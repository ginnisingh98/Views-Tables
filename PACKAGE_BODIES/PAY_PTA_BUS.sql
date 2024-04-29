--------------------------------------------------------
--  DDL for Package Body PAY_PTA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PTA_BUS" as
/* $Header: pyptarhi.pkb 120.0 2005/05/29 07:56:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pta_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_dated_table_id              number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_dated_table_id                       in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_dated_tables pta
     where pta.dated_table_id = p_dated_table_id
       and pbg.business_group_id = pta.business_group_id;
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
    ,p_argument           => 'dated_table_id'
    ,p_argument_value     => p_dated_table_id
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
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_dated_table_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_dated_tables pta
     where pta.dated_table_id = p_dated_table_id
       and pbg.business_group_id (+) = pta.business_group_id;
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
    ,p_argument           => 'dated_table_id'
    ,p_argument_value     => p_dated_table_id
    );
  --
  if ( nvl(pay_pta_bus.g_dated_table_id, hr_api.g_number)
       = p_dated_table_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_pta_bus.g_legislation_code;
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
    pay_pta_bus.g_dated_table_id    := p_dated_table_id;
    pay_pta_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in pay_pta_shd.g_rec_type
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
  IF NOT pay_pta_shd.api_updating
      (p_dated_table_id                       => p_rec.dated_table_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if (nvl(p_rec.table_name, hr_api.g_varchar2) <>
     nvl(pay_pta_shd.g_old_rec.table_name, hr_api.g_varchar2)
     ) then
     l_argument := 'table_name';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.application_id, hr_api.g_number) <>
     nvl(pay_pta_shd.g_old_rec.application_id,hr_api.g_number)
     ) then
     l_argument := 'application_id';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_pta_shd.g_old_rec.business_group_id,hr_api.g_number)
     ) then
     l_argument := 'business_group_id';
     raise l_error;
  END IF;
  --
 if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_pta_shd.g_old_rec.legislation_code, hr_api.g_varchar2)
  then
    l_argument := 'legislation_code';
    raise l_error;
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
-- |---------------------------<chk_dyn_trigger >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure validates the dynamic trigger type passed actually exists
--   in the appropriate lookup.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error if incorrect value is being attempted to insert.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
--
Procedure chk_dyn_trigger
  (p_rec                          in pay_pta_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_dyn_trigger';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate against hr_lookups.
  --
  if p_rec.dyn_trigger_type is not null then
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date => sysdate
      ,p_lookup_type    => 'PAY_DYN_TRIGGER_TYPES'
      ,p_lookup_code    => p_rec.dyn_trigger_type
      )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
      fnd_message.set_token('LOOKUP_TYPE', 'PAY_DYN_TRIGGER_TYPES');
      fnd_message.set_token('VALUE', p_rec.dyn_trigger_type);
     fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_dyn_trigger;

--
-- ----------------------------------------------------------------------------
-- |---------------------------<chk_table_name >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure validates the table  name passed actually exists
--   (EJ:28/4/5) and is in a schema that has dynamic triggers enabled
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error if column not recognised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
--
Procedure chk_table_name
  (p_rec                          in pay_pta_shd.g_rec_type
  ) is
  l_proc        varchar2(72) := g_package||'chk_table_name';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'table_name'
    ,p_argument_value => p_rec.table_name
    );
  --
  If paywsdyg_pkg.is_table_valid(p_rec.table_name) = 'N' Then
    --
    -- The table does not exist and therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_xxxx_INVALID_TABLE_NAME');

    fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_table_name;


--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_dyn_trig_pkg_generated >--------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure validates the flag indicator is yes/no
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error if incorrect value is being attempted to insert.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
--
Procedure chk_dyn_trig_pkg_generated
  (p_rec                          in pay_pta_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_dyn_trig_pkg_generated';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Validate dyn_trig_pkg_generated against hr_lookups.
  --
  if p_rec.dyn_trig_pkg_generated is not null then
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date => sysdate
      ,p_lookup_type    => 'YES_NO'
      ,p_lookup_code    => p_rec.dyn_trig_pkg_generated
      )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'INVALID_LOOKUP_CODE');
      fnd_message.set_token('LOOKUP_TYPE', 'YES_NO');
      fnd_message.set_token('VALUE', p_rec.dyn_trig_pkg_generated);
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_dyn_trig_pkg_generated;


--
-- ----------------------------------------------------------------------------
-- |---------------------------<chk_columns >----------------------------|
-- -----------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure validates the surrogate_key_name, start_date_name
--   and end_date_name are columns which exist on the table referred to
--   (EJ:28/4/5) and that the table is in a schema for which triggers are allowed
--
-- Prerequisites:
--   The table identified by p_table_name already exists.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Error if column not recognised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
--
Procedure chk_columns
  (p_rec                          in pay_pta_shd.g_rec_type
  ) is
--
  l_proc        varchar2(72) := g_package||'chk_columns';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'surrogate_key_name'
    ,p_argument_value => p_rec.surrogate_key_name
    );
  --
  --Bugfix 3114746
  -- remove mandatory_arg_error fo start_date_name and end_date_name
  --
  If paywsdyg_pkg.is_table_column_valid(p_rec.table_name,p_rec.surrogate_key_name) = 'N' Then
    --
    -- The column does not belong to the table therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_xxxx_SURROGATE_KEY_NAME');

    fnd_message.raise_error;
  End If;
  --
  --Bugfix 3114746
  if (p_rec.start_date_name is not null
      and p_rec.end_date_name is not null) then
    If paywsdyg_pkg.is_table_column_valid(p_rec.table_name,p_rec.start_date_name) = 'N' Then
      --
      -- The column does not belong to the table therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_xxxx_START_DATE_NAME');

      fnd_message.raise_error;
    End If;
    --
    If paywsdyg_pkg.is_table_column_valid(p_rec.table_name,p_rec.end_date_name) = 'N' Then
      --
      -- The column does not belong to the table therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_xxxx_END_DATE_NAME');

      fnd_message.raise_error;
    End If;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_columns;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_pta_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_table_name (p_rec              => p_rec);
  --
  chk_columns    (p_rec              => p_rec);
  --
  chk_dyn_trigger(p_rec              => p_rec);
  --
  chk_dyn_trig_pkg_generated(p_rec              => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_pta_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  chk_table_name (p_rec              => p_rec);
  --
  chk_columns    (p_rec              => p_rec);
  --
  chk_dyn_trigger(p_rec              => p_rec);
  --
  chk_dyn_trig_pkg_generated(p_rec              => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_pta_shd.g_rec_type
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
end pay_pta_bus;

/
