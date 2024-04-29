--------------------------------------------------------
--  DDL for Package Body AME_GCF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_GCF_BUS" as
/* $Header: amgcfrhi.pkb 120.5 2006/10/05 16:08:09 pvelugul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_gcf_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_APPROVER_TYPE >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure checks if the approver group consists of members of approver
--  type not allowed in the current transaction type.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_id
--   p_approval_group_id
--
-- Post Success:
--   Processing continues if a valid application_id has been entered.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_approver_type(p_application_id      in   number
                           ,p_approval_group_id   in   number
                                 ) IS
--
  l_proc           varchar2(72) := g_package || 'CHK_APPROVER_TYPE';
  l_count          number;
  l_config_value   ame_config_vars.variable_value%type;
  l_group_name     ame_approval_groups.name%type;
  --
  -- cursor to find the value of allowAllApproverTypes config variable for the
  -- current transaction type.
  --
  cursor C_Sel1 is
    select variable_value
      from ame_config_vars
     where variable_name like 'allowAllApproverTypes'
       and application_id = p_application_id
       and sysdate between start_date and
           nvl(end_date-ame_util.oneSecond,SYSDATE);
  --
  -- cursor to find if the approver group consists of group members of approver
  -- type not allowed in the current transaction type.
  --
  cursor C_Sel2 is
    select count(*)
      from ame_approval_group_members
     where approval_group_id = p_approval_group_id
       and orig_system not in ('FND_USR','PER');
Begin
    hr_utility.set_location('Entering:'||l_proc,10);

    -- find the value of config variable allowAllApproverTypes for the current
    -- transaction type
    open C_Sel1;
    fetch C_Sel1 into l_config_value;
    if C_Sel1%notfound then
      -- if the config variable is not defined for the current transaction type
      -- use the global value
      select variable_value into l_config_value
        from ame_config_vars
       where variable_name like 'allowAllApproverTypes'
         and application_id = 0
         and sysdate between start_date and
             nvl(end_date-ame_util.oneSecond,SYSDATE);
    end if;
    close C_Sel1;
    -- if all approver types are allowed for the current transaction ,then return
    if l_config_value = 'yes' then
      return;
    end if;
    -- find if the approver group has members of approver type other than 'PER'
    -- and 'FND_USR'
  open C_Sel2;
  fetch C_Sel2 into l_count;
  close C_Sel2;
  if l_count <> 0 then
    select name into l_group_name
      from ame_approval_groups
     where approval_group_id = p_approval_group_id
       and sysdate between start_date and
           nvl(end_date-ame_util.oneSecond,SYSDATE)
       and rownum < 2;
    fnd_message.set_name('PER','AME_400617_APG_INV_APPR_TYPE');
    fnd_message.set_token('GRP_NAME',l_group_name);
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_CONFIG.APPLICATION_ID'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
end chk_approver_type;

-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_DELETE >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure checks if any rule in the current transaction type
--  uses an action based on the group config to be deleted.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_application_id
--   p_approval_group_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid application_id has been entered.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_delete(p_application_id      in   number
                    ,p_approval_group_id   in   number
                    ,p_effective_date      in   date
                            ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_DELETE';
  l_count    number;
  --
  -- cursor to find if any rules using this group action
  -- has usage for this transaction type
  --
  cursor C_Sel1 is
    select count(*)
      from ame_action_types aty
          ,ame_actions act
          ,ame_rule_usages aru
          ,ame_action_usages actu
      where aty.name in ( ame_util.preApprovalTypeName
                       ,ame_util.postApprovalTypeName
                       ,ame_util.groupChainApprovalTypeName
                      )
        and aty.action_type_id = act.action_type_id
        and act.parameter = to_char(p_approval_group_id)
        and aru.item_id = p_application_id
        and actu.rule_id = aru.rule_id
        and actu.action_id = act.action_id
        and p_effective_date between aty.start_date and
            nvl(aty.end_date,p_effective_date)
        and p_effective_date between act.start_Date and
            nvl(act.end_date,p_effective_date)
        and ((p_effective_date between aru.start_date and
              nvl(aru.end_date - ame_util.oneSecond, p_effective_date)) or
             (p_effective_date < aru.start_date and
              aru.start_date < nvl(aru.end_date,aru.start_date + ame_util.oneSecond)))
        and ((p_effective_date between actu.start_date and
              nvl(actu.end_date - ame_util.oneSecond, p_effective_date)) or
             (p_effective_date < actu.start_date and
              actu.start_date < nvl(actu.end_date,actu.start_date + ame_util.oneSecond)));

  cursor c_sel2 is
    select null
      from ame_approval_group_config
      where ame_utility_pkg.check_seeddb = 'N'
        and approval_group_id = p_approval_group_id
        and application_id = p_application_id
        and ame_utility_pkg.is_seed_user(created_by) = ame_util.seededDataCreatedById
        and p_effective_date between start_date
              and nvl(end_date - (1/86400), p_effective_date);
Begin
    hr_utility.set_location('Entering:'||l_proc,10);

    -- Check if the group action is being used by an active rule in
    --current transaction type.
    open C_Sel1;
    fetch C_Sel1 into l_count;
    close C_Sel1;
    if l_count <> 0 then
      fnd_message.set_name('PER','AME_400558_RULES_EXIST_FOR_APG');
      fnd_message.raise_error;
    end if;

    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_CONFIG.APPLICATION_ID'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
end chk_delete;


-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_APPLICATION_ID >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the application_id.
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
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_application_id(p_application_id      in   number
                            ,p_effective_date      in   date
                            ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_APPLICATION_ID';
  l_count    number;
--
-- Cursor to find if application_id exists in ame_calling_apps
--
  Cursor C_Sel1 Is
    select count(application_id)
    from   ame_calling_apps t
    where t.application_id = p_application_id
    and p_effective_date between t.start_date and nvl(t.end_date-(1/84600),sysdate);

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'APPLICATION_ID'
                              ,p_argument_value     => p_application_id
                              );
    -- Check if the application_id is existing in ame_calling_apps.
    open C_Sel1;
    fetch C_Sel1 into l_count;
    close C_Sel1;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400474_INV_APPLICATION_ID');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_CONFIG.APPLICATION_ID'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_application_id;


-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_APPROVAL_GROUP_ID >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the approval_group_id.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_approval_group_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid approval_group_id has been entered.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_approval_group_id(p_approval_group_id   in   number
                               ,p_effective_date      in   date
                               ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_APPROVAL_GROUP_ID';
  l_count    number;
--
-- Cursor to find if approval_group_id exists in ame_approval_groups
--
  Cursor C_Sel1 Is
    select count(approval_group_id)
    from   ame_approval_groups t
    where t.approval_group_id = p_approval_group_id
    and p_effective_date between t.start_date and t.end_date;

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'APPROVAL_GROUP_ID'
                              ,p_argument_value     => p_approval_group_id
                              );
    -- Check if the approval_group_id is existing in ame_approval_groups.
    open C_Sel1;
    fetch C_Sel1 into l_count;
    close C_Sel1;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400557_INVALID_APG_ID');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_CONFIG.APPROVAL_GROUP_ID'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_approval_group_id;


-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_VOTING_REGIME >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the voting_regime value which should be in (C,F,O,S)
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_voting_regime
--
-- Post Success:
--   Processing continues if a valid voting_regime has been entered.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_voting_regime(p_voting_regime       in   varchar2
                           ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_VOTING_REGIME';
--

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'VOTING_REGIME'
                              ,p_argument_value     => p_voting_regime
                              );
    -- Check if the voting_regime has value in ('C','F','O','S').
    if p_voting_regime not in ('C','F','O','S') then
      fnd_message.set_name('PER','AME_400564_APG_INVALID_VOT_REG');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_CONFIG.VOTING_REGIME'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_voting_regime;

-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_ORDER_NUMBER >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the order_number value which should be positive.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_order_number
--
-- Post Success:
--   Processing continues if a valid order_number has been entered.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_order_number(p_order_number       in   number
                           ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_ORDER_NUMBER';
--

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'ORDER_NUMBER'
                              ,p_argument_value     => p_order_number
                              );
    -- Check if the order number is negative
    if p_order_number <= 0 then
      fnd_message.set_name('PER','AME_400565_INVALID_ORDER_NUM');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_CONFIG.ORDER_NUMBER'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_order_number;

-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_UNIQUE >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the order_number value which should be positive.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_order_number
--
-- Post Success:
--   Processing continues if a valid order_number has been entered.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_unique(p_approval_group_id   in   number
                    ,p_application_id      in   number
                           ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_unique';
  l_count    number;
--
  cursor CSel1 is
    select count(*)
      from ame_approval_group_config
      where approval_group_id = p_approval_group_id
        and application_id = p_application_id
        and sysdate between start_date and end_date;

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    -- Check if the configuration already exists
    open CSel1;
    fetch CSel1 into l_count;
    close CSel1;
    if l_count <> 0 then
      fnd_message.set_name('PER','AME_400566_APG_CFG_EXISTS');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_CONFIG.APPLICATION_ID'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_unique;

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
  ,p_rec             in ame_gcf_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_gcf_shd.api_updating
      (p_approval_group_id =>  p_rec.approval_group_id
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
  ,p_approval_group_id                in number
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
      ,p_argument       => 'approval_group_id'
      ,p_argument_value => p_approval_group_id
      );
    --
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
  (p_rec                   in ame_gcf_shd.g_rec_type
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
  --
  -- User Entered calls to validate procedures
  chk_application_id (
                      p_application_id  => p_rec.application_id
                     ,p_effective_date  => p_effective_date
                     );
  chk_approval_group_id (
                         p_approval_group_id  => p_rec.approval_group_id
                        ,p_effective_date  => p_effective_date
                        );
  chk_unique (
              p_approval_group_id => p_rec.approval_group_id
             ,p_application_id    => p_rec.application_id
             );
  chk_approver_type (
                     p_application_id  => p_rec.application_id
                    ,p_approval_group_id  => p_rec.approval_group_id
                    );
  chk_voting_regime(
                   p_voting_regime => p_rec.voting_regime
                   );
/*  chk_order_number(
                   p_order_number  => p_rec.order_number
                  );*/
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_gcf_shd.g_rec_type
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

  -- User Entered calls to validate procedures
  chk_voting_regime(
                   p_voting_regime => p_rec.voting_regime
                   );
  chk_order_number(
                   p_order_number  => p_rec.order_number
                  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_gcf_shd.g_rec_type
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
    ,p_approval_group_id =>  p_rec.approval_group_id
 ,p_application_id =>  p_rec.application_id
    );
  chk_delete
    (p_application_id                   =>p_rec.application_id
    ,p_approval_group_id                => p_rec.approval_group_id
    ,p_effective_date                   => sysdate
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_gcf_bus;

/
