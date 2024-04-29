--------------------------------------------------------
--  DDL for Package Body AME_TEST_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_TEST_UTILITY_PKG" as
/* $Header: ametestutility.pkb 120.4.12010000.2 2008/08/05 05:15:44 ubhat ship $ */
--+
function isValidApprover(attributeIdIn    in  number
                        ,attributeValueIn in  varchar2)
  return varchar2 as
  approverTypeId number;
  approverName   wf_roles.display_name%type;
  begin
    approverTypeId := ame_attribute_pkg.getApproverTypeId
                        (attributeIdIn => attributeIdIn);
    if(approverTypeId is not null and attributeValueIn is not null)
    then
      approverName := AME_APPROVER_TYPE_PKG.getWfRolesName
                        (origSystemIn       => approverTypeId
                        ,origSystemIdIn     => attributeValueIn
                        ,raiseNoDataFoundIn => 'true');
    end if;
    return '';
  exception
    when others then
      ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'isValidApprover',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
      return sqlerrm || ' ';
  end;
--+
  function getActionTypeName(actionTypeIdIn in integer) return varchar2 as
    actionTypeName ame_action_types_vl.user_action_type_name%type;
    begin
       if (actionTypeIdIn = -1) then
        return ame_util.getMessage('PER','AME_400637_TEXT_NONE');
        end if;
      select user_action_type_name
        into actionTypeName
        from ame_action_types_vl
       where action_type_id = actionTypeIdIn
         and sysdate between start_date
              and nvl(end_date - ame_util.oneSecond, sysdate);
       return actionTypeName;
     exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getActionTypeName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
       raise;
       return actionTypeName;
    end getActionTypeName;
--+
  function getApproverGroupName(groupIdIn in integer) return varchar2 as
    actionTypeName ame_action_types_vl.user_action_type_name%type;
    begin
      select user_approval_group_name
        into actionTypeName
        from ame_approval_groups_vl
       where approval_group_id = groupIdIn
         and sysdate between start_date and nvl(end_date - ame_util.oneSecond, sysdate);
       return actionTypeName;
      exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getApproverGroupName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
       raise;
       return actionTypeName;
    end getApproverGroupName;
--+
  function getApprovalStatusDesc(statusIn in varchar2) return varchar2 as
    approvalStatusDesc fnd_lookups.meaning%type;
    begin
       return statusIn;
       exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getApprovalStatusDesc',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
       raise;
       return statusIn;
    end getApprovalStatusDesc;
--+
  function getApprovalCategoryDesc(categoryIn in varchar2) return varchar2 as
    approvalCategoryDesc fnd_lookups.meaning%type;
    begin
      select meaning
        into approvalCategoryDesc
        from fnd_lookups fl
       where fl.lookup_type = 'AME_APPROVER_CATEGORY'
         and fl.enabled_flag = 'Y'
         and fl.lookup_code = categoryIn
         and trunc(sysdate) between start_date_active
              and nvl(end_date_active, trunc(sysdate));
       return approvalCategoryDesc;
    exception
      when no_data_found then
        return null;
      when others then
       ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getApprovalCategoryDesc',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
       raise;
       return approvalCategoryDesc;
    end getApprovalCategoryDesc;
--+
  function getAuthorityDesc(authorityIn in varchar2) return varchar2 as
    authorityDesc fnd_lookups.meaning%type;
    begin
      select meaning
        into authorityDesc
        from fnd_lookups fl
       where fl.lookup_type = 'AME_SUBLIST_TYPES'
         and fl.enabled_flag = 'Y'
         and fl.lookup_code = authorityIn
         and trunc(sysdate) between start_date_active
              and nvl(end_date_active, trunc(sysdate));
       return(authorityDesc);
     exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getAuthorityDesc',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
       raise;
       return 'Not a valid';
    end getAuthorityDesc;
--+
  function getApiInsertionDesc(apiInsertionIn in varchar2) return varchar2 as
    apiInsertionDesc fnd_lookups.meaning%type;
    begin
       return apiInsertionIn;
    exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getApiInsertionDesc',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
       raise;
       return apiInsertionIn;
    end getApiInsertionDesc;
--+
  function getOrigSystemDesc(origSystemIn in varchar2) return varchar2 as
    origSystemDesc fnd_lookups.meaning%type;
    begin
      select meaning
        into origSystemDesc
        from fnd_lookups fl
       where fl.lookup_type = 'FND_WF_ORIG_SYSTEMS'
         and fl.lookup_code = origSystemIn
         and trunc(sysdate) between start_date_active
              and nvl(end_date_active, trunc(sysdate));
       return origSystemDesc;
     exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                   routineNameIn => 'getOrigSystemDesc',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         raise;
       return origSystemDesc;
    end getOrigSystemDesc;
--+
  function getRuleTypeDesc(ruleTypeIn in varchar2) return varchar2 as
    ruleTypeDesc fnd_lookups.meaning%type;
    begin
      select meaning
        into ruleTypeDesc
        from fnd_lookups fl
       where fl.lookup_type = 'AME_RULE_TYPE'
         and fl.enabled_flag = 'Y'
         and fl.lookup_code = ruleTypeIn
         and trunc(sysdate) between start_date_active
              and nvl(end_date_active, trunc(sysdate));
       return ruleTypeDesc;
       exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                   routineNameIn => 'getRuleTypeDesc',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         raise;
         return ruleTypeDesc;
    end getRuleTypeDesc;
--+
  function getRuleType(ruleIdIn in integer
                      ,effectiveDateIn in date) return varchar2 as
    ruleTypeCode varchar2(1);
    ruleTypeDesc fnd_lookups.meaning%type;
    begin
      select rule_type
        into ruleTypeCode
        from ame_rules
       where rule_id = ruleIdIn
         and effectiveDateIn between start_date
              and nvl(end_date - ame_util.oneSecond, sysdate);
      return getApprovalCategoryDesc(ruleTypeCode);
      exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getRuleType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
         raise;
         return getApprovalCategoryDesc(ruleTypeCode);
    end getRuleType;
--+
  function getRuleCategory(ruleIdIn        in integer
                          ,applicationIdIn in integer
                          ,effectiveDateIn in date) return varchar2 as
    categoryCode varchar2(1);
    cagegoryDesc fnd_lookups.meaning%type;
    begin
      begin
      select approver_category
        into categoryCode
        from ame_rule_usages
       where rule_id = ruleIdIn
         and item_id = applicationIdIn
         and effectiveDateIn between start_date
           and nvl(end_date - ame_util.oneSecond, sysdate);
      exception
        when no_data_found then
          categoryCode := 'A';
      end;
      return getApprovalCategoryDesc(categoryCode);
      exception
       when others then
      ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getRuleCategory',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
       raise;
       return null;
    end getRuleCategory;
--+
  function getConditionsList(ruleIdIn        in integer
                            ,effectiveDateIn   in date) return varchar2 as
    cursor getCondtitionsCursor(ruleIdIn        in integer
                               ,effectiveDateIn in date) is
      select condition_id
        from ame_condition_usages
       where rule_id = ruleIdIn
         and effectiveDateIn between start_date
           and nvl(end_date - ame_util.oneSecond, sysdate);
    conditionsList  ame_util.longestStringType;
    conditionIdList ame_util.idList;
    begin
      open getCondtitionsCursor(ruleIdIn => ruleIdIn
                        ,effectiveDateIn => effectiveDateIn);
      fetch getCondtitionsCursor bulk collect
        into conditionIdList;
      close getCondtitionsCursor;
      for x in 1 .. conditionIdList.count loop
        if x > 1 then
          conditionsList := conditionsList || fnd_global.local_chr(ascii_chr => 13);
        end if;
        conditionsList := conditionsList
                          || ame_utility_pkg.get_condition_description(p_condition_id => conditionIdList(x));
      end loop;
      return conditionsList;
    exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                   routineNameIn => 'getConditionsList',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         raise;
         return null;
    end getConditionsList;
--+
function getItemClassNameById(itemClassIdIn in integer) return varchar2 as
    itemName ame_item_classes.name%type;
    begin
     select user_item_class_name
       into itemName
        from ame_item_classes_vl
         where item_class_id = itemClassIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
       return(itemName);
      exception
        when others then
          rollback;
            ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                   routineNameIn => 'getItemClassNameById',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
              raise;
         return null;
    end getItemClassNameById;
--+
 function getItemClassName(itemClassNameIn in varchar2) return varchar2 as
    itemName ame_item_classes.name%type;
    begin
     select user_item_class_name
       into itemName
        from ame_item_classes_vl
         where trim(name) = trim(itemClassNameIn) and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
       return(itemName);
      exception
        when others then
            ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                   routineNameIn => 'getItemClassName',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
              raise;
         return null;
    end getItemClassName;
--+
  function getActionsList(ruleIdIn          in integer
                         ,effectiveDateIn   in date) return varchar2 as
    cursor getActionsCursor(ruleIdIn        in integer
                           ,effectiveDateIn in date) is
      select action_id
        from ame_action_usages
       where rule_id = ruleIdIn
         and effectiveDateIn between start_date
           and nvl(end_date - ame_util.oneSecond, sysdate);
    actionsList  ame_util.longestStringType;
    actionIdList ame_util.idList;
    begin
      open getActionsCursor(ruleIdIn => ruleIdIn
                        ,effectiveDateIn => effectiveDateIn);
      fetch getActionsCursor bulk collect
        into actionIdList;
      close getActionsCursor;
      for x in 1 .. actionIdList.count loop
        if x <> 1 then
          actionsList := actionsList || fnd_global.local_chr(ascii_chr => 13);
        end if;
        actionsList := actionsList
                    || ame_utility_pkg.get_action_description(p_action_id => actionIdList(x));
      end loop;
      return actionsList;
     exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                   routineNameIn => 'getActionsList',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         raise;
         return null;
    end getActionsList;
--+
  function getRuleDescription(ruleIdIn in integer,effectiveRuleDate in date) return varchar2 as
    ruleDesc ame_rules_vl.description%type;
    begin
      select description
        into ruleDesc
        from ame_rules_vl
       where rule_id = ruleIdIn
         and  effectiveRuleDate between start_date
              and nvl(end_date - ame_util.oneSecond, sysdate);
      return ruleDesc;
      exception
       when others then
         ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                   routineNameIn => 'getRuleDescription',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         raise;
         return null;
    end getRuleDescription;
--+
  function getSourceDesc(sourceIn in varchar2, effectiveRuleDate in date) return varchar2 as
    sourceDesc ame_util.longestStringType;
    ruleIdList ame_util.idList;
    sourceDescription ame_util.stringType;
    begin
      ame_util.parseSourceValue(sourceValueIn => sourceIn
                               ,sourceDescriptionOut => sourceDescription
                               ,ruleIdListOut => ruleIdList);
      for x in 1 .. ruleIdList.count loop
        if x > 1 then
          sourceDesc := sourceDesc || fnd_global.local_chr(ascii_chr => 13);
        end if;
        sourceDesc := sourceDesc || getRuleDescription(ruleIdList(x),effectiveRuleDate);
      end loop;
      return sourceDesc;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                  routineNameIn => 'getSourceDesc',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
         raise;
         return null;
    end getSourceDesc;
--+
function isAttributesExist(applicationIdIn      in        number
                          ,itemClassIdIn        in        number)
  return varchar2 as
  retValue   varchar2(10) := 'Disabled';
  atrCount   number;
  begin
    select count(1)
      into atrCount
      from ame_attributes,
           ame_attribute_usages
     where ame_attribute_usages.attribute_id = ame_attributes.attribute_id
       and ame_attribute_usages.application_id = applicationIdIn
       and ame_attributes.item_class_id = itemClassIdIn
       and sysdate between ame_attribute_usages.start_date and
             nvl(ame_attribute_usages.end_date - ame_util.oneSecond,sysdate)
       and sysdate between ame_attributes.start_date and
             nvl(ame_attributes.end_date - ame_util.oneSecond,sysdate);
    if(atrCount > 0) then
      retValue := 'Enabled';
    end if;
    return retValue;
    exception
      When others then
        ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                  routineNameIn => 'isAttributesExist',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
        return retValue;
  end isAttributesExist;
  --+
/*************************************************************************************
  procedures
*************************************************************************************/
procedure setErrorMessage(attributeNameIn       in varchar2
                         ,attributeItemTypeIn   in varchar2
                         ,itemClassIdIn         in number   default null
                         ,itemIdIn              in varchar2 default null
                         ,approverTypeIdIn      in number   default null) is
 itemClassName  varchar2(100);
begin
 if attributeItemTypeIn = 'MANDATORY_ATTR' then
   fnd_message.set_name('PER','AME_400824_INV_MAND_ATTR_USG');
   fnd_message.set_token('ATTRIBUTE_NAME',attributeNameIn);
   hr_multi_message.add (p_associated_column1 => 'ATTR_NAME'
                         , p_message_type  => hr_multi_message.g_warning_msg);
 elsif attributeItemTypeIn = 'HEADER_ATTR' then
   if approverTypeIdIn is not null then
     fnd_message.set_name('PER','AME_400821_INVAL_APR_ATTR_USG');
     fnd_message.set_token('ATTRIBUTE_NAME',attributeNameIn);
     hr_multi_message.add (p_associated_column1 => 'ATTR_NAME');
   else
     fnd_message.set_name('PER','AME_400820_INVAL_HDR_ATTR_USG');
     fnd_message.set_token('ATTRIBUTE_NAME',attributeNameIn);
     hr_multi_message.add (p_associated_column1 => 'ATTR_NAME'
                          , p_message_type  => hr_multi_message.g_warning_msg);
   end if;
 else
   itemClassName := getItemClassNameById(itemClassIdIn=> itemClassIdIn);
   if approverTypeIdIn is not null then
     fnd_message.set_name('PER','AME_400823_INV_APR_LN_ATR_USG');
     fnd_message.set_token('ATTRIBUTE_NAME',attributeNameIn);
     fnd_message.set_token('ITEM_ID',itemIdIn);
     fnd_message.set_token('ITEM_CLASS',itemClassName);
     hr_multi_message.add (p_associated_column1 => 'ATTR_NAME');
   else
     fnd_message.set_name('PER','AME_400822_INVAL_LNE_ATTR_USG');
     fnd_message.set_token('ATTRIBUTE_NAME',attributeNameIn);
     fnd_message.set_token('ITEM_ID',itemIdIn);
     fnd_message.set_token('ITEM_CLASS',itemClassName);
     hr_multi_message.add (p_associated_column1 => 'ATTR_NAME'
                          ,p_message_type  => hr_multi_message.g_warning_msg
                          );
   end if;
 end if;
end setErrorMessage;

function checkConversionError(attributeNameIn     in varchar2
                             ,attributeItemTypeIn in varchar2
                             ,attributeValue1In   in varchar2
                             ,attributeValue2In   in varchar2 default null
                             ,attributeValue3In   in varchar2 default null
                             ,attributeTypeIn     in varchar2
                             ,approverTypeIdIn    in number   default null
                             ,itemClassIdIn       in number   default null
                             ,itemIdIn            in varchar2 default null
                              ) return varchar2 is
  dummy_num       number;
  dummy_date      date;
  dummy_curr_code boolean := true;
  dummy_conv_type boolean := true ;
 begin
   if attributeTypeIn = ame_util.numberAttributeType then
    -- number attribute validation
     begin
       dummy_num := to_number(attributeValue1In);
     exception
       when others then
          begin
            if (approverTypeIdIn is not null)  then
              setErrorMessage(attributeNameIn      => attributeNameIn
                             ,attributeItemTypeIn  => attributeItemTypeIn
                             ,itemIdIn             => itemIdIn
                             ,itemClassIdIn        => itemClassIdIn
                             ,approverTypeIdIn     => approverTypeIdIn);
              return 'APPR_ATTR_ERROR';
            else
              setErrorMessage(attributeNameIn      => attributeNameIn
                             ,attributeItemTypeIn  => attributeItemTypeIn
                             ,itemClassIdIn        => itemClassIdIn
                             ,itemIdIn             => itemIdIn
                             );
              return 'ERROR_EXIST';
            end if;
          exception
            when others then
              setErrorMessage(attributeNameIn      => attributeNameIn
                             ,attributeItemTypeIn  => attributeItemTypeIn
                             ,itemClassIdIn        => itemClassIdIn
                             ,itemIdIn             => itemIdIn
                             );
             return 'ERROR_EXIST';
          end;
     end;
   elsif attributeTypeIn = ame_util.dateAttributeType then
    --date validation
     begin
       dummy_date := to_date(attributeValue1In, ame_util.versionDateFormatModel);
     exception
      when others then
        setErrorMessage(attributeNameIn      => attributeNameIn
                       ,attributeItemTypeIn  => attributeItemTypeIn
                       ,itemClassIdIn        => itemClassIdIn
                       ,itemIdIn             => itemIdIn
                       );
        return 'ERROR_EXIST';
     end;
   elsif attributeTypeIn = ame_util.booleanAttributeType then
    --boolean attribute validation
     if trim(attributeValue1In) <> ame_util.booleanAttributeTrue and
            trim(attributeValue1In) <> ame_util.booleanAttributeFalse then
        setErrorMessage(attributeNameIn      => attributeNameIn
                       ,attributeItemTypeIn  => attributeItemTypeIn
                       ,itemClassIdIn        => itemClassIdIn
                       ,itemIdIn             => itemIdIn
                       );
       return 'ERROR_EXIST';
     end if;
   elsif attributeTypeIn = ame_util.currencyAttributeType then
    -- Currency attr validation
     begin
       dummy_num := to_number(attributeValue1In);
       dummy_curr_code := ame_util.isCurrencyCodeValid(currencyCodeIn => attributeValue2In);
       dummy_conv_type := ame_util.isConversionTypeValid(conversionTypeIn => attributeValue3In);
       if  (dummy_curr_code is not null and dummy_curr_code = false) or
           (dummy_curr_code is not null and dummy_conv_type = false )then
        setErrorMessage(attributeNameIn      => attributeNameIn
                       ,attributeItemTypeIn  => attributeItemTypeIn
                       ,itemClassIdIn        => itemClassIdIn
                       ,itemIdIn             => itemIdIn
                       );
        return 'ERROR_EXIST';
      end if;
     exception
      when others then
        setErrorMessage(attributeNameIn      => attributeNameIn
                       ,attributeItemTypeIn  => attributeItemTypeIn
                       ,itemClassIdIn        => itemClassIdIn
                       ,itemIdIn             => itemIdIn
                       );
        return 'ERROR_EXIST';
     end;
   end if;
   return 'NO_ERROR';
 end checkConversionError;

procedure getNonMandAttributes(applicationIdIn   in integer,
                               itemClassIdIn     in integer,
                               attributeIdOut    out nocopy ame_util.stringList,
                               attributeNameOut  out nocopy ame_util.stringList,
                               attributeTypeOut  out nocopy ame_util.stringList,
                               approverTypeIdOut out nocopy ame_util.idList) as
  cursor attributeCursor(applicationIdIn in integer,
                         headerItemClassIdIn in integer) is
    select
      ame_attributes.attribute_id,
      ame_attributes.name,
      ame_attributes.attribute_type,
      ame_attributes.approver_type_id
    from
      ame_attributes,
      ame_attribute_usages,
      ame_item_classes
    where
      ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
      ame_attributes.item_class_id = ame_item_classes.item_class_id and
      ame_item_classes.item_class_id = headerItemClassIdIn and
      ame_attribute_usages.application_id = applicationIdIn and
      nvl(ame_attributes.line_item, ame_util.booleanFalse) = ame_util.booleanFalse and
      ame_attributes.attribute_id not in
      (select attribute_id from ame_mandatory_attributes
       where action_type_id = -1 and
         sysdate between ame_mandatory_attributes.start_date and
           nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate) ) and
        sysdate between ame_attributes.start_date and
               nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
               nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_item_classes.start_date and
               nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate)
      order by ame_attributes.name;
  tempIndex integer;
begin
    tempIndex := 1;
    for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn,
                                              headerItemClassIdIn => itemClassIdIn) loop
      /* The explicit conversion below lets nocopy work. */
      attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
      attributeNameOut(tempIndex) := tempAttributeUsage.name;
      attributeTypeOut(tempIndex) := tempAttributeUsage.attribute_type;
      approverTypeIdOut(tempIndex) := tempAttributeUsage.approver_type_id;
      tempIndex := tempIndex + 1;
    end loop;
exception
  when others then
    rollback;
    ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                              routineNameIn => 'getNonMandAttributes',
                              exceptionNumberIn => sqlcode,
                              exceptionStringIn => '(application ID ' ||
                                                  applicationIdIn||
                                                  ') ' ||
                                                  sqlerrm);
    raise;
end getNonMandAttributes;

procedure populateRealTransAttributes(applicationIdIn in  number
                                     ,transactionIdIn in  varchar2
                                     ,errString out nocopy varchar2) as

  cursor getVariantAttributes(applicationIdIn in number) is
    select atr.attribute_id
          ,atr.name
          ,atr.attribute_type
          ,atr.approver_type_id
      from ame_attributes atr
          ,ame_attribute_usages atu
     where atr.name in (ame_util.jobLevelStartingPointAttribute
                        ,ame_util.nonDefStartingPointPosAttr
                        ,ame_util.nonDefPosStructureAttr
                        ,ame_util.supStartingPointAttribute
                        ,ame_util.firstStartingPointAttribute
                        ,ame_util.secondStartingPointAttribute
                        )
       and atr.attribute_id = atu.attribute_id
       and atu.application_id = applicationIdIn
       and sysdate between atr.start_date and nvl(atr.end_date - (1/86400), sysdate)
       and sysdate between atu.start_date and nvl(atu.end_date - (1/86400), sysdate);

  attributeIds    ame_util.stringList;
  attributeIds2   ame_util.stringList;
  attributeNames  ame_util.stringList;
  attributeTypes  ame_util.stringList;
  attributeValue1 ame_util.attributeValueType;
  attributeValue2 ame_util.attributeValueType;
  attributeValue3 ame_util.attributeValueType;
  itemClassIdsList   ame_util.stringList;
  itemClassNamesList ame_util.stringList;
  itemIds            ame_util.stringList;
  upperLimit      integer;
  workflowItemKey wf_item_activity_statuses.item_key%type;
  workflowItemType wf_item_activity_statuses.item_type%type;
  variantAttributeIds ame_util.idList;
  variantAttributeNames ame_util.stringList;
  variantAttributeTypes ame_util.stringList;
  variantAttributeApprType  ame_util.idList;
  approverTypeIdList     ame_util.idList;
  itemClassName          varchar2(100);
  convErrYes             boolean;
  purgeValueYes          boolean;
  begin
    errString := 'NO_ERROR';
    hr_multi_message.enable_message_list;
    ame_engine.updateTransactionState(isTestTransactionIn         => false
                                     ,isLocalTransactionIn        => true
                                     ,fetchConfigVarsIn           => true
                                     ,fetchOldApproversIn         => false
                                     ,fetchInsertionsIn           => false
                                     ,fetchDeletionsIn            => false
                                     ,fetchAttributeValuesIn      => true
                                     ,fetchInactiveAttValuesIn    => true
                                     ,processProductionActionsIn  => false
                                     ,processProductionRulesIn    => false
                                     ,updateCurrentApproverListIn => false
                                     ,updateOldApproverListIn     => false
                                     ,processPrioritiesIn         => false
                                     ,prepareItemDataIn           => false
                                     ,prepareRuleIdsIn            => false
                                     ,prepareRuleDescsIn          => false
                                     ,transactionIdIn             => transactionIdIn
                                     ,ameApplicationIdIn          => applicationIdIn
                                     ,fndApplicationIdIn          => null
                                     ,transactionTypeIdIn         => null);
    --+
    open getVariantAttributes(applicationIdIn => applicationIdIn);
    fetch getVariantAttributes bulk collect into variantAttributeIds
                                                ,variantAttributeNames
                                                ,variantAttributeTypes
                                                ,variantAttributeApprType;
    close getVariantAttributes;
    --+

    --+
    --+
    --+
       delete from ame_temp_trans_att_values
        where application_id = applicationIdIn
          and transaction_id = transactionIdIn;
    --+
    --+ mandatory attributes
    --+
    ame_attribute_pkg.getMandatoryAttributes2(applicationIdIn  => applicationIdIn
                                             ,attributeIdOut   => attributeIds
                                             ,attributeNameOut => attributeNames
                                             ,attributeTypeOut => attributeTypes);
    upperLimit := attributeIds.count;
    ame_util.getWorkflowAttributeValues(applicationIdIn     => applicationIdIn,
                                        transactionIdIn     => transactionIdIn,
                                        workflowItemKeyOut  => workflowItemKey,
                                        workflowItemTypeOut => workflowItemType);
    --+
    for i in 1 .. upperLimit loop
      --+
      if attributeNames(i) = ame_util.workflowItemKeyAttribute then
        attributeValue1 := workflowItemKey;
        attributeValue2 := null;
        attributeValue3 := null;
      elsif attributeNames(i) = ame_util.workflowItemTypeAttribute then
        attributeValue1 := workflowItemType;
        attributeValue2 := null;
        attributeValue3 := null;
      else
        ame_engine.getHeaderAttValues1(attributeIdIn      => to_number(attributeIds(i))
                                      ,attributeValue1Out => attributeValue1
                                      ,attributeValue2Out => attributeValue2
                                      ,attributeValue3Out => attributeValue3);
      end if;
      --+
     errString:= checkConversionError(attributeNameIn       => attributeNames(i)
                                     ,attributeItemTypeIn   => 'MANDATORY_ATTR'
                                     ,attributeValue1In     => attributeValue1
                                     ,attributeValue2In     => attributeValue2
                                     ,attributeValue3In     => attributeValue3
                                     ,attributeTypeIn       => attributeTypes(i)
                                     ,approverTypeIdIn      => null
                                    );
     if errString = 'ERROR_EXIST' then
      convErrYes := true;
     end if;

      --+
      insert into ame_temp_trans_att_values(application_id
                                ,transaction_id
                                ,row_timestamp
                                ,attribute_id
                                ,attribute_name
                                ,attribute_type
                                ,is_mandatory
                                ,attribute_value_1
                                ,attribute_value_2
                                ,attribute_value_3
                                ,item_id
                                ,item_class_id)
                          values(applicationIdIn
                                ,transactionIdIn
                                ,sysdate
                                ,attributeIds(i)
                                ,attributeNames(i)
                                ,attributeTypes(i)
                                ,'Y'
                                ,attributeValue1
                                ,attributeValue2
                                ,attributeValue3
                                ,transactionIdIn
                                ,1);
    end loop;
    --+
    --+ non mandatory header attributes
    --+
    getNonMandAttributes(applicationIdIn   => applicationIdIn
                        ,itemClassIdIn     => ame_admin_pkg.getItemClassIdByName(itemClassNameIn => ame_util.headerItemClassName)
                        ,attributeIdOut    => attributeIds
                        ,attributeNameOut  => attributeNames
                        ,attributeTypeOut  => attributeTypes
                        ,approverTypeIdOut => approverTypeIdList);
    upperLimit := attributeIds.count;
    --+
    for i in 1 .. upperLimit loop
      --+
      ame_engine.getHeaderAttValues1(attributeIdIn      => to_number(attributeIds(i))
                                    ,attributeValue1Out => attributeValue1
                                    ,attributeValue2Out => attributeValue2
                                    ,attributeValue3Out => attributeValue3);

      --+
     errString := checkConversionError(attributeNameIn     => attributeNames(i)
                                      ,attributeItemTypeIn => 'HEADER_ATTR'
                                      ,attributeValue1In   => attributeValue1
                                      ,attributeValue2In   => attributeValue2
                                      ,attributeValue3In   => attributeValue3
                                      ,attributeTypeIn     => attributeTypes(i)
                                      ,approverTypeIdIn    => approverTypeIdList(i)
                                      );
     if errString = 'ERROR_EXIST' then
       convErrYes := true;
     end if;
     if errString = 'APPR_ATTR_ERROR' then
       purgeValueYes := true;
     end if;
      --+
      insert into ame_temp_trans_att_values(application_id
                                ,transaction_id
                                ,row_timestamp
                                ,attribute_id
                                ,attribute_name
                                ,attribute_type
                                ,is_mandatory
                                ,attribute_value_1
                                ,attribute_value_2
                                ,attribute_value_3
                                ,item_id
                                ,item_class_id)
                          values(applicationIdIn
                                ,transactionIdIn
                                ,sysdate
                                ,attributeIds(i)
                                ,attributeNames(i)
                                ,attributeTypes(i)
                                ,'N'
                                ,attributeValue1
                                ,attributeValue2
                                ,attributeValue3
                                ,transactionIdIn
                                ,1);
    end loop;
    --+
    ame_admin_pkg.getTransTypeItemClasses4(applicationIdIn   => applicationIdIn
                                          ,itemClassIdsOut   => itemClassIdsList
                                          ,itemClassNamesOut => itemClassNamesList);
    upperLimit := itemClassIdsList.count;
    --+
    for i in 1 .. upperLimit loop
      --+
      ame_engine.getItemClassItemIds(itemClassIdIn => itemClassIdsList(i)
                                    ,itemIdsOut    => itemIds);
      getNonMandAttributes(applicationIdIn     => applicationIdIn
                          ,itemClassIdIn     => to_number(itemClassIdsList(i))
                          ,attributeIdOut    => attributeIds2
                          ,attributeNameOut  => attributeNames
                          ,attributeTypeOut  => attributeTypes
                          ,approverTypeIdOut => approverTypeIdList);
      for j in 1 .. itemIds.count loop
        --+
        for k in 1 .. attributeIds2.count loop
          --+
          ame_engine.getItemAttValues1(attributeIdIn      => attributeIds2(k)
                                      ,itemIdIn           => itemIds(j)
                                      ,attributeValue1Out => attributeValue1
                                      ,attributeValue2Out => attributeValue2
                                      ,attributeValue3Out => attributeValue3);

          --+
          errString := checkConversionError(attributeNameIn     => attributeNames(k)
                                           ,attributeItemTypeIn => 'OTHER_ATTR'
                                           ,attributeValue1In   => attributeValue1
                                           ,attributeValue2In   => attributeValue2
                                           ,attributeValue3In   => attributeValue3
                                           ,attributeTypeIn     => attributeTypes(k)
                                           ,approverTypeIdIn    => approverTypeIdList(k)
                                           ,itemClassIdIn       => itemClassIdsList(i)
                                           ,itemIdIn            => itemIds(j)
                                            );
          if errString = 'ERROR_EXIST' then
            convErrYes := true;
          end if;
          if errString = 'APPR_ATTR_ERROR' then
            purgeValueYes := true;
          end if;
          --+
          insert into ame_temp_trans_att_values(application_id
                                    ,transaction_id
                                    ,row_timestamp
                                    ,attribute_id
                                    ,attribute_name
                                    ,attribute_type
                                    ,is_mandatory
                                    ,attribute_value_1
                                    ,attribute_value_2
                                    ,attribute_value_3
                                    ,item_id
                                    ,item_class_id)
                              values(applicationIdIn
                                    ,transactionIdIn
                                    ,sysdate
                                    ,attributeIds2(k)
                                    ,attributeNames(k)
                                    ,attributeTypes(k)
                                    ,'N'
                                    ,attributeValue1
                                    ,attributeValue2
                                    ,attributeValue3
                                    ,itemIds(j)
                                    ,itemClassIdsList(i));
        end loop;
        -- Add by srpurani for variant attribute enhancement
        attributeValue2 := null;
        attributeValue3 := null;
        for k in 1..variantAttributeIds.count loop
          --+
         begin
          attributeValue1 := null;
          attributeValue1 := ame_engine.getVariantAttributeValue(attributeIdIn => variantAttributeIds(k),
                                                                  itemClassIn   => itemClassNamesList(i),
                                                                  itemIdIn      => itemIds(j));
          exception
            When others then
             if attributeValue1 is null then
               attributeValue1 := 'null';
             end if;
             errString := checkConversionError(
                                       attributeNameIn     => variantAttributeNames(k)
                                      ,attributeItemTypeIn => 'OTHER_ATTR'
                                      ,attributeValue1In   => attributeValue1
                                      ,attributeValue2In   => attributeValue2
                                      ,attributeValue3In   => attributeValue3
                                      ,attributeTypeIn     => variantAttributeTypes(k)
                                      ,approverTypeIdIn    => variantAttributeApprType(k)
                                      ,itemClassIdIn       => itemClassIdsList(i)
                                      ,itemIdIn            => itemIds(j)
                                      );
             if errString = 'ERROR_EXIST' then
               convErrYes := true;
             end if;
             if errString = 'APPR_ATTR_ERROR' then
               purgeValueYes := true;
             end if;
         end;
          --+
          insert into ame_temp_trans_att_values(application_id
                                    ,transaction_id
                                    ,row_timestamp
                                    ,attribute_id
                                    ,attribute_name
                                    ,attribute_type
                                    ,is_mandatory
                                    ,attribute_value_1
                                    ,attribute_value_2
                                    ,attribute_value_3
                                    ,item_id
                                    ,item_class_id)
                              values(applicationIdIn
                                    ,transactionIdIn
                                    ,sysdate
                                    ,variantAttributeIds(k)
                                    ,variantAttributeNames(k)
                                    ,variantAttributeTypes(k)
                                    ,'N'
                                    ,attributeValue1
                                    ,attributeValue2
                                    ,attributeValue3
                                    ,itemIds(j)
                                    ,itemClassIdsList(i));
          --+
        end loop;
        --+
      end loop;
      --+
    end loop;
    --+
    if purgeValueYes then
      delete from ame_temp_trans_att_values
      where application_id = applicationIdIn
      and transaction_id = transactionIdIn;
      errString := 'APPR_ATTR_ERROR';
      return;
    end if;
    if convErrYes then
      errString := 'AME_CONV_ERROR';
      return;
    end if;
     exception
      When others then
        ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                  routineNameIn => 'populateRealTransAttributes',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        if sqlcode = -20001 then
          errString :=  sqlerrm;
          errString:= substr(errString,11);
        else
          fnd_message.set_name('PER','AME_400754_TEST_REALTX_ATT_ERR');
          hr_multi_message.add (p_associated_column1 => 'ATTR_NAME');
          errString := 'ERROR_EXIST';
         end if;
  end populateRealTransAttributes;
--+
procedure getApplicableRules(applicationIdIn      in        number
                            ,transactionIdIn      in        varchar2
                            ,isRealTransaction    in        varchar2 -- 'Y' for a real transaction
                                                                     -- 'N' for a test transaction
                            ,processPriorities    in        varchar2
                            ,rulesOut            out nocopy ame_rules_list
                            ,errString           out nocopy varchar2) as
  ruleItemClassIds ame_util.idList;
  itemClassIds     ame_util.idList;
  itemIds          ame_util.stringList;
  ruleTypes        ame_util.idList;
  ruleDescriptions ame_util.stringList;
  ruleIds          ame_util.idList;
  rulesList  ame_rules_list := ame_rules_list();
  ruleObject ame_rule;
  effectiveRuleDate date;
  effecitveRuleDateString ame_util.stringType;
  itemClassName    varchar2(100);
  begin
  errString := 'NO_ERROR';
    ame_engine.updateTransactionState(isTestTransactionIn         => isRealTransaction = 'N'
                                     ,isLocalTransactionIn        => true
                                     ,fetchConfigVarsIn           => true
                                     ,fetchOldApproversIn         => false
                                     ,fetchInsertionsIn           => false
                                     ,fetchDeletionsIn            => false
                                     ,fetchAttributeValuesIn      => true
                                     ,fetchInactiveAttValuesIn    => false
                                     ,processProductionActionsIn  => false
                                     ,processProductionRulesIn    => true
                                     ,updateCurrentApproverListIn => false
                                     ,updateOldApproverListIn     => false
                                     ,processPrioritiesIn         => processPriorities = 'Y'
                                     ,prepareItemDataIn           => false
                                     ,prepareRuleIdsIn            => false
                                     ,prepareRuleDescsIn          => false
                                     ,transactionIdIn             => transactionIdIn
                                     ,ameApplicationIdIn          => applicationIdIn
                                     ,fndApplicationIdIn          => null
                                     ,transactionTypeIdIn         => null);
    effectiveRuleDate := ame_engine.getEffectiveRuleDate;
    ame_engine.getTestTransApplicableRules(ruleItemClassIdsOut => ruleItemClassIds
                                          ,itemClassIdsOut     => itemClassIds
                                          ,itemIdsOut          => itemIds
                                          ,ruleIdsOut          => ruleIds
                                          ,ruleTypesOut        => ruleTypes
                                          ,ruleDescriptionsOut => ruleDescriptions);

    for i in 1 .. itemIds.count loop
      if(ruleItemClassIds(i) is not null) then
        itemClassName := ame_test_utility_pkg.getItemClassNameById(ruleItemClassIds(i));
      else
        itemClassName := null;
      end if;
      ruleObject :=  ame_rule(ruleIds(i)
                                    ,ruleDescriptions(i)
                                    ,ruleItemClassIds(i)
                                    ,itemClassName
                                    ,itemIds(i)
                                    ,getRuleTypeDesc(ruleTypes(i))
                                    ,ruleTypes(i)
                                    ,getRuleCategory(ruleIds(i),applicationIdIn,effectiveRuleDate)
                                    ,ame_rule_pkg.getEffectiveStartDateUsage
                                       (applicationIdIn => applicationIdIn
                                       ,ruleIdIn        => ruleIds(i)
                                       ,effectiveDateIn  => effectiveRuleDate)
                                    ,ame_rule_pkg.getEffectiveEndDateUsage
                                       (applicationIdIn => applicationIdIn
                                       ,ruleIdIn        => ruleIds(i)
                                       ,effectiveDateIn  => effectiveRuleDate)
                                    ,getConditionsList(ruleIds(i),effectiveRuleDate)
                                    ,getActionsList(ruleIds(i),effectiveRuleDate)
                                    );
     rulesList.extend;
     rulesList(i) := ruleObject;
    end loop;
    rulesOut := rulesList;
    exception
      When others then
        ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                  routineNameIn => 'getApplicableRules',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        if sqlcode = -20001 then
          errString :=  sqlerrm;
          errString:= substr(errString,11);
        else
          fnd_message.set_name('PER','AME_400692_ENGINE_ERROR');
          errString := fnd_message.get;
        end if;
  end getApplicableRules;
--+
procedure getApprovers(applicationIdIn      in        number
                      ,transactionIdIn      in        varchar2
                      ,isRealTransaction    in        varchar2 -- 'Y' for a real transaction
                                                               -- 'N' for a test transaction
                      ,approverListStageIn  in        integer
                      ,approversOut        out nocopy ame_approvers_list
                      ,errString           out nocopy varchar2) as
  approverList ame_util.approversTable2;
  productionIndexes ame_util.idList;
  variableNames ame_util.stringList;
  variableValues ame_util.stringList;
  approverObjList ame_approvers_list := ame_approvers_list();
  approver        ame_approver;
  effectiveRuleDate date;
  tempActionTypeName ame_util.stringType;
  tempGroupName ame_util.stringType;
  approverSource varchar2(500);
  productionsList varchar2(4000);
  ruleIdList ame_util.idList;
  l_app_count number;
  begin
    l_app_count :=0;
    errString:= 'NO_ERROR';
    ame_engine.getTestTransApprovers(isTestTransactionIn  => isRealTransaction = 'N'
                                    ,transactionIdIn      => transactionIdIn
                                    ,ameApplicationIdIn   => applicationIdIn
                                    ,approverListStageIn  => approverListStageIn
                                    ,approversOut         => approverList
                                    ,productionIndexesOut => productionIndexes
                                    ,variableNamesOut     => variableNames
                                    ,variableValuesOut    => variableValues);
  --+
  effectiveRuleDate := ame_engine.getEffectiveRuleDate;
  --+
    for i in 1 .. approverList.count loop
      tempActionTypeName := getActionTypeName(approverList(i).action_type_id);
      if(tempActionTypeName in (ame_util.groupChainApprovalTypeName
                               ,ame_util.preApprovalTypeName
                               ,ame_util.postApprovalTypeName))then
        tempGroupName := getApproverGroupName(approverList(i).group_or_chain_id);
      else
        tempGroupName := 'Chain '||approverList(i).group_or_chain_id;
      end if;
      ame_util.parseSourceValue(sourceValueIn        => approverList(i).source
                               ,sourceDescriptionOut => approverSource
                               ,ruleIdListOut        => ruleIdList);
      productionsList := '';
      for j in 1 .. productionIndexes.count
      loop
        if(productionIndexes(j) = i) then
          if (j <> 1) then
            productionsList := productionsList || fnd_global.local_chr(ascii_chr => 13);
          end if;
          productionsList := productionsList ||
                             variableNames(j)|| ' : ' ||
                             variableValues(j);
        end if;
      end loop;
      if ((approverList(i).approval_status is null) or
          (approverList(i).approval_status not like '%'||ame_util.repeatedStatus) or
          (approverListStageIn < 6)) then
        if approverListStageIn = 1 and
            approverList(i).approval_status like '%'||ame_util.repeatedStatus then
          approverList(i).approval_status :=null;
        end if;
        if approverListStageIn = 5 and
            approverList(i).approval_status like '%'||ame_util.repeatedStatus then
          approverList(i).approval_status :=ame_util.repeatedStatus;
        end if;
        approver := ame_approver(approverList(i).name
                                ,approverList(i).orig_system
                                ,approverList(i).orig_system_id
                                ,approverList(i).display_name
                                ,approverList(i).approver_category
                                ,approverList(i).api_insertion
                                ,approverList(i).authority
                                ,approverList(i).approval_status
                                ,approverList(i).action_type_id
                                ,approverList(i).group_or_chain_id
                                ,approverList(i).occurrence
                                ,approverSource
                                ,getItemClassName(approverList(i).item_class)
                                ,approverList(i).item_id
                                ,approverList(i).item_class_order_number
                                ,approverList(i).item_order_number
                                ,approverList(i).sub_list_order_number
                                ,approverList(i).action_type_order_number
                                ,approverList(i).group_or_chain_order_number
                                ,approverList(i).member_order_number
                                ,approverList(i).approver_order_number
                                ,tempActionTypeName
                                ,getOrigSystemDesc(approverList(i).orig_system)
                                ,tempGroupName
                                ,getAuthorityDesc(approverList(i).authority)
                                ,getApiInsertionDesc(approverList(i).api_insertion)
                                ,getApprovalStatusDesc(approverList(i).approval_status)
                                ,getApprovalCategoryDesc(approverList(i).approver_category)
                                ,getSourceDesc(approverList(i).source,effectiveRuleDate)
                                ,productionsList);
        l_app_count := l_app_count + 1;
        approverObjList.extend;
        approverObjList(l_app_count) := approver;
      end if;
    end loop;
    approversOut := approverObjList;
    exception
      When others then
      ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getApprovers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);

      if sqlcode = -20001 then
        errString :=  sqlerrm;
        errString:= substr(errString,11);
      else
        fnd_message.set_name('PER','AME_400692_ENGINE_ERROR');
         errString := fnd_message.get;
       end if;
  --+
  end getApprovers;
--+
procedure getTransactionProductions(applicationIdIn      in        number
                                   ,transactionIdIn      in        varchar2
                                   ,isRealTransaction    in        varchar2 -- 'Y' for a real transaction
                                                                            -- 'N' for a test transaction
                                   ,processPriorities    in        varchar2
                                   ,productionsOut      out nocopy ame_productions_list
                                   ,errString           out nocopy varchar2) as
  variableNames  ame_util.stringList;
  variableValues ame_util.stringList;
  productionNVPair ame_production_name_value_pair;
  productionsList ame_util2.productionsTable ;--:= ame_util2.productionsTable();

  begin
    errString := 'NO_ERROR';
      ame_engine.updateTransactionState(isTestTransactionIn => isRealTransaction = 'N',
                                        isLocalTransactionIn => true,
                                        fetchConfigVarsIn => true,
                                        fetchOldApproversIn => false,
                                        fetchInsertionsIn => false,
                                        fetchDeletionsIn => false,
                                        fetchAttributeValuesIn => true,
                                        fetchInactiveAttValuesIn => false,
                                        processProductionActionsIn => false,
                                        processProductionRulesIn => true,
                                        updateCurrentApproverListIn => true,
                                        updateOldApproverListIn => false,
                                        processPrioritiesIn => processPriorities = 'Y',
                                        prepareItemDataIn => false,
                                        prepareRuleIdsIn => false,
                                        prepareRuleDescsIn => false,
                                        transactionIdIn => transactionIdIn,
                                        ameApplicationIdIn => applicationIdIn,
                                        fndApplicationIdIn => null,
                                        transactionTypeIdIn => null);
      ame_engine.getAllProductions(productionsOut => productionsList);
      productionsOut := ame_productions_list();
      for i in 1 .. productionsList.count loop
        productionsOut.extend();
        productionsOut(i) := ame_production_name_value_pair(null,null,null,null);
        productionsOut(i).name := productionsList(i).variable_name;
        productionsOut(i).value := productionsList(i).variable_value;
        productionsOut(i).item_class := getItemClassName(productionsList(i).item_class);
        productionsOut(i).item_id := productionsList(i).item_id;

      end loop;
     exception
         When others then
      ame_util.runtimeException(packageNameIn => 'ame_test_utility_pkg',
                                    routineNameIn => 'getTransactionProductions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
           if sqlcode = -20001 then
             errString :=  sqlerrm;
             errString:= substr(errString,11);
           else
             fnd_message.set_name('PER','AME_400692_ENGINE_ERROR');
             errString := fnd_message.get;
           end if;
  end getTransactionProductions;
end ame_test_utility_pkg;

/
