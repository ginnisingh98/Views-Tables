--------------------------------------------------------
--  DDL for Package Body AME_ACA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACA_BUS" as
/* $Header: amacarhi.pkb 120.4 2006/10/05 15:53:53 pvelugul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_aca_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CHK_FND_APPLICATION_ID >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether a valid FND Application ID has been
--   provided. The ID must be defined in the FND_APPLICATION table.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_fnd_application_id
--
-- Post Success:
--   Processing continues if a valid FND Application ID is found.
--
-- Post Failure:
--   An application error is raised either if the p_fnd_application_id is not
--   defined or if the value is not found in FND_APPLICATION table.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_fnd_application_id(p_fnd_application_id           in   number) IS
--
  cursor csr_fnd_application_id is
         select null
           from fnd_application
          where application_id = p_fnd_application_id;
  l_proc     varchar2(72) := g_package || 'CHK_FND_APPLICATION_ID';
  l_key      varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'FND_APPLICATION_ID'
                              ,p_argument_value     => p_fnd_application_id
                              );
    open csr_fnd_application_id;
    fetch csr_fnd_application_id into l_key;
    if(csr_fnd_application_id%notfound) then
      close csr_fnd_application_id;
      fnd_message.set_name('AME', 'INVALID_FND_APPLICATION_ID');
      fnd_message.raise_error;
    else
      close csr_fnd_application_id;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
               (p_associated_column1 => 'AME_CALLING_APPS.FND_APPLICATION_ID'
               ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_fnd_application_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< CHK_APPLICATION_NAME >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether a value is defined for APPLICATION_NAME and
--   is unique.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_name
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid unique Application Name is found.
--
-- Post Failure:
--   An application error is raised if the Application Name is not defined or
--   is duplicated.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_application_name(p_application_name                in   varchar2
                              ,p_effective_date                  in   date
                              ) IS
--
  cursor csr_application_name is
         select null
           from ame_calling_apps
          where application_name=p_application_name;
-- Modified for 4540774.
/*            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);*/
  l_proc     varchar2(72) := g_package || 'CHK_APPLICATION_NAME';
  l_key      varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'APPLICATION_NAME'
                              ,p_argument_value     => p_application_name
                              );
    open csr_application_name;
    fetch csr_application_name into l_key;
    if(csr_application_name%found) then
      close csr_application_name;
      fnd_message.set_name('AME', 'AME_400748_TTY_NAME_IN_USE');
      fnd_message.raise_error;
    end if;
    close csr_application_name;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
               (p_associated_column1 => 'AME_CALLING_APPS.APPLICATION_NAME'
               ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_application_name;
--
-- ----------------------------------------------------------------------------
-- |----------------------< CHK_FND_APP_ID_TX_TYPE_ID >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks the uniqueness of the FND_APPLICATION_ID -
--   TRANSACTION_TYPE_ID combination.TRANSACTION_TYPE_ID cannot be null if an
--   existing transaction type already exists for the same application with a
--   null TRANSACTION_TYPE_ID
--
-- Pre-Requisites:
--   chk_fnd_application_id must have been evaluated.
--
-- In Parameters:
--   p_fnd_application_id
--   p_transaction_type_id
--
-- Post Success:
--   Processing continues if the combination is found unique.
--
-- Post Failure:
--   An application error is raised if the uniqueness of the combination is
--   not maintained.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_fnd_app_id_tx_type_id(p_fnd_application_id          in   number
                                   ,p_transaction_type_id         in   varchar2
                                   ) IS
--
  cursor csr_fnd_app_tx_type is
         select null
           from ame_calling_apps
          where fnd_application_id=p_fnd_application_id
            and ((transaction_type_id is null and p_transaction_type_id is null)
             or (transaction_type_id = p_transaction_type_id)
                );
--            and sysdate between start_date and nvl(end_date-(1/84600),sysdate);
  l_proc     varchar2(72) := g_package || 'CHK_FND_APP_ID_TX_TYPE_ID';
  l_key      varchar2(1);
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    if hr_multi_message.no_all_inclusive_error
                   (p_check_column1 => 'AME_CALLING_APPS.FND_APPLICATION_ID') then
      open csr_fnd_app_tx_type;
      fetch csr_fnd_app_tx_type into l_key;
      if(csr_fnd_app_tx_type%found) then
        close csr_fnd_app_tx_type;
        fnd_message.set_name('AME', 'AME_400763_TTID_IN_USE');
        fnd_message.raise_error;
      end if;
      close csr_fnd_app_tx_type;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
               (p_associated_column1 => 'AME_CALLING_APPS.FND_APP_TX_TYP_ID'
               ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
  End chk_fnd_app_id_tx_type_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_is_tty_id_null >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether a value is defined for transaction_type_id
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_transaction_type_id
--
-- Post Success:
--   Processing continues transaction_type_id  is not null.
--
-- Post Failure:
--   An application error is raised if the transaction_type_id is null.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_is_tty_id_null(p_transaction_type_id in varchar2) is
l_proc     varchar2(72) := g_package || 'CHK_IS_TTY_ID_NULL';
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if p_transaction_type_id is null then
    fnd_message.set_name('PER', 'AME_400780_NULL_TTY_ID');
    fnd_message.raise_error;
  end if;
end chk_is_tty_id_null;
-- ----------------------------------------------------------------------------
-- |-----------------------------< CHK_DELETE >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks whether the specified transaction_type exists and
--   is not a seeded record.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if the transaction_type is identified as a
--   non-seeded one.
--
-- Post Failure:
--   An application error is raised if a seeded transaction_type (identified
--   by p_application_id) is defined.An error is also raised when an invalid
--   transaction_type is passed in.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_delete(p_application_id          in   number
                    ,p_effective_date              in   date
                    ) IS
--
  cursor csr_isSeeded is
         select ame_utility_pkg.is_seed_user(created_by)
           from ame_calling_apps
          where application_id=p_application_id
            and p_effective_date between start_date and
                  nvl(end_date - ame_util.oneSecond,p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_DELETE';
  l_key      number;
--
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    open csr_isSeeded;
    fetch csr_isSeeded into l_key;
    if(csr_isSeeded%notfound) then
      close csr_isSeeded;
      fnd_message.set_name('AME', 'INVALID_TRANSACTION_TYPE');
      fnd_message.raise_error;
    else
      close csr_isSeeded;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
               (p_associated_column1 => 'AME_CALLING_APPS.DELETE'
               ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
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
  ,p_rec             in ame_aca_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_aca_shd.api_updating
      (p_application_id =>  p_rec.application_id
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
  -- FND_APPLICATION_ID is non-updateable
  --
  if nvl(p_rec.fnd_application_id, hr_api.g_number) <>
     nvl(ame_aca_shd.g_old_rec.fnd_application_id,hr_api.g_number) then
    hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'FND_APPLICATION_ID'
          ,p_base_table => ame_aca_shd.g_tab_nam
          );
  end if;
  --
  -- APPLICATION_ID is non-updateable
  --
  if nvl(p_rec.application_id, hr_api.g_number) <>
     nvl(ame_aca_shd.g_old_rec.application_id,hr_api.g_number) then
    hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'APPLICATION_ID'
          ,p_base_table => ame_aca_shd.g_tab_nam
          );
  end if;
  --
  --
  -- TRANSACTION_TYPE_ID is non-updateable
  --
  if nvl(p_rec.transaction_type_id, hr_api.g_varchar2) <>
     nvl(ame_aca_shd.g_old_rec.transaction_type_id,hr_api.g_varchar2) then
    hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'TRANSACTION_TYPE_ID'
          ,p_base_table => ame_aca_shd.g_tab_nam
          );
  end if;
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
  (p_application_id                   in number
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
      ,p_argument       => 'application_id'
      ,p_argument_value => p_application_id
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
  (p_rec                   in ame_aca_shd.g_rec_type
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
  chk_is_tty_id_null
    (p_transaction_type_id => p_rec.transaction_type_id);
  --
  chk_fnd_application_id
    (p_fnd_application_id => p_rec.fnd_application_id);
  --
  chk_application_name
    (p_application_name => p_rec.application_name
    ,p_effective_date   => p_effective_date
    );
  --
  chk_fnd_app_id_tx_type_id
    (p_fnd_application_id  => p_rec.fnd_application_id
    ,p_transaction_type_id => p_rec.transaction_type_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_aca_shd.g_rec_type
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
  -- Check for application name when there has been a change in its value.
  --
  if nvl(p_rec.application_name, hr_api.g_varchar2) <>
     nvl(ame_aca_shd.g_old_rec.application_name,hr_api.g_varchar2) then
    chk_application_name(p_application_name  => p_rec.application_name
                        ,p_effective_date    => p_effective_date
                        );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_aca_shd.g_rec_type
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
    ,p_application_id =>  p_rec.application_id
    );
  --
  chk_delete
    (p_application_id   => p_rec.application_id
    ,p_effective_date   => p_effective_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_aca_bus;

/
