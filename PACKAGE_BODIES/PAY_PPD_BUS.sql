--------------------------------------------------------
--  DDL for Package Body PAY_PPD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PPD_BUS" as
/* $Header: pyppdrhi.pkb 120.2 2005/12/29 01:38 nprasath noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_ppd_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_paye_details_id             number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_paye_details_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_pl_paye_details_f ppd
     where ppd.paye_details_id = p_paye_details_id
       and pbg.business_group_id = ppd.business_group_id;
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
    ,p_argument           => 'paye_details_id'
    ,p_argument_value     => p_paye_details_id
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
         => nvl(p_associated_column1,'PAYE_DETAILS_ID')
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
  (p_paye_details_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_pl_paye_details_f ppd
     where ppd.paye_details_id = p_paye_details_id
       and pbg.business_group_id = ppd.business_group_id;
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
    ,p_argument           => 'paye_details_id'
    ,p_argument_value     => p_paye_details_id
    );
  --
  if ( nvl(pay_ppd_bus.g_paye_details_id, hr_api.g_number)
       = p_paye_details_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_ppd_bus.g_legislation_code;
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
    pay_ppd_bus.g_paye_details_id             := p_paye_details_id;
    pay_ppd_bus.g_legislation_code  := l_legislation_code;
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
  ,p_rec             in pay_ppd_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';

cursor csr_contract_type(p_per_or_asg_id  number,
                           p_effective_date date) is
   select segment4
     from hr_soft_coding_keyflex soft, per_all_assignments_f paaf
    where soft.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
      and paaf.assignment_id = p_per_or_asg_id
      and p_effective_date between paaf.effective_start_date and paaf.effective_end_date;

l_contract_type hr_soft_coding_keyflex.segment4%TYPE;
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_ppd_shd.api_updating
      (p_paye_details_id                  => p_rec.paye_details_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
   if nvl(p_rec.business_group_id, hr_api.g_number) <>
	     nvl(pay_ppd_shd.g_old_rec.business_group_id
	        ,hr_api.g_number
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'BUSINESS_GROUP_ID'
	      ,p_base_table => pay_ppd_shd.g_tab_nam
	      );
   end if;

   if nvl(p_rec.contract_category, hr_api.g_varchar2) <>
	     nvl(pay_ppd_shd.g_old_rec.contract_category
	        ,hr_api.g_varchar2
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'CONTRACT_CATEGORY'
	      ,p_base_table => pay_ppd_shd.g_tab_nam
	      );
   end if;

   if nvl(p_rec.per_or_asg_id, hr_api.g_number) <>
	     nvl(pay_ppd_shd.g_old_rec.per_or_asg_id
	        ,hr_api.g_number
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'PER_OR_ASG_ID'
	      ,p_base_table => pay_ppd_shd.g_tab_nam
	      );
   end if;
  -- Check to Income Reduction for CIVIL contract its non updateable
     If p_rec.contract_category in ('CIVIL','LUMP','F_LUMP') then
  	if nvl(p_rec.income_reduction, hr_api.g_varchar2) <>
	  	   nvl(pay_ppd_shd.g_old_rec.income_reduction
	   	  ,hr_api.g_varchar2
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'INCOME_REDUCTION'
	      ,p_base_table => pay_ppd_shd.g_tab_nam
	      );
   	end if;
     End if;

  -- Rate of Tax is a constant for Lump Sum Contracts with Contract type
  -- L01, L02, L03, L04, L09, L10, L11. Also we do not store the Rate of Tax for
  -- these Contract types in the Tax table. Hence the user should not try to
  -- update the Rate of Tax for these Contract types when calling the update api

   if p_rec.contract_category = 'LUMP' then
      open csr_contract_type(p_rec.per_or_asg_id,p_effective_date);
       fetch csr_contract_type into l_contract_type;
      close csr_contract_type;

      if l_contract_type in ('L01','L02','L03','L04','L09','L10','L11') then
         if nvl(p_rec.rate_of_tax, hr_api.g_varchar2) <>
	  	   nvl(pay_ppd_shd.g_old_rec.rate_of_tax
	   	  ,hr_api.g_varchar2
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'RATE_OF_TAX'
	      ,p_base_table => pay_ppd_shd.g_tab_nam
	      );
   	end if;
      end if;
   end if;
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
  (p_paye_details_id                  in number
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
      ,p_argument       => 'paye_details_id'
      ,p_argument_value => p_paye_details_id
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
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_ppd_shd.g_rec_type
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
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_ppd_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --Polish Localization Code has been added here

  --Validation check for Contract Category
  	pay_ppd_bus.chk_contract_category(p_paye_details_id =>p_rec.paye_details_id
								 ,p_effective_date=> p_effective_date
								 ,p_contract_category => p_rec.contract_category
								 ,p_validation_start_date => p_validation_start_date
								 ,p_validation_end_date => p_validation_end_date
								 ,p_object_version_number => p_rec.object_version_number);
  --
  --Validation check for Business Group Id
        pay_ppd_bus.chk_business_group_id(p_paye_details_id => p_rec.paye_details_id,
                                          p_effective_date => p_effective_date,
                                          p_business_group_id => p_rec.business_group_id,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number => p_rec.object_version_number);
  -- Validation check for per_or_asg_id
      pay_ppd_bus.chk_per_asg_id(p_effective_date  	=> p_effective_date
						,p_per_or_asg_id   	=> p_rec.per_or_asg_id
						,p_contract_category=> p_rec.contract_category
						,p_business_group_id=> p_rec.business_group_id
						,p_object_version_number => p_rec.object_version_number);
  --
  -- Validation check for rate_of_tax
           pay_ppd_bus.chk_rate_of_tax(p_paye_details_id	=> p_rec.paye_details_id
						 	  ,p_effective_date 	=> p_effective_date
							  ,p_rate_of_tax		=> p_rec.rate_of_tax
							  ,p_contract_category	=> p_rec.contract_category
							  ,p_validation_start_date => p_validation_start_date
							  ,p_validation_end_date => p_validation_end_date
							  ,p_object_version_number => p_rec.object_version_number
                                      ,p_per_or_asg_id       => p_rec.per_or_asg_id);
  -- Validation check for Tax Reduction

  If p_rec.contract_category in ('NORMAL','TERM_NORMAL') then
      pay_ppd_bus.chk_tax_reduction(p_paye_details_id 			=> p_rec.paye_details_id
  							,p_effective_date			=> p_effective_date
							,p_tax_reduction			=> p_rec.tax_reduction
							,p_validation_start_date	=> p_validation_start_date
							,p_validation_end_date		=> p_validation_end_date
							,p_object_version_number	=> p_rec.object_version_number);
  --
  -- Validation check for tax_calc_with_spouse_child
  	pay_ppd_bus.chk_tax_calc_with_spouse_child(p_paye_details_id	=> p_rec.paye_details_id
									 	  ,p_effective_date 	=> p_effective_date
										  ,p_tax_calc_with_spouse_child => p_rec.tax_calc_with_spouse_child
										  ,p_validation_start_date => p_validation_start_date
  										  ,p_validation_end_date => p_validation_end_date
										  ,p_object_version_number => p_rec.object_version_number);

  --

  -- Validation check for Income Reduction
    	pay_ppd_bus.chk_income_reduction(p_paye_details_id 			=> p_rec.paye_details_id
	  							,p_effective_date			=> p_effective_date
  								,p_income_reduction			=> p_rec.income_reduction
								,p_validation_start_date    => p_validation_start_date
								,p_validation_end_date 		=> p_validation_end_date
								,p_object_version_number    => p_rec.object_version_number);
  --
 End if;
    hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_ppd_shd.g_rec_type
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
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_ppd_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
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
  -- Validation check for rate_of_tax
           pay_ppd_bus.chk_rate_of_tax(p_paye_details_id	=> p_rec.paye_details_id
						 	  ,p_effective_date 	=> p_effective_date
							  ,p_rate_of_tax		=> p_rec.rate_of_tax
							  ,p_contract_category	=> p_rec.contract_category
							  ,p_validation_start_date => p_validation_start_date
							  ,p_validation_end_date => p_validation_end_date
							  ,p_object_version_number => p_rec.object_version_number
                                      ,p_per_or_asg_id      => p_rec.per_or_asg_id);
  -- Validation check for Tax Reduction
  If p_rec.contract_category in ('NORMAL','TERM_NORMAL') then
      pay_ppd_bus.chk_tax_reduction(p_paye_details_id 			=> p_rec.paye_details_id
  							,p_effective_date			=> p_effective_date
							,p_tax_reduction			=> p_rec.tax_reduction
							,p_validation_start_date	=> p_validation_start_date
							,p_validation_end_date		=> p_validation_end_date
							,p_object_version_number	=> p_rec.object_version_number);
  --
  -- Validation check for tax_calc_with_spouse_child
  	pay_ppd_bus.chk_tax_calc_with_spouse_child(p_paye_details_id	=> p_rec.paye_details_id
									 	  ,p_effective_date 	=> p_effective_date
										  ,p_tax_calc_with_spouse_child => p_rec.tax_calc_with_spouse_child
										  ,p_validation_start_date => p_validation_start_date
  										  ,p_validation_end_date => p_validation_end_date
										  ,p_object_version_number => p_rec.object_version_number);

  --

  -- Validation check for Income Reduction
    	pay_ppd_bus.chk_income_reduction(p_paye_details_id 			=> p_rec.paye_details_id
	  							,p_effective_date			=> p_effective_date
  								,p_income_reduction			=> p_rec.income_reduction
								,p_validation_start_date    => p_validation_start_date
								,p_validation_end_date 		=> p_validation_end_date
								,p_object_version_number    => p_rec.object_version_number);
  --
 End if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_ppd_shd.g_rec_type
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
    ,p_paye_details_id                  => p_rec.paye_details_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
--|-------------------------< chk_contract_category >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_contract_category
  (p_paye_details_id        in number
  ,p_effective_date        in date
  ,p_contract_category     in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_object_version_number in number
  ) IS

l_proc         varchar2(72);

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_contract_category';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_CATEGORY')
         ,p_argument_value => p_contract_category
          );

    --  If Contract Category is not null then
    --  Check if the Contract Category value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRACT_CATEGORY'
    --
      if p_contract_category is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRACT_CATEGORY'
            ,p_lookup_code           => p_contract_category
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375843_CONTRACT_PL_LOOKUP');
           -- This message will be 'The Contract Category does not exist in the system'
           hr_utility.raise_error;
         end if;
      end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_PAYE_DETAILS_F.CONTRACT_CATEGORY'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_contract_category;
--
-- ----------------------------------------------------------------------------
--|---------------------------< chk_per_asg_id >-------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_per_asg_id
  (p_effective_date        in date
  ,p_per_or_asg_id         in number
  ,p_contract_category     in varchar2
  ,p_business_group_id     in number
  ,p_object_version_number in number
  ) IS

l_proc         varchar2(72);
l_exists       varchar2(1);
l_civil_catg   hr_soft_coding_keyflex.segment3%TYPE;
l_term_catg    hr_soft_coding_keyflex.segment3%TYPE;

l_lump_catg    hr_soft_coding_keyflex.segment3%TYPE;
l_f_lump_catg  hr_soft_coding_keyflex.segment3%TYPE;

cursor csr_per_id is
  select null
    from per_all_people_f  papf
   where papf.person_id          =  p_per_or_asg_id      and
         papf.business_group_id  =  p_business_group_id  and
         p_effective_date between papf.effective_start_date and
                                  papf.effective_end_date and
         papf.person_type_id in (select person_type_id from per_person_types
                                 where business_group_id = p_business_group_id
                                 and system_person_type in ('EMP','EMP_APL'));

cursor csr_asg_id is
  select null
    from per_all_assignments_f paaf, hr_soft_coding_keyflex hrsoft
   where paaf.assignment_id      =  p_per_or_asg_id      and
         paaf.business_group_id  =  p_business_group_id  and
         p_effective_date between paaf.effective_start_date and
                                  paaf.effective_end_date and
         paaf.assignment_status_type_id in (select assignment_status_type_id from
                                                   per_assignment_status_types where
                                            per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN'))
	and paaf.soft_coding_keyflex_id = hrsoft.soft_coding_keyflex_id and
        hrsoft.segment3 in (l_civil_catg,l_lump_catg,l_f_lump_catg);


cursor csr_normal_term_id is
  select null
    from per_all_assignments_f paaf, hr_soft_coding_keyflex hrsoft
   where paaf.assignment_id      =  p_per_or_asg_id      and
         paaf.business_group_id  =  p_business_group_id  and
         p_effective_date between paaf.effective_start_date and
                                  paaf.effective_end_date and
         paaf.assignment_status_type_id in (select assignment_status_type_id from
                                                   per_assignment_status_types where
                                            per_system_status = 'TERM_ASSIGN')
        and paaf.soft_coding_keyflex_id = hrsoft.soft_coding_keyflex_id;
--	and  hrsoft.segment3 = l_term_catg;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc   := g_package ||'chk_per_asg_id';
 l_exists := NULL;

 l_civil_catg := 'CIVIL';
 l_term_catg  := 'TERM_NORMAL';

 l_lump_catg   := 'LUMP';
 l_f_lump_catg := 'F_LUMP';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','PER_ASG_ID')
         ,p_argument_value => p_per_or_asg_id
          );

if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_PL_PAYE_DETAILS_F.CONTRACT_CATEGORY'
     ,p_check_column2      => 'PAY_PL_PAYE_DETAILS_F.BUSINESS_GROUP_ID'
     ,p_associated_column1 => 'PAY_PL_PAYE_DETAILS_F.PER_OR_ASG_ID') then

-- Continue with valiadtion only if the columns
--  a) BUSINESS_GROUP_ID and
--  b) CONTRACT_CATEGORY are valid.

 if p_contract_category in ('CIVIL','LUMP','F_LUMP') then
  -- Since Civil/Lump Sum/Foreigners Lump Sum PAYE records are stored at the Assignment level,
  -- we open csr_asg_id
   open csr_asg_id;
     fetch csr_asg_id into l_exists;
       if csr_asg_id%NOTFOUND then
          -- Raise an error message that the record is not in the business group for the date range specified.
            hr_utility.set_message(801,'PAY_375840_INVALID_PL_ASG_ID');
            hr_utility.raise_error;
       end if;
      close csr_asg_id;

 elsif p_contract_category = 'NORMAL' then
   -- Since Normal PAYE records are stored at Person level, we open csr_per_id
    open csr_per_id;
      fetch csr_per_id into l_exists;
        if csr_per_id%NOTFOUND then
           -- Raise an error message that the records isnot in the business group for the date range specified
            hr_utility.set_message(801,'PAY_375839_INVALID_PL_PER_ID');
            hr_utility.raise_error;
       end if;
    close csr_per_id;

 elsif p_contract_category = 'TERM_NORMAL' then
    -- Since Normal Terminated PAYE records are stored at Assignment level, we open csr_normal_term_id
     open csr_normal_term_id;
       fetch csr_normal_term_id into l_exists;
         if csr_normal_term_id%NOTFOUND then
            -- Raise an error message that the record is not in the business group for the date range
            hr_utility.set_message(801,'PAY_375857_INVALID_TERM_ID');
            hr_utility.raise_error;
         end if;
      close csr_normal_term_id;

 end if;
end if;

   hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_PAYE_DETAILS_F.PER_OR_ASG_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_per_asg_id;

--
-- ----------------------------------------------------------------------------
--|-------------------------< chk_business_group_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_business_group_id
  (p_paye_details_id        in number
  ,p_effective_date        in date
  ,p_business_group_id     in number
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_object_version_number in number
  ) IS

l_proc         varchar2(72);

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_contract_category';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','BUSINESS_GROUP')
         ,p_argument_value => p_business_group_id
          );

      hr_api.validate_bus_grp_id
          (p_business_group_id   => p_business_group_id
          ,p_associated_column1  => pay_ppd_shd.g_tab_nam||'.BUSINESS_GROUP_ID');

     hr_multi_message.end_validation_set;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_PAYE_DETAILS_F.BUSINESS_GROUP_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_business_group_id;
--
-- ----------------------------------------------------------------------------
--|-------------------------< chk_rate_of_tax >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_rate_of_tax
  (p_paye_details_id             in number
  ,p_effective_date              in date
  ,p_rate_of_tax			     in varchar2
  ,p_contract_category 		     in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_per_or_asg_id               in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

l_contract_type hr_soft_coding_keyflex.segment4%TYPE;

cursor csr_contract_type(p_per_or_asg_id  number,
                           p_effective_date date) is
   select segment4
     from hr_soft_coding_keyflex soft, per_all_assignments_f paaf
    where soft.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
      and paaf.assignment_id = p_per_or_asg_id
      and p_effective_date between paaf.effective_start_date and paaf.effective_end_date;


Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_rate_of_tax';

   if p_contract_category = 'LUMP' then
     open csr_contract_type(p_per_or_asg_id,p_effective_date);
      fetch csr_contract_type into l_contract_type;
     close csr_contract_type;
   end if;

if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_PL_PAYE_DETAILS_F.CONTRACT_CATEGORY'
     ,p_check_column2      => 'PAY_PL_PAYE_DETAILS_F.BUSINESS_GROUP_ID'
     ,p_associated_column1 => 'PAY_PL_PAYE_DETAILS_F.RATE_OF_TAX') then

  --
  -- Continue with valiadtion only if the columns
  --  a) BUSINESS_GROUP_ID and
  --  b) CONTRACT_CATEGORY are valid.

  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

  if p_contract_category in ('NORMAL','TERM_NORMAL','CIVIL','F_LUMP') then
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','RATE_OF_TAX')
         ,p_argument_value => p_rate_of_tax
          );
  end if;


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Rate of Tax value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_ppd_shd.api_updating
    (p_paye_details_id        => p_paye_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_ppd_shd.g_old_rec.rate_of_tax,
                              hr_api.g_varchar2)
    <> nvl(p_rate_of_tax,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Rate of tax is not null then
    --  Check if the Rate of Tax value exists in hr_lookups
    --  where the lookup_type is 'PL_CIVIL_RATE_OF_TAX' or 'PL_NORMAL_RATE_OF_TAX' based on the contract category
    --
      if p_rate_of_tax is not null then
	if p_contract_category in ('NORMAL','TERM_NORMAL') then
            if hr_api.not_exists_in_dt_hr_lookups
  	         (p_effective_date        => p_effective_date
   	         ,p_validation_start_date => p_validation_start_date
	         ,p_validation_end_date   => p_validation_end_date
	         ,p_lookup_type           => 'PL_NORMAL_RATE_OF_TAX'
	         ,p_lookup_code           => p_rate_of_tax
 	          ) then
         	  --  Error: Invalid Value for Rate of Tax
         	  hr_utility.set_message(801,'PAY_375848_RATE_OF_TAX');
          	 -- This message will be 'Ensure that you enter a valid tax rate for this employee.'
	           hr_utility.raise_error;
 	     end if;
	elsif p_contract_category = 'CIVIL' then
	    if hr_api.not_exists_in_dt_hr_lookups
  	         (p_effective_date        => p_effective_date
   	         ,p_validation_start_date => p_validation_start_date
	         ,p_validation_end_date   => p_validation_end_date
	         ,p_lookup_type           => 'PL_CIVIL_RATE_OF_TAX'
	         ,p_lookup_code           => p_rate_of_tax
 	          ) then
         	  --  Error: Invalid Value for Rate of Tax
         	  hr_utility.set_message(801,'PAY_375848_RATE_OF_TAX');
          	 -- This message will be 'Ensure that you enter a valid tax rate for this employee.'
	           hr_utility.raise_error;
 	     end if;
          elsif p_contract_category = 'F_LUMP' then
             if p_rate_of_tax > 100 or p_rate_of_tax < 0 then
                hr_utility.set_message(801,'PAY_375891_F_LUMP_RATE_OF_TAX');
          	 -- This message will be 'Ensure that you enter a valid tax rate for this employee.'
	           hr_utility.raise_error;
 	     end if;
          elsif p_contract_category = 'LUMP' then

              -- For Contract types L01, L02, L03, L04, L09, L10, L11 we will not store the Rate of Tax
              -- in the table pay_pl_paye_details_f
              if l_contract_type not in ('L01','L02','L03','L04','L09','L10','L11') then
                 if p_rate_of_tax > 100 or p_rate_of_tax < 0 then
                   hr_utility.set_message(801,'PAY_375891_F_LUMP_RATE_OF_TAX');
          	 -- This message will be 'Ensure that you enter a valid tax rate for this employee.'
	           hr_utility.raise_error;
 	     end if;
            end if;
	End if;
      end if;
  end if;
End if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_PAYE_DETAILS_F.RATE_OF_TAX'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_rate_of_tax;
--
-- ----------------------------------------------------------------------------
--|-------------------------< chk_tax_reduction >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_tax_reduction
  (p_paye_details_id             in number
  ,p_effective_date              in date
  ,p_tax_reduction			     in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin


 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_tax_reduction';


  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','TAX_REDUCTION')
         ,p_argument_value => p_tax_reduction
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Tax Reduction value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_ppd_shd.api_updating
    (p_paye_details_id        => p_paye_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_ppd_shd.g_old_rec.tax_reduction,
                              hr_api.g_varchar2)
    <> nvl(p_tax_reduction,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Tax Reduction is not null then
    --  Check if the Tax Reduction value exists in hr_lookups
    --  where the lookup_type is 'PL_TAX_REDUCTION'
    --
      if p_tax_reduction is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_TAX_REDUCTION'
            ,p_lookup_code           => p_tax_reduction
            ) then
           --  Error: Invalid value for Tax Reduction
           hr_utility.set_message(801,'PAY_375849_TAX_REDUCTION');
           -- This message will be 'Ensure that you enter a valid tax reduction percentage for this employee.'
           hr_utility.raise_error;
         end if;
      end if;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);

 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_PAYE_DETAILS_F.TAX_REDUCTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_tax_reduction;
--
-- ----------------------------------------------------------------------------
--|-------------------------< chk_tax_calc_with_spouse_child >------------------|
-- ----------------------------------------------------------------------------
Procedure chk_tax_calc_with_spouse_child
  (p_paye_details_id             in number
  ,p_effective_date              in date
  ,p_tax_calc_with_spouse_child	 in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_tax_calc_with_spouse_child';

 --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','TAX_CALC_WITH_SPOUSE_CHILD')
         ,p_argument_value => p_tax_calc_with_spouse_child
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Tax Calculation with Spouse or Child value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_ppd_shd.api_updating
    (p_paye_details_id        => p_paye_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_ppd_shd.g_old_rec.tax_calc_with_spouse_child,
                              hr_api.g_varchar2)
    <> nvl(p_tax_calc_with_spouse_child,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Tax Reduction is not null then
    --  Check if the Tax Calculation with Spouse or Child value exists in hr_lookups
    --  where the lookup_type is 'YES_NO'
    --
      if p_tax_calc_with_spouse_child is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'YES_NO'
            ,p_lookup_code           => p_tax_calc_with_spouse_child
            ) then
           --  Error: Invalid value for Tax calculation with spouse or child
           hr_utility.set_message(801,'PAY_375850_TAX_SPOUSE_CHILD');
 -- Error Message is as follows
 -- 'Ensure that you specify Y or N to indicate whether or not the application should consider tax calculation with spouse or child.'
           hr_utility.raise_error;
         end if;
      end if;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_PAYE_DETAILS_F.TAX_CALC_WITH_SPOUSE_CHILD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_tax_calc_with_spouse_child;
--
-- ----------------------------------------------------------------------------
--|-------------------------< chk_income_reduction >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_income_reduction
  (p_paye_details_id             in number
  ,p_effective_date              in date
  ,p_income_reduction	 	     in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_income_reduction';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','INCOME_REDUCTION')
         ,p_argument_value => p_income_reduction
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Income Reduction value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_ppd_shd.api_updating
    (p_paye_details_id        => p_paye_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_ppd_shd.g_old_rec.income_reduction,
                              hr_api.g_varchar2)
    <> nvl(p_income_reduction,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Income Reduction is not null then
    --  Check if the Income Reduction value exists in hr_lookups
    --  where the lookup_type is 'PL_INCOME_REDUCTION'
    --
      if p_income_reduction is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_INCOME_REDUCTION'
            ,p_lookup_code           => p_income_reduction
            ) then
           --  Error: Invalid Income Reduction
           hr_utility.set_message(801,'PAY_375851_INCOME_REDUCTION');
           -- This message will be 'Ensure that you enter a valid income reduction percentage for this employee.'
           hr_utility.raise_error;
         end if;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_PAYE_DETAILS_F.INCOME_REDUCTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_income_reduction;
--
end pay_ppd_bus;

/
