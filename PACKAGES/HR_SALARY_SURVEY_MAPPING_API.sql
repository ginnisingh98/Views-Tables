--------------------------------------------------------
--  DDL for Package HR_SALARY_SURVEY_MAPPING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SALARY_SURVEY_MAPPING_API" AUTHID CURRENT_USER as
/* $Header: pessmapi.pkh 120.1 2005/10/02 02:24:45 aroussel $ */
/*#
 * This package contains APIs to create and manage mappings of salary survey
 * lines to current jobs and positions.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Salary Survey Mapping
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_mapping >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Salary Survey mapping.
 *
 * This API creates a new map between a salary survey line and an existing job
 * or position in the organizaton.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Position or Job must exist in the current organization. Also the salary
 * survey line must represent a valid salary survey line setup for the
 * organization.
 *
 * <p><b>Post Success</b><br>
 * Salary survey mapping is created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a salary survey mapping and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values,
 * applicable within the active date range. This date does not determine when
 * the changes take effect.
 * @param p_business_group_id {@rep:casecolumn
 * PER_SALARY_SURVEY_MAPPINGS.BUSINESS_GROUP_ID}
 * @param p_parent_id Identifies the parent job or position in the parent
 * table. Serves as a foreign key to either PER_JOBS or HR_ALL_POSITIONS_F
 * @param p_parent_table_name {@rep:casecolumn
 * PER_SALARY_SURVEY_MAPPINGS.PARENT_TABLE_NAME}
 * @param p_salary_survey_line_id Identifies the parent survey line to which
 * this mapping belongs. Serves as a foreign key to PER_SALARY_SURVEY_LINES.
 * @param p_location_id Identifies the location. Serves as a foreign key to
 * HR_LOCATIONS.
 * @param p_grade_id Identifies the grade. Serves as a foreign key to
 * PER_GRADES.
 * @param p_company_organization_id Identifies the company organization. Serves
 * as a foreign key to HR_ALL_ORGANIZATION_UNITS.
 * @param p_company_age_code Code to indicate the age band in the company.
 * Valid values identified by lookup type 'COMPANY_AGE'
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
 * @param p_salary_survey_mapping_id If p_validate is false, uniquely
 * identifies the newly created salary survey mapping. If p_validate is true,
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created salary survey mapping. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Salary Survey Mapping
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_mapping
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_parent_id                     in     number
  ,p_parent_table_name             in     varchar2
  ,p_salary_survey_line_id         in     number
  ,p_location_id                   in     number   default null
  ,p_grade_id                      in     number   default null
  ,p_company_organization_id       in     number   default null
  ,p_company_age_code              in     varchar2 default null
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
  ,p_salary_survey_mapping_id         out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_mapping >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * API to update a existing mappings.
 *
 * A Salary Survey mapping links a salary survey line with a work structure
 * object in your organization. This API allows you to update the object to
 * which the survey line is linked, and other details related to the mapped
 * object.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Survey mapping identified by the p_salary_survey_mapping_id must exist.
 *
 * <p><b>Post Success</b><br>
 * Survey line mapped to the specified object.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update a salary survey mapping and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values,
 * applicable within the active date range. This date does not determine when
 * the changes take effect.
 * @param p_location_id Identifies the location. Serves as a foreign key to
 * HR_LOCATIONS.
 * @param p_grade_id Identifies of the grade. Serves as a foreign key to
 * PER_GRADES.
 * @param p_company_organization_id Identifies the company oragnization. Serves
 * as a foreign key to HR_ALL_ORGANIZATION_UNITS.
 * @param p_company_age_code Code to indicate the age band in the company.
 * Valid values identified by lookup type 'COMPANY_AGE'
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
 * @param p_salary_survey_mapping_id Identifies the salary survey mapping on
 * which the update has to be done.
 * @param p_object_version_number Pass in the current version number of the
 * salary survey mapping to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated salary survey
 * mapping. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Salary Survey Mapping
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_mapping
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_location_id                   in     number
  ,p_grade_id                      in     number
  ,p_company_organization_id       in     number
  ,p_company_age_code              in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_salary_survey_mapping_id      in     number
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_mapping >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * API deletes the salary survey mapping identfied by the
 * p_salary_survey_mapping_id.
 *
 * A Salary Survey Mapping links a salary survey line with a work structure
 * object in your organization. This API allows you to delete the mapping
 * between a survey line and the work structure object.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Survey mapping identified by the p_salary_survey_mapping_id must exist.
 *
 * <p><b>Post Success</b><br>
 * The salary survey mapping row is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The Salary Survey Mapping row is not deleted, and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_salary_survey_mapping_id Identifies a salary survey mapping to be
 * deleted.
 * @param p_object_version_number Current version number of the salary survey
 * mapping to be deleted.
 * @rep:displayname Delete Salary Survey Mapping
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_mapping
  (p_validate                      in     boolean  default false
  ,p_salary_survey_mapping_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< mass_update >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API does bulk creation of salary survey mappings.
 *
 * The API fetches all the salary survey mappings for a given entity
 * (identified by position_id/job_id), then creates additional mappings for all
 * those survey lines that have characteristics similar to the new object.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent job or parent position must exist. You pass its identifiers to the
 * API.
 *
 * <p><b>Post Success</b><br>
 * If p_validate is false, then new mapping rows are created if a given job or
 * position has mappings, and the lines to which those mappings point have
 * duplicate lines with different effective dates. If p_validate is true, then
 * no new rows are created.
 *
 * <p><b>Post Failure</b><br>
 * No new rows are created, and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values,
 * applicable within the active date range. This date does not determine when
 * the changes take effect.
 * @param p_business_group_id The business group for the mapping. Serves as a
 * foreign key to HR_ALL_ORGANIZATIONS, identifying the business group.
 * @param p_job_id Identifies the parent job in the parent table.
 * @param p_position_id Identifies the parent position in the parent table.
 * @rep:displayname Mass Update
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure mass_update
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id		   in     number
  ,p_job_id                        in     number   default null
  ,p_position_id                   in     number   default null
  );
--
end hr_salary_survey_mapping_api;

 

/
