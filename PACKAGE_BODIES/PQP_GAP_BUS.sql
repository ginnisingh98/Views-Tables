--------------------------------------------------------
--  DDL for Package Body PQP_GAP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GAP_BUS" as
/* $Header: pqgaprhi.pkb 120.0.12010000.2 2008/08/05 13:57:02 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_gap_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_gap_absence_plan_id         number         default null;
g_legislation_code            varchar2(150)  default null;
g_assignment_id               number         default null;

--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_gap_absence_plan_id                  in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from pqp_gap_absence_plans gap
         , per_all_assignments_f paa
         , per_business_groups_perf pbg
     where gap.gap_absence_plan_id = p_gap_absence_plan_id
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
    ,p_argument           => 'gap_absence_plan_id'
    ,p_argument_value     => p_gap_absence_plan_id
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
        => nvl(p_associated_column1,'GAP_ABSENCE_PLAN_ID')
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
  (p_assignment_id  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_all_assignments_f paa
         , per_business_groups_perf pbg
     where paa.assignment_id = p_assignment_id
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
    ,p_argument           => 'p_assignment_id'
    ,p_argument_value     => p_assignment_id
    );
  --
  if ( nvl(pqp_gap_bus.g_assignment_id, hr_api.g_number)
       = p_assignment_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_gap_bus.g_legislation_code;
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
    pqp_gap_bus.g_assignment_id     := p_assignment_id;
    pqp_gap_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_gap_legislation_code >---------------------|
--  ---------------------------------------------------------------------------
--
Function return_gap_legislation_code
  (p_gap_absence_plan_id  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from pqp_gap_absence_plans gap
         , per_all_assignments_f paa
         , per_business_groups_perf pbg
     where gap.gap_absence_plan_id = p_gap_absence_plan_id
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
    ,p_argument           => 'gap_absence_plan_id'
    ,p_argument_value     => p_gap_absence_plan_id
    );
  --
  if ( nvl(pqp_gap_bus.g_gap_absence_plan_id, hr_api.g_number)
       = p_gap_absence_plan_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_gap_bus.g_legislation_code;
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
    pqp_gap_bus.g_gap_absence_plan_id     := p_gap_absence_plan_id;
    pqp_gap_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_gap_legislation_code;

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
  ,p_rec in pqp_gap_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqp_gap_shd.api_updating
      (p_gap_absence_plan_id               => p_rec.gap_absence_plan_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.absence_attendance_id, hr_api.g_number) <>
     nvl(pqp_gap_shd.g_old_rec.absence_attendance_id
        ,hr_api.g_number
        ) THEN

    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'ABSENCE_ATTENDANCE_ID'
      ,p_base_table => pqp_gap_shd.g_tab_nam
      );

  END IF;
  --
End chk_non_updateable_args;

--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_absence_attendance_id >----------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate ABSENCE_ATTENDANCE_ID
--
-- Pre Conditions:
--
-- In Arguments:
--   p_absence_attendance_id
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
Procedure chk_absence_attendance_id
  (p_absence_attendance_id    in number
  ) IS
--
  Cursor ChkAbsAttId is
  Select 'Y'
  From per_absence_attendances paa
  Where paa.absence_attendance_id = p_absence_attendance_id;
--
  l_proc        varchar2(72) := g_package || 'chk_absence_attendance_id';
  l_AAValid     char(1) := 'N';
--
Begin
  --
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'absence_attendance_id'
    ,p_argument_value => p_absence_attendance_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  open ChkAbsAttId;
  fetch ChkAbsAttId into l_AAValid;
  close ChkAbsAttId;
  --
  if l_AAValid = 'N' then
    -- invalid absence attendance id
    fnd_message.set_name('PQP', 'PQP_230947_INVALID_PAA_ID');
    fnd_message.raise_error;
  end if; -- l_AAValid = 'N'
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 30);
  --
end chk_absence_attendance_id;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_pl_id >--------------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate pl_id
--
-- Pre Conditions:
--
-- In Arguments:
--   p_pl_id
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
Procedure chk_pl_id
  (p_gap_absence_plan_id  in number
  ,p_pl_id                in number
  ) IS
--
  Cursor ChkPlId is
  Select 'Y'
  From ben_pl_f bp
  Where bp.pl_id = p_pl_id;
--
  l_proc        varchar2(72) := g_package || 'chk_pl_id';
  l_PlValid     char(1) := 'N';
--
Begin
  --
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'pl_id'
    ,p_argument_value => p_pl_id
    );
  --
  if (((p_gap_absence_plan_id is not null) and
       nvl(pqp_gap_shd.g_old_rec.pl_id,hr_api.g_number)
        <> nvl(p_pl_id,hr_api.g_number))
      or
      (p_gap_absence_plan_id is null)
     ) then

    hr_utility.set_location(l_proc, 20);
    --
    begin
     open ChkPlId;
     fetch ChkPlId into l_PlValid;
     close ChkPlId;
    exception
     when others then
       l_PlValid := 'N';
    end;

    if l_PlValid = 'N' then

      -- invalid pl id
      fnd_message.set_name('PQP', 'PQP_230948_INVALID_PL_ID');
      fnd_message.raise_error;

    end if; -- l_PlValid = 'N'
    --
    hr_utility.set_location(l_proc, 30);
    --
  end if; -- (((p_gap_absence_plan_id is not null) and...
  --
  hr_utility.set_location(' Leaving: '|| l_proc, 40);
  --
end chk_pl_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqp_gap_shd.g_rec_type
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
  -- table PER_ABSENCE_ATTENDANCES as FK is available
  per_abs_bus.set_security_group_id
                (p_absence_attendance_id => p_rec.absence_attendance_id
                );

  --
  -- Validate Dependent Attributes
  --
  chk_absence_attendance_id
    (p_absence_attendance_id => p_rec.absence_attendance_id
    );
  --
  chk_pl_id
    (p_gap_absence_plan_id   => p_rec.absence_attendance_id
    ,p_pl_id                 => p_rec.pl_id
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
  ,p_rec                          in pqp_gap_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  pqp_gap_bus.set_security_group_id
                (p_gap_absence_plan_id => p_rec.gap_absence_plan_id
                );
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    );
  --
  chk_absence_attendance_id
    (p_absence_attendance_id => p_rec.absence_attendance_id
    );
  --
  chk_pl_id
    (p_gap_absence_plan_id   => p_rec.absence_attendance_id
    ,p_pl_id                 => p_rec.pl_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqp_gap_shd.g_rec_type
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
end pqp_gap_bus;

/
