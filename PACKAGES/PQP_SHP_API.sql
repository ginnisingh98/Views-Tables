--------------------------------------------------------
--  DDL for Package PQP_SHP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_SHP_API" AUTHID CURRENT_USER as
/* $Header: pqshpapi.pkh 120.1 2005/10/02 02:27:57 aroussel $ */
/*#
 * This package contains employment service history API's.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employment Service History
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_service_history_period >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates employment service history.
 *
 * This API creates employment service history period information for an
 * employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * This employee should have an assignment before creating a service history
 * period.
 *
 * <p><b>Post Success</b><br>
 * The employment service history record will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The employment service history record will not be created and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.BUSINESS_GROUP_ID}
 * @param p_assignment_id Identifies the assignment for which you create the
 * employment service history record.
 * @param p_start_date {@rep:casecolumn PQP_SERVICE_HISTORY_PERIODS.START_DATE}
 * @param p_end_date {@rep:casecolumn PQP_SERVICE_HISTORY_PERIODS.END_DATE}
 * @param p_employer_name {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.EMPLOYER_NAME}
 * @param p_employer_address {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.EMPLOYER_ADDRESS}
 * @param p_employer_type {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.EMPLOYER_TYPE}
 * @param p_employer_subtype {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.EMPLOYER_SUBTYPE}
 * @param p_description {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.CONTINUOUS_SERVICE}
 * @param p_continuous_service {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.ALL_ASSIGNMENTS}
 * @param p_all_assignments {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.DESCRIPTION}
 * @param p_period_years {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.PERIOD_YEARS}
 * @param p_period_days {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.PERIOD_DAYS}
 * @param p_shp_attribute_category {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE_CATEGORY}
 * @param p_shp_attribute1 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE1}
 * @param p_shp_attribute2 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE2}
 * @param p_shp_attribute3 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE3}
 * @param p_shp_attribute4 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE4}
 * @param p_shp_attribute5 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE5}
 * @param p_shp_attribute6 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE6}
 * @param p_shp_attribute7 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE7}
 * @param p_shp_attribute8 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE8}
 * @param p_shp_attribute9 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE9}
 * @param p_shp_attribute10 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE10}
 * @param p_shp_attribute11 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE11}
 * @param p_shp_attribute12 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE12}
 * @param p_shp_attribute13 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE13}
 * @param p_shp_attribute14 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE14}
 * @param p_shp_attribute15 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE15}
 * @param p_shp_attribute16 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE16}
 * @param p_shp_attribute17 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE17}
 * @param p_shp_attribute18 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE18}
 * @param p_shp_attribute19 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE19}
 * @param p_shp_attribute20 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE20}
 * @param p_shp_information_category {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION_CATEGORY}
 * @param p_shp_information1 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION1}
 * @param p_shp_information2 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION2}
 * @param p_shp_information3 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION3}
 * @param p_shp_information4 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION4}
 * @param p_shp_information5 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION5}
 * @param p_shp_information6 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION6}
 * @param p_shp_information7 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION7}
 * @param p_shp_information8 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION8}
 * @param p_shp_information9 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION9}
 * @param p_shp_information10 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION10}
 * @param p_shp_information11 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION11}
 * @param p_shp_information12 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION12}
 * @param p_shp_information13 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION13}
 * @param p_shp_information14 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION14}
 * @param p_shp_information15 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION15}
 * @param p_shp_information16 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION16}
 * @param p_shp_information17 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION17}
 * @param p_shp_information18 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION18}
 * @param p_shp_information19 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION19}
 * @param p_shp_information20 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION20}
 * @param p_service_history_period_id {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SERVICE_HISTORY_PERIOD_ID}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created employment service history. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Employment Service History
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_service_history_period
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_start_date                    in     date     default null
  ,p_end_date                      in     date     default null
  ,p_employer_name                 in     varchar2 default null
  ,p_employer_address              in     varchar2 default null
  ,p_employer_type                 in     varchar2 default null
  ,p_employer_subtype              in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_continuous_service            in     varchar2 default null
  ,p_all_assignments               in     varchar2 default null
  ,p_period_years                  in     number   default null
  ,p_period_days                   in     number   default null
  ,p_shp_attribute_category        in     varchar2 default null
  ,p_shp_attribute1                in     varchar2 default null
  ,p_shp_attribute2                in     varchar2 default null
  ,p_shp_attribute3                in     varchar2 default null
  ,p_shp_attribute4                in     varchar2 default null
  ,p_shp_attribute5                in     varchar2 default null
  ,p_shp_attribute6                in     varchar2 default null
  ,p_shp_attribute7                in     varchar2 default null
  ,p_shp_attribute8                in     varchar2 default null
  ,p_shp_attribute9                in     varchar2 default null
  ,p_shp_attribute10               in     varchar2 default null
  ,p_shp_attribute11               in     varchar2 default null
  ,p_shp_attribute12               in     varchar2 default null
  ,p_shp_attribute13               in     varchar2 default null
  ,p_shp_attribute14               in     varchar2 default null
  ,p_shp_attribute15               in     varchar2 default null
  ,p_shp_attribute16               in     varchar2 default null
  ,p_shp_attribute17               in     varchar2 default null
  ,p_shp_attribute18               in     varchar2 default null
  ,p_shp_attribute19               in     varchar2 default null
  ,p_shp_attribute20               in     varchar2 default null
  ,p_shp_information_category      in     varchar2 default null
  ,p_shp_information1              in     varchar2 default null
  ,p_shp_information2              in     varchar2 default null
  ,p_shp_information3              in     varchar2 default null
  ,p_shp_information4              in     varchar2 default null
  ,p_shp_information5              in     varchar2 default null
  ,p_shp_information6              in     varchar2 default null
  ,p_shp_information7              in     varchar2 default null
  ,p_shp_information8              in     varchar2 default null
  ,p_shp_information9              in     varchar2 default null
  ,p_shp_information10             in     varchar2 default null
  ,p_shp_information11             in     varchar2 default null
  ,p_shp_information12             in     varchar2 default null
  ,p_shp_information13             in     varchar2 default null
  ,p_shp_information14             in     varchar2 default null
  ,p_shp_information15             in     varchar2 default null
  ,p_shp_information16             in     varchar2 default null
  ,p_shp_information17             in     varchar2 default null
  ,p_shp_information18             in     varchar2 default null
  ,p_shp_information19             in     varchar2 default null
  ,p_shp_information20             in     varchar2 default null
  ,p_service_history_period_id        out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_service_history_period >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employment service history period information for an
 * employee assignment.
 *
 * This API updates employment service history period information for an
 * employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An employment service history record for this assignment should exist before
 * updating.
 *
 * <p><b>Post Success</b><br>
 * The employment service history record will be successfully updated into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The employment service history record will not be updated and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_service_history_period_id {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SERVICE_HISTORY_PERIOD_ID}
 * @param p_assignment_id Identifies the assignment record to modify.
 * @param p_start_date {@rep:casecolumn PQP_SERVICE_HISTORY_PERIODS.START_DATE}
 * @param p_end_date {@rep:casecolumn PQP_SERVICE_HISTORY_PERIODS.END_DATE}
 * @param p_employer_name {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.EMPLOYER_NAME}
 * @param p_employer_address {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.EMPLOYER_ADDRESS}
 * @param p_employer_type {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.EMPLOYER_TYPE}
 * @param p_employer_subtype {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.EMPLOYER_SUBTYPE}
 * @param p_description {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.DESCRIPTION}
 * @param p_continuous_service {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.CONTINUOUS_SERVICE}
 * @param p_all_assignments {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.ALL_ASSIGNMENTS}
 * @param p_period_years {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.PERIOD_YEARS}
 * @param p_period_days {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.PERIOD_DAYS}
 * @param p_shp_attribute_category {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE_CATEGORY}
 * @param p_shp_attribute1 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE1}
 * @param p_shp_attribute2 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE2}
 * @param p_shp_attribute3 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE3}
 * @param p_shp_attribute4 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE4}
 * @param p_shp_attribute5 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE5}
 * @param p_shp_attribute6 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE6}
 * @param p_shp_attribute7 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE7}
 * @param p_shp_attribute8 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE8}
 * @param p_shp_attribute9 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE9}
 * @param p_shp_attribute10 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE10}
 * @param p_shp_attribute11 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE11}
 * @param p_shp_attribute12 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE12}
 * @param p_shp_attribute13 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE13}
 * @param p_shp_attribute14 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE14}
 * @param p_shp_attribute15 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE15}
 * @param p_shp_attribute16 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE16}
 * @param p_shp_attribute17 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE17}
 * @param p_shp_attribute18 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE18}
 * @param p_shp_attribute19 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE19}
 * @param p_shp_attribute20 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_ATTRIBUTE20}
 * @param p_shp_information_category {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION_CATEGORY}
 * @param p_shp_information1 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION1}
 * @param p_shp_information2 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION2}
 * @param p_shp_information3 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION3}
 * @param p_shp_information4 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION4}
 * @param p_shp_information5 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION5}
 * @param p_shp_information6 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION6}
 * @param p_shp_information7 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION7}
 * @param p_shp_information8 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION8}
 * @param p_shp_information9 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION9}
 * @param p_shp_information10 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION10}
 * @param p_shp_information11 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION11}
 * @param p_shp_information12 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION12}
 * @param p_shp_information13 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION13}
 * @param p_shp_information14 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION14}
 * @param p_shp_information15 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION15}
 * @param p_shp_information16 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION16}
 * @param p_shp_information17 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION17}
 * @param p_shp_information18 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION18}
 * @param p_shp_information19 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION19}
 * @param p_shp_information20 {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SHP_INFORMATION20}
 * @param p_object_version_number Pass in the current version number of the
 * employment service history to be updated. When the API completes, if
 * p_validate is false, it will be set to the new version number of the updated
 * employment service history. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Employment Service History
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_service_history_period
  (p_validate                      in     boolean  default false
  ,p_service_history_period_id     in     number
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_employer_name                 in     varchar2 default hr_api.g_varchar2
  ,p_employer_address              in     varchar2 default hr_api.g_varchar2
  ,p_employer_type                 in     varchar2 default hr_api.g_varchar2
  ,p_employer_subtype              in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_continuous_service            in     varchar2 default hr_api.g_varchar2
  ,p_all_assignments               in     varchar2 default hr_api.g_varchar2
  ,p_period_years                  in     number   default hr_api.g_number
  ,p_period_days                   in     number   default hr_api.g_number
  ,p_shp_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_shp_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_shp_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_shp_information1              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information2              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information3              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information4              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information5              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information6              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information7              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information8              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information9              in     varchar2 default hr_api.g_varchar2
  ,p_shp_information10             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information11             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information12             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information13             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information14             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information15             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information16             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information17             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information18             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information19             in     varchar2 default hr_api.g_varchar2
  ,p_shp_information20             in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_service_history_period >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Employment Service History period information for an
 * employee assignment.
 *
 * This API deletes Employment Service History period information for an
 * employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An employment service history record for this assignment should exist before
 * deleting.
 *
 * <p><b>Post Success</b><br>
 * The employment service history record will be successfully deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The employment service history record will not be deleted and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_service_history_period_id {@rep:casecolumn
 * PQP_SERVICE_HISTORY_PERIODS.SERVICE_HISTORY_PERIOD_ID}
 * @param p_object_version_number Current version number of the employment
 * service history to be deleted.
 * @rep:displayname Delete Employment Service History
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_service_history_period
  (p_validate                      in     boolean  default false
  ,p_service_history_period_id     in     number
  ,p_object_version_number         in     number
  );
--
end pqp_shp_api;

 

/
