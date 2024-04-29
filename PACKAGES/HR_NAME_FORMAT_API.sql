--------------------------------------------------------
--  DDL for Package HR_NAME_FORMAT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NAME_FORMAT_API" AUTHID CURRENT_USER as
/* $Header: hrnmfapi.pkh 120.7.12010000.2 2008/08/06 08:44:08 ubhat ship $ */
/*#
 * This package contains enhancement for name format functionality.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Name Format
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_name_format >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new name format.
 *
 * This procedure will provide an interface to create named format masks for
 * a legislation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human resources.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The API will create named format masks for a legislation.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the name format and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date of the change of status.
 * @param p_format_name User identifier for name format.
 * @param p_user_format_choice User Format Choice of the name format mask
 * (G or L).
 * @param p_format_mask Actual mask used to create names according to
 * format.
 * @param p_legislation_code Legislation applicable for format.
 * @param p_name_format_id If p_validate is set to false,then this uniquely
 * identifies the new record, else it contains null.
 * @param p_object_version_number If p_validate is set to false,then
 * this uniquely identifies the person name format record else it contains null.
 * @rep:displayname Create Name Format
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure create_name_format
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_format_name                   in     varchar2
  ,p_user_format_choice            in     varchar2
  ,p_format_mask                   in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_name_format_id                   out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_name_format >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Name format.
 *
 * This procedure will provide an interface to update named format masks for
 * a legislation. The name, legislation and User Format Choice themselves
 * will not be updateable.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human resources.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The API will update named format masks for a legislation.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the name format and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date of the change of status.
 * @param p_name_format_id Format name id.
 * @param p_format_mask Actual mask used to update  names according to
 * format.
 * @param p_object_version_number If p_validate is set to false,then
 * this uniquely identifies the person name format record else it contains null.
 * @rep:displayname Update Name Format
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_name_format
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_name_format_id                in     number
  ,p_format_mask                   in     varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_name_format >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Name format.
 *
 * This procedure will provide an interface to delete named format masks for
 * a legislation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human resources.
 *
 * <p><b>Prerequisites</b><br>
 * None.
 *
 * <p><b>Post Success</b><br>
 * The API will delete named format masks for a legislation.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the name format and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_name_format_id Format name id.
 * @param p_object_version_number If p_validate is set to false,then
 * this uniquely identifies the person name format record else it contains null.
 * @rep:displayname Delete Name Format
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_name_format
  (p_validate                      in     boolean  default false
  ,p_name_format_id                in     number
  ,p_object_version_number         in out nocopy number
  );
--
--
end hr_name_format_api;

/
