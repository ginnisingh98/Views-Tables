--------------------------------------------------------
--  DDL for Package Body PAY_SIR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SIR_BUS" as
/* $Header: pysirrhi.pkb 115.4 2003/02/05 17:11:09 arashid noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_sir_bus.';  -- Global package name
--
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
  (p_rec in pay_sir_shd.g_rec_type
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
  IF NOT pay_sir_shd.api_updating
      (p_iterative_rule_id                    => p_rec.iterative_rule_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- p_element_type_id
  --
  if nvl(p_rec.element_type_id, hr_api.g_number) <>
	nvl(pay_sir_shd.g_old_rec.element_type_id, hr_api.g_number)
  then
  l_argument := 'p_element_type_id';
  raise l_error;
  end if;
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
-- |-------------------------< chk_element_type_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_element_type_id
  (p_element_type_id     in number
  ) is
  --
  -- Cursor to check that the element type exists.
  --
  cursor c_element_type_exists is
  select null
  from   pay_shadow_element_types pset
  where  pset.element_type_id = p_element_type_id;
--
  l_proc varchar2(72) := g_package||'chk_element_type_id';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the element type is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name          => l_proc
  ,p_argument          => 'ELEMENT_TYPE_ID'
  ,p_argument_value    => p_element_type_id
  );
  --
  -- Check that the element type exists
  --
  open c_element_type_exists;
  fetch c_element_type_exists into l_exists;
  if c_element_type_exists%notfound then
    close c_element_type_exists;
    fnd_message.set_name('PAY', 'PAY_50095_ETM_INVALID_ELE_TYPE');
    fnd_message.raise_error;
  end if;
  close c_element_type_exists;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_element_type_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_result_name >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_result_name
  (p_result_name           in varchar2
  ,p_iterative_rule_id     in number
  ,p_object_version_number in number
  ) is
--
  l_proc     varchar2(72) := g_package||'chk_result_name';
  l_legislation_code   varchar2(2000);
  l_exists             varchar2(1);
  l_value              varchar2(2000);
  l_output             varchar2(2000);
  l_rgeflg             varchar2(2000);
  l_api_updating       boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sir_shd.api_updating
  (p_iterative_rule_id => p_iterative_rule_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_result_name, hr_api.g_varchar2) <>
	 nvl(pay_sir_shd.g_old_rec.result_name, hr_api.g_varchar2)) or
	 not l_api_updating
  then
    --
    -- Check that the name format is correct (not null database item name).
    --
    l_value := p_result_name;
    hr_chkfmt.checkformat
    (value   => l_value
    ,format  => 'PAY_NAME'
    ,output  => l_output
    ,minimum => null
    ,maximum => null
    ,nullok  => 'N'
    ,rgeflg  => l_rgeflg
    ,curcode => null
    );
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_result_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_input_value_id >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_input_value_id
  (p_input_value_id     in number
  ,p_element_type_id    in number
  ,p_iterative_rule_id  in number
  ,p_object_version_number in number
  ) is
  --
  -- Cursor to check that the input value exists (and is in the same
  -- template as the element type).
  --
  cursor c_input_value_exists is
  select null
  from   pay_shadow_element_types pset
  ,      pay_shadow_element_types pset1
  ,      pay_shadow_input_values  psiv
  where  pset.element_type_id = p_element_type_id
  and    pset1.template_id    = pset.template_id
  and    psiv.input_value_id  = p_input_value_id
  and    psiv.element_type_id = pset1.element_type_id;
--
  l_proc  varchar2(72)  := g_package||'chk_input_value_id';
  l_exists   varchar2(1);
  l_api_updating  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sir_shd.api_updating
    (p_iterative_rule_id    => p_iterative_rule_id
    ,p_object_version_number => p_object_version_number
    );
  if (l_api_updating and nvl(p_input_value_id, hr_api.g_number) <>
     nvl(pay_sir_shd.g_old_rec.input_value_id, hr_api.g_number)) or
	not l_api_updating
  then
    if p_input_value_id is not null then
	 --
	 -- Check that the input value exists
	 --
	 open c_input_value_exists;
	 fetch c_input_value_exists into l_exists;
	 if c_input_value_exists%notfound then
	   close c_input_value_exists;
	   fnd_message.set_name('PAY', 'PAY_50098_ETM_INVALID_INP_VAL');
	   fnd_message.raise_error;
      end if;
	 close c_input_value_exists;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_input_value_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_iterative_rule_type >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_iterative_rule_type
  (p_effective_date         in date
  ,p_iterative_rule_type    in varchar2
  ,p_iterative_rule_id      in number
  ,p_object_version_number  in number
  ) is
--
  l_proc          varchar2(72)  := g_package||'chk_iterative_rule_type';
  l_api_updating  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sir_shd.api_updating
  (p_iterative_rule_id    => p_iterative_rule_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_iterative_rule_type, hr_api.g_varchar2) <>
	nvl(pay_sir_shd.g_old_rec.iterative_rule_type, hr_api.g_varchar2)) or
	not l_api_updating
  then
	--
	-- Iterative rule type is mandatory.
	--
	hr_api.mandatory_arg_error
	(p_api_name          => l_proc
	,p_argument          => 'ITERATIVE_RULE_TYPE'
	,p_argument_value    => p_iterative_rule_type
	);
	--
	-- Validate against hr_lookups.
	--
	if hr_api.not_exists_in_hr_lookups
	   (p_effective_date => p_effective_date
	   ,p_lookup_type    => 'ITERATIVE_RULE_TYPE'
	   ,p_lookup_code    => p_iterative_rule_type
	   )
     then
       fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
       fnd_message.set_token('LOOKUP_TYPE', 'ITERATIVE_RULE_TYPE');
       fnd_message.set_token('COLUMN', 'ITERATIVE_RULE_TYPE');
       fnd_message.raise_error;
     end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_iterative_rule_type;
--
-- ----------------------------------------------------------------------------
-- ---------------------------< chk_severity_level >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_severity_level
  (p_effective_date     in date
  ,p_severity_level     in varchar2
  ,p_iterative_rule_id  in number
  ,p_object_version_number in number
  ) is
--
  l_proc   varchar2(72) := g_package||'chk_severity_level';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sir_shd.api_updating
  (p_iterative_rule_id     => p_iterative_rule_id
  ,p_object_version_number => p_object_version_number
  );
  --
  if (l_api_updating and nvl(p_severity_level, hr_api.g_varchar2) <>
	nvl(pay_sir_shd.g_old_rec.severity_level, hr_api.g_varchar2)) or
	not l_api_updating
  then
    if p_severity_level is not null then
      --
      -- Validate against hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
      	 (p_effective_date => p_effective_date
	 ,p_lookup_type    => 'MESSAGE_LEVEL'
	 ,p_lookup_code    => p_severity_level
	 )
      then
	 fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
	 fnd_message.set_token('LOOKUP_TYPE', 'MESSAGE_LEVEL');
	 fnd_message.set_token('COLUMN', 'SEVERITY_LEVEL');
	 fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_severity_level;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id     in number
  ,p_element_type_id       in number
  ,p_iterative_rule_id     in number
  ,p_object_version_number in number
  ) is
  --
  -- Cursor to check that the exclusion rule is valid.
  --
  cursor c_exclusion_rule_is_valid is
  select null
  from   pay_shadow_element_types     pset
  ,      pay_template_exclusion_rules ter
  where  pset.element_type_id  = p_element_type_id
  and    ter.template_id       = pset.template_id
  and    ter.exclusion_rule_id = p_exclusion_rule_id;
--
  l_proc varchar2(72)  := g_package||'chk_exclusion_rule_id';
  l_api_updating  boolean;
  l_valid	  varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_sir_shd.api_updating
  (p_iterative_rule_id     => p_iterative_rule_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
	nvl(pay_sir_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
	not l_api_updating
  then
    if p_exclusion_rule_id is not null then
	 open c_exclusion_rule_is_valid;
	 fetch c_exclusion_rule_is_valid into l_valid;
	 if c_exclusion_rule_is_valid%notfound then
	   close c_exclusion_rule_is_valid;
	   fnd_message.set_name('PAY', 'PAY_50100_ETM_INVALID_EXC_RULE');
	   fnd_message.raise_error;
      end if;
	 close c_exclusion_rule_is_valid;
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
End chk_exclusion_rule_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_delete >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_iterative_rule_id  in number
  ) is
  --
  -- Cursor to check for rows referencing the iterative rule.
  --
  cursor c_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_sir_lookup_type
  and    tco.shadow_object_id = p_iterative_rule_id;
--
  l_proc varchar2(72) := g_package||'chk_delete';
  l_error exception;
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_core_objects;
  fetch c_core_objects into l_exists;
  if c_core_objects%found then
    close c_core_objects;
    raise l_error;
  end if;
  close c_core_objects;
  hr_utility.set_location('Leaving:'||l_proc, 10);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50112_SIR_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location('Leaving:'||l_proc, 15);
    raise;
End chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_sir_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_element_type_id(p_rec.element_type_id);
  --
  chk_result_name
  (p_result_name           => p_rec.result_name
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_input_value_id
  (p_input_value_id        => p_rec.input_value_id
  ,p_element_type_id       => p_rec.element_type_id
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_iterative_rule_type
  (p_effective_date        => p_effective_date
  ,p_iterative_rule_type   => p_rec.iterative_rule_type
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_severity_level
  (p_effective_date        => p_effective_date
  ,p_severity_level        => p_rec.severity_level
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_element_type_id       => p_rec.element_type_id
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date             in date
  ,p_rec                        in pay_sir_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(p_rec);
  --
  chk_result_name
  (p_result_name           => p_rec.result_name
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_input_value_id
  (p_input_value_id        => p_rec.input_value_id
  ,p_element_type_id       => p_rec.element_type_id
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_iterative_rule_type
  (p_effective_date        => p_effective_date
  ,p_iterative_rule_type   => p_rec.iterative_rule_type
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
   );
  --
  chk_severity_level
  (p_effective_date        => p_effective_date
  ,p_severity_level        => p_rec.severity_level
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_element_type_id       => p_rec.element_type_id
  ,p_iterative_rule_id     => p_rec.iterative_rule_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_sir_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.iterative_rule_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_sir_bus;

/
