--------------------------------------------------------
--  DDL for Package Body HXC_HAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAT_BUS" as
/* $Header: hxchatrhi.pkb 120.2 2005/09/23 10:41:13 sechandr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_hat_bus.';  -- Global package name
g_debug	boolean	:=hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_alias_type_id               number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_alias_type_id                        in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , hxc_alias_types hat
     where hat.alias_type_id = p_alias_type_id;
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
    ,p_argument           => 'alias_type_id'
    ,p_argument_value     => p_alias_type_id
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
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'ALIAS_TYPE_ID')
       );
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
  (p_alias_type_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , hxc_alias_types hat
     where hat.alias_type_id = p_alias_type_id;
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
    ,p_argument           => 'alias_type_id'
    ,p_argument_value     => p_alias_type_id
    );
  --
  if ( nvl(hxc_hat_bus.g_alias_type_id, hr_api.g_number)
       = p_alias_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_hat_bus.g_legislation_code;
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
    hxc_hat_bus.g_alias_type_id               := p_alias_type_id;
    hxc_hat_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hxc_hat_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hxc_hat_shd.api_updating
      (p_alias_type_id                     => p_rec.alias_type_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
End chk_non_updateable_args;

-------------------------------------------------------------------------------
-- |-------------------------<chk_name>---------------------------------------|
-------------------------------------------------------------------------------
Procedure chk_name (p_type hxc_alias_types.ALIAS_TYPE%TYPE,
		    p_reference_object hxc_alias_types.REFERENCE_OBJECT%TYPE
		    ) is

CURSOR  csr_chk_alias_type IS
SELECT 'error'
FROM    sys.dual
WHERE EXISTS (
       SELECT  'x'
       from hxc_alias_types
       where alias_type = p_type and
	     reference_object = p_reference_object);

l_error varchar2(5) := NULL;

Begin

if g_debug then
	hr_utility.trace('Entering chk_name');
end if;

--
-- Raise an error if the alias type and reference object are already defined.
--
  OPEN  csr_chk_alias_type;
  FETCH csr_chk_alias_type INTO l_error;
  CLOSE csr_chk_alias_type;
--
IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809,'HXC_ALT_EXISTS'); -- 'Alias Type already exists');
      hr_utility.raise_error;
--
END IF;
if g_debug then
	hr_utility.trace('Leaving chk_name');
end if;

end chk_name;
--
-------------------------------------------------------------------------------
-- |-------------------------<chk_fk_realation>---------------------------------------|
-------------------------------------------------------------------------------
Procedure chk_fk_relation (p_alias_type_id hxc_alias_types.alias_type_id%TYPE
			   ) is
Cursor csr_chk_aldef IS
select 'error'
from sys.dual
where exists(
	     select 'x'
	     from hxc_alias_definitions had,
		  hxc_alias_types hat
	     where hat.alias_type_id = p_alias_type_id and
		   hat.alias_type_id = had.alias_type_id
	     );
l_error varchar2(5) := NULL;
begin

g_debug:=hr_utility.debug_enabled;
if g_debug then
	hr_utility.trace('Entering chk_fk_relation');
end if;
--
   OPEN csr_chk_aldef;
   FETCH csr_chk_aldef into l_error;
   close csr_chk_aldef;

if g_debug then
	hr_utility.trace('1st Validation'|| l_error);
end if;

IF l_error IS NOT NULL
THEN
--
      hr_utility.set_message(809,'HXC_ALT_CANT_DEL'); -- 'Alias type is used in altenate name definition');
      hr_utility.trace('------77777');
      hr_utility.raise_error;
--
END IF;

if g_debug then
	hr_utility.trace('Leaving chk_fk_relation');
end if;

end chk_fk_relation;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_hat_shd.g_rec_type
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
  -- Validate Dependent Attributes
  --
  -- Do check for duplicate pref hierarchy name
  --
  chk_name ( p_type => p_rec.alias_type,
	     p_reference_object => p_rec.reference_object);
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
  (p_rec                          in hxc_hat_shd.g_rec_type
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
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  -- Do check for duplicate pref hierarchy name
  --
  chk_name ( p_type => p_rec.alias_type,
	     p_reference_object =>p_rec.reference_object);
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
  (p_rec                          in hxc_hat_shd.g_rec_type
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
  -- Check if the alternate type definition is not used by alternate name
     chk_fk_relation(p_rec.alias_type_id);

  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_hat_bus;

/
