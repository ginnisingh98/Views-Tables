--------------------------------------------------------
--  DDL for Package Body HXC_LKR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LKR_BUS" as
/* $Header: hxclockrulesrhi.pkb 120.2 2005/09/23 07:58:43 nissharm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_lkr_bus.';  -- Global package name

g_debug boolean := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_locker_type_owner_id        number         default null;
g_locker_type_requestor_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_locker_type_owner_id                 in number
  ,p_locker_type_requestor_id             in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_locking_rules and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf pbg
         , hxc_locking_rules lkr
      --   , EDIT_HERE table_name(s) 333
     where lkr.locker_type_owner_id = p_locker_type_owner_id
       and lkr.locker_type_requestor_id = p_locker_type_requestor_id;
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
    ,p_argument           => 'locker_type_owner_id'
    ,p_argument_value     => p_locker_type_owner_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'locker_type_requestor_id'
    ,p_argument_value     => p_locker_type_requestor_id
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
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
  (p_locker_type_owner_id                 in     number
  ,p_locker_type_requestor_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_locking_rules and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , hxc_locking_rules lkr
      --   , EDIT_HERE table_name(s) 333
     where lkr.locker_type_owner_id = p_locker_type_owner_id
       and lkr.locker_type_requestor_id = p_locker_type_requestor_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72);
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
    ,p_argument           => 'locker_type_owner_id'
    ,p_argument_value     => p_locker_type_owner_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'locker_type_requestor_id'
    ,p_argument_value     => p_locker_type_requestor_id
    );
  --
  if (( nvl(hxc_lkr_bus.g_locker_type_owner_id, hr_api.g_number)
       = p_locker_type_owner_id)
  and ( nvl(hxc_lkr_bus.g_locker_type_requestor_id, hr_api.g_number)
       = p_locker_type_requestor_id)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_lkr_bus.g_legislation_code;
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
    hxc_lkr_bus.g_locker_type_owner_id        := p_locker_type_owner_id;
    hxc_lkr_bus.g_locker_type_requestor_id    := p_locker_type_requestor_id;
    hxc_lkr_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hxc_lkr_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hxc_lkr_shd.api_updating
      (p_locker_type_owner_id              => p_rec.locker_type_owner_id
      ,p_locker_type_requestor_id          => p_rec.locker_type_requestor_id
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
-- |-----------------------< chk_owner_requestor_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid owner and requestor ID combination
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
--   Processing continues if the owner and requester ID combination is not existing
--
-- Post Failure:
--   An application error is raised if the owner,requestor combination ID is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_owner_requestor_id
  (
   p_owner_id      	   in hxc_locking_rules.locker_type_owner_id%TYPE
  ,p_requestor_id      	   in hxc_locking_rules.locker_type_requestor_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check if the owner ID and requestor ID are not existing
--
CURSOR  csr_chk_id IS
SELECT 'error'
FROM    hxc_locking_rules
WHERE   locker_type_owner_id = p_owner_id
AND     locker_type_requestor_id = p_requestor_id;


l_dup_id varchar2(5) := NULL;

BEGIN
  g_debug := hr_utility.debug_enabled;

  if g_debug then
  	l_proc := g_package||'chk_locker_process_type';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

-- check that the combination of ID has been entered

IF p_owner_id IS NULL THEN
      hr_utility.set_message(809, 'HXC_OWNER_ID_REQUIRED');
      hr_utility.raise_error;
END IF;

IF p_requestor_id IS NULL THEN
      hr_utility.set_message(809, 'HXC_REQUESTOR_ID_REQUIRED');
      hr_utility.raise_error;
END IF;

  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

-- check that the name is unique

  OPEN  csr_chk_id;
  FETCH csr_chk_id INTO l_dup_id;
  CLOSE csr_chk_id;
--
IF l_dup_id IS NOT NULL THEN
      hr_utility.set_message(809, 'HXC_OWNER_REQUESTOR_EXISTS');
      hr_utility.raise_error;
END IF;

  if g_debug then
  	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;

END chk_owner_requestor_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_lkr_shd.g_rec_type
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

  chk_owner_requestor_id
  (p_owner_id      	=>p_rec.locker_type_owner_id
  ,p_requestor_id	=>p_rec.locker_type_requestor_id
  );

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
  (p_rec                          in hxc_lkr_shd.g_rec_type
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
  (p_rec                          in hxc_lkr_shd.g_rec_type
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
  null;
  --
  -- Call all supporting business operations
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_lkr_bus;

/
