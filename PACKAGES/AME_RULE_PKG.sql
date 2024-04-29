--------------------------------------------------------
--  DDL for Package AME_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_PKG" AUTHID CURRENT_USER as
/* $Header: ameorule.pkh 120.1 2006/09/07 13:03:27 pvelugul noship $ */
  /* types */
	type ruleActionRecord is record(
    rule_key ame_rules.rule_key%type,
    rule_id ame_rules.rule_id%type,
    rule_type ame_rules.rule_type%type,
    rule_description ame_rules.description%type,
    usage_start_date ame_rule_usages.start_date%type,
    usage_end_date ame_rule_usages.end_date%type,
    priority ame_rule_usages.priority%type,
    item_class_id ame_rules.item_class_id%type,
    approver_category ame_rule_usages.approver_category%type);
  type ruleActionRecordTable is table of ruleActionRecord index by binary_integer;
  emptyRuleActionRecordTable ruleActionRecordTable;
  /* functions */
  function allOrdinaryConditionsDeleted(conditionIdListIn in ame_util.idList,
                                        deletedListIn in ame_util.stringList) return boolean;
  function appHasRules(applicationIdIn in integer) return boolean;
  function bothSeededLMActionTypesChosen(actionTypeIdsIn in ame_util.idList) return boolean;
  function bothSeededLMActionTypesChosen2(ruleIdIn in integer,
                                          actionTypeIdsIn in ame_util.idList) return boolean;
  function deletedAllExceptionConditions(conditionIdListIn in ame_util.idList,
                                         deletedListIn in ame_util.stringList) return boolean;
  function descriptionInUse(descriptionIn in varchar2) return boolean;
  function finalAuthorityActionType(actionTypeIdsIn in ame_util.idList) return boolean;
  function finalAuthorityActionType2(ruleIdIn in integer) return boolean;
  function getApproverCategory(ruleIdIn in integer,
                               applicationIdIn in integer,
                               usageStartDateIn in date) return varchar2;
  function getConditionCount(ruleIdIn in integer) return integer;
  function getLMConditionId(ruleIdIn in integer) return integer;
  function getDescription(ruleIdIn in integer,
                    processingDateIn in date default null) return varchar2;
  function getEndDate(ruleIdIn in integer) return date;
  function getEffectiveEndDateUsage(applicationIdIn in integer,
                                    ruleIdIn in integer,
                                    effectiveDateIn in date) return date;
  function getEffectiveStartDateUsage(applicationIdIn in integer,
                                      ruleIdIn in integer,
                                      effectiveDateIn in date) return date;
  function getItemClassId(ruleIdIn in integer,
                          processingDateIn in date default null) return integer;
  function getUsageEndDate(ruleIdIn in integer,
                           applicationIdIn in integer,
                             processingDateIn in date) return varchar2;
  function getId(typeIn in varchar2,
                 conditionIdListIn in ame_util.idList,
                 actionIdListIn in ame_util.idList) return integer;
  function ruleKeyExists (ruleKeyIn in varchar2) return boolean;
	function getNextRuleKey return varchar2;
  function getRuleKey(ruleIdIn in integer,
                      processingDateIn in date default null) return varchar2;
  function getItemId(ruleIdIn in integer) return integer;
  function getOrganizationName(organizationIdIn in integer) return varchar2;
  function getPriority(ruleIdIn in integer,
                       applicationIdIn in integer,
                       usageStartDateIn in date) return varchar2;
  function getRulePriorityMode(applicationIdIn in integer,
                               ruleTypeIn in varchar2) return varchar2;
/*
AME_STRIPING
  function getRuleStripeSetId(ruleIdIn in integer) return integer;
*/
  function getRuleType(ruleIdIn in integer,
                       processingDateIn in date default null) return integer;
  function getRuleTypeLabel(ruleTypeIn in integer) return varchar2;
  function getRuleTypeLabel2(ruleTypeIn in integer) return varchar2;
  function getStartDate(ruleIdIn in integer) return date;
  function getSubItemClassId(ruleIdIn in integer) return integer;
  function getUsageStartDate(ruleIdIn in integer,
                         applicationIdIn in integer,
                         processingDateIn in date) return varchar2;
  function getType(ruleIdIn in integer) return integer;
  function getVersionStartDate(ruleIdIn integer) return varchar2;
  function hasATUsageForRuleType2(ruleTypeIn in integer,
                                  actionIdsIn in ame_util.idList) return boolean;
  function hasATUsageForRuleType(ruleTypeIn in integer,
                                 actionTypeIdsIn in ame_util.idList) return boolean;
  function hasExceptionCondition(conditionIdsIn in ame_util.idList) return boolean;
  function hasListModCondition(conditionIdsIn in ame_util.idList) return boolean;
  function hasNonProductionActions(actionIdsIn in ame_util.idList) return boolean;
  function hasNonProductionActionTypes(actionTypeIdsIn in ame_util.idList) return boolean;
  function hasListModCondition2(ruleIdIn in integer) return boolean;
  function hasSubOrListModAction(ruleIdIn in integer) return boolean;
  function isAtLeastOneICAttrSelected(itemClassIdIn in integer,
                                      attributeIdsIn in ame_util.idList) return boolean;
  function isAtLeastOneICCondSelected(itemClassIdIn in integer,
                                      conditionIdsIn in ame_util.idList) return boolean;
  function isInUse(ruleIdIn in integer) return boolean;
  function isInUseByOtherApps(ruleIdIn in integer,
                              applicationIdIn in integer) return boolean;
  function lastConditionDeleted(conditionIdListIn in ame_util.idList,
                                deletedListIn in ame_util.stringList) return boolean;
  function lineItemJobLevelChosen(actionTypeIdsIn in ame_util.idList) return boolean;
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
               processingDateIn in date default null) return integer;
  function newRuleUsage(itemIdIn in integer,
                        ruleIdIn in integer,
                        startDateIn in date,
                        endDateIn in date default null,
                        categoryIn in varchar2 default null,
                        priorityIn in varchar2 default null,
                        finalizeIn in boolean default false,
                        parentVersionStartDateIn in date,
                        processingDateIn in date default null,
                        updateParentObjectIn in boolean default false) return boolean;
  function nonFinalAuthorityActionType(actionTypeIdsIn in ame_util.idList) return boolean;
  function nonFinalAuthorityActionType2(ruleIdIn in integer) return boolean;
  function ordinaryConditionsExist(ruleIdIn in integer) return boolean;
  function ruleAlreadyExistsForTransType(typeIn in varchar2,
                                         conditionIdListIn in ame_util.idList,
                                         actionIdListIn in ame_util.idList,
                                         applicationIdIn in integer,
                                         itemClassIdIn in integer default null) return boolean;
  function ruleExists(typeIn in varchar2,
                      conditionIdListIn in ame_util.idList,
                      actionIdListIn ame_util.idList,
                      itemClassIdIn in integer default null) return boolean;
  function subordinateICCondExist(ruleIdIn in integer) return boolean;
  function useRulePriorityMode(applicationIdIn in integer,
                               ruleTypeIn in varchar2) return boolean;
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
                   processingDateIn in date default null);
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
                        processingDateIn in date default null);
/*
AME_STRIPING
  procedure changeRuleStripe(ruleIdIn in integer,
                             oldStripeSetIdIn in integer,
                             newStripeSetIdIn in integer);
  procedure dropRuleStripeSet(ruleIdIn in integer,
                              applicationIdIn in integer,
                              finalizeIn in boolean default false);
  procedure getAppRuleList(applicationIdIn in integer,
                           stripeSetIdIn in integer default null,
                           isStripingIn in varchar2,
                           ruleListOut out nocopy ame_rule_pkg.ruleActionRecordTable);
*/
  procedure getActionIds(ruleIdIn in integer,
                         actionIdListOut out nocopy ame_util.idList);
  procedure getActions(ruleIdIn in integer,
                       actionIdsOut out nocopy ame_util.idList,
                       actionDescriptionsOut out nocopy ame_util.longStringList);
  procedure getActions2(ruleIdIn in integer,
                        actionTypeIdIn in integer,
                        actionIdsOut out nocopy ame_util.stringList,
                        actionDescriptionsOut out nocopy ame_util.stringList);
  procedure getAppRuleList(applicationIdIn in integer,
                           ruleListOut out nocopy ame_rule_pkg.ruleActionRecordTable);
  procedure getAppRuleList2(applicationIdIn in integer,
                            applicationIdToShareIn in integer,
                            ruleIdListOut out nocopy ame_util.stringList,
                            ruleDescriptionListOut out nocopy ame_util.stringList);
  procedure getConditionIds(ruleIdIn in integer,
                            conditionIdListOut out nocopy ame_util.idList);
  procedure getConditions(ruleIdIn in integer,
                          conditionListOut out nocopy ame_util.stringList,
                          conditionIdListOut out nocopy ame_util.idList);
  procedure getDetailUrls(ruleIdsIn in ame_util.idList,
                          applicationIdIn in integer,
                          usageEndDatesIn in ame_util.dateList default ame_util.emptyDateList,
                          usageStartDatesIn in ame_util.dateList,
                          detailUrlsOut out nocopy ame_util.longStringList);
  procedure getOrdinaryAttributeIds(ruleIdIn in integer,
                                    attributeIdListOut out nocopy ame_util.idList);
  procedure getRequiredAttributes(ruleIdIn in integer,
                                  attributeIdsOut out nocopy ame_util.idList);
  procedure getRuleAppUsages(ruleIdIn in integer,
                             transactionTypeDescriptionsOut out nocopy ame_util.stringList);
  procedure getRuleUsages(ruleIdIn in integer,
                          applicationIdsOut out nocopy ame_util.idList,
                          prioritiesOut out nocopy ame_util.stringList);
/*
AME_STRIPING
  procedure getStripeSetRules(stripeSetIdIn in integer,
                              ruleIdsOut out nocopy ame_util.idList);
  procedure getStripeSets(ruleIdIn in integer,
                          effectiveRuleDateIn in date default sysdate,
                          stripeSetIdsOut out nocopy ame_util.idList);
*/
  procedure getTransTypeItemClasses(applicationIdIn in integer,
                                    itemClassIdIn in integer,
                                    itemClassIdsOut out nocopy ame_util.stringList,
                                    itemClassNamesOut out nocopy ame_util.stringList);
  procedure getTypedConditions(ruleIdIn in integer,
                               conditionTypeIn in varchar2,
                               conditionIdsOut out nocopy ame_util.idList);
  procedure getTypedConditions2(ruleIdIn in integer,
                               conditionTypeIn in varchar2,
                               conditionListOut out nocopy ame_util.longStringList,
                               conditionIdsOut out nocopy ame_util.idList);
/*
AME_STRIPING
  procedure newRuleStripeSet(applicationIdIn in integer,
                             ruleIdIn in integer,
                             stripeSetIdIn in integer);
*/
  procedure remove(ruleIdIn in integer,
                   finalizeIn in boolean default true,
                   processingDateIn in date default null);
/*
AME_STRIPING
  procedure removeRuleStripeSet(stripeSetIdsIn in ame_util.idList default ame_util.emptyIdList,
                                ruleIdIn in integer default null,
                                finalizeIn in boolean default false);
*/
  procedure removeUsage(ruleIdIn in integer,
                        itemIdIn in integer,
                        usageStartDateIn in date,
                        parentVersionStartDateIn in date,
                        finalizeIn in boolean default true,
                        processingDateIn in date default null);
/*
AME_STRIPING
  procedure updateRuleStripeSets(applicationIdIn in integer,
                                 ruleIdIn in integer,
                                 conditionIdsIn in ame_util.idList,
                                 finalizeIn in boolean default false);
*/
end ame_rule_pkg;

 

/
