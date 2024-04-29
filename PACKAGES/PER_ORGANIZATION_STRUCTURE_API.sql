--------------------------------------------------------
--  DDL for Package PER_ORGANIZATION_STRUCTURE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORGANIZATION_STRUCTURE_API" AUTHID CURRENT_USER AS
/* $Header: peorsapi.pkh 120.2 2005/10/22 01:24:14 aroussel noship $ */
/*#
 * This package contains APIs that create and maintain organization
 * hierarchies.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Organization Hierarchy
*/
 g_package            VARCHAR2(33) := '  per_organization_structure_api.';
--
-------------------------------------------------------------------------------
g_dummy number(1);      -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
-------------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_org_struct_and_def_ver >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure creates an organization hierarchy and organization hierarchy
 * version.
 *
 * An organization structure show reporting lines or other relationships. You
 * can use hierarchies for reporting and for controlling access to Oracle HRMS
 * information.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * Organization hierarchy and version will be created.
 *
 * <p><b>Post Failure</b><br>
 * Organization hierarchy and version will not be created and an error will
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_name The name of the organization hierarchy the process creates.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the organization hierarchy.
 * @param p_comments Comment Text
 * @param p_primary_structure_flag Flag specifying if the created organization
 * hierarchy is the primary organization hierarchy for the business group.
 * Valid values are "Y" and 'N'.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_position_control_structure_f Position control structure flag
 * @param p_organization_structure_id If p_validate is false, then this
 * uniquely identifies the organization hierarchy record created. If p_validate
 * is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Organization Hierarchy. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Organizatiion Hierarchy and Version
 * @rep:category BUSINESS_ENTITY PER_ORGANIZATION_HIERARCHY
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_org_struct_and_def_ver
  (p_validate                       IN     BOOLEAN     DEFAULT false
  ,p_effective_date                 in     date
  ,p_name                           in     varchar2
  ,p_business_group_id              in     number      default null
  ,p_comments                       in     varchar2    default null
  ,p_primary_structure_flag         in     varchar2    default 'N'
  ,p_request_id                     in     number      default null
  ,p_program_application_id         in     number      default null
  ,p_program_id                     in     number      default null
  ,p_program_update_date            in     date        default null
  ,p_attribute_category             in     varchar2    default null
  ,p_attribute1                     in     varchar2    default null
  ,p_attribute2                     in     varchar2    default null
  ,p_attribute3                     in     varchar2    default null
  ,p_attribute4                     in     varchar2    default null
  ,p_attribute5                     in     varchar2    default null
  ,p_attribute6                     in     varchar2    default null
  ,p_attribute7                     in     varchar2    default null
  ,p_attribute8                     in     varchar2    default null
  ,p_attribute9                     in     varchar2    default null
  ,p_attribute10                    in     varchar2    default null
  ,p_attribute11                    in     varchar2    default null
  ,p_attribute12                    in     varchar2    default null
  ,p_attribute13                    in     varchar2    default null
  ,p_attribute14                    in     varchar2    default null
  ,p_attribute15                    in     varchar2    default null
  ,p_attribute16                    in     varchar2    default null
  ,p_attribute17                    in     varchar2    default null
  ,p_attribute18                    in     varchar2    default null
  ,p_attribute19                    in     varchar2    default null
  ,p_attribute20                    in     varchar2    default null
  ,p_position_control_structure_f   in     varchar2    default 'N'
  ,p_organization_structure_id         out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_organization_structure >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Organization Hierarchy.
 *
 * An organization structure show reporting lines or other relationships. You
 * can use hierarchies for reporting and for controlling access to Oracle HRMS
 * information.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * None
 *
 * <p><b>Post Success</b><br>
 * Organization hierarchy will be created.
 *
 * <p><b>Post Failure</b><br>
 * Organization hierarchy will not be created and an error will raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_name The name of the organization hierarchy.
 * @param p_business_group_id Uniquely identifies the business group associated
 * with the created organization hierarchy.
 * @param p_comments Comment text.
 * @param p_primary_structure_flag Flag specifying if the created organization
 * hierarchy is the primary organization hierarchy for the business group.
 * Valid values are "Y" and 'N'.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_position_control_structure_f Position control structure flag
 * @param p_organization_structure_id If p_validate is false, then this
 * uniquely identifies the organization hierarchy record created. If p_validate
 * is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Organization Hierarchy. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Organization Hierarchy
 * @rep:category BUSINESS_ENTITY PER_ORGANIZATION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_organization_structure
  (p_validate                       IN     BOOLEAN    default false
  ,p_effective_date                 in     date
  ,p_name                           in     varchar2
  ,p_business_group_id              in     number     default null
  ,p_comments                       in     varchar2   default null
  ,p_primary_structure_flag         in     varchar2   default 'N'
  ,p_request_id                     in     number     default null
  ,p_program_application_id         in     number     default null
  ,p_program_id                     in     number     default null
  ,p_program_update_date            in     date       default null
  ,p_attribute_category             in     varchar2   default null
  ,p_attribute1                     in     varchar2   default null
  ,p_attribute2                     in     varchar2   default null
  ,p_attribute3                     in     varchar2   default null
  ,p_attribute4                     in     varchar2   default null
  ,p_attribute5                     in     varchar2   default null
  ,p_attribute6                     in     varchar2   default null
  ,p_attribute7                     in     varchar2   default null
  ,p_attribute8                     in     varchar2   default null
  ,p_attribute9                     in     varchar2   default null
  ,p_attribute10                    in     varchar2   default null
  ,p_attribute11                    in     varchar2   default null
  ,p_attribute12                    in     varchar2   default null
  ,p_attribute13                    in     varchar2   default null
  ,p_attribute14                    in     varchar2   default null
  ,p_attribute15                    in     varchar2   default null
  ,p_attribute16                    in     varchar2   default null
  ,p_attribute17                    in     varchar2   default null
  ,p_attribute18                    in     varchar2   default null
  ,p_attribute19                    in     varchar2   default null
  ,p_attribute20                    in     varchar2   default null
  ,p_position_control_structure_f   in     varchar2   default 'N'
  ,p_organization_structure_id         out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_organization_structure >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an organization hierarchy.
 *
 * An organization structure show reporting lines or other relationships. You
 * can use hierarchies for reporting and for controlling access to Oracle HRMS
 * information.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization hierarchy must exist.
 *
 * <p><b>Post Success</b><br>
 * Organization hierarchy is updated.
 *
 * <p><b>Post Failure</b><br>
 * Organization hierarchy will not be updated and an error will raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_organization_structure_id Identifies the organization hierarchy
 * record to modify.
 * @param p_name Name of organization hierarchy
 * @param p_comments Comment text.
 * @param p_primary_structure_flag Flag specifying if the created organization
 * hierarchy is the primary organization hierarchy for the business group.
 * Valid values are "Y" and 'N'.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_position_control_structure_f Position control structure flag
 * @param p_object_version_number Pass in the current version number of the
 * organization hierarchy to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated organization
 * hierarchy. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Organization Hierarchy
 * @rep:category BUSINESS_ENTITY PER_ORGANIZATION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_organization_structure
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_organization_structure_id    in     number
  ,p_name                         in     varchar2 default  hr_api.g_varchar2
  ,p_comments                     in     varchar2 default  hr_api.g_varchar2
  ,p_primary_structure_flag       in     varchar2 default  hr_api.g_varchar2
  ,p_request_id                   in     number   default  hr_api.g_number
  ,p_program_application_id       in     number   default  hr_api.g_number
  ,p_program_id                   in     number   default  hr_api.g_number
  ,p_program_update_date          in     date     default  hr_api.g_date
  ,p_attribute_category           in     varchar2 default  hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default  hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default  hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default  hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default  hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default  hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default  hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default  hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default  hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default  hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default  hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default  hr_api.g_varchar2
  ,p_position_control_structure_f in     varchar2 default  hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_organization_structure >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a specified organization hierarchy.
 *
 * An organization structure show reporting lines or other relationships. You
 * can use hierarchies for reporting and for controlling access to Oracle HRMS
 * information.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization must exist.
 *
 * <p><b>Post Success</b><br>
 * Organization hierarchy is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Organization hierarchy will not be deleted and an error will raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_organization_structure_id Identifies the organization hierarchy
 * record to be deleted.
 * @param p_object_version_number Current version number of the organization
 * hierarchy to be deleted.
 * @rep:displayname Delete Organization Hierarchy
 * @rep:category BUSINESS_ENTITY PER_ORGANIZATION_HIERARCHY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_organization_structure
   (  p_validate                     IN BOOLEAN default false
     ,p_organization_structure_id    IN number
     ,p_object_version_number        IN number );
--
--
END per_organization_structure_api;

 

/
