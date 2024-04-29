--------------------------------------------------------
--  DDL for Package Body IRC_CMC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMC_BUS" as
/* $Header: ircmcrhi.pkb 120.0 2007/11/19 11:04:15 sethanga noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_cmc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_communication_id            number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_communication_id                     in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_communications and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , irc_communications cmc
      --   , EDIT_HERE table_name(s) 333
     where cmc.communication_id = p_communication_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'communication_id'
    ,p_argument_value     => p_communication_id
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
        => nvl(p_associated_column1,'COMMUNICATION_ID')
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
  (p_communication_id                     in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_communications and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , irc_communications cmc
      --   , EDIT_HERE table_name(s) 333
     where cmc.communication_id = p_communication_id;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
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
    ,p_argument           => 'communication_id'
    ,p_argument_value     => p_communication_id
    );
  --
  if ( nvl(irc_cmc_bus.g_communication_id, hr_api.g_number)
       = p_communication_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_cmc_bus.g_legislation_code;
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
    irc_cmc_bus.g_communication_id            := p_communication_id;
    irc_cmc_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in irc_cmc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_cmc_shd.api_updating
      (p_communication_id                  => p_rec.communication_id
      ,p_object_version_number             => p_rec.object_version_number
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
  IF p_rec.object_type <>
     irc_cmc_shd.g_old_rec.object_type then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'OBJECT_TYPE'
     ,p_base_table => irc_cmc_shd.g_tab_nam
     );
  END IF;
  --
  IF p_rec.object_id <> irc_cmc_shd.g_old_rec.object_id  THEN
    IF p_rec.object_type = 'APPL' THEN
      hr_api.argument_changed_error
      ( p_api_name     => l_proc
       ,p_argument     => 'APPLICATION_ID'
       ,p_base_table   => irc_cmc_shd.g_tab_nam
      );
     END IF;
  END IF;

   IF p_rec.communication_property_id <>
     irc_cmc_shd.g_old_rec.communication_property_id then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'COMMUNICATION_PROPERTY_ID'
     ,p_base_table => irc_cmc_shd.g_tab_nam
     );
  END IF;

    IF p_rec.start_date <>
     irc_cmc_shd.g_old_rec.start_date then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'START_DATE'
     ,p_base_table => irc_cmc_shd.g_tab_nam
     );
  END IF;

End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_status >--------------------------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This process validates that 'status' exists in the lookup
--   IRC_COMM_STATUS
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   status                     varchar2(50) communication status
--   communication_id           number(15)   PK of irc_communications
--   effective_date             date         date record effective
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised for the following faliure conditions:
--   1: p_status does not exist in lookup IRC_COMM_STATUS
--
-- Access Status:
--   Internal Table Handler Use Only.
Procedure chk_status(p_status in varchar2,
                          p_communication_id in number,
                          p_effective_date in date,
		          p_object_version_number in number) is
--
  l_proc varchar2(72) := g_package||'chk_status';
  l_api_updating boolean;
--
begin
    hr_utility.set_location('Entering: '|| l_proc, 10);
    l_api_updating := irc_cmc_shd.api_updating
           (p_communication_id   => p_communication_id,
            p_object_version_number       => p_object_version_number);
    --
    if (l_api_updating
      and nvl(p_status,hr_api.g_varchar2)
          <> nvl(irc_cmc_shd.g_old_rec.status,hr_api.g_varchar2)
      or not l_api_updating) then
      --
      -- check if value of type falls within lookup.
      --
      if hr_api.not_exists_in_hr_lookups(p_lookup_type    => 'IRC_COMM_STATUS',
                                         p_lookup_code    => p_status,
                                         p_effective_date => sysdate)
                                        then
        --
        -- raise error as does not exist as lookup
        --
        hr_utility.set_location('Leaving: '|| l_proc, 20);
       fnd_message.set_name('PER','IRC_412416_INVALID_COMM_STATUS');
       fnd_message.raise_error;
      end if;
    end if;
    hr_utility.set_location('Leaving: '|| l_proc, 30);
end chk_status;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_object_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure -
--  1) that object_id exists in PER_ALL_ASSIGNMENTS_F
--     when the object_type is 'APPL'
--  2) that combination of (object_id,object_type) is
--     unique.
--
-- Pre Conditions:
--
-- In Arguments:
--  p_object_id
--  p_object_type
--
-- Post Success:
--  Processing continues if object_id is valid.
--
-- Post Failure:
--   An application error is raised if object_id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_object_id
  (p_object_id in irc_communications.object_id%TYPE,
   p_object_type in irc_communications.object_type%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_object_id';
  l_object_id varchar2(1);
  l_object_type varchar2(1);
--
  cursor csr_object_id is
    select null
    from per_all_assignments_f paaf
    where paaf.assignment_id = p_object_id
    and assignment_type = 'A';
--
  cursor csr_object_type is
    select null
    from irc_communications ic
    where ic.object_id = p_object_id
     and  ic.object_type = p_object_type;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
-- Check that object_id is not null.
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'OBJECT_ID'
  ,p_argument_value     => p_object_id
  );

-- Check that object_type is not null.
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'OBJECT_TYPE'
  ,p_argument_value     => p_object_type
  );

-- Check that object_id exists in per_all_assignments_f
  hr_utility.set_location(l_proc,20);
  open csr_object_id;
  fetch csr_object_id into l_object_id;
  hr_utility.set_location(l_proc,30);
  if csr_object_id%NOTFOUND then
    close csr_object_id;
     fnd_message.set_name('PER','IRC_412417_BAD_COMM_OBJ_ID');
     fnd_message.raise_error;
  end if;
  close csr_object_id;

-- Check that combination of (object_id,object_type) is unique.

  open csr_object_type;
  fetch csr_object_type into l_object_type;
  hr_utility.set_location(l_proc,40);
  if csr_object_type%FOUND then
    close csr_object_type;
    fnd_message.set_name('PER','IRC_412418_OBJID_OBJTYP_NOT_UNQ');
    fnd_message.raise_error;
  end if;
  close csr_object_type;

  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_COMMUNICATIONS.OBJECT_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_object_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_object_type >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that object_type has one of the following
--   values :
--   'APPL'
--
-- Pre Conditions:
--
-- In Arguments:
--  p_object_type
--
-- Post Success:
--  Processing continues if object_type is valid.
--
-- Post Failure:
--   An application error is raised if object_type is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_object_type
  (p_object_type in irc_communications.object_type%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_object_type';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
-- Check that object_type is not null.
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'OBJECT_TYPE'
  ,p_argument_value     => p_object_type
  );

   if p_object_type <> 'APPL' then
    fnd_message.set_name('PER','IRC_412419_BAD_OBJECT_TYPE');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,20);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 =>
       'IRC_COMMUNICATIONS.OBJECT_TYPE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,30);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,40);
end chk_object_type;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_start_end_date >------------------------------|
--  ---------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check that the end_date is later than the
--   start_date.
--
-- Pre Conditions:
--   None.
--
-- In Parameters:
--   communication_id           number(15)   PK of irc_communications
--   start_date                 date         start date of communication
--   end_date                   date         end date of communication
--   object_version_number      number(9)    version of row
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Errors handled by the procedure.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
Procedure chk_start_end_date(p_start_date in date,
                             p_end_date in date,
                             p_communication_id in number,
                             p_object_version_number in number) is
--
  l_proc varchar2(72) := g_package||'chk_start_end_date';
  l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering: '|| l_proc, 10);
    l_api_updating := irc_cmc_shd.api_updating
           (p_communication_id   => p_communication_id,
            p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and (nvl(p_start_date,hr_api.g_date)
     <>  nvl(irc_cmc_shd.g_old_rec.start_date,hr_api.g_date)
     or  nvl(p_end_date,hr_api.g_date)
     <>  nvl(irc_cmc_shd.g_old_rec.end_date,hr_api.g_date))
     or not l_api_updating) then
    --
    -- check if end date is greater than start date
    --
    if p_start_date > nvl(p_end_date,hr_api.g_eot) then
      --
      -- raise error as start date should be less than or equal to end date.
      --
      fnd_message.set_name('PER','IRC_412420_START_DATE_BEFORE_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
End chk_start_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_update_validate >----------------------|
-- ----------------------------------------------------------------------------
Procedure insert_update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_update_validate';
--
Begin
--
   irc_cmc_bus.chk_status
   (
    p_rec.status,
    p_rec.communication_id,
    p_effective_date,
    p_rec.object_version_number
   );

   irc_cmc_bus.chk_start_end_date
   ( p_rec.start_date,
     p_rec.end_date,
     p_rec.communication_id,
     p_rec.object_version_number
   );
--
End insert_update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmc_shd.g_rec_type
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
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
      irc_cmc_bus.insert_update_validate(p_effective_date, p_rec);
      irc_cmc_bus.chk_object_type(p_rec.object_type);
      irc_cmc_bus.chk_object_id(p_rec.object_id, p_rec.object_type);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmc_shd.g_rec_type
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
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  irc_cmc_bus.insert_update_validate(p_effective_date, p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_cmc_shd.g_rec_type
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
end irc_cmc_bus;

/
