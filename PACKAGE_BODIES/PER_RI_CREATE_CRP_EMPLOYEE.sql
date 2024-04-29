--------------------------------------------------------
--  DDL for Package Body PER_RI_CREATE_CRP_EMPLOYEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CREATE_CRP_EMPLOYEE" As
/* $Header: pericemp.pkb 120.1 2006/02/27 23:33:48 balchand noship $ */
Function get_line_status(p_view Varchar2,p_dp_batch_line_id Number)
Return Varchar2 Is

Type csr_dp_line_status_type Is Ref Cursor;
csr_dp_line_status csr_dp_line_status_type;

l_status Varchar2(2);
l_sql_stmt Varchar2(200);
Begin

   l_sql_stmt :=  'Select line_status From '||p_view||' Where batch_line_id = :1';

   Open csr_dp_line_status For l_sql_stmt using p_dp_batch_line_id;
   Fetch csr_dp_line_status Into l_status;
   Close csr_dp_line_status;

return l_status;

End get_line_status;


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
                                ) as

l_person_user_key          Varchar2(240);
l_assignment_user_key      Varchar2(240);
l_address_user_key         Varchar2(240);
l_temp                     Varchar2(240);


l_dp_batch_line_id_emp     Number;
l_dp_batch_line_id_add     Number;
l_dp_batch_line_id_asg     Number;
l_dp_batch_line_id_asg_cri Number;
l_dp_batch_line_id_sal     Number;
l_dp_batch_line_id_acc     Number;

l_per_information_category Varchar2(240);

Cursor csr_get_per_user_keys(c_batch_line_id Number) Is
  Select p_person_user_key, p_assignment_user_key
    From hrdpv_create_employee
   Where batch_line_id = c_batch_line_id;

Cursor csr_get_add_user_key(c_batch_line_id Number) Is
  Select p_address_user_key
    From hrdpv_create_person_address
   Where batch_line_id = c_batch_line_id;

begin

  If p_data_pump_batch_line_id Is Not Null Then

     --get batch line ids

     l_dp_batch_line_id_emp        := substr(p_data_pump_batch_line_id,0,instr(p_data_pump_batch_line_id,'X',1,1)-1);
     l_dp_batch_line_id_add        := substr(p_data_pump_batch_line_id,instr(p_data_pump_batch_line_id,'X',1,1)+1,instr(p_data_pump_batch_line_id,'X',1,2)-instr(p_data_pump_batch_line_id,'X',1,1)-1);
     l_dp_batch_line_id_asg        := substr(p_data_pump_batch_line_id,instr(p_data_pump_batch_line_id,'X',1,2)+1,instr(p_data_pump_batch_line_id,'X',1,3)-instr(p_data_pump_batch_line_id,'X',1,2)-1);
     l_dp_batch_line_id_asg_cri    := substr(p_data_pump_batch_line_id,instr(p_data_pump_batch_line_id,'X',1,3)+1,instr(p_data_pump_batch_line_id,'X',1,4)-instr(p_data_pump_batch_line_id,'X',1,3)-1);
     l_dp_batch_line_id_sal        := substr(p_data_pump_batch_line_id,instr(p_data_pump_batch_line_id,'X',1,4)+1,instr(p_data_pump_batch_line_id,'X',1,5)-instr(p_data_pump_batch_line_id,'X',1,4)-1);
     l_dp_batch_line_id_acc        := substr(p_data_pump_batch_line_id,instr(p_data_pump_batch_line_id,'X',1,5)+1);


     --get User Keys

     Open csr_get_per_user_keys(l_dp_batch_line_id_emp);
     Fetch csr_get_per_user_keys Into l_person_user_key,l_assignment_user_key;
     Close csr_get_per_user_keys;

     Open csr_get_add_user_key(l_dp_batch_line_id_add);
     Fetch csr_get_add_user_key Into l_address_user_key;
     Close csr_get_add_user_key;


  Else

   select  to_char(sysdate,'J')||to_char(sysdate,'HH24MISS')||dbms_utility.get_hash_value(p_last_name||p_sex||p_first_name,0,1000)
   into l_temp
   from dual;

    l_person_user_key     := 'RI~PER~'||l_temp;
    l_assignment_user_key := 'RI~ASG~'||l_temp;
    l_address_user_key    := 'RI~ADD~'||l_temp;

  End If;

If l_dp_batch_line_id_emp Is Null Or get_line_status('HRDPV_CREATE_EMPLOYEE',l_dp_batch_line_id_emp) <> 'C' Then

-- Added because for all legislations which only have an international address style
-- donot have the legislation code same as the context code of the address descr. flex
-- and hence all those legislations have to be covered one after another here in this if
-- condition and also taken care of in the PerAdiEngine.java file
if  p_per_information_category  = 'AU_GLB' then
	l_per_information_category := 'AU';
        l_person_user_key     := 'EMP~'||p_first_name || '~' || p_last_name || '~' || p_hire_date;
        l_assignment_user_key := 'ASG~'||p_first_name || '~' || p_last_name || '~' || p_hire_date;
        l_address_user_key    := 'ADD~'||p_first_name || '~' || p_last_name || '~' || p_hire_date;
else
        l_per_information_category := p_per_information_category;
end if;


hrdpp_create_employee.insert_batch_lines( p_batch_id                            => p_batch_id
                                         ,p_data_pump_batch_line_id             => l_dp_batch_line_id_emp
                                         ,p_user_sequence                       => 1
                                         ,p_link_value                          => p_link_value
                                         ,p_hire_date                           => p_hire_date
                                         ,p_last_name                           => p_last_name
                                         ,p_sex                                 => p_sex
                                         ,p_per_comments                        => p_per_comments
                                         ,p_date_employee_data_verified         => p_date_employee_data_verified
                                         ,p_date_of_birth                       => p_date_of_birth
                                         ,p_email_address                       => p_email_address
                                         ,p_employee_number                     => p_employee_number
                                         ,p_expense_check_send_to_addres        => p_expense_check_send_to_addres
                                         ,p_first_name                          => p_first_name
                                         ,p_known_as                            => p_known_as
                                         ,p_marital_status                      => p_marital_status
                                         ,p_middle_names                        => p_middle_names
                                         ,p_nationality                         => p_nationality
                                         ,p_national_identifier                 => p_national_identifier
                                         ,p_previous_last_name                  => p_previous_last_name
                                         ,p_registered_disabled_flag            => p_registered_disabled_flag
                                         ,p_title                               => p_title
                                         ,p_work_telephone                      => p_work_telephone
                                         ,p_attribute_category                  => p_attribute_category
                                         ,p_attribute1                          => p_attribute1
                                         ,p_attribute2                          => p_attribute2
                                         ,p_attribute3                          => p_attribute3
                                         ,p_attribute4                          => p_attribute4
                                         ,p_attribute5                          => p_attribute5
                                         ,p_attribute6                          => p_attribute6
                                         ,p_attribute7                          => p_attribute7
                                         ,p_attribute8                          => p_attribute8
                                         ,p_attribute9                          => p_attribute9
                                         ,p_attribute10                         => p_attribute10
                                         ,p_attribute11                         => p_attribute11
                                         ,p_attribute12                         => p_attribute12
                                         ,p_attribute13                         => p_attribute13
                                         ,p_attribute14                         => p_attribute14
                                         ,p_attribute15                         => p_attribute15
                                         ,p_attribute16                         => p_attribute16
                                         ,p_attribute17                         => p_attribute17
                                         ,p_attribute18                         => p_attribute18
                                         ,p_attribute19                         => p_attribute19
                                         ,p_attribute20                         => p_attribute20
                                         ,p_attribute21                         => p_attribute21
                                         ,p_attribute22                         => p_attribute22
                                         ,p_attribute23                         => p_attribute23
                                         ,p_attribute24                         => p_attribute24
                                         ,p_attribute25                         => p_attribute25
                                         ,p_attribute26                         => p_attribute26
                                         ,p_attribute27                         => p_attribute27
                                         ,p_attribute28                         => p_attribute28
                                         ,p_attribute29                         => p_attribute29
                                         ,p_attribute30                         => p_attribute30
                                         ,p_per_information_category            => l_per_information_category
                                         ,p_per_information1                    => p_per_information1
                                         ,p_per_information2                    => p_per_information2
                                         ,p_per_information3                    => p_per_information3
                                         ,p_per_information4                    => p_per_information4
                                         ,p_per_information5                    => p_per_information5
                                         ,p_per_information6                    => p_per_information6
                                         ,p_per_information7                    => p_per_information7
                                         ,p_per_information8                    => p_per_information8
                                         ,p_per_information9                    => p_per_information9
                                         ,p_per_information10                   => p_per_information10
                                         ,p_per_information11                   => p_per_information11
                                         ,p_per_information12                   => p_per_information12
                                         ,p_per_information13                   => p_per_information13
                                         ,p_per_information14                   => p_per_information14
                                         ,p_per_information15                   => p_per_information15
                                         ,p_per_information16                   => p_per_information16
                                         ,p_per_information17                   => p_per_information17
                                         ,p_per_information18                   => p_per_information18
                                         ,p_per_information19                   => p_per_information19
                                         ,p_per_information20                   => p_per_information20
                                         ,p_per_information21                   => p_per_information21
                                         ,p_per_information22                   => p_per_information22
                                         ,p_per_information23                   => p_per_information23
                                         ,p_per_information24                   => p_per_information24
                                         ,p_per_information25                   => p_per_information25
                                         ,p_per_information26                   => p_per_information26
                                         ,p_per_information27                   => p_per_information27
                                         ,p_per_information28                   => p_per_information28
                                         ,p_per_information29                   => p_per_information29
                                         ,p_per_information30                   => p_per_information30
                                         ,p_date_of_death                       => p_date_of_death
                                         ,p_background_check_status             => p_background_check_status
                                         ,p_background_date_check               => p_background_date_check
                                         ,p_blood_type                          => p_blood_type
                                         ,p_fast_path_employee                  => p_fast_path_employee
                                         ,p_fte_capacity                        => p_fte_capacity
                                         ,p_honors                              => p_honors
                                         ,p_internal_location                   => p_internal_location
                                         ,p_last_medical_test_by                => p_last_medical_test_by
                                         ,p_last_medical_test_date              => p_last_medical_test_date
                                         ,p_mailstop                            => p_mailstop
                                         ,p_office_number                       => p_office_number
                                         ,p_on_military_service                 => p_on_military_service
                                         ,p_pre_name_adjunct                    => p_pre_name_adjunct
                                         ,p_projected_start_date                => p_projected_start_date
                                         ,p_resume_exists                       => p_resume_exists
                                         ,p_resume_last_updated                 => p_resume_last_updated
                                         ,p_second_passport_exists              => null
                                         ,p_student_status                      => null
                                         ,p_work_schedule                       => null
                                         ,p_suffix                              => p_suffix
                                         ,p_receipt_of_death_cert_date          => p_receipt_of_death_cert_date
                                         ,p_coord_ben_med_pln_no                => p_coord_ben_med_pln_no
                                         ,p_coord_ben_no_cvg_flag               => null
                                         ,p_coord_ben_med_ext_er                => p_coord_ben_med_ext_er
                                         ,p_coord_ben_med_pl_name               => p_coord_ben_med_pl_name
                                         ,p_coord_ben_med_insr_crr_name         => p_coord_ben_med_insr_crr_name
                                         ,p_coord_ben_med_insr_crr_ident        => p_coord_ben_med_insr_crr_ident
                                         ,p_coord_ben_med_cvg_strt_dt           => p_coord_ben_med_cvg_strt_dt
                                         ,p_coord_ben_med_cvg_end_dt            => p_coord_ben_med_cvg_end_dt
                                         ,p_uses_tobacco_flag                   => p_uses_tobacco_flag
                                         ,p_dpdnt_adoption_date                 => p_dpdnt_adoption_date
                                         ,p_dpdnt_vlntry_svce_flag              => p_dpdnt_vlntry_svce_flag
                                         ,p_original_date_of_hire               => p_original_date_of_hire
                                         ,p_adjusted_svc_date                   => p_adjusted_svc_date
                                         ,p_town_of_birth                       => p_town_of_birth
                                         ,p_region_of_birth                     => p_region_of_birth
                                         ,p_country_of_birth                    => p_country_of_birth
                                         ,p_global_person_id                    => p_global_person_id
                                         ,p_party_id                            => p_party_id
                                         ,p_person_user_key                     => l_person_user_key
                                         ,p_assignment_user_key                 => l_assignment_user_key
                                         ,p_user_person_type                    => p_user_person_type
                                         ,p_language_code                       => p_language_code
                                         ,p_vendor_name                         => p_vendor_name
                                         ,p_correspondence_language             => p_correspondence_language
                                         ,p_benefit_group                       => p_benefit_group
                                         );


End If;


If l_dp_batch_line_id_add Is Null Or get_line_status('HRDPV_CREATE_PERSON_ADDRESS',l_dp_batch_line_id_add) <> 'C' Then

hrdpp_create_person_address.insert_batch_lines(  p_batch_id                       => p_batch_id
                                                ,p_data_pump_batch_line_id        => l_dp_batch_line_id_add
                                                ,p_user_sequence                  => 2
                                                ,p_link_value                     => p_link_value
                                                ,p_effective_date                 => p_hire_date
                                                ,p_pradd_ovlapval_override        => p_pradd_ovlapval_override
                                                ,p_validate_county                => p_validate_county
                                                ,p_primary_flag                   => p_primary_flag
                                                ,p_style                          => p_style
                                                ,p_date_from                      => p_hire_date
                                                ,p_date_to                        => p_date_to
                                                ,p_address_type                   => p_address_type
                                                ,p_comments                       => p_comments
                                                ,p_address_line1                  => p_address_line1
                                                ,p_address_line2                  => p_address_line2
                                                ,p_address_line3                  => p_address_line3
                                                ,p_town_or_city                   => p_town_or_city
                                                ,p_region_1                       => p_region_1
                                                ,p_region_2                       => p_region_2
                                                ,p_region_3                       => p_region_3
                                                ,p_postal_code                    => p_postal_code
                                                ,p_telephone_number_1             => p_telephone_number_1
                                                ,p_telephone_number_2             => p_telephone_number_2
                                                ,p_telephone_number_3             => p_telephone_number_3
                                                ,p_addr_attribute_category        => p_addr_attribute_category
                                                ,p_addr_attribute1                => p_addr_attribute1
                                                ,p_addr_attribute2                => p_addr_attribute2
                                                ,p_addr_attribute3                => p_addr_attribute3
                                                ,p_addr_attribute4                => p_addr_attribute4
                                                ,p_addr_attribute5                => p_addr_attribute5
                                                ,p_addr_attribute6                => p_addr_attribute6
                                                ,p_addr_attribute7                => p_addr_attribute7
                                                ,p_addr_attribute8                => p_addr_attribute8
                                                ,p_addr_attribute9                => p_addr_attribute9
                                                ,p_addr_attribute10               => p_addr_attribute10
                                                ,p_addr_attribute11               => p_addr_attribute11
                                                ,p_addr_attribute12               => p_addr_attribute12
                                                ,p_addr_attribute13               => p_addr_attribute13
                                                ,p_addr_attribute14               => p_addr_attribute14
                                                ,p_addr_attribute15               => p_addr_attribute15
                                                ,p_addr_attribute16               => p_addr_attribute16
                                                ,p_addr_attribute17               => p_addr_attribute17
                                                ,p_addr_attribute18               => p_addr_attribute18
                                                ,p_addr_attribute19               => p_addr_attribute19
                                                ,p_addr_attribute20               => p_addr_attribute20
                                                ,p_add_information13              => p_add_information13
                                                ,p_add_information14              => p_add_information14
                                                ,p_add_information15              => p_add_information15
                                                ,p_add_information16              => p_add_information16
                                                ,p_add_information17              => p_add_information17
                                                ,p_add_information18              => p_add_information18
                                                ,p_add_information19              => p_add_information19
                                                ,p_add_information20              => p_add_information20
                                                ,p_party_id                       => p_party_id
                                                ,p_address_user_key               => l_address_user_key
                                                ,p_person_user_key                => l_person_user_key
                                                ,p_country                        => p_country
                                                );
End If;

If (p_gre Is Not Null) AND (l_dp_batch_line_id_asg Is Null Or get_line_status('HRDPV_UPDATE_EMP_ASG',l_dp_batch_line_id_asg) <> 'C') Then

hrdpp_update_emp_asg.insert_batch_lines(p_batch_id                => p_batch_id
                                       ,p_data_pump_batch_line_id => l_dp_batch_line_id_asg
                                       ,p_user_sequence           => 3
                                       ,p_effective_date          => p_hire_date
                                       ,p_datetrack_update_mode   => 'CORRECTION'
                                       ,p_cagr_grade_def_id       => null
                                       ,p_assignment_user_key     => l_assignment_user_key
                                       ,p_con_seg_user_name       => null
                                       ,p_segment1                => p_gre
                                       );
End If;


If (p_payroll_name Is Not Null or p_asg_location Is Not Null Or p_pay_basis Is Not Null)
 AND (l_dp_batch_line_id_asg_cri Is Null Or get_line_status('HRDPV_UPDATE_EMP_ASG_CRITERIA',l_dp_batch_line_id_asg_cri) <> 'C') Then

hrdpp_update_emp_asg_criteria.insert_batch_lines(p_batch_id                => p_batch_id
                                                ,p_data_pump_batch_line_id => l_dp_batch_line_id_asg_cri
                                                ,p_user_sequence           => 4
                                                ,p_effective_date          => p_hire_date
                                                ,p_datetrack_update_mode   => 'CORRECTION'
                                                ,p_special_ceiling_step_id => null
                                                ,p_people_group_id         => null
                                                ,p_assignment_user_key     => l_assignment_user_key
                                                ,p_payroll_name            => p_payroll_name
                                                ,p_location_code           => p_asg_location
                                                ,p_language_code           => userenv('lang')
                                                ,p_pay_basis_name          => p_pay_basis
                                                ,p_con_seg_user_name       => null
                                                );

End If;


If (p_proposed_salary Is Not Null or p_change_date Is Not Null Or p_proposal_reason Is Not Null )
 AND (l_dp_batch_line_id_sal Is Null Or get_line_status('HRDPV_UPLOAD_SALARY_PROPOSAL',l_dp_batch_line_id_sal) <> 'C') Then

hrdpp_upload_salary_proposal.insert_batch_lines(p_batch_id                       => p_batch_id
                                                ,p_data_pump_batch_line_id       => l_dp_batch_line_id_sal
                                                ,p_user_sequence                 => 5
                                                ,p_change_date                   => p_change_date
                                                ,p_proposed_salary               => p_proposed_salary
                                                ,p_proposal_reason               => p_proposal_reason
                                                ,p_pay_proposal_id               => null
                                                ,p_object_version_number         => null
                                                ,p_component_reason_1            => null
                                                ,p_approved_1                    => null
                                                ,p_component_id_1                => null
                                                ,p_ppc_object_version_number_1   => null
                                                ,p_component_reason_2            => null
                                                ,p_approved_2                    => null
                                                ,p_component_id_2                => null
                                                ,p_ppc_object_version_number_2   => null
                                                ,p_component_reason_3            => null
                                                ,p_approved_3                    => null
                                                ,p_component_id_3                => null
                                                ,p_ppc_object_version_number_3   => null
                                                ,p_component_reason_4            => null
                                                ,p_approved_4                    => null
                                                ,p_component_id_4                => null
                                                ,p_ppc_object_version_number_4   => null
                                                ,p_component_reason_5            => null
                                                ,p_approved_5                    => null
                                                ,p_component_id_5                => null
                                                ,p_ppc_object_version_number_5   => null
                                                ,p_component_reason_6            => null
                                                ,p_approved_6                    => null
                                                ,p_component_id_6                => null
                                                ,p_ppc_object_version_number_6   => null
                                                ,p_component_reason_7            => null
                                                ,p_approved_7                    => null
                                                ,p_component_id_7                => null
                                                ,p_ppc_object_version_number_7   => null
                                                ,p_component_reason_8            => null
                                                ,p_approved_8                    => null
                                                ,p_component_id_8                => null
                                                ,p_ppc_object_version_number_8   => null
                                                ,p_component_reason_9            => null
                                                ,p_approved_9                    => null
                                                ,p_component_id_9                => null
                                                ,p_ppc_object_version_number_9   => null
                                                ,p_component_reason_10           => null
                                                ,p_approved_10                   => null
                                                ,p_component_id_10               => null
                                                ,p_ppc_object_version_number_10  => null
                                                ,p_assignment_user_key           => l_assignment_user_key
                                                );
End If;


  If l_dp_batch_line_id_acc Is Null Or get_line_status('HRDPV_CREATE_USER_ACCT',l_dp_batch_line_id_acc) <> 'C' Then

     hrdpp_create_user_acct.insert_batch_lines(p_batch_id                             => p_batch_id
                                              ,p_data_pump_batch_line_id              => l_dp_batch_line_id_acc
                                              ,p_per_effective_start_date             => p_hire_date
                                              ,p_user_sequence                        => 6
                                              ,p_hire_date                            => p_hire_date
                                              ,p_date_from                            => p_hire_date
                                              ,p_person_user_key                      => l_person_user_key
                                              );

 End If;

End insert_batch_lines;

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
 ,p_hire_date                   In Date) Is

Cursor csr_emp_details Is
   Select emp.last_name
         ,emp.first_name
         ,emp.full_name
         ,emp.email_address
     From per_people_f emp
    Where emp.person_id = p_person_id
      and emp.effective_start_date = p_per_effective_start_date
      and emp.effective_end_date   = nvl(p_per_effective_end_date,emp.effective_end_date);

Cursor csr_responsibility_details Is
   Select res.application_id
         ,res.responsibility_id
     From fnd_responsibility res
    Where res.responsibility_key = 'EMPLOYEE_DIRECT_ACCESS_V4.0';

l_last_name  Varchar2(150);
l_first_name Varchar2(150);
l_full_name  Varchar2(240);
l_email_address Varchar2(240);

l_application_id Number;
l_responsibility_id Number;

Begin

  Open csr_emp_details;
  Fetch csr_emp_details Into l_last_name, l_first_name, l_full_name, l_email_address;
  Close csr_emp_details;

  hr_user_acct_utility.g_fnd_user_rec.user_name     := l_first_name||'.'||l_last_name;
  hr_user_acct_utility.g_fnd_user_rec.password      := 'Welcome';
  hr_user_acct_utility.g_fnd_user_rec.email_address := l_email_address;
  hr_user_acct_utility.g_fnd_user_rec.password_date := p_hire_date;
  hr_user_acct_utility.g_fnd_user_rec.employee_id   := p_person_id;

  Open csr_responsibility_details;
  Fetch csr_responsibility_details Into l_application_id, l_responsibility_id;
  Close csr_responsibility_details;

  hr_user_acct_utility.g_fnd_resp_tbl(1).existing_resp_id     := l_responsibility_id;
  hr_user_acct_utility.g_fnd_resp_tbl(1).existing_resp_key    := 'EMPLOYEE_DIRECT_ACCESS_V4.0';
  hr_user_acct_utility.g_fnd_resp_tbl(1).existing_resp_app_id := l_application_id;
  hr_user_acct_utility.g_fnd_resp_tbl(1).sec_group_id         := 0;
  hr_user_acct_utility.g_fnd_resp_tbl(1).sec_profile_id       := 0;
  hr_user_acct_utility.g_fnd_resp_tbl(1).user_resp_start_date := p_hire_date;

End set_user_acct_details;

End per_ri_create_crp_employee;

/
