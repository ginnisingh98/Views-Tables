--------------------------------------------------------
--  DDL for Package AME_ADMIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ADMIN_PKG" AUTHID CURRENT_USER as
/* $Header: ameoadmi.pkh 120.0 2005/07/26 06:04:22 mbocutt noship $ */
  function arePrioritiesDisabled(applicationIdIn in integer) return boolean;
  function canHaveItemAttributes(applicationIdIn in integer,
                                 itemClassIdIn in integer) return boolean;
  function getChildVersionStartDate(itemClassIdIn in integer,
                                    applicationIdIn in integer) return varchar2;
/*
AME_STRIPING
  function doesStripeSetIdExist(stripeSetIdIn in integer) return boolean;
*/
  function getEqualityConditionId(attributeIdIn in integer,
                                  stringValueIn in varchar2) return integer;
  function getApplicationId(fndAppIdIn in integer,
                            transactionTypeIdIn in varchar2) return integer;
  function getApplicationIdByName(nameIn in varchar2) return integer;
  function getApplicationName(applicationIdIn in integer) return varchar2;
  function getAttributeQuery(selectClauseIn in varchar2) return ame_util.queryCursor;
/*
AME_STRIPING
  function getAttributeDisplayValue(attributeValueIn in varchar2) return varchar2;
  function getAttributeStripingUseCount(applicationIdIn in integer,
                                        attributeIdIn in integer) return integer;
*/
  function getFndAppDescription(fndAppIdIn in integer) return varchar2;
  function getFndAppDescription1(applicationIdIn in integer) return varchar2;
  function getFndApplicationId(applicationIdIn in integer) return integer;
/*
AME_STRIPING
  procedure addStripingAttribute(attributeIdIn in integer,
                                 applicationIdIn in integer);
  procedure getAttributeStripeSetNames(applicationIdIn in integer,
                                       stripingAttributeIdsOut out nocopy ame_util.idList,
                                       stripingAttributeNamesOut out nocopy ame_util.stringList);
*/
  procedure getExistingShareableIClasses(applicationIdIn in integer,
                                         itemClassIdsOut out nocopy ame_util.stringList,
                                         itemClassNamesOut out nocopy ame_util.stringList);
  procedure getFndApplications(fndAppIdsOut out nocopy ame_util.stringList,
                               fndAppNamesOut out nocopy ame_util.stringList);
  procedure getForwardingBehaviorList(forwardingBehaviorIn in integer,
                                      forwardingBehaviorValuesOut out nocopy ame_util.stringList,
                                      forwardingBehaviorLabelsOut out nocopy ame_util.stringList);
  function getLineItemQueryString(applicationIdIn in integer) return varchar2;
  function getItemClassCount return integer;
  function getItemClassIdByName(itemClassNameIn in varchar2) return integer;
  function getItemClassIdQuery(itemClassIdIn in integer,
                               applicationIdIn in integer) return varchar2;
  function getItemClassMaxOrderNumber(applicationIdIn in integer) return integer;
	function getItemClassName(itemClassIdIn in integer) return varchar2;
  function getItemClassOrderNumber(itemClassIdIn in integer,
                                   applicationIdIn in integer) return integer;
  function getItemClassTransTypeCount(applicationIdIn in integer) return integer;
  function getItemClassParMode(itemClassIdIn in integer,
                              applicationIdIn in integer) return varchar2;
  function getParentVersionStartDate(itemClassIdIn in integer) return varchar2;
  function getItemClassSublistMode(itemClassIdIn in integer,
                                   applicationIdIn in integer) return varchar2;
  function getSubordinateItemClassId(applicationIdIn in integer) return integer;
  function getTransactionTypeId(applicationIdIn in integer) return varchar2;
  function getVersionStartDate(applicationIdIn in integer) return varchar2;
/*
AME_STRIPING
  function getVersionStartDate2(applicationIdIn in integer,
                                stripeSetIdIn in integer) return varchar2;
*/
  function hasLineItemAttributes(applicationIdIn in integer) return boolean;
/*
AME_STRIPING
  function hasRuleStripes(applicationIdIn in integer) return boolean;
*/
  function icInUseByAttributeUsage(itemClassIdIn in integer,
                                   applicationIdIn in integer) return boolean;
  function icInUseByRuleUsage(itemClassIdIn in integer,
                              applicationIdIn in integer) return boolean;
  function inputToCanonStaticCurUsage(attributeIdIn in integer,
                                      applicationIdIn in integer,
                                      queryStringIn varchar2) return varchar2;
  function isApplicationActive(applicationIdIn in integer) return boolean;
  function isInUseByApplication(itemClassIdIn in integer,
                                applicationIdIn in integer) return boolean;
  function isSeeded(applicationIdIn in integer) return boolean;
/*
AME_STRIPING
  function isStripingOn(applicationIdIn in integer) return boolean;
  function newStripeSet(applicationIdIn in integer,
                        attributeValuesIn in ame_util.stringList,
                        commitIn in boolean default false) return integer;
  function getStripeSetId(applicationIdIn in integer,
                          attributeValuesIn in ame_util.stringList) return integer;
*/
  function itemClassNameExists(itemClassnameIn in varchar2) return boolean;
  function newItemClass(itemClassNameIn in varchar2,
                        newStartDateIn in date,
                        finalizeIn in boolean default false,
                        itemClassIdIn in integer default null) return integer;
  function orderNumberUnique(applicationIdIn in integer,
														 orderNumberIn in integer) return boolean;
	function subordinateItemClassCount(applicationIdIn in integer) return integer;
  function transTypeCVValueExists(applicationIdIn in integer,
                                  variableNameIn in varchar2) return boolean;
  procedure change(applicationIdIn in integer,
                   transactionTypeIdIn in varchar2,
                   transactionTypeDescriptionIn in varchar2,
                   versionStartDateIn in date);
  procedure changeItemClass(itemClassIdIn in integer,
                            itemClassNameIn in varchar2,
                            startDateIn in date,
                            endDateIn in date,
                            finalizeIn in boolean default false);
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
                                    finalizeIn in boolean default false);
  procedure changeUsage(applicationIdIn in integer,
                        itemClassIdIn in integer,
                        itemClassParModeIn in varchar2,
                        itemClassSublistModeIn in varchar2,
                        itemClassIdQueryIn in varchar2,
                        orderNumberIn in integer,
                        orderNumberUniqueIn in varchar2,
                        endDateIn in date,
                        newStartDateIn in date,
                        finalizeIn in boolean default false);
  procedure checkNewOrChangedTransType(fndAppIdIn in integer,
                                       transTypeIdIn in varchar2,
                                       transTypeDescIn in varchar2);
/*
AME_STRIPING
  procedure checkStripeSetUsage(stripeSetIdIn in integer,
                                commitIn in boolean default false);
*/
  procedure clearTransException(applicationIdIn in integer,
                                transactionIdIn in varchar2);
  procedure clearTransTypeConfigVarValue(applicationIdIn in integer,
                                         variableNameIn in varchar2);
  procedure clearTransTypeExceptions(applicationIdIn in integer);
  procedure clearWebExceptions;
  procedure decrementItemClassOrderNumbers(applicationIdIn in integer,
                                           orderNumberIn in integer,
                                           finalizeIn in boolean default false);
/*
AME_STRIPING
  procedure enableRuleStriping(applicationIdIn in integer,
                               commitIn in boolean default false);
*/
  procedure getConfigVariables(applicationIdIn in integer default null,
                               variableNamesOut out nocopy ame_util.stringList,
                               descriptionsOut out nocopy ame_util.stringList);
/*
AME_STRIPING
  procedure getStripeSetIds(applicationIdIn in integer,
                            stripeSetIdsOut out nocopy ame_util.idList);
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
                             stripeSetIdListOut out nocopy ame_util.idList);
  procedure getStripingAttributeIds(applicationIdIn in integer,
                                    stripingAttributeIdsOut out nocopy ame_util.idList);
  procedure getStripingAttributeNames(applicationIdIn in integer,
                                      stripingAttributeNamesOut out nocopy ame_util.stringList);
  procedure getStripingAttributeValues(applicationIdIn in integer,
                                       stripingAttributeIdsOut out nocopy ame_util.stringList,
                                       stripingAttributeNamesOut out nocopy ame_util.stringList,
                                       allowedStripeValues1Out out nocopy ame_util.stringList,
                                       allowedStripeValues2Out out nocopy ame_util.stringList,
                                       allowedStripeValues3Out out nocopy ame_util.stringList,
                                       allowedStripeValues4Out out nocopy ame_util.stringList,
                                       allowedStripeValues5Out out nocopy ame_util.stringList);
  procedure getStripingAttributeValues2(applicationIdIn in integer,
                                        stripeSetIdIn in integer,
                                        stripingAttributeIdsOut out nocopy ame_util.stringList,
                                        stripingAttributeNamesOut out nocopy ame_util.stringList,
                                        stripeValue1Out out nocopy varchar2,
                                        stripeValue2Out out nocopy varchar2,
                                        stripeValue3Out out nocopy varchar2,
                                        stripeValue4Out out nocopy varchar2,
                                        stripeValue5Out out nocopy varchar2);
  procedure getStripingAttributeValues3(applicationIdIn in integer,
                                        stripeSetIdIn in integer,
                                        stripeValue1Out out nocopy varchar2,
                                        stripeValue2Out out nocopy varchar2,
                                        stripeValue3Out out nocopy varchar2,
                                        stripeValue4Out out nocopy varchar2,
                                        stripeValue5Out out nocopy varchar2);
*/
  procedure getItemClassList(applicationIdIn in integer,
                             itemClassIdListOut out nocopy ame_util.idList,
                             itemClassNameListOut out nocopy ame_util.stringList,
                             itemClassOrderNumbersOut out nocopy ame_util.idList);
  procedure getTransExceptions(applicationIdIn in integer,
                               transactionIdIn in  varchar2,
                               exceptionLogOut out nocopy ame_util.exceptionLogTable);
  procedure getTransTypeExceptions1(applicationIdIn in integer,
                                    exceptionLogOut out nocopy ame_util.exceptionLogTable);
  procedure getTransTypeExceptions2(applicationIdIn in integer,
                                    exceptionLogOut out nocopy ame_util.exceptionLogTable);
  procedure getTransactionTypes(applicationIdsOut out nocopy ame_util.idList,
                                applicationNamesOut out nocopy ame_util.stringList,
                                transactionTypesOut out nocopy ame_util.stringList,
                                createdByOut out nocopy ame_util.idList);
  procedure getTransTypeItemClasses(applicationIdIn in integer,
                                    itemClassIdsOut out nocopy ame_util.stringList,
                                    itemClassNamesOut out nocopy ame_util.stringList);
  procedure getTransTypeItemClasses2(applicationIdIn in integer,
                                     itemClassIdsOut out nocopy ame_util.idList,
                                     itemClassNamesOut out nocopy ame_util.stringList);
  procedure getTransTypeItemClasses3(applicationIdIn in integer,
                                     itemClassIdsOut out nocopy ame_util.idList,
                                     itemClassNamesOut out nocopy ame_util.stringList);
  procedure getTransTypeItemClasses4(applicationIdIn in integer,
                                     itemClassIdsOut out nocopy ame_util.stringList,
                                     itemClassNamesOut out nocopy ame_util.stringList);
  procedure getTransTypeItemClassIds(applicationIdIn in integer,
                                     itemClassIdsOut out nocopy ame_util.idList);
  procedure getWebExceptions(exceptionLogOut out nocopy ame_util.exceptionLogTable);
  procedure getWorkflowLog(applicationIdIn in integer,
                           transactionIdIn in varchar2 default null,
                           logOut out nocopy ame_util.workflowLogTable);
/*
AME_STRIPING
  procedure newStripeSet2(applicationIdIn in integer,
                          newStripedAttributesSetIn in ame_util.stringList,
                          commitIn in boolean default false);
*/
  procedure incrementItemClassOrderNumbers(applicationIdIn in integer,
                                           itemClassIdIn in integer,
                                           orderNumberIn in integer,
																	         finalizeIn in boolean default false);
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
                              parentVersionStartDateIn in date default null);
  procedure registerTransactionType(fndApplicationIdIn in integer,
                                    transTypeDescIn in varchar2,
                                    transactionTypeIdIn in varchar2 default null,
                                    attributeIdsIn in ame_util.stringList,
                                    queryStringsIn in ame_util.longestStringList,
                                    staticUsagesIn in ame_util.stringList,
                                    versionStartDatesIn in ame_util.stringList);
  procedure removeUsage(itemClassIdIn in integer,
                        parentVersionStartDateIn in date,
                        childVersionStartDateIn in date,
                        applicationIdIn in integer,
                        finalizeIn in boolean default false);
/*
AME_STRIPING
  procedure removeAllStripeSets(applicationIdIn in integer,
                                deleteStripeSetIdZeroIn in boolean,
                                commitIn in boolean default false);
  procedure removeStripeSetAttributes(applicationIdIn in integer,
                                      attributeIdIn in integer);
*/
  procedure removeTransactionType(applicationIdIn in integer,
                                  versionStartDateIn in date);
/*
AME_STRIPING
  procedure updateStripingAttIds(applicationIdIn in integer,
                                 stripedAttributesIn in ame_util.stringList);
  procedure updateStripingAttUseCount(applicationIdIn in integer);
*/
end ame_admin_pkg;

 

/
