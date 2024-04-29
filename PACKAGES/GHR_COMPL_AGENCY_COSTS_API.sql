--------------------------------------------------------
--  DDL for Package GHR_COMPL_AGENCY_COSTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPL_AGENCY_COSTS_API" AUTHID CURRENT_USER as
/* $Header: ghcstapi.pkh 120.3 2006/10/11 14:13:52 utokachi noship $ */
/*#
 * This package contains the procedures for creating, updating
 * and deleting GHR Complaints Tracking Agency Cost records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complaint Agency Costs
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_agency_costs> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates a Complaints Tracking Agency Cost record.
 *
 * This API creates a child Agency Cost record for a Complaint
 * in table ghr_compl_agency_costs.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Complaint must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The API creates a Complaint Agency Cost record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Complaint Agency Cost record
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_complaint_id Uniquely identifies the Complaint.
 * @param p_phase Complaint Agency Cost Phase. Valid values
 * are defined by 'GHR_US_PRE_COST_PHASES' lookup type.
 * @param p_stage Complaint Agency Cost Stage. Valid values
 * are defined by 'GHR_US_STAGE' lookup type.
 * @param p_category Complaint Agency Cost Category.  Valid values are derived
 * by the 'GHR_US_STAGE' lookup type code value selected in
 * Complaint Agency Cost Stage.
 * @param p_amount Complaint Agency Cost amount.
 * @param p_cost_date	Complaint Agency Cost Date.
 * @param p_description Complaint Agency Cost Description.
 * @param p_compl_agency_cost_id If p_validate is false, then this uniquely
 * identifies the Complaint Agency Cost created. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Complaint Agency Cost. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Complaint Agency Cost
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/

--
-- Description:
--
--   This api creates a Complaints Agency Cost records in the ghr_compl_agency_costs table.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--   The api will set the following out parameters:
--
--    p_compl_agency_cost_id       number
--    p_object_version_number      number
--
-- Post Failure:
--   The api will not create the Complaint Agency Cost record and  raises an error.
--
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_agency_costs
  (p_validate                       in  boolean  default false
  ,p_effective_date                 in  date
  ,p_complaint_id                   in  number
  ,p_phase                          in  varchar2 default null
  ,p_stage                          in  varchar2 default null
  ,p_category                       in  varchar2 default null
  ,p_amount                         in  number   default null
  ,p_cost_date                      in  date     default null
  ,p_description                    in  varchar2 default null
  ,p_compl_agency_cost_id           out nocopy number
  ,p_object_version_number          out nocopy number
   );
--


-- ----------------------------------------------------------------------------
-- |--------------------------<update_agency_costs> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API updates a Complaints Tracking Agency Cost record.
 *
 * This API updates a child Agency Cost record in table
 * ghr_compl_agency_costs for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Complaint must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Complaint Agency Cost record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Complaint Agency Cost record
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_agency_cost_id Uniquely identifies the Complaint Agency Cost
 * record to be updated.
 * @param p_complaint_id Uniquely identifies the Complaint.
 * @param p_phase Complaint Agency Cost Phase. Valid values
 * are defined by 'GHR_US_PRE_COST_PHASES' lookup type.
 * @param p_stage Complaint Agency Cost Stage. Valid values
 * are defined by 'GHR_US_STAGE' lookup type.
 * @param p_category Complaint Agency Cost Category.  Valid values are derived
 * by the 'GHR_US_STAGE' lookup type code value selected in Cost Stage.
 * @param p_amount Complaint Agency Cost amount.
 * @param p_cost_date Complaint Agency Cost Date.
 * @param p_description Complaint Agency Cost Description.
 * @param p_object_version_number Pass in the current version number of the
 * Agency Cost to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Agency Cost.
 * If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Complaint Agency Cost
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/

--
-- Description:
--
--   This api updates a Complaint Agency Cost record in the ghr_compl_agency_costs table.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--   The api will set the following out parameters:
--
--    p_object_version_number      number
--
-- Post Failure:
--   The api will not update the Complaint Agency Cost record and raises an error
--
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_agency_costs
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_compl_agency_cost_id           in     number
  ,p_complaint_id                   in     number   default hr_api.g_number
  ,p_phase                          in     varchar2 default hr_api.g_varchar2
  ,p_stage                          in     varchar2 default hr_api.g_varchar2
  ,p_category                       in     varchar2 default hr_api.g_varchar2
  ,p_amount                         in     number   default hr_api.g_number
  ,p_cost_date                      in     date     default hr_api.g_date
  ,p_description                    in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |--------------------------<delete_agency_costs> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API deletes a Complaints Tracking Agency Cost record.
 *
 * This API deletes a child Agency Cost record from table ghr_compl_agency_costs
 * for an existing parent Complaint.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Complaint record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Complaint Agency Cost record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Complaint Agency Cost record
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_compl_agency_cost_id Uniquely identifies the Complaint Agency Cost
 * record to be deleted.
 * @param p_object_version_number Current version number of the
 * Complaint Agency Cost to be deleted.
 * @rep:displayname Delete Complaint Agency Cost
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/

--
-- Description:
--
--   This api deletes a Complaints Agency Costs record in the ghr_compl_agency_costs table.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--  The complaints Agency Costs record is deleted.
--
--
-- Post Failure:
--   The api will not delete the complaints Agency Costs record and raises an error.
--
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_agency_costs
  (p_validate                      in     boolean  default false
  ,p_compl_agency_cost_id          in     number
  ,p_object_version_number         in     number
  );

end ghr_compl_agency_costs_api;

 

/
