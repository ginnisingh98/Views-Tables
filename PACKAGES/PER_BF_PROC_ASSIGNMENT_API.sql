--------------------------------------------------------
--  DDL for Package PER_BF_PROC_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BF_PROC_ASSIGNMENT_API" AUTHID CURRENT_USER AS
/* $Header: pebpaapi.pkh 120.1 2005/10/02 02:12:11 aroussel $ */
/*#
 * This package contains APIs for maintaining backfeed processed assignments
 * records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Backfeed Processed Assignment
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_processed_assignment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a processed assignment for a particular employee assignment
 * relating to a third party payroll run.
 *
 * Creates a processed assignment for a particular third party payroll run and
 * an employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid backfeed payroll run must exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed processed assignment will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed processed assignment will not be created and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_assignment_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID}
 * @param p_payroll_run_id {@rep:casecolumn PER_BF_PAYROLL_RUNS.PAYROLL_RUN_ID}
 * @param p_bpa_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_bpa_attribute1 Descriptive flexfield segment.
 * @param p_bpa_attribute2 Descriptive flexfield segment.
 * @param p_bpa_attribute3 Descriptive flexfield segment.
 * @param p_bpa_attribute4 Descriptive flexfield segment.
 * @param p_bpa_attribute5 Descriptive flexfield segment.
 * @param p_bpa_attribute6 Descriptive flexfield segment.
 * @param p_bpa_attribute7 Descriptive flexfield segment.
 * @param p_bpa_attribute8 Descriptive flexfield segment.
 * @param p_bpa_attribute9 Descriptive flexfield segment.
 * @param p_bpa_attribute10 Descriptive flexfield segment.
 * @param p_bpa_attribute11 Descriptive flexfield segment.
 * @param p_bpa_attribute12 Descriptive flexfield segment.
 * @param p_bpa_attribute13 Descriptive flexfield segment.
 * @param p_bpa_attribute14 Descriptive flexfield segment.
 * @param p_bpa_attribute15 Descriptive flexfield segment.
 * @param p_bpa_attribute16 Descriptive flexfield segment.
 * @param p_bpa_attribute17 Descriptive flexfield segment.
 * @param p_bpa_attribute18 Descriptive flexfield segment.
 * @param p_bpa_attribute19 Descriptive flexfield segment.
 * @param p_bpa_attribute20 Descriptive flexfield segment.
 * @param p_bpa_attribute21 Descriptive flexfield segment.
 * @param p_bpa_attribute22 Descriptive flexfield segment.
 * @param p_bpa_attribute23 Descriptive flexfield segment.
 * @param p_bpa_attribute24 Descriptive flexfield segment.
 * @param p_bpa_attribute25 Descriptive flexfield segment.
 * @param p_bpa_attribute26 Descriptive flexfield segment.
 * @param p_bpa_attribute27 Descriptive flexfield segment.
 * @param p_bpa_attribute28 Descriptive flexfield segment.
 * @param p_bpa_attribute29 Descriptive flexfield segment.
 * @param p_bpa_attribute30 Descriptive flexfield segment.
 * @param p_processed_assignment_id If p_validate is false, then this uniquely
 * identifies the backfeed processed assignment created. If p_validate is true,
 * then set to null.
 * @param p_processed_assignment_ovn If p_validate is false, then set to the
 * version number of the created backfeed payroll assignment record. If
 * p_validate is true, then the value will be null.
 * @rep:displayname Create Backfeed Processed Assignment
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_processed_assignment
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_payroll_run_id                in     number
  ,p_bpa_attribute_category            in     varchar2 default null
  ,p_bpa_attribute1                    in     varchar2 default null
  ,p_bpa_attribute2                    in     varchar2 default null
  ,p_bpa_attribute3                    in     varchar2 default null
  ,p_bpa_attribute4                    in     varchar2 default null
  ,p_bpa_attribute5                    in     varchar2 default null
  ,p_bpa_attribute6                    in     varchar2 default null
  ,p_bpa_attribute7                    in     varchar2 default null
  ,p_bpa_attribute8                    in     varchar2 default null
  ,p_bpa_attribute9                    in     varchar2 default null
  ,p_bpa_attribute10                   in     varchar2 default null
  ,p_bpa_attribute11                   in     varchar2 default null
  ,p_bpa_attribute12                   in     varchar2 default null
  ,p_bpa_attribute13                   in     varchar2 default null
  ,p_bpa_attribute14                   in     varchar2 default null
  ,p_bpa_attribute15                   in     varchar2 default null
  ,p_bpa_attribute16                   in     varchar2 default null
  ,p_bpa_attribute17                   in     varchar2 default null
  ,p_bpa_attribute18                   in     varchar2 default null
  ,p_bpa_attribute19                   in     varchar2 default null
  ,p_bpa_attribute20                   in     varchar2 default null
  ,p_bpa_attribute21                   in     varchar2 default null
  ,p_bpa_attribute22                   in     varchar2 default null
  ,p_bpa_attribute23                   in     varchar2 default null
  ,p_bpa_attribute24                   in     varchar2 default null
  ,p_bpa_attribute25                   in     varchar2 default null
  ,p_bpa_attribute26                   in     varchar2 default null
  ,p_bpa_attribute27                   in     varchar2 default null
  ,p_bpa_attribute28                   in     varchar2 default null
  ,p_bpa_attribute29                   in     varchar2 default null
  ,p_bpa_attribute30                   in     varchar2 default null
  ,p_processed_assignment_id          out nocopy number
  ,p_processed_assignment_ovn         out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_processed_assignment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a processed assignment for a particular employee assignment
 * relating to a third party payroll run.
 *
 * This API updates a processed assignment for a particular third party payroll
 * run and an employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid backfeed processed assignment must exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed processed assignment will be successfully updated into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed processed assignment will not be updated and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_processed_assignment_id Uniquely identifies a backfeed processed
 * assignment record.
 * @param p_bpa_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_bpa_attribute1 Descriptive flexfield segment.
 * @param p_bpa_attribute2 Descriptive flexfield segment.
 * @param p_bpa_attribute3 Descriptive flexfield segment.
 * @param p_bpa_attribute4 Descriptive flexfield segment.
 * @param p_bpa_attribute5 Descriptive flexfield segment.
 * @param p_bpa_attribute6 Descriptive flexfield segment.
 * @param p_bpa_attribute7 Descriptive flexfield segment.
 * @param p_bpa_attribute8 Descriptive flexfield segment.
 * @param p_bpa_attribute9 Descriptive flexfield segment.
 * @param p_bpa_attribute10 Descriptive flexfield segment.
 * @param p_bpa_attribute11 Descriptive flexfield segment.
 * @param p_bpa_attribute12 Descriptive flexfield segment.
 * @param p_bpa_attribute13 Descriptive flexfield segment.
 * @param p_bpa_attribute14 Descriptive flexfield segment.
 * @param p_bpa_attribute15 Descriptive flexfield segment.
 * @param p_bpa_attribute16 Descriptive flexfield segment.
 * @param p_bpa_attribute17 Descriptive flexfield segment.
 * @param p_bpa_attribute18 Descriptive flexfield segment.
 * @param p_bpa_attribute19 Descriptive flexfield segment.
 * @param p_bpa_attribute20 Descriptive flexfield segment.
 * @param p_bpa_attribute21 Descriptive flexfield segment.
 * @param p_bpa_attribute22 Descriptive flexfield segment.
 * @param p_bpa_attribute23 Descriptive flexfield segment.
 * @param p_bpa_attribute24 Descriptive flexfield segment.
 * @param p_bpa_attribute25 Descriptive flexfield segment.
 * @param p_bpa_attribute26 Descriptive flexfield segment.
 * @param p_bpa_attribute27 Descriptive flexfield segment.
 * @param p_bpa_attribute28 Descriptive flexfield segment.
 * @param p_bpa_attribute29 Descriptive flexfield segment.
 * @param p_bpa_attribute30 Descriptive flexfield segment.
 * @param p_processed_assignment_ovn Pass in the current version number of the
 * backfeed processed assignment to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * backfeed payment detail. If p_validate is true will be set to the same value
 * which was passed in.
 * @rep:displayname Update Backfeed Processed Assignment
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_processed_assignment
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_processed_assignment_id       in     number
  ,p_bpa_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_bpa_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_processed_assignment_ovn      in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_processed_assignment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a processed assignment for a particular employee assignment
 * relating to a third party payroll run.
 *
 * Deletes a processed assignment for a particular third party payroll run and
 * an employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid backfeed processed assignment must exist.
 *
 * <p><b>Post Success</b><br>
 * The backfeed processed assignment will be successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The backfeed processed assignment will not be deleted and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_processed_assignment_id Uniquely identifies a backfeed processed
 * assignment record.
 * @param p_processed_assignment_ovn Current version number of the backfeed
 * processed assignment to be deleted.
 * @rep:displayname Delete Backfeed Processed Assignment
 * @rep:category BUSINESS_ENTITY PER_BF_PAYROLL_RESULTS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_processed_assignment
  (p_validate                      in     boolean  default false
  ,p_processed_assignment_id       in number
  ,p_processed_assignment_ovn      in number
  );
--
end PER_BF_PROC_ASSIGNMENT_API;

 

/
