--------------------------------------------------------
--  DDL for Package HR_KI_UI_CONTEXTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_UI_CONTEXTS_API" AUTHID CURRENT_USER as
/* $Header: hrucxapi.pkh 120.1 2006/10/12 14:31:44 avarri noship $ */
/*#
 * This package contains APIs that maintain definition for the HR Knowledge
 * Integration UI Contexts.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Knowledge Integration UI Context
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_ui_context >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This api creates a UI Context.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * A valid user_interface_id, label, location should be entered
 *
 * <p><b>Post Success</b><br>
 * UI context for the given user interface will be successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * UI Context will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_label This specifies the label of UI.
 * @param p_location This specifies the location of field in UI.
 * It should be in the format of pageLayoutName.RegionName.
 * For example, createEmployeePageLayout.EmployeeDetailsRN.
 * @param p_user_interface_id This specifies the unique identifier of the
 * user interface.
 * @param p_ui_context_id If p_validate is false, then this uniquely
 * identifies the created ui context. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then it is set to
 * the version number of the created ui context. If p_validate is true, then
 * it is set to null.
 * @rep:displayname Create UI Context
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure CREATE_UI_CONTEXT
  (  p_validate                      in     boolean  default false
    ,p_label                         in     varchar2
    ,p_location                      in     varchar2
    ,p_user_interface_id             in     number
    ,p_ui_context_id                 out    nocopy   number
    ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_ui_context >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This api deletes a UI Context.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with all products in the HRMS Product Family.
 *
 * <p><b>Prerequisites</b><br>
 * ui_context_id and object_version_number should be valid.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the UI Context successfully.
 *
 * <p><b>Post Failure</b><br>
 * UI Context will not be deleted and error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_ui_context_id This uniquely identifies the ui context to be deleted.
 * @param p_object_version_number Current version number of the ui context
 * to be deleted.
 * @rep:displayname Delete UI Context
 * @rep:category BUSINESS_ENTITY HR_KI_SYSTEM
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure DELETE_UI_CONTEXT
(
   p_validate                 in boolean         default false
  ,p_ui_context_id            in number
  ,p_object_version_number    in number
);
--
end HR_KI_UI_CONTEXTS_API;

 

/
