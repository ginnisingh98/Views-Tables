--------------------------------------------------------
--  DDL for Package Body PAY_RFI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RFI_BUS" as
/* $Header: pyrfirhi.pkb 120.0 2005/05/29 08:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_rfi_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_unique_key >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check the uniqueness of the combination
--   report type, report qualifier, report category and user_entity_id
--   which forms the true key.
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
--   already exists for a different report format item.
--   Errors are trapped and reported.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_unique_key
  ( p_report_type      in  varchar2
   ,p_report_qualifier in  varchar2
   ,p_report_category  in  varchar2
   ,p_user_entity_id   in  number
  ) IS
--
cursor csr_unique_key  is
  select null
  from   pay_report_format_items_f
  where  report_type = p_report_type
  and    report_qualifier = p_report_qualifier
  and    report_category  = p_report_category
  and    user_entity_id   = p_user_entity_id ;
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

        hr_api.mandatory_arg_error
              ( p_api_name       =>  l_proc
               ,p_argument       =>  'USER_ENTITY_ID'
               ,p_argument_value =>  p_user_entity_id
              );

        open csr_unique_key;
        fetch csr_unique_key into l_exists;

        if csr_unique_key%found then

             close csr_unique_key;

             fnd_message.set_name( 'PAY' , 'PAY_33258_INV_UKEY3' );
             fnd_message.set_token( 'COL1' , 'REPORT_TYPE');
             fnd_message.set_token( 'COL2' , 'REPORT_QUALIFIER');
             fnd_message.set_token( 'COL3' , 'REPORT_CATEGORY');
             fnd_message.set_token( 'COL4' , 'USER_ENTITY_ID');
             fnd_message.set_token( 'COL1_VAL', p_report_type);
             fnd_message.set_token( 'COL2_VAL', p_report_qualifier);
             fnd_message.set_token( 'COL3_VAL', p_report_category);
             fnd_message.set_token( 'COL4_VAL', p_user_entity_id);
             fnd_message.raise_error ;

        end if ;

        close csr_unique_key;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_unique_key;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_report_format_mapping >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check whether the report format mapping that
--   is being used in the report format item  exists or not.
--   It is necessary that the report format mapping exists before the report
--   format items for that are created
--
-- Pre Conditions:
--   None
--
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
--   Failure might occur if the arguments are null or the report
--   format mapping does not exists. Errors are trapped and reported.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_report_format_mapping
  ( p_report_type      in  varchar2
   ,p_report_qualifier in  varchar2
   ,p_report_category  in  varchar2
  ) IS
--
cursor csr_report_format_mapping  is
  select null
  from   pay_report_format_mappings_f
  where  report_type = p_report_type
  and    report_qualifier = p_report_qualifier
  and    report_category  = p_report_category;
--
  l_proc     varchar2(72) := g_package || 'chk_report_format_mapping';
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

        open csr_report_format_mapping;
        fetch csr_report_format_mapping into l_exists;

        if csr_report_format_mapping%notfound then

             close csr_report_format_mapping;

             fnd_message.set_name( 'PAY' , 'PAY_33260_INVALID_RFM' );
             fnd_message.set_token( 'COL1' , p_report_type);
             fnd_message.set_token( 'COL2' , p_report_qualifier);
             fnd_message.set_token( 'COL3' , p_report_category);
             fnd_message.raise_error ;

        end if ;

        close csr_report_format_mapping;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_report_format_mapping;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_user_entity_id >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check whether the user entity that
--   is being used in the report format item  exists or not.
--   It is necessary that the user entity exists before the report
--   format item can use that.
--
-- Pre Conditions:
--   None
--
--
-- In Arguments:
--   user_entity_id
--
--
-- Post Success:
--   Processing Continues.
--
--
-- Post Failure:
--   Failure might occur if the user_entity_id is null or the user_entity_id
--   does not exists. Errors are trapped and reported.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_user_entity_id
  ( p_user_entity_id      in  number
  ) IS
--
cursor csr_user_entity_id  is
  select null
  from   ff_user_entities
  where  user_entity_id = p_user_entity_id ;
--
  l_proc     varchar2(72) := g_package || 'chk_user_entity_id';
  l_exists   varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --

        hr_api.mandatory_arg_error
              ( p_api_name       =>  l_proc
               ,p_argument       =>  'USER_ENTITY_ID'
               ,p_argument_value =>  p_user_entity_id
              );

        open  csr_user_entity_id;
        fetch csr_user_entity_id into l_exists;

        if csr_user_entity_id%notfound then

             close csr_user_entity_id;

             fnd_message.set_name('PAY', 'PAY_33174_PARENT_ID_INVALID');
             fnd_message.set_token('PARENT' , 'User Entity Id' );
             fnd_message.raise_error;

        end if ;

        close csr_user_entity_id;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_user_entity_id;
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
  ,p_rec             in pay_rfi_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_rfi_shd.api_updating
      (p_report_format_item_id            => p_rec.report_format_item_id
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
  if nvl(p_rec.report_type, hr_api.g_varchar2) <>
     pay_rfi_shd.g_old_rec.report_type then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'REPORT_TYPE'
     ,p_base_table => pay_rfi_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.report_qualifier, hr_api.g_varchar2) <>
     pay_rfi_shd.g_old_rec.report_qualifier then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'REPORT_QUALIFIER'
     ,p_base_table => pay_rfi_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.report_category, hr_api.g_varchar2) <>
     pay_rfi_shd.g_old_rec.report_category then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'REPORT_CATEGORY'
     ,p_base_table => pay_rfi_shd.g_tab_nam
     );
  end if;
  --
  if nvl(p_rec.user_entity_id, hr_api.g_number) <>
     pay_rfi_shd.g_old_rec.user_entity_id then
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'USER_ENTITY_ID'
     ,p_base_table => pay_rfi_shd.g_tab_nam
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
  (p_report_format_mapping_id      in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
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
  If ((nvl(p_report_format_mapping_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_report_format_mappings_f'
            ,p_base_key_column => 'REPORT_FORMAT_MAPPING_ID'
            ,p_base_key_value  => p_report_format_mapping_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','report format mappings');
     hr_multi_message.add
       (p_associated_column1 => pay_rfi_shd.g_tab_nam || '.REPORT_FORMAT_MAPPING
_ID');
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
  (p_report_format_item_id            in number
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
      ,p_argument       => 'report_format_item_id'
      ,p_argument_value => p_report_format_item_id
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
  (p_rec                   in pay_rfi_shd.g_rec_type
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
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  --
  -- Validate Dependent Attributes
  --
    chk_unique_key
     ( p_report_type      => p_rec.report_type
      ,p_report_qualifier => p_rec.report_qualifier
      ,p_report_category  => p_rec.report_category
      ,p_user_entity_id   => p_rec.user_entity_id
     );
  --
    chk_report_format_mapping
     ( p_report_type      => p_rec.report_type
      ,p_report_qualifier => p_rec.report_qualifier
      ,p_report_category  => p_rec.report_category
     );
  --
    chk_user_entity_id
     ( p_user_entity_id   => p_rec.user_entity_id );
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
  (p_rec                     in pay_rfi_shd.g_rec_type
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
  -- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS.
  --
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_report_format_mapping_id       => p_rec.report_format_mapping_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
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
  (p_rec                    in pay_rfi_shd.g_rec_type
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
    ,p_report_format_item_id            => p_rec.report_format_item_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_report_format_item_id >----------------------|
--  ---------------------------------------------------------------------------
--
Procedure chk_report_format_item_id
  ( p_report_format_item_id  in  number ) IS
--
cursor csr_unique_id  is
  select null
  from   pay_report_format_items_f
  where  report_format_item_id = p_report_format_item_id;
--
  l_proc     varchar2(72) := g_package || 'chk_report_format_item_id';
  l_exists   varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
        hr_api.mandatory_arg_error
                   ( p_api_name       =>  l_proc
                    ,p_argument       =>  'REPORT_FORMAT_ITEM_ID'
                    ,p_argument_value =>  p_report_format_item_id
                   );

        open csr_unique_id;
        fetch csr_unique_id into l_exists;

        if csr_unique_id%found then

             close csr_unique_id;

             pay_rfi_shd.constraint_error
                    (p_constraint_name => 'PAY_REPORT_FORMAT_ITEMS_PK');

        end if ;

        close csr_unique_id;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
End chk_report_format_item_id;
--
end pay_rfi_bus;

/
