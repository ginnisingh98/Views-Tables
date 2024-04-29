--------------------------------------------------------
--  DDL for Package Body PAY_EVG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVG_BUS" as
/* $Header: pyevgrhi.pkb 120.4 2005/11/07 09:03:07 mkataria noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_evg_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_event_group_id              number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_event_group_id                       in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_event_groups evg
     where evg.event_group_id = p_event_group_id
       and pbg.business_group_id = evg.business_group_id;
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
    ,p_argument           => 'event_group_id'
    ,p_argument_value     => p_event_group_id
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
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_event_group_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_event_groups evg
     where evg.event_group_id = p_event_group_id
       and pbg.business_group_id (+) = evg.business_group_id;
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
    ,p_argument           => 'event_group_id'
    ,p_argument_value     => p_event_group_id
    );
  --
  if ( nvl(pay_evg_bus.g_event_group_id, hr_api.g_number)
       = p_event_group_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_evg_bus.g_legislation_code;
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
    pay_evg_bus.g_event_group_id    := p_event_group_id;
    pay_evg_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in pay_evg_shd.g_rec_type
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
  IF NOT pay_evg_shd.api_updating
      (p_event_group_id                       => p_rec.event_group_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if (nvl(p_rec.event_group_name, hr_api.g_varchar2) <>
     nvl(pay_evg_shd.g_old_rec.event_group_name, hr_api.g_varchar2)
      ) THEN
     l_argument := 'event_group_name';
     raise l_error;
  END IF;
  --
  if (nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_evg_shd.g_old_rec.business_group_id,hr_api.g_number)
     ) then
     l_argument := 'business_group_id';
     raise l_error;
  END IF;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_evg_shd.g_old_rec.legislation_code, hr_api.g_varchar2)
  then
    l_argument := 'p_legislation_code';
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
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_unique_key >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the row being inserted or updated does
--   not already exists on the database, i.e, has the same event_group_name.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_unique_key ( p_rec in pay_evg_shd.g_rec_type ) is
--
    l_exists    varchar2(1);
    l_proc      varchar2(72) := g_package||'chk_unique_key';
--
    cursor C1 is
    select 'Y'
    from  pay_event_groups peg
    where peg.event_group_name = p_rec.event_group_name
    and ( nvl(peg.business_group_id,p_rec.business_group_id) = p_rec.business_group_id)
    and ( nvl(peg.legislation_code,p_rec.legislation_code)= p_rec.legislation_code);
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 1);
   --
  open C1;
   fetch C1 into l_exists;
   if C1%found then
     hr_utility.set_location(l_proc, 3);
     -- row is not unique
     close C1;
     pay_evg_shd.constraint_error('PAY_EVENT_GROUPS_UK1');
   end if;
   close C1;
   --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
--
end chk_unique_key;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_event_group_type >------------------------
-- ----------------------------------------------------------------------------
Procedure chk_event_group_type
      (p_effective_date in date
      ,p_rec            in pay_evg_shd.g_rec_type) is
--
  l_proc        varchar2(72) := g_package || 'chk_event_group_type';
  l_error       EXCEPTION;
  l_argument    varchar2(30);
  --
--
Begin
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'event_group_type'
    ,p_argument_value => p_rec.event_group_type
    );
  --
  if hr_api.not_exists_in_hrstanlookups(p_effective_date => p_effective_date
                                       ,p_lookup_type    => 'EVENT_GROUP_TYPE'
                                       ,p_lookup_code    => p_rec.event_group_type) then
    --
    -- The event_group_type for this record is not recognised
    --
    fnd_message.set_name('PAY','HR_xxxx_INVALID_EVENT_GROUP');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function.
  --
end chk_event_group_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_proration_type >--------------------------
-- ----------------------------------------------------------------------------
Procedure chk_proration_type
      (p_effective_date in date
      ,p_rec            in pay_evg_shd.g_rec_type) is
--
  l_proc        varchar2(72) := g_package || 'chk_proration_type';
  l_error       EXCEPTION;
  l_argument    varchar2(30);
  --
--
Begin
  --
  if (p_rec.event_group_type = 'P') then
    if hr_api.not_exists_in_hrstanlookups
       (p_effective_date => p_effective_date
       ,p_lookup_type    => 'PRORATION_PERIOD_TYPE'
       ,p_lookup_code    => p_rec.proration_type) then
      --
      -- The proration_type for this record is not recognised
      --
      fnd_message.set_name('PAY','HR_xxxx_INVALID_PERIOD_TYPE');
      fnd_message.raise_error;
    end if;
  else
    if p_rec.proration_type is not null then
      fnd_message.set_name('PAY','HR_xxxx_INVALID_PERIOD_TYPE');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function.
  --
end chk_proration_type;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_delete
(p_event_group_id in number
) is
--
-- Only interested in child rows from PAY_EVENT_GROUP_USAGES.
--
cursor csr_child_exist
(p_event_group_id in number
) is
select 'Y'
from   pay_event_group_usages egu
where  egu.event_group_id = p_event_group_id;
--
l_ret  varchar2(1);
begin
  open csr_child_exist(p_event_group_id => p_event_group_id);
  fetch csr_child_exist into l_ret;
  if csr_child_exist%found then
    close csr_child_exist;
    fnd_message.set_name('PAY', 'PAY_294526_ECU_CHILD_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_child_exist;
exception
  when others then
    if csr_child_exist%isopen then
      close csr_child_exist;
    end if;
    raise;
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pay_evg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Commenting this out as business group can be null
  --hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_unique_key  (p_rec => p_rec);
  --
  chk_event_group_type (p_effective_date => p_effective_date
                       ,p_rec => p_rec);
  --
  chk_proration_type (p_effective_date => p_effective_date
                       ,p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pay_evg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Commenting this out as business group can be null
  --hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --chk_unique_key  (p_rec => p_rec);
  --
  chk_event_group_type (p_effective_date => p_effective_date
                       ,p_rec => p_rec);
  --
  chk_proration_type (p_effective_date => p_effective_date
                       ,p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_evg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_event_group_id => p_rec.event_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_evg_bus;

/
