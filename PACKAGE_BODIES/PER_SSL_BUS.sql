--------------------------------------------------------
--  DDL for Package Body PER_SSL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSL_BUS" as
/* $Header: pesslrhi.pkb 120.0.12010000.2 2008/09/09 11:18:51 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ssl_bus.';  -- Global package name

--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_salary_survey_line_id >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that the primary key for the table:
--     a) is null on insert
--     b) has not been updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   salary_survey_line_id PK of record being inserted or updated.
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues If:
--     The primary key is null on insert.
--     The primary key has not been updated.
--
-- Post Failure
--   Errors handled by the Procedure
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_salary_survey_line_id
(p_salary_survey_line_id in number,
 p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_salary_survey_line_id';
  --
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id,
     p_object_version_number  => p_object_version_number);
  --
  -- Check that the primary key has not changed.
  --
  If (l_api_updating
     and nvl(p_salary_survey_line_id,hr_api.g_number)
     <>  per_ssl_shd.g_old_rec.salary_survey_line_id) Then
    --
    -- raise error as Primary Key has changed
    --
    per_ssl_shd.constraint_error('PER_SALARY_SURVEY_LINES_PK');
    --
  elsIf not l_api_updating Then
    --
    -- This is an insert so check that the primary key is null.
    --
    If p_salary_survey_line_id is not null Then
      --
      -- raise error as Primary Key is not null
      --
      per_ssl_shd.constraint_error('PER_SALARY_SURVEY_LINES_PK');
      --
    End If;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_salary_survey_line_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_salary_survey_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_line_id PK
--   p_salary_survey_id ID of FK column
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the foreign key exists in the referenced table.
--
-- Post Failure
--   Processing stops and an error is raised If the foreign key does not
--   exist in the referenced table.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_salary_survey_id
(p_salary_survey_line_id in number,
 p_salary_survey_id       in number,
 p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_salary_survey_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor csr_chk_survey_exists is
    select null
    from   per_salary_surveys pss
    where  pss.salary_survey_id = p_salary_survey_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- 	Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'salary_survey_id'
    ,p_argument_value	=> p_salary_survey_id
    );
  --
  hr_utility.set_location(l_proc,6);
  --
  --
  -- check If salary_survey_id value exists in per_salary_surveys table
  --
  open csr_chk_survey_exists;
  --
  fetch csr_chk_survey_exists into l_exists;
  --
  If csr_chk_survey_exists%notfound Then
    --
    close csr_chk_survey_exists;
    hr_utility.set_location('SS id '||to_char(p_salary_survey_id),7);
    --
    -- raise error as FK does not relate to PK in per_salary_surveys
    -- table.
    --
    per_ssl_shd.constraint_error('PER_SALARY_SURVEY_LINES_FK1');
    --
  End If;
  --
  close csr_chk_survey_exists;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_salary_survey_id;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_key >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that survey_job_name_code,
--   survey_region_code, survey_seniority_code, company_size_code,
--   industry_code, survey_age_code form a unique combination with
--   the start_date for this row, between the start_date and
--   end_date of any other row.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_line_id
--   object_version_number
--   survey_job_name_code
--   survey_region_code
--   survey_seniority_code
--   company_size_code
--   industry_code
--   survey_age_code
--   start_date.
--
-- Post Success
--   Processing continues If the survey_job_name_code, survey_region_code,
--   survey_seniority_code, company_size_code, industry_code survey_age_code
--   form a unique combination with start_date for this row between the
--   start_date and end_date of any other row.
--
-- Post Failure
--   An application error is raised If the survey_job_name_code,
--   survey_region_code, survey_seniority, company_size, industry_code
--   survey_age_code combined with start_date for this row are not unique
--   between start_date and end_date of any other row..
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_unique_key
(p_salary_survey_line_id  in number,
 p_object_version_number  in number,
 p_salary_survey_id       in number,
 p_survey_job_name_code   in per_salary_survey_lines.survey_job_name_code%TYPE,
 p_survey_region_code     in per_salary_survey_lines.survey_region_code%TYPE,
 p_survey_seniority_code  in per_salary_survey_lines.survey_seniority_code%TYPE,
 p_company_size_code      in per_salary_survey_lines.company_size_code%TYPE,
 p_industry_code          in per_salary_survey_lines.industry_code%TYPE,
 p_survey_age_code        in per_salary_survey_lines.survey_age_code%TYPE,
 p_start_date             in per_salary_survey_lines.start_date%TYPE,
 p_end_date               in per_salary_survey_lines.end_date%TYPE)is
  --
  l_proc         varchar2(72) := g_package||'chk_unique_key';
  l_api_updating boolean;
  l_exists       varchar2(1);
  l_eot          date         := hr_general.End_of_time;
  --
  cursor csr_duplicate_key is
    select null
    from   per_salary_survey_lines
    where  p_start_date              = start_date
    and    survey_job_name_code      = p_survey_job_name_code
    and    nvl(survey_region_code,hr_api.g_varchar2)
                                     = nvl(p_survey_region_code,hr_api.g_varchar2)
    and    nvl(survey_seniority_code,hr_api.g_varchar2)
                                     = nvl(p_survey_seniority_code,hr_api.g_varchar2)
    and    nvl(company_size_code,hr_api.g_varchar2)
                                     = nvl(p_company_size_code,hr_api.g_varchar2)
    and    nvl(industry_code,hr_api.g_varchar2)
                                     = nvl(p_industry_code,hr_api.g_varchar2)
    and    nvl(survey_age_code,hr_api.g_varchar2)
                                     = nvl(p_survey_age_code,hr_api.g_varchar2)    and    salary_survey_line_id <> nvl(p_salary_survey_line_id,hr_api.g_number)
    and    salary_survey_id = nvl(p_salary_survey_id,hr_api.g_number);
  --
  cursor csr_overlap_date is
    select null
    from   per_salary_survey_lines
    where  p_start_date          <= nvl(end_date,l_eot)
    and    nvl(p_end_date,l_eot) >= start_date
    and    survey_job_name_code  = p_survey_job_name_code
    and    nvl(survey_region_code,hr_api.g_varchar2)
                                 = nvl(p_survey_region_code,hr_api.g_varchar2)
    and    nvl(survey_seniority_code,hr_api.g_varchar2)
                                 = nvl(p_survey_seniority_code,hr_api.g_varchar2)
    and    nvl(company_size_code,hr_api.g_varchar2)
                                 = nvl(p_company_size_code,hr_api.g_varchar2)
    and    nvl(industry_code,hr_api.g_varchar2)
                                 = nvl(p_industry_code,hr_api.g_varchar2)
    and    nvl(survey_age_code,hr_api.g_varchar2)
                                 = nvl(p_survey_age_code,hr_api.g_varchar2)
    and    end_date is not null
    and    salary_survey_line_id <> nvl(p_salary_survey_line_id,hr_api.g_number)
    and    salary_survey_id = nvl(p_salary_survey_id,hr_api.g_number);
  --
  cursor csr_invalid_end_date is
    select null
    from   per_salary_survey_lines
    where  p_start_date < start_date
    and    (nvl(p_end_date,l_eot) >= start_date and
            nvl(p_end_date,l_eot) <= nvl(end_date,l_eot)
           )
    and    survey_job_name_code  = p_survey_job_name_code
    and    nvl(survey_region_code,hr_api.g_varchar2)
                                 = nvl(p_survey_region_code,hr_api.g_varchar2)
    and    nvl(survey_seniority_code,hr_api.g_varchar2)
                                 = nvl(p_survey_seniority_code,hr_api.g_varchar2)
    and    nvl(company_size_code,hr_api.g_varchar2)
                                 = nvl(p_company_size_code,hr_api.g_varchar2)
    and    nvl(industry_code,hr_api.g_varchar2)
                                 = nvl(p_industry_code,hr_api.g_varchar2)
    and    nvl(survey_age_code,hr_api.g_varchar2)
                                 = nvl(p_survey_age_code,hr_api.g_varchar2)
    and    salary_survey_line_id <> nvl(p_salary_survey_line_id,hr_api.g_number)
    and    salary_survey_id = nvl(p_salary_survey_id,hr_api.g_number);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that start_date is not null.  Error If it is.
  --
  If p_start_date is null Then
    fnd_message.set_name('PER','PER_50341_SSL_MAND_START_DATE');
    fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(l_proc, 10);
  --
  --  Only proceed with validation If:
  --   The current g_old_rec is current and
  --   Any of the values have changed or
  --   A record is being inserted
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 15);
  --
  If (l_api_updating
        and nvl(per_ssl_shd.g_old_rec.survey_job_name_code,hr_api.g_varchar2)
        <>  nvl(p_survey_job_name_code,hr_api.g_varchar2))
     or
      (l_api_updating and
           nvl(per_ssl_shd.g_old_rec.survey_region_code,hr_api.g_varchar2)
        <> nvl(p_survey_region_code,hr_api.g_varchar2))
     or
      (l_api_updating and
           nvl(per_ssl_shd.g_old_rec.survey_seniority_code,hr_api.g_varchar2)
        <> nvl(p_survey_seniority_code,hr_api.g_varchar2))
     or
      (l_api_updating and
           nvl(per_ssl_shd.g_old_rec.company_size_code,hr_api.g_varchar2)
        <> nvl(p_company_size_code,hr_api.g_varchar2))
     or
      (l_api_updating and
           nvl(per_ssl_shd.g_old_rec.industry_code,hr_api.g_varchar2)
        <> nvl(p_industry_code,hr_api.g_varchar2))
     or
      (l_api_updating and
           nvl(per_ssl_shd.g_old_rec.survey_age_code,hr_api.g_varchar2)
        <> nvl(p_survey_age_code,hr_api.g_varchar2))

     or
      (l_api_updating and
           per_ssl_shd.g_old_rec.start_date <> p_start_date)
     or
      (l_api_updating and
           nvl(per_ssl_shd.g_old_rec.end_date,l_eot)
        <> nvl(p_end_date,l_eot)
     or
       (NOT l_api_updating))
  Then
    --
    hr_utility.set_location(l_proc, 17);
    --
    -- Check If this key already exists on this start date.
    -- Error If it does.
    --
    open csr_duplicate_key;
    --
    fetch csr_duplicate_key into l_exists;
    --
    If csr_duplicate_key%found Then
      --
      close csr_duplicate_key;
      --
      per_ssl_shd.constraint_error(p_constraint_name =>
                                   'PER_SALARY_SURVEY_LINES_UK1');
      --
    End If;
    --
    close csr_duplicate_key;
    --
    --   Check that their is no overlap in the dates
    --   with this key. Error If their is.
    --
    hr_utility.set_location(l_proc, 20);
    --
    open csr_overlap_date;
    --
    fetch csr_overlap_date into l_exists;
    --
    If csr_overlap_date%found Then
      --
      close csr_overlap_date;
      --
      fnd_message.set_name('PER','PER_50342_SSL_INV_COMB2');
      --
      fnd_message.raise_error;
      --
    End If;
    --
    close csr_overlap_date;
    --
    hr_utility.set_location(l_proc, 25);
    --
    --
    --  Check that the end_date does not fall within the start_date and end_date
    --  of another survey_line when its accompanying keys match the keys of that
    --  other survey_line.
    --
    open csr_invalid_end_date;
    --
    fetch csr_invalid_end_date into l_exists;
    --
    If csr_invalid_end_date%found Then
      --
      close csr_invalid_end_date;
      --
      fnd_message.set_name('PER','PER_50379_SSL_INV_END_DATE');
      --
      fnd_message.raise_error;
      --
    End If;
    --
    close csr_invalid_end_date;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
  --
End chk_unique_key;
--
--
-- -------------------------------------------------------------------------------
-- |-----------------< chk_survey_job_name_code >--------------------------------|
-- -------------------------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that survey_job_name_code:
--     a) Is not null.
--     b) Exists in hr_standard_lookups for lookup_type 'SURVEY_JOB_NAME'.
--     c) Contains PER_SALARY_SURVEYS.IDENTIFIER as its first two
--        letters.
--
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_line_id
--   object_version_number
--   survey_job_name_code
--   p_effective_date (used as parameter for function
--                     not_exists_in_hrstanlookups)
--
-- Post Success
--   Processing continues If the survey_job_name_code
--    is not null
--    exists in hr_standard_lookups and
--    PSS.IDENTIFIER makes up its first two letters.
--
-- Post Failure
--  An application error is raised and processing is terminated
--    If survey_job_name_code is null
--    If the survey_job_name_code does not exist in hr_standard_lookups.
--    or PSS.IDENTIFIER does not make up the first two letters of
--       survey_job_name_code.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_survey_job_name_code
(p_salary_survey_line_id
           in number
,p_object_version_number
           in number
,p_salary_survey_id
           in number
,p_survey_job_name_code
           in per_salary_survey_lines.survey_job_name_code%TYPE
,p_effective_date
           in date) is
--
  l_proc           varchar2(72) := g_package||'chk_survey_job_name_code';
  --
  l_api_updating   boolean;
  --
  l_exists         Varchar2(1);
  --
  cursor csr_has_identifier is
    select null
    from   per_salary_surveys
    where  salary_survey_id = p_salary_survey_id
    and    identifier = SUBSTR(p_survey_job_name_code,0,2);
  --
Begin
  --
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
  -- Check that survey_job_name_code is not null.  Error If it is.
  --
  If p_survey_job_name_code is null Then
    fnd_message.set_name('PER','PER_50343_SSL_MAND_JOB_NAME');
    fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(l_proc, 13);
  --
  -- Only proceed with validation If:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  If (( l_api_updating and
       (per_ssl_shd.g_old_rec.survey_job_name_code <>
        p_survey_job_name_code))
    or
      (p_salary_survey_line_id is null)) Then
    --
    hr_utility.set_location(l_proc, 20);
    --
    --  Check If the survey_job_name_code value exists
    --  in hr_standard_lookups where the lookup_type is 'SURVEY_JOB_NAME'
    --
    If hr_api.not_exists_in_hr_lookups --fix for bug 7240498
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'SURVEY_JOB_NAME'
         ,p_lookup_code           => p_survey_job_name_code
         ) Then
      --  Error: Invalid Survey Job Name
      fnd_message.set_name('PER', 'PER_50344_SSL_INV_JOB_NAME_LKP');
      --
      fnd_message.raise_error;
      --
    End If;
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Open the cursor to see If the job_name_code has the identifier
    -- as the first two characters.
    --
    open csr_has_identifier;
      --
      fetch csr_has_identifier into l_exists;
      --
      If csr_has_identifier%notfound Then
        --
        close csr_has_identifier;
        --
        -- The job_name_code does not have the Survey IdentIfier
        -- as the first two characters so raise an error.
        --
        fnd_message.set_name('PER', 'PER_50345_SSL_INV_JOB_NAME_ID');
        --
        fnd_message.raise_error;
        --
      End If;
      --
      close csr_has_identifier;
      --
      hr_utility.set_location(l_proc, 35);
      --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
End chk_survey_job_name_code;
--
--
-- ---------------------------------------------------------------
-- |-----------------< chk_survey_region_code >-----------------|
-- ---------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that survey_region_code:
--     a) Exists in hr_standard_lookups for lookup_type 'SURVEY_REGION'.
--     b) Contains PER_SALARY_SURVEYS.IDENTIFIER as its first two
--        letters
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_line_id
--   object_version_number
--   survey_region_code.
--   p_effective_date (used as parameter for function
--                     not_exists_in_hrstanlookups)
--
-- Post Success
--   Processing continues If the survey_region_code
--    exists in hr_standard_lookups and
--    SSM.IDENTIFIER makes up its first two letters.
--
-- Post Failure
--  An application error is raised and processing is terminated
--    If the survey_region_code does not exist in hr_standard_lookups.
--    or PSS.IDENTIFIER does not make up the first two letters of
--       survey_region_code.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_survey_region_code
(p_salary_survey_line_id
           in number
,p_object_version_number
           in number
,p_salary_survey_id
           in number
,p_survey_region_code
           in per_salary_survey_lines.survey_region_code%TYPE
,p_effective_date
           in date) is
--
  l_proc           varchar2(72) := g_package||'chk_survey_region_code';
   --
  l_api_updating   boolean;
  --
  l_exists         Varchar2(1);
  --
  cursor csr_has_identifier is
    select null
    from   per_salary_surveys
    where  salary_survey_id = p_salary_survey_id
    and    identifier = SUBSTR(p_survey_region_code,0,2);
  --
--
Begin
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
  hr_utility.set_location(l_proc, 13);
  --
  -- Only proceed with validation If:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  If p_survey_region_code is not null Then
    --
    If ( ( l_api_updating and
           (nvl(per_ssl_shd.g_old_rec.survey_region_code,hr_api.g_varchar2)
            <> nvl(p_survey_region_code,hr_api.g_varchar2)))
            or
            (p_salary_survey_line_id is null) ) Then
      --
      hr_utility.set_location(l_proc, 20);
      --
      --  Check If the survey_region_code value exists
      --  in hr_standard_lookups where the lookup_type is 'SURVEY_REGION'
      --
      If hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'SURVEY_REGION'
           ,p_lookup_code           => p_survey_region_code
           ) Then
        --  Error: Invalid Survey Region
        fnd_message.set_name('PER', 'PER_50346_SSL_INV_REGION_LKP');
        --
        fnd_message.raise_error;
        --
      End If;
      --
    End If;
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Open the cursor to see If the survey_region_code has the
    -- identifier as the first two characters.
    --
    open csr_has_identifier;
      --
      fetch csr_has_identifier into l_exists;
      --
      If csr_has_identifier%notfound Then
        --
        close csr_has_identifier;
        --
        -- The survey_region_code does not have the Survey IdentIfier
        -- as the first two characters so raise an error.
        --
        fnd_message.set_name('PER', 'PER_50347_SSL_INV_REGION_ID');
        --
        fnd_message.raise_error;
        --
      End If;
      --
      close csr_has_identifier;
      --
      hr_utility.set_location(l_proc, 35);
      --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
End chk_survey_region_code;
--
--
-- ---------------------------------------------------------------
-- |--------------------< chk_seniority_code >-------------------|
-- ---------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that survey_seniority_code:
--     a) Exists in hr_standard_lookups for lookup_type 'SURVEY_SENIORITY'.
--     b) Contains PER_SALARY_SURVEYS.IDENTIFIER as its first two
--        letters
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_line_id
--   object_version_number
--   survey_seniority_code.
--   p_effective_date (used as parameter for function
--                     not_exists_in_hrstanlookups)
--
-- Post Success
--   Processing continues If the survey_seniority_code
--     exists in hr_standard_lookups and
--     PSS.IDENTIFIER makes up its first two letters.
--
-- Post Failure
--  An application error is raised and processing is terminated
--    If the survey_seniority_code does not exist in hr_standard_lookups.
--    or PSS.IDENTIFIER does not make up the first two letters of
--       survey_seniority_code.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_survey_seniority_code
(p_salary_survey_line_id
           in number
,p_object_version_number
           in number
,p_salary_survey_id
           in number
,p_survey_seniority_code
           in per_salary_survey_lines.survey_seniority_code%TYPE
,p_effective_date
           in date) is
--
  l_proc           varchar2(72) := g_package||'chk_survey_seniority_code';
   --
  l_api_updating   boolean;
  --
  l_exists         Varchar2(1);
  --
  cursor csr_has_identifier is
    select null
    from   per_salary_surveys
    where  salary_survey_id = p_salary_survey_id
    and    identifier = SUBSTR(p_survey_seniority_code,0,2);
  --
--
Begin
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
  hr_utility.set_location(l_proc, 13);
  --
  -- Only proceed with validation If:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  If p_survey_seniority_code is not null Then
    If ((l_api_updating and
          (nvl(per_ssl_shd.g_old_rec.survey_seniority_code,
              hr_api.g_varchar2) <>
          nvl(p_survey_seniority_code,hr_api.g_varchar2)))
      or
        (p_salary_survey_line_id is null)) Then
      --
      hr_utility.set_location(l_proc, 20);
      --
      --  Check If the survey_seniority_code value exists
      --  in hr_standard_lookups where the lookup_type is 'SURVEY_SENIORITY'
      --
      If hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'SURVEY_SENIORITY'
           ,p_lookup_code           => p_survey_seniority_code
           ) Then
        --  Error: Invalid Survey Seniority
        fnd_message.set_name('PER', 'PER_50348_SSL_INV_SENIOR_LKP');
        --
        fnd_message.raise_error;
        --
      End If;
      --
    End If;
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Open the cursor to see If the survey_seniority_code has the
    -- identifier as the first two characters.
    --
    open csr_has_identifier;
      --
      fetch csr_has_identifier into l_exists;
      --
      If csr_has_identifier%notfound Then
        close csr_has_identifier;
        --
        -- The survey_seniority_code does not have the Survey IdentIfier
        -- as the first two characters so raise an error.
        --
        fnd_message.set_name('PER', 'PER_50349_SSL_INV_SENIOR_ID');
        --
        fnd_message.raise_error;
        --
      End If;
      --
      close csr_has_identifier;
      --
      hr_utility.set_location(l_proc, 35);
      --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
End chk_survey_seniority_code;
--
--
-- ---------------------------------------------------------------
-- |-------------------< chk_company_size_code >-----------------|
-- ---------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that company_size_code:
--     a) Exists in hr_standard_lookups for lookup_type 'COMPANY_SIZE'.
--     b) Contains PER_SALARY_SURVEYS.IDENTIFIER as its first two
--        letters
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_line_id
--   object_version_number
--   company_size_code.
--   p_effective_date (used as parameter for function
--                     not_exists_in_hrstanlookups)
--
-- Post Success
--   Processing continues If the company_size_code
--     exists in hr_standard_lookups and
--     PSS.IDENTIFIER makes up its first two letters.
--
-- Post Failure
--  An application error is raised and processing is terminated
--    If the company_size_code does not exist in hr_standard_lookups.
--    or PSS.IDENTIFIER does not make up the first two letters of
--       company_size_code.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_company_size_code
(p_salary_survey_line_id
           in number
,p_object_version_number
           in number
,p_salary_survey_id
           in number
,p_company_size_code
           in per_salary_survey_lines.company_size_code%TYPE
,p_effective_date
           in date) is
--
  l_proc           varchar2(72) := g_package||'chk_company_size_code';
   --
  l_api_updating   boolean;
  --
  l_exists         Varchar2(1);
  --
  cursor csr_has_identifier is
    select null
    from   per_salary_surveys
    where  salary_survey_id = p_salary_survey_id
    and    identifier = SUBSTR(p_company_size_code,0,2);
  --
--
Begin
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
  hr_utility.set_location(l_proc, 13);
  --
  -- Only proceed with validation If:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  If p_company_size_code is not null Then
    If ((l_api_updating and
          (nvl(per_ssl_shd.g_old_rec.company_size_code,
              hr_api.g_varchar2) <>
          nvl(p_company_size_code,hr_api.g_varchar2)))
      or
        (p_salary_survey_line_id is null)) Then
      --
      hr_utility.set_location(l_proc, 20);
      --
      --  Check If the company_size_code value exists
      --  in hr_standard_lookups where the lookup_type is 'COMPANY_SIZE'
      --
      If hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'COMPANY_SIZE'
           ,p_lookup_code           => p_company_size_code
           ) Then
        --  Error: Invalid Company Size
        fnd_message.set_name('PER', 'PER_50350_SSL_INV_COMPANY_LKP');
        --
        fnd_message.raise_error;
        --
      End If;
      --
    End If;
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Open the cursor to see If the company_size_code has the
    -- identifier as the first two characters.
    --
    open csr_has_identifier;
      --
      fetch csr_has_identifier into l_exists;
      --
      If csr_has_identifier%notfound Then
        close csr_has_identifier;
        --
        -- The company_size_code does not have the Survey IdentIfier
        -- as the first two characters so raise an error.
        --
        fnd_message.set_name('PER', 'PER_50351_INV_COMP_ID');
        --
        fnd_message.raise_error;
        --
      End If;
      --
      close csr_has_identifier;
      --
      hr_utility.set_location(l_proc, 35);
      --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
End chk_company_size_code;
--
--
-- ---------------------------------------------------------------
-- |----------------------< chk_industry_code >------------------|
-- ---------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that industry_code:
--     a) Exists in hr_standard_lookups for lookup_type 'INDUSTRY'.
--     b) Contains PER_SALARY_SURVEYS.IDENTIFIER as its first two
--        letters
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   object_version_number
--   salary_survey_line_id
--   industry_code.
--   p_effective_date (used as parameter for not_exists in
--                     hr_standard_lookups)
--
-- Post Success
--   Processing continues If the industry_code
--     exists in hr_standard_lookups and
--     PSS.IDENTIFIER makes up its first two letters.
--
-- Post Failure
--  An application error is raised and processing is terminated
--    If the industry_code does not exist in hr_standard_lookups.
--    or PSS.IDENTIFIER does not make up the first two letters of
--       industry_code.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_industry_code
(p_salary_survey_line_id
           in number
,p_object_version_number
           in number
,p_salary_survey_id
           in number
,p_industry_code
           in per_salary_survey_lines.industry_code%TYPE
,p_effective_date
           in date) is
--
  l_proc           varchar2(72) := g_package||'chk_industry_code';
  --
  l_api_updating   boolean;
  --
  l_exists         Varchar2(1);
  --
  cursor csr_has_identifier is
    select null
    from   per_salary_surveys
    where  salary_survey_id = p_salary_survey_id
    and    identifier = SUBSTR(p_industry_code,0,2);
  --
--
Begin
  --
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
  hr_utility.set_location(l_proc, 13);
  --
  -- Only proceed with validation If:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  If p_industry_code is not null Then
    --
    If ((l_api_updating and
          (nvl(per_ssl_shd.g_old_rec.industry_code,
              hr_api.g_varchar2) <>
              nvl(p_industry_code,hr_api.g_varchar2)))
      or
        (p_salary_survey_line_id is null)) Then
      --
      hr_utility.set_location(l_proc, 20);
      --
      --  Check If the industry_code value exists
      --  in hr_standard_lookups where the lookup_type is 'INDUSTRY'
      --
      If hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'INDUSTRY'
           ,p_lookup_code           => p_industry_code
           ) Then
        --  Error: Invalid Industry
        fnd_message.set_name('PER', 'PER_50352_SSL_INV_INDUSTRY_LKP');
        --
        fnd_message.raise_error;
        --
      End If;
      --
    End If;
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Open the cursor to see If the industry_code has the
    -- identifier as the first two characters.
    --
    open csr_has_identifier;
      --
      fetch csr_has_identifier into l_exists;
      --
      If csr_has_identifier%notfound Then
        --
        close csr_has_identifier;
        --
        -- The industry_code does not have the Survey IdentIfier
        -- as the first two characters so raise an error.
        --
        fnd_message.set_name('PER', 'PER_50353_SSL_INV_INDUSTRY_ID');
        --
        fnd_message.raise_error;
        --
      End If;
      --
      close csr_has_identifier;
      --
      hr_utility.set_location(l_proc, 35);
      --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
End chk_industry_code;

--
--
-- ---------------------------------------------------------------
-- |-------------------< chk_survey_age_code >-------------------|
-- ---------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that survey_age_code:
--     a) Exists in hr_standard_lookups for lookup_type 'SURVEY_AGE'.
--     b) Contains PER_SALARY_SURVEYS.IDENTIFIER as its first two
--        letters
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   object_version_number
--   salary_survey_line_id
--   survey_age_code.
--   p_effective_date (used as parameter for not_exists in
--                     hr_standard_lookups)
--
-- Post Success
--   Processing continues If the survey_age_code
--     exists in hr_standard_lookups and
--     PSS.IDENTIFIER makes up its first two letters.
--
-- Post Failure
--  An application error is raised and processing is terminated
--    If the survey_age_code does not exist in hr_standard_lookups.
--    or PSS.IDENTIFIER does not make up the first two letters of
--       survey_age_code.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_survey_age_code
(p_salary_survey_line_id
           in number
,p_object_version_number
           in number
,p_salary_survey_id
           in number
,p_survey_age_code
           in per_salary_survey_lines.survey_age_code%TYPE
,p_effective_date
           in date) is
--
  l_proc           varchar2(72) := g_package||'chk_survey_age_code';
  --
  l_api_updating   boolean;
  --
  l_exists         Varchar2(1);
  --
  cursor csr_has_identifier is
    select null
    from   per_salary_surveys
    where  salary_survey_id = p_salary_survey_id
    and    identifier = SUBSTR(p_survey_age_code,0,2);
  --
--
Begin
  --
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
  hr_utility.set_location(l_proc, 13);
  --
  -- Only proceed with validation If:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  If p_survey_age_code is not null Then
    --
    If ((l_api_updating and
          (nvl(per_ssl_shd.g_old_rec.survey_age_code,
              hr_api.g_varchar2) <>
              nvl(p_survey_age_code,hr_api.g_varchar2)))
      or
        (p_salary_survey_line_id is null)) Then
      --
      hr_utility.set_location(l_proc, 20);
      --
      --  Check If the survey_age_code value exists
      --  in hr_standard_lookups where the lookup_type is 'SURVEY_AGE'
      --
      If hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'SURVEY_AGE'
           ,p_lookup_code           => p_survey_age_code
           ) Then
        --  Error: Invalid survey_age
        fnd_message.set_name('PER', 'PER_50354_SSL_INV_AGE_LKP');
        --
        fnd_message.raise_error;
        --
      End If;
      --
    End If;
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Open the cursor to see If the survey_age_code has the
    -- identifier as the first two characters.
    --
    open csr_has_identifier;
      --
      fetch csr_has_identifier into l_exists;
      --
      If csr_has_identifier%notfound Then
        --
        close csr_has_identifier;
        --
        -- The survey_age_code does not have the Survey IdentIfier
        -- as the first two characters so raise an error.
        --
        fnd_message.set_name('PER', 'PER_50355_SSL_INV_AGE_ID');
        --
        fnd_message.raise_error;
        --
      End If;
      --
      close csr_has_identifier;
      --
      hr_utility.set_location(l_proc, 35);
      --
  End If;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
End chk_survey_age_code;
--
--
-- -------------------------------------------------------------------------------
-- |-----------------< chk_stock_display_type_code >--------------------------------|
-- -------------------------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that stock_display_type_code:
--     a) Exists in hr_standard_lookups for lookup_type 'STOCK_DISPLAY_TYPE'.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_line_id
--   object_version_number
--   stock_display_type_code
--   p_effective_date (used as parameter for function
--                     not_exists_in_hrstanlookups)
--
-- Post Success
--   Processing continues If the stock_display_type_code
--    exists in hr_standard_lookups.
--
-- Post Failure
--  An application error is raised and processing is terminated
--    If the stock_display_type_code does not exist in hr_standard_lookups.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_stock_display_type_code
(p_salary_survey_line_id
           in number
,p_object_version_number
           in number
,p_stock_display_type_code
           in per_salary_survey_lines.stock_display_type%TYPE
,p_effective_date
           in date) is
--
  l_proc           varchar2(72) := g_package||'chk_stock_display_type_code';
  --
  l_api_updating   boolean;
  --
  l_exists         Varchar2(1);
  --

Begin
  --
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
  hr_utility.set_location(l_proc, 13);
  --
  -- Only proceed with validation If:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) This is an insert.
  --
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  If p_stock_display_type_code is not null Then
  -- Above check added for bug4343756
  --
  If (( l_api_updating and
       (per_ssl_shd.g_old_rec.stock_display_type <>
        p_stock_display_type_code))
    or
      (p_salary_survey_line_id is null)) Then
    --
    hr_utility.set_location(l_proc, 20);
    --
    --  Check If the stock_display_type_code value exists
    --  in hr_standard_lookups where the lookup_type is 'STOCK_DISPLAY_TYPE'
    --
    If hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'STOCK_DISPLAY_TYPE'
         ,p_lookup_code           => p_stock_display_type_code
         ) Then
      --  Error: Invalid Stock Display Type
      fnd_message.set_name('PER', 'PER_SSL_INV_STOCK_TYPE_LKP');
      --
      fnd_message.raise_error;
      --
    End If;
    --
    hr_utility.set_location(l_proc, 30);
  End If;
  End If; -- p_stock_display_type_code is not null
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  --
End chk_stock_display_type_code;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< is_null >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure :
--     Sets a flag If the passed in value is not null.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   value         (Value of salary figure to be validated)
--
-- In/Out Parameters
--   null flag     (Set to False If the passed in value is not null.
--                  Used in Procedure chk_salary_figures to check If
--                  all the salary figures are null.)
--
-- Post Success
--   Processing continues:
--
--
-- Post Failure
--   An application error is raised:
--
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--

Procedure is_null
 (p_value         in    number,
  p_null_flag     in out nocopy BOOLEAN
  ) is


 l_proc           varchar2(72) := g_package||'is_null';

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_value is not null) Then
    --
    --  Set flag to show that this value is not null.
    --
    p_null_flag := false;
    --
    hr_utility.set_location(l_proc, 10);
    --
  End If;
  --
  hr_utility.set_location(l_proc, 20);
  --
End is_null;
--
-- ---------------------------------------------------------------
-- |------------------< chk_salary_figures >---------------------|
-- ---------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that
--     At least one of the following parameters is not null.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   SALARY_SURVEY_LINE_ID
--   OBJECT_VERSI0N_NUMBER
--   CURRENCY_CODE
--   MINIMUM_PAY
--   MEAN_PAY
--   MAXIMUM_PAY
--   GRADUATE_PAY
--   STARTING_PAY
--   PERCENTAGE_CHANGE
--   JOB_FIRST_QUARTILE
--   JOB_MEDIAN_QUARTILE
--   JOB_THIRD_QUARTILE
--   JOB_FOURTH_QUARTILE
--   MINIMUM_TOTAL_COMPENSATION
--   MEAN_TOTAL_COMPENSATION
--   MAXIMUM_TOTAL_COMPENSATION
--   COMPNSTN_FIRST_QUARTILE
--   COMPNSTN_MEDIAN_QUARTILE
--   COMPNSTN_THIRD_QUARTILE
--   COMPNSTN_FOURTH_QUARTILE
--
-- Post Success
--   Processing continues
--     If at least one of the salary figures is not null.
--
-- Post Failure
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_salary_figures
(p_salary_survey_line_id
      in number,
 p_object_version_number
      in number,
  p_currency_code
      in per_salary_survey_lines.currency_code%TYPE,
 p_minimum_pay
      in per_salary_survey_lines.minimum_pay%TYPE,
 p_mean_pay
      in per_salary_survey_lines.mean_pay%TYPE,
 p_maximum_pay
      in per_salary_survey_lines.maximum_pay%TYPE,
 p_graduate_pay
      in per_salary_survey_lines.graduate_pay%TYPE,
 p_starting_pay
      in per_salary_survey_lines.starting_pay%TYPE,
 p_percentage_change
      in per_salary_survey_lines.percentage_change%TYPE,
 p_job_first_quartile
      in per_salary_survey_lines.job_first_quartile%TYPE,
 p_job_median_quartile
      in per_salary_survey_lines.job_median_quartile%TYPE,
 p_job_third_quartile
      in per_salary_survey_lines.job_third_quartile%TYPE,
 p_job_fourth_quartile
      in per_salary_survey_lines.job_fourth_quartile%TYPE,
 p_minimum_total_compensation
     in per_salary_survey_lines.minimum_total_compensation%TYPE,
 p_mean_total_compensation
     in per_salary_survey_lines.mean_total_compensation%TYPE,
 p_maximum_total_compensation
     in per_salary_survey_lines.maximum_total_compensation%TYPE,
 p_compnstn_first_quartile
     in per_salary_survey_lines.compnstn_first_quartile%TYPE,
 p_compnstn_median_quartile
     in per_salary_survey_lines.compnstn_median_quartile%TYPE,
 p_compnstn_third_quartile
     in per_salary_survey_lines.compnstn_third_quartile%TYPE,
 p_compnstn_fourth_quartile
     in per_salary_survey_lines.compnstn_fourth_quartile%TYPE
) is
  --
  l_proc         varchar2(72) := g_package||'chk_salary_figures';
  --
  l_api_updating boolean;
  --
  l_all_null    boolean       := true;
  --
Begin
  --
  --
  --  Only proceed with validation If:
  --   The current g_old_rec is current and
  --   Any of the values have changed or
  --   A record is being inserted
  --
  l_api_updating := per_ssl_shd.api_updating
    (p_salary_survey_line_id => p_salary_survey_line_id
    ,p_object_version_number  => p_object_version_number
    );
  --
  If ( l_api_updating and
      ((nvl(per_ssl_shd.g_old_rec.minimum_pay,hr_api.g_number)
      <> nvl(p_minimum_pay,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.maximum_pay,hr_api.g_number)
       <> nvl(p_maximum_pay,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.mean_pay,hr_api.g_number)
       <> nvl(p_mean_pay,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.graduate_pay,hr_api.g_number)
       <> nvl(p_graduate_pay,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.starting_pay,hr_api.g_number)
       <> nvl(p_starting_pay,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.percentage_change,hr_api.g_number)
       <> nvl(p_percentage_change,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.job_first_quartile,hr_api.g_number)
       <> nvl(p_job_first_quartile,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.job_median_quartile,hr_api.g_number)
       <> nvl(p_job_median_quartile,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.job_third_quartile,hr_api.g_number)
       <> nvl(p_job_third_quartile,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.job_fourth_quartile,hr_api.g_number)
       <> nvl(p_job_fourth_quartile,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.minimum_total_compensation,hr_api.g_number)
       <> nvl(p_minimum_total_compensation,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.mean_total_compensation,hr_api.g_number)
       <> nvl(p_mean_total_compensation,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.maximum_total_compensation,hr_api.g_number)
       <> nvl(p_maximum_total_compensation,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.compnstn_first_quartile,hr_api.g_number)
       <> nvl(p_compnstn_first_quartile,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.compnstn_median_quartile,hr_api.g_number)
       <> nvl(p_compnstn_median_quartile,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.compnstn_third_quartile,hr_api.g_number)
       <> nvl(p_compnstn_third_quartile,hr_api.g_number)) or
      (nvl(per_ssl_shd.g_old_rec.compnstn_fourth_quartile,hr_api.g_number)
       <> nvl(p_compnstn_fourth_quartile,hr_api.g_number)) ) OR
       (not l_api_updating) )
     then

      --
      hr_utility.set_location('Entering:'||l_proc, 5);
      --
      --  Check that at least one of the salary figures is not null.
      --
      --  Check Minimum Pay.
      --
      is_null(p_value         => p_minimum_pay,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 10);
      --
      --
      --  Check Maximum Pay.
      --
      is_null(p_value         => p_maximum_pay,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 15);
      --
      --
      --  Check Mean pay
      --
      is_null(p_value         => p_mean_pay,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 20);
      --
      --
      --  Check Graduate pay
      --
      is_null(p_value         => p_graduate_pay,
             p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 25);
      --
      --
      --  Check Starting pay
      --
      is_null(p_value         => p_starting_pay,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 30);
      --
      --
      --  Check Percentage Change
      --
      is_null(p_value         => p_percentage_change,
              p_null_flag     => l_all_null);
      --
      --
      --  Check Job First Quartile
      --
      is_null(p_value         => p_job_first_quartile,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 35);
      --
      --
      --  Check job_median_quartile
      --
      is_null(p_value         => p_job_median_quartile,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 40);
      --
      --
      --  Check job_third_quartile
      --
      is_null(p_value         => p_job_third_quartile,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 45);
      --
      --
      --  Check job_fourth_quartile
      --
      is_null(p_value         => p_job_fourth_quartile,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 50);
      --
      --
      --  Check minimum_total_compensation
      --
      is_null(p_value         => p_minimum_total_compensation,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 55);
      --
      --
      --  Check mean_total_compensation
      --
      is_null(p_value         => p_mean_total_compensation,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 60);
      --
      --
      --  Check maximum_total_compensation
      --
      is_null(p_value         => p_maximum_total_compensation,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 65);
      --
      --
      --  Check compnstn_first_quartile
      --
      is_null(p_value         => p_compnstn_first_quartile,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 70);
      --
      --
      --  Check compnstn_median_quartile
      --
      is_null(p_value         => p_compnstn_median_quartile,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 80);
      --
      --
      --  Check compnstn_third_quartile
      --
      is_null(p_value         => p_compnstn_third_quartile,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 85);
      --
      --
      --  Check compnstn_fourth_quartile
      --
      is_null(p_value         => p_compnstn_fourth_quartile,
              p_null_flag     => l_all_null);
      --
      hr_utility.set_location(l_proc, 90);
      --
      --
      -- If all the Salary Figures were null then raise an error;
      --
      If (l_all_null = true) Then
        --
        fnd_message.set_name('PER','PER_50373_SSL_FIG_ALL_NULL');
        --
        fnd_message.raise_error;
        --
      End If;
      --
  End if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 100);
  --
End chk_salary_figures;

--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dates >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure is used to check:
--     a) That the start_date is not null.
--     b) That the start date is not later than the end_date.
--
-- Pre Requisites
--   None.
--
-- In Parameters
--   salary_survey_line_id
--   start_date
--   end_date.
--
-- Post Success
--   Processing continues:
--     If the start_date is not null.
--     If the start date is earlier than end_date.
--
-- Post Failure
--   An application error is raised:
--     If the start_date is null.
--     If the start_date is later than end_date.
--
-- Developer/Implementation Notes
--   None.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_dates
(p_salary_survey_line_id in number,
 p_start_date            in per_salary_survey_lines.start_date%TYPE,
 p_end_date              in per_salary_survey_lines.end_date%TYPE)is
  --
  l_proc         varchar2(72) := g_package||'chk_dates';
  l_eot          date         := hr_general.End_of_time;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that start_date is not null.  Error If it is.
  --
  If p_start_date is null Then
    fnd_message.set_name('PER','PER_50374_SSL_MAND_START_DATE');
    fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(l_proc, 10);
  --
  --  Only proceed with validation If:
  --   The current g_old_rec is current and
  --   start_date has changed or
  --   A record is being inserted
  --
  --
  hr_utility.set_location(l_proc, 15);
  --
  If
    (p_salary_survey_line_id is not null)
     and
       (per_ssl_shd.g_old_rec.start_date <> p_start_date)
     or
      (p_salary_survey_line_id is null)
  Then
    --
    --   Check that the start_date is not later than
    --   the end_date for this row.
    --
    If p_start_date > nvl(p_end_date,l_eot) Then
      --
      fnd_message.set_name('PER','PER_50375_SSL_INV_DATES');
      --
      fnd_message.raise_error;
      --
    End If;
    --
    hr_utility.set_location(l_proc, 25);
    --
   End If;
   --
   hr_utility.set_location('Leaving:'||l_proc, 40);
   --
End chk_dates;
--


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
--   salary_survey_line_id
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
(p_salary_survey_line_id in per_salary_survey_lines.salary_survey_line_id%TYPE
,p_currency_code in per_salary_survey_lines.currency_code%TYPE) is
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
  if (((p_salary_survey_line_id is not null) and
       nvl(per_ssl_shd.g_old_rec.currency_code,
           hr_api.g_varchar2) <> nvl(p_currency_code,
                                     hr_api.g_varchar2))
    or
      (p_salary_survey_line_id is null)) then
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
end chk_currency_code;
--
---------------------------------------------------------------------------
-- |-------------------------------< chk_delete >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This Procedure is used to ensure that no rows may be deleted If there are
--   rows in PER_SALARY_SURVEY_MAPPINGS with matching salary_survey_line_id.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   salary_survey_line_id
--
-- Post Success:
--   Processing continue If there are no rows in per_salary_survey_mappings with
--   matcing salary_survey_line_id.
--
-- Post Failure:
--   An application error is raised If there are rows in
--   per_salary_survey_mappings with matcing salary_survey_line_id.
--
-- Access Status
--   Internal row handler use only.
--
-- {End Of Comments}
--
Procedure chk_delete(p_salary_survey_line_id in number) is
--
  l_proc     varchar2(72) := g_package||'chk_delete';
  l_exists   varchar2(1);
  --
  cursor csr_survey_mapping_exists is
    select null
    from   per_salary_survey_mappings ssm
    where  ssm.salary_survey_line_id = p_salary_survey_line_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open csr_survey_mapping_exists;
  --
  fetch csr_survey_mapping_exists into l_exists;
  --
  If csr_survey_mapping_exists%found Then
    --
    close csr_survey_mapping_exists;
    --
    fnd_message.set_name('PER','PER_50376_SSL_INV_DEL');
    fnd_message.raise_error;
    --
  End If;
  --
  close csr_survey_mapping_exists;
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
--   Processing continues the non updateable attribute
--   (salary_survey_id) has not changed.
--
-- Post Failure:
--   An application error is raised if the non updateable attribute
--   (salary_survey_id) has been altered.
--
-- {End Of Comments}

Procedure chk_non_updateable_args
  (p_rec             in per_ssl_shd.g_rec_type,
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
  if not per_ssl_shd.api_updating
      (p_salary_survey_line_id     => p_rec.salary_survey_line_id
      ,p_object_version_number     => p_rec.object_version_number
      ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if (p_rec.salary_survey_id <> per_ssl_shd.g_old_rec.salary_survey_id) then
     --
     l_argument := 'salary_survey_id';
     --
     raise l_error;
     --
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
    when others then
       raise;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
end chk_non_updateable_args;

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
--   all valid this Procedure will End normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid Then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
Procedure chk_df
  (p_rec in per_ssl_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  If ((p_rec.salary_survey_line_id is not null) and (
     nvl(per_ssl_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)
/*Added for Enhancement 4021737*/
     or
     nvl(per_ssl_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
     nvl(p_rec.attribute21, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
     nvl(p_rec.attribute22, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
     nvl(p_rec.attribute23, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
     nvl(p_rec.attribute24, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
     nvl(p_rec.attribute25, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
     nvl(p_rec.attribute26, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
     nvl(p_rec.attribute27, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
     nvl(p_rec.attribute28, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
     nvl(p_rec.attribute29, hr_api.g_varchar2) or
     nvl(per_ssl_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
     nvl(p_rec.attribute30, hr_api.g_varchar2)))
/*End Enhancement 4021737 */
     or
     (p_rec.salary_survey_line_id is null) Then
    --
    -- Only execute the validation If absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_SALARY_SURVEY_LINES'
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
/*Added for Enhancement 4021737 */
      ,p_attribute21_name   => 'ATTRIBUTE21'
      ,p_attribute21_value  => p_rec.attribute21
      ,p_attribute22_name   => 'ATTRIBUTE22'
      ,p_attribute22_value  => p_rec.attribute22
      ,p_attribute23_name   => 'ATTRIBUTE23'
      ,p_attribute23_value  => p_rec.attribute23
      ,p_attribute24_name   => 'ATTRIBUTE24'
      ,p_attribute24_value  => p_rec.attribute24
      ,p_attribute25_name   => 'ATTRIBUTE25'
      ,p_attribute25_value  => p_rec.attribute25
      ,p_attribute26_name   => 'ATTRIBUTE26'
      ,p_attribute26_value  => p_rec.attribute26
      ,p_attribute27_name   => 'ATTRIBUTE27'
      ,p_attribute27_value  => p_rec.attribute27
      ,p_attribute28_name   => 'ATTRIBUTE28'
      ,p_attribute28_value  => p_rec.attribute28
      ,p_attribute29_name   => 'ATTRIBUTE29'
      ,p_attribute29_value  => p_rec.attribute29
      ,p_attribute30_name   => 'ATTRIBUTE30'
      ,p_attribute30_value  => p_rec.attribute30
/*End Enhancement 4021737 */
      );
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec            in per_ssl_shd.g_rec_type,
                          p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --  Check salary_survey_line_id.
  --
  chk_salary_survey_line_id
  (p_salary_survey_line_id  => p_rec.salary_survey_line_id
   ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 10);
  --
  --  Check SALARY_SURVEY_ID.
  --
  chk_salary_survey_id
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_salary_survey_id      => p_rec.salary_survey_id
  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 15);
  --
  --  Check survey_job_name_code.
  --
  chk_survey_job_name_code
 (p_salary_survey_line_id => p_rec.salary_survey_line_id
 ,p_object_version_number  => p_rec.object_version_number
 ,p_salary_survey_id      => p_rec.salary_survey_id
 ,p_survey_job_name_code   => p_rec.survey_job_name_code
 ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --  Check survey_region_code.
  --
  chk_survey_region_code
 (p_salary_survey_line_id => p_rec.salary_survey_line_id
 ,p_object_version_number  => p_rec.object_version_number
 ,p_salary_survey_id      => p_rec.salary_survey_id
 ,p_survey_region_code     => p_rec.survey_region_code
 ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 25);
  --
  --  Check survey_seniority_code.
  --
  chk_survey_seniority_code
 (p_salary_survey_line_id => p_rec.salary_survey_line_id
 ,p_object_version_number  => p_rec.object_version_number
 ,p_salary_survey_id      => p_rec.salary_survey_id
 ,p_survey_seniority_code  => p_rec.survey_seniority_code
 ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 30);
  --
  --  Check company_size_code.
  --
  chk_company_size_code
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_salary_survey_id      => p_rec.salary_survey_id
  ,p_company_size_code      => p_rec.company_size_code
  ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 35);
  --
  --  Check industry_code.
  --
  chk_industry_code
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_salary_survey_id      => p_rec.salary_survey_id
  ,p_industry_code          => p_rec.industry_code
  ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 40);
  --
  --  Check survey_age_code.
  --
  chk_survey_age_code
  (p_salary_survey_line_id  => p_rec.salary_survey_line_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_salary_survey_id      => p_rec.salary_survey_id
  ,p_survey_age_code        => p_rec.survey_age_code
  ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 43);
  --
  --  Check stck_display_type_code.
  --
  chk_stock_display_type_code
 (p_salary_survey_line_id => p_rec.salary_survey_line_id
 ,p_object_version_number  => p_rec.object_version_number
 ,p_stock_display_type_code   => p_rec.stock_display_type
 ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  --  Check start_date and end_date
  --
  chk_dates
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_start_date             => p_rec.start_date
  ,p_end_date               => p_rec.end_date);
  --
  hr_utility.set_location(l_proc, 45);
  --
  --  Check all Unique Key columns.
  --
  chk_unique_key
 (p_salary_survey_line_id  => p_rec.salary_survey_line_id
 ,p_object_version_number  => p_rec.object_version_number
 ,p_salary_survey_id       => p_rec.salary_survey_id
 ,p_survey_job_name_code   => p_rec.survey_job_name_code
 ,p_survey_region_code     => p_rec.survey_region_code
 ,p_survey_seniority_code  => p_rec.survey_seniority_code
 ,p_company_size_code      => p_rec.company_size_code
 ,p_industry_code          => p_rec.industry_code
 ,p_survey_age_code        => p_rec.survey_age_code
 ,p_start_date             => p_rec.start_date
 ,p_end_date               => p_rec.end_date);
  --
  hr_utility.set_location(l_proc, 50);
  --
  chk_salary_figures
 (p_salary_survey_line_id      => p_rec.salary_survey_line_id
 ,p_object_version_number      => p_rec.object_version_number
 ,p_currency_code              => p_rec.currency_code
 ,p_minimum_pay                => p_rec.minimum_pay
 ,p_mean_pay                   => p_rec.mean_pay
 ,p_maximum_pay                => p_rec.maximum_pay
 ,p_graduate_pay               => p_rec.graduate_pay
 ,p_starting_pay               => p_rec.starting_pay
 ,p_percentage_change          => p_rec.percentage_change
 ,p_job_first_quartile         => p_rec.job_first_quartile
 ,p_job_median_quartile        => p_rec.job_median_quartile
 ,p_job_third_quartile         => p_rec.job_third_quartile
 ,p_job_fourth_quartile        => p_rec.job_fourth_quartile
 ,p_minimum_total_compensation => p_rec.minimum_total_compensation
 ,p_mean_total_compensation    => p_rec.mean_total_compensation
 ,p_maximum_total_compensation => p_rec.maximum_total_compensation
 ,p_compnstn_first_quartile    => p_rec.compnstn_first_quartile
 ,p_compnstn_median_quartile   => p_rec.compnstn_median_quartile
 ,p_compnstn_third_quartile    => p_rec.compnstn_third_quartile
 ,p_compnstn_fourth_quartile   => p_rec.compnstn_fourth_quartile
 );
  --
  hr_utility.set_location(l_proc, 55);
  --
  chk_currency_code
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_currency_code         => p_rec.currency_code
  );
  --
  hr_utility.set_location(l_proc, 60);
  -- Call descriptive flexfield validation routines
  --
  per_ssl_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 65);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec            in per_ssl_shd.g_rec_type,
                          p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --   Check for non updateable arguments.
  --
  chk_non_updateable_args
    (p_rec => p_rec
    ,p_effective_date => p_effective_date
    );
  --
  hr_utility.set_location(l_proc, 7);
  --
  --
  --  Check salary_survey_line_id.
  --
  chk_salary_survey_line_id
 (p_salary_survey_line_id => p_rec.salary_survey_line_id
 ,p_object_version_number    => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 10);
  --
  --  Check job_name_code.
  --
  chk_survey_job_name_code
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_salary_survey_id      => p_rec.salary_survey_id
  ,p_survey_job_name_code   => p_rec.survey_job_name_code
  ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  --  Check survey_region_code.
  --
  chk_survey_region_code
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_salary_survey_id      => p_rec.salary_survey_id
  ,p_survey_region_code     => p_rec.survey_region_code
  ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 25);
  --
  --  Check survey_seniority_code.
  --
  chk_survey_seniority_code
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_salary_survey_id      => p_rec.salary_survey_id
  ,p_survey_seniority_code  => p_rec.survey_seniority_code
  ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 30);
  --
  --  Check company_size_code.
  --
  chk_company_size_code
 (p_salary_survey_line_id => p_rec.salary_survey_line_id
 ,p_object_version_number  => p_rec.object_version_number
 ,p_salary_survey_id      => p_rec.salary_survey_id
 ,p_company_size_code      => p_rec.company_size_code
 ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 35);
  --
  chk_industry_code
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_salary_survey_id      => p_rec.salary_survey_id
  ,p_industry_code          => p_rec.industry_code
  ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 40);
  --
  --  Check survey_age_code.
  --
  chk_survey_age_code
  (p_salary_survey_line_id  => p_rec.salary_survey_line_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_salary_survey_id      => p_rec.salary_survey_id
  ,p_survey_age_code        => p_rec.survey_age_code
  ,p_effective_date         => p_effective_date);
  --
  hr_utility.set_location(l_proc, 43);
  --
  -- Check Stock Display Type Code
  --
  chk_stock_display_type_code
 (p_salary_survey_line_id => p_rec.salary_survey_line_id
 ,p_object_version_number  => p_rec.object_version_number
 ,p_stock_display_type_code   => p_rec.stock_display_type
 ,p_effective_date         => p_effective_date);
  --
  -- Check start_date and end_date.
  --
  chk_dates
  (p_salary_survey_line_id  => p_rec.salary_survey_line_id
  ,p_start_date             => p_rec.start_date
  ,p_end_date               => p_rec.end_date);
  --
  hr_utility.set_location(l_proc, 45);
  --
  --  Check all Unique Key columns.
  --
  chk_unique_key
 (p_salary_survey_line_id  => p_rec.salary_survey_line_id
 ,p_object_version_number  => p_rec.object_version_number
 ,p_salary_survey_id       => p_rec.salary_survey_id
 ,p_survey_job_name_code   => p_rec.survey_job_name_code
 ,p_survey_region_code     => p_rec.survey_region_code
 ,p_survey_seniority_code  => p_rec.survey_seniority_code
 ,p_company_size_code      => p_rec.company_size_code
 ,p_industry_code          => p_rec.industry_code
 ,p_survey_age_code        => p_rec.survey_age_code
 ,p_start_date             => p_rec.start_date
 ,p_end_date               => p_rec.end_date);
  --
  hr_utility.set_location(l_proc, 50);
  --
 chk_salary_figures
(p_salary_survey_line_id       => p_rec.salary_survey_line_id
 ,p_object_version_number      => p_rec.object_version_number
 ,p_currency_code              => p_rec.currency_code
 ,p_minimum_pay                => p_rec.minimum_pay
 ,p_mean_pay                   => p_rec.mean_pay
 ,p_maximum_pay                => p_rec.maximum_pay
 ,p_graduate_pay               => p_rec.graduate_pay
 ,p_starting_pay               => p_rec.starting_pay
 ,p_percentage_change          => p_rec.percentage_change
 ,p_job_first_quartile         => p_rec.job_first_quartile
 ,p_job_median_quartile        => p_rec.job_median_quartile
 ,p_job_third_quartile         => p_rec.job_third_quartile
 ,p_job_fourth_quartile        => p_rec.job_fourth_quartile
 ,p_minimum_total_compensation => p_rec.minimum_total_compensation
 ,p_mean_total_compensation    => p_rec.mean_total_compensation
 ,p_maximum_total_compensation => p_rec.maximum_total_compensation
 ,p_compnstn_first_quartile    => p_rec.compnstn_first_quartile
 ,p_compnstn_median_quartile   => p_rec.compnstn_median_quartile
 ,p_compnstn_third_quartile    => p_rec.compnstn_third_quartile
 ,p_compnstn_fourth_quartile   => p_rec.compnstn_fourth_quartile
 );
  --
  hr_utility.set_location(l_proc, 55);
  --
  chk_currency_code
  (p_salary_survey_line_id => p_rec.salary_survey_line_id
  ,p_currency_code    => p_rec.currency_code
  );
  --
  hr_utility.set_location(l_proc, 60);
  --
  --  -- Call descriptive flexfield validation routines
  --
  per_ssl_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location('Leaving:'||l_proc, 65);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_ssl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --  Check that the Survey row is not mapped to a Job or Position.
  --
  chk_delete(p_salary_survey_line_id => p_rec.salary_survey_line_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End delete_validate;
--
End per_ssl_bus;

/
