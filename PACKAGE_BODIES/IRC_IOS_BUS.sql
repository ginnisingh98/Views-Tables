--------------------------------------------------------
--  DDL for Package Body IRC_IOS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IOS_BUS" as
/* $Header: iriosrhi.pkb 120.3.12010000.2 2008/11/09 06:41:05 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_ios_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_offer_status_history_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_offer_status_history_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , irc_offer_status_history ios
         , per_all_vacancies vac
     where ios.offer_status_history_id = p_offer_status_history_id
       and pbg.business_group_id = vac.business_group_id;
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
    ,p_argument           => 'offer_status_history_id'
    ,p_argument_value     => p_offer_status_history_id
    );
  --
  if ( nvl(irc_ios_bus.g_offer_status_history_id, hr_api.g_number)
       = p_offer_status_history_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_ios_bus.g_legislation_code;
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
    irc_ios_bus.g_offer_status_history_id     := p_offer_status_history_id;
    irc_ios_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec in irc_ios_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_ios_shd.api_updating
      (p_offer_status_history_id           => p_rec.offer_status_history_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if irc_ios_shd.g_old_rec.offer_status_history_id <>
                                   p_rec.offer_status_history_id
  then
          hr_api.argument_changed_error
            (p_api_name   => l_proc,
             p_argument   => 'offer_status_history_id',
             p_base_table => irc_ios_shd.g_tab_name
            );
  end if;
  --
  if irc_ios_shd.g_old_rec.offer_id <> p_rec.offer_id
  then
          hr_api.argument_changed_error
            (p_api_name   => l_proc,
             p_argument   => 'offer_id',
             p_base_table => irc_ios_shd.g_tab_name
            );
  end if;
  --
  if irc_ios_shd.g_old_rec.offer_status <> p_rec.offer_status
  then
          hr_api.argument_changed_error
            (p_api_name   => l_proc,
             p_argument   => 'offer_status',
             p_base_table => irc_ios_shd.g_tab_name
            );
  end if;
  --
  if irc_ios_shd.g_old_rec.change_reason <> p_rec.change_reason
  then
          hr_api.argument_changed_error
            (p_api_name   => l_proc,
             p_argument   => 'change_reason',
             p_base_table => irc_ios_shd.g_tab_name
            );
  end if;
  --
  if irc_ios_shd.g_old_rec.decline_reason <> p_rec.decline_reason
  then
          hr_api.argument_changed_error
            (p_api_name   => l_proc,
             p_argument   => 'decline_reason',
             p_base_table => irc_ios_shd.g_tab_name
            );
  end if;
--
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_offer_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that offer Id exists
--   in table irc_offers.
--
-- Pre Conditions:
--   offer Id should exist in the table.
--
-- In Arguments:
--   offer_id is passed by the user.
--
-- Post Success:
--   Processing continues if Offer Id exists.
--
-- Post Failure:
--   An error is raised if Offer Id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_offer_id
  (p_offer_id      in irc_offer_status_history.offer_id%TYPE
  ) is
--
  l_proc     varchar2(72) := g_package || 'chk_offer_id';
  --
  l_offer_id irc_offer_status_history.offer_id%TYPE;
  --
  cursor csr_offer is
  select  1
    from  IRC_OFFERS
   where  offer_id = p_offer_id;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OFFER_ID'
    ,p_argument_value     => p_offer_id
    );
  --
  open csr_offer;
  fetch csr_offer into l_offer_id;
  hr_utility.set_location(l_proc,20);
  if csr_offer%NOTFOUND then
    close csr_offer;
    fnd_message.set_name ('PER','IRC_412322_INVALID_OFFER_ID');
    fnd_message.raise_error;
  end if;
  close csr_offer;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1=>
        'IRC_OFFER_STATUS_HISTORY.OFFER_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_offer_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_offer_status >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that
--   a)  Offer Status is not null in the table irc_offer_status_history
--   b)  Offer Status is a valid value from IRC_OFFER_STATUSES lookup
--
-- Pre Conditions:
--   offer status should exist in the table.
--   offer status is a valid value from the lookup
--
-- In Arguments:
--   offer_status is passed by the user.
--
-- Post Success:
--   Processing continues if Offer status exists.
--
-- Post Failure:
--   An error is raised if Offer status does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_offer_status
  (p_offer_status           in irc_offer_status_history.offer_status%TYPE,
   p_effective_date         in date
  ) is
--
  l_proc     varchar2(72) := g_package || 'chk_offer_status';
--
  l_offer_status irc_offer_status_history.offer_status%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EFFECTIVE_DATE'
    ,p_argument_value     => p_effective_date
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OFFER_STATUS'
    ,p_argument_value     => p_offer_status
    );
--

--
       hr_utility.set_location(l_proc,20);
       if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date,
          p_lookup_type    => 'IRC_OFFER_STATUSES',
          p_lookup_code    => p_offer_status
         ) then

         hr_utility.set_message(800, 'IRC_412323_INV_OFFER_STATUS');
         hr_utility.raise_error;
       end if;
--
hr_utility.set_location(' Leaving:' || l_proc, 30);

  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1=>
        'IRC_OFFER_STATUS_HISTORY.OFFER_STATUS'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_offer_status;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_change_reason >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that
--   a)  Change Reason must be a valid value from
--       IRC_OFFER_STATUS_CHANGE_REASON lookup
--   b)  Should not get updated in irc_offer_status_history
--
-- Pre Conditions:
--   Change Reason should exist in the lookup.
--
-- In Arguments:
--   change_reason is passed by the user.
--   effective_date is passed by the user.
--
-- Post Success:
--   Processing continues if change reason exists in the lookup.
--
-- Post Failure:
--   An error is raised if change reason does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_change_reason
  (p_change_reason           in irc_offer_status_history.change_reason%TYPE,
   p_effective_date         in date
  ) is
--
  l_proc     varchar2(72) := g_package || 'chk_change_reason';
--
  l_change_reason irc_offer_status_history.change_reason%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
if (p_change_reason is not null)
then
       hr_utility.set_location(l_proc,20);
       if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date,
          p_lookup_type    => 'IRC_OFFER_STATUS_CHANGE_REASON',
          p_lookup_code    => p_change_reason
         ) then

         hr_utility.set_message(800, 'IRC_412347_INV_CHANGE_REASON');
         hr_utility.raise_error;
       end if;
end if;
--
hr_utility.set_location(' Leaving:' || l_proc, 30);

  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1=>
        'IRC_OFFER_STATUS_HISTORY.CHANGE_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_change_reason;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_decline_reason >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that
--   a)  decline Reason must be a valid value from
--       IRC_OFFER_STATUS_DECLINE_REASON lookup
--   b)  Should not get updated in irc_offer_status_history
--
-- Pre Conditions:
--   decline Reason should exist in the lookup.
--
-- In Arguments:
--   decline_reason is passed by the user.
--   effective_date is passed by the user.
--
-- Post Success:
--   Processing continues if decline reason exists in the lookup.
--
-- Post Failure:
--   An error is raised if decline reason does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_decline_reason
  (p_decline_reason           in irc_offer_status_history.decline_reason%TYPE,
   p_effective_date         in date
  ) is
--
  l_proc     varchar2(72) := g_package || 'chk_decline_reason';
--
  l_decline_reason irc_offer_status_history.decline_reason%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EFFECTIVE_DATE'
    ,p_argument_value     => p_effective_date
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'DECLINE_REASON'
    ,p_argument_value     => p_decline_reason
    );
--

--
if (p_decline_reason is not null)
then
       hr_utility.set_location(l_proc,20);
       if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date,
          p_lookup_type    => 'IRC_OFFER_DECLINE_REASON',
          p_lookup_code    => p_decline_reason
         ) then

         hr_utility.set_message(800, 'IRC_412324_INV_DECLINE_REASON');
         hr_utility.raise_error;
       end if;
end if;
--
hr_utility.set_location(' Leaving:' || l_proc, 30);

  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1=>
        'IRC_OFFER_STATUS_HISTORY.DECLINE_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_decline_reason;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_withdraw_reason >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that
--   a)  decline Reason must be a valid value from
--       IRC_OFFER_WITHDRAW_REASON lookup
--   b)  Should not get updated in irc_offer_status_history
--
-- Pre Conditions:
--   decline Reason should exist in the lookup.
--
-- In Arguments:
--   decline_reason is passed by the user.
--   effective_date is passed by the user.
--
-- Post Success:
--   Processing continues if decline reason exists in the lookup.
--
-- Post Failure:
--   An error is raised if decline reason does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_withdraw_reason
  (p_withdraw_reason           in irc_offer_status_history.decline_reason%TYPE,
   p_effective_date         in date
  ) is
--
  l_proc     varchar2(72) := g_package || 'chk_withdraw_reason';
--
  l_decline_reason irc_offer_status_history.decline_reason%TYPE;

--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Check mandatory parameters have been set
--
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'EFFECTIVE_DATE'
    ,p_argument_value     => p_effective_date
    );
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'DECLINE_REASON'
    ,p_argument_value     => p_withdraw_reason
    );
--

--
if (p_withdraw_reason is not null)
then
       hr_utility.set_location(l_proc,20);
       if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date,
          p_lookup_type    => 'IRC_OFFER_WITHDRAWAL_REASON',
          p_lookup_code    => p_withdraw_reason
         ) then

         hr_utility.set_message(800, 'IRC_412551_INV_WITHDRAW_REASON');
         hr_utility.raise_error;
       end if;
end if;
--
hr_utility.set_location(' Leaving:' || l_proc, 30);

  --
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1=>
        'IRC_OFFER_STATUS_HISTORY.DECLINE_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_withdraw_reason;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in irc_ios_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --

  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_offer_id
  (p_offer_id                => p_rec.offer_id
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_offer_status
  (p_offer_status    => p_rec.offer_status,
   p_effective_date => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 40);
  --
  if (p_rec.change_reason is not null) then
  chk_change_reason
  (p_change_reason  => p_rec.change_reason,
   p_effective_date => p_effective_date
  );
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  if (p_rec.decline_reason is not null) then
  if(p_rec.change_reason='MGR_WITHDRAW') then
      chk_withdraw_reason
     (p_withdraw_reason => p_rec.decline_reason,
      p_effective_date => p_effective_date
     );
  else
  chk_decline_reason
  (p_decline_reason => p_rec.decline_reason,
   p_effective_date => p_effective_date
  );
  end if;
  end if;
  --
  hr_utility.set_location(l_proc, 60);
  --
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in irc_ios_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  hr_utility.set_location(l_proc, 20);
  --
  if (p_rec.change_reason is not null) then
  chk_change_reason
  (p_change_reason  => p_rec.change_reason,
   p_effective_date => p_effective_date
  );
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if (p_rec.decline_reason is not null) then
  if(p_rec.change_reason='MGR_WITHDRAW') then
      chk_withdraw_reason
     (p_withdraw_reason => p_rec.decline_reason,
      p_effective_date => p_effective_date
     );
  else
  chk_decline_reason
  (p_decline_reason => p_rec.decline_reason,
   p_effective_date => p_effective_date
  );
  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_ios_shd.g_rec_type
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
end irc_ios_bus;

/
