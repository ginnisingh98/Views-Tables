--------------------------------------------------------
--  DDL for Package AME_CONDITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONDITION_PKG" AUTHID CURRENT_USER as
/* $Header: ameocond.pkh 120.0 2005/07/26 06:04:59 mbocutt noship $*/
  function getAttributeId(conditionIdIn in integer) return integer;
  function getAttributeName(conditionIdIn in integer) return varchar2;
  function getAttributeType(conditionIdIn in integer) return varchar2;
  function getConditionType(conditionIdIn in integer) return varchar2;
  function getConditionKey(conditionIdIn in integer,
	                         processingDateIn in date default null) return varchar2;
	function conditionKeyExists (conditionKeyIn in varchar2) return boolean;
	function getNextConditionKey return varchar2;
  function getDescription(conditionIdIn in integer) return varchar2;
  function getIncludeLowerLimit(conditionIdIn in integer) return varchar;
  function getIncludeUpperLimit(conditionIdIn in integer) return varchar;
  function isStringAttributeType(conditionIdIn in integer) return boolean;
  function getParameterOne(conditionIdIn in integer) return varchar;
  function getParameterTwo(conditionIdIn in integer) return varchar;
  function getParameterThree(conditionIdIn in integer) return varchar;
  function getStartDate(conditionIdIn in integer) return date;
  function getType(conditionIdIn in integer) return varchar2;
  function getVersionStartDate(conditionIdin integer) return varchar2;
  function isConditionUsage(ruleIdIn in integer,
                            conditionIdIn in integer) return boolean;
  function isInUseByOtherApps(conditionIdIn in integer,
                              applicationIdIn in integer) return boolean;
  function isInUse(conditionIdIn in integer) return boolean;
  function lineItemIsInUse(applicationIdIn in integer,
                           conditionTypeIn in varchar2) return boolean;
  function new(typeIn in varchar2,
               attributeIdIn in integer,
               conditionKeyIn in varchar2,
               attributeTypeIn in varchar2 default null,
               parameterOneIn in varchar2 default null,
               parameterTwoIn in varchar2 default null,
               parameterThreeIn in varchar2 default null,
               includeLowerLimitIn in varchar2 default null,
               includeUpperLimitIn in varchar2 default null,
               stringValueListIn in ame_util.longestStringList default ame_util.emptyLongestStringList,
               newStartDateIn in date default null,
               conditionIdIn in integer default null,
               commitIn in boolean default true,
               processingDateIn in date default null) return integer;
  function newConditionUsage(ruleIdIn in integer,
                             conditionIdIn in integer,
                             processingDateIn in date default null) return boolean;
  function newStringValue(conditionIdIn in integer,
                          valueIn in varchar2,
                          processingDateIn in date default null) return boolean;
  procedure change(conditionIdIn  in integer,
                   stringValuesIn in ame_util.longestStringList default ame_util.emptyLongestStringList,
                   typeIn in varchar2 default null,
                   attributeIdIn in integer default null,
                   parameterOneIn in varchar2 default null,
                   parameterTwoIn in varchar2 default null,
                   parameterThreeIn in varchar2 default null,
                   includeLowerLimitIn in varchar2 default null,
                   includeUpperLimitIn in varchar2 default null,
                   versionStartDateIn in date,
                   processingDateIn in date default null);
  procedure getAllProperties(conditionIdIn in integer,
                             conditionTypeOut out nocopy varchar2,
														 conditionKeyOut out nocopy varchar2,
                             attributeIdOut out nocopy integer,
                             parameterOneOut out nocopy varchar2,
                             parameterTwoOut out nocopy varchar2,
                             parameterThreeOut out nocopy varchar2,
                             includeLowerLimitOut out nocopy varchar2,
                             includeUpperLimitOut out nocopy varchar2);
  procedure getApplicationsUsingCondition(conditionIdIn in integer,
                                          applicationIdIn in integer,
                                          applicationNamesOut out nocopy ame_util.stringList);
  procedure getAttributesConditions(attributeIdsIn in ame_util.idList,
                                    conditionTypeIn in varchar2,
                                    lineItemIn in varchar2 default ame_util.booleanFalse,
                                    conditionIdsOut out nocopy ame_util.stringList,
                                    conditionDescriptionsOut out nocopy ame_util.longStringList);
  procedure getAttributesConditions1(attributeIdsIn in ame_util.idList,
                                     conditionTypeIn in varchar2,
                                     itemClassIdIn in integer,
                                     ruleIdIn in integer,
                                     conditionIdsOut out nocopy ame_util.stringList,
                                     conditionDescriptionsOut out nocopy ame_util.longStringList);
  procedure getAttributesConditions2(attributeIdsIn in ame_util.idList,
                                     conditionTypeIn in varchar2,
                                     itemClassIdIn in integer,
                                     lineItemIn in varchar2 default ame_util.booleanFalse,
                                     conditionIdsOut out nocopy ame_util.stringList,
                                     conditionDescriptionsOut out nocopy ame_util.longStringList);
  procedure getAuthPreConditions(applicationIdIn in integer,
                                 itemClassIdIn in integer,
                                 conditionIdsOut out nocopy ame_util.stringList,
                                 conditionTypesOut out nocopy ame_util.stringList,
                                 attributeIdsOut out nocopy ame_util.stringList,
                                 attributeNamesOut out nocopy ame_util.stringList,
                                 attributeTypesOut out nocopy ame_util.stringList,
                                 conditionDescriptionsOut out nocopy ame_util.longStringList);
  procedure getDescriptions(conditionIdsIn in ame_util.idList,
                            descriptionsOut out nocopy ame_util.longStringList);
  procedure getDetailUrls(applicationIdIn in integer,
	                        conditionIdsIn in ame_util.idList,
                          detailUrlsOut out nocopy ame_util.longStringList);
  procedure getLMConditions(conditionIdOut out nocopy ame_util.idList,
                            parameterOneOut out nocopy ame_util.stringList,
                            parameterTwoOut out nocopy ame_util.stringList);
  procedure getLMDescriptions(conditionIdsOut out nocopy ame_util.stringList,
                              descriptionsOut out nocopy ame_util.longStringList);
  procedure getLMDescriptions2(conditionIdsOut out nocopy ame_util.stringList,
                               descriptionsOut out nocopy ame_util.longStringList);
  procedure getLMDescriptions3(lmApproverTypeIn in varchar2,
                               conditionIdsOut out nocopy ame_util.stringList,
                               descriptionsOut out nocopy ame_util.longStringList);
  procedure getStringValueList(conditionIdIn in integer,
                               stringValueListOut out nocopy ame_util.longestStringList);
  procedure remove(conditionIdIn in integer,
                   versionStartDateIn in date,
                   processingDateIn in date default null);
  procedure removeConditionUsage(ruleIdIn in integer,
                                 conditionIdIn in integer,
                                 newConditionIdIn in integer default null,
                                 finalizeIn in boolean default true,
                                 processingDateIn in date default null);
  procedure removeStringValue(conditionIdIn  in integer,
                              versionStartDateIn in date,
                              stringValueListIn in ame_util.longestStringList,
                              processingDateIn in date default null);
end ame_condition_pkg;

 

/
