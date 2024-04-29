--------------------------------------------------------
--  DDL for Package Body BEN_CSO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CSO_BUS" as
/* $Header: becsorhi.pkb 115.0 2003/03/17 13:37:07 csundar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cso_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_cwb_stock_optn_dtls_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_cwb_stock_optn_dtls_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ben_cwb_stock_optn_dtls cso
     where cso.cwb_stock_optn_dtls_id = p_cwb_stock_optn_dtls_id
       and pbg.business_group_id (+) = cso.business_group_id;
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
    ,p_argument           => 'cwb_stock_optn_dtls_id'
    ,p_argument_value     => p_cwb_stock_optn_dtls_id
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
        => nvl(p_associated_column1,'CWB_STOCK_OPTN_DTLS_ID')
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
  (p_cwb_stock_optn_dtls_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ben_cwb_stock_optn_dtls cso
     where cso.cwb_stock_optn_dtls_id = p_cwb_stock_optn_dtls_id
       and pbg.business_group_id (+) = cso.business_group_id;
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
    ,p_argument           => 'cwb_stock_optn_dtls_id'
    ,p_argument_value     => p_cwb_stock_optn_dtls_id
    );
  --
  if ( nvl(ben_cso_bus.g_cwb_stock_optn_dtls_id, hr_api.g_number)
       = p_cwb_stock_optn_dtls_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_cso_bus.g_legislation_code;
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
    ben_cso_bus.g_cwb_stock_optn_dtls_id      := p_cwb_stock_optn_dtls_id;
    ben_cso_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_valid_entry >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that either person_id OR
--   (Business_group_id and employee_number) is present
--   i.e. if person_id is not present then a business_group_id and
--   employee_number must be present.
--   If person_id is present then business_group_id and employee_number are
--   both optional. If Person_id is present, then business_group_id and
--   employee_number (if present) are valid in person table.
--  If any of these conditions is violated, an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_employee_number
--   p_person_id
--   p_business_group_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if all the conditions are satisfied
--
-- Post Failure:
--   An application error is raised if any of the conditions are not satisfied.

--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_valid_entry
  (p_employee_number                in varchar2
  ,p_person_id                      in number
  ,p_business_group_id              in number
  ,p_effective_date                 in date
  ) IS
  --
  -- Declare cursor
  --

  cursor csr_per is
    select per.person_id,
           per.employee_number,
           per.business_group_id
      from per_all_people_f per
     where per.person_id = p_person_id
     and   p_effective_date between per.effective_start_date and per.effective_end_date;
  --
  -- Declare local variables
  --
    l_per csr_per%rowtype;
    l_proc     varchar2(72) := g_package || 'chk_valid_entry';
  --
  --
 Begin
    hr_utility.set_location('Entering:'||l_proc,10);

   open csr_per;
       fetch csr_per into l_per;
       close csr_per;

  if (p_person_id is null and (p_business_group_id is null or p_employee_number is null))
   then
         fnd_message.set_name('BEN','BEN_93358_CWB_INVALID_STK_ENT');
         fnd_message.raise_error;
   end if;
   if ( p_person_id is not null and p_business_group_id <> l_per.business_group_id)
   then
        fnd_message.set_name('BEN','BEN_93360_CWB_INVALID_BG_ID');
         fnd_message.set_token('BUSINESS_GRP_ID',p_business_group_id);
         fnd_message.set_token('PERSON_ID',p_person_id);
         fnd_message.raise_error;
   end if ;
   if (p_person_id is not null and p_employee_number <> l_per.employee_number)
   then
        fnd_message.set_name('BEN','BEN_93359_CWB_INVALID_EMP_ID');
        fnd_message.set_token('EMPLOYEE_NUMBER',p_employee_number);
        fnd_message.set_token('PERSON_ID',p_person_id);
        fnd_message.raise_error;
   end if;

   hr_utility.set_location(' Leaving:'||l_proc,20);

End chk_valid_entry;

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
  (p_rec in ben_cso_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.cwb_stock_optn_dtls_id is not null)  and (
    nvl(ben_cso_shd.g_old_rec.cso_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute_category, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute1, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute2, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute3, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute4, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute5, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute6, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute7, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute8, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute9, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute10, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute11, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute12, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute13, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute14, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute15, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute16, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute17, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute18, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute19, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute20, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute21, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute22, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute23, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute24, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute25, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute26, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute27, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute28, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute29, hr_api.g_varchar2)  or
    nvl(ben_cso_shd.g_old_rec.cso_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.cso_attribute30, hr_api.g_varchar2) ))
    or (p_rec.cwb_stock_optn_dtls_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'BEN'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'CSO_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'CSO_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.cso_attribute1
      ,p_attribute2_name                 => 'CSO_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.cso_attribute2
      ,p_attribute3_name                 => 'CSO_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.cso_attribute3
      ,p_attribute4_name                 => 'CSO_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.cso_attribute4
      ,p_attribute5_name                 => 'CSO_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.cso_attribute5
      ,p_attribute6_name                 => 'CSO_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.cso_attribute6
      ,p_attribute7_name                 => 'CSO_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.cso_attribute7
      ,p_attribute8_name                 => 'CSO_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.cso_attribute8
      ,p_attribute9_name                 => 'CSO_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.cso_attribute9
      ,p_attribute10_name                => 'CSO_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.cso_attribute10
      ,p_attribute11_name                => 'CSO_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.cso_attribute11
      ,p_attribute12_name                => 'CSO_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.cso_attribute12
      ,p_attribute13_name                => 'CSO_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.cso_attribute13
      ,p_attribute14_name                => 'CSO_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.cso_attribute14
      ,p_attribute15_name                => 'CSO_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.cso_attribute15
      ,p_attribute16_name                => 'CSO_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.cso_attribute16
      ,p_attribute17_name                => 'CSO_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.cso_attribute17
      ,p_attribute18_name                => 'CSO_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.cso_attribute18
      ,p_attribute19_name                => 'CSO_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.cso_attribute19
      ,p_attribute20_name                => 'CSO_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.cso_attribute20
      ,p_attribute21_name                => 'CSO_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.cso_attribute21
      ,p_attribute22_name                => 'CSO_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.cso_attribute22
      ,p_attribute23_name                => 'CSO_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.cso_attribute23
      ,p_attribute24_name                => 'CSO_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.cso_attribute24
      ,p_attribute25_name                => 'CSO_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.cso_attribute25
      ,p_attribute26_name                => 'CSO_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.cso_attribute26
      ,p_attribute27_name                => 'CSO_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.cso_attribute27
      ,p_attribute28_name                => 'CSO_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.cso_attribute28
      ,p_attribute29_name                => 'CSO_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.cso_attribute29
      ,p_attribute30_name                => 'CSO_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.cso_attribute30
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
  ,p_rec in ben_cso_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ben_cso_shd.api_updating
      (p_cwb_stock_optn_dtls_id            => p_rec.cwb_stock_optn_dtls_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ben_cso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  ben_cso_bus.chk_valid_entry(p_rec.employee_number
  			     ,p_rec.person_id
  			     ,p_rec.business_group_id
  			     ,p_effective_date
  			     );

  if(p_rec.business_group_id is not null)
  then
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_cso_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  end if;
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --  Commented call to chk_df
  --  ben_cso_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ben_cso_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  ben_cso_bus.chk_valid_entry(p_rec.employee_number
    			     ,p_rec.person_id
    			     ,p_rec.business_group_id
    			     ,p_effective_date
  			     );

  if(p_rec.business_group_id is not null)
  then
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ben_cso_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  end if;
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
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --  Commented call to chk_df
  --  ben_cso_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ben_cso_shd.g_rec_type
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
end ben_cso_bus;

/
