--------------------------------------------------------
--  DDL for Package Body HXC_TER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TER_BUS" as
/* $Header: hxcterrhi.pkb 120.2 2005/09/23 09:19:47 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ter_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_time_entry_rule_id       number         default null;

g_debug boolean := hr_utility.debug_enabled;
--
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
  (p_rec in hxc_ter_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72);
--
begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package || 'chk_df';
  	hr_utility.set_location('Entering:'||l_proc,10);
  end if;
  --
  if ((p_rec.time_entry_rule_id is not null)  and (
    nvl(hxc_ter_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(hxc_ter_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.time_entry_rule_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'HXC'
      ,p_descflex_name                   => 'OTL Formulas'
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
  ,p_rec in hxc_ter_shd.g_rec_type
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
  IF NOT hxc_ter_shd.api_updating
      (p_time_entry_rule_id                => p_rec.time_entry_rule_id
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
--   This procedure insures a valid time entry rule name
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   object_version_number
--   start_date
--   end_date
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
   p_name       in hxc_time_entry_rules.name%TYPE
  ,p_time_entry_rule_id in hxc_time_entry_rules.time_entry_rule_id%TYPE
  ,p_end_date    in hxc_time_entry_rules.end_date%TYPE
  ,p_start_date  in hxc_time_entry_rules.start_date%TYPE
  ,p_legislation_code VARCHAR2
  ,p_bg_id NUMBER
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check name does not overlap
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM	hxc_time_entry_rules ter
WHERE
	ter.name	= p_name AND
	( ter.time_entry_rule_id <> p_time_entry_rule_id OR
	  p_time_entry_rule_id IS NULL )
AND (
	( ter.business_group_id IS NULL AND
	  ter.legislation_code  IS NULL )
	OR
	( ter.legislation_code IS NOT NULL AND
	  ter.legislation_code = p_legislation_code )
        OR
        ( ter.business_group_id IS NOT NULL AND
          ter.business_group_id = NVL( p_bg_id, -1 ) )
	OR
	( p_bg_id IS NULL ) )
AND (
	(
		( p_start_date BETWEEN
		  ter.start_date AND NVL(ter.end_date, HR_GENERAL.END_OF_TIME )
		)
		OR
		( NVL(p_end_date, HR_GENERAL.END_OF_TIME ) BETWEEN
		  ter.start_date AND NVL(ter.end_date, HR_GENERAL.END_OF_TIME )
		)
	)
	OR
		( ter.start_date BETWEEN
		  p_start_date AND NVL(p_end_date, HR_GENERAL.END_OF_TIME )
		)
		OR
		( NVL(ter.end_date, HR_GENERAL.END_OF_TIME ) BETWEEN
		  p_start_date AND NVL(p_end_date, HR_GENERAL.END_OF_TIME )
		)

    );
--
 l_dup_name varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

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
      hr_utility.set_message(809, 'HXC_0037_DAR_NAME_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that the name is unique within the date range
--
  OPEN  csr_chk_name;
  FETCH csr_chk_name INTO l_dup_name;
  CLOSE csr_chk_name;
--
IF l_dup_name IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0038_DAR_DUP_NAME');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
END chk_name;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_rule_usage >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid rule usage
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   rule_usage
--
-- Post Success:
--   Processing continues if the rule usage is entered and is valid
--
-- Post Failure:
--   An application error is raised if the rule usage is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_rule_usage
  (
   p_rule_usage in hxc_time_entry_rules.rule_usage%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
CURSOR csr_chk_rule_usage IS
SELECT	'ok'
FROM	hr_lookups
WHERE	lookup_type = 'HXC_APPROVAL_RULE_USAGE'
AND	lookup_code = p_rule_usage;
--
l_valid_usage VARCHAR2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_rule_usage';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that usage_name has been entered
--
IF p_rule_usage IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0039_DAR_USAGE_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('In:'||l_proc, 10);
  end if;
--
-- check if the rule_usage name exists in HR_LOOKUPS
--
	OPEN  csr_chk_rule_usage;
	FETCH csr_chk_rule_usage INTO l_valid_usage;
	CLOSE csr_chk_rule_usage;
--
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 20);
  end if;
--
IF l_valid_usage IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0040_DAR_USAGE_INVLD');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 30);
  end if;
END chk_rule_usage;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_mapping_id >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid mapping_id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   mapping_id
--
-- Post Success:
--   Processing continues if the mapping_id is valid
--
-- Post Failure:
--   An application error is raised if the mapping_id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_mapping_id
  (
   p_mapping_id in hxc_time_entry_rules.mapping_id%TYPE
  ) IS
--
  l_proc  varchar2(72) := g_package||'chk_mapping_id';
--
CURSOR csr_chk_mapping_id IS
SELECT 'ok'
FROM	dual
WHERE	EXISTS (
	SELECT 'x'
	FROM	hxc_mappings
	WHERE	mapping_id	= p_mapping_id );
--
l_mapping_ok varchar2(2) := NULL;
--
BEGIN
--
IF p_mapping_id IS NOT NULL
THEN
	--
	-- check mapping id exists
	--
		OPEN  csr_chk_mapping_id;
		FETCH csr_chk_mapping_id INTO l_mapping_ok;
		CLOSE csr_chk_mapping_id;
	--
	IF l_mapping_ok IS NULL
	THEN
	--
	      hr_utility.set_message(809, 'HXC_0041_DAR_MAPPING_INVLD');
	      hr_utility.raise_error;
	--
	END IF;
--
END IF;
--
END chk_mapping_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_formula_id >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid formula_id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   formula_id
--   start_date
--   end_date
--
-- Post Success:
--   Processing continues if the formual_id is valid
--
-- Post Failure:
--   An application error is raised if the formula_id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_formula_id
  (
   p_formula_id in hxc_time_entry_rules.formula_id%TYPE
  ,p_start_date  in hxc_time_entry_rules.start_date%TYPE
  ,p_end_date    in hxc_time_entry_rules.end_date%TYPE
  ) IS
--
  l_proc  varchar2(72) := g_package||'chk_formula_id';
--
CURSOR csr_chk_formula_id IS
SELECT 'ok'
FROM	dual
WHERE	EXISTS (
	SELECT 'x'
	FROM	ff_formulas_f
	WHERE	formula_id	= p_formula_id
	AND	effective_start_date <= p_start_date
	AND	effective_end_date   >= p_end_date );
--
l_formula_ok varchar2(2) := NULL;
--
BEGIN
--
IF p_formula_id IS NOT NULL
THEN
	--
	-- check formula valid over range of approval rule
	--
		OPEN  csr_chk_formula_id;
		FETCH csr_chk_formula_id INTO l_formula_ok;
		CLOSE csr_chk_formula_id;
	--
	IF l_formula_ok IS NULL
	THEN
	--
	      hr_utility.set_message(809, 'HXC_0042_DAR_FF_DATE_INVLD');
	      hr_utility.raise_error;
	--
	END IF;
--
END IF;
--
END chk_formula_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_mapping_formula>-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures that at least one of mapping id or formula id are
--   entered
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   formula_id
--   mapping_id
--
-- Post Success:
--   Processing continues if the formula_id or mapping id is entered
--
-- Post Failure:
--   An application error is raised if the formula_id or mapping is are not entered
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_formula_mapping
  (
   p_formula_id in hxc_time_entry_rules.formula_id%TYPE
,  p_mapping_id in hxc_time_entry_rules.mapping_id%TYPE
  ) IS

  l_proc  varchar2(72) := g_package||'chk_formula_mapping';

BEGIN

	IF ( p_formula_id IS NULL AND p_mapping_id IS NULL )
	THEN

	      hr_utility.set_message(809, 'HXC_0043_DAR_MAP_OR_FF_MAND');
	      hr_utility.raise_error;

	END IF;

END chk_formula_mapping;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_start_date >----------------------------------|
-- ----------------------------------------------------------------------------
-- doc for this procedure is located in the header
-- ----------------------------------------------------------------------------
Procedure chk_start_date
  (
   p_name       in hxc_time_entry_rules.name%TYPE
  ,p_start_date  in hxc_time_entry_rules.start_date%TYPE
  ,p_end_date    in hxc_time_entry_rules.end_date%TYPE
  ,p_ovn	in hxc_time_entry_rules.object_version_number%TYPE
  ,p_bg_id NUMBER
  ,p_legislation_code VARCHAR2
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check start date does not overlap
--
CURSOR  csr_chk_start_date IS
SELECT 'error'
FROM	hxc_time_entry_rules ter
WHERE
	ter.name	= p_name AND
	ter.object_version_number <> NVL(p_ovn, -1)
AND (
	( ter.business_group_id IS NULL AND
	  ter.legislation_code  IS NULL )
	OR
	( ter.legislation_code IS NOT NULL AND
	  ter.legislation_code = p_legislation_code )
        OR
        ( ter.business_group_id IS NOT NULL AND
          ter.business_group_id = NVL( p_bg_id, -1 ) )
	OR
	( p_bg_id IS NULL ) )
AND
	p_start_date BETWEEN
	ter.start_date AND NVL(ter.end_date, HR_GENERAL.END_OF_TIME );
--
 l_bad_start_date varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_start_date';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
-- check that date from has been entered
--
IF p_start_date IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0056_DAR_START_DATE_MAND');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 10);
  end if;
--
-- check that date from is not greater than end_date
--
IF p_start_date > NVL(p_end_date, HR_GENERAL.END_OF_TIME )
THEN
--
      hr_utility.set_message(809, 'HXC_0057_DAR_FROM_MORE_THAN_TO');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 20);
  end if;
--
-- check that this start date does not overlap with rule of the same name
--
  OPEN  csr_chk_start_date;
  FETCH csr_chk_start_date INTO l_bad_start_date;
  CLOSE csr_chk_start_date;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 30);
  end if;
--
IF l_bad_start_date IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0058_DAR_FROM_OVERLAPS');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving: '||l_proc, 40);
  end if;
--
END chk_start_date;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_end_date >------------------------------------|
-- ----------------------------------------------------------------------------
-- doc for this procedure is located in the header
-- ----------------------------------------------------------------------------
Procedure chk_end_date
  (
   p_name       in hxc_time_entry_rules.name%TYPE
  ,p_start_date  in hxc_time_entry_rules.start_date%TYPE
  ,p_end_date    in hxc_time_entry_rules.end_date%TYPE
  ,p_ovn	in hxc_time_entry_rules.object_version_number%TYPE
  ,p_bg_id NUMBER
  ,p_legislation_code VARCHAR2
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check start date does not overlap
--
CURSOR  csr_chk_end_date IS
SELECT 'error'
FROM	hxc_time_entry_rules ter
WHERE
	ter.name	= p_name AND
	ter.object_version_number <> NVL(p_ovn, -1)
AND (
	( ter.business_group_id IS NULL AND
	  ter.legislation_code  IS NULL )
	OR
	( ter.legislation_code IS NOT NULL AND
	  ter.legislation_code = p_legislation_code )
        OR
        ( ter.business_group_id IS NOT NULL AND
          ter.business_group_id = NVL( p_bg_id, -1 ) )
	OR
	( p_bg_id IS NULL ) )
AND
	p_end_date BETWEEN
	ter.start_date AND NVL(ter.end_date, HR_GENERAL.END_OF_TIME );
--
 l_bad_end_date varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_end_date';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that date to is not less than date from
--
IF NVL(p_end_date, HR_GENERAL.END_OF_TIME ) < p_start_date
THEN
--
      hr_utility.set_message(809, 'HXC_0059_DAR_TO_LESS_THAN_FROM');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 10);
  end if;
--
-- check that this end date does not overlap with rule of the same name
--
  OPEN  csr_chk_end_date;
  FETCH csr_chk_end_date INTO l_bad_end_date;
  CLOSE csr_chk_end_date;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 20);
  end if;
--
IF l_bad_end_date IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0060_DAR_TO_OVERLAPS');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving: '||l_proc, 30);
  end if;
--
END chk_end_date;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure carries out delete time refential integrity checks
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   time_entry_rule__id
--
-- Post Success:
--   Processing continues if the name is not being referenced
--
-- Post Failure:
--   An application error is raised if the rule is being used.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_time_entry_rule_id in hxc_time_entry_rules.time_entry_rule_id%TYPE
  ) IS

  l_proc  varchar2(72);

CURSOR csr_chk_teru IS
SELECT 'exists'
FROM   hxc_entity_group_comps egc
WHERE  egc.entity_type = 'TIME_ENTRY_RULES'
AND    egc.entity_id   = p_time_entry_rule_id;

CURSOR csr_chk_daru IS
SELECT 'exists'
FROM   hxc_data_app_rule_usages daru
WHERE  daru.time_entry_rule_id = p_time_entry_rule_id;


l_exists VARCHAR2(6) := NULL;

BEGIN
g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'chk_delete';
	hr_utility.set_location('Entering:'||l_proc, 5);
end if;

-- check that approval rule is not being used in any
-- Time Entry Rule or ELP Entry Rule Group

OPEN  csr_chk_teru;
FETCH csr_chk_teru INTO l_exists;
CLOSE csr_chk_teru;

 if g_debug then
 	hr_utility.set_location('Processing: '||l_proc, 10);
 end if;

IF l_exists IS NOT NULL
THEN

      hr_utility.set_message(809, 'HXC_0061_DAR_RULE_IN_USE');
      hr_utility.raise_error;

END IF;

-- check that the time entry rule is not being used in
-- an approval style Date Interdepency Rule

OPEN  csr_chk_daru;
FETCH csr_chk_daru INTO l_exists;
CLOSE csr_chk_daru;

 if g_debug then
 	hr_utility.set_location('Processing: '||l_proc, 20);
 end if;

IF l_exists IS NOT NULL
THEN

      hr_utility.set_message(809, 'HXC_TER_REF_APPROVAL');
      hr_utility.raise_error;

END IF;



  if g_debug then
  	hr_utility.set_location('Leaving: '||l_proc, 30);
  end if;

END chk_delete;
--
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
    g_debug := hr_utility.debug_enabled;

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
  ,p_rec                          in hxc_ter_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||' insert_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
chk_name (
   p_name	    => p_rec.name
  ,p_time_entry_rule_id => p_rec.time_entry_rule_id
  ,p_end_date        => p_rec.end_date
  ,p_start_date      => p_rec.start_date
  ,p_legislation_code=> p_rec.legislation_code
  ,p_bg_id           => p_rec.business_group_id
  );
  --
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 10);
  end if;
  --
chk_rule_usage
  (
   p_rule_usage	=> p_rec.rule_usage
  );
  --
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 30);
  end if;
--
chk_mapping_id
  (
   p_mapping_id => p_rec.mapping_id
   );
--
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 40);
  end if;
--
chk_formula_id
  (
   p_formula_id => p_rec.formula_id
  ,p_start_date  => p_rec.start_date
  ,p_end_date    => p_rec.end_date );
--
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 50);
  end if;
--
chk_formula_mapping
  (
   p_formula_id => p_rec.formula_id
,  p_mapping_id => p_rec.mapping_id );
--
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 50);
  end if;
chk_start_date
  (
   p_name       => p_rec.name
  ,p_start_date  => p_rec.start_date
  ,p_end_date    => p_rec.end_date
  ,p_ovn        => p_rec.object_version_number
  ,p_legislation_code=> p_rec.legislation_code
  ,p_bg_id           => p_rec.business_group_id
  );
--
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 50);
  end if;
chk_end_date
  (
   p_name       => p_rec.name
  ,p_start_date  => p_rec.start_date
  ,p_end_date    => p_rec.end_date
  ,p_ovn        => p_rec.object_version_number
  ,p_legislation_code=> p_rec.legislation_code
  ,p_bg_id           => p_rec.business_group_id
  );
--
  if p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  -- Validate the legislation_code
       chk_legislation_code
       (p_business_group_id           => p_rec.business_group_id,
        p_legislation_code              => p_rec.legislation_code);
--
  hxc_ter_bus.chk_df(p_rec);

  if g_debug then
  	hr_utility.set_location(' Leaving: '||l_proc, 60);
  end if;
--
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_ter_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'update_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 10);
  end if;
  --
  --

  --
 chk_name (
   p_name	    => p_rec.name
  ,p_time_entry_rule_id => p_rec.time_entry_rule_id
  ,p_end_date        => p_rec.end_date
  ,p_start_date      => p_rec.start_date
  ,p_legislation_code=> p_rec.legislation_code
  ,p_bg_id           => p_rec.business_group_id
  );
  --
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 20);
  end if;
  --
chk_rule_usage
  (
   p_rule_usage	=> p_rec.rule_usage
  );
  --
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 30);
  end if;
  --
chk_mapping_id
  (
   p_mapping_id => p_rec.mapping_id
   );
--
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 40);
  end if;
chk_formula_id
  (
   p_formula_id => p_rec.formula_id
  ,p_start_date  => p_rec.start_date
  ,p_end_date    => p_rec.end_date );
--
chk_formula_mapping
  (
   p_formula_id => p_rec.formula_id
,  p_mapping_id => p_rec.mapping_id );
--
  if g_debug then
  	hr_utility.set_location(' Processing: '||l_proc, 50);
  end if;
chk_start_date
  (
   p_name       => p_rec.name
  ,p_start_date  => p_rec.start_date
  ,p_end_date    => p_rec.end_date
  ,p_ovn        => p_rec.object_version_number
  ,p_legislation_code=> p_rec.legislation_code
  ,p_bg_id           => p_rec.business_group_id
  );
--
chk_end_date
  (
   p_name       => p_rec.name
  ,p_start_date  => p_rec.start_date
  ,p_end_date    => p_rec.end_date
  ,p_ovn        => p_rec.object_version_number
  ,p_legislation_code=> p_rec.legislation_code
  ,p_bg_id           => p_rec.business_group_id
  );
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
  hxc_ter_bus.chk_df(p_rec);
--
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 60);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_ter_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'delete_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
chk_delete
  (
   p_time_entry_rule_id => p_rec.time_entry_rule_id
  );
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_ter_bus;

/
