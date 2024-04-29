--------------------------------------------------------
--  DDL for Package Body PQH_RLA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RLA_BUS" as
/* $Header: pqrlarhi.pkb 115.3 2003/02/12 00:43:55 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_rla_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_rule_attribute_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_rule_attribute_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- The cursor csr_sec_group joins pqh_rule_sets,
  -- pqh_rule_attributes and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.

  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_rule_attributes rla
         , pqh_rule_sets rst
     where rla.rule_attribute_id = p_rule_attribute_id
	and pbg.business_group_id = rst.business_group_id
	and rst.rule_set_id = rla.rule_set_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'rule_attribute_id'
    ,p_argument_value     => p_rule_attribute_id
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
        => nvl(p_associated_column1,'RULE_ATTRIBUTE_ID')
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
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_rule_attribute_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- Added joins between pqh_rule_sets,
  -- pqh_rule_attributes and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.

  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pqh_rule_attributes rla
         , pqh_rule_sets rst
     where rla.rule_attribute_id = p_rule_attribute_id
	and pbg.business_group_id = rst.business_group_id
	and rst.rule_set_id = rla.rule_set_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'rule_attribute_id'
    ,p_argument_value     => p_rule_attribute_id
    );
  --
  if ( nvl(pqh_rla_bus.g_rule_attribute_id, hr_api.g_number)
       = p_rule_attribute_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_rla_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
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
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pqh_rla_bus.g_rule_attribute_id           := p_rule_attribute_id;
    pqh_rla_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
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
  (p_rec in pqh_rla_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_rla_shd.api_updating
      (p_rule_attribute_id                 => p_rec.rule_attribute_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_unique_attributes >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure duplicate attributes are not saved
--   for the same rule_set_id, operation_code, and attribute_values.
--
-- Post Failure:
--   An application error is raised if duplicate records are found.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unique_attributes
  (p_rec in pqh_rla_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_unique_attributes';
--
cnt number;
Begin
  hr_utility.set_location(' Entering:'|| l_proc, 10);
select count(*) into cnt from pqh_rule_attributes where
rule_set_id = p_rec.rule_set_id
and
rule_attribute_id <> nvl(p_rec.rule_attribute_id, 0)
and
((attribute_code is null and p_rec.attribute_code is null) or (attribute_code = p_rec.attribute_code))
and
((operation_code is null and p_rec.operation_code is null) or (operation_code = p_rec.operation_code))
and
((attribute_value is null and p_rec.attribute_value is null) or (attribute_value = p_rec.attribute_value));

if cnt > 0 then
hr_utility.set_message(8302, 'PQH_CBR_UNIQUE_ATTRIBUTES');
hr_utility.raise_error;
end if;
  --
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
End chk_unique_attributes;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_attribute_datatype >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure attributes of type number
--   cannot be saved with values which are alpha-numeric. Only numbers should
--   be able to save.
--
-- Post Failure:
--   An application error is raised if characters which are not numbers are
--   found.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_attribute_datatype
  (p_rec in pqh_rla_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_attribute_datatype';
--
att_val number;
att_type varchar2(10);
cnt number;
Begin
select count(*) into cnt from pqh_attributes where attribute_id = to_number(p_rec.attribute_code);
if cnt = 1 then
	select column_type into att_type from pqh_attributes where
	attribute_id = to_number(p_rec.attribute_code);
--
-- to_number is able to handle only upto 126 chars. so making this logic to go beyond 126.
--
	if att_type = 'N' then
		if nvl(length(p_rec.attribute_value), 0) > 120 then
			select to_number(substr(p_rec.attribute_value, 1, 120)) into att_val from dual;
			select to_number(substr(p_rec.attribute_value, 120)) into att_val from dual;
		else
			select to_number(p_rec.attribute_value) into att_val from dual;
		end if;
	end if;
else
hr_utility.set_message(8302, 'PQH_ATTRIBUTE_NOT_FOUND');
hr_utility.raise_error;
end if;
exception when others then
hr_utility.set_message(8302, 'PQH_CBR_NUMBER_ATTRIBUTE');
hr_utility.raise_error;
End chk_attribute_datatype;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pqh_rla_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- commented out the follwing line because rule sets are not
  -- business group sensitive. --01/18/2002 rpasapul.
--pqh_rst_bus.set_security_group_id(p_rec.rule_set_id, null);
  --
  -- Validate Dependent Attributes
  --
  --
  --
  -- Check for duplicate attributes.
  --
  chk_unique_attributes
  (p_rec                => p_rec
  );
  --
  -- Check for data type match for attribute values
  --
  chk_attribute_datatype
  (p_rec                => p_rec
  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pqh_rla_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Commented out the follwoing line because rule sets are not
  -- business group sensitive --01/18/2003 rpasapul.
  -- pqh_rst_bus.set_security_group_id(p_rec.rule_set_id, null);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  -- Check for duplicate attributes.
  --
  chk_unique_attributes
  (p_rec                => p_rec
  );
  --
  -- Check for data type match for attribute values
  --
    chk_attribute_datatype
  (p_rec                => p_rec
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_rla_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_rla_bus;

/
