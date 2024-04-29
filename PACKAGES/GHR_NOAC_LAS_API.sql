--------------------------------------------------------
--  DDL for Package GHR_NOAC_LAS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NOAC_LAS_API" AUTHID CURRENT_USER as
/* $Header: ghnlaapi.pkh 120.2 2005/10/02 01:57:53 aroussel $ */
/*#
 * This package contains the procedures for creating, updating, and deleting US
 * Federal Human Resources Nature of Actions (NOACs) and Legal Authority codes
 * (LACs) combination records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Nature of Action / Legal Authority Code Combination
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_noac_las >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Nature of Action Code / Legal Authority Code combination
 * records.
 *
 * Creates a Nature of Action Code / Legal Authority Code combination record in
 * the table GHR_noac_las for an existing parent nature of action id.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent nature of action id record must exist in GHR_nature_of_actions.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Nature of Action Code/Legal Authority Code combination
 * record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Nature of Action Code / Legal Authority Code
 * combination record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_noac_la_id If p_validate is false, then this uniquely identifies
 * the Nature of Action/Legal Authority combination record created. If
 * p_validate is true, then set to null.
 * @param p_nature_of_action_id {@rep:casecolumn
 * GHR_NATURE_OF_ACTIONS.NATURE_OF_ACTION_ID}
 * @param p_lac_lookup_code Legal Authority lookup code. Valid values are
 * defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_enabled_flag {@rep:casecolumn GHR_NOAC_LAS.ENABLED_FLAG}
 * @param p_date_from {@rep:casecolumn GHR_NOAC_LAS.DATE_FROM}
 * @param p_date_to {@rep:casecolumn GHR_NOAC_LAS.DATE_TO}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Nature of Action and Legal Authority id. If
 * p_validate is true, then the value will be null.
 * @param p_valid_first_lac_flag {@rep:casecolumn
 * GHR_NOAC_LAS.VALID_FIRST_LAC_FLAG}
 * @param p_valid_second_lac_flag {@rep:casecolumn
 * GHR_NOAC_LAS.VALID_SECOND_LAC_FLAG}
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Nature of Action/Legal Authority Code Combination
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_noac_las
(
   p_validate                       in boolean    default false
  ,p_noac_la_id                     out NOCOPY number
  ,p_nature_of_action_id            in  number    default null
  ,p_lac_lookup_code                in  varchar2  default null
  ,p_enabled_flag                   in  varchar2  default null
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_object_version_number          out  NOCOPY number
  ,p_valid_first_lac_flag           in  varchar2  default null
  ,p_valid_second_lac_flag          in  varchar2  default null
  ,p_effective_date            in  date
 );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_noac_las >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Nature of Action Code / Legal Authority Code
 * combination records.
 *
 * This API updates a Nature of Action Code / Legal Authority Code combination
 * record in the table GHR_noac_las for an existing parent nature of action id.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent nature of action id record must exist in GHR_nature_of_actions.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Nature of Action Code / Legal Authority Code combination
 * record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Nature of Action Code / Legal Authority Code
 * combination record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_noac_la_id Uniquely identifies the Nature of Action/Legal Authority
 * Code combination.
 * @param p_nature_of_action_id {@rep:casecolumn
 * GHR_NATURE_OF_ACTIONS.NATURE_OF_ACTION_ID}
 * @param p_lac_lookup_code Legal Authority lookup code. Valid values are
 * defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_enabled_flag {@rep:casecolumn GHR_NOAC_LAS.ENABLED_FLAG}
 * @param p_date_from {@rep:casecolumn GHR_NOAC_LAS.DATE_FROM}
 * @param p_date_to {@rep:casecolumn GHR_NOAC_LAS.DATE_TO}
 * @param p_object_version_number Pass in the current version number of the
 * Nature of Action Code and Legal Authority code id to be updated. When the
 * API completes if p_validate is false, will be set to the new version number
 * of the updated noac_la_id. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_valid_first_lac_flag {@rep:casecolumn
 * GHR_NOAC_LAS.VALID_FIRST_LAC_FLAG}
 * @param p_valid_second_lac_flag {@rep:casecolumn
 * GHR_NOAC_LAS.VALID_SECOND_LAC_FLAG}
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Nature of Action/Legal Authority Code Combination
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_noac_las
  (
   p_validate                       in boolean    default false
  ,p_noac_la_id                     in  number
  ,p_nature_of_action_id            in  number    default hr_api.g_number
  ,p_lac_lookup_code                in  varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_object_version_number          in out  NOCOPY  number
  ,p_valid_first_lac_flag           in  varchar2  default hr_api.g_varchar2
  ,p_valid_second_lac_flag          in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_noac_las >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Nature of Action Code / Legal Authority Code combination
 * records.
 *
 * This API deletes a Nature of Action Code / Legal Authority Code combination
 * record in the table GHR_noac_las for an existing parent nature of action id.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Nature of Action Code/Legal Authority combination record specified must
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Nature of Action Code / Legal Authority Code combination
 * record from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Nature of Action Code / Legal Authority Code
 * combination record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_noac_la_id Uniquely identifies the Nature of Action/Legal Authority
 * Code combination.
 * @param p_object_version_number Current version number of the Nature of
 * Action Code / Legal Authority Code combination to be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Nature of Action/Legal Authority Code Combination
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_noac_las
  (
   p_validate                       in boolean        default false
  ,p_noac_la_id                     in  number
  ,p_object_version_number          in out  NOCOPY  number
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
--   p_noac_la_id                 Yes  number   PK of record
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
    p_noac_la_id                 in number
   ,p_object_version_number        in number
  );
--
end ghr_noac_las_api;

 

/
