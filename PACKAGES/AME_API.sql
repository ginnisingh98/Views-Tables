--------------------------------------------------------
--  DDL for Package AME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_API" AUTHID CURRENT_USER as
/* $Header: ameeapin.pkh 120.3.12000000.1 2007/01/17 23:49:29 appldev noship $ */
/*#
 * This package contains APIs that a typical workflow uses to process an
 * approval.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Approval Process
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getruledescription >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the description of a given rule.
 *
 * Rule descriptions are at most 100 bytes long. Note : This API is an
 * alternative API for ame_api3.getRuleDescription.
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
 * @param ruleidin Rule id
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
-- |-----------------------------< validateapprover >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates an approver.
 *
 * This API checks if the specified approver is valid by looking at WF Roles.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return true if the approver represented by approverIn has a
 * current wf_roles entry, otherwise will return false.
 *
 * <p><b>Post Failure</b><br>
 * This API returns false.
 *
 * @param approverin This is an ame_util.approverRecord that represents an
 * approver.
 * @return This API will return true if the approver represented by approverIn has a current wf_roles entry, otherwise will return false.
 * @rep:displayname Validate Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  function validateApprover(approverIn in ame_util.approverRecord) return boolean;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< clearallapprovals >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API clears the approval process of a transaction.
 *
 * This restores the default approver list (removing
 * approver insertions, suppressions, forwardings, etc.). Use this
 * API to restart a transaction's approval process from scratch,
 * undoing any operations that have already modified the approval
 * process.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The approval process of the given transaction will be cleared.
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
 * @rep:displayname Clear All Approvals
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearAllApprovals(applicationIdIn in integer,
                              transactionIdIn in varchar2,
                              transactionTypeIn in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< cleardeletion >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API clears a deletion of an approver, genereated by a rule,
 * previously requested via the deleteApprover or deleteApprovers API.
 * Typical use: Reverse a delete approver instruction
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The approver must have been deleted via the deleteApprover or deleteApprovers API.
 *
 * <p><b>Post Success</b><br>
 * The deletion of the approver will be cleared.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param approverIn This is the approver record defined by
 * ame_util.approverRecord which identifies the Approver.
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @rep:displayname Clear Deletion
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearDeletion(approverIn in ame_util.approverRecord,
                          applicationIdIn in integer,
                          transactionIdIn in varchar2,
                          transactionTypeIn in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< cleardeletions >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API clears all the deletions requested previously for a
 * given transaction. This is same as the clearDeletion API but in this case it
 * clears all the deletions for the specified transaction.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * All the previously requested deletions for the given transaction will be cleared.
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
 * @rep:displayname Clear Deletions
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearDeletions(applicationIdIn in integer,
                           transactionIdIn in varchar2,
                           transactionTypeIn in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< clearinsertion >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API will clear the approver previously inserted using
 * insertApprover API from the transaction's approver list.Use this API
 * to remove an inserted approver from a transaction's approver list.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The approver must have been previously inserted using insertApprover.
 *
 * <p><b>Post Success</b><br>
 * The insertion of the approver will be cleared.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param approverIn This is the approverRecord defined by ame_util.approverRecord
 * which gives information regarding the Approver.
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @rep:displayname Clear Insertion
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearInsertion(approverIn in ame_util.approverRecord,
                           applicationIdIn in integer,
                           transactionIdIn in varchar2,
                           transactionTypeIn in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< clearinsertions >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API removes all the inserted approvers from the specified transaction.
 * Use this API to remove all the insertions from a transaction at once. This
 * API also clears the forwardings.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * All the inserted approvers will be removed from the specified transaction.
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
 * @rep:displayname Clear Insertions
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearInsertions(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIn in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< deleteapprover >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API suppresses the approver
 * represented by approverIn in the input transaction's approver
 * list.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * This procedure should be called only after getNextApprover or
 * getAllApprovers has been called, for a given transaction.
 *
 * <p><b>Post Success</b><br>
 * The specified approver will be suppressed in the given transaction's approver list.
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
 * @param approverIn This is the approverRecord defined by ame_util.approverRecord
 * which gives information regarding the Approver.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @rep:displayname Delete Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure deleteApprover(applicationIdIn in integer,
                           transactionIdIn in varchar2,
                           approverIn in ame_util.approverRecord,
                           transactionTypeIn in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< deleteapprovers >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API suppresses the approvers
 * represented by approversIn in the input transaction's approver
 * list.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * This procedure should be called only after getNextApprover or
 * getAllApprovers has been called, for a given transaction.
 *
 * <p><b>Post Success</b><br>
 * The specified approvers will be suppressed in the given transaction's approval list.
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
 * @param approversIn This is the approversTable defined by ame_util.approversTable
 * which gives information regarding the Approvers.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @rep:displayname Delete Approvers
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure deleteApprovers(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            approversIn in ame_util.approversTable,
                            transactionTypeIn in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getadminapprover >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the administrator for the input transaction type.
 *
 * This adminstrator user's information can be specified in AME using the admin
 * tab. This API can be used to get the admin approver in case of any errors
 * and so on. Note : This is an alternative API for ame_api3.getAdminApprover.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the administrator user's information in the out
 * parameter adminApproverOut.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param adminapproverout Admin approver in ame_util.approverrecord format.
 * @rep:displayname Get Admin Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAdminApprover(applicationIdIn in integer default null,
                             transactionTypeIn in varchar2 default null,
                             adminApproverOut out nocopy ame_util.approverRecord);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getallapprovers >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns all the approvers for a transaction.
 *
 * This API outputs the input transaction's current approver list, including
 * rule-generated, inserted, suppressed, and repeated approvers. The rows in
 * approversOut are indexed by consecutive ascending integers starting at one.
 * The approval_status values in approversOut reflect each approver's most
 * recent response to any request for approval they have received, assuming the
 * originating application has passed such responses to AME via
 * updateApprovalStatus or updateApprovalStatus2. In AME 11.5.9, the AME engine
 * excluded from the approver list any approvers deleted by calls to
 * ame_api.deleteApprover(s), or suppressed to account for the value of the
 * repeatedApprovers configuration variable. In AME 11.5.10, this behavior has
 * changed. The approver list in approversOut now includes deleted and repeated
 * approvers, but assigns them one of the approval_status values
 * ame_util.suppressedStatus and ame_util.repeatedStatus. Your code should
 * treat these statuses as logically equivalent to ame_util.approvedStatus. The
 * ame_api.getNextApprover will skip approvers with either status when it
 * iterates through the approver list to find the first approver that has not
 * yet approved. Note : This is an alternative API for
 * ame_api2.getAllApprovers7 See also the ame_api2.getAllApprovers[n]
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
 * The API will return all the approvers in the out parameter approversOut.
 *
 * <p><b>Post Failure</b><br>
 * The API will not return any approver for the particular transaction and will
 * raise an error.
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
 * @param approversout This is the ame_util.approversTable which represents the
 * list of approvers.
 * @rep:displayname Get All Approvers
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllApprovers(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIn in varchar2 default null,
                            approversOut out nocopy ame_util.approversTable);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getandrecordallapprovers >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns all the approvers for a transaction.
 * This API is similar to ame_api.getAllApprovers. The only
 * difference is that this call will also store the approver list in the
 * AME transaction tables.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return all the approvers in the out parameter approversOut.
 *
 * <p><b>Post Failure</b><br>
 * The API will not return any approver for the particular transaction and will
 * raise an error.
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
 * @param approversout This is the ame_util.approversTable which represents the
 * list of approvers.
 * @rep:displayname Get And Record All Approvers
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAndRecordAllApprovers(applicationIdIn in integer,
                                     transactionIdIn in varchar2,
                                     transactionTypeIn in varchar2 default null,
                                     approversOut out nocopy ame_util.approversTable);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getapplicablerules1 >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the rules that apply to primary key information for a
 * transaction.
 *
 * Use this API when you only need the rule IDs. Note : This is an alternative
 * API for ame_api3.getapplicablerules1. See also ame_api.getApplicableRules2
 * and getApplicableRules3.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the ids of the applicable rules in the out parameter
 * ruleIdsOut.
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
 * @param ruleidsout Applicable rules for the input transaction.
 * @rep:displayname Get Applicable Rules1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApplicableRules1(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2 default null,
                                ruleIdsOut out nocopy ame_util.idList);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getapplicablerules2 >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the description of the rules that are applicable for a
 * transaction.
 *
 * Use this API when you only need the rule descriptions. Note : This is an
 * alternative API for ame_api3.getApplicableRules2. See also
 * ame_api.getApplicableRules1 and ame_api.getApplicableRules3.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the descriptions of all the applicable rules for a
 * transaction in the out parameter ruleDescriptionsOut.
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
 * @param ruledescriptionsout Rule descriptions for the rules that are
 * applicable for the input transaction.
 * @rep:displayname Get Applicable Rules2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApplicableRules2(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2 default null,
                                ruleDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getapplicablerules3 >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the rules that apply to primary keys, and returns their
 * corresponding descriptions for a transaction.
 *
 * This procedure is useful to construct a displayable list of descriptions of
 * applicable rules, where each rule description hyperlinks to a more detailed
 * description of the rule (generated by one of the ame_api.getRuleDetails[n]
 * procedures). Note : This is an alternative API for
 * ame_api3.getApplicableRules3 See also ame_api.getApplicableRules1,
 * ame_api.getApplicableRules1, and the three ame_api.getRuleDetails[n]
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
 * The API will return the applicable rules' ids and descriptions for a
 * transaction in the out parameters ruleIdsOut and ruleDescriptionsOut.
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
 * @param ruleidsout Rule ids for the rules that are applicable for the input
 * transaction.
 * @param ruledescriptionsout Rule descriptions for the rules that are
 * applicable for the input transaction.
 * @rep:displayname Get Applicable Rules3
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApplicableRules3(applicationIdIn in integer,
                                transactionIdIn in varchar2,
                                transactionTypeIn in varchar2 default null,
                                ruleIdsOut out nocopy ame_util.idList,
                                ruleDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< getapproversandrules1 >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) along with rule primary keys requiring each approver for a
 * transaction.
 *
 * Use this API when you need to display the approver list, along with the
 * rules requiring each approver. Note : This is an alternative API for
 * ame_api2.getAllApprovers4.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers along with rule ids requiring
 * each approvers in the out parameters approversOut and ruleIdsOut.
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
 * @param approversout This is the ame_util.approversTable which represents the
 * list of approvers.
 * @param ruleidsout Rule ids for the rules corresponding to each of the
 * approvers.
 * @rep:displayname Get Approvers And Rules1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApproversAndRules1(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  transactionTypeIn in varchar2 default null,
                                  approversOut out nocopy ame_util.approversTable,
                                  ruleIdsOut out nocopy ame_util.idList);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< getapproversandrules2 >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) along with rule descriptions requiring each approver for a
 * transaction.
 *
 * The getapproversandrules2 procedure has the same functionality as
 * ame_api.getapproversandrules1, but it returns rule descriptions rather than
 * rule IDs. Note : This is an alternative API for ame_api2.getAllApprovers5.
 * See also ame_api.getapproversandrules1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers (both rule-generated and inserted
 * approvers) along with rule descriptions requiring each approvers for a
 * transaction in the out parameters approversOut and ruleDescriptionsOut.
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
 * @param approversout This is the ame_util.approversTable which represents the
 * list of approvers.
 * @param ruledescriptionsout Rule descriptions for the rules corresponding to
 * each of the approvers.
 * @rep:displayname Get Approvers And Rules2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApproversAndRules2(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  transactionTypeIn in varchar2 default null,
                                  approversOut out nocopy ame_util.approversTable,
                                  ruleDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< getapproversandrules3 >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) along with rules (both description and primary key) requiring
 * each approver.
 *
 * The ame_api.getapproversandrules3 procedure has the same functionality as
 * getapproversandrules2, but it returns both rule IDs and rule descriptions.
 * Note : This API is an alternative API for ame_api2.getAllApprovers6. See
 * also ame_api.getapproversandrules1 and ame_api.getapproversandrules2.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers (both rule-generated and inserted
 * approvers) along with rule ids and descriptions requiring each approvers in
 * the out parameters approversOut, ruleIdsOut and ruleDescriptionsOut.
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
 * @param approversout This is the ame_util.approversTable which represents the
 * list of approvers.
 * @param ruleidsout Rule ids for the rules corresponding to each of the
 * approvers.
 * @param ruledescriptionsout Rule descriptions for the rules corresponding to
 * each of the approvers.
 * @rep:displayname Get Approvers And Rules3
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApproversAndRules3(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  transactionTypeIn in varchar2 default null,
                                  approversOut out nocopy ame_util.approversTable,
                                  ruleIdsOut out nocopy ame_util.idList,
                                  ruleDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< getAvailableInsertions >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns a list of ame_util.insertionRecord records representing
 * the dynamic approver insertions that are possible at the absolute
 * position positionIn in the transaction's current approver list.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return a list of available insertions in the out parameter
 * availableInsertionsOut.
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
 * @param positionIn This specifies the index in the Approval Order where the
 * available insertions are to be fetched.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param availableInsertionsOut This is the table defined by ame_util.insertionsTable
 * which represents the list of available insertions.
 * @rep:displayname Get Available Insertions
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAvailableInsertions(applicationIdIn in integer,
                                   transactionIdIn in varchar2,
                                   positionIn in integer,
                                   transactionTypeIn in varchar2 default null,
                                   availableInsertionsOut out nocopy ame_util.insertionsTable);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< getAvailableOrders >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Returns a list of ame_util.orderRecord records representing
 * the dynamic approver insertions that are possible at the absolute
 * position positionIn in the transaction's current approver list.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the list of available orders in the out parameter
 * availableOrdersOut.
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
 * @param positionIn absolute position in the current approver list.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param availableOrdersOut This is the table defined by ame_util.ordersTable
 * which represents the list of available orders.
 * @rep:displayname Get Available Orders
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAvailableOrders(applicationIdIn in integer,
                               transactionIdIn in varchar2,
                               positionIn in integer,
                               transactionTypeIn in varchar2 default null,
                               availableOrdersOut out nocopy ame_util.ordersTable);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getconditiondetails >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the details of an AME condition.
 *
 * This API is an alternative for ame_api3.getconditiondetails.
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
 * the condition is based, in out parameters attributeNameOut,
 * attributeTypeOut, attributeDescriptionOut, lowerLimitOut upperLimitOut,
 * includeLowerLimitOut, includeUpperLimitOut, currencyCodeOut and
 * allowedValuesOut.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param conditionidin Condition id
 * @param attributenameout Attribute name, on which condition is based.
 * @param attributetypeout Attribute type, for example, number, currency,
 * string.
 * @param attributedescriptionout Attribute description.
 * @param lowerlimitout Lower Limit. For number and currency type it contains
 * the lower value. For boolean type it contains true or false,and for string
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
                                /*
                                  includeLowerLimitOut and includeUpperLimitOut will be
                                  ame_util.booleanTrue, ame_util.booleanFalse, or null.
                                */
                                currencyCodeOut out nocopy varchar2,
                                allowedValuesOut out nocopy ame_util.longestStringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getGroupMembers >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns constituent member of a AME approver group.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the details of constituent members of the specified approver
 * group in the out parameters memberOrderNumbersOut,memberPersonIdsOut,memberUserIdsOut.
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
 * @param groupIdIn Group id of the AME approval group.
 * @param memberOrderNumbersOut list of order numbers of the members.
 * @param memberPersonIdsOut list of person_id of the members.
 * @param memberUserIdsOut list of user_id of the members.
 * @rep:displayname Get Group Members
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getGroupMembers(applicationIdIn in number,
                            transactionTypeIn in varchar2,
                            transactionIdIn in varchar2,
                            groupIdIn in number,
                            memberOrderNumbersOut out  nocopy ame_util.idList,
                            memberPersonIdsOut out  nocopy ame_util.idList,
                            memberUserIdsOut out  nocopy ame_util.idList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getnextapprover >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the next approver in the approver list from whom an
 * approval response is required.
 *
 * The returned approver should respond (approve/reject/forward etc) the input
 * transaction. Unlike the ame_api2.getNextApprovers[n] procedures,
 * ame_api.getNextApprover returns the same approver each time the procedure is
 * called for a transaction, until the approver responds the input transaction.
 * Note : This API is an alternative API for ame_api2.getNextApprovers4.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the next approver in the out parameter
 * nextApproverOut.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param nextapproverout This is an ame_util.approverRecord which identifies
 * the approver, requiring notification for
 * the current stage of the input transaction's approval process.
 * @rep:displayname Get Next Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getNextApprover(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIn in varchar2 default null,
                            nextApproverOut out nocopy ame_util.approverRecord);
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
 * This is an alternative API for ame_api3.getOldApprovers. Note : Do not use
 * this api for your approval process. This API is a deprecated routine
 * available only for the sake of backwards compatibility.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the list of approvers in the out parameter
 * oldApproversOut
 *
 * <p><b>Post Failure</b><br>
 * The API will not return any approver and will raise an error.
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
 * @param oldapproversout This is an ame_util.approverTable that will keep the
 * generated old approvers list.
 * @rep:displayname Get Old Approvers
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getOldApprovers(applicationIdIn in integer,
                            transactionIdIn in varchar2,
                            transactionTypeIn in varchar2 default null,
                            oldApproversOut out nocopy ame_util.approversTable);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getruledetails1 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API gets the various rule details including the primary key for the
 * conditions that apply.
 *
 * The following details of a rule are returned. rule type, rule description,
 * condition Ids for the conditions used in this rule, action type names and
 * descriptions, action descriptions corresponding to actions that are used in
 * this rule. Use getRuleDetails1 in connection with one of the
 * getApplicableRules procedures. See also the getApplicableRules[n]
 * procedures. Note : This API is an alternative API for
 * ame_api3.getRuleDetails1
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the rule details in the various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param ruleidin Rule id
 * @param ruletypeout Rule type, for example, list creation, list creation and
 * exception, list modification and so on.
 * @param ruledescriptionout Rule description.
 * @param conditionidsout These are condition ids for the conditions that are
 * used in the input rule.
 * @param approvaltypenameout These are action type names corresponding to the
 * actions that are used in the input rule.
 * @param approvaltypedescriptionout These are action type descriptions
 * corresponding to the actions that are used in the input rule.
 * @param approvaldescriptionout These are action descriptions corresponding to
 * the actions that are used in the input rule.
 * @rep:displayname Get Rule Details 1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getRuleDetails1(ruleIdIn in integer,
                            ruleTypeOut out nocopy varchar2,
                            ruleDescriptionOut out nocopy varchar2,
                            conditionIdsOut out nocopy ame_util.idList,
                            approvalTypeNameOut out nocopy varchar2,
                            approvalTypeDescriptionOut out nocopy varchar2,
                            approvalDescriptionOut out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getruledetails2 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API gets the rule details including a description of the conditions
 * that apply.
 *
 * This API has the same functionality as getRuleDetails1, but it returns
 * condition descriptions rather than condition IDs. Note : This API is an
 * alternative for ame_api3.getRuleDetails2. See also ame_api.getRuleDetails1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the rule details in the various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param ruleidin Rule id.
 * @param ruletypeout Rule type for example list creation, list creation and
 * exception, list modification and so on.
 * @param ruledescriptionout Rule description.
 * @param conditiondescriptionsout Condition descriptions for the conditions
 * that are used in the input rule.
 * @param approvaltypenameout Action type names corresponding to the actions
 * that are used in the input rule
 * @param approvaltypedescriptionout These are action type descriptions
 * corresponding to the actions that are used in the input rule.
 * @param approvaldescriptionout These are action descriptions corresponding to
 * the actions that are used in the input rule.
 * @rep:displayname Get Rule Details 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getRuleDetails2(ruleIdIn in integer,
                            ruleTypeOut out nocopy varchar2,
                            ruleDescriptionOut out nocopy varchar2,
                            conditionDescriptionsOut out nocopy ame_util.longestStringList,
                            approvalTypeNameOut out nocopy varchar2,
                            approvalTypeDescriptionOut out nocopy varchar2,
                            approvalDescriptionOut out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getruledetails3 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API gets the various rule details including the primary key and
 * description of the condition.
 *
 * This API has the same functionality as getRuleDetails1, but it outputs
 * condition ID and descriptions, and indicates whether each condition has a
 * list of allowed values. Note : This API is a alternative for
 * ame_api3.getRuleDetails3. See also ame_api.getRuleDetails1 and
 * ame_api.getRuleDetails2.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the rule details in the various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param ruleidin Rule id.
 * @param ruletypeout Rule type, for example list creation, list creation and
 * exception, list modification and so on.
 * @param ruledescriptionout Rule description.
 * @param conditionidsout Condition ids for the conditions that are used in the
 * input rule.
 * @param conditiondescriptionsout Condition descriptions corresponding to the
 * condition ids that are used in the input rule.
 * @param conditionhaslovsout This indicates whether the corresponding
 * condition has a list of allowed values
 * @param approvaltypenameout These are action type names corresponding to the
 * actions that are used in the input rule.
 * @param approvaltypedescriptionout Action type descriptions corresponding to
 * the actions that are used in the input rule
 * @param approvaldescriptionout These are action descriptions corresponding to
 * the actions that are used in the input rule.
 * @rep:displayname Get Rule Details 3
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getRuleDetails3(ruleIdIn in integer,
                            ruleTypeOut out nocopy varchar2,
                            ruleDescriptionOut out nocopy varchar2,
                            conditionIdsOut out nocopy ame_util.idList,
                            conditionDescriptionsOut out nocopy ame_util.longestStringList,
                            conditionHasLOVsOut out nocopy ame_util.charList,
                              /* Each value is ame_util.booleanTrue or ame_util.booleanFalse. */
                            approvalTypeNameOut out nocopy varchar2,
                            approvalTypeDescriptionOut out nocopy varchar2,
                            approvalDescriptionOut out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< initializeApprovalProcess >-----------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The initializeApprovalProcess procedure causes AME's engine to
 * prepare a transaction's approval process, if it has not already
 * done so.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The transaction must not have been initiated already.
 *
 * <p><b>Post Success</b><br>
 * The transaction approval process will be initiated.
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
 * @param recordApproverListIn This flag specifies whether to record the approval
 * list or not.
 * @rep:displayname Initialize Approval Process
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure initializeApprovalProcess(applicationIdIn in integer,
                                      transactionIdIn in varchar2,
                                      transactionTypeIn in varchar2 default null,
                                      recordApproverListIn in boolean default false);
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
 * The approver will be inserted in the transaction's current approver list.
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
 * @param approverIn This is the approverRecord defined by ame_util.approverRecord
 * which gives information regarding the Approver.
 * @param positionIn This specifies the index in the approver list where the insertion
 * is to be performed.
 * @param orderIn This is the record defined by ame_util.orderRecord which indicates the
 * order of insertion.
 * @rep:displayname Insert Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure insertApprover(applicationIdIn in integer,
                           transactionIdIn in varchar2,
                           approverIn in ame_util.approverRecord,
                           positionIn in integer,
                           orderIn in ame_util.orderRecord,
                           transactionTypeIn in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< setFirstAuthorityApprover >-----------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The setFirstAuthorityApprover procedure sets the first approver
 * for each chain of authority in the input transaction's approver
 * list. Thus if the approver list includes several chains of authority,
 * they will all start with approverIn.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * 1. The approval_status field of approverIn is null.
 * 2. No chain-of-authority approver in the approver list has a
 *    non-null approval_status value.
 *
 * <p><b>Post Success</b><br>
 * The first approver for each chain of authority will be set the given approver in
 * the given transaction's approver list.
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
 * @param approverIn This is the approverRecord defined by ame_util.approverRecord
 * which gives information regarding the Approver.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 *
 * @rep:displayname Set First Authority Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--

  procedure setFirstAuthorityApprover(applicationIdIn in integer,
                                      transactionIdIn in varchar2,
                                      approverIn in ame_util.approverRecord,
                                      transactionTypeIn in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< updateapprovalstatus >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an approver's approval status.
 * Updates an approver's status (to the approval_status value in
 * approverIn); and, if the approval_status value indicates that a
 * forwarding has occurred, identifies the forwardee. However, if
 * the approval_status value is ame_util.clearExceptionsStatus, the
 * procedure clears the transaction's exception log in AME, without
 * changing any approver's status, regardless of the approver
 * identified by approverIn.
 * When a chain-of-authority approver forwards, AME makes the
 * forwardee also a chain-of-authority approver. Otherwise, the
 * forwardee has the api_insertion value ame_util.apiInsertion, and
 * the same authority value as the forwarder.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * 1. The approver should exist in the transaction's approver list.
 * 2. The status of the approver in the transaction's approver list must be notified.
 *
 * <p><b>Post Success</b><br>
 * The status of the given approver will be updated with the specified status.
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
 * @param approverIn This is the approverRecord defined by ame_util.approverRecord
 * which gives information regarding the Approver.
 * @param forwardeeIn Approver record of the forwardee if forwarding has been done.
 * @rep:displayname Update Approval Status
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure updateApprovalStatus(applicationIdIn in integer,
                                 transactionIdIn in varchar2,
                                 approverIn in ame_util.approverRecord,
                                 transactionTypeIn in varchar2 default null,
                                 forwardeeIn in ame_util.approverRecord default ame_util.emptyApproverRecord);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< updateapprovalstatus2 >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This is a wrapper for updateApprovalStatus that lets you
 * identify an approver by person ID or user ID, rather than passing
 * an entire ame_util.approverRecord to the API.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * 1. The approver should exist in the transaction's approver list.
 * 2. The status of the approver in the transaction's approver list must be notified.
 *
 * <p><b>Post Success</b><br>
 * The status of the given approver will be updated with the specified status.
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
 * @param approvalStatusIn This specifies the status to be updated.
 * @param approverPersonIdIn This specifies the person id of the approver.
 * @param approverUserIdIn This specifies the user id of the approver.
 * @param forwardeeIn This is the record specified by ame_util.approverRecord
 * that represents the approver to whom forwarding has been done.
 * @param approvalTypeIdIn This specifies the type of the approver.
 * @param groupOrChainIdIn This specifies the id of the Group or the chain
 * to which the approver belongs to.
 * @param occurrenceIn This represents the Occurrence of the approver in the
 * approver list of a particular item.
 * @rep:displayname Update Approval Status 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure updateApprovalStatus2(applicationIdIn in integer,
                                  transactionIdIn in varchar2,
                                  approvalStatusIn in varchar2,
                                  approverPersonIdIn in integer default null,
                                  approverUserIdIn in integer default null,
                                  transactionTypeIn in varchar2 default null,
                                  forwardeeIn in ame_util.approverRecord default ame_util.emptyApproverRecord,
                                  approvalTypeIdIn in integer default null,
                                  groupOrChainIdIn in integer default null,
                                  occurrenceIn in integer default null);
end ame_api;

 

/
