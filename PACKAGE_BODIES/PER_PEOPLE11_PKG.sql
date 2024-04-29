--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE11_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE11_PKG" AS
/* $Header: peper11t.pkb 120.2 2006/01/26 22:52:10 ghshanka noship $ */
--
procedure insert_row1(p_rowid in out nocopy VARCHAR2
        ,p_person_id in out nocopy NUMBER
        ,p_effective_start_date DATE
        ,p_effective_end_date DATE
        ,p_business_group_id NUMBER
        ,p_person_type_id NUMBER
        ,p_last_name VARCHAR2
        ,p_start_date DATE
        ,p_applicant_number IN OUT NOCOPY VARCHAR2
        ,p_comment_id NUMBER
        ,p_current_applicant_flag VARCHAR2
        ,p_current_emp_or_apl_flag VARCHAR2
        ,p_current_employee_flag VARCHAR2
        ,p_date_employee_data_verified DATE
        ,p_date_of_birth DATE
        ,p_email_address VARCHAR2
        ,p_employee_number IN OUT NOCOPY VARCHAR2
        ,p_expense_check_send_to_addr VARCHAR2
        ,p_first_name VARCHAR2
        ,p_full_name VARCHAR2
        ,p_known_as  VARCHAR2
        ,p_marital_status VARCHAR2
        ,p_middle_names  VARCHAR2
        ,p_nationality VARCHAR2
        ,p_national_identifier VARCHAR2
        ,p_previous_last_name VARCHAR2
        ,p_registered_disabled_flag VARCHAR2
        ,p_sex VARCHAR2
        ,p_title VARCHAR2
        ,p_suffix VARCHAR2
        ,p_vendor_id NUMBER
        ,p_work_telephone VARCHAR2
        ,p_request_id NUMBER
        ,p_program_application_id NUMBER
        ,p_program_id NUMBER
        ,p_program_update_date DATE
        ,p_a_cat VARCHAR2
        ,p_a1 VARCHAR2
        ,p_a2 VARCHAR2
        ,p_a3 VARCHAR2
        ,p_a4 VARCHAR2
        ,p_a5 VARCHAR2
        ,p_a6 VARCHAR2
        ,p_a7 VARCHAR2
        ,p_a8 VARCHAR2
        ,p_a9 VARCHAR2
        ,p_a10 VARCHAR2
        ,p_a11 VARCHAR2
        ,p_a12 VARCHAR2
        ,p_a13 VARCHAR2
        ,p_a14 VARCHAR2
        ,p_a15 VARCHAR2
        ,p_a16 VARCHAR2
        ,p_a17 VARCHAR2
        ,p_a18 VARCHAR2
        ,p_a19 VARCHAR2
        ,p_a20 VARCHAR2
        ,p_a21 VARCHAR2
        ,p_a22 VARCHAR2
        ,p_a23 VARCHAR2
        ,p_a24 VARCHAR2
        ,p_a25 VARCHAR2
        ,p_a26 VARCHAR2
        ,p_a27 VARCHAR2
        ,p_a28 VARCHAR2
        ,p_a29 VARCHAR2
        ,p_a30 VARCHAR2
        ,p_last_update_date DATE
        ,p_last_updated_by NUMBER
        ,p_last_update_login NUMBER
        ,p_created_by NUMBER
        ,p_creation_date DATE
        ,p_i_cat VARCHAR2
        ,p_i1 VARCHAR2
        ,p_i2 VARCHAR2
        ,p_i3 VARCHAR2
        ,p_i4 VARCHAR2
        ,p_i5 VARCHAR2
        ,p_i6 VARCHAR2
        ,p_i7 VARCHAR2
        ,p_i8 VARCHAR2
        ,p_i9 VARCHAR2
        ,p_i10 VARCHAR2
        ,p_i11 VARCHAR2
        ,p_i12 VARCHAR2
        ,p_i13 VARCHAR2
        ,p_i14 VARCHAR2
        ,p_i15 VARCHAR2
        ,p_i16 VARCHAR2
        ,p_i17 VARCHAR2
        ,p_i18 VARCHAR2
        ,p_i19 VARCHAR2
        ,p_i20 VARCHAR2
        ,p_i21 VARCHAR2
	,p_i22 VARCHAR2
	,p_i23 VARCHAR2
	,p_i24 VARCHAR2
	,p_i25 VARCHAR2
	,p_i26 VARCHAR2
	,p_i27 VARCHAR2
	,p_i28 VARCHAR2
	,p_i29 VARCHAR2
	,p_i30 VARCHAR2
        ,p_app_ass_status_type_id NUMBER
        ,p_emp_ass_status_type_id NUMBER
        ,p_create_defaults_for VARCHAR2
   ,p_work_schedule VARCHAR2
   ,p_correspondence_language VARCHAR2
   ,p_student_status VARCHAR2
   ,p_fte_capacity NUMBER
   ,p_on_military_service VARCHAR2
   ,p_second_passport_exists VARCHAR2
   ,p_background_check_status VARCHAR2
   ,p_background_date_check DATE
   ,p_blood_type VARCHAR2
   ,p_last_medical_test_date DATE
   ,p_last_medical_test_by VARCHAR2
   ,p_rehire_recommendation VARCHAR2
   ,p_rehire_reason VARCHAR2
   ,p_resume_exists VARCHAR2
   ,p_resume_last_updated DATE
   ,p_office_number VARCHAR2
   ,p_internal_location VARCHAR2
   ,p_mailstop VARCHAR2
   ,p_honors VARCHAR2
   ,p_pre_name_adjunct VARCHAR2
   ,p_hold_applicant_date_until DATE
   ,p_benefit_group_id NUMBER
   ,p_receipt_of_death_cert_date DATE
   ,p_coord_ben_med_pln_no VARCHAR2
   ,p_coord_ben_no_cvg_flag VARCHAR2
   ,p_uses_tobacco_flag VARCHAR2
   ,p_dpdnt_adoption_date DATE
   ,p_dpdnt_vlntry_svce_flag VARCHAR2
   ,p_date_of_death DATE
   ,p_original_date_of_hire DATE
   ,p_adjusted_svc_date DATE
   ,p_town_of_birth VARCHAR2
   ,p_region_of_birth VARCHAR2
   ,p_country_of_birth VARCHAR2
   ,p_global_person_id VARCHAR2
   ,p_fast_path_employee VARCHAR2 default null
   ,p_rehire_authorizor  VARCHAR2 default null
   ,p_party_id         number default null
   ,p_npw_number     IN OUT NOCOPY VARCHAR2
   ,p_current_npw_flag VARCHAR2 default null
   ,p_order_name       IN VARCHAR2
   ,p_global_name      IN VARCHAR2
   ,p_local_name       IN VARCHAR2
 ) is
--
-- Define Cursor.
--
cursor c1 is select per_people_s.nextval
             from sys.dual;
--
cursor c2 is select rowid
            from   per_all_people_f
            where  effective_start_date = p_effective_start_date
            and    effective_end_date = p_effective_end_date
            and    person_id = p_person_id;
--
cursor c_person is
  select *
  from   per_all_people_f
  where  person_id = p_person_id
  and    p_effective_start_date
         between effective_start_date
         and     effective_end_date;
--
l_person per_all_people_f%rowtype;
--
begin
   --
   -- Test current numbers are not used by
   -- the system already.
   --
  hr_utility.set_location('per_people11_pkg.insert_row1',10);
   hr_person.validate_unique_number(p_person_id    =>p_person_id
                                , p_business_group_id => p_business_group_id
                                , p_employee_number  => p_employee_number
                                , p_applicant_number => p_applicant_number
                                , p_npw_number       => null --p_npw_number
                                , p_current_employee => p_current_employee_flag
                                , p_current_applicant => p_current_applicant_flag
                                , p_current_npw       => null --p_current_npw_flag
                                );

  hr_utility.set_location('Employee  Number = '||p_employee_number,20);
  hr_utility.set_location('Applicant Number = '||p_applicant_number,30);

  --Start of fix for Bug 2167668

  IF p_start_date > p_hold_applicant_date_until THEN
    hr_utility.set_message('800', 'PER_289796_HOLD_UNTIL_DATE');
    hr_utility.set_message_token('HOLD_DATE', p_start_date );
    hr_utility.raise_error;
  END IF;
  -- End of fix for Bug 2167668

   -- #345205
   -- A new person id is only selected from the sequence if the value passed is
   -- not null already. This is used in Applicant Quick Entry when creating an
   -- applicant with an initial status of TERM_APL - this requires two person
   -- rows on successive days.
   -- DK 27-FEB-96
   if ( p_person_id is null ) then
      open c1;
      fetch c1 into p_person_id;
      close c1;
  hr_utility.set_location('per_people11_pkg.insert_row1',40);
   end if;
--
   /* BEGIN OF WWBUG 1975359 */
   if p_party_id is not null then
     --
     per_per_bus.chk_party_id
       (p_person_id             => p_person_id
       ,p_party_id              => p_party_id
       ,p_effective_date        => p_effective_start_date
       ,p_object_version_number => null);
     --
   end if;
   --
   /* END OF WWBUG 1975359 */
   --
   insert into PER_ALL_PEOPLE_F
    (person_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,person_type_id
    ,last_name
    ,start_date
    ,applicant_number
    ,comment_id
    ,current_applicant_flag
    ,current_emp_or_apl_flag
    ,current_employee_flag
    ,date_employee_data_verified
    ,date_of_birth
    ,town_of_birth
    ,region_of_birth
    ,country_of_birth
    ,global_person_id
    ,party_id
    ,email_address
    ,employee_number
    ,expense_check_send_to_address
    ,first_name
    ,full_name
    ,known_as
    ,marital_status
    ,middle_names
    ,nationality
    ,national_identifier
    ,previous_last_name
    ,registered_disabled_flag
    ,sex
    ,title
    ,suffix
    ,vendor_id
--    ,work_telephone
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
    ,attribute21
    ,attribute22
    ,attribute23
    ,attribute24
    ,attribute25
    ,attribute26
    ,attribute27
    ,attribute28
    ,attribute29
    ,attribute30
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date
    ,per_information_category
    ,per_information1
    ,per_information2
    ,per_information3
    ,per_information4
    ,per_information5
    ,per_information6
    ,per_information7
    ,per_information8
    ,per_information9
    ,per_information10
    ,per_information11
    ,per_information12
    ,per_information13
    ,per_information14
    ,per_information15
    ,per_information16
    ,per_information17
    ,per_information18
    ,per_information19
    ,per_information20
    ,per_information21
    ,per_information22
    ,per_information23
    ,per_information24
    ,per_information25
    ,per_information26
    ,per_information27
    ,per_information28
    ,per_information29
    ,per_information30
   ,work_schedule
   ,correspondence_language
   ,student_status
   ,fte_capacity
   ,on_military_service
   ,second_passport_exists
   ,background_check_status
   ,background_date_check
   ,blood_type
   ,last_medical_test_date
   ,last_medical_test_by
   ,rehire_recommendation
   ,rehire_reason
   ,resume_exists
   ,resume_last_updated
   ,office_number
   ,internal_location
   ,mailstop
   ,honors
   ,pre_name_adjunct
   ,hold_applicant_date_until
   ,benefit_group_id
   ,receipt_of_death_cert_date
   ,coord_ben_med_pln_no
   ,coord_ben_no_cvg_flag
   ,uses_tobacco_flag
   ,dpdnt_adoption_date
   ,dpdnt_vlntry_svce_flag
   ,date_of_death
   ,original_date_of_hire
   ,fast_path_employee
   ,rehire_authorizor
   ,npw_number
   ,current_npw_flag
   ,order_name
   ,global_name
   ,local_name
 )
   values
    (p_person_id
    ,p_effective_start_date
    ,p_effective_end_date
    ,p_business_group_id
--    ,p_person_type_id
    ,hr_person_type_usage_info.get_default_person_type_id(p_person_type_id)
    ,p_last_name
    ,p_start_date
    ,p_applicant_number
    ,p_comment_id
    ,p_current_applicant_flag
    ,p_current_emp_or_apl_flag
    ,p_current_employee_flag
    ,p_date_employee_data_verified
    ,p_date_of_birth
    ,p_town_of_birth
    ,p_region_of_birth
    ,p_country_of_birth
    ,p_global_person_id
    ,p_party_id
    ,p_email_address
    ,p_employee_number
    ,p_expense_check_send_to_addr
    ,p_first_name
    ,p_full_name
    ,p_known_as
    ,p_marital_status
    ,p_middle_names
    ,p_nationality
    ,p_national_identifier
    ,p_previous_last_name
    ,p_registered_disabled_flag
    ,p_sex
    ,p_title
   ,p_suffix
    ,p_vendor_id
--    ,p_work_telephone
    ,p_request_id
    ,p_program_application_id
    ,p_program_id
    ,p_program_update_date
    ,p_a_cat
    ,p_a1
    ,p_a2
    ,p_a3
    ,p_a4
    ,p_a5
    ,p_a6
    ,p_a7
    ,p_a8
    ,p_a9
    ,p_a10
    ,p_a11
    ,p_a12
    ,p_a13
    ,p_a14
    ,p_a15
    ,p_a16
    ,p_a17
    ,p_a18
    ,p_a19
    ,p_a20
    ,p_a21
    ,p_a22
    ,p_a23
    ,p_a24
    ,p_a25
    ,p_a26
    ,p_a27
    ,p_a28
    ,p_a29
    ,p_a30
    ,p_last_update_date
    ,p_last_updated_by
    ,p_last_update_login
    ,p_created_by
    ,p_creation_date
    ,p_i_cat
    ,p_i1
    ,p_i2
    ,p_i3
    ,p_i4
    ,p_i5
    ,p_i6
    ,p_i7
    ,p_i8
    ,p_i9
    ,p_i10
    ,p_i11
    ,p_i12
    ,p_i13
    ,p_i14
    ,p_i15
    ,p_i16
    ,p_i17
    ,p_i18
    ,p_i19
    ,p_i20
    ,p_i21
    ,p_i22
    ,p_i23
    ,p_i24
    ,p_i25
    ,p_i26
    ,p_i27
    ,p_i28
    ,p_i29
    ,p_i30
   ,p_work_schedule
   ,p_correspondence_language
   ,p_student_status
   ,p_fte_capacity
   ,p_on_military_service
   ,p_second_passport_exists
   ,p_background_check_status
   ,p_background_date_check
   ,p_blood_type
   ,p_last_medical_test_date
   ,p_last_medical_test_by
   ,p_rehire_recommendation
   ,p_rehire_reason
   ,p_resume_exists
   ,p_resume_last_updated
   ,p_office_number
   ,p_internal_location
   ,p_mailstop
   ,p_honors
   ,p_pre_name_adjunct
   ,p_hold_applicant_date_until
   ,p_benefit_group_id
   ,p_receipt_of_death_cert_date
   ,p_coord_ben_med_pln_no
   ,p_coord_ben_no_cvg_flag
   ,p_uses_tobacco_flag
   ,p_dpdnt_adoption_date
   ,p_dpdnt_vlntry_svce_flag
   ,p_date_of_death
   ,p_original_date_of_hire
   ,p_fast_path_employee
   ,p_rehire_authorizor
   ,p_npw_number
   ,p_current_npw_flag
   ,p_order_name
   ,p_global_name
   ,p_local_name
 );
  --
  -- Earlier version comments were moved from this place to
  -- after the command close c_person.
  --
  open c_person;
    --
    fetch c_person into l_person;
    --
  close c_person;
  --
  /* BEGIN OF WWBUG 1975359 */
/*   ------------------------------------------------
  -- BEGIN TCA_UNMERGE CHANGES
  --
  per_hrtca_merge.create_tca_person(p_rec => l_person);
  --
  hr_utility.set_location('Updating party id',10);
  --
  -- Now assign the resulting party id back to the record.
  --
  update per_all_people_f
    set party_id = l_person.party_id
    where person_id = p_person_id;
  --
  -- END TCA_UNMERGE CHANGES
*/
  /* END OF WWBUG 1975359 */
  --
  -- HR/WF synchronization call
  --
  /*  commenting out and moving to after ptu.  Bug 3297591.
  per_hrwf_synch.per_per_wf(p_rec      => l_person,
                            p_action   => 'INSERT');
  */
  --
  --
  hr_utility.set_location('per_people11_pkg.insert_row1',50);
  --
   open c2;
--
   fetch c2 into p_rowid;
--
  hr_utility.set_location('per_people11_pkg.insert_row1',60);
   close c2;
--
    ben_dt_trgr_handle.person(p_rowid => null
        ,p_business_group_id          => p_business_group_id
	,p_person_id                  => p_person_id
	,p_effective_start_date       => p_effective_start_date
	,p_effective_end_date         => p_effective_end_date
	,p_date_of_birth              => p_date_of_birth
	,p_date_of_death              => p_date_of_death
	,p_marital_status             => p_marital_status
	,p_on_military_service        => p_on_military_service
	,p_registered_disabled_flag   => p_registered_disabled_flag
	,p_sex                        => p_sex
	,p_student_status             => p_student_status
	,p_coord_ben_med_pln_no       => p_coord_ben_med_pln_no
	,p_coord_ben_no_cvg_flag      => p_coord_ben_no_cvg_flag
	,p_uses_tobacco_flag          => p_uses_tobacco_flag
	,p_benefit_group_id           => p_benefit_group_id
	,p_per_information10          => p_i10
	,p_original_date_of_hire      => p_original_date_of_hire
	,p_dpdnt_vlntry_svce_flag     => p_dpdnt_vlntry_svce_flag
	,p_receipt_of_death_cert_date => p_receipt_of_death_cert_date
	,p_attribute1                 => p_a1
	,p_attribute2                 =>p_a2
	,p_attribute3                 =>p_a3
	,p_attribute4                 =>p_a4
	,p_attribute5                 =>p_a5
	,p_attribute6                 =>p_a6
	,p_attribute7                 =>p_a7
	,p_attribute8                 =>p_a8
	,p_attribute9                 =>p_a9
	,p_attribute10                =>p_a10
	,p_attribute11                =>p_a11
	,p_attribute12                =>p_a12
	,p_attribute13                =>p_a13
	,p_attribute14                =>p_a14
	,p_attribute15                =>p_a15
	,p_attribute16                =>p_a16
	,p_attribute17                =>p_a17
	,p_attribute18                =>p_a18
	,p_attribute19                =>p_a19
	,p_attribute20                =>p_a20
	,p_attribute21                =>p_a21
	,p_attribute22                =>p_a22
	,p_attribute23                =>p_a23
	,p_attribute24                =>p_a24
	,p_attribute25                =>p_a25
	,p_attribute26                =>p_a26
	,p_attribute27                =>p_a27
	,p_attribute28                =>p_a28
	,p_attribute29                =>p_a29
	,p_attribute30                =>p_a30
);
--
--2448642: now we are securing by contacts, the security list maintenance must be done for all
--inserts (note CWK are done in their own API anyway, not here)
--2462779: Modification to avoce ref'd fix. Call populate_new_person for
--         EMPs and APLs but call populate_new_contact for new OTHERs.
--
   hr_utility.set_location('per_people11_pkg.insert_row1',70);
   --
   if p_create_defaults_for in ('EMP','APL') then
     hr_security_internal.populate_new_person
          (p_business_group_id=>p_business_group_id
          ,p_person_id        =>p_person_id);
   else
     hr_security_internal.populate_new_contact
          (p_business_group_id=>p_business_group_id
          ,p_person_id        =>p_person_id);
   end if;
   --
   hr_utility.set_location('per_people11_pkg.insert_row1',75);
   --
   if p_create_defaults_for in ('EMP','APL') then
      --
      -- #317298 We must insert a row into per_person_list for the new EMP
      -- or APL, otherwise secure users won't be able to see them until LISTGEN
      -- has next been run. This should be revisited as part of a wider security
      -- review. For example, #294004 points out that all users will be able
      -- to see the new person created here in the default business group, until
      -- their Org or Position is changed on the assignment AND LISTGEN is run.
      --
      -- For the time being, just put a row into per_person_list for the
      -- default business group if it doesn't have the VIEW_ALL_FLAG set. The
      -- 'not exists' check is there for defensive coding, and should never
      -- arise, as we're only dealing with new people.
      -- RMF 02-Feb-96.
      --
      --hr_security_internal.populate_new_person
      --(p_business_group_id=>p_business_group_id
      --,p_person_id        =>p_person_id);
      --
      if p_create_defaults_for = 'EMP' then
         --
         hr_utility.set_location('per_people11_pkg.insert_row1',80);
         -- insert employee rows.
         --
         -- VT 08/13/96
         per_people9_pkg.insert_employee_rows(p_person_id => p_person_id
                           ,p_effective_start_date => p_effective_start_date
                           ,p_effective_end_date => p_effective_end_date
                           ,p_business_group_id =>p_business_group_id
                           ,p_emp_ass_status_type_id => p_emp_ass_status_type_id
                           ,p_employee_number => p_employee_number
                           ,p_request_id => p_request_id
                           ,p_program_application_id => p_program_application_id
                           ,p_program_id => p_program_id
                           ,p_program_update_date => p_program_update_date
                           ,p_last_update_date => p_last_update_date
                           ,p_last_updated_by => p_last_updated_by
                           ,p_last_update_login => p_last_update_login
                           ,p_created_by => p_created_by
                           ,p_creation_date => p_creation_date
                           ,p_adjusted_svc_date =>p_adjusted_svc_date);

      else
         --
         hr_utility.set_location('per_people11_pkg.insert_row1',90);
         -- do insert applicant rows.
         --
         -- VT 08/13/96
         per_people9_pkg.insert_applicant_rows(p_person_id => p_person_id
                           ,p_effective_start_date => p_effective_start_date
                           ,p_effective_end_date => p_effective_end_date
                           ,p_business_group_id =>p_business_group_id
                           ,p_app_ass_status_type_id => p_app_ass_status_type_id
                           ,p_request_id => p_request_id
                           ,p_program_application_id => p_program_application_id
                           ,p_program_id => p_program_id
                           ,p_program_update_date => p_program_update_date
                           ,p_last_update_date => p_last_update_date
                           ,p_last_updated_by => p_last_updated_by
                           ,p_last_update_login => p_last_update_login
                           ,p_created_by => p_created_by
                           ,p_creation_date => p_creation_date
                           );
      end if;
      hr_utility.set_location('per_people11_pkg.insert_row1',100);
   end if;
--
-- PTU : Start of Changes
--
hr_utility.set_location('per_people11_pkg.insert_row1',110);
hr_per_type_usage_internal.maintain_person_type_usage
       (p_effective_date       => p_effective_start_date
       ,p_person_id            => p_person_id
       ,p_person_type_id       => p_person_type_id
       );
-- PTU : End of Changes
--
-- moved synch here - bug 3297591.
--
per_hrwf_synch.per_per_wf(p_rec      => l_person,
                          p_action   => 'INSERT');
--
hr_utility.set_location('Leaving: per_people11_pkg.insert_row1',120);
end insert_row1;
--
procedure delete_row1(p_rowid VARCHAR2) is

-- bug 4635241 starts here
--
 cursor c_person is
      select *
      from   per_all_people_f
      where rowid=chartorowid(p_rowid);

   cursor c_person1(p_esd per_all_people_f.effective_start_date%type
                    ,personid per_all_people_f.person_id%type) is
       select *
       from per_all_people_f
       where effective_start_date between  p_esd and sysdate
              and person_id=personid
               and effective_end_date > sysdate;

   cursor c_person2(p_esd per_all_people_f.effective_start_date%type
                    ,personid per_all_people_f.person_id%type) is
       select *
       from per_all_people_f
       where effective_start_date < p_esd
            and person_id=personid
           and effective_end_date > sysdate;

   l_person_rec per_all_people_f%rowtype;
   l_person_rec1 per_all_people_f%rowtype :=NULL;
--
-- bug 4635241 ends here

begin
--
-- bug 4635241 starts here
--
open c_person;
fetch c_person into l_person_rec;
close c_person;

-- bug 4635241 end here
--
  delete from per_all_people_f
   where rowid=chartorowid(p_rowid);
--
-- bug 4635241 starts here
--
 if ( l_person_rec.effective_start_date <= sysdate ) then
open c_person1(l_person_rec.effective_start_date,
               l_person_rec.person_id);
fetch c_person1 into l_person_rec1;
    if c_person1 % notfound then
      close c_person1;
         open c_person2(l_person_rec.effective_start_date,
                        l_person_rec.person_id);
          fetch c_person2 into l_person_rec1;
          close c_person2;
     end if ;
   close c_person1;
 --
if (l_person_rec1.person_id is not null) then
 per_hrwf_synch.per_per_wf(l_person_rec1,'INSERT');
end if;
--
end if;
-- bug 4635241 ends here
end delete_row1;
--
--
END PER_PEOPLE11_PKG;

/
