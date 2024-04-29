--------------------------------------------------------
--  DDL for Package Body AME_ADMIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ADMIN_PKG" as
/* $Header: ameoadmi.pkb 120.2 2006/12/26 13:28:43 avarri noship $ */
  function arePrioritiesDisabled(applicationIdIn in integer) return boolean is
  begin
    if(ame_util.getConfigVar(variableNameIn => ame_util.rulePriorityModesConfigVar,
                             applicationIdIn => applicationIdIn) =
      'disabled:disabled:disabled:disabled:disabled:disabled:disabled:disabled') then
      return(true);
    end if;
    return(false);
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                  routineNameIn => 'arePrioritiesDisabled',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        raise;
        return(true);
  end arePrioritiesDisabled;
  function canHaveItemAttributes(applicationIdIn in integer,
                                 itemClassIdIn in integer) return boolean is
    itemCount integer;
    itemIdQuery ame_calling_apps.line_item_id_query%type;
    begin
      select item_id_query
        into itemIdQuery
        from
          ame_item_class_usages
        where
          application_id = applicationIdIn and
          item_class_id = itemClassIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
      if itemIdQuery is null then
        return(false);
      end if;
      return(true);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'canHaveItemAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end canHaveItemAttributes;
  function getChildVersionStartDate(itemClassIdIn in integer,
                                    applicationIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_item_class_usages
        where
          item_class_id = itemClassIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getChildVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getChildVersionStartDate;
/*
AME_STRIPING
  function doesStripeSetIdExist(stripeSetIdIn in integer) return boolean as
    stripeSetCount integer;
    begin
      select count(*)
        into stripeSetCount
        from ame_stripe_sets
        where
          stripe_set_id = stripeSetIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      if(stripeSetCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'doesStripeSetIdExist',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end doesStripeSetIdExist;
*/
  function getEqualityConditionId(attributeIdIn in integer,
                                  stringValueIn in varchar2) return integer as
    conditionId ame_conditions.condition_id%type;
    begin
      select ame_conditions.condition_id
        into conditionId
        from ame_conditions,
             ame_string_values
        where
          ame_conditions.condition_id = ame_string_values.condition_id and
          ame_conditions.condition_type = ame_util.ordinaryConditionType and
          ame_conditions.attribute_id = attributeIdIn and
          ame_string_values.string_value = stringValueIn and
          sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_string_values.start_date and
                 nvl(ame_string_values.end_date - ame_util.oneSecond, sysdate) ;
        return(conditionId);
      exception
        when no_data_found then
          return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getEqualityConditionId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getEqualityConditionId;
  function getApplicationId(fndAppIdIn in integer,
                            transactionTypeIdIn in varchar2) return integer as
    appId integer;
    begin
      select application_id
        into appId
        from ame_calling_apps
        where
          fnd_application_id = fndAppIdIn and
          ((transaction_type_id is null and transactionTypeIdIn is null) or
          transaction_type_id = transactionTypeIdIn) and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
        return(appId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getApplicationId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApplicationId;
  function getApplicationIdByName(nameIn in varchar2) return integer as
    appId integer;
    begin
      select application_id
        into appId
        from ame_calling_apps
        where
          application_name = nameIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
        return(appId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getApplicationIdByName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApplicationIdByName;
  function getApplicationName(applicationIdIn in integer) return varchar2 as
    applicationName ame_calling_apps.application_name%type;
    begin
      select application_name
        into applicationName
          from ame_calling_apps
          where
            application_id = applicationIdIn and
            sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(applicationName);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getApplicationName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getApplicationName;
/*
AME_STRIPING
  function getAttributeDisplayValue(attributeValueIn in varchar2) return varchar2 as
    attributeValue ame_stripe_sets.value_1%type;
    begin
      if(substrb(attributeValueIn, 1,5) = ame_util.stripeWildcard) THEN
        return('[any]');
      end if;
      return(attributeValueIn);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getAttributeDisplayValue',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getAttributeDisplayValue;
*/
  function getAttributeQuery(selectClauseIn in varchar2) return ame_util.queryCursor as
    queryCursor ame_util.queryCursor;
    sqlStatement varchar2(4000);
    begin
      sqlStatement := selectClauseIn;
      open queryCursor for sqlStatement;
      return queryCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getAttributeQuery',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(queryCursor);
    end getAttributeQuery;
/*
AME_STRIPING
  function getAttributeStripingUseCount(applicationIdIn in integer,
                                        attributeIdIn in integer) return integer as
    ruleCount integer;
    begin
      select count(*)
        into ruleCount
        from ame_rules,
             ame_rule_usages,
             ame_rule_stripe_sets
        where
          ame_rule_usages.item_id = applicationIdIn and
          ame_rules.rule_id = ame_rule_stripe_sets.rule_id and
          ame_rules.rule_id = ame_rule_usages.rule_id and
          (ame_rule_usages.end_date is null or sysdate < ame_rule_usages.end_date) and
          (ame_rule_stripe_sets.end_date is null or sysdate < ame_rule_stripe_sets.end_date) and
          (ame_rules.end_date is null or sysdate < ame_rules.end_date);
      return(ruleCount);
      exception
        when others then
           rollback;
           ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                     routineNameIn => 'getAttributeStripingUseCount',
                                     exceptionNumberIn => sqlcode,
                                     exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getAttributeStripingUseCount;
*/
  function getFndAppDescription(fndAppIdIn in integer) return varchar2 as
    description fnd_application_vl.application_name%type;
    begin
      select ltrim(fnd_application_vl.application_name)
        into description
        from fnd_application_vl
        where application_id = fndAppIdIn;
      return(description);
      exception
        when others then
           rollback;
           ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                     routineNameIn => 'getFndAppDescription',
                                     exceptionNumberIn => sqlcode,
                                     exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getFndAppDescription;
  function getFndAppDescription1(applicationIdIn in integer) return varchar2 as
    description fnd_application_vl.application_name%type;
    begin
      select ltrim(fnd_application_vl.application_name)
        into description
        from
          fnd_application_vl,
          ame_calling_apps
        where
          fnd_application_vl.application_id = ame_calling_apps.fnd_application_id and
          ame_calling_apps.application_id = applicationIdIn and
          sysdate between ame_calling_apps.start_date and
                 nvl(ame_calling_apps.end_date - ame_util.oneSecond, sysdate)
        order by fnd_application_vl.application_name;
      return(description);
      exception
        when others then
           rollback;
           ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                     routineNameIn => 'getFndAppDescription1',
                                     exceptionNumberIn => sqlcode,
                                     exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getFndAppDescription1;
  function getFndApplicationId(applicationIdIn in integer) return integer as
    fndApplicationId ame_calling_apps.fnd_application_id%type;
    begin
      select fnd_application_id
        into fndApplicationId
        from ame_calling_apps
        where
          application_id = applicationIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return fndApplicationId;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getFndApplicationId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getFndApplicationId;
  function getItemClassCount return integer as
    itemClassCount integer;
    begin
      select count(*)
        into itemClassCount
        from ame_item_classes
        where
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(itemClassCount);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassCount',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassCount;
  function getItemClassIdByName(itemClassNameIn in varchar2) return integer as
    itemId integer;
    begin
      select item_class_id
        into itemId
        from ame_item_classes
        where
          upper(name) = upper(itemClassNameIn) and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(itemId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassIdByName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item name ' ||
                                                        itemClassNameIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getItemClassIdByName;
  function getItemClassIdQuery(itemClassIdIn in integer,
                               applicationIdIn in integer) return varchar2 as
    itemIdQuery ame_util.longestStringType;
    begin
      select item_id_query
        into itemIdQuery
        from ame_item_class_usages
        where
          item_class_id = itemClassIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(itemIdQuery);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassIdQuery',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassIdQuery;
  function getItemClassName(itemClassIdIn in integer) return varchar2 as
    itemName ame_item_classes.name%type;
    begin
      select name
        into itemName
        from ame_item_classes
        where
          item_class_id = itemClassIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(itemName);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassName',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getItemClassName;
  function getLineItemQueryString(applicationIdIn in integer) return varchar2 as
    lineItemQueryString ame_calling_apps.line_item_id_query%type;
    begin
      select line_item_id_query
        into lineItemQueryString
        from ame_calling_apps
        where
          application_id = applicationIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      return lineItemQueryString;
      exception
        when no_data_found then
          return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getLineItemQueryString',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getLineItemQueryString;
  function getItemClassMaxOrderNumber(applicationIdIn in integer) return integer as
    orderNumber integer;
    begin
      select nvl(max(item_class_order_number), 0)
        into orderNumber
        from ame_item_class_usages
        where
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      return(orderNumber);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassMaxOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassMaxOrderNumber;
  function getItemClassOrderNumber(itemClassIdIn in integer,
                                   applicationIdIn in integer) return integer as
    itemClassOrderNumber integer;
    begin
      select item_class_order_number
        into itemClassOrderNumber
        from ame_item_class_usages
        where
          item_class_id = itemClassIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(itemClassOrderNumber);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassOrderNumber',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassOrderNumber;
  function getItemClassTransTypeCount(applicationIdIn in integer) return integer as
    tempCount integer;
      begin
        select count(*)
          into tempCount
          from ame_item_class_usages
          where
            application_id = applicationIdIn and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        return(tempCount);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassTransTypeCount',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassTransTypeCount;
  function getItemClassParMode(itemClassIdIn in integer,
                               applicationIdIn in integer) return varchar2 as
    itemClassParMode ame_util.charType;
    begin
      select item_class_par_mode
        into itemClassParMode
        from ame_item_class_usages
        where
          item_class_id = itemClassIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(itemClassParMode);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassParMode',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassParMode;
  function getParentVersionStartDate(itemClassIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_item_classes
        where
          item_class_id = itemClassIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getParentVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
  end getParentVersionStartDate;
  function getItemClassSublistMode(itemClassIdIn in integer,
                                   applicationIdIn in integer) return varchar2 as
    itemClassSubListMode ame_util.charType;
    begin
      select item_class_sublist_mode
        into itemClassSublistMode
        from ame_item_class_usages
        where
          item_class_id = itemClassIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      return(itemClassSublistMode);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassSublistMode',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getItemClassSublistMode;
  function getSubordinateItemClassId(applicationIdIn in integer) return integer as
    itemId integer;
    begin
      select ame_item_classes.item_class_id
        into itemId
        from ame_item_classes,
             ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_item_classes.name <> ame_util.headerItemClassName and
          sysdate between ame_item_classes.start_date and
            nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_item_class_usages.start_date and
            nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate);
      return(itemId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getSubordinateItemClassId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
  end getSubordinateItemClassId;
  function getTransactionTypeId(applicationIdIn in integer) return varchar2 as
    tempTransactionTypeId ame_calling_apps.transaction_type_id%type;
      begin
        select transaction_type_id
          into tempTransactionTypeId
          from ame_calling_apps
          where application_id = applicationIdIn and
             sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
        return tempTransactionTypeId;
        exception
          when no_data_found then
             return(null);
          when others then
             rollback;
             ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                       routineNameIn => 'getTransactionTypeId',
                                       exceptionNumberIn => sqlcode,
                                       exceptionStringIn => sqlerrm);
              raise;
              return(null);
       end getTransactionTypeId;
  function getVersionStartDate(applicationIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_calling_apps
        where
          application_id = applicationIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getVersionStartDate',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getVersionStartDate;
/*
AME_STRIPING
  function getVersionStartDate2(applicationIdIn in integer,
                                stripeSetIdIn in integer) return varchar2 as
    startDate date;
    stringStartDate varchar2(50);
    begin
      select start_date
        into startDate
        from ame_stripe_sets
        where
          application_id = applicationIdIn and
          stripe_set_id = stripeSetIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      stringStartDate := ame_util.versionDateToString(dateIn => startDate);
      return(stringStartDate);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getVersionStartDate2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getVersionStartDate2;
*/
  function hasLineItemAttributes(applicationIdIn in integer) return boolean is
    lineItemCount integer;
    begin
      select count(*)
        into lineItemCount
        from
          ame_attribute_usages,
          ame_attributes
        where
          ame_attributes.line_item = ame_util.booleanTrue and
          ame_attribute_usages.attribute_id = ame_attributes.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          sysdate between ame_attribute_usages.start_date and
            nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) ;
      if(lineItemCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'hasLineItemAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end hasLineItemAttributes;
/*
AME_STRIPING
  function hasRuleStripes(applicationIdIn in integer) return boolean as
    stripeCount integer;
    begin
      select count(*)
        into stripeCount
        from ame_stripe_sets
        where
          application_id = applicationIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      if(stripeCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'hasRuleStripes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end hasRuleStripes;
*/
  function icInUseByAttributeUsage(itemClassIdIn in integer,
                                   applicationIdIn in integer) return boolean is
    attributeUsageCount integer;
    begin
      select count(*)
        into attributeUsageCount
        from
          ame_attribute_usages,
          ame_attributes
        where
          ame_attribute_usages.attribute_id = ame_attributes.attribute_id and
          ame_attribute_usages.application_id = applicationIdIn and
          ame_attributes.item_class_id = itemClassIdIn and
          sysdate between ame_attribute_usages.start_date and
            nvl(ame_attribute_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_attributes.start_date and
                 nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate);
      if(attributeUsageCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'icInUseByAttributeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end icInUseByAttributeUsage;
  function icInUseByRuleUsage(itemClassIdIn in integer,
                              applicationIdIn in integer) return boolean is
    ruleUsageCount integer;
    begin
      select count(*)
        into ruleUsageCount
        from
          ame_rule_usages,
          ame_rules
        where
          ame_rule_usages.rule_id = ame_rules.rule_id and
          ame_rule_usages.item_id = applicationIdIn and
          ame_rules.item_class_id = itemClassIdIn and
          sysdate between ame_rule_usages.start_date and
            nvl(ame_rule_usages.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_rules.start_date and
                 nvl(ame_rules.end_date - ame_util.oneSecond, sysdate);
      if(ruleUsageCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'icInUseByRuleUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end icInUseByRuleUsage;
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
        The ame_engine.parseStaticCurAttValue procedure parses the usage, if it is parse-able;
        but it doesn't validate the individual values, or convert the amount to canonical format.
      */
      ame_util.parseStaticCurAttValue(applicationIdIn => applicationIdIn,
                                      attributeIdIn => attributeIdIn,
                                      attributeValueIn => queryStringIn,
                                      localErrorIn => false,
                                      amountOut => amount,
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'inputToCanonStaticCurUsage',
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'inputToCanonStaticCurUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage); /* Runtime code doesn't validate input. */
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'inputToCanonStaticCurUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm); /* Runtime code doesn't validate input. */
          raise;
          return(null);
  end inputToCanonStaticCurUsage;
  function isApplicationActive(applicationIdIn in integer) return boolean as
    appCount integer;
    begin
      select count(*)
        into appCount
          from ame_calling_apps
          where
            application_id = applicationIdIn and
            sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
      if(appCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'isApplicationActive',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end isApplicationActive;
  function isInUseByApplication(itemClassIdIn in integer,
                                applicationIdIn in integer) return boolean as
    useCount integer;
    begin
      select count(*)
        into useCount
        from ame_item_class_usages
        where
          item_class_id = itemClassIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'isInUseByApplication',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(true); /* conservative:  avoids allowing deletion if might still be in use */
    end isInUseByApplication;
  function isSeeded(applicationIdIn in integer) return boolean as
    createdByValue integer;
    begin
      select created_by
        into createdByValue
        from ame_calling_apps
        where application_id = applicationIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(createdByValue = 1) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'isSeeded',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true);
    end isSeeded;
/*
AME_STRIPING
  function isStripingOn(applicationIdIn in integer) return boolean as
    isStripingOn varchar2(20);
    begin
      select variable_value
        into isStripingOn
        from ame_config_vars
        where application_id = applicationIdIn and
          variable_name = ame_util.useRuleStripingConfigVar and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      if(isStripingOn = ame_util.yes) then
        return(true);
      end if;
      return(false);
      exception
        when no_data_found then
          return(false);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'isStripingOn',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end isStripingOn;
*/
/*
AME_STRIPING
  function newStripeSet(applicationIdIn in integer,
                        attributeValuesIn in ame_util.stringList,
                        commitIn in boolean default false) return integer as
    attributeValues ame_util.stringList;
    attributeValuesCount integer;
    currentUserId integer;
    stripeSetId ame_stripe_sets.stripe_set_id%type;
    tempIndex integer;
    begin
*/
      /* need to set the rest of the attributeValues to null so the call to
         getStripeSetId below does not hit the no_data_found exception */
/*
      attributeValuesCount := attributeValuesIn.count;
      for i in 1..5 loop
        attributeValues(i) := null;
      end loop;
      for i in 1..attributeValuesCount loop
        attributeValues(i) := attributeValuesIn(i);
      end loop;
      stripeSetId := getStripeSetId(applicationIdIn => applicationIdIn,
                                    attributeValuesIn => attributeValues);
      if(stripeSetId is null) then
        currentUserId := ame_util.getCurrentUserId;
        select max(stripe_set_id + 1) into stripeSetId from ame_stripe_sets;
        insert into ame_stripe_sets(application_id,
                                    stripe_set_id,
                                    value_1,
                                    value_2,
                                    value_3,
                                    value_4,
                                    value_5,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
                                    last_update_date,
                                    last_update_login,
                                    start_date,
                                    end_date,
                                    security_group_id)
          values(applicationIdIn,
                 stripeSetId,
                 attributeValuesIn(1),
                 attributeValuesIn(2),
                 attributeValuesIn(3),
                 attributeValuesIn(4),
                 attributeValuesIn(5),
                 currentUserId,
                 sysdate,
                 currentUserId,
                 sysdate,
                 currentUserId,
                 sysdate,
                 null,
                 null);
      end if;
      if(commitIn) then
        commit;
      end if;
      return(stripeSetId);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newStripeSet',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end newStripeSet;
*/
/*
AME_STRIPING
  function getStripeSetId(applicationIdIn in integer,
                          attributeValuesIn in ame_util.stringList) return integer as
    stripeSetId ame_stripe_sets.stripe_set_id%type;
    begin
      select stripe_set_id
        into stripeSetId
        from ame_stripe_sets
        where
          application_id = applicationIdIn and
          stripe_set_id <> 0 and
          ((value_1 is null and attributeValuesIn(1) is null) or value_1 = attributeValuesIn(1)) and
          ((value_2 is null and attributeValuesIn(2) is null) or value_2 = attributeValuesIn(2)) and
          ((value_3 is null and attributeValuesIn(3) is null) or value_3 = attributeValuesIn(3)) and
          ((value_4 is null and attributeValuesIn(4) is null) or value_4 = attributeValuesIn(4)) and
          ((value_5 is null and attributeValuesIn(5) is null) or value_5 = attributeValuesIn(5)) and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      return(stripeSetId);
      exception
        when no_data_found then
          return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getStripeSetId',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end getStripeSetId;
*/
  function itemClassNameExists(itemClassNameIn in varchar2) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from ame_item_classes
        where
          upper(name) = upper(itemClassNameIn) and
           sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(tempCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'itemClassNameExists',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(true); /* conservative:  avoids possibility of re-creation of existing name */
    end itemClassNameExists;
  function newItemClass(itemClassNameIn in varchar2,
                        newStartDateIn in date,
                        finalizeIn in boolean default false,
                        itemClassIdIn in integer default null) return integer as
    createdBy integer;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    itemClassId integer;
    itemClassCount integer;
    itemClassExistsException exception;
    itemClassName ame_item_classes.name%type;
    nameLengthException exception;
    processingDate date;
    tempCount integer;
    begin
      itemClassName := trim(trailing ' ' from itemClassNameIn);
      /*
      if(processingDateIn is null) then
        processingDate := sysdate;
      else
        processingDate := processingDateIn;
      end if;
      */
      begin
        select item_class_id
          into itemClassId
          from ame_item_classes
          where
            (itemClassIdIn is null or item_class_id <> itemClassIdIn) and
            name = itemClassName and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        if itemClassId is not null then
          raise itemClassExistsException;
        end if;
        exception
          when no_data_found then null;
      end;
      if(ame_util.isArgumentTooLong(tableNameIn => 'ame_item_classes',
                                    columnNameIn => 'name',
                                    argumentIn => itemClassName)) then
        raise nameLengthException;
      end if;
      /*
      If any version of the object has created_by = 1, all versions,
      including the new version, should.  This is a failsafe way to check
      whether previous versions of an already end-dated object had
      created_by = 1.
      */
      currentUserId := ame_util.getCurrentUserId;
      if(itemClassIdIn is null) then
        createdBy := currentUserId;
        select count(*)
          into itemClassCount
          from ame_item_classes
          where
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        /* new id */
        itemClassId := (itemClassCount + 1);
      else
        itemClassId := itemClassIdIn;
        select count(*)
         into tempCount
         from ame_item_classes
           where
             item_class_id = itemClassId and
             created_by = ame_util.seededDataCreatedById;
        if(tempCount > 0) then
          createdBy := ame_util.seededDataCreatedById;
        else
          createdBy := currentUserId;
        end if;
      end if;
      insert into ame_item_classes(item_class_id,
                                   name,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login,
                                   start_date,
                                   end_date)
        values(itemClassId,
               itemClassName,
               createdBy,
               newStartDateIn,
               currentUserId,
               newStartDateIn,
               currentUserId,
               newStartDateIn,
               null);
      if(finalizeIn) then
        commit;
      end if;
      return(itemClassId);
      exception
        when itemClassExistsException then
          rollback;
          errorCode := -20001;
          errorMessage :=
          ame_util.getMessage(applicationShortNameIn => 'PER',
                              messageNameIn => 'AME_400374_ADM IC_NAME_EXISTS');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClass',
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
               messageNameIn => 'AME_400375_ADM IC_NAME_LONG',
               tokenNameOneIn  => 'COLUMN_LENGTH',
               tokenValueOneIn => ame_util.getColumnLength(tableNameIn => 'ame_item_classes',
                                                    columnNameIn => 'name'));
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClass',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
          return(null);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClass',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
          return(null);
    end newItemClass;
  function orderNumberUnique(applicationIdIn in integer,
                                                                                                                 orderNumberIn in integer) return boolean as
    tempCount integer;
                begin
      select count(*)
        into tempCount
        from ame_item_class_usages
        where
          application_id = applicationIdIn and
          item_class_order_number = orderNumberIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      if(tempCount > 1) then
        return(false);
      else
        return(true);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'orderNumberUnique',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
  end orderNumberUnique;
  function subordinateItemClassCount(applicationIdIn in integer) return integer is
    itemClassCount integer;
    begin
      select count(*)
        into itemClassCount
        from ame_item_classes,
             ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_item_classes.name <> ame_util.headerItemClassName and
          sysdate between ame_item_classes.start_date and
            nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_item_class_usages.start_date and
            nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate);
        return(itemClassCount);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'subordinateItemClassCount',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(null);
    end subordinateItemClassCount;
  function transTypeCVValueExists(applicationIdIn in integer,
                                  variableNameIn in varchar2) return boolean as
    tempCount integer;
    begin
      select count(*)
        into tempCount
        from ame_config_vars
        where
          application_id = applicationIdIn and
          variable_name = variableNameIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(tempCount > 0) then
        return(true);
      end if;
      return(false);
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'transTypeCVValueExists',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
          return(false);
    end transTypeCVValueExists;
/*
AME_STRIPING
  procedure addStripingAttribute(attributeIdIn in integer,
                                 applicationIdIn in integer) as
    cursor pairCursor(attributeIdIn in integer,
                      applicationIdIn in integer) is
      select
        ame_condition_usages.rule_id,
        ame_string_values.string_value
        from
          ame_condition_usages,
          ame_rule_usages,
          ame_string_values
        where
          ame_rule_usages.item_id = applicationIdIn and
          ame_rule_usages.rule_id = ame_condition_usages.rule_id and
          ame_string_values.condition_id = ame_condition_usages.condition_id and
          ame_condition_usages.condition_id in
            (select condition_id
              from ame_conditions
              where
                attribute_id = attributeIdIn and
*/
                /* The condition only has one string value. */
/*
                (select count(*) from ame_string_values
                   where
                     ame_string_values.condition_id = ame_conditions.condition_id and
                     sysdate between ame_string_values.start_date and
                 nvl(ame_string_values.end_date - ame_util.oneSecond, sysdate)
                ) = 1 and
                sysdate between ame_conditions.start_date and
                 nvl(ame_conditions.end_date - ame_util.oneSecond, sysdate)) and
          ((sysdate between ame_rule_usages.start_date and
            nvl(ame_rule_usages.end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < ame_rule_usages.start_date and
            ame_rule_usages.start_date < nvl(ame_rule_usages.end_date,
              ame_rule_usages.start_date + ame_util.oneSecond))) and
          ((sysdate between ame_condition_usages.start_date and
            nvl(ame_condition_usages.end_date - ame_util.oneSecond, sysdate)) or
         (sysdate < ame_condition_usages.start_date and
            ame_condition_usages.start_date < nvl(ame_condition_usages.end_date,
              ame_condition_usages.start_date + ame_util.oneSecond))) and
          sysdate between ame_string_values.start_date and
                 nvl(ame_string_values.end_date - ame_util.oneSecond, sysdate)
        order by rule_id; */
                                /* The order-by is crucial to 2(B) below. */
/*
    cursor noConditionRuleCursor(attributeIdIn in integer,
                                 applicationIdIn in integer) is
      select rule_id
        from ame_rule_usages
        where
          item_id = applicationIdIn and
          rule_id not in
          (select ame_condition_usages.rule_id
            from
              ame_condition_usages,
              ame_rule_usages ru2
            where
              ru2.item_id = applicationIdIn and
              ru2.rule_id = ame_condition_usages.rule_id and
              ame_condition_usages.condition_id in
                (select condition_id
                  from ame_conditions
                  where
                    attribute_id = attributeIdIn and
*/
                    /* The condition only has one string value. */
/*
                    (select count(*)
                       from ame_string_values
                       where
                         ame_string_values.condition_id = ame_conditions.condition_id and
                         (ame_string_values.start_date <= sysdate and
                         (ame_string_values.end_date is null or sysdate < ame_string_values.end_date))) = 1 and
                    (ame_conditions.start_date <= sysdate and
                     (ame_conditions.end_date is null or sysdate < ame_conditions.end_date))) and
              (ru2.start_date <= sysdate and
               (ru2.end_date is null or sysdate < ru2.end_date)) and
              (ame_condition_usages.start_date <= sysdate and
               (ame_condition_usages.end_date is null or sysdate < ame_condition_usages.end_date))) and
          (ame_rule_usages.start_date <= sysdate and
           (ame_rule_usages.end_date is null or sysdate < ame_rule_usages.end_date));
    cursor oldRuleStripeSetCursor(ruleIdIn in integer,
                                  applicationIdIn in integer,
                                  stripeSetDateIn in date) is
      select
        value_1,
        value_2,
        value_3,
        value_4,
        value_5
        from
          ame_stripe_sets,
          ame_rule_stripe_sets
        where
          ame_stripe_sets.stripe_set_id = ame_rule_stripe_sets.stripe_set_id and
          ame_stripe_sets.application_id = applicationIdIn and
          ame_rule_stripe_sets.rule_id = ruleIdIn and
*/
          /*
            Here we want a <= comparison for the end dates, because what we're querying for
            stripe sets that were end-dated at tempDate, which gets passed to this cursor as
            stripeSetDateIn.
          */
/*
          (ame_stripe_sets.start_date <= stripeSetDateIn and stripeSetDateIn <= ame_stripe_sets.end_date) and
          (ame_rule_stripe_sets.start_date <= stripeSetDateIn and stripeSetDateIn <= ame_rule_stripe_sets.end_date);
    attributeCount integer;
    errorCode integer;
    errorMessage ame_util.longStringType;
    existingSAException exception;
    firstRuleLackingIndex integer;
    lastRuleHavingIndex integer;
    newAttributeCount integer;
    newStripingAttributeIds ame_util.stringList;
    newStripingAttributeIndex integer;
    noConditionRuleIds ame_util.idList;
    ruleIds ame_util.idList;
    rulesLackingEqualityConditions ame_util.idList;
    stringValues ame_util.stringList;
    stripingAttributeCount integer;
    stripingAttributeIdCount integer;
    stripingAttributeIds ame_util.idList;
    stripingAttNextValIndex integer;
    stripingAttributeValues ame_util.stringList;
    tempDate date;
    tempIndex integer;
    tempIndex1 integer;
    tempStripeSetId integer;
    begin
*/
      /* Initialize tempDate as early as possible, to avoid waiting later for sysdate to pass tempDate. */
/*
      tempDate := sysdate;
*/
      /*
        1.  Make sure the attribute with ID attributeIdIn is not already a striping
            attribute for the transaction type with ID applicationIdIn.
      */
/*
      select count(*)
        into tempIndex
        from ame_attribute_usages
        where
          attribute_id = attributeIdIn and
          application_id = applicationIdIn and
          is_striping_attribute = ame_util.booleanTrue and
          (start_date <= sysdate and
           (end_date is null or sysdate < end_date));
      if(tempIndex > 0) then
        raise existingSAException;
      end if;
*/
      /*
        2.  Fetch all (ruleId, stringValue) ordered pairs such that either (A)
            the rule with ID ruleId uses the equality condition with condition ID on the
            attribute with ID attributeIdIn, and the condition has the unique allowed
            value stringValue, or (B) the rule has no such equality condition, so that
            stringValue is 'AME_*' and there is no conditionId--all within the transaction
            type with ID applicationIdIn.
      */
/*
      open pairCursor(attributeIdIn => attributeIdIn,
                      applicationIdIn => applicationIdIn);
      fetch pairCursor bulk collect
        into
          ruleIds,
          stringValues;
      close pairCursor;
      open noConditionRuleCursor(attributeIdIn => attributeIdIn,
                                 applicationIdIn => applicationIdIn);
      fetch noConditionRuleCursor bulk collect into rulesLackingEqualityConditions;
      close noConditionRuleCursor;
      lastRuleHavingIndex := ruleIds.count;
      tempIndex := lastRuleHavingIndex; */
                        /* pre-increment */
/*
      firstRuleLackingIndex := 0;
      if(rulesLackingEqualityConditions.count > 0) then
        firstRuleLackingIndex := tempIndex + 1;
        for i in 1 .. rulesLackingEqualityConditions.count loop
          tempIndex := tempIndex + 1;
          ruleIds(tempIndex) := rulesLackingEqualityConditions(i);
          stringValues(tempIndex) := ame_util.stripeWildcard;
        end loop;
      else
        firstRuleLackingIndex := null;
      end if;
*/
      /*
        3.  (A) If this is the first striping attribute (so that no stripe sets exist yet),
            loop through the ordered pairs from #1 above.  For each ordered pair, if a
            stripe set has been created (by this loop) that uses stringValue, add ruleId
            to the stripe set; otherwise, create a new stripe set for stringValue, and
            add ruleId to it.
            (B) Otherwise:
              (i) Pause until sysdate > tempDate, so that queries using sysdate will not hit
                  rows end-dated at tempDate.
              (ii) End date at tempDate all current stripe sets and rule-stripe-set assignments
                   in the current transaction type.
              (iii) For each ordered pair in #1 above:
                (a) Fetch the striping-attribute values of all of the stripe sets
                    that were current as of tempDate that ruleId satisfies, ignoring
                    the new striping attribute.
                (b) For each stripe set in (a):
                    (1) If no current stripe set exists with the same attribute values,
                        including stringValue for the new striping attribute, create a new
                        stripe set having those values.
                    (2) Put ruleId in the stripe set you either found or created in (1).
        */
        /* Determine whether this is the first striping attribute. */
/*
        select count(*)
          into stripingAttributeCount
          from ame_attribute_usages
          where
            application_id = applicationIdIn and
            is_striping_attribute = ame_util.booleanTrue and
            (start_date <= sysdate and
             (end_date is null or sysdate < end_date));
        newStripingAttributeIndex := stripingAttributeCount + 1;
*/
        /* Loop through the ordered pairs, processing them. */
/*        if(stripingAttributeCount = 0) then */
/* This is the first striping attribute. */
          /* Initialize the unused slots in stripingAttributeValues to null. */
/*
          for i in 1 .. 5 loop
            stripingAttributeValues(i) := null;
            stripingAttributeIds(i) := null;
          end loop;
*/
          /* Now create new stripe sets and rule-stripe-set assignments as needed. */
/*
          for i in 1 .. lastRuleHavingIndex loop
            stripingAttributeValues(1) := stringValues(i);
            tempStripeSetId := ame_admin_pkg.getStripeSetId(applicationIdIn => applicationIdIn,
                                                            attributeValuesIn => stripingAttributeValues);
            if(tempStripeSetId is null) then
              tempStripeSetId := ame_admin_pkg.newStripeSet(applicationIdIn => applicationIdIn,
                                                            attributeValuesIn => stripingAttributeValues);
            end if;
            ame_rule_pkg.newRuleStripeSet(applicationIdIn => applicationIdIn,
                                          ruleIdIn => ruleIds(i),
                                          stripeSetIdIn => tempStripeSetId);
          end loop;
          if(firstRuleLackingIndex is not null) then
            stripingAttributeValues(1) := ame_util.stripeWildcard;
            tempStripeSetId := ame_admin_pkg.newStripeSet(applicationIdIn => applicationIdIn,
                                                          attributeValuesIn => stripingAttributeValues);
            for i in firstRuleLackingIndex .. ruleIds.count loop
              ame_rule_pkg.newRuleStripeSet(applicationIdIn => applicationIdIn,
                                            ruleIdIn => ruleIds(i),
                                            stripeSetIdIn => tempStripeSetId);
            end loop;
          end if;
        else */
                                /* At least one striping attribute already exists. */
          /*
            End date the current rule-stripe-set assignments, and then the current
            stripe sets, with end_date = tempDate.  (The order of update statements matters!)
          */
/*
          getStripingAttributeIds(applicationIdIn => applicationIdIn,
                                  stripingAttributeIdsOut => stripingAttributeIds);
          update ame_rule_stripe_sets
            set end_date = tempDate
            where
              stripe_set_id in
                (select stripe_set_id
                   from ame_stripe_sets
                   where
                     application_id = applicationIdIn and
                     (start_date <= tempDate and
                      (end_date is null or tempDate < end_date))) and
              (start_date <= tempDate and
               (end_date is null or tempDate < end_date));
          update ame_stripe_sets
            set end_date = tempDate
            where
              application_id = applicationIdIn and
              (start_date <= tempDate and
               (end_date is null or tempDate < end_date));
*/
          /* Wait until sysdate is past tempDate. */
/*
          while(sysdate - tempDate = 0) loop
            null;
          end loop;
*/
          /* Replace old stripe sets as needed, adding the rules to the new stripe sets in the process. */
/*
          for i in 1 .. ruleIds.count loop
            for oldStripeSet in oldRuleStripeSetCursor(ruleIdIn => ruleIds(i),
                                                       applicationIdIn => applicationIdIn,
                                                       stripeSetDateIn => tempDate) loop
              stripingAttributeValues(1) := oldStripeSet.value_1;
              stripingAttributeValues(2) := oldStripeSet.value_2;
              stripingAttributeValues(3) := oldStripeSet.value_3;
              stripingAttributeValues(4) := oldStripeSet.value_4;
              stripingAttributeValues(5) := oldStripeSet.value_5;
              stripingAttributeValues(newStripingAttributeIndex) := stringValues(i);
              tempStripeSetId := ame_admin_pkg.getStripeSetId(applicationIdIn => applicationIdIn,
                                                              attributeValuesIn => stripingAttributeValues);
              if(tempStripeSetId is null) then
                tempStripeSetId := ame_admin_pkg.newStripeSet(applicationIdIn => applicationIdIn,
                                                              attributeValuesIn => stripingAttributeValues);
              end if;
              ame_rule_pkg.newRuleStripeSet(applicationIdIn => applicationIdIn,
                                            ruleIdIn => ruleIds(i),
                                            stripeSetIdIn => tempStripeSetId);
            end loop;
          end loop;
        end if;
*/
        /*
          4.  Make the attribute with ID attributeIdIn a striping attribute for the current
              transaction type.
        */
/*
        attributeCount := stripingAttributeIds.count;
        for i in 1..attributeCount loop
          newStripingAttributeIds(i) := to_char(stripingAttributeIds(i));
        end loop;
        newStripingAttributeIds(newStripingAttributeIndex) := to_char(attributeIdIn);
        tempIndex1 := 1;
        for i in 1..(5 - newStripingAttributeIndex) loop
          newStripingAttributeIds(newStripingAttributeIndex + tempIndex1) := null;
          tempIndex1 := tempIndex1 + 1;
        end loop;
        newStripeSet2(applicationIdIn => applicationIdIn,
                      newStripedAttributesSetIn => newStripingAttributeIds);
        tempDate := sysdate;
        ame_attribute_pkg.changeUsage(attributeIdIn => attributeIdIn,
                                      applicationIdIn => applicationIdIn,
                                      staticUsageIn =>
                                        ame_attribute_pkg.getStaticUsage(attributeIdIn => attributeIdIn,
                                                                         applicationIdIn => applicationIdIn),
                                      queryStringIn =>
                                        ame_attribute_pkg.getQueryString(attributeIdIn => attributeIdIn,
                                                                         applicationIdIn => applicationIdIn),
                                      endDateIn => tempDate,
                                      newStartDateIn => tempDate,
                                      lineItemAttributeIn =>
                                        ame_attribute_pkg.getLineItem(attributeIdIn => attributeIdIn),
                                      isStripingAttributeIn => ame_util.booleanTrue);
      exception
        when existingSAException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            'The attribute ' ||
            ame_attribute_pkg.getName(attributeIdIn => attributeIdIn) ||
            ' is already a striping attribute for this transaction type.  ';
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'addStripingAttribute',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(pairCursor%isopen) then
            close pairCursor;
          end if;
          if(noConditionRuleCursor%isopen) then
            close noConditionRuleCursor;
          end if;
          if(oldRuleStripeSetCursor%isopen) then
            close oldRuleStripeSetCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'addStripingAttribute',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end addStripingAttribute;
*/
  procedure change(applicationIdIn in integer,
                   transactionTypeIdIn in varchar2,
                   transactionTypeDescriptionIn in varchar2,
                   versionStartDateIn in date) as
    cursor startDateCursor is
      select start_date
        from ame_calling_apps
        where
          application_id = applicationIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    appCount integer;
    createdBy integer;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    fndApplicationId ame_calling_apps.fnd_application_id%type;
    invalidOrderException exception;
    multipleTransTypesException exception;
    processingDate date;
    startDate date;
    tempCount integer;
    upperLimit integer;
    begin
      processingDate := sysdate;
      currentUserId := ame_util.getCurrentUserId;
      fndApplicationId := getFndApplicationId(applicationIdIn => applicationIdIn);
      /* Check version date. */
      open startDateCursor;
      fetch startDateCursor into startDate;
      if(versionStartDateIn <> startDate) then
        close startDateCursor;
        raise ame_util.objectVersionException;
      end if;
      close startDateCursor;
      update ame_calling_apps
        set
          last_updated_by = currentUserId,
          last_update_date = processingDate,
          last_update_login = currentUserId,
          end_date = processingDate
        where
          application_id = applicationIdIn and
          processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate) ;
      /*
        Now that the current version has been end-dated, checkNewOrChangedTransType can
        do the same checks as for a new transaction type.
      */
      checkNewOrChangedTransType(fndAppIdIn => fndApplicationId,
                             transTypeIdIn => transactionTypeIdIn,
                             transTypeDescIn => transactionTypeDescriptionIn);
      select count(*)
        into tempCount
        from ame_calling_apps
          where
            application_id = applicationIdIn and
            created_by = ame_util.seededDataCreatedById;
      if(tempCount > 0) then
         createdBy := ame_util.seededDataCreatedById;
       else
         createdBy := currentUserId;
       end if;
      /* Perform update. */
      insert into ame_calling_apps(fnd_application_id,
                                   application_name,
                                   application_id,
                                   transaction_type_id,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login,
                                   start_date,
                                   line_item_id_query)
        values(fndApplicationId,
               transactionTypeDescriptionIn,
               applicationIdIn,
               transactionTypeIdIn,
               createdBy,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               processingDate,
               null);
      commit;
      exception
        when multipleTransTypesException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400173_ADM_TTY_NOT_NULL_ID');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when invalidOrderException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400174_ADM_LIN_QRY_ORD_BY');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when ame_util.objectVersionException then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when no_data_found then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'change',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end change;
  procedure changeItemClass(itemClassIdIn in integer,
                            itemClassNameIn in varchar2,
                            startDateIn in date,
                            endDateIn in date,
                            finalizeIn in boolean default false) as
    itemClassId integer;
    currentUserId integer;
    begin
      currentUserId := ame_util.getCurrentUserId;
      update ame_item_classes
        set
          last_updated_by = currentUserId,
          last_update_date = endDateIn,
          last_update_login = currentUserId,
          end_date = endDateIn
        where
          item_class_id = itemClassIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate);
      itemClassId := newItemClass(itemClassIdIn => itemClassIdIn,
                                  itemClassNameIn => itemClassNameIn,
                                  newStartDateIn => startDateIn,
                                  finalizeIn => false);
      if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'changeItemClass',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end changeItemClass;
  procedure changeItemClassAndUsage(applicationIdIn in integer,
                                    itemClassIdIn in integer,
                                    itemClassNameIn in varchar2,
                                    itemClassParModeIn in varchar2,
                                    itemClassSublistModeIn in varchar2,
                                    itemClassIdQueryIn in varchar2,
                                    orderNumberIn in integer,
                                    orderNumberUniqueIn in varchar2,
                                    parentVersionStartDateIn in date,
                                    childVersionStartDateIn in date,
                                    finalizeIn in boolean default false) as
    cursor startDateCursor is
      select start_date
        from ame_item_classes
        where
          item_class_id = itemClassIdIn and
           sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    cursor startDateCursor2 is
      select start_date
        from ame_item_class_usages
        where
          item_class_id = itemClassIdIn and
          application_id = applicationIdIn and
           sysdate between start_date and
             nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    itemClassId integer;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    newStartAndEndDate date;
    objectVersionNoDataException exception;
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
          /* Check whether the input values match the existing values; if so, just return. */
          select count(*)
            into tempCount
            from
              ame_item_classes,
              ame_item_class_usages
            where
              ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
              ame_item_classes.item_class_id = itemClassIdIn and
              ame_item_class_usages.application_id = applicationIdIn and
              ame_item_class_usages.item_id_query = itemClassIdQueryIn and
              ame_item_class_usages.item_class_par_mode = itemClassParModeIn and
              ame_item_class_usages.item_class_sublist_mode = itemClassSublistModeIn and
              ame_item_class_usages.item_class_order_number = orderNumberIn and
              sysdate between ame_item_classes.start_date and
                nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
              sysdate between ame_item_class_usages.start_date and
                nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate) ;
          if(tempCount > 0) then
            return;
          end if;
          /* Get current values as necessary for update. */
          newStartAndEndDate := sysdate;
          ame_admin_pkg.changeItemClass(itemClassIdIn => itemClassIdIn,
                                        itemClassNameIn => itemClassNameIn,
                                        endDateIn => newStartAndEndDate,
                                        startDateIn => newStartAndEndDate,
                                        finalizeIn => false);
          ame_admin_pkg.changeUsage(itemClassIdIn => itemClassIdIn,
                                    applicationIdIn => applicationIdIn,
                                    itemClassParModeIn => itemClassParModeIn,
                                    itemClassSublistModeIn => itemClassSublistModeIn,
                                    itemClassIdQueryIn => itemClassIdQueryIn,
                                    orderNumberIn => orderNumberIn,
                                    orderNumberUniqueIn => orderNumberUniqueIn,
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'changeItemClassAndUsage',
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'changeItemClassAndUsage',
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'changeItemClassAndUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end changeItemClassAndUsage;
  procedure changeUsage(applicationIdIn in integer,
                        itemClassIdIn in integer,
                        itemClassParModeIn in varchar2,
                        itemClassSublistModeIn in varchar2,
                        itemClassIdQueryIn in varchar2,
                        orderNumberIn in integer,
                        orderNumberUniqueIn in varchar2,
                        endDateIn in date,
                        newStartDateIn in date,
                        finalizeIn in boolean default false) as
    currentUserId integer;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    newOrderNumber integer;
    newStartDate date;
    oldOrderNumber integer;
    oldOrderNumberUnique ame_util.stringType;
    orderNumberException exception;
    updateOnlyICModified boolean;
    begin
      oldOrderNumber := getItemClassOrderNumber(applicationIdIn => applicationIdIn,
                                                itemClassIdIn => itemClassIdIn);
      if(ame_admin_pkg.orderNumberUnique(applicationIdIn => applicationIdIn,
                                         orderNumberIn => oldOrderNumber)) then
        oldOrderNumberUnique := ame_util.yes;
      else
                          oldOrderNumberUnique := ame_util.no;
      end if;
                        currentUserId := ame_util.getCurrentUserId;
                        endDate := endDateIn;
      newStartDate := newStartDateIn;
      updateOnlyICModified := false;
      /* Check if order number was modified */
                        if(oldOrderNumber = orderNumberIn) then
                          if(orderNumberUniqueIn = oldOrderNumberUnique) then
                            updateOnlyICModified := true;
        elsif(orderNumberUniqueIn = ame_util.yes) then
                            /* Need to adjust the order numbers to keep them in sequence. */
          incrementItemClassOrderNumbers(applicationIdIn => applicationIdIn,
                                         itemClassIdIn => itemClassIdIn,
                                         orderNumberIn => orderNumberIn);

        else /* The order number is not unique. */
                                  raise orderNumberException;
                                end if;
      else
        update ame_item_class_usages
          set
            last_updated_by = currentUserId,
            last_update_date = endDate,
            last_update_login = currentUserId,
            end_date = endDate
          where
            application_id = applicationIdIn and
            item_class_id = itemClassIdIn and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
                                if(oldOrderNumberUnique = ame_util.yes) then
          decrementItemClassOrderNumbers(applicationIdIn => applicationIdIn,
                                         orderNumberIn => oldOrderNumber);
                                  if(orderNumberIn > oldOrderNumber)then
            newOrderNumber := (orderNumberIn - 1);
          else
            newOrderNumber := orderNumberIn;
          end if;
        else
          newOrderNumber := orderNumberIn;
                          end if;
                                if(orderNumberUniqueIn = ame_util.yes) then
                            incrementItemClassOrderNumbers(applicationIdIn => applicationIdIn,
                                                           itemClassIdIn => itemClassIdIn,
                                                           orderNumberIn => newOrderNumber);
        end if;
        insert into ame_item_class_usages(application_id,
                                          item_class_id,
                                          item_id_query,
                                          item_class_order_number,
                                          item_class_par_mode,
                                          item_class_sublist_mode,
                                          created_by,
                                          creation_date,
                                          last_updated_by,
                                          last_update_date,
                                          last_update_login,
                                          start_date,
                                          end_date)
          values(applicationIdIn,
                 itemClassIdIn,
                 itemClassIdQueryIn,
                 newOrderNumber,
                 itemClassParModeIn,
                 itemClassSublistModeIn,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 null);
      end if;
      if(updateOnlyICModified) then
        update ame_item_class_usages
          set
            last_updated_by = currentUserId,
            last_update_date = endDate,
            last_update_login = currentUserId,
            end_date = endDate
          where
            application_id = applicationIdIn and
            item_class_id = itemClassIdIn and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_item_class_usages(application_id,
                                          item_class_id,
                                          item_id_query,
                                          item_class_order_number,
                                          item_class_par_mode,
                                          item_class_sublist_mode,
                                          created_by,
                                          creation_date,
                                          last_updated_by,
                                          last_update_date,
                                          last_update_login,
                                          start_date,
                                          end_date)
          values(applicationIdIn,
                 itemClassIdIn,
                 itemClassIdQueryIn,
                 orderNumberIn,
                 itemClassParModeIn,
                 itemClassSublistModeIn,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 currentUserId,
                 newStartDate,
                 null);
      end if;
                        if(finalizeIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'changeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end changeUsage;
  procedure checkNewOrChangedTransType(fndAppIdIn in integer,
                                       transTypeIdIn in varchar2,
                                       transTypeDescIn in varchar2) as
    badDescException exception;
    badTransTypeIdException exception;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    existingNullTTException exception;
    existingTTException exception;
    tempCount integer;
    begin
      /* You can't add a trans type if a null trans type ID already exists for the same app. */
      select count(*)
        into tempCount
        from ame_calling_apps
        where
          fnd_application_id = fndAppIdIn and
          transaction_type_id is null and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(tempCount > 0) then
        raise existingNullTTException;
      end if;
      /* You can't add a null trans type ID if a trans type already exists for same app. */
      if(transTypeIdIn is null) then
        select count(*)
          into tempCount
          from ame_calling_apps
          where
            fnd_application_id = fndAppIdIn and
            sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
        if(tempCount > 0) then
          raise existingTTException;
        end if;
      end if;
      /* You can't add the same trans type as one that already exists. */
      select count(*)
        into tempCount
        from ame_calling_apps
        where
          fnd_application_id = fndAppIdIn and
          transaction_type_id = transTypeIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(tempCount > 0) then
        raise badTransTypeIdException;
      end if;
      /* You can't add the same desc as one that already exists. */
      select count(*)
        into tempCount
        from ame_calling_apps
        where
          upper(application_name) = upper(transTypeDescIn) and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      if(tempCount > 0) then
        raise badDescException;
      end if;
      exception
        when badTransTypeIdException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400175_ADM_TTY_ID_ALREADY');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'checkNewOrChangedTransType',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when badDescException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400176_ADM_TTY_HAS_DESC');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'checkNewOrChangedTransType',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when existingNullTTException then
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400177_ADM_TTY_EXIST_NULL');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                 routineNameIn => 'checkNewOrChangedTransType',
                                 exceptionNumberIn => errorCode,
                                 exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when existingTTException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400178_ADM_TTY_EXIST_NONUL');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'checkNewOrChangedTransType',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'checkNewOrChangedTransType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end checkNewOrChangedTransType;
/*
AME_STRIPING
  procedure checkStripeSetUsage(stripeSetIdIn in integer,
                                commitIn in boolean default false) as
    useCount integer;
    begin
      select count(*)
        into useCount
        from ame_rule_stripe_sets
        where
          stripe_set_id = stripeSetIdIn and
          (start_date <= sysdate and
           (end_date is null or sysdate < end_date));
      if(useCount = 0) then
        update ame_stripe_sets
          set end_date = sysdate
          where
            stripe_set_id = stripeSetIdIn and
            (start_date <= sysdate and
             (end_date is null or sysdate < end_date));
        if(commitIn) then
          commit;
        end if;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'checkStripeSetUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end checkStripeSetUsage;
*/
  procedure clearTransException(applicationIdIn in integer,
                                transactionIdIn in varchar2) as
    begin
      delete from ame_exceptions_log
        where
          application_id = applicationIdIn and
          transaction_id = transactionIdIn;
      commit;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'clearTransException',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end clearTransException;
  procedure clearTransTypeConfigVarValue(applicationIdIn in integer,
                                         variableNameIn in varchar2) as
    begin
      update ame_config_vars
        set end_date = sysdate
        where
          application_id = applicationIdIn and
          variable_name = variableNameIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
      commit;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'clearTransTypeConfigVarValue',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end clearTransTypeConfigVarValue;
  procedure clearTransTypeExceptions(applicationIdIn in integer) as
    begin
      delete from ame_exceptions_log
        where application_id = applicationIdIn;
      commit;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'clearTransTypeExceptions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end clearTransTypeExceptions;
  procedure clearWebExceptions as
    begin
      delete from ame_exceptions_log
        where
          application_id is null and
          transaction_id is null;
       commit;
       exception
         when others then
           rollback;
           ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                     routineNameIn => 'clearWebExceptions',
                                     exceptionNumberIn => sqlcode,
                                     exceptionStringIn => sqlerrm);
           raise;
    end clearWebExceptions;
  procedure decrementItemClassOrderNumbers(applicationIdIn in integer,
                                           orderNumberIn in integer,
                                           finalizeIn in boolean default false) as
    cursor orderNumberCursor is
      select item_class_id, item_class_order_number
        from ame_item_class_usages
        where
          application_id = applicationIdIn and
          item_class_order_number > orderNumberIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
          order by item_class_order_number;
                currentUserId integer;
                itemClassIds ame_util.idList;
                itemClassIdQuery ame_item_class_usages.item_id_query%type;
    itemClassParMode ame_item_class_usages.item_class_par_mode%type;
    itemClassSublistMode ame_item_class_usages.item_class_sublist_mode%type;
    orderNumbers ame_util.idList;
    processingDate date;
    votingRegime ame_util.charType;
    begin
      currentUserId := ame_util.getCurrentUserId;
                        processingDate := sysdate;
      open orderNumberCursor;
        fetch orderNumberCursor bulk collect
        into itemClassIds, orderNumbers;
      close orderNumberCursor;
      for i in 1 .. itemClassIds.count loop
        itemClassIdQuery := getItemClassIdQuery(itemClassIdIn => itemClassIds(i),
                                                applicationIdIn => applicationIdIn);
        itemClassParMode := getItemClassParMode(itemClassIdIn => itemClassIds(i),
                                                applicationIdIn => applicationIdIn);
        itemClassSublistMode := getItemClassSublistMode(itemClassIdIn => itemClassIds(i),
                                                        applicationIdIn => applicationIdIn);
                                update ame_item_class_usages
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            item_class_id = itemClassIds(i) and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_item_class_usages(application_id,
                                          item_class_id,
                                          item_id_query,
                                          item_class_order_number,
                                          item_class_par_mode,
                                          item_class_sublist_mode,
                                          created_by,
                                          creation_date,
                                          last_updated_by,
                                          last_update_date,
                                          last_update_login,
                                          start_date,
                                          end_date)
          values(applicationIdIn,
                 itemClassIds(i),
                 itemClassIdQuery,
                 (orderNumbers(i) - 1),
                 itemClassParMode,
                 itemClassSublistMode,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 null);
      end loop;
                        if(finalizeIn) then
        commit;
      end if;
      exception
       when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'decrementItemClassOrderNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end decrementItemClassOrderNumbers;
/*
  procedure enableRuleStriping(applicationIdIn in integer,
                               commitIn in boolean default false) as
*/
    /*
      This procedure creates all necessary ame_rule_stripe_sets rows for the input
      transaction type, when a user enables rule striping.  At least one striping
      attribute must be selected for the input transaction type, before this
      procedure is called.
    */
/*
    cursor ruleCursor(applicationIdIn in integer) is
*/
      /* This cursor fetches the IDs of all rules used by the input transaction type. */
/*
      select rule_id
        from ame_rule_usages
        where
          item_id = applicationIdIn and
          (start_date <= sysdate and (end_date is null or sysdate < end_date));
*/
    /*
      This cursor fetches the attribute IDs and condition IDs of all striping conditions
      used by the input rule.
    */
/*
    cursor ruleStripingCondCursor(ruleIdIn in integer,
                                  stripingAttribute1IdIn in integer,
                                  stripingAttribute2IdIn in integer,
                                  stripingAttribute3IdIn in integer,
                                  stripingAttribute4IdIn in integer,
                                  stripingAttribute5IdIn in integer) is
      select
        ame_conditions.attribute_id,
        ame_conditions.condition_id
        from
          ame_conditions,
          ame_condition_usages
        where
          ame_condition_usages.rule_id = ruleIdIn and
          ame_condition_usages.condition_id = ame_conditions.condition_id and
          ame_conditions.condition_type = ame_util.ordinaryConditionType and
          (ame_conditions.attribute_id = stripingAttribute1IdIn or
           ame_conditions.attribute_id = stripingAttribute2IdIn or
           ame_conditions.attribute_id = stripingAttribute3IdIn or
           ame_conditions.attribute_id = stripingAttribute4IdIn or
           ame_conditions.attribute_id = stripingAttribute5IdIn) and
          (select count(*)
             from ame_string_values sv2
             where sv2.condition_id = ame_conditions.condition_id and
             (sv2.start_date <= sysdate and (sv2.end_date is null or sysdate < sv2.end_date))) = 1 and
          (ame_conditions.start_date <= sysdate and
           (ame_conditions.end_date is null or sysdate < ame_conditions.end_date)) and
          (ame_condition_usages.start_date <= sysdate and
           (ame_condition_usages.end_date is null or sysdate < ame_condition_usages.end_date));
    cursor stripingConditionCursor(applicationIdIn in integer,
                                   stripingAttributeIdIn in integer) is
*/
      /*
        This cursor fetches all active striping conditions for the input transaction type.  A
        condition qualifies as such if it is (1) ordinary, (2) defined on the input attribute ID,
        (3) has exactly one allowed (string) value, and (4) is used by at least one rule that the
        input transaction type uses.  The query's 'distinct' qualifier is necessary because
        several rule usages can reference the same condition ID.
      */
/*
      select distinct
        ame_conditions.condition_id,
        ame_string_values.string_value
        from
          ame_conditions,
          ame_condition_usages,
          ame_rule_usages,
          ame_string_values
        where
          ame_conditions.attribute_id = stripingAttributeIdIn and
          ame_conditions.condition_type = ame_util.ordinaryConditionType and
          ame_string_values.condition_id = ame_conditions.condition_id and
          ame_condition_usages.condition_id = ame_conditions.condition_id and
          ame_condition_usages.rule_id = ame_rule_usages.rule_id and
          ame_rule_usages.item_id = applicationIdIn and
          (select count(*)
             from ame_string_values sv2
             where sv2.condition_id = ame_conditions.condition_id and
             (sv2.start_date <= sysdate and (sv2.end_date is null or sysdate < sv2.end_date))) = 1 and
          (ame_conditions.start_date <= sysdate and
           (ame_conditions.end_date is null or sysdate < ame_conditions.end_date)) and
          (ame_condition_usages.start_date <= sysdate and
           (ame_condition_usages.end_date is null or sysdate < ame_condition_usages.end_date)) and
          (ame_rule_usages.start_date <= sysdate and
           (ame_rule_usages.end_date is null or sysdate < ame_rule_usages.end_date)) and
          (ame_string_values.start_date <= sysdate and
           (ame_string_values.end_date is null or sysdate < ame_string_values.end_date));
    errorCode integer;
    errorMessage ame_util.longStringType;
    noStripingAttsException exception;
    ruleIds ame_util.idList;
    stripingAttributeCount integer;
    stripingAttributeIds ame_util.idList;
    stripingConditionValues ame_util.stringList; */
                /* indexed by condition ID */
/*    tempAttributeIds ame_util.idList; */
/* indexed consecutively, reused */
/*    tempConditionIds ame_util.idList; */
/* indexed consecutively, reused */
/*    tempConditionValues ame_util.stringList; */
/* indexed consecutively, reused */
/*
    tempStripeSetId integer;
    begin
      ame_admin_pkg.getStripingAttributeIds(applicationIdIn => applicationIdIn,
                                            stripingAttributeIdsOut => stripingAttributeIds);
      stripingAttributeCount := stripingAttributeIds.count;
      if(stripingAttributeCount = 0) then
        raise noStripingAttsException;
      end if;
      for i in stripingAttributeCount + 1 .. 5 loop
        stripingAttributeIds(i) := null;
      end loop;
*/
      /*
        Fetch the condition IDs and string values for each ordinary equality condition
        on each striping attribute, where at least one rule in the current transaction
        type uses the condition.  Copy the string values into a list indexed by
        condition ID, so that code below this loop doesn't have to fetch striping
        conditions' allowed values one condition at a time, or fetch the same condition's
        allowed value several times.
      */
/*
      for i in 1 .. stripingAttributeCount loop
        open stripingConditionCursor(applicationIdIn => applicationIdIn,
                                     stripingAttributeIdIn => stripingAttributeIds(i));
        fetch stripingConditionCursor bulk collect
          into
            tempConditionIds,
            tempConditionValues;
        close stripingConditionCursor;
*/
        /* Copy the temp values into a list that is indexed by condition ID. */
/*
        for j in 1 .. tempConditionIds.count loop
          stripingConditionValues(tempConditionIds(j)) := tempConditionValues(j);
        end loop;
        tempConditionIds.delete;
        tempConditionValues.delete;
      end loop;
*/
      /* Fetch the rules used by this transaction type. */
/*
      open ruleCursor(applicationIdIn => applicationIdIn);
      fetch ruleCursor bulk collect into ruleIds;
      close ruleCursor;
      for i in 1 .. ruleIds.count loop
        tempAttributeIds.delete;
        tempConditionIds.delete;
        open ruleStripingCondCursor(ruleIdIn => ruleIds(i),
                                    stripingAttribute1IdIn => stripingAttributeIds(1),
                                    stripingAttribute2IdIn => stripingAttributeIds(2),
                                    stripingAttribute3IdIn => stripingAttributeIds(3),
                                    stripingAttribute4IdIn => stripingAttributeIds(4),
                                    stripingAttribute5IdIn => stripingAttributeIds(5));
        fetch ruleStripingCondCursor bulk collect
          into
            tempAttributeIds,
            tempConditionIds;
        close ruleStripingCondCursor;
        for j in 1 .. stripingAttributeCount loop
          tempConditionValues(j) := ame_util.stripeWildcard;
        end loop;
        for j in stripingAttributeCount + 1 .. 5 loop
          tempConditionValues(j) := null;
        end loop;
        for j in 1 .. tempAttributeIds.count loop
          for k in 1 .. stripingAttributeCount loop
            if(tempAttributeIds(j) = stripingAttributeIds(k)) then
              tempConditionValues(k) := stripingConditionValues(tempConditionIds(j));
            end if;
          end loop;
        end loop;
        tempStripeSetId := ame_admin_pkg.getStripeSetId(applicationIdIn => applicationIdIn,
                                                        attributeValuesIn => tempConditionValues);
        if(tempStripeSetId is null) then
          tempStripeSetId := ame_admin_pkg.newStripeSet(applicationIdIn => applicationIdIn,
                                                        attributeValuesIn => tempConditionValues);
        end if;
        ame_rule_pkg.newRuleStripeSet(applicationIdIn => applicationIdIn,
                                      ruleIdIn => ruleIds(i),
                                      stripeSetIdIn => tempStripeSetId);
      end loop;
      if(commitIn) then
        commit;
      end if;
      exception
        when noStripingAttsException then
          rollback;
          errorCode := -20001;
          errorMessage := 'At least one striping attribute must be selected to enable rule striping.  ';
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'enableRuleStriping',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(stripingConditionCursor%isopen) then
            close stripingConditionCursor;
          end if;
          if(ruleCursor%isopen) then
            close ruleCursor;
          end if;
          if(ruleStripingCondCursor%isopen) then
            close ruleStripingCondCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'enableRuleStriping',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end enableRuleStriping;
*/
/*
AME_STRIPING
  procedure getAttributeStripeSetNames(applicationIdIn in integer,
                                       stripingAttributeIdsOut out nocopy ame_util.idList,
                                       stripingAttributeNamesOut out nocopy ame_util.stringList) as
    attributeCount integer;
    attributeId1 integer;
    attributeId2 integer;
    attributeId3 integer;
    attributeId4 integer;
    attributeId5 integer;
    begin
      begin
        select to_number(value_1),
               to_number(value_2),
               to_number(value_3),
               to_number(value_4),
               to_number(value_5)
         into
               attributeId1,
               attributeId2,
               attributeId3,
               attributeId4,
               attributeId5
          from ame_stripe_sets
          where
            application_id = applicationIdIn and
            stripe_set_id = 0 and
            (start_date <= sysdate and
            (end_date is null or sysdate < end_date));
        exception
          when no_data_found then
            stripingAttributeIdsOut := ame_util.emptyIdList;
            stripingAttributeNamesOut := ame_util.emptyStringList;
            return;
      end;
      if(attributeId1 is not null) then
        stripingAttributeIdsOut(1) := attributeId1;
        stripingAttributeNamesOut(1) := ame_attribute_pkg.getName(attributeIdIn => attributeId1);
      end if;
      if(attributeId2 is not null) then
        stripingAttributeIdsOut(2) := attributeId2;
        stripingAttributeNamesOut(2) := ame_attribute_pkg.getName(attributeIdIn => attributeId2);
      end if;
      if (attributeId3 is not null) then
        stripingAttributeIdsOut(3) := attributeId3;
        stripingAttributeNamesOut(3) := ame_attribute_pkg.getName(attributeIdIn => attributeId3);
      end if;
      if (attributeId4 is not null) then
        stripingAttributeIdsOut(4) := attributeId4;
        stripingAttributeNamesOut(4) := ame_attribute_pkg.getName(attributeIdIn => attributeId4);
      end if;
      if(attributeId5 is not null) then
        stripingAttributeIdsOut(5) := attributeId5;
        stripingAttributeNamesOut(5) := ame_attribute_pkg.getName(attributeIdIn => attributeId5);
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getAttributeStripeSetNames',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          stripingAttributeIdsOut := ame_util.emptyIdList;
          stripingAttributeNamesOut := ame_util.emptyStringList;
          raise;
    end getAttributeStripeSetNames;
*/
  procedure getConfigVariables(applicationIdIn in integer default null,
                               variableNamesOut out nocopy ame_util.stringList,
                               descriptionsOut out nocopy ame_util.stringList) as
    cursor configVariablesCursor is
      select
        variable_name,
        description
        from ame_config_vars
        where
          application_id is null and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        order by variable_name;
    tempIndex integer;
    begin
      tempIndex := 1;
      /* First handle the default-values case. */
      if(applicationIdIn is null) then
        for tempRows in configVariablesCursor loop
          variableNamesOut(tempIndex) := tempRows.variable_name;
          descriptionsOut(tempIndex) := tempRows.description;
          tempIndex := tempIndex + 1;
        end loop;
        return;
      end if;
      /* Now handle the transaction-type case. */
      variableNamesOut(1) := ame_util.adminApproverConfigVar;
      descriptionsOut(1) := ame_util.getConfigDesc(variableNameIn => ame_util.adminApproverConfigVar);
      variableNamesOut(2) := ame_util.allowAllApproverTypesConfigVar;
      descriptionsOut(2) := ame_util.getConfigDesc(variableNameIn => ame_util.allowAllApproverTypesConfigVar);
      variableNamesOut(3) := ame_util.allowAllICRulesConfigVar;
      descriptionsOut(3) := ame_util.getConfigDesc(variableNameIn => ame_util.allowAllICRulesConfigVar);
      variableNamesOut(4) := ame_util.allowFyiNotificationsConfigVar;
      descriptionsOut(4) := ame_util.getConfigDesc(variableNameIn => ame_util.allowFyiNotificationsConfigVar);
      variableNamesOut(5) := ame_util.curConvWindowConfigVar;
      descriptionsOut(5) := ame_util.getConfigDesc(variableNameIn => ame_util.curConvWindowConfigVar);
      variableNamesOut(6) := ame_util.forwardingConfigVar;
      descriptionsOut(6) := ame_util.getConfigDesc(variableNameIn => ame_util.forwardingConfigVar);
      variableNamesOut(7) := ame_util.productionConfigVar;
      descriptionsOut(7) := ame_util.getConfigDesc(variableNameIn => ame_util.productionConfigVar);
      variableNamesOut(8) := ame_util.purgeFrequencyConfigVar;
      descriptionsOut(8) := ame_util.getConfigDesc(variableNameIn => ame_util.purgeFrequencyConfigVar);
      variableNamesOut(9) := ame_util.repeatedApproverConfigVar;
      descriptionsOut(9) := ame_util.getConfigDesc(variableNameIn => ame_util.repeatedApproverConfigVar);
      variableNamesOut(10) := ame_util.rulePriorityModesConfigVar;
      descriptionsOut(10) := ame_util.getConfigDesc(variableNameIn => ame_util.rulePriorityModesConfigVar);

/*
AME_STRIPING
      variableNamesOut(8) := ame_util.useRuleStripingConfigVar;
      descriptionsOut(8) := ame_util.getConfigDesc(variableNameIn => ame_util.useRuleStripingConfigVar);
*/
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getConfigVariables',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          variableNamesOut := ame_util.emptyStringList;
          descriptionsOut := ame_util.emptyStringList;
          raise;
    end getConfigVariables;
  procedure getExistingShareableIClasses(applicationIdIn in integer,
                                         itemClassIdsOut out nocopy ame_util.stringList,
                                         itemClassNamesOut out nocopy ame_util.stringList) as
    cursor unusedItemClassCursor(applicationIdIn in integer) is
      select
        item_class_id,
        name
      from
        ame_item_classes
      where
        (start_date <= sysdate and
        (end_date is null or sysdate < end_date))
      minus
      select
        ame_item_classes.item_class_id,
        name
      from
        ame_item_classes,
        ame_item_class_usages
      where
        ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
        ame_item_class_usages.application_id = applicationIdIn and
        sysdate between ame_item_classes.start_date and
                 nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
        sysdate between ame_item_class_usages.start_date and
                 nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate)
        order by name;
    tempIndex integer;
      begin
        tempIndex := 1;
        for tempItemClass in unusedItemClassCursor(applicationIdIn => applicationIdIn) loop
          /* The explicit conversion below lets nocopy work. */
          itemClassIdsOut(tempIndex) := to_char(tempItemClass.item_class_id);
          itemClassNamesOut(tempIndex) := tempItemClass.name;
          tempIndex := tempIndex + 1;
        end loop;
        exception
          when others then
            rollback;
            ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                      routineNameIn => 'getExistingShareableIClasses',
                                      exceptionNumberIn => sqlcode,
                                      exceptionStringIn => '(application ID ' ||
                                                        applicationIdIn||
                                                        ') ' ||
                                                        sqlerrm);
            itemClassIdsOut := ame_util.emptyStringList;
            itemClassNamesOut := ame_util.emptyStringList;
            raise;
        end getExistingShareableIClasses;
  procedure getFndApplications(fndAppIdsOut out nocopy ame_util.stringList,
                               fndAppNamesOut out nocopy ame_util.stringList) as
    cursor fndAppNamesCursor is
      select
        application_id,
        substrb(ltrim(application_name),1,99) application_name
        from fnd_application_vl
       order by application_name;
    tempIndex integer;
    begin
      tempIndex := 0;
      for tempRows in fndAppNamesCursor loop
        tempIndex := tempIndex + 1;
        /* The explicit conversion below lets nocopy work. */
        fndAppIdsOut(tempIndex) := to_char(tempRows.application_id);
        fndAppNamesOut(tempIndex) := tempRows.application_name;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getFndApplications',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          fndAppIdsOut := ame_util.emptyStringList;
          fndAppNamesOut := ame_util.emptyStringList;
          raise;
    end getFndApplications;
  procedure getForwardingBehaviorList(forwardingBehaviorIn in integer,
                                      forwardingBehaviorValuesOut out nocopy ame_util.stringList,
                                      forwardingBehaviorLabelsOut out nocopy ame_util.stringList) as
  valueIndex integer;
  begin
    valueIndex := 1;
    if(forwardingBehaviorIn in (1,2,5,6)) then
      forwardingBehaviorValuesOut(valueIndex) := ame_util.remand;
      forwardingBehaviorLabelsOut(valueIndex) := ame_util.getLabel(ame_util.perFndAppId,'AME_REMAND');
      valueIndex := valueIndex + 1;
    end if;
    forwardingBehaviorValuesOut(valueIndex) := ame_util.forwarderAndForwardee;
    forwardingBehaviorLabelsOut(valueIndex) := ame_util.getLabel(ame_util.perFndAppId,'AME_FOR_TO_FORWARDER_FORWARDEE');
    valueIndex := valueIndex +1;
    forwardingBehaviorValuesOut(valueIndex) := ame_util.forwardeeOnly;
    forwardingBehaviorLabelsOut(valueIndex) := ame_util.getLabel(ame_util.perFndAppId,'AME_FOR_TO_FORWARDEE_ONLY');
    valueIndex := valueIndex +1;
    if(forwardingBehaviorIn in (3,4)) then
       forwardingBehaviorValuesOut(valueIndex) := ame_util.repeatForwarder;
       forwardingBehaviorLabelsOut(valueIndex) := ame_util.getLabel(ame_util.perFndAppId,'AME_REPEAT_FORWARDER');
       valueIndex := valueIndex + 1;
       forwardingBehaviorValuesOut(valueIndex) := ame_util.skipForwarder;
       forwardingBehaviorLabelsOut(valueIndex) := ame_util.getLabel(ame_util.perFndAppId,'AME_SKIP_FORWARDER');
       valueIndex := valueIndex + 1;
    end if;
    forwardingBehaviorValuesOut(valueIndex) := ame_util.ignoreForwarding;
    forwardingBehaviorLabelsOut(valueIndex) := ame_util.getLabel(ame_util.perFndAppId,'AME_IGNORE_FORWARDING');
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                  routineNameIn => 'getForwardingBehaviorList',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        forwardingBehaviorValuesOut := ame_util.emptyStringList;
        forwardingBehaviorLabelsOut := ame_util.emptyStringList;
        raise;
  end getForwardingBehaviorList;
  procedure getItemClassList(applicationIdIn in integer,
                             itemClassIdListOut out nocopy ame_util.idList,
                             itemClassNameListOut out nocopy ame_util.stringList,
                             itemClassOrderNumbersOut out nocopy ame_util.idList) as
    cursor itemClassCursor(applicationIdIn in integer) is
      select ame_item_classes.item_class_id,
             ame_item_classes.name,
             ame_item_class_usages.item_class_order_number
        from ame_item_classes,
             ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          sysdate between ame_item_classes.start_date and
            nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_item_class_usages.start_date and
            nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate)
        order by ame_item_class_usages.item_class_order_number;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempItemClass in itemClassCursor(applicationIdIn => applicationIdIn) loop
        itemClassIdListOut(tempIndex) := tempItemClass.item_class_id;
        itemClassNameListOut(tempIndex) := tempItemClass.name;
        itemClassOrderNumbersOut(tempIndex) := tempItemClass.item_class_order_number;
        tempIndex := tempIndex + 1;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getItemClassList',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          itemClassIdListOut := ame_util.emptyIdList;
          itemClassNameListOut := ame_util.emptyStringList;
          raise;
    end getItemClassList;
/*
AME_STRIPING
  procedure getStripeSetIds(applicationIdIn in integer,
                            stripeSetIdsOut out nocopy ame_util.idList) as
  cursor getStripeSetIdsCursor(applicationIdIn in integer) is
    select stripe_set_id
      from ame_stripe_sets
      where
        application_id = applicationIdIn and
        (start_date <= sysdate and
        (end_date is null or sysdate < end_date))
      order by stripe_set_id;
  tempIndex integer;
  begin
    tempIndex := 1;
    for getStripeSetIdsRec in getStripeSetIdsCursor(applicationIdIn => applicationIdIn) loop
      stripeSetIdsOut(tempIndex) := getStripeSetIdsRec.stripe_set_id;
      tempIndex := tempIndex + 1;
    end loop;
    exception
      when others then
        rollback;
        ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                  routineNameIn => 'getStripeSetIds',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        stripeSetIdsOut := ame_util.emptyIdList;
        raise;
  end getStripeSetIds;
*/
/*
AME_STRIPING
  procedure getStripeSetList(applicationIdIn in integer,
                             attributeValues1In in ame_util.stringList default ame_util.emptyStringList,
                             attributeValues2In in ame_util.stringList default ame_util.emptyStringList,
                             attributeValues3In in ame_util.stringList default ame_util.emptyStringList,
                             attributeValues4In in ame_util.stringList default ame_util.emptyStringList,
                             attributeValues5In in ame_util.stringList default ame_util.emptyStringList,
                             attributeValues1Out out nocopy ame_util.stringList,
                             attributeValues2Out out nocopy ame_util.stringList,
                             attributeValues3Out out nocopy ame_util.stringList,
                             attributeValues4Out out nocopy ame_util.stringList,
                             attributeValues5Out out nocopy ame_util.stringList,
                             stripeSetIdListOut out nocopy ame_util.idList) as
    attributeCur ame_util.queryCursor;
    attributeValues1Count integer;
    attributeValues2Count integer;
    attributeValues3Count integer;
    attributeValues4Count integer;
    attributeValues5Count integer;
    constraintValues ame_util.longestStringType;
    dynamicQuery ame_util.longestStringType;
    stripeSetId integer;
    value1 ame_stripe_sets.value_1%type;
    value2 ame_stripe_sets.value_2%type;
    value3 ame_stripe_sets.value_3%type;
    value4 ame_stripe_sets.value_4%type;
    value5 ame_stripe_sets.value_5%type;
    tempCount integer;
    tempIndex integer;
    begin
      attributeValues1Count := attributeValues1In.count;
      if(attributeValues1Count > 0) then
        constraintValues := ' and value_1 in (';
        for i in 1..attributeValues1Count loop
          if i = attributeValues1Count then
            constraintValues := constraintValues ||''''|| attributeValues1In(i) || ''')';
          else
            constraintValues := constraintValues ||''''|| attributeValues1In(i) ||''',';
          end if;
        end loop;
      end if;
      attributeValues2Count := attributeValues2In.count;
      if(attributeValues2Count > 0) then
        constraintValues := constraintValues ||' and value_2 in (';
        for i in 1..attributeValues2Count loop
          if i = attributeValues2Count then
            constraintValues := constraintValues ||''''|| attributeValues2In(i) ||''')';
          else
            constraintValues := constraintValues ||''''|| attributeValues2In(i) ||''',';
          end if;
        end loop;
      end if;
      attributeValues3Count := attributeValues3In.count;
      if(attributeValues3Count > 0) then
        constraintValues := constraintValues ||' and value_3 in (';
        for i in 1..attributeValues3Count loop
          if i = attributeValues3Count then
            constraintValues := constraintValues ||''''|| attributeValues3In(i) ||''')';
          else
            constraintValues := constraintValues ||''''|| attributeValues3In(i) ||''',';
          end if;
        end loop;
      end if;
      attributeValues4Count := attributeValues4In.count;
      if(attributeValues4Count > 0) then
        constraintValues := constraintValues ||' and value_4 in (';
        for i in 1..attributeValues4Count loop
          if i = attributeValues4Count then
            constraintValues := constraintValues ||''''|| attributeValues4In(i) ||''')';
          else
            constraintValues := constraintValues ||''''|| attributeValues4In(i) ||''',';
          end if;
        end loop;
      end if;
      attributeValues5Count := attributeValues5In.count;
      if(attributeValues5Count > 0) then
        constraintValues := constraintValues ||' and value_5 in (';
        for i in 1..attributeValues5Count loop
          if i = attributeValues5Count then
            constraintValues := constraintValues ||''''|| attributeValues5In(i) ||''')';
          else
            constraintValues := constraintValues ||''''|| attributeValues5In(i) ||''',';
          end if;
        end loop;
      end if;
      dynamicQuery :=
        'select stripe_set_id,
                value_1,
                value_2,
                value_3,
                value_4,
                value_5' ||
        ' from ame_stripe_sets where application_id = ' ||
        applicationIdIn ||
        constraintValues ||
        ' and stripe_set_id <> 0 and start_date <= sysdate and (end_date is null or sysdate < end_date)';
     attributeCur := getAttributeQuery(selectClauseIn => dynamicQuery);
     tempIndex := 1;
     loop
       fetch attributeCur
         into stripeSetId,
              value1,
              value2,
              value3,
              value4,
              value5;
         exit when attributeCur%notfound;
         stripeSetIdListOut(tempIndex) := stripeSetId;
         attributeValues1Out(tempIndex) := value1;
         attributeValues2Out(tempIndex) := value2;
         attributeValues3Out(tempIndex) := value3;
         attributeValues4Out(tempIndex) := value4;
         attributeValues5Out(tempIndex) := value5;
         tempIndex := tempIndex + 1;
     end loop;
     close attributeCur;
     exception
       when others then
         rollback;
         ame_util.runtimeException(packageNamein => 'ame_admin_pkg',
                                   routineNamein => 'getStripeSetList',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         attributeValues1Out := ame_util.emptyStringList;
         attributeValues2Out := ame_util.emptyStringList;
         attributeValues3Out := ame_util.emptyStringList;
         attributeValues4Out := ame_util.emptyStringList;
         attributeValues5Out := ame_util.emptyStringList;
         stripeSetIdListOut := ame_util.emptyIdList;
    end getStripeSetList;
*/
/*
AME_STRIPING
  procedure getStripingAttributeIds(applicationIdIn in integer,
                                    stripingAttributeIdsOut out nocopy ame_util.idList) as
    valueColumns ame_util.idList;
    begin
      select
        to_number(value_1),
        to_number(value_2),
        to_number(value_3),
        to_number(value_4),
        to_number(value_5)
        into
          valueColumns(1),
          valueColumns(2),
          valueColumns(3),
          valueColumns(4),
          valueColumns(5)
        from ame_stripe_sets
        where
          application_id = applicationIdIn and
          stripe_set_id = 0 and
          (start_date <= sysdate and
           (end_date is null or sysdate < end_date));
      for i in 1 .. 5 loop
        if(valueColumns(i) is null) then
          exit;
        end if;
        stripingAttributeIdsOut(i) := valueColumns(i);
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                  routineNameIn => 'getStripingAttributeIds',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);

          stripingAttributeIdsOut := ame_util.emptyIdList;
          raise;
    end getStripingAttributeIds;
*/
/*
AME_STRIPING
  procedure getStripingAttributeNames(applicationIdIn in integer,
                                      stripingAttributeNamesOut out nocopy ame_util.stringList) as
    valueColumns ame_util.idList;
    begin
      select
        to_number(value_1),
        to_number(value_2),
        to_number(value_3),
        to_number(value_4),
        to_number(value_5)
        into
          valueColumns(1),
          valueColumns(2),
          valueColumns(3),
          valueColumns(4),
          valueColumns(5)
        from ame_stripe_sets
        where
          application_id = applicationIdIn and
          stripe_set_id = 0 and
          (start_date <= sysdate and
           (end_date is null or sysdate < end_date));
      for i in 1 .. 5 loop
        if(valueColumns(i) is null) then
          exit;
        end if;
        stripingAttributeNamesOut(i) := ame_attribute_pkg.getName(attributeIdIn => valueColumns(i));
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getStripingAttributeNames',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          stripingAttributeNamesOut := ame_util.emptyStringList;
          raise;
    end getStripingAttributeNames;
*/
/*
AME_STRIPING
  procedure getStripingAttributeValues(applicationIdIn in integer,
                                       stripingAttributeIdsOut out nocopy ame_util.stringList,
                                       stripingAttributeNamesOut out nocopy ame_util.stringList,
                                       allowedStripeValues1Out out nocopy ame_util.stringList,
                                       allowedStripeValues2Out out nocopy ame_util.stringList,
                                       allowedStripeValues3Out out nocopy ame_util.stringList,
                                       allowedStripeValues4Out out nocopy ame_util.stringList,
                                       allowedStripeValues5Out out nocopy ame_util.stringList) as
  attributeCur ame_util.queryCursor;
  attributeIds ame_util.idList;
  dynamicCursor integer;
  dynamicQuery ame_util.longestStringType;
  tempIndex integer;
  tempValue1 ame_stripe_sets.value_1%type;
  tempValueList ame_util.stringList;
  upperLimit integer;
  upperLimit2 integer;
  begin
    select value_1,
           value_2,
           value_3,
           value_4,
           value_5
      into
           attributeIds(1),
           attributeIds(2),
           attributeIds(3),
           attributeIds(4),
           attributeIds(5)
      from ame_stripe_sets
      where
        application_id = applicationIdIn and
        stripe_set_id = 0 and
        (start_date <= sysdate and
        (end_date is null or sysdate < end_date));
    for i in 1 .. 5 loop
      if(attributeIds(i) is null) then
        exit;
      end if;
      stripingAttributeIdsOut(i) := attributeIds(i);
      stripingAttributeNamesOut(i) := ame_attribute_pkg.getName(attributeIdIn => attributeIds(i));
    end loop;
    upperLimit := stripingAttributeIdsOut.count;
    for i in 1 .. upperLimit loop
      tempValueList.delete;
      dynamicQuery :=
        'select distinct(nvl(value_' ||
        i || ', ''NULL''))' ||
        ' from ame_stripe_sets where application_id = ' ||
        applicationIdIn ||
        ' and stripe_set_id <> 0 and start_date <= sysdate and (end_date is null or sysdate < end_date)';
      attributeCur := getAttributeQuery(selectClauseIn => dynamicQuery);
      tempIndex := 1;
      loop
        fetch attributeCur into tempValue1;
        exit when attributeCur%notfound;
        tempValueList(tempIndex) := tempValue1;
        tempIndex := tempIndex + 1;
      end loop;
      close attributeCur;
      upperLimit2 := tempValueList.count;
      if(i = 1) then
        for j in 1 .. upperLimit2 loop
          allowedStripeValues1Out(j) := tempValueList(j);
        end loop;
      elsif(i = 2) then
        for j in 1 .. upperLimit2 loop
          allowedStripeValues2Out(j) := tempValueList(j);
        end loop;
      elsif(i = 3) then
        for j in 1 .. upperLimit2 loop
          allowedStripeValues3Out(j) := tempValueList(j);
        end loop;
      elsif(i = 4) then
        for j in 1 .. upperLimit2 loop
          allowedStripeValues4Out(j) := tempValueList(j);
        end loop;
      elsif(i = 5) then
        for j in 1 .. upperLimit2 loop
          allowedStripeValues5Out(j) := tempValueList(j);
        end loop;
      end if;
    end loop;
    exception
      when others then
        rollback;
        if(dbms_sql.is_open(dynamicCursor)) then
          dbms_sql.close_cursor(dynamicCursor);
        end if;
        ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                  routineNameIn => 'getStripingAttributeValues',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        stripingAttributeIdsOut := ame_util.emptyStringList;
        stripingAttributeNamesOut := ame_util.emptyStringList;
        allowedStripeValues1Out := ame_util.emptyStringList;
        allowedStripeValues2Out := ame_util.emptyStringList;
        allowedStripeValues3Out := ame_util.emptyStringList;
        allowedStripeValues4Out := ame_util.emptyStringList;
        allowedStripeValues5Out := ame_util.emptyStringList;
        raise;
  end getStripingAttributeValues;
*/
/*
  procedure getStripingAttributeValues2(applicationIdIn in integer,
                                        stripeSetIdIn in integer,
                                        stripingAttributeIdsOut out nocopy ame_util.stringList,
                                        stripingAttributeNamesOut out nocopy ame_util.stringList,
                                        stripeValue1Out out nocopy varchar2,
                                        stripeValue2Out out nocopy varchar2,
                                        stripeValue3Out out nocopy varchar2,
                                        stripeValue4Out out nocopy varchar2,
                                        stripeValue5Out out nocopy varchar2) as
  attributeIds ame_util.idList;
  attributeCur ame_util.queryCursor;
  dynamicCursor integer;
  dynamicQuery ame_util.longestStringType;
  errorCode integer;
  errorMessage varchar2(200);
  tempIndex integer;
  tempValue1 ame_stripe_sets.value_1%type;
  tempValueList ame_util.stringList;
  upperLimit integer;
  begin
    select value_1,
           value_2,
           value_3,
           value_4,
           value_5
      into
           attributeIds(1),
           attributeIds(2),
           attributeIds(3),
           attributeIds(4),
           attributeIds(5)
      from ame_stripe_sets
      where
        application_id = applicationIdIn and
        stripe_set_id = 0 and
        (start_date <= sysdate and
        (end_date is null or sysdate < end_date));
    for i in 1 .. 5 loop
      if(attributeIds(i) is null) then
        exit;
      end if;
      stripingAttributeIdsOut(i) := attributeIds(i);
      stripingAttributeNamesOut(i) := ame_attribute_pkg.getName(attributeIdIn => attributeIds(i));
    end loop;
    upperLimit := stripingAttributeIdsOut.count;
    for i in 1 .. upperLimit loop
      tempValueList.delete;
      dynamicQuery :=
        'select value_' ||
        i ||
        ' from ame_stripe_sets where application_id = ' ||
        applicationIdIn ||
        ' and stripe_set_id = ' || stripeSetIdIn || ' and start_date <= sysdate and (end_date is null or sysdate < end_date)';
      attributeCur := getAttributeQuery(selectClauseIn => dynamicQuery);
      tempIndex := 1;
      loop
        fetch attributeCur into tempValue1;
        exit when attributeCur%notfound;
        tempValueList(tempIndex) := tempValue1;
        tempIndex := tempIndex + 1;
      end loop;
      close attributeCur;
      if(i = 1) then
        stripeValue1Out := tempValueList(1);
      elsif(i = 2) then
        stripeValue2Out := tempValueList(1);
      elsif(i = 3) then
        stripeValue3Out := tempValueList(1);
      elsif(i = 4) then
        stripeValue4Out := tempValueList(1);
      elsif(i = 5) then
        stripeValue5Out := tempValueList(1);
      end if;
    end loop;
    exception
      when others then
        rollback;
        if(dbms_sql.is_open(dynamicCursor)) then
          dbms_sql.close_cursor(dynamicCursor);
        end if;
        ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                  routineNameIn => 'getStripingAttributeValues2',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        stripingAttributeIdsOut := ame_util.emptyStringList;
        stripingAttributeNamesOut := ame_util.emptyStringList;
        stripeValue1Out := null;
        stripeValue2Out := null;
        stripeValue3Out := null;
        stripeValue4Out := null;
        stripeValue5Out := null;
        raise;
  end getStripingAttributeValues2;
*/
/*
AME_STRIPING
  procedure getStripingAttributeValues3(applicationIdIn in integer,
                                        stripeSetIdIn in integer,
                                        stripeValue1Out out nocopy varchar2,
                                        stripeValue2Out out nocopy varchar2,
                                        stripeValue3Out out nocopy varchar2,
                                        stripeValue4Out out nocopy varchar2,
                                        stripeValue5Out out nocopy varchar2) as
    begin
      select
        value_1,
        value_2,
        value_3,
        value_4,
        value_5
        into
          stripeValue1Out,
          stripeValue2Out,
          stripeValue3Out,
          stripeValue4Out,
          stripeValue5Out
        from ame_stripe_sets
        where
          application_id = applicationIdIn and
          stripe_set_id = stripeSetIdIn and
          (start_date <= sysdate and (end_date is null or sysdate < end_date));
      exception
        when others then
          rollback;
          stripeValue1Out := null;
          stripeValue2Out := null;
          stripeValue3Out := null;
          stripeValue4Out := null;
          stripeValue5Out := null;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getStripingAttributeValues3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end getStripingAttributeValues3;
*/
  procedure getTransExceptions(applicationIdIn in integer,
                               transactionIdIn in  varchar2,
                               exceptionLogOut out nocopy ame_util.exceptionLogTable) as
    cursor exceptionLogCursor is
      select *
      from  ame_exceptions_log
      where
        application_id = applicationIdIn and
        transaction_id = transactionIdIn
      order by log_id desc;
    logLength integer;
    tempIndex integer;
    workflowLog ame_util.workflowLogTable;
    begin
      tempIndex := 1;
      /* Fetch local log. */
      for tempLog in exceptionLogCursor loop
        exceptionLogOut(tempIndex).log_id := tempLog.log_id;
        exceptionLogOut(tempIndex).package_name := tempLog.package_name;
        exceptionLogOut(tempIndex).routine_name := tempLog.routine_name;
        exceptionLogOut(tempIndex).transaction_id := tempLog.transaction_id;
        exceptionLogOut(tempIndex).application_id := tempLog.application_id;
        exceptionLogOut(tempIndex).exception_number := tempLog.exception_number;
        exceptionLogOut(tempIndex).exception_string := tempLog.exception_string;
        tempIndex := tempIndex + 1;
       end loop;
      /*
        If the log is in the Workflow table and it's not in the AME table,
        then fetch the log from Workflow.
      */
      if(ame_util.useWorkflow(transactionIdIn => transactionIdIn,
                              applicationIdIn => applicationIdIn) and
         ame_util.getConfigVar(variableNameIn => ame_util.distEnvConfigVar) = ame_util.yes) then
        getWorkflowLog(applicationIdIn => applicationIdIn,
                       transactionIdIn => transactionIdIn,
                       logOut => workflowLog);
        logLength := workflowLog.count;
        for i in 1 .. logLength loop
          exceptionLogOut(tempIndex).log_id := workflowLog(i).log_id;
          exceptionLogOut(tempIndex).package_name := workflowLog(i).package_name;
          exceptionLogOut(tempIndex).routine_name := workflowLog(i).routine_name;
          exceptionLogOut(tempIndex).transaction_id := workflowLog(i).transaction_id;
          exceptionLogOut(tempIndex).application_id := applicationIdIn;
          exceptionLogOut(tempIndex).exception_number := workflowLog(i).exception_number;
          exceptionLogOut(tempIndex).exception_string := workflowLog(i).exception_string;
          tempIndex := tempIndex + 1;
        end loop;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getTransExceptions',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          exceptionLogOut := ame_util.emptyExceptionLogTable;
          raise;
    end getTransExceptions;
  procedure getTransTypeExceptions1(applicationIdIn in integer,
                                    exceptionLogOut out nocopy ame_util.exceptionLogTable) as
    cursor exceptionLogCursor(applicationIdIn in integer) is
      select *
      from ame_exceptions_log
      where application_id = applicationIdIn
      order by log_id desc;
    logLength integer;
    tempIndex integer;
    workflowLog ame_util.workflowLogTable;
    begin
      tempIndex := 1;
      /* Always fetch the log in the AME table. */
      for tempLog in exceptionLogCursor(applicationIdIn => applicationIdIn) loop
        exceptionLogOut(tempIndex).log_id := tempLog.log_id;
        exceptionLogOut(tempIndex).package_name := tempLog.package_name;
        exceptionLogOut(tempIndex).routine_name := tempLog.routine_name;
        exceptionLogOut(tempIndex).transaction_id := tempLog.transaction_id;
        exceptionLogOut(tempIndex).application_id := tempLog.application_id;
        exceptionLogOut(tempIndex).exception_number := tempLog.exception_number;
        exceptionLogOut(tempIndex).exception_string := tempLog.exception_string;
        tempIndex := tempIndex + 1;
      end loop;
      /*
        If the log is in the Workflow table and it's not in the AME table,
        then fetch the log from Workflow.
      */
      if(ame_util.useWorkflow(applicationIdIn => applicationIdIn) and
         ame_util.getConfigVar(variableNameIn => ame_util.distEnvConfigVar) = ame_util.yes) then
        getWorkflowLog(applicationIdIn => applicationIdIn,
                       transactionIdIn => null,
                       logOut => workflowLog);
        logLength := workflowLog.count;
        for i in 1 .. logLength loop
          exceptionLogOut(tempIndex).log_id := workflowLog(i).log_id;
          exceptionLogOut(tempIndex).package_name := workflowLog(i).package_name;
          exceptionLogOut(tempIndex).routine_name := workflowLog(i).routine_name;
          exceptionLogOut(tempIndex).transaction_id := workflowLog(i).transaction_id;
          exceptionLogOut(tempIndex).application_id := applicationIdIn;
          exceptionLogOut(tempIndex).exception_number := workflowLog(i).exception_number;
          exceptionLogOut(tempIndex).exception_string := workflowLog(i).exception_string;
          tempIndex := tempIndex + 1;
        end loop;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getTransTypeExceptions1',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
         exceptionLogOut := ame_util.emptyExceptionLogTable;
         raise;
    end getTransTypeExceptions1;
  procedure getTransTypeExceptions2(applicationIdIn in integer,
                                    exceptionLogOut out nocopy ame_util.exceptionLogTable) as
    cursor exceptionLogCursor is
      select *
      from ame_exceptions_log
      where application_id = applicationIdIn
      order by
        package_name,
        routine_name;
    tempIndex integer;
    logLength integer;
    workflowLog ame_util.workflowLogTable;
    begin
      tempIndex := 1;
      /* Fetch local log. */
      for tempLog in exceptionLogCursor loop
        exceptionLogOut(tempIndex).log_id := tempLog.log_id;
        exceptionLogOut(tempIndex).package_name := tempLog.package_name;
        exceptionLogOut(tempIndex).routine_name := tempLog.routine_name;
        exceptionLogOut(tempIndex).transaction_id := tempLog.transaction_id;
        exceptionLogOut(tempIndex).application_id := tempLog.application_id;
        exceptionLogOut(tempIndex).exception_number := tempLog.exception_number;
        exceptionLogOut(tempIndex).exception_string := tempLog.exception_string;
        tempIndex := tempIndex + 1;
      end loop;
      /*
        If the log is in the Workflow table and it's not in the AME table,
        then fetch the log from Workflow.
      */
      if(ame_util.useWorkflow(applicationIdIn => applicationIdIn) and
         ame_util.getConfigVar(variableNameIn => ame_util.distEnvConfigVar) = ame_util.yes) then
        getWorkflowLog(applicationIdIn => applicationIdIn,
                       transactionIdIn => null,
                       logOut => workflowLog);
        logLength := workflowLog.count;
        for i in 1 .. logLength loop
          exceptionLogOut(tempIndex).log_id := workflowLog(i).log_id;
          exceptionLogOut(tempIndex).package_name := workflowLog(i).package_name;
          exceptionLogOut(tempIndex).routine_name := workflowLog(i).routine_name;
          exceptionLogOut(tempIndex).transaction_id := workflowLog(i).transaction_id;
          exceptionLogOut(tempIndex).application_id := applicationIdIn;
          exceptionLogOut(tempIndex).exception_number := workflowLog(i).exception_number;
          exceptionLogOut(tempIndex).exception_string := workflowLog(i).exception_string;
          tempIndex := tempIndex + 1;
        end loop;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getTransTypeExceptions2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          exceptionLogOut := ame_util.emptyExceptionLogTable;
          raise;
    end getTransTypeExceptions2;
  procedure getTransactionTypes(applicationIdsOut out nocopy ame_util.idList,
                                applicationNamesOut out nocopy ame_util.stringList,
                                transactionTypesOut out nocopy ame_util.stringList,
                                createdByOut out nocopy ame_util.idList) as
    cursor applicationsCursor is
      select
        fnd_application_id,
        application_id,
        created_by,
        application_name,
        transaction_type_id
      from
        ame_calling_apps
      where
        sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
      order by application_name;
    tempIndex integer;
    begin
      tempIndex := 0;
      for tempTransType in applicationsCursor loop
        tempIndex := tempIndex + 1;
        applicationIdsOut(tempIndex) := tempTransType.application_id;
        applicationNamesOut(tempIndex) := tempTransType.application_name;
        transactionTypesOut(tempIndex) := tempTransType.transaction_type_id;
        createdByOut(tempIndex) := tempTransType.created_by;
      end loop;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getTransactionTypes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          applicationIdsOut := ame_util.emptyIdList;
          applicationNamesOut := ame_util.emptyStringList;
          transactionTypesOut := ame_util.emptyStringList;
          createdByOut := ame_util.emptyIdList;
          raise;
    end getTransactionTypes;
  procedure getTransTypeItemClasses(applicationIdIn in integer,
                                    itemClassIdsOut out nocopy ame_util.stringList,
                                    itemClassNamesOut out nocopy ame_util.stringList) as
    cursor getItemClassesCursor(applicationIdIn in integer) is
      select ame_item_classes.item_class_id,
             ame_item_classes.name
        from ame_item_classes,
             ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          sysdate between ame_item_classes.start_date and
                 nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_item_class_usages.start_date and
                 nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate)
        order by ame_item_class_usages.item_class_order_number;
    begin
      open getItemClassesCursor(applicationIdIn => applicationIdIn);
        fetch getItemClassesCursor bulk collect
          into itemClassIdsOut,
               itemClassNamesOut;
      close getItemClassesCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getTransTypeItemClasses',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          itemClassIdsOut := ame_util.emptyStringList;
          itemClassNamesOut := ame_util.emptyStringList;
          raise;
    end getTransTypeItemClasses;
  procedure getTransTypeItemClasses2(applicationIdIn in integer,
                                     itemClassIdsOut out nocopy ame_util.idList,
                                     itemClassNamesOut out nocopy ame_util.stringList) as
    cursor getItemClassesCursor(applicationIdIn in integer) is
      select ame_item_classes.item_class_id,
             ame_item_classes.name
        from ame_item_classes,
             ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_item_classes.name <> ame_util.headerItemClassName and
          sysdate between ame_item_classes.start_date and
                 nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_item_class_usages.start_date and
                 nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate)
        order by ame_item_class_usages.item_class_order_number;
    begin
      open getItemClassesCursor(applicationIdIn => applicationIdIn);
        fetch getItemClassesCursor bulk collect
          into itemClassIdsOut,
               itemClassNamesOut;
      close getItemClassesCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getTransTypeItemClasses2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          itemClassIdsOut := ame_util.emptyIdList;
          itemClassNamesOut := ame_util.emptyStringList;
          raise;
    end getTransTypeItemClasses2;
  procedure getTransTypeItemClasses3(applicationIdIn in integer,
                                     itemClassIdsOut out nocopy ame_util.idList,
                                     itemClassNamesOut out nocopy ame_util.stringList) as
    cursor getItemClassesCursor(applicationIdIn in integer) is
      select ame_item_classes.item_class_id,
             ame_item_classes.name
        from ame_item_classes,
             ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          sysdate between ame_item_classes.start_date and
                 nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_item_class_usages.start_date and
                 nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate)
        order by ame_item_class_usages.item_class_order_number,
                 ame_item_classes.name;
    begin
      open getItemClassesCursor(applicationIdIn => applicationIdIn);
        fetch getItemClassesCursor bulk collect
          into itemClassIdsOut,
               itemClassNamesOut;
      close getItemClassesCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getTransTypeItemClasses3',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          itemClassIdsOut := ame_util.emptyIdList;
          itemClassNamesOut := ame_util.emptyStringList;
          raise;
    end getTransTypeItemClasses3;
  procedure getTransTypeItemClasses4(applicationIdIn in integer,
                                     itemClassIdsOut out nocopy ame_util.stringList,
                                     itemClassNamesOut out nocopy ame_util.stringList) as
    cursor getItemClassesCursor(applicationIdIn in integer) is
      select ame_item_classes.item_class_id,
             ame_item_classes.name
        from ame_item_classes,
             ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          ame_item_classes.name <> ame_util.headerItemClassName and
          sysdate between ame_item_classes.start_date and
                 nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_item_class_usages.start_date and
                 nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate)
        order by ame_item_class_usages.item_class_order_number;
    begin
      open getItemClassesCursor(applicationIdIn => applicationIdIn);
        fetch getItemClassesCursor bulk collect
          into itemClassIdsOut,
               itemClassNamesOut;
      close getItemClassesCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getTransTypeItemClasses4',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          itemClassIdsOut := ame_util.emptyStringList;
          itemClassNamesOut := ame_util.emptyStringList;
          raise;
    end getTransTypeItemClasses4;
  procedure getTransTypeItemClassIds(applicationIdIn in integer,
                                     itemClassIdsOut out nocopy ame_util.idList) as
    cursor getItemClassesCursor(applicationIdIn in integer) is
      select ame_item_classes.item_class_id
        from ame_item_classes,
             ame_item_class_usages
        where
          ame_item_classes.item_class_id = ame_item_class_usages.item_class_id and
          ame_item_class_usages.application_id = applicationIdIn and
          sysdate between ame_item_classes.start_date and
                 nvl(ame_item_classes.end_date - ame_util.oneSecond, sysdate) and
           sysdate between ame_item_class_usages.start_date and
                 nvl(ame_item_class_usages.end_date - ame_util.oneSecond, sysdate)
        order by ame_item_class_usages.item_class_order_number;
    begin
      open getItemClassesCursor(applicationIdIn => applicationIdIn);
        fetch getItemClassesCursor bulk collect
          into itemClassIdsOut;
      close getItemClassesCursor;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getTransTypeItemClassIds',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          itemClassIdsOut := ame_util.emptyIdList;
          raise;
    end getTransTypeItemClassIds;
  procedure getWebExceptions(exceptionLogOut out nocopy ame_util.exceptionLogTable) as
    cursor exceptionLogCursor is
      select
        log_id,
        package_name,
        routine_name,
        exception_number,
        exception_string
      from ame_exceptions_log
      where
        transaction_id is null and
        application_id is null
      order by log_id desc;
    tempIndex integer;
    begin
      tempIndex := 1;
      for tempLog in exceptionLogCursor loop
        exceptionLogOut(tempIndex).log_id := tempLog.log_id;
        exceptionLogOut(tempIndex).package_name := tempLog.package_name;
        exceptionLogOut(tempIndex).routine_name := tempLog.routine_name;
        exceptionLogOut(tempIndex).exception_number := tempLog.exception_number;
        exceptionLogOut(tempIndex).exception_string := tempLog.exception_string;
        tempIndex := tempIndex + 1;
       end loop;
       exception
         when others then
           rollback;
           ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                     routineNameIn => 'getWebExceptions',
                                     exceptionNumberIn => sqlcode,
                                     exceptionStringIn => sqlerrm);
           exceptionLogOut := ame_util.emptyExceptionLogTable;
           raise;
    end getWebExceptions;
  procedure getWorkflowLog(applicationIdIn in integer,
                           transactionIdIn in varchar2 default null,
                           logOut out nocopy ame_util.workflowLogTable) as
    type logCursorReturnType is record(
      item_key wf_item_activity_statuses.item_key%type,
      error_name wf_item_activity_statuses.error_name%type,
      error_message wf_item_activity_statuses.error_message%type,
      error_stack wf_item_activity_statuses.error_stack%type);
    type logCursorType is ref cursor return logCursorReturnType;
    badCallException exception;
    currentCallStart integer;
    currentCallDot integer;
    currentCallLeftParen integer;
    currentCallRightParen integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    errorStackLength integer;
    fndAppId integer;
    logCursor logCursorType;
    logCursorValues logCursorReturnType;
    tempIndex integer;
    transactionTypeId ame_calling_apps.transaction_type_id%type;
    workflowItemKey wf_item_activity_statuses.item_key%type;
    workflowItemType wf_item_activity_statuses.item_type%type;
    begin
      ame_util.getFndApplicationId(applicationIdIn => applicationIdIn,
                                   fndApplicationIdOut => fndAppId,
                                   transactionTypeIdOut => transactionTypeId);
      ame_util.getWorkflowAttributeValues(applicationIdIn => applicationIdIn,
                                          transactionIdIn => transactionIdIn,
                                          workflowItemKeyOut => workflowItemKey,
                                          workflowItemTypeOut => workflowItemType);
      if(transactionIdIn is null) then
        open logCursor for
          select
            wf_item_activity_statuses.item_key,
            wf_item_activity_statuses.error_name,
            wf_item_activity_statuses.error_message,
            wf_item_activity_statuses.error_stack
          from
            wf_item_activity_statuses,
            wf_items
          where
            wf_item_activity_statuses.item_type = workflowItemType and
            wf_item_activity_statuses.activity_status = 'ERROR' and
            wf_item_activity_statuses.error_stack like (wf_core.newline || 'AME_%') and
            wf_item_activity_statuses.item_type = wf_items.item_type and
            wf_item_activity_statuses.item_key = wf_items.item_key and
            wf_items.end_date is null;
      else
        open logCursor for
          select
            wf_item_activity_statuses.item_key, /* We need to select this column to use the same cursor. */
            wf_item_activity_statuses.error_name,
            wf_item_activity_statuses.error_message,
            wf_item_activity_statuses.error_stack
          from
            wf_item_activity_statuses,
            wf_items
          where
            wf_item_activity_statuses.item_type = workflowItemType and
            wf_item_activity_statuses.item_key = workflowItemKey and
            wf_item_activity_statuses.activity_status = 'ERROR' and
            wf_item_activity_statuses.error_stack like (wf_core.newline || 'AME_%') and
            wf_item_activity_statuses.item_type = wf_items.item_type and
            wf_item_activity_statuses.item_key = wf_items.item_key and
            wf_items.end_date is null;
      end if;
      tempIndex := 1;
      loop
        fetch logCursor into logCursorValues;
        exit when logCursor%notfound;
        /*
          This code assumes that the error_stack is a sequence of entries of the form
            wf_core.newline || [package].[routine]([logId])
          which in aggregate look like a call stack (but we don't include a real
          argument list between the parentheses, just our log ID).  See ame_util.runtimeException
          for the code that generates these entries.
        */
        errorStackLength := lengthb(logCursorValues.error_stack);
        currentCallRightParen := 1;
        loop
          currentCallStart := instrb(logCursorValues.error_stack,
                                     wf_core.newline,
                                     currentCallRightParen,
                                     1) + 1;
          if(currentCallStart = 0) then
            exit;
          end if;
          currentCallDot := instrb(logCursorValues.error_stack,
                                   '.',
                                   currentCallStart,
                                   1);
          if(currentCallDot = 0) then
            raise badCallException;
          end if;
          currentCallLeftParen := instrb(logCursorValues.error_stack,
                                         '(',
                                         currentCallDot,
                                         1);
          if(currentCallLeftParen = 0) then
            raise badCallException;
          end if;
          currentCallRightParen := instrb(logCursorValues.error_stack,
                                          ')',
                                          currentCallLeftParen,
                                          1);
          if(currentCallRightParen = 0) then
            raise badCallException;
          end if;
          logOut(tempIndex).package_name := substrb(logCursorValues.error_stack,
                                                    currentCallStart,
                                                    currentCallDot - currentCallStart);
          logOut(tempIndex).routine_name := substrb(logCursorValues.error_stack,
                                                    currentCallDot + 1,
                                                    currentCallLeftParen - currentCallDot - 1);
          logOut(tempIndex).log_id := to_number(substrb(logCursorValues.error_stack,
                                                        currentCallLeftParen + 1,
                                                        currentCallRightParen - currentCallLeftParen - 1));
          /*
            For exceptions outside of the Workflow engine, Workflow puts sqlcode in error_name
            and sqlerrm in error_message.  See the source code for wf_item_activity_status.Set_Error.
          */
          logOut(tempIndex).transaction_id := substrb(logCursorValues.item_key, 1, 50);
          logOut(tempIndex).exception_number := to_number(logCursorValues.error_name);
          logOut(tempIndex).exception_string := substrb(logCursorValues.error_message, 1, 4000);
          tempIndex := tempIndex + 1;
        end loop;
      end loop;
      close logCursor;
      exception
        when badCallException then
          rollback;
          errorCode := -20001;
          errorMessage :=
           ame_util.getMessage(applicationShortNameIn => 'PER',
           messageNameIn => 'AME_400181_ADM_WKFLW_NOT_PRS');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'getWorkflowLog',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          logOut := ame_util.emptyWorkflowLogTable;
          raise_application_error(errorCode,
                                 errorMessage);
       when others then
         rollback;
         ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                   routineNameIn => 'getWorkflowLog',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         logOut := ame_util.emptyWorkflowLogTable;
         raise;
    end getWorkflowLog;
  procedure incrementItemClassOrderNumbers(applicationIdIn in integer,
                                           itemClassIdIn in integer,
                                           orderNumberIn in integer,
                                                                                                                                                 finalizeIn in boolean default false) as
    cursor orderNumberCursor(applicationIdIn in integer,
                                         itemClassIdIn in integer,
                                                                                                                 orderNumberIn in integer) is
      select item_class_id, item_class_order_number
        from ame_item_class_usages
        where
          application_id = applicationIdIn and
          item_class_id <> itemClassIdIn and
          item_class_order_number >= orderNumberIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
          order by item_class_order_number;
                currentUserId integer;
    itemClassIds ame_util.idList;
    itemClassIdQuery ame_item_class_usages.item_id_query%type;
    itemClassParMode ame_item_class_usages.item_class_par_mode%type;
    itemClassSublistMode ame_item_class_usages.item_class_sublist_mode%type;
    orderNumbers ame_util.idList;
    processingDate date;
    begin
      currentUserId := ame_util.getCurrentUserId;
                        processingDate := sysdate;
      open orderNumberCursor(applicationIdIn => applicationIdIn,
                             itemClassIdIn => itemClassIdIn,
                             orderNumberIn => orderNumberIn);
        fetch orderNumberCursor bulk collect
        into itemClassIds, orderNumbers;
      close orderNumberCursor;
      for i in 1 .. itemClassIds.count loop
        itemClassIdQuery := getItemClassIdQuery(itemClassIdIn => itemClassIds(i),
                                                applicationIdIn => applicationIdIn);
        itemClassParMode := getItemClassParMode(itemClassIdIn => itemClassIds(i),
                                                applicationIdIn => applicationIdIn);
        itemClassSublistMode := getItemClassSublistMode(itemClassIdIn => itemClassIds(i),
                                                        applicationIdIn => applicationIdIn);
                                update ame_item_class_usages
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            item_class_id = itemClassIds(i) and
            sysdate between start_date and
              nvl(end_date - ame_util.oneSecond, sysdate);
        insert into ame_item_class_usages(application_id,
                                          item_class_id,
                                          item_id_query,
                                          item_class_order_number,
                                          item_class_par_mode,
                                          item_class_sublist_mode,
                                          created_by,
                                          creation_date,
                                          last_updated_by,
                                          last_update_date,
                                          last_update_login,
                                          start_date,
                                          end_date)
          values(applicationIdIn,
                 itemClassIds(i),
                 itemClassIdQuery,
                 (orderNumbers(i) + 1),
                 itemClassParMode,
                 itemClassSublistMode,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 null);
      end loop;
                        if(finalizeIn) then
        commit;
      end if;
      exception
       when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'incrementItemClassOrderNumbers',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end incrementItemClassOrderNumbers;
  procedure newItemClassUsage(applicationIdIn in integer,
                              itemClassIdIn in integer,
                              itemClassParModeIn in varchar2,
                              itemClassSublistModeIn in varchar2,
                              itemClassIdQueryIn in varchar2,
                              orderNumberIn in integer default null,
                              orderNumberUniqueIn in varchar2 default ame_util.yes,
                              updateParentObjectIn in boolean,
                              newStartDateIn in date,
                              finalizeIn in boolean default false,
                              parentVersionStartDateIn in date default null) as
    cursor startDateCursor is
      select start_date
        from ame_item_classes
        where
          item_class_id = itemClassIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date))
        for update;
    createdBy integer;
    currentUserId integer;
    dynamicUsageException exception;
    endDate date;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    itemId integer;
    itemIdQuery ame_item_class_usages.item_id_query%type;
    lastUpdatedBy integer;
    maxOrderNumber integer;
    name ame_item_classes.name%type;
    nullQueryStringException exception;
    objectVersionNoDataException exception;
    orderNumber integer;
    startDate date;
    stringDynamicException exception;
    tempCount integer;
    tempCount2 integer;
    tempInt integer;
    transIdPlaceholderPosition integer;
    transIdPlaceholderPosition2 integer;
    upperItemIdQuery ame_item_class_usages.item_id_query%type;
    upperTransIdPlaceholder ame_util.stringType;
    usageExistsException exception;
    begin
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
      if(orderNumberIn is null) then
        orderNumber := 1;
      else
        orderNumber := orderNumberIn;
      end if;
      maxOrderNumber :=
                          ame_admin_pkg.getItemClassMaxOrderNumber(applicationIdIn => applicationIdIn);
      itemIdQuery := itemClassIdQueryIn;
      if(itemIdQuery is null) then
        raise nullQueryStringException;
      end if;
      if(instrb(itemIdQuery, ';', 1, 1) > 0) or
        (instrb(itemIdQuery, '--', 1, 1) > 0) or
        (instrb(itemIdQuery, '/*', 1, 1) > 0) or
        (instrb(itemIdQuery, '*/', 1, 1) > 0) then
        raise stringDynamicException;
      end if;
      tempInt := 1;
      upperItemIdQuery := upper(itemClassIdQueryIn);
      upperTransIdPlaceholder := upper(ame_util.transactionIdPlaceholder);
      loop
        transIdPlaceholderPosition :=
          instrb(upperItemIdQuery, upperTransIdPlaceholder, 1, tempInt);
        if(transIdPlaceholderPosition = 0) then
          exit;
        end if;
        transIdPlaceholderPosition2 :=
          instrb(itemClassIdQueryIn, ame_util.transactionIdPlaceholder, 1, tempInt);
        if(transIdPlaceholderPosition <> transIdPlaceholderPosition2) then
          raise dynamicUsageException;
        end if;
        tempInt := tempInt + 1;
      end loop;
      select count(*)
        into tempCount
        from ame_item_class_usages
        where
          item_class_id = itemClassIdIn and
          application_id = applicationIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      if(tempCount > 0) then
        raise usageExistsException;
      end if;
      currentUserId := ame_util.getCurrentUserId;
      select count(*)
        into tempCount2
        from ame_item_class_usages
          where
            item_class_id = itemClassIdIn and
            application_id = applicationIdIn and
            created_by = ame_util.seededDataCreatedById;
      if(tempCount2 > 0) then
        createdBy := ame_util.seededDataCreatedById;
      else
        createdBy := currentUserId;
      end if;
      lastUpdatedBy := currentUserId;
      --+ following code has beed added for the bug 5623266
      if(createdBy = -1 )then
        lastUpdatedBy := ame_util.seededDataCreatedById;
        createdBy     := ame_util.seededDataCreatedById;
      end if;
      insert into ame_item_class_usages(application_id,
                                        item_class_id,
                                        item_id_query,
                                        item_class_order_number,
                                        item_class_par_mode,
                                        item_class_sublist_mode,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        last_update_login,
                                        start_date,
                                        end_date)
        values(applicationIdIn,
               itemClassIdIn,
               itemClassIdQueryIn,
               orderNumber,
               itemClassParModeIn,
               itemClassSublistModeIn,
               createdBy,
               newStartDateIn,
               lastUpdatedBy,
               newStartDateIn,
               currentUserId,
               newStartDateIn,
               null);
      if(orderNumberUniqueIn = ame_util.yes) then
        if(orderNumber <> (maxOrderNumber + 1)) then
          incrementItemClassOrderNumbers(applicationIdIn => applicationIdIn,
                                         itemClassIdIn => itemClassIdIn,
                                         orderNumberIn => orderNumber);
        end if;
                        end if;
                        if(finalizeIn) then
        if(updateParentObjectIn) then
          name := getItemClassName(itemClassIdIn => itemClassIdIn);
          endDate := newStartDateIn;
          update ame_item_classes
            set
              last_updated_by = currentUserId,
              last_update_date = endDate,
              last_update_login = currentUserId,
              end_date = endDate
            where
              item_class_id = itemClassIdIn and
               sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate);
          itemId := newItemClass(itemClassNameIn => name,
                                 itemClassIdIn => itemClassIdIn,
                                 newStartDateIn => newStartDateIn,
                                 finalizeIn => false);
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClassUsage',
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClassUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when stringDynamicException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400376_ADM IC_QUERY');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClassUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when dynamicUsageException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400377_ADM IC_QUERY2');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClassUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when nullQueryStringException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400410_ADM_NO_EMPTY_USAGE');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClassUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when usageExistsException then
          rollback;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
                                messageNameIn => 'AME_400379_ADM IC_USAGE_EXISTS');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClassUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newItemClassUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end newItemClassUsage;
/*
AME_STRIPING
  procedure newStripeSet2(applicationIdIn in integer,
                          newStripedAttributesSetIn in ame_util.stringList,
                          commitIn in boolean default false) as
    attributeCount integer;
    currentUserId integer;
    errorCode varchar2(10);
    errorMessage varchar2(5000);
    existingSSException exception;
    begin
      currentUserId := ame_util.getCurrentUserId;
      select count(*)
        into attributeCount
        from ame_stripe_sets
        where
          application_id = applicationIdIn and
          ((value_1 is null and newStripedAttributesSetIn(1) is null) or value_1 = newStripedAttributesSetIn(1)) and
          ((value_2 is null and newStripedAttributesSetIn(2) is null) or value_2 = newStripedAttributesSetIn(2)) and
          ((value_3 is null and newStripedAttributesSetIn(3) is null) or value_3 = newStripedAttributesSetIn(3)) and
          ((value_4 is null and newStripedAttributesSetIn(4) is null) or value_4 = newStripedAttributesSetIn(4)) and
          ((value_5 is null and newStripedAttributesSetIn(5) is null) or value_5 = newStripedAttributesSetIn(5)) and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      if(attributeCount > 0) then
        raise existingSSException;
      end if;
      insert into ame_stripe_sets(application_id,
                                  stripe_set_id,
                                  value_1,
                                  value_2,
                                  value_3,
                                  value_4,
                                  value_5,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login,
                                  start_date,
                                  end_date,
                                  security_group_id)
        values(applicationIdIn,
               0,
               newStripedAttributesSetIn(1),
               newStripedAttributesSetIn(2),
               newStripedAttributesSetIn(3),
               newStripedAttributesSetIn(4),
               newStripedAttributesSetIn(5),
               currentUserId,
               sysdate,
               currentUserId,
               sysdate,
               currentUserId,
               sysdate,
               null,
               null);
      if(commitIn) then
        commit;
      end if;
      exception
        when existingSSException then
          rollback;
          errorCode := -20001;
          errorMessage := 'This stripe set already exists for the ' ||
                          'transaction type.  ';
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newStripeSet2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'newStripeSet2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end newStripeSet2;
*/
  procedure registerTransactionType(fndApplicationIdIn in integer,
                                    transTypeDescIn in varchar2,
                                    transactionTypeIdIn in varchar2 default null,
                                    attributeIdsIn in ame_util.stringList,
                                    queryStringsIn in ame_util.longestStringList,
                                    staticUsagesIn in ame_util.stringList,
                                    versionStartDatesIn in ame_util.stringList) as
    cursor attributeCursor(attributeIdIn in integer) is
      select
        to_char(ame_attributes.start_date) start_date
        from
          ame_attributes,
          ame_mandatory_attributes
        where
          ame_attributes.attribute_id = ame_mandatory_attributes.attribute_id and
          ame_attributes.attribute_id = attributeIdIn and
          ame_mandatory_attributes.action_type_id = -1 and
          sysdate between ame_attributes.start_date and
           nvl(ame_attributes.end_date - ame_util.oneSecond, sysdate) and
          sysdate between ame_mandatory_attributes.start_date and
           nvl(ame_mandatory_attributes.end_date - ame_util.oneSecond, sysdate)
        for update;
    actionTypeIds ame_util.idList;
    applicationId integer;
    attributeCount integer;
    attributeIds ame_util.stringList;
    attributeName ame_attributes.name%type;
    currentUserId integer;
    errorCode varchar2(10);
    errorMessage ame_util.longestStringType;
    evalAttributeId ame_attributes.attribute_id%type;
    evalPrioritiesPerItemAttId integer;
    evalPriorityStartDate ame_util.stringType;
    evalQueryString ame_attribute_usages.query_string%type;
    evalStaticUsage ame_attribute_usages.is_static%type;
    finalize boolean;
    found number;
    groupList ame_util.idList;
    orderNumber integer;
    queryStrings ame_util.longestStringList;
    ruleType integer;
    ruleTypes ame_util.idList;
    startDate ame_util.stringType;
    staticUsage ame_attribute_usages.is_static%type;
    staticUsages ame_util.stringList;
    tempIndex integer;
    tempIndex2 integer;
    useRestrItemEvalAttId integer;
    useRestrStartDate ame_util.stringType;
    versionStartDates ame_util.stringList;
    processingDate date;
    begin
      processingDate := sysdate;
      currentUserId := ame_util.getCurrentUserId;
      select ame_applications_s.nextval
       into applicationId
       from dual;
      insert into ame_calling_apps(fnd_application_id,
                                   application_name,
                                   application_id,
                                   transaction_type_id,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login,
                                   start_date,
                                   line_item_id_query)
        values(fndApplicationIdIn,
               transTypeDescIn,
               applicationId,
               transactionTypeIdIn,
               currentUserId,
               processingDate,
               currentUserId,
               processingDate,
               currentUserId,
               processingDate,
               null);
      tempIndex := 1;
      queryStrings := queryStringsIn;
      staticUsages := staticUsagesIn;
      attributeIds := attributeIdsIn;
      versionStartDates := versionStartDatesIn;
      tempIndex2 := (attributeIds.count + 1);
      evalPrioritiesPerItemAttId :=
        ame_attribute_pkg.getIdByName(attributeNameIn => ame_util.evalPrioritiesPerItemAttribute);
      evalPriorityStartDate :=
        ame_attribute_pkg.getStartDate(attributeIdIn => evalPrioritiesPerItemAttId);
      attributeIds(tempIndex2) := evalPrioritiesPerItemAttId;
      queryStrings(tempIndex2) := ame_util.booleanAttributeFalse;
      staticUsages(tempIndex2) := ame_util.booleanTrue;
      versionStartDates(tempIndex2) := evalPriorityStartDate;
      useRestrItemEvalAttId :=
        ame_attribute_pkg.getIdByName(attributeNameIn => ame_util.restrictiveItemEvalAttribute);
      useRestrStartDate :=
        ame_attribute_pkg.getStartDate(attributeIdIn => useRestrItemEvalAttId);
      tempIndex2 := (tempIndex2 + 1);
      attributeIds(tempIndex2) := useRestrItemEvalAttId;
      queryStrings(tempIndex2) := ame_util.booleanAttributeFalse;
      staticUsages(tempIndex2) := ame_util.booleanTrue;
      versionStartDates(tempIndex2) := useRestrStartDate;
      /* attempt to get a lock on the mandatory attributes */
      for i in 1..attributeIds.count loop
        open attributeCursor(attributeIdIn => attributeIds(i));
        loop
          fetch attributeCursor into startDate;
            exit when attributeCursor%notfound;
            /* verifies that the mandatory attribute has not been updated */
            /* the versionStartDate is in sync with the start date due to how the data
               was retrieved for each */
            if(versionStartDates(tempIndex) = startDate) then
              attributeName := ame_attribute_pkg.getName(attributeIdIn => attributeIds(i));
              if(attributeName = ame_util.evalPrioritiesPerItemAttribute) then
                evalAttributeId := attributeIds(i);
                evalQueryString := queryStrings(tempIndex);
                evalStaticUsage := staticUsages(tempIndex);
              else
                ame_attribute_pkg.newAttributeUsage(attributeIdIn => attributeIds(i),
                                                    applicationIdIn => applicationId,
                                                    queryStringIn => queryStrings(tempIndex),
                                                    staticUsageIn => staticUsages(tempIndex),
                                                    updateParentObjectIn => true,
                                                    finalizeIn => false);
                if(attributeName = ame_util.restrictiveItemEvalAttribute) then
                  ame_attribute_pkg.newAttributeUsage(attributeIdIn => evalAttributeId,
                                                      applicationIdIn => applicationId,
                                                      queryStringIn => evalQueryString,
                                                      staticUsageIn => evalStaticUsage,
                                                      updateParentObjectIn => true,
                                                      finalizeIn => false);
                end if;
              end if;
            else
              close attributeCursor;
              raise ame_util.objectVersionException;
            end if;
            tempIndex := tempIndex + 1;
        end loop;
        close attributeCursor;
      end loop;
      ame_action_pkg.getActionTypeUsages2(actionTypeIdsOut => actionTypeIds,
                                          ruleTypesOut => ruleTypes);
      for i in 1..actionTypeIds.count loop
        if(i = 1) then
          ruleType := ruleTypes(i);
          orderNumber := 1;
        else
          if(ruleType = ruleTypes(i)) then
            orderNumber := orderNumber + 1;
          else
            ruleType := ruleTypes(i);
            orderNumber := 1;
          end if;
        end if;
        insert into ame_action_type_config(application_id,
                                           action_type_id,
                                           voting_regime,
                                           order_number,
                                           chain_ordering_mode,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login,
                                           start_date,
                                           end_date)
          values(applicationId,
                 actionTypeIds(i),
                 ame_util.serializedVoting,
                 orderNumber,
                 ame_util.sequentialChainsMode,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 null);
      end loop;
      ame_approval_group_pkg.getApprovalGroupList(groupListOut => groupList);
      for i in 1..groupList.count loop
        insert into ame_approval_group_config(application_id,
                                              approval_group_id,
                                              voting_regime,
                                              order_number,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login,
                                              start_date,
                                              end_date)
          values(applicationId,
                 groupList(i),
                 ame_util.serializedVoting,
                 i,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 currentUserId,
                 processingDate,
                 null);
      end loop;
      commit;
      exception
        when ame_util.objectVersionException then
          rollback;
          if(attributeCursor%isOpen) then
            close attributeCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400143_ACT_OBJECT_CHNGED');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'registerTransactionType',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
         rollback;
         ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                   routineNameIn => 'registerTransactionType',
                                   exceptionNumberIn => sqlcode,
                                   exceptionStringIn => sqlerrm);
         raise;
    end registerTransactionType;
/*
AME_STRIPING
  procedure removeAllStripeSets(applicationIdIn in integer,
                                deleteStripeSetIdZeroIn in boolean,
                                commitIn in boolean default false) as
    cursor getAllStripeSetsCursor(applicationIdIn in integer) is
      select stripe_set_id,
             value_1,
             value_2,
             value_3,
             value_4,
             value_5
        from ame_stripe_sets
        where
          application_id = applicationIdIn and
          stripe_set_id <> 0 and
         (start_date <= sysdate and
         (end_date is null or sysdate < end_date))
        order by stripe_set_id;
    currentUserId integer;
    startDate date;
    begin
      currentUserId := ame_util.getCurrentUserId;
      if(deleteStripeSetIdZeroIn) then
        update ame_stripe_sets
          set
            last_updated_by = currentUserId,
            last_update_date = sysdate,
            last_update_login = currentUserId,
            end_date = sysdate
          where
            application_id = applicationIdIn and
            (start_date <= sysdate and
            (end_date is null or sysdate < end_date));
      else
        for getAllStripeSetsRec in getAllStripeSetsCursor(applicationIdIn => applicationIdIn) loop
          update ame_stripe_sets
          set
            last_updated_by = currentUserId,
            last_update_date = sysdate,
            last_update_login = currentUserId,
            end_date = sysdate
          where
            application_id = applicationIdIn and
            stripe_set_id = getAllStripeSetsRec.stripe_set_id and
            (start_date <= sysdate and
            (end_date is null or sysdate < end_date));
        end loop;
      end if;
      if(commitIn) then
        commit;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'removeAllStripeSets',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end removeAllStripeSets;
*/
/*
AME_STRIPING
  procedure removeStripeSetAttributes(applicationIdIn in integer,
                                      attributeIdIn in integer) as
  cursor stripeSetCursor(applicationIdIn in integer) is
    select
      stripe_set_id,
      value_1,
      value_2,
      value_3,
      value_4,
      value_5
      from ame_stripe_sets
      where
        stripe_set_id <> 0 and
        application_id = applicationIdIn and
        (start_date <= sysdate and
        (end_date is null or sysdate < end_date))
      order by
        value_1,
        value_2,
        value_3,
        value_4,
        value_5; */
                                /* This lexicographic ordering of the value_i columns is critical. */
/*
  cursor stripeSetRuleCursor(stripeSetIdIn in integer) is
    select rule_id
      from ame_rule_stripe_sets
      where
        ame_rule_stripe_sets.stripe_set_id = stripeSetIdIn and
        (start_date <= sysdate and
        (end_date is null or sysdate < end_date));
  columnIndex integer;
  conversionStripeSetIds ame_util.idList;
  conversionStripingAttValues ame_util.stringList;
  conversionConditionIds ame_util.idList;
  currentUserId integer;
  dynamicQuery ame_util.longestStringType;
  errorCode integer;
  errorMessage ame_util.longStringType;
  indexToWrite integer;
  insertRow boolean;
  lastStripeSetId integer;
  lastStripingAttValues ame_util.stringList;
  newConditionId ame_conditions.condition_id%type;
  noAttributeMatchException exception;
  ruleIds ame_util.idList;
  stringValueList ame_util.longestStringList;
  stripeSetIds ame_util.idList;
  stripingAttributeValues1 ame_util.stringList;
  stripingAttributeValues2 ame_util.stringList;
  stripingAttributeValues3 ame_util.stringList;
  stripingAttributeValues4 ame_util.stringList;
  stripingAttributeValues5 ame_util.stringList;
  stripingAttributeIds ame_util.idList;
  upperLimit integer;
  begin
    currentUserId := ame_util.getCurrentUserId;
*/
    /* Fetch the current striping attribute IDs. */
/*
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
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
*/
      /* Set columnIndex to the index of the column containing the striping attribute to be dropped. */
/*
      columnIndex := null;
      for i in 1 .. 5 loop
        if(stripingAttributeIds(i) = attributeIdIn) then
          columnIndex := i;
          exit;
        end if;
      end loop;
      if(columnIndex is null) then
        raise noAttributeMatchException;
      end if;
*/
      /*
        Fetch all current stripe sets in the current transaction type, in
        lexicographic order of striping-attribute value.
      */
/*
      open stripeSetCursor(applicationIdIn => applicationIdIn);
      fetch stripeSetCursor bulk collect
        into
          stripeSetIds,
          stripingAttributeValues1,
          stripingAttributeValues2,
          stripingAttributeValues3,
          stripingAttributeValues4,
          stripingAttributeValues5;
      close stripeSetCursor;
      upperLimit := stripeSetIds.count; */
                        /* Don't update upperLimit below. */
      /* End date all current stripe sets, and the zero-ID row containing the striping-attribute IDs. */
/*
      update ame_stripe_sets
        set end_date = sysdate
        where
          application_id = applicationIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
*/
      /* Insert a new zero-ID row, compacted. */
/*
      if(columnIndex < 5) then
        for i in columnIndex .. 4 loop
          stripingAttributeIds(i) := stripingAttributeIds(i + 1);
        end loop;
      end if;
      stripingAttributeIds(5) := null;
      insert into ame_stripe_sets(
        application_id,
        stripe_set_id,
        value_1,
        value_2,
        value_3,
        value_4,
        value_5,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        start_date,
        end_date) values(
          applicationIdIn,
          0,
          to_number(stripingAttributeIds(1)),
          to_number(stripingAttributeIds(2)),
          to_number(stripingAttributeIds(3)),
          to_number(stripingAttributeIds(4)),
          to_number(stripingAttributeIds(5)),
          currentUserId,
          sysdate,
          currentUserId,
          sysdate,
          currentUserId,
          sysdate,
          null);
*/
      /* Initialize lastStripingAttValues so the first stripe set will always get inserted. */
/*      lastStripeSetId := null; */
/* Just to be safe. */
/*
      for i in 1 .. 5 loop
        lastStripingAttValues(i) := null;
      end loop;
*/
      /* Eliminate duplicate stripe sets. */
/*      for i in 1 .. upperLimit loop */
        /*
          First check whether the ith stripe set in the stripingAttributeValues[i] tables is new.
          Because of the lexicographic ordering, if the ith row does not match the previous row
          inserted, the ith row must be inserted.
        */
/*
        insertRow := false;
        if(columnIndex <> 1 and
           ((stripingAttributeValues1(i) is null and lastStripingAttValues(1) is not null) or
            ((stripingAttributeValues1(i) is not null and lastStripingAttValues(1) is null)) or
            (stripingAttributeValues1(i) <> lastStripingAttValues(1)))) then
          insertRow := true;
        end if;
        if((not insertRow) and
           columnIndex <> 2 and
           ((stripingAttributeValues2(i) is null and lastStripingAttValues(2) is not null) or
            ((stripingAttributeValues2(i) is not null and lastStripingAttValues(2) is null)) or
            (stripingAttributeValues2(i) <> lastStripingAttValues(2)))) then
          insertRow := true;
        end if;
        if((not insertRow) and
           columnIndex <> 3 and
           ((stripingAttributeValues3(i) is null and lastStripingAttValues(3) is not null) or
            ((stripingAttributeValues3(i) is not null and lastStripingAttValues(3) is null)) or
            (stripingAttributeValues3(i) <> lastStripingAttValues(3)))) then
          insertRow := true;
        end if;
        if((not insertRow) and
           columnIndex <> 4 and
           ((stripingAttributeValues4(i) is null and lastStripingAttValues(4) is not null) or
            ((stripingAttributeValues4(i) is not null and lastStripingAttValues(4) is null)) or
            (stripingAttributeValues4(i) <> lastStripingAttValues(4)))) then
          insertRow := true;
        end if;
        if((not insertRow) and
           columnIndex <> 5 and
           ((stripingAttributeValues5(i) is null and lastStripingAttValues(5) is not null) or
            ((stripingAttributeValues5(i) is not null and lastStripingAttValues(5) is null)) or
            (stripingAttributeValues5(i) <> lastStripingAttValues(5)))) then
          insertRow := true;
        end if;
*/
        /* Now insert the ith row if it's new.  Remember to update the last-row-inserted data. */
/*        if(insertRow) then */
          /* Update lastStripeSetId and lastStripingAttValues. */
/*
          lastStripeSetId := stripeSetIds(i);
          lastStripingAttValues(1) := stripingAttributeValues1(i);
          lastStripingAttValues(2) := stripingAttributeValues2(i);
          lastStripingAttValues(3) := stripingAttributeValues3(i);
          lastStripingAttValues(4) := stripingAttributeValues4(i);
          lastStripingAttValues(5) := stripingAttributeValues5(i);
*/
          /* Compact the row. */
/*
          if(columnIndex < 2) then
            stripingAttributeValues1(i) := stripingAttributeValues2(i);
          end if;
          if(columnIndex < 3) then
            stripingAttributeValues2(i) := stripingAttributeValues3(i);
          end if;
          if(columnIndex < 4) then
            stripingAttributeValues3(i) := stripingAttributeValues4(i);
          end if;
          stripingAttributeValues5(i) := null;
        else
*/
          /* Move the rules in this stripe set into the most recently inserted stripe set. */
/*
          open stripeSetRuleCursor(stripeSetIdIn => stripeSetIds(i));
          fetch stripeSetRuleCursor bulk collect into ruleIds;
          close stripeSetRuleCursor;
          update ame_rule_stripe_sets
            set end_date = sysdate
            where
              stripe_set_id = stripeSetIds(i) and
              (start_date <= sysdate and
              (end_date is null or sysdate < end_date));
          forall i in 1 .. ruleIds.count
            insert into ame_rule_stripe_sets(
              rule_id,
              stripe_set_id,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              start_date,
              end_date) values(
                ruleIds(i),
                lastStripeSetId,
                currentUserId,
                sysdate,
                currentUserId,
                sysdate,
                currentUserId,
                sysdate,
                null);
*/
          /* Delete this stripe set. */
/*
          stripeSetIds.delete(i);
        end if;
      end loop;
*/
      /* Compact the stripe-set lists. */
/*      indexToWrite := stripeSetIds.first; */
/* post-increment */
/*
      for i in 1 .. upperLimit loop
        if(indexToWrite is null) then
          stripeSetIds.delete(i, upperLimit);
          stripingAttributeValues1.delete(i, upperLimit);
          stripingAttributeValues2.delete(i, upperLimit);
          stripingAttributeValues3.delete(i, upperLimit);
          stripingAttributeValues4.delete(i, upperLimit);
          stripingAttributeValues5.delete(i, upperLimit);
          exit;
        else
          stripeSetIds(i) := stripeSetIds(indexToWrite);
          stripingAttributeValues1(i) := stripingAttributeValues1(indexToWrite);
          stripingAttributeValues2(i) := stripingAttributeValues2(indexToWrite);
          stripingAttributeValues3(i) := stripingAttributeValues3(indexToWrite);
          stripingAttributeValues4(i) := stripingAttributeValues4(indexToWrite);
          stripingAttributeValues5(i) := stripingAttributeValues5(indexToWrite);
        end if;
        indexToWrite := stripeSetIds.next(indexToWrite);
      end loop;
*/
      /* Bulk insert the stripe sets. */
/*
      forall i in 1 .. stripeSetIds.count
        insert into ame_stripe_sets(
          application_id,
          stripe_set_id,
          value_1,
          value_2,
          value_3,
          value_4,
          value_5,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          start_date,
          end_date) values(
            applicationIdIn,
            stripeSetIds(i),
            stripingAttributeValues1(i),
            stripingAttributeValues2(i),
            stripingAttributeValues3(i),
            stripingAttributeValues4(i),
            stripingAttributeValues5(i),
            currentUserId,
            sysdate,
            currentUserId,
            sysdate,
            currentUserId,
            sysdate,
            null);
      commit;
      exception
        when noAttributeMatchException then
          rollback;
          errorCode := -20001;
          errorMessage := 'The attribute you selected to remove was not ' ||
                          'found within the current stripe set.  Please ' ||
                          'contact your systems administrator.';
          ame_util.runtimeException(packageNamein => 'ame_admin_pkg',
                                    routineNamein => 'removeStripeSetAttributes',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
        raise_application_error(errorCode,
                                errorMessage);
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'removeStripeSetAttributes',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
         raise;
    end removeStripeSetAttributes;
*/
  procedure removeUsage(itemClassIdIn in integer,
                        parentVersionStartDateIn in date,
                        childVersionStartDateIn in date,
                        applicationIdIn in integer,
                        finalizeIn in boolean default false) as
    cursor startDateCursor is
      select start_date
        from ame_item_classes
        where
          item_class_id = itemClassIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    cursor startDateCursor2 is
      select start_date
        from ame_item_class_usages
        where
          item_class_id = itemClassIdIn and
          application_id = applicationIdIn and
          sysdate between start_date and
            nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    icUsageDeletionException exception;
    inUseException exception;
    itemClassId integer;
    itemClassName ame_item_classes.name%type;
    objectVersionNoDataException exception;
    orderNumber integer;
    startDate date;
    startDate2 date;
    processingDate date;
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
          currentUserId := ame_util.getCurrentUserId;
          if((ame_admin_pkg.icInUseByAttributeUsage(itemClassIdIn => itemClassIdIn,
                                                    applicationIdIn => applicationIdIn)) or
            (ame_admin_pkg.icInUseByRuleUsage(itemClassIdIn => itemClassIdIn,
                                              applicationIdIn => applicationIdIn))) then
            raise icUsageDeletionException;
          end if;
          select item_class_order_number
            into orderNumber
            from ame_item_class_usages
            where
              application_id = applicationIdIn and
              item_class_id = itemClassIdIn and
              sysdate between start_date and
                nvl(end_date - ame_util.oneSecond, sysdate);
          if(orderNumberUnique(applicationIdIn => applicationIdIn,
                               orderNumberIn => orderNumber)) then
            /* subtract 1 from the order number for those above the one being deleted */
            decrementItemClassOrderNumbers(applicationIdIn => applicationIdIn,
                                           orderNumberIn => orderNumber,
                                           finalizeIn => false);
          end if;
                                        update ame_item_class_usages
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              item_class_id = itemClassIdIn and
              application_id = applicationIdIn and
              processingDate between start_date and
                nvl(end_date - ame_util.oneSecond, processingDate);
          itemClassName := ame_admin_pkg.getItemClassName(itemClassIdIn => itemClassIdIn);
          update ame_item_classes
            set
              last_updated_by = currentUserId,
              last_update_date = processingDate,
              last_update_login = currentUserId,
              end_date = processingDate
            where
              item_class_id = itemClassIdIn and
              processingDate between start_date and
                nvl(end_date - ame_util.oneSecond, processingDate);
           itemClassId := newItemClass(itemClassIdIn => itemClassIdIn,
                                       itemClassNameIn => itemClassName,
                                       newStartDateIn => processingDate,
                                       finalizeIn => false);
        close startDateCursor;
      close startDateCursor2;
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
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
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'removeUsage',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when icUsageDeletionException then
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
            messageNameIn => 'AME_400381_ADM IC_USAGE_DEL');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
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
          if(startDateCursor2%isOpen) then
            close startDateCursor2;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'removeUsage',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => '(item class ID ' ||
                                                        itemClassIdIn||
                                                        ') ' ||
                                                        sqlerrm);
          raise;
    end removeUsage;
  procedure removeTransactionType(applicationIdIn in integer,
                                  versionStartDateIn in date) as
    cursor startDateCursor is
      select start_date
        from ame_calling_apps
        where
          application_id = applicationIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate)
        for update;
    cursor ruleUsageCursor(applicationIdIn in integer) is
      select rule.rule_id  rule_id,
             start_date
        from ame_rule_usages rule
        where
          item_id = applicationIdIn and
          sysdate between start_date and
                 nvl(end_date - ame_util.oneSecond, sysdate) ;
    attributeIdsList ame_util.idList;
    currentUserId integer;
    errorCode integer;
    errorMessage ame_util.longestStringType;
    itemClassId ame_attributes.item_class_id%type;
    startDate date;
    tempIndex integer;
    versionStartDate date;
    childVersionStartDate date;
    parentVersionStartDate date;
    processingDate date;
    begin
      processingDate := sysdate;
      currentUserId := ame_util.getCurrentUserId;
      open startDateCursor;
      fetch startDateCursor into startDate;
      if(versionStartDateIn = startDate) then
        for tempRows in ruleUsageCursor(applicationIdIn => applicationIdIn) loop
          versionStartDate := ame_rule_pkg.getStartDate(ruleIdIn => tempRows.rule_id);
          ame_rule_pkg.removeUsage(ruleIdIn => tempRows.rule_id,
                                   itemIdIn => applicationIdIn,
                                   usageStartDateIn => tempRows.start_date,
                                   parentVersionStartDateIn => versionStartDate,
                                   finalizeIn => false);
        end loop;
        ame_attribute_pkg.getApplicationAttributes(applicationIdIn => applicationIdIn,
                                                   attributeIdOut => attributeIdsList);
        tempIndex := attributeIdsList.count;
        for i in 1 .. tempIndex loop
          parentVersionStartDate := ame_util.versionStringToDate(stringDateIn =>
             ame_attribute_pkg.getParentVersionStartDate(attributeIdIn => attributeIdsList(i)));
          childVersionStartDate := ame_util.versionStringToDate(stringDateIn =>
             ame_attribute_pkg.getChildVersionStartDate(attributeIdIn => attributeIdsList(i),
                                                        applicationIdIn => applicationIdIn));
          itemClassId := ame_attribute_pkg.getItemClassId(attributeIdIn => attributeIdsList(i));
          ame_attribute_pkg.removeUsage(attributeIdIn => attributeIdsList(i),
                                        applicationIdIn => applicationIdIn,
                                        parentVersionStartDateIn => parentVersionStartDate,
                                        childVersionStartDateIn => childVersionStartDate,
                                        allowAttributeUsageDeleteIn => true,
                                        finalizeIn => false,
                                        itemClassIdIn => itemClassId);
        end loop;
        update ame_calling_apps
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate);
        update ame_config_vars
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            processingDate between start_date and
                 nvl(end_date - ame_util.oneSecond, processingDate);
        update ame_action_type_config
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            processingDate between start_date and
              nvl(end_date - ame_util.oneSecond, processingDate);
        update ame_approval_group_config
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            processingDate between start_date and
              nvl(end_date - ame_util.oneSecond, processingDate);
        update ame_item_class_usages
          set
            last_updated_by = currentUserId,
            last_update_date = processingDate,
            last_update_login = currentUserId,
            end_date = processingDate
          where
            application_id = applicationIdIn and
            processingDate between start_date and
              nvl(end_date - ame_util.oneSecond, processingDate);
                                commit;
      else
        close startDateCursor;
        raise ame_util.objectVersionException;
      end if;
      close startDateCursor;
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
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'removeTransactionType',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when no_data_found then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          errorCode := -20001;
          errorMessage :=
            ame_util.getMessage(applicationShortNameIn => 'PER',
            messageNameIn => 'AME_400145_ACT_OBJECT_DELETED');
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'removeTransactionType',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          rollback;
          if(startDateCursor%isOpen) then
            close startDateCursor;
          end if;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'removeTransactionType',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
           raise;
    end removeTransactionType;
/*
AME_STRIPING
  procedure updateStripingAttIds(applicationIdIn in integer,
                                 stripedAttributesIn in ame_util.stringList) as
    currentUserId integer;
    existingStripingAttCount integer;
    newStripingAttributeIds ame_util.idList;
    stripeCount integer;
    stripedAttributeCount integer;
    stripingAttributeIds ame_util.idList;
    stripeSetId integer;
    begin
      existingStripingAttCount := 0;
      select count(*)
        into stripeCount
        from ame_stripe_sets
        where
          application_id = applicationIdIn and
          (start_date <= sysdate and
          (end_date is null or sysdate < end_date));
      if(stripeCount > 0) then
        ame_admin_pkg.getStripingAttributeIds(applicationIdIn => applicationIdIn,
                                              stripingAttributeIdsOut => stripingAttributeIds);
        update ame_stripe_sets
          set end_date = sysdate
          where
            application_id = applicationIdIn and
            (start_date <= sysdate and
             (end_date is null or sysdate < end_date));
        existingStripingAttCount := stripingAttributeIds.count;
      end if;
      for i in 1..5 loop
        newStripingAttributeIds(i) := null;
      end loop;
      for i in 1..existingStripingAttCount loop
        newStripingAttributeIds(i) := stripingAttributeIds(i);
      end loop;
      stripedAttributeCount := stripedAttributesIn.count;
      for i in 1..stripedAttributeCount loop
        newStripingAttributeIds(existingStripingAttCount + i) := to_number(stripedAttributesIn(i));
      end loop;
      currentUserId := ame_util.getCurrentUserId;
      select max(stripe_set_id + 1) into stripeSetId from ame_stripe_sets;
      insert into ame_stripe_sets(application_id,
                                  stripe_set_id,
                                  value_1,
                                  value_2,
                                  value_3,
                                  value_4,
                                  value_5,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login,
                                  start_date,
                                  end_date,
                                  security_group_id)
        values(applicationIdIn,
               0,
               to_char(newStripingAttributeIds(1)),
               to_char(newStripingAttributeIds(2)),
               to_char(newStripingAttributeIds(3)),
               to_char(newStripingAttributeIds(4)),
               to_char(newStripingAttributeIds(5)),
               currentUserId,
               sysdate,
               currentUserId,
               sysdate,
               currentUserId,
               sysdate,
               null,
               null);
      for i in 1..newStripingAttributeIds.count loop
        if(newStripingAttributeIds(i) is not null) then
          ame_attribute_pkg.changeUsage(attributeIdIn => newStripingAttributeIds(i),
                                        applicationIdIn => applicationIdIn,
                                        staticUsageIn =>
                                          ame_attribute_pkg.getStaticUsage(attributeIdIn => newStripingAttributeIds(i),
                                                                           applicationIdIn => applicationIdIn),
                                        queryStringIn =>
                                          ame_attribute_pkg.getQueryString(attributeIdIn => newStripingAttributeIds(i),
                                                                           applicationIdIn => applicationIdIn),
                                        endDateIn => sysdate - ame_util.oneSecond,
                                        newStartDateIn => sysdate,
                                        lineItemAttributeIn =>
                                          ame_attribute_pkg.getLineItem(attributeIdIn => newStripingAttributeIds(i)),
                                        isStripingAttributeIn => ame_util.booleanTrue);
        end if;
      end loop;
      commit;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'updateStripingAttIds',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
           raise;
    end updateStripingAttIds;
*/
/*
AME_STRIPING
  procedure updateStripingAttUseCount(applicationIdIn in integer) as
    attributeCount integer;
    endDate date;
    lineItemAttribute ame_attributes.line_item%type;
    newStartDate date;
    queryString ame_attribute_usages.query_string%type;
    staticUsage ame_attribute_usages.is_static%type;
    stripingAttributeIds ame_util.idList;
    stripingAttributeNames ame_util.stringList;
    begin
      if(ame_admin_pkg.isStripingOn(applicationIdIn => applicationIdIn)) then
        ame_admin_pkg.getAttributeStripeSetNames(applicationIdIn => applicationIdIn,
                                                 stripingAttributeIdsOut => stripingAttributeIds,
                                                 stripingAttributeNamesOut => stripingAttributeNames);
        attributeCount := stripingAttributeIds.count;
        for i in 1..attributeCount loop
          endDate := sysdate - ame_util.oneSecond;
          newStartDate := sysdate;
          queryString := ame_attribute_pkg.getQueryString(applicationIdIn => applicationIdIn,
                                                          attributeIdIn => stripingAttributeIds(i));
          staticUsage := ame_attribute_pkg.getStaticUsage(applicationIdIn => applicationIdIn,
                                                          attributeIdIn => stripingAttributeIds(i));
          lineItemAttribute := ame_attribute_pkg.getLineItem(attributeIdIn => stripingAttributeIds(i));
          ame_attribute_pkg.changeUsage(attributeIdIn => stripingAttributeIds(i),
                                        applicationIdIn => applicationIdIn,
                                        staticUsageIn => staticUsage,
                                        queryStringIn => queryString,
                                        endDateIn => endDate,
                                        newStartDateIn => newStartDate,
                                        lineItemAttributeIn => lineItemAttribute,
                                        isStripingAttributeIn => ame_util.booleanTrue,
                                        commitIn => false);
        end loop;
      end if;
      exception
        when others then
          rollback;
          ame_util.runtimeException(packageNameIn => 'ame_admin_pkg',
                                    routineNameIn => 'updateStripingAttUseCount',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
           raise;
    end updateStripingAttUseCount;
*/
end ame_admin_pkg;

/
