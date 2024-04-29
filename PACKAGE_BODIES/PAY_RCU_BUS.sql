--------------------------------------------------------
--  DDL for Package Body PAY_RCU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RCU_BUS" as
/* $Header: pyrcurhi.pkb 120.1 2005/06/20 05:01:52 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_rcu_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_retro_component_usage_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_retro_component_usage_id             in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_retro_component_usages rcu
     where rcu.retro_component_usage_id = p_retro_component_usage_id
       and pbg.business_group_id (+) = rcu.business_group_id;
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
    ,p_argument           => 'retro_component_usage_id'
    ,p_argument_value     => p_retro_component_usage_id
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
        => nvl(p_associated_column1,'RETRO_COMPONENT_USAGE_ID')
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
  (p_retro_component_usage_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_retro_component_usages rcu
     where rcu.retro_component_usage_id = p_retro_component_usage_id
       and pbg.business_group_id (+) = rcu.business_group_id;
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
    ,p_argument           => 'retro_component_usage_id'
    ,p_argument_value     => p_retro_component_usage_id
    );
  --
  if ( nvl(pay_rcu_bus.g_retro_component_usage_id, hr_api.g_number)
       = p_retro_component_usage_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_rcu_bus.g_legislation_code;
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
    pay_rcu_bus.g_retro_component_usage_id    := p_retro_component_usage_id;
    pay_rcu_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pay_rcu_shd.g_rec_type
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
  IF NOT pay_rcu_shd.api_updating
      (p_retro_component_usage_id          => p_rec.retro_component_usage_id
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
     nvl(pay_rcu_shd.g_old_rec.business_group_id, hr_api.g_number) then
    l_argument := 'business_group_id';
    raise l_error;
  end if;
  hr_utility.set_location(l_proc, 15);
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_rcu_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
    l_argument := 'legislation_code';
    raise l_error;
  end if;
  hr_utility.set_location(l_proc, 20);
  --
  if p_rec.retro_component_id <> pay_rcu_shd.g_old_rec.retro_component_id then
    l_argument := 'retro_component_id';
    raise l_error;
  end if;
  hr_utility.set_location(l_proc, 25);
  --
  if p_rec.creator_type <> pay_rcu_shd.g_old_rec.creator_type then
    l_argument := 'creator_type';
    raise l_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if p_rec.creator_id <> pay_rcu_shd.g_old_rec.creator_id then
    l_argument := 'creator_id';
    raise l_error;
  end if;
  hr_utility.set_location(l_proc, 35);

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

--
-- -------------------------------------------------------------------------
-- |----------------------< chk_retro_component_id >-----------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the retro component id exists in pay_retro_components.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_component_id
--   p_business_group_id
--   p_legislation_code
--
--
-- Post Success:
--   Processing continues if the retro component id is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   retro component id is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
--
procedure chk_retro_component_id
  (p_retro_component_id in pay_retro_component_usages.retro_component_id%type
  ,p_business_group_id  in pay_retro_component_usages.business_group_id%type
  ,p_legislation_code   in pay_retro_component_usages.legislation_code%type
  )
is
  --
  -- Declare local variables
  --
  l_proc             varchar2(72) := g_package||'chk_retro_component_id';
  l_varchar2         varchar2(30) := hr_api.g_varchar2;
  l_number           number       := hr_api.g_number;
  l_exists           varchar2(1);
  l_legislation_code pay_retro_component_usages.legislation_code%type;

  --
  -- Cursor to check that a retro component exists.
  --
  cursor csr_retro_component is
    select null
      from pay_retro_components
     where retro_component_id = p_retro_component_id
       and nvl(legislation_code, nvl(l_legislation_code, l_varchar2))
             = nvl(l_legislation_code, l_varchar2);

--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'retro_component_id'
    ,p_argument_value => p_retro_component_id
    );
  --
  -- Set the legislation code
  --
  l_legislation_code
     := nvl(p_legislation_code
           ,hr_api.return_legislation_code(p_business_group_id));
  --
  -- Check if the retro component exists.
  --
  hr_utility.set_location(l_proc, 20);
  open csr_retro_component;
  fetch csr_retro_component into l_exists;
  if csr_retro_component%notfound then
    close csr_retro_component;

    fnd_message.set_name('PAY','PAY_33167_RCU_INV_RETRO_COMP');
    fnd_message.raise_error;

  end if;
  close csr_retro_component;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_retro_component_id;
--
-- -------------------------------------------------------------------------
-- |-------------------< chk_creator_type_creator_id >---------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the combination of creator type and creator id.
--   When creator type is ET, then the creator id should be exist in
--   pay_element_types_f.
--   When creator type is EC, then the creator id should be exist in
--   pay_element_classifications.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_creator_type
--   p_creator_Id
--   p_business_group_id
--   p_legislation_code
--   p_effective_date
--
--
-- Post Success:
--   Processing continues if the creator type and creator id are valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   creator type or creator id is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
--
procedure chk_creator_type_creator_id
  (p_creator_type                 in     pay_retro_component_usages.creator_type%type
  ,p_creator_id                   in     pay_retro_component_usages.creator_id%type
  ,p_business_group_id            in     pay_retro_component_usages.business_group_id%type
  ,p_legislation_code             in     pay_retro_component_usages.legislation_code%type
  ,p_effective_date               in     date
  )
is
  --
  -- Declare local variables
  --
  l_proc           varchar2(72) := g_package||'chk_retro_component_id';
  l_varchar2       varchar2(30) := hr_api.g_varchar2;
  l_number         number       := hr_api.g_number;
  l_exists         varchar2(1);
  l_legislation_code pay_retro_component_usages.legislation_code%type;

  --
  -- Cursor to check that an element type exists.
  --
  cursor csr_element_type is
    select null
      from pay_element_types_f
     where element_type_id = p_creator_id
       and p_effective_date between effective_start_date
       and effective_end_date
       and nvl(legislation_code, nvl(l_legislation_code, l_varchar2))
             = nvl(l_legislation_code, l_varchar2)
       and nvl(business_group_id, nvl(p_business_group_id, l_number))
             = nvl(p_business_group_id, l_number);

  --
  -- Cursor to check that an element classification exists.
  --
  cursor csr_classification is
    select null
      from pay_element_classifications
     where classification_id = p_creator_id
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
    ,p_argument       => 'creator_type'
    ,p_argument_value => p_creator_type
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'creator_id'
    ,p_argument_value => p_creator_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );

  --
  -- Set the legislation code
  --
  l_legislation_code
     := nvl(p_legislation_code
           ,hr_api.return_legislation_code(p_business_group_id));

  --
  -- Check the creator type.
  --
  hr_utility.set_location(l_proc, 15);
  if p_creator_type = 'ET' then

    --
    -- Check if the element type exists.
    --
    hr_utility.set_location(l_proc, 20);
    open csr_element_type;
    fetch csr_element_type into l_exists;
    if csr_element_type%notfound then
      close csr_element_type;

    fnd_message.set_name('PAY','PAY_33168_RCU_INV_CRE_ID');
    fnd_message.set_token('TABLE','PAY_ELEMENT_TYPES_F');
    fnd_message.set_token('COLUMN','ELEMENT_TYPE_ID');
    fnd_message.raise_error;

    end if;
    close csr_element_type;

  elsif p_creator_type = 'EC' then

    --
    -- Check if the element classification exists.
    --
    hr_utility.set_location(l_proc, 25);
    open csr_classification;
    fetch csr_classification into l_exists;
    if csr_classification%notfound then
      close csr_classification;

      fnd_message.set_name('PAY','PAY_33168_RCU_INV_CRE_ID');
      fnd_message.set_token('TABLE','PAY_ELEMENT_CLASSIFICATIONS');
      fnd_message.set_token('COLUMN','CLASSIFICATION_ID');
      fnd_message.raise_error;

    end if;
    close csr_classification;

  else

    fnd_message.set_name('PAY','PAY_33161_RCU_INV_CRE_TYP');
    fnd_message.raise_error;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_creator_type_creator_id;

--
-- -------------------------------------------------------------------------
-- |------------------------< chk_reprocess_type >-------------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the reprocess type exists in lookup type
--   RETRO_REPROCESS_TYPE.
--   In addition if the parent retro component is Full Recalculation style,
--   reprocess type must be R (Reprocessed).
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_component_usage_id
--   p_object_version_number
--   p_retro_component_id
--   p_reprocess_type
--   p_effective_date
--
--
-- Post Success:
--   Processing continues if the reprocess type is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   reprocess type is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
--
procedure chk_reprocess_type
  (p_retro_component_usage_id in pay_retro_component_usages.retro_component_usage_id%type
  ,p_object_version_number    in pay_retro_component_usages.object_version_number%type
  ,p_retro_component_id       in pay_retro_component_usages.retro_component_id%type
  ,p_reprocess_type           in pay_retro_component_usages.reprocess_type%type
  ,p_effective_date           in date
  )
is
  --
  -- Declare local variables
  --
  l_proc           varchar2(72) := g_package||'chk_reprocess_type';
  l_api_updating   boolean;
  l_retro_type     pay_retro_components.retro_type%type;

  cursor csr_retro_type
    is
    select retro_type
    from pay_retro_components
    where retro_component_id = p_retro_component_id;

--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'reprocess_type'
    ,p_argument_value => p_reprocess_type
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );

  hr_utility.set_location(l_proc, 15);
  --
  -- Check if the retro component usage is being updated and ensure that
  -- g_old_rec contains the values for this retro_component_usage_id.
  --
  l_api_updating :=
    pay_rcu_shd.api_updating
      (p_retro_component_usage_id => p_retro_component_usage_id
      ,p_object_version_number    => p_object_version_number);

  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert.
  --
  if ((l_api_updating and
       pay_rcu_shd.g_old_rec.reprocess_type <> p_reprocess_type)
     or
       NOT l_api_updating) then
     --
     hr_utility.set_location(l_proc, 30);

     if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date
         ,p_lookup_type    => 'RETRO_REPROCESS_TYPE'
         ,p_lookup_code    => p_reprocess_type
         ) then


       fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
       fnd_message.set_token('COLUMN','REPROCESS_TYPE');
       fnd_message.set_token('LOOKUP_TYPE','RETRO_REPROCESS_TYPE');
       fnd_message.raise_error;

     end if;

     --
     -- If parent retro component is Full Recalcuration, the reprocess type
     -- must be R(Reprocessed).
     --
     open csr_retro_type;
     fetch csr_retro_type into l_retro_type;
     close csr_retro_type;
     if l_retro_type = 'F'
        and p_reprocess_type <> 'R' then

       fnd_message.set_name('PAY','PAY_33169_RCU_INV_RPRC_TYPE');
       fnd_message.raise_error;

     end if;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_reprocess_type;
--
--
-- -------------------------------------------------------------------------
-- |-----------------------< chk_default_component >-----------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the default_component exists in lookup type YES_NO.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_component_usage_id
--   p_object_version_number
--   p_creator_type
--   p_creator_id
--   p_default_component
--   p_effective_date
--   p_business_group_id
--   p_legislation_code
--
--
-- Post Success:
--   Processing continues if the default component is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   default component is invalid.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_default_component
  (p_retro_component_usage_id in pay_retro_component_usages.retro_component_usage_id%type
  ,p_object_version_number    in pay_retro_component_usages.object_version_number%type
  ,p_creator_type             in pay_retro_component_usages.creator_type%type
  ,p_creator_id               in pay_retro_component_usages.creator_id%type
  ,p_default_component        in pay_retro_component_usages.default_component%type
  ,p_effective_date           in date
  ,p_business_group_id        in pay_retro_component_usages.business_group_id%type
  ,p_legislation_code         in pay_retro_component_usages.legislation_code%type
  )
is
  --
  -- Declare local variables
  --
  l_proc           varchar2(72) := g_package||'chk_default_component';
  l_api_updating   boolean;
  l_exists         varchar2(1);
  l_number         number       := hr_api.g_number;

  --
  -- Cursor to check that a default retro component usage exists.
  --
  -- Bug 4435617. Consider business_group_id and legislation_code
  -- while checking for the default component.

  cursor csr_default_component_usage is
    select null
      from pay_retro_component_usages
     where creator_type = p_creator_type
       and creator_id = p_creator_id
       and retro_component_usage_id <> nvl(p_retro_component_usage_id, l_number)
       and default_component = 'Y'
       and (( business_group_id = p_business_group_id and
              legislation_code is null )
            or
            (legislation_code = p_legislation_code and
             business_group_id is null )
            or
            (legislation_code is null and
             business_group_id is null )
           );


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'default_component'
    ,p_argument_value => p_default_component
    );
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_utility.set_location(l_proc, 15);
  --
  -- Check if the retro component usage is being updated and ensure that
  -- g_old_rec contains the values for this retro_component_usage_id.
  --
  l_api_updating :=
    pay_rcu_shd.api_updating
      (p_retro_component_usage_id => p_retro_component_usage_id
      ,p_object_version_number    => p_object_version_number);

  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert.
  --
  if ((l_api_updating and
       pay_rcu_shd.g_old_rec.default_component <> p_default_component)
     or
       NOT l_api_updating) then
     --
     hr_utility.set_location(l_proc, 30);

     if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date
         ,p_lookup_type    => 'YES_NO'
         ,p_lookup_code    => p_default_component
         ) then


       fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
       fnd_message.set_token('COLUMN','DEFAULT_COMPONENT');
       fnd_message.set_token('LOOKUP_TYPE','YES_NO');
       fnd_message.raise_error;

     end if;
     hr_utility.set_location(l_proc, 35);

     --
     -- If the default_component is set to Y, ensure another retro component
     -- usage does not exist whose default_component being set to Y.
     --
     if p_default_component = 'Y' then

       hr_utility.set_location(l_proc, 40);
       open csr_default_component_usage;
       fetch csr_default_component_usage into l_exists;
       if csr_default_component_usage%found then
         close csr_default_component_usage;

         fnd_message.set_name('PAY','PAY_33162_RCU_TOO_MANY_DEF');
         fnd_message.raise_error;

       end if;
       close csr_default_component_usage;

     end if;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_default_component;
--
--
-- -------------------------------------------------------------------------
-- |-----------------------< chk_replace_run_flag >------------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that replace_run_flag value exists in lookup type YES_NO and
--   the value is allowed for the recalculation_style of the component.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_component_usage_id
--   p_retro_component_id
--   p_object_version_number
--   p_replace_run_flag
--   p_effective_date
--
--
-- Post Success:
--   Processing continues if the replace run flag is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   replace run flag is invalid.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_replace_run_flag
  (p_retro_component_usage_id in pay_retro_component_usages.retro_component_usage_id%type
  ,p_retro_component_id       in pay_retro_component_usages.retro_component_id%type
  ,p_object_version_number    in pay_retro_component_usages.object_version_number%type
  ,p_replace_run_flag         in pay_retro_component_usages.replace_run_flag%type
  ,p_effective_date           in date
  )
is
  --
  -- Declare local variables
  --
  l_proc           varchar2(72) := g_package||'chk_replace_run_flag';
  l_api_updating   boolean;
  l_recalculation_style pay_retro_components.recalculation_style%type;
  --
  --
  cursor csr_recalculation_style is
  select recalculation_style
    from pay_retro_components
    where retro_component_id = p_retro_component_id;
  --
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
  -- Check if the retro component usage is being updated and ensure that
  -- g_old_rec contains the values for this retro_component_usage_id.
  --
  l_api_updating :=
    pay_rcu_shd.api_updating
      (p_retro_component_usage_id => p_retro_component_usage_id
      ,p_object_version_number    => p_object_version_number);

  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed.
  -- b) During insert.
  --
  if ((l_api_updating and
       pay_rcu_shd.g_old_rec.replace_run_flag <> p_replace_run_flag )
     or
       NOT l_api_updating) then
     --
     hr_utility.set_location(l_proc, 30);

     if p_replace_run_flag is not null then

	     if p_replace_run_flag = 'Y' then

		open csr_recalculation_style;
		fetch csr_recalculation_style into l_recalculation_style;
		close csr_recalculation_style;

		if l_recalculation_style is null or l_recalculation_style <> 'R' then
			fnd_message.set_name('PAY','PAY_33194_RCU_INVALID_COMB');
			fnd_message.set_token('FLAG','REPLACE_RUN_FLAG');
			fnd_message.raise_error;
		end if;

	     end if;

	     if hr_api.not_exists_in_hr_lookups
		 (p_effective_date => p_effective_date
	         ,p_lookup_type    => 'YES_NO'
	         ,p_lookup_code    => p_replace_run_flag
		 ) then

	       fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	       fnd_message.set_token('COLUMN','REPLACE_RUN_FLAG');
	       fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	       fnd_message.raise_error;

	     end if;
     end if;
     hr_utility.set_location(l_proc, 35);

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_replace_run_flag;
--
--
-- -------------------------------------------------------------------------
-- |-----------------------< chk_use_override_dates >----------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that use_override_dates value exists in lookup type YES_NO
--   and value is allowed for the recalculation_style of the component.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_component_usage_id
--   p_retro_component_id
--   p_object_version_number
--   p_use_override_dates
--   p_effective_date
--
--
-- Post Success:
--   Processing continues if the use_override_dates value is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   use_override_dates value is invalid.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_use_override_dates
  (p_retro_component_usage_id in pay_retro_component_usages.retro_component_usage_id%type
  ,p_retro_component_id       in pay_retro_component_usages.retro_component_id%type
  ,p_object_version_number    in pay_retro_component_usages.object_version_number%type
  ,p_use_override_dates       in pay_retro_component_usages.use_override_dates%type
  ,p_effective_date           in date
  )
is
  --
  -- Declare local variables
  --
  l_proc           varchar2(72) := g_package||'chk_use_override_dates';
  l_api_updating   boolean;
  l_recalculation_style pay_retro_components.recalculation_style%type;
  --
  --
  cursor csr_recalculation_style is
  select recalculation_style
    from pay_retro_components
    where retro_component_id = p_retro_component_id;
  --
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
  -- Check if the retro component usage is being updated and ensure that
  -- g_old_rec contains the values for this retro_component_usage_id.
  --
  l_api_updating :=
    pay_rcu_shd.api_updating
      (p_retro_component_usage_id => p_retro_component_usage_id
      ,p_object_version_number    => p_object_version_number);

  hr_utility.set_location(l_proc, 20);
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed.
  -- b) During insert.
  --
  if ((l_api_updating and
       pay_rcu_shd.g_old_rec.use_override_dates <> p_use_override_dates )
     or
       NOT l_api_updating) then
     --
     hr_utility.set_location(l_proc, 30);

     if p_use_override_dates is not null then

	     if p_use_override_dates = 'Y' then

		open csr_recalculation_style;
		fetch csr_recalculation_style into l_recalculation_style;
		close csr_recalculation_style;

		if l_recalculation_style is null or l_recalculation_style <> 'R' then
			fnd_message.set_name('PAY','PAY_33194_RCU_INVALID_COMB');
			fnd_message.set_token('FLAG','USE_OVERRIDE_DATES');
			fnd_message.raise_error;
		end if;

	     end if;

	     if hr_api.not_exists_in_hr_lookups
		 (p_effective_date => p_effective_date
	         ,p_lookup_type    => 'YES_NO'
	         ,p_lookup_code    => p_use_override_dates
		 ) then

	       fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
	       fnd_message.set_token('COLUMN','USE_OVERRIDE_DATES');
	       fnd_message.set_token('LOOKUP_TYPE','YES_NO');
	       fnd_message.raise_error;

	     end if;
     end if;
     hr_utility.set_location(l_proc, 35);

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_use_override_dates;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_rcu_shd.g_rec_type
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
       ,p_associated_column1 => pay_rcu_shd.g_tab_nam
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
  -- Validate Retro Component Id
  --
  chk_retro_component_id
    (p_retro_component_id => p_rec.retro_component_id
    ,p_business_group_id => p_rec.business_group_id
    ,p_legislation_code  => p_rec.legislation_code
    );

  --
  -- Validate Creator Type, Creator ID
  --
  chk_creator_type_creator_id
    (p_creator_type      => p_rec.creator_type
    ,p_creator_id        => p_rec.creator_id
    ,p_business_group_id => p_rec.business_group_id
    ,p_legislation_code  => p_rec.legislation_code
    ,p_effective_date    => p_effective_date
    );

  --
  -- Validate Reprocess Type
  --
  chk_reprocess_type
    (p_retro_component_usage_id => p_rec.retro_component_usage_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_retro_component_id       => p_rec.retro_component_id
    ,p_reprocess_type           => p_rec.reprocess_type
    ,p_effective_date           => p_effective_date
    );

  --
  -- Validate Default Component
  --
  chk_default_component
    (p_retro_component_usage_id => p_rec.retro_component_usage_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_creator_type             => p_rec.creator_type
    ,p_creator_id               => p_rec.creator_id
    ,p_default_component        => p_rec.default_component
    ,p_effective_date           => p_effective_date
    ,p_business_group_id        => p_rec.business_group_id
    ,p_legislation_code         => p_rec.legislation_code
    );

  --
  -- Validate Replace Run Flag.
  --
  chk_replace_run_flag
    (p_retro_component_usage_id => p_rec.retro_component_usage_id
    ,p_retro_component_id	=> p_rec.retro_component_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_replace_run_flag         => p_rec.replace_run_flag
    ,p_effective_date           => p_effective_date
    );

  --
  -- Validate Use Override Dates.
  --
  chk_use_override_dates
    (p_retro_component_usage_id => p_rec.retro_component_usage_id
    ,p_retro_component_id	=> p_rec.retro_component_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_use_override_dates       => p_rec.use_override_dates
    ,p_effective_date           => p_effective_date
    );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_rcu_shd.g_rec_type
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
       ,p_associated_column1 => pay_rcu_shd.g_tab_nam
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

  --
  -- Validate Reprocess Type
  --
  chk_reprocess_type
    (p_retro_component_usage_id => p_rec.retro_component_usage_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_retro_component_id       => p_rec.retro_component_id
    ,p_reprocess_type           => p_rec.reprocess_type
    ,p_effective_date           => p_effective_date
    );

  --
  -- Validate Default Component
  --
  chk_default_component
    (p_retro_component_usage_id => p_rec.retro_component_usage_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_creator_type             => p_rec.creator_type
    ,p_creator_id               => p_rec.creator_id
    ,p_default_component        => p_rec.default_component
    ,p_effective_date           => p_effective_date
    ,p_business_group_id        => p_rec.business_group_id
    ,p_legislation_code         => p_rec.legislation_code
    );

  --
  -- Validate Replace Run Flag.
  --
  chk_replace_run_flag
    (p_retro_component_usage_id => p_rec.retro_component_usage_id
    ,p_retro_component_id	=> p_rec.retro_component_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_replace_run_flag         => p_rec.replace_run_flag
    ,p_effective_date           => p_effective_date
    );

  --
  -- Validate Use Override Dates.
  --
  chk_use_override_dates
    (p_retro_component_usage_id => p_rec.retro_component_usage_id
    ,p_retro_component_id	=> p_rec.retro_component_id
    ,p_object_version_number    => p_rec.object_version_number
    ,p_use_override_dates       => p_rec.use_override_dates
    ,p_effective_date           => p_effective_date
    );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_rcu_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,pay_rcu_shd.g_old_rec.business_group_id
                    ,pay_rcu_shd.g_old_rec.legislation_code
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
end pay_rcu_bus;

/
