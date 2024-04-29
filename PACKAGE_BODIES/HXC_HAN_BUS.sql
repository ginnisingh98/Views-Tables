--------------------------------------------------------
--  DDL for Package Body HXC_HAN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAN_BUS" as
/* $Header: hxchanrhi.pkb 120.2 2006/07/10 10:09:56 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hxc_han_bus.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_comp_notification_id         number         default null;
g_object_version_number       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_comp_notification_id                  in number
  ,p_object_version_number                in number
  ,p_associated_column1                   in varchar2 default null
  ,p_associated_column2                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_app_comp_notifications and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , hxc_app_comp_notifications han
      --   , EDIT_HERE table_name(s) 333
     where han.comp_notification_id = p_comp_notification_id
       and han.object_version_number = p_object_version_number;
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
  if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'comp_notification_id'
    ,p_argument_value     => p_comp_notification_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'object_version_number'
    ,p_argument_value     => p_object_version_number
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
        => nvl(p_associated_column1,'COMP_notification_ID')
      ,p_associated_column2
        => nvl(p_associated_column2,'OBJECT_VERSION_NUMBER')
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
  if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  end if;
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_comp_notification_id                  in     number
  ,p_object_version_number                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- hxc_app_comp_notifications and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , hxc_app_comp_notifications han
      --   , EDIT_HERE table_name(s) 333
     where han.comp_notification_id = p_comp_notification_id
       and han.object_version_number = p_object_version_number;
      -- and pbg.business_group_id = EDIT_HERE 333.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'comp_notification_id'
    ,p_argument_value     => p_comp_notification_id
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'object_version_number'
    ,p_argument_value     => p_object_version_number
    );
  --
  if (( nvl(hxc_han_bus.g_comp_notification_id, hr_api.g_number)
       = p_comp_notification_id)
  and ( nvl(hxc_han_bus.g_object_version_number, hr_api.g_number)
       = p_object_version_number)) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hxc_han_bus.g_legislation_code;
    if g_debug then
    hr_utility.set_location(l_proc, 20);
    end if;
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
    if g_debug then
    hr_utility.set_location(l_proc,30);
    end if;
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    hxc_han_bus.g_comp_notification_id         := p_comp_notification_id;
    hxc_han_bus.g_object_version_number       := p_object_version_number;
    hxc_han_bus.g_legislation_code  := l_legislation_code;
  end if;
  if g_debug then
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  end if;
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
  (p_rec in hxc_han_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hxc_han_shd.api_updating
      (p_comp_notification_id               => p_rec.comp_notification_id
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
  --Check to see that notification_action_code is not updated
  --
  If (p_rec.notification_action_code <> hxc_han_shd.g_old_rec.notification_action_code) then
    fnd_message.set_name('PER', 'NOTIOFICATION_ACTION_CODE cannot be changed');
    fnd_message.raise_error;
  End If;
  --
  --Check to see that notification_recipient_code is not updated
  --
  If (p_rec.notification_recipient_code<>hxc_han_shd.g_old_rec.notification_recipient_code) then
    fnd_message.set_name('PER', 'RECIPIENT_ACTION_CODE cannot be changed');
    fnd_message.raise_error;
  End If;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_notification_num_retries >------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_notification_num_retries (
   p_notification_number_retries   IN   NUMBER,
   p_notification_action_code      IN   VARCHAR2
 )
IS
BEGIN

      IF (p_notification_action_code <>
                  hxc_app_comp_notifications_api.c_action_request_appr_resend
         )
      THEN
         IF (p_notification_number_retries <> 0)
         THEN
            hr_utility.set_message (809, 'HXC_RETRIES_NOT_ZERO');
            hr_utility.raise_error;
         END IF;
      ELSE
         IF (   p_notification_number_retries < 0
             OR p_notification_number_retries > 999
            )
         THEN
            hr_utility.set_message (809, 'HXC_INAVALID_NUM_RETRIES');
            hr_utility.raise_error;
         END IF;
      END IF;

END chk_notification_num_retries;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_notification_timeout_value >------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_notification_timeout_value (p_notification_timeout_value IN NUMBER)
IS
BEGIN
   IF (   p_notification_timeout_value < 0
       OR p_notification_timeout_value > 999999
      )
   THEN
      hr_utility.set_message (809, 'HXC_TIMEOUT_VALUE');
      hr_utility.raise_error;
   END IF;
END chk_notification_timeout_value;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_notification_action_code >---------------|
-- ----------------------------------------------------------------------------
--
Procedure
chk_notification_action_code
( p_notification_action_code in varchar2
) is
begin
  if p_notification_action_code not in
  (
    hxc_app_comp_notifications_api.C_ACTION_APPROVED
   ,hxc_app_comp_notifications_api.C_ACTION_AUTO_APPROVE
   ,hxc_app_comp_notifications_api.C_ACTION_ERROR
   ,hxc_app_comp_notifications_api.C_ACTION_REJECTED
   ,hxc_app_comp_notifications_api.C_ACTION_REQUEST_APPROVAL
   ,hxc_app_comp_notifications_api.C_ACTION_REQUEST_APPR_RESEND
   ,hxc_app_comp_notifications_api.C_ACTION_SUBMISSION
   ,hxc_app_comp_notifications_api.C_ACTION_TRANSFER
  )
  then
    hr_utility.set_message(809,'HXC_ACTION_CODE');
    hr_utility.raise_error;
  end if;
end chk_notification_action_code;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_notification_recip_code >----------------|
-- ----------------------------------------------------------------------------
--
Procedure
chk_notification_recip_code
( p_notification_recipient_code in varchar2
) is
begin
  if p_notification_recipient_code not in
  (
    hxc_app_comp_notifications_api.C_RECIPIENT_ADMIN
   ,hxc_app_comp_notifications_api.C_RECIPIENT_APPROVER
   ,hxc_app_comp_notifications_api.C_RECIPIENT_ERROR_ADMIN
   ,hxc_app_comp_notifications_api.C_RECIPIENT_PREPARER
   ,hxc_app_comp_notifications_api.C_RECIPIENT_SUPERVISOR
   ,hxc_app_comp_notifications_api.C_RECIPIENT_WORKER
  )
  then
    hr_utility.set_message(809,'HXC_RECIPIENT_CODE');
    hr_utility.raise_error;
  end if;
end chk_notification_recip_code;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hxc_han_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  g_debug:=hr_utility.debug_enabled;
  if g_debug then
  	l_proc := g_package||'insert_validate';
  	hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  --
  --Check for notification_number_retries
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

  chk_notification_num_retries
    ( p_notification_number_retries =>p_rec.notification_number_retries
     ,p_notification_action_code    =>p_rec.notification_action_code
    );

  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
  --
  --Check for notification_timeout_value
  --
  if g_debug then
    	hr_utility.set_location('Processing:'||l_proc, 15);
  end if;
  --


  chk_notification_timeout_value
    (
     p_notification_timeout_value  => p_rec.notification_timeout_value
    );

  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 15);
  end if;
  --
  --Check for notification_action_code
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 20);
  end if;
  chk_notification_action_code
    (p_notification_action_code =>p_rec.notification_action_code);
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;
  --
  --Check for notification_recipient_code
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 25);
  end if;
  chk_notification_recip_code
    (p_notification_recipient_code =>p_rec.notification_recipient_code);
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 25);
  end if;


  -- Validate Dependent Attributes
  --
  --
  if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hxc_han_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  --
  --Check for notification_number_retries
  --
  if g_debug then
  	hr_utility.set_location('Processing:'||l_proc, 10);
  end if;

  chk_notification_num_retries
    ( p_notification_number_retries =>p_rec.notification_number_retries
     ,p_notification_action_code    =>p_rec.notification_action_code
    );
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
  --
  --Check for notification_timeout_value
  --
  if g_debug then
    	hr_utility.set_location('Processing:'||l_proc, 15);
  end if;
  --
  chk_notification_timeout_value
    (
     p_notification_timeout_value  => p_rec.notification_timeout_value
    );
  --
  if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 15);
  end if;
  if g_debug then
    	hr_utility.set_location('Processing:'||l_proc, 20);
  end if;
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  if g_debug then
     	hr_utility.set_location(' Leaving:'||l_proc, 20);
  end if;

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hxc_han_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  if g_debug then
  hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Call all supporting business operations
  --
  if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End delete_validate;
--
end hxc_han_bus;

/
