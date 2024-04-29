--------------------------------------------------------
--  DDL for Package PQP_PERASGADD_RIW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PERASGADD_RIW" AUTHID CURRENT_USER As
/* $Header: pqpaariw.pkh 120.2.12010000.2 2009/05/15 11:18:30 psengupt ship $ */

-- =============================================================================
-- InsUpd_PerAsgAdd_Rec: This procedure is called by the web-adi spreadsheet
-- to create/update a Person, Assignment and Primary Address record in Oracle
-- HRMS from data entered in the spreadsheet or downloaded from an external XML
-- CSV or another HRMS instance.
-- =============================================================================
procedure InsUpd_PerAsgAdd_Rec
         (p_last_name                    in varchar2
         ,p_middle_name                  in varchar2 default null
         ,p_first_name                   in varchar2 default null
         ,p_suffix                       in varchar2 default null
         ,p_prefix                       in varchar2 default null
         ,p_title                        in varchar2 default null
         ,p_email_address                in varchar2 default null
         ,p_preferred_name               in varchar2 default null
         ,p_dup_person_id                in number   default null
         ,p_dup_party_id                 in number   default null
         ,p_marital_status               in varchar2 default null
         ,p_sex                          in varchar2
         ,p_nationality                  in varchar2 default null
         ,p_national_identifier          in varchar2 default null
         ,p_date_of_birth                in date     default null
         ,p_date_of_hire                 in date
         ,p_employee_number              in varchar2 default null
         ,p_primary_flag                 in varchar2 default null
         ,p_address_style                in varchar2 default null
         ,p_address_line1                in varchar2 default null
         ,p_address_line2                in varchar2 default null
         ,p_address_line3                in varchar2 default null
         ,p_region1                      in varchar2 default null
         ,p_region2                      in varchar2 default null
         ,p_region3                      in varchar2 default null
         ,p_town_or_city                 in varchar2 default null
         ,p_country                      in varchar2 default null
         ,p_postal_code                  in varchar2 default null
         ,p_telephone_no1                in varchar2 default null
         ,p_telephone_no2                in varchar2 default null
         ,p_telephone_no3                in varchar2 default null
         ,p_address_date_from            in date     default null
         ,p_address_date_to              in date     default null
         ,p_phone_type                   in varchar2 default null
         ,p_phone_number                 in varchar2 default null
         ,p_phone_date_from              in date     default null
         ,p_phone_date_to                in date     default null
         ,p_contact_type                 in varchar2 default null
         ,p_contact_name                 in varchar2 default null
         ,p_primary_contact              in varchar2 default null
         ,p_personal_flag                in varchar2 default null
         ,p_contact_date_from            in date     default null
         ,p_contact_date_to              in date     default null
         ,p_assign_organization          in varchar2 default null
         ,p_job                          in number   default null
         ,p_grade                        in number   default null
         ,p_internal_location            in varchar2 default null
         ,p_assign_group                 in varchar2 default null
         ,p_position                     in number   default null
         ,p_payroll                      in number   default null
         ,p_status                       in varchar2 default null
         ,p_assignment_no                in varchar2 default null
         ,p_assignment_category          in varchar2 default null
         ,p_collective_agreement         in varchar2 default null
         ,p_employee_category            in varchar2 default null
         ,p_user_person_type             in number   default null
         ,p_salary_basis                 in number   default null
         ,p_gre                          in varchar2 default null
         ,p_web_adi_identifier           in varchar2 default null
         ,p_assign_eff_dt_from           in date     default null
         ,p_assign_eff_dt_to             in date     default null
         -- per_all_people_f: DF
         ,p_per_attribute_category       in varchar2 default null
         ,p_per_attribute1               in varchar2 default null
         ,p_per_attribute2               in varchar2 default null
         ,p_per_attribute3               in varchar2 default null
         ,p_per_attribute4               in varchar2 default null
         ,p_per_attribute5               in varchar2 default null
         ,p_per_attribute6               in varchar2 default null
         ,p_per_attribute7               in varchar2 default null
         ,p_per_attribute8               in varchar2 default null
         ,p_per_attribute9               in varchar2 default null
         ,p_per_attribute10              in varchar2 default null
         ,p_per_attribute11              in varchar2 default null
         ,p_per_attribute12              in varchar2 default null
         ,p_per_attribute13              in varchar2 default null
         ,p_per_attribute14              in varchar2 default null
         ,p_per_attribute15              in varchar2 default null
         ,p_per_attribute16              in varchar2 default null
         ,p_per_attribute17              in varchar2 default null
         ,p_per_attribute18              in varchar2 default null
         ,p_per_attribute19              in varchar2 default null
         ,p_per_attribute20              in varchar2 default null
         ,p_per_attribute21              in varchar2 default null
         ,p_per_attribute22              in varchar2 default null
         ,p_per_attribute23              in varchar2 default null
         ,p_per_attribute24              in varchar2 default null
         ,p_per_attribute25              in varchar2 default null
         ,p_per_attribute26              in varchar2 default null
         ,p_per_attribute27              in varchar2 default null
         ,p_per_attribute28              in varchar2 default null
         ,p_per_attribute29              in varchar2 default null
         ,p_per_attribute30              in varchar2 default null
         -- per_all_people_f: legislation specific DDF
         ,p_per_information_category     in varchar2 default null
         ,p_per_information1             in varchar2 default null
         ,p_per_information2             in varchar2 default null
         ,p_per_information3             in varchar2 default null
         ,p_per_information4             in varchar2 default null
         ,p_per_information5             in varchar2 default null
         ,p_per_information6             in varchar2 default null
         ,p_per_information7             in varchar2 default null
         ,p_per_information8             in varchar2 default null
         ,p_per_information9             in varchar2 default null
         ,p_per_information10            in varchar2 default null
         ,p_per_information11            in varchar2 default null
         ,p_per_information12            in varchar2 default null
         ,p_per_information13            in varchar2 default null
         ,p_per_information14            in varchar2 default null
         ,p_per_information15            in varchar2 default null
         ,p_per_information16            in varchar2 default null
         ,p_per_information17            in varchar2 default null
         ,p_per_information18            in varchar2 default null
         ,p_per_information19            in varchar2 default null
         ,p_per_information20            in varchar2 default null
         ,p_per_information21            in varchar2 default null
         ,p_per_information22            in varchar2 default null
         ,p_per_information23            in varchar2 default null
         ,p_per_information24            in varchar2 default null
         ,p_per_information25            in varchar2 default null
         ,p_per_information26            in varchar2 default null
         ,p_per_information27            in varchar2 default null
         ,p_per_information28            in varchar2 default null
         ,p_per_information29            in varchar2 default null
         ,p_per_information30            in varchar2 default null
         -- Assignment: DF
         ,p_ass_attribute_category       in varchar2 default null
         ,p_ass_attribute1               in varchar2 default null
         ,p_ass_attribute2               in varchar2 default null
         ,p_ass_attribute3               in varchar2 default null
         ,p_ass_attribute4               in varchar2 default null
         ,p_ass_attribute5               in varchar2 default null
         ,p_ass_attribute6               in varchar2 default null
         ,p_ass_attribute7               in varchar2 default null
         ,p_ass_attribute8               in varchar2 default null
         ,p_ass_attribute9               in varchar2 default null
         ,p_ass_attribute10              in varchar2 default null
         ,p_ass_attribute11              in varchar2 default null
         ,p_ass_attribute12              in varchar2 default null
         ,p_ass_attribute13              in varchar2 default null
         ,p_ass_attribute14              in varchar2 default null
         ,p_ass_attribute15              in varchar2 default null
         ,p_ass_attribute16              in varchar2 default null
         ,p_ass_attribute17              in varchar2 default null
         ,p_ass_attribute18              in varchar2 default null
         ,p_ass_attribute19              in varchar2 default null
         ,p_ass_attribute20              in varchar2 default null
         ,p_ass_attribute21              in varchar2 default null
         ,p_ass_attribute22              in varchar2 default null
         ,p_ass_attribute23              in varchar2 default null
         ,p_ass_attribute24              in varchar2 default null
         ,p_ass_attribute25              in varchar2 default null
         ,p_ass_attribute26              in varchar2 default null
         ,p_ass_attribute27              in varchar2 default null
         ,p_ass_attribute28              in varchar2 default null
         ,p_ass_attribute29              in varchar2 default null
         ,p_ass_attribute30              in varchar2 default null
         -- Address: DF
         ,p_adr_attribute_category       in varchar2 default null
         ,p_adr_attribute1               in varchar2 default null
         ,p_adr_attribute2               in varchar2 default null
         ,p_adr_attribute3               in varchar2 default null
         ,p_adr_attribute4               in varchar2 default null
         ,p_adr_attribute5               in varchar2 default null
         ,p_adr_attribute6               in varchar2 default null
         ,p_adr_attribute7               in varchar2 default null
         ,p_adr_attribute8               in varchar2 default null
         ,p_adr_attribute9               in varchar2 default null
         ,p_adr_attribute10              in varchar2 default null
         ,p_adr_attribute11              in varchar2 default null
         ,p_adr_attribute12              in varchar2 default null
         ,p_adr_attribute13              in varchar2 default null
         ,p_adr_attribute14              in varchar2 default null
         ,p_adr_attribute15              in varchar2 default null
         ,p_adr_attribute16              in varchar2 default null
         ,p_adr_attribute17              in varchar2 default null
         ,p_adr_attribute18              in varchar2 default null
         ,p_adr_attribute19              in varchar2 default null
         ,p_adr_attribute20              in varchar2 default null

         ,p_business_group_id            in number   default null
         ,p_data_pump_flag               in varchar2 default null
         ,p_add_information13            in varchar2 default null
         ,p_add_information14            in varchar2 default null
         ,p_add_information15            in varchar2 default null
         ,p_add_information16            in varchar2 default null
         ,p_add_information17            in varchar2 default null
         ,p_add_information18            in varchar2 default null
         ,p_add_information19            in varchar2 default null
         ,p_add_information20            in varchar2 default null
         -- people group keyflex field
         ,p_concat_segments              in varchar2 default null
         ,p_people_segment1              in varchar2 default null
         ,p_people_segment2              in varchar2 default null
         ,p_people_segment3              in varchar2 default null
         ,p_people_segment4              in varchar2 default null
         ,p_people_segment5              in varchar2 default null
         ,p_people_segment6              in varchar2 default null
         ,p_people_segment7              in varchar2 default null
         ,p_people_segment8              in varchar2 default null
         ,p_people_segment9              in varchar2 default null
         ,p_people_segment10             in varchar2 default null
         ,p_people_segment11             in varchar2 default null
         ,p_people_segment12             in varchar2 default null
         ,p_people_segment13             in varchar2 default null
         ,p_people_segment14             in varchar2 default null
         ,p_people_segment15             in varchar2 default null
         ,p_people_segment16             in varchar2 default null
         ,p_people_segment17             in varchar2 default null
         ,p_people_segment18             in varchar2 default null
         ,p_people_segment19             in varchar2 default null
         ,p_people_segment20             in varchar2 default null
         ,p_people_segment21             in varchar2 default null
         ,p_people_segment22             in varchar2 default null
         ,p_people_segment23             in varchar2 default null
         ,p_people_segment24             in varchar2 default null
         ,p_people_segment25             in varchar2 default null
         ,p_people_segment26             in varchar2 default null
         ,p_people_segment27             in varchar2 default null
         ,p_people_segment28             in varchar2 default null
         ,p_people_segment29             in varchar2 default null
         ,p_people_segment30             in varchar2 default null
         -- hr_soft_coding_keyflex
         ,p_soft_segments                in varchar2 default null
         ,p_soft_segment1                in varchar2 default null
         ,p_soft_segment2                in varchar2 default null
         ,p_soft_segment3                in varchar2 default null
         ,p_soft_segment4                in varchar2 default null
         ,p_soft_segment5                in varchar2 default null
         ,p_soft_segment6                in varchar2 default null
         ,p_soft_segment7                in varchar2 default null
         ,p_soft_segment8                in varchar2 default null
         ,p_soft_segment9                in varchar2 default null
         ,p_soft_segment10               in varchar2 default null
         ,p_soft_segment11               in varchar2 default null
         ,p_soft_segment12               in varchar2 default null
         ,p_soft_segment13               in varchar2 default null
         ,p_soft_segment14               in varchar2 default null
         ,p_soft_segment15               in varchar2 default null
         ,p_soft_segment16               in varchar2 default null
         ,p_soft_segment17               in varchar2 default null
         ,p_soft_segment18               in varchar2 default null
         ,p_soft_segment19               in varchar2 default null
         ,p_soft_segment20               in varchar2 default null
         ,p_soft_segment21               in varchar2 default null
         ,p_soft_segment22               in varchar2 default null
         ,p_soft_segment23               in varchar2 default null
         ,p_soft_segment24               in varchar2 default null
         ,p_soft_segment25               in varchar2 default null
         ,p_soft_segment26               in varchar2 default null
         ,p_soft_segment27               in varchar2 default null
         ,p_soft_segment28               in varchar2 default null
         ,p_soft_segment29               in varchar2 default null
         ,p_soft_segment30               in varchar2 default null

         ,p_business_group_name          in varchar2 default null
         ,p_batch_id                     in number   default null
         ,p_data_pump_batch_line_id      in varchar2 default null
         ,p_per_comments                 in varchar2 default null
         ,p_date_employee_data_verified  in date     default null
         ,p_expense_check_send_to_addres in varchar2 default null
         ,p_previous_last_name           in varchar2 default null
         ,p_registered_disabled_flag     in varchar2 default null
         ,p_vendor_id                    in number   default null
         ,p_date_of_death                in date     default null
         ,p_background_check_status      in varchar2 default null
         ,p_background_date_check        in date     default null
         ,p_blood_type                   in varchar2 default null
         ,p_correspondence_language      in varchar2 default null
         ,p_fast_path_employee           in varchar2 default null
         ,p_fte_capacity                 in number   default null
         ,p_honors                       in varchar2 default null
         ,p_last_medical_test_by         in varchar2 default null
         ,p_last_medical_test_date       in date     default null
         ,p_mailstop                     in varchar2 default null
         ,p_office_number                in varchar2 default null
         ,p_on_military_service          in varchar2 default null
         ,p_pre_name_adjunct             in varchar2 default null
         ,p_projected_start_date         in date     default null
         ,p_resume_exists                in varchar2 default null
         ,p_resume_last_updated          in date     default null
         ,p_second_passport_exists       in varchar2 default null
         ,p_student_status               in varchar2 default null
         ,p_work_schedule                in varchar2 default null
         ,p_benefit_group_id             in number   default null
         ,p_receipt_of_death_cert_date   in date     default null
         ,p_coord_ben_med_pln_no         in varchar2 default null
         ,p_coord_ben_no_cvg_flag        in varchar2 default null
         ,p_coord_ben_med_ext_er         in varchar2 default null
         ,p_coord_ben_med_pl_name        in varchar2 default null
         ,p_coord_ben_med_insr_crr_name  in varchar2 default null
         ,p_coord_ben_med_insr_crr_ident in varchar2 default null
         ,p_coord_ben_med_cvg_strt_dt    in date     default null
         ,p_coord_ben_med_cvg_end_dt     in date     default null
         ,p_uses_tobacco_flag            in varchar2 default null
         ,p_dpdnt_adoption_date          in date     default null
         ,p_dpdnt_vlntry_svce_flag       in varchar2 default null
         ,p_original_date_of_hire        in date     default null
         ,p_adjusted_svc_date            in date     default null
         ,p_town_of_birth                in varchar2 default null
         ,p_region_of_birth              in varchar2 default null
         ,p_country_of_birth             in varchar2 default null
         ,p_global_person_id             in varchar2 default null
         ,p_party_id                     in number   default null
         ,p_supervisor_id                in number   default null
         ,p_assignment_number            in varchar2 default null
         ,p_change_reason                in varchar2 default null
         ,p_asg_comments                 in varchar2 default null
         ,p_date_probation_end           in date     default null
         ,p_default_code_comb_id         in number   default null
         ,p_frequency                    in varchar2 default null
         ,p_internal_address_line        in varchar2 default null
         ,p_manager_flag                 in varchar2 default null
         ,p_normal_hours                 in number   default null
         ,p_perf_review_period           in number   default null
         ,p_perf_review_period_frequency in varchar2 default null
         ,p_probation_period             in number   default null
         ,p_probation_unit               in varchar2 default null
         ,p_sal_review_period            in number   default null
         ,p_sal_review_period_frequency  in varchar2 default null
         ,p_set_of_books_id              in number   default null
         ,p_source_type                  in varchar2 default null
         ,p_time_normal_finish           in varchar2 default null
         ,p_time_normal_start            in varchar2 default null
         ,p_bargaining_unit_code         in varchar2 default null
         ,p_labour_union_member_flag     in varchar2 default null
         ,p_hourly_salaried_code         in varchar2 default null
         ,p_pradd_ovlapval_override      in varchar2 default null
         ,p_address_type                 in varchar2 default null
         ,p_adr_comments                 in varchar2 default null
         ,p_batch_name                   in varchar2 default null
         ,p_location_id                  in number   default null
         ,p_student_number               in varchar2 default null
         ,p_apl_assignment_id            in varchar2 default null
         ,p_applicant_number             in varchar2 default null
         ,p_cwk_number                   in varchar2 default null
         ,p_interface_code               in varchar2 default null
--$ Update Batch
         ,p_batch_link                   in number   default null
--$ Get the mode ("Create and Update", "Update Only" or "View Only" )
         ,p_crt_upd                      in varchar2 Default null
         ,p_assignment_id                in number   default null
          );

-- =============================================================================
-- Create_BatchHdr_For_DataPump:
-- =============================================================================
procedure Create_DataPump_BatchHeader
         (p_reference                    in varchar2 default null
         ,p_business_group_id            in number   default null
         ,p_batch_process_name           in out nocopy varchar2
         ,p_batch_process_id             out nocopy number
          );


end PQP_PerAsgAdd_RIW;

/
