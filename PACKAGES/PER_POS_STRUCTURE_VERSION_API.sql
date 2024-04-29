--------------------------------------------------------
--  DDL for Package PER_POS_STRUCTURE_VERSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_STRUCTURE_VERSION_API" AUTHID CURRENT_USER AS
/* $Header: pepsvapi.pkh 120.2 2005/10/22 01:25:03 aroussel noship $ */
/*#
 * This package contains APIs that create and maintain Position Hierarchy
 * Versions.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Position Hierarchy Version
*/
g_package            VARCHAR2(33) := '  per_pos_structure_version_api.';
--
--------------------------------------------------------------------------------
g_dummy number(1);      -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_pos_structure_version >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a position hierarchy version.
 *
 * It creates an position hierarchy version for a given position hierarchy. The
 * process initializes the version number to 1.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Position hierarchy should exist.
 *
 * <p><b>Post Success</b><br>
 * A version of position hierarchy will be created.
 *
 * <p><b>Post Failure</b><br>
 * Position hierarchy version will not get created and error will be returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_position_structure_id Uniquely identifies the position hierarchy
 * for which the process creates a version.
 * @param p_date_from The date on which this position hierarchy version takes
 * effect.
 * @param p_version_number The version number of the position hierarchy.
 * @param p_copy_structure_version_id Uniquely identifies a previously existing
 * position hierarchy version (if any) the process copies as the basis for the
 * created version.
 * @param p_date_to The date the created version of the position hierarchy is
 * no longer in effect.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_pos_structure_version_id If p_validate is false, then this uniquely
 * identifies the created position hierarchy version. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Position Hierarchy Version. If p_validate is
 * true, then the value will be null.
 * @param p_gap_warning The process sets to 'true' if there is a gap between
 * the effective date ranges of position hierarchy versions.
 * @rep:displayname Create Position Hierarchy Version
 * @rep:category BUSINESS_ENTITY PER_POSITION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_pos_structure_version
  (p_validate                      in     boolean  default false
  ,p_effective_date                 in     date
  ,p_position_structure_id      in     number
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number   default null
  ,p_date_to                        in     date     default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
  ,p_pos_structure_version_id          out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_gap_warning                       out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_pos_structure_version >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a position hierarchy version.
 *
 * This procedure will update the position hierarchy version for a given
 * position hierarchy. The system generates a version number for each new row,
 * which Increments by one with each update.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Position hierarchy version should exist.
 *
 * <p><b>Post Success</b><br>
 * Position hierarchy version gets updated.
 *
 * <p><b>Post Failure</b><br>
 * Position hierarchy version is not updated and error returned.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_date_from The date this version of the position hierarchy takes
 * effect.
 * @param p_version_number The version number of the position hierarchy
 * @param p_copy_structure_version_id Uniquely identifies a previously existing
 * position hierarchy version (if any) the process copies as the basis for the
 * created version.
 * @param p_date_to The date this version of the position hierarchy is no
 * longer in effect.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_pos_structure_version_id Identifies the Position hierarchy version
 * record to modify.
 * @param p_object_version_number Pass in the current version number of the
 * Position Hierarchy Version to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Position Hierarchy Version. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_gap_warning The process sets to 'true' if there is a gap between
 * the effective date ranges of position hierarchy versions.
 * @rep:displayname Update Position Hierarchy Version
 * @rep:category BUSINESS_ENTITY PER_POSITION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_pos_structure_version
  (p_validate                      in     boolean  default false
  ,p_effective_date                 in     date
  ,p_date_from                      in     date
  ,p_version_number                 in     number
  ,p_copy_structure_version_id      in     number   default hr_api.g_number
  ,p_date_to                        in     date     default hr_api.g_date
  ,p_request_id                     in     number   default hr_api.g_number
  ,p_program_application_id         in     number   default hr_api.g_number
  ,p_program_id                     in     number   default hr_api.g_number
  ,p_program_update_date            in     date     default hr_api.g_date
  ,p_pos_structure_version_id       in     number
  ,p_object_version_number          in out nocopy number
  ,p_gap_warning                       out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_pos_structure_version >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a position hierarchy version.
 *
 * This procedure deletes an position hierarchy version for a given position
 * hierarchy.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Position Hierarchy Version should exist.
 *
 * <p><b>Post Success</b><br>
 * Position Hierarchy Version deleted.
 *
 * <p><b>Post Failure</b><br>
 * Position Hierarchy Version not deleted and error raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pos_structure_version_id Identifies the Position Hierarchy Version
 * record to be deleted.
 * @param p_object_version_number Current version number of the position
 * hierarchy version to be deleted.
 * @rep:displayname Delete Position Hierarchy Version
 * @rep:category BUSINESS_ENTITY PER_POSITION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_pos_structure_version
   (  p_validate                     IN BOOLEAN default false
     ,p_pos_structure_version_id     IN number
     ,p_object_version_number        IN number );

--
--
END per_pos_structure_version_api;

 

/
