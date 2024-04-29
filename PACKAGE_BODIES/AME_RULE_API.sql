--------------------------------------------------------
--  DDL for Package Body AME_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RULE_API" as
/* $Header: amrulapi.pkb 120.4.12010000.4 2019/09/04 07:41:47 pkgandi ship $ */
--+
-- Package Variables
--+
g_package  varchar2(33) := '  ame_rule_api.';
--+
--   getConditionType Function
--+
--   This is a private function which returns the condition type
--+
function getConditionType(p_condition_id   in integer
                         ,p_effective_date in date) return varchar2 as
  l_condition_type ame_conditions.condition_type%type;
  begin
    select condition_type
      into l_condition_type
      from ame_conditions
     where ame_conditions.condition_id = p_condition_id
       and p_effective_date between start_date
            and nvl(end_date - ame_util.oneSecond, p_effective_date);
     return(l_condition_type);
   exception
     when others then
     fnd_message.set_name('PER','AME_400494_INVALID_CONDITION');
     hr_multi_message.add (p_associated_column1 => 'CONDITION_ID');
     raise;
     return(null);
end getConditionType;
--+
--   This is a private function which checks if any overlapping rule usages exist
--+
Function checkRuleUsageExists(p_application_id in integer
                             ,p_rule_id        in integer
                             ,p_rlu_start_date in date
                             ,p_rlu_end_date   in date     default null
                             ,p_effective_date in date
                             ,p_priority       in varchar2 default null
                             ,p_old_start_date in date     default null)
         return number as
  cursor ruleUsageCursor is
    select start_date
          ,end_date
          ,priority
      from ame_rule_usages
     where rule_id =p_rule_id
       and item_id = p_application_id
       and (p_effective_date between  start_date
             and nvl(end_date - ame_util.oneSecond, p_effective_date)
            or
           (p_effective_date < start_date
             and start_date < nvl(end_date, start_date + ame_util.oneSecond)))
     order by start_date desc;
  usagestartDateList ame_util.dateList;
  usageEndDateList   ame_util.dateList;
  usagePriorityList  ame_util.idList;
begin
  for ruleUsage in ruleUsageCursor loop
    if (p_old_start_date is null or
        p_old_start_date <> ruleUsage.start_date) then
      if ( trunc(p_rlu_start_date) = trunc(ruleUsage.start_date) and
           trunc(p_rlu_end_date) = trunc(ruleUsage.end_date)  and
           p_priority = ruleUsage.priority
          ) then
        return(1);
      elsif  ( trunc(p_rlu_start_date) = trunc(ruleUsage.start_date)  and
               trunc(p_rlu_end_date) = trunc(ruleUsage.end_date)
             ) then
        return(2);
      elsif (ruleUsage.end_date = ame_utility_pkg.endOfTime and p_rlu_end_date = ame_utility_pkg.endOfTime) then
        return(3);
      elsif ((p_rlu_end_date = ame_utility_pkg.endOfTime and p_rlu_start_date < ruleUsage.end_date)
          or
            ( ruleUsage.end_date = ame_utility_pkg.endOfTime and
                  (p_rlu_start_date >= ruleUsage.start_date
                 or p_rlu_end_date > ruleUsage.start_date))
          ) then
        return(3);
       elsif ( (p_rlu_start_date between  ruleUsage.start_date and
                    ruleUsage.end_date - ame_util.oneSecond)
         or
         (p_rlu_end_date  between  ruleUsage.start_date and
                    ruleUsage.end_date - ame_util.oneSecond)
         or
         (ruleUsage.start_date between p_rlu_start_date and
                    p_rlu_end_date - ame_util.oneSecond )
         or
         (ruleUsage.end_date - ame_util.oneSecond between p_rlu_start_date and
                    p_rlu_end_date - ame_util.oneSecond )
            ) then
        return(3);
      end if;
    end if;
  end loop;
  return(0);
exception
  when others then
     fnd_message.set_name('PER','AME_400329_RULE_USG_OVER_LIFE');
     hr_multi_message.add(p_associated_column1 =>'RULE_ID'
                         ,p_associated_column2 =>'ITEM_ID');
     raise;
     return(3);
end checkRuleUsageExists;
--+
-- This is a private function which checks if the transaction type
-- can have a usage for a rule.
--+
function checkRuleAllowed(p_application_id   in     number
                         ,p_rule_id          in     number
                         ,p_effective_date   in     date
                         ) return boolean as
  l_allowAllApproverTypes varchar2(30);
  l_allowProduction       varchar2(30);
  l_swi_package_name      varchar2(30) := 'AME_RULE_SWI';
  l_count                 number;
  actionTypeIds           ame_util.idList;
  l_rule_type             ame_rules.rule_type%type;
  applicationName         ame_calling_apps.application_name%type;
  --+
    cursor getApplicationName(applicationIdIn in integer)is
    select application_name
      from ame_calling_apps
     where application_id = applicationIdIn
       and sysdate between start_date and nvl(end_date - (1/86400), sysdate);
  --+
  cursor getActionTypeCursor is
    select ame_actions.action_type_id
      from ame_actions, ame_action_usages
     where ame_action_usages.rule_id = p_rule_id
       and ame_action_usages.action_id = ame_actions.action_id
       and (p_effective_date between ame_action_usages.start_date
             and nvl(ame_action_usages.end_date - ame_util.oneSecond, p_effective_date)
            or
           (p_effective_date < ame_action_usages.start_date
             and ame_action_usages.start_date < nvl(ame_action_usages.end_date, ame_action_usages.start_date + ame_util.oneSecond)))
       and p_effective_date between ame_actions.start_date
            and nvl(ame_actions.end_date - ame_util.oneSecond, p_effective_date) ;
begin
  --  Check the value of the config variable 'allowAllApproverTypes' and 'productionFunctionality'
  --  to ensure that rules of this type type can be defined for this transaction type.
  --
  l_allowAllApproverTypes :=
      ame_util.getConfigVar
        (variableNameIn  => ame_util.allowAllApproverTypesConfigVar
        ,applicationIdIn => p_application_id);
  l_allowProduction :=
      ame_util.getConfigVar(variableNameIn  => ame_util.productionConfigVar
                           ,applicationIdIn => p_application_id);
  --  get that rule type
  select rule_type
    into l_rule_type
    from ame_rules
   where rule_id =p_rule_id
     and (p_effective_date between  start_date
           and nvl(end_date - ame_util.oneSecond, p_effective_date )
          or
         (p_effective_date < start_date
           and start_date < nvl(end_date, start_date + ame_util.oneSecond)));
  --+
  -- Transform the configuration-variable value into one of the
  -- pseudo-boolean values used by configuration variables,
  -- for ease of use in the cursor.
  --+
  if l_allowAllApproverTypes = ame_util.no or
     l_allowProduction in (ame_util.noProductions, ame_util.perApproverProductions) then
    --+
    -- fetch the action_type_id's associated with this rule
    --+
    open getActionTypeCursor;
    fetch getActionTypeCursor bulk collect into actionTypeIds;
    if actionTypeIds.count = 0 then
      --+
      -- if this call is not made from an SWI package, raise an exception and return false
      --+
      if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
        fnd_message.set_name('PER','AME_400724_NO_ACTION_IN_RULE');
        hr_multi_message.add (p_associated_column1 =>'RULE_ID');
        return(false);
      else
        return(true);
      end if;
    end if;
    close getActionTypeCursor;
    --+
    -- Check that the action types are allowed for this transaction_type
    --+
    if l_rule_type not in (ame_util.productionRuleType
                          ,ame_util.preListGroupRuleType
                          ,ame_util.postListGroupRuleType) then
      if l_allowAllApproverTypes = ame_util.no then
        -- check if the action types defined are allowed to use approver types
        --  other than ame_util.perOrigSystem and ame_util.fndUserOrigSystem.
        for i in 1..actionTypeIds.count loop
          select count(*)
            into l_count
            from ame_approver_type_usages
            where approver_type_id not in (
                         select approver_type_id
                           from ame_approver_types
                          where orig_system in (ame_util.perOrigSystem
                                               ,ame_util.fndUserOrigSystem)
                            and sysdate between start_date
                                 and nvl(end_date - ame_util.oneSecond, sysdate))
              and action_type_id =  actionTypeIds(i)
              and sysdate between start_date
                   and nvl(end_date - ame_util.oneSecond, sysdate);
          if l_count <> 0 then
            return(false);
          end if;
        end loop;
      end if;
    end if;
    if l_allowProduction in (ame_util.noProductions
                            ,ame_util.perApproverProductions) then
      if l_rule_type = ame_util.productionRuleType then
        return(false);
      end if;
      -- If no productions then check that no production
      -- actions are defined for the rule.
      if l_allowProduction = ame_util.noProductions then
        for i in 1..actionTypeIds.count loop
          select count(*)
            into l_count
            from ame_action_type_usages
           where rule_type = ame_util.productionRuleType
             and action_type_id = actionTypeIds(i)
             and p_effective_date between  start_date
                  and nvl(end_date - ame_util.oneSecond, p_effective_date);
          if l_count <> 0 then
            open getApplicationName(applicationIdIn => p_application_id);
            fetch getApplicationName into applicationName;
            close getApplicationName;
            fnd_message.set_name('PER','AME_400640_TTY_NO_PROD_ACTIONS');
            fnd_message.set_token('TXTYPENAME',applicationName);
            hr_multi_message.add(p_associated_column1 =>'RULE_ID');
            return(false);
          end if;
        end loop;
      end if;
    end if;
  end if;
  return(true);
end checkRuleAllowed;
--+
--+
--+
procedure fetchNewRuleDates2(p_rule_id  in           number
                            ,p_rul_start_date    out nocopy date
                            ,p_rul_end_date      out nocopy date) as
begin
  select min(start_date)
    into p_rul_start_date
    from ame_rule_usages
   where rule_id = p_rule_id
     and (sysdate between  start_date
           and nvl(end_date - ame_util.oneSecond, sysdate )
          or
         (sysdate < start_date
           and start_date < nvl(end_date, start_date + ame_util.oneSecond)));
  select max(end_date)
    into p_rul_end_date
    from ame_rule_usages
   where rule_id = p_rule_id
     and (sysdate between  start_date
           and nvl(end_date - ame_util.oneSecond, sysdate )
          or
         (sysdate < start_date
           and start_date < nvl(end_date, start_date + ame_util.oneSecond)));
end fetchNewRuleDates2;
--+
-- This is a private function which checks if the Rule start date and end date need to
-- be changed.
--+
Procedure fetchNewRuleDates(p_rule_id        in     number
                           ,p_rlu_start_date in     date
                           ,p_rlu_end_date   in     date
                           ,p_rul_start_date in out nocopy date
                           ,p_rul_end_date   in out nocopy date
                           ,p_date_changed      out nocopy varchar2
                           ) as
begin
  p_date_changed := 'N';
  --  Check if the rule's start_date > new usage start_date or
  --              rule's end_date < new usage end_date  then
  --  The rule start_date or end_date needs to be changed. Calculate new values
  if(p_rul_start_date > p_rlu_start_date or
     p_rul_end_date < p_rlu_end_date) then
    p_date_changed := 'Y';
    if p_rul_start_date > p_rlu_start_date then
      p_rul_start_date := p_rlu_start_date;
    end if;
    if p_rul_end_date < p_rlu_end_date then
      p_rul_end_date := p_rlu_end_date;
    end if;
  end if;
end fetchNewRuleDates;
--+
--+
--+
procedure getConditionIds(ruleIdIn           in     integer,
                          conditionIdListOut    out nocopy ame_util.idList) as
  cursor conditionCursor(ruleIdIn in integer) is
    select ame_conditions.condition_id condition_id
          ,ame_conditions.condition_type condition_type
      from ame_conditions
          ,ame_condition_usages
     where ame_conditions.condition_id = ame_condition_usages.condition_id
       and ame_condition_usages.rule_id = ruleIdIn
       and (ame_conditions.start_date <= sysdate
             and (ame_conditions.end_date is null or sysdate < ame_conditions.end_date))
       and ((sysdate between ame_condition_usages.start_date
            and nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate))
            or
           (sysdate < ame_condition_usages.start_date
             and ame_condition_usages.start_date <
               nvl(ame_condition_usages.end_date,
                 ame_condition_usages.start_date + ame_util.oneSecond)))
     order by condition_type;
  tempIndex integer;
begin
/*
Can't do a bulk collect here because we have to order by condition_type
(so that exception conditions, either pre or post, get displayed after
ordinary conditions), and we don't want to output condition_type.
*/
  tempIndex := 1;
  for tempCondition in conditionCursor(ruleIdIn => ruleIdIn) loop
    conditionIdListOut(tempIndex) := tempCondition.condition_id;
    tempIndex := tempIndex + 1;
  end loop;
  if(tempIndex = 1) then
    conditionIdListOut := ame_util.emptyIdList;
  end if;
  exception
    when others then
      conditionIdListOut := ame_util.emptyIdList;
end getConditionIds;
--+
--+
--+
procedure getActionIds(ruleIdIn in integer,
                         actionIdListOut out nocopy ame_util.idList) as
  cursor actionCursor(ruleIdIn in integer) is
    select ame_action_usages.action_id
      from ame_action_usages
     where rule_id = ruleIdIn
       and ((sysdate between ame_action_usages.start_date
             and nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate))
           or
           (sysdate < ame_action_usages.start_date
             and ame_action_usages.start_date <
               nvl(ame_action_usages.end_date, ame_action_usages.start_date + ame_util.oneSecond)));
  actionId integer;
  tempIndex integer;
begin
  tempIndex := 1;
  for tempAction in actionCursor(ruleIdIn => ruleIdIn) loop
    actionIdListOut(tempIndex) := tempAction.action_id;
    tempIndex := tempIndex + 1;
  end loop;
  exception
    when others then
      actionIdListOut := ame_util.emptyIdList;
end getActionIds;
--+
--   This is a private function which checks if a rule already exists with the same
--   combination of conditions and actions.
--+
Function ruleExists(p_rule_id          in    number
                    ,p_rule_type       in    varchar2
                    ,p_item_class_id   in    number
                    ,p_effective_date  in    date
                    ,p_conditions_list in    ame_util.idList
                    ,p_actions_list    in    ame_util.idList
                    ) return boolean as
  cursor ruleIdCursor(typeIn        in varchar2
                     ,itemClassIdIn in integer default null) is
    select rule_id
      from ame_rules
     where rule_type = typeIn
       and (item_class_id is null or item_class_id = itemClassIdIn)
       and ((sysdate between start_date
              and nvl(end_date - ame_util.oneSecond, sysdate))
           or
           (sysdate < start_date
             and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  actionIdList1    ame_util.idList;
  actionIdList2    ame_util.idList;
  actionIdMatch    boolean;
  conditionIdList1 ame_util.idList;
  conditionIdList2 ame_util.idList;
  conditionIdMatch boolean;
begin
  for i in 1..p_conditions_list.count loop
    conditionIdList1(i) := p_conditions_list(i);
  end loop;
  --+
  ame_util.sortIdListInPlace(idListInOut => conditionIdList1);
  for i in 1..p_actions_list.count loop
    actionIdList1(i) := p_actions_list(i);
  end loop;
  --+
  ame_util.sortIdListInPlace(idListInOut => actionIdList1);
  conditionIdMatch := false;
  actionIdMatch    := false;
  for tempRuleId in ruleIdCursor(typeIn => p_rule_type
                                ,itemClassIdIn => p_item_class_id) loop
    getConditionIds(ruleIdIn => tempRuleId.rule_id,
                    conditionIdListOut => conditionIdList2);
    ame_util.sortIdListInPlace(idListInOut => conditionIdList2);
    if(ame_util.idListsMatch(idList1InOut => conditionIdList1
                            ,idList2InOut => conditionIdList2
                            ,sortList1In => false
                            ,sortList2In => false)) then
      conditionIdMatch := true;
    end if;
    if conditionIdMatch then
      getActionIds(ruleIdIn => tempRuleId.rule_id
                  ,actionIdListOut => actionIdList2);
      ame_util.sortIdListInPlace(idListInOut => actionIdList2);
      if(ame_util.idListsMatch(idList1InOut => actionIdList1
                              ,idList2InOut => actionIdList2
                              ,sortList1In => false
                              ,sortList2In => false)) then
        actionIdMatch := true;
      end if;
      if(conditionIdMatch and actionIdMatch) then
        return(true);
      end if;
    end if;
    conditionIdList2.delete;
    actionIdList2.delete;
    conditionIdMatch := false;
    actionIdMatch    := false;
  end loop;
  return(false);
  exception
    when others then
      return(true);
end ruleExists;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_rule >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_rule
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_rule_key                      in     varchar2
  ,p_description                   in     varchar2
  ,p_rule_type                     in     varchar2
  ,p_item_class_id                 in     number   default null
  ,p_condition_id                  in     number   default null
  ,p_action_id                     in     number   default null
  ,p_application_id                in     number   default null
  ,p_priority                      in     number   default null
  ,p_approver_category             in     varchar2 default null
  ,p_rul_start_date                in out nocopy   date
  ,p_rul_end_date                  in out nocopy   date
  ,p_rule_id                          out nocopy   number
  ,p_rul_object_version_number        out nocopy   number
  ,p_rlu_object_version_number        out nocopy   number
  ,p_rlu_start_date                   out nocopy   date
  ,p_rlu_end_date                     out nocopy   date
  ,p_cnu_object_version_number        out nocopy   number
  ,p_cnu_start_date                   out nocopy   date
  ,p_cnu_end_date                     out nocopy   date
  ,p_acu_object_version_number        out nocopy   number
  ,p_acu_start_date                   out nocopy   date
  ,p_acu_end_date                     out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                         varchar2(72) := g_package||'create_ame_rule';
  l_rule_id                      number;
  l_rul_object_version_number    number;
  l_rlu_object_version_number    number;
  l_rul_start_date               date;
  l_rlu_start_date               date;
  l_rul_end_date                 date;
  l_rlu_end_date                 date;
  l_cnu_object_version_number    number;
  l_acu_object_version_number    number;
  l_cnu_start_date               date;
  l_acu_start_date               date;
  l_cnu_end_date                 date;
  l_acu_end_date                 date;
  l_swi_call                     boolean;
  l_swi_package_name             varchar2(30) := 'AME_RULE_SWI';
  l_effective_date               date;
  l_use_count                    number := 0;
  l_condition_type               varchar2(10);
  l_attribute_id                 number;
  l_action_rule_type             ame_rules.rule_type%type;
  l_item_class_id                ame_item_classes.item_class_id%type;
  --+
  cursor getActionRuleType is
  select atyu.rule_type
    from ame_action_type_usages atyu
        ,ame_actions act
   where act.action_id = p_action_id
     and act.action_type_id = atyu.action_type_id
     and sysdate between act.start_date and nvl(act.end_date-(1/86400),sysdate)
     and sysdate between atyu.start_date and nvl(atyu.end_date-(1/86400),sysdate);
  --+
  cursor getConditionDetails is
   select condition_type
         ,attribute_id
     from ame_conditions
    where condition_id = p_condition_id
      and l_effective_date between start_date
           and nvl(end_date - ame_util.oneSecond,l_effective_date);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_rule;
  l_swi_call := true;
  l_item_class_id := p_item_class_id;
  l_effective_date := sysdate;
  if (instr(DBMS_UTILITY.FORMAT_CALL_STACK, l_swi_package_name) = 0) then
    --+ this procedure is not invoked from the UI.
    l_swi_call := false;
    --+
    --+ Check the application id.
    --+
    ame_rule_utility_pkg.checkApplicationId(p_application_id => p_application_id);
    --+
    --+ condition id cannot be null for LCE and LM/SUB rule.
    --+
    if p_condition_id is null then
      --+
      if p_rule_type = ame_util.exceptionRuleType then
        fnd_message.set_name('PER','AME_400709_NO_EXC_COND_LCE_RUL');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
      end if;
      --+
      if p_rule_type = ame_util.listModRuleType or p_rule_type = ame_util.substitutionRuleType then
        fnd_message.set_name('PER','AME_400710_NO_LM_CON_LMSUB_RUL');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
      end if;
      --+
    else
      --+
      --+ Check the not null Condition Id.
      --+
      ame_rule_utility_pkg.checkConditionId(p_condition_id);
      --+
      --+ Fetch the condition details.
      --+
      open getConditionDetails;
      fetch getConditionDetails
      into l_condition_type
          ,l_attribute_id ;
      if getConditionDetails%notfound then
        fnd_message.set_name('PER','AME_400494_INVALID_CONDITION');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
      end if;
      close getConditionDetails;
      --+
      --+ Check if this condition can be added to this transaction type
      --+
      if not ame_rule_utility_pkg.is_condition_allowed(p_application_id => p_application_id
                                                      ,p_condition_id   => p_condition_id) then
        fnd_message.set_name('PER','AME_400738_COND_NOT_IN_APP');
        hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
      end if;
      --+
      --+ Item class id should be null for LM Conditions
      --+
      if p_rule_type = 0 and l_condition_type = ame_util.listModConditionType then
        l_item_class_id := null;
      end if;
      --+
    end if;
    --+
  end if;
  --+ End of if not swi block.
  --
  -- Call Before Process User Hook
  --
  begin
    ame_rule_bk1.create_ame_rule_b
                 (p_rule_key            => p_rule_key
                 ,p_description         => p_description
                 ,p_rule_type           => p_rule_type
                 ,p_item_class_id       => l_item_class_id
                 ,p_condition_id        => p_condition_id
                 ,p_action_id           => p_action_id
                 ,p_application_id      => p_application_id
                 ,p_priority            => p_priority
                 ,p_approver_category   => p_approver_category
                 ,p_rul_start_date      => p_rul_start_date
                 ,p_rul_end_date        => p_rul_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_rule'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  --
  -- assign correct values for rule start and end dates
  --
  if p_rul_start_date is null then
    l_rul_start_date := l_effective_date;
  else
    l_rul_start_date := p_rul_start_date;
  end if;
  if p_rul_end_date is null then
    l_rul_end_date := ame_utility_pkg.endOfTime;
  else
    l_rul_end_date := p_rul_end_date;
  end if;

  if not l_swi_call then
     if(l_rul_start_date < l_effective_date ) then
       fnd_message.set_name('PER','AME_400208_RUL_STRT_PREC_TDY');
       fnd_message.raise_error;
     end if;
  end if;

  l_effective_date := l_rul_start_date;
  --
  -- insert the row in ame_rules.
  --
  ame_rul_ins.ins(p_effective_date        => l_effective_date
                 ,p_rule_type             => p_rule_type
                 ,p_description           => p_description
                 ,p_rule_key              => p_rule_key
                 ,p_item_class_id         => l_item_class_id
                 ,p_start_date            => l_rul_start_date
                 ,p_end_date              => l_rul_end_date
                 ,p_rule_id               => l_rule_id
                 ,p_object_version_number => l_rul_object_version_number
                 );
  -- insert data into TL tables
  ame_rtl_ins.ins_tl(p_language_code      => p_language_code
                    ,p_rule_id            => l_rule_id
                    ,p_description        => p_description
                    );
  --
  -- Call DBMS_UTILITY.FORMAT_CALL_STACK to check if the call has been made
  -- from the 'AME_RULE_SWI' package.
  --
  if not l_swi_call then
    --
    -- As the call is not from the SWI layer the following integrity checks need to be done.
    -- a. If Rule type is Exception rule, then the condition being passed in is an exception condition
    -- b. If Rule type is List-modification or  substitution rules the condition being passed in is
    --    a  list-modification condition.
    -- c. Check that action_id is not null.
    --
    --+ Verify the Rule Type and Condition Type Combination.
    --+
    if p_rule_type = ame_util.exceptionRuleType  then
      if (getConditionType(p_condition_id   => p_condition_id
                          ,p_effective_date => l_effective_date)
                           <> ame_util.exceptionConditionType)  then
        fnd_message.set_name('PER','AME_400709_NO_EXC_COND_LCE_RUL');
        hr_multi_message.add (p_associated_column1 =>'CONDITION_ID');
      end if;
    elsif (p_rule_type = ame_util.listModRuleType or
      p_rule_type = ame_util.substitutionRuleType) then
      if ( getConditionType(p_condition_id   => p_condition_id
                           ,p_effective_date => l_effective_date)
                           <> ame_util.listModConditionType)  then
        fnd_message.set_name('PER','AME_400710_NO_LM_CON_LMSUB_RUL');
        hr_multi_message.add (p_associated_column1 => 'CONDITION_ID');
      end if;
    end if;
    --+
    --+ Check Action Id.
    --+
    if p_action_id is null then
      fnd_message.set_name('PER','AME_400725_NO_ACTION_DEFINED');
      hr_multi_message.add(p_associated_column1 => 'ACTION_ID');
    else
      ame_rule_utility_pkg.checkActionId(p_action_id);
      --+
      --+ Check the action and condition combination for LM Rule.
      --+
      if p_rule_type = ame_util.listModRuleType then
        ame_rule_utility_pkg.chk_LM_action_Condition(p_condition_id     => p_condition_id
                                                    ,p_action_id        => p_action_id
                                                    ,is_first_condition => true);
      end if;
    end if;
    --+ Fetch Action details.
    open  getActionRuleType;
    fetch getActionRuleType
    into l_action_rule_type;
    --
    -- set the start date and end date for rule usages
    --
    l_rlu_start_date := l_rul_start_date;
    l_rlu_end_date   := l_rul_end_date;
    --
    -- Create Condition usage if condition id is not null.
    --
    if p_condition_id is not null then
      create_ame_condition_to_rule
       (p_validate                      => p_validate
       ,p_rule_id                       => l_rule_id
       ,p_condition_id                  => p_condition_id
       ,p_object_version_number         => l_cnu_object_version_number
       ,p_start_date                    => l_cnu_start_date
       ,p_end_date                      => l_cnu_end_date
       );
    end if;
    --+
    --+ Check the Rule Type and action combination.
    --+
    if not ame_rule_utility_pkg.chk_rule_type
                                         (p_rule_id             => l_rule_id
                                         ,p_rule_type               => p_rule_type
                                         ,p_action_rule_type        => l_action_rule_type
                                         ,p_application_id          => p_application_id
                                         ,p_allow_production_action => false) then
      fnd_message.set_name('PER','AME_400741_RULE_TYPE_MISMATCH');
      hr_multi_message.add(p_associated_column1 => 'RULE_TYPE');
    end if;
    --
    -- Create Action usage
    --
    create_ame_action_to_rule
       (p_validate                      => p_validate
       ,p_rule_id                       => l_rule_id
       ,p_action_id                     => p_action_id
       ,p_object_version_number         => l_acu_object_version_number
       ,p_start_date                    => l_acu_start_date
       ,p_end_date                      => l_acu_end_date
       );
    --
    -- Create rule usage
    --
    create_ame_rule_usage
       (p_validate                      => p_validate
       ,p_rule_id                       => l_rule_id
       ,p_application_id                => p_application_id
       ,p_priority                      => p_priority
       ,p_approver_category             => p_approver_category
       ,p_object_version_number         => l_rlu_object_version_number
       ,p_start_date                    => l_rlu_start_date
       ,p_end_date                      => l_rlu_end_date
       );
  end if;  -- Check that call is not from an SWI package
  --
  -- Call After Process User Hook
  --
  begin
    ame_rule_bk1.create_ame_rule_a
                 (p_rule_key                  => p_rule_key
                 ,p_description               => p_description
                 ,p_rule_type                 => p_rule_type
                 ,p_item_class_id             => l_item_class_id
                 ,p_condition_id              => p_condition_id
                 ,p_action_id                 => p_action_id
                 ,p_application_id            => p_application_id
                 ,p_priority                  => p_priority
                 ,p_approver_category         => p_approver_category
                 ,p_rul_start_date            => p_rul_start_date
                 ,p_rul_end_date              => p_rul_end_date
                 ,p_rule_id                   => p_rule_id
                 ,p_rul_object_version_number => p_rul_object_version_number
                 ,p_rlu_object_version_number => p_rlu_object_version_number
                 ,p_rlu_start_date            => p_rlu_start_date
                 ,p_rlu_end_date              => p_rlu_end_date
                 ,p_cnu_object_version_number => p_cnu_object_version_number
                 ,p_cnu_start_date            => p_cnu_start_date
                 ,p_cnu_end_date              => p_cnu_end_date
                 ,p_acu_object_version_number => p_acu_object_version_number
                 ,p_acu_start_date            => p_acu_start_date
                 ,p_acu_end_date              => p_acu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_rule'
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
  p_rule_id                        := l_rule_id;
  p_rul_object_version_number      := l_rul_object_version_number;
  p_rul_start_date                 := l_rul_start_date;
  p_rul_end_date                   := l_rul_end_date;
  if not l_swi_call then
    p_rlu_object_version_number    := l_rlu_object_version_number;
    p_rlu_start_date               := l_rlu_start_date;
    p_rlu_end_date                 := l_rlu_end_date;
    p_acu_object_version_number    := l_acu_object_version_number;
    p_acu_start_date               := l_acu_start_date;
    p_acu_end_date                 := l_acu_end_date;
    p_cnu_object_version_number    := l_cnu_object_version_number;
    p_cnu_start_date               := l_cnu_start_date;
    p_cnu_end_date                 := l_cnu_end_date;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ame_rule;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rule_id                        := null;
    p_rul_object_version_number      := null;
    p_rul_start_date                 := null;
    p_rul_end_date                   := null;
    if not l_swi_call then
      p_rlu_object_version_number    := null;
      p_rlu_start_date               := null;
      p_rlu_end_date                 := null;
      p_acu_object_version_number    := null;
      p_acu_start_date               := null;
      p_acu_end_date                 := null;
      p_cnu_object_version_number    := null;
      p_cnu_start_date               := null;
      p_cnu_end_date                 := null;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ame_rule;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_rule_id                    := null;
    p_rul_object_version_number  := null;
    p_rul_start_date             := null;
    p_rul_end_date               := null;
    if not l_swi_call then
      p_rlu_object_version_number  := null;
      p_rlu_start_date             := null;
      p_rlu_end_date               := null;
      p_acu_object_version_number  := null;
      p_acu_start_date             := null;
      p_acu_end_date               := null;
      p_cnu_object_version_number  := null;
      p_cnu_start_date             := null;
      p_cnu_end_date               := null;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ame_rule;
--
-- ----------------------------------------------------------------------------
-- |------------------< create_ame_rule_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_rule_usage
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_application_id                in     number
  ,p_priority                      in     number   default null
  ,p_approver_category             in     varchar2 default null
  ,p_start_date                    in out nocopy   date
  ,p_end_date                      in out nocopy   date
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc             varchar2(72) := g_package||'create_ame_rule_usage';
  l_dummy            varchar2(10);
  l_swi_package_name varchar2(30) := 'AME_RULE_SWI';
  l_effective_date   date;
  l_approver_category varchar2(1);
  l_result           number(2);
  --+
  cursor getAttributeUsages is
    select attribute_id
          ,use_count
          ,start_date
          ,end_date
          ,object_version_number
      from ame_attribute_usages
     where attribute_id in (
                 select ame_conditions.attribute_id
                   from ame_conditions
                       ,ame_condition_usages
                  where ame_condition_usages.rule_id = p_rule_id
                    and (l_effective_date between ame_condition_usages.start_date
                          and nvl(ame_condition_usages.end_date - ame_util.oneSecond, l_effective_date )
                         or
                        (l_effective_date < ame_condition_usages.start_date
                          and ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
                                ame_condition_usages.start_date + ame_util.oneSecond)))
                    and ame_condition_usages.condition_id = ame_conditions.condition_id
                    and l_effective_date between  ame_conditions.start_date
                         and nvl(ame_conditions.end_date - ame_util.oneSecond, l_effective_date)
                           )
       and application_id = p_application_id
       and l_effective_date between  ame_attribute_usages.start_date
            and nvl(ame_attribute_usages.end_date - ame_util.oneSecond, l_effective_date);
  --+
  cursor getAttributeUsages2(p_attribute_id in number) is
    select attribute_id, use_count, start_date, end_date, object_version_number
      from ame_attribute_usages
      where attribute_id = p_attribute_id
         and application_id = p_application_id
         and  l_effective_date between  start_date and
               nvl(end_date - ame_util.oneSecond,l_effective_date);
  --+
  cursor getReqAttributes is
    select man.attribute_id
      from ame_mandatory_attributes man
          ,ame_action_usages acu
          ,ame_actions act
     where man.action_type_id = act.action_type_id
       and acu.action_id = act.action_id
       and acu.rule_id = p_rule_id
       and l_effective_date between man.start_date and nvl(man.end_date - ame_util.oneSecond, l_effective_date)
       and l_effective_date between act.start_date and nvl(act.end_date - ame_util.oneSecond, l_effective_date)
       and ((l_effective_date between acu.start_date and nvl(acu.end_date - ame_util.oneSecond, l_effective_date))
           or
            (l_effective_date < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + ame_util.oneSecond))
           );
  --+
  cursor getActions is
    select action_id
          ,start_date
          ,end_date
          ,object_version_number
      from ame_action_usages
     where rule_id = p_rule_id
       and (l_effective_date between  start_date
             and nvl(end_date - ame_util.oneSecond,l_effective_date)
           or
           (l_effective_date < start_date and start_date < nvl(end_date, start_date + ame_util.oneSecond)));
  --+
  cursor getConditions is
    select condition_id
          ,start_date
          ,end_date
          ,object_version_number
      from ame_condition_usages
     where rule_id = p_rule_id
       and (l_effective_date between  start_date
             and nvl(end_date - ame_util.oneSecond, l_effective_date)
           or
           (l_effective_date < start_date and start_date < nvl(end_date, start_date + ame_util.oneSecond)));
  --+
  cursor itemClassUsageCursor(p_application_id in number
                             ,p_item_class_id  in number
                             ,l_effective_date in date) is
    select null
      from ame_item_class_usages
     where application_id =p_application_id
       and item_class_id = p_item_class_id
       and l_effective_date between  start_date
            and nvl(end_date - ame_util.oneSecond, l_effective_date);
  l_rul_object_version_number    number;
  l_rule_id                      number;
  l_rule_type                    ame_rules.rule_type%type;
  l_item_class_id                number;
  l_item_class_name              ame_item_classes.name%type;
  l_date_changed                 varchar2(10);
  l_variable_value               varchar2(200);
  l_application_id               number;
  l_overlapping_usage            number;
  l_atu_object_version_number    number;
  l_atu_start_date               date;
  l_atu_end_date                 date;
  l_rlu_object_version_number    number;
  l_rlu_start_date               date;
  l_rlu_end_date                 date;
  l_rul_start_date               date;
  l_rul_end_date                 date;
  l_cnu_object_version_number    number;
  l_cnu_start_date               date;
  l_cnu_end_date                 date;
  l_acu_object_version_number    number;
  l_acu_start_date               date;
  l_acu_end_date                 date;
  l_use_count                    number := 0;
  priority                       varchar2(100);
  l_swi_call                     boolean;
  l_create_ame_rule_call         boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_rule_usage;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_rule_bk2.create_ame_rule_usage_b
                 (p_rule_id                => p_rule_id
                 ,p_application_id         => p_application_id
                 ,p_priority               => p_priority
                 ,p_approver_category      => p_approver_category
                 ,p_start_date             => p_start_date
                 ,p_end_date               => p_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_rule_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_rlu_start_date := p_start_date;
  l_rlu_end_date := p_end_date;
  l_swi_call := true;
  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK, l_swi_package_name) = 0) then
    l_swi_call := false;
  end if;

  -- If call is from the UI set the effective date to rule start date non future dated rules
  if l_swi_call then
    if l_effective_date > p_start_date then
      l_effective_date := p_start_date;
    end if;
  end if;
  --
  --  Check that the transaction type has a usage for the Item class of the rule.
  --
  -- get item class for rule

  --+
  --+ Check Rule Id
  --+
  ame_rule_utility_pkg.checkRuleId(p_rule_id => p_rule_id);
  --+
  --+ Check Application Id
  --+
  ame_rule_utility_pkg.checkApplicationId(p_application_id => p_application_id);
  --+
  --+ Check If all the actions for this rule
  --+ are valid for this Transaction Type.
  --+
  l_result := ame_rule_utility_pkg.is_rule_usage_allowed(p_application_id => p_application_id
                                                        ,p_rule_id        => p_rule_id);
  if l_result = ame_rule_utility_pkg.ActionNotAllowedInTTY then
    fnd_message.set_name('PER','AME_400735_ACT_NOT_IN_APP');
    hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
  elsif l_result = ame_rule_utility_pkg.GroupNotAllowedInTTY then
    fnd_message.set_name('PER','AME_400744_GRP_NOT_IN_APP');
    hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
  elsif l_result = ame_rule_utility_pkg.PosActionNotAllowedInTTY then
    fnd_message.set_name('PER','AME_400770_POS_APR_NOT_IN_APP');
    hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
  end if;
  --+
  --+ Check If all the conditions are
  --+ valid for this Transaction Type.
  --+
  if not ame_rule_utility_pkg.is_rule_usage_cond_allowed(p_application_id => p_application_id
                                                        ,p_rule_id        => p_rule_id)               then
    fnd_message.set_name('PER','AME_400738_COND_NOT_IN_APP');
    hr_multi_message.add (p_associated_column1 => 'RULE_ID');
  end if;
  --+
  select item_class_id
        ,rule_type
        ,start_date
        ,end_date
        ,object_version_number
    into l_item_class_id
        ,l_rule_type
        ,l_rul_start_date
        ,l_rul_end_date
        ,l_rul_object_version_number
    from ame_rules
   where rule_id = p_rule_id
     and ((l_effective_date between start_date
           and nvl(end_date - ame_util.oneSecond, l_effective_date))
          or
         (l_effective_date < start_date
           and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
   if l_item_class_id is not null then
     -- check item class is valid
     open itemClassUsageCursor(p_application_id => p_application_id
                              ,p_item_class_id  => l_item_class_id
                              ,l_effective_date => l_effective_date);
     fetch itemClassUsageCursor into l_dummy;
     if itemClassUsageCursor%NOTFOUND then
       fnd_message.set_name('PER','AME_400740_INV_ITEM_CLASS_ID');
       hr_multi_message.add(p_associated_column1 =>'RULE_ID');
     end if;
     close itemClassUsageCursor;
    --
    --  Check the value of the config variable 'allowAllItemClassRules' to ensure that rules for this
    --  item class can be defined for this application id.
    --
    l_variable_value := ame_util.getConfigVar
                   (variableNameIn  => ame_util.allowAllICRulesConfigVar
                   ,applicationIdIn => p_application_id);
    if l_variable_value = ame_util.no then
      -- check that the rule item class is header
      select name
        into l_item_class_name
        from ame_item_classes
        where item_class_id = l_item_class_id
          and l_effective_date between start_date
               and nvl(end_date - ame_util.oneSecond, l_effective_date);
      if l_item_class_name not in (ame_util.headerItemClassName
                                  ,ame_util.lineItemItemClassName) then
        fnd_message.set_name('PER','AME_400743_ITC_NOT_ALLOWED');
        hr_multi_message.add(p_associated_column1 => 'RULE_ID');
      end if;
    end if;
  end if;
  --
  --  Check the value of the config variable 'allowAllApproverTypes' and 'productionFunctionality'
  --  to ensure that rules of this type type can be defined for this transaction type.
  --
  /*
  if l_rule_type not in (ame_util.substitutionRuleType) then
    if not checkRuleAllowed(p_application_id => p_application_id
                           ,p_rule_id        => p_rule_id
                           ,p_effective_date => l_effective_date) then
      fnd_message.set_name('PER','AME_99999_RU_NOT_ALLOWED');
      fnd_message.raise_error;
--      hr_multi_message.add(p_associated_column1 => 'RULE_ID');
    end if;
  end if;
  */
  --
  --  Check the value of the config variable 'allowFyiNotifications'
  --  to ensure that rules of this approver category are allowed.
  --
  if p_approver_category = ame_util.fyiApproverCategory then
    if (ame_util.getConfigVar(variableNameIn => ame_util.allowFyiNotificationsConfigVar
                             ,applicationIdIn => p_application_id) = ame_util.no ) then
      fnd_message.set_name('PER','AME_400742_FYI_CAT_NO_ALLOWED');
      hr_multi_message.add(p_associated_column1 => 'APPROVER_CATEGORY');
    end if;
  end if;
  l_approver_category := p_approver_category;
  if not l_swi_call then
    if(l_rule_type not in (ame_util.listModRuleType
                          ,ame_util.substitutionRuleType
                          ,ame_util.productionRuleType
                          ,ame_util.combinationRuleType)) then
      if l_approver_category is null then
        l_approver_category := ame_util.approvalApproverCategory;
      end if;
    elsif l_rule_type = ame_util.combinationRuleType and not ame_rule_utility_pkg.is_LM_comb_rule(p_rule_id) then
      if l_approver_category is null then
        l_approver_category := ame_util.approvalApproverCategory;
      end if;
    elsif l_approver_category is not null then
      fnd_message.set_name('PER','AME_400744_APPR_CAT_NOT_NULL');
      hr_multi_message.add(p_associated_column1 => 'APPROVER_CATEGORY');
    end if;
  end if;

  --
  -- Check that priority is defined, if enabled for this rule type for this transaction type
  --
  l_variable_value := ame_util.getConfigVar(
                         variableNameIn => ame_util.rulePriorityModesConfigVar
                         ,applicationIdIn => p_application_id);
  if(l_rule_type = ame_util.combinationRuleType) then
    priority := substrb(l_variable_value, 1, (instr(l_variable_value,':',1,1) -1));
  elsif(l_rule_type = ame_util.authorityRuleType) then
    priority := substrb(l_variable_value,
                       (instr(l_variable_value,':',1,1) +1),
                       (instr(l_variable_value,':',1,2) -
                       (instr(l_variable_value,':',1,1) +1)));
  elsif(l_rule_type = ame_util.exceptionRuleType) then
    priority := substrb(l_variable_value,
                       (instr(l_variable_value,':',1,2) +1),
                       (instr(l_variable_value,':',1,3) -
                       (instr(l_variable_value,':',1,2) +1)));
  elsif(l_rule_type = ame_util.listModRuleType) then
    priority := substrb(l_variable_value,
                       (instr(l_variable_value,':',1,3) +1),
                       (instr(l_variable_value,':',1,4) -
                       (instr(l_variable_value,':',1,3) +1)));
  elsif(l_rule_type = ame_util.substitutionRuleType) then
    priority := substrb(l_variable_value,
                       (instr(l_variable_value,':',1,4) +1),
                       (instr(l_variable_value,':',1,5) -
                       (instr(l_variable_value,':',1,4) +1)));
  elsif(l_rule_type = ame_util.preListGroupRuleType) then
    priority := substrb(l_variable_value,
                       (instr(l_variable_value,':',1,5) +1),
                       (instr(l_variable_value,':',1,6) -
                       (instr(l_variable_value,':',1,5) +1)));
  elsif(l_rule_type = ame_util.postListGroupRuleType) then
    priority := substrb(l_variable_value,
                       (instr(l_variable_value,':',1,6) +1),
                       (instr(l_variable_value,':',1,7) -
                       (instr(l_variable_value,':',1,6) +1)));
  elsif(l_rule_type = ame_util.productionRuleType) then
    priority := substrb(l_variable_value,
                       (instr(l_variable_value,':',1,7) +1));
  end if;
  if(priority <> ame_util.disabledRulePriority and p_priority is null) then
    fnd_message.set_name('PER','AME_400707_INVALID_PRIORITY');
    hr_multi_message.add(p_associated_column1 => 'PRIORITY');
  end if;
  --
  -- Check that the rule usage does not overlap with existing rule usage dates
  -- for the same application ID
  l_overlapping_usage :=  checkRuleUsageExists(p_application_id => p_application_id
                                              ,p_rule_id        => p_rule_id
                                              ,p_rlu_start_date => p_start_date
                                              ,p_rlu_end_date   => p_end_date
                                              ,p_effective_date => l_effective_date
                                              ,p_priority       => p_priority );
  if l_overlapping_usage = 1 then
    fnd_message.set_name('PER','AME_400327_RULE_USG_EXST_LIFE');
    hr_multi_message.add (p_associated_column1 => 'RULE_ID');
  elsif l_overlapping_usage = 2 then
    fnd_message.set_name('PER','AME_400328_RULE_USG_DIFF_PRIOR');
    hr_multi_message.add (p_associated_column1 =>'RULE_ID');
  elsif l_overlapping_usage = 3 then
    fnd_message.set_name('PER','AME_400329_RULE_USG_OVER_LIFE');
    hr_multi_message.add (p_associated_column1 => 'RULE_ID');
  end if;
  -- insert the row in ame_rule_usages
  if l_rlu_start_date is null then
    l_rlu_start_date := l_effective_date;
  end if;
  if l_rlu_end_date is null then
    l_rlu_end_date := ame_utility_pkg.endOfTime;
  else
    l_rlu_end_date := trunc(l_rlu_end_date);
  end if;
  ame_rlu_ins.ins(p_rule_id               => p_rule_id
                 ,p_item_id               => p_application_id
                 ,p_effective_date        => l_effective_date
                 ,p_approver_category     => l_approver_category
                 ,p_priority              => p_priority
                 ,p_object_version_number => l_rlu_object_version_number
                 ,p_start_date            => l_rlu_start_date
                 ,p_end_date              => l_rlu_end_date
                 );
  --
  --  Check if the start date and end date for the rule has changed
  --

--  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name||fnd_global.local_chr(ascii_chr => 10)) = 0) and
  l_create_ame_rule_call := true;
  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,'AME_RULE_API.CREATE_AME_RULE' ) = 0)then
    l_create_ame_rule_call := false;
  end if;
  if not l_create_ame_rule_call and not l_swi_call then
    fetchNewRuleDates(p_rule_id        => p_rule_id
                     ,p_rlu_start_date => l_rlu_start_date
                     ,p_rlu_end_date   => l_rlu_end_date
                     ,p_rul_start_date => l_rul_start_date
                     ,p_rul_end_date   => l_rul_end_date
                     ,p_date_changed   => l_date_changed
                     ) ;
    if l_date_changed = 'Y' then
      --
      -- date has changed, update the dates for rules, condition usages and action usages
      --
      -- actions usages
       for tempActions in getActions loop
         l_acu_object_version_number := tempActions.object_version_number;
         l_acu_start_date := tempActions.start_date;
         l_acu_end_date := tempActions.end_date;
         ame_acu_upd.upd(p_rule_id               => p_rule_id
                        ,p_datetrack_mode        => hr_api.g_update
                        ,p_action_id             => tempActions.action_id
                        ,p_effective_date        => l_effective_date
                        ,p_object_version_number => l_acu_object_version_number
                        ,p_start_date            => l_rul_start_date
                        ,p_end_date              => l_rul_end_date
                        );
       end loop;
      -- condition usages
       for tempConditions in getConditions loop
         l_cnu_object_version_number := tempConditions.object_version_number;
         l_cnu_start_date := tempConditions.start_date;
         l_cnu_end_date := tempConditions.end_date;
         ame_cnu_upd.upd(p_rule_id               => p_rule_id
                        ,p_datetrack_mode        => hr_api.g_update
                        ,p_condition_id          => tempConditions.condition_id
                        ,p_effective_date        => l_effective_date
                        ,p_object_version_number => l_cnu_object_version_number
                        ,p_start_date            => l_rul_start_date
                        ,p_end_date              => l_rul_end_date
                        );
       end loop;
      -- rules
      ame_rul_upd.upd(p_rule_id               => p_rule_id
                     ,p_datetrack_mode        => hr_api.g_update
                     ,p_effective_date        => l_effective_date
                     ,p_object_version_number => l_rul_object_version_number
                     ,p_start_date            => l_rul_start_date
                     ,p_end_date              => l_rul_end_date
                     );
    end if;
  end if;
  --
  --  Update the attribute usage counts
  --
  for tempAttributeUsages in getAttributeUsages loop
    l_atu_object_version_number := tempAttributeUsages.object_version_number;
    l_atu_start_date            := tempAttributeUsages.start_date;
    l_atu_end_date              := tempAttributeUsages.end_date;
    ame_attribute_api.updateUseCount(p_attribute_id              => tempAttributeUsages.attribute_id
                                    ,p_application_id            => p_application_id
                                    ,p_atu_object_version_number => l_atu_object_version_number);
  end loop;
  -- update the use count of req attributes
  for tempAttribute in getReqAttributes loop
    for tempAttributeUsages in getAttributeUsages2(p_attribute_id => tempAttribute.attribute_id) loop
      l_atu_object_version_number := tempAttributeUsages.object_version_number;
    ame_attribute_api.updateUseCount(p_attribute_id              => tempAttributeUsages.attribute_id
                                    ,p_application_id            => p_application_id
                                    ,p_atu_object_version_number => l_atu_object_version_number);
    end loop;
  end loop;
  --
  -- Call After Process User Hook
  --
  begin
    ame_rule_bk2.create_ame_rule_usage_a
                 (p_rule_id               => p_rule_id
                 ,p_application_id        => p_application_id
                 ,p_priority              => p_priority
                 ,p_approver_category     => l_approver_category
                 ,p_object_version_number => l_rlu_object_version_number
                 ,p_start_date            => l_rlu_start_date
                 ,p_end_date              => l_rlu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_rule_usage'
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
  p_object_version_number := l_rlu_object_version_number;
  p_start_date            := l_rlu_start_date;
  p_end_date              := l_rlu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ame_rule_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    p_start_date            := null;
    p_end_date              := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ame_rule_usage;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := null;
    p_start_date            := null;
    p_end_date              := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ame_rule_usage;
--
-- ----------------------------------------------------------------------------
-- |------------------<create_ame_condition_to_rule>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_condition_to_rule
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_condition_id                  in     number
  ,p_object_version_number            out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ,p_effective_date                in     date     default null
   ) is
  --
  -- Declare cursors and local variables
  --
  l_proc             varchar2(72) := g_package||'create_ame_rule_usage';
  l_dummy            varchar2(10);
  l_swi_package_name varchar2(30) := 'AME_RULE_SWI';
  l_effective_date   date;
  l_condition_type   ame_conditions.condition_type%type;
  l_attribute_id     number;
  l_swi_call         boolean;
  cursor getConditionDetails is
    select condition_type
          ,attribute_id
      from ame_conditions
     where condition_id = p_condition_id
       and l_effective_date between start_date
            and nvl(end_date - ame_util.oneSecond,l_effective_date);
  cursor getRuleDetails is
    select rule_type
          ,start_date
          ,end_date
          ,item_class_id
      from ame_rules
     where rule_id = p_rule_id
       and (l_effective_date between  start_date
             and nvl(end_date - ame_util.oneSecond,l_effective_date) or
           (l_effective_date < start_date
             and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  cursor getApplications is
    select item_id
      from ame_rule_usages
     where rule_id = p_rule_id
       and (l_effective_date between  start_date
             and nvl(end_date - ame_util.oneSecond,l_effective_date ) or
           (l_effective_date < start_date
             and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  cursor getAttributeUsages(p_application_id in integer) is
    select use_count
          ,start_date
          ,end_date
          ,object_version_number
      from ame_attribute_usages
     where attribute_id = l_attribute_id
       and l_effective_date between  start_date
            and nvl(end_date - ame_util.oneSecond,l_effective_date )
       and application_id = p_application_id;
  cursor getApplicationName(applicationIdIn in integer)is
    select application_name
      from ame_calling_apps
     where application_id = applicationIdIn
       and sysdate between start_date and nvl(end_date - (1/86400), sysdate);
  cursor getApplicationIds(p_rule_id in integer) is
  select distinct item_id
    from ame_rule_usages
   where rule_id = p_rule_id
     and ((sysdate between start_date and nvl(end_date - (1/86400),sysdate))
             or
            (sysdate < start_date and start_date < nvl(end_date, start_date + (1/86400)))
           );
  --+
  l_condition_count           number;
  l_rule_type                 ame_rules.rule_type%type;
  l_item_class_id             number;
  l_application_id            number;
  l_overlapping_usage         number;
  l_rlu_object_version_number number;
  l_atu_object_version_number number;
  l_atu_start_date            date;
  l_atu_end_date              date;
  l_condition_found           boolean;
  l_rul_object_version_number number;
  l_rul_start_date            date;
  l_rul_end_date              date;
  l_cnu_object_version_number number;
  l_cnu_start_date            date;
  l_cnu_end_date              date;
  l_use_count                 number := 0;
  actionIdList                ame_util.idList;
  conditionIdList             ame_util.idList;
  applicationName             ame_calling_apps.application_name%type;
  attributeName               ame_attributes.name%type;
  appIdList                   ame_util.idList;
  lm_count                    number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_condition_to_rule;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_rule_bk6.create_ame_condition_to_rule_b
                 (p_rule_id                => p_rule_id
                 ,p_condition_id           => p_condition_id
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_condition_to_rule'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;

  l_swi_call := true;
  ame_rule_utility_pkg.checkRuleId(p_rule_id => p_rule_id);
  ame_rule_utility_pkg.checkConditionId(p_condition_id => p_condition_id);
  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
    ame_rule_utility_pkg.chk_rule_and_item_class(p_rule_id      => p_rule_id
                                                ,p_condition_id => p_condition_id);
    l_swi_call := false;
  end if;

  -- If the call is from UI, then set the l_effective_date to p_effective_date
  if l_swi_call and p_effective_date is not null then
    l_effective_date := p_effective_date;
  end if;

  open getApplicationIds(p_rule_id => p_rule_id);
  fetch getApplicationIds
   bulk collect into appIdList;
   for i in 1..appIdList.count loop
     if not ame_rule_utility_pkg.is_condition_allowed(p_application_id => appIdList(i)
                                                     ,p_condition_id   => p_condition_id) then
      fnd_message.set_name('PER','AME_400738_COND_NOT_IN_APP');
      hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
     end if;
   end loop;
  --
  --  Fetch the condition details
  --
  open getConditionDetails;
  fetch getConditionDetails
   into l_condition_type
       ,l_attribute_id ;
  if getConditionDetails%notfound then
    fnd_message.set_name('PER','AME_400494_INVALID_CONDITION');
    hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
  end if;
  close getConditionDetails;
  --
  --  Fetch the rule details
  --
  open getRuleDetails;
  fetch getRuleDetails
   into l_rule_type
       ,l_rul_start_date
       ,l_rul_end_date
       ,l_item_class_id;
  if getRuleDetails%notfound then
    fnd_message.set_name('PER','AME_400480_INV_RULE_ID');
    hr_multi_message.add(p_associated_column1 => 'RULE_ID');
  end if;
  close getRuleDetails;
  --+
  -- Check that the condition type of the condition is allowed for the Rule Type.
  --+
  -- Condition Type  --->    Ordinary       Exception        List Modification
  -- Rule Type
  -- |    List Creation Rule      Y              N                 N
  -- |    Exception Rule          Y              Y                 N
  -- V    Pre-Approver Rule       Y              N                 N
  --      Post-Approver Rule      Y              N                 N
  --      List Modification Rule  Y              N                 Y
  --      Substitution Rule       Y              N                 Y
  --      Production Rule         Y              N                 N
  --+
  if l_condition_type = ame_util.exceptionConditionType then
    if l_rule_type <> ame_util.exceptionRuleType then
      fnd_message.set_name('PER','AME_400726_NO_EXC_CON_IN_RULE');
      hr_multi_message.add(p_associated_column1 =>'CONDITION_ID');
    end if;
  elsif l_condition_type = ame_util.listModConditionType then
    if l_rule_type not in (ame_util.listModRuleType
                          ,ame_util.substitutionRuleType
                          ,ame_util.combinationRuleType) then
      fnd_message.set_name('PER','AME_400727_NO_LM_CON_IN_RULE');
      hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
      if ame_rule_utility_pkg.rule_conditions_count(p_rule_id => p_rule_id) > 0 then
       fnd_message.set_name('PER','AME_400733_EXTRA_LM_CON');
       hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
      end if;
    end if;
  end if;
  --+
  --
  -- Check that there is no other rule with the same combination of actions and conditions
  -- existing.
  --
  -- Fetch conditions and actions for rule

  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
    --+
    --+ Check if the rule is LM/SUB/LM COMB and error out if these rules already have an LM Condition.
    --+
    select count(*)
      into lm_count
      from ame_rules             rul
          ,ame_condition_usages  cnu
          ,ame_conditions        cnd
     where rul.rule_id        = p_rule_id
       and cnu.rule_id        = rul.rule_id
       and cnd.condition_id   = cnu.condition_id
       and cnd.condition_type = 'post'
       and sysdate between cnd.start_date and nvl(cnd.end_date - (1/86400),sysdate)
       and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
          or
          (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
         )
       and ((sysdate between cnu.start_date and nvl(cnu.end_date - (1/86400),sysdate))
          or
          (sysdate < cnu.start_date and cnu.start_date < nvl(cnu.end_date, cnu.start_date + (1/86400)))
         );
    if lm_count > 0 then
      if(l_rule_type in(ame_util.listModRuleType
                        ,ame_util.substitutionRuleType
                        ,ame_util.combinationRuleType)
         and l_condition_type = ame_util.listModConditionType) then
        fnd_message.set_name('PER','AME_400385_RULE_LM');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
      end if;
    end if;
    getConditionIds(ruleIdIn => p_rule_id,
                    conditionIdListOut => conditionIdList);
    getActionIds(ruleIdIn => p_rule_id,
                 actionIdListOut => actionIdList);
    -- check condition does not exist in rule already
    l_condition_found := false;
    for i in 1..conditionIdList.count loop
      if p_condition_id = conditionIdList(i) then
        l_condition_found := true;
      end if;
    end loop;
    if l_condition_found then
        fnd_message.set_name('PER','AME_400728_DUP_CON_IN_RULE');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
    end if;
    -- add this condition_id to end of list
    l_condition_count := conditionIdList.count;
    conditionIdList(l_condition_count+1) := p_condition_id;
    /*
    if ruleExists(p_rule_id         => p_rule_id
                 ,p_rule_type       => l_rule_type
                 ,p_item_class_id   => l_item_class_id
                 ,p_effective_date  => l_effective_date
                 ,p_conditions_list => conditionIdList
                 ,p_actions_list    => actionIdList
                 )   then
        fnd_message.set_name('PER','AME_400212_RUL_PROP_EXISTS');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
    end if;
    */
  end if;

  --+
  ame_rule_utility_pkg.checkAllApplications(ruleIdIn      => p_rule_id
                                           ,conditionIdIn => p_condition_id);
  --+
  --
  -- Calculate Condition Usage start and end date.
  --
  if l_effective_date > l_rul_start_date then
    l_cnu_start_date := l_effective_date;
  else
    l_cnu_start_date := l_rul_start_date;
  end if;
  l_cnu_end_date := l_rul_end_date;
  --
  -- insert the row in ame_condition_usages
  --
  ame_cnu_ins.ins(p_rule_id               => p_rule_id
                 ,p_condition_id          => p_condition_id
                 ,p_effective_date        => l_effective_date
                 ,p_object_version_number => l_cnu_object_version_number
                 ,p_start_date            => l_cnu_start_date
                 ,p_end_date              => l_cnu_end_date
                 );
  --+
  -- For all conditions except List modification conditions,
  -- check that an attribute usage exists for the attribute this condition is based on
  -- for all the transaction type's using this rule.
  -- Update the attribute usage counts
  --+
  if l_condition_type <> ame_util.listModConditionType then
    for tempApplications in getApplications loop
      l_application_id := tempApplications.item_id;
      open getAttributeUsages(p_application_id => l_application_id) ;
      fetch getAttributeUsages
       into l_use_count
           ,l_atu_start_date
           ,l_atu_end_date
           ,l_atu_object_version_number;
      if getAttributeUsages%notfound  then
        open getApplicationName(applicationIdIn => l_application_id);
        fetch getApplicationName into applicationName;
        close getApplicationName;
        ame_rule_utility_pkg.getAttributeName(p_attribute_id       => l_attribute_id
                                             ,p_attribute_name_out => attributeName);
        fnd_message.set_name('PER','AME_400149_ATT_TTY_NO_USAGE');
        fnd_message.set_token('ATTRIBUTE',attributeName);
        fnd_message.set_token('APPLICATION',applicationName);
        hr_multi_message.add(p_associated_column1 => 'RULE_ID');
      end if;
      close getAttributeUsages;
      ame_attribute_api.updateUseCount(p_attribute_id              => l_attribute_id
                                      ,p_application_id            => tempApplications.item_id
                                      ,p_atu_object_version_number => l_atu_object_version_number);
    end loop;
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    ame_rule_bk6.create_ame_condition_to_rule_a
                 (p_rule_id                => p_rule_id
                 ,p_condition_id           => p_condition_id
                 ,p_object_version_number  => l_cnu_object_version_number
                 ,p_start_date             => l_cnu_start_date
                 ,p_end_date               => l_cnu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_condition_to_rule'
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
  p_object_version_number    := l_cnu_object_version_number;
  p_start_date               := l_cnu_start_date;
  p_end_date                 := l_cnu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ame_condition_to_rule;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number    := null;
    p_start_date           := null;
    p_end_date                 := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ame_condition_to_rule;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number    := null;
    p_start_date           := null;
    p_end_date                 := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ame_condition_to_rule;
--
-- ----------------------------------------------------------------------------
-- |------------------<create_ame_action_to_rule>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_action_to_rule
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_action_id                     in     number
  ,p_object_version_number            out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc            varchar2(72) := g_package||'create_ame_action_to_rule';
  l_dummy           varchar2(10);
  l_action_type_id  ame_action_types.action_type_id%type;
  l_attribute_id    number;
  l_effective_date  date;
  --+
  cursor getActionDetails is
   select aatu.action_type_id
         ,aatu.rule_type
     from ame_action_type_usages aatu
         ,ame_actions aa
    where aa.action_id = p_action_id
      and l_effective_date between aa.start_date
           and nvl(aa.end_date - ame_util.oneSecond, l_effective_date)
      and aa.action_type_id = aatu.action_type_id
      and l_effective_date between aatu.start_date
           and nvl(aatu.end_date - ame_util.oneSecond, l_effective_date);
  --+
  cursor getRuleDetails is
    select rule_type, start_date, end_date, item_class_id
      from ame_rules
      where rule_id = p_rule_id
        and ( l_effective_date between  start_date and
                     nvl(end_date - ame_util.oneSecond,l_effective_date ) or
           (l_effective_date < start_date and
           start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  cursor getReqAttributes(p_application_id in integer
                         ,p_action_type_id in integer) is
    select attribute_id
      from ame_mandatory_attributes ama
      where ama.attribute_id  not in (select attribute_id
                                      from ame_attribute_usages
                                     where application_id = p_application_id
                                       and l_effective_date between start_date
                                       and nvl(end_date - ame_util.oneSecond, l_effective_date))
      and l_effective_date between ama.start_date
      and nvl(ama.end_date - ame_util.oneSecond, l_effective_date)
      and action_type_id = p_action_type_id;
  --+
  cursor getReqAttributeIds(actionIdIn in integer
                           ,ruleIdIn   in integer) is
    select man.attribute_id
      from ame_mandatory_attributes man
          ,ame_action_usages acu
          ,ame_actions act
     where man.action_type_id = act.action_type_id
       and acu.action_id      = act.action_id
       and acu.action_id      = actionIdIn
       and acu.rule_id        = ruleIdIn
       and l_effective_date between man.start_date and nvl(man.end_date - ame_util.oneSecond, l_effective_date)
       and l_effective_date between act.start_date and nvl(act.end_date - ame_util.oneSecond, l_effective_date)
       and ((l_effective_date between acu.start_date and nvl(acu.end_date - ame_util.oneSecond, l_effective_date))
           or
            (l_effective_date < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + ame_util.oneSecond))
           );
  --+
  cursor getApplications(ruleIdIn in integer)is
    select item_id
      from ame_rule_usages
     where rule_id = ruleIdIn
       and (l_effective_date between  start_date
             and nvl(end_date - ame_util.oneSecond, l_effective_date)
           or
           (l_effective_date < start_date
             and start_date < nvl(end_date, start_date + ame_util.oneSecond)));
  --+
  cursor getAttributeUsages(attributeIdIn   in integer
                           ,applicationIdIn in integer) is
    select application_id
          ,use_count
          ,start_date
          ,end_date
          ,object_version_number
     from ame_attribute_usages
    where attribute_id   = attributeIdIn
      and application_id = applicationIdIn
      and l_effective_date between  start_date
           and nvl(end_date - ame_util.oneSecond,l_effective_date);
  --+
  cursor getApplicationIds(p_rule_id in integer) is
  select distinct item_id
    from ame_rule_usages
   where rule_id = p_rule_id
     and ((sysdate between start_date and nvl(end_date - (1/86400),sysdate))
             or
            (sysdate < start_date and start_date < nvl(end_date, start_date + (1/86400)))
           );
  l_action_found                 boolean;
  l_allowAllApproverTypes        varchar2(30);
  l_allowProduction              varchar2(30);
  l_action_type_name             ame_action_types.name%type;
  l_atu_object_version_number    integer;
  l_count                        number;
  l_action_rule_type             number;
  l_item_class_id                number;
  l_application_id               number;
  l_overlapping_usage            number;
  l_rul_object_version_number    number;
  l_rul_start_date               date;
  l_rul_end_date                 date;
  l_rule_type                    ame_rules.rule_type%type;
  l_acu_object_version_number    number;
  l_acu_start_date               date;
  l_acu_end_date                 date;
  l_swi_package_name             varchar2(30) := 'AME_RULE_SWI';
  actionIdList ame_util.idList;
  conditionIdList ame_util.idList;
  appIdList ame_util.idList;
  l_result  number(2);
  l_head_item_class_id           ame_item_classes.item_class_id%type;
  l_aty_name                     ame_action_types.name%type;
  l_swi_call                     boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_action_to_rule;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_rule_bk7.create_ame_action_to_rule_b
                 (p_rule_id   => p_rule_id
                 ,p_action_id => p_action_id
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_action_to_rule'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;

  -- Check the rule type of the rule. Ensure that this action is valid for this rule type.
  open getActionDetails;
  fetch getActionDetails
   into l_action_type_id
       ,l_action_rule_type;
  if getActionDetails%notfound then
    fnd_message.set_name('PER','AME_400736_INV_ACTION_ID');
    hr_multi_message.add(p_associated_column1 => 'ACTION_ID');
  end if;
  close getActionDetails;
  --
  --  Fetch the rule details
  --
  open getRuleDetails;
  fetch getRuleDetails
   into l_rule_type
       ,l_rul_start_date
       ,l_rul_end_date
       ,l_item_class_id;
  if getRuleDetails%notfound then
    fnd_message.set_name('PER','AME_400729_INV_RULE_ID');
    hr_multi_message.add(p_associated_column1 => 'RULE_ID');
  end if;
  close getRuleDetails;
  --+
  --+ Check if the action is of line-item job-level chains of authority action type.
  --+
  select name
    into l_aty_name
    from ame_action_types
   where action_type_id = l_action_type_id
     and sysdate between start_date and nvl(end_date - (1/84600),sysdate);
  --+
  if l_aty_name = 'line-item job-level chains of authority' then
    select item_class_id
      into l_head_item_class_id
      from ame_item_classes
     where name = 'header'
       and sysdate between start_date and nvl(end_date - (1/84600),sysdate);
    if l_head_item_class_id <> l_item_class_id then
      fnd_message.set_name('PER','AME_400449_INV_ACT_TYP_CHOSEN');
      hr_multi_message.add(p_associated_column1 => 'ITEM_CLASS_ID');
    end if;
  end if;
  --+
  --+  Checks to be done for all transaction types using this rule
  --+
    ame_rule_utility_pkg.chekActionForAllApplications(ruleIdIn   => p_rule_id
                                                    ,actionIdIn => p_action_id);
  --+
  -- Fetch conditions and actions for rule
  l_swi_call := true;
  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
    --+
    --+ Check Rule Id.
    --+
    l_swi_call := false;
    ame_rule_utility_pkg.checkRuleId(p_rule_id => p_rule_id);
    --+
    --+ Check Action Id.
    --+
    ame_rule_utility_pkg.checkActionId(p_action_id => p_action_id);
    --+
    --+ Get all the transaction types using this rule.
    --+
    open getApplicationIds(p_rule_id => p_rule_id);
    fetch getApplicationIds
    bulk collect into appIdList;
    --+
    --+ Check if this action is valid for all these transaction types.
    --+
    for i in 1..appIdList.count loop
      l_result := ame_rule_utility_pkg.is_action_allowed(p_application_id => appIdList(i)
                                                        ,p_action_id      => p_action_id);
      if l_result = ame_rule_utility_pkg.ActionNotAllowed then
        fnd_message.set_name('PER','AME_400735_ACT_NOT_IN_APP');
        hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
      elsif l_result = ame_rule_utility_pkg.GroupNotAllowed then
        fnd_message.set_name('PER','AME_400744_GRP_NOT_IN_APP');
        hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
      elsif l_result = ame_rule_utility_pkg.PosActionNotAllowed then
        fnd_message.set_name('PER','AME_400770_POS_APR_NOT_IN_APP');
        hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
      end if;
      --+
      --+ Check the Rule Type and action combination.
      --+
      if not ame_rule_utility_pkg.chk_rule_type(p_rule_id                    => p_rule_id
                                               ,p_rule_type                  => l_rule_type
                                               ,p_action_rule_type           => l_action_rule_type
                                               ,p_application_id             => appIdList(i)
                                               ,p_allow_production_action    => true) then
        fnd_message.set_name('PER','AME_400741_RULE_TYPE_MISMATCH');
        hr_multi_message.add(p_associated_column1 => 'RULE_TYPE');
      end if;
      if l_rule_type = ame_util.listModRuleType then
        if not ame_rule_utility_pkg.chk_lm_actions(p_rule_id   => p_rule_id
                                                  ,p_action_id => p_action_id) then
          fnd_message.set_name('PER','AME_400425_RULE_LM_RULE');
          hr_multi_message.add(p_associated_column1 => 'ACTION_ID');
        end if;
      end if;
    end loop;
    --added till here...
    getConditionIds(ruleIdIn => p_rule_id,
                    conditionIdListOut => conditionIdList);
    getActionIds(ruleIdIn => p_rule_id,
                 actionIdListOut => actionIdList);
    -- check action does not exist in rule already
    l_action_found := false;
    for i in 1..actionIdList.count loop
      if p_action_id = actionIdList(i) then
        l_action_found := true;
      end if;
    end loop;
    if l_action_found then
        fnd_message.set_name('PER','AME_400730_DUPLICATE_ACTION');
        hr_multi_message.add(p_associated_column1 => 'ACTION_ID');
    end if;
    -- add this condition_id to end of list
    l_count := actionIdList.count;
    actionIdList(l_count+1) := p_action_id;
    /*
    if ruleExists(p_rule_id         => p_rule_id
                 ,p_rule_type       => l_rule_type
                 ,p_item_class_id   => l_item_class_id
                 ,p_effective_date  => l_effective_date
                 ,p_conditions_list => conditionIdList
                 ,p_actions_list    => actionIdList
                 )   then
        fnd_message.set_name('PER','AME_400212_RUL_PROP_EXISTS');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
    end if;
    */
  end if;

  -- If the call is from UI, then set the l_effective_date to p_effective_date
  if l_swi_call and p_effective_date is not null then
    l_effective_date := p_effective_date;
  end if;
  --
  -- Calculate Action Usage start and end date.
  --
  if l_effective_date > l_rul_start_date then
    l_acu_start_date := l_effective_date;
  else
    l_acu_start_date := l_rul_start_date;
  end if;
  l_acu_end_date := l_rul_end_date;
  --
  -- insert the row in ame_action_usages
  --
  ame_acu_ins.ins(p_rule_id               => p_rule_id
                 ,p_action_id             => p_action_id
                 ,p_effective_date        => l_effective_date
                 ,p_object_version_number => l_acu_object_version_number
                 ,p_start_date            => l_acu_start_date
                 ,p_end_date              => l_acu_end_date
                 );
  --
  for tempAttribute in getReqAttributeIds(actionIdIn => p_action_id
                                         ,ruleIdIn   => p_rule_id) loop
    for tempApplication in getApplications(ruleIdIn => p_rule_id) loop
      for tempAttributeUsages in getAttributeUsages(attributeIdIn   => tempAttribute.attribute_id
                                                   ,applicationIdIn => tempApplication.item_id) loop
        l_atu_object_version_number := tempAttributeUsages.object_version_number;
        ame_attribute_api.updateUseCount(p_attribute_id              => tempAttribute.attribute_id
                                        ,p_application_id            => tempApplication.item_id
                                        ,p_atu_object_version_number => l_atu_object_version_number);
      end loop;
    end loop;
  end loop;
  --
  -- Call After Process User Hook
  --
  begin
    ame_rule_bk7.create_ame_action_to_rule_a
                 (p_rule_id                => p_rule_id
                 ,p_action_id              => p_action_id
                 ,p_object_version_number  => l_acu_object_version_number
                 ,p_start_date             => l_acu_start_date
                 ,p_end_date               => l_acu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_ame_action_to_rule'
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
  p_object_version_number    := l_acu_object_version_number;
  p_start_date               := l_acu_start_date;
  p_end_date               := l_acu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_ame_action_to_rule;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number    := null;
    p_start_date           := null;
    p_end_date                 := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_ame_action_to_rule;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number    := null;
    p_start_date           := null;
    p_end_date                 := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_ame_action_to_rule;

--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ame_rule >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_rule
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_rule_id                       in     number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                    in out nocopy   date
  ,p_end_date                      in out nocopy   date
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_rul_object_version_number    number;
  l_rul_start_date               date;
  l_rul_end_date                 date;
  l_effective_date               date;
  l_swi_package_name             varchar2(30) := 'AME_RULE_SWI';
  l_proc                         varchar2(72) := g_package||'update_ame_rule';
  l_swi_call                     boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_ame_rule;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_rule_bk3.update_ame_rule_b
                 (p_rule_id                   => p_rule_id
                 ,p_description               => p_description
                 ,p_object_version_number     => p_object_version_number
                 ,p_start_date                => p_start_date
                 ,p_end_date                  => p_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_rule'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate

  l_effective_date := sysdate;
  l_rul_object_version_number := p_object_version_number;
  --+ Check Rule Id.
  ame_rule_utility_pkg.checkRuleId(p_rule_id => p_rule_id);
  if p_rule_id is null then
    fnd_message.set_name('PER', 'AME_400729_INV_RULE_ID');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  end if;
  --
  -- Check if the API is called from the SWI layer. If yes, update start and end dates for rules.
  -- Else only update Description.
  l_swi_call := true;
  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
    l_swi_call := false;
    -- If Description is null and call is not made from SWI layer, then raise an exception.
    if(p_description is null  or
       p_description = hr_api.g_varchar2) then
      fnd_message.set_name('PER','AME_400731_NO_DESCRIPTION');
      hr_multi_message.add(p_associated_column1 => 'DESCRIPTION');
    end if;
    l_rul_start_date := null;
    l_rul_end_date := null;
  else
    l_rul_start_date := p_start_date;
    l_rul_end_date := p_end_date;
  end if;
  if l_swi_call and p_effective_date is not null then
    l_effective_date := p_effective_date;
  end if;
  ame_rul_upd.upd(p_effective_date         => l_effective_date
                 ,p_datetrack_mode         => hr_api.g_update
                 ,p_rule_id                => p_rule_id
                 ,p_object_version_number  => l_rul_object_version_number
                 ,p_description            => p_description
                 ,p_start_date             => l_rul_start_date
                 ,p_end_date               => l_rul_end_date
                 );

  -- update data into TL tables
  if(p_description is not null or
     p_description <> hr_api.g_varchar2) then
    ame_rtl_upd.upd_tl(p_language_code      => p_language_code
                      ,p_rule_id            => p_rule_id
                      ,p_description        => p_description
                      );
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    ame_rule_bk3.update_ame_rule_a
                 (p_rule_id               => p_rule_id
                 ,p_description           => p_description
                 ,p_object_version_number => l_rul_object_version_number
                 ,p_start_date            => l_rul_start_date
                 ,p_end_date              => l_rul_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_rule'
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
  p_object_version_number := l_rul_object_version_number;
  p_start_date            := l_rul_start_date;
  p_end_date              := l_rul_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
       (p_associated_column1 => 'action_id') then
       hr_utility.set_location(' Leaving:'|| l_proc, 50);
       raise;
     end if;
     hr_utility.set_location(' Leaving:'|| l_proc, 60);
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_ame_rule;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_start_date           := null;
    p_end_date             := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_ame_rule;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_start_date           := null;
    p_end_date             := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_ame_rule;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_ame_rule_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_rule_usage
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_application_id                in     number
  ,p_priority                      in     number   default hr_api.g_number
  ,p_approver_category             in     varchar2 default hr_api.g_varchar2
  ,p_old_start_date                in     date
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                    in out nocopy   date
  ,p_end_date                      in out nocopy   date
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_date_changed                 varchar2(10);
  l_swi_package_name             varchar2(30) := 'AME_RULE_SWI';
  l_overlapping_usage            number;
  l_acu_object_version_number    number;
  l_acu_start_date               date;
  l_acu_end_date                 date;
  l_cnu_object_version_number    number;
  l_cnu_start_date               date;
  l_cnu_end_date                 date;
  l_rlu_object_version_number    number;
  l_rlu_start_date               date;
  l_rlu_end_date                 date;
  l_rul_object_version_number    number;
  l_rul_start_date               date;
  l_rul_end_date                 date;
  l_rul_start_date2              date;
  l_rul_end_date2                date;
  l_effective_date               date;
  l_proc                         varchar2(72) := g_package||'update_ame_rule_usage';
  l_swi_call                     boolean;
  --+
  cursor getRuleDetails is
    select start_date
          ,end_date
          ,object_version_number
      from ame_rules
     where rule_id = p_rule_id
       and ((l_effective_date between  start_date and nvl(end_date - ame_util.oneSecond, l_effective_date))
           or
           (l_effective_date < start_date and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  cursor getActions is
    select action_id
          ,start_date
          ,end_date
          ,object_version_number
      from ame_action_usages
     where rule_id = p_rule_id
       and ((l_effective_date between  start_date
              and nvl(end_date - ame_util.oneSecond, l_effective_date))
            or
            (l_effective_date < start_date
              and start_date < nvl(end_date, start_date + ame_util.oneSecond)));
  --+
  cursor getConditions is
    select condition_id
          ,start_date
          ,end_date
          ,object_version_number
      from ame_condition_usages
     where rule_id = p_rule_id
       and ((l_effective_date between  start_date
              and nvl(end_date - ame_util.oneSecond, l_effective_date))
           or
           (l_effective_date < start_date
             and start_date < nvl(end_date, start_date + ame_util.oneSecond)));
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if(p_end_date is not null and TRUNC(p_end_date) = TRUNC(SYSDATE)) then
    delete_ame_rule_usage(p_validate              => p_validate
                         ,p_rule_id               => p_rule_id
                         ,p_application_id        => p_application_id
                         ,p_object_version_number => p_object_version_number
                         ,p_start_date            => p_start_date
                         ,p_end_date              => p_end_date
                          );
    return;
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_ame_rule_usage;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_rule_bk4.update_ame_rule_usage_b
                 (p_rule_id                   => p_rule_id
                 ,p_application_id            => p_application_id
                 ,p_priority                  => p_priority
                 ,p_approver_category         => p_approver_category
                 ,p_old_start_date            => p_old_start_date
                 ,p_object_version_number     => p_object_version_number
                 ,p_start_date                => p_start_date
                 ,p_end_date                  => p_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_rule_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  --+
  --+ Check the dates for the rule usage.
  --+
  l_swi_call := true;
  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
    l_swi_call := false ;
    if p_start_date < l_effective_date then
      fnd_message.set_name('PER','AME_400213_RUL_STRT_GRTR_CUR');
      hr_multi_message.add (p_associated_column1 => 'START_DATE');
    end if;
    if p_end_date < l_effective_date then
      fnd_message.set_name('PER','AME_400706_PAS_END_DATE');
      hr_multi_message.add (p_associated_column1 => 'END_DATE');
    end if;
    if p_start_date > p_end_date then
      fnd_message.set_name('PER','AME_400214_RUL_STRT_LESS_END');
      hr_multi_message.add (p_associated_column1 => 'START_DATE');
    end if;
  end if;
  --+
  --+ Check the Rule Id.
  --+
  ame_rule_utility_pkg.checkRuleId(p_rule_id => p_rule_id);
  --+
  --+ Check the Application Id.
  --+
  ame_rule_utility_pkg.checkApplicationId(p_application_id => p_application_id);
  --
  -- Check that there is no overlapping rule usage existing for the rule_id.
  -- Gaps between the rule usage dates  is allowed.
  --
  l_overlapping_usage :=  checkRuleUsageExists(p_application_id => p_application_id
                                              ,p_rule_id        => p_rule_id
                                              ,p_rlu_start_date => p_start_date
                                              ,p_rlu_end_date   => p_end_date
                                              ,p_effective_date => l_effective_date
                                              ,p_priority       => p_priority
                                              ,p_old_start_date => p_old_start_date);
  if l_overlapping_usage = 1 then
    fnd_message.set_name('PER','AME_400327_RULE_USG_EXST_LIFE');
    hr_multi_message.add (p_associated_column1 => 'RULE_ID');
  elsif l_overlapping_usage = 2 then
    fnd_message.set_name('PER','AME_400328_RULE_USG_DIFF_PRIOR');
    hr_multi_message.add (p_associated_column1 => 'RULE_ID');
  elsif l_overlapping_usage = 3 then
    fnd_message.set_name('PER','AME_400329_RULE_USG_OVER_LIFE');
    hr_multi_message.add (p_associated_column1 => 'RULE_ID');
  end if;
  --
  l_rlu_object_version_number := p_object_version_number;
  l_rlu_start_date            := p_start_date;
  l_rlu_end_date              := p_end_date;
  -- update the row in ame_rule_usages. Parent row locking not needed.
  if l_swi_call and p_effective_date is not null then
    l_effective_date := p_effective_date;
  end if;
  ame_rlu_upd.upd(p_effective_date       => l_effective_date
                   ,p_datetrack_mode       => hr_api.g_update
                   ,p_rule_id              => p_rule_id
                   ,p_item_id              => p_application_id
                   ,p_old_start_date       => p_old_start_date
                   ,p_object_version_number=> l_rlu_object_version_number
                   ,p_priority             => p_priority
                   ,p_approver_category    => p_approver_category
                   ,p_start_date           => l_rlu_start_date
                   ,p_end_date             => l_rlu_end_date
                   );
  --
  -- Perform check to see if rule dates have changed only if the usage dates are being changed and
  -- the call is not from an SWI package
  --
/*if ((instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name||fnd_global.local_chr(ascii_chr => 10)) = 0) and
      p_start_date is null and
      p_end_date is null) then
    fetchNewRuleDates(p_rule_id        => p_rule_id
                     ,p_rlu_start_date => l_rlu_start_date
                     ,p_rlu_end_date   => l_rlu_end_date
                     ,p_rul_start_date => l_rul_start_date
                     ,p_rul_end_date   => l_rul_end_date
                     ,p_date_changed   => l_date_changed
                     ) ;
    if l_date_changed = 'Y' then
      --
      -- date has changed, update the dates for rules, condition usages and action usages
      --
      -- rules
      ame_rul_upd.upd(p_rule_id               => p_rule_id
                     ,p_datetrack_mode        => hr_api.g_update
                     ,p_effective_date        => l_effective_date
                     ,p_object_version_number => l_rul_object_version_number
                     ,p_start_date            => l_rul_start_date
                     ,p_end_date              => l_rul_end_date
                     );
      -- actions usages
       for tempActions in getActions loop
         l_acu_object_version_number := tempActions.object_version_number;
         l_acu_start_date := tempActions.start_date;
         l_acu_end_date := tempActions.end_date;
         ame_acu_upd.upd(p_rule_id               => p_rule_id
                        ,p_datetrack_mode        => hr_api.g_update
                        ,p_action_id             => tempActions.action_id
                        ,p_effective_date        => l_effective_date
                        ,p_object_version_number => l_acu_object_version_number
                        ,p_start_date            => l_acu_start_date
                        ,p_end_date              => l_acu_end_date
                        );
       end loop;
      -- condition usages
       for tempConditions in getConditions loop
         l_cnu_object_version_number := tempConditions.object_version_number;
         l_cnu_start_date := tempConditions.start_date;
         l_cnu_end_date := tempConditions.end_date;
         ame_cnu_upd.upd(p_rule_id               => p_rule_id
                        ,p_datetrack_mode        => hr_api.g_update
                        ,p_condition_id          => tempConditions.condition_id
                        ,p_effective_date        => l_effective_date
                        ,p_object_version_number => l_cnu_object_version_number
                        ,p_start_date            => l_cnu_start_date
                        ,p_end_date              => l_cnu_end_date
                        );
       end loop;
    end if;
  end if;*/
  --+
  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
    ame_rule_utility_pkg.syncRuleObjects(p_rule_id        => p_rule_id);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    ame_rule_bk4.update_ame_rule_usage_a
                 (p_rule_id                   => p_rule_id
                 ,p_application_id            => p_application_id
                 ,p_priority                  => p_priority
                 ,p_approver_category         => p_approver_category
                 ,p_old_start_date            => p_old_start_date
                 ,p_object_version_number     => p_object_version_number
                 ,p_start_date                => p_start_date
                 ,p_end_date                  => p_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_ame_rule_usage'
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
  p_object_version_number := l_rlu_object_version_number;
  p_start_date            := l_rlu_start_date;
  p_end_date              := l_rlu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_ame_rule_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_start_date             := null;
    p_end_date               := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_ame_rule_usage;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_start_date             := null;
    p_end_date               := null;
    --+
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_ame_rule_usage;
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_ame_rule_usage >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_rule_usage
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_application_id                in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                    in out nocopy   date
  ,p_end_date                    in out nocopy   date
  ) is
  --+
  --+ Declare cursors and local variables
  --+
  l_atu_object_version_number    number;
  l_atu_start_date               date;
  l_atu_end_date                 date;
  l_acu_object_version_number    number;
  l_acu_start_date               date;
  l_acu_end_date                 date;
  l_cnu_object_version_number    number;
  l_cnu_start_date               date;
  l_cnu_end_date                 date;
  l_swi_package_name             varchar2(30) := 'AME_RULE_SWI';
  l_rul_object_version_number    number;
  l_rlu_object_version_number    number;
  l_rul_start_date               date;
  l_rul_start_date2              date;
  l_rlu_start_date               date;
  l_rul_end_date                 date;
  l_rul_end_date2                 date;
  l_rlu_end_date                 date;
  l_effective_date               date;
  l_exists                       number;
  l_proc                         varchar2(72) := g_package||'delete_ame_rule_usage';
  l_usage_count                  number;
  --+
  cursor getActions is
    select action_id, start_date, end_date, object_version_number
      from ame_action_usages
      where rule_id = p_rule_id
        and ( l_effective_date between  start_date and
                     nvl(end_date - ame_util.oneSecond,l_effective_date ) or
           (l_effective_date < start_date and
           start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  --+
  cursor getRuleDetails is
    select start_date
          ,end_date
          ,object_version_number
      from ame_rules
     where rule_id = p_rule_id
       and ((l_effective_date between  start_date and nvl(end_date - ame_util.oneSecond, l_effective_date))
           or
           (l_effective_date < start_date and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  cursor getConditions is
    select condition_id
          ,start_date
          ,end_date
          ,object_version_number
      from ame_condition_usages
     where rule_id = p_rule_id
       and ((l_effective_date between  start_date
               and nvl(end_date - ame_util.oneSecond,l_effective_date))
            or
             (l_effective_date < start_date
               and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  cursor getRuleConditions is
    select ame_conditions.attribute_id attribute_id
      from ame_conditions
          ,ame_condition_usages
     where ame_condition_usages.rule_id = p_rule_id
       and (l_effective_date between ame_condition_usages.start_date
             and nvl(ame_condition_usages.end_date - ame_util.oneSecond, l_effective_date)
           or
           (l_effective_date < ame_condition_usages.start_date
             and ame_condition_usages.start_date <
                 nvl(ame_condition_usages.end_date, ame_condition_usages.start_date + ame_util.oneSecond)))
       and ame_condition_usages.condition_id = ame_conditions.condition_id
       and ame_conditions.condition_type <> ame_util.listModConditionType
       and l_effective_date between ame_conditions.start_date
            and nvl(ame_conditions.end_date - ame_util.oneSecond,l_effective_date);
  --+
  cursor getReqAttributes is
    select man.attribute_id
      from ame_mandatory_attributes man
          ,ame_action_usages acu
          ,ame_actions act
     where man.action_type_id = act.action_type_id
       and acu.action_id = act.action_id
       and acu.rule_id = p_rule_id
       and l_effective_date between man.start_date and nvl(man.end_date - ame_util.oneSecond, l_effective_date)
       and l_effective_date between act.start_date and nvl(act.end_date - ame_util.oneSecond, l_effective_date)
       and ((l_effective_date between acu.start_date and nvl(acu.end_date - ame_util.oneSecond, l_effective_date))
           or
            (l_effective_date < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + ame_util.oneSecond))
           );
  --+
  cursor getAttributeUsages(p_attribute_id in number) is
    select attribute_id, use_count, start_date, end_date, object_version_number
      from ame_attribute_usages
      where attribute_id = p_attribute_id
         and application_id = p_application_id
         and  l_effective_date between  start_date and
               nvl(end_date - ame_util.oneSecond,l_effective_date);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ame_rule_usage;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_rule_bk5.delete_ame_rule_usage_b
                 (p_rule_id               => p_rule_id
                 ,p_application_id        => p_application_id
                 ,p_object_version_number => p_object_version_number
                 ,p_start_date            => p_start_date
                 ,p_end_date              => p_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_rule_usage'
        ,p_hook_type   => 'BP'
        );
  end;
  --+
  --+ Check Rule Id.
  --+
  ame_rule_utility_pkg.checkRuleId(p_rule_id => p_rule_id);
  --+
  --+ Check Application Id.
  --+
  ame_rule_utility_pkg.checkApplicationId(p_application_id => p_application_id);
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date            := sysdate;
  l_rlu_object_version_number := p_object_version_number;
  l_rlu_start_date            := p_start_date;
  l_rlu_end_date              := p_end_date;
  -- delete the row in ame_rule_usages
  --
    ame_rlu_del.del(p_effective_date        => l_effective_date
                   ,p_datetrack_mode        => hr_api.g_delete
                   ,p_rule_id               => p_rule_id
                   ,p_item_id               => p_application_id
                   ,p_object_version_number => l_rlu_object_version_number
                   ,p_start_date            => l_rlu_start_date
                   ,p_end_date              => l_rlu_end_date
                   );
  --
  --
  --  Update the attribute usage counts
  --
  for tempconditions in getRuleConditions loop
    for tempAttributeUsages in getAttributeUsages(p_attribute_id => tempconditions.attribute_id) loop
      l_atu_object_version_number := tempAttributeUsages.object_version_number;
    ame_attribute_api.updateUseCount(p_attribute_id              => tempAttributeUsages.attribute_id
                                    ,p_application_id            => p_application_id
                                    ,p_atu_object_version_number => l_atu_object_version_number);
    end loop;
  end loop;
  -- update the use count of req attributes
  for tempAttribute in getReqAttributes loop
    for tempAttributeUsages in getAttributeUsages(p_attribute_id => tempAttribute.attribute_id) loop
      l_atu_object_version_number := tempAttributeUsages.object_version_number;
    ame_attribute_api.updateUseCount(p_attribute_id              => tempAttributeUsages.attribute_id
                                    ,p_application_id            => p_application_id
                                    ,p_atu_object_version_number => l_atu_object_version_number);
    end loop;
  end loop;
  --
  --
  --
  open getRuleDetails;
  fetch getRuleDetails
   into l_rul_start_date
       ,l_rul_end_date
       ,l_rul_object_version_number;
  close getRuleDetails;
  -- If call is not made from an SWI package then
  -- Check number of usages which exist for this rule. If future and current usages at this
  -- point are = 0 delete the Condition Usage, Action Usage and Rule row too.
  --
  --if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name||fnd_global.local_chr(ascii_chr => 10)) = 0) then
    select count(*)
      into l_usage_count
      from ame_rule_usages
     where rule_id  = p_rule_id
       and ((l_effective_date between start_date
             and nvl(end_date - ame_util.oneSecond,l_effective_date))
            or
            (l_effective_date < start_date
              and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
    if l_usage_count = 0 then
      -- actions usages
      for tempActions in getActions loop
        l_acu_object_version_number := tempActions.object_version_number;
        l_acu_start_date            := tempActions.start_date;
        l_acu_end_date              := tempActions.end_date;
        ame_acu_del.del(p_effective_date        => l_effective_date
                       ,p_datetrack_mode        => hr_api.g_delete
                       ,p_rule_id               => p_rule_id
                       ,p_action_id             => tempActions.action_id
                       ,p_object_version_number => l_acu_object_version_number
                       ,p_start_date            => l_acu_start_date
                       ,p_end_date              => l_acu_end_date
                       );
      end loop;
      -- condition usages
      for tempConditions in getConditions loop
        l_cnu_object_version_number := tempConditions.object_version_number;
        l_cnu_start_date            := tempConditions.start_date;
        l_cnu_end_date              := tempConditions.end_date;
        ame_cnu_del.del(p_effective_date        => l_effective_date
                       ,p_datetrack_mode        => hr_api.g_delete
                       ,p_rule_id               => p_rule_id
                       ,p_condition_id          => tempConditions.condition_id
                       ,p_object_version_number => l_cnu_object_version_number
                       ,p_start_date            => l_cnu_start_date
                       ,p_end_date              => l_cnu_end_date
                       );
      end loop;
      -- rule
      ame_rul_del.del(p_effective_date        => l_effective_date
                     ,p_datetrack_mode        => hr_api.g_delete
                     ,p_rule_id               => p_rule_id
                     ,p_object_version_number => l_rul_object_version_number
                     ,p_start_date            => l_rul_start_date
                     ,p_end_date              => l_rul_end_date
                     );
    else
    if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
      ame_rule_utility_pkg.syncRuleObjects(p_rule_id        => p_rule_id);
    end if;
        --+
    end if;
  --end if;
  --
  -- Call After Process User Hook
  --
  begin
    ame_rule_bk5.delete_ame_rule_usage_a
                 (p_rule_id               => p_rule_id
                 ,p_application_id        => p_application_id
                 ,p_object_version_number => l_rlu_object_version_number
                 ,p_start_date            => l_rlu_start_date
                 ,p_end_date              => l_rlu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_rule_usage'
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
  p_object_version_number    := l_rlu_object_version_number;
  p_start_date               := l_rlu_start_date;
  p_end_date                 := l_rlu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_ame_rule_usage;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_start_date := null;
    p_end_date   := null;
    --+
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_ame_rule_usage;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_start_date := null;
    p_end_date   := null;
    --+
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
  end delete_ame_rule_usage;
--
-- ----------------------------------------------------------------------------
-- |------------------<delete_ame_rule_condition >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_rule_condition
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_condition_id                  in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ,p_effective_date                in     date     default null
  ) is
  --+
  --+ Declare cursors
  --+
  l_effective_date               date;
  l_attribute_id                 number;
  --+
    cursor getApplicationName(applicationIdIn in integer)is
    select application_name
      from ame_calling_apps
     where application_id = applicationIdIn
       and sysdate between start_date and nvl(end_date - (1/86400), sysdate);
  --+
  cursor getConditionCount(p_condition_type in varchar2
                          ,p_condition_id   in integer) is
    select count(*)
      from ame_conditions, ame_condition_usages
      where ame_condition_usages.condition_id <> p_condition_id
        and ame_condition_usages.rule_id = p_rule_id
        and ( l_effective_date between  ame_condition_usages.start_date and
                     nvl(ame_condition_usages.end_date - ame_util.oneSecond,l_effective_date ) or
           (l_effective_date < ame_condition_usages.start_date and
           ame_condition_usages.start_date <
              nvl(ame_condition_usages.end_date,ame_condition_usages.start_date + ame_util.oneSecond)))
        and ame_condition_usages.condition_id = ame_conditions.condition_id
        and ame_conditions.condition_type = p_condition_type
        and  l_effective_date between  ame_conditions.start_date and
                     nvl(ame_conditions.end_date - ame_util.oneSecond,l_effective_date );
  --+
  cursor getRuleDetails is
    select rule_type, start_date, end_date, item_class_id
      from ame_rules
      where rule_id = p_rule_id
        and ( l_effective_date between  start_date and
                     nvl(end_date - ame_util.oneSecond,l_effective_date ) or
           (l_effective_date < start_date and
           start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  cursor getApplications is
    select item_id
      from ame_rule_usages
      where rule_id = p_rule_id
        and ( l_effective_date between  start_date and
                     nvl(end_date - ame_util.oneSecond,l_effective_date ) or
           (l_effective_date < start_date and
           start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  cursor getConditionType(conditionIdIn in integer) is
    select condition_type
      from ame_conditions
      where condition_id = conditionIdIn
        and l_effective_date between  start_date
             and nvl(end_date - ame_util.oneSecond,l_effective_date);
  --+
  cursor getAttributeUsages(p_application_id in integer) is
    select  use_count, start_date, end_date, object_version_number
      from ame_attribute_usages
      where attribute_id = l_attribute_id
        and l_effective_date between  start_date and
               nvl(end_date - ame_util.oneSecond,l_effective_date )
        and application_id = p_application_id;
  --+
  cursor getAttributeId is
    select attribute_id
      from ame_conditions
     where condition_id = p_condition_id
        and l_effective_date between  start_date and
               nvl(end_date - ame_util.oneSecond,l_effective_date ) ;
  --+
  --+ Declare local variables
  --+
  l_proc                         varchar2(72) := g_package||'delete_ame_rule_condition ';
  l_dummy                        varchar2(10);
  l_swi_package_name             varchar2(30) := 'AME_RULE_SWI';
  l_condition_type               ame_conditions.condition_type%type;
  l_atu_object_version_number    number;
  l_atu_start_date               date;
  l_atu_end_date                 date;
  l_condition_count              number;
  l_count                        number;
  l_rule_type                    ame_rules.rule_type%type;
  l_item_class_id                number;
  l_application_id               number;
  l_rul_object_version_number    number;
  l_rul_start_date               date;
  l_rul_end_date                 date;
  l_cnu_object_version_number    number;
  l_cnu_start_date               date;
  l_cnu_end_date                 date;
  l_acu_object_version_number    number;
  l_acu_start_date               date;
  l_acu_end_date                 date;
  l_use_count                    number := 0;
  actionIdList                   ame_util.idList;
  conditionIdList                ame_util.idList;
  applicationName                ame_calling_apps.application_name%type;
  attributeName                  ame_attributes.name%type;
  l_swi_call                     boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ame_rule_condition ;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_rule_bk8.delete_ame_rule_condition_b
                 (p_rule_id                => p_rule_id
                 ,p_condition_id           => p_condition_id
                 ,p_object_version_number  => p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_rule_condition'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_cnu_object_version_number := p_object_version_number;
  --  Perform following Integrity checks.
  --  a. If Rule type is Exception rule, then atleast one exception type condition other
  --     than this one should exist in the rule.
  --  b. If Rule type is List-modification or substitution rules atleast one List Modification
  --     or Substitution type condition other than this one should exist in the rule
  --+
  --+ Check Rule Id.
  --+
  ame_rule_utility_pkg.checkRuleId(p_rule_id => p_rule_id);
  --+
  --+ Check Condition Id.
  --+
  ame_rule_utility_pkg.checkConditionId(p_condition_id => p_condition_id);
  --
  --
  --  Fetch the rule details
  --
  open getRuleDetails;
  fetch getRuleDetails into l_rule_type, l_rul_start_date, l_rul_end_date,
                            l_item_class_id;
  if getRuleDetails%notfound then
    fnd_message.set_name('PER','AME_400729_INV_RULE_ID');
    hr_multi_message.add(p_associated_column1 => 'RULE_ID');
  end if;
  close getRuleDetails;
  l_swi_call := true;
  if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
    l_swi_call := false;
    if not ame_rule_utility_pkg.is_cond_exist_in_rule(p_rule_id      => p_rule_id
                                                     ,p_condition_id => p_condition_id) then
      fnd_message.set_name('PER','AME_400772_CON_NOT_EXIST_RULE');
      hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
    end if;
    if l_rule_type = ame_util.exceptionRuleType then
      l_condition_type := ame_util.exceptionConditionType;
      --
      --  Fetch the condition details
      --
      open getConditionCount(p_condition_type => l_condition_type
                            ,p_condition_id   => p_condition_id);
      fetch getConditionCount into l_count;
      close getConditionCount;
      if l_count = 0 then
        fnd_message.set_name('PER','AME_400709_NO_EXC_COND_LCE_RUL');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
      end if;
    elsif l_rule_type in (ame_util.listModRuleType, ame_util.substitutionRuleType) then
      l_condition_type := ame_util.listModConditionType ;
      --
      --  Fetch the condition details
      --
      open getConditionCount(p_condition_type => l_condition_type
                            ,p_condition_id   => p_condition_id);
      fetch getConditionCount into l_count;
      close getConditionCount;
      if l_count = 0 then
        fnd_message.set_name('PER','AME_400710_NO_LM_CON_LMSUB_RUL');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
      end if;
    end if;
    --
    -- Check that there is no other rule with the same combination of actions and conditions
    -- existing.
    --
    -- Fetch conditions and actions for rule
    getConditionIds(ruleIdIn => p_rule_id,
                    conditionIdListOut => conditionIdList);
    getActionIds(ruleIdIn => p_rule_id,
                 actionIdListOut => actionIdList);
    -- Remove this condition_id from list
    l_condition_count := conditionIdList.count;
    for i in 1.. l_condition_count loop
      if conditionIdList(i) = p_condition_id then
        if i = l_condition_count then
          conditionIdList.delete(i);
        else
          conditionIdList(i) := conditionIdList(l_condition_count);
          conditionIdList.delete(l_condition_count);
        end if;
        exit;
      end if;
    end loop;
    /*
    if ruleExists(p_rule_id         => p_rule_id
                 ,p_rule_type       => l_rule_type
                 ,p_item_class_id   => l_item_class_id
                 ,p_effective_date  => l_effective_date
                 ,p_conditions_list => conditionIdList
                 ,p_actions_list    => actionIdList
                 )   then
        fnd_message.set_name('PER','AME_400212_RUL_PROP_EXISTS');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
    end if;
    */
  end if; -- end of if not swi call.

  if l_swi_call and p_effective_date is not null then
    l_effective_date := p_effective_date;
  end if;

  --
  -- Check that an attribute usage exists for the attribute this condition is based on
  -- for all the transaction type's using this rule.
  -- Update the attribute usage counts
  open getConditionType(conditionIdIn => p_condition_id);
  fetch getConditionType into l_condition_type;
  close getConditionType;
  --
  -- delete the row in ame_condition_usages
  --
  ame_cnu_del.del(p_effective_date        => l_effective_date
                 ,p_datetrack_mode        => hr_api.g_delete
                 ,p_rule_id               => p_rule_id
                 ,p_condition_id          => p_condition_id
                 ,p_object_version_number => l_cnu_object_version_number
                 ,p_start_date            => l_cnu_start_date
                 ,p_end_date              => l_cnu_end_date
                 );
  --
  if(l_condition_type <> ame_util.listModConditionType) then
    open getAttributeId;
    fetch getAttributeId into l_attribute_id;
    close getAttributeId;
    --+
    for tempApplications in getApplications loop
      open getAttributeUsages(p_application_id => tempApplications.item_id) ;
      fetch getAttributeUsages into l_use_count, l_atu_start_date, l_atu_end_date,l_atu_object_version_number;
      if getAttributeUsages%notfound  then
        open getApplicationName(applicationIdIn => tempApplications.item_id);
        fetch getApplicationName into applicationName;
        close getApplicationName;
        ame_rule_utility_pkg.getAttributeName(p_attribute_id       => l_attribute_id
                                             ,p_attribute_name_out => attributeName);
        fnd_message.set_name('PER','AME_400149_ATT_TTY_NO_USAGE');
        fnd_message.set_token('ATTRIBUTE',attributeName);
        fnd_message.set_token('APPLICATION',applicationName);
        hr_multi_message.add(p_associated_column1 => 'RULE_ID');
      end if;
      close getAttributeUsages;
      ame_attribute_api.updateUseCount(p_attribute_id              => l_attribute_id
                                      ,p_application_id            => tempApplications.item_id
                                      ,p_atu_object_version_number => l_atu_object_version_number);
    end loop;
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    ame_rule_bk8.delete_ame_rule_condition_a
                 (p_rule_id               => p_rule_id
                 ,p_condition_id          => p_condition_id
                 ,p_object_version_number => l_cnu_object_version_number
                 ,p_start_date            => l_cnu_start_date
                 ,p_end_date              => l_cnu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_rule_condition'
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
  p_object_version_number := l_cnu_object_version_number;
  p_start_date            := l_cnu_start_date;
  p_end_date              := l_cnu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_ame_rule_condition;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := null;
    p_start_date            := null;
    p_end_date              := null;
    --+
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_ame_rule_condition;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number := null;
    p_start_date            := null;
    p_end_date              := null;
    --+
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_ame_rule_condition;
--
-- ----------------------------------------------------------------------------
-- |------------------<delete_ame_rule_action >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_rule_action
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_action_id                     in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ,p_effective_date                in     date     default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc            varchar2(72) := g_package||'delete_ame_rule_action ';
  l_dummy           varchar2(10);
  l_action_type_id  ame_action_types.action_type_id%type;
  l_attribute_id    number;
  l_effective_date  date;
  --+
  cursor getActionCount is
    select count(*)
      from ame_action_usages acu
     where rule_id = p_rule_id
       and ((l_effective_date between start_date and nvl(end_date - ame_util.oneSecond, l_effective_date))
           or
            (l_effective_date < start_date and start_date < nvl(end_date,start_date + ame_util.oneSecond)))
       and action_id <> p_action_id;
  --+
  cursor getRuleDetails is
    select rule_type
          ,start_date
          ,end_date
          ,item_class_id
      from ame_rules
     where rule_id = p_rule_id
       and ((l_effective_date between  start_date and nvl(end_date - ame_util.oneSecond, l_effective_date))
           or
           (l_effective_date < start_date and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  cursor getReqAttributeIds(actionIdIn in integer) is
    select man.attribute_id
      from ame_mandatory_attributes man
          ,ame_actions act
     where man.action_type_id = act.action_type_id
       and act.action_id      = actionIdIn
       and l_effective_date between man.start_date and nvl(man.end_date - ame_util.oneSecond, l_effective_date)
       and l_effective_date between act.start_date and nvl(act.end_date - ame_util.oneSecond, l_effective_date);
  --+
  cursor getApplications(ruleIdIn in integer)is
    select item_id
      from ame_rule_usages
     where rule_id = ruleIdIn
       and (l_effective_date between  start_date
             and nvl(end_date - ame_util.oneSecond, l_effective_date)
           or
           (l_effective_date < start_date
             and start_date < nvl(end_date, start_date + ame_util.oneSecond)));
  --+
  cursor getAttributeUsages(attributeIdIn   in integer
                           ,applicationIdIn in integer) is
    select application_id
          ,use_count
          ,start_date
          ,end_date
          ,object_version_number
      from ame_attribute_usages
     where attribute_id   = attributeIdIn
       and application_id = applicationIdIn
       and l_effective_date between  start_date
            and nvl(end_date - ame_util.oneSecond, l_effective_date);
  --+
  l_count                     number;
  l_allowAllApproverTypes     varchar2(30);
  l_allowProduction           varchar2(30);
  l_action_type_id            number;
  l_atu_object_version_number integer;
  l_rule_type                 ame_rules.rule_type%type;
  l_item_class_id             number;
  l_date_changed              varchar2(10);
  l_application_id            number;
  l_acu_object_version_number number;
  l_acu_start_date            date;
  l_acu_end_date              date;
  l_use_count                 number := 0;
  l_swi_package_name          varchar2(30) := 'AME_RULE_SWI';
  actionIdList                ame_util.idList;
  conditionIdList             ame_util.idList;
  l_swi_call                  boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ame_rule_action ;
  --
  --
  l_swi_call := true;
    if (instrb(DBMS_UTILITY.FORMAT_CALL_STACK,l_swi_package_name) = 0) then
      l_swi_call := false;
    end if;
  --
  -- Call Before Process User Hook
  --
  begin
    ame_rule_bk9.delete_ame_rule_action_b
                 (p_rule_id                => p_rule_id
                 ,p_action_id              => p_action_id
                 ,p_object_version_number  => p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_rule_action '
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date            := sysdate;
  l_acu_object_version_number := p_object_version_number;
  --+
  --+ Check that there is no other rule with the same combination of actions and conditions existing.
  --+
  --+ Fetch conditions and actions for rule
  if not l_swi_call then
    --+ verify the rule_id
    ame_rule_utility_pkg.checkRuleId(p_rule_id => p_rule_id);
    --+ verify the action_id
    ame_rule_utility_pkg.checkActionId(p_action_id => p_action_id);
    --+
    --+ Check that there is atleast one other action defined for this rule, besides this one.
    --+
    open getActionCount;
    fetch getActionCount into l_count;
    close getActionCount;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400724_NO_ACTION_IN_RULE');
      hr_multi_message.add(p_associated_column1 => 'ACTION_ID');
    end if;
    --+
    --+ verify the action can be deleted or not
    --+
    if not ame_rule_utility_pkg.is_action_deletion_allowed
                                  (p_rule_id   => p_rule_id
                                  ,p_action_id => p_action_id) then
      fnd_message.set_name('PER','AME_400739_INV_ACT_DEL_RULE');
      hr_multi_message.add(p_associated_column1 => 'ACTION_ID');
    end if;
    --+
    getConditionIds(ruleIdIn           => p_rule_id,
                    conditionIdListOut => conditionIdList);
    getActionIds(ruleIdIn        => p_rule_id,
                 actionIdListOut => actionIdList);
    -- Remove this action_id from list
    l_count := actionIdList.count;
    for i in 1.. l_count loop
      if actionIdList(i) = p_action_id then
        if i = l_count then
          actionIdList.delete(i);
        else
          actionIdList(i) := actionIdList(l_count);
          actionIdList.delete(l_count);
        end if;
        exit;
      end if;
    end loop;
    /*
    if ruleExists(p_rule_id         => p_rule_id
                 ,p_rule_type       => l_rule_type
                 ,p_item_class_id   => l_item_class_id
                 ,p_effective_date  => l_effective_date
                 ,p_conditions_list => conditionIdList
                 ,p_actions_list    => actionIdList
                 ) then
        fnd_message.set_name('PER','AME_400212_RUL_PROP_EXISTS');
        hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
    end if;
    */
  end if;
  if l_swi_call and p_effective_date is not null then
    l_effective_date := p_effective_date;
  end if;
  --+
  -- delete the row in ame_action_usages
  --+
  ame_acu_del.del(p_effective_date        => l_effective_date
                 ,p_datetrack_mode        => hr_api.g_delete
                 ,p_rule_id               => p_rule_id
                 ,p_action_id             => p_action_id
                 ,p_object_version_number => l_acu_object_version_number
                 ,p_start_date            => l_acu_start_date
                 ,p_end_date              => l_acu_end_date
                 );
  --+
  -- update the use count of req attributes
  --+
  for tempAttribute in getReqAttributeIds(actionIdIn => p_action_id) loop
    for tempApplication in getApplications(ruleIdIn  => p_rule_id) loop
      for tempAttributeUsages in getAttributeUsages(attributeIdIn   => tempAttribute.attribute_id
                                                   ,applicationIdIn => tempApplication.item_id) loop
        l_atu_object_version_number := tempAttributeUsages.object_version_number;
        ame_attribute_api.updateUseCount(p_attribute_id              => tempAttribute.attribute_id
                                        ,p_application_id            => tempApplication.item_id
                                        ,p_atu_object_version_number => l_atu_object_version_number);
      end loop;
    end loop;
  end loop;
  --+
  -- Call After Process User Hook
  --+
  begin
    ame_rule_bk9.delete_ame_rule_action_a
                 (p_rule_id                => p_rule_id
                 ,p_action_id              => p_action_id
                 ,p_object_version_number  => l_acu_object_version_number
                 ,p_start_date             => l_acu_start_date
                 ,p_end_date               => l_acu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_ame_rule_action '
        ,p_hook_type   => 'AP'
        );
  end;
  --+
  -- When in validation only mode raise the Validate_Enabled exception
  --+
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --+
  -- Set all IN OUT and OUT parameters with out values
  --+
  p_object_version_number := l_acu_object_version_number;
  p_start_date            := l_acu_start_date;
  p_end_date              := l_acu_end_date;
  --+
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --+
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --+
    rollback to delete_ame_rule_action ;
    --+
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --+
    p_object_version_number    := null;
    p_start_date               := null;
    p_end_date                 := null;
    --+
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --+
    -- A validation or unexpected error has occured
    --+
    rollback to delete_ame_rule_action ;
    --+
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --+
    p_object_version_number    := null;
    p_start_date               := null;
    p_end_date                 := null;
    --+
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_ame_rule_action ;
--
-- ----------------------------------------------------------------------------
-- |------------------<replace_lm_condition>----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure replace_lm_condition
  (p_validate                      in     boolean  default false
  ,p_rule_id                       in     number
  ,p_condition_id                  in     number
  ,p_object_version_number            out nocopy   number
  ,p_start_date                       out nocopy   date
  ,p_end_date                         out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc             varchar2(72) := g_package||'replace_lm_condition';
  l_dummy            varchar2(10);
  l_swi_package_name varchar2(30) := 'AME_RULE_SWI';
  l_effective_date   date;
  l_condition_type   ame_conditions.condition_type%type;
  l_attribute_id     number;
  --+
  cursor getConditionDetails is
    select condition_type
          ,attribute_id
      from ame_conditions
     where condition_id = p_condition_id
       and l_effective_date between start_date
            and nvl(end_date - ame_util.oneSecond,l_effective_date);
  --+
  cursor getRuleDetails is
    select rule_type
          ,start_date
          ,end_date
          ,item_class_id
      from ame_rules
     where rule_id = p_rule_id
       and (l_effective_date between  start_date
             and nvl(end_date - ame_util.oneSecond,l_effective_date) or
           (l_effective_date < start_date
             and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
  --+
  cursor getApplicationIds(p_rule_id in integer) is
  select distinct item_id
    from ame_rule_usages
   where rule_id = p_rule_id
     and ((sysdate between start_date and nvl(end_date - (1/86400),sysdate))
             or
            (sysdate < start_date and start_date < nvl(end_date, start_date + (1/86400)))
           );
  --+
  l_rule_type                 ame_rules.rule_type%type;
  l_item_class_id             number;
  l_rul_start_date            date;
  l_rul_end_date              date;
  l_count                     number;
  appIdList                   ame_util.idList;
  l_action_id_list            ame_util.idList;
  l_old_condition_id          number;
  l_cnu_object_version_number number;
  l_cnu_start_date            date;
  l_cnu_end_date              date;
  l_new_cnu_start_date        date;
  begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint replace_lm_condition;
  --
  -- Call Before Process User Hook
  --
  begin
  ame_rule_bk10.replace_lm_condition_b
                 (p_rule_id                => p_rule_id
                 ,p_condition_id           => p_condition_id
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'replace_lm_condition'
        ,p_hook_type   => 'BP'
        );
  end;
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  --+
  --+ Check Rule Id.
  --+
  ame_rule_utility_pkg.checkRuleId(p_rule_id => p_rule_id);
  --+
  --+ Check Condition Id.
  --+
  ame_rule_utility_pkg.checkConditionId(p_condition_id => p_condition_id);
  --
  --  Fetch the condition details
  --
  open getConditionDetails;
  fetch getConditionDetails
   into l_condition_type
       ,l_attribute_id ;
  if getConditionDetails%notfound then
    fnd_message.set_name('PER','AME_400494_INVALID_CONDITION');
    hr_multi_message.add(p_associated_column1 => 'CONDITION_ID');
  end if;
  close getConditionDetails;
  --
  --  Fetch the rule details
  --
  open getRuleDetails;
  fetch getRuleDetails
   into l_rule_type
       ,l_rul_start_date
       ,l_rul_end_date
       ,l_item_class_id;
  if getRuleDetails%notfound then
    fnd_message.set_name('PER','AME_400480_INV_RULE_ID');
    hr_multi_message.add(p_associated_column1 => 'RULE_ID');
  end if;
  close getRuleDetails;
  --+
  --+ Error out if condition is not LM.
  --+
  if l_condition_type <> ame_util.listModConditionType then
      fnd_message.set_name('PER','AME_400776_NON_LM_COND');
      hr_multi_message.add (p_associated_column1 => 'CONDITION_ID');
  end if;
  --+
  --+ Error out if rule is not LM/SUB/ LMCOMB.
  --+
  if (l_rule_type = ame_util.combinationRuleType and not ame_rule_utility_pkg.is_LM_comb_rule(p_rule_id)) then
      fnd_message.set_name('PER','AME_400777_NON_LM_SUB_RULE');
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
  end if;
  if l_rule_type not in(ame_util.listModRuleType
                       ,ame_util.substitutionRuleType) then
      fnd_message.set_name('PER','AME_400777_NON_LM_SUB_RULE');
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
  end if;
  --+
  --+ Get the Old Condition ID
  --+
  select cnu.condition_id
    into l_old_condition_id
    from ame_condition_usages cnu
        ,ame_conditions       cnd
   where cnu.rule_id        = p_rule_id
     and cnu.condition_id   = cnd.condition_id
     and cnd.condition_type = ame_util.listModConditionType
     and sysdate between cnd.start_date and nvl(cnd.end_date - (1/86400),sysdate)
     and ((sysdate between cnu.start_date and nvl(cnu.end_date - (1/86400),sysdate))
           or
          (sysdate < cnu.start_date and cnu.start_date < nvl(cnu.end_date, cnu.start_date + (1/86400)))
         );
  --+
  --+ Error out if the new condition id is same as current condition id.
  --+
  if l_old_condition_id = p_condition_id then
    fnd_message.set_name('PER','AME_400778_DIFF_LM_COND');
    hr_multi_message.add (p_associated_column1 => 'CONDITION_ID');
  end if;
  --+
  --+ Check if this condition is valid in all the transaction tyes having this rule.
  --+
  open getApplicationIds(p_rule_id => p_rule_id);
  fetch getApplicationIds
   bulk collect into appIdList;
  for i in 1..appIdList.count loop
    if not ame_rule_utility_pkg.is_condition_allowed(p_application_id => appIdList(i)
                                                    ,p_condition_id   => p_condition_id) then
      fnd_message.set_name('PER','AME_400738_COND_NOT_IN_APP');
      hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
    end if;
  end loop;
  --+
  --+ Verify the actions and conditions
  --+
  getActionIds(ruleIdIn        => p_rule_id
              ,actionIdListOut => l_action_id_list);
  for i in 1..l_action_id_list.count loop
    ame_rule_utility_pkg.chk_LM_action_Condition(p_condition_id     => p_condition_id
                                                ,p_action_id        => l_action_id_list(i)
                                                ,is_first_condition => true);
  end loop;
  --+
  --+ Delete the old condition from the rule.
  --+
  select object_version_number
        ,start_date
        ,end_date
    into l_cnu_object_version_number
        ,l_cnu_start_date
        ,l_cnu_end_date
    from ame_condition_usages
   where condition_id = l_old_condition_id
     and rule_id      = p_rule_id
     and ((sysdate between start_date and nvl(end_date - (1/86400),sysdate))
             or
            (sysdate < start_date and start_date < nvl(end_date, start_date + (1/86400)))
           );
  ame_cnu_del.del(p_effective_date        => l_effective_date
                 ,p_datetrack_mode        => hr_api.g_delete
                 ,p_rule_id               => p_rule_id
                 ,p_condition_id          => l_old_condition_id
                 ,p_object_version_number => l_cnu_object_version_number
                 ,p_start_date            => l_cnu_start_date
                 ,p_end_date              => l_new_cnu_start_date
                 );
  l_cnu_start_date := l_new_cnu_start_date;
  --+
  --+ Insert the new condition for the rule.
  --+
  ame_cnu_ins.ins(p_rule_id               => p_rule_id
                 ,p_condition_id          => p_condition_id
                 ,p_effective_date        => l_effective_date
                 ,p_object_version_number => l_cnu_object_version_number
                 ,p_start_date            => l_cnu_start_date
                 ,p_end_date              => l_cnu_end_date
                 );
  --
  -- Call After Process User Hook
  --
  begin
    ame_rule_bk10.replace_lm_condition_a
                 (p_rule_id                => p_rule_id
                 ,p_condition_id           => p_condition_id
                 ,p_object_version_number  => l_cnu_object_version_number
                 ,p_start_date             => l_cnu_start_date
                 ,p_end_date               => l_cnu_end_date
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'replace_lm_condition'
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
  p_object_version_number    := l_cnu_object_version_number;
  p_start_date               := l_cnu_start_date;
  p_end_date                 := l_cnu_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to replace_lm_condition;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number    := null;
    p_start_date           := null;
    p_end_date                 := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to replace_lm_condition;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number    := null;
    p_start_date           := null;
    p_end_date                 := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end replace_lm_condition;
end ame_rule_api;

/
