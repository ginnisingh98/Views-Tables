--------------------------------------------------------
--  DDL for Package Body PER_SPP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPP_BUS" as
/* $Header: pespprhi.pkb 120.2.12010000.4 2008/11/05 14:50:57 brsinha ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_spp_bus.';  -- Global package name
-- Start of 3335915
g_debug boolean := hr_utility.debug_enabled;
-- End of 3335915

--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150) := NULL;
g_placement_id                number := NULL;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_assignment_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a assignment_id exists in table per_all_assignments_f.
--    - Checks that the assignment_id is not null
--    - Check if a placement has already been created for the assignment_id.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_assignment_id
--
--
--  Post Success:
--    If a row does exist in per_all_assignments for the given assignment id then
--     processing continues.
--
--  Post Failure:
--    If a row does not exist in per_all_assignments_f for the given assignment id
--    then an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_assignment_id
  (p_assignment_id         in per_spinal_point_placements_f.assignment_id%TYPE
  ,p_datetrack_mode        in varchar2
  ,p_placement_id          in per_spinal_point_placements_f.placement_id%TYPE
  ,p_object_version_number in
                     per_spinal_point_placements_f.object_version_number%TYPE
  ,p_effective_date        in date
  )
  -- Bug 2488727 added parameter effective date
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_assignment_id';
  --
  l_api_updating      boolean;
  l_assignment_id     number;
  l_placement_id      number;
  --
  cursor csr_valid_assignment_id is
   select assignment_id paa
     from per_all_assignments_f paa
    where paa.assignment_id = p_assignment_id
      and p_effective_date between
          effective_start_date and effective_end_date;

  cursor csr_placement_exists is
    select placement_id
    from per_spinal_point_placements_f
    where assignment_id = p_assignment_id
      and p_effective_date between
          effective_start_date and effective_end_date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check if inserting or updating with modified values
  --
  l_api_updating := per_spp_shd.api_updating
         (p_placement_id  		 => p_placement_id
         ,p_effective_date		 => p_effective_date -- Bug 2488727
         ,p_object_version_number        => p_object_version_number
         );
  --
  if ((l_api_updating and per_spp_shd.g_old_rec.assignment_id <> p_assignment_id)
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the Assignment ID is linked to a
    -- valid assignment_id on per_all_assignments
    --
    open csr_valid_assignment_id;
    fetch csr_valid_assignment_id into l_assignment_id;
    if csr_valid_assignment_id%notfound then
      --
      close csr_valid_assignment_id;
         fnd_message.set_name('PER', 'HR_289224_SPP_ASSIGNMENT_CHK');
      hr_utility.raise_error;
      --
         else
      close csr_valid_assignment_id;
    if(p_datetrack_mode = 'INSERT') then
     open csr_placement_exists;
     fetch csr_placement_exists into l_placement_id;
     if csr_placement_exists%found then
     --
     close csr_placement_exists;
         fnd_message.set_name('PER', 'HR_289225_SPP_PLACEMENT_EXIST');
     hr_utility.raise_error;
     --
     else
      close csr_placement_exists;
     end if;
    end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_assignment_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_pay_ass_ceiling >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--       check if the step_id passed is greater than the step_id for
--       the special_ceiling_step_id or the pay scale ceiling_step_id.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_step_id
--    p_parent_spine_id
--    p_assignment_id
--
--  Post Success:
--    If the the step_id's sequence is less than or equal to either of the
--    ceilings then continue.
--
--  Post Failure:
--    If the the step_id's sequence is greater than or equal to either of the
--    ceilings then throw error.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_pay_ass_ceiling
  (p_step_id               in     per_spinal_point_placements_f.step_id%TYPE
  ,p_parent_spine_id       in     per_spinal_point_placements_f.parent_spine_id%TYPE
  ,p_assignment_id         in     per_spinal_point_placements_f.assignment_id%TYPE
  ,p_effective_date	       in     date
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_pay_ass_ceiling';
  --
  l_api_updating      boolean;
  l_step_number		number;
  l_grade_ceiling	number;
  l_assignment_ceiling	number;
  l_grade_id           per_grades.grade_id%TYPE;
  l_ceiling_to_use	number;
  max_ceiling_number 	      number;
  max_special_ceiling_number  number;
  --
  Cursor csr_special_ceiling is
  select special_ceiling_step_id,
         grade_id
  from   per_all_assignments_f
  where  assignment_id = p_assignment_id
  and    p_effective_date between effective_start_date
			                           and effective_end_date;
  --
  Cursor csr_grade_ceiling is
  select pgs.ceiling_step_id
    from per_grade_spines_f pgs
   where pgs.parent_spine_id = p_parent_spine_id
     and pgs.grade_id        = l_grade_id
     and p_effective_date between pgs.effective_start_date
                              and pgs.effective_end_date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'step_id'
    ,p_argument_value => p_step_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'parent_spine_id'
    ,p_argument_value => p_parent_spine_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- First check if a special ceiling has been entered, if so then use this
  -- ceiling instead of grade ceiling, else use the grade ceiling
  --
  open  csr_special_ceiling;
  fetch csr_special_ceiling into l_assignment_ceiling, l_grade_id;
  --
  if l_assignment_ceiling is null then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Use the grade scale ceiling
    --
    open csr_grade_ceiling;
    fetch csr_grade_ceiling into l_grade_ceiling;
    close csr_grade_ceiling;
    --
    hr_utility.set_location(l_proc||' Grade Ceiling - '||l_grade_ceiling,40);
    --
    l_ceiling_to_use := l_grade_ceiling;
    --
  elsif csr_special_ceiling%found then
    --
    hr_utility.set_location(l_proc,50);
    --
    l_ceiling_to_use := l_assignment_ceiling;
    --
  end if;
  --
  close csr_special_ceiling;
  --
  hr_utility.set_location('l_ceiling_to_use - '||l_ceiling_to_use,60);
  -- --------------------------------------------------------------------------
  -- Procedure done every time an update occurs as it is possible to
  -- be on a step id and then assign a step id as the limit which is below
  -- the current step id, in which case it needs to through an error
  -- --------------------------------------------------------------------------
  select sps.sequence
  into max_ceiling_number
  from per_spinal_point_steps_f sps,
       per_grade_spines_f pgs
  where sps.step_id = l_ceiling_to_use
  and   sps.grade_spine_id = pgs.grade_spine_id
  and   pgs.parent_spine_id = p_parent_spine_id
  and   p_effective_date between sps.effective_start_date
			     and sps.effective_end_date
  and   p_effective_date between pgs.effective_start_date
			     and pgs.effective_end_date;

  -- --------------------------------------------------------------------------
  -- Select the sequence number for the passed step id
  -- --------------------------------------------------------------------------
  select sps.sequence
  into l_step_number
  from per_spinal_point_steps_f sps
  where sps.step_id = p_step_id
  and p_effective_date between sps.effective_start_date
		  	   and sps.effective_end_date;
  -- --------------------------------------------------------------------------
  -- compare the two ceiling step_id's to the passed step_id
  -- --------------------------------------------------------------------------
  if (l_step_number > max_ceiling_number) then
       fnd_message.set_name('PER', 'HR_289276_SPP_CEILING_CHK');
       hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 999);
  --
end chk_pay_ass_ceiling;
--
--  ---------------------------------------------------------------------------
--  |------------------------------< chk_reason >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that the reason being passed is valid.
--
--  Pre-conditions :
--
--  In Arguments :
--    p_reason
--    p_placement_id
--    p_effective_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Row Handler Use Only
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
--
PROCEDURE chk_reason
  (p_reason   		   IN per_spinal_point_placements_f.reason%TYPE
  ,p_effective_date        IN date) IS
  --
  -- Declare Local Variables
  --
  l_proc   varchar2(72) := g_package||'chk_reason';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if :
  -- there is a reason being passed
  --
  IF  (p_reason is not null) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the reason type exists in HR_LOOKUPS
    --
    IF hr_api.not_exists_in_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_lookup_type           => 'PLACEMENT_REASON'
      ,p_lookup_code           => p_reason) THEN
      --
      hr_utility.set_location(l_proc, 30);
      --
      fnd_message.set_name('PER', 'HR_289266_SPP_INVAL_REASON');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
END chk_reason;
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_object_version_number >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the object version number is correct for the record
--      as of the effective date
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_placement_id
--    p_effective_date
--    p_object_version_number
--
--
--  Post Success:
--    If object_version_number is correct then processing continues.
--
--  Post Failure:
--    If object_version_number is not correct
--    then an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_object_version_number
  (p_placement_id             in     per_spinal_point_placements_f.placement_id%TYPE
  ,p_object_version_number    in     per_spinal_point_placements_f.object_version_number%TYPE
  ,p_effective_date	      in     date
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_object_version_number';
  --
  l_api_updating      boolean;
  l_object_version_number number;
  --
  cursor csr_valid_ovn is
    select object_version_number spp
    from per_spinal_point_placements_f spp
    where spp.placement_id = p_placement_id
    and p_effective_date between spp.effective_start_date
          		   and spp.effective_end_date
    and object_version_number = p_object_version_number;



begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'object_version_number'
    ,p_argument_value => p_object_version_number
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check if inserting or updating with modified values
  --
  l_api_updating := per_spp_shd.api_updating
         (p_placement_id                 => p_placement_id
         ,p_effective_date               => p_effective_date
         ,p_object_version_number        => p_object_version_number
         );
  --
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the object version number is correct for the effective date
    --
    open csr_valid_ovn;
    fetch csr_valid_ovn into l_object_version_number;
    if csr_valid_ovn%notfound then
      --
      close csr_valid_ovn;
         fnd_message.set_name('PER', 'HR_289256_SPP_OBJECT_VER_NUM');
      hr_utility.raise_error;
      --
         else
      close csr_valid_ovn;
    end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_object_version_number;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_auto_inc_flag >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Checks that the auto_increment_flag has a value of 'Y' or 'N'.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_auto_increment_flag
--
--  Post Success:
--    If the flag is set to either 'Y' or 'N' then the processing continues.
--
--  Post Failure:
--    If the flag is not set to either 'Y' or 'N' then an application error
--    will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_auto_inc_flag
  (p_auto_increment_flag      in     per_spinal_point_placements_f.auto_increment_flag%TYPE
  ,p_placement_id             in     per_spinal_point_placements_f.placement_id%TYPE
  ,p_increment_number         in     per_spinal_point_placements_f.increment_number%TYPE
  ,p_object_version_number    in     per_spinal_point_placements_f.object_version_number%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_auto_inc_flag';
  --
  l_api_updating      boolean;
  l_placement_id      number;
  l_effective_date    date := sysdate;  -- not used
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'auto_increment_flag'
    ,p_argument_value => p_auto_increment_flag
    );
  --
  hr_utility.set_location(l_proc, 20);
  hr_utility.set_location('p_increment_number:'||p_increment_number,23);
  hr_utility.set_location('p_auto_increment_flag:'||p_auto_increment_flag, 24);
/*
  -- The following section was commited out to deal with old records.
  -- Increment Number is a new column and so there are cases where auto_inc_flag
  -- will be 'Y' and not changed and the user does not enter a increment number
  -- but becaudse of how this works the checks will not be done as old value
  -- will equal new value and l_api_updating will be true.
  --
  -- Check if inserting or updating with modified values
  --
  l_api_updating := per_spp_shd.api_updating
         (p_placement_id                 => p_placement_id
         ,p_effective_date               => l_effective_date  not used
         ,p_object_version_number        => p_object_version_number
         );
  --
  if ((l_api_updating and per_spp_shd.g_old_rec.auto_increment_flag <> p_auto_increment_flag)
    or
      (NOT l_api_updating))
  then
*/
  --
  --

    hr_utility.set_location(l_proc, 30);
    hr_utility.set_location('Auto Increment Flag:'||p_auto_increment_flag,31);
    --
    -- Check that the Auto Increment Flag is 'Y' or 'N'
    If (p_auto_increment_flag not in ('Y','N')  )
    --
      then
    	 hr_utility.set_location(l_proc, 35);
         fnd_message.set_name('PER', 'HR_289223_SPP_AUTO_INC_FLG_CHK');
      hr_utility.raise_error;
    --
  hr_utility.set_location(l_proc, 22);
    elsif (p_auto_increment_flag = 'Y') then
  hr_utility.set_location(l_proc, 23);
    if (NVL(p_increment_number,0) <= 0) then
         hr_utility.set_location(l_proc, 36);
         fnd_message.set_name('PER', 'HR_289243_SPP_INCREMENT_NUMBER');
        hr_utility.raise_error;
    end if;
    hr_utility.set_location(l_proc, 40);
  end if;
--  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 45);
end chk_auto_inc_flag;
--
/*
-- Commented out as not going to inforce the reason for using 'REASON' to be
-- only for a step placement change. Thus allowing datetrack history to be
-- created if only the reason changes.
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_reason_only_update >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that if a reason is the only item changing to then change the
--      datetrack mode to correction.
--      (Reasoning - 'Meaning' refers to the reson that a step_id has been
--       changed so if you are updating only the reason then a new datetrack
--       record can not be created.)
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_rec
--
--  Post Success:
--    If after checking the values being updated that the only column being
--    updated is the reason column then the datetrack mode is changed to
--    'CORRECTION'.
--
--  Post Failure:
--    If there are other variables being changed then skip process and return
--    control to the calling process.
--
--  Post Success:
--
--  Post Failure:
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_reason_only_update
  (p_rec                   in     per_spp_shd.g_rec_type
  ,p_datetrack_mode        in out nocopy varchar2
  ,p_effective_date	   in     date
  ,p_validation_start_date in out nocopy date
  ,p_validation_end_date   in out nocopy date
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_reason_only_update';
  --
  l_placement_id      per_spinal_point_placements_f.placement_id%TYPE;
  l_business_group_id per_spinal_point_placements_f.business_group_id%TYPE;
  l_assignment_id     per_spinal_point_placements_f.assignment_id%TYPE;
  l_step_id	      per_spinal_point_placements_f.step_id%TYPE;
  l_auto_inc_flag     per_spinal_point_placements_f.auto_increment_flag%TYPE;
  l_parent_spine_id   per_spinal_point_placements_f.parent_spine_id%TYPE;
  l_reason	      per_spinal_point_placements_f.reason%TYPE;
  l_old_rec           per_spp_shd.g_rec_type;
  --

  cursor csr_reason_1 is
    select placement_id,
           business_group_id,
	   assignment_id,
	   step_id,
	   auto_increment_flag,
	   parent_spine_id,
 	   reason
     from per_spinal_point_placements_f
    where placement_id = p_rec.placement_id
    and p_effective_date between effective_start_date
                                and effective_end_date;


begin
    hr_utility.set_location(l_proc, 10);
    --
    -- Check that the record matches bar the reason
    --
    open csr_reason_1;
    fetch csr_reason_1 into l_placement_id,
   			  l_business_group_id,
			  l_assignment_id,
			  l_step_id,
			  l_auto_inc_flag,
			  l_parent_spine_id,
  			  l_reason;
      --
      close csr_reason_1;

    if (NVL(l_reason, 'XZX') <> NVL(p_rec.reason , 'XZX')
     and (l_placement_id <> p_rec.placement_id
      or  l_business_group_id <> p_rec.business_group_id
      or  l_assignment_id <> p_rec.assignment_id
      or  l_auto_inc_flag <> p_rec.auto_increment_flag
      or  l_step_id <> p_rec.step_id
      or  l_parent_spine_id <> p_rec.parent_spine_id)) then
        null;
    elsif (l_reason = p_rec.reason) then
        null;

    else
       p_datetrack_mode := 'CORRECTION';
	p_validation_start_date := p_rec.effective_start_date;
        p_validation_end_date   := p_rec.effective_end_date;

    end if;

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_reason_only_update;
*/
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_parent_spine_step_id >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a parent_spine_id exists in the table per_parent_spines
--      and that the step_id exists in table per_spinal_point_steps_f.
--      (When checking the parent_spine_id, it is also copared to the table
--       per_grade_spines_f. This is so that grade_spine_id can be extracted
--       so that when checking the step_id you can use the grade spine id to
--       check that the step_id is a valid step id for the parent spine.)
--    - Checks that the effective dates for the parent_spine_id being passed is
--      between the effective dates for the parent_spine_id in the table
--      per_grade_spines_f.
--    - Checks that the effective dates for the step_id being passed is between
--      the effective dates for the step_id in the table
--      per_spinal_point_steps_f.
--
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_step_id
--    p_parent_spine_id
--    p_effective_start_date
--    p_effective_end_date
--
--
--  Post Success:
--    If a row does exist in per_spinal_point_steps_f or per_grade_spines_f for
--    the given parent spine id or the step id then processing continues.
--
--  Post Failure:
--    If a row does not exist in per_spinal_point_steps_f or per_grade_spines_f
--    for the given parent spine id or the step id then an application error
--    will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_parent_spine_step_id
  (p_step_id       	   in per_spinal_point_placements_f.step_id%TYPE
  ,p_parent_spine_id	   in per_spinal_point_placements_f.parent_spine_id%TYPE
  ,p_effective_start_date  in
                         per_spinal_point_placements_f.effective_start_date%TYPE
  ,p_effective_end_date    in
                           per_spinal_point_placements_f.effective_end_date%TYPE
  ,p_placement_id          in per_spinal_point_placements_f.placement_id%TYPE
  ,p_object_version_number in
                        per_spinal_point_placements_f.object_version_number%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_parent_spine_step_id';
  --
  l_api_updating      boolean;
  l_parent_spine_id   number;
  l_step_id	      number;
  --l_effective_date    date := sysdate; -- bug 2491732
  l_effective_date    date := p_effective_start_date; -- Bug 2491732
  l_grade_spine_id    number;
  --
  -- Validate if the parent spine alone is invalid
  --
  cursor csr_valid_parent_spine is
    select gs.parent_spine_id
    from   per_grade_spines_f gs
    where  gs.parent_spine_id = p_parent_spine_id
    and    p_effective_start_date between gs.effective_start_date
                                                   and gs.effective_end_date;
  --
  -- Validates the  dates and that the parent spine exists and step exists
  --
  cursor csr_valid_parent_spine_step_id is
    select gs.parent_spine_id,
           gs.grade_spine_id
    from per_grade_spines_f gs,
	 per_spinal_point_steps_f sps
    where gs.parent_spine_id = p_parent_spine_id
    and   gs.grade_spine_id = sps.grade_spine_id
    and   sps.step_id = p_step_id
   and   p_effective_start_date between gs.effective_start_date
                                                   and gs.effective_end_date
    and   p_effective_start_date between sps.effective_start_date
                                                   and sps.effective_end_date;


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.set_location('Step ID :'|| p_step_id, 10);
  hr_utility.set_location('Parent Spine ID :'|| p_parent_spine_id,10);
  hr_utility.set_location('Start Date in chk :'|| p_effective_start_date,10);
  hr_utility.set_location('End Date :'|| p_effective_end_date,10);
  hr_utility.set_location('Placement ID :'|| p_placement_id,10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'step_id'
    ,p_argument_value => p_step_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'parent_spine_id'
    ,p_argument_value => p_parent_spine_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_start_date'
    ,p_argument_value => p_effective_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_end_date'
    ,p_argument_value => p_effective_end_date
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check if inserting or updating with modified values
  --
  l_api_updating := per_spp_shd.api_updating
         (p_placement_id                 => p_placement_id
         ,p_effective_date               => l_effective_date
         ,p_object_version_number        => p_object_version_number
         );
  --
  hr_utility.set_location(l_proc, 25);
  --
  if ((l_api_updating and (per_spp_shd.g_old_rec.parent_spine_id <> p_parent_spine_id)
                       or (per_spp_shd.g_old_rec.step_id <> p_step_id))
    or
      (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the Parent Spine ID is linked to a
    -- valid parent_spine_id on per_parent_spines table
    -- and get the grade_spine_id from the per_grade_spines_f table
    -- based on the parent_spine_id
    --
    open csr_valid_parent_spine_step_id;
    fetch csr_valid_parent_spine_step_id into l_parent_spine_id,l_grade_spine_id;
    if csr_valid_parent_spine_step_id%notfound then
      --
      close csr_valid_parent_spine_step_id;
	 --
	 -- Check to see if parent spine is invalid
	 --
	  open csr_valid_parent_spine;
	  fetch csr_valid_parent_spine into l_parent_spine_id;
	  if csr_valid_parent_spine%notfound then

            fnd_message.set_name('PER', 'HR_289226_SPP_PARENT_SPINE');

          else

	    -- If parent spine is valid the step must be invalid

	    fnd_message.set_name('PER', 'HR_289227_SPP_STEP_ID');

          end if;

          close csr_valid_parent_spine;

      hr_utility.raise_error;
      --
         else
  	   close csr_valid_parent_spine_step_id;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_parent_spine_step_id;
--
-- Start of fix for Bug 3335915
--  ----------------------------------------------------------------------------
--  |----------------------< chk_future_asg_changes >--------------------------|
--  ----------------------------------------------------------------------------
--
--  Description:
--    - Validates that the parent assginment records does not have grade change
--      in future
--    - Should only be called in DELETE_NEXT_MODE, FUTURE_CHANGES and
--      UPDATE_OVEERRIDE datetrack mode.
--    - This validation not applicable if called from maintain_spp_asg
--      procedure.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_placement_id
--    p_effective_date
--    p_datetrack_mode
--
--
--  Post Success:
--    Continues Processing
--
--  Post Failure:
--    Error is raised and processing stops, if parent assigneent has future
--    grade changes.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
 procedure  chk_future_asg_changes
  (p_placement_id  in per_spinal_point_placements_f.placement_id%TYPE
  ,p_effective_date in date
  ,p_datetrack_mode in varchar2
   )
  as

  -- Define local variables
  --
  l_end_date date := hr_api.g_eot;
  l_grade_id number;
  l_dummy varchar2(1);
  l_asg_id number;
  l_proc varchar2(20) := 'CHK_FUTURE_ASG_CHNG';
  --
  --
  --

  --
  --Cursor to select current assignemnt grade.
  --
  cursor c_curr_grade is
     select paf.grade_id , paf.assignment_id
     from per_all_assignments_f paf, per_spinal_point_placements_f psf
     where paf.assignment_id = psf.assignment_id
     and psf.placement_id = p_placement_id
     and p_effective_date between psf.effective_start_Date and psf.effective_end_date
     and p_effective_date between paf.effective_start_Date and paf.effective_end_date;

  --
  -- Cursor to select effective end date of next spp record.
  --
  cursor c_next_spp_eed is
     select pspf.effective_end_date
     from per_spinal_point_placements_f pspf
     where pspf.placement_id = p_placement_id
     and pspf.effective_start_date > p_effective_Date
     order by pspf.effective_end_date  ;

  --
  -- cursor to check for change in grade in future assignemnt rec.
  --
  cursor c_future_grade_chg (p_grade_id number, p_end_date date) is
     select 'X'
     from per_all_assignments_f paf
     where paf.assignment_id = l_asg_id
     and paf.grade_id <> p_grade_id
     and paf.effective_end_date between p_effective_date and p_end_date;


  begin
      if g_debug then
  	 hr_utility.set_location('Entering:'|| l_proc, 10);
   	 hr_utility.set_location('p_placement_id'|| p_placement_id , 10);
  	 hr_utility.set_location('p_effective_Date'|| p_effective_date , 10);
      end if;
  --
  -- IF delete mode is Delete next change,get the
  -- EED of the next record. otherwise it has to be EOT.
  --
  IF p_datetrack_mode = 'DELETE_NEXT_CHANGE' then
    open c_next_spp_eed;
    fetch c_next_spp_eed into l_end_date;

    if c_next_spp_eed%notfound then
       l_end_date := hr_api.g_eot;
    end if;
    close c_next_spp_eed;

    if g_debug then
     hr_utility.set_location( l_proc ||': l_end_date '|| to_char(l_end_date), 30);
    end if;

  end if; -- mode = DNC

  open c_curr_grade;
  fetch c_curr_grade into l_grade_id,l_asg_id;
  if c_curr_grade%notfound then
    null;
  end if;
  close c_curr_grade;

  if g_debug then
     hr_utility.set_location( l_proc ||': grade ID '|| to_char(l_grade_id), 40);
     hr_utility.set_location( l_proc ||': ASG ID '|| to_char(l_asg_id), 40);
  end if;

  open c_future_grade_chg(p_grade_id =>l_grade_id
                         ,p_end_date => l_end_date);
  fetch c_future_grade_chg  into  l_dummy;
  if c_future_grade_chg%found then
     -- we have found grade change in future
     -- This should be avoided and error should be raised
     --
     close c_future_grade_chg;
     --null;
     if g_debug then
        hr_utility.set_location( l_proc ||'raise error', 60);
     end if;

    fnd_message.set_name (800,'PER_449912_FUT_GRD_CHG');
    fnd_message.raise_error;

  end if ;

  if c_future_grade_chg%isopen then
   close c_future_grade_chg;
  end if;

  if g_debug then
     hr_utility.set_location( 'leaving :'|| l_proc , 70);
  end if;

end chk_future_asg_changes;
--
-- End of fix for Bug 3335915
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_placement_id                         in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_spinal_point_placements_f spp
     where spp.placement_id = p_placement_id
       and pbg.business_group_id = spp.business_group_id;
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
    ,p_argument           => 'placement_id'
    ,p_argument_value     => p_placement_id
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
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_placement_id                         in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_spinal_point_placements_f spp
     where spp.placement_id = p_placement_id
       and pbg.business_group_id = spp.business_group_id;
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
    ,p_argument           => 'placement_id'
    ,p_argument_value     => p_placement_id
    );
  --
  if ( nvl(per_spp_bus.g_placement_id, hr_api.g_number)
       = p_placement_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_spp_bus.g_legislation_code;
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
    per_spp_bus.g_placement_id      := p_placement_id;
    per_spp_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date  in date
  ,p_rec             in per_spp_shd.g_rec_type
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
  hr_utility.set_location(' Entering:'||l_proc,10);
  IF NOT per_spp_shd.api_updating
      (p_placement_id                     => p_rec.placement_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
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
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
  hr_utility.set_location(' Leaving:'||l_proc,20);
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_step_id                       in number
  ,p_assignment_id                 in number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_utility.set_location(' Entering: More VAlidation'||l_proc,15);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
  /*  -- bug 7457065. As we allow end dated Steps to be used now, this check is removed.
  If ((nvl(p_step_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_spinal_point_steps_f'
            ,p_base_key_column => 'STEP_ID'
            ,p_base_key_value  => p_step_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'spinal point steps';
     raise l_integrity_error;
  End If;
  */
  If ((nvl(p_assignment_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_all_assignments_f'
            ,p_base_key_column => 'ASSIGNMENT_ID'
            ,p_base_key_value  => p_assignment_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     l_table_name := 'all assignments';
     raise l_integrity_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc,30);
  --
  --
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_placement_id                     in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'placement_id'
      ,p_argument_value => p_placement_id
      );
    --
  --
    --
  End If;
  --
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in per_spp_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
  l_effective_start_date per_spinal_point_placements_f.effective_start_date%TYPE;
  l_effective_end_date   per_spinal_point_placements_f.effective_end_date%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  l_effective_start_date := p_effective_date; -- bug 2491732
  --l_effective_start_date := hr_api.g_sys commented out for bug 2491732;
  l_effective_end_date   := hr_api.g_eot; -- do i want this?
  --
  hr_utility.set_location('Entering:chk_parent_spine_step_id : '||l_proc, 10);
  --
  hr_utility.set_location('Start Date :'|| l_effective_start_date,969);
  hr_utility.set_location('val Start Date :'|| p_validation_start_date,969);
  --
  chk_parent_spine_step_id
  (p_step_id			=> p_rec.step_id
  ,p_parent_spine_id		=> p_rec.parent_spine_id
  ,p_effective_start_date	=> l_effective_start_date
  ,p_effective_end_date		=> l_effective_end_date
  ,p_placement_id		=> p_rec.placement_id
  ,p_object_version_number	=> p_rec.object_version_number);
  --
  hr_utility.set_location('Entering: chk_assignment_id'||l_proc, 15);
  --
  chk_assignment_id
  (p_assignment_id		=> p_rec.assignment_id
  ,p_datetrack_mode		=> p_datetrack_mode
  ,p_placement_id		=> p_rec.placement_id
  ,p_object_version_number	=> p_rec.object_version_number
  ,p_effective_date             => p_effective_date);  -- Bug 2488727
  --
  hr_utility.set_location('Entering: chk_pay_ass_ceiling'||l_proc, 16);
  --
  chk_pay_ass_ceiling
  (p_step_id			=> p_rec.step_id
  ,p_parent_spine_id		=> p_rec.parent_spine_id
  ,p_assignment_id		=> p_rec.assignment_id
  ,p_effective_date		=> p_effective_date);
  --
  hr_utility.set_location('Entering: chk_auto_inc_flag'||l_proc, 18);
  --
  chk_auto_inc_flag
  (p_auto_increment_flag	=> p_rec.auto_increment_flag
  ,p_placement_id               => p_rec.placement_id
  ,p_increment_number		=> p_rec.increment_number
  ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location('Entering: chk_reason'||l_proc, 19);
  --
  chk_reason
  (p_reason			=> p_rec.reason
  ,p_effective_date		=> p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in out nocopy per_spp_shd.g_rec_type
  ,p_effective_date          in     date
  ,p_datetrack_mode          in out nocopy varchar2
  ,p_validation_start_date   in out nocopy date
  ,p_validation_end_date     in out nocopy date
  ) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
  l_effective_start_date per_spinal_point_placements_f.effective_start_date%TYPE;
  l_effective_end_date   per_spinal_point_placements_f.effective_end_date%TYPE;
--
--csr_start_end_date select the start and end date for the record being modified
--
  cursor csr_start_end_date is
  select spp.effective_start_date,
         spp.effective_end_date
  from per_spinal_point_placements_f spp
  where spp.placement_id = p_rec.placement_id
  and  spp.assignment_id = p_rec.assignment_id
  and p_effective_date between spp.effective_start_date
  		         and   spp.effective_end_date ;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  open csr_start_end_date;
  fetch csr_start_end_date into l_effective_start_date, l_effective_end_date;
  if csr_start_end_date%notfound then
   --
   close csr_start_end_date;
     fnd_message.set_name('PER', 'HR_289229_SPP_DATE_ERROR');
   hr_utility.raise_error;
  --
  else
  close csr_start_end_date;
  end if;
  --
  hr_utility.set_location('Entering: chk_object_version_number'||l_proc,7);
  --
  chk_object_version_number
  (p_placement_id		=> p_rec.placement_id
  ,p_object_version_number	=> p_rec.object_version_number
  ,p_effective_date 		=> p_effective_date
  );
  hr_utility.set_location('Entering: chk_parent_spine_step_id '||l_proc, 69);
  --
  hr_utility.set_location('p_eff Date :'|| p_effective_date,69);
  hr_utility.set_location('Start Date :'|| l_effective_start_date,69);
  hr_utility.set_location('End Date :'|| l_effective_end_date,69);
  hr_utility.set_location('val start Date :'|| p_validation_start_date,69);
  --
  chk_parent_spine_step_id
  (p_step_id                    => p_rec.step_id
  ,p_parent_spine_id            => p_rec.parent_spine_id
  ,p_effective_start_date       => p_effective_date  -- Bug 2419723
  ,p_effective_end_date         => l_effective_end_date
  ,p_placement_id               => p_rec.placement_id
  ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location('Entering: chk_assignment_id'||l_proc, 15);
  --
  chk_assignment_id
  (p_assignment_id              => p_rec.assignment_id
  ,p_datetrack_mode             => p_datetrack_mode
  ,p_placement_id               => p_rec.placement_id
  ,p_object_version_number      => p_rec.object_version_number
  ,p_effective_date             => p_effective_date);  -- Bug 2488727
  --
  hr_utility.set_location('Entering: chk_pay_ass_ceiling'||l_proc, 16);
  --
  chk_pay_ass_ceiling
  (p_step_id                    => p_rec.step_id
  ,p_parent_spine_id            => p_rec.parent_spine_id
  ,p_assignment_id              => p_rec.assignment_id
  ,p_effective_date             => p_effective_date);
  --
  hr_utility.set_location('Entering: chk_auto_inc_flag'||l_proc, 18);
  --
  chk_auto_inc_flag
  (p_auto_increment_flag        => p_rec.auto_increment_flag
  ,p_placement_id               => p_rec.placement_id
  ,p_increment_number		=> p_rec.increment_number
  ,p_object_version_number      => p_rec.object_version_number);
  --
  hr_utility.set_location('Entering: chk_reason'||l_proc, 19);
  --
  chk_reason
  (p_reason                     => p_rec.reason
  ,p_effective_date             => p_effective_date);
  --
  -- Start of fix for Bug 3335915
  --
  if (not hr_assignment_internal.g_called_from_spp_asg) and
     (p_datetrack_mode = 'UPDATE_OVERRIDE') then
     --
     chk_future_asg_changes
            (p_placement_id   => p_rec.placement_id
            ,p_effective_date => p_effective_date
            ,p_datetrack_mode => p_datetrack_mode
            );

  end if ;
  --
  -- End of fix for Bug 3335915
/*
  hr_utility.set_location('Entering: chk_reason_only_update'||l_proc, 20);
  --
  -- If the only thing that changes on the record is the reason then
  -- the record can not be updated as thereason refers to the reason why
  -- a step id has changed. Therefor the datetrack mode is set to correction
  --
  chk_reason_only_update
  (p_rec                        => p_rec
  ,p_datetrack_mode             => p_datetrack_mode
  ,p_effective_date             => p_effective_date
  ,p_validation_start_date      => p_validation_start_date
  ,p_validation_end_date        => p_validation_end_date
  );
*/
  --
  hr_utility.set_location(' Entering: dt_update_validate'||l_proc, 30);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_step_id                        => p_rec.step_id
    ,p_assignment_id                  => p_rec.assignment_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  hr_utility.set_location(' Entering: chk_non_updateable_args'||l_proc, 35);
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in per_spp_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location('Entering: chk_object_version_number'||l_proc,7);
  --
  chk_object_version_number
  (p_placement_id               => p_rec.placement_id
  ,p_object_version_number      => p_rec.object_version_number
  ,p_effective_date             => p_effective_date
  );
  -- Start of fix for Bug 3335915
  if (not hr_assignment_internal.g_called_from_spp_asg) and
     (p_datetrack_mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE'))then
     --
     hr_utility.set_location( l_proc ||'calling chk_fututre_asg_chng', 40);
     --
     chk_future_asg_changes
          (p_placement_id   => p_rec.placement_id
          ,p_effective_date => p_effective_date
          ,p_datetrack_mode => p_datetrack_mode
          );

  end if ;
  --
  -- End of fix for Bug 3335915
  --
  hr_utility.set_location('Entering: dt_delete_validate'||l_proc,8);
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_placement_id                     => p_rec.placement_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_spp_bus;

/
