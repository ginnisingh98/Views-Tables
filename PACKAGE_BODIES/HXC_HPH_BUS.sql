--------------------------------------------------------
--  DDL for Package Body HXC_HPH_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HPH_BUS" as
/* $Header: hxchphrhi.pkb 120.2.12000000.2 2007/03/16 13:22:54 rchennur noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_hph_bus.';  -- Global package name
g_debug	   boolean	:= hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pref_hierarchy_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pref_hierarchy_id                    in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_pref_hierarchies and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hxc_pref_hierarchies hph
      --   , EDIT_HERE table_name(s) 333
     where hph.pref_hierarchy_id = p_pref_hierarchy_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72) ;
  --
begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc :=  g_package||'set_security_group_id';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pref_hierarchy_id'
    ,p_argument_value     => p_pref_hierarchy_id
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
  (p_pref_hierarchy_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_pref_hierarchies and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , hxc_pref_hierarchies hph
      --   , EDIT_HERE table_name(s) 333
     where hph.pref_hierarchy_id = p_pref_hierarchy_id;
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
  end if;--
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pref_hierarchy_id'
    ,p_argument_value     => p_pref_hierarchy_id
    );
  --
  if ( nvl(hxc_hph_bus.g_pref_hierarchy_id, hr_api.g_number)
       = p_pref_hierarchy_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_hph_bus.g_legislation_code;
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
    hxc_hph_bus.g_pref_hierarchy_id := p_pref_hierarchy_id;
    hxc_hph_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hxc_hph_shd.g_rec_type
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
  if ((p_rec.pref_hierarchy_id is not null)  and (
    nvl(hxc_hph_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(hxc_hph_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2)  ))
    or (p_rec.pref_hierarchy_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'HXC'
     -- ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_descflex_name                   => 'OTC PREFERENCES'
     -- ,p_attribute_category              => 'ATTRIBUTE_CATEGORY'
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
  (p_effective_date               in date
  ,p_rec in hxc_hph_shd.g_rec_type
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
  IF NOT hxc_hph_shd.api_updating
      (p_pref_hierarchy_id                    => p_rec.pref_hierarchy_id
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
-- |-----------------------------< chk_name >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure ensures that a valid and a unique Preference Hierarchy name
-- has been entered for a parent.i.e., No two children of a parent can have the
-- same name.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   parent_pref_hierarchy_id
--   object_version_number
--
-- Post Success:
--   Processing continues if a valid and a unique name has been entered for a
--   parent
--
-- Post Failure:
--   An application error is raised if the child name is not unique
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
p_name in hxc_pref_hierarchies.name%TYPE,
p_business_group_id in hxc_pref_hierarchies.business_group_id%TYPE,
p_parent_pref_hierarchy_id in hxc_pref_hierarchies.parent_pref_hierarchy_id%TYPE
,
p_object_version_number in hxc_pref_hierarchies.object_version_number%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check that a duplicate child pref hierarchy name is not entered
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM    sys.dual
WHERE EXISTS (
       SELECT  'x'
       FROM    hxc_pref_hierarchies hph
       WHERE   upper(hph.name) = upper(p_name)
       AND     hph.object_version_number <> NVL(p_object_version_number, -1)
       AND     (business_group_id = p_business_group_id or business_group_id is null)
       AND     level = 1
       START WITH hph.parent_pref_hierarchy_id = p_parent_pref_hierarchy_id
       CONNECT BY PRIOR hph.pref_hierarchy_id = hph.parent_pref_hierarchy_id);
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_name';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- Raise error if name is NULL as it is a mandatory field.
--
IF p_name IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0077_HPH_PREF_NAME_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- Raise an error if the child preference hierarchy name is not unique
--
  OPEN  csr_chk_name;
  FETCH csr_chk_name INTO l_error;
  CLOSE csr_chk_name;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0078_HPH_DUP_PREF_NAME');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_name;


PROCEDURE chk_rules_evaluation_pref (
          p_pref_code   VARCHAR2
        , p_attribute1  VARCHAR2
        , p_attribute2  VARCHAR2 ) IS

BEGIN

IF ( p_pref_code = 'TC_W_RULES_EVALUATION' )
THEN

	IF ( p_attribute1 = 'Y' )
	THEN
		IF ( p_attribute2 IS NULL )
		THEN
		      hr_utility.set_message(809, 'HXC_HPH_RULES_EVALUATION');
		      hr_utility.raise_error;
		END IF;
	END IF;

END IF;

END chk_rules_evaluation_pref;

PROCEDURE chk_days_hours_factor (
          p_pref_code   VARCHAR2
        , p_attribute1  VARCHAR2
        , p_attribute2  VARCHAR2 ) IS
BEGIN
IF ( p_pref_code = 'TS_PER_DAYS_TO_HOURS' )
THEN
        IF ( p_attribute1 is not null ) and (p_attribute2 is null)
        THEN
                      hr_utility.set_message(809, 'HXC_DAYS_HOURS');
                      hr_utility.raise_error;
        END IF;
END IF;
END chk_days_hours_factor;


PROCEDURE chk_tk_person_name_number (
          p_pref_code   VARCHAR2
        , p_attribute2  VARCHAR2
        , p_attribute3  VARCHAR2 ) IS
BEGIN
IF ( p_pref_code = 'TK_TCARD_SETUP' )
THEN
        IF ( p_attribute2 = 'N' ) and (p_attribute3 = 'N')
        THEN
                      hr_utility.set_message(809, 'HXC_TK_PERSON_NAME_NUMBER');
                      hr_utility.raise_error;
        END IF;
END IF;
END chk_tk_person_name_number;

PROCEDURE chk_tk_audit_segments (
          p_pref_code   VARCHAR2
        , p_attribute1  VARCHAR2
        , p_attribute2  VARCHAR2
        , p_attribute3  VARCHAR2
        , p_attribute4 VARCHAR2 ) IS
BEGIN
IF ( p_pref_code = 'TK_TCARD_CLA' )
THEN
        IF ( p_attribute1 = 'Y' )
       and ( p_attribute2 is Null or
             p_attribute3 is Null or
	     (p_attribute4 is Null and p_attribute3 <>'NONE'))
        THEN
                      hr_utility.set_message(809, 'HXC_TK_AUDIT_SEG_REQ');
                      hr_utility.raise_error;
        END IF;
END IF;
END chk_tk_audit_segments;

--
-- -----------------------------------------------------------------------------------
-- |-----------------------------< get_top_level_id >---------------------------------|
-- -----------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This function return the top level id of a particular none in the hierarchy
--
function get_top_level_id(p_pref_id in number)
 return number is

--Performance Fix
/*cursor csr_top  (p_preference_id number) is
select parent_pref_hierarchy_id
from hxc_pref_hierarchies hph
where pref_hierarchy_id = p_preference_id;*/

cursor csr_top (p_preference_id number) is
select top_level_parent_id                 --Performance Fix
from hxc_pref_hierarchies hph
where pref_hierarchy_id = p_preference_id;

l_parent_id  number;
l_temp_parent_id  number;

Begin

l_parent_id := null;

  OPEN  csr_top (p_pref_id) ;
  FETCH csr_top INTO l_parent_id;
  CLOSE csr_top;

  if l_parent_id is null then
     l_parent_id := p_pref_id;
  end if;

--Performance Fix
/*  l_temp_parent_id := l_parent_id;

  WHILE l_temp_parent_id is not null LOOP
   OPEN  csr_top (l_temp_parent_id) ;
   FETCH csr_top INTO l_temp_parent_id;
   CLOSE csr_top;
   if l_temp_parent_id is not null then
     l_parent_id := l_temp_parent_id;
   end if;
  END LOOP;*/

return l_parent_id;

end;
--
-- -------------------------------------------------------------------------------------
-- |-----------------------------< get_top_level_name >---------------------------------|
-- ------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This function return the top level id of a particular none in the hierarchy
--
function get_top_level_name(p_pref_id in number)
 return varchar2 is

--Performance Fix
/*cursor csr_top  (p_preference_id number) is
select parent_pref_hierarchy_id ,name
from hxc_pref_hierarchies hph
where pref_hierarchy_id = p_preference_id;*/

cursor csr_top (p_preference_id number) is
select hph.name
from hxc_pref_hierarchies hph
    ,hxc_pref_hierarchies hph1
where hph.pref_hierarchy_id = hph1.top_level_parent_id  --Performance Fix
  and hph1.pref_hierarchy_id = p_preference_id;

l_parent_id  number;
l_parent_name varchar2(80);

l_temp_parent_id  number;
l_temp_parent_name varchar2(80);

Begin

l_parent_id := null;
l_parent_name := null;

  OPEN  csr_top (p_pref_id) ;
  FETCH csr_top INTO l_parent_name;
  CLOSE csr_top;

--Performance Fix
/*  l_temp_parent_id := l_parent_id;

  WHILE l_temp_parent_id is not null LOOP
   OPEN  csr_top (l_temp_parent_id) ;
   FETCH csr_top INTO l_temp_parent_id,l_temp_parent_name;
   CLOSE csr_top;
   if l_temp_parent_id is not null then
     l_parent_id := l_temp_parent_id;
     l_parent_name := l_temp_parent_name;
   end if;
  END LOOP;*/

return l_parent_name;

end;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_pref_code >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure ensures that a valid and a unique Preference Hierarchy code
-- has been entered for a parent.i.e., No two children from the top levelparent
-- can have the same pref code.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   parent_pref_hierarchy_id
--   object_version_number
--
-- Post Success:
--   Processing continues if a valid and a unique name has been entered for a
--   parent
--
-- Post Failure:
--   An application error is raised if the child name is not unique
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_pref_code
  (
p_pref_code in hxc_pref_hierarchies.attribute_category%TYPE,
p_parent_pref_hierarchy_id in hxc_pref_hierarchies.parent_pref_hierarchy_id%TYPE,
p_pref_hierarchy_id in hxc_pref_hierarchies.pref_hierarchy_id%TYPE,
p_object_version_number in hxc_pref_hierarchies.object_version_number%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check that a duplicate child pref hierarchy name is not entered
--

CURSOR  csr_chk_code IS
SELECT 'error'
FROM    sys.dual
WHERE EXISTS (
       SELECT  'x'
       FROM    hxc_pref_hierarchies hph
       WHERE   hph.attribute_category = p_pref_code
       and     hph.pref_hierarchy_id <> p_pref_hierarchy_id
       START WITH hph.parent_pref_hierarchy_id = hxc_hph_bus.get_top_level_id(p_parent_pref_hierarchy_id)
       CONNECT BY PRIOR hph.pref_hierarchy_id = hph.parent_pref_hierarchy_id);

CURSOR  csr_chk_code2 IS
SELECT 'error'
FROM    sys.dual
WHERE EXISTS (
       SELECT  'x'
       FROM    hxc_pref_hierarchies hph
       WHERE   hph.attribute_category is not null
       and     hph.pref_hierarchy_id = p_parent_pref_hierarchy_id);

--
 l_error varchar2(5) := NULL;
 l_error2 varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_code';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- Raise error if name is NULL as it is a mandatory field.
--
IF p_pref_code IS NOT NULL THEN
--
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- Raise an error if the child preference hierarchy name is not unique
--
  OPEN  csr_chk_code;
  FETCH csr_chk_code INTO l_error;
  CLOSE csr_chk_code;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_HPH_DUP_PREF_CODE');
      hr_utility.raise_error;
--
END IF;
--
END IF;
--
  OPEN  csr_chk_code2;
  FETCH csr_chk_code2 INTO l_error2;
  CLOSE csr_chk_code2;
--
IF l_error2 IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_HPH_NOT_PREF_PARENT');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--

END chk_pref_code;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_top_node >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure ensures that a valid and a unique Top Node Preference name
-- has been entered
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   object_version_number
--
-- Post Success:
--   Processing continues if a valid and a unique top node name has been
--   entered
--
-- Post Failure:
--   An application error is raised if the top node name is not unique
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_top_node
  (
p_name in hxc_pref_hierarchies.name%TYPE,
p_business_group_id in hxc_pref_hierarchies.business_group_id%TYPE,
p_object_version_number in hxc_pref_hierarchies.object_version_number%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check that a duplicate top node name is not entered
--
CURSOR  csr_chk_top_node IS
SELECT 'error'
FROM    sys.dual
WHERE EXISTS (
       SELECT  'x'
       FROM    hxc_pref_hierarchies hph
       WHERE   hph.name = p_name
       AND     (business_group_id = p_business_group_id or business_group_id is null)
       AND     hph.object_version_number <> NVL(p_object_version_number, -1)
       AND     hph.parent_pref_hierarchy_id is null);
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_top_node';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- Raise an error if the top node preference name is not unique
--
  OPEN  csr_chk_top_node;
  FETCH csr_chk_top_node INTO l_error;
  CLOSE csr_chk_top_node;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0149_HPH_TOP_NODE_EXIST');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 5);
  end if;
--
END chk_top_node;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_preference >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure ensures that a single Hierarchy should not contain the same
-- preference twice (Preference Definition)
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   pref_definition_id
--   parent_pref_hierarchy_id
--   object_version_number
--
-- Post Success:
--   Processing continues if a valid and a unique preference has been entered
--   for the hierarchy
--
-- Post Failure:
--   An application error is raised if a unique preference is not entered for
--   that hierarchy
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_preference
  (
p_pref_definition_id in hxc_pref_hierarchies.pref_definition_id%TYPE,
p_bg_id NUMBER,
p_parent_pref_hierarchy_id in hxc_pref_hierarchies.parent_pref_hierarchy_id%TYPE
,
p_object_version_number in hxc_pref_hierarchies.object_version_number%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check that a preference definition is not entered twice for a
-- single hierarchy
--
CURSOR  csr_chk_preference IS
SELECT 'error'
FROM    sys.dual
WHERE EXISTS (
       SELECT  'x'
       FROM    hxc_pref_hierarchies hph
       WHERE   hph.pref_definition_id  = p_pref_definition_id
       AND     NVL(hph.business_group_id,-1) = NVL(p_bg_id,-1)
       AND     level = 2
       AND     hph.object_version_number <> NVL(p_object_version_number, -1)
       START WITH hph.pref_hierarchy_id = p_parent_pref_hierarchy_id
       CONNECT BY PRIOR hph.pref_hierarchy_id = hph.parent_pref_hierarchy_id);
--
 l_error varchar2(5) := NULL;
--
BEGIN

  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_preference';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- Raise an error if the child preference definition name is not unique
--
  OPEN  csr_chk_preference;
  FETCH csr_chk_preference INTO l_error;
  CLOSE csr_chk_preference;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0147_HPH_DUP_PREF_DEF');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_preference;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_mapping_components >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure returns the mapping component id of mapping components of a
-- particular alternate name type
--
--
-- In Arguments:
--   p_alias_type_id
--
-- InOut Arguments:
--   p_mapping_id_table
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure get_mapping_components(p_alias_type_id in number,
				 p_mapping_id_table in out nocopy hxc_hph_shd.alias_mapping_table) is
    cursor c_get_mapping_components (p_alias_type_id number) is
           select mapping_component_id
	     from hxc_alias_type_components hac
	    where hac.alias_type_id = p_alias_type_id;
    ind number;
begin
g_debug:=hr_utility.debug_enabled;
if g_debug then
	hr_utility.trace('Mappings are');
end if;
    open c_get_mapping_components(p_alias_type_id);
    loop
       fetch c_get_mapping_components into ind;
         exit  when c_get_mapping_components%notfound;
       p_mapping_id_table(ind).mapping_id := ind;
       if g_debug then
	hr_utility.trace('Mapping Id '|| ind);
       end if;
    end loop;
    close c_get_mapping_components;
end get_mapping_components;
-- ----------------------------------------------------------------------------
-- |---------------------------< VALIDATE_ALIAS_DEFINITIONS >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Checks if the alternate names chosen have the same alternate name type,
-- and also checks if the mappings defined for alternate name types are
-- mutually exclusive.
--
-- In Arguments:
--   p_alias_type_id_table
--   p_index
-- Return Value :
-- 0 -Failure
-- 1 -Success
-- {End Of Comments}
-- ----------------------------------------------------------------------------

function VALIDATE_ALIAS_DEFINITIONS(p_alias_type_id_table in hxc_hph_shd.alias_type_id_table
				   ,p_index in number) return number is
       key_mapping_id_table hxc_hph_shd.alias_mapping_table;
       key_alias_type_id hxc_alias_types.alias_type_id%type;
       l_alias_type_id hxc_alias_types.alias_type_id%type;
       l_mapping_id_table hxc_hph_shd.alias_mapping_table;
       i number;
       j number;
begin
       g_debug:=hr_utility.debug_enabled;
       key_alias_type_id := p_alias_type_id_table(p_index).id;
       if (key_alias_type_id is not null) then
       if g_debug then
	 hr_utility.trace('Key Alias Type Id' || key_alias_type_id);
       end if;
       get_mapping_components(key_alias_type_id,key_mapping_id_table);
       for i in 1..p_index-1 loop
           l_alias_type_id := p_alias_type_id_table(i).id;
	   if g_debug then
		hr_utility.trace('Validate_alias_definitions' || l_alias_type_id);
	   end if;
	   if (l_alias_type_id = key_alias_type_id) then
	       return 0;
	   else
	       get_mapping_components(l_alias_type_id,l_mapping_id_table);
	       j := key_mapping_id_table.first;
	       if g_debug then
		hr_utility.trace('Key Maping Id');
	       end if;
	       loop
	          exit when not key_mapping_id_table.exists(j);
		  if g_debug then
			hr_utility.trace('Matching ID ');
		  end if;
		  if (l_mapping_id_table.exists(j)) then
		     return 0;
		  end if;
		  j := key_mapping_id_table.next(j);
	       end loop;
	   end if;
       end loop;
       end if;
       return 1;
end validate_alias_definitions;

-- ----------------------------------------------------------------------------
-- |-------------------------< populate_alias_type_id_table >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Populates the pl/sql table with the alias_type_id of the alternate names
-- choosen,
--
-- In Arguments:
--   p_rec
--
-- In Out:
-- p_alias_type_id_table
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure populate_alias_type_id_table (p_rec in hxc_hph_shd.g_rec_type,
					p_alias_type_id_table in out nocopy hxc_hph_shd.alias_type_id_table) is
	cursor c_alias_type_id (p_alias_definition_id number) is
	       select alias_type_id
	         from hxc_alias_definitions had
		where had.alias_definition_id = p_alias_definition_id;
begin
  if (p_rec.attribute1 is not null) then
   open c_alias_type_id (p_rec.attribute1);
   fetch c_alias_type_id into p_alias_type_id_table(1).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(1).id := null;
  end if;

  if (p_rec.attribute2 is not null) then
   open c_alias_type_id (p_rec.attribute2);
   fetch c_alias_type_id into p_alias_type_id_table(2).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(2).id := null;
  end if;

  if (p_rec.attribute3 is not null) then
   open c_alias_type_id (p_rec.attribute3);
   fetch c_alias_type_id into p_alias_type_id_table(3).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(3).id := null;
  end if;

  if (p_rec.attribute4 is not null) then
   open c_alias_type_id (p_rec.attribute4);
   fetch c_alias_type_id into p_alias_type_id_table(4).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(4).id := null;
  end if;

  if (p_rec.attribute5 is not null) then
   open c_alias_type_id (p_rec.attribute5);
   fetch c_alias_type_id into p_alias_type_id_table(5).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(5).id := null;
  end if;

  if (p_rec.attribute6 is not null) then
   open c_alias_type_id (p_rec.attribute6);
   fetch c_alias_type_id into p_alias_type_id_table(6).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(6).id := null;
  end if;

  if (p_rec.attribute7 is not null) then
   open c_alias_type_id (p_rec.attribute7);
   fetch c_alias_type_id into p_alias_type_id_table(7).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(7).id := null;
  end if;

  if (p_rec.attribute8 is not null) then
   open c_alias_type_id (p_rec.attribute8);
   fetch c_alias_type_id into p_alias_type_id_table(8).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(8).id := null;
  end if;

  if (p_rec.attribute9 is not null) then
   open c_alias_type_id (p_rec.attribute9);
   fetch c_alias_type_id into p_alias_type_id_table(9).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(9).id := null;
  end if;

  if (p_rec.attribute10 is not null) then
   open c_alias_type_id (p_rec.attribute10);
   fetch c_alias_type_id into p_alias_type_id_table(10).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(10).id := null;
  end if;

  if (p_rec.attribute11 is not null) then
   open c_alias_type_id (p_rec.attribute11);
   fetch c_alias_type_id into p_alias_type_id_table(11).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(11).id := null;
  end if;

  if (p_rec.attribute12 is not null) then
   open c_alias_type_id (p_rec.attribute12);
   fetch c_alias_type_id into p_alias_type_id_table(12).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(12).id := null;
  end if;

  if (p_rec.attribute13 is not null) then
   open c_alias_type_id (p_rec.attribute13);
   fetch c_alias_type_id into p_alias_type_id_table(13).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(13).id := null;
  end if;

  if (p_rec.attribute14 is not null) then
   open c_alias_type_id (p_rec.attribute14);
   fetch c_alias_type_id into p_alias_type_id_table(14).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(14).id := null;
  end if;

  if (p_rec.attribute15 is not null) then
   open c_alias_type_id (p_rec.attribute15);
   fetch c_alias_type_id into p_alias_type_id_table(15).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(15).id := null;
  end if;

  if (p_rec.attribute16 is not null) then
   open c_alias_type_id (p_rec.attribute16);
   fetch c_alias_type_id into p_alias_type_id_table(16).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(16).id := null;
  end if;

  if (p_rec.attribute17 is not null) then
   open c_alias_type_id (p_rec.attribute17);
   fetch c_alias_type_id into p_alias_type_id_table(17).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(17).id := null;
  end if;

  if (p_rec.attribute18 is not null) then
   open c_alias_type_id (p_rec.attribute18);
   fetch c_alias_type_id into p_alias_type_id_table(18).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(18).id := null;
  end if;

  if (p_rec.attribute19 is not null) then
   open c_alias_type_id (p_rec.attribute19);
   fetch c_alias_type_id into p_alias_type_id_table(19).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(19).id := null;
  end if;

  if (p_rec.attribute20 is not null) then
   open c_alias_type_id (p_rec.attribute20);
   fetch c_alias_type_id into p_alias_type_id_table(20).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(20).id := null;
  end if;

  if (p_rec.attribute21 is not null) then
   open c_alias_type_id (p_rec.attribute21);
   fetch c_alias_type_id into p_alias_type_id_table(21).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(21).id := null;
  end if;

  if (p_rec.attribute22 is not null) then
   open c_alias_type_id (p_rec.attribute22);
   fetch c_alias_type_id into p_alias_type_id_table(22).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(22).id := null;
  end if;

  if (p_rec.attribute23 is not null) then
   open c_alias_type_id (p_rec.attribute23);
   fetch c_alias_type_id into p_alias_type_id_table(23).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(23).id := null;
  end if;

  if (p_rec.attribute24 is not null) then
   open c_alias_type_id (p_rec.attribute24);
   fetch c_alias_type_id into p_alias_type_id_table(24).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(24).id := null;
  end if;

  if (p_rec.attribute25 is not null) then
   open c_alias_type_id (p_rec.attribute25);
   fetch c_alias_type_id into p_alias_type_id_table(25).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(25).id := null;
  end if;

  if (p_rec.attribute26 is not null) then
   open c_alias_type_id (p_rec.attribute26);
   fetch c_alias_type_id into p_alias_type_id_table(26).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(26).id := null;
  end if;

  if (p_rec.attribute27 is not null) then
   open c_alias_type_id (p_rec.attribute27);
   fetch c_alias_type_id into p_alias_type_id_table(27).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(27).id := null;
  end if;

  if (p_rec.attribute28 is not null) then
   open c_alias_type_id (p_rec.attribute28);
   fetch c_alias_type_id into p_alias_type_id_table(28).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(28).id := null;
  end if;

  if (p_rec.attribute29 is not null) then
   open c_alias_type_id (p_rec.attribute29);
   fetch c_alias_type_id into p_alias_type_id_table(29).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(29).id := null;
  end if;

  if (p_rec.attribute30 is not null) then
   open c_alias_type_id (p_rec.attribute30);
   fetch c_alias_type_id into p_alias_type_id_table(30).id;
   close c_alias_type_id;
  else
   p_alias_type_id_table(30).id := null;
  end if;
end populate_alias_type_id_table;

-- ----------------------------------------------------------------------------
-- |------------------------< validate_alias_mapping_names >------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Checks if the mapping components choosen have the corresonding contexts are
-- choosen.
--
-- In Arguments:
--  p_alias_type_id_table
--
-- Return Value :
-- 0 -Failure
-- 1 -Success
-- {End Of Comments}
-- ----------------------------------------------------------------------------

function validate_alias_mapping_names(p_alias_type_id_table in hxc_hph_shd.alias_type_id_table) return number is
l_alias_mapping_name_table hxc_hph_shd.alias_mapping_name_table;
n number;
counter number := 1;
l_Inputvalue_flag number := 0;
l_CostSegment_flag number := 0;
l_GrpSegment_flag number := 0;
l_JobSegment_flag number := 0;
l_PosSegment_flag number := 0;
l_mapping_name varchar2(80);
succ number := 0;
cursor c_get_mapping_comp_name(p_alias_type_id number) is
     select name
       from hxc_alias_type_components hac,
            hxc_mapping_components hmc
      where hac.alias_type_id = p_alias_type_id
        and hac.mapping_component_id = hmc.mapping_component_id;

begin
    g_debug:=hr_utility.debug_enabled;
    n := p_alias_type_id_table.first;
    loop
       if g_debug then
	hr_utility.set_location('validate_alias_mapping_name' ,20);
       end if;
       exit when not p_alias_type_id_table.exists(n);
       open c_get_mapping_comp_name(p_alias_type_id_table(n).id);
       loop
          fetch c_get_mapping_comp_name into l_mapping_name;
	  l_alias_mapping_name_table(counter).mapping_comp_name := l_mapping_name;
 	  exit when c_get_mapping_comp_name%notfound;
	  counter := counter +1;
	  if (l_mapping_name like 'InputValue%') then
	      l_Inputvalue_flag := 1;
	  --else if (l_mapping_name like 'CostSegment%') then
	  --    l_CostSegment_flag := 1;
	  --else if (l_mapping_name like 'GrpSegment%') then
	  --    l_GrpSegment_flag := 1;
	  --else if (l_mapping_name like 'JobSegment%') then
	  --    l_JobSegment_flag := 1;
	  --else if (l_mapping_name like 'PosSegment%') then
	  --    l_PosSegment_flag := 1;
	  --end if;
	  --end if;
	  --end if;
	  --end if;
	  end if;
       end loop;


       close c_get_mapping_comp_name;
       n := p_alias_type_id_table.next(n);
    end loop;

       n := l_alias_mapping_name_table.first;
       loop
	   exit when not l_alias_mapping_name_table.exists(n);
	   l_mapping_name := l_alias_mapping_name_table(n).mapping_comp_name;
	   if g_debug then
		hr_utility.trace('l_mapping_name' || l_mapping_name);
	   end if;
	   n := l_alias_mapping_name_table.next(n);
       end loop;
    if g_debug then
	hr_utility.trace('l_Inputvalue_flag= ' || l_Inputvalue_flag);
    end if;
    if ( l_Inputvalue_flag= 1 ) then
        succ := 0;
        n := l_alias_mapping_name_table.first;
	loop
	   exit when not l_alias_mapping_name_table.exists(n);
	   l_mapping_name := l_alias_mapping_name_table(n).mapping_comp_name;
	   if (l_mapping_name = 'Dummy Element Context') then
	       succ := 1;
	   end if;
	   n := l_alias_mapping_name_table.next(n);
	 end loop;
         if (succ = 0) then
	    return 0;
	 end if;
    end if;
    /*
    if g_debug then
	hr_utility.trace('l_costsegment_flag ' || l_costsegment_flag);
    end if;
    if (l_CostSegment_flag = 1 ) then
        succ := 0;
        n := l_alias_mapping_name_table.first;
	loop
	   exit when not l_alias_mapping_name_table.exists(n);
	   l_mapping_name := l_alias_mapping_name_table(n).mapping_comp_name;
	   if (l_mapping_name = 'Dummy Cost Context') then
	       succ := 1;
	   end if;
	   n := l_alias_mapping_name_table.next(n);
	 end loop;
	 if g_debug then
		hr_utility.trace('Succ: ' || succ);
         end if;
	 if (succ = 0) then
	    return 0;
	 end if;
    end if;
        if g_debug then
		hr_utility.trace('l_GrpSegment_flag ' || l_GrpSegment_flag);
	end if;
    if (l_GrpSegment_flag = 1 ) then
        succ := 0;
        n := l_alias_mapping_name_table.first;
	loop
	   exit when not l_alias_mapping_name_table.exists(n);
	   l_mapping_name := l_alias_mapping_name_table(n).mapping_comp_name;
	   if (l_mapping_name = 'Dummy Grp Context') then
	       succ := 1;
	   end if;
	   n := l_alias_mapping_name_table.next(n);
	 end loop;
         if (succ = 0) then
	    return 0;
	 end if;
    end if;
        if g_debug then
		hr_utility.trace('l_JobSegment_flag ' || l_JobSegment_flag);
	end if;
    if (l_JobSegment_flag = 1 ) then
        succ := 0;
        n := l_alias_mapping_name_table.first;
	loop
	   exit when not l_alias_mapping_name_table.exists(n);
	   l_mapping_name := l_alias_mapping_name_table(n).mapping_comp_name;
	   if (l_mapping_name = 'Dummy Job Context') then
	       succ := 1;
	   end if;
	   n := l_alias_mapping_name_table.next(n);
	 end loop;
         if (succ = 0) then
	    return 0;
	 end if;
    end if;
        if g_debug then
		hr_utility.trace('l_PosSegment_flag ' || l_PosSegment_flag);
	end if;
    if (l_PosSegment_flag = 1 ) then
        succ := 0;
        n := l_alias_mapping_name_table.first;
	loop
	   exit when not l_alias_mapping_name_table.exists(n);
	   l_mapping_name := l_alias_mapping_name_table(n).mapping_comp_name;
	   if (l_mapping_name = 'Dummy Pos Context') then
	       succ := 1;
	   end if;
	   n := l_alias_mapping_name_table.next(n);
	 end loop;
         if (succ = 0) then
	    return 0;
	 end if;
    end if;
    */
    return 1;
end validate_alias_mapping_names;

procedure validate_alias (p_rec  in hxc_hph_shd.g_rec_type) is
n number;
succ number;
l_alias_type_id_table hxc_hph_shd.alias_type_id_table;
l_alias_mapping_name_table hxc_hph_shd.alias_mapping_name_table;
begin
g_debug:=hr_utility.debug_enabled;
if g_debug then
	hr_utility.trace('p_rec.attribute_category' ||p_rec.attribute_category);
end if;
if (p_rec.attribute_category = 'TK_TCARD_ATTRIBUTES_DEFINITION') then
if g_debug then
	hr_utility.set_location('validate_alias',20);
end if;
    populate_alias_type_id_table(p_rec,l_alias_type_id_table);
    n := l_alias_type_id_table.first;
    loop
       if g_debug then
		hr_utility.set_location('validate_alias',30);
       end if;
       exit when not l_alias_type_id_table.exists(n);
       if g_debug then
		hr_utility.trace('n' || n);
       end if;
       succ := validate_alias_definitions(l_alias_type_id_table,n);
       if (succ =0) then
          hr_utility.set_message(809,'HXC_AN_DEFN_WRG');
	  hr_utility.raise_error;
       end if;
       n:= l_alias_type_id_table.next(n);
    end loop;
    succ := validate_alias_mapping_names(l_alias_type_id_table);
    if (succ = 0) then
       hr_utility.set_message(809,'HXC_AN_DEFN_WRG');
       hr_utility.raise_error;
    end if;
 end if;
 end validate_alias;


--
--  -----------------------------------------------------------------
--  |-----------------------< chk_legislation_code >----------------|
--  -----------------------------------------------------------------
--
--  Description:
--    Validate the legislation_code against the FND_TERRITORIES table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_legislation_code
--
--  Post Success:
--    Processing continues if the legislation_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_code is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_legislation_code
       (p_business_group_id           in      number,
        p_legislation_code           in      varchar2
       ) is
--
--   Local declarations
  l_proc               varchar2(72);
  l_territory_code     fnd_territories.territory_code%TYPE;
  l_lc                 per_business_groups.legislation_code%TYPE;
--
-- Setup cursor for valid legislation code check
  cursor csr_valid_legislation_code is
    select territory_code
    from fnd_territories ft
    where ft.territory_code = p_legislation_code;

-- Setup cursor for valid legislation code for a particular business_group
  cursor csr_valid_bg_lc is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id
    and   pbg.legislation_code = p_legislation_code;

--
--
begin
    g_debug:=hr_utility.debug_enabled;
    if g_debug then
	l_proc := g_package||'chk_legislation_code';
	hr_utility.set_location('Entering: '||l_proc,5);
    end if;
     --------------------------------
     -- Check legislation code is valid --
     --------------------------------
     if p_legislation_code is not null then

        open csr_valid_legislation_code;
        fetch csr_valid_legislation_code into l_territory_code;
        if csr_valid_legislation_code%notfound then
            close csr_valid_legislation_code;
            hr_utility.set_message(800,'PER_52123_AMD_LEG_CODE_INV');
            hr_utility.raise_error;
        end if; -- End cursor if
        close csr_valid_legislation_code;

        if p_business_group_id is not null then
           open csr_valid_bg_lc;
           fetch csr_valid_bg_lc into l_lc;
           if csr_valid_bg_lc%notfound then
              close csr_valid_bg_lc;
              hr_utility.set_message(800,'PER_52123_AMD_LEG_CODE_INV');
              hr_utility.raise_error;
           end if; -- End cursor if
           close csr_valid_bg_lc;
        end if;

     end if; -- end check

    if g_debug then
	hr_utility.set_location('Leaving: '||l_proc,10);
    end if;
end chk_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_hph_shd.g_rec_type
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
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
  --
  -- Do check for duplicate pref hierarchy name
  --
  if g_debug then
	hr_utility.trace('p_rec.attribute_category is ' || p_rec.attribute_category);
  end if;
  chk_name ( p_name => p_rec.name,
             p_parent_pref_hierarchy_id => p_rec.parent_pref_hierarchy_id,
             p_business_group_id => p_rec.business_group_id,
             p_object_version_number => p_rec.object_version_number );
  --
  --
  -- Do check for duplicate pref hierarchy code
  --
  chk_pref_code( p_pref_code => p_rec.attribute_category,
             p_parent_pref_hierarchy_id => p_rec.parent_pref_hierarchy_id,
             p_pref_hierarchy_id => p_rec.pref_hierarchy_id,
             p_object_version_number => p_rec.object_version_number );
  --
  chk_rules_evaluation_pref  (
                              p_pref_code => p_rec.attribute_category
                            , p_attribute1 => p_rec.attribute1
                            , p_attribute2 => p_rec.attribute2 );
  --
  chk_tk_person_name_number (
				p_pref_code => p_rec.attribute_category,
				p_attribute2 => p_rec.attribute2,
				p_attribute3 => p_rec.attribute3);

   chk_tk_audit_segments (
			  p_pref_code => p_rec.attribute_category,
			  p_attribute1 => p_rec.attribute1,
			  p_attribute2 => p_rec.attribute2,
			  p_attribute3 => p_rec.attribute3,
			  p_attribute4 => p_rec.attribute4);

chk_days_hours_factor(
    p_pref_code => p_rec.attribute_category
   , p_attribute1 => p_rec.attribute1
   , p_attribute2 => p_rec.attribute2 );

if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
	--
	hr_utility.set_location('Processing:'||l_proc, 15);
end if;

  IF ( p_rec.parent_pref_hierarchy_id is null )
  THEN

	  -- Do check for duplicate top node if defining top node

	  chk_top_node ( p_name => p_rec.name,
	  		 p_business_group_id => p_rec.business_group_id,
	                 p_object_version_number => p_rec.object_version_number );

  END IF;

  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 20);
  end if;
  --
  -- Check that a single hierarchy does not contain the same preference twice
  --
  chk_preference ( p_pref_definition_id => p_rec.pref_definition_id,
             p_bg_id => p_rec.business_group_id,
             p_parent_pref_hierarchy_id => p_rec.parent_pref_hierarchy_id,
             p_object_version_number => p_rec.object_version_number );
  --
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  --
    if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  -- Validate the legislation_code
       chk_legislation_code
       (p_business_group_id           => p_rec.business_group_id,
        p_legislation_code              => p_rec.legislation_code);
--
  hxc_hph_bus.chk_df(p_rec);
  --
  hxc_hph_bus.validate_alias(p_rec);
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_hph_shd.g_rec_type
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
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  -- Do check for duplicate pref hierarchy name
  --
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
  --
  chk_name ( p_name => p_rec.name,
             p_parent_pref_hierarchy_id => p_rec.parent_pref_hierarchy_id,
             p_business_group_id => p_rec.business_group_id,
             p_object_version_number => p_rec.object_version_number );
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
  --
  -- Do check for duplicate pref hierarchy code
  --
  chk_pref_code( p_pref_code => p_rec.attribute_category,
             p_parent_pref_hierarchy_id => p_rec.parent_pref_hierarchy_id,
             p_pref_hierarchy_id => p_rec.pref_hierarchy_id,
             p_object_version_number => p_rec.object_version_number );

  chk_rules_evaluation_pref  (
                              p_pref_code => p_rec.attribute_category
                            , p_attribute1 => p_rec.attribute1
                            , p_attribute2 => p_rec.attribute2 );
  --
  chk_tk_person_name_number (
                                p_pref_code => p_rec.attribute_category,
                                p_attribute2 => p_rec.attribute2,
                                p_attribute3 => p_rec.attribute3);

   chk_tk_audit_segments (
			  p_pref_code => p_rec.attribute_category,
			  p_attribute1 => p_rec.attribute1,
			  p_attribute2 => p_rec.attribute2,
			  p_attribute3 => p_rec.attribute3,
			  p_attribute4 => p_rec.attribute4);
chk_days_hours_factor(
    p_pref_code => p_rec.attribute_category
   , p_attribute1 => p_rec.attribute1
   , p_attribute2 => p_rec.attribute2 );

  --
if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 15);
end if;
  IF ( p_rec.parent_pref_hierarchy_id is null )
  THEN

	  -- Do check for duplicate top node

	  chk_top_node ( p_name => p_rec.name,
	  		 p_business_group_id => p_rec.business_group_id,
	                 p_object_version_number => p_rec.object_version_number );

  END IF;

  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 20);
  end if;
  --
  -- Check that a single hierarchy does not contain the same preference twice
  --
  chk_preference ( p_pref_definition_id => p_rec.pref_definition_id,
             p_bg_id => p_rec.business_group_id,
             p_parent_pref_hierarchy_id => p_rec.parent_pref_hierarchy_id,
             p_object_version_number => p_rec.object_version_number );
  --
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;
  --
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  -- Validate the legislation_code
       chk_legislation_code
       (p_business_group_id           => p_rec.business_group_id,
        p_legislation_code              => p_rec.legislation_code);
  --
  hxc_hph_bus.chk_df(p_rec);
    hxc_hph_bus.validate_alias(p_rec);
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 15);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_hph_shd.g_rec_type
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
end hxc_hph_bus;

/
