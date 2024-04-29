--------------------------------------------------------
--  DDL for Package Body PER_BBA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BBA_BUS" as
/* $Header: pebbarhi.pkb 115.8 2002/12/02 13:03:45 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bba_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code       varchar2(150)  default null;
g_balance_amount_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure set_security_group_id
  (p_balance_amount_id                    in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select inf.org_information14
      from hr_organization_information inf
         , per_bf_balance_amounts bba
     where bba.balance_amount_id = p_balance_amount_id
       and inf.organization_id   = bba.business_group_id
       and inf.org_information_context || '' = 'Business Group Information';
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
  hr_api.mandatory_arg_error(p_api_name           => l_proc,
                             p_argument           => 'BALANCE_AMOUNT_ID',
                             p_argument_value     => p_balance_amount_id);
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
     fnd_message.set_name('PER','HR_7220_INVALID_PRIMARY_KEY');
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
function return_legislation_code
  (p_balance_amount_id                    in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_bf_balance_amounts bba
     where bba.balance_amount_id = p_balance_amount_id
       and pbg.business_group_id = bba.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name           => l_proc,
                             p_argument           => 'BALANCE_AMOUNT_ID',
                             p_argument_value     => p_balance_amount_id);
  --
  if ( nvl(g_balance_amount_id, hr_api.g_number) = p_balance_amount_id) then
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
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PER','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    g_balance_amount_id                 := p_balance_amount_id;
    g_legislation_code                  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in per_bba_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.balance_amount_id is not null)  and (
    nvl(per_bba_shd.g_old_rec.bba_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute_category, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute1, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute2, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute3, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute4, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute5, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute6, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute7, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute8, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute9, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute10, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute11, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute12, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute13, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute14, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute15, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute16, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute17, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute18, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute19, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute20, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute21, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute22, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute23, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute24, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute25, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute26, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute27, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute28, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute29, hr_api.g_varchar2)  or
    nvl(per_bba_shd.g_old_rec.bba_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.bba_attribute30, hr_api.g_varchar2) ))
    or (p_rec.balance_amount_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_BF_BALANCE_AMOUNTS'
      ,p_attribute_category              => p_rec.bba_attribute_category
      ,p_attribute1_name                 => 'BBA_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.bba_attribute1
      ,p_attribute2_name                 => 'BBA_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.bba_attribute2
      ,p_attribute3_name                 => 'BBA_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.bba_attribute3
      ,p_attribute4_name                 => 'BBA_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.bba_attribute4
      ,p_attribute5_name                 => 'BBA_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.bba_attribute5
      ,p_attribute6_name                 => 'BBA_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.bba_attribute6
      ,p_attribute7_name                 => 'BBA_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.bba_attribute7
      ,p_attribute8_name                 => 'BBA_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.bba_attribute8
      ,p_attribute9_name                 => 'BBA_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.bba_attribute9
      ,p_attribute10_name                => 'BBA_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.bba_attribute10
      ,p_attribute11_name                => 'BBA_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.bba_attribute11
      ,p_attribute12_name                => 'BBA_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.bba_attribute12
      ,p_attribute13_name                => 'BBA_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.bba_attribute13
      ,p_attribute14_name                => 'BBA_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.bba_attribute14
      ,p_attribute15_name                => 'BBA_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.bba_attribute15
      ,p_attribute16_name                => 'BBA_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.bba_attribute16
      ,p_attribute17_name                => 'BBA_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.bba_attribute17
      ,p_attribute18_name                => 'BBA_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.bba_attribute18
      ,p_attribute19_name                => 'BBA_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.bba_attribute19
      ,p_attribute20_name                => 'BBA_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.bba_attribute20
      ,p_attribute21_name                => 'BBA_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.bba_attribute21
      ,p_attribute22_name                => 'BBA_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.bba_attribute22
      ,p_attribute23_name                => 'BBA_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.bba_attribute23
      ,p_attribute24_name                => 'BBA_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.bba_attribute24
      ,p_attribute25_name                => 'BBA_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.bba_attribute25
      ,p_attribute26_name                => 'BBA_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.bba_attribute26
      ,p_attribute27_name                => 'BBA_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.bba_attribute27
      ,p_attribute28_name                => 'BBA_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.bba_attribute28
      ,p_attribute29_name                => 'BBA_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.bba_attribute29
      ,p_attribute30_name                => 'BBA_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.bba_attribute30
      );
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
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
Procedure chk_non_updateable_args(p_rec in per_bba_shd.g_rec_type) IS
--
  l_proc     varchar2(72) := g_package || 'check_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_bba_shd.api_updating
      (p_balance_amount_id                      => p_rec.balance_amount_id
       ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE ', l_proc);
     hr_utility.set_message_token('STEP ', '5');
  END IF;
  --
  hr_utility.set_location(l_proc,10);
  --
  IF nvl(p_rec.balance_type_id, hr_api.g_number) <>
  per_bba_shd.g_old_rec.balance_type_id then
  l_argument:='balance_type_id';
  raise l_error;
  END IF;
  hr_utility.set_location(l_proc,20);
  --
  IF nvl(p_rec.processed_assignment_id, hr_api.g_number) <>
  per_bba_shd.g_old_rec.processed_assignment_id then
  l_argument:='processed_assignment_id';
  raise l_error;
  END IF;
  hr_utility.set_location(l_proc,30);
  --
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
  per_bba_shd.g_old_rec.business_group_id then
  l_argument:='business_group_id';
  raise l_error;
  END IF;
  hr_utility.set_location(l_proc,40);
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
  hr_utility.set_location(' Leaving:'||l_proc,20);
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_processed_asg_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Check that the processed_asg_idexists in the table
--   PER_BF_PROCESSED_ASSIGNMENTS
--
-- Pre Conditions:
--
-- In Arguments:
--   p_processed_assignment_id
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_processed_asg_id
 (p_processed_assignment_id  IN NUMBER)
IS
  --
  CURSOR csr_chk_processed_asg_id IS
  SELECT 1
  FROM PER_BF_PROCESSED_ASSIGNMENTS
  WHERE processed_assignment_id = p_processed_assignment_id;
  --
  l_temp   VARCHAR2(1);
  l_proc     varchar2(72) := g_package || 'chk_processed_asg_id';
BEGIN
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  OPEN csr_chk_processed_asg_id ;
  FETCH csr_chk_processed_asg_id INTO l_temp;
  --
  IF csr_chk_processed_asg_id%NOTFOUND THEN
    --
    CLOSE csr_chk_processed_asg_id;
    --
    -- The ID hasn't been found, so error
    --
    per_bba_shd.constraint_error
         (p_constraint_name => 'PER_BF_BALANCE_AMOUNTS_FK3');
    --
  END IF;
  CLOSE csr_chk_processed_asg_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
END chk_processed_asg_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_balance_type_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Check that the balance_type_id exists in the table
--   PER_BF_BALANCE_AMOUNTS
--
-- Pre Conditions:
--
-- In Arguments:
--   p_balance_type_id
--   p_business_group_id
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE CHK_BALANCE_TYPE_ID
  (p_balance_type_id	 IN NUMBER
  ,p_business_group_id   IN NUMBER
  )
IS
  CURSOR csr_chk_balance_type_id IS
  SELECT 1
  FROM per_bf_balance_types
  WHERE balance_type_id = p_balance_type_id
  AND business_group_id = p_business_group_id;
  --
  l_temp   VARCHAR2(1);
  --
BEGIN
  OPEN csr_chk_balance_type_id;
  FETCH csr_chk_balance_type_id INTO l_temp;
  IF csr_chk_balance_type_id%NOTFOUND THEN
    --
    CLOSE csr_chk_balance_type_id;
    --
    -- The balance type either doesn't exist or is in a different BG
    -- so error.
    --
    per_bba_shd.constraint_error
       (p_constraint_name => 'PER_BF_BALANCE_AMOUNTS_FK2');
    --
  END IF;
  --
  CLOSE csr_chk_balance_type_id;
  --
  --
END CHK_BALANCE_TYPE_ID;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_effective_date   in  date,
                          p_rec in per_bba_shd.g_rec_type
                         ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
 CHK_PROCESSED_ASG_ID
 (p_processed_assignment_id  => p_rec.processed_assignment_id);
  --
  CHK_BALANCE_TYPE_ID
  (p_balance_type_id	 => p_rec.balance_type_id
  ,p_business_group_id   => p_rec.business_group_id
  );
  -- Validate flexfields
  -- ===================
  chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_effective_date   in  date,
                          p_rec in per_bba_shd.g_rec_type
                         ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args(p_rec => p_rec);
  --
  -- Validate flexfields
  -- ===================
  chk_df(p_rec => p_rec);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_bba_shd.g_rec_type) is
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
end per_bba_bus;

/
