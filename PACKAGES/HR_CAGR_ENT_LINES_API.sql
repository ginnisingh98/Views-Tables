--------------------------------------------------------
--  DDL for Package HR_CAGR_ENT_LINES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENT_LINES_API" AUTHID CURRENT_USER AS
/* $Header: pepclapi.pkh 120.2 2006/10/18 09:24:31 grreddy noship $ */
/*#
 * This package contains APIs that maintain entitlement lines used by
 * collective agreements.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Collective Agreement Entitlement Line
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_entitlement_line >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a collective agreement entitlement line.
 *
 * An entitlement line is an instance of an entitlement item for a specific
 * collective agreement that holds a specific value. There may be one or more
 * entitlement lines for each entitlement item used by a collective agreement.
 * For example, the 'Health Workers Collective Agreement' may have one
 * entitlement line for the item 'Normal Working Hours' holding the value 40,
 * and another line holding the value 45. The collective agreement process
 * determines whether a person receives the line based on eligibility profile
 * associated with the line.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement entitlement must exist.
 *
 * <p><b>Post Success</b><br>
 * The entitlement line is created.
 *
 * <p><b>Post Failure</b><br>
 * The entitlement line is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_entitlement_line_id If p_validate is false, then this uniquely
 * identifies the entitlement line created. If p_validate is true, then set to
 * null.
 * @param p_mandatory Collective agreement processing always determines the
 * entitlement line as eligible, irrespective of eligibility profile.
 * @param p_value If collective agreement processing determines the entitlement
 * line as eligible and the parent item category is 'Assignment', the
 * entitlement line value is assigned to the person.
 * @param p_range_from The lower bound of an allowed range of values (instead
 * of a specific value).
 * @param p_range_to The upper bound of an allowed range of values (instead of
 * a specific value).
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created entitlement line. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created entitlement line. If p_validate is true,
 * then set to null.
 * @param p_grade_spine_id If collective agreement processing determines the
 * entitlement line as eligible and the parent item category is 'Grade', the
 * entitlement line value is assigned to the person.
 * @param p_parent_spine_id If collective agreement processing determines the
 * entitlement line as eligible and the parent item category is 'Pay Scale',
 * the entitlement line value is assigned to the person.
 * @param p_cagr_entitlement_id The parent collective agreement entitlement to
 * which this line belongs.
 * @param p_status The status of the record. Valid values are defined by the
 * 'CAGR_STATUS' lookup type.
 * @param p_eligy_prfl_id The eligibility profile which is used to determine
 * whether this line is valid for a person, or not.
 * @param p_step_id The specific grade step to which the entitlement line
 * relates.
 * @param p_from_step_id The lower grade step to which the entitlement line
 * relates.
 * @param p_to_step_id The upper grade step to which the entitlement line
 * relates.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created entitlement line. If p_validate is true, then
 * the value will be null.
 * @param p_oipl_id The option in plan record to which this line relates.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @rep:displayname Create Entitlement Line
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_entitlement_line
(
   p_validate                       in boolean    default false
  ,p_cagr_entitlement_line_id       out nocopy number
  ,p_mandatory                      in  varchar2
  ,p_value                          in  varchar2  default null
  ,p_range_from                     in  varchar2  default null
  ,p_range_to                       in  varchar2  default null
  ,p_effective_start_date               out nocopy date
  ,p_effective_end_date                 out nocopy date
  ,p_grade_spine_id                 in  number    default null
  ,p_parent_spine_id                in  number    default null
  ,p_cagr_entitlement_id            in  number
  ,p_status                         in  varchar2
  ,p_eligy_prfl_id                  in  number
  ,p_step_id                        in  number    default null
  ,p_from_step_id                   in  number    default null
  ,p_to_step_id                     in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_oipl_id                           OUT NOCOPY  NUMBER
  ,p_effective_date                 in  date
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_entitlement_line >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a collective agreement entitlement line.
 *
 * An entitlement line is an instance of an entitlement item for a specific
 * collective agreement that holds a specific value. There may be one or more
 * entitlement lines for each entitlement item used by a collective agreement.
 * For example the 'Health Workers Collective Agreement' may have one
 * entitlement line for the item 'Normal Working Hours' holding the value 40,
 * and another line holding the value 45. The collective agreement process
 * determines whether a person receives the line based on eligibility profile
 * associated with the line.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The entitlement line must exist.
 *
 * <p><b>Post Success</b><br>
 * The entitlement line is updated.
 *
 * <p><b>Post Failure</b><br>
 * The entitlement line is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_entitlement_line_id Uniquely identifies the entitlement line.
 * @param p_mandatory Collective agreement processing always determines the
 * entitlement line as eligible, irrespective of eligibility profile.
 * @param p_value If collective agreement processing determines the entitlement
 * line as eligible and the parent item category is 'Assignment', the
 * entitlement line value is assigned to the person.
 * @param p_range_from The lower bound of an allowed range of values (instead
 * of a specific value).
 * @param p_range_to The upper bound of an allowed range of values (instead of
 * a specific value).
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated entitlement line row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated entitlement line row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_grade_spine_id If collective agreement processing determines the
 * entitlement line as eligible and the parent item category is 'Grade', the
 * entitlement line value is assigned to the person.
 * @param p_parent_spine_id If collective agreement processing determines the
 * entitlement line as eligible and the parent item category is 'Pay Scale',
 * the entitlement line value is assigned to the person.
 * @param p_cagr_entitlement_id The parent collective agreement entitlement to
 * which this line belongs.
 * @param p_status The status of the record. Valid values are defined by the
 * 'CAGR_STATUS' lookup type.
 * @param p_oipl_id The option in plan record to which this line relates.
 * @param p_eligy_prfl_id The eligibility profile which is used to determine
 * whether this line is valid for a person, or not.
 * @param p_step_id The specific grade step to which the entitlement line
 * relates.
 * @param p_from_step_id The lower grade step to which the entitlement line
 * relates.
 * @param p_to_step_id The upper grade step to which the entitlement line
 * relates.
 * @param p_object_version_number Pass in the current version number of the
 * entitlement to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated entitlement. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @rep:displayname Update Entitlement Line
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_entitlement_line
  (
   p_validate                       in boolean    default false
  ,p_cagr_entitlement_line_id       in  number
  ,p_mandatory                      in  varchar2  default hr_api.g_varchar2
  ,p_value                          in  varchar2  default hr_api.g_varchar2
  ,p_range_from                     in  varchar2  default hr_api.g_varchar2
  ,p_range_to                       in  varchar2  default hr_api.g_varchar2
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_grade_spine_id                 in  number    default hr_api.g_number
  ,p_parent_spine_id                in  number    default hr_api.g_number
  ,p_cagr_entitlement_id            in  number    default hr_api.g_number
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_step_id                        in  number    default hr_api.g_number
  ,p_from_step_id                   in  number    default hr_api.g_number
  ,p_to_step_id                     in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_entitlement_line >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a collective agreement entitlement line.
 *
 * An entitlement line is an instance of an entitlement item for a collective
 * agreement that holds a specific value. There may be one or more entitlement
 * lines for each entitlement item used by a collective agreement. For example
 * the 'Health Workers Collective Agreement' may have one entitlement line for
 * the item 'Normal Working Hours' holding the value 40, and another line
 * holding the value 45. The collective agreement process determines whether a
 * person receives the line based on eligibility profile associated with the
 * line.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The entitlement line must exist.
 *
 * <p><b>Post Success</b><br>
 * The entitlement line is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The entitlement line is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_entitlement_line_id Uniquely identifies the entitlement line.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted entitlement line row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted entitlement line row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_object_version_number Current version number of the entitlement
 * line to be deleted.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @rep:displayname Delete Entitlement Line
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_entitlement_line
  (
   p_validate                       in boolean        default false
  ,p_cagr_entitlement_line_id       in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
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
--   p_cagr_entitlement_line_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
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
    p_cagr_entitlement_line_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
  );
--
end hr_cagr_ent_lines_api;

/
