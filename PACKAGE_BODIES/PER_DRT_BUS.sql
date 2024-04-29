--------------------------------------------------------
--  DDL for Package Body PER_DRT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRT_BUS" as
/* $Header: pedrtrhi.pkb 120.0.12010000.2 2018/06/25 07:19:17 hardeeps noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_drt_bus.';  -- Global package name
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
  (p_rec in per_drt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_drt_shd.api_updating
      (p_table_id                   => p_rec.table_id
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
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_drt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
	l_unique_flag varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

	    l_unique_flag := per_drt_pkg.check_tables_uniqueness
                                                        (p_table_name        => p_rec.table_name
                                                        ,p_table_phase       => p_rec.table_phase
                                                        ,p_record_identifier => p_rec.record_identifier);

		if l_unique_flag = 'N' then
				fnd_message.set_name('PER','PER_7901_SYS_DUPLICATE_RECORDS');
        fnd_message.raise_error;
    end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_drt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
	l_luby fnd_user.user_id%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  	select last_updated_by into l_luby from per_drt_tables where table_id = p_rec.table_id;
	if (l_luby = 121 or l_luby = 122) then
			fnd_message.set_name ('PER','PER_500048_DATA_NON_UPDATBLE');
			fnd_message.raise_error;
	end if;
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_drt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
  	l_luby fnd_user.user_id%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
	select last_updated_by into l_luby from per_drt_tables where table_id = p_rec.table_id;
	if (l_luby = 121 or l_luby = 122) then
			fnd_message.set_name ('PER','PER_500048_DATA_NON_UPDATBLE');
			fnd_message.raise_error;
	end if;
	--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_drt_bus;

/
