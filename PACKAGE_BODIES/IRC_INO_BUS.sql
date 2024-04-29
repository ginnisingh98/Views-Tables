--------------------------------------------------------
--  DDL for Package Body IRC_INO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_INO_BUS" as
/* $Header: irinorhi.pkb 120.1 2005/10/04 06:25:18 kthavran noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ino_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_note_id                     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_note_id                              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
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
    ,p_argument           => 'note_id'
    ,p_argument_value     => p_note_id
    );
  --
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
  (p_note_id                              in     number
  )
  Return Varchar2 Is
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
    ,p_argument           => 'note_id'
    ,p_argument_value     => p_note_id
    );
  --
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
  (p_rec in irc_ino_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ino_shd.api_updating
      (p_note_id                           => p_rec.note_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Add checks to ensure non-updateable args have
  -- not been updated.
  --
  if p_rec.note_id <> irc_ino_shd.g_old_rec.note_id
    then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'NOTE_ID'
      ,p_base_table => irc_ino_shd.g_tab_nam
      );
  end if;
  --
  if p_rec.offer_status_history_id <> irc_ino_shd.g_old_rec.offer_status_history_id
    then
    hr_api.argument_changed_error
      (p_api_name   => l_proc
      ,p_argument   => 'OFFER_STATUS_HISTORY_ID'
      ,p_base_table => irc_ino_shd.g_tab_nam
      );
  end if;
  --
End chk_non_updateable_args;
--
-- ---------------------------------------------------------------------------------------
-- |---------------------------< chk_offer_status_history_id >----------------------------|
-- ----------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that offer_status_history_id exists in
--   irc_offer_status_history.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_offer_status_history_id
--
-- Post Success:
--   Processing continues if the offer status history id exists.
--
-- Post Failure:
--   An application error is raised if the offer status history id does not exist
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_offer_status_history_id
  (p_offer_status_history_id in irc_notes.offer_status_history_id%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_offer_status_history_id';
  l_num number;
  --
  cursor csr_offer_status_history_id is
    select 1
    from irc_offer_status_history
    where offer_status_history_id = p_offer_status_history_id;
  --
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  -- Check if the offer status history id is valid.
  --
  open csr_offer_status_history_id;
  fetch csr_offer_status_history_id into l_num;
  hr_utility.set_location(l_proc,20);
  if csr_offer_status_history_id%notfound then
    close csr_offer_status_history_id;
    hr_utility.set_message(800,'IRC_412325_INV_OFFER_HISTORYID');
    hr_utility.raise_error;
  end if;
  close csr_offer_status_history_id;
  hr_utility.set_location(l_proc,30);
--
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 =>
      'irc_notes.offer_status_history_id'
      ) then
      hr_utility.set_location(' Leaving:'||l_proc,50);
      raise;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,60);
End chk_offer_status_history_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in irc_ino_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- Validate Dependent Attributes
  --
   hr_api.mandatory_arg_error
   (p_api_name           => l_proc
   ,p_argument           => 'NOTE_TEXT'
   ,p_argument_value     => p_rec.note_text
   );
  --
   chk_offer_status_history_id
   (p_offer_status_history_id => p_rec.offer_status_history_id
   );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in irc_ino_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ino_shd.g_rec_type
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
end irc_ino_bus;

/
