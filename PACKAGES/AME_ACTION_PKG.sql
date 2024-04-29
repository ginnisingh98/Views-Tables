--------------------------------------------------------
--  DDL for Package AME_ACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTION_PKG" AUTHID CURRENT_USER as
/* $Header: ameoacti.pkh 120.0 2005/07/26 06:04:11 mbocutt noship $  */
  function actionTypeIsInUse(actionTypeIdIn in integer) return boolean;
  function getActionTypeDescQuery(actionTypeIdIn in integer) return varchar2;
  function getActionTypeDynamicDesc(actionTypeIdIn in integer) return varchar2;
  function getActionTypeIdById(actionIdIn in integer) return integer;
  function getActionTypeIdByName(actionTypeNameIn in varchar2) return integer;
  function getActionTypeDescription(actionTypeIdIn in integer) return varchar2;
  function getActionTypeMaxOrderNumber(applicationIdIn in integer,
	                                     ruleTypeIn in integer) return integer;
  function getActionTypeName(actionTypeIdIn in integer) return varchar2;
  function getActionTypeNameByActionId(actionIdIn in integer) return varchar2;
  function getActionTypeOrderNumber(applicationIdIn in integer,
                                    actionTypeIdIn in integer) return integer;
  function getActionTypeProcedureName(actionTypeIdIn in integer) return varchar2;
  function getActionTypeCreatedBy(actionTypeIdIn in integer) return integer;
  function getAllowedRuleType(actionTypeIdIn in integer) return integer;
  function getAllowedRuleTypeLabel(ruleTypeIn in integer) return varchar2;
  function getChainOrderingMode(actionTypeIdIn in integer,
                                applicationIdIn in integer) return varchar2;
  function getChildVersionStartDate(actionIdIn in integer) return varchar2;
  function getChildVersionStartDate2(actionTypeIdIn in integer,
                                     applicationIdIn in integer) return varchar2;
  function getDescription(actionIdIn in integer) return varchar2;
  function getDescription2(actionIdIn in integer) return varchar2;
  function getDynamicActionDesc(actionIdIn in integer) return varchar2;
  function getGroupChainActionTypeId return integer;
  function getId(actionTypeIdIn in integer,
                 parameterIn in varchar2 default null) return integer;
  function getParameter(actionIdIn in integer) return varchar2;
  function getParameter2(actionIdIn in integer) return varchar2;
  function getParentVersionStartDate(actionTypeIdIn in integer) return varchar2;
  function getPostApprovalActionTypeId return integer;
  function getPreApprovalActionTypeId return integer;
  function getVotingRegime(actionTypeIdIn in integer,
                           applicationIdIn in integer) return varchar2;
  function isInUse(actionIdIn in integer) return boolean;
  function isListCreationRuleType(actionTypeIdIn in integer) return boolean;
  function isSeeded(actionTypeIdIn in integer) return boolean;
  function new(nameIn in varchar2,
               procedureNameIn in varchar2,
               dynamicDescriptionIn in varchar2,
               descriptionIn in varchar2 default null,
               descriptionQueryIn in varchar2 default null,
               actionTypeIdIn in integer default null,
               finalizeIn in boolean default false,
               newStartDateIn in date default null,
               processingDateIn in date default null) return integer;
  function newAction(actionTypeIdIn in integer,
                     updateParentObjectIn in boolean,
                     descriptionIn in varchar2 default null,
                     parameterIn in varchar2 default null,
                     parameterTwoIn in varchar2 default null,
                     newStartDateIn in date default null,
                     finalizeIn in boolean default false,
                     parentVersionStartDateIn in date default null,
                     actionIdIn in integer default null,
                     processingDateIn in date default null) return integer;
  function orderNumberUnique(applicationIdIn in integer,
														 orderNumberIn in integer,
														 actionTypeIdIn in integer) return boolean;
	function requiredAttOnApprovalTypeList(actionTypeIdIn in integer,
                                         attributeIdIn in integer) return boolean;
  procedure change(actionTypeIdIn in integer,
                   ruleTypeIn in varchar2,
                   processingDateIn in date,
                   descriptionQueryIn in varchar2 default null,
                   nameIn in varchar2 default null,
                   procedureNameIn in varchar2 default null,
                   descriptionIn in varchar2 default null,
                   deleteListIn in ame_util.stringList default ame_util.emptyStringList,
                   finalizeIn in boolean default false);
  procedure changeActionTypeAndConfig(actionTypeIdIn in integer,
                                      ruleTypeIn in varchar2,
                                      orderNumberIn in integer,
                                      orderNumberUniqueIn in varchar2,
                                      childVersionStartDate2In in date,
                                      parentVersionStartDateIn in date,
                                      applicationIdIn in integer,
                                      descriptionQueryIn in varchar2 default null,
                                      chainOrderIngModeIn in varchar2 default null,
                                      votingRegimeIn in varchar2 default null,
                                      nameIn in varchar2 default null,
                                      procedureNameIn in varchar2 default null,
                                      descriptionIn in varchar2 default null,
                                      deleteListIn in ame_util.stringList default ame_util.emptyStringList,
                                      finalizeIn in boolean default false);
  procedure changeActionTypeConfig(applicationIdIn in integer,
                                   actionTypeIdIn in integer,
                                   orderNumberIn in integer,
                                   orderNumberUniqueIn in varchar2,
                                   processingDateIn in date,
                                   votingRegimeIn in varchar2 default null,
                                   chainOrderingModeIn in varchar2 default null,
                                   finalizeIn in boolean default false);
  procedure changeAction(actionIdIn in integer,
                         actionTypeIdIn in integer default null,
                         descriptionIn in varchar2 default null,
                         parameterIn in varchar2 default null,
                         parameterTwoIn in varchar2 default null,
                         finalizeIn in boolean default false,
                         childVersionStartDateIn in date,
                         parentVersionStartDateIn in date,
                         processingDateIn in date default null);
  procedure decrementActionTypeOrdNumbers(applicationIdIn in integer,
                                          actionTypeIdIn in integer,
                                          orderNumberIn in integer,
                                          finalizeIn in boolean default false);
	procedure getActions(actionTypeIdIn in integer,
                       actionsOut out nocopy ame_util.idStringTable);
  procedure getActions2(actionTypeIdIn in integer,
                        actionIdsOut out nocopy ame_util.stringList,
                        actionDescriptionsOut out nocopy ame_util.longStringList);
  procedure getActions3(actionTypeIdIn in integer,
                        dynamicDescriptionIn in varchar2,
                        actionTypeNamesOut out nocopy ame_util.stringList,
                        actionIdsOut out nocopy ame_util.idList,
                        actionParametersOut out nocopy ame_util.stringList,
                        actionDescriptionsOut out nocopy ame_util.stringList,
                        actionCreatedByOut out nocopy ame_util.idList);
  procedure getActions4(actionTypeIdIn in integer,
                        actionIdsOut out nocopy ame_util.stringList,
                        actionDescriptionsOut out nocopy ame_util.stringList);
  procedure getActionTypes(actionTypesOut out nocopy ame_util.idStringTable);
  procedure getActionTypes2(actionTypeIdsOut out nocopy ame_util.stringList,
                            actionTypeNamesOut out nocopy ame_util.stringList);
  procedure getActionTypes3(applicationIdIn in integer,
                            actionTypeIdsOut out nocopy ame_util.stringList,
                            actionTypeNamesOut out nocopy ame_util.stringList,
                            actionTypeDescriptionsOut out nocopy ame_util.stringList,
                            ruleTypesOut out nocopy ame_util.idList);
  procedure getActionTypeDescriptions(actionTypeIdsOut out nocopy ame_util.stringList,
                                      actionTypeDescriptionsOut out nocopy ame_util.stringList);
  procedure getActionTypeUsages(actionTypeIdIn in integer,
                                ruleTypesOut out nocopy ame_util.stringList);
  procedure getActionTypeUsages2(actionTypeIdsOut out nocopy ame_util.idList,
                                 ruleTypesOut out nocopy ame_util.idList);
  procedure getAllowedApproverTypes(actionTypeIdIn in integer,
                                    allowedApproverTypeIdsOut out nocopy ame_util.stringList,
                                    allowedApproverTypeNamesOut out nocopy ame_util.stringList);
  procedure getAllowedRuleTypeLabels(allowedRuleTypesOut out nocopy ame_util.stringList,
                                     allowedRuleTypeLabelsOut out nocopy ame_util.stringList);
  procedure getAvailableActionTypes(applicationIdIn in integer,
                                    ruleTypeIn in integer,
                                    actionTypeIdsOut out nocopy ame_util.stringList,
                                    actionTypeDescriptionsOut out nocopy ame_util.stringList);
  procedure getAvailCombActionTypes(applicationIdIn in integer,
                                    subOrListModActsForCombRuleIn in varchar2,
                                    actionTypeIdsOut out nocopy ame_util.stringList,
                                    actionTypeDescriptionsOut out nocopy ame_util.stringList);
  procedure incrementActionTypeOrdNumbers(applicationIdIn in integer,
                                          actionTypeIdIn in integer,
                                          orderNumberIn in integer,
                                          finalizeIn in boolean default false);
	procedure newActionTypeConfig(applicationIdIn in integer,
	                              actionTypeIdIn in integer,
                                ruleTypeIn in integer,
                                orderNumberUniqueIn in varchar2,
                                orderNumberIn in integer,
                                chainOrderingModeIn in varchar2,
                                votingRegimeIn in varchar2,
                                finalizeIn in boolean default false);
  procedure newActionTypeUsage(actionTypeIdIn in integer,
                               ruleTypeIn in integer,
                               finalizeIn in boolean default false,
                               processingDateIn in date default null);
  procedure remove(actionTypeIdIn in integer,
                   finalizeIn in boolean default false,
                   parentVersionStartDateIn in date,
                   processingDateIn in date default null);
  procedure removeAction(actionTypeIdIn in integer,
                         actionIdIn in ame_util.idList default ame_util.emptyIdList,
                         childVersionStartDatesIn in ame_util.dateList,
                         finalizeIn in boolean default false,
                         processingDateIn in date default null);
  procedure removeActionTypeUsage(actionTypeIdIn in integer,
                                  ruleTypeIn in integer,
                                  finalizeIn in boolean default false,
                                  processingDateIn in date default null);
  procedure removeActionTypeUsages(actionTypeIdIn in integer,
                                   finalizeIn in boolean default false,
                                   processingDateIn in date default null);
end AME_action_pkg;

 

/
