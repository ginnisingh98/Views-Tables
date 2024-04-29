--------------------------------------------------------
--  DDL for Package Body HR_TTL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TTL_BUS" as
/* $Header: hrttlrhi.pkb 115.1 2004/04/05 07:21 menderby noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ttl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_topic_id                 number         default null;
g_language                    varchar2(4)    default null;
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
  (p_rec in hr_ttl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_ttl_shd.api_updating
      (p_topic_id                       => p_rec.topic_id,
       p_language                   => p_rec.language
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
-- ------------------------------< CHK_TOPIC_ID >------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the topic id entered in the TL table is
--   present in the base table.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_topic_id

-- Post Success:
--   Processing continues if topic id is present in the base table
--
-- Post Failure:
--   An application error is raised if topic id is absent in the base table
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_topic_id
(
  p_topic_id in number
)
is
  -- Declare cursors and local variables
  --
  -- Cursor to check if there is an entry in hr_ki_topics

CURSOR csr_ttl_parent is
  select
   'found'
  From
    hr_ki_topics  tpc
  where
    tpc.topic_id = p_topic_id;

 l_proc        varchar2(72) := g_package||'chk_topic_id';
 l_found       varchar2(10);

  Begin

   hr_utility.set_location(' Entering:' || l_proc,10);

   hr_api.mandatory_arg_error
   (p_api_name           => l_proc
   ,p_argument           => 'TOPIC_ID'
   ,p_argument_value     => p_topic_id
   );

   open csr_ttl_parent;
   fetch csr_ttl_parent into l_found;

   if csr_ttl_parent%NOTFOUND then
    close csr_ttl_parent;
    fnd_message.set_name('PER', 'PER_449934_TTL_TPC_ID_ABSENT');
    fnd_message.raise_error;
   end if;

   close csr_ttl_parent;

   hr_utility.set_location(' Leaving:' || l_proc,20);

Exception
 when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'HR_KI_TOPICS_TL.TOPIC_ID'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);
  --
  End chk_topic_id;

-- ----------------------------------------------------------------------------
-- ------------------------------< CHK_NAME >----------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the NAME value entered in the TL table is
--   not null and unique.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_topic_id

-- Post Success:
--   Processing continues if name is not null and unique
--
-- Post Failure:
--   An application error is raised if name is null or already present for a
--   language.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_name
(
  p_language in varchar2,
  p_name in varchar2,
  p_topic_id in number
)
is
  -- Declare cursors and local variables
  --
  -- Cursor to check if there is an entry in hr_ki_hierarchies

CURSOR csr_ttl_name is
  select
   'found'
  From
    hr_ki_topics_tl  ttl
  where
    ttl.language = p_language and
    ttl.name = p_name and
    ttl.topic_id <> p_topic_id;

 l_proc        varchar2(72) := g_package||'chk_name';
 l_found       varchar2(10);

  Begin

   hr_utility.set_location(' Entering:' || l_proc,10);

   hr_api.mandatory_arg_error
   (p_api_name           => l_proc
   ,p_argument           => 'NAME'
   ,p_argument_value     => p_name
   );

   open csr_ttl_name;
   fetch csr_ttl_name into l_found;

   if csr_ttl_name%FOUND then
    close csr_ttl_name;
    fnd_message.set_name('PER', 'PER_449935_TTL_NAME_DUPLI');
    fnd_message.raise_error;
   end if;

   close csr_ttl_name;

   hr_utility.set_location(' Leaving:' || l_proc,20);

Exception
 when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'HR_KI_TOPICS_TL.NAME'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);
  --
  End chk_name;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_ttl_shd.g_rec_type,
   p_topic_id                  in number
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
  --
  -- Validate Dependent Attributes
  chk_topic_id(p_topic_id);
  chk_name(p_rec.language,p_rec.name,p_topic_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_ttl_shd.g_rec_type
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
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );

 chk_name(p_rec.language,p_rec.name,p_rec.topic_id);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_ttl_shd.g_rec_type
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
end hr_ttl_bus;

/
