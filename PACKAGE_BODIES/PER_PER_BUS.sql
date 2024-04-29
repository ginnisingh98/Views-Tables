--------------------------------------------------------
--  DDL for Package Body PER_PER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PER_BUS" as
/* $Header: peperrhi.pkb 120.14.12010000.5 2009/08/17 12:07:47 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
--
   g_package  varchar2(33) := '  per_per_bus.';  -- Global package name
   g_debug boolean := hr_utility.debug_enabled;
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_person_id number default null;
g_legislation_code varchar2(150) default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  set_security_group_id  >------------------------|
--  ---------------------------------------------------------------------------
--
  procedure set_security_group_id
   (
    p_person_id in per_all_people_f.person_id%TYPE
   ,p_associated_column1 in varchar2 default null
   ) as
  --
  -- Declare cursor
  --
  -- Bug Number  : 3009266.
  -- Description : To let Phones row handler access person row hanlder for all persons
  --               replaced per_people_f with per_all_people_f in this cursor.
  --
     cursor csr_sec_grp is
     select hoi.org_information14, hoi.org_information9
       from hr_organization_information hoi
            , per_all_people_f per
      where per.person_id = p_person_id
        and hoi.organization_id = per.business_group_id
        and hoi.org_information_context||'' = 'Business Group Information';
  --
  -- Local variables
  --
  l_security_group_id number;
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72) := g_package||'set_security_group_id';
  --
  begin
 if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'person_id',
                             p_argument_value => p_person_id);
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id, l_legislation_code;
  if csr_sec_grp%notfound then
    close csr_sec_grp;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_multi_message.add(p_associated_column1 =>
                         nvl(p_associated_column1,'PERSON_ID'));
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
    --
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 end if;
  --
end set_security_group_id;
--  ---------------------------------------------------------------------------
--  |----------------------<  return_system_person_type  >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that the person_type_id exists in per_person_types for the
--    business group and returns the value of system_person_type
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_type_id
--    p_business_group_id
--
--  Post Success:
--    If the person_type exists in PER_PERSON_TYPES for the business
--    group then
--    the value of system person type is returned and processing continues
--
--  Post Failure:
--    If the person_type does not exist in PER_PERSON_TYPES for the business
--    group then
--    an application error will be raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
function return_system_person_type
  (p_person_type_id           in  per_all_people_f.person_type_id%TYPE
  ,p_business_group_id        in  per_all_people_f.business_group_id%TYPE)
  return varchar2 is
--
  l_person_type    varchar2(30);
  l_proc           varchar2(72)  :=  g_package||'return_system_person_type';
--
  cursor csr_chk_person_type is
   select pet.system_person_type
   from per_person_types pet
   where p_person_type_id = pet.person_type_id
     and p_business_group_id = pet.business_group_id + 0;
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person type id'
    ,p_argument_value => p_person_type_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business group id'
    ,p_argument_value => p_business_group_id
    );
  --
  -- Check if the previous system_person_type variable(g_previous_sys_per_type)
  -- is null, if not then we already have the required value so just return it,
  -- if so select it from the database before returning it.
  --
  if g_previous_sys_per_type is null then
    --
    --  Check that the person_type exists in PER_PERSON_TYPES for the business
    --  group and return the system person type
    --
    open csr_chk_person_type;
    fetch csr_chk_person_type into g_previous_sys_per_type;
    If csr_chk_person_type%found then
      close csr_chk_person_type;
 if g_debug then
      hr_utility.set_location(l_proc, 3);
 end if;
    else
      --
 if g_debug then
      hr_utility.set_location(l_proc, 4);
 end if;
      --
      close csr_chk_person_type;
      -- Error: Invalid person type
      hr_utility.set_message(801,'HR_7513_PER_TYPE_INVALID');
      hr_utility.raise_error;
    end if;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving '||l_proc, 5);
 end if;
  return g_previous_sys_per_type;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.PERSON_TYPE_ID'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 6);
 end if;
        raise;
    end if;
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc,7);
 end if;
    -- call to stop proceeding further if there is an error in
    -- system person type
    --
    hr_multi_message.end_validation_set;
    --
end return_system_person_type;
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  set_current_flags  >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--   Sets the value of p_current_employee_flag, p_current_applicant_flag and
--   p_current_emp_or_apl_flag according to the value of system person type.
--   This procedure is called directly on insert and from chk_person_type_id
--   on update, if a valid change in system person type occurs.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_person_type_id
--    p_effective_date
--    p_object_version_number
--
--  Out Arguments:
--    p_current_employee_flag
--    p_current_applicant_flag
--    p_current_emp_or_apl_flag
--
--  Post Success:
--    If the system_person_type corresponding to the value of p_person_type_id
--    is 'EMP' or 'EMP_APL' then
--      p_current_employee_flag is set to 'Y' and processing continues
--    else
--      p_current_employee_flag is set to null and processing continues
--
--    If the system_person_type corresponding to the value of p_person_type_id
--    is 'APL','APL_EX_APL', 'EMP_APL' or 'EX_EMP_APL' then
--      p_current_applicant_flag is set to 'Y' and processing continues
--    else
--      p_current_applicant_flag is set to null and processing continues
--
--    If the system_person_type corresponding to the value of p_person_type_id
--    is 'EMP','APL','EMP_APL', EX_EMP_APL' or 'APL_EX_APL' then
--      p_current_emp_or_apl_flag is set to 'Y' and processing continues
--    else
--      p_current_emp_or_apl_flag is set to null and processing continues
--
--  Post Failure:
--   None
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure set_current_flags
  (p_person_id                in per_all_people_f.person_id%TYPE
  ,p_business_group_id        in per_all_people_f.business_group_id%TYPE
  ,p_person_type_id           in per_all_people_f.person_type_id%TYPE
  ,p_current_employee_flag   out nocopy per_all_people_f.current_employee_flag%TYPE
  ,p_current_applicant_flag  out nocopy per_all_people_f.current_applicant_flag%TYPE
  ,p_current_emp_or_apl_flag out nocopy per_all_people_f.current_emp_or_apl_flag%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_people_f.object_version_number%TYPE) is
--
  l_proc           varchar2(72)  :=  g_package||'set_current_flags';
  l_api_updating        boolean;
  l_system_person_type  varchar2(30);
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business group id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person type id'
    ,p_argument_value => p_person_type_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The person type id value has changed
  --  c) A record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and per_per_shd.g_old_rec.person_type_id
    <> p_person_type_id) or
    (NOT l_api_updating)) then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 2);
 end if;
    --
    --  Populate l_system_person_type with the value of system person type
    --
    l_system_person_type := return_system_person_type(p_person_type_id
                                                     ,p_business_group_id);
    --
 if g_debug then
    hr_utility.set_location(l_proc, 3);
 end if;
    --
    --  Check if the person is an employee
    --
    if l_system_person_type in ('EMP','EMP_APL') then
      --
 if g_debug then
      hr_utility.set_location(l_proc, 4);
 end if;
      --
      --  Person is an employee so set current employee flag to 'Y'
      --
      p_current_employee_flag := 'Y';
    else
      --
 if g_debug then
      hr_utility.set_location(l_proc, 5);
 end if;
      --
      --  Person is not an employee so set to null
      --
      p_current_employee_flag := null;
    end if;
    --
    --  Check if the person is an applicant
    --
    if l_system_person_type in ('APL','APL_EX_APL','EMP_APL','EX_EMP_APL') then
      --
 if g_debug then
      hr_utility.set_location(l_proc, 6);
 end if;
      --
      -- Person is an applicant so set current applicant flag to 'Y'
      --
      p_current_applicant_flag := 'Y';
    else
      --
 if g_debug then
      hr_utility.set_location(l_proc, 7);
 end if;
      --
      --  Person is not an applicant so set to null
      --
      p_current_applicant_flag := null;
    end if;
    --
    --  Check if the person is an employee or applicant
    --
    if l_system_person_type in ('EMP','APL','EMP_APL','EX_EMP_APL','APL_EX_APL')
      then
      --
 if g_debug then
      hr_utility.set_location(l_proc, 8);
 end if;
      --
      --  Person is an employee or applicant so set current emp or apl flag
      --  to 'Y'
      --
      p_current_emp_or_apl_flag := 'Y';
    else
      --
      --  Person is not an employee or applicant so set to null
      --
 if g_debug then
      hr_utility.set_location(l_proc, 9);
 end if;
      --
      p_current_emp_or_apl_flag := null;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc, 10);
 end if;
  else
 if g_debug then
    hr_utility.set_location(l_proc, 11);
 end if;
    --
    p_current_employee_flag := per_per_shd.g_old_rec.current_employee_flag;
    p_current_applicant_flag := per_per_shd.g_old_rec.current_applicant_flag;
    p_current_emp_or_apl_flag := per_per_shd.g_old_rec.current_emp_or_apl_flag;
  end if;
 if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 12);
 end if;
end set_current_flags;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_person_type_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that a person type id is valid
--
--  Pre-conditions:
--    1) p_current_employee_flag and p_current_emp_or_apl_flag must have been
--       set
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_person_type_id
--    p_old_person_type_id
--    p_current_employee_flag
--    p_current_emp_or_apl_flag
--    p_effective_date
--    p_object_version_number
--    p_datetrack_mode
--
--  Post Success:
--    If the following cases are true then processing continues
--
--      a) person_type_id exists in per_person_types for the business group
--
--      b) system_person_type is one of:
--         APL, APL_EX_APL, EMP, EMP_APL, EX_APL, EX_EMP, EX_EMP_APL, OTHER
--
--         On insert only EMP, APL, and OTHER are permitted.
--
--      c) system_person_type undergoes one of the following transitions:
--         OTHER      to APL, EMP or OTHER
--         APL        to EMP, EMP_APL, EX_APL or APL
--         EX_APL     to APL_EX_APL or EX_APL, EMP
--         APL_EX_APL to EMP or APL_EX_APL, EMP_APL, EX_APL
--         EMP        to EMP_APL, EX_EMP or EMP
--         EMP_APL    to EMP or EMP_APL, EX_EMP_APL
--         EX_EMP     to EMP, EX_EMP_APL or EX_EMP
--         EX_EMP_APL to EMP_APL, EMP or EX_EMP_APL, EX_EMP
--
--      d) The value of system_person_type has changed and the
--         datetrack mode is UPDATE, CORRECTION or UPDATE_OVERRIDE (the
--         latter two under specific conditions).
--
--      e) The value of system_person_type has not changed and the
--         datetrack mode is UPDATE or CORRECTION.
--
--  Post Failure:
--    If any of the following cases are true then
--    an application error will be raised and processing is terminated
--
--      a) person_type_id does not exist in per_person_types for the business
--         group, or is not active
--
--      b) system_person_type is not as specified in (b) above.
--
--      c) The system_person_type transition is not as specified in (c)
--         above.
--
--      d) The value of system_person_type has changed and the
--         datetrack mode is UPDATE_CHANGE_INSERT, CORRECTION or
--         UPDATE_OVERRIDE (the latter two under specific conditions).
--
--      e) The value of system_person_type has not changed and the
--         datetrack mode is UPDATE_CHANGE_INSERT.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_person_type_id
  (p_person_id                in per_all_people_f.person_id%TYPE
  ,p_business_group_id        in per_all_people_f.business_group_id%TYPE
  ,p_person_type_id           in per_all_people_f.person_type_id%TYPE
  ,p_old_person_type_id       in per_all_people_f.person_type_id%TYPE
  ,p_current_employee_flag    in out nocopy per_all_people_f.current_employee_flag%TYPE
  ,p_current_applicant_flag   in out nocopy per_all_people_f.current_employee_flag%TYPE
  ,p_current_emp_or_apl_flag  in out nocopy per_all_people_f.current_emp_or_apl_flag%TYPE
  ,p_effective_date           in date
  ,p_validation_start_date    in date
  ,p_object_version_number    in per_all_people_f.object_version_number%TYPE
  ,p_datetrack_mode           in varchar2) is
--
  l_exists                     varchar2(1);
  l_new_system_person_type     varchar2(30);
  l_old_system_person_type     varchar2(30);
  l_proc           varchar2(72)  :=  g_package||'chk_person_type_id';
  l_api_updating               boolean;
  l_current_employee_flag      varchar2(1);
  l_current_applicant_flag     varchar2(1);
  l_current_emp_or_apl_flag    varchar2(1);
  l_business_group_id          per_person_types.business_group_id%type;
  l_active_flag                per_person_types.active_flag%type;
  l_discard_varchar2           varchar2(100);
  l_discard_number             number;
  l_original_sys_type          per_person_types.system_person_type%type;
--
  cursor
    csr_person_type(l_person_type_id in per_all_people_f.person_type_id%type) is
    select pet.system_person_type,
      pet.business_group_id,
      pet.active_flag
    from per_person_types pet
    where l_person_type_id = pet.person_type_id;
--
/*
  cursor csr_system_type(l_start_date in date) is
    select pet.system_person_type
    from per_all_people_f per,
    per_person_types pet
    where per.person_id = p_person_id
    and   l_start_date between per.effective_start_date
             and     per.effective_end_date
    and   pet.person_type_id = per.person_type_id;
*/
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business group id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person type id'
    ,p_argument_value => p_person_type_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- The DateTrack mode UPDATE_OVERRIDE mode cannot be used if there is
  -- a change of system person type after the effective date.
  -- Note that this rule applies even if the person type is not being
  -- changed in this transaction.
  --
  if p_datetrack_mode = 'UPDATE_OVERRIDE' then
  --
 if g_debug then
    hr_utility.set_location(l_proc, 5);
 end if;
  --
    per_per_bus.chk_system_pers_type
    (p_person_id             => p_person_id
    ,p_validation_start_date => p_validation_start_date
    ,p_validation_end_date   => hr_api.g_eot
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_effective_date        => p_effective_date
    );
  end if;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The person type id value has changed
  --  c) or a record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and per_per_shd.g_old_rec.person_type_id <>
    p_person_type_id) or
    (NOT l_api_updating)) then
    --
    --  Perform Insert/Update Checks
    --
    --  Check if the person type id exists in per_person_types for the business
    --  group
    --
    open csr_person_type(p_person_type_id);
    fetch csr_person_type
    into l_new_system_person_type,
    l_business_group_id,
    l_active_flag;
    if csr_person_type%notfound then
      close csr_person_type;
      -- Error: Invalid person type
      hr_utility.set_message(801, 'HR_7513_PER_TYPE_INVALID');
      hr_utility.raise_error;
    end if;
    close csr_person_type;
    if l_business_group_id <> p_business_group_id then
      hr_utility.set_message(801, 'HR_7974_PER_TYPE_INV_BUS_GROUP');
      hr_utility.raise_error;
    elsif l_active_flag <> 'Y' then
      hr_utility.set_message(801, 'HR_7973_PER_TYPE_NOT_ACTIVE');
      hr_utility.raise_error;
    end if;
    --
 if g_debug then
    hr_utility.set_location(l_proc, 7);
 end if;
    --
    -- If a new person is being inserted, then check that the system person
    -- type is of a permitted value.
    --
    if p_datetrack_mode = 'INSERT' then
      if l_new_system_person_type not in ('EMP', 'APL', 'OTHER') then
        hr_utility.set_message(801, 'HR_7977_PER_INV_TYPE_FOR_INS');
        hr_utility.raise_error;
      end if;
    end if;
    --
    --  Only proceed with validation if:
    --  a) The current g_old_rec is current and
    --  b) The person type id value has changed
    --
    if ((l_api_updating and per_per_shd.g_old_rec.person_type_id <>
        p_person_type_id)) then
      --
      --  Perform Update Checks
      --
      --  Check the values of system person type in the old record for the
      --  business group
      --
      open csr_person_type(p_old_person_type_id);
      fetch csr_person_type
      into l_old_system_person_type,
      l_discard_number,
      l_discard_varchar2;
      close csr_person_type;
 if g_debug then
      hr_utility.set_location(l_proc, 9);
 end if;
      --
      -- Check if DateTrack mode is valid
      --
      If l_new_system_person_type <> l_old_system_person_type then
      --
      -- system person type has changed so
      -- update is allowed
      -- update_change_insert is not allowed
      --
   if p_datetrack_mode = 'UPDATE_CHANGE_INSERT'
   then
     hr_utility.set_message(801, 'HR_7724_PER_DT_MODE_SPT_CHANGE');
     hr_utility.raise_error;
   end if;
        --
   -- DateTrack mode CORRECTION is allowed, provided the system person
   -- type hasn't already been changed on the effective start date of
   -- the current row.
   --
   /*if p_datetrack_mode = 'CORRECTION' then
          --
          open CSR_System_type(p_validation_start_date-1);
     fetch csr_system_type
     into l_original_sys_type;
     if csr_system_type%notfound then
       close csr_system_type;
       hr_utility.set_message(801, 'HR_7984_PER_NO_PREVIOUS_ROW');
       hr_utility.raise_error;
     end if;
     close csr_system_type;
     if l_original_sys_type <> l_old_system_person_type then
             hr_utility.set_message(801, 'HR_7978_PER_TYPE_CHANGE');
             hr_utility.raise_error;
          end if;
        end if;
       */
      end if;
 if g_debug then
      hr_utility.set_location(l_proc, 11);
 end if;
      --
      -- Check that the system person type conversion is valid.
      --
      if (l_old_system_person_type = 'OTHER' and
        l_new_system_person_type not in ('APL', 'EMP', 'OTHER'))
      or (l_old_system_person_type = 'APL' and
   l_new_system_person_type not in ('EMP', 'EMP_APL', 'EX_APL', 'APL'))
      or (l_old_system_person_type = 'EX_APL' and
     l_new_system_person_type not in ('EMP','APL_EX_APL', 'EX_APL'))
      or (l_old_system_person_type = 'APL_EX_APL' and
     l_new_system_person_type not in ('EMP','APL_EX_APL','EMP_APL','EX_APL'))
      or (l_old_system_person_type = 'EMP' and
    l_new_system_person_type not in ('EMP_APL', 'EX_EMP', 'EMP'))
      or (l_old_system_person_type = 'EMP_APL' and
     l_new_system_person_type not in ('EMP', 'EMP_APL','EX_EMP_APL'))
      or (l_old_system_person_type = 'EX_EMP' and
   l_new_system_person_type not in ('EMP', 'EX_EMP_APL', 'EX_EMP'))
      or (l_old_system_person_type = 'EX_EMP_APL' and
     l_new_system_person_type not in ('EMP_APL', 'EMP', 'EX_EMP_APL','EX_EMP'))
      then
   hr_utility.set_message(801, 'HR_7987_PER_INV_TYPE_CHANGE');
   hr_utility.raise_error;
      else
 if g_debug then
        hr_utility.set_location(l_proc, 12);
 end if;
   --
   set_current_flags(p_person_id
                        ,p_business_group_id
                   ,p_person_type_id
                   ,l_current_employee_flag
              ,l_current_applicant_flag
              ,l_current_emp_or_apl_flag
              ,p_effective_date
              ,p_object_version_number);
     --
   p_current_employee_flag := l_current_employee_flag;
   p_current_applicant_flag := l_current_applicant_flag;
   p_current_emp_or_apl_flag := l_current_emp_or_apl_flag;
      end if;
    end if;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 13);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.PERSON_TYPE_ID'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 14);
 end if;
        raise;
    end if;
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc,15);
 end if;
    hr_multi_message.end_validation_set;
end chk_person_type_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_date_of_birth  >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that a date of birth value is valid
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_person_type_id
--    p_business_group_id
--    p_start_date
--    p_date_of_birth
--    p_effective_date
--    p_object_version_number
--
--  Out Arguments
--    p_dob_null_warning
--
--  Post Success:
--    If a date of birth <= the start date then
--    processing continues
--
--    If date of birth is null on insert when system person type is 'EMP' then
--    a warning is flagged and processing continues
--
--    If the persons age is between the minimum and maximum ages defined
--    for the business group then
--    processing continues
--
--  Post Failure:
--    If a date of birth > the start date then
--    an application error will be raised and processing is terminated
--
--    If the persons age is not between the minimum and maximum ages defined
--    for the business group then
--    an application error will be raised and processing is terminated
--
--    If the person type is EMP, and any assignment has its payroll component
--    set, then an application error will be raised and processing terminated
--    if the date of birth is updated to null.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_date_of_birth
  (p_person_id                in  per_all_people_f.person_id%TYPE
  ,p_person_type_id           in  per_all_people_f.person_type_id%TYPE
  ,p_business_group_id        in  per_all_people_f.business_group_id%TYPE
  ,p_start_date               in  date
  ,p_date_of_birth            in  date
  ,p_dob_null_warning         out nocopy boolean
  ,p_effective_date           in  date
  ,p_validation_start_date    in  date
  ,p_validation_end_date      in  date
  ,p_object_version_number    in  per_all_people_f.object_version_number%TYPE) is
--
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_date_of_birth';
  l_api_updating   boolean;
   /* Change for the bug 7001206 starts here */
  -- l_age            number(3);    --852863
  -- l_minimum_age    number(3);    --852863
  -- l_maximum_age    number(3);    --852863

   l_age            number(4);
   l_minimum_age    number(4);
   l_maximum_age    number(4);
   /* Change for the bug 7001206 ends here */
  l_dob_st         boolean := false;
  l_system_person_type varchar2(20);    --2273304
  --
  cursor csr_asg is
    select null
    from per_assignments_f asg
    where asg.person_id = p_person_id
    and   asg.effective_start_date <= p_validation_end_date
    and   asg.effective_end_date >= p_validation_start_date
    and   asg.payroll_id is not null;
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PER_ALL_PEOPLE_F.START_DATE'
     )
  then
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'person type id'
      ,p_argument_value => p_person_type_id
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'business group id'
      ,p_argument_value => p_business_group_id
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation start date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
     ,p_argument       => 'validation end date'
     ,p_argument_value => p_validation_end_date
      );
    --
    p_dob_null_warning := false;
    --
    --  Only proceed with validation if:
    --  a) The current g_old_rec is current and
    --  b) The start date value has changed
    --  c) a record is being inserted
    --
    l_api_updating := per_per_shd.api_updating
      (p_person_id             => p_person_id
      ,p_effective_date        => p_effective_date
      ,p_object_version_number => p_object_version_number);
    --
    if ((l_api_updating and nvl(per_per_shd.g_old_rec.date_of_birth,
                                hr_api.g_date)
      <> nvl(p_date_of_birth,hr_api.g_date)) or
      (NOT l_api_updating)) then
 if g_debug then
      hr_utility.set_location(l_proc, 2);
 end if;
      --
      --  Perform Insert/Update checks
      --
      --  Check if date of birth is greater than start date
      --
      if p_date_of_birth is not null then
        if p_date_of_birth > p_start_date then
          --  Error: The Date of Birth is greater than the start date
          hr_utility.set_message(801, 'HR_6523_PERSON_DOB_GT_START');
          l_dob_st := true;
          hr_utility.raise_error;
        end if;
      end if;
 if g_debug then
      hr_utility.set_location(l_proc, 3);
 end if;
      --
      --  Calculate persons age
      --
 if g_debug then
      hr_utility.set_location(p_effective_date,10);
 end if;
 if g_debug then
      hr_utility.set_location(p_date_of_birth,10);
 end if;
      l_age := trunc(months_between(p_effective_date,p_date_of_birth)/12);
      --
      --  Find the minimum and maximum ages allowed for the business group
      --
      per_people3_pkg.get_legislative_ages(p_business_group_id
                                          ,l_minimum_age
                                          ,l_maximum_age);
      --
 if g_debug then
      hr_utility.set_location(l_proc, 4);
 end if;
      --
      --  Check that the persons age is between the minimum and maximum allowed
      --  for the business group.
      --  This check should not be done if person is of type OTHER. <IJH 483393>
      --
      -- Bug# 2273304 Start Here
      --
      l_system_person_type := return_system_person_type
      (p_person_type_id, p_business_group_id);
      if l_age not between nvl(l_minimum_age,l_age) and
                           nvl(l_maximum_age,l_age) and
         ( l_system_person_type <> 'OTHER' and l_system_person_type <>'%APL') then
          --  Error: Employees age must be between 'min' and 'max'
          hr_utility.set_message(801, 'HR_7426_EMP_AGE_ILLEGAL');
          hr_utility.set_message_token('MIN',to_char(l_minimum_age));
          hr_utility.set_message_token('MAX',to_char(l_maximum_age));
          hr_utility.raise_error;
      end if;
      --
      --Bug# 2273304 End Here
      --
      --
      -- Only proceed with validation if:
      --  a) a record is being inserted
      --
      if NOT l_api_updating then
        --
        --  Perform Insert check
        --
 if g_debug then
        hr_utility.set_location(l_proc, 5);
 end if;
        --
      end if;
      --
      -- Disallow updating of date of birth to null if person type is EMP and
      -- any assignment has its payroll component set.
      --
      if l_api_updating
      and return_system_person_type(p_person_type_id, p_business_group_id) in
               ('EMP','EX_EMP','EMP_APL','EX_EMP_APL')
      and p_date_of_birth is null then
 if g_debug then
        hr_utility.set_location(l_proc, 6);
 end if;
        open csr_asg;
        fetch csr_asg into l_exists;
        if csr_asg%notfound then
        close csr_asg;
          p_dob_null_warning := TRUE;
 if g_debug then
          hr_utility.set_location(l_proc, 7);
 end if;
        else
     close csr_asg;
          hr_utility.set_message(801, 'HR_7950_PPM_NULL_DOB');
          hr_utility.raise_error;
        end if;
      end if;
    End if;
    --  Raise warning if date of birth is null and system person type is 'EMP'
    --
      If return_system_person_type
      (p_person_type_id, p_business_group_id) = 'EMP' and
       p_date_of_birth is null then
       p_dob_null_warning := TRUE;
      end if;
    end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 8);
 end if;
  exception
  when app_exception.application_exception then
    If not l_dob_st then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.DATE_OF_BIRTH'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 9);
 end if;
        raise;
      end if;
    Else
      if hr_multi_message.exception_add
          (p_associated_column1      => 'PER_ALL_PEOPLE_F.DATE_OF_BIRTH'
          ,p_associated_column2      => 'PER_ALL_PEOPLE_F.START_DATE'
          ) then
 if g_debug then
            hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
            raise;
      end if;
    End if;
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc,11);
 end if;
end chk_date_of_birth;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_marital_status  >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the marital status exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'MAR_STATUS' with an enabled
--      flag set to 'Y' and the effective start date of the person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_marital_status
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - marital status exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'MAR_STATUS' where the enabled
--        flag is 'Y' and the effective start date of the person
--        is between start date active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - marital status does'nt exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'MAR_STATUS' where the enabled
--        flag is 'Y' and the effective start date of the person
--        is between start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_marital_status
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_marital_status           in     per_all_people_f.marital_status%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_marital_status';
  l_api_updating   boolean;
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The marital status value has changed
  --  c) a record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number
    );
  if ((l_api_updating
      and nvl(per_per_shd.g_old_rec.marital_status, hr_api.g_varchar2)
      <> nvl(p_marital_status,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
 if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check if marital status is set
    --
    If p_marital_status is not null then
      --
      -- Check that the marital status exists in hr_lookups for the
      -- lookup type 'MAR_STATUS' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'MAR_STATUS'
        ,p_lookup_code           => p_marital_status
        )
      then
        --
        hr_utility.set_message(801, 'HR_7518_PER_M_STATUS_INVALID');
        hr_utility.raise_error;
        --
      end if;
    end if;
 if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.MARITAL_STATUS'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 80);
 end if;
        raise;
      end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,90);
 end if;
end chk_marital_status;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_party_id >----------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the party exists as a party in HZ_PARTIES.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_party_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - party_id is null or party exists in hz_parties.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - party_id does not exist in HZ_PARTIES.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_party_id
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_party_id                 in     number
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_party_id';
  l_api_updating   boolean;
  --
  cursor c1 is
    select null
    from   hz_parties
    where  party_id = p_party_id;
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The party value has changed
  --  c) a record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number
    );
  if ((l_api_updating
      and nvl(per_per_shd.g_old_rec.party_id, hr_api.g_number)
      <> nvl(p_party_id,hr_api.g_number))
    or
      (NOT l_api_updating))
  then
 if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check if party is set
    --
    If p_party_id is not null then
      --
      -- Check that the party_id exists in HZ_PARTIES.
      --
        open c1;
        fetch c1 into l_exists;
        if c1%notfound then
          --
          close c1;
          hr_utility.set_message(800, 'PER_289342_PARTY_ID_INVALID');
          hr_utility.raise_error;
          --
        end if;
        --
      close c1;
      --
    end if;
    --
 if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.PARTY_ID'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 80);
 end if;
        raise;
      end if;
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc,90);
 end if;
end chk_party_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_nationality  >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that a nationality value is valid
--    - Validates that the nationality exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'NATIONALITY' with an enabled
--      flag set to 'Y' and the effective start date of the person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_nationality
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - nationality exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'NATIONALITY' where the enabled
--        flag is 'Y' and the effective start date of the person
--        is between start date active and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - nationality does'nt exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'NATIONALITY' where the enabled
--        flag is 'Y' and the effective start date of the person
--        is between start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_nationality
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_nationality              in     per_all_people_f.nationality%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_nationality';
  l_api_updating   boolean;
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The nationality value has changed
  --  c) A record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number
    );
  if ((l_api_updating
      and nvl(per_per_shd.g_old_rec.nationality, hr_api.g_varchar2)
      <> nvl(p_nationality,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
 if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    --  Check if nationality is set
    --
    if p_nationality is not null then
      --
      -- Check that the nationality exists in hr_lookups for the
      -- lookup type 'NATIONALITY' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'NATIONALITY'
        ,p_lookup_code           => p_nationality
        )
      then
        --
        hr_utility.set_message(801, 'HR_7522_PER_NATION_INVALID');
        hr_utility.raise_error;
        --
      end if;
 if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
    end if;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 60);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.NATIONALITY'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 70);
 end if;
        raise;
      end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,80);
 end if;
end chk_nationality;

-- start for bug 6241572, a new overloaded procedure is created with
-- p_region_of_birth, p_country_of_birth and p_nationality parameters.

procedure chk_national_identifier
  (p_person_id                in  per_all_people_f.person_id%TYPE
  ,p_business_group_id        in  per_all_people_f.business_group_id%TYPE
  ,p_national_identifier      in  per_all_people_f.national_identifier%TYPE
  ,p_date_of_birth            in  date
  ,p_sex                      in  per_all_people_f.sex%TYPE
  ,p_effective_date           in  date
  ,p_object_version_number    in  per_all_people_f.object_version_number%TYPE
  ,p_legislation_code         in  per_business_groups.legislation_code%TYPE
  ,p_person_type_id           in  per_all_people_f.person_type_id%TYPE) is

	-- declaring those variable which are not present in the previous
	-- chk_national_identifier

  l_region_of_birth			  per_all_people_f.region_of_birth%TYPE;
  l_country_of_birth      per_all_people_f.country_of_birth%TYPE;
  l_nationality           per_all_people_f.nationality%TYPE;

begin
	--calling chk_nation_identifier

  per_per_bus.chk_national_identifier
  (p_person_id                => p_person_id,
   p_business_group_id        => p_business_group_id,
   p_national_identifier      => p_national_identifier,
   p_date_of_birth            => p_date_of_birth,
   p_sex                      => p_sex,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_object_version_number,
   p_legislation_code         => p_legislation_code,
   p_person_type_id           => p_person_type_id,
   p_region_of_birth          => l_region_of_birth,
   p_country_of_birth         => l_country_of_birth,
   p_nationality              => l_nationality);

end;

--end for bug 6241572
--
--  ---------------------------------------------------------------------------
--  |-------------------<  chk_national_identifier  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calls process hr_person.validate_national_identifier
--
--  Pre-conditions:
--    Business Group id must be valid
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_national_identifier
--    p_date_of_birth
--    p_sex
--    p_effective_date
--    p_object_version_number
--    p_legislation_code
--    p_person_type_id            - Bug 1642707.
--
--  Post Success:
--    If the national identifier is valid then
--    processing continues
--
--  Post Failure:
--    If the national identifier is not valid then
--    an application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_national_identifier
  (p_person_id                in  per_all_people_f.person_id%TYPE
  ,p_business_group_id        in  per_all_people_f.business_group_id%TYPE
  ,p_national_identifier      in  per_all_people_f.national_identifier%TYPE
  ,p_date_of_birth            in  date
  ,p_sex                      in  per_all_people_f.sex%TYPE
  ,p_effective_date           in  date
  ,p_object_version_number    in  per_all_people_f.object_version_number%TYPE
  ,p_legislation_code         in  per_business_groups.legislation_code%TYPE
  ,p_person_type_id           in  per_all_people_f.person_type_id%TYPE

  --added new parameter for bug 6241572
  ,p_region_of_birth          in  per_all_people_f.region_of_birth%TYPE default NULL
  ,p_country_of_birth         in  per_all_people_f.country_of_birth%TYPE default NULL
  ,p_nationality              in  per_all_people_f.nationality%TYPE) is

--
  l_exists            varchar2(1);
  l_proc              varchar2(72)  :=  g_package||'chk_national_identifier';
  l_api_updating      boolean;
  l_valid_ni          varchar2(240);
  l_warning           varchar2(1)   := 'N';
  l_prof_val          varchar2(50) ;  -- #4069243
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business group id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) national identifier has changed
  --  c) A record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
  --
  if ((l_api_updating and nvl(per_per_shd.g_old_rec.national_identifier,
                              hr_api.g_varchar2)
    <> nvl(p_national_identifier,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 2);
 end if;
    --
    --  If national identifier is not null then
    --  Call process to validate national identifier
    --  (If validation is successful, but returns different format
    --  raise error)
    --
    if p_national_identifier is not null then
    l_valid_ni := hr_ni_chk_pkg.validate_national_identifier(
                      p_national_identifier => p_national_identifier,
                      p_birth_date          => p_date_of_birth,
                      p_gender              => p_sex,
                      p_person_id           => p_person_id,
                 p_business_group_id   => p_business_group_id,
                      p_legislation_code    => p_legislation_code,
                      p_session_date        => p_effective_date,
                      p_warning             => l_warning,
                      p_person_type_id      => p_person_type_id,
                                                                    --change for bug 6241572
		      p_region_of_birth     => p_region_of_birth,
                      p_country_of_birth    => p_country_of_birth,
                      p_nationality         => p_nationality );
      --
--
--
--  3807899 - Modified the 'or' condition to 'and'
--            Also modified the value used to set the token 'RETURNED_VALUE' to l_valid_ni
--            instead of '123-45-789'
--
    if fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'NONE' and fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'WARN' then
    -- #932657
      if l_valid_ni <> p_national_identifier then
        hr_utility.set_message(800, 'HR_52765_PER_INV_NI_FORMAT');
        hr_utility.set_message_token('P_N_I', p_national_identifier);
        hr_utility.set_message_token('RETURNED_VALUE', l_valid_ni); --3807899
   hr_utility.raise_error;
      end if;
     end if;
      -- 4069243 start
       l_prof_val := fnd_profile.value ('PER_NI_UNIQUE_ERROR_WARNING');

        hr_ni_chk_pkg.check_ni_unique
          (p_national_identifier => p_national_identifier
          ,p_person_id => p_person_id
          ,p_business_group_id =>p_business_group_id
          ,p_raise_error_or_warning => nvl(l_prof_val,'WARNING'));
      -- 4069243 end
    end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 4);
 end if;
        raise;
      end if;
 if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc,5);
 end if;
end chk_national_identifier;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_employee_number  >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that an employee value is valid
--
--  Pre-conditions:
--    p_person_type_id must be valid
--    p_business_group_id must be valid for p_person_id
--    p_national_identifier must be valid
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_person_type_id
--    p_employee_number
--    p_national_identifier
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If system person type is 'EMP', 'EX_EMP', 'EMP_APL' or 'EX_EMP_APL' then
--    employee number is defined based on employee number generation method as
--    follows :
--
--        If employee number is not null and employee number generation method
--        is 'Manual' then processing continues.
--        If employee number is null and employee number generation method is
--        'Automatic' then employee number is generated and processing
--        continues.
--        If employee number is null and national identifier is not null and
--        the employee number generation method is 'National identifier' then
--        employee number is set to national identifier and processing
--        continues.
--
--    If the employee number is unique within the business group then
--    processing continues
--
--  Post Failure:
--    If system person type is 'EMP', 'EX_EMP', 'EMP_APL' or 'EX_EMP_APL' then
--    If employee number is null then
--    an application error will be raised and processing is terminated
--
--    If system person type is anything other than 'EMP', 'EX_EMP', 'EMP_APL'
--    or 'EX_EMP_APL' then
--    If employee number is not null then
--    an application error will be raised and processing is terminated
--
--    If the employee number is not unique within the business group then
--    an application error will be raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_employee_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPE
  ,p_employee_number          in out nocopy per_all_people_f.employee_number%TYPE
  ,p_national_identifier      in     per_all_people_f.national_identifier%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE)
is
begin
    chk_employee_number
  (p_person_id              => p_person_id
  ,p_business_group_id      => p_business_group_id
  ,p_person_type_id         => p_person_type_id
  ,p_employee_number        => p_employee_number
  ,p_national_identifier    => p_national_identifier
  ,p_effective_date         => p_effective_date
  ,p_object_version_number  => p_object_version_number
  ,p_party_id               => null
  ,p_date_of_birth          => null
  ,p_start_date             => null
  );
end chk_employee_number;
--
-- Overloaded
--
procedure chk_employee_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPE
  ,p_employee_number          in out nocopy per_all_people_f.employee_number%TYPE
  ,p_national_identifier      in     per_all_people_f.national_identifier%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  ,p_party_id                 in     per_all_people_f.party_id%TYPE
  ,p_date_of_birth            in     per_all_people_f.date_of_birth%TYPE
  ,p_start_date               in     per_periods_of_service.date_start%TYPE)
is
--
  l_exists           varchar2(1);
  l_proc             varchar2(72)  :=  g_package||'chk_employee_number';
  l_api_updating     boolean;
  l_applicant_number per_all_people_f.applicant_number%TYPE;
  l_npw_number       per_all_people_f.npw_number%TYPE;
  l_gen_method       varchar2(1);
  l_emp_ni           boolean       := false;
--
  cursor csr_gen_method is
    select pbg.method_of_generation_emp_num
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
--
-- Declare the function emp_sys_per_type_change
--
  function emp_sys_per_type_change
               (p_new_person_type_id      numeric
               ,p_old_person_type_id      numeric
               ,p_business_group_id       numeric)
  return boolean is
  --
  l_new_system_person_type   per_person_types.system_person_type%TYPE;
  l_old_system_person_type   per_person_types.system_person_type%TYPE;
  l_return_status            boolean;
  l_proc                     varchar2(25) := 'emp_sys_per_type_change';
  --
  -- Cursor to get the system_person_type for the 'old' person_type_id
  --
  cursor get_old_sys_per_type is
         select system_person_type
         from   per_person_types
         where  person_type_id    = p_old_person_type_id
         and    business_group_id = p_business_group_id;
  --
  begin
    --
 if g_debug then
    hr_utility.set_location('Entering '||l_proc,10);
 end if;
    --
    -- Assume we have not changed the system_person_type, so set return
    -- variable to FALSE.
    --
    l_return_status := false;
    --
    -- Check the person_type_id has actually changed
    --
    if p_new_person_type_id <> p_old_person_type_id then
      --
 if g_debug then
      hr_utility.set_location(l_proc, 20);
 end if;
      --
      -- Get the system_person_type for the 'new' person_type_id
      --
      l_new_system_person_type := return_system_person_type
                                 (p_person_type_Id    =>p_new_person_type_id
                                 ,p_business_group_id =>p_business_group_id
                                 );
 if g_debug then
      hr_utility.set_location(l_proc, 30);
 end if;
      --
      -- Get the system_person_type for the 'old' person_type_id
      --
      open get_old_sys_per_type;
      fetch get_old_sys_per_type into l_old_system_person_type;
      close get_old_sys_per_type;
      --
      -- If the system_person_type's have changed then check the transition
      -- to see if the employee number needs to be validated/generated
      --
      if ((l_old_system_person_type = 'OTHER' and
           l_new_system_person_type = 'EMP')
          or
          (l_old_system_person_type = 'APL' and
           l_new_system_person_type in ('EMP','EMP_APL'))
          or
          (l_old_system_person_type = 'APL_EX_APL' and
           l_new_system_person_type = 'EMP')
          or
          (l_old_system_person_type = 'EX_APL' and         -- 4100548
           l_new_system_person_type = 'EMP')
           ) then
        --
 if g_debug then
        hr_utility.set_location(l_proc, 40);
 end if;
        --
        l_return_status := true;
      end if;
 if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
    end if;
 if g_debug then
    hr_utility.set_location(' Leaving '||l_proc, 60);
 end if;
    return l_return_status;
  end emp_sys_per_type_change;
--
-- Declare the function emp_ni_change
--
  function emp_ni_change
               (p_new_ni            varchar2
               ,p_old_ni            varchar2
               ,p_gen_method        varchar2)
  return boolean is
  --
  l_return_status boolean := FALSE;
  l_proc          varchar2(30) := 'emp_ni_change';
  --
  begin
 if g_debug then
    hr_utility.set_location('Entering '||l_proc,10);
 end if;
    --
    if p_gen_method  = 'N' and
       p_new_ni     <> p_old_ni then
 if g_debug then
      hr_utility.set_location(l_proc,20);
 end if;
      l_return_status := TRUE;
    end if;
 if g_debug then
    hr_utility.set_location(' Leaving '||l_proc,30);
 end if;
    return l_return_status;
  end emp_ni_change;
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER'
        )
  then
    --
    -- Check mandatory parameters have been set
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'business group id'
      ,p_argument_value => p_business_group_id
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'person type id'
      ,p_argument_value => p_person_type_id
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date
      );
    --
    --  Only proceed with validation if:
    --  a) The current g_old_rec is current and
    --  b) The employee number value has changed
    --  c) The system_person_type has changed in such a way that emp number is
    --     now required.
    --  d) The NI has changed and the generation method for emp num is 'N'
    --  e) a record is being inserted
    --
    l_api_updating := per_per_shd.api_updating
      (p_person_id             => p_person_id
      ,p_effective_date        => p_effective_date
      ,p_object_version_number => p_object_version_number);
    --
    -- Get the generation method
    --
    open csr_gen_method;
    fetch csr_gen_method into l_gen_method;
    close csr_gen_method;
 if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
    --
    -- Need to validate/generate the employee number if the employee number
    -- has changed or if the system person type has changed in such a way
    -- that an employee number is now required or if the NI number has changed
    -- and the generation method is 'N'.
    --
    if ((l_api_updating and (nvl(per_per_shd.g_old_rec.employee_number,
                              hr_api.g_varchar2) <>
                          nvl(p_employee_number, hr_api.g_varchar2)
                      or  emp_sys_per_type_change
                                   (p_person_type_id
                                   ,per_per_shd.g_old_rec.person_type_id
                                   ,p_business_group_id)
                      or  emp_ni_change
                                   (p_national_identifier
                                   ,per_per_shd.g_old_rec.national_identifier
                                   ,l_gen_method)))
      or
     (NOT l_api_updating)) then
      --
 if g_debug then
      hr_utility.set_location(l_proc, 30);
 end if;
      --
      -- If we are updating and the employee number has actually changed then
      -- ensure the number generation method is not automatic.
      --
      if l_api_updating  and
         nvl(per_per_shd.g_old_rec.employee_number, hr_api.g_varchar2) <>
                            nvl(p_employee_number, hr_api.g_varchar2) and
         l_gen_method = 'A'
           and (not g_global_transfer_in_process
                OR
                   (g_global_transfer_in_process
                    and (PER_BG_NUMBERING_METHOD_PKG.Get_PersonNumber_Formula
                            ('EMP',p_effective_date) is not null))
                    and per_per_shd.g_old_rec.employee_number is not null)
      then
        hr_utility.set_message(801, 'HR_51239_PER_INV_EMP_UPD');
        hr_utility.raise_error;
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
      --  Perform employee number validation as required by number generation
      --  method for the business group, and ensure that it is
      --  unique within the business group.
      --
      if return_system_person_type(p_person_type_id, p_business_group_id) in
        ('EMP','EX_EMP', 'EMP_APL','EX_EMP_APL') then
        --
if g_debug then
        hr_utility.set_location(l_proc, 60);
 end if;
        --
        -- If generation method is 'A' ensure employee number IN is set null
        --
        if l_gen_method = 'A' and
           p_employee_number is not null
           and (not g_global_transfer_in_process
                OR
                   (g_global_transfer_in_process
                    and (PER_BG_NUMBERING_METHOD_PKG.Get_PersonNumber_Formula
                            ('EMP',p_effective_date) is not null)))
        then
          --
          hr_utility.set_message(801,'HR_51240_PER_EMP_NUM_NOT_NULL');
          hr_utility.raise_error;
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 70);
 end if;
        --
        -- If generation method is 'N' ensure employee number IN is set null
        -- on insert.
        --
        if l_gen_method = 'N' and
           NOT l_api_updating and
           p_employee_number <> p_national_identifier then
          --
          hr_utility.set_message(801,'HR_51241_PER_EMP_NUM_NOT_NULL');
          l_emp_ni := true;
          hr_utility.raise_error;
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 80);
 end if;
        --
        -- If generation method is 'N' ensure national identifier IN is not null
        --
        if l_gen_method = 'N' and
           p_national_identifier is null then
          --
          hr_utility.set_message(801,'HR_51242_PER_NAT_ID_NULL');
          l_emp_ni := true;
          hr_utility.raise_error;
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 90);
 end if;
        --
        -- Call number generation routine.
        --
        if l_gen_method = 'A'
           and nvl(fnd_profile.value('PER_GLOBAL_EMP_NUM'),'N') = 'Y'
           and ( PER_BG_NUMBERING_METHOD_PKG.Get_PersonNumber_Formula
                      ('EMP',p_effective_date)) is null
           and p_employee_number is not null
           and g_global_transfer_in_process then
           --
           -- For global transfers we allow passing employee number if numbering
           -- is by global sequence ONLY
           -- The expectation is that the number will be same as original BG record
           -- If it is not set then we assume normal rules should apply
           --
           null;
           --
        else
          hr_person.generate_number(p_current_employee    => 'Y'
                                   ,p_current_applicant   => 'N'
                                   ,p_current_npw         => 'N'
                                   ,p_national_identifier => p_national_identifier
                                   ,p_business_group_id   => p_business_group_id
                                   ,p_person_id           => p_person_id
                                   ,p_employee_number     => p_employee_number
                                   ,p_applicant_number    => l_applicant_number
                                   ,p_npw_number          => l_npw_number
                                   ,p_effective_date      => p_effective_date
                                   ,p_party_id            => p_party_id
                                   ,p_date_of_birth       => p_date_of_birth
                                   ,p_start_date          => p_effective_date);
        end if;
        --
if g_debug then
        hr_utility.set_location(l_proc, 100);
 end if;
        --
        --  Check uniqueness of generated number if not generated automatically
        --
        if l_gen_method <> 'A' then
          --
if g_debug then
          hr_utility.set_location(l_proc, 104);
 end if;
          --
          hr_person.validate_unique_number
                                 (p_person_id         => p_person_id
                                 ,p_business_group_id => p_business_group_id
                                 ,p_employee_number   => p_employee_number
                                 ,p_applicant_number  => null
                                 ,p_npw_number        => null
                                 ,p_current_employee  => 'Y'
                                 ,p_current_applicant => 'N'
                                 ,p_current_npw       => 'N');
          --
if g_debug then
          hr_utility.set_location(l_proc, 108);
 end if;
          --
        end if;
        --
if g_debug then
        hr_utility.set_location(l_proc, 110);
 end if;
        --
      else
        --
        --  System person type is not 'EMP','EX_EMP','EMP_APL' or 'EX_EMP_APL'
        --  so employee number must be null
        --
if g_debug then
        hr_utility.set_location(l_proc, 120);
 end if;
        --
        if p_employee_number is not null then
          --  Error: You cannot enter an employee number for this person type
          hr_utility.set_message(801, 'HR_7523_PER_EMP_NO_NOT_NULL');
          hr_utility.raise_error;
        end if;
        --
if g_debug then
        hr_utility.set_location(l_proc, 130);
 end if;
        --
      end if;
    end if;
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 140);
 end if;
    exception
      when app_exception.application_exception then
    -- if error is not because of national identifier
      if not l_emp_ni
      then
        if hr_multi_message.exception_add
        (p_associated_column1      => 'PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER'
        ) then
if g_debug then
          hr_utility.set_location(' Leaving:'||l_proc, 150);
 end if;
          raise;
        end if;
      else
       if hr_multi_message.exception_add
           (p_associated_column1 => 'PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER'
           ,p_associated_column2 => 'PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER'
           ) then
if g_debug then
             hr_utility.set_location(' Leaving:'||l_proc, 160);
 end if;
             raise;
        end if;
      end if;
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,170);
 end if;
end chk_employee_number;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_npw_number  >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that cwk number value is valid
--
--  Pre-conditions:
--    p_person_type_id must be valid
--    p_business_group_id must be valid for p_person_id
--    p_national_identifier must be valid
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_current_npw_flag
--    p_npw_number
--    p_national_identifier
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If current_npw_flag = Y or there exists a previous CWK record on PTU,
--    npw number is defined based on cwk number generation method as
--    follows :
--
--        If npw number is not null and cwk number generation method
--        is 'Manual' then processing continues.
--        If npw number is null and cwk number generation method is
--        'Automatic' then npw number is generated and processing
--        continues.
--        If npw number is null and national identifier is not null and
--        the cwk number generation method is 'National identifier' then
--        npw number is set to national identifier and processing
--        continues.
--
--    If the npw number is unique within the business group then
--    processing continues
--
--  Post Failure:
--    If current_npw_flag = 'Y' or there exists a previous CWK record on PTU
--    If npw number is null then
--    an application error will be raised and processing is terminated
--
--    If current_npw_flag = N or (is null and no previous CWK record exists on PTU)
--    If npw number is not null then
--    an application error will be raised and processing is terminated
--
--    If the npw number is not unique within the business group then
--    an application error will be raised and processing is terminated
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_npw_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_current_npw_flag         in     per_all_people_f.current_npw_flag%TYPE
  ,p_npw_number               in out nocopy per_all_people_f.npw_number%TYPE
  ,p_national_identifier      in     per_all_people_f.national_identifier%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
)
is
begin
  chk_npw_number
  (p_person_id              => p_person_id
  ,p_business_group_id      => p_business_group_id
  ,p_current_npw_flag       => p_current_npw_flag
  ,p_npw_number             => p_npw_number
  ,p_national_identifier    => p_national_identifier
  ,p_effective_date         => p_effective_date
  ,p_object_version_number  => p_object_version_number
  ,p_party_id               => null
  ,p_date_of_birth          => null
  ,p_start_date             => null
  );
end chk_npw_number;
--
procedure chk_npw_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_current_npw_flag         in     per_all_people_f.current_npw_flag%TYPE
  ,p_npw_number               in out nocopy per_all_people_f.npw_number%TYPE
  ,p_national_identifier      in     per_all_people_f.national_identifier%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  ,p_party_id                 in     per_all_people_f.party_id%TYPE
  ,p_date_of_birth            in     per_all_people_f.date_of_birth%TYPE
  ,p_start_date               in     date
)
is
--
  l_proc             varchar2(72)  :=  g_package||'chk_npw_number';
  l_exists           varchar2(1);
  l_api_updating     boolean;
  l_applicant_number per_all_people_f.applicant_number%TYPE;
  l_employee_number  per_all_people_f.employee_number%TYPE;
  l_gen_method       varchar2(1);
  l_npw_ni           boolean       := false;
--
  cursor csr_gen_method is
    select pbg.method_of_generation_cwk_num
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
--
-- Declare the function emp_ni_change
--
  function npw_ni_change
               (p_new_ni            varchar2
               ,p_old_ni            varchar2
               ,p_gen_method        varchar2)
  return boolean is
  --
  l_return_status boolean := FALSE;
  l_proc          varchar2(30) := 'npw_ni_change';
  --
  begin
if g_debug then
    hr_utility.set_location('Entering '||l_proc,10);
 end if;
    --
    if p_gen_method  = 'N' and
       p_new_ni     <> p_old_ni then
if g_debug then
      hr_utility.set_location(l_proc,20);
 end if;
      l_return_status := TRUE;
    end if;
if g_debug then
    hr_utility.set_location(' Leaving '||l_proc,30);
 end if;
    return l_return_status;
  end npw_ni_change;
--
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  if hr_multi_message.no_exclusive_error
        (p_check_column1      => 'PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER'
        )
  then
    --
    -- Check mandatory parameters have been set
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'business group id'
      ,p_argument_value => p_business_group_id
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date
      );
    --
    --  Only proceed with validation if:
    --  a) The current g_old_rec is current and
    --  b) The npw number value has changed
    --  c) The current_npw_flag has changed in such a way that npw_number is
    --     now required.
    --  d) The NI has changed and the generation method for npw num is 'N'
    --  e) a record is being inserted
    --
    l_api_updating := per_per_shd.api_updating
      (p_person_id             => p_person_id
      ,p_effective_date        => p_effective_date
      ,p_object_version_number => p_object_version_number);
    --
    -- Get the generation method
    --
    open csr_gen_method;
    fetch csr_gen_method into l_gen_method;
    close csr_gen_method;
if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
    --
    --
    -- Need to validate/generate the npw number if the npw number
    -- has changed or if the current_npw_flag has changed in such a way
    -- that an npw number is now required or if the NI number has changed
    -- and the generation method is 'N'.
    --
    if ((l_api_updating and (nvl(per_per_shd.g_old_rec.npw_number,
                              hr_api.g_varchar2) <>
                          nvl(p_npw_number, hr_api.g_varchar2)
                      or (p_current_npw_flag = 'Y'
                          and per_per_shd.g_old_rec.current_npw_flag is null)
                      or  npw_ni_change
                                   (p_national_identifier
                                   ,per_per_shd.g_old_rec.national_identifier
                                   ,l_gen_method)))
      or
     (NOT l_api_updating)) then
      --
if g_debug then
      hr_utility.set_location(l_proc, 30);
 end if;
      --
      -- If we are updating and the npw number has actually changed then
      -- ensure the number generation method is not automatic.
      --
      if l_api_updating  and
         nvl(per_per_shd.g_old_rec.npw_number, hr_api.g_varchar2) <>
                            nvl(p_npw_number, hr_api.g_varchar2) and
         l_gen_method = 'A' then
        hr_utility.set_message(800, 'HR_289657_PER_INV_CWK_UPD');
        hr_utility.raise_error;
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
      --  Perform npw number validation as required by number generation
      --  method for the business group, and ensure that it is
      --  unique within the business group.
      --
      if p_current_npw_flag = 'Y' then
        --
if g_debug then
        hr_utility.set_location(l_proc, 60);
 end if;
        --
        -- If generation method is not specified then error: ct. may not have upgraded
        -- BG info
        if l_gen_method is null then
          --
          hr_utility.set_message(800,'PER_289634_CWK_GEN_NOT_NULL');
          hr_utility.raise_error;
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 60);
 end if;
        --
        -- If generation method is 'A' ensure npw number IN is set null
        -- or has not changed from its previous value (fixes 2876274)
        --
        if l_gen_method = 'A' and
           p_npw_number is not null and
           p_npw_number <> nvl(per_per_shd.g_old_rec.npw_number,hr_api.g_varchar2) then
          --
          hr_utility.set_message(800,'PER_289635_CWK_NUM_NOT_NULL');
          hr_utility.raise_error;
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 70);
 end if;
        --
        -- If generation method is 'N' ensure npw number IN is set null
        -- on insert.
        --
        if l_gen_method = 'N' and
           NOT l_api_updating and
           p_npw_number <> p_national_identifier then
          --
          hr_utility.set_message(800,'PER_289636_CWK_NUM_NOT_NULL');
          l_npw_ni := true;
          hr_utility.raise_error;
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 80);
 end if;
        --
        -- If generation method is 'N' ensure national identifier IN is not null
        --
        if l_gen_method = 'N' and
           p_national_identifier is null then
          --
          hr_utility.set_message(800,'PER_289637_CWK_NAT_ID_NULL');
          l_npw_ni := true;
          hr_utility.raise_error;
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 90);
 end if;
        --
        -- Call number generation routine.
        --
        hr_person.generate_number(p_current_employee    => 'N'
                                 ,p_current_applicant   => 'N'
                                 ,p_current_npw         => 'Y'
                                 ,p_national_identifier => p_national_identifier
                                 ,p_business_group_id   => p_business_group_id
                                 ,p_person_id           => p_person_id
                                 ,p_employee_number     => l_employee_number
                                 ,p_applicant_number    => l_applicant_number
                                 ,p_npw_number          => p_npw_number
                                 ,p_effective_date      => p_effective_date
                                 ,p_party_id            => p_party_id
                                 ,p_date_of_birth       => p_date_of_birth
                                 ,p_start_date          => p_effective_date);

        --
if g_debug then
        hr_utility.set_location(l_proc, 100);
 end if;
        --
        --  Check uniqueness of generated number if not generated automatically
        --
        if l_gen_method <> 'A' then
          --
if g_debug then
          hr_utility.set_location(l_proc, 104);
 end if;
          --
          hr_person.validate_unique_number
                                 (p_person_id         => p_person_id
                                 ,p_business_group_id => p_business_group_id
                                 ,p_employee_number   => null
                                 ,p_applicant_number  => null
                                 ,p_npw_number        => p_npw_number
                                 ,p_current_employee  => 'N'
                                 ,p_current_applicant => 'N'
                                 ,p_current_npw       => 'Y');
          --
if g_debug then
          hr_utility.set_location(l_proc, 108);
 end if;
          --
        end if;
        --
if g_debug then
        hr_utility.set_location(l_proc, 110);
 end if;
        --
      else
        --
        --  current_npw_flag is null, so npw number must be null
        --
if g_debug then
        hr_utility.set_location(l_proc, 120);
 end if;
        --
        if p_npw_number is not null then
          --  Error: You cannot enter an npw number for this person type
          hr_utility.set_message(800, 'PER_289638_CWK_NUM_NOT_NULL');
          hr_utility.raise_error;
        end if;
        --
if g_debug then
        hr_utility.set_location(l_proc, 130);
 end if;
        --
      end if;
    end if;
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 140);
 end if;
    exception
      when app_exception.application_exception then
    -- if error is not because of national identifier
      if not l_npw_ni
      then
        if hr_multi_message.exception_add
        (p_associated_column1      => 'PER_ALL_PEOPLE_F.NPW_NUMBER'
        ) then
if g_debug then
          hr_utility.set_location(' Leaving:'||l_proc, 150);
 end if;
          raise;
        end if;
      else
       if hr_multi_message.exception_add
           (p_associated_column1 => 'PER_ALL_PEOPLE_F.NPW_NUMBER'
           ,p_associated_column2 => 'PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER'
           ) then
if g_debug then
             hr_utility.set_location(' Leaving:'||l_proc, 160);
 end if;
             raise;
        end if;
      end if;
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,170);
 end if;
end chk_npw_number;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_expense_check_send_to_addr  >-------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the expense check send to address exists as a lookup
--      code on HR_LOOKUPS for the lookup type 'HOME_OFFICE' with an enabled
--      flag set to 'Y' and the effective start date of the person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_expense_check_send_to_addres
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - expense check send to address exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'HOME_OFFICE' where the enabled flag is 'Y' and
--        the effective start date of the person is between start date active
--        and end date active on HR_LOOKUPS.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - expense check send to address does'nt exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'HOME_OFFICE' where the enabled
--        flag is 'Y' and the effective start date of the person
--        is between start date active and end date active on HR_LOOKUPS.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_expense_check_send_to_addr
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_expense_check_send_to_addres in     per_all_people_f.expense_check_send_to_address%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_expense_check_send_to_addr';
  l_api_updating   boolean;
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The expense check send to address value has changed
  --  c) a record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number
    );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating
      and nvl(per_per_shd.g_old_rec.expense_check_send_to_address,
          hr_api.g_varchar2)
      <> nvl(p_expense_check_send_to_addres,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check if expense check send to address is set
    --
    If p_expense_check_send_to_addres is not null then
      --
      -- Check that the expense check send to address exists in hr_lookups for the
      -- lookup type 'HOME_OFFICE' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'HOME_OFFICE'
        ,p_lookup_code           => p_expense_check_send_to_addres
        )
      then
        --
        hr_utility.set_message(801, 'HR_51251_PER_CHECK_SEND_ADR');
        hr_utility.raise_error;
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc, 60);
 end if;
    --
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.EXPENSE_CHECK_SEND_TO_ADDRESS'
      ) then
if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 80);
 end if;
        raise;
      end if;
if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc,90);
 end if;

end chk_expense_check_send_to_addr;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_sex_title  >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that the sex exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'SEX' with an enabled
--      flag set to 'Y' and the effective start date of the person between
--      start date active and end date active on HR_LOOKUPS.
--    - Validates that the title exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'TITLE' with an enabled
--      flag set to 'Y' and the effective start date of the person between
--      start date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    A valid person type
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_person_type_id
--    p_title
--    p_sex
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - a sex exists as a lookup code in HR_LOOKUPS for the lookup type
--        'SEX' where the enabled flag is 'Y' and the effective start
--        date of the person is between start date active and end date
--        active on HR_LOOKUPS.
--      - a title exists as a lookup code in HR_LOOKUPS for the lookup type
--        'TITLE' where the enabled flag is 'Y' and the effective start
--        date of the person is between start date active and end date
--        active on HR_LOOKUPS.
--      - a sex value is 'M' and the title value is not 'MISS','MRS.',
--        'MS.'
--      - a sex value is 'F' and the title value is 'MR'.
--      - the related system person type is 'EMP' and a sex value is
--        set.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - a sex does'nt exist as a lookup code in HR_LOOKUPS for the lookup
--        type 'SEX' where the enabled flag is 'Y' and the effective start
--        date of the person is between start date active and end date
--        active on HR_LOOKUPS.
--      - a title does'nt exist as a lookup code in HR_LOOKUPS for the lookup
--        type 'TITLE' where the enabled flag is 'Y' and the effective start
--        date of the person is between start date active and end date
--        active on HR_LOOKUPS.
--      - a sex value is 'M' and the title value is 'MISS','MRS.', 'MS.'
--      - a sex value is 'F' and the title value is 'MR.'
--      - the related system person type is 'EMP' and a sex value is not
--        set.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_sex_title
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPe
  ,p_title                    in     per_all_people_f.title%TYPE
  ,p_sex                      in     per_all_people_f.sex%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_sex_title';
  l_api_updating   boolean;
  l_lookup_type    varchar2(30);
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The sex value has changed
  --  c) The title value has changed
  --  d)A record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number
    );
if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating
        and nvl(per_per_shd.g_old_rec.sex, hr_api.g_varchar2)
        <> nvl(p_sex,hr_api.g_varchar2))
      or
        (l_api_updating and nvl(per_per_shd.g_old_rec.title,hr_api.g_varchar2)
        <> nvl(p_title,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
    then
if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    -- Check if title is set
    --
    If p_title is not null then
      --
      -- Check that the title exists in hr_lookups for the lookup type
      -- 'TITLE' with an enabled flag set to 'Y' and that the effective
      -- start date of the person is between start date active and end
      -- date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
         (p_effective_date        => p_effective_date
         ,p_validation_start_date => p_validation_start_date
         ,p_validation_end_date   => p_validation_end_date
         ,p_lookup_type           => 'TITLE'
         ,p_lookup_code           => p_title
         )
      then
        --
        hr_utility.set_message(801, 'HR_7512_PER_TITLE_INVALID');
        hr_multi_message.add
   (p_associated_column1      => 'PER_ALL_PEOPLE_F.TITLE'
   );
      --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
      --
    end if;
    --
    --  Check if sex is set
    --
    If p_sex is not null then
      --
      -- Check that the sex exists in hr_lookups for the lookup type
      -- 'SEX' with an enabled flag set to 'Y' and that the effective
      -- start date of the person is between start date active and end
      -- date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'SEX'
        ,p_lookup_code           => p_sex
        )
      then
        --
        hr_utility.set_message(801, 'HR_7511_PER_SEX_INVALID');
        hr_multi_message.add
   (p_associated_column1      => 'PER_ALL_PEOPLE_F.SEX'
   );
        --
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 40);
 end if;
      --
      -- Check if title is set
      --
      If p_title is not null then
        --
        --  Check that title is consistent with sex
        --
        If p_sex = 'M' and
           p_title in ('MISS','MRS.','MS.') then
          --  Error: Values for Sex and Title are inconsistent.
          hr_utility.set_message(801, 'HR_6527_PERSON_SEX_AND_TITLE');
          hr_multi_message.add
     (p_associated_column1      => 'PER_ALL_PEOPLE_F.TITLE'
     ,p_associated_column2      => 'PER_ALL_PEOPLE_F.SEX'
     );
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 70);
 end if;
        --
        If p_sex = 'F' and
           p_title = 'MR.' then
          --  Error: Values for Sex and Title are inconsistent.
          hr_utility.set_message(801, 'HR_6527_PERSON_SEX_AND_TITLE');
          hr_multi_message.add
     (p_associated_column1      => 'PER_ALL_PEOPLE_F.TITLE'
     ,p_associated_column2      => 'PER_ALL_PEOPLE_F.SEX'
     );
        end if;
if g_debug then
        hr_utility.set_location(l_proc, 80);
 end if;
        --
      end if;
    else
      --
      --  If sex is null check if system person type contains 'EMP'
      --
      if instr(return_system_person_type(p_person_type_id,
                                         p_business_group_id),'EMP') <> 0 then
        --  Error: You must enter sex for an employee.
        hr_utility.set_message(801, 'HR_6524_EMP_MANDATORY_SEX');
        hr_multi_message.add
   (p_associated_column1      => 'PER_ALL_PEOPLE_F.SEX'
   );
      end if;
if g_debug then
      hr_utility.set_location(l_proc, 90);
 end if;
      --
    end if;
if g_debug then
    hr_utility.set_location(' Leaving:'|| l_proc, 130);
 end if;
  end if;
end chk_sex_title;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_town_of_birth >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that the town of birth parameter corresponds to a valid lookup value if
--    there a row in pay_legislative_field_info for the current legislation code
--    and the field_name of 'TOWN_OF_BIRTH'. (If no row exists in PLFI table then
--    assume this field is free text and under the current legislation is not validated).
--
--  Pre-conditions:
--
--  In Arguments:
--    p_person_id
--    p_town_of_birth
--    p_effective_date
--    p_validation_start_date  in date
--    p_validation_end_date    in date
--    p_legislation_code
--
--  Post Success:
--    On insert/update if a town of birth value exists then
--    processing continues
--
--  Post Failure:
--    On insert/update if a town of birth value does not exist
--    then an application error will be raised and processing is
--    terminated
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_town_of_birth
  (p_person_id              in per_all_people_f.person_id%TYPE,
   p_town_of_birth          in per_all_people_f.town_of_birth%TYPE,
   p_effective_date         in date,
   p_validation_start_date  in date,
   p_validation_end_date    in date,
   p_legislation_code       in per_business_groups.legislation_code%TYPE) is
--
--
  CURSOR csr_plfi is
  SELECT rule_type
  FROM pay_legislative_field_info plfi
  WHERE upper(plfi.field_name) = 'TOWN_OF_BIRTH'
  AND plfi.legislation_code = p_legislation_code;
--
  l_exists         varchar2(1);
  l_lookup_type    hr_lookups.lookup_type%TYPE;
  l_proc           varchar2(72);
  --
begin
if g_debug then
 l_proc  :=  g_package||'chk_town_of_birth';
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  if p_town_of_birth IS NOT NULL then
  --
  --  Only proceed with validation if:
  --  a) rec is being inserted or
  --  b) rec is updating and the g_old_rec is not current value
  --
    if ((p_person_id is null)
     OR
       ((p_person_id is not null) and
      nvl(p_town_of_birth,hr_api.g_varchar2) <> nvl(per_per_shd.g_old_rec.town_of_birth,hr_api.g_varchar2))) then
      --
if g_debug then
      hr_utility.set_location(l_proc, 2);
 end if;
      --
      open csr_plfi;
      fetch csr_plfi into l_lookup_type;
      if csr_plfi%found then
        close csr_plfi;
        -- attempt to decode the lookup type returned from plfi record
      -- with the p_town_of_birth lookup_value supplied to the api.
        if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => l_lookup_type
        ,p_lookup_code           => p_town_of_birth
        )
      then
          --  Error: Invalid town lookup_value has been passed.
        hr_utility.set_message_token('TOWN_CODE', p_town_of_birth);
          hr_utility.set_message(800, 'PER_52619_TOWN_NOT_FOUND)');
          hr_utility.raise_error;
      end if;
      else
        close csr_plfi;
    end if;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.TOWN_OF_BIRTH'
      ) then
if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 4);
 end if;
        raise;
      end if;
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,5);
 end if;
end chk_town_of_birth;
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_region_of_birth >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that the region of birth parameter corresponds to a valid lookup value if
--    there a row in pay_legislative_field_info for the current legislation code
--    and the field_name of 'REGION_OF_BIRTH'. (If no row exists in PLFI table then
--    assume this field is free text and under the current legislation is not validated).
--
--  Pre-conditions:
--
--  In Arguments:
--    p_person_id
--    p_region_of_birth
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_legislation_code
--
--  Post Success:
--    On insert/update if a region of birth value exists then
--    processing continues
--
--  Post Failure:
--    On insert/update if a region of birth value does not exist
--    then an application error will be raised and processing is
--    terminated
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_region_of_birth
  (p_person_id              in per_all_people_f.person_id%TYPE,
   p_region_of_birth        in per_all_people_f.region_of_birth%TYPE,
   p_effective_date         in date,
   p_validation_start_date  in date,
   p_validation_end_date    in date,
   p_legislation_code       in per_business_groups.legislation_code%TYPE) is
--
--
  CURSOR csr_plfi is
  SELECT rule_type
  FROM pay_legislative_field_info plfi
  WHERE upper(plfi.field_name) = 'REGION_OF_BIRTH'
  AND plfi.legislation_code = p_legislation_code;
--
  l_exists         varchar2(1);
  l_lookup_type    hr_lookups.lookup_type%TYPE;
  l_proc           varchar2(72);
  --
begin
if g_debug then
 l_proc :=  g_package||'chk_region_of_birth';
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  if p_region_of_birth IS NOT NULL then
  --
  --  Only proceed with validation if:
  --  a) rec is being inserted or
  --  b) rec is updating and the g_old_rec is not current value
  --
    if ((p_person_id is null)
     OR
       ((p_person_id is not null) and
      nvl(p_region_of_birth,hr_api.g_varchar2) <> nvl(per_per_shd.g_old_rec.region_of_birth,hr_api.g_varchar2))) then
      --
if g_debug then
      hr_utility.set_location(l_proc, 2);
 end if;
      --
      open csr_plfi;
      fetch csr_plfi into l_lookup_type;
      if csr_plfi%found then
        close csr_plfi;
        -- attempt to decode the lookup type returned from plfi record
      -- with the p_region_of_birth lookup_value supplied to the api.
        if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => l_lookup_type
        ,p_lookup_code           => p_region_of_birth
        )
      then
          --  Error: Invalid region lookup_value has been passed.
        hr_utility.set_message_token('REGION_CODE', p_region_of_birth);
          hr_utility.set_message(800, 'PER_52620_REGION_NOT_FOUND)');
          hr_utility.raise_error;
      end if;
      else
        close csr_plfi;
    end if;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.REGION_OF_BIRTH'
      ) then
if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 4);
 end if;
        raise;
      end if;
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,5);
 end if;
end chk_region_of_birth;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_country_of_birth >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that a country of birth value (country short code) is valid
--
--  Pre-conditions:
--
--  In Arguments:
--    p_person_id
--    p_country_of_birth
--
--  Post Success:
--    On insert/update if a country of birth value exists then
--    processing continues
--
--  Post Failure:
--    On insert/update if a country of birth value does not exist
--    then an application error will be raised and processing is
--    terminated
--
--  Access Status:
--    Internal Row Handler Use Only.
--
procedure chk_country_of_birth
  (p_person_id                in per_all_people_f.person_id%TYPE,
   p_country_of_birth         in per_all_people_f.country_of_birth%TYPE) is
--
  l_exists         varchar2(1);
  l_proc           varchar2(72);
--
-- cursor to attempt to match the country short code.
--
  cursor csr_country is
  Select null
  from fnd_territories_vl ftv
  where ftv.territory_code = p_country_of_birth;
--
begin
if g_debug then
 l_proc :=  g_package||'chk_country_of_birth';
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  if p_country_of_birth IS NOT NULL then
  --
  --  Only proceed with validation if:
  --  a) rec is being inserted or
  --  b) rec is updating and the g_old_rec is not current value
  --
    if ((p_person_id is null)
     OR
       ((p_person_id is not null) and
      nvl(p_country_of_birth,hr_api.g_varchar2) <> nvl(per_per_shd.g_old_rec.country_of_birth,hr_api.g_varchar2))) then
      --
if g_debug then
      hr_utility.set_location(l_proc, 2);
 end if;
      --
      open csr_country;
      fetch csr_country into l_exists;
      if csr_country%notfound then
        close csr_country;
        --  Error: Invalid country short code
      hr_utility.set_message_token('COUNTRY_CODE', p_country_of_birth);
        hr_utility.set_message(800, 'PER_52618_COUNTRY_NOT_FOUND');
        hr_utility.raise_error;
      end if;
      close csr_country;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.COUNTRY_OF_BIRTH'
      ) then
if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 4);
 end if;
        raise;
      end if;
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,5);
 end if;
end chk_country_of_birth;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_start_date >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that a start date value is valid
--
--  Pre-conditions:
--
--  In Arguments:
--    p_person_id
--    p_start_date
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    On insert if a start date is the same as effective date then
--    processing continues
--
--    On update if a start date is the same as the minimum effective start date
--    then processing continues
--
--  Post Failure:
--    On insert if a start date is not the same as the effective
--    date then an application error will be raised and processing is
--    terminated
--
--    On update if a start date is not the same as the minimum effective start
--    date then an application error will be raised and processing is
--    terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_start_date
  (p_person_id                in per_all_people_f.person_id%TYPE
  ,p_start_date               in date
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_people_f.object_version_number%TYPE) is
--
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_start_date';
  l_api_updating   boolean;
  l_min_date       date;
--
-- Find the earliest effective start date for the person
--
  cursor csr_chk_min_date is
  Select min(effective_start_date)
  from per_all_people_f
  where p_person_id = person_id;
--
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start date'
    ,p_argument_value => p_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The start date value has changed
  --  c) A record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
  --
  if NOT l_api_updating then
    --
    -- On insert check that start date equals effective date
    --
if g_debug then
    hr_utility.set_location(l_proc, 2);
 end if;
    --
    if p_start_date <> p_effective_date then
      --  Error: Invalid Start Date
      hr_utility.set_message(801, 'HR_7514_PER_START_DATE_INVALID');
      hr_utility.raise_error;
    end if;
  elsif(l_api_updating and per_per_shd.g_old_rec.start_date <>
        p_start_date) then
    --
    --  On update check if start date is the same as the earliest effective
    --  start date
    --
if g_debug then
    hr_utility.set_location(l_proc, 3);
 end if;
    --
    open csr_chk_min_date;
    fetch csr_chk_min_date into l_min_date;
    if p_start_date <> l_min_date then
      close csr_chk_min_date;
      --  Error: Invalid start date

      hr_utility.set_message(801, 'HR_7514_PER_START_DATE_INVALID');
      hr_utility.raise_error;
    end if;
    close csr_chk_min_date;
  end if;
if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.START_DATE'
      ) then
if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 5);
 end if;
        raise;
      end if;
if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc,6);
 end if;

end chk_start_date;
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_orig_and_start_dates >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Validates that for person type of 'EMP','EMP_APL','EX_EMP' or
--      'EX_EMP_APL' the original date of hire is the same of earlier
--      than the earliest per_periods_of_service start date.
--      For any other person type a warning is raised if an original
--      date of hire is entered.
--
--  Pre-conditions:
--    Valid p_person_id.
--
--  In Arguments:
--    p_person_id
--    p_person_type_id
--    p_business_group_id
--    p_original_date_of_hire
--    p_effective_date
--    p_start_date
--    p_object_version_number
--
--  Out Arguments:
--    p_orig_hire_warning
--
--  Post Success:
--    Processing continues if:
--      - person_type is 'EMP','EMP_APL','EX_EMP' or 'EX_EMP_APL'
--        and original_date_of_hire is on or before the start date
--      - person_type is not 'EMP','EMP_APL','EX_EMP','EX_EMP_APL'
--        and original_date_of_hire is not entered
--      - person_type is not 'EMP','EMP_APL','EX_EMP','EX_EMP_APL'
--        and original_date_of_hire is enter and the warning
--        message is acknowledged.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - person_type is 'EMP','EMP_APL','EX_EMP' or 'EX_EMP_APL' and
--        the original_date_of_hire is later than the start_date.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_orig_and_start_dates
  (p_person_id             in     per_all_people_f.person_id%TYPE
  ,p_person_type_id        in     per_all_people_f.person_type_id%TYPE
  ,p_business_group_id     in     per_all_people_f.business_group_id%TYPE
  ,p_original_date_of_hire in     per_all_people_f.original_date_of_hire%TYPE
  ,p_start_date            in     per_all_people_f.start_date%TYPE
  ,p_effective_date        in     date
  ,p_object_version_number in     per_all_people_f.object_version_number%TYPE
  ,p_orig_hire_warning     out nocopy    boolean
  ) is
--
l_proc          varchar2(72) ;
l_system_person_type varchar2(72) := return_system_person_type
                                     (p_person_type_id
                                     ,p_business_group_id);
l_earliest_date date;
--
cursor csr_earliest_date is
select min(date_start)
from per_periods_of_service
where p_person_id = person_id;

-- added for the bug 5402099
l_earliest_date1 date;
cursor original_date_of_hire_ppf is
select original_date_of_hire from per_all_people_f where
person_id=p_person_id and
p_original_date_of_hire between effective_start_date and effective_end_date ;
-- end of bug 5402099
--
begin
  --
p_orig_hire_warning := FALSE;
  --
if g_debug then
 l_proc :=  g_package||'chk_orig_and_start_dates';
  hr_utility.set_location('Entering:'|| l_proc,5);
 end if;
--
  if p_original_date_of_hire is NOT NULL then
    if (nvl(per_per_shd.g_old_rec.original_date_of_hire,hr_api.g_date)
      <> nvl(p_original_date_of_hire, hr_api.g_date)) or
      (per_per_shd.g_old_rec.start_date <> p_start_date) then
--
      if l_system_person_type in ('EMP','EMP_APL','EX_EMP','EX_EMP_APL') then
--
        if (p_person_id is null and
          (nvl(p_original_date_of_hire,hr_api.g_date) > p_start_date)) then
          hr_utility.set_message(800,'PER_52474_PER_ORIG_ST_DATE');
          hr_multi_message.add
          (p_associated_column1 => 'PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE'
          ,p_associated_column2 => 'PER_ALL_PEOPLE_F.START_DATE'
          );
--
       elsif p_person_id is not null then
          open csr_earliest_date;
          fetch csr_earliest_date into l_earliest_date;
	  -- added for the bug 5402099
	     open original_date_of_hire_ppf ;
             fetch original_date_of_hire_ppf into l_earliest_date1;
             hr_utility.set_location('l_earliest_date1:'|| l_earliest_date1,10);
             if l_earliest_date1 is null then
                 l_earliest_date:=p_original_date_of_hire;
                 hr_utility.set_location('l_earliest_date:'|| l_earliest_date,15);
                 close original_date_of_hire_ppf;
              else
                 close original_date_of_hire_ppf;
              end if;
           -- end of  bug 5402099
          if (nvl(p_original_date_of_hire,hr_api.g_date) > l_earliest_date) then
  /* 1352469 Replaced with above IF statement
            if ((l_earliest_date <= p_start_date) and
              (nvl(p_original_date_of_hire,hr_api.g_date) > l_earliest_date))
              or ((l_earliest_date > p_start_date) and
                (nvl(p_original_date_of_hire,hr_api.g_date) > p_start_date)) then
  */
            hr_utility.set_message(800,'PER_52474_PER_ORIG_ST_DATE');
            close csr_earliest_date;
            hr_multi_message.add
            (p_associated_column1 => 'PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE'
            );
          else
            close csr_earliest_date;
          end if;
        end if;
--
      elsif l_system_person_type not in ('EMP','EMP_APL','EX_EMP','EX_EMP_APL')
        then p_orig_hire_warning := TRUE;
      end if;
    end if;
  end if;
  --
if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
--
end chk_orig_and_start_dates;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_GB_per_information >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Checks that the values held in developer descriptive flexfields
--      are valid for a category of 'GB'
--    - Validates that per information3  and per information11 to 20 are null.
--    - Validates that per information2, 4 ,9 and 10 exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'YES_NO' with an enabled flag set to 'Y'
--      and the effective start date of the person between start date active
--      and end date active on HR_LOOKUPS.
--    - Validates that per information1 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'ETH_TYPE' with an enabled flag set to 'Y' and the
--      effective start date of the person between start date active and end
--      date active on HR_LOOKUPS.
--    - Validates that per information5 is less than or equal to 30 characters
--      and in uppercase.
--
--  Pre-conditions:
--    A GB per information category
--
--  In Arguments:
--    p_person_id
--    p_per_information_category
--    p_per_information1
--    p_per_information2
--    p_per_information3
--    p_per_information4
--    p_per_information5
--    p_per_information6
--    p_per_information7
--    p_per_information8
--    p_per_information9
--    p_per_information10
--    p_per_information11
--    p_per_information12
--    p_per_information13
--    p_per_information14
--    p_per_information15
--    p_per_information16
--    p_per_information17
--    p_per_information18
--    p_per_information19
--    p_per_information20
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--      - per_information3 and per_information11 to 20 values are null
--      - per information2, 4 , 9 and 10 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y'
--        and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information1 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'ETH_TYPE' where the enabled flag is 'Y'
--        and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per_information5 is less than or equal to 30 characters long
--        and upper case.
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - any of per_information3 and per_information10 to 20 values are
--        not null.
--      - any of per information2, 4,9 and 10 does'nt exist as a lookup code
--        in HR_LOOKUPS for the lookup type 'YES_NO' where the enabled flag
--        is 'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information1 does'nt exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'ETH_TYPE' where the enabled flag is 'Y'
--        and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per_information5 is not less than or equal to 30 characters long
--        or not upper case.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_GB_per_information
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_per_information_category in     per_all_people_f.per_information_category%TYPE
  ,p_per_information1         in     per_all_people_f.per_information1%TYPE
  ,p_per_information2         in     per_all_people_f.per_information2%TYPE
  ,p_per_information3         in     per_all_people_f.per_information3%TYPE
  ,p_per_information4         in     per_all_people_f.per_information4%TYPE
  ,p_per_information5         in     per_all_people_f.per_information5%TYPE
  ,p_per_information6         in     per_all_people_f.per_information6%TYPE
  ,p_per_information7         in     per_all_people_f.per_information7%TYPE
  ,p_per_information8         in     per_all_people_f.per_information8%TYPE
  ,p_per_information9         in     per_all_people_f.per_information9%TYPE
  ,p_per_information10        in     per_all_people_f.per_information10%TYPE
  ,p_per_information11        in     per_all_people_f.per_information11%TYPE
  ,p_per_information12        in     per_all_people_f.per_information12%TYPE
  ,p_per_information13        in     per_all_people_f.per_information13%TYPE
  ,p_per_information14        in     per_all_people_f.per_information14%TYPE
  ,p_per_information15        in     per_all_people_f.per_information15%TYPE
  ,p_per_information16        in     per_all_people_f.per_information16%TYPE
  ,p_per_information17        in     per_all_people_f.per_information17%TYPE
  ,p_per_information18        in     per_all_people_f.per_information18%TYPE
  ,p_per_information19        in     per_all_people_f.per_information19%TYPE
  ,p_per_information20        in     per_all_people_f.per_information20%TYPE
  ,p_per_information21        in     per_all_people_f.per_information21%TYPE
  ,p_per_information22        in     per_all_people_f.per_information22%TYPE
  ,p_per_information23        in     per_all_people_f.per_information23%TYPE
  ,p_per_information24        in     per_all_people_f.per_information24%TYPE
  ,p_per_information25        in     per_all_people_f.per_information25%TYPE
  ,p_per_information26        in     per_all_people_f.per_information26%TYPE
  ,p_per_information27        in     per_all_people_f.per_information27%TYPE
  ,p_per_information28        in     per_all_people_f.per_information28%TYPE
  ,p_per_information29        in     per_all_people_f.per_information29%TYPE
  ,p_per_information30        in     per_all_people_f.per_information30%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_error          exception;
  l_proc           varchar2(72)  :=  g_package||'chk_GB_per_information';
  l_api_updating   boolean;
  l_lookup_type    varchar2(30);
  l_info_attribute number(2);
  l_per_information6 per_all_people_f.per_information6%TYPE;
  l_per_information7 per_all_people_f.per_information7%TYPE;
  l_per_information8 per_all_people_f.per_information8%TYPE;
  l_output           varchar2(150);
  l_rgeflg           varchar2(10);
  --
begin
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check the mandatory parameters
  --
   hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- We know the per_information_category is GB, so check the rest of
  -- the per_information fields within this context.
  --
  --  Check if the per_information1 value exists in hr_lookups
  --  where the lookup_type is 'ETH_TYPE'
  --
  if p_per_information1 is not null then
    --
    -- Check that per information1 exists in hr_lookups for the
    -- lookup type 'ETH_TYPE' with an enabled flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'ETH_TYPE'
      ,p_lookup_code           => p_per_information1
      )
    then
      --
      hr_utility.set_message(801, 'HR_7524_PER_INFO1_INVALID');
      hr_utility.raise_error;
      --
    end if;
if g_debug then
    hr_utility.set_location(l_proc,30);
 end if;
    --
  end if;
if g_debug then
  hr_utility.set_location(l_proc,40);
 end if;
  --
  --  Check if the per_information2 value exists in hr_lookups
  --  where the lookup_type is 'YES_NO'
  --
  if p_per_information2 is not null then
    --
    -- Check that per information2 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information2
      )
    then
      --
      hr_utility.set_message(801, 'HR_7525_PER_INFO2_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,50);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(l_proc,60);
 end if;
  --
  --  Check if the per_information4 value exists in hr_lookups
  --  where the lookup_type is 'YES_NO'
  --
  if p_per_information4 is not null then
    --
    -- Check that per information4 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information4
      )
    then
      --
      hr_utility.set_message(801, 'HR_7526_PER_INFO4_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,70);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(l_proc,80);
 end if;
  --
  -- Check if p_per_information5 is greater than 30 characters long
  --
  if p_per_information5 is not null then
    if length(p_per_information5) > 30 then
      --  Error: Work Permit (PER_INFORMATION5) cannot be longer than
      --         30 characters
      hr_utility.set_message(801, 'HR_7527_PER_INFO5_LENGTH');
      hr_utility.raise_error;
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,90);
 end if;
    --
    --  Check if p_per_information5 is not upper case
    --
    --if p_per_information5 <> upper(p_per_information5) then
      --  Error: Enter the Work Permit value (PER_INFORMATION5) in
      --         upper case
      --hr_utility.set_message(801, 'HR_7528_PER_INFO5_CASE');
      --hr_utility.raise_error;
    --end if;
 --if g_debug then
    --hr_utility.set_location(l_proc,100);
 --end if;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc,110);
 end if;
  --
  -- Check if p_per_information6 is in the range 0 - 99.
  --
  if p_per_information6 is not null then
    --
    l_per_information6 := p_per_information6;
    hr_chkfmt.checkformat(value   => l_per_information6
                         ,format  => 'I'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok  => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
 if g_debug then
    hr_utility.set_location(l_proc,120);
 end if;
    --
    if to_number(l_per_information6) < 0  or
       to_number(l_per_information6) > 99 then
      --  Error: Additional pension years (PER_INFORMATION6) not in the
      --         range 0 - 99.
      hr_utility.set_message(801, 'HR_51272_PER_INFO6_INVALID');
      hr_utility.raise_error;
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,130);
 end if;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 140);
 end if;
  --
  -- Check if p_per_information7 is in the range 1 - 11.
  --
  if p_per_information7 is not null then
    --
    l_per_information7 := p_per_information7;
    hr_chkfmt.checkformat(value   => l_per_information7
                         ,format  => 'I'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok  => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
 if g_debug then
    hr_utility.set_location(l_proc, 150);
 end if;
    --
    if to_number(l_per_information7) < 1  or
       to_number(l_per_information7) > 11 then
      --  Error: Additional pension months (PER_INFORMATION7) not in the
      --         range 1 - 11.
      hr_utility.set_message(801, 'HR_51273_PER_INFO7_INVALID');
      hr_utility.raise_error;
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,160);
 end if;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 170);
 end if;
  --
  -- Check if p_per_information8 is number.
  --
  if p_per_information8 is not null then
    --
    l_per_information8 := p_per_information8;
    hr_chkfmt.checkformat(value   => l_per_information8
                         ,format  => 'I'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok  => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
 if g_debug then
    hr_utility.set_location(l_proc,180);
 end if;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 190);
 end if;
  --
  --  Check if the per_information9 value exists in hr_lookups
  --  where the lookup_type is 'YES_NO'
  --
  if p_per_information9 is not null then
    --
    -- Check that per information9 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information9
      )
    then
      --
      hr_utility.set_message(801, 'HR_51274_PER_INFO9_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,200);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(l_proc,210);
 end if;

  -- ***** Start new code for bug 2236999 **************

  if p_per_information10 is not null then
     --
     -- Check that per information10 exists in hr_lookups for the
     -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
     -- the effective start date of the person is between start date
     -- active and end date active in hr_lookups.
     --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information10
      )
     then
     --
     hr_utility.set_message(801, 'HR_78105_PER_INFO10_INVALID');
     hr_utility.raise_error;
     --
     end if;

     --
  end if;

  --***** End new code for bug 2236999 **************
  --
  --  Check if any of the remaining per_information parameters are not
  --  null
  --  (developer descriptive flexfields not used for GB)
  --
  if p_per_information3 is not null then
    l_info_attribute := 3;
    raise l_error;

 -- ***** Start commented code for bug 2236999 **************
  /* elsif p_per_information10 is not null then
    l_info_attribute := 10;
    raise l_error;*/
 -- ***** End commented code for bug 2236999  **************

 -- ***** Start commented code for bug 5606753 **************
   /*elsif p_per_information11 is not null then
    l_info_attribute := 11;
    raise l_error; */
  -- ***** End commented code for bug 5606753  **************
  -- ***** Start commented code for bug 5917391 *************
  /*elsif p_per_information12 is not null then
    l_info_attribute := 12;
    raise l_error;
  elsif p_per_information13 is not null then
    l_info_attribute := 13;
    raise l_error;
  elsif p_per_information14 is not null then
    l_info_attribute := 14;
    raise l_error;*/
  -- ***** End commented code for bug 5917391 ************
  elsif p_per_information15 is not null then
    l_info_attribute := 15;
    raise l_error;
  elsif p_per_information16 is not null then
    l_info_attribute := 16;
    raise l_error;
  elsif p_per_information17 is not null then
    l_info_attribute := 17;
    raise l_error;
  elsif p_per_information18 is not null then
    l_info_attribute := 18;
    raise l_error;
  elsif p_per_information19 is not null then
    l_info_attribute := 19;
    raise l_error;
  elsif p_per_information20 is not null then
    l_info_attribute := 20;
    raise l_error;
  elsif p_per_information21 is not null then
    l_info_attribute := 21;
    raise l_error;
  elsif p_per_information22 is not null then
    l_info_attribute := 22;
    raise l_error;
  elsif p_per_information23 is not null then
    l_info_attribute := 23;
    raise l_error;
  elsif p_per_information24 is not null then
    l_info_attribute := 24;
    raise l_error;
-- Commenting null check for p_per_information25, p_per_information26 as
-- these are used for Employee Referral Functionality
  /*elsif p_per_information25 is not null then
    l_info_attribute := 25;
    raise l_error;
  elsif p_per_information26 is not null then
    l_info_attribute := 26;
    raise l_error;*/
-- End of Commenting for Employee Referral
  elsif p_per_information27 is not null then
    l_info_attribute := 27;
    raise l_error;
  elsif p_per_information28 is not null then
    l_info_attribute := 28;
    raise l_error;
  elsif p_per_information29 is not null then
    l_info_attribute := 29;
    raise l_error;
  elsif p_per_information30 is not null then
    l_info_attribute := 30;
    raise l_error;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 220);
 end if;
exception
    when l_error then
      --  Error: Do not enter PER_INFORMATION99 for this legislation
      hr_utility.set_message(801, 'HR_7529_PER_INFO_NOT_NULL');
      hr_utility.set_message_token('NUM',to_char(l_info_attribute));
      hr_utility.raise_error;
end chk_GB_per_information;
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_US_per_information >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - Checks that the values held in developer descriptive flexfields
--      are valid for a category of 'US'.
--    - Validates that per information6 and 9 exist as a lookup code on
--      HR_LOOKUPS for the lookup type 'YES_NO' with an enabled flag
--      set to 'Y' and the effective start date of the person between start
--      date active and end date active on HR_LOOKUPS.
--    - Validates that per information1 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'US_ETHNIC_GROUP' with an enabled flag set to 'Y'
--      and the effective start date of the person between start date active
--      and end date active on HR_LOOKUPS.
--    - Validates that per information2 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'PER_US_I9_STATE' with an enabled flag set to 'Y'
--      and the effective start date of the person between start date active
--      and end date active on HR_LOOKUPS.
--    - Validates that per information4 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'US_VISA_TYPE' with an enabled flag set to 'Y'
--      and the effective start date of the person between start date active
--      and end date active on HR_LOOKUPS.
--    - Validates that per information5 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'US_VETERAN_STATUS' with an enabled flag set to 'Y'
--      and the effective start date of the person between start date active
--      and end date active on HR_LOOKUPS.
--    - Validates that per information7 exists as a lookup code on HR_LOOKUPS
--      for the lookup type 'US_NEW_HIRE_STATUS' with an enabled flag set to 'Y'
--      and the effective start date of the person between start date active
--      and end date active on HR_LOOKUPS.
--    - Validates that when per information7 is set to 'EXCL' that per
--      information8 exists as a lookup code on HR_LOOKUPS for the lookup type
--      'US_NEW_HIRE_EXCEPTIONS' with an enabled flag set to 'Y' and the
--      effective start date of the person between start date active and end
--      date active on HR_LOOKUPS.
--    - Validates that per information10 exists as a lookup code on
--      HR_LOOKUPS for the lookup type 'YES_NO' with an enabled flag
--      set to 'Y' and the effective start date of the person between start
--      date active and end date active on HR_LOOKUPS.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_per_information_category
--    p_per_information1
--    p_per_information2
--    p_per_information3
--    p_per_information4
--    p_per_information5
--    p_per_information6
--    p_per_information7
--    p_per_information8
--    p_per_information9
--    p_per_information10
--    p_per_information11
--    p_per_information12
--    p_per_information13
--    p_per_information14
--    p_per_information15
--    p_per_information16
--    p_per_information17
--    p_per_information18
--    p_per_information19
--    p_per_information20
--    p_per_information21
--    p_per_information22
--    p_per_information23
--    p_per_information24
--    p_per_information25
--    p_per_information26
--    p_per_information27
--    p_per_information28
--    p_per_information29
--    p_per_information30
--    p_effective_date
--    p_validation_start_date
--    p_validation_end_date
--    p_object_version_number
--    p_api_updating
--
--  Post Success:
--    Processing continues if:
--      - per information6 and 9 exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y' and
--        the effective start date of the person is between start date
--        active and end date active on HR_LOOKUPS.
--      - per information1 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_ETHNIC_GROUP' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information2 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'PER_US_I9_STATE' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information3 is a valid date and 11 characters long.
--      - per information4 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_VISA_TYPE' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information5 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_VETERAN_STATUS' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information7 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_NEW_HIRE_STATUS' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - when per information7 is set to 'EXCL' and per information8 exists
--        as a lookup code in HR_LOOKUPS for the lookup type
--        'US_NEW_HIRE_EXCEPTIONS' where the enabled flag is 'Y' and the
--        effective start date of the person is between start date active
--        and end date active on HR_LOOKUPS.
--
--     9) per_information9 value exists in hr_lookups
--        where lookup_type = 'YES_NO'
--
--    10) per information10 exists as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y' and
--        the effective start date of the person is between start date
--        active and end date active on HR_LOOKUPS.
--
--    11) per_information11 to 20 values are null
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--      - per information6 and 9 does not exist as a lookup code in
--        HR_LOOKUPS for the lookup type 'YES_NO' where the
--        enabled flag is 'Y' and the effective start date of the person
--        is between start date active and end date active on HR_LOOKUPS.
--      - per information1 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_ETHNIC_GROUP' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information2 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'PER_US_I9_STATE' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information3 value is an invalid date or less than 11
--        characters long.
--      - per information4 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_VISA_TYPE' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information5 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_VETERAN_STATUS' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information7 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_NEW_HIRE_STATUS' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - per information8 doesn't exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'US_NEW_HIRE_EXCEPTION' where the enabled flag is
--        'Y' and the effective start date of the person is between start
--        date active and end date active on HR_LOOKUPS.
--      - when per information7 is set to 'EXCL' and per information8 doesn't
--        exist as a lookup code in HR_LOOKUPS for the lookup type
--        'US_NEW_HIRE_EXCEPTIONS' where the enabled flag is 'Y' and the
--        effective start date of the person is between start date active
--        and end date active on HR_LOOKUPS.
--
--     9) per_information9 value does not exists in hr_lookups
--        where lookup_type = 'YES_NO'
--
--    10) per information10 does not exist as a lookup code in HR_LOOKUPS
--        for the lookup type 'YES_NO' where the enabled flag is 'Y' and
--        the effective start date of the person is between start date
--        active and end date active on HR_LOOKUPS.
--
--    11) per_information11 to 20 values are not null
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_US_per_information
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_per_information_category in     per_all_people_f.per_information_category%TYPE
  ,p_per_information1         in     per_all_people_f.per_information1%TYPE
  ,p_per_information2         in     per_all_people_f.per_information2%TYPE
  ,p_per_information3         in     per_all_people_f.per_information3%TYPE
  ,p_per_information4         in     per_all_people_f.per_information4%TYPE
  ,p_per_information5         in     per_all_people_f.per_information5%TYPE
  ,p_per_information6         in     per_all_people_f.per_information6%TYPE
  ,p_per_information7         in     per_all_people_f.per_information7%TYPE
  ,p_per_information8         in     per_all_people_f.per_information8%TYPE
  ,p_per_information9         in     per_all_people_f.per_information9%TYPE
  ,p_per_information10        in     per_all_people_f.per_information10%TYPE
  ,p_per_information11        in     per_all_people_f.per_information11%TYPE
  ,p_per_information12        in     per_all_people_f.per_information12%TYPE
  ,p_per_information13        in     per_all_people_f.per_information13%TYPE
  ,p_per_information14        in     per_all_people_f.per_information14%TYPE
  ,p_per_information15        in     per_all_people_f.per_information15%TYPE
  ,p_per_information16        in     per_all_people_f.per_information16%TYPE
  ,p_per_information17        in     per_all_people_f.per_information17%TYPE
  ,p_per_information18        in     per_all_people_f.per_information18%TYPE
  ,p_per_information19        in     per_all_people_f.per_information19%TYPE
  ,p_per_information20        in     per_all_people_f.per_information20%TYPE
  ,p_per_information21        in     per_all_people_f.per_information21%TYPE
  ,p_per_information22        in     per_all_people_f.per_information22%TYPE
  ,p_per_information23        in     per_all_people_f.per_information23%TYPE
  ,p_per_information24        in     per_all_people_f.per_information24%TYPE
  ,p_per_information25        in     per_all_people_f.per_information25%TYPE
  ,p_per_information26        in     per_all_people_f.per_information26%TYPE
  ,p_per_information27        in     per_all_people_f.per_information27%TYPE
  ,p_per_information28        in     per_all_people_f.per_information28%TYPE
  ,p_per_information29        in     per_all_people_f.per_information29%TYPE
  ,p_per_information30        in     per_all_people_f.per_information30%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  ,p_api_updating             in     boolean
  )
is
  --
  l_exists           varchar2(1);
  l_error            exception;
  l_temp_error       exception;
  l_proc             varchar2(72)  :=  g_package||'chk_US_per_information';
  l_lookup_type      varchar2(30);
  l_info_attribute   number(2);
  l_per_information3 per_all_people_f.per_information3%TYPE;
  l_output           varchar2(150);
  l_rgeflg           varchar2(10);
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check the mandatory parameters
  --
   hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- We know the per_information_category is US, so check the rest of
  -- the per_information fields within this context.
  --
  -- Check if the value for per information1 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information1,hr_api.g_varchar2)
        <> nvl(per_per_shd.g_old_rec.per_information1,hr_api.g_varchar2)
        and p_api_updating)
      or (NOT p_api_updating))
    and p_per_information1 is not null)
  then
    --
    -- Check that per information1 exists in hr_lookups for the
    -- lookup type 'US_ETHNIC_GROUP' with an enabled flag set to 'Y'
    -- and that the effective start date of the person is between start
    -- date active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'US_ETHNIC_GROUP'
      ,p_lookup_code           => p_per_information1
      )
    then
      --
      hr_utility.set_message(801, 'HR_7524_PER_INFO1_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,30);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location( l_proc, 40);
 end if;
  --
  -- Check if the value for per information2 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information2,hr_api.g_varchar2) <>
        nvl(per_per_shd.g_old_rec.per_information2,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information2 is not null)
  then
    --
    -- Check that per information2 exists in hr_lookups for the
    -- lookup type 'PER_US_I9_STATE' with an enabled flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'PER_US_I9_STATE'
      ,p_lookup_code           => p_per_information2
      )
    then
      --
      hr_utility.set_message(801, 'HR_51243_PER_INFO2_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,50);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  -- Check if the value for per information3 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information3,hr_api.g_varchar2) <>
        nvl(per_per_shd.g_old_rec.per_information3,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information3 is not null)
  then
    --
    --  Check if the per_information3 value is an 11 character date
    --  field.
    --
    l_per_information3 := p_per_information3;
    hr_chkfmt.changeformat(input   => l_per_information3
               ,output  => l_output
                         ,format  => 'D'
                         ,curcode => NULL);
 if g_debug then
    hr_utility.set_location(l_proc, 70);
 end if;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  -- Check if the value for per information4 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information4,hr_api.g_varchar2) <>
        nvl(per_per_shd.g_old_rec.per_information4,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information4 is not null)
  then
    --
    -- Check that per information4 exists in hr_lookups for the
    -- lookup type 'US_VISA_TYPE' with an enabled flag set to 'Y'
    -- and that the effective start date of the person is between start
    -- date active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'US_VISA_TYPE'
      ,p_lookup_code           => p_per_information4
      )
    then
      --
      hr_utility.set_message(801, 'HR_51245_PER_INFO4_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,90);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  -- Check if the value for per information5 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information5,hr_api.g_varchar2) <>
        nvl(per_per_shd.g_old_rec.per_information5,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information5 is not null)
  then
    --
    -- Check that per information5 exists in hr_lookups for the
    -- lookup type 'US_VISA_TYPE' with an enabled flag set to 'Y'
    -- and that the effective start date of the person is between start
    -- date active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'US_VETERAN_STATUS'
      ,p_lookup_code           => p_per_information5
      )
    then
      --
      hr_utility.set_message(801, 'HR_51246_PER_INFO5_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,110);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location( l_proc, 120);
 end if;
  --
  -- Check if the value for per information6 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information6,hr_api.g_varchar2) <>
        nvl(per_per_shd.g_old_rec.per_information6,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information6 is not null)
  then
    --
    -- Check that per information6 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information6
      )
    then
      --
      hr_utility.set_message(801, 'HR_51247_PER_INFO6_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc, 130);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location( l_proc, 140);
 end if;
  --
  -- Check if the value for per information7 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information7,hr_api.g_varchar2) <>
        nvl(per_per_shd.g_old_rec.per_information7,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information7 is not null)
  then
    --
    -- Check that per information7 exists in hr_lookups for the
    -- lookup type 'US_NEW_HIRE_STATUS' with an enabled flag set to 'Y'
    -- and that the effective start date of the person is between start
    -- date active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'US_NEW_HIRE_STATUS'
      ,p_lookup_code           => p_per_information7
      )
    then
      --
      hr_utility.set_message(801, 'HR_51285_PER_INFO7_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,150);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location( l_proc, 160);
 end if;
  --
  -- Check if the value for per information8 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information8,hr_api.g_varchar2) <>
        nvl(per_per_shd.g_old_rec.per_information8,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information8 is not null)
  then
    --
    -- Check if per information7 is 'EXCL'
    --
    if nvl(p_per_information7,hr_api.g_varchar2) <> 'EXCL'
    then
      --
      -- Error: Field must be null because per_info7 is not 'EXCL'
      --
      hr_utility.set_message(801, 'HR_51286_PER_INFO8_NOT_NULL');
      hr_utility.raise_error;
    else
      --
      -- Check that per information7 exists in hr_lookups for the
      -- lookup type 'US_NEW_HIRE_EXCEPTIONS' with an enabled flag set to 'Y'
      -- and that the effective start date of the person is between start
      -- date active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_dt_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_validation_start_date => p_validation_start_date
        ,p_validation_end_date   => p_validation_end_date
        ,p_lookup_type           => 'US_NEW_HIRE_EXCEPTIONS'
        ,p_lookup_code           => p_per_information8
        )
      then
        --
        hr_utility.set_message(801, 'HR_51287_PER_INFO8_INVALID');
        hr_utility.raise_error;
        --
      end if;
 if g_debug then
      hr_utility.set_location( l_proc, 170);
 end if;
      --
    end if;
  end if;
 if g_debug then
  hr_utility.set_location( l_proc, 180);
 end if;
  --
  -- Check if the value for per information9 is set on insert or has
  -- changed on update.
  --
  if (((nvl(p_per_information9,hr_api.g_varchar2) <>
        nvl(per_per_shd.g_old_rec.per_information9,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information9 is not null)
  then
    --
    -- Check that per information9 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information9
      )
    then
      --
      hr_utility.set_message(801, 'HR_51288_PER_INFO9_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc, 190);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location( l_proc, 200);
 end if;
  --
  if (((nvl(p_per_information10,hr_api.g_varchar2) <>
        nvl(per_per_shd.g_old_rec.per_information10,hr_api.g_varchar2)
                     and p_api_updating) or
       (NOT p_api_updating)) and
        p_per_information10 is not null)
  then
    --
    -- Check that per information10 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information10
      )
    then
      --
      hr_utility.set_message(801, 'PER_52390_PER_INFO10_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,210);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(l_proc,220);
 end if;


  --  Check if any of the remaining per_information parameters are not
  --  null
  --  (developer descriptive flexfields not used for US)
  --

  -- TM removed check for p_per_information10 now that it is being used.
  -- Removed check for p_per_infomation11 for the bug#

  /* if p_per_information11 is not null then
    l_info_attribute := 11;
    raise l_error;*/
  -- ***** Start commented code for bug 5917391 *************
  /*if p_per_information12 is not null then
    l_info_attribute := 12;
    raise l_error;
  elsif p_per_information13 is not null then
    l_info_attribute := 13;
    raise l_error;
  elsif p_per_information14 is not null then
    l_info_attribute := 14;
    raise l_error;*/
  -- ***** End commented code for bug 5917391 *************
  if p_per_information15 is not null then
    l_info_attribute := 15;
    raise l_error;
  elsif p_per_information16 is not null then
    l_info_attribute := 16;
    raise l_error;
  elsif p_per_information17 is not null then
    l_info_attribute := 17;
    raise l_error;
  elsif p_per_information18 is not null then
    l_info_attribute := 18;
    raise l_error;
  elsif p_per_information19 is not null then
    l_info_attribute := 19;
    raise l_error;
  elsif p_per_information20 is not null then
    l_info_attribute := 20;
    raise l_error;
 -- end if;
  elsif p_per_information21 is not null then
    l_info_attribute := 21;
    raise l_error;
  elsif p_per_information22 is not null then
    l_info_attribute := 22;
    raise l_error;
  elsif p_per_information23 is not null then
    l_info_attribute := 23;
    raise l_error;
  elsif p_per_information24 is not null then
    l_info_attribute := 24;
    raise l_error;
-- Commenting null check for p_per_information25, p_per_information26 as
-- these are used for Employee Referral Functionality
--  Removed check for p_per_infomation25 for the bug# 8722991. Also reverted Employee Referral Check.
--  elsif p_per_information25 is not null then
--    l_info_attribute := 25;
--    raise l_error;
  elsif p_per_information26 is not null then
    l_info_attribute := 26;
    raise l_error;
-- End of Commenting for Employee Referral
  elsif p_per_information27 is not null then
    l_info_attribute := 27;
    raise l_error;
  elsif p_per_information28 is not null then
    l_info_attribute := 28;
    raise l_error;
  elsif p_per_information29 is not null then
    l_info_attribute := 29;
    raise l_error;
  elsif p_per_information30 is not null then
    l_info_attribute := 30;
    raise l_error;
  end if;
 if g_debug then
  hr_utility.set_location('Leaving:'|| l_proc, 230);
 end if;
exception
    when l_error then
      --  Error: Do not enter PER_INFORMATION99 for this legislation
      hr_utility.set_message(801, 'HR_7529_PER_INFO_NOT_NULL');
      hr_utility.set_message_token('NUM',to_char(l_info_attribute));
      hr_utility.raise_error;
end chk_US_per_information;
--
-- ----------------------------------------------------------------------------
-- |------------------------<chk_JP_per_information  >------------------------|
-- ----------------------------------------------------------------------------

procedure chk_JP_per_information
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_per_information_category in     per_all_people_f.per_information_category%TYPE
  ,p_per_information1         in     per_all_people_f.per_information1%TYPE
  ,p_per_information2         in     per_all_people_f.per_information2%TYPE
  ,p_per_information3         in     per_all_people_f.per_information3%TYPE
  ,p_per_information4         in     per_all_people_f.per_information4%TYPE
  ,p_per_information5         in     per_all_people_f.per_information5%TYPE
  ,p_per_information6         in     per_all_people_f.per_information6%TYPE
  ,p_per_information7         in     per_all_people_f.per_information7%TYPE
  ,p_per_information8         in     per_all_people_f.per_information8%TYPE
  ,p_per_information9         in     per_all_people_f.per_information9%TYPE
  ,p_per_information10        in     per_all_people_f.per_information10%TYPE
  ,p_per_information11        in     per_all_people_f.per_information11%TYPE
  ,p_per_information12        in     per_all_people_f.per_information12%TYPE
  ,p_per_information13        in     per_all_people_f.per_information13%TYPE
  ,p_per_information14        in     per_all_people_f.per_information14%TYPE
  ,p_per_information15        in     per_all_people_f.per_information15%TYPE
  ,p_per_information16        in     per_all_people_f.per_information16%TYPE
  ,p_per_information17        in     per_all_people_f.per_information17%TYPE
  ,p_per_information18        in     per_all_people_f.per_information18%TYPE
  ,p_per_information19        in     per_all_people_f.per_information19%TYPE
  ,p_per_information20        in     per_all_people_f.per_information20%TYPE
  ,p_per_information21        in     per_all_people_f.per_information21%TYPE
  ,p_per_information22        in     per_all_people_f.per_information22%TYPE
  ,p_per_information23        in     per_all_people_f.per_information23%TYPE
  ,p_per_information24        in     per_all_people_f.per_information24%TYPE
  ,p_per_information25        in     per_all_people_f.per_information25%TYPE
  ,p_per_information26        in     per_all_people_f.per_information26%TYPE
  ,p_per_information27        in     per_all_people_f.per_information27%TYPE
  ,p_per_information28        in     per_all_people_f.per_information28%TYPE
  ,p_per_information29        in     per_all_people_f.per_information29%TYPE
  ,p_per_information30        in     per_all_people_f.per_information30%TYPE
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  ) is

  l_error          exception;
  l_proc           varchar2(72)  :=  g_package||'chk_JP_per_information';
  l_info_attribute number(2);
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check the mandatory parameters
  --
   hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- We know the per_information_category is JP, so check the rest of
  -- the per_information fields within this context.
  --
  --  Check if the per_information1 value exists in hr_lookups
  --  where the lookup_type is 'YES_NO'
  --
  if p_per_information1 is not null then
    --
    -- Check that per information1 exists in hr_lookups for the
    -- lookup type 'YES_NO' with an enabled flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'YES_NO'
      ,p_lookup_code           => p_per_information1
      )
    then
      --
      hr_utility.set_message(801, 'HR_72022_PER_INFO1_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,30);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(l_proc,40);
 end if;
  --
  --  Check if the per_information2 value exists in hr_lookups
  --  where the lookup_type is 'JP_TERM_LOCAL_TAX_PAYMENT_TYPE'
  --
  if p_per_information2 is not null then
    --
    -- Check that per information2 exists in hr_lookups for the
    -- lookup type 'JP_TERM_LOCAL_TAX_PAYMENT_TYPE' with an enabled
    -- flag set to 'Y' and that
    -- the effective start date of the person is between start date
    -- active and end date active in hr_lookups.
    --
    if hr_api.not_exists_in_dt_hr_lookups
      (p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      ,p_lookup_type           => 'JP_TERM_LOCAL_TAX_PAYMENT_TYPE'
      ,p_lookup_code           => p_per_information2
      )
    then
      --
      hr_utility.set_message(801, 'HR_72023_PER_INFO2_INVALID');
      hr_utility.raise_error;
      --
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,50);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(l_proc,60);
 end if;
  --
  --
  --  Check if any of the remaining per_information parameters are not
  --  null
  --  (developer descriptive flexfields not used for JP)
  --

  if p_per_information3 is not null then
    l_info_attribute := 3;
    raise l_error;
  elsif p_per_information4 is not null then
    l_info_attribute := 4;
    raise l_error;
  elsif p_per_information5 is not null then
    l_info_attribute := 5;
    raise l_error;
  elsif p_per_information6 is not null then
    l_info_attribute := 6;
    raise l_error;
  elsif p_per_information7 is not null then
    l_info_attribute := 7;
    raise l_error;
  elsif p_per_information8 is not null then
    l_info_attribute := 8;
    raise l_error;
  elsif p_per_information9 is not null then
    l_info_attribute := 9;
    raise l_error;
  elsif p_per_information10 is not null then
    l_info_attribute := 10;
    raise l_error;
  elsif p_per_information11 is not null then
    l_info_attribute := 11;
    raise l_error;
  elsif p_per_information12 is not null then
    l_info_attribute := 12;
    raise l_error;
  elsif p_per_information13 is not null then
    l_info_attribute := 13;
    raise l_error;
  elsif p_per_information14 is not null then
    l_info_attribute := 14;
    raise l_error;
  elsif p_per_information15 is not null then
    l_info_attribute := 15;
    raise l_error;
  elsif p_per_information16 is not null then
    l_info_attribute := 16;
    raise l_error;
  elsif p_per_information17 is not null then
    l_info_attribute := 17;
    raise l_error;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 210);
 end if;
exception
    when l_error then
      hr_utility.set_message(801, 'HR_7529_PER_INFO_NOT_NULL');
      hr_utility.set_message_token('NUM',to_char(l_info_attribute));
      hr_utility.raise_error;
end chk_JP_per_information;
--
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< chk_ddf >---------------------------------|
-- -----------------------------------------------------------------------------
--
procedure chk_ddf
  (p_rec   in per_per_shd.g_rec_type) is
--
  l_proc       varchar2(72);
  l_error      exception;
--
Begin
 if g_debug then
  l_proc := g_package||'chk_ddf';
  hr_utility.set_location('Entering:'||l_proc, 5);
 end if;
  --
  -- Check if the row is being inserted or updated and a
  -- value has changed
  --
  if (p_rec.person_id is null)
    or ((p_rec.person_id is not null)
    and
    nvl(per_per_shd.g_old_rec.per_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.per_information_category, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information1, hr_api.g_varchar2) <>
    nvl(p_rec.per_information1, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information2, hr_api.g_varchar2) <>
    nvl(p_rec.per_information2, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information3, hr_api.g_varchar2) <>
    nvl(p_rec.per_information3, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information4, hr_api.g_varchar2) <>
    nvl(p_rec.per_information4, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information5, hr_api.g_varchar2) <>
    nvl(p_rec.per_information5, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information6, hr_api.g_varchar2) <>
    nvl(p_rec.per_information6, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information7, hr_api.g_varchar2) <>
    nvl(p_rec.per_information7, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information8, hr_api.g_varchar2) <>
    nvl(p_rec.per_information8, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information9, hr_api.g_varchar2) <>
    nvl(p_rec.per_information9, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information10, hr_api.g_varchar2) <>
    nvl(p_rec.per_information10, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information11, hr_api.g_varchar2) <>
    nvl(p_rec.per_information11, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information12, hr_api.g_varchar2) <>
    nvl(p_rec.per_information12, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information13, hr_api.g_varchar2) <>
    nvl(p_rec.per_information13, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information14, hr_api.g_varchar2) <>
    nvl(p_rec.per_information14, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information15, hr_api.g_varchar2) <>
    nvl(p_rec.per_information15, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information16, hr_api.g_varchar2) <>
    nvl(p_rec.per_information16, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information17, hr_api.g_varchar2) <>
    nvl(p_rec.per_information17, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information18, hr_api.g_varchar2) <>
    nvl(p_rec.per_information18, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information19, hr_api.g_varchar2) <>
    nvl(p_rec.per_information19, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information20, hr_api.g_varchar2) <>
    nvl(p_rec.per_information20, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information21, hr_api.g_varchar2) <>
    nvl(p_rec.per_information21, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information22, hr_api.g_varchar2) <>
    nvl(p_rec.per_information22, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information23, hr_api.g_varchar2) <>
    nvl(p_rec.per_information23, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information24, hr_api.g_varchar2) <>
    nvl(p_rec.per_information24, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information25, hr_api.g_varchar2) <>
    nvl(p_rec.per_information25, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information26, hr_api.g_varchar2) <>
    nvl(p_rec.per_information26, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information27, hr_api.g_varchar2) <>
    nvl(p_rec.per_information27, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information28, hr_api.g_varchar2) <>
    nvl(p_rec.per_information28, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information29, hr_api.g_varchar2) <>
    nvl(p_rec.per_information29, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.per_information30, hr_api.g_varchar2) <>
    nvl(p_rec.per_information30, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Person Developer DF'
      ,p_attribute_category => p_rec.per_information_category
      ,p_attribute1_name    => 'PER_INFORMATION1'
      ,p_attribute1_value   => p_rec.per_information1
      ,p_attribute2_name    => 'PER_INFORMATION2'
      ,p_attribute2_value   => p_rec.per_information2
      ,p_attribute3_name    => 'PER_INFORMATION3'
      ,p_attribute3_value   => p_rec.per_information3
      ,p_attribute4_name    => 'PER_INFORMATION4'
      ,p_attribute4_value   => p_rec.per_information4
      ,p_attribute5_name    => 'PER_INFORMATION5'
      ,p_attribute5_value   => p_rec.per_information5
      ,p_attribute6_name    => 'PER_INFORMATION6'
      ,p_attribute6_value   => p_rec.per_information6
      ,p_attribute7_name    => 'PER_INFORMATION7'
      ,p_attribute7_value   => p_rec.per_information7
      ,p_attribute8_name    => 'PER_INFORMATION8'
      ,p_attribute8_value   => p_rec.per_information8
      ,p_attribute9_name    => 'PER_INFORMATION9'
      ,p_attribute9_value   => p_rec.per_information9
      ,p_attribute10_name   => 'PER_INFORMATION10'
      ,p_attribute10_value  => p_rec.per_information10
      ,p_attribute11_name   => 'PER_INFORMATION11'
      ,p_attribute11_value  => p_rec.per_information11
      ,p_attribute12_name   => 'PER_INFORMATION12'
      ,p_attribute12_value  => p_rec.per_information12
      ,p_attribute13_name   => 'PER_INFORMATION13'
      ,p_attribute13_value  => p_rec.per_information13
      ,p_attribute14_name   => 'PER_INFORMATION14'
      ,p_attribute14_value  => p_rec.per_information14
      ,p_attribute15_name   => 'PER_INFORMATION15'
      ,p_attribute15_value  => p_rec.per_information15
      ,p_attribute16_name   => 'PER_INFORMATION16'
      ,p_attribute16_value  => p_rec.per_information16
      ,p_attribute17_name   => 'PER_INFORMATION17'
      ,p_attribute17_value  => p_rec.per_information17
      ,p_attribute18_name   => 'PER_INFORMATION18'
      ,p_attribute18_value  => p_rec.per_information18
      ,p_attribute19_name   => 'PER_INFORMATION19'
      ,p_attribute19_value  => p_rec.per_information19
      ,p_attribute20_name   => 'PER_INFORMATION20'
      ,p_attribute20_value  => p_rec.per_information20
      ,p_attribute21_name   => 'PER_INFORMATION21'
      ,p_attribute21_value  => p_rec.per_information21
      ,p_attribute22_name   => 'PER_INFORMATION22'
      ,p_attribute22_value  => p_rec.per_information22
      ,p_attribute23_name   => 'PER_INFORMATION23'
      ,p_attribute23_value  => p_rec.per_information23
      ,p_attribute24_name   => 'PER_INFORMATION24'
      ,p_attribute24_value  => p_rec.per_information24
      ,p_attribute25_name   => 'PER_INFORMATION25'
      ,p_attribute25_value  => p_rec.per_information25
      ,p_attribute26_name   => 'PER_INFORMATION26'
      ,p_attribute26_value  => p_rec.per_information26
      ,p_attribute27_name   => 'PER_INFORMATION27'
      ,p_attribute27_value  => p_rec.per_information27
      ,p_attribute28_name   => 'PER_INFORMATION28'
      ,p_attribute28_value  => p_rec.per_information28
      ,p_attribute29_name   => 'PER_INFORMATION29'
      ,p_attribute29_value  => p_rec.per_information29
      ,p_attribute30_name   => 'PER_INFORMATION30'
      ,p_attribute30_value  => p_rec.per_information30
      );
    --
  end if;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
end chk_ddf;
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_per_information >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that the values held in developer descriptive flexfields
--    are valid
--
--    This routine calls separate local validation procedures to perform
--    validation for each specific category. At present the suppported
--    categories are 'GB', 'US' and 'JP'

--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_per_information_category
--    p_per_information1
--    p_per_information2
--    p_per_information3
--    p_per_information4
--    p_per_information5
--    p_per_information6
--    p_per_information7
--    p_per_information8
--    p_per_information9
--    p_per_information10
--    p_per_information11
--    p_per_information12
--    p_per_information13
--    p_per_information14
--    p_per_information15
--    p_per_information16
--    p_per_information17
--    p_per_information18
--    p_per_information19
--    p_per_information20
--    p_per_information21
--    p_per_information22
--    p_per_information23
--    p_per_information24
--    p_per_information25
--    p_per_information26
--    p_per_information27
--    p_per_information28
--    p_per_information29
--    p_per_information30
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If the value in per_information_category value is 'GB' or 'US' then
--    processing continues
--
--  Post Failure:
--    If the value in per_information_category value is not 'GB' or 'US' then
--    an application error will be raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_per_information
  (p_rec             in out nocopy per_per_shd.g_rec_type
  ,p_effective_date           in     date
  ,p_validation_start_date    in     date
  ,p_validation_end_date      in     date) is
--
  l_exists         varchar2(1);
  l_error          exception;
  l_proc           varchar2(72)  :=  g_package||'chk_per_information';
  l_api_updating   boolean;
  l_lookup_type    varchar2(30);
  l_info_attribute number(2);
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       =>  'validation_start_date'
    ,p_argument_value =>  p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name        =>  l_proc
    ,p_argument       =>  'validation_end_date'
    ,p_argument_value =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Any of the per_information (developer descriptive flex) values have
  --     changed
  --  c) A record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_rec.person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating and nvl(per_per_shd.g_old_rec.per_information_category,
                              hr_api.g_varchar2)
    <> nvl(p_rec.per_information_category,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information1,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information1,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information2,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information2,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information3,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information3,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information4,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information4,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information5,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information5,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information6,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information6,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information7,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information7,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information8,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information8,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information9,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information9,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information10,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information10,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information11,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information11,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information12,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information12,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information13,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information13,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information14,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information14,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information15,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information15,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information16,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information16,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information17,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information17,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information18,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information18,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information19,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information19,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information20,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information20,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information21,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information21,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information22,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information22,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information23,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information23,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information24,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information24,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information25,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information25,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information26,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information26,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information27,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information27,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information28,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information28,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information29,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information29,hr_api.g_varchar2)) or
    (l_api_updating and nvl(per_per_shd.g_old_rec.per_information30,
                            hr_api.g_varchar2)
    <> nvl(p_rec.per_information30,hr_api.g_varchar2)) or
    (NOT l_api_updating))
  then
 if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
    --  Check if the per_information_category is 'GB' or 'US' calling
    --  the appropriate validation routine or generating an error
    --
--    If p_rec.per_information_category is not null then
      If p_rec.per_information_category = 'GB' then
        --
        -- GB specific validation.
        --
        per_per_bus.chk_GB_per_information
          (p_person_id                 => p_rec.person_id
          ,p_per_information_category  => p_rec.per_information_category
          ,p_per_information1          => p_rec.per_information1
          ,p_per_information2          => p_rec.per_information2
          ,p_per_information3          => p_rec.per_information3
          ,p_per_information4          => p_rec.per_information4
          ,p_per_information5          => p_rec.per_information5
          ,p_per_information6          => p_rec.per_information6
          ,p_per_information7          => p_rec.per_information7
          ,p_per_information8          => p_rec.per_information8
          ,p_per_information9          => p_rec.per_information9
          ,p_per_information10         => p_rec.per_information10
          ,p_per_information11         => p_rec.per_information11
          ,p_per_information12         => p_rec.per_information12
          ,p_per_information13         => p_rec.per_information13
          ,p_per_information14         => p_rec.per_information14
          ,p_per_information15         => p_rec.per_information15
          ,p_per_information16         => p_rec.per_information16
          ,p_per_information17         => p_rec.per_information17
          ,p_per_information18         => p_rec.per_information18
          ,p_per_information19         => p_rec.per_information19
          ,p_per_information20         => p_rec.per_information20
          ,p_per_information21         => p_rec.per_information21
          ,p_per_information22         => p_rec.per_information22
          ,p_per_information23         => p_rec.per_information23
          ,p_per_information24         => p_rec.per_information24
          ,p_per_information25         => p_rec.per_information25
          ,p_per_information26         => p_rec.per_information26
          ,p_per_information27         => p_rec.per_information27
          ,p_per_information28         => p_rec.per_information28
          ,p_per_information29         => p_rec.per_information29
          ,p_per_information30         => p_rec.per_information30
          ,p_validation_start_date     => p_validation_start_date
          ,p_validation_end_date       => p_validation_end_date
          ,p_effective_date            => p_effective_date
          ,p_object_version_number     => p_rec.object_version_number
          );
 if g_debug then
          hr_utility.set_location(l_proc, 50);
 end if;
          --
      elsif p_rec.per_information_category = 'US' then
        --
        -- US specific validation.
        --
        per_per_bus.chk_US_per_information
          (p_person_id                 => p_rec.person_id
          ,p_per_information_category  => p_rec.per_information_category
          ,p_per_information1          => p_rec.per_information1
          ,p_per_information2          => p_rec.per_information2
          ,p_per_information3          => p_rec.per_information3
          ,p_per_information4          => p_rec.per_information4
          ,p_per_information5          => p_rec.per_information5
          ,p_per_information6          => p_rec.per_information6
          ,p_per_information7          => p_rec.per_information7
          ,p_per_information8          => p_rec.per_information8
          ,p_per_information9          => p_rec.per_information9
          ,p_per_information10         => p_rec.per_information10
          ,p_per_information11         => p_rec.per_information11
          ,p_per_information12         => p_rec.per_information12
          ,p_per_information13         => p_rec.per_information13
          ,p_per_information14         => p_rec.per_information14
          ,p_per_information15         => p_rec.per_information15
          ,p_per_information16         => p_rec.per_information16
          ,p_per_information17         => p_rec.per_information17
          ,p_per_information18         => p_rec.per_information18
          ,p_per_information19         => p_rec.per_information19
          ,p_per_information20         => p_rec.per_information20
          ,p_per_information21         => p_rec.per_information21
          ,p_per_information22         => p_rec.per_information22
          ,p_per_information23         => p_rec.per_information23
          ,p_per_information24         => p_rec.per_information24
          ,p_per_information25         => p_rec.per_information25
          ,p_per_information26         => p_rec.per_information26
          ,p_per_information27         => p_rec.per_information27
          ,p_per_information28         => p_rec.per_information28
          ,p_per_information29         => p_rec.per_information29
          ,p_per_information30         => p_rec.per_information30
          ,p_effective_date            => p_effective_date
          ,p_validation_start_date     => p_validation_start_date
          ,p_validation_end_date       => p_validation_end_date
          ,p_object_version_number     => p_rec.object_version_number
          ,p_api_updating              => l_api_updating
          );
 if g_debug then
          hr_utility.set_location(l_proc, 60);
 end if;
          --
/*      elsif p_rec.per_information_category = 'JP' then
        --
        -- JP specific validation
        --
        per_per_bus.chk_JP_per_information
          (p_person_id                 => p_rec.person_id
          ,p_per_information_category  => p_rec.per_information_category
          ,p_per_information1          => p_rec.per_information1
          ,p_per_information2          => p_rec.per_information2
          ,p_per_information3          => p_rec.per_information3
          ,p_per_information4          => p_rec.per_information4
          ,p_per_information5          => p_rec.per_information5
          ,p_per_information6          => p_rec.per_information6
          ,p_per_information7          => p_rec.per_information7
          ,p_per_information8          => p_rec.per_information8
          ,p_per_information9          => p_rec.per_information9
          ,p_per_information10         => p_rec.per_information10
          ,p_per_information11         => p_rec.per_information11
          ,p_per_information12         => p_rec.per_information12
          ,p_per_information13         => p_rec.per_information13
          ,p_per_information14         => p_rec.per_information14
          ,p_per_information15         => p_rec.per_information15
          ,p_per_information16         => p_rec.per_information16
          ,p_per_information17         => p_rec.per_information17
          ,p_per_information18         => p_rec.per_information18
          ,p_per_information19         => p_rec.per_information19
          ,p_per_information20         => p_rec.per_information20
          ,p_per_information21         => p_rec.per_information21
          ,p_per_information22         => p_rec.per_information22
          ,p_per_information23         => p_rec.per_information23
          ,p_per_information24         => p_rec.per_information24
          ,p_per_information25         => p_rec.per_information25
          ,p_per_information26         => p_rec.per_information26
          ,p_per_information27         => p_rec.per_information27
          ,p_per_information28         => p_rec.per_information28
          ,p_per_information29         => p_rec.per_information29
          ,p_per_information30         => p_rec.per_information30
          ,p_validation_start_date     => p_validation_start_date
          ,p_validation_end_date       => p_validation_end_date
          ,p_effective_date            => p_effective_date
          ,p_object_version_number     => p_rec.object_version_number
          );
 if g_debug then
          hr_utility.set_location(l_proc, 70);
 end if;
          -- */
      else
           per_per_bus.chk_ddf(p_rec => p_rec);
      end if;
--    end if;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 100);
 end if;
exception
    when l_error then
      --  Error: Do not enter PER_INFORMATION99 for this legislation
      hr_utility.set_message(801, 'HR_7529_PER_INFO_NOT_NULL');
      hr_utility.set_message_token('NUM',to_char(l_info_attribute));
      hr_multi_message.add;
   -- hr_utility.raise_error;
end chk_per_information;
--
/* Bug#3613987 - Removed chk_JP_names procedure
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_JP_names  >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that a name values are kana
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_effective_date
--    p_object_version_number
--    p_first_name
--    p_last_name
--    p_per_information18
--    p_per_information19
--
--  Out Arguments
--    p_full_name
--
--  Post Success:
--    If a name contains only single byte characters then process continues.
--    It returns value to p_full_name calling return_JP_fullname
--
--  Post Failure:
--    If a name contains any double byte characters then process is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_JP_names
  (p_person_id                in  per_all_people_f.person_id%TYPE
  ,p_effective_date           in  date
  ,p_object_version_number    in  per_all_people_f.object_version_number%TYPE
  ,p_first_name               in  per_all_people_f.first_name%TYPE
  ,p_last_name                in  per_all_people_f.last_name%TYPE
  ,p_per_information18        in  per_all_people_f.per_information18%TYPE
  ,p_per_information19        in  per_all_people_f.per_information19%TYPE) is
  --,p_full_name                out nocopy per_all_people_f.full_name%TYPE) is -- bug# 2689366
  --
  l_last_name     per_all_people_f.last_name%TYPE;
  l_first_name    per_all_people_f.first_name%TYPE;
  l_proc                varchar2(72) ;
  l_api_updating     boolean;
  l_output        varchar2(150);
  l_rgeflg     varchar2(10);
  --
begin
 if g_debug then
  l_proc :=  g_package||'chk_JP_names';
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  if hr_multi_message.no_exclusive_error
    (p_check_column1      => 'PER_ALL_PEOPLE_F.LAST_NAME'
    )
  then
    l_api_updating := per_per_shd.api_updating
      (p_person_id             => p_person_id
      ,p_effective_date        => p_effective_date
      ,p_object_version_number => p_object_version_number);
    --
    --  Only proceed with validation if:
    --  a) The current g_old_rec is current and
    --  b) The start date value has changed
    --  c) a record is being inserted
    --
    --
 if g_debug then
      hr_utility.set_location(l_proc, 2);
 end if;
    --
    if ((l_api_updating
         and nvl(per_per_shd.g_old_rec.last_name, hr_api.g_varchar2)
         <> nvl(p_last_name,hr_api.g_varchar2))
       or
         (NOT l_api_updating)) then
      --
      --  Perform Insert/Update checks
      --
      l_last_name := p_last_name;
      hr_chkfmt.checkformat(value   => l_last_name
            ,format  => 'KANA'
            ,output  => l_output
            ,minimum => NULL
            ,maximum => NULL
            ,nullok  => 'N'
            ,rgeflg  => l_rgeflg
            ,curcode => NULL);
    end if;
    --
 if g_debug then
      hr_utility.set_location(l_proc, 3);
 end if;
    --
    if ((l_api_updating
         and nvl(per_per_shd.g_old_rec.first_name, hr_api.g_varchar2)
         <> nvl(p_first_name,hr_api.g_varchar2))
       or
         (NOT l_api_updating)) then
      --
      --  Perform Insert/Update checks
      --
      l_first_name := p_first_name;
      hr_chkfmt.checkformat(value   => l_first_name
                           ,format  => 'KANA'
                           ,output  => l_output
                           ,minimum => NULL
                           ,maximum => NULL
                           ,nullok  => 'Y'
                           ,rgeflg  => l_rgeflg
                           ,curcode => NULL);
    end if;
  end if;
    --
 if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 5);
 end if;
  exception
     when app_exception.application_exception then
      if hr_multi_message.exception_add
             (p_associated_column1      => 'PER_ALL_PEOPLE_F.LAST_NAME'
            ,p_associated_column2      => 'PER_ALL_PEOPLE_F.FIRST_NAME'
            ) then
 if g_debug then
         hr_utility.set_location(' Leaving:'||l_proc, 6);
 end if;
         raise;
       end if;
 if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc,7);
 end if;
end chk_JP_names;
*/
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  return_full_name  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Calls process hr_person.derive_full_name which constructs the full name
--
--  Pre-conditions:
--    The value of p_title and p_date_of_birth must be valid
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_first_name
--    p_middle_names
--    p_last_name
--    p_known_as
--    p_title
--    p_date_of_birth
--    p_full_name
--    p_suffix
--    p_effective_date
--    p_object_version_number
--    p_pre_name_adjunct
--
--  Out Arguments
--    p_full_name
--    p_name_combination_warning
--
--  Post Success:
--    The full name is set to the concatenated string  and processing continues
--
--    If the combination of full name and date of birth already exists then
--    a warning is flagged and processing continues
--
--  Post Failure:
--    None
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- For bug # 486308, added p_suffix.
--
-- For bug # 2689366, added p_per_information18 and p_per_information19
--
procedure return_full_name
   (p_person_id                in  per_all_people_f.person_id%TYPE
   ,p_business_group_id        in  per_all_people_f.business_group_id%type
   ,p_first_name               in  per_all_people_f.first_name%TYPE
   ,p_middle_names             in  per_all_people_f.middle_names%TYPE
   ,p_last_name                in  per_all_people_f.last_name%TYPE
   ,p_known_as                 in  per_all_people_f.known_as%TYPE
   ,p_title                    in  per_all_people_f.title%TYPE
   ,p_date_of_birth            in  per_all_people_f.date_of_birth%TYPE
   ,p_suffix                   in  per_all_people_f.suffix%TYPE
   ,p_pre_name_adjunct         in  per_all_people_f.pre_name_adjunct%TYPE
   ,p_effective_date           in  date
   ,p_object_version_number    in  per_all_people_f.object_version_number%TYPE
   ,p_previous_last_name per_all_people_f.previous_last_name%TYPE DEFAULT NULL
   ,p_email_address      per_all_people_f.email_address%TYPE DEFAULT NULL
   ,p_employee_number    per_all_people_f.employee_number%TYPE DEFAULT NULL
   ,p_applicant_number   per_all_people_f.applicant_number%TYPE DEFAULT NULL
   ,p_npw_number         per_all_people_f.npw_number%TYPE DEFAULT NULL
   ,p_per_information1   per_all_people_f.per_information1%TYPE DEFAULT NULL
   ,p_per_information2   per_all_people_f.per_information2%TYPE DEFAULT NULL
   ,p_per_information3   per_all_people_f.per_information3%TYPE DEFAULT NULL
   ,p_per_information4   per_all_people_f.per_information4%TYPE DEFAULT NULL
   ,p_per_information5   per_all_people_f.per_information5%TYPE DEFAULT NULL
   ,p_per_information6   per_all_people_f.per_information6%TYPE DEFAULT NULL
   ,p_per_information7   per_all_people_f.per_information7%TYPE DEFAULT NULL
   ,p_per_information8   per_all_people_f.per_information8%TYPE DEFAULT NULL
   ,p_per_information9   per_all_people_f.per_information9%TYPE DEFAULT NULL
   ,p_per_information10  per_all_people_f.per_information10%TYPE DEFAULT NULL
   ,p_per_information11  per_all_people_f.per_information11%TYPE DEFAULT NULL
   ,p_per_information12  per_all_people_f.per_information12%TYPE DEFAULT NULL
   ,p_per_information13  per_all_people_f.per_information13%TYPE DEFAULT NULL
   ,p_per_information14  per_all_people_f.per_information14%TYPE DEFAULT NULL
   ,p_per_information15  per_all_people_f.per_information15%TYPE DEFAULT NULL
   ,p_per_information16  per_all_people_f.per_information16%TYPE DEFAULT NULL
   ,p_per_information17  per_all_people_f.per_information17%TYPE DEFAULT NULL
   ,p_per_information18  per_all_people_f.per_information18%TYPE DEFAULT NULL
   ,p_per_information19  per_all_people_f.per_information19%TYPE DEFAULT NULL
   ,p_per_information20  per_all_people_f.per_information20%TYPE DEFAULT NULL
   ,p_per_information21  per_all_people_f.per_information21%TYPE DEFAULT NULL
   ,p_per_information22  per_all_people_f.per_information22%TYPE DEFAULT NULL
   ,p_per_information23  per_all_people_f.per_information23%TYPE DEFAULT NULL
   ,p_per_information24  per_all_people_f.per_information24%TYPE DEFAULT NULL
   ,p_per_information25  per_all_people_f.per_information25%TYPE DEFAULT NULL
   ,p_per_information26  per_all_people_f.per_information26%TYPE DEFAULT NULL
   ,p_per_information27  per_all_people_f.per_information27%TYPE DEFAULT NULL
   ,p_per_information28  per_all_people_f.per_information28%TYPE DEFAULT NULL
   ,p_per_information29  per_all_people_f.per_information29%TYPE DEFAULT NULL
   ,p_per_information30  per_all_people_f.per_information30%TYPE DEFAULT NULL
   ,p_attribute1         per_all_people_f.attribute1%TYPE DEFAULT NULL
   ,p_attribute2         per_all_people_f.attribute2%TYPE DEFAULT NULL
   ,p_attribute3         per_all_people_f.attribute3%TYPE DEFAULT NULL
   ,p_attribute4         per_all_people_f.attribute4%TYPE DEFAULT NULL
   ,p_attribute5         per_all_people_f.attribute5%TYPE DEFAULT NULL
   ,p_attribute6         per_all_people_f.attribute6%TYPE DEFAULT NULL
   ,p_attribute7         per_all_people_f.attribute7%TYPE DEFAULT NULL
   ,p_attribute8         per_all_people_f.attribute8%TYPE DEFAULT NULL
   ,p_attribute9         per_all_people_f.attribute9%TYPE DEFAULT NULL
   ,p_attribute10        per_all_people_f.attribute10%TYPE DEFAULT NULL
   ,p_attribute11        per_all_people_f.attribute11%TYPE DEFAULT NULL
   ,p_attribute12        per_all_people_f.attribute12%TYPE DEFAULT NULL
   ,p_attribute13        per_all_people_f.attribute13%TYPE DEFAULT NULL
   ,p_attribute14        per_all_people_f.attribute14%TYPE DEFAULT NULL
   ,p_attribute15        per_all_people_f.attribute15%TYPE DEFAULT NULL
   ,p_attribute16        per_all_people_f.attribute16%TYPE DEFAULT NULL
   ,p_attribute17        per_all_people_f.attribute17%TYPE DEFAULT NULL
   ,p_attribute18        per_all_people_f.attribute18%TYPE DEFAULT NULL
   ,p_attribute19        per_all_people_f.attribute19%TYPE DEFAULT NULL
   ,p_attribute20        per_all_people_f.attribute20%TYPE DEFAULT NULL
   ,p_attribute21        per_all_people_f.attribute21%TYPE DEFAULT NULL
   ,p_attribute22        per_all_people_f.attribute22%TYPE DEFAULT NULL
   ,p_attribute23        per_all_people_f.attribute23%TYPE DEFAULT NULL
   ,p_attribute24        per_all_people_f.attribute24%TYPE DEFAULT NULL
   ,p_attribute25        per_all_people_f.attribute25%TYPE DEFAULT NULL
   ,p_attribute26        per_all_people_f.attribute26%TYPE DEFAULT NULL
   ,p_attribute27        per_all_people_f.attribute27%TYPE DEFAULT NULL
   ,p_attribute28        per_all_people_f.attribute28%TYPE DEFAULT NULL
   ,p_attribute29        per_all_people_f.attribute29%TYPE DEFAULT NULL
   ,p_attribute30        per_all_people_f.attribute30%TYPE DEFAULT NULL
   ,p_full_name          OUT NOCOPY per_all_people_f.full_name%TYPE
   ,p_order_name         OUT NOCOPY per_all_people_f.order_name%TYPE
   ,p_global_name        OUT NOCOPY per_all_people_f.global_name%TYPE
   ,p_local_name         OUT NOCOPY per_all_people_f.local_name%TYPE
   ,p_duplicate_flag     OUT NOCOPY VARCHAR2
   ,p_name_combination_warning out nocopy boolean) is
--
  l_exists            varchar2(1);
  l_proc              varchar2(72)  :=  g_package||'return_full_name';
  l_api_updating              boolean;
  l_duplicate_flag            varchar2(1);
  l_full_name                 varchar2(240);
  l_order_name                varchar2(240);
  l_global_name               varchar2(240);
  l_local_name                varchar2(240);
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'business group id'
      ,p_argument_value => p_business_group_id
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective date'
      ,p_argument_value => p_effective_date
      );
    --
    -- Check if the last name is set.
    --
    if p_last_name is null then
      --
      hr_utility.set_message(801, 'PER_52076_PER_NULL_LAST_NAME');
      hr_utility.raise_error;
      --
    end if;
    --
  if hr_multi_message.no_all_inclusive_error
               (p_check_column1      => 'PER_ALL_PEOPLE_F.TITLE'
               ,p_check_column2      => 'PER_ALL_PEOPLE_F.DATE_OF_BIRTH'
               )
  then
    p_name_combination_warning := false;
    --
    --  Only proceed with validation if:
    --  a) The current g_old_rec is current and
    --  b) last name has changed
    --  c) title has changed
    --  d) first name has changed
    --  d) middle names have changed
    --  e) known as values has changed
    --  f) date of birth has changed
    --  g) A record is being inserted
    --
    l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);
    --
    if ((l_api_updating and nvl(per_per_shd.g_old_rec.last_name,
                                hr_api.g_varchar2)
      <> nvl(p_last_name,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.title,
                                hr_api.g_varchar2)
      <> nvl(p_title,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.first_name,
                                hr_api.g_varchar2)
      <> nvl(p_first_name,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.middle_names,
                                hr_api.g_varchar2)
      <> nvl(p_middle_names,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.suffix,
                                hr_api.g_varchar2)
      <> nvl(p_suffix,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.known_as,
                                hr_api.g_varchar2)
      <> nvl(p_known_as,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.date_of_birth,
                                hr_api.g_date)
      <> nvl(p_date_of_birth,hr_api.g_date)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.pre_name_adjunct,
                                hr_api.g_varchar2)
      <> nvl(p_pre_name_adjunct,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.employee_number,
                                hr_api.g_varchar2)
      <> nvl(p_employee_number,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.applicant_number,
                                hr_api.g_varchar2)
      <> nvl(p_applicant_number,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.npw_number,
                                hr_api.g_varchar2)
      <> nvl(p_npw_number,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.email_address,
                                hr_api.g_varchar2)
      <> nvl(p_email_address,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information1,
                                hr_api.g_varchar2)
      <> nvl(p_per_information1,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information2,
                                hr_api.g_varchar2)
      <> nvl(p_per_information2,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information3,
                                hr_api.g_varchar2)
      <> nvl(p_per_information3,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information4,
                                hr_api.g_varchar2)
      <> nvl(p_per_information4,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information5,
                                hr_api.g_varchar2)
      <> nvl(p_per_information5,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information6,
                                hr_api.g_varchar2)
      <> nvl(p_per_information6,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information7,
                                hr_api.g_varchar2)
      <> nvl(p_per_information7,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information8,
                                hr_api.g_varchar2)
      <> nvl(p_per_information8,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information9,
                                hr_api.g_varchar2)
      <> nvl(p_per_information9,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information10,
                                hr_api.g_varchar2)
      <> nvl(p_per_information10,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information11,
                                hr_api.g_varchar2)
      <> nvl(p_per_information11,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information12,
                                hr_api.g_varchar2)
      <> nvl(p_per_information12,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information13,
                                hr_api.g_varchar2)
      <> nvl(p_per_information13,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information14,
                                hr_api.g_varchar2)
      <> nvl(p_per_information14,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information15,
                                hr_api.g_varchar2)
      <> nvl(p_per_information15,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information16,
                                hr_api.g_varchar2)
      <> nvl(p_per_information16,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information17,
                                hr_api.g_varchar2)
      <> nvl(p_per_information17,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information18,
                                hr_api.g_varchar2)
      <> nvl(p_per_information18,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information19,
                                hr_api.g_varchar2)
      <> nvl(p_per_information19,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information20,
                                hr_api.g_varchar2)
      <> nvl(p_per_information20,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information21,
                                hr_api.g_varchar2)
      <> nvl(p_per_information21,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information22,
                                hr_api.g_varchar2)
      <> nvl(p_per_information22,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information23,
                                hr_api.g_varchar2)
      <> nvl(p_per_information23,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information24,
                                hr_api.g_varchar2)
      <> nvl(p_per_information24,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information25,
                                hr_api.g_varchar2)
      <> nvl(p_per_information25,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information26,
                                hr_api.g_varchar2)
      <> nvl(p_per_information26,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information27,
                                hr_api.g_varchar2)
      <> nvl(p_per_information27,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information28,
                                hr_api.g_varchar2)
      <> nvl(p_per_information28,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information29,
                                hr_api.g_varchar2)
      <> nvl(p_per_information29,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.per_information30,
                                hr_api.g_varchar2)
      <> nvl(p_per_information30,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute1,
                                hr_api.g_varchar2)
      <> nvl(p_attribute1,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute2,
                                hr_api.g_varchar2)
      <> nvl(p_attribute2,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute3,
                                hr_api.g_varchar2)
      <> nvl(p_attribute3,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute4,
                                hr_api.g_varchar2)
      <> nvl(p_attribute4,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute5,
                                hr_api.g_varchar2)
      <> nvl(p_attribute5,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute6,
                                hr_api.g_varchar2)
      <> nvl(p_attribute6,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute7,
                                hr_api.g_varchar2)
      <> nvl(p_attribute7,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute8,
                                hr_api.g_varchar2)
      <> nvl(p_attribute8,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute9,
                                hr_api.g_varchar2)
      <> nvl(p_attribute9,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute10,
                                hr_api.g_varchar2)
      <> nvl(p_attribute10,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute11,
                                hr_api.g_varchar2)
      <> nvl(p_attribute11,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute12,
                                hr_api.g_varchar2)
      <> nvl(p_attribute12,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute13,
                                hr_api.g_varchar2)
      <> nvl(p_attribute13,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute14,
                                hr_api.g_varchar2)
      <> nvl(p_attribute14,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute15,
                                hr_api.g_varchar2)
      <> nvl(p_attribute15,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute16,
                                hr_api.g_varchar2)
      <> nvl(p_attribute16,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute17,
                                hr_api.g_varchar2)
      <> nvl(p_attribute17,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute18,
                                hr_api.g_varchar2)
      <> nvl(p_attribute18,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute19,
                                hr_api.g_varchar2)
      <> nvl(p_attribute19,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute20,
                                hr_api.g_varchar2)
      <> nvl(p_attribute20,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute21,
                                hr_api.g_varchar2)
      <> nvl(p_attribute21,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute22,
                                hr_api.g_varchar2)
      <> nvl(p_attribute22,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute23,
                                hr_api.g_varchar2)
      <> nvl(p_attribute23,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute24,
                                hr_api.g_varchar2)
      <> nvl(p_attribute24,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute25,
                                hr_api.g_varchar2)
      <> nvl(p_attribute25,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute26,
                                hr_api.g_varchar2)
      <> nvl(p_attribute26,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute27,
                                hr_api.g_varchar2)
      <> nvl(p_attribute27,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute28,
                                hr_api.g_varchar2)
      <> nvl(p_attribute28,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute29,
                                hr_api.g_varchar2)
      <> nvl(p_attribute29,hr_api.g_varchar2)) or
      (l_api_updating and nvl(per_per_shd.g_old_rec.attribute30,
                                hr_api.g_varchar2)
      <> nvl(p_attribute30,hr_api.g_varchar2)) or
      (NOT l_api_updating)) then
      --
      if g_debug then
         hr_utility.set_location(l_proc, 20);
      end if;
      --
      l_duplicate_flag := 'N';
      --
      --  Call process to contruct full name
      --
      hr_person_name.derive_person_names
      (p_format_name        =>  NULL,    -- derice all names
       p_business_group_id  =>  p_business_group_id,
       p_person_id          =>  p_person_id,
       p_first_name         =>  p_first_name,
       p_middle_names       =>  p_middle_names,
       p_last_name          =>  p_last_name,
       p_known_as           =>  p_known_as,
       p_title              =>  p_title,
       p_suffix             =>  p_suffix,
       p_pre_name_adjunct   =>  p_pre_name_adjunct,
       p_date_of_birth      =>  p_date_of_birth,
       p_previous_last_name =>  p_previous_last_name  ,
       p_email_address      =>  p_email_address  ,
       p_employee_number    =>  p_employee_number  ,
       p_applicant_number   =>  p_applicant_number  ,
       p_npw_number         =>  p_npw_number  ,
       p_per_information1   =>  p_per_information1  ,
       p_per_information2   =>  p_per_information2  ,
       p_per_information3   =>  p_per_information3  ,
       p_per_information4   =>  p_per_information4  ,
       p_per_information5   =>  p_per_information5  ,
       p_per_information6   =>  p_per_information6  ,
       p_per_information7   =>  p_per_information7  ,
       p_per_information8   =>  p_per_information8  ,
       p_per_information9   =>  p_per_information9  ,
       p_per_information10  =>  p_per_information10  ,
       p_per_information11  =>  p_per_information11  ,
       p_per_information12  =>  p_per_information12  ,
       p_per_information13  =>  p_per_information13  ,
       p_per_information14  =>  p_per_information14  ,
       p_per_information15  =>  p_per_information15  ,
       p_per_information16  =>  p_per_information16  ,
       p_per_information17  =>  p_per_information17  ,
       p_per_information18  =>  p_per_information18  ,
       p_per_information19  =>  p_per_information19  ,
       p_per_information20  =>  p_per_information20  ,
       p_per_information21  =>  p_per_information21  ,
       p_per_information22  =>  p_per_information22  ,
       p_per_information23  =>  p_per_information23  ,
       p_per_information24  =>  p_per_information24  ,
       p_per_information25  =>  p_per_information25  ,
       p_per_information26  =>  p_per_information26  ,
       p_per_information27  =>  p_per_information27  ,
       p_per_information28  =>  p_per_information28  ,
       p_per_information29  =>  p_per_information29  ,
       p_per_information30  =>  p_per_information30  ,
       p_attribute1         =>  p_attribute1  ,
       p_attribute2         =>  p_attribute2  ,
       p_attribute3         =>  p_attribute3  ,
       p_attribute4         =>  p_attribute4  ,
       p_attribute5         =>  p_attribute5  ,
       p_attribute6         =>  p_attribute6  ,
       p_attribute7         =>  p_attribute7  ,
       p_attribute8         =>  p_attribute8  ,
       p_attribute9         =>  p_attribute9  ,
       p_attribute10        =>  p_attribute10  ,
       p_attribute11        =>  p_attribute11  ,
       p_attribute12        =>  p_attribute12  ,
       p_attribute13        =>  p_attribute13  ,
       p_attribute14        =>  p_attribute14  ,
       p_attribute15        =>  p_attribute15  ,
       p_attribute16        =>  p_attribute16  ,
       p_attribute17        =>  p_attribute17  ,
       p_attribute18        =>  p_attribute18  ,
       p_attribute19        =>  p_attribute19  ,
       p_attribute20        =>  p_attribute20  ,
       p_attribute21        =>  p_attribute21  ,
       p_attribute22        =>  p_attribute22  ,
       p_attribute23        =>  p_attribute23,
       p_attribute24        =>  p_attribute24,
       p_attribute25        =>  p_attribute25,
       p_attribute26        =>  p_attribute26,
       p_attribute27        =>  p_attribute27,
       p_attribute28        =>  p_attribute28,
       p_attribute29        =>  p_attribute29,
       p_attribute30        =>  p_attribute30,
       p_full_name          => l_full_name,
       p_order_name         => l_order_name,
       p_global_name        => l_global_name,
       p_local_name         => l_local_name,
       p_duplicate_flag     => l_duplicate_flag
       );

      --hr_person.derive_full_name(p_first_name         =>  p_first_name
      --                          ,p_middle_names       =>  p_middle_names
      --                          ,p_last_name          =>  p_last_name
      --                          ,p_known_as           =>  p_known_as
      --                          ,p_title              =>  p_title
      --                          ,p_suffix             =>  p_suffix
      --                          ,p_pre_name_adjunct   =>  p_pre_name_adjunct
      --                          ,p_date_of_birth      =>  p_date_of_birth
      --                          ,p_person_id          =>  p_person_id
      --                          ,p_business_group_id  =>  p_business_group_id
      --                          ,p_full_name          =>  l_full_name
      --                          ,p_duplicate_flag     =>  l_duplicate_flag
      --                          ,p_per_information18  =>  p_per_information18
      --                          ,p_per_information19  =>  p_per_information19
      --                          );
      --
      p_full_name   := l_full_name;
      p_order_name  := l_order_name;
      p_global_name := l_global_name;
      p_local_name  := l_local_name;
      --
      if l_duplicate_flag = 'Y' then
        p_name_combination_warning := TRUE;
        if g_debug then
             hr_utility.set_location(l_proc,25);
        end if;
      end if;
      --
      if g_debug then
         hr_utility.set_location(l_proc, 30);
      end if;
    else
      --
      -- We are not updating the name so we must return the current full_name
      --
      p_full_name   := per_per_shd.g_old_rec.full_name;
      p_order_name  := per_per_shd.g_old_rec.order_name;
      p_global_name := per_per_shd.g_old_rec.global_name;
      p_local_name  := per_per_shd.g_old_rec.local_name;
    end if;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.LAST_NAME'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
        raise;
      end if;
 if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc,60);
 end if;
end return_full_name;
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_applicant_number  >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that applicant number is valid on insert and delete based on
--    applicant number generation method.
--
--    Some specific tests are performed in this procedure and then if all
--    is still okay the hr_person.generate_number routine is called to
--    finish of the validation/generation process.
--
--  Pre-conditions:
--    Valid person_id
--    Valid current_applicant_flag
--    Valid current_employee_flag
--    Valid business_group_id
--    Valid person_type_id
--
--  In Arguments:
--    p_person_id
--    p_applicant_number
--    p_business_group_id
--    p_current_applicant
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--
--  If the following conditions apply then an applicant_number is generated
--  and processing continues :
--
--   a) Applicant number must be not null if system person type is 'APL',
--      'APL_EX_APL','EMP_APL','EX_EMP_APL'.
--
--   b) Applicant number must not be modified to null if the system person
--      type is 'EMP' or 'EX_EMP' and the applicant number is not null
--
--   c) Applicant number must be null if the system person type is 'EMP' and
--      no previous changes to system person type exist
--
--   d) Applicant number must be null if the system person type is 'OTHER'
--
--   e) Applicant number is mandatory in Manual generation mode
--
--   f) Number generation mode of associated business group id can only
--      be 'A' or 'M'
--
--   g) Applicant number can only be updated in generation mode 'M'
--
--   h) Applicant number must be unique within the business group
--
--  Post Failure:
--
--  If the following conditions apply then processing fails :
--
--   a) Applicant number is not null, system person type is 'OTHER'
--
--   b) Applicant number has changed from not null to null and the system
--      person type is 'EMP' or 'EX_EMP'
--
--   c) Applicant number updated when generation mode is 'A'
--
--   d) Applicant number is not null, system person type is 'EMP' and
--      no historic changes in system person type exist for this person.
--      i.e they are 'EMP' now and have always been an 'EMP'.
--
--   e) Applicant number is null when generation mode is 'M'
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_applicant_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_applicant_number         in out nocopy per_all_people_f.applicant_number%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_current_applicant        in     per_all_people_f.current_applicant_flag%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
  is
begin
   chk_applicant_number
  (p_person_id              => p_person_id
  ,p_applicant_number       => p_applicant_number
  ,p_business_group_id      => p_business_group_id
  ,p_current_applicant      => p_current_applicant
  ,p_person_type_id         => p_person_type_id
  ,p_effective_date         => p_effective_date
  ,p_object_version_number  => p_object_version_number
  ,p_party_id               => null
  ,p_date_of_birth          => null
  ,p_start_date             => null
  );
end chk_applicant_number;
--
--
procedure chk_applicant_number
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_applicant_number         in out nocopy per_all_people_f.applicant_number%TYPE
  ,p_business_group_id        in     per_all_people_f.business_group_id%TYPE
  ,p_current_applicant        in     per_all_people_f.current_applicant_flag%TYPE
  ,p_person_type_id           in     per_all_people_f.person_type_id%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  ,p_party_id                 in     per_all_people_f.party_id%TYPE
  ,p_date_of_birth            in     per_all_people_f.date_of_birth%TYPE
  ,p_start_date               in     date
  )
  is
--
  l_proc               varchar2(72)  :=  g_package||'chk_applicant_number';
  l_api_updating       boolean;
  l_gen_method         per_business_groups.method_of_generation_emp_num%TYPE;
  l_system_person_type per_person_types.system_person_type%TYPE;
  l_employee_number    per_all_people_f.employee_number%TYPE;
  l_npw_number         per_all_people_f.npw_number%TYPE;
  l_apl_sys                  boolean := false;
--
-- Cursor to get number generation method for Bus Group
--
  cursor csr_gen_meth is
    select pbg.method_of_generation_apl_num
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
--
--
-- Declare the function apl_sys_per_type_change
--
  function apl_sys_per_type_change
               (p_new_person_type_id      numeric
               ,p_old_person_type_id      numeric
               ,p_business_group_id       numeric)
  return boolean is
  --
  l_new_system_person_type   per_person_types.system_person_type%TYPE;
  l_old_system_person_type   per_person_types.system_person_type%TYPE;
  l_return_status            boolean;
  l_proc                     varchar2(25) := 'apl_sys_per_type_change';
  --
  -- Cursor to get the system_person_type for the 'old' person_type_id
  --
  cursor get_old_sys_per_type is
         select system_person_type
         from   per_person_types
         where  person_type_id    = p_old_person_type_id
         and    business_group_id = p_business_group_id;
  --
  begin
    --
 if g_debug then
    hr_utility.set_location('Entering '||l_proc,10);
 end if;
    --
    -- Assume we have not changed the system_person_type, so set return
    -- variable to FALSE.
    --
    l_return_status := false;
    --
    -- Check the person_type_id has actually changed
    --
    if p_new_person_type_id <> p_old_person_type_id then
      --
 if g_debug then
      hr_utility.set_location(l_proc, 20);
 end if;
      --
      -- Get the system_person_type for the 'new' person_type_id
      --
      l_new_system_person_type := return_system_person_type
                                 (p_person_type_Id    =>p_new_person_type_id
                                 ,p_business_group_id =>p_business_group_id
                                 );
 if g_debug then
      hr_utility.set_location(l_proc, 30);
 end if;
      --
      -- Get the system_person_type for the 'old' person_type_id
      --
      open get_old_sys_per_type;
      fetch get_old_sys_per_type into l_old_system_person_type;
      close get_old_sys_per_type;
      --
      -- If the system_person_type's have changed then check the transition
      -- to see if the applicant number needs to be validated/generated
      --
      if ((l_old_system_person_type = 'OTHER' and
           l_new_system_person_type = 'APL')
          or
          (l_old_system_person_type = 'EMP' and
           l_new_system_person_type = 'EMP_APL')
          or
          (l_old_system_person_type = 'EX_EMP' and
           l_new_system_person_type = 'EX_EMP_APL')) then
        --
 if g_debug then
        hr_utility.set_location(l_proc, 40);
 end if;
        --
        l_return_status := true;
      end if;
 if g_debug then
      hr_utility.set_location(l_proc, 50);
 end if;
    end if;
 if g_debug then
    hr_utility.set_location(' Leaving '||l_proc, 60);
 end if;
    return l_return_status;
  end apl_sys_per_type_change;
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business group id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Check if the person is being updated
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The applicant number value has changed
  --  c) a record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number);
 if g_debug then
  hr_utility.set_location(l_proc, 2);
 end if;
  --
  -- Need to validate/generate the applicant number if the applicant number
  -- has changed or if the system person type has changed in such a way
  -- that an applicant number is now required.
  --
  if ((l_api_updating and
              (nvl(per_per_shd.g_old_rec.applicant_number,
                   hr_api.g_varchar2) <>
               nvl(p_applicant_number, hr_api.g_varchar2)
               or   apl_sys_per_type_change
                                (p_person_type_id
                                ,per_per_shd.g_old_rec.person_type_id
                                ,p_business_group_id)))
       or
      (NOT l_api_updating)) then
      --
 if g_debug then
      hr_utility.set_location(l_proc, 3);
 end if;
      --
      --  Get the generation method for applicant numbers for the
      --  business group
      --
      open csr_gen_meth;
      fetch csr_gen_meth into l_gen_method;
      close csr_gen_meth;
 if g_debug then
      hr_utility.set_location(l_proc, 4);
 end if;
      --
      --  Get the system person type for the type id
      --
      l_system_person_type := return_system_person_type
                                   (p_person_type_id    => p_person_type_id
                                   ,p_business_group_id => p_business_group_id
                                   );
 if g_debug then
      hr_utility.set_location(l_proc, 5);
 end if;
      --
      --  If system_person_type is OTHER, applicant number must be NULL
      --
      if (l_system_person_type = 'OTHER' and
          p_applicant_number is not null) then
        hr_utility.set_message(801, 'HR_51199_PER_APP_NOT_NULL');
        l_apl_sys := true;
        hr_utility.raise_error;
      end if;
 if g_debug then
      hr_utility.set_location(l_proc, 6);
 end if;
      --
      --  If system person type is EMP, applicant number must be NULL
      --  on insert
      --
      if (NOT l_api_updating and
          l_system_person_type = 'EMP' and
          p_applicant_number is not null) then
        hr_utility.set_message(801, 'HR_51202_PER_APL_NOT_NULL');
        l_apl_sys := true;
        hr_utility.raise_error;
      end if;
 if g_debug then
      hr_utility.set_location(l_proc, 7);
 end if;
      --
      --  If system person type is EMP or EX_EMP and we are updating then
      --  applicant number cannot change to null
      --
      if (l_api_updating) then
        if (l_system_person_type in ('EMP','EX_EMP') and
            per_per_shd.g_old_rec.applicant_number is not null and
            p_applicant_number is null) then
          hr_utility.set_message(801, 'HR_51200_PER_APL_NOT_NULL_UPD');
          l_apl_sys := true;
          hr_utility.raise_error;
        end if;
 if g_debug then
        hr_utility.set_location(l_proc, 8);
 end if;
      end if;
 if g_debug then
      hr_utility.set_location(l_proc, 9);
 end if;
      --
      --  Check that on update with Automatic number generation
      --  the applicant number is not changed.
      --
      if (l_api_updating and
          nvl(per_per_shd.g_old_rec.applicant_number,hr_api.g_varchar2) <>
               nvl(p_applicant_number, hr_api.g_varchar2)  and
          l_gen_method = 'A') then
        hr_utility.set_message(801, 'HR_51201_PER_INV_APL_UPD');
        hr_utility.raise_error;
      end if;
 if g_debug then
      hr_utility.set_location(l_proc,11);
 end if;
      --
      --  On update, If system person type is EMP and no previous sys per
      --  type change then applicant number must be null
      --
      if (l_api_updating and
          l_system_person_type = 'EMP' and
          NOT hr_person.chk_prev_person_type
             (p_system_person_type   => l_system_person_type
             ,p_person_id            => p_person_id
             ,p_business_group_id    => p_business_group_id
             ,p_effective_start_date => p_effective_date) and
          p_applicant_number is not null) then
        hr_utility.set_message(801, 'HR_51202_PER_APP_NOT_NULL_SPT');
        l_apl_sys := true;
        hr_utility.raise_error;
      end if;
 if g_debug then
      hr_utility.set_location(l_proc,12);
 end if;
      --
      --  Now call the generate routine. We are either in insert mode
      --  or updating a manually generated applicant number
      --
      hr_person.generate_number(p_current_employee    => 'N'
                               ,p_current_applicant   => p_current_applicant
                               ,p_current_npw         => 'N'
                               ,p_national_identifier => NULL
                               ,p_business_group_id   => p_business_group_id
                               ,p_person_id           => p_person_id
                               ,p_employee_number     => l_employee_number
                               ,p_applicant_number    => p_applicant_number
                               ,p_npw_number          => l_npw_number
                               ,p_effective_date      => p_effective_date
                               ,p_party_id            => p_party_id
                               ,p_date_of_birth       => p_date_of_birth
                               ,p_start_date          => p_effective_date);

 if g_debug then
      hr_utility.set_location(l_proc,13);
 end if;
      --
      --  Check uniqueness of generated number
      --
      if l_gen_method <> 'A' then
        --
 if g_debug then
        hr_utility.set_location(l_proc,14);
 end if;
        --
        hr_person.validate_unique_number
                                  (p_person_id         => p_person_id
                                  ,p_business_group_id => p_business_group_id
                                  ,p_employee_number   => null
                                  ,p_applicant_number  => p_applicant_number
                                  ,p_npw_number        => null
                                  ,p_current_employee  => 'N'
                                  ,p_current_applicant => p_current_applicant
                                  ,p_current_npw       => 'N');
        --
 if g_debug then
        hr_utility.set_location(l_proc,15);
 end if;
        --
      end if;
      --
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc,16);
 end if;
  exception
    when app_exception.application_exception then
    if not l_apl_sys
    then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.APPLICANT_NUMBER'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 17);
 end if;
        raise;
      end if;
    else
       if hr_multi_message.exception_add
        (p_associated_column1  => 'PER_ALL_PEOPLE_F.APPLICANT_NUMBER'
        ,p_associated_column2  => 'PER_ALL_PEOPLE_F.PERSON_TYPE_ID'
        ) then
 if g_debug then
          hr_utility.set_location(' Leaving:'||l_proc, 17);
 end if;
          raise;
      end if;
    end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,18);
 end if;
end chk_applicant_number;
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_date_emp_data_verified  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that date employee data verified is always null on insert. On
--    update date employee data verified cannot be set to a not null value.
--    However, a not null value for date employee data verified is permissable
--    when other attributes apart from date employee data verified are being
--    set.
--
--  Pre-conditions:
--    Valid person_id
--
--  In Arguments:
--    p_person_id
--    p_date_employee_data_verified
--    p_effective_start_date
--    p_object_version_number
--
--  Post Success:
--    If date_employee_data_verified is after the effective_start_date
--    of the person record then process succeeds
--
--  Post Failure:
--    If date_employee_data_verified is before the effective_start_date of
--    the person record an application error will be raised and processing
--    is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_date_emp_data_verified
  (p_person_id                   in per_all_people_f.person_id%TYPE
  ,p_date_employee_data_verified in
   per_all_people_f.date_employee_data_verified%TYPE
  ,p_effective_start_date        in date
  ,p_object_version_number       in per_all_people_f.object_version_number%TYPE
  )
  is
--
  l_proc             varchar2(72);
  l_api_updating     boolean;
--
begin
 if g_debug then
  l_proc :=  g_package||'chk_date_employee_data_verified';
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_start_date
        ,p_object_version_number  => p_object_version_number);
 if g_debug then
  hr_utility.set_location(l_proc, 2);
 end if;
  --
  if ((l_api_updating and
       nvl(per_per_shd.g_old_rec.date_employee_data_verified,
       hr_api.g_date) <> nvl(p_date_employee_data_verified,
       hr_api.g_date)) or (NOT l_api_updating)) then
    --
 if g_debug then
    hr_utility.set_location(l_proc, 3);
 end if;
    --
    --  Check that date employee data verified is valid
    --
    -- The date_employee_data_verified can be earlier than the
    -- effective_starte_date. Bug# 2775438.

    --if p_date_employee_data_verified is not null and
    --  p_date_employee_data_verified < p_effective_start_date then
      --  Error: Invalid value
    --  hr_utility.set_message(801, 'HR_51256_PER_DTE_EMP_DTE_START');
    --  hr_utility.raise_error;
    --end if;

    --
 if g_debug then
    hr_utility.set_location(l_proc, 4);
 end if;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 5);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_ALL_PEOPLE_F.DATE_EMPLOYEE_DATA_VERIFIED'
      ,p_associated_column2  => 'PER_ALL_PEOPLE_F.EFFECTIVE_START_DATE'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 6);
 end if;
        raise;
      end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,7);
 end if;
end chk_date_emp_data_verified;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_vendor_id  >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that vendor id is valid.
--
--  Pre-conditions:
--    Valid person_id
--
--  In Arguments:
--    p_person_id
--    p_vendor_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If vendor id is null and system person type is not one of  'EMP',
--    'EMP_APL','EX_EMP',EX_EMP_APL then process succeeds.
--    If vendor id is not null, system person type is one of 'EMP','EMP_APL',
--    'EX_EMP','EX_EMP_APL' and vendor id exists in lookup table then process
--    succeeds.
--
--  Post Failure:
--    If vendor id is not null and system person type is not one of  'EMP',
--    'EMP_APL','EX_EMP',EX_EMP_APL then process is terminated.
--    If vendor id is not null, system person type is one of 'EMP','EMP_APL',
--    'EX_EMP','EX_EMP_APL' and vendor id does not exists in lookup table then
--    process is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_vendor_id
  (p_person_id                in per_all_people_f.person_id%TYPE
  ,p_vendor_id                in per_all_people_f.vendor_id%TYPE
  ,p_person_type_id           in per_all_people_f.person_type_id%TYPE
  ,p_business_group_id        in per_all_people_f.business_group_id%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in per_all_people_f.object_version_number%TYPE
  ) is
  --
  l_proc                  varchar2(72);
  l_api_updating          boolean;
  l_exists                varchar2(1);
  --
  -- Cursor to validate vendor_id in PO_VENDORS table.
  --
  cursor csr_chk_vendor is
     select null
     from   po_vendors
     where  vendor_id = p_vendor_id;
  --
begin
 if g_debug then
  l_proc := g_package||'chk_vendor_id';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check if the person is being updated
  --
  l_api_updating := per_per_shd.api_updating
        (p_person_id              => p_person_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => p_object_version_number);
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  if ((l_api_updating and
       nvl(per_per_shd.g_old_rec.vendor_id, hr_api.g_number) <>
       nvl(p_vendor_id, hr_api.g_number)) or
      (NOT l_api_updating)) then
   --
 if g_debug then
   hr_utility.set_location(l_proc, 30);
 end if;
   --
   --  Check the system person type and validate as appropriate.
   --
   if  return_system_person_type(p_person_type_id,p_business_group_id)
          in ('EMP','EMP_APL','EX_EMP','EX_EMP_APL') then
     --
     -- Vendor id can be null, but if it is not null then it must exist
     -- in the PO_VENDORS table.
     --
     if p_vendor_id is not null then
 if g_debug then
       hr_utility.set_location(l_proc, 40);
 end if;
       open csr_chk_vendor;
       fetch csr_chk_vendor into l_exists;
       if csr_chk_vendor%notfound then
         close csr_chk_vendor;
         --
         -- Error : Invalid vendor id
         --
         hr_utility.set_message(801,'HR_51249_PER_INVALID_VENDOR');
         hr_utility.raise_error;
       end if;
       close csr_chk_vendor;
 if g_debug then
       hr_utility.set_location(l_proc, 50);
 end if;
     end if;
   else
     --
 if g_debug then
     hr_utility.set_location(l_proc, 60);
 end if;
     --
     -- Vendor id must be null.
     --
     if p_vendor_id is not null then
       --
       --  Error : Vendor must be null
       --
       hr_utility.set_message(801, 'HR_51250_PER_VENDOR_NOT_NULL');
       hr_utility.raise_error;
     end if;
 if g_debug then
     hr_utility.set_location(l_proc, 70);
 end if;
   end if;
  end if;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 80);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.VENDOR_ID'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 90);
 end if;
        raise;
      end if;
 if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc,100);
 end if;
end chk_vendor_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------------< chk_suffix >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    - No validation
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_marital_status
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues if:
--
--  Post Failure:
--    An application error is raised and processing is terminated if:
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_suffix
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_suffix                   in     per_all_people_f.suffix%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_exists         varchar2(1);
  l_proc           varchar2(72)  :=  g_package||'chk_marital_status';
  l_api_updating   boolean;
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The suffix value has changed
  --  c) a record is being inserted
  --
  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating
      and nvl(per_per_shd.g_old_rec.suffix, hr_api.g_varchar2)
      <> nvl(p_suffix,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
 if g_debug then
    hr_utility.set_location(l_proc, 40);
 end if;
    --
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
 end if;
end chk_suffix;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_work_telephone >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that work_telephone is null. Work Telephone is now stored on the
--    per_phones table.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_work_telephone
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    An application error is raised and processing is terminated
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_work_telephone
  (p_person_id                in     per_all_people_f.person_id%TYPE
  ,p_work_telephone           in     per_all_people_f.work_telephone%TYPE
  ,p_effective_date           in     date
  ,p_object_version_number    in     per_all_people_f.object_version_number%TYPE
  )
is
  --
  l_proc           varchar2(72);
  l_api_updating   boolean;
  --
begin
 if g_debug then
  l_proc :=  g_package||'chk_work_telephone';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;

  l_api_updating := per_per_shd.api_updating
    (p_person_id             => p_person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  if ((l_api_updating
      and nvl(per_per_shd.g_old_rec.work_telephone, hr_api.g_varchar2)
      <> nvl(p_work_telephone,hr_api.g_varchar2))
    or
      (NOT l_api_updating))
  then
    --
    -- Check parameter is null
    --
 if g_debug then
    hr_utility.set_location('Work Number is:'|| p_work_telephone, 15);
 end if;
    if p_work_telephone is not null then
         hr_utility.set_message(801, 'HR_52217_PER_INVALID_PHONE');
         hr_utility.raise_error;
    end if;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
 end if;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ALL_PEOPLE_F.WORK_TELEPHONE'
      ) then
 if g_debug then
        hr_utility.set_location(' Leaving:'||l_proc, 80);
 end if;
        raise;
      end if;
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc,90);
 end if;
end chk_work_telephone;
--
--  Fix 3573040
--  Added new procedure chk_per_information_category
--
--  ---------------------------------------------------------------------------
--  |-------------------<  chk_per_information_category  >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks if the information category has the valid legislation
--
--  In Arguments:
--    p_per_information_category
--    p_legislation_code
--
--  Post Success:
--    If p_per_information_category is not null and it matches the legislation
--    corresponding to the business group then the process succeeds.
--    If p_per_information_category is null and a valid DDF context exists for
--    the legislation of the business group, then the corresponding legislation
--    is set for p_per_information_category
--
--  Post Failure:
--    If p_per_information_category is not null and it does not match the
--    legislation corresponding to the business group then the process fails.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_per_information_category
  (p_per_information_category in out nocopy per_all_people_f.per_information_category%TYPE
  ,p_legislation_code             in per_business_groups.legislation_code%TYPE
  ) is
--
   l_ddf_exists varchar2(1);
--
begin
   -- Bug fix 38383715. Modified if condition.
   if p_per_information_category is not null
      and p_per_information_category <> p_legislation_code then
         hr_utility.set_message( 800, 'PER_449162_INFO_CATEGORY' );
         hr_utility.raise_error;
   else
         PER_PEOPLE3_PKG.get_ddf_exists
         ( p_legislation_code => p_legislation_code
         , p_ddf_exists       => l_ddf_exists );
         if l_ddf_exists = 'Y' then
            p_per_information_category := p_legislation_code;
         else
            p_per_information_category := null;
         end if;
   end if;
end chk_per_information_category;
--
--  ---------------------------------------------------------------------------
--  |------------------------<  chk_delete >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that rows may be deleted from per_all_people_f
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--    p_business_group_id
--    p_person_type_id
--    p_effective_date
--    p_datetrack_mode
--
--  Post Success:
--    If a row may be deleted then
--    processing continues
--
--  Post Failure:
--    If future changes to person type exist and datetrack mode is delete next
--    change or delete future change
--    an application error will be raised and processing is terminated
--
--    See perper.bru for full list of failure conditions handled by
--    hr_person_delete.weak_predel_validation
--    hr_person_delete.moderate_predel_validation and
--
--  Access Status:
--    Internal Table Handler Use Only.
--
procedure chk_delete
  (p_person_id          in per_all_people_f.person_id%TYPE
  ,p_business_group_id  in per_all_people_f.business_group_id%TYPE
  ,p_person_type_id     in per_all_people_f.person_type_id%TYPE
  ,p_effective_date     in   date
  ,p_datetrack_mode     in   varchar2) is
--
  l_exists             varchar2(1);
  l_proc               varchar2(72)  :=  g_package||'chk_delete';
  l_system_person_type varchar2(30);
--
--  check if future changes to system person type exist
--
  cursor csr_chk_future_changes
    (c_system_person_type    per_person_types.system_person_type%TYPE
    )
  is
  select   null
    from   sys.dual
    where exists
      (select   null
       from     per_all_people_f ppf,
                per_person_types ppt
       where    ppf.effective_start_date > p_effective_date
     and      ppf.person_id = p_person_id
       and      ppt.person_type_id = ppf.person_type_id
       and      ppt.system_person_type <> c_system_person_type
      );
--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business group id'
    ,p_argument_value => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person type id'
    ,p_argument_value => p_person_type_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack mode'
    ,p_argument_value => p_datetrack_mode
    );
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --  If delete mode is DELETE_NEXT_CHANGE or FUTURE_CHANGE
  --  check if rows exist in PER_PEOPLE_F where the system person type has
  --  changed
  --
  if p_datetrack_mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE')
  then
    --
    l_system_person_type := return_system_person_type
                              (p_person_type_id,
                              p_business_group_id
                              );
    open csr_chk_future_changes(l_system_person_type);
    fetch csr_chk_future_changes into l_exists;
    if csr_chk_future_changes%found then
      close csr_chk_future_changes;
      --  Error: Delete not allowed
      hr_utility.set_message(801, 'HR_7726_PER_DEL_NOT_ALLOWED');
      hr_utility.raise_error;
    end if;
    close csr_chk_future_changes;
 if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 3);
 end if;
  --
  --  If delete mode in ('ZAP','DELETE','DELETE_NEXT_CHANGE',
  --                     'FUTURE_CHANGE') then
  --  carry out weak and moderate delete checks
  --
  -- if  p_datetrack_mode in ('ZAP','DELETE','DELETE_NEXT_CHANGE',
  -- 'FUTURE_CHANGE') then
  --
  if p_datetrack_mode in ('ZAP','DELETE') then
    --
    -- Fix for 3908271 starts here.
    -- Comment out the following calls.
    --
    /*
    hr_person_delete.weak_predel_validation(p_person_id  => p_person_id
                                           ,p_session_date => p_effective_date);
    hr_person_delete.moderate_predel_validation(p_person_id  => p_person_id
                                           ,p_session_date => p_effective_date);
    */
    --
    -- Call hr_person_internal procedures.
    --
    hr_person_internal.weak_predel_validation(p_person_id  => p_person_id
                                           ,p_effective_date => p_effective_date);
    hr_person_internal.strong_predel_validation(p_person_id  => p_person_id
                                           ,p_effective_date => p_effective_date);
    --
    -- Fix for 3908271 ends here.
    --
  end if;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
 end if;
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updatetable attributes have
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
--   (business_group_id)
--   have been altered.
--
-- Access Status:
--   Internal Development Use Only.
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure check_non_updateable_args(p_rec in per_per_shd.g_rec_type
                                   ,p_effective_date in date) is
--
  l_proc     varchar2(72) := g_package||'check_non_updateable_args';
--
Begin
 if g_debug then
   hr_utility.set_location('Entering:'||l_proc, 5);
 end if;
--
-- Only proceed with validation if a row exists for
-- the current record in the HR Schema
--
  if not per_per_shd.api_updating
    (p_person_id                  => p_rec.person_id
    ,p_effective_date             => p_effective_date
    ,p_object_version_number      => p_rec.object_version_number) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '5');
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 6);
 end if;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(per_per_shd.g_old_rec.business_group_id, hr_api.g_number) then
     hr_api.argument_changed_error
     (
      p_api_name   => l_proc
     ,p_argument   => 'BUSINESS_GROUP_ID'
     ,p_base_table => per_per_shd.g_tab_nam
     );
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving '||l_proc, 7);
 end if;
  --
end check_non_updateable_args;
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
-- Pre Conditions:
--   This procedure is called from the update_validate.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (
        p_datetrack_mode           in varchar2,
             p_validation_start_date        in date,
        p_validation_end_date      in date) Is
--
  l_proc     varchar2(72) := g_package||'dt_update_validate';
--l_integrity_error Exception;
  l_table_name     all_tables.table_name%TYPE;
--
Begin
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
 end if;
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    --
    --
  End If;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
Exception
  /*When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;*/
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
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
-- Pre Conditions:
--   This procedure is called from the delete_validate.
--
-- In Arguments:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_person_id      in number,
             p_datetrack_mode    in varchar2,
        p_validation_start_date  in date,
        p_validation_end_date in date) Is
--
  l_proc varchar2(72)   := g_package||'dt_delete_validate';
--l_rows_exist Exception;
  l_table_name all_tables.table_name%TYPE;
--
Begin
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
 end if;
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'person_id',
       p_argument_value => p_person_id);
    --
    --
    if (dt_api.rows_exist
       (p_base_table_name => 'per_contracts_f',
        p_base_key_column => 'person_id',
        p_base_key_value => p_person_id,
        p_from_date => p_validation_start_date,
        p_to_date => p_validation_end_date)) then
        l_table_name := 'contracts';
        hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
        hr_utility.set_message_token('TABLE_NAME', l_table_name);
        hr_multi_message.add;
    --  raise l_rows_exist;
    end if;
    --
    --
  End If;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
Exception
  /*When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;*/
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
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
  (p_rec in per_per_shd.g_rec_type) is
--
  l_proc     varchar2(72);
--
begin
 if g_debug then
   l_proc    := g_package||'chk_df';
  hr_utility.set_location('Entering:'||l_proc, 10);
 end if;
  --
  if ((p_rec.person_id is not null) and (
    nvl(per_per_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2) or
    nvl(per_per_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2)))
    or (p_rec.person_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_PEOPLE'
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
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 20);
 end if;

end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
   (p_rec             in out nocopy per_per_shd.g_rec_type,
    p_effective_date     in date,
    p_datetrack_mode     in varchar2,
    p_validation_start_date    in date,
    p_validation_end_date      in date,
         p_name_combination_warning out nocopy boolean,
         p_dob_null_warning         out nocopy boolean,
         p_orig_hire_warning        out nocopy boolean) is
--
  l_proc varchar2(72);
  l_legislation_code        per_business_groups.legislation_code%TYPE;
--
  l_first_name  per_all_people_f.first_name%TYPE;
  l_last_name   per_all_people_f.last_name%TYPE;
  l_output  varchar2(150);
  l_rgeflg  varchar2(10);
  l_duplicate_flag varchar2(1);
--
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_rec.business_group_id;
--
-- Added for 3104595 starts here
  cursor csr_bg_start_date is
    select date_from
      from per_business_groups pbg
     where pbg.business_group_id = p_rec.business_group_id;
  --
  l_bg_start_date    date;
-- Added for 3104595 ends here
--
--
Begin
 if g_debug then
  l_proc  := g_package||'insert_validate';
  hr_utility.set_location('Entering:'||l_proc, 10);
 end if;
  --
  -- Set global variable used to improve calling of return_system_status_type
  -- when called multiple times on same pass through the validation process.
  -- A null value indicates that the function has not been called on this pass
  -- through the validation process.
  --
  g_previous_sys_per_type := NULL;
  --
  -- Check that no unsupported attributes have been set.
  --
  per_per_bus1.chk_unsupported_attributes
    (p_person_id             =>  p_rec.person_id
    ,p_fast_path_employee    =>  p_rec.fast_path_employee
    ,p_order_name            =>  p_rec.order_name
    ,p_projected_start_date  =>  p_rec.projected_start_date
    ,p_rehire_authorizor     =>  p_rec.rehire_authorizor
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
  --
  -- Call all supporting business operations
  -- Mapping to the appropriate Business Rules in perper.bru is provided.
  --
  --  Validate Business Group Id
  --
  hr_api.validate_bus_grp_id
  (p_business_group_id => p_rec.business_group_id
  ,p_associated_column1 => per_per_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
  );
  hr_multi_message.end_validation_set;
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Validate Correspondence Language
  --
  per_per_bus1.chk_correspondence_language
    (p_person_id                  =>  p_rec.person_id
    ,p_effective_date             =>  p_effective_date
    ,p_correspondence_language    =>  p_rec.correspondence_language
    ,p_object_version_number      =>  p_rec.object_version_number);
  --
  -- Added for 3104595 starts here
     open csr_bg_start_date;
     fetch csr_bg_start_date  into  l_bg_start_date;
-- Modified the check condition as part of fix 5407679
     if csr_bg_start_date%found then
        if l_bg_start_date > p_rec.effective_start_date then
           fnd_message.set_name('PER','HR_52383_EFF_DATE_RANGE');
           fnd_message.raise_error;
        end if;
     end if;
     close csr_bg_start_date;
--
-- Added for 3104595 ends here
--
  --
  -- Validate FTE capacity
  --
  per_per_bus1.chk_fte_capacity
    (p_person_id              =>  p_rec.person_id
    ,p_effective_date         =>  p_effective_date
    ,p_fte_capacity           =>  p_rec.fte_capacity
    ,p_object_version_number  =>  p_rec.object_version_number);
  --
  -- Validate Background Check Status
  --
  per_per_bus1.chk_BACKGROUND_CHECK_STATUS
    (p_person_id                   =>  p_rec.person_id
    ,p_BACKGROUND_CHECK_STATUS     =>  p_rec.BACKGROUND_CHECK_STATUS
    ,p_effective_date              =>  p_effective_date
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Validate Blood Type
  --
  per_per_bus1.chk_blood_type
    (p_person_id                   =>  p_rec.person_id
    ,p_blood_type                  =>  p_rec.blood_type
    ,p_effective_date              =>  p_effective_date
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  -- Validate Student Status
  --
  per_per_bus1.chk_student_status
    (p_person_id                   =>  p_rec.person_id
    ,p_student_status              =>  p_rec.student_status
    ,p_effective_date              =>  p_effective_date
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 50);
 end if;
  --
  -- Validate Work Schedule
  --
  per_per_bus1.chk_work_schedule
    (p_person_id             =>  p_rec.person_id
    ,p_work_schedule         =>  p_rec.work_schedule
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  -- Validate Rehire Recommendation
  --
  per_per_bus1.chk_rehire_recommendation
    (p_person_id             =>  p_rec.person_id
    ,p_rehire_recommendation =>  p_rec.rehire_recommendation
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 70);
 end if;
  --
  -- Validate Benefit Group Id
  --
  per_per_bus1.chk_benefit_group_id
    (p_person_id             =>  p_rec.person_id
    ,p_benefit_group_id      =>  p_rec.benefit_group_id
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  -- Validate Receipt of Death Certificate date.
  --
  per_per_bus1.chk_date_death_and_rcpt_cert
    (p_person_id             =>  p_rec.person_id
    ,p_receipt_of_death_cert_date =>  p_rec.receipt_of_death_cert_date
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_date_of_death         =>  p_rec.date_of_death
    );
 if g_debug then
  hr_utility.set_location(l_proc, 90);
 end if;
  --
  -- Validate the dependent's adoption date.
  --
  per_per_bus1.chk_birth_adoption_date
    (p_person_id             =>  p_rec.person_id
    ,p_dpdnt_adoption_date   =>  p_rec.dpdnt_adoption_date
    ,p_date_of_birth         =>  p_rec.date_of_birth
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  -- Validate registered disabled flag.
  --
  per_per_bus1.chk_rd_flag
    (p_person_id             =>  p_rec.person_id
    ,p_registered_disabled_flag =>  p_rec.registered_disabled_flag
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
  --
  -- Validate Date of Death.
  --
  per_per_bus1.chk_date_of_death
    (p_person_id             =>  p_rec.person_id
    ,p_date_of_death         =>  p_rec.date_of_death
    ,p_date_of_birth         =>  p_rec.date_of_birth
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 120);
 end if;
    --
    -- Validate uses tobacco flag.
    --
  per_per_bus1.chk_uses_tobacco
    (p_person_id             =>  p_rec.person_id
    ,p_uses_tobacco_flag     =>  p_rec.uses_tobacco_flag
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
     );
 if g_debug then
  hr_utility.set_location(l_proc, 125);
 end if;

  --
  chk_orig_and_start_dates
    (p_person_id             =>  p_rec.person_id
    ,p_person_type_id        =>  p_rec.person_type_id
    ,p_business_group_id     =>  p_rec.business_group_id
    ,p_original_date_of_hire =>  p_rec.original_date_of_hire
    ,p_start_date            =>  p_rec.start_date
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_orig_hire_warning     =>  p_orig_hire_warning
    );
 if g_debug then
  hr_utility.set_location(l_proc, 130);
 end if;
  --
  --  Validate Person Type ID
  --
  chk_person_type_id
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_person_type_id           =>  p_rec.person_type_id
    ,p_old_person_type_id       =>  p_rec.person_type_id
    ,p_current_employee_flag    =>  p_rec.current_employee_flag
    ,p_current_applicant_flag   =>  p_rec.current_applicant_flag
    ,p_current_emp_or_apl_flag  =>  p_rec.current_emp_or_apl_flag
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_object_version_number    =>  p_rec.object_version_number
    ,p_datetrack_mode           =>  p_datetrack_mode
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Set current flags
  --
  set_current_flags
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_person_type_id           =>  p_rec.person_type_id
    ,p_current_employee_flag    =>  p_rec.current_employee_flag
    ,p_current_applicant_flag   =>  p_rec.current_applicant_flag
    ,p_current_emp_or_apl_flag  =>  p_rec.current_emp_or_apl_flag
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  -- Validate National Identifier
  --
  open csr_bg;
  fetch csr_bg into l_legislation_code;
  close csr_bg;
  chk_national_identifier
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_national_identifier      =>  p_rec.national_identifier
    ,p_date_of_birth            =>  p_rec.date_of_birth
    ,p_sex                      =>  p_rec.sex
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    ,p_legislation_code         =>  l_legislation_code
    ,p_person_type_id           =>  p_rec.person_type_id

    --changed for bug 6241572
    ,p_region_of_birth          => p_rec.region_of_birth
    ,p_country_of_birth         => p_rec.country_of_birth
    ,p_nationality              => p_rec.nationality

    );
    --
 if g_debug then
  hr_utility.set_location(l_proc, 50);
 end if;
  --
  -- Validate Employee Number
  --
  chk_employee_number
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_person_type_id           =>  p_rec.person_type_id
    ,p_employee_number          =>  p_rec.employee_number
    ,p_national_identifier      =>  p_rec.national_identifier
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    ,p_party_id                 =>  p_rec.party_id
    ,p_date_of_birth            =>  p_rec.date_of_birth
    ,p_start_date               =>  p_rec.effective_start_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  chk_npw_number
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_current_npw_flag         =>  p_rec.current_npw_flag
    ,p_npw_number               =>  p_rec.npw_number
    ,p_national_identifier      =>  p_rec.national_identifier
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    ,p_party_id                 =>  p_rec.party_id
    ,p_date_of_birth            =>  p_rec.date_of_birth
    ,p_start_date               =>  p_rec.effective_start_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 65);
 end if;
  --
  chk_expense_check_send_to_addr
    (p_person_id                =>  p_rec.person_id
    ,p_expense_check_send_to_addres =>  p_rec.expense_check_send_to_address
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 70);
 end if;
  --
  -- Validate Start Date
  --
  chk_start_date
    (p_person_id                =>  p_rec.person_id
    ,p_start_date               =>  p_rec.start_date
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  -- Validate Nationality
  --
  chk_nationality
    (p_person_id                =>  p_rec.person_id
    ,p_nationality              =>  p_rec.nationality
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 90);
 end if;
  --
  -- Validate Marital Status
  --
  chk_marital_status
    (p_person_id                =>  p_rec.person_id
    ,p_marital_status           =>  p_rec.marital_status
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  chk_party_id
    (p_person_id                =>  p_rec.person_id
    ,p_party_id                 =>  p_rec.party_id
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number);
  --
  -- Validate Sex and Title
  --
  chk_sex_title
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_person_type_id           =>  p_rec.person_type_id
    ,p_title                    =>  p_rec.title
    ,p_sex                      =>  p_rec.sex
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
  --
  -- Validate Date of Birth
  --
  chk_date_of_birth
    (p_person_id                =>  p_rec.person_id
    ,p_person_type_id           =>  p_rec.person_type_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_start_date               =>  p_rec.start_date
    ,p_date_of_birth            =>  p_rec.date_of_birth
    ,p_dob_null_warning         =>  p_dob_null_warning
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
  --
  -- Validate Town of Birth
  --
  chk_town_of_birth
    (p_person_id                =>  p_rec.person_id
    ,p_town_of_birth            =>  p_rec.town_of_birth
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_legislation_code         =>  l_legislation_code
    );
  --
  -- Validate Region of Birth
  --
  chk_region_of_birth
    (p_person_id                =>  p_rec.person_id
    ,p_region_of_birth          =>  p_rec.region_of_birth
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_legislation_code         =>  l_legislation_code
    );
  --
  -- Validate Country of Birth
  --
  chk_country_of_birth
    (p_person_id                =>  p_rec.person_id
    ,p_country_of_birth         =>  p_rec.country_of_birth
    );

  -- Fix 3573040
  -- Derive per_information_category parameter internally
  --
  chk_per_information_category
     (p_per_information_category  => p_rec.per_information_category
     ,p_legislation_code         =>  l_legislation_code
     );
  --
  -- Set Full Name, Order Name, List Names (Global and Local)
  --
  return_full_name
   (p_person_id                 =>  p_rec.person_id
   ,p_business_group_id         =>  p_rec.business_group_id
   ,p_first_name                =>  p_rec.first_name
   ,p_middle_names              =>  p_rec.middle_names
   ,p_last_name                 =>  p_rec.last_name
   ,p_known_as                  =>  p_rec.known_as
   ,p_title                     =>  p_rec.title
   ,p_date_of_birth             =>  p_rec.date_of_birth
   ,p_suffix                    =>  p_rec.suffix
   ,p_pre_name_adjunct          =>  p_rec.pre_name_adjunct
   ,p_effective_date            =>  p_effective_date
   ,p_object_version_number     =>  p_rec.object_version_number,
    p_previous_last_name        => p_rec.previous_last_name,
    p_email_address      =>  p_rec.email_address  ,
    p_employee_number    =>  p_rec.employee_number  ,
    p_applicant_number   =>  p_rec.applicant_number  ,
    p_npw_number         =>  p_rec.npw_number  ,
    p_per_information1   =>  p_rec.per_information1  ,
    p_per_information2   =>  p_rec.per_information2  ,
    p_per_information3   =>  p_rec.per_information3  ,
    p_per_information4   =>  p_rec.per_information4  ,
    p_per_information5   =>  p_rec.per_information5  ,
    p_per_information6   =>  p_rec.per_information6  ,
    p_per_information7   =>  p_rec.per_information7  ,
    p_per_information8   =>  p_rec.per_information8  ,
    p_per_information9   =>  p_rec.per_information9  ,
    p_per_information10  =>  p_rec.per_information10  ,
    p_per_information11  =>  p_rec.per_information11  ,
    p_per_information12  =>  p_rec.per_information12  ,
    p_per_information13  =>  p_rec.per_information13  ,
    p_per_information14  =>  p_rec.per_information14  ,
    p_per_information15  =>  p_rec.per_information15  ,
    p_per_information16  =>  p_rec.per_information16  ,
    p_per_information17  =>  p_rec.per_information17  ,
    p_per_information18  =>  p_rec.per_information18  ,
    p_per_information19  =>  p_rec.per_information19  ,
    p_per_information20  =>  p_rec.per_information20  ,
    p_per_information21  =>  p_rec.per_information21  ,
    p_per_information22  =>  p_rec.per_information22  ,
    p_per_information23  =>  p_rec.per_information23  ,
    p_per_information24  =>  p_rec.per_information24  ,
    p_per_information25  =>  p_rec.per_information25  ,
    p_per_information26  =>  p_rec.per_information26  ,
    p_per_information27  =>  p_rec.per_information27  ,
    p_per_information28  =>  p_rec.per_information28  ,
    p_per_information29  =>  p_rec.per_information29  ,
    p_per_information30  =>  p_rec.per_information30  ,
    p_attribute1         =>  p_rec.attribute1  ,
    p_attribute2         =>  p_rec.attribute2  ,
    p_attribute3         =>  p_rec.attribute3  ,
    p_attribute4         =>  p_rec.attribute4  ,
    p_attribute5         =>  p_rec.attribute5  ,
    p_attribute6         =>  p_rec.attribute6  ,
    p_attribute7         =>  p_rec.attribute7  ,
    p_attribute8         =>  p_rec.attribute8  ,
    p_attribute9         =>  p_rec.attribute9  ,
    p_attribute10        =>  p_rec.attribute10  ,
    p_attribute11        =>  p_rec.attribute11  ,
    p_attribute12        =>  p_rec.attribute12  ,
    p_attribute13        =>  p_rec.attribute13  ,
    p_attribute14        =>  p_rec.attribute14  ,
    p_attribute15        =>  p_rec.attribute15  ,
    p_attribute16        =>  p_rec.attribute16  ,
    p_attribute17        =>  p_rec.attribute17  ,
    p_attribute18        =>  p_rec.attribute18  ,
    p_attribute19        =>  p_rec.attribute19  ,
    p_attribute20        =>  p_rec.attribute20  ,
    p_attribute21        =>  p_rec.attribute21  ,
    p_attribute22        =>  p_rec.attribute22  ,
    p_attribute23        =>  p_rec.attribute23,
    p_attribute24        =>  p_rec.attribute24,
    p_attribute25        =>  p_rec.attribute25,
    p_attribute26        =>  p_rec.attribute26,
    p_attribute27        =>  p_rec.attribute27,
    p_attribute28        =>  p_rec.attribute28,
    p_attribute29        =>  p_rec.attribute29,
    p_attribute30        =>  p_rec.attribute30,
    p_full_name          =>  p_rec.full_name,
    p_order_name         =>  p_rec.order_name,
    p_global_name        =>  p_rec.global_name,
    p_local_name         =>  p_rec.local_name
   ,p_duplicate_flag     =>  l_duplicate_flag
   ,p_name_combination_warning => p_name_combination_warning
    );

 if g_debug then
  hr_utility.set_location(l_proc, 130);
 end if;
/* Bug#3613987 - Removed chk_JP_names procedure
  --
  -- Create full_name for JP legislation
  --
  if l_legislation_code = 'JP' then
  --
    chk_JP_names
    (p_person_id             => p_rec.person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_rec.object_version_number
    ,p_first_name            => p_rec.first_name
    ,p_last_name             => p_rec.last_name
    ,p_per_information18     => p_rec.per_information18
    ,p_per_information19     => p_rec.per_information19);
    --,p_full_name             => p_rec.full_name );  -- bug# 2689366
  --
  end if;
*/
 if g_debug then
  hr_utility.set_location(l_proc, 145);
 end if;
  --
  -- Validate Applicant Number
  --
  chk_applicant_number
    (p_person_id                 =>  p_rec.person_id
    ,p_applicant_number          =>  p_rec.applicant_number
    ,p_business_group_id         =>  p_rec.business_group_id
    ,p_current_applicant         =>  p_rec.current_applicant_flag
    ,p_person_type_id            =>  p_rec.person_type_id
    ,p_effective_date            =>  p_effective_date
    ,p_object_version_number     =>  p_rec.object_version_number
    ,p_party_id                  =>  p_rec.party_id
    ,p_date_of_birth             =>  p_rec.date_of_birth
    ,p_start_date                =>  null
    );
 if g_debug then
  hr_utility.set_location(l_proc, 150);
 end if;
  --
  -- Validate Date Employee Data Verified
  --
  chk_date_emp_data_verified
    (p_person_id                   =>  p_rec.person_id
    ,p_date_employee_data_verified =>  p_rec.date_employee_data_verified
    ,p_effective_start_date        =>  p_validation_start_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 160);
 end if;
  --
  --
  -- Validate Vendor Id
  --
  chk_vendor_id
    (p_person_id                   =>  p_rec.person_id
    ,p_vendor_id                   =>  p_rec.vendor_id
    ,p_person_type_id              =>  p_rec.person_type_id
    ,p_business_group_id           =>  p_rec.business_group_id
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 180);
 end if;
  --
  chk_suffix
    (p_person_id                   => p_rec.person_id
    ,p_suffix                      => p_rec.suffix
    ,p_effective_date              => p_effective_date
    ,p_object_version_number       => p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 190);
 end if;
  --
  -- Validate work telephone
  --
  chk_work_telephone
  (p_person_id                =>   p_rec.person_id
  ,p_work_telephone           =>   p_rec.work_telephone
  ,p_effective_date           =>   p_effective_date
  ,p_object_version_number    =>   p_rec.object_version_number
  );
  --
  -- Validate benefit medical coverage dates
  --
  per_per_bus1.chk_coord_ben_med_cvg_dates
  (p_coord_ben_med_cvg_strt_dt => p_rec.coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt  => p_rec.coord_ben_med_cvg_end_dt
  );
  --
  -- Validate benefit medical details
  --
  per_per_bus1.chk_coord_ben_med_details
  (p_coord_ben_med_cvg_strt_dt    => p_rec.coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt     => p_rec.coord_ben_med_cvg_end_dt
  ,p_coord_ben_med_ext_er         => p_rec.coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name        => p_rec.coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name  => p_rec.coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident => p_rec.coord_ben_med_insr_crr_ident
  );
  --
  -- Check other benefit coverage rules
  --
  per_per_bus1.chk_other_coverages
  (p_attribute10                 => p_rec.attribute10
  ,p_coord_ben_med_insr_crr_name => p_rec.coord_ben_med_insr_crr_name
  ,p_coord_ben_med_cvg_end_dt    => p_rec.coord_ben_med_cvg_end_dt
  ,p_coord_ben_no_cvg_flag       => p_rec.coord_ben_no_cvg_flag
  ,p_effective_date              => p_effective_date
  );
  --
  -- Validate Developer Descriptive Flexfields
  --
  chk_per_information
    (p_rec         =>  p_rec
    ,p_effective_date            =>  p_effective_date
    ,p_validation_start_date     =>  p_validation_start_date
    ,p_validation_end_date       =>  p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 200);
 end if;
  --
  -- Validate flex fields.
  --
  per_per_bus.chk_df(p_rec => p_rec);
 if g_debug then
  hr_utility.set_location(l_proc, 210);
 end if;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10000);
 end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
   (p_rec          in out nocopy per_per_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date,
         p_name_combination_warning   out nocopy boolean,
         p_dob_null_warning           out nocopy boolean,
         p_orig_hire_warning          out nocopy boolean) is
--
  l_proc varchar2(72);
  l_legislation_code        per_business_groups.legislation_code%TYPE;
--
  l_first_name  per_all_people_f.first_name%TYPE;
  l_last_name   per_all_people_f.last_name%TYPE;
  l_output      varchar2(150);
  l_rgeflg      varchar2(10);
  l_duplicate_flag varchar2(1);
--
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_rec.business_group_id;
--
Begin
 if g_debug then
  l_proc := g_package||'update_validate';
  hr_utility.set_location('Entering:'||l_proc, 10);
 end if;
  --
  -- Set global variable used to improve calling of return_system_status_type
  -- when called multiple times on same pass through the validation process.
  -- A null value indicates that the function has not been called on this pass
  -- through the validation process.
  --
  g_previous_sys_per_type := NULL;
  --
  --  Validate Business Group Id
  --
  hr_api.validate_bus_grp_id
  (p_business_group_id => p_rec.business_group_id
  ,p_associated_column1 => per_per_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
  );
  hr_multi_message.end_validation_set;
  --
  --
  -- Check that no unsupported attributes have been set.
  --
  per_per_bus1.chk_unsupported_attributes
    (p_person_id             =>  p_rec.person_id
    ,p_fast_path_employee    =>  p_rec.fast_path_employee
    ,p_order_name            =>  p_rec.order_name
    ,p_projected_start_date  =>  p_rec.projected_start_date
    ,p_rehire_authorizor     =>  p_rec.rehire_authorizor
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
  --
  -- Validate Correspondence Language
  --
  per_per_bus1.chk_correspondence_language
    (p_person_id                  =>  p_rec.person_id
    ,p_effective_date             =>  p_effective_date
    ,p_correspondence_language    =>  p_rec.correspondence_language
    ,p_object_version_number      =>  p_rec.object_version_number);
  --
  -- Validate FTE capacity
  --
  per_per_bus1.chk_fte_capacity
    (p_person_id              =>  p_rec.person_id
    ,p_effective_date         =>  p_effective_date
    ,p_fte_capacity           =>  p_rec.fte_capacity
    ,p_object_version_number  =>  p_rec.object_version_number);
  --
  -- Validate Background Check Status
  --
  per_per_bus1.chk_BACKGROUND_CHECK_STATUS
    (p_person_id                   =>  p_rec.person_id
    ,p_BACKGROUND_CHECK_STATUS     =>  p_rec.BACKGROUND_CHECK_STATUS
    ,p_effective_date              =>  p_effective_date
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Validate Blood Type
  --
  per_per_bus1.chk_blood_type
    (p_person_id                   =>  p_rec.person_id
    ,p_blood_type                  =>  p_rec.blood_type
    ,p_effective_date              =>  p_effective_date
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  -- Validate Student Status
  --
  per_per_bus1.chk_student_status
    (p_person_id                   =>  p_rec.person_id
    ,p_student_status              =>  p_rec.student_status
    ,p_effective_date              =>  p_effective_date
    ,p_validation_start_date       =>  p_validation_start_date
    ,p_validation_end_date         =>  p_validation_end_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 50);
 end if;
  --
  -- Validate Work Schedule
  --
  per_per_bus1.chk_work_schedule
    (p_person_id             =>  p_rec.person_id
    ,p_work_schedule         =>  p_rec.work_schedule
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  -- Validate Rehire Recommendation
  --
  per_per_bus1.chk_rehire_recommendation
    (p_person_id             =>  p_rec.person_id
    ,p_rehire_recommendation =>  p_rec.rehire_recommendation
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 70);
 end if;
  --
  -- Validate Benefit Group Id
  --
  per_per_bus1.chk_benefit_group_id
    (p_person_id             =>  p_rec.person_id
    ,p_benefit_group_id      =>  p_rec.benefit_group_id
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  -- Validate Receipt of Death Certificate date.
  --
  per_per_bus1.chk_date_death_and_rcpt_cert
    (p_person_id             =>  p_rec.person_id
    ,p_receipt_of_death_cert_date =>  p_rec.receipt_of_death_cert_date
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    ,p_date_of_death         =>  p_rec.date_of_death
    );
 if g_debug then
  hr_utility.set_location(l_proc, 90);
 end if;
  --
  -- Validate the dependent's adoption date.
  --
  per_per_bus1.chk_birth_adoption_date
    (p_person_id             =>  p_rec.person_id
    ,p_dpdnt_adoption_date   =>  p_rec.dpdnt_adoption_date
    ,p_date_of_birth         =>  p_rec.date_of_birth
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  -- Validate registered disabled flag.
  --
  per_per_bus1.chk_rd_flag
    (p_person_id             =>  p_rec.person_id
    ,p_registered_disabled_flag =>  p_rec.registered_disabled_flag
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
  --
  -- Validate Date of Death.
  --
  per_per_bus1.chk_date_of_death
    (p_person_id             =>  p_rec.person_id
    ,p_date_of_death         =>  p_rec.date_of_death
    ,p_date_of_birth         =>  p_rec.date_of_birth
    ,p_effective_date        =>  p_effective_date
    ,p_object_version_number =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 120);
 end if;
  --
  -- Validate uses tobacco flag.
  --
  per_per_bus1.chk_uses_tobacco
    (p_person_id             =>  p_rec.person_id
    ,p_uses_tobacco_flag     =>  p_rec.uses_tobacco_flag
    ,p_effective_date        =>  p_effective_date
    ,p_validation_start_date =>  p_validation_start_date
    ,p_validation_end_date   =>  p_validation_end_date
    ,p_object_version_number =>  p_rec.object_version_number
     );
 if g_debug then
   hr_utility.set_location(l_proc, 125);
 end if;
  --
  chk_orig_and_start_dates
     (p_person_id             => p_rec.person_id
     ,p_person_type_id        => p_rec.person_type_id
     ,p_business_group_id     => p_rec.business_group_id
     ,p_original_date_of_hire => p_rec.original_date_of_hire
     ,p_start_date            => p_rec.start_date
     ,p_effective_date        => p_effective_date
     ,p_object_version_number => p_rec.object_version_number
     ,p_orig_hire_warning     => p_orig_hire_warning
     );
 if g_debug then
   hr_utility.set_location(l_proc, 130);
 end if;
--
  -- Call all supporting business operations
  -- Mapping to the appropriate Business Rules in perper.bru is provided.
  --
  --  Validate Person Type ID
  --
  chk_person_type_id
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_person_type_id           =>  p_rec.person_type_id
    ,p_old_person_type_id       =>  per_per_shd.g_old_rec.person_type_id
    ,p_current_employee_flag    =>  p_rec.current_employee_flag
    ,p_current_applicant_flag   =>  p_rec.current_applicant_flag
    ,p_current_emp_or_apl_flag  =>  p_rec.current_emp_or_apl_flag
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_object_version_number    =>  p_rec.object_version_number
    ,p_datetrack_mode           =>  p_datetrack_mode
    );
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  --
  -- Validate National Identifier
  --
  open csr_bg;
  fetch csr_bg into l_legislation_code;
  close csr_bg;
  chk_national_identifier
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_national_identifier      =>  p_rec.national_identifier
    ,p_date_of_birth            =>  p_rec.date_of_birth
    ,p_sex                      =>  p_rec.sex
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    ,p_legislation_code         =>  l_legislation_code
    ,p_person_type_id           =>  p_rec.person_type_id

    --changed for bu 6241572
    ,p_region_of_birth          => p_rec.region_of_birth
    ,p_country_of_birth         => p_rec.country_of_birth
    ,p_nationality              => p_rec.nationality
    );
    --
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Validate Employee Number
  --
  chk_employee_number
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_person_type_id           =>  p_rec.person_type_id
    ,p_employee_number          =>  p_rec.employee_number
    ,p_national_identifier      =>  p_rec.national_identifier
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    ,p_party_id                 =>  p_rec.party_id
    ,p_date_of_birth            =>  p_rec.date_of_birth
    ,p_start_date               =>  null
    );
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  chk_npw_number
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_current_npw_flag         =>  p_rec.current_npw_flag
    ,p_npw_number               =>  p_rec.npw_number
    ,p_national_identifier      =>  p_rec.national_identifier
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    ,p_party_id                 =>  p_rec.party_id
    ,p_date_of_birth            =>  p_rec.date_of_birth
    ,p_start_date               =>  null
    );
 if g_debug then
  hr_utility.set_location(l_proc, 43);
 end if;
  --
  chk_expense_check_send_to_addr
    (p_person_id                =>  p_rec.person_id
    ,p_expense_check_send_to_addres =>  p_rec.expense_check_send_to_address
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 45);
 end if;
  --
  -- Validate Start Date
  --
  chk_start_date
    (p_person_id                =>  p_rec.person_id
    ,p_start_date               =>  p_rec.start_date
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 50);
 end if;
  --
  -- Validate Nationality
  --
  chk_nationality
    (p_person_id                =>  p_rec.person_id
    ,p_nationality              =>  p_rec.nationality
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
  --
  chk_party_id
    (p_person_id                =>  p_rec.person_id
    ,p_party_id                 =>  p_rec.party_id
    ,p_effective_date           =>  p_effective_date
    ,p_object_version_number    =>  p_rec.object_version_number);
  --
  -- Validate Marital Status
  --
  chk_marital_status
    (p_person_id                =>  p_rec.person_id
    ,p_marital_status           =>  p_rec.marital_status
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 70);
 end if;
  --
  -- Validate Sex and Title
  --
  chk_sex_title
    (p_person_id                =>  p_rec.person_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_person_type_id           =>  p_rec.person_type_id
    ,p_title                    =>  p_rec.title
    ,p_sex                      =>  p_rec.sex
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 80);
 end if;
  --
  -- Validate Date of Birth
  --
  chk_date_of_birth
    (p_person_id                =>  p_rec.person_id
    ,p_person_type_id           =>  p_rec.person_type_id
    ,p_business_group_id        =>  p_rec.business_group_id
    ,p_start_date               =>  p_rec.start_date
    ,p_date_of_birth            =>  p_rec.date_of_birth
    ,p_dob_null_warning         =>  p_dob_null_warning
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_object_version_number    =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 90);
 end if;
  --
  -- Validate Town of Birth
  --
  chk_town_of_birth
    (p_person_id                =>  p_rec.person_id
    ,p_town_of_birth            =>  p_rec.town_of_birth
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_legislation_code         =>  l_legislation_code
    );
  --
  -- Validate Region of Birth
  --
  chk_region_of_birth
    (p_person_id                =>  p_rec.person_id
    ,p_region_of_birth          =>  p_rec.region_of_birth
    ,p_effective_date           =>  p_effective_date
    ,p_validation_start_date    =>  p_validation_start_date
    ,p_validation_end_date      =>  p_validation_end_date
    ,p_legislation_code         =>  l_legislation_code
    );
  --
  -- Validate Country of Birth
  --
  chk_country_of_birth
    (p_person_id                =>  p_rec.person_id
    ,p_country_of_birth         =>  p_rec.country_of_birth
    );
  -- Fix 3573040
  -- Derive per_information_category parameter internally
  --
  chk_per_information_category
     (p_per_information_category  => p_rec.per_information_category
     ,p_legislation_code         =>  l_legislation_code
     );
  --
  -- Set Full Name, Order Name, List Names (Global and Local)
  --
  return_full_name
   (p_person_id                 =>  p_rec.person_id
   ,p_business_group_id         =>  p_rec.business_group_id
   ,p_first_name                =>  p_rec.first_name
   ,p_middle_names              =>  p_rec.middle_names
   ,p_last_name                 =>  p_rec.last_name
   ,p_known_as                  =>  p_rec.known_as
   ,p_title                     =>  p_rec.title
   ,p_date_of_birth             =>  p_rec.date_of_birth
   ,p_suffix                    =>  p_rec.suffix
   ,p_pre_name_adjunct          =>  p_rec.pre_name_adjunct
   ,p_effective_date            =>  p_effective_date
   ,p_object_version_number     =>  p_rec.object_version_number,
    p_previous_last_name        =>  p_rec.previous_last_name,
    p_email_address      =>  p_rec.email_address  ,
    p_employee_number    =>  p_rec.employee_number  ,
    p_applicant_number   =>  p_rec.applicant_number  ,
    p_npw_number         =>  p_rec.npw_number  ,
    p_per_information1   =>  p_rec.per_information1  ,
    p_per_information2   =>  p_rec.per_information2  ,
    p_per_information3   =>  p_rec.per_information3  ,
    p_per_information4   =>  p_rec.per_information4  ,
    p_per_information5   =>  p_rec.per_information5  ,
    p_per_information6   =>  p_rec.per_information6  ,
    p_per_information7   =>  p_rec.per_information7  ,
    p_per_information8   =>  p_rec.per_information8  ,
    p_per_information9   =>  p_rec.per_information9  ,
    p_per_information10  =>  p_rec.per_information10  ,
    p_per_information11  =>  p_rec.per_information11  ,
    p_per_information12  =>  p_rec.per_information12  ,
    p_per_information13  =>  p_rec.per_information13  ,
    p_per_information14  =>  p_rec.per_information14  ,
    p_per_information15  =>  p_rec.per_information15  ,
    p_per_information16  =>  p_rec.per_information16  ,
    p_per_information17  =>  p_rec.per_information17  ,
    p_per_information18  =>  p_rec.per_information18  ,
    p_per_information19  =>  p_rec.per_information19  ,
    p_per_information20  =>  p_rec.per_information20  ,
    p_per_information21  =>  p_rec.per_information21  ,
    p_per_information22  =>  p_rec.per_information22  ,
    p_per_information23  =>  p_rec.per_information23  ,
    p_per_information24  =>  p_rec.per_information24  ,
    p_per_information25  =>  p_rec.per_information25  ,
    p_per_information26  =>  p_rec.per_information26  ,
    p_per_information27  =>  p_rec.per_information27  ,
    p_per_information28  =>  p_rec.per_information28  ,
    p_per_information29  =>  p_rec.per_information29  ,
    p_per_information30  =>  p_rec.per_information30  ,
    p_attribute1         =>  p_rec.attribute1  ,
    p_attribute2         =>  p_rec.attribute2  ,
    p_attribute3         =>  p_rec.attribute3  ,
    p_attribute4         =>  p_rec.attribute4  ,
    p_attribute5         =>  p_rec.attribute5  ,
    p_attribute6         =>  p_rec.attribute6  ,
    p_attribute7         =>  p_rec.attribute7  ,
    p_attribute8         =>  p_rec.attribute8  ,
    p_attribute9         =>  p_rec.attribute9  ,
    p_attribute10        =>  p_rec.attribute10  ,
    p_attribute11        =>  p_rec.attribute11  ,
    p_attribute12        =>  p_rec.attribute12  ,
    p_attribute13        =>  p_rec.attribute13  ,
    p_attribute14        =>  p_rec.attribute14  ,
    p_attribute15        =>  p_rec.attribute15  ,
    p_attribute16        =>  p_rec.attribute16  ,
    p_attribute17        =>  p_rec.attribute17  ,
    p_attribute18        =>  p_rec.attribute18  ,
    p_attribute19        =>  p_rec.attribute19  ,
    p_attribute20        =>  p_rec.attribute20  ,
    p_attribute21        =>  p_rec.attribute21  ,
    p_attribute22        =>  p_rec.attribute22  ,
    p_attribute23        =>  p_rec.attribute23,
    p_attribute24        =>  p_rec.attribute24,
    p_attribute25        =>  p_rec.attribute25,
    p_attribute26        =>  p_rec.attribute26,
    p_attribute27        =>  p_rec.attribute27,
    p_attribute28        =>  p_rec.attribute28,
    p_attribute29        =>  p_rec.attribute29,
    p_attribute30        =>  p_rec.attribute30,
    p_full_name          =>  p_rec.full_name,
    p_order_name         =>  p_rec.order_name,
    p_global_name        =>  p_rec.global_name,
    p_local_name         =>  p_rec.local_name
   ,p_duplicate_flag     =>  l_duplicate_flag
   ,p_name_combination_warning  =>  p_name_combination_warning
    );

 if g_debug then
  hr_utility.set_location(l_proc, 100);
 end if;
  --
  -- Validate benefit medical coverage dates
  --
  per_per_bus1.chk_coord_ben_med_cvg_dates
  (p_coord_ben_med_cvg_strt_dt => p_rec.coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt  => p_rec.coord_ben_med_cvg_end_dt
  );
  --
  -- Validate benefit medical details
  --
  per_per_bus1.chk_coord_ben_med_details
  (p_coord_ben_med_cvg_strt_dt    => p_rec.coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt     => p_rec.coord_ben_med_cvg_end_dt
  ,p_coord_ben_med_ext_er         => p_rec.coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name        => p_rec.coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name  => p_rec.coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident => p_rec.coord_ben_med_insr_crr_ident
  );
  --
  -- Check other benefit coverage rules
  --
  per_per_bus1.chk_other_coverages
  (p_attribute10                 => p_rec.attribute10
  ,p_coord_ben_med_insr_crr_name => p_rec.coord_ben_med_insr_crr_name
  ,p_coord_ben_med_cvg_end_dt    => p_rec.coord_ben_med_cvg_end_dt
  ,p_coord_ben_no_cvg_flag       => p_rec.coord_ben_no_cvg_flag
  ,p_effective_date              => p_effective_date
  );
  --
  -- Validate Developer Descriptive Flexfields
  --
  chk_per_information
    (p_rec         =>  p_rec
    ,p_effective_date            =>  p_effective_date
    ,p_validation_start_date     =>  p_validation_start_date
    ,p_validation_end_date       =>  p_validation_end_date
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 110);
 end if;
/* Bug#3613987 - Removed chk_JP_names procedure
  --
  -- Create full_name for JP legislation
  --
  if l_legislation_code = 'JP' then
  --
    chk_JP_names
    (p_person_id             => p_rec.person_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_rec.object_version_number
    ,p_first_name            => p_rec.first_name
    ,p_last_name             => p_rec.last_name
    ,p_per_information18     => p_rec.per_information18
    ,p_per_information19     => p_rec.per_information19);
    --,p_full_name             => p_rec.full_name );  -- bug# 2689366 --
  --
  end if;
*/
 if g_debug then
  hr_utility.set_location(l_proc, 145);
 end if;
  --
  -- Validate Applicant Number
  --
  chk_applicant_number
    (p_person_id                 =>  p_rec.person_id
    ,p_applicant_number          =>  p_rec.applicant_number
    ,p_business_group_id         =>  p_rec.business_group_id
    ,p_current_applicant         =>  p_rec.current_applicant_flag
    ,p_person_type_id            =>  p_rec.person_type_id
    ,p_effective_date            =>  p_effective_date
    ,p_object_version_number     =>  p_rec.object_version_number
    ,p_party_id                  =>  p_rec.party_id
    ,p_date_of_birth             =>  p_rec.date_of_birth
    ,p_start_date                =>  null
    );
 if g_debug then
  hr_utility.set_location(l_proc, 120);
 end if;
  --
  -- Validate Date Employee Data Verified
  --
  chk_date_emp_data_verified
    (p_person_id                   =>  p_rec.person_id
    ,p_date_employee_data_verified =>  p_rec.date_employee_data_verified
    ,p_effective_start_date        =>  p_validation_start_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 130);
 end if;
  --
  -- Validate Vendor Id
  --
  chk_vendor_id
    (p_person_id                   =>  p_rec.person_id
    ,p_vendor_id                   =>  p_rec.vendor_id
    ,p_person_type_id              =>  p_rec.person_type_id
    ,p_business_group_id           =>  p_rec.business_group_id
    ,p_effective_date              =>  p_effective_date
    ,p_object_version_number       =>  p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 150);
 end if;
  --
  chk_suffix
    (p_person_id                   => p_rec.person_id
    ,p_suffix                      => p_rec.suffix
    ,p_effective_date              => p_effective_date
    ,p_object_version_number       => p_rec.object_version_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 160);
 end if;
  --
  -- Validate work telephone
  --
  chk_work_telephone
  (p_person_id                =>   p_rec.person_id
  ,p_work_telephone           =>   p_rec.work_telephone
  ,p_effective_date           =>   p_effective_date
  ,p_object_version_number    =>   p_rec.object_version_number
  );
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date       => p_validation_start_date,
     p_validation_end_date      => p_validation_end_date
    );
 if g_debug then
  hr_utility.set_location(l_proc, 170);
 end if;
  --
  --
  -- Validate flex fields.
  --
  per_per_bus.chk_df(p_rec => p_rec);
 if g_debug then
  hr_utility.set_location(l_proc, 180);
 end if;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10000);
 end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
   (p_rec          in per_per_shd.g_rec_type,
    p_effective_date  in date,
    p_datetrack_mode  in varchar2,
    p_validation_start_date in date,
    p_validation_end_date   in date) is
--
  l_proc varchar2(72);
--
Begin
 if g_debug then
  l_proc := g_package||'delete_validate';
  hr_utility.set_location('Entering:'||l_proc, 5);
 end if;
  --
  -- Set global variable used to improve calling of return_system_status_type
  -- when called multiple times on same pass through the validation process.
  -- A null value indicates that the function has not been called on this pass
  -- through the validation process.
  --
  g_previous_sys_per_type := NULL;
  --
  -- Call all supporting business operations. Mapping to the appropriate
  -- business rules on perper.bru is provided
  --
  -- check if delete operations are allowed
  --
  chk_delete
    (p_person_id                   =>  p_rec.person_id
    ,p_person_type_id              =>  per_per_shd.g_old_rec.person_type_id
    ,p_business_group_id           =>  per_per_shd.g_old_rec.business_group_id
    ,p_effective_date              =>  p_effective_date
    ,p_datetrack_mode              =>  p_datetrack_mode
   );
  --
  dt_delete_validate
    (p_datetrack_mode      => p_datetrack_mode,
     p_validation_start_date  => p_validation_start_date,
     p_validation_end_date => p_validation_end_date,
     p_person_id     => p_rec.person_id);
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
End delete_validate;
--
-- ---------------------------------------------------------------------------|
-- |---------------------------< chk_person_type>-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_person_type
  (p_person_type_id     in out nocopy number
  ,p_business_group_id  in     number
  ,p_expected_sys_type  in     varchar2) is
--
  l_system_person_type per_person_types.system_person_type%type;
  l_active_flag        per_person_types.active_flag%type;
  l_business_group_id  per_person_types.business_group_id%type;
  l_proc               varchar2(30);
--
  -- Bug fix 3632363. cursor modified to improve performance.
  cursor csr_get_default is
    select pet.person_type_id
    from per_person_types pet
    where pet.system_person_type = p_expected_sys_type
    and   pet.business_group_id  = p_business_group_id
    and   pet.active_flag = 'Y'
    and   pet.default_flag = 'Y';
--
  cursor csr_person_type is
    select pet.system_person_type,
      pet.active_flag,
      pet.business_group_id
    from per_person_types pet
    where pet.person_type_id = p_person_type_id;
  --
begin
 if g_debug then
  l_proc := 'chk_person_type';
  hr_utility.set_location(' Entering '||l_proc,10);
 end if;
  --
  -- Validate the specified business group
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id =>  p_business_group_id
    ,p_associated_column1 => per_per_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
    );
  hr_multi_message.end_validation_set;
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
  --
  -- If the person type hasn't been specified or is set to the system default
  -- hr_api.g_number, then fetch the default for
  -- the business group and system type.
  --
  if (p_person_type_id is null or p_person_type_id = hr_api.g_number) then
 if g_debug then
    hr_utility.set_location(l_proc,30);
 end if;
    --
    -- Get the required default person type
    --
    open csr_get_default;
    fetch csr_get_default
    into p_person_type_id;
    if csr_get_default%notfound then
      close csr_get_default;
      hr_utility.set_message(801, 'HR_7972_PER_NO_DEFAULT_TYPE');
      hr_utility.raise_error;
    end if;
    close csr_get_default;
 if g_debug then
    hr_utility.set_location(l_proc,40);
 end if;
  else
 if g_debug then
    hr_utility.set_location(l_proc,50);
 end if;
    --
    -- Validate the specified person type.
    --
    open csr_person_type;
    fetch csr_person_type
    into l_system_person_type,
         l_active_flag,
    l_business_group_id;
    if csr_person_type%notfound then
      close csr_person_type;
      hr_utility.set_message(801, 'HR_7513_PER_TYPE_INVALID');
      hr_utility.raise_error;
    end if;
    close csr_person_type;
 if g_debug then
    hr_utility.set_location(l_proc,60);
 end if;
    --
    if l_active_flag <> 'Y' then
      hr_utility.set_message(801, 'HR_7973_PER_TYPE_NOT_ACTIVE');
      hr_utility.raise_error;
    elsif l_business_group_id <> p_business_group_id then
      hr_utility.set_message(801, 'HR_7974_PER_TYPE_INV_BUS_GROUP');
      hr_utility.raise_error;
    elsif l_system_person_type <> p_expected_sys_type then
      hr_utility.set_message(801, 'HR_7970_PER_WRONG_SYS_TYPE');
      hr_utility.set_message_token('SYSTYPE', p_expected_sys_type);
      hr_utility.raise_error;
    end if;
 if g_debug then
    hr_utility.set_location(l_proc,70);
 end if;
  end if;
end chk_person_type;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_person_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_all_people_f         per
     where per.person_id         = p_person_id
       and pbg.business_group_id = per.business_group_id
  order by per.effective_start_date;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72) ;
begin
 if g_debug then
   l_proc :=  g_package||'return_legislation_code';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- HR/TCA merge allows person_id to be null
  --
  if p_person_id is null then
    g_person_id := p_person_id;
    l_legislation_code := NULL;
 if g_debug then
    hr_utility.set_location(l_proc, 15);
 end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  --hr_api.mandatory_arg_error(p_api_name       => l_proc,
  --                          p_argument       => 'person_id',
  --                         p_argument_value => p_person_id);
  --
  else
  if nvl(g_person_id, hr_api.g_number) = p_person_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
 if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
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
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 end if;
  --
    g_person_id := p_person_id;
    g_legislation_code := l_legislation_code;
  end if;
  end if;  -- HR/TCA merge
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 25);
 end if;
  --
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_system_pers_type>---------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_system_pers_type
  (p_person_id              in number
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ,p_datetrack_mode         in varchar2
  ,p_effective_date         in date
  )
  is
--
   l_exists         varchar2(1);
   l_person_type    varchar2(30);
   l_proc           varchar2(72)  :=  g_package||'chk_system_pers_type';
--
   cursor csr_get_system_person_type is
     select   ppt.system_person_type
     from     per_all_people_f ppf
     ,        per_person_types ppt
     where    p_effective_date between ppf.effective_start_date
                                   and ppf.effective_end_date
     and      ppf.person_id = p_person_id
     and      ppt.person_type_id = ppf.person_type_id;
--
   cursor csr_chk_future_changes is
     select   null
     from     sys.dual
     where exists(select   null
                  from     per_all_people_f ppf
                  ,        per_person_types ppt
                  where    ppf.effective_start_date between
                                                    p_validation_start_date
                                                and p_validation_end_date
                  and      ppf.person_id = p_person_id
                  and      ppt.person_type_id = ppf.person_type_id
                  and      ppt.system_person_type <> l_person_type);

--
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 1);
 end if;
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_id'
    ,p_argument_value => p_person_id
    );
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
 if g_debug then
  hr_utility.set_location(l_proc, 2);
 end if;
  --
  -- Get current value for system_person_type (i.e. as of the
  -- effective date)
  --
  open csr_get_system_person_type;
  fetch csr_get_system_person_type into l_person_type;
  close csr_get_system_person_type;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 3);
 end if;
  --
  -- Check that no future changes exist for the person type
  --
  open csr_chk_future_changes;
  fetch csr_chk_future_changes into l_exists;
  if csr_chk_future_changes%found then
    close csr_chk_future_changes;
    hr_utility.set_message(801, 'HR_7979_PER_SYS_PERS_TYP_CHANG');
    hr_utility.raise_error;
  end if;
  close csr_chk_future_changes;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 4);
 end if;
end chk_system_pers_type;
--
end per_per_bus;

/
