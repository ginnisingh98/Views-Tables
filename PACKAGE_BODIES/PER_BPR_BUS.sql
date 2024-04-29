--------------------------------------------------------
--  DDL for Package Body PER_BPR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPR_BUS" as
/* $Header: pebprrhi.pkb 115.6 2002/12/02 14:33:23 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code       varchar2(150)  default null;
g_payroll_run_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure set_security_group_id
  (p_payroll_run_id                       in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select inf.org_information14
      from hr_organization_information inf
         , per_bf_payroll_runs bpr
     where bpr.payroll_run_id = p_payroll_run_id
       and inf.organization_id   = bpr.business_group_id
       and inf.org_information_context || '' = 'Business Group Information';
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
  hr_api.mandatory_arg_error(p_api_name           => l_proc,
                             p_argument           => 'PAYROLL_RUN_ID',
                             p_argument_value     => p_payroll_run_id);
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
     fnd_message.set_name('PER','HR_7220_INVALID_PRIMARY_KEY');
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
function return_legislation_code
  (p_payroll_run_id                       in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_bf_payroll_runs bpr
     where bpr.payroll_run_id = p_payroll_run_id
       and pbg.business_group_id = bpr.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name           => l_proc,
                             p_argument           => 'PAYROLL_RUN_ID',
                             p_argument_value     => p_payroll_run_id);
  --
  if ( nvl(g_payroll_run_id, hr_api.g_number) = p_payroll_run_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
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
      fnd_message.set_name('PER','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    g_payroll_run_id                    := p_payroll_run_id;
    g_legislation_code                  := l_legislation_code;
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
  (p_rec in per_bpr_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if ((p_rec.payroll_run_id is not null)  and (
    nvl(per_bpr_shd.g_old_rec.bpr_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute_category, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute1, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute2, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute3, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute4, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute5, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute6, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute7, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute8, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute9, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute10, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute11, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute12, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute13, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute14, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute15, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute16, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute17, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute18, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute19, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute20, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute21, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute22, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute23, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute24, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute25, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute26, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute27, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute28, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute29, hr_api.g_varchar2)  or
    nvl(per_bpr_shd.g_old_rec.bpr_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.bpr_attribute30, hr_api.g_varchar2) ))
    or (p_rec.payroll_run_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_BF_PAYROLL_RUNS'
      ,p_attribute_category              => p_rec.bpr_attribute_category
      ,p_attribute1_name                 => 'BPR_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.bpr_attribute1
      ,p_attribute2_name                 => 'BPR_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.bpr_attribute2
      ,p_attribute3_name                 => 'BPR_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.bpr_attribute3
      ,p_attribute4_name                 => 'BPR_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.bpr_attribute4
      ,p_attribute5_name                 => 'BPR_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.bpr_attribute5
      ,p_attribute6_name                 => 'BPR_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.bpr_attribute6
      ,p_attribute7_name                 => 'BPR_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.bpr_attribute7
      ,p_attribute8_name                 => 'BPR_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.bpr_attribute8
      ,p_attribute9_name                 => 'BPR_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.bpr_attribute9
      ,p_attribute10_name                => 'BPR_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.bpr_attribute10
      ,p_attribute11_name                => 'BPR_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.bpr_attribute11
      ,p_attribute12_name                => 'BPR_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.bpr_attribute12
      ,p_attribute13_name                => 'BPR_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.bpr_attribute13
      ,p_attribute14_name                => 'BPR_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.bpr_attribute14
      ,p_attribute15_name                => 'BPR_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.bpr_attribute15
      ,p_attribute16_name                => 'BPR_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.bpr_attribute16
      ,p_attribute17_name                => 'BPR_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.bpr_attribute17
      ,p_attribute18_name                => 'BPR_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.bpr_attribute18
      ,p_attribute19_name                => 'BPR_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.bpr_attribute19
      ,p_attribute20_name                => 'BPR_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.bpr_attribute20
      ,p_attribute21_name                => 'BPR_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.bpr_attribute21
      ,p_attribute22_name                => 'BPR_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.bpr_attribute22
      ,p_attribute23_name                => 'BPR_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.bpr_attribute23
      ,p_attribute24_name                => 'BPR_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.bpr_attribute24
      ,p_attribute25_name                => 'BPR_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.bpr_attribute25
      ,p_attribute26_name                => 'BPR_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.bpr_attribute26
      ,p_attribute27_name                => 'BPR_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.bpr_attribute27
      ,p_attribute28_name                => 'BPR_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.bpr_attribute28
      ,p_attribute29_name                => 'BPR_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.bpr_attribute29
      ,p_attribute30_name                => 'BPR_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.bpr_attribute30
      );
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
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
Procedure chk_non_updateable_args(p_rec in per_bpr_shd.g_rec_type) IS
--
  l_proc     varchar2(72) := g_package || 'check_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_bpr_shd.api_updating
      (p_payroll_run_id                         => p_rec.payroll_run_id
       ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE ', l_proc);
     hr_utility.set_message_token('STEP ', '5');
  END IF;
  --
  hr_utility.set_location(l_proc,10);
  --
  IF nvl(p_rec.payroll_id, hr_api.g_number) <>
  per_bpr_shd.g_old_rec.payroll_id then
  l_argument:='payroll_id';
  raise l_error;
  END IF;
  hr_utility.set_location(l_proc,20);
  --
  IF nvl(p_rec.business_group_id, hr_api.g_number) <>
  per_bpr_shd.g_old_rec.business_group_id then
  l_argument:='business_group_id';
  raise l_error;
  END IF;
  hr_utility.set_location(l_proc,30);
  --
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
  hr_utility.set_location(' Leaving:'||l_proc,20);
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_identifier >-----------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   A check to make sure the payroll_identifer is unique within the context
--   of the the business_group_id.
-- Pre-Conditions
--   None
-- In Arguments
--   p_payroll_identifier
--   p_business_group_id
-- Post Success
--   Process continues if the identifier is unique within the constraints
--   laid out above.
-- Post Failure
--   An application error will be raised and processing terminated if the
--   payroll identifier is not unique within the constraints laid out above.
--
Procedure chk_identifier
  ( p_payroll_identifier  in    per_bf_payroll_runs.payroll_identifier%TYPE
  , p_business_group_id   in    per_bf_payroll_runs.business_group_id%TYPE
  , p_payroll_run_id      in    per_bf_payroll_runs.payroll_run_id%TYPE
  )
is
  --
  l_proc     varchar2(72) := g_package || 'chk_identifier';
  --
  CURSOR c_check_identifier IS
  SELECT 1
  FROM per_bf_payroll_runs
  WHERE(  (p_payroll_run_id IS NULL)
       or (payroll_run_id <> p_payroll_run_id))
    AND payroll_identifier = p_payroll_identifier
    AND business_group_id  = p_business_group_id ;
  --
  l_temp   VARCHAR2(1);
begin
  hr_utility.set_location ('Entering:'|| l_proc, 1);
  --
  --
  -- Check that the business_group_id is not null.
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'business_group_id'
    ,p_argument_value   => p_business_group_id
    );
  --
  OPEN c_check_identifier;
  FETCH c_check_identifier INTO l_temp;
  --
  IF c_check_identifier%FOUND THEN
    --
    -- Another row exists with the same identifier in the same context
    -- so error.
    --
    close c_check_identifier;
    --
    per_bpr_shd.constraint_error('PER_BF_PAYROLL_RUNS_UK1');
    --
  END IF;
  --
  close c_check_identifier;
  --
end chk_identifier;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_run_dates >------------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   One of the following dates must be set:
--       PERIOD_START_DATE
--       PERIOD_END_DATE
--       PROCESSING_DATE
--   Processing_date must be greater or equal to period_start_date
-- Pre-Conditions
--   None
--
-- In Arguments
--   p_period_start_date
--   p_period_end_date
--   p_processing_date
--   p_payroll_run_id
--   p_object_version_number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   An application error will be raised and processing terminated.
--
PROCEDURE chk_run_dates
 ( p_period_start_date     in    per_bf_payroll_runs.period_start_date%TYPE
 , p_period_end_date       in    per_bf_payroll_runs.period_end_date%TYPE
 , p_processing_date       in    per_bf_payroll_runs.processing_date%TYPE
 , p_payroll_run_id        in    per_bf_payroll_runs.payroll_run_id%TYPE
 , p_object_version_number in    per_bf_payroll_runs.object_version_number%TYPE
  ) IS
--
  l_proc  varchar2(72) := g_package||'chk_run_dates';
--
  l_start_date          DATE;
  l_processing_date     DATE;
  l_api_updating        BOOLEAN;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := per_bpr_shd.api_updating
    (p_payroll_run_id        => p_payroll_run_id
    ,p_object_version_number => p_object_version_number
    );
  --
  IF ( (p_period_start_date IS NULL)
    OR (   l_api_updating
       AND NVL (per_bpr_shd.g_old_rec.period_start_date, hr_api.g_date)
	 = NVL (p_period_start_date, hr_api.g_date)
       AND per_bpr_shd.g_old_rec.period_start_date IS NULL
       )
     ) THEN
      --
      IF ( (p_period_end_date IS NULL)
      OR (   l_api_updating
         AND NVL (per_bpr_shd.g_old_rec.period_end_date, hr_api.g_date)
	   = NVL (p_period_end_date, hr_api.g_date)
         AND per_bpr_shd.g_old_rec.period_end_date IS NULL
         )
       ) THEN
      --
      IF ( (p_processing_date IS NULL)
        OR (   l_api_updating
           AND NVL (per_bpr_shd.g_old_rec.processing_date, hr_api.g_date)
	     = NVL (p_processing_date, hr_api.g_date)
           AND per_bpr_shd.g_old_rec.processing_date IS NULL
	   )
         ) THEN
        --
	-- All the dates are Null, so raise an error as at least one must be
	-- set.
	--
        hr_utility.set_message(800,'HR_52932_ALL_DATES_NULL');
        hr_utility.raise_error;
      END IF;
    END IF;
  END IF;
  --
  -- Check to make sure that the processing date is later or equal to the
  -- start date.
  --
     -- If inserting and the start date is greater than the processing date ..
  IF ((NOT l_api_updating AND NVL(p_period_start_date, hr_api.g_sot)
                               > p_processing_date)
     OR
       -- If updating and either the start date or processing date have changed
       ((l_api_updating and nvl(per_bpr_shd.g_old_rec.period_start_date,
                                hr_api.g_date)
                        <> nvl(p_period_start_date, hr_api.g_date))
        OR
        (l_api_updating and nvl(per_bpr_shd.g_old_rec.processing_date,
                                hr_api.g_date)
                        <> nvl(p_processing_date, hr_api.g_date)))) THEN
    --
    -- Make the dates are equal to their actual value and not
    -- hr_api.g_date
    --
    IF (l_api_updating and p_period_start_date = hr_api.g_date) THEN
      --
      l_start_date := NVL(per_bpr_shd.g_old_rec.period_start_date
                         ,hr_api.g_sot);
      --
    ELSE
      --
      l_start_date := NVL(p_period_start_date, hr_api.g_sot);
      --
    END IF;
    IF (l_api_updating AND p_processing_date = hr_api.g_date) THEN
      --
      l_processing_date := NVL(per_bpr_shd.g_old_rec.processing_date
                              ,hr_api.g_eot);
      --
    ELSE
      --
      l_processing_date := NVL(p_processing_date,hr_api.g_eot);
      --
    END IF;
    --
    -- Now the actual date exist, perform the check
    --
    IF l_start_date > l_processing_date THEN
      --
      -- The start date is greater than the processing date
      hr_utility.set_message(800,'HR_52608_PROC_DATE_PROB');
      hr_utility.raise_error;
      --
    END IF;
  END IF;
  --
END CHK_RUN_DATES;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_start_end >-------------------------|
-- ----------------------------------------------------------------------------
-- Description
--    If both exist, the start date has to be greater than the end date
--    and if the end date exists then the start date has to exist.
--
-- Pre-Conditions
--   None
-- In Arguments
--   p_period_start_date
--   p_period_end_date
-- Post Success
--   Processing continues
--
-- Post Failure
--   An application error will be raised and processing terminated.
--
PROCEDURE chk_date_start_end
 ( p_period_start_date     in    per_bf_payroll_runs.period_start_date%TYPE
 , p_period_end_date       in    per_bf_payroll_runs.period_end_date%TYPE
 , p_payroll_run_id        in    per_bf_payroll_runs.payroll_run_id%TYPE
 , p_object_version_number in    per_bf_payroll_runs.object_version_number%TYPE
  ) IS
  --
  l_start_date       	DATE;
  l_end_date            DATE;
  l_api_updating	BOOLEAN;
  --
BEGIN
  --
  -- Only proceed with the validation if :
  --  a) The current g_old_rec is current.
  --  b) The period_start_date has changed.
  --  c) The period_end_date has changed.
  --  d) a record is being inserted.
  --
  --
  l_api_updating := per_bpr_shd.api_updating
    (p_payroll_run_id        => p_payroll_run_id
    ,p_object_version_number => p_object_version_number
    );
  --
  IF (((l_api_updating and nvl(per_bpr_shd.g_old_rec.period_start_date,
                                hr_api.g_date)
                        <> nvl(p_period_start_date, hr_api.g_date))
      OR
        (l_api_updating and nvl(per_bpr_shd.g_old_rec.period_end_date,
                                 hr_api.g_date)
                        <> nvl(p_period_end_date, hr_api.g_date))
       )
  OR
    (NOT l_api_updating)) THEN
    --
    --
    -- Make sure the dates are equal to their actual value and not
    -- hr_api.g_date
    --
    IF (l_api_updating and p_period_start_date = hr_api.g_date) THEN
      --
      l_start_date := per_bpr_shd.g_old_rec.period_start_date;
      --
    ELSE
      --
      l_start_date := p_period_start_date;
      --
    END IF;
    IF (l_api_updating AND p_period_end_date = hr_api.g_date) THEN
      --
      l_end_date := per_bpr_shd.g_old_rec.period_end_date;
      --
    ELSE
      --
      l_end_date := p_period_end_date;
      --
    END IF;
    --
    -- If the period_start_date is greater than the period_end_date, raise an
    -- error
    IF ((l_start_date IS NOT NULL) and (l_end_date IS NOT NULL)
      AND (l_start_date > l_end_date)) THEN
      --
      hr_utility.set_message (800,'HR_52933_DATE_START_END');
      hr_utility.raise_error;
      --
    END IF;
    --
    IF ((l_start_date IS NULL) and (l_end_date IS NOT NULL))
      THEN
      --
      hr_utility.set_message (800,'HR_52607_DATE_START_NULL_END');
      hr_utility.raise_error;
      --
    END IF;
  END IF;
END chk_date_start_end;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_row_exists >-----------------------------|
-- ----------------------------------------------------------------------------
--
  Procedure chk_row_exists
(p_payroll_run_id in number
) is
--
l_exists  varchar2(1);
l_proc    varchar2(72) := g_package || 'chk_row_exists';
--
-- Cursor to check if row exists in per_bf_processed_assignments for given
-- payroll_run_id
--
cursor csr_payroll_exists is
  select 'Y'
  from per_bf_processed_assignments bpa
  where bpa.payroll_run_id = p_payroll_run_id;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 10);
--
if p_payroll_run_id is not null then
  open csr_payroll_exists;
  fetch csr_payroll_exists into l_exists;
  if csr_payroll_exists%FOUND then
  -- row exists - raise error by calling contraint error
  close csr_payroll_exists;
  per_bpr_shd.constraint_error('PER_BF_PAYROLL_RUNS_REX');
  end if;
  close csr_payroll_exists;
end if;
end chk_row_exists;
--

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_effective_date   in  date,
                          p_rec in per_bpr_shd.g_rec_type
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_identifier
  ( p_payroll_identifier  =>  p_rec.payroll_identifier
  , p_business_group_id   =>  p_rec.business_group_id
  , p_payroll_run_id      =>  p_rec.payroll_run_id
  );
  --
  chk_run_dates
  ( p_period_start_date   =>  p_rec.period_start_date
  , p_period_end_date     =>  p_rec.period_end_date
  , p_processing_date     =>  p_rec.processing_date
  , p_payroll_run_id      =>  p_rec.payroll_run_id
  , p_object_version_number => p_rec.object_version_number
  ) ;
  --
  chk_date_start_end
  ( p_period_start_date   =>  p_rec.period_start_date
  , p_period_end_date     =>  p_rec.period_end_date
  , p_payroll_run_id      =>  p_rec.payroll_run_id
  , p_object_version_number => p_rec.object_version_number
  );
  --
  -- Validate flexfields
  -- ===================
  chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_effective_date   in  date,
                          p_rec in per_bpr_shd.g_rec_type
                         ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- VALIDATE IDENTIFIER
  --   Business Rule Mapping
  --   =====================
  --  Rule CHK_IDENTIFIER a
  --
  chk_identifier
  ( p_payroll_identifier  =>  p_rec.payroll_identifier
  , p_business_group_id   =>  p_rec.business_group_id
  , p_payroll_run_id      =>  p_rec.payroll_run_id
  );
  --
  chk_run_dates
  ( p_period_start_date   =>  p_rec.period_start_date
  , p_period_end_date     =>  p_rec.period_end_date
  , p_processing_date     =>  p_rec.processing_date
  , p_payroll_run_id      =>  p_rec.payroll_run_id
  , p_object_version_number => p_rec.object_version_number
  ) ;
  --
  chk_date_start_end
  ( p_period_start_date   =>  p_rec.period_start_date
  , p_period_end_date     =>  p_rec.period_end_date
  , p_payroll_run_id      =>  p_rec.payroll_run_id
  , p_object_version_number => p_rec.object_version_number
  );
  --
  chk_non_updateable_args(p_rec => p_rec);
  --
  -- Validate flexfields
  -- ===================
  chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_bpr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_row_exists(p_payroll_run_id => p_rec.payroll_run_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_bpr_bus;

/
