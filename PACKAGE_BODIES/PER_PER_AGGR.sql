--------------------------------------------------------
--  DDL for Package Body PER_PER_AGGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PER_AGGR" AS
/* $Header: pegbperhi.pkb 120.1.12010000.2 2009/07/23 10:29:23 rlingama noship $ */

-- Start : bug#8370225

PROCEDURE AI_check_PAYE_NI_flags (p_person_id IN NUMBER,
                                  p_effective_date IN DATE) IS

CURSOR GET_PERSON_DETAILS IS
 SELECT papf.person_id, PAPF.object_version_number, PAPF.employee_number,
        PER_INFORMATION9,PER_INFORMATION10 ,CURRENT_EMPLOYEE_FLAG
 FROM  per_all_people_f PAPF
 WHERE papf.person_id = p_person_id
 AND p_effective_date BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.effective_end_date;

L_PERSON_ID PER_ALL_PEOPLE_F.PERSON_ID%TYPE;
l_validate Boolean;
l_object_version_number NUMBER;
l_employee_number PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE;
l_paye_aggregate_assignment PER_ALL_PEOPLE_F.PER_INFORMATION10%type;
l_ni_aggregate_assignment PER_ALL_PEOPLE_F.PER_INFORMATION10%type;
l_full_name PER_ALL_PEOPLE_F.full_name%TYPE;
l_comment_id number;
l_name_combination_warning boolean;
l_assign_payroll_warning   boolean;
l_orig_hire_warning        boolean;
l_end_date  date;
l_start_date date;
l_profile_value varchar2(30);
l_CURRENT_EMPLOYEE_FLAG PER_ALL_PEOPLE_F.CURRENT_EMPLOYEE_FLAG%type;

BEGIN

fnd_profile.get('GB_PAYE_NI_AGGREGATION',l_profile_value);
IF NVL(l_profile_value,'N') = 'Y' then

OPEN GET_PERSON_DETAILS;
FETCH GET_PERSON_DETAILS INTO L_PERSON_ID, l_object_version_number,
                              l_employee_number,l_ni_aggregate_assignment,
			      l_paye_aggregate_assignment,l_CURRENT_EMPLOYEE_FLAG;

IF GET_PERSON_DETAILS%FOUND THEN
IF NVL(l_paye_aggregate_assignment,'N') = 'N'
   and NVL(l_ni_aggregate_assignment,'N') = 'N'
   and l_CURRENT_EMPLOYEE_FLAG = 'Y' THEN

l_ni_aggregate_assignment := 'Y';
l_paye_aggregate_assignment := 'Y';

  HR_PERSON_API.update_gb_person (
   p_validate                     =>  l_validate
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => 'CORRECTION'
  ,p_person_id                    => L_PERSON_ID
  ,p_object_version_number        => l_object_version_number
  ,p_person_type_id               =>  hr_api.g_number
  ,p_last_name                    =>  hr_api.g_varchar2
  ,p_applicant_number             =>  hr_api.g_varchar2
  ,p_comments                     =>  hr_api.g_varchar2
  ,p_date_employee_data_verified  =>  hr_api.g_date
  ,p_date_of_birth                =>   hr_api.g_date
  ,p_email_address                =>  hr_api.g_varchar2
  ,p_employee_number              => l_employee_number
  ,p_expense_check_send_to_addres =>  hr_api.g_varchar2
  ,p_first_name                =>  hr_api.g_varchar2
  ,p_known_as                  =>   hr_api.g_varchar2
  ,p_marital_status            =>  hr_api.g_varchar2
  ,p_middle_names              =>  hr_api.g_varchar2
  ,p_nationality               =>  hr_api.g_varchar2
  ,p_ni_number                 =>  hr_api.g_varchar2
  ,p_previous_last_name        =>  hr_api.g_varchar2
  ,p_registered_disabled_flag  =>  hr_api.g_varchar2
  ,p_sex                       =>  hr_api.g_varchar2
  ,p_title                     =>  hr_api.g_varchar2
  ,p_vendor_id                 =>  hr_api.g_number
  ,p_work_telephone            =>  hr_api.g_varchar2
  ,p_attribute_category        =>  hr_api.g_varchar2
  ,p_attribute1                =>  hr_api.g_varchar2
  ,p_attribute2                =>  hr_api.g_varchar2
  ,p_attribute3                =>  hr_api.g_varchar2
  ,p_attribute4                =>  hr_api.g_varchar2
  ,p_attribute5                =>   hr_api.g_varchar2
  ,p_attribute6                =>   hr_api.g_varchar2
  ,p_attribute7                =>   hr_api.g_varchar2
  ,p_attribute8                =>  hr_api.g_varchar2
  ,p_attribute9                =>  hr_api.g_varchar2
  ,p_attribute10               =>  hr_api.g_varchar2
  ,p_attribute11               =>  hr_api.g_varchar2
  ,p_attribute12               =>   hr_api.g_varchar2
  ,p_attribute13               =>  hr_api.g_varchar2
  ,p_attribute14               =>  hr_api.g_varchar2
  ,p_attribute15               =>  hr_api.g_varchar2
  ,p_attribute16               =>  hr_api.g_varchar2
  ,p_attribute17               =>  hr_api.g_varchar2
  ,p_attribute18               =>   hr_api.g_varchar2
  ,p_attribute19               =>   hr_api.g_varchar2
  ,p_attribute20               =>  hr_api.g_varchar2
  ,p_attribute21               =>   hr_api.g_varchar2
  ,p_attribute22               =>   hr_api.g_varchar2
  ,p_attribute23               =>   hr_api.g_varchar2
  ,p_attribute24               =>   hr_api.g_varchar2
  ,p_attribute25               =>   hr_api.g_varchar2
  ,p_attribute26               =>   hr_api.g_varchar2
  ,p_attribute27               =>   hr_api.g_varchar2
  ,p_attribute28               =>  hr_api.g_varchar2
  ,p_attribute29               =>   hr_api.g_varchar2
  ,p_attribute30               =>   hr_api.g_varchar2
  ,p_ethnic_origin             =>   hr_api.g_varchar2
  ,p_director                  =>   hr_api.g_varchar2
  ,p_pensioner                 =>   hr_api.g_varchar2
  ,p_work_permit_number        =>   hr_api.g_varchar2
  ,p_addl_pension_years        =>   hr_api.g_varchar2
  ,p_addl_pension_months       =>   hr_api.g_varchar2
  ,p_addl_pension_days         =>   hr_api.g_varchar2
  ,p_ni_multiple_asg           =>   l_ni_aggregate_assignment
  ,p_paye_aggregate_assignment =>   l_paye_aggregate_assignment
  ,p_date_of_death             =>   hr_api.g_date
  ,p_background_check_status   =>   hr_api.g_varchar2
  ,p_background_date_check     =>   hr_api.g_date
  ,p_blood_type                =>   hr_api.g_varchar2
  ,p_correspondence_language   =>   hr_api.g_varchar2
  ,p_fast_path_employee        =>   hr_api.g_varchar2
  ,p_fte_capacity              =>   hr_api.g_number
  ,p_hold_applicant_date_until =>   hr_api.g_date
  ,p_honors                   =>   hr_api.g_varchar2
  ,p_internal_location        =>   hr_api.g_varchar2
  ,p_last_medical_test_by     =>   hr_api.g_varchar2
  ,p_last_medical_test_date   =>   hr_api.g_date
  ,p_mailstop                 =>   hr_api.g_varchar2
  ,p_office_number            =>   hr_api.g_varchar2
  ,p_on_military_service      =>   hr_api.g_varchar2
  ,p_pre_name_adjunct         =>   hr_api.g_varchar2
  ,p_projected_start_date     =>   hr_api.g_date
  ,p_rehire_authorizor        =>   hr_api.g_varchar2
  ,p_rehire_recommendation    =>   hr_api.g_varchar2
  ,p_resume_exists            =>  hr_api.g_varchar2
  ,p_resume_last_updated      =>   hr_api.g_date
  ,p_second_passport_exists   =>   hr_api.g_varchar2
  ,p_student_status           =>   hr_api.g_varchar2
  ,p_work_schedule            =>   hr_api.g_varchar2
  ,p_rehire_reason            =>   hr_api.g_varchar2
  ,p_suffix                   =>   hr_api.g_varchar2
  ,p_benefit_group_id         =>   hr_api.g_number
  ,p_receipt_of_death_cert_date =>   hr_api.g_date
  ,p_coord_ben_med_pln_no       =>   hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag      =>   hr_api.g_varchar2
  ,p_coord_ben_med_ext_er       =>   hr_api.g_varchar2
  ,p_coord_ben_med_pl_name      =>   hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_name  =>   hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_ident =>   hr_api.g_varchar2
  ,p_coord_ben_med_cvg_strt_dt    =>  hr_api.g_date
  ,p_coord_ben_med_cvg_end_dt  =>   hr_api.g_date
  ,p_uses_tobacco_flag         =>   hr_api.g_varchar2
  ,p_dpdnt_adoption_date       =>   hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag    =>   hr_api.g_varchar2
  ,p_original_date_of_hire     =>   hr_api.g_date
  ,p_adjusted_svc_date         =>   hr_api.g_date
  ,p_town_of_birth             =>   hr_api.g_varchar2
  ,p_region_of_birth           =>   hr_api.g_varchar2
  ,p_country_of_birth          =>   hr_api.g_varchar2
  ,p_global_person_id          =>   hr_api.g_varchar2
  ,p_party_id                  =>  hr_api.g_number
  ,p_npw_number                =>  hr_api.g_varchar2
  ,p_effective_start_date      => l_start_date
  ,p_effective_end_date        => l_end_date
  ,p_full_name                 => l_full_name
  ,p_comment_id                => l_comment_id
  ,p_name_combination_warning  => l_name_combination_warning
  ,p_assign_payroll_warning    => l_assign_payroll_warning
  ,p_orig_hire_warning         => l_orig_hire_warning );

  END IF;
 END IF;
 CLOSE GET_PERSON_DETAILS;
END IF;


 END AI_check_PAYE_NI_flags;


 PROCEDURE AU_check_PAYE_NI_flags (p_person_id IN NUMBER,
                               p_effective_date IN DATE,
			       p_datetrack_mode IN VARCHAR2,
			       P_CURRENT_EMPLOYEE_FLAG_O IN VARCHAR2) IS

CURSOR GET_PERSON_DETAILS IS
 SELECT papf.person_id, PAPF.object_version_number, PAPF.employee_number,
        PER_INFORMATION9, PER_INFORMATION10 ,CURRENT_EMPLOYEE_FLAG
 FROM  per_all_people_f PAPF
 WHERE papf.person_id = p_person_id
 AND p_effective_date BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.effective_end_date;

L_PERSON_ID PER_ALL_PEOPLE_F.PERSON_ID%TYPE;
l_validate Boolean;
l_object_version_number NUMBER;
l_employee_number PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE;
l_paye_aggregate_assignment PER_ALL_PEOPLE_F.PER_INFORMATION10%type;
l_ni_aggregate_assignment PER_ALL_PEOPLE_F.PER_INFORMATION10%type;
l_full_name PER_ALL_PEOPLE_F.full_name%TYPE;
l_comment_id number;
l_name_combination_warning boolean;
l_assign_payroll_warning   boolean;
l_orig_hire_warning        boolean;
l_end_date  date;
l_start_date date;
l_profile_value varchar2(30);
l_CURRENT_EMPLOYEE_FLAG PER_ALL_PEOPLE_F.CURRENT_EMPLOYEE_FLAG%type;

BEGIN

fnd_profile.get('GB_PAYE_NI_AGGREGATION',l_profile_value);
IF NVL(l_profile_value,'N') = 'Y' then

OPEN GET_PERSON_DETAILS;
FETCH GET_PERSON_DETAILS INTO L_PERSON_ID, l_object_version_number,
                              l_employee_number,l_ni_aggregate_assignment,
			      l_paye_aggregate_assignment,l_CURRENT_EMPLOYEE_FLAG;

IF GET_PERSON_DETAILS%FOUND THEN
IF NVL(l_paye_aggregate_assignment,'N') = 'N'
   and NVL(l_ni_aggregate_assignment,'N') = 'N'
   and NVL(l_CURRENT_EMPLOYEE_FLAG,'N') = 'Y'
   and NVL(P_CURRENT_EMPLOYEE_FLAG_O,'N') = 'N' THEN

l_ni_aggregate_assignment := 'Y';
l_paye_aggregate_assignment := 'Y';

  HR_PERSON_API.update_gb_person (
   p_validate                     =>  l_validate
  ,p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => 'CORRECTION'
  ,p_person_id                    => L_PERSON_ID
  ,p_object_version_number        => l_object_version_number
  ,p_person_type_id               =>  hr_api.g_number
  ,p_last_name                    =>  hr_api.g_varchar2
  ,p_applicant_number             =>  hr_api.g_varchar2
  ,p_comments                     =>  hr_api.g_varchar2
  ,p_date_employee_data_verified  =>  hr_api.g_date
  ,p_date_of_birth                =>   hr_api.g_date
  ,p_email_address                =>  hr_api.g_varchar2
  ,p_employee_number              => l_employee_number
  ,p_expense_check_send_to_addres =>  hr_api.g_varchar2
  ,p_first_name                =>  hr_api.g_varchar2
  ,p_known_as                  =>   hr_api.g_varchar2
  ,p_marital_status            =>  hr_api.g_varchar2
  ,p_middle_names              =>  hr_api.g_varchar2
  ,p_nationality               =>  hr_api.g_varchar2
  ,p_ni_number                 =>  hr_api.g_varchar2
  ,p_previous_last_name        =>  hr_api.g_varchar2
  ,p_registered_disabled_flag  =>  hr_api.g_varchar2
  ,p_sex                       =>  hr_api.g_varchar2
  ,p_title                     =>  hr_api.g_varchar2
  ,p_vendor_id                 =>  hr_api.g_number
  ,p_work_telephone            =>  hr_api.g_varchar2
  ,p_attribute_category        =>  hr_api.g_varchar2
  ,p_attribute1                =>  hr_api.g_varchar2
  ,p_attribute2                =>  hr_api.g_varchar2
  ,p_attribute3                =>  hr_api.g_varchar2
  ,p_attribute4                =>  hr_api.g_varchar2
  ,p_attribute5                =>   hr_api.g_varchar2
  ,p_attribute6                =>   hr_api.g_varchar2
  ,p_attribute7                =>   hr_api.g_varchar2
  ,p_attribute8                =>  hr_api.g_varchar2
  ,p_attribute9                =>  hr_api.g_varchar2
  ,p_attribute10               =>  hr_api.g_varchar2
  ,p_attribute11               =>  hr_api.g_varchar2
  ,p_attribute12               =>   hr_api.g_varchar2
  ,p_attribute13               =>  hr_api.g_varchar2
  ,p_attribute14               =>  hr_api.g_varchar2
  ,p_attribute15               =>  hr_api.g_varchar2
  ,p_attribute16               =>  hr_api.g_varchar2
  ,p_attribute17               =>  hr_api.g_varchar2
  ,p_attribute18               =>   hr_api.g_varchar2
  ,p_attribute19               =>   hr_api.g_varchar2
  ,p_attribute20               =>  hr_api.g_varchar2
  ,p_attribute21               =>   hr_api.g_varchar2
  ,p_attribute22               =>   hr_api.g_varchar2
  ,p_attribute23               =>   hr_api.g_varchar2
  ,p_attribute24               =>   hr_api.g_varchar2
  ,p_attribute25               =>   hr_api.g_varchar2
  ,p_attribute26               =>   hr_api.g_varchar2
  ,p_attribute27               =>   hr_api.g_varchar2
  ,p_attribute28               =>  hr_api.g_varchar2
  ,p_attribute29               =>   hr_api.g_varchar2
  ,p_attribute30               =>   hr_api.g_varchar2
  ,p_ethnic_origin             =>   hr_api.g_varchar2
  ,p_director                  =>   hr_api.g_varchar2
  ,p_pensioner                 =>   hr_api.g_varchar2
  ,p_work_permit_number        =>   hr_api.g_varchar2
  ,p_addl_pension_years        =>   hr_api.g_varchar2
  ,p_addl_pension_months       =>   hr_api.g_varchar2
  ,p_addl_pension_days         =>   hr_api.g_varchar2
  ,p_ni_multiple_asg           =>   l_ni_aggregate_assignment
  ,p_paye_aggregate_assignment =>   l_paye_aggregate_assignment
  ,p_date_of_death             =>   hr_api.g_date
  ,p_background_check_status   =>   hr_api.g_varchar2
  ,p_background_date_check     =>   hr_api.g_date
  ,p_blood_type                =>   hr_api.g_varchar2
  ,p_correspondence_language   =>   hr_api.g_varchar2
  ,p_fast_path_employee        =>   hr_api.g_varchar2
  ,p_fte_capacity              =>   hr_api.g_number
  ,p_hold_applicant_date_until =>   hr_api.g_date
  ,p_honors                   =>   hr_api.g_varchar2
  ,p_internal_location        =>   hr_api.g_varchar2
  ,p_last_medical_test_by     =>   hr_api.g_varchar2
  ,p_last_medical_test_date   =>   hr_api.g_date
  ,p_mailstop                 =>   hr_api.g_varchar2
  ,p_office_number            =>   hr_api.g_varchar2
  ,p_on_military_service      =>   hr_api.g_varchar2
  ,p_pre_name_adjunct         =>   hr_api.g_varchar2
  ,p_projected_start_date     =>   hr_api.g_date
  ,p_rehire_authorizor        =>   hr_api.g_varchar2
  ,p_rehire_recommendation    =>   hr_api.g_varchar2
  ,p_resume_exists            =>  hr_api.g_varchar2
  ,p_resume_last_updated      =>   hr_api.g_date
  ,p_second_passport_exists   =>   hr_api.g_varchar2
  ,p_student_status           =>   hr_api.g_varchar2
  ,p_work_schedule            =>   hr_api.g_varchar2
  ,p_rehire_reason            =>   hr_api.g_varchar2
  ,p_suffix                   =>   hr_api.g_varchar2
  ,p_benefit_group_id         =>   hr_api.g_number
  ,p_receipt_of_death_cert_date =>   hr_api.g_date
  ,p_coord_ben_med_pln_no       =>   hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag      =>   hr_api.g_varchar2
  ,p_coord_ben_med_ext_er       =>   hr_api.g_varchar2
  ,p_coord_ben_med_pl_name      =>   hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_name  =>   hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_ident =>   hr_api.g_varchar2
  ,p_coord_ben_med_cvg_strt_dt    =>  hr_api.g_date
  ,p_coord_ben_med_cvg_end_dt  =>   hr_api.g_date
  ,p_uses_tobacco_flag         =>   hr_api.g_varchar2
  ,p_dpdnt_adoption_date       =>   hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag    =>   hr_api.g_varchar2
  ,p_original_date_of_hire     =>   hr_api.g_date
  ,p_adjusted_svc_date         =>   hr_api.g_date
  ,p_town_of_birth             =>   hr_api.g_varchar2
  ,p_region_of_birth           =>   hr_api.g_varchar2
  ,p_country_of_birth          =>   hr_api.g_varchar2
  ,p_global_person_id          =>   hr_api.g_varchar2
  ,p_party_id                  =>  hr_api.g_number
  ,p_npw_number                =>  hr_api.g_varchar2
  ,p_effective_start_date      => l_start_date
  ,p_effective_end_date        => l_end_date
  ,p_full_name                 => l_full_name
  ,p_comment_id                => l_comment_id
  ,p_name_combination_warning  => l_name_combination_warning
  ,p_assign_payroll_warning    => l_assign_payroll_warning
  ,p_orig_hire_warning         => l_orig_hire_warning );

  END IF;
 END IF;
 CLOSE GET_PERSON_DETAILS;
END IF;

 END AU_check_PAYE_NI_flags;
-- End : bug#8370225
END PER_PER_AGGR;
--

/
