--------------------------------------------------------
--  DDL for Package AME_API4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_API4" AUTHID CURRENT_USER as
/* $Header: ameeapi4.pkh 120.1 2005/10/02 02:35 aroussel $ */
/*#
 * This package contains ancillary APIs.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Approval Process Groups
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< getgroupmembers >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the approval group members' details for the input approval
 * group id and transaction.
 *
 * This API returns the approval group members order number, person id and user
 * id for the input approval group id and transaction.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the approval group members' person id or user id and
 * their corresponding order numbers.
 *
 * <p><b>Post Failure</b><br>
 * The API will not return the group members' details and will raise an error.
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
 * @param groupidin Approval group id.
 * @param memberordernumbersout Group members' order number.
 * @param memberpersonidsout Group members' person id.
 * @param memberuseridsout Group members' user id.
 * @rep:displayname Get Group Members
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
  procedure getGroupMembers(applicationIdIn       in number,
                            transactionTypeIn     in varchar2,
                            transactionIdIn       in varchar2,
                            groupIdIn             in number,
                            memberOrderNumbersOut out nocopy ame_util.idList,
                            memberPersonIdsOut    out nocopy ame_util.idList,
                            memberUserIdsOut      out nocopy ame_util.idList);
end ame_api4;

 

/
