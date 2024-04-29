--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_DPNT_ELIG_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_DPNT_ELIG_SS" AUTHID CURRENT_USER as
/* $Header: bendpels.pkh 120.0 2005/05/28 04:09:26 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                   |
|                          Redwood Shores, California, USA                      |
|                               All rights reserved.                            |
+==============================================================================+
--
Name
        Dependent Eligibility for Self Service
Purpose
        This package loops through all electable choices for a passed in per_in_ler
and determines if the dependent (person_contact_id is passed in) is eligible.  This
is called from self service enrollment.  This logic is similar to the Dependent
Designation Form logic so changes made here should also be made in the forms library
for the Dependent Designation Form.

History
        Date       Who           Version    What?
        ----       ---           -------    -----
        03 Aug 00  Thayden       115.0      Created.
        12 Feb 02  Shdas         115.1      Added fmly_mmbr_cd_exist proc.
        04 Dec 02  kmullapu      115.2      Added create_contact_w,update_person_w
                                            NOCOPY changes
	09 Mar 05  vborkar	 115.4	    Bug 4218944 - Added procedure
	                                    update_contact_w
*/
--------------------------------------------------------------------------------


procedure main
  (p_pgm_id                  in number
  ,p_per_in_ler_id           in number
  ,p_person_id               in number
  ,p_contact_person_id       in number
  ,p_contact_relationship_id in number
  ,p_effective_date          in date
  );
--
procedure fmly_mmbr_cd_exist
  (p_business_group_id       in          number
  ,p_effective_date          in          date
  ,p_fmly_mmbr_exist         out  NOCOPY varchar2
  );
--
procedure create_contact_w
  (p_validate                     in        varchar2    default 'N'
  ,p_start_date                   in        date
  ,p_business_group_id            in        number
  ,p_person_id                    in        number
  ,p_contact_person_id            in        number      default null
  ,p_contact_type                 in        varchar2
  ,p_ctr_comments                 in        varchar2    default null
  ,p_primary_contact_flag         in        varchar2    default 'N'
  ,p_date_start               in            date        default null
  ,p_start_life_reason_id         in        number      default null
  ,p_date_end                 in            date        default null
  ,p_end_life_reason_id           in        number      default null
  ,p_rltd_per_rsds_w_dsgntr_flag  in        varchar2    default 'N'
  ,p_personal_flag                in        varchar2    default 'N'
  ,p_sequence_number              in        number      default null
  ,p_cont_attribute_category      in        varchar2    default null
  ,p_cont_attribute1              in        varchar2    default null
  ,p_cont_attribute2              in        varchar2    default null
  ,p_cont_attribute3              in        varchar2    default null
  ,p_cont_attribute4              in        varchar2    default null
  ,p_cont_attribute5              in        varchar2    default null
  ,p_cont_attribute6              in        varchar2    default null
  ,p_cont_attribute7              in        varchar2    default null
  ,p_cont_attribute8              in        varchar2    default null
  ,p_cont_attribute9              in        varchar2    default null
  ,p_cont_attribute10             in        varchar2    default null
  ,p_cont_attribute11             in        varchar2    default null
  ,p_cont_attribute12             in        varchar2    default null
  ,p_cont_attribute13             in        varchar2    default null
  ,p_cont_attribute14             in        varchar2    default null
  ,p_cont_attribute15             in        varchar2    default null
  ,p_cont_attribute16             in        varchar2    default null
  ,p_cont_attribute17             in        varchar2    default null
  ,p_cont_attribute18             in        varchar2    default null
  ,p_cont_attribute19             in        varchar2    default null
  ,p_cont_attribute20             in        varchar2    default null
  ,p_cont_information_category    in        varchar2    default null
  ,p_cont_information1            in        varchar2    default null
  ,p_cont_information2            in        varchar2    default null
  ,p_cont_information3            in        varchar2    default null
  ,p_cont_information4            in        varchar2    default null
  ,p_cont_information5            in        varchar2    default null
  ,p_cont_information6            in        varchar2    default null
  ,p_cont_information7            in        varchar2    default null
  ,p_cont_information8            in        varchar2    default null
  ,p_cont_information9            in        varchar2    default null
  ,p_cont_information10           in        varchar2    default null
  ,p_cont_information11           in        varchar2    default null
  ,p_cont_information12           in        varchar2    default null
  ,p_cont_information13           in        varchar2    default null
  ,p_cont_information14           in        varchar2    default null
  ,p_cont_information15           in        varchar2    default null
  ,p_cont_information16           in        varchar2    default null
  ,p_cont_information17           in        varchar2    default null
  ,p_cont_information18           in        varchar2    default null
  ,p_cont_information19           in        varchar2    default null
  ,p_cont_information20           in        varchar2    default null
  ,p_third_party_pay_flag         in        varchar2    default 'N'
  ,p_bondholder_flag              in        varchar2    default 'N'
  ,p_dependent_flag               in        varchar2    default 'N'
  ,p_beneficiary_flag             in        varchar2    default 'N'
  ,p_last_name                    in        varchar2    default null
  ,p_sex                          in        varchar2    default null
  ,p_person_type_id               in        number      default null
  ,p_per_comments                 in        varchar2    default null
  ,p_date_of_birth                in        date        default null
  ,p_email_address                in        varchar2    default null
  ,p_first_name                   in        varchar2    default null
  ,p_known_as                     in        varchar2    default null
  ,p_marital_status               in        varchar2    default null
  ,p_middle_names                 in        varchar2    default null
  ,p_nationality                  in        varchar2    default null
  ,p_national_identifier          in        varchar2    default null
  ,p_previous_last_name           in        varchar2    default null
  ,p_registered_disabled_flag     in        varchar2    default null
  ,p_title                        in        varchar2    default null
  ,p_work_telephone               in        varchar2    default null
  ,p_attribute_category           in        varchar2    default null
  ,p_attribute1                   in        varchar2    default null
  ,p_attribute2                   in        varchar2    default null
  ,p_attribute3                   in        varchar2    default null
  ,p_attribute4                   in        varchar2    default null
  ,p_attribute5                   in        varchar2    default null
  ,p_attribute6                   in        varchar2    default null
  ,p_attribute7                   in        varchar2    default null
  ,p_attribute8                   in        varchar2    default null
  ,p_attribute9                   in        varchar2    default null
  ,p_attribute10                  in        varchar2    default null
  ,p_attribute11                  in        varchar2    default null
  ,p_attribute12                  in        varchar2    default null
  ,p_attribute13                  in        varchar2    default null
  ,p_attribute14                  in        varchar2    default null
  ,p_attribute15                  in        varchar2    default null
  ,p_attribute16                  in        varchar2    default null
  ,p_attribute17                  in        varchar2    default null
  ,p_attribute18                  in        varchar2    default null
  ,p_attribute19                  in        varchar2    default null
  ,p_attribute20                  in        varchar2    default null
  ,p_attribute21                  in        varchar2    default null
  ,p_attribute22                  in        varchar2    default null
  ,p_attribute23                  in        varchar2    default null
  ,p_attribute24                  in        varchar2    default null
  ,p_attribute25                  in        varchar2    default null
  ,p_attribute26                  in        varchar2    default null
  ,p_attribute27                  in        varchar2    default null
  ,p_attribute28                  in        varchar2    default null
  ,p_attribute29                  in        varchar2    default null
  ,p_attribute30                  in        varchar2    default null
  ,p_per_information_category     in        varchar2    default null
  ,p_per_information1             in        varchar2    default null
  ,p_per_information2             in        varchar2    default null
  ,p_per_information3             in        varchar2    default null
  ,p_per_information4             in        varchar2    default null
  ,p_per_information5             in        varchar2    default null
  ,p_per_information6             in        varchar2    default null
  ,p_per_information7             in        varchar2    default null
  ,p_per_information8             in        varchar2    default null
  ,p_per_information9             in        varchar2    default null
  ,p_per_information10            in        varchar2    default null
  ,p_per_information11            in        varchar2    default null
  ,p_per_information12            in        varchar2    default null
  ,p_per_information13            in        varchar2    default null
  ,p_per_information14            in        varchar2    default null
  ,p_per_information15            in        varchar2    default null
  ,p_per_information16            in        varchar2    default null
  ,p_per_information17            in        varchar2    default null
  ,p_per_information18            in        varchar2    default null
  ,p_per_information19            in        varchar2    default null
  ,p_per_information20            in        varchar2    default null
  ,p_per_information21            in        varchar2    default null
  ,p_per_information22            in        varchar2    default null
  ,p_per_information23            in        varchar2    default null
  ,p_per_information24            in        varchar2    default null
  ,p_per_information25            in        varchar2    default null
  ,p_per_information26            in        varchar2    default null
  ,p_per_information27            in        varchar2    default null
  ,p_per_information28            in        varchar2    default null
  ,p_per_information29            in        varchar2    default null
  ,p_per_information30            in        varchar2    default null
  ,p_correspondence_language      in        varchar2    default null
  ,p_honors                       in        varchar2    default null
  ,p_pre_name_adjunct             in        varchar2    default null
  ,p_suffix                       in        varchar2    default null
  ,p_create_mirror_flag           in        varchar2    default 'N'
  ,p_mirror_type                  in        varchar2    default null

  ,p_contact_relationship_id      out    NOCOPY   number
  ,p_ctr_object_version_number    out    NOCOPY   number
  ,p_per_person_id                out    NOCOPY   number
  ,p_per_object_version_number    out    NOCOPY   number
  ,p_per_effective_start_date     out    NOCOPY   date
  ,p_per_effective_end_date       out    NOCOPY   date
  ,p_full_name                    out    NOCOPY   varchar2
  ,p_per_comment_id               out    NOCOPY   number
  ,p_name_combination_warning     out    NOCOPY   varchar2
  ,p_orig_hire_warning            out    NOCOPY   varchar2
  ,p_return_status                out    NOCOPY   varchar2
  );
--
procedure update_contact_w
  (p_validate                          in        varchar2    default 'N'
  ,p_effective_date                    in        date
  ,p_contact_relationship_id           in        number
  ,p_contact_type                      in        varchar2  default hr_api.g_varchar2
  ,p_comments                          in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag              in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag              in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag                   in        varchar2  default hr_api.g_varchar2
  ,p_date_start                        in        date      default hr_api.g_date
  ,p_start_life_reason_id              in        number    default hr_api.g_number
  ,p_date_end                          in        date      default hr_api.g_date
  ,p_end_life_reason_id                in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag       in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                     in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number                   in        number    default hr_api.g_number
  ,p_dependent_flag                    in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category           in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information_category         in        varchar2  default hr_api.g_varchar2
  ,p_cont_information1                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information2                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information3                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information4                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information5                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information6                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information7                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information8                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information9                 in        varchar2  default hr_api.g_varchar2
  ,p_cont_information10                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information11                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information12                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information13                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information14                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information15                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information16                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information17                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information18                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information19                in        varchar2  default hr_api.g_varchar2
  ,p_cont_information20                in        varchar2  default hr_api.g_varchar2
  ,p_object_version_number             in out nocopy    number
  ,p_return_status                     out    nocopy    varchar2
  );
--
procedure update_person_w
  (p_validate                     in      varchar2   default 'N'
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out NOCOPY number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out NOCOPY varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_national_identifier          in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
  ,p_registered_disabled_flag     in      varchar2 default hr_api.g_varchar2
  ,p_sex                          in      varchar2 default hr_api.g_varchar2
  ,p_title                        in      varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in      number   default hr_api.g_number
  ,p_work_telephone               in      varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in      varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in      varchar2 default hr_api.g_varchar2
  ,p_per_information_category     in      varchar2 default hr_api.g_varchar2
  ,p_per_information1             in      varchar2 default hr_api.g_varchar2
  ,p_per_information2             in      varchar2 default hr_api.g_varchar2
  ,p_per_information3             in      varchar2 default hr_api.g_varchar2
  ,p_per_information4             in      varchar2 default hr_api.g_varchar2
  ,p_per_information5             in      varchar2 default hr_api.g_varchar2
  ,p_per_information6             in      varchar2 default hr_api.g_varchar2
  ,p_per_information7             in      varchar2 default hr_api.g_varchar2
  ,p_per_information8             in      varchar2 default hr_api.g_varchar2
  ,p_per_information9             in      varchar2 default hr_api.g_varchar2
  ,p_per_information10            in      varchar2 default hr_api.g_varchar2
  ,p_per_information11            in      varchar2 default hr_api.g_varchar2
  ,p_per_information12            in      varchar2 default hr_api.g_varchar2
  ,p_per_information13            in      varchar2 default hr_api.g_varchar2
  ,p_per_information14            in      varchar2 default hr_api.g_varchar2
  ,p_per_information15            in      varchar2 default hr_api.g_varchar2
  ,p_per_information16            in      varchar2 default hr_api.g_varchar2
  ,p_per_information17            in      varchar2 default hr_api.g_varchar2
  ,p_per_information18            in      varchar2 default hr_api.g_varchar2
  ,p_per_information19            in      varchar2 default hr_api.g_varchar2
  ,p_per_information20            in      varchar2 default hr_api.g_varchar2
  ,p_per_information21            in      varchar2 default hr_api.g_varchar2
  ,p_per_information22            in      varchar2 default hr_api.g_varchar2
  ,p_per_information23            in      varchar2 default hr_api.g_varchar2
  ,p_per_information24            in      varchar2 default hr_api.g_varchar2
  ,p_per_information25            in      varchar2 default hr_api.g_varchar2
  ,p_per_information26            in      varchar2 default hr_api.g_varchar2
  ,p_per_information27            in      varchar2 default hr_api.g_varchar2
  ,p_per_information28            in      varchar2 default hr_api.g_varchar2
  ,p_per_information29            in      varchar2 default hr_api.g_varchar2
  ,p_per_information30            in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_ext_er         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_pl_name        in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_name  in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_ident in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_cvg_strt_dt    in      date     default hr_api.g_date
  ,p_coord_ben_med_cvg_end_dt     in      date     default hr_api.g_date
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_party_id                     in      number   default hr_api.g_number
  ,p_npw_number                   in      varchar2 default hr_api.g_varchar2
  ,p_effective_start_date         out   NOCOPY  date
  ,p_effective_end_date           out   NOCOPY  date
  ,p_full_name                    out   NOCOPY  varchar2
  ,p_comment_id                   out   NOCOPY  number
  ,p_name_combination_warning     out   NOCOPY  varchar2
  ,p_assign_payroll_warning       out   NOCOPY  varchar2
  ,p_orig_hire_warning            out   NOCOPY  varchar2
  ,p_return_status                out   NOCOPY  varchar2
  );
--
end ben_determine_dpnt_elig_ss;

 

/
