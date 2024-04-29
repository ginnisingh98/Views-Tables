--------------------------------------------------------
--  DDL for Package Body AME_RULE_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RULE_UTILITY_PKG" as
/* $Header: ameruleutility.pkb 120.3 2006/08/24 13:08:39 prasashe noship $ */
--+
  function isDescriptionExists(ruleIdIn  in integer
                              ,endDateIn in date) return boolean is
  dummy ame_rules.description%type;
  begin
    select rule1.description into dummy
      from ame_rules rule1
          ,ame_rules rule2
     where rule1.description = rule2.description
       and rule1.end_date = endDateIn
       and ((sysdate between rule2.start_date and nvl(rule2.end_date - (1/86400),sysdate))
             or
            (sysdate < rule2.start_date and rule2.start_date < nvl(rule2.end_date, rule2.start_date + (1/86400)))
           );
    return true;
  exception
    when no_data_found then
      return false;
    when others then
      return true;
  end isDescriptionExists;
--+
  function isProductionAction(actionIdIn in integer) return boolean is
  --+
  dummy number;
  --+
  begin
    select axu.rule_type into dummy
      from ame_actions act
          ,ame_action_type_usages axu
     where act.action_id = actionIdIn
       and act.action_type_id = axu.action_type_id
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
       and sysdate between axu.start_date and nvl(axu.end_date - (1/86400), sysdate);
    --+
    if dummy = 7 then
      return true;
    else
      return false;
    end if;
  exception
    when no_data_found then
      return false;
    when others then
      return false;
  end isProductionAction;
--+
  function isProdRule(ruleIdIn in integer)return boolean is
  dummy number;
  begin
    select rule_type into dummy from ame_rules
     where rule_id = ruleIdIn
       and rownum < 2;
    if dummy = 7 then
      return true;
    else
      return false;
    end if;
  exception
    when no_data_found then
      return false;
    when others then
      return false;
  end isProdRule;
--+
  function hasProductionActions(ruleIdIn  in integer
                               ,endDateIn in date)return boolean is
  --+
  cursor getActions(ruleIdIn in integer) is
    select 'Y'
      from ame_action_types aty
          ,ame_actions act
          ,ame_action_usages acu
          ,ame_rules rul
          ,ame_action_type_usages axu
     where rul.rule_id = ruleIdIn
       and rul.rule_id = acu.rule_id
       and acu.action_id = act.action_id
       and act.action_type_id = aty.action_type_id
       and aty.action_type_id = axu.action_type_id
       and axu.rule_type = 7
       and sysdate between aty.start_date and nvl(aty.end_date - (1/86400), sysdate)
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
       and sysdate between axu.start_date and nvl(axu.end_date - (1/86400), sysdate)
       and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
             or
            (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
           )
       and ((sysdate between acu.start_date and nvl(acu.end_date - (1/86400),sysdate))
             or
            (sysdate < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + (1/86400)))
           );
  --+
  cursor getActions2(ruleIdIn  in integer
                   ,endDateIn in date) is
    select 'Y'
      from ame_action_types aty
          ,ame_actions act
          ,ame_action_usages acu
          ,ame_rules rul
          ,ame_action_type_usages axu
     where rul.rule_id = ruleIdIn
       and rul.rule_id = acu.rule_id
       and acu.action_id = act.action_id
       and act.action_type_id = aty.action_type_id
       and aty.action_type_id = axu.action_type_id
       and axu.rule_type = 7
       and sysdate between aty.start_date and nvl(aty.end_date - (1/86400), sysdate)
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
       and sysdate between axu.start_date and nvl(axu.end_date - (1/86400), sysdate)
       and rul.end_date = endDateIn
       and acu.end_date = rul.end_date;
  --+
  dummy varchar2(1);
  result boolean;
  begin
    result := false;
    if endDateIn is null then
      open getActions(ruleIdIn => ruleIdIn);
      fetch getActions into dummy;
      if(getActions%found) then
        result := true;
      end if;
      close getActions;
    else
      open getActions2(ruleIdIn  => ruleIdIn
                     ,endDateIn => endDateIn);
      fetch getActions2 into dummy;
      if(getActions2%found) then
        result := true;
      end if;
      close getActions2;
    end if;
    return result;
  exception
    when no_data_found then
      return false;
    when others then
      return false;
  end hasProductionActions;
--+
--+
--+
  procedure checkRuleForUsage2(ruleIdIn        in integer
                              ,applicationIdIn in integer
                              ,endDateIn       in date
                              ,resultOut       out nocopy varchar2) as
  --+
  cursor checkAttributeUsagesCursor(ruleIdIn        in integer
                                   ,applicationIdIn in integer
                                   ,endDateIn       in date   ) is
    select distinct atr.attribute_id, atr.name
      from ame_attributes  atr
          ,ame_conditions cond
          ,ame_condition_usages condu
          ,ame_rules rules
     where cond.attribute_id = atr.attribute_id
       and condu.condition_id = cond.condition_id
       and condu.rule_id     = rules.rule_id
       and rules.rule_id     = ruleIdIn
       and cond.condition_type <> ame_util.listModConditionType
       and atr.attribute_id not in (select attribute_id
                                      from ame_attribute_usages
                                     where application_id = applicationIdIn
                                       and sysdate between start_date
                                            and nvl(end_date - (1/86400), sysdate))
       and sysdate between atr.start_date and nvl(atr.end_date - (1/86400), sysdate)
       and sysdate between cond.start_date and nvl(cond.end_date - (1/86400), sysdate)
       and rules.end_date = endDateIn
       and condu.end_date = rules.end_date
     union
     select distinct atr.attribute_id, atr.name
      from ame_attributes  atr
          ,ame_action_usages acu
          ,ame_actions act
          ,ame_mandatory_attributes ama
          ,ame_rules rules
     where ama.attribute_id = atr.attribute_id
       and act.action_id = acu.action_id
       and act.action_type_id = ama.action_type_id
       and acu.rule_id = rules.rule_id
       and rules.rule_id     = ruleIdIn
       and ama.attribute_id not in (select attribute_id
                                      from ame_attribute_usages
                                     where application_id = applicationIdIn
                                       and sysdate between start_date
                                            and nvl(end_date - (1/86400), sysdate))
       and sysdate between atr.start_date and nvl(atr.end_date - (1/86400), sysdate)
       and sysdate between ama.start_date and nvl(ama.end_date - (1/86400), sysdate)
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
       and rules.end_date = endDateIn
       and acu.end_date = rules.end_date;
  --+
  cursor checkItemClass(ruleIdIn        in integer
                       ,applicationIdIn in integer
                       ,endDatein       in date) is
    select name
      from ame_item_classes itc
          ,ame_rules rul
     where rul.item_class_id = itc.item_class_id
       and rul.rule_id = ruleIdIn
       and sysdate between itc.start_date and nvl(itc.end_date - (1/86400), sysdate)
       and rul.end_date = endDateIn
       and itc.item_class_id not in (select item_class_id
                                   from ame_item_class_usages itu
                                  where itu.application_id = applicationIdIn
                                    and sysdate between itu.start_date
                                         and nvl(itu.end_date - (1/86400), sysdate));
  --+
  cursor getApplicationName(applicationIdIn in integer)is
    select application_name
      from ame_calling_apps
     where application_id = applicationIdIn
       and sysdate between start_date and nvl(end_date - (1/86400), sysdate);
  --+
  cursor getItemClass(ruleIdIn  in integer
                     ,endDateIn in date) is
    select 'Y'
      from ame_rules rul
          ,ame_item_classes itc
     where rul.rule_id = ruleIdIn
       and rul.item_class_id = itc.item_class_id
       and itc.name <> ame_util.headerItemClassName
       and sysdate between itc.start_date and nvl(itc.end_date - (1/86400), sysdate)
       and rul.end_date = endDateIn;
  --+
  cursor checkActionTypes(ruleIdIn        in integer
                         ,applicationIdIn in integer
                         ,endDateIn       in date) is
    select distinct aty.action_type_id, aty.name
      from ame_action_types aty
          ,ame_actions act
          ,ame_action_usages acu
          ,ame_rules rul
     where rul.rule_id = ruleIdIn
       and rul.rule_id = acu.rule_id
       and acu.action_id = act.action_id
       and act.action_type_id = aty.action_type_id
       and aty.action_type_id not in (select atf.action_type_id
                                        from ame_action_type_config atf
                                       where atf.application_id = applicationIdIn
                                         and sysdate between atf.start_date
                                              and nvl(atf.end_date - (1/86400), sysdate))
       and sysdate between aty.start_date and nvl(aty.end_date - (1/86400), sysdate)
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
       and rul.end_date = endDateIn
       and acu.end_date = rul.end_date;
  --+
  cursor checkApproverGroups(ruleIdIn        in integer
                            ,applicationIdIn in integer
                            ,endDateIn       in date) is
  select apg.approval_group_id
        ,apg.name
    from ame_action_types aty
        ,ame_actions act
        ,ame_action_usages acu
        ,ame_rules rul
        ,ame_approval_groups apg
   where rul.rule_id = ruleIdIn
     and rul.end_date = endDateIn
     and rul.start_date < endDateIn
     and rul.rule_id = acu.rule_id
     and acu.end_date = rul.end_date
     and acu.start_date >= rul.start_date
     and acu.action_id = act.action_id
     and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
     and act.action_type_id = aty.action_type_id
     and sysdate between aty.start_date and nvl(aty.end_date - (1/86400), sysdate)
     and to_char(apg.approval_group_id) = act.parameter
     and sysdate between apg.start_date and nvl(apg.end_date - (1/86400), sysdate)
     and not exists (select null
                       from ame_approval_group_config agf
                      where agf.application_id = applicationIdIn
                        and agf.approval_group_id = apg.approval_group_id
                        and sysdate between agf.start_date and nvl(agf.end_date - (1/86400), sysdate))
     and aty.name in ('pre-chain-of-authority approvals'
                     ,'post-chain-of-authority approvals'
                     ,'approval-group chain of authority');
    --+
  cursor checkLMConditions(ruleIdIn  in integer
                          ,endDateIn in date) is
    select 'Y'
      from ame_rules rul
          ,ame_conditions con
          ,ame_condition_usages cnu
          ,wf_roles wf
     where rul.rule_id = ruleIdIn
       and con.condition_id = cnu.condition_id
       and con.condition_type = ame_util.listModConditionType
       and cnu.rule_id = rul.rule_id
       and con.parameter_two = wf.name
       and wf.orig_system = 'POS'
       and wf.status = 'ACTIVE'
       and rul.end_date = endDateIn
       and cnu.end_date = rul.end_date;
  --+
  dummy              varchar2(1);
  errorExists        boolean;
  attributeIdList    ame_util.idList;
  attributeNamesList ame_util.stringList;
  itemClassName      ame_item_classes.name%type;
  applicationName    ame_calling_apps.application_name%type;
  tempValue          ame_config_vars.variable_value%type;
  actionTypeIdList   ame_util.idList;
  actionTypeNameList ame_util.stringList;
  endDate            date;
  --+
  begin
    errorExists := false;
    endDate     := endDateIn;
    resultOut   := 'Y';
    hr_multi_message.enable_message_list;
    --+
    --+ get application name
    --+
    open getApplicationName(applicationIdIn => applicationIdIn);
    fetch getApplicationName into applicationName;
    close getApplicationName;
    --+
    --+
    --+
    tempValue := ame_util.getConfigVar
                   (variableNameIn  => ame_util.allowAllICRulesConfigVar
                   ,applicationIdIn => applicationIdIn);
    if(tempValue = ame_util.no) then
      open getItemClass(ruleIdIn  => ruleIdIn
                       ,endDateIn => endDate);
      fetch getItemClass into dummy;
      if(getItemClass%found) then
        fnd_message.set_name('PER','AME_400633_SUBITC_TTY_NO_USAGE');
        fnd_message.set_token('TXTYPENAME',applicationName);
        hr_multi_message.add (p_associated_column1 => 'RULE_ID');
        close getItemClass;
        resultOut := 'N';
        fnd_message.raise_error;
        return;
      end if;
      close getItemClass;
    end if;
    --+
    --+
    --+
    tempValue := ame_util.getConfigVar
                   (variableNameIn  => ame_util.allowAllApproverTypesConfigVar
                   ,applicationIdIn => applicationIdIn);
    if(tempValue = ame_util.no) then
      open checkLMConditions(ruleIdIn  => ruleIdIn
                            ,endDateIn => endDate);
      fetch checkLMConditions into dummy;
      if(checkLMConditions%found) then
        fnd_message.set_name('PER','AME_400641_TTY_INV_APPR_TYPE');
        fnd_message.set_token('TXTYPENAME',applicationName);
        hr_multi_message.add (p_associated_column1 => 'RULE_ID');
        close checkLMConditions;
        resultOut := 'N';
        fnd_message.raise_error;
        return;
      end if;
      close checkLMConditions;
    end if;
    --+
    --+ check prodution functionality
    --+
    tempValue := ame_util.getConfigVar
                   (variableNameIn  => ame_util.productionConfigVar
                   ,applicationIdIn => applicationIdIn);

    if(tempValue <> ame_util.allProductions) then
      if(tempValue <> ame_util.perTransactionProductions and isProdRule(ruleIdIn)) then
        fnd_message.set_name('PER','AME_400639_TTY_NO_PROD_RULES');
        fnd_message.set_token('TXTYPENAME',applicationName);
        hr_multi_message.add (p_associated_column1 => 'RULE_ID');
        resultOut := 'N';
        fnd_message.raise_error;
        return;
      elsif(tempValue <> ame_util.perApproverProductions and hasProductionActions(ruleIdIn,endDate) and not isProdRule(ruleIdIn)) then
        fnd_message.set_name('PER','AME_400640_TTY_NO_PROD_ACTIONS');
        fnd_message.set_token('TXTYPENAME',applicationName);
        hr_multi_message.add (p_associated_column1 => 'RULE_ID');
        resultOut := 'N';
        fnd_message.raise_error;
        return;
      end if;
    end if;
    --+
    --+ check item_class
    --+
    open checkItemClass(ruleIdIn        => ruleIdIn
                       ,applicationIdIn => applicationIdIn
                       ,endDateIn       => endDate);
    fetch checkItemClass into itemClassName;
    if(checkItemClass%found)then
      fnd_message.set_name('PER','AME_400632_ITC_TTY_NO_USAGE');
      fnd_message.set_token('ITEM_CLASS',itemClassName);
      fnd_message.set_token('TXTYPENAME',applicationName);
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
      errorExists := true;
    end if;
    close checkItemClass;
    --+
    --+ check for attributes
    --+
    open checkAttributeUsagesCursor(ruleIdIn        => ruleIdIn
                                   ,applicationIdIn => applicationIdIn
                                   ,endDateIn       => endDate);
    fetch checkAttributeUsagesCursor
      bulk collect into attributeIdList
                       ,attributeNamesList;
    close checkAttributeUsagesCursor;
    if attributeIdList.count > 0 then
      errorExists := true;
    end if;
    for i in 1 .. attributeIdList.count loop
      fnd_message.set_name('PER','AME_400149_ATT_TTY_NO_USAGE');
      fnd_message.set_token('ATTRIBUTE',attributeNamesList(i));
      fnd_message.set_token('APPLICATION',applicationName);
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
    end loop;
    --+
    --+ check for action types
    --+
    open checkActionTypes(ruleIdIn        => ruleIdIn
                         ,applicationIdIn => applicationIdIn
                         ,endDateIn       => endDate);
    fetch checkActionTypes
      bulk collect into actionTypeIdList
                       ,actionTypeNameList;
    close checkActionTypes;
    if actionTypeIdList.count > 0 then
      errorExists := true;
    end if;
    for i in 1 .. actionTypeIdList.count loop
      fnd_message.set_name('PER','AME_400634_ATY_TTY_NO_USAGE');
      fnd_message.set_token('ACTION_TYPE',actionTypeNameList(i));
      fnd_message.set_token('TXTYPENAME',applicationName);
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
    end loop;
    --+
    --+ check for approval groups
    --+
    actionTypeIdList.delete;
    open checkApproverGroups(ruleIdIn        => ruleIdIn
                            ,applicationIdIn => applicationIdIn
                            ,endDateIn       => endDate);
    fetch checkApproverGroups
      bulk collect into actionTypeIdList
                       ,actionTypeNameList;
    close checkApproverGroups;
    if actionTypeIdList.count > 0 then
      errorExists := true;
    end if;
    for i in 1 .. actionTypeIdList.count loop
      fnd_message.set_name('PER','AME_400643_APG_TTY_NO_USAGE');
      fnd_message.set_token('GROUP',actionTypeNameList(i));
      fnd_message.set_token('TXTYPENAME',applicationName);
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
    end loop;
    --+
    if errorExists then
      resultOut := 'N';
      fnd_message.raise_error;
    end if;
  exception
    when others then
      null;
  end checkRuleForUsage2;
--+
--+
--+
  procedure checkRuleForUsage(ruleIdIn        in integer
                             ,applicationIdIn in integer
                             ,endDateIn       in varchar2
                             ,resultOut       out nocopy varchar2) as
  --+
  cursor checkRuleCursor(ruleIdIn        in integer
                        ,applicationIdIn in integer) is
    select 'Y'
      from ame_rule_usages
     where rule_id = ruleIdIn
       and item_id = applicationIdIn
       and ((sysdate between start_date and nvl(end_date - (1/86400),sysdate))
             or
            (sysdate < start_date and start_date < nvl(end_date, start_date + (1/86400)))
           );
  --+
  cursor checkAttributeUsagesCursor(ruleIdIn        in integer
                                   ,applicationIdIn in integer) is
    select distinct atr.attribute_id, atr.name
      from ame_attributes  atr
          ,ame_conditions cond
          ,ame_condition_usages condu
          ,ame_rules rules
     where cond.attribute_id = atr.attribute_id
       and condu.condition_id = cond.condition_id
       and condu.rule_id     = rules.rule_id
       and rules.rule_id     = ruleIdIn
       and cond.condition_type <> ame_util.listModConditionType
       and atr.attribute_id not in (select attribute_id
                                      from ame_attribute_usages
                                     where application_id = applicationIdIn
                                       and sysdate between start_date
                                            and nvl(end_date - (1/86400), sysdate))
       and sysdate between atr.start_date and nvl(atr.end_date - (1/86400), sysdate)
       and sysdate between cond.start_date and nvl(cond.end_date - (1/86400), sysdate)
       and ((sysdate between rules.start_date and nvl(rules.end_date - (1/86400),sysdate))
             or
            (sysdate < rules.start_date and rules.start_date < nvl(rules.end_date, rules.start_date + (1/86400)))
           )
       and ((sysdate between condu.start_date and nvl(condu.end_date - (1/86400),sysdate))
             or
            (sysdate < condu.start_date and condu.start_date < nvl(condu.end_date, condu.start_date + (1/86400)))
           )
     union
     select distinct atr.attribute_id, atr.name
      from ame_attributes  atr
          ,ame_action_usages acu
          ,ame_actions act
          ,ame_mandatory_attributes ama
          ,ame_rules rules
     where ama.attribute_id = atr.attribute_id
       and act.action_id = acu.action_id
       and act.action_type_id = ama.action_type_id
       and acu.rule_id = rules.rule_id
       and rules.rule_id     = ruleIdIn
       and ama.attribute_id not in (select attribute_id
                                      from ame_attribute_usages
                                     where application_id = applicationIdIn
                                       and sysdate between start_date
                                            and nvl(end_date - (1/86400), sysdate))
       and sysdate between atr.start_date and nvl(atr.end_date - (1/86400), sysdate)
       and sysdate between ama.start_date and nvl(ama.end_date - (1/86400), sysdate)
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
       and ((sysdate between rules.start_date and nvl(rules.end_date - (1/86400),sysdate))
             or
            (sysdate < rules.start_date and rules.start_date < nvl(rules.end_date, rules.start_date + (1/86400)))
           )
       and ((sysdate between acu.start_date and nvl(acu.end_date - (1/86400),sysdate))
             or
            (sysdate < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + (1/86400)))
           );

  --+
  cursor checkItemClass(ruleIdIn        in integer
                       ,applicationIdIn in integer) is
    select name
      from ame_item_classes itc
          ,ame_rules rul
     where rul.item_class_id = itc.item_class_id
       and rul.rule_id = ruleIdIn
       and sysdate between itc.start_date and nvl(itc.end_date - (1/86400), sysdate)
       and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
             or
            (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
           )
       and itc.item_class_id not in (select item_class_id
                                   from ame_item_class_usages itu
                                  where itu.application_id = applicationIdIn
                                    and sysdate between itu.start_date
                                         and nvl(itu.end_date - (1/86400), sysdate));
  --+
  cursor getApplicationName(applicationIdIn in integer)is
    select application_name
      from ame_calling_apps
     where application_id = applicationIdIn
       and sysdate between start_date and nvl(end_date - (1/86400), sysdate);
  --+
  cursor getItemClass(ruleIdIn in integer) is
    select 'Y'
      from ame_rules rul
          ,ame_item_classes itc
     where rul.rule_id = ruleIdIn
       and rul.item_class_id = itc.item_class_id
       and itc.name <> ame_util.headerItemClassName
       and sysdate between itc.start_date and nvl(itc.end_date - (1/86400), sysdate)
       and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
             or
            (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
           );
  --+
  cursor checkActionTypes(ruleIdIn        in integer
                         ,applicationIdIn in integer) is
    select distinct aty.action_type_id, aty.name
      from ame_action_types aty
          ,ame_actions act
          ,ame_action_usages acu
          ,ame_rules rul
     where rul.rule_id = ruleIdIn
       and rul.rule_id = acu.rule_id
       and acu.action_id = act.action_id
       and act.action_type_id = aty.action_type_id
       and aty.action_type_id not in (select atf.action_type_id
                                        from ame_action_type_config atf
                                       where atf.application_id = applicationIdIn
                                         and sysdate between atf.start_date
                                              and nvl(atf.end_date - (1/86400), sysdate))
       and sysdate between aty.start_date and nvl(aty.end_date - (1/86400), sysdate)
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
       and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
             or
            (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
           )
       and ((sysdate between acu.start_date and nvl(acu.end_date - (1/86400),sysdate))
             or
            (sysdate < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + (1/86400)))
           );
  --+
  cursor checkApproverGroups(ruleIdIn        in integer
                            ,applicationIdIn in integer) is
    select apg.approval_group_id, apg.name
          from ame_action_types aty
              ,ame_actions act
              ,ame_action_usages acu
              ,ame_rules rul
              ,ame_approval_groups apg
         where rul.rule_id = ruleIdIn
           and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
                 or
                (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
               )
           and rul.rule_id = acu.rule_id
           and ((sysdate between acu.start_date and nvl(acu.end_date - (1/86400),sysdate))
                 or
                (sysdate < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + (1/86400)))
               )
           and acu.action_id = act.action_id
           and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
           and act.action_type_id = aty.action_type_id
           and sysdate between aty.start_date and nvl(aty.end_date - (1/86400), sysdate)
           and to_char(apg.approval_group_id) = act.parameter
           and sysdate between apg.start_date and nvl(apg.end_date - (1/86400), sysdate)
           and not exists (select null
                             from ame_approval_group_config agf
                            where agf.application_id = applicationIdIn
                              and agf.approval_group_id = apg.approval_group_id
                              and sysdate between agf.start_date and nvl(agf.end_date - (1/86400), sysdate))
           and aty.name in ('pre-chain-of-authority approvals'
                           ,'post-chain-of-authority approvals'
                           ,'approval-group chain of authority');
  --+
  cursor checkLMConditions(ruleIdIn in integer) is
    select 'Y'
      from ame_rules rul
          ,ame_conditions con
          ,ame_condition_usages cnu
          ,wf_roles wf
     where rul.rule_id = ruleIdIn
       and con.condition_id = cnu.condition_id
       and cnu.rule_id = rul.rule_id
       and con.parameter_two = wf.name
       and wf.orig_system = 'POS'
       and wf.status = 'ACTIVE'
       and sysdate between con.start_date and nvl(con.end_date - (1/86400), sysdate)
       and ((sysdate between cnu.start_date and nvl(cnu.end_date - (1/86400),sysdate))
             or
            (sysdate < cnu.start_date and cnu.start_date < nvl(cnu.end_date, cnu.start_date + (1/86400)))
           )
       and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
             or
            (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
           );
  --+
  dummy              varchar2(1);
  errorExists        boolean;
  attributeIdList    ame_util.idList;
  attributeNamesList ame_util.stringList;
  itemClassName      ame_item_classes.name%type;
  applicationName    ame_calling_apps.application_name%type;
  tempValue          ame_config_vars.variable_value%type;
  actionTypeIdList   ame_util.idList;
  actionTypeNameList ame_util.stringList;
  endDate            date;
  --+
  begin
    errorExists := false;
    open checkRuleCursor(ruleIdIn        => ruleIdIn
                        ,applicationIdIn => applicationIdIn);
    fetch checkRuleCursor into dummy;
    if(checkRuleCursor%found) then
      close checkRuleCursor;
      resultOut := 'Y';
      return;
    end if;
    close checkRuleCursor;
    --+
    endDate := null;
    if(endDateIn is not null) then
      endDate := to_date(endDateIn,'YYYY:MM:DD:HH24:MI:SS');
    end if;
    if (endDate is not null and endDate < sysdate) then
      checkRuleForUsage2(ruleIdIn        => ruleIdIn
                        ,applicationIdIn => applicationIdIn
                        ,endDateIn       => endDate
                        ,resultOut       => resultOut);
      return;
    end if;
    --+
    resultOut := 'Y';
    hr_multi_message.enable_message_list;
    --+
    --+ get application name
    --+
    open getApplicationName(applicationIdIn => applicationIdIn);
    fetch getApplicationName into applicationName;
    close getApplicationName;
    --+
    --+
    --+
    tempValue := ame_util.getConfigVar
                   (variableNameIn  => ame_util.allowAllICRulesConfigVar
                   ,applicationIdIn => applicationIdIn);
    if(tempValue = ame_util.no) then
      open getItemClass(ruleIdIn => ruleIdIn);
      fetch getItemClass into dummy;
      if(getItemClass%found) then
        fnd_message.set_name('PER','AME_400633_SUBITC_TTY_NO_USAGE');
        fnd_message.set_token('TXTYPENAME',applicationName);
        hr_multi_message.add (p_associated_column1 => 'RULE_ID');
        close getItemClass;
        resultOut := 'N';
        fnd_message.raise_error;
        return;
      end if;
      close getItemClass;
    end if;
    --+
    --+ check LM Conditions
    --+
    tempValue := ame_util.getConfigVar
                   (variableNameIn  => ame_util.allowAllApproverTypesConfigVar
                   ,applicationIdIn => applicationIdIn);
    if(tempValue = ame_util.no) then
      open checkLMConditions(ruleIdIn => ruleIdIn);
      fetch checkLMConditions into dummy;
      if(checkLMConditions%found) then
        fnd_message.set_name('PER','AME_400641_TTY_INV_APPR_TYPE');
        fnd_message.set_token('TXTYPENAME',applicationName);
        hr_multi_message.add (p_associated_column1 => 'RULE_ID');
        close getItemClass;
        resultOut := 'N';
        fnd_message.raise_error;
        return;
      end if;
      close checkLMConditions;
    end if;
    --+
    --+ check prodution functionality
    --+
    tempValue := ame_util.getConfigVar
                   (variableNameIn  => ame_util.productionConfigVar
                   ,applicationIdIn => applicationIdIn);
    if(tempValue <> ame_util.allProductions) then
      if(tempValue <> ame_util.perTransactionProductions and isProdRule(ruleIdIn)) then
        fnd_message.set_name('PER','AME_400639_TTY_NO_PROD_RULES');
        fnd_message.set_token('TXTYPENAME',applicationName);
        hr_multi_message.add (p_associated_column1 => 'RULE_ID');
        resultOut := 'N';
        fnd_message.raise_error;
        return;
      elsif(tempValue <> ame_util.perApproverProductions and hasProductionActions(ruleIdIn,endDate) and not isProdRule(ruleIdIn)) then
        fnd_message.set_name('PER','AME_400640_TTY_NO_PROD_ACTIONS');
        fnd_message.set_token('TXTYPENAME',applicationName);
        hr_multi_message.add (p_associated_column1 => 'RULE_ID');
        resultOut := 'N';
        fnd_message.raise_error;
        return;
      end if;

    end if;
    --+
    --+ check item_class
    --+
    open checkItemClass(ruleIdIn        => ruleIdIn
                       ,applicationIdIn => applicationIdIn);
    fetch checkItemClass into itemClassName;
    if(checkItemClass%found)then
      fnd_message.set_name('PER','AME_400632_ITC_TTY_NO_USAGE');
      fnd_message.set_token('ITEM_CLASS',itemClassName);
      fnd_message.set_token('TXTYPENAME',applicationName);
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
      errorExists := true;
    end if;
    close checkItemClass;
    --+
    --+ check for attributes
    --+
    open checkAttributeUsagesCursor(ruleIdIn        => ruleIdIn
                                   ,applicationIdIn => applicationIdIn);
    fetch checkAttributeUsagesCursor
      bulk collect into attributeIdList
                       ,attributeNamesList;
    close checkAttributeUsagesCursor;
    if attributeIdList.count > 0 then
      errorExists := true;
    end if;
    for i in 1 .. attributeIdList.count loop
      fnd_message.set_name('PER','AME_400149_ATT_TTY_NO_USAGE');
      fnd_message.set_token('ATTRIBUTE',attributeNamesList(i));
      fnd_message.set_token('APPLICATION',applicationName);
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
    end loop;
    --+
    --+ check for action types
    --+
    open checkActionTypes(ruleIdIn        => ruleIdIn
                         ,applicationIdIn => applicationIdIn);
    fetch checkActionTypes
      bulk collect into actionTypeIdList
                       ,actionTypeNameList;
    close checkActionTypes;
    if actionTypeIdList.count > 0 then
      errorExists := true;
    end if;
    for i in 1 .. actionTypeIdList.count loop
      fnd_message.set_name('PER','AME_400634_ATY_TTY_NO_USAGE');
      fnd_message.set_token('ACTION_TYPE',actionTypeNameList(i));
      fnd_message.set_token('TXTYPENAME',applicationName);
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
    end loop;
    --+
    --+ check for approval groups
    --+
    actionTypeIdList.delete;
    open checkApproverGroups(ruleIdIn        => ruleIdIn
                            ,applicationIdIn => applicationIdIn);
    fetch checkApproverGroups
      bulk collect into actionTypeIdList
                       ,actionTypeNameList;
    close checkApproverGroups;
    if actionTypeIdList.count > 0 then
      errorExists := true;
    end if;
    for i in 1 .. actionTypeIdList.count loop
      fnd_message.set_name('PER','AME_400643_APG_TTY_NO_USAGE');
      fnd_message.set_token('GROUP',actionTypeNameList(i));
      fnd_message.set_token('TXTYPENAME',applicationName);
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
    end loop;
    --+
    if errorExists then
      resultOut := 'N';
      fnd_message.raise_error;
    end if;
  exception
    when others then
      null;
  end checkRuleForUsage;
--+
--+
--+
  function isRuleReenabled(ruleIdIn        in integer
                          ,applicationIdIn in integer
                          ,endDateIn       in varchar2) return integer is
  --+
  cursor checkConditions(ruleIdIn  in integer
                        ,endDateIn in date
                        ) is
    select count(*)
      from ame_conditions con
          ,ame_condition_usages cnu
          ,ame_rules rul
     where rul.rule_id = ruleIdIn
       and rul.end_date = endDateIn
       and cnu.rule_id = rul.rule_id
       and cnu.end_date = rul.end_date
       and con.condition_id = cnu.condition_id
       and sysdate between con.start_date and nvl(con.end_date - (1/86400), sysdate);
  --+
  cursor getActions(ruleIdIn  in integer
                   ,endDateIn in date) is
    select count(*)
      from ame_action_usages acu
          ,ame_rules rul
     where rul.rule_id = ruleIdIn
       and rul.end_date = endDateIn
       and acu.rule_id = rul.rule_id
       and acu.end_date = rul.end_date;
  --+
  cursor checkActions(ruleIdIn  in integer
                     ,endDateIn in date
                     ) is
    select count(*)
      from ame_actions act
          ,ame_action_usages acu
          ,ame_rules rul
     where rul.rule_id = ruleIdIn
       and rul.end_date = endDateIn
       and acu.rule_id = rul.rule_id
       and acu.end_date = rul.end_date
       and act.action_id = acu.action_id
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate);
  --+
  cursor checkActionTypes(ruleIdIn  in integer
                         ,endDateIn in date) is
    select 'Y'
      from ame_actions act
          ,ame_action_usages acu
          ,ame_rules rul
          ,ame_action_types aty
     where rul.rule_id = ruleIdIn
       and rul.end_date = endDateIn
       and acu.rule_id = rul.rule_id
       and acu.end_date = rul.end_date
       and act.action_id = acu.action_id
       and act.action_type_id = aty.action_type_id
       and sysdate between aty.start_date and nvl(aty.end_date - (1/86400), sysdate);
  --+
  cursor getConditions(ruleIdIn  in integer
                      ,endDateIn in date) is
    select count(*)
      from ame_condition_usages cnu
          ,ame_rules rul
     where rul.rule_id = ruleIdIn
       and rul.end_date = endDateIn
       and cnu.rule_id = rul.rule_id
       and cnu.end_date = rul.end_date;
  --+
  endDate     date;
  dummy       varchar2(1);
  tempBoolean boolean;
  checkActionCount number:=null;
  getActionCount   number:=null;
  getConditionCount number:=null;
  checkConditionCount number:=null;
  begin
    endDate := to_date(endDateIn,'YYYY:MM:DD:HH24:MI:SS');
    tempBoolean := false;
    if endDate > sysdate then
      return 0;
    end if;
    --+
    if(isDescriptionExists (ruleIdIn  => ruleIdIn
                          ,endDateIn => endDate))then
      return 1;
    end if;
    --+
    open getConditions(ruleIdIn  => ruleIdIn
                      ,endDateIn => endDate);
    fetch getConditions into getConditionCount;
    close getConditions;
    --+
    if getConditionCount > 0 then
      open checkConditions(ruleIdIn  => ruleIdIn
                          ,endDateIn => endDate
                          );
      fetch checkConditions into checkConditionCount;
      close checkConditions;
      if checkConditionCount <> getConditionCount then
        return 1;
      end if;
    end if;
    --+
    open getActions(ruleIdIn  => ruleIdIn
                   ,endDateIn => endDate);
    fetch getActions into getActionCount;
    close getActions;

    if getActionCount > 0 then
      open checkActions(ruleIdIn   => ruleIdIn
                       ,endDateIn  => endDate
                        );
      fetch checkActions into checkActionCount;
      close checkActions;
      if getActionCount <> checkActionCount then
        return 1;
      end if;
    end if;
    --+
    open checkActionTypes(ruleIdIn  => ruleIdIn
                         ,endDateIn => endDate);
    fetch checkActionTypes into dummy;
    if(checkActionTypes%notfound)then
      tempBoolean := true;
    end if;
    close checkActionTypes;
    if tempBoolean then
      return 1;
    end if;
    --+
    return 0;
  exception
    when others then
      return 1;
  end isRuleReenabled;
--+
--+
--+
  procedure enableRule(ruleIdIn        in integer
                      ,ruleEndDateIn   in date
                      ,startDateIn     in date
                      ,endDateIn       in date
                      ,resultOut       out nocopy varchar2) is
  --+
  cursor getConditions(ruleIdIn in integer
                      ,endDateIn in date)is
    select condition_id,created_by,creation_date
      from ame_condition_usages
     where rule_id = ruleIdIn
       and end_date = endDateIn;
  --+
  cursor getACtions(ruleIdIn in integer
                   ,endDateIn in date)is
    select action_id,created_by,creation_date
      from ame_action_usages
     where rule_id = ruleIdIn
       and end_date = endDateIn;
  --+
  tempOVN   integer;
  endDate   date;
  startDate date;
  begin

    startDate  := startDateIn;
    endDate      := endDateIn;
    --+ rule
    insert into ame_rules
    (rule_id
    ,rule_type
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,start_date
    ,end_date
    ,description
    ,rule_key
    ,item_class_id
    ,object_version_number)
    select rule_id
          ,rule_type
          ,created_by
          ,creation_date
          ,fnd_global.user_id
          ,sysdate
          ,fnd_global.user_id
          ,startDate
          ,endDate
          ,description
          ,rule_key
          ,item_class_id
          ,object_version_number+1 from ame_rules
           where rule_id = ruleIdIn
             and end_date = ruleEndDateIn;
    --+ conditions
    for condRec in getConditions(ruleIdIn,ruleEndDateIn) loop
      insert into ame_condition_usages
      (rule_id
      ,condition_id
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,start_date
      ,end_date
      ,object_version_number)
      values(ruleIdIn
            ,condRec.condition_id
            ,condRec.created_by
            ,condRec.creation_date
            ,fnd_global.user_id
            ,sysdate
            ,fnd_global.user_id
            ,startDate
            ,endDate
            ,1);
    end loop;
    --+ actions
    for actionRec in getActions(ruleIdIn,ruleEndDateIn) loop
      insert into ame_action_usages
      (rule_id
      ,action_id
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,start_date
      ,end_date
      ,object_version_number)
      values(ruleIdIn
            ,actionRec.action_id
            ,actionRec.created_by
            ,actionRec.creation_date
            ,fnd_global.user_id
            ,sysdate
            ,fnd_global.user_id
            ,startDate
            ,endDate
            ,1);
    end loop;
    --+
    resultOut := 'Y';
  end enableRule;
--+
--+
--+
  procedure checkAllApplications(ruleIdIn      in integer
                                ,conditionIdIn in integer) is
  --+
  cursor getApplications is
    select aca.application_id, aca.application_name
      from ame_rule_usages rlu
          ,ame_calling_apps aca
     where rlu.rule_id = ruleIdIn
       and aca.application_id = rlu.item_id
       and sysdate between aca.start_date and nvl(aca.end_date - (1/86400), sysdate)
       and (sysdate between rlu.start_date
             and nvl(rlu.end_date - ame_util.oneSecond, sysdate) or
           (sysdate < rlu.start_date
             and rlu.start_date < nvl(rlu.end_date, rlu.start_date + ame_util.oneSecond)));
  --+
  cursor getInvalidAttributes(applicationIdIn in integer
                             ,conditionIdIn   in integer) is
    select atr.attribute_id, atr.name
      from ame_attributes atr
          ,ame_conditions con
     where atr.attribute_id = con.attribute_id
       and con.condition_id = conditionIdIn
       and con.condition_type <> ame_util.listModConditionType
       and sysdate between atr.start_date and nvl(atr.end_date - (1/86400), sysdate)
       and sysdate between con.start_date and nvl(con.end_date - (1/86400), sysdate)
       and not exists (select attribute_id
                         from ame_attribute_usages atu
                        where atu.application_id = applicationIdIn
                          and atu.attribute_id = atr.attribute_id
                          and sysdate between atu.start_date
                               and nvl(atu.end_date - (1/86400), sysdate));
  --+
  cursor checkLMCondition(conditionIdIn in integer) is
    select 'Y'
      from ame_conditions con
          ,wf_roles wf
     where con.condition_id = conditionIdIn
       and con.condition_type = ame_util.listModConditionType
       and con.parameter_two = wf.name
       and wf.orig_system = 'POS'
       and wf.status = 'ACTIVE'
       and sysdate between con.start_date and nvl(con.end_date - (1/86400), sysdate);
  --+
  attributeIdList   ame_util.idList;
  attributeNameList ame_util.stringList;
  tempValue         ame_config_vars.variable_value%type;
  dummy             varchar2(1);
  errorExists       boolean;
  begin
    --+
    errorExists := false;
    for rec in getApplications loop
      attributeIdList.delete;
      attributeNameList.delete;
      open getInvalidAttributes(applicationIdIn => rec.application_id
                               ,conditionIdIn   => conditionIdIn);
      fetch getInvalidAttributes bulk collect into attributeIdList, attributeNameList;
      for i in 1 .. attributeIdList.count loop
        fnd_message.set_name('PER','AME_400149_ATT_TTY_NO_USAGE');
        fnd_message.set_token('ATTRIBUTE',attributeNameList(i));
        fnd_message.set_token('APPLICATION',rec.application_name);
        hr_multi_message.add (p_associated_column1 => 'CONDITION_ID');
        errorExists := true;
      end loop;
      close getInvalidAttributes;
    end loop;
    --+
    for rec in getApplications loop
      tempValue := ame_util.getConfigVar
                 (variableNameIn  => ame_util.allowAllApproverTypesConfigVar
                 ,applicationIdIn => rec.application_id);
      if(tempValue = ame_util.no) then
        open checkLMCondition(conditionIdIn => conditionIdIn);
        fetch checkLMCondition into dummy;
        if(checkLMCondition%found) then
          fnd_message.set_name('PER','AME_400641_TTY_INV_APPR_TYPE');
          fnd_message.set_token('TXTYPENAME',rec.application_name);
          hr_multi_message.add (p_associated_column1 => 'RULE_ID');
        end if;
        close checkLMCondition;
      end if;
    end loop;
    --+
  end checkAllApplications;
--+
--+
--+
  procedure chekActionForAllApplications(ruleIdIn   in integer
                                        ,actionIdIn in integer) is
  --+
  cursor getApplications is
    select aca.application_id, aca.application_name
      from ame_rule_usages rlu
          ,ame_calling_apps aca
     where rlu.rule_id = ruleIdIn
       and aca.application_id = rlu.item_id
       and sysdate between aca.start_date and nvl(aca.end_date - (1/86400), sysdate)
       and (sysdate between rlu.start_date
             and nvl(rlu.end_date - ame_util.oneSecond, sysdate) or
           (sysdate < rlu.start_date
             and rlu.start_date < nvl(rlu.end_date, rlu.start_date + ame_util.oneSecond)));
  --+
  cursor getInvalidActionTypes(applicationIdIn in integer
                              ,actionIdIn      in integer) is
    select aty.action_type_id, aty.name
      from ame_action_types aty
          ,ame_actions act
     where act.action_id = actionIdIn
       and act.action_type_id = aty.action_type_id
       and aty.action_type_id not in (select atf.action_type_id
                                        from ame_action_type_config atf
                                       where atf.application_id = applicationIdIn
                                         and sysdate between atf.start_date
                                              and nvl(atf.end_date - (1/86400), sysdate))
       and sysdate between aty.start_date and nvl(aty.end_date - (1/86400), sysdate)
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate);
  --+
  cursor getInvalidRequiredAttributes(applicationIdIn in integer
                                     ,actionIdIn      in integer) is
    select distinct atr.attribute_id, atr.name
      from ame_attributes atr
          ,ame_mandatory_attributes man
          ,ame_actions act
     where act.action_id = actionIdIn
       and act.action_type_id = man.action_type_id
       and atr.attribute_id = man.attribute_id
       and atr.attribute_id not in (select attribute_id
                                      from ame_attribute_usages atu
                                     where atu.application_id = applicationIdIn
                                       and atu.attribute_id = atr.attribute_id
                                       and sysdate between atu.start_date
                                            and nvl(atu.end_date - (1/86400), sysdate))
       and sysdate between man.start_date and nvl(man.end_date - (1/86400), sysdate)
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate);
  --+
  cursor getInvalidGroups(applicationIdIn in integer
                         ,actionIdIn      in integer) is
    select apg.approval_group_id, apg.name
      from ame_action_types aty
          ,ame_actions act
          ,ame_approval_groups apg
     where act.action_id = actionIdIn
       and act.action_type_id = aty.action_type_id
       and act.parameter = to_char(apg.approval_group_id)
       and apg.approval_group_id not in (select agf.approval_group_id
                                           from ame_approval_group_config agf
                                          where agf.application_id = applicationIdIn
                                            and sysdate between agf.start_date
                                                 and nvl(agf.end_date - (1/86400), sysdate))
       and aty.name in (ame_util.preApprovalTypeName
                       ,ame_util.postApprovalTypeName
                       ,ame_util.groupChainApprovalTypeName)
       and sysdate between aty.start_date and nvl(aty.end_date - (1/86400), sysdate)
       and sysdate between act.start_date and nvl(act.end_date - (1/86400), sysdate)
       and sysdate between apg.start_date and nvl(apg.end_date - (1/86400), sysdate);
  --+
  actionTypeIdList   ame_util.idList;
  actionTypeNameList ame_util.stringList;
  attributeIdList    ame_util.idList;
  attributeNameList  ame_util.stringList;
  tempValue          ame_config_vars.variable_value%type;
  errorExists        boolean;
  begin
    errorExists := false;
    --+
    for rec in getApplications loop
      actionTypeIdList.delete;
      actionTypeNameList.delete;
      --+
      open getInvalidActionTypes(applicationIdIn => rec.application_id
                                ,actionIdIn      => actionIdIn);
      fetch getInvalidActionTypes bulk collect into actionTypeIdList, actionTypeNameList;
      for i in 1 .. actionTypeIdList.count loop
        fnd_message.set_name('PER','AME_400634_ATY_TTY_NO_USAGE');
        fnd_message.set_token('ACTION_TYPE',actionTypeNameList(i));
        fnd_message.set_token('TXTYPENAME',rec.application_name);
        hr_multi_message.add (p_associated_column1 => 'CONDITION_ID');
        errorExists := true;
      end loop;
      close getInvalidActionTypes;
    end loop;
    if errorExists then
      return;
    end if;
    --+
    for rec in getApplications loop
      attributeIdList.delete;
      attributeNameList.delete;
      open getInvalidRequiredAttributes(applicationIdIn => rec.application_id
                                       ,actionIdIn      => actionIdIn);
      fetch getInvalidRequiredAttributes bulk collect into attributeIdList, attributeNameList;
      for i in 1 .. attributeIdList.count loop
        fnd_message.set_name('PER','AME_400149_ATT_TTY_NO_USAGE');
        fnd_message.set_token('ATTRIBUTE',attributeNameList(i));
        fnd_message.set_token('APPLICATION',rec.application_name);
        hr_multi_message.add (p_associated_column1 => 'ACTION_ID');
        errorExists := true;
      end loop;
      close getInvalidRequiredAttributes;
    end loop;
    --+
    if errorExists then
      return;
    end if;
    --+
    for rec in getApplications loop
      tempValue := ame_util.getConfigVar
                     (variableNameIn  => ame_util.productionConfigVar
                     ,applicationIdIn => rec.application_id);
      if(tempValue = ame_util.noProductions and isProductionAction(actionIdIn)) then
        fnd_message.set_name('PER','AME_400640_TTY_NO_PROD_ACTIONS');
        fnd_message.set_token('TXTYPENAME',rec.application_name);
        hr_multi_message.add (p_associated_column1 => 'RULE_ID');
      end if;
    end loop;
    --+
    for rec in getApplications loop
      actionTypeIdList.delete;
      actionTypeNameList.delete;
      --+
      open getInvalidGroups(applicationIdIn => rec.application_id
                           ,actionIdIn      => actionIdIn);
      fetch getInvalidGroups bulk collect into actionTypeIdList, actionTypeNameList;
      for i in 1 .. actionTypeIdList.count loop
        fnd_message.set_name('PER','AME_400643_APG_TTY_NO_USAGE');
        fnd_message.set_token('GROUP',actionTypeNameList(i));
        fnd_message.set_token('TXTYPENAME',rec.application_name);
        hr_multi_message.add (p_associated_column1 => 'CONDITION_ID');
        errorExists := true;
      end loop;
      close getInvalidGroups;
    end loop;
    --+
  end chekActionForAllApplications;
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
  procedure syncRuleObjects(p_rule_id  in           number
                           ,p_effective_date in     date      default null) is

    l_rul_start_date               date;
    l_rul_end_date                 date;
    l_rul_start_date2              date;
    l_rul_end_date2                date;
    l_effective_date               date;
    l_rul_object_version_number    number;
    l_acu_object_version_number    number;
    l_acu_start_date               date;
    l_acu_end_date                 date;
    l_cnu_object_version_number    number;
    l_cnu_start_date               date;
    l_cnu_end_date                 date;
    l_update_rule                  boolean;
    --+
    cursor getActions(l_effective_date in date) is
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
    cursor getConditions(l_effective_date in date) is
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
    --+

    cursor getRuleDetails(l_effective_date in date) is
      select start_date
            ,end_date
            ,object_version_number
        from ame_rules
       where rule_id = p_rule_id
         and ((l_effective_date between  start_date and nvl(end_date - ame_util.oneSecond, l_effective_date))
             or
             (l_effective_date < start_date and start_date < nvl(end_date,start_date + ame_util.oneSecond)));
    --+

  begin

    if p_effective_date is not null and p_effective_date <= sysdate then
      l_effective_date := p_effective_date;
    else
      l_effective_date := sysdate;
    end if;

    open getRuleDetails(l_effective_date);
    fetch getRuleDetails
     into l_rul_start_date
         ,l_rul_end_date
         ,l_rul_object_version_number;
    close getRuleDetails;
    --+

    fetchNewRuleDates2(p_rule_id        => p_rule_id
                      ,p_rul_start_date => l_rul_start_date2
                      ,p_rul_end_date   => l_rul_end_date2);
    --+
    l_update_rule := false;
    if l_rul_start_date < l_effective_date then
      if l_rul_start_date2 > l_rul_start_date then
        l_update_rule := true;
        l_rul_start_date := l_rul_start_date2;
      end if;
    elsif l_rul_start_date = l_effective_date then
      null;
    else
      if l_rul_start_date2 <> l_rul_start_date then
        l_update_rule := true;
        l_rul_start_date := l_rul_start_date2;
      end if;
    end if;
      --+
    if l_rul_end_date2 <> l_rul_end_date then
      l_update_rule := true;
      l_rul_end_date := l_rul_end_date2;
    end if;
    --+
    if l_update_rule then
      --+
      for tempActions in getActions(l_effective_date) loop
        l_acu_object_version_number := tempActions.object_version_number;
        l_acu_start_date            := tempActions.start_date;
        l_acu_end_date              := tempActions.end_date;
        ame_acu_upd.upd(p_effective_date        => l_effective_date
                       ,p_datetrack_mode        => hr_api.g_update
                       ,p_rule_id               => p_rule_id
                       ,p_action_id             => tempActions.action_id
                       ,p_object_version_number => l_acu_object_version_number
                       ,p_start_date            => l_rul_start_date
                       ,p_end_date              => l_rul_end_date
                       );
      end loop;
      -- condition usages
      for tempConditions in getConditions(l_effective_date) loop
        l_cnu_object_version_number := tempConditions.object_version_number;
        l_cnu_start_date            := tempConditions.start_date;
        l_cnu_end_date              := tempConditions.end_date;
        ame_cnu_upd.upd(p_effective_date        => l_effective_date
                       ,p_datetrack_mode        => hr_api.g_update
                       ,p_rule_id               => p_rule_id
                       ,p_condition_id          => tempConditions.condition_id
                       ,p_object_version_number => l_cnu_object_version_number
                       ,p_start_date            => l_rul_start_date
                       ,p_end_date              => l_rul_end_date
                       );
      end loop;
      -- rule
      ame_rul_upd.upd(p_effective_date        => l_effective_date
                     ,p_datetrack_mode        => hr_api.g_update
                     ,p_rule_id               => p_rule_id
                     ,p_object_version_number => l_rul_object_version_number
                     ,p_start_date            => l_rul_start_date
                     ,p_end_date              => l_rul_end_date
                   );
      --+
    end if;
  end syncRuleObjects;
  --+

  procedure getAttributeName(p_attribute_id       in         number
                            ,p_attribute_name_out out nocopy varchar2) is
  cursor getAtrName(p_attribute_id in number) is
  select name
    from ame_attributes
   where attribute_id = p_attribute_id
     and sysdate between start_date and nvl(end_date-(1/84600),sysdate);
  begin
   open getAtrName(p_attribute_id => p_attribute_id);
    fetch getAtrName
     into p_attribute_name_out;
    close getAtrName;
  exception
    when others then
      null;
  end getAttributeName;
--+
--+ validates the rule id.
--+ Invoked from all the public callable api except create_ame_rule
--+
  procedure checkRuleId(p_rule_id  in           number) is
  --+
  cursor checkRule(p_rule_id  in           number) is
  select count(*)
    from ame_rules
   where rule_id = p_rule_id
       and ((sysdate between start_date and nvl(end_date - (1/86400),sysdate))
             or
            (sysdate < start_date and start_date < nvl(end_date, start_date + (1/86400)))
           );
  l_count number(3);
  --+
  begin
    open checkRule(p_rule_id);
     fetch checkRule
     into l_count;
    --+
    close checkRule;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400729_INV_RULE_ID');
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
    end if;
  end checkRuleId;
--+
--+ validates the action id.
--+ Invoked from create_ame_rule, create_ame_action_to_rule,
--+ update_ame_rule_action and delete_ame_rule_action.
--+
  procedure checkActionId(p_action_id  in           number) is
  --+
  cursor checkAction(p_action_id  in           number) is
  select count(*)
    from ame_actions
   where action_id = p_action_id
     and sysdate between start_date and nvl(end_date - (1/86400),sysdate);
  l_count number(3);
  --+
  begin
    open checkAction(p_action_id);
     fetch checkAction
      into l_count;
    close checkAction;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400736_INV_ACTION_ID');
      hr_multi_message.add (p_associated_column1 => 'ACTION_ID');
    end if;
  end checkActionId;
--+
--+ validates the condition id.
--+ Invoked from create_ame_rule, create_ame_condition_to_rule,
--+ update_ame_rule_condition and delete_ame_rule_condition.
--+
  procedure checkConditionId(p_condition_id  in           number) is
  --+
  cursor checkCondition(p_condition_id  in           number) is
  select count(*)
    from ame_conditions
   where condition_id = p_condition_id
     and sysdate between start_date and nvl(end_date - (1/86400),sysdate);
  l_count number(3);
  --+
  begin
    open checkCondition(p_condition_id);
     fetch checkCondition
      into l_count;
    close checkCondition;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400737_INV_COND_ID');
      hr_multi_message.add (p_associated_column1 => 'CONDITION_ID');
    end if;
  end checkConditionId;
--+
--+ Validates the Application Id
--+ Invoked from create_ame_rule, create_ame_rule_usage,
--+ update_ame_rule_usage and delete_ame_rule_usage.
--+
  procedure checkApplicationId(p_application_id  in           number)is
  --+
  cursor checkApplication(p_application_id  in           number) is
  select count(*)
    from ame_calling_apps
   where application_id = p_application_id
     and sysdate between start_date and nvl(end_date-(1/84600),sysdate);
  l_count number(3);
  --+
  begin
    open checkApplication(p_application_id);
     fetch checkApplication
     into l_count;
    close checkApplication;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400732_INV_APPLICATION_ID');
      hr_multi_message.add (p_associated_column1 => 'ITEM_ID');
    end if;
  end checkApplicationId;
--+
--+ Invoked from create_ame_rule
--+ returns the no. of conditions attached to the rule
--+
  function rule_conditions_count(p_rule_id  in integer) return integer is
  --+
  cursor rulCndCnt(p_rule_id in number) is
  select count(*)
    from ame_rules rul
        ,ame_condition_usages cnu
   where rul.rule_id = p_rule_id
     and cnu.rule_id = rul.rule_id
     and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
          or
          (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
         )
     and sysdate between cnu.start_date and nvl(cnu.end_date - (1/86400),sysdate);
  l_count number(3);
  --+
  begin
    open rulCndCnt(p_rule_id);
     fetch rulCndCnt
      into l_count;
    close rulCndCnt;
    return l_count;
  end rule_conditions_count;
--+
--+ Invoked from create_ame_rule and is_rule_usage_allowed.
--+ Validates if this action's action type has a config in this application.
--+
  function is_action_allowed(p_application_id   in integer
                            ,p_action_id        in integer) return number is
   --+ get All non-group actions.
  cursor getActions(p_application_id   in integer
                   ,p_action_id        in integer) is
  select count(act.action_id)
    from ame_actions act
        ,ame_action_type_config atf
        ,ame_action_types aty
   where act.action_id = p_action_id
     and atf.application_id = p_application_id
     and act.action_type_id = atf.action_type_id
     and act.action_type_id = aty.action_type_id
     and sysdate between act.start_date and nvl(act.end_date - (1/86400),sysdate)
     and sysdate between atf.start_date and nvl(atf.end_date - (1/86400),sysdate)
     and sysdate between aty.start_date and nvl(aty.end_date - (1/86400),sysdate)
     and aty.name not in ('approval-group chain of authority'
                         ,'pre-chain-of-authority approvals'
                         ,'post-chain-of-authority approvals');
  --+ get all position actions.
  cursor getPosActions(p_application_id   in integer
                      ,p_action_id        in integer) is
  select count(*)
    from ame_actions act
        ,ame_action_type_config atf
        ,ame_action_types aty
   where act.action_id = p_action_id
     and atf.application_id = p_application_id
     and act.action_type_id = atf.action_type_id
     and act.action_type_id = aty.action_type_id
     and sysdate between act.start_date and nvl(act.end_date - (1/86400),sysdate)
     and sysdate between atf.start_date and nvl(atf.end_date - (1/86400),sysdate)
     and sysdate between aty.start_date and nvl(aty.end_date - (1/86400),sysdate)
     and aty.name in ('hr position'
                     ,'hr position level');
  --+ get all group actions.
  cursor getGroupActions(p_application_id   in integer
                        ,p_action_id        in integer) is
  select act.parameter
    from ame_actions act
        ,ame_action_type_config atf
        ,ame_action_types aty
   where act.action_id = p_action_id
     and atf.application_id = p_application_id
     and act.action_type_id = atf.action_type_id
     and aty.action_type_id = act.action_type_id
     and sysdate between act.start_date and nvl(act.end_date - (1/86400),sysdate)
     and sysdate between atf.start_date and nvl(atf.end_date - (1/86400),sysdate)
     and sysdate between aty.start_date and nvl(aty.end_date - (1/86400),sysdate)
     and aty.name in ('approval-group chain of authority'
                     ,'pre-chain-of-authority approvals'
                     ,'post-chain-of-authority approvals');
  --+
  l_group_param ame_actions.parameter%type;
  l_count number(3);
  l_pos_count number(3);
  --+
  begin
    --+
    open getPosActions(p_application_id => p_application_id
                   ,p_action_id      => p_action_id);
      fetch getPosActions
       into l_pos_count;
    close getPosActions;
    --+
    if l_pos_count > 0 then
      --+
      if is_all_approver_types_allowed(p_application_id => p_application_id) then
        return NoErrors;
      else
        return PosActionNotAllowed;
      end if;
      --+
    end if;
    --+
    open getGroupActions(p_application_id => p_application_id
                        ,p_action_id      => p_action_id);
     fetch getGroupActions
      into l_group_param;
    --+
    if getGroupActions%NOTFOUND then
      --+
      open getActions(p_application_id => p_application_id
                     ,p_action_id      => p_action_id);
       fetch getActions
        into l_count;
      close getActions;
      --+
      if l_count = 0 then
        return ActionNotAllowed;
      else
        return NoErrors;
      end if;
      --+
    else
      --+
      if not is_group_allowed(p_application_id    => p_application_id
                           ,p_approval_group_id => l_group_param) then
        return GroupNotAllowed;
      else
        return NoErrors;
      end if;
      --+
    end if;
    --+
    close getGroupActions;
  end is_action_allowed;
--+
--+ Invoked from create_ame_action_to_rule and create_ame_rule
--+ checks if all the actions for this rule have config
--+ in this transaction type.
--+
  function is_rule_usage_allowed(p_application_id in integer
                                ,p_rule_id        in integer) return number is
  --+
  cursor getRuleActions(p_rule_id in integer) is
  select acu.action_id
    from ame_action_usages acu
        ,ame_rules rul
   where rul.rule_id = acu.rule_id
    and rul.rule_id = p_rule_id
    and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
         or
         (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
        )
    and ((sysdate between acu.start_date and nvl(acu.end_date - (1/86400),sysdate))
         or
         (sysdate < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + (1/86400)))
        );
  --+
  actionIdList ame_util.idList;
  l_result     number(2);
  begin
    --+
    open getRuleActions(p_rule_id => p_rule_id);
     fetch getRuleActions
     bulk collect into actionIdList;
    --+
    for i in 1..actionIdList.count loop
      --+
      l_result := is_action_allowed(p_application_id => p_application_id
                                   ,p_action_id      => actionIdList(i));
      --+
      if l_result = ActionNotAllowed then
        close getRuleActions;
        return ActionNotAllowedInTTY;
      elsif l_result = GroupNotAllowed then
        close getRuleActions;
        return GroupNotAllowedInTTY;
      elsif l_result = PosActionNotAllowed then
        close getRuleActions;
        return PosActionNotAllowedInTTY;
      end if;
      --+
    end loop;
    --+
    close getRuleActions;
    return NoErrors;
  end is_rule_usage_allowed;
--+
--+ Invoked from create_ame_rule and create_ame_condition_to_rule.
--+ Validates if the rule can be added to the transaction type.
--+
  function is_rule_usage_cond_allowed(p_application_id in integer
                                     ,p_rule_id        in integer) return boolean is
  --+
  cursor getRuleConditions(p_rule_id in integer) is
  select cnu.condition_id
    from ame_condition_usages cnu
        ,ame_rules rul
   where rul.rule_id = cnu.rule_id
    and rul.rule_id = p_rule_id
    and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
         or
         (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
        )
    and ((sysdate between cnu.start_date and nvl(cnu.end_date - (1/86400),sysdate))
         or
         (sysdate < cnu.start_date and cnu.start_date < nvl(cnu.end_date, cnu.start_date + (1/86400)))
        );
  --+
  conditionIdList ame_util.idList;
  begin
    --+
    open getRuleConditions(p_rule_id => p_rule_id);
     fetch getRuleConditions
      bulk collect into conditionIdList;
    --+
    for i in 1..conditionIdList.count loop
      --+
      if not is_condition_allowed(p_application_id => p_application_id
                                 ,p_condition_id   => conditionIdList(i)) then
        close getRuleConditions;
        return false;
      end if;
      --+
    end loop;
    --+
    close getRuleConditions;
    return true;
  end is_rule_usage_cond_allowed;
--+
--+ Validates the rule type and action combination.
--+
  function chk_rule_type(p_rule_id                    in integer
                        ,p_rule_type                  in integer
                        ,p_action_rule_type           in integer
                        ,p_application_id             in integer
                        ,p_allow_production_action    in boolean) return boolean is
  l_rule_type   ame_rules.rule_type%type;
  --+
  begin
    --+
    l_rule_type := p_rule_type;
    --+
    if not p_allow_production_action then
      if p_rule_type <> 7 and p_action_rule_type = 7 then
        return false;
      end if;
    end if;
    --+
    if l_rule_type = 2 then
      l_rule_type := 1;
    end if;
    --+
    if P_action_rule_type = 7 then
      --+
      if p_allow_production_action then
        --+
        if (not is_prod_action_allowed(p_application_id))then
          return false;
        else
          return true;
        end if;
        --+
      end if;
      --+
    elsif l_rule_type <> 0 then
      --+
      if l_rule_type <> p_action_rule_type then
        return false;
      end if;
      --+
    else
      --+
      if is_LM_comb_rule(p_rule_id) then
        --+
        if p_action_rule_type = 3 or p_action_rule_type = 4 then
          return true;
        else
          return false;
        end if;
        --+
      else
        --+_
        if p_action_rule_type = 3 or p_action_rule_type = 4 then
          return false;
        else
          return true;
        end if;
        --+
      end if;
      --+
    end if;
    --+
    return true;
  end chk_rule_type;
 --+
 --+ Invoked from chkRuleType and create_ame_rule.
 --+
  function is_prod_action_allowed(p_application_id in integer) return boolean is
  temp   ame_config_vars.variable_value%type;
  begin
    --+
    temp := ame_util.getConfigVar
                    (variableNameIn  => ame_util.productionConfigVar
                    ,applicationIdIn => p_application_id);
    --+
    if temp = 'all' or temp = 'approver' then
      return true;
    else
      return false;
    end if;
    --+
  end is_prod_action_allowed;
  --+
  --+ Invoked from chkRuleType and create_ame_rule
  --+ Determines whether the given rule is Combination LM rule or not.
  --+
  function is_LM_comb_rule(p_rule_id in integer) return boolean is
  --+
  cursor getLMConditions(p_rule_id in integer) is
   select count(*)
     from ame_rules             rul
         ,ame_condition_usages  cnu
         ,ame_conditions        cnd
    where rul.rule_id        = p_rule_id
      and cnu.rule_id        = rul.rule_id
      and cnd.condition_id   = cnu.condition_id
      and cnd.condition_type = ame_util.listModConditionType
      and rul.rule_type      = 0
      and sysdate between cnd.start_date and nvl(cnd.end_date - (1/86400),sysdate)
      and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
         or
         (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
        )
      and ((sysdate between cnu.start_date and nvl(cnu.end_date - (1/86400),sysdate))
         or
         (sysdate < cnu.start_date and cnu.start_date < nvl(cnu.end_date, cnu.start_date + (1/86400)))
        );
  --+
  l_count  number(5);
  begin
    --+
    open getLMConditions(p_rule_id => p_rule_id);
     fetch getLMConditions
      into l_count;
    close getLMConditions;
    --+
    if l_count = 0 then
      return false;
    else
      return true;
    end if;
    --+
  end is_LM_comb_rule;
  --+
  --+ Invoked from create_ame_rule and create_ame_rule_usage.
  --+
  function is_condition_allowed(p_application_id in integer
                               ,p_condition_id   in integer) return boolean is
  --+ Check if this application has a usage for the attribute on which the condition is based.
  cursor getConditions(p_application_id   in integer
                      ,p_condition_id     in integer) is
  select count(*)
    from ame_conditions cnd
        ,ame_attribute_usages atu
   where cnd.condition_id = p_condition_id
     and cnd.condition_type <> ame_util.listModConditionType
     and atu.application_id = p_application_id
     and cnd.attribute_id   = atu.attribute_id
     and sysdate between cnd.start_date and nvl(cnd.end_date - (1/86400),sysdate)
     and sysdate between atu.start_date and nvl(atu.end_date - (1/86400),sysdate);
  --+
  l_count number(3);
  lm_count number(3);
  lm_param2 ame_conditions.parameter_two%type;
  begin
    --+
    select count(*)
      into lm_count
      from ame_conditions
     where condition_type = ame_util.listModConditionType
       and condition_id = p_condition_id
       and sysdate between start_date and nvl(end_date - (1/86400),sysdate);
    --+
    if lm_count = 0 then
      --+
      open getConditions(p_application_id => p_application_id
                        ,p_condition_id      => p_condition_id);
       fetch getConditions
        into l_count;
      close getConditions;
      --+
      if l_count = 0 then
        return false;
      else
        return true;
      end if;
      --+
    else
      --+
      select parameter_two
        into lm_param2
        from ame_conditions
       where condition_id = p_condition_id
         and sysdate between start_date and nvl(end_date - (1/86400),sysdate);
      --+
      if is_pos_approver(p_name => lm_param2) then
        --+
        if is_all_approver_types_allowed(p_application_id => p_application_id) then
          return true;
        else
          return false;
        end if;
        --+
      end if;
      --+
      return true;
    end if;
    --+
  end is_condition_allowed;
  --+
  --+ invoked from delete_ame_rule_action
  --+
  function is_action_deletion_allowed(p_rule_id   in integer
                                  ,p_action_id in integer) return boolean is
  --+
  --+ getNonProdActionCnt will return the number of non-production
  --+ actions exist in a non-production rule.
  --+ For a prod rule, the number of actions would be returned
  --+
  cursor getNonProdActionCnt(p_rule_id in integer
                            ,p_action_id in integer) is
  select count(*)
    from ame_rules              rul
        ,ame_action_usages      acu
        ,ame_action_type_usages atyu
        ,ame_actions            act
   where act.action_id <> p_action_id
     and rul.rule_id   = p_rule_id
     and rul.rule_id   = acu.rule_id
     and acu.action_id = act.action_id
     and act.action_type_id = atyu.action_type_id
     and (atyu.rule_type <> ame_util.productionRuleType
           or rul.rule_type <> ame_util.productionRuleType)
      and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
         or
         (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
        )
      and ((sysdate between acu.start_date and nvl(acu.end_date - (1/86400),sysdate))
         or
         (sysdate < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + (1/86400)))
        )
     and sysdate between act.start_date and nvl(act.end_date - (1/86400),sysdate)
     and sysdate between atyu.start_date and nvl(atyu.end_date - (1/86400),sysdate);
  --+
  l_count number(3);
  --+
  begin
    --+
    open getNonProdActionCnt(p_rule_id   => p_rule_id
                            ,p_action_id => p_action_id);
     fetch getNonProdActionCnt
      into l_count;
    close getNonProdActionCnt;
    --+
    if l_count = 0 then
      return false;
    else
      return true;
    end if;
    --+
  end is_action_deletion_allowed;
  --+
  --+ create_ame_rule
  --+ only for api [not for ui]
  --+ to verify the action and LM condition combination
  --+
  procedure chk_LM_action_Condition(p_condition_id     in integer
                                   ,p_action_id        in integer
                                   ,is_first_condition in boolean) is
  --+
  cursor getConditionParam(p_condition_id in integer) is
  select parameter_one
        ,parameter_two
    from ame_conditions
   where condition_id = p_condition_id
     and sysdate between start_date and nvl(end_date - (1/86400),sysdate);
  --+
  cursor getActionType(p_action_id in integer) is
  select aty.name
    from ame_actions act
        ,ame_action_types aty
   where act.action_id = p_action_id
     and aty.action_type_id = act.action_type_id
     and sysdate between act.start_date and nvl(act.end_date - (1/86400),sysdate)
     and sysdate between aty.start_date and nvl(aty.end_date - (1/86400),sysdate);
  --+
  l_param       ame_conditions.parameter_one%type;
  l_param_two   ame_conditions.parameter_two%type;
  l_action_type ame_action_types.name%type;
  --+
  begin
    open getConditionParam(p_condition_id => p_condition_id);
     fetch getConditionParam
      into l_param
          ,l_param_two;
    close getConditionParam;
    --+
    open getActionType(p_action_id => p_action_id);
     fetch getActionType
      into l_action_type;
    close getActionType;
    --+
    if l_param = 'any_approver' and l_action_type = 'nonfinal authority' then
      fnd_message.set_name('PER','AME_400702_INV_LM_ATY_COMB_1');
      hr_multi_message.add(p_associated_column1 => 'ACTION_ID');
    elsif l_param = 'final_approver' and l_action_type = 'final authority' then
      fnd_message.set_name('PER','AME_400703_INV_LM_ATY_COMB_2');
      hr_multi_message.add(p_associated_column1 => 'ACTION_ID');
    end if;
    --+
    if l_param = 'final_approver' and not is_per_approver(p_name => l_param_two) and is_first_condition then
      fnd_message.set_name('PER','AME_400703_INV_LM_ATY_COMB_2');
      hr_multi_message.add (p_associated_column1 => 'RULE_ID');
    end if;
  end chk_LM_action_Condition;
  --+
  --+ used in is_action_allowed
  --+
  function is_group_allowed(p_application_id    in integer
                         ,p_approval_group_id in integer) return boolean is
  --+
  cursor get_groups(p_application_id    in integer
                  ,p_approval_group_id in integer) is
  select count(*)
    from ame_approval_group_config gpc
   where gpc.approval_group_id = p_approval_group_id
     and gpc.application_id = p_application_id
     and sysdate between gpc.start_date and nvl(gpc.end_date - (1/86400),sysdate);
  --+
  l_count number(3);
  begin
    --+
    open get_groups(p_application_id    => p_application_id
                  ,p_approval_group_id => p_approval_group_id);
     fetch get_groups
      into l_count;
    close get_groups;
    --+
    if l_count = 0 then
      return false;
    else
      return true;
    end if;
    --+
  end is_group_allowed;
  --+
  --+ used in is_action_allowed.
  --+
  function is_all_approver_types_allowed(p_application_id    in integer) return boolean is
  tempValue  ame_config_vars.variable_value%type;
  begin
    --+
    tempValue := ame_util.getConfigVar
                   (variableNameIn  => ame_util.allowAllApproverTypesConfigVar
                   ,applicationIdIn => p_application_id);
    --+
    if(tempValue = ame_util.no) then
      return false;
    else
      return true;
    end if;
    --+
  end is_all_approver_types_allowed;
  --+
  --+ used in chk_LM_action_Condition.
  --+
  function is_per_approver(p_name in varchar2) return boolean is
  --+
  cursor get_per_approver(p_name in varchar2) is
  select count(*)
    from wf_roles
   where status = 'ACTIVE'
     and nvl(expiration_date,sysdate) >= sysdate
     and orig_system = 'PER'
     and name = p_name;
  --+
  l_count number(3);
  --+
  begin
    --+
    open get_per_approver(p_name => p_name);
     fetch get_per_approver
      into l_count;
    close get_per_approver;
    --+
    if l_count = 0 then
      return false;
    else
      return true;
    end if;
    --+
  end is_per_approver;
  --+
  --+ Used in is_condition_allowed.
  --+
  function is_pos_approver(p_name in varchar2) return boolean is
  --+
  cursor get_pos_approver(p_name in varchar2) is
  select count(*)
    from wf_roles
   where status = 'ACTIVE'
     and nvl(expiration_date,sysdate) >= sysdate
     and orig_system = 'POS'
     and name = p_name;
  --+
  l_count number(3);
  --+
  begin
    open get_pos_approver(p_name => p_name);
     fetch get_pos_approver
      into l_count;
    close get_pos_approver;
    if l_count = 0 then
      return false;
    else
      return true;
    end if;
  end is_pos_approver;
  --+
  --+ Used in create_ame_condition_to_rule.
  --+
  procedure chk_rule_and_item_class(p_rule_id      in integer
                                   ,p_condition_id in integer) is
  --+
  cursor get_sub_ic_cond(p_rule_id in integer) is
  select distinct atr.item_class_id
    from ame_rules rul
        ,ame_condition_usages cnu
        ,ame_attributes atr
        ,ame_conditions con
        ,ame_item_classes itc
   where rul.rule_id       = p_rule_id
     and rul.rule_id       = cnu.rule_id
     and cnu.condition_id  = con.condition_id
     and con.attribute_id  = atr.attribute_id
     and atr.item_class_id = itc.item_class_id
     and itc.name <> ame_util.headerItemClassName
     and ((sysdate between rul.start_date and nvl(rul.end_date - (1/86400),sysdate))
           or
          (sysdate < rul.start_date and rul.start_date < nvl(rul.end_date, rul.start_date + (1/86400)))
         )
     and ((sysdate between cnu.start_date and nvl(cnu.end_date - (1/86400),sysdate))
           or
          (sysdate < cnu.start_date and cnu.start_date < nvl(cnu.end_date, cnu.start_date + (1/86400)))
         )
     and sysdate between con.start_date and nvl(con.end_date - (1/86400),sysdate)
     and sysdate between atr.start_date and nvl(atr.end_date - (1/86400),sysdate)
     and sysdate between itc.start_date and nvl(itc.end_date - (1/86400),sysdate);
     --+
     l_item_class_id        ame_rules.item_class_id%type;
     l_header_item_class_id ame_rules.item_class_id%type;
     l_sub_ic_cond_list     ame_util.idList;
     l_con_item_class_id    ame_rules.item_class_id%type;
     l_con_type             ame_conditions.condition_type%type;
  begin
    --+
    select condition_type
      into l_con_type
      from ame_conditions
     where condition_id = p_condition_id
       and sysdate between start_date and nvl(end_date - (1/84600),sysdate);
     if l_con_type = ame_util.listModConditionType then
       return;
     end if;
    --+
    select item_class_id
      into l_header_item_class_id
      from ame_item_classes
     where name = ame_util.headerItemClassName
       and sysdate between start_date and nvl(end_date - (1/84600),sysdate);
    --+
    select atr.item_class_id
      into l_con_item_class_id
      from ame_conditions con
          ,ame_attributes atr
     where con.attribute_id = atr.attribute_id
       and con.condition_id = p_condition_id
       and sysdate between con.start_date and nvl(con.end_date - (1/86400),sysdate)
       and sysdate between atr.start_date and nvl(atr.end_date - (1/86400),sysdate);
    if l_con_item_class_id = l_header_item_class_id then
      return;
    end if;
    --+
    select nvl(item_class_id,l_header_item_class_id)
      into l_item_class_id
      from ame_rules
     where rule_id = p_rule_id
       and ((sysdate between start_date and nvl(end_date - (1/86400),sysdate))
             or
            (sysdate < start_date and start_date < nvl(end_date, start_date + (1/86400)))
           );
    --+
    if l_item_class_id = l_header_item_class_id then
      open get_sub_ic_cond(p_rule_id => p_rule_id);
       fetch get_sub_ic_cond
        bulk collect into l_sub_ic_cond_list;
      if l_sub_ic_cond_list.count <> 0 then
        if l_sub_ic_cond_list(1) <> l_con_item_class_id then
          fnd_message.set_name('PER','AME_400695_RULE_SUB_ITC_COND');
          hr_multi_message.add(p_associated_column1 => 'ITEM_CLASS_ID');
        end if;
      end if;
      close get_sub_ic_cond;
    else
      if l_con_item_class_id <> l_item_class_id then
        fnd_message.set_name('PER','AME_400708_NH_RULE_SUB_ITC_CON');
        hr_multi_message.add(p_associated_column1 => 'ITEM_CLASS_ID');
      end if;
    end if;
  --+
  end chk_rule_and_item_class;
  --+
  function is_cond_exist_in_rule(p_rule_id      in integer
                                ,p_condition_id in integer) return boolean is
  l_count number(2);
  begin
    --+
    select count(*)
      into l_count
      from ame_condition_usages
     where rule_id      = p_rule_id
       and condition_id = p_condition_id
       and ((sysdate between start_date and nvl(end_date - (1/86400),sysdate))
             or
            (sysdate < start_date and start_date < nvl(end_date, start_date + (1/86400)))
           );
    if l_count = 0 then
      return(false);
    else
      return(true);
    end if;
  end is_cond_exist_in_rule;
  --+
  function chk_lm_actions(p_rule_id   in integer
                         ,p_action_id in integer) return boolean is
  l_count number(2);
  l_aty_name ame_action_types.name%type;
  begin
    select aty.name
      into l_aty_name
      from ame_actions act
          ,ame_action_types aty
     where act.action_id = p_action_id
       and act.action_type_id = aty.action_type_id
       and sysdate between act.start_date and nvl(act.end_date - (1/86400),sysdate)
       and sysdate between aty.start_date and nvl(aty.end_date - (1/86400),sysdate);
    if l_aty_name = 'final authority' then
      select count(*)
        into l_count
        from ame_action_usages acu
            ,ame_action_types aty
            ,ame_actions act
       where acu.rule_id   = p_rule_id
         and aty.name = 'nonfinal authority'
         and acu.action_id = act.action_id
         and act.action_type_id = aty.action_type_id
         and sysdate between act.start_date and nvl(act.end_date - (1/86400),sysdate)
         and sysdate between aty.start_date and nvl(aty.end_date - (1/86400),sysdate)
         and ((sysdate between acu.start_date and nvl(acu.end_date - (1/86400),sysdate))
              or
              (sysdate < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + (1/86400)))
             );
      if l_count > 0 then
        return false;
      end if;
    elsif l_aty_name = 'nonfinal authority' then
      select count(*)
        into l_count
        from ame_action_usages acu
            ,ame_action_types aty
            ,ame_actions act
       where acu.rule_id   = p_rule_id
         and aty.name = 'final authority'
         and acu.action_id = act.action_id
         and act.action_type_id = aty.action_type_id
         and sysdate between act.start_date and nvl(act.end_date - (1/86400),sysdate)
         and sysdate between aty.start_date and nvl(aty.end_date - (1/86400),sysdate)
         and ((sysdate between acu.start_date and nvl(acu.end_date - (1/86400),sysdate))
              or
              (sysdate < acu.start_date and acu.start_date < nvl(acu.end_date, acu.start_date + (1/86400)))
             );
      if l_count > 0 then
        return false;
      end if;
    end if;
    return true;
  end chk_lm_actions;
--+
end ame_rule_utility_pkg;

/
