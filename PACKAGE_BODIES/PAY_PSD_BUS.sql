--------------------------------------------------------
--  DDL for Package Body PAY_PSD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PSD_BUS" as
/* $Header: pypsdrhi.pkb 120.1 2005/12/08 05:08 ssekhar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_psd_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_sii_details_id              number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_sii_details_id                       in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_pl_sii_details_f psd
     where psd.sii_details_id = p_sii_details_id
       and pbg.business_group_id = psd.business_group_id;
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
    ,p_argument           => 'sii_details_id'
    ,p_argument_value     => p_sii_details_id
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
         => nvl(p_associated_column1,'SII_DETAILS_ID')
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
  (p_sii_details_id                       in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_pl_sii_details_f psd
     where psd.sii_details_id = p_sii_details_id
       and pbg.business_group_id = psd.business_group_id;
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
    ,p_argument           => 'sii_details_id'
    ,p_argument_value     => p_sii_details_id
    );
  --
  if ( nvl(pay_psd_bus.g_sii_details_id, hr_api.g_number)
       = p_sii_details_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_psd_bus.g_legislation_code;
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
    pay_psd_bus.g_sii_details_id              := p_sii_details_id;
    pay_psd_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--

-- ----------------------------------------------------------------------------
--|-------------------------< chk_contract_category >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Contract Category.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_contract_category
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_contract_category
  (p_sii_details_id        in number
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
           hr_utility.set_message(801,'PAY_375841_CONTRACT_PL_LOOKUP');
           -- This message will be 'The Contract Category does not exist in the system'
           hr_utility.raise_error;
         end if;
      end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.CONTRACT_CATEGORY'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_contract_category;

--
-- ----------------------------------------------------------------------------
--|-------------------------< chk_business_group_id >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Business Group Id.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_business_group_id
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_business_group_id
  (p_sii_details_id        in number
  ,p_effective_date        in date
  ,p_business_group_id     in number
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ,p_object_version_number in number
  ) IS

l_proc         varchar2(72);

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_business_group_id';

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
          ,p_associated_column1  => pay_psd_shd.g_tab_nam||'.BUSINESS_GROUP_ID');

     hr_multi_message.end_validation_set;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.BUSINESS_GROUP_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_business_group_id;
--
--
-- ----------------------------------------------------------------------------
--|---------------------------< chk_per_asg_id >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Person/Assignment Id.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_per_or_asg_id
--   p_business_group_id
--   p_contract_category
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
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
        and paaf.soft_coding_keyflex_id = hrsoft.soft_coding_keyflex_id and
        hrsoft.segment3 = l_term_catg;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc   := g_package ||'chk_per_asg_id';
 l_exists := NULL;

 l_civil_catg := 'CIVIL';
 l_term_catg  := 'NORMAL';

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
     (p_check_column1      => 'PAY_PL_SII_DETAILS_F.CONTRACT_CATEGORY'
     ,p_check_column2      => 'PAY_PL_SII_DETAILS_F.BUSINESS_GROUP_ID'
     ,p_associated_column1 => 'PAY_PL_SII_DETAILS_F.PER_OR_ASG_ID') then

-- Continue with valiadtion only if the columns
--  a) BUSINESS_GROUP_ID and
--  b) CONTRACT_CATEGORY are valid.

 if p_contract_category in ('CIVIL','LUMP','F_LUMP') then
  -- Since Civil SII records are stored at the Assignment level, we open csr_asg_id
   open csr_asg_id;
     fetch csr_asg_id into l_exists;
       if csr_asg_id%NOTFOUND then
          -- Raise an error message that the record is not in the business group for the date range specified.
            hr_utility.set_message(801,'PAY_375840_INVALID_PL_ASG_ID');
            hr_utility.raise_error;
       end if;
      close csr_asg_id;

 elsif p_contract_category = 'NORMAL' then
   -- Since Normal SII records are stored at Person level, we open csr_per_id
    open csr_per_id;
      fetch csr_per_id into l_exists;
        if csr_per_id%NOTFOUND then
           -- Raise an error message that the records isnot in the business group for the date range specified
            hr_utility.set_message(801,'PAY_375839_INVALID_PL_PER_ID');
            hr_utility.raise_error;
       end if;
    close csr_per_id;

 elsif p_contract_category = 'TERM_NORMAL' then
    -- Since Normal Terminated SII records are stored at Assignment level, we open csr_normal_term_id
     open csr_normal_term_id;
       fetch csr_normal_term_id into l_exists;
         if csr_normal_term_id%NOTFOUND then
            -- Raise an error message that the record is not in the business group for the date range
            hr_utility.set_message(801,'PAY_375840_INVALID_PL_ASG_ID');
            hr_utility.raise_error;
         end if;
      close csr_normal_term_id;

 end if;
end if;

   hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.PER_OR_ASG_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_per_asg_id;

--
---- ----------------------------------------------------------------------------
--|---------------------< chk_emp_social_security_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Employee Social Security Information values.
--
-- Prerequisites:
--
--
-- In Parameters:
-- p_sii_details_id
-- p_effective_date
-- p_emp_social_security_info
-- p_object_version_number
--
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_emp_social_security_info
  (p_sii_details_id           in number
  ,p_effective_date           in date
  ,p_emp_social_security_info in varchar2
  ,p_object_version_number    in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;
l_exists       varchar2(1);

l_user_table_name  pay_user_tables.user_table_name%TYPE;
l_legislation_code pay_user_columns.legislation_code%TYPE;

cursor csr_emp_social_security_info is
select null
  from pay_user_columns puc, pay_user_tables put
 where puc.user_table_id = put.user_table_id
   and put.user_table_name = l_user_table_name
   and put.legislation_code = l_legislation_code
   and puc.user_column_name = p_emp_social_security_info;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_emp_social_security_info';

-- Assigning values to local variables
 l_user_table_name  := 'PL_EMPLOYEE_SOCIAL_SECURITY_INFORMATION';
 l_legislation_code := 'PL';

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
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','EMP_SOCIAL_SECURITY_INFO')
         ,p_argument_value => p_emp_social_security_info
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Employee Social Security Information has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_psd_shd.g_old_rec.emp_social_security_info,
                              hr_api.g_varchar2)
    <> nvl(p_emp_social_security_info,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Employee Social Security Information is not null then
    --  Check if the Employee Social Security Information value exists in User Tables
    --  where the user table name is 'PL_EMP_SOCIAL_SECURITY_INFO'
    --
      if p_emp_social_security_info is not null then
         open csr_emp_social_security_info;
           fetch csr_emp_social_security_info into l_exists;
             if csr_emp_social_security_info%NOTFOUND then
                hr_utility.set_message(801,'PAY_375842_INVALID_SOCIAL_INFO');
                hr_utility.raise_error;
             end if;
          close csr_emp_social_security_info;
       end if;
 end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.EMP_SOCIAL_SECURITY_INFO'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_emp_social_security_info;
--
--
-- ----------------------------------------------------------------------------
--|---------------------< chk_old_age_contribution >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Old Age Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_old_age_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_old_age_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_old_age_contribution        in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_old_age_contribution';

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
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','OLD_AGE_CONTRIBUTION')
         ,p_argument_value => p_old_age_contribution
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Old Age Contribution value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_psd_shd.g_old_rec.old_age_contribution,
                              hr_api.g_varchar2)
    <> nvl(p_old_age_contribution,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Old Age Contribution is not null then
    --  Check if the Old Age Contribution value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_TYPE'
    --
      if p_old_age_contribution is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_TYPE'
            ,p_lookup_code           => p_old_age_contribution
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375843_INVALID_CONTRI_TYPE');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','OLD_AGE_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;
 -- Raise an error if 'Voluntary' is specified for a 'NORMAL' or 'TERM_NORMAL' category
         if (p_contract_category in ('NORMAL','TERM_NORMAL') and p_old_age_contribution = 'D') then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375871_INVALID_NORMAL_CONT');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','OLD_AGE_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.OLD_AGE_CONTRIBUTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_old_age_contribution;
--
--
-- ----------------------------------------------------------------------------
--|---------------------< chk_pension_contribution >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Pension Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_pension_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_pension_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_pension_contribution        in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_pension_contribution';

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
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','PENSION_CONTRIBUTION')
         ,p_argument_value => p_pension_contribution
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Pension Contribution value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_psd_shd.g_old_rec.pension_contribution,
                              hr_api.g_varchar2)
    <> nvl(p_pension_contribution,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Pension Contribution is not null then
    --  Check if the Pension Contribution value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_TYPE'
    --
      if p_pension_contribution is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_TYPE'
            ,p_lookup_code           => p_pension_contribution
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375843_INVALID_CONTRI_TYPE');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','PENSION_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;

 -- Raise an error if 'Voluntary' is specified for a 'NORMAL' or 'TERM_NORMAL' category
         if (p_contract_category in ('NORMAL','TERM_NORMAL') and p_pension_contribution = 'D') then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375871_INVALID_NORMAL_CONT');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','PENSION_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.PENSION_CONTRIBUTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_pension_contribution;
--
--
-- ----------------------------------------------------------------------------
--|---------------------< chk_sickness_contribution >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Sickness Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_sickness_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_sickness_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_sickness_contribution       in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_sickness_contribution';

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
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','SICKNESS_CONTRIBUTION')
         ,p_argument_value => p_sickness_contribution
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Sickness Contribution value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_psd_shd.g_old_rec.sickness_contribution,
                              hr_api.g_varchar2)
    <> nvl(p_sickness_contribution,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Sickness Contribution is not null then
    --  Check if the Sickness Contribution value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_TYPE'
    --
      if p_sickness_contribution is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_TYPE'
            ,p_lookup_code           => p_sickness_contribution
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375843_INVALID_CONTRI_TYPE');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','SICKNESS_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;

 -- Raise an error if 'Voluntary' is specified for a 'NORMAL' or 'TERM_NORMAL' category
         if (p_contract_category in ('NORMAL','TERM_NORMAL') and p_sickness_contribution = 'D') then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375871_INVALID_NORMAL_CONT');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','SICKNESS_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.SICKNESS_CONTRIBUTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_sickness_contribution;
--
--
-- ----------------------------------------------------------------------------
--|--------------------< chk_work_injury_contribution >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Work Injury Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_work_injury_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_work_injury_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_work_injury_contribution    in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_work_injury_contribution';

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
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','WORK_INJURY_CONTRIBUTION')
         ,p_argument_value => p_work_injury_contribution
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Work Injury Contribution value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_psd_shd.g_old_rec.work_injury_contribution,
                              hr_api.g_varchar2)
    <> nvl(p_work_injury_contribution,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Work Injury Contribution is not null then
    --  Check if the Work Injury Contribution value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_TYPE'
    --
      if p_work_injury_contribution is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_TYPE'
            ,p_lookup_code           => p_work_injury_contribution
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375843_INVALID_CONTRI_TYPE');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','WORK_INJURY_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;

 -- Raise an error if 'Voluntary' is specified for a 'NORMAL' or 'TERM_NORMAL' category
         if (p_contract_category in ('NORMAL','TERM_NORMAL') and p_work_injury_contribution = 'D') then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375871_INVALID_NORMAL_CONT');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','WORK_INJURY_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.WORK_INJURY_CONTRIBUTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_work_injury_contribution;
--
--
-- ----------------------------------------------------------------------------
--|----------------------< chk_labor_contribution >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Labor Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_labor_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_labor_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_labor_contribution          in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_labor_contribution';

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
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','LABOR_CONTRIBUTION')
         ,p_argument_value => p_labor_contribution
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Labor Contribution value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_psd_shd.g_old_rec.labor_contribution,
                              hr_api.g_varchar2)
    <> nvl(p_labor_contribution,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Labor Contribution is not null then
    --  Check if the Labor Contribution value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_TYPE'
    --
      if p_labor_contribution is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_TYPE'
            ,p_lookup_code           => p_labor_contribution
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375843_INVALID_CONTRI_TYPE');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','LABOR_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;
 -- Raise an error if 'Voluntary' is specified for a 'NORMAL' or 'TERM_NORMAL' category
         if (p_contract_category in ('NORMAL','TERM_NORMAL') and p_labor_contribution = 'D') then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375871_INVALID_NORMAL_CONT');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','LABOR_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.LABOR_CONTRIBUTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_labor_contribution;
--
--
-- ----------------------------------------------------------------------------
--|---------------------< chk_health_contribution >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Health Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_health_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_health_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_health_contribution         in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_health_contribution';

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
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','HEALTH_CONTRIBUTION')
         ,p_argument_value => p_health_contribution
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Health Contribution value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_psd_shd.g_old_rec.health_contribution,
                              hr_api.g_varchar2)
    <> nvl(p_health_contribution,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Health Contribution is not null then
    --  Check if the Health Contribution value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_TYPE'
    --
      if p_health_contribution is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_TYPE'
            ,p_lookup_code           => p_health_contribution
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375843_INVALID_CONTRI_TYPE');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','HEALTH_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;

 -- Raise an error if 'Voluntary' is specified for a 'NORMAL' or 'TERM_NORMAL' category
         if (p_contract_category in ('NORMAL','TERM_NORMAL') and p_health_contribution = 'D') then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375871_INVALID_NORMAL_CONT');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','HEALTH_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.HEALTH_CONTRIBUTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_health_contribution;
--


-- ----------------------------------------------------------------------------
--|------------------< chk_unemployment_contribution >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Unemployment Contribution values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_unemployment_contribution
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--   p_contract_category
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unemployment_contribution
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_unemployment_contribution   in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ,p_contract_category           in varchar2
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;

Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_unemployment_contribution';

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
         ,p_argument       => hr_general.decode_lookup('PL_FORM_LABELS','UNEMPLOYMENT_CONTRIBUTION')
         ,p_argument_value => p_unemployment_contribution
          );


 --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Unemployment Contribution value  has changed
  --  c) A record is being inserted
  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

 if ((l_api_updating and nvl(pay_psd_shd.g_old_rec.unemployment_contribution,
                              hr_api.g_varchar2)
    <> nvl(p_unemployment_contribution,hr_api.g_varchar2)) or
    (NOT l_api_updating)) then

    --
    --  If Unemployment Contribution is not null then
    --  Check if the Unemployment Contribution value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_TYPE'
    --
      if p_unemployment_contribution is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_TYPE'
            ,p_lookup_code           => p_unemployment_contribution
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375843_INVALID_CONTRI_TYPE');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','UNEMPLOYMENT_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;

 -- Raise an error if 'Voluntary' is specified for a 'NORMAL' or 'TERM_NORMAL' category
         if (p_contract_category in ('NORMAL','TERM_NORMAL') and p_unemployment_contribution = 'D') then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375871_INVALID_NORMAL_CONT');
           -- This message will be 'The Contribution type does not exist in the system'
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','UNEMPLOYMENT_CONTRIBUTION'));
           hr_utility.raise_error;
         end if;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.UNEMPLOYMENT_CONTRIBUTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_unemployment_contribution;
--
--
-- ----------------------------------------------------------------------------
--|--------------------< chk_old_age_cont_end_reason >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Old Age Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_old_age_contribution
--   p_old_age_cont_end_reason
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_old_age_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_old_age_contribution        in varchar2
  ,p_old_age_cont_end_reason     in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;



Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_old_age_cont_end_reason';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

-- Proceed with validation only if the Old Age Contribution Value is not Invalid
if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_PL_SII_DETAILS_F.OLD_AGE_CONTRIBUTION'
     ,p_associated_column1 => 'PAY_PL_SII_DETAILS_F.OLD_AGE_CONT_END_REASON') then


  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Old Age Contribution End Reason value has changed

  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

-- If the Contribution type has changed from Mandatory/Voluntary to No Contribution
-- then the Contribution End Reason is mandatory

   if p_old_age_contribution = 'N' and
      nvl(pay_psd_shd.g_old_rec.old_age_contribution,'N') <> 'N' then
           if p_old_age_cont_end_reason is null then
              hr_utility.set_message(801,'PAY_375844_CONT_END_REQD');
              hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','OLD_AGE_CONTRIBUTION'));
              hr_utility.raise_error;
           end if;
       end if;

 if (l_api_updating and nvl(pay_psd_shd.g_old_rec.old_age_cont_end_reason,
                              hr_api.g_varchar2)
    <> nvl(p_old_age_cont_end_reason,hr_api.g_varchar2)) then
    --
    --  If Old Age Contribution End Reason is not null then
    --  Check if the Old Age Contribution End Reason value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_END_REASON'
    --
      if p_old_age_cont_end_reason is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_END_REASON'
            ,p_lookup_code           => p_old_age_cont_end_reason
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375845_INVALID_END_REASON');
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','OLD_AGE_CONTRIBUTION'));
           -- This message will be 'The Old Age Contribution End Reason type
           -- does not exist in the system'
           hr_utility.raise_error;
         end if;

-- If the Old Age Contribution End Reason is not null then the value of Old Age
-- Contribution shud be 'No Contribution'.

       if p_old_age_contribution <> 'N' then
          -- Raise an error that Old Age Contribution should be 'No Contribution'
          -- when Old Age Contribution End Reason has been specified
          hr_utility.set_message(801,'PAY_375846_CONTRI_TYPE_REQD');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','OLD_AGE_CONTRIBUTION'));
          hr_utility.raise_error;
       end if;


-- If the value of the OLD_AGE_CONTRIBUTION has remained unchanged (and its
-- older and new values are 'No Contribution') and if the value of
-- OLD_AGE_CONT_END_REASON has
-- been changed from NULL to a not NULL value, then an error should be raised

      if p_old_age_contribution = 'N' and
         pay_psd_shd.g_old_rec.old_age_contribution = 'N' then
          hr_utility.set_message(801,'PAY_375847_INCORREC_END_REASON');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','OLD_AGE_CONTRIBUTION'));
          hr_utility.raise_error;
      end if;


      end if;
  end if;
end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.OLD_AGE_CONT_END_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_old_age_cont_end_reason;
--
--

-- ----------------------------------------------------------------------------
--|--------------------< chk_pension_cont_end_reason >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Pension Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_pension_contribution
--   p_pension_cont_end_reason
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_pension_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_pension_contribution        in varchar2
  ,p_pension_cont_end_reason     in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;



Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_pension_cont_end_reason';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

-- Proceed with validation only if the Old Age Contribution Value is not Invalid
if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_PL_SII_DETAILS_F.PENSION_CONTRIBUTION'
     ,p_associated_column1 => 'PAY_PL_SII_DETAILS_F.OLD_PENSION_END_REASON') then


  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Pension Contribution End Reason value has changed

  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

-- If the Contribution type has changed from Mandatory/Voluntary to No Contribution
-- then the Contribution End Reason is mandatory

   if p_pension_contribution = 'N' and
      nvl(pay_psd_shd.g_old_rec.pension_contribution,'N') <> 'N' then
           if p_pension_cont_end_reason is null then
              hr_utility.set_message(801,'PAY_375844_CONT_END_REQD');
              hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','PENSION_CONTRIBUTION'));
              hr_utility.raise_error;
           end if;
       end if;

 if (l_api_updating and nvl(pay_psd_shd.g_old_rec.pension_cont_end_reason,
                              hr_api.g_varchar2)
    <> nvl(p_pension_cont_end_reason,hr_api.g_varchar2)) then
    --
    --  If Pension Contribution End Reason is not null then
    --  Check if the Pension Contribution End Reason value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_END_REASON'
    --
      if p_pension_cont_end_reason is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_END_REASON'
            ,p_lookup_code           => p_pension_cont_end_reason
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375845_INVALID_END_REASON');
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','PENSION_CONTRIBUTION'));
           -- This message will be 'The Pension Contribution End Reason type
           -- does not exist in the system'
           hr_utility.raise_error;
         end if;

-- If the Pension Contribution End Reason is not null then the value of Pension
-- Contribution shud be 'No Contribution'.

       if p_pension_contribution <> 'N' then
          -- Raise an error that Pension Contribution should be 'No Contribution'
          -- when Pension Contribution End Reason has been specified
          hr_utility.set_message(801,'PAY_375846_CONTRI_TYPE_REQD');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','PENSION_CONTRIBUTION'));
          hr_utility.raise_error;
       end if;


-- If the value of the PENSION_CONTRIBUTION has remained unchanged (and its
-- older and new values are 'No Contribution') and if the value of
-- PENSION_CONT_END_REASON has
-- been changed from NULL to a not NULL value, then an error should be raised

      if p_pension_contribution = 'N' and
         pay_psd_shd.g_old_rec.pension_contribution = 'N' then
          hr_utility.set_message(801,'PAY_375847_INCORREC_END_REASON');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','PENSION_CONTRIBUTION'));
      end if;


      end if;
  end if;
end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.PENSION_CONT_END_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_pension_cont_end_reason;
--
--
-- ----------------------------------------------------------------------------
--|-------------------< chk_sickness_cont_end_reason >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Sickness Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_sickness_contribution
--   p_sickness_cont_end_reason
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_sickness_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_sickness_contribution       in varchar2
  ,p_sickness_cont_end_reason    in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;



Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_sickness_cont_end_reason';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

-- Proceed with validation only if the Sickness Contribution Value is not Invalid
if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_PL_SII_DETAILS_F.SICKNESS_CONTRIBUTION'
     ,p_associated_column1 => 'PAY_PL_SII_DETAILS_F.SICKNESS_CONT_END_REASON') then


  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Sickness Contribution End Reason value has changed

  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

-- If the Contribution type has changed from Mandatory/Voluntary to No Contribution
-- then the Contribution End Reason is mandatory

   if p_sickness_contribution = 'N' and
      nvl(pay_psd_shd.g_old_rec.sickness_contribution,'N') <> 'N' then
           if p_sickness_cont_end_reason is null then
              hr_utility.set_message(801,'PAY_375844_CONT_END_REQD');
              hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','SICKNESS_CONTRIBUTION'));
              hr_utility.raise_error;
           end if;
       end if;

 if (l_api_updating and nvl(pay_psd_shd.g_old_rec.sickness_cont_end_reason,
                              hr_api.g_varchar2)
    <> nvl(p_sickness_cont_end_reason,hr_api.g_varchar2)) then
    --
    --  If Sickness Contribution End Reason is not null then
    --  Check if the Sickness Contribution End Reason value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_END_REASON'
    --
      if p_sickness_cont_end_reason is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_END_REASON'
            ,p_lookup_code           => p_sickness_cont_end_reason
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375845_INVALID_END_REASON');
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','SICKNESS_CONTRIBUTION'));
           -- This message will be 'The Sickness Contribution End Reason type
           -- does not exist in the system'
           hr_utility.raise_error;
         end if;

-- If the Sickness Contribution End Reason is not null then the value of Sickness
-- Contribution shud be 'No Contribution'.

       if p_sickness_contribution <> 'N' then
          -- Raise an error that Sickness Contribution should be 'No Contribution'
          -- when Sickness Contribution End Reason has been specified
          hr_utility.set_message(801,'PAY_375846_CONTRI_TYPE_REQD');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','SICKNESS_CONTRIBUTION'));
          hr_utility.raise_error;
       end if;


-- If the value of the SICKNESS_CONTRIBUTION has remained unchanged (and its
-- older and new values are 'No Contribution') and if the value of
-- SICKNESS_CONT_END_REASON has
-- been changed from NULL to a not NULL value, then an error should be raised

      if p_sickness_contribution = 'N' and
         pay_psd_shd.g_old_rec.sickness_contribution = 'N' then
          hr_utility.set_message(801,'PAY_375847_INCORREC_END_REASON');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','SICKNESS_CONTRIBUTION'));
      end if;


      end if;
  end if;
end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.SICKNESS_CONT_END_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_sickness_cont_end_reason;
--
--
-- ----------------------------------------------------------------------------
--|--------------------< chk_work_injury_cont_end >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Work Injury Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_work_injury_contribution
--   p_work_injury_cont_end_reason
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_work_injury_cont_end
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_work_injury_contribution    in varchar2
  ,p_work_injury_cont_end_reason in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;



Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_work_injury_cont_end';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

-- Proceed with validation only if the Work Injury Contribution Value is not Invalid
if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_PL_SII_DETAILS_F.WORK_INJURY_CONTRIBUTION'
     ,p_associated_column1 => 'PAY_PL_SII_DETAILS_F.WORK_INJURY_CONT_END_REASON') then


  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Work Injury Contribution End Reason value has changed

  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

-- If the Contribution type has changed from Mandatory/Voluntary to No Contribution
-- then the Contribution End Reason is mandatory

   if p_work_injury_contribution = 'N' and
      nvl(pay_psd_shd.g_old_rec.work_injury_contribution,'N') <> 'N' then
           if p_work_injury_cont_end_reason is null then
              hr_utility.set_message(801,'PAY_375844_CONT_END_REQD');
              hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','WORK_INJURY_CONTRIBUTION'));
              hr_utility.raise_error;
           end if;
       end if;

 if (l_api_updating and nvl(pay_psd_shd.g_old_rec.work_injury_cont_end_reason,
                              hr_api.g_varchar2)
    <> nvl(p_work_injury_cont_end_reason,hr_api.g_varchar2)) then
    --
    --  If Work Injury Contribution End Reason is not null then
    --  Check if the Work Injury Contribution End Reason value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_END_REASON'
    --
      if p_work_injury_cont_end_reason is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_END_REASON'
            ,p_lookup_code           => p_work_injury_cont_end_reason
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375845_INVALID_END_REASON');
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','WORK_INJURY_CONTRIBUTION'));
           -- This message will be 'The Work Injury Contribution End Reason type
           -- does not exist in the system'
           hr_utility.raise_error;
         end if;

-- If the Work Injury Contribution End Reason is not null then the value of Work Injury
-- Contribution shud be 'No Contribution'.

       if p_work_injury_contribution <> 'N' then
          -- Raise an error that Work Injury Contribution should be 'No Contribution'
          -- when Work Injury Contribution End Reason has been specified
          hr_utility.set_message(801,'PAY_375846_CONTRI_TYPE_REQD');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','WORK_INJURY_CONTRIBUTION'));
          hr_utility.raise_error;
       end if;


-- If the value of the WORK_INJURY_CONTRIBUTION has remained unchanged (and its
-- older and new values are 'No Contribution') and if the value of
-- WORK_INJURY_CONT_END_REASON has
-- been changed from NULL to a not NULL value, then an error should be raised

      if p_work_injury_contribution = 'N' and
         pay_psd_shd.g_old_rec.work_injury_contribution = 'N' then
          hr_utility.set_message(801,'PAY_375847_INCORREC_END_REASON');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','WORK_INJURY_CONTRIBUTION'));
      end if;


      end if;
  end if;
end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.WORK_INJURY_CONT_END_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_work_injury_cont_end;
--
--
-- ----------------------------------------------------------------------------
--|------------------< chk_labor_fund_cont_end_reason >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Labor fund Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_labor_contribution
--   p_labor_fund_cont_end_reason
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_labor_fund_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_labor_contribution          in varchar2
  ,p_labor_fund_cont_end_reason     in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;



Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_labor_fund_cont_end_reason';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

-- Proceed with validation only if the Labor Contribution Value is not Invalid
if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_PL_SII_DETAILS_F.LABOR_CONTRIBUTION'
     ,p_associated_column1 => 'PAY_PL_SII_DETAILS_F.LABOR_FUND_CONT_END_REASON') then


  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Labor Contribution End Reason value has changed

  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

-- If the Contribution type has changed from Mandatory/Voluntary to No Contribution
-- then the Contribution End Reason is mandatory

   if p_labor_contribution = 'N' and
      nvl(pay_psd_shd.g_old_rec.labor_contribution,'N') <> 'N' then
           if p_labor_fund_cont_end_reason is null then
              hr_utility.set_message(801,'PAY_375844_CONT_END_REQD');
              hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','LABOR_CONTRIBUTION'));
              hr_utility.raise_error;
           end if;
       end if;

 if (l_api_updating and nvl(pay_psd_shd.g_old_rec.labor_fund_cont_end_reason,
                              hr_api.g_varchar2)
    <> nvl(p_labor_fund_cont_end_reason,hr_api.g_varchar2)) then
    --
    --  If Labor Fund Contribution End Reason is not null then
    --  Check if the Labor fund Contribution End Reason value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_END_REASON'
    --
      if p_labor_fund_cont_end_reason is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_END_REASON'
            ,p_lookup_code           => p_labor_fund_cont_end_reason
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375845_INVALID_END_REASON');
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','LABOR_CONTRIBUTION'));
           -- This message will be 'The Labor fund Contribution End Reason type
           -- does not exist in the system'
           hr_utility.raise_error;
         end if;

-- If the Labor fund Contribution End Reason is not null then the value of Labor fund
-- Contribution shud be 'No Contribution'.

       if p_labor_contribution <> 'N' then
          -- Raise an error that Labor Contribution should be 'No Contribution'
          -- when Labor Contribution End Reason has been specified
          hr_utility.set_message(801,'PAY_375846_CONTRI_TYPE_REQD');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','LABOR_CONTRIBUTION'));
          hr_utility.raise_error;
       end if;


-- If the value of the LABOR_FUND_CONTRIBUTION has remained unchanged (and its
-- older and new values are 'No Contribution') and if the value of
-- LABOR_FUND_CONT_END_REASON has
-- been changed from NULL to a not NULL value, then an error should be raised

      if p_labor_contribution = 'N' and
         pay_psd_shd.g_old_rec.labor_contribution = 'N' then
          hr_utility.set_message(801,'PAY_375847_INCORREC_END_REASON');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','LABOR_CONTRIBUTION'));
      end if;


      end if;
  end if;
end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.LABOR_FUND_CONT_END_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_labor_fund_cont_end_reason;
--
--
-- ----------------------------------------------------------------------------
--|--------------------< chk_health_cont_end_reason >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Health Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_health_contribution
--   p_health_cont_end_reason
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_health_cont_end_reason
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_health_contribution         in varchar2
  ,p_health_cont_end_reason      in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;



Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_health_cont_end_reason';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

-- Proceed with validation only if the Health Contribution Value is not Invalid
if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_PL_SII_DETAILS_F.HEALTH_CONTRIBUTION'
     ,p_associated_column1 => 'PAY_PL_SII_DETAILS_F.HEALTH_CONT_END_REASON') then


  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Health Contribution End Reason value has changed

  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

-- If the Contribution type has changed from Mandatory/Voluntary to No Contribution
-- then the Contribution End Reason is mandatory

   if p_health_contribution = 'N' and
      nvl(pay_psd_shd.g_old_rec.health_contribution,'N') <> 'N' then
           if p_health_cont_end_reason is null then
              hr_utility.set_message(801,'PAY_375844_CONT_END_REQD');
              hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','HEALTH_CONTRIBUTION'));
              hr_utility.raise_error;
           end if;
       end if;

 if (l_api_updating and nvl(pay_psd_shd.g_old_rec.health_cont_end_reason,
                              hr_api.g_varchar2)
    <> nvl(p_health_cont_end_reason,hr_api.g_varchar2)) then
    --
    --  If Health Contribution End Reason is not null then
    --  Check if the Health Contribution End Reason value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_END_REASON'
    --
      if p_health_cont_end_reason is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_END_REASON'
            ,p_lookup_code           => p_health_cont_end_reason
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375845_INVALID_END_REASON');
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','HEALTH_CONTRIBUTION'));
           -- This message will be 'The Health Contribution End Reason type
           -- does not exist in the system'
           hr_utility.raise_error;
         end if;

-- If the Health Contribution End Reason is not null then the value of Health
-- Contribution shud be 'No Contribution'.

       if p_health_contribution <> 'N' then
          -- Raise an error that Health Contribution should be 'No Contribution'
          -- when Health Contribution End Reason has been specified
          hr_utility.set_message(801,'PAY_375846_CONTRI_TYPE_REQD');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','HEALTH_CONTRIBUTION'));
          hr_utility.raise_error;
       end if;


-- If the value of the HEALTH_CONTRIBUTION has remained unchanged (and its
-- older and new values are 'No Contribution') and if the value of
-- HEALTH_CONT_END_REASON has
-- been changed from NULL to a not NULL value, then an error should be raised

      if p_health_contribution = 'N' and
         pay_psd_shd.g_old_rec.health_contribution = 'N' then
          hr_utility.set_message(801,'PAY_375847_INCORREC_END_REASON');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','HEALTH_CONTRIBUTION'));
      end if;


      end if;
  end if;
end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.HEALTH_CONT_END_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_health_cont_end_reason;
--
--
-- ----------------------------------------------------------------------------
--|----------------------< chk_unemployment_cont_end >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the Unemployment Contribution End Reason values.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_sii_details_id
--   p_effective_date
--   p_unemployment_contribution
--   p_unemployment_cont_end_reason
--   p_validation_start_date
--   p_validation_end_date
--   p_object_version_number
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unemployment_cont_end
  (p_sii_details_id              in number
  ,p_effective_date              in date
  ,p_unemployment_contribution   in varchar2
  ,p_unemployment_cont_end_reason in varchar2
  ,p_validation_start_date       in date
  ,p_validation_end_date         in date
  ,p_object_version_number       in number
  ) IS

l_proc         varchar2(72);
l_api_updating boolean;



Begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
 l_proc := g_package ||'chk_unemployment_cont_end';

  --
  -- Check mandatory parameters have been set
  --
      hr_api.mandatory_arg_error
         (p_api_name       => l_proc
         ,p_argument       => 'effective date'
         ,p_argument_value => p_effective_date
          );

-- Proceed with validation only if the Old Age Contribution Value is not Invalid
if hr_multi_message.no_exclusive_error
     (p_check_column1      => 'PAY_PL_SII_DETAILS_F.UNEMPLOYMENT_CONTRIBUTION'
     ,p_associated_column1 => 'PAY_PL_SII_DETAILS_F.UNEMPLOYMENT_CONT_END_REASON') then


  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) Unemployment Contribution End Reason value has changed

  --
  l_api_updating := pay_psd_shd.api_updating
    (p_sii_details_id        => p_sii_details_id
    ,p_effective_date        => p_effective_date
    ,p_object_version_number => p_object_version_number);

-- If the Contribution type has changed from Mandatory/Voluntary to No Contribution
-- then the Contribution End Reason is mandatory

   if p_unemployment_contribution = 'N' and
      nvl(pay_psd_shd.g_old_rec.unemployment_contribution,'N') <> 'N' then
           if p_unemployment_cont_end_reason is null then
              hr_utility.set_message(801,'PAY_375844_CONT_END_REQD');
              hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','UNEMPLOYMENT_CONTRIBUTION'));
              hr_utility.raise_error;
           end if;
       end if;

 if (l_api_updating and nvl(pay_psd_shd.g_old_rec.unemployment_cont_end_reason,
                              hr_api.g_varchar2)
    <> nvl(p_unemployment_cont_end_reason,hr_api.g_varchar2)) then
    --
    --  If Unemployment Contribution End Reason is not null then
    --  Check if the Unemployment Contribution End Reason value exists in hr_lookups
    --  where the lookup_type is 'PL_CONTRIBUTION_END_REASON'
    --
      if p_unemployment_cont_end_reason is not null then
         if hr_api.not_exists_in_dt_hr_lookups
            (p_effective_date        => p_effective_date
            ,p_validation_start_date => p_validation_start_date
            ,p_validation_end_date   => p_validation_end_date
            ,p_lookup_type           => 'PL_CONTRIBUTION_END_REASON'
            ,p_lookup_code           => p_unemployment_cont_end_reason
            ) then
           --  Error: Invalid Contract Category
           hr_utility.set_message(801,'PAY_375845_INVALID_END_REASON');
           hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','UNEMPLOYMENT_CONTRIBUTION'));
           -- This message will be 'The Unemployment Contribution End Reason type
           -- does not exist in the system'
           hr_utility.raise_error;
         end if;

-- If the Unemployment Contribution End Reason is not null then the value of Unemployment
-- Contribution shud be 'No Contribution'.

       if p_unemployment_contribution <> 'N' then
          -- Raise an error that Unemployment Contribution should be 'No Contribution'
          -- when Unemployment Contribution End Reason has been specified
          hr_utility.set_message(801,'PAY_375846_CONTRI_TYPE_REQD');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','UNEMPLOYMENT_CONTRIBUTION'));
          hr_utility.raise_error;
       end if;


-- If the value of the UNEMPLOYMENT_CONTRIBUTION has remained unchanged (and its
-- older and new values are 'No Contribution') and if the value of
-- UNEMPLOYMENT_CONT_END_REASON has
-- been changed from NULL to a not NULL value, then an error should be raised

      if p_unemployment_contribution = 'N' and
         pay_psd_shd.g_old_rec.unemployment_contribution = 'N' then
          hr_utility.set_message(801,'PAY_375847_INCORREC_END_REASON');
          hr_utility.set_message_token('TYPE',hr_general.decode_lookup('PL_FORM_LABELS','UNEMPLOYMENT_CONTRIBUTION'));
      end if;


      end if;
  end if;
end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
 exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PAY_PL_SII_DETAILS_F.UNEMPLOYMENT_CONT_END_REASON'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);

End chk_unemployment_cont_end;
--
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
  ,p_rec             in pay_psd_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_psd_shd.api_updating
      (p_sii_details_id                   => p_rec.sii_details_id
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
	     nvl(pay_psd_shd.g_old_rec.business_group_id
	        ,hr_api.g_number
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'BUSINESS_GROUP_ID'
	      ,p_base_table => pay_psd_shd.g_tab_nam
	      );
   end if;

   if nvl(p_rec.contract_category, hr_api.g_varchar2) <>
	     nvl(pay_psd_shd.g_old_rec.contract_category
	        ,hr_api.g_varchar2
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'CONTRACT_CATEGORY'
	      ,p_base_table => pay_psd_shd.g_tab_nam
	      );
   end if;

   if nvl(p_rec.per_or_asg_id, hr_api.g_number) <>
	     nvl(pay_psd_shd.g_old_rec.per_or_asg_id
	        ,hr_api.g_number
	        ) then
	    hr_api.argument_changed_error
	      (p_api_name   => l_proc
	      ,p_argument   => 'PER_OR_ASG_ID'
	      ,p_base_table => pay_psd_shd.g_tab_nam
	      );
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
  (p_sii_details_id                   in number
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
      ,p_argument       => 'sii_details_id'
      ,p_argument_value => p_sii_details_id
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
  (p_rec                   in pay_psd_shd.g_rec_type
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
    ,p_associated_column1 => pay_psd_shd.g_tab_nam
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

    -- Validate the Contract Category
        pay_psd_bus.chk_contract_category(p_sii_details_id => p_rec.sii_details_id,
                                          p_effective_date => p_effective_date,
                                          p_contract_category => p_rec.contract_category,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number => p_rec.object_version_number);



    -- Validate the Business Group Id
        pay_psd_bus.chk_business_group_id(p_sii_details_id => p_rec.sii_details_id,
                                          p_effective_date => p_effective_date,
                                          p_business_group_id => p_rec.business_group_id,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number => p_rec.object_version_number);



    -- Validate the Person/Assignment Id
        pay_psd_bus.chk_per_asg_id(p_effective_date => p_effective_date,
                                   p_per_or_asg_id  => p_rec.per_or_asg_id,
                                   p_contract_category => p_rec.contract_category,
                                   p_business_group_id => p_rec.business_group_id,
                                   p_object_version_number => p_rec.object_version_number);


 -- Validate the Old Age Contribution Values
     pay_psd_bus.chk_old_age_contribution(p_sii_details_id => p_rec.sii_details_id,
                                          p_effective_date => p_effective_date,
                                          p_old_age_contribution => p_rec.old_age_contribution,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number => p_rec.object_version_number,
                                          p_contract_category => p_rec.contract_category);



 -- Validate the Pension Contribution Values
     pay_psd_bus.chk_pension_contribution(p_sii_details_id => p_rec.sii_details_id,
                                          p_effective_date => p_effective_date,
                                          p_pension_contribution => p_rec.pension_contribution,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number => p_rec.object_version_number,
								  p_contract_category => p_rec.contract_category);


 -- Validate the Sickness Contribution Values
     pay_psd_bus.chk_sickness_contribution(p_sii_details_id => p_rec.sii_details_id,
                                           p_effective_date => p_effective_date,
                                           p_sickness_contribution => p_rec.sickness_contribution,
                                           p_validation_start_date => p_validation_start_date,
                                           p_validation_end_date  => p_validation_end_date,
                                           p_object_version_number => p_rec.object_version_number,
								   p_contract_category => p_rec.contract_category);



 -- Validate the Work Injury Contribution Values
     pay_psd_bus.chk_work_injury_contribution(p_sii_details_id => p_rec.sii_details_id,
                                              p_effective_date => p_effective_date,
                                              p_work_injury_contribution => p_rec.work_injury_contribution,
                                              p_validation_start_date => p_validation_start_date,
                                              p_validation_end_date  => p_validation_end_date,
                                              p_object_version_number => p_rec.object_version_number,
									  p_contract_category => p_rec.contract_category);



 -- Validate the Labor Contribution Values
     pay_psd_bus.chk_labor_contribution(p_sii_details_id => p_rec.sii_details_id,
                                        p_effective_date => p_effective_date,
                                        p_labor_contribution => p_rec.labor_contribution,
                                        p_validation_start_date => p_validation_start_date,
                                        p_validation_end_date  => p_validation_end_date,
                                        p_object_version_number => p_rec.object_version_number,
								p_contract_category => p_rec.contract_category);



 -- Validate the Health Contribution Values
     pay_psd_bus.chk_health_contribution(p_sii_details_id => p_rec.sii_details_id,
                                         p_effective_date => p_effective_date,
                                         p_health_contribution => p_rec.health_contribution,
                                         p_validation_start_date => p_validation_start_date,
                                         p_validation_end_date  => p_validation_end_date,
                                         p_object_version_number => p_rec.object_version_number,
								 p_contract_category => p_rec.contract_category);


 -- Validate the Unemployment Contribution Values
     pay_psd_bus.chk_unemployment_contribution(p_sii_details_id => p_rec.sii_details_id,
                                               p_effective_date => p_effective_date,
                                               p_unemployment_contribution =>
                                                           p_rec.unemployment_contribution,
                                               p_validation_start_date => p_validation_start_date,
                                               p_validation_end_date  => p_validation_end_date,
                                               p_object_version_number => p_rec.object_version_number,
									   p_contract_category => p_rec.contract_category);


 -- Validate the Old Age Contribution End Reason Values
    pay_psd_bus.chk_old_age_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                            p_effective_date => p_effective_date,
                                            p_old_age_contribution => p_rec.old_age_contribution,
                                            p_old_age_cont_end_reason => p_rec.old_age_cont_end_reason,
                                            p_validation_start_date => p_validation_start_date,
                                            p_validation_end_date  => p_validation_end_date,
                                            p_object_version_number=> p_rec.object_version_number);


 -- Validate the Pension Contribution End Reason Values
    pay_psd_bus.chk_pension_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                            p_effective_date => p_effective_date,
                                            p_pension_contribution => p_rec.pension_contribution,
                                            p_pension_cont_end_reason => p_rec.pension_cont_end_reason,
                                            p_validation_start_date => p_validation_start_date,
                                            p_validation_end_date  => p_validation_end_date,
                                            p_object_version_number=> p_rec.object_version_number);

 -- Validate the Sickness Contribution End Reason Values
    pay_psd_bus.chk_sickness_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                             p_effective_date => p_effective_date,
                                             p_sickness_contribution => p_rec.sickness_contribution,
                                             p_sickness_cont_end_reason => p_rec.sickness_cont_end_reason,
                                             p_validation_start_date => p_validation_start_date,
                                             p_validation_end_date  => p_validation_end_date,
                                             p_object_version_number=> p_rec.object_version_number);


 -- Validate the Work Injury Contribution End Reason Values
    pay_psd_bus.chk_work_injury_cont_end(p_sii_details_id => p_rec.sii_details_id,
                                         p_effective_date => p_effective_date,
                                         p_work_injury_contribution =>
                                                         p_rec.work_injury_contribution,
                                         p_work_injury_cont_end_reason =>
                                                           p_rec.work_injury_cont_end_reason,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number=> p_rec.object_version_number);

 -- Validate the Labor fund Contribution End Reason Values
    pay_psd_bus.chk_labor_fund_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                               p_effective_date => p_effective_date,
                                               p_labor_contribution => p_rec.labor_contribution,
                                               p_labor_fund_cont_end_reason =>
                                                       p_rec.labor_fund_cont_end_reason,
                                               p_validation_start_date => p_validation_start_date,
                                               p_validation_end_date  => p_validation_end_date,
                                               p_object_version_number=> p_rec.object_version_number);


 -- Validate the Health Contribution End Reason Values
    pay_psd_bus.chk_health_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                           p_effective_date => p_effective_date,
                                           p_health_contribution => p_rec.health_contribution,
                                           p_health_cont_end_reason => p_rec.health_cont_end_reason,
                                           p_validation_start_date => p_validation_start_date,
                                           p_validation_end_date  => p_validation_end_date,
                                           p_object_version_number=> p_rec.object_version_number);


 -- Validate the Unemployment Contribution End Reason Values
    pay_psd_bus.chk_unemployment_cont_end(p_sii_details_id => p_rec.sii_details_id,
                                          p_effective_date => p_effective_date,
                                          p_unemployment_contribution =>
                                                           p_rec.unemployment_contribution,
                                          p_unemployment_cont_end_reason =>
                                                           p_rec.unemployment_cont_end_reason,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number=> p_rec.object_version_number);





  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_psd_shd.g_rec_type
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
    ,p_associated_column1 => pay_psd_shd.g_tab_nam
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

 --

      -- Validate the Employee Social Security Information Values
 pay_psd_bus.chk_emp_social_security_info(p_sii_details_id => p_rec.sii_details_id,
                                          p_effective_date => p_effective_date,
                                          p_emp_social_security_info => p_rec.emp_social_security_info,
                                          p_object_version_number => p_rec.object_version_number);


 -- Validate the Old Age Contribution Values
     pay_psd_bus.chk_old_age_contribution(p_sii_details_id => p_rec.sii_details_id,
                                          p_effective_date => p_effective_date,
                                          p_old_age_contribution => p_rec.old_age_contribution,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number => p_rec.object_version_number,
								  p_contract_category => p_rec.contract_category);



 -- Validate the Pension Contribution Values
     pay_psd_bus.chk_pension_contribution(p_sii_details_id => p_rec.sii_details_id,
                                          p_effective_date => p_effective_date,
                                          p_pension_contribution => p_rec.pension_contribution,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number => p_rec.object_version_number,
								  p_contract_category => p_rec.contract_category);


 -- Validate the Sickness Contribution Values
     pay_psd_bus.chk_sickness_contribution(p_sii_details_id => p_rec.sii_details_id,
                                           p_effective_date => p_effective_date,
                                           p_sickness_contribution => p_rec.sickness_contribution,
                                           p_validation_start_date => p_validation_start_date,
                                           p_validation_end_date  => p_validation_end_date,
                                           p_object_version_number => p_rec.object_version_number,
								   p_contract_category => p_rec.contract_category);



 -- Validate the Work Injury Contribution Values
     pay_psd_bus.chk_work_injury_contribution(p_sii_details_id => p_rec.sii_details_id,
                                              p_effective_date => p_effective_date,
                                              p_work_injury_contribution => p_rec.work_injury_contribution,
                                              p_validation_start_date => p_validation_start_date,
                                              p_validation_end_date  => p_validation_end_date,
                                              p_object_version_number => p_rec.object_version_number,
									  p_contract_category => p_rec.contract_category);



 -- Validate the Labor Contribution Values
     pay_psd_bus.chk_labor_contribution(p_sii_details_id => p_rec.sii_details_id,
                                        p_effective_date => p_effective_date,
                                        p_labor_contribution => p_rec.labor_contribution,
                                        p_validation_start_date => p_validation_start_date,
                                        p_validation_end_date  => p_validation_end_date,
                                        p_object_version_number => p_rec.object_version_number,
								p_contract_category => p_rec.contract_category);



 -- Validate the Health Contribution Values
     pay_psd_bus.chk_health_contribution(p_sii_details_id => p_rec.sii_details_id,
                                         p_effective_date => p_effective_date,
                                         p_health_contribution => p_rec.health_contribution,
                                         p_validation_start_date => p_validation_start_date,
                                         p_validation_end_date  => p_validation_end_date,
                                         p_object_version_number => p_rec.object_version_number,
								 p_contract_category => p_rec.contract_category);


 -- Validate the Unemployment Contribution Values
     pay_psd_bus.chk_unemployment_contribution(p_sii_details_id => p_rec.sii_details_id,
                                               p_effective_date => p_effective_date,
                                               p_unemployment_contribution =>
                                                           p_rec.unemployment_contribution,
                                               p_validation_start_date => p_validation_start_date,
                                               p_validation_end_date  => p_validation_end_date,
                                               p_object_version_number => p_rec.object_version_number,
									   p_contract_category => p_rec.contract_category);

 -- Validate the Old Age Contribution End Reason Values
    pay_psd_bus.chk_old_age_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                            p_effective_date => p_effective_date,
                                            p_old_age_contribution => p_rec.old_age_contribution,
                                            p_old_age_cont_end_reason => p_rec.old_age_cont_end_reason,
                                            p_validation_start_date => p_validation_start_date,
                                            p_validation_end_date  => p_validation_end_date,
                                            p_object_version_number=> p_rec.object_version_number);


 -- Validate the Pension Contribution End Reason Values
    pay_psd_bus.chk_pension_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                            p_effective_date => p_effective_date,
                                            p_pension_contribution => p_rec.pension_contribution,
                                            p_pension_cont_end_reason => p_rec.pension_cont_end_reason,
                                            p_validation_start_date => p_validation_start_date,
                                            p_validation_end_date  => p_validation_end_date,
                                            p_object_version_number=> p_rec.object_version_number);

 -- Validate the Sickness Contribution End Reason Values
    pay_psd_bus.chk_sickness_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                             p_effective_date => p_effective_date,
                                             p_sickness_contribution => p_rec.sickness_contribution,
                                             p_sickness_cont_end_reason => p_rec.sickness_cont_end_reason,
                                             p_validation_start_date => p_validation_start_date,
                                             p_validation_end_date  => p_validation_end_date,
                                             p_object_version_number=> p_rec.object_version_number);


 -- Validate the Work Injury Contribution End Reason Values
    pay_psd_bus.chk_work_injury_cont_end(p_sii_details_id => p_rec.sii_details_id,
                                         p_effective_date => p_effective_date,
                                         p_work_injury_contribution =>
                                                         p_rec.work_injury_contribution,
                                         p_work_injury_cont_end_reason =>
                                                           p_rec.work_injury_cont_end_reason,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number=> p_rec.object_version_number);

 -- Validate the Labor fund Contribution End Reason Values
    pay_psd_bus.chk_labor_fund_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                               p_effective_date => p_effective_date,
                                               p_labor_contribution => p_rec.labor_contribution,
                                               p_labor_fund_cont_end_reason =>
                                                       p_rec.labor_fund_cont_end_reason,
                                               p_validation_start_date => p_validation_start_date,
                                               p_validation_end_date  => p_validation_end_date,
                                               p_object_version_number=> p_rec.object_version_number);


 -- Validate the Health Contribution End Reason Values
    pay_psd_bus.chk_health_cont_end_reason(p_sii_details_id => p_rec.sii_details_id,
                                           p_effective_date => p_effective_date,
                                           p_health_contribution => p_rec.health_contribution,
                                           p_health_cont_end_reason => p_rec.health_cont_end_reason,
                                           p_validation_start_date => p_validation_start_date,
                                           p_validation_end_date  => p_validation_end_date,
                                           p_object_version_number=> p_rec.object_version_number);


 -- Validate the Unemployment Contribution End Reason Values
    pay_psd_bus.chk_unemployment_cont_end(p_sii_details_id => p_rec.sii_details_id,
                                          p_effective_date => p_effective_date,
                                          p_unemployment_contribution =>
                                                           p_rec.unemployment_contribution,
                                          p_unemployment_cont_end_reason =>
                                                           p_rec.unemployment_cont_end_reason,
                                          p_validation_start_date => p_validation_start_date,
                                          p_validation_end_date  => p_validation_end_date,
                                          p_object_version_number=> p_rec.object_version_number);


  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_psd_shd.g_rec_type
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
    ,p_sii_details_id                   => p_rec.sii_details_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
--|-----------------------< get_contribution_values >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure derives the various Contribution values when the 'Employee
-- Social Security Information' value is passed in.
--
-- Prerequisites:
--
--
-- In Parameters:
--   p_emp_social_security_info
--   p_effective_date
--
-- In/Out Parameters
--   p_old_age_contribution
--   p_pension_contribution
--   p_sickness_contribution
--   p_work_injury_contribution
--   p_labor_contribution
--   p_health_contribution
--   p_unemployment_contribution
--
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised if the validation fails.
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure get_contribution_values
  (p_effective_date in date
  ,p_emp_social_security_info in varchar2
  ,p_old_age_contribution      in out nocopy varchar2
  ,p_pension_contribution      in out nocopy varchar2
  ,p_sickness_contribution     in out nocopy varchar2
  ,p_work_injury_contribution  in out nocopy varchar2
  ,p_labor_contribution        in out nocopy varchar2
  ,p_health_contribution       in out nocopy varchar2
  ,p_unemployment_contribution in out nocopy varchar2) IS

begin





 if p_old_age_contribution is null then
        select pucif.value
          into p_old_age_contribution
          from
            pay_user_column_instances_f  pucif,
            pay_user_columns             puc,
            pay_user_rows_f              purf,
            pay_user_tables              put
      where put.user_table_name   ='PL_EMPLOYEE_SOCIAL_SECURITY_INFORMATION'
        and put.legislation_code = 'PL'
        and purf.legislation_code = 'PL'
        and purf.user_table_id = put.user_table_id
        and p_effective_date between purf.effective_start_date and purf.effective_end_date
        and purf.row_low_range_or_name = 'Old Age'
        and puc.user_column_name  = p_emp_social_security_info
        and puc.user_table_id = put.user_table_id
        and pucif.user_row_id = purf.user_row_id
        and pucif.user_column_id = puc.user_column_id
        and p_effective_date between pucif.effective_start_date and pucif.effective_end_date;
  end if;



 if p_pension_contribution is null then
       select pucif.value
         into p_pension_contribution
         from
            pay_user_column_instances_f  pucif,
            pay_user_columns             puc,
            pay_user_rows_f              purf,
            pay_user_tables              put
      where put.user_table_name   ='PL_EMPLOYEE_SOCIAL_SECURITY_INFORMATION'
        and put.legislation_code = 'PL'
        and purf.legislation_code = 'PL'
        and purf.user_table_id = put.user_table_id
        and p_effective_date between purf.effective_start_date and purf.effective_end_date
        and purf.row_low_range_or_name = 'Pension'
        and puc.user_column_name  = p_emp_social_security_info
        and puc.user_table_id = put.user_table_id
        and pucif.user_row_id = purf.user_row_id
        and pucif.user_column_id = puc.user_column_id
        and p_effective_date between pucif.effective_start_date and pucif.effective_end_date;
  end if;


  if p_sickness_contribution is null then
          select pucif.value
            into p_sickness_contribution
            from
               pay_user_column_instances_f  pucif,
               pay_user_columns             puc,
               pay_user_rows_f              purf,
               pay_user_tables              put
         where put.user_table_name   ='PL_EMPLOYEE_SOCIAL_SECURITY_INFORMATION'
           and put.legislation_code = 'PL'
           and purf.legislation_code = 'PL'
           and purf.user_table_id = put.user_table_id
           and p_effective_date between purf.effective_start_date and purf.effective_end_date
           and purf.row_low_range_or_name = 'Sickness'
           and puc.user_column_name  = p_emp_social_security_info
           and puc.user_table_id = put.user_table_id
           and pucif.user_row_id = purf.user_row_id
           and pucif.user_column_id = puc.user_column_id
           and p_effective_date between pucif.effective_start_date and pucif.effective_end_date;
   end if;

   if p_work_injury_contribution is null then
          select pucif.value
            into p_work_injury_contribution
            from
               pay_user_column_instances_f  pucif,
               pay_user_columns             puc,
               pay_user_rows_f              purf,
               pay_user_tables              put
         where put.user_table_name   ='PL_EMPLOYEE_SOCIAL_SECURITY_INFORMATION'
           and put.legislation_code = 'PL'
           and purf.legislation_code = 'PL'
           and purf.user_table_id = put.user_table_id
           and p_effective_date between purf.effective_start_date and purf.effective_end_date
           and purf.row_low_range_or_name = 'Work Injury'
           and puc.user_column_name  = p_emp_social_security_info
           and puc.user_table_id = put.user_table_id
           and pucif.user_row_id = purf.user_row_id
           and pucif.user_column_id = puc.user_column_id
           and p_effective_date between pucif.effective_start_date and pucif.effective_end_date;
    end if;

   if p_labor_contribution is null then
          select pucif.value
            into p_labor_contribution
            from
               pay_user_column_instances_f  pucif,
               pay_user_columns             puc,
               pay_user_rows_f              purf,
               pay_user_tables              put
         where put.user_table_name   ='PL_EMPLOYEE_SOCIAL_SECURITY_INFORMATION'
           and put.legislation_code = 'PL'
           and purf.legislation_code = 'PL'
           and purf.user_table_id = put.user_table_id
           and p_effective_date between purf.effective_start_date and purf.effective_end_date
           and purf.row_low_range_or_name = 'Labor'
           and puc.user_column_name  = p_emp_social_security_info
           and puc.user_table_id = put.user_table_id
           and pucif.user_row_id = purf.user_row_id
           and pucif.user_column_id = puc.user_column_id
           and p_effective_date between pucif.effective_start_date and pucif.effective_end_date;
    end if;


    if p_health_contribution is null then
            select pucif.value
              into p_health_contribution
              from
                pay_user_column_instances_f  pucif,
                pay_user_columns             puc,
                pay_user_rows_f              purf,
                pay_user_tables              put
          where put.user_table_name   ='PL_EMPLOYEE_SOCIAL_SECURITY_INFORMATION'
            and put.legislation_code = 'PL'
            and purf.legislation_code = 'PL'
            and purf.user_table_id = put.user_table_id
            and p_effective_date between purf.effective_start_date and purf.effective_end_date
            and purf.row_low_range_or_name = 'Health'
            and puc.user_column_name  = p_emp_social_security_info
            and puc.user_table_id = put.user_table_id
            and pucif.user_row_id = purf.user_row_id
            and pucif.user_column_id = puc.user_column_id
            and p_effective_date between pucif.effective_start_date and pucif.effective_end_date;
     end if;


     if p_unemployment_contribution is null then
             select pucif.value
               into p_unemployment_contribution
               from
                 pay_user_column_instances_f  pucif,
                 pay_user_columns             puc,
                 pay_user_rows_f              purf,
                 pay_user_tables              put
           where put.user_table_name   ='PL_EMPLOYEE_SOCIAL_SECURITY_INFORMATION'
             and put.legislation_code = 'PL'
             and purf.legislation_code = 'PL'
             and purf.user_table_id = put.user_table_id
             and p_effective_date between purf.effective_start_date and purf.effective_end_date
             and purf.row_low_range_or_name = 'Unemployment'
             and puc.user_column_name  = p_emp_social_security_info
             and puc.user_table_id = put.user_table_id
             and pucif.user_row_id = purf.user_row_id
             and pucif.user_column_id = puc.user_column_id
             and p_effective_date between pucif.effective_start_date and pucif.effective_end_date;
      end if;

 exception
    when no_data_found then
        hr_utility.set_message(801,'PAY_375858_NO_EMP_SOCIAL_INFO');
        hr_utility.raise_error;


end get_contribution_values;

end pay_psd_bus;

/
