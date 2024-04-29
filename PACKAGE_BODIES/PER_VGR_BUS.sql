--------------------------------------------------------
--  DDL for Package Body PER_VGR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VGR_BUS" as
/* $Header: pevgrrhi.pkb 120.0.12010000.3 2008/11/17 13:51:24 varanjan ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_vgr_bus.';  -- Global package name
--
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_valid_grade_id number default null;
g_legislation_code varchar2(150) default null;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_grade_id >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that a grade id exists in the table per_grades
--
--      Validates that the business group id for the grade id is the same
--      as that for the valid grade.
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_grade_id
--
--  Post Success :
--     If a row does exist in per_grades for the given grade id then
--     processing continues
--
--  Post Failure :
--       If a row does not exist in per_grades for the given grade id then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_grade_id
    (p_grade_id in number,
     p_business_group_id in number) is
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_grade_id';
    l_business_group_id number(15);
--
    cursor csr_valid_gra is
	select gra.business_group_id
	from per_grades gra
	where gra.grade_id = p_grade_id;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'grade_id',
       p_argument_value => p_grade_id
      );
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'business_group_id',
       p_argument_value => p_business_group_id
      );
  hr_utility.set_location(l_proc, 2);
  --
  -- Check that the grade ID is linked to a valid grade on per_grades
  --
  open csr_valid_gra;
  fetch csr_valid_gra into l_business_group_id;
  if csr_valid_gra%notfound then
    close csr_valid_gra;
    hr_utility.set_message(801, 'HR_51082_GRADE_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  close csr_valid_gra;
  --
  hr_utility.set_location(l_proc, 3);
  --
  if l_business_group_id <> p_business_group_id then
    hr_utility.set_message(801, 'HR_51083_GRADE_INVALID_BG');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(' Leaving: '|| l_proc, 4);
end chk_grade_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_from >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that date_from is less than or equal to date to (may be null)
--
--      Validates that date from must be within the range specified by date_from
--       and date_to on per_grades for the grade_id.
--
--      Validates that date from is equal to or later than the effective_date of
--      hr_positions_f for the position_id if it is not null.
--
--      Validates that date from is equal to or later than the date_from of
--      per_jobs_v for the job_id if it is not null.
--
--  Pre-conditions:
--    Format of p_date_from and p_date_to must be correct
--
--   In Arguments :
--      p_grade_id
--      p_date_from
--      p_date_to
--      p_job_id
--      p_position_id
--      p_object_version_number
--	p_effective_date		Added for Bug# 1760707
--
--  Post Success :
--    If the above business rules are satisfied then procesing continues.
--
--  Post Failure :
--       If  the above business rules are violated then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_date_from
  (p_valid_grade_id             in number
  ,p_grade_id			in number
  ,p_date_from			in date
  ,p_date_to			in date
  ,p_job_id			in number
  ,p_position_id	        in number
  ,p_object_version_number	in number
  ,p_effective_date 		in date)  -- Added for Bug# 1760707
is
--
  l_exists		varchar2(1);
  l_proc		varchar2(72) := g_package||'chk_date_from';
  l_api_updating	boolean;
--
  cursor csr_chk_gra_dates is
      select null
      from  per_grades gra
      where gra.grade_id = p_grade_id
        and p_date_from between gra.date_from
                                           and nvl(gra.date_to, hr_api.g_eot);
--
  cursor csr_chk_job_dates is
     select null
     from per_jobs_v job
     where job.job_id = p_job_id
       and p_date_from >= job.date_from;
--
-- Changes 12-Oct-99 SCNair (per_positions to hr_positions) Date tracked position req.
-- Changes 22-APR-02. replaced hr_positions with hr_positions_f and added effective_date
-- condition
cursor csr_chk_pos_dates is
     select null
     from hr_positions_f pos
     where pos.position_id = p_position_id
       and p_date_from >= pos.date_effective
       and p_effective_date between pos.effective_start_date and pos.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name	=> l_proc
      ,p_argument	=>'grade_id'
      ,p_argument_value => p_grade_id
     );
  --
hr_api.mandatory_arg_error
     (p_api_name	=> l_proc
      ,p_argument	=> 'date_from'
      ,p_argument_value => p_date_from
     );
  --
  -- Only proceed with validation if :
  --  a) The current g_old_rec is current and
  -- b) The date_from value has changed
  --
  l_api_updating := per_vgr_shd.api_updating
    (p_valid_grade_id	=> p_valid_grade_id
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and per_vgr_shd.g_old_rec.date_from <> p_date_from) or
       (NOT l_api_updating)) then
     hr_utility.set_location(l_proc, 2);
     --
     -- Check that the date_from value is less than or equal to the date_to
     -- value for the current record
     --
     if p_date_from > nvl(p_date_to, hr_api.g_eot) then
         hr_utility.set_message(801, 'HR_51084_VGR_DATE_LESS');
         hr_utility.raise_error;
     end if;
     hr_utility.set_location(l_proc, 3);
     --
     -- Check that date_from is within the range of the date_from and date_to
     -- on per_grades for p_grade_id
     --
     open csr_chk_gra_dates;
     fetch csr_chk_gra_dates into l_exists;
     if csr_chk_gra_dates%notfound then
         close csr_chk_gra_dates;
         hr_utility.set_message(801, 'HR_51085_VGR_DATE_GRADE');
         hr_utility.raise_error;
     end if;
     close csr_chk_gra_dates;
     hr_utility.set_location(l_proc, 4);
     --
     -- Check that date_from is on or later than the date_from on per_jobs_v for
     -- p_job_id
     --
    if p_job_id is not null then
        open csr_chk_job_dates;
        fetch csr_chk_job_dates into l_exists;
        if csr_chk_job_dates%notfound then
            close csr_chk_job_dates;
            hr_utility.set_message(801, 'HR_51086_VGR_DATE_JOB');
            hr_utility.raise_error;
        end if;
       close csr_chk_job_dates;
     end if;
     hr_utility.set_location(l_proc, 5);
     --
     -- Check that date_from is on or later than the effective_date on
     -- hr_positions_f  p_position_id
     --
     if p_position_id is not null then
        open csr_chk_pos_dates;
        fetch csr_chk_pos_dates into l_exists;
        if csr_chk_pos_dates%notfound then
           close csr_chk_pos_dates;
            hr_utility.set_message(801, 'HR_51087_VGR_DATE_POS');
           hr_utility.raise_error;
        end if;
        close csr_chk_pos_dates;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 6);
end chk_date_from;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_job_or_position_rule >-------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that if job_id is not null that position_id is null
--       or that if job_id is null that position_id is not null
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_job_id
--      p_position_id
--
--  Post Success :
--     If job_id is not null and position_id is null or
--     job_id is null and position_id is not null then
--     processing continues
--
--  Post Failure :
--       if job_id is not null and position_id is not null then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_job_or_position_rule
    (p_job_id in number
    ,p_position_id in number
    ) is
--
    l_exists	varchar2(1);
    l_proc		varchar2(72) := g_package||'chk_job_or_position_rule';
--
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  if p_job_id is not null and p_position_id is not null then
     hr_utility.set_message(801, 'HR_51088_VGR_JOB_OR_POS');
     hr_utility.raise_error;
  elsif p_job_id is null and p_position_id is null then
     hr_utility.set_message(801, 'HR_51089_VGR_INV_JOB_OR_POS');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 1);
end chk_job_or_position_rule;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_job_id >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that a job id exists in the view per_jobs_v
--
--      Validates that the business group id for the job is the same as that
--      for the valid grade.
--
--      Validates that the combination of grade_id and job_id does not already
--      exist on per_valid_grades.
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_job_id
--
--  Post Success :
--     If a row does exist in per_jobs_v for the given job id then
--     processing continues
--
--  Post Failure :
--       if a row does not exist in per_jobs_v for the given job_id then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_job_id
    (p_job_id in number,
     p_business_group_id in number,
     p_grade_id in number,
     p_date_from in date, -- Added For Bug # 6983587
     p_date_to in date) is -- Added For Bug # 6983587
--
    l_exists	varchar2(1);
    l_proc	varchar2(72) := g_package||'chk_job_id';
    l_business_group_id number(15);
--
    cursor csr_valid_job is
	select job.business_group_id
	from per_jobs_v job
	where job.job_id = p_job_id;
--
    cursor csr_chk_job_grd_comb is
       select null
       from per_valid_grades vgr
       where vgr.job_id = p_job_id
       and vgr.grade_id = p_grade_id
-- Fix For Bug # 6983587 Starts
       and
       (
	(p_date_from between vgr.date_from and nvl(vgr.date_to,hr_api.g_eot)
	or
	p_date_to between vgr.date_from and nvl(vgr.date_to,hr_api.g_eot)
	)
	or
	(p_date_from < vgr.date_from and p_date_to > nvl(vgr.date_to,hr_api.g_eot))
	);
-- Fix For Bug # 6983587 Ends
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  --
  -- Check that the job ID, if it is not null, is linked to a valid job on
  -- per_jobs_v
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'grade_id',
       p_argument_value => p_grade_id
      );
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'business_group_id',
       p_argument_value => p_business_group_iD
      );
  --
  if p_job_id is not null then
     open csr_valid_job;
     fetch csr_valid_job into l_business_group_id;
     if csr_valid_job %notfound then
       close csr_valid_job;
       hr_utility.set_message(801, 'HR_51090_JOB_NOT_EXIST');
       hr_utility.raise_error;
     end if;
     close csr_valid_job;
     --
     hr_utility.set_location(l_proc, 2);
     --
     if l_business_group_id <> p_business_group_id then
       hr_utility.set_message(801, 'HR_51091_JOB_INVALID_BG');
       hr_utility.raise_error;
     end if;
     --
     hr_utility.set_location(l_proc, 4);
     --
     open csr_chk_job_grd_comb;
     fetch csr_chk_job_grd_comb into l_exists;
     if csr_chk_job_grd_comb%found then
       close csr_chk_job_grd_comb;
       hr_utility.set_message(801, 'HR_51092_VGR_JOB_GRD_COMBO');
       hr_utility.raise_error;
     end if;
     close csr_chk_job_grd_comb;
     --
  end if;
  hr_utility.set_location(' Leaving: '|| l_proc, 10);
end chk_job_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_position_id >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that a position id exists in the table hr_positions_f
--
--      Validates that the business group id for the position is the same as
--      that for the valid grade.
--
--  Pre-conditions:
--     None
--
--   In Arguments :
--      p_position_id
--
--  Post Success :
--     If a row does exist in hr_positions_f for the given position id then
--     processing continues
--
--  Post Failure :
--       If a row does not exist in hr_positions_f for the given position id then
--      0an application error will be raised and processing is terminatet
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_position_id
    (p_position_id in number,
     p_business_group_id in number,
     p_grade_id in number,
     p_effective_date in date,  -- Effective_date added for Bug# 1760707
     p_date_from in date, -- Added For Bug # 7516458
     p_date_to in date) is -- Added For Bug # 7516458

--
    l_exists	varchar2(1);
    l_proc		varchar2(72) := g_package||'chk_position_id';
    l_business_group_id number(15);
--
    --
    -- Changed 12-Oct-99 SCNair (per_positions to hr_positions) Date tracked position req
    -- Changed 22-APR-02.hr_positions is replaced with hr_positions_f and added the
    -- effective_date condition. Bug 1760707
    cursor csr_valid_pos is
	select pos.business_group_id
	from hr_positions_f pos
	where pos.position_id = p_position_id
	and p_effective_date between pos.effective_start_date and pos.effective_end_date;
--
    cursor csr_chk_pos_grd_comb is
        select null
        from per_valid_grades vgr
        where vgr.position_id = p_position_id
        and vgr.grade_id = p_grade_id
	-- Fix For Bug # 7516458 Starts
        and
        (
	( p_date_from between vgr.date_from and nvl(vgr.date_to,hr_api.g_eot)
	or
	 p_date_to between vgr.date_from and nvl(vgr.date_to,hr_api.g_eot))
	or
	(p_date_from < vgr.date_from and p_date_to > nvl(vgr.date_to,hr_api.g_eot))
	);
       -- Fix For Bug # 7516458 Ends

--
begin
  hr_utility.set_location('Entering: '|| l_proc, 1);
  --
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'grade_id',
       p_argument_value => p_grade_id
      );
  --
  hr_api.mandatory_arg_error
      (p_api_name	=> l_proc,
       p_argument	=> 'business_group_id',
       p_argument_value => p_business_group_iD
      );
  --
-- Check that the position ID , if it is not null, is linked to a valid
-- position on hr_positions_f
  --
  if p_position_id is not null then
     open csr_valid_pos;
     fetch csr_valid_pos into l_business_group_id;
     if csr_valid_pos%notfound then
        close csr_valid_pos;
        hr_utility.set_message(801, 'HR_51093_POS_NOT_EXIST');
        hr_utility.raise_error;
     end if;
     close csr_valid_pos;
     --
     hr_utility.set_location(l_proc, 2);
     --
     if l_business_group_id <> p_business_group_id then
       hr_utility.set_message(801, 'HR_51094_POS_INVALID_BG');
       hr_utility.raise_error;
     end if;
     --
     hr_utility.set_location(l_proc, 3);
     --
     open csr_chk_pos_grd_comb;
     fetch csr_chk_pos_grd_comb into l_exists;
     if csr_chk_pos_grd_comb%found then
       CLose csr_chk_pos_grd_comb;
       hr_utility.set_message(801, 'HR_51095_VGR_POS_GRD_COMBO');
       hr_utility.raise_error;
     end if;
     close csr_chk_pos_grd_comb;
     --
  end if;
  hr_utility.set_location(' Leaving: '|| l_proc, 10);
end chk_position_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_to >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description :
--      Validates that date_to  is greater than or equal to date from
--
--      Validates that date to must be within the range specified by date_from
--       and date_to on per_grades for the grade_id.
--
--      Validates that date to is equal to or earlier than the effective_date of
--      hr_positions_f for the position_id if it is not null.
--
--      Validates that date to is equal to or earlier than the date_to  of
--      per_jobs_v for the job_id if it is not null.
--
--  Pre-conditions:
--    Format of p_date_from and p_date_to must be correct
--
--   In Arguments :
--      p_grade_id
--      p_date_to
--      p_date_from
--      p_job_id
--      p_position_id
--      p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied then procesing continues.
--
--  Post Failure :
--       If  the above business rules are violated then
--       an application error will be raised and processing is terminated
--
--   Access Status :
--      Internal Table Handler Use only.
--
--    {End of Comments}
--  ---------------------------------------------------------------------------
procedure chk_date_to
  (p_valid_grade_id             in number
  ,p_grade_id			in number
  ,p_date_from			in date
  ,p_date_to			in date
  ,p_job_id			in number
  ,p_position_id	        in number
  ,p_object_version_number	in number
  ,p_effective_date		in date)  --Added for Bug#1760707
is
--
  l_exists		varchar2(1);
  l_proc		varchar2(72) := g_package||'chk_date_to';
  l_api_updating	boolean;
--
  cursor csr_chk_gra_dates is
      select null
      from  per_grades gra
      where gra.grade_id = p_grade_id
       and nvl(p_date_to, hr_api.g_eot) between gra.date_from
                                           and nvl(gra.date_to, hr_api.g_eot);
--
  cursor csr_chk_job_dates is
     select null
     from per_jobs_v job
     where job.job_id = p_job_id
      and nvl(p_date_to, hr_api.g_eot) <= nvl(job.date_to, hr_api.g_eot);
--
-- Changes 12-Oct-99 SCNair (per_postions to hr_positions) date tracked position req.
-- replaced  hr_positions with hr_position_f.Added effective_date condition. Bug 1760707
--
cursor csr_chk_pos_dates is
     select null
     from hr_positions_f pos
     where pos.position_id = p_position_id
      and nvl(p_date_to, hr_api.g_eot)  <= nvl(hr_general.get_position_date_end(p_position_id), hr_api.g_eot)
      and p_effective_date between pos.effective_start_date and pos.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters havu been set
  --
  hr_api.mandatory_arg_error
     (p_api_name	=> l_proc
      ,p_argument	=> 'grade_id'
      ,p_argument_value => p_grade_id
     );
  --
 hr_api.mandatory_arg_error
     (p_api_name	=> l_proc
      ,p_argument	=> 'date_from'
      ,p_argument_value => p_date_from
     );
  --
  -- Only proceed with validation if :
  --  a) The current g_old_rec is current and
  --  b) The date_to value has changed
  --
  l_api_updating := per_vgr_shd.api_updating
    (p_valid_grade_id	=> p_valid_grade_id
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
         nvl(per_vgr_shd.g_old_rec.date_to, hr_api.g_eot) <>
         nvl(p_date_to, hr_api.g_eot)) or
       (NOT l_api_updating)) then
     hr_utility.set_location(l_proc, 2);
     --
     -- Check that the date_from value is greater than or equal to the date_to
     -- value for the current record
     --
     if p_date_from > nvl(p_date_to, hr_api.g_eot) then
         hr_utility.set_message(801, 'HR_51096_VGR_DATE_GREATER');
         hr_utility.raise_error;
     end if;
     hr_utility.set_location(l_proc, 3);
     --
     -- Check that date_to is within the range of the date_from and date_to
     -- on per_grades for p_grade_id
     --
     open csr_chk_gra_dates;
     fetch csr_chk_gra_dates into l_exists;
     if csr_chk_gra_dates%notfound then
         close csr_chk_gra_dates;
         hr_utility.set_message(801, 'HR_51097_VGR_END_DATE_INVALID');
         hr_utility.raise_error;
     end if;
     close csr_chk_gra_dates;
     hr_utility.set_location(l_proc, 4);
     --
     -- Check that date_to is on or earlier than the date_to on per_jobs_v for
     -- p_job_id
     --
     if p_job_id is not null then
        open csr_chk_job_dates;
        fetch csr_chk_job_dates into l_exists;
        if csr_chk_job_dates%notfound then
            close csr_chk_job_dates;
            hr_utility.set_message(801, 'HR_51098_VGR_END_DATE_JOB');
            hr_utility.raise_error;
        end if;
        close csr_chk_job_dates;
    end if;
    hr_utility.set_location(l_proc, 5);
     --
     -- Check that date_to is on or later than the end_date on
     -- hr_positions_f  p_position_id
     --
     if p_position_id is not null then
        open csr_chk_pos_dates;
        fetch csr_chk_pos_dates into l_exists;
        if csr_chk_pos_dates%notfound then
           close csr_chk_pos_dates;
           hr_utility.set_message(801, 'HR_51099_VGR_END_DATE_POS');
           hr_utility.raise_error;
       end if;
       close csr_chk_pos_dates;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 6);
end chk_date_to;
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
  (p_rec in per_vgr_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.valid_grade_id is not null) and (
    nvl(per_vgr_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_vgr_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.valid_grade_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_VALID_GRADES'
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
Procedure insert_validate(p_rec           in per_vgr_shd.g_rec_type,
			  p_effective_date in date) is   -- Added for Bug# 1760707
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations.  Mapping to the appropriate
  -- Business Rules in pervga.bru is provided.
  --
  --
  -- Validate Business Group id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate Grade id
  --
  chk_grade_id (p_grade_id => p_rec.grade_id
               ,p_business_group_id => p_rec.business_group_id );
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Validate that either Position or Job Ids are set
  --
  chk_job_or_position_rule
       (p_job_id => p_rec.job_id
       ,p_position_id => p_rec.position_id);
  --
  hr_utility.set_location(l_proc, 20);
 --
 -- Validate Job id
 --
 chk_job_id (p_job_id => p_rec.job_id
               ,p_business_group_id => p_rec.business_group_id
               ,p_grade_id => p_rec.grade_id
               ,p_date_from => p_rec.date_from -- Added For Bug # 6983587
               ,p_date_to => p_rec.date_to); -- Added For Bug 6983587
 --
 hr_utility.set_location(l_proc, 25);
 --
 -- Validate Position id
 --
  chk_position_id (p_position_id => p_rec.position_id
               ,p_business_group_id => p_rec.business_group_id
               ,p_grade_id => p_rec.grade_id
               ,p_effective_date => p_effective_date  -- Added for Bug# 1760707
               ,p_date_from => p_rec.date_from -- Added For Bug # 7516458
               ,p_date_to => p_rec.date_to); -- Added For Bug 7516458

  --
 hr_utility.set_location(l_proc, 30);
 --
 -- Validate Date From
 --
  chk_date_from
        (p_valid_grade_id  => p_rec.valid_grade_id
        ,p_grade_id	   => p_rec.grade_id
        ,p_date_from       => p_rec.date_from
        ,p_date_to	   => p_rec.date_to
        ,p_job_id	   => p_rec.job_id
        ,p_position_id => p_rec.position_id
       ,p_object_version_number => p_rec.object_version_number
       ,p_effective_date   => p_effective_date);  -- Added for Bug# 1760707
 --
 hr_utility.set_location(l_proc, 35);
 --
 -- Validate Date To
 --
  chk_date_to
        (p_valid_grade_id  => p_rec.valid_grade_id
        ,p_grade_id	   => p_rec.grade_id
        ,p_date_from       => p_rec.date_from
        ,p_date_to	   => p_rec.date_to
        ,p_job_id	   => p_rec.job_id
        ,p_position_id => p_rec.position_id
       ,p_object_version_number => p_rec.object_version_number
       ,p_effective_date   => p_effective_date);  -- Added for Bug# 1760707
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  -- Call descriptive flexfield validation routines
  --
  per_vgr_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 45);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec            in per_vgr_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations.  Mapping to the
  -- appropriate Business Rules in per_vgr.bru is provided
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Validate Business Group id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  -- Validate date from
  --
  chk_date_from
        (p_valid_grade_id  => p_rec.valid_grade_id
        ,p_grade_id	   => p_rec.grade_id
        ,p_date_from       => p_rec.date_from
        ,p_date_to	   => p_rec.date_to
        ,p_job_id	   => p_rec.job_id
        ,p_position_id => p_rec.position_id
       ,p_object_version_number => p_rec.object_version_number
       ,p_effective_date   => p_effective_date);  -- Added for Bug# 1760707
 --
 hr_utility.set_location(l_proc, 7);
 --
 -- Validate Date To
 --
  chk_date_to
        (p_valid_grade_id  => p_rec.valid_grade_id
        ,p_grade_id	   => p_rec.grade_id
        ,p_date_from       => p_rec.date_from
        ,p_date_to	   => p_rec.date_to
        ,p_job_id	   => p_rec.job_id
        ,p_position_id => p_rec.position_id
       ,p_object_version_number => p_rec.object_version_number
       ,p_effective_date   => p_effective_date );  --Added for Bug#1760707
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- Call descriptive flexfield validation routines
  --
  per_vgr_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_vgr_shd.g_rec_type) is
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
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_valid_grade_id    in per_valid_grades.valid_grade_id%TYPE
  ) return varchar2 is
  --
  -- Cursor to find legislation code
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_valid_grades pvg
     where pvg.valid_grade_id = p_valid_grade_id
       and pbg.business_group_id = pvg.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'valid_grade_id',
                             p_argument_value => p_valid_grade_id);
 --
  if nvl(g_valid_grade_id, hr_api.g_number) = p_valid_grade_id then
    --
    -- The legislation has already been found with a previous
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
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(' Leaving:'|| l_proc, 30);
    --
    -- Set the global variables so the vlaues are
    -- available for the next call to this function
    --
    close csr_leg_code;
    g_valid_grade_id	:= p_valid_grade_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_vgr_bus;

/
