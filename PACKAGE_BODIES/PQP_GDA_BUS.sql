--------------------------------------------------------
--  DDL for Package Body PQP_GDA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GDA_BUS" as
/* $Header: pqgdarhi.pkb 120.0 2005/05/29 01:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_gda_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_gap_daily_absence_id        number         default null;

/*
-- Commented out set_security_group_id proc as currently
-- the proc in row handler of parent table PQP_GAP_ABSENCE_PLANS
-- does the job.
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_gap_daily_absence_id                 in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from pqp_gap_daily_absences gda
         , pqp_gap_absence_plans gap
         , per_all_assignments_f paa
         , per_business_groups_perf pbg
     where gda.gap_daily_absence_id = p_gap_daily_absence_id
       and gap.gap_absence_plan_id = gda.gap_absence_plan_id
       and paa.assignment_id = gap.assignment_id
       and pbg.business_group_id = paa.business_group_id;
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
    ,p_argument           => 'gap_daily_absence_id'
    ,p_argument_value     => p_gap_daily_absence_id
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
        => nvl(p_associated_column1,'GAP_DAILY_ABSENCE_ID')
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
*/

--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_gap_daily_absence_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from pqp_gap_daily_absences gda
         , pqp_gap_absence_plans gap
         , per_all_assignments_f paa
         , per_business_groups_perf pbg
     where gda.gap_daily_absence_id = p_gap_daily_absence_id
       and gap.gap_absence_plan_id = gda.gap_absence_plan_id
       and paa.assignment_id = gap.assignment_id
       and pbg.business_group_id = paa.business_group_id;
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
    ,p_argument           => 'gap_daily_absence_id'
    ,p_argument_value     => p_gap_daily_absence_id
    );
  --
  if ( nvl(pqp_gda_bus.g_gap_daily_absence_id, hr_api.g_number)
       = p_gap_daily_absence_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_gda_bus.g_legislation_code;
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
    pqp_gda_bus.g_gap_daily_absence_id        := p_gap_daily_absence_id;
    pqp_gda_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date               in date
  ,p_rec in pqp_gda_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqp_gda_shd.api_updating
      (p_gap_daily_absence_id              => p_rec.gap_daily_absence_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.gap_absence_plan_id, hr_api.g_number) <>
     nvl(pqp_gda_shd.g_old_rec.gap_absence_plan_id
        ,hr_api.g_number
        ) THEN

    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'GAP_ABSENCE_PLAN_ID'
      ,p_base_table => pqp_gda_shd.g_tab_nam
      );

  END IF;
  --
  IF nvl(p_rec.absence_date, hr_api.g_date) <>
     nvl(pqp_gda_shd.g_old_rec.absence_date
        ,hr_api.g_date
        ) THEN

    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'ABSENCE_DATE'
      ,p_base_table => pqp_gda_shd.g_tab_nam
      );

  END IF;
  --
End chk_non_updateable_args;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_gap_absence_plan_id >------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate gap_absence_plan_id
--
-- Pre Conditions:
--
-- In Arguments:
--   p_gap_absence_plan_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_gap_absence_plan_id
  (p_gap_absence_plan_id   in number
  ) IS
  --
  Cursor ChkGAPId is
  Select 'Y'
  From pqp_gap_absence_plans gap
  Where gap.gap_absence_plan_id = p_gap_absence_plan_id;
  --
  l_proc        varchar2(72) := g_package || 'chk_gap_absence_plan_id';
  l_GAPValid     char(1) := 'N';
  --
Begin
  --
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'gap_absence_plan_id'
    ,p_argument_value => p_gap_absence_plan_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  open ChkGAPId;
  fetch ChkGAPId into l_GAPValid;
  close ChkGAPId;

  if l_GAPValid = 'N' then

    -- invalid gap absence plan id
    fnd_message.set_name('PQP', 'PQP_230949_INVALID_GAP_ID');
    fnd_message.raise_error;

  end if; -- l_GAPValid = 'N'
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 30);
  --
end chk_gap_absence_plan_id;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_absence_date >-------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate absence_date
--
-- Pre Conditions:
--
-- In Arguments:
--   p_absence_date
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_absence_date
  (p_absence_date   in date
  ) IS
  --
  l_proc        varchar2(72) := g_package || 'chk_absence_date';
  --
Begin
  --
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'absence_date'
    ,p_argument_value => p_absence_date
    );
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 20);
  --
end chk_absence_date;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_work_pattern_day_type >----------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate work_pattern_day_type against
--   HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE is
--   'PQP_GAP_WORK_PATTERN_DAY_TYPE'.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--   p_work_pattern_day_type
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_work_pattern_day_type
  (p_gap_daily_absence_id    in number
  ,p_work_pattern_day_type   in varchar2
  ,p_effective_date          in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_work_pattern_day_type';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'work_pattern_day_type'
    ,p_argument_value => p_work_pattern_day_type
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (((p_gap_daily_absence_id is not null) and
       nvl(pqp_gda_shd.g_old_rec.work_pattern_day_type,
       hr_api.g_varchar2) <> nvl(p_work_pattern_day_type,
                                 hr_api.g_varchar2))
     or
        (p_gap_daily_absence_id is null)) then

    hr_utility.set_location(l_proc, 30);
    --
    if hr_api.not_exists_in_hr_lookups
         (p_effective_date            => p_effective_date
         ,p_lookup_type               => 'PQP_GAP_WORK_PATTERN_DAY_TYPE'
         ,p_lookup_code               => p_work_pattern_day_type
         ) then

      -- Invalid work Pattern Day Type
      fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
      fnd_message.set_token('COLUMN_NAME', 'WORK_PATTERN_DAY_TYPE');
      fnd_message.raise_error;

    end if; -- hr_api.not_exists_in_hr_lookups
    --
    hr_utility.set_location(l_proc, 40);
    --
  end if; -- (((p_gap_daily_absence_id is not null) and...
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 50);
  --
end chk_work_pattern_day_type;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_level_of_entitlement >-----------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate level_of_entitlement against
--   HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE is
--   'PQP_GAP_ENTITLEMENT_BANDS'.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--   p_level_of_entitlement
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_level_of_entitlement
  (p_gap_daily_absence_id    in number
  ,p_level_of_entitlement    in varchar2
  ,p_effective_date          in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_level_of_entitlement';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'level_of_entitlement'
    ,p_argument_value => p_level_of_entitlement
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (((p_gap_daily_absence_id is not null) and
       nvl(pqp_gda_shd.g_old_rec.level_of_entitlement,
       hr_api.g_varchar2) <> nvl(p_level_of_entitlement,
                                 hr_api.g_varchar2))
     or
        (p_gap_daily_absence_id is null)) then

    hr_utility.set_location(l_proc, 30);
    --
    if hr_api.not_exists_in_hr_lookups
         (p_effective_date            => p_effective_date
         ,p_lookup_type               => 'PQP_GAP_ENTITLEMENT_BANDS'
         ,p_lookup_code               => p_level_of_entitlement
         ) then

      -- Invalid Level of Entitlement
      fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
      fnd_message.set_token('COLUMN_NAME', 'LEVEL_OF_ENTITLEMENT');
      fnd_message.raise_error;

    end if; -- hr_api.not_exists_in_hr_lookups
    --
    hr_utility.set_location(l_proc, 40);
    --
  end if; -- (((p_gap_daily_absence_id is not null) and...
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 50);
  --
end chk_level_of_entitlement;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_level_of_pay >-----------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate level_of_pay against
--   HR_LOOKUP.LOOKUP_CODE in any one of the following
--   LOOKUP_TYPEs
--     'PQP_GB_OSP_CALENDAR_RULES', 'PQP_GB_OMP_CALENDAR_RULES' and
--     'PQP_GAP_ENTITLEMENT_BANDS'
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--   p_level_of_pay
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_level_of_pay
  (p_gap_daily_absence_id    in number
  ,p_level_of_pay    in varchar2
  ,p_effective_date          in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_level_of_pay';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'level_of_pay'
    ,p_argument_value => p_level_of_pay
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (((p_gap_daily_absence_id is not null) and
       nvl(pqp_gda_shd.g_old_rec.level_of_pay,
       hr_api.g_varchar2) <> nvl(p_level_of_pay,
                                 hr_api.g_varchar2))
     or
        (p_gap_daily_absence_id is null)) then

    hr_utility.set_location(l_proc, 30);
    --
    if hr_api.not_exists_in_hr_lookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'PQP_GB_OSP_CALENDAR_RULES'
         ,p_lookup_code           => p_level_of_pay
         ) then

      hr_utility.set_location(l_proc, 40);
      --
      if hr_api.not_exists_in_hr_lookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'PQP_GB_OMP_CALENDAR_RULES'
           ,p_lookup_code           => p_level_of_pay
           ) then

        hr_utility.set_location(l_proc, 50);
        --
        if hr_api.not_exists_in_hr_lookups
             (p_effective_date        => p_effective_date
             ,p_lookup_type           => 'PQP_GAP_ENTITLEMENT_BANDS'
             ,p_lookup_code           => p_level_of_pay
             ) then

          -- Invalid work Level of Pay
          fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
          fnd_message.set_token('COLUMN_NAME', 'LEVEL_OF_PAY');
          fnd_message.raise_error;
          --
        end if; -- PQP_GAP_ENTITLEMENT_BANDS
        --
      end if; -- PQP_GB_OMP_CALENDAR_RULES
      --
    end if; -- PQP_GB_OSP_CALENDAR_RULES
    --
    hr_utility.set_location(l_proc, 60);
    --
  end if; -- (((p_gap_daily_absence_id is not null) and...
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 70);
  --
end chk_level_of_pay;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_duration >-----------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate duration
--
-- Pre Conditions:
--
-- In Arguments:
--   p_gap_daily_absence_id
--   p_duration
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_duration
  (p_gap_daily_absence_id    in number
  ,p_duration                in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_duration';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'duration'
    ,p_argument_value => p_duration
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (((p_gap_daily_absence_id is not null) and
       nvl(pqp_gda_shd.g_old_rec.duration,
       hr_api.g_number) <> nvl(p_duration,
                                 hr_api.g_number))
     or
        (p_gap_daily_absence_id is null)) then

    hr_utility.set_location(l_proc, 30);
    --
    if NOT (p_duration between 0 and 1) then

      -- invalid duration
      fnd_message.set_name('PQP', 'PQP_230950_INVALID_DURATION');
      fnd_message.raise_error;

    end if; -- NOT (p_duration between 0 and 1)
    --
    hr_utility.set_location(l_proc, 40);
    --
  end if; -- (((p_gap_daily_absence_id is not null) and...
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 50);
  --
end chk_duration;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_duration_in_hours >--------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate duration_in_hours
--
-- Pre Conditions:
--
-- In Arguments:
--   p_gap_daily_absence_id
--   p_duration_in_hours
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_duration_in_hours
  (p_gap_daily_absence_id    in number
  ,p_duration_in_hours                in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_duration_in_hours';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  -- Duration_in_hours is mandatory only while inserting
  -- because this is a new column and existing customers
  -- will not have data in this column hence we cannot
  -- enforce this while updating
  if p_gap_daily_absence_id is null then
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'duration_in_hours'
      ,p_argument_value => p_duration_in_hours
      );
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (((p_gap_daily_absence_id is not null) and
       nvl(pqp_gda_shd.g_old_rec.duration_in_hours,
       hr_api.g_number) <> nvl(p_duration_in_hours,
                                 hr_api.g_number))
     or
        (p_gap_daily_absence_id is null)) then

    hr_utility.set_location(l_proc, 30);
    --
    if NOT (p_duration_in_hours between 0 and 24) then

      -- invalid duration_in_hours
      fnd_message.set_name('PQP', 'PQP_230951_INV_DURATION_IN_HRS');
      fnd_message.raise_error;

    end if; -- NOT (p_duration_in_hours between 0 and 24)
    --
    hr_utility.set_location(l_proc, 40);
    --
  end if; -- (((p_gap_daily_absence_id is not null) and...
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 50);
  --
end chk_duration_in_hours;
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_working_days_per_week >----------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate working_days_per_week
--
-- Pre Conditions:
--
-- In Arguments:
--   p_gap_daily_absence_id
--   p_working_days_per_week
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_working_days_per_week
  (p_gap_daily_absence_id    in number
  ,p_working_days_per_week   in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_working_days_per_week';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  -- Working_Days_Per_Week is mandatory only while inserting
  -- because this is a new column and existing customers
  -- will not have data in this column hence we cannot
  -- enforce this while updating
  if p_gap_daily_absence_id is null then
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'working_days_per_week'
      ,p_argument_value => p_working_days_per_week
      );
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (((p_gap_daily_absence_id is not null) and
       nvl(pqp_gda_shd.g_old_rec.working_days_per_week,
       hr_api.g_number) <> nvl(p_working_days_per_week,
                                 hr_api.g_number))
     or
        (p_gap_daily_absence_id is null)) then

    hr_utility.set_location(l_proc, 30);
    --
    if (p_working_days_per_week <= 0 -- Must be greater than 0
        or
        p_working_days_per_week > 7  -- Must be 7 or less
       ) then

      -- invalid working_days_per_week
      fnd_message.set_name('PQP', 'PQP_230094_INV_WRKDAYS_PERWEEK');
      fnd_message.raise_error;

    end if; -- (p_working_days_per_week <= 0..
    --
    hr_utility.set_location(l_proc, 40);
    --
  end if; -- (((p_gap_daily_absence_id is not null) and...
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 50);
  --
end chk_working_days_per_week;
--
-- LG below Procedure added
-- ---------------------------------------------------------------------------+
-- |--------------------------------< chk_fte >-------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate fte
--
-- Pre Conditions:
--
-- In Arguments:
--   p_gap_daily_absence_id
--   p_fte
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_fte
  (p_gap_daily_absence_id    in number
  ,p_fte                     in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_fte';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  -- fte is mandatory only while inserting
  -- because this is a new column and existing customers
  -- will not have data in this column hence we cannot
  -- enforce this while updating
  if p_gap_daily_absence_id is null then
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'fte'
      ,p_argument_value => p_fte
      );
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if (((p_gap_daily_absence_id is not null) and
       nvl(pqp_gda_shd.g_old_rec.fte,hr_api.g_number)
         <> nvl(p_fte, hr_api.g_number))
     or
        (p_gap_daily_absence_id is null)) then

    hr_utility.set_location(l_proc, 30);
    --
    if (p_fte <= 0 -- Must be greater than 0
        or
        p_fte > 7  -- Must be 7 or less
       ) then

      -- invalid working_days_per_week
      fnd_message.set_name('PQP', 'PQP_230094_INV_FTE');
      fnd_message.raise_error;

    end if; -- (p_working_days_per_week <= 0..
    --
    hr_utility.set_location(l_proc, 40);
    --
  end if; -- (((p_gap_daily_absence_id is not null) and...
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 50);
  --
end chk_fte;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqp_gda_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  -- Calling set_securit_group_id from row handler of parent
  -- table PQP_GAP_ABSENCE_PLANS as FK is available
  pqp_gap_bus.set_security_group_id
                (p_gap_absence_plan_id => p_rec.gap_absence_plan_id
                );
  --
  -- Validate Dependent Attributes
  --
  chk_gap_absence_plan_id
    (p_gap_absence_plan_id     => p_rec.gap_absence_plan_id
    );
  --
  chk_absence_date
    (p_absence_date            => p_rec.absence_date
    );
  --
  chk_work_pattern_day_type
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_work_pattern_day_type   => p_rec.work_pattern_day_type
    ,p_effective_date          => p_effective_date
    );
  --
  chk_level_of_entitlement
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_level_of_entitlement    => p_rec.level_of_entitlement
    ,p_effective_date          => p_effective_date
    );
  --
  chk_level_of_pay
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_level_of_pay            => p_rec.level_of_pay
    ,p_effective_date          => p_effective_date
    );
  --
  chk_duration
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_duration                => p_rec.duration
    );
  --
  chk_duration_in_hours
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_duration_in_hours       => p_rec.duration_in_hours
    );
  --
  chk_working_days_per_week
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_working_days_per_week   => p_rec.working_days_per_week
    );
  -- -- LG added chk_fte call
  chk_fte
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_fte                     => p_rec.fte
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
  ,p_rec                          in pqp_gda_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

  -- Calling set_securit_group_id from row handler of parent
  -- table PQP_GAP_ABSENCE_PLANS as FK is available
  pqp_gap_bus.set_security_group_id
                (p_gap_absence_plan_id => p_rec.gap_absence_plan_id
                );

  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  chk_gap_absence_plan_id
    (p_gap_absence_plan_id     => p_rec.gap_absence_plan_id
    );
  --
  chk_absence_date
    (p_absence_date            => p_rec.absence_date
    );
  --
  chk_work_pattern_day_type
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_work_pattern_day_type   => p_rec.work_pattern_day_type
    ,p_effective_date          => p_effective_date
    );
  --
  chk_level_of_entitlement
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_level_of_entitlement    => p_rec.level_of_entitlement
    ,p_effective_date          => p_effective_date
    );
  --
  chk_level_of_pay
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_level_of_pay            => p_rec.level_of_pay
    ,p_effective_date          => p_effective_date
    );
  --
  chk_duration
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_duration                => p_rec.duration
    );
  --
  chk_duration_in_hours
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_duration_in_hours       => p_rec.duration_in_hours
    );
  chk_working_days_per_week
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_working_days_per_week   => p_rec.working_days_per_week
    );
    -- LG added below call to chk_fte
  chk_fte
    (p_gap_daily_absence_id    => p_rec.gap_absence_plan_id
    ,p_fte                     => p_rec.fte
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqp_gda_shd.g_rec_type
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
end pqp_gda_bus;

/
