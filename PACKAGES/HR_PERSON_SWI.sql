--------------------------------------------------------
--  DDL for Package HR_PERSON_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_SWI" AUTHID CURRENT_USER As
/* $Header: hrperswi.pkh 115.2 2003/02/12 20:13:06 pzwalker ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_person >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_api.update_person
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_person
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_person_id                    in     number
  ,p_object_version_number        in out nocopy number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_last_name                    in     varchar2  default hr_api.g_varchar2
  ,p_applicant_number             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_employee_data_verified  in     date      default hr_api.g_date
  ,p_date_of_birth                in     date      default hr_api.g_date
  ,p_email_address                in     varchar2  default hr_api.g_varchar2
  ,p_employee_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres in     varchar2  default hr_api.g_varchar2
  ,p_first_name                   in     varchar2  default hr_api.g_varchar2
  ,p_known_as                     in     varchar2  default hr_api.g_varchar2
  ,p_marital_status               in     varchar2  default hr_api.g_varchar2
  ,p_middle_names                 in     varchar2  default hr_api.g_varchar2
  ,p_nationality                  in     varchar2  default hr_api.g_varchar2
  ,p_national_identifier          in     varchar2  default hr_api.g_varchar2
  ,p_previous_last_name           in     varchar2  default hr_api.g_varchar2
  ,p_registered_disabled_flag     in     varchar2  default hr_api.g_varchar2
  ,p_sex                          in     varchar2  default hr_api.g_varchar2
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_work_telephone               in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_per_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ,p_date_of_death                in     date      default hr_api.g_date
  ,p_background_check_status      in     varchar2  default hr_api.g_varchar2
  ,p_background_date_check        in     date      default hr_api.g_date
  ,p_blood_type                   in     varchar2  default hr_api.g_varchar2
  ,p_correspondence_language      in     varchar2  default hr_api.g_varchar2
  ,p_fast_path_employee           in     varchar2  default hr_api.g_varchar2
  ,p_fte_capacity                 in     number    default hr_api.g_number
  ,p_hold_applicant_date_until    in     date      default hr_api.g_date
  ,p_honors                       in     varchar2  default hr_api.g_varchar2
  ,p_internal_location            in     varchar2  default hr_api.g_varchar2
  ,p_last_medical_test_by         in     varchar2  default hr_api.g_varchar2
  ,p_last_medical_test_date       in     date      default hr_api.g_date
  ,p_mailstop                     in     varchar2  default hr_api.g_varchar2
  ,p_office_number                in     varchar2  default hr_api.g_varchar2
  ,p_on_military_service          in     varchar2  default hr_api.g_varchar2
  ,p_pre_name_adjunct             in     varchar2  default hr_api.g_varchar2
  ,p_projected_start_date         in     date      default hr_api.g_date
  ,p_rehire_authorizor            in     varchar2  default hr_api.g_varchar2
  ,p_rehire_recommendation        in     varchar2  default hr_api.g_varchar2
  ,p_resume_exists                in     varchar2  default hr_api.g_varchar2
  ,p_resume_last_updated          in     date      default hr_api.g_date
  ,p_second_passport_exists       in     varchar2  default hr_api.g_varchar2
  ,p_student_status               in     varchar2  default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2  default hr_api.g_varchar2
  ,p_rehire_reason                in     varchar2  default hr_api.g_varchar2
  ,p_suffix                       in     varchar2  default hr_api.g_varchar2
  ,p_benefit_group_id             in     number    default hr_api.g_number
  ,p_receipt_of_death_cert_date   in     date      default hr_api.g_date
  ,p_coord_ben_med_pln_no         in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_ext_er         in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_pl_name        in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_name  in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_ident in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_cvg_strt_dt    in     date      default hr_api.g_date
  ,p_coord_ben_med_cvg_end_dt     in     date      default hr_api.g_date
  ,p_uses_tobacco_flag            in     varchar2  default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in     date      default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in     varchar2  default hr_api.g_varchar2
  ,p_original_date_of_hire        in     date      default hr_api.g_date
  ,p_adjusted_svc_date            in     date      default hr_api.g_date
  ,p_town_of_birth                in     varchar2  default hr_api.g_varchar2
  ,p_region_of_birth              in     varchar2  default hr_api.g_varchar2
  ,p_country_of_birth             in     varchar2  default hr_api.g_varchar2
  ,p_global_person_id             in     varchar2  default hr_api.g_varchar2
  ,p_party_id                     in     number    default hr_api.g_number
  ,p_npw_number                   in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_party_last_update_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end hr_person_swi;

 

/