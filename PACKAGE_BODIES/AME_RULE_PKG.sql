--------------------------------------------------------
--  DDL for Package Body AME_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RULE_PKG" as
/* $Header: ameorule.pkb 120.1 2006/09/07 12:59:51 pvelugul noship $ */
  allOrgsLabel constant varchar2(50) := 'Include all organizations.';
  allGroupsLabel constant varchar2(50) := 'Include all business groups.';
  allSetsOfBooksLabel constant varchar2(50) := 'Include all sets of books.';
  /* forward declarations */
  /*
    1.  Call changeAllAttributeUseCounts after committing changes to a rule that will always
        exist after the changes.
    2.  When you're going to call removeUsage, or do anything else that might result in a
        rule's deletion (end dating), first fetch the list of attributes used by the rule
        before the changes, then call removeUsage (or perform the other changes) and commit
        them, then call changeAttributeUseCounts2, passing it the list of attributes.
    Note that changeAttributeUseCounts gets called by changeAllAttributeUseCounts.
  */
	procedure changeAllAttributeUseCounts(ruleIdIn in integer,
                                        finalizeIn in boolean default true);
  procedure changeAttributeUseCounts(ruleIdIn in integer,
                                     applicationIdIn in integer,
                                     finalizeIn in boolean default true);
  procedure changeAttributeUseCounts2(attributeIdsIn in ame_util.idList,
                                      applicationIdIn in integer,
                                      finalizeIn in boolean default true);
	/* functions */
  function allOrdinaryConditionsDeleted(conditionIdListIn in ame_util.idList,
                                        deletedListIn in ame_util.stringList) return boolean as
    conditionId integer;
    deletedOrdinaryConditionCount integer;
    ordinaryConditionCount integer;
    begin
      ordinaryConditionCount := 0;
      deletedOrdinaryConditionCount := 0;
      /* get a count of the existing ordinary conditions applied to the rule */
      for i in 1..conditionIdListIn.count loop
        if(ame_condition_pkg.getConditionType(conditionIdIn => conditionIdListIn(i))
          = ame_util.ordinaryConditionType) then
          ordinaryConditionCount := (ordinaryConditionCount + 1);
        end if;
      end loop;
      /* get a count of the deleted ordinary conditions */
      for i in 1..deletedListIn.count loop
        if(deletedListIn(i) like 'con%') then
          conditionId := to_number(substrb(deletedListIn(i),4,(lengthb(deletedListIn(i)))));
          if(ame_condition_pkg.getConditionType(conditionIdIn => conditionId)
            = ame_util.ordinaryConditionType) then
            deletedOrdinaryConditionCount := (deletedOrdinaryConditionCount + 1);
          end if;
        end if;
      end loop;
      /* verify if all ordinary conditions were deleted */
      if(ordinaryConditionCount = deletedOrdinaryConditionCount) then
        /* all ordinary conditions were deleted */
        return(true);
      else
        return(false);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'allOrdinaryConditionsDeleted',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end allOrdinaryConditionsDeleted;
	function appHasRules(applicationIdIn in integer) return boolean as
    ruleCount integer;
    begin
      select count(*)
        into ruleCount
        from ame_rule_usages
        where
             item_id = applicationIdIn and
             ((sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < start_date and
                 start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      if(ruleCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'appHasRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end appHasRules;
   /* This function may return the following value
       0     No overlapping Usage exists
       1     Usage with same Lifespan and priority exists
       2     Usage with same lifespan but different priority exists
       3     Usage with overlapping lifespan exists
   */
   function bothSeededLMActionTypesChosen(actionTypeIdsIn in ame_util.idList) return boolean as
     finalAuthActionTypeId integer;
     nonFinalAuthActionTypeId integer;
     tempCount integer;
     begin
       tempCount := 0;
       nonFinalAuthActionTypeId :=
         ame_action_pkg.getActionTypeIdByName(actionTypeNameIn => ame_util.nonFinalAuthority);
       finalAuthActionTypeId :=
         ame_action_pkg.getActionTypeIdByName(actionTypeNameIn => ame_util.finalAuthorityTypeName);
       for i in 1..actionTypeIdsIn.count loop
         if(actionTypeIdsIn(i) in (nonFinalAuthActionTypeId, finalAuthActionTypeId)) then
           tempCount := (tempCount + 1);
         end if;
       end loop;
       if(tempCount > 1) then
         return(true);
       end if;
       return(false);
       exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'bothSeededLMActionTypesChosen',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
     end bothSeededLMActionTypesChosen;
   function bothSeededLMActionTypesChosen2(ruleIdIn in integer,
                                           actionTypeIdsIn in ame_util.idList) return boolean as
     cursor actionTypeIdsCursor(ruleIdIn in integer) is
       select distinct(ame_action_types.action_type_id) action_type_id
         from ame_action_types,
              ame_actions,
              ame_action_usages
         where
           ame_action_types.action_type_id = ame_actions.action_type_id and
           ame_actions.action_id = ame_action_usages.action_id and
           ame_action_usages.rule_id = ruleIdIn and
           sysdate between ame_action_usages.start_date and
             nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_action_types.start_date and
             nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_actions.start_date and
             nvl(ame_actions.end_date - ame_util.oneSecond, sysdate);
     actionTypeIds ame_util.idList;
     finalAuthActionTypeId integer;
     finalAuthority boolean;
     nonFinalAuthActionTypeId integer;
     nonFinalAuthority boolean;
     tempCount integer;
     tempCount2 integer;
     begin
       tempCount := (actionTypeIdsIn.count + 1);
       actionTypeIds := actionTypeIdsIn;
       for actionTypeIdsRec in actionTypeIdsCursor(ruleIdIn => ruleIdIn) loop
         actionTypeIds(tempCount) := actionTypeIdsRec.action_type_id;
         tempCount := (tempCount + 1);
       end loop;
       nonFinalAuthActionTypeId :=
         ame_action_pkg.getActionTypeIdByName(actionTypeNameIn => ame_util.nonFinalAuthority);
       finalAuthActionTypeId :=
         ame_action_pkg.getActionTypeIdByName(actionTypeNameIn => ame_util.finalAuthorityTypeName);
       /* Verify if both action types are now selected. */
       for i in 1..actionTypeIds.count loop
         if(actionTypeIds(i) = nonFinalAuthActionTypeId) then
           nonFinalAuthority := true;
           exit;
         end if;
       end loop;
       for i in 1..actionTypeIds.count loop
         if(actionTypeIds(i) = finalAuthActionTypeId) then
           finalAuthority := true;
           exit;
         end if;
       end loop;
       if(nonFinalAuthority) then
         if(finalAuthority) then
           return(true);
         end if;
       end if;
       return(false);
       exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'bothSeededLMActionTypesChosen2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
     end bothSeededLMActionTypesChosen2;
   function checkRuleUsageExists(applicationIdIn in integer,
                              ruleIdIn in integer,
                              startDateIn in date,
                              endDateIn in date default null,
                              processingDateIn in date,
                              priorityIn in varchar2 default null)
         return number as
    cursor ruleUsageCursor(ruleIdIn in integer,
                           applicationIdIn in integer,
                           processingDateIn in date)  is
       select start_date, end_date, priority
         from ame_rule_usages
        where rule_id = ruleIdIn and
              item_id = applicationIdIn and
          ( processingDateIn between  start_date and
                     nvl(end_date - ame_util.oneSecond,processingDateIn ) or
           (processingDateIn < start_date and
           start_date < nvl(end_date,start_date + ame_util.oneSecond)))
       order by start_date desc;
    usagestartDateList ame_util.dateList;
    usageEndDateList ame_util.dateList;
    usagePriorityList ame_util.idList;
    errorCode integer;
    errorMessage ame_util.longestStringType;
  begin
    for ruleUsage in ruleUsageCursor(ruleIdIn => ruleIdIn,
                                     applicationIdIn => applicationIdIn,
                                     processingDateIn => processingDateIn) loop
      if ( trunc(startDateIn) = trunc(ruleUsage.start_date) and
           trunc(endDateIn) = trunc(ruleUsage.end_date)  and
           priorityIn = ruleUsage.priority
          ) then
        return(1);
      elsif  ( trunc(startDateIn) = trunc(ruleUsage.start_date)  and
               trunc(endDateIn) = trunc(ruleUsage.end_date)
             ) then
        return(2);
      elsif (ruleUsage.end_date is null and endDateIn is null) then
        return(3);
      elsif ((endDateIn is null and startDateIn < ruleUsage.end_date)
          or
            ( ruleUsage.end_date is null and
                  (startDateIn >= ruleUsage.start_date
                 or endDateIn > ruleUsage.start_date))
          ) then
        return(3);
      elsif ( (startDateIn between  ruleUsage.start_date and
                    ruleUsage.end_date - ame_util.oneSecond)
         or
         (endDateIn  between  ruleUsage.start_date and
                    ruleUsage.end_date - ame_util.oneSecond)
         or
         (ruleUsage.start_date between startDateIn and
                    endDateIn - ame_util.oneSecond )
         or
         (ruleUsage.end_date between startDateIn and
                    endDateIn - ame_util.oneSecond )
            ) then
        return(3);
      end if;
    end loop;
    return(0);
  exception
    when others then
          rollback;
          errorCode := -20001;
          errorMessage :=
             ame_util.getMessage(applicationShortNameIn => 'PER',
             messageNameIn => 'AME_400329_RULE_USG_OVER_LIFE');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'checkRuleUsageExists',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise;
          return(3);
  end checkRuleUsageExists;
  function deletedAllExceptionConditions(conditionIdListIn in ame_util.idList,
                                         deletedListIn in ame_util.stringList) return boolean as
    conditionId integer;
    mandatoryConditionCount integer;
    mandatoryConditionIdList ame_util.idList;
    tempConditionCount integer;
    tempIndex integer;
    begin
      tempIndex := 1;
      for i in 1..conditionIdListIn.count loop
        if(ame_condition_pkg.getConditionType(conditionIdIn => conditionIdListIn(i))
          = ame_util.exceptionConditionType) then
          mandatoryConditionIdList(tempIndex) := conditionIdListIn(i);
          tempIndex := (tempIndex + 1);
          /* there can be multiple exception conditions so keep looping */
        end if;
      end loop;
      mandatoryConditionCount := mandatoryConditionIdList.count;
      if(mandatoryConditionCount = 0) then
        return(false);
      end if;
      tempConditionCount := 0;
      for i in 1..deletedListIn.count loop
        if(deletedListIn(i) like 'con%') then
          conditionId := to_number(substrb(deletedListIn(i),4,(lengthb(deletedListIn(i)))));
          for j in 1..mandatoryConditionCount loop
            if(mandatoryConditionIdList(j) = conditionId) then
              tempConditionCount := (tempConditionCount + 1);
            end if;
          end loop;
        end if;
      end loop;
      if(mandatoryConditionCount = tempConditionCount) then
        /* all exception conditions were deleted */
        return(true);
      else
        return(false);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'deletedAllExceptionConditions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion */
    end deletedAllExceptionConditions;
  function descriptionInUse(descriptionIn in varchar2) return boolean as
    descriptionCount varchar2(500);
    begin
      select count(*)
        into descriptionCount
        from ame_rules
        where upper(description) = upper(descriptionIn) and
        /* allows for future start date */
        ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
        (sysdate < start_date and
            start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      if descriptionCount > 0 then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'descriptionInUse',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end descriptionInUse;
  function finalAuthorityActionType(actionTypeIdsIn in ame_util.idList) return boolean as
    finalAuthActionTypeId integer;
    begin
      finalAuthActionTypeId :=
        ame_action_pkg.getActionTypeIdByName(actionTypeNameIn => ame_util.finalAuthorityTypeName);
      for i in 1..actionTypeIdsIn.count loop
        if(actionTypeIdsIn(i) = finalAuthActionTypeId) then
          return(true);
        end if;
      end loop;
      return(false);
    exception
    when others then
      rollback;
      ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                routineNamein => 'finalAuthorityActionType',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
        raise;
        return(true);
    end finalAuthorityActionType;
  function finalAuthorityActionType2(ruleIdIn in integer) return boolean as
     cursor actionTypeIdsCursor(ruleIdIn in integer) is
       select distinct(ame_action_types.action_type_id) action_type_id
         from ame_action_types,
              ame_actions,
              ame_action_usages
         where
           ame_action_types.action_type_id = ame_actions.action_type_id and
           ame_actions.action_id = ame_action_usages.action_id and
           ame_action_usages.rule_id = ruleIdIn and
           sysdate between ame_action_usages.start_date and
             nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_action_types.start_date and
             nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_actions.start_date and
             nvl(ame_actions.end_date - ame_util.oneSecond, sysdate);
     finalAuthActionTypeId integer;
    begin
      finalAuthActionTypeId :=
        ame_action_pkg.getActionTypeIdByName(actionTypeNameIn => ame_util.finalAuthorityTypeName);
      for actionTypeIdsRec in actionTypeIdsCursor(ruleIdIn => ruleIdIn) loop
        if(actionTypeIdsRec.action_type_id = finalAuthActionTypeId) then
          return(true);
        end if;
      end loop;
      return(false);
      exception
       when others then
         rollback;
         ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                   routineNamein => 'finalAuthorityActionType2',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         raise;
         return(true);
     end finalAuthorityActionType2;
  function getApproverCategory(ruleIdIn in integer,
                               applicationIdIn in integer,
                               usageStartDateIn in date) return varchar2 as
    approverCategory ame_util.stringType;
    begin
      select approver_category
        into approverCategory
        from
          ame_rule_usages
        where
          rule_id = ruleIdIn and
          item_id = applicationIdIn and
          start_date = usageStartDateIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      return(approverCategory);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getApproverCategory',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getApproverCategory;
  function getConditionCount(ruleIdIn in integer) return integer as
    conditionCount integer;
    begin
      select count(condition_id)
        into conditionCount
        from ame_condition_usages
        where
          rule_id = ruleIdIn and
          /* allows for future start date */
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      return(conditionCount);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getConditionCount',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end getConditionCount;
  function getItemClassId(ruleIdIn in integer,
                          processingDateIn in date default null) return integer as
    itemClassId integer;
    begin
      if processingDateIn is null then
        select item_class_id
          into itemClassId
          from ame_rules
          where
            rule_id = ruleIdIn and
            ((sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate)) or
            (sysdate < start_date and
               start_date < nvl(end_date,start_date + ame_util.oneSecond)));
        return(itemClassId);
      else
        select item_class_id
          into itemClassId
          from ame_rules
          where
            rule_id = ruleIdIn and
            rownum < 2 and /* for efficiency */
            (processingDateIn between start_date and
               nvl(end_date - ame_util.oneSecond, processingDateIn)) ;
        return(itemClassId);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getItemClassId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getItemClassId;
  function getLMConditionId(ruleIdIn in integer) return integer as
    conditionId integer;
    begin
      select ame_conditions.condition_id
        into conditionId
        from ame_conditions,
             ame_condition_usages
        where
          ame_conditions.condition_id = ame_condition_usages.condition_id and
          ame_conditions.condition_type = ame_util.listModConditionType and
          ame_condition_usages.rule_id = ruleIdIn and
          (ame_conditions.start_date <= sysdate and
          (ame_conditions.end_date is null or sysdate < ame_conditions.end_date)) and
          ((sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < ame_condition_usages.start_date and
            ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
            ame_condition_usages.start_date + ame_util.oneSecond)));
          return(conditionId);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getLMConditionId',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end getLMConditionId;
  function getOrganizationName(organizationIdIn in integer) return varchar2 as
    organizationName  hr_organization_units.name%type;
    begin
      select name
        into organizationName
        from hr_organization_units
        where
          sysdate >= date_from and
          organization_id = organizationIdIn and
          (date_to is null or sysdate < date_to);
      return(organizationName);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                  routineNameIn => 'getOrganizationName',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(organization ID ' ||
                                                        organizationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end getOrganizationName;
  function getPriority(ruleIdIn in integer,
                       applicationIdIn in integer,
                       usageStartDateIn in date) return varchar2 as
    priority varchar2(20);
    begin
      select to_char(priority)
        into priority
        from ame_rule_usages
        where
             rule_id = ruleIdIn and
             item_id = applicationIdIn and
             usageStartDateIn between start_date and
               nvl(end_date - ame_util.oneSecond, usageStartDateIn);
      return(priority);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getPriority',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getPriority;
  function getItemId(ruleIdIn in integer) return integer as
    itemId ame_rule_usages.item_id%type;
    begin
      select item_id
        into itemId
        from ame_rule_usages
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      return(itemId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getItemId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getItemId;
  function getRuleType(ruleIdIn in integer,
                       processingDateIn in date default null) return integer as
    ruleType integer;
    begin
      if processingDateIn is null then
        select rule_type
          into ruleType
          from ame_rules
          where
            rule_id = ruleIdIn and
            ((sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate)) or
            (sysdate < start_date and
               start_date < nvl(end_date,start_date + ame_util.oneSecond)));
        return(ruleType);
      else
        select rule_type
          into ruleType
          from ame_rules
          where
            rule_id = ruleIdIn and
            rownum < 2 and /* for efficiency */
            (processingDateIn between start_date and
               nvl(end_date - ame_util.oneSecond, processingDateIn)) ;
        return(ruleType);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getRuleType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getRuleType;
  function getRuleTypeLabel(ruleTypeIn in integer) return varchar2 as
    begin
      if(ruleTypeIn = ame_util.authorityRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_LIST_CREATION'));
      elsif(ruleTypeIn = ame_util.exceptionRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_LIST_CREATION_EXCEPTION'));
      elsif(ruleTypeIn = ame_util.listModRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_LIST_MODIFICATION'));
      elsif(ruleTypeIn = ame_util.substitutionRuleType) then
        return(lower(ame_util.getLabel(ame_util.perFndAppId, 'AME_SUBSTITUTION')));
        -- return('substitution');
      elsif(ruleTypeIn = ame_util.preListGroupRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId, 'AME_PRE_LIST_APPROVAL_GROUP'));
      elsif(ruleTypeIn = ame_util.postListGroupRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId, 'AME_POST_LIST_APPROVAL_GROUP'));
      elsif(ruleTypeIn = ame_util.productionRuleType) then
        return(lower(ame_util.getLabel(ame_util.perFndAppId, 'AME_PRODUCTION')));
      elsif(ruleTypeIn = ame_util.combinationRuleType) then
        return(lower(ame_util.getLabel(ame_util.perFndAppId, 'AME_COMBINATION')));
      else
        return(null);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getRuleTypeLabel',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getRuleTypeLabel;
  function getRuleTypeLabel2(ruleTypeIn in integer) return varchar2 as
    begin
      if(ruleTypeIn = ame_util.authorityRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_LIST_CREAT_RULES'));
      elsif(ruleTypeIn = ame_util.exceptionRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_LIST_CREAT_EXCEP_RULES'));
      elsif(ruleTypeIn = ame_util.listModRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_LIST_MOD_RULES'));
      elsif(ruleTypeIn = ame_util.substitutionRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_SUBSTITUTION_RULES'));
      elsif(ruleTypeIn = ame_util.preListGroupRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_PRE_LIST_APPR_GROUP_RULES'));
      elsif(ruleTypeIn = ame_util.postListGroupRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_POST_LIST_APPR_GROUP_RULES'));
      elsif(ruleTypeIn = ame_util.productionRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_PRODUCTION_RULES'));
      elsif(ruleTypeIn = ame_util.combinationRuleType) then
        return(ame_util.getLabel(ame_util.perFndAppId,'AME_COMBINATION_RULES'));
      else
        return(null);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getRuleTypeLabel2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getRuleTypeLabel2;
  function getDescription(ruleIdIn in integer,
                      processingDateIn in date default null) return varchar2 as
 	  description ame_rules.description%type;
    begin
      if processingDateIn is null then
        select description
          into description
          from ame_rules
          where
            rule_id = ruleIdIn and
            rownum < 2 and /* for efficiency */
            ((sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate)) or
            (sysdate < start_date and
               start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      else
        select description
          into description
          from ame_rules
          where
            rule_id = ruleIdIn and
            rownum < 2 and /* for efficiency */
            (processingDateIn between start_date and
               nvl(end_date - ame_util.oneSecond, processingDateIn)) ;
      end if;
      return(description);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getDescription',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getDescription;
  function getEndDate(ruleIdIn in integer) return date as
 	  endDate ame_rules.end_date%type;
    begin
      select end_date
        into endDate
        from ame_rules
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      return(endDate);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getEndDate',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end getEndDate;
  function getEffectiveEndDateUsage(applicationIdIn in integer,
                                    ruleIdIn in integer,
                                    effectiveDateIn in date) return date as
  usageEndDate date;
  effectiveDate date;
  begin
    effectiveDate := effectiveDateIn;
    if(trunc(effectiveDate) = trunc(sysdate)) then
      effectiveDate := sysdate;
    end if;
    select end_date
      into usageEndDate
      from ame_rule_usages
      where
        item_id = applicationIdIn and
        rule_id = ruleIdIn and
        effectiveDate between start_date and
            nvl(end_date - ame_util.oneSecond, effectiveDate);
    return(usageEndDate);
    exception
      when no_data_found then
        return(null);
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getEffectiveEndDateUsage',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getEffectiveEndDateUsage;
  function getEffectiveStartDateUsage(applicationIdIn in integer,
                                      ruleIdIn in integer,
                                      effectiveDateIn in date) return date as
  usageStartDate date;
  effectiveDate date;
  begin
    effectiveDate := effectiveDateIn;
    if(trunc(effectiveDate) = trunc(sysdate)) then
      effectiveDate := sysdate;
    end if;
    select start_date
      into usageStartDate
      from ame_rule_usages
      where
        item_id = applicationIdIn and
        rule_id = ruleIdIn and
        effectiveDate between start_date and
            nvl(end_date - ame_util.oneSecond, effectiveDate);
    return(usageStartDate);
    exception
      when no_data_found then
        return(null);
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getEffectiveStartDateUsage',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getEffectiveStartDateUsage;
  function getUsageEndDate(ruleIdIn in integer,
                           applicationIdIn in integer,
                             processingDateIn in date) return varchar2 as
 	  endDate ame_rule_usages.end_date%type;
    begin
      select end_date
        into endDate
        from ame_rule_usages
        where
             rule_id = ruleIdIn and
             item_id = applicationIdIn and
             creation_date = processingDateIn;
      return(ame_util.versionDateToString(dateIn => endDate));
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getUsageEndDate',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end getUsageEndDate;
  function getId(typeIn in varchar2,
                 conditionIdListIn in ame_util.idList,
                 actionIdListIn in ame_util.idList) return integer as
    cursor ruleIdCursor(typeIn in varchar2) is
      select rule_id
        from ame_rules
        where
           rule_type = typeIn and
           ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
    actionIdList1 ame_util.idList;
    actionIdList2 ame_util.idList;
    actionIdMatch boolean;
    conditionIdList1 ame_util.idList;
    conditionIdList2 ame_util.idList;
    conditionIdMatch boolean;
    ruleId ame_rules.rule_id%type;
    begin
      ruleId := null;
      conditionIdList1 := conditionIdListIn;
      actionIdList1 := actionIdListIn;
      ame_util.sortIdListInPlace(idListInOut => conditionIdList1);
      ame_util.sortIdListInPlace(idListInOut => actionIdList1);
      conditionIdMatch := false;
      actionIdMatch := false;
      for tempRuleId in ruleIdCursor(typeIn => typeIn) loop
        getConditionIds(ruleIdIn => tempRuleId.rule_id,
                        conditionIdListOut => conditionIdList2);
        ame_util.sortIdListInPlace(idListInOut => conditionIdList2);
        if(ame_util.idListsMatch(idList1InOut => conditionIdList1,
                                 idList2InOut => conditionIdList2,
                                 sortList1In => false,
                                 sortList2In => false)) then
          conditionIdMatch := true;
        end if;
        getactionIds(ruleIdIn => tempRuleId.rule_id,
                     actionIdListOut => actionIdList2);
        ame_util.sortIdListInPlace(idListInOut => actionIdList2);
        if(ame_util.idListsMatch(idList1InOut => actionIdList1,
                                 idList2InOut => actionIdList2,
                                 sortList1In => false,
                                 sortList2In => false)) then
          actionIdMatch := true;
        end if;
        ruleId := tempRuleId.rule_id;
        if(conditionIdMatch and actionIdMatch) then
          return(ruleId);
        end if;
        conditionIdList2.delete;
        actionIdList2.delete;
        conditionIdMatch := false;
        actionIdMatch := false;
      end loop;
      return(null);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleId ||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getId;
/*
AME_STRIPING
  function getRuleStripeSetId(ruleIdIn in integer) return integer as
    stripeSetId integer;
    begin
      begin
        select stripe_set_id
          into stripeSetId
          from ame_rule_stripe_sets
          where
            rule_id = ruleIdIn and
            (start_date <= sysdate and
            (end_date is null or sysdate < end_date));
        return(stripeSetId);
        exception
          when no_data_found then
            return(null);
      end;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'getRuleStripeSetId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          return(null);
    end getRuleStripeSetId;
*/
  function ruleKeyExists (ruleKeyIn in varchar2) return boolean as
    ruleCount integer;
    begin
      select count(*)
      into ruleCount
      from ame_rules
      where upper(rule_key) = upper(ruleKeyIn) and
       rownum < 2;
      if ruleCount > 0 then
        return(true);
      else
       return(false);
      end if;
    exception
    when others then
      rollback;
      ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                routineNamein => 'ruleKeyExists',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => '(rule Key ' ||
                                                       ruleKeyIn ||
                                                      ') ' ||
                                                       sqlerrm);
        raise;
        return(true);
    end ruleKeyExists;
  function getNextRuleKey return varchar2 as
    databaseId varchar2(50);
    newRuleKey ame_rules.rule_key%type;
    newRuleKey1 ame_rules.rule_key%type;
    ruleKeyId number;
    seededKeyPrefix varchar2(4);
    begin
      begin
        select to_char(db.dbid)
        into databaseId
        from v$database db, v$instance instance
        where upper(db.name) = upper(instance.instance_name);
      exception
        when no_data_found then
          databaseId := null;
      end;
      if (ame_util.getHighestResponsibility = ame_util.developerResponsibility) then
         seededKeyPrefix := ame_util.seededKeyPrefix;
      else
         seededKeyPrefix := null;
      end if;
      loop
        select ame_rule_keys_s.nextval into ruleKeyId from dual;
        newRuleKey := databaseId||':'||ruleKeyId;
        if seededKeyPrefix is not null then
          newRuleKey1 := seededKeyPrefix||'-' || newRuleKey;
        else
          newRuleKey1 := newRuleKey;
        end if;
        if not ruleKeyExists(newRuleKey1) then
          exit;
        end if;
      end loop;
      return(newRuleKey);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                 routineNamein => 'getNextRuleKey',
                                 exceptionNumberIn => sqlcode,
                                 exceptionStringIn => '(rule Key ' ||
                                                       newRuleKey ||
                                                      ') ' ||
                                                       sqlerrm);
        raise;
				return(null);
    end getNextRuleKey;
  function getRuleKey(ruleIdIn in integer,
                      processingDateIn in date default null) return varchar2 as
 	  ruleKey ame_rules.rule_key%type;
    begin
      if processingDateIn is null then
        select rule_key
          into ruleKey
          from ame_rules
          where
             rule_id = ruleIdIn and
             ((sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate)) or
            (sysdate < start_date and
               start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      else
        select rule_key
          into ruleKey
          from ame_rules
          where
               rule_id = ruleIdIn and
            (processingDateIn between start_date and
               nvl(end_date - ame_util.oneSecond, processingDateIn)) ;
      end if;
      return(ruleKey);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getRuleKey',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getRuleKey;
	function getNewRuleStartDate(ruleIdIn in integer,
                               processingDateIn in date) return date as
    ruleStartDate date;
    newStartDate  date;
    begin
      select min(start_date)
        into ruleStartDate
        from ame_rule_usages
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      if ruleStartDate is null then
        newStartDate := null;
      elsif trunc(ruleStartDate) > trunc(processingDateIn) then
        newStartDate :=  trunc(ruleStartDate);
      else
        newStartDate := processingDateIn;
      end if;
      return(newStartDate);
     exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getNewRuleStartDate',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end getNewRuleStartDate;
  function getNewRuleEndDate(ruleIdIn in integer,
                             processingDateIn in date) return date as
    ruleEndDate date;
    newEndDate  date;
    begin
      select max(nvl(end_date,to_date('31/12/4712','DD/MM/YYYY')))
        into ruleEndDate
        from ame_rule_usages
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      if ruleEndDate is null or ruleEndDate =
                                 to_date('31/12/4712','DD/MM/YYYY') then
        newEndDate := null;
      elsif trunc(ruleEndDate) > trunc(processingDateIn) then
        newEndDate :=  trunc(ruleEndDate);
      else
        newEndDate := ruleEndDate;
      end if;
      return(newEndDate);
     exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getNewRuleEndDate',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end getNewRuleEndDate;
  function getRulePriorityMode(applicationIdIn in integer,
                               ruleTypeIn in varchar2) return varchar2 as
    priority ame_util.stringType;
    variableValue ame_util.longStringType;
    begin
      variableValue := ame_util.getConfigVar(variableNameIn => ame_util.rulePriorityModesConfigVar,
                                             applicationIdIn => applicationIdIn);
      if(ruleTypeIn = ame_util.combinationRuleType) then
        priority := substrb(variableValue, 1, (instr(variableValue,':',1,1) -1));
      elsif(ruleTypeIn = ame_util.authorityRuleType) then
        priority := substrb(variableValue,
                           (instr(variableValue,':',1,1) +1),
                           (instr(variableValue,':',1,2) -
                           (instr(variableValue,':',1,1) +1)));
      elsif(ruleTypeIn = ame_util.exceptionRuleType) then
        priority := substrb(variableValue,
                           (instr(variableValue,':',1,2) +1),
                           (instr(variableValue,':',1,3) -
                           (instr(variableValue,':',1,2) +1)));
      elsif(ruleTypeIn = ame_util.listModRuleType) then
        priority := substrb(variableValue,
                           (instr(variableValue,':',1,3) +1),
                           (instr(variableValue,':',1,4) -
                           (instr(variableValue,':',1,3) +1)));
      elsif(ruleTypeIn = ame_util.substitutionRuleType) then
        priority := substrb(variableValue,
                           (instr(variableValue,':',1,4) +1),
                           (instr(variableValue,':',1,5) -
                           (instr(variableValue,':',1,4) +1)));
      elsif(ruleTypeIn = ame_util.preListGroupRuleType) then
        priority := substrb(variableValue,
                           (instr(variableValue,':',1,5) +1),
                           (instr(variableValue,':',1,6) -
                           (instr(variableValue,':',1,5) +1)));
      elsif(ruleTypeIn = ame_util.postListGroupRuleType) then
        priority := substrb(variableValue,
                           (instr(variableValue,':',1,6) +1),
                           (instr(variableValue,':',1,7) -
                           (instr(variableValue,':',1,6) +1)));
      elsif(ruleTypeIn = ame_util.productionRuleType) then
        priority := substrb(variableValue,
                           (instr(variableValue,':',1,7) +1));
      end if;
      return(priority);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getRulePriorityMode',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(ame_util.disabledRulePriority); /* safe */
    end getRulePriorityMode;
  function getStartDate(ruleIdIn in integer) return date as
 	  startDate ame_rules.start_date%type;
    begin
      select start_date
        into startDate
        from ame_rules
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      return(startDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getStartDate;
  function getSubItemClassId(ruleIdIn in integer) return integer as
    cursor getSubItemClassIdCur(ruleIdIn in integer,
                                headerItemClassIdIn in integer) is
      select item_class_id
        from ame_conditions,
             ame_attributes,
             ame_condition_usages
        where
          ame_conditions.condition_id = ame_condition_usages.condition_id and
          ame_conditions.attribute_id = ame_attributes.attribute_id and
          ame_condition_usages.rule_id = ruleIdIn and
          ame_attributes.item_class_id <> headerItemClassIdIn and
          (sysdate between ame_conditions.start_date and
            nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate)) and
          (sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) and
          (sysdate between ame_attributes.start_date and
            nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate));
    headerItemClassId integer;
    itemIds ame_util.idList;
    begin
      headerItemClassId :=
        ame_admin_pkg.getItemClassIdByName(itemClassNameIn =>
                                             ame_util.headerItemClassName);
      open getSubItemClassIdCur(ruleIdIn => ruleIdIn,
                                headerItemClassIdIn => headerItemClassId);
        fetch getSubItemClassIdCur bulk collect
          into itemIds;
      close getSubItemClassIdCur;
      for i in 1..itemIds.count loop
        if(itemIds(i) <> headerItemClassId) then
          return(itemIds(i));
        end if;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getSubItemClassId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getSubItemClassId;
  function getUsageStartDate(ruleIdIn in integer,
                             applicationIdIn in integer,
                             processingDateIn in date) return varchar2 as
    startDate ame_rule_usages.start_date%type;
    begin
      select start_date
        into startDate
        from ame_rule_usages
        where
             rule_id = ruleIdIn and
             item_id = applicationIdIn and
             creation_date = processingDateIn;
      return(ame_util.versionDateToString(dateIn => startDate));
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getUsageStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getUsageStartDate;
  function getType(ruleIdIn in integer) return integer as
    ruleType ame_rules.rule_type%type;
    begin
      select rule_type
        into ruleType
        from ame_rules
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      return(ruleType);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getType',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end getType;
  function getVersionStartDate(ruleIdIn integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_rules
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'getVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getVersionStartDate;
  function hasATUsageForRuleType(ruleTypeIn in integer,
                                 actionTypeIdsIn in ame_util.idList) return boolean as
    cursor actionTypeUsagesCur(actionTypeIdIn in integer) is
      select rule_type
        from ame_action_type_usages
        where
          action_type_id = actionTypeIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
    begin
      for i in 1..actionTypeIdsIn.count loop
        for actionTypeUsagesRec in actionTypeUsagesCur(actionTypeIdIn => actionTypeIdsIn(i)) loop
          if(ruleTypeIn = actionTypeUsagesRec.rule_type) then
            return(true);
          end if;
        end loop;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'hasATUsageForRuleType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end hasATUsageForRuleType;
  function hasATUsageForRuleType2(ruleTypeIn in integer,
                                  actionIdsIn in ame_util.idList) return boolean as
    cursor actionTypeUsagesCur(actionIdIn in integer) is
      select ame_action_type_usages.rule_type
        from ame_action_type_usages,
             ame_action_types,
             ame_actions
        where
          ame_action_types.action_type_id = ame_action_type_usages.action_type_id and
          ame_action_types.action_type_id = ame_actions.action_type_id and
          ame_actions.action_id = actionIdIn and
          sysdate between ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_actions.start_date and
            nvl(ame_actions.end_date - ame_util.oneSecond, sysdate);
    begin
      /*
         With exception of the combination rule type, a rule must have at least
         one action of an action type that has an action-type usage for
         the rule's type.
      */
      if(ruleTypeIn = ame_util.combinationRuleType) then
        return(true);
      end if;
      for i in 1..actionIdsIn.count loop
        for actionTypeUsagesRec in actionTypeUsagesCur(actionIdIn => actionIdsIn(i)) loop
          if(ruleTypeIn = actionTypeUsagesRec.rule_type) then
            return(true);
          end if;
        end loop;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'hasATUsageForRuleType2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end hasATUsageForRuleType2;
  function hasExceptionCondition(conditionIdsIn in ame_util.idList) return boolean as
    begin
      for i in 1..conditionIdsIn.count loop
        if(ame_condition_pkg.getConditionType(conditionIdIn => conditionIdsIn(i)) =
                                                ame_util.exceptionConditionType) then
          return(true);
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'hasExceptionCondition',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end hasExceptionCondition;
  function hasListModCondition(conditionIdsIn in ame_util.idList) return boolean as
    begin
      for i in 1..conditionIdsIn.count loop
        if(ame_condition_pkg.getConditionType(conditionIdIn => conditionIdsIn(i)) =
                                                ame_util.listMOdConditionType) then
          return(true);
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'hasListModCondition',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end hasListModCondition;
  function hasListModCondition2(ruleIdIn in integer) return boolean as
    conditionCount integer;
    begin
      select count(*)
        into conditionCount
        from ame_conditions,
             ame_condition_usages
        where
          ame_conditions.condition_id = ame_condition_usages.condition_id and
          ame_conditions.condition_type = ame_util.listModConditionType and
          ame_condition_usages.rule_id = ruleIdIn and
          (ame_conditions.start_date <= sysdate and
          (ame_conditions.end_date is null or sysdate < ame_conditions.end_date)) and
          ((sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < ame_condition_usages.start_date and
            ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
            ame_condition_usages.start_date + ame_util.oneSecond)));
      if(conditionCount > 0) then
        return(true);
      else
        return(false);
      end if;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'hasListModCondition2',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end hasListModCondition2;
  function hasNonProductionActions(actionIdsIn in ame_util.idList) return boolean as
    actionTypeId integer;
		begin
      for i in 1 .. actionIdsIn.count loop
        actionTypeId :=
				  ame_action_pkg.getActionTypeIdById(actionIdIn => actionIdsIn(i));
        if(ame_action_pkg.getAllowedRuleType(actionTypeIdIn => actionTypeId) <>
          ame_util.productionRuleType) then
          return(true);
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'hasNonProductionActions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end hasNonProductionActions;
  function hasNonProductionActionTypes(actionTypeIdsIn in ame_util.idList) return boolean as
    begin
      for i in 1 .. actionTypeIdsIn.count loop
        if(ame_action_pkg.getAllowedRuleType(actionTypeIdIn => actionTypeIdsIn(i)) <>
          ame_util.productionRuleType) then
          return(true);
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'hasNonProductionActionTypes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end hasNonProductionActionTypes;
  function hasSubOrListModAction(ruleIdIn in integer) return boolean as
    subOrListModActionCount integer;
    begin
      select count(distinct ame_action_types.action_type_id)
        into subOrListModActionCount
        from ame_action_usages,
          ame_actions,
          ame_action_types,
          ame_action_type_usages
        where ame_action_usages.rule_id = ruleIdIn and
          ame_action_usages.action_id = ame_actions.action_id and
          ame_action_types.action_type_id = ame_actions.action_type_id and
          ame_action_type_usages.action_type_id = ame_action_types.action_type_id and
          ame_action_type_usages.rule_type in (ame_util.substitutionRuleType,
                                               ame_util.listModRuleType) and
          sysdate between ame_action_usages.start_date and
            nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_type_usages.start_date and
            nvl(ame_action_type_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_actions.start_date and
            nvl(ame_actions.end_date - ame_util.oneSecond, sysdate);
        if(subOrListModActionCount > 0) then
          return(true);
        else
          return(false);
        end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'hasSubOrListModAction',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end hasSubOrListModAction;
  function isAtLeastOneICAttrSelected(itemClassIdIn in integer,
                                      attributeIdsIn in ame_util.idList) return boolean as
    begin
      for i in 1..attributeIdsIn.count loop
        if(ame_attribute_pkg.getItemClassId(attributeIdIn => attributeIdsIn(i)) =
          itemClassIdIn) then
          return(true);
          exit;
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'isAtLeastOneICAttrSelected',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
        raise;
        return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isAtLeastOneICAttrSelected;
  function isAtLeastOneICCondSelected(itemClassIdIn in integer,
                                      conditionIdsIn in ame_util.idList) return boolean as
    attributeId integer;
    begin
      for i in 1..conditionIdsIn.count loop
        attributeId := ame_condition_pkg.getAttributeId(conditionIdIn => conditionIdsIn(i));
        if(ame_attribute_pkg.getItemClassId(attributeIdIn => attributeId) =
          itemClassIdIn) then
          return(true);
          exit;
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'isAtLeastOneICCondSelected',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
        raise;
        return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isAtLeastOneICCondSelected;
  function isInUse(ruleIdIn in integer) return boolean as
    useCount integer;
    begin
      select count(*)
        into useCount
        from ame_rule_usages
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'isinUse',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isinUse;
  function isInUseByOtherApps(ruleIdIn in integer,
                              applicationIdIn in integer) return boolean as
    useCount integer;
    begin
      select count(*)
        into useCount
        from ame_rule_usages
        where
           rule_id = ruleIdIn and
           item_id <> applicationIdIn and
           ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < start_date and
              start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'isInUseByOtherApps',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isInUseByOtherApps;
  function lastConditionDeleted(conditionIdListIn in ame_util.idList,
                                deletedListIn in ame_util.stringList) return boolean as
    conditionCount integer;
    deleteCount integer;
    begin
      conditionCount := conditionIdListIn.count;
      deleteCount := 0;
      for i in 1..deletedListIn.count loop
        if(deletedListIn(i)) like 'con%' then
          deleteCount := deleteCount + 1;
        end if;
      end loop;
      if(conditionCount = deleteCount) then
        return(true);
      end if;
      return(false);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'lastConditionDeleted',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
        return(true); /* conservative:  avoids allowing deletion */
    end lastConditionDeleted;
  function lineItemJobLevelChosen(actionTypeIdsIn in ame_util.idList) return boolean as
    lineItemJobLevelActionTypeId integer;
    begin
      lineItemJobLevelActionTypeId :=
        ame_action_pkg.getActionTypeIdByName(actionTypeNameIn => ame_util.lineItemJobLevelTypeName);
      for i in 1..actionTypeIdsIn.count loop
        if(actionTypeIdsIn(i) = lineItemJobLevelActionTypeId) then
          return(true);
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'lineItemJobLevelChosen',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end lineItemJobLevelChosen;
  function new(applicationIdIn in integer,
               typeIn in integer,
               conditionIdsIn in ame_util.idList default ame_util.emptyIdList,
               actionIdsIn in ame_util.idList,
               ruleKeyIn in varchar2,
               descriptionIn in varchar2,
               startDateIn in date,
               endDateIn in date default null,
               ruleIdIn in integer default null,
               itemClassIdIn in integer default null,
               finalizeIn in boolean default true,
               processingDateIn in date default null) return integer as
    createdBy integer;
    currentUserId integer;
    startDateToInsert date;
    descriptionInUseException exception;
    descriptionLengthException exception;
    endDateToInsert date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    lastIndex integer;
    processingDate date;
    ruleCount integer;
    ruleId integer;
    ruleKeyLengthException exception;
    startDateException exception;
    startDateException1 exception;
    tempCount integer;
    begin
      /* check to see if processingDate has been initialized */
      if processingDateIn  is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
			/* check to see if description has already been used */
      if ame_rule_pkg.descriptionInUse(descriptionIn => descriptionIn) then
        raise descriptionInUseException;
      end if;
      /* Check and set start date. */
      if ruleIdIn is null then
         if (startDateIn < trunc(processingDate)) then
           raise startDateException; /* Start dates should always be today or later. */
         elsif(trunc(startDateIn) > trunc(processingDate)) then
           startDateToInsert := trunc(startDateIn); /* Truncate future start dates. */
         else
           startDateToInsert := processingDate; /* Don't truncate start dates that are for today. */
         end if;
         /* Check and set end date. */
         if (endDateIn is null) then
           endDateToInsert := null;
         elsif(startDateIn < endDateIn) then /* Non-null end dates should follow start dates, and should be truncated. */
           endDateToInsert := trunc(endDateIn);
         else
           raise startDateException1;
         end if;
      else
         startDateToInsert := startDateIn;
         endDateToInsert := endDateIn;
      end if;
      /* misc preparation for inserts */
			if(lengthb(ruleKeyIn) > 100) then
        raise ruleKeyLengthException;
      end if;
  		if(ame_util.isArgumentTooLong(tableNamein => 'ame_rules',
                                    columnNamein => 'description',
                                    argumentin => descriptionIn)) then
        raise descriptionLengthException;
      end if;
			/*
      If any version of the object has created_by = 1, all versions,
      including the new version, should.  This is a failsafe way to check
      whether previous versions of an already end-dated object had
      created_by = 1.
      */
      currentUserId := ame_util.getCurrentUserId;
      if(ruleIdIn is null) then
        createdBy := currentUserId;
        if(ame_util.getHighestResponsibility = ame_util.developerResponsibility) then
          /* Use negative rule IDs for developer-seeded rules. */
          select count(*)
            into ruleCount
            from ame_rules
            where
             ((sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < start_date and
                 start_date < nvl(end_date,start_date + ame_util.oneSecond))) ;
          if ruleCount = 0 then
            ruleId := -1;
          else
            select min(rule_id) - 1
              into ruleId
              from ame_rules
              where
             ((sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < start_date and
                 start_date < nvl(end_date,start_date + ame_util.oneSecond))) ;
            if(ruleId > -1) then
              ruleId := -1;
            end if;
          end if;
        else
          select ame_rules_s.nextval into ruleId from dual;
        end if;
      else
        ruleId := ruleIdIn;
        select count(*)
         into tempCount
         from ame_rules
           where
             rule_id = ruleId and
             created_by = ame_util.seededDataCreatedById;
        if(tempCount > 0) then
          createdBy := ame_util.seededDataCreatedById;
        else
          createdBy := currentUserId;
        end if;
      end if;
      /* inserts */
      insert into ame_rules(rule_id,
                            rule_type,
                            rule_key,
                            action_id,
                            created_by,
                            creation_date,
                            last_updated_by,
                            last_update_date,
                            last_update_login,
                            start_date,
                            end_date,
                            description,
                            item_class_id)
        values(ruleId,
               typeIn,
               ruleKeyIn,
	           null,
               createdBy,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               startDateToInsert,
               endDateToInsert,
               descriptionIn,
               itemClassIdIn);
      if(conditionIdsIn.count > 0) then
        for tempIndex in 1 .. conditionIdsIn.count loop
          insert into ame_condition_usages(rule_id,
                                           condition_id,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           start_date,
                                           end_date)
          values(ruleId,
                 conditionIdsIn(tempIndex),
                 createdBy,
                 processingDate,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 startDateToInsert,
                 endDateToInsert);
        end loop;
      end if;
      for tempIndex in 1 .. actionIdsIn.count loop
        insert into ame_action_usages(rule_id,
                                      action_id,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date,
                                      last_update_login,
                                      start_date,
                                      end_date)
          values(ruleId,
                 actionIdsIn(tempIndex),
                 createdBy,
                 processingDate,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 startDateToInsert,
                 endDateToInsert);
      end loop;
/*
AME_STRIPING
      if(ame_admin_pkg.isStripingOn(applicationIdIn => applicationIdIn)) then
        updateRuleStripeSets(applicationIdIn => applicationIdIn,
                             ruleIdIn => ruleId,
                             conditionIdsIn => conditionIdsIn);
      end if;
*/
      if(ruleIdIn is null and
         finalizeIn) then
        commit;
      end if;
      return(ruleId);
    exception
			when ruleKeyLengthException then
        rollback;
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
          messageNameIn   => 'AME_400361_RULE_KEY_LONG',
          tokenNameOneIn  => 'COLUMN_LENGTH',
          tokenValueOneIn => 100);
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'new',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
        return(null);
			when descriptionInUseException then
        rollback;
        errorCode := -20001;
        errorMessage :=
        ame_util.getMessage(applicationShortNameIn => 'PER',
          messageNameIn   => 'AME_400206_RUL_DESC_IN_USE');
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'new',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
        return(null);
			when descriptionLengthException then
        rollback;
        errorCode := -20001;
        errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
          messageNameIn   => 'AME_400207_RUL_DESC_LONG',
          tokenNameOneIn  => 'COLUMN_LENGTH',
          tokenValueOneIn => ame_util.getColumnLength(tableNamein => 'ame_rules',
                                                   columnNamein => 'description'));
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'new',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
        return(null);
      when startDateException then
        rollback;
        errorCode := -20001;
        errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
           messageNameIn => 'AME_400208_RUL_STRT_PREC_TDY');
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'new',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
        return(null);
      when startDateException1 then
        rollback;
        errorCode := -20001;
        errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
          messageNameIn => 'AME_400209_RUL_STRT_PREC_END');
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'new',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
        return(null);
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'new',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
        return(null);
    end new;
/*
AME_STRIPING
  procedure newRuleStripeSet(applicationIdIn in integer,
                             ruleIdIn in integer,
                             stripeSetIdIn in integer) as
    attributeCount integer;
    currentUserId integer;
    endDate date;
    errorCode integer;
    errorMessage varchar2(200);
    lineItemAttribute ame_attributes.line_item%type;
    newStartDate date;
    queryString ame_attribute_usages.query_string%type;
    staticUsage ame_attribute_usages.is_static%type;
    stripingAttributeIds ame_util.idList;
    stripingAttributeNames ame_util.stringList;
    useCount integer;
    begin
      currentUserId := ame_util.getCurrentUserId;
      select count(*)
        into useCount
        from ame_rule_stripe_sets
        where
          rule_id = ruleIdIn and
          stripe_set_id = stripeSetIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      if(useCount > 0) then
        return;
      end if;
      insert into ame_rule_stripe_sets(rule_id,
                                       stripe_set_id,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
                                       last_update_login,
                                       security_group_id,
                                       start_date,
                                       end_date)
            values(ruleIdIn,
                   stripeSetIdIn,
                   currentUserId,
                   sysdate,
                   currentUserId,
                   sysdate,
                   currentUserId,
                   null,
                   sysdate,
                   null);
      ame_admin_pkg.updateStripingAttUseCount(applicationIdIn => applicationIdIn);
      commit;
      exception
       when others then
         rollback;
         ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                   routineNamein => 'newRuleStripeSet',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
         raise;
    end newRuleStripeSet;
*/
  function newRuleUsage(itemIdIn in integer,
                        ruleIdIn in integer,
                        startDateIn in date,
                        endDateIn in date default null,
                        categoryIn in varchar2 default null,
                        priorityIn in varchar2 default null,
                        finalizeIn in boolean default false,
                        parentVersionStartDateIn in date,
                        processingDateIn in date default null,
                        updateParentObjectIn in boolean default false) return boolean as
    cursor startDateCursor is
      select start_date
        from ame_rules
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)))
        for update;
    actionIdList ame_util.idList;
    description ame_rules.description%type;
    approvalCategory ame_util.stringType;
    conditionIdList ame_util.idList;
    createdBy integer;
    createUsage boolean;
    currentUserId integer;
    newRuleEndDate ame_rules.end_date%type;
    newRuleStartDate ame_rules.start_date%type;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidDateException exception;
    itemClassId integer;
    itemIdCount integer;
    objectVersionNoDataException exception;
    invalidPriorityException exception;
    ruleKey ame_rules.rule_key%type;
    ruleId ame_rules.rule_id%type;
    ruleType ame_rules.rule_type%type;
    ruleStartDate date;
    usageExistsException exception;
    startDateException exception;
    startDateException1 exception;
    tempCount integer;
    useCount integer;
    startDateToInsert date;
    endDateToInsert date;
    processingDate date;
    endDate date;
    overlappingUsage number;
    usageAlreadyExists exception;
    usageExistsWithDiffPriority exception;
    usageOverlaps exception;
    begin
      /* check to see if processingDate has been initialized */
      if processingDateIn  is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      /* Check to make sure that there are no overlapping timespans */
      overlappingUsage :=  checkRuleUsageExists(applicationIdIn => itemIdIn,
                              ruleIdIn => ruleIdIn,
                              startDateIn => startDateIn,
                              endDateIn => endDateIn,
                              processingDateIn => processingDate,
                              priorityIn => priorityIn ) ;
      if overlappingUsage = 1 then
        raise usageAlreadyExists;
      elsif overlappingUsage = 2 then
        raise usageExistsWithDiffPriority;
      elsif overlappingUsage = 3 then
        raise usageOverlaps;
      end if;
      if(finalizeIn) then
        open startDateCursor;
          fetch startDateCursor into ruleStartDate;
          if startDateCursor%notfound then
            raise objectVersionNoDataException;
          end if;
          if(parentVersionStartDateIn <> ruleStartDate) then
            close startDateCursor;
            raise ame_util.objectVersionException;
          end if;
      end if;
      ruleKey := getRuleKey(ruleIdIn => ruleIdIn);
      ruleType := getRuleType(ruleIdIn => ruleIdIn);
      itemClassId := getItemClassId(ruleIdIn => ruleIdIn);
      if(ame_rule_pkg.useRulePriorityMode(applicationIdIn => itemIdIn,
                                          ruleTypeIn => ruleType)) then
          if (priorityIn is null) or
             (not(ame_util.isANumber(stringIn => priorityIn,
                                     allowDecimalsIn => false,
                                     allowNegativesIn => false))) then
             raise invalidPriorityException;
          end if;
        end if;
        /* Check and set start date. for rule usage  */
        if (startDateIn < trunc(processingDate)) then
          raise startDateException; /* Start dates should always be today or later. */
        elsif(trunc(startDateIn) > trunc(processingDate)) then
          startDateToInsert := trunc(startDateIn); /* Truncate future start dates.  */
        else
          startDateToInsert := processingDate; /* Don't truncate start dates that are for today. */
        end if;
        /* Check and set end date for rule usage. */
        if(endDateIn is null) then
          endDateToInsert := null;
        elsif(trunc(endDateIn)) = trunc(processingDate) then
          endDateToInsert := processingDate;
        elsif(startDateIn < endDateIn) then /* Non-null end dates should follow start dates, and should be truncated. */
          endDateToInsert := trunc(endDateIn);
        else
          raise startDateException1;
        end if;
        if(endDateToInsert = startDateToInsert) then
          raise invalidDateException;
        end if;
        select count(*)
          into useCount
          from ame_rule_usages
          where
            rule_id = ruleIdIn and
            item_id = itemIdIn and
            trunc(start_date) = startDateIn and
            nvl(end_date, processingDate) = nvl(endDateIn, processingDate) and
            ((sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate)) or
                (sysdate < start_date and
                   start_date < nvl(end_date,start_date + ame_util.oneSecond))) ;
        if(useCount > 0) then
          raise usageExistsException;
        end if;
        currentUserId := ame_util.getCurrentUserId;
        select count(*)
          into tempCount
          from ame_rule_usages
            where
              rule_id = ruleIdIn and
              item_id = itemIdIn and
              created_by = ame_util.seededDataCreatedById;
        if(tempCount > 0) then
          createdBy := ame_util.seededDataCreatedById;
        else
          createdBy := currentUserId;
        end if;
        approvalCategory := categoryIn;
        /* The category should default to ame_util.approvalApproverCategory
           if the categoryIn value is null for rule types other than
           list modification and substitution */
        if(ruleType in (ame_util.authorityRuleType,
                        ame_util.exceptionRuleType,
                        ame_util.preListGroupRuleType,
                        ame_util.postListGroupRuleType,
                        ame_util.combinationRuleType)) then
          if(categoryIn is null) then
            approvalCategory := ame_util.approvalApproverCategory;
          end if;
        end if;
        insert into ame_rule_usages(item_id,
                                    rule_id,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
                                    last_update_date,
                                    last_update_login,
                                    start_date,
                                    end_date,
                                    priority,
                                    approver_category)
            values(itemIdIn,
                   ruleIdIn,
                   currentUserId,
                   processingDate,
                   currentUserId,
                   processingDate,
                   currentUserId,
                   startDateToInsert,
                   endDateToInsert,
                   priorityIn,
                   approvalCategory);
        /*  ruleType := getRuleType(ruleIdIn => ruleIdIn); */
        if updateParentObjectIn then
          endDate := processingDate;
          description := getDescription(ruleIdIn => ruleIdIn);
          newRuleStartDate := getnewRuleStartDate(ruleIdIn => ruleIdIn,
                                                  processingDateIn => processingDate);
          newRuleEndDate := getnewRuleEndDate(ruleIdIn => ruleIdIn,
                                              processingDateIn => processingDate);
          getActionIds(ruleIdIn => ruleIdIn,
                       actionIdListOut => actionIdList);
          for i in 1..actionIdList.count loop
            update ame_action_usages
              set
                last_updated_by = currentUserId,
                last_update_date = processingDate,
                last_update_login = currentUserId,
                end_date = endDate
                where
                  rule_id = ruleIdIn and
                  action_id = actionIdList(i) and
                  ((processingDate between start_date and
                   nvl(end_date - ame_util.oneSecond, processingDate)) or
                   (processingDate < start_date and
                   start_date < nvl(end_date,start_date + ame_util.oneSecond)));
          end loop;
          getConditionIds(ruleIdIn => ruleIdIn,
                          conditionIdListOut => conditionIdList);
          if conditionIdList.count > 0 then
            for i in 1..conditionIdList.count loop
              update ame_condition_usages
                set
                  last_updated_by = currentUserId,
                  last_update_date = processingDate,
                  last_update_login = currentUserId,
                  end_date = endDate
                  where
                  rule_id = ruleIdIn and
                  condition_id = conditionIdList(i) and
                  ((processingDate between start_date and
                   nvl(end_date - ame_util.oneSecond, processingDate)) or
                   (processingDate < start_date and
                   start_date < nvl(end_date,start_date + ame_util.oneSecond)));
            end loop;
          end if;
          update ame_rules
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = endDate
            where
              rule_id = ruleIdIn and
              ((processingDate between start_date and
               nvl(end_date - ame_util.oneSecond, processingDate)) or
               (processingDate < start_date and
               start_date < nvl(end_date,start_date + ame_util.oneSecond)));
          ruleId := new(applicationIdIn => itemIdIn,
                        typeIn => ruleType,
                        conditionIdsIn => conditionIdList,
                        actionIdsIn => actionIdList,
                        itemClassIdIn => itemClassId,
                        ruleKeyIn => ruleKey,
                        descriptionIn => description,
                        startDateIn => newRuleStartDate,
                        endDateIn => newRuleEndDate,
                        ruleIdIn => ruleIdIn,
                        finalizeIn => false,
                        processingDateIn => processingDateIn);
        end if;
        changeAttributeUseCounts(ruleIdIn => ruleIdIn,
                                 applicationIdIn => itemIdIn,
                                 finalizeIn => false);
      if(finalizeIn) then
        commit;
        close startDateCursor;
      end if;
      return(true);
      exception
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
    when usageAlreadyExists then
          rollback;
          errorCode := -20001;
          errorMessage :=
             ame_util.getMessage(applicationShortNameIn => 'PER',
             messageNameIn => 'AME_400327_RULE_USG_EXST_LIFE');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
    when usageExistsWithDiffPriority then
          rollback;
          errorCode := -20001;
          errorMessage :=
             ame_util.getMessage(applicationShortNameIn => 'PER',
             messageNameIn => 'AME_400328_RULE_USG_DIFF_PRIOR');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
    when usageOverlaps then
          rollback;
          errorCode := -20001;
          errorMessage :=
             ame_util.getMessage(applicationShortNameIn => 'PER',
             messageNameIn => 'AME_400329_RULE_USG_OVER_LIFE');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
      when invalidPriorityException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400288_RUL_PRI_NOT_VAL');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when startDateException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
             messageNameIn => 'AME_400208_RUL_STRT_PREC_TDY');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when startDateException1 then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400214_RUL_STRT_LESS_END');
            ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when usageExistsException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400210_RUL_USAGE_EXISTS');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
       when invalidDateException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400437_RULE_USAGE_END_DATE');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'newRuleUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
       when others then
         rollback;
         if(startDateCursor%isOpen) then
           close startDateCursor;
         end if;
         ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                   routineNamein => 'newRuleUsage',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
         raise;
         return(null);
    end newRuleUsage;
  function nonFinalAuthorityActionType(actionTypeIdsIn in ame_util.idList) return boolean as
    nonFinalAuthActionTypeId integer;
    begin
      nonFinalAuthActionTypeId :=
        ame_action_pkg.getActionTypeIdByName(actionTypeNameIn => ame_util.nonFinalAuthority);
      for i in 1..actionTypeIdsIn.count loop
        if(actionTypeIdsIn(i) = nonFinalAuthActionTypeId) then
          return(true);
        end if;
      end loop;
      return(false);
    exception
    when others then
      rollback;
      ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                routineNamein => 'nonFinalAuthorityActionType',
                                exceptionNumberIn => sqlcode,
                                exceptionStringIn => sqlerrm);
        raise;
        return(true);
    end nonFinalAuthorityActionType;
  function nonFinalAuthorityActionType2(ruleIdIn in integer) return boolean as
     cursor actionTypeIdsCursor(ruleIdIn in integer) is
       select distinct(ame_action_types.action_type_id) action_type_id
         from ame_action_types,
              ame_actions,
              ame_action_usages
         where
           ame_action_types.action_type_id = ame_actions.action_type_id and
           ame_actions.action_id = ame_action_usages.action_id and
           ame_action_usages.rule_id = ruleIdIn and
           sysdate between ame_action_usages.start_date and
             nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_action_types.start_date and
             nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_actions.start_date and
             nvl(ame_actions.end_date - ame_util.oneSecond, sysdate);
     nonFinalAuthActionTypeId integer;
    begin
      nonFinalAuthActionTypeId :=
        ame_action_pkg.getActionTypeIdByName(actionTypeNameIn => ame_util.nonFinalAuthority);
      for actionTypeIdsRec in actionTypeIdsCursor(ruleIdIn => ruleIdIn) loop
        if(actionTypeIdsRec.action_type_id = nonFinalAuthActionTypeId) then
          return(true);
        end if;
      end loop;
      return(false);
      exception
       when others then
         rollback;
         ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                   routineNamein => 'nonFinalAuthorityActionType2',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         raise;
         return(true);
     end nonFinalAuthorityActionType2;
  function ordinaryConditionsExist(ruleIdIn in integer) return boolean as
    conditionCount integer;
    begin
      select count(*)
        into conditionCount
        from ame_conditions,
             ame_condition_usages
        where
          ame_conditions.condition_id = ame_condition_usages.condition_id and
          ame_condition_usages.rule_id = ruleIdIn and
          ame_conditions.condition_type = ame_util.ordinaryConditionType and
          sysdate between ame_conditions.start_date and
            nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
          ((sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < ame_condition_usages.start_date and
            ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
              ame_condition_usages.start_date + ame_util.oneSecond)));
      if(conditionCount > 0) then
        return(true);
      end if;
      return(false);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'ordinaryConditionsExist',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
        return(true); /* conservative:  avoids allowing deletion */
    end ordinaryConditionsExist;
  function ruleAlreadyExistsForTransType(typeIn in varchar2,
                                         conditionIdListIn in ame_util.idList,
                                         actionIdListIn in ame_util.idList,
                                         applicationIdIn in integer,
                                         itemClassIdIn in integer default null) return boolean as
    cursor ruleIdCursor(typeIn in varchar2,
                        applicationIdIn in integer,
                        itemClassIdIn in integer default null) is
      select ame_rules.rule_id
        from ame_rules,
             ame_rule_usages
        where
          item_id = applicationIdIn and
          rule_type = typeIn and
          (item_class_id is null or
           item_class_id = itemClassIdIn) and
          ame_rules.rule_id = ame_rule_usages.rule_id and
          ((sysdate between ame_rules.start_date and
              nvl(ame_rules.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_rules.start_date and
              ame_rules.start_date < nvl(ame_rules.end_date,
                ame_rules.start_date + ame_util.oneSecond))) and
          ((sysdate between ame_rule_usages.start_date and
              nvl(ame_rule_usages.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_rule_usages.start_date and
              ame_rule_usages.start_date < nvl(ame_rule_usages.end_date,
                ame_rule_usages.start_date + ame_util.oneSecond)));
    actionIdList1 ame_util.idList;
    actionIdList2 ame_util.idList;
    actionIdMatch boolean;
    conditionIdList1 ame_util.idList;
    conditionIdList2 ame_util.idList;
    conditionIdMatch boolean;
    ruleId ame_rules.rule_id%type;
    begin
      ruleId := null;
      conditionIdList1 := conditionIdListIn;
      ame_util.sortIdListInPlace(idListInOut => conditionIdList1);
      actionIdList1 := actionIdListIn;
      ame_util.sortIdListInPlace(idListInOut => actionIdList1);
      actionIdMatch := false;
      conditionIdMatch := false;
      for tempRuleId in ruleIdCursor(typeIn => typeIn,
                                     applicationIdIn => applicationIdIn,
                                     itemClassIdIn => itemClassIdIn) loop
        getConditionIds(ruleIdIn => tempRuleId.rule_id,
                        conditionIdListOut => conditionIdList2);
        ame_util.sortIdListInPlace(idListInOut => conditionIdList2);
        if(ame_util.idListsMatch(idList1InOut => conditionIdList1,
                                 idList2InOut => conditionIdList2,
                                 sortList1In => false,
                                 sortList2In => false)) then
          conditionIdMatch := true;
        end if;
        getActionIds(ruleIdIn => tempRuleId.rule_id,
                     actionIdListOut => actionIdList2);
        ame_util.sortIdListInPlace(idListInOut => actionIdList2);
        if(ame_util.idListsMatch(idList1InOut => actionIdList1,
                                 idList2InOut => actionIdList2,
                                 sortList1In => false,
                                 sortList2In => false)) then
          actionIdMatch := true;
        end if;
        if(conditionIdMatch and actionIdMatch) then
          return(true);
        end if;
        conditionIdList2.delete;
        actionIdList2.delete;
        conditionIdMatch := false;
        actionIdMatch := false;
        ruleId := tempRuleId.rule_id;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'ruleAlreadyExistsForTransType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                         ruleId ||
                                                         ') ' ||
                                                         sqlerrm);
          raise;
          return(true);
    end ruleAlreadyExistsForTransType;
  function ruleExists(typeIn in varchar2,
                      conditionIdListIn in ame_util.idList,
                      actionIdListIn ame_util.idList,
                      itemClassIdIn in integer default null) return boolean as
    cursor ruleIdCursor(typeIn in varchar2,
                        itemClassIdIn in integer default null) is
      select rule_id
        from ame_rules
        where
          rule_type = typeIn and
          (item_class_id is null or
           item_class_id = itemClassIdIn) and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
            start_date < nvl(end_date,start_date + ame_util.oneSecond)));
    actionIdList1 ame_util.idList;
    actionIdList2 ame_util.idList;
    actionIdMatch boolean;
    conditionIdList1 ame_util.idList;
    conditionIdList2 ame_util.idList;
    conditionIdMatch boolean;
	ruleId ame_rules.rule_id%type;
    begin
      ruleId := null;
      conditionIdList1 := conditionIdListIn;
      ame_util.sortIdListInPlace(idListInOut => conditionIdList1);
      actionIdList1 := actionIdListIn;
      ame_util.sortIdListInPlace(idListInOut => actionIdList1);
      conditionIdMatch := false;
      actionIdMatch := false;
      for tempRuleId in ruleIdCursor(typeIn => typeIn,
                                     itemClassIdIn => itemClassIdIn) loop
        getConditionIds(ruleIdIn => tempRuleId.rule_id,
                        conditionIdListOut => conditionIdList2);
        ame_util.sortIdListInPlace(idListInOut => conditionIdList2);
        if(ame_util.idListsMatch(idList1InOut => conditionIdList1,
                                 idList2InOut => conditionIdList2,
                                 sortList1In => false,
                                 sortList2In => false)) then
          conditionIdMatch := true;
        end if;
        getActionIds(ruleIdIn => tempRuleId.rule_id,
                     actionIdListOut => actionIdList2);
        ame_util.sortIdListInPlace(idListInOut => actionIdList2);
        if(ame_util.idListsMatch(idList1InOut => actionIdList1,
                                 idList2InOut => actionIdList2,
                                 sortList1In => false,
                                 sortList2In => false)) then
          actionIdMatch := true;
        end if;
        if(conditionIdMatch and actionIdMatch) then
          return(true);
        end if;
        ruleId := tempRuleId.rule_id;
        conditionIdList2.delete;
        actionIdList2.delete;
        conditionIdMatch := false;
        actionIdMatch := false;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'ruleExists',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                         ruleId ||
                                                         ') ' ||
                                                         sqlerrm);
          raise;
          return(true);
    end ruleExists;
  function subordinateICCondExist(ruleIdIn in integer) return boolean as
    headerItemClassId integer;
    tempCount integer;
    begin
      headerItemClassId :=
        ame_admin_pkg.getItemClassIdByName(itemClassNameIn =>
                                             ame_util.headerItemClassName);
      select count(*)
        into tempCount
        from ame_conditions,
             ame_attributes,
             ame_condition_usages
        where
          ame_conditions.condition_id = ame_condition_usages.condition_id and
          ame_conditions.attribute_id = ame_attributes.attribute_id and
          ame_condition_usages.rule_id = ruleIdIn and
          ame_attributes.item_class_id <> headerItemClassId and
          (sysdate between ame_conditions.start_date and
            nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate)) and
          (sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) and
          (sysdate between ame_attributes.start_date and
            nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate));
      if(tempCount > 0) then
        return(true);
      else
        return(false);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'subordinateICCondExist',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
        raise;
        return(false);
    end subordinateICCondExist;
  function useRulePriorityMode(applicationIdIn in integer,
                               ruleTypeIn in varchar2) return boolean as
    variableValue ame_util.longStringType;
    begin
      variableValue := ame_util.getConfigVar(variableNameIn => ame_util.rulePriorityModesConfigVar,
                                             applicationIdIn => applicationIdIn);
      if(ruleTypeIn = ame_util.combinationRuleType) then
        if(substrb(variableValue, 1, (instr(variableValue,':',1,1) -1))
          = ame_util.disabledRulePriority) then
          return(false);
        end if;
      elsif(ruleTypeIn = ame_util.authorityRuleType) then
        if(substrb(variableValue,
                  (instr(variableValue,':',1,1) +1),
                  (instr(variableValue,':',1,2) -
                  (instr(variableValue,':',1,1) +1)))
          = ame_util.disabledRulePriority) then
          return(false);
        end if;
      elsif(ruleTypeIn = ame_util.exceptionRuleType) then
        if(substrb(variableValue,
                  (instr(variableValue,':',1,2) +1),
                  (instr(variableValue,':',1,3) -
                  (instr(variableValue,':',1,2) +1)))
          = ame_util.disabledRulePriority) then
          return(false);
        end if;
      elsif(ruleTypeIn = ame_util.listModRuleType) then
        if(substrb(variableValue,
                  (instr(variableValue,':',1,3) +1),
                  (instr(variableValue,':',1,4) -
                  (instr(variableValue,':',1,3) +1)))
          = ame_util.disabledRulePriority) then
          return(false);
        end if;
      elsif(ruleTypeIn = ame_util.substitutionRuleType) then
        if(substrb(variableValue,
                  (instr(variableValue,':',1,4) +1),
                  (instr(variableValue,':',1,5) -
                  (instr(variableValue,':',1,4) +1)))
          = ame_util.disabledRulePriority) then
          return(false);
        end if;
      elsif(ruleTypeIn = ame_util.preListGroupRuleType) then
        if(substrb(variableValue,
                  (instr(variableValue,':',1,5) +1),
                  (instr(variableValue,':',1,6) -
                  (instr(variableValue,':',1,5) +1)))
          = ame_util.disabledRulePriority) then
          return(false);
        end if;
      elsif(ruleTypeIn = ame_util.postListGroupRuleType) then
        if(substrb(variableValue,
                  (instr(variableValue,':',1,6) +1),
                  (instr(variableValue,':',1,7) -
                  (instr(variableValue,':',1,6) +1)))
          = ame_util.disabledRulePriority) then
          return(false);
        end if;
      elsif(ruleTypeIn = ame_util.productionRuleType) then
        if(substrb(variableValue,
                  (instr(variableValue,':',1,7) +1))
          = ame_util.disabledRulePriority) then
          return(false);
        end if;
      end if;
      return(true);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'useRulePriorityMode',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end useRulePriorityMode;
  /* procedures */
  procedure change(ruleIdIn in integer,
                   typeIn in integer default null,
                   conditionIdsIn in ame_util.idList default ame_util.emptyIdList,
                   actionIdsIn in ame_util.idList default ame_util.emptyIdList,
                   deleteListIn in ame_util.stringList default ame_util.emptyStringList,
                   descriptionIn in varchar2 default null,
                   applicationIdIn in integer default null,
                   parentVersionStartDateIn in date,
                   finalizeIn in boolean default false,
                   processingDateIn in date default null) as
    cursor ruleStartDateCursor is
      select start_date
        from ame_rules
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)))
        for update;
    actionCount integer;
    actionCount2 integer;
    actionDeletionException exception;
    actionId integer;
    actionId1 ame_actions.action_id%type;
    actionIdListCopy ame_util.idList;
    actionTypeId1 ame_action_types.action_type_id%type;
    actionTypeId2 ame_action_types.action_type_id%type;
    actionTypeUsageException exception;
    conditionCount integer;
    applicationIds ame_util.idList;
    conditionId integer;
    conditionIdListCopy ame_util.idList;
    currentUserId integer;
    description ame_rules.description%type;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    exceptionConditionException exception;
    inUseException exception;
    itemClassId integer;
    listModConditionException exception;
    newActionIdList ame_util.idList;
    newConditionIdList ame_util.idList;
    newStartDate date;
    newEndDate date;
    newUsageResult boolean;
    nonProductionActionException exception;
    objectVersionNoDataException exception;
    ruleId integer;
    ruleKey ame_rules.rule_key%type;
    ruleType integer;
    ruleStartDate ame_rules.start_date%type;
    ruleEndDate ame_rules.end_date%type;
    tempCount integer;
    tempIndex2 integer;
    processingDate date;
    newVersionStartDate date;
    begin
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      if(finalizeIn) then
        open ruleStartDateCursor;
          fetch ruleStartDateCursor into ruleStartDate;
          if ruleStartDateCursor%notfound then
            raise objectVersionNoDataException;
          end if;
          if parentVersionStartDateIn <> ruleStartDate then
            close ruleStartDateCursor;
            raise ame_util.objectVersionException;
          end if;
      end if;
      if(typeIn is null) then
        ruleType := getType(ruleIdIn => ruleIdIn);
      else
        ruleType := typeIn;
      end if;
      ruleKey := getRuleKey(ruleIdIn => ruleIdIn);
      if(descriptionIn is null) then
        description := getDescription(ruleIdIn => ruleIdIn);
      else
        description := descriptionIn;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      /* make sure the end_date and start_date values do not overlap */
      endDate := processingDate ;
      /* To figure out the start_date for the new row in ame_rules the
      logic is : If no value of start date is inputed in the routine then
      start date is not changed, then for future dated rules, the start_date
      is retained otherwise it becomes the processing date */
      if(trunc(ruleStartDate) > trunc(processingDate)) then
        newStartDate := trunc(ruleStartDate);
      else
        newStartDate := processingDate;
      end if;
      /* To figure out the end date for the new row in ame_rules the logic
      is: If no value for end_date is inputed in the routine then end date
      is not changed. In this case the end_date from the old row is retained
      */
      ruleEndDate := getEndDate(ruleIdIn => ruleIdIn);
      if ruleEndDate is null then
        newEndDate := null;
      else
        newEndDate := ruleEndDate;
      end if;
      itemClassId := ame_rule_pkg.getItemClassId(ruleIdIn => ruleIdIn);
      newConditionIdList := conditionIdsIn;
      conditionCount := newConditionIdList.count;
      newActionIdList := actionIdsIn;
      actionCount := newActionIdList.count;
      actionCount2 := 0;
      /* Verify that at least on action remains for the rule. */
      if(deleteListIn.count > 0) then
        for i in 1..deleteListIn.count loop
          if(deleteListIn(i) like 'act%') then
            actionCount2 := (actionCount2 + 1);
          end if;
        end loop;
        /* If no actions remain, raise an exception. */
        if(actionCount2 = actionCount) then
          raise actionDeletionException;
        end if;
        for i in 1..deleteListIn.count loop
          if(deleteListIn(i)) like 'con%' then
            conditionId := to_number(substrb(deleteListIn(i),4,(lengthb(deleteListIn(i)))));
            for j in 1..conditionCount loop
              if(newConditionIdList(j) = conditionId) then
                /* there is a match so delete from the condition list */
                newConditionIdList.delete(j);
                for k in (j + 1) .. conditionCount loop
                  /* reindex those conditions that fall above the deleted condition */
                  newConditionIdList(k-1) := newConditionIdList(k);
                end loop;
                /* the last condition in the index was reset in the loop above
                   which now leaves a duplicate so delete the duplicate */
                newConditionIdList.delete(conditionCount);
                /* get the new condition count */
                conditionCount := newConditionIdList.count;
                exit;
              end if;
            end loop;
          else
            actionId := to_number(substrb(deleteListIn(i),4,(lengthb(deleteListIn(i)))));
            for j in 1..actionCount loop
              if(newActionIdList(j) = actionId) then
                /* there is a match so delete from the action list */
                newActionIdList.delete(j);
                for k in (j + 1) .. actionCount loop
                  /* reindex those actions that fall above the deleted action */
                  newActionIdList(k-1) := newActionIdList(k);
                end loop;
                /* the last action in the index was reset in the loop above
                   which now leaves a duplicate so delete the duplicate */
                newActionIdList.delete(actionCount);
                /* get the new action count */
                actionCount := newActionIdList.count;
                exit;
              end if;
            end loop;
          end if;
        end loop;
        itemClassId := ame_rule_pkg.getItemClassId(ruleIdIn => ruleIdIn);
        if(ruleExists(typeIn => ruleType,
                      itemClassIdIn => itemClassId,
                      conditionIdListIn => newConditionIdList,
                      actionIdListIn => newActionIdList)) then
          raise inUseException;
        end if;
      end if;
      /*
         With exception of the combination rule type, a rule must have at least
         one action of an action type that has an action-type usage for
         the rule's type.
      */
      if(not ame_rule_pkg.hasATUsageForRuleType2(ruleTypeIn => ruleType,
                                                 actionIdsIn => newActionIdList)) then
        raise actionTypeUsageException;
      end if;
      if(ruleType = ame_util.combinationRuleType) then
        if(not ame_rule_pkg.hasNonProductionActions(actionIdsIn => newActionIdList)) then
          raise nonProductionActionException;
        end if;
      end if;
      /* Exception rules must have at least one exception condition. */
      if(ruleType = ame_util.exceptionRuleType) then
        if(not ame_rule_pkg.hasExceptionCondition(conditionIdsIn => newConditionIdList)) then
          raise exceptionConditionException;
        end if;
      end if;
      /*  List-modification and substitution rules must have exactly one list-modification condition. */
      if(ruleType in (ame_util.listModRuleType, ame_util.substitutionRuleType)) then
        if(not ame_rule_pkg.hasListModCondition(conditionIdsIn => newConditionIdList)) then
          raise listModConditionException;
        end if;
      end if;
      update ame_condition_usages
        set
              last_updated_by = currentUserId,
              last_update_date = endDate,
              last_update_login = currentUserId,
              end_date = endDate
            where
              rule_id = ruleIdIn and
              ((sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < start_date and
                 start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      update ame_action_usages
        set
          last_updated_by = currentUserId,
          last_update_date = endDate,
          last_update_login = currentUserId,
          end_date = endDate
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
             start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      update ame_rules
            set
              last_updated_by = currentUserId,
              last_update_date = endDate,
              last_update_login = currentUserId,
              end_date = endDate
            where
              rule_id = ruleIdIn and
              ((sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < start_date and
                 start_date < nvl(end_date,start_date + ame_util.oneSecond)));
      ruleId := new(applicationIdIn => applicationIdIn,
                    typeIn => ruleType,
                    conditionIdsIn => newConditionIdList,
                    actionIdsIn => newActionIdList,
                    itemClassIdIn => itemClassId,
                    ruleKeyIn => ruleKey,
                    descriptionIn => description,
                    startDateIn => newStartDate,
                    endDateIn => newEndDate,
                    ruleIdIn => ruleIdIn,
                    finalizeIn => false,
                    processingDateIn => processingDate);
      changeAllAttributeUseCounts(ruleIdIn => ruleIdIn,
                                      finalizeIn => false);
      if(finalizeIn) then
        close ruleStartDateCursor;
        commit;
      end if;
    exception
        when ame_util.objectVersionException then
          rollback;
          if(ruleStartDateCursor%isOpen) then
            close ruleStartDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(ruleStartDateCursor%isOpen) then
            close ruleStartDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when inUseException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400212_RUL_PROP_EXISTS');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when actionTypeUsageException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400382_RULE_ONE_ACT_SEL');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when actionDeletionException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400383_RULE_ONE_ACT_SEL2');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when nonProductionActionException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400464_RULE_NONPROD_ACTION');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when exceptionConditionException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400384_RULE_ONE_EXC_COND');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when listModConditionException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400385_RULE_LM');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(ruleStartDateCursor%isOpen) then
            close ruleStartDateCursor;
          end if;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'change',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end change;
  procedure changeAllAttributeUseCounts(ruleIdIn in integer,
                                        finalizeIn in boolean default true) as
    cursor applicationCursor(ruleIdIn in integer) is
      select item_id
        from ame_rule_usages
        where
          rule_id = ruleIdIn and
             ((sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < start_date and
                 start_date < nvl(end_date,start_date + ame_util.oneSecond))) ;
    begin
      for tempApplication in applicationCursor(ruleIdIn => ruleIdIn) loop
        changeAttributeUseCounts(ruleIdIn => ruleIdIn,
                                 applicationIdIn => tempApplication.item_id,
                                 finalizeIn => finalizeIn);
      end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'changeAllAttributeUseCounts',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
    end changeAllAttributeUseCounts;
  procedure changeAttributeUseCounts(ruleIdIn in integer,
                                     applicationIdIn in integer,
                                     finalizeIn in boolean default true) as
    attributeIds ame_util.idList;
    upperLimit integer;
    begin
      getRequiredAttributes(ruleIdIn => ruleIdIn,
                            attributeIdsOut => attributeIds);
      upperLimit := attributeIds.count;
      for i in 1 .. upperLimit loop
        ame_attribute_pkg.updateUseCount(attributeIdIn => attributeIds(i),
                                         applicationIdIn => applicationIdIn,
                                         finalizeIn => finalizeIn);
      end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                  routineNameIn => 'changeAttributeUseCounts',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
  end changeAttributeUseCounts;
  procedure changeAttributeUseCounts2(attributeIdsIn in ame_util.idList,
                                      applicationIdIn in integer,
                                      finalizeIn in boolean default true) as
    upperLimit integer;
    begin
      upperLimit := attributeIdsIn.count;
      for i in 1 .. upperLimit loop
        ame_attribute_pkg.updateUseCount(attributeIdIn => attributeIdsIn(i),
                                         applicationIdIn => applicationIdIn,
                                         finalizeIn => finalizeIn);
      end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                  routineNameIn => 'changeAttributeUseCounts2',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
    end changeAttributeUseCounts2;
/*
AME_STRIPING
  procedure changeRuleStripe(ruleIdIn in integer,
                             oldStripeSetIdIn in integer,
                             newStripeSetIdIn in integer) as
    currentUserId integer;
    begin
      currentUserId := ame_util.getCurrentUserId;
      update ame_rule_stripe_sets
        set
          last_updated_by = currentUserId,
          last_update_date = sysdate,
          last_update_login = currentUserId,
          end_date = sysdate
        where
          rule_id = ruleIdIn and
          stripe_set_id = oldStripeSetIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      insert into ame_rule_stripe_sets(rule_id,
                                       stripe_set_id,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
                                       last_update_login,
                                       security_group_id,
                                       start_date,
                                       end_date)
        values(ruleIdIn,
               newStripeSetIdIn,
               currentUserId,
               sysdate,
               currentUserId,
               sysdate,
               currentUserId,
               null,
               sysdate,
               null);
      commit;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                  routineNameIn => 'changeRuleStripe',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
    end changeRuleStripe;
*/
  procedure changeUsage(ruleIdIn in integer,
                        applicationIdIn in integer,
                        priorityIn in varchar2,
                        categoryIn in varchar2,
                        parentVersionStartDateIn in date,
                        oldStartDateIn in date,
                        oldEndDateIn in date default null,
                        startDateIn in date default null,
                        endDateIn in date default null,
                        finalizeIn in boolean default false,
                        processingDateIn in date default null) as
    cursor startDateCursor is
      select start_date
        from ame_rules
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
           nvl(end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < start_date and
           start_date < nvl(end_date,start_date + ame_util.oneSecond)))
        for update;
    cursor usageDataCursor is
      select rule_id
        from ame_rule_usages
        where
          item_id = applicationIdIn and
          rule_id = ruleIdIn and
          start_date = oldStartDateIn and
          nvl(end_date, sysdate) = nvl(oldEndDateIn, sysdate)
        for update;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    invalidDateException exception;
    invalidPriorityException exception;
    newUsageResult boolean;
    endDate date;
    objectVersionNoDataException exception;
    processingDate date;
    newStartDate date;
    newEndDate date;
    ruleId integer;
    startDate date;
    startDateException exception;
    startDateException1 exception;
    usageStartDate date;
    usageEndDate date;
    begin
      if(finalizeIn) then
        open startDateCursor;
          fetch startDateCursor into startDate;
          if startDateCursor%notfound then
            raise objectVersionNoDataException;
          end if;
          if(parentVersionStartDateIn <> startDate) then
            raise ame_util.objectVersionException;
          end if;
          open usageDataCursor;
            fetch usageDataCursor into ruleId;
            if usageDataCursor%notfound then
              raise ame_util.objectVersionException;
            end if;
      end if;
      if processingDateIn is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      if (trunc(startDateIn) <> trunc(oldStartDateIn) and
                (startDateIn) < trunc(processingDate)) then
        raise startDateException;
      end if;
      if (startDateIn) >= (endDateIn)  then
        raise startDateException1;
      end if;
      if not(ame_util.isANumber(stringIn => priorityIn,
                                allowDecimalsIn => false,
                                allowNegativesIn => false)) then
        raise invalidPriorityException;
      end if;
      if(trunc(startDateIn) > trunc(processingDate)) then
        newStartDate := trunc(startDateIn);
      else
        newStartDate := processingDate;
      end if;
      endDate := processingDate;
      currentUserId := ame_util.getCurrentUserId;
      update ame_rule_usages
        set
          last_updated_by = currentUserId,
          last_update_date = endDate,
          last_update_login = currentUserId,
          end_date = endDate
        where
          rule_id = ruleIdIn and
          item_id = applicationIdIn and
          start_date = oldStartDateIn and
          nvl(end_date, endDate) = nvl(oldEndDateIn, endDate) ;
      newUsageResult := newRuleUsage(itemIdIn => applicationIdIn,
                                     ruleIdIn => ruleIdIn,
                                     startDateIn => newStartDate,
                                     endDateIn => endDateIn,
                                     priorityIn => priorityIn,
                                     categoryIn => categoryIn,
                                     finalizeIn => false,
                                     parentVersionStartDateIn => parentVersionStartDateIn,
                                     processingDateIn => processingDateIn,
                                     updateParentObjectIn => true);
      if(finalizeIn) then
        close usageDataCursor;
        close startDateCursor;
        commit;
      end if;
      exception
        when ame_util.objectVersionException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'changeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
         when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(usageDataCursor%isOpen) then
            close usageDataCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'changeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when invalidPriorityException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400288_RUL_PRI_NOT_VAL');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'changeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when startDateException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
          messageNameIn => 'AME_400213_RUL_STRT_GRTR_CUR');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'changeUsage',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
      when startDateException1 then
        rollback;
        errorCode := -20001;
        errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
          messageNameIn => 'AME_400214_RUL_STRT_LESS_END');
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'changeUsage',
                                  exceptionNumberIn => errorCode,
                                  exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'changeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
    end changeUsage;
/*
AME_STRIPING
  procedure dropRuleStripeSet(ruleIdIn in integer,
                              applicationIdIn in integer,
                              finalizeIn in boolean default false) as
    stripeSetId integer;
    begin
      begin
        select stripe_set_id
          into stripeSetId
          from ame_rule_stripe_sets
          where
            rule_id = ruleIdIn and
            stripe_set_id in
              (select stripe_set_id
                from ame_stripe_sets
                where
                  application_id = applicationIdIn and
                  (start_date <= sysdate and
                   (end_date is null or sysdate < end_date))) and
            (start_date <= sysdate and
            (end_date is null or sysdate < end_date));
          exception
            when no_data_found then
              return;
        end;
      update ame_rule_stripe_sets
        set end_date = sysdate
        where
          rule_id = ruleIdIn and
          stripe_set_id = stripeSetId and
          (start_date <= sysdate and
           (end_date is null or sysdate < end_date));
      ame_admin_pkg.checkStripeSetUsage(stripeSetIdIn => stripeSetId,
                                        finalizeIn => false);
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'dropRuleStripeSet',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
    end dropRuleStripeSet;
*/
/*
AME_STRIPING
  procedure getAppRuleList(applicationIdIn in integer,
                           stripeSetIdIn in integer default null,
                           isStripingIn in varchar2,
                           ruleListOut out nocopy ame_rule_pkg.ruleActionRecordTable) as
*/
  procedure getActionIds(ruleIdIn in integer,
                         actionIdListOut out nocopy ame_util.idList) as
    cursor actionCursor(ruleIdIn in integer) is
     	select
        ame_action_usages.action_id
       	from
          ame_action_usages
        where
          rule_id = ruleIdIn and
          ((sysdate between ame_action_usages.start_date and
              nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_action_usages.start_date and
              ame_action_usages.start_date < nvl(ame_action_usages.end_date,
                            ame_action_usages.start_date + ame_util.oneSecond)));
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
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getActionIds',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        actionIdListOut := ame_util.emptyIdList;
        raise;
    end getActionIds;
  procedure getActions(ruleIdIn in integer,
                       actionIdsOut out nocopy ame_util.idList,
                       actionDescriptionsOut out nocopy ame_util.longStringList) as
    cursor actionsCursor(ruleIdIn in integer) is
      select ame_actions.action_id,
             ame_actions.parameter,
             ame_actions.parameter_two,
             ame_action_types.name,
             ame_action_types.dynamic_description,
             ame_action_types.description_query
        from ame_actions,
             ame_action_types,
             ame_action_usages
        where
          ame_actions.action_type_id = ame_action_types.action_type_id and
          ame_actions.action_id = ame_action_usages.action_id and
          ame_action_usages.rule_id = ruleIdIn and
          sysdate between ame_actions.start_date and
            nvl(ame_actions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          ((sysdate between ame_action_usages.start_date and
              nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_action_usages.start_date and
              ame_action_usages.start_date < nvl(ame_action_usages.end_date,
                            ame_action_usages.start_date + ame_util.oneSecond)))
        order by ame_actions.created_by, ame_actions.description;
    actionId integer;
    tempActionDescription ame_util.stringType;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAction in actionsCursor(ruleIdIn => ruleIdIn) loop
        actionIdsOut(tempIndex) := tempAction.action_id;
        if(tempAction.dynamic_description = ame_util.booleanTrue) then
          begin
            if(instrb(tempAction.description_query, ame_util.actionParameterOne) > 0) then
              if(instrb(tempAction.description_query, ame_util.actionParameterTwo) > 0) then /* both parameters */
                execute immediate tempAction.description_query
                  into tempActionDescription using
                  in tempAction.parameter,
                  in tempAction.parameter_two;
              else /* just parameter_one */
                execute immediate tempAction.description_query into
                  tempActionDescription using
                  in tempAction.parameter;
              end if;
            else
              if(instrb(tempAction.description_query, ame_util.actionParameterTwo) > 0) then /* just paramter_two */
                execute immediate tempAction.description_query
                  into tempActionDescription using
                  in tempAction.parameter_two;
              else /* neither */
                execute immediate tempAction.description_query into
                  tempActionDescription;
              end if;
            end if;
            exception when others then
            tempActionDescription := ame_util.getLabel(ame_util.perFndAppId,'AME_INVALID_DESCRIPTION');
          end;
          actionDescriptionsOut(tempIndex) :=
            tempAction.name || ': ' || tempActionDescription;
        else
          actionDescriptionsOut(tempIndex) :=
            ame_action_pkg.getDescription(actionIdIn => tempAction.action_id);
        end if;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'getActions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          actionIdsOut := ame_util.emptyIdList;
          actionDescriptionsOut := ame_util.emptyLongStringList;
          raise;
    end getActions;
  procedure getActions2(ruleIdIn in integer,
                        actionTypeIdIn in integer,
                        actionIdsOut out nocopy ame_util.stringList,
                        actionDescriptionsOut out nocopy ame_util.stringList) as
    cursor actionsCursor(ruleIdIn in integer) is
      select ame_actions.action_id,
             ame_actions.parameter,
             ame_actions.parameter_two,
             ame_actions.description,
             ame_action_types.dynamic_description,
             ame_action_types.description_query
        from ame_actions,
             ame_action_types
        where
          ame_actions.action_type_id = ame_action_types.action_type_id and
          ame_actions.action_type_id = actionTypeIdIn and
          ame_actions.action_id not in
            (select action_id
               from ame_action_usages
               where
                 rule_id = ruleIdIn and
                 ((sysdate between ame_action_usages.start_date and
                    nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate)) or
                 (sysdate < ame_action_usages.start_date and
                    ame_action_usages.start_date < nvl(ame_action_usages.end_date,
                      ame_action_usages.start_date + ame_util.oneSecond)))) and
          sysdate between ame_actions.start_date and
            nvl(ame_actions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_action_types.start_date and
            nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate)
        order by ame_actions.created_by, ame_actions.description;
    actionId integer;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAction in actionsCursor(ruleIdIn => ruleIdIn) loop
        actionIdsOut(tempIndex) := tempAction.action_id;
        if(tempAction.dynamic_description = ame_util.booleanTrue) then
          begin
            if(instrb(tempAction.description_query, ame_util.actionParameterOne) > 0) then
              if(instrb(tempAction.description_query, ame_util.actionParameterTwo) > 0) then /* both parameters */
                execute immediate tempAction.description_query
                  into actionDescriptionsOut(tempIndex) using
                  in tempAction.parameter,
                  in tempAction.parameter_two;
              else /* just parameter_one */
                execute immediate tempAction.description_query into
                  actionDescriptionsOut(tempIndex) using
                  in tempAction.parameter;
              end if;
            else
              if(instrb(tempAction.description_query, ame_util.actionParameterTwo) > 0) then /* just paramter_two */
                execute immediate tempAction.description_query
                  into actionDescriptionsOut(tempIndex) using
                  in tempAction.parameter_two;
              else /* neither */
                execute immediate tempAction.description_query into
                  actionDescriptionsOut(tempIndex);
              end if;
            end if;
            exception when others then
            actionDescriptionsOut(tempIndex) :=  ame_util.getLabel(ame_util.perFndAppId,'AME_INVALID_DESCRIPTION');
          end;
        else
          actionDescriptionsOut(tempIndex) := tempAction.description;
        end if;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'getActions2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          actionIdsOut := ame_util.emptyStringList;
          actionDescriptionsOut := ame_util.emptyStringList;
          raise;
    end getActions2;
  procedure getAppRuleList(applicationIdIn in integer,
                           ruleListOut out nocopy ame_rule_pkg.ruleActionRecordTable) as
    cursor ruleCursor(applicationIdIn in varchar2) is
      select
        r.rule_id rule_id,
        r.rule_key rule_key,
        r.rule_type rule_type,
        r.description rule_description,
        u.start_date usage_start_date,
        u.end_date usage_end_date,
        u.priority priority,
        r.item_class_id,
        u.approver_category
	      from
          ame_rule_usages u,
          ame_rules r,
          ame_item_class_usages i
        where
          u.rule_id = r.rule_id and
          r.item_class_id = i.item_class_id and
          u.item_id = applicationIdIn and
          i.application_id = applicationIdIn and
             ((sysdate between r.start_date and
                 nvl(r.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < r.start_date and
                 r.start_date < nvl(r.end_date,
                               r.start_date + ame_util.oneSecond))) and
             ((sysdate between u.start_date and
                 nvl(u.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < u.start_date and
                 u.start_date < nvl(u.end_date,
                           u.start_date + ame_util.oneSecond))) and
             (i.start_date <= sysdate and
             (i.end_date is null or sysdate < i.end_date))
        order by i.item_class_order_number, rule_type, rule_description, usage_start_date;
    cursor ruleCursor2(applicationIdIn in varchar2) is
      select
        r.rule_id rule_id,
        r.rule_key rule_key,
        r.rule_type rule_type,
        r.description rule_description,
        u.start_date usage_start_date,
        u.end_date usage_end_date,
        u.priority priority,
        null item_class_id,
        u.approver_category
	      from
          ame_rule_usages u,
          ame_rules r
        where
          u.rule_id = r.rule_id and
          r.rule_type in (ame_util.substitutionRuleType, ame_util.listModRuleType) and
          u.item_id = applicationIdIn and
             ((sysdate between r.start_date and
                 nvl(r.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < r.start_date and
                 r.start_date < nvl(r.end_date,
                               r.start_date + ame_util.oneSecond))) and
             ((sysdate between u.start_date and
                 nvl(u.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < u.start_date and
                 u.start_date < nvl(u.end_date,
                           u.start_date + ame_util.oneSecond)))
        order by rule_type, rule_description, usage_start_date;
    tempRuleActionRecord ruleActionRecord;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempRule in ruleCursor(applicationIdIn => applicationIdIn) loop
        tempRuleActionRecord.rule_id := tempRule.rule_id;
        tempRuleActionRecord.rule_key:= tempRule.rule_key;
        tempRuleActionRecord.rule_type := tempRule.rule_type;
        tempRuleActionRecord.rule_description := tempRule.rule_description;
        tempRuleActionRecord.usage_start_date := tempRule.usage_start_date;
        tempRuleActionRecord.usage_end_date := tempRule.usage_end_date;
        tempRuleActionRecord.priority := tempRule.priority;
        tempRuleActionRecord.item_class_id := tempRule.item_class_id;
        tempRuleActionRecord.approver_category := tempRule.approver_category;
        ruleListOut(tempIndex) := tempRuleActionRecord;
        tempIndex := tempIndex + 1;
      end loop;
      for tempRule in ruleCursor2(applicationIdIn => applicationIdIn) loop
        tempRuleActionRecord.rule_id := tempRule.rule_id;
        tempRuleActionRecord.rule_key:= tempRule.rule_key;
        tempRuleActionRecord.rule_type := tempRule.rule_type;
        tempRuleActionRecord.rule_description := tempRule.rule_description;
        tempRuleActionRecord.usage_start_date := tempRule.usage_start_date;
        tempRuleActionRecord.usage_end_date := tempRule.usage_end_date;
        tempRuleActionRecord.priority := tempRule.priority;
        tempRuleActionRecord.item_class_id := null;
        tempRuleActionRecord.approver_category := tempRule.approver_category;
        ruleListOut(tempIndex) := tempRuleActionRecord;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'getAppRuleList',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        ruleListOut := ame_rule_pkg.emptyRuleActionRecordTable;
        raise;
    end getAppRuleList;
  procedure getAppRuleList2(applicationIdIn in integer,
                            applicationIdToShareIn in integer,
                            ruleIdListOut out nocopy ame_util.stringList,
                            ruleDescriptionListOut out nocopy ame_util.stringList) as
    cursor ruleCursor(applicationIdToShareIn in varchar2,
                      itemClassIdIn in integer) is
      select
        distinct(r.rule_id) rule_id,
        r.description
        from
          ame_rules r,
          ame_rule_usages u
        where
          u.rule_id = r.rule_id and
          (r.item_class_id is null or
          r.item_class_id = itemClassIdIn) and
          u.item_id = applicationIdToShareIn and
             ((sysdate between r.start_date and
                 nvl(r.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < r.start_date and
                 r.start_date < nvl(r.end_date,
                               r.start_date + ame_util.oneSecond))) and
             ((sysdate between u.start_date and
                 nvl(u.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < u.start_date and
                 u.start_date < nvl(u.end_date,
                           u.start_date + ame_util.oneSecond)))
        order by r.description;
    itemClassIds ame_util.idList;
    tempIndex integer;
    begin
      ame_admin_pkg.getTransTypeItemClassIds(applicationIdIn => applicationIdIn,
                                             itemClassIdsOut => itemClassIds);
      tempIndex := 1;
      for i in 1 .. itemClassIds.count loop
        for tempRule in ruleCursor(applicationIdToShareIn => applicationIdToShareIn,
                                   itemClassIdIn => itemClassIds(i)) loop
          ruleIdListOut(tempIndex) := tempRule.rule_id;
          ruleDescriptionListOut(tempIndex) := tempRule.description;
          tempIndex := tempIndex + 1;
          end loop;
      end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                  routineNameIn => 'getAppRuleList2',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        ruleIdListOut := ame_util.emptyStringList;
        ruleDescriptionListOut := ame_util.emptyStringList;
        raise;
    end getAppRuleList2;
  procedure getConditionIds(ruleIdIn in integer,
                            conditionIdListOut out nocopy ame_util.idList) as
    cursor conditionCursor(ruleIdIn in integer) is
     	select
        ame_conditions.condition_id condition_id,
        ame_conditions.condition_type condition_type
       	from
          ame_conditions,
          ame_condition_usages
        where
          ame_conditions.condition_id = ame_condition_usages.condition_id and
          ame_condition_usages.rule_id = ruleIdIn and
          (ame_conditions.start_date <= sysdate and
          (ame_conditions.end_date is null or sysdate < ame_conditions.end_date)) and
             ((sysdate between ame_condition_usages.start_date and
                 nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < ame_condition_usages.start_date and
                 ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
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
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getConditionIds',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        conditionIdListOut := ame_util.emptyIdList;
        raise;
    end getConditionIds;
  procedure getConditions(ruleIdIn in integer,
                          conditionListOut out nocopy ame_util.stringList,
                          conditionIdListOut out nocopy ame_util.idList) as
    conditionIdList ame_util.idList;
    tempConditionType ame_conditions.condition_type%type;
    tempDescription varchar2(200);
    upperLimit integer;
    ruleType ame_rules.rule_type%type;
    begin
      ruleType := getRuleType(ruleIdIn => ruleIdIn);
      getConditionIds(ruleIdIn => ruleIdIn,
                      conditionIdListOut => conditionIdList);
      upperLimit := conditionIdList.count;
      if(upperLimit = 0) then
        conditionListOut :=  ame_util.emptyStringList;
        conditionIdListOut := ame_util.emptyIdList;
      else
        for tempIndex in 1..upperLimit loop
          tempConditionType := ame_condition_pkg.getType(conditionIdIn => conditionIdList(tempIndex));
          if(tempConditionType = ame_util.exceptionConditionType) then
            tempDescription := 'Exception:  ' ||
              ame_condition_pkg.getDescription(conditionIdIn => conditionIdList(tempIndex));
          elsif(tempConditionType = ame_util.listModConditionType) then
            tempDescription := 'List Modification:  ' ||
              ame_condition_pkg.getDescription(conditionIdIn => conditionIdList(tempIndex));
          else
            tempDescription :=
              ame_condition_pkg.getDescription(conditionIdIn => conditionIdList(tempIndex));
          end if;
          conditionListOut(tempIndex) := substrb(tempDescription, 1, 100);
          conditionIdListOut(tempIndex) := conditionIdList(tempIndex);
        end loop;
      end if;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getConditions',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        conditionListOut := ame_util.emptyStringList;
        conditionIdListOut := ame_util.emptyIdList;
        raise;
    end getConditions;
  procedure getDetailUrls(ruleIdsIn in ame_util.idList,
                          applicationIdIn in integer,
                          usageEndDatesIn in ame_util.dateList default ame_util.emptyDateList,
                          usageStartDatesIn in ame_util.dateList,
                          detailUrlsOut out nocopy ame_util.longStringList) as
    ruleIdCount integer;
    usageStartDate ame_util.stringType;
    begin
      ruleIdCount := ruleIdsIn.count;
      for i in 1..ruleIdCount loop
        detailUrlsOut(i) := (ame_util.getPlsqlDadPath ||
                             'ame_rules_ui.getDetails?ruleIdIn=' ||
                             ruleIdsIn(i) ||
                             '&applicationIdIn=' ||
                             applicationIdIn ||
                             '&displayUsagesIn=' ||
                             ame_util.booleanTrue ||
                             '&usageEndDateIn=' ||
                             ame_util.versionDateToString(dateIn => usageEndDatesIn(i)) ||
                             '&usageStartDateIn=' ||
                             ame_util.versionDateToString(dateIn => usageStartDatesIn(i)));
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getDetailUrls',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          detailUrlsOut := ame_util.emptyLongStringList;
          raise;
    end getDetailUrls;
  procedure getOrdinaryAttributeIds(ruleIdIn in integer,
                                    attributeIdListOut out nocopy ame_util.idList) as
    cursor attributeCursor(ruleIdIn in integer) is
      select ame_conditions.attribute_id attribute_id
        from
          ame_conditions,
          ame_condition_usages
        where
          ame_conditions.condition_type = ame_util.ordinaryConditionType and
          ame_conditions.condition_id = ame_condition_usages.condition_id and
          ame_condition_usages.rule_id = ruleIdIn and
          (ame_conditions.start_date <= sysdate and
          (ame_conditions.end_date is null or sysdate < ame_conditions.end_date)) and
             ((sysdate between ame_condition_usages.start_date and
                 nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < ame_condition_usages.start_date and
                 ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,ame_condition_usages.start_date + ame_util.oneSecond)))
           order by attribute_id;
      tempIndex integer;
      begin
        tempIndex := 1;
        for tempAttribute in attributeCursor(ruleIdIn => ruleIdIn) loop
          attributeIdListOut(tempIndex) := tempAttribute.attribute_id;
          tempIndex := tempIndex + 1;
        end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getOrdinaryAttributeIds',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          attributeIdListOut := ame_util.emptyIdList;
          raise;
    end getOrdinaryAttributeIds;
  procedure getRequiredAttributes(ruleIdIn in integer,
                                  attributeIdsOut out nocopy ame_util.idList) as
    cursor attributeCursor(ruleIdIn in integer) is
      select ame_conditions.attribute_id attribute_id
        from
          ame_conditions,
          ame_condition_usages
        where
          ame_conditions.condition_type in (ame_util.ordinaryConditionType, ame_util.exceptionConditionType) and
          ame_condition_usages.rule_id = ruleIdIn and
          ame_condition_usages.condition_id = ame_conditions.condition_id and
          (ame_conditions.start_date <= sysdate and
          (ame_conditions.end_date is null or sysdate < ame_conditions.end_date)) and
          ((sysdate between ame_condition_usages.start_date and
           nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_condition_usages.start_date and
           ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
                        ame_condition_usages.start_date + ame_util.oneSecond)))
      union
      select ame_mandatory_attributes.attribute_id attribute_id
        from
          ame_mandatory_attributes,
          ame_action_usages,
          ame_actions
        where
          ame_mandatory_attributes.action_type_id = ame_actions.action_type_id and
          ame_actions.action_id = ame_action_usages.action_id and
          ame_action_usages.rule_id = ruleIdIn and
          (ame_mandatory_attributes.start_date <= sysdate and
          (ame_mandatory_attributes.end_date is null or sysdate < ame_mandatory_attributes.end_date)) and
          ((sysdate between ame_action_usages.start_date and
              nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_action_usages.start_date and
              ame_action_usages.start_date < nvl(ame_action_usages.end_date,
                            ame_action_usages.start_date + ame_util.oneSecond))) and
          (ame_actions.start_date <= sysdate and
          (ame_actions.end_date is null or sysdate < ame_actions.end_date));
    tempIndex integer;
    begin
      tempIndex := 0;
      for tempAttribute in attributeCursor(ruleIdIn => ruleIdIn) loop
        tempIndex := tempIndex + 1;
        attributeIdsOut(tempIndex) := tempAttribute.attribute_id;
      end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                  routineNameIn => 'getRequiredAttributes',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        attributeIdsOut := ame_util.emptyIdList;
        raise;
    end getRequiredAttributes;
  procedure getRuleAppUsages(ruleIdIn in integer,
                             transactionTypeDescriptionsOut out nocopy ame_util.stringList) as
    cursor getAppUsagesCursor(ruleIdIn in integer) is
      select application_id,
             application_name
        from ame_rule_usages,
             ame_calling_apps
        where
             ame_rule_usages.item_id = ame_calling_apps.application_id and
             ame_rule_usages.rule_id = ruleIdIn and
             (ame_rule_usages.start_date <= sysdate and
             (ame_rule_usages.end_date is null or sysdate < ame_rule_usages.end_date)) and
             (ame_calling_apps.start_date <= sysdate and
             (ame_calling_apps.end_date is null or sysdate < ame_calling_apps.end_date))
             order by application_name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for getAppUsagesRec in getAppUsagesCursor(ruleIdIn => ruleIdIn) loop
        transactionTypeDescriptionsOut(tempIndex) :=
          getAppUsagesRec.application_name;
        tempIndex := tempIndex + 1;
      end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getRuleAppUsages',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        transactionTypeDescriptionsOut := ame_util.emptyStringList;
        raise;
    end getRuleAppUsages;
  procedure getRuleUsages(ruleIdIn in integer,
                          applicationIdsOut out nocopy ame_util.idList,
                          prioritiesOut out nocopy ame_util.stringList) as
    cursor getRuleUsageCursor(ruleIdIn in integer) is
      select item_id,
             priority
       from ame_rule_usages
       where rule_id = ruleIdIn and
         ((sysdate between start_date and
         nvl(end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < start_date and
         start_date < nvl(end_date, start_date + ame_util.oneSecond)));
    tempIndex integer;
    begin
      tempIndex := 1;
      for getRuleUsageRec in getRuleUsageCursor(ruleIdIn => ruleIdIn) loop
        applicationIdsOut(tempIndex) := getRuleUsageRec.item_id;
        prioritiesOut(tempIndex) := getRuleUsageRec.priority;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getRuleUsages',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          applicationIdsOut := ame_util.emptyIdList;
          prioritiesOut := ame_util.emptyStringList;
          raise;
    end getRuleUsages;
/*
AME_STRIPING
  procedure getStripeSetRules(stripeSetIdIn in integer,
                              ruleIdsOut out nocopy ame_util.idList) is
    cursor getRuleIdCursor(stripeSetIdIn in integer) is
      select rule_id
        from ame_rule_stripe_sets
        where
          stripe_set_id = stripeSetIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
    begin
      open getRuleIdCursor(stripeSetIdIn => stripeSetIdIn);
        fetch getRuleIdCursor bulk collect
          into ruleIdsOut;
      close getRuleIdCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'getStripeSetRules',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          ruleIdsOut := ame_util.emptyIdList;
          raise;
    end getStripeSetRules;
*/
/*
AME_STRIPING
  procedure getStripeSets(ruleIdIn in integer,
                          effectiveRuleDateIn in date default sysdate,
                          stripeSetIdsOut out nocopy ame_util.idList) is
    cursor stripeSetCursor(ruleIdIn in integer,
                           effectiveRuleDateIn in date) is
      select stripe_set_id
        from ame_rule_stripe_sets
        where
          rule_id = ruleIdIn and
          effectiveRuleDateIn between
            (start_date + ame_util.oneSecond) and
            nvl(end_date - ame_util.oneSecond, effectiveRuleDateIn);
    begin
      open stripeSetCursor(ruleIdIn => ruleIdIn,
                           effectiveRuleDateIn => effectiveRuleDateIn);
        fetch stripeSetCursor bulk collect
          into stripeSetIdsOut;
      close stripeSetCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'getStripeSets',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          stripeSetIdsOut := ame_util.emptyIdList;
          raise;
    end getStripeSets;
*/
  procedure getTransTypeItemClasses(applicationIdIn in integer,
                                    itemClassIdIn in integer,
                                    itemClassIdsOut out nocopy ame_util.stringList,
                                    itemClassNamesOut out nocopy ame_util.stringList) as
    cursor itemClassesCursor(itemClassIdIn in integer) is
      select to_char(ame_item_classes.item_class_id),
             name
        from ame_item_classes,
             ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_item_classes.item_class_id <> itemClassIdIn and
          sysdate between ame_item_classes.start_date and
            nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_item_class_usages.start_date and
            nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate)
          order by ame_item_classes.item_class_id;
    begin
      open itemClassesCursor(itemClassIdIn => itemClassIdIn);
      fetch itemClassesCursor bulk collect
        into itemClassIdsOut,
             itemClassNamesOut;
      close itemClassesCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'getTransTypeItemClasses',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          itemClassIdsOut := ame_util.emptyStringList;
          itemClassNamesOut := ame_util.emptyStringList;
          raise;
    end getTransTypeItemClasses;
  procedure getTypedConditions(ruleIdIn in integer,
                               conditionTypeIn in varchar2,
                               conditionIdsOut out nocopy ame_util.idList) as
  cursor conditionCursor(ruleIdIn in integer,
                         conditionTypeIn in varchar2) is
    select
        ame_conditions.condition_id condition_id
    from
        ame_conditions,
        ame_condition_usages
    where
        ame_conditions.condition_type = conditionTypeIn and
        ame_condition_usages.rule_id = ruleIdIn and
        ame_condition_usages.condition_id = ame_conditions.condition_id and
        (ame_conditions.start_date <= sysdate and
        (ame_conditions.end_date is null or sysdate < ame_conditions.end_date)) and
        ((sysdate between ame_condition_usages.start_date and
         nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < ame_condition_usages.start_date and
         ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
                      ame_condition_usages.start_date + ame_util.oneSecond)))
          order by condition_type;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempCondition in conditionCursor(ruleIdIn => ruleIdIn,
                                       conditionTypeIn => conditionTypeIn) loop
        conditionIdsOut(tempIndex) := tempCondition.condition_id;
        tempIndex := tempIndex + 1;
      end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getTypedConditions',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        conditionIdsOut := ame_util.emptyIdList;
        raise;
    end getTypedConditions;
  procedure getTypedConditions2(ruleIdIn in integer,
                               conditionTypeIn in varchar2,
                               conditionListOut out nocopy ame_util.longStringList,
                               conditionIdsOut out nocopy ame_util.idList) as
  cursor conditionCursor(ruleIdIn in integer,
                         conditionTypeIn in varchar2) is
    select
        ame_conditions.condition_id condition_id
    from
        ame_conditions,
        ame_condition_usages
    where
        ame_conditions.condition_type = conditionTypeIn and
        ame_condition_usages.rule_id = ruleIdIn and
        ame_condition_usages.condition_id = ame_conditions.condition_id and
        (ame_conditions.start_date <= sysdate and
        (ame_conditions.end_date is null or sysdate < ame_conditions.end_date)) and
        ((sysdate between ame_condition_usages.start_date and
         nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < ame_condition_usages.start_date and
         ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
                      ame_condition_usages.start_date + ame_util.oneSecond)))
          order by condition_type;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempCondition in conditionCursor(ruleIdIn => ruleIdIn,
                                       conditionTypeIn => conditionTypeIn) loop
        conditionIdsOut(tempIndex) := tempCondition.condition_id;
        conditionListOut(tempIndex) :=
          ame_condition_pkg.getDescription(conditionIdIn => tempCondition.condition_id);
        tempIndex := tempIndex + 1;
      end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                  routineNamein => 'getTypedConditions2',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        conditionIdsOut := ame_util.emptyIdList;
        raise;
    end getTypedConditions2;
  procedure remove(ruleIdIn in integer,
                   finalizeIn in boolean default true,
                   processingDateIn in date default null) as
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    inUseException exception;
    conditionIdList ame_util.idList;
    conditionCount integer;
    endDate  date;
    processingDate date;
    begin
      if(isInUse(ruleIdIn)) then
        raise inUseException;
      end if;
      /* check to see if processingDate has been initialized */
      if processingDateIn  is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      endDate := processingDate;
      ame_rule_pkg.getConditionIds(ruleIdIn => ruleIdIn,
                                   conditionIdListOut => conditionIdList);
      conditionCount := conditionIdList.count;
      for tempIndex in 1..conditionCount loop
        ame_condition_pkg.removeConditionUsage(ruleIdIn => ruleIdIn,
                                               conditionIdIn => conditionIdList(tempIndex),
                                               finalizeIn => finalizeIn);
      end loop;
      currentUserId := ame_util.getCurrentUserId;
      update ame_rules
        set
          last_updated_by = currentUserId,
          last_update_date = sysdate,
          last_update_login = currentUserId,
          end_date = endDate
        where
          rule_id = ruleIdIn and
          ((sysdate between start_date and
          nvl(end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < start_date and
          start_date < nvl(end_date, start_date + ame_util.oneSecond)));
      if finalizeIn then
        commit;
      end if;
      exception
        when inUseException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400216_RUL_IN_USE');
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'remove',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'remove',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end remove;
/*
AME_STRIPING
  procedure removeRuleStripeSet(stripeSetIdsIn in ame_util.idList default ame_util.emptyIdList,
                                ruleIdIn in integer default null,
                                finalizeIn in boolean default false) as
    currentUserId integer;
    stripeSetCount integer;
    begin
      currentUserId := ame_util.getCurrentUserId;
      stripeSetCount := stripeSetIdsIn.count;
      if(stripeSetCount > 0) then
        for i in 1..stripeSetCount loop
          update ame_rule_stripe_sets
            set
              last_updated_by = currentUserId,
              last_update_date = sysdate,
              last_update_login = currentUserId,
              end_date = sysdate
            where
              stripe_set_id = stripeSetIdsIn(i) and
              (end_date is null or sysdate < end_date);
        end loop;
      else
        update ame_rule_stripe_sets
            set
              last_updated_by = currentUserId,
              last_update_date = sysdate,
              last_update_login = currentUserId,
              end_date = sysdate
            where
              rule_id = ruleIdIn and
              (end_date is null or sysdate < end_date);
      end if;
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNamein => 'ame_rule_pkg',
                                    routineNamein => 'removeRuleStripeSet',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end removeRuleStripeSet;
*/
  procedure removeUsage(ruleIdIn in integer,
                        itemIdIn in integer,
                        usageStartDateIn in date,
                        parentVersionStartDateIn in date,
                        finalizeIn in boolean default true,
                        processingDateIn in date default null) as
    cursor startDateCursor is
      select start_date
        from ame_rules
        where
          rule_id = ruleIdIn and
             ((sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < start_date and
               start_date < nvl(end_date, start_date + ame_util.oneSecond)))
        for update;
    actionCount integer;
    actionIdList ame_util.idList;
    attributeIdList ame_util.idList;
    conditionCount integer;
    conditionIdList ame_util.idList;
    currentUserId integer;
    description ame_rules.description%type;
    newRuleEndDate ame_rules.end_date%type;
    endDate date;
    processingDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    itemClassId integer;
    objectVersionNoDataException exception;
    ruleId ame_rules.rule_id%type;
    ruleKey ame_rules.rule_key%type;
    ruleType ame_rules.rule_type%type;
    startDate date;
    begin
      /* check to see if processingDate has been initialized */
      if processingDateIn  is null then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      endDate := processingDate;
      open startDateCursor;
        fetch startDateCursor into startDate;
        if startDateCursor%notfound then
          raise objectVersionNoDataException;
        end if;
        if parentVersionStartDateIn <> startDate then
          close startDateCursor;
          raise ame_util.objectVersionException;
        end if;
        getRequiredAttributes(ruleIdIn => ruleIdIn,
                              attributeIdsOut => attributeIdList);
        currentUserId := ame_util.getCurrentUserId;
        update ame_rule_usages
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = endDate
            where
              rule_id = ruleIdIn and
              item_id = itemIdIn and
              start_date = usageStartDateIn and
              start_date < nvl(end_date, start_date + ame_util.onesecond);
        changeAttributeUseCounts2(attributeIdsIn => attributeIdList,
                                  applicationIdIn => itemIdIn,
                                  finalizeIn => false);
        ruleKey := getRuleKey(ruleIdIn => ruleIdIn);
        ruleType := getRuleType(ruleIdIn => ruleIdIn);
        description := getDescription(ruleIdIn => ruleIdIn);
        itemClassId := getItemClassId(ruleIdIn => ruleIdIn);
        newRuleEndDate := getNewRuleEndDate(ruleIdIn => ruleIdIn,
                                   processingDateIn => processingDate);
        getConditionIds(ruleIdIn => ruleIdIn,
                        conditionIdListOut => conditionIdList);
        conditionCount := conditionIdList.count;
        getActionIds(ruleIdIn => ruleIdIn,
                     actionIdListOut => actionIdList);
        actionCount := actionIdList.count;
        if conditionCount > 0 then
          for i in 1..conditionCount loop
            update ame_condition_usages
              set
                last_updated_by = currentUserId,
                last_update_date = processingDate,
                last_update_login = currentUserId,
                end_date = processingDate
              where
                rule_id = ruleIdIn and
                condition_id = conditionIdList(i) and
               ((sysdate between start_date and
                   nvl(end_date - ame_util.oneSecond, sysdate)) or
                 (sysdate < start_date and
                    start_date < nvl(end_date, start_date + ame_util.oneSecond)));
          end loop;
        end if;
        if actionCount > 0 then
          for i in 1..actionCount loop
            update ame_action_usages
              set
                last_updated_by = currentUserId,
                last_update_date = processingDate,
                last_update_login = currentUserId,
                end_date = processingDate
              where
                rule_id = ruleIdIn and
                action_id = actionIdList(i) and
               ((sysdate between start_date and
                   nvl(end_date - ame_util.oneSecond, sysdate)) or
                (sysdate < start_date and
                  start_date < nvl(end_date, start_date + ame_util.oneSecond)));
          end loop;
        end if;
        if not isInUse(ruleIdIn) then
          remove(ruleIdIn => ruleIdIn,
                 finalizeIn => false,
                 processingDateIn => processingDateIn);
/*
AME_STRIPING
              if(ame_admin_pkg.isStripingOn(applicationIdIn => itemIdIn)) then
                dropRuleStripeSet(ruleIdIn => ruleIdIn,
                                  applicationIdIn => itemIdIn);
                ame_admin_pkg.updateStripingAttUseCount(applicationIdIn => itemIdIn);
              end if;
*/
        else
          update ame_rules
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = endDate
            where
              rule_id = ruleIdIn and
             ((processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate)) or
              (processingDate < start_date and
               start_date < nvl(end_date, start_date + ame_util.oneSecond)));
          ruleId := new(applicationIdIn => itemIdIn,
                        typeIn => ruleType,
                        conditionIdsIn => conditionIdList,
                        actionIdsIn => actionIdList,
                        ruleKeyIn => ruleKey,
                        descriptionIn => description,
                        itemClassIdIn => itemClassId,
                        startDateIn => processingDate,
                        endDateIn => newRuleEndDate,
                        ruleIdIn => ruleIdIn,
                        finalizeIn => false,
                        processingDateIn => processingDate);
        end if;
      close startDateCursor;
      if(finalizeIn) then
        commit;
      end if;
			exception
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'removeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'removeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'removeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
    end removeUsage;
/*
AME_STRIPING
  procedure updateRuleStripeSets(applicationIdIn in integer,
                                 ruleIdIn in integer,
                                 conditionIdsIn in ame_util.idList,
                                 finalizeIn in boolean default false) as
*/
    /* This procedure updates the rule's stripe set in each transaction type that uses striping. */
/*
    cursor applicationIdCursor is
      select application_id
        from ame_calling_apps
        where
          start_date <= sysdate and
          (end_date is null or sysdate < end_date);
    applicationIds ame_util.idList;
    attributeIds ame_util.idList;
    newAttributeCount integer;
    stringValues ame_util.longestStringList;
    stripingAttributeIds ame_util.idList;
    stripingAttributeValues ame_util.stringList;
    stripingAttributeCount integer;
    equalityCondStringValues ame_util.stringList;
    stripeSetIds ame_util.idList;
    tempIndex integer;
    tempStripeSetId integer;
    begin
      open applicationIdCursor;
      fetch applicationIdCursor bulk collect into applicationIds;
      close applicationIdCursor;
*/
      /*
        Fetch attribute IDs corresponding to the ordinary equality conditions on string attributes
        (possible striping conditions).
      */
      /* tempIndex := 0; pre-increment */
/*
      for i in 1 .. conditionIdsIn.count loop
        if(ame_condition_pkg.getConditionType(conditionIdIn => conditionIdsIn(i)) = ame_util.ordinaryConditionType and
           ame_condition_pkg.getAttributeType(conditionIdIn => conditionIdsIn(i)) = ame_util.stringAttributeType) then
          ame_condition_pkg.getStringValueList(conditionIdIn => conditionIdsIn(i),
                                               stringValueListOut => stringValues);
          if(stringValues.count = 1) then */ /* equality condition, and so possible striping condition */
/*
            tempIndex := tempIndex + 1;
            attributeIds(tempIndex) := ame_condition_pkg.getAttributeId(conditionIdIn => conditionIdsIn(i));
            equalityCondStringValues(tempIndex) := stringValues(1);
          end if;
        end if;
      end loop;
      for i in 1 .. applicationIds.count loop
        if(ame_admin_pkg.isStripingOn(applicationIdIn => applicationIdIn)) then
          ame_admin_pkg.getStripingAttributeIds(applicationIdIn => applicationIdIn,
                                                stripingAttributeIdsOut => stripingAttributeIds);
          stripingAttributeCount := stripingAttributeIds.count; */
          /* Initialize the striping-attribute values to the wildcard. */
/*
          for j in 1 .. stripingAttributeCount loop
            stripingAttributeValues(j) := ame_util.stripeWildcard;
          end loop;
*/
          /* Initialize the remaining columns to null. */
/*
          for j in stripingAttributeCount + 1 .. 5 loop
            stripingAttributeValues(j) := null;
          end loop;
*/
          /*
            Find the rule's striping conditions for the ith transaction type, and populate
            stripingAttributeValues with the corresponding string values.
          */
/*
          for j in 1 .. attributeIds.count loop
            for k in 1 .. stripingAttributeCount loop
              if(stripingAttributeIds(k) = attributeIds(j)) then */ /* striping attribute */
/*
                  stripingAttributeValues(k) := equalityCondStringValues(j);
                  exit; */ /* at most one striping condition per striping attribute */
/*
              end if;
            end loop;
          end loop;
*/
          /* Check to see if rule was just created. (If just created, the rule
             will not have a stripe set.) */
            /* Rule is not new, so drop the rule from its old stripe set. */
/*
          dropRuleStripeSet(ruleIdIn => ruleIdIn,
                            applicationIdIn => applicationIdIn);
*/
          /* Add the rule to its new stripe set, creating that stripe set if needed. */
/*
          tempStripeSetId := ame_admin_pkg.getStripeSetId(applicationIdIn => applicationIdIn,
                                                          attributeValuesIn => stripingAttributeValues);
          if(tempStripeSetId is null) then
            tempStripeSetId := ame_admin_pkg.newStripeSet(applicationIdIn => applicationIdIn,
                                                          attributeValuesIn => stripingAttributeValues);
          end if;
          ame_rule_pkg.newRuleStripeSet(applicationIdIn => applicationIdIn,
                                        ruleIdIn => ruleIdIn,
                                        stripeSetIdIn => tempStripeSetId);
        end if;
      end loop;
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          if(applicationIdCursor%isopen) then
            close applicationIdCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_rule_pkg',
                                    routineNameIn => 'updateRuleStripeSets',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
    end updateRuleStripeSets;
*/
  /* Get the rule id only once */
end ame_rule_pkg;

/
