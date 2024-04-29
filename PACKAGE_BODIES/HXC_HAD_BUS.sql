--------------------------------------------------------
--  DDL for Package Body HXC_HAD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAD_BUS" as
/* $Header: hxchadrhi.pkb 120.2 2005/09/23 10:40:21 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_had_bus.';  -- Global package name
g_debug	boolean	:=hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_alias_definition_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_alias_definition_id                  in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_alias_definitions and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hxc_alias_definitions had
      --   , EDIT_HERE table_name(s) 333
     where had.alias_definition_id = p_alias_definition_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72);
  --
begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc  :=  g_package||'set_security_group_id';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'alias_definition_id'
    ,p_argument_value     => p_alias_definition_id
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
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
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
  (p_alias_definition_id                  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_alias_definitions and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , hxc_alias_definitions had
      --   , EDIT_HERE table_name(s) 333
     where had.alias_definition_id = p_alias_definition_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72) ;
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc :=  g_package||'return_legislation_code';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'alias_definition_id'
    ,p_argument_value     => p_alias_definition_id
    );
  --
  if ( nvl(hxc_had_bus.g_alias_definition_id, hr_api.g_number)
       = p_alias_definition_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_had_bus.g_legislation_code;
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
    hxc_had_bus.g_alias_definition_id := p_alias_definition_id;
    hxc_had_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hxc_had_shd.g_rec_type
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
  IF NOT hxc_had_shd.api_updating
      (p_alias_definition_id                  => p_rec.alias_definition_id
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
--   This procedure ensures a valid alias definition name
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
--   Processing continues if the alias definition name business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_name       	   in hxc_alias_definitions.alias_definition_name%TYPE
  ,p_ovn        	   in hxc_alias_definitions.object_version_number%TYPE
  ,p_alias_definition_id   in hxc_alias_definitions.timecard_field%TYPE
  ,p_business_group_id     in hxc_alias_definitions.business_group_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check alias definition name does not overlap
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM    hxc_alias_definitions had,
        hxc_alias_definitions_tl hadtl
WHERE   hadtl.alias_definition_name = p_name
AND	hadtl.alias_definition_id   = had.alias_definition_id
and     hadtl.language = USERENV('LANG')
AND     had.alias_definition_id   <> NVL(p_alias_definition_id,9.99E125)
AND     had.object_version_number <> NVL(p_ovn, -1)
AND     had.business_group_id 	  =  p_business_group_id;
--
 l_dup_name varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
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
      hr_utility.set_message(809, 'HXC_ALIAS_NAME_DEFN_MAND');
      hr_utility.raise_error;
--
END IF;
--

--IF p_tc_field IS NULL
--THEN
--
--      hr_utility.set_message(809, 'HXC_ALIAS_TC_FIELD_MAND');
--      hr_utility.raise_error;
--
--END IF;

--
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
      hr_utility.set_message(809, 'HXC_ALIAS_NAME_DEFN_UNIQUE');
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
--   This procedure carries out refential integrity checks
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   alias_definition_id
--
-- Post Success:
--   Processing continues if the Timecard Alias is not being used
--
-- Post Failure:
--   An application error is raised if the Timecard Alias is being used.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_alias_definition_id in hxc_alias_definitions.alias_definition_id%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
l_exists_attribute1 VARCHAR2(6) := NULL;
l_exists_attribute2 VARCHAR2(6) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_delete';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
--check that Timecard Alias is not being used
--

  if g_debug then
	hr_utility.set_location('Calling num_hierarchy_occurances: '||l_proc, 10);
  end if;
  l_exists_attribute1 := HXC_PREFERENCE_EVALUATION.num_hierarchy_occurances
                         ('TC_W_TCRD_ALIASES'
                          ,1
                          ,TO_CHAR(p_alias_definition_id));
  l_exists_attribute2 := HXC_PREFERENCE_EVALUATION.num_hierarchy_occurances
                         ('TC_W_TCRD_ALIASES'
                          ,2
                          ,TO_CHAR(p_alias_definition_id));
  if g_debug then
	hr_utility.set_location('After calling num_hierarchy_occurances:'||l_proc,20);
  end if;

--
IF l_exists_attribute1 <> 0 OR l_exists_attribute2 <> 0 THEN
--
      hr_utility.set_message(809, 'HXC_HEG_ALT_NAME_IN_USE');
      hr_utility.raise_error;
--
END IF;

  hxc_time_category_utils_pkg.alias_definition_ref_int_chk ( p_alias_definition_id );

--
  if g_debug then
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
END chk_delete;

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
    g_debug:=hr_utility.debug_enabled;
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
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_context >---------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid alias context name
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   context
--
-- Post Success:
--   Processing continues if the alias context name business rules
--   have not been violated
--
-- Post Failure:
--   An application error is raised if the context name is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_context
  (
   p_context_name       in hxc_alias_definitions.alias_context_code%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check alias definition name does not overlap
--
CURSOR  csr_chk_context IS
SELECT 'success'
FROM   fnd_descr_flex_contexts_vl c,
      fnd_application a
where c.descriptive_flexfield_name = 'OTC Aliases'
and   a.application_short_name = 'HXC'
and   a.application_id = c.application_id
and   c.descriptive_flex_context_code = p_context_name ;

--
 l_context_name varchar2(7) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_context';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- check that the name has been entered
--
IF p_context_name IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_ALIAS_CONTEXT_MAND');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- check that the name is unique
--
  OPEN  csr_chk_context;
  FETCH csr_chk_context INTO l_context_name;
  CLOSE csr_chk_context;
--
IF l_context_name IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_ALIAS_CONTEXT_INVALID');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 20);
  end if;
--
END chk_context;
-- ----------------------------------------------------------------------------
-- |---------------------------< n >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_had_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'insert_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
chk_name (
   p_name           		=> p_rec.alias_definition_name
  ,p_ovn            		=> p_rec.object_version_number
  ,p_alias_definition_id        => p_rec.alias_definition_id
  ,p_business_group_id		=> p_rec.business_group_id
  );
  --
/*chk_context
  (
   p_context_name  => p_rec.alias_context_code
  ); */
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
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
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hxc_had_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'update_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
chk_name (
   p_name           		=> p_rec.alias_definition_name
  ,p_ovn            		=> p_rec.object_version_number
  ,p_alias_definition_id        => p_rec.alias_definition_id
  ,p_business_group_id		=> p_rec.business_group_id
  );
  --
/*chk_context
  (
   p_context_name  => p_rec.alias_context_code
  );  */
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  chk_non_updateable_args
    (p_rec              => p_rec
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
  (p_rec                          in hxc_had_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72);
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'delete_validate';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  chk_delete
  ( p_alias_definition_id => p_rec.alias_definition_id);
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_had_bus;

/
