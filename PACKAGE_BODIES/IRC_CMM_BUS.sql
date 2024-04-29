--------------------------------------------------------
--  DDL for Package Body IRC_CMM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMM_BUS" as
/* $Header: ircmmrhi.pkb 120.2 2008/04/14 14:50:29 amikukum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_cmm_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_communication_message_id    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_communication_message_id             in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_comm_messages and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , irc_comm_messages cmm
      --   , EDIT_HERE table_name(s) 333
     where cmm.communication_message_id = p_communication_message_id;
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
    ,p_argument           => 'communication_message_id'
    ,p_argument_value     => p_communication_message_id
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
        => nvl(p_associated_column1,'COMMUNICATION_MESSAGE_ID')
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
  (p_communication_message_id             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_comm_messages and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , irc_comm_messages cmm
      --   , EDIT_HERE table_name(s) 333
     where cmm.communication_message_id = p_communication_message_id;
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
    ,p_argument           => 'communication_message_id'
    ,p_argument_value     => p_communication_message_id
    );
  --
  if ( nvl(irc_cmm_bus.g_communication_message_id, hr_api.g_number)
       = p_communication_message_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_cmm_bus.g_legislation_code;
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
    irc_cmm_bus.g_communication_message_id    := p_communication_message_id;
    irc_cmm_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in irc_cmm_shd.g_rec_type
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
  IF NOT irc_cmm_shd.api_updating
      (p_communication_message_id          => p_rec.communication_message_id
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
    --
  -- Ensure non-updateable args have not been updated.
  --
  if p_rec.communication_topic_id <> irc_cmm_shd.g_old_rec.communication_topic_id
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'COMMUNICATION_TOPIC_ID'
     ,p_base_table => irc_cmm_shd.g_tab_nam
     );
  end if;
  if p_rec.sender_type <> irc_cmm_shd.g_old_rec.sender_type
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'SENDER_TYPE'
     ,p_base_table => irc_cmm_shd.g_tab_nam
     );
  end if;
  if p_rec.sender_id <> irc_cmm_shd.g_old_rec.sender_id
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'SENDER_ID'
     ,p_base_table => irc_cmm_shd.g_tab_nam
     );
  end if;
  if irc_cmm_shd.g_old_rec.message_subject IS NOT NULL AND
     p_rec.message_subject <> irc_cmm_shd.g_old_rec.message_subject
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'MESSAGE_SUBJECT'
     ,p_base_table => irc_cmm_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_comm_topic_id >---------------------------|
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
Procedure chk_comm_topic_id
  (p_topic_id                 in number
  ,p_communication_message_id in number
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_comm_topic_id';
  --
  l_topic_id irc_comm_messages.communication_topic_id%type;
  --
  l_api_updating boolean;
  --
  cursor csr_topic_id is
  select 1
  from irc_comm_topics
  where communication_topic_id = p_topic_id;
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'COMMUNICATION_TOPIC_ID'
  ,p_argument_value     => p_topic_id
  );
  --
  open csr_topic_id;
  fetch csr_topic_id into l_topic_id;
  --
  hr_utility.set_location(l_proc,20);
  --
  if csr_topic_id%notfound then
    close csr_topic_id;
    fnd_message.set_name('PER','IRC_412398_BAD_TOPIC_ID');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  --
  close csr_topic_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_MESSAGES.COMMUNICATION_TOPIC_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,50);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,60);
    --
End chk_comm_topic_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_message_subject >--------------------------|
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
Procedure chk_message_subject
  (p_message_subject    in irc_comm_messages.message_subject%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_message_subject';
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  /*
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'MESSAGE_SUBJECT'
  ,p_argument_value     => p_message_subject
  );
  */
  --
  if length(p_message_subject) > 150 then
    fnd_message.set_name('PER','IRC_412399_LONG_MSG_SUB');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_MESSAGES.MESSAGE_SUBJECT'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,30);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,40);
    --
End chk_message_subject;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_message_body >----------------------------|
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
Procedure chk_message_body
  (p_message_body    in irc_comm_messages.message_body%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_message_body';
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  if p_message_body is null or length(p_message_body) = 0 then
    fnd_message.set_name('PER','IRC_412247_NULL_MSG_BODY');
    fnd_message.raise_error;
  end if;

  if length(p_message_body) > 4000 then
    fnd_message.set_name('PER','IRC_412400_LONG_MSG_BODY');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_MESSAGES.MESSAGE_BODY'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,30);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,40);
    --
End chk_message_body;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_message_post_date >-------------------------|
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
Procedure chk_message_post_date
  (p_message_post_date    in irc_comm_messages.message_post_date%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_message_post_date';
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'MESSAGE_POST_DATE'
  ,p_argument_value     => p_message_post_date
  );
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_MESSAGES.MESSAGE_POST_DATE'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,20);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,30);
    --
End chk_message_post_date;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_sender >------------------------------|
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
Procedure chk_sender
  (p_sender_type    in irc_comm_messages.sender_type%type ,
   p_sender_id      in irc_comm_messages.sender_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_sender';
  l_sender_id             per_all_people_f.person_id%type;
  --
  cursor csr_sender is
  select person_id
  from per_all_people_f
  where person_id = p_sender_id;
--
  cursor csr_sender_agency is
  select vendor_id
  from po_vendors
  where vendor_id = p_sender_id;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'SENDER_TYPE'
  ,p_argument_value     => p_sender_type
  );
  --
  hr_utility.set_location(' Entering:'||l_proc,20);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'SENDER_ID'
  ,p_argument_value     => p_sender_id
  );
  --
  if p_sender_type = 'PERSON' then
    open csr_sender;
    fetch csr_sender into l_sender_id;
    --
    hr_utility.set_location(l_proc,30);
    --
    if csr_sender%notfound then
      close csr_sender;
      fnd_message.set_name('PER','IRC_412401_BAD_SENDER_ID');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,40);
    --
    close csr_sender;
  end if;
  if p_sender_type = 'VENDOR' then
    open csr_sender_agency;
    fetch csr_sender_agency into l_sender_id;
    --
    hr_utility.set_location(l_proc,50);
    --
    if csr_sender_agency%notfound then
      close csr_sender_agency;
      fnd_message.set_name('PER','IRC_412402_BAD_SENDER_ID');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,60);
    --
    close csr_sender_agency;
  end if;

exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_MESSAGES.SENDER_TYPE'
      ,p_associated_column2 => 'IRC_COMM_MESSAGES.SENDER_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,70);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,80);
    --
End chk_sender;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_document >-----------------------------|
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
Procedure chk_document
  (p_document_type    in irc_comm_messages.document_type%type ,
   p_document_id      in irc_comm_messages.document_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_document';
  l_document_id           irc_documents.document_id%type;
  --
  cursor csr_document is
  select document_id
  from irc_documents
  where document_id = p_document_id;
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  if p_document_type = 'IRC_DOC' then
    open csr_document;
    fetch csr_document into l_document_id;
    --
    hr_utility.set_location(l_proc,20);
    --
    if csr_document%notfound then
      close csr_document;
      fnd_message.set_name('PER','IRC_412403_BAD_DOC_ID');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,30);
    --
    close csr_document;
  end if;
  if (p_document_type is null and p_document_id is null) or
     (p_document_type is not null and p_document_id is not null) then
  --it is okay to go ahead
    hr_utility.set_location(l_proc,30);
  else
      fnd_message.set_name('PER','IRC_412404_NULL_DOC_ID');
      fnd_message.raise_error;
  end if;
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_MESSAGES.DOCUMENT_TYPE'
      ,p_associated_column2 => 'IRC_COMM_MESSAGES.DOCUMENT_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,40);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,50);
    --
End chk_document;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_deleted_flag >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_deleted_flag
  (p_deleted_flag    in irc_comm_messages.deleted_flag%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_deleted_flag';
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  if p_deleted_flag <> 'Y' and p_deleted_flag <> 'N' then
  --
  -- raise error
  --
    hr_utility.set_location('Leaving: '|| l_proc, 3);
    hr_utility.set_message(800,'IRC_412421_INVALID_DELETED_FLAG');
    hr_utility.raise_error;
  end if;
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_MESSAGES.DELETED_FLAG'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,20);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,30);
    --
End chk_deleted_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmm_shd.g_rec_type
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
  chk_comm_topic_id(p_topic_id                  => p_rec.communication_topic_id
                   ,p_communication_message_id  => p_rec.communication_message_id);
  --
  chk_message_subject(p_rec.message_subject);
  --
  chk_message_body(p_rec.message_body);
  --
  chk_message_post_date(p_rec.message_post_date);
  --
  chk_sender(p_sender_type => p_rec.sender_type
            ,p_sender_id   => p_rec.sender_id);
  --
  chk_document(p_document_type => p_rec.document_type
               ,p_document_id  => p_rec.document_id);
  --
  chk_deleted_flag(p_rec.deleted_flag);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmm_shd.g_rec_type
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
  chk_comm_topic_id(p_topic_id                  => p_rec.communication_topic_id
                   ,p_communication_message_id  => p_rec.communication_message_id);
  --
  chk_message_subject(p_rec.message_subject);
  --
  chk_message_body(p_rec.message_body);
  --
  chk_message_post_date(p_rec.message_post_date);
  --
  chk_sender(p_sender_type => p_rec.sender_type
            ,p_sender_id   => p_rec.sender_id);
  --
  chk_document(p_document_type => p_rec.document_type
               ,p_document_id  => p_rec.document_id);
  --
  chk_deleted_flag(p_rec.deleted_flag);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_cmm_shd.g_rec_type
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
end irc_cmm_bus;

/
