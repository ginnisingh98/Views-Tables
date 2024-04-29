--------------------------------------------------------
--  DDL for Package Body HR_OTT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_OTT_BUS" as
/* $Header: hrottrhi.pkb 115.1 2004/04/05 07:21 menderby noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ott_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_option_type_id              number         default null;
g_language                    varchar2(4)    default null;
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
  (p_rec in hr_ott_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_ott_shd.api_updating
      (p_option_type_id                    => p_rec.option_type_id
      ,p_language
                      => p_rec.language

      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_OPTION_NAME>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid name is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_name
--   p_language
-- Post Success:
--   Processing continues if name is not null and unique
--
-- Post Failure:
--   An application error is raised if name is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_option_name
  (
   p_option_type_id in number
  ,p_option_name     in varchar2
  ,p_language              in varchar2
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_option_name';
  l_name     varchar2(1);

  CURSOR csr_name IS
         select
           null
         from
           hr_ki_option_types_tl
         where
           option_type_id   <> p_option_type_id
           and option_name =p_option_name
           and language=p_language;


  l_check varchar2(1);

Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check value has been passed
  --
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'OPTION_NAME'
  ,p_argument_value     => p_option_name
  );
  hr_utility.set_location('Checking:'||l_proc,20);

-- check if the record already exists

   open csr_name;
   fetch csr_name into l_name;
   hr_utility.set_location('After fetching:'||l_proc,30);
   if (csr_name%found)
   then
     close csr_name;
     fnd_message.set_name('PER','PER_449951_OTT_NAME_DUPLICATE');
     fnd_message.raise_error;
   end if;
  close csr_name;

   hr_utility.set_location(' Leaving:'||l_proc,40);

   exception
    when app_exception.application_exception then
            if hr_multi_message.exception_add
            (p_associated_column1 => 'HR_KI_OPTION_TYPES_TL.OPTION_NAME'
            )then
              hr_utility.set_location(' Leaving:'||l_proc, 50);
              raise;
            end if;
        hr_utility.set_location(' Leaving:'||l_proc,60);


End chk_option_name;
--

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_option_type_id>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a if parent option type id exists
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_option_type_id
--
-- Post Success:
--   Processing continues if option type id exist in hr_ki_option_types table
--
-- Post Failure:
--   An application error is raised if id does not exist in hr_ki_option_types
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------


procedure chk_option_type_id
(
  p_option_type_id in number
)
is
  -- Declare cursors and local variables
  --
  -- Cursor to check if there is an entry in hr_ki_hi
  l_proc     varchar2(72) := g_package || 'chk_option_type_id';
  l_name     varchar2(1);


CURSOR csr_id is
  select
   null
  From
    hr_ki_option_types
  where
    option_type_id = p_option_type_id;

  Begin


   hr_utility.set_location(' Entering:' || l_proc,10);

   open csr_id;
   fetch csr_id into l_name;

   if csr_id%NOTFOUND then
    fnd_message.set_name('PER', 'PER_449950_OTT_ID_ABSENT');
    fnd_message.raise_error;
   end if;

   close csr_id;

   hr_utility.set_location(' Leaving:' || l_proc,20);

Exception
 when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'HR_KI_OPTION_TYPES_TL.OPTION_TYPE_ID'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);
  --
  End chk_option_type_id;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_ott_shd.g_rec_type
  ,p_option_type_id               in number
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  --call validation methods


  CHK_OPTION_TYPE_ID
  (
  p_option_type_id  => p_option_type_id
  );

  CHK_OPTION_NAME
      (
        p_option_type_id => p_option_type_id
       ,p_option_name  => p_rec.option_name
       ,p_language     => p_rec.language
      );


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_ott_shd.g_rec_type
   ,p_option_type_id              in number
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );

  CHK_OPTION_NAME
      (
        p_option_type_id => p_option_type_id
       ,p_option_name  => p_rec.option_name
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
  (p_rec                          in hr_ott_shd.g_rec_type
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
end hr_ott_bus;

/
