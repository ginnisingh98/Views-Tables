--------------------------------------------------------
--  DDL for Package HR_API_HOOK_CALL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_API_HOOK_CALL_API" AUTHID CURRENT_USER as
/* $Header: peahcapi.pkh 120.3 2006/09/13 12:34:17 sgelvi noship $ */
/*#
 * This package contains APIs for maintaining User Hook Calls.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname API Hook Call
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_api_hook_call >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a User Hook Call.
 *
 * Creates user hook call information in the HR_API_HOOK_CALLS table. The user
 * hook call specifies which extra logic, package procedures or formula should
 * be called from the API hook points. Each row should be a child of a parent
 * API Hook which already exists on the HR_API_HOOKS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * An API Hook must have been created so that the Hook Call can be attached to
 * it.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates the hook call.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the hook call and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_api_hook_id Acts as the foreign key to the HR_API_HOOKS table.
 * @param p_api_hook_call_type The type of the hook call. Can only be set to
 * 'PP' for the first version.
 * @param p_sequence When more than one row exists for the same API_HOOK_ID,
 * the sequence will affect the order of the hook calls (low numbers will be
 * processed first).
 * @param p_enabled_flag Determines whether the hook call is enabled or not.
 * Valid values are defined by 'YES_NO' lookup type.
 * @param p_call_package Name of the database package that the hook package
 * should call to create.
 * @param p_call_procedure Name of the procedure within the call package that
 * the hook package should call.
 * @param p_api_hook_call_id If p_validate is false, then this uniquely
 * identifies the api hook call created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created hook call. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create API Hook Call
 * @rep:category BUSINESS_ENTITY HR_USER_HOOK
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_id                  in     number,
   p_api_hook_call_type           in     varchar2,
   p_sequence                     in     number,
   p_enabled_flag                 in     varchar2,
   p_call_package                 in     varchar2  default null,
   p_call_procedure               in     varchar2  default null,
   p_api_hook_call_id             out nocopy    number,
   p_object_version_number        out nocopy    number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_api_hook_call >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a User Hook Call.
 *
 * Only hook calls which have been created using the create_api_hook_call, can
 * be deleted. Any hook calls which are pre-seeded by legislation groups cannot
 * be deleted using this API. These hook calls have a set legislation code.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A hook call id with a legislation code set to null. The object version
 * number of the hook call id.
 *
 * <p><b>Post Success</b><br>
 * The API hook call will successfully be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the hook call and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_api_hook_call_id Unique identifier for the hook call to be deleted.
 * @param p_object_version_number Current version number of the API Hook call
 * to be deleted.
 * @rep:displayname Delete API Hook Call
 * @rep:category BUSINESS_ENTITY HR_USER_HOOK
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_api_hook_call
  (p_validate                           in     boolean  default false,
   p_api_hook_call_id                   in     number,
   p_object_version_number              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_api_hook_call >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a User Hook Call.
 *
 * A hook call cannot be updated if the LEGISLATION_CODE is not null. Only hook
 * calls with null legislation codes can be updated with this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * The API hook call id with a null legislation code.
 *
 * <p><b>Post Success</b><br>
 * The hook call will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The hook call will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_api_hook_call_id Unique identifier for the hook call to be updated.
 * @param p_sequence When more than one row exists for the same API_HOOK_ID,
 * the sequence will affect the order of the hook calls (low numbers will be
 * processed first).
 * @param p_enabled_flag Determines whether the hook call is enabled or not.
 * Valid values are defined by 'YES_NO' lookup type.
 * @param p_call_package Name of the database package that the hook package
 * should call to update.
 * @param p_call_procedure Name of the procedure within the call package that
 * the API hook should call.
 * @param p_object_version_number Pass in the current version number of the HR
 * API Hook Call to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated HR API Hook Call. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update API Hook Call
 * @rep:category BUSINESS_ENTITY HR_USER_HOOK
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_call_id             in     number,
   p_sequence                     in     number    default hr_api.g_number,
   p_enabled_flag                 in     varchar2  default hr_api.g_varchar2,
   p_call_package                 in     varchar2  default hr_api.g_varchar2,
   p_call_procedure               in     varchar2  default hr_api.g_varchar2,
   p_object_version_number        in out nocopy    number) ;

end hr_api_hook_call_api;

/
