--------------------------------------------------------
--  DDL for Package Body HXC_MAP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_MAP_BUS" as
/* $Header: hxcmaprhi.pkb 120.2 2005/09/23 08:17:59 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_map_bus.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
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
  (p_rec in hxc_map_shd.g_rec_type
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
  IF NOT hxc_map_shd.api_updating
      (p_mapping_id                           => p_rec.mapping_id
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
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- Note:
--      This procedure is called from the client
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_name       in hxc_mappings.name%TYPE
  ,p_mapping_id in hxc_mappings.mapping_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check name does not overlap
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_mappings map
	WHERE	map.name	= p_name AND
	( map.mapping_id <> p_mapping_id OR
	  p_mapping_id IS NULL ) );
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
      hr_utility.set_message(809, 'HXC_0028_MAP_NAME_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that the name is unique
--
  OPEN  csr_chk_name;
  FETCH csr_chk_name INTO l_dup_name;
  CLOSE csr_chk_name;
--
IF l_dup_name IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0029_MAP_DUP_NAME');
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
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- Note:
--      This procedure is shared by hxc_mcu_bus
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_mapping_id in hxc_mappings.mapping_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
CURSOR csr_chk_dar IS
SELECT 'exists'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_time_entry_rules dar
	WHERE  dar.mapping_id = p_mapping_id);
--
--
CURSOR csr_chk_dep IS
SELECT 'exists'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_deposit_processes dep
	WHERE  dep.mapping_id = p_mapping_id);
--
--
CURSOR csr_chk_ret IS
SELECT 'exists'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_retrieval_processes ret
	WHERE  ret.mapping_id = p_mapping_id);
--
l_exists VARCHAR2(6) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_delete';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
-- check that mapping is not being used by data approval rule
--
	OPEN  csr_chk_dar;
	FETCH csr_chk_dar INTO l_exists;
	CLOSE csr_chk_dar;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 10);
  end if;
--
IF l_exists IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0030_MAPPING_USED');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 20);
  end if;
  --
-- check that mapping is not being used by data approval rule
--
	OPEN  csr_chk_dep;
	FETCH csr_chk_dep INTO l_exists;
	CLOSE csr_chk_dep;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 30);
  end if;
--
IF l_exists IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0030_MAPPING_USED');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 40);
  end if;
  --
-- check that mapping is not being used by data approval rule
--
	OPEN  csr_chk_ret;
	FETCH csr_chk_ret INTO l_exists;
	CLOSE csr_chk_ret;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 50);
  end if;
--
IF l_exists IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0030_MAPPING_USED');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 60);
  end if;
  --
END chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_map_shd.g_rec_type
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
  -- Call all supporting business operations
  --
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  chk_name (
   p_name	=> p_rec.name
  ,p_mapping_id => p_rec.mapping_id );
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
  (p_rec                          in hxc_map_shd.g_rec_type
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
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  chk_name (
   p_name	=> p_rec.name
  ,p_mapping_id => p_rec.mapping_id );
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
  (p_rec                          in hxc_map_shd.g_rec_type
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
  chk_delete ( p_mapping_id => p_rec.mapping_id );
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_map_bus;

/
