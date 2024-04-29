--------------------------------------------------------
--  DDL for Package AME_ITEM_CLASS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITEM_CLASS_API" AUTHID CURRENT_USER as
/* $Header: amitcapi.pkh 120.3 2006/05/05 00:22 avarri noship $ */
/*#
 * This package contains AME Item class APIs.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Item Class
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_AME_ITEM_CLASS >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to create an item class.
--
-- Prerequisites:
--   The set_base_key_value procedure for item class must be run
--   before this API procedure is called.
--
-- In Parameters:
--
--   Name                   Reqd  Type      Description
--   P_VALIDATE             N     boolean   If passed as true, all operations
--                                          are rolled back.Used for validating
--                                          the operation. Default false
--   P_NAME                 Y     varchar2  The item class name.
--
-- Post Success:
--   The API creates the item class and then sets the following
--   OUT parameters.
--
--   Name                           Type     Description
--   P_ITEM_CLASS_ID                number   Unique ID for the Item Class
--   P_OBJECT_VERSION_NUMBER        number   Set to 1 when record is inserted.
--   P_START_DATE                   date     Date from which the item class
--                                           is effective.
--   P_END_DATE                     date     Date u pto, which item class
--                                           is effective. Set to null,
--                                           upon creation.
--
-- Post Failure:
--   The API procedure does not create the item class.
--
-- Access Status:
--   Internal Development use only.
--
-- {End Of Comments}
--
Procedure create_ame_item_class
                        (p_validate                in         boolean  default false
                        ,p_language_code           in         varchar2 default
                                                                         hr_api.userenv_lang
                        ,p_name                    in         varchar2
                        ,p_user_item_class_name    in         varchar2
                        ,p_item_class_id           out nocopy number
                        ,p_object_version_number   out nocopy number
                        ,p_start_date              out nocopy date
                        ,p_end_date                out nocopy date
                        );
--
-- ----------------------------------------------------------------------------
-- |-----------------------<UPDATE_AME_ITEM_CLASS>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API procedure is used to update a given item class
--
-- Prerequisites:
--   A valid item class must exist.
--
-- In Parameters:
--
--   Name                   Reqd  Type      Description
--   P_VALIDATE              N    boolean   If passed as true, all operations
--                                          are rolled back.Used for validating
--                                          the operation. Default false
--   P_ITEM_CLASS_ID         Y    number    The item class ID.
--   P_USER_ITEM_CLASS_NAME  Y    varchar2  The user-defined item class name.
--   P_OBJECT_VERSION_NUMBER Y    number    The Object Version Number of the
--                                          item class to be updated.
--
-- Post Success:
--   The API updates the item class and sets the following OUT parameters.
--
--   Name                           Type     Description
--   P_OBJECT_VERSION_NUMBER        number   Incremented by 1 when the record
--                                           is updated.
--   P_START_DATE                   date     Date from which the updated
--                                           item class is effective ,set to
--                                           present date.
--   P_END_DATE                     date     Date up to, which item class is
--                                           effective.Set to null,upon update.
--
-- Post Failure:
--   The API procedure does not update the item class
--
-- Access Status:
--   Internal Development use only.
--
-- {End Of Comments}
--
procedure update_ame_item_class
        (p_validate                     in     boolean   default false
        ,p_language_code                in     varchar2  default
                                                         hr_api.userenv_lang
        ,p_item_class_id                in     number
        ,p_user_item_class_name         in     varchar2  default hr_api.g_varchar2
        ,p_object_version_number        in out nocopy number
        ,p_start_date                      out nocopy date
        ,p_end_date                        out nocopy date
        );
--
-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_AME_ITEM_CLASS >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API procedure is used to delete a given item class
--
-- Prerequisites:
--   The item_class_id and object_version_number must be entered.
--
-- In Parameters:
--
--   Name                   Reqd  Type      Description
--   P_VALIDATE              N    boolean   If passed as true, all operations
--                                          are rolled back.Used for validating
--                                          the operation. Default false
--   P_ITEM_CLASS_ID         Y    number    The unique active item class_id
--   P_OBJECT_VERSION_NUMBER Y    number    The Object Version Number of the
--                                          item class to be deleted/end dated.
--
-- Post Success:
--   The API deletes the given item class
--
--   Name                           Type     Description
--   P_OBJECT_VERSION_NUMBER        number   Incremented by 1 when the record
--                                           is deleted(end dated).
--   P_START_DATE                   date     Date from which the updated
--                                           item class was effective.
--   P_END_DATE                     date     Date up to, which item class
--                                           was effective.Set to present date.
--
-- Post Failure:
--   The API procedure does not delete the item class
--
-- Access Status:
--   Internal Development use only.
--
-- {End Of Comments}
--
procedure delete_ame_item_class
                         (p_validate              in     boolean  default false
                         ,p_item_class_id         in number
                         ,p_object_version_number in out nocopy number
                         ,p_start_date               out nocopy date
                         ,p_end_date                 out nocopy date
                         );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_item_class_usage >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an item class usage for a given transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The transaction type should be valid.
 *
 * <p><b>Post Success</b><br>
 * Item class usage is created for the given transaction type.
 *
 * <p><b>Post Failure</b><br>
 * Item class usage is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_item_id_query Dynamic sql query string to identify the list of
 * items under the item class. The query may reference AME's: transactionId
 * bind variable, and must return the item IDs in ascending order.
 * @param p_item_class_order_number An item class usage has an order number,
 * which is always an integer with a value of 1 to 'n'. The item class order
 * numbers in the related item class usages order the set of all item classes
 * used by a given transaction type. The order numbers start at one and ascend
 * to at most the number of item classes the transaction type uses. The order
 * numbers are not necessarily unique, so the highest order number may be lower
 * than the number of item class usages in the transaction type. AME uses the
 * item classes' order numbers at run time to sort items' approver lists by
 * item class, for a given transaction.
 * @param p_item_class_par_mode An item class usage has a parallelization mode
 * that has one of two possible values: serial and parallel. The mode governs
 * how AME sorts items' approver lists by item ID.
 * @param p_item_class_sublist_mode An item class usage's sublist mode
 * determines how AME sorts the sublists in each item's approver list.
 * The AME_ITC_SUBLIST_MODE lookup type defines valid values.
 * @param p_application_id This uniquely identifies the transaction type for
 * which item class usage is to be created.
 * @param p_item_class_id This uniquely identifies the item class.
 * @param p_object_version_number If p_validate is false, then it is set to
 * version number of the created item class usage. If p_validate is true, then
 * it is set to null.
 * @param p_start_date If p_validate is false, then it is set to the effective
 * start date for the created transaction type. If p_validate is true, then it
 * is set to null.
 * @param p_end_date It is the date up to, which the item class usage is
 * effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null.
 * @rep:displayname Create Ame Item Class Usage
 * @rep:category BUSINESS_ENTITY AME_ITEM_CLASS
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
Procedure create_ame_item_class_usage
                        (p_validate                in     boolean  default false
                        ,p_item_id_query           in     varchar2
                        ,p_item_class_order_number in     number
                        ,p_item_class_par_mode     in     varchar2
                        ,p_item_class_sublist_mode in     varchar2
                        ,p_application_id          in out nocopy number
                        ,p_item_class_id           in out nocopy number
                        ,p_object_version_number      out nocopy number
                        ,p_start_date                 out nocopy date
                        ,p_end_date                   out nocopy date
                         );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ame_item_class_usage >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an item class usage for a given transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * A valid Item class usage must exist for a given item class id and
 * application id.
 *
 * <p><b>Post Success</b><br>
 * Item class usage is updated for the given transaction type.
 *
 * <p><b>Post Failure</b><br>
 * Item class usage is not updated and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_application_id This uniquely identifies the transaction type for
 * which item class usage is to be updated.
 * @param p_item_class_id This uniquely identifies the item class
 * whose usage has to be updated.
 * @param p_item_id_query Dynamic sql query string to identify the list of
 * items under the item class. The query may reference AME's: transactionId
 * bind variable, and must return the item IDs in ascending order.
 * @param p_item_class_order_number An item class usage has an order number,
 * which is always an integer with a value of 1 to 'n'. The item class order
 * numbers in the related item class usages order the set of all item classes
 * used by a given transaction type. The order numbers start at one and ascend
 * to at most the number of item classes the transaction type uses. The order
 * numbers are not necessarily unique, so the highest order number may be lower
 * than the number of item class usages in the transaction type. AME uses the
 * item classes' order numbers at run time to sort items' approver lists by
 * item class, for a given transaction.
 * @param p_item_class_par_mode An item class usage has a parallelization mode
 * that has one of two possible values: serial and parallel. The mode governs
 * how AME sorts items' approver lists by item ID.
 * @param p_item_class_sublist_mode An item class usage's sublist mode
 * determines how AME sorts the sublists in each item's approver list.
 * The AME_ITC_SUBLIST_MODE lookup type defines valid values.
 * @param p_object_version_number Pass in the current version number of the
 * item class usage to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated item class
 * usage. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_start_date If p_validate is false, It is set to present date.
 * If p_validate is true, it is set to null.
 * @param p_end_date It is the date up to, which the updated item class usage
 * is effective. If p_validate is false, it is set to 31-Dec-4712.
 * If p_validate is true, it is set to null.
 * @rep:displayname Update Ame Item Class Usage
 * @rep:category BUSINESS_ENTITY AME_ITEM_CLASS
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_ame_item_class_usage
        (p_validate                     in     boolean   default false
        ,p_application_id               in     number
        ,p_item_class_id                in     number
        ,p_item_id_query                in     varchar2  default hr_api.g_varchar2
        ,p_item_class_order_number      in     number    default hr_api.g_number
        ,p_item_class_par_mode          in     varchar2  default hr_api.g_varchar2
        ,p_item_class_sublist_mode      in     varchar2  default hr_api.g_varchar2
        ,p_object_version_number        in out nocopy number
        ,p_start_date                   out nocopy date
        ,p_end_date                     out nocopy date
        );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ame_item_class_usage >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an item class usage for a given transaction type.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the
 * e-business suite.
 *
 * <p><b>Prerequisites</b><br>
 * The item class id and the application id should be valid.
 *
 * <p><b>Post Success</b><br>
 * Item class usage is deleted for the given transaction type.
 *
 * <p><b>Post Failure</b><br>
 * Item class usage is not deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_application_id This uniquely identifies the transaction type for
 * which item class usage is to be deleted.
 * @param p_item_class_id This uniquely identifies the item class
 * whose usage has to be deleted.
 * @param p_object_version_number Pass in the current version number of the
 * item class usage to be deleted. When the API completes if p_validate
 * is false, will be set to the new version number of the deleted item class
 * usage. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_start_date If p_validate is false, it is set to the date from
 * which the deleted transaction type was effective. If p_validate is true,
 * it is set to null.
 * @param p_end_date If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to null.
 * @rep:displayname Delete Ame Item Class Usage
 * @rep:category BUSINESS_ENTITY AME_ITEM_CLASS
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_item_class_usage
                          (p_validate              in     boolean  default false
                          ,p_application_id        in     number
                          ,p_item_class_id         in     number
                          ,p_object_version_number in out nocopy number
                          ,p_start_date               out nocopy date
                          ,p_end_date                 out nocopy date
                          );
--
end AME_ITEM_CLASS_API;

 

/
