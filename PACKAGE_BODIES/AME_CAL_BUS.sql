--------------------------------------------------------
--  DDL for Package Body AME_CAL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CAL_BUS" as
/* $Header: amcalrhi.pkb 120.2 2006/01/03 22:52 tkolla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_cal_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_application_id              number         default null;
g_language                    varchar2(4)    default null;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_FND_APPLICATION_ID >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether a valid Application ID has been
--   provided. The ID must be defined in the AME_CALLING_APPS table.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_id
--
-- Post Success:
--   Processing continues if a valid Application ID is found.
--
-- Post Failure:
--   An application error is raised either if the p_application_id is not
--   defined or if the value is not found in AME_CALLING_APPS table.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_application_id(p_application_id           in   number
                            ,p_effective_date           in   date
                            ) IS
--
  cursor csr_application_id is
    select null
      from ame_calling_apps
     where application_id = p_application_id
       and p_effective_date between start_date
             and nvl(end_date - ame_util.oneSecond, p_effective_date);
  --
  l_proc     varchar2(72) := g_package || 'CHK_APPLICATION_ID';
  l_key      varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'APPLICATION_ID'
                              ,p_argument_value     => p_application_id
                              );
    open csr_application_id;
    fetch csr_application_id into l_key;
    if(csr_application_id%notfound) then
      close csr_application_id;
      fnd_message.set_name('AME', 'INVALID_APPLICATION_ID');
      fnd_message.raise_error;
    else
      close csr_application_id;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
               (p_associated_column1 => 'AME_CALLING_APPS_TL.APPLICATION_ID'
               ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_application_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< CHK_APPLICATION_NAME >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether a value is defined for APPLICATION_NAME and
--   is unique.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_name
--
-- Post Success:
--   Processing continues if a valid unique Application Name is found.
--
-- Post Failure:
--   An application error is raised if the Application Name is not defined.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_application_name(p_application_name            in   varchar2
                               ,p_language                    in   varchar2) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_APPLICATION_NAME';
  l_key      varchar2(1);
  l_exists varchar2(1);
  cursor dup_app_name is
    select null
      from ame_calling_apps_tl cal
       where cal.application_name = p_application_name
       and cal.language = p_language;
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'APPLICATION_NAME'
                              ,p_argument_value     => p_application_name
                              );
    hr_utility.set_location(' Leaving:'||l_proc,30);
  open dup_app_name;
  fetch dup_app_name into l_exists;
   if dup_app_name%found then
     close dup_app_name;
       fnd_message.set_name('PER','AME_400748_TTY_NAME_IN_USE');
       fnd_message.raise_error;
   end if;
  close dup_app_name;
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
               (p_associated_column1 => 'AME_CALLING_APPS_TL.APPLICATION_NAME'
               ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_application_name;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_application_id                       in number
  ,p_associated_column1                   in varchar2 default null
  ) is
begin
  null;
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_application_id                       in     number
  ,p_language                             in     varchar2
  )
  Return Varchar2 Is
Begin
  return null;
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
  (p_rec in ame_cal_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_cal_shd.api_updating
      (p_application_id                    => p_rec.application_id
      ,p_language                          => p_rec.language
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
  -- Check to see whether the transaction type name modified already exist
  -- or not, if its already exist then throw an error

End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in ame_cal_shd.g_rec_type
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
  chk_application_id(p_application_id  => p_rec.application_id
                    ,p_effective_date  => sysdate
                    );
  chk_application_name(p_application_name  => p_rec.application_name
                       ,p_language         => p_rec.language);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in ame_cal_shd.g_rec_type
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
    (p_rec              => p_rec
    );
if (ame_cal_shd.g_old_rec.application_name <> p_rec.application_name) then
  chk_application_name(p_application_name  => p_rec.application_name
                       ,p_language         => p_rec.language);
end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ame_cal_shd.g_rec_type
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
end ame_cal_bus;

/
