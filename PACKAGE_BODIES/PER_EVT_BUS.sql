--------------------------------------------------------
--  DDL for Package Body PER_EVT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_EVT_BUS" as
/* $Header: peevtrhi.pkb 120.2 2008/04/30 11:32:10 uuddavol ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_evt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_event_id                    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_event_id                             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_events evt
     where evt.event_id = p_event_id
       and pbg.business_group_id = evt.business_group_id;
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
    ,p_argument           => 'event_id'
    ,p_argument_value     => p_event_id
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
  (p_event_id                             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_events evt
     where evt.event_id = p_event_id
       and pbg.business_group_id = evt.business_group_id;
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
    ,p_argument           => 'event_id'
    ,p_argument_value     => p_event_id
    );
  --
  if ( nvl(per_evt_bus.g_event_id, hr_api.g_number)
       = p_event_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_evt_bus.g_legislation_code;
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
    per_evt_bus.g_event_id          := p_event_id;
    per_evt_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_evt_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.event_id is not null)  and (
    nvl(per_evt_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_evt_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.event_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_EVENTS'
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
  (p_rec in per_evt_shd.g_rec_type
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
  IF NOT per_evt_shd.api_updating
      (p_event_id                             => p_rec.event_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_289323_EVENT_NOT_FOUND');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if p_rec.business_group_id <> per_evt_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
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
-- |---------------------------< chk_event_type >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--    Perform check to make sure that :
--      - Typem parameter has been passed in.
--
-- In Parameters
--   p_type
--
-- Post Success
--   Processing continues.
--
-- Post Failure
-- An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - type is not set
--
-- Access Status
--  Internal Development Use Only
--

Procedure chk_event_type
  (p_type           in per_events.type%TYPE
  ) is
--
  l_proc                varchar2(72):=g_package||'chk_type';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'type',
     p_argument_value   => p_type
    );

  hr_utility.set_location('Leaving:'|| l_proc, 20);
--
end chk_event_type;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_event_times >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--    Perform check to make sure that :
--	- Validates that the start date of the event is entered
--      - Validates that end time and date is later or equal to start time and date
--
-- In Parameters
--   p_date_start
--   p_time_start
--   p_date_end
--   p_time_end
--
-- Post Success
--   Processing continues.
--
-- Post Failure
-- An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - date_start is not set
--	- date_end is not later than date_start
--
-- Access Status
--  Internal Development Use Only
--

Procedure chk_event_times
  (p_date_start         in per_events.date_start%TYPE
  ,p_date_end           in per_events.date_end%TYPE
  ,p_time_start         in per_events.time_start%TYPE
  ,p_time_end           in per_events.time_end%TYPE
  ) is
--
  l_proc        	varchar2(72):=g_package||'chk_event_times';
  l_time_start      date;
  l_time_end        date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'date_start',
     p_argument_value   => p_date_start
    );

  if (p_time_start is not null) then
    begin
      l_time_start := to_date(p_time_start, 'HH24:MI');
    Exception
      WHEN OTHERS THEN
--      raise an error with message "The Start time is not valid"
        hr_utility.set_message(800, 'HR_289319_START_TIME_INVALID');
        hr_utility.raise_error;
    end;
  end if;

  if (p_time_end IS NOT NULL) then
     begin
       l_time_end := to_date(p_time_end, 'HH24:MI');
     Exception
       WHEN OTHERS THEN
--       raise an error with message "The End date is not valid"
         hr_utility.set_message(800, 'HR_289320_END_TIME_INVALID');
         hr_utility.raise_error;
     end;
  end if;

  if (p_date_end is not null) then

    if ((p_date_end < p_date_start)
    or (     (p_date_end = p_date_start)
         and (nvl(l_time_end, hr_api.g_eot) < nvl(l_time_start, hr_api.g_sot)))
       ) then
--    raise an error with message "The Start date must be before the End date."
      hr_utility.set_message(800, 'HR_289321_START_DATE_AFTER_END');
      hr_utility.raise_error;
    end if;
  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 10);
--
end chk_event_times;

--
-------------------------------------------------------------------------------
--------------------------------<chk_emp_or_apl>-------------------------------
-------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a valid Employee/Applicant flag is set
--
--   - Validates that it is exists as lookup code for that type
--
--  In Arguments:
--    p_emp_or_apl
--
--  Post Success:
--    Process continues if :
--    The in parameter is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - employee/applicant flag is not set or is invalid
--
--  Access Status
--    Internal Table Handler Use Only.
--
procedure chk_emp_or_apl
(p_emp_or_apl             in      per_events.emp_or_apl%TYPE
,p_date_start             in      date
)
is
--
        l_proc               varchar2(72)  :=  g_package||'chk_emp_apl';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Whe updating only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The value for employee/applicant flag has changed
  --
  if (per_evt_shd.g_old_rec.event_id is null
  or  nvl(per_evt_shd.g_old_rec.emp_or_apl, hr_api.g_varchar2)
                         <> nvl(p_emp_or_apl, hr_api.g_varchar2)
     ) then
     --
     hr_utility.set_location(l_proc, 20);
     --
     -- If employee/applicant is not null then
     -- check if the value exists in hr_lookups
     -- where the lookup_type = 'EMP_APL'
     --
     if p_emp_or_apl is not null then
       if hr_api.not_exists_in_hr_lookups
            (p_effective_date   => p_date_start
            ,p_lookup_type      => 'EMP_APL'
            ,p_lookup_code      => p_emp_or_apl
            ) then
            -- error invalid employee/applicant flag
          hr_utility.set_message(800, 'HR_289310_EMP_APL_NOT_FOUND');
          hr_utility.raise_error;
       end if;
       hr_utility.set_location(l_proc, 30);
     end if;
  end if;
 hr_utility.set_location('Leaving: '|| l_proc, 40);
end chk_emp_or_apl;

--
--------------------------------------------------------------------------------
--------------------------<chk_event_or_interview>------------------------------
--------------------------------------------------------------------------------
--
--  Description:
--   - Validates that a valid event/interview flag is set
--
--   - Validates that it is exists as lookup code for that type
--
--  In Arguments:
--    p_event_or_interview
--
--  Post Success:
--    Process continues if :
--    All the in parameters are valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of
--    the following cases are found :
--      - event/interview flag is invalid
--
--  Access Status
--    Internal Table Handler Use Only.
--
--
procedure chk_event_or_interview
(p_event_or_interview         in      per_events.event_or_interview%TYPE
,p_date_start                 in      date
)
is
--
        l_proc               varchar2(72)  :=  g_package||'chk_event_or_interview';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current  g_old_rec is current and
  -- b) The value for event_or_interview has changed
  --
  if (per_evt_shd.g_old_rec.event_id is null
  or  nvl(per_evt_shd.g_old_rec.event_or_interview, hr_api.g_varchar2)
                         <> nvl(p_event_or_interview, hr_api.g_varchar2) ) then
     --
     hr_utility.set_location(l_proc, 20);
     --
     -- If event_or_interview is not null then
     -- check if the value exists in hr_lookups
     -- where the lookup_type = 'EVENT_INTERVIEW'
     --
     --
     if p_event_or_interview is not null then
       if hr_api.not_exists_in_hr_lookups
            (p_effective_date   => p_date_start
            ,p_lookup_type      => 'EVENT_INTERVIEW'
            ,p_lookup_code      => p_event_or_interview
            ) then
            -- error invalid event/interview
          hr_utility.set_message(800, 'HR_289311_EVT_INT_NOT_FOUND');
          hr_utility.raise_error;
       end if;
       hr_utility.set_location(l_proc, 30);
     end if;
  end if;
  hr_utility.set_location('Leaving: '|| l_proc, 40);
end chk_event_or_interview;

--
--  ---------------------------------------------------------------------------
--  |-------------------<  chk_internal_contact_person_id >-------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a person id exists in table per_people_f.
--    - Validates that the business group of the event matches
--      the business group of the person.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_object_version_number
--    p_person_id
--    p_business_group_id
--    p_date_start
--
--  Post Success:
--    If a row does exist in per_people_f for the given person id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in per_people_f for the given person id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_internal_contact_person_id
  (p_object_version_number       in     per_events.object_version_number%TYPE
  ,p_internal_contact_person_id  in     per_events.internal_contact_person_id%TYPE
  ,p_business_group_id           in     per_events.business_group_id%TYPE
  ,p_date_start                  in     per_events.date_start%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_internal_contact_person_id';
  --
  l_business_group_id per_all_people_f.business_group_id%type;
  --
  cursor csr_valid_pers is
    select ppf.business_group_id
    from   per_all_people_f ppf
    where  ppf.person_id = p_internal_contact_person_id
    and    p_date_start between
           ppf.effective_start_date and ppf.effective_end_date
    and   (ppf.current_employee_flag = 'Y'
     or   (ppf.current_npw_flag = 'Y' and
           nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'), 'N') = 'Y'));
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_utility.set_location('event_id : ' || per_evt_shd.g_old_rec.event_id, 11);
  hr_utility.set_location('old person id : ' || per_evt_shd.g_old_rec.internal_contact_person_id, 12);
  hr_utility.set_location('new person id : ' || p_internal_contact_person_id, 13);

  if ((per_evt_shd.g_old_rec.event_id is null and p_internal_contact_person_id is not null)
  or (per_evt_shd.g_old_rec.event_id is not null
  and nvl(per_evt_shd.g_old_rec.internal_contact_person_id, hr_api.g_number)
                         <> nvl(p_internal_contact_person_id, hr_api.g_number))) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the Internal Contact Person ID is linked to a
    -- valid person on PER_PEOPLE_F
    --
    open csr_valid_pers;
    fetch csr_valid_pers into l_business_group_id;
    if csr_valid_pers%notfound then
      --
      close csr_valid_pers;
      hr_utility.set_message(800, 'HR_51011_PER_NOT_EXIST_DATE');
      hr_utility.raise_error;
      --
    end if;
    close csr_valid_pers;
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the business group of the person is the same as the
    -- business group of the event, or that cross business group profile
    -- option is enabled.
    --

    if nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'), 'N') = 'N' then
       if (p_business_group_id <> l_business_group_id) then
          --
          hr_utility.set_message(800, 'HR_289312_PERSON_NOT_IN_BG');
          hr_utility.raise_error;
          --
       end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_internal_contact_person_id;

--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_organization_run_by_id >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that an organization id exists in table HR_ORGANIZATION_UNITS.
--    - Validates that the business group of the organization matches
--      the business group of the event.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_run_by_id
--    p_business_group_id
--
--  Post Success:
--    If a row does exist in HR_ORGANIZATION_UNITS for the given organization id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in HR_ORGANIZATION_UNITS for the given organization id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_organization_run_by_id
  (p_object_version_number       in     per_events.object_version_number%TYPE
  ,p_organization_run_by_id         in     per_events.organization_run_by_id%TYPE
  ,p_business_group_id           in     per_events.business_group_id%TYPE
  ,p_date_start                  in     per_events.date_start%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_organization_run_by_id';
  --
  l_business_group_id hr_all_organization_units.business_group_id%type;
  --
  cursor csr_valid_org is
    select business_group_id
    from hr_all_organization_units hou
    where hou.organization_id = p_organization_run_by_id
    and p_date_start between date_from and nvl(date_to, hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if ((per_evt_shd.g_old_rec.event_id is null and p_organization_run_by_id is not null)
  or (per_evt_shd.g_old_rec.event_id is not null
  and nvl(per_evt_shd.g_old_rec.organization_run_by_id, hr_api.g_number)
                         <> nvl(p_organization_run_by_id, hr_api.g_number))) then
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the Organization Run By is linked to a
    -- valid organization on hr_organiztion_units
    --
    open csr_valid_org;
    fetch csr_valid_org into l_business_group_id;
    if csr_valid_org%notfound then
      --
      close csr_valid_org;
      hr_utility.set_message(800, 'HR_289313_NO_SUCH_ORGANIZATION');
      hr_utility.raise_error;
      --
    end if;
    close csr_valid_org;
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the business group of the organization is the same as the
    -- business group of the event or the organization is global.
    --
    if nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'), 'N') = 'N' then
       if (p_business_group_id <> nvl(l_business_group_id, p_business_group_id)) then
          --
          hr_utility.set_message(800, 'HR_289314_ORG_NOT_IN_THIS_BG');
          hr_utility.raise_error;
          --
       end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_organization_run_by_id;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_assignment_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the value in assignment_ID is in the per_assignments table.
--
-- In Parameters:
--   p_assignment_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
Procedure chk_assignment_id
  (
   p_assignment_id      in      per_events.assignment_id%type
  ,p_date_start         in      per_events.date_start%type
  ,p_business_group_id  in      per_events.business_group_id%TYPE
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_assignment_id';
  l_business_group_id per_all_assignments_f.business_group_id%type;
  l_assignment_id per_events.assignment_id%type;
--
  cursor c_valid_asg(v_assignment_id number) is
      select business_group_id
        from per_all_assignments_f asg
       where asg.assignment_id = v_assignment_id
       and p_date_start between effective_start_date and effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The g_old_rec is current and
  -- b) The value for assignment has changed
  --
  if (p_assignment_id is not null) then
    if (p_assignment_id <> hr_api.g_number) then
       l_assignment_id := p_assignment_id;
    else
       l_assignment_id := per_evt_shd.g_old_rec.assignment_id;
    end if;
  --
  -- Check that the assignment_id is in the per_assignments table.
  --
  open c_valid_asg(l_assignment_id);
  fetch c_valid_asg into l_business_group_id;
  if c_valid_asg%notfound then
    close c_valid_asg;
    hr_utility.set_message(800, 'HR_289315_NO_SUCH_ASSIGNMENT');
    hr_utility.raise_error;
  end if;
  close c_valid_asg;
  hr_utility.set_location(l_proc, 20);
  --
  end if;
  --
  if (p_business_group_id <> nvl(l_business_group_id, p_business_group_id)) then
    --
    hr_utility.set_message(800, 'HR_289316_ASG_NOT_IN_THIS_BG');
    hr_utility.raise_error;
    --
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
End chk_assignment_id;

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_location_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that a location id exists in table hr_locations.
--    - Validates that the business group of the event matches
--      the business group of the location if the location is not global.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_location_id
--    p_business_group_id
--
--  Post Success:
--    If a row does exist in hr_locations for the given location id then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in hr_locations for the given location id then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_location_id
  (p_object_version_number       in     per_events.object_version_number%TYPE
  ,p_location_id                 in     per_events.location_id%TYPE
  ,p_business_group_id           in     per_events.business_group_id%TYPE
  )
is
  --
  l_proc              varchar2(72)  :=  g_package||'chk_location_id';
  --
  l_business_group_id hr_locations_all.business_group_id%TYPE;
  --
  cursor csr_valid_locn is
    select business_group_id
    from hr_locations_all hln
    where hln.location_id = p_location_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_location_id is not null and p_location_id <> hr_api.g_number then
  hr_utility.set_location(l_proc, 20);
    --
    -- Check that the Location ID is linked to a
    -- valid location on HR_LOCATIONS
    --
    open csr_valid_locn;
    fetch csr_valid_locn into l_business_group_id;
    if csr_valid_locn%notfound then
      --
      close csr_valid_locn;
      hr_utility.set_message(800, 'HR_289317_NO_SUCH_LOCATION');
      hr_utility.raise_error;
      --
    end if;
    close csr_valid_locn;
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that the business group of the location is the same as the
    -- business group of the event, or is global.
    --
      if (p_business_group_id <> nvl(l_business_group_id, p_business_group_id)) then
      --
      hr_utility.set_message(800, 'HR_289318_LOC_NOT_IN_THIS_BG');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_location_id;

-- ----------------------------------------------------------------------------
-- |--------------------------< chk_party_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
--
--  Description:
--   - Validates that the person_id and the party_id are matched in
--     per_all_people_f
--     and if person_id is not null and party_id is null, derive party_id
--     from per_all_people_f from person_id
--
--  Pre_conditions:
--    A valid business_group_id
--
--  In Arguments:
--    A Pl/Sql record structre.
--    effective_date

--
--  Post Success:
--    Process continues if :
--
--  Post Failure:
--    An application error is raised and processing is terminated if any of

--  Access Status:
--    Internal Table Handler Use Only.
--
--
Procedure chk_party_id(
   p_rec             in out nocopy per_evt_shd.g_rec_type
  )is
--
  l_proc    varchar2(72)  :=  g_package||'chk_party_id';
  l_party_id     per_events.party_id%TYPE;
  l_party_id2    per_events.party_id%TYPE;
--
  --
  -- cursor to get party_id
  --
  cursor csr_get_party_id is
  select max(per.party_id)
  from    per_all_people_f per
  where   per.person_id =
          (select asg.person_id from per_all_assignments_f asg
           where asg.assignment_id = p_rec.assignment_id
           and p_rec.date_start
           between asg.effective_start_date
           and asg.effective_end_date);
  --
  cursor csr_valid_party_id is
  select party_id
  from hz_parties hzp
  where hzp.party_id = p_rec.party_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  if p_rec.party_id is not null then
    hr_utility.set_location(l_proc,10);
    open csr_valid_party_id;
    fetch csr_valid_party_id into l_party_id2;
    if csr_valid_party_id%notfound then
      close csr_valid_party_id;
      hr_utility.set_message(800, 'PER_289342_PARTY_ID_INVALID');
      hr_utility.set_location(l_proc,20);
      hr_utility.raise_error;
    end if;
    close csr_valid_party_id;
  elsif p_rec.assignment_id is not null then
    open csr_get_party_id;
    fetch csr_get_party_id into l_party_id;
    close csr_get_party_id;
    --
    -- derive party_id from per_all_people_f using assignment_id
    --
    hr_utility.set_location(l_proc,30);
    p_rec.party_id := l_party_id;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
End chk_party_id;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in out nocopy per_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);

  -- HR/TCA merge
  -- if party_id is specified, business_group_id isn't required parameter
  --
  if p_rec.party_id is null and p_rec.business_group_id is not null then
  --
  -- Call all supporting business operations
  --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;

  --
  -- Validate CHK_EVENT_TYPE
  --
  per_evt_bus.chk_event_type
  (p_type                         => p_rec.type
  );

  --
  -- Validate CHK_EVENT_TIMES
  --
  per_evt_bus.chk_event_times
  (p_date_start                   => p_rec.date_start
  ,p_date_end                     => p_rec.date_end
  ,p_time_start                   => p_rec.time_start
  ,p_time_end                     => p_rec.time_end
  );

  --
  -- Validate CHK_EMP_OR_APL
  --
  per_evt_bus.chk_emp_or_apl
  (p_emp_or_apl                  => p_rec.emp_or_apl
  ,p_date_start                  => p_rec.date_start
  );

  --
  -- Validate CHK_EVENT_OR_INTERVIEW
  --
  per_evt_bus.chk_event_or_interview
  (p_event_or_interview          => p_rec.event_or_interview
  ,p_date_start                  => p_rec.date_start
  );

  --
  -- Validate CHK_INTERNAL_CONTACT_PERSON_ID
  --
  per_evt_bus.chk_internal_contact_person_id
  (p_object_version_number       => p_rec.object_version_number
  ,p_internal_contact_person_id  => p_rec.internal_contact_person_id
  ,p_business_group_id           => p_rec.business_group_id
  ,p_date_start                  => p_rec.date_start
  );

  --
  -- Validate CHK_PARTY_ID
  --
  per_evt_bus.chk_party_id
  (p_rec
  );
  --
  -- Validate CHK_ORGANIZATION_RUN_BY_ID
  --
  per_evt_bus.chk_organization_run_by_id
  (p_object_version_number       => p_rec.object_version_number
  ,p_organization_run_by_id      => p_rec.organization_run_by_id
  ,p_business_group_id           => p_rec.business_group_id
  ,p_date_start                  => p_rec.date_start
  );

  --
  -- Validate CHK_ASSIGNMENT_ID
  --
  per_evt_bus.chk_assignment_id
  (p_assignment_id               => p_rec.assignment_id
  ,p_date_start                  => p_rec.date_start
  ,p_business_group_id           => p_rec.business_group_id
  );

  --
  -- Validate CHK_LOCATION
  --
  per_evt_bus.chk_location_id
  (p_object_version_number       => p_rec.object_version_number
  ,p_location_id                 => p_rec.location_id
  ,p_business_group_id           => p_rec.business_group_id
  );

  --
  per_evt_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- HR/TCA merge
  -- if party_id is specified, business_group_id isn't required parameter
  if p_rec.business_group_id is not null then
    --
    -- Call all supporting business operations
    --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_non_updateable_args
    (p_rec
    );
  --
  -- Validate CHK_EVENT_TIMES
  --
  per_evt_bus.chk_event_times
  (p_date_start                   => p_rec.date_start
  ,p_date_end                     => p_rec.date_end
  ,p_time_start                   => p_rec.time_start
  ,p_time_end                     => p_rec.time_end
  );

  --
  -- Validate CHK_EMP_OR_APL
  --
  per_evt_bus.chk_emp_or_apl
  (p_emp_or_apl                  => p_rec.emp_or_apl
  ,p_date_start                  => p_rec.date_start
  );

  --
  -- Validate CHK_EVENT_OR_INTERVIEW
  --
  per_evt_bus.chk_event_or_interview
  (p_event_or_interview          => p_rec.event_or_interview
  ,p_date_start                  => p_rec.date_start
  );

  --
  -- Validate CHK_INTERNAL_CONTACT_PERSON_ID
  --
  per_evt_bus.chk_internal_contact_person_id
  (p_object_version_number       => p_rec.object_version_number
  ,p_internal_contact_person_id  => p_rec.internal_contact_person_id
  ,p_date_start                  => p_rec.date_start
  ,p_business_group_id           => p_rec.business_group_id
  );

  --
  -- Validate CHK_ORGANIZATION_RUN_BY_ID
  --
  per_evt_bus.chk_organization_run_by_id
  (p_object_version_number       => p_rec.object_version_number
  ,p_organization_run_by_id      => p_rec.organization_run_by_id
  ,p_business_group_id           => p_rec.business_group_id
  ,p_date_start                  => p_rec.date_start
  );

  --
  -- Validate CHK_ASSIGNMENT_ID
  --
  per_evt_bus.chk_assignment_id
  (p_assignment_id               => p_rec.assignment_id
  ,p_date_start                  => p_rec.date_start
  ,p_business_group_id           => p_rec.business_group_id
  );

  --
  -- Validate CHK_LOCATION
  --
  per_evt_bus.chk_location_id
  (p_object_version_number       => p_rec.object_version_number
  ,p_location_id                 => p_rec.location_id
  ,p_business_group_id           => p_rec.business_group_id
  );

  --
  per_evt_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_evt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End delete_validate;
--
end per_evt_bus;

/
