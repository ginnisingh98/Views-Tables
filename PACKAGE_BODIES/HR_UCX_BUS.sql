--------------------------------------------------------
--  DDL for Package Body HR_UCX_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UCX_BUS" as
/* $Header: hrucxrhi.pkb 120.0 2005/05/31 03:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ucx_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_ui_context_id               number         default null;
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
  (p_rec in hr_ucx_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_ucx_shd.api_updating
      (p_ui_context_id                     => p_rec.ui_context_id
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
End chk_non_updateable_args;


-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_UI_CONTEXT_KEY>------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid UI context key is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_lalel,p_user_interface_id
-- Post Success:
--   Processing continues if UI context key is not null and unique
--
-- Post Failure:
--   An application error is raised if UI context key is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_UI_CONTEXT_KEY
  (
     p_label           in varchar2
    ,p_user_interface_id  in number

  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_UI_CONTEXT_KEY';
  l_key      varchar2(1) ;
  l_gen_ui_context_key  varchar2(205);
  cursor csr_key(p_gen_ui_context_key varchar2) is
         select null
           from hr_ki_ui_contexts
          where  ui_context_key = p_gen_ui_context_key;


--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'UI_CONTEXT_KEY'
  ,p_argument_value     => p_label
  );

  hr_utility.set_location('Converting'||l_proc,20);


  hr_ucx_shd.construct_ui_context_key
    (
     p_user_interface_id
    ,p_label
    ,l_gen_ui_context_key
    );

  hr_utility.set_location('Opening cursor'||l_proc,30);

    open csr_key(l_gen_ui_context_key);
    fetch csr_key into l_key;
    if (csr_key%found)
    then
      close csr_key;
      fnd_message.set_name('PER','PER_449945_UCX_UI_KEY_DUP');
      fnd_message.raise_error;
    end if;
    close csr_key;

  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_UI_CONTEXTS.UI_CONTEXT_KEY'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,60);
End CHK_UI_CONTEXT_KEY;


-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_USER_INTERFACE_ID>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures user_interface_id is present in hr_ki_ui_contexts
--   and it is mandatory.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_user_interface_id
--
-- Post Success:
--   Processing continues if user_interface_id is valid
--
-- Post Failure:
--   An application error is raised if user_interface_id is invalid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure CHK_USER_INTERFACE_ID
  (p_user_interface_id     in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_user_interface_id';
  l_key     varchar2(30) ;
  cursor csr_int is
         select user_interface_id
           from hr_ki_user_interfaces
          where  user_interface_id = p_user_interface_id;


--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

--user_interface_id should not be null

    hr_api.mandatory_arg_error
        (p_api_name           => l_proc
        ,p_argument           => 'USER_INTERFACE_ID'
        ,p_argument_value     => p_user_interface_id
    );


  hr_utility.set_location('Validating:'||l_proc,20);


    open csr_int;
    fetch csr_int into l_key;
    hr_utility.set_location('After fetching :'||l_proc,30);
    if (csr_int%notfound) then
      close csr_int;
      fnd_message.set_name('PER','PER_449569_UCX_UI_ID_ABSENT');
      fnd_message.raise_error;
    end if;
    close csr_int;

  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_UI_CONTEXTS.USER_INTERFACE_ID'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,60);
End CHK_USER_INTERFACE_ID;



--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_ucx_shd.g_rec_type
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
  -- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  CHK_USER_INTERFACE_ID
    (
     p_user_interface_id  => p_rec.user_interface_id
    );
  CHK_UI_CONTEXT_KEY
    (
     p_label           => p_rec.label
    ,p_user_interface_id  => p_rec.user_interface_id
    );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_ucx_shd.g_rec_type
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
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
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
  (p_rec                          in hr_ucx_shd.g_rec_type
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
end hr_ucx_bus;

/
