--------------------------------------------------------
--  DDL for Package HR_EMPLOYEE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EMPLOYEE_SWI" AUTHID CURRENT_USER As
/* $Header: hrempswi.pkh 120.1 2005/09/13 15:02:51 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< apply_for_internal_vacancy >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_employee_api.apply_for_internal_vacancy
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
PROCEDURE apply_for_internal_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_applicant_number             in out nocopy varchar2
  ,p_per_object_version_number    in out nocopy number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_application_id                  out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_apl_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< create_employee >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_employee_api.create_employee
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
PROCEDURE create_employee
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_hire_date                    in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_sex                          in     varchar2
  ,p_person_type_id               in     number    default null
  ,p_per_comments                 in     varchar2  default null
  ,p_date_employee_data_verified  in     date      default null
  ,p_date_of_birth                in     date      default null
  ,p_email_address                in     varchar2  default null
  ,p_employee_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres in     varchar2  default null
  ,p_first_name                   in     varchar2  default null
  ,p_known_as                     in     varchar2  default null
  ,p_marital_status               in     varchar2  default null
  ,p_middle_names                 in     varchar2  default null
  ,p_nationality                  in     varchar2  default null
  ,p_national_identifier          in     varchar2  default null
  ,p_previous_last_name           in     varchar2  default null
  ,p_registered_disabled_flag     in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_vendor_id                    in     number    default null
  ,p_work_telephone               in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_date_of_death                in     date      default null
  ,p_background_check_status      in     varchar2  default null
  ,p_background_date_check        in     date      default null
  ,p_blood_type                   in     varchar2  default null
  ,p_correspondence_language      in     varchar2  default null
  ,p_fast_path_employee           in     varchar2  default null
  ,p_fte_capacity                 in     number    default null
  ,p_honors                       in     varchar2  default null
  ,p_internal_location            in     varchar2  default null
  ,p_last_medical_test_by         in     varchar2  default null
  ,p_last_medical_test_date       in     date      default null
  ,p_mailstop                     in     varchar2  default null
  ,p_office_number                in     varchar2  default null
  ,p_on_military_service          in     varchar2  default null
  ,p_pre_name_adjunct             in     varchar2  default null
  ,p_projected_start_date         in     date      default null
  ,p_resume_exists                in     varchar2  default null
  ,p_resume_last_updated          in     date      default null
  ,p_second_passport_exists       in     varchar2  default null
  ,p_student_status               in     varchar2  default null
  ,p_work_schedule                in     varchar2  default null
  ,p_suffix                       in     varchar2  default null
  ,p_benefit_group_id             in     number    default null
  ,p_receipt_of_death_cert_date   in     date      default null
  ,p_coord_ben_med_pln_no         in     varchar2  default null
  ,p_coord_ben_no_cvg_flag        in     varchar2  default null
  ,p_coord_ben_med_ext_er         in     varchar2  default null
  ,p_coord_ben_med_pl_name        in     varchar2  default null
  ,p_coord_ben_med_insr_crr_name  in     varchar2  default null
  ,p_coord_ben_med_insr_crr_ident in     varchar2  default null
  ,p_coord_ben_med_cvg_strt_dt    in     date      default null
  ,p_coord_ben_med_cvg_end_dt     in     date      default null
  ,p_uses_tobacco_flag            in     varchar2  default null
  ,p_dpdnt_adoption_date          in     date      default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2  default null
  ,p_original_date_of_hire        in     date      default null
  ,p_adjusted_svc_date            in     date      default null
  ,p_town_of_birth                in     varchar2  default null
  ,p_region_of_birth              in     varchar2  default null
  ,p_country_of_birth             in     varchar2  default null
  ,p_global_person_id             in     varchar2  default null
  ,p_party_id                     in     number    default null
  ,p_person_id                       out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_per_comment_id                  out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< create_employee >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_employee_api.create_employee
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
PROCEDURE create_employee
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_hire_date                    in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_sex                          in     varchar2
  ,p_person_type_id               in     number    default null
  ,p_per_comments                 in     varchar2  default null
  ,p_date_employee_data_verified  in     date      default null
  ,p_date_of_birth                in     date      default null
  ,p_email_address                in     varchar2  default null
  ,p_employee_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres in     varchar2  default null
  ,p_first_name                   in     varchar2  default null
  ,p_known_as                     in     varchar2  default null
  ,p_marital_status               in     varchar2  default null
  ,p_middle_names                 in     varchar2  default null
  ,p_nationality                  in     varchar2  default null
  ,p_national_identifier          in     varchar2  default null
  ,p_previous_last_name           in     varchar2  default null
  ,p_registered_disabled_flag     in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_vendor_id                    in     number    default null
  ,p_work_telephone               in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_date_of_death                in     date      default null
  ,p_background_check_status      in     varchar2  default null
  ,p_background_date_check        in     date      default null
  ,p_blood_type                   in     varchar2  default null
  ,p_correspondence_language      in     varchar2  default null
  ,p_fast_path_employee           in     varchar2  default null
  ,p_fte_capacity                 in     number    default null
  ,p_honors                       in     varchar2  default null
  ,p_internal_location            in     varchar2  default null
  ,p_last_medical_test_by         in     varchar2  default null
  ,p_last_medical_test_date       in     date      default null
  ,p_mailstop                     in     varchar2  default null
  ,p_office_number                in     varchar2  default null
  ,p_on_military_service          in     varchar2  default null
  ,p_pre_name_adjunct             in     varchar2  default null
  ,p_projected_start_date         in     date      default null
  ,p_resume_exists                in     varchar2  default null
  ,p_resume_last_updated          in     date      default null
  ,p_second_passport_exists       in     varchar2  default null
  ,p_student_status               in     varchar2  default null
  ,p_work_schedule                in     varchar2  default null
  ,p_suffix                       in     varchar2  default null
  ,p_benefit_group_id             in     number    default null
  ,p_receipt_of_death_cert_date   in     date      default null
  ,p_coord_ben_med_pln_no         in     varchar2  default null
  ,p_coord_ben_no_cvg_flag        in     varchar2  default null
  ,p_coord_ben_med_ext_er         in     varchar2  default null
  ,p_coord_ben_med_pl_name        in     varchar2  default null
  ,p_coord_ben_med_insr_crr_name  in     varchar2  default null
  ,p_coord_ben_med_insr_crr_ident in     varchar2  default null
  ,p_coord_ben_med_cvg_strt_dt    in     date      default null
  ,p_coord_ben_med_cvg_end_dt     in     date      default null
  ,p_uses_tobacco_flag            in     varchar2  default null
  ,p_dpdnt_adoption_date          in     date      default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2  default null
  ,p_original_date_of_hire        in     date      default null
  ,p_adjusted_svc_date            in     date      default null
  ,p_town_of_birth                in     varchar2  default null
  ,p_region_of_birth              in     varchar2  default null
  ,p_country_of_birth             in     varchar2  default null
  ,p_global_person_id             in     varchar2  default null
  ,p_party_id                     in     number    default null
  ,p_person_id                       out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_per_comment_id                  out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  /* person address parameters */
  ,p_addr_validate                     in     number    default hr_api.g_false_num
  ,p_addr_effective_date               in     date
  ,p_pradd_ovlapval_override      in     number    default null
  ,p_addr_validate_county              in     number    default null
  ,p_addr_person_id                    in     number    default null
  ,p_addr_primary_flag                 in     varchar2
  ,p_addr_style                        in     varchar2
  ,p_addr_date_from                    in     date
  ,p_addr_date_to                      in     date      default null
  ,p_addr_address_type                 in     varchar2  default null
  ,p_addr_comments                     in     long      default null
  ,p_addr_address_line1                in     varchar2  default null
  ,p_addr_address_line2                in     varchar2  default null
  ,p_addr_address_line3                in     varchar2  default null
  ,p_addr_town_or_city                 in     varchar2  default null
  ,p_addr_region_1                     in     varchar2  default null
  ,p_addr_region_2                     in     varchar2  default null
  ,p_addr_region_3                     in     varchar2  default null
  ,p_addr_postal_code                  in     varchar2  default null
  ,p_addr_country                      in     varchar2  default null
  ,p_addr_telephone_number_1           in     varchar2  default null
  ,p_addr_telephone_number_2           in     varchar2  default null
  ,p_addr_telephone_number_3           in     varchar2  default null
  ,p_addr_attribute_category      in     varchar2  default null
  ,p_addr_attribute1              in     varchar2  default null
  ,p_addr_attribute2              in     varchar2  default null
  ,p_addr_attribute3              in     varchar2  default null
  ,p_addr_attribute4              in     varchar2  default null
  ,p_addr_attribute5              in     varchar2  default null
  ,p_addr_attribute6              in     varchar2  default null
  ,p_addr_attribute7              in     varchar2  default null
  ,p_addr_attribute8              in     varchar2  default null
  ,p_addr_attribute9              in     varchar2  default null
  ,p_addr_attribute10             in     varchar2  default null
  ,p_addr_attribute11             in     varchar2  default null
  ,p_addr_attribute12             in     varchar2  default null
  ,p_addr_attribute13             in     varchar2  default null
  ,p_addr_attribute14             in     varchar2  default null
  ,p_addr_attribute15             in     varchar2  default null
  ,p_addr_attribute16             in     varchar2  default null
  ,p_addr_attribute17             in     varchar2  default null
  ,p_addr_attribute18             in     varchar2  default null
  ,p_addr_attribute19             in     varchar2  default null
  ,p_addr_attribute20             in     varchar2  default null
  ,p_addr_add_information13            in     varchar2  default null
  ,p_addr_add_information14            in     varchar2  default null
  ,p_addr_add_information15            in     varchar2  default null
  ,p_addr_add_information16            in     varchar2  default null
  ,p_addr_add_information17            in     varchar2  default null
  ,p_addr_add_information18            in     varchar2  default null
  ,p_addr_add_information19            in     varchar2  default null
  ,p_addr_add_information20            in     varchar2  default null
  ,p_addr_party_id                     in     number    default null
  ,p_addr_address_id                   in     number
  ,p_addr_object_version_number           out nocopy number
  ,p_addr_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< hire_into_job >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_employee_api.hire_into_job
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
PROCEDURE hire_into_job
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_object_version_number        in out nocopy number
  ,p_employee_number              in out nocopy varchar2
  ,p_datetrack_update_mode        in     varchar2  default hr_api.g_varchar2
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_national_identifier          in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< re_hire_ex_employee >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_employee_api.re_hire_ex_employee
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
PROCEDURE re_hire_ex_employee
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_hire_date                    in     date
  ,p_person_id                    in     number
  ,p_per_object_version_number    in out nocopy number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_rehire_reason                in     varchar2
  ,p_assignment_id                   out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------< convert_to_manual_gen_method > -----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is to update the employee number, applicant number,
--  contigent worker number generation flag to Manual 'M' to support
--  iSetup Employee Migration.
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE convert_to_manual_gen_method
    (errbuf              out nocopy varchar2
    ,retcode             out nocopy number
    ,p_business_group_id in  number
    );
-- ----------------------------------------------------------------------------
end hr_employee_swi;

 

/
