--------------------------------------------------------
--  DDL for Package Body PER_PMA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PMA_BUS" as
/* $Header: pepmarhi.pkb 120.4.12010000.3 2009/10/23 13:48:57 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pma_bus.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_appraisal_period_id         number         default null;
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
  (p_rec in per_pma_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.appraisal_period_id is not null)  and (
    nvl(per_pma_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(per_pma_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.appraisal_period_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_APPRAISAL_PERIODS'
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
-- |---------------------------< chk_start_date >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_start_date
 (p_task_start_date  in date
 )is
 --
 l_proc  varchar2(72) := g_package||'chk_start_date';
 --

Begin
 hr_utility.set_location('Entering:'||l_proc, 5);
 hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_task_start_date'
          ,p_argument_value => p_task_start_date
          );
IF trunc(p_task_start_date)  < trunc(sysdate) THEN
     fnd_message.set_name('PER', 'HR_APPR_TASK_DT_BEFORE_SYSDATE');
     fnd_message.raise_error;
   END IF;
hr_utility.set_location(' Leaving:'||l_proc, 980);
End chk_start_date;
--

--
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
  ,p_rec in per_pma_shd.g_rec_type
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
  IF NOT per_pma_shd.api_updating
      (p_appraisal_period_id               => p_rec.appraisal_period_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  if nvl(p_rec.plan_id,hr_api.g_number) <>
     per_pma_shd.g_old_rec.plan_id then
     l_argument := 'plan_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  if nvl(p_rec.appraisal_template_id,hr_api.g_number) <>
     per_pma_shd.g_old_rec.appraisal_template_id then
     l_argument := 'appraisal_template_id';
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
         ,p_base_table => per_pma_shd.g_tab_nam);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
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
  (p_plan_id          IN number
  ) IS

  --
  l_proc          varchar2(72) := g_package || 'chk_plan_id';
  l_plan_id       number;
  --

  CURSOR csr_chk_plan_id IS
  SELECT pmp.plan_id
  FROM   per_perf_mgmt_plans pmp
  WHERE  pmp.plan_id = p_plan_id;
--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_plan_id'
          ,p_argument_value => p_plan_id
          );

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

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_APPRAISAL_PERIODS.PLAN_ID')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_plan_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_appraisal_template_id >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate that the specified appraisal
--   template exists.
--
-- Pre Conditions:
--   The appraisal template must already exist.
--
-- In Arguments:
--
--
-- Post Success:
--   Processing continues if the appraisal template is valid.
--
-- Post Failure:
--   An application error is raised if the appraisal template does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_appraisal_template_id
  (p_appraisal_template_id   IN number
  ) IS

  --
  l_proc          varchar2(72) := g_package || 'chk_appraisal_template_id';
  l_template_id   number;
  --

  CURSOR csr_chk_template IS
  SELECT apt.appraisal_template_id
  FROM   per_appraisal_templates apt
  WHERE  apt.appraisal_template_id = p_appraisal_template_id;
--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_appraisal_template_id'
          ,p_argument_value => p_appraisal_template_id
          );

  --
  -- Check that template exists.
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;
  OPEN  csr_chk_template;
  FETCH csr_chk_template INTO l_template_id;
  CLOSE csr_chk_template;

  IF l_template_id IS null THEN
    fnd_message.set_name('PER', 'HR_50299_PMA_TEMPLATE_INVALID');
    fnd_message.raise_error;
  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_APPRAISAL_PERIODS.APPRAISAL_TEMPLATE_ID')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_appraisal_template_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_dates >--------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the start and end date of the appraisal period.
--   It first checks that the start date is earlier than the end date,
--   then it checks that the appraisal period dates are within the dates
--   of the performance management plan and finally it checks that the
--   dates fall within the dates of the appraisal template.
--
-- Pre Conditions:
--   The plan and appraisal template must exist and have been validated.
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
  (p_appraisal_period_id   IN number
  ,p_object_version_number IN number
  ,p_plan_id               IN number
  ,p_appraisal_template_id IN number
  ,p_start_date            IN date
  ,p_end_date              IN date
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_dates';
  l_api_updating   boolean;
  l_pmp_start_date date;
  l_pmp_end_date   date;
  l_apt_date_from  date;
  l_apt_date_to    date;
  l_pap_start_date date;
  l_pap_end_date   date;
  l_row_found      varchar2(1)  := 'N';
  --

  CURSOR csr_dates_within_plan IS
  SELECT pmp.start_date, pmp.end_date
  FROM   per_perf_mgmt_plans pmp
  WHERE  pmp.plan_id = p_plan_id;

  CURSOR csr_dates_within_template IS
  SELECT apt.date_from, apt.date_to
  FROM   per_appraisal_templates apt
  WHERE  apt.appraisal_template_id = p_appraisal_template_id;
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
  l_api_updating := per_pma_shd.api_updating
         (p_appraisal_period_id    => p_appraisal_period_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_pma_shd.g_old_rec.start_date, hr_api.g_date)
    = nvl(p_start_date, hr_api.g_date)
  AND nvl(per_pma_shd.g_old_rec.end_date, hr_api.g_date)
    = nvl(p_end_date, hr_api.g_date))
  THEN
     RETURN;
  END IF;

  IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

  --
  -- Check that the appraisal period's start date is not later
  -- than the end date.
  --
  IF p_start_date > p_end_date THEN
    fnd_message.set_name('PER', 'HR_50233_WPM_PLAN_DATES');
    fnd_message.raise_error;
  END IF;

  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  --
  -- Check that the appraisal period is within the plan dates.
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
  OPEN  csr_dates_within_plan;
  FETCH csr_dates_within_plan INTO l_pmp_start_date
                                  ,l_pmp_end_date;
  CLOSE csr_dates_within_plan;

  IF p_start_date < l_pmp_start_date
   OR p_end_date > l_pmp_end_date
  THEN
    fnd_message.set_name('PER', 'HR_50391_PMA_PLAN_DATES');
    fnd_message.raise_error;
  END IF;

  --
  -- Check that the appraisal period is within the template dates.
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;
  OPEN  csr_dates_within_template;
  FETCH csr_dates_within_template INTO l_apt_date_from
                                      ,l_apt_date_to;
  CLOSE csr_dates_within_template;

  IF p_start_date < nvl(l_apt_date_from, hr_api.g_sot)
   OR p_end_date > nvl(l_apt_date_to, hr_api.g_eot)
  THEN
    fnd_message.set_name('PER', 'HR_50393_PMA_TEMPLATE_DATES');
    fnd_message.raise_error;
  END IF;


  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_APPRAISAL_PERIODS.START_DATE'
      ,p_associated_column2 => 'PER_APPRAISAL_PERIODS.END_DATE')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_dates;
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
  (p_appraisal_period_id   IN number
  ,p_object_version_number IN number
  ,p_plan_id               IN number
  ,p_appraisal_template_id IN number
  ,p_start_date            IN date
  ,p_end_date              IN date
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_duplicate';
  l_api_updating   boolean;
  l_dup            varchar2(5) := 'FALSE';
  --

  CURSOR csr_chk_duplicate IS
  SELECT 'TRUE'
  FROM   per_appraisal_periods pma
  WHERE  pma.plan_id = p_plan_id
  AND    pma.appraisal_template_id = p_appraisal_template_id
  AND    pma.start_date = p_start_date
  AND    pma.end_date = p_end_date
  AND    pma.appraisal_period_id <> nvl(p_appraisal_period_id, hr_api.g_number);
--
BEGIN

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date values have changed
  --
  l_api_updating := per_pma_shd.api_updating
         (p_appraisal_period_id    => p_appraisal_period_id
         ,p_object_version_number  => p_object_version_number);
  --
  IF (l_api_updating
  AND nvl(per_pma_shd.g_old_rec.plan_id, hr_api.g_number)
    = nvl(p_plan_id, hr_api.g_number)
  AND nvl(per_pma_shd.g_old_rec.appraisal_template_id, hr_api.g_number)
    = nvl(p_appraisal_template_id, hr_api.g_number)
  AND nvl(per_pma_shd.g_old_rec.start_date, hr_api.g_date)
    = nvl(p_start_date, hr_api.g_date)
  AND nvl(per_pma_shd.g_old_rec.end_date, hr_api.g_date)
    = nvl(p_end_date, hr_api.g_date))
  THEN
     RETURN;
  END IF;

  --
  -- Check that the plan is not a duplicate.
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;
  OPEN  csr_chk_duplicate;
  FETCH csr_chk_duplicate INTO l_dup;
  CLOSE csr_chk_duplicate;

  IF l_dup = 'TRUE' THEN
    fnd_message.set_name('PER', 'HR_50394_PMA_DUP_ERROR');
    fnd_message.raise_error;
  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_PERSONAL_SCORECARDS.PLAN_ID'
      ,p_associated_column2 => 'PER_PERSONAL_SCORECARDS.APPRAISAL_TEMPLATE_ID'
      ,p_associated_column3 => 'PER_PERSONAL_SCORECARDS.START_DATE'
      ,p_associated_column4 => 'PER_PERSONAL_SCORECARDS.START_END')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_duplicate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_initiator_code >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks that the status code is a valid lookup code in the lookup type
--   HR_WPM_INITIATOR.
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
procedure chk_initiator_code
  (p_appraisal_period_id     in  number
  ,p_object_version_number   in  number
  ,p_effective_date          in  date
  ,p_initiator_code             in  varchar2
  ) is

 -- Declare local variables

    l_proc         varchar2(72) :=  g_package||'chk_status_code';
    l_api_updating boolean;

Begin

IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

    --
    hr_api.mandatory_arg_error
            (p_api_name       => l_proc
            ,p_argument       => 'p_initiator_code'
            ,p_argument_value => p_initiator_code
            );
    --
    -- Only proceed with validation if :
    -- a) The current g_old_rec is current and
    -- b) The date values have changed
    --
    l_api_updating := per_pma_shd.api_updating
           (p_appraisal_period_id   => p_appraisal_period_id
           ,p_object_version_number => p_object_version_number);
    --
    IF (l_api_updating
    AND nvl(per_pma_shd.g_old_rec.initiator_code, hr_api.g_varchar2)
      = nvl(p_initiator_code, hr_api.g_varchar2))
    THEN
        RETURN;
    END IF;

    IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

    --
    -- Checks that the status code is valid
    --
    IF hr_api.not_exists_in_hrstanlookups
         (p_effective_date        => p_effective_date
         ,p_lookup_type           => 'HR_WPM_INITIATOR'
         ,p_lookup_code           => p_initiator_code
         ) THEN
       fnd_message.set_name('PER','HR_50234_WPM_PLAN_STATUS');
       fnd_message.raise_error;
    END IF;

    IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
    (p_associated_column1 =>  'PER_APPRAISAL_PERIODS.INITIATOR_CODE'
    ) THEN
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      raise;
    END IF;
   hr_utility.set_location(' Leaving:'||l_proc, 990);


End chk_initiator_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_task_dates >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the task start and task end date of the appraisal
--   period.
--   It checks that the task start date is earlier than the task end date.
--
-- Pre Conditions:
--   The plan and appraisal template must exist and have been validated.
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
Procedure chk_task_dates
  (p_task_start_date            IN date
  ,p_task_end_date              IN date
  ) IS

  --
  l_proc           varchar2(72) := g_package || 'chk_task_dates';

BEGIN

   IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

   --
   hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_task_start_date'
          ,p_argument_value => p_task_start_date
          );
   --
   hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'p_task_end_date'
          ,p_argument_value => p_task_end_date
          );

   --
   -- Check that the appraisal period's task start date is not later
   -- than the task end date.
   --
   IF p_task_start_date > p_task_end_date THEN
     fnd_message.set_name('PER', 'HR_50417_WPM_PLAN_DATES');
     fnd_message.raise_error;
   END IF;

   IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 970); END IF;

EXCEPTION

  WHEN app_exception.application_exception THEN
    IF hr_multi_message.exception_add
      (p_associated_column1 => 'PER_APPRAISAL_PERIODS.TASK_START_DATE'
      ,p_associated_column2 => 'PER_APPRAISAL_PERIODS.TASK_END_DATE')
    THEN
      hr_utility.set_location(' Leaving:'|| l_proc, 980);
      RAISE;
    END IF;
    hr_utility.set_location(' Leaving:'|| l_proc, 990);

END chk_task_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pma_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  IF g_debug THEN hr_utility.set_location('Entering:'||l_proc, 5); END IF;
  --
  -- Call all supporting business operations
  --
  -- No business group context. HR_STANDARD_LOOKUPS used for validation.

  --
  -- Validate Dependent Attributes
  --
  chk_plan_id
    (p_plan_id                => p_rec.plan_id);

  IF g_debug THEN hr_utility.set_location(l_proc, 10); END IF;

  chk_appraisal_template_id
    (p_appraisal_template_id  => p_rec.appraisal_template_id);

  --
  -- End important validation
  --
  hr_multi_message.end_validation_set;

  IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

  --
  -- Validate Independent Attributes
  --
  chk_dates
    (p_appraisal_period_id     => p_rec.appraisal_period_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_plan_id                 => p_rec.plan_id
    ,p_appraisal_template_id   => p_rec.appraisal_template_id
    ,p_start_date              => p_rec.start_date
    ,p_end_date                => p_rec.end_date);

  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  chk_duplicate
    (p_appraisal_period_id     => p_rec.appraisal_period_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_plan_id                 => p_rec.plan_id
    ,p_appraisal_template_id   => p_rec.appraisal_template_id
    ,p_start_date              => p_rec.start_date
    ,p_end_date                => p_rec.end_date);

  chk_initiator_code
    (p_appraisal_period_id     => p_rec.appraisal_period_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_effective_date          => p_effective_date
    ,p_initiator_code          => p_rec.initiator_code);

  chk_task_dates
  (p_task_start_date           => p_rec.task_start_date
  ,p_task_end_date             => p_rec.task_end_date);

  chk_start_date
  (p_task_start_date             => p_rec.task_start_date);

  per_pma_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 980);

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pma_shd.g_rec_type
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
    (p_effective_date   => p_effective_date
    ,p_rec              => p_rec
    );

  IF g_debug THEN hr_utility.set_location(l_proc, 10); END IF;

  --
  -- Validate Independent Attributes
  --
  chk_dates
    (p_appraisal_period_id     => p_rec.appraisal_period_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_plan_id                 => p_rec.plan_id
    ,p_appraisal_template_id   => p_rec.appraisal_template_id
    ,p_start_date              => p_rec.start_date
    ,p_end_date                => p_rec.end_date);

  IF g_debug THEN hr_utility.set_location(l_proc, 20); END IF;

  chk_duplicate
    (p_appraisal_period_id     => p_rec.appraisal_period_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_plan_id                 => p_rec.plan_id
    ,p_appraisal_template_id   => p_rec.appraisal_template_id
    ,p_start_date              => p_rec.start_date
    ,p_end_date                => p_rec.end_date);

  chk_initiator_code
    (p_appraisal_period_id     => p_rec.appraisal_period_id
    ,p_object_version_number   => p_rec.object_version_number
    ,p_effective_date          => p_effective_date
    ,p_initiator_code          => p_rec.initiator_code);

  chk_task_dates
  (p_task_start_date           => p_rec.task_start_date
  ,p_task_end_date             => p_rec.task_end_date);

--
if( nvl(per_pma_shd.g_old_rec.task_start_date, hr_api.g_date)
    <> nvl(p_rec.task_start_date, hr_api.g_date)) then
    chk_start_date(p_task_start_date           => p_rec.task_start_date);
    end if;
--

  --
  per_pma_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 980);

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pma_shd.g_rec_type
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
end per_pma_bus;

/
