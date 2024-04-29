--------------------------------------------------------
--  DDL for Package Body HR_ITL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITL_BUS" as
/* $Header: hritlrhi.pkb 115.1 2004/04/05 07:21 menderby noship $ */
/* $Header: hritlrhi.pkb 115.1 2004/04/05 07:21 menderby noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_itl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_integration_id              number         default null;
g_language                    varchar2(4)    default null;
--
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
  (p_rec in hr_itl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_itl_shd.api_updating
      (p_integration_id                    => p_rec.integration_id
      ,p_language                     => p_rec.language

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
-- |-----------------------< chk_integration_id>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that parent integration_id exists in
--   hr_ki_integrations table.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_integration_id
--
-- Post Success:
--   Processing continues if integration_id exist in hr_ki_integrations table
--
-- Post Failure:
--   An application error is raised if id does not exist in hr_ki_integrations
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------


procedure chk_integration_id
(
  p_integration_id in number
)
is
  -- Declare cursors and local variables
  --
  -- Cursor to check if there is an entry in hr_ki_integrations
  l_proc     varchar2(72) := g_package || 'chk_integration_id';
  l_name     varchar2(1);


CURSOR csr_id is
  select
   null
  From
    hr_ki_integrations
  where
    integration_id = p_integration_id;

  Begin


   hr_utility.set_location(' Entering:' || l_proc,10);

   open csr_id;
   fetch csr_id into l_name;

   if csr_id%NOTFOUND then
    fnd_message.set_name('PER', 'PER_449983_ITL_INT_ID_ABSENT');
    fnd_message.raise_error;
   end if;

   close csr_id;

   hr_utility.set_location(' Leaving:' || l_proc,20);

Exception
 when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'HR_KI_INTEGRATIONS_TL.INTEGRATION_ID'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);
  --
  End chk_integration_id;


-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_SERVICE_NAME>--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures entered partner name is not null and unique.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_name
--   p_language
-- Post Success:
--   Processing continues if service name is not null and unique
--
-- Post Failure:
--   An application error is raised if service name is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_SERVICE_NAME
  (
   p_integration_id in number
  ,p_partner_name in varchar
  ,p_service_name     in varchar2
  ,p_language              in varchar2
  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_SERVICE_NAME';
  l_name     varchar2(1);
  cursor csr_name is
         select null
           from hr_ki_integrations_tl
          where
           integration_id <> p_integration_id
          and service_name = p_service_name
          and partner_name=p_partner_name
          and language = p_language;

  l_check varchar2(1);

--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check value has been passed
  --

  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'PARTNER_NAME'
  ,p_argument_value     => p_partner_name
  );

  hr_utility.set_location('Checking:'||l_proc,20);

  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'SERVICE_NAME'
  ,p_argument_value     => p_service_name
  );
  hr_utility.set_location('Checking:'||l_proc,30);

---First check if record already present in the table
---  for same id ,partner name and service name and language
---If record exist then user is not updating the record
---so NO validation is required

   open csr_name;
   fetch csr_name into l_name;
   hr_utility.set_location('After fetching:'||l_proc,40);
   if (csr_name%found)
   then
     close csr_name;
     fnd_message.set_name('PER','PER_449984_ITL_SNAME_DUPLICATE');
     fnd_message.raise_error;
   end if;
   close csr_name;

  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_INTEGRATIONS_TL.SERVICE_NAME'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,70);
End CHK_SERVICE_NAME;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_itl_shd.g_rec_type
  ,p_integration_id               in number
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
  CHK_INTEGRATION_ID
  (
  p_integration_id  => p_integration_id
  );

  CHK_SERVICE_NAME
      (
      p_integration_id=>p_integration_id
      ,p_partner_name  => p_rec.partner_name
      ,p_service_name  => p_rec.service_name
      ,p_language  => p_rec.language
      );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_itl_shd.g_rec_type
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


  CHK_SERVICE_NAME
      (
      p_integration_id=>p_rec.integration_id
      ,p_partner_name  => p_rec.partner_name
       ,p_service_name  => p_rec.service_name
       ,p_language  => p_rec.language
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
  (p_rec                          in hr_itl_shd.g_rec_type
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
end hr_itl_bus;

/
