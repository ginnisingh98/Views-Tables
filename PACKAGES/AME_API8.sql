--------------------------------------------------------
--  DDL for Package AME_API8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_API8" AUTHID CURRENT_USER as
/* $Header: ameeapi8.pkh 120.2 2006/10/12 07:53:44 avarri noship $ */
/*#
 * This API package contains ancillary routines.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Ancillary Parallel Approvers Process
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< getitemproductions >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API returns the list of productions for a particular item in a given
 * transaction.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The API will return the list of productions for a particular item.
 *
 * <p><b>Post Failure</b><br>
 * The API will raise an error.
 *
 * @param applicationidin The fnd_application.application_id value of the
 * originating application calling the AME API routine.
 * @param transactiontypein This is a string parameter up to 50 bytes long. It
 * distinguishes one transaction type from another, within a given originating
 * application. It can be null, but you must always pass its value explicitly.
 * @param transactionidin  This is a string up to 50 bytes long. It identifies a
 * transaction within a transaction type. Its value must not contain
 * white-space characters, and must not be the character representation of a
 * negative integer.
 * @param itemclassin This specifies the Item Class. Example: header,
 * line item, cost center, project code and so on, for which the
 * list of productions will be retrieved.
 * @param itemidin Item Id in a transaction for which the list of productions
 * will be retrieved.
 * @param productionsout List of productions.
 * @rep:displayname Get Item Productions
 * @rep:category BUSINESS_ENTITY AME_APPROVAL
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure getItemProductions(applicationIdIn   in number
                            ,transactionTypeIn in varchar2
                            ,transactionIdIn   in varchar2
                            ,itemClassIn       in varchar2
                            ,itemIdIn          in varchar2
                            ,productionsOut    out nocopy ame_util2.productionsTable);
end ame_api8;

 

/
