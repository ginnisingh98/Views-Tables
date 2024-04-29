--------------------------------------------------------
--  DDL for Package GHR_COMPLAINT_BASES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_COMPLAINT_BASES_API" AUTHID CURRENT_USER as
/* $Header: ghcbaapi.pkh 120.1 2005/10/02 01:57:14 aroussel $ */
/*#
 * This package contains the procedures for creating, updating and deleting GHR
 * Complaints Tracking Complaint Bases records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Complaint Base
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_compl_basis >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Complaints Tracking Complaint Basis record.
 *
 * This API creates a child Basis record in table ghr_compl_bases for an
 * existing parent Claim.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Claim record must exist in ghr_compl_claims.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Basis record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Basis record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_claim_id Uniquely identifies the Parent Claim record.
 * @param p_basis Claim Basis Category. Valid values are defined by the
 * 'GHR_US_BASIS_CATEGORY' lookup type.
 * @param p_value Claim Basis Value. Valid values are derived by the
 * 'GHR_US_BASIS_CATEGORY' lookup type code value selected in Claim Bases.
 * @param p_statute Basis Statute. Valid values are defined by
 * 'GHR_US_BASIS_STATUTE' lookup type.
 * @param p_agency_finding Basis Agency Finding. Valid values are defined by
 * 'GHR_US_FINDING' lookup type.
 * @param p_aj_finding Basis Administrative Judge (AJ) Finding. Valid values
 * are defined by 'GHR_US_FINDING' lookup type.
 * @param p_compl_basis_id If p_validate is false, then this uniquely
 * identifies the Basis created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Basis. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Complaint Basis
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_compl_basis
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_compl_claim_id               in number
  ,p_basis                        in varchar2 default null
  ,p_value                        in varchar2 default null
  ,p_statute                      in varchar2 default null
  ,p_agency_finding               in varchar2 default null
  ,p_aj_finding                   in varchar2 default null
  ,p_compl_basis_id               out nocopy number
  ,p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_compl_basis >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Complaints Tracking Complaint Basis record.
 *
 * This API updates a child Basis record in table ghr_compl_bases for an
 * existing parent Claim.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Claim record must exist in ghr_compl_claims.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Basis record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Basis record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_compl_basis_id Uniquely identifies the Basis record to be updated.
 * @param p_compl_claim_id Uniquely identifies the Parent Claim record.
 * @param p_basis Claim Basis Category. Valid values are defined by
 * 'GHR_US_BASIS_CATEGORY' lookup type.
 * @param p_value Claim Basis Value. Valid values are derived by the
 * 'GHR_US_BASIS_CATEGORY' lookup type code value selected in Claim Bases.
 * @param p_statute Basis Statute. Valid values are defined by
 * 'GHR_US_BASIS_STATUTE' lookup type.
 * @param p_agency_finding Basis Agency Finding. Valid values are defined by
 * 'GHR_US_FINDING' lookup type.
 * @param p_aj_finding Basis Administrative Judge (AJ) Finding. Valid values
 * are defined by 'GHR_US_FINDING' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * Basis to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated Basis. If p_validate is true
 * will be set to the same value which was passed in.
 * @rep:displayname Update Complaint Basis
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_compl_basis
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_compl_basis_id               in number
  ,p_compl_claim_id               in number   default hr_api.g_number
  ,p_basis                        in varchar2 default hr_api.g_varchar2
  ,p_value                        in varchar2 default hr_api.g_varchar2
  ,p_statute                      in varchar2 default hr_api.g_varchar2
  ,p_agency_finding               in varchar2 default hr_api.g_varchar2
  ,p_aj_finding                   in varchar2 default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_compl_basis >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Complaints Tracking Complaint Basis record.
 *
 * This API deletes a child Basis record from table ghr_compl_bases for an
 * existing parent Claim.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Complaint Basis record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the Basis record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Basis record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_compl_basis_id Uniquely identifies the Basis record to be deleted.
 * @param p_object_version_number Current version number of the Basis to be
 * deleted.
 * @rep:displayname Delete Complaint Basis
 * @rep:category BUSINESS_ENTITY GHR_EEO_COMPLAINT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_compl_basis
  (p_validate                     in boolean  default false
  ,p_compl_basis_id               in number
  ,p_object_version_number        in number
  );
--
end ghr_complaint_bases_api;

 

/
