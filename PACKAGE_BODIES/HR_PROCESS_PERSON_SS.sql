--------------------------------------------------------
--  DDL for Package Body HR_PROCESS_PERSON_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROCESS_PERSON_SS" AS
/* $Header: hrperwrs.pkb 120.11.12010000.21 2010/04/20 11:33:22 gpurohit ship $*/

-- Global variables
  g_package               constant varchar2(75):='HR_PROCESS_PERSON_SS.';
  g_wf_review_regn_itm_attr_name  constant varchar2(2000)
                                  := 'HR_REVIEW_REGION_ITEM';

  g_data_error                   exception;
  --g_no_changes                   exception;
  g_date_prior_to_cur_start_date exception;
  g_validate_basic_details_error exception;
  g_applicant_hire boolean := false;

  g_debug boolean := hr_utility.debug_enabled;

  --global cursor for getting system_person_type
  CURSOR gc_get_sys_person_type (p_person_type_id in number) IS
  SELECT ppt.system_person_type
    FROM per_person_types ppt
   WHERE ppt.person_type_id = p_person_type_id;


-- Global cursor
  CURSOR gc_get_cur_person_data
         (p_person_id      in number
         ,p_eff_date       in date default trunc(sysdate))
  IS
  SELECT   per.effective_start_date
          ,per.effective_end_date
          ,per.object_version_number
          ,per.person_type_id
          ,per.employee_number
          ,per.npw_number
          ,per.last_name
          ,per.applicant_number
          ,per.date_employee_data_verified
          ,per.original_date_of_hire
          ,per.date_of_birth
          ,per.town_of_birth
          ,per.region_of_birth
          ,per.country_of_birth
          ,per.global_person_id
          ,per.email_address
          ,per.expense_check_send_to_address
          ,per.first_name
          ,per.known_as
          ,per.marital_status
          ,per.middle_names
          ,per.nationality
          ,per.national_identifier
          ,per.previous_last_name
          ,per.registered_disabled_flag
          ,per.sex
          ,per.title
          ,per.vendor_id
          ,per.work_telephone
          ,per.suffix
          ,per.attribute_category
          ,per.attribute1
          ,per.attribute2
          ,per.attribute3
          ,per.attribute4
          ,per.attribute5
          ,per.attribute6
          ,per.attribute7
          ,per.attribute8
          ,per.attribute9
          ,per.attribute10
          ,per.attribute11
          ,per.attribute12
          ,per.attribute13
          ,per.attribute14
          ,per.attribute15
          ,per.attribute16
          ,per.attribute17
          ,per.attribute18
          ,per.attribute19
          ,per.attribute20
          ,per.attribute21
          ,per.attribute22
          ,per.attribute23
          ,per.attribute24
          ,per.attribute25
          ,per.attribute26
          ,per.attribute27
          ,per.attribute28
          ,per.attribute29
          ,per.attribute30
          ,per.per_information_category
          ,per.per_information1
          ,per.per_information2
          ,per.per_information3
          ,per.per_information4
          ,per.per_information5
          ,per.per_information6
          ,per.per_information7
          ,per.per_information8
          ,per.per_information9
          ,per.per_information10
          ,per.per_information11
          ,per.per_information12
          ,per.per_information13
          ,per.per_information14
          ,per.per_information15
          ,per.per_information16
          ,per.per_information17
          ,per.per_information18
          ,per.per_information19
          ,per.per_information20
          ,per.per_information21
          ,per.per_information22
          ,per.per_information23
          ,per.per_information24
          ,per.per_information25
          ,per.per_information26
          ,per.per_information27
          ,per.per_information28
          ,per.per_information29
          ,per.per_information30
          ,per.date_of_death
          ,per.background_check_status
          ,per.background_date_check
          ,per.blood_type
          ,per.correspondence_language
          ,per.fast_path_employee
          ,per.fte_capacity
          ,per.hold_applicant_date_until
          ,per.honors
          ,per.internal_location
          ,per.last_medical_test_by
          ,per.last_medical_test_date
          ,per.mailstop
          ,per.office_number
          ,per.on_military_service
          ,per.pre_name_adjunct
          ,per.projected_start_date
          ,per.rehire_authorizor
          ,per.rehire_recommendation
          ,per.resume_exists
          ,per.resume_last_updated
          ,per.second_passport_exists
          ,per.student_status
          ,per.work_schedule
          ,per.rehire_reason
          ,per.benefit_group_id
          ,per.receipt_of_death_cert_date
          ,per.coord_ben_med_pln_no
          ,per.coord_ben_no_cvg_flag
          ,per.uses_tobacco_flag
          ,per.dpdnt_adoption_date
          ,per.dpdnt_vlntry_svce_flag
          ,per.comment_id
          ,hc.comment_text
          ,pos.adjusted_svc_date
  FROM     per_all_people_f   per
          ,hr_comments        hc
          ,per_periods_of_service pos
  WHERE  per.person_id = p_person_id
  AND    p_eff_date BETWEEN per.effective_start_date and per.effective_end_date
  AND    hc.comment_id (+) = per.comment_id
-- bug 2747159 : Making an outer join to the per_periods_of_service table.
  AND    per.person_id = pos.person_id(+)
  and    per.effective_start_date between pos.date_start(+)
  and nvl(pos.actual_termination_date(+),per.effective_start_date);
-- bug #2679759 :getting the value of
-- adj svc date from per_periods_of_service

--
  CURSOR gc_get_current_applicant_flag
         (p_person_id      in number
         ,p_eff_date       in date default trunc(sysdate))
  IS
  SELECT   per.current_applicant_flag,
           per.current_employee_flag,
           per.current_npw_flag
  FROM     per_all_people_f   per
  WHERE  per.person_id = p_person_id
  AND    p_eff_date BETWEEN per.effective_start_date and per.effective_end_date;

--
  CURSOR gc_get_new_appl_person_type
         (p_person_id    in number
         ,p_effective_date  in date)
  IS

  SELECT ptu.person_type_id
  FROM   per_person_type_usages_f ptu,
         per_person_types ppt
  WHERE  ptu.person_id = p_person_id
  AND    p_effective_date between ptu.effective_start_date
         and ptu.effective_end_date
  AND    ptu.person_type_id = ppt.person_type_id
  AND    ppt.system_person_type = 'APL'
  AND    ppt.active_flag = 'Y';

--
-- ------------------------------------------------------------------------
-- -------------------------<get_hr_lookup_meaning>------------------------
-- ------------------------------------------------------------------------
-- Purpose: This procedure retrieves the lookup meaning from hr_lookups for the
--          lookup_type and lookup_code passed in.
-- ------------------------------------------------------------------------
Function get_hr_lookup_meaning(p_lookup_type in varchar2
                           ,p_lookup_code in varchar2)
return varchar2 is
  --
  CURSOR csr_hr_lookup is
  SELECT meaning
  FROM   hr_lookups
  WHERE  lookup_type = upper(p_lookup_type)
  AND    lookup_code = upper(p_lookup_code);
  --
  l_meaning           varchar2(80) default null;
  l_proc   varchar2(72)  := g_package||'get_hr_lookup_meaning';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Entering For Loop:'||l_proc,10);
  FOR csr1 in csr_hr_lookup LOOP
      l_meaning := csr1.meaning;
  END LOOP;
  hr_utility.set_location('Exiting For Loop:'||l_proc,15);

  hr_utility.set_location('Exiting:'||l_proc,20);
  --
  return l_meaning;
  --
  Exception
    When others THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
      raise;
    --
END get_hr_lookup_meaning;

--
-- ------------------------------------------------------------------------
-- -------------------------<get_max_effective_date>------------------------
-- ------------------------------------------------------------------------
-- Purpose: This procedure retrieves the max effective start date from
-- per_all_people_f for the person_id passed in.
-- ------------------------------------------------------------------------
Function get_max_effective_date(p_person_id in number)
return Date is
  --
  l_effective_date           Date default null;
  l_proc   varchar2(72)  := g_package||'get_max_effective_date';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  select max(EFFECTIVE_START_DATE) into l_effective_date
                     from per_all_people_f where person_id = p_person_id;
  hr_utility.set_location('Exiting:'||l_proc,10);
  --
  return l_effective_date;
  --
  Exception
    When others THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
      raise;
    --
END get_max_effective_date;

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
--StartRegistration.
   ,p_adjusted_svc_date               out nocopy date
   ,p_date_start                      out nocopy date
--EndRegistration.
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
)is

  l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
  l_api_names            hr_util_web.g_varchar2_tab_type;
  l_trans_step_rows                  NUMBER  ;

  l_transaction_rec_count      integer default 0;
  l_proc   varchar2(72)  := g_package||'get_person_data_from_tt';

begin

  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_transaction_api.get_transaction_step_info
     (p_item_type              => p_item_type
     ,p_item_key               => p_item_key
     ,p_activity_id            => p_activity_id
     ,p_transaction_step_id    => l_trans_step_ids
     ,p_api_name               => l_api_names
     ,p_rows                   => l_trans_step_rows);


  IF l_trans_step_rows IS NOT NULL OR
     l_trans_step_rows > 0
  THEN
     hr_utility.set_location('IF step_rows!=NULL OR step_rows > 0:'||l_proc,10);
     l_transaction_rec_count := l_trans_step_rows;
  ELSE
     hr_utility.set_location('IF step_rows=NULL AND step_rows <= 0:'||l_proc,15);
     l_transaction_rec_count := 0;
     hr_utility.set_location('Exiting: in the  else part'||l_proc, 15);
     return;
  END IF;
  --
  -- -------------------------------------------------------------------
  -- There are some changes made earlier in the transaction.
  -- Retrieve the data and return to caller.
  -- -------------------------------------------------------------------
  --
  -- Now get the transaction data for the given step
 -- Need to loop through l_trans_rec_count -1 as the index starts from 0

  hr_utility.set_location('Entering 0..l_transaction_rec_count-1:'||l_proc,20);
  FOR i in 0..l_transaction_rec_count-1 LOOP
   IF(l_api_names(i) = 'HR_PROCESS_PERSON_SS.PROCESS_API') THEN
    get_person_data_from_tt(
    p_transaction_step_id            => l_trans_step_ids(i)
   ,p_effective_date                 => p_effective_date
   ,p_attribute_update_mode          => p_attribute_update_mode
   ,p_person_id                      => p_person_id
   ,p_object_version_number          => p_object_version_number
   ,p_person_type_id                 => p_person_type_id
   ,p_last_name                      => p_last_name
   ,p_applicant_number               => p_applicant_number
   ,p_comments                       => p_comments
   ,p_date_employee_data_verified    => p_date_employee_data_verified
   ,p_original_date_of_hire          => p_original_date_of_hire
   ,p_date_of_birth                  => p_date_of_birth
   ,p_town_of_birth                  => p_town_of_birth
   ,p_region_of_birth                => p_region_of_birth
   ,p_country_of_birth               => p_country_of_birth
   ,p_global_person_id               => p_global_person_id
   ,p_email_address                  => p_email_address
   ,p_employee_number                => p_employee_number
   ,p_npw_number                     => p_npw_number
   ,p_expense_check_send_to_addres   => p_expense_check_send_to_addres
   ,p_first_name                     => p_first_name
   ,p_known_as                       => p_known_as
   ,p_marital_status                 => p_marital_status
   ,p_middle_names                   => p_middle_names
   ,p_nationality                    => p_nationality
   ,p_national_identifier            => p_national_identifier
   ,p_previous_last_name             => p_previous_last_name
   ,p_registered_disabled_flag       => p_registered_disabled_flag
   ,p_sex                            => p_sex
   ,p_title                          => p_title
   ,p_vendor_id                      => p_vendor_id
   ,p_work_telephone                 => p_work_telephone
   ,p_suffix                         => p_suffix
   ,p_attribute_category             => p_attribute_category
   ,p_date_of_death                  => p_date_of_death
   ,p_background_check_status        => p_background_check_status
   ,p_background_date_check          => p_background_date_check
   ,p_blood_type                     => p_blood_type
   ,p_correspondence_language        => p_correspondence_language
   ,p_fast_path_employee             => p_fast_path_employee
   ,p_fte_capacity                   => p_fte_capacity
   ,p_hold_applicant_date_until      => p_hold_applicant_date_until
   ,p_honors                         => p_honors
   ,p_internal_location              => p_internal_location
   ,p_last_medical_test_by           => p_last_medical_test_by
   ,p_last_medical_test_date         => p_last_medical_test_date
   ,p_mailstop                       => p_mailstop
   ,p_office_number                  => p_office_number
   ,p_on_military_service            => p_on_military_service
   ,p_pre_name_adjunct               => p_pre_name_adjunct
   ,p_projected_start_date           => p_projected_start_date
   ,p_rehire_authorizor              => p_rehire_authorizor
   ,p_rehire_recommendation          => p_rehire_recommendation
   ,p_resume_exists                  => p_resume_exists
   ,p_resume_last_updated            => p_resume_last_updated
   ,p_second_passport_exists         => p_second_passport_exists
   ,p_student_status                 => p_student_status
   ,p_work_schedule                  => p_work_schedule
   ,p_rehire_reason                  => p_rehire_reason
   ,p_benefit_group_id               => p_benefit_group_id
   ,p_receipt_of_death_cert_date     => p_receipt_of_death_cert_date
   ,p_coord_ben_med_pln_no           => p_coord_ben_med_pln_no
   ,p_coord_ben_no_cvg_flag          => p_coord_ben_no_cvg_flag
   ,p_uses_tobacco_flag              => p_uses_tobacco_flag
   ,p_dpdnt_adoption_date            => p_dpdnt_adoption_date
   ,p_dpdnt_vlntry_svce_flag         => p_dpdnt_vlntry_svce_flag
-- StartRegistration.
   ,p_adjusted_svc_date              => p_adjusted_svc_date
   ,p_date_start                     => p_date_start
-- EndRegistration.
   ,p_attribute1                     => p_attribute1
   ,p_attribute2                     => p_attribute2
   ,p_attribute3                     => p_attribute3
   ,p_attribute4                     => p_attribute4
   ,p_attribute5                     => p_attribute5
   ,p_attribute6                     => p_attribute6
   ,p_attribute7                     => p_attribute7
   ,p_attribute8                     => p_attribute8
   ,p_attribute9                     => p_attribute9
   ,p_attribute10                    => p_attribute10
   ,p_attribute11                    => p_attribute11
   ,p_attribute12                    => p_attribute12
   ,p_attribute13                    => p_attribute13
   ,p_attribute14                    => p_attribute14
   ,p_attribute15                    => p_attribute15
   ,p_attribute16                    => p_attribute16
   ,p_attribute17                    => p_attribute17
   ,p_attribute18                    => p_attribute18
   ,p_attribute19                    => p_attribute19
   ,p_attribute20                    => p_attribute20
   ,p_attribute21                    => p_attribute21
   ,p_attribute22                    => p_attribute22
   ,p_attribute23                    => p_attribute23
   ,p_attribute24                    => p_attribute24
   ,p_attribute25                    => p_attribute25
   ,p_attribute26                    => p_attribute26
   ,p_attribute27                    => p_attribute27
   ,p_attribute28                    => p_attribute28
   ,p_attribute29                    => p_attribute29
   ,p_attribute30                    => p_attribute30
   ,p_per_information_category       => p_per_information_category
   ,p_per_information1               => p_per_information1
   ,p_per_information2               => p_per_information2
   ,p_per_information3               => p_per_information3
   ,p_per_information4               => p_per_information4
   ,p_per_information5               => p_per_information5
   ,p_per_information6               => p_per_information6
   ,p_per_information7               => p_per_information7
   ,p_per_information8               => p_per_information8
   ,p_per_information9               => p_per_information9
   ,p_per_information10              => p_per_information10
   ,p_per_information11              => p_per_information11
   ,p_per_information12              => p_per_information12
   ,p_per_information13              => p_per_information13
   ,p_per_information14              => p_per_information14
   ,p_per_information15              => p_per_information15
   ,p_per_information16              => p_per_information16
   ,p_per_information17              => p_per_information17
   ,p_per_information18              => p_per_information18
   ,p_per_information19              => p_per_information19
   ,p_per_information20              => p_per_information20
   ,p_per_information21              => p_per_information21
   ,p_per_information22              => p_per_information22
   ,p_per_information23              => p_per_information23
   ,p_per_information24              => p_per_information24
   ,p_per_information25              => p_per_information25
   ,p_per_information26              => p_per_information26
   ,p_per_information27              => p_per_information27
   ,p_per_information28              => p_per_information28
   ,p_per_information29              => p_per_information29
   ,p_per_information30              => p_per_information30
   ,p_title_meaning                  => p_title_meaning
   ,p_marital_status_meaning         => p_marital_status_meaning
   ,p_full_name                      => p_full_name
   ,p_business_group_id              => p_business_group_id
   ,p_review_proc_call               => p_review_proc_call
   ,p_action_type                    => p_action_type
   );
  END IF;
 END LOOP;
 hr_utility.set_location('Exiting For Loop:'||l_proc,30);

 p_trans_rec_count := l_transaction_rec_count;
 hr_utility.set_location('Exiting:'||l_proc,35);

EXCEPTION
   WHEN g_data_error THEN
   hr_utility.set_location('Exception:g_data_error'||l_proc,555);
      RAISE;

END get_person_data_from_tt;
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
)is

   l_title                            per_all_people_f.title%type default null;
   l_marital_status                   per_all_people_f.marital_status%type
                                      default null;
   l_title_meaning                    hr_lookups.meaning%type default null;
   l_marital_status_meaning           hr_lookups.meaning%type default null;
   l_proc   varchar2(72)  := g_package||'get_person_data_from_tt';

BEGIN
--
   hr_utility.set_location('Entering:'||l_proc, 5);
   p_effective_date:= to_date(
      hr_transaction_ss.get_wf_effective_date
        (p_transaction_step_id => p_transaction_step_id),g_date_format);
--
  hr_utility.set_location('Start Calling hr_transaction_api methods:'||l_proc,10);
  p_attribute_update_mode :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE_UPDATE_MODE');
--
  p_person_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ID');
--
  p_object_version_number :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER');
--
  p_person_type_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_TYPE_ID');
--
  p_last_name :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LAST_NAME');
--
  p_applicant_number :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_APPLICANT_NUMBER');
--
  p_comments :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_COMMENTS');
--
  p_date_employee_data_verified :=
    hr_transaction_api.get_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_DATE_EMPLOYEE_DATA_VERIFIED');
--
  p_original_date_of_hire :=
    hr_transaction_api.get_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_ORIGINAL_DATE_OF_HIRE');
--
  p_date_of_birth :=
    hr_transaction_api.get_date_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_DATE_OF_BIRTH');
--
  p_town_of_birth :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TOWN_OF_BIRTH');
--
  p_region_of_birth :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REGION_OF_BIRTH');
--
  p_country_of_birth :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_COUNTRY_OF_BIRTH');
--
  p_global_person_id :=
    hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_GLOBAL_PERSON_ID');
--
  p_email_address :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EMAIL_ADDRESS');
--
  p_employee_number :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EMPLOYEE_NUMBER');
--
  p_npw_number :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NPW_NUMBER');
--
  p_expense_check_send_to_addres :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EXPENSE_CHECK_SEND_TO_ADDRES');
--
  p_first_name :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FIRST_NAME');
--
  p_known_as :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_KNOWN_AS');
--
  l_marital_status :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MARITAL_STATUS');
--
  p_middle_names :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MIDDLE_NAMES');
--
  p_nationality :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NATIONALITY');
--
  p_national_identifier :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NATIONAL_IDENTIFIER');
--
  p_previous_last_name :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PREVIOUS_LAST_NAME');
--
  p_registered_disabled_flag :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REGISTERED_DISABLED_FLAG');
--
  p_sex :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SEX');
--
  l_title :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TITLE');
--
  p_vendor_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_VENDOR_ID');
--
  p_work_telephone :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_WORK_TELEPHONE');
--
  p_suffix :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SUFFIX');
--
  p_date_of_death :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATE_OF_DEATH');
--
  p_background_check_status :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BACKGROUND_CHECK_STATUS');
--
  p_background_date_check :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BACKGROUND_DATE_CHECK');
--
  p_blood_type :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BLOOD_TYPE');
--
  p_correspondence_language :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CORRESPONDENCE_LANGUAGE');
--
  p_fast_path_employee :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FAST_PATH_EMPLOYEE');
--
  p_fte_capacity :=
    hr_transaction_api.get_number_value
       (p_transaction_step_id => p_transaction_step_id
       ,p_name                => 'P_FTE_CAPACITY');
--
  p_hold_applicant_date_until :=
      hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_HOLD_APPLICANT_DATE_UNTIL');
--
  p_honors :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_HONORS');
--
  p_internal_location :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_INTERNAL_LOCATION');
--
  p_last_medical_test_by :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LAST_MEDICAL_TEST_BY');
--
  p_last_medical_test_date :=
       hr_transaction_api.get_date_value
           (p_transaction_step_id => p_transaction_step_id
           ,p_name                => 'P_LAST_MEDICAL_TEST_DATE');
--
  p_mailstop :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MAILSTOP');
--
  p_office_number :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OFFICE_NUMBER');
--
  p_on_military_service :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ON_MILITARY_SERVICE');
--
  p_pre_name_adjunct :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PRE_NAME_ADJUNCT');
--
  p_projected_start_date :=
      hr_transaction_api.get_date_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_PROJECTED_START_DATE');
--
  p_rehire_authorizor :=
     hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REHIRE_AUTHORIZOR');
--
  p_rehire_recommendation :=
     hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REHIRE_RECOMMENDATION');
--
  p_resume_exists :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_RESUME_EXISTS');
--
  p_resume_last_updated :=
    hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_RESUME_LAST_UPDATED');
--
  p_second_passport_exists :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_SECOND_PASSPORT_EXISTS');
--
  p_student_status :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_STUDENT_STATUS');
--
  p_work_schedule :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_WORK_SCHEDULE');
--
  p_rehire_reason :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_REHIRE_REASON');
--
  p_benefit_group_id :=
     hr_transaction_api.get_number_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_BENEFIT_GROUP_ID');
--
  p_receipt_of_death_cert_date :=
     hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_RECEIPT_OF_DEATH_CERT_DATE');
--
  p_coord_ben_med_pln_no :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_COORD_BEN_MED_PLN_NO');
--
  p_coord_ben_no_cvg_flag :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_COORD_BEN_NO_CVG_FLAG');
--
  p_uses_tobacco_flag :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_USES_TOBACCO_FLAG');
--
  p_dpdnt_adoption_date :=
     hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_DPDNT_ADOPTION_DATE');
--
  p_dpdnt_vlntry_svce_flag :=
      hr_transaction_api.get_varchar2_value
      (p_transaction_step_id => p_transaction_step_id
      ,p_name                => 'P_DPDNT_VLNTRY_SVCE_FLAG');
--

  --
  -- StartRegistration.
  --
  begin
     --
     p_adjusted_svc_date :=
        hr_transaction_api.get_date_value
         (p_transaction_step_id => p_transaction_step_id
         ,p_name                => 'P_ADJUSTED_SVC_DATE');
     --
     p_date_start:= to_date(
       hr_transaction_ss.get_wf_effective_date
        (p_transaction_step_id => p_transaction_step_id),g_date_format);
     --
  exception
     when others then
        hr_utility.set_location('Exception:Others'||l_proc,555);
        P_ADJUSTED_SVC_DATE := null;
        P_DATE_START        := null;
  end;

-- EndRegistration.
--
  p_attribute_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE_CATEGORY');
--
  p_attribute1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE1');
--
  p_attribute2 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE2');
--
  p_attribute3 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE3');
--
  p_attribute4 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE4');
--
  p_attribute5 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE5');
--
  P_ATTRIBUTE6 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE6');
--
  p_attribute7 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE7');
--
  p_attribute8 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE8');
--
  p_attribute9 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE9');
--
  p_attribute10 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE10');
--
  p_attribute11 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE11');
--
  p_attribute12 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE12');
--
  p_attribute13 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE13');
--
  p_attribute14 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE14');
--
  p_attribute15 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE15');
--
  p_attribute16 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE16');
--
  p_attribute17 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE17');
--
  p_attribute18 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE18');
--
  p_attribute19 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE19');
--
  p_attribute20 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE20');
--
  p_attribute21 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE21');
--
  p_attribute22 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE22');
--
  p_attribute23 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE23');
--
  p_attribute24 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE24');
--
  p_attribute25 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE25');
--
  p_attribute26 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE26');
--
  p_attribute27 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE27');
--
  p_attribute28 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE28');
--
  p_attribute29 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE29');
--
  p_attribute30 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ATTRIBUTE30');
--
  p_per_information_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION_CATEGORY');
--
  p_per_information1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION1');
--
  p_per_information2 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION2');
--
  p_per_information3 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION3');
--
  p_per_information4 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION4');
--
  p_per_information5 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION5');
--
  p_per_information6 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION6');
--
  p_per_information7 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION7');
--
  p_per_information8 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION8');
--
  p_per_information9 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION9');
--
  p_per_information10 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION10');
--
  p_per_information11 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION11');
--
  p_per_information12 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION12');
--
  p_per_information13 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION13');
--
  p_per_information14 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION14');
--
  p_per_information15 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION15');
--
  p_per_information16 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION16');
--
  p_per_information17 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION17');
--
  p_per_information18 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION18');
--
  p_per_information19 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION19');
--
  p_per_information20 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION20');
--
  p_per_information21 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION21');
--
  p_per_information22 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION22');
--
  p_per_information23 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION23');
--
  p_per_information24 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION24');
--
  p_per_information25 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION25');
--
  p_per_information26 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION26');
--
  p_per_information27 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION27');
--
  p_per_information28 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION28');
--
  p_per_information29 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION29');
--
  p_per_information30 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PER_INFORMATION30');
--
  l_title_meaning := get_hr_lookup_meaning (p_lookup_type => 'TITLE'
                                           ,p_lookup_code => l_title);
--
  l_marital_status_meaning := get_hr_lookup_meaning
                                (p_lookup_type => 'MAR_STATUS'
                                ,p_lookup_code => l_marital_status);
--
  p_full_name :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FULL_NAME');
--
  p_business_group_id :=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_BUSINESS_GROUP_ID');
--
  p_review_proc_call :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REVIEW_PROC_CALL');
--
  p_action_type  :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTION_TYPE');
--
  p_title := l_title;
  p_title_meaning := l_title_meaning;
  p_marital_status := l_marital_status;
  p_marital_status_meaning := l_marital_status_meaning;
--
--
hr_utility.set_location('End of  Calling hr_transaction_api methods:'||l_proc,15);
hr_utility.set_location('Exiting:'||l_proc, 20);
EXCEPTION
   WHEN OTHERS THEN
       hr_utility.set_location('Exception:Others'||l_proc,555);
       RAISE;

END get_person_data_from_tt;


-- ---------------------------------------------------------------------------
-- ---------------------------- < update_person> ------------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will perform validations when a user presses Next
--          on Update Basic Details entry page or on the Review page.
--          Either case, the data will be saved to the transaction table.
--          If this procedure is invoked from Review page, it will first check
--          that if a transaction already exists.  If it does, it will update
--          the current transaction record.
--          NOTE: The p_validate_mode cannot be in boolean because this
--                procedure will be called from Java which has a different
--                boolean value from pl/sql.
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
  ,p_appl_assign_id             in      number  default null
  ,p_error_message                out nocopy     long
  ,p_ni_duplicate_warn_or_err     in out nocopy varchar2
  ,p_validate_ni                  in out nocopy varchar2
 ) IS

  CURSOR  get_wf_actid (c_activity_name  in varchar2) IS
--BUG 3636429
    SELECT distinct process_activity activity_id
     FROM
     (
     SELECT
          ws.process_activity
     FROM wf_item_activity_statuses ws
       ,wf_process_activities wp
     WHERE ws.item_type = p_item_type
       AND ws.item_key = p_item_key
       AND ws.process_activity = wp.instance_id
       AND wp.activity_name = c_activity_name
     UNION ALL
     SELECT
          ws.process_activity
     FROM wf_item_activity_statuses_h ws
         ,wf_process_activities wp
     WHERE ws.item_type = p_item_type
       AND ws.item_key = p_item_key
       AND ws.process_activity = wp.instance_id
       AND wp.activity_name = c_activity_name
     );

  cursor check_payroll is
    select asg.assignment_id,
               asg.payroll_id, asg.soft_coding_keyflex_id
      from per_all_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and p_effective_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status         = 'ACCEPTED'
	   	 and asg.assignment_type = 'A'
       and asg.payroll_id is not null
       order by asg.assignment_id;

    cursor get_transaction_step_id IS
    SELECT transaction_step_id FROM   hr_api_transaction_steps
    WHERE  item_type = p_item_type
    AND    item_key  = p_item_key
    AND    api_name = 'HR_PROCESS_PERSON_SS.PROCESS_DUMMY_API';

     cursor get_job_and_asg is
     select pj.name, hou.name from
     per_all_assignments_f asf, per_jobs_tl pj, hr_all_organization_units_tl hou
     where asf.person_id = p_person_id and asf.primary_flag = 'Y'
    AND  asf.organization_id = hou.organization_id(+)
    AND  hou.language = userenv('LANG')
    AND  asf.job_id = pj.job_id(+)
    AND  pj.language(+)=userenv('LANG')
    and p_effective_date between effective_start_date and effective_end_date;

    p_job_name		varchar2(30);
    p_org_name		varchar2(30);

  dummy                           number;
  l_is_payroll_upd                    boolean;
  l_attribute_update_mode         varchar2(100) default  null;
  l_validate_mode                 boolean  default false;
  l_basic_details_update_mode     varchar2(100) default  null;
  l_form_changed                  boolean default false;
  l_count                         number default 0;
  l_transaction_table             hr_transaction_ss.transaction_table;
  l_dummy_txn_table	hr_transaction_ss.transaction_table;
  l_trs_object_version_number
         hr_api_transaction_steps.object_version_number%type default null;
  l_transaction_step_id
         hr_api_transaction_steps.transaction_step_id%type default null;
  ln_dummy_txn_step_id
         hr_api_transaction_steps.transaction_step_id%type default null;
  l_transaction_id             number default null;
  l_ovn                           number default null;

  l_name_combination_warning      boolean default false;
  l_assign_payroll_warning        boolean default false;
  l_orig_hire_warning             boolean default false;
  l_employee_number               per_all_people_f.employee_number%type
                                  default null;
  l_effective_start_date          date default null;
  l_effective_end_date            date default null;
  l_full_name                     per_all_people_f.full_name%type default null;
  l_comment_id                    per_all_people_f.comment_id%type default null;
  l_basic_details_changed         boolean default null;
  l_full_name_duplicate_flag      varchar2(1) default null;
  l_vendor_id                     number default null;
  l_benefit_group_id              number default null;
  l_fte_capacity                  number default null;
  l_error_message                 long default null;
  l_result                     varchar2(100) default null;
  l_review_item_name           varchar2(250);

-- variables and cursor for applicant_hire
  l_per_object_version_number number;
  l_per_effective_start_date date;
  l_per_effective_end_date date;
  l_appl_assignment_id number;
  l_unaccepted_asg_del_warning boolean;
  l_per_assign_payroll_warning boolean;
  l_current_applicant_flag  per_all_people_f.current_applicant_flag%type;
  l_current_employee_flag  per_all_people_f.current_employee_flag%type;
  l_current_npw_flag per_all_people_f.current_npw_flag%type;
  l_person_type_id per_all_people_f.person_type_id%type;
  l_proc   varchar2(72)  := g_package||'update_person';
  l_comments varchar2(100) := hr_api.g_varchar2;

BEGIN


hr_utility.set_location('Entering:'||l_proc, 5);
IF g_debug THEN
  hr_utility.set_location('IF g_debug THEN', 10);
END IF;


  IF upper(p_action_type) = g_change
  THEN
     hr_utility.set_location('IF Action Type=g_change', 15);
     l_attribute_update_mode := g_attribute_update;
  ELSE
     IF upper(p_action_type) = g_correct
     THEN
        hr_utility.set_location('IF Action Type=g_correct', 20);
        l_attribute_update_mode := g_attribute_correct;
     END IF;
  END IF;


IF g_debug THEN
    hr_utility.set_location('l_attribute_update_mode=' || l_attribute_update_mode, 20);
END IF;



  l_ovn := p_object_version_number;
  l_employee_number := p_employee_number;
  l_person_type_id := p_person_type_id;

-- Java caller will set p_vendor_id, p_benefit_group_id and p_fte_capacity to
-- hr_api.g_number value.  We need to set these back to null before saving to
-- transaction table.

   IF p_vendor_id = 0
   THEN
      hr_utility.set_location('p_vendor_id = 0:'||l_proc,25);
      l_vendor_id := null;
   ELSE
      hr_utility.set_location('p_vendor_id != 0:'||l_proc,30);
      l_vendor_id := p_vendor_id;
   END IF;
--
   IF p_benefit_group_id = 0
   THEN
      l_benefit_group_id := null;
   ELSE
      l_benefit_group_id := p_benefit_group_id;
   END IF;
--
   IF p_fte_capacity = 0
   THEN
      l_fte_capacity := null;
   ELSE
      l_fte_capacity := p_fte_capacity;
   END IF;

-- This procedure can be called by Update Basic Details entry page only.
--
-- The field "p_process_section_name" will be set to 'BASIC_DETAILS' if called
-- from Update Basic Details page to transition to the Review page.
--
-- We will always save to transaction table regardless of whether the update is
-- for approval or not.  Therefore, the validate_mode for calling the person
-- api should always be set to true.
--
   IF p_validate_mode = 'N' OR p_validate_mode IS NULL
   THEN
      l_validate_mode := false;
   ELSE
      l_validate_mode := true;
   END IF;

  -- get the assignment_id from workflow
   l_appl_assignment_id := wf_engine.getItemAttrText(
    itemtype  => p_item_type,
    itemkey   => p_item_key,
    aname     => 'CURRENT_ASSIGNMENT_ID');

  if (p_asgn_change_mode = 'V' OR p_asgn_change_mode = 'W') then
     l_appl_assignment_id := p_appl_assign_id;
  end if;

-- Save for later changes.
   IF (p_save_mode = 'SAVE_FOR_LATER') THEN
       hr_utility.set_location('save mode is SFL'||l_proc,35);
       GOTO only_transaction;
   END IF;

--

  -- In case of hiring an applicant, we need to call the hr_applicant_api to
  -- make the applicant an employee and then update the BD record and made
  -- this call before is_basic_details_changed, so that the person_type_id
  -- is always changed and we write to transaction tables

   hr_utility.set_location('Open:gc_get_current_applicant_flag'||l_proc,40);
   open gc_get_current_applicant_flag(p_person_id, p_effective_date);
   fetch gc_get_current_applicant_flag into l_current_applicant_flag, l_current_employee_flag, l_current_npw_flag;
   close gc_get_current_applicant_flag;

   l_per_object_version_number := l_ovn;

   --call the hr_applicant_api.hire_applicant in commit mode
   -- and get the person type and store it in transaction tables

   if (l_current_applicant_flag = 'Y' AND
      nvl(l_current_employee_flag, 'N') <>  'Y' AND
      nvl(l_current_npw_flag, 'N') <> 'Y') then
     g_applicant_hire := true;

     hr_utility.set_location(' SAVEPOINT applicant_hire:'||l_proc,45);
     SAVEPOINT applicant_hire;

     for c in check_payroll loop
        process_applicant(
           p_effective_date  =>    p_effective_date
          ,p_person_id     =>  p_person_id
          ,p_assignment_id     =>  c.assignment_id
          ,p_soft_coding_keyflex_id => c.soft_coding_keyflex_id
          ,p_business_group_id =>  p_business_group_id
          ,p_is_payroll_upd => l_is_payroll_upd);
     end loop;

     hr_applicant_api.hire_applicant(
      p_validate => false
     ,p_hire_date => p_effective_date
     ,p_person_id => p_person_id
     ,p_per_object_version_number => l_per_object_version_number
     ,p_assignment_id =>  l_appl_assignment_id
     ,p_employee_number => l_employee_number
     ,p_per_effective_start_date => l_per_effective_start_date
     ,p_per_effective_end_date => l_per_effective_end_date
     ,p_unaccepted_asg_del_warning  => l_unaccepted_asg_del_warning
     ,p_assign_payroll_warning => l_assign_payroll_warning
     ,p_source => true);


     ROLLBACK TO applicant_hire;
     g_applicant_hire := false;

   end if;

  ---------------------------------------------------------------------------
    -- Bug 1937643 Fix Begins - 08/04/2002
    -- With the PTU model, the per_all_people_f.person_type_id stores only the
    -- default user flavor of the system_person_type.  The true user flavor
    -- for the system_person_type is stored in per_person_type_usages_f table.
    -- Since the current Personal Information Basic Details region and the
    -- New Hire page does not allow a user to choose any user flavor, so we'll
    -- zap the p_person_type_id to hr_api.g_number value when it is not an
    -- applicant when calling the hr_person_api.update_person. That way, the api
    -- will understand that the person_type is not changed and will not update
    -- the person_type_id in per_person_type_usages_f table as is.  If we pass
    -- the per_all_people_f.person_type_id to the api, the person_type_id in
    -- per_person_type_usages_f table will be updated with that value which will
    -- overwrite the true user flavor of the system person type with the
    -- default user flavor person type.  This may not be desirable.
    -- When we allow a user to select user flavors of person type in New Hire
    -- or Basic Details page, the code to pass hr_api.g_number in
    -- p_person_type_id for non-applicant needs to change.
    ---------------------------------------------------------------------------



   IF (l_current_applicant_flag = 'Y' AND
      nvl(l_current_employee_flag, 'N') <>  'Y' AND
      nvl(l_current_npw_flag, 'N') <> 'Y')
   THEN
    -- get the person_type_id for the applicant from database
      hr_utility.set_location('Fetching gc_get_new_appl_person_type into l_person_type_id:'||l_proc,50);
      open gc_get_new_appl_person_type(p_person_id, p_effective_date);
      fetch gc_get_new_appl_person_type into l_person_type_id;
      close gc_get_new_appl_person_type;
   ELSE
       l_person_type_id := hr_api.g_number;
   END IF;

-- Bug 1937643 Fix END



IF g_debug THEN
  hr_utility.set_location('Before calling is_rec_changed', 55);
END IF;


  -- Check if the record has changed
  l_basic_details_changed := hr_process_person_ss.is_rec_changed
    (p_effective_date              => p_effective_date
    ,p_person_id                   => p_person_id
    ,p_object_version_number       => p_object_version_number
    ,p_person_type_id              => p_person_type_id
    ,p_last_name                   => p_last_name
    ,p_applicant_number            => p_applicant_number
    ,p_comments                    => l_comments
    ,p_date_employee_data_verified => p_date_employee_data_verified
    ,p_original_date_of_hire       => p_original_date_of_hire
    ,p_date_of_birth               => p_date_of_birth
    ,p_town_of_birth               => p_town_of_birth
    ,p_region_of_birth             => p_region_of_birth
    ,p_country_of_birth            => p_country_of_birth
    ,p_global_person_id            => p_global_person_id
    ,p_email_address               => p_email_address
    ,p_employee_number             => p_employee_number
    ,p_npw_number                  => p_npw_number
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                  => p_first_name
    ,p_known_as                    => p_known_as
    ,p_marital_status              => p_marital_status
    ,p_middle_names                => p_middle_names
    ,p_nationality                 => p_nationality
    ,p_national_identifier         => p_national_identifier
    ,p_previous_last_name          => p_previous_last_name
    ,p_registered_disabled_flag    => p_registered_disabled_flag
    ,p_sex                         => p_sex
    ,p_title                       => p_title
    ,p_vendor_id                   => l_vendor_id
    ,p_work_telephone              => p_work_telephone
    ,p_suffix                      => p_suffix
    ,p_date_of_death               => p_date_of_death
    ,p_background_check_status     => p_background_check_status
    ,p_background_date_check       => p_background_date_check
    ,p_blood_type                  => p_blood_type
    ,p_correspondence_language     => p_correspondence_language
    ,p_fast_path_employee          => p_fast_path_employee
    ,p_fte_capacity                => l_fte_capacity
    ,p_hold_applicant_date_until   => p_hold_applicant_date_until
    ,p_honors                      => p_honors
    ,p_internal_location           => p_internal_location
    ,p_last_medical_test_by        => p_last_medical_test_by
    ,p_last_medical_test_date      => p_last_medical_test_date
    ,p_mailstop                    => p_mailstop
    ,p_office_number               => p_office_number
    ,p_on_military_service         => p_on_military_service
    ,p_pre_name_adjunct            => p_pre_name_adjunct
    ,p_projected_start_date        => p_projected_start_date
    ,p_rehire_authorizor           => p_rehire_authorizor
    ,p_rehire_recommendation       => p_rehire_recommendation
    ,p_resume_exists               => p_resume_exists
    ,p_resume_last_updated         => p_resume_last_updated
    ,p_second_passport_exists      => p_second_passport_exists
    ,p_student_status              => p_student_status
    ,p_work_schedule               => p_work_schedule
    ,p_rehire_reason               => p_rehire_reason
    ,p_benefit_group_id            => l_benefit_group_id
    ,p_receipt_of_death_cert_date  => p_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no        => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag       => p_coord_ben_no_cvg_flag
    ,p_uses_tobacco_flag           => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date         => p_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag      => p_dpdnt_vlntry_svce_flag
    ,p_adjusted_svc_date           => p_adjusted_svc_date
    ,p_attribute_category          => p_attribute_category
    ,p_attribute1                  => p_attribute1
    ,p_attribute2                  => p_attribute2
    ,p_attribute3                  => p_attribute3
    ,p_attribute4                  => p_attribute4
    ,p_attribute5                  => p_attribute5
    ,p_attribute6                  => p_attribute6
    ,p_attribute7                  => p_attribute7
    ,p_attribute8                  => p_attribute8
    ,p_attribute9                  => p_attribute9
    ,p_attribute10                 => p_attribute10
    ,p_attribute11                 => p_attribute11
    ,p_attribute12                 => p_attribute12
    ,p_attribute13                 => p_attribute13
    ,p_attribute14                 => p_attribute14
    ,p_attribute15                 => p_attribute15
    ,p_attribute16                 => p_attribute16
    ,p_attribute17                 => p_attribute17
    ,p_attribute18                 => p_attribute18
    ,p_attribute19                 => p_attribute19
    ,p_attribute20                 => p_attribute20
    ,p_attribute21                 => p_attribute21
    ,p_attribute22                 => p_attribute22
    ,p_attribute23                 => p_attribute23
    ,p_attribute24                 => p_attribute24
    ,p_attribute25                 => p_attribute25
    ,p_attribute26                 => p_attribute26
    ,p_attribute27                 => p_attribute27
    ,p_attribute28                 => p_attribute28
    ,p_attribute29                 => p_attribute29
    ,p_attribute30                 => p_attribute30
    ,p_per_information_category    => p_per_information_category
    ,p_per_information1            => p_per_information1
    ,p_per_information2            => p_per_information2
    ,p_per_information3            => p_per_information3
    ,p_per_information4            => p_per_information4
    ,p_per_information5            => p_per_information5
    ,p_per_information6            => p_per_information6
    ,p_per_information7            => p_per_information7
    ,p_per_information8            => p_per_information8
    ,p_per_information9            => p_per_information9
    ,p_per_information10           => p_per_information10
    ,p_per_information11           => p_per_information11
    ,p_per_information12           => p_per_information12
    ,p_per_information13           => p_per_information13
    ,p_per_information14           => p_per_information14
    ,p_per_information15           => p_per_information15
    ,p_per_information16           => p_per_information16
    ,p_per_information17           => p_per_information17
    ,p_per_information18           => p_per_information18
    ,p_per_information19           => p_per_information19
    ,p_per_information20           => p_per_information20
    ,p_per_information21           => p_per_information21
    ,p_per_information22           => p_per_information22
    ,p_per_information23           => p_per_information23
    ,p_per_information24           => p_per_information24
    ,p_per_information25           => p_per_information25
    ,p_per_information26           => p_per_information26
    ,p_per_information27           => p_per_information27
    ,p_per_information28           => p_per_information28
    ,p_per_information29           => p_per_information29
    ,p_per_information30           => p_per_information30
    );
  --
  IF l_basic_details_changed
  THEN
     null;
  ELSE
     hr_utility.set_location('raise hr_perinfo_util_web.g_no_changes:'||l_proc,60);
     raise hr_perinfo_util_web.g_no_changes;
     GOTO no_transaction;
  END IF;


  if(p_assign_payroll_warning = 'Y') then
    hr_utility.set_location('p_assign_payroll_warning = Y:'||l_proc,65);
    l_assign_payroll_warning := true;
  end if;

  --

  -- For National Identifier validations
   if (l_current_applicant_flag = 'Y' AND
     nvl(l_current_employee_flag, 'N') <>  'Y' AND
     nvl(l_current_npw_flag, 'N') <> 'Y')
   then
     if(p_ni_duplicate_warn_or_err <> 'IGNORE') then
        hr_person_info_util_ss.check_ni_unique(
        p_national_identifier => p_national_identifier
       ,p_business_group_id => p_business_group_id
       ,p_person_id => p_person_id
       ,p_ni_duplicate_warn_or_err => p_ni_duplicate_warn_or_err);
     end if;

     if(p_validate_ni <> 'IGNORE') then
	hr_utility.set_location('p_validate_ni <> IGNORE:'||l_proc,70);
    hr_person_info_util_ss.validate_national_identifier(
	p_national_identifier => p_national_identifier
       ,p_birth_date => p_date_of_birth
       ,p_gender => p_sex
       ,p_person_id => p_person_id
       ,p_business_group_id => p_business_group_id
       ,p_legislation_code => p_per_information_category
       ,p_effective_date => p_effective_date
       ,p_warning => p_validate_ni);
     end if;
  end if;

  validate_basic_details
    (p_validate_mode               => l_validate_mode
    ,p_attribute_update_mode       => l_attribute_update_mode
    ,p_effective_date              => p_effective_date
    ,p_person_id                   => p_person_id
    ,p_object_version_number       => l_ovn
    ,p_person_type_id              => l_person_type_id
    ,p_last_name                   => p_last_name
    ,p_applicant_number            => p_applicant_number
    ,p_comments                    => l_comments
    ,p_date_employee_data_verified => p_date_employee_data_verified
    ,p_original_date_of_hire       => p_original_date_of_hire
    ,p_date_of_birth               => p_date_of_birth
    ,p_town_of_birth               => p_town_of_birth
    ,p_region_of_birth             => p_region_of_birth
    ,p_country_of_birth            => p_country_of_birth
    ,p_global_person_id            => p_global_person_id
    ,p_email_address               => p_email_address
    ,p_employee_number             => l_employee_number
    ,p_npw_number                  => p_npw_number
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                  => p_first_name
    ,p_known_as                    => p_known_as
    ,p_marital_status              => p_marital_status
    ,p_middle_names                => p_middle_names
    ,p_nationality                 => p_nationality
    ,p_national_identifier         => p_national_identifier
    ,p_previous_last_name          => p_previous_last_name
    ,p_registered_disabled_flag    => p_registered_disabled_flag
    ,p_sex                         => p_sex
    ,p_title                       => p_title
    ,p_vendor_id                   => l_vendor_id
    ,p_work_telephone              => p_work_telephone
    ,p_suffix                      => p_suffix
    ,p_date_of_death               => p_date_of_death
    ,p_background_check_status     => p_background_check_status
    ,p_background_date_check       => p_background_date_check
    ,p_blood_type                  => p_blood_type
    ,p_correspondence_language     => p_correspondence_language
    ,p_fast_path_employee          => p_fast_path_employee
    ,p_fte_capacity                => l_fte_capacity
    ,p_hold_applicant_date_until   => p_hold_applicant_date_until
    ,p_honors                      => p_honors
    ,p_internal_location           => p_internal_location
    ,p_last_medical_test_by        => p_last_medical_test_by
    ,p_last_medical_test_date      => p_last_medical_test_date
    ,p_mailstop                    => p_mailstop
    ,p_office_number               => p_office_number
    ,p_on_military_service         => p_on_military_service
    ,p_pre_name_adjunct            => p_pre_name_adjunct
    ,p_projected_start_date        => p_projected_start_date
    ,p_rehire_authorizor           => p_rehire_authorizor
    ,p_rehire_recommendation       => p_rehire_recommendation
    ,p_resume_exists               => p_resume_exists
    ,p_resume_last_updated         => p_resume_last_updated
    ,p_second_passport_exists      => p_second_passport_exists
    ,p_student_status              => p_student_status
    ,p_work_schedule               => p_work_schedule
    ,p_rehire_reason               => p_rehire_reason
    ,p_benefit_group_id            => l_benefit_group_id
    ,p_receipt_of_death_cert_date  => p_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no        => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag       => p_coord_ben_no_cvg_flag
    ,p_uses_tobacco_flag           => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date         => p_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag      => p_dpdnt_vlntry_svce_flag
    ,p_adjusted_svc_date           => p_adjusted_svc_date
    ,p_attribute_category          => p_attribute_category
    ,p_attribute1                  => p_attribute1
    ,p_attribute2                  => p_attribute2
    ,p_attribute3                  => p_attribute3
    ,p_attribute4                  => p_attribute4
    ,p_attribute5                  => p_attribute5
    ,p_attribute6                  => p_attribute6
    ,p_attribute7                  => p_attribute7
    ,p_attribute8                  => p_attribute8
    ,p_attribute9                  => p_attribute9
    ,p_attribute10                 => p_attribute10
    ,p_attribute11                 => p_attribute11
    ,p_attribute12                 => p_attribute12
    ,p_attribute13                 => p_attribute13
    ,p_attribute14                 => p_attribute14
    ,p_attribute15                 => p_attribute15
    ,p_attribute16                 => p_attribute16
    ,p_attribute17                 => p_attribute17
    ,p_attribute18                 => p_attribute18
    ,p_attribute19                 => p_attribute19
    ,p_attribute20                 => p_attribute20
    ,p_attribute21                 => p_attribute21
    ,p_attribute22                 => p_attribute22
    ,p_attribute23                 => p_attribute23
    ,p_attribute24                 => p_attribute24
    ,p_attribute25                 => p_attribute25
    ,p_attribute26                 => p_attribute26
    ,p_attribute27                 => p_attribute27
    ,p_attribute28                 => p_attribute28
    ,p_attribute29                 => p_attribute29
    ,p_attribute30                 => p_attribute30
    ,p_per_information_category    => p_per_information_category
    ,p_per_information1            => p_per_information1
    ,p_per_information2            => p_per_information2
    ,p_per_information3            => p_per_information3
    ,p_per_information4            => p_per_information4
    ,p_per_information5            => p_per_information5
    ,p_per_information6            => p_per_information6
    ,p_per_information7            => p_per_information7
    ,p_per_information8            => p_per_information8
    ,p_per_information9            => p_per_information9
    ,p_per_information10           => p_per_information10
    ,p_per_information11           => p_per_information11
    ,p_per_information12           => p_per_information12
    ,p_per_information13           => p_per_information13
    ,p_per_information14           => p_per_information14
    ,p_per_information15           => p_per_information15
    ,p_per_information16           => p_per_information16
    ,p_per_information17           => p_per_information17
    ,p_per_information18           => p_per_information18
    ,p_per_information19           => p_per_information19
    ,p_per_information20           => p_per_information20
    ,p_per_information21           => p_per_information21
    ,p_per_information22           => p_per_information22
    ,p_per_information23           => p_per_information23
    ,p_per_information24           => p_per_information24
    ,p_per_information25           => p_per_information25
    ,p_per_information26           => p_per_information26
    ,p_per_information27           => p_per_information27
    ,p_per_information28           => p_per_information28
    ,p_per_information29           => p_per_information29
    ,p_per_information30           => p_per_information30
    ,p_effective_start_date        => l_effective_start_date
    ,p_effective_end_date          => l_effective_end_date
    ,p_full_name                   => l_full_name
    ,p_comment_id                  => l_comment_id
    ,p_name_combination_warning    => l_name_combination_warning
    ,p_assign_payroll_warning      => l_assign_payroll_warning
    ,p_orig_hire_warning           => l_orig_hire_warning
    ,p_error_message               => l_error_message
   );


IF g_debug THEN
  hr_utility.set_location('After calling validate_basic_details', 75);
END IF;


--
  IF (l_error_message IS NOT NULL) THEN
     hr_utility.set_location('l_error_message IS NOT NULL:'||l_proc,80);
     raise hr_process_person_ss.g_validate_basic_details_error;
  END IF;

--
  IF hr_errors_api.errorExists
  THEN

IF g_debug THEN
     hr_utility.set_location('api error exists', 85);
END IF;

     raise g_data_error;
  END IF;
--

--
-------------------------------------------------------------------------------
-- We use the p_actid passed in because only in the Update page will it call
-- this update_person procedure.
--
-- Now save the data to transaction table.  When coming from Update Basic
-- Details first time, a transaction step won't exit.  We'll save to
-- transaction table.  Then displays the Review page.  A user can press back to
-- go back to Update Basic Details and enters some more changes or correct typo
-- errors. At this point, a transaction step already exists.
-- Before saving to the transaction table, we need to see if a transaction step
-- already exists or not.  This could happen when a user enters data to Update
-- Basic Details --> Next --> Review Page --> Back to Update Basic Details to
-- correct wrong entry or to make further changes --> Next --> Review Page.
-- Use the activity_id to check if a transaction step already
-- exists.
-------------------------------------------------------------------------------

  <<only_transaction>> -- label for GOTO

-- Set the P_EFFECTIVE_DATE and CURRENT_EFFECTIVE_DATE in wf item attributes to be retreived
-- in review page

       wf_engine.setItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'P_EFFECTIVE_DATE',
                           avalue   =>  to_char(p_effective_date,
                                        g_date_format));

       wf_engine.setItemAttrDate (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'CURRENT_EFFECTIVE_DATE',
                           avalue   =>  p_effective_date);

  --
  -- First, check if transaction id exists or not
  --
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
       --
  IF l_transaction_id is null THEN

        -- Start a Transaction

     hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_actid
           ,funmode    => 'RUN'
           ,p_login_person_id => p_login_person_id
           ,result     => l_result);

     l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
  END IF;
  --
  -- Create a transaction step
  --
     hr_transaction_api.create_transaction_step
           (p_validate              => false
           ,p_creator_person_id     => p_login_person_id
           ,p_transaction_id        => l_transaction_id
           ,p_api_name              => g_package || 'PROCESS_API'
           ,p_item_type             => p_item_type
           ,p_item_key              => p_item_key
           ,p_activity_id           => p_actid
           ,p_transaction_step_id   => l_transaction_step_id
           ,p_object_version_number => l_trs_object_version_number);
 --

--
--
  l_count := 1;
  l_transaction_table(l_count).param_name := 'P_ITEM_TYPE';
  l_transaction_table(l_count).param_value := p_item_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ITEM_KEY';
  l_transaction_table(l_count).param_value := p_item_key;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTIVITY_ID';
  l_transaction_table(l_count).param_value := p_actid;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PROCESS_SECTION_NAME';
  l_transaction_table(l_count).param_value := p_process_section_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTION_TYPE';
  l_transaction_table(l_count).param_value := p_action_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
  l_transaction_table(l_count).param_value := to_char(p_effective_date,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
-- Store the hire date in p_date_start to be shown as HireDate
-- in review page for applicant hire.
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_START';
  l_transaction_table(l_count).param_value := to_char(p_effective_date,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_UPDATE_MODE';
  l_transaction_table(l_count).param_value := l_attribute_update_mode;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
-- We don't want to derive the business_group_id because we want to save a
-- db sql statement call to improve the performance.
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
  l_transaction_table(l_count).param_value := p_business_group_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_ID';
  l_transaction_table(l_count).param_value := p_person_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := p_object_version_number;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_TYPE_ID';
  l_transaction_table(l_count).param_value := p_person_type_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_NAME';
  l_transaction_table(l_count).param_value := p_last_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
--
------------------------------------------------------------------------------
--NOTE: When we save to transaction table, we need to convert all number and
--      date data type to varchar2 because the transaction table is defined as
--      varchar2 for the param_value.  Otherwise, we will get ORA 06502:PL/SQL
--      numeric or value error, character conversion to number because in
--      hr_transaction_ss.save_transaction_step, it uses a to_number function
--      to convert the param_value from char to num for param_type = 'NUMBER'.
------------------------------------------------------------------------------
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FULL_NAME';
  l_transaction_table(l_count).param_value := l_full_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_APPLICANT_NUMBER';
  l_transaction_table(l_count).param_value := p_applicant_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COMMENTS';
  l_transaction_table(l_count).param_value := l_comments;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_EMPLOYEE_DATA_VERIFIED';
  l_transaction_table(l_count).param_value := to_char
                                              (p_date_employee_data_verified
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ORIGINAL_DATE_OF_HIRE';
  l_transaction_table(l_count).param_value := to_char
                                             (p_original_date_of_hire
                                             ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_OF_BIRTH';
  l_transaction_table(l_count).param_value := to_char
                                              (p_date_of_birth
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TOWN_OF_BIRTH';
  l_transaction_table(l_count).param_value := p_town_of_birth;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REGION_OF_BIRTH';
  l_transaction_table(l_count).param_value := p_region_of_birth;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COUNTRY_OF_BIRTH';
  l_transaction_table(l_count).param_value := p_country_of_birth;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_GLOBAL_PERSON_ID';
  l_transaction_table(l_count).param_value := p_global_person_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EMAIL_ADDRESS';
  l_transaction_table(l_count).param_value := p_email_address;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EMPLOYEE_NUMBER';
  l_transaction_table(l_count).param_value := p_employee_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NPW_NUMBER';
  l_transaction_table(l_count).param_value := p_npw_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EXPENSE_CHECK_SEND_TO_ADDRES';
  l_transaction_table(l_count).param_value := p_expense_check_send_to_addres;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FIRST_NAME';
  l_transaction_table(l_count).param_value := p_first_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_KNOWN_AS';
  l_transaction_table(l_count).param_value := p_known_as;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_MARITAL_STATUS';
  l_transaction_table(l_count).param_value := p_marital_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_MIDDLE_NAMES';
  l_transaction_table(l_count).param_value := p_middle_names;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NATIONALITY';
  l_transaction_table(l_count).param_value := p_nationality;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NATIONAL_IDENTIFIER';
  l_transaction_table(l_count).param_value := p_national_identifier;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PREVIOUS_LAST_NAME';
  l_transaction_table(l_count).param_value := p_previous_last_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REGISTERED_DISABLED_FLAG';
  l_transaction_table(l_count).param_value := p_registered_disabled_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SEX';
  l_transaction_table(l_count).param_value := p_sex;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TITLE';
  l_transaction_table(l_count).param_value := p_title;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_VENDOR_ID';
  l_transaction_table(l_count).param_value := to_char(l_vendor_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_WORK_TELEPHONE';
  l_transaction_table(l_count).param_value := p_work_telephone;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SUFFIX';
  l_transaction_table(l_count).param_value := p_suffix;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_OF_DEATH';
  l_transaction_table(l_count).param_value := to_char
                                              (p_date_of_death
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BACKGROUND_CHECK_STATUS';
  l_transaction_table(l_count).param_value := p_background_check_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BACKGROUND_DATE_CHECK';
  l_transaction_table(l_count).param_value := to_char
                                              (p_background_date_check
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BLOOD_TYPE';
  l_transaction_table(l_count).param_value := p_blood_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CORRESPONDENCE_LANGUAGE';
  l_transaction_table(l_count).param_value := p_correspondence_language;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FAST_PATH_EMPLOYEE';
  l_transaction_table(l_count).param_value := p_fast_path_employee;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FTE_CAPACITY';
  l_transaction_table(l_count).param_value := to_char(l_fte_capacity);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_HOLD_APPLICANT_DATE_UNTIL';
  l_transaction_table(l_count).param_value := to_char
                                              (p_hold_applicant_date_until
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_HONORS';
  l_transaction_table(l_count).param_value := p_honors;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INTERNAL_LOCATION';
  l_transaction_table(l_count).param_value := p_internal_location;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_MEDICAL_TEST_BY';
  l_transaction_table(l_count).param_value := p_last_medical_test_by;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_MEDICAL_TEST_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_last_medical_test_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_MAILSTOP';
  l_transaction_table(l_count).param_value := p_mailstop;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OFFICE_NUMBER';
  l_transaction_table(l_count).param_value := p_office_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ON_MILITARY_SERVICE';
  l_transaction_table(l_count).param_value := p_on_military_service;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PRE_NAME_ADJUNCT';
  l_transaction_table(l_count).param_value := p_pre_name_adjunct;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PROJECTED_START_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_projected_start_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REHIRE_AUTHORIZOR';
  l_transaction_table(l_count).param_value := p_rehire_authorizor;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REHIRE_RECOMMENDATION';
  l_transaction_table(l_count).param_value := p_rehire_recommendation;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RESUME_EXISTS';
  l_transaction_table(l_count).param_value := p_resume_exists;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RESUME_LAST_UPDATED';
  l_transaction_table(l_count).param_value := to_char
                                              (p_resume_last_updated
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SECOND_PASSPORT_EXISTS';
  l_transaction_table(l_count).param_value := p_second_passport_exists;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_STUDENT_STATUS';
  l_transaction_table(l_count).param_value := p_student_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_WORK_SCHEDULE';
  l_transaction_table(l_count).param_value := p_work_schedule;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REHIRE_REASON';
  l_transaction_table(l_count).param_value := p_rehire_reason;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BENEFIT_GROUP_ID';
  l_transaction_table(l_count).param_value := to_char(l_benefit_group_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RECEIPT_OF_DEATH_CERT_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_receipt_of_death_cert_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COORD_BEN_MED_PLN_NO';
  l_transaction_table(l_count).param_value := p_coord_ben_med_pln_no;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COORD_BEN_NO_CVG_FLAG';
  l_transaction_table(l_count).param_value := p_coord_ben_no_cvg_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_USES_TOBACCO_FLAG';
  l_transaction_table(l_count).param_value := p_uses_tobacco_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DPDNT_ADOPTION_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_dpdnt_adoption_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DPDNT_VLNTRY_SVCE_FLAG';
  l_transaction_table(l_count).param_value := p_dpdnt_vlntry_svce_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ADJUSTED_SVC_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_adjusted_svc_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';

--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_CATEGORY';
  l_transaction_table(l_count).param_value := p_attribute_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1';
  l_transaction_table(l_count).param_value := p_attribute1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2';
  l_transaction_table(l_count).param_value := p_attribute2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3';
  l_transaction_table(l_count).param_value := p_attribute3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4';
  l_transaction_table(l_count).param_value := p_attribute4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5';
  l_transaction_table(l_count).param_value := p_attribute5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6';
  l_transaction_table(l_count).param_value := p_attribute6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7';
  l_transaction_table(l_count).param_value := p_attribute7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8';
  l_transaction_table(l_count).param_value := p_attribute8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9';
  l_transaction_table(l_count).param_value := p_attribute9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10';
  l_transaction_table(l_count).param_value := p_attribute10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11';
  l_transaction_table(l_count).param_value := p_attribute11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12';
  l_transaction_table(l_count).param_value := p_attribute12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13';
  l_transaction_table(l_count).param_value := p_attribute13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14';
  l_transaction_table(l_count).param_value := p_attribute14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15';
  l_transaction_table(l_count).param_value := p_attribute15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16';
  l_transaction_table(l_count).param_value := p_attribute16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17';
  l_transaction_table(l_count).param_value := p_attribute17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18';
  l_transaction_table(l_count).param_value := p_attribute18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19';
  l_transaction_table(l_count).param_value := p_attribute19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20';
  l_transaction_table(l_count).param_value := p_attribute20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE21';
  l_transaction_table(l_count).param_value := p_attribute21;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE22';
  l_transaction_table(l_count).param_value := p_attribute22;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE23';
  l_transaction_table(l_count).param_value := p_attribute23;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE24';
  l_transaction_table(l_count).param_value := p_attribute24;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE25';
  l_transaction_table(l_count).param_value := p_attribute25;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE26';
  l_transaction_table(l_count).param_value := p_attribute26;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE27';
  l_transaction_table(l_count).param_value := p_attribute27;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE28';
  l_transaction_table(l_count).param_value := p_attribute28;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE29';
  l_transaction_table(l_count).param_value := p_attribute29;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE30';
  l_transaction_table(l_count).param_value := p_attribute30;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION_CATEGORY';
  l_transaction_table(l_count).param_value := p_per_information_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION1';
  l_transaction_table(l_count).param_value := p_per_information1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION2';
  l_transaction_table(l_count).param_value := p_per_information2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION3';
  l_transaction_table(l_count).param_value := p_per_information3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION4';
  l_transaction_table(l_count).param_value := p_per_information4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION5';
  l_transaction_table(l_count).param_value := p_per_information5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION6';
  l_transaction_table(l_count).param_value := p_per_information6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION7';
  l_transaction_table(l_count).param_value := p_per_information7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION8';
  l_transaction_table(l_count).param_value := p_per_information8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION9';
  l_transaction_table(l_count).param_value := p_per_information9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION10';
  l_transaction_table(l_count).param_value := p_per_information10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION11';
  l_transaction_table(l_count).param_value := p_per_information11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION12';
  l_transaction_table(l_count).param_value := p_per_information12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION13';
  l_transaction_table(l_count).param_value := p_per_information13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION14';
  l_transaction_table(l_count).param_value := p_per_information14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION15';
  l_transaction_table(l_count).param_value := p_per_information15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION16';
  l_transaction_table(l_count).param_value := p_per_information16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION17';
  l_transaction_table(l_count).param_value := p_per_information17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION18';
  l_transaction_table(l_count).param_value := p_per_information18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION19';
  l_transaction_table(l_count).param_value := p_per_information19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION20';
  l_transaction_table(l_count).param_value := p_per_information20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION21';
  l_transaction_table(l_count).param_value := p_per_information21;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION22';
  l_transaction_table(l_count).param_value := p_per_information22;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION23';
  l_transaction_table(l_count).param_value := p_per_information23;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION24';
  l_transaction_table(l_count).param_value := p_per_information24;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION25';
  l_transaction_table(l_count).param_value := p_per_information25;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION26';
  l_transaction_table(l_count).param_value := p_per_information26;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION27';
  l_transaction_table(l_count).param_value := p_per_information27;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION28';
  l_transaction_table(l_count).param_value := p_per_information28;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION29';
  l_transaction_table(l_count).param_value := p_per_information29;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION30';
  l_transaction_table(l_count).param_value := p_per_information30;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

--
  l_review_item_name := p_review_page_region_code;
  if (p_review_page_region_code IS NULL) then
    BEGIN
      l_review_item_name :=
        wf_engine.GetActivityAttrText(itemtype  => p_item_type,
                               itemkey   => p_item_key,
                               actid     => p_actid,
                               aname     => g_wf_review_regn_itm_attr_name);
    EXCEPTION
    WHEN OTHERS THEN
       hr_utility.set_location('Exception:Others'||l_proc,555);
       l_review_item_name := 'HrBasicDetailsReview';
    END;
  end if;

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
  l_transaction_table(l_count).param_value := l_review_item_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_actid;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_APPL_ASSIGNMENT_ID';
  l_transaction_table(l_count).param_value := l_appl_assignment_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ASGN_CHANGE_MODE';
  l_transaction_table(l_count).param_value := p_asgn_change_mode;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

--------------------------------------------------------------------------------
-- NOTE: If l_transaction_step_id is null, when we call
--       hr_transaction_ss.save_transaction_step will create a transaction and
--       create a transaction_step_id.
--       If it is not null, it will use the existing step id to update the
--       database.
--------------------------------------------------------------------------------
--

IF g_debug THEN
  hr_utility.set_location('Before save_transaction_step', 95);
END IF;


  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => p_actid
                ,p_login_person_id     => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || 'PROCESS_API'
                ,p_transaction_data => l_transaction_table);
--
   open  get_transaction_step_id;
   fetch get_transaction_step_id into ln_dummy_txn_step_id;
   close get_transaction_step_id;

   if p_asgn_change_mode = 'Y' and ln_dummy_txn_step_id is null then
     hr_transaction_api.Set_Process_Order_String(p_item_type => p_item_type
                      ,p_item_key  => p_item_key
                      ,p_actid => -1);
     open get_job_and_asg;
     fetch get_job_and_asg into p_job_name,p_org_name;
     close get_job_and_asg;

      l_count := 1;
      l_dummy_txn_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
      l_dummy_txn_table(l_count).param_value := 'HrDummyAssignment';
      l_dummy_txn_table(l_count).param_data_type := 'VARCHAR2';
--
      l_count := l_count + 1;
      l_dummy_txn_table(l_count).param_name := 'P_REVIEW_ACTID';
      l_dummy_txn_table(l_count).param_value := -1;
      l_dummy_txn_table(l_count).param_data_type := 'VARCHAR2';

      l_count := l_count + 1;
      l_dummy_txn_table(l_count).param_name := 'P_JOB_NAME';
      l_dummy_txn_table(l_count).param_value := p_job_name;
      l_dummy_txn_table(l_count).param_data_type := 'VARCHAR2';

      l_count := l_count + 1;
      l_dummy_txn_table(l_count).param_name := 'P_ORG_NAME';
      l_dummy_txn_table(l_count).param_value := p_org_name;
      l_dummy_txn_table(l_count).param_data_type := 'VARCHAR2';

       hr_transaction_ss.save_transaction_step
	(p_item_type => p_item_type
	,p_item_key => p_item_key
	,p_actid =>	-1
	,p_login_person_id => p_login_person_id
	,p_transaction_step_id => ln_dummy_txn_step_id
	,p_api_name => 'HR_PROCESS_PERSON_SS.PROCESS_DUMMY_API'
	,p_transaction_data => l_dummy_txn_table);
   end if;

IF g_debug THEN
  hr_utility.set_location('After save_transaction_step', 100);
END IF;

--
-- Not sure if we need to set the generic approval url here ????
--
--

IF g_debug THEN
  hr_utility.set_location('After saving transaction steps', 105);
END IF;


--
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_full_name := l_full_name;
  p_comment_id := l_comment_id;
--
-- Need to convert the boolean true/false value to varchar2 value because on
-- return back to Java program which won't recognize the value.
  IF l_name_combination_warning
  THEN
     p_name_combination_warning := 'Y';
  ELSE
     p_name_combination_warning := 'N';
  END IF;
--
  IF l_assign_payroll_warning
  THEN
     p_assign_payroll_warning := 'Y';
  ELSE
     p_assign_payroll_warning := 'N';
  END IF;
--
  IF l_orig_hire_warning
  THEN
     p_orig_hire_warning := 'Y';
  ELSE
     p_orig_hire_warning := 'N';
  END IF;
--
  p_object_version_number := l_ovn;
  p_employee_number := l_employee_number;
  hr_utility.set_location('Exiting:'||l_proc, 115);
  <<no_transaction>> -- label for GOTO
  null;


EXCEPTION
   WHEN g_data_error THEN
   hr_utility.set_location('Exception:g_data_error'||l_proc,560);
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => l_error_message);
-- applicant_hire
    if (g_applicant_hire) then
       rollback to applicant_hire;
       g_applicant_hire := false;
    end if;
--
   WHEN hr_process_person_ss.g_validate_basic_details_error THEN
   hr_utility.set_location('Exception:g_validate_basic_details_error'||l_proc,565);
   -- No need to call formatted_error_message, as the messages is already
   -- formatted.
   p_error_message := l_error_message;
-- applicant_hire
    if (g_applicant_hire) then
       rollback to applicant_hire;
       g_applicant_hire := false;
    end if;
--
   WHEN hr_perinfo_util_web.g_no_changes THEN
   hr_utility.set_location('Exception:g_no_changes'||l_proc,570);
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => l_error_message,
                      p_attr_name => 'Page',
                      p_app_short_name => 'PER',
                      p_message_name => 'HR_PERINFO_NO_CHANGES');
-- applicant_hire
    if (g_applicant_hire) then
       rollback to applicant_hire;
       g_applicant_hire := false;
    end if;
--
-- Bug Fix : 3048836
   WHEN hr_perinfo_util_web.g_past_effective_date THEN
   hr_utility.set_location('Exception:g_past_effective_date'||l_proc,575);
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => l_error_message);

   WHEN hr_perinfo_util_web.g_past_current_start_date THEN
   hr_utility.set_location('Exception:g_past_current_start_date'||l_proc,580);
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => l_error_message);

   WHEN OTHERS THEN
   hr_utility.set_location('Exception:Others'||l_proc,585);
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => l_error_message);
-- applicant_hire
    if (g_applicant_hire) then
       rollback to applicant_hire;
       g_applicant_hire := false;
    end if;
END update_person;

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
   )
IS

  CURSOR get_current_rec(
  p_eff_date  in date default trunc(sysdate)) is
  SELECT effective_start_date, object_version_number
  FROM   per_all_people_f
  WHERE  person_id = p_person_id
  AND    p_eff_date between effective_start_date
                      and     effective_end_date;

  l_current_rec          get_current_rec%rowtype;
  l_name_combination_warning      boolean default false;
  l_assign_payroll_warning        boolean default false;
  l_orig_hire_warning             boolean default false;
  l_ovn                           number default null;
  l_employee_number               per_all_people_f.employee_number%type
                                  default hr_api.g_varchar2;
  l_effective_start_date          date default null;
  l_effective_end_date            date default null;
  l_full_name                     per_all_people_f.full_name%type default null;
  l_comment_id                    per_all_people_f.comment_id%type default null;
  l_message_number VARCHAR2(10);
  l_proc   varchar2(72)  := g_package||'validate_basic_details';
--
--
BEGIN

  -- Validate that the effective_date entered is not less than the
  -- effective_start_date of the most current record.
  --
  hr_utility.set_location('Entering:& creating a Savepoint'||l_proc, 5);
  SAVEPOINT process_basic_details;
  --
  hr_utility.set_location('Opening & Fetching:get_current_rec'||l_proc,10);
  OPEN get_current_rec(p_eff_date=> p_effective_date);
  FETCH get_current_rec into l_current_rec;
  IF get_current_rec%NOTFOUND
  THEN
     CLOSE get_current_rec;
     raise g_data_error;
  ELSE
     CLOSE get_current_rec;
  END IF;

  l_ovn := p_object_version_number;

  IF p_effective_date < l_current_rec.effective_start_date
  THEN
     -- the error message should be like HR_PERINFO_INVALID_ED_01:
     -- "The effective date you have entered is invalid. You have either:<br>
     -- - entered an effective date before the hire date<br>
     -- entered an effective date before the date of the last person
     -- details change<br>
     -- <br>To correct the invalid entry either:<br>
     -- - enter an address after the hire date<br>
     -- - contact your HR department for a correction of the person
     --   details change.
     hr_utility.set_location('p_effective_date < l_current_rec.effective_start_date:'||l_proc,15);
     raise hr_process_person_ss.g_date_prior_to_cur_start_date;
  END IF;
  --
--


-- Fix 2091186
/*
	 hr_person_att.update_person gives error
	 THE MANDATORY COLUMN ATTRIBUTE<x> HAS NOT BEEN ASSIGNED A VALUE
	 when a segment in descriptive flex field is made as required.
	 The solution suggested is to add the descriptive flex is to
	 ignore validation using hr_dflex_utility.create_ignore_df_validation
	 please refer to bug for further details.
	 */

hr_person_info_util_ss.create_ignore_df_validation('PER_PERIODS_OF_SERVICE');


  hr_person_api.update_person (
     p_validate                    => false
    ,p_datetrack_update_mode       => p_attribute_update_mode
    ,p_effective_date              => p_effective_date
    ,p_person_id                   => p_person_id
    ,p_object_version_number       => l_ovn
    ,p_person_type_id              => p_person_type_id
    ,p_last_name                   => p_last_name
    ,p_applicant_number            => p_applicant_number
    ,p_comments                    => p_comments
    ,p_date_employee_data_verified => p_date_employee_data_verified
    ,p_original_date_of_hire       => p_original_date_of_hire
    ,p_date_of_birth               => p_date_of_birth
    ,p_town_of_birth               => p_town_of_birth
    ,p_region_of_birth             => p_region_of_birth
    ,p_country_of_birth            => p_country_of_birth
    ,p_global_person_id            => p_global_person_id
    ,p_email_address               => p_email_address
    ,p_employee_number             => l_employee_number
    ,p_npw_number                  => p_npw_number
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                  => p_first_name
    ,p_known_as                    => p_known_as
    ,p_marital_status              => p_marital_status
    ,p_middle_names                => p_middle_names
    ,p_nationality                 => p_nationality
    ,p_national_identifier         => p_national_identifier
    ,p_previous_last_name          => p_previous_last_name
    ,p_registered_disabled_flag    => p_registered_disabled_flag
    ,p_sex                         => p_sex
    ,p_title                       => p_title
    ,p_vendor_id                   => p_vendor_id
    ,p_work_telephone              => p_work_telephone
    ,p_suffix                      => p_suffix
    ,p_date_of_death               => p_date_of_death
    ,p_background_check_status     => p_background_check_status
    ,p_background_date_check       => p_background_date_check
    ,p_blood_type                  => p_blood_type
    ,p_correspondence_language     => p_correspondence_language
    ,p_fast_path_employee          => p_fast_path_employee
    ,p_fte_capacity                => p_fte_capacity
    ,p_hold_applicant_date_until   => p_hold_applicant_date_until
    ,p_honors                      => p_honors
    ,p_internal_location           => p_internal_location
    ,p_last_medical_test_by        => p_last_medical_test_by
    ,p_last_medical_test_date      => p_last_medical_test_date
    ,p_mailstop                    => p_mailstop
    ,p_office_number               => p_office_number
    ,p_on_military_service         => p_on_military_service
    ,p_pre_name_adjunct            => p_pre_name_adjunct
    ,p_projected_start_date        => p_projected_start_date
    ,p_rehire_authorizor           => p_rehire_authorizor
    ,p_rehire_recommendation       => p_rehire_recommendation
    ,p_resume_exists               => p_resume_exists
    ,p_resume_last_updated         => p_resume_last_updated
    ,p_second_passport_exists      => p_second_passport_exists
    ,p_student_status              => p_student_status
    ,p_work_schedule               => p_work_schedule
    ,p_rehire_reason               => p_rehire_reason
    ,p_benefit_group_id            => p_benefit_group_id
    ,p_receipt_of_death_cert_date  => p_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no        => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag       => p_coord_ben_no_cvg_flag
    ,p_uses_tobacco_flag           => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date         => p_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag      => p_dpdnt_vlntry_svce_flag
    ,p_adjusted_svc_date           => p_adjusted_svc_date
    ,p_attribute_category          => p_attribute_category
    ,p_attribute1                  => p_attribute1
    ,p_attribute2                  => p_attribute2
    ,p_attribute3                  => p_attribute3
    ,p_attribute4                  => p_attribute4
    ,p_attribute5                  => p_attribute5
    ,p_attribute6                  => p_attribute6
    ,p_attribute7                  => p_attribute7
    ,p_attribute8                  => p_attribute8
    ,p_attribute9                  => p_attribute9
    ,p_attribute10                 => p_attribute10
    ,p_attribute11                 => p_attribute11
    ,p_attribute12                 => p_attribute12
    ,p_attribute13                 => p_attribute13
    ,p_attribute14                 => p_attribute14
    ,p_attribute15                 => p_attribute15
    ,p_attribute16                 => p_attribute16
    ,p_attribute17                 => p_attribute17
    ,p_attribute18                 => p_attribute18
    ,p_attribute19                 => p_attribute19
    ,p_attribute20                 => p_attribute20
    ,p_attribute21                 => p_attribute21
    ,p_attribute22                 => p_attribute22
    ,p_attribute23                 => p_attribute23
    ,p_attribute24                 => p_attribute24
    ,p_attribute25                 => p_attribute25
    ,p_attribute26                 => p_attribute26
    ,p_attribute27                 => p_attribute27
    ,p_attribute28                 => p_attribute28
    ,p_attribute29                 => p_attribute29
    ,p_attribute30                 => p_attribute30
    ,p_per_information_category    => p_per_information_category
    ,p_per_information1            => p_per_information1
    ,p_per_information2            => p_per_information2
    ,p_per_information3            => p_per_information3
    ,p_per_information4            => p_per_information4
    ,p_per_information5            => p_per_information5
    ,p_per_information6            => p_per_information6
    ,p_per_information7            => p_per_information7
    ,p_per_information8            => p_per_information8
    ,p_per_information9            => p_per_information9
    ,p_per_information10           => p_per_information10
    ,p_per_information11           => p_per_information11
    ,p_per_information12           => p_per_information12
    ,p_per_information13           => p_per_information13
    ,p_per_information14           => p_per_information14
    ,p_per_information15           => p_per_information15
    ,p_per_information16           => p_per_information16
    ,p_per_information17           => p_per_information17
    ,p_per_information18           => p_per_information18
    ,p_per_information19           => p_per_information19
    ,p_per_information20           => p_per_information20
    ,p_per_information21           => p_per_information21
    ,p_per_information22           => p_per_information22
    ,p_per_information23           => p_per_information23
    ,p_per_information24           => p_per_information24
    ,p_per_information25           => p_per_information25
    ,p_per_information26           => p_per_information26
    ,p_per_information27           => p_per_information27
    ,p_per_information28           => p_per_information28
    ,p_per_information29           => p_per_information29
    ,p_per_information30           => p_per_information30
    ,p_effective_start_date        => l_effective_start_date
    ,p_effective_end_date          => l_effective_end_date
    ,p_full_name                   => l_full_name
    ,p_comment_id                  => l_comment_id
    ,p_name_combination_warning    => l_name_combination_warning
    ,p_assign_payroll_warning      => l_assign_payroll_warning
    ,p_orig_hire_warning           => l_orig_hire_warning);

--
hr_person_info_util_ss.remove_ignore_df_validation;
-- Fix 2091186 End.


  IF p_validate_mode
  THEN
     hr_utility.set_location('IF p_validate_mode:'||l_proc,20);
     p_full_name := l_full_name; -- Bug fix 2116170
     p_effective_start_date := l_effective_start_date;
     p_effective_end_date := l_effective_end_date;
     p_comment_id := l_comment_id;
-- Bug fix 2247108, always populate the warnings
     p_name_combination_warning := l_name_combination_warning;
-- if already issued assign payroll warning, then eat the warning
-- this time
     if(p_assign_payroll_warning) then
       p_assign_payroll_warning := false;
     else
       p_assign_payroll_warning := l_assign_payroll_warning;
     end if;
     p_orig_hire_warning := l_orig_hire_warning;
     ROLLBACK TO process_basic_details;
  ELSE
     hr_utility.set_location('!p_validate_mode:'||l_proc,25);
     p_effective_start_date := l_effective_start_date;
     p_effective_end_date := l_effective_end_date;
     p_full_name := l_full_name;
     p_comment_id := l_comment_id;
     p_name_combination_warning := l_name_combination_warning;
     p_assign_payroll_warning := l_assign_payroll_warning;
     p_orig_hire_warning := l_orig_hire_warning;
     p_object_version_number := l_ovn;
     p_employee_number := l_employee_number;
  END IF;
--

hr_utility.set_location('Exiting:'||l_proc, 30);
EXCEPTION

   WHEN hr_process_person_ss.g_date_prior_to_cur_start_date THEN
   hr_utility.set_location('Exception:g_date_prior_to_cur_start_date'||l_proc,555);
   ROLLBACK TO process_basic_details;
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => p_error_message,
                      p_attr_name => 'EffectiveStartDate',
                      p_app_short_name => 'PER',
                      p_message_name => 'HR_EARLIER_THAN_CUR_START_DT');
--
   WHEN g_data_error THEN
   hr_utility.set_location('Exception:g_data_error'||l_proc,560);
   ROLLBACK TO process_basic_details;
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => p_error_message);
--
   WHEN hr_utility.hr_error THEN
  	-- -------------------------------------------
   	-- an application error has been raised so we must
  	-- redisplay the web form to display the error
   	-- --------------------------------------------
   hr_utility.set_location('Exception:hr_utility.hr_error'||l_proc,565);
   ROLLBACK TO process_basic_details;
   hr_message.provide_error;
   l_message_number := hr_message.last_message_number;
   IF l_message_number = 'APP-7165' OR l_message_number = 'APP-7155' THEN
  --populate the p_error_message out variable
      p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                         p_error_message => p_error_message,
                         p_attr_name => 'Page',
                         p_app_short_name => 'PER',
                         p_message_name => 'HR_UPDATE_NOT_ALLOWED');
-- Bug Fix : 3048836
   ELSIF l_message_number = 'APP-7179' THEN
     hr_utility.set_message(800,'HR_PERINFO_PAST_EFFECTIVE_DATE');
     hr_utility.set_message_token('EFFECTIVE_DATE',
                                  get_max_effective_date(p_person_id));
     hr_utility.raise_error;

   ELSE
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => p_error_message);
   END IF;
--
   WHEN hr_perinfo_util_web.g_past_current_Start_date THEN
   hr_utility.set_location('Exception:g_past_current_Start_date'||l_proc,570);
   ROLLBACK TO process_basic_details;
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => p_error_message,
                      p_attr_name => 'EffectiveStartDate',
                      p_app_short_name => 'PER',
                      p_message_name => 'HR_PERINFO_INVALID_ED_01');
--
   WHEN hr_perinfo_util_web.g_past_effective_date THEN
   hr_utility.set_location('Exception:g_past_effective_date'||l_proc,575);
   ROLLBACK TO process_basic_details;
     hr_utility.set_message(800,'HR_PERINFO_PAST_EFFECTIVE_DATE');
     hr_utility.set_message_token('EFFECTIVE_DATE',
                                  get_max_effective_date(p_person_id));
     hr_utility.raise_error;
--
   WHEN hr_perinfo_util_web.g_no_changes THEN
   hr_utility.set_location('Exception:g_no_changes'||l_proc,580);
   ROLLBACK TO process_basic_details;
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => p_error_message,
                      p_attr_name => 'Page',
                      p_app_short_name => 'PER',
                      p_message_name => 'HR_PERINFO_NO_CHANGES');
--
   WHEN OTHERS THEN
   hr_utility.set_location('Exception:Others'||l_proc,585);
   ROLLBACK TO process_basic_details;
   p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => p_error_message);

END validate_basic_details;

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
   return boolean
   IS


  l_rec_changed                    boolean default null;
  l_cur_person_data                gc_get_cur_person_data%rowtype;
  l_proc   varchar2(72)  := g_package||'is_rec_changed';
--
BEGIN
  --
-- Bug Fix 3048836 : checking if the effective date entered by user <
-- hire date or the current record's start date.

        hr_utility.set_location('Entering:'||l_proc, 5);
        IF hr_perinfo_util_web.isDateLessThanCreationDate
			(p_date => p_effective_date
			,p_person_id => p_person_id) THEN
		-- The effective Date is less than the creation date of the
		-- Person.
		hr_utility.set_location('The EffDate<CreationDate of person :'||l_proc,10);
           RAISE hr_perinfo_util_web.g_past_effective_date;
	END IF;
	IF hr_perinfo_util_web.isLessThanCurrentStartDate
		(p_effective_date => p_effective_date
		,p_person_id => p_person_id
		,p_ovn => p_object_version_number) THEN
		hr_utility.set_location('The EffDate<StartDate of person :'||l_proc,15);
         RAISE hr_perinfo_util_web.g_past_current_start_date;
	END IF;


  hr_utility.set_location('Opening and Fetching gc_get_cur_person_data :'||l_proc,20);
  OPEN gc_get_cur_person_data(p_person_id => p_person_id,
                              p_eff_date=> p_effective_date);
  FETCH gc_get_cur_person_data into l_cur_person_data;
  IF gc_get_cur_person_data%NOTFOUND
  THEN
     CLOSE gc_get_cur_person_data;
     raise g_data_error;
  ELSE
     CLOSE gc_get_cur_person_data;
  END IF;
--
------------------------------------------------------------------------------
-- NOTE: We need to use nvl(xxx attribute name, hr_api.g_xxxx) because the
--       parameter coming in can be null.  If we do not use nvl, then it will
--       never be equal to the database null value if the parameter value is
--       also null.
------------------------------------------------------------------------------
  IF p_person_type_id <> hr_api.g_number OR p_person_type_id IS NULL
  THEN
     IF nvl(p_person_type_id, hr_api.g_number) <>
        nvl(l_cur_person_data.person_type_id, hr_api.g_number)
     THEN
        hr_utility.set_location('nvl(p_person_type_id, hr_api.g_number) <> nvl(l_cur_person_data.person_type_id, hr_api.g_number)'||l_proc,25);
        l_rec_changed := TRUE;
        hr_utility.set_location('GOing to <FINISH>'||l_proc,30);
        goto finish;
     END IF;
  END IF;
--
  IF p_last_name <> hr_api.g_varchar2 OR p_last_name IS NULL
  THEN
     IF nvl(p_last_name, hr_api.g_varchar2) <>
        nvl (l_cur_person_data.last_name, hr_api.g_varchar2)
     THEN
        hr_utility.set_location('nvl(p_last_name, hr_api.g_varchar2) <>nvl (l_cur_person_data.last_name, hr_api.g_varchar2)'||l_proc,35);
        hr_utility.set_location('GOing to <FINISH>'||l_proc,40);
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_applicant_number <> hr_api.g_varchar2 OR p_applicant_number IS NULL
  THEN
     IF nvl(p_applicant_number, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.applicant_number, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        hr_utility.set_location('nvl(p_applicant_number, hr_api.g_varchar2)<>nvl(l_cur_person_data.applicant_number, hr_api.g_varchar2)'||l_proc,45);
        hr_utility.set_location('GOing to <FINISH>'||l_proc,50);

        goto finish;
     END IF;
  END IF;
--
  IF p_comments <> hr_api.g_varchar2 OR p_comments IS NULL
  THEN
     IF nvl(p_comments, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.comment_text, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        hr_utility.set_location('nvl(p_comments, hr_api.g_varchar2) <>nvl(l_cur_person_data.comment_text, hr_api.g_varchar2)'||l_proc,55);
        hr_utility.set_location('GOing to <FINISH>'||l_proc,60);

        goto finish;
     END IF;
  END IF;
--
  IF p_date_employee_data_verified <> hr_api.g_date OR p_date_employee_data_verified IS NULL
  THEN
     IF nvl(p_date_employee_data_verified, hr_api.g_date) <>
        nvl(l_cur_person_data.date_employee_data_verified, hr_api.g_date)
     THEN

        hr_utility.set_location('GOing to <FINISH>'||l_proc,65);

        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_original_date_of_hire <> hr_api.g_date OR p_original_date_of_hire IS NULL
  THEN
     IF nvl(p_original_date_of_hire, hr_api.g_date) <>
        nvl(l_cur_person_data.original_date_of_hire, hr_api.g_date)
     THEN
        hr_utility.set_location('GOing to <FINISH>'||l_proc,70);
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_date_of_birth <> hr_api.g_date OR p_date_of_birth IS NULL
  THEN
     IF nvl(p_date_of_birth, hr_api.g_date) <>
        nvl(l_cur_person_data.date_of_birth, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
                hr_utility.set_location('Check DOB & , GOing to <FINISH>'||l_proc,65);
        goto finish;
     END IF;
  END IF;
--
  IF p_town_of_birth <> hr_api.g_varchar2 OR p_town_of_birth IS NULL
  THEN
     IF nvl(p_town_of_birth, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.town_of_birth, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        hr_utility.set_location('Check on Town of birth & GOing to <FINISH>'||l_proc,70);
        goto finish;
     END IF;
  END IF;
--
  IF p_region_of_birth <> hr_api.g_varchar2 OR p_region_of_birth IS NULL
  THEN
     IF nvl(p_region_of_birth, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.region_of_birth, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
                hr_utility.set_location('Check on Region  of birth & GOing to <FINISH>'||l_proc,75);
        goto finish;
     END IF;
  END IF;
--
  IF p_country_of_birth <> hr_api.g_varchar2 OR p_country_of_birth IS NULL
  THEN
     IF nvl(p_country_of_birth, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.country_of_birth, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        hr_utility.set_location('Check on Country  of birth & GOing to <FINISH>'||l_proc,80);
        goto finish;
     END IF;
  END IF;
--
-- Global_Person_ID is defined as varchar2 data type on the database.
  IF p_global_person_id <> hr_api.g_varchar2 OR p_global_person_id IS NULL
  THEN
     IF nvl(p_global_person_id, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.global_person_id, hr_api.g_varchar2)
     THEN
        hr_utility.set_location('Check on Global person id & GOing to <FINISH>'||l_proc,80);
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_email_address <> hr_api.g_varchar2 OR p_email_address IS NULL
  THEN
     IF nvl(p_email_address, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.email_address, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
                hr_utility.set_location('Check on Email id id & GOing to <FINISH>'||l_proc,85);
        goto finish;
     END IF;
  END IF;
--
  IF p_employee_number <> hr_api.g_varchar2 OR p_employee_number IS NULL
  THEN
     IF nvl(p_employee_number, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.employee_number, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        hr_utility.set_location('Check on empno & GOing to <FINISH>'||l_proc,90);
        goto finish;
     END IF;
  END IF;
--
  IF p_npw_number <> hr_api.g_varchar2 OR p_npw_number IS NULL
  THEN
     IF nvl(p_npw_number, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.npw_number, hr_api.g_varchar2)
     THEN
          hr_utility.set_location('Check on npwno & GOing to <FINISH>'||l_proc,95);
         l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_expense_check_send_to_addres <> hr_api.g_varchar2 OR p_expense_check_send_to_addres IS NULL
  THEN
     IF nvl(p_expense_check_send_to_addres, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.expense_check_send_to_address, hr_api.g_varchar2)
     THEN
        hr_utility.set_location('Check on to address & GOing to <FINISH>'||l_proc,100);
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_first_name <> hr_api.g_varchar2 OR p_first_name IS NULL
  THEN
     IF nvl(p_first_name, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.first_name, hr_api.g_varchar2)
     THEN
        hr_utility.set_location('Check on firstname & GOing to <FINISH>'||l_proc,105);
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_known_as <> hr_api.g_varchar2 OR p_known_as IS NULL
  THEN
     IF nvl(p_known_as, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.known_as, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_marital_status <> hr_api.g_varchar2 OR p_marital_status IS NULL
  THEN
     IF nvl(p_marital_status, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.marital_status, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_middle_names <> hr_api.g_varchar2 OR p_middle_names IS NULL
  THEN
     IF nvl(p_middle_names, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.middle_names, hr_api.g_varchar2)
     THEN
         hr_utility.set_location('Check on middlename & GOing to <FINISH>'||l_proc,110);
               l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_nationality <> hr_api.g_varchar2 OR p_nationality IS NULL
  THEN
     IF nvl(p_nationality, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.nationality, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_national_identifier <> hr_api.g_varchar2 OR p_national_identifier IS NULL
  THEN
     IF nvl(p_national_identifier, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.national_identifier, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_previous_last_name <> hr_api.g_varchar2 OR p_previous_last_name IS NULL
  THEN
     IF nvl(p_previous_last_name, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.previous_last_name, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_registered_disabled_flag <> hr_api.g_varchar2 OR p_registered_disabled_flag IS NULL
  THEN
     IF nvl(p_registered_disabled_flag, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.registered_disabled_flag, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_sex <> hr_api.g_varchar2 OR p_sex IS NULL
  THEN
     IF nvl(p_sex, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.sex, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_title <> hr_api.g_varchar2 OR p_title IS NULL
  THEN
     IF nvl(p_title, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.title, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_vendor_id <> hr_api.g_number OR p_vendor_id IS NULL
  THEN
     IF nvl(p_vendor_id, hr_api.g_number) <>
        nvl(l_cur_person_data.vendor_id, hr_api.g_number)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_work_telephone <> hr_api.g_varchar2 OR p_work_telephone IS NULL
  THEN
     IF nvl(p_work_telephone, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.work_telephone, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_suffix <> hr_api.g_varchar2 OR p_suffix IS NULL
  THEN
     IF nvl(p_suffix, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.suffix, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_date_of_death <> hr_api.g_date OR p_date_of_death IS NULL
  THEN
     IF nvl(p_date_of_death, hr_api.g_date) <>
        nvl(l_cur_person_data.date_of_death, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_background_check_status <> hr_api.g_varchar2 OR p_background_check_status IS NULL
  THEN
     IF nvl(p_background_check_status, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.background_check_status, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_background_date_check <> hr_api.g_date OR p_background_date_check IS NULL
  THEN
     IF nvl(p_background_date_check, hr_api.g_date) <>
        nvl(l_cur_person_data.background_date_check, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_blood_type <> hr_api.g_varchar2 OR p_blood_type IS NULL
  THEN
     IF nvl(p_blood_type, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.blood_type, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_correspondence_language <> hr_api.g_varchar2 OR p_correspondence_language IS NULL
  THEN
     IF nvl(p_correspondence_language, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.correspondence_language, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_fast_path_employee <> hr_api.g_varchar2 OR p_fast_path_employee IS NULL
  THEN
     IF nvl(p_fast_path_employee, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.fast_path_employee, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_fte_capacity <> hr_api.g_number OR p_fte_capacity IS NULL
  THEN
     IF nvl(p_fte_capacity, hr_api.g_number) <>
        nvl(l_cur_person_data.fte_capacity, hr_api.g_number)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_hold_applicant_date_until <> hr_api.g_date OR p_hold_applicant_date_until IS NULL
  THEN
     IF nvl(p_hold_applicant_date_until, hr_api.g_date) <>
        nvl(l_cur_person_data.hold_applicant_date_until, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_honors <> hr_api.g_varchar2 OR p_honors IS NULL
  THEN
     IF nvl(p_honors, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.honors, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_internal_location <> hr_api.g_varchar2 OR p_internal_location IS NULL
  THEN
     IF nvl(p_internal_location, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.internal_location, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_last_medical_test_by <> hr_api.g_varchar2 OR p_last_medical_test_by IS NULL
  THEN
     IF nvl(p_last_medical_test_by, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.last_medical_test_by, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_last_medical_test_date <> hr_api.g_date OR p_last_medical_test_date IS NULL
  THEN
     IF nvl(p_last_medical_test_date, hr_api.g_date) <>
        nvl(l_cur_person_data.last_medical_test_date, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_mailstop <> hr_api.g_varchar2 OR p_mailstop IS NULL
  THEN
     IF nvl(p_mailstop, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.mailstop, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_office_number <> hr_api.g_varchar2 OR p_office_number IS NULL
  THEN
     IF nvl(p_office_number, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.office_number, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_on_military_service <> hr_api.g_varchar2 OR p_on_military_service IS NULL
  THEN
     IF nvl(p_on_military_service, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.on_military_service, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_pre_name_adjunct <> hr_api.g_varchar2 OR p_pre_name_adjunct IS NULL
  THEN
     IF nvl(p_pre_name_adjunct, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.pre_name_adjunct, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_projected_start_date <> hr_api.g_date OR p_projected_start_date IS NULL
  THEN
     IF nvl(p_projected_start_date, hr_api.g_date) <>
        nvl(l_cur_person_data.projected_start_date, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--_
--
  IF p_rehire_authorizor <> hr_api.g_varchar2 OR p_rehire_authorizor IS NULL
  THEN
     IF nvl(p_rehire_authorizor, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.rehire_authorizor, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_rehire_recommendation <> hr_api.g_varchar2 OR p_rehire_recommendation IS NULL
  THEN
     IF nvl(p_rehire_recommendation, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.rehire_recommendation, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_rehire_reason <> hr_api.g_varchar2 OR p_rehire_reason IS NULL
  THEN
     IF nvl(p_rehire_reason, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.rehire_reason, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_benefit_group_id <> hr_api.g_number OR p_benefit_group_id IS NULL
  THEN
     IF nvl(p_benefit_group_id, hr_api.g_number) <>
        nvl(l_cur_person_data.benefit_group_id, hr_api.g_number)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_receipt_of_death_cert_date <> hr_api.g_date OR p_receipt_of_death_cert_date IS NULL
  THEN
     IF nvl(p_receipt_of_death_cert_date, hr_api.g_date) <>
        nvl(l_cur_person_data.receipt_of_death_cert_date, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_coord_ben_med_pln_no <> hr_api.g_varchar2 OR p_coord_ben_med_pln_no IS NULL
  THEN
     IF nvl(p_coord_ben_med_pln_no, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.coord_ben_med_pln_no, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_coord_ben_no_cvg_flag <> hr_api.g_varchar2 OR p_coord_ben_no_cvg_flag IS NULL
  THEN
     IF nvl(p_coord_ben_no_cvg_flag, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.coord_ben_no_cvg_flag, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_uses_tobacco_flag <> hr_api.g_varchar2 OR p_uses_tobacco_flag IS NULL
  THEN
     IF nvl(p_uses_tobacco_flag, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.uses_tobacco_flag, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_dpdnt_adoption_date <> hr_api.g_date OR p_dpdnt_adoption_date IS NULL
  THEN
     IF nvl(p_dpdnt_adoption_date, hr_api.g_date) <>
        nvl(l_cur_person_data.dpdnt_adoption_date, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_dpdnt_vlntry_svce_flag <> hr_api.g_varchar2 OR p_dpdnt_vlntry_svce_flag IS NULL
  THEN
     IF nvl(p_dpdnt_vlntry_svce_flag, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.dpdnt_vlntry_svce_flag, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--

  IF p_adjusted_svc_date <> hr_api.g_date
  THEN
     IF nvl(p_adjusted_svc_date, hr_api.g_date) <>
        nvl(l_cur_person_data.adjusted_svc_date, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;


--
  IF p_resume_exists <> hr_api.g_varchar2 OR p_resume_exists IS NULL
  THEN
     IF nvl(p_resume_exists, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.resume_exists, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_resume_last_updated <> hr_api.g_date OR p_resume_last_updated IS NULL
  THEN
     IF nvl(p_resume_last_updated, hr_api.g_date) <>
        nvl(l_cur_person_data.resume_last_updated, hr_api.g_date)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_second_passport_exists <> hr_api.g_varchar2 OR p_second_passport_exists IS NULL
  THEN
     IF nvl(p_second_passport_exists, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.second_passport_exists, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_student_status <> hr_api.g_varchar2 OR p_student_status IS NULL
  THEN
     IF nvl(p_student_status, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.student_status, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_work_schedule <> hr_api.g_varchar2 OR p_work_schedule IS NULL
  THEN
     IF nvl(p_work_schedule, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.work_schedule, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute_category <> hr_api.g_varchar2 OR p_attribute_category IS NULL
  THEN
     IF nvl(p_attribute_category, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute_category, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute1 <> hr_api.g_varchar2 OR p_attribute1 IS NULL
  THEN
     IF nvl(p_attribute1, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute1, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute2 <> hr_api.g_varchar2 OR p_attribute2 IS NULL
  THEN
     IF nvl(p_attribute2, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute2, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute3 <> hr_api.g_varchar2 OR p_attribute3 IS NULL
  THEN
     IF nvl(p_attribute3, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute3, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute4 <> hr_api.g_varchar2 OR p_attribute4 IS NULL
  THEN
     IF nvl(p_attribute4, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute4, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute5 <> hr_api.g_varchar2 OR p_attribute5 IS NULL
  THEN
     IF nvl(p_attribute5, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute5, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute6 <> hr_api.g_varchar2 OR p_attribute6 IS NULL
  THEN
     IF nvl(p_attribute6, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute6, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute7 <> hr_api.g_varchar2 OR p_attribute7 IS NULL
  THEN
     IF nvl(p_attribute7, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute7, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute8 <> hr_api.g_varchar2 OR p_attribute8 IS NULL
  THEN
     IF nvl(p_attribute8, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute8, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute9 <> hr_api.g_varchar2 OR p_attribute9 IS NULL
  THEN
     IF nvl(p_attribute9, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute9, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute10 <> hr_api.g_varchar2 OR p_attribute10 IS NULL
  THEN
     IF nvl(p_attribute10, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute10, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute11 <> hr_api.g_varchar2 OR p_attribute11 IS NULL
  THEN
     IF nvl(p_attribute11, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute11, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute12 <> hr_api.g_varchar2 OR p_attribute12 IS NULL
  THEN
     IF nvl(p_attribute12, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute12, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute13 <> hr_api.g_varchar2 OR p_attribute13 IS NULL
  THEN
     IF nvl(p_attribute13, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute13, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute14 <> hr_api.g_varchar2 OR p_attribute14 IS NULL
  THEN
     IF nvl(p_attribute14, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute14, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute15 <> hr_api.g_varchar2 OR p_attribute15 IS NULL
  THEN
     IF nvl(p_attribute15, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute15, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute16 <> hr_api.g_varchar2 OR p_attribute16 IS NULL
  THEN
     IF nvl(p_attribute16, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute16, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute17 <> hr_api.g_varchar2 OR p_attribute17 IS NULL
  THEN
     IF nvl(p_attribute17, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute17, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute18 <> hr_api.g_varchar2 OR p_attribute18 IS NULL
  THEN
     IF nvl(p_attribute18, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute18, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute19 <> hr_api.g_varchar2 OR p_attribute19 IS NULL
  THEN
     IF nvl(p_attribute19, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute19, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute20 <> hr_api.g_varchar2 OR p_attribute20 IS NULL
  THEN
     IF nvl(p_attribute20, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute20, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute21 <> hr_api.g_varchar2 OR p_attribute21 IS NULL
  THEN
     IF nvl(p_attribute21, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute21, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute22 <> hr_api.g_varchar2 OR p_attribute22 IS NULL
  THEN
     IF nvl(p_attribute22, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute22, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute23 <> hr_api.g_varchar2 OR p_attribute23 IS NULL
  THEN
     IF nvl(p_attribute23, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute23, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute24 <> hr_api.g_varchar2 OR p_attribute24 IS NULL
  THEN
     IF nvl(p_attribute24, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute24, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute25 <> hr_api.g_varchar2 OR p_attribute25 IS NULL
  THEN
     IF nvl(p_attribute25, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute25, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute26 <> hr_api.g_varchar2 OR p_attribute26 IS NULL
  THEN
     IF nvl(p_attribute26, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute26, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute27 <> hr_api.g_varchar2 OR p_attribute27 IS NULL
  THEN
     IF nvl(p_attribute27, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute27, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute28 <> hr_api.g_varchar2 OR p_attribute28 IS NULL
  THEN
     IF nvl(p_attribute28, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute28, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute29 <> hr_api.g_varchar2 OR p_attribute29 IS NULL
  THEN
     IF nvl(p_attribute29, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute29, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_attribute30 <> hr_api.g_varchar2 OR p_attribute30 IS NULL
  THEN
     IF nvl(p_attribute30, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.attribute30, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information_category <> hr_api.g_varchar2 OR p_per_information_category IS NULL
  THEN
     IF nvl(p_per_information_category, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information_category, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information1 <> hr_api.g_varchar2 OR p_per_information1 IS NULL
  THEN
     IF nvl(p_per_information1, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information1, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information2 <> hr_api.g_varchar2 OR p_per_information2 IS NULL
  THEN
     IF nvl(p_per_information2, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information2, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information3 <> hr_api.g_varchar2 OR p_per_information3 IS NULL
  THEN
     IF nvl(p_per_information3, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information3, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information4 <> hr_api.g_varchar2 OR p_per_information4 IS NULL
  THEN
     IF nvl(p_per_information4, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information4, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information5 <> hr_api.g_varchar2 OR p_per_information5 IS NULL
  THEN
     IF nvl(p_per_information5, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information5, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information6 <> hr_api.g_varchar2 OR p_per_information6 IS NULL
  THEN
     IF nvl(p_per_information6, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information6, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information7 <> hr_api.g_varchar2 OR p_per_information7 IS NULL
  THEN
     IF nvl(p_per_information7, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information7, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information8 <> hr_api.g_varchar2 OR p_per_information8 IS NULL
  THEN
     IF nvl(p_per_information8, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information8, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information9 <> hr_api.g_varchar2 OR p_per_information9 IS NULL
  THEN
     IF nvl(p_per_information9, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information9, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information10 <> hr_api.g_varchar2 OR p_per_information10 IS NULL
  THEN
     IF nvl(p_per_information10, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information10, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information11 <> hr_api.g_varchar2 OR p_per_information11 IS NULL
  THEN
     IF nvl(p_per_information11, hr_api.g_varchar2) <>
     nvl(l_cur_person_data.per_information11, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information12 <> hr_api.g_varchar2 OR p_per_information12 IS NULL
  THEN
     IF nvl(p_per_information12, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information12, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information13 <> hr_api.g_varchar2 OR p_per_information13 IS NULL
  THEN
     IF nvl(p_per_information13, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information13, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information14 <> hr_api.g_varchar2 OR p_per_information14 IS NULL
  THEN
     IF nvl(p_per_information14, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information14, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information15 <> hr_api.g_varchar2 OR p_per_information15 IS NULL
  THEN
     IF nvl(p_per_information15, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information15, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information16 <> hr_api.g_varchar2 OR p_per_information16 IS NULL
  THEN
     IF nvl(p_per_information16, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information16, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information17 <> hr_api.g_varchar2 OR p_per_information17 IS NULL
  THEN
     IF nvl(p_per_information17, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information17, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information18 <> hr_api.g_varchar2 OR p_per_information18 IS NULL
  THEN
     IF nvl(p_per_information18, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information18, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information19 <> hr_api.g_varchar2 OR p_per_information19 IS NULL
  THEN
     IF nvl(p_per_information19, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information19, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information20 <> hr_api.g_varchar2 OR p_per_information20 IS NULL
  THEN
     IF nvl(p_per_information20, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information20, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information21 <> hr_api.g_varchar2 OR p_per_information21 IS NULL
  THEN
     IF nvl(p_per_information21, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information21, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information22 <> hr_api.g_varchar2 OR p_per_information22 IS NULL
  THEN
     IF nvl(p_per_information22, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information22, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information23 <> hr_api.g_varchar2 OR p_per_information23 IS NULL
  THEN
     IF nvl(p_per_information23, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information23, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information24 <> hr_api.g_varchar2 OR p_per_information24 IS NULL
  THEN
     IF nvl(p_per_information24, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information24, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information25 <> hr_api.g_varchar2 OR p_per_information25 IS NULL
  THEN
     IF nvl(p_per_information25, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information25, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information26 <> hr_api.g_varchar2 OR p_per_information26 IS NULL
  THEN
     IF nvl(p_per_information26, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information26, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information27 <> hr_api.g_varchar2 OR p_per_information27 IS NULL
  THEN
     IF nvl(p_per_information27, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information27, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information28 <> hr_api.g_varchar2 OR p_per_information28 IS NULL
  THEN
     IF nvl(p_per_information28, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information28, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information29 <> hr_api.g_varchar2 OR p_per_information29 IS NULL
  THEN
     IF nvl(p_per_information29, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information29, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;
--
  IF p_per_information30 <> hr_api.g_varchar2 OR p_per_information30 IS NULL
  THEN
     IF nvl(p_per_information30, hr_api.g_varchar2) <>
        nvl(l_cur_person_data.per_information30, hr_api.g_varchar2)
     THEN
        l_rec_changed := TRUE;
        goto finish;
     END IF;
  END IF;

  hr_utility.set_location('Exiting:'||l_proc, 200);
--
--
<<finish>>
  RETURN l_rec_changed;


EXCEPTION
  When hr_perinfo_util_web.g_past_effective_date then
  hr_utility.set_location('Exception:past_effective_date'||l_proc,555);
  hr_utility.set_message(applid=> 800,l_message_name=>'HR_PERINFO_PAST_EFFECTIVE_DATE');
  hr_utility.set_message_token('EFFECTIVE_DATE',
                                  get_max_effective_date(p_person_id));
  raise hr_perinfo_util_web.g_past_effective_date;

    When hr_perinfo_util_web.g_past_current_start_date then
  hr_utility.set_location('Exception:past_current_start_date'||l_proc,565);
  hr_utility.set_message(applid=> 800,l_message_name=>'HR_PERINFO_PAST_EFFECTIVE_DATE');
  hr_utility.set_message_token('EFFECTIVE_DATE',
                                  get_max_effective_date(p_person_id));
   raise hr_perinfo_util_web.g_past_current_start_date;


  When g_data_error THEN

  hr_utility.set_location('Exception:g_data_error'||l_proc,575);
       raise;

  When others THEN
  hr_utility.set_location('Exception:Others'||l_proc,585);
       raise;

END is_rec_changed;

--
--
-- ---------------------------------------------------------------------------
-- ----------------------------- < process_api > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
-- ---------------------------------------------------------------------------
PROCEDURE process_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
)
IS
--
  l_effective_start_date             date default null;
  l_effective_end_date               date default null;
  l_full_name                        per_all_people_f.full_name%type;
  l_comment_id                       per_all_people_f.comment_id%type;
  l_name_combination_warning         boolean default null;
  l_assign_payroll_warning           boolean default null;
  l_orig_hire_warning                boolean default null;
  l_employee_number                  per_all_people_f.employee_number%type
                                     := hr_api.g_varchar2;
  l_npw_number                       per_all_people_f.npw_number%type
                                     := hr_api.g_varchar2;
  l_ovn                              number default null;
  l_person_id                        per_all_people_f.person_id%type
                                     default null;

--Start Registration

  l_assignment_id                    number default null;
  l_povn                             number default null;
  l_aovn                             number default null;
  l_dovn                             number default null;
  l_assignment_sequence              number default null;
  -- Bug# 2693580 : changing the l_assignment_number from number to per_assignments_f.assignment_number%type
  l_assignment_number                per_assignments_f.assignment_number%type default null;
  l_assignment_extra_info_id         number;
  l_aei_object_version_number        number;
  l_flow_name                        varchar2(30) default null;
  l_asg_effective_end_date           date;
  l_asg_effective_start_date         date;
  prflvalue                          varchar2(2000) default null;
  l_item_type                        wf_items.item_type%type default null;
  l_item_key                         wf_items.item_key%type default null;
  l_transaction_step                 number default null;
  l_user_id               number;
  l_user_name             fnd_user.user_name%TYPE;
  l_user_pswd             fnd_user.encrypted_user_password%TYPE;
  l_pswd_hint             fnd_user.description%TYPE;
  l_api_error             boolean;
  l_respons_id            number ;
  l_respons_appl_id       number ;
  l_owner                 number ;
  l_session_number        number ;
  l_start_date            date;
  l_end_date              date;
  l_last_logon_date       date;
  l_password_date         date;
  l_password_accesses_left                 number ;
  l_password_lifespan_accesses             number ;
  l_password_lifespan_days                 number ;
  l_employee_id                            number ;
  l_customer_id                            number ;
  l_supplier_id                            number ;
  l_business_group_id                      number ;
  l_email_address                          varchar2(240);
  l_fax                                    varchar2(80);

--End Registration

-- variables and cursor for applicant_hire
 -- l_original_date_of_hire date default null;  --bug 4416684
  l_per_information7 hr_api_transaction_values.varchar2_value%type default null;
  l_per_object_version_number number;
  l_per_effective_start_date date;
  l_per_effective_end_date date;
  l_unaccepted_asg_del_warning boolean;
  l_per_assign_payroll_warning boolean;
  l_current_applicant_flag  per_all_people_f.current_applicant_flag%type;
  l_current_employee_flag  per_all_people_f.current_employee_flag%type;
  l_current_npw_flag per_all_people_f.current_npw_flag%type;
  l_effective_date      date;
  l_appl_assignment_id number;
  l_person_type_id per_all_people_f.person_type_id%type;
  l_sys_person_type  per_person_types.system_person_type%type;
  l_proc   varchar2(72)  := g_package||'process_api';
  l_business_grp_Id number;
  login_person_id number;

  CURSOR csr_leg_code(l_organization_id in number) is
    SELECT  oi.org_information9 legislation_code
    FROM hr_organization_information oi
    WHERE oi.organization_id = l_organization_id
    AND oi.org_information_context = 'Business Group Information';

   TYPE asgn_pay_rec_rectype IS RECORD (assignment_id number, payroll_id number);
   TYPE asg_pay_tabtype IS TABLE OF asgn_pay_rec_rectype INDEX BY BINARY_INTEGER;
   asg_pay_rec asg_pay_tabtype;
   count1 number := 1;

  cursor check_payroll is
    select asg.assignment_id,
               asg.payroll_id,   asg.soft_coding_keyflex_id
      from per_all_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = l_person_id
       and l_effective_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status         = 'ACCEPTED'
	   	 and asg.assignment_type = 'A'
       and asg.payroll_id is not null
       order by asg.assignment_id;

  dummy_payroll_id                           number;
  l_is_payroll_upd   boolean := false;
  l_leg_code_row   csr_leg_code%rowtype;
  l_overwrite_primary	varchar2(2);
  l_oversubscribed_vacancy_id	number;

  l_orgid number;
  l_ex_emp varchar2(10) default null;
  l_rehire_reason varchar2(250);
  l_asg_rec		per_all_assignments_f%rowtype;

BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  if (p_effective_date is not null) then
    l_effective_date:= to_date(p_effective_date,g_date_format);
    hr_utility.set_location('p_effective_date is not null:'||l_proc,10);
  else
   hr_utility.set_location('p_effective_date is  null:'||l_proc,15);
   l_effective_date:= to_date(
      hr_transaction_ss.get_wf_effective_date
        (p_transaction_step_id => p_transaction_step_id),g_date_format);
  end if;

--
  SAVEPOINT process_basic_details;

--
-- Get the person_id first.  If it is null, that means we'll create a new
-- employee.  If it is not null, we will do an update to the person record.

  hr_utility.set_location('Calls to hr_transation_api:'||l_proc,20);
  l_person_id := hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PERSON_ID');
--
  l_employee_number := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_EMPLOYEE_NUMBER');

  l_overwrite_primary := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_ASGN_CHANGE_MODE');
--
  l_ovn := hr_transaction_api.get_number_value
             (p_transaction_step_id => p_transaction_step_id
             ,p_name => 'P_OBJECT_VERSION_NUMBER');
--

  l_appl_assignment_id := hr_transaction_api.get_number_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_APPL_ASSIGNMENT_ID');
--
  l_person_type_id := hr_transaction_api.get_number_value
                       (p_transaction_step_id => p_transaction_step_id
                       ,p_name => 'P_PERSON_TYPE_ID');
--
  l_business_grp_Id :=hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BUSINESS_GROUP_ID');
--
  l_per_information7    :=  hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION7');

 if l_business_grp_Id is not null  then
       open csr_leg_code(l_business_grp_Id);
       fetch csr_leg_code into l_leg_code_row;
       close csr_leg_code;
       l_orgid := l_business_grp_Id;
       if hr_multi_tenancy_pkg.is_multi_tenant_system then
          hr_utility.set_location('Multi tenancy changes '||l_proc,21);

          if l_person_id is not null
            and l_person_id <> -1 then
             hr_utility.set_location('Person Id: '|| l_person_id,22);

             l_orgid := hr_multi_tenancy_pkg.get_org_id_for_person(l_person_id);
          else
             hr_utility.set_location('Business group Id: '|| l_business_grp_Id,23);

             select CREATOR_PERSON_ID into login_person_id
               from HR_API_TRANSACTION_STEPS
              where TRANSACTION_STEP_ID = p_transaction_step_id;

             hr_utility.set_location('Creator Person Id: '|| login_person_id,24);
             l_orgid := hr_multi_tenancy_pkg.get_org_id_for_person(login_person_id, l_business_grp_Id);
          end if;
       end if;
       hr_util_misc_ss.set_sys_ctx(l_leg_code_row.legislation_code, l_orgid);
 end if;

  IF l_person_id IS NOT NULL
  THEN

  -- In case of hiring an applicant, we need to call the hr_applicant_api to
  -- make the applicant an employee and then update the BD record

   hr_utility.set_location('Opening & Fetching gc_get_current_applicant_flag:'||l_proc,25);
   open gc_get_current_applicant_flag(l_person_id, l_effective_date);
   fetch gc_get_current_applicant_flag into
   l_current_applicant_flag, l_current_employee_flag, l_current_npw_flag;
   close gc_get_current_applicant_flag;

   --code for rehire api start
   l_item_type := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_ITEM_TYPE');

   l_item_key := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_ITEM_KEY');

   l_ex_emp := wf_engine.GetItemAttrText(l_item_type,l_item_key,'HR_FLOW_IDENTIFIER',true);

   if nvl(l_ex_emp,'N') = 'EX_EMP' then
   	l_rehire_reason := hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REHIRE_REASON');

        hr_employee_api.re_hire_ex_employee
  		(p_validate                     => FALSE
  		,p_hire_date                    => l_effective_date
  		,p_person_id                    => l_person_id
		,p_per_object_version_number    => l_ovn
		,p_person_type_id               => l_person_type_id
		,p_rehire_reason                => l_rehire_reason
		,p_assignment_id                => l_assignment_id
		,p_asg_object_version_number    => l_aovn
		,p_per_effective_start_date     => l_per_effective_start_date
		,p_per_effective_end_date       => l_per_effective_end_date
		,p_assignment_sequence          => l_assignment_sequence
		,p_assignment_number            => l_assignment_number
		,p_assign_payroll_warning       => l_assign_payroll_warning
		);

	g_session_id := ICX_SEC.G_SESSION_ID;
   	g_person_id := l_person_id;
   	g_assignment_id := l_assignment_id;
   	g_asg_object_version_number := l_aovn;

   end if;
   --code for rehire api ends
   --call the hr_applicant_api.hire_applicant in validate mode
   if (l_current_applicant_flag = 'Y'
     AND nvl(l_current_employee_flag, 'N') <>  'Y'
     AND nvl(l_current_npw_flag,'N')       <>  'Y') then

   -- set the global variable to true which will be used by
   -- assignment steps
     g_is_applicant := true;
     g_session_id := ICX_SEC.G_SESSION_ID;

     if hr_new_user_reg_ss.g_ignore_emp_generation = 'YES' then
   --
   -- Special case for SSHR if the profile is set
   -- as we need to make sure that the generation controls table is not
   -- locked.
   --

       hr_utility.set_location('hr_new_user_reg_ss.g_ignore_emp_generation =YES:'||l_proc,35);
       fnd_profile.put('PER_SSHR_NO_EMPNUM_GENERATION','Y');

     end if;

    -- l_original_date_of_hire := hr_transaction_api.get_date_value        --bug 4416684
	--		(p_transaction_step_id => p_transaction_step_id
	--		 ,p_name => 'P_ORIGINAL_DATE_OF_HIRE');

    l_per_information7  :=  nvl(hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION7'),hr_api.g_varchar2);

   for c in check_payroll loop
      asg_pay_rec(count1).assignment_id := c.assignment_id;
      asg_pay_rec(count1).payroll_id := c.payroll_id;
      count1 := count1 +1;
      process_applicant(
        p_effective_date  =>    l_effective_date
       ,p_person_id     =>  l_person_id
       ,p_assignment_id     =>  c.assignment_id
       ,p_soft_coding_keyflex_id => c.soft_coding_keyflex_id
       ,p_business_group_id =>  l_business_grp_Id
       ,p_is_payroll_upd => l_is_payroll_upd);
   end loop;

     hr_applicant_api.hire_applicant(
      p_validate => p_validate
     ,p_hire_date => l_effective_date
     ,p_person_id => l_person_id
     ,p_per_object_version_number => l_ovn
     ,p_assignment_id => l_appl_assignment_id
     ,p_employee_number => l_employee_number
     ,p_per_effective_start_date => l_per_effective_start_date
     ,p_per_effective_end_date => l_per_effective_end_date
     ,p_unaccepted_asg_del_warning  => l_unaccepted_asg_del_warning
     ,p_assign_payroll_warning => l_assign_payroll_warning
     ,p_source => true);
    -- ,p_original_date_of_hire => l_original_date_of_hire); --bug 4416684, pass original_date_of_hire

if l_is_payroll_upd then
   FOR i IN asg_pay_rec.FIRST..asg_pay_rec.LAST LOOP
      update per_all_assignments_f set payroll_id=asg_pay_rec(i).payroll_id
      where assignment_id = asg_pay_rec(i).assignment_id and
      l_effective_date - 1  between effective_start_date and effective_end_date;

      update per_all_assignments_f set payroll_id=asg_pay_rec(i).payroll_id
      where assignment_id = asg_pay_rec(i).assignment_id and
      assignment_id <> l_appl_assignment_id and
      l_effective_date  between effective_start_date and effective_end_date;
   END LOOP;
end if;

  -- get the person_type_id in the rollback segment
     open gc_get_new_appl_person_type(l_person_id, l_effective_date);
     fetch gc_get_new_appl_person_type into l_person_type_id;
     close gc_get_new_appl_person_type;

    if hr_new_user_reg_ss.g_ignore_emp_generation = 'YES' then
       hr_utility.set_location('hr_new_user_reg_ss.g_ignore_emp_generation = YES:'||l_proc,40);
       hr_new_user_reg_ss.g_ignore_emp_generation := 'NO';

       fnd_profile.put('PER_SSHR_NO_EMPNUM_GENERATION','N');
    end if;

   end if;

 if (l_overwrite_primary = 'Y' OR l_overwrite_primary = 'N') then
   if (l_current_applicant_flag = 'Y' AND l_current_employee_flag = 'Y') then
     g_is_applicant := true;
     g_session_id := ICX_SEC.G_SESSION_ID;
     hr_employee_applicant_api.hire_employee_applicant
	  (p_validate          =>	p_validate,
   	   p_hire_date         =>       l_effective_date,
	   p_asg_rec      =>	l_asg_rec,
	   p_person_id         => 	l_person_id,
   	   p_primary_assignment_id     => l_appl_assignment_id,
	   p_person_type_id    =>	l_person_type_id,
   	   p_overwrite_primary     =>   l_overwrite_primary,
	   p_per_object_version_number	=> l_ovn,
   	   p_per_effective_start_date   =>  l_per_effective_start_date,
	   p_per_effective_end_date     =>  l_per_effective_end_date,
   	   p_unaccepted_asg_del_warning =>  l_unaccepted_asg_del_warning,
	   p_assign_payroll_warning     =>  l_assign_payroll_warning,
           	   p_oversubscribed_vacancy_id  =>  l_oversubscribed_vacancy_id,
	   p_called_from => 'SSHR'
          	   );
    end if;
 end if;
-- Fix bug :2091186

    hr_person_info_util_ss.create_ignore_df_validation('PER_PERIODS_OF_SERVICE');

    ---------------------------------------------------------------------------
    -- Bug 1937643 Fix Begins - 08/04/2002
    -- With the PTU model, the per_all_people_f.person_type_id stores only the
    -- default user flavor of the system_person_type.  The true user flavor
    -- for the system_person_type is stored in per_person_type_usages_f table.
    -- Since the current Personal Information Basic Details region and the
    -- New Hire page does not allow a user to choose any user flavor, so we'll
    -- zap the p_person_type_id to hr_api.g_number value when it is not an
    -- applicant when calling the hr_person_api.update_person. That way, the api
    -- will understand that the person_type is not changed and will not update
    -- the person_type_id in per_person_type_usages_f table as is.  If we pass
    -- the per_all_people_f.person_type_id to the api, the person_type_id in
    -- per_person_type_usages_f table will be updated with that value which will
    -- overwrite the true user flavor of the system person type with the
    -- default user flavor person type.  This may not be desirable.
    -- When we allow a user to select user flavors of person type in New Hire
    -- or Basic Details page, the code to pass hr_api.g_number in
    -- p_person_type_id for non-applicant needs to change.
    ---------------------------------------------------------------------------

    IF (l_current_applicant_flag = 'Y'
        AND nvl(l_current_employee_flag, 'N') <>  'Y')
    THEN
       hr_utility.set_location('l_current_applicant_flag=Y:'||l_proc,45);
       NULL;
    ELSE
       l_person_type_id := hr_api.g_number;
    END IF;

    -- Bug 1937643 Fix Ends - 08/04/2002


    hr_person_api.update_person(
     p_validate                => p_validate
    ,p_effective_date          => l_effective_date
    ,p_datetrack_update_mode   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE_UPDATE_MODE')
    ,p_person_id               => l_person_id
    ,p_object_version_number   => l_ovn
    ,p_person_type_id          => l_person_type_id
    ,p_last_name               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_LAST_NAME')
    ,p_applicant_number        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_APPLICANT_NUMBER')
    ,p_comments                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COMMENTS')
    ,p_date_employee_data_verified => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_EMPLOYEE_DATA_VERIFIED')
   -- bug 4416684 pass original_date_of_hire only if it is not null
    ,p_original_date_of_hire   => nvl(hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ORIGINAL_DATE_OF_HIRE'),hr_api.g_date)
    ,p_date_of_birth           => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_OF_BIRTH')
    ,p_town_of_birth           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TOWN_OF_BIRTH')
    ,p_region_of_birth         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGION_OF_BIRTH')
    ,p_country_of_birth        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COUNTRY_OF_BIRTH')
    ,p_global_person_id        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_GLOBAL_PERSON_ID')
    ,p_employee_number         => l_employee_number
    ,p_npw_number              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NPW_NUMBER')
    ,p_email_address           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_EMAIL_ADDRESS')
    ,p_expense_check_send_to_addres => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_EXPENSE_CHECK_SEND_TO_ADDRES')
    ,p_first_name              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_FIRST_NAME')
    ,p_known_as                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_KNOWN_AS')
    ,p_marital_status          => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_MARITAL_STATUS')
    ,p_middle_names             => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_MIDDLE_NAMES')
    ,p_nationality              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONALITY')
    ,p_national_identifier      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONAL_IDENTIFIER')
    ,p_previous_last_name       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PREVIOUS_LAST_NAME')
    ,p_registered_disabled_flag => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGISTERED_DISABLED_FLAG')
    ,p_sex                      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SEX')
    ,p_title                    => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TITLE')
    ,p_vendor_id                => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_VENDOR_ID')
    ,p_work_telephone           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_WORK_TELEPHONE')
    ,p_suffix                   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SUFFIX')
    ,p_date_of_death            => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_OF_DEATH')
    ,p_background_check_status  => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BACKGROUND_CHECK_STATUS')
    ,p_background_date_check    => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BACKGROUND_DATE_CHECK')
    ,p_blood_type               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BLOOD_TYPE')
    ,p_correspondence_language  => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_CORRESPONDENCE_LANGUAGE')
    ,p_fast_path_employee       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_FAST_PATH_EMPLOYEE')
    ,p_fte_capacity             => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_FTE_CAPACITY')
    ,p_hold_applicant_date_until => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_HOLD_APPLICANT_DATE_UNTIL')
    ,p_honors                   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_HONORS')
    ,p_internal_location        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_INTERNAL_LOCATION')
    ,p_last_medical_test_by     => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_LAST_MEDICAL_TEST_BY')
    ,p_last_medical_test_date   => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_LAST_MEDICAL_TEST_DATE')
    ,p_mailstop                 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_MAILSTOP')
    ,p_office_number            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_OFFICE_NUMBER')
    ,p_on_military_service      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ON_MILITARY_SERVICE')
    ,p_pre_name_adjunct         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PRE_NAME_ADJUNCT')
    ,p_projected_start_date     => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PROJECTED_START_DATE')
    ,p_rehire_authorizor        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REHIRE_AUTHORIZOR')
    ,p_rehire_recommendation    => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REHIRE_RECOMMENDATION')
    ,p_resume_exists            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_RESUME_EXISTS')
    ,p_resume_last_updated      => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_RESUME_LAST_UPDATED')
    ,p_second_passport_exists   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SECOND_PASSPORT_EXISTS')
    ,p_student_status           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_STUDENT_STATUS')
    ,p_work_schedule            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_WORK_SCHEDULE')
    ,p_rehire_reason            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REHIRE_REASON')
    ,p_benefit_group_id         => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BENEFIT_GROUP_ID')
    ,p_receipt_of_death_cert_date => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_RECEIPT_OF_DEATH_CERT_DATE')
    ,p_coord_ben_med_pln_no     => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COORD_BEN_MED_PLN_NO')
    ,p_coord_ben_no_cvg_flag    => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COORD_BEN_NO_CVG_FLAG')
    ,p_uses_tobacco_flag        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_USES_TOBACCO_FLAG')
    ,p_dpdnt_adoption_date      => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DPDNT_ADOPTION_DATE')
    ,p_dpdnt_vlntry_svce_flag   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DPDNT_VLNTRY_SVCE_FLAG')

    ,p_adjusted_svc_date        => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ADJUSTED_SVC_DATE')
    ,p_attribute_category       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE_CATEGORY')
    ,p_attribute1               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE1')
    ,p_attribute2               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE2')
    ,p_attribute3               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE3')
    ,p_attribute4               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE4')
    ,p_attribute5               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE5')
    ,p_attribute6               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE6')
    ,p_attribute7               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE7')
    ,p_attribute8               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE8')
    ,p_attribute9               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE9')
    ,p_attribute10              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE10')
    ,p_attribute11              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE11')
    ,p_attribute12              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE12')
    ,p_attribute13              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE13')
    ,p_attribute14              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE14')
    ,p_attribute15              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE15')
    ,p_attribute16              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE16')
    ,p_attribute17              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE17')
    ,p_attribute18              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE18')
    ,p_attribute19              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE19')
    ,p_attribute20              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE20')
    ,p_attribute21              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE21')
    ,p_attribute22              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE22')
    ,p_attribute23              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE23')
    ,p_attribute24              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE24')
    ,p_attribute25              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE25')
    ,p_attribute26              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE26')
    ,p_attribute27              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE27')
    ,p_attribute28              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE28')
    ,p_attribute29              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE29')
    ,p_attribute30              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE30')
    ,p_per_information_category => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION_CATEGORY')
    ,p_per_information1         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION1')
    ,p_per_information2         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION2')
    ,p_per_information3         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION3')
    ,p_per_information4         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION4')
    ,p_per_information5         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION5')
    ,p_per_information6         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION6')
    ,p_per_information7         => l_per_information7
    ,p_per_information8         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION8')
    ,p_per_information9         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION9')
    ,p_per_information10        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION10')
    ,p_per_information11        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION11')
    ,p_per_information12        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION12')
    ,p_per_information13        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION13')
    ,p_per_information14        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION14')
    ,p_per_information15        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION15')
    ,p_per_information16        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION16')
    ,p_per_information17        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION17')
    ,p_per_information18        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION18')
    ,p_per_information19        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION19')
    ,p_per_information20        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION20')
    ,p_per_information21        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION21')
    ,p_per_information22        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION22')
    ,p_per_information23        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION23')
    ,p_per_information24        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION24')
    ,p_per_information25        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION25')
    ,p_per_information26        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION26')
    ,p_per_information27        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION27')
    ,p_per_information28        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION28')
    ,p_per_information29        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION29')
    ,p_per_information30        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION30')
    ,p_effective_start_date      => l_effective_start_Date
    ,p_effective_end_date        => l_effective_end_Date
    ,p_full_name                 => l_full_name
    ,p_comment_id                => l_comment_id
    ,p_name_combination_warning  => l_name_combination_warning
    ,p_assign_payroll_warning    => l_assign_payroll_warning
    ,p_orig_hire_warning         => l_orig_hire_warning
    );
hr_person_info_util_ss.remove_ignore_df_validation;

-- Fix bug 2091186 ends.
  ELSE
     -- for future use, put in code for creating an employee
  ---Start Registration

--code for insert begin   -- for future use, put in code for creating an employee
  --Added Insert By VVK
--
--start cobra codes
  l_flow_name := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_FLOW_NAME');

  l_item_type := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_ITEM_TYPE');

  l_item_key := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_ITEM_KEY');
--
  if l_flow_name = 'Insert' then
--end cobra codes

  if hr_new_user_reg_ss.g_ignore_emp_generation = 'YES' then
   --
   -- Special case for SSHR if the profile is set
   -- as we need to make sure that the generation controls table is not
   -- locked.
   --

   hr_utility.set_location('l_flow_name = Insert:'||l_proc,100);
   fnd_profile.put('PER_SSHR_NO_EMPNUM_GENERATION','Y');

  end if;

   open gc_get_sys_person_type(l_person_type_id);
   fetch gc_get_sys_person_type into l_sys_person_type;
   close gc_get_sys_person_type;

   if (l_sys_person_type = 'CWK') then
     l_npw_number := hr_transaction_api.get_varchar2_value
                       (p_transaction_step_id => p_transaction_step_id
                       ,p_name => 'P_NPW_NUMBER');
     hr_contingent_worker_api.create_cwk
       (p_validate                => p_validate
       ,p_start_date              => l_effective_date
       ,p_business_group_id       => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BUSINESS_GROUP_ID')
       ,p_last_name               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_LAST_NAME')
       ,p_person_type_id          => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PERSON_TYPE_ID')
       ,p_npw_number              => l_npw_number
       ,p_background_check_status => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BACKGROUND_CHECK_STATUS')
       ,p_background_date_check   => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BACKGROUND_DATE_CHECK')
       ,p_blood_type              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BLOOD_TYPE')
       ,p_comments                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_COMMENTS')
       ,p_correspondence_language => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_CORRESPONDENCE_LANGUAGE')
       ,p_country_of_birth        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COUNTRY_OF_BIRTH')
       ,p_date_of_birth           => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_OF_BIRTH')
       ,p_date_of_death           => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_OF_DEATH')
       ,p_dpdnt_adoption_date     => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DPDNT_ADOPTION_DATE')
       ,p_dpdnt_vlntry_svce_flag  => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DPDNT_VLNTRY_SVCE_FLAG')
       ,p_email_address           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_EMAIL_ADDRESS')
       ,p_first_name              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_FIRST_NAME')
       ,p_fte_capacity            => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_FTE_CAPACITY')
       ,p_honors                  => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_HONORS')
       ,p_internal_location       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_INTERNAL_LOCATION')
       ,p_known_as                => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                    ,p_name => 'P_KNOWN_AS')
       ,p_last_medical_test_by    => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_LAST_MEDICAL_TEST_BY')
       ,p_last_medical_test_date  => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_LAST_MEDICAL_TEST_DATE')
       ,p_mailstop                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_MAILSTOP')
       ,p_marital_status          => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_MARITAL_STATUS')
       ,p_middle_names            => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_MIDDLE_NAMES')
       ,p_national_identifier     => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONAL_IDENTIFIER')
       ,p_nationality             => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONALITY')
       ,p_office_number           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_OFFICE_NUMBER')
       ,p_on_military_service     => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ON_MILITARY_SERVICE')
       ,p_party_id                => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PARTY_ID')
       ,p_pre_name_adjunct        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PRE_NAME_ADJUNCT')
       ,p_previous_last_name      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PREVIOUS_LAST_NAME')
       --,p_projected_placement_end =>
       ,p_receipt_of_death_cert_date => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_RECEIPT_OF_DEATH_CERT_DATE')
       ,p_region_of_birth         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGION_OF_BIRTH')
       ,p_registered_disabled_flag => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGISTERED_DISABLED_FLAG')
       ,p_resume_exists            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_RESUME_EXISTS')
       ,p_resume_last_updated      => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_RESUME_LAST_UPDATED')
       ,p_second_passport_exists   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SECOND_PASSPORT_EXISTS')
       ,p_sex                      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SEX')
       ,p_student_status           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_STUDENT_STATUS')
       ,p_suffix                   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SUFFIX')
       ,p_title                    => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TITLE')
       ,p_town_of_birth            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TOWN_OF_BIRTH')
       ,p_uses_tobacco_flag        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_USES_TOBACCO_FLAG')
       ,p_vendor_id                => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_VENDOR_ID')
       ,p_work_schedule            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_WORK_SCHEDULE')
       ,p_work_telephone           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_WORK_TELEPHONE')
       --,p_exp_check_send_to_address =>
       --,p_hold_applicant_date_until =>
       ,p_date_employee_data_verified => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_EMPLOYEE_DATA_VERIFIED')
       ,p_benefit_group_id          => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BENEFIT_GROUP_ID')
       ,p_coord_ben_med_pln_no      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COORD_BEN_MED_PLN_NO')
       ,p_coord_ben_no_cvg_flag     => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COORD_BEN_NO_CVG_FLAG')
       ,p_original_date_of_hire     => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ORIGINAL_DATE_OF_HIRE')
       ,p_attribute_category        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE_CATEGORY')
       ,p_attribute1                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE1')
       ,p_attribute2                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE2')
       ,p_attribute3                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE3')
       ,p_attribute4                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE4')
       ,p_attribute5                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE5')
       ,p_attribute6                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE6')
       ,p_attribute7                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE7')
       ,p_attribute8                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE8')
       ,p_attribute9                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE9')
       ,p_attribute10               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE10')
       ,p_attribute11               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE11')
       ,p_attribute12               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE12')
       ,p_attribute13               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE13')
       ,p_attribute14               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE14')
       ,p_attribute15               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE15')
       ,p_attribute16               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE16')
       ,p_attribute17               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE17')
       ,p_attribute18               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE18')
       ,p_attribute19               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE19')
       ,p_attribute20               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE20')
       ,p_attribute21               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE21')
       ,p_attribute22               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE22')
       ,p_attribute23               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE23')
       ,p_attribute24               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE24')
       ,p_attribute25               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE25')
       ,p_attribute26               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE26')
       ,p_attribute27               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE27')
       ,p_attribute28               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE28')
       ,p_attribute29               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE29')
       ,p_attribute30               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE30')
       ,p_per_information_category => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION_CATEGORY')
       ,p_per_information1         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION1')
       ,p_per_information2         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION2')
       ,p_per_information3         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION3')
       ,p_per_information4         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION4')
       ,p_per_information5         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION5')
       ,p_per_information6         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION6')
       ,p_per_information7         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION7')
       ,p_per_information8         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION8')
       ,p_per_information9         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION9')
       ,p_per_information10        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION10')
       ,p_per_information11        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION11')
       ,p_per_information12        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION12')
       ,p_per_information13        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION13')
       ,p_per_information14        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION14')
       ,p_per_information15        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION15')
       ,p_per_information16        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION16')
       ,p_per_information17        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION17')
       ,p_per_information18        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION18')
       ,p_per_information19        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION19')
       ,p_per_information20        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION20')
       ,p_per_information21        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION21')
       ,p_per_information22        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION22')
       ,p_per_information23        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION23')
       ,p_per_information24        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION24')
       ,p_per_information25        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION25')
       ,p_per_information26        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION26')
       ,p_per_information27        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION27')
       ,p_per_information28        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION28')
       ,p_per_information29        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION29')
       ,p_per_information30        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION30')
       ,p_person_id                => l_person_id
       ,p_per_object_version_number => l_povn
       ,p_per_effective_start_date  => l_effective_start_Date
       ,p_per_effective_end_date    => l_effective_end_Date
       ,p_pdp_object_version_number => l_dovn
       ,p_full_name                 => l_full_name
       ,p_comment_id                => l_comment_id
       ,p_assignment_id             => l_assignment_id
       ,p_asg_object_version_number => l_aovn
       ,p_assignment_sequence       => l_assignment_sequence
       ,p_assignment_number         => l_assignment_number
       ,p_name_combination_warning  => l_name_combination_warning
       );
   else
    hr_employee_api.create_employee(
     p_validate                => p_validate
    ,p_hire_date               => l_effective_date
    ,p_business_group_id       => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BUSINESS_GROUP_ID')
    ,p_last_name               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_LAST_NAME')
    ,p_sex                      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SEX')
    ,p_person_type_id          => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PERSON_TYPE_ID')
    ,p_per_comments                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_COMMENTS')
    ,p_date_employee_data_verified => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_EMPLOYEE_DATA_VERIFIED')
    ,p_date_of_birth           => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_OF_BIRTH')
    ,p_email_address           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_EMAIL_ADDRESS')
    ,p_employee_number         => l_employee_number
    ,p_expense_check_send_to_addres => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_EXPENSE_CHECK_SEND_TO_ADDRES')
    ,p_first_name              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_FIRST_NAME')
    ,p_known_as                => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_KNOWN_AS')
    ,p_marital_status          => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_MARITAL_STATUS')
    ,p_middle_names             => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_MIDDLE_NAMES')
    ,p_nationality              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONALITY')
    ,p_national_identifier      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONAL_IDENTIFIER')
    ,p_previous_last_name       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PREVIOUS_LAST_NAME')
    ,p_registered_disabled_flag => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGISTERED_DISABLED_FLAG')
    ,p_title                    => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TITLE')
    ,p_vendor_id                => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_VENDOR_ID')
    ,p_work_telephone           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_WORK_TELEPHONE')
    ,p_attribute_category       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE_CATEGORY')
    ,p_attribute1               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE1')
    ,p_attribute2               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE2')
    ,p_attribute3               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE3')
    ,p_attribute4               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE4')
    ,p_attribute5               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE5')
    ,p_attribute6               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE6')
    ,p_attribute7               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE7')
    ,p_attribute8               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE8')
    ,p_attribute9               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE9')
    ,p_attribute10              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE10')
    ,p_attribute11              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE11')
    ,p_attribute12              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE12')
    ,p_attribute13              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE13')
    ,p_attribute14              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE14')
    ,p_attribute15              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE15')
    ,p_attribute16              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE16')
    ,p_attribute17              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE17')
    ,p_attribute18              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE18')
    ,p_attribute19              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE19')
    ,p_attribute20              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE20')
    ,p_attribute21              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE21')
    ,p_attribute22              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE22')
    ,p_attribute23              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE23')
    ,p_attribute24              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE24')
    ,p_attribute25              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE25')
    ,p_attribute26              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE26')
    ,p_attribute27              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE27')
    ,p_attribute28              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE28')
    ,p_attribute29              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE29')
    ,p_attribute30              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE30')
    ,p_per_information_category => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION_CATEGORY')
    ,p_per_information1         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION1')
    ,p_per_information2         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION2')
    ,p_per_information3         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION3')
    ,p_per_information4         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION4')
    ,p_per_information5         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION5')
    ,p_per_information6         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION6')
    ,p_per_information7         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION7')
    ,p_per_information8         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION8')
    ,p_per_information9         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION9')
    ,p_per_information10        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION10')
    ,p_per_information11        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION11')
    ,p_per_information12        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION12')
    ,p_per_information13        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION13')
    ,p_per_information14        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION14')
    ,p_per_information15        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION15')
    ,p_per_information16        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION16')
    ,p_per_information17        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION17')
    ,p_per_information18        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION18')
    ,p_per_information19        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION19')
    ,p_per_information20        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION20')
    ,p_per_information21        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION21')
    ,p_per_information22        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION22')
    ,p_per_information23        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION23')
    ,p_per_information24        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION24')
    ,p_per_information25        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION25')
    ,p_per_information26        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION26')
    ,p_per_information27        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION27')
    ,p_per_information28        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION28')
    ,p_per_information29        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION29')
    ,p_per_information30        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION30')
    ,p_date_of_death            => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_OF_DEATH')
    ,p_background_check_status  => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BACKGROUND_CHECK_STATUS')
    ,p_background_date_check    => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BACKGROUND_DATE_CHECK')
    ,p_blood_type               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BLOOD_TYPE')
    ,p_correspondence_language  => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_CORRESPONDENCE_LANGUAGE')
    ,p_fast_path_employee       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_FAST_PATH_EMPLOYEE')
    ,p_fte_capacity             => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_FTE_CAPACITY')
    ,p_honors                   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_HONORS')
    ,p_internal_location        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_INTERNAL_LOCATION')
    ,p_last_medical_test_by     => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_LAST_MEDICAL_TEST_BY')
    ,p_last_medical_test_date   => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_LAST_MEDICAL_TEST_DATE')
    ,p_mailstop                 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_MAILSTOP')
    ,p_office_number            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_OFFICE_NUMBER')
    ,p_on_military_service      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ON_MILITARY_SERVICE')
    ,p_pre_name_adjunct         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PRE_NAME_ADJUNCT')
    ,p_projected_start_date     => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PROJECTED_START_DATE')
    ,p_resume_exists            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_RESUME_EXISTS')
    ,p_resume_last_updated      => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_RESUME_LAST_UPDATED')
    ,p_second_passport_exists   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SECOND_PASSPORT_EXISTS')
    ,p_student_status           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_STUDENT_STATUS')
    ,p_work_schedule            => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_WORK_SCHEDULE')
    ,p_suffix                   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SUFFIX')
    ,p_benefit_group_id         => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_BENEFIT_GROUP_ID')
    ,p_receipt_of_death_cert_date => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_RECEIPT_OF_DEATH_CERT_DATE')
    ,p_coord_ben_med_pln_no     => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COORD_BEN_MED_PLN_NO')
    ,p_coord_ben_no_cvg_flag    => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COORD_BEN_NO_CVG_FLAG')
    ,p_uses_tobacco_flag        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_USES_TOBACCO_FLAG')
    ,p_dpdnt_adoption_date      => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DPDNT_ADOPTION_DATE')
    ,p_dpdnt_vlntry_svce_flag   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DPDNT_VLNTRY_SVCE_FLAG')
    ,p_original_date_of_hire   => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ORIGINAL_DATE_OF_HIRE')
    ,p_adjusted_svc_date       => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ADJUSTED_SVC_DATE')
    ,p_town_of_birth           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TOWN_OF_BIRTH')
    ,p_region_of_birth         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGION_OF_BIRTH')
    ,p_country_of_birth        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COUNTRY_OF_BIRTH')
    ,p_global_person_id        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_GLOBAL_PERSON_ID')
    ,p_party_id                => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PARTY_ID')
    ,p_person_id                   => l_person_id
    ,p_assignment_id               => l_assignment_id
    ,p_per_object_version_number   => l_povn
    ,p_asg_object_version_number   => l_aovn
    ,p_per_effective_start_date    => l_effective_start_Date
    ,p_per_effective_end_date      => l_effective_end_Date
    ,p_full_name                   => l_full_name
    ,p_per_comment_id              => l_comment_id
    ,p_assignment_sequence         => l_assignment_sequence
    ,p_assignment_number           => l_assignment_number
    ,p_name_combination_warning    => l_name_combination_warning
    ,p_assign_payroll_warning      => l_assign_payroll_warning
    ,p_orig_hire_warning           => l_orig_hire_warning
    );
  end if;
--
--Added by VVK

    if hr_new_user_reg_ss.g_ignore_emp_generation = 'YES' then
       hr_new_user_reg_ss.g_ignore_emp_generation := 'NO';

       fnd_profile.put('PER_SSHR_NO_EMPNUM_GENERATION','N');
    end if;

ELSIF l_flow_name = 'Cobra' THEN
   hr_utility.set_location('l_flow_name = Cobra:'||l_proc,100);
   hr_contact_api.create_person
    (p_validate                => p_validate
    ,p_start_date              => sysdate
    ,p_business_group_id       => hr_transaction_api.get_number_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_BUSINESS_GROUP_ID')
    ,p_last_name               => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_LAST_NAME')
    ,p_sex                     => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_SEX')
    ,p_person_type_id          => null
    ,p_comments                => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_PER_COMMENTS')
    ,p_date_employee_data_verified => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_EMPLOYEE_DATA_VERIFIED')
    ,p_date_of_birth            => hr_transaction_api.get_date_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_DATE_OF_BIRTH')
    ,p_email_address            => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_EMAIL_ADDRESS')
    ,p_expense_check_send_to_addres => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_EXPENSE_CHECK_SEND_TO_ADDRES')
    ,p_first_name               => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_FIRST_NAME')
    ,p_known_as                 => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                    ,p_name => 'P_KNOWN_AS')
    ,p_marital_status           => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_MARITAL_STATUS')
    ,p_middle_names             => hr_transaction_api.get_varchar2_value
                              (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_MIDDLE_NAMES')
    ,p_nationality              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONALITY')
    ,p_national_identifier      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONAL_IDENTIFIER')
    ,p_previous_last_name       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PREVIOUS_LAST_NAME')
    ,p_registered_disabled_flag => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGISTERED_DISABLED_FLAG')
    ,p_title                    => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TITLE')
    ,p_vendor_id                => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_VENDOR_ID')
    ,p_work_telephone           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_WORK_TELEPHONE')
    ,p_attribute_category       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE_CATEGORY')
    ,p_attribute1               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE1')
    ,p_attribute2               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE2')
    ,p_attribute3               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE3')
    ,p_attribute4               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE4')
    ,p_attribute5               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE5')
    ,p_attribute6               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE6')
    ,p_attribute7               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE7')
    ,p_attribute8               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE8')
    ,p_attribute9               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE9')
    ,p_attribute10              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE10')
    ,p_attribute11              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE11')
    ,p_attribute12              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE12')
    ,p_attribute13              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE13')
    ,p_attribute14              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE14')
    ,p_attribute15              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE15')
    ,p_attribute16              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE16')
    ,p_attribute17              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE17')
    ,p_attribute18              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE18')
    ,p_attribute19              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE19')
    ,p_attribute20              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE20')
    ,p_attribute21              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE21')
    ,p_attribute22              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE22')
    ,p_attribute23              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE23')
    ,p_attribute24              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE24')
    ,p_attribute25              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE25')
    ,p_attribute26              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE26')
    ,p_attribute27              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE27')
    ,p_attribute28              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE28')
    ,p_attribute29              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE29')
    ,p_attribute30              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE30')
    ,p_per_information_category => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION_CATEGORY')
    ,p_per_information1         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION1')
    ,p_per_information2         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION2')
    ,p_per_information3         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION3')
    ,p_per_information4         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION4')
    ,p_per_information5         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION5')
    ,p_per_information6         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION6')
    ,p_per_information7         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION7')
    ,p_per_information8         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION8')
    ,p_per_information9         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION9')
    ,p_per_information10        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION10')
    ,p_per_information11        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION11')

    ,p_per_information12        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION12')
    ,p_per_information13        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION13')
    ,p_per_information14        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION14')
    ,p_per_information15        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION15')
    ,p_per_information16        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION16')
    ,p_per_information17        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION17')
    ,p_per_information18        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION18')
    ,p_per_information19        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION19')
    ,p_per_information20        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION20')
    ,p_per_information21        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION21')
    ,p_per_information22        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION22')
    ,p_per_information23        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION23')
    ,p_per_information24        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION24')
    ,p_per_information25        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION25')
    ,p_per_information26        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION26')
    ,p_per_information27        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION27')
    ,p_per_information28        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION28')
    ,p_per_information29        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION29')
    ,p_per_information30        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION30')
    ,p_correspondence_language  => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_CORRESPONDENCE_LANGUAGE')
    ,p_honors                   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_HONORS')
    ,p_pre_name_adjunct         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PRE_NAME_ADJUNCT')
    ,p_suffix                   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SUFFIX')
    ,p_town_of_birth           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TOWN_OF_BIRTH')
    ,p_region_of_birth         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGION_OF_BIRTH')
    ,p_country_of_birth        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COUNTRY_OF_BIRTH')
    ,p_global_person_id        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_GLOBAL_PERSON_ID')
    ,p_person_id               => l_person_id
    ,p_object_version_number   => l_povn
    ,p_effective_start_date    => l_effective_start_Date
    ,p_effective_end_date      => l_effective_end_Date
    ,p_full_name               => l_full_name
    ,p_comment_id              => l_comment_id
    ,p_name_combination_warning=> l_name_combination_warning
    ,p_orig_hire_warning       => l_orig_hire_warning
    );

   /*prflvalue := fnd_profile.value('BEN_USER_TO_ORG_LINK');

   ben_assignment_api.create_ben_asg
        (p_validate                      => p_validate
                                     --in boolean  default false
         ,p_event_mode                   => false
         ,p_effective_date               => trunc(sysdate)
         ,p_person_id                    => l_person_id
         ,p_organization_id              =>
               nvl(prflvalue,hr_transaction_api.get_number_value
                               (p_transaction_step_id => p_transaction_step_id
                               ,p_name => 'P_BUSINESS_GROUP_ID'))
         ,p_assignment_status_type_id    => 1
         ,p_assignment_id                => l_assignment_id  --   out number
         ,p_object_version_number        => l_aovn ---   out nocopy number
         ,p_effective_start_date         =>
                               l_asg_effective_start_date   --   out date
         ,p_effective_end_date           => l_asg_effective_end_date  --out date
         ,p_assignment_extra_info_id     => l_assignment_extra_info_id
         ,p_aei_object_version_number    => l_aei_object_version_number
         );*/
 END IF;
-- end cobra codes
--
   l_transaction_step := to_number(wf_engine.GetItemAttrText
                    (itemtype   => l_item_type,
                     itemkey    => l_item_key,
                     aname      =>'USER_TRANSACTION_STEP'));
   if l_transaction_step is not null then
   hr_utility.set_location('l_transaction_step is not null then'||l_proc,105);
      ben_process_user_ss_api.get_user_data_from_tt(
           p_transaction_step_id          => l_transaction_step
          ,p_user_name                    => l_user_name
          ,p_user_pswd                    => l_user_pswd
          ,p_pswd_hint                    => l_pswd_hint
          ,p_owner                        => l_owner
          ,p_session_number               => l_session_number
          ,p_start_date                   => l_start_date
          ,p_end_date                     => l_end_date
          ,p_last_logon_date              => l_last_logon_date
          ,p_password_date                => l_password_date
          ,p_password_accesses_left       => l_password_accesses_left
          ,p_password_lifespan_accesses   => l_password_lifespan_accesses
          ,p_password_lifespan_days       => l_password_lifespan_days
          ,p_employee_id                  => l_employee_id
          ,p_email_address                => l_email_address
          ,p_fax                          => l_fax
          ,p_customer_id                  => l_customer_id
          ,p_supplier_id                  => l_supplier_id
          ,p_business_group_id            => l_business_group_id
          ,p_respons_id                   => l_respons_id
          ,p_respons_appl_id              => l_respons_appl_id
          );

      l_user_pswd := wf_engine.GetItemAttrText
                    (itemtype   => l_item_type,
                     itemkey    => l_item_key,
                     aname      =>'USER_ACCOUNT_INFO');

      wf_engine.SetItemAttrText (itemtype => l_item_type,
                           itemkey  => l_item_key,
                           aname    => 'USER_ACCOUNT_INFO',
                           avalue   => null);
      ben_process_user_ss_api.create_user_details(
           p_validate                     => false
          ,p_user_name                    => l_user_name
          ,p_owner                        => l_owner
          ,p_unencrypted_password         => trim(l_user_pswd)
          ,p_session_number               => l_session_number
          ,p_start_date                   => l_start_date
          ,p_end_date                     => l_end_date
          ,p_last_logon_date              => l_last_logon_date
          ,p_description                  => l_pswd_hint
          ,p_password_date                => l_password_date
          ,p_password_accesses_left       => l_password_accesses_left
          ,p_password_lifespan_accesses   => l_password_lifespan_accesses
          ,p_password_lifespan_days       => l_password_lifespan_days
          ,p_employee_id                  => l_person_id
          ,p_email_address                => l_email_address
          ,p_fax                          => l_fax
          ,p_customer_id                  => l_customer_id
          ,p_supplier_id                  => l_supplier_id
          ,p_business_group_id            => l_business_group_id
          ,p_responsibility_id            => l_respons_id
          ,p_respons_application_id       => l_respons_appl_id
          ,p_api_error                    => l_api_error
          ,p_user_id                      => l_user_id
          );
   end if;
--ADDED BY VVK
   --code for insert end  null;
   g_session_id := ICX_SEC.G_SESSION_ID;
   g_person_id := l_person_id;
   g_assignment_id := l_assignment_id;
   g_asg_object_version_number := l_aovn;
--   hr_utility.set_location('Venkat g_person_id =' || g_person_id, 8888);
---End Registration
  END IF;

  fnd_profile.put('PER_PERSON_ID', l_person_id);
  fnd_profile.put('PER_BUSINESS_GROUP_ID', l_business_grp_Id);

--
--
  IF l_assign_payroll_warning THEN
     -- ------------------------------------------------------------
     -- The assign payroll warning has been set so we must set the
     -- error so we can retrieve the text using fnd_message.get
     -- -------------------------------------------------------------
     -- as of now, 09/07/00, we don't know how to handle warnings yet. So, we
     -- just don't do anything.
     null;
  END IF;
--
--
  IF p_validate = true THEN
   hr_utility.set_location('p_validate = true THEN'||l_proc,115);
     ROLLBACK TO process_basic_details;
  END IF;
--
--
EXCEPTION
  WHEN hr_utility.hr_error THEN
    -- -----------------------------------------------------------------
    -- An application error has been raised by the API so we must set
    -- the error.
    -- -----------------------------------------------------------------
        hr_utility.set_location('Exception:hr_utility.hr_error THEN'||l_proc,555);
        ROLLBACK TO process_basic_details;
        RAISE;

END process_api;

PROCEDURE process_dummy_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
)
IS
begin
   hr_utility.set_location('Entering process_dummy_api',5);
   null;
   hr_utility.set_location('Leaving process_dummy_api',10);
end;

--
---Start Registration
----------------------------------------------------********************-
---Create Person Added by VVK
------------------------------------------------------------------------------
procedure create_person
  (p_item_type                     in varchar2
  ,p_item_key                      in varchar2
  ,p_actid                         in number
  ,p_login_person_id               in number
  ,p_process_section_name          in varchar2
  ,p_action_type                   in varchar2
  ,p_validate                      in varchar2 default 'Y'  --boolean default  false
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
  -- start cobra codes
  ,p_flow_name                    in      varchar2 default null
  -- end cobra codes
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
  ,p_name_combination_warning         out nocopy varchar2    ---boolean
  ,p_assign_payroll_warning           out nocopy varchar2    ---boolean
  ,p_orig_hire_warning                out nocopy varchar2    ---boolean
  ,p_party_id                     in      number default null
  ,p_save_mode                    in      varchar2 default null
  ,p_error_message                out nocopy     long
  ,p_ni_duplicate_warn_or_err     in out nocopy varchar2
  ,p_validate_ni                  in out nocopy varchar2
  ) IS

  CURSOR  get_wf_actid (c_activity_name  in varchar2) IS
  SELECT  distinct wfias.activity_id
  FROM    wf_item_activity_statuses_v  wfias
  WHERE   wfias.item_type = p_item_type
  and     wfias.item_key  = p_item_key
  and     wfias.activity_name = c_activity_name;

------
  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_count                      integer default 0;
  l_transaction_table hr_transaction_ss.transaction_table;
  l_review_item_name  varchar2(250);
  --
  l_full_name_duplicate_flag      varchar2(1) default null;
  l_result                  varchar2(50);
  l_per_ovn                           number default null;
  l_pdp_ovn                           number default null;
  -- bug# 2693580 : changing l_employee_number from number to varchar2
  l_employee_number         per_all_people_f.employee_number%type default null;
  l_npw_number              per_all_people_f.npw_number%type default null;
  l_asg_ovn                           number default null;
  l_full_name                     per_all_people_f.full_name%type default null;
  l_person_id                    number;
  l_assignment_id                number;
  l_per_effective_start_date    date;
  l_asg_effective_end_date      date;
  l_asg_effective_start_date    date;
  l_per_effective_end_date      date;
  l_per_comment_id                number;
  l_assignment_sequence           number;
  l_assignment_number             varchar2(50);
  l_name_combination_warning      boolean;
  l_assign_payroll_warning        boolean;
  l_orig_hire_warning             boolean;
  l_parent_id         number;
  l_dummy_num  number;
  l_dummy_date date;
  l_dummy_char varchar2(1000);
  l_dummy_bool boolean;
  l_validate boolean;
  l_vendor_id                     number default null;
  l_benefit_group_id              number default null;
  l_fte_capacity                  number default null;
  l_person_type_id                number default null;
  l_sys_person_type  per_person_types.system_person_type%type;
  -- start cobra codes
  l_assignment_extra_info_id      number;
  l_aei_object_version_number     number;
  prflvalue                          varchar2(2000) default null;
  l_dup_name          VARCHAR2(1);
 -- end cobra codes
----
  l_appl_assignment_id number;
  l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
  l_api_names            hr_util_web.g_varchar2_tab_type;
  l_trans_step_rows                  NUMBER  ;
  l_proc   varchar2(72)  := g_package||'create_person';
  l_comments varchar2(100) := hr_api.g_varchar2;

Begin

     hr_multi_message.enable_message_list;

    SAVEPOINT create_person_ben_ss;
    --

   hr_utility.set_location('Entering:'||l_proc, 5);
   IF p_validate = 'N' OR p_validate IS NULL
   THEN

      hr_utility.set_location('p_validate=N OR p_validate IS NULL:'||l_proc,10);
      l_validate := false;
   ELSE
      hr_utility.set_location('p_validate=Y AND p_validate!= NULL:'||l_proc,15);
      l_validate := true;
   END IF;
---------
-- Java caller will set p_vendor_id, p_benefit_group_id and p_fte_capacity to
-- hr_api.g_number value.  We need to set these back to null before saving to
-- transaction table.

   IF p_vendor_id = 0
   THEN
      hr_utility.set_location('p_vendor_id = 0:'||l_proc,20);
      l_vendor_id := null;
   ELSE
      hr_utility.set_location('p_vendor_id != 0:'||l_proc,25);
      l_vendor_id := p_vendor_id;
   END IF;
--
   IF p_benefit_group_id = 0
   THEN
      hr_utility.set_location('p_benefit_group_id = 0:'||l_proc,30);
      l_benefit_group_id := null;
   ELSE
      hr_utility.set_location('p_benefit_group_id != 0:'||l_proc,35);
      l_benefit_group_id := p_benefit_group_id;
   END IF;
--
   IF p_fte_capacity = 0
   THEN
      hr_utility.set_location('p_fte_capacity = 0:'||l_proc,40);
      l_fte_capacity := null;
   ELSE
      hr_utility.set_location('p_fte_capacity != 0:'||l_proc,45);
      l_fte_capacity := p_fte_capacity;
   END IF;
----
   IF p_person_type_id = 0
   THEN
      hr_utility.set_location('p_person_type_id = 0:'||l_proc,50);
      l_person_type_id := null;
   ELSE
      hr_utility.set_location('p_person_type_id != 0:'||l_proc,55);
      l_person_type_id := p_person_type_id;
   END IF;

   l_employee_number := p_employee_number;
   l_npw_number := p_npw_number;

-- Save for later changes.
   IF (p_save_mode = 'SAVE_FOR_LATER') THEN
       hr_utility.set_location('if SFL,GOTO to create only Txn '||l_proc,60);
       GOTO create_only_transaction;
   END IF;


-- get the assignment_id from workflow for the applicant
   l_appl_assignment_id := wf_engine.getItemAttrText(
    itemtype  => p_item_type,
    itemkey   => p_item_key,
    aname     => 'CURRENT_ASSIGNMENT_ID');

-----------
 -- start cobra codes
--bug# 2174876
--  IF p_flow_name is null THEN
 IF p_flow_name = 'Insert' THEN
-- end cobra codes

 if(p_ni_duplicate_warn_or_err <> 'IGNORE') then
  hr_person_info_util_ss.check_ni_unique(
     p_national_identifier => p_national_identifier
    ,p_business_group_id => p_business_group_id
    ,p_person_id => p_person_id
    ,p_ni_duplicate_warn_or_err => p_ni_duplicate_warn_or_err);
    hr_utility.set_location('p_ni_duplicate_warn_or_err!=IGNORE'||l_proc,65);
 end if;

 if(p_validate_ni <> 'IGNORE') then
  hr_person_info_util_ss.validate_national_identifier(
     p_national_identifier => p_national_identifier
    ,p_birth_date => p_date_of_birth
    ,p_gender => p_sex
    ,p_person_id => p_person_id
    ,p_business_group_id => p_business_group_id
    ,p_legislation_code => p_per_information_category
    ,p_effective_date => p_effective_date
    ,p_warning => p_validate_ni);
    hr_utility.set_location('p_validate_ni!=IGNORE'||l_proc,70);
 end if;

   open gc_get_sys_person_type(l_person_type_id);
   fetch gc_get_sys_person_type into l_sys_person_type;
   close gc_get_sys_person_type;

   if (l_sys_person_type = 'CWK') then
     hr_utility.set_location('l_sys_person_type=CWK'||l_proc,75);
     hr_contingent_worker_api.create_cwk
       (p_validate                => l_validate
       ,p_start_date              => p_hire_date
       ,p_business_group_id       => p_business_group_id
       ,p_last_name               => p_last_name
       ,p_person_type_id          => l_person_type_id
       ,p_npw_number              => l_npw_number
       ,p_background_check_status => p_background_check_status
       ,p_background_date_check   => p_background_date_check
       ,p_blood_type              => p_blood_type
       ,p_comments                => p_per_comments
       ,p_correspondence_language => p_correspondence_language
       ,p_country_of_birth        => p_country_of_birth
       ,p_date_of_birth           => p_date_of_birth
       ,p_date_of_death           => p_date_of_death
       ,p_dpdnt_adoption_date     => p_dpdnt_adoption_date
       ,p_dpdnt_vlntry_svce_flag  => p_dpdnt_vlntry_svce_flag
       ,p_email_address           => p_email_address
       ,p_first_name              => p_first_name
       ,p_fte_capacity            => l_fte_capacity
       ,p_honors                  => p_honors
       ,p_internal_location       => p_internal_location
       ,p_known_as                => p_known_as
       ,p_last_medical_test_by    => p_last_medical_test_by
       ,p_last_medical_test_date  => p_last_medical_test_date
       ,p_mailstop                => p_mailstop
       ,p_marital_status          => p_marital_status
       ,p_middle_names            => p_middle_names
       ,p_national_identifier     => p_national_identifier
       ,p_nationality             => p_nationality
       ,p_office_number           => p_office_number
       ,p_on_military_service     => p_on_military_service
       ,p_party_id                => p_party_id
       ,p_pre_name_adjunct        => p_pre_name_adjunct
       ,p_previous_last_name      => p_previous_last_name
       --,p_projected_placement_end =>
       ,p_receipt_of_death_cert_date => p_receipt_of_death_cert_date
       ,p_region_of_birth         => p_region_of_birth
       ,p_registered_disabled_flag => p_registered_disabled_flag
       ,p_resume_exists            => p_resume_exists
       ,p_resume_last_updated      => p_resume_last_updated
       ,p_second_passport_exists   => p_second_passport_exists
       ,p_sex                      => p_sex
       ,p_student_status           => p_student_status
       ,p_suffix                   => p_suffix
       ,p_title                    => p_title
       ,p_town_of_birth            => p_town_of_birth
       ,p_uses_tobacco_flag        => p_uses_tobacco_flag
       ,p_vendor_id                => l_vendor_id
       ,p_work_schedule            => p_work_schedule
       ,p_work_telephone           => p_work_telephone
       --,p_exp_check_send_to_address =>
       --,p_hold_applicant_date_until =>
       ,p_date_employee_data_verified => p_date_employee_data_verified
       ,p_benefit_group_id          => l_benefit_group_id
       ,p_coord_ben_med_pln_no      => p_coord_ben_med_pln_no
       ,p_coord_ben_no_cvg_flag     => p_coord_ben_no_cvg_flag
       ,p_original_date_of_hire     => p_original_date_of_hire
       ,p_attribute_category        => p_attribute_category
       ,p_attribute1                => p_attribute1
       ,p_attribute2                => p_attribute2
       ,p_attribute3                => p_attribute3
       ,p_attribute4                => p_attribute4
       ,p_attribute5                => p_attribute5
       ,p_attribute6                => p_attribute6
       ,p_attribute7                => p_attribute7
       ,p_attribute8                => p_attribute8
       ,p_attribute9                => p_attribute9
       ,p_attribute10               => p_attribute10
       ,p_attribute11               => p_attribute11
       ,p_attribute12               => p_attribute12
       ,p_attribute13               => p_attribute13
       ,p_attribute14               => p_attribute14
       ,p_attribute15               => p_attribute15
       ,p_attribute16               => p_attribute16
       ,p_attribute17               => p_attribute17
       ,p_attribute18               => p_attribute18
       ,p_attribute19               => p_attribute19
       ,p_attribute20               => p_attribute20
       ,p_attribute21               => p_attribute21
       ,p_attribute22               => p_attribute22
       ,p_attribute23               => p_attribute23
       ,p_attribute24               => p_attribute24
       ,p_attribute25               => p_attribute25
       ,p_attribute26               => p_attribute26
       ,p_attribute27               => p_attribute27
       ,p_attribute28               => p_attribute28
       ,p_attribute29               => p_attribute29
       ,p_attribute30               => p_attribute30
       ,p_per_information_category => p_per_information_category
       ,p_per_information1         => p_per_information1
       ,p_per_information2         => p_per_information2
       ,p_per_information3         => p_per_information3
       ,p_per_information4         => p_per_information4
       ,p_per_information5         => p_per_information5
       ,p_per_information6         => p_per_information6
       ,p_per_information7         => p_per_information7
       ,p_per_information8         => p_per_information8
       ,p_per_information9         => p_per_information9
       ,p_per_information10        => p_per_information10
       ,p_per_information11        => p_per_information11
       ,p_per_information12        => p_per_information12
       ,p_per_information13        => p_per_information13
       ,p_per_information14        => p_per_information14
       ,p_per_information15        => p_per_information15
       ,p_per_information16        => p_per_information16
       ,p_per_information17        => p_per_information17
       ,p_per_information18        => p_per_information18
       ,p_per_information19        => p_per_information19
       ,p_per_information20        => p_per_information20
       ,p_per_information21        => p_per_information21
       ,p_per_information22        => p_per_information22
       ,p_per_information23        => p_per_information23
       ,p_per_information24        => p_per_information24
       ,p_per_information25        => p_per_information25
       ,p_per_information26        => p_per_information26
       ,p_per_information27        => p_per_information27
       ,p_per_information28        => p_per_information28
       ,p_per_information29        => p_per_information29
       ,p_per_information30        => p_per_information30
       ,p_person_id                => l_person_id
       ,p_per_object_version_number => l_per_ovn
       ,p_per_effective_start_date  => l_per_effective_start_date
       ,p_per_effective_end_date    => l_per_effective_end_date
       ,p_pdp_object_version_number => l_pdp_ovn
       ,p_full_name                 => l_full_name
       ,p_comment_id                => l_per_comment_id
       ,p_assignment_id             => l_assignment_id
       ,p_asg_object_version_number => l_asg_ovn
       ,p_assignment_sequence       => l_assignment_sequence
       ,p_assignment_number         => l_assignment_number
       ,p_name_combination_warning  => l_name_combination_warning
       );
   else
     hr_utility.set_location('l_sys_person_type!=CWK'||l_proc,80);
     hr_employee_api.create_employee
       (p_validate                      => l_validate
                        --in     boolean  default false
        ,p_hire_date                     => p_hire_date
        ,p_business_group_id             => p_business_group_id
        ,p_last_name                     => p_last_name
        ,p_sex                           => p_sex
        ,p_person_type_id                => l_person_type_id
        ,p_per_comments                  => p_per_comments
        ,p_date_employee_data_verified   => p_date_employee_data_verified
        ,p_date_of_birth                 => p_date_of_birth
        ,p_email_address                 => p_email_address
        ,p_employee_number               => l_employee_number
                        --in out nocopy varchar2
        ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
        ,p_first_name                    => p_first_name
        ,p_known_as                      => p_known_as
        ,p_marital_status                => p_marital_status
        ,p_middle_names                  => p_middle_names
        ,p_nationality                   => p_nationality
        ,p_national_identifier           => p_national_identifier
        ,p_previous_last_name            => p_previous_last_name
        ,p_registered_disabled_flag      => p_registered_disabled_flag
        ,p_title                         => p_title
        ,p_vendor_id                     => l_vendor_id
        ,p_work_telephone                => p_work_telephone
        ,p_attribute_category            => p_attribute_category
        ,p_attribute1                   => p_attribute1
        ,p_attribute2                   => p_attribute2
        ,p_attribute3                   => p_attribute3
        ,p_attribute4                   => p_attribute4
        ,p_attribute5                   => p_attribute5
        ,p_attribute6                   => p_attribute6
        ,p_attribute7                   => p_attribute7
        ,p_attribute8                   => p_attribute8
        ,p_attribute9                   => p_attribute9
        ,p_attribute10                  => p_attribute10
        ,p_attribute11                  => p_attribute11
        ,p_attribute12                  => p_attribute12
        ,p_attribute13                  => p_attribute13
        ,p_attribute14                  => p_attribute14
        ,p_attribute15                  => p_attribute15
        ,p_attribute16                  => p_attribute16
        ,p_attribute17                  => p_attribute17
        ,p_attribute18                  => p_attribute18
        ,p_attribute19                  => p_attribute19
        ,p_attribute20                  => p_attribute20
        ,p_attribute21                  => p_attribute21
        ,p_attribute22                  => p_attribute22
        ,p_attribute23                  => p_attribute23
        ,p_attribute24                  => p_attribute24
        ,p_attribute25                  => p_attribute25
        ,p_attribute26                  => p_attribute26
        ,p_attribute27                  => p_attribute27
        ,p_attribute28                  => p_attribute28
        ,p_attribute29                  => p_attribute29
        ,p_attribute30                  => p_attribute30
        ,p_per_information_category      => p_per_information_category
        ,p_per_information1              => p_per_information1
        ,p_per_information2              => p_per_information2
        ,p_per_information3              => p_per_information3
        ,p_per_information4              => p_per_information4
        ,p_per_information5              => p_per_information5
        ,p_per_information6              => p_per_information6
        ,p_per_information7              => p_per_information7
        ,p_per_information8              => p_per_information8
        ,p_per_information9              => p_per_information9
        ,p_per_information10             => p_per_information10
        ,p_per_information11             => p_per_information11
        ,p_per_information12             => p_per_information12
        ,p_per_information13             => p_per_information13
        ,p_per_information14             => p_per_information14
        ,p_per_information15             => p_per_information15
        ,p_per_information16             => p_per_information16
        ,p_per_information17             => p_per_information17
        ,p_per_information18             => p_per_information18
        ,p_per_information19             => p_per_information19
        ,p_per_information20             => p_per_information20
        ,p_per_information21             => p_per_information21
        ,p_per_information22             => p_per_information22
        ,p_per_information23             => p_per_information23
        ,p_per_information24             => p_per_information24
        ,p_per_information25             => p_per_information25
        ,p_per_information26             => p_per_information26
        ,p_per_information27             => p_per_information27
        ,p_per_information28             => p_per_information28
        ,p_per_information29             => p_per_information29
        ,p_per_information30             => p_per_information30
        ,p_date_of_death                 => p_date_of_death
        ,p_background_check_status       => p_background_check_status
        ,p_background_date_check         => p_background_date_check
        ,p_blood_type                    => p_blood_type
        ,p_correspondence_language       => p_correspondence_language
        ,p_fast_path_employee            => p_fast_path_employee
        ,p_fte_capacity                  => l_fte_capacity
       ,p_honors                        => p_honors
       ,p_internal_location             => p_internal_location
       ,p_last_medical_test_by          => p_last_medical_test_by
       ,p_last_medical_test_date        => p_last_medical_test_date
       ,p_mailstop                      => p_mailstop
       ,p_office_number                 => p_office_number
       ,p_on_military_service           => p_on_military_service
       ,p_pre_name_adjunct              => p_pre_name_adjunct
       ,p_projected_start_date          => p_projected_start_date
       ,p_resume_exists                 => p_resume_exists
       ,p_resume_last_updated           => p_resume_last_updated
       ,p_second_passport_exists        => p_second_passport_exists
       ,p_student_status                => p_student_status
       ,p_work_schedule                 => p_work_schedule
       ,p_suffix                        => p_suffix
       ,p_benefit_group_id              => l_benefit_group_id
       ,p_receipt_of_death_cert_date    => p_receipt_of_death_cert_date
       ,p_coord_ben_med_pln_no          => p_coord_ben_med_pln_no
       ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
       ,p_uses_tobacco_flag             => p_uses_tobacco_flag
       ,p_dpdnt_adoption_date           => p_dpdnt_adoption_date
       ,p_dpdnt_vlntry_svce_flag        => p_dpdnt_vlntry_svce_flag
       ,p_original_date_of_hire         => p_original_date_of_hire
       ,p_adjusted_svc_date             => p_adjusted_svc_date
       ,p_town_of_birth                 => p_town_of_birth
       ,p_region_of_birth               => p_region_of_birth
       ,p_country_of_birth              => p_country_of_birth
       ,p_global_person_id              => p_global_person_id
       ,p_party_id                      => p_party_id
       ,p_person_id                     => l_person_id  --   out number
       ,p_assignment_id                 => l_assignment_id  --   out number
       ,p_per_object_version_number     => l_per_ovn ---   out nocopy number
       ,p_asg_object_version_number     => l_asg_ovn  ---   out nocopy number
       ,p_per_effective_start_date      => l_per_effective_start_date --out date
       ,p_per_effective_end_date        => l_per_effective_end_date --out date
       ,p_full_name                     => l_full_name   ---out nocopy varchar2
       ,p_per_comment_id                => l_per_comment_id ---out nocopy number
       ,p_assignment_sequence           => l_assignment_sequence --out number
       ,p_assignment_number             => l_assignment_number --out varchar2
       ,p_name_combination_warning      => l_name_combination_warning
                                           --out boolean
       ,p_assign_payroll_warning        => l_assign_payroll_warning
                                           --   out boolean
       ,p_orig_hire_warning             => l_orig_hire_warning  --  out boolean
   );
   end if;
  --
   --
 -- start cobra codes
 ELSIF p_flow_name = 'Cobra' THEN
     hr_utility.set_location('p_flow_name=Cobra'||l_proc,85);
   hr_contact_api.create_person
        (p_validate                      => false  --in boolean  default false
        ,p_start_date                    => sysdate
        ,p_business_group_id             => p_business_group_id
        ,p_last_name                     => p_last_name
        ,p_sex                           => p_sex
        ,p_person_type_id                => null
        ,p_comments                      => p_per_comments
        ,p_date_employee_data_verified   => p_date_employee_data_verified
        ,p_date_of_birth                 => p_date_of_birth
        ,p_email_address                 => p_email_address
        ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
        ,p_first_name                    => p_first_name
        ,p_known_as                      => p_known_as
        ,p_marital_status                => p_marital_status
        ,p_middle_names                  => p_middle_names
        ,p_nationality                   => p_nationality
        ,p_national_identifier           => p_national_identifier
        ,p_previous_last_name            => p_previous_last_name
        ,p_registered_disabled_flag      => p_registered_disabled_flag
        ,p_title                         => p_title
        ,p_vendor_id                     => l_vendor_id
        ,p_work_telephone                => p_work_telephone
        ,p_attribute_category            => p_attribute_category
        ,p_attribute1                   => p_attribute1
        ,p_attribute2                   => p_attribute2
        ,p_attribute3                   => p_attribute3
        ,p_attribute4                   => p_attribute4
        ,p_attribute5                   => p_attribute5
        ,p_attribute6                   => p_attribute6
        ,p_attribute7                   => p_attribute7
        ,p_attribute8                   => p_attribute8
        ,p_attribute9                   => p_attribute9
        ,p_attribute10                  => p_attribute10
        ,p_attribute11                  => p_attribute11
        ,p_attribute12                  => p_attribute12
        ,p_attribute13                  => p_attribute13
        ,p_attribute14                  => p_attribute14
        ,p_attribute15                  => p_attribute15
        ,p_attribute16                  => p_attribute16
        ,p_attribute17                  => p_attribute17
        ,p_attribute18                  => p_attribute18
        ,p_attribute19                  => p_attribute19
        ,p_attribute20                  => p_attribute20
        ,p_attribute21                  => p_attribute21
        ,p_attribute22                  => p_attribute22
        ,p_attribute23                  => p_attribute23
        ,p_attribute24                  => p_attribute24
        ,p_attribute25                  => p_attribute25
        ,p_attribute26                  => p_attribute26
        ,p_attribute27                  => p_attribute27
        ,p_attribute28                  => p_attribute28
        ,p_attribute29                  => p_attribute29
        ,p_attribute30                  => p_attribute30
        ,p_per_information_category      => p_per_information_category
        ,p_per_information1              => p_per_information1
        ,p_per_information2              => p_per_information2
        ,p_per_information3              => p_per_information3
        ,p_per_information4              => p_per_information4
        ,p_per_information5              => p_per_information5
        ,p_per_information6              => p_per_information6
        ,p_per_information7              => p_per_information7
        ,p_per_information8              => p_per_information8
        ,p_per_information9              => p_per_information9
        ,p_per_information10             => p_per_information10
        ,p_per_information11             => p_per_information11
        ,p_per_information12             => p_per_information12
        ,p_per_information13             => p_per_information13
        ,p_per_information14             => p_per_information14
        ,p_per_information15             => p_per_information15
        ,p_per_information16             => p_per_information16
        ,p_per_information17             => p_per_information17
        ,p_per_information18             => p_per_information18
        ,p_per_information19             => p_per_information19
        ,p_per_information20             => p_per_information20
        ,p_per_information21             => p_per_information21
        ,p_per_information22             => p_per_information22
        ,p_per_information23             => p_per_information23
        ,p_per_information24             => p_per_information24
        ,p_per_information25             => p_per_information25
        ,p_per_information26             => p_per_information26
        ,p_per_information27             => p_per_information27
        ,p_per_information28             => p_per_information28
        ,p_per_information29             => p_per_information29
        ,p_per_information30             => p_per_information30
        ,p_correspondence_language       => p_correspondence_language
        ,p_honors                        => p_honors
        ,p_pre_name_adjunct              => p_pre_name_adjunct
        ,p_suffix                        => p_suffix
        ,p_town_of_birth                 => p_town_of_birth
        ,p_region_of_birth               => p_region_of_birth
        ,p_country_of_birth              => p_country_of_birth
        ,p_global_person_id              => p_global_person_id
        ,p_person_id                     => l_person_id  --   out number
        ,p_object_version_number         => l_per_ovn ---   out nocopy number
        ,p_effective_start_date          => l_per_effective_start_date
                                            --out date
        ,p_effective_end_date            => l_per_effective_end_date
                                           --   out date
        ,p_full_name                     => l_full_name -- out nocopy varchar2
        ,p_comment_id                   => l_per_comment_id -- out nocopy number
        ,p_name_combination_warning      => l_name_combination_warning
                                           --   out boolean
        ,p_orig_hire_warning             => l_orig_hire_warning  --  out boolean
   );
  --

IF g_debug THEN
    hr_utility.set_location('Leaving  hr_process_person_ss.create_personnnnnnnnnn ' || l_person_id, 2006);
END IF;

    /*prflvalue := fnd_profile.value('BEN_USER_TO_ORG_LINK');
    ben_assignment_api.create_ben_asg
        (p_validate                     => l_validate --in boolean default false
         ,p_event_mode                   => false
         ,p_effective_date               => trunc(sysdate)
         ,p_person_id                    => l_person_id
         ,p_organization_id            => nvl(prflvalue,p_business_group_id) --new profile??
         ,p_assignment_status_type_id    => 1
         ,p_assignment_id                => l_assignment_id  --   out number
         ,p_object_version_number        => l_asg_ovn ---   out nocopy number
         ,p_effective_start_date         => l_asg_effective_start_date   --   out date
         ,p_effective_end_date           => l_asg_effective_end_date    --   out date
         ,p_assignment_extra_info_id     => l_assignment_extra_info_id
         ,p_aei_object_version_number    => l_aei_object_version_number
         );*/

  END IF;

 -- end cobra codes


  -- set back the full name
    p_full_name := l_full_name;

  hr_utility.set_location('Rolling back to create_person_ben_ss'||l_proc,90);
  rollback to create_person_ben_ss;

   hr_multi_message.disable_message_list;

 <<create_only_transaction>> -- label for GOTO

   hr_utility.set_location('create_only_transaction:'||l_proc,95);
  --Store the full_name in workflow item attribute HR_SECTION_DISPLAY_NAME
  -- to be used by the actions page.
  -- if l_full_name is null, derive it
     if (l_full_name is null) then
     hr_utility.set_location('l_full_name is null:'||l_proc,100);
      hr_person.derive_full_name(p_first_name,
                               p_middle_names, p_last_name, p_known_as,
                               p_title, p_date_of_birth,
                               p_person_id, p_business_group_id
                               ,l_full_name,l_dup_name,
                               p_per_information1, p_per_information2,
                               p_per_information3, p_per_information4,
                               p_per_information5, p_per_information6,
                               p_per_information7, p_per_information8,
                               p_per_information9, p_per_information10,
                               p_per_information11, p_per_information12,
                               p_per_information13, p_per_information14,
                               p_per_information15, p_per_information16,
                               p_per_information17, p_per_information18,
                               p_per_information19, p_per_information20,
                               p_per_information21, p_per_information22,
                               p_per_information23, p_per_information24,
                               p_per_information25, p_per_information26,
                               p_per_information27, p_per_information28,
                               p_per_information29, p_per_information30);
     end if;

     wf_engine.setItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'HR_SECTION_DISPLAY_NAME',
                           avalue   => l_full_name);

-- Set the P_EFFECTIVE_DATE and CURRENT_EFFECTIVE_DATE in wf item attributes to be retreived
-- in review page

       wf_engine.setItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'P_EFFECTIVE_DATE',
                           avalue   =>  to_char(p_effective_date,
                                        g_date_format));

       wf_engine.setItemAttrDate (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'CURRENT_EFFECTIVE_DATE',
                           avalue   =>  p_effective_date);
  --
  -- First, check if transaction id exists or not
  --
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  --
  IF l_transaction_id is null THEN
     -- Start a Transaction
        hr_utility.set_location('l_transaction_id is null THEN:'||l_proc,105);
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_actid
           ,funmode    => 'RUN'
           ,p_login_person_id => p_login_person_id  --nvl(p_login_person_id, p_parent_id)
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
  END IF;
------------------
  --
  -- First check step id already exists, which happens when user navigates
  -- back from review or page after this page.
  --
 hr_transaction_api.get_transaction_step_info
     (p_item_type              => p_item_type
     ,p_item_key               => p_item_key
     ,p_activity_id            => p_actid
     ,p_transaction_step_id    => l_trans_step_ids
     ,p_api_name               => l_api_names
     ,p_rows                   => l_trans_step_rows);
  --

 hr_utility.set_location('Entering For Loop 0..l_trans_step_rows-1:'||l_proc,110);
 FOR i in 0..l_trans_step_rows-1 LOOP
   IF(l_api_names(i) = 'HR_PROCESS_PERSON_SS.PROCESS_API') THEN
      l_transaction_step_id := l_trans_step_ids(i);
   END IF;
 END LOOP;
 hr_utility.set_location('Exiting For Loop 0..l_trans_step_rows-1:'||l_proc,115);

  if l_transaction_step_id is null then
     --
     -- Create a transaction step
     --
     hr_utility.set_location('l_transaction_step_id is null then:'||l_proc,120);
     hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => p_login_person_id
               --nvl(p_login_person_id, p_parent_id)
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_package || 'PROCESS_API'
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_actid
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
     --
  end if;
  --

  --
  -- Create a transaction step
  --
/*  hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => p_login_person_id  --nvl(p_login_person_id, p_parent_id)
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_package || 'PROCESS_API'
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_actid
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num); */

  --
  l_count := 1;
  l_transaction_table(l_count).param_name := 'P_ITEM_TYPE';
  l_transaction_table(l_count).param_value := p_item_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ITEM_KEY';
  l_transaction_table(l_count).param_value := p_item_key;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTIVITY_ID';
  l_transaction_table(l_count).param_value := p_actid;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PROCESS_SECTION_NAME';
  l_transaction_table(l_count).param_value := p_process_section_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTION_TYPE';
  l_transaction_table(l_count).param_value := p_action_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_START';
  l_transaction_table(l_count).param_value := to_char(p_hire_date,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
-- We don't want to derive the business_group_id because we want to save a
-- db sql statement call to improve the performance.
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
  l_transaction_table(l_count).param_value := p_business_group_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_NAME';
  l_transaction_table(l_count).param_value := p_last_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SEX';
  l_transaction_table(l_count).param_value := p_sex;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_TYPE_ID';
  l_transaction_table(l_count).param_value := l_person_type_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_COMMENTS';
  l_transaction_table(l_count).param_value := p_per_comments;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_EMPLOYEE_DATA_VERIFIED';
  l_transaction_table(l_count).param_value := to_char(p_date_employee_data_verified,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_OF_BIRTH';
  l_transaction_table(l_count).param_value := to_char(p_date_of_birth,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EMAIL_ADDRESS';
  l_transaction_table(l_count).param_value := p_email_address;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EXPENSE_CHECK_SEND_TO_ADDRES';
  l_transaction_table(l_count).param_value := p_expense_check_send_to_addres;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FIRST_NAME';
  l_transaction_table(l_count).param_value := p_first_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_KNOWN_AS';
  l_transaction_table(l_count).param_value := p_known_as;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_MARITAL_STATUS';
  l_transaction_table(l_count).param_value := p_marital_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_MIDDLE_NAMES';
  l_transaction_table(l_count).param_value := p_middle_names;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NATIONALITY';
  l_transaction_table(l_count).param_value := p_nationality;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NATIONAL_IDENTIFIER';
  l_transaction_table(l_count).param_value := p_national_identifier;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PREVIOUS_LAST_NAME';
  l_transaction_table(l_count).param_value := p_previous_last_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REGISTERED_DISABLED_FLAG';
  l_transaction_table(l_count).param_value := p_registered_disabled_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TITLE';
  l_transaction_table(l_count).param_value := p_title;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_VENDOR_ID';
  l_transaction_table(l_count).param_value := to_char(l_vendor_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_WORK_TELEPHONE';
  l_transaction_table(l_count).param_value := p_work_telephone;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_CATEGORY';
  l_transaction_table(l_count).param_value := p_attribute_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1';
  l_transaction_table(l_count).param_value := p_attribute1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2';
  l_transaction_table(l_count).param_value := p_attribute2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3';
  l_transaction_table(l_count).param_value := p_attribute3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4';
  l_transaction_table(l_count).param_value := p_attribute4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5';
  l_transaction_table(l_count).param_value := p_attribute5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6';
  l_transaction_table(l_count).param_value := p_attribute6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7';
  l_transaction_table(l_count).param_value := p_attribute7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8';
  l_transaction_table(l_count).param_value := p_attribute8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9';
  l_transaction_table(l_count).param_value := p_attribute9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10';
  l_transaction_table(l_count).param_value := p_attribute10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11';
  l_transaction_table(l_count).param_value := p_attribute11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12';
  l_transaction_table(l_count).param_value := p_attribute12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13';
  l_transaction_table(l_count).param_value := p_attribute13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14';
  l_transaction_table(l_count).param_value := p_attribute14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15';
  l_transaction_table(l_count).param_value := p_attribute15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16';
  l_transaction_table(l_count).param_value := p_attribute16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17';
  l_transaction_table(l_count).param_value := p_attribute17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18';
  l_transaction_table(l_count).param_value := p_attribute18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19';
  l_transaction_table(l_count).param_value := p_attribute19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20';
  l_transaction_table(l_count).param_value := p_attribute20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE21';
  l_transaction_table(l_count).param_value := p_attribute21;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE22';
  l_transaction_table(l_count).param_value := p_attribute22;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE23';
  l_transaction_table(l_count).param_value := p_attribute23;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE24';
  l_transaction_table(l_count).param_value := p_attribute24;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE25';
  l_transaction_table(l_count).param_value := p_attribute25;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE26';
  l_transaction_table(l_count).param_value := p_attribute26;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE27';
  l_transaction_table(l_count).param_value := p_attribute27;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE28';
  l_transaction_table(l_count).param_value := p_attribute28;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE29';
  l_transaction_table(l_count).param_value := p_attribute29;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE30';
  l_transaction_table(l_count).param_value := p_attribute30;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION_CATEGORY';
  l_transaction_table(l_count).param_value := p_per_information_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION1';
  l_transaction_table(l_count).param_value := p_per_information1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION2';
  l_transaction_table(l_count).param_value := p_per_information2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION3';
  l_transaction_table(l_count).param_value := p_per_information3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION4';
  l_transaction_table(l_count).param_value := p_per_information4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION5';
  l_transaction_table(l_count).param_value := p_per_information5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION6';
  l_transaction_table(l_count).param_value := p_per_information6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION7';
  l_transaction_table(l_count).param_value := p_per_information7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION8';
  l_transaction_table(l_count).param_value := p_per_information8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION9';
  l_transaction_table(l_count).param_value := p_per_information9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION10';
  l_transaction_table(l_count).param_value := p_per_information10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION11';
  l_transaction_table(l_count).param_value := p_per_information11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION12';
  l_transaction_table(l_count).param_value := p_per_information12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION13';
  l_transaction_table(l_count).param_value := p_per_information13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION14';
  l_transaction_table(l_count).param_value := p_per_information14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION15';
  l_transaction_table(l_count).param_value := p_per_information15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION16';
  l_transaction_table(l_count).param_value := p_per_information16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION17';
  l_transaction_table(l_count).param_value := p_per_information17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION18';
  l_transaction_table(l_count).param_value := p_per_information18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION19';
  l_transaction_table(l_count).param_value := p_per_information19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION20';
  l_transaction_table(l_count).param_value := p_per_information20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION21';
  l_transaction_table(l_count).param_value := p_per_information21;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION22';
  l_transaction_table(l_count).param_value := p_per_information22;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION23';
  l_transaction_table(l_count).param_value := p_per_information23;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION24';
  l_transaction_table(l_count).param_value := p_per_information24;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION25';
  l_transaction_table(l_count).param_value := p_per_information25;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION26';
  l_transaction_table(l_count).param_value := p_per_information26;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION27';
  l_transaction_table(l_count).param_value := p_per_information27;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION28';
  l_transaction_table(l_count).param_value := p_per_information28;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION29';
  l_transaction_table(l_count).param_value := p_per_information29;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION30';
  l_transaction_table(l_count).param_value := p_per_information30;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_OF_DEATH';
  l_transaction_table(l_count).param_value := to_char
                                              (p_date_of_death
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BACKGROUND_CHECK_STATUS';
  l_transaction_table(l_count).param_value := p_background_check_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BACKGROUND_DATE_CHECK';
  l_transaction_table(l_count).param_value := to_char
                                              (p_background_date_check
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BLOOD_TYPE';
  l_transaction_table(l_count).param_value := p_blood_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CORRESPONDENCE_LANGUAGE';
  l_transaction_table(l_count).param_value := p_correspondence_language;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FAST_PATH_EMPLOYEE';
  l_transaction_table(l_count).param_value := p_fast_path_employee;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FTE_CAPACITY';
  l_transaction_table(l_count).param_value := to_char(l_fte_capacity);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_HONORS';
  l_transaction_table(l_count).param_value := p_honors;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INTERNAL_LOCATION';
  l_transaction_table(l_count).param_value := p_internal_location;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_MEDICAL_TEST_BY';
  l_transaction_table(l_count).param_value := p_last_medical_test_by;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_MEDICAL_TEST_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_last_medical_test_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_MAILSTOP';
  l_transaction_table(l_count).param_value := p_mailstop;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OFFICE_NUMBER';
  l_transaction_table(l_count).param_value := p_office_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ON_MILITARY_SERVICE';
  l_transaction_table(l_count).param_value := p_on_military_service;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PRE_NAME_ADJUNCT';
  l_transaction_table(l_count).param_value := p_pre_name_adjunct;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PROJECTED_START_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_projected_start_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RESUME_EXISTS';
  l_transaction_table(l_count).param_value := p_resume_exists;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RESUME_LAST_UPDATED';
  l_transaction_table(l_count).param_value := to_char
                                              (p_resume_last_updated
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SECOND_PASSPORT_EXISTS';
  l_transaction_table(l_count).param_value := p_second_passport_exists;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_STUDENT_STATUS';
  l_transaction_table(l_count).param_value := p_student_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_WORK_SCHEDULE';
  l_transaction_table(l_count).param_value := p_work_schedule;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SUFFIX';
  l_transaction_table(l_count).param_value := p_suffix;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BENEFIT_GROUP_ID';
  l_transaction_table(l_count).param_value := to_char(l_benefit_group_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RECEIPT_OF_DEATH_CERT_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_receipt_of_death_cert_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COORD_BEN_MED_PLN_NO';
  l_transaction_table(l_count).param_value := p_coord_ben_med_pln_no;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COORD_BEN_NO_CVG_FLAG';
  l_transaction_table(l_count).param_value := p_coord_ben_no_cvg_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_USES_TOBACCO_FLAG';
  l_transaction_table(l_count).param_value := p_uses_tobacco_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DPDNT_ADOPTION_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_dpdnt_adoption_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DPDNT_VLNTRY_SVCE_FLAG';
  l_transaction_table(l_count).param_value := p_dpdnt_vlntry_svce_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ORIGINAL_DATE_OF_HIRE';
  l_transaction_table(l_count).param_value := to_char
                                             (p_original_date_of_hire
                                             ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ADJUSTED_SVC_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_adjusted_svc_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TOWN_OF_BIRTH';
  l_transaction_table(l_count).param_value := p_town_of_birth;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REGION_OF_BIRTH';
  l_transaction_table(l_count).param_value := p_region_of_birth;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COUNTRY_OF_BIRTH';
  l_transaction_table(l_count).param_value := p_country_of_birth;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_GLOBAL_PERSON_ID';
  l_transaction_table(l_count).param_value := p_global_person_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_ID';
  l_transaction_table(l_count).param_value := p_person_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ASSIGNMENT_ID';
  l_transaction_table(l_count).param_value := p_assignment_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := p_per_object_version_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ASG_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := p_asg_object_version_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_EFFECTIVE_START_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_per_effective_start_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_EFFECTIVE_END_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_per_effective_end_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_review_item_name := p_review_page_region_code;
  if (p_review_page_region_code IS NULL) then
    BEGIN
     hr_utility.set_location('p_review_page_region_code IS NULL'||l_proc,125);
      l_review_item_name :=
        wf_engine.GetActivityAttrText(itemtype  => p_item_type,
                             itemkey   => p_item_key,
                             actid     => p_actid,
                             aname     => g_wf_review_regn_itm_attr_name);
    EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Exception:Others'||l_proc,555);
      l_review_item_name := 'HrBasicDetailsReview';
    END;
  end if;

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
  l_transaction_table(l_count).param_value := l_review_item_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_actid;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
  l_transaction_table(l_count).param_value := to_char(p_effective_date,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_UPDATE_MODE';
  l_transaction_table(l_count).param_value := p_attribute_update_mode;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := p_object_version_number;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
 l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_APPLICANT_NUMBER';
  l_transaction_table(l_count).param_value := p_applicant_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COMMENTS';
  l_transaction_table(l_count).param_value := l_comments;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EMPLOYEE_NUMBER';
  l_transaction_table(l_count).param_value := p_employee_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NPW_NUMBER';
  l_transaction_table(l_count).param_value := p_npw_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_HOLD_APPLICANT_DATE_UNTIL';
  l_transaction_table(l_count).param_value := to_char
                                              (p_hold_applicant_date_until
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REHIRE_AUTHORIZOR';
  l_transaction_table(l_count).param_value := p_rehire_authorizor;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REHIRE_RECOMMENDATION';
  l_transaction_table(l_count).param_value := p_rehire_recommendation;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REHIRE_REASON';
  l_transaction_table(l_count).param_value := p_rehire_reason;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FULL_NAME';
  l_transaction_table(l_count).param_value := l_full_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
 --
-- start cobra codes
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FLOW_NAME';
  l_transaction_table(l_count).param_value := p_flow_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
 --
 -- end cobra codes
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_APPL_ASSIGNMENT_ID';
  l_transaction_table(l_count).param_value := l_appl_assignment_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--

--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PARTY_ID';
  l_transaction_table(l_count).param_value := p_party_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--



 hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => p_actid
                ,p_login_person_id     => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || 'PROCESS_API'
                ,p_transaction_data => l_transaction_table);

  p_person_id := l_person_id;
  p_assignment_id := l_assignment_id;
  p_per_object_version_number := l_per_ovn;
  p_asg_object_version_number := l_asg_ovn;
  p_per_effective_start_date := l_per_effective_start_date;
  p_per_effective_end_date := l_per_effective_end_date;
  p_full_name := l_full_name;
  p_per_comment_id := l_per_comment_id;
  p_assignment_sequence := l_assignment_sequence;
  p_assignment_number := l_assignment_number;
--
-- Need to convert the boolean true/false value to varchar2 value because on
-- return back to Java program which won't recognize the value.
  IF l_name_combination_warning
  THEN
     p_name_combination_warning := 'Y';
  ELSE
     p_name_combination_warning := 'N';
  END IF;
--
  IF l_assign_payroll_warning
  THEN
     p_assign_payroll_warning := 'Y';
  ELSE
     p_assign_payroll_warning := 'N';
  END IF;
--
  IF l_orig_hire_warning
  THEN
     p_orig_hire_warning := 'Y';
  ELSE
     p_orig_hire_warning := 'N';
  END IF;
--
  p_employee_number := l_employee_number;


IF g_debug THEN
  hr_utility.set_location('Leaving  hr_process_person_ss.create_person ' || g_person_id, 200);
END IF;


EXCEPTION
  WHEN g_data_error THEN
    hr_utility.set_location('Exception:g_data_error THEN'||l_proc,560);
    rollback to create_person_ben_ss;
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                      p_error_message => p_error_message);
  WHEN others THEN
  hr_utility.set_location('Exception:Others'||l_proc,555);
--  This should be included as an out param for the procedure "create_person".
--  Along with this change include also the appropriate changes in the java that calls this api.
--
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                          p_error_message => p_error_message);
    rollback to create_person_ben_ss;

END create_person;
--
--   End Registration
--

/* see header for comments */

procedure process_applicant(
    p_effective_date   in date
   ,p_person_id        in number
    ,p_business_group_id    in number
   ,p_assignment_id        in number
   ,p_soft_coding_keyflex_id in number default null
   ,p_is_payroll_upd out nocopy boolean
   ) is

  l_address_line1 per_addresses.address_line1%type;
  l_date_of_birth per_all_people_f.date_of_birth%type;
  l_legislation_code             per_business_groups.legislation_code%TYPE;
  l_leg_code             per_business_groups.legislation_code%TYPE;

  cursor csr_get_person_dob is
     select   date_of_birth   from     per_people_f
     where    person_id    = p_person_id
     and      p_effective_date between effective_start_date
                                   and effective_end_date;

  cursor csr_pradd_exists is
    select   address_line1   from     per_addresses
    where    person_id = p_person_id    and      primary_flag='Y'
    and      ( (style='US' and region_1 is not null)
             or style<>'US');

  cursor csr_get_legc_code is
  select legislation_code  from per_business_groups_perf
  where business_group_id = p_business_group_id;

  cursor csr_pay_legislation_rules is
    select legislation_code from pay_legislation_rules
    where legislation_code = l_legislation_code
    and rule_type = 'TAX_UNIT' and rule_mode = 'Y';

begin
p_is_payroll_upd := false;

  open csr_pradd_exists;
  fetch csr_pradd_exists into l_address_line1;
  close csr_pradd_exists;

  open csr_get_person_dob;
  fetch csr_get_person_dob into l_date_of_birth;
  close csr_get_person_dob;

  open csr_get_legc_code;
  fetch csr_get_legc_code into l_legislation_code;
  close csr_get_legc_code;

  open csr_pay_legislation_rules;
  fetch csr_pay_legislation_rules into l_leg_code;
  close csr_pay_legislation_rules;

if (hr_general.chk_geocodes_installed = 'Y'
      and ( ( l_legislation_code = 'CA'
              and hr_utility.chk_product_install(p_product => 'Oracle Payroll',
                                                 p_legislation => 'CA'))
            OR ( l_legislation_code = 'US'
              and hr_utility.chk_product_install(p_product => 'Oracle Payroll',
                                                 p_legislation => 'US')))
        and l_address_line1 is null) OR (l_date_of_birth is null) OR
        (p_soft_coding_keyflex_id is null and l_leg_code is not null)   then

        update per_all_assignments_f set payroll_id=null where assignment_id = p_assignment_id and
        p_effective_date between effective_start_date and effective_end_date;

        p_is_payroll_upd := true;
end if;

end;

END hr_process_person_ss;
--
--

/
