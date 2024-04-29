--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE13_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE13_PKG" AS
/* $Header: peper13t.pkb 120.1.12010000.4 2010/03/18 12:32:43 ktithy ship $ */
--
g_package  varchar2(24) := '  PER_PEOPLE13_PKG.';  -- Fix For Bug # 9474857,9485309. Changed the variable length from 14 to 24
g_debug    boolean; -- debug flag
--
procedure lock_row1(p_rowid VARCHAR2
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
   ,p_i30 VARCHAR2
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
   ,p_period_of_service_id NUMBER
   ,p_town_of_birth VARCHAR2
   ,p_region_of_birth VARCHAR2
   ,p_country_of_birth VARCHAR2
   ,p_global_person_id VARCHAR2
   ,p_npw_number VARCHAR2
   ,p_current_npw_flag VARCHAR2
  ) is
--
-- Define cursor.
--
   cursor per is select *
   from per_people_v
   where row_id = chartorowid(p_rowid);
--
   cursor per1 is select *
   from per_people_f
   where rowid = chartorowid(p_rowid)
   for update nowait;
--
-- Local variables.
--
per_rec per%rowtype;
per_rec1 per1%rowtype;
--
l_proc            varchar2(10) :=  'lock_row1';
--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

   open per;
   fetch per into per_rec;
   close per;
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 10);
  END IF;
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
   per_rec.work_schedule := rtrim(per_rec.work_schedule);
   per_rec.correspondence_language := rtrim(per_rec.correspondence_language);
   per_rec.student_status := rtrim(per_rec.student_status);
   per_rec.fte_capacity := rtrim(per_rec.fte_capacity);
   per_rec.on_military_service := rtrim(per_rec.on_military_service);
   per_rec.second_passport_exists := rtrim(per_rec.second_passport_exists);
   per_rec.background_check_status := rtrim(per_rec.background_check_status);
   per_rec.background_date_check := trunc(per_rec.background_date_check);
   per_rec.blood_type := rtrim(per_rec.blood_type);
   per_rec.last_medical_test_date := trunc(per_rec.last_medical_test_date);
   per_rec.last_medical_test_by := rtrim(per_rec.last_medical_test_by);
   per_rec.rehire_recommendation := rtrim(per_rec.rehire_recommendation);
   per_rec.rehire_reason := rtrim(per_rec.rehire_reason);
   per_rec.resume_exists := rtrim(per_rec.resume_exists);
   per_rec.resume_last_updated := trunc(per_rec.resume_last_updated);
   per_rec.office_number := rtrim(per_rec.office_number);
   per_rec.internal_location := rtrim(per_rec.internal_location);
   per_rec.mailstop := rtrim(per_rec.mailstop);
   per_rec.honors := rtrim(per_rec.honors);
   per_rec.pre_name_adjunct := rtrim(per_rec.pre_name_adjunct);
   per_rec.hold_applicant_date_until := trunc(per_rec.hold_applicant_date_until);
   per_rec.benefit_group_id := rtrim(per_rec.benefit_group_id);
   --Fix for bug 8769623 changed rtrim to trunc
   per_rec.receipt_of_death_cert_date := trunc(per_rec.receipt_of_death_cert_date);
  per_rec.coord_ben_med_pln_no := rtrim(per_rec.coord_ben_med_pln_no);
  per_rec.coord_ben_no_cvg_flag := rtrim(per_rec.coord_ben_no_cvg_flag);
  per_rec.uses_tobacco_flag := rtrim(per_rec.uses_tobacco_flag);
  --Fix for bug 8769623 changed rtrim to trunc
  per_rec.dpdnt_adoption_date := trunc(per_rec.dpdnt_adoption_date);
  per_rec.dpdnt_vlntry_svce_flag := rtrim(per_rec.dpdnt_vlntry_svce_flag);
  per_rec.date_of_death := trunc(per_rec.date_of_death);
  per_rec.original_date_of_hire := trunc(per_rec.original_date_of_hire);
   per_rec.town_of_birth := rtrim(per_rec.town_of_birth);
   per_rec.region_of_birth := rtrim(per_rec.region_of_birth);
   per_rec.country_of_birth := rtrim(per_rec.country_of_birth);
   per_rec.global_person_id := rtrim(per_rec.global_person_id);
  per_rec.npw_number := rtrim(per_rec.npw_number);
  per_rec.current_npw_flag := rtrim(per_rec.current_npw_flag);

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
   and ((per_rec.person_type_id = p_person_type_id)
   or (per_rec.person_type_id is null
   and (p_person_type_id is null)))
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
   and ((per_rec.town_of_birth = p_town_of_birth)
   or (per_rec.town_of_birth is null
   and (p_town_of_birth is null)))
   and ((per_rec.region_of_birth = p_region_of_birth)
   or (per_rec.region_of_birth is null
   and (p_region_of_birth is null)))
   and ((per_rec.country_of_birth = p_country_of_birth)
   or (per_rec.country_of_birth is null
   and (p_country_of_birth is null)))
   and ((per_rec.global_person_id = p_global_person_id)
   or (per_rec.global_person_id is null
   and (p_global_person_id is null)))
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
   -- Commented out two following lines as work_telephone
   -- is not present in the Person form. VT 09/15/97.
   --and ((per_rec.work_telephone = p_work_telephone)
   --or (per_rec.work_telephone is null))
   -- FIX for WWBUG 436781
   -- GP
   -- This is being done as the work telephone can be derived from either the
   -- PER_PEOPLE_F table or from the PER_PHONES table. If the PER_PHONES table
   -- is used then the lock fails as the database value is different from the
   -- form value and thus the lock assumes an update has occured so asks you
   -- to requery the record. This never occurs if the work_telephone is entered
   -- on the form as then the lock succeeds.
   -- The only way this lock could fail now is if the record is cleared and in
   -- the time it takes to clear someone else updates the record on the
   -- database then the on-lock trigger wil fail as the per_rec.work_telephone
   -- will have a value and the form will not. (Highly Unlikely).
   --and (p_work_telephone is null)))
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
      -- VT 09/11/96 added more !!!!!!!!!
          if (  ((per_rec.work_schedule = p_work_schedule)
          or (per_rec.work_schedule is null
          and (p_work_schedule is null)))
          and ((per_rec.correspondence_language = p_correspondence_language)
          or (per_rec.correspondence_language is null
          and (p_correspondence_language is null)))
          and ((per_rec.student_status = p_student_status)
          or (per_rec.student_status is null
          and (p_student_status is null)))
          and ((per_rec.fte_capacity = p_fte_capacity)
          or (per_rec.fte_capacity is null
          and (p_fte_capacity is null)))
          and ((per_rec.on_military_service = p_on_military_service)
          or (per_rec.on_military_service is null
          and (p_on_military_service is null)))
          and ((per_rec.second_passport_exists = p_second_passport_exists)
          or (per_rec.second_passport_exists is null
          and (p_second_passport_exists is null)))
          and ((per_rec.background_check_status = p_background_check_status )
          or (per_rec.background_check_status is null
          and (p_background_check_status is null)))
          and ((per_rec.background_date_check = p_background_date_check)
          or (per_rec.background_date_check is null
          and (p_background_date_check is null)))
          and ((per_rec.blood_type = p_blood_type)
          or (per_rec.blood_type is null
          and (p_blood_type is null)))
          and ((per_rec.last_medical_test_date = p_last_medical_test_date)
          or (per_rec.last_medical_test_date is null
          and (p_last_medical_test_date is null)))
          and ((per_rec.last_medical_test_by = p_last_medical_test_by)
          or (per_rec.last_medical_test_by is null
          and (p_last_medical_test_by is null)))
          and ((per_rec.rehire_recommendation = p_rehire_recommendation)
          or (per_rec.rehire_recommendation is null
          and (p_rehire_recommendation is null)))
          and ((per_rec.rehire_reason = p_rehire_reason)
          or (per_rec.rehire_reason is null
          and (p_rehire_reason is null)))
          and ((per_rec.resume_exists = p_resume_exists)
          or (per_rec.resume_exists is null
          and (p_resume_exists is null)))
          and ((per_rec.resume_last_updated = p_resume_last_updated)
          or (per_rec.resume_last_updated is null
          and (p_resume_last_updated is null)))
          and ((per_rec.office_number = p_office_number)
          or (per_rec.office_number is null
          and (p_office_number is null)))
          and ((per_rec.internal_location = p_internal_location)
          or (per_rec.internal_location is null
          and (p_internal_location is null)))
          and ((per_rec.mailstop = p_mailstop)
          or (per_rec.mailstop is null
          and (p_mailstop is null)))
          and ((per_rec.honors = p_honors)
          or (per_rec.honors is null
          and (p_honors is null)))
          and ((per_rec.pre_name_adjunct = p_pre_name_adjunct)
          or (per_rec.pre_name_adjunct is null
          and (p_pre_name_adjunct is null)))
          and ((per_rec.hold_applicant_date_until = p_hold_applicant_date_until)
          or (per_rec.hold_applicant_date_until is null
          and (p_hold_applicant_date_until is null)))
   and ((per_rec.benefit_group_id = p_benefit_group_id)
   or (per_rec.benefit_group_id is null
   and (p_benefit_group_id is null)))
   and ((per_rec.receipt_of_death_cert_date = p_receipt_of_death_cert_date)
   or (per_rec.receipt_of_death_cert_date is null
   and (p_receipt_of_death_cert_date is null)))
   and ((per_rec.coord_ben_med_pln_no = p_coord_ben_med_pln_no)
   or (per_rec.coord_ben_med_pln_no is null
   and (p_coord_ben_med_pln_no is null)))
   and ((per_rec.coord_ben_no_cvg_flag = p_coord_ben_no_cvg_flag )
   or ( per_rec.coord_ben_no_cvg_flag  is null
   and (p_coord_ben_no_cvg_flag is null)))
   and ((per_rec.uses_tobacco_flag = p_uses_tobacco_flag)
   or (per_rec.uses_tobacco_flag is null
   and (p_uses_tobacco_flag is null)))
   and (( per_rec.dpdnt_adoption_date = p_dpdnt_adoption_date)
   or (per_rec.dpdnt_adoption_date is null
   and (p_dpdnt_adoption_date is null)))
   and ((per_rec.dpdnt_vlntry_svce_flag = p_dpdnt_vlntry_svce_flag)
   or (per_rec.dpdnt_vlntry_svce_flag is null
   and (p_dpdnt_vlntry_svce_flag is null)))
   and ((per_rec.date_of_death = p_date_of_death)
   or (per_rec.date_of_death is null
   and (p_date_of_death is null)))
   and ((per_rec.original_date_of_hire = p_original_date_of_hire)
   or (per_rec.original_date_of_hire is null
   and (p_original_date_of_hire is null)))
   and ((per_rec.period_of_service_id = p_period_of_service_id)
   or (per_rec.period_of_service_id is null
   and (p_period_of_service_id is null)))
   and ((per_rec.npw_number = p_npw_number)
   or (per_rec.npw_number is null
   and (p_npw_number is null)))
   and ((per_rec.current_npw_flag = p_current_npw_flag)
   or (per_rec.current_npw_flag is null
   and (p_current_npw_flag is null)))

          ) then
          open per1;
          fetch per1 into per_rec1;
          close per1;
          return; -- return record is locked and ok.
          end if;
      end if;
   end if;
  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 20);
  END IF;

-- Record changed by another user.
--
   fnd_message.set_name('FND','FORM_RECORD_CHANGED');
   app_exception.raise_exception ;
   exception when no_data_found then
      raise;
      when others then raise;
end lock_row1;
--
END PER_PEOPLE13_PKG;

/
