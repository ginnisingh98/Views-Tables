--------------------------------------------------------
--  DDL for Package GHR_PA_REMARKS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PA_REMARKS_API" AUTHID CURRENT_USER as
/* $Header: ghpreapi.pkh 120.3 2006/07/07 12:43:15 vnarasim noship $ */
/*#
 * This package contains the procedures for creating, updating, and deleting
 * Request for Personnel Action (RPA) Remarks where the user has entered
 * insertion values.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Request for Personnel Action Remark
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_pa_remarks >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Request for Personnel Action (RPA) Remark record.
 *
 * This API creates a Request for Personnel Action (RPA) Remark record
 * containing a user entered insertion value in the GHR_pa_remarks table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent pa request id record must exist in GHR_pa_requests and remark_id
 * must exist in GHR_remarks.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Request for Personnel Action (RPA) Remark record in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Request for Personnel Action (RPA) Remark record
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pa_request_id {@rep:casecolumn GHR_PA_REQUESTS.PA_REQUEST_ID}
 * @param p_remark_id {@rep:casecolumn GHR_REMARKS.REMARK_ID}
 * @param p_description {@rep:casecolumn GHR_PA_REMARKS.DESCRIPTION}
 * @param p_remark_code_information1 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION1}
 * @param p_remark_code_information2 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION2}
 * @param p_remark_code_information3 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION3}
 * @param p_remark_code_information4 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION4}
 * @param p_remark_code_information5 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION5}
 * @param p_pa_remark_id If p_validate is false, then this uniquely identifies
 * the Request for Personnel Action (RPA) Remark record created. If p_validate
 * is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Personnel Action_remark_id. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Request for Personnel Action Remark
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pa_remarks
  (p_validate                      in     boolean   default false
  ,p_pa_request_id 	           in     number
  ,p_remark_id                     in     number
  ,p_description                   in     varchar2  default null
  ,p_remark_code_information1      in     varchar2  default null
  ,p_remark_code_information2      in     varchar2  default null
  ,p_remark_code_information3      in     varchar2  default null
  ,p_remark_code_information4      in     varchar2  default null
  ,p_remark_code_information5      in     varchar2  default null
  ,p_pa_remark_id                  out nocopy   number
  ,p_object_version_number         out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_pa_remarks >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Request for Personnel Action (RPA) Remark record in the
 * GHR_pa_remarks table.
 *
 * This API updates the Request for Personnel Action (RPA) Remark record
 * containing a user entered insertion value in the GHR_pa_remarks table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent pa request id record must exist in GHR_pa_requests and remark_id
 * must exist in GHR_remarks.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Request for Personnel Action (RPA) Remark record in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Request for Personnel Action (RPA) Remark record
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pa_remark_id Uniquely identifies the Request for Personnel Action
 * (RPA) Remark record.
 * @param p_object_version_number Pass in the current version number of the
 * Personnel Action_remark_id to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Personnel Action_remark_id. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_remark_code_information1 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION1}
 * @param p_remark_code_information2 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION2}
 * @param p_remark_code_information3 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION3}
 * @param p_remark_code_information4 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION4}
 * @param p_remark_code_information5 {@rep:casecolumn
 * GHR_PA_REMARKS.REMARK_CODE_INFORMATION5}
 * @param p_description {@rep:casecolumn GHR_PA_REMARKS.DESCRIPTION}
 * @rep:displayname Update Request for Personnel Action Remark
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pa_remarks
  (p_validate                      in     boolean  default false
  ,p_pa_remark_id                  in     number
  ,p_object_version_number         in out nocopy  number
  ,p_remark_code_information1      in     varchar2  default hr_api.g_varchar2
  ,p_remark_code_information2      in     varchar2  default hr_api.g_varchar2
  ,p_remark_code_information3      in     varchar2  default hr_api.g_varchar2
  ,p_remark_code_information4      in     varchar2  default hr_api.g_varchar2
  ,p_remark_code_information5      in     varchar2  default hr_api.g_varchar2
  ,p_description                   in     varchar2  default hr_api.g_varchar2
   );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_pa_remarks >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Request for Personnel Action (RPA) Remark record from
 * the GHR_pa_remarks table.
 *
 * This API deletes the Request for Personnel Action (RPA) Remark record
 * containing a user entered insertion value from the GHR_pa_remarks table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Personnel Action Remark record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The Request for Personnel Action (RPA) Remark record is deleted from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Request for Personnel Action (RPA) Remark record
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pa_remark_id Uniquely identifies the Request for Personnel Action
 * (RPA) Remark record.
 * @param p_object_version_number Current version number of the Request for
 * Personnel Action (RPA) Remark record to be deleted.
 * @rep:displayname Delete Request for Personnel Action Remark
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_pa_remarks
  (p_validate                      in     boolean  default false
  ,p_pa_remark_id                  in     number
  ,p_object_version_number         in     number
  );
end ghr_pa_remarks_api;

 

/
