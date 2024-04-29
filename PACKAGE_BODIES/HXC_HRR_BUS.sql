--------------------------------------------------------
--  DDL for Package Body HXC_HRR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HRR_BUS" as
/* $Header: hxchrrrhi.pkb 120.3 2005/09/23 10:43:47 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_hrr_bus.';  -- Global package name
g_debug boolean		:=hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_resource_rule_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_resource_rule_id                     in number
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_resource_rules and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hxc_resource_rules hrr
      --   , EDIT_HERE table_name(s) 333
     where hrr.resource_rule_id = p_resource_rule_id;
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
    ,p_argument           => 'resource_rule_id'
    ,p_argument_value     => p_resource_rule_id
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
  (p_resource_rule_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_resource_rules and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , hxc_resource_rules hrr
      --   , EDIT_HERE table_name(s) 333
     where hrr.resource_rule_id = p_resource_rule_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72);
  --
Begin
  --
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc  :=  g_package||'return_legislation_code';
	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'resource_rule_id'
    ,p_argument_value     => p_resource_rule_id
    );
  --
  if ( nvl(hxc_hrr_bus.g_resource_rule_id, hr_api.g_number)
       = p_resource_rule_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_hrr_bus.g_legislation_code;
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
    hxc_hrr_bus.g_resource_rule_id  := p_resource_rule_id;
    hxc_hrr_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date               in date
  ,p_rec in hxc_hrr_shd.g_rec_type
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
  IF NOT hxc_hrr_shd.api_updating
      (p_resource_rule_id                     => p_rec.resource_rule_id
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
-- This procedure ensures that a valid and a unique Resource rule name
-- has been entered
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   object_version_number
--
-- Post Success:
--   Processing continues if a valid and a unique name has been entered
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_name in hxc_resource_rules.name%TYPE,
   p_business_group_id in hxc_resource_rules.business_group_id%TYPE,
   p_object_version_number in hxc_resource_rules.object_version_number%TYPE
  ) IS
--
  l_proc  varchar2(72);
--
-- cursor to check that a duplicate resource rule name is not entered
--
CURSOR  csr_chk_name IS
SELECT 'error'
FROM    sys.dual
WHERE EXISTS (
        SELECT  'x'
        FROM    hxc_resource_rules hrr
        WHERE   hrr.name = p_name
        AND     (hrr.business_group_id = p_business_group_id or hrr.business_group_id is null)
        AND     hrr.object_version_number <> NVL(p_object_version_number, -1) );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	l_proc := g_package||'chk_name';
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- Raise error if name is NULL as it is a mandatory field.
--
IF p_name IS NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0083_HRR_RULE_NAME_MAND');
      hr_utility.raise_error;
--
END IF;
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
--
-- Raise an error if the resource rule name is not unique
--
  OPEN  csr_chk_name;
  FETCH csr_chk_name INTO l_error;
  CLOSE csr_chk_name;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0084_HRR_DUP_RESC_RL_NAME');
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
-- |-< chk_dates >------------------------------------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure performs basic checks on the assignment dates to ensure
--   that they conform with the business rules.
--   At the moment the only business rule enforced in this procedure is that
--   the end date must be >= the start date
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_resource_rule_id
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An exception is raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_dates
   (p_resource_rule_id
                  IN hxc_resource_rules.resource_rule_id%TYPE
   ,p_start_date
                  IN hxc_resource_rules.start_date%TYPE
   ,p_end_date
                  IN hxc_resource_rules.end_date%TYPE
   )
IS
--
CURSOR c_get_dates
IS
SELECT start_date
      ,end_date
  FROM hxc_resource_rules
 WHERE resource_rule_id = p_resource_rule_id;
--
BEGIN
   --
   -- check that the start date is not greater than the end date
   --
   IF p_start_date > NVL(p_end_date, hr_general.END_OF_TIME) THEN
      --
      hr_utility.set_message
         (809
         ,'HXC_0085_HRR_START_DT_ERR'
         );
      hr_utility.raise_error;
      --
   END IF;
   --
END chk_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_rule_evaluation_order >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure ensures that a valid and a unique Rule Evaluation Order
-- has been entered for each resource rule
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   rule_evaluation_order
--   object_version_number
--
-- Post Success:
--   Processing continues if a valid and a unique rule evaluation order
--   has been entered
--
-- Post Failure:
--   An application error is raised if the rule evaluation order is not
--   unique
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_rule_evaluation_order
  (
   p_rule_evaluation_order in hxc_resource_rules.rule_evaluation_order%TYPE,
   p_business_group_id in hxc_resource_rules.business_group_id%TYPE,
   p_object_version_number in hxc_resource_rules.object_version_number%TYPE
  ) IS
--
  l_proc  varchar2(72) := g_package||'chk_rule_evaluation_order';
--
-- cursor to check that a duplicate rule evaluation order is not entered
--
CURSOR  csr_chk_rule_evaluation_order IS
SELECT 'error'
FROM    sys.dual
WHERE EXISTS (
        SELECT  'x'
        FROM    hxc_resource_rules hrr
        WHERE   hrr.rule_evaluation_order = p_rule_evaluation_order
        AND     (hrr.business_group_id = p_business_group_id or hrr.business_group_id is null)
        AND     hrr.object_version_number <> NVL(p_object_version_number, -1) );
--
 l_error varchar2(5) := NULL;
--
BEGIN
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
--
-- Raise an error if the rule evaluation order is not unique
--
IF (p_rule_evaluation_order <> 0) THEN
  OPEN  csr_chk_rule_evaluation_order;
  FETCH csr_chk_rule_evaluation_order INTO l_error;
  CLOSE csr_chk_rule_evaluation_order;
END IF;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809, 'HXC_0129_HRR_DUP_RL_EVL_ORD');
      hr_utility.raise_error;
--
END IF;
--
  if g_debug then
	hr_utility.set_location('Leaving:'||l_proc, 10);
  end if;
--
END chk_rule_evaluation_order;
--
--
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
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_hrr_shd.g_rec_type
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
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
  --
  -- Do checks for the unique resource rule name
  --
        chk_name ( p_name => p_rec.name,
        	   p_business_group_id => p_rec.business_group_id,
                   p_object_version_number => p_rec.object_version_number );
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
  --
  --
  -- Do checks on the dates of the resource rule
  --
   chk_dates
      (p_resource_rule_id => p_rec.resource_rule_id
      ,p_start_date       => p_rec.start_date
      ,p_end_date         => p_rec.end_date
      );
  --
  -- Do checks for the unique rule_evaluation_order
  --
chk_rule_evaluation_order(p_rule_evaluation_order =>p_rec.rule_evaluation_order,
			  p_business_group_id => p_rec.business_group_id,
                          p_object_version_number => p_rec.object_version_number );
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
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
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in hxc_hrr_shd.g_rec_type
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
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  -- Do check for duplicate resource rule name
  --
  if g_debug then
	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;
  --
        chk_name ( p_name => p_rec.name,
        	   p_business_group_id => p_rec.business_group_id,
                   p_object_version_number => p_rec.object_version_number );
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
  --
  -- Do checks on the dates of the resource rule
  --
   chk_dates
      (p_resource_rule_id => p_rec.resource_rule_id
      ,p_start_date       => p_rec.start_date
      ,p_end_date         => p_rec.end_date
      );
  --
  -- Do checks for the unique rule evaluation order
  --
chk_rule_evaluation_order(p_rule_evaluation_order =>p_rec.rule_evaluation_order,
			  p_business_group_id => p_rec.business_group_id,
                          p_object_version_number => p_rec.object_version_number );
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
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_hrr_shd.g_rec_type
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
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_hrr_bus;

/
