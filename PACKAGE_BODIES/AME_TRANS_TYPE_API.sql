--------------------------------------------------------
--  DDL for Package Body AME_TRANS_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_TRANS_TYPE_API" as
/* $Header: amacaapi.pkb 120.3.12010000.3 2019/09/11 13:12:03 jaakhtar ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'AME_TRANS_TYPE_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------< CREATE_AME_TRANSACTION_TYPE >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_transaction_type
  (p_validate              in     boolean  default false
  ,p_language_code         in     varchar2 default hr_api.userenv_lang
  ,p_application_name      in     varchar2
  ,p_fnd_application_id    in     number
  ,p_transaction_type_id   in     varchar2
  ,p_application_id           out nocopy number
  ,p_object_version_number    out nocopy number
  ,p_start_date               out nocopy date
  ,p_end_date                 out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor getMandatoryAttributesCur is
   select ame_attributes.attribute_id,
          ame_attributes.attribute_type
     from ame_attributes,
          ame_mandatory_attributes
    where ame_attributes.attribute_id = ame_mandatory_attributes.attribute_id
      and ame_mandatory_attributes.action_type_id = -1
      and sysdate between ame_attributes.start_date and
            nvl(ame_attributes.end_date - (1/86400), sysdate)
      and sysdate between ame_mandatory_attributes.start_date and
            nvl(ame_mandatory_attributes.end_date - (1/86400), sysdate);
  cursor getHeaderItemId is
    select item_class_id
      from ame_item_classes
     where name = ame_util.headerItemClassName
       and sysdate between start_date and
             nvl(end_date - (1/86400), sysdate);
  type attribTypeList is table of ame_attributes.attribute_type%type
                         index by binary_integer;
  l_proc                      varchar2(72) := g_package||'create_ame_transaction_type';
  l_swi_pkg_name              varchar2(72) := 'AME_TRANS_TYPE_SWI';
  l_application_id            number;
  l_object_version_number     number;
  l_ovn_child                 number;
  l_header_item_class_id      number;
  l_start_date                date;
  l_end_date                  date;
  l_start_date_child          date;
  l_end_date_child            date;
  l_attributeIds              ame_util.idList;
  l_attributeTypes            attribTypeList;
  l_queryString               varchar2(5);
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint create_ame_transaction_type;
    --
    -- Remember IN OUT parameter IN values. None here.
    --
    -- Call Before Process User Hook
    --
    begin
      ame_trans_type_bk1.create_ame_transaction_type_b
                         (p_application_name      => p_application_name
                         ,p_fnd_application_id    => p_fnd_application_id
                         ,p_transaction_type_id   => p_transaction_type_id
                         );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error(p_module_name => 'create_ame_transaction_type'
                                          ,p_hook_type   => 'BP'
                                          );
    end;
    --
    -- Process Logic
    --
    ame_aca_ins.ins(p_effective_date                => sysdate
                   ,p_fnd_application_id            => p_fnd_application_id
                   ,p_application_name              => p_application_name
                   ,p_transaction_type_id           => p_transaction_type_id
                   ,p_line_item_id_query            => null
                   ,p_security_group_id             => null
                   ,p_application_id                => l_application_id
                   ,p_object_version_number         => l_object_version_number
                   ,p_start_date                    => l_start_date
                   ,p_end_date                      => l_end_date
                   );
    --
    -- Create TL Data.
    --
    ame_cal_ins.ins_tl(p_language_code     => p_language_code
                      ,p_application_id    => l_application_id
                      ,p_application_name  => p_application_name
                      );
    --
    -- If the call is NOT made through SWI package,call all auxiliary APIs.
    --
    --if (instr(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_pkg_name) = 0) then --Bug #30281732
	  if (instr(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_pkg_name) = 0) then --Bug #30281732
      --
      -- Create Header Item Class Usage
      --
      open getHeaderItemId;
      fetch getHeaderItemId into l_header_item_class_id;
      close getHeaderItemId;
      ame_item_class_api.create_ame_item_class_usage
        (p_validate                => p_validate
        ,p_item_id_query           => 'select :transactionId from dual'
        ,p_item_class_order_number => 1
        ,p_item_class_par_mode     => ame_util.serialItems
        ,p_item_class_sublist_mode => ame_util.serialSublists
        ,p_application_id          => l_application_id
        ,p_item_class_id           => l_header_item_class_id
        ,p_object_version_number   => l_ovn_child
        ,p_start_date              => l_start_date_child
        ,p_end_date                => l_end_date_child
        );
      --
      -- Create ATTRIBUTE USAGEs
      --
      open getMandatoryAttributesCur;
      fetch getMandatoryAttributesCur bulk collect into l_attributeIds,
                                                        l_attributeTypes;
      close getMandatoryAttributesCur;
      for indx in 1..l_attributeIds.count
      loop
        if(LOWER(l_attributeTypes(indx)) = 'boolean') then
          l_queryString := ame_util.booleanAttributeFalse;
        else
          l_queryString := null;
        end if;
        ame_attribute_api.create_ame_attribute_usage
          (p_validate              => p_validate
          ,p_attribute_id          => l_attributeIds(indx)
          ,p_application_id        => l_application_id
          ,p_is_static             => ame_util.booleanTrue
          ,p_query_string          => l_queryString
          ,p_object_version_number => l_ovn_child
          ,p_start_date            => l_start_date_child
          ,p_end_date              => l_end_date_child
          );
      end loop;
      --
    end if;
    --
    -- Call After Process User Hook
    --
    begin
      ame_trans_type_bk1.create_ame_transaction_type_a
                   (p_application_name              => p_application_name
                   ,p_fnd_application_id            => p_fnd_application_id
                   ,p_transaction_type_id           => p_transaction_type_id
                   ,p_application_id                => l_application_id
                   ,p_object_version_number         => l_object_version_number
                   ,p_start_date                    => l_start_date
                   ,p_end_date                      => l_end_date
                   );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error(p_module_name => 'create_ame_transaction_type'
                                          ,p_hook_type   => 'AP'
                                          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values
    --
    p_application_id            := l_application_id;
    p_object_version_number     := l_object_version_number;
    p_start_date                := l_start_date;
    p_end_date                  := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to create_ame_transaction_type;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      p_application_id         := null;
      p_object_version_number  := null;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to create_ame_transaction_type;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_application_id         := null;
      p_object_version_number  := null;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end create_ame_transaction_type;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< UPDATE_AME_TRANSACTION_TYPE >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_transaction_type
  (p_validate                    in     boolean  default false
  ,p_language_code               in     varchar2 default hr_api.userenv_lang
  ,p_application_name            in     varchar2 default hr_api.g_varchar2
  ,p_application_id              in     number
  ,p_object_version_number       in out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'update_ame_transaction_type';
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_ame_transaction_type;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_trans_type_bk2.update_ame_transaction_type_b
        (p_application_name      => p_application_name
        ,p_application_id        => p_application_id
        ,p_object_version_number => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error(p_module_name => 'update_ame_transaction_type'
                                          ,p_hook_type   => 'BP'
                                          );
    end;
    --
    -- Process Logic
    --
    /*ame_aca_upd.upd(p_effective_date        => sysdate
                   ,p_datetrack_mode        => hr_api.g_update
                   ,p_application_id        => p_application_id
                   ,p_object_version_number => p_object_version_number
                   ,p_line_item_id_query    => hr_api.g_varchar2
                   ,p_security_group_id     => hr_api.g_number
                   ,p_start_date            => l_start_date
                   ,p_end_date              => l_end_date
                   );*/
    --
    -- Call the _TL layer update
    --
    ame_cal_upd.upd_tl(p_language_code     => p_language_code
                      ,p_application_id    => p_application_id
                      ,p_application_name  => p_application_name
                      );
    --
    -- Call After Process User Hook
    --
    begin
      ame_trans_type_bk2.update_ame_transaction_type_a
        (p_application_name      => p_application_name
        ,p_application_id        => p_application_id
        ,p_object_version_number => p_object_version_number
        ,p_start_date            => l_start_date
        ,p_end_date              => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error(p_module_name => 'update_ame_transaction_type'
                                          ,p_hook_type   => 'AP'
                                          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date   := l_start_date;
    p_end_date     := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to update_ame_transaction_type;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to update_ame_transaction_type;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end update_ame_transaction_type;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< DELETE_AME_TRANSACTION_TYPE >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_transaction_type
  (p_validate               in     boolean  default false
  ,p_application_id         in     number
  ,p_object_version_number  in out nocopy number
  ,p_start_date                out nocopy date
  ,p_end_date                  out nocopy date
  ) is
  --
  -- Declare cursors and local variables
  --
  cursor getRuleUsageCur is
    select rule_id,
           start_date,
           end_date,
           object_version_number
      from ame_rule_usages
     where item_id = p_application_id
       and ((sysdate between start_date
                         and nvl(end_date - ame_util.oneSecond, sysdate)) or
            (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  cursor getAttributeUsageCur is
    select atu.attribute_id,
           atu.object_version_number
      from ame_attribute_usages atu
          ,ame_attributes att
     where application_id = p_application_id
       and att.attribute_id = atu.attribute_id
       and sysdate between atu.start_date and
             nvl(atu.end_date - ame_util.oneSecond, sysdate)
       and sysdate between att.start_date and
             nvl(att.end_date - ame_util.oneSecond, sysdate);
  cursor getItemClassUsageCur is
    select item_class_id,
           object_version_number
      from ame_item_class_usages
     where application_id = p_application_id
       and sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate);
  cursor getApprovalGroupConfigCur is
    select approval_group_id,
           object_version_number
      from ame_approval_group_config
     where application_id = p_application_id
       and sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate);
  cursor getActionTypesConfigCur is
    select action_type_id,
           object_version_number
      from ame_action_type_config
     where application_id = p_application_id
       and sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate);
  cursor getConfigVarsCur is
    select variable_name,
           object_version_number
      from ame_config_vars
     where application_id = p_application_id
       and sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate);
  type varsList is table of ame_config_vars.variable_name%type
                   index by binary_integer;
  l_proc                   varchar2(72) := g_package||'delete_ame_transaction_type';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  l_start_date_child       date;
  l_end_date_child         date;
  l_ruleIds                ame_util.idList;
  l_ruleStartDates         ame_util.dateList;
  l_ruleEndDates           ame_util.dateList;
  l_attributeIds           ame_util.idList;
  l_itemClassIds           ame_util.idList;
  l_approvalGroupIds       ame_util.idList;
  l_actionTypeIds          ame_util.idList;
  l_configVarsList         varsList;
  l_objectVersionNumbers   ame_util.idList;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint delete_ame_transaction_type;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_trans_type_bk3.delete_ame_transaction_type_b
        (p_application_id           => p_application_id
        ,p_object_version_number    => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error(p_module_name => 'delete_ame_transaction_type'
                                          ,p_hook_type   => 'BP'
                                          );
    end;
    --
    -- Remove RULE_USAGESs
    --
    open getRuleUsageCur;
    fetch getRuleUsageCur bulk collect into l_ruleIds,
                                            l_ruleStartDates,
                                            l_ruleEndDates,
                                            l_objectVersionNumbers;
    close getRuleUsageCur;
    for indx in 1..l_ruleIds.count
    loop
      ame_rule_api.delete_ame_rule_usage
        (p_validate              => p_validate
        ,p_rule_id               => l_ruleIds(indx)
        ,p_application_id        => p_application_id
        ,p_object_version_number => l_objectVersionNumbers(indx)
        ,p_start_date            => l_ruleStartDates(indx)
        ,p_end_date              => l_ruleEndDates(indx)
        );
    end loop;
    --
    -- Remove ATTRIBUTES_USAGEs
    --
    open getAttributeUsageCur;
    fetch getAttributeUsageCur bulk collect into l_attributeIds,
                                                 l_objectVersionNumbers;
    close getAttributeUsageCur;
    for indx in 1..l_attributeIds.count
    loop
      ame_attribute_api.delete_ame_attribute_usage
        (p_validate              => p_validate
        ,p_attribute_id          => l_attributeIds(indx)
        ,p_application_id        => p_application_id
        ,p_object_version_number => l_objectVersionNumbers(indx)
        ,p_start_date            => l_start_date_child
        ,p_end_date              => l_end_date_child
        );
    end loop;
    --
    -- Remove ITEM_CLASS_USAGEs
    --
    open getItemClassUsageCur;
    fetch getItemClassUsageCur bulk collect into l_itemClassIds,
                                                 l_objectVersionNumbers;
    close getItemClassUsageCur;
    for indx in 1..l_itemClassIds.count
    loop
      ame_item_class_api.delete_ame_item_class_usage
        (p_validate              => p_validate
        ,p_application_id        => p_application_id
        ,p_item_class_id         => l_itemClassIds(indx)
        ,p_object_version_number => l_objectVersionNumbers(indx)
        ,p_start_date            => l_start_date_child
        ,p_end_date              => l_end_date_child
        );
    end loop;
    --
    -- Remove APPROVAL_GROUP_CONFIGs
    --
    open getApprovalGroupConfigCur;
    fetch getApprovalGroupConfigCur bulk collect into l_approvalGroupIds,
                                                      l_objectVersionNumbers;
    close getApprovalGroupConfigCur;
    for indx in 1..l_approvalGroupIds.count
    loop
       ame_approver_group_api.delete_approver_group_config
         (p_validate              => p_validate
         ,p_approval_group_id     => l_approvalGroupIds(indx)
         ,p_application_id        => p_application_id
         ,p_object_version_number => l_objectVersionNumbers(indx)
         ,p_start_date            => l_start_date_child
         ,p_end_date              => l_end_date_child
         );
    end loop;
    --
    -- Remove ACTION_TYPE_CONFIGs
    --
    open getActionTypesConfigCur;
    fetch getActionTypesConfigCur bulk collect into l_actionTypeIds,
                                                    l_objectVersionNumbers;
    close getActionTypesConfigCur;
    for indx in 1..l_actionTypeIds.count
    loop
      ame_action_api.delete_ame_action_type_conf
        (p_validate              => p_validate
        ,p_action_type_id        => l_actionTypeIds(indx)
        ,p_application_id        => p_application_id
        ,p_object_version_number => l_objectVersionNumbers(indx)
        ,p_start_date            => l_start_date_child
        ,p_end_date              => l_end_date_child
        );
    end loop;
    --
    -- Remove CONFIG_VARS
    --
    open getConfigVarsCur;
    fetch getConfigVarsCur bulk collect into l_configVarsList,
                                             l_objectVersionNumbers;
    close getConfigVarsCur;
    for indx in 1..l_configVarsList.count
    loop
      ame_config_var_api.delete_ame_config_variable
        (p_validate              => p_validate
        ,p_application_id        => p_application_id
        ,p_variable_name         => l_configVarsList(indx)
        ,p_object_version_number => l_objectVersionNumbers(indx)
        ,p_start_date            => l_start_date_child
        ,p_end_date              => l_end_date_child
        );
    end loop;
    --
    -- Remove saved Test cases and associated details.
    --
    delete from ame_test_trans_att_values
     where application_id = p_application_id;
    delete from ame_test_transactions
     where application_id = p_application_id;
    --
    -- Process Logic
    --
    ame_aca_del.del(p_effective_date          => sysdate
                   ,p_datetrack_mode          => hr_api.g_delete
                   ,p_application_id          => p_application_id
                   ,p_object_version_number   => p_object_version_number
                   ,p_start_date              => l_start_date
                   ,p_end_date                => l_end_date
                   );
    --
    -- Call After Process User Hook
    --
    begin
      ame_trans_type_bk3.delete_ame_transaction_type_a
      (p_application_id          => p_application_id
      ,p_object_version_number   => p_object_version_number
      ,p_start_date              => l_start_date
      ,p_end_date                => l_end_date
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error(p_module_name => 'delete_ame_transaction_type'
                                          ,p_hook_type   => 'AP'
                                          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date  := l_start_date;
    p_end_date    := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to delete_ame_transaction_type;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to delete_ame_transaction_type;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end delete_ame_transaction_type;
end AME_TRANS_TYPE_API;

/
