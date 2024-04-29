--------------------------------------------------------
--  DDL for Package Body PER_SSM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSM_BUS" as
/* $Header: pessmrhi.pkb 120.0 2005/05/31 21:50:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package                  varchar2(33)	 := '  per_ssm_bus.';  -- Global package name
g_salary_survey_mapping_id number        default null;
g_legislation_code         varchar2(150) default null;
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_legislation_code >-----------------------|
-- ----------------------------------------------------------------------------
Function return_legislation_code( p_salary_survey_mapping_id in number )
                                  return varchar2 is
--
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
         select pbg.legislation_code
         from   per_business_groups pbg,
                per_salary_survey_mappings ssm
         where  ssm.salary_survey_mapping_id = p_salary_survey_mapping_id
         and    pbg.business_group_id = ssm.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code varchar2(150);
  l_proc             varchar2(72) := g_package||'return_legislation_code';
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error(p_api_name         => l_proc
                            ,p_argument        => 'salary_survey_mapping_id'
                            ,p_argument_value   => p_salary_survey_mapping_id
                            );
  --
  if nvl( g_salary_survey_mapping_id, hr_api.g_number ) = p_salary_survey_mapping_id
then
     --
     -- The legislation has already been found with a previous call to this
     -- function. Just return the value in the global variable.
     --
     l_legislation_code := g_legislation_code;
     hr_utility.set_location('Entering:'||l_proc, 6);
  else
     open csr_leg_code;
     fetch csr_leg_code into l_legislation_code;
     if csr_leg_code%notfound then
        close csr_leg_code;
        fnd_message.set_name('PER','PER_52479_SSM_INVL_SSM_ID');
        fnd_message.raise_error;
     end if;
     hr_utility.set_location('Entering:'||l_proc, 7);
     close csr_leg_code;
     g_salary_survey_mapping_id := p_salary_survey_mapping_id;
     g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  return l_legislation_code;
End return_legislation_code;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args(p_rec in per_ssm_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_ssm_shd.api_updating
                (p_salary_survey_mapping_id    => p_rec.salary_survey_mapping_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_ssm_shd.g_old_rec.business_group_id, hr_api.g_number) then
     l_argument := 'business_group_id';
     raise l_error;
  elsif nvl(p_rec.salary_survey_line_id, hr_api.g_number) <>
        nvl(per_ssm_shd.g_old_rec.salary_survey_line_id, hr_api.g_number) then
     l_argument := 'salary_survey_line_id';
     raise l_error;
  elsif nvl(p_rec.parent_id, hr_api.g_number) <>
        nvl(per_ssm_shd.g_old_rec.parent_id, hr_api.g_number) then
     l_argument := 'parent_id';
     raise l_error;
  elsif nvl(p_rec.parent_table_name, hr_api.g_varchar2) <>
        nvl(per_ssm_shd.g_old_rec.parent_table_name, hr_api.g_varchar2) then
     l_argument := 'parent_table_name';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 11);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end chk_non_updateable_args;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< get_salary_survey_line_start >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure returns the start date of the salary survey line referenced.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_line_id ID of FK column
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
Function get_salary_survey_line_start
 (p_salary_survey_line_id    in number)
 return date is
  --
  l_proc         varchar2(72) := g_package||'get_salary_survey_line_start';
  l_start_date   date;
  --
  cursor csr_get_dates is
    select start_date
    from   per_salary_survey_lines ssl
    where  ssl.salary_survey_line_id = p_salary_survey_line_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open csr_get_dates;
  --
  fetch csr_get_dates into l_start_date;
  --
  return l_start_date;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End get_salary_survey_line_start;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_salary_survey_line_end >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure returns the end date of the salary survey line referenced.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_line_id ID of FK column
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
--   Processing stops and an error is raised If the foreign key does not
--   exist in the referenced table.
--
-- Access Status
--   Internal row handler use only.
--
Function get_salary_survey_line_end
 (p_salary_survey_line_id    in number)
 return date is
  --
  l_proc         varchar2(72) := g_package||'get_salary_survey_line_end';
  l_end_date   date;
  --
  cursor csr_get_dates is
    select nvl(end_date,hr_api.g_eot)
    from   per_salary_survey_lines ssl
    where  ssl.salary_survey_line_id = p_salary_survey_line_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  open csr_get_dates;
  --
  fetch csr_get_dates into l_end_date;
  --
  return l_end_date;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End get_salary_survey_line_end;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_salary_survey_line_id >------------------------|
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
--   p_salary_survey_mapping_id PK
--   p_salary_survey_line_id ID of FK column
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
Procedure chk_salary_survey_line_id
(p_salary_survey_mapping_id in number,
 p_salary_survey_line_id    in number,
 p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_salary_survey_line_id';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor csr_chk_survey_line_exists is
    select 'Y'
    from   per_salary_survey_lines ssl
    where  ssl.salary_survey_line_id = p_salary_survey_line_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  --    Check mandatory parameters have been set
  --
  --hr_api.mandatory_arg_error
  --  (p_api_name         => l_proc
  --  ,p_argument         => 'salary_survey_line_id'
  --  ,p_argument_value   => p_salary_survey_line_id
  --  );
  --
  hr_utility.set_location(l_proc,6);
  --
  l_api_updating := per_ssm_shd.api_updating
     (p_salary_survey_mapping_id  => p_salary_survey_mapping_id,
      p_object_version_number   => p_object_version_number);
  --
  If not l_api_updating and p_salary_survey_line_id is null then
     -- Mandatory column is null
     --
     fnd_message.set_name('PER','PER_52478_SSM_LINE_ID_NULL');
     fnd_message.raise_error;
     --
  Elsif not l_api_updating and p_salary_survey_line_id is not null then
     --
     -- check If salary_survey_line_id value exists in
     -- per_salary_survey_lines table
     --
     open csr_chk_survey_line_exists;
     --
     fetch csr_chk_survey_line_exists into l_exists;
     --
     If csr_chk_survey_line_exists%notfound Then
        --
        close csr_chk_survey_line_exists;
        --
        -- raise error as FK does not relate to PK in per_salary_survey_lines
        -- table.
        --
        per_ssm_shd.constraint_error('PER_SALARY_SURVEY_MAPPINGS_FK1');
        --
      End If;
      --
    close csr_chk_survey_line_exists;
    --
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_salary_survey_line_id;
--

-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_parent >-------------------------------|
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
--   p_salary_survey_mapping_id PK
--   p_parent_id ID of FK column in table p_parent_table_name
--   p_parent_table_name is the name of the table for which parent_id is the PK
--   p_business_group_id is the business group ID of the salary survey mapping
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
Procedure chk_parent
(p_salary_survey_mapping_id in number,
 p_parent_id                in number,
 p_parent_table_name        in varchar2,
 p_business_group_id        in number,
 p_object_version_number    in number,
 p_ssl_start_date	    in date,
 p_ssl_end_date             in date) is
  --
  l_proc         	varchar2(72) := g_package||'chk_parent';
  l_api_updating 	boolean;
  l_business_group_id 	per_business_groups.business_group_id%TYPE;
  l_parent_start_date   date;
  l_parent_end_date     date;
  --
  cursor csr_chk_job_id_exists is
    select j.business_group_id, date_from, nvl(date_to,hr_api.g_eot)
    from   per_jobs j
    where  j.job_id = p_parent_id;
  --
  -- Changed 13-Oct-99 SCNair (per_positions to hr_positions_f) Date tracked position req
  --
  cursor csr_chk_position_id_exists is
    select p.business_group_id,date_effective,
           nvl(hr_general.get_position_date_end(p.position_id),hr_general.end_of_time)
    from   hr_positions_f p
    where p.position_id = p_parent_id
    and effective_end_date = hr_general.end_of_time;
  --
  -- Added as part of enhancement 4021737.
  cursor csr_chk_assignment_id_exists is
    select p.business_group_id,effective_start_date,
          effective_end_date
    from  per_all_assignments_f  p
    where p.assignment_id = p_parent_id
    and effective_end_date = hr_general.end_of_time;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  --    Check mandatory parameters have been set
  --
--  hr_api.mandatory_arg_error
--    (p_api_name         => l_proc
--    ,p_argument         => 'parent_id'
--    ,p_argument_value   => p_parent_id
--    );
--  hr_api.mandatory_arg_error
--    (p_api_name         => l_proc
--    ,p_argument         => 'parent_table_name'
--    ,p_argument_value   => p_parent_table_name
--    );
  --
  hr_utility.set_location(l_proc,6);
  --
  l_api_updating := per_ssm_shd.api_updating
     (p_salary_survey_mapping_id  => p_salary_survey_mapping_id,
      p_object_version_number   => p_object_version_number);
  --
    hr_utility.set_location(l_proc,7);
    --
    If l_api_updating and
      (nvl(p_parent_id,hr_api.g_number)
     <> nvl(per_ssm_shd.g_old_rec.parent_id,hr_api.g_number)
     or nvl(p_parent_table_name,hr_api.g_varchar2)
     <> nvl(per_ssm_shd.g_old_rec.parent_table_name,hr_api.g_varchar2)) then
       --
       hr_utility.set_location(l_proc,8);
       --
       -- Trying to update parent_id or parent_table_name.
       fnd_message.set_name('PER','PER_52480_SSM_NON_UPD_FIELD');
       fnd_message.raise_error;
    Elsif not l_api_updating then
      --
      hr_utility.set_location(l_proc,9);
      --
      If p_parent_id is null then
	--
	hr_utility.set_location(l_proc,15);
        fnd_message.set_name('PER','PER_52481_SSM_NO_PARENT_ID');
        fnd_message.raise_error;
      Elsif p_parent_table_name is null then
	--
	hr_utility.set_location(l_proc,20);
	--
        fnd_message.set_name('PER','PER_52482_SSM_NO_PRNT_TBL_NAME');
        fnd_message.raise_error;
      Else
	--
        hr_utility.set_location(l_proc,25);
	--
        If p_parent_table_name = 'PER_JOBS' then
	   --
	   hr_utility.set_location(l_proc,30);
	   --
           open csr_chk_job_id_exists;
           fetch csr_chk_job_id_exists into l_business_group_id,l_parent_start_date,l_parent_end_date;
           If csr_chk_job_id_exists%notfound Then
	      --
	      hr_utility.set_location(l_proc,35);
              --
              close  csr_chk_job_id_exists;
              --
              -- raise error as FK does not relate to PK in per_jobs
              -- table.
              --
              fnd_message.set_name('PER','PER_52483_SSM_INVL_JOB_ID');
              fnd_message.raise_error;
           Elsif l_business_group_id <> p_business_group_id then
	      --
	      hr_utility.set_location(l_proc,40);
              close  csr_chk_job_id_exists;
              fnd_message.set_name('PER','PER_52484_SSM_INVL_JOB_BG');
              fnd_message.raise_error;
              --
           Elsif (p_ssl_start_date > l_parent_end_date) or
              (p_ssl_end_date < l_parent_start_date) then
	      --
              hr_utility.set_location(l_proc,42);
              close  csr_chk_job_id_exists;
              fnd_message.set_name('PER','PER_52485_SSM_JOB_DATE_INVL');
              fnd_message.raise_error;
           Else
	      --
	      hr_utility.set_location(l_proc,45);
	      --
              close  csr_chk_job_id_exists;
           End if;
        --
        Elsif  p_parent_table_name = 'PER_POSITIONS' then
	   --
	   hr_utility.set_location(l_proc,50);
	   --
           open csr_chk_position_id_exists;
	   --
           fetch csr_chk_position_id_exists into l_business_group_id,l_parent_start_date,l_parent_end_date;
           If csr_chk_position_id_exists%notfound Then
	      --
	      hr_utility.set_location(l_proc,55);
              --
              close  csr_chk_position_id_exists;
              --
              -- raise error as FK does not relate to PK in per_jobs
              -- table.
              --
              fnd_message.set_name('PER','PER_52486_SSM_INVL_POS_ID');
              fnd_message.raise_error;
           Elsif l_business_group_id <> p_business_group_id then
	      --
	      hr_utility.set_location(l_proc,60);
	      --
              close  csr_chk_position_id_exists;
              fnd_message.set_name('PER','PER_52487_SSM_INVL_POS_BG');
              fnd_message.raise_error;
	      --
           Elsif (p_ssl_start_date > nvl(l_parent_end_date,hr_api.g_eot)) or
               (nvl(p_ssl_end_date,hr_api.g_eot)< l_parent_start_date) then

              --
              hr_utility.set_location(l_proc,62);
hr_utility.set_location('SSL start '||to_char(p_ssl_start_date,'DD-MON-YYYY'),62);
hr_utility.set_location('SSL end '||to_char(p_ssl_end_date,'DD-MON-YYYY'),62);
hr_utility.set_location('parent start '||to_char(l_parent_start_date,'DD-MON-YYYY'),62);
hr_utility.set_location('parent end '||to_char(l_parent_end_date,'DD-MON-YYYY'),62);
              close  csr_chk_position_id_exists;
              fnd_message.set_name('PER','PER_52488_SSM_POS_DATE_INVL');
              fnd_message.raise_error;
           Else
	      --
	      hr_utility.set_location(l_proc,65);
	      --
              close  csr_chk_position_id_exists;
           End if;
        Elsif  p_parent_table_name = 'PER_ASSIGNMENTS' then
           --
           hr_utility.set_location(l_proc,50);
           --
           open csr_chk_assignment_id_exists;
           --
           fetch csr_chk_assignment_id_exists into l_business_group_id,l_parent_start_date,l_parent_end_date;
           If csr_chk_assignment_id_exists%notfound Then
              --
              hr_utility.set_location(l_proc,55);
              --
              close  csr_chk_assignment_id_exists;
              --
              -- raise error as FK does not relate to PK in per_jobs
              -- table.
              --
              fnd_message.set_name('PER','PER_SSM_INVL_ASG_ID');
              fnd_message.raise_error;
           Elsif l_business_group_id <> p_business_group_id then
              --
              hr_utility.set_location(l_proc,60);
              --
              close  csr_chk_assignment_id_exists;
              fnd_message.set_name('PER','PER_SSM_INVL_ASG_BG');
              fnd_message.raise_error;
              --
           Elsif (p_ssl_start_date > nvl(l_parent_end_date,hr_api.g_eot)) or
               (nvl(p_ssl_end_date,hr_api.g_eot)< l_parent_start_date) then

              --
              hr_utility.set_location(l_proc,62);
hr_utility.set_location('SSL start '||to_char(p_ssl_start_date,'DD-MON-YYYY'),62);
hr_utility.set_location('SSL end '||to_char(p_ssl_end_date,'DD-MON-YYYY'),62);
hr_utility.set_location('parent start '||to_char(l_parent_start_date,'DD-MON-YYYY'),62);
hr_utility.set_location('parent end '||to_char(l_parent_end_date,'DD-MON-YYYY'),62);
              close  csr_chk_position_id_exists;
              fnd_message.set_name('PER','PER_SSM_ASG_DATE_INVL');
              fnd_message.raise_error;
           Else
              --
              hr_utility.set_location(l_proc,65);
              --
              close  csr_chk_assignment_id_exists;
           End if;
        Else

	   --
	   hr_utility.set_location(l_proc,70);
	   --
           -- Invalid parent_table_name.
	   fnd_message.set_name('PER','PER_52489_SSM_INVL_TBL_NAME');
	   fnd_message.raise_error;
        End If;
     End If;
    End If;
     --
  --
  hr_utility.set_location('Leaving:'||l_proc,150);
  --
End chk_parent;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_key >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure is used to check that salary_survey_line_id,
--   parent_table_name and the parent_table_id are in a unique combination
--   compared to other rows in the table per_salary_survey_mappings.
--
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_mapping_id PK
--   p_parent_id ID of FK column in table p_parent_table_name
--   p_parent_table_name is the name of the table for which parent_id is the PK
--   p_salary_survey_line_id is the salary survey line ID of the salary survey
--   mapping
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the salary_survey_line_id, parent_table_name
--   and the parent_table_id are in a unique combination compared to
--   other rows in the table per_salary_survey_mappings.
--
-- Post Failure
--   Processing stops and an error is raised if the unique key validation
--   is breeched.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_unique_key
(p_salary_survey_mapping_id in number,
 p_parent_id                in number,
 p_parent_table_name        in varchar2,
 p_salary_survey_line_id    in number,
 p_grade_id		    in number,
 p_location_id		    in number,
 p_company_organization_id  in number,
 p_company_age_code	    in varchar2,
 p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_unique_key';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor csr_chk_unique_key is
    select 'Y'
    from   per_salary_survey_mappings ssm
    where  ssm.parent_id = p_parent_id
    and    ssm.parent_table_name = p_parent_table_name
    and    ssm.salary_survey_line_id = p_salary_survey_line_id
    and    ssm.grade_id = p_grade_id
    and    ssm.location_id = p_location_id
    and    ssm.company_organization_id = p_company_organization_id
    and    ssm.company_age_code = p_company_age_code;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  --    Check mandatory parameters have been set
  --
  hr_utility.set_location(l_proc,6);
  --
  l_api_updating := per_ssm_shd.api_updating
     (p_salary_survey_mapping_id  => p_salary_survey_mapping_id,
      p_object_version_number   => p_object_version_number);
  --
  hr_utility.set_location(l_proc,8);
  --
  If not l_api_updating then
     open csr_chk_unique_key;
     fetch csr_chk_unique_key into l_exists;
     If csr_chk_unique_key%found Then
        close csr_chk_unique_key;
	per_ssm_shd.constraint_error('PER_SALARY_SURVEY_MAPPINGS_UK');
     Else
        close csr_chk_unique_key;
     End If;
  End If;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_unique_key;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_location_id >-----------------------------|
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
--   p_salary_survey_mapping_id PK
--   p_location_id ID of FK column
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
Procedure chk_location_id
(p_salary_survey_mapping_id in number,
 p_location_id              in number,
 p_object_version_number    in number,
 p_ssl_start_date           in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_location_id';
  l_api_updating boolean;
  l_loc_date_to  date;
  --
  cursor csr_chk_location_exists is
    select inactive_date
    from   hr_locations loc
    where  loc.location_id = p_location_id and loc.location_use = 'HR'
    ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  --    Check mandatory parameters have been set
  --
  --
  --
  If p_location_id is not null then
     open csr_chk_location_exists;
     fetch csr_chk_location_exists into l_loc_date_to;
     If csr_chk_location_exists%notfound then
        --
        hr_utility.set_location('Entering:'||l_proc,6);
        --
        close csr_chk_location_exists;
        --
        -- raise error as FK does not relate to PK in hr_locations
        -- table.
        --
        per_ssm_shd.constraint_error('PER_SALARY_SURVEY_MAPPINGS_FK2');
        --
     Elsif l_loc_date_to < p_ssl_start_date then
        --
        close csr_chk_location_exists;
        --
        fnd_message.set_name('PER','PER_52490_SSM_LOC_DATE_INVL');
        fnd_message.raise_error;
        --
     Else
        --
        hr_utility.set_location('Entering:'||l_proc,7);
        --
        close csr_chk_location_exists;
     End If;
  End if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_location_id;
--
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_grade_id >------------------------------|
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
--   p_salary_survey_mapping_id PK
--   p_grade_id ID of FK column
--   p_business_group_id the business group ID of the salary survey mapping
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
Procedure chk_grade_id
(p_salary_survey_mapping_id in number,
 p_grade_id                 in number,
 p_business_group_id        in number,
 p_object_version_number    in number,
 p_ssl_start_date	    in date,
 p_ssl_end_date             in date) is
  --
  l_proc              varchar2(72) := g_package||'chk_grade_id';
  l_api_updating      boolean;
  l_exists            varchar2(1);
  l_grade_id          number(15);
  l_business_group_id number(15);
  l_grade_date_from   date;
  l_grade_date_to     date;
  l_bg		      number(15);
  --
  cursor csr_chk_grade_exists is
    select g.business_group_id, g.date_from, nvl(g.date_to,hr_api.g_eot)
    from   per_grades g
    where  g.grade_id = p_grade_id;
  --
  cursor csr_get_bg is
    select business_group_id
    from per_salary_survey_mappings
    where salary_survey_mapping_id = p_salary_survey_mapping_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_ssm_shd.api_updating
                (p_salary_survey_mapping_id => p_salary_survey_mapping_id
                ,p_object_version_number    => p_object_version_number
                );
  --
  If l_api_updating then
     open csr_get_bg;
     fetch csr_get_bg into l_bg;
     close csr_get_bg;
  Else
     l_bg := p_business_group_id;
  End If;
  If p_grade_id is not null then
     open csr_chk_grade_exists;
     fetch csr_chk_grade_exists into l_business_group_id, l_grade_date_from, l_grade_date_to;
     If csr_chk_grade_exists%notfound then
        close csr_chk_grade_exists;
        --
        -- raise error as FK does not relate to PK in per_grades
        -- table.
        --
        per_ssm_shd.constraint_error('PER_SALARY_SURVEY_MAPPINGS_FK3');
        --
--     Elsif l_business_group_id <> p_business_group_id then
     Elsif l_business_group_id <> l_bg then
        close csr_chk_grade_exists;
        --
        fnd_message.set_name('PER','PER_52491_SSM_INVL_GRD_BG');
        fnd_message.raise_error;
     Elsif (p_ssl_start_date > nvl(l_grade_date_to,hr_api.g_eot)
         or nvl(p_ssl_end_date,hr_api.g_eot) < l_grade_date_from) then

        close csr_chk_grade_exists;
        --
        fnd_message.set_name('PER','PER_52492_SSM_GRD_DATE_INVL');
        fnd_message.raise_error;
        --
     Else
        close csr_chk_grade_exists;
     End If;
  End If;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_grade_id;
--
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_company_organization_id >-----------------------|
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
--   p_salary_survey_mapping_id PK
--   p_company_organization_id ID of FK column
--   p_business_group_id the business group ID of the salary survey mapping
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
Procedure chk_company_organization_id
(p_salary_survey_mapping_id in number,
 p_company_organization_id  in number,
 p_business_group_id        in number,
 p_object_version_number    in number,
 p_ssl_start_date	    in date,
 p_ssl_end_date             in date) is
  --
  l_proc              varchar2(72) := g_package||'chk_company_organization_id';
  l_api_updating      boolean;
  l_business_group_id number;
  l_org_date_from     date;
  l_org_date_to       date;
  l_bg		      number;
  --
  cursor csr_chk_company_org is
    select o.business_group_id, o.date_from, nvl(o.date_to,hr_api.g_eot)
    from   hr_all_organization_units o
    where  o.organization_id = p_company_organization_id;
  --
  cursor csr_get_bg is
    select business_group_id
    from per_salary_survey_mappings
    where salary_survey_mapping_id = p_salary_survey_mapping_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_ssm_shd.api_updating
                (p_salary_survey_mapping_id => p_salary_survey_mapping_id
                ,p_object_version_number    => p_object_version_number
                );
  --
  If l_api_updating then
     open csr_get_bg;
     fetch csr_get_bg into l_bg;
     close csr_get_bg;
  Else
     l_bg := p_business_group_id;
  End If;
  --
  If p_company_organization_id is not null then
     hr_utility.set_location(l_proc,10);
     open csr_chk_company_org;
     fetch csr_chk_company_org into l_business_group_id, l_org_date_from, l_org_date_to;
     If csr_chk_company_org%notfound then
	hr_utility.set_location(l_proc,25);
        close csr_chk_company_org;
        --
        -- raise error as FK does not relate to PK in hr_all_organization_units
        -- table.
        --
        per_ssm_shd.constraint_error('PER_SALARY_SURVEY_MAPPINGS_FK5');
        --
--     Elsif l_business_group_id <> p_business_group_id then
     Elsif l_business_group_id <> l_bg then
	hr_utility.set_location(l_proc,30);
        close csr_chk_company_org;
        --
        fnd_message.set_name('PER','PER_52493_SSM_INVL_ORG_BG');
        fnd_message.raise_error;
     Elsif p_ssl_end_date < l_org_date_from
	   or p_ssl_start_date > l_org_date_to then
	hr_utility.set_location(l_proc,32);
        close csr_chk_company_org;
        --
        fnd_message.set_name('PER','PER_52494_SSM_ORG_DATE_INVL');
        fnd_message.raise_error;
	--
     Else
	hr_utility.set_location(l_proc,35);
        close csr_chk_company_org;
     End If;
  End If;
  hr_utility.set_location('Leaving:'||l_proc,50);
  --
End chk_company_organization_id;
--
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_company_age_code >--------------------------|
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
--   p_salary_survey_mapping_id PK
--   p_company_age_code code for lookup in hr_lookups
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the lookup exists in the lookup table.
--
-- Post Failure
--   Processing stops and an error is raised If the lookup does not
--   exist in the lookup table.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_company_age_code
(p_salary_survey_mapping_id in number,
 p_company_age_code         in varchar2,
 p_effective_date	    in date,
 p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_company_age_code';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor csr_chk_company_age_exists is
    select 'Y'
    from   hr_lookups l
    where  l.lookup_code = p_company_age_code
    and    l.lookup_type = 'COMPANY_AGE'
    and    l.enabled_flag = 'Y';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  If p_company_age_code is not null then
     open csr_chk_company_age_exists;
     fetch csr_chk_company_age_exists into l_exists;
     If csr_chk_company_age_exists%notfound then
        close csr_chk_company_age_exists;
        --
        -- raise error as FK does not relate to PK in hr_all_organization_units
        -- table.
        --
        -- per_ssm_shd.constraint_error('PER_SALARY_SURVEY_MAPPINGS_FK');
        fnd_message.set_name('PER','PER_52495_SSM_AGE_DATE_INVL');
	fnd_message.raise_error;
        --
     Else
        close csr_chk_company_age_exists;
     End If;
  End If;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_company_age_code;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_effective_date >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This Procedure checks that the effective date is not null and is valid
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_salary_survey_mapping_id PK
--   p_effective_date
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues If the effective_date is valid
--
-- Post Failure
--   Processing stops and an error is raised.
--
-- Access Status
--   Internal row handler use only.
--
Procedure chk_effective_date
(p_effective_date           in date) is
  --
  l_proc           varchar2(72) := g_package||'chk_effective_date';
  l_api_updating   boolean;
  l_exists         varchar2(1);
  l_effective_date date;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_effective_date := p_effective_date;
  --
  If l_effective_date is not null then
     hr_api.mandatory_arg_error
       (p_api_name         => l_proc
       ,p_argument         => 'effective_date'
       ,p_argument_value   => l_effective_date
       );
  Else
     fnd_message.set_name('PER','PER_52496_SSM_EFF_DATE_NULL');
     fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_effective_date;
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
  (p_rec in per_ssm_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  If ((p_rec.salary_survey_mapping_id is not null) and (
     nvl(per_ssm_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_ssm_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.salary_survey_mapping_id is null) Then
    --
    -- Only execute the validation If absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_SALARY_SURVEY_MAPPINGS'
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
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_df;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec            in per_ssm_shd.g_rec_type
			 ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_ssl_start_date date;
  l_ssl_end_date date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(l_proc, 6);
  --
  chk_unique_key( p_salary_survey_mapping_id  => p_rec.salary_survey_mapping_id
                , p_parent_id		      => p_rec.parent_id
                , p_parent_table_name	      => p_rec.parent_table_name
                , p_salary_survey_line_id     => p_rec.salary_survey_line_id
		, p_grade_id		      => p_rec.grade_id
		, p_location_id		      => p_rec.location_id
		, p_company_organization_id   => p_rec.company_organization_id
		, p_company_age_code	      => p_rec.company_age_code
                , p_object_version_number     => p_rec.object_version_number
                );
  --
  hr_utility.set_location(l_proc, 7);
  --
  chk_salary_survey_line_id( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
                           , p_salary_survey_line_id     => p_rec.salary_survey_line_id
                	   , p_object_version_number     => p_rec.object_version_number
                	   );
  --
  l_ssl_start_date := get_salary_survey_line_start( p_salary_survey_line_id     => p_rec.salary_survey_line_id);
  --
  l_ssl_end_date := get_salary_survey_line_end( p_salary_survey_line_id     => p_rec.salary_survey_line_id);
  hr_utility.set_location(l_proc, 8);
  --
  chk_parent( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
            , p_parent_id		  => p_rec.parent_id
            , p_parent_table_name	  => p_rec.parent_table_name
            , p_business_group_id	  => p_rec.business_group_id
            , p_object_version_number     => p_rec.object_version_number
	    , p_ssl_start_date		  => l_ssl_start_date
            , p_ssl_end_date		  => l_ssl_end_date
            );
  --
  hr_utility.set_location(l_proc, 9);
  --
  chk_location_id( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
                 , p_location_id	       => p_rec.location_id
                 , p_object_version_number     => p_rec.object_version_number
                 , p_ssl_start_date            => l_ssl_start_date
                 );
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_grade_id( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
              , p_grade_id		    => p_rec.grade_id
              , p_business_group_id	    => p_rec.business_group_id
              , p_object_version_number     => p_rec.object_version_number
	      , p_ssl_start_date  	    => l_ssl_start_date
              , p_ssl_end_date              => l_ssl_end_date
              );
  --
  hr_utility.set_location(l_proc, 11);
  --
  chk_company_organization_id( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
              		     , p_company_organization_id  => p_rec.company_organization_id
              		     , p_business_group_id	  => p_rec.business_group_id
              		     , p_object_version_number    => p_rec.object_version_number
	                     , p_ssl_start_date		  => l_ssl_start_date
    	 	             , p_ssl_end_date              => l_ssl_end_date
              		     );
  --
  hr_utility.set_location(l_proc, 12);
  --
  chk_company_age_code
      ( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
      , p_company_age_code	   => p_rec.company_age_code
      , p_effective_date	   => p_effective_date
      , p_object_version_number    => p_rec.object_version_number
              );
  --
  hr_utility.set_location(l_proc, 13);
  --
  chk_effective_date(p_effective_date => p_effective_date);
  --
  -- chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End insert_validate;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec            in per_ssm_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_ssl_start_date date;
  l_ssl_end_date date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Check that non updateable arguments have not bee updated.
  --
  chk_non_updateable_args(p_rec);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  hr_utility.set_location(l_proc, 6);
  --
  chk_unique_key( p_salary_survey_mapping_id  => p_rec.salary_survey_mapping_id
                , p_parent_id                 => p_rec.parent_id
                , p_parent_table_name         => p_rec.parent_table_name
                , p_salary_survey_line_id     => p_rec.salary_survey_line_id
                , p_grade_id                  => p_rec.grade_id
                , p_location_id               => p_rec.location_id
                , p_company_organization_id   => p_rec.company_organization_id
                , p_company_age_code          => p_rec.company_age_code
                , p_object_version_number     => p_rec.object_version_number
                );
  --
  hr_utility.set_location(l_proc, 7);
  --
  chk_salary_survey_line_id( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
                           , p_salary_survey_line_id     => p_rec.salary_survey_line_id
                	   , p_object_version_number     => p_rec.object_version_number
                	   );
  --
  l_ssl_start_date := get_salary_survey_line_start( p_salary_survey_line_id     => p_rec.salary_survey_line_id);
  --
  l_ssl_end_date := get_salary_survey_line_end( p_salary_survey_line_id     => p_rec.salary_survey_line_id);
  --
  hr_utility.set_location(l_proc, 8);
  --
  chk_parent( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
            , p_parent_id		  => p_rec.parent_id
            , p_parent_table_name	  => p_rec.parent_table_name
            , p_business_group_id	  => p_rec.business_group_id
            , p_object_version_number     => p_rec.object_version_number
            , p_ssl_start_date            => l_ssl_start_date
            , p_ssl_end_date              => l_ssl_end_date
            );
  --
  hr_utility.set_location(l_proc, 9);
  --
  chk_location_id( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
                 , p_location_id	       => p_rec.location_id
                 , p_object_version_number     => p_rec.object_version_number
                 , p_ssl_start_date            => l_ssl_start_date
                 );
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_grade_id( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
              , p_grade_id		    => p_rec.grade_id
              , p_business_group_id	    => p_rec.business_group_id
              , p_object_version_number     => p_rec.object_version_number
              , p_ssl_start_date            => l_ssl_start_date
              , p_ssl_end_date              => l_ssl_end_date
              );
  --
  hr_utility.set_location(l_proc, 11);
  --
  chk_company_organization_id
    ( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
    , p_company_organization_id  => p_rec.company_organization_id
    , p_business_group_id	 => p_rec.business_group_id
    , p_object_version_number    => p_rec.object_version_number
    , p_ssl_start_date           => l_ssl_start_date
    , p_ssl_end_date              => l_ssl_end_date
    );
  --
  hr_utility.set_location(l_proc, 12);
  --
  chk_company_age_code
    ( p_salary_survey_mapping_id => p_rec.salary_survey_mapping_id
    , p_company_age_code	 => p_rec.company_age_code
    , p_effective_date           => p_effective_date
    , p_object_version_number    => p_rec.object_version_number
    );
  --
  hr_utility.set_location(l_proc, 13);
  --
  chk_effective_date(p_effective_date => p_effective_date);
  --
  -- chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End update_validate;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_ssm_shd.g_rec_type) is
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
--
end per_ssm_bus;

/
