--------------------------------------------------------
--  DDL for Package Body PQH_GIN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GIN_BUS" as
/* $Header: pqginrhi.pkb 115.7 2004/03/15 03:05 svorugan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_gin_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_global_index_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_global_index_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
 cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
      where pbg.business_group_id = hr_general.get_business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'global_index_id'
    ,p_argument_value     => p_global_index_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
         => nvl(p_associated_column1,'GLOBAL_INDEX_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_global_index_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
     where pbg.business_group_id = hr_general.get_business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'global_index_id'
    ,p_argument_value     => p_global_index_id
    );
  --
  if ( nvl(pqh_gin_bus.g_global_index_id, hr_api.g_number)
       = p_global_index_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_gin_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pqh_gin_bus.g_global_index_id             := p_global_index_id;
    pqh_gin_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_effective_date  in date
  ,p_rec             in pqh_gin_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_gin_shd.api_updating
      (p_global_index_id                  => p_rec.global_index_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  -- GROSS_INDEX

  IF NVL(p_rec.gross_index, hr_api.g_number) <>
               nvl(pqh_gin_shd.g_old_rec.gross_index
                  ,hr_api.g_number
                  ) then
              hr_api.argument_changed_error
                (p_api_name   => l_proc
                ,p_argument   => 'GROSS_INDEX'
                ,p_base_table => pqh_gin_shd.g_tab_nam
                );
  END IF;
  --
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
    --
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_global_index_id                  in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'global_index_id'
      ,p_argument_value => p_global_index_id
      );
    --
  --
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- Check procedures

Procedure chk_record_type (p_type_of_record in varchar2 )
IS

Cursor csr_record_type IS
Select null
from hr_lookups
where lookup_type = 'PQH_FR_TYPE_OF_INDICES'
and lookup_code = p_type_of_record;
--
l_value varchar2(30):= null;
--
Begin

	Open csr_record_type;
	--
	   Fetch csr_record_type into l_value;

	   If (csr_record_type%NOTFOUND) then
	   --
	     fnd_message.set_name('PQH','PQH_FR_INVALID_INDICES_TYPE');
	     hr_multi_message.add (p_associated_column1 => 'TYPE_OF_RECORD');
       	   --
	  End If;
	--
	Close csr_record_type;

End chk_record_type;

--
--
Procedure chk_IND_values_inputted(p_type_of_record in varchar2,
				 p_gross_index in number,
				 p_increased_index in number)
IS

Begin

-- Gross_index, increased_index are associated with IND
-- Housing Indeminity housing_indemnity_rate, Basic Salary Rate basic_salary_rate are associated with INM

	If (p_type_of_record = 'INM' ) then
	--
		If (p_gross_index is not null or
				p_increased_index is not null) then
		--
		fnd_message.set_name('PQH','PQH_FR_INVALID_INM_VALUES');
	        hr_multi_message.add;
	        --
	        End if;

	--
	End if;

End chk_IND_values_inputted;

--
Procedure chk_INM_values_inputted(p_type_of_record in varchar2,
				 p_housing_indemnity_rate in number,
				 p_basic_salary_rate in number)
IS

Begin

-- Gross_index, increased_index are associated with IND
-- Housing Indeminity housing_indemnity_rate, Basic Salary Rate basic_salary_rate are associated with INM

	If (p_type_of_record = 'IND' ) then
	--
		If (p_housing_indemnity_rate is not null or
				p_basic_salary_rate is not null) then
		--
		fnd_message.set_name('PQH','PQH_FR_INVALID_IND_VALUES');
	        hr_multi_message.add;
	        --
	        End if;

	--
	End if;

End chk_INM_values_inputted;
--
--
Procedure chk_INM_record_existence
IS
--
Cursor csr_INM_record_existence IS
Select null
from pqh_fr_global_indices_f
where type_of_record = 'INM';
--
l_value varchar2(10);

Begin

	Open csr_INM_record_existence;
	--
	  Fetch csr_INM_record_existence into l_value;

	  If csr_INM_record_existence%FOUND then
	  --
	  fnd_message.set_name('PQH','PQH_FR_NO_SECOND_INM_ROW');
	        hr_multi_message.add;
	  --
	  End If;
	--
	Close csr_INM_record_existence;
--
End chk_INM_record_existence;
--
--
Procedure chk_currency(p_currency_code in varchar2 )
IS
Cursor csr_currency is
Select null
from fnd_currencies_vl
where currency_code = p_currency_code
and   currency_flag = 'Y'
and   enabled_flag  = 'Y';

l_value varchar2(10);
begin
--

	If p_currency_code is not null then
	--
	Open csr_currency;
	--
	   Fetch csr_currency into l_value;

	   If csr_currency%notfound then
	   	  fnd_message.set_name('PQH','PQH_FR_INVALID_CURRENCY');
	   	        hr_multi_message.add;
	   End if;
  	--
  	Close csr_currency;
  	--
  	End if;
--
End chk_currency;
--
--
--This chk will be done, before creating an entry for Global Index
--
Procedure chk_inm_existance(p_effective_date date)
IS
Cursor csr_ind_existance is
Select null
from pqh_fr_global_indices_f
where p_effective_date between effective_start_date and effective_end_date
and   type_of_record = 'INM';
--
l_value varchar2(10);
--
begin

	Open csr_ind_existance;
	--
	   Fetch csr_ind_existance into l_value;

	   If csr_ind_existance%NOTFOUND then
	   --
 	   	  fnd_message.set_name('PQH','PQH_FR_NO_INDM_RATES');
 	   	  fnd_message.set_token('DATE',p_effective_date);
         	  hr_multi_message.add;
   	   --
   	   End if;
   	--
   	Close csr_ind_existance;
--
End chk_inm_existance;

--
Procedure chk_steps_exist_for_index(p_global_index_id number, p_effective_date date)
IS
Cursor csr_current_record IS
Select Gross_index
from pqh_fr_global_indices_f
where global_index_id = p_global_index_id
and   p_effective_date between effective_start_date and effective_end_date;
--
l_gross_index number;
l_exists varchar2(10);
Begin

	Open csr_current_record;
	--
	  Fetch csr_current_record into l_gross_index;
	--
	Close csr_current_record;

	Select pqh_corps_utility.chk_steps_exist_for_index(l_gross_index) into l_exists from dual;

	if (l_exists = 'Y') then
	   --
	   	  fnd_message.set_name('PQH','PQH_FR_STEPS_EXIST_FOR_INDEX');
	       	  hr_multi_message.add;
	   --
	End if;



End;

procedure chk_unique_insert(p_gross_index number)
IS

Cursor csr_unique is
Select null
from pqh_fr_global_indices_f
where gross_index =p_gross_index;
--
l_value varchar2(1);
Begin

	Open csr_unique;
	--
	  Fetch csr_unique into l_value;

	  If csr_unique%found Then
	  --
	    fnd_message.set_name('PQH','PQH_FR_RECORD_IB_EXIST');
	    fnd_message.set_token('IB',p_gross_index);
	    hr_multi_message.add;

	  --
	  End if;
--
End chk_unique_insert;

---
procedure chk_unique_update(p_gross_index number, p_increased_index number,p_global_index_id number)
IS

Cursor csr_unique is
Select null
from pqh_fr_global_indices_f
where gross_index =p_gross_index
and   increased_index = p_increased_index
and   global_index_id <> p_global_index_id;
--
l_value varchar2(1);
Begin

	Open csr_unique;
	--
	  Fetch csr_unique into l_value;

	  If csr_unique%found Then
	  --
	    fnd_message.set_name('PQH','PQH_FR_RECORD_COMB_EXIST');
	    fnd_message.set_token('IB',p_gross_index);
	    fnd_message.set_token('INM',p_increased_index);
	    hr_multi_message.add;

	  --
	  End if;
--
End chk_unique_update;

--
procedure chk_is_negetive_BS_rate(p_basic_salary_rate number)
IS
--
Begin

   If (round(p_basic_salary_rate,3) <= 0) then
    --
     fnd_message.set_name('PQH','PQH_FR_NO_NEG_BS_RATE');
     hr_multi_message.add;
    --
   End if;

--
End chk_is_negetive_BS_rate;

--
procedure chk_is_negetive_HI_rate(p_housing_indemnity_rate number)
IS
--
Begin
	If (round(p_housing_indemnity_rate,3) <= 0) then
	--

	  fnd_message.set_name('PQH','PQH_FR_NO_NEG_HI_RATE');
          hr_multi_message.add;

	--
	End if;

--
End chk_is_negetive_HI_rate;

--
procedure chk_is_negetive_GI_rate(p_gross_index number)
IS
--
Begin
 	If (p_gross_index <= 0 ) then
 	--
	  fnd_message.set_name('PQH','PQH_FR_NO_NEG_GI_RATE');
          hr_multi_message.add;

 	--
 	End if;

--
End chk_is_negetive_GI_rate;


--
procedure chk_is_negetive_II_rate(p_increased_index number)
IS
--
Begin
 	If (p_increased_index <= 0 ) then
 	--
	  fnd_message.set_name('PQH','PQH_FR_NO_NEG_II_RATE');
          hr_multi_message.add;

 	--
 	End if;
--
End chk_is_negetive_II_rate;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pqh_gin_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

     hr_api.validate_bus_grp_id
    		(p_business_group_id => nvl(hr_general.get_business_group_id,0) );

     chk_unique_insert(p_rec.gross_index);

     hr_multi_message.end_validation_set;

     chk_record_type ( p_rec.type_of_record );

     chk_currency (p_rec.currency_code);

     If (p_rec.type_of_record = 'INM') then
     --
     -- System will not allowed to have second entry from Indemnity,
     -- As user can always update (create date-track version) for the same entry.
     --
     	chk_INM_record_existence;

     	chk_is_negetive_BS_rate(p_rec.basic_salary_rate);

     	chk_is_negetive_HI_rate(p_rec.housing_indemnity_rate);

     --
     End if;

     If (p_rec.type_of_record ='IND') then
     --
     -- Checks is there any Indemnity defined in the system as on the effective date
     -- or not .. If not system will throw an error
     -- Bcoz , with out an Indemnity having indeces is no meaning.
     --
          chk_inm_existance(p_effective_date);

          chk_is_negetive_GI_rate(p_rec.gross_index);

          chk_is_negetive_II_rate(p_rec.increased_index);
     --
     End if;

     hr_multi_message.end_validation_set;

  --
  -- Validate Dependent Attributes
  --
  chk_IND_values_inputted(p_rec.type_of_record ,
  				 p_rec.gross_index ,
  				 p_rec.increased_index );

  chk_INM_values_inputted(p_rec.type_of_record ,
  				 p_rec.housing_indemnity_rate ,
				 p_rec.basic_salary_rate );

   hr_multi_message.end_validation_set;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pqh_gin_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

   hr_api.validate_bus_grp_id
    		(p_business_group_id => nvl(hr_general.get_business_group_id,0) );

  chk_unique_update(p_rec.gross_index,p_rec.increased_index,p_rec.global_index_id);

  hr_multi_message.end_validation_set;


  If (p_rec.type_of_record = 'INM') then
       --
       --

       	chk_is_negetive_BS_rate(p_rec.basic_salary_rate);

       	chk_is_negetive_HI_rate(p_rec.housing_indemnity_rate);

       --
  End if;

  If (p_rec.type_of_record ='IND') then
       --
       --

            chk_is_negetive_GI_rate(p_rec.gross_index);

            chk_is_negetive_II_rate(p_rec.increased_index);
       --
 End if;

  chk_record_type ( p_rec.type_of_record );

  chk_currency (p_rec.currency_code);
  --
  -- Validate Dependent Attributes
  --
  chk_IND_values_inputted(p_rec.type_of_record ,
    				 p_rec.gross_index ,
    				 p_rec.increased_index );

  chk_INM_values_inputted(p_rec.type_of_record ,
    				 p_rec.housing_indemnity_rate ,
  				 p_rec.basic_salary_rate );

  hr_multi_message.end_validation_set;

  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
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
  (p_rec                    in pqh_gin_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_global_index_id                  => p_rec.global_index_id
    );
  --

  chk_steps_exist_for_index(p_rec.global_index_id, p_effective_date);


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_gin_bus;

/
