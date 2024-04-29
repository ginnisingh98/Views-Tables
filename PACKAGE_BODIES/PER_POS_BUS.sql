--------------------------------------------------------
--  DDL for Package Body PER_POS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POS_BUS" as
/* $Header: peposrhi.pkb 120.0.12010000.1 2008/07/28 05:23:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_pos_bus.';  -- Global package name

-- Added for Bug fix 892165
--  -----------------------------------------------------------------
--  |-----------------------< chk_non_updateable_args >--------------|
--  -----------------------------------------------------------------
--
Procedure chk_non_updateable_args
  (p_rec            in per_pos_shd.g_rec_type
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
    IF not per_pos_shd.api_updating
    (p_position_id	         => p_rec.position_id
    ,p_object_version_number     => p_rec.object_version_number)
    THEN
    	hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    	hr_utility.set_message_token('PROCEDURE', l_proc);
    	hr_utility.set_message_token('STEP', '20');
    END IF;
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_pos_shd.g_old_rec.business_group_id
        ,hr_api.g_number
        ) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  --
  if nvl(p_rec.job_id, hr_api.g_number) <>
     nvl(per_pos_shd.g_old_rec.job_id
        ,hr_api.g_number
        ) then
     l_argument := 'job_id';
     raise l_error;
  end if;
  --
  --
  if nvl(p_rec.organization_id, hr_api.g_number) <>
     nvl(per_pos_shd.g_old_rec.organization_id
        ,hr_api.g_number
        ) then
     l_argument := 'organization_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
end chk_non_updateable_args;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<  set_security_group_id  >------------------------|
--  ---------------------------------------------------------------------------
--
--
  procedure set_security_group_id
   (
    p_position_id                in per_positions.position_id%TYPE
   ) is
  --
  -- Declare cursor
  --
     cursor csr_sec_grp is
       select inf.org_information14
      from hr_organization_information inf
         , per_positions  pos
     where pos.position_id = p_position_id
       and inf.organization_id = pos.business_group_id
       and inf.org_information_context || '' = 'Business Group Information';
  --
  -- Local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72) := g_package||'set_security_group_id';
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'position_id',
                             p_argument_value => p_position_id);
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  if csr_sec_grp%notfound then
    close csr_sec_grp;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
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
--  ----------------------------------------------------------------------------
--  |--------------------------<  chk_job_id  >--------------------------------|
--  ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that JOB_ID is not null
--
--    Validates that values entered for this column exist in the PER_JOBS
--    table.
--
--    Validates that PER_POSITIONS.DATE_EFFECTIVE cannot be less than the
--    DATE_FROM value for the JOB record on PER_JOBS.
--
--  Pre-conditions :
--    Format for p_date_effective must be correct
--
--  In Arguments :
--    p_job_id
--    p_date_effective
--
--  Post Success :
--    If a row exists in per_jobs for the job id and the date conditions
--    are met, processing continues
--
--  Post Failure :
--    If a row does not exist in per_jobs for the job id or if date conditions
--    are not met, an application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_job_id
  (p_job_id		in	number
  ,p_date_effective	in	date
  ,p_business_group_id  in      number
  )	is
--
   l_exists		varchar2(1);
   l_proc 		varchar2(72)	:=	g_package||'chk_job_id';
--
   cursor csr_valid_job_id is
     select 'x'
     from per_jobs job
     where job.job_id = p_job_id
     and job.business_group_id + 0 = p_business_group_id;
--
   cursor csr_valid_job_dates is
     select 'x'
     from per_jobs job
     where job.job_id = p_job_id
       and p_date_effective between job.date_from
       and nvl(job.date_to,hr_api.g_eot);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name			=> l_proc
    ,p_argument			=> 'job_id'
    ,p_argument_value	=> p_job_id
    );
  hr_utility.set_location(l_proc, 2);
  --
  --    Check for valid job id
  --
  open csr_valid_job_id;
  fetch csr_valid_job_id into l_exists;
  if csr_valid_job_id%notfound then
    close csr_valid_job_id;
    hr_utility.set_message(801,'HR_51090_JOB_NOT_EXIST');
    hr_utility.raise_error;
  else
    hr_utility.set_location(l_proc, 3);
    --
    --    Check p_date_effective between job date_from and date_to
    --
    close csr_valid_job_id;
    open csr_valid_job_dates;
    fetch csr_valid_job_dates into l_exists;
    if csr_valid_job_dates%notfound then
      close csr_valid_job_dates;
      hr_utility.set_message(801,'HR_51358_POS_JOB_INVALID_DATE');
      hr_utility.raise_error;
    end if;
    close csr_valid_job_dates;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end chk_job_id;
--
--
--  ---------------------------------------------------------------------------
--  | -------------------<  chk_organization_id  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that ORGANIZATION_ID is not null
--
--    Validates that values entered for this column exist in the
--    HR_ORGANIZATION_UNITS table. (I)
--
--    Validates that PER_POSITIONS.DATE_EFFECTIVE cannot be less than the
--    DATE_FROM value for the ORGANIZATION record on HR_ORGANIZATION_UNITS.
--
--  Pre-conditions:
--    Format for p_date_effective must be correct
--
--  In Arguments :
--    p_organization_id
--    p_date_effective
--
--  Post Success :
--
--    If a row exists in hr_organization_units for the organization id and the
--    date conditions are met then processing continues
--
--  Post Failure :
--
--    If a row does not exist in hr_organization_units for the organization id
--    or the date conditions are not met then an application error will be
--    raised and processing is terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ----------------------------------------------------------------------------
procedure chk_organization_id
  (p_organization_id	in number
  ,p_date_effective	in date
  ,p_business_group_id  in number
  )  is
--
   l_exists	varchar2(1);
   l_proc 		varchar2(72) :=	g_package||'chk_organization_id';
--
   cursor csr_valid_organization_id is
     select 'x'
     from per_organization_units oru
     where oru.organization_id = p_organization_id
     and oru.business_group_id + 0 = p_business_group_id
     and oru.internal_external_flag = 'INT';
--
   cursor csr_valid_organization_dates is
     select 'x'
     from hr_organization_units oru
     where oru.organization_id = p_organization_id
       and p_date_effective between oru.date_from
       and nvl(oru.date_to,hr_api.g_eot);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'organization_id'
    ,p_argument_value	=> p_organization_id
    );
  hr_utility.set_location(l_proc, 2);
  --
  --    Check for valid organization id
  --
  open csr_valid_organization_id;
  fetch csr_valid_organization_id into l_exists;
  if csr_valid_organization_id%notfound then
    close csr_valid_organization_id;
    hr_utility.set_message(801,'HR_51371_POS_ORG_NOT_EXIST');
    hr_utility.raise_error;
  else
    hr_utility.set_location(l_proc, 3);
    --
    --    Check p_date_effective between org date_from and date_to
    --
    close csr_valid_organization_id;
    open csr_valid_organization_dates;
    fetch csr_valid_organization_dates into l_exists;
    if csr_valid_organization_dates%notfound then
      close csr_valid_organization_dates;
      hr_utility.set_message(801,'HR_51359_POS_ORG_INVAL_W_DATE');
      hr_utility.raise_error;
    end if;
    close csr_valid_organization_dates;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end chk_organization_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_successor_position_id  >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--
--    Validates that if SUCCESSOR_POSITION_ID exists, it must be a valid
--    position for the business group and the successor DATE_END is on or after
--    the DATE_EFFECTIVE of the position.
--
--  Pre-conditions:
--    Format for p_date_effective must be correct
--
--  In Arguments :
--    p_position_id
--    p_business_group_id
--    p_successor_position_id
--    p_date_effective
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ----------------------------------------------------------------------------
procedure chk_successor_position_id
  (p_business_group_id		in 	number
  ,p_position_id		in      number default null
  ,p_successor_position_id	in	number
  ,p_date_effective	        in	date
  ,p_object_version_number      in      number default null
  )	is
--
   l_exists	          varchar2(1);
   l_proc 	varchar2(72) :=	g_package||'chk_successor_position_id';
   l_api_updating     boolean;
--
   cursor csr_valid_successor_position is
     select 'x'
     from per_positions pos
     where pos.position_id               = p_successor_position_id
     and pos.business_group_id + 0       = p_business_group_id
     and nvl(pos.date_end,hr_api.g_eot) >= p_date_effective ;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The successor_position_id value has changed
  --
  if p_successor_position_id is not null then
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date effective'
    ,p_argument_value => p_date_effective);
  --
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number     => p_object_version_number);
  --
  --    Check for valid successor position id
  --
  if ((l_api_updating and
       per_pos_shd.g_old_rec.successor_position_id <>
       p_successor_position_id) or
       (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 2);
    --
      open csr_valid_successor_position;
      fetch csr_valid_successor_position into l_exists;
      if csr_valid_successor_position%notfound then
        close csr_valid_successor_position;
        fnd_message.set_name('PER','PER_52979_POS_SUCC_NOT_EXIST');
        fnd_message.raise_error;
     else
      close csr_valid_successor_position;
      if(l_api_updating and p_position_id = p_successor_position_id) then
        hr_utility.set_message(801,'HR_51360_POS_SUCCESSOR_EQ_POS');
        hr_utility.raise_error;
     end if;
    end if;
   end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
end chk_successor_position_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_relief_position_id  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that if RELIEF_POSITION_ID exists, it must be a valid
--    position for the business group and the relief DATE_END is on or after
--    the DATE_EFFECTIVE of the position.
--
--  Pre-conditions:
--    Format for p_date_effective must be correct
--
--  In Arguments :
--    p_business_group_id
--    p_position_id
--    p_relief_position_id
--    p_date_effective
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- ---------------------------------------------------------------------------
procedure chk_relief_position_id
  (p_business_group_id      in number
  ,p_position_id            in number default null
  ,p_relief_position_id     in number
  ,p_date_effective         in date
  ,p_object_version_number  in number default null
  )	is
--
   l_exists	varchar2(1);
   l_proc 	varchar2(72)	:= g_package||'chk_relief_position_id';
   l_api_updating     boolean;
--
--
   cursor csr_valid_relief_position is
     select 'x'
     from per_positions pos
     where pos.position_id               = p_relief_position_id
     and pos.business_group_id + 0       = p_business_group_id
     and nvl(pos.date_end,hr_api.g_eot) >= p_date_effective ;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The successor_position_id value has changed
  --
  if p_relief_position_id is not null then
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date effective'
    ,p_argument_value => p_date_effective);
  --
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number     => p_object_version_number);
  --
  --    Check for valid relief position id
  --
  if ((l_api_updating and
       per_pos_shd.g_old_rec.relief_position_id <>
       p_relief_position_id) or
       (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 2);
    --
      open csr_valid_relief_position;
      fetch csr_valid_relief_position into l_exists;
      if csr_valid_relief_position%notfound then
        close csr_valid_relief_position;
        fnd_message.set_name('PER','PER_52980_POS_RELF_NOT_EXIST');
        fnd_message.raise_error;
     else
      close csr_valid_relief_position;
      if(l_api_updating and p_position_id = p_relief_position_id) then
        hr_utility.set_message(801,'HR_51361_POS_RELIEF_EQ_POS');
        hr_utility.raise_error;
     end if;
    end if;
   end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
end chk_relief_position_id;
--
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_location_id  >---------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Selects the value for LOCATION_ID from HR_ORGANIZATION_UNITS for the
--    position's ORGANIZATION_ID when p_location_id is null. When the
--    organization's LOCATION_ID is null the value for the business group is
--    selected.
--
--    Validates that values entered for this column exist in the
--    HR_LOCATIONS table and are active for the PER_POSITIONS.DATE_EFFECTIVE
--    i.e. HR_LOCATIONS.INACTIVE_DATE must be null or greater than
--    PER_POSITIONS.DATE_EFFECTIVE
--
--  Pre-conditions:
--    Format for p_date_effective must be correct
--
--  In Arguments :
--    p_business_group_id
--    p_organization_id
--    p_position_id
--    p_location_id
--    p_date_effective
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_location_id
  (p_position_id           in number default null
  ,p_location_id           in number
  ,p_date_effective        in date
  ,p_object_version_number in number default null)   is
--
   l_exists		varchar2(1);
   l_proc 		varchar2(72)	:=	g_package||'chk_location_id';
   l_location_id  number;
   l_api_updating boolean;
--
   cursor csr_valid_location is
     select 'x'
     from hr_locations loc
     where loc.location_id = p_location_id
       and p_date_effective < nvl(loc.inactive_date,
         hr_api.g_eot);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The location_id value has changed
  --
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
       nvl(per_pos_shd.g_old_rec.location_id,hr_api.g_number) <>
       nvl(p_location_id,hr_api.g_number)) or
       (NOT l_api_updating)) then
    --
    --    Validate that location id is valid for p_date_effective
    --
    hr_utility.set_location(l_proc, 4);
    --
    if p_location_id is not null then
    open csr_valid_location;
    fetch csr_valid_location into l_exists;
      if csr_valid_location%notfound then
        close csr_valid_location;
        hr_utility.set_message(801,'HR_51357_POS_LOC_NOT_EXIST');
        hr_utility.raise_error;
      end if;
   close csr_valid_location;
  end if;
 end if;
  --
hr_utility.set_location(' Leaving:'||l_proc, 5);
end chk_location_id;
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_position_definition_id  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that POSITION_DEFINITION_ID is not null
--
--
--  Pre-conditions:
--
--  In Arguments :
--    p_position_definition_id
--
--  Post Success :
--
--  Post Failure :
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
procedure chk_position_definition_id
  (p_position_definition_id	in	number,
   p_position_id                in      number default null,
   p_object_version_number      in      number default null
  )	is
--
   l_proc 	varchar2(72)	:= g_package||'chk_position_definition_id';
   l_exists		varchar2(1);
   l_api_updating  boolean;
--
cursor csr_pos_def is
  select 'x'
  from per_position_definitions
  where position_definition_id = p_position_definition_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'position_definition_id'
    ,p_argument_value	=> p_position_definition_id
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 3);
  --
  if ((l_api_updating and
       (per_pos_shd.g_old_rec.position_definition_id <>
          p_position_definition_id)) or
       (NOT l_api_updating)) then
--
  hr_utility.set_location(l_proc, 4);
  --
  open csr_pos_def;
  fetch csr_pos_def into l_exists;
  if csr_pos_def%notfound then
    hr_utility.set_message(801,'HR_51369_POS_DEF_NOT_EXIST');
    hr_utility.raise_error;
  end if;
  close csr_pos_def;
--
end if;
  hr_utility.set_location('Leaving '||l_proc, 5);
  --
end chk_position_definition_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_dates >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates DATE_EFFECTIVE is not null
--
--    Validates that DATE_EFFECTIVE is less than or equal to the value for
--    DATE_END on the same POSITION record
--
--  Pre-conditions:
--    Format of p_date_effective must be correct
--
--  In Arguments :
--    p_position_id
--    p_date_effective
--    p_date_end
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_dates
  (p_position_id		in	number default null
  ,p_date_effective		in	date
  ,p_date_end			in	date
  ,p_object_version_number in number default null)	is
--
   l_proc 		varchar2(72)	:= g_package||'chk_dates';
   l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name		=> l_proc
    ,p_argument		=> 'date_effective'
    ,p_argument_value	=> p_date_effective
    );
  hr_utility.set_location(l_proc, 2);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number => p_object_version_number);
  --
  if (((l_api_updating and
       (per_pos_shd.g_old_rec.date_end <> p_date_end) or
       (per_pos_shd.g_old_rec.date_effective <> p_date_effective)) or
       (NOT l_api_updating))) then
    --
    --   Check that date_effective <= date_end
    --
    hr_utility.set_location(l_proc, 3);
    --
    if p_date_effective > nvl(p_date_end,hr_api.g_eot) then
      hr_utility.set_message(801,'HR_51362_POS_INVAL_EFF_DATE');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end chk_dates;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_hrs_frequency  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that if the values for WORKING_HOURS and FREQUENCY are null that
--    the values are defaulted from HR_ORGANIZATION_UNITS for the position's
--    ORGANIZATION_ID. When organization defaults are not maintained, the
--    default values from the business group are used.
--
--    Validate that if FREQUENCY is null and WORKING_HOURS is not null
--    or if WORKING_HOURS is null and FREQUENCY is not null an error
--    is raised
--
--    Validate the FREQUENCY value against the table
--    FND_COMMON_LOOKUPS where the LOOKUP_TYPE is 'FREQUENCY'. (I,U)
--
--    Validate that if the value for WORKING_HOURS is NOT NULL,
--    that the FREQUENCY value is valid for the WORKING_HOURS value.
--
--
--  Pre-conditions:
--    None
--
--  In Arguments :
--    p_business_group_id
--    p_organization_id
--    p_position_id
--    p_working_hours
--    p_frequency
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_hrs_frequency
  (p_position_id		   in number default null
  ,p_working_hours		   in number
  ,p_frequency			   in varchar2
  ,p_object_version_number in number default null) 	is
--
   l_proc 	varchar2(72)	:= g_package||'chk_hrs_frequency';
   l_exists		      varchar2(1);
   l_working_hours    number;
   l_frequency        varchar2(30);
   l_api_updating     boolean;
--
   cursor csr_valid_freq is
     select 'x'
     from fnd_common_lookups
     where lookup_type = 'FREQUENCY'
     and lookup_code = p_frequency
     and enabled_flag = 'Y';
--
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The working hours value has changed or
  -- c) The frequency value has changed
  --
--
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
      (nvl(per_pos_shd.g_old_rec.working_hours,hr_api.g_number) <>
      nvl(p_working_hours,hr_api.g_number) or
      (nvl(per_pos_shd.g_old_rec.frequency,hr_api.g_varchar2) <>
      nvl(p_frequency,hr_api.g_varchar2)))) or
      (NOT l_api_updating)) then
      --
      --    Check for values consistency
      --
      hr_utility.set_location(l_proc, 5);
      --
    if ((p_working_hours is null and p_frequency is not null) or
      (p_working_hours is not null and p_frequency is null)) then
       fnd_message.set_name('PER','PER_52981_POS_WORK_FREQ_NULL');
       fnd_message.raise_error;
    end if;
      --
      --    Check for valid frequency against fnd_common_lookups
      --
    hr_utility.set_location(l_proc, 6);
      --
if p_frequency is not null then

    open csr_valid_freq;
    fetch csr_valid_freq into l_exists;
    if csr_valid_freq%notfound then
      hr_utility.set_message(801,'HR_51363_POS_INVAL_FREQUENCY');
      hr_utility.raise_error;
    end if;
      --
      --    Validate combinations of working_hours and frequency
      --
    hr_utility.set_location(l_proc, 7);
      --
    if ((p_working_hours > 24 AND p_frequency = 'D') or
       ((p_working_hours > 168)
        and (p_frequency = 'W')) or
       ((p_working_hours > 744)
        and (p_frequency = 'M')) or
       ((p_working_hours > 8784)
        and (p_frequency = 'Y'))) then
       hr_utility.set_message(800,'HR_POS_2_MANY_HOURS');
       hr_utility.raise_error;
    end if;
    --
  end if;
--
end if;
hr_utility.set_location(' Leaving:'||l_proc, 8);
end chk_hrs_frequency;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_probation_info >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that if the PROBATION_PERIOD is null and PROBATION_PERIOD_UNITS
--    is not null or if PROBATION_PERIOD is not null and PROBATION_PERIOS_UNITS
--    is null then an error is raised
--
--    Validate the value for PROBATION_PERIOD_UNITS against the table
--    FND_COMMON_LOOKUPS where the LOOKUP_TYPE is 'QUALIFYING_UNITS'.
--
--  Pre-conditions:
--    None
--
--  In Arguments :
--    p_position_id
--    p_probation_period
--    p_probation_period_units
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_probation_info
  (p_position_id                in number default null
  ,p_probation_period			in number
  ,p_probation_period_units 	in        varchar2
  ,p_object_version_number      in number default null) is
--
   l_proc 	varchar2(72)	:=	g_package||'chk_probation_info';
   l_api_updating     boolean;
   l_exists		varchar2(1);
--
   cursor csr_valid_unit is
     select 'x'
     from fnd_common_lookups
     where lookup_type = 'QUALIFYING_UNITS'
       and lookup_code = p_probation_period_units;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The probation_period value has changed
  -- c) The probation_period_units value has changed
  --
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
    (nvl(per_pos_shd.g_old_rec.probation_period,hr_api.g_number) <>
    nvl(p_probation_period,hr_api.g_number)) or
    (nvl(per_pos_shd.g_old_rec.probation_period_units,hr_api.g_varchar2) <>
    nvl(p_probation_period_units,hr_api.g_varchar2))) or
    (NOT l_api_updating)) then
    --
    --    Check for values consistency
    --
    hr_utility.set_location(l_proc, 2);
    --
    if (p_probation_period is null and
        p_probation_period_units is not null) or
       (p_probation_period is not null and
       p_probation_period_units is null) then
       hr_utility.set_message(801,'HR_51365_POS_PROB_UNITS_REQ');
       hr_utility.raise_error;
    else
      --
      --    Validate probation_period_units against fnd_common_lookups
      --
      hr_utility.set_location(l_proc, 3);
      --
      if p_probation_period is not null
           and p_probation_period_units is not null then
        open csr_valid_unit;
        fetch csr_valid_unit into l_exists;
        if csr_valid_unit%notfound then
          hr_utility.set_message(801,'HR_51366_POS_PROB_UNITS_INV');
          hr_utility.raise_error;
        end if;
     end if;
  end if;
end if;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end chk_probation_info;
--
--  ---------------------------------------------------------------------------
--  |--------------<  chk_replacement_required_flag >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that allowable values are ('Y','N') against
--    FND_COMMON_LOOKUPS where lookup_type = 'YES_NO'
--
--    Validate that on insert, REPLACEMENT_REQUIRED_FLAG must be defaulted to
--    'N' when null
--
--  Pre-conditions:
--    None
--
--  In Arguments :
--    p_position_id
--    p_replacement_required_flag
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
procedure chk_replacement_flag
  (p_position_id                in number default null
  ,p_replacement_required_flag  in varchar2
  ,p_object_version_number      in number default null) is
--
   l_exists		varchar2(1);
   l_proc 		varchar2(72)	:= g_package||'chk_replacement_flag';
   l_api_updating     boolean;
--
   cursor csr_valid_flag is
     select 'x'
     from fnd_common_lookups
     where lookup_type = 'YES_NO'
     and lookup_code = p_replacement_required_flag;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The replacement_required_flag value has changed
  --
if p_replacement_required_flag is not null then
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
     (nvl(per_pos_shd.g_old_rec.replacement_required_flag,hr_api.g_varchar2) <>
     nvl(p_replacement_required_flag,hr_api.g_varchar2))) or
     (NOT l_api_updating)) then
    --
    --    Validate flag replacement_required_flag against fnd_common_lookups
    --
    hr_utility.set_location(l_proc, 3);
    --
    open csr_valid_flag;
    fetch csr_valid_flag into l_exists;
    if csr_valid_flag%notfound then
      hr_utility.set_message(801,'HR_51370_POS_REPL_REQ_FLAG');
      hr_utility.raise_error;
    end if;
    --
  end if;
end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end chk_replacement_flag;
--
--
--  ---------------------------------------------------------------------------
--  |------------------<  chk_time_start_finish  >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that TIME_NORMAL_FINISH is not before TIME_NORMAL_START.
--
--    Selects TIME_NORMAL_START and TIME_NORMAL_FINISH from the corresponding
--    values on HR_ORGANIZATION_UNITS for the position's ORGANIZATION_ID when
--    the values are null. When organization defaults are not maintained, the
--    default values from the business group are used.
--
--  Pre-conditions:
--    None
--
--  In Arguments :
--    p_business_group_id
--    p_organization_id
--    p_position_id
--    p_time_normal_start
--    p_time_normal_finish
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_time_start_finish
  (p_position_id			in number default null
  ,p_time_normal_start		in  varchar2
  ,p_time_normal_finish		in  varchar2
  ,p_object_version_number  in number default null)	is
--
   l_exists		          varchar2(1);
   l_proc 		          varchar2(72)	:= g_package||'chk_time_start_finish';
   l_time_normal_start    varchar2(5);
   l_time_normal_finish   varchar2(5);
   l_api_updating     boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The time_normal_start value has changed
  -- c) The time_normal_finish value has changed
  --
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and
     (nvl(per_pos_shd.g_old_rec.time_normal_start,hr_api.g_varchar2) <>
     nvl(p_time_normal_start,hr_api.g_varchar2) or
     (nvl(per_pos_shd.g_old_rec.time_normal_finish,hr_api.g_varchar2) <>
     nvl(p_time_normal_finish,hr_api.g_varchar2)))) or
     (NOT l_api_updating)) then
  --
    --    Check for values consistency
    --
    hr_utility.set_location(l_proc, 4);
    --
    if (p_time_normal_start is not null and p_time_normal_finish is null) or
      (p_time_normal_start is null and p_time_normal_finish is not null) then
        hr_utility.set_message(801,'HR_51367_POS_TIMES_REQ');
        hr_utility.raise_error;
--
  elsif not (substr(p_time_normal_start,1,2) between '00' and '24'
        and substr(p_time_normal_start,4,2) between '00' and '59'
        and substr(p_time_normal_start,3,1) = ':') then
        hr_utility.set_message(801,'HR_51154_INVAL_TIME_FORMAT');
        hr_utility.raise_error;
--
   elsif not (substr(p_time_normal_finish,1,2) between '00' and '24'
        and substr(p_time_normal_finish,4,2) between '00' and '59'
        and substr(p_time_normal_finish,3,1) = ':') then
        hr_utility.set_message(801,'HR_51154_INVAL_TIME_FORMAT');
        hr_utility.raise_error;
end if;
    --
    --   Check that time_normal_start <= time_normal_finish
    --
    hr_utility.set_location(l_proc, 5);
    --
/*
    if p_time_normal_finish < p_time_normal_start then
      hr_utility.set_message(801,'HR_51368_POS_FIN_GT_START');
      hr_utility.raise_error;
    end if;
*/
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 6);
end chk_time_start_finish;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_status  >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate the STATUS value against the table
--    FND_COMMON_LOOKUPS where the LOOKUP_TYPE is 'POSITION_STATUS'. (I,U)
--
--
--  Pre-conditions:
--    None
--
--  In Arguments :
--    p_position_id
--    p_date_effective
--    p_status
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_status
  (p_position_id                   in number     default null
  ,p_date_effective		   in date
  ,p_status                        in varchar2
  ,p_object_version_number         in number     default null)    is
--
   l_proc 	              varchar2(72)	:= g_package||'chk_status';
   l_exists		      varchar2(1);
   l_date_effective           date;
   l_status                   varchar2(30);
   l_api_updating             boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The status value has changed or
  -- c) Inserting
  --
  l_api_updating := per_pos_shd.api_updating
    (p_position_id	         => p_position_id
    ,p_object_version_number     => p_object_version_number);
  --
  if ((l_api_updating and
     (nvl(per_pos_shd.g_old_rec.status,hr_api.g_varchar2) <>
     nvl(p_status,hr_api.g_varchar2))) or
     (NOT l_api_updating)) then
    --
    --    Check for valid status against fnd_common_lookups
    --
    hr_utility.set_location(l_proc, 2);
    --
      if p_status is not null and
	 hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_date_effective
         ,p_lookup_type    => 'POSITION_STATUS'
         ,p_lookup_code    => p_status
         )
      then
        hr_utility.set_message(801,'PER_51870_POS_STATUS_INV');
        hr_utility.raise_error;
      end if;
    --
  end if;
--
hr_utility.set_location(' Leaving:'||l_proc, 3);
end chk_status;
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
  (p_rec in per_pos_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.position_id is not null) and (
    nvl(per_pos_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_pos_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.position_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_POSITIONS'
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
--
--  ----------------------------------------------------------------------------
--  |--------------------------<  chk_ccid_unique_for_BG  >--------------------|
--  ----------------------------------------------------------------------------
--
--  PMFLETCH - New uniqueness validation routine
--
--  Desciption :
--
--    Validates that the POSITION_DEFINITION_ID is unique within a
--    position's BUSINESS GROUP
--
--  Pre-conditions :
--
--  In Arguments :
--    p_business_group_id
--    p_position_id
--    p_position_definition_id
--
--  Post Success :
--    If the POSITION_DEFINITION_ID in PER_ALL_POSITIONS table does not exist
--    for given BUSINESS_GROUP_ID then processing continues
--
--  Post Failure :
--    If the POSITION_DEFINITION_ID does exist in PER_ALL_POSITIONS table for given
--    BUSINESS_GROUP_ID, then an application error will be raised and processing
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
procedure chk_ccid_unique_for_BG
  (p_business_group_id             in      number
  ,p_position_id                   in      number
  ,p_position_definition_id        in      number
  ,p_object_version_number         in      number
  )  is
--
   l_api_updating                  boolean;
   l_exists                        varchar2(1);
   l_proc                          varchar2(72) ;
--
  -- Check there are no records in this business group that have the same
  -- position definition id  - except for the current position
   cursor csr_ccid_unique is
   SELECT 'x'
   from dual
   where exists
     (select null
         from hr_all_positions_f pos
         where pos.business_group_id = p_business_group_id
           and pos.position_definition_id = p_position_definition_id
           and pos.position_id <> nvl(p_position_id, -1)
           and hr_general.effective_date
           between pos.effective_start_date and  pos.effective_end_date
     ) ;
--
begin
  --if g_debug then
     l_proc :=      g_package||'chk_ccid_unique_for_BG';
    hr_utility.set_location('Entering:'||l_proc, 10);
  --end if;
  --
  --   Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'business_group_id'
    ,p_argument_value           => p_business_group_id
    );
  --if g_debug then
    hr_utility.set_location(l_proc, 20);
  --end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'position_definition_id'
    ,p_argument_value           => p_position_definition_id
    );
  --if g_debug then
    hr_utility.set_location(l_proc, 30);
  --end if;
  --
  l_api_updating := per_pos_shd.api_updating
         (p_position_id          => p_position_id
         ,p_object_version_number  => p_object_version_number
         );
  --if g_debug then
    hr_utility.set_location(l_proc, 70);
  --end if;
  --
  if (l_api_updating and
       (nvl(per_pos_shd.g_old_rec.position_definition_id, hr_api.g_number)
         <> nvl(p_position_definition_id, hr_api.g_number))
     )
    or  NOT l_api_updating
  then
    --if g_debug then
      hr_utility.set_location(l_proc, 80);
    --end if;
    --
    --    Check for unique ccid
    --
    open csr_ccid_unique;
    fetch csr_ccid_unique into l_exists;
    if csr_ccid_unique%found then
      close csr_ccid_unique;
      hr_utility.set_message(801,'PAY_7688_USER_POS_TAB_UNIQUE');
      hr_utility.raise_error;
    else
      close csr_ccid_unique;
      --if g_debug then
        hr_utility.set_location(l_proc, 90);
      --end if;
    end if;
  --
  end if;
  --
  --if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 100);
  --end if;
--
end chk_ccid_unique_for_BG;
--
--
--  ----------------------------------------------------------------------------
--  |--------------------------<  chk_name_unique_for_BG  >--------------------|
--  ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the position NAME is unique within position's BUSINESS GROUP
--
--  Pre-conditions :
--
--  In Arguments :
--    p_business_group_id
--    p_position_id
--    p_name
--
--  Post Success :
--    If the NAME in PER_POSITIONS table does not exist for given BUSINESS_GROUP_ID
--    then processing continues
--
--  Post Failure :
--    If the NAME does exist in PER_POSITIONS table for given BUSINESS_GROUP_ID,
--    then an application error will be raised and processing terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
procedure chk_name_unique_for_BG
  (p_business_group_id  in      number
  ,p_position_id        in      number
  ,p_name               in      varchar2
  )  is
--
   l_exists             varchar2(1);
   l_proc               varchar2(72)  :=      g_package||'chk_name_unique_for_BG';
--
   cursor csr_name_unique is
      select  'x'
        from  per_all_positions posn
       where  posn.name = p_name
         and  (p_position_id is null or posn.position_id <> p_position_id)
         and  posn.business_group_id = p_business_group_id;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --   Check mandatory parameters have been set
  --
hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'business_group_id'
    ,p_argument_value           => p_business_group_id
    );
  hr_utility.set_location(l_proc, 2);
  --
  hr_api.mandatory_arg_error
    (p_api_name                 => l_proc
    ,p_argument                 => 'name'
    ,p_argument_value           => p_name
    );
  hr_utility.set_location(l_proc, 3);
  --
  --    Check for unique name
  --
  -- Added If statement to ensure an selective open of cursor
  -- Bug 892165
  -- Amended changed this to p_name

  IF ((( p_name IS NOT NULL ) and
     NVL(per_pos_shd.g_old_rec.name,hr_api.g_varchar2)
     <> NVL(p_name,hr_api.g_varchar2))
     OR ( p_name IS NULL)) THEN

  open csr_name_unique;
  fetch csr_name_unique into l_exists;
  if csr_name_unique%found then
    close csr_name_unique;
    hr_utility.set_message(801,'PAY_7688_USER_POS_TAB_UNIQUE');
    hr_utility.raise_error;
  else
    close csr_name_unique;
  end if;

  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end chk_name_unique_for_BG;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_pos_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
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
--
-- Validate date effective and date_end
--
chk_dates
  (p_date_effective         => p_rec.date_effective,
   p_date_end               => p_rec.date_end
);
-- Validate job id
--
chk_job_id
   (p_job_id		=>	p_rec.job_id,
   p_date_effective	=>	p_rec.date_effective,
   p_business_group_id  =>      p_rec.business_group_id
);
--
hr_utility.set_location(l_proc, 7);
--
-- Validate organization id
--
chk_organization_id
  (p_organization_id	=>	p_rec.organization_id,
   p_date_effective	=>	p_rec.date_effective,
   p_business_group_id  =>      p_rec.business_group_id
);
--
hr_utility.set_location(l_proc, 8);
--
-- Validate successor position id
--
chk_successor_position_id
  (p_business_group_id       =>  p_rec.business_group_id,
  p_successor_position_id    =>  p_rec.successor_position_id,
  p_date_effective           =>  p_rec.date_effective
);
--
hr_utility.set_location(l_proc, 9);
--
-- Validate relief position id
--
chk_relief_position_id
  (p_business_group_id       =>  p_rec.business_group_id,
  p_relief_position_id	     =>  p_rec.relief_position_id,
  p_date_effective           =>  p_rec.date_effective
);
--
hr_utility.set_location(l_proc, 10);
--
-- Validate location_id
--
chk_location_id
  (p_location_id		   => p_rec.location_id,
  p_date_effective	           => p_rec.date_effective
);
--
hr_utility.set_location(l_proc, 10);
--
-- Validate position definition id
--
chk_position_definition_id
  (p_position_definition_id	=>	p_rec.position_definition_id
);
--
hr_utility.set_location(l_proc, 11);
--
-- Validate working_hours and frequency
--
chk_hrs_frequency
  (p_working_hours	  => p_rec.working_hours,
  p_frequency		  => p_rec.frequency
);
--
hr_utility.set_location(l_proc, 15);
--
-- Validate probation period and probation_period_units
--
chk_probation_info
  (p_probation_period        => p_rec.probation_period,
  p_probation_period_units  => p_rec.probation_period_units
);
--
hr_utility.set_location(l_proc, 16);
--
-- Validate time normal start and time_normal_finish
--
chk_time_start_finish
  (p_time_normal_start	  => p_rec.time_normal_start,
  p_time_normal_finish	  => p_rec.time_normal_finish
);
--
chk_replacement_flag
  (p_replacement_required_flag  => p_rec.replacement_required_flag
);
--
-- Validate status
--
chk_status
  (p_position_id            => p_rec.position_id,
   p_date_effective  	    => p_rec.date_effective,
   p_status                 => p_rec.status,
   p_object_version_number  => p_rec.object_version_number
);
-- Moved the next 11 lines to be before chk_df call
-- Bug 892165
  --
hr_utility.set_location(l_proc, 18);
--
  -- PMFLETCH ** Not using this uniqueness check anymore **
  -- Check position_name is unique for Business_group
  --
  --chk_name_unique_for_BG
  --  (p_business_group_id     =>  p_rec.business_group_id,
  --   p_position_id          => p_rec.position_id,
  --   p_name                 =>   p_rec.name
  --);
  --
  -- PMFLETCH Check position_definition_id is unique for business group
  --
  chk_ccid_unique_for_BG
    (p_business_group_id             => p_rec.business_group_id
    ,p_position_id                   => p_rec.position_id
    ,p_position_definition_id        => p_rec.position_definition_id
    ,p_object_version_number         => p_rec.object_version_number
    );
--
--
hr_utility.set_location(l_proc, 19);
--
  --
  -- Call descriptive flexfield validation routines
  --
--  per_pos_bus.chk_df(p_rec => p_rec);
--
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
End insert_validate;

-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_pos_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- Bug 892165
  -- Validate Business Group
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  -- Call to chk_non_updateable_args - Bug 892165
  --
  hr_utility.set_location(l_proc, 6);
  chk_non_updateable_args(p_rec => p_rec);
  --
  -- Call all supporting business operations
  --
  -- Validate date effective
  --
chk_dates
  (p_position_id	   => p_rec.position_id,
   p_date_effective	   => p_rec.date_effective,
   p_date_end	           => p_rec.date_end,
   p_object_version_number => p_rec.object_version_number
);
  -- Validate successor position id
  --
chk_successor_position_id
  (p_business_group_id       => p_rec.business_group_id,
  p_position_id              => p_rec.position_id,
  p_successor_position_id    =>	p_rec.successor_position_id,
  p_date_effective	     =>	p_rec.date_effective,
  p_object_version_number    => p_rec.object_version_number
);
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Validate relief position id
  --
chk_relief_position_id
  (p_business_group_id       => p_rec.business_group_id,
  p_position_id              => p_rec.position_id,
  p_relief_position_id	     =>	p_rec.relief_position_id,
  p_date_effective	     =>	p_rec.date_effective,
  p_object_version_number    => p_rec.object_version_number
);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validate location_id
  --
chk_location_id
  (p_position_id              => p_rec.position_id,
  p_location_id		     =>	p_rec.location_id,
  p_date_effective	     =>	p_rec.date_effective,
  p_object_version_number    => p_rec.object_version_number
);
  --
  hr_utility.set_location(l_proc, 12);
  --
  -- Validate working_hours and frequency
  --
chk_hrs_frequency
  (p_position_id	  => p_rec.position_id,
  p_working_hours	  => p_rec.working_hours,
  p_frequency		  => p_rec.frequency,
  p_object_version_number => p_rec.object_version_number
);
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Validate probation period and probation_period_units
  --
chk_probation_info
  (p_position_id            => p_rec.position_id,
  p_probation_period	    => p_rec.probation_period,
  p_probation_period_units  => p_rec.probation_period_units,
  p_object_version_number   => p_rec.object_version_number
);
  --
  hr_utility.set_location(l_proc, 16);
  --
  -- Validate time normal start and time_normal_finish
  --
chk_time_start_finish
  (p_position_id          => p_rec.position_id,
  p_time_normal_start	  => p_rec.time_normal_start,
  p_time_normal_finish    => p_rec.time_normal_finish,
  p_object_version_number => p_rec.object_version_number
);
--
chk_replacement_flag
  (p_position_id              => p_rec.position_id,
  p_replacement_required_flag => p_rec.replacement_required_flag,
  p_object_version_number     => p_rec.object_version_number
);
--
-- Validate position definition id
--
chk_position_definition_id
  (p_position_definition_id	=>	p_rec.position_definition_id,
   p_position_id                =>      p_rec.position_id,
   p_object_version_number      =>      p_rec.object_version_number
);
--
-- Validate status
--
chk_status
  (p_position_id            => p_rec.position_id,
   p_date_effective  	    => p_rec.date_effective,
   p_status                 => p_rec.status,
   p_object_version_number  => p_rec.object_version_number
);
  hr_utility.set_location(l_proc, 17);
  -- Moved this call to be before chk_df
  -- Bug 892165
  --
  -- PMFLETCH ** Not using this uniqueness check anymore **
  -- Check position_name is unique for Business_group
  --
  --chk_name_unique_for_BG
  --  (p_business_group_id     =>  p_rec.business_group_id,
  --   p_position_id          => p_rec.position_id,
  --   p_name                 =>   p_rec.name
  --);
  --
  -- PMFLETCH Check position_definition_id is unique for business group
  --
  chk_ccid_unique_for_BG
    (p_business_group_id             => p_rec.business_group_id
    ,p_position_id                   => p_rec.position_id
    ,p_position_definition_id        => p_rec.position_definition_id
    ,p_object_version_number         => p_rec.object_version_number
    );
  --
  --
  -- Call descriptive flexfield validation routines
  --
  --per_pos_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 18);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_pos_shd.g_rec_type) is
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
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_position_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_positions        pos
     where pos.position_id       = p_position_id
       and pbg.business_group_id = pos.business_group_id;
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
                             p_argument       => 'position_id',
                             p_argument_value => p_position_id);
  --
  open csr_leg_code;
  fetch csr_leg_code into l_legislation_code;
  if csr_leg_code%notfound then
    close csr_leg_code;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  --
  close csr_leg_code;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_pos_bus;

/
