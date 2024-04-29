--------------------------------------------------------
--  DDL for Package Body BEN_PDT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDT_BUS" as
/* $Header: bepdtrhi.pkb 115.0 2003/10/30 09:33 rpillay noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pdt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pymt_check_det_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pymt_check_det_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ben_pymt_check_det pdt
     where pdt.pymt_check_det_id = p_pymt_check_det_id
       and pbg.business_group_id = pdt.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pymt_check_det_id'
    ,p_argument_value     => p_pymt_check_det_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'PYMT_CHECK_DET_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_pymt_check_det_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ben_pymt_check_det pdt
     where pdt.pymt_check_det_id = p_pymt_check_det_id
       and pbg.business_group_id = pdt.business_group_id;
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
    ,p_argument           => 'pymt_check_det_id'
    ,p_argument_value     => p_pymt_check_det_id
    );
  --
  if ( nvl(ben_pdt_bus.g_pymt_check_det_id, hr_api.g_number)
       = p_pymt_check_det_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_pdt_bus.g_legislation_code;
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
    ben_pdt_bus.g_pymt_check_det_id           := p_pymt_check_det_id;
    ben_pdt_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ben_pdt_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.pymt_check_det_id is not null)  and (
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute_category, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute1, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute2, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute3, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute4, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute5, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute6, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute7, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute8, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute9, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute10, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute11, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute12, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute13, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute14, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute15, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute16, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute17, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute18, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute19, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute20, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute21, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute22, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute23, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute24, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute25, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute26, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute27, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute28, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute29, hr_api.g_varchar2)  or
    nvl(ben_pdt_shd.g_old_rec.pdt_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.pdt_attribute30, hr_api.g_varchar2) ))
    or (p_rec.pymt_check_det_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'BEN'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'PDT_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'PDT_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.pdt_attribute1
      ,p_attribute2_name                 => 'PDT_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.pdt_attribute2
      ,p_attribute3_name                 => 'PDT_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.pdt_attribute3
      ,p_attribute4_name                 => 'PDT_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.pdt_attribute4
      ,p_attribute5_name                 => 'PDT_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.pdt_attribute5
      ,p_attribute6_name                 => 'PDT_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.pdt_attribute6
      ,p_attribute7_name                 => 'PDT_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.pdt_attribute7
      ,p_attribute8_name                 => 'PDT_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.pdt_attribute8
      ,p_attribute9_name                 => 'PDT_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.pdt_attribute9
      ,p_attribute10_name                => 'PDT_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.pdt_attribute10
      ,p_attribute11_name                => 'PDT_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.pdt_attribute11
      ,p_attribute12_name                => 'PDT_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.pdt_attribute12
      ,p_attribute13_name                => 'PDT_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.pdt_attribute13
      ,p_attribute14_name                => 'PDT_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.pdt_attribute14
      ,p_attribute15_name                => 'PDT_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.pdt_attribute15
      ,p_attribute16_name                => 'PDT_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.pdt_attribute16
      ,p_attribute17_name                => 'PDT_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.pdt_attribute17
      ,p_attribute18_name                => 'PDT_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.pdt_attribute18
      ,p_attribute19_name                => 'PDT_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.pdt_attribute19
      ,p_attribute20_name                => 'PDT_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.pdt_attribute20
      ,p_attribute21_name                => 'PDT_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.pdt_attribute21
      ,p_attribute22_name                => 'PDT_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.pdt_attribute22
      ,p_attribute23_name                => 'PDT_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.pdt_attribute23
      ,p_attribute24_name                => 'PDT_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.pdt_attribute24
      ,p_attribute25_name                => 'PDT_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.pdt_attribute25
      ,p_attribute26_name                => 'PDT_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.pdt_attribute26
      ,p_attribute27_name                => 'PDT_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.pdt_attribute27
      ,p_attribute28_name                => 'PDT_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.pdt_attribute28
      ,p_attribute29_name                => 'PDT_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.pdt_attribute29
      ,p_attribute30_name                => 'PDT_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.pdt_attribute30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
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
  (p_effective_date               in date
  ,p_rec in ben_pdt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ben_pdt_shd.api_updating
      (p_pymt_check_det_id                 => p_rec.pymt_check_det_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  IF nvl(p_rec.business_group_id,hr_api.g_number) <>
     nvl(ben_pdt_shd.g_old_rec.business_group_id,hr_api.g_number) then

     hr_api.argument_changed_error
     (p_api_name      => l_proc,
      p_argument      => 'BUSINESS_GROUP_ID',
      p_base_table    => ben_pdt_shd.g_tab_nam);
  END IF;
  --
  IF nvl(p_rec.person_id,hr_api.g_number) <>
     nvl(ben_pdt_shd.g_old_rec.person_id,hr_api.g_number) then

     hr_api.argument_changed_error
     (p_api_name      => l_proc,
      p_argument      => 'PERSON_ID',
      p_base_table    => ben_pdt_shd.g_tab_nam);
  END IF;

End chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_pymt_check_det_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pymt_check_det_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_pymt_check_det_id(p_pymt_check_det_id           in number,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pymt_check_det_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pdt_shd.api_updating
    (p_pymt_check_det_id           => p_pymt_check_det_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pymt_check_det_id,hr_api.g_number)
     <>  ben_pdt_shd.g_old_rec.pymt_check_det_id) then
    --
    -- raise error as PK has changed
    --
    ben_pty_shd.constraint_error('BEN_PYMT_CHECK_DET_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pymt_check_det_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pty_shd.constraint_error('BEN_PYMT_CHECK_DET_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pymt_check_det_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_person_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pymt_check_det_id PK
--   p_person_ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_person_id (p_pymt_check_det_id     in number,
                         p_person_id             in number,
                         p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_people_f a
    where  a.person_id = p_person_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
 l_api_updating := ben_pdt_shd.api_updating
     (p_pymt_check_det_id       => p_pymt_check_det_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_person_id,hr_api.g_number)
     <> nvl(ben_pdt_shd.g_old_rec.person_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if person_id value exists in per_all_people_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people_f
        -- table.
        --
        ben_pdt_shd.constraint_error('BEN_PYMT_CHECK_DET_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ben_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_pdt_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --
  chk_pymt_check_det_id(p_pymt_check_det_id           => p_rec.pymt_check_det_id
                       ,p_object_version_number       => p_rec.object_version_number);

  chk_person_id(p_pymt_check_det_id           => p_rec.pymt_check_det_id
               ,p_person_id                   => p_rec.person_id
               ,p_object_version_number       => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ben_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_pdt_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date    => p_effective_date
      ,p_rec              => p_rec
    );
  --
  chk_pymt_check_det_id(p_pymt_check_det_id           => p_rec.pymt_check_det_id
                       ,p_object_version_number       => p_rec.object_version_number);

  chk_person_id(p_pymt_check_det_id           => p_rec.pymt_check_det_id
               ,p_person_id                   => p_rec.person_id
               ,p_object_version_number       => p_rec.object_version_number);


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ben_pdt_shd.g_rec_type
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
end ben_pdt_bus;

/
