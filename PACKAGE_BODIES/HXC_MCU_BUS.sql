--------------------------------------------------------
--  DDL for Package Body HXC_MCU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_MCU_BUS" as
/* $Header: hxcmcurhi.pkb 120.2 2005/09/23 08:44:11 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_mcu_bus.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
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
  (p_rec in hxc_mcu_shd.g_rec_type
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
  IF NOT hxc_mcu_shd.api_updating
      (p_mapping_comp_usage_id                => p_rec.mapping_comp_usage_id
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
-- |-----------------------< chk_mapping_component_id >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid mapping component id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   mapping component id
--
-- Post Success:
--   Processing continues if the mapping component id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the mapping component id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_mapping_component_id
  (
   p_mapping_component_id  in hxc_mapping_components.mapping_component_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check mapping_component_id is valid
--
CURSOR  csr_chk_mpc IS
SELECT 'error'
FROM	sys.dual
WHERE NOT EXISTS (
	SELECT	'x'
	FROM	hxc_mapping_components mpc
	WHERE	mpc.mapping_component_id = p_mapping_component_id );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_mapping_component_id';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the mapping component id  has been entered
--
IF p_mapping_component_id IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0031_MCU_MPC_ID_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that mapping_component_id is valid
--
  OPEN  csr_chk_mpc;
  FETCH csr_chk_mpc INTO l_error;
  CLOSE csr_chk_mpc;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0032_MCU_MPC_ID_INVLD');
      hr_utility.raise_error;
--
END IF;
--
END chk_mapping_component_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_mapping_id >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid mapping id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   mapping id
--
-- Post Success:
--   Processing continues if the mapping id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the mapping id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_mapping_id
  (
   p_mapping_id  in hxc_mappings.mapping_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check mapping id is valid
--
CURSOR  csr_chk_map IS
SELECT 'error'
FROM	sys.dual
WHERE NOT EXISTS (
	SELECT	'x'
	FROM	hxc_mappings map
	WHERE	map.mapping_id = p_mapping_id );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_mapping_id';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the mapping id has been entered
--
IF p_mapping_id IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0034_MCU_MAP_ID_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that mapping_component_id is valid
--
  OPEN  csr_chk_map;
  FETCH csr_chk_map INTO l_error;
  CLOSE csr_chk_map;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0033_MCU_MAP_ID_INVLD');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_mapping_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_mcu_field_name>------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure the field name is used onlyu once in a mapping
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   mapping component id
--   mapping id
--
-- Post Success:
--   Processing continues if the field name is not duplicated
--
-- Post Failure:
--   An application error is raised if the field name is duplicated
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_mcu_field_name
  (
   p_mapping_id            in hxc_mappings.mapping_id%TYPE
,  p_mapping_component_id  in hxc_mapping_components.mapping_component_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
CURSOR csr_chk_field_name IS
SELECT 'error'
FROM	hxc_mapping_components mpc
WHERE	mpc.mapping_component_id = p_mapping_component_id
AND EXISTS (
	SELECT	'x'
	FROM	hxc_mapping_components mpc1
	,	hxc_mapping_comp_usages mcu
	WHERE	mcu.mapping_id	= p_mapping_id
	AND	mcu.mapping_component_id = mpc1.mapping_component_id
	AND	mpc1.mapping_component_id <> mpc.mapping_component_id
	AND	mpc1.field_name	= mpc.field_name );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_mcu_field_name';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that field name is not used more than once in the mapping
--
  OPEN  csr_chk_field_name;
  FETCH csr_chk_field_name INTO l_error;
  CLOSE csr_chk_field_name;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0035_MCU_DUP_FLD_NAME');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 10);
  end if;
--
END chk_mcu_field_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_mcu_composite_key>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures the segment and bld blk info type are unique within
--   a mapping
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   mapping component id
--   mapping id
--
-- Post Success:
--   Processing continues if the key is not duplicated
--
-- Post Failure:
--   An application error is raised if the key is duplicated
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_mcu_composite_key
  (
   p_mapping_id            in hxc_mappings.mapping_id%TYPE
,  p_mapping_component_id  in hxc_mapping_components.mapping_component_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
CURSOR csr_chk_composite_key IS
SELECT 'error'
FROM	hxc_mapping_components mpc
WHERE	mpc.mapping_component_id = p_mapping_component_id
AND EXISTS (
	SELECT	'x'
	FROM	hxc_mapping_components mpc1
	,	hxc_mapping_comp_usages mcu
	WHERE	mcu.mapping_id	= p_mapping_id
	AND	mcu.mapping_component_id = mpc1.mapping_component_id
	AND	mpc1.segment = mpc.segment
	AND     mpc1.bld_blk_info_type_id = mpc.bld_blk_info_type_id );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_mcu_composite_key';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that composite key is not used more than once in the mapping
--
  OPEN  csr_chk_composite_key;
  FETCH csr_chk_composite_key INTO l_error;
  CLOSE csr_chk_composite_key;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0036_MCU_DUP_TYPE_SEG');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 10);
  end if;
--
END chk_mcu_composite_key;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This procedure is the same as HXC_MAP_BUS's chk_delete.
-- See hxmaprhi.pkh for details
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_mcu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'insert_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  -- Call all supporting business operations
  --
	chk_mapping_component_id (
		p_mapping_component_id => p_rec.mapping_component_id );
  --
	chk_mapping_id ( p_mapping_id => p_rec.mapping_id );
  --
	chk_mcu_field_name ( p_mapping_id => p_rec.mapping_id
			   , p_mapping_component_id => p_rec.mapping_component_id);
  --
	chk_mcu_composite_key ( p_mapping_id => p_rec.mapping_id
			   , p_mapping_component_id => p_rec.mapping_component_id);
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
  (p_rec                          in hxc_mcu_shd.g_rec_type
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
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  -- Call all supporting business operations
  --
	chk_mapping_component_id (
		p_mapping_component_id => p_rec.mapping_component_id );
  --
	chk_mapping_id ( p_mapping_id => p_rec.mapping_id );
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
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
  (p_rec                          in hxc_mcu_shd.g_rec_type
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
  hxc_map_bus.chk_delete ( p_mapping_id => p_rec.mapping_id );
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_mcu_bus;

/
