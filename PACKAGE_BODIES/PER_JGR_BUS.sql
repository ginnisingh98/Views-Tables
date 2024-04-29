--------------------------------------------------------
--  DDL for Package Body PER_JGR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JGR_BUS" as
/* $Header: pejgrrhi.pkb 115.9 2004/09/09 08:11:45 smparame noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_jgr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_job_group_id                number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_job_group_id                         in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_job_groups jgr
     where jgr.job_group_id = p_job_group_id
       and pbg.business_group_id = jgr.business_group_id;
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
    ,p_argument           => 'job_group_id'
    ,p_argument_value     => p_job_group_id
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
--  |--------------------<chk_unique_jgr_name>--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Validate that both the internal_name and the displayed_name of the
-- Job Group are unique. If HR: Cross Business Group profile is set to 'N'
-- they must be unique within the business group. If the HR: Cross Business
-- Group profile is set to 'Y' then the names must be unique across
-- all business groups.
--
-- Pre-requisites:
--   None
--
-- In parameters:
--     p_displayed_name
--     p_internal_name
--     p_business_group_id
--
-- Post Success:
--   Where business_group_id is not null, processing continues if
--   the displayed_name and the internal_name are unique within
--   that business group.
--   Where business_group_id is null, processing continues if the
--   the displayed_name and the internal_name are unique across all
--   business groups.
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   internal_name and the displayed_name are not unique either in that
--   business group, where business_group_id is not null, or across all
--   business groups where business group id is null.
--
-- Access Status:
--   Internal table handler use only.
--
procedure chk_unique_jgr_name(p_displayed_name in varchar2
					    ,p_internal_name in varchar2
					    ,p_business_group_id in number
					    ,p_job_group_id in number
					    ) is
--
l_int_name varchar2(80);
l_disp_name varchar2(80);
l_proc varchar2(72) := g_package||'chk_unique_jgr_name';
l_job_Group_id number;
--
cursor csr_int_name_exists is
select internal_name
from per_job_groups
where business_group_id = p_business_group_id
and internal_name = p_internal_name
and job_group_id <> nvl(p_job_group_id,-999);
--
cursor csr_disp_name_exists is
select displayed_name
from per_job_groups
where business_group_id = p_business_group_id
and displayed_name = p_displayed_name
and job_group_id <> nvl(p_job_group_id,-999);
--
cursor csr_int_name_no_bg is
select internal_name
from per_job_groups
where internal_name = p_internal_name
and job_group_id <> nvl(p_job_group_id,-999);
--
cursor csr_disp_name_no_bg is
select displayed_name
from per_job_groups
where displayed_name = p_displayed_name
and job_group_id <> nvl(p_job_group_id,-999);
--
begin
--
l_job_Group_id := p_job_Group_id;
hr_utility.set_location('job_group_id '||l_job_Group_id,1);
hr_utility.set_location('Entering :'||l_proc,5);
--
  if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
    open csr_disp_name_exists;
    fetch csr_disp_name_exists into l_disp_name;
    if csr_disp_name_exists%found then
      close csr_disp_name_exists;
      hr_utility.set_message(800,'PER_52661_DIS_NAME_EXIST_BG');
      hr_utility.raise_error;
    else open csr_int_name_exists;
	 fetch csr_int_name_exists into l_int_name;
	 if csr_int_name_exists%found then
	   close csr_int_name_exists;
	   hr_utility.set_message(800,'PER_52662_INT_NAME_EXIST_BG');
	   hr_utility.raise_error;
      end if;
      close csr_int_name_exists;
    end if;
    close csr_disp_name_exists;
  else
    open csr_disp_name_no_bg;
    fetch csr_disp_name_no_bg into l_disp_name;
    if csr_disp_name_no_bg%found then
	 close csr_disp_name_no_bg;
	 hr_utility.set_message(800,'PER_52663_DISP_NAME_EXISTS');
	 hr_utility.raise_error;
    else open csr_int_name_no_bg;
	 fetch csr_int_name_no_bg into l_int_name;
	 if csr_int_name_no_bg%found then
	   close csr_int_name_no_bg;
        hr_utility.set_message(800,'PER_52664_INT_NAME_EXISTS');
	   hr_utility.raise_error;
      end if;
	 close csr_disp_name_no_bg;
    end if;
    close csr_int_name_no_bg;
  end if;
--
hr_utility.set_location('Leaving :'||l_proc,10);
end chk_unique_jgr_name;

--  ---------------------------------------------------------------------------
--  |--------------------<chk_master_flag>------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Validate that if this Job Group has a not null business_group_id
-- and HR: Cross Business Group profile is set to 'N' then
-- only one Job Group in that business group can have the master flag
-- set to 'Y'. Also, if business_group_id is null or HR:Cross Business Group
-- profile is set to 'Y' then validate that only one Job Group in all
-- business groups has master flag set to 'Y'.
--
-- Pre-requisites:
--   None
--
-- In parameters:
--     p_job_group_id
--     p_business_group_Id
--     p_master_flag
--
-- Post Success:
--   Where business_group_id is not null, processing continues if only one
--   job group has master flag set to 'Y' in that business group.
--   Where business_group_id is null, processing continues if only one
--   job group has master flag set to 'Y' across all business groups.
--
-- Post Failure:
--   An application error is raised and processing is terminated if more
--   than one job group has master flag set to 'Y' either in that business
--   group, where business group id is not null, or across all business groups
--   where business group id is null.
--
-- Access Status:
--   Internal table handler use only.
--
procedure chk_master_flag(p_job_group_id in number
					,p_business_group_id in number
					,p_master_flag  in varchar2
					) is
--
cursor csr_master_flag_bg is
select master_flag
from per_job_groups
where p_business_group_id = business_group_id
and job_group_id <> p_job_group_id  -- bug fix 3879133
and master_flag = 'Y';
--
cursor csr_master_flag_no_bg is
select master_flag
from per_job_groups
where master_flag = 'Y'
and job_group_id <> p_job_group_id; -- bug fix 3879133.
--
l_flag_bg varchar2(1);
l_flag_no_bg varchar2(1);
l_proc varchar2(72) := g_package||'chk_master_flag';
--
begin
  --
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  if p_master_flag = 'Y'
  --and
    --per_jgr_shd.g_old_rec.master_flag <> p_master_flag then
    then
    --
    if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
	 open csr_master_flag_bg;
	 fetch csr_master_flag_bg into l_flag_bg;
	 if csr_master_flag_bg%found then
	   close csr_master_flag_bg;
	   hr_utility.set_message(800,'PER_52665_MASTER_FLAG_BG');
	   hr_utility.raise_error;
      end if;
      close csr_master_flag_bg;
    else
	 open csr_master_flag_no_bg;
	 fetch csr_master_flag_no_bg into l_flag_no_bg;
	 if csr_master_flag_no_bg%found then
	   close csr_master_flag_no_bg;
	   hr_utility.set_message(800,'PER_52666_MASTER_FLAG_NBG');
	   hr_utility.raise_error;
      end if;
	 close csr_master_flag_no_bg;
    end if;
    --
    hr_utility.set_location('Leaving: '||l_proc,10);
  --
  end if;
--
end chk_master_flag;
--
--  --------------------------------------------------------------------------
-- |----------------------<chk_object_version_number>------------------------|
--  --------------------------------------------------------------------------
--
--
--  Desciption :
--
--    Checks that the OVN passed is not null on delete.
--
--  Pre-conditions :
--    None.
--
--  In Arguments :
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_object_version_number
  (
   p_object_version_number in  per_job_groups.object_version_number%TYPE
   )  is
--
l_proc  varchar2(72) := g_package||'chk_object_version_number';
--
begin
--
hr_utility.set_location('Entering:'||l_proc, 1);
--
--      Check mandatory parameters have been set
--
   hr_api.mandatory_arg_error
    (p_api_name             => l_proc
    ,p_argument             => 'object_version_number'
    ,p_argument_value      => p_object_version_number
	 );
--
hr_utility.set_location(' Leaving:'||l_proc, 3);
--
end chk_object_version_number;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_delete_jgr>-----------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--     Validates that the default 'HR' job group is not deleted and that
--     user defined job groups can only be deleted if no jobs are linked
--     to that job group.
--
--  Pre-requisites:
--     None
--
--  In parameters:
--     p_job_group_id
--
--  Post Success:
--    Where the job group is not the default 'HR' job group and no
--    jobs exists which are linked to this job group, then processing
--    continues and the job group is deleted.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the job group is the default 'HR' job group or the job group
--    has jobs linked to it.
--
--  Access Status:
--    Internal table handler use only.
--
procedure chk_delete_jgr(p_job_group_id in number
              ) is
--
cursor csr_jobs_exist is
select 'X'
from per_jobs
where job_group_id = p_job_group_id;
--
cursor csr_hr_jobgroup is
select 'Y'
from per_job_groups
where job_group_id = p_job_group_id
and internal_name = 'HR_'||to_char(business_group_id);
--
cursor csr_rep_body is
select 'X'
from hr_organization_information
where org_information1 in
 (select to_char(job_group_id) from per_job_groups
 where job_group_id = p_job_group_id);
--
l_jobs_exist varchar2(30);
l_hr_jobgroup varchar2(30);
l_rep_body varchar2(30);
l_proc  varchar2(72) := g_package||'chk_object_version_number';
--
begin
hr_utility.set_location('Entering: '||l_proc,5);
  open csr_hr_jobgroup;
  fetch csr_hr_jobgroup into l_hr_jobgroup;
  if csr_hr_jobgroup%found then
    hr_utility.set_message(800,'PER_52667_DEL_HR_JGR');
    hr_utility.raise_error;
  end if;
  close csr_hr_jobgroup;
  open csr_jobs_exist;
  fetch csr_jobs_exist into l_jobs_exist;
    if csr_jobs_exist%found then
	 hr_utility.set_message(800,'PER_52668_JGR_JOB_EXIST');
	 hr_utility.raise_error;
    end if;
  close csr_jobs_exist;
  open csr_rep_body;
  fetch csr_rep_body into l_rep_body;
    if csr_rep_body%found then
	 hr_utility.set_message(800,'PER_52685_JGR_REP_DEL');
	 hr_utility.raise_error;
    end if;
  close csr_rep_body;
--
hr_utility.set_location('Leaving: '||l_proc,10);
--
end chk_delete_jgr;
--
--  ---------------------------------------------------------------------------
--  |---------------------<chk_job_structure>---------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description:
--
-- Validates that the job structure is valid in the fnd_id_flex_structures_vl table.
--
-- Pre-requisites:
--   None
--
-- In parameters:
--     p_id_flex_num
--
-- Post Success:
--   Where the job structure exists in fnd_id_flex_structures_vl processing
--   continues.
--
-- Post Failure:
--   An application error is raised and processing is terminated if id_flex_num
--   is not valid.
--
-- Access Status:
--   Internal table handler use only.
--
procedure chk_job_structure(p_id_flex_num in number) is
--
l_proc varchar2(72) := g_package||'chk_job_structure';
l_job_structure varchar2(30);
--
cursor csr_job_structure is
select 'X'
from fnd_id_flex_structures_vl fnd, hr_organization_information hoi
where fnd.id_flex_code = 'JOB'
and hoi.org_information_context = 'Business Group Information'
and fnd.id_flex_num = p_id_flex_num;
--
begin
--
  hr_utility.set_location('Entering: '||l_proc,5);
  --
  if p_id_flex_num is not null then
    open csr_job_structure;
    fetch csr_job_structure into l_job_structure;
    if csr_job_structure%notfound then
	 close csr_job_structure;
	 hr_utility.set_message(800,'PER_52671_JOB_STRUC_INV');
      hr_utility.raise_error;
    end if;
    close csr_job_structure;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc,10);
--
end chk_job_structure;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_job_group_id                         in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_job_groups jgr
     where jgr.job_group_id = p_job_group_id
       and pbg.business_group_id = jgr.business_group_id;
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
    ,p_argument           => 'job_group_id'
    ,p_argument_value     => p_job_group_id
    );
  --
  if ( nvl(per_jgr_bus.g_job_group_id, hr_api.g_number)
       = p_job_group_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_jgr_bus.g_legislation_code;
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
    per_jgr_bus.g_job_group_id      := p_job_group_id;
    per_jgr_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_jgr_shd.g_rec_type
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
  IF NOT per_jgr_shd.api_updating
      (p_job_group_id                         => p_rec.job_group_id
      ,p_object_version_number                => p_rec.object_version_number
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
  hr_utility.set_location(l_proc, 30);
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date    in date
  ,p_rec               in per_jgr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  per_jgr_bus.chk_unique_jgr_name(p_displayed_name    => p_rec.displayed_name
						   ,p_internal_name     => p_rec.internal_name
						   ,p_business_group_id => p_rec.business_group_id
						   ,p_job_group_id      => p_rec.job_group_id);
  --
  per_jgr_bus.chk_master_flag(p_job_group_id      => p_rec.job_group_id
					    ,p_business_group_id => p_rec.business_group_id
					    ,p_master_flag       => p_rec.master_flag);
  --
  per_jgr_bus.chk_job_structure(p_id_flex_num => p_rec.id_flex_num);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_jgr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  per_jgr_bus.chk_unique_jgr_name
   (p_displayed_name    => p_rec.displayed_name
   ,p_internal_name     => p_rec.internal_name
   ,p_business_group_id => p_rec.business_group_id
   ,p_job_group_id      => p_rec.job_group_id);
  --
  per_jgr_bus.chk_master_flag
   (p_job_group_id      => p_rec.job_group_id
   ,p_business_group_id => p_rec.business_group_id
   ,p_master_flag       => p_rec.master_flag);
  --
  per_jgr_bus.chk_job_structure
   (p_id_flex_num => p_rec.id_flex_num);
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_jgr_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
  l_int varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  l_int := p_rec.internal_name;
  hr_utility.set_location('internal_name '||l_int,7);
  --
  chk_delete_jgr
	(p_job_group_id         => p_rec.job_group_id);
  --
  -- Validate Object Version Number
  --
  chk_object_version_number
	(p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_jgr_bus;

/
