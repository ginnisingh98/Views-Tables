--------------------------------------------------------
--  DDL for Package GHR_NOAC_REMARKS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NOAC_REMARKS_API" AUTHID CURRENT_USER as
/* $Header: ghnreapi.pkh 120.2 2005/10/02 01:57:59 aroussel $ */
/*#
 * This package contains the procedures for creating, updating, and deleting US
 * Federal Human Resources Nature of actions (NOACs) and Remarks combination
 * records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Nature of Action Code /Remark combination
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_noac_remarks >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Nature of Action Code/Remark combination records.
 *
 * This API creates a Nature of Action Code/Remark combination record in the
 * table GHR_noac_remarks for an existing parent nature of action id and remark
 * id
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent nature of action id record must exist in GHR_nature_of_actions and
 * a parent remark_id record must exist in GHR_remarks.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Nature of Action Code / Remark combination record in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Nature of Action Code/Remark combination record
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_noac_remark_id If p_validate is false, then this uniquely
 * identifies the Nature of Action/Remark combination record created. If
 * p_validate is true, then set to null.
 * @param p_nature_of_action_id {@rep:casecolumn
 * GHR_NATURE_OF_ACTIONS.NATURE_OF_ACTION_ID}
 * @param p_remark_id {@rep:casecolumn GHR_REMARKS.REMARK_ID}
 * @param p_required_flag {@rep:casecolumn GHR_NOAC_REMARKS.REQUIRED_FLAG}
 * @param p_enabled_flag {@rep:casecolumn GHR_NOAC_REMARKS.ENABLED_FLAG}
 * @param p_date_from {@rep:casecolumn GHR_NOAC_REMARKS.DATE_FROM}
 * @param p_date_to {@rep:casecolumn GHR_NOAC_REMARKS.DATE_TO}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Noac_remarks_id. If p_validate is true, then
 * the value will be null.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Nature of Action/Remark Combination
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_noac_remarks
(
   p_validate                       in boolean    default false
  ,p_noac_remark_id                 out NOCOPY number
  ,p_nature_of_action_id            in  number    default null
  ,p_remark_id                      in  number    default null
  ,p_required_flag                  in  varchar2  default null
  ,p_enabled_flag                   in  varchar2  default null
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_object_version_number          out NOCOPY number
  ,p_effective_date            in  date
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_noac_remarks >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Nature of Action Code/Remark combination records.
 *
 * This API updates a Nature of Action Code/Remark combination record in the
 * table GHR_noac_remarks for an existing parent nature of action id.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent nature of action id record must exist in GHR_nature_of_actions and
 * a parent remark_id record must exist in GHR_remarks.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Nature of Action Code/Remark combination record in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Nature of Action/Remark combination record and
 * an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_noac_remark_id Uniquely identifies the Nature of action Code/Remark
 * combination record.
 * @param p_nature_of_action_id {@rep:casecolumn
 * GHR_NATURE_OF_ACTIONS.NATURE_OF_ACTION_ID}
 * @param p_remark_id {@rep:casecolumn GHR_REMARKS.REMARK_ID}
 * @param p_required_flag {@rep:casecolumn GHR_NOAC_REMARKS.REQUIRED_FLAG}
 * @param p_enabled_flag {@rep:casecolumn GHR_NOAC_REMARKS.ENABLED_FLAG}
 * @param p_date_from {@rep:casecolumn GHR_NOAC_REMARKS.DATE_FROM}
 * @param p_date_to {@rep:casecolumn GHR_NOAC_REMARKS.DATE_TO}
 * @param p_object_version_number Pass in the current version number of the
 * Nature of Action Code and remark code id to be updated. When the API
 * completes if p_validate is false, will be set to the new version number of
 * the updated Nature of Action Code and remark code id. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Nature of Action/Remark Combination
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_noac_remarks
  (
   p_validate                       in boolean    default false
  ,p_noac_remark_id                 in  number
  ,p_nature_of_action_id            in  number    default hr_api.g_number
  ,p_remark_id                      in  number    default hr_api.g_number
  ,p_required_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_noac_remarks >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Nature of Action Code/Remark combination records.
 *
 * This API deletes a Nature of Action Code/Remark combination records in the
 * table GHR_noac_remarks for an existing parent nature of action id.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Nature of Action Code/Remark combination record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Nature of Action Code/Remark combination records from
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Nature of action Code/Remark combination record
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_noac_remark_id Uniquely identifies the Nature of Action Code/Remark
 * combination record.
 * @param p_object_version_number Current version number of the Nature of
 * Action Code/Remark combination to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Nature of Action/Remark Combination
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_noac_remarks
  (
   p_validate                       in boolean        default false
  ,p_noac_remark_id                 in  number
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date            in date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_noac_remark_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_noac_remark_id                 in number
   ,p_object_version_number        in number
  );
--
end ghr_noac_remarks_api;

 

/
