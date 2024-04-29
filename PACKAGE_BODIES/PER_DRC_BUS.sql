--------------------------------------------------------
--  DDL for Package Body PER_DRC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRC_BUS" as
/* $Header: pedrcrhi.pkb 120.0.12010000.4 2019/10/31 09:28:15 jaakhtar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_drc_bus.';  -- Global package name
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
  (p_rec in per_drc_shd.g_rec_type
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
  IF NOT per_drc_shd.api_updating
      (p_column_id               => p_rec.column_id
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
  (p_rec                          in per_drc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
	l_unique_flag varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
	    l_unique_flag := per_drt_pkg.check_columns_uniqueness
                                                        (p_table_id        => p_rec.table_id
                                                        ,p_column_name     => p_rec.column_name);

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
  (p_rec                          in per_drc_shd.g_rec_type
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
  	select last_updated_by into l_luby from per_drt_columns where column_id = p_rec.column_id;
	if (l_luby = 121 or l_luby = 122) then
			hr_utility.set_location('l_luby: '||l_luby, 5);
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
  (p_rec                          in per_drc_shd.g_rec_type
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
  	select last_updated_by into l_luby from per_drt_columns where column_id = p_rec.column_id;
	if (l_luby = 121 or l_luby = 122) then
			fnd_message.set_name ('PER','PER_500048_DATA_NON_UPDATBLE');
			fnd_message.raise_error;
	end if;
	--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
Procedure chk_parameter_values
  (p_rec                          in per_drc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_parameter_values';

  --Bug # 30461218
   cursor csr_hr_look is
    select null
      from hr_lookups
     where meaning  = p_rec.rule_type
       and lookup_type  = 'DRT_RULE_TYPE'
       and enabled_flag = 'Y'
       and trunc(sysdate) between
               nvl(start_date_active, trunc(sysdate))
           and nvl(end_date_active, trunc(sysdate));

  l_exists     varchar2(1);
  --Bug # 30461218
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --Bug # 30461218
    if p_rec.rule_type is not null then


		  open csr_hr_look;
		  fetch csr_hr_look into l_exists;
		  if csr_hr_look%notfound then
		    close csr_hr_look;
			    	fnd_message.set_name('PER', 'PER_500085_DRT_RULE_INV');
			   		fnd_message.raise_error;
		  else
		    close csr_hr_look;
		  end if;
		end if;
	--Bug # 30461218
		if p_rec.ff_type = 'NONE' then
				if p_rec.attribute is null then
			    	fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
			    	fnd_message.set_token('COL_NAME','Attribute');
			    	fnd_message.set_token('TYPE','flexfield type NONE');
			   		fnd_message.raise_error;
				elsif p_rec.column_phase is null then
			    	fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
			    	fnd_message.set_token('COL_NAME','Column Phase');
			    	fnd_message.set_token('TYPE','flexfield type NONE');
			   		fnd_message.raise_error;
				elsif p_rec.rule_type is null then
			    	fnd_message.set_name('PER', 'PER_500056_DRT_CLMN_NULL');
			    	fnd_message.set_token('COL_NAME','Rule Type');
			    	fnd_message.set_token('TYPE','flexfield type NONE');
			   		fnd_message.raise_error;
				else
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
				end if;
		else
				if p_rec.attribute is not null then
		  			fnd_message.set_name('PER', 'PER_500057_DRT_CLMN_NO_NULL');
		  			fnd_message.set_token('COL_NAME','Attribute');
		  			fnd_message.set_token('TYPE','flexfield type DDF/DFF/KFF');
				elsif p_rec.column_phase is not null then
	    			fnd_message.set_name('PER', 'PER_500057_DRT_CLMN_NO_NULL');
	    			fnd_message.set_token('COL_NAME','Column Phase');
	    			fnd_message.set_token('TYPE','flexfield type DDF/DFF/KFF');
				elsif p_rec.rule_type is not null then
	    			fnd_message.set_name('PER', 'PER_500057_DRT_CLMN_NO_NULL');
	    			fnd_message.set_token('COL_NAME','Rule Type');
	    			fnd_message.set_token('TYPE','flexfield type DDF/DFF/KFF');
				elsif p_rec.parameter_1 is not null then
	    			fnd_message.set_name('PER', 'PER_500057_DRT_CLMN_NO_NULL');
	    			fnd_message.set_token('COL_NAME','Parameter_1');
	    			fnd_message.set_token('TYPE','flexfield type DDF/DFF/KFF');
				elsif p_rec.parameter_2 is not null then
	    			fnd_message.set_name('PER', 'PER_500057_DRT_CLMN_NO_NULL');
	    			fnd_message.set_token('COL_NAME','Parameter_2');
	    			fnd_message.set_token('TYPE','flexfield type DDF/DFF/KFF');
				end if;
		end if;

	-- Check whether paramter values are valid
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

end chk_parameter_values;
--

end per_drc_bus;

/
