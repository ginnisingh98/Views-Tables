--------------------------------------------------------
--  DDL for Package Body AME_RUL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RUL_BUS" as
/* $Header: amrulrhi.pkb 120.6 2006/02/14 01:23 vboggava noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_rul_bus.';  -- Global package name
--  ---------------------------------------------------------------------------
--  |----------------------< chk_description       >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the Description is less than 100 characters.
--   It also checks that the description is not in use by any existing rule.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_rule_id
--   p_object_version_number
--   p_description
--
-- Post Success:
--   Processing continues if description is valid.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_description
  (p_rule_id   in number,
   p_object_version_number in number,
   p_effective_date in date,
   p_description in ame_rules.description%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_description';
  l_descriptionCount    number;
begin
  -- check description is null
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'description'
                            ,p_argument_value => p_description
                            );
  -- check description not in use
  select count(*)
    into l_descriptionCount
    from ame_rules
   where upper(description) = upper(p_description)
     and (p_rule_id is null or rule_id <> p_rule_id) /* allows for future start date */
     and ((p_effective_date between start_date
            and nvl(end_date - ame_util.oneSecond, p_effective_date))
         or
          (p_effective_date < start_date
            and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  if l_descriptionCount > 0 then
    fnd_message.set_name('PER','AME_400206_RUL_DESC_IN_USE');
    fnd_message.raise_error;
  end if;
  -- check length
  if(ame_util.isArgumentTooLong(tableNameIn  => 'ame_rules'
                               ,columnNameIn => 'description'
                               ,argumentIn   => p_description)) then
    fnd_message.set_name('PER','AME_400207_RUL_DESC_LONG');
    fnd_message.raise_error;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'DESCRIPTION') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_description;
--  ---------------------------------------------------------------------------
--  |----------------------<chk_item_class_id      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the item_class_id is a foreign key to
--   ame_item_classes.item_class_id. Also check that ITEM_CLASS_ID is not
--   inserted for list modification and substitutions rules.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_rule_id
--   p_object_version_number
--   p_effective_date
--   p_item_class_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_item_class_id
  (p_rule_id   in number,
   p_object_version_number in number,
   p_effective_date        in date,
   p_item_class_id in ame_rules.item_class_id%type,
   p_rule_type in ame_rules.rule_type%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_item_class_id';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_item_classes
      where
        item_class_id = p_item_class_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  if p_item_class_id is not null or p_rule_type <> ame_util.combinationRuleType then
    open c_sel1;
    fetch  c_sel1 into l_exists;
    if c_sel1%notfound then
      close c_sel1;
      fnd_message.set_name('PER','AME_400472_INV_ITEM_CLASS');
      fnd_message.raise_error;
    end if;
    close c_sel1;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ITEM_CLASS_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_item_class_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_rule_key         >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
-- Checks if there is a duplicate for the rule key.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_rule_key
--
-- Post Success:
--   Processing continues if rule type is unique.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_rule_key(p_rule_key in varchar2) is
l_count number(2);
begin
  select count(*)
    into l_count
    from ame_rules
   where lower(p_rule_key) = lower(rule_key);
  if l_count > 0 then
    fnd_message.set_name('PER','AME_400359_RULE_KEY_EXIST');
    fnd_message.raise_error;
  end if;
end chk_rule_key;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_rule_type         >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the rule type is one of the following:
--      ame_util.combinationRuleType
--      ame_util.authorityRuleType
--      ame_util.exceptionRuleType
--      ame_util.listModRuleType
--      ame_util.substitutionRuleType
--      ame_util.preListGroupRuleType
--      ame_util.postListGroupRuleType
--      ame_util.productionRuleType
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_rule_id
--   p_object_version_number
--   p_rule_type
--
-- Post Success:
--   Processing continues if attribute type is valid.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_rule_type
  (p_rule_id   in number,
   p_object_version_number in number,
   p_rule_type in ame_rules.rule_type%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_rule_type';
begin
  if not (p_rule_type = ame_util.combinationRuleType or
          p_rule_type =  ame_util.authorityRuleType or
          p_rule_type =  ame_util.exceptionRuleType or
          p_rule_type =  ame_util.listModRuleType or
          p_rule_type =  ame_util.substitutionRuleType or
          p_rule_type =  ame_util.preListGroupRuleType or
          p_rule_type =  ame_util.postListGroupRuleType or
          p_rule_type =  ame_util.productionRuleType) then
     fnd_message.set_name('PER','AME_400468_RULE_TYPE_INVALID');
     fnd_message.raise_error;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'RULE_TYPE') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_rule_type;
--+
--  ---------------------------------------------------------------------------
--  |----------------------<chk_item_class_and_rule_type >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--  Errors out if the item class id is not null for LM/Sub rules.
--  Errors out if the item class is not header for production rules.
--  Errors out if the item class is null for other rule types except comb.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   rule_type
--   p_item_class_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_item_class_and_rule_type(p_item_class_id in number
                                      ,p_rule_type     in number) is

  cursor getItemClassName(p_item_class_id in number) is
  select name
    from ame_item_classes
   where sysdate between start_date and nvl(end_date-(1/84600),sysdate)
     and item_class_id = p_item_class_id;
  l_item_class_name   ame_item_classes.name%type;

begin

  if (p_rule_type =  ame_util.listModRuleType or
      p_rule_type =  ame_util.substitutionRuleType) then
    if p_item_class_id is not null then
      fnd_message.set_name('PER','AME_400722_INV_IC_LM_SUB_RULE');
      fnd_message.raise_error;
    end if;
  elsif p_rule_type =  ame_util.combinationRuleType then
    null;
  elsif p_item_class_id is null then
    fnd_message.set_name('PER','AME_400472_INV_ITEM_CLASS');
    fnd_message.raise_error;
  end if;

end chk_item_class_and_rule_type;
--  ---------------------------------------------------------------------------
--  |----------------------< chk_start_end_date_combination >-----------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that 1. start_date is greater than effective date
--                  2. end_date is either null or greater than start_date.
--                  3. end_date is either null or greater than effective date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_rule_id
--   p_effective_date
--   p_object_version_number
--   p_start_date
--   p_end_date
--
-- Post Success:
--   Processing continues if start date end date combination are valid
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_start_end_date_combination
  (p_rule_id   in number,
   p_object_version_number in number,
   p_effective_date        in date,
   p_start_date in ame_rules.start_date%type,
   p_end_date in ame_rules.end_date%type) is
  l_proc              varchar2(72)  :=  g_package||'chk_start_end_date_combination';
begin
  if(p_start_date is null or
     p_start_date < p_effective_date ) then
     fnd_message.set_name('PER','AME_400208_RUL_STRT_PREC_TDY');
     fnd_message.raise_error;
  end if;
  if p_end_date is not null then
    if ( p_end_date < p_start_date or
         p_end_date < p_effective_date) then
     fnd_message.set_name('PER','AME_400209_RUL_STRT_PREC_END');
     fnd_message.raise_error;
    end if;
  end if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'START_DATE') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_start_end_date_combination;
--
--  ---------------------------------------------------------------------------
--  |----------------------<     chk_delete        >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {sTARt Of Comments}
--
-- Description:
--   check that 1. No rule Usages exist
--              2. No condition  Usages exist
--              3. No action  Usages exist
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_rule_id
--   p_object_version_number
--   p_effective_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_delete
  (p_rule_id   in number,
   p_object_version_number in number,
   p_effective_date        in date) is
  l_proc              varchar2(72)  :=  g_package||'chk_delete';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_rule_usages
      where
        rule_id = p_rule_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  cursor c_sel2 is
    select null
      from ame_condition_usages
      where
        rule_id = p_rule_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  cursor c_sel3 is
    select null
      from ame_action_usages
      where
        rule_id = p_rule_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  -- ame_rule_usages
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%found then
    close c_sel1;
    fnd_message.set_name('PER','AME_400216_RUL_IN_USE');
    fnd_message.raise_error;
  end if;
  close c_sel1;
  -- ame_condition_usages
  open c_sel2;
  fetch  c_sel2 into l_exists;
  if c_sel2%found then
    close c_sel2;
    fnd_message.set_name('PER','AME_400216_RUL_IN_USE');
    fnd_message.raise_error;
  end if;
  close c_sel2;
  -- ame_action_usages
  open c_sel3;
  fetch  c_sel3 into l_exists;
  if c_sel3%found then
    close c_sel3;
    fnd_message.set_name('PER','AME_400216_RUL_IN_USE');
    fnd_message.raise_error;
  end if;
  close c_sel3;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ATTRIBUTE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_delete;
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
  ,p_rec             in ame_rul_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_rul_shd.api_updating
      (p_rule_id =>  p_rec.rule_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- checks to ensure non-updateable args have not been updated.
  --
  if (ame_rul_shd.g_old_rec.rule_key <> p_rec.rule_key) then
     fnd_message.set_name('PER', 'AME_400467_NON_UPDATEABLE_FIELD');
     fnd_message.set_token('FIELD_NAME ', 'RULE_KEY');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  end if;
  if (ame_rul_shd.g_old_rec.rule_type <> p_rec.rule_type) then
     fnd_message.set_name('PER', 'AME_400467_NON_UPDATEABLE_FIELD');
     fnd_message.set_token('FIELD_NAME ', 'RULE_TYPE');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  end if;
  if (ame_rul_shd.g_old_rec.item_class_id <> p_rec.item_class_id) then
     fnd_message.set_name('PER', 'AME_400467_NON_UPDATEABLE_FIELD');
     fnd_message.set_token('FIELD_NAME ', 'ITEM_CLASS_ID');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
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
  (p_rule_id                          in number
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
      ,p_argument       => 'rule_id'
      ,p_argument_value => p_rule_id
      );
    --
  ame_rul_shd.child_rows_exist
(p_rule_id => p_rule_id
,p_start_date => p_validation_start_date
,p_end_date   => p_validation_end_date);
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
  (p_rec                   in ame_rul_shd.g_rec_type
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
  ame_rul_bus.chk_description
      (p_rule_id   => p_rec.rule_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_effective_date => p_effective_date
      ,p_description => p_rec.description);
  if p_rec.item_class_id is not null then
    ame_rul_bus.chk_item_class_id
      (p_rule_id   => p_rec.rule_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_effective_date => p_effective_date
      ,p_item_class_id => p_rec.item_class_id
      ,p_rule_type => p_rec.rule_type);
  end if;

  ame_rul_bus.chk_item_class_and_rule_type(p_item_class_id => p_rec.item_class_id
                                          ,p_rule_type     => p_rec.rule_type);

  ame_rul_bus.chk_rule_type
      (p_rule_id   => p_rec.rule_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_rule_type => p_rec.rule_type);
  --
  -- Validate Dependent Attributes
  --
  ame_rul_bus.chk_start_end_date_combination
      (p_rule_id   => p_rec.rule_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_effective_date => p_effective_date
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date);
  --
  ame_rul_bus.chk_rule_key(p_rule_key => p_rec.rule_key);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_rul_shd.g_rec_type
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
  --+
  ame_rul_bus.chk_description
      (p_rule_id   => p_rec.rule_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_effective_date => p_effective_date
      ,p_description => p_rec.description);
  --+
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
  ame_rul_bus.chk_start_end_date_combination
      (p_rule_id   => p_rec.rule_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_effective_date => p_effective_date
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date);
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_rul_shd.g_rec_type
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
    ,p_rule_id =>  p_rec.rule_id
    );
  --
  ame_rul_bus.chk_delete
      (p_rule_id   => p_rec.rule_id
      ,p_object_version_number => p_rec.object_version_number
      ,p_effective_date => p_effective_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_rul_bus;

/
