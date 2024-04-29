--------------------------------------------------------
--  DDL for Package Body HXC_HTC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HTC_BUS" as
/* $Header: hxchtcrhi.pkb 120.2.12010000.2 2008/08/05 12:03:17 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------

g_debug boolean := hr_utility.debug_enabled;

CURSOR csr_chk_ref_integ ( p_time_category_id NUMBER ) IS
SELECT	DISTINCT ter.time_entry_rule_id
               , dfcu.application_column_name
FROM	fnd_descr_flex_column_usages dfcu
,	hxc_time_entry_rules ter
WHERE	ter.formula_id IS NOT NULL
AND
        dfcu.application_id = 809 AND
        dfcu.descriptive_flex_context_code = ter.attribute_category AND
        UPPER(dfcu.end_user_column_name) like 'TIME_CATEGORY%'
AND
	DECODE ( dfcu.application_column_name,
        'ATTRIBUTE1', ter.attribute1,
        'ATTRIBUTE2', ter.attribute2,
        'ATTRIBUTE3', ter.attribute3,
        'ATTRIBUTE4', ter.attribute4,
        'ATTRIBUTE5', ter.attribute5,
        'ATTRIBUTE6', ter.attribute6,
        'ATTRIBUTE7', ter.attribute7,
        'ATTRIBUTE8', ter.attribute8,
        'ATTRIBUTE9', ter.attribute9,
        'ATTRIBUTE10', ter.attribute10,
        'ATTRIBUTE11', ter.attribute11,
        'ATTRIBUTE12', ter.attribute12,
        'ATTRIBUTE13', ter.attribute13,
        'ATTRIBUTE14', ter.attribute14,
        'ATTRIBUTE15', ter.attribute15,
        'ATTRIBUTE16', ter.attribute16,
        'ATTRIBUTE17', ter.attribute17,
        'ATTRIBUTE18', ter.attribute18,
        'ATTRIBUTE19', ter.attribute19,
        'ATTRIBUTE20', ter.attribute20,
        'ATTRIBUTE21', ter.attribute21,
        'ATTRIBUTE22', ter.attribute22,
        'ATTRIBUTE23', ter.attribute23,
        'ATTRIBUTE24', ter.attribute24,
        'ATTRIBUTE25', ter.attribute25,
        'ATTRIBUTE26', ter.attribute26,
        'ATTRIBUTE27', ter.attribute27,
        'ATTRIBUTE28', ter.attribute28,
        'ATTRIBUTE29', ter.attribute29,
        'ATTRIBUTE30', ter.attribute30, 'zZz' ) = TO_CHAR(p_time_category_id);

g_package  varchar2(33)	:= '  hxc_htc_bus.';  -- Global package name

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
  (p_rec in hxc_htc_shd.g_rec_type
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
  IF NOT hxc_htc_shd.api_updating
      (p_time_category_id                           => p_rec.time_category_id
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
-- |-----------------------< chk_time_category>-------------------------------|
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
Procedure chk_time_category
  (
   p_time_category_id   number,
   p_time_category_name varchar2
  ) IS

  l_proc  varchar2(72);

-- cursor to check time category code is unique

CURSOR  csr_chk_time_category IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_time_categories map
	WHERE	map.time_category_name	= p_time_category_name AND
	( map.time_category_id <> p_time_category_id OR
	  p_time_category_id IS NULL ) );

 l_dup_time_category varchar2(5) := NULL;

BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_time_category';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

-- check that the time category code is unique

  OPEN  csr_chk_time_category;
  FETCH csr_chk_time_category INTO l_dup_time_category;
  CLOSE csr_chk_time_category;

IF l_dup_time_category IS NOT NULL
THEN

      hr_utility.set_message(809, 'HXC_HTC_DUPLICATE_TC');
      hr_utility.raise_error;

END IF;

--
  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_time_category;


-- ----------------------------------------------------------------------------
-- |------------------< chk_tc_ref_integrity >--------------------------------|
-- ----------------------------------------------------------------------------

-- Description:

--   SEE DESCRIPTION IN PACKAGE HEADER

-- ----------------------------------------------------------------------------

FUNCTION chk_tc_ref_integrity ( p_time_category_id NUMBER ) RETURN BOOLEAN IS

l_referenced BOOLEAN := TRUE;

l_exists r_ter_record;

BEGIN

OPEN  csr_chk_ref_integ ( p_time_category_id );
FETCH csr_chk_ref_integ INTO l_exists;

IF ( csr_chk_ref_integ%FOUND )
THEN

	l_referenced := FALSE;

END IF;

CLOSE csr_chk_ref_integ;

RETURN l_referenced;

END chk_tc_ref_integrity;


-- ----------------------------------------------------------------------------
-- |------------------< get_tc_ref_integrity_list >---------------------------|
-- ----------------------------------------------------------------------------

-- Description:

--   SEE DESCRIPTION IN PACKAGE HEADER

-- ----------------------------------------------------------------------------

FUNCTION get_tc_ref_integrity_list ( p_time_category_id NUMBER ) RETURN t_ter_table IS

l_ter_list t_ter_table;
l_index BINARY_INTEGER := 1;

BEGIN

OPEN  csr_chk_ref_integ ( p_time_category_id );
FETCH csr_chk_ref_integ INTO l_ter_list(l_index);

IF ( csr_chk_ref_integ%FOUND )
THEN

	l_index := l_index + 1;

	FETCH csr_chk_ref_integ INTO l_ter_list(l_index);

END IF;

CLOSE csr_chk_ref_integ;

RETURN l_ter_list;

END get_tc_ref_integrity_list;



-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------

-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER

-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_time_category_id  number
  ) IS

  l_proc  varchar2(72);

CURSOR csr_chk_tcc IS
SELECT 'exists'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_time_category_comps tcc
	WHERE  tcc.ref_time_category_id = p_time_category_id);

l_exists VARCHAR2(6) := NULL;

BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_delete';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

-- check that time_category is not being used by another time category

	OPEN  csr_chk_tcc;
	FETCH csr_chk_tcc INTO l_exists;
	CLOSE csr_chk_tcc;

  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc, 10);
  end if;

IF l_exists IS NOT NULL
THEN

      hr_utility.set_message(809, 'HXC_HTC_TC_IN_USE');
      hr_utility.raise_error;

END IF;

  if g_debug then
  	hr_utility.set_location('Processing: '||l_proc,20);
  end if;

-- check to see that this time category is not being referenced in any
-- of the seeded formula or other formula which have been coded using
-- the TIME_CATEGORY segment naming convention standard.

IF ( NOT hxc_htc_bus.chk_tc_ref_integrity ( p_time_category_id ) )
THEN

      hr_utility.set_message(809, 'HXC_HTC_TC_IN_USE');
      hr_utility.raise_error;

END IF;

END chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_htc_shd.g_rec_type
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
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TIME_CATEGORY_NAME'
    ,p_argument_value     => p_rec.time_category_name
    );

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OPERATOR'
    ,p_argument_value     => p_rec.operator
    );

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'DISPLAY'
    ,p_argument_value     => p_rec.display
    );

  chk_time_category (
   p_time_category_name	=> p_rec.time_category_name
  ,p_time_category_id => p_rec.time_category_id );
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
  (p_rec                          in hxc_htc_shd.g_rec_type
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
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TIME_CATEGORY_NAME'
    ,p_argument_value     => p_rec.time_category_name
    );

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OPERATOR'
    ,p_argument_value     => p_rec.operator
    );

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'DISPLAY'
    ,p_argument_value     => p_rec.display
    );

  chk_time_category (
   p_time_category_name	=> p_rec.time_category_name
  ,p_time_category_id => p_rec.time_category_id );
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
  (p_rec                          in hxc_htc_shd.g_rec_type
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
  chk_delete ( p_time_category_id => p_rec.time_category_id );
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_htc_bus;

/
