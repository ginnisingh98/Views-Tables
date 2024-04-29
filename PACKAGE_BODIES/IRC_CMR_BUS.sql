--------------------------------------------------------
--  DDL for Package Body IRC_CMR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMR_BUS" as
/* $Header: ircmrrhi.pkb 120.1 2008/04/14 14:51:14 amikukum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_cmr_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_communication_recipient_id  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_communication_recipient_id           in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_comm_recipients and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , irc_comm_recipients cmr
      --   , EDIT_HERE table_name(s) 333
     where cmr.communication_recipient_id = p_communication_recipient_id;
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
    ,p_argument           => 'communication_recipient_id'
    ,p_argument_value     => p_communication_recipient_id
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
        => nvl(p_associated_column1,'COMMUNICATION_RECIPIENT_ID')
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
  (p_communication_recipient_id           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_comm_recipients and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , irc_comm_recipients cmr
      --   , EDIT_HERE table_name(s) 333
     where cmr.communication_recipient_id = p_communication_recipient_id;
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
    ,p_argument           => 'communication_recipient_id'
    ,p_argument_value     => p_communication_recipient_id
    );
  --
  if ( nvl(irc_cmr_bus.g_communication_recipient_id, hr_api.g_number)
       = p_communication_recipient_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_cmr_bus.g_legislation_code;
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
    irc_cmr_bus.g_communication_recipient_id  := p_communication_recipient_id;
    irc_cmr_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in irc_cmr_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_cmr_shd.api_updating
      (p_communication_recipient_id        => p_rec.communication_recipient_id
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
  if p_rec.communication_object_type <> irc_cmr_shd.g_old_rec.communication_object_type
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'COMMUNICATION_OBJECT_TYPE'
     ,p_base_table => irc_cmr_shd.g_tab_nam
     );
  end if;
  --
  if p_rec.communication_object_id <> irc_cmr_shd.g_old_rec.communication_object_id
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'COMMUNICATION_OBJECT_ID'
     ,p_base_table => irc_cmr_shd.g_tab_nam
     );
  end if;
  if p_rec.recipient_type <> irc_cmr_shd.g_old_rec.recipient_type
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'RECIPIENT_TYPE'
     ,p_base_table => irc_cmr_shd.g_tab_nam
     );
  end if;
  --
  if p_rec.recipient_id <> irc_cmr_shd.g_old_rec.recipient_id
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'RECIPIENT_ID'
     ,p_base_table => irc_cmr_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_communication_object >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- In Arguments:
--
-- Post Success:
--
-- Post Failure:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_communication_object
  (p_communication_object_type    in irc_comm_recipients.communication_object_type%type ,
   p_communication_object_id      in irc_comm_recipients.communication_object_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_communication_object';
  l_comm_object_id           irc_comm_topics.communication_topic_id%type;
  --
  cursor csr_comm_topic is
  select communication_topic_id
  from irc_comm_topics
  where communication_topic_id = p_communication_object_id;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'COMMUNICATION_OBJECT_TYPE'
  ,p_argument_value     => p_communication_object_type
  );
  --
  hr_utility.set_location(' Entering:'||l_proc,20);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'COMMUNICATION_OBJECT_ID'
  ,p_argument_value     => p_communication_object_id
  );
  --
  if p_communication_object_type = 'TOPIC' then
    open csr_comm_topic;
    fetch csr_comm_topic into l_comm_object_id;
    --
    hr_utility.set_location(l_proc,30);
    --
    if csr_comm_topic%notfound then
      close csr_comm_topic;
      fnd_message.set_name('PER','IRC_412393_BAD_COMM_OBJ_ID');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,40);
    --
    close csr_comm_topic;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_RECIPIENTS.COMMUNICATION_OBJECT_TYPE'
      ,p_associated_column2 => 'IRC_COMM_RECIPIENTS.COMMUNICATION_OBJECT_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,50);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,60);
    --
End chk_communication_object;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_recipient >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- In Arguments:
--
-- Post Success:
--
-- Post Failure:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_recipient
  (p_recipient_type    in irc_comm_recipients.recipient_type%type ,
   p_recipient_id      in irc_comm_recipients.recipient_id%type ,
   p_communication_object_type in irc_comm_recipients.communication_object_type%type,
   p_communication_object_id   in irc_comm_recipients.communication_object_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_recipient';
  l_recipient_id          per_all_people_f.person_id%type;
  --
  cursor csr_recipient_person is
  select person_id
  from per_all_people_f
  where person_id = p_recipient_id;
  --
  cursor csr_recipient_agency is
  select vendor_id
  from po_vendors
  where vendor_id = p_recipient_id;
  --
  cursor csr_recipient is
  select communication_recipient_id
  from irc_comm_recipients
  where communication_object_type = p_communication_object_type
  and communication_object_id = p_communication_object_id
  and recipient_type = p_recipient_type
  and recipient_id = p_recipient_id;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'RECIPIENT_TYPE'
  ,p_argument_value     => p_recipient_type
  );
  --
  hr_utility.set_location(' Entering:'||l_proc,20);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'RECIPIENT_ID'
  ,p_argument_value     => p_recipient_id
  );
  --
  if p_recipient_type = 'PERSON' then
    open csr_recipient_person;
    fetch csr_recipient_person into l_recipient_id;
    --
    hr_utility.set_location(l_proc,30);
    --
    if csr_recipient_person%notfound then
      close csr_recipient_person;
      fnd_message.set_name('PER','IRC_412394_BAD_RECIPIENT_ID');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,40);
    --
    close csr_recipient_person;
  end if;
    if p_recipient_type = 'AGENCY' then
    open csr_recipient_agency;
    fetch csr_recipient_agency into l_recipient_id;
    --
    hr_utility.set_location(l_proc,50);
    --
    if csr_recipient_agency%notfound then
      close csr_recipient_agency;
      fnd_message.set_name('PER','IRC_412395_BAD_RECIPIENT_ID');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,60);
    --
    close csr_recipient_agency;
  end if;
  open csr_recipient;
  fetch csr_recipient into l_recipient_id;
  --
  hr_utility.set_location(l_proc,70);
  --
  if csr_recipient%found then
    close csr_recipient;
    fnd_message.set_name('PER','IRC_412396_ALREADY_RECIPIENT');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,80);
  --
  close csr_recipient;
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_RECIPIENTS.RECIPIENT_TYPE'
      ,p_associated_column2 => 'IRC_COMM_RECIPIENTS.RECIPIENT_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,90);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,100);
    --
End chk_recipient;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_active_dates >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- In Arguments:
--
-- Post Success:
--
-- Post Failure:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_active_dates
  (p_start_date_active    in irc_comm_recipients.start_date_active%type
  ,p_end_date_active    in irc_comm_recipients.end_date_active%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_active_dates';
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'MESSAGE_POST_DATE'
  ,p_argument_value     => p_start_date_active
  );
  --
  if p_start_date_active > nvl(p_end_date_active,p_start_date_active) then
    fnd_message.set_name('PER','IRC_412397_START_DATE_BEFORE_END');
    fnd_message.raise_error;
  end if;
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_RECIPIENTS.START_DATE_ACTIVE'
      ,p_associated_column2 => 'IRC_COMM_RECIPIENTS.END_DATE_ACTIVE'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,20);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,30);
    --
End chk_active_dates;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_primary_flag >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_primary_flag
  (p_primary_flag    in irc_comm_recipients.primary_flag%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_primary_flag';
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  if p_primary_flag <> 'Y' and p_primary_flag <> 'N' then
  --
  -- raise error
  --
    hr_utility.set_location('Leaving: '|| l_proc, 20);
    hr_utility.set_message(800,'IRC_412398_INVALID_PRIMARY_FLAG');
    hr_utility.raise_error;
  end if;
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_RECIPIENTS.PRIMARY_FLAG'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,30);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,40);
    --
End chk_primary_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmr_shd.g_rec_type
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
  chk_communication_object
  (p_communication_object_type => p_rec.communication_object_type
  ,p_communication_object_id   => p_rec.communication_object_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  chk_recipient
  (p_recipient_type => p_rec.recipient_type
  ,p_recipient_id   => p_rec.recipient_id
  ,p_communication_object_type => p_rec.communication_object_type
  ,p_communication_object_id   => p_rec.communication_object_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
  chk_active_dates
  (p_start_date_active => p_rec.start_date_active
  ,p_end_date_active   => p_rec.end_date_active);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
  chk_primary_flag(p_rec.primary_flag);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmr_shd.g_rec_type
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  chk_communication_object
  (p_communication_object_type => p_rec.communication_object_type
  ,p_communication_object_id   => p_rec.communication_object_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
  chk_recipient
  (p_recipient_type => p_rec.recipient_type
  ,p_recipient_id   => p_rec.recipient_id
  ,p_communication_object_type => p_rec.communication_object_type
  ,p_communication_object_id   => p_rec.communication_object_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
  chk_active_dates
  (p_start_date_active => p_rec.start_date_active
  ,p_end_date_active   => p_rec.end_date_active);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  chk_primary_flag(p_rec.primary_flag);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_cmr_shd.g_rec_type
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
end irc_cmr_bus;

/
