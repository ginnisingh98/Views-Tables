--------------------------------------------------------
--  DDL for Package Body PAY_PBC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PBC_BUS" as
/* $Header: pypbcrhi.pkb 120.0 2005/05/29 07:19:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pbc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_balance_category_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_balance_category_id                  in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_balance_categories_f pbc
     where pbc.balance_category_id = p_balance_category_id
       and pbg.business_group_id = pbc.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'balance_category_id'
    ,p_argument_value     => p_balance_category_id
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
     hr_multi_message.add
       (p_associated_column1
         => nvl(p_associated_column1,'BALANCE_CATEGORY_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_balance_category_id                  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_balance_categories_f pbc
     where pbc.balance_category_id = p_balance_category_id
       and pbg.business_group_id (+) = pbc.business_group_id;
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
    ,p_argument           => 'balance_category_id'
    ,p_argument_value     => p_balance_category_id
    );
  --
  if ( nvl(pay_pbc_bus.g_balance_category_id, hr_api.g_number)
       = p_balance_category_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_pbc_bus.g_legislation_code;
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
    pay_pbc_bus.g_balance_category_id         := p_balance_category_id;
    pay_pbc_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_category_name >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the category_name is unique.
--   A hierachy is used to prevent duplicate category names. GENERIC mode takes
--   priority, if a generic row exists then error with duplicate name, but if a
--   startup or user row exists with same name then error, saying the existig
--   row must be deleted and retry insert of GENERIC.
--   IF in STARTUP mode, if generic row or startup row in same legislation
--   exists then error - duplicate row.
--   NB. user rows cannot be created for balance categories. If in the future
--   they can be created see pay_bad_bus.chk_attribute_name for additional
--   functionality.
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
--   Processing continues if a valid category_name has been entered.
--
-- Post Failure:
--   An application error is raised if a duplicate category_name has been
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_category_name
  (p_balance_category_id       in number
  ,p_category_name     in varchar2
  ,p_effective_date    in date
  ,p_business_group_id in number default null
  ,p_legislation_code  in varchar2 default null) IS
--
  l_proc     varchar2(72) := g_package || 'chk_category_name';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_category_name varchar2(80);
  l_bg_id    number;
  l_leg_code varchar2(80);
  l_mode     varchar2(30);
  l_bg_leg   varchar2(80);
  --
  -- NB removed date restriction, as does not work if p_effective_date
  -- is before the p_effective_start_date.
  --
  cursor csr_category_name is
  select pbc.category_name
  ,      pbc.legislation_code
  ,      pbc.business_group_id
  from   pay_balance_categories_f pbc
  where  pbc.category_name = p_category_name;
Begin
--
hr_utility.set_location('Entering: '||l_proc,5);
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the run_type_name has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the run_type_name is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null, because pre_inset has not been called yet.
--
IF (((p_balance_category_id is not null) and
     nvl(pay_pbc_shd.g_old_rec.category_name, hr_api.g_varchar2) <>
     nvl(p_category_name, hr_api.g_varchar2))
   or
    (p_balance_category_id is null)) then
    --
      hr_utility.set_location(l_proc, 10);
      --
      -- Only need to open the cursor if category_name is not null
      --
      if p_category_name is not null then
      --
      l_mode := hr_startup_data_api_support.return_startup_mode;
      --
          OPEN csr_category_name;
          FETCH csr_category_name INTO l_category_name
                                      ,l_leg_code
                                      ,l_bg_id;
          IF csr_category_name%NOTFOUND THEN
          --
            hr_utility.trace('insert row');
            CLOSE csr_category_name;
          ELSE
          --
            if l_mode = 'GENERIC' then
              hr_utility.set_location(l_proc, 15);
              if (l_leg_code is null and l_bg_id is null) then
                hr_utility.set_message(801,'PAY_34223_CAT_DUP_GEN');
                hr_utility.raise_error;
              elsif
                 l_leg_code is not null
              or l_bg_id is not null then
                -- name exists at lower level, existing row must be deleted
                -- so new seeded row can be inserted.
                hr_utility.set_message(801,'PAY_34224_S_CAT_LOW_LVL_DEL');
                hr_utility.raise_error;
              end if;
            elsif l_mode = 'STARTUP' THEN
              hr_utility.set_location(l_proc, 20);
              if (l_leg_code = p_legislation_code) then
                hr_utility.set_message(801,'PAY_34225_CAT_DUP_S');
                hr_utility.raise_error;
              elsif
                 l_leg_code is null then
                   if l_bg_id is not null then
                     hr_utility.trace('here');
                     hr_utility.set_message(801,'PAY_34226_U_CAT_LOW_LVL_DEL');
                     hr_utility.raise_error;
                   else -- l_bg_id is null then
                     hr_utility.trace('here2');
                     hr_utility.set_message(801,'PAY_34227_G_CAT_HI_LVL');
                     hr_utility.raise_error;
                   end if;
              end if;
            end if; -- what mode
            close csr_category_name;
          --
          END IF;
        end if;
end if;
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_category_name;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_user_category_name >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Note: user_category_name is being added for NLS support of this table.
--   The check functionality is the same as for category_name.
--   This procedure is used to ensure that the user_category_name is unique.
--   A hierachy is used to prevent duplicate user category names. GENERIC mode
--   takes priority, if a generic row exists then error with duplicate name,
--   but if a startup or user row exists with same name then error, saying the
--   existig row must be deleted and retry insert of GENERIC.
--   IF in STARTUP mode, if generic row or startup row in same legislation
--   exists then error - duplicate row.
--   NB. user rows cannot be created for balance categories. If in the future
--   they can be created see pay_bad_bus.chk_attribute_name for additional
--   functionality.
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
--   Processing continues if a valid user_category_name has been entered.
--
-- Post Failure:
--   An application error is raised if a duplicate user_category_name has been
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_user_category_name
  (p_balance_category_id in number
  ,p_user_category_name  in varchar2
  ,p_business_group_id   in number default null
  ,p_legislation_code    in varchar2 default null) IS
--
  l_proc     varchar2(72) := g_package || 'chk_user_category_name';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_user_category_name varchar2(80);
  l_bg_id    number;
  l_leg_code varchar2(80);
  l_mode     varchar2(30);
  l_bg_leg   varchar2(80);
  --
  cursor csr_user_category_name is
  select pbc.user_category_name
  ,      pbc.legislation_code
  ,      pbc.business_group_id
  from   pay_balance_categories_f pbc
  where  pbc.user_category_name = p_user_category_name;
Begin
--
hr_utility.set_location('Entering: '||l_proc,5);
--
-- Only execute the cursor if absolutely necessary.
-- a) During update, the user_category_name has actually changed to another not
--    null value, i,e, the value passed to this procedure is different to the
--    g_old_rec value.
-- b) During insert, the user_category_name is null.
-- Can tell the difference between insert and update by looking at the
-- primary key value. For update it will be not null. For insert it will be
-- null, because pre_inset has not been called yet.
--
IF (((p_balance_category_id is not null) and
     nvl(pay_pbc_shd.g_old_rec.user_category_name, hr_api.g_varchar2) <>
     nvl(p_user_category_name, hr_api.g_varchar2))
   or
    (p_balance_category_id is null)) then
    --
      hr_utility.set_location(l_proc, 10);
      --
      -- Only need to open the cursor if user_category_name is not null
      --
      if p_user_category_name is not null then
      --
      l_mode := hr_startup_data_api_support.return_startup_mode;
      --
          OPEN csr_user_category_name;
          FETCH csr_user_category_name INTO l_user_category_name
                                           ,l_leg_code
                                           ,l_bg_id;
          IF csr_user_category_name%NOTFOUND THEN
          --
            hr_utility.trace('insert row');
            CLOSE csr_user_category_name;
          ELSE
          --
            if l_mode = 'GENERIC' then
              hr_utility.set_location(l_proc, 15);
              if (l_leg_code is null and l_bg_id is null) then
                hr_utility.set_message(801,'PAY_34272_USR_CAT_DUP_GEN');
                hr_utility.raise_error;
              elsif
                 l_leg_code is not null
              or l_bg_id is not null then
                -- name exists at lower level, existing row must be deleted
                -- so new seeded row can be inserted.
                hr_utility.set_message(801,'PAY_34273_S_USRCAT_LOWLVL_DEL');
                hr_utility.raise_error;
              end if;
            elsif l_mode = 'STARTUP' THEN
              hr_utility.set_location(l_proc, 20);
              if (l_leg_code = p_legislation_code) then
                hr_utility.set_message(801,'PAY_34274_USRCAT_DUP_S');
                hr_utility.raise_error;
              elsif
                 l_leg_code is null then
                   if l_bg_id is not null then
                    hr_utility.trace('here');
                    hr_utility.set_message(801,'PAY_34275_U_USRCAT_LOWLVL_DEL');
                    hr_utility.raise_error;
                   else -- l_bg_id is null then
                     hr_utility.trace('here2');
                     hr_utility.set_message(801,'PAY_34276_G_USRCAT_HI_LVL');
                     hr_utility.raise_error;
                   end if;
              end if;
            end if; -- what mode
            close csr_user_category_name;
          --
          END IF;
        end if;
end if;
hr_utility.set_location('Leaving: '||l_proc, 20);
--
END chk_user_category_name;
-- ----------------------------------------------------------------------------
-- |----------------------< chk_save_run_bal_enabled >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that a valid value is entered in
--   save_run_balance_enabled.
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
--   Processing continues if a valid value is entered in
--   save_run_balance_enabled.
--
-- Post Failure:
--   An application error is raised if a value other than those returned from
--   HR_STANDARD_LOOKUPS with lookup_type = 'YES_NO'.
--   entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_save_run_bal_enabled
  (p_effective_date           in date
  ,p_validation_start_date    in date
  ,p_validation_end_date      in date
  ,p_save_run_balance_enabled in varchar2) IS
--
  l_proc     varchar2(72) := g_package || 'chk_save_run_bal_enabled';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  --
Begin
--
hr_utility.set_location('Entering: '||l_proc,5);
--
-- YES_NO is a system level lookup, so only need to validate against
-- hr_standar_lookups, even though the table has a business_group_id and
-- would expect to need to validate against hr_lookups.
--
  if p_save_run_balance_enabled is not null then
  --
    IF hr_api.not_exists_in_dt_hrstanlookups
                      (p_effective_date          => p_effective_date
                      ,p_validation_start_date   => p_validation_start_date
                      ,p_validation_end_date     => p_validation_end_date
                      ,p_lookup_type             => 'YES_NO'
                      ,p_lookup_code             => p_save_run_balance_enabled
                      )
    THEN
    --
    -- the value entered for this  record is not recognised
    --
      fnd_message.set_name('PAY', 'PAY_34228_PBC_INV_LOOKUP');
      fnd_message.raise_error;
      --
      hr_utility.set_location(l_proc,10);
    END IF;
  end if;
  --
hr_utility.set_location('Leaving: '||l_proc,15);
--
End chk_save_run_bal_enabled;
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
  (p_rec in pay_pbc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.balance_category_id is not null)  and (
    nvl(pay_pbc_shd.g_old_rec.pbc_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information_category, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information1, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information2, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information3, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information4, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information5, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information6, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information7, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information8, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information9, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information10, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information11, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information12, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information13, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information14, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information15, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information16, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information17, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information18, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information19, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information20, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information21, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information21, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information22, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information22, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information23, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information23, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information24, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information24, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information25, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information25, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information26, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information26, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information27, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information27, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information28, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information28, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information29, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information29, hr_api.g_varchar2)  or
    nvl(pay_pbc_shd.g_old_rec.pbc_information30, hr_api.g_varchar2) <>
    nvl(p_rec.pbc_information30, hr_api.g_varchar2) ))
    or (p_rec.balance_category_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Balance Category Developer DF'
    --  ,p_attribute_category              => 'PBC_INFORMATION_CATEGORY'
      ,p_attribute_category              => p_rec.pbc_information_category
      ,p_attribute1_name                 => 'PBC_INFORMATION1'
      ,p_attribute1_value                => p_rec.pbc_information1
      ,p_attribute2_name                 => 'PBC_INFORMATION2'
      ,p_attribute2_value                => p_rec.pbc_information2
      ,p_attribute3_name                 => 'PBC_INFORMATION3'
      ,p_attribute3_value                => p_rec.pbc_information3
      ,p_attribute4_name                 => 'PBC_INFORMATION4'
      ,p_attribute4_value                => p_rec.pbc_information4
      ,p_attribute5_name                 => 'PBC_INFORMATION5'
      ,p_attribute5_value                => p_rec.pbc_information5
      ,p_attribute6_name                 => 'PBC_INFORMATION6'
      ,p_attribute6_value                => p_rec.pbc_information6
      ,p_attribute7_name                 => 'PBC_INFORMATION7'
      ,p_attribute7_value                => p_rec.pbc_information7
      ,p_attribute8_name                 => 'PBC_INFORMATION8'
      ,p_attribute8_value                => p_rec.pbc_information8
      ,p_attribute9_name                 => 'PBC_INFORMATION9'
      ,p_attribute9_value                => p_rec.pbc_information9
      ,p_attribute10_name                => 'PBC_INFORMATION10'
      ,p_attribute10_value               => p_rec.pbc_information10
      ,p_attribute11_name                => 'PBC_INFORMATION11'
      ,p_attribute11_value               => p_rec.pbc_information11
      ,p_attribute12_name                => 'PBC_INFORMATION12'
      ,p_attribute12_value               => p_rec.pbc_information12
      ,p_attribute13_name                => 'PBC_INFORMATION13'
      ,p_attribute13_value               => p_rec.pbc_information13
      ,p_attribute14_name                => 'PBC_INFORMATION14'
      ,p_attribute14_value               => p_rec.pbc_information14
      ,p_attribute15_name                => 'PBC_INFORMATION15'
      ,p_attribute15_value               => p_rec.pbc_information15
      ,p_attribute16_name                => 'PBC_INFORMATION16'
      ,p_attribute16_value               => p_rec.pbc_information16
      ,p_attribute17_name                => 'PBC_INFORMATION17'
      ,p_attribute17_value               => p_rec.pbc_information17
      ,p_attribute18_name                => 'PBC_INFORMATION18'
      ,p_attribute18_value               => p_rec.pbc_information18
      ,p_attribute19_name                => 'PBC_INFORMATION19'
      ,p_attribute19_value               => p_rec.pbc_information19
      ,p_attribute20_name                => 'PBC_INFORMATION20'
      ,p_attribute20_value               => p_rec.pbc_information20
      ,p_attribute21_name                => 'PBC_INFORMATION21'
      ,p_attribute21_value               => p_rec.pbc_information21
      ,p_attribute22_name                => 'PBC_INFORMATION22'
      ,p_attribute22_value               => p_rec.pbc_information22
      ,p_attribute23_name                => 'PBC_INFORMATION23'
      ,p_attribute23_value               => p_rec.pbc_information23
      ,p_attribute24_name                => 'PBC_INFORMATION24'
      ,p_attribute24_value               => p_rec.pbc_information24
      ,p_attribute25_name                => 'PBC_INFORMATION25'
      ,p_attribute25_value               => p_rec.pbc_information25
      ,p_attribute26_name                => 'PBC_INFORMATION26'
      ,p_attribute26_value               => p_rec.pbc_information26
      ,p_attribute27_name                => 'PBC_INFORMATION27'
      ,p_attribute27_value               => p_rec.pbc_information27
      ,p_attribute28_name                => 'PBC_INFORMATION28'
      ,p_attribute28_value               => p_rec.pbc_information28
      ,p_attribute29_name                => 'PBC_INFORMATION29'
      ,p_attribute29_value               => p_rec.pbc_information29
      ,p_attribute30_name                => 'PBC_INFORMATION30'
      ,p_attribute30_value               => p_rec.pbc_information30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_for_child_rows >---------------------------|
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
Procedure chk_for_child_rows
  (p_balance_category_id in number
  ,p_effective_date      in date
  ,p_business_group_id   in number default null
  ,p_legislation_code    in varchar2 default null) is
  --
  cursor csr_child_balance(p_bal_cat_id number
                          ,p_bg_id      number)
  is
  select 1
  from   pay_balance_types pbt
  where  pbt.balance_category_id = p_bal_cat_id
  and    pbt.business_group_id = nvl(p_bg_id, pbt.business_group_id);
  --
  cursor csr_child_defaults(p_bal_cat_id number
                           ,p_bg_id      number)
  is
  select 1
  from   pay_bal_attribute_defaults pbd
  where  pbd.balance_category_id = p_bal_cat_id
  and    pbd.business_group_id = nvl(p_bg_id, pbd.business_group_id);
  --
  cursor get_bg_id
  is
  select business_group_id
  from   per_business_groups
  where  legislation_code = p_legislation_code;
  --
  l_proc     varchar2(72) := g_package || 'chk_for_child_rows';
  l_error    EXCEPTION;
  l_argument varchar2(30);
  l_exists   number(1);
--
BEGIN
hr_utility.set_location('Entering: '||l_proc,5);
--
if p_legislation_code is not null then -- startup category
--
  for each_bg in get_bg_id loop
    open csr_child_balance(p_balance_category_id, each_bg.business_group_id);
    fetch csr_child_balance into l_exists;
    if csr_child_balance%FOUND then
      close csr_child_balance;
      hr_utility.set_message(801,'PAY_34230_PBC_CHILD_BAL');
      hr_utility.raise_error;
      hr_utility.set_location(l_proc, 10);
    else
      close csr_child_balance;
    end if;
    --
    -- check for existing child pay_bal_attribute_defaults
    --
    open csr_child_defaults(p_balance_category_id, each_bg.business_group_id);
    fetch csr_child_defaults into l_exists;
    if csr_child_defaults%FOUND then
      close csr_child_defaults;
      hr_utility.set_message(801,'PAY_34229_PBC_CHLD_ATT_DEFAULT');
      hr_utility.raise_error;
      hr_utility.set_location(l_proc, 15);
    else
      close csr_child_defaults;
    end if;
  end loop;
--
ELSE -- generic category
  open csr_child_balance(p_balance_category_id, p_business_group_id);
  fetch csr_child_balance into l_exists;
  if csr_child_balance%FOUND then
    close csr_child_balance;
    hr_utility.set_message(801,'PAY_34230_PBC_CHILD_BAL');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 20);
  else
    close csr_child_balance;
  end if;
  --
  -- check for existing child pay_bal_attribute_definitions
  --
  open csr_child_defaults(p_balance_category_id, p_business_group_id);
  fetch csr_child_defaults into l_exists;
  if csr_child_defaults%FOUND then
    close csr_child_defaults;
    hr_utility.set_message(801,'PAY_34229_PBC_CHLD_ATT_DEFAULT');
    hr_utility.raise_error;
    hr_utility.set_location(l_proc, 25);
  else
    close csr_child_defaults;
  end if;
END IF;
hr_utility.set_location(' Leaving:'|| l_proc, 40);
--
End chk_for_child_rows;
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
  (p_effective_date  in date
  ,p_rec             in pay_pbc_shd.g_rec_type
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
  IF NOT pay_pbc_shd.api_updating
      (p_balance_category_id              => p_rec.balance_category_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_pbc_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 15);
  --
  if p_rec.balance_category_id <> pay_pbc_shd.g_old_rec.balance_category_id then
     l_argument := 'balance_category_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 20);
  --
  if p_rec.legislation_code <> pay_pbc_shd.g_old_rec.legislation_code then
     l_argument := 'legislation_code';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 25);
  --
    if p_rec.category_name <> pay_pbc_shd.g_old_rec.category_name then
     l_argument := 'category_name';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
End chk_non_updateable_args;
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
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
    --
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
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
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_balance_category_id              in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'balance_category_id'
      ,p_argument_value => p_balance_category_id
      );
    --
  --
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  -- NOTE: USER rows are not permitted in PAY_BALANCE_CATEGORIES_F
  --
  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => FALSE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => FALSE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_pbc_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_pbc_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Validate Dependent Attributes
  --
  pay_pbc_bus.chk_category_name
             (p_balance_category_id => p_rec.balance_category_id
             ,p_category_name       => p_rec.category_name
             ,p_effective_date      => p_effective_date
             ,p_business_group_id   => p_rec.business_group_id
             ,p_legislation_code    => p_rec.legislation_code
             );
  --
  pay_pbc_bus.chk_user_category_name
             (p_balance_category_id => p_rec.balance_category_id
             ,p_user_category_name  => p_rec.user_category_name
             ,p_business_group_id   => p_rec.business_group_id
             ,p_legislation_code    => p_rec.legislation_code
             );
  --
  pay_pbc_bus.chk_save_run_bal_enabled
             (p_effective_date           => p_effective_date
             ,p_validation_start_date    => p_validation_start_date
             ,p_validation_end_date      => p_validation_end_date
             ,p_save_run_balance_enabled => p_rec.save_run_balance_enabled
             );
  --
  pay_pbc_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_pbc_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_pbc_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Validate Dependent Attributes
  --
  pay_pbc_bus.chk_category_name
             (p_balance_category_id => p_rec.balance_category_id
             ,p_category_name       => p_rec.category_name
             ,p_effective_date      => p_effective_date
             ,p_business_group_id   => p_rec.business_group_id
             ,p_legislation_code    => p_rec.legislation_code
             );
  --
  pay_pbc_bus.chk_user_category_name
             (p_balance_category_id => p_rec.balance_category_id
             ,p_user_category_name  => p_rec.user_category_name
             ,p_business_group_id   => p_rec.business_group_id
             ,p_legislation_code    => p_rec.legislation_code
             );
  --
  pay_pbc_bus.chk_save_run_bal_enabled
             (p_effective_date           => p_effective_date
             ,p_validation_start_date    => p_validation_start_date
             ,p_validation_end_date      => p_validation_end_date
             ,p_save_run_balance_enabled => p_rec.save_run_balance_enabled
             );
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  --
  pay_pbc_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_pbc_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- NB. need to use g_old_rec, as p_rec is not pupulated with all the columns
  -- for delete mode.
  --
  chk_for_child_rows
             (p_balance_category_id => p_rec.balance_category_id
             ,p_effective_date      => p_effective_date
             ,p_business_group_id   => pay_pbc_shd.g_old_rec.business_group_id
             ,p_legislation_code    => pay_pbc_shd.g_old_rec.legislation_code);
  --
  chk_startup_action(false
                    ,pay_pbc_shd.g_old_rec.business_group_id
                    ,pay_pbc_shd.g_old_rec.legislation_code
                    );
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_balance_category_id              => p_rec.balance_category_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_pbc_bus;

/
