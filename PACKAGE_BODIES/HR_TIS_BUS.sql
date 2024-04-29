--------------------------------------------------------
--  DDL for Package Body HR_TIS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIS_BUS" as
/* $Header: hrtisrhi.pkb 120.3 2008/02/25 13:24:06 avarri ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_tis_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_topic_integrations_id       number         default null;
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
  (p_rec in hr_tis_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_tis_shd.api_updating
      (p_topic_integrations_id             => p_rec.topic_integrations_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;


End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_integration_id>------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures integration_id is present in hr_ki_integrations
--   and it is mandatory.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_integration_id
--
-- Post Success:
--   Processing continues if integration_id is valid
--
-- Post Failure:
--   An application error is raised if integration_id is invalid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_integration_id
  (p_integration_id     in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_integration_id';
  l_key      hr_ki_integrations.integration_id%type;
  cursor csr_int is
         select INTEGRATION_ID
           from hr_ki_integrations
          where  integration_id = p_integration_id;


--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

--integration_id should not be null

    hr_api.mandatory_arg_error
        (p_api_name           => l_proc
        ,p_argument           => 'INTEGRATION_ID'
        ,p_argument_value     => p_integration_id
    );


  hr_utility.set_location('Validating:'||l_proc,20);


    open csr_int;
    fetch csr_int into l_key;
    hr_utility.set_location('After fetching :'||l_proc,30);
    if (csr_int%notfound) then
      close csr_int;
      fnd_message.set_name('PER','PER_449962_TIS_INT_ID_ABSENT');
      fnd_message.raise_error;
    end if;
    close csr_int;

  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_TOPIC_INTEGRATIONS.INTEGRATION_ID'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,60);
End chk_integration_id;


-- ----------------------------------------------------------------------------
-- |-----------------------< chk_topic_id>------------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures topic_id is present in hr_ki_topics
--   and it is mandatory.
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_topic_id
--
-- Post Success:
--   Processing continues if topic_id exists in parent table.
--
-- Post Failure:
--   An application error is raised if topic_id does not exist in parent table
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

Procedure chk_topic_id
  (p_topic_id     in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_topic_id';
  l_key      hr_ki_topics.topic_id%type;
  cursor csr_int is
         select topic_id
           from hr_ki_topics
          where  topic_id = p_topic_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);

--topic_id should not be null

    hr_api.mandatory_arg_error
        (p_api_name           => l_proc
        ,p_argument           => 'TOPIC_ID'
        ,p_argument_value     => p_topic_id
    );

  hr_utility.set_location('Validating:'||l_proc,20);

    open csr_int;
    fetch csr_int into l_key;
    hr_utility.set_location('After fetching :'||l_proc,30);
    if (csr_int%notfound) then
      close csr_int;
      fnd_message.set_name('PER','PER_449963_TIS_TOPIC_ID_ABSENT');
      fnd_message.raise_error;
    end if;
    close csr_int;

  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_associated_column1 => 'HR_KI_TOPIC_INTEGRATIONS.TOPIC_ID'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,60);
End chk_topic_id;


-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_UNIQUE_RECORD>-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures if record is unique for combination of
--   topic_id,integration_id
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_topic_id,p_integration_id
--
-- Post Success:
--   Processing continues record is valid
--
-- Post Failure:
--   An application error is raised for invalid record
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_UNIQUE_RECORD
  (
  p_topic_id in number
  ,p_integration_id     in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_UNIQUE_RECORD';
  l_found   varchar2(1);

    cursor csr_int_options is
           select null
             from hr_ki_topic_integrations
            where  topic_id = p_topic_id
            and integration_id = p_integration_id;
--
Begin
    hr_utility.set_location('Entering:'||l_proc,10);

-- Only proceed with topic_id/ integration_id validation when the
-- Multiple Message List does not already contain an errors
-- associated with the topic_id/integration_id columns.
--
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'HR_KI_TOPIC_INTEGRATIONS.TOPIC_ID'
       ,p_associated_column1 => 'HR_KI_TOPIC_INTEGRATIONS.TOPIC_ID'
       ,p_check_column2      => 'HR_KI_TOPIC_INTEGRATIONS.INTEGRATION_ID'
       ,p_associated_column2 => 'HR_KI_TOPIC_INTEGRATIONS.INTEGRATION_ID'
       ) then


    open  csr_int_options;
    fetch csr_int_options into l_found;

    if (csr_int_options%found) then
      close csr_int_options;
      fnd_message.set_name('PER','PER_449964_TIS_INVALID_COMB');
      fnd_message.raise_error;
      end if;
   close csr_int_options;

  end if;
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_same_associated_columns => 'Y'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_UNIQUE_RECORD;


-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_UNIQUE_RECORD_UPD>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures if record is unique for combination of
--   topic_id,integration_id
--   If earlier procedure is used for update validation then error will be
--   thrown even if combination is unique and not null as earlier query
--   does not have addtional p_topic_integrations_id condition in the cursor.
--   Hence for current record also earlier cursor throws error.
--   We can not combine these 2 methods as p_topic_integrations_id is not
--   available at the time of insert_validation
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_topic_id,p_integration_id,p_topic_integrations_id
--
-- Post Success:
--   Processing continues record is valid
--
-- Post Failure:
--   An application error is raised for invalid record
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure CHK_UNIQUE_RECORD_UPD
  (
  p_topic_id in number
  ,p_integration_id     in number
  ,p_topic_integrations_id in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_UNIQUE_RECORD_UPD';
  l_found   varchar2(1);

    cursor csr_int_options is
           select null
             from hr_ki_topic_integrations
            where  topic_id = p_topic_id
            and integration_id = p_integration_id
            and topic_integrations_id <> p_topic_integrations_id;
--
Begin
    hr_utility.set_location('Entering:'||l_proc,10);

-- Only proceed with topic_id/ integration_id validation when the
-- Multiple Message List does not already contain an errors
-- associated with the topic_id/integration_id columns.
--
  if hr_multi_message.no_exclusive_error
       (p_check_column1      => 'HR_KI_TOPIC_INTEGRATIONS.TOPIC_ID'
       ,p_associated_column1 => 'HR_KI_TOPIC_INTEGRATIONS.TOPIC_ID'
       ,p_check_column2      => 'HR_KI_TOPIC_INTEGRATIONS.INTEGRATION_ID'
       ,p_associated_column2 => 'HR_KI_TOPIC_INTEGRATIONS.INTEGRATION_ID'
       ) then


    open  csr_int_options;
    fetch csr_int_options into l_found;

    if (csr_int_options%found) then
      close csr_int_options;
      fnd_message.set_name('PER','PER_449964_TIS_INVALID_COMB');
      fnd_message.raise_error;
      end if;
   close csr_int_options;

  end if;
  exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
    (p_same_associated_columns => 'Y'
    )then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,50);
End CHK_UNIQUE_RECORD_UPD;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_tis_shd.g_rec_type
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
    CHK_TOPIC_ID
      (
       p_topic_id  => p_rec.topic_id
      );

    CHK_INTEGRATION_ID
      (
       p_integration_id  => p_rec.integration_id
      );

    CHK_UNIQUE_RECORD
      (
       p_topic_id  => p_rec.topic_id
       ,p_integration_id  => p_rec.integration_id
      );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_tis_shd.g_rec_type
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

    CHK_TOPIC_ID
      (
       p_topic_id  => p_rec.topic_id
      );

    CHK_INTEGRATION_ID
      (
       p_integration_id  => p_rec.integration_id
      );

    CHK_UNIQUE_RECORD_UPD
      (
       p_topic_id  => p_rec.topic_id
       ,p_integration_id  => p_rec.integration_id
       ,p_topic_integrations_id =>p_rec.topic_integrations_id
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
  (p_rec                          in hr_tis_shd.g_rec_type
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
end hr_tis_bus;

/
