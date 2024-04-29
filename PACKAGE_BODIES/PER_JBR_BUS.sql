--------------------------------------------------------
--  DDL for Package Body PER_JBR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JBR_BUS" as
/* $Header: pejbrrhi.pkb 115.7 2002/12/06 10:18:00 pkakar ship $ */
--
-- ---------------------------------------------------------------------------
-- |                    Private Global Definitions                           |
-- ---------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_jbr_bus.';  -- Global package name
--
-- [ Start of change 8/4 by Kim Conley]
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_job_id >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  	This procedure validates that the job_id exists in the
--	PER_JOBS_V view .
--
--	The procedure also validates that the combination of job id
--	and analysis criteria id, do not already exist in the job requirement
--	table.  This procedure does not do the mandatory check, because
--	the chk_job_pos confirmed the existence of job id
--
-- Pre-conditions:
--  	The job id must not be null, and position id must be null
--
-- In Arguments:
--	p_analysis_criteria_id
--	p_job_id
--	p_job_requirement_id
--	p_business_group_id
--
-- Post Success:
-- 	If a job is is valid, and the combination of job and
--	analysis criteria doesn't already exist then processing continues
--
-- Post Failure:
--	If  job id is not valid or the combination of job and
--	analysis_criteria_id already exist then
--	an application error will be raised and processing is terminated.
--
-- Access Status:
--	Internal Table Handler Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_job_id (p_job_id			in  number,
                      p_analysis_criteria_id 	in  number,
	              p_job_requirement_id	in  number default null,
	              p_business_group_id	in  number,
                      p_object_version_number   in  number default null) is
--
  l_exists		varchar2(1);
  l_proc		varchar2(72)	:=  g_package||'chk_job_id';
  l_api_updating        boolean;
--
cursor csr_job_exists is
   select 'x'
   from   per_jobs_v pj
   where  pj.job_id = p_job_id
   and    pj.business_group_id + 0 = p_business_group_id;
--
cursor csr_combo_exists is
   select 'x'
   from   per_job_requirements pjr
   where (p_job_requirement_id <> pjr.job_requirement_id or
          p_job_requirement_id is NULL)
   and    p_job_id = pjr.job_id
   and    p_analysis_criteria_id = pjr.analysis_criteria_id;
--
begin
  hr_utility.set_location('Entering :'||l_proc,1);
  --
  l_api_updating :=
    per_jbr_shd.api_updating
      (p_job_requirement_id    => p_job_requirement_id,
       p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
      (per_jbr_shd.g_old_rec.job_id <> p_job_id) or
      (per_jbr_shd.g_old_rec.analysis_criteria_id <>
       p_analysis_criteria_id)) or
      (not l_api_updating)) then
--
--  Checks that job is valid
--
hr_utility.set_location(l_proc,2);
--
    open csr_job_exists;
    fetch csr_job_exists into l_exists;
    if csr_job_exists%notfound then
      close csr_job_exists;
      hr_utility.set_message(801,'HR_51090_JOB_NOT_EXIST');
      hr_utility.raise_error;
    else
      close csr_job_exists;
    end if;
--
--
--  Checks the combination of job and analysis criteria
--
    hr_utility.set_location(l_proc,3);
    open csr_combo_exists;
    fetch csr_combo_exists into l_exists;
    if csr_combo_exists%found then
      close csr_combo_exists;
      hr_utility.set_message(801,'HR_51109_JBR_ALREADY_EXISTS');
      hr_utility.raise_error;
    else
      close csr_combo_exists;
  end if;
--
end if;
hr_utility.set_location('Leaving:'||l_proc,4);
end chk_job_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_position_id >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  	This procedure validates that the position_id exists in the
--	HR_POSITIONS table
--
--	The procedure also validates that the combination of position id
--	and analysis criteria id, do not already exist in the job requirement
--	table.  This procedure does not do the mandatory check, because
--	the chk_job_pos confirmed the existence of position id
--
-- Pre-conditions:
--  	The position id must not be null, and job id must be null
--
-- In Arguments:
--	p_analysis_criteria_id
--	p_position_id
--	p_job_requirement_id
--      p_business_group_id
--
-- Post Success:
-- 	If a position is is valid, and the combination of position and
--	analysis criteria doesn't already exist then processing continues
--
-- Post Failure:
--	If  position id is not valid or the combination of position and
--	analysis_criteria_id already exist then
--	an application error will be raised and processing is terminated.
--
-- Access Status:
--	Internal Table Handler Use Only
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_position_id (
	         p_position_id		 in number,
                 p_analysis_criteria_id	 in number,
	         p_job_requirement_id	 in number default null,
	         p_business_group_id	 in number,
                 p_object_version_number in number default null) is
--
  l_exists		varchar2(1);
  l_proc	        varchar2(72)	:=  g_package||'chk_position_id';
  l_api_updating        boolean;
  --
  -- Changed 12-Oct-99 SCNair (per_positions to hr_positions) Date tracked position req.
  --
  cursor csr_position_exists is
     select 'x'
     from   hr_positions_f pos
     where  pos.position_id = p_position_id
     and    pos.business_group_id + 0 = p_business_group_id;
--
  cursor csr_pos_combo_exists is
    select 'x'
    from   per_job_requirements pjr
    where  (p_job_requirement_id <> pjr.job_requirement_id or
            p_job_requirement_id is NULL)
    and    p_position_id = pjr.position_id
    and    p_analysis_criteria_id = pjr.analysis_criteria_id;
--
begin
  hr_utility.set_location('Entering :'||l_proc,1);
  l_api_updating :=
    per_jbr_shd.api_updating
      (p_job_requirement_id    => p_job_requirement_id,
       p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
      (per_jbr_shd.g_old_rec.position_id <> p_position_id or
       per_jbr_shd.g_old_rec.analysis_criteria_id <>
       p_analysis_criteria_id)) or
      (not l_api_updating)) then
    --
    --  Checks that position is valid
    --
    hr_utility.set_location(l_proc,2);
    open csr_position_exists;
    fetch csr_position_exists into l_exists;
    if csr_position_exists%notfound then
      close csr_position_exists;
      hr_utility.set_message(801,'HR_51093_POS_NOT_EXIST');
      hr_utility.raise_error;
    else
      close csr_position_exists;
    end if;
  --
    --
    --  Checks the combination of position and analysis criteria
    --
    hr_utility.set_location(l_proc,3);
    open csr_pos_combo_exists;
    fetch csr_pos_combo_exists into l_exists;
    if csr_pos_combo_exists%found then
      close csr_pos_combo_exists;
      hr_utility.set_message(801,'HR_51110_JBR_POS_ALREADY_EXIS');
    hr_utility.raise_error;
    else
      close csr_pos_combo_exists;
    end if;
  end if;
--
  hr_utility.set_location('Leaving:'||l_proc,4);
end chk_position_id;
--
-- ----------------------------------------------------------------------------
-- |---------------< chk_analysis_criteria_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  	Validates that the analysis_criteria_id is not null, and exists in
--            per_analysis_criteria table
--
-- Pre-conditions:
--  	None
--
-- In Arguments:
--	p_analysis_criteria_id
--
-- Post Success:
-- 	If a analysis_criteria_id is valid then processing continues
--
-- Post Failure:
--	If  a analysis_criteria_id is null or not in per_analysis_criteria then
--	an application error will be raised and processing is terminated.
--
-- Access Status:
--	Internal Table Handler Use Only
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_analysis_criteria_id
            (p_analysis_criteria_id  in number,
             p_job_requirement_id    in number default null,
             p_object_version_number in number default null) is
--
  l_exists	 varchar2(1);
  l_proc	 varchar2(72)	:=  g_package||'chk_analysis_criteria_id';
  l_api_updating boolean;
--
  cursor csr_criteria_exists is
    select 'x'
    from   per_analysis_criteria pac
    where  pac.analysis_criteria_id = p_analysis_criteria_id;
--
begin
  --
  --  Checks that analysis criteria is not null
  --
  hr_utility.set_location('Entering:'||l_proc,1);
  --
  hr_api.mandatory_arg_error(p_api_name  => l_proc,
	 		     p_argument  => 'analysis_criteria_id',
                             p_argument_value  =>  p_analysis_criteria_id);
  --
  hr_utility.set_location(l_proc,2);
  l_api_updating :=
    per_jbr_shd.api_updating
      (p_job_requirement_id    => p_job_requirement_id,
       p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
      (per_jbr_shd.g_old_rec.analysis_criteria_id <>
       p_analysis_criteria_id)) or
      (not l_api_updating)) then
    --
    --
    --  Checks that analysis criteria is valid
    --
    hr_utility.set_location(l_proc, 3);
    --
    open csr_criteria_exists;
    fetch csr_criteria_exists into l_exists;
    if csr_criteria_exists%notfound then
      close csr_criteria_exists;
      hr_utility.set_message(801,'HR_51111_JBR_A_CR_NOT_EXIS');
    hr_utility.raise_error;
    else
      close csr_criteria_exists;
    end if;
  end if;
  --
hr_utility.set_location('Leaving:'||l_proc,4);
end chk_analysis_criteria_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_job_pos >----------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description:
--  	This procedure checks for the mutual exculsivity of job_id and
--            position_id.  If job exists but position doesn't the chk_job_id
--            procedure is called.  If position exists but job doesn't the
--	chk_position_id procedure is called.
--
--	NOTE:  This procedure was created so that there was no
--	conditional branching in the insert_validate procedure
--
-- Pre-conditions:
--  	None
--
-- In Arguments:
--	p_position_id
--	p_job_id
--	p_analysis_criteria_id
--	p_job_requirement_id
--
-- Post Success:
-- 	If a job is not null and position is null chk_job_id is called
--      (processing continues).  If position is not null and job is
--      null then chk_position_id is called (processing continues)
--
-- Post Failure:
--	If  both job and position exist , OR job and position are null then
--	an application error will be raised and processing is terminated.
--
-- Access Status:
--	Internal Table Handler Use Only
--
-- {End of Comments}
-------------------------------------------------------------------------------
Procedure chk_job_pos
                 (p_position_id 	  in number,
	          p_job_id         	  in number,
	          p_analysis_criteria_id  in number,
	          p_job_requirement_id	  in number default null,
	          p_business_group_id	  in number,
                  p_object_version_number in number default null) is
--
  l_proc  varchar2(72)  :=  g_package||'chk_job_pos';
--
begin
  hr_utility.set_location(' Entering:'||l_proc,1);
  --
  if (p_position_id is not null AND p_job_id is null) then
    chk_position_id(p_job_requirement_id        => p_job_requirement_id,
                    p_object_version_number     => p_object_version_number,
                    p_position_id  		=> p_position_id,
	 	    p_analysis_criteria_id	=> p_analysis_criteria_id,
		    p_business_group_id 	=> p_business_group_id);
  elsif (p_job_id is not null AND p_position_id is null) then
    chk_job_id(p_job_requirement_id     => p_job_requirement_id,
               p_object_version_number  => p_object_version_number,
               p_job_id			=> p_job_id,
	       p_analysis_criteria_id	=> p_analysis_criteria_id,
	       p_business_group_id	=> p_business_group_id);
  else
    hr_utility.set_message(801, 'HR_51112_JBR_JOB_OR_POS');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,2);
end chk_job_pos;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_essential >---------------------------------|
--  ---------------------------------------------------------------------------
--
-- Description:
--  	This procedure checks that ESSENTIAL is 'Y' or 'N'.
--
-- Pre-conditions:
--  	None
--
-- In Arguments:
--	p_essential
--
-- Post Success:
-- 	 If essential is 'Y' or 'N' processing continues
--
-- Post Failure:
--	If  essential is not 'Y' or 'N'  then
--	an application error will be raised and processing is terminated.
--
-- Access Status:
--	Internal Table Handler Use Only
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_essential(p_essential             in varchar2,
                        p_job_requirement_id    in number default null,
                        p_object_version_number in number default null) is
--
  l_proc         varchar2(72)  := g_package||'chk_essential';
  l_api_updating boolean;
  l_exists       varchar2(1);
--
  cursor csr_essential is
    select 'x'
    from   hr_lookups hl
    where  hl.lookup_type = 'YES_NO'
    and    hl.lookup_code = p_essential;
--
begin
  --
  hr_utility.set_location('Entering :'||l_proc,1);
  --
  hr_api.mandatory_arg_error(p_api_name  => l_proc,
 	  	             p_argument  => 'essential',
                             p_argument_value  =>  p_essential);
  --
  hr_utility.set_location(l_proc,2);

  l_api_updating :=
    per_jbr_shd.api_updating
      (p_job_requirement_id => p_job_requirement_id,
       p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
       per_jbr_shd.g_old_rec.essential <> p_essential) or
      (not l_api_updating)) then
  --
  hr_utility.set_location(l_proc,3);
  --
    open csr_essential;
    fetch csr_essential into l_exists;
    if csr_essential%notfound then
      hr_utility.set_message(801, 'HR_51113_JBR_ESSENTIAL');
    hr_utility.raise_error;
    end if;
    close csr_essential;
  end if;
  --
hr_utility.set_location(' Leaving :'||l_proc,4);
--
end chk_essential;
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
  (p_rec in per_jbr_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.job_requirement_id is not null) and (
    nvl(per_jbr_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_jbr_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.job_requirement_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_JOB_REQUIREMENTS'
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
-- ---------------------------------------------------------------------------
-- |--------------------------< insert_validate >----------------------------|
-- ---------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_jbr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- [ Start of changes by Kim Conley]
  --
  chk_analysis_criteria_id
    (p_analysis_criteria_id => p_rec.analysis_criteria_id);
  --
  chk_job_pos (p_position_id 		=> p_rec.position_id,
	       p_job_id         	=> p_rec.job_id,
	       p_analysis_criteria_id	=> p_rec.analysis_criteria_id,
	       p_business_group_id	=> p_rec.business_group_id);
  --
  chk_essential(p_essential => p_rec.essential);
  --
  -- Call descriptive flexfield validation routines
  --
  per_jbr_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< update_validate >----------------------------|
-- ---------------------------------------------------------------------------
Procedure update_validate(p_rec in per_jbr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Business Group
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 6);
  --
  chk_analysis_criteria_id
    (p_job_requirement_id    => p_rec.job_requirement_id,
     p_object_version_number => p_rec.object_version_number,
     p_analysis_criteria_id  => p_rec.analysis_criteria_id);
  --
  chk_job_pos
    (p_job_requirement_id    => p_rec.job_requirement_id,
     p_object_version_number => p_rec.object_version_number,
     p_position_id           => p_rec.position_id,
     p_job_id                => p_rec.job_id,
     p_analysis_criteria_id  => p_rec.analysis_criteria_id,
     p_business_group_id     => p_rec.business_group_id);
  --
  chk_essential
    (p_job_requirement_id    => p_rec.job_requirement_id,
     p_object_version_number => p_rec.object_version_number,
     p_essential             => p_rec.essential);
  --
  -- Call descriptive flexfield validation routines
  --
  per_jbr_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< delete_validate >----------------------------|
-- ---------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_jbr_shd.g_rec_type) is
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
end per_jbr_bus;

/
