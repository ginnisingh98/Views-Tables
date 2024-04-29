--------------------------------------------------------
--  DDL for Package Body PER_DRX_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRX_BUS" as
/* $Header: pedrxrhi.pkb 120.0.12010000.2 2018/06/25 07:21:06 hardeeps noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_drx_bus.';  -- Global package name
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
  (p_rec in per_drx_shd.g_rec_type
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
  IF NOT per_drx_shd.api_updating
      (p_ff_column_id               => p_rec.ff_column_id
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
Procedure chk_parameter_values
  (p_rec                          in per_drx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_parameter_values';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
		if p_rec.rule_type = 'Fixed String' and p_rec.parameter_1 is null then
    		fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
    		fnd_message.set_token('COL_NAME','Parameter_1');
    		fnd_message.set_token('TYPE','rule type Fixed String');
   			fnd_message.raise_error;
		elsif p_rec.rule_type = 'Random Number' then
			if p_rec.parameter_1 is null then
    		fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
    		fnd_message.set_token('COL_NAME','Parameter_1');
    		fnd_message.set_token('TYPE','rule type Random Number');
   			fnd_message.raise_error;
			elsif p_rec.parameter_2 is null then
    		fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
    		fnd_message.set_token('COL_NAME','Parameter_2');
    		fnd_message.set_token('TYPE','rule type Random Number');
   			fnd_message.raise_error;
			end if;
		elsif p_rec.rule_type = 'Random String' then
			if p_rec.parameter_1 is null then
    		fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
    		fnd_message.set_token('COL_NAME','Parameter_1');
    		fnd_message.set_token('TYPE','rule type Random String');
   			fnd_message.raise_error;
			elsif p_rec.parameter_2 is null then
    		fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
    		fnd_message.set_token('COL_NAME','Parameter_2');
    		fnd_message.set_token('TYPE','rule type Random String');
   			fnd_message.raise_error;
			end if;
		elsif p_rec.rule_type = 'User Defined Function' then
			if p_rec.parameter_1 is null then
    		fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
    		fnd_message.set_token('COL_NAME','Parameter_1');
    		fnd_message.set_token('TYPE','rule type User Defined Function');
   			fnd_message.raise_error;
			elsif p_rec.parameter_2 is null then
    		fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
    		fnd_message.set_token('COL_NAME','Parameter_2');
    		fnd_message.set_token('TYPE','rule type User Defined Function');
   			fnd_message.raise_error;
			end if;
		elsif p_rec.rule_type = 'Post Process' then
			if p_rec.parameter_1 is null then
    		fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
    		fnd_message.set_token('COL_NAME','Parameter_1');
    		fnd_message.set_token('TYPE','rule type Post Process');
   			fnd_message.raise_error;
			elsif p_rec.parameter_2 is null then
    		fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
    		fnd_message.set_token('COL_NAME','Parameter_2');
    		fnd_message.set_token('TYPE','rule type Post Process');
   			fnd_message.raise_error;
			end if;
		end if;

	begin
		if p_rec.rule_type = 'Random String' then
			if to_number (p_rec.parameter_1) < 1 then
    		fnd_message.set_name('PER', 'PER_500058_DRT_PMTR_NEG');
    		fnd_message.set_token('COL_NAME','Parameter_1');
    		fnd_message.raise_error;
			elsif to_number (p_rec.parameter_2) < 1 then
    		fnd_message.set_name('PER', 'PER_500058_DRT_PMTR_NEG');
    		fnd_message.set_token('COL_NAME','Parameter_2');
    		fnd_message.raise_error;
			end if;
		end if;
		if p_rec.rule_type = 'Random String' or p_rec.rule_type = 'Random Number' then
if to_number (p_rec.parameter_1) > to_number (p_rec.parameter_2) then
    fnd_message.set_name('PER', 'PER_500059_DRT_PRM_INVLD');
    fnd_message.raise_error;
end if;
end if;
exception
when value_error then
    fnd_message.set_name('PER', 'PER_500060_DRT_TYPE_INVLD');
    fnd_message.raise_error;
end;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_parameter_values;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_drx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
	l_unique_flag varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
	    l_unique_flag := per_drt_pkg.check_contexts_uniqueness
                                                        (p_column_id        => p_rec.column_id
																												,p_flexfield_name        	=> p_rec.ff_name
                                                        ,p_context_name     => p_rec.context_name);

		if l_unique_flag = 'N' then
				fnd_message.set_name('PER','PER_7901_SYS_DUPLICATE_RECORDS');
        fnd_message.raise_error;
    end if;

		chk_parameter_values(p_rec);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_drx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
	l_luby fnd_user.user_id%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations

		chk_parameter_values(p_rec);
  --
	select last_updated_by into l_luby from per_drt_col_contexts where ff_column_id = p_rec.ff_column_id;
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
  (p_rec                          in per_drx_shd.g_rec_type
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
	select last_updated_by into l_luby from per_drt_col_contexts where ff_column_id = p_rec.ff_column_id;
	if (l_luby = 121 or l_luby = 122) then
			fnd_message.set_name ('PER','PER_500048_DATA_NON_UPDATBLE');
			fnd_message.raise_error;
	end if;
	--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end per_drx_bus;

/
