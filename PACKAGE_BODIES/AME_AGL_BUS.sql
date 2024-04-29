--------------------------------------------------------
--  DDL for Package Body AME_AGL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_AGL_BUS" as
/* $Header: amaglrhi.pkb 120.0 2005/09/02 03:49 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_agl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_approval_group_id           number         default null;
g_language                    varchar2(4)    default null;

-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_APPROVAL_GROUP_ID >------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the approval_group_id.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_name
--
-- Post Success:
--   Processing continues if a valid approval_group_id is entered.
--
-- Post Failure:
--   An application error is raised approval_group_id is invalid.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_approval_group_id(p_approval_group_id in   number
                                      ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_approval_group_id';
  l_count    number;
  cursor CSel1 is
    select count(*)
      from ame_approval_groups
      where approval_group_id = p_approval_group_id
        and sysdate >= start_date and sysdate < end_date;
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name         => l_proc
                              ,p_argument         => 'APPROVAL_GROUP_ID'
                              ,p_argument_value   => p_approval_group_id
                              );
    open CSel1;
    fetch CSel1 into l_count;
    close CSel1;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400557_INVALID_APG_ID');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 =>
                        'AME_APPROVAL_GROUPS_TL.APPROVAL_GROUP_ID'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_approval_group_id;


-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_USER_APPROVAL_GROUP_NAME >------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure ensures user_approval_group_name is not null.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_user_approval_group_name
--
-- Post Success:
--   Processing continues if a non null value is entered.
--
-- Post Failure:
--   An application error is raised if the name is null.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_user_approval_group_name(p_user_approval_group_name in   varchar2
                                      ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_user_approval_group_name';
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name         => l_proc
                              ,p_argument         => 'USER_APPROVAL_GROUP_NAME'
                              ,p_argument_value   => p_user_approval_group_name
                              );
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 =>
                        'AME_APPROVAL_GROUPS_TL.USER_APPROVAL_GROUP_NAME'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_user_approval_group_name;


-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_DESCRIPTION >------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure ensures group's description is not null.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_description
--
-- Post Success:
--   Processing continues if a non null description is entered.
--
-- Post Failure:
--   An application error is raised if description is null.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_description(p_description in   varchar2
                                      ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_description';
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name         => l_proc
                              ,p_argument         => 'DESCRIPTION'
                              ,p_argument_value   => p_description
                              );
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 =>
                        'AME_APPROVAL_GROUPS_TL.DESCRIPTION'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_description;

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
  (p_rec in ame_agl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_agl_shd.api_updating
      (p_approval_group_id                 => p_rec.approval_group_id
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
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in ame_agl_shd.g_rec_type
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
  --
  chk_approval_group_id(
                        p_approval_group_id => p_rec.approval_group_id
                       );
  chk_user_approval_group_name
                  (p_user_approval_group_name => p_rec.user_approval_group_name
                  );
  chk_description (p_description => p_rec.description);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in ame_agl_shd.g_rec_type
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
  chk_user_approval_group_name
                  (p_user_approval_group_name => p_rec.user_approval_group_name
                  );
  chk_description (p_description => p_rec.description);
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
  (p_rec                          in ame_agl_shd.g_rec_type
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
end ame_agl_bus;

/
