--------------------------------------------------------
--  DDL for Package Body PER_BPA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPA_BUS" as
/* $Header: pebparhi.pkb 115.6 2002/12/02 13:36:46 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpa_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_processed_assignment_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_processed_assignment_id              in number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_bf_processed_assignments bpa
         , per_bf_payroll_runs bpr
     where bpa.processed_assignment_id = p_processed_assignment_id
       and bpa.payroll_run_id = bpr.payroll_run_id
       and pbg.business_group_id = bpr.business_group_id;
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
  hr_api.mandatory_arg_error(p_api_name           => l_proc
                            ,p_argument           => 'PROCESSED_ASSIGNMENT_ID'
                            ,p_argument_value     => p_processed_assignment_id);
  --
  if ( nvl(g_processed_assignment_id, hr_api.g_number)
       = p_processed_assignment_id) then
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
    g_processed_assignment_id           := p_processed_assignment_id;
    g_legislation_code                  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >---------------------------------
--
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
  (p_rec in per_bpa_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.processed_assignment_id is not null)  and (
    nvl(per_bpa_shd.g_old_rec.bpa_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute_category, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute1, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute2, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute3, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute4, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute5, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute6, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute7, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute8, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute9, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute10, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute11, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute12, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute13, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute14, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute15, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute16, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute17, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute18, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute19, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute20, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute21, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute22, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute23, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute24, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute25, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute26, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute27, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute28, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute29, hr_api.g_varchar2)  or
    nvl(per_bpa_shd.g_old_rec.bpa_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.bpa_attribute30, hr_api.g_varchar2) ))
    or (p_rec.processed_assignment_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_BF_PROCESSED_ASSIGNMENTS'
      ,p_attribute_category              => p_rec.bpa_attribute_category
      ,p_attribute1_name                 => 'BPA_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.bpa_attribute1
      ,p_attribute2_name                 => 'BPA_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.bpa_attribute2
      ,p_attribute3_name                 => 'BPA_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.bpa_attribute3
      ,p_attribute4_name                 => 'BPA_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.bpa_attribute4
      ,p_attribute5_name                 => 'BPA_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.bpa_attribute5
      ,p_attribute6_name                 => 'BPA_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.bpa_attribute6
      ,p_attribute7_name                 => 'BPA_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.bpa_attribute7
      ,p_attribute8_name                 => 'BPA_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.bpa_attribute8
      ,p_attribute9_name                 => 'BPA_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.bpa_attribute9
      ,p_attribute10_name                => 'BPA_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.bpa_attribute10
      ,p_attribute11_name                => 'BPA_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.bpa_attribute11
      ,p_attribute12_name                => 'BPA_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.bpa_attribute12
      ,p_attribute13_name                => 'BPA_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.bpa_attribute13
      ,p_attribute14_name                => 'BPA_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.bpa_attribute14
      ,p_attribute15_name                => 'BPA_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.bpa_attribute15
      ,p_attribute16_name                => 'BPA_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.bpa_attribute16
      ,p_attribute17_name                => 'BPA_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.bpa_attribute17
      ,p_attribute18_name                => 'BPA_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.bpa_attribute18
      ,p_attribute19_name                => 'BPA_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.bpa_attribute19
      ,p_attribute20_name                => 'BPA_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.bpa_attribute20
      ,p_attribute21_name                => 'BPA_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.bpa_attribute21
      ,p_attribute22_name                => 'BPA_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.bpa_attribute22
      ,p_attribute23_name                => 'BPA_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.bpa_attribute23
      ,p_attribute24_name                => 'BPA_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.bpa_attribute24
      ,p_attribute25_name                => 'BPA_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.bpa_attribute25
      ,p_attribute26_name                => 'BPA_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.bpa_attribute26
      ,p_attribute27_name                => 'BPA_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.bpa_attribute27
      ,p_attribute28_name                => 'BPA_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.bpa_attribute28
      ,p_attribute29_name                => 'BPA_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.bpa_attribute29
      ,p_attribute30_name                => 'BPA_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.bpa_attribute30
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
Procedure chk_non_updateable_args
  (p_rec in per_bpa_shd.g_rec_type
  ) IS
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
  IF NOT per_bpa_shd.api_updating
      (p_processed_assignment_id              => p_rec.processed_assignment_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE ', l_proc);
     hr_utility.set_message_token('STEP ', '5');
  END IF;
  --
  hr_utility.set_location(l_proc,10);
  --
  IF nvl(p_rec.payroll_run_id, hr_api.g_number) <>
  per_bpa_shd.g_old_rec.payroll_run_id then
  l_argument:='payroll_run_id';
  raise l_error;
  END IF;
  hr_utility.set_location(l_proc,20);
  --
  IF nvl(p_rec.assignment_id, hr_api.g_number) <>
  per_bpa_shd.g_old_rec.assignment_id then
  l_argument:='assigment_id';
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
  hr_utility.set_location(' Leaving:'||l_proc,40);
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_assignment_id >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Check to make sure the assignment exists and that it is valid on the
--  effective date.
--
-- Pre Conditions:
--
--
-- In Arguments:
--   p_assignment_id
--   p_effective_date
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--    Processing is terminated and an application error is raised.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_assignment_id
( p_assignment_id  IN NUMBER
, p_effective_date IN DATE
)
IS
--
CURSOR csr_get_asg_dates IS
SELECT effective_start_date, effective_end_date
FROM per_all_assignments_f
WHERE assignment_id = p_assignment_id
AND p_effective_date BETWEEN
effective_start_date and effective_end_date;
--
l_esd 	DATE;
l_eed		DATE;
--
l_proc  varchar2(72) := g_package||'chk_assignment_id';
BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);
--
OPEN  csr_get_asg_dates;
FETCH csr_get_asg_dates INTO l_esd, l_eed;
--
IF csr_get_asg_dates%NOTFOUND THEN
--
CLOSE csr_get_asg_dates ;
-- The assignment_id doesn't exist in the assignment table
-- for the specified time period, so error.
--
hr_utility.set_message(800,'HR_52934_NO_ASG_AVAIL');
hr_utility.raise_error;
--
END IF;
--
CLOSE csr_get_asg_dates ;
END chk_assignment_id;
-- ----------------------------------------------------------------------------
-- |----------------------< chk_payroll_run_id >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Check to make sure the payroll run id exists.
--
-- Pre Conditions:
--
--
-- In Arguments:
--   p_payroll_run_id
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--    Processing is terminated and an application error is raised.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_payroll_run_id
( p_payroll_run_id  IN NUMBER
)
IS
--
CURSOR csr_get_run_dates IS
SELECT 1
FROM per_bf_payroll_runs
WHERE payroll_run_id = p_payroll_run_id;
--
l_temp  VARCHAR2(1);
--
l_proc  varchar2(72) := g_package||'chk_payroll_run_id';
BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);
--
OPEN  csr_get_run_dates;
FETCH csr_get_run_dates INTO l_temp;
--
IF csr_get_run_dates%NOTFOUND THEN
--
CLOSE csr_get_run_dates;
--
-- The payroll_run_id doesn't exist in the run table
-- so error
--
per_bpa_shd.constraint_error
(p_constraint_name => 'PER_BF_PROCESSED_ASSIGNS_FK1');
--
END IF;
CLOSE csr_get_run_dates;
--
--
END chk_payroll_run_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_bg_are_same >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    Check to make sure the business group of the assignment (assignment_id)
--  is the same as the business group of the payroll run (payroll run id).
--
-- Pre Conditions:
--
--
-- In Arguments:
--   p_payroll_run_id
--   p_assignment_id
--   p_effective_date
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--    Processing is terminated and an application error is raised.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_bg_are_same
( p_payroll_run_id  IN NUMBER
, p_assignment_id   IN NUMBER
, p_effective_date  IN DATE)
IS
--
CURSOR csr_get_payroll_run_bg IS
SELECT business_group_id
FROM per_bf_payroll_runs
WHERE payroll_run_id = p_payroll_run_id;
--
CURSOR csr_get_assignment_bg IS
SELECT business_group_id
FROM per_all_assignments_f
WHERE assignment_id = p_assignment_id
AND p_effective_date BETWEEN
effective_start_date AND effective_end_date;
--
l_asg_bg     NUMBER;
l_run_bg     NUMBER;
--
l_proc  varchar2(72) := g_package||'chk_bg_are_same';
BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);
--
OPEN csr_get_payroll_run_bg;
FETCH csr_get_payroll_run_bg INTO l_run_bg;
CLOSE csr_get_payroll_run_bg;
--
OPEN csr_get_assignment_bg;
FETCH csr_get_assignment_bg INTO l_asg_bg;
CLOSE csr_get_assignment_bg;
--
-- No need to check whether the id's  are found as this will be revealed in
-- previous tests.
--
IF l_asg_bg <> l_run_bg THEN
--
-- The business groups of the assignment and payroll run differ, so error.
--
hr_utility.set_message(800,'HR_52936_DIFF_BGS');
hr_utility.raise_error;
--
END IF;
--
END chk_bg_are_same;
-- ----------------------------------------------------------------------------
-- -----------------------------< chk_child_rows >-----------------------------
-- ----------------------------------------------------------------------------
Procedure chk_child_rows
(p_processed_assignment_id in number
) is
--
l_exists  varchar2(1);
l_proc    varchar2(72) := g_package || 'chk_child_rows';
--
-- Cursor to check if child rows exist in per_bf_balance_amounts
--
cursor csr_balance_amount is
  select 'Y'
  from per_bf_balance_amounts bba
  where bba.processed_assignment_id = p_processed_assignment_id;
--
-- Cursor to check if child rows exist in per_bf_payment_details
--
cursor csr_payment_detail is
  select 'Y'
  from per_bf_payment_details bpd
  where bpd.processed_assignment_id = p_processed_assignment_id;

--
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 10);
--
if p_processed_assignment_id is not null then
  --
  open csr_balance_amount;
  fetch csr_balance_amount into l_exists;
  if csr_balance_amount%FOUND then
  --child row exists - raise error by calling constraint error
  close csr_balance_amount;
  per_bpa_shd.constraint_error('PER_BF_PROCESSED_ASSIGNS_BPAB');
  end if;
  close csr_balance_amount;
  --
  open csr_payment_detail;
  fetch csr_payment_detail into l_exists;
  if csr_payment_detail%FOUND then
  --child row exists - raise error by calling constraint error
  close csr_payment_detail;
  per_bpa_shd.constraint_error('PER_BF_PROCESSED_ASSIGNS_BPAP');
  end if;
  close csr_payment_detail;
  --
end if;
--
hr_utility.set_location('Leaving: '||l_proc,50);
--
END chk_child_rows;
--
-- ----------------------------------------------------------------------------
-- ----------------------------< chk_ids_unique >-----------------------------
-- ----------------------------------------------------------------------------
Procedure chk_ids_unique
(p_payroll_run_id in number,
 p_assignment_id  in number
) is
--
l_exists  varchar2(1);
l_proc    varchar2(72) := g_package || 'chk_ids_unique';
--
-- Cursors to check PER_BF_PROCESSED_ASSIGNS_UK1
--
cursor csr_id_unique is
-- checks p_assignment_id and p_payroll_run_id are unique
  select 'Y'
  from per_bf_processed_assignments
  where assignment_id = p_assignment_id
  and payroll_run_id = p_payroll_run_id;
--
BEGIN
  hr_utility.set_location('Entering: '||l_proc, 10);
--
  hr_api.mandatory_arg_error(p_api_name   => l_proc
                    ,p_argument           => 'ASSIGNMENT_ID'
                    ,p_argument_value     => p_assignment_id);
--
  hr_api.mandatory_arg_error(p_api_name   => l_proc
                    ,p_argument           => 'PAYROLL_RUN_ID'
                    ,p_argument_value     => p_payroll_run_id);
--
  open csr_id_unique;
  fetch csr_id_unique into l_exists;
  if csr_id_unique%FOUND then
-- -ids are not unique - raise error by calling contraint error
  close csr_id_unique;
  per_bpa_shd.constraint_error('PER_BF_PROCESSED_ASSIGNS_UK1');
  end if;
  close csr_id_unique;
--
hr_utility.set_location(' Leaving: '||l_proc, 50);
--
end chk_ids_unique;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_effective_date               in date
,p_rec                          in per_bpa_shd.g_rec_type
) is
--
l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Call all supporting business operations
--
-- Note: The chk_payroll_run_id is before the set_security_group_id
--       to ensure that the payroll run exists.
--
chk_payroll_run_id
( p_payroll_run_id  => p_rec.payroll_run_id
);
-- Call parent set_security_group_id proc.
--
per_bpr_bus.set_security_group_id
(p_payroll_run_id => p_rec.payroll_run_id);
--
chk_assignment_id
( p_assignment_id  => p_rec.assignment_id
, p_effective_date => p_effective_date
);
--
chk_bg_are_same
( p_payroll_run_id  => p_rec.payroll_run_id
, p_assignment_id   => p_rec.assignment_id
, p_effective_date  => p_effective_date);
--
chk_ids_unique
( p_payroll_run_id  => p_rec.payroll_run_id
, p_assignment_id   => p_rec.assignment_id);
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
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_bpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call parent set_security_group_id proc.
  --
  per_bpr_bus.set_security_group_id
    (p_payroll_run_id => p_rec.payroll_run_id);
  --
  --
  chk_non_updateable_args
    ( p_rec => p_rec );
  --
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
Procedure delete_validate
  (p_rec                          in per_bpa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_child_rows(p_processed_assignment_id => p_rec.processed_assignment_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_bpa_bus;

/
