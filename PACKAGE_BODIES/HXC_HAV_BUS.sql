--------------------------------------------------------
--  DDL for Package Body HXC_HAV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAV_BUS" as
/* $Header: hxchavrhi.pkb 120.2 2005/09/23 10:41:41 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_hav_bus.';  -- Global package name
g_debug	boolean:=hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_alias_value_id              number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_alias_value_id                       in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_alias_values and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hxc_alias_values hav
      --   , EDIT_HERE table_name(s) 333
     where hav.alias_value_id = p_alias_value_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72);
  --
begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc  :=  g_package||'set_security_group_id';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'alias_value_id'
    ,p_argument_value     => p_alias_value_id
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
  if g_debug then
	hr_utility.set_location(' Leaving:'|| l_proc, 20);
  end if;
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_alias_value_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_alias_values and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , hxc_alias_values hav
      --   , EDIT_HERE table_name(s) 333
     where hav.alias_value_id = p_alias_value_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72);
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc  :=  g_package||'return_legislation_code';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'alias_value_id'
    ,p_argument_value     => p_alias_value_id
    );
  --
  if ( nvl(hxc_hav_bus.g_alias_value_id, hr_api.g_number)
       = p_alias_value_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_hav_bus.g_legislation_code;
    if g_debug then
	hr_utility.set_location(l_proc, 20);
    end if;
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
    if g_debug then
	hr_utility.set_location(l_proc,30);
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    hxc_hav_bus.g_alias_value_id    := p_alias_value_id;
    hxc_hav_bus.g_legislation_code  := l_legislation_code;
  end if;
  if g_debug then
	hr_utility.set_location(' Leaving:'|| l_proc, 40);
  end if;
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
  (p_rec in hxc_hav_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72);
--
begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package || 'chk_df';
	hr_utility.set_location('Entering:'||l_proc,10);
  end if;
  --
  if ((p_rec.alias_value_id is not null)  and (
    nvl(hxc_hav_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(hxc_hav_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.alias_value_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'HXC'
      ,p_descflex_name                   => 'OTC Aliases'
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
  (p_rec in hxc_hav_shd.g_rec_type
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
  IF NOT hxc_hav_shd.api_updating
      (p_alias_value_id                       => p_rec.alias_value_id
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
-- |-----------------------< chk_name >---------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid alias value name
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_name
--   p_ovn         - object_version_number
--   p_date_from
--   p_date_to
--   p_alias_definition_id
--
-- Post Success:
--   Processing continues if the name business rules have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_name       	    in hxc_alias_values.alias_value_name%TYPE
  ,p_ovn        	    in hxc_alias_values.object_version_number%TYPE
  ,p_date_from  	    in hxc_alias_values.date_from%TYPE
  ,p_date_to    	    in hxc_alias_values.date_to%TYPE
  ,p_alias_definition_id    in hxc_alias_values.alias_definition_id%TYPE
  ,p_alias_value_id         in hxc_alias_values.alias_definition_id%TYPE DEFAULT NULL
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check alias value name does not overlap
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM    hxc_alias_values_tl havt,
	hxc_alias_values hav
WHERE   havt.alias_value_id = hav.alias_value_id
AND	havt.alias_value_name = p_name
AND     hav.object_version_number <> NVL(p_ovn, -1)
AND     hav.alias_definition_id = p_alias_definition_id
and     havt.language = USERENV('LANG')
AND     hav.alias_value_id 	<> nvl(p_alias_value_id,9.99E125)
AND     ((p_date_from BETWEEN hav.date_from
                      AND NVL(hav.date_to, HR_GENERAL.END_OF_TIME))
        OR
         (NVL(p_date_to, HR_GENERAL.END_OF_TIME) BETWEEN
          hav.date_from AND NVL(hav.date_to, HR_GENERAL.END_OF_TIME))
        OR
        (hav.date_from BETWEEN p_date_from
		       AND NVL(p_date_to, HR_GENERAL.END_OF_TIME))
        OR
        (NVL(hav.date_to, HR_GENERAL.END_OF_TIME) BETWEEN
         p_date_from AND NVL(p_date_to, HR_GENERAL.END_OF_TIME)));
--
 l_dup_name varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_name';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the name has been entered
--
IF p_name IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_ALIAS_NAME_VALUE_MAND');
      hr_utility.raise_error;
--
END IF;
--
IF p_date_from IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0056_DAR_START_DATE_MAND');
      hr_utility.raise_error;
--
END IF;
--
IF p_date_to is not null AND p_date_from > p_date_to THEN
    hr_utility.set_message(809,'HXC_0059_DAR_TO_LESS_THAN_FROM');
    hr_utility.raise_error;
END IF;
--
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that the name is unique
--
/*
fnd_log.string(1
           ,'hxc_hav_shd.chk_duplicate_values'
           ,'p_ovn '||p_ovn||
  	   ' p_date_from '||p_date_from ||
           ' p_date_to '||p_date_to ||
           ' p_alias_definition_id '||p_alias_definition_id||
           ' p_alias_value_id '||p_alias_value_id||
           ' p_name '||p_name);
*/
OPEN  csr_chk_name;
FETCH csr_chk_name INTO l_dup_name;
CLOSE csr_chk_name;
--
IF l_dup_name IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_ALIAS_NAME_VALUE_UNIQUE');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_duplicate_values >---------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid alias values.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_name
--   p_ovn         - object_version_number
--   p_date_from
--   p_date_to
--   p_alias_definition_id
--
-- Post Success:
--   Processing continues if the name business rules have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_duplicate_values
  (
   p_attribute_category	    in hxc_alias_values.attribute_category%TYPE
  ,p_attribute1        	    in hxc_alias_values.attribute1%TYPE DEFAULT NULL
  ,p_attribute2        	    in hxc_alias_values.attribute2%TYPE DEFAULT NULL
  ,p_attribute3        	    in hxc_alias_values.attribute3%TYPE DEFAULT NULL
  ,p_attribute4        	    in hxc_alias_values.attribute4%TYPE DEFAULT NULL
  ,p_attribute5        	    in hxc_alias_values.attribute5%TYPE DEFAULT NULL
  ,p_attribute6        	    in hxc_alias_values.attribute6%TYPE DEFAULT NULL
  ,p_attribute7        	    in hxc_alias_values.attribute7%TYPE DEFAULT NULL
  ,p_attribute8        	    in hxc_alias_values.attribute8%TYPE DEFAULT NULL
  ,p_attribute9        	    in hxc_alias_values.attribute9%TYPE DEFAULT NULL
  ,p_attribute10            in hxc_alias_values.attribute10%TYPE DEFAULT NULL
  ,p_attribute11            in hxc_alias_values.attribute11%TYPE DEFAULT NULL
  ,p_attribute12            in hxc_alias_values.attribute12%TYPE DEFAULT NULL
  ,p_attribute13      	    in hxc_alias_values.attribute13%TYPE DEFAULT NULL
  ,p_attribute14            in hxc_alias_values.attribute14%TYPE DEFAULT NULL
  ,p_attribute15            in hxc_alias_values.attribute15%TYPE DEFAULT NULL
  ,p_attribute16            in hxc_alias_values.attribute16%TYPE DEFAULT NULL
  ,p_attribute17            in hxc_alias_values.attribute17%TYPE DEFAULT NULL
  ,p_attribute18            in hxc_alias_values.attribute18%TYPE DEFAULT NULL
  ,p_attribute19            in hxc_alias_values.attribute19%TYPE DEFAULT NULL
  ,p_attribute20            in hxc_alias_values.attribute20%TYPE DEFAULT NULL
  ,p_attribute21            in hxc_alias_values.attribute21%TYPE DEFAULT NULL
  ,p_attribute22            in hxc_alias_values.attribute22%TYPE DEFAULT NULL
  ,p_attribute23            in hxc_alias_values.attribute23%TYPE DEFAULT NULL
  ,p_attribute24            in hxc_alias_values.attribute24%TYPE DEFAULT NULL
  ,p_attribute25            in hxc_alias_values.attribute25%TYPE DEFAULT NULL
  ,p_attribute26            in hxc_alias_values.attribute26%TYPE DEFAULT NULL
  ,p_attribute27            in hxc_alias_values.attribute27%TYPE DEFAULT NULL
  ,p_attribute28            in hxc_alias_values.attribute28%TYPE DEFAULT NULL
  ,p_attribute29            in hxc_alias_values.attribute29%TYPE DEFAULT NULL
  ,p_attribute30            in hxc_alias_values.attribute30%TYPE DEFAULT NULL
  ,p_ovn        	    in hxc_alias_values.object_version_number%TYPE
  ,p_date_from  	    in hxc_alias_values.date_from%TYPE
  ,p_date_to    	    in hxc_alias_values.date_to%TYPE
  ,p_alias_definition_id    in hxc_alias_values.alias_definition_id%TYPE
  ,p_alias_value_id	    in hxc_alias_values.alias_value_id%TYPE DEFAULT NULL
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check alias value name does not overlap
--
CURSOR  csr_chk_duplicate IS
SELECT 'error'
FROM    hxc_alias_values hav
WHERE   hav.alias_definition_id = p_alias_definition_id
AND     hav.object_version_number <> NVL(p_ovn, -1)
AND     ((p_date_from BETWEEN hav.date_from
                      AND NVL(hav.date_to, HR_GENERAL.END_OF_TIME))
        OR
         (NVL(p_date_to, HR_GENERAL.END_OF_TIME) BETWEEN
          hav.date_from AND NVL(hav.date_to, HR_GENERAL.END_OF_TIME))
        OR
        (hav.date_from BETWEEN p_date_from
		       AND NVL(p_date_to, HR_GENERAL.END_OF_TIME))
        OR
        (NVL(hav.date_to, HR_GENERAL.END_OF_TIME) BETWEEN
         p_date_from AND NVL(p_date_to, HR_GENERAL.END_OF_TIME)))
AND     hav.alias_value_id 		       <> nvl(p_alias_value_id,9.99E125)
AND	hav.attribute_category 		       = p_attribute_category
AND	nvl(hav.attribute1,chr(0))	       = nvl(p_attribute1,chr(0))
AND	nvl(hav.attribute2,chr(0))	       = nvl(p_attribute2,chr(0))
AND	nvl(hav.attribute3,chr(0))	       = nvl(p_attribute3,chr(0))
AND	nvl(hav.attribute4,chr(0))	       = nvl(p_attribute4,chr(0))
AND	nvl(hav.attribute5,chr(0))	       = nvl(p_attribute5,chr(0))
AND	nvl(hav.attribute6,chr(0))	       = nvl(p_attribute6,chr(0))
AND	nvl(hav.attribute7,chr(0))	       = nvl(p_attribute7,chr(0))
AND	nvl(hav.attribute8,chr(0))	       = nvl(p_attribute8,chr(0))
AND	nvl(hav.attribute9,chr(0))	       = nvl(p_attribute9,chr(0))
AND	nvl(hav.attribute10,chr(0))	       = nvl(p_attribute10,chr(0))
AND	nvl(hav.attribute11,chr(0))	       = nvl(p_attribute11,chr(0))
AND	nvl(hav.attribute12,chr(0))	       = nvl(p_attribute12,chr(0))
AND	nvl(hav.attribute13,chr(0))	       = nvl(p_attribute13,chr(0))
AND	nvl(hav.attribute14,chr(0))	       = nvl(p_attribute14,chr(0))
AND	nvl(hav.attribute15,chr(0))	       = nvl(p_attribute15,chr(0))
AND	nvl(hav.attribute16,chr(0))	       = nvl(p_attribute16,chr(0))
AND	nvl(hav.attribute17,chr(0))	       = nvl(p_attribute17,chr(0))
AND	nvl(hav.attribute18,chr(0))	       = nvl(p_attribute18,chr(0))
AND	nvl(hav.attribute19,chr(0))	       = nvl(p_attribute19,chr(0))
AND	nvl(hav.attribute20,chr(0))	       = nvl(p_attribute20,chr(0))
AND	nvl(hav.attribute21,chr(0))	       = nvl(p_attribute21,chr(0))
AND	nvl(hav.attribute22,chr(0))	       = nvl(p_attribute22,chr(0))
AND	nvl(hav.attribute23,chr(0))	       = nvl(p_attribute23,chr(0))
AND	nvl(hav.attribute24,chr(0))	       = nvl(p_attribute24,chr(0))
AND	nvl(hav.attribute25,chr(0))	       = nvl(p_attribute25,chr(0))
AND	nvl(hav.attribute26,chr(0))	       = nvl(p_attribute26,chr(0))
AND	nvl(hav.attribute27,chr(0))	       = nvl(p_attribute27,chr(0))
AND	nvl(hav.attribute28,chr(0))	       = nvl(p_attribute28,chr(0))
AND	nvl(hav.attribute29,chr(0))	       = nvl(p_attribute29,chr(0))
AND	nvl(hav.attribute30,chr(0))	       = nvl(p_attribute30,chr(0));
--
 l_dup_value varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_duplicate_values';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
IF p_date_from IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0056_DAR_START_DATE_MAND');
      hr_utility.raise_error;
--
END IF;
--
IF p_date_to is not null AND p_date_from > p_date_to THEN
    hr_utility.set_message(809,'HXC_0059_DAR_TO_LESS_THAN_FROM');
    hr_utility.raise_error;
END IF;
--
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that the value is unique
--
/*
fnd_log.string(1
           ,'hxc_hav_shd.chk_duplicate_values'
           ,'ATT_CAT:'||p_ATTRIBUTE_CATEGORY||
	    ' ATT1:'||p_ATTRIBUTE1||
	    ' ATT2:'||p_ATTRIBUTE2||
	    ' ATT3:'||p_ATTRIBUTE3||
	    ' ATT4:'||p_ATTRIBUTE4);
fnd_log.string(1
           ,'hxc_hav_shd.chk_duplicate_values'
	   ,' ATT5:'||p_ATTRIBUTE5||
	    ' ATT6:'||p_ATTRIBUTE6||
	    ' ATT7:'||p_ATTRIBUTE7||
	    ' ATT8:'||p_ATTRIBUTE8||
	    ' ATT9:'||p_ATTRIBUTE9||
	    ' ATT10:'||p_ATTRIBUTE10||
	    ' ATT11:'||p_ATTRIBUTE11||
	    ' ATT12:'||p_ATTRIBUTE12||
	    ' ATT13:'||p_ATTRIBUTE13||
	    ' ATT14:'||p_ATTRIBUTE14||
	    ' ATT15:'||p_ATTRIBUTE15||
	    ' ATT16:'||p_ATTRIBUTE16||
	    ' ATT17:'||p_ATTRIBUTE17||
	    ' ATT18:'||p_ATTRIBUTE18||
	    ' ATT19:'||p_ATTRIBUTE19||
	    ' ATT20:'||p_ATTRIBUTE20||
	    ' ATT21:'||p_ATTRIBUTE21||
	    ' ATT22:'||p_ATTRIBUTE22||
	    ' ATT23:'||p_ATTRIBUTE23||
	    ' ATT24:'||p_ATTRIBUTE24||
	    ' ATT25:'||p_ATTRIBUTE25||
	    ' ATT26:'||p_ATTRIBUTE26||
	    ' ATT27:'||p_ATTRIBUTE27||
	    ' ATT28:'||p_ATTRIBUTE28||
	    ' ATT29:'||p_ATTRIBUTE29||
	    ' ATT30:'||p_ATTRIBUTE30);
fnd_log.string(1
           ,'hxc_hav_shd.chk_duplicate_values'
           ,'p_ovn '||p_ovn||
  	   ' p_date_from '||p_date_from ||
           ' p_date_to '||p_date_to ||
           ' p_alias_definition_id '||p_alias_definition_id||
           ' p_alias_value_id '||p_alias_value_id);
*/
  OPEN  csr_chk_duplicate;
  FETCH csr_chk_duplicate INTO l_dup_value;
--
IF csr_chk_duplicate%FOUND
THEN
--
      hr_utility.set_message(809, 'HXC_ALIAS_VALUE_UNIQUE');
      hr_utility.raise_error;
--
END IF;
--
CLOSE csr_chk_duplicate;
--
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_duplicate_values;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_hav_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'insert_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
chk_name (
   p_name                  => p_rec.alias_value_name
  ,p_ovn                   => p_rec.object_version_number
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  ,p_alias_definition_id   => p_rec.alias_definition_id
  ,p_alias_value_id	   => p_rec.alias_value_id
  );

chk_duplicate_values
  (
   p_attribute_category	    => p_rec.attribute_category
  ,p_attribute1        	    => p_rec.attribute1
  ,p_attribute2        	    => p_rec.attribute2
  ,p_attribute3        	    => p_rec.attribute3
  ,p_attribute4        	    => p_rec.attribute4
  ,p_attribute5        	    => p_rec.attribute5
  ,p_attribute6        	    => p_rec.attribute6
  ,p_attribute7        	    => p_rec.attribute7
  ,p_attribute8        	    => p_rec.attribute8
  ,p_attribute9        	    => p_rec.attribute9
  ,p_attribute10            => p_rec.attribute10
  ,p_attribute11            => p_rec.attribute11
  ,p_attribute12            => p_rec.attribute12
  ,p_attribute13      	    => p_rec.attribute13
  ,p_attribute14            => p_rec.attribute14
  ,p_attribute15            => p_rec.attribute15
  ,p_attribute16            => p_rec.attribute16
  ,p_attribute17            => p_rec.attribute17
  ,p_attribute18            => p_rec.attribute18
  ,p_attribute19            => p_rec.attribute19
  ,p_attribute20            => p_rec.attribute20
  ,p_attribute21            => p_rec.attribute21
  ,p_attribute22            => p_rec.attribute22
  ,p_attribute23            => p_rec.attribute23
  ,p_attribute24            => p_rec.attribute24
  ,p_attribute25            => p_rec.attribute25
  ,p_attribute26            => p_rec.attribute26
  ,p_attribute27            => p_rec.attribute27
  ,p_attribute28            => p_rec.attribute28
  ,p_attribute29            => p_rec.attribute29
  ,p_attribute30            => p_rec.attribute30
  ,p_ovn                    => p_rec.object_version_number
  ,p_date_from              => p_rec.date_from
  ,p_date_to                => p_rec.date_to
  ,p_alias_definition_id    => p_rec.alias_definition_id
  ,p_alias_value_id	    => p_rec.alias_value_id
  );
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  --
  hxc_hav_bus.chk_df(p_rec);
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
  (p_rec                          in hxc_hav_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'update_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
chk_non_updateable_args
    (p_rec              => p_rec
    );

chk_name (
   p_name                  => p_rec.alias_value_name
  ,p_ovn                   => p_rec.object_version_number
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  ,p_alias_definition_id   => p_rec.alias_definition_id
  ,p_alias_value_id	   => p_rec.alias_value_id
  );

chk_duplicate_values
  (
   p_attribute_category	    => p_rec.attribute_category
  ,p_attribute1        	    => p_rec.attribute1
  ,p_attribute2        	    => p_rec.attribute2
  ,p_attribute3        	    => p_rec.attribute3
  ,p_attribute4        	    => p_rec.attribute4
  ,p_attribute5        	    => p_rec.attribute5
  ,p_attribute6        	    => p_rec.attribute6
  ,p_attribute7        	    => p_rec.attribute7
  ,p_attribute8        	    => p_rec.attribute8
  ,p_attribute9        	    => p_rec.attribute9
  ,p_attribute10            => p_rec.attribute10
  ,p_attribute11            => p_rec.attribute11
  ,p_attribute12            => p_rec.attribute12
  ,p_attribute13      	    => p_rec.attribute13
  ,p_attribute14            => p_rec.attribute14
  ,p_attribute15            => p_rec.attribute15
  ,p_attribute16            => p_rec.attribute16
  ,p_attribute17            => p_rec.attribute17
  ,p_attribute18            => p_rec.attribute18
  ,p_attribute19            => p_rec.attribute19
  ,p_attribute20            => p_rec.attribute20
  ,p_attribute21            => p_rec.attribute21
  ,p_attribute22            => p_rec.attribute22
  ,p_attribute23            => p_rec.attribute23
  ,p_attribute24            => p_rec.attribute24
  ,p_attribute25            => p_rec.attribute25
  ,p_attribute26            => p_rec.attribute26
  ,p_attribute27            => p_rec.attribute27
  ,p_attribute28            => p_rec.attribute28
  ,p_attribute29            => p_rec.attribute29
  ,p_attribute30            => p_rec.attribute30
  ,p_ovn                    => p_rec.object_version_number
  ,p_date_from              => p_rec.date_from
  ,p_date_to                => p_rec.date_to
  ,p_alias_definition_id    => p_rec.alias_definition_id
  ,p_alias_value_id	    => p_rec.alias_value_id
  );
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
/*  chk_non_updateable_args
    (p_rec              => p_rec
    ); */
  --
  --
  hxc_hav_bus.chk_df(p_rec);
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
  (p_rec                          in hxc_hav_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
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
end hxc_hav_bus;

/
