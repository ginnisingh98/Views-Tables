--------------------------------------------------------
--  DDL for Package Body PAY_PEV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PEV_BUS" as
/* $Header: pypperhi.pkb 120.1.12010000.1 2008/07/27 23:25:17 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_pev_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_process_event_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_process_event_id                     in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_process_events pev
     where pev.process_event_id = p_process_event_id
       and pbg.business_group_id = pev.business_group_id;
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
    ,p_argument           => 'process_event_id'
    ,p_argument_value     => p_process_event_id
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
  (p_process_event_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_process_events pev
     where pev.process_event_id = p_process_event_id
       and pbg.business_group_id (+) = pev.business_group_id;
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
    ,p_argument           => 'process_event_id'
    ,p_argument_value     => p_process_event_id
    );
  --
  if ( nvl(pay_pev_bus.g_process_event_id, hr_api.g_number)
       = p_process_event_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_pev_bus.g_legislation_code;
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
    pay_pev_bus.g_process_event_id  := p_process_event_id;
    pay_pev_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_pev_shd.g_rec_type
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
  IF NOT pay_pev_shd.api_updating
      (p_process_event_id                     => p_rec.process_event_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  -- p_assignment_id
  --
  if nvl(p_rec.assignment_id, hr_api.g_number) <>
     nvl(pay_pev_shd.g_old_rec.assignment_id, hr_api.g_number)
  then
    l_argument := 'p_assignment_id';
    raise l_error;
  end if;
  --
  -- p_effective_date
  --
  if nvl(p_rec.effective_date, hr_api.g_date) <>
     nvl(pay_pev_shd.g_old_rec.effective_date, hr_api.g_date)
  then
    l_argument := 'p_effective_date';
    raise l_error;
  end if;
  --
  -- p_change_type
  --
  if nvl(p_rec.change_type, hr_api.g_varchar2) <>
     nvl(pay_pev_shd.g_old_rec.change_type, hr_api.g_varchar2)
  then
    l_argument := 'p_change_type';
    raise l_error;
  end if;
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_pev_shd.g_old_rec.business_group_id, hr_api.g_number)
  then
    l_argument := 'business_group_id';
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
-- |-----------------------< chk_change_type >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the change type is valid for
--   continuous calc.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if the change type is valid
--
-- Post Failure:
--   An application error is raised if any of the change_type is not
--   valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_change_type
  (p_rec in pay_pev_shd.g_rec_type
  ) IS
--
  l_proc        varchar2(72) := g_package || 'chk_change_type';
  l_error       EXCEPTION;
  l_argument    varchar2(30);
  --
--
Begin
  --
  if hr_api.not_exists_in_hrstanlookups(p_effective_date => p_rec.effective_date
                                       ,p_lookup_type    => 'PROCESS_EVENT_TYPE'
                                       ,p_lookup_code    => p_rec.change_type) then
    --
    -- The change_type for this record is not recognised
    --
    fnd_message.set_name('PAY','HR_xxxx_INVALID_EVENT_TYPE');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(l_proc,30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function.
  --
end chk_change_type;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_status >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the status code is valid for
--   continuous calc.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if the status code is valid
--
-- Post Failure:
--   An application error is raised if any of the status is not
--   valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_status
  (p_rec in pay_pev_shd.g_rec_type
  ) IS
--
  l_proc        varchar2(72) := g_package || 'chk_status';
  l_error       EXCEPTION;
  l_argument    varchar2(30);
  --
--
Begin
  --
  if hr_api.not_exists_in_hrstanlookups(p_rec.effective_date,
                                        'PROCESS_EVENT_STATUS',
                                        p_rec.status) then
    --
    -- The status for this record is not recognised
    --
    fnd_message.set_name('PAY','HR_xxxx_INVALID_STATUS_TYPE');
    fnd_message.raise_error;
  end if;

  hr_utility.set_location(l_proc,30);
  --
  -- Set the global variables so the values are
  -- available for the next call to this function.
  --
end chk_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in pay_pev_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_change_type
    (p_rec              => p_rec
    );
  --
  chk_status
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in pay_pev_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  chk_change_type
    (p_rec              => p_rec
    );
  --
  chk_status
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_pev_shd.g_rec_type
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
end pay_pev_bus;

/
