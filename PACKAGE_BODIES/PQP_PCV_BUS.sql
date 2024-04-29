--------------------------------------------------------
--  DDL for Package Body PQP_PCV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PCV_BUS" as
/* $Header: pqpcvrhi.pkb 120.0 2005/05/29 01:55:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pcv_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_configuration_value_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_configuration_value_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pqp_configuration_values pcv
     where pcv.configuration_value_id = p_configuration_value_id
       and pbg.business_group_id = pcv.business_group_id;
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
    ,p_argument           => 'configuration_value_id'
    ,p_argument_value     => p_configuration_value_id
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
        => nvl(p_associated_column1,'CONFIGURATION_VALUE_ID')
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
  (p_configuration_value_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pqp_configuration_values pcv
     where pcv.configuration_value_id = p_configuration_value_id
       and pbg.business_group_id (+) = pcv.business_group_id;
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
    ,p_argument           => 'configuration_value_id'
    ,p_argument_value     => p_configuration_value_id
    );
  --
  if ( nvl(pqp_pcv_bus.g_configuration_value_id, hr_api.g_number)
       = p_configuration_value_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_pcv_bus.g_legislation_code;
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
    pqp_pcv_bus.g_configuration_value_id      := p_configuration_value_id;
    pqp_pcv_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.configuration_value_id is not null)  and (
    nvl(pqp_pcv_shd.g_old_rec.pcv_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information_category, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information1, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information2, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information3, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information4, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information5, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information6, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information7, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information8, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information9, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information10, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information11, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information12, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information13, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information14, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information15, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information16, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information17, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information18, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information19, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_information20, hr_api.g_varchar2) ))
    or (p_rec.configuration_value_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'PCV_INFORMATION_CATEGORY'
      ,p_attribute1_name                 => 'PCV_INFORMATION1'
      ,p_attribute1_value                => p_rec.pcv_information1
      ,p_attribute2_name                 => 'PCV_INFORMATION2'
      ,p_attribute2_value                => p_rec.pcv_information2
      ,p_attribute3_name                 => 'PCV_INFORMATION3'
      ,p_attribute3_value                => p_rec.pcv_information3
      ,p_attribute4_name                 => 'PCV_INFORMATION4'
      ,p_attribute4_value                => p_rec.pcv_information4
      ,p_attribute5_name                 => 'PCV_INFORMATION5'
      ,p_attribute5_value                => p_rec.pcv_information5
      ,p_attribute6_name                 => 'PCV_INFORMATION6'
      ,p_attribute6_value                => p_rec.pcv_information6
      ,p_attribute7_name                 => 'PCV_INFORMATION7'
      ,p_attribute7_value                => p_rec.pcv_information7
      ,p_attribute8_name                 => 'PCV_INFORMATION8'
      ,p_attribute8_value                => p_rec.pcv_information8
      ,p_attribute9_name                 => 'PCV_INFORMATION9'
      ,p_attribute9_value                => p_rec.pcv_information9
      ,p_attribute10_name                => 'PCV_INFORMATION10'
      ,p_attribute10_value               => p_rec.pcv_information10
      ,p_attribute11_name                => 'PCV_INFORMATION11'
      ,p_attribute11_value               => p_rec.pcv_information11
      ,p_attribute12_name                => 'PCV_INFORMATION12'
      ,p_attribute12_value               => p_rec.pcv_information12
      ,p_attribute13_name                => 'PCV_INFORMATION13'
      ,p_attribute13_value               => p_rec.pcv_information13
      ,p_attribute14_name                => 'PCV_INFORMATION14'
      ,p_attribute14_value               => p_rec.pcv_information14
      ,p_attribute15_name                => 'PCV_INFORMATION15'
      ,p_attribute15_value               => p_rec.pcv_information15
      ,p_attribute16_name                => 'PCV_INFORMATION16'
      ,p_attribute16_value               => p_rec.pcv_information16
      ,p_attribute17_name                => 'PCV_INFORMATION17'
      ,p_attribute17_value               => p_rec.pcv_information17
      ,p_attribute18_name                => 'PCV_INFORMATION18'
      ,p_attribute18_value               => p_rec.pcv_information18
      ,p_attribute19_name                => 'PCV_INFORMATION19'
      ,p_attribute19_value               => p_rec.pcv_information19
      ,p_attribute20_name                => 'PCV_INFORMATION20'
      ,p_attribute20_value               => p_rec.pcv_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  (p_rec in pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.configuration_value_id is not null)  and (
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute_category, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute1, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute2, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute3, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute4, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute5, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute6, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute7, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute8, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute9, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute10, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute11, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute12, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute13, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute14, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute15, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute16, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute17, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute18, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute19, hr_api.g_varchar2)  or
    nvl(pqp_pcv_shd.g_old_rec.pcv_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.pcv_attribute20, hr_api.g_varchar2) ))
    or (p_rec.configuration_value_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'PCV_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'PCV_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.pcv_attribute1
      ,p_attribute2_name                 => 'PCV_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.pcv_attribute2
      ,p_attribute3_name                 => 'PCV_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.pcv_attribute3
      ,p_attribute4_name                 => 'PCV_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.pcv_attribute4
      ,p_attribute5_name                 => 'PCV_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.pcv_attribute5
      ,p_attribute6_name                 => 'PCV_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.pcv_attribute6
      ,p_attribute7_name                 => 'PCV_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.pcv_attribute7
      ,p_attribute8_name                 => 'PCV_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.pcv_attribute8
      ,p_attribute9_name                 => 'PCV_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.pcv_attribute9
      ,p_attribute10_name                => 'PCV_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.pcv_attribute10
      ,p_attribute11_name                => 'PCV_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.pcv_attribute11
      ,p_attribute12_name                => 'PCV_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.pcv_attribute12
      ,p_attribute13_name                => 'PCV_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.pcv_attribute13
      ,p_attribute14_name                => 'PCV_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.pcv_attribute14
      ,p_attribute15_name                => 'PCV_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.pcv_attribute15
      ,p_attribute16_name                => 'PCV_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.pcv_attribute16
      ,p_attribute17_name                => 'PCV_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.pcv_attribute17
      ,p_attribute18_name                => 'PCV_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.pcv_attribute18
      ,p_attribute19_name                => 'PCV_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.pcv_attribute19
      ,p_attribute20_name                => 'PCV_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.pcv_attribute20
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
  ,p_rec in pqp_pcv_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqp_pcv_shd.api_updating
      (p_configuration_value_id            => p_rec.configuration_value_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
End chk_non_updateable_args;
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
  -- EDIT_HERE: The following call should be edited if certain types of rows
  -- are not permitted.
  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;

-----------------------------------------------------------------------------
-----------------------Get the legistionId for BusinessGroupId---------------
-----------------------------------------------------------------------------
FUNCTION get_legislation_code
                 (p_business_group_id IN NUMBER
		 ) RETURN VARCHAR2 IS
   --declare local variables
   l_legislation_code  per_business_groups.legislation_code%TYPE;

   CURSOR c_get_leg_code IS
   SELECT legislation_code
    FROM  per_business_groups_perf
    WHERE business_group_id =p_business_group_id;

 BEGIN
   OPEN c_get_leg_code;
   LOOP
      FETCH c_get_leg_code INTO l_legislation_code;
      EXIT WHEN c_get_leg_code%NOTFOUND;
   END LOOP;
   CLOSE c_get_leg_code;
   RETURN (l_legislation_code);
 EXCEPTION
 ---------
 WHEN OTHERS THEN
 RETURN(NULL);
 END;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_mandatory_fields >------------------------|
-- ----------------------------------------------------------------------------
--Checking each segment value sequencialy based on total_unique_columns count in
-- pqp_configuration_types table
PROCEDURE chk_mandatory_fields
  (p_rec  IN pqp_pcv_shd.g_rec_type
  ,p_flag IN VARCHAR2
  ) IS

--Declare the cursor to get the registration number count
 CURSOR   config_unique_col_cursor IS
   Select total_unique_columns
   from   pqp_configuration_types
   where  configuration_type =p_rec.pcv_information_category;

   --Declare local variable
   l_count                number;
   l_column_count         number;
   l_where_clause         VARCHAR2(10000);
   l_temp_str             VARCHAR2(10000);
   TYPE ref_csr_typ  IS   REF CURSOR;
   c_column_cursor        ref_csr_typ;
   l_legislation_code  varchar2(150);

BEGIN
   hr_utility.set_location('Entering: chk_mandatory_fields', 5);
   OPEN  config_unique_col_cursor;
   FETCH config_unique_col_cursor INTO  l_count;
   CLOSE config_unique_col_cursor;
   hr_utility.set_location('l_count :'||l_count, 5);
   IF l_count = 1 THEN
       l_where_clause := ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||'';
   ELSIF l_count = 2 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||'';
   ELSIF l_count = 3 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||'';
   ELSIF l_count = 4 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||'';
   ELSIF l_count = 5 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||'';
   ELSIF l_count = 6 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||'';
   ELSIF l_count = 7 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||''||
                          ' AND pcv_information7 = '||''''||nvl(p_rec.pcv_information7,'?') ||''''||'';
   ELSIF l_count = 8 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||''||
                          ' AND pcv_information7 = '||''''||nvl(p_rec.pcv_information7,'?') ||''''||''||
                          ' AND pcv_information8 = '||''''||nvl(p_rec.pcv_information8,'?') ||''''||'';

   ELSIF l_count = 9 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||''||
                          ' AND pcv_information7 = '||''''||nvl(p_rec.pcv_information7,'?') ||''''||''||
                          ' AND pcv_information8 = '||''''||nvl(p_rec.pcv_information8,'?') ||''''||''||
                          ' AND pcv_information9 = '||''''||nvl(p_rec.pcv_information9,'?') ||''''||'';
   ELSIF l_count = 10 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||''||
                          ' AND pcv_information7 = '||''''||nvl(p_rec.pcv_information7,'?') ||''''||''||
                          ' AND pcv_information8 = '||''''||nvl(p_rec.pcv_information8,'?') ||''''||''||
                          ' AND pcv_information9 = '||''''||nvl(p_rec.pcv_information9,'?') ||''''||''||
                          ' AND pcv_information10 = '||''''||nvl(p_rec.pcv_information10,'?') ||''''||'';
    ELSIF l_count = 11 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||''||
                          ' AND pcv_information7 = '||''''||nvl(p_rec.pcv_information7,'?') ||''''||''||
                          ' AND pcv_information8 = '||''''||nvl(p_rec.pcv_information8,'?') ||''''||''||
                          ' AND pcv_information9 = '||''''||nvl(p_rec.pcv_information9,'?') ||''''||''||
                          ' AND pcv_information10 = '||''''||nvl(p_rec.pcv_information10,'?') ||''''||''||
                          ' AND pcv_information11 = '||''''||nvl(p_rec.pcv_information11,'?') ||''''||'';
     ELSIF l_count = 12 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||''||
                          ' AND pcv_information7 = '||''''||nvl(p_rec.pcv_information7,'?') ||''''||''||
                          ' AND pcv_information8 = '||''''||nvl(p_rec.pcv_information8,'?') ||''''||''||
                          ' AND pcv_information9 = '||''''||nvl(p_rec.pcv_information9,'?') ||''''||''||
                          ' AND pcv_information10 = '||''''||nvl(p_rec.pcv_information10,'?') ||''''||''||
                          ' AND pcv_information11 = '||''''||nvl(p_rec.pcv_information11,'?') ||''''||''||
                          ' AND pcv_information12 = '||''''||nvl(p_rec.pcv_information12,'?') ||''''||'';
     ELSIF l_count = 13 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||''||
                          ' AND pcv_information7 = '||''''||nvl(p_rec.pcv_information7,'?') ||''''||''||
                          ' AND pcv_information8 = '||''''||nvl(p_rec.pcv_information8,'?') ||''''||''||
                          ' AND pcv_information9 = '||''''||nvl(p_rec.pcv_information9,'?') ||''''||''||
                          ' AND pcv_information10 = '||''''||nvl(p_rec.pcv_information10,'?')||''''||''||
                          ' AND pcv_information11 = '||''''||nvl(p_rec.pcv_information11,'?') ||''''||''||
                          ' AND pcv_information12 = '||''''||nvl(p_rec.pcv_information12,'?') ||''''||''||
                          ' AND pcv_information13 = '||''''||nvl(p_rec.pcv_information13,'?') ||''''||'';
     ELSIF l_count = 14 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||''||
                          ' AND pcv_information7 = '||''''||nvl(p_rec.pcv_information7,'?') ||''''||''||
                          ' AND pcv_information8 = '||''''||nvl(p_rec.pcv_information8,'?') ||''''||''||
                          ' AND pcv_information9 = '||''''||nvl(p_rec.pcv_information9,'?') ||''''||''||
                          ' AND pcv_information10 = '||''''||nvl(p_rec.pcv_information10,'?') ||''''||''||
                          ' AND pcv_information11 = '||''''||nvl(p_rec.pcv_information11,'?') ||''''||''||
                          ' AND pcv_information12 = '||''''||nvl(p_rec.pcv_information12,'?') ||''''||''||
                          ' AND pcv_information13 = '||''''||nvl(p_rec.pcv_information13,'?') ||''''||''||
                          ' AND pcv_information14 = '||''''||nvl(p_rec.pcv_information14,'?') ||''''||'';
     ELSIF l_count = 15 THEN
       l_where_clause :=  ' AND pcv_information1 = '||''''||nvl(p_rec.pcv_information1,'?') ||''''||''||
                          ' AND pcv_information2 = '||''''||nvl(p_rec.pcv_information2,'?') ||''''||''||
                          ' AND pcv_information3 = '||''''||nvl(p_rec.pcv_information3,'?') ||''''||''||
                          ' AND pcv_information4 = '||''''||nvl(p_rec.pcv_information4,'?') ||''''||''||
                          ' AND pcv_information5 = '||''''||nvl(p_rec.pcv_information5,'?') ||''''||''||
                          ' AND pcv_information6 = '||''''||nvl(p_rec.pcv_information6,'?') ||''''||''||
                          ' AND pcv_information7 = '||''''||nvl(p_rec.pcv_information7,'?') ||''''||''||
                          ' AND pcv_information8 = '||''''||nvl(p_rec.pcv_information8,'?') ||''''||''||
                          ' AND pcv_information9 = '||''''||nvl(p_rec.pcv_information9,'?') ||''''||''||
                          ' AND pcv_information10 = '||''''||nvl(p_rec.pcv_information10,'?') ||''''||''||
                          ' AND pcv_information11 = '||''''||nvl(p_rec.pcv_information11,'?') ||''''||''||
                          ' AND pcv_information12 = '||''''||nvl(p_rec.pcv_information12,'?') ||''''||''||
                          ' AND pcv_information13 = '||''''||nvl(p_rec.pcv_information13,'?') ||''''||''||
                          ' AND pcv_information14 = '||''''||nvl(p_rec.pcv_information14,'?') ||''''||''||
                          ' AND pcv_information15 = '||''''||nvl(p_rec.pcv_information15,'?') ||''''||'';

   END IF;
  --Getting the legislationId for business groupId
  -- Get legislation code

  IF l_where_clause is not null then
      hr_utility.set_location('Inside If', 5);
      l_temp_str := 'SELECT count(CONFIGURATION_VALUE_ID)
                      FROM  pqp_configuration_values
                      WHERE NVL(business_group_id,'||''''||hr_api.g_number||''''||') =
                            NVL('||''''||p_rec.business_group_id||''''||','||''''||hr_api.g_number||''''||')
                        AND NVL(legislation_code, '||''''||hr_api.g_varchar2||''''||')=
                            NVL('||''''||p_rec.legislation_code||''''||','||''''||hr_api.g_varchar2||''''||')
                        AND configuration_value_id <> NVL( '||''''||p_rec.configuration_value_id||''''||
                             ','||''''||hr_api.g_number||''''||')
                        AND   PCV_INFORMATION_CATEGORY =
                             '|| ''''||p_rec.pcv_information_category ||''''||'
                             '||l_where_clause ||'';

     OPEN c_column_cursor FOR l_temp_str;
     FETCH c_column_cursor INTO l_column_count;
     CLOSE c_column_cursor;
     hr_utility.set_location('l_column_count :'||l_column_count, 5);
  END IF;
   hr_utility.set_location('Leaving: chk_mandatory_fields', 5);
   IF l_column_count>0 THEN
--     IF p_flag = 'U' THEN
--         fnd_message.set_name('PQP','PQP_230751_NO_CHGS_TO_SAVE');
--         fnd_message.raise_error;
--      ELSE
        fnd_message.set_name('PQP','PQP_230184_CONFIG_ROW_EXISTS');
        fnd_message.raise_error;
--      END IF;
   END IF;

EXCEPTION
--------
WHEN no_data_found THEN
NULL;
End;

-- Bug 4150124
-- New procedure to check rows based on configuration type occurrence type
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_mult_occurrence >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_mult_occurrence
  (p_rec                          in pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_mult_occurrence';

  -- Cursor to retrieve the occurrence type
  -- for this configuration type
  CURSOR csr_get_occurrence_type
    (c_config_type      VARCHAR2
    ,c_legislation_code VARCHAR2
    )
  IS
  SELECT multiple_occurences_flag
        ,description
        ,total_unique_columns
    FROM pqp_configuration_types
   WHERE configuration_type = c_config_type
     AND (
          (legislation_code IS NOT NULL AND
           legislation_code = c_legislation_code
          )
          OR
          legislation_code IS NULL
         );

  -- Cursor to check multiple rows in configuration values table

  CURSOR csr_chk_config_val
    (c_config_val_id     NUMBER
    ,c_config_type       VARCHAR2
    ,c_business_group_id NUMBER
    ,c_legislation_code  VARCHAR2
    )
  IS
  SELECT 1
    FROM pqp_configuration_values
   WHERE pcv_information_category = c_config_type
     AND configuration_value_id <> NVL(c_config_val_id, hr_api.g_number)
     AND NVL(business_group_id, hr_api.g_number) = NVL(c_business_group_id, hr_api.g_number)
     AND NVL(legislation_code, hr_api.g_varchar2) = NVL(c_legislation_code, hr_api.g_varchar2);

  l_legislation_code  per_business_groups.legislation_code%TYPE;
  l_mult_occurrence   pqp_configuration_types.multiple_occurences_flag%TYPE;
  l_exists            NUMBER;
  l_config_desc       pqp_configuration_types.description%TYPE;
  l_total_uniq_cols   NUMBER;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Get legislation code
  IF p_rec.business_group_id IS NULL THEN
     l_legislation_code := p_rec.legislation_code;
  ELSE
     l_legislation_code := get_legislation_code(p_rec.business_group_id);
  END IF; -- End if of business_group_id is null check...

  hr_utility.set_location(l_proc, 10);

  l_mult_occurrence := NULL;

  OPEN csr_get_occurrence_type
    (p_rec.pcv_information_category
    ,l_legislation_code
    );
  FETCH csr_get_occurrence_type INTO l_mult_occurrence
                                    ,l_config_desc
                                    ,l_total_uniq_cols;
  CLOSE csr_get_occurrence_type;

  -- Check whether multiple occurrence allowed

  hr_utility.set_location(l_proc, 20);

  IF l_mult_occurrence = 'N' THEN

     hr_utility.set_location(l_proc, 30);

     -- Check for row existence in pqp_configuration_values
     OPEN csr_chk_config_val
       (p_rec.configuration_value_id
       ,p_rec.pcv_information_category
       ,p_rec.business_group_id
       ,p_rec.legislation_code
       );
     FETCH csr_chk_config_val INTO l_exists;

     IF csr_chk_config_val%FOUND THEN

        -- Raise an error
        CLOSE csr_chk_config_val;
        fnd_message.set_name('PQP','PQP_230173_PCV_MULT_NOT_ALLOW');
        fnd_message.set_token('CONFIGURATION_TYPE', l_config_desc);
        fnd_message.raise_error;

     END IF; -- End if of config val not found check ...
     CLOSE csr_chk_config_val;

   ELSE -- multiple occurrence exist

     -- Added check for total_unique_columns
     hr_utility.set_location(l_proc, 40);

     IF l_total_uniq_cols IS NULL THEN

        -- Raise an error
        fnd_message.set_name('PQP','PQP_230220_PCV_UNIQ_COLS_REQ');
        fnd_message.raise_error;

     END IF; -- End if of total unique columns is null check ...

   END IF; -- End if of multiple occurrence flag check ...

   hr_utility.set_location('Leaving '||l_proc, 50);
   --
End chk_mult_occurrence;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- commented by skutteti as LD wanted to seed data with null bg and leg
  -- chk_startup_action(true
  --                  ,p_rec.business_group_id
  --                  ,p_rec.legislation_code
  --                  );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     -- commented by skutteti as LD wanted to seed data with null bg and leg
     --hr_api.validate_bus_grp_id
     --  (p_business_group_id => p_rec.business_group_id
     --  ,p_associated_column1 => pqp_pcv_shd.g_tab_nam
     --                           || '.BUSINESS_GROUP_ID');
     --
     -- Checking mandatory segment values
     --
     chk_mandatory_fields( p_rec  => p_rec
                           ,p_flag =>'I');

     -- Checking multiple occurrences
     -- Bug 4150124

     hr_utility.set_location(l_proc, 10);

     chk_mult_occurrence (p_rec => p_rec);

     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  --
  --pqp_pcv_bus.chk_ddf(p_rec);
  --
  --pqp_pcv_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --chk_startup_action(false
  --                  ,p_rec.business_group_id
  --                  ,p_rec.legislation_code
  --                  );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     -- hr_api.validate_bus_grp_id
     --  (p_business_group_id => p_rec.business_group_id
     --  ,p_associated_column1 => pqp_pcv_shd.g_tab_nam
     --                           || '.BUSINESS_GROUP_ID');

     --
     -- Checking mandatory segment values
     --
     chk_mandatory_fields( p_rec  => p_rec
                           ,p_flag =>'U');

     -- Checking multiple occurrences
     -- Bug 4150124

     hr_utility.set_location(l_proc, 10);

     chk_mult_occurrence (p_rec => p_rec);

     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  --pqp_pcv_bus.chk_ddf(p_rec);
  --
  --pqp_pcv_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,pqp_pcv_shd.g_old_rec.business_group_id
                    ,pqp_pcv_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
end pqp_pcv_bus;

/
