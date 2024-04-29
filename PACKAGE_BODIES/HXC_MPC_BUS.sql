--------------------------------------------------------
--  DDL for Package Body HXC_MPC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_MPC_BUS" as
/* $Header: hxcmpcrhi.pkb 120.2 2005/09/23 08:47:45 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_mpc_bus.';  -- Global package name

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
  (p_rec in hxc_mpc_shd.g_rec_type
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
  IF NOT hxc_mpc_shd.api_updating
      (p_mapping_component_id                 => p_rec.mapping_component_id
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
--   This procedure insures a valid mapping component name
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   mapping_component_id
--
-- Post Success:
--   Processing continues if the mapping component name business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the mapping component name is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_name in hxc_mapping_components.name%TYPE,
   p_mapping_component_id in hxc_mapping_components.mapping_component_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check mapping name is not duplicated
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_mapping_components mpc
	WHERE	mpc.name = p_name
	AND	( mpc.mapping_component_id <> p_mapping_component_id OR
		  p_mapping_component_id IS NULL ) );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_name';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the mapping component name has been entered
--
IF p_name IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0021_MPC_MAPPING_NAME_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that mapping component name is unique
--
  OPEN  csr_chk_name;
  FETCH csr_chk_name INTO l_error;
  CLOSE csr_chk_name;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0022_MPC_DUP_MAPPING_NAME');
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
-- |------------------------< chk_bld_blk_info_type_id >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid bld blk info type id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   bld blk info type id
--
-- Post Success:
--   Processing continues if the bld blk info type id business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the bld blk info is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_bld_blk_info_type_id
  (
   p_bld_blk_info_type_id in hxc_bld_blk_info_type_usages.bld_blk_info_type_id%TYPE
,  p_segment  in hxc_mapping_components.segment%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check building block category is valid
--
CURSOR  csr_chk_bbc IS
SELECT 'error'
FROM	sys.dual
WHERE NOT EXISTS (
	SELECT	'x'
	FROM	hxc_bld_blk_info_type_usages bb
	WHERE	bb.bld_blk_info_type_id = p_bld_blk_info_type_id );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_bld_blk_info_type_id';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

-- if the bld_blk_category is null and the segment is ATTRIBUTE_CATEGORY
-- then no validation needed

IF ( p_segment = 'ATTRIBUTE_CATEGORY' AND p_bld_blk_info_type_id IS NULL )
THEN
	null;
ELSE
--
-- check that the building block category has been entered
--
IF p_bld_blk_info_type_id IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0023_MPC_BLD_BLK_CAT_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that building block category is valid
--
  OPEN  csr_chk_bbc;
  FETCH csr_chk_bbc INTO l_error;
  CLOSE csr_chk_bbc;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0024_MPC_BLD_BLK_CAT_INVLD');
      hr_utility.raise_error;
--
END IF;

END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_bld_blk_info_type_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_segment >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid segment
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   bld_blk_info_type_id
--   segment
--
-- Post Success:
--   Processing continues if the segment business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the segment is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_segment
  (
   p_bld_blk_info_type_id IN hxc_bld_blk_info_types.bld_blk_info_type_id%TYPE
,  p_segment in hxc_mapping_components.segment%TYPE
  ) IS
--
  l_proc  varchar2(72);

-- cursor to check segment is valid

CURSOR  csr_chk_segment IS
SELECT 'ok'
FROM	fnd_descr_flex_column_usages df
,	hxc_bld_blk_info_types bbit
WHERE	bbit.bld_blk_info_type_id	= p_bld_blk_info_type_id
AND	df.descriptive_flex_context_code= bbit.bld_blk_info_type
AND     df.application_id = 809
AND	df.application_column_name	= p_segment;

 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_segment';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the segment has been entered
--
IF p_segment IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0025_MPC_SEGMENT_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

IF ( p_segment <> 'ATTRIBUTE_CATEGORY' )
THEN
	--
	-- check that segment is valid
	--
	  OPEN  csr_chk_segment;
	  FETCH csr_chk_segment INTO l_error;
	  CLOSE csr_chk_segment;
	--
	IF l_error IS NULL
	THEN
	--
	      hr_utility.set_message(809, 'HXC_0026_MPC_TYPE_INVALID');
	      hr_utility.raise_error;
	--
	END IF;
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_segment;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_composite_key >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid composite key based on Field Name, bld blk
--   info type and segment
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   Field Name
--   bld blk info type id
--   Segment
--
-- Post Success:
--   Processing continues if the composite key is unique
--
-- Post Failure:
--   An application error is raised if the composite is not unique
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_composite_key
  (
   p_object_version_number in hxc_mapping_components.object_version_number%TYPE
,  p_field_name IN hxc_mapping_components.field_name%TYPE
,  p_bld_blk_info_type_id IN hxc_mapping_components.bld_blk_info_type_id%TYPE
,  p_segment IN hxc_mapping_components.segment%TYPE
  ) IS
--
  l_proc  varchar2(72);

-- cursor to check key not duplicated

CURSOR  csr_chk_key IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_mapping_components mpc
	WHERE	mpc.field_name	= p_field_name
	AND	mpc.bld_blk_info_type_id = p_bld_blk_info_type_id
	AND	mpc.segment	= p_segment
	AND	mpc.object_version_number <> NVL( p_object_version_number, -1 ));

 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_composite_key';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--

-- check that segment is valid

  OPEN  csr_chk_key;
  FETCH csr_chk_key INTO l_error;
  CLOSE csr_chk_key;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0020_MPC_DUP_COMP_KEY');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_composite_key;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_field_name >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures a valid field name
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   field name
--
-- Post Success:
--   Processing continues if the field name business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the segment is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_field_name
  (
   p_field_name in hxc_mapping_components.field_name%TYPE
  ) IS
--
  l_proc  varchar2(72);

--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_field_name';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the field name has been entered
--
IF p_field_name IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0027_MPC_FIELD_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that the field name is not reserved
--
IF ( UPPER(p_field_name) IN ( 'RESOURCE_TYPE', 'RESOURCE_ID', 'COMMENT_TEXT', 'COMMENT' ) )
THEN
--
      hr_utility.set_message(809, 'HXC_0019_MPC_SYSTEM_FIELD_NAME');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_field_name;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_delete >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure insures referential integrity when deleting a mapping
--   component
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   mapping_component_id
--
-- Post Success:
--   Processing continues if the mapping component is not referenced
--
-- Post Failure:
--   An application error is raised if the mapping component is being used
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_mapping_component_id in hxc_mapping_components.mapping_component_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check mapping component is not referenced
--
CURSOR  csr_chk_mcu IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_mapping_comp_usages mcu
	WHERE	mcu.mapping_component_id = p_mapping_component_id );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_delete';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that mapping component is not being used
--
  OPEN  csr_chk_mcu;
  FETCH csr_chk_mcu INTO l_error;
  CLOSE csr_chk_mcu;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 10);
  end if;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0018_MPC_COMPONENT_USED');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_mpc_shd.g_rec_type
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
	chk_name ( p_name => p_rec.name,
		   p_mapping_component_id => p_rec.mapping_component_id );
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
  --
	chk_bld_blk_info_type_id ( p_bld_blk_info_type_id
					=> p_rec.bld_blk_info_type_id
			,	   p_segment => p_rec.segment );
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 20);
  end if;
  --
	chk_segment ( p_bld_blk_info_type_id	=> p_rec.bld_blk_info_type_id
		,     p_segment			=> p_rec.segment );
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 30);
  end if;
  --
	chk_field_name ( p_field_name => p_rec.field_name );
  --
	chk_composite_key ( p_object_version_number	=> p_rec.object_version_number
			,   p_field_name 		=> p_rec.field_name
			,   p_bld_blk_info_type_id	=> p_rec.bld_blk_info_type_id
			,   p_segment			=> p_rec.segment );
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 40);
  	--
  	hr_utility.set_location('Leaving:'||l_proc, 50);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hxc_mpc_shd.g_rec_type
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
	-- GPM v115.8
  	chk_delete (p_mapping_component_id => p_rec.mapping_component_id );

	chk_name ( p_name => p_rec.name,
		   p_mapping_component_id => p_rec.mapping_component_id );
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
  --
	chk_bld_blk_info_type_id ( p_bld_blk_info_type_id
					=> p_rec.bld_blk_info_type_id
			,	   p_segment => p_rec.segment );
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 20);
  end if;
  --
	chk_segment ( p_bld_blk_info_type_id	=> p_rec.bld_blk_info_type_id
		,     p_segment			=> p_rec.segment );
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 30);
  end if;
  --
	chk_field_name ( p_field_name => p_rec.field_name );
  --
	chk_composite_key ( p_object_version_number	=> p_rec.object_version_number
			,   p_field_name 		=> p_rec.field_name
			,   p_bld_blk_info_type_id	=> p_rec.bld_blk_info_type_id
			,   p_segment			=> p_rec.segment );
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 40);
  end if;
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 50);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_mpc_shd.g_rec_type
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
	chk_delete (p_mapping_component_id => p_rec.mapping_component_id );
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_mpc_bus;

/
