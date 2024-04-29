--------------------------------------------------------
--  DDL for Package Body OTA_LPC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LPC_BUS" as
/* $Header: otlpcrhi.pkb 120.0 2005/05/29 07:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_dummy    number(1);
g_package  varchar2(33) := '  ota_lpc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_learning_path_section_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_learning_path_section_id             in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_lp_sections lpc
     where lpc.learning_path_section_id = p_learning_path_section_id
       and pbg.business_group_id = lpc.business_group_id;
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
    ,p_argument           => 'learning_path_section_id'
    ,p_argument_value     => p_learning_path_section_id
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
        => nvl(p_associated_column1,'LEARNING_PATH_SECTION_ID')
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
  (p_learning_path_section_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , ota_lp_sections lpc
     where lpc.learning_path_section_id = p_learning_path_section_id
       and pbg.business_group_id = lpc.business_group_id;
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
    ,p_argument           => 'learning_path_section_id'
    ,p_argument_value     => p_learning_path_section_id
    );
  --
  if ( nvl(ota_lpc_bus.g_learning_path_section_id, hr_api.g_number)
       = p_learning_path_section_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_lpc_bus.g_legislation_code;
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
    ota_lpc_bus.g_learning_path_section_id    := p_learning_path_section_id;
    ota_lpc_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ota_lpc_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.learning_path_section_id is not null)  and (
    nvl(ota_lpc_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(ota_lpc_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.learning_path_section_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_LP_SECTIONS'
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
  ,p_rec in ota_lpc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ota_lpc_shd.api_updating
      (p_learning_path_section_id          => p_rec.learning_path_section_id
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
--
-- ----------------------------------------------------------------------------
-- |--------------------------< call_error_message >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Passes the error information to the procedure set_message of package
--   hr_utility.
--
Procedure call_error_message
  (
   p_error_appl             varchar2
  ,p_error_txt              varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'call_error_message';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- ** TEMP ** Add error message with the following text.
  --
  fnd_message.set_name      ( p_error_appl     ,p_error_txt);
  fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End call_error_message;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_completion_type_valid >-------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check the completion type code for the section being added/updated
--   This section may not have the completion type of All Optional if this
--   is the first section being added to the learning path.
--
PROCEDURE chk_completion_type_valid
  (p_learning_path_section_id  in  number,
   p_learning_path_id          in  number
  ) is
  --
  v_exists                BOOLEAN := FALSE;
  l_lp_id                 ota_lp_sections.learning_path_id%TYPE;
  v_proc                  varchar2(72) := g_package||'chk_completion_type_valid';
  --
  CURSOR get_lp_id IS
  SELECT learning_path_id
    FROM ota_lp_sections
   WHERE learning_path_section_id = p_learning_path_section_id;

  cursor sel_lps_exists is
    select 1
      from ota_lp_sections lps
     where lps.learning_path_id = l_lp_id
       and lps.completion_type_code IN ('M', 'S')
       AND (p_learning_path_section_id IS NULL
            OR ( p_learning_path_section_id IS NOT NULL
                 AND p_learning_path_section_id <> lps.learning_path_section_id)) ;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  IF p_learning_path_id IS NULL THEN
      OPEN get_lp_id;
     FETCH get_lp_id INTO l_lp_id;
     CLOSE get_lp_id;
 ELSE
     l_lp_id := p_learning_path_id;
 END IF;

  Open  sel_lps_exists;
  fetch sel_lps_exists into g_dummy;
  --
  v_exists := sel_lps_exists%FOUND;
  --
  close sel_lps_exists;
  --
   IF NOT v_exists THEN

       call_error_message( p_error_appl    =>   'OTA'
                         , p_error_txt     =>  'OTA_13075_LPC_CMP_TYPE_ERR');


   END IF;

  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
EXCEPTION
WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LP_SECTIONS.COMPLETION_TYPE_CODE') THEN

              hr_utility.set_location(' Leaving:'||v_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||v_proc, 94);

End chk_completion_type_valid;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_if_lme_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   update validation.
--   This section completion type flag cannot be updated if enrollments
--   exist for this learning path.
--
Procedure chk_if_lme_exists
  (
   p_learning_path_section_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'chk_if_lme_exists';
  --
  cursor sel_lme_exists is
    select 'Y'
      from ota_lp_member_enrollments lme
     where lme.learning_path_section_id = p_learning_path_section_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_lme_exists;
  fetch sel_lme_exists into v_exists;
  --
  if sel_lme_exists%found then
    --
    close sel_lme_exists;
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt            =>  'OTA_13074_LPC_DEL_LPM_EXISTS'
                      );
    --
  else
    close sel_lme_exists;

  end if;
  --
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End chk_if_lme_exists;
--
-- ----------------------------------------------------------------------------
-- |---------------------< is_last_section >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
--
Function is_last_section
   (p_learning_path_section_id          in  ota_lp_sections.learning_path_section_id%TYPE)
    RETURN BOOLEAN is
  --
  l_lp_id                 ota_learning_paths.learning_path_id%TYPE;
  l_count_sections        NUMBER;
  l_return                boolean := FALSE;
  v_proc                  varchar2(72) := g_package||'is_last_section';
  --
  CURSOR get_lp_id IS
  SELECT learning_path_id
    FROM ota_lp_sections
   WHERE learning_path_section_id = p_learning_path_section_id;

  CURSOR csr_is_last_section IS
  SELECT count(learning_path_section_id)
    FROM ota_lp_sections
   WHERE learning_path_id = l_lp_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
   Open get_lp_id;
  Fetch get_lp_id INTO l_lp_id;
  Close get_lp_id;

   Open csr_is_last_section;
  fetch csr_is_last_section into l_count_sections;
  close csr_is_last_section;
    --
  IF l_count_sections = 1 THEN
     l_return := TRUE;
 ELSE
     l_return := FALSE;

 END IF;

  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  RETURN l_return;

End is_last_section;
--
-- ----------------------------------------------------------------------------
-- |---------------------< is_catalog_lp >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
--
Function is_catalog_lp
   (p_learning_path_id          in  number)
    RETURN BOOLEAN is
  --
  v_path_source_code      ota_learning_paths.path_source_code%TYPE;
  l_return                boolean := FALSE;
  v_proc                  varchar2(72) := g_package||'is_catalog_lp';
  --
  cursor csr_is_catalog_lp is
    select path_source_code
      from ota_learning_paths lps
     where lps.learning_path_id = p_learning_path_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
   Open csr_is_catalog_lp;
  fetch csr_is_catalog_lp into v_path_source_code;
  close csr_is_catalog_lp;
    --
   IF v_path_source_code = 'CATALOG' THEN
      l_return := TRUE;
  END IF;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  RETURN l_return;

End is_catalog_lp;
--
-- ----------------------------------------------------------------------------
-- |---------------------< disable_section_dff >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Disable DFF validation for non-catalog learning paths
--
Procedure disable_section_dff
   (p_learning_path_section_id  in  number,
    p_learning_path_id          in  number
   ) is
  --
  v_path_source_code      ota_learning_paths.path_source_code%TYPE;
  v_proc                  varchar2(72) := g_package||'disable_section_dff';
  l_add_struct_d          hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();
  --
  cursor csr_is_catalog_lp is
    select path_source_code
      from ota_learning_paths lps
     where lps.learning_path_id = p_learning_path_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
   Open csr_is_catalog_lp;
  fetch csr_is_catalog_lp into v_path_source_code;
  close csr_is_catalog_lp;
    --
    IF v_path_source_code <> 'CATALOG' THEN
	 -- Ignore dff validation for non-catalog learning paths

        l_add_struct_d.extend(1);
        l_add_struct_d(l_add_struct_d.count) := 'OTA_LP_SECTIONS';

        hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);

    END IF;

  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End disable_section_dff;
--
/* commented for Bug 4149025
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_no_of_mandatory_courses >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validation for number of mandatory courses for Some Mandatory sections
--
Procedure chk_no_of_mandatory_courses
  (
   p_learning_path_section_id  in  number,
   p_no_of_mandatory_courses   in  number
  ) is
  --
  v_count                 number(15);
  v_proc                  varchar2(72) := g_package||'chk_no_of_mandatory_courses';
  --
  cursor sel_lpm_count is
    select count(learning_path_member_id)
      from ota_learning_path_members lpm
     where lpm.learning_path_section_id = p_learning_path_section_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --Added for Bug#3861877
  IF NOT p_no_of_mandatory_courses > 0 THEN
    fnd_message.set_name('OTA','OTA_443368_POSITIVE_NUMBER');
    fnd_message.raise_error;
  END IF;
  --
  Open sel_lpm_count;
  fetch sel_lpm_count into v_count;
  --
  IF p_no_of_mandatory_courses > v_count THEN
    --
     close sel_lpm_count;
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt            =>  'OTA_13076_LPC_MNDTRY_ACT_ERR'
                      );
    --
  --
  ELSE
    close sel_lpm_count;
  END IF;

  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
EXCEPTION
WHEN app_exception.application_exception THEN

            IF hr_multi_message.exception_add
                (p_associated_column1   => 'OTA_LP_SECTIONS.NO_OF_MANDATORY_COURSES') THEN

              hr_utility.set_location(' Leaving:'||v_proc, 92);
              RAISE;

            END IF;

            hr_utility.set_location(' Leaving:'||v_proc, 94);

End chk_no_of_mandatory_courses;
--
*/
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_lpc_shd.g_rec_type
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
    ,p_associated_column1 => ota_lpc_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
	--
  ota_general.check_domain_value(
		p_domain_type		     => 'OTA_LP_SECTION_COMPLETION_TYPE',
		p_domain_value		     => p_rec.completion_type_code);
	--
  IF p_rec.completion_type_code = 'O' THEN
     chk_completion_type_valid(
        p_learning_path_section_id  => p_rec.learning_path_section_id,
        p_learning_path_id          => p_rec.learning_path_id) ;

  END IF;
   IF is_catalog_lp(p_rec.learning_path_id) THEN
      ota_lpc_bus.chk_df(p_rec);
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_lpc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
  l_completion_type_changed   BOOLEAN
       := ota_general.value_changed(ota_lpc_shd.g_old_rec.completion_type_code,
                                    p_rec.completion_type_code);

  l_no_of_courses_changed BOOLEAN
     := ota_general.value_changed(ota_lpc_shd.g_old_rec.no_of_mandatory_courses,
                                  p_rec.no_of_mandatory_courses);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => ota_lpc_shd.g_tab_nam
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
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  ota_general.check_domain_value(
		p_domain_type		     => 'OTA_LP_SECTION_COMPLETION_TYPE',
		p_domain_value		     => p_rec.completion_type_code);
  --
  IF p_rec.completion_type_code = 'O' THEN
     chk_completion_type_valid(
        p_learning_path_section_id  => p_rec.learning_path_section_id,
        p_learning_path_id          => p_rec.learning_path_id) ;

  END IF;

  /* commented for Bug 4149025
  --Modified for Bug#3861877
  IF p_rec.completion_type_code = 'S'-- AND p_rec.no_of_mandatory_courses <> 0
  THEN
     chk_no_of_mandatory_courses(p_learning_path_section_id => p_rec.learning_path_section_id,
                                 p_no_of_mandatory_courses  => p_rec.no_of_mandatory_courses);
  END IF;
  */

  IF l_completion_type_changed OR l_no_of_courses_changed THEN
     chk_if_lme_exists(p_learning_path_section_id => p_rec.learning_path_section_id);
  END IF;
  IF is_catalog_lp(p_rec.learning_path_id) THEN
     ota_lpc_bus.chk_df(p_rec);
 END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_lpc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
     chk_if_lme_exists(p_rec.learning_path_section_id);
      IF NOT is_last_section(p_rec.learning_path_section_id) THEN
         chk_completion_type_valid(p_learning_path_section_id => p_rec.learning_path_section_id,
                                   p_learning_path_id         => p_rec.learning_path_id);
     END IF;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--

end ota_lpc_bus;

/
