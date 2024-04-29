--------------------------------------------------------
--  DDL for Package Body PER_SBT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SBT_BUS" as
/* $Header: pesbtrhi.pkb 120.0 2005/05/31 20:43:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_sbt_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_subjects_taken_id           number         default null;
g_language                    varchar2(4)    default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
-- PF - The base table does not have a business group ID, but it does
-- call the qualifications set_business_group_id. We therefore need to
-- derive the qualification_id from the base table, so we can call
-- per_qua_bus.set_security_group_id (it would be better to call
-- per_sbt_bus.set_secutity_group_id, but that does not exist...)
--
Procedure set_security_group_id
  (p_subjects_taken_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  -- PF - This cursor gets the qualification_id from the base table
  --
  cursor csr_qua_id is
    select sub.qualification_id
      from per_subjects_taken sub
     where sub.subjects_taken_id = p_subjects_taken_id;
  --
  -- Declare local variables
  --
  l_qualification_id number;
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
    ,p_argument           => 'subjects_taken_id'
    ,p_argument_value     => p_subjects_taken_id
    );
  --
  --
  open csr_qua_id;
  fetch csr_qua_id into l_qualification_id;
  --
  if csr_qua_id%notfound then
     --
     close csr_qua_id;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'SUBJECTS_TAKEN_ID')
       );
     --
  else
    close csr_qua_id;
    --
    -- PF - Now set the security group via per_qua_bus.set_security_group_id
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    per_qua_bus.set_security_group_id
      ( p_qualification_id => l_qualification_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
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
  (p_rec in per_sbt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_sbt_shd.api_updating
      (p_subjects_taken_id                 => p_rec.subjects_taken_id
      ,p_language                          => p_rec.language
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- PF - No non-updateable fields
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_sbt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_language_code   VARCHAR2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- PF - Call local procedure
  --set_security_group_id( p_subjects_taken_id => p_rec.subjects_taken_id
  --                     );
  --
  -- PF - subjects_taken_id is already implicitly validated against base
  -- table in set_security_group_id; Do not need to do again
  --
  -- PF - calling api language validation as there is no API package yet.
  l_language_code := p_rec.source_lang;
  hr_api.validate_language_code ( p_language_code => l_language_code
                                );
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
  (p_rec                          in per_sbt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_language_code   VARCHAR2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- PF - Call local procedure
  --set_security_group_id( p_subjects_taken_id => p_rec.subjects_taken_id
  --                     );
  --
  -- PF - subjects_taken_id is already implicitly validated against base
  -- table in set_security_group_id; Do not need to do again
  --
  -- PF - calling api language validation as there is no API package yet.
  l_language_code := p_rec.source_lang;
  hr_api.validate_language_code ( p_language_code => l_language_code
                                );
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
  (p_rec                          in per_sbt_shd.g_rec_type
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
end per_sbt_bus;

/
