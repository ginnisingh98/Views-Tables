--------------------------------------------------------
--  DDL for Package Body PER_OBJ_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_OBJ_BUS" as
/* $Header: peobjrhi.pkb 120.16.12010000.4 2008/11/05 05:52:10 rvagvala ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_obj_bus.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args(p_rec in per_obj_shd.g_rec_type) is
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
  if not per_obj_shd.api_updating
                (p_objective_id             => p_rec.objective_id
                ,p_object_version_number    => p_rec.object_version_number
                ) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
  hr_utility.set_location(l_proc, 6);
  --
  if p_rec.business_group_id <> per_obj_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  elsif p_rec.appraisal_id <> per_obj_shd.g_old_rec.appraisal_id then
     hr_utility.set_location(l_proc, 7);
     l_argument := 'appraisal_id';
     raise l_error;
  elsif p_rec.owning_person_id <> per_obj_shd.g_old_rec.owning_person_id then
     hr_utility.set_location(l_proc, 8);
     l_argument := 'owning_person_id';
     raise l_error;
  end if;
  hr_utility.set_location(l_proc, 11);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         ,p_base_table => per_par_shd.g_tab_nam);
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 12);
end chk_non_updateable_args;
--
--
-----------------------------------------------------------------------------
-------------------------------<chk_appraisal>-------------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the appraisal exists and is within the same business
--     group as that of objective
--
--  Pre_conditions:
--   - Valid Business group id
--
--  In Arguments:
--    p_appraisal_id
--    p_business_group_id
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- appraisal does not exist
--      -- appraisal exists but not with the same business group
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_appraisal
(p_appraisal_id		     in      per_objectives.appraisal_id%TYPE
,p_business_group_id	     in	     per_objectives.business_group_id%TYPE
)
is
--
	l_exists	     varchar2(1);
        l_proc               varchar2(72)  :=  g_package||'chk_appraisal';
        l_business_group_id  per_objectives.business_group_id%TYPE;
--
	--
	-- Cursor to check if appraisal exists
	--
	Cursor csr_appraisal_exists
          is
	select  business_group_id
	from	per_appraisals
	where   appraisal_id = p_appraisal_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_utility.set_location('Entering:'|| l_proc, 2);
  --
     if p_appraisal_id is not null then
        open csr_appraisal_exists;
        fetch csr_appraisal_exists into l_business_group_id;
	if csr_appraisal_exists%notfound then
            close csr_appraisal_exists;
            hr_utility.set_message(801,'HR_52054_OBJ_APR_NOT_EXIST');
            hr_utility.raise_error;
	else
	close csr_appraisal_exists;
	end if;
	--
	-- check if appraisal is in the same business group
	--
	hr_utility.set_location('Entering:'|| l_proc, 3);
        if l_business_group_id <> p_business_group_id then
	       hr_utility.set_message(801,'HR_52055_OBJ_DIFF_BUS_GRP');
	       hr_utility.raise_error;
        end if;
     end if;
   --
   hr_utility.set_location(l_proc, 4);
   --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.APPRAISAL_ID'
             ) then
          raise;
        end if;

end chk_appraisal;
--
--
-----------------------------------------------------------------------------
-------------------------------<chk_upd_appraisal>-------------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Update only when the existing value is null, otherwise error out
--     group as that of objective
--
--
--  In Arguments:
--    p_appraisal_id
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- appraisal does not exist
--      -- appraisal exists but not with the same business group
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_upd_appraisal
(p_appraisal_id per_appraisals.appraisal_id%TYPE
)
is
--
	l_exists	     varchar2(1);
        l_proc               varchar2(72)  :=  g_package||'chk_upd_appraisal';
--
	--
	-- Cursor to check if appraisal exists
	--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  --
  hr_utility.set_location('Entering:'|| l_proc, 2);
  --
    if( p_appraisal_id <> per_obj_shd.g_old_rec.appraisal_id ) then
     if per_obj_shd.g_old_rec.appraisal_id is not null then
	       hr_utility.set_message(801,'HR_52055_OBJ_APPR_ID');
	       hr_utility.raise_error;
     end if;
    end if;
   --
   hr_utility.set_location(l_proc, 4);
   --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.APPRAISAL_ID'
             ) then
          raise;
        end if;

end chk_upd_appraisal;
--
-----------------------------------------------------------------------------
-----------------------------<chk_owned_by_person>---------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the person_id (owning_person_id) has been entered
--     as it is a mandatory column
--   - Validates that the person is in the same business group as the
--     objective
--   - Validates that the person is valid as of the effective date
--   - Validates that if an appraisal_id is entered then the owning_person_id
--     equals to the appraisee_id in per_appraisals.
--
--  Pre_conditions:
--    - Valid Business_group_id
--
--  In Arguments:
--    p_owning_person_id
--    p_effective_date
--    p_business_group_id
--    p_appraisal_id
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--	-- owning_person_id is not set
--	-- effective_date is not set
--	-- person does not exist in the business group
--	-- person does not exist as of effective date
--	-- owning_person_id does to equal to appraisee_id in per_appraisals
--	   if appraisal_id is entered.
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_owned_by_person
(p_owning_person_id          in      per_objectives.owning_person_id%TYPE
,p_business_group_id	     in	     per_objectives.business_group_id%TYPE
,p_appraisal_id		     in	     per_objectives.appraisal_id%TYPE
,p_effective_date	     in	     date
)
is
--
	l_exists	     varchar2(1);
	l_business_group_id  per_objectives.business_group_id%TYPE;
        l_proc               varchar2(72)  :=  g_package||'chk_owned_by_person';
 	--
	--
	-- Cursor to check if the person_exists
	--
	Cursor csr_person_bg
          is
	select  business_group_id
	from	per_all_people_f
	where   person_id = p_owning_person_id;
	--
	--
	-- Cursor to check if person is valid
	-- as of effective date
	--
	Cursor csr_person_valid_date
          is
	select  'Y'
	from	per_all_people_f
	where	person_id = p_owning_person_id
	and	p_effective_date between
		effective_start_date and nvl(effective_end_date,hr_api.g_eot);
	--
	--
	-- Cursor to check if the owning_person_id is equal to
	-- the appraisee_id in per_appraisals
	--
	Cursor csr_owned_by_person
          is
	select  'Y'
	from	per_appraisals
	where	appraisal_id = p_appraisal_id
	and	appraisee_person_id = p_owning_person_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
   if (p_owning_person_id is NULL) then
	hr_utility.set_message(801, 'HR_52056_OBJ_PERSON_NULL');
       	hr_utility.raise_error;
   end if;
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );
  --
  --
  hr_utility.set_location('Entering:'|| l_proc, 2);
  --
     if p_owning_person_id is not null then
        open csr_person_bg;
        fetch csr_person_bg into l_business_group_id;
	if csr_person_bg%notfound then
            close csr_person_bg;
            hr_utility.set_message(801,'HR_52057_OBJ_PERSON_NOT_EXIST');
            hr_utility.raise_error;
        else
          close csr_person_bg;
	end if;

	hr_utility.set_location(l_proc, 3);
	-- check if business group match
  /*
	if p_business_group_id <> l_business_group_id then
	    hr_utility.set_message(801,'HR_52058_OBJ_PERSON_DIFF_BG');
            hr_utility.raise_error;
	end if;
  */
	hr_utility.set_location(l_proc, 4);
	-- check if person is valid as of effective date
	open csr_person_valid_date;
        fetch csr_person_valid_date into l_exists;
	if csr_person_valid_date%notfound then
            close csr_person_valid_date;
            hr_utility.set_message(801,'HR_52059_OBJ_PERSON_DATE_RANGE');
            hr_utility.raise_error;
	else
          close csr_person_valid_date;
	end if;

	hr_utility.set_location(l_proc, 5);
        /*
	-- check if owning_person_id = appraisee_id in per_appraisals
        -- Only perform the check if the appraisal_id is populated
	if p_appraisal_id is not null then
	   open csr_owned_by_person;
           fetch csr_owned_by_person into l_exists;
	   if csr_owned_by_person%notfound then
              close csr_owned_by_person;
              hr_utility.set_message(801,'HR_52060_OBJ_NOT_EQ_APPRAISEE');
              hr_utility.raise_error;
           else
           close csr_owned_by_person;
	   end if;
	end if;*/
    end if;
   --
 hr_utility.set_location('Leaving: '|| l_proc, 10);
--
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.OWNING_PERSON_ID'
             ) then
          raise;
        end if;

end chk_owned_by_person;
--
-- ---------------------------------------------------------------------
-- |-----------------------< chk_next_review_date >--------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that next_review_date is not later than start_date.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_objective_id
--    p_start_date
--    p_next_review_date
--    p_object_version_number
--
-- Post Success:
--    Processing continues if next_review_date is later than start_date
--    or if next_review_date is not entered.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if
--    next_review_date is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_next_review_date
  (p_objective_id          in per_objectives.objective_id%TYPE
  ,p_start_date            in per_objectives.start_date%TYPE
  ,p_next_review_date      in per_objectives.next_review_date%TYPE
  ,p_object_version_number in per_objectives.object_version_number%TYPE
  ) is
  --
  l_proc          varchar2(72)  :=  g_package||'chk_next_review_date';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
    if p_next_review_date < p_start_date then
      hr_utility.set_message(800,'HR_INV_NEXT_REV_DATE');
      hr_utility.raise_error;
    end if;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1      => 'PER_OBJECTIVES.NEXT_REVIEW_DATE'
       ) then
      raise;
    end if;
end chk_next_review_date;
--
-- ---------------------------------------------------------------------
-- |-----------------------< chk_target_date >-------------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that target_date is later than start_date.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_objective_id
--    p_start_date
--    p_target_date
--    p_object_version_number
--
-- Post Success:
--    Processing continues if target_date is not later than start_date
--    or if target_date is not entered.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if
--    start_date is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_target_date
  (p_objective_id          in per_objectives.objective_id%TYPE
  ,p_start_date            in per_objectives.start_date%TYPE
  ,p_target_date           in per_objectives.target_date%TYPE
  ,p_object_version_number in per_objectives.object_version_number%TYPE
  ) is
--
l_proc          varchar2(72)  :=  g_package||'chk_target_date';
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
    if p_target_date < p_start_date then
      hr_utility.set_message(800,'PER_52552_TARGET_DATE');
      hr_utility.raise_error;
    end if;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.TARGET_DATE'
             ) then
          raise;
        end if;

end chk_target_date;
--
--
-- ---------------------------------------------------------------------
-- |------------------------< chk_achiev_date >------------------------|
-- ---------------------------------------------------------------------
--
-- Description:
--    Validates that achievement_date is later than start_date.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_objective_id
--    p_start_date
--    p_achievement_date
--    p_complete_percent
--    p_appraisal_id
--    p_object_version_number
--
-- Post Success:
--    Processing continues if achievement_date is not later than
--    start_date or if achievement_date is not entered.
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if
--    start_date is invalid.
--
-- Access Status:
--    Internal Development use only.
--
-- ---------------------------------------------------------------------
procedure chk_achiev_date
  (p_objective_id          in per_objectives.objective_id%TYPE
  ,p_start_date            in per_objectives.start_date%TYPE
  ,p_achievement_date      in per_objectives.achievement_date%TYPE
  ,p_complete_percent      in per_objectives.complete_percent%TYPE
  ,p_appraisal_id          in per_objectives.appraisal_id%TYPE
  ,p_object_version_number in per_objectives.object_version_number%TYPE
  ,p_scorecard_id          IN per_objectives.scorecard_id%TYPE   -- new parameter added for for fixing bug#5947176...
  ) is
    --
    l_proc              varchar2(72)  :=  g_package||'chk_achiev_date';
    l_is_new_appraisal  varchar2(1);
	--
	-- Cursor to check if the appraisal is new or old
	--
    cursor csr_is_new_appraisal
      is
      select 'Y'
      from per_appraisals appr,
           per_appraisal_templates templ
      where appr.appraisal_id = p_appraisal_id
            and appr.appraisal_template_id = templ.appraisal_template_id
            and templ.objective_asmnt_type_id is not null;
    --
    --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc,5);
  --
    if p_achievement_date < p_start_date then
      hr_utility.set_message(800,'PER_52553_ACHIEV_DATE');
      hr_utility.raise_error;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- Following fix has raised a regression issue in 5201522
  -- Removing this check
  --
  --fix for Bug 5186559

  ----change the p_appraisal_id IS NULL condition to p_scorecard_id IS NOT NULL for for fixing bug#5947176
   if ( p_achievement_date > trunc(sysdate) and p_scorecard_id is not null ) then
     hr_utility.set_message(800,'HR_WPM_INV_FUTURE_ACH_DATE');
     hr_utility.raise_error;
   end if;
  -- end of  fix for bug 5186559

  --
  if (p_appraisal_id is not null) then
    open csr_is_new_appraisal;
    fetch csr_is_new_appraisal into l_is_new_appraisal;
    if csr_is_new_appraisal%found then
      close csr_is_new_appraisal;
    else
      close csr_is_new_appraisal;
      return;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 12);
  --
 /* if ((p_achievement_date is not null)
      and ((p_complete_percent is null) or (p_complete_percent <> 100))) then
    hr_utility.set_message(800,'HR_INV_CMPL_PERC_ACHIEV_DATE');
    hr_utility.raise_error;
  end if;*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.ACHIEVEMENT_DATE'
             ) then
          raise;
        end if;

end chk_achiev_date;
--
-------------------------------------------------------------------------------
------------------------------<chk_objective_delete>---------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that an objective cannot be deleted if:
--     objective is referenced in:
--		- per_performance_ratings
--
--  Pre_conditions:
--   - A valid objective_id
--
--  In Arguments:
--    p_objective_id
--    p_object_version_number
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - objective is referenced in per_performance_ratings
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_objective_delete
(p_objective_id              in      per_objectives.objective_id%TYPE
,p_object_version_number     in      per_objectives.object_version_number%TYPE
)
is
--
  l_exists		   varchar2(1);
  l_proc               varchar2(72)  :=  g_package||'chk_objective_delete';
--
  --
  -- Cursor to check if the objective is used in per_performance_ratings
  --
  cursor csr_apr_exits_in_perf_rat
  is
  select 'Y'
  from   per_performance_ratings
  where  objective_id    = p_objective_id;
  --
  -- Cursor to check if the objective is aligned with other objectives
  --
  cursor csr_is_obj_aligned
  is
  select 'Y'
  from   per_objectives
  where  aligned_with_objective_id    = p_objective_id;
  --
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'objective_id'
    ,p_argument_value => p_objective_id
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  open  csr_apr_exits_in_perf_rat;
  fetch  csr_apr_exits_in_perf_rat into l_exists;
  if csr_apr_exits_in_perf_rat%found then
     close  csr_apr_exits_in_perf_rat;
     hr_utility.set_message(801,'HR_52061_OBJ_IN_PERF_RAT');
     hr_utility.raise_error;
  else
     close  csr_apr_exits_in_perf_rat;
     open  csr_is_obj_aligned;
     fetch  csr_is_obj_aligned into l_exists;
     if  csr_is_obj_aligned%found then
         close  csr_is_obj_aligned;
         hr_utility.set_message(801,'HR_52061_OBJ_IN_PERF_RAT');
         hr_utility.raise_error;
     else
         close csr_is_obj_aligned;
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
  exception
  when app_exception.application_exception then
          if hr_multi_message.exception_add
               (p_associated_column1      => 'PER_OBJECTIVES.OBJECTIVE_ID'
               ) then
            raise;
          end if;

end chk_objective_delete;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_group_code >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the group code is a valid lookup code in HR_WPM_GROUP.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the dates are valid.
--
-- Post Failure:
--  A warning message is displayed
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_group_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_group_code             in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_group_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_obj_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_obj_shd.g_old_rec.group_code, hr_api.g_varchar2)
      = nvl(p_group_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the group code is valid
    --
    if p_group_code is not null then
      if hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'HR_WPM_GROUP'
           ,p_lookup_code           => p_group_code
           ) then
        --  Error: Invalid Group
        fnd_message.set_name('PER', 'HR_50188_WPM_INV_GROUP');
        fnd_message.raise_error;
      end if;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.GROUP_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);
--
end chk_group_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_priority_code >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the priority code is a valid lookup code in HR_WPM_PRIORITY.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the priority code is valid.
--
-- Post Failure:
--   An application error is raised if the priority code is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_priority_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_priority_code          in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_priority_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_obj_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_obj_shd.g_old_rec.priority_code, hr_api.g_varchar2)
      = nvl(p_priority_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the priority code is valid
    --
    if p_priority_code is not null then
      if hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'HR_WPM_PRIORITY'
           ,p_lookup_code           => p_priority_code
           ) then
        --  Error: Invalid Group
        fnd_message.set_name('PER', 'HR_50189_WPM_INV_PRIORITY');
        fnd_message.raise_error;
      end if;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.PRIORITY_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_priority_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_appraise_flag >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the appraise flag is set to a valid value.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the appraise flag is valid.
--
-- Post Failure:
--   An application error is raised if the appraise flag is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_appraise_flag
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_appraise_flag          in  varchar2
  ,p_scorecard_id           in  number
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_appraise_flag';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    IF p_scorecard_id IS NOT null THEN
  	  --
	    hr_api.mandatory_arg_error
        	    (p_api_name       => l_proc
	            ,p_argument       => 'p_appraise_flag'
	            ,p_argument_value => p_appraise_flag
	            );

	    --
	    -- Only proceed with validation if :
	    -- a) The current g_old_rec is current and
	    -- b) The date values have changed
	    --
	    l_api_updating := per_obj_shd.api_updating
	           (p_objective_id          => p_objective_id
	           ,p_object_version_number => p_object_version_number);
	    --
	    IF (l_api_updating
	    AND nvl(per_obj_shd.g_old_rec.appraise_flag, hr_api.g_varchar2)
	      = nvl(p_appraise_flag, hr_api.g_varchar2))
	    THEN
	        RETURN;
	    END IF;

	    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

	    --
	    -- Checks that the appraise flag is valid
	    --
	    if hr_api.not_exists_in_hrstanlookups
	         (p_effective_date        => p_effective_date
	         ,p_lookup_type           => 'YES_NO'
	         ,p_lookup_code           => p_appraise_flag
	         ) then
	      --  Error: Invalid Group
	      fnd_message.set_name('PER', 'HR_50199_WPM_APPRAISE_FLAG');
	      fnd_message.raise_error;
 	    end if;
    END IF;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.APPRAISE_FLAG'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_appraise_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_complete_percent >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the complete percent is between 0 and 100, both included.
--
-- Prerequisites:
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the complete percent is valid.
--
-- Post Failure:
--   An application error is raised if the complete percent is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_complete_percent
  (p_objective_id                in  number
  ,p_object_version_number       in  number
  ,p_complete_percent            in  number
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_complete_percent';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_obj_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_obj_shd.g_old_rec.complete_percent, hr_api.g_number)
      = nvl(p_complete_percent, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if p_complete_percent is not null then

      IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;
      --
      -- Checks that the complete_percent is between 0 and 100
      -- and raises error if it is otherwise
      --
      if (p_complete_percent < 0 ) then
         fnd_message.set_name('PER','HR_INV_CMPL_PERC');
         fnd_message.raise_error;
      end if;

      IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;

    end if;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.COMPLETE_PERCENT'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_complete_percent;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_weighting_percent >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the weighting value is not negative. (removed)
--   Checks that the weighting percent is not greater than 100.
--   Checks if the objective has been marked to be included in appraisals.
--   Checks that the weighting_percent is a valid lookup value
--
-- Prerequisites:
--   That the appraise flag has already been validated.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the weighting percent is valid.
--
-- Post Failure:
--   An application error is raised if the weighting percent is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_weighting_percent
  (p_objective_id                in  number
  ,p_object_version_number       in  number
  ,p_effective_date              in  date
  ,p_appraise_flag               in  varchar2
  ,p_weighting_percent           in  number
  ,p_weighting_over_100_warning  out nocopy boolean
  ,p_weighting_appraisal_warning out nocopy boolean
  ) is


 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_weighting_percent';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_obj_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_obj_shd.g_old_rec.appraise_flag, hr_api.g_varchar2)
      = nvl(p_appraise_flag, hr_api.g_varchar2)
    AND nvl(per_obj_shd.g_old_rec.weighting_percent, hr_api.g_number)
      = nvl(p_weighting_percent, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if p_weighting_percent is not null then

      IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;
      --
      -- Warn if the objective is not marked for appraisal.
      --
      if hr_multi_message.no_exclusive_error
          (p_check_column1      => 'PER_OBJECTIVES.APPRAISE_FLAG'
          ,p_associated_column1 => 'PER_OBJECTIVES.APPRAISE_FLAG'
          ) then
        p_weighting_appraisal_warning := (p_appraise_flag = 'N');
      end if;

      IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
      --
      -- Checks that the weighting_percent is a valid lookup value
      --
      if hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'HR_WPM_WEIGHTING'
         ,p_lookup_code           => p_weighting_percent
         ) then
        --  Error: Invalid Group
        fnd_message.set_name('PER', 'HR_50193_WPM_WEIGHT_VALUE');
        fnd_message.raise_error;
      end if;

      IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;
      --
      -- Warns that the weighting percent is greater than 100
      --
      p_weighting_over_100_warning := (p_weighting_percent > 100);

    end if;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.WEIGHTING_PERCENT'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_weighting_percent;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_measurement_style_code >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the measurement style code is a valid lookup code.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the measurement style code is valid.
--
-- Post Failure:
--   An application error is raised if the measurement style code is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_measurement_style_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_measurement_style_code in  varchar2
  ,p_scorecard_id           in  number
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_measurement_style_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    IF p_scorecard_id IS NOT null THEN
	    --
	    hr_api.mandatory_arg_error
	            (p_api_name       => l_proc
	            ,p_argument       => 'p_measurement_style_code'
	            ,p_argument_value => p_measurement_style_code
	            );

	    --
	    -- Only proceed with validation if :
	    -- a) The current g_old_rec is current and
	    -- b) The date values have changed
	    --
	    l_api_updating := per_obj_shd.api_updating
	           (p_objective_id          => p_objective_id
	           ,p_object_version_number => p_object_version_number);
	    --
	    IF (l_api_updating
	    AND nvl(per_obj_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
	      = nvl(p_measurement_style_code, hr_api.g_varchar2))
	    THEN
	        RETURN;
	    END IF;

	    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

	    --
	    -- Checks that the measurement_style_code is valid
	    --
	    if hr_api.not_exists_in_hrstanlookups
	         (p_effective_date        => p_effective_date
	         ,p_lookup_type           => 'HR_WPM_MEASURE'
	         ,p_lookup_code           => p_measurement_style_code
	         ) then
	      --  Error: Invalid Group
	      fnd_message.set_name('PER', 'HR_50194_WPM_INV_MEASR_STYL');
	      fnd_message.raise_error;
	    end if;

    END IF;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.MEASUREMENT_STYLE_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_measurement_style_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_measure_name >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the measure name has been entered when the measurement style
--   is quantitative or qualitative.
--
-- Prerequisites:
--   That the measurement style code has been validated without error.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the measure name has been entered.
--
-- Post Failure:
--   An application error is raised if the measure name has not been entered
--   when required.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_measure_name
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_measurement_style_code in  varchar2
  ,p_measure_name           in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_measure_name';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_obj_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_obj_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
      = nvl(p_measurement_style_code, hr_api.g_varchar2)
    AND nvl(per_obj_shd.g_old_rec.measure_name, hr_api.g_varchar2)
      = nvl(p_measure_name, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_OBJECTIVES.MEASUREMENT_STYLE_CODE'
        ,p_associated_column1 => 'PER_OBJECTIVES.MEASUREMENT_STYLE_CODE'
        ) then

        if p_measurement_style_code <> 'N_M'
        then
            IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

            hr_api.mandatory_arg_error
                (p_api_name       => l_proc
                ,p_argument       => 'p_measure_name'
                ,p_argument_value => p_measure_name
                );
        end if;

    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.MEASURE_NAME'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_measure_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_target_value >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the target value  hs been entered when the measurement style
--   is quantitative.
--
-- Prerequisites:
--   That the measurement style code has been validated without error.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the target value has been entered.
--
-- Post Failure:
--   An application error is raised if the target value has not been entered
--   when required.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_target_value
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_measurement_style_code in  varchar2
  ,p_target_value           in  number
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_target_value';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_obj_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_obj_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
      = nvl(p_measurement_style_code, hr_api.g_varchar2)
    AND nvl(per_obj_shd.g_old_rec.target_value, hr_api.g_number)
      = nvl(p_target_value, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_OBJECTIVES.MEASUREMENT_STYLE_CODE'
        ,p_associated_column1 => 'PER_OBJECTIVES.MEASUREMENT_STYLE_CODE'
        ) then

    if p_measurement_style_code = 'QUANT_M'
        then
            IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

            hr_api.mandatory_arg_error
                (p_api_name       => l_proc
                ,p_argument       => 'p_target_value'
                ,p_argument_value => p_target_value
                );
        end if;

    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.TARGET_VALUE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_target_value;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_uom_code >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the UOM code is a valid lookup code.
--
-- Prerequisites:
--   That the measurement style code has been validated without error.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the UOM code is valid.
--
-- Post Failure:
--   An application error is raised if the UOM code is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_uom_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_measurement_style_code in  varchar2
  ,p_uom_code               in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_uom_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_obj_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_obj_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
      = nvl(p_measurement_style_code, hr_api.g_varchar2)
    AND nvl(per_obj_shd.g_old_rec.uom_code, hr_api.g_varchar2)
      = nvl(p_uom_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_OBJECTIVES.MEASUREMENT_STYLE_CODE'
        ,p_associated_column1 => 'PER_OBJECTIVES.MEASUREMENT_STYLE_CODE'
        ) then

        if p_measurement_style_code = 'QUANT_M'
        then
            IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

            hr_api.mandatory_arg_error
                (p_api_name       => l_proc
                ,p_argument       => 'p_uom_code'
                ,p_argument_value => p_uom_code
                );
        end if;

    end if;

    IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;

    --
    -- Checks that the UOM code is valid
    --
    if p_uom_code is not null then
        if hr_api.not_exists_in_hrstanlookups
             (p_effective_date        => p_effective_date
             ,p_lookup_type           => 'HR_WPM_MEASURE_UOM'
             ,p_lookup_code           => p_uom_code
             ) then
          --  Error: Invalid Group
          fnd_message.set_name('PER', 'HR_50195_WPM_INV_UOM');
          fnd_message.raise_error;
        end if;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.UOM_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_uom_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_measure_type_code >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the measure type is a valid lookup code.
--
-- Prerequisites:
--   That the measurement style code has been validated without error.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the measure type code is valid.
--
-- Post Failure:
--   An application error is raised if the measure type code is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_measure_type_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_measurement_style_code in  varchar2
  ,p_measure_type_code      in  varchar2
  ) is

 -- Declare local variables

  l_proc         varchar2(72)  :=  g_package||'chk_measure_type_code';
  l_api_updating boolean;

begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 1); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_obj_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_obj_shd.g_old_rec.measurement_style_code, hr_api.g_varchar2)
      = nvl(p_measurement_style_code, hr_api.g_varchar2)
    AND nvl(per_obj_shd.g_old_rec.measure_type_code, hr_api.g_varchar2)
      = nvl(p_measure_type_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_OBJECTIVES.MEASUREMENT_STYLE_CODE'
        ,p_associated_column1 => 'PER_OBJECTIVES.MEASUREMENT_STYLE_CODE'
        ) then

        if p_measurement_style_code = 'QUANT_M'
        then
            IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

            hr_api.mandatory_arg_error
                (p_api_name       => l_proc
                ,p_argument       => 'p_measure_type_code'
                ,p_argument_value => p_measure_type_code
                );
        end if;

    end if;

    IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;

    --
    -- Checks that the measure type code is valid
    --
    if p_measure_type_code is not null then
      if hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'HR_WPM_MEASURE_TYPE'
           ,p_lookup_code           => p_measure_type_code
           ) then
        --  Error: Invalid Group
        fnd_message.set_name('PER', 'HR_50196_WPM_INV_MEASR_TYPE');
        fnd_message.raise_error;
      end if;
    end if;

    IF g_debug THEN hr_utility.set_location(' Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_OBJECTIVES.MEASURE_TYPE_CODE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

end chk_measure_type_code;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_scorecard_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the specified scorecard exists
--
-- Pre Conditions:
--   The scorecard must already exist.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the scorecard is valid.
--
-- Post Failure:
--   An application error is raised if the scorecard does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_scorecard_id
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_scorecard_id           IN  number
  ) IS

  --
  l_proc          varchar2(72) := g_package || 'chk_scorecard_id';
  l_api_updating  boolean;
  l_scorecard_id  number;
  --

  CURSOR csr_chk_scard_id IS
  SELECT psc.scorecard_id
  FROM   per_personal_scorecards psc
  WHERE  psc.scorecard_id = p_scorecard_id;
--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The scorecard value has changed
  --
  l_api_updating := per_obj_shd.api_updating
         (p_objective_id          => p_objective_id
         ,p_object_version_number => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_obj_shd.g_old_rec.scorecard_id, hr_api.g_number)
    = nvl(p_scorecard_id, hr_api.g_number))
  THEN
      RETURN;
  END IF;
  --
  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 11); END IF;
  --
  IF nvl(p_scorecard_id,hr_api.g_number) <> hr_api.g_number THEN
    --
    -- Check that scorecard exists.
    --
    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;
    OPEN  csr_chk_scard_id;
    FETCH csr_chk_scard_id INTO l_scorecard_id;
    CLOSE csr_chk_scard_id;

    IF l_scorecard_id IS null THEN
      fnd_message.set_name('PER', 'HR_WPM_INVALID_SCORECARD');
      fnd_message.raise_error;
    END IF;

  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_OBJECTIVES.SCORECARD_ID')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_scorecard_id;
--
--=======================================================================================
--
-----------------------------------------------------------------------------
---------------------------<chk_copied_from_lib_id>--------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the copied from objective library exists
--
--  Pre_conditions:
--   - None
--
--  In Arguments:
--    p_copied_from_lib_id
--
--  Post Success:
--    Process continues if :
--     in parameter is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- Objective library does not exist
--
--  Access Status
--    Internal row Handler Use Only.
--
--
procedure chk_copied_from_lib_id
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_copied_from_lib_id	    in  number
  )
is
--
  l_exists       varchar2(1);
  l_proc         varchar2(72)  :=  g_package||'chk_copied_from_lib_id';
  l_api_updating boolean;
--
	--
	-- Cursor to check if appraisal exists
	--
	Cursor csr_objlib_exists
          is
	select  'Y'
	from	per_objectives_library
	where   objective_id = p_copied_from_lib_id;
--
begin
  --
  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The copied_from_library_id value has changed
  --
  l_api_updating := per_obj_shd.api_updating
         (p_objective_id          => p_objective_id
         ,p_object_version_number => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_obj_shd.g_old_rec.copied_from_library_id, hr_api.g_number)
    = nvl(p_copied_from_lib_id, hr_api.g_number))
  THEN
      RETURN;
  END IF;
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 11); END IF;
  --
  if nvl(p_copied_from_lib_id,hr_api.g_number) <> hr_api.g_number then
     open csr_objlib_exists;
     fetch csr_objlib_exists into l_exists;
     if csr_objlib_exists%notfound then
        close csr_objlib_exists;
        hr_utility.set_message(800,'HR_WPM_INV_COPY_FRM_LIB_ID');
        hr_utility.raise_error;
     else
        close csr_objlib_exists;
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.COPIED_FROM_LIBRARY_ID'
             ) then
          raise;
        end if;

end chk_copied_from_lib_id;
--
-----------------------------------------------------------------------------
---------------------------<chk_copied_from_obj_id>--------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the copied from objective exists
--
--  Pre_conditions:
--   - None
--
--  In Arguments:
--    p_copied_from_lib_id
--
--  Post Success:
--    Process continues if :
--     in parameter is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- Objective library does not exist
--
--  Access Status
--    Internal row Handler Use Only.
--
--
procedure chk_copied_from_obj_id
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_copied_from_obj_id	    in  number
  )
is
--
  l_exists	  varchar2(1);
  l_proc          varchar2(72)  :=  g_package||'chk_copied_from_obj_id';
  l_api_updating  boolean;
  --
  -- Cursor to check if appraisal exists
  --
  Cursor csr_obj_exists
    is
    select  'Y'
    from	per_objectives
    where   objective_id = p_copied_from_obj_id;
--
begin
  --
  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The copied_from_objective_id value has changed
  --
  l_api_updating := per_obj_shd.api_updating
         (p_objective_id          => p_objective_id
         ,p_object_version_number => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_obj_shd.g_old_rec.copied_from_objective_id, hr_api.g_number)
    = nvl(p_copied_from_obj_id, hr_api.g_number))
  THEN
      RETURN;
  END IF;
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 11); END IF;
  --
  if nvl(p_copied_from_obj_id,hr_api.g_number) <> hr_api.g_number then
     open csr_obj_exists;
     fetch csr_obj_exists into l_exists;
     if csr_obj_exists%notfound then
        close csr_obj_exists;
        hr_utility.set_message(800,'HR_WPM_INV_COPY_FRM_OBJ_ID');
        hr_utility.raise_error;
     else
        close csr_obj_exists;
     end if;
     --
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.COPIED_FROM_OBJECTIVE_ID'
             ) then
          raise;
        end if;

end chk_copied_from_obj_id;
--
--
-----------------------------------------------------------------------------
---------------------------<chk_aligned_with_obj_id>-------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the copied from objective exists
--
--  Pre_conditions:
--   - None
--
--  In Arguments:
--    p_aligned_with_obj_id
--
--  Post Success:
--    Process continues if :
--     in parameter is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- Objective does not exist
--      --
--
--  Access Status
--    Internal row Handler Use Only.
--
--
PROCEDURE chk_aligned_with_obj_id
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_aligned_with_obj_id    IN  number
  ,p_scorecard_id           IN  number
  )
IS
--
  l_exists	  VARCHAR2(1);
  l_proc          VARCHAR2(72)  :=  g_package||'chk_aligned_with_obj_id';
  l_api_updating  boolean;
--
  --
  -- Cursor to check if source objective exists
  --
  /*CURSOR csr_obj_exists
  IS
  SELECT
    ppsc.plan_id,ppsc.scorecard_id,ppsc.person_id
  FROM
    per_objectives          pobj
   ,per_personal_scorecards ppsc
  -- ,per_perf_mgmt_plans     ppln
  WHERE
      pobj.objective_id = p_aligned_with_obj_id
  AND pobj.scorecard_id = ppsc.scorecard_id;
  --and ppsc.plan_id      = ppln.plan_id;*/
CURSOR csr_obj_exists
  IS
    SELECT
      NVL(ppsc.plan_id,ap.plan_id) PLAN_ID,
      NVL(ppsc.scorecard_id,ppsc2.scorecard_id)            SCORECARD_ID,
      NVL(ppsc.person_id,ap.appraisee_person_id) SOURCE_PERSON_ID
    FROM
      per_objectives          pobj
     ,per_personal_scorecards ppsc
     ,per_personal_scorecards ppsc2
     ,per_appraisals ap
     WHERE
        pobj.objective_id = p_aligned_with_obj_id
    AND pobj.scorecard_id = ppsc.scorecard_id (+)
    AND pobj.appraisal_id = ap.appraisal_id (+)
    AND ap.plan_id = ppsc2.plan_id(+)
    AND ap.appraisee_person_id = ppsc2.person_id(+);
  --
  l_source_plan_id      per_personal_scorecards.plan_id%TYPE;
  l_source_scorecard_id per_personal_scorecards.scorecard_id%TYPE;
  l_source_person_id    per_personal_scorecards.person_id%TYPE;
  --
  -- Cursor to get target plan
  --
  CURSOR csr_target_plan
  IS
  SELECT
    plan_id,person_id
  FROM
    per_personal_scorecards
  WHERE
    scorecard_id = p_scorecard_id;
  --
  l_target_plan_id   per_personal_scorecards.plan_id%TYPE;
  l_target_person_id per_personal_scorecards.person_id%TYPE;
  --
  -- Cursor to check if source and target persons is same
  --
  CURSOR csr_chk_person
  IS
  SELECT 'Y'
  FROM
    per_objectives          pobj
   ,per_personal_scorecards ppsc
   ,per_perf_mgmt_plans     ppln
  WHERE
       ppln.plan_id      = l_source_plan_id
  AND  ppln.plan_id      = ppsc.plan_id
  AND  ppsc.person_id    = l_source_person_id
  AND  pobj.objective_id = p_aligned_with_obj_id;
  --
  l_same_person VARCHAR2(1);
  --
  -- Cursor to check whetehr the objective is shared
  --
  CURSOR csr_chk_shared
  IS
  SELECT
    'Y'
  FROM
    per_scorecard_sharing
  WHERE
    scorecard_id = l_source_scorecard_id
  AND person_id  = l_target_person_id;
  --
  l_shared VARCHAR2(1);
  --
--
BEGIN
  --
  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The aligned_with_obj_id value has changed
  --
  l_api_updating := per_obj_shd.api_updating
         (p_objective_id          => p_objective_id
         ,p_object_version_number => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_obj_shd.g_old_rec.aligned_with_objective_id, hr_api.g_number)
    = nvl(p_aligned_with_obj_id, hr_api.g_number))
  THEN
      RETURN;
  END IF;
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 11); END IF;
  --
  IF nvl(p_aligned_with_obj_id,-1) <> -1 THEN
     OPEN csr_obj_exists;
     FETCH csr_obj_exists INTO l_source_plan_id,l_source_scorecard_id,l_source_person_id;
     IF csr_obj_exists%NOTFOUND THEN
        CLOSE csr_obj_exists;
        --The Objective that you are aligning with does not exist
        hr_utility.set_message(800,'HR_WPM_INV_ALIGNED_WITH_OBJ_ID');
        hr_utility.raise_error;
     ELSE
        CLOSE csr_obj_exists;
     END IF;
       --
     --
     -- Check the source and target objectives are within the same plan
     --
     OPEN csr_target_plan;
     FETCH csr_target_plan INTO l_target_plan_id,l_target_person_id;
     IF (csr_target_plan%FOUND AND l_target_plan_id <> l_source_plan_id) THEN
        CLOSE csr_target_plan;
        -- You can not align this objective in a different performance management plan
        hr_utility.set_message(800,'HR_WPM_INV_ALIGN_DIFF_PLANS');
        hr_utility.raise_error;
     ELSE
        CLOSE csr_target_plan;
     END IF;
     --
     -- Check that the person is not the same for both the objectives (target and aligned-to obj)
     /*
     OPEN csr_chk_person;
     FETCH csr_chk_person INTO l_same_person;
     IF csr_chk_person%FOUND  THEN
        CLOSE csr_chk_person;
        -- You can not align this objective to the same person who has this objective allocated.
        hr_utility.set_message(800,'HR_WPM_INV_ALIGN_SAME_PER');
        hr_utility.raise_error;
     ELSE
        CLOSE csr_chk_person;
     END IF;
     */
     IF l_target_person_id = l_source_person_id  THEN
        -- You can not align this objective to the same person who has this objective allocated.
        hr_utility.set_message(800,'HR_WPM_INV_ALIGN_SAME_PER');
        hr_utility.raise_error;
     END IF;
     --
     -- Check whether the objective to be aligned with is shared
     --
     OPEN csr_chk_shared;
     FETCH csr_chk_shared INTO l_shared;
     IF csr_chk_shared%NOTFOUND  THEN
        CLOSE csr_chk_shared;
        -- You can not align this objective as this objective is not shared.
        hr_utility.set_message(800,'HR_WPM_INV_ALIGN_SHR_ACCESS');
        hr_utility.raise_error;
     ELSE
        CLOSE csr_chk_shared;
     END IF;
     --
  END IF;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
EXCEPTION
WHEN app_exception.application_exception THEN
        IF hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.ALIGNED_WITH_OBJECTIVE_ID'
             ) THEN
          RAISE;
        END IF;

END chk_aligned_with_obj_id;
--
-----------------------------------------------------------------------------
---------------------------<chk_copied_from_sources>-------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the copied from source is either from objective library
--     or from objectives but not both
--
--  Pre_conditions:
--   - None
--
--  In Arguments:
--    p_copied_from_lib_id
--    p_copied_from_obj_id
--
--  Post Success:
--    Process continues if :
--     Either of the parameter is NULL.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- Copied from Objective and Copied from library exist
--
--  Access Status
--    Internal row Handler Use Only.
--
--
procedure chk_copied_from_sources
  (p_copied_from_obj_id	in  number
  ,p_copied_from_lib_id	in  number
  )
is
--
  l_exists	     varchar2(1);
  l_proc             varchar2(72)  :=  g_package||'chk_copied_from_sources';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  if (nvl(p_copied_from_obj_id,-1) <> -1 AND nvl(p_copied_from_lib_id,-1) <> -1)
  then
     hr_utility.set_message(800,'HR_WPM_INV_COPY_SOURCES');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 10);
--
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.COPIED_FROM_OBJECTIVE_ID'
             ) then
          raise;
        end if;

end chk_copied_from_sources;
--
--
-----------------------------------------------------------------------------
---------------------------<chk_sharing_access_code>-------------------------
-----------------------------------------------------------------------------
--
--  Description:
--   - Validates that the copied from source is either from objective library
--     or from objectives but not both
--
--  Pre_conditions:
--   - None
--
--  In Arguments:
--    p_copied_from_lib_id
--    p_copied_from_obj_id
--
--  Post Success:
--    Process continues if :
--     in parameter is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      -- Objective library does not exist
--
--  Access Status
--    Internal row Handler Use Only.
--
--
procedure chk_sharing_access_code
  (p_objective_id           in  number
  ,p_object_version_number  in  number
  ,p_effective_date         in  date
  ,p_sharing_access_code    in      per_objectives.sharing_access_code%TYPE
)
is
--
  l_exists	 varchar2(1);
  l_proc         varchar2(72)  :=  g_package||'chk_sharing_access_code';
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The sharing access code values have changed
    --
    l_api_updating := per_obj_shd.api_updating
           (p_objective_id          => p_objective_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_obj_shd.g_old_rec.sharing_access_code, hr_api.g_varchar2)
      = nvl(p_sharing_access_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the group code is valid
    --
    if p_sharing_access_code is not null then
      if hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'HR_WPM_OBJECTIVE_SHARING'
           ,p_lookup_code           => p_sharing_access_code
           ) then
        --  Error: Invalid Code
        fnd_message.set_name('PER', 'HR_WPM_INV_SHR_ACCESS_CDE');
        fnd_message.raise_error;
      end if;
    end if;
  hr_utility.set_location('Leaving: '|| l_proc, 10);
  --
exception
when app_exception.application_exception then
        if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_OBJECTIVES.SHARING_ACCESS_CODE'
             ) then
          raise;
        end if;

end chk_sharing_access_code;
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
  (p_rec in per_obj_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.objective_id is not null) and (
     nvl(per_obj_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2) or

     nvl(per_obj_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
     nvl(p_rec.attribute21, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
     nvl(p_rec.attribute22, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
     nvl(p_rec.attribute23, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
     nvl(p_rec.attribute24, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
     nvl(p_rec.attribute25, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
     nvl(p_rec.attribute26, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
     nvl(p_rec.attribute27, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
     nvl(p_rec.attribute28, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
     nvl(p_rec.attribute29, hr_api.g_varchar2) or
     nvl(per_obj_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
     nvl(p_rec.attribute30, hr_api.g_varchar2)))


     or
     (p_rec.objective_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_OBJECTIVES'
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
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_obj_shd.g_rec_type
			 ,p_effective_date in date
                         ,p_weighting_over_100_warning   out nocopy boolean
                         ,p_weighting_appraisal_warning  out nocopy boolean
                         ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
  ,p_associated_column1 => per_obj_shd.g_tab_nam ||
                             '.BUSINESS_GROUP_ID');  -- Validate Bus Grp

  hr_multi_message.end_validation_set;
  --
  -- check if the name column has been entered
  if (p_rec.name is NULL) then
	hr_utility.set_message(801, 'HR_52062_OBJ_NAME_NULL');
       	hr_utility.raise_error;
  end if;
  --
  -- check if the start date has been entered
  if (p_rec.start_date is NULL) then
	hr_utility.set_message(801, 'HR_52063_OBJ_START_DATE_NULL');
       	hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 4);
  --
  -- check if target_date is not later that start_date
  --
  per_obj_bus.chk_target_date
  (p_objective_id              => p_rec.objective_id
  ,p_start_date                => p_rec.start_date
  ,p_target_date               => p_rec.target_date
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
  -- check if achievement_date is not later that start_date
  --
  per_obj_bus.chk_achiev_date
  (p_objective_id              => p_rec.objective_id
  ,p_start_date                => p_rec.start_date
  ,p_achievement_date          => p_rec.achievement_date
  ,p_complete_percent          => p_rec.complete_percent
  ,p_appraisal_id              => p_rec.appraisal_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_scorecard_id => p_rec.scorecard_id -- added new parameter for fixing bug#5947176
  );
  --
  hr_utility.set_location('Leaving:'||l_proc, 6);
  -- check appraisal
  per_obj_bus.chk_appraisal
  (p_appraisal_id              	=>	p_rec.appraisal_id
  ,p_business_group_id	     	=>	p_rec.business_group_id
  );
  hr_utility.set_location(l_proc, 7);
  -- check owned_by_person
  -- if owning_person_id = -3, then do not call business rule as
  -- business rule will fail, since this is coming from eligibility
  -- and publish plan process.
  if p_rec.owning_person_id <> -3 then
    per_obj_bus.chk_owned_by_person
    (p_owning_person_id        	=> p_rec.owning_person_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_appraisal_id		=> p_rec.appraisal_id
    ,p_effective_date		=> p_effective_date
    );
  end if;
/*
 * Added for WPM changes -- =========================================================
 *
 */
  --
  -- Check the group code.
  --
  chk_group_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_group_code                  => p_rec.group_code);

  hr_utility.set_location(l_proc, 20);
  --
  -- Check the priority.
  --
  chk_priority_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_priority_code               => p_rec.priority_code);

  hr_utility.set_location(l_proc, 25);
  --
  -- Check the appraise flag.
  --
  chk_appraise_flag
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_appraise_flag               => p_rec.appraise_flag
    ,p_scorecard_id                => p_rec.scorecard_id);

  hr_utility.set_location(l_proc, 30);
  --
  -- Check the weighting percent.
  --
  chk_weighting_percent
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_appraise_flag               => p_rec.appraise_flag
    ,p_weighting_percent           => p_rec.weighting_percent
    ,p_weighting_over_100_warning  => p_weighting_over_100_warning
    ,p_weighting_appraisal_warning => p_weighting_appraisal_warning);

  hr_utility.set_location(l_proc, 35);

  --
  -- Check the measurement style code.
  --
  chk_measurement_style_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_scorecard_id                => p_rec.scorecard_id);


  hr_utility.set_location(l_proc, 40);
  --
  -- Check the measure name.
  --
  chk_measure_name
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_measure_name                => p_rec.measure_name);

  hr_utility.set_location(l_proc, 45);
  --
  -- Check the target value.
  --
  chk_target_value
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_target_value                => p_rec.target_value);

  hr_utility.set_location(l_proc, 50);
  --
  -- Check the UOM code.
  --
  chk_uom_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_uom_code                    => p_rec.uom_code);

  hr_utility.set_location(l_proc, 55);
  --
  -- Check the measure type code.
  --
  chk_measure_type_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_measure_type_code           => p_rec.measure_type_code);

  hr_utility.set_location(l_proc, 60);
  --
  -- check if scorecard_id exists
  --
IF p_rec.scorecard_id <> -1 THEN --- added for mass cascasde
  per_obj_bus.chk_scorecard_id
  (p_objective_id                  => p_rec.objective_id
  ,p_object_version_number         => p_rec.object_version_number
  ,p_scorecard_id                  => p_rec.scorecard_id
  );
END if;
  hr_utility.set_location(l_proc, 62);
  --
  -- check if complete percent is valid
  --
  hr_utility.set_location(l_proc, 66);
  per_obj_bus.chk_complete_percent
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_complete_percent            => p_rec.complete_percent);
  hr_utility.set_location(l_proc, 67);
  --
  -- check if next_review_date is later than start_date
  --
  per_obj_bus.chk_next_review_date
  (p_objective_id                  => p_rec.objective_id
  ,p_start_date                    => p_rec.start_date
  ,p_next_review_date              => p_rec.next_review_date
  ,p_object_version_number         => p_rec.object_version_number
  );
  hr_utility.set_location(l_proc, 71);
  --
  chk_copied_from_lib_id
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_copied_from_lib_id          => p_rec.copied_from_library_id
    );
  hr_utility.set_location(l_proc, 72);
  --
  chk_copied_from_obj_id
    (p_objective_id               => p_rec.objective_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_copied_from_obj_id         => p_rec.copied_from_objective_id
    );
  hr_utility.set_location(l_proc, 73);
  --
IF p_rec.scorecard_id <> -1 THEN --- added for mass cascasde
  chk_aligned_with_obj_id
    (p_objective_id               => p_rec.objective_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_aligned_with_obj_id        => p_rec.aligned_with_objective_id
    ,p_scorecard_id               => p_rec.scorecard_id
    );
  END if;
  hr_utility.set_location(l_proc, 74);
  --
/* temporarily commented for functional justification
  chk_copied_from_sources
    (p_copied_from_obj_id         => p_rec.copied_from_objective_id
    ,p_copied_from_lib_id         => p_rec.copied_from_library_id
    );
*/
  hr_utility.set_location(l_proc, 75);
  --
  chk_sharing_access_code
    (p_objective_id               => p_rec.objective_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_effective_date             => p_effective_date
    ,p_sharing_access_code        => p_rec.sharing_access_code
    );
  hr_utility.set_location(l_proc, 76);
/*
 * End of changes added for WPM --===============================================
 */

 --
 -- Call descriptive flexfield validation routines
 --
 IF hr_general.get_calling_context <>'FORMS' THEN
  per_obj_flex.df(p_rec => p_rec);
 END IF;
 --
 per_obj_bus.chk_df(p_rec => p_rec);
 --
 hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_obj_shd.g_rec_type
			 ,p_effective_date in date
                         ,p_weighting_over_100_warning   out nocopy boolean
                         ,p_weighting_appraisal_warning  out nocopy boolean
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
  -- Validate business_group_id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
  ,p_associated_column1 => per_obj_shd.g_tab_nam ||
                             '.BUSINESS_GROUP_ID'
   );

  hr_multi_message.end_validation_set;

  --
  -- Rule Check non-updateable fields cannot be updated
  --
  chk_non_updateable_args(p_rec	=> p_rec);
  --
  hr_utility.set_location('Entering:'||l_proc, 6);
  -- check if the name column has been entered
  if (p_rec.name is NULL) then
	hr_utility.set_message(801, 'HR_52062_OBJ_NAME_NULL');
       	hr_utility.raise_error;
  end if;
  --
  -- check if the start date has been entered
  if (p_rec.start_date is NULL) then
	hr_utility.set_message(801, 'HR_52063_OBJ_START_DATE_NULL');
       	hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 4);
  --
  -- check if target_date is not later that start_date
  --
  per_obj_bus.chk_target_date
  (p_objective_id              => p_rec.objective_id
  ,p_start_date                => p_rec.start_date
  ,p_target_date               => p_rec.target_date
  ,p_object_version_number     => p_rec.object_version_number
  );
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
  -- check if achievement_date is not later that start_date
  --
  per_obj_bus.chk_achiev_date
  (p_objective_id              => p_rec.objective_id
  ,p_start_date                => p_rec.start_date
  ,p_achievement_date          => p_rec.achievement_date
  ,p_complete_percent          => p_rec.complete_percent
  ,p_appraisal_id              => p_rec.appraisal_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_scorecard_id => p_rec.scorecard_id -- added new parameter for fixing bug#5947176
  );
  --
  hr_utility.set_location('Leaving:'||l_proc, 6);

/*
 * Added for WPM changes -- =========================================================
 *
 */
  --
  -- Check the group code.
  --
  chk_group_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_group_code                  => p_rec.group_code);

  hr_utility.set_location(l_proc, 20);
  --
  -- Check the priority.
  --
  chk_priority_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_priority_code               => p_rec.priority_code);

  hr_utility.set_location(l_proc, 25);
  --
  -- Check the appraise flag.
  --
  chk_appraise_flag
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_appraise_flag               => p_rec.appraise_flag
    ,p_scorecard_id                => p_rec.scorecard_id);

  hr_utility.set_location(l_proc, 30);
  --
  -- Check the weighting percent.
  --
  chk_weighting_percent
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_appraise_flag               => p_rec.appraise_flag
    ,p_weighting_percent           => p_rec.weighting_percent
    ,p_weighting_over_100_warning  => p_weighting_over_100_warning
    ,p_weighting_appraisal_warning => p_weighting_appraisal_warning);

  hr_utility.set_location(l_proc, 35);
  --
  -- Check the measurement style code.
  --
  chk_measurement_style_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_scorecard_id                => p_rec.scorecard_id);

  hr_utility.set_location(l_proc, 40);
  --
  -- Check the measure name.
  --
  chk_measure_name
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_measure_name                => p_rec.measure_name);

  hr_utility.set_location(l_proc, 45);
  --
  -- Check the target value.
  --
  chk_target_value
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_target_value                => p_rec.target_value);

  hr_utility.set_location(l_proc, 50);
  --
  -- Check the UOM code.
  --
  chk_uom_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_uom_code                    => p_rec.uom_code);

  hr_utility.set_location(l_proc, 55);
  --
  -- Check the measure type code.
  --
  chk_measure_type_code
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_effective_date              => p_effective_date
    ,p_measurement_style_code      => p_rec.measurement_style_code
    ,p_measure_type_code           => p_rec.measure_type_code);

  hr_utility.set_location(l_proc, 60);
  --
  -- check if scorecard_id exists
  --
IF p_rec.scorecard_id <> -1 THEN --- added for mass cascasde
  per_obj_bus.chk_scorecard_id
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_scorecard_id                => p_rec.scorecard_id
    );
END if;
  hr_utility.set_location(l_proc, 62);
  --
  -- check appraisal
  per_obj_bus.chk_appraisal
  (p_appraisal_id                  =>	p_rec.appraisal_id
  ,p_business_group_id	     	   =>	p_rec.business_group_id
  );
  hr_utility.set_location(l_proc, 63);

  per_obj_bus.chk_upd_appraisal(p_rec.appraisal_id);
  hr_utility.set_location(l_proc, 64);
  --
  -- check if complete percent is valid
  --
  hr_utility.set_location(l_proc, 66);
  per_obj_bus.chk_complete_percent
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_complete_percent            => p_rec.complete_percent);
  hr_utility.set_location(l_proc, 67);
  --
  -- check if next_review_date is later that start_date
  --
  per_obj_bus.chk_next_review_date
    (p_objective_id                => p_rec.objective_id
    ,p_start_date                  => p_rec.start_date
    ,p_next_review_date            => p_rec.next_review_date
    ,p_object_version_number       => p_rec.object_version_number
    );
  hr_utility.set_location(l_proc, 70);
  --
  chk_copied_from_lib_id
    (p_objective_id                => p_rec.objective_id
    ,p_object_version_number       => p_rec.object_version_number
    ,p_copied_from_lib_id          => p_rec.copied_from_library_id
    );
  hr_utility.set_location(l_proc, 72);
  --
  chk_copied_from_obj_id
    (p_objective_id               => p_rec.objective_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_copied_from_obj_id         => p_rec.copied_from_objective_id
    );
  hr_utility.set_location(l_proc, 73);
  --
IF p_rec.scorecard_id <> -1 THEN --- added for mass cascasde
  chk_aligned_with_obj_id
    (p_objective_id               => p_rec.objective_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_aligned_with_obj_id        => p_rec.aligned_with_objective_id
    ,p_scorecard_id               => p_rec.scorecard_id
    );
  END if;
  hr_utility.set_location(l_proc, 74);
  --
/*
  chk_copied_from_sources
    (p_copied_from_obj_id         => p_rec.copied_from_objective_id
    ,p_copied_from_lib_id         => p_rec.copied_from_library_id
    );
*/
  hr_utility.set_location(l_proc, 75);
  --
  chk_sharing_access_code
    (p_objective_id               => p_rec.objective_id
    ,p_object_version_number      => p_rec.object_version_number
    ,p_effective_date             => p_effective_date
    ,p_sharing_access_code        => p_rec.sharing_access_code
    );
  hr_utility.set_location(l_proc, 76);
/*
 * End of changes added for WPM --===============================================
 */

  --
  -- Call descriptive flexfield validation routines
  --
  IF hr_general.get_calling_context <>'FORMS' THEN
    per_obj_flex.df(p_rec => p_rec);
  END IF;
  --
  per_obj_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_obj_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_obj_bus.chk_objective_delete
  (p_objective_id              =>	p_rec.objective_id
  ,p_object_version_number     =>	p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
-- ----------------------------------------------------------------------------
function return_legislation_code
  (p_objective_id     in per_objectives.objective_id%TYPE
  ) return varchar2 is
--
-- Curson to find legislation code.
--
   cursor csr_leg_code is
          select legislation_code
          from   per_business_groups  pbg,
                 per_objectives  ppa
          where  ppa.objective_id = p_objective_id
            and  pbg.business_group_id  = ppa.business_group_id;
--
-- Declare local variables
--
   l_proc              varchar2(72) := 'return_legislation_code';
   l_legislation_code  varchar2(150);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'objective_id',
                              p_argument_value => p_objective_id );
  if nvl(g_objective_id, hr_api.g_number) = p_objective_id then
    --
    -- The legislation code has already been found with a previous
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
     --
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function
  --
  close csr_leg_code;
  g_objective_id := p_objective_id;
  g_legislation_code   := l_legislation_code;
end if;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  return l_legislation_code;
  --
end return_legislation_code;
--
end per_obj_bus;

/
