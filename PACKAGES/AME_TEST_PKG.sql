--------------------------------------------------------
--  DDL for Package AME_TEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_TEST_PKG" AUTHID CURRENT_USER as
/* $Header: ameotest.pkh 120.0 2005/07/26 06:05:42 mbocutt noship $ */
  function getTestTransactionId return varchar2;
  function isTestItemIdDuplicate(applicationIdIn in integer,
                                 transactionIdIn in varchar2,
                                 itemClassIdIN in integer,
                                 itemIdIn in varchar2) return boolean;
  procedure deleteTestItems(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            itemClassIdIn in integer,
                            deleteIn in ame_util.stringList);
  procedure getAllAttributeValues(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  itemIdIn in varchar2 default null,
                                  attributeIdsOut out nocopy ame_util.idList,
                                  attributeNamesOut out nocopy ame_util.stringList,
                                  attributeTypesOut out nocopy ame_util.stringList,
                                  isMandatoryOut out nocopy ame_util.stringList,
                                  attributeValues1Out out nocopy ame_util.attributeValueList,
                                  attributeValues2Out out nocopy ame_util.attributeValueList,
                                  attributeValues3Out out nocopy ame_util.attributeValueList);
  procedure getAllAttributeValues2(applicationIdIn in integer,
                                   transactionIdIn in varchar2,
                                   itemClassIdIn in integer,
                                   itemIdIn in varchar2 default null,
                                   attributeIdsOut out nocopy ame_util.idList,
                                   attributeNamesOut out nocopy ame_util.stringList,
                                   attributeTypesOut out nocopy ame_util.stringList,
                                   isMandatoryOut out nocopy ame_util.stringList,
                                   attributeValues1Out out nocopy ame_util.attributeValueList,
                                   attributeValues2Out out nocopy ame_util.attributeValueList,
                                   attributeValues3Out out nocopy ame_util.attributeValueList);
	procedure getApplicableRules(applicationIdIn in integer,
                               transactionIdIn in varchar2,
                               ruleListVersionIn in integer,
                               testOrRealTransTypeIn in varchar2,
                               ruleItemClassIdsOut out nocopy ame_util.idList,
                               itemClassIdsOut out nocopy ame_util.idList,
                               itemIdsOut out nocopy ame_util.stringList,
                               ruleTypesOut out nocopy ame_util.idList,
                               ruleDescriptionsOut out nocopy ame_util.stringList,
                               ruleIdsOut out nocopy ame_util.idList);
  procedure getApproverAttributes(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  itemClassIdIn in integer,
                                  itemIdIn in varchar2,
                                  attributeIdsOut out nocopy ame_util.IdList,
                                  attributeNamesOut out nocopy ame_util.stringList,
                                  approverTypeIdsOut out nocopy ame_util.idList);
  procedure getApproverList(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            testOrRealTransTypeIn in varchar2,
                            approverListStageIn in integer,
                            approverListOut out nocopy ame_util.approversTable2,
			    productionIndexesOut out nocopy ame_util.idList,
                            variableNamesOut out nocopy ame_util.stringList,
                            variableValuesOut out nocopy ame_util.stringList,
                            doRepeatSubstitutionsOut out nocopy varchar2);
  procedure getItemAttributeValues(applicationIdIn in integer,
                                   transactionIdIn in varchar2,
                                   itemClassIdIn in integer,
                                   itemIdIn in varchar2,
                                   testOrRealTransTypeIn in varchar2,
                                   attributeNamesOut out nocopy ame_util.stringList,
                                   attributeTypesOut out nocopy ame_util.stringList,
                                   attributeValuesOut1 out nocopy ame_util.attributeValueList,
                                   attributeValuesOut2 out nocopy ame_util.attributeValueList,
                                   attributeValuesOut3 out nocopy ame_util.attributeValueList);
  procedure getItemIds(applicationIdIn in integer,
                       transactionIdIn in varchar2,
                       itemClassIdIn in integer,
                       itemIdsOut out nocopy ame_util.stringList);
  procedure getTransactionProductions(applicationIdIn in integer,
                                      transactionIdIn in varchar2,
                                      testOrRealTransTypeIn in varchar2,
                                      variableNamesOut out nocopy ame_util.stringList,
                                      variableValuesOut out nocopy ame_util.stringList);
  procedure initializeTestTrans(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                itemClassIdIn in integer default null,
                                isHeaderItemClassIn in boolean default true,
                                itemIdIn in varchar2 default null);
  procedure setAllAttributeValues(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  itemClassIdIn in integer,
                                  attributeIdsIn in ame_util.idList,
                                  itemIdIn in varchar2 default null,
                                  attributeValues1In in ame_util.attributeValueList,
                                  attributeValues2In in ame_util.attributeValueList,
                                  attributeValues3In in ame_util.attributeValueList);
  procedure setAttributeValues(applicationIdIn in integer,
                               transactionIdIn in varchar2,
                               itemClassIdIn in integer,
                               itemIdIn in varchar2,
                               attributeIdIn in integer,
                               attributeValue1In in varchar2,
                               attributeValue2In in varchar2 default null,
                               attributeValue3In in varchar2 default null);
end ame_test_pkg;

 

/
