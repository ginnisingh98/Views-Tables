--------------------------------------------------------
--  DDL for Package Body AME_STV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_STV_BUS" as
/* $Header: amstvrhi.pkb 120.2 2005/11/22 03:20 santosin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_stv_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_CONDITION_ID >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the mandatory value condition_id entered is
--   defined in the parent (ame_conditons) table and is associated with string
--   attributes.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_condition_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid condition_id has been entered.
--
-- Post Failure:
--   An application error is raised if the condition_id is undefined.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_condition_id(p_condition_id                     in   number
                          ,p_effective_date                   in   date
                          ) IS
--
  cursor csr_name is
         select amecon.condition_id, ameatr.attribute_type
           from ame_conditions amecon
	       ,ame_attributes ameatr
          where amecon.condition_id = p_condition_id
	    and amecon.attribute_id = ameatr.attribute_id
            and p_effective_date between amecon.start_date and
                  nvl(amecon.end_date - ame_util.oneSecond, p_effective_date)
            and p_effective_date between ameatr.start_date and
                  nvl(ameatr.end_date - ame_util.oneSecond, p_effective_date);
  l_key      number;
  l_key2     varchar2(30);
  l_proc     varchar2(72) := g_package || 'CHK_CONDITION_ID';
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'CONDITION_ID'
                              ,p_argument_value     => p_condition_id
                              );
    -- Check for the existence of condition_id in parent table(AME_CONDITIONS)
    open csr_name;
    fetch csr_name into l_key,l_key2;
    if(csr_name%notfound) then
      close csr_name;
      fnd_message.set_name('PER', 'AME_400497_INVALID_CONDITION');
      fnd_message.raise_error;
    elsif(l_key2 <> ame_util.stringAttributeType) then
      close csr_name;
      fnd_message.set_name('PER', 'AME_400508_ATTR_TYP_NOT_STR');
      fnd_message.raise_error;
    end if;
    close csr_name;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                    (p_associated_column1 => 'AME_STRING_VALUES.CONDITION_ID'
                    ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_condition_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_STRING_VALUE >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a string value of the same name doesn't
--   already exist for the entered condition_id. It also ascertains that the
--   value is not null.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_string_value
--   p_condition_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if a unique string value for the condition_id has
--   been entered.
--
-- Post Failure:
--   An application error is raised if the string_value is duplicated.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_string_value(p_string_value                        in   varchar2
                          ,p_condition_id                        in   number
                          ,p_effective_date                      in   date
                          ) IS
--
  cursor csr_name is
         select 'Y'
           from ame_string_values
          where condition_id = p_condition_id
            and string_value = p_string_value
            and p_effective_date between start_date and
                  nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_key      varchar2(1);
  l_proc     varchar2(72) := g_package || 'CHK_STRING_VALUE';
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);

    if(p_string_value is null) then
      fnd_message.set_name('PER','AME_400526_STR_COND_STR_NULL');
      fnd_message.raise_error;
    end if;
    -- Check if String Value is NULL

    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'STRING_VALUE'
                              ,p_argument_value     => p_condition_id
                              );
    -- Check for the existence of condition_id in parent table(AME_CONDITIONS)
    open csr_name;
    fetch csr_name into l_key;
    if(csr_name%found) then
      close csr_name;
      fnd_message.set_name('PER', 'AME_400509_DUP_STRVAL_CON');
      fnd_message.raise_error;
    end if;
    close csr_name;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                    (p_associated_column1 => 'AME_STRING_VALUES.STRING_VALUE'
                    ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_string_value;
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
  ,p_rec             in ame_stv_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_stv_shd.api_updating
      (p_condition_id =>  p_rec.condition_id
 ,p_string_value =>  p_rec.string_value
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
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
  -- CONDITION_ID is non-updateable
  --
  if nvl(p_rec.condition_id, hr_api.g_number) <>
      nvl(ame_stv_shd.g_old_rec.condition_id,hr_api.g_number) then
    hr_api.argument_changed_error
         (p_api_name   => l_proc
         ,p_argument   => 'CONDITION_ID'
         ,p_base_table => ame_stv_shd.g_tab_nam
         );
  end if;
  --
  -- STRING_VALUE is non-updateable
  --
  if nvl(p_rec.string_value, hr_api.g_varchar2) <>
      nvl(ame_stv_shd.g_old_rec.string_value,hr_api.g_varchar2) then
    hr_api.argument_changed_error
         (p_api_name   => l_proc
         ,p_argument   => 'STRING_VALUE'
         ,p_base_table => ame_stv_shd.g_tab_nam
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
  /*hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );*/
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
  (p_condition_id                     in number
  ,p_string_value                     in varchar2
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
    /*hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );*/
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'condition_id'
      ,p_argument_value => p_condition_id
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
  (p_rec                   in ame_stv_shd.g_rec_type
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
  -- Validate Dependent Attributes
  --
  -- Developer entered calls to validate procedures.
  --
  chk_condition_id(p_rec.condition_id
                  ,p_effective_date
                  );
  chk_string_value(p_rec.string_value
                  ,p_rec.condition_id
                  ,p_effective_date
                  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_stv_shd.g_rec_type
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_stv_shd.g_rec_type
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
    ,p_condition_id =>  p_rec.condition_id
 ,p_string_value =>  p_rec.string_value
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_stv_bus;

/
