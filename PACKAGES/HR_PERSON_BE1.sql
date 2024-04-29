--------------------------------------------------------
--  DDL for Package HR_PERSON_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_BE1" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:15
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_person_a (
p_effective_date               date,
p_datetrack_update_mode        varchar2,
p_person_id                    number,
p_object_version_number        number,
p_person_type_id               number,
p_last_name                    varchar2,
p_applicant_number             varchar2,
p_comments                     varchar2,
p_date_employee_data_verified  date,
p_date_of_birth                date,
p_email_address                varchar2,
p_employee_number              varchar2,
p_expense_check_send_to_addres varchar2,
p_first_name                   varchar2,
p_known_as                     varchar2,
p_marital_status               varchar2,
p_middle_names                 varchar2,
p_nationality                  varchar2,
p_national_identifier          varchar2,
p_previous_last_name           varchar2,
p_registered_disabled_flag     varchar2,
p_sex                          varchar2,
p_title                        varchar2,
p_vendor_id                    number,
p_attribute_category           varchar2,
p_attribute1                   varchar2,
p_attribute2                   varchar2,
p_attribute3                   varchar2,
p_attribute4                   varchar2,
p_attribute5                   varchar2,
p_attribute6                   varchar2,
p_attribute7                   varchar2,
p_attribute8                   varchar2,
p_attribute9                   varchar2,
p_attribute10                  varchar2,
p_attribute11                  varchar2,
p_attribute12                  varchar2,
p_attribute13                  varchar2,
p_attribute14                  varchar2,
p_attribute15                  varchar2,
p_attribute16                  varchar2,
p_attribute17                  varchar2,
p_attribute18                  varchar2,
p_attribute19                  varchar2,
p_attribute20                  varchar2,
p_attribute21                  varchar2,
p_attribute22                  varchar2,
p_attribute23                  varchar2,
p_attribute24                  varchar2,
p_attribute25                  varchar2,
p_attribute26                  varchar2,
p_attribute27                  varchar2,
p_attribute28                  varchar2,
p_attribute29                  varchar2,
p_attribute30                  varchar2,
p_per_information_category     varchar2,
p_per_information1             varchar2,
p_per_information2             varchar2,
p_per_information3             varchar2,
p_per_information4             varchar2,
p_per_information5             varchar2,
p_per_information6             varchar2,
p_per_information7             varchar2,
p_per_information8             varchar2,
p_per_information9             varchar2,
p_per_information10            varchar2,
p_per_information11            varchar2,
p_per_information12            varchar2,
p_per_information13            varchar2,
p_per_information14            varchar2,
p_per_information15            varchar2,
p_per_information16            varchar2,
p_per_information17            varchar2,
p_per_information18            varchar2,
p_per_information19            varchar2,
p_per_information20            varchar2,
p_per_information21            varchar2,
p_per_information22            varchar2,
p_per_information23            varchar2,
p_per_information24            varchar2,
p_per_information25            varchar2,
p_per_information26            varchar2,
p_per_information27            varchar2,
p_per_information28            varchar2,
p_per_information29            varchar2,
p_per_information30            varchar2,
p_date_of_death                date,
p_background_check_status      varchar2,
p_background_date_check        date,
p_blood_type                   varchar2,
p_correspondence_language      varchar2,
p_fast_path_employee           varchar2,
p_fte_capacity                 number,
p_hold_applicant_date_until    date,
p_honors                       varchar2,
p_internal_location            varchar2,
p_last_medical_test_by         varchar2,
p_last_medical_test_date       date,
p_mailstop                     varchar2,
p_office_number                varchar2,
p_on_military_service          varchar2,
p_pre_name_adjunct             varchar2,
p_projected_start_date         date,
p_rehire_authorizor            varchar2,
p_rehire_recommendation        varchar2,
p_resume_exists                varchar2,
p_resume_last_updated          date,
p_second_passport_exists       varchar2,
p_student_status               varchar2,
p_work_schedule                varchar2,
p_rehire_reason                varchar2,
p_suffix                       varchar2,
p_benefit_group_id             number,
p_receipt_of_death_cert_date   date,
p_coord_ben_med_pln_no         varchar2,
p_coord_ben_no_cvg_flag        varchar2,
p_coord_ben_med_ext_er         varchar2,
p_coord_ben_med_pl_name        varchar2,
p_coord_ben_med_insr_crr_name  varchar2,
p_coord_ben_med_insr_crr_ident varchar2,
p_coord_ben_med_cvg_strt_dt    date,
p_coord_ben_med_cvg_end_dt     date,
p_uses_tobacco_flag            varchar2,
p_dpdnt_adoption_date          date,
p_dpdnt_vlntry_svce_flag       varchar2,
p_original_date_of_hire        date,
p_adjusted_svc_date            date,
p_effective_start_date         date,
p_effective_end_date           date,
p_full_name                    varchar2,
p_comment_id                   number,
p_town_of_birth                varchar2,
p_region_of_birth              varchar2,
p_country_of_birth             varchar2,
p_global_person_id             varchar2,
p_party_id                     number,
p_npw_number                   varchar2,
p_name_combination_warning     boolean,
p_assign_payroll_warning       boolean,
p_orig_hire_warning            boolean);
end hr_person_be1;

/