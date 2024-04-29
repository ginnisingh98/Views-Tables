--------------------------------------------------------
--  DDL for Package AME_APPROVER_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_GROUP_API" AUTHID CURRENT_USER as
/* $Header: amapgapi.pkh 120.4 2006/12/23 09:54:34 avarri noship $ */
/*#
 * This package contains AME approver group APIs.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Approver Group
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_AME_APPROVER_GROUP >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an approver group.
 *
 * Use this API when you need to create an approver group.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The approver group is created.
 *
 * <p><b>Post Failure</b><br>
 * The approver group is not created and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_LANGUAGE_CODE Specifies to which language the translation values
 * apply, You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param P_NAME Name of the approver group.
 * @param P_DESCRIPTION Description of the approver group.
 * @param P_IS_STATIC Indicates whether the approver group is static or
 * dynamic, allowed values are 'Y' and 'N'.
 * @param P_APPROVAL_GROUP_ID If p_validate is false, then this uniquely
 * identifies the created approver group. If p_validate is true, then set
 * to null.
 * @param P_QUERY_STRING Dynamic sql query string that identifies the members
 * of the dynamic approver group. The query may reference AME's:transactionId
 * bind variable.
 * @param P_OBJECT_VERSION_NUMBER If p_validate is false, then set to
 * the version number of the approver group. If p_validate is true, then set
 * to null.
 * @param P_START_DATE If p_validate is false, then set to the effective
 * start date of the approver group. If p_validate is true, then set to null.
 * @param P_END_DATE It is the date up to, which the approver group is
 * effective. If p_validate is false, then set to 31-Dec-4712. If p_validate
 * is true, then set to null.
 * @rep:displayname Create Ame Approver Group
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AME_APPROVER_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_approver_group
                 (p_validate                 in    boolean  default false
                 ,p_language_code            in    varchar2 default
                                                   hr_api.userenv_lang
                 ,p_name                     in    varchar2
                 ,p_description              in    varchar2
                 ,p_is_static                in    varchar2
                 ,p_query_string             in    varchar2 default null
                 ,p_approval_group_id        out   nocopy   number
                 ,p_start_date               out   nocopy   date
                 ,p_end_date                 out   nocopy   date
                 ,p_object_version_number    out   nocopy   number
                 );
--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_AME_APPROVER_GROUP >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the approver group.
 *
 * Use this API when you need to update an approver group.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * A valid group should exist.
 *
 * <p><b>Post Success</b><br>
 * Approver group is updated.
 *
 * <p><b>Post Failure</b><br>
 * The approver group is not updated and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_LANGUAGE_CODE Specifies to which language the translation values
 * apply. You can set to the base or any installed language.
 * The default value of hr_api.userenv_lang is equivalent to the RDBMS
 * userenv('LANG') function value.
 * @param P_DESCRIPTION Description of the approver group.
 * @param P_IS_STATIC Indicates whather the approver group has static or
 * dynamic, allowed values are 'Y' and 'N'.
 * @param P_APPROVAL_GROUP_ID Approver group that has to be updated.
 * @param P_QUERY_STRING Query to find the member when approver group
 * is dynamic.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of
 * the approver group to be updated. When the API completes, if p_validate is
 * false, it will be set to the new version number of the updated
 * approver group. If p_validate is true will be set to the same value which
 * was passed in.
 * @param P_START_DATE If p_validate is false, It is set to present date.
 * If p_validate is true, it is set null.
 * @param P_END_DATE It is the date up to, which the updated approver group is
 * effective. If p_validate is false, it is set to null.
 * If p_validate is true, it is set to the same date which was passed in.
 * @rep:displayname Update Ame Approver Group
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AME_APPROVER_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_ame_approver_group
  (p_validate                    in     boolean  default false
  ,p_approval_group_id           in     number
  ,p_language_code               in     varchar2 default
                                                 hr_api.userenv_lang
  ,p_description                 in     varchar2 default hr_api.g_varchar2
  ,p_is_static                   in     varchar2 default hr_api.g_varchar2
  ,p_query_string                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number       in out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< DELETE_AME_APPROVER_GROUP >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an approver group.
 *
 * Use this API when you need to delete an approver group.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No approver group config should exist for the group.
 *
 * <p><b>Post Success</b><br>
 * The approver group is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The approver group is not deleted and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_APPROVAL_GROUP_ID ID of the approver group that has to be deleted.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of the
 * approver group to be deleted. When the API completes, if p_validate,
 * is false, it will be set to the new version number of the deleted
 * approver group. If p_validate is true will be set to the same value
 * which was passed in.
 * @param P_START_DATE If p_validate is false, it is set to the date from
 * which the deleted approver group was effective. If p_validate is true,
 * it is set null.
 * @param P_END_DATE If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to null.
 * @rep:displayname Delete Ame Approver Group
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AME_APPROVER_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_approver_group
              (p_validate              in     boolean  default false
              ,p_approval_group_id     in     number
              ,p_object_version_number in out nocopy   number
              ,p_start_date               out nocopy   date
              ,p_end_date                 out nocopy   date
              );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_approver_group_config >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an approver group config with default values.
 *
 * Use this API when you need to create an approver group config with default
 * values.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * Valid approver group and valid transaction type should exist.
 *
 * <p><b>Post Success</b><br>
 * The approver group config is created.
 *
 * <p><b>Post Failure</b><br>
 * The approver group config is not created and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_APPLICATION_ID Transaction type for which approver group config
 * is created.
 * @param P_APPROVAL_GROUP_ID Uniquely identifies the approver group
 * for which config has to be created.
 * @param P_VOTING_REGIME The voting regime for the approver group config.
 * The valid values are in the lookup type AME_APG_VOTING_REGIME.
 * @param P_ORDER_NUMBER The order number of the group in the given
 * transaction type (used for parallelization).
 * @param P_OBJECT_VERSION_NUMBER If p_validate is false, then set to
 * the version number of the created approver group config. If p_validate is
 * true, then set to null.
 * @param P_START_DATE If p_validate is false, then set to the effective
 * start date for the created approver group config. If p_validate is true,
 * then set to null.
 * @param P_END_DATE It is the date up to, which the approver group config is
 * effective. If p_validate is false, then set to 31-Dec-4712. If p_validate
 *  is true, then set to null.
 * @rep:displayname Create Ame Approver Group Config
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AME_APPROVER_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_approver_group_config
                (
                 p_validate               in     boolean  default false
                ,p_approval_group_id      in     number
                ,p_application_id         in     number
                ,p_voting_regime          in     varchar2
                ,p_order_number           in     number   default null
                ,p_object_version_number     out nocopy   number
                ,p_start_date                out nocopy   date
                ,p_end_date                  out nocopy   date
                );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_approver_group_config >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 *This API deletes approver group config.
 *
 * Use this API when you need to delete an approver group config.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * A valid group and a valid transaction type should exist.
 *
 * The approver group should not be in use by any of the active rules in
 * the transaction type specified by the parameter P_APPLICATION_ID.
 *
 * <p><b>Post Success</b><br>
 * The approver group config is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The approver group config is not deleted and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_START_DATE If p_validate is false, it is set to the date from
 * which the deleted approver group config was effective.
 * If p_validate is true, it is set to null.
 * @param P_END_DATE If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to null.
 * @param P_APPLICATION_ID Transaction type for which the approver group config
 * is to be deleted.
 * @param P_APPROVAL_GROUP_ID Approver group for which config is deleted.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of
 * the approver group config to be deleted. When the API completes
 * if p_validate is false, will be set to the new version number of the
 * deleted approver group config. If p_validate is true will be set to the
 * same value which was passed in.
 * @rep:displayname Delete Ame Approver Group Config
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AME_APPROVER_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_approver_group_config
                (
                 p_validate               in     boolean  default false
                ,p_approval_group_id      in     number
                ,p_application_id         in     number
                ,p_object_version_number  in out nocopy   number
                ,p_start_date                out nocopy   date
                ,p_end_date                  out nocopy   date
                );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_approver_group_config >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 *This API updates an approver group config.
 *
 * Use this API when you need to update an approver group config.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * A valid approver group and transaction type should exist.
 *
 * <p><b>Post Success</b><br>
 * The approver group config is updated.
 *
 *
 * <p><b>Post Failure</b><br>
 * The approver group config is not updated and an error is raised.
 *
 *
 * @param P_APPLICATION_ID Transaction type for which approver group config
 * has to be modified.
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_APPROVAL_GROUP_ID ID of the approver group for which the
 * approver group config has to be modified.
 * @param P_VOTING_REGIME Voting regime for the approver group config.
 * @param P_ORDER_NUMBER Order number of the group config in the given
 * transaction type (used for parallelization).
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number
 * of the approver group config to be updated. When the API completes
 * if p_validate is false, will be set to the new version number of
 * the updated approver group config.
 * If p_validate is true will be set to the same value which was passed in.
 * @param P_START_DATE If p_validate is false, It is set to present date.
 * If p_validate is true, it is set to null.
 * @param P_END_DATE It is the date up to, which the updated
 * approver group config is effective. If p_validate is false, It is set
 * to 31-Dec-4712. If p_validate is true, it is set to null.
 * @rep:displayname Update Ame Approver Group config
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AME_APPROVER_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
 procedure update_approver_group_config
            (
             p_validate               in     boolean  default false
            ,p_approval_group_id      in     number
            ,p_application_id         in     number
            ,p_voting_regime          in     varchar2 default hr_api.g_varchar2
            ,p_order_number           in     varchar2 default hr_api.g_number
            ,p_object_version_number  in out nocopy   number
            ,p_start_date                out nocopy   date
            ,p_end_date                  out nocopy   date
            );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_approver_group_item >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API adds member to a static approver group.
 *
 * Use this API when you need to create approver group member. The member can
 * be either a wf_roles or a nested group.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * A approver group should exist.
 *
 * <p><b>Post Success</b><br>
 * Member is added to the approver group.
 *
 * <p><b>Post Failure</b><br>
 * Member is not added to the approver group and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_APPROVAL_GROUP_ID Approver group to which member is added.
 * @param P_PARAMETER_NAME IF equals 'wf_roles_name' then group member is
 * normal wf_roles_name.
 * If equals 'oam_group_id' then member is a nested group.
 * @param P_PARAMETER If P_PARAMETER_NAME equals wf_roles_name then
 * P_PARAMETER gives wf_roles_name. Otherwise specifies nested group.
 * @param P_APPROVAL_GROUP_ITEM_ID If p_is_static is false then uniquely
 * identifies the group member. If p_is_static true then returns null.
 * @param P_ORDER_NUMBER Group member order number.
 * @param P_OBJECT_VERSION_NUMBER If p_validate is false, then set to
 * the version number of the created approver group item. If p_validate is
 * true, then set to null.
 * @param P_START_DATE If p_validate is false, then set to the effective
 * start date for the created approver group member. If p_validate is true,
 * then set to null.
 * @param P_END_DATE It is the date up to, which the approver group member
 * is effective. If p_validate is false, then set to 31-Dec-4712.
 * If p_validate is true, then set to null.
 * @rep:displayname Create Ame Approver Group Item
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AME_APPROVER_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_approver_group_item
                (
                 p_validate               in     boolean  default false
                ,p_approval_group_id      in     number
                ,p_parameter_name         in     varchar2
                ,p_parameter              in     varchar2
                ,p_order_number           in     number
                ,p_approval_group_item_id    out nocopy   number
                ,p_object_version_number     out nocopy   number
                ,p_start_date                out nocopy   date
                ,p_end_date                  out nocopy   date
                );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_approver_group_item >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes group member from a static approver group. Member can be
 * wf_roles or nested group.
 *
 * Use this API when you need to delete a given approver group member.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * Valid approver group and valid approver group member should exist.
 *
 * <p><b>Post Success</b><br>
 * The approver group member is deleted from the approver group.
 *
 *
 * <p><b>Post Failure</b><br>
 * The approver group member is not deleted and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_APPROVAL_GROUP_ITEM_ID Group member that has to be deleted from
 * the approver group.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of
 * the approver group item to be deleted. When the API completes if p_validate
 * is false, will be set to the new version number of the deleted
 * approver group config. If p_validate is true will be set to the same value
 * which was passed in.
 * @param P_START_DATE If p_validate is false, it is set to the date
 * from which the deleted approver group item was effective.
 * If p_validate is true, it is set to null.
 * @param P_END_DATE If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to null.
 * @rep:displayname Delete Ame Approver Group Item
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AME_APPROVER_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_approver_group_item
                (
                 p_validate               in     boolean  default false
                ,p_approval_group_item_id in     number
                ,p_object_version_number  in out nocopy   number
                ,p_start_date                out nocopy   date
                ,p_end_date                  out nocopy   date
                );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_approver_group_item >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a given approver group member.
 *
 * Use this API when you need to update a given approver group member.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * A valid approver group should exist.
 *
 * <p><b>Post Success</b><br>
 * The approver group member is updated.
 *
 * <p><b>Post Failure</b><br>
 * The approver group member is not updated and an error is raised.
 *
 * @param P_VALIDATE If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param P_APPROVAL_GROUP_ITEM_ID ID of the approver group member that
 * has to be modified.
 * @param P_ORDER_NUMBER Group member order number.
 * @param P_OBJECT_VERSION_NUMBER Pass in the current version number of the
 * approver group item to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated
 * approver group item. If p_validate is true will be set to the same value
 * which was passed in.
 * @param P_START_DATE If p_validate is false, It is set to present date.
 * If p_validate is true, it is set to null.
 * @param P_END_DATE It is the date up to, which the updated approver group item
 * is effective. If p_validate is false, It is set to 31-Dec-4712.
 * If p_validate is true, it is set to null.
 * @rep:displayname Update Ame Approver Group Item
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AME_APPROVER_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_approver_group_item
            (
             p_validate               in     boolean  default false
            ,p_approval_group_item_id in     number
            ,p_order_number           in     varchar2 default hr_api.g_number
            ,p_object_version_number  in out nocopy   number
            ,p_start_date                out nocopy   date
            ,p_end_date                  out nocopy   date
            );

end AME_APPROVER_GROUP_API;

/
