--------------------------------------------------------
--  DDL for Package AME_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_API2" AUTHID CURRENT_USER as
/* $Header: ameeapi2.pkh 120.5 2006/10/12 11:54:43 avarri noship $ */
/*#
 * This API package contains routines that a typical workflow uses to process
 * an approval process.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Parallel Approval Process
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< validateapprover >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the generated approver against wf_roles.
 *
 * This API is used to check whether an ame_util.approverRecord2 that the
 * calling application generates is valid, especially before passing an
 * ame_util.approverRecord2 to an AME API routine.
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
 * @param approverin This is an ame_util.approverRecord2 that represents an
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
  function validateApprover(approverIn in ame_util.approverRecord2) return boolean;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< clearallapprovals >------------------------|
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
 * @param applicationidin The fnd_application.application_id value for the
 * originating application that called the AME API routine.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @rep:displayname Clear All Approvals
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure clearAllApprovals(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getadminapprover >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns an ame_util.approverRecord2 representing the
 * administrative approver for a transaction type.
 *
 * An originating application may wish to notify this approver when AME raises
 * an exception.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the administrative approver for a transaction in
 * ame_util.approverRecord2 format. Also, it will return the wf_role name as
 * adminapproverout.name and will return ame_util.exceptionStatus as
 * adminapproverout.approval_status.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value for the
 * originating application that called the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param adminapproverout This is an ame_util.approverRecord2 that represents
 * the administrator for the particular transaction type.
 * @rep:displayname Get Admin Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAdminApprover(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             adminApproverOut out nocopy ame_util.approverRecord2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getallapprovers1 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) for a transaction.
 *
 * The approvers' indexes in approversOut are consecutive ascending integers
 * starting at one. The order induced by the indexes is consistent with the
 * ordering inducd by the approvers' approver_order_number values (which AME's
 * parallel-approval-process functionality generates). The approvers'
 * approval_status values reflect the approvers' latest responses to requests
 * for approvals, assuming the originating application has communicated such
 * responses to AME via ame_api2.updateApprovalStatus or
 * ame_api2.updateApprovalStatus2.
 * <p> approvalProcessCompleteYNOut can have one of the following values
 * <ul><li> ame_util2.completeFullyApproved - all the approvers for the transaction
 *      have approved
 * <li> ame_util2.completeNoApprovers - approval process of the transaction is
 *      completed as there are no approvers for it.
 * <li> ame_util2.notCompleted - approval process of the transaction is not
 *      completed and there are approvers to respond.
 * <li> ame_util2.completeFullyRejected - all the approvers for the transaction
 *      have rejected.
 * <li> ame_util2.completePartiallyApproved - approval process of the
 *      transaction is complete and it is partially approved as some of the
 *      items of the transaction are rejected.</ul>
 * <p> If an approver's item_id value is null, several
 * items require the approver. If such an approver is at index i in
 * approversOut, and itemIndexesOut(j) = i, then itemIdsOut(j) is the ID of an
 * item requiring the approver, itemClassesOut(i) is the item's item class, and
 * itemSourcesOut(j) is the source field indicating which rules required the
 * approver for the same item. Use this API to fetch and display the entire
 * approver list, either for information or to prompt for approver insertions
 * or suppresions.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers in various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API does not return any approver and raises an error.
 *
 * @param applicationidin The fnd_application.application_id value for the
 * originating application that called the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param approversout This is an ame_util.approverstable2, and is populated
 * with the generated list of approvers.
 * @param itemindexesout This is a list of item indices corresponding to each
 * generated approver.
 * @param itemclassesout This is a list of item classes corresponding to each
 * generated approver.
 * @param itemidsout Ths is a list of item ids corresponding to each generated
 * approver.
 * @param itemsourcesout This is the source of the item corresponding to each
 * generated approver.
 * @rep:displayname Get All Approvers 1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllApprovers1(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getallapprovers2 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers, including per-approver productions
 * (name, value) pair, and both rule-generated and inserted approvers for a
 * transaction.
 *
 * This API has the same functionality as ame_api2.getAllApprovers1, but it
 * also returns per-approver productions stored in variableNamesOut and
 * variableValuesOut. Several productions can be assigned a single approver, so
 * productionIndexesOut contains for each production the index of the approver
 * in approversOut to which the production is assigned. That is, if
 * productionIndexesOut(i) = j, then the production in variableNamesOut(i) and
 * variableValuesOut(i) is assigned to approversOut(j). Use getAllApprovers2 as
 * you would getAllApprovers1, when you need to display perapprover productions
 * with the approvers.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers in various out parameters. It
 * will include the per-approver productions (name, value) pair, and both
 * rule-generated and inserted approvers for a transaction.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
 *
 * @param applicationidin This is the nd_application.application_id value for
 * the originating application that called the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param approversout This is an ame_util.approverstable2, and is populated
 * with the list of generated approvers.
 * @param itemindexesout This is a list of item indices corresponding to each
 * generated approver..
 * @param itemclassesout This is a list of item classes corresponding to each
 * generated approver.
 * @param itemidsout This is a list of item ids corresponding to each generated
 * approver.
 * @param itemsourcesout This is the source of the item corresponding to each
 * generated approver.
 * @param productionindexesout This contains the production indices (if any).
 * @param variablenamesout This holds the per-approver production variable
 * names that correspond to each generated approver.
 * @param variablevaluesout This holds the per-approver production variable
 * values that correspond to each production name.
 * @rep:displayname Get All Approvers 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllApprovers2(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             productionIndexesOut out nocopy ame_util.idList,
                             variableNamesOut out nocopy ame_util.stringList,
                             variableValuesOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getallapprovers3 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers for a transaction, and includes the
 * per-approver and per-transaction productions (name, value) pair; and both
 * rule-generated and inserted approvers.
 *
 * This API has the same functionality as ame_api2.getAllApprovers2, but it
 * also returns per-transaction productions. Use getAllApprovers3 as you would
 * getAllApprovers2, when you need to display per-transaction productions as
 * well as the approver list. See also ame_api2.getAllApprovers1 and
 * ame_api2.getAllApprovers2.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers including per-approver and
 * per-transaction productions (name, value) pair, and both rule-generated and
 * inserted approver for a transaction into the various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param approversout This is an ame_util.approverstable2, that will be
 * populated with the list of generated approvers.
 * @param itemindexesout List of item indices corresponding to each generated
 * approver.
 * @param itemclassesout List of item classes corresponding to each generated
 * approver.
 * @param itemidsout List of item ids corresponding to each generated approver.
 * @param itemsourcesout Source of the item corresponding to each generated
 * approver.
 * @param productionindexesout Production Indices (if any).
 * @param variablenamesout Per-approver production variable names corresponding
 * to each generated approvers (if any).
 * @param variablevaluesout Per-approver production variable values
 * corresponding to each production names (if any).
 * @param transvariablenamesout Per-transaction production variable names (if
 * any).
 * @param transvariablevaluesout Per-transaction production variable values
 * corresponding to each per-transaction production names (if any).
 * @rep:displayname Get All Approvers 3
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
    procedure getAllApprovers3(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             productionIndexesOut out nocopy ame_util.idList,
                             variableNamesOut out nocopy ame_util.stringList,
                             variableValuesOut out nocopy ame_util.stringList,
                             transVariableNamesOut out nocopy ame_util.stringList,
                             transVariableValuesOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getallapprovers4 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) along with rule primary keys requiring each approver for a
 * transaction.
 *
 * This API has the same functionality as getAllApprovers1, but it also
 * classifies the approvers in approversOut according to the reasons for their
 * occurrence in the approver list. When one or more rules require an approver,
 * ruleIdsOut identifies the rules. More particularly: every approver in
 * approversOut has at least one row in ruleIndexesOut, sourceTypesOut and
 * ruleIdsOut. If ruleIndexesOut(i) = j, then the values in sourceTypesOut(i)
 * and ruleIdsOut(i) pertain to the approver in approversOut(j). Every approver
 * in approversOut has only one source value, no matter how many rules required
 * the approver. That is, if ruleIndexesOut(i1) = j and ruleIndexesOut(i2) = j
 * for i1 and i2, sourceTypesOut(i1) = sourceTypesOut(i2). Some source values
 * indicate that an approver is not required by any rules, but is present for
 * other reasons. In such cases, if the approver is at index i, then if
 * sourceTypesOut(j) = i, then ruleIdsOut(j) = null. Use getAllApprovers4 when
 * you need to display the approver list, along with the rules requiring each
 * approver. See also ame_api2.getAllApprovers1. Note that getAllApprovers4
 * requires significantly more performance overhead than some of its sibling
 * getAllApprovers[n] procedures.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) along with rule ids requiring each approver for a transaction
 * into various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param approversout This is an ame_util.approverstable2, that will be
 * populated with the list of approvers generated.
 * @param itemindexesout List of item indices corresponding to each generated
 * approver.
 * @param itemclassesout List of item classes corresponding to each generated
 * approver.
 * @param itemidsout List of item ids corresponding to each generated approver.
 * @param itemsourcesout Source of the item corresponding to each generated
 * approver.
 * @param ruleindexesout List of rule indices corresponding to each rules
 * requiring for each generated approver.
 * @param sourcetypesout Source types corresponding to each generated approver,
 * that is, whether rule generated, insertee, surrogate and so on.
 * @param ruleidsout List of Rule ids corresponding to each generated approver.
 * @rep:displayname Get All Approvers 4
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllApprovers4(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             ruleIndexesOut out nocopy ame_util.idList,
                             sourceTypesOut out nocopy ame_util.stringList,
                             ruleIdsOut out nocopy ame_util.idList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getallapprovers5 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) along with rule descriptions requiring each approver for a
 * transaction.
 *
 * The getAllApprovers5 procedure has the same functionality as
 * getAllApprovers4, but it returns rule descriptions rather than rule IDs. See
 * also ame_api2.getAllApprovers4.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) along with rule descriptions requiring each approver for a
 * transaction into the various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param approversout This is an ame_util.approverstable2, that will be
 * populated with the list of generated approvers.
 * @param itemindexesout List of item indices corresponding to each generated
 * approver.
 * @param itemclassesout List of item classes corresponding to each generated
 * approver.
 * @param itemidsout List of item ids corresponding to each generated approver.
 * @param itemsourcesout Source of the item corresponding to each generated
 * approver.
 * @param ruleindexesout List of rule indices corresponding to each rules
 * requiring for each generated approver.
 * @param sourcetypesout Source types corresponding to each generated approver,
 * that is,whether rule generated, insertee, surrogate and so on.
 * @param ruledescriptionsout List of rules' descriptions corresponding to each
 * generated approver.
 * @rep:displayname Get All Approvers 5
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllApprovers5(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             ruleIndexesOut out nocopy ame_util.idList,
                             sourceTypesOut out nocopy ame_util.stringList,
                             ruleDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getallapprovers6 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers), along with the rules requiring each approver for a transaction.
 *
 * The getAllApprovers6 procedure has the same functionality as
 * getAllApprovers4, but it returns both rule IDs and rule descriptions. See
 * also ame_api2.getAllApprovers4 and ame_api2.getAllApprovers4
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) along with rule ids and descriptions requiring each approver for
 * a transaction into various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param approversout This is an ame_util.approverstable2, that will be
 * populated with the list of generated approvers.
 * @param itemindexesout List of item indices corresponding to each generated
 * approver.
 * @param itemclassesout List of item classes corresponding to each generated
 * approver.
 * @param itemidsout List of item ids corresponding to each generated approver.
 * @param itemsourcesout Source of the item corresponding to each generated
 * approver.
 * @param ruleindexesout List of rule indices corresponding to each rules
 * requiring for each generated approver.
 * @param sourcetypesout Source types corresponding to each generated
 * approvers, that is, whether rule generated, insertee, surrogate and so on.
 * @param ruleidsout List of rule ids corresponding to each generated approver.
 * @param ruledescriptionsout List of rule descriptions corresponding to each
 * rule id.
 * @rep:displayname Get All Approvers 6
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllApprovers6(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             ruleIndexesOut out nocopy ame_util.idList,
                             sourceTypesOut out nocopy ame_util.stringList,
                             ruleIdsOut out nocopy ame_util.idList,
                             ruleDescriptionsOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getallapprovers7 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) for a transaction.
 *
 * The getAllApprovers7 procedure has the same functionality as
 * getAllApprovers1, but omitting the per-item outputs. This is the
 * lowest-overhead of all the getAllApprovers[n] procedures. See also
 * ame_api2.getAllApprovers1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) for a transaction into various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param approversout This is an ame_util.approverstable2, that will be
 * populated with the list of approvers generated.
 * @rep:displayname Get All Approvers 7
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllApprovers7(applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getallitemapprovers1 >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) for an item in a transaction.
 *
 * This API has the same functionality as getAllApprovers7, but for the single
 * item with ID itemIdIn of the item class with the ID itemClassIdIn. See also
 * ame_api2.getAllApprovers7.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) for an item in a transaction into various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param itemclassidin Item class id of an item class. For example, header,
 * line item, cost center, projects and so on.
 * @param itemidin Item Id in a transaction for which the list of approvers
 * will be retrieved.
 * @param approvalprocesscompleteynout This indicates current status of
 * item's approval process.
 * @param approversout This is an ame_util.approverstable2, that will be
 * populated with the list of approvers generated.
 * @rep:displayname Get All Item Approvers 1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllItemApprovers1(applicationIdIn in number,
                                 transactionTypeIn in varchar2,
                                 transactionIdIn in varchar2,
                                 itemClassIdIn in number,
                                 itemIdIn in varchar2,
                                 approvalProcessCompleteYNOut out nocopy varchar2,
                                 approversOut out nocopy ame_util.approversTable2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getallitemapprovers2 >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) for an item in a transaction.
 *
 * This API has the same functionality as getAllItemApprovers1, but it
 * identifies the input item class by name in itemClassNameIn. See also
 * ame_api2.getAllApprovers1 and ame_api2.getAllItemApprovers1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API returns the list of approvers (both rule-generated and inserted
 * approvers) for an item in a transaction into the various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param itemclassnamein Item class, for example, header, line item, cost
 * center, projects and so on.
 * @param itemidin Item Id in a transaction for which the list of approvers
 * will be retrieved.
 * @param approvalprocesscompleteynout This indicates current status of
 * item's approval process.
 * @param approversout This is an ame_util.approverstable2, that will be
 * populated with the list of approvers generated.
 * @rep:displayname Get All Item Approvers 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAllItemApprovers2(applicationIdIn in number,
                                 transactionTypeIn in varchar2,
                                 transactionIdIn in varchar2,
                                 itemClassNameIn in varchar2,
                                 itemIdIn in varchar2,
                                 approvalProcessCompleteYNOut out nocopy varchar2,
                                 approversOut out nocopy ame_util.approversTable2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getandrecordallapprovers >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns all the approvers for a transaction.
 * This API is similar to ame_api2.getAllApprovers1. The only
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
 * @param approversout This is the ame_util.approversTable2 which represents the
 * list of approvers.
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param itemindexesout List of item indices corresponding to each generated
 * approver.
 * @param itemclassesout List of item classes corresponding to each generated
 * approver.
 * @param itemidsout List of item ids corresponding to each generated approver.
 * @param itemsourcesout Source of the item corresponding to each generated
 * approver.
 * @rep:displayname Get And Record All Approvers
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getAndRecordAllApprovers(applicationIdIn in number,
                                     transactionTypeIn in varchar2,
                                     transactionIdIn in varchar2,
                                     approvalProcessCompleteYNOut out nocopy varchar2,
                                     approversOut out nocopy ame_util.approversTable2,
                                     itemIndexesOut out nocopy ame_util.idList,
                                     itemClassesOut out nocopy ame_util.stringList,
                                     itemIdsOut out nocopy ame_util.stringList,
                                     itemSourcesOut out nocopy ame_util.longStringList);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< getitemstatus1 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the status of approval process of the given item.
 * The item is identified by item id and item class id.
 * <p> approvalProcessCompleteYNOut can have one of the following values
 * <ul><li> ame_util2.completeFullyApproved - all the approvers for the
 *      item have approved
 * <li> ame_util2.completeNoApprovers - approval process of the item is
 *      completed as there are no approvers for it.
 * <li> ame_util2.notCompleted - approval process of the item is not
 *      completed and there are approvers to respond.
 * <li> ame_util2.completeFullyRejected - approval process of the item is
 *      complete and fully rejected</ul>
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the status of the approval process for an item in a
 * transaction in the out parameter approvalProcessCompleteYNOut.
 *
 * <p><b>Post Failure</b><br>
 * This API will set approvalProcessCompleteYNOut = null and will raise an
 * error.
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
 * @param itemclassidin Item class id of an item class. For example, the ids of
 * itemclasses:header, line item, cost center, project code and so on.
 * @param itemidin Item id of the item class for which status will be
 * evaluated.
 * @param approvalprocesscompleteynout This indicates current status of
 * item's approval process.
 * @rep:displayname Get Item Status 1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getItemStatus1(applicationIdIn in number,
                           transactionTypeIn in varchar2,
                           transactionIdIn in varchar2,
                           itemClassIdIn in integer,
                           itemIdIn in varchar2,
                           approvalProcessCompleteYNOut out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< getitemstatus2 >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the status of approval process of the given item.
 * The item is identified by item id and item class name.
 * See also ame_api2.getItemStatus1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the status of the approval process for an item in a
 * transaction in the out parameter approvalProcessCompleteYNOut.
 *
 * <p><b>Post Failure</b><br>
 * This API will set approvalProcessCompleteYNOut = null and will raise an
 * error.
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
 * @param itemclassnamein Item class name, for example, header, line item, cost
 * center, project code and so on.
 * @param itemidin Item id of the item class for which status will be
 * evaluated.
 * @param approvalprocesscompleteynout This indicates current status of
 * item's approval process.
 * @rep:displayname Get Item Status 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getItemStatus2(applicationIdIn in number,
                           transactionTypeIn in varchar2,
                           transactionIdIn in varchar2,
                           itemClassNameIn in varchar2,
                           itemIdIn in varchar2,
                           approvalProcessCompleteYNOut out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getitemstatuses >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the current status of approval process of all items belong
 * to a given transaction.
 *
 * The value at approvalProcessesCompleteYNOut(i) indicates the status of
 * item identified by item itemIdsOut(i) of the item class itemClassNamesOut(i)
 * <p> approvalProcessesCompleteYNOut(i) can have one of the following values
 * <ul><li> ame_util2.completeFullyApproved - all the approvers for the
 *      item have approved
 * <li> ame_util2.completeNoApprovers - approval process of the item is
 *      completed as there are no approvers for it.
 * <li> ame_util2.notCompleted - approval process of the item is not
 *      completed and there are approvers to respond.
 * <li> ame_util2.completeFullyRejected - approval process of the item is
 *      complete and fully rejected</ul>
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the item class names and ids and the corresponding
 * approval status for each item for a transaction in the various out
 * parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return the approval process statuses of the items and will
 * raise an error.
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
 * @param itemclassnamesout Item classe names, for example, header, line item, cost
 * center, projects and so on.
 * @param itemidsout Item ids corresponding to the item classes.
 * @param approvalprocessescompleteynout This indicates current status of
 * individual items' approval process.
 * @rep:displayname Get Item Statuses
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getItemStatuses(applicationIdIn in number,
                            transactionTypeIn in varchar2,
                            transactionIdIn in varchar2,
                            itemClassNamesOut out nocopy ame_util.stringList,
                            itemIdsOut out nocopy ame_util.stringList,
                            approvalProcessesCompleteYNOut out nocopy ame_util.charList);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getnextapprovers1 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers requiring notification for the
 * current stage of a transaction approval.
 *
 * Once an originating application updates an approver's status to
 * ame_util.notifiedStatus, getNextApprovers1 excludes the approver from
 * nextApproversOut. An originating application can update an approver's status
 * to ame_util.notifiedStatus by passing ame_util.booleanTrue as
 * flagApproversAsNotifiedIn to a call to getNextApprovers1 that includes the
 * approver in nextApproversOut. Or the originating application can pass
 * ame_util.booleanFalse in flagApproversAsNotifiedIn, and instead call
 * updateApprovalStatus or updateApprovalStatus2 to update the approver's
 * status independently of a call to getNextApprovers. getNextApprovers1
 * outputs current status of transaction's approval process in
 * approvalProcessCompleteYNOut .
 * <p> approvalProcessCompleteYNOut can have one of the following values
 * <ul><li> ame_util2.completeFullyApproved - all the approvers for the transaction
 *      have approved
 * <li> ame_util2.completeNoApprovers - approval process of the transaction is
 *      completed as there are no approvers for it.
 * <li> ame_util2.notCompleted - approval process of the transaction is not
 *      completed and there are approvers to respond.
 * <li> ame_util2.completeFullyRejected - approval process of the transaction is
 *      complete and fully rejected.
 * <li> ame_util2.completePartiallyApproved - approval process of the
 *      transaction is complete and it is partially approved as some of the
 *      items of the transaction are rejected.</ul>
 * Use getNextApprovers1 to iterate through a transaction's approval process
 * one stage at a time. See also ame_api2.getAllApprovers1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers requiring notification for the
 * current stage, for a transaction's approval process in the various out
 * parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param flagapproversasnotifiedin This parameter determines whether to set
 * the approvalStatus as &quot;Notified&quot; for the generated approvers or
 * not based on the input value (ie. Y/N). Default value is Y
 * (ame_util.booleanTrue).
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param nextapproversout This is an ame_util.approverstable2, that will be
 * populated with the list of approvers generated, requiring notification for
 * the current stage of the input transaction's approval process(if any).
 * @param itemindexesout List of item indices corresponding to each generated
 * approver.
 * @param itemclassesout List of item classes corresponding to each generated
 * approver.
 * @param itemidsout List of item ids corresponding to each generated approver.
 * @param itemsourcesout Source of the item corresponding to each generated
 * approver.
 * @rep:displayname Get Next Approvers 1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getNextApprovers1(applicationIdIn in number,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2,
                              flagApproversAsNotifiedIn in varchar2 default ame_util.booleanTrue,
                              approvalProcessCompleteYNOut out nocopy varchar2,
                              nextApproversOut out nocopy ame_util.approversTable2,
                              itemIndexesOut out nocopy ame_util.idList,
                              itemClassesOut out nocopy ame_util.stringList,
                              itemIdsOut out nocopy ame_util.stringList,
                              itemSourcesOut out nocopy ame_util.longStringList);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getnextapprovers2 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers along with per-approver productions,
 * requiring notification for the current stage of approval for the input
 * transaction.
 *
 * This API has the same functionality as as getNextApprovers1, but it also
 * returns per-approver productions. Use getNextApprovers2 to iterate through a
 * transaction's approval process one stage at a time when your application
 * enables per-approver productions, for example to track per-approver
 * eSignature requirements. See also ame_api2.getAllApprovers2 and
 * ame_api2.getNextApprovers1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers along with per-approver
 * productions, requiring notification for the current stage of the input
 * transaction's approval process in the various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param flagapproversasnotifiedin This parameter determines whether to set
 * the approvalStatus as &quot;Notified&quot; for the generated approvers or
 * not based on the input value (ie. Y/N). Default value is Y
 * (ame_util.booleanTrue).
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param nextapproversout This is an ame_util.approverstable2, that will be
 * populated with the list of approvers generated, requiring notification for
 * the current stage of the input transaction's approval process.
 * @param itemindexesout List of item indices corresponding to each generated
 * approver.
 * @param itemclassesout List of item classes corresponding to each generated
 * approver.
 * @param itemidsout List of item ids corresponding to each generated approver.
 * @param itemsourcesout Source of the item corresponding to each generated
 * approver.
 * @param productionindexesout Production Indices (if any).
 * @param variablenamesout Per-approver production variable names corresponding
 * to each generated approvers (if any).
 * @param variablevaluesout Per-approver production variable values
 * corresponding to each production names (if any).
 * @rep:displayname Get Next Approvers 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getNextApprovers2(applicationIdIn in number,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2,
                              flagApproversAsNotifiedIn in varchar2 default ame_util.booleanTrue,
                              approvalProcessCompleteYNOut out nocopy varchar2,
                              nextApproversOut out nocopy ame_util.approversTable2,
                              itemIndexesOut out nocopy ame_util.idList,
                              itemClassesOut out nocopy ame_util.stringList,
                              itemIdsOut out nocopy ame_util.stringList,
                              itemSourcesOut out nocopy ame_util.longStringList,
                              productionIndexesOut out nocopy ame_util.idList,
                              variableNamesOut out nocopy ame_util.stringList,
                              variableValuesOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getnextapprovers3 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers along with per-approver and
 * per-transaction productions, requiring approval notification for the
 * currentinput transaction.
 *
 * This API has the same functionality as getNextApprovers2, but it also
 * returns per-transaction productions. Use getNextApprovers3 when your
 * application enables per-approver and per-transaction productions, for
 * example to track eSignature requirements per approver and transaction. See
 * also ame_api2.getAllApprovers3 and ame_api2.getNextApprovers2.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers along with per-approver and
 * per-transaction productions, requiring notification for the current stage of
 * the input transaction's approval process in the various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param flagapproversasnotifiedin This parameter determines whether to set
 * the approvalStatus as &quot;Notified&quot; for the generated approvers or
 * not based on the input value (ie. Y/N). Default value is Y
 * (ame_util.booleanTrue).
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param nextapproversout This is an ame_util.approverstable2, that will be
 * populated with the list of approvers generated, requiring notification for
 * the current stage of the input transaction's approval process.
 * @param itemindexesout List of item indices corresponding to each generated
 * approver.
 * @param itemclassesout List of item classes corresponding to each generated
 * approver.
 * @param itemidsout List of item ids corresponding to each generated approver.
 * @param itemsourcesout Source of the item corresponding to each generated
 * approver.
 * @param productionindexesout Production Indices (if any).
 * @param variablenamesout Per-approver production variable names corresponding
 * to each generated approvers (if any).
 * @param variablevaluesout Per-approver production variable values
 * corresponding to each production names (if any).
 * @param transvariablenamesout Per-transaction production variable names (if
 * any).
 * @param transvariablevaluesout Per-transaction production variable values
 * corresponding to each per-transaction production names (if any).
 * @rep:displayname Get Next Approvers 3
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getNextApprovers3(applicationIdIn in number,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2,
                              flagApproversAsNotifiedIn in varchar2 default ame_util.booleanTrue,
                              approvalProcessCompleteYNOut out nocopy varchar2,
                              nextApproversOut out nocopy ame_util.approversTable2,
                              itemIndexesOut out nocopy ame_util.idList,
                              itemClassesOut out nocopy ame_util.stringList,
                              itemIdsOut out nocopy ame_util.stringList,
                              itemSourcesOut out nocopy ame_util.longStringList,
                              productionIndexesOut out nocopy ame_util.idList,
                              variableNamesOut out nocopy ame_util.stringList,
                              variableValuesOut out nocopy ame_util.stringList,
                              transVariableNamesOut out nocopy ame_util.stringList,
                              transVariableValuesOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getnextapprovers4 >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers requiring approval notification for
 * the input transaction.
 *
 * This API has the same functionality as getNextApprovers1, but it omits
 * per-item outputs. This is the lowest-overhead getNextApprovers[n] procedure.
 * See also ame_api2.getAllApprovers7 and ame_api2.getNextApprovers1.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of approvers, requiring notification for the
 * current stage of the input transaction's approval process in the various out
 * parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param flagapproversasnotifiedin This parameter determines whether to set
 * the approvalStatus as &quot;Notified&quot; for the generated approvers or
 * not based on the input value (ie. Y/N). Default value is Y
 * (ame_util.booleanTrue).
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param nextapproversout This is an ame_util.approverstable2, that will be
 * populated with the list of approvers generated, requiring notification for
 * the current stage of the input transaction's approval process.
 * @rep:displayname Get Next Approvers 4
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getNextApprovers4(applicationIdIn in number,
                              transactionTypeIn in varchar2,
                              transactionIdIn in varchar2,
                              flagApproversAsNotifiedIn in varchar2 default ame_util.booleanTrue,
                              approvalProcessCompleteYNOut out nocopy varchar2,
                              nextApproversOut out nocopy ame_util.approversTable2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getpendingapprovers >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of pending approvers.
 *
 * The pending approvers are identified with approver_category =
 * ame_util.approvalApproverCategory and approval_status =
 * ame_util.notifiedStatus. These are the approvers who must approve before the
 * input transaction's approval process will continue to the next stage. If
 * approvalProcessCompleteYNOut is other than ame_util2.notComplete, the transaction's
 * approval process is complete. If approvalProcessCompleteYNOut is
 * ame_util2.notComplete and approversOut.count is zero, the application should
 * call one of the getNextApprovers[n] procedures, and notify the approvers
 * returned by that procedure. Note : If ame_api2.getNextApprover[n] is called
 * with flagApproversNotifiedIn as false, then the subsequent call to this API
 * would not return approvers.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the list of pending approvers and the status of the
 * transaction.
 *
 * <p><b>Post Failure</b><br>
 * This API will not return any approver and will raise an error.
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
 * @param approvalprocesscompleteynout This indicates current status of
 * transaction's approval process.
 * @param approversout This is an ame_util.approverstable2, that will be
 * populated with the list of approvers, those who are already notified but yet
 * to respond.
 * @rep:displayname Get Pending Approvers
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getPendingApprovers(applicationIdIn in number,
                                transactionTypeIn in varchar2,
                                transactionIdIn in varchar2,
                                approvalProcessCompleteYNOut out nocopy varchar2,
                                approversOut out nocopy ame_util.approversTable2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< gettransactionproductions >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns all the per-transaction productions for a transaction.
 *
 * Use this API when your application uses AME as a general-purpose
 * production-rule engine. See also ame_api2.getAllApprovers3.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * This API will return the name value pair for all the per-transaction
 * productions for a transaction in various out parameters.
 *
 * <p><b>Post Failure</b><br>
 * This API will raise an error.
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
 * @param variablenamesout Per-transaction production variable names.
 * @param variablevaluesout Per-transaction production variable values
 * corresponding to each production names.
 * @rep:displayname Get Transaction Productions
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getTransactionProductions(applicationIdIn in number,
                                      transactionTypeIn in varchar2,
                                      transactionIdIn in varchar2,
                                      variableNamesOut out nocopy ame_util.stringList,
                                      variableValuesOut out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< initializeapprovalprocess >-----------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Records the date at which the transaction's approval process was
 * initiated and optionally records the current approver list (for the
 * sake of making that data available to getOldApprovers).
 * The procedure getAllApprovers requires a commit if there has
 * been no previous call to any of the API which require transaction
 * management. Otherwise, it is now a "read only" procedure (it
 * does not require a commit or rollback). To make sure it functions
 * as such, make sure your application calls
 * The AME API initializeApprovalProcess (with or without recording the
 * approver list, it doesn't matter) before it calls any other ame_api
 * routine.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The approval process will be initialized.
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
 * @param recordApproverListIn This flag specifies whether to Record the approvers
 * list or not.
 *
 * @rep:displayname Initialize Approval Process
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure initializeApprovalProcess(applicationIdIn in number,
                                      transactionTypeIn in varchar2,
                                      transactionIdIn in varchar2,
                                      recordApproverListIn in boolean default false);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< setfirstauthorityapprover >-----------------|
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
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approverIn This is the approverRecord defined by ame_util.approverRecord2
 * which gives information regarding the Approver.
 * @param clearChainStatusYNIn This flag specifies whether to clear chain status or not.
 *
 * @rep:displayname Set First Authority Approver
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure setFirstAuthorityApprover(applicationIdIn in number,
                                      transactionTypeIn in varchar2,
                                      transactionIdIn in varchar2,
                                      approverIn in ame_util.approverRecord2,
                                      clearChainStatusYNIn in varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< updateapprovalstatus >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Updates an approver's status (to the approval_status value in
 * approverIn); and, if the approval_status value indicates that a
 * forwarding/reassignment has occurred, identifies the forwardee. However,
 * if the approval_status value is ame_util.clearExceptionsStatus, the
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
 * None
 *
 * <p><b>Post Success</b><br>
 * The status of the given approver will be updated with the specified status.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value for the
 * originating application that called the AME API routine.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param approverIn Approver record describing the approver.
 * @param forwardeeIn Approver record of the forwardee if forwarding has been done.
 * @param updateItemIn This flag determines whether the status of the repeated
 * occurrences of the approvers in the same item have to be updated or not.
 * @rep:displayname Update Approval Status
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure updateApprovalStatus(applicationIdIn in number,
                                 transactionTypeIn in varchar2,
                                 transactionIdIn in varchar2,
                                 approverIn in ame_util.approverRecord2,
                                 forwardeeIn in ame_util.approverRecord2 default ame_util.emptyApproverRecord2,
                                 updateItemIn in boolean default false);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< updateapprovalstatuses >---------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
  procedure updateApprovalStatuses(applicationIdIn in number,
                                   transactionTypeIn in varchar2,
                                   transactionIdIn in varchar2,
                                   approverIn in ame_util.approverRecord2,
                                   approvalStatusesIn in ame_util.stringList default ame_util.emptyStringList,
                                   itemClassesIn in ame_util.stringList default ame_util.emptyStringList,
                                   itemIdsIn in ame_util.stringList default ame_util.emptyStringList,
                                   forwardeesIn in ame_util.approversTable2 default ame_util.emptyApproversTable2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< updateapprovalstatus2 >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This is a wrapper for updateApprovalStatus that lets you
 * identify an approver by name, rather than passing
 * an entire ame_util.approverRecord to the API.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The status of the given approver will be updated with the specified status.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value for the
 * originating application that called the AME API routine.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param approvalStatusIn This specifies the status to be updated.
 * @param approverNameIn This specifies the role name of the approver.
 * @param itemClassIn This specifies the Item Class for which the approver status
 * has to be updated.
 * @param itemIdIn This specifies the Item id for which the approver status
 * has to be updated.
 * @param actionTypeIdIn This specifies the action type, which has generated
 * this approver.
 * @param groupOrChainIdIn  This specifies the id of the Group or the chain
 * to which the approver belongs to.
 * @param occurrenceIn This represents the Occurrence of the approver in the
 * approver list of a particular item.
 * @param forwardeeIn Approver record of the forwardee if forwarding has been done.
 * @param updateItemIn This flag determines whether the status of the repeated
 * occurrences of the approvers in the same item have to be updated or not.
 * @rep:displayname Update Approval Status 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure updateApprovalStatus2(applicationIdIn in number,
                                  transactionTypeIn in varchar2,
                                  transactionIdIn in varchar2,
                                  approvalStatusIn in varchar2,
                                  approverNameIn in varchar2,
                                  itemClassIn in varchar2 default null,
                                  itemIdIn in varchar2 default null,
                                  actionTypeIdIn in number default null,
                                  groupOrChainIdIn in number default null,
                                  occurrenceIn in number default null,
                                  forwardeeIn in ame_util.approverRecord2 default ame_util.emptyApproverRecord2,
                                  updateItemIn in boolean default false);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< updateapprovalstatuses2 >---------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
  procedure updateApprovalStatuses2(applicationIdIn in number,
                                    transactionTypeIn in varchar2,
                                    transactionIdIn in varchar2,
                                    approvalStatusIn in varchar2,
                                    approverNameIn in varchar2,
                                    itemClassIn in varchar2 default null,
                                    itemIdIn in varchar2 default null,
                                    actionTypeIdIn in number default null,
                                    groupOrChainIdIn in number default null,
                                    occurrenceIn in number default null,
                                    approvalStatusesIn in ame_util.stringList default ame_util.emptyStringList,
                                    itemClassesIn in ame_util.stringList default ame_util.emptyStringList,
                                    itemIdsIn in ame_util.stringList default ame_util.emptyStringList,
                                    forwardeesIn in ame_util.approversTable2 default ame_util.emptyApproversTable2);
end ame_api2;

 

/
