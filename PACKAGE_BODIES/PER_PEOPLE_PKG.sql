--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE_PKG" AS
/* $Header: peper01t.pkb 120.0 2005/05/31 13:31:01 appldev noship $ */
--
procedure insert_row(p_rowid in out nocopy VARCHAR2
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
    ,p_known_as VARCHAR2
    ,p_marital_status VARCHAR2
    ,p_middle_names VARCHAR2
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
    ,p_party_id number default null
    ,p_blood_type            VARCHAR2 default NULL
    ,p_correspondence_language VARCHAR2 default NULL
    ,p_honors                 VARCHAR2 default NULL
    ,p_pre_name_adjunct       VARCHAR2 default NULL
    ,p_rehire_authorizor      VARCHAR2 default NULL
    ,p_rehire_recommendation  VARCHAR2 default NULL
    ,p_resume_exists          VARCHAR2 default NULL
    ,p_resume_last_updated    DATE default NULL
    ,p_second_passport_exists VARCHAR2 default NULL
    ,p_student_status     VARCHAR2 default NULL
    ,p_date_of_death      DATE default NULL
    ,p_uses_tobacco_flag  VARCHAR2 default NULL
    ,p_town_of_birth      VARCHAR2 default NULL
    ,p_region_of_birth    VARCHAR2 default NULL
    ,p_country_of_birth   VARCHAR2 default NULL
    ,p_fast_path_employee VARCHAR2 default NULL
    ,p_fte_capacity    VARCHAR2 default NULL) is
--
-- Define Cursor.
--
cursor c1 is select per_people_s.nextval
             from sys.dual;
--
cursor c2 is select rowid
            from   per_people_f
            where  effective_start_date = p_effective_start_date
            and    effective_end_date = p_effective_end_date
            and    person_id = p_person_id;
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
l_phone_ovn        number;
l_phone_id         number;
l_person_type_id   number;
--
l_full_name        per_all_people_f.full_name%TYPE;
l_order_name       per_all_people_f.order_name%TYPE;
l_global_name      per_all_people_f.global_name%TYPE;
l_local_name       per_all_people_f.local_name%TYPE;
l_duplicate_flag   varchar2(10);
--
begin
   l_phone_ovn      := NULL ;
   l_phone_id       := NULL ;
   l_person_type_id := p_person_type_id;
   --
   -- Test current numbers are not used by
   -- the system already.
   --
   hr_person.validate_unique_number(p_person_id    => p_person_id
                                , p_business_group_id => p_business_group_id
                                , p_employee_number  => p_employee_number
                                , p_applicant_number => p_applicant_number
                                , p_npw_number       => null --p_npw_number
                                , p_current_employee => p_current_employee_flag
                                , p_current_applicant => p_current_applicant_flag
                                , p_current_npw       => null --p_current_npw_flag
                                );
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
   end if;

  -- Verify party id, if one is passed in
  if p_party_id is not null then
    --
    per_per_bus.chk_party_id
      (p_person_id             => p_person_id
      ,p_party_id              => p_party_id
      ,p_effective_date        => p_effective_start_date
      ,p_object_version_number => null);
   end if;
--
  -- Enh 3889584. Derive names
  hr_person_name.derive_person_names -- #3889584
    (p_format_name        =>  NULL, -- derive all person names
     p_business_group_id  =>  p_business_group_id,
     p_person_id          =>  p_person_id,
     p_first_name         =>  p_first_name,
     p_middle_names       =>  p_middle_names,
     p_last_name          =>  p_last_name,
     p_known_as           =>  p_known_as,
     p_title              =>  p_title,
     p_suffix             =>  p_suffix,
     p_pre_name_adjunct   =>  p_pre_name_adjunct,
     p_date_of_birth      =>  p_date_of_birth,
     p_previous_last_name =>  p_previous_last_name ,
     p_email_address     =>   p_email_address,
     p_employee_number    =>  p_employee_number  ,
     p_applicant_number   =>  p_applicant_number  ,
     p_npw_number         =>  NULL,
     p_per_information1   =>  p_i1  ,
     p_per_information2   =>  p_i2  ,
     p_per_information3   =>  p_i3  ,
     p_per_information4   =>  p_i4  ,
     p_per_information5   =>  p_i5  ,
     p_per_information6   =>  p_i6  ,
     p_per_information7   =>  p_i7  ,
     p_per_information8   =>  p_i8  ,
     p_per_information9   =>  p_i9  ,
     p_per_information10  =>  p_i10  ,
     p_per_information11  =>  p_i11  ,
     p_per_information12  =>  p_i12  ,
     p_per_information13  =>  p_i13  ,
     p_per_information14  =>  p_i14  ,
     p_per_information15  =>  p_i15  ,
     p_per_information16  =>  p_i16  ,
     p_per_information17  =>  p_i17  ,
     p_per_information18  =>  p_i18  ,
     p_per_information19  =>  p_i19  ,
     p_per_information20  =>  p_i20  ,
     p_per_information21  =>  p_i21  ,
     p_per_information22  =>  p_i22  ,
     p_per_information23  =>  p_i23  ,
     p_per_information24  =>  p_i24  ,
     p_per_information25  =>  p_i25  ,
     p_per_information26  =>  p_i26  ,
     p_per_information27  =>  p_i27  ,
     p_per_information28  =>  p_i28  ,
     p_per_information29  =>  p_i29  ,
     p_per_information30  =>  p_i30  ,
     p_attribute1         =>  p_a1  ,
     p_attribute2         =>  p_a2  ,
     p_attribute3         =>  p_a3  ,
     p_attribute4         =>  p_a4  ,
     p_attribute5         =>  p_a5  ,
     p_attribute6         =>  p_a6  ,
     p_attribute7         =>  p_a7  ,
     p_attribute8         =>  p_a8  ,
     p_attribute9         =>  p_a9  ,
     p_attribute10        =>  p_a10  ,
     p_attribute11        =>  p_a11  ,
     p_attribute12        =>  p_a12  ,
     p_attribute13        =>  p_a13  ,
     p_attribute14        =>  p_a14  ,
     p_attribute15        =>  p_a15  ,
     p_attribute16        =>  p_a16  ,
     p_attribute17        =>  p_a17  ,
     p_attribute18        =>  p_a18  ,
     p_attribute19        =>  p_a19  ,
     p_attribute20        =>  p_a20  ,
     p_attribute21        =>  p_a21  ,
     p_attribute22        =>  p_a22  ,
     p_attribute23        =>  p_a23,
     p_attribute24        =>  p_a24,
     p_attribute25        =>  p_a25,
     p_attribute26        =>  p_a26,
     p_attribute27        =>  p_a27,
     p_attribute28        =>  p_a28,
     p_attribute29        =>  p_a29,
     p_attribute30        =>  p_a30,
     p_full_name          =>  l_full_name,
     p_order_name         =>  l_order_name,
     p_global_name        =>  l_global_name,
     p_local_name         =>  l_local_name,
     p_duplicate_flag     =>  l_duplicate_flag);
  --
   insert into PER_PEOPLE_F
    (person_id
    ,party_id
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
--    ,work_telephone    -- Now done by the create_phone business process call
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
    ,blood_type
    ,correspondence_language
    ,honors
    ,pre_name_adjunct
    ,rehire_authorizor
    ,rehire_recommendation
    ,resume_exists
    ,resume_last_updated
    ,second_passport_exists
    ,student_status
    ,date_of_death
    ,uses_tobacco_flag
    ,town_of_birth
    ,region_of_birth
    ,country_of_birth
    ,fast_path_employee
    ,fte_capacity
    ,order_name
    ,global_name
    ,local_name   )
   values
    (p_person_id
    ,p_party_id
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
    ,p_email_address
    ,p_employee_number
    ,p_expense_check_send_to_addr
    ,p_first_name
    ,l_full_name
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
--    ,p_work_telephone   -- Now done by the create_phone business process call
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
    ,p_blood_type
    ,p_correspondence_language
    ,p_honors
    ,p_pre_name_adjunct
    ,p_rehire_authorizor
    ,p_rehire_recommendation
    ,p_resume_exists
    ,p_resume_last_updated
    ,p_second_passport_exists
    ,p_student_status
    ,p_date_of_death
    ,p_uses_tobacco_flag
    ,p_town_of_birth
    ,p_region_of_birth
    ,p_country_of_birth
    ,p_fast_path_employee
    ,p_fte_capacity
    ,l_order_name
    ,l_global_name
    ,l_local_name   );
--
   /* BEGIN OF PARTY_ID WORK */
  --
  open c_person;
    --
    fetch c_person into l_person;
    --
  close c_person;
  --
  per_hrtca_merge.create_tca_person(p_rec => l_person);
  --
  hr_utility.set_location('Updating party id',10);
  --
  -- Now assign the resulting party id back to the record.
  --
  if p_party_id is null then
    update per_people_f
       set party_id = l_person.party_id
     where person_id = p_person_id;
  end if;
  --
  /* END OF PARTY ID WORK */

   open c2;
--
   fetch c2 into p_rowid;
--
   close c2;
--
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
      hr_security_internal.populate_new_person
      (p_business_group_id=>p_business_group_id
      ,p_person_id        =>p_person_id);
      --
      if p_create_defaults_for = 'EMP' then
         --
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
                           ,p_adjusted_svc_date => NULL);

-- PTU : Start of Changes
-- validate person type first

 per_per_bus.chk_person_type
          (p_person_type_id    => l_person_type_id
          ,p_business_group_id => p_business_group_id
          ,p_expected_sys_type => 'EMP');


 hr_per_type_usage_internal.maintain_person_type_usage
	(p_effective_date	=> p_effective_start_date
	,p_person_id 		=> p_person_id
	,p_person_type_id 	=> l_person_type_id
	);

-- PTU : End of Changes

      else
         --
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
                           ,p_creation_date => p_creation_date);

-- PTU : Start of Changes
-- validate person type first

 per_per_bus.chk_person_type
          (p_person_type_id    => l_person_type_id
          ,p_business_group_id => p_business_group_id
          ,p_expected_sys_type => 'APL');

 hr_per_type_usage_internal.maintain_person_type_usage
	(p_effective_date	=> p_effective_start_date
	,p_person_id 		=> p_person_id
	,p_person_type_id 	=> l_person_type_id
	);

-- PTU : End of Changes

      end if;
   end if;
   --
   -- Create a phone row if the work_telephone parm is not null.
   -- Use p_start_date (i.e., p_date_received passed from per_applicant_pkg)
   -- as the value for effective date and date from.
   --
   if p_work_telephone is not null then
          hr_phone_api.create_phone
             (p_date_from                 => p_start_date
             ,p_date_to                   => null
             ,p_phone_type                => 'W1'
             ,p_phone_number              => p_work_telephone
             ,p_parent_id                 => p_person_id
             ,p_parent_table              => 'PER_ALL_PEOPLE_F'
             ,p_validate                  => FALSE
             ,p_effective_date            => p_start_date
             ,p_object_version_number     => l_phone_ovn  --out
             ,p_phone_id                  => l_phone_id   --out
             );
   end if;
   --
--
end insert_row;
--
procedure delete_row(p_rowid VARCHAR2) is
begin
--
   delete from per_people_f
   where rowid=chartorowid(p_rowid);
--
end delete_row;
--
procedure lock_row(p_rowid VARCHAR2
   ,p_person_id NUMBER
   ,p_effective_start_date DATE
   ,p_effective_end_date DATE
   ,p_business_group_id NUMBER
   ,p_person_type_id NUMBER
   ,p_last_name VARCHAR2
   ,p_start_date DATE
   ,p_applicant_number VARCHAR2
   ,p_comment_id NUMBER
   ,p_current_applicant_flag VARCHAR2
   ,p_current_emp_or_apl_flag VARCHAR2
   ,p_current_employee_flag VARCHAR2
   ,p_date_employee_data_verified DATE
   ,p_date_of_birth DATE
   ,p_email_address VARCHAR2
   ,p_employee_number VARCHAR2
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
   ,p_i30 VARCHAR2) is
--
-- Define cursor.
--
   cursor per is select *
   from per_people_f
   where rowid = chartorowid(p_rowid)
   for update nowait;
--
-- Local variables.
--
per_rec per%rowtype;
--
begin
   open per;
   fetch per into per_rec;
   close per;
   --
   -- Fix to ensure column values are rtrim before
   -- comparison (as forms truncates all char fields for trailing spaces.)
   --
   per_rec.last_name := rtrim(per_rec.last_name);
   per_rec.applicant_number := rtrim(per_rec.applicant_number);
   per_rec.current_emp_or_apl_flag := rtrim(per_rec.current_emp_or_apl_flag);
   per_rec.expense_check_send_to_address :=
                       rtrim(per_rec.expense_check_send_to_address);
   per_rec.known_as := rtrim(per_rec.known_as);
   per_rec.per_information11 := rtrim(per_rec.per_information11);
   per_rec.per_information16 := rtrim(per_rec.per_information16);
   per_rec.registered_disabled_flag := rtrim(per_rec.registered_disabled_flag);
   per_rec.attribute_category := rtrim(per_rec.attribute_category);
   per_rec.attribute3 := rtrim(per_rec.attribute3);
   per_rec.attribute6 := rtrim(per_rec.attribute6);
   per_rec.attribute9 := rtrim(per_rec.attribute9);
   per_rec.attribute12 := rtrim(per_rec.attribute12);
   per_rec.attribute14 := rtrim(per_rec.attribute14);
   per_rec.attribute17 := rtrim(per_rec.attribute17);
   per_rec.attribute20 := rtrim(per_rec.attribute20);
   per_rec.middle_names := rtrim(per_rec.middle_names);
   per_rec.nationality := rtrim(per_rec.nationality);
   per_rec.national_identifier := rtrim(per_rec.national_identifier);
   per_rec.previous_last_name := rtrim(per_rec.previous_last_name);
   per_rec.sex := rtrim(per_rec.sex);
   per_rec.title := rtrim(per_rec.title);
   per_rec.suffix := rtrim(per_rec.suffix);
   per_rec.work_telephone := rtrim(per_rec.work_telephone);
   per_rec.attribute1 := rtrim(per_rec.attribute1);
   per_rec.attribute2 := rtrim(per_rec.attribute2);
   per_rec.attribute4 := rtrim(per_rec.attribute4);
   per_rec.attribute5 := rtrim(per_rec.attribute5);
   per_rec.attribute7 := rtrim(per_rec.attribute7);
   per_rec.attribute8 := rtrim(per_rec.attribute8);
   per_rec.attribute10 := rtrim(per_rec.attribute10);
   per_rec.attribute11 := rtrim(per_rec.attribute11);
   per_rec.attribute13 := rtrim(per_rec.attribute13);
   per_rec.attribute15 := rtrim(per_rec.attribute15);
   per_rec.attribute16 := rtrim(per_rec.attribute16);
   per_rec.attribute18 := rtrim(per_rec.attribute18);
   per_rec.attribute19 := rtrim(per_rec.attribute19);
   per_rec.attribute21 := rtrim(per_rec.attribute21);
   per_rec.attribute22 := rtrim(per_rec.attribute22);
   per_rec.attribute23 := rtrim(per_rec.attribute23);
   per_rec.attribute24 := rtrim(per_rec.attribute24);
   per_rec.attribute25 := rtrim(per_rec.attribute25);
   per_rec.attribute26 := rtrim(per_rec.attribute26);
   per_rec.attribute27 := rtrim(per_rec.attribute27);
   per_rec.attribute28 := rtrim(per_rec.attribute28);
   per_rec.attribute29 := rtrim(per_rec.attribute29);
   per_rec.attribute30 := rtrim(per_rec.attribute30);
   per_rec.per_information_category := rtrim(per_rec.per_information_category);
   per_rec.current_applicant_flag := rtrim(per_rec.current_applicant_flag);
   per_rec.current_employee_flag := rtrim(per_rec.current_employee_flag);
   per_rec.email_address := rtrim(per_rec.email_address);
   per_rec.employee_number := rtrim(per_rec.employee_number);
   per_rec.first_name := rtrim(per_rec.first_name);
   per_rec.full_name := rtrim(per_rec.full_name);
   per_rec.marital_status := rtrim(per_rec.marital_status);
   per_rec.per_information1 := rtrim(per_rec.per_information1);
   per_rec.per_information2 := rtrim(per_rec.per_information2);
   per_rec.per_information3 := rtrim(per_rec.per_information3);
   per_rec.per_information4 := rtrim(per_rec.per_information4);
   per_rec.per_information5 := rtrim(per_rec.per_information5);
   per_rec.per_information6 := rtrim(per_rec.per_information6);
   per_rec.per_information7 := rtrim(per_rec.per_information7);
   per_rec.per_information8 := rtrim(per_rec.per_information8);
   per_rec.per_information9 := rtrim(per_rec.per_information9);
   per_rec.per_information10 := rtrim(per_rec.per_information10);
   per_rec.per_information12 := rtrim(per_rec.per_information12);
   per_rec.per_information13 := rtrim(per_rec.per_information13);
   per_rec.per_information14 := rtrim(per_rec.per_information14);
   per_rec.per_information15 := rtrim(per_rec.per_information15);
   per_rec.per_information17 := rtrim(per_rec.per_information17);
   per_rec.per_information18 := rtrim(per_rec.per_information18);
   per_rec.per_information19 := rtrim(per_rec.per_information19);
   per_rec.per_information20 := rtrim(per_rec.per_information20);
   per_rec.per_information21 := rtrim(per_rec.per_information21);
   per_rec.per_information22 := rtrim(per_rec.per_information22);
   per_rec.per_information23 := rtrim(per_rec.per_information23);
   per_rec.per_information24 := rtrim(per_rec.per_information24);
   per_rec.per_information25 := rtrim(per_rec.per_information25);
   per_rec.per_information26 := rtrim(per_rec.per_information26);
   per_rec.per_information27 := rtrim(per_rec.per_information27);
   per_rec.per_information28 := rtrim(per_rec.per_information28);
   per_rec.per_information29 := rtrim(per_rec.per_information29);
   per_rec.per_information30 := rtrim(per_rec.per_information30);
   --
   if ( ((per_rec.person_id = p_person_id)
   or (per_rec.person_id is null
   and (p_person_id is null)))
   and ((per_rec.effective_start_date = p_effective_start_date)
   or (per_rec.effective_start_date is null
   and (p_effective_start_date is null)))
   and ((per_rec.effective_end_date = p_effective_end_date)
   or (per_rec.effective_end_date is null
   and (p_effective_end_date is null)))
   and ((per_rec.business_group_id = p_business_group_id)
   or (per_rec.business_group_id is null
   and (p_business_group_id is null)))
-- PTU : Start of Changes
--   and ((per_rec.person_type_id = p_person_type_id)
--   or (per_rec.person_type_id is null
--   and (p_person_type_id is null)))
-- PTU : End of Changes
   and ((per_rec.last_name = p_last_name)
   or (per_rec.last_name is null
   and (p_last_name is null)))
   and ((per_rec.start_date = p_start_date)
   or (per_rec.start_date is null
   and (p_start_date is null)))
   and ((per_rec.applicant_number = p_applicant_number)
   or (per_rec.applicant_number is null
   and (p_applicant_number is null)))
   and ((per_rec.comment_id = p_comment_id)
   or (per_rec.comment_id is null
   and (p_comment_id is null)))
   and ((per_rec.current_applicant_flag = p_current_applicant_flag)
   or (per_rec.current_applicant_flag is null
   and (p_current_applicant_flag is null)))
   and ((per_rec.current_emp_or_apl_flag = p_current_emp_or_apl_flag)
   or (per_rec.current_emp_or_apl_flag is null
   and (p_current_emp_or_apl_flag is null)))
   and ((per_rec.current_employee_flag = p_current_employee_flag)
   or (per_rec.current_employee_flag is null
   and (p_current_employee_flag is null)))
   and ((per_rec.date_employee_data_verified = p_date_employee_data_verified)
   or (per_rec.date_employee_data_verified is null
   and (p_date_employee_data_verified is null)))
   and ((per_rec.date_of_birth = p_date_of_birth)
   or (per_rec.date_of_birth is null
   and (p_date_of_birth is null)))
   and ((per_rec.email_address = p_email_address)
   or (per_rec.email_address is null
   and (p_email_address is null)))
   and ((per_rec.employee_number = p_employee_number)
   or (per_rec.employee_number is null
   and (p_employee_number is null)))
   and ((per_rec.expense_check_send_to_address = p_expense_check_send_to_addr)
   or (per_rec.expense_check_send_to_address is null
   and (p_expense_check_send_to_addr is null)))
   and ((per_rec.first_name = p_first_name)
   or (per_rec.first_name is null
   and (p_first_name is null)))
   and ((per_rec.full_name = p_full_name)
   or (per_rec.full_name is null
   and (p_full_name is null)))
   and ((per_rec.known_as = p_known_as)
   or (per_rec.known_as is null
   and (p_known_as is null)))
   and ((per_rec.marital_status = p_marital_status)
   or (per_rec.marital_status is null
   and (p_marital_status is null)))
   and ((per_rec.middle_names = p_middle_names)
   or (per_rec.middle_names is null
   and (p_middle_names is null)))
   and ((per_rec.nationality = p_nationality)
   or (per_rec.nationality is null
   and (p_nationality is null)))
   and ((per_rec.national_identifier = p_national_identifier)
   or (per_rec.national_identifier is null
   and (p_national_identifier is null)))
   and ((per_rec.previous_last_name = p_previous_last_name)
   or (per_rec.previous_last_name is null
   and (p_previous_last_name is null)))
   and ((per_rec.registered_disabled_flag = p_registered_disabled_flag)
   or (per_rec.registered_disabled_flag is null
   and (p_registered_disabled_flag is null)))
   and ((per_rec.sex = p_sex)
   or (per_rec.sex is null
   and (p_sex is null)))
   and ((per_rec.title = p_title)
   or (per_rec.title is null
   and (p_title is null)))
   and ((per_rec.suffix = p_suffix)
   or (per_rec.suffix is null
   and (p_suffix is null)))
   and ((per_rec.vendor_id = p_vendor_id)
   or (per_rec.vendor_id is null
   and (p_vendor_id is null)))
   and ((per_rec.work_telephone = p_work_telephone)
   or (per_rec.work_telephone is null
   and (p_work_telephone is null)))
   and ((per_rec.attribute_category = p_a_cat)
   or (per_rec.attribute_category is null
   and (p_a_cat is null)))
   and ((per_rec.attribute1 = p_a1)
   or (per_rec.attribute1 is null
   and (p_a1 is null)))
   and ((per_rec.attribute2 = p_a2)
   or (per_rec.attribute2 is null
   and (p_a2 is null)))
   and ((per_rec.attribute3 = p_a3)
   or (per_rec.attribute3 is null
   and (p_a3 is null)))
   and ((per_rec.attribute4 = p_a4)
   or (per_rec.attribute4 is null
   and (p_a4 is null)))
   and ((per_rec.attribute5 = p_a5)
   or (per_rec.attribute5 is null
   and (p_a5 is null)))
   and ((per_rec.attribute6 = p_a6)
   or (per_rec.attribute6 is null
   and (p_a6 is null)))
   and ((per_rec.attribute7 = p_a7)
   or (per_rec.attribute7 is null
   and (p_a7 is null)))
   and ((per_rec.attribute8 = p_a8)
   or (per_rec.attribute8 is null
   and (p_a8 is null)))
   and ((per_rec.attribute9 = p_a9)
   or (per_rec.attribute9 is null
   and (p_a9 is null)))
   and ((per_rec.attribute10 = p_a10)
   or (per_rec.attribute10 is null
   and (p_a10 is null)))
   and ((per_rec.attribute11 = p_a11)
   or (per_rec.attribute11 is null
   and (p_a11 is null)))
   and ((per_rec.attribute12 = p_a12)
   or (per_rec.attribute12 is null
   and (p_a12 is null)))
   and ((per_rec.attribute13 = p_a13)
   or (per_rec.attribute13 is null
   and (p_a13 is null)))
   and ((per_rec.attribute14 = p_a14)
   or (per_rec.attribute14 is null
   and (p_a14 is null)))
   and ((per_rec.attribute15 = p_a15)
   or (per_rec.attribute15 is null
   and (p_a15 is null)))
   and ((per_rec.attribute16 = p_a16)
   or (per_rec.attribute16 is null
   and (p_a16 is null)))
   and ((per_rec.attribute17 = p_a17)
   or (per_rec.attribute17 is null
   and (p_a17 is null)))
   and ((per_rec.attribute18 = p_a18)
   or (per_rec.attribute18 is null
   and (p_a18 is null)))
   and ((per_rec.attribute19 = p_a19)
   or (per_rec.attribute19 is null
   and (p_a19 is null)))
   and ((per_rec.attribute20 = p_a20)
   or (per_rec.attribute20 is null
   and (p_a20 is null))) )then
      --
      -- PL/SQL cannot handle an IF statement this length
      -- so split the comparisons into more manageable 'chunks'
      --
      if (  ((per_rec.attribute21 = p_a21)
      or (per_rec.attribute21 is null
      and (p_a21 is null)))
      and ((per_rec.attribute22 = p_a22)
      or (per_rec.attribute22 is null
      and (p_a22 is null)))
      and ((per_rec.attribute23 = p_a23)
      or (per_rec.attribute23 is null
      and (p_a23 is null)))
      and ((per_rec.attribute24 = p_a24)
      or (per_rec.attribute24 is null
      and (p_a24 is null)))
      and ((per_rec.attribute25 = p_a25)
      or (per_rec.attribute25 is null
      and (p_a25 is null)))
      and ((per_rec.attribute26 = p_a26)
      or (per_rec.attribute26 is null
      and (p_a26 is null)))
      and ((per_rec.attribute27 = p_a27)
      or (per_rec.attribute27 is null
      and (p_a27 is null)))
      and ((per_rec.attribute28 = p_a28)
      or (per_rec.attribute28 is null
      and (p_a28 is null)))
      and ((per_rec.attribute29 = p_a29)
      or (per_rec.attribute29 is null
      and (p_a29 is null)))
      and ((per_rec.attribute30 = p_a30)
      or (per_rec.attribute30 is null
      and (p_a30 is null)))
      and ((per_rec.per_information_category = p_i_cat)
      or (per_rec.per_information_category is null
      and (p_i_cat is null)))
      and ((per_rec.per_information1 = p_i1)
      or (per_rec.per_information1 is null
      and (p_i1 is null)))
      and ((per_rec.per_information2 = p_i2)
      or (per_rec.per_information2 is null
      and (p_i2 is null)))
      and ((per_rec.per_information3 = p_i3)
      or (per_rec.per_information3 is null
      and (p_i3 is null)))
      and ((per_rec.per_information4 = p_i4)
      or (per_rec.per_information4 is null
      and (p_i4 is null)))
      and ((per_rec.per_information5 = p_i5)
      or (per_rec.per_information5 is null
      and (p_i5 is null)))
      and ((per_rec.per_information6 = p_i6)
      or (per_rec.per_information6 is null
      and (p_i6 is null)))
      and ((per_rec.per_information7 = p_i7)
      or (per_rec.per_information7 is null
      and (p_i7 is null)))
      and ((per_rec.per_information8 = p_i8)
      or (per_rec.per_information8 is null
      and (p_i8 is null)))
      and ((per_rec.per_information9 = p_i9)
      or (per_rec.per_information9 is null
      and (p_i9 is null)))
      and ((per_rec.per_information10 = p_i10)
      or (per_rec.per_information10 is null
      and (p_i10 is null)))
      and ((per_rec.per_information11 = p_i11)
      or (per_rec.per_information11 is null
      and (p_i11 is null)))
      and ((per_rec.per_information12 = p_i12)
      or (per_rec.per_information12 is null
      and (p_i12 is null)))
      and ((per_rec.per_information13 = p_i13)
      or (per_rec.per_information13 is null
      and (p_i13 is null)))
      and ((per_rec.per_information14 = p_i14)
      or (per_rec.per_information14 is null
      and (p_i14 is null)))
      and ((per_rec.per_information15 = p_i15)
      or (per_rec.per_information15 is null
      and (p_i15 is null)))
      and ((per_rec.per_information16 = p_i16)
      or (per_rec.per_information16 is null
      and (p_i16 is null)))
      and ((per_rec.per_information17 = p_i17)
      or (per_rec.per_information17 is null
      and (p_i17 is null)))
      and ((per_rec.per_information18 = p_i18)
      or (per_rec.per_information18 is null
      and (p_i18 is null)))
      and ((per_rec.per_information19 = p_i19)
      or (per_rec.per_information19 is null
      and (p_i19 is null)))
      and ((per_rec.per_information20 = p_i20)
      or (per_rec.per_information20 is null
      and (p_i20 is null)))
      and ((per_rec.per_information21 = p_i21)
      or (per_rec.per_information21 is null
      and (p_i21 is null)))
      and ((per_rec.per_information22 = p_i22)
      or (per_rec.per_information22 is null
      and (p_i22 is null)))
      and ((per_rec.per_information23 = p_i23)
      or (per_rec.per_information23 is null
      and (p_i23 is null)))
      and ((per_rec.per_information24 = p_i24)
      or (per_rec.per_information24 is null
      and (p_i24 is null)))
      and ((per_rec.per_information25 = p_i25)
      or (per_rec.per_information25 is null
      and (p_i25 is null)))
      and ((per_rec.per_information26 = p_i26)
      or (per_rec.per_information26 is null
      and (p_i26 is null)))
      and ((per_rec.per_information27 = p_i27)
      or (per_rec.per_information27 is null
      and (p_i27 is null)))
      and ((per_rec.per_information28 = p_i28)
      or (per_rec.per_information28 is null
      and (p_i28 is null)))
      and ((per_rec.per_information29 = p_i29)
      or (per_rec.per_information29 is null
      and (p_i29 is null)))
      and ((per_rec.per_information30 = p_i30)
      or (per_rec.per_information30 is null
      and (p_i30 is null)))
      ) then
    return; -- return record is locked and ok.
      end if;
   end if;
-- Record changed by another user.
--
   fnd_message.set_name('FND','FORM_RECORD_CHANGED');
   app_exception.raise_exception ;
   exception when no_data_found then
      raise;
      when others then raise;
end lock_row;
--
procedure update_row(p_rowid VARCHAR2
   ,p_person_id NUMBER
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
   ,p_known_as VARCHAR2
   ,p_marital_status VARCHAR2
   ,p_middle_names VARCHAR2
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
   ,p_system_person_type VARCHAR2
   ,p_s_system_person_type VARCHAR2
   ,p_hire_date DATE
   ,p_s_hire_date DATE
   ,p_s_date_of_birth DATE
   ,p_status in out nocopy VARCHAR2
   ,p_new_primary_id in out nocopy NUMBER
   ,p_update_primary in out nocopy VARCHAR2
   ,p_legislation_code VARCHAR2
   ,p_vacancy_id IN OUT NOCOPY NUMBER
   ,p_session_date date
   ,p_end_of_time date) is
--
   l_period_of_service_id number; -- Period of Service id.
   l_employ_emp_apl varchar2(1);  -- Are we employing an EMP_APL?
   l_fire_warning varchar2(1);    -- If set Y return to form displaying warning.
   l_num_appls NUMBER;            -- Number of applicants.
   l_num_accepted_appls NUMBER;   -- Number of accepted spplicant assignments
   l_set_of_books_id NUMBER;      -- Required for GL.
   l_npw_number per_all_people_f.npw_number%TYPE;
   l_party_id   per_all_people_f.party_id%type;
--
   cursor csr_partyId_details is -- Enh 3299580
     select party_id
       from per_all_people_f
      where person_id = p_person_id
        and p_session_date between effective_start_date
                              and  effective_end_date;
begin
   --
   -- p_status has the Value of where the code should start on re-entry.
   -- on startup = 'BEGIN'( First time called from form)
   -- other values depend on what meesages have been returned to the client
   -- and the re-entry point on return from the client.
   --
   if p_status = 'BEGIN' then
      --
      -- Test to see if the hire_date_has changed
      -- Providing Person type has not and it is emp.
      -- Or that it has changed to EMP
      --
      if (p_hire_date <> p_s_hire_date)
         and (p_s_hire_date is not null)
         and (((p_system_person_type = p_s_system_person_type)
            and p_system_person_type = 'EMP')
          or ((p_system_person_type = 'EMP'
               and p_s_system_person_type in ('APL','APL_EX_APL','EX_EMP_APL'))
          or (p_system_person_type = 'EMP_APL'
               and p_s_system_person_type = 'APL')
          or (p_system_person_type = 'EMP'
             and p_s_system_person_type = 'EMP_APL'))) then
         -- get the period_of_service_id
         begin
            select pps.period_of_service_id
            into   l_period_of_service_id
            from   per_periods_of_service pps
            where  pps.person_id = p_person_id
            and    pps.date_start = p_s_hire_date;
            --
            exception
             when no_data_found then
               --
               -- If no data found and a previous hire date existed
               -- then raise an error;
               --
               if p_s_hire_date is not null then
                  hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
                  hr_utility.set_message_token('PROCEDURE','Update_row');
                  hr_utility.raise_error;
               end if;
         end;
         --
         -- check the integrity of the date change.
         -- Date may come in between a person type change.
         --
         hr_date_chk.check_hire_ref_int(p_person_id
                  ,p_business_group_id
                  ,l_period_of_service_id
                  ,p_s_hire_date
                  ,p_system_person_type
                  ,p_hire_date);
      end if;
      --
      -- check session date and effective_start_date for differences
      -- if any exists then ensure the person record is correct
      -- i.e duplicate datetrack functionality as it currently uses
      -- a global version of session date to update the rows (not good)
      --
      -- VT 08/13/96
      if p_session_date <> p_effective_start_date  then
        per_people9_pkg.update_old_person_row(p_person_id =>p_person_id
                              ,p_session_date => p_session_date
                              ,p_effective_start_date=>p_effective_start_date);
      end if;
      --
      -- get the Employee and applicant numbers if necessary
      -- only returns values depending on values of
      -- p_current_applicant_flag, p_current_applicant_flag
      -- and whether p_employee_number and p_applicant_number
      -- are null.
      --
      open csr_partyId_details;  -- Enh 3299580
      fetch csr_partyId_details into l_party_id;
      close csr_partyId_details;
      --
      hr_person.generate_number(p_current_employee_flag
           ,p_current_applicant_flag
           ,null  -- p_current_npw_flag
           ,p_national_identifier
           ,p_business_group_id
           ,p_person_id
           ,p_employee_number
           ,p_applicant_number
           ,l_npw_number
            -- Enh 3299580 --
           ,p_session_date
           ,l_party_id
           ,p_date_of_birth
           ,p_hire_date
       );
      --
      -- Test current numbers are not used by
      -- the system already.
      --
      hr_person.validate_unique_number(p_person_id    =>p_person_id
				   , p_business_group_id => p_business_group_id
				   , p_employee_number  => p_employee_number
				   , p_applicant_number => p_applicant_number
                                   , p_npw_number       => null --p_npw_number
				   , p_current_employee => p_current_employee_flag
				   , p_current_applicant => p_current_applicant_flag
                                   , p_current_npw       => null --p_current_npw_flag
                                   );
      p_status := 'VACANCY_CHECK'; -- Set status to next possible reentry point.
   end if; -- End the First in section
   --
   -- Start of Person type changes.
   --
   -- Has the Person type changed to become that of an applicant?
   --
   if (p_system_person_type ='APL'
         and p_s_system_person_type = 'OTHER')
      or (p_system_person_type = 'APL_EX_APL'
         and p_s_system_person_type = 'EX_APL')
      or (p_system_person_type = 'EMP_APL'
         and p_s_system_person_type = 'EMP')
      or (p_system_person_type = 'EX_EMP_APL'
         and p_s_system_person_type = 'EX_EMP') then
         --
         --  Ensure no future person_type_changes.
         --
         if hr_person.chk_future_person_type(p_s_system_person_type
                                            ,p_person_id
                                            ,p_business_group_id
                                            ,p_effective_start_date) then
           fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
           app_exception.raise_exception;
         end if;
         --
         -- Ensure there are no future applicant assignments
         --
         per_people3_pkg.check_future_apl(p_person_id => p_person_id
                          ,p_hire_date => p_session_date);
         --
         -- Insert the default applicant row and applicant
         -- assignment.
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
               ,p_creation_date => p_creation_date);
   --
   -- Has the Person type changed to become that of an employee
   -- when the previous type is not a current applicant?
   --
   elsif (p_system_person_type = 'EMP'
         and ( p_s_system_person_type = 'OTHER'
      or p_s_system_person_type = 'EX_EMP')) then
         --
         --  Ensure no future person_type_changes.
         --
         if hr_person.chk_future_person_type(p_s_system_person_type
                                            ,p_person_id
                                            ,p_business_group_id
                                            ,p_effective_start_date) then
           fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
           app_exception.raise_exception;
         end if;
      --
      -- Ensure there are no future applicant assignments
      --
      per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => p_effective_start_date);
      --
      -- Insert the default period_of service and assignment
      -- rows.
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
         ,p_adjusted_svc_date => NULL);
      --
      -- Has the Person become an Employee or Employee applicant from being an
      -- applicant or employee applicant?
      --
   elsif ((p_system_person_type = 'EMP'
         and p_s_system_person_type in ('APL','APL_EX_APL','EX_EMP_APL'))
      or (p_system_person_type = 'EMP_APL'
         and p_s_system_person_type = 'APL')
      or (p_system_person_type = 'EMP'
         and p_s_system_person_type = 'EMP_APL')) then
         --
         --  Ensure no future person_type_changes.
         --
         if hr_person.chk_future_person_type(p_s_system_person_type
                                            ,p_person_id
                                            ,p_business_group_id
                                            ,p_effective_start_date) then
          fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
           hr_utility.raise_error;
         end if;
      --
      -- Ensure there are no future applicant assignments
      --
      per_people3_pkg.check_future_apl(p_person_id => p_person_id
                        ,p_hire_date => p_effective_start_date);
      --
      -- Check that the change is valid.
      --
      if p_status = 'VACANCY_CHECK' then
         loop
            exit when p_status = 'GET_APPLS';
               --
               -- Check each vacancy,if it is oversubscribed
               -- l_fire_warning = 'Y', return to client
               -- displaying relevant message.
               -- on return l_vacancy_id starts the cursor at the
               -- relevant point.
               --
               per_people3_pkg.vacancy_chk(p_person_id => p_person_id
                           ,p_fire_warning => l_fire_warning
                           ,p_vacancy_id => p_vacancy_id);
               if l_fire_warning = 'Y' then
                  return;
               elsif l_fire_warning = 'N' then
                  p_status := 'GET_APPLS'; -- Set next possible re-entry point.
               end if;
         end loop;
      end if; -- End of VACANCY_CHECK
      --
      if p_status='GET_APPLS' then
         --
         -- Get all the accepted applicants
         --
         per_people3_pkg.get_accepted_appls(p_person_id => p_person_id
                           ,p_num_accepted_appls => l_num_accepted_appls
                           ,p_new_primary_id =>p_new_primary_id);
         --
         -- Get all current applicant assignments.
         --
         per_people3_pkg.get_all_current_appls(p_person_id => p_person_id
                              ,p_num_appls => l_num_appls);
         --
         if p_system_person_type = 'EMP_APL' then
            --
            -- If we have got this far then there must be > 0 Accepted
            -- applications,therefore check p_system_person_type if EMP_APL
            -- and number of accepted is equal to number of current assignments
            -- then there is an error. Otherwise go around end_accepted
            -- to multiple contracts.
            --
            if l_num_accepted_appls = l_num_appls then
               hr_utility.set_message('801','HR_6791_EMP_APL_NO_ASG');
               hr_utility.raise_error;
            else
               p_status := 'MULTIPLE_CONTRACTS';-- Set next re-entry point.
            end if;
         --
         -- Number of accepted does not equal number of current then
         -- end_accepted.
         --
         elsif l_num_accepted_appls <> l_num_appls then
            hr_utility.set_message('801','HR_EMP_UNACCEPTED_APPL');
            p_status := 'END_UNACCEPTED'; -- next code re-entry,
            return;
         --
         -- Otherwise ignore end_accepted.
         --
         else
            p_status := 'MULTIPLE_CONTRACTS'; -- next code re-entry.
         end if;
      end if; -- End of GET_APPLS
      --
      if p_status = 'END_UNACCEPTED' then
         --
         -- End the unaccepted assignments.
         --
         hrhirapl.end_unaccepted_app_assign(p_person_id
                                             ,p_business_group_id
                                             ,p_legislation_code
                                             ,p_session_date);
         p_status := 'MULTIPLE_CONTRACTS';
      end if; -- End of END_UNACCEPTED
      --
      -- Test to see if multiple contracts are a possibility.
      --
   hr_utility.set_location('update_row - b4 MULTIPLE_CONTRACTS',1);
      if p_status = 'MULTIPLE_CONTRACTS' then -- MULTIPLE_CONTRACTS
         if l_num_accepted_appls >1 then
            hr_utility.set_message('801','HR_EMP_MULTIPLE_CONTRACTS');
            return;
         else
            p_status := 'CHOOSE_VAC'; -- next code re-entry.
         end if;
      end if; -- End of MULTIPLE_CONTRACTS
      --
      -- Choose whether to change the Primary assignment
      -- and which vacancy  is to be the primary if so.
      --
   hr_utility.set_location('update_row - b4 CHOOSE_VAC',1);
      if p_status = 'CHOOSE_VAC' then
         return;
      end if; --End of CHOOSE_VAC
      --
      -- Can now hire the Person
		-- Note HIRE status can only be set from client form
		-- as interaction is generally required.
      --
   hr_utility.set_location('update_row - b4 HIRE',1);
      if p_status = 'HIRE' then
         --
         -- If new is Emp and old was Emp_apl
         -- then l_emp_emp_apl is set to Y
         --
         if p_system_person_type = 'EMP'
               and p_s_system_person_type = 'EMP_APL' then
            l_employ_emp_apl := 'Y';
         else
            l_employ_emp_apl := 'N';
         end if;
         --
         -- Run the employ_applicant stored procedure
         --
   hr_utility.set_location('update_row - b4 hrhirapl',1);
         hrhirapl.employ_applicant(p_person_id
                                  ,p_business_group_id
                                  ,p_legislation_code
                                  ,p_new_primary_id
                                  ,p_emp_ass_status_type_id
                                  ,p_last_updated_by
                                  ,p_last_update_login
                                  ,p_effective_start_date
                                  ,p_end_of_time
                                  ,p_last_update_date
                                  ,p_update_primary
                                  ,p_employee_number
                                  ,l_set_of_books_id
                                  ,l_employ_emp_apl
                                  ,NULL
                                  ,p_session_date); -- Bug 3564129
   hr_utility.set_location('update_row - after hrhirapl',2);
      end if; -- End of HIRE.
   end if; -- Of Person type change checks.
   --
   hr_utility.set_location('update_row - b4 update',1);
   update per_people_f ppf
   set ppf.person_id = p_person_id
   ,ppf.effective_start_date = p_effective_start_date
   ,ppf.effective_end_date = p_effective_end_date
   ,ppf.business_group_id = p_business_group_id
   ,ppf.person_type_id = p_person_type_id
   ,ppf.last_name = p_last_name
   ,ppf.start_date = p_start_date
   ,ppf.applicant_number = p_applicant_number
   ,ppf.comment_id = p_comment_id
   ,ppf.current_applicant_flag = p_current_applicant_flag
   ,ppf.current_emp_or_apl_flag = p_current_emp_or_apl_flag
   ,ppf.current_employee_flag = p_current_employee_flag
   ,ppf.date_employee_data_verified = p_date_employee_data_verified
   ,ppf.date_of_birth = p_date_of_birth
   ,ppf.email_address = p_email_address
   ,ppf.employee_number = p_employee_number
   ,ppf.expense_check_send_to_address = p_expense_check_send_to_addr
   ,ppf.first_name = p_first_name
   ,ppf.full_name = p_full_name
   ,ppf.known_as = p_known_as
   ,ppf.marital_status = p_marital_status
   ,ppf.middle_names = p_middle_names
   ,ppf.nationality = p_nationality
   ,ppf.national_identifier = p_national_identifier
   ,ppf.previous_last_name = p_previous_last_name
   ,ppf.registered_disabled_flag = p_registered_disabled_flag
   ,ppf.sex = p_sex
   ,ppf.title = p_title
   ,ppf.suffix = p_suffix
   ,ppf.vendor_id = p_vendor_id
   ,ppf.work_telephone = p_work_telephone
   ,ppf.request_id = p_request_id
   ,ppf.program_application_id = p_program_application_id
   ,ppf.program_id = p_program_id
   ,ppf.program_update_date = p_program_update_date
   ,ppf.attribute_category = p_a_cat
   ,ppf.attribute1 = p_a1
   ,ppf.attribute2 = p_a2
   ,ppf.attribute3 = p_a3
   ,ppf.attribute4 = p_a4
   ,ppf.attribute5 = p_a5
   ,ppf.attribute6 = p_a6
   ,ppf.attribute7 = p_a7
   ,ppf.attribute8 = p_a8
   ,ppf.attribute9 = p_a9
   ,ppf.attribute10 = p_a10
   ,ppf.attribute11 = p_a11
   ,ppf.attribute12 = p_a12
   ,ppf.attribute13 = p_a13
   ,ppf.attribute14 = p_a14
   ,ppf.attribute15 = p_a15
   ,ppf.attribute16 = p_a16
   ,ppf.attribute17 = p_a17
   ,ppf.attribute18 = p_a18
   ,ppf.attribute19 = p_a19
   ,ppf.attribute20 = p_a20
   ,ppf.attribute21 = p_a21
   ,ppf.attribute22 = p_a22
   ,ppf.attribute23 = p_a23
   ,ppf.attribute24 = p_a24
   ,ppf.attribute25 = p_a25
   ,ppf.attribute26 = p_a26
   ,ppf.attribute27 = p_a27
   ,ppf.attribute28 = p_a28
   ,ppf.attribute29 = p_a29
   ,ppf.attribute30 = p_a30
   ,ppf.last_update_date = p_last_update_date
   ,ppf.last_updated_by = p_last_updated_by
   ,ppf.last_update_login = p_last_update_login
   ,ppf.created_by = p_created_by
   ,ppf.creation_date = p_creation_date
   ,ppf.per_information_category = p_i_cat
   ,ppf.per_information1 = p_i1
   ,ppf.per_information2 = p_i2
   ,ppf.per_information3 = p_i3
   ,ppf.per_information4 = p_i4
   ,ppf.per_information5 = p_i5
   ,ppf.per_information6 = p_i6
   ,ppf.per_information7 = p_i7
   ,ppf.per_information8 = p_i8
   ,ppf.per_information9 = p_i9
   ,ppf.per_information10 = p_i10
   ,ppf.per_information11 = p_i11
   ,ppf.per_information12 = p_i12
   ,ppf.per_information13 = p_i13
   ,ppf.per_information14 = p_i14
   ,ppf.per_information15 = p_i15
   ,ppf.per_information16 = p_i16
   ,ppf.per_information17 = p_i17
   ,ppf.per_information18 = p_i18
   ,ppf.per_information19 = p_i19
   ,ppf.per_information20 = p_i20
   ,ppf.per_information21 = p_i21
   ,ppf.per_information22 = p_i22
   ,ppf.per_information23 = p_i23
   ,ppf.per_information24 = p_i24
   ,ppf.per_information25 = p_i25
   ,ppf.per_information26 = p_i26
   ,ppf.per_information27 = p_i27
   ,ppf.per_information28 = p_i28
   ,ppf.per_information29 = p_i29
   ,ppf.per_information30 = p_i30
   where ppf.rowid = p_rowid;
   --
   if sql%rowcount <1 then
      hr_utility.set_message(801,'HR_6001_ALL_MANDATORY_FIELD');
      hr_utility.set_message_token('MISSING_FIELD','rowid is'||p_rowid);
      hr_utility.raise_error;
   end if;
   --
   -- Tests required post-update
   --
   hr_utility.set_location('update_row - after update',1);
   --
   -- Has the Date of Birth changed?
   --
   if p_date_of_birth <> p_s_date_of_birth then
      --
      -- Run the assignment_link_usages and Element_entry
      -- code for Change of Personal qualifying conditions.
      --
      per_people3_pkg.run_alu_ee(p_alu_mode => 'CHANGE_PQC'
                            ,p_business_group_id=>p_business_group_id
                            ,p_person_id =>p_person_id
                            ,p_old_start =>p_s_hire_date
                            ,p_start_date => p_last_update_date
                            );
   end if;
   --
   hr_utility.set_location('update_row - after update',2);
   --
   -- test if hire_date has changed. and system person type has not.
   --
   if  ((p_current_employee_flag = 'Y')
         and (p_hire_date <> p_s_hire_date)
         and (p_system_person_type = p_s_system_person_type)) then
      --
      -- Update the period of service for the employee
      --
      --
      per_people3_pkg.update_period(p_person_id =>p_person_id
                              ,p_hire_date => p_s_hire_date
                              ,p_new_hire_date =>p_hire_date);
      --
      hr_utility.set_location('update_row - after update',3);
      --
      -- Update the hire records i.e
      -- assignment etc.
      --
      --
      hr_date_chk.update_hire_records(p_person_id
          ,p_applicant_number
          ,p_hire_date
          ,p_s_hire_date
          ,p_last_updated_by
          ,p_last_update_login);
      --
      hr_utility.set_location('update_row - after update',4);
      --
      -- Run the assignment_link_usages and Element_entry
      -- code for Assignment Criteria.
      --
      per_people3_pkg.run_alu_ee(p_alu_mode => 'ASG_CRITERIA'
                          ,p_business_group_id=>p_business_group_id
                          ,p_person_id =>p_person_id
                          ,p_old_start =>p_s_hire_date
                         ,p_start_date => p_hire_date);
   end if;
   --
   p_status := 'END'; -- Status required to end update loop on server
   --
end update_row;
--
END PER_PEOPLE_PKG;

/
