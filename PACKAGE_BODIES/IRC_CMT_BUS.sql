--------------------------------------------------------
--  DDL for Package Body IRC_CMT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMT_BUS" as
/* $Header: ircmtrhi.pkb 120.1 2008/03/18 14:03:16 amikukum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_cmt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_communication_topic_id      number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_communication_topic_id               in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_comm_topics and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , irc_comm_topics cmt
      --   , EDIT_HERE table_name(s) 333
     where cmt.communication_topic_id = p_communication_topic_id;
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
    ,p_argument           => 'communication_topic_id'
    ,p_argument_value     => p_communication_topic_id
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
        => nvl(p_associated_column1,'COMMUNICATION_TOPIC_ID')
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
  (p_communication_topic_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- irc_comm_topics and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , irc_comm_topics cmt
      --   , EDIT_HERE table_name(s) 333
     where cmt.communication_topic_id = p_communication_topic_id;
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
    ,p_argument           => 'communication_topic_id'
    ,p_argument_value     => p_communication_topic_id
    );
  --
  if ( nvl(irc_cmt_bus.g_communication_topic_id, hr_api.g_number)
       = p_communication_topic_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_cmt_bus.g_legislation_code;
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
    irc_cmt_bus.g_communication_topic_id      := p_communication_topic_id;
    irc_cmt_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in irc_cmt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_cmt_shd.api_updating
      (p_communication_topic_id            => p_rec.communication_topic_id
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
  if p_rec.subject <> irc_cmt_shd.g_old_rec.subject
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'SUBJECT'
     ,p_base_table => irc_cmt_shd.g_tab_nam
     );
  end if;
  if p_rec.communication_id <> irc_cmt_shd.g_old_rec.communication_id
  then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'COMMUNICATION_ID'
     ,p_base_table => irc_cmt_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_communication_id >--------------------------|
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
Procedure chk_communication_id
  (p_communication_id    in irc_comm_topics.communication_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_communication_id';
  l_status irc_comm_topics.status%type;
  cursor csr_comm(p_comm_id in number) is
  select status from irc_communications where
  communication_id = p_comm_id;
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'COMMUNICATION_ID'
  ,p_argument_value     => p_communication_id
  );
  --The status of the communication record referenced by COMMUNICATION_ID
  --should be in open status
  open csr_comm(p_communication_id);
  fetch csr_comm into l_status;
  if csr_comm%notfound or l_status <> 'OPEN' then
    fnd_message.set_name('PER','IRC_412405_WRNG_COMM_ID');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_TOPICS.COMMUNICATION_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,30);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,40);
    --
End chk_communication_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_subject >--------------------------|
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
Procedure chk_subject
  (p_subject    in irc_comm_topics.subject%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_subject';
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  if p_subject is null or length(p_subject) = 0 then
    fnd_message.set_name('PER','IRC_412246_NULL_TPC_SUB');
    fnd_message.raise_error;
  end if;

  if length(p_subject) > 150 then
    fnd_message.set_name('PER','IRC_412406_LONG_MSG_SUB');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,20);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_TOPICS.SUBJECT'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,30);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,40);
    --
End chk_subject;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_status >--------------------------|
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
Procedure chk_status
  (p_status         in irc_comm_topics.status%type
  ,p_effective_date in date
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_status';
  --
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'STATUS'
  ,p_argument_value     => p_status
  );
  --
  hr_utility.set_location(l_proc,20);
  if hr_api.not_exists_in_hr_lookups(p_lookup_type  => 'IRC_COMM_STATUS',
                                     p_lookup_code    => p_status,
                                     p_effective_date => p_effective_date)
  then
    --
    -- raise error as does not exist as lookup
    --
    hr_utility.set_location('Leaving: '|| l_proc, 30);
    hr_utility.set_message(800,'IRC_412407_NO_SUCH_TOPIC_STATUS');
    hr_utility.raise_error;
  end if;
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_COMM_TOPICS.STATUS'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,40);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,50);
    --
End chk_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmt_shd.g_rec_type
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
  chk_communication_id(p_rec.communication_id);
  --
  chk_subject(p_rec.subject);
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  chk_status(p_status         => p_rec.status
            ,p_effective_date => p_effective_date);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_cmt_shd.g_rec_type
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
  chk_subject(p_rec.subject);
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  chk_status(p_status         => p_rec.status
            ,p_effective_date => p_effective_date);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_cmt_shd.g_rec_type
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
end irc_cmt_bus;

/
