--------------------------------------------------------
--  DDL for Package Body PAY_ESU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ESU_BUS" as
/* $Header: pyesurhi.pkb 115.1 2003/08/15 02:39:10 thabara noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_esu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_element_span_usage_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_element_span_usage_id                in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_element_span_usages esu
     where esu.element_span_usage_id = p_element_span_usage_id
       and pbg.business_group_id (+) = esu.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'element_span_usage_id'
    ,p_argument_value     => p_element_span_usage_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
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
        => nvl(p_associated_column1,'ELEMENT_SPAN_USAGE_ID')
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
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
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
  (p_element_span_usage_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_element_span_usages esu
     where esu.element_span_usage_id = p_element_span_usage_id
       and pbg.business_group_id (+) = esu.business_group_id;
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
    ,p_argument           => 'element_span_usage_id'
    ,p_argument_value     => p_element_span_usage_id
    );
  --
  if ( nvl(pay_esu_bus.g_element_span_usage_id, hr_api.g_number)
       = p_element_span_usage_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_esu_bus.g_legislation_code;
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
    pay_esu_bus.g_element_span_usage_id       := p_element_span_usage_id;
    pay_esu_bus.g_legislation_code  := l_legislation_code;
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
  (p_effective_date               in date
  ,p_rec in pay_esu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_esu_shd.api_updating
      (p_element_span_usage_id             => p_rec.element_span_usage_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_esu_shd.g_old_rec.business_group_id, hr_api.g_number) then
    l_argument := 'business_group_id';
    raise l_error;
  end if;
  hr_utility.set_location(l_proc, 15);
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_esu_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
    l_argument := 'legislation_code';
    raise l_error;
  end if;
  hr_utility.set_location(l_proc, 20);
  --
  if nvl(p_rec.retro_component_usage_id, hr_api.g_number) <>
     nvl(pay_esu_shd.g_old_rec.retro_component_usage_id, hr_api.g_number) then
    l_argument := 'retro_component_usage_id';
    raise l_error;
  end if;
  hr_utility.set_location(l_proc, 25);
  --
  if nvl(p_rec.time_span_id, hr_api.g_number) <>
     nvl(pay_esu_shd.g_old_rec.time_span_id, hr_api.g_number) then
    l_argument := 'time_span_id';
    raise l_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
exception
  when l_error then
    hr_api.argument_changed_error
      (p_api_name => l_proc
      ,p_argument => l_argument
      );
  when others then
    raise;

End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;

-- -------------------------------------------------------------------------
-- |-------------------< chk_retro_component_usage_id >--------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the retro component usage id exists in
--   pay_retro_component_usages.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_component_usage_id
--   p_business_group_id
--   p_legislation_code
--
-- Post Success:
--   Processing continues if the retro_component_usage_id is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   retro_component_usage_id is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
--
procedure chk_retro_component_usage_id
  (p_retro_component_usage_id in pay_element_span_usages.time_span_id%type
  ,p_business_group_id        in pay_element_span_usages.business_group_id%type
  ,p_legislation_code         in pay_element_span_usages.legislation_code%type
  )
is
  --
  -- Declare local variables
  --
  l_proc           varchar2(72) := g_package||'chk_retro_component_usage_id';
  l_varchar2       varchar2(30) := hr_api.g_varchar2;
  l_number         number       := hr_api.g_number;
  l_exists         varchar2(1);
  l_legislation_code pay_element_span_usages.legislation_code%type;

  --
  -- Cursor to check that a retro component exists.
  --
  cursor csr_retro_component_usage is
    select null
      from pay_retro_component_usages
     where retro_component_usage_id = p_retro_component_usage_id
       and nvl(legislation_code, nvl(l_legislation_code, l_varchar2))
             = nvl(l_legislation_code, l_varchar2)
       and nvl(business_group_id, nvl(p_business_group_id, l_number))
             = nvl(p_business_group_id, l_number);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'retro_component_usage_id'
    ,p_argument_value => p_retro_component_usage_id
    );

  --
  -- Set the legislation code
  --
  l_legislation_code
     := nvl(p_legislation_code
           ,hr_api.return_legislation_code(p_business_group_id));

  --
  -- Check if the retro component usage exists.
  --
  hr_utility.set_location(l_proc, 20);
  open csr_retro_component_usage;
  fetch csr_retro_component_usage into l_exists;
  if csr_retro_component_usage%notfound then
    close csr_retro_component_usage;

    fnd_message.set_name('PAY','PAY_33164_ESU_INV_RET_COMP_USG');
    fnd_message.raise_error;

  end if;
  close csr_retro_component_usage;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_retro_component_usage_id;
--
-- -------------------------------------------------------------------------
-- |-------------------------< chk_time_span_id >--------------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the time span id exists in pay_time_spans.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_time_span_id
--   p_retro_component_usage_id
--
-- Post Success:
--   Processing continues if the time_span_id is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   time_span_id is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
--
procedure chk_time_span_id
  (p_time_span_id             in pay_element_span_usages.time_span_id%type
  ,p_retro_component_usage_id in pay_element_span_usages.retro_component_usage_id%type
  )
is
  --
  -- Declare local variables
  --
  l_proc             varchar2(72) := g_package||'chk_time_span_id';
  l_varchar2         varchar2(30) := hr_api.g_varchar2;
  l_number           number       := hr_api.g_number;
  l_exists           varchar2(1);

  --
  -- Cursor to check that a retro component exists.
  --
  cursor csr_time_span is
    select null
      from pay_time_spans pts
          ,pay_retro_component_usages rcu
     where pts.time_span_id = p_time_span_id
       and rcu.retro_component_usage_id = p_retro_component_usage_id
       and pts.creator_type = 'RC'
       and pts.creator_id = rcu.retro_component_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'time_span_id'
    ,p_argument_value => p_time_span_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'retro_component_usage_id'
    ,p_argument_value => p_retro_component_usage_id
    );

  --
  -- Check if the time span exists.
  --
  hr_utility.set_location(l_proc, 20);
  open csr_time_span;
  fetch csr_time_span into l_exists;
  if csr_time_span%notfound then
    close csr_time_span;

    fnd_message.set_name('PAY','PAY_33165_ESU_INV_TIME_SPAN');
    fnd_message.raise_error;

  end if;
  close csr_time_span;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_time_span_id;
--
-- -------------------------------------------------------------------------
-- |------------------------< chk_adjustment_type >------------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the adjustment type exists in lookup type
--   RETRO_ADJUSTMENT_TYPE.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_element_span_usage_id
--   p_adjustment_type
--   p_object_version_number
--   p_effective_date
--
--
-- Post Success:
--   Processing continues if the adjustment_type is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   adjustment_type is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
--
procedure chk_adjustment_type
  (p_element_span_usage_id in pay_element_span_usages.retro_component_usage_id%type
  ,p_adjustment_type       in pay_element_span_usages.adjustment_type%type
  ,p_object_version_number in pay_element_span_usages.object_version_number%type
  ,p_effective_date        in date
  )
is
  --
  -- Declare local variables
  --
  l_proc           varchar2(72) := g_package||'chk_adjustment_type';
  l_api_updating   boolean;

--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );

  hr_utility.set_location(l_proc, 15);
  --
  -- Check if the element span usage is being updated and ensure that
  -- g_old_rec contains the values for this element_span_usage_id.
  --
  l_api_updating :=
    pay_esu_shd.api_updating
      (p_element_span_usage_id => p_element_span_usage_id
      ,p_object_version_number => p_object_version_number);

  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the value is not null.
  --
  if ((l_api_updating and
       nvl(pay_esu_shd.g_old_rec.adjustment_type, hr_api.g_varchar2)
         <> nvl(p_adjustment_type, hr_api.g_varchar2))
     or
       NOT l_api_updating) then
     --
     hr_utility.set_location(l_proc, 30);

     --
     --  If adjustment_type is not null then
     --  Check if the adjustment_type value exists in hr_lookups
     --  where the lookup_type is 'RETRO_ADJUSTMENT_TYPE'
     --
     if p_adjustment_type is not null then
       if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_effective_date
           ,p_lookup_type    => 'RETRO_ADJUSTMENT_TYPE'
           ,p_lookup_code    => p_adjustment_type
           ) then

         fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
         fnd_message.set_token('COLUMN','ADJUSTMENT_TYPE');
         fnd_message.set_token('LOOKUP_TYPE','RETRO_ADJUSTMENT_TYPE');
         fnd_message.raise_error;

       end if;
     end if;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_adjustment_type;
--
--
-- -------------------------------------------------------------------------
-- |---------------------< chk_retro_element_type_id >---------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the retro_element_type_id exists in pay_element_types_f.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_element_span_usage_id
--   p_retro_element_type_id
--   p_object_version_number
--   p_effective_date
--
--
-- Post Success:
--   Processing continues if the retro_element_type_id is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   retro_element_type_id is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
--
procedure chk_retro_element_type_id
  (p_element_span_usage_id in pay_element_span_usages.retro_component_usage_id%type
  ,p_retro_element_type_id in pay_element_span_usages.retro_element_type_id%type
  ,p_business_group_id     in pay_element_span_usages.business_group_id%type
  ,p_legislation_code      in pay_element_span_usages.legislation_code%type
  ,p_object_version_number in pay_element_span_usages.object_version_number%type
  ,p_effective_date        in date
  )
is
  --
  -- Declare local variables
  --
  l_proc             varchar2(72) := g_package||'chk_retro_element_type_id';
  l_varchar2         varchar2(30) := hr_api.g_varchar2;
  l_number           number       := hr_api.g_number;
  l_exists           varchar2(1);
  l_api_updating     boolean;
  l_legislation_code pay_element_span_usages.legislation_code%type;

  --
  -- Cursor to check that a retro component exists.
  --
  cursor csr_retro_element_type is
    select null
      from pay_element_types_f
     where element_type_id = p_retro_element_type_id
       and p_effective_date between effective_start_date
       and effective_end_date
       and nvl(legislation_code, nvl(l_legislation_code, l_varchar2))
             = nvl(l_legislation_code, l_varchar2)
       and nvl(business_group_id, nvl(p_business_group_id, l_number))
             = nvl(p_business_group_id, l_number);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'retro_element_type_id'
    ,p_argument_value => p_retro_element_type_id
    );
  --
  -- Set the legislation code
  --
  l_legislation_code
     := nvl(p_legislation_code
           ,hr_api.return_legislation_code(p_business_group_id));

  --
  -- Check if the retro component usage is being updated and ensure that
  -- g_old_rec contains the values for this retro_component_usage_id.
  --
  l_api_updating :=
    pay_esu_shd.api_updating
      (p_element_span_usage_id => p_element_span_usage_id
      ,p_object_version_number => p_object_version_number);

  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert.
  --
  if ((l_api_updating and
       pay_esu_shd.g_old_rec.retro_element_type_id <> p_retro_element_type_id)
     or
       NOT l_api_updating) then
     --
     hr_utility.set_location(l_proc, 30);

     --
     -- Check if the retro element type exists.
     --
     hr_utility.set_location(l_proc, 40);
     open csr_retro_element_type;
     fetch csr_retro_element_type into l_exists;
     if csr_retro_element_type%notfound then
       close csr_retro_element_type;

       fnd_message.set_name('PAY','PAY_33166_ESU_INV_RET_ELE_TYP');
       fnd_message.raise_error;

     end if;
     close csr_retro_element_type;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_retro_element_type_id;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_esu_shd.g_rec_type
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
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_esu_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  --
  chk_retro_component_usage_id
    (p_retro_component_usage_id => p_rec.retro_component_usage_id
    ,p_business_group_id        => p_rec.business_group_id
    ,p_legislation_code         => p_rec.legislation_code
    );

  chk_time_span_id
    (p_time_span_id             => p_rec.time_span_id
    ,p_retro_component_usage_id => p_rec.retro_component_usage_id
    );

  chk_adjustment_type
    (p_element_span_usage_id => p_rec.element_span_usage_id
    ,p_adjustment_type       => p_rec.adjustment_type
    ,p_object_version_number => p_rec.object_version_number
    ,p_effective_date        => p_effective_date
    );

  chk_retro_element_type_id
    (p_element_span_usage_id => p_rec.element_span_usage_id
    ,p_retro_element_type_id => p_rec.retro_element_type_id
    ,p_business_group_id     => p_rec.business_group_id
    ,p_legislation_code      => p_rec.legislation_code
    ,p_object_version_number => p_rec.object_version_number
    ,p_effective_date        => p_effective_date
    );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_esu_shd.g_rec_type
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
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_esu_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  chk_adjustment_type
    (p_element_span_usage_id => p_rec.element_span_usage_id
    ,p_adjustment_type       => p_rec.adjustment_type
    ,p_object_version_number => p_rec.object_version_number
    ,p_effective_date        => p_effective_date
    );

  chk_retro_element_type_id
    (p_element_span_usage_id => p_rec.element_span_usage_id
    ,p_retro_element_type_id => p_rec.retro_element_type_id
    ,p_business_group_id     => p_rec.business_group_id
    ,p_legislation_code      => p_rec.legislation_code
    ,p_object_version_number => p_rec.object_version_number
    ,p_effective_date        => p_effective_date
    );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_esu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,pay_esu_shd.g_old_rec.business_group_id
                    ,pay_esu_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_esu_bus;

/
