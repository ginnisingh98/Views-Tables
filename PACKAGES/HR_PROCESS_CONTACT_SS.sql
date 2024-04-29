--------------------------------------------------------
--  DDL for Package HR_PROCESS_CONTACT_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROCESS_CONTACT_SS" AUTHID CURRENT_USER AS
/* $Header: hrconwrs.pkh 120.3 2006/11/17 14:40:28 gpurohit noship $*/
--
-- ---------------------------------------------------------------------------+
-- ---------------------- < get_contact_relationship_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------
--
  g_is_address_updated      boolean	:= false;
  g_date_format           constant varchar2(10):='RRRR/MM/DD';
  g_correct               constant varchar2(10) := 'CORRECT';
  g_change                constant varchar2(10) := 'CHANGE';
  g_attribute_update      constant varchar2(100) := 'ATTRIBUTE_UPDATE';
  g_attribute_correct     constant varchar2(100) := 'ATTRIBUTE_CORRECTION';
  g_update_for_approval   constant varchar2(100) := 'UPDATE_FOR_APPROVAL';
  g_update_basic_details  constant varchar2(100) := 'UPDATE_BASIC_DETAILS';
  g_trans_actvty_result_code constant varchar2(100) := 'NEXT';
  g_contact_person_id     number;
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
-- ---------------------------------------------------------------------------
-- ---------------------- < get_contact_relationship_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get which regions are changed in earlier save
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is also used when the user first time navigates to review page.
--          Based on the output of this procedure Review page layout is built.
--          Ex : If contacts and phone changed then both are shown, if Only
--          phone changed then shows phone data.
-- ---------------------------------------------------------------------------
--
PROCEDURE get_contact_regions_status_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_contact_changed                 out nocopy varchar2
   ,p_phone_changed                   out nocopy varchar2
   ,p_address_changed                 out nocopy varchar2
   ,p_second_address_changed          out nocopy varchar2
   ,p_parent_id                       out nocopy varchar2
   ,p_contact_person_id               out nocopy varchar2
   ,p_contact_relationship_id         out nocopy varchar2
   ,p_contact_operation               out nocopy varchar2
   ,p_shared_Residence_Flag           out nocopy varchar2
   ,p_save_mode                       out nocopy varchar2
   ,p_address_id                      out nocopy varchar2
   ,p_contact_step_id                 out nocopy varchar2
   ,p_phone_step_id                   out nocopy varchar2
   ,p_address_step_id                 out nocopy varchar2
   ,p_second_address_step_id          out nocopy varchar2
   ,p_first_name                      out nocopy varchar2
   ,p_last_name                       out nocopy varchar2
   ,p_contact_set                     in  varchar2
   );
--
PROCEDURE get_contact_relationship_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  number
   ,p_trans_rec_count                 out nocopy number
   ,p_effective_date                  out nocopy date
   ,p_attribute_update_mode           out nocopy varchar2
   ,P_CONTACT_RELATIONSHIP_ID         out nocopy NUMBER
   ,P_CONTACT_TYPE                    out nocopy VARCHAR2
   ,P_COMMENTS                        out nocopy VARCHAR2
   ,P_PRIMARY_CONTACT_FLAG            out nocopy VARCHAR2
   ,P_THIRD_PARTY_PAY_FLAG            out nocopy VARCHAR2
   ,p_bondholder_flag                 out nocopy varchar2
   ,p_date_start                      out nocopy date
   ,p_start_life_reason_id            out nocopy number
   ,p_date_end                        out nocopy date
   ,p_end_life_reason_id              out nocopy number
   ,p_rltd_per_rsds_w_dsgntr_flag      out nocopy varchar2
   ,p_personal_flag                    out nocopy varchar2
   ,p_sequence_number                  out nocopy number
   ,p_dependent_flag                   out nocopy varchar2
   ,p_beneficiary_flag                 out nocopy varchar2
   ,p_cont_attribute_category          out nocopy varchar2
   ,p_cont_attribute1                  out nocopy varchar2
   ,p_cont_attribute2                  out nocopy varchar2
   ,p_cont_attribute3                  out nocopy varchar2
   ,p_cont_attribute4                  out nocopy varchar2
   ,p_cont_attribute5                  out nocopy varchar2
   ,p_cont_attribute6                  out nocopy varchar2
   ,p_cont_attribute7                  out nocopy varchar2
   ,p_cont_attribute8                  out nocopy varchar2
   ,p_cont_attribute9                  out nocopy varchar2
   ,p_cont_attribute10                 out nocopy varchar2
   ,p_cont_attribute11                 out nocopy varchar2
   ,p_cont_attribute12                 out nocopy varchar2
   ,p_cont_attribute13                 out nocopy varchar2
   ,p_cont_attribute14                 out nocopy varchar2
   ,p_cont_attribute15                 out nocopy varchar2
   ,p_cont_attribute16                 out nocopy varchar2
   ,p_cont_attribute17                 out nocopy varchar2
   ,p_cont_attribute18                 out nocopy varchar2
   ,p_cont_attribute19                 out nocopy varchar2
   ,p_cont_attribute20                 out nocopy varchar2
   ,P_CONT_INFORMATION_CATEGORY         out nocopy varchar2
   ,P_CONT_INFORMATION1                 out nocopy varchar2
   ,P_CONT_INFORMATION2                 out nocopy varchar2
   ,P_CONT_INFORMATION3                 out nocopy varchar2
   ,P_CONT_INFORMATION4                 out nocopy varchar2
   ,P_CONT_INFORMATION5                 out nocopy varchar2
   ,P_CONT_INFORMATION6                 out nocopy varchar2
   ,P_CONT_INFORMATION7                 out nocopy varchar2
   ,P_CONT_INFORMATION8                 out nocopy varchar2
   ,P_CONT_INFORMATION9                 out nocopy varchar2
   ,P_CONT_INFORMATION10                out nocopy varchar2
   ,P_CONT_INFORMATION11                out nocopy varchar2
   ,P_CONT_INFORMATION12                out nocopy varchar2
   ,P_CONT_INFORMATION13                out nocopy varchar2
   ,P_CONT_INFORMATION14                out nocopy varchar2
   ,P_CONT_INFORMATION15                out nocopy varchar2
   ,P_CONT_INFORMATION16                out nocopy varchar2
   ,P_CONT_INFORMATION17                out nocopy varchar2
   ,P_CONT_INFORMATION18                out nocopy varchar2
   ,P_CONT_INFORMATION19                out nocopy varchar2
   ,P_CONT_INFORMATION20                out nocopy varchar2
   ,p_object_version_number            out nocopy number
   ,p_review_proc_call                 out nocopy varchar2
 );
--
--
-- ---------------------------------------------------------------------------
-- ---------------------- < get_contact_relationship_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is the procedure which does the actual work.
-- ---------------------------------------------------------------------------
procedure get_contact_relationship_tt
   (p_transaction_step_id             in  number
   ,p_effective_date                  out nocopy date
   ,p_attribute_update_mode           out nocopy varchar2
   ,P_CONTACT_RELATIONSHIP_ID         out nocopy NUMBER
   ,P_CONTACT_TYPE                    out nocopy VARCHAR2
   ,P_COMMENTS                        out nocopy VARCHAR2
   ,P_PRIMARY_CONTACT_FLAG            out nocopy VARCHAR2
   ,P_THIRD_PARTY_PAY_FLAG            out nocopy VARCHAR2
   ,p_bondholder_flag                 out nocopy varchar2
   ,p_date_start                      out nocopy date
   ,p_start_life_reason_id            out nocopy number
   ,p_date_end                        out nocopy date
   ,p_end_life_reason_id              out nocopy number
   ,p_rltd_per_rsds_w_dsgntr_flag      out nocopy varchar2
   ,p_personal_flag                    out nocopy varchar2
   ,p_sequence_number                  out nocopy number
   ,p_dependent_flag                   out nocopy varchar2
   ,p_beneficiary_flag                 out nocopy varchar2
   ,p_cont_attribute_category          out nocopy varchar2
   ,p_cont_attribute1                  out nocopy varchar2
   ,p_cont_attribute2                  out nocopy varchar2
   ,p_cont_attribute3                  out nocopy varchar2
   ,p_cont_attribute4                  out nocopy varchar2
   ,p_cont_attribute5                  out nocopy varchar2
   ,p_cont_attribute6                  out nocopy varchar2
   ,p_cont_attribute7                  out nocopy varchar2
   ,p_cont_attribute8                  out nocopy varchar2
   ,p_cont_attribute9                  out nocopy varchar2
   ,p_cont_attribute10                  out nocopy varchar2
   ,p_cont_attribute11                  out nocopy varchar2
   ,p_cont_attribute12                  out nocopy varchar2
   ,p_cont_attribute13                  out nocopy varchar2
   ,p_cont_attribute14                  out nocopy varchar2
   ,p_cont_attribute15                  out nocopy varchar2
   ,p_cont_attribute16                  out nocopy varchar2
   ,p_cont_attribute17                  out nocopy varchar2
   ,p_cont_attribute18                  out nocopy varchar2
   ,p_cont_attribute19                  out nocopy varchar2
   ,p_cont_attribute20                  out nocopy varchar2
   ,P_CONT_INFORMATION_CATEGORY         out nocopy varchar2
   ,P_CONT_INFORMATION1                 out nocopy varchar2
   ,P_CONT_INFORMATION2                 out nocopy varchar2
   ,P_CONT_INFORMATION3                 out nocopy varchar2
   ,P_CONT_INFORMATION4                 out nocopy varchar2
   ,P_CONT_INFORMATION5                 out nocopy varchar2
   ,P_CONT_INFORMATION6                 out nocopy varchar2
   ,P_CONT_INFORMATION7                 out nocopy varchar2
   ,P_CONT_INFORMATION8                 out nocopy varchar2
   ,P_CONT_INFORMATION9                 out nocopy varchar2
   ,P_CONT_INFORMATION10                out nocopy varchar2
   ,P_CONT_INFORMATION11                out nocopy varchar2
   ,P_CONT_INFORMATION12                out nocopy varchar2
   ,P_CONT_INFORMATION13                out nocopy varchar2
   ,P_CONT_INFORMATION14                out nocopy varchar2
   ,P_CONT_INFORMATION15                out nocopy varchar2
   ,P_CONT_INFORMATION16                out nocopy varchar2
   ,P_CONT_INFORMATION17                out nocopy varchar2
   ,P_CONT_INFORMATION18                out nocopy varchar2
   ,P_CONT_INFORMATION19                out nocopy varchar2
   ,P_CONT_INFORMATION20                out nocopy varchar2
   ,p_object_version_number             out nocopy number
   ,p_review_proc_call                out nocopy varchar2
);
--

procedure is_address_updated
  (P_CONTACT_RELATIONSHIP_ID in number
            ,P_DATE_START  in date
            ,p_transaction_step_id IN NUMBER
            ,p_contact_person_id in number
            ,p_person_id number) ;

  /*
  ||===========================================================================
  || PROCEDURE: update_contact_relationship
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_contact_rel_api.update_contact_relationship()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see peaddapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

PROCEDURE update_contact_relationship
  (p_validate                      in        varchar2  default 'Y'
  ,p_cont_effective_date           in        date
  ,p_contact_relationship_id       in        number
  ,p_contact_type                  in        varchar2  default hr_api.g_varchar2
  ,p_ctr_comments                  in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag          in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag          in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag               in        varchar2  default hr_api.g_varchar2
  ,p_date_start                    in        date      default hr_api.g_date
  ,p_start_life_reason_id          in        number    default hr_api.g_number
  ,p_date_end                      in        date      default hr_api.g_date
  ,p_end_life_reason_id            in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag   in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                 in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number               in        number    default hr_api.g_number
  ,p_dependent_flag                in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category       in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20              in        varchar2  default hr_api.g_varchar2
  ,p_person_id                     in        number -- this could be p_login_person_id
  ,p_login_person_id               in        number    default hr_api.g_number
  ,p_cont_object_version_number    in out nocopy    number
  ,p_item_type                     in        varchar2
  ,p_item_key                      in        varchar2
  ,p_activity_id                   in        number
  ,p_action                        in        varchar2 -- this is p_action_type
  ,p_process_section_name          in        varchar2
  ,p_review_page_region_code       in        varchar2 default hr_api.g_varchar2

  -- Update_person parameters

  ,p_per_effective_date           in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_cont_person_id                  in      number
  ,p_per_object_version_number    in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_per_comments                 in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
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
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_business_group_id            in      number   default hr_api.g_number
  ,p_contact_operation            in      varchar2 default hr_api.g_varchar2
  ,p_emrg_cont_flag               in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_bnf_flag               in      varchar2 default hr_api.g_varchar2
  ,p_save_mode                    in      varchar2 default null
-- Added new params
  ,P_CONT_INFORMATION_CATEGORY 	  in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION1            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION2            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION3            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION4            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION5            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION6            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION7            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION8            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION9            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION10           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION11           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION12           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION13           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION14           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION15           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION16           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION17           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION18           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION19           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION20           in        varchar2    default hr_api.g_varchar2
  ,p_effective_start_date         out nocopy     date
  ,p_effective_end_date           out nocopy     date
  ,p_full_name                    out nocopy     varchar2
  ,p_comment_id                   out nocopy     number
  ,p_name_combination_warning     out nocopy     varchar2
  ,p_assign_payroll_warning       out nocopy     varchar2
  ,p_orig_hire_warning            out nocopy     varchar2
  ,p_ni_duplicate_warn_or_err   out nocopy     varchar2
  ,p_orig_rel_type                in varchar2      default null
 );
--
--
-- ---------------------------------------------------------------------------
-- ---------------------------- < is_rec_changed > ---------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This function will check field by field to determine if there
--          are any changes made to the record.
-- ---------------------------------------------------------------------------
FUNCTION  is_rec_changed (
   p_effective_date                in        date
  ,p_contact_relationship_id       in        number
  ,p_contact_type                  in        varchar2  default hr_api.g_varchar2
  ,p_comments                      in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag          in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag          in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag               in        varchar2  default hr_api.g_varchar2
  ,p_date_start                    in        date      default hr_api.g_date
  ,p_start_life_reason_id          in        number    default hr_api.g_number
  ,p_date_end                      in        date      default hr_api.g_date
  ,p_end_life_reason_id            in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag   in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                 in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number               in        number    default hr_api.g_number
  ,p_dependent_flag                in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category       in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20              in        varchar2  default hr_api.g_varchar2
-- Added new params
  ,P_CONT_INFORMATION_CATEGORY 	  in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION1            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION2            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION3            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION4            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION5            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION6            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION7            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION8            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION9            in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION10           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION11           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION12           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION13           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION14           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION15           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION16           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION17           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION18           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION19           in        varchar2    default hr_api.g_varchar2
  ,P_CONT_INFORMATION20           in        varchar2    default hr_api.g_varchar2
  ,p_object_version_number        in        number ) return boolean;
-- ---------------------------------------------------------------------------
-- ---------------------- < get_contact_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------

procedure get_contact_from_tt
  (
   p_start_date                   out nocopy        date
  ,p_business_group_id            out nocopy        number
  ,p_person_id                    out nocopy        number
  ,p_contact_person_id            out nocopy        number
  ,p_contact_type                 out nocopy        varchar2
  ,p_ctr_comments                 out nocopy        varchar2
  ,p_primary_contact_flag         out nocopy        varchar2
  ,p_date_start                   out nocopy        date
  ,p_start_life_reason_id         out nocopy        number
  ,p_date_end                     out nocopy        date
  ,p_end_life_reason_id           out nocopy        number
  ,p_rltd_per_rsds_w_dsgntr_flag  out nocopy        varchar2
  ,p_personal_flag                out nocopy        varchar2
  ,p_sequence_number              out nocopy        number
  ,p_cont_attribute_category      out nocopy        varchar2
  ,p_cont_attribute1              out nocopy        varchar2
  ,p_cont_attribute2              out nocopy        varchar2
  ,p_cont_attribute3              out nocopy        varchar2
  ,p_cont_attribute4              out nocopy        varchar2
  ,p_cont_attribute5              out nocopy        varchar2
  ,p_cont_attribute6              out nocopy        varchar2
  ,p_cont_attribute7              out nocopy        varchar2
  ,p_cont_attribute8              out nocopy        varchar2
  ,p_cont_attribute9              out nocopy        varchar2
  ,p_cont_attribute10             out nocopy        varchar2
  ,p_cont_attribute11             out nocopy        varchar2
  ,p_cont_attribute12             out nocopy        varchar2
  ,p_cont_attribute13             out nocopy        varchar2
  ,p_cont_attribute14             out nocopy        varchar2
  ,p_cont_attribute15             out nocopy        varchar2
  ,p_cont_attribute16             out nocopy        varchar2
  ,p_cont_attribute17             out nocopy        varchar2
  ,p_cont_attribute18             out nocopy        varchar2
  ,p_cont_attribute19             out nocopy        varchar2
  ,p_cont_attribute20             out nocopy        varchar2
  ,p_third_party_pay_flag         out nocopy        varchar2
  ,p_bondholder_flag              out nocopy        varchar2
  ,p_dependent_flag               out nocopy        varchar2
  ,p_beneficiary_flag             out nocopy        varchar2
  ,p_last_name                    out nocopy        varchar2
  ,p_sex                          out nocopy        varchar2
  ,p_sex_meaning                  out nocopy        varchar2
  ,p_person_type_id               out nocopy        number
  ,p_per_comments                 out nocopy        varchar2
  ,p_date_of_birth                out nocopy        date
  ,p_email_address                out nocopy        varchar2
  ,p_first_name                   out nocopy        varchar2
  ,p_known_as                     out nocopy        varchar2
  ,p_marital_status               out nocopy        varchar2
  ,p_marital_status_meaning       out nocopy        varchar2
  ,p_student_status               out nocopy        varchar2
  ,p_student_status_meaning       out nocopy        varchar2
  ,p_middle_names                 out nocopy        varchar2
  ,p_nationality                  out nocopy        varchar2
  ,p_national_identifier          out nocopy        varchar2
  ,p_previous_last_name           out nocopy        varchar2
  ,p_registered_disabled_flag     out nocopy        varchar2
  ,p_registered_disabled          out nocopy        varchar2
  ,p_title                        out nocopy        varchar2
  ,p_work_telephone               out nocopy        varchar2
  ,p_attribute_category           out nocopy        varchar2
  ,p_attribute1                   out nocopy        varchar2
  ,p_attribute2                   out nocopy        varchar2
  ,p_attribute3                   out nocopy        varchar2
  ,p_attribute4                   out nocopy        varchar2
  ,p_attribute5                   out nocopy        varchar2
  ,p_attribute6                   out nocopy        varchar2
  ,p_attribute7                   out nocopy        varchar2
  ,p_attribute8                   out nocopy        varchar2
  ,p_attribute9                   out nocopy        varchar2
  ,p_attribute10                  out nocopy        varchar2
  ,p_attribute11                  out nocopy        varchar2
  ,p_attribute12                  out nocopy        varchar2
  ,p_attribute13                  out nocopy        varchar2
  ,p_attribute14                  out nocopy        varchar2
  ,p_attribute15                  out nocopy        varchar2
  ,p_attribute16                  out nocopy        varchar2
  ,p_attribute17                  out nocopy        varchar2
  ,p_attribute18                  out nocopy        varchar2
  ,p_attribute19                  out nocopy        varchar2
  ,p_attribute20                  out nocopy        varchar2
  ,p_attribute21                  out nocopy        varchar2
  ,p_attribute22                  out nocopy        varchar2
  ,p_attribute23                  out nocopy        varchar2
  ,p_attribute24                  out nocopy        varchar2
  ,p_attribute25                  out nocopy        varchar2
  ,p_attribute26                  out nocopy        varchar2
  ,p_attribute27                  out nocopy        varchar2
  ,p_attribute28                  out nocopy        varchar2
  ,p_attribute29                  out nocopy        varchar2
  ,p_attribute30                  out nocopy        varchar2
  ,p_per_information_category     out nocopy        varchar2
  ,p_per_information1             out nocopy        varchar2
  ,p_per_information2             out nocopy        varchar2
  ,p_per_information3             out nocopy        varchar2
  ,p_per_information4             out nocopy        varchar2
  ,p_per_information5             out nocopy        varchar2
  ,p_per_information6             out nocopy        varchar2
  ,p_per_information7             out nocopy        varchar2
  ,p_per_information8             out nocopy        varchar2
  ,p_per_information9             out nocopy        varchar2
  ,p_per_information10            out nocopy        varchar2
  ,p_per_information11            out nocopy        varchar2
  ,p_per_information12            out nocopy        varchar2
  ,p_per_information13            out nocopy        varchar2
  ,p_per_information14            out nocopy        varchar2
  ,p_per_information15            out nocopy        varchar2
  ,p_per_information16            out nocopy        varchar2
  ,p_per_information17            out nocopy        varchar2
  ,p_per_information18            out nocopy        varchar2
  ,p_per_information19            out nocopy        varchar2
  ,p_per_information20            out nocopy        varchar2
  ,p_per_information21            out nocopy        varchar2
  ,p_per_information22            out nocopy        varchar2
  ,p_per_information23            out nocopy        varchar2
  ,p_per_information24            out nocopy        varchar2
  ,p_per_information25            out nocopy        varchar2
  ,p_per_information26            out nocopy        varchar2
  ,p_per_information27            out nocopy        varchar2
  ,p_per_information28            out nocopy        varchar2
  ,p_per_information29            out nocopy        varchar2
  ,p_per_information30            out nocopy        varchar2
  ,p_uses_tobacco_flag            out nocopy        varchar2
  ,p_uses_tobacco_meaning         out nocopy        varchar2
  ,p_on_military_service          out nocopy        varchar2
  ,p_on_military_service_meaning  out nocopy        varchar2
  ,p_dpdnt_vlntry_svce_flag       out nocopy        varchar2
  ,p_dpdnt_vlntry_svce_meaning    out nocopy        varchar2
  ,p_correspondence_language      out nocopy        varchar2
  ,p_honors                       out nocopy        varchar2
  ,p_pre_name_adjunct             out nocopy        varchar2
  ,p_suffix                       out nocopy        varchar2
  ,p_create_mirror_flag           out nocopy        varchar2
  ,p_mirror_type                  out nocopy        varchar2
  ,p_mirror_cont_attribute_cat    out nocopy        varchar2
  ,p_mirror_cont_attribute1       out nocopy        varchar2
  ,p_mirror_cont_attribute2       out nocopy        varchar2
  ,p_mirror_cont_attribute3       out nocopy        varchar2
  ,p_mirror_cont_attribute4       out nocopy        varchar2
  ,p_mirror_cont_attribute5       out nocopy        varchar2
  ,p_mirror_cont_attribute6       out nocopy        varchar2
  ,p_mirror_cont_attribute7       out nocopy        varchar2
  ,p_mirror_cont_attribute8       out nocopy        varchar2
  ,p_mirror_cont_attribute9       out nocopy        varchar2
  ,p_mirror_cont_attribute10      out nocopy        varchar2
  ,p_mirror_cont_attribute11      out nocopy        varchar2
  ,p_mirror_cont_attribute12      out nocopy        varchar2
  ,p_mirror_cont_attribute13      out nocopy        varchar2
  ,p_mirror_cont_attribute14      out nocopy        varchar2
  ,p_mirror_cont_attribute15      out nocopy        varchar2
  ,p_mirror_cont_attribute16      out nocopy        varchar2
  ,p_mirror_cont_attribute17      out nocopy        varchar2
  ,p_mirror_cont_attribute18      out nocopy        varchar2
  ,p_mirror_cont_attribute19      out nocopy        varchar2
  ,p_mirror_cont_attribute20      out nocopy        varchar2
  ,p_item_type                    in         varchar2
  ,p_item_key                     in         varchar2
  ,p_activity_id                  in         number
  ,p_action                       out nocopy        varchar2
  ,p_login_person_id              out nocopy        number
  ,p_process_section_name         out nocopy        varchar2
  ,p_review_page_region_code      out nocopy        varchar2
  -- Bug 1914891
  ,p_date_of_death                out nocopy        date
  ,p_dpdnt_adoption_date          out nocopy        date
  ,p_title_meaning                out nocopy        varchar2
  ,p_contact_type_meaning         out nocopy        varchar2
  ,p_contact_operation            out nocopy        varchar2
  ,p_emrg_cont_flag               out nocopy        varchar2
  ,p_dpdnt_bnf_flag               out nocopy        varchar2
  ,p_contact_relationship_id      out nocopy        number
  ,p_cont_object_version_number   out nocopy        number
    -- bug# 2315163
  ,p_is_emrg_cont                 out nocopy        varchar2
  ,p_is_dpdnt_bnf                 out nocopy        varchar2
  ,P_CONT_INFORMATION_CATEGORY    out nocopy        varchar2
  ,P_CONT_INFORMATION1            out nocopy        varchar2
  ,P_CONT_INFORMATION2            out nocopy        varchar2
  ,P_CONT_INFORMATION3            out nocopy        varchar2
  ,P_CONT_INFORMATION4            out nocopy        varchar2
  ,P_CONT_INFORMATION5            out nocopy        varchar2
  ,P_CONT_INFORMATION6            out nocopy        varchar2
  ,P_CONT_INFORMATION7            out nocopy        varchar2
  ,P_CONT_INFORMATION8            out nocopy        varchar2
  ,P_CONT_INFORMATION9            out nocopy        varchar2
  ,P_CONT_INFORMATION10           out nocopy        varchar2
  ,P_CONT_INFORMATION11           out nocopy        varchar2
  ,P_CONT_INFORMATION12           out nocopy        varchar2
  ,P_CONT_INFORMATION13           out nocopy        varchar2
  ,P_CONT_INFORMATION14           out nocopy        varchar2
  ,P_CONT_INFORMATION15           out nocopy        varchar2
  ,P_CONT_INFORMATION16           out nocopy        varchar2
  ,P_CONT_INFORMATION17           out nocopy        varchar2
  ,P_CONT_INFORMATION18           out nocopy        varchar2
  ,P_CONT_INFORMATION19           out nocopy        varchar2
  ,P_CONT_INFORMATION20           out nocopy        varchar2
  );
--

-- ---------------------------------------------------------------------------
-- ---------------------- < get_contact_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is the procedure which does the actual work.
-- ---------------------------------------------------------------------------

procedure get_contact_from_tt
  (p_transaction_step_id          in         number
  ,p_start_date                   out nocopy        date
  ,p_business_group_id            out nocopy        number
  ,p_person_id                    out nocopy        number
  ,p_contact_person_id            out nocopy        number
  ,p_contact_type                 out nocopy        varchar2
  ,p_ctr_comments                 out nocopy        varchar2
  ,p_primary_contact_flag         out nocopy        varchar2
  ,p_date_start                   out nocopy        date
  ,p_start_life_reason_id         out nocopy        number
  ,p_date_end                     out nocopy        date
  ,p_end_life_reason_id           out nocopy        number
  ,p_rltd_per_rsds_w_dsgntr_flag  out nocopy        varchar2
  ,p_personal_flag                out nocopy        varchar2
  ,p_sequence_number              out nocopy        number
  ,p_cont_attribute_category      out nocopy        varchar2
  ,p_cont_attribute1              out nocopy        varchar2
  ,p_cont_attribute2              out nocopy        varchar2
  ,p_cont_attribute3              out nocopy        varchar2
  ,p_cont_attribute4              out nocopy        varchar2
  ,p_cont_attribute5              out nocopy        varchar2
  ,p_cont_attribute6              out nocopy        varchar2
  ,p_cont_attribute7              out nocopy        varchar2
  ,p_cont_attribute8              out nocopy        varchar2
  ,p_cont_attribute9              out nocopy        varchar2
  ,p_cont_attribute10             out nocopy        varchar2
  ,p_cont_attribute11             out nocopy        varchar2
  ,p_cont_attribute12             out nocopy        varchar2
  ,p_cont_attribute13             out nocopy        varchar2
  ,p_cont_attribute14             out nocopy        varchar2
  ,p_cont_attribute15             out nocopy        varchar2
  ,p_cont_attribute16             out nocopy        varchar2
  ,p_cont_attribute17             out nocopy        varchar2
  ,p_cont_attribute18             out nocopy        varchar2
  ,p_cont_attribute19             out nocopy        varchar2
  ,p_cont_attribute20             out nocopy        varchar2
  ,p_third_party_pay_flag         out nocopy        varchar2
  ,p_bondholder_flag              out nocopy        varchar2
  ,p_dependent_flag               out nocopy        varchar2
  ,p_beneficiary_flag             out nocopy        varchar2
  ,p_last_name                    out nocopy        varchar2
  ,p_sex                          out nocopy        varchar2
  ,p_sex_meaning                  out nocopy        varchar2
  ,p_person_type_id               out nocopy        number
  ,p_per_comments                 out nocopy        varchar2
  ,p_date_of_birth                out nocopy        date
  ,p_email_address                out nocopy        varchar2
  ,p_first_name                   out nocopy        varchar2
  ,p_known_as                     out nocopy        varchar2
  ,p_marital_status               out nocopy        varchar2
  ,p_marital_status_meaning       out nocopy        varchar2
  ,p_student_status               out nocopy        varchar2
  ,p_student_status_meaning       out nocopy        varchar2
  ,p_middle_names                 out nocopy        varchar2
  ,p_nationality                  out nocopy        varchar2
  ,p_national_identifier          out nocopy        varchar2
  ,p_previous_last_name           out nocopy        varchar2
  ,p_registered_disabled_flag     out nocopy        varchar2
  ,p_registered_disabled          out nocopy        varchar2
  ,p_title                        out nocopy        varchar2
  ,p_work_telephone               out nocopy        varchar2
  ,p_attribute_category           out nocopy        varchar2
  ,p_attribute1                   out nocopy        varchar2
  ,p_attribute2                   out nocopy        varchar2
  ,p_attribute3                   out nocopy        varchar2
  ,p_attribute4                   out nocopy        varchar2
  ,p_attribute5                   out nocopy        varchar2
  ,p_attribute6                   out nocopy        varchar2
  ,p_attribute7                   out nocopy        varchar2
  ,p_attribute8                   out nocopy        varchar2
  ,p_attribute9                   out nocopy        varchar2
  ,p_attribute10                  out nocopy        varchar2
  ,p_attribute11                  out nocopy        varchar2
  ,p_attribute12                  out nocopy        varchar2
  ,p_attribute13                  out nocopy        varchar2
  ,p_attribute14                  out nocopy        varchar2
  ,p_attribute15                  out nocopy        varchar2
  ,p_attribute16                  out nocopy        varchar2
  ,p_attribute17                  out nocopy        varchar2
  ,p_attribute18                  out nocopy        varchar2
  ,p_attribute19                  out nocopy        varchar2
  ,p_attribute20                  out nocopy        varchar2
  ,p_attribute21                  out nocopy        varchar2
  ,p_attribute22                  out nocopy        varchar2
  ,p_attribute23                  out nocopy        varchar2
  ,p_attribute24                  out nocopy        varchar2
  ,p_attribute25                  out nocopy        varchar2
  ,p_attribute26                  out nocopy        varchar2
  ,p_attribute27                  out nocopy        varchar2
  ,p_attribute28                  out nocopy        varchar2
  ,p_attribute29                  out nocopy        varchar2
  ,p_attribute30                  out nocopy        varchar2
  ,p_per_information_category     out nocopy        varchar2
  ,p_per_information1             out nocopy        varchar2
  ,p_per_information2             out nocopy        varchar2
  ,p_per_information3             out nocopy        varchar2
  ,p_per_information4             out nocopy        varchar2
  ,p_per_information5             out nocopy        varchar2
  ,p_per_information6             out nocopy        varchar2
  ,p_per_information7             out nocopy        varchar2
  ,p_per_information8             out nocopy        varchar2
  ,p_per_information9             out nocopy        varchar2
  ,p_per_information10            out nocopy        varchar2
  ,p_per_information11            out nocopy        varchar2
  ,p_per_information12            out nocopy        varchar2
  ,p_per_information13            out nocopy        varchar2
  ,p_per_information14            out nocopy        varchar2
  ,p_per_information15            out nocopy        varchar2
  ,p_per_information16            out nocopy        varchar2
  ,p_per_information17            out nocopy        varchar2
  ,p_per_information18            out nocopy        varchar2
  ,p_per_information19            out nocopy        varchar2
  ,p_per_information20            out nocopy        varchar2
  ,p_per_information21            out nocopy        varchar2
  ,p_per_information22            out nocopy        varchar2
  ,p_per_information23            out nocopy        varchar2
  ,p_per_information24            out nocopy        varchar2
  ,p_per_information25            out nocopy        varchar2
  ,p_per_information26            out nocopy        varchar2
  ,p_per_information27            out nocopy        varchar2
  ,p_per_information28            out nocopy        varchar2
  ,p_per_information29            out nocopy        varchar2
  ,p_per_information30            out nocopy        varchar2
  ,p_uses_tobacco_flag            out nocopy        varchar2
  ,p_uses_tobacco_meaning         out nocopy        varchar2
  ,p_on_military_service          out nocopy        varchar2
  ,p_on_military_service_meaning  out nocopy        varchar2
  ,p_dpdnt_vlntry_svce_flag       out nocopy        varchar2
  ,p_dpdnt_vlntry_svce_meaning    out nocopy        varchar2
  ,p_correspondence_language      out nocopy        varchar2
  ,p_honors                       out nocopy        varchar2
  ,p_pre_name_adjunct             out nocopy        varchar2
  ,p_suffix                       out nocopy        varchar2
  ,p_create_mirror_flag           out nocopy        varchar2
  ,p_mirror_type                  out nocopy        varchar2
  ,p_mirror_cont_attribute_cat    out nocopy        varchar2
  ,p_mirror_cont_attribute1       out nocopy        varchar2
  ,p_mirror_cont_attribute2       out nocopy        varchar2
  ,p_mirror_cont_attribute3       out nocopy        varchar2
  ,p_mirror_cont_attribute4       out nocopy        varchar2
  ,p_mirror_cont_attribute5       out nocopy        varchar2
  ,p_mirror_cont_attribute6       out nocopy        varchar2
  ,p_mirror_cont_attribute7       out nocopy        varchar2
  ,p_mirror_cont_attribute8       out nocopy        varchar2
  ,p_mirror_cont_attribute9       out nocopy        varchar2
  ,p_mirror_cont_attribute10      out nocopy        varchar2
  ,p_mirror_cont_attribute11      out nocopy        varchar2
  ,p_mirror_cont_attribute12      out nocopy        varchar2
  ,p_mirror_cont_attribute13      out nocopy        varchar2
  ,p_mirror_cont_attribute14      out nocopy        varchar2
  ,p_mirror_cont_attribute15      out nocopy        varchar2
  ,p_mirror_cont_attribute16      out nocopy        varchar2
  ,p_mirror_cont_attribute17      out nocopy        varchar2
  ,p_mirror_cont_attribute18      out nocopy        varchar2
  ,p_mirror_cont_attribute19      out nocopy        varchar2
  ,p_mirror_cont_attribute20      out nocopy        varchar2
  ,p_action                       out nocopy        varchar2
  ,p_login_person_id              out nocopy        number
  ,p_process_section_name         out nocopy        varchar2
  ,p_review_page_region_code      out nocopy        varchar2
  -- Bug 1914891
  ,p_date_of_death                out nocopy        date
  ,p_dpdnt_adoption_date          out nocopy        date
  ,p_title_meaning                out nocopy        varchar2
  ,p_contact_type_meaning         out nocopy        varchar2
  ,p_contact_operation            out nocopy        varchar2
  ,p_emrg_cont_flag               out nocopy        varchar2
  ,p_dpdnt_bnf_flag               out nocopy        varchar2
  ,p_contact_relationship_id      out nocopy        number
  ,p_cont_object_version_number   out nocopy        number
    -- bug# 2315163
  ,p_is_emrg_cont                 out nocopy        varchar2
  ,p_is_dpdnt_bnf                 out nocopy        varchar2
  ,P_CONT_INFORMATION_CATEGORY    out nocopy        varchar2
  ,P_CONT_INFORMATION1            out nocopy        varchar2
  ,P_CONT_INFORMATION2            out nocopy        varchar2
  ,P_CONT_INFORMATION3            out nocopy        varchar2
  ,P_CONT_INFORMATION4            out nocopy        varchar2
  ,P_CONT_INFORMATION5            out nocopy        varchar2
  ,P_CONT_INFORMATION6            out nocopy        varchar2
  ,P_CONT_INFORMATION7            out nocopy        varchar2
  ,P_CONT_INFORMATION8            out nocopy        varchar2
  ,P_CONT_INFORMATION9            out nocopy        varchar2
  ,P_CONT_INFORMATION10           out nocopy        varchar2
  ,P_CONT_INFORMATION11           out nocopy        varchar2
  ,P_CONT_INFORMATION12           out nocopy        varchar2
  ,P_CONT_INFORMATION13           out nocopy        varchar2
  ,P_CONT_INFORMATION14           out nocopy        varchar2
  ,P_CONT_INFORMATION15           out nocopy        varchar2
  ,P_CONT_INFORMATION16           out nocopy        varchar2
  ,P_CONT_INFORMATION17           out nocopy        varchar2
  ,P_CONT_INFORMATION18           out nocopy        varchar2
  ,P_CONT_INFORMATION19           out nocopy        varchar2
  ,P_CONT_INFORMATION20           out nocopy        varchar2
  );
  /*
  ||===========================================================================
  || PROCEDURE: create_contact_tt
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_contact_rel_api.create_contact_tt()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pecrlapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

procedure create_contact_tt
  (p_validate                     in        number      default 0
  ,p_start_date                   in        date
  ,p_business_group_id            in        number
  ,p_person_id                    in        number
  ,p_contact_person_id            in        number      default null
  ,p_contact_type                 in        varchar2
  ,p_ctr_comments                 in        varchar2    default null
  ,p_primary_contact_flag         in        varchar2    default 'N'
  ,p_date_start                   in        date        default null
  ,p_start_life_reason_id         in        number      default null
  ,p_date_end                     in        date        default null
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
  ,p_mirror_cont_attribute_cat    in        varchar2    default null
  ,p_mirror_cont_attribute1       in        varchar2    default null
  ,p_mirror_cont_attribute2       in        varchar2    default null
  ,p_mirror_cont_attribute3       in        varchar2    default null
  ,p_mirror_cont_attribute4       in        varchar2    default null
  ,p_mirror_cont_attribute5       in        varchar2    default null
  ,p_mirror_cont_attribute6       in        varchar2    default null
  ,p_mirror_cont_attribute7       in        varchar2    default null
  ,p_mirror_cont_attribute8       in        varchar2    default null
  ,p_mirror_cont_attribute9       in        varchar2    default null
  ,p_mirror_cont_attribute10      in        varchar2    default null
  ,p_mirror_cont_attribute11      in        varchar2    default null
  ,p_mirror_cont_attribute12      in        varchar2    default null
  ,p_mirror_cont_attribute13      in        varchar2    default null
  ,p_mirror_cont_attribute14      in        varchar2    default null
  ,p_mirror_cont_attribute15      in        varchar2    default null
  ,p_mirror_cont_attribute16      in        varchar2    default null
  ,p_mirror_cont_attribute17      in        varchar2    default null
  ,p_mirror_cont_attribute18      in        varchar2    default null
  ,p_mirror_cont_attribute19      in        varchar2    default null
  ,p_mirror_cont_attribute20      in        varchar2    default null
  ,p_item_type                    in        varchar2
  ,p_item_key                     in        varchar2
  ,p_activity_id                  in        number
  ,p_action                       in        varchar2
  ,p_login_person_id              in        number
  ,p_process_section_name         in        varchar2
  ,p_review_page_region_code      in        varchar2 default null

  ,p_adjusted_svc_date            in      date     default null
  ,p_datetrack_update_mode        in      varchar2 default hr_api.g_correction --
  ,p_applicant_number             in      varchar2 default null
  ,p_background_check_status      in      varchar2 default null
  ,p_background_date_check        in      date     default null
  ,p_benefit_group_id             in      number   default null
  ,p_blood_type                   in      varchar2 default null
  ,p_coord_ben_med_pln_no         in      varchar2 default null
  ,p_coord_ben_no_cvg_flag        in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_date_employee_data_verified  in      date     default null
  ,p_date_of_death                in      date     default null
  ,p_dpdnt_adoption_date          in      date     default null
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default null
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default null
  ,p_fast_path_employee           in      varchar2 default null
  ,p_fte_capacity                 in      number   default null
  ,p_global_person_id             in      varchar2 default null
  ,p_hold_applicant_date_until    in      date     default null
  ,p_internal_location            in      varchar2 default null
  ,p_last_medical_test_by         in      varchar2 default null
  ,p_last_medical_test_date       in      date     default null
  ,p_mailstop                     in      varchar2 default null
  ,p_office_number                in      varchar2 default null
  ,p_on_military_service          in      varchar2 default null
  ,p_original_date_of_hire        in      date     default null
  ,p_projected_start_date         in      date     default null
  ,p_receipt_of_death_cert_date   in      date     default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_rehire_authorizor            in      varchar2 default null
  ,p_rehire_recommendation        in      varchar2 default null
  ,p_rehire_reason                in      varchar2 default null
  ,p_resume_exists                in      varchar2 default null
  ,p_resume_last_updated          in      date     default null
  ,p_second_passport_exists       in      varchar2 default null
  ,p_student_status               in      varchar2 default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_uses_tobacco_flag            in      varchar2 default null
  ,p_vendor_id                    in      number   default null
  ,p_work_schedule                in      varchar2 default null
  ,p_contact_operation            in      varchar2 default null
  ,p_emrg_cont_flag               in      varchar2 default 'N'
  ,p_dpdnt_bnf_flag               in      varchar2 default 'N'
  ,p_save_mode                    in      varchar2 default null
-- Added new parameters
  ,P_CONT_INFORMATION_CATEGORY 	  in      varchar2    default null
  ,P_CONT_INFORMATION1            in      varchar2    default null
  ,P_CONT_INFORMATION2            in      varchar2    default null
  ,P_CONT_INFORMATION3            in      varchar2    default null
  ,P_CONT_INFORMATION4            in      varchar2    default null
  ,P_CONT_INFORMATION5            in      varchar2    default null
  ,P_CONT_INFORMATION6            in      varchar2    default null
  ,P_CONT_INFORMATION7            in      varchar2    default null
  ,P_CONT_INFORMATION8            in      varchar2    default null
  ,P_CONT_INFORMATION9            in      varchar2    default null
  ,P_CONT_INFORMATION10           in      varchar2    default null
  ,P_CONT_INFORMATION11           in      varchar2    default null
  ,P_CONT_INFORMATION12           in      varchar2    default null
  ,P_CONT_INFORMATION13           in      varchar2    default null
  ,P_CONT_INFORMATION14           in      varchar2    default null
  ,P_CONT_INFORMATION15           in      varchar2    default null
  ,P_CONT_INFORMATION16           in      varchar2    default null
  ,P_CONT_INFORMATION17           in      varchar2    default null
  ,P_CONT_INFORMATION18           in      varchar2    default null
  ,P_CONT_INFORMATION19           in      varchar2    default null
  ,P_CONT_INFORMATION20           in      varchar2    default null
--bug 4634855
  ,P_MIRROR_CONT_INFORMATION_CAT  in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION1     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION2     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION3     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION4     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION5     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION6     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION7     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION8     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION9     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION10     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION11     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION12     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION13     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION14     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION15     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION16     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION17     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION18     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION19     in      varchar2    default null
  ,P_MIRROR_CONT_INFORMATION20     in      varchar2    default null

  ,p_contact_relationship_id      out nocopy number
  ,p_ctr_object_version_number    out nocopy number
  ,p_per_person_id                out nocopy number
  ,p_per_object_version_number    out nocopy number
  ,p_per_effective_start_date     out nocopy date
  ,p_per_effective_end_date       out nocopy date
  ,p_full_name                    out nocopy varchar2
  ,p_per_comment_id               out nocopy number
  ,p_con_name_combination_warning out nocopy varchar2
  ,p_per_name_combination_warning out nocopy varchar2
  ,p_con_orig_hire_warning            out nocopy varchar2
  ,p_per_orig_hire_warning            out nocopy varchar2
  ,p_per_assign_payroll_warning       out nocopy varchar2
  ,p_ni_duplicate_warn_or_err   out nocopy varchar2
 ) ;

Function is_con_rec_changed (
  p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in      number   default hr_api.g_number
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2  )
  return boolean ;
--
-- ---------------------------------------------------------------------------
-- ----------------------------- < process_create_contact_api> -----------------------------
-- ---------------------------------------------------------------------------
--          This procedure will call the api to create
--          to the database with p_validate equal to false.
--          For contacts there is no approver process attached.
--
-- ---------------------------------------------------------------------------
PROCEDURE process_create_contact_api
          (p_validate IN BOOLEAN DEFAULT FALSE
          ,p_transaction_step_id IN NUMBER
          ,p_effective_date      in varchar2 default null
);

--
-- ---------------------------------------------------------------------------
-- ----------------------------- < process_api > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
--          For contacts there is no approver process attached.
--
-- ---------------------------------------------------------------------------
PROCEDURE process_api
          (p_validate IN BOOLEAN DEFAULT FALSE
          ,p_transaction_step_id IN NUMBER
          ,p_effective_date      in varchar2 default null
);

  /*
  ||===========================================================================
  || PROCEDURE: end_contact_relationship
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_contact_rel_api.update_contact_relationship()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see peaddapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

PROCEDURE end_contact_relationship
  (p_validate                      in        number  default 0
  ,p_effective_date                in        date
  ,p_contact_relationship_id       in        number
  ,p_contact_type                  in        varchar2  default hr_api.g_varchar2
  ,p_comments                      in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag          in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag          in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag               in        varchar2  default hr_api.g_varchar2
  ,p_date_start                    in        date      default hr_api.g_date
  ,p_start_life_reason_id          in        number    default hr_api.g_number
  ,p_date_end                      in        date      default hr_api.g_date
  ,p_end_life_reason_id            in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag   in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                 in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number               in        number    default hr_api.g_number
  ,p_dependent_flag                in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category       in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9               in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19              in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20              in        varchar2  default hr_api.g_varchar2
  ,p_person_id                     in        number -- this could be p_login_person_id
  ,p_object_version_number         in out nocopy    number
  ,p_item_type                     in        varchar2
  ,p_item_key                      in        varchar2
  ,p_activity_id                   in        number
  ,p_action                        in        varchar2 -- this is p_action_type
  ,p_process_section_name          in        varchar2
  ,p_review_page_region_code       in        varchar2 default hr_api.g_varchar2
  ,p_save_mode                     in        varchar2  default null
 -- SFL needs it bug #2082333
  ,p_login_person_id               in        number
  ,p_contact_person_id             in        number
  -- Bug 2723267 change
  ,p_contact_operation             in        varchar2
  -- Bug 3152505
  ,p_end_other_rel                 in        varchar2
  ,p_other_rel_id                  in        number
 );
--
-- ---------------------------------------------------------------------------
-- ----------------------------- < process_end_api > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
--          For contacts there is no approver process attached.
--
-- ---------------------------------------------------------------------------
PROCEDURE process_end_api
          (p_validate IN BOOLEAN DEFAULT FALSE
          ,p_transaction_step_id IN NUMBER
          ,p_effective_date      in varchar2 default null
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< is_contact_added>------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will be called from contacts subprocess, which will
-- determine  if the control sholud go to the contacts page again or to the
-- conatcs decision page.
--          Case1 : If no contacts were added in this session Then Goto Decision page
--                                                   ( may be from contacts - back button
--          Case2 : If there are some contacts added,Then Goto Contacts page to show last contact added
--                                                    ( coming from back button)
--
-- Parameters:
--   Input
--   p_item_type - required. It is the item type for the workflow process.
--   p_item_key  - required.  It is the item key for the workflow process.
--   p_actid  - required. It is the item key for the workflow process.
--   not yet--  p_contact_set - required. It is the Last contact set added in to trx.

--  Output Parameters:
--   1) p_resultout - will populate the result code for the activity
-- Purpose: This procedure will read the HR_RUNTIME_APPROVAL_REQ_FLAG item level
-- attribute value and branch accordingly. This value will be set by the review
-- page by reading its attribute level attribute HR_APPROVAL_REQ_FLAG
-- ----------------------------------------------------------------------------
PROCEDURE is_contact_added
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2  -- i need to remove this
  ,resultout   out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_transaction_steps>------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: These procedures will be called from contacts subprocess, which will
--          remove the steps thst have been saved and are to be removed as the
--          user went back to the contacts page and this data is displayed on
--          the page and will be saved  later.
--
PROCEDURE delete_transaction_steps(
  p_item_type IN     varchar2,
  p_item_key  IN     varchar2,
  p_actid     IN     varchar2,
  p_login_person_id  IN varchar2);
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_transaction_steps  Overloaded>------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: These procedures will be called from contacts subprocess, which will
--          remove the steps thst have been saved and are to be removed as the
--          user went back to the contacts page and this data is displayed on
--          the page and will be saved  later.
--
PROCEDURE delete_transaction_steps(
  p_item_type IN     varchar2,
  p_item_key  IN     varchar2,
  p_actid     IN     varchar2,
  p_login_person_id  IN varchar2,
  p_mode IN varchar2);
---
/*
procedure save_for_later_validation
  (p_item_type in varchar2
  ,p_item_key  in varchar2
  ,p_return    out nocopy varchar2);
--
*/
procedure update_object_version
  (p_transaction_step_id in     number
  ,p_login_person_id in number);

-- Bug # 2263008: checks if duplicate SSN is entered.
procedure check_ni_unique
(p_national_identifier in  varchar2 default null
,p_business_group_id            in        number
,p_person_id                    in        number
,p_ni_duplicate_warn_or_err out nocopy varchar2);
--
-- Bug 3152505 :a new procedure to make a validation call to create_contact_api.
procedure call_contact_api
  (p_validate                     in        boolean     default false
  ,p_start_date                   in        date
  ,p_business_group_id            in        number
  ,p_person_id                    in        number
  ,p_contact_person_id            in        number      default null
  ,p_contact_type                 in        varchar2
  ,p_ctr_comments                 in        varchar2    default null
  ,p_primary_contact_flag         in        varchar2    default 'N'
  ,p_date_start                   in        date        default null
  ,p_start_life_reason_id         in        number      default null
  ,p_date_end                     in        date        default null
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
  ,p_cont_information_category      in        varchar2    default null
  ,p_cont_information1              in        varchar2    default null
  ,p_cont_information2              in        varchar2    default null
  ,p_cont_information3              in        varchar2    default null
  ,p_cont_information4              in        varchar2    default null
  ,p_cont_information5              in        varchar2    default null
  ,p_cont_information6              in        varchar2    default null
  ,p_cont_information7              in        varchar2    default null
  ,p_cont_information8              in        varchar2    default null
  ,p_cont_information9              in        varchar2    default null
  ,p_cont_information10             in        varchar2    default null
  ,p_cont_information11             in        varchar2    default null
  ,p_cont_information12             in        varchar2    default null
  ,p_cont_information13             in        varchar2    default null
  ,p_cont_information14             in        varchar2    default null
  ,p_cont_information15             in        varchar2    default null
  ,p_cont_information16             in        varchar2    default null
  ,p_cont_information17             in        varchar2    default null
  ,p_cont_information18             in        varchar2    default null
  ,p_cont_information19             in        varchar2    default null
  ,p_cont_information20             in        varchar2    default null
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
  ,p_mirror_cont_attribute_cat    in        varchar2    default null
  ,p_mirror_cont_attribute1       in        varchar2    default null
  ,p_mirror_cont_attribute2       in        varchar2    default null
  ,p_mirror_cont_attribute3       in        varchar2    default null
  ,p_mirror_cont_attribute4       in        varchar2    default null
  ,p_mirror_cont_attribute5       in        varchar2    default null
  ,p_mirror_cont_attribute6       in        varchar2    default null
  ,p_mirror_cont_attribute7       in        varchar2    default null
  ,p_mirror_cont_attribute8       in        varchar2    default null
  ,p_mirror_cont_attribute9       in        varchar2    default null
  ,p_mirror_cont_attribute10      in        varchar2    default null
  ,p_mirror_cont_attribute11      in        varchar2    default null
  ,p_mirror_cont_attribute12      in        varchar2    default null
  ,p_mirror_cont_attribute13      in        varchar2    default null
  ,p_mirror_cont_attribute14      in        varchar2    default null
  ,p_mirror_cont_attribute15      in        varchar2    default null
  ,p_mirror_cont_attribute16      in        varchar2    default null
  ,p_mirror_cont_attribute17      in        varchar2    default null
  ,p_mirror_cont_attribute18      in        varchar2    default null
  ,p_mirror_cont_attribute19      in        varchar2    default null
  ,p_mirror_cont_attribute20      in        varchar2    default null
  ,p_mirror_cont_information_cat    in        varchar2    default null
  ,p_mirror_cont_information1       in        varchar2    default null
  ,p_mirror_cont_information2       in        varchar2    default null
  ,p_mirror_cont_information3       in        varchar2    default null
  ,p_mirror_cont_information4       in        varchar2    default null
  ,p_mirror_cont_information5       in        varchar2    default null
  ,p_mirror_cont_information6       in        varchar2    default null
  ,p_mirror_cont_information7       in        varchar2    default null
  ,p_mirror_cont_information8       in        varchar2    default null
  ,p_mirror_cont_information9       in        varchar2    default null
  ,p_mirror_cont_information10      in        varchar2    default null
  ,p_mirror_cont_information11      in        varchar2    default null
  ,p_mirror_cont_information12      in        varchar2    default null
  ,p_mirror_cont_information13      in        varchar2    default null
  ,p_mirror_cont_information14      in        varchar2    default null
  ,p_mirror_cont_information15      in        varchar2    default null
  ,p_mirror_cont_information16      in        varchar2    default null
  ,p_mirror_cont_information17      in        varchar2    default null
  ,p_mirror_cont_information18      in        varchar2    default null
  ,p_mirror_cont_information19      in        varchar2    default null
  ,p_mirror_cont_information20      in        varchar2    default null
--
  ,p_contact_relationship_id      out nocopy number
  ,p_ctr_object_version_number    out nocopy number
  ,p_per_person_id                out nocopy number
  ,p_per_object_version_number    out nocopy number
  ,p_per_effective_start_date     out nocopy date
  ,p_per_effective_end_date       out nocopy date
  ,p_full_name                    out nocopy varchar2
  ,p_per_comment_id               out nocopy number
  ,p_name_combination_warning     out nocopy boolean
  ,p_orig_hire_warning            out nocopy boolean
--
  ,p_contact_operation               in        varchar2
  ,p_emrg_cont_flag                  in      varchar2 default 'N'
  );
--
procedure get_emrg_rel_id (
   P_contact_relationship_id          in number
  ,p_contact_person_id                in number
  ,p_emrg_rel_id                      out nocopy varchar2
  ,p_no_of_non_emrg_rel               out nocopy varchar2
  ,p_other_rel_type                   out nocopy varchar2
  ,p_emrg_rel_type                    out nocopy varchar2)
;
--
procedure validate_rel_start_date (
   p_person_id                        in number
  ,p_item_key                         in varchar2
  ,p_save_mode                        in varchar2
  ,p_date_start                       in out nocopy date
  ,p_date_of_birth                    in date)
;
--
/* This function checks if teh primary contact field has changed.And if the
   Primary Contact field has changed, it validates it.
*/
Procedure validate_primary_cont_flag(
   p_contact_relationship_id          in number
  ,p_primary_contact_flag             in varchar2
  ,p_date_start                       in date
  ,p_contact_person_id                in number
  ,p_object_version_number             in out nocopy    number)
;

END hr_process_contact_ss;


/
