--------------------------------------------------------
--  DDL for Package Body HR_EAP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EAP_BUS" as
/* $Header: hreaprhi.pkb 115.0 2004/01/09 00:17 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_eap_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_ext_application_id          number         default null;
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
  (p_rec in hr_eap_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_eap_shd.api_updating
      (p_ext_application_id                => p_rec.ext_application_id
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Add checks to ensure non-updateable args have
  --            not been updated.
  --
  if nvl(p_rec.external_application_id, hr_api.g_number) <>
       nvl(hr_eap_shd.g_old_rec.external_application_id
           ,hr_api.g_number
           ) then
      hr_api.argument_changed_error
        (p_api_name   => l_proc
        ,p_argument   => 'EXTERNAL_APPLICATION_ID'
        ,p_base_table => hr_eap_shd.g_tab_nam
        );
  end if;


End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |------------------< CHK_EXTERNAL_APPLICATION_NAME>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures EXTERNAL_APPLICATION_NAME is not null and unique.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   P_EXTERNAL_APPLICATION_NAME
-- Post Success:
--   Processing continues if P_EXTERNAL_APPLICATION_NAME is not null and unique
--
-- Post Failure:
--   An application error is raised if P_EXTERNAL_APPLICATION_NAME is null
--   or exists already in table.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_EXTERNAL_APPLICATION_NAME
  (p_external_application_name     in varchar2

  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_EXTERNAL_APPLICATION_NAME';
  l_key     varchar2(1) ;
  cursor csr_name is
         select null
           from hr_ki_ext_applications
          where  external_application_name = p_external_application_name;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'EXTERNAL_APPLICATION_NAME'
  ,p_argument_value     => p_external_application_name
  );

  hr_utility.set_location('Validating:'||l_proc,20);
    open csr_name;
    fetch csr_name into l_key;
    if (csr_name%found)
    then
      close csr_name;
      fnd_message.set_name('PER','PER_449985_EAP_EAPP_NAME_DUP');
      fnd_message.raise_error;
    end if;
    close csr_name;

  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'hr_ki_ext_applications.EXTERNAL_APPLICATION_NAME'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_EXTERNAL_APPLICATION_NAME;

-- ----------------------------------------------------------------------------
-- |---------------< CHK_EXTERNAL_APP_NAME_UPD>-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures EXTERNAL_APPLICATION_NAME is not null and unique.
--   If earlier procedure is used for update validation then error will be
--   thrown even if application name is unique and not null as earlier query
--   does not have addtional p_ext_application_id condition in the cursor.
--   We can not combine these 2 methods as p_ext_application_id is not
--   available at the time of insert_validation
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   P_EXTERNAL_APPLICATION_NAME
--   p_ext_application_id
-- Post Success:
--   Processing continues if P_EXTERNAL_APPLICATION_NAME is not null and unique
--
-- Post Failure:
--   An application error is raised if P_EXTERNAL_APPLICATION_NAME is null
--   or exists already in table.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_EXTERNAL_APP_NAME_UPD
  (p_external_application_name     in varchar2
   ,p_ext_application_id               in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_EXTERNAL_APP_NAME_UPD';
  l_key     varchar2(1) ;
  cursor csr_name is
         select null
           from hr_ki_ext_applications
          where  external_application_name = p_external_application_name
          and ext_application_id<>p_ext_application_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'EXTERNAL_APPLICATION_NAME'
  ,p_argument_value     => p_external_application_name
  );

  hr_utility.set_location('Validating:'||l_proc,20);
    open csr_name;
    fetch csr_name into l_key;
    if (csr_name%found)
    then
      close csr_name;
      fnd_message.set_name('PER','PER_449985_EAP_EAPP_NAME_DUP');
      fnd_message.raise_error;
    end if;
    close csr_name;

  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'hr_ki_ext_applications.EXTERNAL_APPLICATION_NAME'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_EXTERNAL_APP_NAME_UPD;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_eap_shd.g_rec_type
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
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_eap_shd.g_rec_type
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

  CHK_EXTERNAL_APP_NAME_UPD
  (
   p_external_application_name => p_rec.external_application_name
   ,p_ext_application_id        => p_rec.ext_application_id
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
  (p_rec                          in hr_eap_shd.g_rec_type
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
end hr_eap_bus;

/
