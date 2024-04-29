--------------------------------------------------------
--  DDL for Package Body PAY_TDF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TDF_BUS" as
/* $Header: pytdfrhi.pkb 120.4 2005/09/20 06:56 adkumar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_tdf_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_time_definition_id          number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_time_definition_id                   in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_time_definitions tdf
     where tdf.time_definition_id = p_time_definition_id
       and pbg.business_group_id (+) = tdf.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'time_definition_id'
    ,p_argument_value     => p_time_definition_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'TIME_DEFINITION_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_time_definition_id                   in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_time_definitions tdf
     where tdf.time_definition_id = p_time_definition_id
       and pbg.business_group_id (+) = tdf.business_group_id;
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
    ,p_argument           => 'time_definition_id'
    ,p_argument_value     => p_time_definition_id
    );
  --
  if ( nvl(pay_tdf_bus.g_time_definition_id, hr_api.g_number)
       = p_time_definition_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_tdf_bus.g_legislation_code;
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
    pay_tdf_bus.g_time_definition_id          := p_time_definition_id;
    pay_tdf_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date               in  date
  ,p_rec in pay_tdf_shd.g_rec_type
  ,p_time_def_used                in  boolean
  ,p_regenerate_periods           out nocopy boolean
  ,p_delete_periods               out nocopy boolean
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_tdf_shd.api_updating
      (p_time_definition_id                => p_rec.time_definition_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_tdf_shd.g_old_rec.business_group_id, hr_api.g_number) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'BUSINESS_GROUP_ID'
     ,p_base_table => pay_tdf_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_tdf_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'LEGISLATION_CODE'
     ,p_base_table => pay_tdf_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.short_name, hr_api.g_varchar2) <>
        pay_tdf_shd.g_old_rec.short_name then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'SHORT_NAME'
     ,p_base_table => pay_tdf_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.definition_type, hr_api.g_varchar2) <>
        nvl(pay_tdf_shd.g_old_rec.definition_type, hr_api.g_varchar2) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'DEFINITION_TYPE'
     ,p_base_table => pay_tdf_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.period_type, hr_api.g_varchar2) <>
          nvl(pay_tdf_shd.g_old_rec.period_type, hr_api.g_varchar2) OR
     nvl(p_rec.period_unit, hr_api.g_varchar2) <>
          nvl(pay_tdf_shd.g_old_rec.period_unit, hr_api.g_varchar2) OR
     nvl(p_rec.day_adjustment, hr_api.g_varchar2) <>
          nvl(pay_tdf_shd.g_old_rec.day_adjustment, hr_api.g_varchar2) OR
     nvl(p_rec.dynamic_code, hr_api.g_varchar2) <>
          nvl(pay_tdf_shd.g_old_rec.dynamic_code, hr_api.g_varchar2) OR
     nvl(p_rec.start_date, hr_api.g_date) <>
          nvl(pay_tdf_shd.g_old_rec.start_date, hr_api.g_date) OR
     nvl(p_rec.period_time_definition_id, hr_api.g_number) <>
          nvl(pay_tdf_shd.g_old_rec.period_time_definition_id, hr_api.g_number) then

     if p_time_def_used then

        p_regenerate_periods := false;
        p_delete_periods := false;

        fnd_message.set_name('PAY', 'PAY_34057_FLSA_CROSS_VAL1');
        fnd_message.raise_error;

     else

        p_regenerate_periods := true;
        p_delete_periods := true;

     end if;

  elsif  nvl(p_rec.number_of_years, hr_api.g_number) <>
          nvl(pay_tdf_shd.g_old_rec.time_definition_id, hr_api.g_number) then

        p_regenerate_periods := true;
        p_delete_periods := false;

  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode

  IF (p_insert) THEN

    if p_business_group_id is not null and p_legislation_code is not null then

         fnd_message.set_name('PAY', 'PAY_34057_FLSA_CROSS_VAL1');
         fnd_message.set_token('ARGUMENT1', 'Business Group');
         fnd_message.set_token('ARGUMENT2', 'Legislation Code');
         fnd_message.raise_error;

    end if;

    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< is_startup_data >------------------------------|
-- ----------------------------------------------------------------------------
Function is_startup_data
  ( p_time_definition_id  IN number
   ,p_business_group_id   IN number
   ,p_legislation_code    IN varchar2 )
Return number is
--
  l_proc  varchar2(72) := g_package||'is_startup_data';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,5);
  --
    BEGIN
      hr_startup_data_api_support.chk_upd_del_startup_action
        (p_generic_allowed      => TRUE
        ,p_startup_allowed      => TRUE
        ,p_user_allowed         => TRUE
        ,p_business_group_id    => p_business_group_id
        ,p_legislation_code     => p_legislation_code
        ,p_legislation_subgroup => null
        );
    EXCEPTION
      When Others then
        return 0;
    END;

    return 1;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
END is_startup_data;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_time_def_usage >---------------------------|
-- ----------------------------------------------------------------------------
Function chk_time_def_usage
  ( p_time_definition_id  IN number
   ,p_definition_type     IN varchar2
 )
Return boolean is
--
  l_proc  varchar2(72) := g_package||'chk_time_def_usage';
  l_exists varchar2(1);
--
--  Cursor csr_time_def_comb is
--  select null
--  from   pay_time_def_combinations
--  where  child_time_definition_id = p_time_definition_id;


  Cursor csr_time_def_static is
  select null
  from   pay_time_definitions
  where  period_time_definition_id = p_time_definition_id;

  Cursor csr_time_def_element is
  select null
  from   pay_element_types_f
  where  time_definition_id = p_time_definition_id
  and    time_definition_type = 'S';

  Cursor csr_time_def_run_results is
  select null
  from   pay_run_results
  where  time_definition_id = p_time_definition_id;

  Cursor csr_time_def_process_details is
  select null
  from   pay_entry_process_details
  where  time_definition_id = p_time_definition_id;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc,5);
  --
     if p_definition_type = 'P' then

       open csr_time_def_static;
       fetch csr_time_def_static into l_exists;

       if csr_time_def_static%found then
         close csr_time_def_static;
         return true;
       end if;

       close csr_time_def_static;

     else

-- Following validation will be put in place
-- when combination time definitions will be implemented.

--     if p_definition_type = 'S' then
--
--         open csr_time_def_comb;
--         fetch csr_time_def_comb into l_exists;
--         if csr_time_def_comb%found then
--            close csr_time_def_comb;
--            return true;
--         end if;
--         close csr_time_def_comb;
--
--       end if;

       open csr_time_def_element;
       fetch csr_time_def_element into l_exists;
       if csr_time_def_element%found then
         close csr_time_def_element;
         return true;
       end if;
       close csr_time_def_element;

       open csr_time_def_run_results;
       fetch csr_time_def_run_results into l_exists;
       if csr_time_def_run_results%found then
         close csr_time_def_run_results;
         return true;
       end if;
       close csr_time_def_run_results;

       open csr_time_def_process_details;
       fetch csr_time_def_process_details into l_exists;
       if csr_time_def_process_details%found then
         close csr_time_def_process_details;
         return true;
       end if;
       close csr_time_def_process_details;

     end if;

     return false;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);

Exception

    when others then
--       if csr_time_def_comb%isopen then
--          close csr_time_def_comb;
--       end if;

       if csr_time_def_static%isopen then
          close csr_time_def_static;
       end if;

       if csr_time_def_element%isopen then
          close csr_time_def_element;
       end if;

       if csr_time_def_run_results%isopen then
          close csr_time_def_run_results;
       end if;

       if csr_time_def_process_details%isopen then
          close csr_time_def_process_details;
       end if;

       raise;
END chk_time_def_usage;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_number_of_years >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Number of Years column
--
--  Prerequisites:
--    Definition type is valid.
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_type
--    p_number_of_years
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_number_of_years
  (p_time_definition_id     in  number,
   p_object_version_number  in  number,
   p_definition_type        in  varchar2,
   p_number_of_years        in  number
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_number_of_years';
  l_api_updating  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_tdf_shd.api_updating
        (p_time_definition_id    => p_time_definition_id
        ,p_object_version_number => p_object_version_number);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_TIME_DEFINITIONS.DEFINITION_TYPE'
     ,p_associated_column1 => 'PAY_TIME_DEFINITIONS.NUMBER_OF_YEARS'
     ) and (
       not l_api_updating or
       ( l_api_updating and nvl(p_number_of_years, hr_api.g_number) <>
                                     nvl(pay_tdf_shd.g_old_rec.number_of_years, hr_api.g_number) )
     ) then

     if p_definition_type in ('P','E','C')
            and p_number_of_years is not null  then

       fnd_message.set_name('PAY', 'PAY_34052_FLSA_ARG_NOT_NULL');
       fnd_message.set_token('ARGUMENT', 'Years');
       fnd_message.raise_error;

     end if;

     if p_definition_type = 'S' and p_number_of_years is null then

       fnd_message.set_name('PAY', 'PAY_34053_FLSA_ARG_NULL');
       fnd_message.set_token('ARGUMENT', 'Years');
       fnd_message.raise_error;

     end if;

     if p_definition_type = 'S' and p_number_of_years <= 0 then

       fnd_message.set_name('PAY', 'PAY_34054_FLSA_ARG_ZERO');
       fnd_message.set_token('ARGUMENT', 'Years');
       fnd_message.raise_error;

     end if;

     if l_api_updating and p_definition_type = 'S' and
              p_number_of_years < nvl(pay_tdf_shd.g_old_rec.number_of_years,0) then

       fnd_message.set_name('PAY', 'PAY_34055_FLSA_YEARS_INV_UPD');
       fnd_message.raise_error;

     end if;

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.NUMBER_OF_YEARS') then
              raise;
       end if;

    when others then
       raise;

End chk_number_of_years;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_cross_validations >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Performs the cross validations on a number of columns.
--
--  Prerequisites:
--    Definition type is valid.
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_type
--    p_period_type
--    p_period_time_definition_id
--    p_day_adjustment
--    p_period_unit
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_cross_validations
  (p_time_definition_id        in  number,
   p_object_version_number     in  number,
   p_definition_type           in  varchar2,
   p_period_type               in  varchar2,
   p_period_time_definition_id in  number,
   p_day_adjustment            in  varchar2,
   p_period_unit               in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_cross_validations';
  l_api_updating  boolean;
  l_exists varchar2(1);

  cursor csr_pit_period_type is
    select null
    from   hr_lookups
    where lookup_type like 'PAY_PIT_OFFSET_PERIOD_TYPE'
      and enabled_flag='Y'
      and lookup_code = p_period_type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.trace('Definition Type - ' || nvl(p_definition_type,'null'));
  hr_utility.trace('Period Type - ' || nvl(p_period_type,'null'));
  hr_utility.trace('Day Adjustment - ' || nvl(p_day_adjustment,'null'));
  hr_utility.trace('Period Unit - ' || nvl(p_period_unit,'null'));
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_TIME_DEFINITIONS.DEFINITION_TYPE'
     ,p_associated_column1 => 'PAY_TIME_DEFINITIONS.CROSS_VALIDATIONS'
     ) then

     if p_definition_type = 'S' then

       if p_period_type is not null and p_period_time_definition_id is not null then

         fnd_message.set_name('PAY', 'PAY_34057_FLSA_CROSS_VAL1');
         fnd_message.set_token('ARGUMENT1', 'Period Type');
         fnd_message.set_token('ARGUMENT2', 'Definition for Next Start Date');
         fnd_message.raise_error;

       elsif p_period_type is null and p_period_time_definition_id is null then

         fnd_message.set_name('PAY', 'PAY_34058_FLSA_CROSS_VAL2');
         fnd_message.set_token('ARGUMENT1', 'Period Type');
         fnd_message.set_token('ARGUMENT2', 'Definition for Next Start Date');
         fnd_message.raise_error;

       end if;

     end if;

     if p_definition_type = 'P' then
       if p_period_type is null and p_period_unit is null
                             and p_day_adjustment is null then

         fnd_message.set_name('PAY', 'PAY_34060_FLSA_CROSS_VAL3');
         fnd_message.raise_error;

       elsif p_period_type is null and p_period_unit is not null then

         fnd_message.set_name('PAY', 'PAY_34053_FLSA_ARG_NULL');
         fnd_message.set_token('ARGUMENT', 'Period Type');
         fnd_message.raise_error;

       elsif p_period_type is not null and p_period_unit is null then
         open csr_pit_period_type;
	 fetch csr_pit_period_type into l_exists;
	 if csr_pit_period_type%found then
	    fnd_message.set_name('PAY', 'PAY_34053_FLSA_ARG_NULL');
            fnd_message.set_token('ARGUMENT', 'Period Unit');
            fnd_message.raise_error;
         end if;
	 close csr_pit_period_type;
       end if;

     end if;

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

   when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.CROSS_VALIDATIONS') then
              raise;
       end if;

    when others then
       raise;

End chk_cross_validations;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_period_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Period type column
--
--  Prerequisites:
--    Definition type is valid.
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_type
--    p_period_type
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_period_type
  (p_time_definition_id        in  number,
   p_object_version_number     in  number,
   p_definition_type           in  varchar2,
   p_period_type               in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_period_type';
  l_api_updating  boolean;
  l_exists varchar2(1);

  cursor csr_period_type is
    select null
    from   per_time_period_types
    where  period_type = p_period_type;

  cursor csr_pit_period_type is
    select null
    from   hr_lookups
    where lookup_type like 'PAY_PIT_PERIOD_TYPE'
      and enabled_flag='Y'
      and lookup_code = p_period_type;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_tdf_shd.api_updating
        (p_time_definition_id    => p_time_definition_id
        ,p_object_version_number => p_object_version_number);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_TIME_DEFINITIONS.DEFINITION_TYPE'
     ,p_associated_column1 => 'PAY_TIME_DEFINITIONS.PERIOD_TYPE'
     ) and (
       not l_api_updating or
       ( l_api_updating and nvl(p_period_type, hr_api.g_varchar2) <>
                                     nvl(pay_tdf_shd.g_old_rec.period_type, hr_api.g_varchar2 ) )
     ) then

     if p_definition_type in ('E','C')
            and p_period_type is not null  then

       fnd_message.set_name('PAY', 'PAY_34052_FLSA_ARG_NOT_NULL');
       fnd_message.set_token('ARGUMENT', 'Period Type');
       fnd_message.raise_error;

     end if;

     if p_period_type is not null then
        if p_definition_type = 'P' then
	   open csr_pit_period_type;
           fetch csr_pit_period_type into l_exists;
           if csr_pit_period_type%notfound then
              close csr_pit_period_type;
              fnd_message.set_name('PAY', 'PAY_34059_FLSA_ARG_INVALID');
              fnd_message.set_token('ARGUMENT', 'Period Type');
              fnd_message.raise_error;
            end if;
            close csr_pit_period_type;
         else
            open csr_period_type;
            fetch csr_period_type into l_exists;

            if csr_period_type%notfound then
               close csr_period_type;
               fnd_message.set_name('PAY', 'PAY_34059_FLSA_ARG_INVALID');
               fnd_message.set_token('ARGUMENT', 'Period Type');
               fnd_message.raise_error;
            end if;
            close csr_period_type;
          end if;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.PERIOD_TYPE') then
              raise;
       end if;

    when others then
       if csr_period_type%isopen then
          close csr_period_type;
       end if;
       raise;

End chk_period_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_period_unit >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Period unit column
--
--  Prerequisites:
--    Definition type is valid.
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_type
--    p_period_unit
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_period_unit
  (p_time_definition_id     in  number,
   p_object_version_number  in  number,
   p_definition_type        in  varchar2,
   p_period_unit            in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_period_unit';
  l_api_updating  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_tdf_shd.api_updating
        (p_time_definition_id    => p_time_definition_id
        ,p_object_version_number => p_object_version_number);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_TIME_DEFINITIONS.DEFINITION_TYPE'
     ,p_associated_column1 => 'PAY_TIME_DEFINITIONS.PERIOD_UNIT'
     ) and (
       not l_api_updating or
       ( l_api_updating and nvl(p_period_unit, hr_api.g_varchar2) <>
                                     nvl(pay_tdf_shd.g_old_rec.period_unit, hr_api.g_varchar2) )
     ) then

     if p_definition_type in ('S','E','C')
            and p_period_unit is not null  then

       fnd_message.set_name('PAY', 'PAY_34052_FLSA_ARG_NOT_NULL');
       fnd_message.set_token('ARGUMENT', 'Period Unit');
       fnd_message.raise_error;

     end if;

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.PERIOD_UNIT') then
              raise;
       end if;

    when others then
       raise;

End chk_period_unit;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_day_adjustment >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Day adjustment column
--
--  Prerequisites:
--    Definition type is valid.
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_type
--    p_day_adjustment
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_day_adjustment
  (p_time_definition_id     in  number,
   p_object_version_number  in  number,
   p_definition_type        in  varchar2,
   p_day_adjustment         in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_day_adjustment';
  l_api_updating  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_tdf_shd.api_updating
        (p_time_definition_id    => p_time_definition_id
        ,p_object_version_number => p_object_version_number);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_TIME_DEFINITIONS.DEFINITION_TYPE'
     ,p_associated_column1 => 'PAY_TIME_DEFINITIONS.DAY_ADUSTMENT'
     ) and (
       not l_api_updating or
       ( l_api_updating and nvl(p_day_adjustment, hr_api.g_varchar2) <>
                                     nvl(pay_tdf_shd.g_old_rec.day_adjustment, hr_api.g_varchar2) )
     ) then

     if p_definition_type in ('S','E','C')
            and p_day_adjustment is not null  then

       fnd_message.set_name('PAY', 'PAY_34052_FLSA_ARG_NOT_NULL');
       fnd_message.set_token('ARGUMENT', 'Day Adjustment');
       fnd_message.raise_error;

     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.DAY_ADJUSTMENT') then
              raise;
       end if;

    when others then
       raise;

End chk_day_adjustment;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_start_date >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Start date column
--
--  Prerequisites:
--    Definition type is valid.
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_type
--    p_start_date
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_start_date
  (p_time_definition_id     in  number,
   p_object_version_number  in  number,
   p_definition_type        in  varchar2,
   p_start_date             in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_start_date';
  l_api_updating  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_tdf_shd.api_updating
        (p_time_definition_id    => p_time_definition_id
        ,p_object_version_number => p_object_version_number);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_TIME_DEFINITIONS.DEFINITION_TYPE'
     ,p_associated_column1 => 'PAY_TIME_DEFINITIONS.START_DATE'
     ) and (
       not l_api_updating or
       ( l_api_updating and nvl(p_start_date, hr_api.g_date) <>
                                     nvl(pay_tdf_shd.g_old_rec.start_date, hr_api.g_date) )
     ) then

     if p_definition_type in ('P','E','C')
            and p_start_date is not null  then

       fnd_message.set_name('PAY', 'PAY_34052_FLSA_ARG_NOT_NULL');
       fnd_message.set_token('ARGUMENT', 'Start Date');
       fnd_message.raise_error;

     end if;

     if p_definition_type = 'S' and p_start_date is null then

       fnd_message.set_name('PAY', 'PAY_34053_FLSA_ARG_NULL');
       fnd_message.set_token('ARGUMENT', 'Start Date');
       fnd_message.raise_error;

     end if;

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.START_DATE') then
              raise;
       end if;

    when others then
       raise;

End chk_start_date;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_period_time_definition_id >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Period Time definition column
--
--  Prerequisites:
--    Definition type is valid.
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_type
--    p_period_time_definition_id
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_period_time_definition_id
  (p_time_definition_id        in  number,
   p_object_version_number     in  number,
   p_definition_type           in  varchar2,
   p_period_time_definition_id in  number,
   p_business_group_id         in  number,
   p_legislation_code          in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_period_time_definition_id';
  l_api_updating  boolean;
  l_exists varchar2(1);

cursor csr_period_time_definition_id is
  select null
  from   pay_time_definitions ptd
  where  ptd.time_definition_id = p_period_time_definition_id
  and    nvl(ptd.definition_type, 'P') = 'P'
  and  (
         ( p_business_group_id is null and
           p_legislation_code is null and
           ptd.business_group_id is null and
           ptd.legislation_code is null
         ) OR
         ( p_business_group_id is null and
           p_legislation_code is not null and
           ( (ptd.business_group_id is null and ptd.legislation_code is null)
             OR ( ptd.business_group_id is null and ptd.legislation_code = p_legislation_code) )
         ) OR
         (
           p_business_group_id is not null and
           p_legislation_code is null and
           ( ( ptd.business_group_id is null and ptd.legislation_code is null)
             OR (ptd.business_group_id is null and ptd.legislation_code = hr_api.return_legislation_code(p_business_group_id))
             OR (ptd.business_group_id = p_business_group_id and ptd.legislation_code is null) )
         )
       );

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_tdf_shd.api_updating
        (p_time_definition_id    => p_time_definition_id
        ,p_object_version_number => p_object_version_number);

  if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_TIME_DEFINITIONS.DEFINITION_TYPE'
     ,p_associated_column1 => 'PAY_TIME_DEFINITIONS.PERIOD_TIME_DEFINITION_ID'
     ) and (
       not l_api_updating or
       ( l_api_updating and nvl(p_period_time_definition_id, hr_api.g_number) <>
                                     nvl(pay_tdf_shd.g_old_rec.period_time_definition_id, hr_api.g_number ) )
     ) then

     if p_definition_type in ('P','E','C')
            and p_period_time_definition_id is not null  then

       fnd_message.set_name('PAY', 'PAY_34052_FLSA_ARG_NOT_NULL');
       fnd_message.set_token('ARGUMENT', 'Period Time Definition Id');
       fnd_message.raise_error;

     end if;

     if p_period_time_definition_id is not null then

       open csr_period_time_definition_id;
       fetch csr_period_time_definition_id into l_exists;

       if csr_period_time_definition_id%notfound then

         close csr_period_time_definition_id;
         fnd_message.set_name('PAY', 'PAY_34059_FLSA_ARG_INVALID');
         fnd_message.set_token('ARGUMENT', 'Period Time Definition');
         fnd_message.raise_error;

       end if;

       close csr_period_time_definition_id;

     end if;

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.PERIOD_TIME_DEFINITION_ID') then
              raise;
       end if;

    when others then
       if csr_period_time_definition_id%isopen then
          close csr_period_time_definition_id;
       end if;
       raise;

End chk_period_time_definition_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_definition_name >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Definition Name column
--
--  Prerequisites:
--     None
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_name
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_definition_name
  (p_time_definition_id        in  number,
   p_object_version_number     in  number,
   p_definition_name           in  varchar2,
   p_business_group_id         in  number,
   p_legislation_code          in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_definition_name';
  l_api_updating  boolean;
  l_exists varchar2(1);

  cursor csr_definition_name is
  select null
  from   pay_time_definitions ptd
  where  ptd.definition_name = p_definition_name
  and  (
         ( p_business_group_id is null and
           p_legislation_code is null and
           ptd.business_group_id is null and
           ptd.legislation_code is null
         ) OR
         ( p_business_group_id is null and
           p_legislation_code is not null and
           ( (ptd.business_group_id is null and ptd.legislation_code is null)
             OR ( ptd.business_group_id is null and ptd.legislation_code = p_legislation_code) )
         ) OR
         (
           p_business_group_id is not null and
           p_legislation_code is null and
           ( ( ptd.business_group_id is null and ptd.legislation_code is null)
             OR (ptd.business_group_id is null and ptd.legislation_code = hr_api.return_legislation_code(p_business_group_id))
             OR (ptd.business_group_id = p_business_group_id and ptd.legislation_code is null) )
         )
       );

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_tdf_shd.api_updating
        (p_time_definition_id    => p_time_definition_id
        ,p_object_version_number => p_object_version_number);

  if not l_api_updating or
       ( l_api_updating and nvl(p_definition_name, hr_api.g_varchar2) <>
                                     nvl(pay_tdf_shd.g_old_rec.definition_name, hr_api.g_varchar2 )
     ) then

     hr_api.mandatory_arg_error
     (p_api_name       =>  l_proc
     ,p_argument       =>  'DEFINITION_NAME'
     ,p_argument_value =>  p_definition_name
     );

     open csr_definition_name;
     fetch csr_definition_name into l_exists;

     if csr_definition_name%found then

        close csr_definition_name;

        fnd_message.set_name('PAY','PAY_34061_FLSA_DUP_NAME');
        fnd_message.raise_error;

     end if;

     close csr_definition_name;

  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.DEFINITION_NAME') then
              raise;
       end if;

    when others then
      if csr_definition_name%isopen then
         close csr_definition_name;
      end if;
      raise;

End chk_definition_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_short_name >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Short Name column
--
--  Prerequisites:
--     None
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_type
--    p_number_of_years
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_short_name
  (p_time_definition_id        in  number,
   p_object_version_number     in  number,
   p_short_name                in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_short_name';
  l_api_updating  boolean;
  l_exists varchar2(1);

  cursor csr_short_name is
  select null
  from   pay_time_definitions ptd
  where  ptd.short_name = p_short_name;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
     hr_api.mandatory_arg_error
     (p_api_name       =>  l_proc
     ,p_argument       =>  'SHORT_NAME'
     ,p_argument_value =>  p_short_name
     );

     open  csr_short_name;
     fetch csr_short_name into l_exists;

     if csr_short_name%found then

        close csr_short_name;

        fnd_message.set_name('PAY','PAY_34062_FLSA_DUP_SHORT_NAME');
        fnd_message.raise_error;

     end if;

     close csr_short_name;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.SHORT_NAME') then
              raise;
       end if;

    when others then
      if csr_short_name%isopen then
         close csr_short_name;
      end if;
      raise;

End chk_short_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_definition_type >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Definition type column
--
--  Prerequisites:
--     None
--
--  In Arguments:
--    p_time_definition_id
--    p_object_version_number
--    p_definition_type
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Procedure chk_definition_type
  (p_time_definition_id        in  number,
   p_object_version_number     in  number,
   p_definition_type           in  varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_definition_type';
  l_api_updating  boolean;
  l_exists varchar2(1);

  cursor csr_definition_type is
  select null
  from   hr_standard_lookups hrl
  where  hrl.lookup_type = 'PAY_TIME_DEFINITION_TYPE'
  and    hrl.lookup_code = p_definition_type
  and    hrl.enabled_flag = 'Y';

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
     hr_api.mandatory_arg_error
     (p_api_name       =>  l_proc
     ,p_argument       =>  'DEFINITION_TYPE'
     ,p_argument_value =>  p_definition_type
     );

     open  csr_definition_type;
     fetch csr_definition_type into l_exists;

     if csr_definition_type%notfound then

        close csr_definition_type;

        fnd_message.set_name('PAY','PAY_34059_FLSA_ARG_INVALID');
        fnd_message.set_token('ARGUMENT', 'Definition Type');
        fnd_message.raise_error;

     end if;

     close csr_definition_type;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception

    when app_exception.application_exception then
       if hr_multi_message.exception_add
         (p_associated_column1 => 'PAY_TIME_DEFINITIONS.DEFINITION_TYPE') then
              raise;
       end if;

    when others then
      if csr_definition_type%isopen then
         close csr_definition_type;
      end if;
      raise;

End chk_definition_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_legislation_code>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates the Legislation Code column
--
--  Prerequisites:
--     None
--
--  In Arguments:
--    p_legislation_code
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An error is raised if the validation fails.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure chk_legislation_code
  ( p_legislation_code  in varchar2 )
is
--
cursor csr_legislation_code is
select null
from fnd_territories
where territory_code = p_legislation_code ;
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'chk_legislation_code';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_legislation_code;
  fetch csr_legislation_code into l_exists ;

  if csr_legislation_code%notfound then
    close csr_legislation_code;
    fnd_message.set_name('PAY', 'PAY_34059_FLSA_ARG_INVALID');
    fnd_message.set_token('ARGUMENT', 'Legislation Code');
    fnd_message.raise_error;
  end if;
  close csr_legislation_code;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PAY_TIME_DEFINITIONS.LEGISLATION_CODE'
       ) then
      raise;
    end if;
  when others then
    if csr_legislation_code%isopen then
      close csr_legislation_code;
    end if;
    raise;
end chk_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_tdf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );

  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_tdf_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  if hr_startup_data_api_support.g_startup_mode not in ('GENERIC','USER') then

     --
     -- Validate Important Attributes
     --
        chk_legislation_code(p_legislation_code => p_rec.legislation_code);
     --
        hr_multi_message.end_validation_set;

  end if;
  --
  -- Validate Dependent Attributes
  --

  chk_definition_name
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_definition_name           => p_rec.definition_name,
   p_business_group_id         => p_rec.business_group_id,
   p_legislation_code          => p_rec.legislation_code
  );

  chk_short_name
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_short_name                => p_rec.short_name
  );

  chk_definition_type
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_definition_type           => p_rec.definition_type
  );

  chk_start_date
  (p_time_definition_id     => p_rec.time_definition_id,
   p_object_version_number  => p_rec.object_version_number,
   p_definition_type        => p_rec.definition_type,
   p_start_date             => p_rec.start_date
  );

  chk_number_of_years
  (p_time_definition_id     => p_rec.time_definition_id,
   p_object_version_number  => p_rec.object_version_number,
   p_definition_type        => p_rec.definition_type,
   p_number_of_years        => p_rec.number_of_years
  );

  chk_cross_validations
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_definition_type           => p_rec.definition_type,
   p_period_type               => p_rec.period_type,
   p_period_time_definition_id => p_rec.period_time_definition_id,
   p_day_adjustment            => p_rec.day_adjustment,
   p_period_unit               => p_rec.period_unit
  );

  chk_period_type
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_definition_type           => p_rec.definition_type,
   p_period_type               => p_rec.period_type
  );

  chk_period_unit
  (p_time_definition_id     => p_rec.time_definition_id,
   p_object_version_number  => p_rec.object_version_number,
   p_definition_type        => p_rec.definition_type,
   p_period_unit            => p_rec.period_unit
  );

  chk_day_adjustment
  (p_time_definition_id     => p_rec.time_definition_id,
   p_object_version_number  => p_rec.object_version_number,
   p_definition_type        => p_rec.definition_type,
   p_day_adjustment         => p_rec.day_adjustment
  );

  chk_period_time_definition_id
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_definition_type           => p_rec.definition_type,
   p_period_time_definition_id => p_rec.period_time_definition_id,
   p_business_group_id         => p_rec.business_group_id,
   p_legislation_code          => p_rec.legislation_code
  );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_tdf_shd.g_rec_type
  ,p_regenerate_periods           out nocopy boolean
  ,p_delete_periods               out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_time_def_usage boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );

  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_tdf_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  l_time_def_usage := chk_time_def_usage
                        ( p_time_definition_id  => p_rec.time_definition_id
                         ,p_definition_type     => p_rec.definition_type
                        );
  --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
    ,p_rec                => p_rec
    ,p_time_def_used      => l_time_def_usage
    ,p_regenerate_periods => p_regenerate_periods
    ,p_delete_periods     => p_delete_periods
    );
  --
  chk_definition_name
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_definition_name           => p_rec.definition_name,
   p_business_group_id         => p_rec.business_group_id,
   p_legislation_code          => p_rec.legislation_code
  );

  chk_start_date
  (p_time_definition_id     => p_rec.time_definition_id,
   p_object_version_number  => p_rec.object_version_number,
   p_definition_type        => p_rec.definition_type,
   p_start_date             => p_rec.start_date
  );

  chk_number_of_years
  (p_time_definition_id     => p_rec.time_definition_id,
   p_object_version_number  => p_rec.object_version_number,
   p_definition_type        => p_rec.definition_type,
   p_number_of_years        => p_rec.number_of_years
  );

  chk_cross_validations
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_definition_type           => p_rec.definition_type,
   p_period_type               => p_rec.period_type,
   p_period_time_definition_id => p_rec.period_time_definition_id,
   p_day_adjustment            => p_rec.day_adjustment,
   p_period_unit               => p_rec.period_unit
  );

  chk_period_type
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_definition_type           => p_rec.definition_type,
   p_period_type               => p_rec.period_type
  );

  chk_period_unit
  (p_time_definition_id     => p_rec.time_definition_id,
   p_object_version_number  => p_rec.object_version_number,
   p_definition_type        => p_rec.definition_type,
   p_period_unit            => p_rec.period_unit
  );

  chk_day_adjustment
  (p_time_definition_id     => p_rec.time_definition_id,
   p_object_version_number  => p_rec.object_version_number,
   p_definition_type        => p_rec.definition_type,
   p_day_adjustment         => p_rec.day_adjustment
  );

  chk_period_time_definition_id
  (p_time_definition_id        => p_rec.time_definition_id,
   p_object_version_number     => p_rec.object_version_number,
   p_definition_type           => p_rec.definition_type,
   p_period_time_definition_id => p_rec.period_time_definition_id,
   p_business_group_id         => p_rec.business_group_id,
   p_legislation_code          => p_rec.legislation_code
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_tdf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
  l_time_def_usage boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  chk_startup_action(false
                    ,pay_tdf_shd.g_old_rec.business_group_id
                    ,pay_tdf_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  l_time_def_usage := chk_time_def_usage
                        ( p_time_definition_id  => p_rec.time_definition_id
                         ,p_definition_type     => pay_tdf_shd.g_old_rec.definition_type
                        );

  if l_time_def_usage then

    fnd_message.set_name('PAY', 'PAY_34064_FLSA_INV_DELETE');
    fnd_message.raise_error;

  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_tdf_bus;

/
