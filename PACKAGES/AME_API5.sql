--------------------------------------------------------
--  DDL for Package AME_API5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_API5" AUTHID CURRENT_USER as
/* $Header: ameeapi5.pkh 120.4 2006/10/12 07:53:51 avarri noship $ */
/*#
 * This API package contains ancillary routines.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Ancillary Parallel Approvers Process
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< clearitemclassapprovals1 >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Clears the approval process for the item class specified by the parameter,
 * itemClassIdIn.The item id can also be passed optionally to clear approvals
 * of a particular item only.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The API will clear the approval process for the specified item class or item.
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
 * @param itemClassIdIn This uniquely identifies the item class.
 * @param itemIdIn This uniquely identifies the item with in an item class.
 * @rep:displayname Clear Item Class Approvals 1
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure  clearItemClassApprovals1(applicationIdIn    in number,
                                      transactionTypeIn  in varchar2,
                                      transactionIdIn    in varchar2,
                                      itemClassIdIn      in number,
                                      itemIdIn           in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< clearitemclassapprovals2 >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Clears the approval process for the item class specified by the parameter,
 * itemClassNameIn.The item id can also be passed optionally to clear approvals of a
 * particular item only.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The API will clear the approval process for the specified item class or item.
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
 * @param itemClassNameIn This uniquely identifies the item class.
 * For example, header, line item, cost center, projects and so on.
 * This is the string parameter of up to 100 bytes long.
 * @param itemIdIn This uniquely identifies the item with in an item class.
 * @rep:displayname Clear Item Class Approvals 2
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure  clearItemClassApprovals2(applicationIdIn    in number,
                                      transactionTypeIn  in varchar2,
                                      transactionIdIn    in varchar2,
                                      itemClassNameIn    in varchar2,
                                      itemIdIn           in varchar2 default null);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< getapprovalgroupname >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Returns the name of the approval group for the passed approval group id.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * The API will return the name of the approval group with the out parameter groupNameOut.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param groupIdIn This uniquely identifies an approver group.
 * @param groupNameOut Name of the approver group.
 * @rep:displayname Get Approval Group Name
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure  getApprovalGroupName(groupIdIn   in   number
                                 ,groupNameOut out nocopy ame_util.stringType);
  procedure getAllApproversAndInsertions
    (applicationIdIn                in            number
    ,transactionTypeIn              in            varchar2
    ,transactionIdIn                in            varchar2
    ,activeApproversYNIn            in            varchar2 default ame_util.booleanFalse
    ,coaInsertionsYNIn              in            varchar2 default ame_util.booleanFalse
    ,approvalProcessCompleteYNOut      out nocopy varchar2
    ,approversOut                      out nocopy ame_util.approversTable2
    ,availableInsertionsOut            out nocopy ame_util2.insertionsTable3
    );
end ame_api5;

 

/
