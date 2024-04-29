--------------------------------------------------------
--  DDL for Package PQH_CORPS_DEFINITIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CORPS_DEFINITIONS_API" AUTHID CURRENT_USER as
/* $Header: pqcpdapi.pkh 120.1 2005/10/02 02:26:32 aroussel $ */
/*#
 * This package contains APIs to validate, create, update and delete corps
 * definition records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname CORPS Definition for France
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_corps_definition >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new corps definition record.
 *
 * Corps is a French public sector specific work structure that captures the
 * career progression related information for a civil servant joining the
 * Public Sector Organization. Details recorded include the benefits program to
 * which the corps is linked, category, type of public sector etc. It validates
 * corps name for uniqueness. The record is created in PQH_CORPS_DEFINITIONS
 * table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Benefits program representing the grade ladder must exist as of the
 * effective date.
 *
 * <p><b>Post Success</b><br>
 * A new corps definition record is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * A corps definition record is not created in the database and an error is
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_corps_definition_id The process returns the unique corps definition
 * identifier generated as the primary key for the new record
 * @param p_business_group_id Identifies the business group identifier for
 * which the corps definition record is being created
 * @param p_name Unique name for the corps.
 * @param p_status_cd Status of the corps as identified by lookup type
 * 'PQH_CORPS_STATUS'
 * @param p_retirement_age Retirement age of the employees on this corps. Its
 * value is between 40 and 80
 * @param p_category_cd Category code of the corps which will indicate its
 * level of responsibility and management within the public sector. Valid
 * values are defined by 'PQH_CORPS_CATEGORY' lookup type
 * @param p_corps_type_cd Type of the corps. Valid values are defined by
 * 'PQH_CORPS_TYPE' lookup type
 * @param p_date_from {@rep:casecolumn PQH_CORPS_DEFINITIONS.DATE_FROM}
 * @param p_date_to {@rep:casecolumn PQH_CORPS_DEFINITIONS.DATE_TO}
 * @param p_recruitment_end_date Identifies the end date of recruitment for the
 * corps. It should be between start date and end date
 * @param p_starting_grade_step_id The starting grade step for the civil
 * servant on this corps. It should be the identifier of a step in existence as
 * of the effective date
 * @param p_type_of_ps Type of the public sector organization. Valid values are
 * defined by 'FR_PQH_ORG_CATEGORY' lookup type
 * @param p_task_desc {@rep:casecolumn PQH_CORPS_DEFINITIONS.TASK_DESC}
 * @param p_secondment_threshold Percentage of civil servants in this corps,
 * who can be placed on secondment. Value should be between 0 and 100
 * @param p_normal_hours Normal working hours for civil servants on this corps
 * in terms of the unit given in normal_frequency parameter
 * @param p_normal_hours_frequency Unit of time measurement in terms of which
 * normal working hour for civil servants on this corps is provided. This value
 * is mandatory if the normal_hours parameter has a not null value. Valid
 * values are identified by 'FREQUENCY' lookup type.
 * @param p_minimum_hours Minimum working hours for civil servants on this
 * corps in terms of the unit given in minimum_frequency parameter. Should not
 * be greater than the normal working hours.
 * @param p_minimum_hours_frequency Unit of time measurement in terms of which
 * minimum working hour for civil servants on this corps is provided. This
 * value is mandatory if the minimum_hours parameter has a not null value.
 * Valid values are identified by lookup type 'FREQUENCY'.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_object_version_number If p_validate is false, the process returns
 * the version number of the created corps definition record. If p_validate is
 * true, it returns null
 * @param p_primary_prof_field_id Primary professional field shared type
 * identifier. Valid values are defined by 'PER_SHARED_TYPES' table.
 * @param p_starting_grade_id The starting grade step for the civil servant on
 * this corps. It should be the identifier of a step in existence as of the
 * effective date
 * @param p_ben_pgm_id {@rep:casecolumn PQH_CORPS_DEFINITIONS.BEN_PGM_ID}
 * @param p_probation_period {@rep:casecolumn
 * PQH_CORPS_DEFINITIONS.PROBATION_PERIOD}
 * @param p_probation_units Units for probation period duration. Valid values
 * are identified by lookup type 'PROC_PERIOD_TYPE'.
 * @rep:displayname Create CORPS Definition
 * @rep:category BUSINESS_ENTITY PQH_FR_CORPS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_corps_definition
(
  p_validate                      in     boolean   default false
  ,p_effective_date               in     date
  ,p_corps_definition_id          out nocopy    number
  ,p_business_group_id            in     number
  ,p_name                         in    varchar2
  ,p_status_cd                    in    varchar2
  ,p_retirement_age               in    number     default null
  ,p_category_cd                  in    varchar2
  ,p_corps_type_cd                in    varchar2
  ,p_date_from         in    date
  ,p_date_to           in    date       default null
  ,p_recruitment_end_date         in    date       default null
  ,p_starting_grade_step_id       in    number     default null
  ,p_type_of_ps               in    varchar2   default null
  ,p_task_desc                    in    varchar2   default null
  ,p_secondment_threshold         in    number     default null
  ,p_normal_hours                 in    number     default null
  ,p_normal_hours_frequency       in    varchar2   default null
  ,p_minimum_hours                in    number     default null
  ,p_minimum_hours_frequency      in    varchar2   default null
  ,p_attribute1                   in    varchar2   default null
  ,p_attribute2                   in    varchar2   default null
  ,p_attribute3                   in    varchar2   default null
  ,p_attribute4                   in    varchar2   default null
  ,p_attribute5                   in    varchar2   default null
  ,p_attribute6                   in    varchar2   default null
  ,p_attribute7                   in    varchar2   default null
  ,p_attribute8                   in    varchar2   default null
  ,p_attribute9                   in    varchar2   default null
  ,p_attribute10                  in    varchar2   default null
  ,p_attribute11                  in    varchar2   default null
  ,p_attribute12                  in    varchar2   default null
  ,p_attribute13                  in    varchar2   default null
  ,p_attribute14                  in    varchar2   default null
  ,p_attribute15                  in    varchar2   default null
  ,p_attribute16                  in    varchar2   default null
  ,p_attribute17                  in    varchar2   default null
  ,p_attribute18                  in    varchar2   default null
  ,p_attribute19                  in    varchar2   default null
  ,p_attribute20                  in    varchar2   default null
  ,p_attribute21                  in    varchar2   default null
  ,p_attribute22                  in    varchar2   default null
  ,p_attribute23                  in    varchar2   default null
  ,p_attribute24                  in    varchar2   default null
  ,p_attribute25                  in    varchar2   default null
  ,p_attribute26                  in    varchar2   default null
  ,p_attribute27                  in    varchar2   default null
  ,p_attribute28                  in    varchar2   default null
  ,p_attribute29                  in    varchar2   default null
  ,p_attribute30                  in    varchar2   default null
  ,p_attribute_category           in    varchar2   default null
  ,p_object_version_number        out nocopy   number
  ,p_primary_prof_field_id          in number      default null
  ,p_starting_grade_id              in number      default null
  ,p_ben_pgm_id                     in number      default null
  ,p_probation_period               in number      default null
  ,p_probation_units                in varchar2    default null
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_corps_definition >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the record when an existing corps definition is changed
 * and updates the record in the database.
 *
 * It validates the corps definition name for uniqueness. The record is updated
 * in PQH_CORPS_DEFINITIONS table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The corps definition record must exist with the specified object version
 * number.
 *
 * <p><b>Post Success</b><br>
 * The existing corps definition record is updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The existing corps definition record is not updated and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the Date Track operation comes into
 * force
 * @param p_corps_definition_id Unique corps definition identifier generated
 * for this record when created as a Primary Key
 * @param p_business_group_id Identifies the business group identifier for
 * which the corps definition record is being created
 * @param p_name Unique name for the corps
 * @param p_status_cd Status of the corps as identified by lookup type
 * 'PQH_CORPS_STATUS'
 * @param p_retirement_age Retirement age of the employees on this corps. Value
 * is between 40 and 80
 * @param p_category_cd Category code of the corps which will indicate its
 * level of responsibility and management within the public sector. Valid
 * values are defined by 'PQH_CORPS_CATEGORY' lookup type
 * @param p_starting_grade_step_id Type of the corps. Valid values are defined
 * by 'PQH_CORPS_TYPE' lookup type
 * @param p_type_of_ps {@rep:casecolumn PQH_CORPS_DEFINITIONS.DATE_FROM}
 * @param p_corps_type_cd {@rep:casecolumn PQH_CORPS_DEFINITIONS.DATE_TO}
 * @param p_date_from Identifies the end date of recruitment for the corps. It
 * should be between start date and end date
 * @param p_date_to The starting grade step for the civil servant on this
 * corps. It should be the identifier of a step in existence as of the
 * effective date
 * @param p_recruitment_end_date Type of the public sector organization. Valid
 * values are defined by 'FR_PQH_ORG_CATEGORY' lookup type
 * @param p_task_desc {@rep:casecolumn PQH_CORPS_DEFINITIONS.TASK_DESC}
 * @param p_secondment_threshold Percentage of civil servants in this corps who
 * can be placed on secondment. Its value should be between 0 and 100
 * @param p_normal_hours Normal working hours for civil servants on this corps
 * in terms of the unit given in normal_frequency parameter
 * @param p_normal_hours_frequency Unit of time measurement in terms of which
 * normal working hour for civil servants on this corps is provided. This value
 * is mandatory if the normal_hours parameter has a not null value. Valid
 * values are identified by 'FREQUENCY' lookup type.
 * @param p_minimum_hours Minimum working hours for civil servants on this
 * corps in terms of the unit given in minimum_frequency parameter. It should
 * not be greater than the normal working hours
 * @param p_minimum_hours_frequency Unit of time measurement in terms of which
 * minimum working hour for civil servants on this corps is provided. This
 * value is mandatory if the minimum_hours parameter has a not null value.
 * Valid values are identified by lookup type 'FREQUENCY'.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_object_version_number Identifies the current version number of the
 * corps definition to be updated. When the API completes if p_validate is
 * false, the process returns the new version number of the updated corps
 * definition. If p_validate is true it returns the same value which was passed
 * in
 * @param p_primary_prof_field_id Primary professional field shared type
 * identifier. Valid values are defined by 'PER_SHARED_TYPES' database table
 * @param p_starting_grade_id The starting grade step for the civil servant on
 * this corps. It should be the identifier of a step in existence as of the
 * effective date
 * @param p_ben_pgm_id {@rep:casecolumn PQH_CORPS_DEFINITIONS.BEN_PGM_ID}
 * @param p_probation_period {@rep:casecolumn
 * PQH_CORPS_DEFINITIONS.PROBATION_PERIOD}
 * @param p_probation_units Units for probation period duration. Valid values
 * are identified by lookup type 'PROC_PERIOD_TYPE'.
 * @rep:displayname Update CORPS Definition
 * @rep:category BUSINESS_ENTITY PQH_FR_CORPS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_corps_definition
  (
  p_validate                      in    boolean    default false
  ,p_effective_date               in    date
  ,p_corps_definition_id          in    number
  ,p_business_group_id            in    number     default hr_api.g_number
  ,p_name                         in    varchar2   default hr_api.g_varchar2
  ,p_status_cd                    in    varchar2   default hr_api.g_varchar2
  ,p_retirement_age               in    number     default hr_api.g_number
  ,p_category_cd                  in    varchar2   default hr_api.g_varchar2
  ,p_starting_grade_step_id       in    number     default hr_api.g_number
  ,p_type_of_ps               in    varchar2   default hr_api.g_varchar2
  ,p_corps_type_cd                in    varchar2   default hr_api.g_varchar2
  ,p_date_from         in    date       default hr_api.g_date
  ,p_date_to           in    date       default hr_api.g_date
  ,p_recruitment_end_date         in    date       default hr_api.g_date
  ,p_task_desc                    in    varchar2   default hr_api.g_varchar2
  ,p_secondment_threshold         in    number     default hr_api.g_number
  ,p_normal_hours                 in    number     default hr_api.g_number
  ,p_normal_hours_frequency       in    varchar2   default hr_api.g_varchar2
  ,p_minimum_hours                in    number     default hr_api.g_number
  ,p_minimum_hours_frequency      in    varchar2   default hr_api.g_varchar2
  ,p_attribute1                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute2                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute3                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute4                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute5                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute6                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute7                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute8                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute9                   in    varchar2   default hr_api.g_varchar2
  ,p_attribute10                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute11                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute12                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute13                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute14                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute15                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute16                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute17                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute18                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute19                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute20                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute21                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute22                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute23                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute24                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute25                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute26                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute27                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute28                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute29                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute30                  in    varchar2   default hr_api.g_varchar2
  ,p_attribute_category           in    varchar2   default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy   number
  ,p_primary_prof_field_id          in number      default hr_api.g_number
  ,p_starting_grade_id              in number      default hr_api.g_number
  ,p_ben_pgm_id                     in number      default hr_api.g_number
  ,p_probation_period               in number      default hr_api.g_number
  ,p_probation_units                in varchar2    default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_corps_definition >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes corps definitions.
 *
 * The record is deleted from PQH_CORPS_DEFINITIONS table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * This record should exist with the specified object version number. There
 * should not be any placements on the corps. All the associated corps extra
 * information record must have been deleted already.
 *
 * <p><b>Post Success</b><br>
 * The corps definition record is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The corps definition record is not deleted from the database and an error is
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_corps_definition_id Unique corps definition identifier generated
 * for this record when created as a Primary Key
 * @param p_object_version_number Current version number of the corps
 * definition to be deleted
 * @rep:displayname Delete CORPS Definition
 * @rep:category BUSINESS_ENTITY PQH_FR_CORPS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_corps_definition
  (
  p_validate                        in boolean        default false
  ,p_corps_definition_id            in  number
  ,p_object_version_number          in number
  );
--
end pqh_corps_definitions_api;

 

/
