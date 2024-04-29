--------------------------------------------------------
--  DDL for Package Body HR_TMP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TMP_BUS" as
/* $Header: hrtmprhi.pkb 115.6 2002/12/03 11:31:46 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_tmp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_form_template_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_form_template_id                     in number
  ) is
  --
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- No business group context. Security group is not applicable.
  --
  null;
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
  (p_form_template_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select tmp.legislation_code
      from hr_form_templates_b tmp
     where tmp.form_template_id = p_form_template_id;
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
    ,p_argument           => 'form_template_id'
    ,p_argument_value     => p_form_template_id
    );
  --
  if ( nvl(hr_tmp_bus.g_form_template_id, hr_api.g_number)
       = p_form_template_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_tmp_bus.g_legislation_code;
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
    hr_tmp_bus.g_form_template_id  := p_form_template_id;
    hr_tmp_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hr_tmp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.form_template_id is not null)  and (
    nvl(hr_tmp_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(hr_tmp_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) )
    or (p_rec.form_template_id is null) ) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'HR_FORM_TEMPLATES'
      ,p_attribute_category              => p_rec.attribute_category
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
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
  ,p_rec in hr_tmp_shd.g_rec_type
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
  IF NOT hr_tmp_shd.api_updating
      (p_form_template_id                     => p_rec.form_template_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.application_id,hr_api.g_number) <>
      nvl(hr_tmp_shd.g_old_rec.application_id,hr_api.g_number)
     ) THEN
     l_argument := 'application_id';
     RAISE l_error;
  END IF;
  --
  IF (nvl(p_rec.form_id,hr_api.g_number) <>
      nvl(hr_tmp_shd.g_old_rec.form_id,hr_api.g_number)
     ) THEN
     l_argument := 'form_id';
     RAISE l_error;
  END IF;
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
-- |--------------------------< chk_application_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_application_id
  (p_effective_date               in date
  ,p_form_template_id             in number
  ,p_object_version_number        in number
  ,p_application_id               in number
  ) is
  --
  l_check number;
  CURSOR cur_chk_app_id
  IS
  SELECT 1
  FROM fnd_application
  WHERE application_id = p_application_id;

  l_proc                         varchar2(72) := g_package || 'chk_application_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'application_id'
    ,p_argument_value               => p_application_id
    );
  --
  --
  OPEN cur_chk_app_id;
  FETCH cur_chk_app_id INTO l_check;
  IF cur_chk_app_id%NOTFOUND THEN
    CLOSE cur_chk_app_id;
    fnd_message.set_name('PER', 'HR_NEW_MESSAGE');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;
  CLOSE cur_chk_app_id;

  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_application_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_form_id >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_form_id
  (p_effective_date               in date
  ,p_form_template_id             in number
  ,p_object_version_number        in number
  ,p_form_id                      in number
  ,p_application_id               in number
  ) is
  l_check number;
  CURSOR cur_chk_form_id
  IS
  SELECT 1
  FROM fnd_form
  WHERE form_id = p_form_id
  AND application_id = p_application_id;
  --
  l_proc                         varchar2(72) := g_package || 'chk_form_id';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'form_id'
    ,p_argument_value               => p_form_id
    );
  --
  OPEN cur_chk_form_id;
  FETCH cur_chk_form_id INTO l_check;
  IF cur_chk_form_id%NOTFOUND THEN
    CLOSE cur_chk_form_id;
    fnd_message.set_name('PER', 'HR_NEW_MESSAGE');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;
  CLOSE cur_chk_form_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_form_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_legislation_code
  (p_effective_date               in date
  ,p_form_template_id             in number
  ,p_object_version_number        in number
  ,p_legislation_code             in varchar2
  ) is
  --
  l_check number;
  CURSOR cur_chk_leg_code
  IS
  SELECT 1
  FROM fnd_territories
  WHERE territory_code = p_legislation_code;
  --
  l_proc                         varchar2(72) := g_package || 'chk_legislation_code';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- additional validation
  --
  IF (p_legislation_code IS NOT NULL)
  THEN
    --
    OPEN cur_chk_leg_code;
    FETCH cur_chk_leg_code INTO l_check;
    IF cur_chk_leg_code%NOTFOUND THEN
      CLOSE cur_chk_leg_code;
      fnd_message.set_name('PER', 'HR_NEW_MESSAGE');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    END IF;
    CLOSE cur_chk_leg_code ;
  --
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_template_name >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_name
  (p_effective_date               in date
  ,p_form_template_id             in number
  ,p_object_version_number        in number
  ,p_template_name                in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_template_name';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'template_name'
    ,p_argument_value               => p_template_name
    );
  --
  -- Check value is in uppercase
  --
  if p_template_name <> upper(p_template_name) then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_template_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_enabled_flag >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_enabled_flag
  (p_effective_date               in date
  ,p_form_template_id             in number
  ,p_object_version_number        in number
  ,p_enabled_flag                 in varchar2
  ) is
  --
  l_proc                         varchar2(72) := g_package || 'chk_enabled_flag';
  l_api_updating                 boolean;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  l_api_updating := hr_tmp_shd.api_updating
    (p_form_template_id             => p_form_template_id
    ,p_object_version_number        => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (  (   l_api_updating
        and nvl(hr_tmp_shd.g_old_rec.enabled_flag,hr_api.g_varchar2) <>
            nvl(p_enabled_flag,hr_api.g_varchar2))
     or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Check value has been passed
    --
    hr_api.mandatory_arg_error
      (p_api_name                     => l_proc
      ,p_argument                     => 'enabled_flag'
      ,p_argument_value               => p_enabled_flag
      );
    --
    -- Must exist in hr_standard_lookups where lookup_type is YES_NO
    --
    if hr_api.not_exists_in_hrstanlookups
      (p_effective_date               => p_effective_date
      ,p_lookup_type                  => 'YES_NO'
      ,p_lookup_code                  => p_enabled_flag
      ) then
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
End chk_enabled_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_rec                          in hr_tmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- No additional validation required
  --
  null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hr_tmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  -- Call all supporting business operations
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  chk_application_id
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_form_id
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_id                      => p_rec.form_id
    ,p_application_id               => p_rec.application_id
    );
  --
  chk_legislation_code
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_legislation_code             => p_rec.legislation_code
    );
  --
  chk_template_name
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_template_name                => p_rec.template_name
    );
  --
  chk_enabled_flag
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_enabled_flag                 => p_rec.enabled_flag
    );
  --
  chk_df
    (p_rec                          => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hr_tmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  -- Call all supporting business operations
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
    ,p_rec                         => p_rec
    );

  chk_application_id
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_application_id               => p_rec.application_id
    );

  chk_form_id
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_form_id                      => p_rec.form_id
    ,p_application_id               => p_rec.application_id
    );

  chk_legislation_code
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_legislation_code             => p_rec.legislation_code
    );
  --
  chk_template_name
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_template_name                => p_rec.template_name
    );
  --
  chk_enabled_flag
    (p_effective_date               => p_effective_date
    ,p_form_template_id             => p_rec.form_template_id
    ,p_object_version_number        => p_rec.object_version_number
    ,p_enabled_flag                 => p_rec.enabled_flag
    );
  --
  chk_df
    (p_rec                          => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_tmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete
    (p_rec                          => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_tmp_bus;

/
