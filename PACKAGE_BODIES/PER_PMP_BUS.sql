--------------------------------------------------------
--  DDL for Package Body PER_PMP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PMP_BUS" as
/* $Header: pepmprhi.pkb 120.8.12010000.4 2010/01/27 15:51:33 rsykam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pmp_bus.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< return_status_code >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Returns the plan's status.
--
-- Prerequisites:
--   The plan must already exist and p_plan_id must have a value.
--
-- In Arguments:
--   p_plan_id
--
-- Post Success:
--   The plan's status is returned as a varchar2.
--
-- Post Failure:
--   Null is returned.
--
-- Access Status:
--   Internal Oracle Use Only.
--
-- ----------------------------------------------------------------------------
function return_status_code
  (p_plan_id in number) return varchar2
is
--
  l_proc   varchar2(72) := g_package || 'return_status_code';
  l_status_code            per_perf_mgmt_plans.status_code%TYPE;

  CURSOR csr_get_status_code IS
  SELECT pmp.status_code
  FROM   per_perf_mgmt_plans pmp
  WHERE  pmp.plan_id = p_plan_id;

begin

  hr_utility.set_location('Entering:'||l_proc,10);

  --
  -- Only attempt to get the plan's status if the procedure has been
  -- called correctly.
  --
  IF p_plan_id IS NOT NULL THEN

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;
    OPEN  csr_get_status_code;
    FETCH csr_get_status_code INTO l_status_code;
    CLOSE csr_get_status_code;

  END IF;

  hr_utility.set_location('Leaving:'||l_proc,980);
  RETURN l_status_code;

end return_status_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< return_ovn >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Returns the plan's object version number.
--
-- Prerequisites:
--   The plan must already exist and p_plan_id must have a value.
--
-- In Arguments:
--   p_plan_id
--
-- Post Success:
--   The plan's OVN is returned as a number.
--
-- Post Failure:
--   Null is returned.
--
-- Access Status:
--   Internal Oracle Use Only.
--
-- ----------------------------------------------------------------------------
function return_ovn
  (p_plan_id in number) return number
is
--
  l_proc   varchar2(72) := g_package || 'return_ovn';
  l_ovn    number;

  CURSOR csr_get_ovn IS
  SELECT pmp.object_version_number
  FROM   per_perf_mgmt_plans pmp
  WHERE  pmp.plan_id = p_plan_id;

begin

  hr_utility.set_location('Entering:'||l_proc,10);

  --
  -- Only attempt to get the plan's status if the procedure has been
  -- called correctly.
  --
  IF p_plan_id IS NOT NULL THEN

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;
    OPEN  csr_get_ovn;
    FETCH csr_get_ovn INTO l_ovn;
    CLOSE csr_get_ovn;

  END IF;

  hr_utility.set_location('Leaving:'||l_proc,980);
  RETURN l_ovn;

end return_ovn;
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
  (p_rec in per_pmp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.plan_id is not null)  and (
    nvl(per_pmp_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_pmp_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.plan_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PERF_MGMT_PLANS'
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
  ,p_rec in per_pmp_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_pmp_shd.api_updating
      (p_plan_id                           => p_rec.plan_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_plan_name >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks the uniqueness of the plan name.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  If the name is a duplicate, a warning is set.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_plan_name
  (p_plan_id                in  number
  ,p_object_version_number  in  number
  ,p_plan_name              in  varchar2
  ,p_start_date             in  date
  ,p_end_date               in  date
  ,p_duplicate_name_warning out nocopy boolean
  ) is

  -- Declare the cursor

    cursor csr_plan_name is
    select 'Y'
    from  per_perf_mgmt_plans pmp
    where pmp.plan_id <> nvl(p_plan_id, hr_api.g_number)
    and   upper(trim(pmp.plan_name)) = upper(trim(p_plan_name))
    and   (p_start_date between pmp.start_date and pmp.end_date OR
           pmp.start_date between p_start_date and p_end_date);

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_plan_name';
    l_api_updating boolean;
    l_dup          varchar2(1)  := 'N';

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_plan_name'
            ,p_argument_value => p_plan_name
            );

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.plan_name, hr_api.g_varchar2)
      = nvl(p_plan_name, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Warn if an plan with this name already exists.
    --
    open csr_plan_name;
    fetch csr_plan_name into l_dup;
    close csr_plan_name;

    p_duplicate_name_warning := (l_dup = 'Y');

    IF g_debug THEN hr_utility.trace('p_duplicate_name_warning: '||l_dup); END IF;
    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

End chk_plan_name;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_administrator_person_id >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the person_id of administrator is valid person.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the person_id is valid.
--
-- Post Failure:
--  An application error is raised if the person_id is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_administrator_person_id
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_effective_date          in  date
  ,p_administrator_person_id in  number
  ) is

  -- Declare the cursor

    cursor csr_admin_person_id is
    select 'Y'
    from   per_all_people_f ppf
    where  ppf.person_id = p_administrator_person_id
    and    p_effective_date between ppf.effective_start_date and ppf.effective_end_date;


 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_administrator_person_id';
    l_api_updating boolean;
    l_exists       varchar2(1)  := 'N';

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_administrator_person_id'
            ,p_argument_value => p_administrator_person_id
            );

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.administrator_person_id, hr_api.g_number)
      = nvl(p_administrator_person_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- check if person exists.
    --
    open  csr_admin_person_id;
    fetch csr_admin_person_id into l_exists;
    close csr_admin_person_id;

    IF (l_exists is null or l_exists <> 'Y') THEN
        fnd_message.set_name('PER', 'HR_50232_WPM_PLAN_ADMIN');
        fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.ADMINISTRATOR_PERSON_ID'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_administrator_person_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_previous_plan_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the previous_plan_id is a valid plan and is different
--   to the current plan.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the previous_plan_id is valid.
--
-- Post Failure:
--  An application error is raised if the previous_plan_id is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_previous_plan_id
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_effective_date          in  date
  ,p_start_date              in  date
  ,p_previous_plan_id        in  number
  ) is

  -- Declare the cursor

    cursor csr_previous_plan is
    select 'Y'
    from   per_perf_mgmt_plans pmp
    where  pmp.plan_id = p_previous_plan_id
    and    pmp.start_date < p_start_date
    and    pmp.plan_id <> nvl(p_plan_id, hr_api.g_number);

    cursor csr_plan_overlap is
    select end_date
    from per_perf_mgmt_plans pmp
    where  pmp.plan_id = p_previous_plan_id;


 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_previous_plan_id';
    l_api_updating boolean;
    l_exists       varchar2(1)  := 'N';
    l_end_date     date;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id               => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.previous_plan_id, hr_api.g_number)
      = nvl(p_previous_plan_id, hr_api.g_number)
    AND nvl(per_pmp_shd.g_old_rec.start_date, hr_api.g_date)
      = nvl(p_start_date, hr_api.g_date))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    IF p_previous_plan_id IS NOT NULL THEN
        --
        -- Check if the previous plan exists.
        --
        open  csr_previous_plan;
        fetch csr_previous_plan into l_exists;
        close csr_previous_plan;

        IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

        IF (l_exists is null or l_exists <> 'Y') THEN
            IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
            fnd_message.set_name('PER', 'HR_50423_WPM_PRVPLAN');
            fnd_message.raise_error;
        END IF;
	--
        -- Check that the current plan start date is after the previous
        -- plan end date
        --
        open  csr_plan_overlap;
        fetch csr_plan_overlap into l_end_date;
        close csr_plan_overlap;

 	IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;

        IF (l_end_date > p_start_date) THEN
          IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;
          fnd_message.set_name('PER', 'HR_50419_WPM_PLAN_OVERLAP');
          fnd_message.raise_error;
        END IF;

    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.PREVIOUS_PLAN_ID'
    ,p_associated_column2 =>  'PER_PERF_MGMT_PLANS.START_DATE'
    ) then
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    end if;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_previous_plan_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_start_from_to_date >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the plan start date is not greater than the plan end date.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the dates are valid.
--
-- Post Failure:
--  An application error is raised if the dates are not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_start_from_to_date
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_start_date              in date
  ,p_end_date                in date
  ,p_status_code             in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_start_from_to_date';
    l_api_updating boolean;

Begin

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
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.start_date, hr_api.g_date)
      = nvl(p_start_date, hr_api.g_date)
    AND nvl(per_pmp_shd.g_old_rec.end_date, hr_api.g_date)
      = nvl(p_end_date, hr_api.g_date))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the valid from date is not greater than the valid to date.
    --
    IF (p_start_date > p_end_date) THEN
       fnd_message.set_name('PER','HR_50233_WPM_PLAN_DATES');
       fnd_message.raise_error;
    END IF;
    --
    IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;
    --
    IF (l_api_updating AND p_status_code <> 'DRAFT' AND
        nvl(per_pmp_shd.g_old_rec.start_date, hr_api.g_date)
	<> nvl(p_start_date, hr_api.g_date))
    THEN
       fnd_message.set_name('PER','HR_50395_WPM_ST_DATE_UPD');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.START_DATE'
    ,p_associated_column2 =>  'PER_PERF_MGMT_PLANS.END_DATE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_start_from_to_date;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_status_code >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the status code is a valid lookup code in the lookup type
--   HR_WPM_PLAN_STATUS.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the status code is valid.
--
-- Post Failure:
--  An application error is raised if the status code is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_status_code
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_effective_date          in  date
  ,p_status_code             in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_status_code';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
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
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.status_code, hr_api.g_varchar2)
      = nvl(p_status_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'HR_WPM_PLAN_STATUS'
         ,p_lookup_code           => p_status_code
         ) THEN
       fnd_message.set_name('PER','HR_50234_WPM_PLAN_STATUS');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.STATUS_CODE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_status_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_hierarchy_type_code >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the hierarchy type code is a valid lookup code in the
--   lookup type HR_WPM_PLAN_HIER_TYPE.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the hierarchy type code is valid.
--
-- Post Failure:
--  An application error is raised if the hierarchy type code is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_hierarchy_type_code
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_effective_date          in  date
  ,p_hierarchy_type_code     in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_hierarchy_type_code';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the hierarchy type is valid
    --
    IF (p_hierarchy_type_code IS NOT NULL) THEN
      IF hr_api.not_exists_in_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_lookup_type           => 'HR_WPM_PLAN_HIER_TYPE'
           ,p_lookup_code           => p_hierarchy_type_code
           ) THEN
         fnd_message.set_name('PER','HR_50235_WPM_PLAN_HIER_TYP');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.HIERARCHY_TYPE_CODE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_hierarchy_type_code;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_supervisor_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the supervisor id is valid person id PER_ALL_PEOPLE_F.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the supervisor id is valid.
--
-- Post Failure:
--  An application error is raised if the supervisor id is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_supervisor_id
  (p_plan_id               in  number
  ,p_object_version_number in  number
  ,p_effective_date        in  date
  ,p_hierarchy_type_code   in  varchar2
  ,p_supervisor_id         in  number
  ) is

  -- Declare the cursor

    cursor csr_supervisor_id is
    select 'Y'
    from   per_all_people_f ppf
    where  ppf.person_id = p_supervisor_id
    and    p_effective_date between ppf.effective_start_date and ppf.effective_end_date;

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_supervisor_id';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.supervisor_id, hr_api.g_number)
      = nvl(p_supervisor_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Validate the parameter has been entered.
    --
    IF p_hierarchy_type_code IS NOT null AND
       p_hierarchy_type_code = 'SUP' THEN
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_supervisor_id'
              ,p_argument_value => p_supervisor_id
              );
    END IF;

    IF p_supervisor_id IS NOT null THEN
      --
      -- Checks that the supervisor is valid person
      --
      open csr_supervisor_id;
      fetch csr_supervisor_id into l_exist;
      close csr_supervisor_id;

      IF (l_exist IS NULL) THEN
         fnd_message.set_name('PER','HR_50236_WPM_PLAN_SUPERVISOR');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.SUPERVISOR_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_supervisor_id;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_supervisor_assignment_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the supervisor assignment is a valid person id
--   PER_ALL_ASSIGNMENTS_F.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the supervisor assignment id is valid.
--
-- Post Failure:
--  An application error is raised if the supervisor assignment id is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_supervisor_assignment_id
  (p_plan_id                  in  number
  ,p_object_version_number    in  number
  ,p_effective_date           in  date
  ,p_hierarchy_type_code      in  varchar2
  ,p_supervisor_assignment_id in  number
  ) is

  -- Declare the cursor

    cursor csr_supervisor_assignment_id is
    select 'Y'
    from   per_all_assignments_f paf
    where  paf.assignment_id = p_supervisor_assignment_id
    and    p_effective_date between
           paf.effective_start_date and paf.effective_end_date;

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_supervisor_assignment_id';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.supervisor_assignment_id, hr_api.g_number)
      = nvl(p_supervisor_assignment_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    -- Validate the parameter has been entered.
    --
    IF p_hierarchy_type_code IS NOT null AND
       p_hierarchy_type_code = 'SUP_ASG' THEN
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_supervisor_assignment_id'
              ,p_argument_value => p_supervisor_assignment_id
              );
    END IF;

    IF p_supervisor_assignment_id IS NOT null THEN
      --
      -- Checks that the supervisor assignment is valid
      --
      open csr_supervisor_assignment_id;
      fetch csr_supervisor_assignment_id into l_exist;
      close csr_supervisor_assignment_id;

      IF (l_exist IS NULL) THEN
         fnd_message.set_name('PER','HR_50237_WPM_PLAN_SUP_ASG');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.SUPERVISOR_ASSIGNMENT_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_supervisor_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_organization_structure_id >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the organization structure id exists in the table
--   PER_ORGANIZATION_STRUCTURES.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the organization structure id exists.
--
-- Post Failure:
--  An application error is raised if the organization structure id does not
--  exists.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_organization_structure_id
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_hierarchy_type_code       in  varchar2
  ,p_organization_structure_id in  number
  ) is

  -- Declare the cursor

    cursor csr_org_structure_id is
    select 'Y'
    from   per_organization_structures pos
    where  pos.organization_structure_id = p_organization_structure_id;

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_organization_structure_id';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.organization_structure_id, hr_api.g_number)
      = nvl(p_organization_structure_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Validate the parameter has been entered.
    --
    IF p_hierarchy_type_code IS NOT null AND
       p_hierarchy_type_code = 'ORG' THEN
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_organization_structure_id'
              ,p_argument_value => p_organization_structure_id
              );
    END IF;

    IF p_organization_structure_id IS NOT null THEN
      --
      -- Checks that the organization structure exists
      --
      open csr_org_structure_id;
      fetch csr_org_structure_id into l_exist;
      close csr_org_structure_id;

      IF (l_exist IS NULL) THEN
         fnd_message.set_name('PER','HR_50238_WPM_PLAN_ORG_HIER');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.ORGANIZATION_STRUCTURE_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_organization_structure_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_org_structure_version_id >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the organization structure version id exists in the table
--   PER_ORG_STRUCTURE_VERSIONS.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the organization structure version id exists.
--
-- Post Failure:
--  An application error is raised if the organization structure version id
--  does not exists.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_org_structure_version_id
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_hierarchy_type_code       in  varchar2
  ,p_org_structure_version_id  in  number
  ) is

  -- Declare the cursor

    cursor csr_org_structure_version_id is
    select 'Y'
    from   per_org_structure_versions psv
    where  psv.org_structure_version_id = p_org_structure_version_id;

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_org_structure_version_id';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.org_structure_version_id, hr_api.g_number)
      = nvl(p_org_structure_version_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Validate the parameter has been entered.
    --
    IF p_hierarchy_type_code IS NOT null AND
       p_hierarchy_type_code = 'ORG' THEN
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_org_structure_version_id'
              ,p_argument_value => p_org_structure_version_id
              );
    END IF;

    IF p_org_structure_version_id IS NOT null THEN
      --
      -- Checks that the org structure version exists
      --
      open csr_org_structure_version_id;
      fetch csr_org_structure_version_id into l_exist;
      close csr_org_structure_version_id;

      IF (l_exist IS NULL) THEN
         fnd_message.set_name('PER','HR_50239_WPM_PLAN_ORG_HIER_VER');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.ORG_STRUCTURE_VERSION_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_org_structure_version_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_org_structure_version >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the hierarchy version is valid for given organization structure.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the organization structure version is valid.
--
-- Post Failure:
--  An application error is raised if the organization structure version is
--  not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_org_structure_version
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_organization_structure_id in  number
  ,p_org_structure_version_id  in  number
  ) is

  -- Declare the cursor

    cursor csr_org_structure_version_id is
    select 'Y'
    from   per_org_structure_versions psv
    where  psv.organization_structure_id = p_organization_structure_id
    and    psv.org_structure_version_id = p_org_structure_version_id;

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_org_structure_version';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.organization_structure_id, hr_api.g_number)
      = nvl(p_organization_structure_id, hr_api.g_number)
    AND nvl(per_pmp_shd.g_old_rec.org_structure_version_id, hr_api.g_number)
      = nvl(p_org_structure_version_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    IF p_organization_structure_id IS NOT null AND
       p_org_structure_version_id IS NOT null THEN
      --
      -- Checks that the hierarchy version is valid for given structure
      --
      open csr_org_structure_version_id;
      fetch csr_org_structure_version_id into l_exist;
      close csr_org_structure_version_id;

      IF (l_exist IS NULL) THEN
         fnd_message.set_name('PER','HR_50241_WPM_PLAN_INV_ORG_HIER');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.ORGANIZATION_STRUCTURE_ID'
    ,p_associated_column2 =>  'PER_PERF_MGMT_PLANS.ORG_STRUCTURE_VERSION_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_org_structure_version;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_top_organization_id >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the organization id exists in the table
--   PER_ORG_STRUCTURE_ELEMENTS.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the organization id exists.
--
-- Post Failure:
--  An application error is raised if the organization id
--  does not exists.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_top_organization_id
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_hierarchy_type_code       in  varchar2
  ,p_top_organization_id       in  number
  ,p_org_structure_version_id  in  number
  ) is

  -- Declare the cursor
    cursor csr_org_id is
    select 'Y'
    from   per_org_structure_elements pse
    where  pse.organization_id_parent = p_top_organization_id
    and   (p_org_structure_version_id IS null OR
            (p_org_structure_version_id IS NOT null AND
             pse.org_structure_version_id = p_org_structure_version_id));

  -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_top_organization_id';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.org_structure_version_id, hr_api.g_number)
      = nvl(p_org_structure_version_id, hr_api.g_number)
    AND nvl(per_pmp_shd.g_old_rec.top_organization_id, hr_api.g_number)
      = nvl(p_top_organization_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    --
    -- Validate the parameter has been entered.
    --
    IF p_hierarchy_type_code IS NOT null AND
       p_hierarchy_type_code = 'ORG' THEN
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_top_organization_id'
              ,p_argument_value => p_top_organization_id
              );
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    IF p_top_organization_id IS NOT null THEN
      --
      -- Checks that the org exists
      --
      open csr_org_id;
      fetch csr_org_id into l_exist;
      close csr_org_id;

      IF (l_exist IS NULL) THEN
        fnd_message.set_name('PER','HR_50388_WPM_PLAN_ORG');
        fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.TOP_ORGANIZATION_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_top_organization_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_position_structure_id >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the position structure id exists in the table
--   PER_POSITION_STRUCTURES.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the position structure id exists.
--
-- Post Failure:
--  An application error is raised if the position structure id does not
--  exists.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_position_structure_id
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_hierarchy_type_code       in  varchar2
  ,p_position_structure_id     in  number
  ) is

  -- Declare the cursor

    cursor csr_pos_structure_id is
    select 'Y'
    from   per_position_structures pps
    where  pps.position_structure_id = p_position_structure_id;

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_position_structure_id';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.position_structure_id, hr_api.g_number)
      = nvl(p_position_structure_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    --
    -- Validate the parameter has been entered.
    --
    IF p_hierarchy_type_code IS NOT null AND
       p_hierarchy_type_code = 'POS' THEN
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_position_structure_id'
              ,p_argument_value => p_position_structure_id
              );
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    IF p_position_structure_id IS NOT null THEN
      --
      -- Checks that the position structure exists
      --
      open csr_pos_structure_id;
      fetch csr_pos_structure_id into l_exist;
      close csr_pos_structure_id;

      IF (l_exist IS NULL) THEN
         fnd_message.set_name('PER','HR_50242_WPM_PLAN_POS_HIER');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.POSITION_STRUCTURE_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_position_structure_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_pos_structure_version_id >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the position structure version id exists in the table
--   PER_POS_STRUCTURE_VERSIONS.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the position structure version id exists.
--
-- Post Failure:
--  An application error is raised if the position structure version id
--  does not exists.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_pos_structure_version_id
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_hierarchy_type_code       in  varchar2
  ,p_pos_structure_version_id  in  number
  ) is

  -- Declare the cursor

    cursor csr_pos_structure_version_id is
    select 'Y'
    from   per_pos_structure_versions ppv
    where  ppv.pos_structure_version_id = p_pos_structure_version_id;

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_pos_structure_version_id';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.pos_structure_version_id, hr_api.g_number)
      = nvl(p_pos_structure_version_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Validate the parameter has been entered.
    --
    IF p_hierarchy_type_code IS NOT null AND
       p_hierarchy_type_code = 'POS' THEN
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_pos_structure_version_id'
              ,p_argument_value => p_pos_structure_version_id
              );
    END IF;

    IF p_pos_structure_version_id IS NOT null THEN
      --
      -- Checks that the pos structure version exists
      --
      open csr_pos_structure_version_id;
      fetch csr_pos_structure_version_id into l_exist;
      close csr_pos_structure_version_id;

      IF (l_exist IS NULL) THEN
         fnd_message.set_name('PER','HR_50243_WPM_PLAN_POS_HER_VER');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.POS_STRUCTURE_VERSION_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_pos_structure_version_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_pos_structure_version >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the hierarchy version is valid for given position structure.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the position structure version is valid.
--
-- Post Failure:
--  An application error is raised if the position structure version is
--  not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_pos_structure_version
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_position_structure_id     in  number
  ,p_pos_structure_version_id  in  number
  ) is

  -- Declare the cursor

    cursor csr_pos_structure_version_id is
    select 'Y'
    from   per_pos_structure_versions psv
    where  psv.position_structure_id = p_position_structure_id
    and    psv.pos_structure_version_id = p_pos_structure_version_id;

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_pos_structure_version';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.position_structure_id, hr_api.g_number)
      = nvl(p_position_structure_id, hr_api.g_number)
    AND nvl(per_pmp_shd.g_old_rec.pos_structure_version_id, hr_api.g_number)
      = nvl(p_pos_structure_version_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    IF p_position_structure_id IS NOT null AND
       p_pos_structure_version_id IS NOT null THEN
      --
      -- Checks that the hierarchy version is valid for given structure
      --
      open csr_pos_structure_version_id;
      fetch csr_pos_structure_version_id into l_exist;
      close csr_pos_structure_version_id;

      IF (l_exist IS NULL) THEN
         fnd_message.set_name('PER','HR_50244_WPM_PLAN_INV_POS_HIER');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.POSITION_STRUCTURE_ID'
    ,p_associated_column2 =>  'PER_PERF_MGMT_PLANS.POS_STRUCTURE_VERSION_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_pos_structure_version;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_top_position_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the position id exists in the table
--   HR_ALL_POSITION_F.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the organization id exists.
--
-- Post Failure:
--  An application error is raised if the organization id
--  does not exists.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_top_position_id
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_hierarchy_type_code       in  varchar2
  ,p_pos_structure_version_id  in  number
  ,p_top_position_id           in  number
  ) is

  -- Declare the cursor
    cursor csr_pos_id is
    select 'Y'
    from   per_pos_structure_elements pos
    where  pos.parent_position_id = p_top_position_id
    and   (p_pos_structure_version_id IS null OR
            (p_pos_structure_version_id IS NOT null AND
             pos.pos_structure_version_id = p_pos_structure_version_id));

  -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_top_position_id';
    l_api_updating boolean;
    l_exist        varchar2(1);
Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.pos_structure_version_id, hr_api.g_number)
      = nvl(p_pos_structure_version_id, hr_api.g_number)
    AND nvl(per_pmp_shd.g_old_rec.top_position_id, hr_api.g_number)
      = nvl(p_top_position_id, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Validate the parameter has been entered.
    --
    IF p_hierarchy_type_code IS NOT null AND
       p_hierarchy_type_code = 'POS' THEN
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_top_position_id'
              ,p_argument_value => p_top_position_id
              );
    END IF;

    IF p_top_position_id IS NOT null THEN
      --
      -- Checks that the pos exists
      --
      open csr_pos_id;
      fetch csr_pos_id into l_exist;
      close csr_pos_id;

      IF (l_exist IS NULL) THEN
         fnd_message.set_name('PER','HR_50389_WPM_PLAN_POS');
         fnd_message.raise_error;
      END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.TOP_POSITION_ID'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_top_position_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_hierarchy_levels >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the hierarchy level is not a negative value.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the hierarchy level is valid.
--
-- Post Failure:
--  An application error is raised if the hierarchy level is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_hierarchy_levels
  (p_plan_id               in  number
  ,p_object_version_number in  number
  ,p_hierarchy_levels      in  number
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_hierarchy_levels';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_levels, hr_api.g_number)
      = nvl(p_hierarchy_levels, hr_api.g_number))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the hierarchy levels is not negative number
    --
    IF (p_hierarchy_levels IS NOT NULL AND p_hierarchy_levels < 0) THEN
       fnd_message.set_name('PER','HR_50245_WPM_PLAN_HIER_LEVEL');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.HIERARCHY_LEVELS'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_hierarchy_levels;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_automatic_enrollment_flag >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the automatic enrollment flag is a valid lookup code in the
--   lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the automatic enrollment flag is valid.
--
-- Post Failure:
--  An application error is raised if the automatic enrollment flag is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_automatic_enrollment_flag
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_effective_date            in  date
  ,p_automatic_enrollment_flag in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_automatic_enrollment_flag';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_automatic_enrollment_flag'
            ,p_argument_value => p_automatic_enrollment_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.automatic_enrollment_flag, hr_api.g_varchar2)
      = nvl(p_automatic_enrollment_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_automatic_enrollment_flag
         ) THEN
       fnd_message.set_name('PER','HR_50246_WPM_PLAN_AUTO_ENROL_E');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.AUTOMATIC_ENROLLMENT_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_automatic_enrollment_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_assignment_types_code >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the assignment types code is a valid lookup code in the
--   lookup type HR_WPM_ASSIGNMENT_TYPES.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the assignment types code is valid.
--
-- Post Failure:
--  An application error is raised if the assignment types code is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_assignment_types_code
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_effective_date          in  date
  ,p_assignment_types_code   in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_assignment_types_code';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_assignment_types_code'
            ,p_argument_value => p_assignment_types_code
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.assignment_types_code, hr_api.g_varchar2)
      = nvl(p_assignment_types_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'HR_WPM_ASSIGNMENT_TYPES'
         ,p_lookup_code           => p_assignment_types_code
         ) THEN
       fnd_message.set_name('PER','HR_50248_WPM_PLAN_ASG_TYP_CD');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.ASSIGNMENT_TYPES_CODE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_assignment_types_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_primary_asg_only_flag >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the primary asg only flag is a valid lookup code in the
--   lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the primary asg only flag is valid.
--
-- Post Failure:
--  An application error is raised if the primary asg only flag is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_primary_asg_only_flag
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_effective_date          in  date
  ,p_primary_asg_only_flag   in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_primary_asg_only_flag';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_primary_asg_only_flag'
            ,p_argument_value => p_primary_asg_only_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.primary_asg_only_flag, hr_api.g_varchar2)
      = nvl(p_primary_asg_only_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_primary_asg_only_flag
         ) THEN
       fnd_message.set_name('PER','HR_50249_WPM_PLAN_PRI_ASG_FLG');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.PRIMARY_ASG_ONLY_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_primary_asg_only_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_hier_type_primary_asg >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the primary asg only flag is not selected when the plan
--   hiererchy type is 'Supervisor Assignment'.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the primary asg only flag is selected with the plan
--  hiererchy type of 'Supervisor Assignment'.
--
-- Post Failure:
--  An application error is raised if the primary asg only flag is selected with
--   the plan hiererchy type of 'Supervisor Assignment'.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_hier_type_primary_asg
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_hierarchy_type_code     in  varchar2
  ,p_primary_asg_only_flag   in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_hier_type_primary_asg';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_primary_asg_only_flag'
            ,p_argument_value => p_primary_asg_only_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.hierarchy_type_code, hr_api.g_varchar2)
      = nvl(p_hierarchy_type_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.primary_asg_only_flag, hr_api.g_varchar2)
      = nvl(p_primary_asg_only_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks Primary Asg only option is not selected when plan hierarchy
    -- is 'Supervisor Assignment'.
    --
    IF (p_hierarchy_type_code IS NOT null AND
        p_hierarchy_type_code = 'SUP_ASG' AND
        p_primary_asg_only_flag = 'Y') THEN
       fnd_message.set_name('PER','HR_50251_WPM_PLAN_PRI_ASG_VAL');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.PRIMARY_ASG_ONLY_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_hier_type_primary_asg;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_include_obj_set_flag >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the include objective setting flag is a valid lookup code in
--   lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the include objective setting flag is valid.
--
-- Post Failure:
--  An application error is raised if the include objective setting flag is
--  not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_include_obj_set_flag
  (p_plan_id                  in  number
  ,p_object_version_number    in  number
  ,p_effective_date           in  date
  ,p_include_obj_setting_flag in  varchar2
  ,p_obj_setting_start_date   in  date
  ,p_method_code              in  varchar2
  ,p_notify_population_flag   in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_include_obj_set_flag';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_include_obj_setting_flag'
            ,p_argument_value => p_include_obj_setting_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.include_obj_setting_flag, hr_api.g_varchar2)
      = nvl(p_include_obj_setting_flag, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.obj_setting_start_date, hr_api.g_date)
      = nvl(p_obj_setting_start_date, hr_api.g_date)
    AND nvl(per_pmp_shd.g_old_rec.method_code, hr_api.g_varchar2)
      = nvl(p_method_code, hr_api.g_varchar2)
    AND nvl(per_pmp_shd.g_old_rec.notify_population_flag, hr_api.g_varchar2)
      = nvl(p_notify_population_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_include_obj_setting_flag
         ) THEN
       fnd_message.set_name('PER','HR_50252_WPM_PLAN_INC_OBJ_SET');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

    --
    -- If flag is set to 'Y' , then check floowing mandatory fields are entered
    --
    IF (p_include_obj_setting_flag = 'Y') THEN
      --
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_obj_setting_start_date'
              ,p_argument_value => p_obj_setting_start_date
              );
      --
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_method_code'
              ,p_argument_value => p_method_code
              );
      --
      hr_api.mandatory_arg_error
              (p_api_name       => l_proc
              ,p_argument       => 'p_notify_population_flag'
              ,p_argument_value => p_notify_population_flag
              );
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.INCLUDE_OBJ_SETTING_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_include_obj_set_flag;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_obj_set_start_end >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the objective setting start date is not greater than the
--    objective setting deadline.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the dates are valid.
--
-- Post Failure:
--  An application error is raised if the dates are not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_obj_set_start_end
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_obj_setting_start_date  in date
  ,p_obj_setting_deadline    in date
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_obj_set_start_end';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.obj_setting_start_date, hr_api.g_date)
      = nvl(p_obj_setting_start_date, hr_api.g_date)
    AND nvl(per_pmp_shd.g_old_rec.obj_setting_deadline, hr_api.g_date)
      = nvl(p_obj_setting_deadline, hr_api.g_date))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    IF (p_obj_setting_start_date IS NOT NULL AND
        p_obj_setting_deadline IS NOT NULL)
    THEN
        --
        -- Checks that the valid from date is not greater than the valid to date.
        --
        IF (p_obj_setting_start_date > p_obj_setting_deadline) THEN
           fnd_message.set_name('PER','HR_50253_WPM_PLAN_OBJ_SET_ST');
           fnd_message.raise_error;
        END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.OBJ_SETTING_START_DATE'
    ,p_associated_column2 =>  'PER_PERF_MGMT_PLANS.OBJ_SETTING_DEADLINE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_obj_set_start_end;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_plan_end_obj_set_end >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the objective setting deadline is not greater than the
--   plan end date.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the dates are valid.
--
-- Post Failure:
--  An application error is raised if the dates are not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_plan_end_obj_set_end
  (p_plan_id               in  number
  ,p_object_version_number in  number
  ,p_obj_setting_deadline  in date
  ,p_end_date              in date
  ,p_status                in varchar
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_plan_end_obj_set_end';
    l_api_updating boolean;
    l_sysdate date := trunc(sysdate);

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.obj_setting_deadline, hr_api.g_date)
      = nvl(p_obj_setting_deadline, hr_api.g_date)
    AND nvl(per_pmp_shd.g_old_rec.end_date, hr_api.g_date)
      = nvl(p_end_date, hr_api.g_date))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    IF (p_obj_setting_deadline IS NOT NULL AND
        p_end_date IS NOT NULL)
    THEN
        --
        -- Checks that the obj_setting_deadline date is not greater than
        -- the plan end date.
        --
        IF (p_obj_setting_deadline > p_end_date) THEN
           fnd_message.set_name('PER','HR_50254_WPM_PLAN_OBJ_SET_END');
           fnd_message.raise_error;
        END IF;
    END IF;

    --
    -- check that the plan is not being created in the past
    --
    IF (p_status = 'INSERT') THEN
     IF (p_end_date < l_sysdate) THEN
          fnd_message.set_name('PER','HR_50422_WPM_EXPIRED_PLAN');
          fnd_message.raise_error;
     END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.OBJ_SETTING_DEADLINE'
    ,p_associated_column2 =>  'PER_PERF_MGMT_PLANS.END_DATE'
    ,p_associated_column3 =>  'PER_PERF_MGMT_PLANS.END_DATE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_plan_end_obj_set_end;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_plan_start_obj_start_end >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the objective setting start date is not before the
--   plan start date.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the dates are valid.
--
-- Post Failure:
--  An application error is raised if the dates are not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_plan_start_obj_set_start
  (p_plan_id               in  number
  ,p_object_version_number in  number
  ,p_obj_setting_start_date  in date
  ,p_start_date              in date
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_plan_start_obj_set_start';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.obj_setting_start_date, hr_api.g_date)
      = nvl(p_obj_setting_start_date, hr_api.g_date)
    AND nvl(per_pmp_shd.g_old_rec.start_date, hr_api.g_date)
      = nvl(p_start_date, hr_api.g_date))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    IF (p_obj_setting_start_date IS NOT NULL AND
        p_start_date IS NOT NULL)
    THEN
        --
        -- Checks that the objective setting start date is not greater than
        -- the plan start date.
        --
        IF (p_obj_setting_start_date < p_start_date) THEN
           fnd_message.set_name('PER','HR_50421_WPM_PLAN_OBJ_SET_STRT');
           fnd_message.raise_error;
        END IF;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.OBJ_SETTING_START_DATE'
    ,p_associated_column2 =>  'PER_PERF_MGMT_PLANS.START_DATE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

END chk_plan_start_obj_set_start;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_obj_set_outside_flag >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the objective setting outside the period flag is a valid lookup
--    code in lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the objective setting outside the period flag
--   is valid.
--
-- Post Failure:
--  An application error is raised if the objective setting outside the period
--  flag is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_obj_set_outside_flag
  (p_plan_id                     in  number
  ,p_object_version_number       in  number
  ,p_effective_date              in  date
  ,p_obj_set_outside_period_flag in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_obj_set_outside_flag';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_obj_set_outside_period_flag'
            ,p_argument_value => p_obj_set_outside_period_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.obj_set_outside_period_flag, hr_api.g_varchar2)
      = nvl(p_obj_set_outside_period_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_obj_set_outside_period_flag
         ) THEN
       fnd_message.set_name('PER','HR_50255_WPM_PLAN_SET_OUT_PRD');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.OBJ_SET_OUTSIDE_PERIOD_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_obj_set_outside_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_method_code >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the method code is a valid lookup code in the lookup type
--   HR_WPM_PLAN_METHOD.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the method code is valid.
--
-- Post Failure:
--  An application error is raised if the method code is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_method_code
  (p_plan_id               in  number
  ,p_object_version_number in  number
  ,p_effective_date        in  date
  ,p_method_code           in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_method_code';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_method_code'
            ,p_argument_value => p_method_code
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.method_code, hr_api.g_varchar2)
      = nvl(p_method_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'HR_WPM_PLAN_METHOD'
         ,p_lookup_code           => p_method_code
         ) THEN
       fnd_message.set_name('PER','HR_50256_WPM_PLAN_MTHD_CODE');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.METHOD_CODE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_method_code;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_notify_population_flag >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the notify population flag is a valid lookup code in the
--   lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the notify population flag is valid.
--
-- Post Failure:
--  An application error is raised if the notify population flag is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_notify_population_flag
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_effective_date            in  date
  ,p_notify_population_flag    in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_notify_population_flag';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_notify_population_flag'
            ,p_argument_value => p_notify_population_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id               => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.notify_population_flag, hr_api.g_varchar2)
      = nvl(p_notify_population_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_notify_population_flag
         ) THEN
       fnd_message.set_name('PER','HR_50415_WPM_PMP_NOTIFY_FLAG');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.NOTIFY_POPULATION_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_notify_population_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_automatic_allocation_flag >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the automatic allocation flag is a valid lookup code in the
--   lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the automatic allocation flag is valid.
--
-- Post Failure:
--  An application error is raised if the automatic allocation flag is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_automatic_allocation_flag
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_effective_date            in  date
  ,p_automatic_allocation_flag in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_automatic_allocation_flag';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_automatic_allocation_flag'
            ,p_argument_value => p_automatic_allocation_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.automatic_allocation_flag, hr_api.g_varchar2)
      = nvl(p_automatic_allocation_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_automatic_allocation_flag
         ) THEN
       fnd_message.set_name('PER','HR_50257_WPM_PLAN_ALLOC_FLG');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.AUTOMATIC_ALLOCATION_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_automatic_allocation_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_copy_past_objectives_flag >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the copy past objectives flag is a valid lookup code in the
--   lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the copy past objectives flag is valid.
--
-- Post Failure:
--  An application error is raised if the copy past objectives flag is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_copy_past_objectives_flag
  (p_plan_id                   in  number
  ,p_object_version_number     in  number
  ,p_effective_date            in  date
  ,p_copy_past_objectives_flag in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_copy_past_objectives_flag';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_copy_past_objectives_flag'
            ,p_argument_value => p_copy_past_objectives_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.copy_past_objectives_flag, hr_api.g_varchar2)
      = nvl(p_copy_past_objectives_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_copy_past_objectives_flag
         ) THEN
       fnd_message.set_name('PER','HR_123456_X');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.COPY_PAST_OBJECTIVES_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_copy_past_objectives_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_sharing_alignment_flag >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the sharing alignment flag is a valid lookup code in the
--   lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the sharing alignment flag is valid.
--
-- Post Failure:
--  An application error is raised if the sharing alignment flag is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_sharing_alignment_flag
  (p_plan_id                     in  number
  ,p_object_version_number       in  number
  ,p_effective_date              in  date
  ,p_sharing_alignment_task_flag in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_sharing_alignment_flag';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_sharing_alignment_task_flag'
            ,p_argument_value => p_sharing_alignment_task_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.sharing_alignment_task_flag, hr_api.g_varchar2)
      = nvl(p_sharing_alignment_task_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_sharing_alignment_task_flag
         ) THEN
       fnd_message.set_name('PER','HR_50258_WPM_PLAN_SHR_ALN_FLG');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.SHARING_ALIGNMENT_TASK_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_sharing_alignment_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_include_appraisals_flag >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the include appraisals flag is a valid lookup code in the
--   lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the include appraisals flag is valid.
--
-- Post Failure:
--  An application error is raised if the include appraisals flag is not valid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_include_appraisals_flag
  (p_plan_id                 in  number
  ,p_object_version_number   in  number
  ,p_effective_date          in  date
  ,p_include_appraisals_flag in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_include_appraisals_flag';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;
    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_include_appraisals_flag'
            ,p_argument_value => p_include_appraisals_flag
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pmp_shd.api_updating
           (p_plan_id          => p_plan_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pmp_shd.g_old_rec.include_appraisals_flag, hr_api.g_varchar2)
      = nvl(p_include_appraisals_flag, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'YES_NO'
         ,p_lookup_code           => p_include_appraisals_flag
         ) THEN
       fnd_message.set_name('PER','HR_50259_WPM_PLAN_INC_APRSL');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.INCLUDE_APPRAISALS_FLAG'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_include_appraisals_flag;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_plan_still_active >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the plan, if published, is active on effective date.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues when the plan, if published, is active on
--  effective date.
--
-- Post Failure:
--  An application error is raised if the published plan is not active on
--  effective date.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_plan_still_active
  (p_effective_date          in  date
  ,p_status_code             in  varchar2
  ,p_start_date              in date
  ,p_end_date                in date
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_plan_still_active';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    IF (p_status_code = 'PUBLISHED' AND
        p_effective_date > p_end_date)
    THEN
       fnd_message.set_name('PER','HR_50261_WPM_PLAN_UPD_ACTIVE');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.START_DATE'
    ,p_associated_column2 =>  'PER_PERF_MGMT_PLANS.END_DATE'
    ,p_associated_column3 =>  'PER_PERF_MGMT_PLANS.STATUS_CODE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_plan_still_active;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_plan_is_draft >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the plan status is 'DRAFT'.
--
-- Prerequisites:
--   None.
--
-- In Arguments:
--
--
-- Post Success:
--  Processing continues if the plan is 'DRAFT'.
--
-- Post Failure:
--  An application error is raised if the plan status is not 'DRAFT'.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_plan_is_draft
  (p_status_code             in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_plan_is_draft';
    l_api_updating boolean;

Begin

    IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    -- Checks that the status code is 'DRAFT'
    --
    IF (p_status_code <> 'DRAFT') THEN
       fnd_message.set_name('PER','HR_50262_WPM_PLAN_DEL_DRAFT');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_PERF_MGMT_PLANS.STATUS_CODE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);

End chk_plan_is_draft;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pmp_shd.g_rec_type
  ,p_duplicate_name_warning       out nocopy boolean
  ,p_no_life_events_warning       out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- No business group context. HR_STANDARD_LOOKUPS used for validation.

  --
  -- Validate Independent Attributes
  --
  --
  -- Check the uniqueness of the plan name.
  --
  chk_plan_name
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_plan_name              => p_rec.plan_name
  ,p_start_date             => p_rec.start_date
  ,p_end_date               => p_rec.end_date
  ,p_duplicate_name_warning => p_duplicate_name_warning
  );

  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Check the validity of administrator id
  --
  chk_administrator_person_id
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_administrator_person_id => p_rec.administrator_person_id
  );

  --
  -- Check the validity of dates
  --
  chk_start_from_to_date
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_start_date             => p_rec.start_date
  ,p_end_date               => p_rec.end_date
  ,p_status_code            => p_rec.status_code
  );

  hr_utility.set_location('Entering:'||l_proc, 15);

  --
  -- Check the validity of status code
  --
  chk_status_code
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  ,p_status_code            => p_rec.status_code
  );

  hr_utility.set_location('Entering:'||l_proc, 20);

  --
  -- Check the validity of plan hierarchy type
  --
  chk_hierarchy_type_code
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  ,p_hierarchy_type_code    => p_rec.hierarchy_type_code
  );

  hr_utility.set_location('Entering:'||l_proc, 25);

  --
  -- Check the validity of supervisor id
  --
  chk_supervisor_id
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  ,p_hierarchy_type_code    => p_rec.hierarchy_type_code
  ,p_supervisor_id          => p_rec.supervisor_id
  );

  hr_utility.set_location('Entering:'||l_proc, 30);

  --
  -- Check the validity of supervisor assignment id
  --
  chk_supervisor_assignment_id
  (p_plan_id                  => p_rec.plan_id
  ,p_object_version_number    => p_rec.object_version_number
  ,p_effective_date           => p_effective_date
  ,p_hierarchy_type_code      => p_rec.hierarchy_type_code
  ,p_supervisor_assignment_id => p_rec.supervisor_assignment_id
  );

  hr_utility.set_location('Entering:'||l_proc, 35);

  --
  -- Check the validity of organization structure id
  --
  chk_organization_structure_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_organization_structure_id => p_rec.organization_structure_id
  );

  hr_utility.set_location('Entering:'||l_proc, 40);

  --
  -- Check the validity of organization structure version id
  --
  chk_org_structure_version_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_org_structure_version_id  => p_rec.org_structure_version_id
  );

  hr_utility.set_location('Entering:'||l_proc, 45);

  --
  -- Check the validity of version for organization structure
  --
  chk_org_structure_version
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_organization_structure_id => p_rec.organization_structure_id
  ,p_org_structure_version_id  => p_rec.org_structure_version_id
  );

  hr_utility.set_location('Entering:'||l_proc, 50);

  --
  -- Check the validity of top organization id
  --
  chk_top_organization_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_org_structure_version_id  => p_rec.org_structure_version_id
  ,p_top_organization_id       => p_rec.top_organization_id
  );

  hr_utility.set_location('Entering:'||l_proc, 55);

  --
  -- Check the validity of position structure id
  --
  chk_position_structure_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_position_structure_id     => p_rec.position_structure_id
  );

  hr_utility.set_location('Entering:'||l_proc, 60);

  --
  -- Check the validity of position structure version id
  --
  chk_pos_structure_version_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_pos_structure_version_id  => p_rec.pos_structure_version_id
  );

  hr_utility.set_location('Entering:'||l_proc, 65);

  --
  -- Check the validity of version for position structure
  --
  chk_pos_structure_version
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_position_structure_id     => p_rec.position_structure_id
  ,p_pos_structure_version_id  => p_rec.pos_structure_version_id
  );

  hr_utility.set_location('Entering:'||l_proc, 70);

  --
  -- Check the validity of top position id
  --
  chk_top_position_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_pos_structure_version_id  => p_rec.pos_structure_version_id
  ,p_top_position_id           => p_rec.top_position_id
  );

  hr_utility.set_location('Entering:'||l_proc, 75);

  --
  -- Check the validity of hierarchy level
  --
  chk_hierarchy_levels
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_hierarchy_levels       => p_rec.hierarchy_levels
  );

  hr_utility.set_location('Entering:'||l_proc, 80);

  --
  -- Check the validity of automatic enrollment flag
  --
  chk_automatic_enrollment_flag
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_effective_date            => p_effective_date
  ,p_automatic_enrollment_flag => p_rec.automatic_enrollment_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 85);

  --
  -- Check the validity of assignment types code
  --
  chk_assignment_types_code
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_assignment_types_code   => p_rec.assignment_types_code
  );


  hr_utility.set_location('Entering:'||l_proc, 90);

  --
  -- Check the validity of primary assignment only flag
  --
  chk_primary_asg_only_flag
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_primary_asg_only_flag   => p_rec.primary_asg_only_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 95);

  --
  -- Check the validity of primary assignment only flag with plan hierarchy
  --
  chk_hier_type_primary_asg
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_hierarchy_type_code     => p_rec.hierarchy_type_code
  ,p_primary_asg_only_flag   => p_rec.primary_asg_only_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 100);

  --
  -- Check the validity of include objective setting flag
  --
  chk_include_obj_set_flag
  (p_plan_id                  => p_rec.plan_id
  ,p_object_version_number    => p_rec.object_version_number
  ,p_effective_date           => p_effective_date
  ,p_include_obj_setting_flag => p_rec.include_obj_setting_flag
  ,p_obj_setting_start_date   => p_rec.obj_setting_start_date
  ,p_method_code              => p_rec.method_code
  ,p_notify_population_flag   => p_rec.notify_population_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 95);

  --
  -- Check the validity of objective setting dates
  --
  chk_obj_set_start_end
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_obj_setting_start_date  => p_rec.obj_setting_start_date
  ,p_obj_setting_deadline    => p_rec.obj_setting_deadline
  );

  hr_utility.set_location('Entering:'||l_proc, 105);

  --
  -- Check the validity of objective setting deadline with plan end date
  --
  chk_plan_end_obj_set_end
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_obj_setting_deadline   => p_rec.obj_setting_deadline
  ,p_end_date               => p_rec.end_date
  ,p_status                 => 'INSERT'
  );

  hr_utility.set_location('Entering:'||l_proc, 110);

  --
  -- Check the validity of objective setting outside period flag
  --
  chk_obj_set_outside_flag
  (p_plan_id                     => p_rec.plan_id
  ,p_object_version_number       => p_rec.object_version_number
  ,p_effective_date              => p_effective_date
  ,p_obj_set_outside_period_flag => p_rec.obj_set_outside_period_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 115);

  --
  -- Check the validity of method code
  --
  chk_method_code
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date        => p_effective_date
  ,p_method_code           => p_rec.method_code
  );

  hr_utility.set_location('Entering:'||l_proc, 120);

  --
  -- Check the validity of notify population flag
  --
  chk_notify_population_flag
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_effective_date            => p_effective_date
  ,p_notify_population_flag    => p_rec.notify_population_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 123);

  --
  -- Check the validity of automatic allocation flag
  --
  chk_automatic_allocation_flag
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_effective_date            => p_effective_date
  ,p_automatic_allocation_flag => p_rec.automatic_allocation_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 125);

  --
  -- Check the validity of sharing assignment task flag
  --
  chk_sharing_alignment_flag
  (p_plan_id                     => p_rec.plan_id
  ,p_object_version_number       => p_rec.object_version_number
  ,p_effective_date              => p_effective_date
  ,p_sharing_alignment_task_flag => p_rec.sharing_alignment_task_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 130);

  --
  -- Check the validity of include appraisals flag
  --
  chk_include_appraisals_flag
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_include_appraisals_flag => p_rec.include_appraisals_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 135);

  --
  -- Check that the previous plan does not overlap with the new plan
  --
  chk_previous_plan_id
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_start_date              => p_rec.start_date
  ,p_previous_plan_id        => p_rec.previous_plan_id
  );

  hr_utility.set_location('Entering:'||l_proc, 140);
  --
  -- Check the validity of objective setting start date  with plan start date
  --
  chk_plan_start_obj_set_start
  (p_plan_id                  => p_rec.plan_id
  ,p_object_version_number    => p_rec.object_version_number
  ,p_obj_setting_start_date   => p_rec.obj_setting_start_date
  ,p_start_date               => p_rec.start_date
  );

  hr_utility.set_location('Entering:'||l_proc, 145);

  --
  -- Check the flexfield.
  --
  per_pmp_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 200);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pmp_shd.g_rec_type
  ,p_duplicate_name_warning       out nocopy boolean
  ,p_no_life_events_warning       out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- No business group context. HR_STANDARD_LOOKUPS used for validation.
  --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
      ,p_rec              => p_rec
    );
  --

  --
  -- Validate Independent Attributes
  --
  --
  -- Check the uniqueness of the plan name.
  --
  chk_plan_name
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_plan_name              => p_rec.plan_name
  ,p_start_date             => p_rec.start_date
  ,p_end_date               => p_rec.end_date
  ,p_duplicate_name_warning => p_duplicate_name_warning
  );

  hr_utility.set_location('Entering:'||l_proc, 10);

  --
  -- Check the validity of administrator id
  --
  chk_administrator_person_id
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_administrator_person_id => p_rec.administrator_person_id
  );

  --
  -- Check the validity of dates
  --
  chk_start_from_to_date
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_start_date             => p_rec.start_date
  ,p_end_date               => p_rec.end_date
  ,p_status_code            => p_rec.status_code
  );

  hr_utility.set_location('Entering:'||l_proc, 15);

  --
  -- Check the validity of status code
  --
  chk_status_code
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  ,p_status_code            => p_rec.status_code
  );

  hr_utility.set_location('Entering:'||l_proc, 20);

  --
  -- Check the validity of plan hierarchy type
  --
  chk_hierarchy_type_code
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date         => p_effective_date
  ,p_hierarchy_type_code    => p_rec.hierarchy_type_code
  );

  hr_utility.set_location('Entering:'||l_proc, 25);

  --
  -- Check the validity of supervisor id
  --
  chk_supervisor_id
  (p_plan_id                  => p_rec.plan_id
  ,p_object_version_number    => p_rec.object_version_number
  ,p_effective_date           => p_effective_date
  ,p_hierarchy_type_code      => p_rec.hierarchy_type_code
  ,p_supervisor_id            => p_rec.supervisor_id
  );

  hr_utility.set_location('Entering:'||l_proc, 30);

  --
  -- Check the validity of supervisor assignment id
  --
  chk_supervisor_assignment_id
  (p_plan_id                  => p_rec.plan_id
  ,p_object_version_number    => p_rec.object_version_number
  ,p_effective_date           => p_effective_date
  ,p_hierarchy_type_code      => p_rec.hierarchy_type_code
  ,p_supervisor_assignment_id => p_rec.supervisor_assignment_id
  );

  hr_utility.set_location('Entering:'||l_proc, 35);

  --
  -- Check the validity of organization structure id
  --
  chk_organization_structure_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_organization_structure_id => p_rec.organization_structure_id
  );

  hr_utility.set_location('Entering:'||l_proc, 40);

  --
  -- Check the validity of organization structure version id
  --
  chk_org_structure_version_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_org_structure_version_id  => p_rec.org_structure_version_id
  );

  hr_utility.set_location('Entering:'||l_proc, 45);

  --
  -- Check the validity of version for organization structure
  --
  chk_org_structure_version
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_organization_structure_id => p_rec.organization_structure_id
  ,p_org_structure_version_id  => p_rec.org_structure_version_id
  );

  hr_utility.set_location('Entering:'||l_proc, 50);

  --
  -- Check the validity of top organization id
  --
  chk_top_organization_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_top_organization_id       => p_rec.top_organization_id
  ,p_org_structure_version_id  => p_rec.org_structure_version_id
  );

  hr_utility.set_location('Entering:'||l_proc, 55);

  --
  -- Check the validity of position structure id
  --
  chk_position_structure_id
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_position_structure_id  => p_rec.position_structure_id
  );

  hr_utility.set_location('Entering:'||l_proc, 60);

  --
  -- Check the validity of position structure version id
  --
  chk_pos_structure_version_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_pos_structure_version_id  => p_rec.pos_structure_version_id
  );

  hr_utility.set_location('Entering:'||l_proc, 65);

  --
  -- Check the validity of version for position structure
  --
  chk_pos_structure_version
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_position_structure_id     => p_rec.position_structure_id
  ,p_pos_structure_version_id  => p_rec.pos_structure_version_id
  );

  hr_utility.set_location('Entering:'||l_proc, 70);

  --
  -- Check the validity of top position id
  --
  chk_top_position_id
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_hierarchy_type_code       => p_rec.hierarchy_type_code
  ,p_pos_structure_version_id  => p_rec.pos_structure_version_id
  ,p_top_position_id           => p_rec.top_position_id
  );

  hr_utility.set_location('Entering:'||l_proc, 75);

  --
  -- Check the validity of hierarchy level
  --
  chk_hierarchy_levels
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_hierarchy_levels       => p_rec.hierarchy_levels
  );

  hr_utility.set_location('Entering:'||l_proc, 80);

  --
  -- Check the validity of automatic enrollment flag
  --
  chk_automatic_enrollment_flag
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_effective_date            => p_effective_date
  ,p_automatic_enrollment_flag => p_rec.automatic_enrollment_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 85);

  --
  -- Check the validity of assignment types code
  --
  chk_assignment_types_code
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_assignment_types_code   => p_rec.assignment_types_code
  );


  hr_utility.set_location('Entering:'||l_proc, 90);

  --
  -- Check the validity of primary assignment only flag
  --
  chk_primary_asg_only_flag
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_primary_asg_only_flag   => p_rec.primary_asg_only_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 95);

  --
  -- Check the validity of primary assignment only flag with plan hierarchy
  --
  chk_hier_type_primary_asg
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_hierarchy_type_code     => p_rec.hierarchy_type_code
  ,p_primary_asg_only_flag   => p_rec.primary_asg_only_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 100);

  --
  -- Check the validity of include objective setting flag
  --
  chk_include_obj_set_flag
  (p_plan_id                  => p_rec.plan_id
  ,p_object_version_number    => p_rec.object_version_number
  ,p_effective_date           => p_effective_date
  ,p_include_obj_setting_flag => p_rec.include_obj_setting_flag
  ,p_obj_setting_start_date   => p_rec.obj_setting_start_date
  ,p_method_code              => p_rec.method_code
  ,p_notify_population_flag   => p_rec.notify_population_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 105);

  --
  -- Check the validity of objective setting dates
  --
  chk_obj_set_start_end
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_obj_setting_start_date  => p_rec.obj_setting_start_date
  ,p_obj_setting_deadline    => p_rec.obj_setting_deadline
  );

  hr_utility.set_location('Entering:'||l_proc, 110);

  --
  -- Check the validity of objective setting deadline with plan end date
  --
  chk_plan_end_obj_set_end
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_obj_setting_deadline   => p_rec.obj_setting_deadline
  ,p_end_date               => p_rec.end_date
  ,p_status                 => 'UPDATE'
  );

  hr_utility.set_location('Entering:'||l_proc, 115);

  --
  -- Check the validity of objective setting outside period flag
  --
  chk_obj_set_outside_flag
  (p_plan_id                     => p_rec.plan_id
  ,p_object_version_number       => p_rec.object_version_number
  ,p_effective_date              => p_effective_date
  ,p_obj_set_outside_period_flag => p_rec.obj_set_outside_period_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 120);

  --
  -- Check the validity of method code
  --
  chk_method_code
  (p_plan_id                => p_rec.plan_id
  ,p_object_version_number  => p_rec.object_version_number
  ,p_effective_date        => p_effective_date
  ,p_method_code           => p_rec.method_code
  );

  hr_utility.set_location('Entering:'||l_proc, 125);

  --
  -- Check the validity of notify population flag
  --
  chk_notify_population_flag
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_effective_date            => p_effective_date
  ,p_notify_population_flag    => p_rec.notify_population_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 127);

  --
  -- Check the validity of automatic allocation flag
  --
  chk_automatic_allocation_flag
  (p_plan_id                   => p_rec.plan_id
  ,p_object_version_number     => p_rec.object_version_number
  ,p_effective_date            => p_effective_date
  ,p_automatic_allocation_flag => p_rec.automatic_allocation_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 130);

  --
  -- Check the validity of sharing assignment task flag
  --
  chk_sharing_alignment_flag
  (p_plan_id                     => p_rec.plan_id
  ,p_object_version_number       => p_rec.object_version_number
  ,p_effective_date              => p_effective_date
  ,p_sharing_alignment_task_flag => p_rec.sharing_alignment_task_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 135);

  --
  -- Check the validity of include appraisals flag
  --
  chk_include_appraisals_flag
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_include_appraisals_flag => p_rec.include_appraisals_flag
  );

  hr_utility.set_location('Entering:'||l_proc, 140);
  --
  -- Check the published plan validity on effective date
  --
  chk_plan_still_active
  (p_effective_date          => p_effective_date
  ,p_status_code            => p_rec.status_code
  ,p_start_date             => p_rec.start_date
  ,p_end_date               => p_rec.end_date
  );

  hr_utility.set_location('Entering:'||l_proc, 145);

  --
  -- Check that the previous plan does not overlap with the new plan
  --
  chk_previous_plan_id
  (p_plan_id                 => p_rec.plan_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_effective_date          => p_effective_date
  ,p_start_date              => p_rec.start_date
  ,p_previous_plan_id        => p_rec.previous_plan_id
  );

  hr_utility.set_location('Entering:'||l_proc, 150);

  --
  -- Check the validity of objective setting start date  with plan start date
  --
  chk_plan_start_obj_set_start
  (p_plan_id                  => p_rec.plan_id
  ,p_object_version_number    => p_rec.object_version_number
  ,p_obj_setting_start_date   => p_rec.obj_setting_start_date
  ,p_start_date               => p_rec.start_date
  );

  hr_utility.set_location('Entering:'||l_proc, 155);

  --
  -- Check the flexfield.
  --
  per_pmp_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 200);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Check the plan status is 'DRAFT'
  --
  chk_plan_is_draft
  (p_status_code            => p_rec.status_code
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_pmp_bus;

/
