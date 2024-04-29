--------------------------------------------------------
--  DDL for Package PQH_POSITION_TRANSACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_POSITION_TRANSACTIONS_API" AUTHID CURRENT_USER as
/* $Header: pqptxapi.pkh 120.0 2005/05/29 02:22:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_position_transaction >------------------------|
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
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_action_date                  No   date
--   p_position_id                  No   number
--   p_availability_status_id       No   number
--   p_business_group_id            No   number    Business Group of Record
--   p_entry_step_id                No   number
--   p_entry_grade_rule_id                No   number
--   p_job_id                       No   number
--   p_location_id                  No   number
--   p_organization_id              No   number
--   p_pay_freq_payroll_id          No   number
--   p_position_definition_id       No   number
--   p_prior_position_id            No   number
--   p_relief_position_id           No   number
--   p_entry_grade_id        No   number
--   p_successor_position_id        No   number
--   p_supervisor_position_id       No   number
--   p_amendment_date               No   date
--   p_amendment_recommendation     No   varchar2
--   p_amendment_ref_number         No   varchar2
--   p_avail_status_prop_end_date   No   date
--   p_bargaining_unit_cd           No   varchar2
--   p_comments                     No   long
--   p_country1                     No   varchar2
--   p_country2                     No   varchar2
--   p_country3                     No   varchar2
--   p_current_job_prop_end_date    No   date
--   p_current_org_prop_end_date    No   date
--   p_date_effective               No   date
--   p_date_end                     No   date
--   p_earliest_hire_date           No   date
--   p_fill_by_date                 No   date
--   p_frequency                    No   varchar2
--   p_fte                          No   number
--   p_fte_capacity                 No   varchar2
--   p_location1                    No   varchar2
--   p_location2                    No   varchar2
--   p_location3                    No   varchar2
--   p_max_persons                  No   number
--   p_name                         No   varchar2
--   p_other_requirements           No   varchar2
--   p_overlap_period               No   number
--   p_overlap_unit_cd              No   varchar2
--   p_passport_required            No   varchar2
--   p_pay_term_end_day_cd          No   varchar2
--   p_pay_term_end_month_cd        No   varchar2
--   p_permanent_temporary_flag     No   varchar2
--   p_permit_recruitment_flag      No   varchar2
--   p_position_type                No   varchar2
--   p_posting_description          No   varchar2
--   p_probation_period             No   number
--   p_probation_period_unit_cd     No   varchar2
--   p_relocate_domestically        No   varchar2
--   p_relocate_internationally     No   varchar2
--   p_replacement_required_flag    No   varchar2
--   p_review_flag                  No   varchar2
--   p_seasonal_flag                No   varchar2
--   p_security_requirements        No   varchar2
--   p_service_minimum              No   varchar2
--   p_term_start_day_cd            No   varchar2
--   p_term_start_month_cd          No   varchar2
--   p_time_normal_finish           No   varchar2
--   p_time_normal_start            No   varchar2
--   p_transaction_status           No   varchar2
--   p_travel_required              No   varchar2
--   p_working_hours                No   number
--   p_works_council_approval_flag  No   varchar2
--   p_work_any_country             No   varchar2
--   p_work_any_location            No   varchar2
--   p_work_period_type_cd          No   varchar2
--   p_work_schedule                No   varchar2
--   p_work_duration                No   varchar2
--   p_work_term_end_day_cd         No   varchar2
--   p_work_term_end_month_cd       No   varchar2
--   p_proposed_fte_for_layoff      No   number
--   p_proposed_date_for_layoff     No   Date
--   p_information1                 No   varchar2
--   p_information2                 No   varchar2
--   p_information3                 No   varchar2
--   p_information4                 No   varchar2
--   p_information5                 No   varchar2
--   p_information6                 No   varchar2
--   p_information7                 No   varchar2
--   p_information8                 No   varchar2
--   p_information9                 No   varchar2
--   p_information10                No   varchar2
--   p_information11                No   varchar2
--   p_information12                No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--   p_information_category         No   varchar2
--   p_attribute1                   No   varchar2  Descriptive Flexfield
--   p_attribute2                   No   varchar2  Descriptive Flexfield
--   p_attribute3                   No   varchar2  Descriptive Flexfield
--   p_attribute4                   No   varchar2  Descriptive Flexfield
--   p_attribute5                   No   varchar2  Descriptive Flexfield
--   p_attribute6                   No   varchar2  Descriptive Flexfield
--   p_attribute7                   No   varchar2  Descriptive Flexfield
--   p_attribute8                   No   varchar2  Descriptive Flexfield
--   p_attribute9                   No   varchar2  Descriptive Flexfield
--   p_attribute10                  No   varchar2  Descriptive Flexfield
--   p_attribute11                  No   varchar2  Descriptive Flexfield
--   p_attribute12                  No   varchar2  Descriptive Flexfield
--   p_attribute13                  No   varchar2  Descriptive Flexfield
--   p_attribute14                  No   varchar2  Descriptive Flexfield
--   p_attribute15                  No   varchar2  Descriptive Flexfield
--   p_attribute16                  No   varchar2  Descriptive Flexfield
--   p_attribute17                  No   varchar2  Descriptive Flexfield
--   p_attribute18                  No   varchar2  Descriptive Flexfield
--   p_attribute19                  No   varchar2  Descriptive Flexfield
--   p_attribute20                  No   varchar2  Descriptive Flexfield
--   p_attribute21                  No   varchar2  Descriptive Flexfield
--   p_attribute22                  No   varchar2  Descriptive Flexfield
--   p_attribute23                  No   varchar2  Descriptive Flexfield
--   p_attribute24                  No   varchar2  Descriptive Flexfield
--   p_attribute25                  No   varchar2  Descriptive Flexfield
--   p_attribute26                  No   varchar2  Descriptive Flexfield
--   p_attribute27                  No   varchar2  Descriptive Flexfield
--   p_attribute28                  No   varchar2  Descriptive Flexfield
--   p_attribute29                  No   varchar2  Descriptive Flexfield
--   p_attribute30                  No   varchar2  Descriptive Flexfield
--   p_attribute_category           No   varchar2  Descriptive Flexfield
--   p_effective_date           Yes  date      Session Date.
--   p_pay_basis_id		No	number   Pay Basis
--   p_supervisor_id		No	number   Supervisor
--   p_wf_transaction_category_id   No	number   Wf Transaction Category Id
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_position_transaction_id      Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_position_transaction
(
   p_validate                       in boolean    default false
  ,p_position_transaction_id        out nocopy number
  ,p_action_date                    in  date      default null
  ,p_position_id                    in  number    default null
  ,p_availability_status_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id                  in  number    default null
  ,p_job_id                         in  number    default null
  ,p_location_id                    in  number    default null
  ,p_organization_id                in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_definition_id         in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id          in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_country1                       in  varchar2  default null
  ,p_country2                       in  varchar2  default null
  ,p_country3                       in  varchar2  default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_date_effective                 in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_fte_capacity                   in  varchar2  default null
  ,p_location1                      in  varchar2  default null
  ,p_location2                      in  varchar2  default null
  ,p_location3                      in  varchar2  default null
  ,p_max_persons                    in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_other_requirements             in  varchar2  default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_passport_required              in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default null
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_relocate_domestically          in  varchar2  default null
  ,p_relocate_internationally       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_service_minimum                in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_transaction_status             in  varchar2  default null
  ,p_travel_required                in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_any_country               in  varchar2  default null
  ,p_work_any_location              in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_schedule                  in  varchar2  default null
  ,p_work_duration                  in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_pay_basis_id		    in  number    default null
  ,p_supervisor_id		    in  number    default null
  ,p_wf_transaction_category_id	    in  number    default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_position_transaction >------------------------|
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
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_position_transaction_id      Yes  number    PK of record
--   p_action_date                  No   date
--   p_position_id                  No   number
--   p_availability_status_id       No   number
--   p_business_group_id            No   number    Business Group of Record
--   p_entry_step_id                No   number
--   p_entry_grade_rule_id                No   number
--   p_job_id                       No   number
--   p_location_id                  No   number
--   p_organization_id              No   number
--   p_pay_freq_payroll_id          No   number
--   p_position_definition_id       No   number
--   p_prior_position_id            No   number
--   p_relief_position_id           No   number
--   p_entry_grade_id        No   number
--   p_successor_position_id        No   number
--   p_supervisor_position_id       No   number
--   p_amendment_date               No   date
--   p_amendment_recommendation     No   varchar2
--   p_amendment_ref_number         No   varchar2
--   p_avail_status_prop_end_date   No   date
--   p_bargaining_unit_cd           No   varchar2
--   p_comments                     No   long
--   p_country1                     No   varchar2
--   p_country2                     No   varchar2
--   p_country3                     No   varchar2
--   p_current_job_prop_end_date    No   date
--   p_current_org_prop_end_date    No   date
--   p_date_effective               No   date
--   p_date_end                     No   date
--   p_earliest_hire_date           No   date
--   p_fill_by_date                 No   date
--   p_frequency                    No   varchar2
--   p_fte                          No   number
--   p_fte_capacity                 No   varchar2
--   p_location1                    No   varchar2
--   p_location2                    No   varchar2
--   p_location3                    No   varchar2
--   p_max_persons                  No   number
--   p_name                         No   varchar2
--   p_other_requirements           No   varchar2
--   p_overlap_period               No   number
--   p_overlap_unit_cd              No   varchar2
--   p_passport_required            No   varchar2
--   p_pay_term_end_day_cd          No   varchar2
--   p_pay_term_end_month_cd        No   varchar2
--   p_permanent_temporary_flag     No   varchar2
--   p_permit_recruitment_flag      No   varchar2
--   p_position_type                No   varchar2
--   p_posting_description          No   varchar2
--   p_probation_period             No   number
--   p_probation_period_unit_cd     No   varchar2
--   p_relocate_domestically        No   varchar2
--   p_relocate_internationally     No   varchar2
--   p_replacement_required_flag    No   varchar2
--   p_review_flag                  No   varchar2
--   p_seasonal_flag                No   varchar2
--   p_security_requirements        No   varchar2
--   p_service_minimum              No   varchar2
--   p_term_start_day_cd            No   varchar2
--   p_term_start_month_cd          No   varchar2
--   p_time_normal_finish           No   varchar2
--   p_time_normal_start            No   varchar2
--   p_transaction_status           No   varchar2
--   p_travel_required              No   varchar2
--   p_working_hours                No   number
--   p_works_council_approval_flag  No   varchar2
--   p_work_any_country             No   varchar2
--   p_work_any_location            No   varchar2
--   p_work_period_type_cd          No   varchar2
--   p_work_schedule                No   varchar2
--   p_work_duration                No   varchar2
--   p_work_term_end_day_cd         No   varchar2
--   p_work_term_end_month_cd       No   varchar2
--   p_proposed_fte_for_layoff      No   number
--   p_proposed_date_for_layoff     No   Date
--   p_information1                 No   varchar2
--   p_information2                 No   varchar2
--   p_information3                 No   varchar2
--   p_information4                 No   varchar2
--   p_information5                 No   varchar2
--   p_information6                 No   varchar2
--   p_information7                 No   varchar2
--   p_information8                 No   varchar2
--   p_information9                 No   varchar2
--   p_information10                No   varchar2
--   p_information11                No   varchar2
--   p_information12                No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--   p_information_category         No   varchar2
--   p_attribute1                   No   varchar2  Descriptive Flexfield
--   p_attribute2                   No   varchar2  Descriptive Flexfield
--   p_attribute3                   No   varchar2  Descriptive Flexfield
--   p_attribute4                   No   varchar2  Descriptive Flexfield
--   p_attribute5                   No   varchar2  Descriptive Flexfield
--   p_attribute6                   No   varchar2  Descriptive Flexfield
--   p_attribute7                   No   varchar2  Descriptive Flexfield
--   p_attribute8                   No   varchar2  Descriptive Flexfield
--   p_attribute9                   No   varchar2  Descriptive Flexfield
--   p_attribute10                  No   varchar2  Descriptive Flexfield
--   p_attribute11                  No   varchar2  Descriptive Flexfield
--   p_attribute12                  No   varchar2  Descriptive Flexfield
--   p_attribute13                  No   varchar2  Descriptive Flexfield
--   p_attribute14                  No   varchar2  Descriptive Flexfield
--   p_attribute15                  No   varchar2  Descriptive Flexfield
--   p_attribute16                  No   varchar2  Descriptive Flexfield
--   p_attribute17                  No   varchar2  Descriptive Flexfield
--   p_attribute18                  No   varchar2  Descriptive Flexfield
--   p_attribute19                  No   varchar2  Descriptive Flexfield
--   p_attribute20                  No   varchar2  Descriptive Flexfield
--   p_attribute21                  No   varchar2  Descriptive Flexfield
--   p_attribute22                  No   varchar2  Descriptive Flexfield
--   p_attribute23                  No   varchar2  Descriptive Flexfield
--   p_attribute24                  No   varchar2  Descriptive Flexfield
--   p_attribute25                  No   varchar2  Descriptive Flexfield
--   p_attribute26                  No   varchar2  Descriptive Flexfield
--   p_attribute27                  No   varchar2  Descriptive Flexfield
--   p_attribute28                  No   varchar2  Descriptive Flexfield
--   p_attribute29                  No   varchar2  Descriptive Flexfield
--   p_attribute30                  No   varchar2  Descriptive Flexfield
--   p_attribute_category           No   varchar2  Descriptive Flexfield
--   p_effective_date          Yes  date       Session Date.
--   p_pay_basis_id		No	number   Pay Basis
--   p_supervisor_id		No	number   Supervisor
--   p_wf_transaction_category_id   No	number   Wf Transaction Category Id
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_position_transaction
  (
   p_validate                       in boolean    default false
  ,p_position_transaction_id        in  number
  ,p_action_date                    in  date      default hr_api.g_date
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_availability_status_id         in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_entry_step_id                  in  number    default hr_api.g_number
  ,p_entry_grade_rule_id                  in  number    default hr_api.g_number
  ,p_job_id                         in  number    default hr_api.g_number
  ,p_location_id                    in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_pay_freq_payroll_id            in  number    default hr_api.g_number
  ,p_position_definition_id         in  number    default hr_api.g_number
  ,p_prior_position_id              in  number    default hr_api.g_number
  ,p_relief_position_id             in  number    default hr_api.g_number
  ,p_entry_grade_id          in  number    default hr_api.g_number
  ,p_successor_position_id          in  number    default hr_api.g_number
  ,p_supervisor_position_id         in  number    default hr_api.g_number
  ,p_amendment_date                 in  date      default hr_api.g_date
  ,p_amendment_recommendation       in  varchar2  default hr_api.g_varchar2
  ,p_amendment_ref_number           in  varchar2  default hr_api.g_varchar2
  ,p_avail_status_prop_end_date     in  date      default hr_api.g_date
  ,p_bargaining_unit_cd             in  varchar2  default hr_api.g_varchar2
  ,p_comments                       in  long      default null
  ,p_country1                       in  varchar2  default hr_api.g_varchar2
  ,p_country2                       in  varchar2  default hr_api.g_varchar2
  ,p_country3                       in  varchar2  default hr_api.g_varchar2
  ,p_current_job_prop_end_date      in  date      default hr_api.g_date
  ,p_current_org_prop_end_date      in  date      default hr_api.g_date
  ,p_date_effective                 in  date      default hr_api.g_date
  ,p_date_end                       in  date      default hr_api.g_date
  ,p_earliest_hire_date             in  date      default hr_api.g_date
  ,p_fill_by_date                   in  date      default hr_api.g_date
  ,p_frequency                      in  varchar2  default hr_api.g_varchar2
  ,p_fte                            in  number    default hr_api.g_number
  ,p_fte_capacity                   in  varchar2  default hr_api.g_varchar2
  ,p_location1                      in  varchar2  default hr_api.g_varchar2
  ,p_location2                      in  varchar2  default hr_api.g_varchar2
  ,p_location3                      in  varchar2  default hr_api.g_varchar2
  ,p_max_persons                    in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_other_requirements             in  varchar2  default hr_api.g_varchar2
  ,p_overlap_period                 in  number    default hr_api.g_number
  ,p_overlap_unit_cd                in  varchar2  default hr_api.g_varchar2
  ,p_passport_required              in  varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_day_cd            in  varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_month_cd          in  varchar2  default hr_api.g_varchar2
  ,p_permanent_temporary_flag       in  varchar2  default hr_api.g_varchar2
  ,p_permit_recruitment_flag        in  varchar2  default hr_api.g_varchar2
  ,p_position_type                  in  varchar2  default hr_api.g_varchar2
  ,p_posting_description            in  varchar2  default hr_api.g_varchar2
  ,p_probation_period               in  number    default hr_api.g_number
  ,p_probation_period_unit_cd       in  varchar2  default hr_api.g_varchar2
  ,p_relocate_domestically          in  varchar2  default hr_api.g_varchar2
  ,p_relocate_internationally       in  varchar2  default hr_api.g_varchar2
  ,p_replacement_required_flag      in  varchar2  default hr_api.g_varchar2
  ,p_review_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_seasonal_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_security_requirements          in  varchar2  default hr_api.g_varchar2
  ,p_service_minimum                in  varchar2  default hr_api.g_varchar2
  ,p_term_start_day_cd              in  varchar2  default hr_api.g_varchar2
  ,p_term_start_month_cd            in  varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish             in  varchar2  default hr_api.g_varchar2
  ,p_time_normal_start              in  varchar2  default hr_api.g_varchar2
  ,p_transaction_status             in  varchar2  default hr_api.g_varchar2
  ,p_travel_required                in  varchar2  default hr_api.g_varchar2
  ,p_working_hours                  in  number    default hr_api.g_number
  ,p_works_council_approval_flag    in  varchar2  default hr_api.g_varchar2
  ,p_work_any_country               in  varchar2  default hr_api.g_varchar2
  ,p_work_any_location              in  varchar2  default hr_api.g_varchar2
  ,p_work_period_type_cd            in  varchar2  default hr_api.g_varchar2
  ,p_work_schedule                  in  varchar2  default hr_api.g_varchar2
  ,p_work_duration                  in  varchar2  default hr_api.g_varchar2
  ,p_work_term_end_day_cd           in  varchar2  default hr_api.g_varchar2
  ,p_work_term_end_month_cd         in  varchar2  default hr_api.g_varchar2
  ,p_proposed_fte_for_layoff        in  number    default hr_api.g_number
  ,p_proposed_date_for_layoff       in  date      default hr_api.g_date
  ,p_information1                   in  varchar2  default hr_api.g_varchar2
  ,p_information2                   in  varchar2  default hr_api.g_varchar2
  ,p_information3                   in  varchar2  default hr_api.g_varchar2
  ,p_information4                   in  varchar2  default hr_api.g_varchar2
  ,p_information5                   in  varchar2  default hr_api.g_varchar2
  ,p_information6                   in  varchar2  default hr_api.g_varchar2
  ,p_information7                   in  varchar2  default hr_api.g_varchar2
  ,p_information8                   in  varchar2  default hr_api.g_varchar2
  ,p_information9                   in  varchar2  default hr_api.g_varchar2
  ,p_information10                  in  varchar2  default hr_api.g_varchar2
  ,p_information11                  in  varchar2  default hr_api.g_varchar2
  ,p_information12                  in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_pay_basis_id		    in  number    default hr_api.g_number
  ,p_supervisor_id		    in  number    default hr_api.g_number
  ,p_wf_transaction_category_id	    in  number    default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_position_transaction >------------------------|
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
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_position_transaction_id      Yes  number    PK of record
--   p_effective_date          Yes  date     Session Date.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_position_transaction
  (
   p_validate                       in boolean        default false
  ,p_position_transaction_id        in  number
  ,p_object_version_number          in  number
  ,p_effective_date            in date
  );
--
--
end pqh_position_transactions_api;

 

/
