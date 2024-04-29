--------------------------------------------------------
--  DDL for Package HR_AU_SUPER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AU_SUPER_API" AUTHID CURRENT_USER as
/* $Header: hrauwrsu.pkh 120.1 2005/10/02 01:59:37 aroussel $ */
/*#
 * This package contains superannuation contribution APIs for Australia.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Superannuation Contribution for Australia
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_super_contribution >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Super Contribution details for the Australian localization.
 *
 * This API updates the Super Contribution element details when the element is
 * attached to assignment of Australian legislation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business_group_id and valid assignment for the Employee of
 * Australian Legislation must exist. The super contribution element should be
 * linked with assignment as of the effective date of update.
 *
 * <p><b>Post Success</b><br>
 * The element entries of Super Contribution element will be successfully
 * updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the super contribution element and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_session_date Determines when the DateTrack operation takes effect.
 * @param p_mode Indicates which DateTrack mode to use when updating the
 * record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_business_group_id Australia Business group in which the employee is
 * present
 * @param p_element_entry_id {@rep:casecolumn
 * PAY_ELEMENT_ENTRIES_F.ELEMENT_ENTRY_ID}
 * @param p_super_fund_name Name of the superannuation fund.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_pay_value Pay value of the Superannuation Contribution.
 * @param p_member_number Member number.
 * @param p_sg_amount Super Guarantee amount.
 * @param p_sg_percent Super Guarantee percentage.
 * @param p_non_sg_amount Non-Super Guarantee amount.
 * @param p_non_sg_percent Non-Super Guarantee percentage.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated super contribution row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated super contribution row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_update_warning If p_validate is false,set to true if warnings
 * occurred while processing the element entry.If p_validate is true,then the
 * value will be null.
 * @rep:displayname Update Superannuation Contribution for Australia
 * @rep:category BUSINESS_ENTITY HR_SUPER_CONTRIBUTION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure update_super_contribution
  (p_validate                     in      boolean
  ,p_assignment_id                in      number
  ,p_session_date                 in      date
  ,p_mode                         in      varchar2
  ,p_business_group_id            in      number
  ,p_element_entry_id             in      number
  ,p_super_fund_name              in      varchar2
  ,p_attribute_category           in      varchar2  default null
  ,p_attribute1                   in      varchar2  default null
  ,p_attribute2                   in      varchar2  default null
  ,p_attribute3                   in      varchar2  default null
  ,p_attribute4                   in      varchar2  default null
  ,p_attribute5                   in      varchar2  default null
  ,p_attribute6                   in      varchar2  default null
  ,p_attribute7                   in      varchar2  default null
  ,p_attribute8                   in      varchar2  default null
  ,p_attribute9                   in      varchar2  default null
  ,p_attribute10                  in      varchar2  default null
  ,p_attribute11                  in      varchar2  default null
  ,p_attribute12                  in      varchar2  default null
  ,p_attribute13                  in      varchar2  default null
  ,p_attribute14                  in      varchar2  default null
  ,p_attribute15                  in      varchar2  default null
  ,p_attribute16                  in      varchar2  default null
  ,p_attribute17                  in      varchar2  default null
  ,p_attribute18                  in      varchar2  default null
  ,p_attribute19                  in      varchar2  default null
  ,p_attribute20                  in      varchar2  default null
  ,p_pay_value                    in      number    default null
  ,p_member_number                in      varchar2
  ,p_sg_amount                    in      number    default null
  ,p_sg_percent                   in      number    default null
  ,p_non_sg_amount                in      number    default null
  ,p_non_sg_percent               in      number    default null
  ,p_effective_start_date            out NOCOPY  date
  ,p_effective_end_date              out NOCOPY  date
  ,p_update_warning                  out NOCOPY  boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_super_contribution >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Super Contribution details for Australia.
 *
 * This API creates the Super Contribution element details when the element is
 * assigned to assignment of Australian legislation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business_group_id and valid assignment for the Employee of
 * Australian Legislation must exist.
 *
 * <p><b>Post Success</b><br>
 * The element entries of Super Contribution element will be successfully
 * inserted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the super contribution element and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_business_group_id Australia Business group in which the employee is
 * present
 * @param p_original_entry_id {@rep:casecolumn
 * PAY_ELEMENT_ENTRIES_F.ELEMENT_ENTRY_ID}
 * @param p_assignment_id Identifies the assignment for which you create the
 * super contribution record.
 * @param p_entry_type Entry Type. Valid values are defined by the 'ENTRY_TYPE'
 * lookup type.
 * @param p_cost_allocation_keyflex_id {@rep:casecolumn
 * PAY_ELEMENT_ENTRIES_F.COST_ALLOCATION_KEYFLEX_ID}
 * @param p_updating_action_id {@rep:casecolumn
 * PAY_ELEMENT_ENTRIES_F.UPDATING_ACTION_ID}
 * @param p_comment_id Comment text identifier.
 * @param p_reason Reason.Valid values are defined by the 'ELE_ENTRY_REASON'
 * lookup type.
 * @param p_target_entry_id {@rep:casecolumn
 * PAY_ELEMENT_ENTRIES_F.TARGET_ENTRY_ID}
 * @param p_subpriority Subpriority input value.
 * @param p_date_earned Date Earned input value.
 * @param p_super_fund_name Name of the superannuation fund.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_pay_value Pay value of the Super Contribution.
 * @param p_member_number Member number.
 * @param p_sg_amount Super Guarantee amount.
 * @param p_sg_percent Super Guarantee percentage.
 * @param p_non_sg_amount Non-Super Guarantee amount.
 * @param p_non_sg_percent Non-Super Guarantee percentage.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created super contribution. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created super contribution. If p_validate is
 * true, then set to null.
 * @param p_element_entry_id If p_validate is false,then set to value of the
 * created super contribution element entry id.If p_validate is true,then the
 * value will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created super contribution. If p_validate is true,
 * then the value will be null.
 * @param p_create_warning If p_validate is false,set to true if warnings
 * occurred while processing the element entry.If p_validate is true,then the
 * value will be null.
 * @rep:displayname Create Superannuation Contribution for Australia
 * @rep:category BUSINESS_ENTITY HR_SUPER_CONTRIBUTION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure create_super_contribution
  (p_validate                      in     boolean     default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_original_entry_id             in     number      default null
  ,p_assignment_id                 in     number
  ,p_entry_type                    in     varchar2
  ,p_cost_allocation_keyflex_id    in     number      default null
  ,p_updating_action_id            in     number      default null
  ,p_comment_id                    in     number      default null
  ,p_reason                        in     varchar2    default null
  ,p_target_entry_id               in     number      default null
  ,p_subpriority                   in     number      default null
  ,p_date_earned                   in     date        default null
  ,p_super_fund_name               in     varchar2
  ,p_attribute_category            in     varchar2    default null
  ,p_attribute1                    in     varchar2    default null
  ,p_attribute2                    in     varchar2    default null
  ,p_attribute3                    in     varchar2    default null
  ,p_attribute4                    in     varchar2    default null
  ,p_attribute5                    in     varchar2    default null
  ,p_attribute6                    in     varchar2    default null
  ,p_attribute7                    in     varchar2    default null
  ,p_attribute8                    in     varchar2    default null
  ,p_attribute9                    in     varchar2    default null
  ,p_attribute10                   in     varchar2    default null
  ,p_attribute11                   in     varchar2    default null
  ,p_attribute12                   in     varchar2    default null
  ,p_attribute13                   in     varchar2    default null
  ,p_attribute14                   in     varchar2    default null
  ,p_attribute15                   in     varchar2    default null
  ,p_attribute16                   in     varchar2    default null
  ,p_attribute17                   in     varchar2    default null
  ,p_attribute18                   in     varchar2    default null
  ,p_attribute19                   in     varchar2    default null
  ,p_attribute20                   in     varchar2    default null
  ,p_pay_value                     in     number      default null
  ,p_member_number                 in     varchar2
  ,p_sg_amount                     in     number      default null
  ,p_sg_percent                    in     number      default null
  ,p_non_sg_amount                 in     number      default null
  ,p_non_sg_percent                in     number      default null
  ,p_effective_start_date             out NOCOPY date
  ,p_effective_end_date               out NOCOPY date
  ,p_element_entry_id                 out NOCOPY number
  ,p_object_version_number            out NOCOPY number
  ,p_create_warning                   out NOCOPY boolean
  );
  --
end hr_au_super_api;

 

/
