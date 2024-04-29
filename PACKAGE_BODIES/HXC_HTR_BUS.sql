--------------------------------------------------------
--  DDL for Package Body HXC_HTR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HTR_BUS" as
/* $Header: hxchtrrhi.pkb 120.2 2005/09/23 07:45:11 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_htr_bus.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
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
--   time_recipient_id
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
   p_name       in hxc_time_recipients.name%TYPE
  ,p_time_recipient_id in hxc_time_recipients.time_recipient_id%TYPE
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
	FROM	hxc_time_recipients tr
	WHERE	tr.name	= p_name
	AND	( tr.time_recipient_id <> p_time_recipient_id
		OR p_time_recipient_id IS NULL) );
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
      hr_utility.set_message(809, 'HXC_0065_HTR_NAME_MAND');
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
      hr_utility.set_message(809, 'HXC_0066_HTR_DUP_NAME');
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
-- |-----------------------< chk_application_id >-----------------------------|
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
--   application_id
--
-- Post Success:
--   Processing continues if the name business rules have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_application_id
  (
   p_application_id in hxc_time_recipients.application_id%TYPE
  ) IS

l_invalid_id VARCHAR2(1) := 'Y';

CURSOR csr_chk_app_id IS
SELECT	'N'
FROM	fnd_application
WHERE	application_id	= p_application_id;

BEGIN

OPEN  csr_chk_app_id;
FETCH csr_chk_app_id INTO l_invalid_id;
CLOSE csr_chk_app_id;

IF ( l_invalid_id = 'Y' )
THEN
      hr_utility.set_message(809, 'HXC_0068_HTR_APP_ID_INVLD');
      hr_utility.raise_error;
END IF;
--
END chk_application_id;
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
--   time_recipient_id
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
   p_time_recipient_id in hxc_time_recipients.time_recipient_id%TYPE
  ) IS

l_used_elsewhere VARCHAR2(1) := 'N';

CURSOR csr_chk_ret IS
SELECT 'Y'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_retrieval_processes ret
	WHERE  ret.time_recipient_id = p_time_recipient_id);

CURSOR csr_chk_rrc IS
SELECT 'Y'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_retrieval_rule_comps rrc
	WHERE  rrc.time_recipient_id = p_time_recipient_id);

CURSOR csr_chk_apc IS
SELECT 'Y'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_approval_period_comps apc
	WHERE  apc.time_recipient_id = p_time_recipient_id);

CURSOR csr_chk_daru IS
SELECT 'Y'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_data_app_rule_usages daru
	WHERE  daru.time_recipient_id = p_time_recipient_id);

CURSOR csr_chk_ac IS
SELECT 'Y'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_approval_comps ac
	WHERE  ac.time_recipient_id = p_time_recipient_id);

CURSOR csr_chk_asc IS
SELECT 'Y'
FROM	sys.dual
WHERE	EXISTS (
	SELECT	'x'
	FROM   hxc_application_set_comps_v appsc
	WHERE  appsc.time_recipient_id = p_time_recipient_id);

BEGIN -- chk_delete

OPEN  csr_chk_ret;
FETCH csr_chk_ret INTO l_used_elsewhere;
CLOSE csr_chk_ret;

IF ( l_used_elsewhere = 'Y' )
THEN
      hr_utility.set_message(809, 'HXC_0069_HTR_IN_USE');
      hr_utility.raise_error;
END IF;

OPEN  csr_chk_rrc;
FETCH csr_chk_rrc INTO l_used_elsewhere;
CLOSE csr_chk_rrc;

IF ( l_used_elsewhere = 'Y' )
THEN
      hr_utility.set_message(809, 'HXC_0069_HTR_IN_USE');
      hr_utility.raise_error;
END IF;

OPEN  csr_chk_apc;
FETCH csr_chk_apc INTO l_used_elsewhere;
CLOSE csr_chk_apc;

IF ( l_used_elsewhere = 'Y' )
THEN
      hr_utility.set_message(809, 'HXC_0069_HTR_IN_USE');
      hr_utility.raise_error;
END IF;

OPEN  csr_chk_daru;
FETCH csr_chk_daru INTO l_used_elsewhere;
CLOSE csr_chk_daru;

IF ( l_used_elsewhere = 'Y' )
THEN
      hr_utility.set_message(809, 'HXC_0069_HTR_IN_USE');
      hr_utility.raise_error;
END IF;

OPEN  csr_chk_ac;
FETCH csr_chk_ac INTO l_used_elsewhere;
CLOSE csr_chk_ac;

IF ( l_used_elsewhere = 'Y' )
THEN
      hr_utility.set_message(809, 'HXC_0069_HTR_IN_USE');
      hr_utility.raise_error;
END IF;

OPEN  csr_chk_asc;
FETCH csr_chk_asc INTO l_used_elsewhere;
CLOSE csr_chk_asc;

IF ( l_used_elsewhere = 'Y' )
THEN
      hr_utility.set_message(809, 'HXC_0069_HTR_IN_USE');
      hr_utility.raise_error;
END IF;

END chk_delete;

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
  ,p_rec in hxc_htr_shd.g_rec_type
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
  IF NOT hxc_htr_shd.api_updating
      (p_time_recipient_id                    => p_rec.time_recipient_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
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
  (p_effective_date               in date
  ,p_rec                          in hxc_htr_shd.g_rec_type
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
  hxc_htr_bus.chk_name ( p_name	=> p_rec.name
			,p_time_recipient_id => p_rec.time_recipient_id );

  hxc_htr_bus.chk_application_id ( p_application_id => p_rec.application_id );
  --
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
  ,p_rec                          in hxc_htr_shd.g_rec_type
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
  hxc_htr_bus.chk_name ( p_name	=> p_rec.name
			,p_time_recipient_id => p_rec.time_recipient_id );

  hxc_htr_bus.chk_application_id ( p_application_id => p_rec.application_id );
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
  (p_rec                          in hxc_htr_shd.g_rec_type
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
  hxc_htr_bus.chk_delete ( p_time_recipient_id => p_rec.time_recipient_id );

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_htr_bus;

/
