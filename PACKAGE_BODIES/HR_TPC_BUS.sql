--------------------------------------------------------
--  DDL for Package Body HR_TPC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TPC_BUS" as
/* $Header: hrtpcrhi.pkb 115.0 2004/01/09 04:37 vkarandi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_tpc_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_topic_id                    number         default null;
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
  (p_rec in hr_tpc_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_tpc_shd.api_updating
      (p_topic_id                          => p_rec.topic_id
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
  if nvl(p_rec.topic_key, hr_api.g_varchar2) <>
            nvl(hr_tpc_shd.g_old_rec.topic_key,hr_api.g_varchar2
                ) then
            hr_api.argument_changed_error
              (p_api_name   => l_proc
              ,p_argument   => 'TOPIC_KEY'
              ,p_base_table => hr_tpc_shd.g_tab_nam
              );
          end if;
  --
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- ------------------------------< CHK_TOPIC_KEY>------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid topic key is entered
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_topic_key

-- Post Success:
--   Processing continues if topic key is not null and unique
--
-- Post Failure:
--   An application error is raised if topic key is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_topic_key
(p_topic_key  in varchar2
)
is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to check if the hierarchy key provided in the insert is already
  -- present
  CURSOR csr_tpc_key is
    select
      distinct 'found'
    From
      hr_ki_topics  tpc
    where
      tpc.topic_key = p_topic_key;

  -- Variables for API Boolean parameters
  l_proc           varchar2(72) := g_package ||'chk_topic_key';
  l_found_flag     varchar2(10);

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
    hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'TOPIC_KEY'
    ,p_argument_value     => p_topic_key
    );

    OPEN csr_tpc_key;
    FETCH csr_tpc_key into l_found_flag;

    IF csr_tpc_key%FOUND then
        hr_utility.set_location(' Topic Key already present:' || l_proc,20);
        CLOSE csr_tpc_key;
        fnd_message.set_name( 'PER','PER_449930_TPC_KEY_DUPLICATE');
        fnd_message.raise_error;
    END IF;

    CLOSE csr_tpc_key;


  --
  hr_utility.set_location(' Leaving:' || l_proc,30);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'HR_KI_TOPICS.TOPIC_KEY'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,40);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,50);
  --
End chk_topic_key ;

-- ----------------------------------------------------------------------------
-- -------------------------------< CHK_HANDLER>-------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid handler is entered
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--  handler

-- Post Success:
--   Processing continues if handler is not null.
--
-- Post Failure:
--   An application error is raised if handler is null.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_handler(p_handler in varchar2)
is
  l_proc    varchar2(72) := g_package ||'chk_handler';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'HANDLER'
    ,p_argument_value     => p_handler
    );

  hr_utility.set_location(' Leaving:' || l_proc,20);

Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'HR_KI_TOPICS.HANDLER'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,40);
  --
End chk_handler;


-- ----------------------------------------------------------------------------
-- -------------------------------< CHK_DELETE>--------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a delete occurs only if there are no child
--   rows for a record in hr_ki_topics. The tables that contain child rows are
--   hr_ki_hierarchy_node_maps,hr_ki_topic_integrations,hr_ki_topics_tl.

-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--   p_topic_id

-- Post Success:
--   Processing continues if there are no child records.
--
-- Post Failure:
--   An application error is raised if there are any child rows from any of the
--   above mentioned tables.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_delete(p_topic_id in varchar2)
is

CURSOR csr_hnm_id is
    select
      distinct 'found'
    From
      hr_ki_hierarchy_node_maps  hnm
    where
      hnm.topic_id = p_topic_id;

CURSOR csr_tis_id is
    select
      distinct 'found'
    From
      hr_ki_topic_integrations  tis
    where
     tis.topic_id = p_topic_id;

CURSOR csr_ttl_id is
    select
      distinct 'found'
    From
      hr_ki_topics_tl  ttl
    where
      ttl.topic_id = p_topic_id;

l_found varchar2(30);
l_proc    varchar2(72) := g_package ||'chk_delete';

Begin

  hr_utility.set_location(' Entering:' || l_proc,10);

  open csr_hnm_id;
  fetch csr_hnm_id into l_found;

  if csr_hnm_id%FOUND then
    close csr_hnm_id;
    fnd_message.set_name( 'PER','PER_449931_TPC_NMAP_MAIN_EXIST');
    fnd_message.raise_error;
  end if;

  close csr_hnm_id;

  open csr_tis_id;
  fetch csr_tis_id into l_found;

  if csr_tis_id%FOUND then
    close csr_tis_id;
    fnd_message.set_name( 'PER','PER_449932_TPC_TPIN_MAIN_EXIST');
    fnd_message.raise_error;
  end if;

  close csr_tis_id;

  open csr_ttl_id;
  fetch csr_ttl_id into l_found;

  if csr_ttl_id%FOUND then
    close csr_ttl_id;
    fnd_message.set_name( 'PER','PER_449933_TPC_TPTL_MAIN_EXIST');
    fnd_message.raise_error;
  end if;

  close csr_ttl_id;

  hr_utility.set_location(' Leaving:'|| l_proc,20);

 Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'HR_KI_TOPICS.TOPIC_ID'
                 )THEN
       hr_utility.set_location(' Leaving:'|| l_proc,30);
       raise;
    END IF;
  hr_utility.set_location(' Leaving:'|| l_proc,40);

 End chk_delete;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in hr_tpc_shd.g_rec_type
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
  chk_topic_key(p_rec.topic_key);
  chk_handler(p_rec.handler);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in hr_tpc_shd.g_rec_type
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
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );

  chk_handler(p_rec.handler);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_tpc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  chk_delete(p_rec.topic_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end hr_tpc_bus;

/
