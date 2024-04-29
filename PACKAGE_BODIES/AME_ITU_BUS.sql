--------------------------------------------------------
--  DDL for Package Body AME_ITU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ITU_BUS" as
/* $Header: amiturhi.pkb 120.6 2006/10/05 16:11:40 pvelugul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_itu_bus.';  -- Global package name
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_APPLICATION_ID >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensure that application_id must be already defined in
--   ame_calling_apps table and must be valid over the given date ranges
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid application_id has been entered.
--
-- Post Failure:
--   An application error is raised if the application_id is not defined in
--   ame_calling_apps table
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_application_id(p_application_id                  in   number
                            ,p_effective_date                  in   date
                            ) IS
--
  cursor csr_application_id is
         select null
           from ame_calling_apps
          where application_id = p_application_id
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_APPLICATION_ID';
  l_dummy    varchar2(1);
--
  Begin
    hr_utility.set_location(' Entering:'||l_proc,10);

    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'APPLICATION_ID'
                              ,p_argument_value     => p_application_id
                              );
    open csr_application_id;
    fetch csr_application_id into l_dummy;
    if(csr_application_id%notfound) then
      close csr_application_id;
      fnd_message.set_name('PER','AME_400732_INV_APPLICATION_ID');
      fnd_message.raise_error;
    end if;
    close csr_application_id;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_ITEM_CLASS_USAGES.APPLICATION_ID'
                     ) then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
    End chk_application_id;
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_ITEM_CLASS_ID >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensure that item_class_id must be already defined in
--   ame_item_classes table and must be valid over the given date ranges
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_item_class_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid item_class_id has been entered.
--
-- Post Failure:
--   An application error is raised if the item_class_id is not defined in
--   ame_item_classes table
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_item_class_id(p_item_class_id                    in   number
                           ,p_effective_date                   in   date
                            ) IS
--
  cursor csr_item_class_id is
         select null
           from ame_item_classes
          where item_class_id = p_item_class_id
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_ITEM_CLASS_ID';
  l_dummy    varchar2(1);
--
  Begin
    hr_utility.set_location(' Entering:'||l_proc,10);

    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'ITEM_CLASS_ID'
                              ,p_argument_value     => p_item_class_id
                              );
    open csr_item_class_id;
    fetch csr_item_class_id into l_dummy;
    if(csr_item_class_id%notfound) then
      close csr_item_class_id;
      fnd_message.set_name('PER','AME_400740_INV_ITEM_CLASS_ID');
      fnd_message.raise_error;
    end if;
    close csr_item_class_id;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_CLASS_ID'
                     ) then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
    End chk_item_class_id;
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_ITEM_CLASS_USAGE >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensure that the item class usage being created is not
--   already present for the given transaction type.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_item_class_id
--   p_application_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid item_class_usage is not already present
--
-- Post Failure:
--   An application error is raised if the item_class_usage is already defined
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_item_class_usage
            (p_item_class_id                    in   number
            ,p_application_id                   in   number
            ,p_effective_date                   in   date
            ) is
--
  cursor csr_item_class_usage is
         select null
           from ame_item_class_usages
          where item_class_id = p_item_class_id
            and application_id = p_application_id
            and p_effective_date between start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
  l_proc     varchar2(72) := g_package || 'CHK_ITEM_CLASS_USAGE';
  l_dummy    varchar2(1);
--
  Begin
    hr_utility.set_location(' Entering:'||l_proc,10);
    open csr_item_class_usage;
    fetch csr_item_class_usage into l_dummy;
    if(csr_item_class_usage%found) then
      close csr_item_class_usage;
      fnd_message.set_name('PER','AME_400745_ITC_NAME_NOT_UNQ');
      fnd_message.raise_error;
    end if;
    close csr_item_class_usage;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_CLASS_ID'
                     ) then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
    End chk_item_class_usage;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_MANDATORY_ARGS >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensure that not null values are passed for the following
--   arguments:ITEM_ID_QUERY, ITEM_CLASS_PAR_MODE, ITEM_CLASS_SUBLIST_MODE
--
-- Pre-Requisites:
--   chk_application_id and chk_item_class_id must have been validated
--
-- In Parameters:
--   p_rec
--
-- Post Success:
--   Processing continues if a valid not null value has been entered for the
--   above mentioned arguments
--
-- Post Failure:
--   An application error is raised if null value is passed for any of the
--   above mentioned argument
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_mandatory_args(p_rec         ame_itu_shd.g_rec_type) IS
--
  l_proc                 varchar2(72) := g_package || 'CHK_MANDATORY_ARGS';
--
  Begin
    hr_utility.set_location(' Entering:'||l_proc,10);
    if hr_multi_message.no_all_inclusive_error
               (p_check_column1 => 'AME_ITEM_CLASS_USAGES.APPLICATION_ID') and
       hr_multi_message.no_all_inclusive_error
               (p_check_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_CLASS_ID') then
      hr_api.mandatory_arg_error(p_api_name           => l_proc
                                ,p_argument           => 'ITEM_ID_QUERY'
                                ,p_argument_value     => p_rec.item_id_query
                                );
      hr_api.mandatory_arg_error(p_api_name           => l_proc
                                ,p_argument           => 'ITEM_CLASS_ORDER_NUMBER'
                                ,p_argument_value     => p_rec.item_class_order_number
                                );
      hr_api.mandatory_arg_error(p_api_name           => l_proc
                                ,p_argument           => 'ITEM_CLASS_PAR_MODE'
                                ,p_argument_value     => p_rec.item_class_par_mode
                                );
      hr_api.mandatory_arg_error(p_api_name           => l_proc
                                ,p_argument           => 'ITEM_CLASS_SUBLIST_MODE'
                                ,p_argument_value     => p_rec.item_class_sublist_mode
                                );
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  End chk_mandatory_args;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_ITEM_ID_QUERY >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensure that item_id_query must not contain any special
--   characters like ';','--','/*','*/ and any place holder column other
--   than the one for transaction ID
--
-- Pre-Requisites:
--   chk_application_id and chk_item_class_id must have been validated
--
-- In Parameters:
--   p_item_id_query
--
-- Post Success:
--   Processing continues if a valid item_id_query has been entered.
--
-- Post Failure:
--   An application error is raised if item_id_query is not valid
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_item_id_query(p_item_id_query             in   varchar2) IS
--
  l_proc                       varchar2(72) := g_package || 'CHK_ITEM_ID_QUERY';
  l_upper_item_id_query        ame_item_class_usages.item_id_query%type;
  l_trans_id_placeholder_pos   integer;
  l_trans_id_placeholder_pos2  integer;
  l_temp_count                 integer;
  l_upper_trans_id_placeholder ame_util.stringType;
  l_query_validation           varchar2(1000);
--
  Begin
    hr_utility.set_location(' Entering:'||l_proc,10);
    if hr_multi_message.no_all_inclusive_error
               (p_check_column1 => 'AME_ITEM_CLASS_USAGES.APPLICATION_ID') and
       hr_multi_message.no_all_inclusive_error
               (p_check_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_CLASS_ID') then
      if nvl(p_item_id_query, hr_api.g_varchar2) <> hr_api.g_varchar2 then
        -- Check for special characters in item_id_query
        if(instrb(p_item_id_query, ';', 1, 1) > 0) or
          (instrb(p_item_id_query, '--', 1, 1) > 0) or
          (instrb(p_item_id_query, '/*', 1, 1) > 0) or
          (instrb(p_item_id_query, '*/', 1, 1) > 0) then
          fnd_message.set_name('PER','QUERY_CONTAINS_SPL_CHARS');
          fnd_message.raise_error;
        end if;
        -- Check for any other place holder columns other than place holder
        -- column for transaction ID
        l_temp_count := 1;
        l_upper_item_id_query        := upper(p_item_id_query);
        l_upper_trans_id_placeholder := upper(ame_util.transactionIdPlaceholder);
        loop
          l_trans_id_placeholder_pos :=
            instrb(l_upper_item_id_query, l_upper_trans_id_placeholder, 1, l_temp_count);
          if(l_trans_id_placeholder_pos = 0) then
            exit;
          end if;
          l_trans_id_placeholder_pos2 :=
            instrb(p_item_id_query, ame_util.transactionIdPlaceholder, 1, l_temp_count);
          if(l_trans_id_placeholder_pos <> l_trans_id_placeholder_pos2) then
            fnd_message.set_name('PER','AME_400377_ADM_IC_QUERY2');
            fnd_message.raise_error;
          end if;
          l_temp_count := l_temp_count + 1;
        end loop;
        select ame_utility_pkg.validate_query(p_item_id_query,'1',ame_util2.itemClassObject)
          into l_query_validation
          from dual;
        if l_query_validation <> 'Y' then
          fnd_message.raise_error;
        end if;
      end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_ID_QUERY'
                     ) then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
    End chk_item_id_query;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_ITEM_CLASS_PAR_MODE >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that no other value is entered other than
--   ame_util.serialItems and ame_util.parallelItems for item_class_par_mode
--
-- Pre-Requisites:
--   chk_application_id and chk_item_class_id must have been validated
--
-- In Parameters:
--   p_item_class_par_mode
--
-- Post Success:
--   Processing continues if a valid item_class_par_mode has been entered.
--
-- Post Failure:
--   An application error is raised if other values are passed for
--   item_class_par_mode except the two mentioned above
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_item_class_par_mode(p_item_class_par_mode   in   varchar2) IS
--
  l_proc                       varchar2(72) := g_package || 'CHK_ITEM_CLASS_PAR_MODE';
--
  Begin
    hr_utility.set_location(' Entering:'||l_proc,10);
    if hr_multi_message.no_all_inclusive_error
               (p_check_column1 => 'AME_ITEM_CLASS_USAGES.APPLICATION_ID') and
       hr_multi_message.no_all_inclusive_error
               (p_check_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_CLASS_ID') then
        if nvl(p_item_class_par_mode, hr_api.g_varchar2) <> hr_api.g_varchar2 and
           p_item_class_par_mode not in (ame_util.serialItems,
                                         ame_util.parallelItems
                                         ) then
          fnd_message.set_name('PER','AME_400766_INV_PARAM_MODE');
          fnd_message.raise_error;
        end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_CLASS_PAR_MODE'
                     ) then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
    End chk_item_class_par_mode;
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_ITEM_CLASS_SUBLIST_MODE >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that no other value is entered other than
--   ame_util.serialSublists, ame_util.parallelSublists, ame_util.preFirst
--   and ame_util.preAndAuthorityFirst for item_class_sublist_mode
--
-- Pre-Requisites:
--   chk_application_id and chk_item_class_id must have been validated
--
-- In Parameters:
--   p_item_class_sublist_mode
--
-- Post Success:
--   Processing continues if a valid item_class_sublist_mode has been entered.
--
-- Post Failure:
--   An application error is raised if other values are passed for
--   item_class_sublist_mode except the four mentioned above
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_item_class_sublist_mode(p_item_class_sublist_mode in varchar2) IS
--
  l_proc          varchar2(72) := g_package || 'CHK_ITEM_CLASS_SUBLIST_MODE';
--
  Begin
    hr_utility.set_location(' Entering:'||l_proc,10);
    if hr_multi_message.no_all_inclusive_error
               (p_check_column1 => 'AME_ITEM_CLASS_USAGES.APPLICATION_ID') and
       hr_multi_message.no_all_inclusive_error
               (p_check_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_CLASS_ID') then
        if nvl(p_item_class_sublist_mode, hr_api.g_varchar2) <>
              hr_api.g_varchar2 and
              p_item_class_sublist_mode not in (ame_util.serialSublists
                                                ,ame_util.parallelSublists
                                                ,ame_util.preFirst
                                                ,ame_util.preAndAuthorityFirst
                                               ) then
          fnd_message.set_name('PER','AME_400767_INV_SUBLIST_MODE');
          fnd_message.raise_error;
        end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_CLASS_SUBLIST_MODE'
                     ) then
      hr_utility.set_location(' Leaving:'||l_proc, 40);
      raise;
      end if;
      hr_utility.set_location(' Leaving:'||l_proc,50);
    End chk_item_class_sublist_mode;
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_ORDER_NUMBER>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates order_number which should be positive integer.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_order_number
--
-- Post Success:
--   Processing continues if order_number has valid value.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_order_number(
                           p_order_number   in   number
                          ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_ORDER_NUMBER';
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'ORDER_NUMBER'
                              ,p_argument_value     => p_order_number
                              );
    -- check if order_number is negative
    --
    if p_order_number <=0  then
      fnd_message.set_name('PER','AME_400565_INVALID_ORDER_NUM');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                (p_associated_column1 => 'AME_ITEM_CLASS_USAGES.ITEM_CLASS_ORDER_NUMBER'
                 ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_order_number;
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
  ,p_rec             in ame_itu_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_itu_shd.api_updating
      (p_item_class_id         => p_rec.item_class_id
      ,p_application_id        => p_rec.application_id
      ,p_effective_date        => p_effective_date
      ,p_object_version_number => p_rec.object_version_number
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
End chk_non_updateable_args;

procedure chk_delete
  (p_item_class_id   in number
  ,p_application_id in number) is
  l_proc              varchar2(72)  :=  g_package||'chk_delete';
	cursor c_sel1 Is
    select null
      from ame_item_class_usages
      where
        ame_utility_pkg.check_seeddb = 'N' and
        ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById and
		    item_class_id = p_item_class_id and
        application_id = p_application_id ;
	l_exists varchar2(1);
begin
  null;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ITEM_CLASS_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_delete;


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
  (p_item_class_id                 in number default hr_api.g_number
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
  ,p_item_class_id                    in number
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
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'item_class_id'
      ,p_argument_value => p_item_class_id
      );
    --
    -- Ensures no child rows exists for the particular item_class_id and
    -- application_id
    --
    ame_itu_shd.child_rows_exist
    (p_item_class_id  => p_item_class_id
    ,p_application_id => p_application_id
    ,p_start_date     => p_validation_start_date
    ,p_end_date       => p_validation_end_date);

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
  (p_rec                   in ame_itu_shd.g_rec_type
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
  ame_itu_bus.chk_application_id(p_application_id   => p_rec.application_id
                                ,p_effective_date   => p_effective_date);

  ame_itu_bus.chk_item_class_id(p_item_class_id   => p_rec.item_class_id
                                ,p_effective_date => p_effective_date);

  ame_itu_bus.chk_item_class_usage(p_item_class_id   => p_rec.item_class_id
                                ,p_application_id  => p_rec.application_id
                                ,p_effective_date => p_effective_date);

  ame_itu_bus.chk_mandatory_args(p_rec   => p_rec);

  ame_itu_bus.chk_item_id_query(p_item_id_query   => p_rec.item_id_query);

  ame_itu_bus.chk_item_class_par_mode(
                      p_item_class_par_mode  => p_rec.item_class_par_mode
                      );

  ame_itu_bus.chk_item_class_sublist_mode(
              p_item_class_sublist_mode  => p_rec.item_class_sublist_mode
              );
  ame_itu_bus.chk_order_number(p_order_number   => p_rec.item_class_order_number);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_itu_shd.g_rec_type
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
    (p_item_class_id                  => p_rec.item_class_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  ame_itu_bus.chk_item_id_query(p_item_id_query   => p_rec.item_id_query);

  ame_itu_bus.chk_item_class_par_mode(
                      p_item_class_par_mode  => p_rec.item_class_par_mode
                      );

  ame_itu_bus.chk_item_class_sublist_mode(
              p_item_class_sublist_mode  => p_rec.item_class_sublist_mode
              );
  ame_itu_bus.chk_order_number(p_order_number   => p_rec.item_class_order_number);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_itu_shd.g_rec_type
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
    ,p_item_class_id                    =>  p_rec.item_class_id
    ,p_application_id                   =>  p_rec.application_id
    );
  --
    chk_delete(p_item_class_id => p_rec.item_class_id
              ,p_application_id => p_rec.application_id
              );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_itu_bus;

/
