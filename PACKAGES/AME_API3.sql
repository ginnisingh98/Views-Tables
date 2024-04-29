--------------------------------------------------------
--  DDL for Package AME_API3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_API3" AUTHID CURRENT_USER as
/* $Header: ameeapi3.pkh 120.5 2006/10/12 11:58:50 avarri noship $ */
/*#
 * This API package contains ancillary routines.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Ancillary Parallel Approvers Process
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getruledescription >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the description of the rule for a rule primary key.
 *
 * Rule descriptions are atmost 100 bytes long.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the rule description.
 *
 * <p><b>Post Failure</b><br>
 * The API will return null.
 *
 * @param ruleidin Rule id.
 * @return The API will return the rule description for the input rule id.
 * @rep:displayname Get Rule Description
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  function getRuleDescription(ruleIdIn in varchar2) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< clearInsertion >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API will clear the approver previously inserted by calls to
 * ame_api.insertApprover, ame_api.setFirstAuthorityApprover.
 * It will also clear the approvers inserted as a result of forwarding.
 * This will NOT clear the approval statuses and the approver deletions.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The approver should exist in the transaction's approver list.
 *
 * <p><b>Post Success</b><br>
 * The API will clear the insertion of the approver in the transaction's
 * approver list.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approverIn This is the approverRecord defined by ame_util.approverRecord2
 * that identifies the approver.
 * @rep:displayname Clear Insertion
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearInsertion(applicationIdIn in number,
                           transactionTypeIn in varchar2,
                           transactionIdIn in varchar2,
                           approverIn in ame_util.approverRecord2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< clearInsertions >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API clears all the approvers previously inserted for a
 * given transaction. This is same as the clearInsertion API but in this case it
 * clears all the insertions in the given transacton.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will clear all the previously inserted approvers in the given
 * transaction's approver list.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @rep:displayname Clear Insertions
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearInsertions(applicationIdIn in integer,
                            transactionTypeIn in varchar2,
                            transactionIdIn in varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< clearSuppression >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API clears a suppression of an approver previously requested via the
 * suppressApprover or suppressApprovers API.
 * Typical use: Reverse a delete approver instruction
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The approver must have been previously suppressed using the
 * suppressApprover or suppressApprovers API.
 *
 * <p><b>Post Success</b><br>
 * The API will clear the suppression of the given approver.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approverIn This is the approverRecord defined by
 * ame_util.approverRecord2 that identifies the suppressed approver
 * @rep:displayname Clear Suppression
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearSuppression(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approverIn in ame_util.approverRecord2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< clearSuppressions >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API clears all suppressions previously requested using
 * suppressApprover API or suppressApprovers API for a given transaction. This
 * is same as the clearSuppression API but in this case it clears all the
 * suppressions of a given transaction.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will clear all the suppressions for the given transaction.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @rep:displayname Clear Suppressions
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearSuppressions(applicationIdIn in integer,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getallapprovalgroups >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns all the current AME approval groups.
 *
 * The approval group id and the names of all the active approval groups is
 * returned by in ascending order of their names.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The group Id and the group names will be returned.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param groupidsout Approval group ids
 * @param groupnamesout Approval group names corresponding to the approval
 * group ids
 * @rep:displayname Get All Approvalgroups
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllApprovalGroups(groupIdsOut out nocopy ame_util.idList,
                                 groupNamesOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getapplicablerules1 >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the primary key information of the rules that are
 * applicable for a transaction.
 *
 * See also ame_api3.getApplicableRules2 and getApplicableRules3.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The Rule Ids will be returned.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param ruleidsout Rule ids.
 * @rep:displayname Get Applicable Rules 1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApplicableRules1(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2,
                                ruleIdsOut out nocopy ame_util.idList);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getapplicablerules2 >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the descriptions of the rules that are applicable for a
 * transaction.
 *
 * Use this API when you only need the rule descriptions. See also
 * ame_api3.getApplicableRules1 and ame_api3.getApplicableRules3.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the rule description.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param ruledescriptionsout Rule descriptions.
 * @rep:displayname Get Applicable Rules 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApplicableRules2(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2,
                                ruleDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getapplicablerules3 >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the primary key information and description of all the
 * rules that are applicable for a transaction.
 *
 * This procedure is useful to construct a displayable list of descriptiosn of
 * applicable rules, where each rule description hyperlinks to a more detailed
 * description of the rule (generated by one of the ame_api3.getRuleDetails[n]
 * procedures). See also ame_api3.getApplicableRules1,
 * ame_api3.getApplicableRules1, and the three ame_api3.getRuleDetails[n]
 * procedures.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The rule ids and rule description will be returned.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param ruleidsout Rule ids.
 * @param ruledescriptionsout Rule descriptions corresponding to rule ids.
 * @rep:displayname Get Applicable Rules 3
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApplicableRules3(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2,
                                ruleIdsOut out nocopy ame_util.idList,
                                ruleDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getapprovalgroupid >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the approval group primary key information for a given
 * approval group name.
 *
 * The approval group ID is returned for a given approval group name.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The Approval Group Id will be returned.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param groupnamein This specifies the Approval group name.
 * @param groupidout This specifies the unique identifier of Approval group.
 * @rep:displayname Get Approval Group
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApprovalGroupId(groupNameIn ame_util.stringType,
                               groupIdOut out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getattributevalue >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the value of an attribute for a given transaction.
 *
 * This API outputs in attributeValue1Out, attributeValue2Out, and
 * attributeValue3Out the values of the attribute with the name attributeNameIn
 * for the item with ID itemIdIn, for the input transaction. An attribute is
 * always associated with an item class, and attribute names are unique across
 * item classes, so it is not necessary to input the item class. If the
 * attribute pertains to the header item class, itemIdIn should have the same
 * value as transactionIdIn. For all attribute types other than currency
 * attributes, attributeValue1Out contains the attribute's value, and
 * attributeValue2Out and attributeValue3Out are null. For currency attributes,
 * attributeValue1Out is the amount, attributeValue2Out is the General Ledger
 * currency code, and attributeValue3Out is the General Ledger conversion type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the value of the attribute.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param attributenamein Attribute name.
 * @param itemidin Item id corresponding to the item class, to that the
 * attribute belongs.
 * @param attributevalue1out Attribute value.
 * @param attributevalue2out For non-currency attribute type, it will contain
 * null and for currency type it will contain General Ledger currency code.
 * @param attributevalue3out For non-currency attribute type, it will contain
 * null and for currency type it will contain General Ledger conversion type.
 * @rep:displayname Get Attribute Value
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAttributeValue( applicationIdIn in number,
                               transactionTypeIn in varchar2,
                               transactionIdIn in varchar2,
                               attributeNameIn in varchar2,
                               itemIdIn in varchar2,
                               attributeValue1Out out nocopy varchar2,
                               attributeValue2Out out nocopy varchar2,
                               attributeValue3Out out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< getAvailableInsertions >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Returns a list of ame_util.insertionRecord2 records representing
 * the dynamic approver insertions. Returns the available insertions that
 * are of type specified at the given position in the transaction's
 * current approver list.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the list of available insertions with the out parameter
 * availableInsertionsOut.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param positionIn Absolute position in the current approver list.
 * @param orderTypeIn Order type record defined by ame_util.orderRecord
 * identifies the order type.
 * @param availableInsertionsOut List of available insertions.
 * @rep:displayname Get Available Insertions
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAvailableInsertions(applicationIdIn in number,
                                   transactionTypeIn in varchar2,
                                   transactionIdIn in varchar2,
                                   positionIn in number,
                                   orderTypeIn in varchar2 default null,
                                   availableInsertionsOut out nocopy ame_util.insertionsTable2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getconditiondetails >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the details of an AME condition.
 *
 * The condition details include the attribute details (ie. attribute name,
 * type and description) on which the condition is based.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the condition details along with the attribute on which
 * the condition is based i.e. attributeNameOut, attributeTypeOut,
 * attributeDescriptionOut, lowerLimitOut upperLimitOut, includeLowerLimitOut,
 * includeUpperLimitOut, currencyCodeOut and allowedValuesOut.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param conditionidin Condition id.
 * @param attributenameout Attribute name, on which the condition is based.
 * @param attributetypeout Attribute type, for example, number, currency,
 * string and so on.
 * @param attributedescriptionout Attribute description.
 * @param lowerlimitout Lower limit. For number and currency type it contains
 * the lower value. For boolean type it contains true or false, and for string
 * type, it contains null.
 * @param upperlimitout Upper Limit. For number and currency type it contains
 * the upper value. For boolean and string type it contains contains null.
 * @param includelowerlimitout For number and currency type it determines
 * whether the Lower Limit is included, otherwise it contains null.
 * @param includeupperlimitout For number and currency type it determines
 * whether the Upper Limit is included, otherwise it contains null.
 * @param currencycodeout For currency type, it contains the General Ledger
 * currency code, otherwise null.
 * @param allowedvaluesout For string type conditions it contains the list of
 * values, otherwise null.
 * @rep:displayname Get Condition Details
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getConditionDetails(conditionIdIn in integer,
                                attributeNameOut out nocopy varchar2,
                                attributeTypeOut out nocopy varchar2,
                                attributeDescriptionOut out nocopy varchar2,
                                lowerLimitOut out nocopy varchar2,
                                upperLimitOut out nocopy varchar2,
                                includeLowerLimitOut out nocopy varchar2,
                                includeUpperLimitOut out nocopy varchar2,
                                currencyCodeOut out nocopy varchar2,
                                allowedValuesOut out nocopy ame_util.longestStringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getgroupmembers1 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the approval group members display name for a given
 * transaction.
 *
 * If applicationIdIn, transactionIdIn, and transactionTypeIn are null, the
 * GROUP ID must be for a static approval group. If the group is dynamic, these
 * three inputs must identify the transaction for which AME should calculate
 * the group's members.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the approval group members' display name.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param groupidin This specifies the unique identifier of Approval group.
 * @param memberdisplaynamesout Group members' display name.
 * @rep:displayname Get Group Members 1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getGroupMembers1(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             groupIdIn in number,
                             memberDisplayNamesOut out nocopy ame_util.longStringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getgroupmembers2 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the approval group members name and display name for a
 * given transaction.
 *
 * This API has the same functionality as getGroupMembers1, but it also outputs
 * the group members' wf_roles.name values. See also ame_api3.getGroupMembers1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the approval group members' role name and display name.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param groupidin This specifies the unique identifier of Approval group.
 * @param membernamesout Group members' name.
 * @param memberdisplaynamesout Group members' display name.
 * @rep:displayname Get Group Members 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getGroupMembers2(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             groupIdIn in number,
                             memberNamesOut out nocopy ame_util.longStringList,
                             memberDisplayNamesOut out nocopy ame_util.longStringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getgroupmembers3 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the approval group members name, display name and order
 * number for a given transaction.
 *
 * This API has the same functionality as getGroupMembers2, but it also outputs
 * the members' order numbers. See also ame_api3.getGroupMembers2.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the approval group members' role name, display name and
 * the order number.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param groupidin This specifies the unique identifier of Approval group.
 * @param membernamesout Group members' name.
 * @param memberordernumbersout Group members' order number.
 * @param memberdisplaynamesout Group members' display name.
 * @rep:displayname Get Group Members 3
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getGroupMembers3(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             groupIdIn in number,
                             memberNamesOut out nocopy ame_util.longStringList,
                             memberOrderNumbersOut out nocopy ame_util.idList,
                             memberDisplayNamesOut out nocopy ame_util.longStringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getgroupmembers4 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the approval group members name, display name, order
 * number, orig system details for a given transaction.
 *
 * This API has the same functionality as getGroupMembers3, but it also outputs
 * the members' wf_roles.orig_system and wf_roles.orig_system_id values. See
 * also ame_api3.getGroupMembers3.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return approval group members' role name, display name, order
 * number, orig system and orig system id.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param groupidin This specifies the unique identifier of Approval group.
 * @param membernamesout Group members' name.
 * @param memberordernumbersout Group members' order number.
 * @param memberdisplaynamesout Group members' display name.
 * @param memberorigsystemidsout Group members' orig system id.
 * @param memberorigsystemsout Group members' orig system, for example,
 * FND_USR, PER, POS and so on.
 * @rep:displayname Get Group Members 4
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getGroupMembers4(applicationIdIn in number default null,
                             transactionTypeIn in varchar2 default null,
                             transactionIdIn in varchar2 default null,
                             groupIdIn in number,
                             memberNamesOut out nocopy ame_util.longStringList,
                             memberOrderNumbersOut out nocopy ame_util.idList,
                             memberDisplayNamesOut out nocopy ame_util.longStringList,
                             memberOrigSystemIdsOut out nocopy ame_util.idList,
                             memberOrigSystemsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< getitemclasses >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API gets item class information for a given transaction type.
 *
 * This outputs the IDs and names of the item classes defined for a transaction
 * type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return all the item class ids and the corresponding item class
 * names for a transaction type.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param itemclassidsout Item class ids.
 * @param itemclassnamesout Item class names corresponding to ids.
 * @rep:displayname Get Item Classes
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getItemClasses( applicationIdIn in number,
                            transactionTypeIn in varchar2,
                            itemClassIdsOut out nocopy ame_util.idList,
                            itemClassNamesOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< getitemclassid >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API gets item class primary key information for a given Item class
 * name.
 *
 * The item class id for the given item class name is returned.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the item class id for a given item class name.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param itemclassnamein Item class name.
 * @param itemclassidout Item class id.
 * @rep:displayname Get Item Class Id
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getItemClassId( itemClassNameIn in varchar2,
                            itemClassIdOut out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getitemclassname >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API gets an Item class name information for a given item class primary
 * key.
 *
 * This API outputs in itemClassNameOut, the name of the item class with the ID
 * itemClassIdIn.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the name of the item class for a given item class id.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param itemclassidin Item class id.
 * @param itemclassnameout Item class name.
 * @rep:displayname Get Item Class Name
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getItemClassName( itemClassIdIn in number,
                              itemClassNameOut out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getoldapprovers >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the approver list that AME calculated when it last
 * generated an approver list for the input transaction.
 *
 * This approver list may not be the transaction's current list. That is,
 * simultaneous calls to getAllApprovers1 and getOldApprovers could return
 * different approver lists (and the list returned by getOldApprovers would
 * then be outdated). This API is a deprecated routine available only for the
 * sake of backward compatibility.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the list of old approvers.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters and must not be the character representation of a
 * negative integer.
 * @param oldapproversout This is an ame_util.approverTable2 that will keep the
 * generated old approvers list.
 * @rep:displayname Get Old Approvers
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getOldApprovers( applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             oldApproversOut out nocopy ame_util.approversTable2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getruledetails1 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns various rule details.
 *
 * This API returns the following details about the rule with ID ruleIdIn: rule
 * type, rule description, condition Ids for the conditions used in this rule,
 * action type names and descriptions, action descriptions corresponding to
 * actions that are used in this rule. Use getRuleDetails1 in connection with
 * one of the getApplicableRules procedures. See also the getApplicableRules[n]
 * procedures.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the following rule details for a given rule id: rule
 * type, rule description, conditions (used in the rule), action type name,
 * action type descriptions and action descriptions.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param ruleidin Rule id.
 * @param ruletypeout Rule type, for example, list creation, list creation and
 * exception, list modification and so on.
 * @param ruledescriptionout Rule description.
 * @param conditionidsout Condition ids for the conditions that are used in the
 * input rule.
 * @param actiontypenamesout Action type names corresponding to the actions
 * that are used in the input rule.
 * @param actiontypedescriptionsout Action type descriptions corresponding to
 * the actions that are used in the input rule.
 * @param actiondescriptionsout Action descriptions corresponding to the
 * actions that are used in the input rule.
 * @rep:displayname Get Rule Details 1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getRuleDetails1( ruleIdIn in number,
                             ruleTypeOut out nocopy varchar2,
                             ruleDescriptionOut out nocopy varchar2,
                             conditionIdsOut out nocopy ame_util.idList,
                             actionTypeNamesOut out nocopy ame_util.stringList,
                             actionTypeDescriptionsOut out nocopy ame_util.stringList,
                             actionDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getruledetails2 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API gets the various rule details such as conditions applying to the
 * rule.
 *
 * This API has the same functionality as getRuleDetails1, but it outputs
 * condition descriptions rather than condition IDs. See also
 * ame_api3.getRuleDetails1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the following details for a given rule: rule type, rule
 * description, condition descriptions, action type names, action type
 * descriptions and action descriptions.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param ruleidin Rule id.
 * @param ruletypeout Rule type, for example, list creation, list creation and
 * exception, list modification and so on.
 * @param ruledescriptionout Rule description.
 * @param conditiondescriptionsout Condition descriptions for the conditions
 * that are used in the input rule.
 * @param actiontypenamesout Action type names corresponding to the actions
 * that are used in the input rule.
 * @param actiontypedescriptionsout Action type descriptions corresponding to
 * the actions that are used in the input rule.
 * @param actiondescriptionsout Action descriptions corresponding to the
 * actions that are used in the input rule.
 * @rep:displayname Get Rule Details 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getRuleDetails2( ruleIdIn in number,
                             ruleTypeOut out nocopy varchar2,
                             ruleDescriptionOut out nocopy varchar2,
                             conditionDescriptionsOut out nocopy ame_util.longestStringList,
                             actionTypeNamesOut out nocopy ame_util.stringList,
                             actionTypeDescriptionsOut out nocopy ame_util.stringList,
                             actionDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getruledetails3 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API gets the various rule details and provides further description of
 * the conditions applying to the rule.
 *
 * This API has the same functionality as getRuleDetails1, but it outputs
 * condition ID and descriptions, and indicates whether each condition has a
 * list of allowed values. See also ame_api3.getRuleDetails2.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the rule details, conditions are being used by that rule
 * and action details for a given rule id into the various OUT parameters.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param ruleidin Rule id.
 * @param ruletypeout Rule type, for example, list creation, list creation and
 * exception, list modification and so on.
 * @param ruledescriptionout Rule description.
 * @param conditionidsout Condition ids for the conditions that are used in the
 * input rule.
 * @param conditiondescriptionsout Condition descriptions corresponding to the
 * condition ids that are used in the input rule.
 * @param conditionhaslovsout This indicates whether the corresponding
 * condition has a list of allowed values.
 * @param actiontypenamesout Action type names corresponding to the actions
 * that are used in the input rule.
 * @param actiontypedescriptionsout Action type descriptions corresponding to
 * the actions that are used in the input rule.
 * @param actiondescriptionsout Action descriptions corresponding to the
 * actions that are used in the input rule.
 * @rep:displayname Get Rule Details 3
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getRuleDetails3( ruleIdIn in number,
                             ruleTypeOut out nocopy varchar2,
                             ruleDescriptionOut out nocopy varchar2,
                             conditionIdsOut out nocopy ame_util.idList,
                             conditionDescriptionsOut out nocopy ame_util.longestStringList,
                             conditionHasLOVsOut out nocopy ame_util.charList,
                             actionTypeNamesOut out nocopy ame_util.stringList,
                             actionTypeDescriptionsOut out nocopy ame_util.stringList,
                             actionDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insertapprover >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Dynamically inserts an approver with a given insertion-order
 * relation at a given position in the transaction's current approver
 * list.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * 1. The approval_status field of approverIn is null.
 * 2. The combination of values in orderIn, the api_insertion field
 *    of approverIn, and the authority field of approverIn match a
 *    record returned by getAvailableInsertions.
 *
 *
 * <p><b>Post Success</b><br>
 * The approver will be inserted in the given transaction's approver list.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approverIn This is the approverRecord defined by ame_util.approverRecord2
 * that identifies the approver.
 * @param positionIn  The position in approver list where the approver insertion will be done.
 * @param insertionIn Insertion record.
 * @rep:displayname Insert Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure insertApprover( applicationIdIn in number,
                            transactionTypeIn in varchar2,
                            transactionIdIn in varchar2,
                            approverIn in ame_util.approverRecord2,
                            positionIn in number,
                            insertionIn in ame_util.insertionRecord2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< parseapproversource >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This api parses the source field of a ame_util.approverRecord of
 * an approver and returns the description of the source
 * and the list of rule ids that generated this approver.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * This api returns description of the source and the list of rule ids
 * which have generated this approver, if any.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param approversourcein This is the value of the source field of
 * ame_util.approverRecord of an approver.
 * @param sourcedescriptionout Description of the source.
 * @param ruleidlistout This is the list of rule IDs that generated this approver.
 * @rep:displayname Parse Approver Source
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure parseApproverSource(approverSourceIn     in         varchar2,
                                sourceDescriptionOut out nocopy varchar2,
                                ruleIdListOut        out nocopy ame_util.idList);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< suppressApprover >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Dynamically suppresses an approver in the transaction's current approver
 * list.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The approver identified by approverIn should already be in the
 * transaction's approver list.
 *
 *
 * <p><b>Post Success</b><br>
 * The approver will be suppressed in the given transaction's approver list.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approverIn This is the approverRecord defined by ame_util.approverRecord2
 * that identifies the approver.
 * @rep:displayname Suppress Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure suppressApprover(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approverIn in ame_util.approverRecord2);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< suppressApprovers >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Dynamically suppresses multiple approvers in the transaction's current approver
 * list.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The approvers identified by approverIn should already be in the
 * transaction's approver list.
 *
 *
 * <p><b>Post Success</b><br>
 * The specified approvers will be suppressed in the transaction's approver list.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approversIn Approvers list defined by ame_util.approversTable2
 * identifies the list of approvers.
 * @rep:displayname Suppress Approvers
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure suppressApprovers(applicationIdIn in integer,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2,
                              approversIn in ame_util.approversTable2);
end ame_api3;

 

/
