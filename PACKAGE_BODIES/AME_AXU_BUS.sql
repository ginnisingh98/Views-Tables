--------------------------------------------------------
--  DDL for Package Body AME_AXU_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_AXU_BUS" as
/* $Header: amaxurhi.pkb 120.3 2005/11/22 03:14 santosin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_axu_bus.';  -- Global package name
--
--  ---------------------------------------------------------------------------
--  |----------------------<chk_action_type_id      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the action_type_id is a foreign key to ame_action_types.action_type_id.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_action_type_id
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
procedure chk_action_type_id
  (p_action_type_id   in number,
   p_effective_date        in date) is
  l_proc              varchar2(72)  :=  g_package||'chk_action_type_id';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_action_types
      where
        action_type_id = p_action_type_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%notfound then
    close c_sel1;
    -- AT MESSAGE
    -- The action type id specified is invalid
    fnd_message.set_name('PER','AME_400575_ACT_TYP_NOT_EXIST');
    fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ACTION_TYPE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_action_type_id;
--  ---------------------------------------------------------------------------
--  |----------------------< chk_usage_already_exists >-----------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that an action type can have only one usage
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_action_type_id
--
-- Post Success:
--   Processing continues if action type does not already have a usage
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
----
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_usage_already_exists
  (p_action_type_id in number) is
  l_proc  varchar2(72)  :=  g_package||'chk_usage_already_exists';
  l_count number;
begin
  SELECT count(action_type_id)
    INTO l_count
    FROM ame_action_type_usages
    WHERE action_type_id = p_action_type_id
      AND SYSDATE BETWEEN start_date AND
            nvl(end_date - (1/86400), sysdate);
  if l_count <> 0 then
     -- AT MESSAGE
     -- The action type already has an usage
     fnd_message.set_name('PER','AME_400663_ACT_USG_EXISTS');
     fnd_message.raise_error;
  end if;
 exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
          (p_associated_column1 => 'ACTION_TYPE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_usage_already_exists;
--  ---------------------------------------------------------------------------
--  |----------------------< chk_rule_type>------------------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the rule type is one of the following:
--      combinationRuleType constant integer := 0;
--      authorityRuleType constant number := 1;
--      exceptionRuleType constant number := 2;
--      listModRuleType constant number := 3;
--      substitutionRuleType constant number := 4;
--      preListGroupRuleType constant number := 5;
--      postListGroupRuleType constant number := 6;
--      productionRuleType constant integer := 7;
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_rule_type
--
-- Post Success:
--   Processing continues if dynamic description is valid.
--
-- Post Failure:
--   Log the error message.
--
-- Developer Implementation Notes:
--   None.
----
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_rule_type
  (p_rule_type in number) is
  l_proc  varchar2(72)  :=  g_package||'chk_rule_type';
begin
  --added the mand arg error code to fix bug 4402340
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                        ,p_argument       => 'rule_type'
                        ,p_argument_value => p_rule_type
                        );
  if p_rule_type not in (
                         ame_util.authorityRuleType,
                         ame_util.listModRuleType,
                         ame_util.substitutionRuleType,
                         ame_util.preListGroupRuleType,
                         ame_util.postListGroupRuleType,
                         ame_util.productionRuleType) then
     -- AT MESSAGE
     -- The rule type specified is not valid
     fnd_message.set_name('PER','AME_400638_INVALID_RULE_TYPE');
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
  ,p_rec             in ame_axu_shd.g_rec_type
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
  IF NOT ame_axu_shd.api_updating
      (p_action_type_id =>  p_rec.action_type_id
 ,p_rule_type =>  p_rec.rule_type
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
End chk_non_updateable_args;
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<     chk_delete        >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   check that 1) An action type usage of a seeded action type cannot be deleted.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_action_type_id
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
  (p_action_type_id   in number) is
  l_proc              varchar2(72)  :=  g_package||'chk_delete';
	cursor c_sel1 Is
    select null
      from ame_action_types
      where
		    action_type_id = p_action_type_id and
        ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById and
        ame_utility_pkg.check_seeddb = 'N';
	l_exists varchar2(1);
begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%found then
    close c_sel1;
    -- AT MESSAGE
    -- An action type usage of a seeded action type cannot be deleted.
    fnd_message.set_name('PER','AME_400598_SD_ACTTYPUSG_CN_DEL');
    fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'ACTION_TYPE_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_delete;
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
  (p_action_type_id                   in number
  ,p_rule_type                        in number
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
      ,p_argument       => 'action_type_id'
      ,p_argument_value => p_action_type_id
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
  (p_rec                   in ame_axu_shd.g_rec_type
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
  -- Action Type Id
  chk_action_type_id(p_effective_date => p_effective_date,
                     p_action_type_id => p_rec.action_type_id);
  chk_usage_already_exists
  (p_action_type_id => p_rec.action_type_id);
  --
  chk_rule_type(p_rule_type => p_rec.rule_type);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_axu_shd.g_rec_type
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
  (p_rec                    in ame_axu_shd.g_rec_type
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
  chk_delete(p_action_type_id => p_rec.action_type_id);
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_action_type_id =>  p_rec.action_type_id
 ,p_rule_type =>  p_rec.rule_type
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_axu_bus;

/
