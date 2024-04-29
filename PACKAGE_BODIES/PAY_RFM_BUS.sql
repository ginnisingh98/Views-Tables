--------------------------------------------------------
--  DDL for Package Body PAY_RFM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RFM_BUS" as
/* $Header: pyrfmrhi.pkb 120.0 2005/05/29 08:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_rfm_bus.';  -- Global package name
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_report_format_mapping_id             in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_report_format_mappings_f rfm
     where rfm.report_format_mapping_id = p_report_format_mapping_id
       and pbg.business_group_id (+) = rfm.business_group_id;
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
    ,p_argument           => 'report_format_mapping_id'
    ,p_argument_value     => p_report_format_mapping_id
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
         => nvl(p_associated_column1,'REPORT_FORMAT_MAPPING_ID')
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
--  |--------------------< chk_report_format_mapping_id >---------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_report_format_mapping_id
  ( p_report_format_mapping_id  in  number ) IS
--
cursor csr_unique_id  is
  select null
  from   pay_report_format_mappings_f
  where  report_format_mapping_id = p_report_format_mapping_id;
--
  l_proc     varchar2(72) := g_package || 'chk_report_format_mapping_id';
  l_exists   varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
        hr_api.mandatory_arg_error
                   ( p_api_name       =>  l_proc
                    ,p_argument       =>  'REPORT_FORMAT_MAPPING_ID'
                    ,p_argument_value =>  p_report_format_mapping_id
                   );

        open csr_unique_id;
        fetch csr_unique_id into l_exists;

        if csr_unique_id%found then

             close csr_unique_id;

             pay_rfm_shd.constraint_error
                    (p_constraint_name => 'PAY_REPORT_FORMAT_MAPPINGS_PK');

        end if ;

        close csr_unique_id;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_report_format_mapping_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_unique_key >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the uniqueness of the combination
--   report type, report qualifier and report category which forms the
--   true key.
--
--
-- Pre Conditions:
--   Should be called only while insert. Since these columns are non-updatable
--   it is not required to check the uniqueness while update.
--
-- In Arguments:
--
--
--
-- Post Success:
--   Processing Continues.
--
--
-- Post Failure:
--   Failure might occur if any of the parameters are null or the combination
--   already exists for a different report format mapping.
--   Errors are trapped and reported.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unique_key
  ( p_report_type      in  varchar2
   ,p_report_qualifier in  varchar2
   ,p_report_category  in  varchar2
  ) IS
--
cursor csr_unique_key  is
  select null
  from   pay_report_format_mappings_f
  where  report_type = p_report_type
  and    report_qualifier = p_report_qualifier
  and    report_category  = p_report_category;
--
  l_proc     varchar2(72) := g_package || 'chk_unique_key';
  l_exists   varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
        hr_api.mandatory_arg_error
              ( p_api_name       =>  l_proc
               ,p_argument       =>  'REPORT_TYPE'
               ,p_argument_value =>  p_report_type
              );

        hr_api.mandatory_arg_error
              ( p_api_name       =>  l_proc
               ,p_argument       =>  'REPORT_QUALIFIER'
               ,p_argument_value =>  p_report_qualifier
              );

        hr_api.mandatory_arg_error
              ( p_api_name       =>  l_proc
               ,p_argument       =>  'REPORT_CATEGORY'
               ,p_argument_value =>  p_report_category
              );

        open csr_unique_key;
        fetch csr_unique_key into l_exists;

        if csr_unique_key%found then

             close csr_unique_key;

             fnd_message.set_name( 'PAY' , 'PAY_33257_INV_UKEY2' );
             fnd_message.set_token( 'COL1' , 'REPORT_TYPE');
             fnd_message.set_token( 'COL2' , 'REPORT_QUALIFIER');
             fnd_message.set_token( 'COL3' , 'REPORT_CATEGORY');
             fnd_message.set_token( 'COL1_VAL', p_report_type);
             fnd_message.set_token( 'COL2_VAL', p_report_qualifier);
             fnd_message.set_token( 'COL3_VAL', p_report_category);
             fnd_message.raise_error ;

        end if ;

        close csr_unique_key;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_unique_key;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_report_format >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the validity of report_format.
--   report_format must not be null.
--
-- Pre Conditions:
--   None
--
--
-- In Arguments:
--   report_format
--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   Failure might occur if the report_format is null.
--   Errors will be trapped and reported.
--
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_report_format
  ( p_report_format      in  varchar2  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_report_format';
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
        hr_api.mandatory_arg_error
              ( p_api_name       =>  l_proc
               ,p_argument       =>  'REPORT_FORMAT'
               ,p_argument_value =>  p_report_format
              );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_report_format;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_updatable_flag >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Checks the validity of updatable_flag.
--   If updatable_flag is not null then it must be either 'Y' or 'N'
--
-- Pre Conditions:
--   None
--
--
-- In Arguments:
--   updatable_flag
--
--
-- Post Success:
--   Processing Continues.
--
--
-- Post Failure:
--   Failure might occur if updatabale_flag is not valid.
--   Errors are trapped and reported.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_updatable_flag
  ( p_updatable_flag     in  varchar2  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_updatable_flag';
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --

        if  p_updatable_flag is not null and
                  p_updatable_flag not in ('Y', 'N') then

             fnd_message.set_name( 'PAY' , 'PAY_33259_INVALID_UFLAG' );
             fnd_message.raise_error ;

        end if;

  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_updatable_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_legislation_code>-------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Validates that the legislation code exists in fnd_territories
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_legislation_code
--
--  Post Success:
--    Processing continues if the legislation_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the legislation_code is invalid.
--
--  Developer/Implementation Notes:
--    None
--
-- ----------------------------------------------------------------------------
procedure chk_legislation_code
( p_legislation_code  in varchar2 )
is
--
cursor csr_legislation_code is
  select null
  from   fnd_territories
  where  territory_code = p_legislation_code ;
--
l_exists varchar2(1);
l_proc   varchar2(100) := g_package || 'chk_legislation_code';
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_legislation_code;
  fetch csr_legislation_code into l_exists ;

  if csr_legislation_code%notfound then
    close csr_legislation_code;
    fnd_message.set_name('PAY', 'PAY_33177_LEG_CODE_INVALID');
    fnd_message.raise_error;
  end if;
  close csr_legislation_code;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates that the
--       1. For Delete Mode there are no child rows on or after
--          validation_start_date
--       2. For Zap Mode there are no child rows at all.

--
--  Pre-Requisites:
--        None.
--
--  In Parameters:

--
--  Post Success:
--    Processing continues if the deletion is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the deletion is invalid.
--
--  Developer/Implementation Notes:
--    None
--
--  Access Status:
--    Internal Row Handler Use Only
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_delete
  ( p_report_format_mapping_id  in  number
   ,p_object_version_number     in  number
   ,p_datetrack_mode            in  varchar2
   ,p_validation_start_date     in  date
   ,p_validation_end_date       in  date
  ) IS
--
cursor csr_dt_rfi_exists is
   select null
   from   pay_report_format_items_f rfi
         ,pay_report_format_mappings_f rfm
   where  rfm.report_format_mapping_id = p_report_format_mapping_id
   and    rfm.object_version_number = p_object_version_number
   and    rfm.report_type = rfi.report_type
   and    rfm.report_qualifier = rfi.report_qualifier
   and    rfm.report_category = rfi.report_category
   and    rfi.effective_end_date >= p_validation_start_date  ;
--
cursor csr_rfi_exists is
   select null
   from   pay_report_format_items_f rfi
         ,pay_report_format_mappings_f rfm
   where  rfm.report_format_mapping_id = p_report_format_mapping_id
   and    rfm.object_version_number = p_object_version_number
   and    rfm.report_type = rfi.report_type
   and    rfm.report_qualifier = rfi.report_qualifier
   and    rfm.report_category = rfi.report_category;
--
cursor csr_rfp_exists is
   select null
   from   pay_report_format_parameters rfp
   where  rfp.report_format_mapping_id = p_report_format_mapping_id;
--
cursor csr_rftl_exists is
   select null
   from   pay_report_format_mappings_tl rftl
   where  rftl.report_format_mapping_id = p_report_format_mapping_id;
--
  l_proc     varchar2(72) := g_package || 'chk_delete';
  l_exists varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_datetrack_mode = hr_api.g_delete then

        open csr_dt_rfi_exists;
        fetch csr_dt_rfi_exists into l_exists;
        if csr_dt_rfi_exists%found then

                close csr_dt_rfi_exists;

                fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
                fnd_message.set_token('TABLE_NAME', 'PAY_REPORT_FORMAT_ITEMS_F');
                fnd_message.raise_error;

        end if;
        close csr_dt_rfi_exists;

  end if;

  if p_datetrack_mode = hr_api.g_zap then

        open csr_rfi_exists;
        fetch csr_rfi_exists into l_exists;
        if csr_rfi_exists%found then

                close csr_rfi_exists;

                fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
                fnd_message.set_token('TABLE_NAME', 'PAY_REPORT_FORMAT_ITEMS_F');
                fnd_message.raise_error;

        end if;
        close csr_rfi_exists;

        open csr_rfp_exists;
        fetch csr_rfp_exists into l_exists;
        if csr_rfp_exists%found then

                close csr_rfp_exists;

                fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
                fnd_message.set_token('TABLE_NAME', 'PAY_REPORT_FORMAT_PARAMETERS');
                fnd_message.raise_error;

        end if;
        close csr_rfp_exists;

        open csr_rftl_exists;
        fetch csr_rftl_exists into l_exists;
        if csr_rftl_exists%found then

                close csr_rftl_exists;

                fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
                fnd_message.set_token('TABLE_NAME', 'PAY_REPORT_FORMAT_MAPPINGS_TL');
                fnd_message.raise_error;

        end if;
        close csr_rftl_exists;

  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_delete;
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
  ,p_rec             in pay_rfm_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_rfm_shd.api_updating
      (p_report_format_mapping_id         => p_rec.report_format_mapping_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(pay_rfm_shd.g_old_rec.business_group_id, hr_api.g_number) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'BUSINESS_GROUP_ID'
     ,p_base_table => pay_rfm_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.legislation_code, hr_api.g_varchar2) <>
     nvl(pay_rfm_shd.g_old_rec.legislation_code, hr_api.g_varchar2) then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'LEGISLATION_CODE'
     ,p_base_table => pay_rfm_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.report_type, hr_api.g_varchar2) <>
     pay_rfm_shd.g_old_rec.report_type then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'REPORT_TYPE'
     ,p_base_table => pay_rfm_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.report_qualifier, hr_api.g_varchar2) <>
     pay_rfm_shd.g_old_rec.report_qualifier then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'REPORT_QUALIFIER'
     ,p_base_table => pay_rfm_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.report_category, hr_api.g_varchar2) <>
     pay_rfm_shd.g_old_rec.report_category then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'REPORT_CATEGORY'
     ,p_base_table => pay_rfm_shd.g_tab_nam
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
  (p_report_format_mapping_id         in number
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
      ,p_argument       => 'report_format_mapping_id'
      ,p_argument_value => p_report_format_mapping_id
      );
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
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode

  if p_business_group_id is not null and p_legislation_code is not null then
        fnd_message.set_name('PAY', 'PAY_33179_BGLEG_INVALID');
        fnd_message.raise_error;
    end if;

  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_rfm_shd.g_rec_type
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
  --
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );

  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_rfm_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --

  --
  -- Validate Dependent Attributes
  --
  if hr_startup_data_api_support.g_startup_mode not in ('GENERIC','USER') then

        chk_legislation_code(p_legislation_code => p_rec.legislation_code);

  end if;
  --
  chk_unique_key
     ( p_report_type      => p_rec.report_type
      ,p_report_qualifier => p_rec.report_qualifier
      ,p_report_category  => p_rec.report_category
     );
  --
  chk_report_format
     ( p_report_format    => p_rec.report_format );
  --
  chk_updatable_flag
     ( p_updatable_flag   => p_rec.updatable_flag );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_rfm_shd.g_rec_type
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
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pay_rfm_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
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
  chk_report_format
     ( p_report_format    => p_rec.report_format );
  --
  chk_updatable_flag
     ( p_updatable_flag   => p_rec.updatable_flag );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_rfm_shd.g_rec_type
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
    --
  chk_startup_action(false
                    ,pay_rfm_shd.g_old_rec.business_group_id
                    ,pay_rfm_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_report_format_mapping_id         => p_rec.report_format_mapping_id
    );
  --
  chk_delete
    ( p_report_format_mapping_id  => p_rec.report_format_mapping_id
     ,p_object_version_number     => p_rec.object_version_number
     ,p_datetrack_mode            => p_datetrack_mode
     ,p_validation_start_date     => p_validation_start_date
     ,p_validation_end_date       => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_rfm_bus;

/
