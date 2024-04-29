--------------------------------------------------------
--  DDL for Package Body HR_ORU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORU_BUS" as
/* $Header: hrorurhi.pkb 120.2 2006/03/08 11:46:02 deenath noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_oru_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_organization_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_organization_id                      in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hr_all_organization_units oru
     where oru.organization_id = p_organization_id
       and pbg.business_group_id = oru.business_group_id;
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
    ,p_argument           => 'organization_id'
    ,p_argument_value     => p_organization_id
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
Function return_legislation_code
  (p_organization_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , hr_all_organization_units oru
     where oru.organization_id = p_organization_id
       and pbg.business_group_id = oru.business_group_id;
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
    ,p_argument           => 'organization_id'
    ,p_argument_value     => p_organization_id
    );
  --
  if ( nvl(hr_oru_bus.g_organization_id, hr_api.g_number)
       = p_organization_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_oru_bus.g_legislation_code;
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
    hr_oru_bus.g_organization_id   := p_organization_id;
    hr_oru_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hr_oru_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.organization_id is not null)  and (
    nvl(hr_oru_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hr_oru_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    -- Enhancement 4040086
    nvl(hr_oru_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2) or
    nvl(hr_oru_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2) or
    nvl(hr_oru_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2) or
    nvl(hr_oru_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2) or
    nvl(hr_oru_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2) or
    nvl(hr_oru_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2) or
    nvl(hr_oru_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2) or
    nvl(hr_oru_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2) or
    nvl(hr_oru_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2) or
    nvl(hr_oru_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    -- End Enhancement 4040086
    or (p_rec.organization_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
   if nvl(fnd_profile.value('FLEXFIELDS:VALIDATE_ON_SERVER'),'N') = 'Y' then
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_ORGANIZATION_UNITS'
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
      --Enhancement 4040086
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
      --End enhancement 4040086
      );
   end if;
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
  ,p_rec in hr_oru_shd.g_rec_type
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
  IF NOT hr_oru_shd.api_updating
      (p_organization_id                      => p_rec.organization_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
/* bug fix for 2999489
  IF nvl(p_rec.name, hr_api.g_varchar2) <>
     nvl(hr_oru_shd.g_old_rec.name, hr_api.g_varchar2) THEN
     l_argument := 'NAME';
     RAISE l_error;
  END IF;
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
*/
End chk_non_updateable_args;
--
--
--         THIS PROCEDURE HAS BEEN COMMENTED OUT DUE TO BUG 2074718
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_date_from >-------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that date_from of organization unit is greater than or equal
--    to date_from of the business group
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_date_from
--    p_effective_date
--    p_business_group_id
--
--  Post Success:
--    If date_from of organization unit is greater than or equal to date_from
--    of the relevant business group then normal processing continues
--
--  Post Failure:
--    If the date_from of the organization unit is less than the date_from of
--    the relevant business group then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained
--
--  Access Status:
--    Internal Row Handler Use Only
--
-- {End Of Comments}
--
--PROCEDURE chk_date_from
--  (p_date_from              IN     hr_all_organization_units.date_from%TYPE,
--   p_effective_date         IN     DATE,
--   p_business_group_id      IN     hr_all_organization_units.business_group_id%TYPE)
--IS
--
--   l_proc  VARCHAR2(72) := g_package||'chk_date_from';
--
--   l_bgr_date_from DATE;
--
--   CURSOR csr_bgr_date_from IS
--   SELECT date_from
--   FROM hr_all_organization_units
--   WHERE organization_id = p_business_group_id
--     AND business_group_id = p_business_group_id;
--
--BEGIN
--   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--   hr_api.mandatory_arg_error
--    (p_api_name           => l_proc
--    ,p_argument           => 'DATE_FROM'
--    ,p_argument_value     => p_date_from
--    );
--
   --
   -- Get date_from for the business group
   --
--   OPEN csr_bgr_date_from;
--   FETCH csr_bgr_date_from INTO l_bgr_date_from;
--   IF csr_bgr_date_from%notfound THEN
--     CLOSE csr_bgr_date_from;
--     hr_utility.set_message(800, 'HR_51491_ESA_BUS_GRP_ID_FK2');
--     hr_utility.raise_error;
--   END IF;
--   CLOSE csr_bgr_date_from;
   --
   --  If found, date_from must be greater or equal to business group
   --  date_from.
   --
--   IF p_date_from < l_bgr_date_from THEN
--      hr_utility.set_message(800, 'HR_52757_INV_DATE_FROM');
--      hr_utility.raise_error;
--   END IF;
   --
--   hr_utility.set_location('Leaving:'||l_proc, 30);
--
--END chk_date_from;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_name >-------------------------------------|
-- ----------------------------------------------------------------------------
--
--  Procedure description is in the header.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_name
  ( p_name                    IN     hr_all_organization_units.name%TYPE,
    p_effective_date          IN     DATE default NULL,
    p_business_group_id       IN     number,
    p_organization_id         IN     number default null,
p_duplicate_org_warning OUT NOCOPY  BOOLEAN
  )
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_name';
   l_exists         number;
    -- cursor returns organization id, business id, and boolean (BG) if the org is a BG
   l_is_business_group    boolean;
   l_duplicate_bg         boolean;
   l_bg                   number;
   CURSOR C1 is
      select o.organization_id, o.business_group_id
      from  hr_all_organization_units o
      where (o.name = p_name OR o.organization_id = p_organization_id);

BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
p_duplicate_org_warning := false;
l_is_business_group     := false;
l_duplicate_bg          := false;
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'NAME'
    ,p_argument_value     => p_name
    );
--
--
hr_utility.set_location(l_proc, 20);
--
--
-- Check organization name uniqueness throughout business groups if
-- Cross business profile option is set to Y
-- This will also check for duplicate business groups
--

for Crec in C1 loop

 select count(*)
 into l_bg
 from hr_organization_information i
 where i.organization_id = crec.organization_id
 and i.org_information1='HR_BG'
 and i.org_information_context='CLASS'
 and i.org_information2 ='Y';
if Crec.organization_id = nvl(p_organization_id,'-1') then
  if L_BG = 1 then
    l_is_business_group := true;-- if we are updating and the current row is
                                -- a BG, then l_is_business_group
                                -- is set to true
  end if;
else
  if L_BG = 1 then          -- if the row returned is a BG but not the
                            -- current row set both flags true
    l_duplicate_bg := TRUE;
    p_duplicate_org_warning := TRUE;
  elsif                          -- if it is not the current row, but XBG option is yes then set warning
   fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'Y' then
    p_duplicate_org_warning :=TRUE;
  end if;

  if (crec.business_group_id = p_business_group_id) then -- if not current row but in same business group
    hr_utility.set_message(800, 'HR_52751_DUPL_NAME');   -- raise error
    hr_utility.raise_error;
  end if;

end if;
end loop;

  if l_is_business_group and l_duplicate_bg then           -- using flags set above, if current row is a BG
     hr_utility.set_message(800, 'HR_289381_DUPLICATE_BG');-- and a different bg with the same name exists
     hr_utility.raise_error;                               -- raise the duplicate BG error
  end if;
--
--
hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_soft_coding_kf >---------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that soft_coding_keyflex_id of organization unit is present in
--    HR_SOFT_CODING_KEYFLEX table when not null.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_soft_coding_keyflex_id
--
--  Post Success:
--    If the soft_coding_keyflex_id attribute is present then
--    normal processing continues
--
--  Post Failure:
--    If the soft_coding_keyflex_id attribute is not present then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_soft_coding_kf
  ( p_soft_coding_keyflex_id IN hr_all_organization_units.soft_coding_keyflex_id%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_soft_coding_kf';
   l_exists         VARCHAR2(1) := 'N';
--
   cursor csr_soft_coding_keyflex_id IS
     SELECT 'Y'
        FROM hr_soft_coding_keyflex
        WHERE soft_coding_keyflex_id = p_soft_coding_keyflex_id;
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check soft_coding_keyflex_id uniqueness
--
  IF p_soft_coding_keyflex_id IS NOT null THEN
   OPEN csr_soft_coding_keyflex_id;
   FETCH csr_soft_coding_keyflex_id INTO l_exists;
--
   hr_utility.set_location(l_proc, 20);
--
   IF csr_soft_coding_keyflex_id%notfound THEN
     CLOSE csr_soft_coding_keyflex_id;
     hr_utility.set_message(800, 'HR_52754_INV_SCL_ID');
     hr_utility.raise_error;
   ELSE
     CLOSE csr_soft_coding_keyflex_id;
   END IF;
  END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_soft_coding_kf;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cost_alloc_kf >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that cost_allocation_keyflex_id of organization unit is present in
--    PAY_COST_ALLOCATION_KEYFLEX table when not null.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_id
--    p_cost_allocation_keyflex_id
--
--  Post Success:
--    If the cost_allocation_keyflex_id attribute is present then
--    normal processing continues
--
--  Post Failure:
--    If the cost_allocation_keyflex_id attribute is not present then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_cost_alloc_kf
  (p_organization_id            IN NUMBER,
   p_business_group_id          IN NUMBER,
   p_cost_allocation_keyflex_id IN hr_all_organization_units.cost_allocation_keyflex_id%TYPE)
IS
--
l_count                         NUMBER;
l_proc                          VARCHAR2(72)  :=  g_package||'chk_cost_alloc_kf';
l_exists                        VARCHAR2(1) := 'N';
--
CURSOR csr_cost_allocation_keyflex_id IS
       SELECT 'Y'
         FROM pay_cost_allocation_keyflex pcak,
              per_business_groups_perf pbg
        WHERE pcak.cost_allocation_keyflex_id = p_cost_allocation_keyflex_id
          AND pbg.business_group_id = p_business_group_id
          AND pbg.cost_allocation_structure = to_char(pcak.id_flex_num);
--
BEGIN
--
hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check cost_allocation_keyflex_id uniqueness
--
IF p_cost_allocation_keyflex_id IS NOT NULL THEN
   --
   -- The following validation needs to be performed only for the INSERT
   -- operation or the value has actually changed during an UPDATE operation
   --
   IF p_organization_id IS NULL OR
      p_cost_allocation_keyflex_id <>
      NVL(hr_oru_shd.g_old_rec.cost_allocation_keyflex_id, hr_api.g_number) THEN
      --
      OPEN csr_cost_allocation_keyflex_id;
      FETCH csr_cost_allocation_keyflex_id INTO l_exists;
      --
      hr_utility.set_location(l_proc, 20);
      --
      IF csr_cost_allocation_keyflex_id%notfound THEN
         --
         CLOSE csr_cost_allocation_keyflex_id;
         hr_utility.set_location(l_proc, 21);
         hr_utility.set_message(800, 'HR_52755_INV_COST_ID');
         hr_utility.raise_error;
         --
      ELSE
         --
         CLOSE csr_cost_allocation_keyflex_id;
         --
      END IF;
      --
   END IF;
   --
   -- Following validation should be performed only during UPDATE
   -- operation
   --
   IF p_organization_id IS NOT NULL THEN
      --
      SELECT COUNT(*)
             INTO l_count
             FROM hr_organization_information
            WHERE organization_id = p_organization_id
              AND org_information_context = 'CLASS'
              AND org_information1 = 'HR_ORG'
              AND org_information2 = 'Y';
      --
      IF l_count = 0 THEN
         --
         hr_utility.set_location(l_proc, 22);
         hr_utility.set_message(800, 'HR_289484_INV_ORG_COST_ID');
         hr_utility.raise_error;
         --
      END IF;
      --
   END IF;
   --
END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_cost_alloc_kf;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_location_id >------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that location_id of organization unit is present in
--    HR_LOCATIONS_ALL table and valid when not null.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_location_id
--
--  Post Success:
--    If the location_id attribute is present and valid then
--    normal processing continues
--
--  Post Failure:
--    If the location_id attribute is present and invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_location_id
  ( p_location_id  IN hr_all_organization_units.location_id%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_location_id';
   l_exists         VARCHAR2(1) := 'N';
--
   cursor csr_location_id IS
     SELECT 'Y'
        FROM hr_locations_all
        WHERE location_id = p_location_id;
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check location_id uniqueness
--
  IF p_location_id IS NOT null THEN
   OPEN csr_location_id;
   FETCH csr_location_id INTO l_exists;
--
   hr_utility.set_location(l_proc, 20);
--
   IF csr_location_id%notfound THEN
     CLOSE csr_location_id;
     hr_utility.set_message(800, 'HR_52756_INV_LOC_ID');
     hr_utility.raise_error;
   ELSE
     CLOSE csr_location_id;
   END IF;
  END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_location_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_type >-------------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that type of organization unit is present in
--    HR_LOKUPS table and valid when not null.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_type
--    p_effective_date
--
--  Post Success:
--    If the type attribute is present and valid then
--    normal processing continues
--
--  Post Failure:
--    If the type attribute is present and invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_type
  ( p_type  IN hr_all_organization_units.type%TYPE,
    p_effective_date          IN     DATE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_type';
   l_exists         VARCHAR2(1) := 'N';
--
   cursor csr_type IS
     SELECT 'Y'
        FROM hr_lookups
        WHERE lookup_type = 'ORG_TYPE'
          AND lookup_code = p_type
          AND enabled_flag = 'Y'
          AND p_effective_date BETWEEN nvl(start_date_active,p_effective_date)
          AND nvl(end_date_active,p_effective_date);
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check location_id uniqueness
--
  IF p_type IS NOT null THEN
   OPEN csr_type;
   FETCH csr_type INTO l_exists;
--
   hr_utility.set_location(l_proc, 20);
--
   IF csr_type%notfound THEN
     CLOSE csr_type;
     hr_utility.set_message(800, 'HR_52752_INV_ORG_TYPE');
     hr_utility.raise_error;
   ELSE
     CLOSE csr_type;
   END IF;
  END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_type;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_int_ext_flag >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that internal_external_flag of organization unit is present in
--    HR_LOKUPS table and valid when not null.
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_internal_external_flag
--    p_effective_date
--
--  Post Success:
--    If the internal_external_flag attribute is present and valid then
--    normal processing continues
--
--  Post Failure:
--    If the internal_external_flag attribute is present and invalid then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_int_ext_flag
  ( p_internal_external_flag  IN hr_all_organization_units.internal_external_flag%TYPE,
    p_effective_date          IN     DATE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_int_ext_flag';
   l_exists         VARCHAR2(1) := 'N';
--
   cursor csr_internal_external_flag IS
     SELECT 'Y'
        FROM hr_lookups
        WHERE lookup_type = 'INTL_EXTL'
          AND lookup_code = p_internal_external_flag
          AND enabled_flag = 'Y'
          AND p_effective_date BETWEEN nvl(start_date_active,p_effective_date)
          AND nvl(end_date_active,p_effective_date);
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Bug 4319315
  if (hr_oru_shd.g_old_rec.internal_external_flag is not null
     and
 (nvl(p_internal_external_flag,hr_oru_shd.g_old_rec.internal_external_flag)
	       <>hr_oru_shd.g_old_rec.internal_external_flag)) then
     fnd_message.set_name('PER','PER_449606_INVALID_UPD_ORG');
     fnd_message.raise_error;

 end if;

-- End of Bug 4319315
-- Check location_id uniqueness
--
  IF p_internal_external_flag IS NOT null THEN
   OPEN csr_internal_external_flag;
   FETCH csr_internal_external_flag INTO l_exists;
--
   hr_utility.set_location(l_proc, 20);
--
   IF csr_internal_external_flag%notfound THEN
     CLOSE csr_internal_external_flag;
     hr_utility.set_message(800, 'HR_52753_INV_ORG_INT_EXT_FLAG');
     hr_utility.raise_error;
   ELSE
     CLOSE csr_internal_external_flag;
   END IF;
  END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_int_ext_flag;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_cls_exists >-------------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that organization unit has at least one classification
--
--  Pre-conditions:
--    None.
--
--  In Arguments:
--    p_organization_id
--
--  Post Success:
--    If classification is not present then
--    normal processing continues
--
--  Post Failure:
--    If classification is already present then an application
--    error will be raised and processing is terminated.
--
--  Developer/Implementation Notes:
--    Duplicate validation exists on form, so any changes made here
--    or on form must be dual-maintained.
--
--  Access Status:
--    Internal Row Table Handler Use Only.
--
-- {End Of Comments}
--
PROCEDURE chk_org_delete
  ( p_organization_id  IN hr_all_organization_units.organization_id%TYPE)
IS
   l_proc           VARCHAR2(72)  :=  g_package||'chk_cls_exists';
   l_exists         VARCHAR2(1) := 'N';
--
BEGIN
--
   hr_utility.set_location('Entering:'|| l_proc, 10);
--
--
-- Check classification presence
--
-- Added 'AND org_infformation2 = 'Y' for WWBUG 2293725
--
  BEGIN
   SELECT 'Y'
   INTO l_exists
   FROM sys.dual
   WHERE EXISTS
     (SELECT null
      FROM hr_organization_information
      WHERE organization_id = p_organization_id
        AND org_information_context = 'CLASS'
        AND org_information2 = 'Y'
    );
   EXCEPTION
   WHEN NO_DATA_FOUND THEN null;
  END;
--
   hr_utility.set_location(l_proc, 20);
--
   IF l_exists = 'Y' THEN
     hr_utility.set_message(800, 'HR_52758_ORG_HAS_CLSF');
     hr_utility.raise_error;
   END IF;
--
--
  hr_utility.set_location('Leaving:'||l_proc, 30);
--
END chk_org_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hr_oru_shd.g_rec_type
  ,p_duplicate_org_warning        out nocopy boolean
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
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --
  -- Validate name
  -- =================
  --
  chk_name
    (p_name                     =>    p_rec.name,
     p_effective_date           =>    p_effective_date,
     p_business_group_id        =>    p_rec.business_group_id,
     p_duplicate_org_warning    =>    p_duplicate_org_warning
     );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate date_from
  -- ======================
--  chk_date_from
--    (p_date_from                  =>    p_rec.date_from,
--     p_effective_date             =>    p_effective_date,
--     p_business_group_id          =>    p_rec.business_group_id
--    );
  --
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate soft_coding_keyflex_id
  -- =======================
  chk_soft_coding_kf
    (p_soft_coding_keyflex_id     =>    p_rec.soft_coding_keyflex_id);
  --
  hr_utility.set_location(l_proc, 40);
  -- Validate cost_allocation_keyflex_id
  -- =======================
  chk_cost_alloc_kf
    (p_organization_id            =>    p_rec.organization_id,
     p_business_group_id          =>    p_rec.business_group_id,
     p_cost_allocation_keyflex_id =>    p_rec.cost_allocation_keyflex_id);
  --
  hr_utility.set_location(l_proc, 50);
  -- Validate location_id
  -- =======================
  chk_location_id
    (p_location_id                =>    p_rec.location_id);
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate type
  -- ======================
  chk_type
    (p_type                       =>    p_rec.type,
     p_effective_date             =>    p_effective_date);
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Validate type
  -- ======================
  chk_int_ext_flag
    (p_internal_external_flag     =>    p_rec.internal_external_flag,
     p_effective_date             =>    p_effective_date);
  --
  hr_utility.set_location(l_proc, 80);
  --
  --
  hr_oru_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hr_oru_shd.g_rec_type
  ,p_duplicate_org_warning        out nocopy boolean
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
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate date_from
  -- ======================
--  chk_date_from
--    (p_date_from                  =>    p_rec.date_from,
--     p_effective_date             =>    p_effective_date,
--     p_business_group_id          =>    p_rec.business_group_id
--    );
  --
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Validate soft_coding_keyflex_id
  -- =======================
  chk_soft_coding_kf
    (p_soft_coding_keyflex_id     =>    p_rec.soft_coding_keyflex_id);
  --
  hr_utility.set_location(l_proc, 40);
  -- Validate cost_allocation_keyflex_id
  -- =======================
  chk_cost_alloc_kf
    (p_organization_id            =>    p_rec.organization_id,
     p_business_group_id          =>    p_rec.business_group_id,
     p_cost_allocation_keyflex_id =>    p_rec.cost_allocation_keyflex_id);
  --
  hr_utility.set_location(l_proc, 50);
  -- Validate location_id
  -- =======================
  chk_location_id
    (p_location_id                =>    p_rec.location_id);
  --
  chk_name
        (p_name                   =>    p_rec.name
         ,p_effective_date        =>    p_effective_date
         ,p_business_group_id     =>    p_rec.business_group_id
         ,p_organization_id       =>    p_rec.organization_id
         ,p_duplicate_org_warning =>    p_duplicate_org_warning );
  hr_utility.set_location(l_proc, 60);
  --
  -- Validate type
  -- ======================
  chk_type
    (p_type                       =>    p_rec.type,
     p_effective_date             =>    p_effective_date);
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Validate type
  -- ======================
  chk_int_ext_flag
    (p_internal_external_flag     =>    p_rec.internal_external_flag,
     p_effective_date             =>    p_effective_date);
  --
  hr_utility.set_location(l_proc, 80);
  --
  --
  hr_oru_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_oru_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
  -- Start of fix for bug 2881808
  l_bg_id    hr_all_organization_units.business_group_id%Type;
  l_installed boolean;
  l_pa_installed varchar2(1);
  l_inv_installed varchar2(1);
  l_eng_installed varchar2(1);
  l_ota_installed varchar2(1);
  l_industry  varchar2(1);
  -- End of fix for bug 2881808
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Get the Business Group id.
  --
  select business_group_id
  into l_bg_id
  from  hr_all_organization_units
  where organization_id = p_rec.organization_id;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Call all supporting business operations
  --
  -- Validate classification exists
  -- =======================
  chk_org_delete
    (p_organization_id     =>    p_rec.organization_id);
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Start of fix for bug 2881808
  --
  -- Validate  Job and Position exists
  -- =================================
    hr_job_pos.hr_jp_predelete(p_rec.organization_id,
                               l_bg_id);
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate Person, Org and Hierarchies exists
  -- ===========================================
    hr_organization.org_predel_check(p_rec.organization_id,
                                     l_bg_id);
  hr_utility.set_location(l_proc, 25);
  --
  -- Product specific validations
  -- ============================

  --          Project Accounting PA
            l_installed := fnd_installation.get(appl_id => 275
                                               ,dep_appl_id => 275
                                               ,status => l_pa_installed
                                               ,industry => l_industry);
            if l_pa_installed <> 'N' then
                 pa_org.pa_predel_validation(p_rec.organization_id);
                 null;
            end if;
            pa_org.pa_org_predel_validation(p_rec.organization_id);
            hr_utility.set_location(l_proc, 30);
       --
--          Inventory INV
            l_installed := fnd_installation.get(appl_id => 401
                                               ,dep_appl_id => 401
                                               ,status => l_inv_installed
                                               ,industry => l_industry);
            if l_inv_installed <> 'N' then
                  inv_org.inv_predel_validation(p_rec.organization_id);
            end if;
            hr_utility.set_location(l_proc, 35);
       --
  --      Training OTA
            if p_rec.organization_id is not null then
              per_ota_predel_validation.ota_predel_org_validation(p_rec.organization_id);
            else null;
            end if;
       hr_utility.set_location(l_proc, 40);
       --
--          Engineering Eng
            l_installed := fnd_installation.get(appl_id => 703
                                               ,dep_appl_id => 703
                                               ,status => l_eng_installed
                                               ,industry => l_industry);
            if l_eng_installed <> 'N' then
               null;
               eng_org.eng_predel_validation(p_rec.organization_id);
            end if;
  --  End of fix for bug 2881808
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_oru_bus;

/
