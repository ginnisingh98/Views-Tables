--------------------------------------------------------
--  DDL for Package Body AME_ATTRIBUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATTRIBUTE_PKG" as
/* $Header: ameoattr.pkb 120.1 2006/12/26 13:14:27 avarri noship $ */
  function attributeExists(attributeIdIn in integer) return boolean as
    attributeCount integer;
    begin
      select count(*)
        into attributeCount
        from ame_attributes
        where
          attribute_id = attributeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if attributeCount > 0 then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'attributeExists',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(false);
  end attributeExists;
  function attributeExistsForDiffIC(attributeNameIn in varchar2,
                                          itemClassIdIn in integer) return boolean as
    itemClassId integer;
    begin
      select item_class_id
        into itemClassId
        from ame_attributes
        where
          name = attributeNameIn and
           sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate);
      if(itemClassId <> itemClassIdIn) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'attributeExistsForDiffIC',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end attributeExistsForDiffIC;
/*
AME_STRIPING
  function calculateUseCount(attributeIdIn in integer,
                             applicationIdIn in integer,
                             isStripingAttributeChangeIn in varchar2 default ame_util.booleanFalse,
                             isBecomingStripingAttributeIn in varchar2 default ame_util.booleanFalse) return integer as
*/
  function calculateUseCount(attributeIdIn in integer,
                             applicationIdIn in integer) return integer as
    cursor ruleCursor(applicationIdIn in integer) is
      select rule_id
        from ame_rule_usages
        where
          ame_rule_usages.item_id = applicationIdIn and
          ((sysdate between ame_rule_usages.start_date and
            nvl(ame_rule_usages.end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < ame_rule_usages.start_date and
            ame_rule_usages.start_date < nvl(ame_rule_usages.end_date,
                           ame_rule_usages.start_date + ame_util.oneSecond)));
    ruleCount integer;
    tempCount integer;
    useCount integer;
    begin
      /* Due to the placement of this call within newAttributeUsage, the
         ame_attribute_usages table is not yet updated so we need
         to verify if striping is on and if so, check whether:
         1.  It's a striping attribute that has been set to null or
             (isStripingAttributeChangeIn)
         2.  It's an attribute that is becoming a striping attribute.
             (isBecomingStripingAttributeIn) */
/*
      if(ame_admin_pkg.isStripingOn(applicationIdIn => applicationIdIn) and
        (isStripingAttribute(applicationIdIn => applicationIdIn,
                             attributeIdIn => attributeIdIn) or
         isBecomingStripingAttributeIn = ame_util.booleanTrue) and
        isStripingAttributeChangeIn = ame_util.booleanFalse) then
        select count(*)
          into ruleCount
          from ame_rule_usages
          where
            ame_rule_usages.item_id = applicationIdIn and
            (ame_rule_usages.start_date <= sysdate and
            (ame_rule_usages.end_date is null or sysdate < ame_rule_usages.end_date));
        return(ruleCount);
      end if;
*/
      useCount := 0;
      for tempRule in ruleCursor(applicationIdIn => applicationIdIn) loop
        select count(*)
          into tempCount
          from
            ame_conditions,
            ame_condition_usages
          where
            ame_conditions.attribute_id = attributeIdIn and
            ame_conditions.condition_id = ame_condition_usages.condition_id and
            ame_condition_usages.rule_id = tempRule.rule_id and
            sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
            ((sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < ame_condition_usages.start_date and
            ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
                           ame_condition_usages.start_date + ame_util.oneSecond)));
        if(tempCount > 0) then
          useCount := useCount + 1;
        else
          select count(*)
            into tempCount
            from
              ame_mandatory_attributes,
              ame_actions,
              ame_action_usages
            where
              ame_mandatory_attributes.attribute_id = attributeIdIn and
              ame_mandatory_attributes.action_type_id = ame_actions.action_type_id and
              ame_actions.action_id = ame_action_usages.action_id and
              ame_action_usages.rule_id = tempRule.rule_id and
               sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate) and
               sysdate between ame_actions.start_date and
                 nvl(ame_actions.end_date - ame_util.oneSecond, sysdate) and
              ((sysdate between ame_action_usages.start_date and
                nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate)) or
                (sysdate < ame_action_usages.start_date and
                 ame_action_usages.start_date < nvl(ame_action_usages.end_date,
                           ame_action_usages.start_date + ame_util.oneSecond)));
          if(tempCount > 0) then
            useCount := useCount + 1;
          end if;
        end if;
      end loop;
      return(useCount);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'calculateUseCount',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(Attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end calculateUseCount;
  function getApprovalTypeNames(attributeIdIn in integer) return varchar2 as
    cursor getApprovalTypeNames(attributeIdIn in integer) is
      select
          ame_action_types.name
        from
          ame_action_types,
          ame_mandatory_attributes
        where
          ame_action_types.action_type_id = ame_mandatory_attributes.action_type_id and
          ame_mandatory_attributes.attribute_id = attributeIdIn and
          sysdate between ame_action_types.start_date and
                 nvl(ame_action_types.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)
          order by name;
    tempCount integer;
    approvalTypeNames varchar2(500);
    begin
      tempCount := 1;
      for getApprovalTypeNamesRec in getApprovalTypeNames(attributeIdIn => attributeIdIn) loop
        if tempCount = 1 then
          approvalTypeNames := getApprovalTypeNamesRec.name;
          tempCount := tempCount + 1;
        else
          approvalTypeNames := approvalTypeNames ||', '|| getApprovalTypeNamesRec.name;
          tempCount := tempCount + 1;
        end if;
      end loop;
      return(approvalTypeNames);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getApprovalTypeNames',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn ||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getApprovalTypeNames;
  function getApproverTypeId(attributeIdIn in integer) return integer as
    approverTypeId integer;
    begin
      select approver_type_id
        into approverTypeId
        from ame_attributes
        where
          attribute_id = attributeIdIn and
          sysdate between ame_attributes.start_date and
            nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate);
      return(approverTypeId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getApproverTypeId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn ||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getApproverTypeId;
  function getAttributeConditionCnt(attributeIdIn in integer,
                                    conditionTypeIn in varchar2) return integer as
    attributeConditionCnt integer;
    begin
      select count(*)
        into attributeConditionCnt
        from ame_attributes,
             ame_conditions
        where
          ame_attributes.attribute_id = ame_conditions.attribute_id and
          ame_attributes.attribute_id = attributeIdIn and
          ame_conditions.condition_type = conditionTypeIn and
          sysdate between ame_attributes.start_date and
            nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_conditions.start_date and
            nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate);
      return(attributeConditionCnt);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getAttributeConditionCnt',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn ||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getAttributeConditionCnt;
  function getAttributeConditionInUseCnt(attributeIdIn in integer,
                                         conditionTypeIn in varchar2,
                                         ruleIdIn in integer) return integer as
    attributeConditionInUseCnt integer;
    begin
      select count(*)
        into attributeConditionInUseCnt
        from ame_attributes,
             ame_conditions,
             ame_rules,
             ame_condition_usages
        where
          ame_attributes.attribute_id = ame_conditions.attribute_id and
          ame_conditions.condition_id = ame_condition_usages.condition_id and
          ame_rules.rule_id = ame_condition_usages.rule_id and
          ame_rules.rule_id = ruleIdIn and
          ame_attributes.attribute_id = attributeIdIn and
          ame_conditions.condition_type = conditionTypeIn and
          sysdate between ame_attributes.start_date and
            nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_conditions.start_date and
            nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
          ((sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
          (sysdate < ame_condition_usages.start_date and
            ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
                                         ame_condition_usages.start_date + ame_util.oneSecond))) and
          ((sysdate between ame_rules.start_date and
              nvl(ame_rules.end_date - ame_util.oneSecond, sysdate)) or
           (sysdate < ame_rules.start_date and
              ame_rules.start_date < nvl(ame_rules.end_date,
                               ame_rules.start_date + ame_util.oneSecond)));
      return(attributeConditionInUseCnt);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getAttributeConditionInUseCnt',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn ||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getAttributeConditionInUseCnt;
  function getAttributeNames(actionTypeIdIn in integer) return varchar2 as
    cursor getAttributeNames(actionTypeIdIn in integer) is
      select ame_attributes.name
        from ame_attributes,
             ame_mandatory_attributes
        where
          ame_attributes.attribute_id = ame_mandatory_attributes.attribute_id and
          ame_mandatory_attributes.action_type_id = actionTypeIdIn and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)
        order by ame_attributes.name;
    tempCount integer;
    attributeNames varchar2(500);
    begin
      tempCount := 1;
      for getAttributeNamesRec in getAttributeNames(actionTypeIdIn => actionTypeIdIn) loop
        if tempCount = 1 then
          attributeNames := getAttributeNamesRec.name;
          tempCount := tempCount + 1;
        else
          attributeNames := attributeNames ||', '|| getAttributeNamesRec.name;
          tempCount := tempCount + 1;
        end if;
      end loop;
      return(attributeNames);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getAttributeNames',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn ||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end getAttributeNames;
  function getDescription(attributeIdIn in integer) return varchar2 as
    description ame_attributes.description%type;
    begin
      select description
        into description
        from ame_attributes
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(description);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getDescription',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getDescription;
  function getIdByName(attributeNameIn in varchar2) return integer as
    attributeId integer;
    begin
      select attribute_id
        into attributeId
        from ame_attributes
        where
          name = upper(attributeNameIn) and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(attributeId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getIdByName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute name ' ||
                                                        attributeNameIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getIdByName;
  function getItemClassId(attributeIdIn in integer) return integer as
    itemClassId ame_attributes.item_class_id%type;
    begin
      select item_class_id
        into itemClassId
        from ame_attributes
        where
          attribute_id = attributeIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(itemClassId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getItemClassId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getItemClassId;
  function getLineItem(attributeIdIn in integer) return varchar2 as
    lineItem ame_attributes.line_item%type;
    begin
      select line_item
        into lineItem
        from ame_attributes
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(lineItem);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getLineItem',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(ame_util.booleanFalse);
  end getLineItem;
  function getName(attributeIdIn in integer) return varchar2 as
    name ame_attributes.name%type;
    begin
      select name
        into name
        from ame_attributes
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(name);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getName;
  function getQueryString(attributeIdIn in integer,
                          applicationIdIn in integer) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    queryString ame_attribute_usages.query_string%type;
    begin
      select query_string
        into queryString
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(queryString);
      exception
        when no_data_found then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                messageNameIn   => 'AME_400149_ATT_TTY_NO_USAGE',
                tokenNameOneIn  => 'ATTRIBUTE',
                tokenValueOneIn => getName(attributeIdIn => attributeIdIn),
                tokenNameTwoIn  => 'APPLICATION',
                tokenValueTwoIn => ame_admin_pkg.getApplicationName(applicationIdIn => applicationIdIn));
            ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                      routineNameIn     => 'getQueryString',
                                      exceptionNumberIn => errorCode,
                                      exceptionStringIn => errorMessage);
            raise_application_error(errorCode,
                                    errorMessage);
            return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getQueryString',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getQueryString;
  function getStartDate(attributeIdIn in integer) return date as
    startDate date;
    begin
      select start_date
        into startDate
        from ame_attributes
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(startDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getStartDate;
  function getStaticUsage(attributeIdIn in integer,
                          applicationIdIn in integer) return varchar2 as
    staticUsage ame_attribute_usages.is_static%type;
    begin
      select is_static
        into staticUsage
        from ame_attribute_usages
        where attribute_id = attributeIdIn and
              application_id = applicationIdIn and
               sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(staticUsage);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getStaticUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getStaticUsage;
  function getUseCount(attributeIdIn in integer,
                       applicationIdIn in integer) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    useCount ame_attribute_usages.use_count%type;
    begin
      select use_count
        into useCount
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(useCount);
      exception
        when no_data_found then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                messageNameIn   => 'AME_400149_ATT_TTY_NO_USAGE',
                tokenNameOneIn  => 'ATTRIBUTE',
                tokenValueOneIn => getName(attributeIdIn => attributeIdIn),
                tokenNameTwoIn  => 'APPLICATION',
                tokenValueTwoIn => ame_admin_pkg.getApplicationName(applicationIdIn => applicationIdIn));
            ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                      routineNameIn     => 'getUseCount',
                                      exceptionNumberIn => errorCode,
                                      exceptionStringIn => errorMessage);
            raise_application_error(errorCode,
                                    errorMessage);
            return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getUseCount',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getUseCount;
  function getUserEditable(attributeIdIn in integer,
                           applicationIdIn in integer) return varchar2 as
    errorCode integer;
    errorMessage ame_util.longestStringType;
    userEditable ame_attribute_usages.user_editable%type;
    begin
      select user_editable
        into userEditable
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(userEditable);
      exception
        when no_data_found then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                messageNameIn   => 'AME_400149_ATT_TTY_NO_USAGE',
                tokenNameOneIn  => 'ATTRIBUTE',
                tokenValueOneIn => getName(attributeIdIn => attributeIdIn),
                tokenNameTwoIn  => 'APPLICATION',
                tokenValueTwoIn => ame_admin_pkg.getApplicationName(applicationIdIn => applicationIdIn));
            ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                      routineNameIn     => 'getUserEditable',
                                      exceptionNumberIn => errorCode,
                                      exceptionStringIn => errorMessage);
            raise_application_error(errorCode,
                                    errorMessage);
            return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getUserEditable',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getUserEditable;
  function getChildVersionStartDate(attributeIdIn in integer,
                                    applicationIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getChildVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getChildVersionStartDate;
  function getParentVersionStartDate(attributeIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_attributes
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getParentVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getParentVersionStartDate;
  function getType(attributeIdIn in integer) return varchar2 as
    attributeType ame_attributes.attribute_type%type;
    begin
      select attribute_type
        into attributeType
        from ame_attributes
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(attributeType);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getType;
  function inputToCanonStaticCurUsage(attributeIdIn in integer,
                                      applicationIdIn in integer,
                                      queryStringIn varchar2) return varchar2 as
    amount ame_util.attributeValueType;
    conversionType ame_util.attributeValueType;
    convTypeException exception;
    curCodeException exception;
    currencyCode ame_util.attributeValueType;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    begin
      /*
        The ame_util.parseStaticCurAttValue procedure parses the usage, if it is parse-able;
        but it doesn't validate the individual values, or convert the amount to canonical format.
      */
      ame_util.parseStaticCurAttValue(applicationIdIn => applicationIdIn,
                                      attributeIdIn => attributeIdIn,
                                      attributeValueIn => queryStringIn,
                                      amountOut => amount,
                                      localErrorIn => true,
                                      currencyOut => currencyCode,
                                      conversionTypeOut => conversionType);
      /* ame_util.inputNumStringToCanonNumString validates and formats the amount. */
      amount := ame_util.inputNumStringToCanonNumString(inputNumberStringIn => amount,
                                                        currencyCodeIn => currencyCode);
      if not ame_util.isCurrencyCodeValid(currencyCodeIn => currencyCode) then
        raise curCodeException;
      end if;
      if not ame_util.isConversionTypeValid(conversionTypeIn => conversionType) then
        raise convTypeException;
      end if;
      return(amount || ',' || currencyCode || ',' || conversionType);
      exception
        when convTypeException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400150_ATT_STA_CONV_INV');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'inputToCanonStaticCurUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage); /* Runtime code doesn't validate input. */
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when curCodeException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400151_ATT_STA_CURR_INV');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'inputToCanonStaticCurUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage); /* Runtime code doesn't validate input. */
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'inputToCanonStaticCurUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm); /* Runtime code doesn't validate input. */
          raise;
          return(null);
  end inputToCanonStaticCurUsage;
  function hasUsage(attributeIdIn in integer,
                    applicationIdIn in integer) return boolean as
    attributeCount integer;
    begin
      select count(*)
        into attributeCount
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id <> applicationIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(attributeCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'hasUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end hasUsage;
/*
AME_STRIPING
  function isAStripingAttribute(applicationIdIn in integer,
                                attributeIdIn in integer) return boolean as
    stripingAttributeIds ame_util.idList;
    useCount integer;
    begin
      select
      to_number(value_1),
      to_number(value_2),
      to_number(value_3),
      to_number(value_4),
      to_number(value_5)
      into
        stripingAttributeIds(1),
        stripingAttributeIds(2),
        stripingAttributeIds(3),
        stripingAttributeIds(4),
        stripingAttributeIds(5)
      from ame_stripe_sets
        where
          application_id = applicationIdIn and
          stripe_set_id = 0 and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      for i in 1..5 loop
        if(stripingAttributeIds(i) = attributeIdIn) then
          return(true);
        end if;
      end loop;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_attribute_pkg',
                                    routineNameIn => 'isAStripingAttribute',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true);
    end isAStripingAttribute;
*/
  function isInUse(attributeIdIn in integer) return boolean as
    useCount integer;
    begin
      select count(*)
        into useCount
        from
          ame_conditions
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'isInUse',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isInUse;
  function isInUseByApplication(attributeIdIn in integer,
                                applicationIdIn in integer) return boolean as
    useCount integer;
    begin
      select use_count
        into useCount
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(useCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when no_data_found then
          rollback;
          return(false);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'isInUseByApplication',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isInUseByApplication;
  function isLineItem(attributeIdIn in integer) return boolean as
    lineItemCount integer;
    begin
      select count(*)
        into lineItemCount
        from ame_attributes
        where
          attribute_id = attributeIdIn and
          line_item = ame_util.booleanTrue and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if lineItemCount > 0 then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'isLineItem',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(false);
    end isLineItem;
  function isMandatory(attributeIdIn in integer) return boolean is
    mandatoryCount integer;
    begin
      select count(*)
        into mandatoryCount
        from ame_mandatory_attributes
        where action_type_id = -1 and
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if mandatoryCount > 0 then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'isMandatory',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true);
    end isMandatory;
  function isNonHeaderAttributeItem(attributeIdIn in integer) return boolean as
    itemClassId integer;
    begin
      select item_class_id
        into itemClassId
        from ame_attributes
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate);
      if(itemClassId <> ame_admin_pkg.getItemClassIdByName(itemClassNameIn =>
                                                            ame_util.headerItemClassName)) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'isNonHeaderAttributeItem',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(false);
    end isNonHeaderAttributeItem;
  function isRequired(attributeIdIn in integer) return boolean is
    requiredCount integer;
    begin
      select count(*)
        into requiredCount
        from ame_mandatory_attributes
        where
          action_type_id <> -1 and
          attribute_id = attributeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if requiredCount > 0 then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'isRequired',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                       attributeIdIn||
                                                       ') ' ||
                                                       sqlerrm);
          raise;
          return(true);
    end isRequired;
  function isSeeded(attributeIdIn in integer) return boolean as
    createdByValue integer;
    begin
      select created_by
        into createdByValue
        from ame_attributes
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(createdByValue = 1) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_attribute_pkg',
                                    routineNameIn => 'isSeeded',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isSeeded;
/*
AME_STRIPING
  function isStripingAttribute(applicationIdIn in integer,
                               attributeIdIn in integer) return boolean as
    isStripingAttribute ame_attribute_usages.is_striping_attribute%type;
    begin
      select is_striping_attribute
        into isStripingAttribute
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      if(isStripingAttribute = ame_util.booleanTrue) then
        return(true);
      end if;
      return(false);
      exception
        when no_data_found then
          rollback;
          return(false);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_attribute_pkg',
                                    routineNameIn => 'isStripingAttribute',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true);
    end isStripingAttribute;
*/
  function nameExists(nameIn in varchar2) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from ame_attributes
        where
          name = upper(nameIn) and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(tempCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'nameExists',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true); /* conservative:  avoids possibility of re-creation of existing name */
    end nameExists;
  function new(nameIn in varchar2,
               typeIn in varchar2,
               descriptionIn in varchar2,
               itemClassIdIn in integer,
               approverTypeIdIn in integer default null,
               finalizeIn in boolean default false,
               newStartDateIn in date default null,
               attributeIdIn in integer default null,
               createdByIn in integer default null) return integer as
    attributeExistsException exception;
    attributeId integer;
    attributeName ame_attributes.name%type;
    createdBy integer;
    currentUserId integer;
    descriptionLengthException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    lineItem varchar2(1);
    nameLengthException exception;
    typeLengthException exception;
    processingDate date;
    tempCount integer;
    begin
      attributeName := upper(trim(trailing ' ' from nameIn));
      processingDate := sysdate;
      begin
        select attribute_id
          into attributeId
          from ame_attributes
          where
            (attributeIdIn is null or attribute_id <> attributeIdIn) and
            name = attributeName and
             sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
        if attributeId is not null then
          raise attributeExistsException;
        end if;
        exception
          when no_data_found then null;
      end;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_attributes',
                                    columnNameIn => 'name',
                                    argumentIn => attributeName)) then
        raise nameLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_attributes',
                                    columnNameIn => 'attribute_type',
                                    argumentIn => typeIn)) then
        raise typeLengthException;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_attributes',
                                    columnNameIn => 'description',
                                    argumentIn => descriptionIn)) then
        raise descriptionLengthException;
      end if;
      /*
      If any version of the object has created_by = 1, all versions,
      including the new version, should.  This is a failsafe way to check
      whether previous versions of an already end-dated object had
      created_by = 1.
      */
      currentUserId := ame_util.getCurrentUserId;
      if(attributeIdIn is null) then
                          if(createdByIn is null) then
          createdBy := currentUserId;
                                else
          createdBy := createdByIn;
                                end if;
        select ame_attributes_s.nextval into attributeId from dual;
      else
        attributeId := attributeIdIn;
        select count(*)
         into tempCount
         from ame_attributes
           where
             attribute_id = attributeId and
             created_by = ame_util.seededDataCreatedById;
        if(tempCount > 0) then
          createdBy := ame_util.seededDataCreatedById;
                          elsif(createdByIn is null) then
          createdBy := currentUserId;
                                else
          createdBy := createdByIn;
        end if;
      end if;
      insert into ame_attributes(attribute_id,
                                 name,
                                 attribute_type,
                                 created_by,
                                 creation_date,
                                 last_updated_by,
                                 last_update_date,
                                 last_update_login,
                                 start_date,
                                 end_date,
                                 description,
                                 line_item,
                                 approver_type_id,
                                 item_class_id)
        values(attributeId,
               attributeName,
               typeIn,
               createdBy,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               nvl(newStartDateIn, processingDate),
               null,
               descriptionIn,
               null,
               approverTypeIdIn,
               itemClassIdIn);
      if(finalizeIn) then
        commit;
      end if;
      return(attributeId);
      exception
        when attributeExistsException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400152_ATT_NAME_EXISTS');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when nameLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
               messageNameIn => 'AME_400153_ATT_NAME_LONG',
               tokenNameOneIn  => 'COLUMN_LENGTH',
               tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_attributes',
                                                    columnNameIn => 'name'));
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when typeLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400154_ATT_TYPE_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_attributes',
                                                     columnNameIn => 'attribute_type'));
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when descriptionLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400155_ATT_DESC_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_attributes',
                                                     columnNameIn => 'description'));
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'new',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
           return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'new',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end new;
  function usageIsUserEditable(attributeIdIn in integer,
                               applicationIdIn in integer) return boolean as
    isEditable varchar2(1);
    begin
      if not isSeeded(attributeIdIn => attributeIdIn) then
        return(true);
      end if;
      select user_editable
        into isEditable
        from ame_attribute_usages
        where attribute_id = attributeIdIn and
              application_id = applicationIdIn and
               sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if isEditable = ame_util.booleanTrue then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'usageIsUserEditable',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(false);
    end usageIsUserEditable;
  procedure change(attributeIdIn in integer,
                   applicationIdIn in integer default null,
                   nameIn in varchar2,
                   typeIn in varchar2,
                   startDateIn in date,
                   endDateIn in date,
                   descriptionIn in varchar2 default null,
                   itemClassIdIn in integer,
                   finalizeIn in boolean default false) as
    approverTypeId integer;
    attributeId integer;
    currentUserId integer;
    begin
      currentUserId := ame_util.getCurrentUserId;
      approverTypeId := getApproverTypeId(attributeIdIn => attributeIdIn);
      update ame_attributes
        set
          last_updated_by = currentUserId,
          last_update_date = endDateIn,
          last_update_login = currentUserId,
          end_date = endDateIn
        where
          attribute_id = attributeIdIn and
          sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate);
      attributeId := new(nameIn => nameIn,
                         typeIn => typeIn,
                         descriptionIn => descriptionIn,
                         attributeIdIn => attributeIdIn,
                         itemClassIdIn => itemClassIdIn,
                         newStartDateIn => startDateIn,
                         approverTypeIdIn => approverTypeId,
                         finalizeIn => false);
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'change',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end change;
  procedure changeAttributeAndUsage(attributeIdIn in integer,
                                    applicationIdIn in integer default null,
                                    staticUsageIn in varchar2,
                                    queryStringIn in varchar2 default null,
                                    nameIn in varchar2 default null,
                                    descriptionIn in varchar2 default null,
                                    parentVersionStartDateIn in date,
                                    childVersionStartDateIn in date,
                                    itemClassIdIn in integer,
                                    finalizeIn in boolean default false) as
    cursor startDateCursor is
      select start_date
        from ame_attributes
        where
          attribute_id = attributeIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    cursor startDateCursor2 is
      select start_date
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    attributeId integer;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    name ame_attributes.name%type;
    attributeType ame_attributes.attribute_type%type;
    description ame_attributes.description%type;
    invalidReferenceException exception;
    newStartAndEndDate date;
    objectVersionNoDataException exception;
    queryString ame_attribute_usages.query_string%type;
    startDate date;
    startDate2 date;
    tempCount integer;
    begin
      /* Try to get a lock on the record. */
      open startDateCursor;
        fetch startDateCursor into startDate;
        if startDateCursor%notfound then
          raise objectVersionNoDataException;
        end if;
        if(parentVersionStartDateIn <> startDate) then
          close startDateCursor;
          raise ame_util.objectVersionException;
        end if;
        open startDateCursor2;
          fetch startDateCursor2 into startDate2;
          if startDateCursor2%notfound then
            raise objectVersionNoDataException;
          end if;
          if(childVersionStartDateIn <> startDate2) then
            close startDateCursor2;
            raise ame_util.objectVersionException;
          end if;
          attributeType := getType(attributeIdIn => attributeIdIn);
          if(staticUsageIn = ame_util.booleanTrue) then
            queryString := ame_util.removeReturns(stringIn => queryStringIn,
                                                  replaceWithSpaces => false);
          else
            queryString := queryStringIn;
          end if;
          /* Check whether the input values match the existing values; if so, just return. */
          select count(*)
            into tempCount
            from
              ame_attributes,
              ame_attribute_usages
            where
              ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
              ame_attributes.attribute_id = attributeIdIn and
              ame_attribute_usages.application_id = applicationIdIn and
              ame_attribute_usages.is_static = staticUsageIn and
              ame_attribute_usages.query_string = queryString and
              (nameIn is null or name = upper(nameIn)) and
              (attributeType is null or upper(attribute_type) = upper(attributeType)) and
              (descriptionIn is null or description = descriptionIn) and
               sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
               sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) ;
          if(tempCount > 0) then
            return;
          end if;
          /* Get current values as necessary for update. */
          if(nameIn is null) then
            name := getName(attributeIdIn => attributeIdIn);
          else
            name := nameIn;
          end if;
          if(descriptionIn is null) then
            description := getDescription(attributeIdIn => attributeIdIn);
          else
            description := descriptionIn;
          end if;
          newStartAndEndDate := sysdate;
          ame_attribute_pkg.change(attributeIdIn => attributeIdIn,
                                   applicationIdIn => applicationIdIn,
                                   nameIn => name,
                                   typeIn => attributeType,
                                   endDateIn => newStartAndEndDate,
                                   startDateIn => newStartAndEndDate,
                                   descriptionIn => description,
                                   itemClassIdIn => itemClassIdIn,
                                   finalizeIn => false);
          ame_attribute_pkg.changeUsage(attributeIdIn => attributeIdIn,
                                        applicationIdIn => applicationIdIn,
                                        staticUsageIn => staticUsageIn,
                                        queryStringIn => queryString,
                                        endDateIn => newStartAndEndDate,
                                        newStartDateIn => newStartAndEndDate,
                                        finalizeIn => false);
        close startDateCursor2;
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
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'changeAttributeAndUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'changeAttributeAndUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when invalidReferenceException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400157_ATT_REF_LINE_ITEM');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'changeAttributeAndUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'changeAttributeAndUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end changeAttributeAndUsage;
/*
AME_STRIPING
  procedure changeUsage(attributeIdIn in integer,
                        applicationIdIn in integer,
                        staticUsageIn in varchar2,
                        queryStringIn in varchar2 default null,
                        endDateIn in date,
                        newStartDateIn in date,
                        lineItemAttributeIn in varchar2,
                        isStripingAttributeIn in varchar2 default null,
                        finalizeIn in boolean default true) as
*/
  procedure changeUsage(attributeIdIn in integer,
                        applicationIdIn in integer,
                        staticUsageIn in varchar2,
                        queryStringIn in varchar2 default null,
                        endDateIn in date,
                        newStartDateIn in date,
                        finalizeIn in boolean default false) as
    attributeName ame_attributes.name%type;
    attributeType ame_attributes.attribute_type%type;
    comma1Location integer;
    comma2Location integer;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    firstReturnLocation integer;
    loweredQueryString varchar2(4000);
    queryString ame_attribute_usages.query_string%type;
    queryStringColumnException exception;
    tempCount integer;
    transactionType ame_calling_apps.application_name%type;
    begin
      attributeType := ame_attribute_pkg.getType(attributeIdIn => attributeIdIn);
      if(staticUsageIn = ame_util.booleanTrue) then
        queryString := ame_util.removeReturns(stringIn => queryStringIn,
                                              replaceWithSpaces => false);
        if(attributeType = ame_util.numberAttributeType) then
          queryString := ame_util.inputNumStringToCanonNumString(inputNumberStringIn => queryString);
        end if;
      else
        queryString := queryStringIn;
        if(attributeType = ame_util.currencyAttributeType) then
          loweredQueryString := lower(queryString);
          if(instrb(loweredQueryString, ',', 1, 2) = 0 or
            instrb(loweredQueryString, ',', 1, 2) > instrb(loweredQueryString, 'from', 1, 1)) then
            raise queryStringColumnException;
          end if;
        end if;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      update ame_attribute_usages
      set
        last_updated_by = currentUserId,
        last_update_date = endDateIn,
        last_update_login = currentUserId,
        end_date = endDateIn
      where
        attribute_id = attributeIdIn and
        application_id = applicationIdIn and
         sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
/*
AME_STRIPING
      newAttributeUsage(attributeIdIn => attributeIdIn,
                        applicationIdIn => applicationIdIn,
                        staticUsageIn => staticUsageIn,
                        queryStringIn => queryString,
                        newStartDateIn => newStartDateIn,
                        lineItemAttributeIn => lineItemAttributeIn,
                        isStripingAttributeIn => isStripingAttributeIn,
                        finalizeIn => finalizeIn);
*/
      newAttributeUsage(attributeIdIn => attributeIdIn,
                        applicationIdIn => applicationIdIn,
                        staticUsageIn => staticUsageIn,
                        updateParentObjectIn => true,
                        queryStringIn => queryString,
                        newStartDateIn => newStartDateIn,
                        finalizeIn => finalizeIn);
      exception
        when queryStringColumnException then
          rollback;
          errorCode := -20001;
          errorMessage := 'The select clause of a currency attribute''s ' ||
                          'usage must select three values: ' ||
                          'amount, currency code, and conversion-type code ';
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'changeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'changeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end changeUsage;
  procedure getActiveAttributes(applicationIdIn in integer,
                                attributeIdsOut out nocopy ame_util.idList,
                                attributeNamesOut out nocopy ame_util.stringList) as
    cursor activeAttributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
        from
          ame_attributes,
          ame_attribute_usages
        where
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          use_count > 0 and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    cursor mandatoryAttributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
        from
          ame_attributes,
          ame_mandatory_attributes
        where
          ame_attributes.attribute_id = ame_mandatory_attributes.attribute_id and
          ame_mandatory_attributes.action_type_id = -1 and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttribute in mandatoryAttributeCursor(applicationIdIn => applicationIdIn) loop
        attributeIdsOut(tempIndex) := tempAttribute.attribute_id;
        attributeNamesOut(tempIndex) := tempAttribute.name;
        tempIndex := tempIndex + 1;
      end loop;
      for tempAttribute in activeAttributeCursor(applicationIdIn => applicationIdIn) loop
        attributeIdsOut(tempIndex) := tempAttribute.attribute_id;
        attributeNamesOut(tempIndex) := tempAttribute.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getActiveAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getActiveAttributes;
  procedure getActiveHeaderAttributes(applicationIdIn in integer,
                                      attributeIdsOut out nocopy ame_util.idList,
                                      attributeNamesOut out nocopy ame_util.stringList) as
    cursor activeAttributeCursor(applicationIdIn in integer,
                                 itemClassIdIn in integer) is
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
        from
          ame_attributes,
          ame_attribute_usages
        where
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_attributes.item_class_id = itemClassIdIn and
          use_count > 0 and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    cursor mandatoryAttributeCursor(applicationIdIn in integer,
                                    itemClassIdIn in integer) is
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
        from
          ame_attributes,
          ame_mandatory_attributes
        where
          ame_attributes.attribute_id = ame_mandatory_attributes.attribute_id and
          ame_attributes.item_class_id = itemClassIdIn and
          ame_mandatory_attributes.action_type_id = -1 and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)
        order by name;
    itemClassId integer;
    tempIndex integer;
    begin
      tempIndex := 1;
      itemClassId :=
        ame_admin_pkg.getItemClassIdByName(itemClassNameIn => ame_util.headerITemClassName);
      for tempAttribute in mandatoryAttributeCursor(applicationIdIn => applicationIdIn,
                                                    itemClassIdIn => itemClassId) loop
        attributeIdsOut(tempIndex) := tempAttribute.attribute_id;
        attributeNamesOut(tempIndex) := tempAttribute.name;
        tempIndex := tempIndex + 1;
      end loop;
      for tempAttribute in activeAttributeCursor(applicationIdIn => applicationIdIn,
                                                 itemClassIdIn => itemClassId) loop
        attributeIdsOut(tempIndex) := tempAttribute.attribute_id;
        attributeNamesOut(tempIndex) := tempAttribute.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getActiveHeaderAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getActiveHeaderAttributes;
  procedure getAllAttributes(attributeIdsOut out nocopy ame_util.stringList,
                             attributeNamesOut out nocopy ame_util.stringList) as
    cursor attributeCursor is
      select attribute_id, name
        from ame_attributes
        where
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
         order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeRec in attributeCursor loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdsOut(tempIndex) := to_char(tempAttributeRec.attribute_id);
        attributeNamesOut(tempIndex) := tempAttributeRec.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getAllAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAllAttributes;
  procedure getApplicationAttributes(applicationIdIn in integer,
                                     attributeIdOut out nocopy ame_util.idList) as
    cursor attributeCursor(applicationIdIn in integer) is
      select attribute_id
        from ame_attribute_usages
        where
          application_id = applicationIdIn and
           sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        order by attribute_id;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn) loop
        attributeIdOut(tempIndex) := tempAttributeUsage.attribute_id;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getApplicationAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(applicationID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getApplicationAttributes;
  procedure getApplicationAttributes2(applicationIdIn in integer,
                                      itemClassIdIn in integer,
                                      attributeIdOut out nocopy ame_util.stringList,
                                      attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id id,
        ame_attributes.name name
        from
          ame_attributes,
          ame_attribute_usages
        where
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attributes.item_class_id = itemClassIdIn and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_attributes.attribute_id not in (select attribute_id
                                              from ame_mandatory_attributes
                                              where action_type_id = ame_util.mandAttActionTypeId and
                                                                                                                                                                                    sysdate between start_date and
                                                                                                                                                                                          nvl(end_date - ame_util.oneSecond, sysdate)) and
          sysdate between ame_attributes.start_date and
                nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_attribute_usages.start_date and
                nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttribute in attributeCursor(applicationIdIn => applicationIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttribute.id);
        attributeNameOut(tempIndex) := tempAttribute.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getApplicationAttributes2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getApplicationAttributes2;
/*
AME_STRIPING
  procedure getApplicationAttributes3(applicationIdIn in integer,
                                      attributeIdsOut out nocopy ame_util.stringList,
                                      attributeNamesOut out nocopy ame_util.stringList) as
    cursor applicationAttributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
        from
          ame_attributes,
          ame_attribute_usages
        where
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_attributes.attribute_type = ame_util.stringAttributeType and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    attributeIdList ame_util.idList;
    tempCount integer;
    tempIndex integer;
    begin
      begin
        select to_number(value_1),
               to_number(value_2),
               to_number(value_3),
               to_number(value_4),
               to_number(value_5)
          into
               attributeIdList(1),
               attributeIdList(2),
               attributeIdList(3),
               attributeIdList(4),
               attributeIdList(5)
          from ame_stripe_sets
          where
            application_id = applicationIdIn and
            stripe_set_id = 0 and
             sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
        exception
          when no_data_found then */ /* striping is not on, user needs to select
                                     from entire string attribute list */
/*
            tempIndex := 1;
            for applicationAttributeRec in applicationAttributeCursor(applicationIdIn => applicationIdIn) loop
              attributeIdsOut(tempIndex) := to_char(applicationAttributeRec.attribute_id);
              attributeNamesOut(tempIndex) := applicationAttributeRec.name;
              tempIndex := tempIndex + 1;
            end loop;
            return;
      end;
      if(attributeIdList(5) is not null)then
        tempCount := 5;
      elsif(attributeIdList(4) is not null)then
        tempCount := 4;
      elsif(attributeIdList(3) is not null)then
        tempCount := 3;
      elsif(attributeIdList(2) is not null)then
        tempCount := 2;
      else
        tempCount := 1;
      end if;
      tempIndex := 1;
      for applicationAttributeRec in applicationAttributeCursor(applicationIdIn => applicationIdIn) loop
        for i in 1..tempCount loop
          if(applicationAttributeRec.attribute_id = attributeIdList(i)) then
            exit;
          elsif(applicationAttributeRec.attribute_id <> attributeIdList(i) and
                i = tempCount) then
            attributeIdsOut(tempIndex) := to_char(applicationAttributeRec.attribute_id);
            attributeNamesOut(tempIndex) := applicationAttributeRec.name;
            tempIndex := tempIndex + 1;
          end if;
        end loop;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_attribute_pkg',
                                    routineNameIn => 'getApplicationAttributes3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          attributeIdsOut := ame_util.emptyStringList;
          attributeNamesOut := ame_util.emptyStringList;
          raise;
    end getApplicationAttributes3;
*/
  procedure getAttributes(applicationIdIn in integer,
                          ruleTypeIn in integer,
                          lineItemIn in varchar2 default ame_util.booleanFalse,
                          attributeIdOut out nocopy ame_util.stringList,
                          attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer,
                           ruleTypeIn in integer,
                           lineItemIn in varchar2) is
      /* the distinct below is necessary to select a distinct list of attribute
         attribute names that are used within a condition */
      select distinct
        ame_attributes.attribute_id id,
        ame_attributes.name name
        from
          ame_attributes,
          ame_attribute_usages,
          ame_conditions
        where
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_conditions.attribute_id = ame_attributes.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          nvl(ame_attributes.line_item, ame_util.booleanFalse) = lineItemIn and
          ame_conditions.condition_type = decode(ruleTypeIn, 1, ame_util.ordinaryConditionType, 2, ame_util.exceptionConditionType) and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttribute in attributeCursor(applicationIdIn => applicationIdIn,
                                           ruleTypeIn => ruleTypeIn,
                                           lineItemIn => lineItemIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttribute.id);
        attributeNameOut(tempIndex) := tempAttribute.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getAttributes;
  procedure getAttributes2(applicationIdIn in integer,
                           itemClassIdIn in integer,
                           ruleTypeIn in integer,
                           lineItemIn in varchar2 default ame_util.booleanFalse,
                           attributeIdOut out nocopy ame_util.stringList,
                           attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer,
                           itemClassIdIn in integer,
                           ruleTypeIn in integer,
                           lineItemIn in varchar2) is
      /* the distinct below is necessary to select a distinct list of attribute
         attribute names that are used within a condition */
      select distinct
        ame_attributes.attribute_id id,
        ame_attributes.name name
        from
          ame_attributes,
          ame_attribute_usages,
          ame_conditions
        where
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_conditions.attribute_id = ame_attributes.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_attributes.item_class_id = itemClassIdIn and
          nvl(ame_attributes.line_item, ame_util.booleanFalse) = lineItemIn and
          ame_conditions.condition_type = decode(ruleTypeIn, 1, ame_util.ordinaryConditionType, 2, ame_util.exceptionConditionType) and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttribute in attributeCursor(applicationIdIn => applicationIdIn,
                                           itemClassIdIn => itemClassIdIn,
                                           ruleTypeIn => ruleTypeIn,
                                           lineItemIn => lineItemIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttribute.id);
        attributeNameOut(tempIndex) := tempAttribute.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getAttributes2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getAttributes2;
  procedure getAttributes3(applicationIdIn in integer,
                           ruleIdIn in integer,
                           itemClassIdIn in integer,
                           conditionTypeIn in varchar2,
                           ruleTypeIn in integer,
                           attributeIdOut out nocopy ame_util.stringList,
                           attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer,
                           itemClassIdIn in integer,
                           conditionTypeIn in varchar2,
                           ruleTypeIn in integer) is
      /* the distinct below is necessary to select a distinct list of attribute
         attribute names that are used within a condition */
      select distinct
        ame_attributes.attribute_id id,
        ame_attributes.name name
        from
          ame_attributes,
          ame_attribute_usages,
          ame_conditions
        where
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_conditions.attribute_id = ame_attributes.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_attributes.item_class_id = itemClassIdIn and
          ame_conditions.condition_type = conditionTypeIn and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate)
        order by name;
    attributeConditionCount integer;
    attributeConditionsInUseCount integer;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttribute in attributeCursor(applicationIdIn => applicationIdIn,
                                           itemClassIdIn => itemClassIdIn,
                                           conditionTypeIn => conditionTypeIn,
                                           ruleTypeIn => ruleTypeIn) loop
        /* Verify that at least one condition is not in use for the rule. */
        attributeConditionCount :=
          getAttributeConditionCnt(attributeIdIn => tempAttribute.id,
                                   conditionTypeIn => conditionTypeIn);
        attributeConditionsInUseCount :=
          getAttributeConditionInUseCnt(ruleIdIn => ruleIdIn,
                                        conditionTypeIn => conditionTypeIn,
                                        attributeIdIn => tempAttribute.id);
        if(attributeConditionCount > attributeConditionsInUseCount) then
          /* The explicit conversion below lets nocopy work. */
          attributeIdOut(tempIndex) := to_char(tempAttribute.id);
          attributeNameOut(tempIndex) := tempAttribute.name;
          tempIndex := tempIndex + 1;
        end if;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getAttributes3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getAttributes3;
  procedure getAttributeConditions(attributeIdIn in integer,
                                   conditionIdListOut out nocopy ame_util.idList) as
    cursor getConditionsCursor(attributeIdIn in integer) is
      select condition_id
        from ame_conditions
        where
          attribute_id = attributeIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
    tempIndex integer;
    begin
      tempIndex := 1;
      for getConditionsRec in getConditionsCursor(attributeIdIn => attributeIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        conditionIdListOut(tempIndex) := getConditionsRec.condition_id;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getAttributeConditions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getAttributeConditions;
  procedure getAvailReqAttributes(actionTypeIdIn in integer,
                                  attributeIdOut out nocopy ame_util.stringList,
                                  attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(actionTypeIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
      from
        ame_attributes
      where
        ame_attributes.attribute_id not in
        (select attribute_id from ame_mandatory_attributes
         where
           (action_type_id = actionTypeIdIn or
            action_type_id = ame_util.mandAttActionTypeId) and
           sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)) and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttribute in attributeCursor(actionTypeIdIn => actionTypeIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttribute.attribute_id);
        attributeNameOut(tempIndex) := tempAttribute.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getAvailReqAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getAvailReqAttributes;
  procedure getHeaderICAttributes(applicationIdIn in integer,
                                  attributeIdsOut out nocopy ame_util.stringList,
                                  attributeNamesOut out nocopy ame_util.stringList) as
    cursor getHeaderICAttributesCursor(applicationIdIn in integer,
                                       headerItemClassIdIn in integer) is
      select distinct(ame_attributes.attribute_id),
             ame_attributes.name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attributes.item_class_id = headerItemClassIdIn and
        ame_attribute_usages.application_id = applicationIdIn and
        ame_attributes.attribute_id not in
          (select attribute_id from ame_mandatory_attributes
             where
               action_type_id = -1 and
               sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)) and
        sysdate between ame_attributes.start_date and
               nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
               nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    headerItemClassId integer;
    tempIndex integer;
    begin
      headerItemClassId :=
            ame_admin_pkg.getItemClassIdByName(itemClassNameIn =>
                                                 ame_util.headerItemClassName);
      open getHeaderICAttributesCursor(applicationIdIn => applicationIdIn,
                                       headerItemClassIdIn => headerItemClassId);
        fetch getHeaderICAttributesCursor bulk collect
          into attributeIdsOut,
               attributeNamesOut;
      close getHeaderICAttributesCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getHeaderICAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getHeaderICAttributes;
  procedure getMandatoryAttributes(attributeIdOut out nocopy ame_util.stringList,
                                   attributeNameOut out nocopy ame_util.stringList,
                                   attributeTypeOut out nocopy ame_util.stringList,
                                   attributeStartDateOut out nocopy ame_util.stringList) as
    cursor attributeCursor is
      select
        ame_attributes.attribute_id,
        ame_attributes.attribute_type,
        ame_attributes.name,
        ame_attributes.start_date
        from
          ame_attributes,
          ame_mandatory_attributes
        where
          ame_attributes.attribute_id = ame_mandatory_attributes.attribute_id and
          ame_mandatory_attributes.action_type_id = ame_util.mandAttActionTypeId and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNameOut(tempIndex) := tempAttributeUsage.name;
        attributeTypeOut(tempIndex) := tempAttributeUsage.attribute_type;
        attributeStartDateOut(tempIndex) := tempAttributeUsage.start_date;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getMandatoryAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getMandatoryAttributes;
  procedure getMandatoryAttributes2(applicationIdIn in integer,
                                    attributeIdOut out nocopy ame_util.stringList,
                                    attributeNameOut out nocopy ame_util.stringList,
                                    attributeTypeOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.attribute_type,
        ame_attributes.name
        from
          ame_attributes,
          ame_attribute_usages,
          ame_mandatory_attributes
        where
          ame_attributes.attribute_id = ame_mandatory_attributes.attribute_id and
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_mandatory_attributes.action_type_id = ame_util.mandAttActionTypeId and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn) loop
      /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNameOut(tempIndex) := tempAttributeUsage.name;
        attributeTypeOut(tempIndex) := tempAttributeUsage.attribute_type;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getMandatoryAttributes2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getMandatoryAttributes2;
  procedure getMandatoryAttributes3(attributeIdOut out nocopy ame_util.stringList,
                                    attributeNameOut out nocopy ame_util.stringList,
                                    attributeTypeOut out nocopy ame_util.stringList,
                                    attributeStartDateOut out nocopy ame_util.stringList) as
    cursor attributeCursor is
      select
        ame_attributes.attribute_id,
        ame_attributes.attribute_type,
        ame_attributes.name,
        ame_attributes.start_date
        from
          ame_attributes,
          ame_mandatory_attributes
        where
          ame_attributes.attribute_id = ame_mandatory_attributes.attribute_id and
          ame_mandatory_attributes.action_type_id = ame_util.mandAttActionTypeId and
          ame_attributes.name not in (ame_util.evalPrioritiesPerItemAttribute,
                                      ame_util.restrictiveItemEvalAttribute) and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNameOut(tempIndex) := tempAttributeUsage.name;
        attributeTypeOut(tempIndex) := tempAttributeUsage.attribute_type;
        attributeStartDateOut(tempIndex) := tempAttributeUsage.start_date;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getMandatoryAttributes3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getMandatoryAttributes3;
  procedure getNonHeaderICAttributes(applicationIdIn in integer,
                                     itemClassIdIn in integer,
                                     attributeIdsOut out nocopy ame_util.stringList,
                                     attributeNamesOut out nocopy ame_util.stringList) as
    cursor getNonHeaderICAttributesCursor(applicationIdIn in integer,
                                          itemClassIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attributes.item_class_id = itemClassIdIn and
        ame_attribute_usages.application_id = applicationIdIn and
        sysdate between ame_attributes.start_date and
               nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
               nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      open getNonHeaderICAttributesCursor(applicationIdIn => applicationIdIn,
                                          itemClassIdIn => itemClassIdIn);
        fetch getNonHeaderICAttributesCursor bulk collect
          into attributeIdsOut,
               attributeNamesOut;
      close getNonHeaderICAttributesCursor;
      exception
        when others then
          rollback;
          attributeIdsOut := ame_util.emptyStringList;
          attributeNamesOut := ame_util.emptyStringList;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getNonHeaderICAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getNonHeaderICAttributes;
  procedure getNonHeaderICAttributes2(applicationIdIn in integer,
                                      itemClassIdIn in integer,
                                      attributeIdsOut out nocopy ame_util.idList,
                                      attributeNamesOut out nocopy ame_util.stringList) as
    cursor getNonHeaderICAttributesCursor(applicationIdIn in integer,
                                          itemClassIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attributes.item_class_id = itemClassIdIn and
        ame_attribute_usages.application_id = applicationIdIn and
        sysdate between ame_attributes.start_date and
               nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
               nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      open getNonHeaderICAttributesCursor(applicationIdIn => applicationIdIn,
                                          itemClassIdIn => itemClassIdIn);
        fetch getNonHeaderICAttributesCursor bulk collect
          into attributeIdsOut,
               attributeNamesOut;
      close getNonHeaderICAttributesCursor;
      exception
        when others then
          rollback;
          attributeIdsOut := ame_util.emptyIdList;
          attributeNamesOut := ame_util.emptyStringList;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getNonHeaderICAttributes2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getNonHeaderICAttributes2;
  procedure getRequiredAttributes(actionTypeIdIn in integer,
                                  attributeIdOut out nocopy ame_util.stringList,
                                  attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(actionTypeIdIn in integer) is
      select ame_attributes.attribute_id,
             ame_attributes.name
        from ame_attributes,
             ame_mandatory_attributes
        where
          ame_attributes.attribute_id = ame_mandatory_attributes.attribute_id and
          ame_mandatory_attributes.action_type_id = actionTypeIdIn and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_mandatory_attributes.start_date and
                 nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttribute in attributeCursor(actionTypeIdIn => actionTypeIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttribute.attribute_id);
        attributeNameOut(tempIndex) := tempAttribute.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getRequiredAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(action type ID ' ||
                                                        actionTypeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getRequiredAttributes;
/*
AME_STRIPING
  procedure getLineItemAttributes(applicationIdIn in integer,
                                  isStripingAttributeIn in varchar2 default ame_util.booleanFalse,
                                  attributeIdOut out nocopy ame_util.stringList,
                                  attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer,
                           isStripingAttributeIn in varchar2) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attribute_usages.application_id = applicationIdIn and
        nvl(ame_attributes.line_item, ame_util.booleanFalse) = ame_util.booleanTrue and
        nvl(ame_attribute_usages.is_striping_attribute, ame_util.booleanFalse) = isStripingAttributeIn and
        (ame_attributes.start_date <= sysdate and
        (ame_attributes.end_date is null or sysdate < ame_attributes.end_date)) and
        (ame_attribute_usages.start_date <= sysdate and
        (ame_attribute_usages.end_date is null or sysdate < ame_attribute_usages.end_date))
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn,
                                                isStripingAttributeIn => isStripingAttributeIn) loop
*/
        /* The explicit conversion below lets nocopy work. */
/*
        attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNameOut(tempIndex) := tempAttributeUsage.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_attribute_pkg',
                                    routineNameIn => 'getLineItemAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getLineItemAttributes;
*/
  procedure getLineItemAttributes(applicationIdIn in integer,
                                  attributeIdOut out nocopy ame_util.stringList,
                                  attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attribute_usages.application_id = applicationIdIn and
        nvl(ame_attributes.line_item, ame_util.booleanFalse) = ame_util.booleanTrue and
        sysdate between ame_attributes.start_date and
               nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
               nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNameOut(tempIndex) := tempAttributeUsage.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getLineItemAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getLineItemAttributes;
  procedure getLineItemAttributes2(applicationIdIn in integer,
                                   attributeIdOut out nocopy ame_util.stringList,
                                   attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attribute_usages.application_id = applicationIdIn and
        nvl(ame_attributes.line_item, ame_util.booleanFalse) = ame_util.booleanTrue and
        sysdate between ame_attributes.start_date and
               nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
               nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNameOut(tempIndex) := tempAttributeUsage.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getLineItemAttributes2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getLineItemAttributes2;
/*
AME_STRIPING
  procedure getNonMandatoryAttributes(applicationIdIn in integer,
                                      isStripingAttributeIn in varchar2 default ame_util.booleanFalse,
                                      attributeIdOut out nocopy ame_util.stringList,
                                      attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer,
                           isStripingAttributeIn in varchar2) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attribute_usages.application_id = applicationIdIn and
        nvl(ame_attributes.line_item, ame_util.booleanFalse) = ame_util.booleanFalse and
        nvl(ame_attribute_usages.is_striping_attribute, ame_util.booleanFalse) = isStripingAttributeIn and
        ame_attributes.attribute_id not in
        (select attribute_id from ame_mandatory_attributes
         where action_type_id = -1 and
          (ame_mandatory_attributes.start_date <= sysdate and
          (ame_mandatory_attributes.end_date is null or sysdate < ame_mandatory_attributes.end_date))) and
          (ame_attributes.start_date <= sysdate and
          (ame_attributes.end_date is null or sysdate < ame_attributes.end_date)) and
          (ame_attribute_usages.start_date <= sysdate and
          (ame_attribute_usages.end_date is null or sysdate < ame_attribute_usages.end_date))
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn,
                                                isStripingAttributeIn => isStripingAttributeIn) loop
*/
        /* The explicit conversion below lets nocopy work. */
/*
        attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNameOut(tempIndex) := tempAttributeUsage.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_attribute_pkg',
                                    routineNameIn => 'getNonMandatoryAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getNonMandatoryAttributes;
*/
  procedure getNonMandatoryAttributes(applicationIdIn in integer,
                                      attributeIdOut out nocopy ame_util.stringList,
                                      attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
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
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNameOut(tempIndex) := tempAttributeUsage.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getNonMandatoryAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getNonMandatoryAttributes;
  procedure getNonMandHeaderAttributes(applicationIdIn in integer,
                                       attributeIdOut out nocopy ame_util.stringList,
                                       attributeNameOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer,
                           headerItemClassIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
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
    headerItemClassId integer;
    tempIndex integer;
    begin
      tempIndex := 1;
      headerItemClassId :=
        ame_admin_pkg.getItemClassIdByName(itemClassNameIn => ame_util.headerItemClassName);
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn,
                                                headerItemClassIdIn => headerItemClassId) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNameOut(tempIndex) := tempAttributeUsage.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getNonMandHeaderAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getNonMandHeaderAttributes;
/*
AME_STRIPING
  procedure getRuleStripingAttributes(applicationIdIn in integer,
                                      attributeIdsOut out nocopy ame_util.stringList) as
    cursor ruleStripingAttributeCursor(applicationIdIn in integer) is
      select
        ame_attributes.attribute_id attribute_id
        from
          ame_attributes,
          ame_attribute_usages
        where
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_attributes.attribute_type = ame_util.stringAttributeType and
          ame_attribute_usages.is_striping_attribute = ame_util.booleanTrue and
           sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by ame_attributes.attribute_id;
      tempIndex integer;
    begin
      tempIndex := 1;
      for ruleStripingAttributeRec in ruleStripingAttributeCursor(applicationIdIn => applicationIdIn) loop
        attributeIdsOut(tempIndex) := to_char(ruleStripingAttributeRec.attribute_id);
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_attribute_pkg',
                                    routineNameIn => 'getRuleStripingAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getRuleStripingAttributes;
*/
  procedure getExistingShareableAttNames(applicationIdIn in integer,
                                         itemClassIdIn in integer,
                                         attributeIdsOut out nocopy ame_util.stringList,
                                         attributeNamesOut out nocopy ame_util.stringList) as
    cursor unusedAttributeCursor(applicationIdIn in integer,
                                 itemClassIdIn in integer) is
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
      from
        ame_attributes
      where
        item_class_id = itemClassIdIn and
        (ame_attributes.start_date <= sysdate and
        (ame_attributes.end_date is null or sysdate < ame_attributes.end_date))
      minus
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attribute_usages.application_id = applicationIdIn and
        sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    cursor unusedAttributeCursor2(applicationIdIn in integer,
                                  itemClassIdIn in integer,
                                  perApproverTypeIdIn in integer,
                                  fndUserApproverTypeIdIn in integer) is
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
      from
        ame_attributes
      where
        item_class_id = itemClassIdIn and
        (ame_attributes.start_date <= sysdate and
        (ame_attributes.end_date is null or sysdate < ame_attributes.end_date))
      minus
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attribute_usages.application_id = applicationIdIn and
        sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
                 nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
      minus
      select
        ame_attributes.attribute_id attribute_id,
        ame_attributes.name name
      from
        ame_attributes
      where
        approver_type_id not in (perApproverTypeIdIn, fndUserApproverTypeIdIn) and
        (ame_attributes.start_date <= sysdate and
        (ame_attributes.end_date is null or sysdate < ame_attributes.end_date))
        order by name;
    allowAllApproverTypes ame_util.stringType;
    fndUserApproverTypeId integer;
    perApproverTypeId integer;
    tempIndex integer;
      begin
        perApproverTypeId :=
          ame_approver_type_pkg.getApproverTypeId(origSystemIn => ame_util.perOrigSystem);
        fndUserApproverTypeId :=
          ame_approver_type_pkg.getApproverTypeId(origSystemIn => ame_util.fndUserOrigSystem);
        allowAllApproverTypes :=
           ame_util.getConfigVar(variableNameIn => ame_util.allowAllApproverTypesConfigVar,
                                applicationIdIn => applicationIdIn);
        tempIndex := 1;
        if(allowAllApproverTypes = ame_util.yes) then
          for tempAttribute in unusedAttributeCursor(applicationIdIn => applicationIdIn,
                                                     itemClassIdIn => itemClassIdIn) loop
            /* The explicit conversion below lets nocopy work. */
            attributeIdsOut(tempIndex) := to_char(tempAttribute.attribute_id);
            attributeNamesOut(tempIndex) := tempAttribute.name;
            tempIndex := tempIndex + 1;
          end loop;
        else
          for tempAttribute in unusedAttributeCursor2(applicationIdIn => applicationIdIn,
                                                      itemClassIdIn => itemClassIdIn,
                                                      perApproverTypeIdIn => perApproverTypeId,
                                                      fndUserApproverTypeIdIn => fndUserApproverTypeId) loop
            /* The explicit conversion below lets nocopy work. */
            attributeIdsOut(tempIndex) := to_char(tempAttribute.attribute_id);
            attributeNamesOut(tempIndex) := tempAttribute.name;
            tempIndex := tempIndex + 1;
          end loop;
        end if;
        exception
          when others then
            rollback;
            ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                      routineNameIn     => 'getExistingShareableAttNames',
                                      exceptionNumberIn => sqlcode,
                                      exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
            raise;
        end getExistingShareableAttNames;
  procedure getSubordinateICAttributes(applicationIdIn in integer,
                                       itemClassIdIn in integer,
                                       attributeIdsOut out nocopy ame_util.stringList,
                                       attributeNamesOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer,
                           itemClassIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attribute_usages.application_id = applicationIdIn and
        ame_attributes.item_class_id = itemClassIdIn and
        sysdate between ame_attributes.start_date and
          nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
          nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn,
                                                itemClassIdIn => itemClassIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdsOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNamesOut(tempIndex) := tempAttributeUsage.name;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          attributeIdsOut := ame_util.emptyStringList;
          attributeNamesOut := ame_util.emptyStringList;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getSubordinateICAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getSubordinateICAttributes;
  procedure getSubordinateICAttributes2(applicationIdIn in integer,
                                        itemClassIdIn in integer,
                                        attributeIdsOut out nocopy ame_util.idList,
                                        attributeNamesOut out nocopy ame_util.stringList,
                                        attributeTypesOut out nocopy ame_util.stringList) as
    cursor attributeCursor(applicationIdIn in integer,
                           itemClassIdIn in integer) is
      select
        ame_attributes.attribute_id,
        ame_attributes.name,
        ame_attributes.attribute_type
      from
        ame_attributes,
        ame_attribute_usages
      where
        ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
        ame_attribute_usages.application_id = applicationIdIn and
        ame_attributes.item_class_id = itemClassIdIn and
        sysdate between ame_attributes.start_date and
          nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_attribute_usages.start_date and
          nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempAttributeUsage in attributeCursor(applicationIdIn => applicationIdIn,
                                                itemClassIdIn => itemClassIdIn) loop
        /* The explicit conversion below lets nocopy work. */
        attributeIdsOut(tempIndex) := to_char(tempAttributeUsage.attribute_id);
        attributeNamesOut(tempIndex) := tempAttributeUsage.name;
        attributeTypesOut (tempIndex) := tempAttributeUsage.attribute_type;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          attributeIdsOut := ame_util.emptyIdList;
          attributeNamesOut := ame_util.emptyStringList;
          attributeTypesOut := ame_util.emptyStringList;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'getSubordinateICAttributes2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end getSubordinateICAttributes2;
/*
AME_STRIPING
  procedure newAttributeUsage(attributeIdIn in integer,
                              applicationIdIn in integer,
                              staticUsageIn in varchar2,
                              queryStringIn in varchar2 default null,
                              newStartDateIn in date default null,
                              lineItemAttributeIn in varchar2,
                              isStripingAttributeIn in varchar2 default null,
                              finalizeIn in boolean default true) as
*/
  procedure newAttributeUsage(attributeIdIn in integer,
                              applicationIdIn in integer,
                              staticUsageIn in varchar2,
                              updateParentObjectIn in boolean,
                              queryStringIn in varchar2 default null,
                              newStartDateIn in date default null,
                              finalizeIn in boolean default false,
                              parentVersionStartDateIn in date default null,
                              createdByIn in integer default null) as
    cursor startDateCursor is
      select start_date
        from ame_attributes
        where
          attribute_id = attributeIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date))
        for update;
    approverTypeId integer;
    attributeDescription ame_attributes.description%type;
    lineItemAttribute varchar2(1);
    attributeId ame_attributes.attribute_id%type;
    attributeName ame_attributes.name%type;
    attributeType ame_attributes.attribute_type%type;
    badCurUsageException exception;
    badStaticDateUsageException exception;
    booleanException exception;
    charMonths ame_util.stringList;
    comma1Location integer;
    comma2Location integer;
    createdBy integer;
    currentUserId integer;
    dateAttribute date;
    dynamicUsageException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    firstReturnLocation integer;
    invalidBooleanValueException exception;
    invalidReferenceException exception;
    itemClassId integer;
/*
AME_STRIPING
    isBecomingStripingAttribute varchar2(1);
    isStripingAttributeChange varchar2(1);
*/
    lineItemIdPlaceholderPosition integer;
    lineItemIdPlaceholderPosition2 integer;
    loweredQueryString varchar2(4000);
    numMonths ame_util.stringList;
    nullQueryStringException exception;
    objectVersionNoDataException exception;
    placeholderException exception;
    queryString ame_attribute_usages.query_string%type;
    queryString1 ame_attribute_usages.query_string%type;
    queryStringLengthException exception;
    queryStringColumnException exception;
    startDate date;
    startDate2 date;
    stringDynamicException exception;
    stringStaticUsageException exception;
    substitutionString ame_util.stringType;
    tempCount integer;
    tempCount2 integer;
    tempInt integer;
    transactionType ame_calling_apps.application_name%type;
    transIdPlaceholderPosition integer;
    transIdPlaceholderPosition2 integer;
    upperLineItemIdPlaceholder varchar2(100);
    upperQueryString ame_attribute_usages.query_string%type;
    upperTransIdPlaceholder varchar2(100);
    usageExistsException exception;
    useCount integer;
    processingDate date;
    begin
      processingDate := sysdate;
      if(finalizeIn) then
        open startDateCursor;
          fetch startDateCursor into startDate;
          if startDateCursor%notfound then
            raise objectVersionNoDataException;
          end if;
          if(parentVersionStartDateIn <> startDate) then
            close startDateCursor;
            raise ame_util.objectVersionException;
          end if;
      end if;
      attributeName := ame_attribute_pkg.getName(attributeIdIn => attributeIdIn);
      attributeType := ame_attribute_pkg.getType(attributeIdIn => attributeIdIn);
      itemClassId := ame_attribute_pkg.getItemClassId(attributeIdIn => attributeIdIn);
      if(staticUsageIn = ame_util.booleanTrue) then /* static usage */
        queryString := ame_util.removeReturns(stringIn => queryStringIn,
                                              replaceWithSpaces => false);
        if(instrb(upper(queryString), upper(ame_util.transactionIdPlaceholder))) > 0 then
          raise placeholderException;
        end if;
        /* Format the static usage correctly. */
        if(attributeType = ame_util.currencyAttributeType) then
          queryString := inputToCanonStaticCurUsage(attributeIdIn => attributeIdIn,
                                                    applicationIdIn => applicationIdIn,
                                                    queryStringIn => queryString);
        elsif(attributeType = ame_util.numberAttributeType) then
          queryString := ame_util.inputNumStringToCanonNumString(inputNumberStringIn => queryString);
        elsif(attributeType = ame_util.stringAttributeType) then
          if(instrb(queryString, '''') > 0) or length(queryString) > ame_util.stringTypeLength then
            raise stringStaticUsageException;
          end if;
        elsif(attributeType = ame_util.booleanAttributeType) then
          if(instrb(upper(queryStringIn),'TRUE') > 0) then
            queryString := 'true';
          elsif(instrb(upper(queryStringIn), 'FALSE') > 0) then
            queryString := 'false';
          else
            raise booleanException;
          end if;
          if(attributeName = ame_util.evalPrioritiesPerItemAttribute) then
            if(queryString = 'true') then
              attributeId := ame_attribute_pkg.getIdByName(attributeNameIn => ame_util.restrictiveItemEvalAttribute);
              queryString1 := ame_attribute_pkg.getQueryString(attributeIdIn => attributeId,
                                                               applicationIdIn => applicationIdIn);
              if(queryString1 is null or queryString1 = 'false') then
                raise invalidBooleanValueException;
              end if;
            end if;
          end if;
        elsif(attributeType = ame_util.dateAttributeType) then
          /* check to make sure the user entered the date in the correct format */
          begin
            if(queryString is not null) then
              numMonths(1) := '01';
              numMonths(2) := '02';
              numMonths(3) := '03';
              numMonths(4) := '04';
              numMonths(5) := '05';
              numMonths(6) := '06';
              numMonths(7) := '07';
              numMonths(8) := '08';
              numMonths(9) := '09';
              numMonths(10) := '10';
              numMonths(11) := '11';
              numMonths(12) := '12';
              charMonths(1) := 'JAN';
              charMonths(2) := 'FEB';
              charMonths(3) := 'MAR';
              charMonths(4) := 'APR';
              charMonths(5) := 'MAY';
              charMonths(6) := 'JUN';
              charMonths(7) := 'JUL';
              charMonths(8) := 'AUG';
              charMonths(9) := 'SEP';
              charMonths(10) := 'OCT';
              charMonths(11) := 'NOV';
              charMonths(12) := 'DEC';
              ame_util.substituteStrings(stringIn => queryString,
                                         targetStringsIn => charMonths,
                                         substitutionStringsIn => numMonths,
                                         stringOut => substitutionString);
              queryString := substitutionString;
              if(instrb(queryString, ':', 1, 5)) = 0 then
                raise badStaticDateUsageException;
              end if;
            end if;
            exception
              when others then
                raise badStaticDateUsageException;
          end;
        end if;
      else /* dynamic usage (actual query string) */
        queryString := queryStringIn;
        if(queryString is null) then
          raise nullQueryStringException;
        end if;
        if(instrb(queryString, ';', 1, 1) > 0) or
          (instrb(queryString, '--', 1, 1) > 0) or
          (instrb(queryString, '/*', 1, 1) > 0) or
          (instrb(queryString, '*/', 1, 1) > 0) then
          raise stringDynamicException;
        end if;
        tempInt := 1;
        upperQueryString := upper(queryStringIn);
        upperTransIdPlaceholder := upper(ame_util.transactionIdPlaceholder);
        loop
          transIdPlaceholderPosition :=
          instrb(upperQueryString, upperTransIdPlaceholder, 1, tempInt);
          if(transIdPlaceholderPosition = 0) then
            exit;
          end if;
          transIdPlaceholderPosition2 :=
          instrb(queryStringIn, ame_util.transactionIdPlaceholder, 1, tempInt);
          if(transIdPlaceholderPosition <> transIdPlaceholderPosition2) then
            raise dynamicUsageException;
          end if;
          tempInt := tempInt + 1;
        end loop;
        if(attributeType = ame_util.currencyAttributeType) then
          comma1Location := instrb(queryString, ',', -1, 2);
          comma2Location := instrb(queryString, ',', -1, 1);
          if(comma1Location = 0 or
            comma2Location = 0 or
            comma1Location < 2 or
            comma2Location < 4) then
/*
              attributeName := ame_attribute_pkg.getName(attributeIdIn => attributeIdIn);
*/
            raise badCurUsageException;
          end if;
        end if;
      end if;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_attribute_usages',
                                    columnNameIn => 'query_string',
                                    argumentIn => queryString)) then
        raise queryStringLengthException;
      end if;
      select count(*)
        into tempCount
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      if(tempCount > 0) then
        raise usageExistsException;
      end if;
        /* Need to check if the striping attribute has been set to null.
           If so, need to let calculateUseCount know because it checks
           to see if it is a striping attribute before the ame_attribute_usages
           gets updated (which is after the call to calculateUseCount below).
           calculateUse check to see if striping is on. */
/*
AME_STRIPING
      if(isStripingAttribute(applicationIdIn => applicationIdIn,
                             attributeIdIn => attributeIdIn) and
        isStripingAttributeIn is null) then */ /* existing striping attribute
                                               has been set to null */
/*
        isStripingAttributeChange := ame_util.booleanTrue;
        isBecomingStripingAttribute := ame_util.booleanFalse;
      elsif(not isStripingAttribute(applicationIdIn => applicationIdIn,
                                    attributeIdIn => attributeIdIn) and
        isStripingAttributeIn is not null) then */ /* attribute is becoming a
                                                   striping attribute */
/*
        isStripingAttributeChange := ame_util.booleanFalse;
        isBecomingStripingAttribute := ame_util.booleanTrue;
      else
        isStripingAttributeChange := ame_util.booleanFalse;
        isBecomingStripingAttribute := ame_util.booleanFalse;
      end if;
      useCount := calculateUseCount(attributeIdIn => attributeIdIn,
                                    applicationIdIn => applicationIdIn,
                                    isStripingAttributeChangeIn => isStripingAttributeChange,
                                    isBecomingStripingAttributeIn => isBecomingStripingAttribute);
      select count(*)
        into tempCount2
        from ame_attribute_usages
          where
            attribute_id = attributeIdIn and
            applicationI_id = applicationIdIn and
            created_by = ame_util.seededDataCreatedById;
      if(tempCount2 > 0) then
        createdBy := ame_util.seededDataCreatedById;
      else
        createdBy := currentUserId;
      end if;
      insert into ame_attribute_usages(attribute_id,
                                       application_id,
                                       query_string,
                                       use_count,
                                       is_static,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
                                       last_update_login,
                                       start_date,
                                       end_date,
                                       user_editable,
                                       is_striping_attribute)
        values(attributeIdIn,
               applicationIdIn,
               queryString,
               useCount,
               staticUsageIn,
               createdBy,
               sysdate,
               currentUserId,
               sysdate,
               currentUserId,
               nvl(newStartDateIn, sysdate),
               null,
               ame_util.booleanTrue,
               isStripingAttributeIn);
*/
      useCount := calculateUseCount(attributeIdIn => attributeIdIn,
                                    applicationIdIn => applicationIdIn);
      startDate2 := nvl(newStartDateIn, sysdate);
        /* parent record was locked above so see if parent has been modified; if so
           raise an error, if not then insert
        */
      /*
      If any version of the object has created_by = 1, all versions,
      including the new version, should.  This is a failsafe way to check
      whether previous versions of an already end-dated object had
      created_by = 1.
      */
      currentUserId := ame_util.getCurrentUserId;
      select count(*)
        into tempCount2
        from ame_attribute_usages
          where
            attribute_id = attributeIdIn and
            application_id = applicationIdIn and
            created_by = ame_util.seededDataCreatedById;
      if(tempCount2 > 0) then
        createdBy := ame_util.seededDataCreatedById;
      elsif(createdByIn is null) then
        createdBy := currentUserId;
                        else
        createdBy := createdByIn;
      end if;
      insert into ame_attribute_usages(attribute_id,
                                       application_id,
                                       query_string,
                                       use_count,
                                       is_static,
                                       created_by,
                                       creation_date,
                                       last_updated_by,
                                       last_update_date,
                                       last_update_login,
                                       start_date,
                                       end_date,
                                       user_editable)
        values(attributeIdIn,
               applicationIdIn,
               queryString,
               useCount,
               staticUsageIn,
               createdBy,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               startDate2,
               null,
               ame_util.booleanTrue);
      if(finalizeIn) then
        if(updateParentObjectIn) then
          attributeDescription := getDescription(attributeIdIn => attributeIdIn);
          approverTypeId := getApproverTypeId(attributeIdIn => attributeIdIn);
          update ame_attributes
            set
              last_updated_by = currentUserId,
              last_update_date = startDate2,
              last_update_login = currentUserId,
              end_date = startDate2
            where
              attribute_id = attributeIdIn and
               sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
          attributeId := new(nameIn => attributeName,
                             typeIn => attributeType,
                             descriptionIn => attributeDescription,
                             attributeIdIn => attributeIdIn,
                             itemClassIdIn => itemClassId,
                             newStartDateIn => startDate2,
                             approverTypeIdIn => approverTypeId,
                             finalizeIn => false,
                             createdByIn => createdByIn);
        close startDateCursor;
        end if;
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
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
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
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when placeholderException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400159_ATT_STAT_NOT_PLC');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when dynamicUsageException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400414_DYNAMIC_ATTR_USAGES');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when nullQueryStringException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400161_ATT_EMPTY_USAGE');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when usageExistsException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400162_ATT_USAGE_EXISTS');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
         when queryStringColumnException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400158_ATT_THREE_VALUES');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when queryStringLengthException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400163_ATT_USAGE_LONG',
            tokenNameOneIn  => 'COLUMN_LENGTH',
            tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_attribute_usages',
                                                       columnNameIn => 'query_string'));
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when invalidBooleanValueException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400322_LIN_ITEM_TRUE_SET');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when invalidReferenceException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                                       messageNameIn => 'AME_400157_ATT_REF_LINE_ITEM');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when badCurUsageException then
          rollback;
          transactionType := ame_admin_pkg.getApplicationName(applicationIdIn => applicationIdIn);
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn   => 'AME_400164_ATT_BAD_STAT_USG',
            tokenNameOneIn  => 'TRANSACTION_TYPE',
            tokenValueOneIn => transactionType,
            tokenNameTwoIn  => 'ATTRIBUTE',
            tokenValueTwoIn => attributeName);
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when stringDynamicException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400165_ATT_DYN_USG_COMM');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when stringStaticUsageException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400166_ATT_STAT_USG_STRING');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when booleanException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400167_ATT_STAT_USG_BOOL');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when badStaticDateUsageException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400168_ATT_STAT_USG_DATE');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newAttributeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end newAttributeUsage;
  procedure newMandatoryAttributes(attributeIdIn in integer,
                                   actionTypeIdIn in integer,
                                   createdByIn in integer default null) as
    /* select every application having a rule that uses the approval type */
       cursor getApplicationId (actionTypeIdIn in integer) is
    /* the distinct is necessary because of the possibility that multiple rules
       within an application will use the specified approval type */
    select distinct ame_rule_usages.item_id
      from ame_action_usages,
         ame_actions,
         ame_rule_usages
      where
        ame_action_usages.action_id = ame_actions.action_id and
        ame_action_usages.rule_id = ame_rule_usages.rule_id and
        ame_actions.action_type_id = actionTypeIdIn and
        ((sysdate between ame_action_usages.start_date and
                 nvl(ame_action_usages.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < ame_action_usages.start_date and
                 ame_action_usages.start_date < nvl(ame_action_usages.end_date,
                              ame_action_usages.start_date + ame_util.oneSecond))) and
        ( sysdate between ame_actions.start_date and
                 nvl(ame_actions.end_date - ame_util.oneSecond, sysdate) ) and
        ((sysdate between ame_rule_usages.start_date and
                 nvl(ame_rule_usages.end_date - ame_util.oneSecond, sysdate)) or
              (sysdate < ame_rule_usages.start_date and
                 ame_rule_usages.start_date < nvl(ame_rule_usages.end_date,
                           ame_rule_usages.start_date + ame_util.oneSecond)));
    cursor applicationCursor(attributeIdIn in integer) is
      select application_id
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate) ;
    applicationCount integer;
    commitData boolean;
    currentUserId integer;
    createdBy integer;
    tempCount integer;
    tempCount1 integer;
    tempIndex integer;
    begin
      select count(*)
        into applicationCount
        from ame_attribute_usages
        where attribute_id = attributeIdIn and
        sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate);
      for getAppRec in getApplicationId(actionTypeIdIn => actionTypeIdIn) loop
      /* for every application that uses the approval type, make sure an
         attribute usage exists for the required attribute */
        select count(*)
          into tempCount1
          from ame_attribute_usages
          where
            attribute_id = attributeIdIn and
            application_id = getAppRec.item_id and
            sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate) ;
        if tempCount1 = 0 then
          raise_application_error(-20001,
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400169_ATT_LACK_QRY_STRING'));
        end if;
      end loop;
        select count(*)
          into tempCount
          from ame_mandatory_attributes
          where
            attribute_id = attributeIdIn and
            action_type_id = actionTypeIdIn and
            sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate) ;
         if tempCount > 0 then
           return;
         end if;
         currentUserId := ame_util.getCurrentUserId;
                                 if(createdByIn is null) then
                                   createdBy := currentUserId;
                                 else
                                   createdBy := createdByIn;
         end if;
         insert into ame_mandatory_attributes
           (attribute_id,
            action_type_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            start_date,
            end_date)
         values
           (attributeIdIn,
            actionTypeIdIn,
            createdBy,
            sysdate,
            currentUserId,
            sysdate,
            currentUserId,
            sysdate,
            null);
      /* Call updateUseCount after creating the new attribute requirements. */
      tempIndex := 1;
      for tempApplication in applicationCursor(attributeIdIn => attributeIdIn) loop
        if(tempIndex = applicationCount)then
          commitData := true;
        else
          commitData := false;
        end if;
        updateUseCount(attributeIdIn => attributeIdIn,
                       applicationIdIn => tempApplication.application_id,
                       finalizeIn => commitData);
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'newMandatoryAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
      end newMandatoryAttributes;
  procedure remove(attributeIdIn in integer,
                   finalizeIn in boolean default false) as
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    inUseException exception;
    processingDate date;
    attributeType ame_attributes.attribute_type%type;
    begin
      processingDate := sysdate;
      currentUserId := ame_util.getCurrentUserId;
      attributeType := getType(attributeIdIn => attributeIdIn);
      if attributeType = ame_util.stringAttributeType then
        update ame_string_values
           set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          condition_id in (select condition_id
                             from ame_conditions
                            where processingDate between start_date and
                                    nvl(end_date - ame_util.oneSecond, processingDate) and
                                  attribute_id = attributeIdIn) and
          processingDate between start_date and
            nvl(end_date - ame_util.oneSecond, processingDate) ;
      end if;
      update ame_conditions
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          attribute_id = attributeIdIn and
          processingDate between start_date and
               nvl(end_date - ame_util.oneSecond, processingDate) ;
      update ame_attributes
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          attribute_id = attributeIdIn and
          processingDate between start_date and
               nvl(end_date - ame_util.oneSecond, processingDate) ;
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'remove',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end remove;
  procedure removeMandatoryAttributes(attributeIdIn in integer,
                                      actionTypeIdIn in integer,
                                      finalizeIn in boolean default true) as
    cursor applicationCursor(attributeIdIn in integer) is
      select application_id
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate) ;
    currentUserId integer;
    processingDate date;
    begin
      processingDate := sysdate;
      currentUserId := ame_util.getCurrentUserId;
      update ame_mandatory_attributes
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          attribute_id = attributeIdIn and
          action_type_id = actionTypeIdIn and
          processingDate between start_date and
               nvl(end_date - ame_util.oneSecond, processingDate) ;
      /* Call updateUseCount after removing the attribute requirements. */
      for tempApplication in applicationCursor(attributeIdIn => attributeIdIn) loop
        updateUseCount(attributeIdIn => attributeIdIn,
                       applicationIdIn => tempApplication.application_id,
                       finalizeIn => finalizeIn);
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'removeMandatoryAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end removeMandatoryAttributes;
  procedure removeUsage(attributeIdIn in integer,
                        parentVersionStartDateIn in date,
                        childVersionStartDateIn in date,
                        applicationIdIn in integer,
                        allowAttributeUsageDeleteIn in boolean default false,
                        finalizeIn in boolean default false,
                        deleteConditionsIn in boolean default false,
                        itemClassIdIn in integer) as
    cursor startDateCursor is
      select start_date
        from ame_attributes
        where
          attribute_id = attributeIdIn and
          sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    cursor startDateCursor2 is
      select start_date
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
               nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    approverTypeId integer;
    attributeId ame_attributes.attribute_id%type;
    attributeDescription ame_attributes.description%type;
    attributeName ame_attributes.name%type;
    attributeType ame_attributes.attribute_type%type;
    conditionIdList ame_util.idList;
    conditionVersionStartDate date;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    inUseException exception;
    isMandatoryException exception;
    lineItem ame_attributes.line_item%type;
    objectVersionNoDataException exception;
    startDate date;
    startDate2 date;
    processingDate date;
/*
AME_STRIPING
    stripingAttributeException exception;
*/
    begin
      processingDate := sysdate;
      /* Try to get a lock on the record. */
      open startDateCursor;
      fetch startDateCursor into startDate;
      if startDateCursor%notfound then
        raise objectVersionNoDataException;
      end if;
      if(parentVersionStartDateIn <> startDate) then
        close startDateCursor;
        raise ame_util.objectVersionException;
      end if;
      open startDateCursor2;
      fetch startDateCursor2 into startDate2;
      if startDateCursor2%notfound then
        raise objectVersionNoDataException;
      end if;
      if(childVersionStartDateIn <> startDate2) then
        close startDateCursor2;
        raise ame_util.objectVersionException;
      end if;
      /* Don't allow deleting usages for mandatory attributes. */
      if not allowAttributeUsageDeleteIn then
         if(isMandatory(attributeIdIn => attributeIdIn)) then
           raise isMandatoryException;
         end if;
      end if;
      /* Don't allow deleting usages for active attributes. */
      if(isInUseByApplication(attributeIdIn => attributeIdIn,
                              applicationIdIn => applicationIdIn)) then
        raise inUseException;
      end if;
/*
AME_STRIPING
        if(isAStripingAttribute(applicationIdIn => applicationIdIn,
                                attributeIdIn => attributeIdIn)) then
          raise stripingAttributeException;
        end if;
*/
      currentUserId := ame_util.getCurrentUserId;
          /* Not active, either not mandatory or allowed to delete, so delete the usage. */
      update ame_attribute_usages
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
          processingDate between start_date and
               nvl(end_date - ame_util.oneSecond, processingDate);
      /*
      If the attribute name is
        (1) not used by any conditions in any rules used by the transaction type
        (2) is not required by any approval type (whether or not a rule uses the approval type, at present)
        (3) is not mandatory delete the attribute (not just the usage).
      */

      if(hasUsage(attributeIdIn => attributeIdIn,
                  applicationIdIn => applicationIdIn) or
         isRequired(attributeIdIn => attributeIdIn) or
         isMandatory(attributeIdIn => attributeIdIn)) then
        attributeName := getName(attributeIdIn => attributeIdIn);
        attributeDescription := getDescription(attributeIdIn => attributeIdIn);
        attributeType := getType(attributeIdIn => attributeIdIn);
        approverTypeId := getApproverTypeId(attributeIdIn => attributeIdIn);
        update ame_attributes
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            attribute_id = attributeIdIn and
            processingDate between start_date and
             nvl(end_date - ame_util.oneSecond, processingDate) ;
        attributeId := new(nameIn => attributeName,
                           typeIn => attributeType,
                           descriptionIn => attributeDescription,
                           attributeIdIn => attributeIdIn,
                           approverTypeIdIn => approverTypeId,
                           finalizeIn => false,
                           itemClassIdIn => itemClassIdIn);
      else
        ame_attribute_pkg.remove(attributeIdIn => attributeIdIn,
                                 finalizeIn => false);
      end if;
      close startDateCursor;
      close startDateCursor2;
      if(finalizeIn) then
        commit;
      end if;
      exception
/*
AME_STRIPING
        when stripingAttributeException then
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          attributeName := getName(attributeIdIn => attributeIdIn);
          errorCode := -20001;
          errorMessage := ame_util.getMessage(applicationShortNameIn => 'PER',
                                              messageNameIn => 'AME_400309_ATT_NAME_STRP_ATTR',
                                              tokenNameOneIn  => 'ATTRIBUTE_NAME',
                                              tokenValueOneIn => attributeName);
          ame_util.runtimeException(packageNameIn => 'ame_attribute_pkg',
                                    routineNameIn => 'removeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
*/
        when isMandatoryException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400170_ATT_MAND_CANT_DEL');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'removeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when inUseException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400171_ATT_IS_IN_USE');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'removeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'removeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when objectVersionNoDataException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'removeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'removeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end removeUsage;
/*
AME_STRIPING
  procedure setStripingAttributesToNull(applicationIdIn in integer,
                                        oldStripedAttributesIn in ame_util.idList default ame_util.emptyIdList,
                                        lastStripingAttributeIn in boolean default false) as
    cursor getStripingAttributesCursor(applicationIdIn in integer) is
      select ame_attribute_usages.attribute_id,
             ame_attribute_usages.is_static,
             ame_attribute_usages.query_string,
             ame_attribute_usages.end_date,
             ame_attributes.line_item
        from ame_attributes,
             ame_attribute_usages
        where
          ame_attributes.attribute_id = ame_attribute_usages.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_attribute_usages.is_striping_attribute = ame_util.booleanTrue and
          (ame_attribute_usages.start_date <= sysdate and
          (ame_attribute_usages.end_date is null or sysdate < ame_attribute_usages.end_date)) and
          (ame_attributes.start_date <= sysdate and
          (ame_attributes.end_date is null or sysdate < ame_attributes.end_date));
    endDate date;
    oldAttributeCount integer;
    startDate varchar2(50);
    stripeSetCount integer;
    stripeSetId ame_stripe_sets.stripe_set_id%type;
    stripeSetIds ame_util.idList;
    versionStartDate date;
    begin
      oldAttributeCount := oldStripedAttributesIn.count;
      for getStripingAttributesRec in
        getStripingAttributesCursor(applicationIdIn => applicationIdIn) loop
        if oldAttributeCount > 0 then
/*
          /* check to see if the attribute is no longer in the new set */
/*
          for i in 1..oldAttributeCount loop
            if(getStripingAttributesRec.attribute_id = oldStripedAttributesIn(i)) then
              endDate := sysdate - ame_util.oneSecond;
              changeUsage(attributeIdIn => getStripingAttributesRec.attribute_id,
                          applicationIdIn => applicationIdIn,
                          staticUsageIn => getStripingAttributesRec.is_static,
                          queryStringIn => getStripingAttributesRec.query_string,
                          endDateIn => endDate,
                          newStartDateIn => sysdate,
                          lineItemAttributeIn => getStripingAttributesRec.line_item,
                          isStripingAttributeIn => ame_util.booleanFalse);
              ame_admin_pkg.removeStripeSetAttributes(applicationIdIn => applicationIdIn,
                                                      attributeIdIn => getStripingAttributesRec.attribute_id);
            end if;
          end loop;
        end if;
      end loop;
      if(oldAttributeCount = 0 or lastStripingAttributeIn) then
        ame_admin_pkg.getStripeSetIds(applicationIdIn => applicationIdIn,
                                      stripeSetIdsOut => stripeSetIds);
        ame_admin_pkg.removeAllStripeSets(applicationIdIn => applicationIdIn,
                                          deleteStripeSetIdZeroIn => lastStripingAttributeIn);
        ame_rule_pkg.removeRuleStripeSet(stripeSetIdsIn => stripeSetIds);
        stripeSetId := ame_util.getCurrentStripeSetId(applicationIdIn => applicationIdIn);
        owa_util.mime_header('text/html', FALSE);
        owa_cookie.remove(name => ame_util.getStripeSetCookieName(applicationIdIn => applicationIdIn),
                          val => to_char(stripeSetId));
        owa_util.http_header_close;
      end if;
      commit;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_attribute_pkg',
                                    routineNameIn => 'setStripingAttributesToNull',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end setStripingAttributesToNull;
*/
  procedure updateUseCount(attributeIdIn in integer,
                           applicationIdIn in integer,
                           finalizeIn in boolean default true) as
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
/*
AME_STRIPING
    stripingAttribute ame_attribute_usages.is_striping_attribute%type;
*/
    lineItem ame_attributes.line_item%type;
    nullQueryException exception;
    queryString ame_attribute_usages.query_string%type;
    result boolean;
    staticUsage ame_attribute_usages.is_static%type;
    useCount integer;
    processingDate date;
    begin
      processingDate := sysdate;
      queryString := getQueryString(attributeIdIn => attributeIdIn,
                                    applicationIdIn => applicationIdIn);
      staticUsage := ame_attribute_pkg.getStaticUsage(attributeIdIn => attributeIdIn,
                                                      applicationIdIn => applicationIdIn);
/*
AME_STRIPING
      if(isStripingAttribute(attributeIdIn => attributeIdIn,
                             applicationIdIn => applicationIdIn)) then
        stripingAttribute := ame_util.booleanTrue;
      else
        stripingAttribute := ame_util.booleanFalse;
      end if;
*/
      if(queryString is null and
         staticUsage = ame_util.booleanFalse) then
        raise nullQueryException;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      useCount := calculateUseCount(attributeIdIn   => attributeIdIn,
                                    applicationIdIn => applicationIdIn);
      update ame_attribute_usages
      set use_count = useCount
      where
        application_id = applicationIdIn and
        attribute_id   = attributeIdIn and
        processingDate between start_date and
           nvl(end_date - ame_util.oneSecond, processingDate);
      /* newAttributeUsage calls calculateUseCount to get the new use_count value. */
/*
AME_STRIPING
      newAttributeUsage(attributeIdIn => attributeIdIn,
                        applicationIdIn => applicationIdIn,
                        staticUsageIn => staticUsage,
                        queryStringIn => queryString,
                        lineItemAttributeIn => lineItem,
                        isStripingAttributeIn => stripingAttribute,
                        finalizeIn => finalizeIn);
*/
      exception
        when nullQueryException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400172_ATT_NULL_ATT_USAGE');
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'updateUseCount',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                    routineNameIn     => 'updateUseCount',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(attribute ID ' ||
                                                        attributeIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end updateUseCount;
  procedure updateUseCount2(ruleIdIn in integer,
                            applicationIdIn in integer) as
    attributeIds ame_util.idList;
    upperLimit integer;
    useCount integer;
    processingDate date;
    begin
      processingDate := sysdate;
      ame_rule_pkg.getRequiredAttributes(ruleIdIn => ruleIdIn,
                                         attributeIdsOut => attributeIds);
      upperLimit := attributeIds.count;
      for i in 1 .. upperLimit loop
        useCount := to_number(getUseCount(attributeIdIn => attributeIds(i),
                                          applicationIdIn => applicationIdIn));
        update ame_attribute_usages
          set use_count = useCount - 1
          where
            application_id = applicationIdIn and
            attribute_id = attributeIds(i) and
            processingDate between start_date and
               nvl(end_date - ame_util.oneSecond, processingDate) ;
      end loop;
      commit;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn     => 'ame_attribute_pkg',
                                  routineNameIn     => 'updateUseCount2',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => '(rule ID ' ||
                                                        ruleIdIn||
                                                        ') ' ||
                                                        sqlerrm);
        raise;
  end updateUseCount2;
end ame_attribute_pkg;

/
