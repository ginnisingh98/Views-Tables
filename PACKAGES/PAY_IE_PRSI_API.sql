--------------------------------------------------------
--  DDL for Package PAY_IE_PRSI_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_PRSI_API" AUTHID CURRENT_USER as
/* $Header: pysidapi.pkh 120.1 2005/10/02 02:34:20 aroussel $ */
/*#
 * This package contains the PRSI Details API for Ireland.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname PRSI Detail for Ireland
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_ie_prsi_details >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates PRSI details for Ireland.
 *
 * A PRSI Detail record is created for an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A PPS Number must exist for the person record.
 *
 * <p><b>Post Success</b><br>
 * A PRSI Details record is created for the assignment.
 *
 * <p><b>Post Failure</b><br>
 * No PRSI Details records are created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_assignment_id Identifies the assignment for which you created the
 * PRSI Details record.
 * @param p_contribution_class Social Insurance Contribution Class.
 * IE_PRSI_CONT_CLASS lookup.
 * @param p_overridden_subclass Subclass manual override value for one pay
 * period. IE_PRSI_CONT_SUBCLASS lookup.
 * @param p_soc_ben_flag Social Benefits Flag to indicate if a benefit is being
 * taken by the employee.
 * @param p_soc_ben_start_date Date the Social Benefit started.
 * @param p_overridden_ins_weeks Insurable Weeks manual override for one pay
 * period.
 * @param p_non_standard_ins_weeks Non Standard amount for Insurable Weeks for
 * continous pay periods.
 * @param p_exemption_start_date PRSI Exemption Start Date.
 * @param p_exemption_end_date PRSI Exemption End Date.
 * @param p_cert_issued_by Exemption Certificate Issued by.
 * @param p_director_flag The employee is a Director.
 * @param p_community_flag The employee is part of a Special Community
 * exemption.
 * @param p_prsi_details_id If p_validate is false, then this uniquely
 * identifies the prsi details record created. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created PRSI Details record. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created PRSI Details record. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created PRSI Details record. If p_validate is
 * true, then set to null.
 * @rep:displayname Create PRSI Detail for Ireland
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ie_prsi_details
  (p_validate                      in           boolean  default false
  ,p_effective_date                in           date
  ,p_assignment_id                 in           number
  ,p_contribution_class            in           varchar2
  ,p_overridden_subclass           in           varchar2 default  Null
  ,p_soc_ben_flag                  in           varchar2 default  Null
  ,p_soc_ben_start_date            in           date     default  Null
  ,p_overridden_ins_weeks          in           number   default  Null
  ,p_non_standard_ins_weeks        in           number   default  Null
  ,p_exemption_start_date          in           date     default  Null
  ,p_exemption_end_date            in           date     default  Null
  ,p_cert_issued_by                in           varchar2 default  Null
  ,p_director_flag                 in           varchar2 default  Null
  ,p_community_flag                in           varchar2 default  Null
  ,p_prsi_details_id               out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_ie_prsi_details >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates PRSI details for Ireland.
 *
 * A PRSI Detail record is updated for an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * p_prsi_details_id must exist at the time of the update for this assignment.
 *
 * <p><b>Post Success</b><br>
 * A PRSI Details record is updated for the assignment.
 *
 * <p><b>Post Failure</b><br>
 * No PRSI Details records are updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_prsi_details_id Identifies the prsi details record to be modified.
 * @param p_contribution_class Social Insurance Contribution Class.
 * IE_PRSI_CONT_CLASS lookup.
 * @param p_overridden_subclass Subclass manual override value for one pay
 * period. IE_PRSI_CONT_SUBCLASS lookup.
 * @param p_soc_ben_flag Social Benefits Flag to indicate if a benefit is being
 * taken by the employee.
 * @param p_soc_ben_start_date Date the Socail Benefit started.
 * @param p_overridden_ins_weeks Insurable Weeks manual override for one pay
 * period.
 * @param p_non_standard_ins_weeks Non Standard amount for Insurable Weeks for
 * continous pay periods.
 * @param p_exemption_start_date PRSI Exemption Start Date.
 * @param p_exemption_end_date PRSI Exemption End Date.
 * @param p_cert_issued_by Exemption Certificate Issued by.
 * @param p_director_flag The employee is a Director.
 * @param p_community_flag The employee is part of a Special Community
 * exemption.
 * @param p_object_version_number Pass in the current version number of the
 * PRSI Details record to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated PRSI Details
 * record. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated PRSI Details row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated PRSI Details row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update PRSI detail for Ireland
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ie_prsi_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_prsi_details_id               in     number
  ,p_contribution_class            in     varchar2 default hr_api.g_varchar2
  ,p_overridden_subclass           in     varchar2 default hr_api.g_varchar2
  ,p_soc_ben_flag                  in     varchar2 default hr_api.g_varchar2
  ,p_soc_ben_start_date            in     date     default hr_api.g_date
  ,p_overridden_ins_weeks          in     number   default hr_api.g_number
  ,p_non_standard_ins_weeks        in     number   default hr_api.g_number
  ,p_exemption_start_date          in     date     default hr_api.g_date
  ,p_exemption_end_date            in     date     default hr_api.g_date
  ,p_cert_issued_by                in     varchar2 default hr_api.g_varchar2
  ,p_director_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_community_flag                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_ie_prsi_details >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes PRSI details for Ireland.
 *
 * A PRSI Detail record is deleted for an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * p_prsi_details_id must exist at the time of the deletion for this
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * A PRSI Details record is deleted for the assignment.
 *
 * <p><b>Post Failure</b><br>
 * No PRSI Details records are deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_prsi_details_id Identifies the prsi details record to be deleted.
 * @param p_object_version_number Current version number of the PRSI Details
 * record to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted PRSI Details row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted PRSI Details row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete PRSI detail for Ireland
 * @rep:category BUSINESS_ENTITY HR_SOC_INS_CONTRIBUTIONS
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_ie_prsi_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_prsi_details_id               in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out nocopy    date
  ,p_effective_end_date            out nocopy    date
  );
--
end pay_ie_prsi_api;

 

/
