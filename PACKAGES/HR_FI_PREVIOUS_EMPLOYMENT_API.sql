--------------------------------------------------------
--  DDL for Package HR_FI_PREVIOUS_EMPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FI_PREVIOUS_EMPLOYMENT_API" AUTHID CURRENT_USER as
/* $Header: pepemfii.pkh 120.1 2005/10/02 02:43:36 aroussel $ */
/*#
 * This package contains previous employment APIs for Finland.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Previous Employment for Finland
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_fi_previous_job >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates previous job details.
 *
 * This API is effectively an alternative to the API create_previous_job. If
 * p_validate is set to false, a previous job is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The previous employer must already exist.
 *
 * <p><b>Post Success</b><br>
 * The previous job will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The previous job will not be created and an error will be raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_employer_id Foreign key for the table
 * per_previous_employers.
 * @param p_start_date The date from which the employee worked with the
 * previous job. Start date should be between start and end dates for the
 * previous employer record.
 * @param p_end_date The date on which the employee left the previous job.
 * @param p_period_years Number of years of previous employment based on the
 * employment start date and end date.
 * @param p_period_months Number of months of previous employment based on the
 * employment start date and end date.
 * @param p_period_days Remaining number of days of employment based on number
 * of days in period.
 * @param p_job_name The name of the previous job. This is free text, and
 * should not be confused with jobs held with the current employer stored
 * within Oracle Human Resources.
 * @param p_employment_category Category of the previous job. Valid values are
 * defined by EMPLOYEE_CATG lookup type.
 * @param p_description Description of the previous job.
 * @param p_all_assignments Indicates whether previous employer is applicable
 * to all assignments of the current employer.
 * @param p_pjo_attribute_category Descriptive flexfield structure defining
 * column.
 * @param p_pjo_attribute1 Descriptive flexfield column.
 * @param p_pjo_attribute2 Descriptive flexfield column.
 * @param p_pjo_attribute3 Descriptive flexfield column.
 * @param p_pjo_attribute4 Descriptive flexfield column.
 * @param p_pjo_attribute5 Descriptive flexfield column.
 * @param p_pjo_attribute6 Descriptive flexfield column.
 * @param p_pjo_attribute7 Descriptive flexfield column.
 * @param p_pjo_attribute8 Descriptive flexfield column.
 * @param p_pjo_attribute9 Descriptive flexfield column.
 * @param p_pjo_attribute10 Descriptive flexfield column.
 * @param p_pjo_attribute11 Descriptive flexfield column.
 * @param p_pjo_attribute12 Descriptive flexfield column.
 * @param p_pjo_attribute13 Descriptive flexfield column.
 * @param p_pjo_attribute14 Descriptive flexfield column.
 * @param p_pjo_attribute15 Descriptive flexfield column.
 * @param p_pjo_attribute16 Descriptive flexfield column.
 * @param p_pjo_attribute17 Descriptive flexfield column.
 * @param p_pjo_attribute18 Descriptive flexfield column
 * @param p_pjo_attribute19 Descriptive flexfield column.
 * @param p_pjo_attribute20 Descriptive flexfield column.
 * @param p_pjo_attribute21 Descriptive flexfield column.
 * @param p_pjo_attribute22 Descriptive flexfield column.
 * @param p_pjo_attribute23 Descriptive flexfield column.
 * @param p_pjo_attribute24 Descriptive flexfield column.
 * @param p_pjo_attribute25 Descriptive flexfield column.
 * @param p_pjo_attribute26 Descriptive flexfield column.
 * @param p_pjo_attribute27 Descriptive flexfield column.
 * @param p_pjo_attribute28 Descriptive flexfield column.
 * @param p_pjo_attribute29 Descriptive flexfield column.
 * @param p_pjo_attribute30 Descriptive flexfield column.
 * @param p_job_exp_classification Job experience classification. Valid values
 * are defined by FI_JOB_EXP_CAT lookup type.
 * @param p_previous_job_id If p_validate is false, then this uniquely
 * identifies the created previous job. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created previous job. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Previous Job for Finland
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_fi_previous_job
(  p_effective_date                 in     date
  ,p_validate                       in     boolean  default false
  ,p_previous_employer_id           in     number
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_period_years                   in     number   default null
  ,p_period_months                  in     number   default null
  ,p_period_days                    in     number   default null
  ,p_job_name                       in     varchar2 default null
  ,p_employment_category            in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_all_assignments                in     varchar2 default 'N'
  ,p_pjo_attribute_category         in     varchar2 default null
  ,p_pjo_attribute1                 in     varchar2 default null
  ,p_pjo_attribute2                 in     varchar2 default null
  ,p_pjo_attribute3                 in     varchar2 default null
  ,p_pjo_attribute4                 in     varchar2 default null
  ,p_pjo_attribute5                 in     varchar2 default null
  ,p_pjo_attribute6                 in     varchar2 default null
  ,p_pjo_attribute7                 in     varchar2 default null
  ,p_pjo_attribute8                 in     varchar2 default null
  ,p_pjo_attribute9                 in     varchar2 default null
  ,p_pjo_attribute10                in     varchar2 default null
  ,p_pjo_attribute11                in     varchar2 default null
  ,p_pjo_attribute12                in     varchar2 default null
  ,p_pjo_attribute13                in     varchar2 default null
  ,p_pjo_attribute14                in     varchar2 default null
  ,p_pjo_attribute15                in     varchar2 default null
  ,p_pjo_attribute16                in     varchar2 default null
  ,p_pjo_attribute17                in     varchar2 default null
  ,p_pjo_attribute18                in     varchar2 default null
  ,p_pjo_attribute19                in     varchar2 default null
  ,p_pjo_attribute20                in     varchar2 default null
  ,p_pjo_attribute21                in     varchar2 default null
  ,p_pjo_attribute22                in     varchar2 default null
  ,p_pjo_attribute23                in     varchar2 default null
  ,p_pjo_attribute24                in     varchar2 default null
  ,p_pjo_attribute25                in     varchar2 default null
  ,p_pjo_attribute26                in     varchar2 default null
  ,p_pjo_attribute27                in     varchar2 default null
  ,p_pjo_attribute28                in     varchar2 default null
  ,p_pjo_attribute29                in     varchar2 default null
  ,p_pjo_attribute30                in     varchar2 default null
  ,p_job_exp_classification 	    in     varchar2 default null
  ,p_previous_job_id                out nocopy    number
  ,p_object_version_number          out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_fi_previous_job >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API modifies a previous job.
 *
 * This API is effectively an alternative to the API update_previous_job. If
 * p_validate is set to false, the previous job is updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The previous job record identified by p_previous_job_id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The previous job will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The previous job will not be updated and an error will be raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_job_id Primary key of the table.
 * @param p_start_date The date from which the employee worked with the
 * previous job. The start date should be in between the start and end dates
 * for the previous employer record.
 * @param p_end_date The date on which the employee left the previous job.
 * @param p_period_years Number of years of previous employment based on the
 * employment start date and end date.
 * @param p_period_months Number of months of previous employment based on the
 * employment start date and end date.
 * @param p_period_days Remaining number of days of employment based on number
 * of days in period.
 * @param p_job_name The name of the previous job. This is free text, and
 * should not be confused with jobs held with the current employer stored
 * within Oracle Human Resources.
 * @param p_employment_category Category of the previous job. Valid values are
 * defined by EMPLOYEE_CATG lookup type.
 * @param p_description Description of the previous job.
 * @param p_all_assignments Indicates whether previous employer is applicable
 * to all assignments of the current employer.
 * @param p_pjo_attribute_category Descriptive flexfield structure defining
 * column.
 * @param p_pjo_attribute1 Descriptive flexfield column.
 * @param p_pjo_attribute2 Descriptive flexfield column.
 * @param p_pjo_attribute3 Descriptive flexfield column.
 * @param p_pjo_attribute4 Descriptive flexfield column.
 * @param p_pjo_attribute5 Descriptive flexfield column.
 * @param p_pjo_attribute6 Descriptive flexfield column.
 * @param p_pjo_attribute7 Descriptive flexfield column.
 * @param p_pjo_attribute8 Descriptive flexfield column.
 * @param p_pjo_attribute9 Descriptive flexfield column.
 * @param p_pjo_attribute10 Descriptive flexfield column.
 * @param p_pjo_attribute11 Descriptive flexfield column.
 * @param p_pjo_attribute12 Descriptive flexfield column.
 * @param p_pjo_attribute13 Descriptive flexfield column.
 * @param p_pjo_attribute14 Descriptive flexfield column.
 * @param p_pjo_attribute15 Descriptive flexfield column.
 * @param p_pjo_attribute16 Descriptive flexfield column.
 * @param p_pjo_attribute17 Descriptive flexfield column.
 * @param p_pjo_attribute18 Descriptive flexfield column.
 * @param p_pjo_attribute19 Descriptive flexfield column.
 * @param p_pjo_attribute20 Descriptive flexfield column.
 * @param p_pjo_attribute21 Descriptive flexfield column.
 * @param p_pjo_attribute22 Descriptive flexfield column.
 * @param p_pjo_attribute23 Descriptive flexfield column.
 * @param p_pjo_attribute24 Descriptive flexfield column.
 * @param p_pjo_attribute25 Descriptive flexfield column.
 * @param p_pjo_attribute26 Descriptive flexfield column.
 * @param p_pjo_attribute27 Descriptive flexfield column.
 * @param p_pjo_attribute28 Descriptive flexfield column.
 * @param p_pjo_attribute29 Descriptive flexfield column.
 * @param p_pjo_attribute30 Descriptive flexfield column.
 * @param p_job_exp_classification Job experience classification. Valid values
 * are defined by FI_JOB_EXP_CAT lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * previous job to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated previous job. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Previous Job for Finland
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_fi_previous_job
  (p_effective_date               in     date
  ,p_validate                     in     boolean   default false
  ,p_previous_job_id              in     number
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_period_years                 in     number    default null
  ,p_period_months                in     number    default null
  ,p_period_days                  in     number    default null
  ,p_job_name                     in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_all_assignments              in     varchar2  default 'N'
  ,p_pjo_attribute_category       in     varchar2  default null
  ,p_pjo_attribute1               in     varchar2  default null
  ,p_pjo_attribute2               in     varchar2  default null
  ,p_pjo_attribute3               in     varchar2  default null
  ,p_pjo_attribute4               in     varchar2  default null
  ,p_pjo_attribute5               in     varchar2  default null
  ,p_pjo_attribute6               in     varchar2  default null
  ,p_pjo_attribute7               in     varchar2  default null
  ,p_pjo_attribute8               in     varchar2  default null
  ,p_pjo_attribute9               in     varchar2  default null
  ,p_pjo_attribute10              in     varchar2  default null
  ,p_pjo_attribute11              in     varchar2  default null
  ,p_pjo_attribute12              in     varchar2  default null
  ,p_pjo_attribute13              in     varchar2  default null
  ,p_pjo_attribute14              in     varchar2  default null
  ,p_pjo_attribute15              in     varchar2  default null
  ,p_pjo_attribute16              in     varchar2  default null
  ,p_pjo_attribute17              in     varchar2  default null
  ,p_pjo_attribute18              in     varchar2  default null
  ,p_pjo_attribute19              in     varchar2  default null
  ,p_pjo_attribute20              in     varchar2  default null
  ,p_pjo_attribute21              in     varchar2  default null
  ,p_pjo_attribute22              in     varchar2  default null
  ,p_pjo_attribute23              in     varchar2  default null
  ,p_pjo_attribute24              in     varchar2  default null
  ,p_pjo_attribute25              in     varchar2  default null
  ,p_pjo_attribute26              in     varchar2  default null
  ,p_pjo_attribute27              in     varchar2  default null
  ,p_pjo_attribute28              in     varchar2  default null
  ,p_pjo_attribute29              in     varchar2  default null
  ,p_pjo_attribute30              in     varchar2  default null
  ,p_job_exp_classification in     varchar2  default null
  ,p_object_version_number        in out nocopy number
  );
--
end hr_fi_previous_employment_api;

 

/
