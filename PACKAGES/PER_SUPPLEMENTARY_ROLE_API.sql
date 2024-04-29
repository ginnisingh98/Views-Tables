--------------------------------------------------------
--  DDL for Package PER_SUPPLEMENTARY_ROLE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUPPLEMENTARY_ROLE_API" AUTHID CURRENT_USER as
/* $Header: perolapi.pkh 120.1.12010000.1 2008/07/28 05:45:40 appldev ship $ */
/*#
 * This package contains APIs that create and maintain supplementary roles.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Supplementary Role
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_supplementary_role >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a supplementary role for a person.
 *
 * Supplementary roles are activities a person does for the enterprise but
 * typically receives no renumeration for doing it, such as fire wardens or
 * health and safety officers. HRMS also uses supplementary roles to specify
 * union representatives within the workforce, so you can associate a
 * supplementary role with a representative body. Before you can give a person
 * a supplementary role, you must define the role itself by creating a job in
 * any job group other than the 'Default HR Job Group'. For more details on job
 * groups, see the package 'HR Job Group APIs'.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A person must exist and at least one job must have been created in any other
 * job group other than the 'Default HR Job Group'.
 *
 * <p><b>Post Success</b><br>
 * A supplementary role is created.
 *
 * <p><b>Post Failure</b><br>
 * A supplementary role is not created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_job_id Uniquely identifies the job associated with this
 * supplementary role.
 * @param p_job_group_id Uniquely identifies the job group the job is in.
 * Cannot be the 'Default HR Job Group'.
 * @param p_person_id Identifies the person for whom you create the
 * supplementary role record.
 * @param p_organization_id Uniquely identifies the representative body
 * associated with the role. The organization must be of the class
 * 'Representative Body'.
 * @param p_start_date The start date of the role.
 * @param p_end_date The end date of the role.
 * @param p_confidential_date The date on which a confidentiality agreement was
 * signed. (Some roles require a signed confidentiality agreement.)
 * @param p_emp_rights_flag Use this flag to indicate whether extended
 * employment rights are available for this role. Some roles grant additional
 * employment rights to the employee. For example, termination rules may be
 * different for union representatives. Valid values are 'Y' or 'N'.
 * @param p_end_of_rights_date The date that extended employment rights end. If
 * you terminate an employee before this date, the termination raises a
 * warning. You can only set this date if the p_emp_rights_flag is set to 'Y'.
 * @param p_primary_contact_flag Use this flag to indicate whether the person
 * is a primary contact for this role. (Many people can hold the same role.)
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
 * @param p_role_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_role_information1 Developer descriptive flexfield
 * @param p_role_information2 Developer descriptive flexfield
 * @param p_role_information3 Developer descriptive flexfield
 * @param p_role_information4 Developer descriptive flexfield
 * @param p_role_information5 Developer descriptive flexfield
 * @param p_role_information6 Developer descriptive flexfield
 * @param p_role_information7 Developer descriptive flexfield
 * @param p_role_information8 Developer descriptive flexfield
 * @param p_role_information9 Developer descriptive flexfield
 * @param p_role_information10 Developer descriptive flexfield
 * @param p_role_information11 Developer descriptive flexfield
 * @param p_role_information12 Developer descriptive flexfield
 * @param p_role_information13 Developer descriptive flexfield
 * @param p_role_information14 Developer descriptive flexfield
 * @param p_role_information15 Developer descriptive flexfield
 * @param p_role_information16 Developer descriptive flexfield
 * @param p_role_information17 Developer descriptive flexfield
 * @param p_role_information18 Developer descriptive flexfield
 * @param p_role_information19 Developer descriptive flexfield
 * @param p_role_information20 Developer descriptive flexfield
 * @param p_role_id If p_validate is false, uniquely identifies the
 * supplementary role created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created supplementary role. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Supplementary Role
 * @rep:category BUSINESS_ENTITY PER_SUPPLEMENTARY_ROLE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_supplementary_role
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_job_id                        in     number
  ,p_job_group_id                  in     number
  ,p_person_id                     in     number
  ,p_organization_id               in     number   default null
  ,p_start_date                    in     date
  ,p_end_date                      in     date     default null
  ,p_confidential_date             in     date     default null
  ,p_emp_rights_flag               in     varchar2 default 'N'
  ,p_end_of_rights_date            in     date     default null
  ,p_primary_contact_flag          in     varchar2 default 'N'
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_role_information_category      in     varchar2 default null
  ,p_role_information1              in     varchar2 default null
  ,p_role_information2              in     varchar2 default null
  ,p_role_information3              in     varchar2 default null
  ,p_role_information4              in     varchar2 default null
  ,p_role_information5              in     varchar2 default null
  ,p_role_information6              in     varchar2 default null
  ,p_role_information7              in     varchar2 default null
  ,p_role_information8              in     varchar2 default null
  ,p_role_information9              in     varchar2 default null
  ,p_role_information10             in     varchar2 default null
  ,p_role_information11             in     varchar2 default null
  ,p_role_information12             in     varchar2 default null
  ,p_role_information13             in     varchar2 default null
  ,p_role_information14             in     varchar2 default null
  ,p_role_information15             in     varchar2 default null
  ,p_role_information16             in     varchar2 default null
  ,p_role_information17             in     varchar2 default null
  ,p_role_information18             in     varchar2 default null
  ,p_role_information19             in     varchar2 default null
  ,p_role_information20             in     varchar2 default null
  ,p_role_id                        out nocopy number
  ,p_object_version_number          out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_supplementary_role >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a supplementary role for a person.
 *
 * Supplementary roles are activities a person does for the enterprise but
 * typically receives no renumeration for doing it, such as fire wardens or
 * health and safety officers. HRMS also uses supplementary roles to specify
 * union representatives within the workforce, so you can associate a
 * supplementary role with a representative body. Before you can give a person
 * a supplementary role, you must define the role itself by creating a job in
 * any job group other than the 'Default HR Job Group'. For more details on job
 * groups, see the package 'HR Job Group APIs'.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The supplementary role must exist for the person.
 *
 * <p><b>Post Success</b><br>
 * The supplementary role will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The supplementary role will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_role_id Uniquely identifies the supplementary role to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * supplementary role to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated supplementary
 * role If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_start_date The start date of the role.
 * @param p_end_date The end date of the role.
 * @param p_confidential_date The date on which a confidentiality agreement was
 * signed. (Some roles require a signed confidentiality agreement.)
 * @param p_emp_rights_flag Use this flag to indicate whether extended
 * employment rights are available for this role. Some roles grant additional
 * employment rights to the employee. For example, termination rules may be
 * different for union representatives. Valid values are 'Y' or 'N'.
 * @param p_end_of_rights_date The date that extended employment rights end. If
 * you terminate an employee before this date, the termination raises a
 * warning. You can only set this date if the p_emp_rights_flag is set to 'Y'.
 * @param p_primary_contact_flag Use this flag to indicate whether the person
 * is a primary contact for this role. (Many people can hold the same role.)
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
 * @param p_role_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_role_information1 Developer descriptive flexfield
 * @param p_role_information2 Developer descriptive flexfield
 * @param p_role_information3 Developer descriptive flexfield
 * @param p_role_information4 Developer descriptive flexfield
 * @param p_role_information5 Developer descriptive flexfield
 * @param p_role_information6 Developer descriptive flexfield
 * @param p_role_information7 Developer descriptive flexfield
 * @param p_role_information8 Developer descriptive flexfield
 * @param p_role_information9 Developer descriptive flexfield
 * @param p_role_information10 Developer descriptive flexfield
 * @param p_role_information11 Developer descriptive flexfield
 * @param p_role_information12 Developer descriptive flexfield
 * @param p_role_information13 Developer descriptive flexfield
 * @param p_role_information14 Developer descriptive flexfield
 * @param p_role_information15 Developer descriptive flexfield
 * @param p_role_information16 Developer descriptive flexfield
 * @param p_role_information17 Developer descriptive flexfield
 * @param p_role_information18 Developer descriptive flexfield
 * @param p_role_information19 Developer descriptive flexfield
 * @param p_role_information20 Developer descriptive flexfield
 * @param p_old_end_date This is used in internal processing and should not be
 * passed into the API.
 * @rep:displayname Update Supplementary Role
 * @rep:category BUSINESS_ENTITY PER_SUPPLEMENTARY_ROLE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_supplementary_role
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_role_id                       in     number
  ,p_object_version_number         in out nocopy number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_confidential_date             in     date     default hr_api.g_date
  ,p_emp_rights_flag               in     varchar2 default hr_api.g_varchar2
  ,p_end_of_rights_date            in     date     default hr_api.g_date
  ,p_primary_contact_flag          in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_role_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_role_information1              in     varchar2 default hr_api.g_varchar2
  ,p_role_information2              in     varchar2 default hr_api.g_varchar2
  ,p_role_information3              in     varchar2 default hr_api.g_varchar2
  ,p_role_information4              in     varchar2 default hr_api.g_varchar2
  ,p_role_information5              in     varchar2 default hr_api.g_varchar2
  ,p_role_information6              in     varchar2 default hr_api.g_varchar2
  ,p_role_information7              in     varchar2 default hr_api.g_varchar2
  ,p_role_information8              in     varchar2 default hr_api.g_varchar2
  ,p_role_information9              in     varchar2 default hr_api.g_varchar2
  ,p_role_information10             in     varchar2 default hr_api.g_varchar2
  ,p_role_information11             in     varchar2 default hr_api.g_varchar2
  ,p_role_information12             in     varchar2 default hr_api.g_varchar2
  ,p_role_information13             in     varchar2 default hr_api.g_varchar2
  ,p_role_information14             in     varchar2 default hr_api.g_varchar2
  ,p_role_information15             in     varchar2 default hr_api.g_varchar2
  ,p_role_information16             in     varchar2 default hr_api.g_varchar2
  ,p_role_information17             in     varchar2 default hr_api.g_varchar2
  ,p_role_information18             in     varchar2 default hr_api.g_varchar2
  ,p_role_information19             in     varchar2 default hr_api.g_varchar2
  ,p_role_information20             in     varchar2 default hr_api.g_varchar2
  ,p_old_end_date                   in     date     default hr_api.g_date -- fix 1370960
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_supplementary_role >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a supplementary role for a person.
 *
 * Supplementary roles are activities a person does for the enterprise but
 * typically receives no renumeration for doing it, such as fire wardens or
 * health and safety officers. HRMS also uses supplementary roles to specify
 * union representatives within the workforce, so you can associate a
 * supplementary role with a representative body. Before you can give a person
 * a supplementary role, you must define the role itself by creating a job in
 * any job group other than the 'Default HR Job Group'. For more details on job
 * groups, see the package 'HR Job Group APIs'.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The supplementary role must exist for the person.
 *
 * <p><b>Post Success</b><br>
 * The supplementary role is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The supplementary role is not deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_id Uniquely identifies the supplementary role to be deleted.
 * @param p_object_version_number Current version number of the supplementary
 * role to be deleted.
 * @rep:displayname Delete Supplementary Role
 * @rep:category BUSINESS_ENTITY PER_SUPPLEMENTARY_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_supplementary_role
  (p_validate                      in     boolean  default false
  ,p_role_id                       in     number
  ,p_object_version_number         in     number
  );
--
end per_supplementary_role_api;

/
