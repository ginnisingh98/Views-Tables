--------------------------------------------------------
--  DDL for Package IRC_REFERRAL_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_REFERRAL_INFO_API" AUTHID CURRENT_USER as
/* $Header: irirfapi.pkh 120.0.12010000.3 2010/05/18 14:45:40 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_referral_info >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- {End Of Comments}
--
procedure create_referral_info
  (p_validate                       in           boolean  default false
  ,p_object_id                      in           number
  ,p_object_type                    in           varchar2
  ,p_source_type                    in           varchar2 default null
  ,p_source_name                    in           varchar2 default null
  ,p_source_criteria1               in           varchar2 default null
  ,p_source_value1                  in           varchar2 default null
  ,p_source_criteria2               in           varchar2 default null
  ,p_source_value2                  in           varchar2 default null
  ,p_source_criteria3               in           varchar2 default null
  ,p_source_value3                  in           varchar2 default null
  ,p_source_criteria4               in           varchar2 default null
  ,p_source_value4                  in           varchar2 default null
  ,p_source_criteria5               in           varchar2 default null
  ,p_source_value5                  in           varchar2 default null
  ,p_source_person_id               in           number   default null
  ,p_candidate_comment              in           varchar2 default null
  ,p_employee_comment               in           varchar2 default null
  ,p_irf_attribute_category         in           varchar2 default null
  ,p_irf_attribute1                 in           varchar2 default null
  ,p_irf_attribute2                 in           varchar2 default null
  ,p_irf_attribute3                 in           varchar2 default null
  ,p_irf_attribute4                 in           varchar2 default null
  ,p_irf_attribute5                 in           varchar2 default null
  ,p_irf_attribute6                 in           varchar2 default null
  ,p_irf_attribute7                 in           varchar2 default null
  ,p_irf_attribute8                 in           varchar2 default null
  ,p_irf_attribute9                 in           varchar2 default null
  ,p_irf_attribute10                in           varchar2 default null
  ,p_irf_information_category       in           varchar2 default null
  ,p_irf_information1               in           varchar2 default null
  ,p_irf_information2               in           varchar2 default null
  ,p_irf_information3               in           varchar2 default null
  ,p_irf_information4               in           varchar2 default null
  ,p_irf_information5               in           varchar2 default null
  ,p_irf_information6               in           varchar2 default null
  ,p_irf_information7               in           varchar2 default null
  ,p_irf_information8               in           varchar2 default null
  ,p_irf_information9               in           varchar2 default null
  ,p_irf_information10              in           varchar2 default null
  ,p_object_created_by              in           varchar2 default null
  ,p_referral_info_id               out nocopy   number
  ,p_object_version_number          out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_referral_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
--
-- {End Of Comments}
--
procedure update_referral_info
  (p_validate                       in           boolean  default false
  ,p_referral_info_id               in           number
  ,p_source_type                    in           varchar2 default hr_api.g_varchar2
  ,p_source_name                    in           varchar2 default hr_api.g_varchar2
  ,p_source_criteria1               in           varchar2 default hr_api.g_varchar2
  ,p_source_value1                  in           varchar2 default hr_api.g_varchar2
  ,p_source_criteria2               in           varchar2 default hr_api.g_varchar2
  ,p_source_value2                  in           varchar2 default hr_api.g_varchar2
  ,p_source_criteria3               in           varchar2 default hr_api.g_varchar2
  ,p_source_value3                  in           varchar2 default hr_api.g_varchar2
  ,p_source_criteria4               in           varchar2 default hr_api.g_varchar2
  ,p_source_value4                  in           varchar2 default hr_api.g_varchar2
  ,p_source_criteria5               in           varchar2 default hr_api.g_varchar2
  ,p_source_value5                  in           varchar2 default hr_api.g_varchar2
  ,p_source_person_id               in           number   default hr_api.g_number
  ,p_candidate_comment              in           varchar2 default hr_api.g_varchar2
  ,p_employee_comment               in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute_category         in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute1                 in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute2                 in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute3                 in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute4                 in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute5                 in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute6                 in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute7                 in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute8                 in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute9                 in           varchar2 default hr_api.g_varchar2
  ,p_irf_attribute10                in           varchar2 default hr_api.g_varchar2
  ,p_irf_information_category       in           varchar2 default hr_api.g_varchar2
  ,p_irf_information1               in           varchar2 default hr_api.g_varchar2
  ,p_irf_information2               in           varchar2 default hr_api.g_varchar2
  ,p_irf_information3               in           varchar2 default hr_api.g_varchar2
  ,p_irf_information4               in           varchar2 default hr_api.g_varchar2
  ,p_irf_information5               in           varchar2 default hr_api.g_varchar2
  ,p_irf_information6               in           varchar2 default hr_api.g_varchar2
  ,p_irf_information7               in           varchar2 default hr_api.g_varchar2
  ,p_irf_information8               in           varchar2 default hr_api.g_varchar2
  ,p_irf_information9               in           varchar2 default hr_api.g_varchar2
  ,p_irf_information10              in           varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_referral_details >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- {End Of Comments}
--
procedure copy_referral_details
  (p_source_assignment_id in number
  ,p_target_assignment_id in number
  );
--
--
end IRC_REFERRAL_INFO_API;

/
