--------------------------------------------------------
--  DDL for Package Body PAY_BTH_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BTH_BUS" as
/* $Header: pybthrhi.pkb 120.2 2005/06/12 16:19:52 susivasu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_bth_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_batch_id                    number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_batch_id                             in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_batch_headers bth
     where bth.batch_id = p_batch_id
       and pbg.business_group_id = bth.business_group_id;
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
    ,p_argument           => 'batch_id'
    ,p_argument_value     => p_batch_id
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
  (p_batch_id                             in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_batch_headers bth
     where bth.batch_id = p_batch_id
       and pbg.business_group_id = bth.business_group_id;
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
    ,p_argument           => 'batch_id'
    ,p_argument_value     => p_batch_id
    );
  --
  if ( nvl(pay_bth_bus.g_batch_id, hr_api.g_number)
       = p_batch_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_bth_bus.g_legislation_code;
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
    pay_bth_bus.g_batch_id          := p_batch_id;
    pay_bth_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_bth_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  hr_utility.set_location(l_proc, 5);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_bth_shd.api_updating
      (p_batch_id                             => p_rec.batch_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     pay_bth_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
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
-- |-----------------------< chk_transferred_status >-------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Check whether the existing batch header is transferred or not. If it
--    is transferred then raise error.
--    Also check if the batch is currently being processed too.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_transferred_status (p_batch_id number) Is
--
  cursor csr_status is
     select pbh.batch_status
       from pay_batch_headers pbh
      where pbh.batch_id = p_batch_id;
  --
  l_status pay_batch_headers.batch_status%TYPE;
  --
Begin
  --
  open csr_status;
  fetch csr_status into l_status;
  close csr_status;

  if l_status = 'T' then
     Fnd_Message.Set_Name('PER', 'HR_289754_BEE_REC_TRANSFERRED');
     fnd_message.raise_error;
  elsif l_status = 'P' then
     Fnd_Message.Set_Name('PER', 'HR_51321_BATCH_AFTER_SUBMITION');
     fnd_message.raise_error;
  end if;
  --
End chk_transferred_status;
--
-- ---------------------------------------------------------------------------
-- |----------------------------< chk_batch_name >--------------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update batch_name is not null.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_name
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_batch_name
  (p_batch_name          in    pay_batch_headers.batch_name%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_batch_name';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory batch_name exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'batch_name'
    ,p_argument_value               => p_batch_name
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_batch_name;
--
-- ---------------------------------------------------------------------------
-- |----------------------------< chk_batch_status >-------------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update batch_status is not null.
--    Also to validate against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'BATCH_STATUS'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_status
--    p_session_date
--    p_batch_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_batch_status
  (p_batch_status          in    pay_batch_headers.batch_status%TYPE,
   p_session_date          in    date,
   p_batch_id              in    pay_batch_headers.batch_id%TYPE,
   p_object_version_number in    pay_batch_headers.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_batch_status';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory batch_name exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'batch_status'
    ,p_argument_value               => p_batch_status
    );
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_bth_shd.api_updating
    (p_batch_id                => p_batch_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_bth_shd.g_old_rec.batch_status,hr_api.g_varchar2) <>
       nvl(p_batch_status,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     --    Validate against the hr_lookup.
     --
     if hr_api.not_exists_in_hr_lookups
        (p_effective_date => p_session_date,
         p_lookup_type    => 'BATCH_STATUS',
         p_lookup_code    => p_batch_status) then
         pay_bth_shd.constraint_error('PAY_BCH_BATCH_STATUS_CHK');
     end if;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_batch_status;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< chk_action_if_exists >-----------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update action_if_exists is not null.
--    Also to validate against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'ACTION_IF_EXISTS'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_action_if_exists
--    p_session_date
--    p_batch_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_action_if_exists
  (p_action_if_exists      in    pay_batch_headers.action_if_exists%TYPE,
   p_session_date          in    date,
   p_batch_id              in    pay_batch_headers.batch_id%TYPE,
   p_object_version_number in    pay_batch_headers.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_action_if_exists';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_bth_shd.api_updating
    (p_batch_id                => p_batch_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_bth_shd.g_old_rec.action_if_exists,hr_api.g_varchar2) <>
       nvl(p_action_if_exists,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     if (p_action_if_exists is not null) then
        --
        hr_utility.set_location(l_proc,35);
        --
        --    Validate against the hr_lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_session_date,
            p_lookup_type    => 'ACTION_IF_EXISTS',
            p_lookup_code    => p_action_if_exists) then
            pay_bth_shd.constraint_error('PAY_BCH_ACTION_IF_EXISTS_CHK');
        end if;
        --
     end if;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_action_if_exists;
--
-- ---------------------------------------------------------------------------
-- |------------------------< chk_purge_after_transfer >---------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update purge_after_transfer is not null.
--    Also to validate against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'YES_NO'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_purge_after_transfer
--    p_session_date
--    p_batch_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_purge_after_transfer
  (p_purge_after_transfer  in    pay_batch_headers.purge_after_transfer%TYPE,
   p_session_date          in    date,
   p_batch_id              in    pay_batch_headers.batch_id%TYPE,
   p_object_version_number in    pay_batch_headers.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_purge_after_transfer';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_bth_shd.api_updating
    (p_batch_id                => p_batch_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_bth_shd.g_old_rec.purge_after_transfer,hr_api.g_varchar2) <>
       nvl(p_purge_after_transfer,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     if (p_purge_after_transfer is not null) then
        --
        hr_utility.set_location(l_proc,35);
        --
        --    Validate against the hr_lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_session_date,
            p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_purge_after_transfer) then
            pay_bth_shd.constraint_error('PAY_BCH_PURGE_AFTER_TRANSF_CHK');
        end if;
        --
     end if;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_purge_after_transfer;
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_reject_if_future_changes >-------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update reject_if_future_changes is not null.
--    Also to validate against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'YES_NO'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_reject_if_future_changes
--    p_session_date
--    p_batch_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_reject_if_future_changes
  (p_reject_if_future_changes  in    pay_batch_headers.reject_if_future_changes%TYPE,
   p_session_date              in    date,
   p_batch_id                  in    pay_batch_headers.batch_id%TYPE,
   p_object_version_number in    pay_batch_headers.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_reject_if_future_changes';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_bth_shd.api_updating
    (p_batch_id                => p_batch_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_bth_shd.g_old_rec.reject_if_future_changes,hr_api.g_varchar2) <>
       nvl(p_reject_if_future_changes,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     if (p_reject_if_future_changes is not null) then
        --
        hr_utility.set_location(l_proc,35);
        --
        --    Validate against the hr_lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_session_date,
            p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_reject_if_future_changes) then
            pay_bth_shd.constraint_error('PAY_BCH_REJECT_IF_FUTURE_C_CHK');
        end if;
        --
     end if;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_reject_if_future_changes;
--
-- ---------------------------------------------------------------------------
-- |----------------------< chk_reject_if_results_exists >-------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update reject_if_results_exists is not null.
--    Also to validate against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'YES_NO'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_reject_if_results_exists
--    p_session_date
--    p_batch_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_reject_if_results_exists
  (p_reject_if_results_exists  in    pay_batch_headers.reject_if_results_exists%TYPE,
   p_session_date              in    date,
   p_batch_id                  in    pay_batch_headers.batch_id%TYPE,
   p_object_version_number in    pay_batch_headers.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_reject_if_results_exists';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_bth_shd.api_updating
    (p_batch_id                => p_batch_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_bth_shd.g_old_rec.reject_if_results_exists,hr_api.g_varchar2) <>
       nvl(p_reject_if_results_exists,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     if (p_reject_if_results_exists is not null) then
        --
        hr_utility.set_location(l_proc,35);
        --
        --    Validate against the hr_lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_session_date,
            p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_reject_if_results_exists) then
            pay_bth_shd.constraint_error('PAY_BCH_REJECT_IF_RESULTS_E_CHK');
        end if;
        --
     end if;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_reject_if_results_exists;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< chk_purge_after_rollback >--------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update purge_after_rollback is not null.
--    Also to validate against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'YES_NO'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_purge_after_rollback
--    p_session_date
--    p_batch_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_purge_after_rollback
  (p_purge_after_rollback  in    pay_batch_headers.purge_after_rollback%TYPE,
   p_session_date              in    date,
   p_batch_id                  in    pay_batch_headers.batch_id%TYPE,
   p_object_version_number in    pay_batch_headers.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_purge_after_rollback';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_bth_shd.api_updating
    (p_batch_id                => p_batch_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_bth_shd.g_old_rec.purge_after_rollback,hr_api.g_varchar2) <>
       nvl(p_purge_after_rollback,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     if (p_purge_after_rollback is not null) then
        --
        hr_utility.set_location(l_proc,35);
        --
        --    Validate against the hr_lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_session_date,
            p_lookup_type    => 'YES_NO',
            p_lookup_code    => p_purge_after_rollback) then
            pay_bth_shd.constraint_error('PAY_BCH_PURGE_AFTER_R_CHK');
        end if;
        --
     end if;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_purge_after_rollback;
--
-- ---------------------------------------------------------------------------
-- |-----------------------< chk_date_effective_changes >--------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update date_effective_changes is not null.
--    Also to validate against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_date_effective_changes
--    p_session_date
--    p_batch_id
--    P_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_date_effective_changes
  (p_date_effective_changes      in    pay_batch_headers.date_effective_changes%TYPE,
   p_session_date                in    date,
   p_batch_id                    in    pay_batch_headers.batch_id%TYPE,
   p_object_version_number       in    pay_batch_headers.object_version_number%TYPE,
   p_reject_if_future_changes    in    pay_batch_headers.reject_if_future_changes%TYPE,
   p_action_if_exists            in    pay_batch_headers.action_if_exists%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_date_effective_changes';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_bth_shd.api_updating
    (p_batch_id                => p_batch_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_bth_shd.g_old_rec.date_effective_changes,hr_api.g_varchar2) <>
       nvl(p_date_effective_changes,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     if (p_date_effective_changes is not null) then
        --
        hr_utility.set_location(l_proc,35);
        --
        --    Validate against the hr_lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_session_date,
            p_lookup_type    => 'DATE_EFFECTIVE_CHANGES',
            p_lookup_code    => p_date_effective_changes) then
            pay_bth_shd.constraint_error('PAY_BCH_DATE_EFFECTIVE_CHA_CHK');
        end if;
        --
     end if;
     --
  end if;
  --
  if (((p_reject_if_future_changes <> 'N' or p_action_if_exists <> 'U') and p_date_effective_changes = 'O')
       or (p_action_if_exists = 'U' and p_date_effective_changes not in ('O','C','U'))
       or (p_action_if_exists <> 'U' and p_date_effective_changes in ('O','C','U'))) then
          --
          pay_bth_shd.constraint_error('PAY_BCH_DATE_EFFECTIVE_CHA_CHK');
          --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_date_effective_changes;
--
-- ---------------------------------------------------------------------------
-- |-------------------------------< chk_delete >----------------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Check if there is no child row exists in
--    PAY_BATCH_LINES,
--    PAY_BATCH_CONTROL_TOTALS
--    and
--    PAY_MESSAGE_LINES.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_delete
  (p_batch_id                    in    pay_batch_headers.batch_id%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_exists   varchar2(1);
--
  cursor csr_batch_lines_exists is
    select null
    from   pay_batch_lines btl
    where  btl.batch_id = p_batch_id;
--
  cursor csr_batch_ctl_totals_exists is
    select null
    from   pay_batch_control_totals bct
    where  bct.batch_id = p_batch_id;
--
  cursor csr_message_lines is
    select null
    from   pay_message_lines pml
    where  pml.source_id = p_batch_id
    and    pml.source_type = 'H';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory batch_id exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'batch_id'
    ,p_argument_value               => p_batch_id
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open csr_batch_lines_exists;
  --
  fetch csr_batch_lines_exists into l_exists;
  --
  If csr_batch_lines_exists%found Then
    --
    close csr_batch_lines_exists;
    --
    fnd_message.set_name('PAY','PAY_52681_BHT_CHILD_EXISTS');
    fnd_message.raise_error;
    --
  End If;
  --
  close csr_batch_lines_exists;
  --
  hr_utility.set_location(l_proc, 20);
  --
  open csr_batch_ctl_totals_exists;
  --
  fetch csr_batch_ctl_totals_exists into l_exists;
  --
  If csr_batch_ctl_totals_exists%found Then
    --
    close csr_batch_ctl_totals_exists;
    --
    fnd_message.set_name('PAY','PAY_52681_BHT_CHILD_EXISTS');
    fnd_message.raise_error;
    --
  End If;
  --
  close csr_batch_ctl_totals_exists;
  --
  hr_utility.set_location(l_proc, 30);
  --
  open csr_message_lines;
  --
  fetch csr_message_lines into l_exists;
  --
  If csr_message_lines%found Then
    --
    close csr_message_lines;
    --
    fnd_message.set_name('PAY','PAY_52681_BHT_CHILD_EXISTS');
    fnd_message.raise_error;
    --
  End If;
  --
  close csr_message_lines;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_session_date                 in date,
   p_rec                          in pay_bth_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_batch_name(p_batch_name => p_rec.batch_name);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_batch_status(p_batch_status => p_rec.batch_status
                  ,p_session_date => p_session_date
                  ,p_batch_id => p_rec.batch_id
                  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_action_if_exists(p_action_if_exists => p_rec.action_if_exists
                      ,p_session_date => p_session_date
                      ,p_batch_id => p_rec.batch_id
                      ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 50);
  --
  chk_purge_after_transfer(p_purge_after_transfer => p_rec.purge_after_transfer
                          ,p_session_date => p_session_date
                          ,p_batch_id => p_rec.batch_id
                          ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 60);
  --
  chk_reject_if_future_changes(p_reject_if_future_changes => p_rec.reject_if_future_changes
                              ,p_session_date => p_session_date
                              ,p_batch_id => p_rec.batch_id
                              ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 70);
  --
  chk_date_effective_changes(p_date_effective_changes => p_rec.date_effective_changes
                            ,p_session_date => p_session_date
                            ,p_batch_id => p_rec.batch_id
                            ,p_object_version_number => p_rec.object_version_number
                            ,p_reject_if_future_changes => p_rec.reject_if_future_changes
                            ,p_action_if_exists => p_rec.action_if_exists);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_session_date                 in date,
   p_rec                          in pay_bth_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  chk_transferred_status(p_batch_id => p_rec.batch_id);
  --
  hr_utility.set_location(l_proc, 25);
  --
  chk_batch_name(p_batch_name => p_rec.batch_name);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_batch_status(p_batch_status => p_rec.batch_status
                  ,p_session_date => p_session_date
                  ,p_batch_id => p_rec.batch_id
                  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_action_if_exists(p_action_if_exists => p_rec.action_if_exists
                      ,p_session_date => p_session_date
                      ,p_batch_id => p_rec.batch_id
                      ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 50);
  --
  chk_purge_after_transfer(p_purge_after_transfer => p_rec.purge_after_transfer
                          ,p_session_date => p_session_date
                          ,p_batch_id => p_rec.batch_id
                          ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 60);
  --
  chk_reject_if_future_changes(p_reject_if_future_changes => p_rec.reject_if_future_changes
                              ,p_session_date => p_session_date
                              ,p_batch_id => p_rec.batch_id
                              ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 70);
  --
  chk_date_effective_changes(p_date_effective_changes => p_rec.date_effective_changes
                            ,p_session_date => p_session_date
                            ,p_batch_id => p_rec.batch_id
                            ,p_object_version_number => p_rec.object_version_number
                            ,p_reject_if_future_changes => p_rec.reject_if_future_changes
                            ,p_action_if_exists => p_rec.action_if_exists);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_bth_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  if payplnk.g_payplnk_call <> true then
     chk_transferred_status(p_batch_id => p_rec.batch_id);
  end if;
  --
  hr_utility.set_location(l_proc, 8);
  --
  chk_delete(p_batch_id => p_rec.batch_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_bth_bus;

/
