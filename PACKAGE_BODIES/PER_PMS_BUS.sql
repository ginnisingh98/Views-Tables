--------------------------------------------------------
--  DDL for Package Body PER_PMS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PMS_BUS" as
/* $Header: pepmsrhi.pkb 120.2.12010000.2 2008/09/02 10:51:07 arumukhe ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pms_bus.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_scorecard_id                number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_scorecard_id                         in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_all_assignments_f paf
         , per_personal_scorecards pms
     where pms.scorecard_id = p_scorecard_id
     and pms.assignment_id = paf.assignment_id
     and paf.business_group_id = pbg.business_group_id;

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
    ,p_argument           => 'scorecard_id'
    ,p_argument_value     => p_scorecard_id
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
        => nvl(p_associated_column1,'SCORECARD_ID')
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
  (p_scorecard_id                         in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_all_assignments_f paf
         , per_personal_scorecards pms
     where pms.scorecard_id = p_scorecard_id
     and pms.assignment_id = paf.assignment_id
     and paf.business_group_id = pbg.business_group_id;

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
    ,p_argument           => 'scorecard_id'
    ,p_argument_value     => p_scorecard_id
    );
  --
  if ( nvl(per_pms_bus.g_scorecard_id, hr_api.g_number)
       = p_scorecard_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pms_bus.g_legislation_code;
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
    per_pms_bus.g_scorecard_id                := p_scorecard_id;
    per_pms_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_pms_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.scorecard_id is not null)  and (
    nvl(per_pms_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_pms_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.scorecard_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PERSONAL_SCORECARDS'
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
  ,p_rec in per_pms_shd.g_rec_type
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
  IF NOT per_pms_shd.api_updating
      (p_scorecard_id                      => p_rec.scorecard_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  if nvl(p_rec.person_id,hr_api.g_number) <>
     per_pms_shd.g_old_rec.person_id then
     l_argument := 'person_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 15);
  if nvl(p_rec.assignment_id,hr_api.g_number) <>
     per_pms_shd.g_old_rec.assignment_id then
     l_argument := 'assignment_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  if nvl(p_rec.creator_type,hr_api.g_varchar2) <>
     per_pms_shd.g_old_rec.creator_type then
     l_argument := 'creator_type';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name   => l_proc
         ,p_argument   => l_argument
         ,p_base_table => per_pms_shd.g_tab_nam);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_assignment_id >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the specified assignment exists
--   and that it is not a Benefits ('B') assignment.
--
-- Pre Conditions:
--   The assignment must already exist.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the assignment is valid.
--
-- Post Failure:
--   An application error is raised if the assignment does not exist
--   or is a Benefits assignment.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assignment_id
  (p_scorecard_id          IN         number
  ,p_object_version_number IN         number
  ,p_assignment_id         IN         number
  ,p_person_id             OUT NOCOPY number
  ) IS

  --
  l_proc          varchar2(72) := g_package || 'chk_assignment_id';
  l_api_updating  boolean;
  l_assignment_id number;
  --

  CURSOR csr_chk_assignment_id IS
  SELECT asg.assignment_id, asg.person_id
  FROM   per_all_assignments_f asg
  WHERE  asg.assignment_id = p_assignment_id
  AND    asg.assignment_type <> 'B';
--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_assignment_id'
          ,p_argument_value => p_assignment_id
          );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_pms_shd.api_updating
         (p_scorecard_id           => p_scorecard_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_pms_shd.g_old_rec.assignment_id, hr_api.g_number)
    = nvl(p_assignment_id, hr_api.g_number))
  THEN
     RETURN;
  END IF;

  --
  -- Check that the assignment is valid.
  -- No attempt is made to validate the dates of the assignment
  -- against the scorecard: it is possible to have a scorecard
  -- that starts before, or ends after, the assignment.
  -- Such validation would be possible but later changes to
  -- the assignment could invalidate the rule and it becomes
  -- unncessarily complex for little benefit.
  -- Life Events can be used to capture changes to the
  -- dates of an assignment and early end the scorecard.
  --
  OPEN  csr_chk_assignment_id;
  FETCH csr_chk_assignment_id INTO l_assignment_id
                                  ,p_person_id;
  CLOSE csr_chk_assignment_id;

  IF l_assignment_id IS null THEN
    fnd_message.set_name('PER', 'HR_50263_PMS_INVALID_ASG');
    fnd_message.raise_error;
  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_PERSONAL_SCORECARDS.ASSIGNMENT_ID')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_plan_id >------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the specified performance
--   management plan exists.
--
-- Pre Conditions:
--   The plan must already exist.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the plan is valid.
--
-- Post Failure:
--   An application error is raised if the plan does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_plan_id
  (p_scorecard_id          IN number
  ,p_object_version_number IN number
  ,p_plan_id               IN number
  ) IS

  --
  l_proc          varchar2(72) := g_package || 'chk_plan_id';
  l_api_updating  boolean;
  l_plan_id       number;
  --

  CURSOR csr_chk_plan_id IS
  SELECT pmp.plan_id
  FROM   per_perf_mgmt_plans pmp
  WHERE  pmp.plan_id = p_plan_id;
--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_pms_shd.api_updating
         (p_scorecard_id           => p_scorecard_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_pms_shd.g_old_rec.plan_id, hr_api.g_number)
    = nvl(p_plan_id, hr_api.g_number))
  THEN
     RETURN;
  END IF;

  IF p_plan_id IS NOT null THEN
    --
    -- Check that plan exists.
    --
    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;
    OPEN  csr_chk_plan_id;
    FETCH csr_chk_plan_id INTO l_plan_id;
    CLOSE csr_chk_plan_id;

    IF l_plan_id IS null THEN
      fnd_message.set_name('PER', 'HR_50264_PMS_INVALID_PLAN');
      fnd_message.raise_error;
    END IF;

  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_PERSONAL_SCORECARDS.PLAN_ID')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_plan_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_duplicate >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that a personal scorecard does not
--   already exist for the given assignment and given plan.
--
-- Pre Conditions:
--   The plan and assignment must exist and have been validated.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the scorecard is not a duplicate.
--
-- Post Failure:
--   An application error is raised if the scorecard is a duplicate.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_duplicate
  (p_scorecard_id          IN number
  ,p_object_version_number IN number
  ,p_plan_id               IN number
  ,p_assignment_id         IN number
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_duplicate';
  l_api_updating   boolean;
  l_dup            varchar2(5) := 'FALSE';
  --

  CURSOR csr_chk_duplicate IS
  SELECT 'TRUE'
  FROM   per_personal_scorecards pms
  WHERE  pms.plan_id = p_plan_id
  AND    pms.assignment_id = p_assignment_id
  AND    pms.scorecard_id <> nvl(p_scorecard_id, hr_api.g_number)
  AND    pms.STATUS_CODE <> 'TRANSFER_OUT';
--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_assignment_id'
          ,p_argument_value => p_assignment_id
          );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_pms_shd.api_updating
         (p_scorecard_id           => p_scorecard_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_pms_shd.g_old_rec.plan_id, hr_api.g_number)
    = nvl(p_plan_id, hr_api.g_number)
  AND nvl(per_pms_shd.g_old_rec.assignment_id, hr_api.g_number)
    = nvl(p_assignment_id, hr_api.g_number))
  THEN
     RETURN;
  END IF;

  IF p_plan_id IS NOT null THEN
    --
    -- Check that the plan is not a duplicate.
    --
    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;
    OPEN  csr_chk_duplicate;
    FETCH csr_chk_duplicate INTO l_dup;
    CLOSE csr_chk_duplicate;

    IF l_dup = 'TRUE' THEN
      fnd_message.set_name('PER', 'HR_50265_PMS_DUP_SCORECARD');
      fnd_message.raise_error;
    END IF;

  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_PERSONAL_SCORECARDS.PLAN_ID'
      ,p_associated_column2 => 'PER_PERSONAL_SCORECARDS.ASSIGNMENT_ID')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_duplicate;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dates >--------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the start and end date of the scorecard. It
--   first checks that the start date is earlier than the end date,
--   then it checks that the scorecard dates are within the dates of the
--   performance management plan and finally it checks that the dates
--   against the scorecard's objectives to not exceed the new dates.
--
-- Pre Conditions:
--   Where used, the plan must exist and have been validated.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the dates are valid.
--
-- Post Failure:
--   An application error is raised if the dates are invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_dates
  (p_scorecard_id          IN number
  ,p_object_version_number IN number
  ,p_plan_id               IN number
  ,p_start_date            IN date
  ,p_end_date              IN date
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_dates';
  l_api_updating   boolean;
  l_pmp_start_date date;
  l_pmp_end_date   date;
  l_row_found      varchar2(1)  := 'N';
  --

  CURSOR csr_dates_within_plan IS
  SELECT pmp.start_date, pmp.end_date
  FROM   per_perf_mgmt_plans pmp
  WHERE  pmp.plan_id = p_plan_id;

  CURSOR csr_objs_outside_scorecard IS
  SELECT 'Y'
  FROM   per_objectives obj
  WHERE  obj.scorecard_id IS NOT NULL
  AND    obj.scorecard_id = p_scorecard_id
  AND   (obj.start_date < p_start_date OR
         obj.target_date > p_end_date)
  AND    rownum = 1;

--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_start_date'
          ,p_argument_value => p_start_date
          );
  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_end_date'
          ,p_argument_value => p_end_date
          );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_pms_shd.api_updating
         (p_scorecard_id           => p_scorecard_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_pms_shd.g_old_rec.plan_id, hr_api.g_number)
    = nvl(p_plan_id, hr_api.g_number)
  AND nvl(per_pms_shd.g_old_rec.start_date, hr_api.g_date)
    = nvl(p_start_date, hr_api.g_date)
  AND nvl(per_pms_shd.g_old_rec.end_date, hr_api.g_date)
    = nvl(p_end_date, hr_api.g_date))
  THEN
     RETURN;
  END IF;

  IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

  --
  -- Check that the scorecard's start date is not later than the end date.
  --
  IF p_start_date > p_end_date THEN
    fnd_message.set_name('PER', 'HR_50266_PMS_START_END');
    fnd_message.raise_error;
  END IF;

  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  IF p_plan_id IS NOT null THEN
    --
    -- Check that the scorecard's dates are within the plan dates.
    --
    IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
    OPEN  csr_dates_within_plan;
    FETCH csr_dates_within_plan INTO l_pmp_start_date
                                    ,l_pmp_end_date;
    CLOSE csr_dates_within_plan;

    IF p_start_date < l_pmp_start_date
     OR p_end_date > l_pmp_end_date
    THEN
      fnd_message.set_name('PER', 'HR_50267_PMS_DATES_OUT_PLAN');
      fnd_message.raise_error;
    END IF;

  END IF;

  IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;

  IF p_scorecard_id IS NOT null THEN
    --
    -- Check that there are no objectives outside the range of this scorecard.
    --
    IF g_debug THEN hr_utility.set_location(l_proc, 60); END IF;
    OPEN  csr_objs_outside_scorecard;
    FETCH csr_objs_outside_scorecard INTO l_row_found;
    CLOSE csr_objs_outside_scorecard;

    IF l_row_found = 'Y'
    THEN
      fnd_message.set_name('PER', 'HR_50296_PMS_OBJ_DATES');
      fnd_message.raise_error;
    END IF;

  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_PERSONAL_SCORECARDS.START_DATE'
      ,p_associated_column2 => 'PER_PERSONAL_SCORECARDS.END_DATE')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_scorecard_name >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks that the specified assignment does not already
--   have a scorecard with a duplicate name.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the scorecard name is unique for the given
--   assignment and the p_duplicate_name_warning is set accordingly
--   (true if the name already exists; false if it does not).
--
-- Post Failure:
--   An error is raised if an unhandled exception occurs.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_scorecard_name
  (p_scorecard_id           IN  number
  ,p_object_version_number  IN  number
  ,p_assignment_id          IN  number
  ,p_scorecard_name         IN  varchar2
  ,p_duplicate_name_warning OUT NOCOPY boolean
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_scorecard_name';
  l_api_updating   boolean;
  l_dup            varchar2(5) := 'FALSE';
  --

  CURSOR csr_chk_scorecard_name IS
  SELECT 'TRUE'
  FROM   per_personal_scorecards pms
  WHERE  pms.assignment_id = p_assignment_id
  AND    pms.scorecard_id <> nvl(p_scorecard_id, hr_api.g_number)
  AND    upper(trim(pms.scorecard_name)) = upper(trim(p_scorecard_name));
--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_assignment_id'
          ,p_argument_value => p_assignment_id
          );
  --
  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_scorecard_name'
          ,p_argument_value => p_scorecard_name
          );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_pms_shd.api_updating
         (p_scorecard_id           => p_scorecard_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_pms_shd.g_old_rec.assignment_id, hr_api.g_number)
    = nvl(p_assignment_id, hr_api.g_number)
  AND nvl(per_pms_shd.g_old_rec.scorecard_name, hr_api.g_varchar2)
    = nvl(p_scorecard_name, hr_api.g_varchar2))
  THEN
     RETURN;
  END IF;

  IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

  --
  -- Warn if a scorecard with the same name already exists
  -- (case and space insensitive).
  --
  OPEN  csr_chk_scorecard_name;
  FETCH csr_chk_scorecard_name INTO l_dup;
  CLOSE csr_chk_scorecard_name;

  p_duplicate_name_warning := (l_dup = 'TRUE');

  IF g_debug THEN hr_utility.trace('p_duplicate_name_warning: '||l_dup); END IF;
  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

END chk_scorecard_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_creator_type >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the creator type is 'MANUAL' or 'AUTO'.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if p_creator_type is valid.
--
-- Post Failure:
--   An application error is raised if the creator_type is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_creator_type
  (p_creator_type            IN varchar2
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_creator_type';
  --

--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_creator_type'
          ,p_argument_value => p_creator_type
          );

  --
  -- Check that p_creator_type is valid.
  --
  IF NOT (p_creator_type = 'MANUAL' OR p_creator_type = 'AUTO')
  THEN
    fnd_message.set_name('PER', 'HR_50269_PMS_CREATOR_TYPE');
    fnd_message.raise_error;
  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_PERSONAL_SCORECARDS.CREATOR_TYPE')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_creator_type;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_status_code >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the status code is a valid lookup.
--
-- Pre Conditions:
--   The lookup needs to exist and enabled.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the status code is valid.
--
-- Post Failure:
--   An application error is raised if the status code is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_status_code
  (p_effective_date         IN  date
  ,p_scorecard_id           IN  number
  ,p_object_version_number  IN  number
  ,p_status_code            IN  varchar2
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_status_code';
  l_api_updating   boolean;
  --

--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_status_code'
          ,p_argument_value => p_status_code
          );

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_pms_shd.api_updating
         (p_scorecard_id           => p_scorecard_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_pms_shd.g_old_rec.status_code, hr_api.g_varchar2)
    = nvl(p_status_code, hr_api.g_varchar2))
  THEN
     RETURN;
  END IF;

  --
  -- Check that the status code is a valid lookup.
  --
  IF hr_api.not_exists_in_hr_lookups
    (p_effective_date  => p_effective_date
    ,p_lookup_type     => 'HR_WPM_SCORECARD_STATUS'
    ,p_lookup_code     => p_status_code)
  THEN
    fnd_message.set_name('PER', 'HR_50271_PMS_STATUS_CODE');
    fnd_message.raise_error;
  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 =>'PER_PERSONAL_SCORECARDS.STATUS_CODE')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_status_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_auto_creator_type >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks if the creator type is 'AUTO'.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   The p_created_by_plan_warning is set accordingly.
--
-- Post Failure:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_auto_creator_type
  (p_creator_type            IN varchar2
  ,p_created_by_plan_warning OUT NOCOPY boolean
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_auto_creator_type';
  --

--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  p_created_by_plan_warning := (p_creator_type = 'AUTO');

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

END chk_auto_creator_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_no_objectives >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates that the scorecard does not have any objectives
--   before it is deleted.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the scorecard does not have any objectives.
--
-- Post Failure:
--   An application error is raised if the scorecard has objectives.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_no_objectives
  (p_scorecard_id            IN number
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_no_objectives';
  l_exists         varchar2(1)  := 'N';
  --
  CURSOR csr_has_objectives IS
  SELECT 'Y'
  FROM   per_objectives obj
  WHERE  obj.scorecard_id IS NOT NULL
  AND    obj.scorecard_id = p_scorecard_id
  AND    rownum = 1;

--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  --
  -- Check whether this scorecard has any objectives.
  --
  OPEN  csr_has_objectives;
  FETCH csr_has_objectives INTO l_exists;
  CLOSE csr_has_objectives;

  IF l_exists = 'Y' THEN
    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;
    fnd_message.set_name('PER', 'HR_50229_PMS_DEL_NO_OBJ');
    fnd_message.raise_error;
  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

END chk_no_objectives;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pms_shd.g_rec_type
  ,p_person_id                    out nocopy number
  ,p_duplicate_name_warning       out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Call all supporting business operations.
  --
  --
  -- Validate the assignment first, so that the call to
  -- per_asg_bus1 does not provide a misleading error message.
  --
  chk_assignment_id
    (p_scorecard_id           => p_rec.scorecard_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_assignment_id          => p_rec.assignment_id
    ,p_person_id              => p_person_id);

  --
  -- As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- set_security_group_id procedure.
  --
  per_asg_bus1.set_security_group_id
    (p_assignment_id => p_rec.assignment_id);

  chk_plan_id
    (p_scorecard_id           => p_rec.scorecard_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_plan_id                => p_rec.plan_id);

  --
  -- End important validation
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate Independent Attributes
  --
  chk_duplicate
    (p_scorecard_id            => p_rec.scorecard_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_plan_id                 => p_rec.plan_id
    ,p_assignment_id           => p_rec.assignment_id);

  chk_dates
    (p_scorecard_id            => p_rec.scorecard_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_plan_id                 => p_rec.plan_id
    ,p_start_date              => p_rec.start_date
    ,p_end_date                => p_rec.end_date);

  chk_scorecard_name
    (p_scorecard_id            => p_rec.scorecard_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_assignment_id           => p_rec.assignment_id
    ,p_scorecard_name          => p_rec.scorecard_name
    ,p_duplicate_name_warning  => p_duplicate_name_warning);

  chk_creator_type
    (p_creator_type            => p_rec.creator_type);

  chk_status_code
    (p_effective_date          => p_effective_date
    ,p_scorecard_id            => p_rec.scorecard_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_status_code             => p_rec.status_code);

  per_pms_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pms_shd.g_rec_type
  ,p_duplicate_name_warning      out nocopy boolean
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
  -- Validate Important Attributes
  --
  chk_non_updateable_args
    (p_effective_date        => p_effective_date
    ,p_rec                   => p_rec);

  --
  -- As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- set_security_group_id procedure.
  --
  per_asg_bus1.set_security_group_id
    (p_assignment_id => p_rec.assignment_id);

  chk_plan_id
    (p_scorecard_id           => p_rec.scorecard_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_plan_id                => p_rec.plan_id);

  --
  -- End important validation
  --
  hr_multi_message.end_validation_set;

  --
  -- Validate Independent Attributes
  --
  chk_duplicate
    (p_scorecard_id           => p_rec.scorecard_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_plan_id                => p_rec.plan_id
    ,p_assignment_id          => p_rec.assignment_id);

  chk_dates
    (p_scorecard_id           => p_rec.scorecard_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_plan_id                => p_rec.plan_id
    ,p_start_date             => p_rec.start_date
    ,p_end_date               => p_rec.end_date);

  chk_scorecard_name
    (p_scorecard_id           => p_rec.scorecard_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_assignment_id          => p_rec.assignment_id
    ,p_scorecard_name         => p_rec.scorecard_name
    ,p_duplicate_name_warning => p_duplicate_name_warning);

  chk_status_code
    (p_effective_date          => p_effective_date
    ,p_scorecard_id            => p_rec.scorecard_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_status_code             => p_rec.status_code);

  per_pms_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pms_shd.g_rec_type
  ,p_created_by_plan_warning     out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Call all supporting business operations
  --
  chk_auto_creator_type
    (p_creator_type            => p_rec.creator_type
    ,p_created_by_plan_warning => p_created_by_plan_warning);

  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Check if the scorecard has any objectives before deleting.
  --
  chk_no_objectives
    (p_scorecard_id            => p_rec.scorecard_id);

  hr_utility.set_location(' Leaving:'||l_proc, 980);

End delete_validate;
--
end per_pms_bus;

/
