--------------------------------------------------------
--  DDL for Package HR_PROCESS_PERSON_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROCESS_PERSON_SS" AUTHID CURRENT_USER AS
/* $Header: hrperwrs.pkh 120.2.12010000.6 2010/03/12 11:22:27 gpurohit ship $*/
  g_date_format  constant varchar2(10):='RRRR-MM-DD';
  g_correct               constant varchar2(10) := 'CORRECT';
  g_change                constant varchar2(10) := 'CHANGE';
  g_attribute_update      constant varchar2(100) := 'UPDATE';
  g_attribute_correct     constant varchar2(100) := 'CORRECTION';
  g_update_for_approval   constant varchar2(100) := 'UPDATE_FOR_APPROVAL';
  g_update_basic_details  constant varchar2(100) := 'UPDATE_BASIC_DETAILS';
  g_trans_actvty_result_code constant varchar2(100) := 'NEXT';

--Start Registration
  g_session_id            number;
  g_person_id             number;
  g_assignment_id         number;
  g_asg_object_version_number   number;

--End Registration
--applicant_hire
  g_is_applicant     boolean := false;
--
-- ----------------------------------------------------------------------------
-- Following global variables will hold the Function Attribute
-- Internal Name. ( For Workflow )
-- ----------------------------------------------------------------------------
  g_basic_details VARCHAR2(100) := 'BASIC_DETAILS';
  g_contacts VARCHAR2(100) := 'CONTACTS';
  g_phone_numbers VARCHAR2(100) := 'PHONE_NUMBERS';
  g_main_address VARCHAR2(100) := 'MAIN_ADDRESS';
  g_secondary_address VARCHAR2(100) := 'SECONDARY_ADDRESS';
--
--
-- ------------------------------------------------------------------------
-- -------------------------<get_hr_lookup_meaning>------------------------
-- ------------------------------------------------------------------------
-- Purpose: This procedure retrieves the lookup meaning from hr_lookups for the
--          lookup_type and lookup_code passed in.
-- ------------------------------------------------------------------------
Function get_hr_lookup_meaning(p_lookup_type in varchar2
                           ,p_lookup_code in varchar2)
return varchar2;


--
--
-- ------------------------------------------------------------------------
-- -------------------------<get_max_effective_date>------------------------
-- ------------------------------------------------------------------------
-- Purpose: This procedure retrieves the lookup meaning from hr_lookups for the
--          lookup_type and lookup_code passed in.
-- ------------------------------------------------------------------------
Function get_max_effective_date(p_person_id in number)
return Date;

--
--
-- ---------------------------------------------------------------------------
-- ---------------------- < get_person_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------
PROCEDURE get_person_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  number
   ,p_trans_rec_count                 out nocopy number
   ,p_effective_date                  out nocopy date
   ,p_attribute_update_mode           out nocopy varchar2
   ,p_person_id                       out nocopy number
   ,p_object_version_number           out nocopy number
   ,p_person_type_id                  out nocopy number
   ,p_last_name                       out nocopy varchar2
   ,p_applicant_number                out nocopy varchar2
   ,p_comments                        out nocopy varchar2
   ,p_date_employee_data_verified     out nocopy date
   ,p_original_date_of_hire           out nocopy date
   ,p_date_of_birth                   out nocopy date
   ,p_town_of_birth                   out nocopy varchar2
   ,p_region_of_birth                 out nocopy varchar2
   ,p_country_of_birth                out nocopy varchar2
   ,p_global_person_id                out nocopy varchar2
   ,p_email_address                   out nocopy varchar2
   ,p_employee_number                 out nocopy varchar2
   ,p_npw_number                      out nocopy varchar2
   ,p_expense_check_send_to_addres    out nocopy varchar2
   ,p_first_name                      out nocopy varchar2
   ,p_known_as                        out nocopy varchar2
   ,p_marital_status                  out nocopy varchar2
   ,p_middle_names                    out nocopy varchar2
   ,p_nationality                     out nocopy varchar2
   ,p_national_identifier             out nocopy varchar2
   ,p_previous_last_name              out nocopy varchar2
   ,p_registered_disabled_flag        out nocopy varchar2
   ,p_sex                             out nocopy varchar2
   ,p_title                           out nocopy varchar2
   ,p_vendor_id                       out nocopy number
   ,p_work_telephone                  out nocopy varchar2
   ,p_suffix                          out nocopy varchar2
   ,p_date_of_death                   out nocopy date
   ,p_background_check_status         out nocopy varchar2
   ,p_background_date_check           out nocopy date
   ,p_blood_type                      out nocopy varchar2
   ,p_correspondence_language         out nocopy varchar2
   ,p_fast_path_employee              out nocopy varchar2
   ,p_fte_capacity                    out nocopy number
   ,p_hold_applicant_date_until       out nocopy date
   ,p_honors                          out nocopy varchar2
   ,p_internal_location               out nocopy varchar2
   ,p_last_medical_test_by            out nocopy varchar2
   ,p_last_medical_test_date          out nocopy date
   ,p_mailstop                        out nocopy varchar2
   ,p_office_number                   out nocopy varchar2
   ,p_on_military_service             out nocopy varchar2
   ,p_pre_name_adjunct                out nocopy varchar2
   ,p_projected_start_date            out nocopy date
   ,p_rehire_authorizor               out nocopy varchar2
   ,p_rehire_recommendation           out nocopy varchar2
   ,p_resume_exists                   out nocopy varchar2
   ,p_resume_last_updated             out nocopy date
   ,p_second_passport_exists          out nocopy varchar2
   ,p_student_status                  out nocopy varchar2
   ,p_work_schedule                   out nocopy varchar2
   ,p_rehire_reason                   out nocopy varchar2
   ,p_benefit_group_id                out nocopy number
   ,p_receipt_of_death_cert_date      out nocopy date
   ,p_coord_ben_med_pln_no            out nocopy varchar2
   ,p_coord_ben_no_cvg_flag           out nocopy varchar2
   ,p_uses_tobacco_flag               out nocopy varchar2
   ,p_dpdnt_adoption_date             out nocopy varchar2
   ,p_dpdnt_vlntry_svce_flag          out nocopy varchar2
-- StartRegistration.
   ,p_adjusted_svc_date               out nocopy date
   ,p_date_start                      out nocopy date
-- EndRegistration.
   ,p_attribute_category              out nocopy varchar2
   ,p_attribute1                      out nocopy varchar2
   ,p_attribute2                      out nocopy varchar2
   ,p_attribute3                      out nocopy varchar2
   ,p_attribute4                      out nocopy varchar2
   ,p_attribute5                      out nocopy varchar2
   ,p_attribute6                      out nocopy varchar2
   ,p_attribute7                      out nocopy varchar2
   ,p_attribute8                      out nocopy varchar2
   ,p_attribute9                      out nocopy varchar2
   ,p_attribute10                     out nocopy varchar2
   ,p_attribute11                     out nocopy varchar2
   ,p_attribute12                     out nocopy varchar2
   ,p_attribute13                     out nocopy varchar2
   ,p_attribute14                     out nocopy varchar2
   ,p_attribute15                     out nocopy varchar2
   ,p_attribute16                     out nocopy varchar2
   ,p_attribute17                     out nocopy varchar2
   ,p_attribute18                     out nocopy varchar2
   ,p_attribute19                     out nocopy varchar2
   ,p_attribute20                     out nocopy varchar2
   ,p_attribute21                     out nocopy varchar2
   ,p_attribute22                     out nocopy varchar2
   ,p_attribute23                     out nocopy varchar2
   ,p_attribute24                     out nocopy varchar2
   ,p_attribute25                     out nocopy varchar2
   ,p_attribute26                     out nocopy varchar2
   ,p_attribute27                     out nocopy varchar2
   ,p_attribute28                     out nocopy varchar2
   ,p_attribute29                     out nocopy varchar2
   ,p_attribute30                     out nocopy varchar2
   ,p_per_information_category        out nocopy varchar2
   ,p_per_information1                out nocopy varchar2
   ,p_per_information2                out nocopy varchar2
   ,p_per_information3                out nocopy varchar2
   ,p_per_information4                out nocopy varchar2
   ,p_per_information5                out nocopy varchar2
   ,p_per_information6                out nocopy varchar2
   ,p_per_information7                out nocopy varchar2
   ,p_per_information8                out nocopy varchar2
   ,p_per_information9                out nocopy varchar2
   ,p_per_information10               out nocopy varchar2
   ,p_per_information11               out nocopy varchar2
   ,p_per_information12               out nocopy varchar2
   ,p_per_information13               out nocopy varchar2
   ,p_per_information14               out nocopy varchar2
   ,p_per_information15               out nocopy varchar2
   ,p_per_information16               out nocopy varchar2
   ,p_per_information17               out nocopy varchar2
   ,p_per_information18               out nocopy varchar2
   ,p_per_information19               out nocopy varchar2
   ,p_per_information20               out nocopy varchar2
   ,p_per_information21               out nocopy varchar2
   ,p_per_information22               out nocopy varchar2
   ,p_per_information23               out nocopy varchar2
   ,p_per_information24               out nocopy varchar2
   ,p_per_information25               out nocopy varchar2
   ,p_per_information26               out nocopy varchar2
   ,p_per_information27               out nocopy varchar2
   ,p_per_information28               out nocopy varchar2
   ,p_per_information29               out nocopy varchar2
   ,p_per_information30               out nocopy varchar2
   ,p_title_meaning                   out nocopy varchar2
   ,p_marital_status_meaning          out nocopy varchar2
   ,p_full_name                       out nocopy varchar2
   ,p_business_group_id               out nocopy number
   ,p_review_proc_call                out nocopy varchar2
   ,p_action_type                     out nocopy varchar2
);
--
--
-- ---------------------------------------------------------------------------
-- ---------------------- < get_person_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is the procedure which does the actual work.
-- ---------------------------------------------------------------------------
procedure get_person_data_from_tt
   (p_transaction_step_id             in  number
   ,p_effective_date                  out nocopy date
   ,p_attribute_update_mode           out nocopy varchar2
   ,p_person_id                       out nocopy number
   ,p_object_version_number           out nocopy number
   ,p_person_type_id                  out nocopy number
   ,p_last_name                       out nocopy varchar2
   ,p_applicant_number                out nocopy varchar2
   ,p_comments                        out nocopy varchar2
   ,p_date_employee_data_verified     out nocopy date
   ,p_original_date_of_hire           out nocopy date
   ,p_date_of_birth                   out nocopy date
   ,p_town_of_birth                   out nocopy varchar2
   ,p_region_of_birth                 out nocopy varchar2
   ,p_country_of_birth                out nocopy varchar2
   ,p_global_person_id                out nocopy varchar2
   ,p_email_address                   out nocopy varchar2
   ,p_employee_number                 out nocopy varchar2
   ,p_npw_number                      out nocopy varchar2
   ,p_expense_check_send_to_addres    out nocopy varchar2
   ,p_first_name                      out nocopy varchar2
   ,p_known_as                        out nocopy varchar2
   ,p_marital_status                  out nocopy varchar2
   ,p_middle_names                    out nocopy varchar2
   ,p_nationality                     out nocopy varchar2
   ,p_national_identifier             out nocopy varchar2
   ,p_previous_last_name              out nocopy varchar2
   ,p_registered_disabled_flag        out nocopy varchar2
   ,p_sex                             out nocopy varchar2
   ,p_title                           out nocopy varchar2
   ,p_vendor_id                       out nocopy number
   ,p_work_telephone                  out nocopy varchar2
   ,p_suffix                          out nocopy varchar2
   ,p_date_of_death                   out nocopy date
   ,p_background_check_status         out nocopy varchar2
   ,p_background_date_check           out nocopy date
   ,p_blood_type                      out nocopy varchar2
   ,p_correspondence_language         out nocopy varchar2
   ,p_fast_path_employee              out nocopy varchar2
   ,p_fte_capacity                    out nocopy number
   ,p_hold_applicant_date_until       out nocopy date
   ,p_honors                          out nocopy varchar2
   ,p_internal_location               out nocopy varchar2
   ,p_last_medical_test_by            out nocopy varchar2
   ,p_last_medical_test_date          out nocopy date
   ,p_mailstop                        out nocopy varchar2
   ,p_office_number                   out nocopy varchar2
   ,p_on_military_service             out nocopy varchar2
   ,p_pre_name_adjunct                out nocopy varchar2
   ,p_projected_start_date            out nocopy date
   ,p_rehire_authorizor               out nocopy varchar2
   ,p_rehire_recommendation           out nocopy varchar2
   ,p_resume_exists                   out nocopy varchar2
   ,p_resume_last_updated             out nocopy date
   ,p_second_passport_exists          out nocopy varchar2
   ,p_student_status                  out nocopy varchar2
   ,p_work_schedule                   out nocopy varchar2
   ,p_rehire_reason                   out nocopy varchar2
   ,p_benefit_group_id                out nocopy number
   ,p_receipt_of_death_cert_date      out nocopy date
   ,p_coord_ben_med_pln_no            out nocopy varchar2
   ,p_coord_ben_no_cvg_flag           out nocopy varchar2
   ,p_uses_tobacco_flag               out nocopy varchar2
   ,p_dpdnt_adoption_date             out nocopy date
   ,p_dpdnt_vlntry_svce_flag          out nocopy varchar2
-- StartRegistration.
   ,p_adjusted_svc_date               out nocopy date
   ,p_date_start                      out nocopy date
-- EndRegistration.
   ,p_attribute_category              out nocopy varchar2
   ,p_attribute1                      out nocopy varchar2
   ,p_attribute2                      out nocopy varchar2
   ,p_attribute3                      out nocopy varchar2
   ,p_attribute4                      out nocopy varchar2
   ,p_attribute5                      out nocopy varchar2
   ,p_attribute6                      out nocopy varchar2
   ,p_attribute7                      out nocopy varchar2
   ,p_attribute8                      out nocopy varchar2
   ,p_attribute9                      out nocopy varchar2
   ,p_attribute10                     out nocopy varchar2
   ,p_attribute11                     out nocopy varchar2
   ,p_attribute12                     out nocopy varchar2
   ,p_attribute13                     out nocopy varchar2
   ,p_attribute14                     out nocopy varchar2
   ,p_attribute15                     out nocopy varchar2
   ,p_attribute16                     out nocopy varchar2
   ,p_attribute17                     out nocopy varchar2
   ,p_attribute18                     out nocopy varchar2
   ,p_attribute19                     out nocopy varchar2
   ,p_attribute20                     out nocopy varchar2
   ,p_attribute21                     out nocopy varchar2
   ,p_attribute22                     out nocopy varchar2
   ,p_attribute23                     out nocopy varchar2
   ,p_attribute24                     out nocopy varchar2
   ,p_attribute25                     out nocopy varchar2
   ,p_attribute26                     out nocopy varchar2
   ,p_attribute27                     out nocopy varchar2
   ,p_attribute28                     out nocopy varchar2
   ,p_attribute29                     out nocopy varchar2
   ,p_attribute30                     out nocopy varchar2
   ,p_per_information_category        out nocopy varchar2
   ,p_per_information1                out nocopy varchar2
   ,p_per_information2                out nocopy varchar2
   ,p_per_information3                out nocopy varchar2
   ,p_per_information4                out nocopy varchar2
   ,p_per_information5                out nocopy varchar2
   ,p_per_information6                out nocopy varchar2
   ,p_per_information7                out nocopy varchar2
   ,p_per_information8                out nocopy varchar2
   ,p_per_information9                out nocopy varchar2
   ,p_per_information10               out nocopy varchar2
   ,p_per_information11               out nocopy varchar2
   ,p_per_information12               out nocopy varchar2
   ,p_per_information13               out nocopy varchar2
   ,p_per_information14               out nocopy varchar2
   ,p_per_information15               out nocopy varchar2
   ,p_per_information16               out nocopy varchar2
   ,p_per_information17               out nocopy varchar2
   ,p_per_information18               out nocopy varchar2
   ,p_per_information19               out nocopy varchar2
   ,p_per_information20               out nocopy varchar2
   ,p_per_information21               out nocopy varchar2
   ,p_per_information22               out nocopy varchar2
   ,p_per_information23               out nocopy varchar2
   ,p_per_information24               out nocopy varchar2
   ,p_per_information25               out nocopy varchar2
   ,p_per_information26               out nocopy varchar2
   ,p_per_information27               out nocopy varchar2
   ,p_per_information28               out nocopy varchar2
   ,p_per_information29               out nocopy varchar2
   ,p_per_information30               out nocopy varchar2
   ,p_title_meaning                   out nocopy varchar2
   ,p_marital_status_meaning          out nocopy varchar2
   ,p_full_name                       out nocopy varchar2
   ,p_business_group_id               out nocopy number
   ,p_review_proc_call                out nocopy varchar2
   ,p_action_type                     out nocopy varchar2
);

--
-- ---------------------------------------------------------------------------
-- ---------------------------- < update_person> ------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will perform validations when a user presses Next
--          on Update Basic Details entry page or on the Review page.
--          Either case, the data will be saved to the transaction table.
--          If this procedure is invoked from Review page, it will first check
--          that if a transaction already exists.  If it does, it will update
--          the current transaction record.
-- ---------------------------------------------------------------------------
procedure update_person
  (p_item_type                    in varchar2
  ,p_item_key                     in varchar2
  ,p_actid                        in number
  ,p_login_person_id              in number
  ,p_process_section_name         in varchar2
  ,p_action_type                  in varchar2
  ,p_validate_mode                in varchar2 default 'Y'
  ,p_review_page_region_code      in varchar2 default hr_api.g_varchar2
  ,p_effective_date               in      date
  ,p_business_group_id            in number
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_npw_number                   in      varchar2 default hr_api.g_varchar2
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
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
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
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_adjusted_svc_date            in      date     default hr_api.g_date
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
  ,p_effective_start_date         out nocopy     date
  ,p_effective_end_date           out nocopy     date
  ,p_full_name                    in out nocopy  varchar2
  ,p_comment_id                   out nocopy     number
  ,p_name_combination_warning     out nocopy     varchar2
  ,p_assign_payroll_warning       in out nocopy     varchar2
  ,p_orig_hire_warning            out nocopy     varchar2
  ,p_save_mode                    in      varchar2 default null
  ,p_asgn_change_mode             in      varchar2 default null
  ,p_appl_assign_id                 in   number default null
  ,p_error_message                out nocopy     long
  ,p_ni_duplicate_warn_or_err     in out nocopy varchar2
  ,p_validate_ni                  in out nocopy varchar2
 );

--
-- ---------------------------------------------------------------------------
-- ---------------------- < validate_basic_details> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will perform field validation and then call the api.
--          This procedure is invoked from Update Basic Details page.
-- ---------------------------------------------------------------------------
PROCEDURE validate_basic_details
    (p_validate_mode               in boolean default false
    ,p_attribute_update_mode       in varchar2
    ,p_effective_date              in date
    ,p_person_id                   in number
    ,p_object_version_number       in out nocopy number
    ,p_person_type_id              in number   default hr_api.g_number
    ,p_last_name                   in varchar2 default hr_api.g_varchar2
    ,p_applicant_number            in varchar2 default hr_api.g_varchar2
    ,p_comments                    in varchar2 default hr_api.g_varchar2
    ,p_date_employee_data_verified in date     default hr_api.g_date
    ,p_original_date_of_hire       in date     default hr_api.g_date
    ,p_date_of_birth               in date     default hr_api.g_date
    ,p_town_of_birth               in varchar2 default hr_api.g_varchar2
    ,p_region_of_birth             in varchar2 default hr_api.g_varchar2
    ,p_country_of_birth            in varchar2 default hr_api.g_varchar2
    ,p_global_person_id            in varchar2 default hr_api.g_varchar2
    ,p_email_address               in varchar2 default hr_api.g_varchar2
    ,p_employee_number             in out nocopy varchar2
    ,p_npw_number                  in varchar2 default hr_api.g_varchar2
    ,p_expense_check_send_to_addres in varchar2 default hr_api.g_varchar2
    ,p_first_name                  in varchar2 default hr_api.g_varchar2
    ,p_known_as                    in varchar2 default hr_api.g_varchar2
    ,p_marital_status              in varchar2 default hr_api.g_varchar2
    ,p_middle_names                in varchar2 default hr_api.g_varchar2
    ,p_nationality                 in varchar2 default hr_api.g_varchar2
    ,p_national_identifier         in varchar2 default hr_api.g_varchar2
    ,p_previous_last_name          in varchar2 default hr_api.g_varchar2
    ,p_registered_disabled_flag    in varchar2 default hr_api.g_varchar2
    ,p_sex                         in varchar2 default hr_api.g_varchar2
    ,p_title                       in varchar2 default hr_api.g_varchar2
    ,p_vendor_id                   in number   default hr_api.g_number
    ,p_work_telephone              in varchar2 default hr_api.g_varchar2
    ,p_suffix                      in varchar2 default hr_api.g_varchar2
    ,p_date_of_death               in date     default hr_api.g_date
    ,p_background_check_status     in varchar2 default hr_api.g_varchar2
    ,p_background_date_check       in date     default hr_api.g_date
    ,p_blood_type                  in varchar2 default hr_api.g_varchar2
    ,p_correspondence_language     in varchar2 default hr_api.g_varchar2
    ,p_fast_path_employee          in varchar2 default hr_api.g_varchar2
    ,p_fte_capacity                in number   default hr_api.g_number
    ,p_hold_applicant_date_until   in date     default hr_api.g_date
    ,p_honors                      in varchar2 default hr_api.g_varchar2
    ,p_internal_location           in varchar2 default hr_api.g_varchar2
    ,p_last_medical_test_by        in varchar2 default hr_api.g_varchar2
    ,p_last_medical_test_date      in date     default hr_api.g_date
    ,p_mailstop                    in varchar2 default hr_api.g_varchar2
    ,p_office_number               in varchar2 default hr_api.g_varchar2
    ,p_on_military_service         in varchar2 default hr_api.g_varchar2
    ,p_pre_name_adjunct            in varchar2 default hr_api.g_varchar2
    ,p_projected_start_date        in date     default hr_api.g_date
    ,p_rehire_authorizor           in varchar2 default hr_api.g_varchar2
    ,p_rehire_recommendation       in varchar2 default hr_api.g_varchar2
    ,p_resume_exists               in varchar2 default hr_api.g_varchar2
    ,p_resume_last_updated         in date     default hr_api.g_date
    ,p_second_passport_exists      in varchar2 default hr_api.g_varchar2
    ,p_student_status              in varchar2 default hr_api.g_varchar2
    ,p_work_schedule               in varchar2 default hr_api.g_varchar2
    ,p_rehire_reason               in varchar2 default hr_api.g_varchar2
    ,p_benefit_group_id            in number   default hr_api.g_number
    ,p_receipt_of_death_cert_date  in date     default hr_api.g_date
    ,p_coord_ben_med_pln_no        in varchar2 default hr_api.g_varchar2
    ,p_coord_ben_no_cvg_flag       in varchar2 default hr_api.g_varchar2
    ,p_uses_tobacco_flag           in varchar2 default hr_api.g_varchar2
    ,p_dpdnt_adoption_date         in date     default hr_api.g_date
    ,p_dpdnt_vlntry_svce_flag      in varchar2 default hr_api.g_varchar2
    ,p_adjusted_svc_date           in date     default hr_api.g_date
    ,p_attribute_category          in varchar2 default hr_api.g_varchar2
    ,p_attribute1                  in varchar2 default hr_api.g_varchar2
    ,p_attribute2                  in varchar2 default hr_api.g_varchar2
    ,p_attribute3                  in varchar2 default hr_api.g_varchar2
    ,p_attribute4                  in varchar2 default hr_api.g_varchar2
    ,p_attribute5                  in varchar2 default hr_api.g_varchar2
    ,p_attribute6                  in varchar2 default hr_api.g_varchar2
    ,p_attribute7                  in varchar2 default hr_api.g_varchar2
    ,p_attribute8                  in varchar2 default hr_api.g_varchar2
    ,p_attribute9                  in varchar2 default hr_api.g_varchar2
    ,p_attribute10                 in varchar2 default hr_api.g_varchar2
    ,p_attribute11                 in varchar2 default hr_api.g_varchar2
    ,p_attribute12                 in varchar2 default hr_api.g_varchar2
    ,p_attribute13                 in varchar2 default hr_api.g_varchar2
    ,p_attribute14                 in varchar2 default hr_api.g_varchar2
    ,p_attribute15                 in varchar2 default hr_api.g_varchar2
    ,p_attribute16                 in varchar2 default hr_api.g_varchar2
    ,p_attribute17                 in varchar2 default hr_api.g_varchar2
    ,p_attribute18                 in varchar2 default hr_api.g_varchar2
    ,p_attribute19                 in varchar2 default hr_api.g_varchar2
    ,p_attribute20                 in varchar2 default hr_api.g_varchar2
    ,p_attribute21                 in varchar2 default hr_api.g_varchar2
    ,p_attribute22                 in varchar2 default hr_api.g_varchar2
    ,p_attribute23                 in varchar2 default hr_api.g_varchar2
    ,p_attribute24                 in varchar2 default hr_api.g_varchar2
    ,p_attribute25                 in varchar2 default hr_api.g_varchar2
    ,p_attribute26                 in varchar2 default hr_api.g_varchar2
    ,p_attribute27                 in varchar2 default hr_api.g_varchar2
    ,p_attribute28                 in varchar2 default hr_api.g_varchar2
    ,p_attribute29                 in varchar2 default hr_api.g_varchar2
    ,p_attribute30                 in varchar2 default hr_api.g_varchar2
    ,p_per_information_category    in varchar2 default hr_api.g_varchar2
    ,p_per_information1            in varchar2 default hr_api.g_varchar2
    ,p_per_information2            in varchar2 default hr_api.g_varchar2
    ,p_per_information3            in varchar2 default hr_api.g_varchar2
    ,p_per_information4            in varchar2 default hr_api.g_varchar2
    ,p_per_information5            in varchar2 default hr_api.g_varchar2
    ,p_per_information6            in varchar2 default hr_api.g_varchar2
    ,p_per_information7            in varchar2 default hr_api.g_varchar2
    ,p_per_information8            in varchar2 default hr_api.g_varchar2
    ,p_per_information9            in varchar2 default hr_api.g_varchar2
    ,p_per_information10           in varchar2 default hr_api.g_varchar2
    ,p_per_information11           in varchar2 default hr_api.g_varchar2
    ,p_per_information12           in varchar2 default hr_api.g_varchar2
    ,p_per_information13           in varchar2 default hr_api.g_varchar2
    ,p_per_information14           in varchar2 default hr_api.g_varchar2
    ,p_per_information15           in varchar2 default hr_api.g_varchar2
    ,p_per_information16           in varchar2 default hr_api.g_varchar2
    ,p_per_information17           in varchar2 default hr_api.g_varchar2
    ,p_per_information18           in varchar2 default hr_api.g_varchar2
    ,p_per_information19           in varchar2 default hr_api.g_varchar2
    ,p_per_information20           in varchar2 default hr_api.g_varchar2
    ,p_per_information21           in varchar2 default hr_api.g_varchar2
    ,p_per_information22           in varchar2 default hr_api.g_varchar2
    ,p_per_information23           in varchar2 default hr_api.g_varchar2
    ,p_per_information24           in varchar2 default hr_api.g_varchar2
    ,p_per_information25           in varchar2 default hr_api.g_varchar2
    ,p_per_information26           in varchar2 default hr_api.g_varchar2
    ,p_per_information27           in varchar2 default hr_api.g_varchar2
    ,p_per_information28           in varchar2 default hr_api.g_varchar2
    ,p_per_information29           in varchar2 default hr_api.g_varchar2
    ,p_per_information30           in varchar2 default hr_api.g_varchar2
    ,p_effective_start_date        out nocopy     date
    ,p_effective_end_date          out nocopy     date
    ,p_full_name                   out nocopy     varchar2
    ,p_comment_id                  out nocopy     number
    ,p_name_combination_warning    out nocopy     boolean
    ,p_assign_payroll_warning      in out nocopy     boolean
    ,p_orig_hire_warning           out nocopy     boolean
    ,p_error_message               out nocopy     long
);

--
--
-- ---------------------------------------------------------------------------
-- ---------------------------- < is_rec_changed > ---------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This function will check field by field to determine if there
--          are any changes made to the record.
-- ---------------------------------------------------------------------------
FUNCTION  is_rec_changed
    (p_effective_date              in date
    ,p_person_id                   in number
    ,p_object_version_number       in number
    ,p_person_type_id              in number   default hr_api.g_number
    ,p_last_name                   in varchar2 default hr_api.g_varchar2
    ,p_applicant_number            in varchar2 default hr_api.g_varchar2
    ,p_comments                    in varchar2 default hr_api.g_varchar2
    ,p_date_employee_data_verified in date     default hr_api.g_date
    ,p_original_date_of_hire       in date     default hr_api.g_date
    ,p_date_of_birth               in date     default hr_api.g_date
    ,p_town_of_birth               in varchar2 default hr_api.g_varchar2
    ,p_region_of_birth             in varchar2 default hr_api.g_varchar2
    ,p_country_of_birth            in varchar2 default hr_api.g_varchar2
    ,p_global_person_id            in varchar2 default hr_api.g_varchar2
    ,p_email_address               in varchar2 default hr_api.g_varchar2
    ,p_employee_number             in varchar2 default hr_api.g_varchar2
    ,p_npw_number                  in varchar2 default hr_api.g_varchar2
    ,p_expense_check_send_to_addres in varchar2 default hr_api.g_varchar2
    ,p_first_name                  in varchar2 default hr_api.g_varchar2
    ,p_known_as                    in varchar2 default hr_api.g_varchar2
    ,p_marital_status              in varchar2 default hr_api.g_varchar2
    ,p_middle_names                in varchar2 default hr_api.g_varchar2
    ,p_nationality                 in varchar2 default hr_api.g_varchar2
    ,p_national_identifier         in varchar2 default hr_api.g_varchar2
    ,p_previous_last_name          in varchar2 default hr_api.g_varchar2
    ,p_registered_disabled_flag    in varchar2 default hr_api.g_varchar2
    ,p_sex                         in varchar2 default hr_api.g_varchar2
    ,p_title                       in varchar2 default hr_api.g_varchar2
    ,p_vendor_id                   in number   default hr_api.g_number
    ,p_work_telephone              in varchar2 default hr_api.g_varchar2
    ,p_suffix                      in varchar2 default hr_api.g_varchar2
    ,p_date_of_death               in date     default hr_api.g_date
    ,p_background_check_status     in varchar2 default hr_api.g_varchar2
    ,p_background_date_check       in date     default hr_api.g_date
    ,p_blood_type                  in varchar2 default hr_api.g_varchar2
    ,p_correspondence_language     in varchar2 default hr_api.g_varchar2
    ,p_fast_path_employee          in varchar2 default hr_api.g_varchar2
    ,p_fte_capacity                in number   default hr_api.g_number
    ,p_hold_applicant_date_until   in date     default hr_api.g_date
    ,p_honors                      in varchar2 default hr_api.g_varchar2
    ,p_internal_location           in varchar2 default hr_api.g_varchar2
    ,p_last_medical_test_by        in varchar2 default hr_api.g_varchar2
    ,p_last_medical_test_date      in date     default hr_api.g_date
    ,p_mailstop                    in varchar2 default hr_api.g_varchar2
    ,p_office_number               in varchar2 default hr_api.g_varchar2
    ,p_on_military_service         in varchar2 default hr_api.g_varchar2
    ,p_pre_name_adjunct            in varchar2 default hr_api.g_varchar2
    ,p_projected_start_date        in date     default hr_api.g_date
    ,p_rehire_authorizor           in varchar2 default hr_api.g_varchar2
    ,p_rehire_recommendation       in varchar2 default hr_api.g_varchar2
    ,p_resume_exists               in varchar2 default hr_api.g_varchar2
    ,p_resume_last_updated         in date     default hr_api.g_date
    ,p_second_passport_exists      in varchar2 default hr_api.g_varchar2
    ,p_student_status              in varchar2 default hr_api.g_varchar2
    ,p_work_schedule               in varchar2 default hr_api.g_varchar2
    ,p_rehire_reason               in varchar2 default hr_api.g_varchar2
    ,p_benefit_group_id            in number   default hr_api.g_number
    ,p_receipt_of_death_cert_date  in date     default hr_api.g_date
    ,p_coord_ben_med_pln_no        in varchar2 default hr_api.g_varchar2
    ,p_coord_ben_no_cvg_flag       in varchar2 default hr_api.g_varchar2
    ,p_uses_tobacco_flag           in varchar2 default hr_api.g_varchar2
    ,p_dpdnt_adoption_date         in date     default hr_api.g_date
    ,p_dpdnt_vlntry_svce_flag      in varchar2 default hr_api.g_varchar2
    ,p_adjusted_svc_date           in date     default hr_api.g_date
    ,p_attribute_category          in varchar2 default hr_api.g_varchar2
    ,p_attribute1                  in varchar2 default hr_api.g_varchar2
    ,p_attribute2                  in varchar2 default hr_api.g_varchar2
    ,p_attribute3                  in varchar2 default hr_api.g_varchar2
    ,p_attribute4                  in varchar2 default hr_api.g_varchar2
    ,p_attribute5                  in varchar2 default hr_api.g_varchar2
    ,p_attribute6                  in varchar2 default hr_api.g_varchar2
    ,p_attribute7                  in varchar2 default hr_api.g_varchar2
    ,p_attribute8                  in varchar2 default hr_api.g_varchar2
    ,p_attribute9                  in varchar2 default hr_api.g_varchar2
    ,p_attribute10                 in varchar2 default hr_api.g_varchar2
    ,p_attribute11                 in varchar2 default hr_api.g_varchar2
    ,p_attribute12                 in varchar2 default hr_api.g_varchar2
    ,p_attribute13                 in varchar2 default hr_api.g_varchar2
    ,p_attribute14                 in varchar2 default hr_api.g_varchar2
    ,p_attribute15                 in varchar2 default hr_api.g_varchar2
    ,p_attribute16                 in varchar2 default hr_api.g_varchar2
    ,p_attribute17                 in varchar2 default hr_api.g_varchar2
    ,p_attribute18                 in varchar2 default hr_api.g_varchar2
    ,p_attribute19                 in varchar2 default hr_api.g_varchar2
    ,p_attribute20                 in varchar2 default hr_api.g_varchar2
    ,p_attribute21                 in varchar2 default hr_api.g_varchar2
    ,p_attribute22                 in varchar2 default hr_api.g_varchar2
    ,p_attribute23                 in varchar2 default hr_api.g_varchar2
    ,p_attribute24                 in varchar2 default hr_api.g_varchar2
    ,p_attribute25                 in varchar2 default hr_api.g_varchar2
    ,p_attribute26                 in varchar2 default hr_api.g_varchar2
    ,p_attribute27                 in varchar2 default hr_api.g_varchar2
    ,p_attribute28                 in varchar2 default hr_api.g_varchar2
    ,p_attribute29                 in varchar2 default hr_api.g_varchar2
    ,p_attribute30                 in varchar2 default hr_api.g_varchar2
    ,p_per_information_category    in varchar2 default hr_api.g_varchar2
    ,p_per_information1            in varchar2 default hr_api.g_varchar2
    ,p_per_information2            in varchar2 default hr_api.g_varchar2
    ,p_per_information3            in varchar2 default hr_api.g_varchar2
    ,p_per_information4            in varchar2 default hr_api.g_varchar2
    ,p_per_information5            in varchar2 default hr_api.g_varchar2
    ,p_per_information6            in varchar2 default hr_api.g_varchar2
    ,p_per_information7            in varchar2 default hr_api.g_varchar2
    ,p_per_information8            in varchar2 default hr_api.g_varchar2
    ,p_per_information9            in varchar2 default hr_api.g_varchar2
    ,p_per_information10           in varchar2 default hr_api.g_varchar2
    ,p_per_information11           in varchar2 default hr_api.g_varchar2
    ,p_per_information12           in varchar2 default hr_api.g_varchar2
    ,p_per_information13           in varchar2 default hr_api.g_varchar2
    ,p_per_information14           in varchar2 default hr_api.g_varchar2
    ,p_per_information15           in varchar2 default hr_api.g_varchar2
    ,p_per_information16           in varchar2 default hr_api.g_varchar2
    ,p_per_information17           in varchar2 default hr_api.g_varchar2
    ,p_per_information18           in varchar2 default hr_api.g_varchar2
    ,p_per_information19           in varchar2 default hr_api.g_varchar2
    ,p_per_information20           in varchar2 default hr_api.g_varchar2
    ,p_per_information21           in varchar2 default hr_api.g_varchar2
    ,p_per_information22           in varchar2 default hr_api.g_varchar2
    ,p_per_information23           in varchar2 default hr_api.g_varchar2
    ,p_per_information24           in varchar2 default hr_api.g_varchar2
    ,p_per_information25           in varchar2 default hr_api.g_varchar2
    ,p_per_information26           in varchar2 default hr_api.g_varchar2
    ,p_per_information27           in varchar2 default hr_api.g_varchar2
    ,p_per_information28           in varchar2 default hr_api.g_varchar2
    ,p_per_information29           in varchar2 default hr_api.g_varchar2
    ,p_per_information30           in varchar2 default hr_api.g_varchar2
   )
   return boolean;

--
-- ---------------------------------------------------------------------------
-- ----------------------------- < process_api > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
-- ---------------------------------------------------------------------------
procedure process_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
);

procedure process_dummy_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
);

--
--Start Registration

-------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will perform validations when a user presses Next
--          on Insert Basic Details entry page the data will be saved to the
--          transaction table.
-- ---------------------------------------------------------------------------
--
procedure create_person
  (p_item_type                     in varchar2
  ,p_item_key                      in varchar2
  ,p_actid                         in number
  ,p_login_person_id               in number
  ,p_process_section_name          in varchar2
  ,p_action_type                   in varchar2
  ,p_validate                      in varchar2 default 'Y'
                                     --boolean default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_review_page_region_code       in varchar2 default hr_api.g_varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_npw_number                    in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_per_information_category      in     varchar2 default null
  ,p_per_information1              in     varchar2 default null
  ,p_per_information2              in     varchar2 default null
  ,p_per_information3              in     varchar2 default null
  ,p_per_information4              in     varchar2 default null
  ,p_per_information5              in     varchar2 default null
  ,p_per_information6              in     varchar2 default null
  ,p_per_information7              in     varchar2 default null
  ,p_per_information8              in     varchar2 default null
  ,p_per_information9              in     varchar2 default null
  ,p_per_information10             in     varchar2 default null
  ,p_per_information11             in     varchar2 default null
  ,p_per_information12             in     varchar2 default null
  ,p_per_information13             in     varchar2 default null
  ,p_per_information14             in     varchar2 default null
  ,p_per_information15             in     varchar2 default null
  ,p_per_information16             in     varchar2 default null
  ,p_per_information17             in     varchar2 default null
  ,p_per_information18             in     varchar2 default null
  ,p_per_information19             in     varchar2 default null
  ,p_per_information20             in     varchar2 default null
  ,p_per_information21             in     varchar2 default null
  ,p_per_information22             in     varchar2 default null
  ,p_per_information23             in     varchar2 default null
  ,p_per_information24             in     varchar2 default null
  ,p_per_information25             in     varchar2 default null
  ,p_per_information26             in     varchar2 default null
  ,p_per_information27             in     varchar2 default null
  ,p_per_information28             in     varchar2 default null
  ,p_per_information29             in     varchar2 default null
  ,p_per_information30             in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_global_person_id             in      varchar2 default null
  ,p_effective_date               in      date default sysdate
  ,p_attribute_update_mode        in      varchar2 default null
  ,p_object_version_number        in      number default null
  ,p_applicant_number             in      varchar2 default null
  ,p_comments                     in      varchar2 default null
  ,p_rehire_authorizor            in      varchar2 default null
  ,p_rehire_recommendation        in      varchar2 default null
  ,p_hold_applicant_date_until    in      date     default null
  ,p_rehire_reason                in      varchar2 default null
  ,p_flow_name                    in      varchar2 default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy varchar2
  ,p_assign_payroll_warning           out nocopy varchar2
  ,p_orig_hire_warning                out nocopy varchar2
  ,p_party_id                     in      number default null
  ,p_save_mode                    in      varchar2 default null
  ,p_error_message                out nocopy     long
  ,p_ni_duplicate_warn_or_err     in out nocopy varchar2
  ,p_validate_ni                  in out nocopy varchar2
  );

/*   When we try to hire an applicant with payroll and no DOB or address we get error.
This happens because when we hire applicant the payroll validation fails. Now before
hiring set his payroll to null.
In process_api reverted it back to original value after hiring.                                        */

procedure process_applicant(
    p_effective_date   in date
   ,p_person_id        in number
   ,p_business_group_id    in number
   ,p_assignment_id        in number
   ,p_soft_coding_keyflex_id in number default null
   ,p_is_payroll_upd out nocopy boolean);

--
--End Start Registration
--
END hr_process_person_ss;
--
--

/
