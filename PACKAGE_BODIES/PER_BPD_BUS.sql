--------------------------------------------------------
--  DDL for Package Body PER_BPD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BPD_BUS" as
/* $Header: pebpdrhi.pkb 115.6 2002/12/02 13:52:43 apholt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_bpd_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_payment_detail_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure set_security_group_id
(p_payment_detail_id                    in number
) is
--
-- Declare cursor
--
cursor csr_sec_grp is
select inf.org_information14
from hr_organization_information inf
 , per_bf_payment_details bpd
where bpd.payment_detail_id = p_payment_detail_id
and inf.organization_id   = bpd.business_group_id
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
		     p_argument           => 'PAYMENT_DETAIL_ID',
		     p_argument_value     => p_payment_detail_id);
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
(p_payment_detail_id                    in number) return varchar2 is
--
-- Declare cursor
--
cursor csr_leg_code is
select pbg.legislation_code
from per_business_groups pbg
 , per_bf_payment_details bpd
where bpd.payment_detail_id = p_payment_detail_id
and pbg.business_group_id = bpd.business_group_id;
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
		     p_argument           => 'PAYMENT_DETAIL_ID',
		     p_argument_value     => p_payment_detail_id);
--
if ( nvl(g_payment_detail_id, hr_api.g_number)
= p_payment_detail_id) then
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
g_payment_detail_id                 := p_payment_detail_id;
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
(p_rec in per_bpd_shd.g_rec_type
) is
--
l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
hr_utility.set_location('Entering:'||l_proc,10);
--
if ((p_rec.payment_detail_id is not null)  and (
nvl(per_bpd_shd.g_old_rec.bpd_attribute_category, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute_category, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute1, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute1, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute2, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute2, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute3, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute3, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute4, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute4, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute5, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute5, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute6, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute6, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute7, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute7, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute8, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute8, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute9, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute9, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute10, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute10, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute11, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute11, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute12, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute12, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute13, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute13, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute14, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute14, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute15, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute15, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute16, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute16, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute17, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute17, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute18, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute18, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute19, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute19, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute20, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute20, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute21, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute21, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute22, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute22, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute23, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute23, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute24, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute24, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute25, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute25, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute26, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute26, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute27, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute27, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute28, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute28, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute29, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute29, hr_api.g_varchar2)  or
nvl(per_bpd_shd.g_old_rec.bpd_attribute30, hr_api.g_varchar2) <>
nvl(p_rec.bpd_attribute30, hr_api.g_varchar2) ))
or (p_rec.payment_detail_id is null)  then
--
-- Only execute the validation if absolutely necessary:
-- a) During update, the structure column value or any
--    of the attribute values have actually changed.
-- b) During insert.
--
hr_dflex_utility.ins_or_upd_descflex_attribs
(p_appl_short_name                 => 'PER'
,p_descflex_name                   => 'PER_BF_PAYMENT_DETAILS'
,p_attribute_category              => p_rec.bpd_attribute_category
,p_attribute1_name                 => 'BPD_ATTRIBUTE1'
,p_attribute1_value                => p_rec.bpd_attribute1
,p_attribute2_name                 => 'BPD_ATTRIBUTE2'
,p_attribute2_value                => p_rec.bpd_attribute2
,p_attribute3_name                 => 'BPD_ATTRIBUTE3'
,p_attribute3_value                => p_rec.bpd_attribute3
,p_attribute4_name                 => 'BPD_ATTRIBUTE4'
,p_attribute4_value                => p_rec.bpd_attribute4
,p_attribute5_name                 => 'BPD_ATTRIBUTE5'
,p_attribute5_value                => p_rec.bpd_attribute5
,p_attribute6_name                 => 'BPD_ATTRIBUTE6'
,p_attribute6_value                => p_rec.bpd_attribute6
,p_attribute7_name                 => 'BPD_ATTRIBUTE7'
,p_attribute7_value                => p_rec.bpd_attribute7
,p_attribute8_name                 => 'BPD_ATTRIBUTE8'
,p_attribute8_value                => p_rec.bpd_attribute8
,p_attribute9_name                 => 'BPD_ATTRIBUTE9'
,p_attribute9_value                => p_rec.bpd_attribute9
,p_attribute10_name                => 'BPD_ATTRIBUTE10'
,p_attribute10_value               => p_rec.bpd_attribute10
,p_attribute11_name                => 'BPD_ATTRIBUTE11'
,p_attribute11_value               => p_rec.bpd_attribute11
,p_attribute12_name                => 'BPD_ATTRIBUTE12'
,p_attribute12_value               => p_rec.bpd_attribute12
,p_attribute13_name                => 'BPD_ATTRIBUTE13'
,p_attribute13_value               => p_rec.bpd_attribute13
,p_attribute14_name                => 'BPD_ATTRIBUTE14'
,p_attribute14_value               => p_rec.bpd_attribute14
,p_attribute15_name                => 'BPD_ATTRIBUTE15'
,p_attribute15_value               => p_rec.bpd_attribute15
,p_attribute16_name                => 'BPD_ATTRIBUTE16'
,p_attribute16_value               => p_rec.bpd_attribute16
,p_attribute17_name                => 'BPD_ATTRIBUTE17'
,p_attribute17_value               => p_rec.bpd_attribute17
,p_attribute18_name                => 'BPD_ATTRIBUTE18'
,p_attribute18_value               => p_rec.bpd_attribute18
,p_attribute19_name                => 'BPD_ATTRIBUTE19'
,p_attribute19_value               => p_rec.bpd_attribute19
,p_attribute20_name                => 'BPD_ATTRIBUTE20'
,p_attribute20_value               => p_rec.bpd_attribute20
,p_attribute21_name                => 'BPD_ATTRIBUTE21'
,p_attribute21_value               => p_rec.bpd_attribute21
,p_attribute22_name                => 'BPD_ATTRIBUTE22'
,p_attribute22_value               => p_rec.bpd_attribute22
,p_attribute23_name                => 'BPD_ATTRIBUTE23'
,p_attribute23_value               => p_rec.bpd_attribute23
,p_attribute24_name                => 'BPD_ATTRIBUTE24'
,p_attribute24_value               => p_rec.bpd_attribute24
,p_attribute25_name                => 'BPD_ATTRIBUTE25'
,p_attribute25_value               => p_rec.bpd_attribute25
,p_attribute26_name                => 'BPD_ATTRIBUTE26'
,p_attribute26_value               => p_rec.bpd_attribute26
,p_attribute27_name                => 'BPD_ATTRIBUTE27'
,p_attribute27_value               => p_rec.bpd_attribute27
,p_attribute28_name                => 'BPD_ATTRIBUTE28'
,p_attribute28_value               => p_rec.bpd_attribute28
,p_attribute29_name                => 'BPD_ATTRIBUTE29'
,p_attribute29_value               => p_rec.bpd_attribute29
,p_attribute30_name                => 'BPD_ATTRIBUTE30'
,p_attribute30_value               => p_rec.bpd_attribute30

);
end if;
--
hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
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
Procedure chk_non_updateable_args(p_rec in per_bpd_shd.g_rec_type) IS
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
IF NOT per_bpd_shd.api_updating
(p_payment_detail_id                      => p_rec.payment_detail_id
,p_object_version_number                => p_rec.object_version_number
) THEN
hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
hr_utility.set_message_token('PROCEDURE ', l_proc);
hr_utility.set_message_token('STEP ', '5');
END IF;
--
hr_utility.set_location(l_proc,10);
--
IF nvl(p_rec.processed_assignment_id, hr_api.g_number) <>
per_bpd_shd.g_old_rec.processed_assignment_id then
l_argument:='processed_assignment_id';
raise l_error;
END IF;
hr_utility.set_location(l_proc,20);
--
IF nvl(p_rec.personal_payment_method_id, hr_api.g_number) <>
per_bpd_shd.g_old_rec.personal_payment_method_id then
l_argument:='personal_payment_method_id';
raise l_error;
END IF;
hr_utility.set_location(l_proc,30);
--
IF nvl(p_rec.business_group_id, hr_api.g_number) <>
per_bpd_shd.g_old_rec.business_group_id then
l_argument:='business_group_id';
raise l_error;
END IF;
hr_utility.set_location(l_proc,40);
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
-- |----------------------< chk_payment_method_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Check that the personal_payment method id exists in the table
--   PAY_PERSONAL_PAYMENT_METHODS_F and is in the same business group
--
-- Pre Conditions:
--
-- In Arguments:
--   p_payment_method_id
--   p_business_group_id
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE CHK_PAYMENT_METHOD_ID
(p_personal_payment_method_id   IN  NUMBER
,p_business_group_id            IN  NUMBER
)
IS
CURSOR csr_get_method_details IS
SELECT 1
FROM PAY_PERSONAL_PAYMENT_METHODS_F
WHERE personal_payment_method_id = p_personal_payment_method_id
AND business_group_id = p_business_group_id;
--
l_temp  VARCHAR2(1) ;
--
BEGIN
OPEN csr_get_method_details;
FETCH csr_get_method_details INTO l_temp;
IF csr_get_method_details%NOTFOUND THEN
CLOSE csr_get_method_details;
--
-- There isn't a payment_method with the id passed in which is in the
-- same business group so error
--
hr_utility.set_message(800,'HR_52947_INVALID_PPM_ID');
hr_utility.raise_error;
--
END IF;
CLOSE csr_get_method_details;
END CHK_PAYMENT_METHOD_ID;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_processed_asg_id >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Check that the processed_asg_idexists in the table
--   PER_BF_PROCESSED_ASSIGNMENTS
--
-- Pre Conditions:
--
-- In Arguments:
--   p_processed_assignment_id
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_processed_asg_id
 (p_processed_assignment_id  IN NUMBER)
IS
  --
  CURSOR csr_chk_processed_asg_id IS
  SELECT 1
  FROM PER_BF_PROCESSED_ASSIGNMENTS
  WHERE processed_assignment_id = p_processed_assignment_id;
  --
  l_temp   VARCHAR2(1);
BEGIN
  --
  OPEN csr_chk_processed_asg_id ;
  FETCH csr_chk_processed_asg_id INTO l_temp;
  IF csr_chk_processed_asg_id%NOTFOUND THEN
    --
    CLOSE csr_chk_processed_asg_id;
    --
    -- The ID hasn't been found, so error
    --
    hr_utility.set_message(800,'HR_52948_BAD_PROCESSED_ASG_ID');
    hr_utility.raise_error;
    --
  END IF;
  CLOSE csr_chk_processed_asg_id;
  --
END chk_processed_asg_id;
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_check_type >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   If the CHECK_TYPE is not null, check that it is contained in HR_LOOKUPS
-- Pre Conditions:
--
-- In Arguments:
--   p_payment_detail_id
--   p_object_version_number
--   p_check_type
--   p_effective_date
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE chk_check_type
  (p_payment_detail_id	 	IN NUMBER
  ,p_object_version_number      IN NUMBER
  ,p_check_type                 IN VARCHAR2
  ,p_effective_date             IN DATE)
IS
  --
  CURSOR csr_check_type IS
  SELECT start_date_active, end_date_active
  FROM hr_lookups
  WHERE lookup_type = 'BACKFEED_PD_CHECK_TYPE'
    AND  lookup_code = p_check_type;
  --
  l_start_date 	DATE;
  l_end_date 	DATE;
  --
  l_api_updating           BOOLEAN;
BEGIN
  --
  -- Only perform the tests if a check_type exists and we are inserting
  --
  l_api_updating := per_bpd_shd.api_updating
    (p_payment_detail_id => p_payment_detail_id
    ,p_object_version_number => p_object_version_number);
  --
  IF p_check_type IS NOT NULL AND NOT l_api_updating THEN
    --
    -- Cursor selects the start and end active dates rather than including them
    -- as part of the where clause in order to give a more meaningful message.
    --
    OPEN csr_check_type;
    FETCH csr_check_type INTO l_start_date, l_end_date;
    --
    IF csr_check_type%NOTFOUND THEN
      --
      -- The lookup code entered doesn't exist in hr_lookups
      -- so error.
      --
      hr_utility.set_message(800, 'HR_52949_CT_NOT_EXIST');
      hr_utility.raise_error;
      --
    END IF;
    --
    IF p_effective_date not between NVL (l_start_date, hr_api.g_sot)
				and NVL (l_end_date, hr_api.g_eot)  THEN
      --
      -- The lookup exists, but it isn't valid for the effective date
      -- so error.
      --
      hr_utility.set_message(800,'HR_52351_CT_NOT_VALID');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
END chk_check_type;
-- ----------------------------------------------------------------------------
-- ----------------------------< chk_ids_unique >---------------------------
-- ----------------------------------------------------------------------------
Procedure chk_ids_unique(p_processed_assignment_id     in number,
                         p_personal_payment_method_id  in number) is
--
-- Procedure to check that p_processed_assignment_id and
-- p_personal_payment_method_id are unique
--
  l_exists varchar2(1);
  l_proc   varchar2(72):= g_package || 'chk_ids_unique';
--
-- Cursor to check p_processed_assignment_id and
-- p_personal_payment_method are unique
--
cursor csr_unique_ids is
  select 'Y'
  from per_bf_payment_details
  where processed_assignment_id = p_processed_assignment_id
  and personal_payment_method_id = p_personal_payment_method_id;
--
begin
  hr_utility.set_location('Entering: '||l_proc, 10);
--
  hr_api.mandatory_arg_error(p_api_name   => l_proc
                    ,p_argument           => 'PROCESSED_ASSIGNMENT_ID'
                    ,p_argument_value     => p_processed_assignment_id);
--
  hr_api.mandatory_arg_error(p_api_name   => l_proc
                    ,p_argument           => 'PERSONAL_PAYMENT_METHOD_ID'
                    ,p_argument_value     => p_personal_payment_method_id);
--
  open csr_unique_ids;
  fetch csr_unique_ids into l_exists;
  if csr_unique_ids%FOUND then
  --ids are not unique - raise error by calling constraint error
  close csr_unique_ids;
  per_bpd_shd.constraint_error('PER_BF_PAYMENT_DETAILS_UK1');
  end if;
  close csr_unique_ids;
--
hr_utility.set_location(' Leaving: '||l_proc, 50);
--
end chk_ids_unique;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_effective_date   in  date,
                          p_rec in per_bpd_shd.g_rec_type
                         ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_check_type
  (p_payment_detail_id	 	=> p_rec.payment_detail_id
  ,p_object_version_number      => p_rec.object_version_number
  ,p_check_type                 => p_rec.check_type
  ,p_effective_date             => p_effective_date);
  --
  --
 CHK_PAYMENT_METHOD_ID
  (p_personal_payment_method_id   => p_rec.personal_payment_method_id
  ,p_business_group_id            => p_rec.business_group_id
  );
  --
 CHK_PROCESSED_ASG_ID
 (p_processed_assignment_id  => p_rec.processed_assignment_id);
  --
 chk_ids_unique
 (p_processed_assignment_id     => p_rec.processed_assignment_id
 ,p_personal_payment_method_id  => p_rec.personal_payment_method_id);
  --
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
                          p_rec in per_bpd_shd.g_rec_type
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
  chk_check_type
  (p_payment_detail_id	 	=> p_rec.payment_detail_id
  ,p_object_version_number      => p_rec.object_version_number
  ,p_check_type                 => p_rec.check_type
  ,p_effective_date             => p_effective_date);
  --
  chk_non_updateable_args
     (p_rec => p_rec);
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
Procedure delete_validate(p_rec in per_bpd_shd.g_rec_type) is
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
end per_bpd_bus;

/
