--------------------------------------------------------
--  DDL for Package AME_API6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_API6" AUTHID CURRENT_USER as
/* $Header: ameeapi6.pkh 120.6.12010000.2 2011/11/15 06:54:38 kkananth ship $ */
/*#
 * This API package contains ancillary routines.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Ancillary Parallel Approvers Process
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getApprovers >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of approvers who have acted upon a particular
 * transaction.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The approver list with all the information is returned.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approversOut This is the approversTable defined by ame_util.approversTable2
 * which gives information regarding all the Approvers who have acted upon a
 * particular transaction.
 * @rep:displayname Get Approvers
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getApprovers(applicationIdIn in number,
                         transactionTypeIn in varchar2,
                         transactionIdIn in varchar2,
                         approversOut out nocopy ame_util.approversTable2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< updateapprovalstatus >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
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
 * This api is typically used to update the AME Approvals History region,
 * with the notification id and user comments through notification record.
 * AME Approvals History region can be used to override default workflow
 * action history region to display details of parallel approval process.
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
 * @param notificationIn This is the notificationRecord defined by
 * ame_util2.notificationRecord which is used to pass the notification id and user comments.
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
                                 notificationIn in ame_util2.notificationRecord
                                          default ame_util2.emptyNotificationRecord,
                                 forwardeeIn in ame_util.approverRecord2 default
                                             ame_util.emptyApproverRecord2,
                                 updateItemIn in boolean default false) ;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< updateapprovalstatus2 >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This is a wrapper for updateApprovalStatus that lets you
 * identify an approver by role name, rather than passing
 * an entire ame_util.approverRecord to the API.
 * This api is typically used to update the AME Approvals History region, with
 * the notification id and user comments through notification record.AME
 * Approvals History region can be used to override default workflow action
 * history region to display details of parallel approval process.
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
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param approvalStatusIn This specifies the status to be updated.
 * @param approverNameIn This is the workflow role name of the approver.
 * @param itemClassIn This specifies the Item Class for which the approver status
 * has to be updated.
 * @param itemIdIn This specifies the Item id of the item class for which the
 * approver status has to be updated.
 * @param actionTypeIdIn This specifies the type of the approver.
 * @param groupOrChainIdIn This specifies the id of the Group or the chain
 * to which the approver belongs to.
 * @param occurrenceIn Approver's Occurrence in the group or chain.
 * @param notificationIn This is the notificationRecord defined by
 * ame_util2.notificationRecord which is used to pass the notification id and user comments.
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
                                  notificationIn in ame_util2.notificationRecord
                                        default ame_util2.emptyNotificationRecord,
                                  forwardeeIn in ame_util.approverRecord2
                                        default ame_util.emptyApproverRecord2,
                                  updateItemIn in boolean default false);

procedure getApprovers2(applicationIdIn   in number
                        ,transactionTypeIn in varchar2
                        ,transactionIdIn   in varchar2
                        ,approversOut     out nocopy ame_util.approversTable2);

end ame_api6;

/
