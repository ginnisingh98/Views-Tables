--------------------------------------------------------
--  DDL for Package Body HXC_HTS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HTS_BUS" as
/* $Header: hxchtsrhi.pkb 120.2 2005/09/23 07:49:02 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_hts_bus.';  -- Global package name

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
  (p_effective_date               in date
  ,p_rec in hxc_hts_shd.g_rec_type
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
  IF NOT hxc_hts_shd.api_updating
      (p_time_source_id                       => p_rec.time_source_id
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
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   time_source_id
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
   p_name       in hxc_time_sources.name%TYPE
  ,p_time_source_id in hxc_time_sources.time_source_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check name is unique
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM	sys.dual
WHERE EXISTS (
	SELECT	'x'
	FROM	hxc_time_sources tr
	WHERE	tr.name	= p_name
	AND	( tr.time_source_id <> p_time_source_id
		OR p_time_source_id IS NULL) );
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
      hr_utility.set_message(809, 'HXC_0062_HTS_NAME_MAND');
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
      hr_utility.set_message(809, 'HXC_0063_HTS_DUP_NAME');
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
--
-- Description:
--
--   SEE DESCRIPTION IN PACKAGE HEADER
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   time_source_id
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
   p_time_source_id in hxc_time_sources.time_source_id%TYPE
  ) IS

l_used_elsewhere VARCHAR2(1) := 'N';

CURSOR csr_chk_dep IS
SELECT 'Y'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_deposit_processes dep
	WHERE  dep.time_source_id = p_time_source_id);

BEGIN -- chk_delete

OPEN  csr_chk_dep;
FETCH csr_chk_dep INTO l_used_elsewhere;
CLOSE csr_chk_dep;

IF ( l_used_elsewhere = 'Y' )
THEN
      hr_utility.set_message(809, 'HXC_0064_HTS_IN_USE');
      hr_utility.raise_error;
END IF;

END chk_delete;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_hts_shd.g_rec_type
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
  hxc_hts_bus.chk_name ( p_name	=> p_rec.name
			,p_time_source_id => p_rec.time_source_id );

  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
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
  (p_effective_date               in date
  ,p_rec                          in hxc_hts_shd.g_rec_type
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
  hxc_hts_bus.chk_name ( p_name	=> p_rec.name
			,p_time_source_id => p_rec.time_source_id );
  --
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
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
  (p_rec                          in hxc_hts_shd.g_rec_type
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
  hxc_hts_bus.chk_delete ( p_time_source_id => p_rec.time_source_id );

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_hts_bus;

/
