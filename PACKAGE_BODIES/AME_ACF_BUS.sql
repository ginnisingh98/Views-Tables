--------------------------------------------------------
--  DDL for Package Body AME_ACF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACF_BUS" as
/* $Header: amacfrhi.pkb 120.5 2006/12/23 12:19:44 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_acf_bus.';  -- Global package name
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
  ,p_rec             in ame_acf_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_acf_shd.api_updating
      (p_action_type_id =>  p_rec.action_type_id
 ,p_application_id =>  p_rec.application_id
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
  (p_effective_date        in date,
   p_action_type_id   in number) is
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
    --  AT MESSAGE
    --  The action type id specified in invalid
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
--
--  ---------------------------------------------------------------------------
--  |----------------------<chk_application_id      >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the application_id is a foreign key to
--   ame_calling_apps.application_id.
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
procedure chk_application_id
  (p_effective_date        in date,
   p_application_id        in number
   ) is
  l_proc              varchar2(72)  :=  g_package||'chk_application_id';
  tempCount integer;
  cursor c_sel1 is
    select null
      from ame_calling_apps
      where
        application_id = p_application_id and
        p_effective_date between start_date and
                 nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  l_exists varchar2(1);
begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%notfound then
    close c_sel1;
    --  AT MESSAGE
    --  The transaction type specified is invalid
    fnd_message.set_name('PER','AME_400474_INV_APPLICATION_ID');
    fnd_message.raise_error;
  end if;
  close c_sel1;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'APPLICATION_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_application_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_unique >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the voting regime is one of the following:
--      ame_util.consensusVoting;
--      ame_util.firstApproverVoting;
--      ame_util.serializedVoting;
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--  p_voting_regime
--
-- Post Success:
--   Processing continues if voting regime is valid.
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
procedure chk_unique
  (p_application_id in number
  ,p_action_type_id IN number) is
  l_proc  varchar2(72)  :=  g_package||'chk_unique';
  l_count number;
begin
  SELECT count(action_type_id)
    INTO l_count
    FROM ame_action_type_config
    WHERE application_id = p_application_id
      AND action_type_id = p_action_type_id
      AND SYSDATE BETWEEN start_date
            AND nvl(end_date - (1/86400), sysdate);
  IF l_count <> 0 then
    fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
    fnd_message.set_token('TABLE_NAME','ame_action_type_config');
    fnd_message.raise_error;
  END if;
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
          (p_associated_column1 => 'APPLICATION_ID') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
END chk_unique;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_voting_regime>-------------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the voting regime is one of the following:
--      ame_util.consensusVoting;
--      ame_util.firstApproverVoting;
--      ame_util.serializedVoting;
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--  p_voting_regime
--
-- Post Success:
--   Processing continues if voting regime is valid.
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
procedure chk_voting_regime
  (p_voting_regime in varchar2
  ,p_action_type_id IN number) is
  l_proc  varchar2(72)  :=  g_package||'chk_voting_regime';
  l_rule_type number;
begin
  SELECT rule_type
    INTO l_rule_type
    FROM ame_action_type_usages
    WHERE action_type_id = p_action_type_id
    AND SYSDATE BETWEEN start_date and
          nvl(end_date - (1/86400), sysdate)
    AND ROWNUM < 2;
  --chain of authority(rule_type = 1) needs voting regime(not null)
  if ( l_rule_type = 1 AND
       ( p_voting_regime IS NULL OR
          p_voting_regime not in (ame_util.consensusVoting,
                                        ame_util.firstApproverVoting,
                                  ame_util.serializedVoting)
       )
     )then
     -- AT MESSAGE
     -- The voting regime specified is invalid
                 fnd_message.set_name('PER','AME_400564_APG_INVALID_VOT_REG');
     fnd_message.raise_error;
  end if;
 exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
          (p_associated_column1 => 'VOTING_REGIME') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_voting_regime;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_chain_ordering_mode>--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the chain ordering mode is one of the following:
--      ame_util.parallelChainsMode;
--      ame_util.serialChainsMode;
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_chain_ordering_mode
--
-- Post Success:
--   Processing continues if chain ordering mode is valid.
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
procedure chk_chain_ordering_mode
  (p_chain_ordering_mode in varchar2
  ,p_action_type_id IN number) is
  l_proc  varchar2(72)  :=  g_package||'chk_chain_ordering_mode';
  l_rule_type number;
begin
  SELECT rule_type
      INTO l_rule_type
      FROM ame_action_type_usages
      WHERE action_type_id = p_action_type_id
      AND SYSDATE BETWEEN start_date and
            nvl(end_date - (1/86400), sysdate)
      AND ROWNUM < 2;
  --chain of authority(rule_type = 1) requires non null chain ordering mode
  IF ( l_rule_type =1 AND
        (p_chain_ordering_mode IS NULL OR
          p_chain_ordering_mode not in (ame_util.parallelChainsMode,
                                              ame_util.serialChainsMode)
         )
      )then
     -- AT MESSAGE
     -- The chain ordering mode specified is invalid
     fnd_message.set_name('PER','AME_400576_INV_ACT_COA_MODE');
     fnd_message.raise_error;
  end if;
 exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
          (p_associated_column1 => 'CHAIN_ORDERING_MODE') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_chain_ordering_mode;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_order_number>-------------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   Validates that the order number is mandatory and in a valid range.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--  p_effective_date
--  p_order_number
--  p_application_id
--
-- Post Success:
--   Processing continues if order number is in a valid range.
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
procedure chk_order_number
  (p_effective_date in date,
         p_application_id in number,
         p_order_number   in number) is
  l_proc  varchar2(72)  :=  g_package||'chk_order_number';
  max_order_number integer;
begin
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'order_number'
    ,p_argument_value => p_order_number
    );
  /*select max(order_number + 1)
    into max_order_number
    from ame_action_type_config
    where
      application_id = p_application_id and
      p_effective_date between start_date and
        nvl(end_date - ame_util.oneSecond, p_effective_date) ;
  if(p_order_number not between 1 and max_order_number) then
     -- AT MESSAGE
     -- The order number specified is invalid
     fnd_message.set_name('PAY','HR_7200_INVALID_ORD_NUM');
     fnd_message.raise_error;
  end if;*/
  if(p_order_number < 1) then
     fnd_message.set_name('PER','AME_400565_INVALID_ORDER_NUM');
     fnd_message.raise_error;
  end if;
 exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
          (p_associated_column1 => 'ORDER_NUMBER') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
end chk_order_number;

--
--
--  ---------------------------------------------------------------------------
--  |----------------------<     chk_delete        >--------------------------|
--  ---------------------------------------------------------------------------
--
--  {Start Of Comments}
--
-- Description:
--   check that 1) An action type config containing action usage and rule
--                 usage cannot be deleted.
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
  (p_action_type_id   in number
  ,p_application_id   in number) is
  l_proc              varchar2(72)  :=  g_package||'chk_delete';
        cursor c_sel1 Is
    select null
      from ame_rule_usages aru
          ,ame_action_usages aau
          ,ame_actions act
          ,ame_action_types aty
      where aru.item_id = p_application_id
        and aau.rule_id = aru.rule_id
        and aau.action_id = act.action_id
        and act.action_type_id = aty.action_type_id
        and aty.action_type_id = p_action_type_id
        and sysdate between aru.start_date and
              nvl(aru.end_date - (1/86400), sysdate)
        and sysdate between aau.start_date and
              nvl(aau.end_date - (1/86400), sysdate)
        and sysdate between act.start_date and
              nvl(act.end_date - (1/86400), sysdate)
        and sysdate between aty.start_date and
              nvl(aty.end_date - (1/86400), sysdate);

   cursor c_sel2 is
     select null
       from ame_action_type_config acf
       where ame_utility_pkg.is_seed_user(acf.created_by) = ame_util.seededDataCreatedById
         and ame_utility_pkg.check_seeddb = 'N'
         and acf.action_type_id = p_action_type_id
         and acf.application_id = p_application_id
         and sysdate between acf.start_date and
              nvl(acf.end_date - (1/86400), sysdate);

        l_exists varchar2(1);

begin
  open c_sel1;
  fetch  c_sel1 into l_exists;
  if c_sel1%found then
    close c_sel1;
    -- AT MESSAGE
    -- An action type config of a TT containing active rule on it cannot be
    --deleted
    fnd_message.set_name('PER','AME_400595_SD_ACTTYPCFG_CN_DEL');
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
  (p_application_id                   in number
  ,p_action_type_id                   in number
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
  (p_rec                   in ame_acf_shd.g_rec_type
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
  -- Application Id
  chk_application_id(p_effective_date => p_effective_date,
                           p_application_id => p_rec.application_id);
  -- Action Type Id
  chk_action_type_id(p_effective_date => p_effective_date,
                           p_action_type_id => p_rec.action_type_id);
  --uniqueness
  chk_unique(p_application_id => p_rec.application_id,
             p_action_type_id => p_rec.action_type_id);
  -- Voting Regime
  chk_voting_regime(p_voting_regime => p_rec.voting_regime
                   ,p_action_type_id => p_rec.action_type_id);
  -- Chain Ordering Mode
  chk_chain_ordering_mode(p_chain_ordering_mode => p_rec.chain_ordering_mode
                   ,p_action_type_id => p_rec.action_type_id);
  -- Order Number
  /*chk_order_number(p_effective_date => p_effective_date,
                   p_application_id => p_rec.application_id,
                   p_order_number => p_rec.order_number);
  */
        -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_acf_shd.g_rec_type
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
  -- Voting Regime
  chk_voting_regime(p_voting_regime => p_rec.voting_regime
                   ,p_action_type_id => p_rec.action_type_id);
  -- Chain Ordering Mode
  chk_chain_ordering_mode(p_chain_ordering_mode => p_rec.chain_ordering_mode
                         ,p_action_type_id => p_rec.action_type_id);
  -- Order Number
  chk_order_number(p_effective_date => p_effective_date,
                   p_application_id => p_rec.application_id,
                   p_order_number => p_rec.order_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_acf_shd.g_rec_type
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
  chk_delete(p_action_type_id => p_rec.action_type_id
            ,p_application_id => p_rec.application_id);
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_action_type_id =>  p_rec.action_type_id
 ,p_application_id =>  p_rec.application_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_acf_bus;

/
