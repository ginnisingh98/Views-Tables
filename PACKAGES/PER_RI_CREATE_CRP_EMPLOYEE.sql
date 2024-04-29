--------------------------------------------------------
--  DDL for Package PER_RI_CREATE_CRP_EMPLOYEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CREATE_CRP_EMPLOYEE" AUTHID CURRENT_USER as
/* $Header: pericemp.pkh 120.0 2005/05/31 18:09:44 appldev noship $ */

    Procedure insert_batch_lines(p_batch_id                     In Number
                                ,p_data_pump_batch_line_id      In Varchar2   Default Null
                                ,p_user_sequence                In Number     Default Null
                                ,p_link_value                   In Number     Default Null
                                ,p_hire_date                    In Date
                                ,p_last_name                    In Varchar2
                                ,p_sex                          In Varchar2
                                ,p_per_comments                 In Varchar2   Default Null
                                ,p_date_employee_data_verified  In Date       Default Null
                                ,p_date_of_birth                In Date       Default Null
                                ,p_email_address                In Varchar2   Default Null
                                ,p_employee_number              In Varchar2   Default Null
                                ,p_expense_check_send_to_addres In Varchar2   Default Null
                                ,p_first_name                   In Varchar2   Default Null
                                ,p_known_as                     In Varchar2   Default Null
                                ,p_marital_status               In Varchar2   Default Null
                                ,p_middle_names                 In Varchar2   Default Null
                                ,p_nationality                  In Varchar2   Default Null
                                ,p_national_identifier          In Varchar2   Default Null
                                ,p_previous_last_name           In Varchar2   Default Null
                                ,p_registered_disabled_flag     In Varchar2   Default Null
                                ,p_title                        In Varchar2   Default Null
                                ,p_work_telephone               In Varchar2   Default Null
                                ,p_attribute_category           In Varchar2   Default Null
                                ,p_attribute1                   In Varchar2   Default Null
                                ,p_attribute2                   In Varchar2   Default Null
                                ,p_attribute3                   In Varchar2   Default Null
                                ,p_attribute4                   In Varchar2   Default Null
                                ,p_attribute5                   In Varchar2   Default Null
                                ,p_attribute6                   In Varchar2   Default Null
                                ,p_attribute7                   In Varchar2   Default Null
                                ,p_attribute8                   In Varchar2   Default Null
                                ,p_attribute9                   In Varchar2   Default Null
                                ,p_attribute10                  In Varchar2   Default Null
                                ,p_attribute11                  In Varchar2   Default Null
                                ,p_attribute12                  In Varchar2   Default Null
                                ,p_attribute13                  In Varchar2   Default Null
                                ,p_attribute14                  In Varchar2   Default Null
                                ,p_attribute15                  In Varchar2   Default Null
                                ,p_attribute16                  In Varchar2   Default Null
                                ,p_attribute17                  In Varchar2   Default Null
                                ,p_attribute18                  In Varchar2   Default Null
                                ,p_attribute19                  In Varchar2   Default Null
                                ,p_attribute20                  In Varchar2   Default Null
                                ,p_attribute21                  In Varchar2   Default Null
                                ,p_attribute22                  In Varchar2   Default Null
                                ,p_attribute23                  In Varchar2   Default Null
                                ,p_attribute24                  In Varchar2   Default Null
                                ,p_attribute25                  In Varchar2   Default Null
                                ,p_attribute26                  In Varchar2   Default Null
                                ,p_attribute27                  In Varchar2   Default Null
                                ,p_attribute28                  In Varchar2   Default Null
                                ,p_attribute29                  In Varchar2   Default Null
                                ,p_attribute30                  In Varchar2   Default Null
                                ,p_per_information_category     In Varchar2   Default Null
                                ,p_per_information1             In Varchar2   Default Null
                                ,p_per_information2             In Varchar2   Default Null
                                ,p_per_information3             In Varchar2   Default Null
                                ,p_per_information4             In Varchar2   Default Null
                                ,p_per_information5             In Varchar2   Default Null
                                ,p_per_information6             In Varchar2   Default Null
                                ,p_per_information7             In Varchar2   Default Null
                                ,p_per_information8             In Varchar2   Default Null
                                ,p_per_information9             In Varchar2   Default Null
                                ,p_per_information10            In Varchar2   Default Null
                                ,p_per_information11            In Varchar2   Default Null
                                ,p_per_information12            In Varchar2   Default Null
                                ,p_per_information13            In Varchar2   Default Null
                                ,p_per_information14            In Varchar2   Default Null
                                ,p_per_information15            In Varchar2   Default Null
                                ,p_per_information16            In Varchar2   Default Null
                                ,p_per_information17            In Varchar2   Default Null
                                ,p_per_information18            In Varchar2   Default Null
                                ,p_per_information19            In Varchar2   Default Null
                                ,p_per_information20            In Varchar2   Default Null
                                ,p_per_information21            In Varchar2   Default Null
                                ,p_per_information22            In Varchar2   Default Null
                                ,p_per_information23            In Varchar2   Default Null
                                ,p_per_information24            In Varchar2   Default Null
                                ,p_per_information25            In Varchar2   Default Null
                                ,p_per_information26            In Varchar2   Default Null
                                ,p_per_information27            In Varchar2   Default Null
                                ,p_per_information28            In Varchar2   Default Null
                                ,p_per_information29            In Varchar2   Default Null
                                ,p_per_information30            In Varchar2   Default Null
                                ,p_date_of_death                In Date       Default Null
                                ,p_background_check_status      In Varchar2   Default Null
                                ,p_background_date_check        In Date       Default Null
                                ,p_blood_type                   In Varchar2   Default Null
                                ,p_fast_path_employee           In Varchar2   Default Null
                                ,p_fte_capacity                 In Number     Default Null
                                ,p_honors                       In Varchar2   Default Null
                                ,p_internal_location            In Varchar2   Default Null
                                ,p_last_medical_test_by         In Varchar2   Default Null
                                ,p_last_medical_test_date       In Date       Default Null
                                ,p_mailstop                     In Varchar2   Default Null
                                ,p_office_number                In Varchar2   Default Null
                                ,p_on_military_service          In Varchar2   Default Null
                                ,p_pre_name_adjunct             In Varchar2   Default Null
                                ,p_projected_start_date         In Date       Default Null
                                ,p_resume_exists                In Varchar2   Default Null
                                ,p_resume_last_updated          In Date       Default Null
                                ,p_second_passport_exists       In Varchar2   Default Null
                                ,p_student_status               In Varchar2   Default Null
                                ,p_work_schedule                In Varchar2   Default Null
                                ,p_suffix                       In Varchar2   Default Null
                                ,p_receipt_of_death_cert_date   In Date       Default Null
                                ,p_coord_ben_med_pln_no         In Varchar2   Default Null
                                ,p_coord_ben_no_cvg_flag        In Varchar2   Default Null
                                ,p_coord_ben_med_ext_er         In Varchar2   Default Null
                                ,p_coord_ben_med_pl_name        In Varchar2   Default Null
                                ,p_coord_ben_med_insr_crr_name  In Varchar2   Default Null
                                ,p_coord_ben_med_insr_crr_ident In Varchar2   Default Null
                                ,p_coord_ben_med_cvg_strt_dt    In Date       Default Null
                                ,p_coord_ben_med_cvg_end_dt     In Date       Default Null
                                ,p_uses_tobacco_flag            In Varchar2   Default Null
                                ,p_dpdnt_adoption_date          In Date       Default Null
                                ,p_dpdnt_vlntry_svce_flag       In Varchar2   Default Null
                                ,p_original_date_of_hire        In Date       Default Null
                                ,p_adjusted_svc_date            In Date       Default Null
                                ,p_town_of_birth                In Varchar2   Default Null
                                ,p_region_of_birth              In Varchar2   Default Null
                                ,p_country_of_birth             In Varchar2   Default Null
                                ,p_global_person_id             In Varchar2   Default Null
                                ,p_party_id                     In Number     Default Null
                                ,p_person_user_key              In Varchar2   Default Null
                                ,p_assignment_user_key          In Varchar2   Default Null
                                ,p_user_person_type             In Varchar2   Default Null
                                ,p_language_code                In Varchar2   Default Null
                                ,p_vendor_name                  In Varchar2   Default Null
                                ,p_correspondence_language      In Varchar2   Default Null
                                ,p_benefit_group                In Varchar2   Default Null
                                ,p_data_pump_batch_line_id_add  In Number     Default Null
                                ,p_effective_date               In Date       Default Null
                                ,p_pradd_ovlapval_override      In Boolean    Default Null
                                ,p_validate_county              In Boolean    Default Null
                                ,p_primary_flag                 In Varchar2
                                ,p_style                        In Varchar2
                                ,p_date_from                    In Date       Default Null
                                ,p_date_to                      In Date       Default Null
                                ,p_address_type                 In Varchar2   Default Null
                                ,p_comments                     In Long       Default Null
                                ,p_address_line1                In Varchar2   Default Null
                                ,p_address_line2                In Varchar2   Default Null
                                ,p_address_line3                In Varchar2   Default Null
                                ,p_town_or_city                 In Varchar2   Default Null
                                ,p_region_1                     In Varchar2   Default Null
                                ,p_region_2                     In Varchar2   Default Null
                                ,p_region_3                     In Varchar2   Default Null
                                ,p_postal_code                  In Varchar2   Default Null
                                ,p_telephone_number_1           In Varchar2   Default Null
                                ,p_telephone_number_2           In Varchar2   Default Null
                                ,p_telephone_number_3           In Varchar2   Default Null
                                ,p_addr_attribute_category      In Varchar2   Default Null
                                ,p_addr_attribute1              In Varchar2   Default Null
                                ,p_addr_attribute2              In Varchar2   Default Null
                                ,p_addr_attribute3              In Varchar2   Default Null
                                ,p_addr_attribute4              In Varchar2   Default Null
                                ,p_addr_attribute5              In Varchar2   Default Null
                                ,p_addr_attribute6              In Varchar2   Default Null
                                ,p_addr_attribute7              In Varchar2   Default Null
                                ,p_addr_attribute8              In Varchar2   Default Null
                                ,p_addr_attribute9              In Varchar2   Default Null
                                ,p_addr_attribute10             In Varchar2   Default Null
                                ,p_addr_attribute11             In Varchar2   Default Null
                                ,p_addr_attribute12             In Varchar2   Default Null
                                ,p_addr_attribute13             In Varchar2   Default Null
                                ,p_addr_attribute14             In Varchar2   Default Null
                                ,p_addr_attribute15             In Varchar2   Default Null
                                ,p_addr_attribute16             In Varchar2   Default Null
                                ,p_addr_attribute17             In Varchar2   Default Null
                                ,p_addr_attribute18             In Varchar2   Default Null
                                ,p_addr_attribute19             In Varchar2   Default Null
                                ,p_addr_attribute20             In Varchar2   Default Null
                                ,p_add_information13            In Varchar2   Default Null
                                ,p_add_information14            In Varchar2   Default Null
                                ,p_add_information15            In Varchar2   Default Null
                                ,p_add_information16            In Varchar2   Default Null
                                ,p_add_information17            In Varchar2   Default Null
                                ,p_add_information18            In Varchar2   Default Null
                                ,p_add_information19            In Varchar2   Default Null
                                ,p_add_information20            In Varchar2   Default Null
                                ,p_address_user_key             In Varchar2   Default Null
                                ,p_country                      In Varchar2   Default Null
                                ,p_asg_location                 In Varchar2   Default Null
                                ,p_payroll_name                 In Varchar2   Default Null
                                ,p_pay_basis                    In Varchar2   Default Null
                                ,p_gre                          In Varchar2   Default Null
                                ,p_data_pump_batch_line_id_sal  In Number     Default Null
                                ,p_change_date                  In Date       Default Null
                                ,p_proposed_salary              In Number     Default Null
                                ,p_proposal_reason              In Varchar2   Default Null
                                );

Procedure set_user_acct_details(
  p_person_id                   In Number
 ,p_per_effective_start_date    In Date
 ,p_per_effective_end_date      In Date
 ,p_assignment_id               In Number
 ,p_asg_effective_start_date    In Date
 ,p_asg_effective_end_date      In Date
 ,p_business_group_id           In Number
 ,p_date_from                   In Date
 ,p_date_to                     In Date
 ,p_org_structure_id            In Number
 ,p_org_structure_vers_id       In Number
 ,p_parent_org_id               In Number
 ,p_single_org_id               In Number
 ,p_run_type                    In Varchar2
 ,p_hire_date                   In Date
);

End per_ri_create_crp_employee;

 

/
