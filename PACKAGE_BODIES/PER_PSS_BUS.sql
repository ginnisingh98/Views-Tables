--------------------------------------------------------
--  DDL for Package Body PER_PSS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PSS_BUS" as
/* $Header: pepssrhi.pkb 120.1 2006/08/08 11:27:06 amigarg noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pss_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_salary_survey_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.  It is mandatory.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   salary_survey_id PK of record being inserted or updated.
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
--   Internal row handler use only.
--
Procedure chk_salary_survey_id(p_salary_survey_id      in number,
                               p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_salary_survey_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_pss_shd.api_updating
    (p_salary_survey_id            => p_salary_survey_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_salary_survey_id,hr_api.g_number)
     <>  per_pss_shd.g_old_rec.salary_survey_id) then
    --
    -- raise error as PK has changed
    --
    per_pss_shd.constraint_error('PER_SALARY_SURVEYS_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_salary_survey_id is not null then
      --
      -- raise error as PK is not null
      --
      per_pss_shd.constraint_error('PER_SALARY_SURVEYS_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_salary_survey_id;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_survey_name_company_code >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that survey_name and
--   survey_company_code:
--     a) Are not null since they are mandatory.
--     b) Form a unique combination.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_id
--   object_version_number
--   survey_name
--   survey_company_code.
--
-- Post Success
--   Processing continues if the survey_name and survey_company_code are not
--   null and the combination is valid.
--
-- Post Failure
--   An application error is raised and processing is terminated if the
--   survey_name or survey_company_code are null or combination is invalid.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_survey_name_company_code
(p_salary_survey_id      in number,
 p_object_version_number in number,
 p_survey_name           in per_salary_surveys.survey_name%TYPE,
 p_survey_company_code   in per_salary_surveys.survey_company_code%TYPE) is
  --
  l_proc         varchar2(72) := g_package||'chk_survey_name_company_code';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor csr_unique_surv_name_comp_code is
    select null
    from   per_salary_surveys
    where upper(survey_name)   = upper(p_survey_name)
    and    survey_company_code = p_survey_company_code
    and    salary_survey_id <> nvl(p_salary_survey_id,hr_api.g_number);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that survey_name is not null.  Error if it is.
  --
  if p_survey_name is null then
    fnd_message.set_name('PER','PER_50331_PSS_MAND_SURV_NAME');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check that survey_company_code is not null.  Error if it is.
  --
  if p_survey_company_code is null then
    fnd_message.set_name('PER','PER_50332_PSS_MAND_SURV_COMP');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Entering:'||l_proc, 15);
  --
  --  Only proceed with validation if:
  --   The current g_old_rec is current and
  --   The survey_name value has changed or
  --   The survey_company_code value has changed or
  --   A record is being inserted
  --
  l_api_updating := per_pss_shd.api_updating
    (p_salary_survey_id      => p_salary_survey_id
    ,p_object_version_number => p_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  if ((l_api_updating
        and nvl(per_pss_shd.g_old_rec.survey_name, hr_api.g_varchar2)
        <>  nvl(p_survey_name,hr_api.g_varchar2))
     or
      (l_api_updating and
           nvl(per_pss_shd.g_old_rec.survey_company_code,hr_api.g_varchar2)
        <> nvl(p_survey_company_code,hr_api.g_varchar2))
     or
       (NOT l_api_updating))
  then
    --
    -- c) Check that survey_name forms a unique combination with
    --    survey_company_code.
    --
    hr_utility.set_location(l_proc, 25);
    --
    open csr_unique_surv_name_comp_code;
    --
    fetch csr_unique_surv_name_comp_code into l_exists;
    --
    if csr_unique_surv_name_comp_code%found then
        --
        per_pss_shd.constraint_error(p_constraint_name =>
                                     'PER_SALARY_SURVEYS_UK1');
        --
    end if;
    --
    hr_utility.set_location(l_proc, 30);
    --
   end if;
   --
   hr_utility.set_location('Leaving:'||l_proc, 35);
   --
End chk_survey_name_company_code;
--
-- ---------------------------------------------------------------
-- |-----------------< chk_survey_company_code >-----------------|
-- ---------------------------------------------------------------
--
-- Description
--   This procedure is used to check that survey_company_code:
--     a) Exists in hr_standard_lookups for lookup_type 'SURVEY_COMPANY'.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_id
--   survey_company_code.
--   p_effective_date (used as parameter for not_exists in
--                     hr_standard_lookups)
--
-- Post Success
--   Processing continues if the survey_company_code
--   exists in hr_standard_lookups.
--
-- Post Failure
--  An application error is raised and processing is terminated
--  if the survey_company_code does not exist in hr_standard_lookups.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
procedure chk_survey_company_code
(p_salary_survey_id in per_salary_surveys.salary_survey_id%TYPE
,p_survey_company_code
                    in per_salary_surveys.survey_company_code%TYPE
,p_effective_date   in date
  ) is
--
  l_proc           varchar2(72)  :=
                             g_package||'chk_survey_company_code';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  if (((p_salary_survey_id is not null) and
       nvl(per_pss_shd.g_old_rec.survey_company_code,
           hr_api.g_varchar2) <> nvl(p_survey_company_code,
                                     hr_api.g_varchar2))
    or
      (p_salary_survey_id is null)) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    --  If survey_company_code is not null then
    --  Check if the survey_company_code value exists
    --  in hr_standard_lookups where the lookup_type is 'SURVEY_COMPANY'
    --
    if p_survey_company_code is not null then
      -- code commented for bug5439193 by amigarg
      --if hr_api.not_exists_in_hrstanlookups
      if hr_api.not_exists_in_hr_lookups
          (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'SURVEY_COMPANY'
           ,p_lookup_code           => p_survey_company_code
           ) then
        --  Error: Invalid Survey Company
        fnd_message.set_name('PER', 'PER_50333_PSS_INV_SURV_COMP');
        fnd_message.raise_error;
      end if;
      -- code change ended  for bug5439193 by amigarg
      --
      hr_utility.set_location(l_proc, 30);
      --
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end chk_survey_company_code;
--
-- ---------------------------------------------------------------
-- |----------------------< chk_identifier >---------------------|
-- ---------------------------------------------------------------
--
-- Description
--   This procedure is used to check that identifier:
--     a) Is not null.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_id
--   identifier.
--
-- Post Success
--   Processing continues if the identifier is not null.
--
-- Post Failure
--  An application error is raised and processing is terminated
--  if the identifier is null.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
procedure chk_identifier
(p_identifier       in per_salary_surveys.identifier%TYPE) is
--
  l_proc         varchar2(72) := g_package||'chk_identifier';
  l_api_updating boolean;
--
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --  Check that identifier is not null.
  --
  if p_identifier is null then
    fnd_message.set_name('PER','PER_50334_PSS_MAND_IDENTIFIER');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
end chk_identifier;
--
/*ras
-- ---------------------------------------------------------------
-- |--------------------< chk_currency_code >--------------------|
-- ---------------------------------------------------------------
--
-- Description
--   This procedure is used to check that currency_code:
--     a) Is not null.
--     a) Exists in fnd_currencies_v;.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_id
--   currency_code
--   p_effective_date
--
-- Post Success
--   Processing continues if the currency_code
--   exists in hr_standard_lookups and is not null.
--
-- Post Failure
--  An application error is raised and processing is terminated
--  if the currency_code does not exist in hr_standard_lookups or is null.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
procedure chk_currency_code
(p_salary_survey_id in per_salary_surveys.salary_survey_id%TYPE
,p_currency_code
                    in per_salary_surveys.currency_code%TYPE) is
--
  l_proc           varchar2(72)  :=
                             g_package||'chk_currency_code';
  --
  l_api_updating   boolean;
  --
  l_exists         varchar2(1);
  --
  cursor csr_currency_exists is
    select null
    from   fnd_currencies_vl fcv
    where  fcv.currency_code = p_currency_code;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location(l_proc, 15);
  --
  -- Check that currency_code is not null
  --
  if p_currency_code is null then
    fnd_message.set_name('PER','PER_50335_PSS_MAND_CURRENCY');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 17);
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  if (((p_salary_survey_id is not null) and
       nvl(per_pss_shd.g_old_rec.currency_code,
           hr_api.g_varchar2) <> nvl(p_currency_code,
                                     hr_api.g_varchar2))
    or
      (p_salary_survey_id is null)) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    --  If currency_code is not null then
    --  Check if the currency_code value exists
    --  in fnd_currencies_vl.
    --
    open csr_currency_exists;
    --
    fetch csr_currency_exists into l_exists;
    --
    if csr_currency_exists%notfound then
      --
      --  Error: Invalid Currency
      --
      fnd_message.set_name('PER', 'PER_50336_PSS_INV_CURRENCY');
      --
      fnd_message.raise_error;
      --
    end if;
    --
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end chk_currency_code; ras */
--
-- ---------------------------------------------------------------
-- |------------------< chk_survey_type_code >-------------------|
-- ---------------------------------------------------------------
--
-- Description
--   This procedure is used to check that survey_type_code:
--     a) Is not null.
--     b) Exists in hr_standard_lookups for lookup_type 'PAY_BASIS'.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_id
--   survey_type_code.
--   p_effective_date (used as parameter for not_exists in
--                     hr_standard_lookups)
--
-- Post Success
--   Processing continues if the survey_type_code
--   exists in hr_standard_lookups.
--
-- Post Failure
--  An application error is raised and processing is terminated
--  if the survey_type_code does not exist in hr_standard_lookups.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
procedure chk_survey_type_code
(p_salary_survey_id in per_salary_surveys.salary_survey_id%TYPE
,p_survey_type_code
                    in per_salary_surveys.survey_type_code%TYPE
,p_effective_date   in date
  ) is
--
  l_proc           varchar2(72)  :=
                             g_package||'chk_survey_type_code';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Check that survey_type_code is not null.
  --
  if p_survey_type_code is null then
    fnd_message.set_name('PER', 'PER_50337_PSS_MAND_SURV_TYPE');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 15);
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  if (((p_salary_survey_id is not null) and
       nvl(per_pss_shd.g_old_rec.survey_type_code,
           hr_api.g_varchar2) <> nvl(p_survey_type_code,
                                     hr_api.g_varchar2))
    or
      (p_salary_survey_id is null)) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    --  If survey_type_code is not null then
    --  Check if the survey_type_code value exists
    --  in hr_standard_lookups where the lookup_type is 'PAY_BASIS'
    --
    if hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'PAY_BASIS'
         ,p_lookup_code           => p_survey_type_code
         ) then
      --  Error: Invalid Survey TYPE
      fnd_message.set_name('PER', 'PER_50338_PSS_INV_SURV_TYPE');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc, 30);
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
end chk_survey_type_code;

--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that no rows may be deleted if there are
--   rows in PER_SALARY_SURVEY_LINES with matching salary_survey_id.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   salary_survey_id
--
-- Post Success:
--   Processing continues if there are no rows in salary_survey_lines with
--   matcing salary_survey_id.
--
-- Post Failure:
--   An application error is raised if there are  rows in
--   salary_survey_lines with matcing salary_survey_id.
--
-- Access Status
--   Internal row handler use only.
--
-- {End Of Comments}

Procedure chk_delete(p_salary_survey_id
                               in per_salary_surveys.salary_survey_id%TYPE) is
--
  l_proc     varchar2(72) := g_package||'chk_delete';
  l_exists   varchar2(1);
  --
  cursor csr_survey_line_exists is
         select null
         from   per_salary_survey_lines ssl
         where  ssl.salary_survey_id = p_salary_survey_id;
  --
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open csr_survey_line_exists;
  --
  fetch csr_survey_line_exists into l_exists;
  --
  if csr_survey_line_exists%found then
    --
    close csr_survey_line_exists;
    --
    fnd_message.set_name('PER','PER_50339_PSS_INV_DEL');
    fnd_message.raise_error;
    --
  end if;
  --
  close csr_survey_line_exists;
  --
  hr_utility.set_location('Entering:'||l_proc, 20);
  --
End chk_delete;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_non_updateable_args >-----------------------|
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
--   An application error is raised if any of the non updateable attributes
--   (survey_company_code, identifier)
--   have been altered.
--
-- {End Of Comments}

Procedure chk_non_updateable_args
  (p_rec             in per_pss_shd.g_rec_type,
   p_effective_date  in date
  ) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_pss_shd.api_updating
      (p_salary_survey_id          => p_rec.salary_survey_id
      ,p_object_version_number     => p_rec.object_version_number
      ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.survey_company_code, hr_api.g_varchar2) <>
     nvl(per_pss_shd.g_old_rec.survey_company_code,hr_api.g_varchar2)
  then
     l_argument := 'survey_company_code';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  if nvl(p_rec.identifier, hr_api.g_varchar2) <>
     nvl(per_pss_shd.g_old_rec.identifier,hr_api.g_varchar2)
  then
     l_argument := 'identifier';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 60);
end chk_non_updateable_args;
--
--
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
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
procedure chk_df
  (p_rec in per_pss_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.salary_survey_id is not null) and (
     nvl(per_pss_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_pss_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.salary_survey_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_SALARY_SURVEYS'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      );

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec            in per_pss_shd.g_rec_type,
                          p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --   a) Check SALARY_SURVEY_ID.
  --
  chk_salary_survey_id(p_salary_survey_id      => p_rec.salary_survey_id
                      ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 10);
  --
  --   b) Check SURVEY_NAME and SURVEY_COMPANY_CODE.
  --
  chk_survey_name_company_code(p_salary_survey_id => p_rec.salary_survey_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_survey_name           => p_rec.survey_name
  ,p_survey_company_code   => p_rec.survey_company_code);
  --
  hr_utility.set_location(l_proc, 15);
  --
  --  c) Check SURVEY_COMPANY_CODE specific rules.
  --
 chk_survey_company_code(p_salary_survey_id => p_rec.salary_survey_id
 ,p_survey_company_code => p_rec.survey_company_code
 ,p_effective_date      => p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --  d) Check IDENTIFIER.
  --
  chk_identifier(p_identifier => p_rec.identifier);
  --
  hr_utility.set_location(l_proc, 25);
  --
  --  e) Check CURRENCY_CODE.
  --
--ras  chk_currency_code(p_salary_survey_id => p_rec.salary_survey_id
--ras                  ,p_currency_code    => p_rec.currency_code);
  --
  hr_utility.set_location(l_proc, 27);
  --
  --  f) Check SURVEY_TYPE_CODE.
  --
  chk_survey_type_code(p_salary_survey_id => p_rec.salary_survey_id
  ,p_survey_type_code => p_rec.survey_type_code
  ,p_effective_date   => p_effective_date);
  --
  hr_utility.set_location(l_proc, 30);
  --

  --
  -- Call descriptive flexfield validation routines
  --
  per_pss_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 35);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_pss_shd.g_rec_type,
                          p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --   a) Check for non updateable arguments.
  --
  chk_non_updateable_args(p_rec => p_rec
  ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(l_proc, 10);
  --
  --   b) Check SALARY_SURVEY_ID.
  --
  chk_salary_survey_id(p_salary_survey_id      => p_rec.salary_survey_id
                      ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 15);
  --
  --   c) Check SURVEY_NAME and SURVEY_COMPANY_CODE have a unique combination.
  --
  chk_survey_name_company_code(p_salary_survey_id => p_rec.salary_survey_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_survey_name           => p_rec.survey_name
  ,p_survey_company_code   => p_rec.survey_company_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --  d) Check CURRENCY_CODE.
  --
--ras  chk_currency_code(p_salary_survey_id => p_rec.salary_survey_id
--ras                   ,p_currency_code    => p_rec.currency_code);
  --
  hr_utility.set_location(l_proc, 23);
  --
  --  e) Check SURVEY_TYPE_CODE.
  --
  chk_survey_type_code(p_salary_survey_id => p_rec.salary_survey_id
  ,p_survey_type_code => p_rec.survey_type_code
  ,p_effective_date   => p_effective_date);
  --
  hr_utility.set_location(l_proc, 25);
  --
  --
  -- Call descriptive flexfield validation routines
  --
  per_pss_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 35);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_pss_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --  Check there are no rows in PER_SALARY_SURVEY_LINES.
  --
  chk_delete(p_salary_survey_id => p_rec.salary_survey_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_pss_bus;

/
