--------------------------------------------------------
--  DDL for Package AME_ATTRIBUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATTRIBUTE_PKG" AUTHID CURRENT_USER as
/* $Header: ameoattr.pkh 120.0 2005/07/26 06:04:33 mbocutt noship $ */
  function attributeExists(attributeIdIn in integer) return boolean;
  function attributeExistsForDiffIC(attributeNameIn in varchar2,
	                                  itemClassIdIn in integer) return boolean;
/*
AME_STRIPING
  function calculateUseCount(attributeIdIn in integer,
                             applicationIdIn in integer,
                             isStripingAttributeChangeIn in varchar2 default ame_util.booleanFalse,
                             isBecomingStripingAttributeIn in varchar2 default ame_util.booleanFalse) return integer;
*/
  function calculateUseCount(attributeIdIn in integer,
                             applicationIdIn in integer) return integer;
  function getApprovalTypeNames(attributeIdIn in integer) return varchar2;
  function getApproverTypeId(attributeIdIn in integer) return integer;
  function getAttributeConditionCnt(attributeIdIn in integer,
                                    conditionTypeIn in varchar2) return integer;
  function getAttributeConditionInUseCnt(attributeIdIn in integer,
                                         conditionTypeIn in varchar2,
                                         ruleIdIn in integer) return integer;
  function getAttributeNames(actionTypeIdIn in integer) return varchar2;
  function getDescription(attributeIdIn in integer) return varchar2;
  function getIdByName(attributeNameIn in varchar2) return integer;
  function getItemClassId(attributeIdIn in integer) return integer;
  function getLineItem(attributeIdIn in integer) return varchar2;
  function getName(attributeIdIn in integer) return varchar2;
  function getQueryString(attributeIdIn in integer,
                          applicationIdIn in integer) return varchar2;
  function getStartDate(attributeIdIn in integer) return date;
  function getStaticUsage(attributeIdIn in integer,
                          applicationIdIn in integer) return varchar2;
  function getType(attributeIdIn in integer) return varchar2;
  function getUseCount(attributeIdIn in integer,
                       applicationIdIn in integer) return varchar2;
  function getUserEditable(attributeIdIn in integer,
                           applicationIdIn in integer) return varchar2;
  function getChildVersionStartDate(attributeIdIn in integer,
                                    applicationIdIn in integer) return varchar2;
  function getParentVersionStartDate(attributeIdIn in integer) return varchar2;
  function hasUsage(attributeIdIn in integer,
                    applicationIdIn in integer) return boolean;
  function inputToCanonStaticCurUsage(attributeIdIn in integer,
                                      applicationIdIn in integer,
                                      queryStringIn varchar2) return varchar2;
/*
AME_STRIPING
  function isAStripingAttribute(applicationIdIn in integer,
                                attributeIdIn in integer) return boolean;
*/
  function isInUse(attributeIdIn in integer) return boolean;
  function isInUseByApplication(attributeIdIn in integer,
                                applicationIdIn in integer) return boolean;
  function isLIneItem(attributeIdIn in integer) return boolean;
  function isMandatory(attributeIdIn in integer) return boolean;
  function isNonHeaderAttributeItem(attributeIdIn in integer) return boolean;
  function isRequired(attributeIdIn in integer) return boolean;
  function isSeeded(attributeIdIn in integer) return boolean;
/*
AME_STRIPING
  function isStripingAttribute(applicationIdIn in integer,
                               attributeIdIn in integer) return boolean;
*/
  function nameExists(nameIn in varchar2) return boolean;
  function new(nameIn in varchar2,
               typeIn in varchar2,
               descriptionIn in varchar2,
               itemClassIdIn in integer,
               approverTypeIdIn in integer default null,
               finalizeIn in boolean default false,
               newStartDateIn in date default null,
               attributeIdIn in integer default null,
               createdByIn in integer default null) return integer;
  function usageIsUserEditable(attributeIdIn in integer,
                               applicationIdIn in integer) return boolean;
  procedure change(attributeIdIn in integer,
                   applicationIdIn in integer default null,
                   nameIn in varchar2,
                   typeIn in varchar2,
                   startDateIn in date,
                   endDateIn in date,
                   descriptionIn in varchar2 default null,
                   itemClassIdIn in integer,
                   finalizeIn in boolean default false);
  procedure changeAttributeAndUsage(attributeIdIn in integer,
                                    applicationIdIn in integer default null,
                                    staticUsageIn in varchar2,
                                    queryStringIn in varchar2 default null,
                                    nameIn in varchar2 default null,
                                    descriptionIn in varchar2 default null,
                                    parentVersionStartDateIn in date,
                                    childVersionStartDateIn in date,
                                    itemClassIdIn in integer,
                                    finalizeIn in boolean default false);
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
                        finalizeIn in boolean default true);
*/
  procedure changeUsage(attributeIdIn in integer,
                        applicationIdIn in integer,
                        staticUsageIn in varchar2,
                        queryStringIn in varchar2 default null,
                        endDateIn in date,
                        newStartDateIn in date,
                        finalizeIn in boolean default false);
  /*
    An attribute is "active" for a given transaction type (calling application) if it is a
    mandatory attribute, or if its ame_attribute_usages.use_count > 0.  The engine fetches
    the values of all and only active attributes when processing a transaction.  The
    procedure getActiveAttributes orders the attribute IDs in attributeIdsOut by attribute
    name, so that the procedure is useful to UI code.  The engine's fetchAttributeValues
    function also requires attribute type, and does not require the by-name ordering,
    so it uses its own cursor for efficiency.
  */
  procedure getActiveAttributes(applicationIdIn in integer,
                                attributeIdsOut out nocopy ame_util.idList,
                                attributeNamesOut out nocopy ame_util.stringList);
  procedure getActiveHeaderAttributes(applicationIdIn in integer,
                                      attributeIdsOut out nocopy ame_util.idList,
                                      attributeNamesOut out nocopy ame_util.stringList);
  procedure getAllAttributes(attributeIdsOut out nocopy ame_util.stringList,
                             attributeNamesOut out nocopy ame_util.stringList);
  procedure getApplicationAttributes(applicationIdIn in integer,
                                     attributeIdOut out nocopy ame_util.idList);
  procedure getApplicationAttributes2(applicationIdIn in integer,
                                      itemClassIdIn in integer,
                                      attributeIdOut out nocopy ame_util.stringList,
                                      attributeNameOut out nocopy ame_util.stringList);
/*
AME_STRIPING
  procedure getApplicationAttributes3(applicationIdIn in integer,
                                      attributeIdsOut out nocopy ame_util.stringList,
                                      attributeNamesOut out nocopy ame_util.stringList);
*/
  procedure getAttributes(applicationIdIn in integer,
                          ruleTypeIn in integer,
                          lineItemIn in varchar2 default ame_util.booleanFalse,
                          attributeIdOut out nocopy ame_util.stringList,
                          attributeNameOut out nocopy ame_util.stringList);
  procedure getAttributes2(applicationIdIn in integer,
                           itemClassIdIn in integer,
                           ruleTypeIn in integer,
                           lineItemIn in varchar2 default ame_util.booleanFalse,
                           attributeIdOut out nocopy ame_util.stringList,
                           attributeNameOut out nocopy ame_util.stringList);
  procedure getAttributes3(applicationIdIn in integer,
                           ruleIdIn in integer,
                           itemClassIdIn in integer,
                           conditionTypeIn in varchar2,
                           ruleTypeIn in integer,
                           attributeIdOut out nocopy ame_util.stringList,
                           attributeNameOut out nocopy ame_util.stringList);
  procedure getAttributeConditions(attributeIdIn in integer,
                                   conditionIdListOut out nocopy ame_util.idList);
  procedure getAvailReqAttributes(actionTypeIdIn in integer,
                                  attributeIdOut out nocopy ame_util.stringList,
                                  attributeNameOut out nocopy ame_util.stringList);
/*
AME_STRIPING
  procedure getLineItemAttributes(applicationIdIn in integer,
                                  isStripingAttributeIn in varchar2 default ame_util.booleanFalse,
                                  attributeIdOut out nocopy ame_util.stringList,
                                  attributeNameOut out nocopy ame_util.stringList);
*/
  procedure getExistingShareableAttNames(applicationIdIn in integer,
                                         itemClassIdIn in integer,
                                         attributeIdsOut out nocopy ame_util.stringList,
                                         attributeNamesOut out nocopy ame_util.stringList);
  procedure getHeaderICAttributes(applicationIdIn in integer,
                                  attributeIdsOut out nocopy ame_util.stringList,
                                  attributeNamesOut out nocopy ame_util.stringList);
  procedure getLineItemAttributes(applicationIdIn in integer,
                                  attributeIdOut out nocopy ame_util.stringList,
                                  attributeNameOut out nocopy ame_util.stringList);
  procedure getLineItemAttributes2(applicationIdIn in integer,
                                   attributeIdOut out nocopy ame_util.stringList,
                                   attributeNameOut out nocopy ame_util.stringList);
  procedure getMandatoryAttributes(attributeIdOut out nocopy ame_util.stringList,
                                   attributeNameOut out nocopy ame_util.stringList,
                                   attributeTypeOut out nocopy ame_util.stringList,
                                   attributeStartDateOut out nocopy ame_util.stringList);
  procedure getMandatoryAttributes2(applicationIdIn in integer,
                                    attributeIdOut out nocopy ame_util.stringList,
                                    attributeNameOut out nocopy ame_util.stringList,
                                    attributeTypeOut out nocopy ame_util.stringList);
  procedure getMandatoryAttributes3(attributeIdOut out nocopy ame_util.stringList,
                                    attributeNameOut out nocopy ame_util.stringList,
                                    attributeTypeOut out nocopy ame_util.stringList,
                                    attributeStartDateOut out nocopy ame_util.stringList);
  procedure getNonHeaderICAttributes(applicationIdIn in integer,
                                     itemClassIdIn in integer,
                                     attributeIdsOut out nocopy ame_util.stringList,
                                     attributeNamesOut out nocopy ame_util.stringList);
  procedure getNonHeaderICAttributes2(applicationIdIn in integer,
                                      itemClassIdIn in integer,
                                      attributeIdsOut out nocopy ame_util.idList,
                                      attributeNamesOut out nocopy ame_util.stringList);
  procedure getNonMandatoryAttributes(applicationIdIn in integer,
                                      attributeIdOut out nocopy ame_util.stringList,
                                      attributeNameOut out nocopy ame_util.stringList);
  procedure getNonMandHeaderAttributes(applicationIdIn in integer,
                                       attributeIdOut out nocopy ame_util.stringList,
                                       attributeNameOut out nocopy ame_util.stringList);
  procedure getRequiredAttributes(actionTypeIdIn in integer,
                                  attributeIdOut out nocopy ame_util.stringList,
                                  attributeNameOut out nocopy ame_util.stringList);
  procedure getSubordinateICAttributes(applicationIdIn in integer,
                                       itemClassIdIn in integer,
                                       attributeIdsOut out nocopy ame_util.stringList,
                                       attributeNamesOut out nocopy ame_util.stringList);
  procedure getSubordinateICAttributes2(applicationIdIn in integer,
                                        itemClassIdIn in integer,
                                        attributeIdsOut out nocopy ame_util.idList,
                                        attributeNamesOut out nocopy ame_util.stringList,
                                        attributeTypesOut out nocopy ame_util.stringList);
/*
AME_STRIPING
  procedure getRuleStripingAttributes(applicationIdIn in integer,
                                      attributeIdsOut out nocopy ame_util.stringList);
*/
/*
AME_STRIPING
  procedure newAttributeUsage(attributeIdIn in integer,
                              applicationIdIn in integer,
                              staticUsageIn in varchar2,
                              queryStringIn in varchar2 default null,
                              newStartDateIn in date default null,
                              lineItemAttributeIn in varchar2,
                              isStripingAttributeIn in varchar2 default null,
                              finalizeIn in boolean default true);
*/
  procedure newAttributeUsage(attributeIdIn in integer,
                              applicationIdIn in integer,
                              staticUsageIn in varchar2,
                              updateParentObjectIn in boolean,
                              queryStringIn in varchar2 default null,
                              newStartDateIn in date default null,
                              finalizeIn in boolean default false,
                              parentVersionStartDateIn in date default null,
                              createdByIn in integer default null);
  procedure newMandatoryAttributes(attributeIdIn in integer,
                                   actionTypeIdIn in integer,
                                   createdByIn in integer default null);
  procedure remove(attributeIdIn in integer,
                   finalizeIn in boolean default false);
  procedure removeMandatoryAttributes(attributeIdIn in integer,
                                      actionTypeIdIn in integer,
                                      finalizeIn in boolean default true);
  procedure removeUsage(attributeIdIn in integer,
                        parentVersionStartDateIn in date,
                        childVersionStartDateIn in date,
                        applicationIdIn in integer,
                        allowAttributeUsageDeleteIn in boolean default false,
                        finalizeIn in boolean default false,
                        deleteConditionsIn in boolean default false,
                        itemClassIdIn in integer);
/*
AME_STRIPING
  procedure setStripingAttributesToNull(applicationIdIn in integer,
                                        oldStripedAttributesIn in ame_util.idList default ame_util.emptyIdList,
                                        lastStripingAttributeIn in boolean default false);
*/
  /*
    Call updateUseCount in an object-layer routine after the routine does something
    that might change an attribute's ame_attribute_usages.use_count value, which is
    the number of rules that use the attribute, either in a condition or in an
    action.  (In the latter case, the handler for the action's approval type may
    require the attribute.)
  */
  procedure updateUseCount(attributeIdIn in integer,
                           applicationIdIn in integer,
                           finalizeIn in boolean default true);
  procedure updateUseCount2(ruleIdIn in integer,
                            applicationIdIn in integer);
end ame_attribute_pkg;

 

/
