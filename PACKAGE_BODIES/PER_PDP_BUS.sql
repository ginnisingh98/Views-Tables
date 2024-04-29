--------------------------------------------------------
--  DDL for Package Body PER_PDP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PDP_BUS" as
/* $Header: pepdprhi.pkb 115.8 2004/01/29 05:53:10 adudekul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pdp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_period_of_placement_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_period_of_placement_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_periods_of_placement pdp
     where pdp.period_of_placement_id = p_period_of_placement_id
       and pbg.business_group_id = pdp.business_group_id;
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
    ,p_argument           => 'period_of_placement_id'
    ,p_argument_value     => p_period_of_placement_id
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
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'PERIOD_OF_PLACEMENT_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
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
  (p_period_of_placement_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_periods_of_placement pdp
     where pdp.period_of_placement_id = p_period_of_placement_id
       and pbg.business_group_id = pdp.business_group_id;
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
    ,p_argument           => 'period_of_placement_id'
    ,p_argument_value     => p_period_of_placement_id
    );
  --
  if ( nvl(per_pdp_bus.g_period_of_placement_id, hr_api.g_number)
       = p_period_of_placement_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pdp_bus.g_legislation_code;
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
    per_pdp_bus.g_period_of_placement_id      := p_period_of_placement_id;
    per_pdp_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ---------------------------------------------------------------------------
-- |--------------< return_period_of_placement_id >--------------------------|
-- ---------------------------------------------------------------------------
--
function return_period_of_placement_id
  (p_person_id                            in number
  ,p_date_start                           in date
  ) return number is

  cursor c_get_period_of_placement_id is
    select pdp.period_of_placement_id
    from   per_periods_of_placement pdp
    where  pdp.person_id = p_person_id
    and    pdp.date_start = p_date_start;

  l_proc  varchar2(72) := g_package||'return_period_of_placement_id';
  l_period_of_placement_id  number;

begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  open  c_get_period_of_placement_id;
  fetch c_get_period_of_placement_id into l_period_of_placement_id;
  close c_get_period_of_placement_id;

  if l_period_of_placement_id is null then
    --
    -- The record does not exist for the person_id / date_start
    -- combination. Raise an error.
    --
    fnd_message.set_name('PER','HR_289609_PDP_NOT_EXISTS');
    fnd_message.raise_error;
  end if;

  --
  -- Return the period_of_placement_id
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);

  return l_period_of_placement_id;

end return_period_of_placement_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_actual_termination_date >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Must be <= LAST_STANDARD_PROCESS_DATE (U)
--    b)      Must be >= DATE_START (U)
--    c)      Must be null (I)
--    d)      Cannot be changed from one not null value to another (U)
--    e)      Must be after initial insert date of last assignment (U)
--    f)      Must be after effective start date of last future change(s) (U)
--
--  Pre-conditions:
--    person_id, date_start, last_standard_process_date and period_of_placement_id
--    have been successfully validated separately.
--
--  In Arguments:
--    p_actual_termination_date
--    p_date_start
--    p_last_standard_process_date
--    p_object_version_number
--    p_period_of_placement_id
--    p_person_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_actual_termination_date
--
  (p_actual_termination_date    in date
  ,p_date_start                 in date
  ,p_last_standard_process_date in date
  ,p_object_version_number      in number
  ,p_period_of_placement_id     in number
  ,p_person_id                  in number
  ) is
--
   l_api_updating          boolean;
   l_no_data_found         boolean;
   l_effective_start_date  date;
   l_assignment_id         number;
   l_proc                  varchar2(72) := g_package||
                                           'chk_actual_termination_date';
   --
   cursor csr_get_max_asg_start_date is
     select min(asg.effective_start_date)
           ,assignment_id
     from   per_all_assignments_f asg
     where  asg.period_of_placement_date_start = p_date_start
     and    asg.person_id = p_person_id
     group by asg.assignment_id
     order by 1 desc;
   --
   cursor csr_get_max_per_eff_date is
     select max(per.effective_start_date)
     from   per_all_people_f per
     where  per.person_id = p_person_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Only proceed with validation when the Multiple Message List
  -- does not already contain an error associated with the
  -- below columns.
  --

  if hr_multi_message.no_exclusive_error
       (p_check_column1      => per_pdp_shd.g_tab_nam||
                               '.LAST_STANDARD_PROCESS_DATE'
       ,p_associated_column1 => per_pdp_shd.g_tab_nam||
                               '.LAST_STANDARD_PROCESS_DATE'
       ) then

  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pdp_shd.api_updating
         (p_period_of_placement_id  => p_period_of_placement_id
         ,p_object_version_number   => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  if l_api_updating
  then
    --
    if  nvl(per_pdp_shd.g_old_rec.actual_termination_date, hr_api.g_date) <>
        nvl(p_actual_termination_date, hr_api.g_date)
    and p_actual_termination_date is not null
    then
      hr_utility.set_location(l_proc, 40);
      --
      if per_pdp_shd.g_old_rec.actual_termination_date is not null
      then
        --
        -- Cannot be changed from one not null value to another not null value.
        -- CHK_ACTUAL_TERMINATION_DATE / d
        --
        hr_utility.set_message(801,'HR_7955_PDS_INV_ATT_CHANGE');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 60);
      --
      if p_actual_termination_date > p_last_standard_process_date and
        p_last_standard_process_date is not null                 then
        --
        -- CHK_ACTUAL_TERMINATION_DATE / a
        --
        hr_utility.set_message(801,'HR_7505_PDS_INV_LSP_ATT_DT');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 70);
      --
      if not (nvl(p_actual_termination_date, hr_api.g_eot) >=
              p_date_start) then
        --
        -- CHK_ACTUAL_TERMINATION_DATE / b
        --
        hr_utility.set_message(801,'HR_7493_PDS_INV_ATT_DT_ST');
        hr_utility.raise_error;
      end if;
      hr_utility.set_location(l_proc, 80);
      --
      -- Get the initial insert date of the latest assignment.
      --
      open csr_get_max_asg_start_date;
      fetch csr_get_max_asg_start_date
       into l_effective_start_date
          , l_assignment_id;
      --
      if csr_get_max_asg_start_date%NOTFOUND then
        --
        close csr_get_max_asg_start_date;
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '5');
        hr_utility.raise_error;
        --
      elsif (p_actual_termination_date < l_effective_start_date) then
        --
        -- CHK_ACTUAL_TERMINATION_DATE / e
        --
        close csr_get_max_asg_start_date;
        hr_utility.set_message(801,'HR_7956_PDS_INV_ATT_DT_EARLY');
        hr_utility.raise_error;
      end if;
      close csr_get_max_asg_start_date;
      hr_utility.set_location(l_proc, 110);
      --
      -- Get the latest effective start date for any person future changes.
      --
      open csr_get_max_per_eff_date;
      fetch csr_get_max_per_eff_date
       into l_effective_start_date;
      close csr_get_max_per_eff_date;
      --
      if l_effective_start_date is null then
        --
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '10');
        hr_utility.raise_error;
        --
      elsif not (p_actual_termination_date >= l_effective_start_date) then
        --
        -- CHK_ACTUAL_TERMINATION_DATE / f
        --
        hr_utility.set_message(801,'HR_7957_PDS_INV_ATT_FUTURE');
        hr_utility.raise_error;
      end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 120);

end if; -- end multi_message if

exception
  --
  -- When Multiple Error Detection is enabled handle the Application Errors
  -- which have been raised by this procedure. Transfer the error to the
  -- Multiple Message List and associate the error with the above columns.
  --
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_same_associated_columns => 'Y'
        ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 130);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 140);

end chk_actual_termination_date;
--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_date_start >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Mandatory (I,U)
--    NB:     The unique combination of person_id and date_start is validated
--            via rule CHK_PERSON_ID_DATE_START.
--
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_date_start
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_date_start
--
  (p_date_start   in date) is
--
   l_proc           varchar2(72)  :=  g_package||'chk_date_start';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- CHK_DATE_START / a
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => per_pdp_shd.g_tab_nam||'.DATE_START'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

end chk_date_start;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_projected_term_date >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a) p_projected_termination_date is less than p_date_start (I,U)
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_date_start
--    p_projected_termination_date
--    p_object_version_number
--    p_period_of_placement_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_projected_term_date
  (p_date_start                 in date
  ,p_projected_termination_date in date
  ,p_object_version_number      in number
  ,p_period_of_placement_id     in number) is
--
   l_proc           varchar2(72)  :=  g_package||'chk_projected_term_date';
   l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pdp_shd.api_updating
         (p_period_of_placement_id => p_period_of_placement_id
         ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location('Entering:'|| l_proc, 20);
  --
  if (l_api_updating
        AND (nvl(per_pdp_shd.g_old_rec.projected_termination_date, hr_api.g_date) <>
             nvl(p_projected_termination_date, hr_api.g_date)))
     OR not l_api_updating
  then
      if nvl(p_projected_termination_date,hr_api.g_eot) < p_date_start
        then
        --
        -- CHK_PROJECTED_TERM_DATE / a
        --
        hr_utility.set_message(800,'HR_289745_ERR_PLACEMENT_DATE');
        hr_utility.raise_error;
      end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => per_pdp_shd.g_tab_nam||'.PROJECTED_TERMINATION_DATE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_projected_term_date;
--
--  ---------------------------------------------------------------------------
--  |------------------------<chk_final_process_date >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      If the person is not assigned to any payrolls then
--            must be equal to ACTUAL_TERMINATION_DATE (U)
--    b)      If the person is assigned to a payroll then
--            must equal the maximum period end date of all Assignments
--            for the current Period of Placement (U)
--    c)      Must be >= LAST_STANDARD_PROCESS_DATE (U)
--    d)      If ACTUAL_TERMINATION_DATE is null then must be null (U)
--    e)      Must be null (I)
--
--  Pre-conditions:
--    p_date_start, actual_termination_date, last_standard_process_date and
--    period_of_placement_id have been successfully validated separately.
--
--  In Arguments:
--    p_actual_termination_date
--    p_date_start
--    p_final_process_date
--    p_last_standard_process_date
--    p_object_version_number
--    p_period_of_placement_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_final_process_date
  (p_actual_termination_date    in date,
   p_date_start                 in date,
   p_final_process_date         in date,
   p_last_standard_process_date in date,
   p_object_version_number      in number,
   p_period_of_placement_id     in number) is
--
   l_assigned_payroll boolean;
   l_api_updating     boolean;
   l_max_end_date     date;
   l_proc             varchar2(72)  :=  g_package||'chk_final_process_date';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  --
  -- Only proceed with validation when the Multiple Message List
  -- does not already contain an error associated with the
  -- below columns.
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => per_pdp_shd.g_tab_nam||
                               '.LAST_STANDARD_PROCESS_DATE'
       ,p_check_column2      => per_pdp_shd.g_tab_nam||
                               '.ACTUAL_TERMINATION_DATE'
       ,p_associated_column1 => per_pdp_shd.g_tab_nam||
                               '.LAST_STANDARD_PROCESS_DATE'
       ,p_associated_column2 => per_pdp_shd.g_tab_nam||
                               '.ACTUAL_TERMINATION_DATE'
       ) then

  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pdp_shd.api_updating
         (p_period_of_placement_id => p_period_of_placement_id
         ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 5);
  --
  if l_api_updating
  then
    --
    if nvl(per_pdp_shd.g_old_rec.final_process_date, hr_api.g_date) <>
       nvl(p_final_process_date, hr_api.g_date)
    then
      --
      hr_utility.set_location(l_proc, 6);
      --
      --
      if  per_pdp_shd.g_old_rec.final_process_date is not null
      and p_final_process_date is not null
      then
        -- CHK_FINAL_PROCESS_DATE / g
        --
        hr_utility.set_message(801,'HR_7962_PDS_INV_FP_CHANGE');
        hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 50);
      if p_actual_termination_date is null
      then
        --
        if not (p_final_process_date is null)
        then
          -- CHK_FINAL_PROCESS_DATE / d
          --
          hr_utility.set_message(801,'HR_7503_PDS_INV_FP_DT_BLANK');
          hr_utility.raise_error;
        end if;
        --
      end if;
      --
      hr_utility.set_location(l_proc, 7);
      --
      if p_last_standard_process_date is null
      then
        --
        hr_utility.set_location(l_proc, 8);
        --
        if not (nvl(p_final_process_date, hr_api.g_eot) >=
                nvl(p_actual_termination_date, hr_api.g_eot))
        then
          -- CHK_FINAL_PROCESS_DATE / f
          --
          hr_utility.set_message(801,'HR_7963_PDS_INV_FP_BEFORE_ATT');
          hr_utility.raise_error;
        end if;
      else
        --
        if not (nvl(p_final_process_date, hr_api.g_eot) >=
                p_last_standard_process_date)
        --
        then
          -- CHK_FINAL_PROCESS_DATE / c
          --
          hr_utility.set_message(801,'HR_7504_PDS_INV_FP_LSP_DT');
          hr_utility.raise_error;
        end if;
      end if;
      --
      hr_utility.set_location(l_proc, 8);
      --
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 14);

end if; -- end multi_message if

exception
  --
  -- Multiple Error Detection is enabled handle the Application Errors
  -- which have been raised by this procedure. Transfer the error to the
  -- Multiple Message List and associate the error with the above columns.
  --
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_same_associated_columns => 'Y'
        ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 20);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 30);

end chk_final_process_date;
--
--  ---------------------------------------------------------------------------
--  |-------------------< chk_last_standard_process_date >--------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    c)      Must be >= ACTUAL_TERMINATION_DATE (U)
--    e)      Must be null (I)
--    f)      If ACTUAL_TERMINATION_DATE is null then must be null (U)
--    g)      If US legislation then must be null (U)
--    h)      If not US legislation and ACTUAL_TERMINATION_DATE is not null
--            then must not be null (U)
--    i)      Cannot be changed from one not null value to another (U)
--
--  Pre-conditions:
--    p_date_start and period_of_placement_id have been successfully
--    validated.
--
--  In Arguments:
--    p_actual_termination_date
--    p_date_start
--    p_last_standard_process_date
--    p_object_version_number
--    p_period_of_placement_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_last_standard_process_date
  (p_actual_termination_date    in date
  ,p_business_group_id          in number
  ,p_date_start                 in date
  ,p_last_standard_process_date in date
  ,p_object_version_number      in number
  ,p_period_of_placement_id     in number
  ) is
--
  l_api_updating     boolean;
  l_assigned_payroll boolean;
  l_legislation_code per_business_groups.legislation_code%TYPE;
  l_max_end_date     date;
  l_proc             varchar2(72)
                       := g_package||'chk_last_standard_process_date';
--
  cursor csr_get_legislation_code is
    select bus.legislation_code
    from   per_business_groups_perf bus
    where  bus.business_group_id = p_business_group_id
    and    rownum = 1;
-- Bug 3387328. Used _perf view to increase perfomance.
--
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pdp_shd.api_updating
         (p_period_of_placement_id  => p_period_of_placement_id
         ,p_object_version_number   => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  if l_api_updating
  then
    --
    if nvl(per_pdp_shd.g_old_rec.last_standard_process_date, hr_api.g_date) <>
       nvl(p_last_standard_process_date, hr_api.g_date)
    then
      --
      hr_utility.set_location(l_proc, 30);
      --
      if  per_pdp_shd.g_old_rec.last_standard_process_date is not null
      and p_last_standard_process_date is not null
      then
        -- CHK_LAST_STANDARD_PROCESS_DATE / i
        --
        hr_utility.set_message(801,'HR_7960_PDS_INV_LSP_CHANGE');
        hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 40);
      --
      open  csr_get_legislation_code;
      fetch csr_get_legislation_code
       into l_legislation_code;
      --
      if csr_get_legislation_code%NOTFOUND
      then
        --
        close csr_get_legislation_code;
        --
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '5');
        hr_utility.raise_error;
      end if;
      --
      close csr_get_legislation_code;
      --
      hr_utility.set_location(l_proc, 50);
      --
-- Bug 1711085. VS. 27-Mar-2001. Commented out the code that disables
-- last_standard_process for US legislature.
/*      if l_legislation_code = 'US'
      then
        --
        hr_utility.set_location(l_proc, 60);
        --
        if not (p_last_standard_process_date is null)
        then
          -- CHK_LAST_STANDARD_PROCESS_DATE / g
          --
          hr_utility.set_message(801,'HR_7958_PDS_INV_US_LSP_BLANK');
          hr_utility.raise_error;
        end if;
      end if;
*/
      --
      if p_actual_termination_date is null
      then
        --
        if not (p_last_standard_process_date is null)
        then
          -- CHK_LAST_STANDARD_PROCESS_DATE / f
          --
          hr_utility.set_message(801,'HR_7497_PDS_INV_LSP_DT_BLANK');
          hr_utility.raise_error;
        end if;
        --
      end if;
      --
      hr_utility.set_location(l_proc, 80);
      --
      if not (nvl(p_last_standard_process_date, hr_api.g_eot) >=
              nvl(p_actual_termination_date, hr_api.g_eot))
      --
      then
        -- CHK_LAST_STANDARD_PROCESS_DATE / c
        --
        hr_utility.set_message(801,'HR_7505_PDS_INV_LSP_ATT_DT');
        hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 90);
      --
    end if;
    --
    if  (nvl(per_pdp_shd.g_old_rec.actual_termination_date, hr_api.g_date) <>
         nvl(p_actual_termination_date,hr_api.g_date) )
         and (p_actual_termination_date is not null)
         and l_legislation_code <> 'US'
    then
           hr_utility.set_location(l_proc, 100);
           --
           if p_last_standard_process_date is null
           --
           then
           --
           -- Must also be set to not null value if actual_termination_date
           -- updated to not null value.
           -- CHK_LAST_STANDARD_PROCESS_DATE / h
           --
              hr_utility.set_message(801,'HR_7959_PDS_INV_LSP_BLANK');
              hr_utility.raise_error;
           end if;
    end if;
    --
  end if;
    --
    hr_utility.set_location(l_proc, 120);
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 130);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => per_pdp_shd.g_tab_nam||
                                      '.LAST_STANDARD_PROCESS_DATE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 140);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 150);

end chk_last_standard_process_date;
--
--  ---------------------------------------------------------------------------
--  |-------------------------< chk_at_date_lsp_date >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates the following business rule :
--
--    If actual_termination_date is changed from a NULL value to
--    a NOT NULL value then last_standard_process_date must also
--    be changed to a NOT NULL value.
--
--  Pre-conditions:
--    actual_termination_date, last_standard_process_date have been
--    successfully validated separately.
--
--  In Arguments:
--    p_period_of_placement_id
--    p_actual_termination_date
--    p_last_standard_process_date
--    p_object_version_number
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_at_date_lsp_date
--
  (p_actual_termination_date    in date
  ,p_last_standard_process_date in date
  ,p_object_version_number      in number
  ,p_period_of_placement_id     in number
  ,p_business_group_id		in number
  ) is
--
  l_proc             varchar2(72) := g_package||'chk_at_date_lsp_date';
  l_api_updating     boolean;
  l_legislation_code per_business_groups.legislation_code%TYPE;
--
 cursor csr_get_legislation_code is
    select bus.legislation_code
    from   per_business_groups_perf bus
    where  bus.business_group_id = p_business_group_id
    and    rownum = 1;
-- Bug 3387328. Used _perf view to improve performance.
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);

  --
  -- Only proceed with validation when the Multiple Message List
  -- does not already contain an error associated with the
  -- below columns.
  --
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => per_pdp_shd.g_tab_nam||
                               '.LAST_STANDARD_PROCESS_DATE'
       ,p_check_column2      => per_pdp_shd.g_tab_nam||
                               '.ACTUAL_TERMINATION_DATE'
       ,p_associated_column1 => per_pdp_shd.g_tab_nam||
                               '.LAST_STANDARD_PROCESS_DATE'
       ,p_associated_column2 => per_pdp_shd.g_tab_nam||
                               '.ACTUAL_TERMINATION_DATE'
       ) then

  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pdp_shd.api_updating
         (p_period_of_placement_id  => p_period_of_placement_id
         ,p_object_version_number   => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for actual_termination_date or last_standard_process_date
  --    has changed
  --
  if (l_api_updating
    and ((nvl(per_pdp_shd.g_old_rec.actual_termination_date, hr_api.g_date)
        <> nvl(p_actual_termination_date, hr_api.g_date))
        or
        (nvl(per_pdp_shd.g_old_rec.last_standard_process_date, hr_api.g_date)
        <> nvl(p_last_standard_process_date, hr_api.g_date))))
    or
      NOT l_api_updating then
    --
    hr_utility.set_location(l_proc, 30);
    --
      open  csr_get_legislation_code;
      fetch csr_get_legislation_code
      into l_legislation_code;
      --
      if csr_get_legislation_code%NOTFOUND
      then
        --
        close csr_get_legislation_code;
        --
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', l_proc);
        hr_utility.set_message_token('STEP', '5');
        hr_utility.raise_error;
      end if;
      --
      close csr_get_legislation_code;
      --
      hr_utility.set_location(l_proc, 50);
      --
      if l_legislation_code <> 'US' then
      --
      -- Check combination when either actual_termination_date or
      -- last_standard_process_date are set
      --
        if  (per_pdp_shd.g_old_rec.actual_termination_date is null
            and  p_actual_termination_date is not null)
            and  p_last_standard_process_date is null
        then
            hr_utility.set_message(801,'HR_7959_PDS_INV_LSP_BLANK');
            hr_utility.raise_error;
        end if;
      --
      end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 40);

end if; -- end multi_message if

exception
  --
  -- Multiple Error Detection is enabled handle the Application Errors
  -- which have been raised by this procedure. Transfer the error to the
  -- Multiple Message List and associate the error with the above columns.
  --
  when app_exception.application_exception then
    if hr_multi_message.exception_add
        (p_same_associated_columns => 'Y'
        ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);

end chk_at_date_lsp_date;
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_termination_reason >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Validate against HR_LOOKUPS.lookup_code
--            where LOOKUP_TYPE = 'HR_CWK_TERMINATION_REASONS' (U)
--    b)      Must be null (I)
--
--  Pre-conditions:
--    period_of_placement_id must have been successfully validated.
--
--  In Arguments:
--    p_termination_reason
--    p_effective_date
--    p_object_version_number
--    p_period_of_placement_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_termination_reason
--
  (p_termination_reason         in varchar2,
   p_effective_date             in date,
   p_object_version_number      in number,
   p_period_of_placement_id     in number) is
--
   l_api_updating boolean;
   l_proc         varchar2(72)  :=  g_package||'chk_termination_reason';
   l_rec	  per_pdp_shd.g_rec_type;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  hr_api.mandatory_arg_error
   (p_api_name    => l_proc
   ,p_argument    => 'effective date'
   ,p_argument_value => p_effective_date
   );
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pdp_shd.api_updating
         (p_period_of_placement_id => p_period_of_placement_id
         ,p_object_version_number  => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 2);
  --
  if  l_api_updating
  and p_termination_reason is not null
  then
    --
    if nvl(per_pdp_shd.g_old_rec.termination_reason, hr_api.g_varchar2) <>
       nvl(p_termination_reason, hr_api.g_varchar2)
    then
      --
      -- Bug 1472162.
      --
--      if hr_api.not_exists_in_hr_lookups
      if hr_api.not_exists_in_leg_lookups
	  (p_effective_date  => p_effective_date
	  ,p_lookup_type     => 'HR_CWK_TERMINATION_REASONS'
	  ,p_lookup_code     => p_termination_reason
	  ) then
        -- Error - Invalid Termination Reason
        hr_utility.set_location(l_proc, 3);
        hr_utility.set_message(800,'HR_289610_PDP_TERM_REASON');
        hr_utility.raise_error;
      end if;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 5);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => per_pdp_shd.g_tab_nam||
                                    '.TERMINATION_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 10);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 20);

end chk_termination_reason;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      Mandatory (I,U)
--    b)      UPDATE not allowed (U)
--    c)      The person_id must exist in PER_ALL_PEOPLE_F at the effective
--            date (I)
--    NB:     The unique combination of person_id and date_start is validated
--            for uniqueness.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_person_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_person_id
--
  (p_person_id                   in number
  ,p_effective_date              in date
  ,p_business_group_id           in number) is
--
   l_proc           varchar2(72)  :=  g_package||'chk_person_id';
   l_rec	    per_pdp_shd.g_rec_type;
   l_person_id      number;

   cursor c_get_person is
   select p.person_id
   from   per_all_people_f p
   where  p.person_id = p_person_id
   and    p.business_group_id = p_business_group_id
   and    p_effective_date between
          p.effective_start_date and p.effective_end_date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- CHK_PERSON_ID / a
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_utility.set_location(l_proc, 20);

  --
  -- CHK_PERSON_ID / b
  --
  open  c_get_person;
  fetch c_get_person into l_person_id;
  close c_get_person;

  if l_person_id is null then
    --
    -- person does not exist
    --
    fnd_message.set_name('PAY','HR_7971_PER_PER_IN_PERSON');
    fnd_message.raise_error;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 30);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => per_pdp_shd.g_tab_nam||'.PERSON_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);

end chk_person_id;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< chk_person_id_date_start >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that the following business rules are met:
--    a)      PERSON_ID and DATE_START combination must be unique (I)
--    b)      PERSON_ID must have a CWK PTU (I,U)
--
--  Pre-conditions:
--    person_id and date_start have been successfully validated separately.
--
--  In Arguments:
--    p_date_start
--    p_person_id
--
--  Post Success:
--    If the above business rules are satisfied then processing continues.
--
--  Post Failure:
--    If the above business rules then an application error will be raised and
--    processing is terminated.
--
--  Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_person_id_date_start
--
  (p_date_start             in date,
   p_object_version_number  in number,
   p_period_of_placement_id in number,
   p_person_id              in number) is
--
   l_api_updating   boolean;
   l_exists         varchar2(1);
   l_proc           varchar2(72)  :=  g_package||'chk_person_id_date_start';
--
   cursor csr_new_pers_date is
     select null
     from   per_periods_of_placement pdp
     where  pdp.person_id  = p_person_id
     and    pdp.date_start = p_date_start;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  hr_utility.set_location(l_proc, 4);
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  hr_utility.set_location(l_proc, 5);
  --
  -- Check to see if record updated.
  --
  l_api_updating := per_pdp_shd.api_updating
         (p_period_of_placement_id => p_period_of_placement_id
         ,p_object_version_number  => p_object_version_number);
  --
  if not l_api_updating
  then
    --
    -- Check that the Person ID and Date Start combination does not exist
    -- on PER_PERIODS_OF_PLACEMENT
    --
    hr_utility.set_location(l_proc, 6);
    --
    open csr_new_pers_date;
    --
    fetch csr_new_pers_date into l_exists;
    --
    if csr_new_pers_date%FOUND
    then
      -- CHK_PERSON_ID_DATE_START / a
      --
      close csr_new_pers_date;
      hr_utility.set_message(800, 'HR_289611_PDP_EXISTS');
      hr_utility.raise_error;
    end if;
    --
    close csr_new_pers_date;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 9);

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => per_pdp_shd.g_tab_nam||'.PERSON_ID'
         ,p_associated_column2      => per_pdp_shd.g_tab_nam||'.DATE_START'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

end chk_person_id_date_start;
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
--
procedure chk_ddf
  (p_rec in per_pdp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.period_of_placement_id is not null)  and (
    nvl(per_pdp_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information21, hr_api.g_varchar2) <>
    nvl(p_rec.information21, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information22, hr_api.g_varchar2) <>
    nvl(p_rec.information22, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information23, hr_api.g_varchar2) <>
    nvl(p_rec.information23, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information24, hr_api.g_varchar2) <>
    nvl(p_rec.information24, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information25, hr_api.g_varchar2) <>
    nvl(p_rec.information25, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information26, hr_api.g_varchar2) <>
    nvl(p_rec.information26, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information27, hr_api.g_varchar2) <>
    nvl(p_rec.information27, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information28, hr_api.g_varchar2) <>
    nvl(p_rec.information28, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information29, hr_api.g_varchar2) <>
    nvl(p_rec.information29, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.information30, hr_api.g_varchar2) <>
    nvl(p_rec.information30, hr_api.g_varchar2) ))
    or (p_rec.period_of_placement_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PDP_DEVELOPER_DF'
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
      ,p_attribute21_name                => 'INFORMATION21'
      ,p_attribute21_value               => p_rec.information21
      ,p_attribute22_name                => 'INFORMATION22'
      ,p_attribute22_value               => p_rec.information22
      ,p_attribute23_name                => 'INFORMATION23'
      ,p_attribute23_value               => p_rec.information23
      ,p_attribute24_name                => 'INFORMATION24'
      ,p_attribute24_value               => p_rec.information24
      ,p_attribute25_name                => 'INFORMATION25'
      ,p_attribute25_value               => p_rec.information25
      ,p_attribute26_name                => 'INFORMATION26'
      ,p_attribute26_value               => p_rec.information26
      ,p_attribute27_name                => 'INFORMATION27'
      ,p_attribute27_value               => p_rec.information27
      ,p_attribute28_name                => 'INFORMATION28'
      ,p_attribute28_value               => p_rec.information28
      ,p_attribute29_name                => 'INFORMATION29'
      ,p_attribute29_value               => p_rec.information29
      ,p_attribute30_name                => 'INFORMATION30'
      ,p_attribute30_value               => p_rec.information30
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
--
procedure chk_df
  (p_rec in per_pdp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.period_of_placement_id is not null)  and (
    nvl(per_pdp_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_pdp_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.period_of_placement_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PERIODS_OF_PLACEMENT'
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
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
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
  (p_effective_date               in date
  ,p_rec in per_pdp_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_pdp_shd.api_updating
      (p_period_of_placement_id            => p_rec.period_of_placement_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pdp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_pdp_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  hr_utility.set_location(l_proc, 10);

  --
  -- Validate person id
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID / a,c
  --
  per_pdp_bus.chk_person_id
    (p_person_id         => p_rec.person_id,
     p_effective_date    => p_effective_date,
     p_business_group_id => p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 15);

  --
  -- Validate date start
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_DATE_START / a
  --
  per_pdp_bus.chk_date_start(p_date_start => p_rec.date_start);

  hr_utility.set_location(l_proc, 20);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate Independent Attributes
  --
  hr_utility.set_location(l_proc, 25);
  --
  --
  -- Validate person id and date start combination
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID_DATE_START / a,b
  --
  per_pdp_bus.chk_person_id_date_start
    (p_date_start              => p_rec.date_start
    ,p_object_version_number   => p_rec.object_version_number
    ,p_period_of_placement_id  => p_rec.period_of_placement_id
    ,p_person_id               => p_rec.person_id);

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate projected termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PROJECTED_TERM_DATE / a
  --
  per_pdp_bus.chk_projected_term_date
    (p_date_start                 => p_rec.date_start
    ,p_projected_termination_date => p_rec.projected_termination_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_placement_id     => p_rec.period_of_placement_id);
  --
  hr_utility.set_location(l_proc, 35);
  --
  -- Validate termination reason
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_TERMINATION_REASON / b
  --
  per_pdp_bus.chk_termination_reason
    (p_termination_reason      => p_rec.termination_reason,
     p_effective_date          => p_effective_date,
     p_object_version_number   => p_rec.object_version_number,
     p_period_of_placement_id  => p_rec.period_of_placement_id);

  hr_utility.set_location(l_proc, 40);

  --
  -- Validate last standard process date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LAST_STANDARD_PROCESS_DATE / e
  --
  -- 70.3 change c start.
  --
  per_pdp_bus.chk_last_standard_process_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_business_group_id          => p_rec.business_group_id
    ,p_date_start                 => p_rec.date_start
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_placement_id     => p_rec.period_of_placement_id
    );

  hr_utility.set_location(l_proc, 50);

  --
  -- Validate Dependent Attributes
  --

  --
  -- Validate actual termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ACTUAL_TERMINATION_DATE / c
  --
  per_pdp_bus.chk_actual_termination_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_date_start                 => p_rec.date_start
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_placement_id     => p_rec.period_of_placement_id
    ,p_person_id                  => p_rec.person_id);

  hr_utility.set_location(l_proc, 60);

  --
  -- Validate final process date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FINAL_PROCESS_DATE / e
  --
  per_pdp_bus.chk_final_process_date
    (p_actual_termination_date    => p_rec.actual_termination_date,
     p_date_start                 => p_rec.date_start,
     p_final_process_date         => p_rec.final_process_date,
     p_last_standard_process_date => p_rec.last_standard_process_date,
     p_object_version_number      => p_rec.object_version_number,
     p_period_of_placement_id     => p_rec.period_of_placement_id);

  hr_utility.set_location(l_proc, 70);

  --
  -- Validate actual termination date/last standard process date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LAST_STANDARD_PROCESS_DATE / h
  --
  per_pdp_bus.chk_at_date_lsp_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_placement_id     => p_rec.period_of_placement_id
    ,p_business_group_id          => p_rec.business_group_id
    );

  hr_utility.set_location(l_proc, 80);

  --
  -- Only validate the flexfields if the PDP being created
  -- is not the default for a new person.
  --
  if per_pdp_shd.g_validate_df_flex then

    per_pdp_bus.chk_ddf(p_rec);
    per_pdp_bus.chk_df(p_rec);

  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pdp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_pdp_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  hr_utility.set_location(l_proc, 10);

  --
  -- Validate person id
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID / a,c
  --
  per_pdp_bus.chk_person_id
    (p_person_id         => p_rec.person_id,
     p_effective_date    => p_effective_date,
     p_business_group_id => p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 15);

  --
  -- Validate date start
  --
  -- Business Rule Mapping

-- CHK_DATE_START / a -- per_pdp_bus.chk_date_start(p_date_start => p_rec.date_start);

  hr_utility.set_location(l_proc, 20);

  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;


  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );

  --
  -- Validate Independent Attributes
  --

  hr_utility.set_location(l_proc, 25);
  --
  --
  -- Validate person id and date start combination
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PERSON_ID_DATE_START / a,b
  --
  per_pdp_bus.chk_person_id_date_start
    (p_date_start              => p_rec.date_start
    ,p_object_version_number   => p_rec.object_version_number
    ,p_period_of_placement_id  => p_rec.period_of_placement_id
    ,p_person_id               => p_rec.person_id);

  hr_utility.set_location(l_proc, 30);

  --
  -- Validate projected termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_PROJECTED_TERM_DATE / a
  --
  per_pdp_bus.chk_projected_term_date
    (p_date_start                 => p_rec.date_start
    ,p_projected_termination_date => p_rec.projected_termination_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_placement_id     => p_rec.period_of_placement_id);
  --
  hr_utility.set_location(l_proc, 35);
  --
  -- Validate termination reason
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_TERMINATION_REASON / b
  --
  per_pdp_bus.chk_termination_reason
    (p_termination_reason      => p_rec.termination_reason,
     p_effective_date          => p_effective_date,
     p_object_version_number   => p_rec.object_version_number,
     p_period_of_placement_id  => p_rec.period_of_placement_id);

  hr_utility.set_location(l_proc, 40);
  --
  -- Validate last standard process date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LAST_STANDARD_PROCESS_DATE / e
  --
  -- 70.3 change c start.
  --
  per_pdp_bus.chk_last_standard_process_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_business_group_id          => p_rec.business_group_id
    ,p_date_start                 => p_rec.date_start
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_placement_id     => p_rec.period_of_placement_id
    );

  hr_utility.set_location(l_proc, 50);

  --
  -- Validate Dependent Attributes
  --

  --
  -- Validate actual termination date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_ACTUAL_TERMINATION_DATE / c
  --
  per_pdp_bus.chk_actual_termination_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_date_start                 => p_rec.date_start
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_placement_id     => p_rec.period_of_placement_id
    ,p_person_id                  => p_rec.person_id);

  hr_utility.set_location(l_proc, 60);

  --
  -- Validate final process date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_FINAL_PROCESS_DATE / e
  --
  per_pdp_bus.chk_final_process_date
    (p_actual_termination_date    => p_rec.actual_termination_date,
     p_date_start                 => p_rec.date_start,
     p_final_process_date         => p_rec.final_process_date,
     p_last_standard_process_date => p_rec.last_standard_process_date,
     p_object_version_number      => p_rec.object_version_number,
     p_period_of_placement_id     => p_rec.period_of_placement_id);

  hr_utility.set_location(l_proc, 70);

  --
  -- Validate actual termination date/last standard process date
  --
  -- Business Rule Mapping
  -- =====================
  -- CHK_LAST_STANDARD_PROCESS_DATE / h
  --
  per_pdp_bus.chk_at_date_lsp_date
    (p_actual_termination_date    => p_rec.actual_termination_date
    ,p_last_standard_process_date => p_rec.last_standard_process_date
    ,p_object_version_number      => p_rec.object_version_number
    ,p_period_of_placement_id     => p_rec.period_of_placement_id
    ,p_business_group_id          => p_rec.business_group_id
    );

  hr_utility.set_location(l_proc, 80);

  --
  -- Only validate the flexfields if the PDP being created
  -- is not the default for a new person.
  --
  if per_pdp_shd.g_validate_df_flex then

    per_pdp_bus.chk_ddf(p_rec);
    per_pdp_bus.chk_df(p_rec);

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pdp_shd.g_rec_type
  ) is
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
end per_pdp_bus;

/
