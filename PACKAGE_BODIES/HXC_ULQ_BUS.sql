--------------------------------------------------------
--  DDL for Package Body HXC_ULQ_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ULQ_BUS" as
/* $Header: hxculqrhi.pkb 120.2 2005/09/23 06:26:40 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ulq_bus.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_qualifier_name >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_qualifier_name
   (p_layout_comp_qualifier_id   IN NUMBER    DEFAULT NULL
   ,p_qualifier_name             IN VARCHAR2
   )
IS
--
CURSOR csr_chk_qualifier_name_unique IS
SELECT 1
  FROM hxc_layout_comp_qualifiers
 WHERE qualifier_name = p_qualifier_name
   AND (p_layout_comp_qualifier_id IS NULL
        OR layout_comp_qualifier_id <> p_layout_comp_qualifier_id);
--
l_result  NUMBER;
--
BEGIN
   --
   OPEN csr_chk_qualifier_name_unique;
   --
   FETCH csr_chk_qualifier_name_unique INTO l_result;
   --
   IF csr_chk_qualifier_name_unique%FOUND THEN
      CLOSE csr_chk_qualifier_name_unique;
      fnd_message.set_name('HXC', 'HXC_xxxxx_QUALIFIER_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
   END IF;
   --
   CLOSE csr_chk_qualifier_name_unique;
   --
END chk_qualifier_name;
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
  (p_rec in hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) ;
--
begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package || 'chk_df';
  	hr_utility.set_location('Entering:'||l_proc,10);
  end if;
  --
  if ((p_rec.layout_comp_qualifier_id is not null)  and (
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute_category, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute1, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute2, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute3, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute4, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute5, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute6, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute7, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute8, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute9, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute10, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute11, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute12, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute13, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute14, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute15, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute16, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute17, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute18, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute19, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute20, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute21, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute22, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute23, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute24, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute25, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute26, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute27, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute28, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute29, hr_api.g_varchar2)  or
    nvl(hxc_ulq_shd.g_old_rec.qualifier_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.qualifier_attribute30, hr_api.g_varchar2) ))
    or (p_rec.layout_comp_qualifier_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'HXC'
      ,p_descflex_name                   => 'HXC_CONFIGURABLE_UI_COMP_INFO'
      ,p_attribute_category              => p_rec.qualifier_attribute_category
      ,p_attribute1_name                 => 'QUALIFIER_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.qualifier_attribute1
      ,p_attribute2_name                 => 'QUALIFIER_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.qualifier_attribute2
      ,p_attribute3_name                 => 'QUALIFIER_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.qualifier_attribute3
      ,p_attribute4_name                 => 'QUALIFIER_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.qualifier_attribute4
      ,p_attribute5_name                 => 'QUALIFIER_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.qualifier_attribute5
      ,p_attribute6_name                 => 'QUALIFIER_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.qualifier_attribute6
      ,p_attribute7_name                 => 'QUALIFIER_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.qualifier_attribute7
      ,p_attribute8_name                 => 'QUALIFIER_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.qualifier_attribute8
      ,p_attribute9_name                 => 'QUALIFIER_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.qualifier_attribute9
      ,p_attribute10_name                => 'QUALIFIER_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.qualifier_attribute10
      ,p_attribute11_name                => 'QUALIFIER_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.qualifier_attribute11
      ,p_attribute12_name                => 'QUALIFIER_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.qualifier_attribute12
      ,p_attribute13_name                => 'QUALIFIER_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.qualifier_attribute13
      ,p_attribute14_name                => 'QUALIFIER_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.qualifier_attribute14
      ,p_attribute15_name                => 'QUALIFIER_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.qualifier_attribute15
      ,p_attribute16_name                => 'QUALIFIER_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.qualifier_attribute16
      ,p_attribute17_name                => 'QUALIFIER_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.qualifier_attribute17
      ,p_attribute18_name                => 'QUALIFIER_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.qualifier_attribute18
      ,p_attribute19_name                => 'QUALIFIER_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.qualifier_attribute19
      ,p_attribute20_name                => 'QUALIFIER_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.qualifier_attribute20
      ,p_attribute21_name                => 'QUALIFIER_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.qualifier_attribute21
      ,p_attribute22_name                => 'QUALIFIER_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.qualifier_attribute22
      ,p_attribute23_name                => 'QUALIFIER_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.qualifier_attribute23
      ,p_attribute24_name                => 'QUALIFIER_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.qualifier_attribute24
      ,p_attribute25_name                => 'QUALIFIER_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.qualifier_attribute25
      ,p_attribute26_name                => 'QUALIFIER_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.qualifier_attribute26
      ,p_attribute27_name                => 'QUALIFIER_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.qualifier_attribute27
      ,p_attribute28_name                => 'QUALIFIER_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.qualifier_attribute28
      ,p_attribute29_name                => 'QUALIFIER_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.qualifier_attribute29
      ,p_attribute30_name                => 'QUALIFIER_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.qualifier_attribute30
      );
  end if;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc,20);
  end if;
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
  (p_rec in hxc_ulq_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the hxc Schema.
  --
  IF NOT hxc_ulq_shd.api_updating
      (p_layout_comp_qualifier_id             => p_rec.layout_comp_qualifier_id
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
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'insert_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- check that qualifier name is unique
  --
--  chk_qualifier_name
--     (p_qualifier_name => p_rec.qualifier_name
--     );
  --
  hxc_ulq_bus.chk_df(p_rec);
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'update_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  -- check that qualifier name is unique
  --
--  chk_qualifier_name
--     (p_layout_comp_qualifier_id => p_rec.layout_comp_qualifier_id
--     ,p_qualifier_name => p_rec.qualifier_name
--     );
  --
  hxc_ulq_bus.chk_df(p_rec);
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_ulq_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) ;
--
Begin
  g_debug :=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'delete_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_ulq_bus;

/
