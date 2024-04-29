--------------------------------------------------------
--  DDL for Package Body PER_ABB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABB_BUS" as
/* $Header: peabbrhi.pkb 120.3 2006/03/03 06:26 bshukla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_abb_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_absence_attendance_type_id  number         default null;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_absence_attendance_type_id           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code,abb.business_group_id
      from per_business_groups_perf pbg
         , per_absence_attendance_types abb
     where abb.absence_attendance_type_id = p_absence_attendance_type_id
       and pbg.business_group_id(+) = abb.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_business_group_id per_business_groups.business_group_id%type;
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
    ,p_argument           => 'absence_attendance_type_id'
    ,p_argument_value     => p_absence_attendance_type_id
    );
  --
  if ( nvl(per_abb_bus.g_absence_attendance_type_id, hr_api.g_number)
       = p_absence_attendance_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_abb_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code, l_business_group_id;
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
    if l_business_group_id is not null then
      per_abb_bus.g_absence_attendance_type_id  := p_absence_attendance_type_id;
      per_abb_bus.g_legislation_code  := l_legislation_code;
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_absence_type_dates >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates that date_effective is supplied.
--   Must be earlier than date_end
--   If updating, cannot be later than date_start of child row in PER_ABSENCE_ATTENDANCES
--
-- Prerequisites:
--
-- In Arguments:
--   p_absence_attendance_type_id
--   p_object_version_number
--   p_date_effective
--   p_date_end
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--   An application error is raised and processing is terminated.
--
--
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_absence_type_dates
  (p_absence_attendance_type_id   in   per_absence_attendance_types.absence_attendance_type_id%type
  ,p_object_version_number        in   per_absence_attendance_types.object_version_number%type
  ,p_date_effective               in   per_absence_attendance_types.date_effective%type
  ,p_date_end                     in   per_absence_attendance_types.date_end%type
  ) is
  --
  l_proc   varchar2(72) := g_package || 'chk_absence_type_dates';
  l_api_updating     boolean;
  --
  cursor csr_chk_attendance_date is
  select 1
  from per_absence_attendances
  where absence_attendance_type_id = p_absence_attendance_type_id
  and   date_start < p_date_effective;
  --
  l_dummy  number;
  --
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'date_effective'
    ,p_argument_value => p_date_effective
    );
  --
  l_api_updating := per_abb_shd.api_updating
         (p_absence_attendance_type_id  => p_absence_attendance_type_id
         ,p_object_version_number  => p_object_version_number);
  --
  --  Only proceed with validation if:
  --  a) rec is being inserted or
  --  b) rec is updating and the g_old_rec is not current value
  --
  if ( (l_api_updating and (p_date_effective <> per_abb_shd.g_old_rec.date_effective
                           or p_date_end <> per_abb_shd.g_old_rec.date_end))
      or not l_api_updating) then
      --
      if p_date_effective > nvl (p_date_end,hr_api.g_eot) then
         fnd_message.set_name('PER','PER_7003_ALL_DATE_FROM_TO');
         fnd_message.raise_error;
      end if;
      --
      if l_api_updating then
        open csr_chk_attendance_date;
        fetch csr_chk_attendance_date into l_dummy;
        if csr_chk_attendance_date%found then
          close csr_chk_attendance_date;
          fnd_message.set_name('PER','HR_6790_ABS_NO_CHANGE_2');
         fnd_message.raise_error;
        else
          close csr_chk_attendance_date;
        end if;
      end if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ABSENCE_ATTENDANCE_TYPES.DATE_EFFECTIVE'
      ,p_associated_column2      => 'PER_ABSENCE_ATTENDANCE_TYPES.DATE_END'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_absence_type_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_input_value_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates input_value_id
--   Must be null if BG is null
--   Once it is not null, it cannot be changed.
--   Must correspond to a row on pay_input_values_f on both date_effective and date_end
--   Must correspond to an element type of processing type N,
--          or processing type R with not null proration group
--
-- Prerequisites:
--   Valid business_group_id
--
-- In Arguments:
--  p_absence_attendance_type_id
--  p_object_version_number
--  p_business_group_id
--  p_input_value_id
--  p_date_effective
--  p_date_end
--
-- Post Success:
--     Processing continues
--
-- Post Failure:
--     An application error is raised and processing terminates.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_input_value_id
  (p_absence_attendance_type_id   in   per_absence_attendance_types.absence_attendance_type_id%type
  ,p_object_version_number        in   per_absence_attendance_types.object_version_number%type
  ,p_date_effective               in   per_absence_attendance_types.date_effective%type
  ,p_date_end                     in out nocopy  per_absence_attendance_types.date_end%type
  ,p_input_value_id               in   per_absence_attendance_types.input_value_id%type
  ,p_business_group_id            in   per_absence_attendance_types.business_group_id%type
  ) is
  --
  l_proc   varchar2(72) := g_package || 'chk_input_value_id';
  l_api_updating     boolean;
  l_dummy  number;
  l_date_end date := p_date_end;
  l_input_end date;
  --
  cursor csr_valid_input_value_bg is
  select 1
  from pay_input_values_f piv1, per_business_groups_perf pbg
  where piv1.input_value_id = p_input_value_id
  and   pbg.business_group_id = p_business_group_id
  and   nvl(piv1.business_group_id,p_business_group_id) = p_business_group_id
  and   nvl(piv1.legislation_code,pbg.legislation_code) = pbg.legislation_code;
  --
  cursor csr_input_end is
  select max(effective_end_date)
  from   pay_input_values_f
  where  input_value_id = p_input_value_id;
  --
  cursor csr_valid_input_value_dates is
  select 1
  from pay_input_values_f piv1, per_business_groups_perf pbg
  where piv1.input_value_id = p_input_value_id
  and   p_date_effective between piv1.effective_start_date and piv1.effective_end_date
  and   exists  (select 1
                 from   pay_input_values_f piv2
                 where  piv1.input_value_id = piv2.input_value_id
                 and    nvl(l_date_end,hr_api.g_eot) between
                        piv2.effective_start_date and piv2.effective_end_date);
  --
  cursor csr_valid_input_value_uom is
  select 1
  from pay_input_values_f piv1, per_business_groups_perf pbg
  where piv1.input_value_id = p_input_value_id
  and   piv1.uom in ('ND','H_HH','H_DECIMAL1','H_DECIMAL2','H_DECIMAL3')
  and   p_date_effective between piv1.effective_start_date and piv1.effective_end_date;
  --
  cursor csr_valid_element_type is
  select 1
  from  pay_element_types_f pet, pay_input_values_f piv
  where p_input_value_id = piv.input_value_id
  and   p_date_effective between piv.effective_start_date and piv.effective_end_date
  and   piv.element_type_id = pet.element_type_id
  and   p_date_effective between pet.effective_start_date and pet.effective_end_date
  and   (    pet.processing_type = 'N'
         or (pet.processing_type= 'R' and pet.proration_group_id is not null));
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'PER_ABSENCE_ATTENDANCE_TYPES.DATE_EFFECTIVE'
     ,p_check_column2      =>  'PER_ABSENCE_ATTENDANCE_TYPES.DATE_END'
     ) then
    --
    l_api_updating := per_abb_shd.api_updating
           (p_absence_attendance_type_id  => p_absence_attendance_type_id
           ,p_object_version_number  => p_object_version_number);
    --
    --
    --  Only proceed with validation if:
    --  a) rec is being inserted or
    --  b) rec is updating and the g_old_rec is not current value
    --
    if ( (l_api_updating and
         ( nvl(per_abb_shd.g_old_rec.input_value_id,-1) <> nvl(p_input_value_id,-1)
          or   per_abb_shd.g_old_rec.date_effective <> p_date_effective
          or nvl(per_abb_shd.g_old_rec.date_end,hr_api.g_eot) <>
                 nvl(p_date_end,hr_api.g_eot)))
        or not l_api_updating)
    then
      --
      hr_utility.set_location(l_proc,20);
      --
      -- input value cannot be specified unless BG is specified
      --
      if p_business_group_id is null
      and p_input_value_id is not null then
	fnd_message.set_name('PER','PER_449173_ABB_NO_BG_NO_INPUT');
		fnd_message.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc,30);
      --
      -- input value cannot change once it is not null
      --
      if (p_input_value_id is not null
	  and p_input_value_id <> nvl(per_abb_shd.g_old_rec.input_value_id,p_input_value_id))
      or  (p_input_value_id is null and per_abb_shd.g_old_rec.input_value_id is not null)
      then
	fnd_message.set_name('PER','PER_449174_ABB_NO_CHANGE_INPUT');
	fnd_message.raise_error;
      end if;
      --
      if p_input_value_id is not null then
      --
	open csr_valid_input_value_bg;
	fetch csr_valid_input_value_bg into l_dummy;
	if csr_valid_input_value_bg%notfound then
	  close csr_valid_input_value_bg;
	  fnd_message.set_name('PER','PER_449182_ABB_INPUT_WRONG_BG');
	  fnd_message.raise_error;
	else
	  close csr_valid_input_value_bg;
	end if;
	--
	hr_utility.set_location(l_proc,40);
	--
        open csr_input_end;
        fetch csr_input_end into l_input_end;
        close csr_input_end;
        --
        if p_date_end is null
        and l_input_end < hr_api.g_eot then
           l_date_end := l_input_end;   --auto-populate date_end if input has end date
        elsif p_date_end is not null
        and p_date_end > l_input_end then
           fnd_message.set_name('PER','PER_7800_DEF_ABS_ELEMENT_ENDS');
           fnd_message.raise_error;
        end if;
        --
	open csr_valid_input_value_dates;
	fetch csr_valid_input_value_dates into l_dummy;
	if csr_valid_input_value_dates%notfound then
	  close csr_valid_input_value_dates;
	  fnd_message.set_name('PER','PER_449176_ABB_INPUT_NOT_EXIST');
	  fnd_message.raise_error;
	else
	  close csr_valid_input_value_dates;
	end if;
	--
	hr_utility.set_location(l_proc,50);
	--
	open csr_valid_input_value_uom;
	fetch csr_valid_input_value_uom into l_dummy;
	if csr_valid_input_value_uom%notfound then
	  close csr_valid_input_value_uom;
	  fnd_message.set_name('PER','PER_449175_ABB_INPUT_WRONG_UOM');
	  fnd_message.raise_error;
	else
	  close csr_valid_input_value_uom;
	end if;
	--
	hr_utility.set_location(l_proc,60);
	--
	open csr_valid_element_type;
	fetch csr_valid_element_type into l_dummy;
	if csr_valid_element_type%notfound then
	  close csr_valid_element_type;
	  fnd_message.set_name('PER','PER_449177_ABB_INPUT_ELE_TYPE');
	  fnd_message.raise_error;
	else
	  close csr_valid_element_type;
	end if;
	--
	hr_utility.set_location(l_proc,70);
	--
      end if;  --input_value_id is not null
    end if;   --api_updating check
  end if;  --no_all_inclusive_error check
  --
  hr_utility.set_location('Leaving:'||l_proc,80);
  --
  --set the OUT arguments
  --
  p_date_end := l_date_end;
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ABSENCE_ATTENDANCE_TYPES.DATE_EFFECTIVE'
      ,p_associated_column2      => 'PER_ABSENCE_ATTENDANCE_TYPES.DATE_END'
      ,p_associated_column3      => 'PER_ABSENCE_ATTENDANCE_TYPES.INPUT_VALUE_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 90);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,100);
end chk_input_value_id;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_abs_overlap_flag >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the value of Absence Overlap Flag.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_absence_overlap_flag
--
-- Post Success:
--   None.
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_abs_overlap_flag
  (
   p_absence_overlap_flag  in  per_absence_attendance_types.absence_overlap_flag %TYPE
  )
      is
  --

  --
  l_proc          varchar2(72) := g_package||'chk_abs_overlap_flag';
  l_api_updating  boolean;
  l_absence_overlap_flag   varchar2(10);

    cursor csr_abs_overlap_flag(p_absence_overlap_flag varchar2)
    is
    select 'X'
    from   hr_lookups
    where  lookup_type = 'YES_NO'
    and    lookup_code = p_absence_overlap_flag;


  --
  begin
  hr_utility.set_location('Entering:'||l_proc, 5);

    open csr_abs_overlap_flag(p_absence_overlap_flag);
    fetch csr_abs_overlap_flag into l_absence_overlap_flag;
    if csr_abs_overlap_flag%notfound then
    close csr_abs_overlap_flag;

    hr_utility.set_message(800, 'HR_449758_INVL_ABS_OVERLAP_FLG');
    hr_utility.set_message_token('OBJECT', 'ABSENCE_OVERLAP_FLAG');
    hr_utility.set_message_token('TABLE', 'HR_LOOKUPS');
    hr_utility.set_message_token('CONDITION', 'lookup type "YES_NO"');

    hr_utility.set_location(l_proc, 10);
    --
    else
    close csr_abs_overlap_flag;
    end if;
    hr_utility.set_location(l_proc, 20);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_same_associated_columns =>  'Y'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_abs_overlap_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_inc_or_dec_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates increasing_or_decreasing_flag
--     Must be null is input_value_id is null
--     Must have value 'I' or 'D' if not null
--     Once it is not null it cannot be changed
--
-- Prerequisites:
--   input_value_id is valid
--
-- In Arguments:
-- p_absence_attendance_type_id
-- p_object_version_number
-- p_input_value_id
-- p_inc_or_dec_flag
--
-- Post Success:
--   Processing Continues
--
-- Post Failure:
--   An application error is raised and processing terminates.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_inc_or_dec_flag
  (p_absence_attendance_type_id   in   per_absence_attendance_types.absence_attendance_type_id%type
  ,p_object_version_number        in   per_absence_attendance_types.object_version_number%type
  ,p_input_value_id               in   per_absence_attendance_types.input_value_id%type
  ,p_inc_or_dec_flag              in   per_absence_attendance_types.increasing_or_decreasing_flag%type
  ) is
  --
  l_proc   varchar2(72) := g_package || 'chk_inc_or_dec_flag';
  l_api_updating     boolean;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating := per_abb_shd.api_updating
         (p_absence_attendance_type_id  => p_absence_attendance_type_id
         ,p_object_version_number  => p_object_version_number);
  --
  --
  --  Only proceed with validation if:
  --  a) rec is being inserted or
  --  b) rec is updating and the g_old_rec is not current value
  --
  if (l_api_updating and
        (  nvl(per_abb_shd.g_old_rec.increasing_or_decreasing_flag,hr_api.g_varchar2) <>
           nvl(p_inc_or_dec_flag,hr_api.g_varchar2)
        or nvl(per_abb_shd.g_old_rec.input_value_id,-1) <> nvl(p_input_value_id,-1))
      or not l_api_updating)
  then
    --
    if p_input_value_id is null then
      if p_inc_or_dec_flag is not null then
        fnd_message.set_name('PER','PER_449183_ABB_NO_INPUT_NO_INC');
        fnd_message.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc,20);
      --
    else
      -- input_value_id is not null so inc_or_dec_flag must be specified
      --
      if nvl(p_inc_or_dec_flag,hr_api.g_varchar2) not in ('I','D') then
        fnd_message.set_name('PER','HR_7583_ALL_MAN_INC_FIELD');
        fnd_message.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc,30);
      --
      if l_api_updating
      and per_abb_shd.g_old_rec.increasing_or_decreasing_flag is not null
      and nvl(p_inc_or_dec_flag,hr_api.g_varchar2) <>
          per_abb_shd.g_old_rec.increasing_or_decreasing_flag then
        --
        --flag must not be changed once it is not null
        --
        fnd_message.set_name('PER','PER_449178_ABB_NO_CHANGE_INC');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,70);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ABSENCE_ATTENDANCE_TYPES.INCREASING_OR_DECREASING_FLAG'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 80);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,90);
end chk_inc_or_dec_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_hours_or_days >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates hours_or_days
--     Must be null if input_Value_id is null
--     Once it is not null, it cannot be changed
--     Value must be one of 'D','H'
--
-- Prerequisites:
--   Valid input_value_id
--
-- In Arguments:
-- p_absence_attendance_type_id
-- p_object_version_number
-- p_input_value_id
-- p_hours_or_days
--
-- Post Success:
--  Processing continues
--
-- Post Failure:
--  An application error is raised and processing is terminated
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_hours_or_days
  (p_absence_attendance_type_id   in   per_absence_attendance_types.absence_attendance_type_id%type
  ,p_object_version_number        in   per_absence_attendance_types.object_version_number%type
  ,p_input_value_id               in   per_absence_attendance_types.input_value_id%type
  ,p_hours_or_days           in   per_absence_attendance_types.hours_or_days%type
  ,p_date_effective               in   per_absence_attendance_types.date_effective%type
  ) is
  --
  l_proc   varchar2(72) := g_package || 'chk_hours_or_days';
  l_api_updating     boolean;
  l_input_uom        pay_input_values_f.uom%type;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'PER_ABSENCE_ATTENDANCE_TYPES.INPUT_VALUE_ID'
     ) then
    --
    --
    l_api_updating := per_abb_shd.api_updating
	   (p_absence_attendance_type_id  => p_absence_attendance_type_id
	   ,p_object_version_number  => p_object_version_number);
    --
    --
    --  Only proceed with validation if:
    --  a) rec is being inserted or
    --  b) rec is updating and the g_old_rec is not current value
    --
    if (l_api_updating and
	  (  nvl(per_abb_shd.g_old_rec.hours_or_days,hr_api.g_varchar2) <>
	     nvl(p_hours_or_days,hr_api.g_varchar2)
	  or nvl(per_abb_shd.g_old_rec.input_value_id,-1) <> nvl(p_input_value_id,-1))
	or not l_api_updating)
    then
      --
      if p_input_value_id is null then
	if p_hours_or_days is not null then
	  fnd_message.set_name('PER','PER_449184_ABB_NO_INPUT_NO_HOU');
	  fnd_message.raise_error;
	end if;
	--
      else         -- input_value_id is not null
	hr_utility.set_location(l_proc,20);
	--
	if l_api_updating
        and per_abb_shd.g_old_rec.hours_or_days is not null
        and nvl(p_hours_or_days,hr_api.g_varchar2) <>
	    per_abb_shd.g_old_rec.hours_or_days then
	  --
	  --flag must not be changed once it is not null
	  --
	  fnd_message.set_name('PER','PER_449179_ABB_NO_CHANGE_HOURS');
	  fnd_message.raise_error;
	end if;
	--
	hr_utility.set_location(l_proc,30);
	--
        -- flag must have the correct value (uom of input value is already validated)
        --
        if p_hours_or_days is null
        or p_hours_or_days not in ('D','H') then
          fnd_message.set_name('PER','PER_449180_ABB_HOURS_WRONG_UOM');
	  fnd_message.raise_error;
        end if;
      end if;  --input_value_id is null check
      --
    end if;   --api updating check
  end if;  --no_all_inclusive_error
  hr_utility.set_location('Leaving:'||l_proc,70);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ABSENCE_ATTENDANCE_TYPES.HOURS_OR_DAYS'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 80);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,90);
  --
end chk_hours_or_days;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_absence_category >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates absence_category
--     Must exist as enabled lookup_code for lookup_type 'ABSENCE_CATEGORY'
--     Value cannot be changed once it is not null if there is a chile record in
--       per_absence_attendances
--
-- Prerequisites:
--
--
-- In Arguments:
--  p_absence_attendance_type_id
--  p_object_version_number
--  p_date_effective
--  p_absence_category
--
-- Post Success:
--  Processing continues
--
-- Post Failure:
--  An application error is raised and processing is terminated
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_absence_category
  (p_absence_attendance_type_id   in   per_absence_attendance_types.absence_attendance_type_id%type
  ,p_object_version_number        in   per_absence_attendance_types.object_version_number%type
  ,p_date_effective               in   per_absence_attendance_types.date_effective%type
  ,p_absence_category             in   per_absence_attendance_types.absence_category%type
  ) is
  --
  l_proc   varchar2(72) := g_package || 'chk_absence_category';
  l_api_updating     boolean;
  --
  cursor csr_absence_attendance is
  select 1
  from   per_absence_attendances
  where  absence_attendance_type_id = p_absence_attendance_type_id;
  --
  l_dummy  number;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating := per_abb_shd.api_updating
    (p_absence_attendance_type_id  => p_absence_attendance_type_id
    ,p_object_version_number  => p_object_version_number);
  --
  --
  --  Only proceed with validation if:
  --  a) rec is being inserted or
  --  b) rec is updating and the g_old_rec is not current value
  --
  if (l_api_updating and
        (nvl(per_abb_shd.g_old_rec.absence_category,hr_api.g_varchar2) <>  nvl(p_absence_category,hr_api.g_varchar2))
  or not l_api_updating)
  then
    --
    hr_utility.set_location(l_proc,20);
    --
    if p_absence_category is not null
    and hr_api.not_exists_in_leg_lookups
       (p_effective_date        => p_date_effective
       ,p_lookup_type           => 'ABSENCE_CATEGORY'
       ,p_lookup_code           => p_absence_category
        )
    then
      --
      fnd_message.set_name('PER','PER_449185_ABB_CAT_NOT_EXIST');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,30);
    --
    if l_api_updating then
      open csr_absence_attendance;
      fetch csr_absence_attendance into l_dummy;
      --
      if csr_absence_attendance%found
      and per_abb_shd.g_old_rec.absence_category is not null
      and per_abb_shd.g_old_rec.absence_category <>
	  nvl(p_absence_category,hr_api.g_varchar2)
      then
	close csr_absence_attendance;
	  fnd_message.set_name('PER','HR_6383_ABS_DET_NO_CHANGE');
	  fnd_message.raise_error;
      else
	hr_utility.set_location(l_proc,40);
	--
	close csr_absence_attendance;
      end if;
      --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,70);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'PER_ABSENCE_ATTENDANCE_TYPES.ABSENCE_CATEGORY'
       ) then
        hr_utility.set_location(' Leaving:'||l_proc, 80);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,90);
  --
end chk_absence_category;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_information_category >------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates information_category
--     Must be null if business_group_id is null
--     If not null, must correspond to the legislation of the BG, and an enabled
--       context of DDF 'Absence Type Developer DF'
--
-- Prerequisites:
--
-- In Arguments:
--  p_absence_attendance_type_id
--  p_object_version_number
--  p_business_group_id
--
-- Post Success:
--    If p_information_category is not null and it matches the legislation
--    corresponding to the business group then the process succeeds.
--    If p_information_category is null and a valid DDF context exists for
--    the legislation of the business group, then the corresponding legislation
--    is set for p_per_information_category
--
-- Post Failure:
--  An application error is raised and processing is terminated.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_information_category
  (p_absence_attendance_type_id   in   per_absence_attendance_types.absence_attendance_type_id%type
  ,p_object_version_number        in   per_absence_attendance_types.object_version_number%type
  ,p_business_group_id            in   per_absence_attendance_types.business_group_id%type
  ,p_information_category         in out nocopy per_absence_attendance_types.information_category%type
  ) is
  --
  l_proc   varchar2(72) := g_package || 'chk_information_category';
  l_api_updating     boolean;
  l_dummy    number;
  l_leg      per_business_groups.legislation_code%TYPE;
  --
  cursor csr_bg_legislation is
  select legislation_code
  from   per_business_groups pbg
  where  business_group_id = p_business_group_id;
  --
  cursor csr_ddf_exist(p_legislation_code varchar2) is
  select 1
  from fnd_descr_flex_contexts fdfc
  where fdfc.application_id = 800
  and fdfc.descriptive_flexfield_name = 'Absence Type Developer DF'
  and fdfc.enabled_flag = 'Y'
  and fdfc.descriptive_flex_context_code = p_legislation_code;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating := per_abb_shd.api_updating
    (p_absence_attendance_type_id  => p_absence_attendance_type_id
    ,p_object_version_number  => p_object_version_number);
  --
  --
  --  Only proceed with validation if:
  --  a) rec is being inserted or
  --  b) rec is updating and the g_old_rec is not current value
  --
  if (l_api_updating and
        (nvl(per_abb_shd.g_old_rec.information_category,hr_api.g_varchar2) <>  nvl(p_information_category,hr_api.g_varchar2))
  or not l_api_updating)
  then
    --
    hr_utility.set_location(l_proc,10);
    --
    if p_information_category is not null then
      if p_business_group_id is null then
	fnd_message.set_name('PER','PER_449181_ABB_INFO_CAT_BG');
	fnd_message.raise_error;
      else
        --
        hr_utility.set_location(l_proc,20);
        --
	open csr_bg_legislation;
	fetch csr_bg_legislation into l_leg;
	close csr_bg_legislation;
	--
	if p_information_category <> l_leg then
	  fnd_message.set_name('PER','PER_449186_ABB_INF_CAT_LEG');
	  fnd_message.raise_error;
	end if;
        --
      end if;
    else
      if p_business_group_id is not null then
        --
        hr_utility.set_location(l_proc,30);
        --
	open csr_bg_legislation;
	fetch csr_bg_legislation into l_leg;
	close csr_bg_legislation;
	--
	open csr_ddf_exist(l_leg);
	fetch csr_ddf_exist into l_dummy;
	if csr_ddf_exist%found then
	  close csr_ddf_exist;
          --
          hr_utility.set_location(l_proc,40);
          --
	  p_information_category := l_leg;
	else
	  close csr_ddf_exist;
          --
          hr_utility.set_location(l_proc,50);
          --
	  p_information_category := null;
	end if;
      else
       --
       hr_utility.set_location(l_proc,60);
       --
       p_information_category := null;
      end if;
      --
    end if;  -- p_information_category is not null
    --
  end if;  --api updating
  --
  hr_utility.set_location('Leaving:'||l_proc,70);
  --
end chk_information_category;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_absence_type_delete >------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Checks if deletion of the absence type will be allowed.
--     Must be no records referencing absence type on the following tables.
--       per_abs_attendance_reasons, per_absence_attendances
--
-- Prerequisites:
--
-- In Arguments:
--  p_absence_attendance_type_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--  An application error is raised and processing is terminated.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_absence_type_delete
  (p_absence_attendance_type_id   in   per_absence_attendance_types.absence_attendance_type_id%type
  ) is
  --
  l_proc   varchar2(72) := g_package || 'chk_absence_type_delete';
  l_dummy    number;
  --
  cursor csr_attendance is
  select 1
  from   per_absence_attendances
  where  absence_attendance_type_id = p_absence_attendance_type_id;
  --
  cursor csr_reason is
  select 1
  from  per_abs_attendance_reasons
  where absence_attendance_type_id = p_absence_attendance_type_id;
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  open csr_attendance;
  fetch csr_attendance into l_dummy;
  if csr_attendance%found then
    close csr_attendance;
    fnd_message.set_name('PER','PER_7059_EMP_ABS_DEL_TYPE');
    fnd_message.raise_error;
  else
    close csr_attendance;
  end if;
  --
  hr_utility.set_location(l_proc,20);
  --
  open csr_reason;
  fetch csr_reason into l_dummy;
  if csr_reason%found then
    close csr_reason;
    fnd_message.set_name('PER','PER_7805_DEF_ABS_DEL_REASON');
    fnd_message.raise_error;
  else
    close csr_reason;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,30);
  --
end chk_absence_type_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in per_abb_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.absence_attendance_type_id is not null)  and (
    nvl(per_abb_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) ))
    or (p_rec.absence_attendance_type_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Absence Type Developer DF'
      ,p_attribute_category              => p_rec.information_category
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  (p_rec in per_abb_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.absence_attendance_type_id is not null)  and (
    nvl(per_abb_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_abb_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.absence_attendance_type_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_ABSENCE_ATTENDANCE_TYPES'
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
  (p_rec in per_abb_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_abb_shd.api_updating
      (p_absence_attendance_type_id        => p_rec.absence_attendance_type_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(per_abb_shd.g_old_rec.business_group_id,-1) <>
     nvl(p_rec.business_group_id,-1) then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if nvl(per_abb_shd.g_old_rec.information_category,hr_api.g_varchar2) <>
     nvl(p_rec.information_category,hr_api.g_varchar2) then
     l_argument := 'information_category';
     raise l_error;
  end if;
  --
  --
  hr_utility.set_location(l_proc, 30);
  --
  if per_abb_shd.g_old_rec.absence_attendance_type_id <>
     p_rec.absence_attendance_type_id then
     l_argument := 'absence_attendance_type_id';
     raise l_error;
  end if;
  --
hr_utility.set_location(' Leaving:'||l_proc, 40);
--
exception
  when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
  when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 90);
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in out nocopy per_abb_shd.g_rec_type
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
    hr_api.validate_bus_grp_id
      (p_business_group_id => p_rec.business_group_id
       );
  end if;
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  per_abb_bus.chk_absence_type_dates
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_date_effective               => p_rec.date_effective
     ,p_date_end                     => p_rec.date_end
     );
  --
  per_abb_bus.chk_input_value_id
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_date_effective               => p_rec.date_effective
     ,p_date_end                     => p_rec.date_end
     ,p_input_value_id               => p_rec.input_value_id
     ,p_business_group_id            => p_rec.business_group_id
     );
  --
  per_abb_bus.chk_inc_or_dec_flag
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_input_value_id               => p_rec.input_value_id
     ,p_inc_or_dec_flag              => p_rec.increasing_or_decreasing_flag
     );
  --
  per_abb_bus.chk_hours_or_days
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_input_value_id               => p_rec.input_value_id
     ,p_hours_or_days                => p_rec.hours_or_days
     ,p_date_effective               => p_rec.date_effective
     );
  --
  per_abb_bus.chk_absence_category
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_date_effective               => p_rec.date_effective
     ,p_absence_category             => p_rec.absence_category
     );
  --
  per_abb_bus.chk_information_category
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_business_group_id            => p_rec.business_group_id
     ,p_information_category         => p_rec.information_category
     );
  --
  per_abb_bus.chk_abs_overlap_flag
     (p_absence_overlap_flag => p_rec.absence_overlap_flag
   );
  --
  per_abb_bus.chk_ddf(p_rec);
  --
  per_abb_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in out nocopy per_abb_shd.g_rec_type
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
    hr_api.validate_bus_grp_id
      (p_business_group_id => p_rec.business_group_id
       );
  end if;
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  per_abb_bus.chk_absence_type_dates
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_date_effective               => p_rec.date_effective
     ,p_date_end                     => p_rec.date_end
     );
  --
  per_abb_bus.chk_input_value_id
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_date_effective               => p_rec.date_effective
     ,p_date_end                     => p_rec.date_end
     ,p_input_value_id               => p_rec.input_value_id
     ,p_business_group_id            => p_rec.business_group_id
     );
  --
  per_abb_bus.chk_inc_or_dec_flag
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_input_value_id               => p_rec.input_value_id
     ,p_inc_or_dec_flag              => p_rec.increasing_or_decreasing_flag
     );
  --
  per_abb_bus.chk_hours_or_days
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_input_value_id               => p_rec.input_value_id
     ,p_hours_or_days                => p_rec.hours_or_days
     ,p_date_effective               => p_rec.date_effective
     );
  --
  per_abb_bus.chk_absence_category
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_date_effective               => p_rec.date_effective
     ,p_absence_category             => p_rec.absence_category
     );
  --
  per_abb_bus.chk_information_category
     (p_absence_attendance_type_id   => p_rec.absence_attendance_type_id
     ,p_object_version_number        => p_rec.object_version_number
     ,p_business_group_id            => p_rec.business_group_id
     ,p_information_category         => p_rec.information_category
     );
  --
  per_abb_bus.chk_ddf(p_rec);
  --
  per_abb_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_abb_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_abb_bus.chk_absence_type_delete
     (p_absence_attendance_type_id =>  p_rec.absence_attendance_type_id
      );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_abb_bus;

/
