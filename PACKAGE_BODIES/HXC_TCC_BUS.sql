--------------------------------------------------------
--  DDL for Package Body HXC_TCC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TCC_BUS" as
/* $Header: hxctccrhi.pkb 120.3 2006/07/07 06:27:47 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_tcc_bus.';  -- Global package name

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
  (p_rec in hxc_tcc_shd.g_rec_type
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
  IF NOT hxc_tcc_shd.api_updating
      (p_time_category_comp_id                 => p_rec.time_category_comp_id
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


-- ----------------------------------------------------------------------------
-- |------------------------< chk_component_type_id >-------------------------|
-- ----------------------------------------------------------------------------

-- Description:
--   This procedure insures a valid mapping component id

-- Pre Conditions:
--   None

-- In Arguments:
--   component_type_id

-- Post Success:
--   Processing continues if the mapping component id business rules
--   have not been violated

-- Post Failure:
--   An application error is raised if the mapping component id is not valid

-- ----------------------------------------------------------------------------
Procedure chk_component_type_id
  (
   p_time_category_id      number
  ,p_time_category_comp_id number
  ,p_component_type_id     number
  ) IS

  l_proc  varchar2(72);

-- cursor to check mapping component id is valid

CURSOR	csr_chk_mpc_id IS
SELECT	'ok'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_mapping_components mpc
	WHERE	mpc.mapping_component_id = p_component_type_id );

l_ok varchar2(2) := NULL;

BEGIN

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_component_type_id';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

IF ( p_component_type_id IS NOT NULL )
THEN
	if g_debug then
		hr_utility.set_location('Processing:'||l_proc, 10);
	end if;

	-- check that mapping component id is valid

	OPEN  csr_chk_mpc_id;
	FETCH csr_chk_mpc_id INTO l_ok;
	CLOSE csr_chk_mpc_id;

	IF l_ok IS NULL
	THEN

	      hr_utility.set_message(809, 'HXC_TCC_MPC_INVALID');
	      hr_utility.raise_error;

	END IF;

END IF;

  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;

END chk_component_type_id;

-- ----------------------------------------------------------------------------
-- |------------------------< chk_ref_time_category_id >----------------------|
-- ----------------------------------------------------------------------------

-- Description:
--   This procedure insures a valid time category id and that it is unique
--   within a time category
--   Furthermore, we also need to check that this time category code's
--   components do not reference or lead back to the Parent Time Category

-- Pre Conditions:
--   None

-- In Arguments:
--   time category code

-- Post Success:
--   Processing continues if the time category code business rules
--   have not been violated

-- Post Failure:
--   An application error is raised if the time category code is not valid

-- ----------------------------------------------------------------------------
Procedure chk_time_category_code
  (
   p_time_category_id      number
  ,p_time_category_comp_id number
  ,p_ref_time_category_id  number
  ) IS

l_proc  varchar2(72);
l_error varchar2(5);
l_ok    varchar2(2);

-- cursor to check time category code is valid

CURSOR	csr_chk_time_category_code IS
SELECT	'ok'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_time_categories htc
	WHERE	htc.time_category_id = p_ref_time_category_id );

CURSOR	csr_chk_code IS
SELECT	'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_time_category_comps mpc
	WHERE	mpc.time_category_id     = p_time_category_id
	AND	mpc.ref_time_category_id = p_ref_time_category_id
	AND	( mpc.time_category_comp_id <> p_time_category_comp_id OR
		  p_time_category_comp_id IS NULL ) );

PROCEDURE chk_for_parent_category ( p_time_category_id NUMBER
				,   p_ref_time_category_id NUMBER ) IS

CURSOR	csr_get_child_comps IS
SELECT	tcc.ref_time_category_id
FROM	hxc_time_category_comps tcc
,	hxc_time_categories htc
WHERE	htc.time_category_id = p_ref_time_category_id
AND     htc.time_category_id = tcc.time_category_id
AND	tcc.ref_time_category_id IS NOT NULL;

l_ref_comp_time_cat_id hxc_time_category_comps.ref_time_category_id%TYPE;

l_proc  varchar2(72);

BEGIN
g_debug := hr_utility.debug_enabled;

if g_debug then
	l_proc := g_package||'chk_for_parent_category';
	hr_utility.set_location('Processing:'||l_proc, 5);
end if;

-- get any time category components of the child time category code
-- and make sure none are equal to the parent time category
-- for those which are not equal check that their time category
-- components do not point back to the parent.

OPEN  csr_get_child_comps;
FETCH csr_get_child_comps INTO l_ref_comp_time_cat_id;

WHILE csr_get_child_comps%FOUND
LOOP
	if g_debug then
		hr_utility.set_location('Processing:'||l_proc, 10);
	end if;

	IF ( l_ref_comp_time_cat_id = p_time_category_id )
	THEN
		hr_utility.set_message(809, 'HXC_TCC_TC_CANNOT_REF_PARENT');
	        hr_utility.raise_error;
	ELSE

		if g_debug then
			hr_utility.set_location('Processing:'||l_proc, 15);
		end if;

		chk_for_parent_category ( p_time_category_id     => p_time_category_id
					, p_ref_time_category_id => l_ref_comp_time_cat_id );

	END IF;

	FETCH csr_get_child_comps INTO l_ref_comp_time_cat_id;

END LOOP;

CLOSE csr_get_child_comps;

if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 20);
end if;

END chk_for_parent_category;



BEGIN -- chk_time_category_code

  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_time_category_code';
  	hr_utility.set_location('Entering:'||l_proc, 10);
  end if;

IF ( p_ref_time_category_id IS NOT NULL )
THEN

	if g_debug then
		hr_utility.set_location('Processing:'||l_proc, 20);
	end if;

	-- check that time category code is valid

	OPEN  csr_chk_time_category_code;
	FETCH csr_chk_time_category_code INTO l_ok;
	CLOSE csr_chk_time_category_code;

	if g_debug then
		hr_utility.set_location('Processing:'||l_proc, 30);
	end if;

	IF l_ok IS NULL
	THEN

	      hr_utility.set_message(809, 'HXC_TCC_TC_INVALID');
	      hr_utility.raise_error;

	END IF;

	if g_debug then
		hr_utility.set_location('Processing:'||l_proc, 40);
	end if;

	-- check that time category code is unique

	  OPEN  csr_chk_code;
	  FETCH csr_chk_code INTO l_error;
	  CLOSE csr_chk_code;

	IF l_error IS NOT NULL
	THEN
	  if g_debug then
	  	hr_utility.set_location('Leaving:'||l_proc, 60);
	  end if;

	      hr_utility.set_message(809, 'HXC_TCC_TC_ALREADY_USED');
	      hr_utility.raise_error;

	END IF;

	-- check to see if the time category code components include
	-- any other time categories and make sure none of these are
	-- or lead back to the time category code.

	chk_for_parent_category ( p_time_category_id      => p_time_category_id
				, p_ref_time_category_id  => p_ref_time_category_id );

  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 70);
  end if;
END IF;

END chk_time_category_code;

-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_value_id >------------------------------|
-- ----------------------------------------------------------------------------

-- Description:
--   This procedure insures a valid value id

-- Pre Conditions:
--   None

-- In Arguments:
--   time category code

-- Post Success:
--   Processing continues if the value id business rules
--   have not been violated

-- Post Failure:
--   An application error is raised if the vlaue id is not valid

-- ----------------------------------------------------------------------------
Procedure chk_value_id
  (
   p_flex_value_set_id number,
   p_value_id          varchar2
  ) IS

  l_proc  varchar2(72);

 l_description varchar2(150) := NULL;

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( p_value_id IS NOT NULL )
THEN

	if g_debug then
		l_proc := g_package||'chk_value_id';
		hr_utility.set_location('Entering:'||l_proc, 5);
	end if;

	l_description := hxc_time_category_utils_pkg.get_flex_value (p_flex_value_set_id, p_value_id );

	IF ( l_description IS NULL )
	THEN
		      hr_utility.set_message(809, 'HXC_TCC_VALUE_INVALID');
		      hr_utility.raise_error;
	END IF;

	if g_debug then
		hr_utility.set_location('Leaving:'||l_proc, 20);
	end if;

END IF;

END chk_value_id;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_mpc_value_id >------------------------------|
-- ----------------------------------------------------------------------------

-- Description:
--   This procedure insures that the mapping component and value combo
--   are not duplicated with a category

-- Pre Conditions:
--   None

-- In Arguments:
--   mapping component id
--   value id
--   flex value set id

-- Post Success:
--   Processing continues if the value id business rules
--   have not been violated

-- Post Failure:
--   An application error is raised if the vlaue id is not valid

-- ----------------------------------------------------------------------------
Procedure chk_mpc_value_id
  (
   p_time_category_id  number,
   p_time_category_comp_id number,
   p_flex_value_set_id number,
   p_value_id          varchar2,
   p_component_type_id number,
   p_type              varchar2
  ) IS

--
-- cursor to check mapping component is not duplicated
--
CURSOR  csr_chk_mpc IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_time_category_comps mpc
	WHERE	mpc.time_category_id     = p_time_category_id
        AND     mpc.component_type_id    = p_component_type_id
        AND     mpc.type                 = p_type
        AND     (
                 (  mpc.type = 'MC' AND
                  ( mpc.value_id             = p_value_id ) OR
                  ( p_value_id IS NULL AND mpc.value_id IS NULL )
                 )
		OR
		 ( mpc.type = 'MC_VS' AND
	           mpc.flex_value_set_id = p_flex_value_set_id )
                OR
                ( mpc.type NOT IN ( 'MC_VS', 'MC' ) )
                )
	AND	( mpc.time_category_comp_id <> p_time_category_comp_id OR
		  p_time_category_comp_id IS NULL ) );

 l_error varchar2(5) := NULL;

  l_proc  varchar2(72);

 l_description varchar2(150) := NULL;

BEGIN

g_debug := hr_utility.debug_enabled;

-- first of all check to see that mapping component and value combo
-- are unique

	  OPEN  csr_chk_mpc;
	  FETCH csr_chk_mpc INTO l_error;
	  CLOSE csr_chk_mpc;

	  if g_debug then
	  	l_proc := g_package||'chk_mpc_value_id';
	  	hr_utility.set_location('Entering:'||l_proc, 10);
	  end if;

	IF l_error IS NOT NULL
	THEN

	      hr_utility.set_message(809, 'HXC_TCC_MPC_VALUE_ALREADY_USED');
	      hr_utility.raise_error;

	END IF;

  if g_debug then
  	hr_utility.set_location('Entering:'||l_proc, 15);
  end if;

END chk_mpc_value_id;

-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_flex_Value_set_id >--------------------|
-- ----------------------------------------------------------------------------

-- Description:
--   This procedure insures a valid flex value set id

-- Pre Conditions:
--   None

-- In Arguments:
--   p_flex_value_set_id
--   p_value_id
--   p_type

-- Post Success:
--   Processing continues if the flex value set id business rules
--   have not been violated

-- Post Failure:
--   An application error is raised if the flex vlaue set id is not valid

-- ----------------------------------------------------------------------------
Procedure chk_flex_value_set_id
  (
   p_flex_value_set_id number
,  p_value_id          varchar2
,  p_type              varchar2
  ) IS

CURSOR csr_chk_flex_value_set_id IS
SELECT 'ok'
FROM   dual
WHERE EXISTS (
select 1
FROM   fnd_flex_value_sets
WHERE  flex_value_set_id = p_flex_value_set_id );

  l_proc  varchar2(72);

 l_ok varchar2(2) := NULL;

BEGIN

g_debug := hr_utility.debug_enabled;

IF ( p_flex_value_set_id IS NULL AND p_value_id IS NOT NULL and p_type IN ('MC','MC_VS') )
THEN

      hr_utility.set_message(809, 'HXC_TCC_FLEX_VALUE_SET_ID_MAND');
      hr_utility.raise_error;

ELSIF ( p_flex_value_set_id IN ( -1,-2 ) )
THEN

	-- -1 when ATTRIBUTE_CATEGORY mapping component chosen

	l_ok := 'ok';

ELSIF ( ( p_type = 'MC' AND p_value_id IS NOT NULL )
     OR ( p_type = 'MC_VS' ) )
THEN

	OPEN  csr_chk_flex_value_set_id;
	FETCH csr_chk_flex_value_set_id INTO l_ok;
	CLOSE csr_chk_flex_value_set_id;

ELSE

	l_ok := 'ok';

END IF;

IF l_ok IS NULL
THEN

  if g_debug then
  	l_proc := g_package||'chk_flex_value_set_id';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

      hr_utility.set_message(809, 'HXC_TCC_FLEX_VALUE_SET_ID_INV');
      hr_utility.raise_error;

END IF;

  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;

END chk_flex_value_set_id;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_tcc_shd.g_rec_type
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

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

	IF ( p_rec.component_type_id IS NOT NULL AND p_rec.type = 'MC' )
	THEN
        if g_debug then
        	hr_utility.set_location('Processing:'||l_proc, 20);
        end if;

	chk_component_type_id ( p_component_type_id => p_rec.component_type_id
                  ,p_time_category_id      => p_rec.time_category_id
	          ,p_time_category_comp_id => p_rec.time_category_comp_id );

	chk_flex_value_set_id ( p_flex_value_set_id => p_rec.flex_value_set_id
                              , p_value_id          => p_rec.value_id
                              , p_type              => p_rec.type );

	chk_value_id ( p_flex_value_set_id => p_rec.flex_value_set_id,
                       p_value_id          => p_rec.value_id );

	chk_mpc_value_id ( p_time_category_id      => p_rec.time_category_id,
                           p_time_category_comp_id => p_rec.time_category_comp_id,
                           p_flex_value_set_id => p_rec.flex_value_set_id,
                           p_value_id          => p_rec.value_id,
                           p_component_type_id => p_rec.component_type_id,
                           p_type              => p_rec.type );

	ELSIF ( p_rec.type = 'TC' )
	THEN

        if g_debug then
        	hr_utility.set_location('Processing:'||l_proc, 30);
        end if;

	chk_time_category_code ( p_ref_time_category_id => p_rec.ref_time_category_id
                  ,p_time_category_id      => p_rec.time_category_id
	          ,p_time_category_comp_id => p_rec.time_category_comp_id );

        ELSIF ( p_rec.type = 'AN' ) --Fix for bug 4336172
	THEN

        if g_debug then
        	hr_utility.set_location('Processing:'||l_proc, 35);
        end if;

	chk_mpc_value_id ( p_time_category_id      => p_rec.time_category_id,
                           p_time_category_comp_id => p_rec.time_category_comp_id,
                           p_flex_value_set_id => p_rec.flex_value_set_id,
                           p_value_id          => p_rec.value_id,
                           p_component_type_id => p_rec.component_type_id,
                           p_type              => p_rec.type );

	END IF;

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 40);
  end if;

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hxc_tcc_shd.g_rec_type
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

  -- No business group context.  HR_STANDARD_LOOKUPS used for validation.
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.

  -- Call all supporting business operations

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

	IF ( p_rec.ref_time_category_id IS NOT NULL )
	THEN
        if g_debug then
        	hr_utility.set_location('Processing:'||l_proc, 20);
        end if;

	chk_time_category_code ( p_ref_time_category_id => p_rec.ref_time_category_id
                  ,p_time_category_id      => p_rec.time_category_id
	          ,p_time_category_comp_id => p_rec.time_category_comp_id );

	ELSIF ( p_rec.type = 'MC' )
	THEN

        if g_debug then
        	hr_utility.set_location('Processing:'||l_proc, 30);
        end if;

	chk_component_type_id ( p_component_type_id => p_rec.component_type_id
                  ,p_time_category_id      => p_rec.time_category_id
	          ,p_time_category_comp_id => p_rec.time_category_comp_id );

	chk_flex_value_set_id ( p_flex_value_set_id => p_rec.flex_value_set_id
                              , p_value_id          => p_rec.value_id
                              , p_type              => p_rec.type );

	chk_value_id ( p_flex_value_set_id => p_rec.flex_value_set_id,
                       p_value_id          => p_rec.value_id );

	chk_mpc_value_id ( p_time_category_id      => p_rec.time_category_id,
                           p_time_category_comp_id => p_rec.time_category_comp_id,
                           p_flex_value_set_id => p_rec.flex_value_set_id,
                           p_value_id          => p_rec.value_id,
                           p_component_type_id => p_rec.component_type_id,
                           p_type              => p_rec.type );
	END IF;

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 40);
  end if;

  chk_non_updateable_args
    (p_rec              => p_rec
    );

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 50);
  end if;
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_tcc_shd.g_rec_type
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

  -- Call all supporting business operations

  IF ( p_rec.type IN ( 'AN', 'MC_VS' ) )
  THEN
	hxc_time_category_utils_pkg.delete_time_category_comp_sql ( p_rec );
  END IF;

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_tcc_bus;

/
