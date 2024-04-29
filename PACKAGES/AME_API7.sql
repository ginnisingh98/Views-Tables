--------------------------------------------------------
--  DDL for Package AME_API7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_API7" AUTHID CURRENT_USER as
/* $Header: ameeapi7.pkh 120.1 2006/10/05 13:59:14 avarri noship $ */
/*#
 * This API package contains ancillary routines.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Ancillary Parallel Approvers Process
*/
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
 * @param itemclassin This specifies the Item Class name. Example: header,
 * line item, cost center, project code and so on, for which the
 * list of group members will be retrieved.
 * @param itemidin Item Id in a transaction for which the list of group members
 * will be retrieved.
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
  procedure getGroupMembers1(applicationIdIn       in number   default null,
                             transactionTypeIn     in varchar2 default null,
                             transactionIdIn       in varchar2 default null,
                             itemClassIn           in varchar2,
                             itemIdIn              in varchar2,
                             groupIdIn             in number,
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
 * the group members' wf_roles.name values. See also ame_api7.getGroupMembers1.
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
 * @param itemclassin This specifies the Item Class name. Example: header,
 * line item, cost center, project code and so on, for which the
 * list of group members will be retrieved.
 * @param itemidin Item Id in a transaction for which the list of group members
 * will be retrieved.
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
  procedure getGroupMembers2(applicationIdIn       in number   default null,
                             transactionTypeIn     in varchar2 default null,
                             transactionIdIn       in varchar2 default null,
                             itemClassIn           in varchar2,
                             itemIdIn              in varchar2,
                             groupIdIn             in number,
                             memberNamesOut        out nocopy ame_util.longStringList,
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
 * the members' order numbers. See also ame_api7.getGroupMembers2.
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
 * @param itemclassin This specifies the Item Class name. Example: header,
 * line item, cost center, project code and so on, for which the
 * list of group members will be retrieved.
 * @param itemidin Item Id in a transaction for which the list of group members
 * will be retrieved.
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
  procedure getGroupMembers3(applicationIdIn       in number   default null,
                             transactionTypeIn     in varchar2 default null,
                             transactionIdIn       in varchar2 default null,
                             itemClassIn           in varchar2,
                             itemIdIn              in varchar2,
                             groupIdIn             in number,
                             memberNamesOut        out nocopy ame_util.longStringList,
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
 * also ame_api7.getGroupMembers3.
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
 * @param itemclassin This specifies the Item Class name. Example: header,
 * line item, cost center, project code and so on, for which the
 * list of group members will be retrieved.
 * @param itemidin Item Id in a transaction for which the list of group members
 * will be retrieved.
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
  procedure getGroupMembers4(applicationIdIn        in number   default null,
                             transactionTypeIn      in varchar2 default null,
                             transactionIdIn        in varchar2 default null,
                             itemClassIn            in varchar2,
                             itemIdIn               in varchar2,
                             groupIdIn              in number,
                             memberNamesOut         out nocopy ame_util.longStringList,
                             memberOrderNumbersOut  out nocopy ame_util.idList,
                             memberDisplayNamesOut  out nocopy ame_util.longStringList,
                             memberOrigSystemIdsOut out nocopy ame_util.idList,
                             memberOrigSystemsOut   out nocopy ame_util.stringList);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getattributevalue >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the value of an attribute for a given transaction.
 *
 * This API outputs attributeValue1Out, attributeValue2Out, and
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
 * @param attributenamein This specifies the Attribute name.
 * @param itemclassin This specifies the attributes' Item Class name.
 * Example: header, line item, cost center, projects and so on.
 * @param itemidin Item id corresponding to the item class, to that
 * the attribute belongs.
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
                               itemClassIn in varchar2,
                               itemIdIn in varchar2,
                               attributeValue1Out out nocopy varchar2,
                               attributeValue2Out out nocopy varchar2,
                               attributeValue3Out out nocopy varchar2);
--
end ame_api7;

 

/
