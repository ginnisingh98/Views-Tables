--------------------------------------------------------
--  DDL for Package Body HXC_LCK_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LCK_BUS" as
/* $Header: hxclocktypesrhi.pkb 120.2 2005/09/23 08:08:21 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_lck_bus.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_locker_type_id              number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_locker_type_id                       in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_locker_types and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select distinct pbg.security_group_id
    from per_business_groups_perf pbg
         , hxc_locker_types lck
      --   , EDIT_HERE table_name(s) 333
     where lck.locker_type_id = p_locker_type_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72);
  l_legislation_code  varchar2(150);
  --
begin
  g_debug := hr_utility.debug_enabled;

  --
  if g_debug then
  	l_proc :=  g_package||'set_security_group_id';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'locker_type_id'
    ,p_argument_value     => p_locker_type_id
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
    --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );

  end if;
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
  (p_locker_type_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_locker_types and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , hxc_locker_types lck
      --   , EDIT_HERE table_name(s) 333
     where lck.locker_type_id = p_locker_type_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72) ;
  --
Begin
  g_debug := hr_utility.debug_enabled;

  --
  if g_debug then
  	l_proc :=  g_package||'return_legislation_code';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'locker_type_id'
    ,p_argument_value     => p_locker_type_id
    );
  --
  if ( nvl(hxc_lck_bus.g_locker_type_id, hr_api.g_number)
       = p_locker_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_lck_bus.g_legislation_code;
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
    hxc_lck_bus.g_locker_type_id              := p_locker_type_id;
    hxc_lck_bus.g_legislation_code  := l_legislation_code;
  end if;
  if g_debug then
  	hr_utility.set_location(' Leaving:'|| l_proc, 40);
  end if;
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in hxc_lck_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hxc_lck_shd.api_updating
      (p_locker_type_id                    => p_rec.locker_type_id
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
End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_locker_process_type >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid process Type and Locker Type
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   object_version_number
--   timecard_field
--
-- Post Success:
--   Processing continues if the process Type and locker Type are not existing
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_locker_process_type
  (
   p_locker_type      	   in hxc_locker_types.locker_type%TYPE
  ,p_process_type      	   in hxc_locker_types.process_type%TYPE
  ,p_locker_type_id        in hxc_locker_types.locker_type_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check if the process Type and locker Type are not existing
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM    hxc_locker_types
WHERE   locker_type = p_locker_type
AND	process_type   = p_process_type
AND     locker_type_id   <> NVL(p_locker_type_id,9.99E125);

l_dup_name varchar2(5) := NULL;

BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_locker_process_type';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

-- check that the name has been entered

IF p_locker_type IS NULL THEN
      hr_utility.set_message(809, 'HXC_LOCKER_TYPE_REQUIRED');
      hr_utility.raise_error;
END IF;

IF p_process_type IS NULL THEN
      hr_utility.set_message(809, 'HXC_PROCESS_TYPE_REQUIRED');
      hr_utility.raise_error;
END IF;

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

-- check that the name is unique

  OPEN  csr_chk_name;
  FETCH csr_chk_name INTO l_dup_name;
  CLOSE csr_chk_name;
--
IF l_dup_name IS NOT NULL THEN
      hr_utility.set_message(809, 'HXC_LOCKER_PROCESS_TYPE_EXISTS');
      hr_utility.raise_error;
END IF;

  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;

END chk_locker_process_type;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure carries out refential integrity checks
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   locker_type_id
--
-- Post Success:
--   Processing continues if the locker_type_id is  not being used
--
-- Post Failure:
--   An application error is raised if the locker_type_id is  being used.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_locker_type_id in hxc_locker_types.locker_type_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check if the process Type and locker Type are used in hxc_locks.
--
CURSOR  csr_chk_id_exists IS
SELECT 'error'
FROM    hxc_locks
WHERE   locker_type_id = p_locker_type_id;

CURSOR  csr_chk_seed_id_exists IS
SELECT 'error'
FROM    hxc_locking_rules
WHERE   locker_type_owner_id = p_locker_type_id OR locker_type_requestor_id=p_locker_type_id;


l_exists_id VARCHAR2(6) := NULL;
l_seed_exists_id VARCHAR2(6):=NULL;
--
BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_delete';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
--check that locker_type_id is not being used
--

  if g_debug then
  	hr_utility.set_location('Calling num_hierarchy_occurances: '||l_proc, 10);
  end if;

  OPEN  csr_chk_id_exists;
  FETCH csr_chk_id_exists INTO l_exists_id;
  CLOSE csr_chk_id_exists;
--
IF l_exists_id IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_LOCKER_PROCESS_TYPE_USED');
      hr_utility.raise_error;
--
END IF;

  OPEN  csr_chk_seed_id_exists;
  FETCH csr_chk_seed_id_exists INTO l_seed_exists_id;
  CLOSE csr_chk_seed_id_exists;

IF l_seed_exists_id IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_LOCKER_PROCESS_TYPE_USED');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
END chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_lck_shd.g_rec_type
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

--call the business validations

  chk_locker_process_type
  (p_locker_type	=> p_rec.locker_type
  ,p_process_type	=> p_rec.process_type
  ,p_locker_type_id	=> p_rec.locker_type_id
  ) ;
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
  -- Validate Dependent Attributes
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
  (p_rec                          in hxc_lck_shd.g_rec_type
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

  chk_locker_process_type
  (p_locker_type	=> p_rec.locker_type
  ,p_process_type	=> p_rec.process_type
  ,p_locker_type_id	=> p_rec.locker_type_id
  ) ;
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
  -- Validate Dependent Attributes
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
  (p_rec                          in hxc_lck_shd.g_rec_type
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
  chk_delete
  (p_locker_type_id => p_rec.locker_type_id);
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_lck_bus;

/
