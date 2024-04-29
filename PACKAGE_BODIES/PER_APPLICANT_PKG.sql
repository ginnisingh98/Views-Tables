--------------------------------------------------------
--  DDL for Package Body PER_APPLICANT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APPLICANT_PKG" as
/* $Header: peper02t.pkb 120.1.12010000.5 2009/07/21 15:14:13 sidsaxen ship $ */
--
g_package  varchar2(18) := 'PER_APPLICANT_PKG.';
g_debug    boolean; -- debug flag
--
--
-- PRIVATE PROCEDURES
--
-- Name
--   get_default_working_conditions
-- Purpose
--   Derive the working conditions for the new assignment
--   Given the position and organization and business group of the new
--   assignment get the working conditions in that order. The first set
--   that are not null are returned
-- Parameters
--   See below
--
-- Note
--   The in out variables are not out in order to be able to test their
--   values.
procedure get_working_conditions ( p_business_group_id in number,
				   p_organization_id   in number,
				   p_position_id       in number,
				   p_hours	       in out nocopy number,
				   p_freq	       in out nocopy varchar2,
				   p_start	       in out nocopy varchar2,
				   p_finish	       in out nocopy varchar2,
				   p_probation_period  in out nocopy number,
				   p_probation_unit    in out nocopy varchar2 ) is
--
-- Changed 01-Oct-99 SCNair ( per_all_positions to hr_all_positions ) date track requirement
--
cursor get_pos_conditions is
  select p.working_hours,
	 p.frequency,
	 p.time_normal_start,
	 p.time_normal_finish,
	 p.probation_period,
	 p.probation_period_unit_cd probation_period_units
  from   hr_all_positions p
  where  p.position_id = p_position_id ;
--
cursor get_org_conditions is
  select fnd_number.canonical_to_number(o.working_hours),
	 o.frequency,
	 o.default_start_time,
	 o.default_end_time
  from   per_all_organization_units o
  where  o.organization_id = p_organization_id ;
--
cursor get_bg_conditions is
  select fnd_number.canonical_to_number(b.working_hours),
	 b.frequency,
	 b.default_start_time,
	 b.default_end_time
  from   per_business_groups b
  where  b.business_group_id = p_business_group_id ;


  l_proc  varchar2(22) := 'get_working_conditions';
--
begin
--
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
    hr_utility.trace('p_business_group_id = ' || to_char(nvl(p_business_group_id,-999)));
	hr_utility.trace('p_organization_id = ' || to_char(nvl(p_organization_id,-999)));
	hr_utility.trace('p_position_id = ' || to_char(nvl(p_position_id,-999)));
	hr_utility.trace('p_hours = ' || to_char(nvl(p_hours,-999)));
	hr_utility.trace('p_freq  = ' || nvl(p_freq,'NULL'));
	hr_utility.trace('p_start  = ' || nvl(p_start,'NULL'));
	hr_utility.trace('p_finish = ' || nvl(p_finish,'NULL'));
	hr_utility.trace('p_probation_period = ' || to_char(nvl(p_probation_period,-999)));
	hr_utility.trace('p_probation_unit = ' || nvl(p_probation_unit,'NULL'));
  END IF;

  if ( p_position_id is not null ) then
    open get_pos_conditions ;
    fetch get_pos_conditions into p_hours,
				  p_freq,
				  p_start,
				  p_finish,
				  p_probation_period,
				  p_probation_unit ;
    close get_pos_conditions ;
    --
    -- If there were some details then return
    --
    if (     p_hours is not null
	 and p_freq  is not null
	 and p_start is not null
	 and p_freq  is not null ) then
       return ;
    end if;
  end if ;
  --
  --
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 10);
  END IF;

  if (     ( p_organization_id is not null )
       and ( p_organization_id <> p_business_group_id ) ) then
     --
     --
	open get_org_conditions ;
        fetch get_org_conditions into p_hours,
				      p_freq,
				      p_start,
				      p_finish ;
	close get_org_conditions ;
     --
     --
  else
     --
     --
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 20);
  END IF;


	open get_bg_conditions ;
        fetch get_bg_conditions into p_hours,
				     p_freq,
				     p_start,
				     p_finish ;
	close get_bg_conditions ;
     --
     --
  end if ;
--
end get_working_conditions ;
--
--
--
-- PUBLIC PROCEDURES
procedure insert_row ( p_rowid        in out nocopy VARCHAR2
,p_business_group_id NUMBER
,p_person_type_id                     in out nocopy NUMBER
,p_person_id 			      in out nocopy NUMBER
,p_effective_start_date DATE
,p_effective_end_date DATE
,p_last_name VARCHAR2
,p_first_name VARCHAR2
,p_title VARCHAR2
,p_full_name VARCHAR2
,p_sex VARCHAR2
,p_work_telephone VARCHAR2
,p_applicant_number 		      in out nocopy VARCHAR2
,p_assignment_status_type_id NUMBER
,p_request_id NUMBER
,p_program_application_id NUMBER
,p_program_id NUMBER
,p_program_update_date DATE
,p_attribute_category VARCHAR2
,p_attribute1 VARCHAR2
,p_attribute2 VARCHAR2
,p_attribute3 VARCHAR2
,p_attribute4 VARCHAR2
,p_attribute5 VARCHAR2
,p_attribute6 VARCHAR2
,p_attribute7 VARCHAR2
,p_attribute8 VARCHAR2
,p_attribute9 VARCHAR2
,p_attribute10 VARCHAR2
,p_attribute11 VARCHAR2
,p_attribute12 VARCHAR2
,p_attribute13 VARCHAR2
,p_attribute14 VARCHAR2
,p_attribute15 VARCHAR2
,p_attribute16 VARCHAR2
,p_attribute17 VARCHAR2
,p_attribute18 VARCHAR2
,p_attribute19 VARCHAR2
,p_attribute20 VARCHAR2
,p_attribute21 VARCHAR2
,p_attribute22 VARCHAR2
,p_attribute23 VARCHAR2
,p_attribute24 VARCHAR2
,p_attribute25 VARCHAR2
,p_attribute26 VARCHAR2
,p_attribute27 VARCHAR2
,p_attribute28 VARCHAR2
,p_attribute29 VARCHAR2
,p_attribute30 VARCHAR2
,p_per_information_category VARCHAR2
,p_per_information1 VARCHAR2
,p_per_information2 VARCHAR2
,p_per_information3 VARCHAR2
,p_per_information4 VARCHAR2
,p_per_information5 VARCHAR2
,p_per_information6 VARCHAR2
,p_per_information7 VARCHAR2
,p_per_information8 VARCHAR2
,p_per_information9 VARCHAR2
,p_per_information10 VARCHAR2
,p_per_information11 VARCHAR2
,p_per_information12 VARCHAR2
,p_per_information13 VARCHAR2
,p_per_information14 VARCHAR2
,p_per_information15 VARCHAR2
,p_per_information16 VARCHAR2
,p_per_information17 VARCHAR2
,p_per_information18 VARCHAR2
,p_per_information19 VARCHAR2
,p_per_information20 VARCHAR2
,p_per_information21 VARCHAR2
,p_per_information22 VARCHAR2
,p_per_information23 VARCHAR2
,p_per_information24 VARCHAR2
,p_per_information25 VARCHAR2
,p_per_information26 VARCHAR2
,p_per_information27 VARCHAR2
,p_per_information28 VARCHAR2
,p_per_information29 VARCHAR2
,p_per_information30 VARCHAR2
,p_style VARCHAR2
,p_address_line1 VARCHAR2
,p_address_line2 VARCHAR2
,p_address_line3 VARCHAR2
,p_address_type VARCHAR2
,p_country VARCHAR2
,p_postal_code VARCHAR2
,p_region_1 VARCHAR2
,p_region_2 VARCHAR2
,p_region_3 VARCHAR2
,p_telephone_number_1 VARCHAR2
,p_telephone_number_2 VARCHAR2
,p_telephone_number_3 VARCHAR2
,p_town_or_city VARCHAR2
,p_addr_attribute_category VARCHAR2
,p_addr_attribute1 VARCHAR2
,p_addr_attribute2 VARCHAR2
,p_addr_attribute3 VARCHAR2
,p_addr_attribute4 VARCHAR2
,p_addr_attribute5 VARCHAR2
,p_addr_attribute6 VARCHAR2
,p_addr_attribute7 VARCHAR2
,p_addr_attribute8 VARCHAR2
,p_addr_attribute9 VARCHAR2
,p_addr_attribute10 VARCHAR2
,p_addr_attribute11 VARCHAR2
,p_addr_attribute12 VARCHAR2
,p_addr_attribute13 VARCHAR2
,p_addr_attribute14 VARCHAR2
,p_addr_attribute15 VARCHAR2
,p_addr_attribute16 VARCHAR2
,p_addr_attribute17 VARCHAR2
,p_addr_attribute18 VARCHAR2
,p_addr_attribute19 VARCHAR2
,p_addr_attribute20 VARCHAR2
-- ***** Start new code for bug 2711964 **************
,p_add_information13           VARCHAR2
,p_add_information14           VARCHAR2
,p_add_information15           VARCHAR2
,p_add_information16           VARCHAR2
,p_add_information17           VARCHAR2
,p_add_information18           VARCHAR2
,p_add_information19           VARCHAR2
,p_add_information20           VARCHAR2
-- ***** End new code for bug 2711964 ***************
,p_date_received DATE
,p_current_employer VARCHAR2
,p_appl_attribute_category VARCHAR2
,p_appl_attribute1 VARCHAR2
,p_appl_attribute2 VARCHAR2
,p_appl_attribute3 VARCHAR2
,p_appl_attribute4 VARCHAR2
,p_appl_attribute5 VARCHAR2
,p_appl_attribute6 VARCHAR2
,p_appl_attribute7 VARCHAR2
,p_appl_attribute8 VARCHAR2
,p_appl_attribute9 VARCHAR2
,p_appl_attribute10 VARCHAR2
,p_appl_attribute11 VARCHAR2
,p_appl_attribute12 VARCHAR2
,p_appl_attribute13 VARCHAR2
,p_appl_attribute14 VARCHAR2
,p_appl_attribute15 VARCHAR2
,p_appl_attribute16 VARCHAR2
,p_appl_attribute17 VARCHAR2
,p_appl_attribute18 VARCHAR2
,p_appl_attribute19 VARCHAR2
,p_appl_attribute20 VARCHAR2
,p_recruitment_activity_id NUMBER
,p_source_organization_id NUMBER
,p_person_referred_by_id NUMBER
,p_vacancy_id NUMBER
,p_recruiter_id NUMBER
,p_organization_id NUMBER
,p_people_group_id NUMBER
,p_people_group_name VARCHAR2
,p_job_id NUMBER
,p_position_id NUMBER
,p_grade_id NUMBER
,p_location_id NUMBER
,p_location_code                     in out nocopy VARCHAR2
,p_source_type VARCHAR2
,p_ass_attribute_category VARCHAR2
,p_ass_attribute1 VARCHAR2
,p_ass_attribute2 VARCHAR2
,p_ass_attribute3 VARCHAR2
,p_ass_attribute4 VARCHAR2
,p_ass_attribute5 VARCHAR2
,p_ass_attribute6 VARCHAR2
,p_ass_attribute7 VARCHAR2
,p_ass_attribute8 VARCHAR2
,p_ass_attribute9 VARCHAR2
,p_ass_attribute10 VARCHAR2
,p_ass_attribute11 VARCHAR2
,p_ass_attribute12 VARCHAR2
,p_ass_attribute13 VARCHAR2
,p_ass_attribute14 VARCHAR2
,p_ass_attribute15 VARCHAR2
,p_ass_attribute16 VARCHAR2
,p_ass_attribute17 VARCHAR2
,p_ass_attribute18 VARCHAR2
,p_ass_attribute19 VARCHAR2
,p_ass_attribute20   VARCHAR2
,p_ass_attribute21 VARCHAR2
,p_ass_attribute22 VARCHAR2
,p_ass_attribute23 VARCHAR2
,p_ass_attribute24 VARCHAR2
,p_ass_attribute25 VARCHAR2
,p_ass_attribute26 VARCHAR2
,p_ass_attribute27 VARCHAR2
,p_ass_attribute28 VARCHAR2
,p_ass_attribute29 VARCHAR2
,p_ass_attribute30   VARCHAR2
,p_per_system_status VARCHAR2
,p_address_set       BOOLEAN
,p_method_of_apl_num_gen VARCHAR2
,p_party_id  NUMBER
,p_date_of_birth        DATE
,p_known_as             VARCHAR2
,p_marital_status       VARCHAR2
,p_middle_names         VARCHAR2
,p_nationality          VARCHAR2
,p_blood_type            VARCHAR2
,p_correspondence_language VARCHAR2
,p_honors                 VARCHAR2
,p_pre_name_adjunct       VARCHAR2
,p_rehire_authorizor      VARCHAR2
,p_rehire_recommendation  VARCHAR2
,p_resume_exists          VARCHAR2
,p_resume_last_updated    DATE
,p_second_passport_exists VARCHAR2
,p_student_status     VARCHAR2
,p_suffix             VARCHAR2
,p_date_of_death      DATE
,p_uses_tobacco_flag  VARCHAR2
,p_town_of_birth      VARCHAR2
,p_region_of_birth    VARCHAR2
,p_country_of_birth   VARCHAR2
,p_fast_path_employee VARCHAR2
,p_email_address   VARCHAR2
,p_fte_capacity    VARCHAR2
,p_national_identifier VARCHAR2 ) is
--
l_proc           varchar2(10) := 'insert_row';
--
l_assignment_status_id number;
l_object_version_number number;
--
l_dummy_varchar2 varchar2(255) := NULL ; -- Used to discard IN/OUT variables
l_dummy2_varchar2 varchar2(255) := NULL ; -- Used to discard IN/OUT variables
l_dummy_number   number        := NULL ; -- Used to discard IN/OUT variables
l_application_id number        := NULL ;
l_assignment_id  number        := NULL ;
l_apl_date_end   date          := NULL ; -- The end date for the application
l_asg_end_date   date          := NULL ;  -- The end date for the assignment
--
-- Working conditions for the Assignment
l_hours		   number       := NULL ;
l_freq		   varchar2(30) := NULL ;
l_start		   varchar2(5)  := NULL ;
l_finish           varchar2(5)  := NULL ;
l_probation_period number       := NULL ;
l_probation_unit   varchar2(30) := NULL ;
l_date_probation_end date	:= NULL ;     -- Added to fix the bug# 2314084

-- copied from peper01t.pkb ( bug 1368672 )
--
cursor c1 is select per_people_s.nextval
             from sys.dual;
--
--
-- Retrieve the person type id if the applicant is terminated
function get_ex_apl_person_type_id ( p_business_group_id in number )
	       return number is
l_return_value number := NULL ;
--
	-- Bug fix 3648715
	-- cursor c1  modified - '+0' removed to improve performance.

cursor c1 is
  select person_type_id
  from   per_person_types
  where  business_group_id  = p_business_group_id
  and    system_person_type = 'EX_APL'
  and    active_flag        = 'Y'
  and    default_flag       = 'Y' ;
begin
  --
  open c1 ;
  fetch c1 into l_return_value ;
  close c1 ;
  --
  return (l_return_value ) ;
--
end ;
--
--
begin
--
--Create the PERSON record
--
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;

    if ( p_method_of_apl_num_gen = 'A'  and p_applicant_number is null) then
      hr_person.generate_number( p_current_employee  => 'N',
 			         p_current_applicant => 'Y',
                                 p_current_npw       => 'N',
			         p_business_group_id => p_business_group_id,
			         p_person_id	   => null,
			         p_employee_number   => l_dummy2_varchar2,
			         p_applicant_number  => p_applicant_number,
                                 p_npw_number        => l_dummy_varchar2,
                                 p_national_identifier => p_national_identifier,
                                 p_effective_date    => p_effective_start_date,
                                 p_party_id          => p_party_id,
                                 p_date_of_birth     => p_date_of_birth
                                ,p_start_date        => p_effective_start_date);
    else
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 10);
  END IF;

      -- Check that the number is unique
      hr_person.validate_unique_number ( p_person_id         => NULL,
					 p_business_group_id => p_business_group_id,
					 p_employee_number   => NULL,
					 p_applicant_number  => p_applicant_number,
                                         p_npw_number        => NULL,
					 p_current_employee  => 'N',
					 p_current_applicant => 'Y',
                                         p_current_npw       => 'N');
    end if ;
    --
    -- If the location code is null and the location id is not null
    -- then populate location code. This happens when the standard location
    -- is accepted.

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 20);
  END IF;

    if (     ( p_location_id is not null )
	 and ( p_location_code is null ) ) then
	p_location_code := get_location_code( p_location_id ) ;
    end if ;

   -- To resolve bug 1346121
   -- Had to add the following if and move up the insert
   -- to before the proc call
   -- This is untidy but the clean way would have involved the
   -- rewrite of this package

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 30);
  END IF;

     if ( p_person_id is null ) then
        open c1;
        fetch c1 into p_person_id;
        close c1;
     end if;

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 40);
  END IF;

   --
     hr_security_internal.populate_new_person
     (p_business_group_id => p_business_group_id
     ,p_person_id         => p_person_id);
   --
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 50);
  END IF;

    per_people_pkg.insert_row(
		   p_rowid                        => p_rowid,
		   p_person_id                    => p_person_id ,
		   p_effective_start_date         => p_effective_start_date,
		   p_effective_end_date           => p_effective_end_date,
		   p_business_group_id            => p_business_group_id  ,
		   p_person_type_id               => p_person_type_id ,
		   p_last_name                    => p_last_name,
		   p_start_date                   => p_date_received,
		   p_applicant_number             => p_applicant_number ,
		   p_comment_id                   => null ,
		   p_current_applicant_flag       => 'Y' ,
		   p_current_emp_or_apl_flag      => 'Y' ,
		   p_current_employee_flag        => NULL,
		   p_date_employee_data_verified  => NULL,
		   p_date_of_birth                => p_date_of_birth,
		   p_email_address  		  => p_email_address,
		   p_employee_number              => l_dummy_varchar2 ,
		   p_expense_check_send_to_addr   => NULL ,
		   p_first_name  		  => p_first_name,
		   p_full_name                    => p_full_name        ,
		   p_known_as  			  => p_known_as,
		   p_marital_status               => p_marital_status,
		   p_middle_names  		  => p_middle_names,
		   p_nationality  		  => p_nationality,
		   p_national_identifier 	  => p_national_identifier,
		   p_previous_last_name           => NULL,
		   p_registered_disabled_flag     => NULL,
		   p_sex  			  => p_sex ,
		   p_title 			  => p_title ,
		   p_suffix			  => p_suffix,
		   p_vendor_id 			  => NULL,
		   p_work_telephone 		  => p_work_telephone  ,
		   p_request_id  		  => p_request_id ,
		   p_program_application_id       => p_program_application_id,
		   p_program_id                   => p_program_id ,
		   p_program_update_date          => p_program_update_date ,
		   p_a_cat 			  => p_attribute_category ,
		   p_a1  			  => p_attribute1,
		   p_a2 			  => p_attribute2,
		   p_a3 			  => p_attribute3,
		   p_a4  			  => p_attribute4,
		   p_a5                           => p_attribute5,
		   p_a6  		          => p_attribute6,
		   p_a7  			  => p_attribute7,
		   p_a8  			  => p_attribute8,
		   p_a9  			  => p_attribute9,
		   p_a10  			  => p_attribute10,
		   p_a11  			  => p_attribute11,
		   p_a12  			  => p_attribute12,
		   p_a13  			  => p_attribute13,
		   p_a14  			  => p_attribute14,
		   p_a15  			  => p_attribute15,
		   p_a16  			  => p_attribute16,
		   p_a17  			  => p_attribute17,
		   p_a18  			  => p_attribute18,
		   p_a19  			  => p_attribute19,
		   p_a20  			  => p_attribute20,
		   p_a21  			  => p_attribute21,
		   p_a22  			  => p_attribute22,
		   p_a23  			  => p_attribute23,
		   p_a24  			  => p_attribute24,
		   p_a25  			  => p_attribute25,
		   p_a26  			  => p_attribute26,
		   p_a27  			  => p_attribute27,
		   p_a28  			  => p_attribute28,
		   p_a29  			  => p_attribute29,
		   p_a30  			  => p_attribute30,
		   p_last_update_date  		  => null ,
		   p_last_updated_by  		  => null ,
		   p_last_update_login 	          => null,
		   p_created_by 		  => null,
		   p_creation_date 		  => null,
		   p_i_cat        		  => p_per_information_category ,
		   p_i1  			  => p_per_information1 ,
		   p_i2  			  => p_per_information2,
		   p_i3  			  => p_per_information3,
		   p_i4  			  => p_per_information4,
		   p_i5  			  => p_per_information5,
		   p_i6  			  => p_per_information6,
		   p_i7  			  => p_per_information7,
		   p_i8  			  => p_per_information8,
		   p_i9  			  => p_per_information9,
		   p_i10 			  => p_per_information10,
		   p_i11 			  => p_per_information11,
		   p_i12 			  => p_per_information12,
		   p_i13 			  => p_per_information13,
		   p_i14 			  => p_per_information14,
		   p_i15 			  => p_per_information15,
		   p_i16 			  => p_per_information16,
		   p_i17 			  => p_per_information17,
		   p_i18 			  => p_per_information18,
		   p_i19 			  => p_per_information19,
		   p_i20 			  => p_per_information20,
		   p_i21 			  => p_per_information21,
		   p_i22 			  => p_per_information22,
		   p_i23 			  => p_per_information23,
		   p_i24 			  => p_per_information24,
		   p_i25 			  => p_per_information25,
		   p_i26 			  => p_per_information26,
		   p_i27 			  => p_per_information27,
		   p_i28 			  => p_per_information28,
		   p_i29 			  => p_per_information29,
		   p_i30 			  => p_per_information30,
		   p_app_ass_status_type_id 	  => NULL,
		   p_emp_ass_status_type_id       => NULL,
		   p_create_defaults_for          => NULL,
                   p_party_id                     => p_party_id,
                   p_blood_type => p_blood_type
                  ,p_correspondence_language => p_correspondence_language
                  ,p_honors   => p_honors
                  ,p_pre_name_adjunct    =>p_pre_name_adjunct
                  ,p_rehire_authorizor   =>p_rehire_authorizor
                  ,p_rehire_recommendation=>p_rehire_recommendation
                  ,p_resume_exists         =>p_resume_exists
                  ,p_resume_last_updated   =>p_resume_last_updated
                  ,p_second_passport_exists=>p_second_passport_exists
                  ,p_student_status    =>p_student_status
                  ,p_date_of_death     =>p_date_of_death
                  ,p_uses_tobacco_flag =>p_uses_tobacco_flag
                  ,p_town_of_birth     =>p_town_of_birth
                  ,p_region_of_birth   =>p_region_of_birth
                  ,p_country_of_birth  =>p_country_of_birth
                  ,p_fast_path_employee=>p_fast_path_employee
                  ,p_fte_capacity      =>p_fte_capacity ) ;

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 60);
  END IF;

   -- If the Application has been terminated then create a person starting
   -- from the following day
  if p_per_system_status = 'TERM_APL' then
    p_person_type_id := get_ex_apl_person_type_id ( p_business_group_id ) ;
    per_people_pkg.insert_row(
		   p_rowid                        => p_rowid,
		   p_person_id                    => p_person_id ,
		   p_effective_start_date         => p_effective_start_date + 1,
		   p_effective_end_date           => hr_general.end_of_time,
		   p_business_group_id            => p_business_group_id  ,
		   p_person_type_id               => p_person_type_id ,
		   p_last_name                    => p_last_name,
		   p_start_date                   => p_date_received,
		   p_applicant_number             => p_applicant_number ,
		   p_comment_id                   => null ,
		   p_current_applicant_flag       => 'Y' ,
		   p_current_emp_or_apl_flag      => 'Y' ,
		   p_current_employee_flag        => NULL,
		   p_date_employee_data_verified  => NULL,
		   p_date_of_birth                => NULL,
		   p_email_address  		  => NULL,
		   p_employee_number              => l_dummy_varchar2 ,
		   p_expense_check_send_to_addr   => NULL ,
		   p_first_name  		  => p_first_name,
		   p_full_name                    => NULL        ,
		   p_known_as  			  => NULL,
		   p_marital_status               => NULL,
		   p_middle_names  		  => NULL,
		   p_nationality  		  => NULL,
		   p_national_identifier 	  => p_national_identifier,
		   p_previous_last_name           => NULL,
		   p_registered_disabled_flag     => NULL,
		   p_sex  			  => p_sex ,
		   p_title 			  => p_title ,
		   p_suffix			  => NULL,
		   p_vendor_id 			  => NULL,
		   p_work_telephone 		  => p_work_telephone  ,
		   p_request_id  		  => p_request_id ,
		   p_program_application_id       => p_program_application_id,
		   p_program_id                   => p_program_id ,
		   p_program_update_date          => p_program_update_date ,
		   p_a_cat 			  => p_attribute_category ,
		   p_a1  			  => p_attribute1,
		   p_a2 			  => p_attribute2,
		   p_a3 			  => p_attribute3,
		   p_a4  			  => p_attribute4,
		   p_a5                           => p_attribute5,
		   p_a6  		          => p_attribute6,
		   p_a7  			  => p_attribute7,
		   p_a8  			  => p_attribute8,
		   p_a9  			  => p_attribute9,
		   p_a10  			  => p_attribute10,
		   p_a11  			  => p_attribute11,
		   p_a12  			  => p_attribute12,
		   p_a13  			  => p_attribute13,
		   p_a14  			  => p_attribute14,
		   p_a15  			  => p_attribute15,
		   p_a16  			  => p_attribute16,
		   p_a17  			  => p_attribute17,
		   p_a18  			  => p_attribute18,
		   p_a19  			  => p_attribute19,
		   p_a20  			  => p_attribute20,
		   p_a21  			  => p_attribute21,
		   p_a22  			  => p_attribute22,
		   p_a23  			  => p_attribute23,
		   p_a24  			  => p_attribute24,
		   p_a25  			  => p_attribute25,
		   p_a26  			  => p_attribute26,
		   p_a27  			  => p_attribute27,
		   p_a28  			  => p_attribute28,
		   p_a29  			  => p_attribute29,
		   p_a30  			  => p_attribute30,
		   p_last_update_date  		  => null ,
		   p_last_updated_by  		  => null ,
		   p_last_update_login 	          => null,
		   p_created_by 		  => null,
		   p_creation_date 		  => null,
		   p_i_cat        		  => p_per_information_category ,
		   p_i1  			  => p_per_information1 ,
		   p_i2  			  => p_per_information2,
		   p_i3  			  => p_per_information3,
		   p_i4  			  => p_per_information4,
		   p_i5  			  => p_per_information5,
		   p_i6  			  => p_per_information6,
		   p_i7  			  => p_per_information7,
		   p_i8  			  => p_per_information8,
		   p_i9  			  => p_per_information9,
		   p_i10 			  => p_per_information10,
		   p_i11 			  => p_per_information11,
		   p_i12 			  => p_per_information12,
		   p_i13 			  => p_per_information13,
		   p_i14 			  => p_per_information14,
		   p_i15 			  => p_per_information15,
		   p_i16 			  => p_per_information16,
		   p_i17 			  => p_per_information17,
		   p_i18 			  => p_per_information18,
		   p_i19 			  => p_per_information19,
		   p_i20 			  => p_per_information20,
		   p_i21 			  => p_per_information21,
		   p_i22 			  => p_per_information22,
		   p_i23 			  => p_per_information23,
		   p_i24 			  => p_per_information24,
		   p_i25 			  => p_per_information25,
		   p_i26 			  => p_per_information26,
		   p_i27 			  => p_per_information27,
		   p_i28 			  => p_per_information28,
		   p_i29 			  => p_per_information29,
		   p_i30 			  => p_per_information30,
		   p_app_ass_status_type_id 	  => NULL,
		   p_emp_ass_status_type_id       => NULL,
		   p_create_defaults_for          => NULL,
                   p_party_id                     => p_party_id
                  ,p_blood_type => p_blood_type
                  ,p_correspondence_language => p_correspondence_language
                  ,p_honors   => p_honors
                  ,p_pre_name_adjunct    =>p_pre_name_adjunct
                  ,p_rehire_authorizor   =>p_rehire_authorizor
                  ,p_rehire_recommendation=>p_rehire_recommendation
                  ,p_resume_exists         =>p_resume_exists
                  ,p_resume_last_updated   =>p_resume_last_updated
                  ,p_second_passport_exists=>p_second_passport_exists
                  ,p_student_status    =>p_student_status
                  ,p_date_of_death     =>p_date_of_death
                  ,p_uses_tobacco_flag =>p_uses_tobacco_flag
                  ,p_town_of_birth     =>p_town_of_birth
                  ,p_region_of_birth   =>p_region_of_birth
                  ,p_country_of_birth  =>p_country_of_birth
                  ,p_fast_path_employee=>p_fast_path_employee
                  ,p_fte_capacity      =>p_fte_capacity
                  ) ;

   end if ;
--

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 70);
  END IF;

   -- PTU Added call to create APL PTU record
   -- Condition added to pass the person_type_id instead of the default value
   -- for the applicant quick entry form enhancement
  if p_person_type_id is null then
    hr_per_type_usage_internal.maintain_person_type_usage
        (  p_effective_date  => p_effective_start_date
          ,p_person_id       => p_person_id
          ,p_person_type_id  => hr_person_type_usage_info.get_default_person_type_id
                                        ( p_Business_Group_Id
                                        ,'APL')
        );
  else
   hr_per_type_usage_internal.maintain_person_type_usage
        (  p_effective_date  => p_effective_start_date
          ,p_person_id       => p_person_id
          ,p_person_type_id  => p_person_type_id);
  end if;
   --
  if p_per_system_status = 'TERM_APL' then
    hr_per_type_usage_internal.maintain_person_type_usage
        (  p_effective_date  => p_effective_start_date+1
          ,p_person_id       => p_person_id
          ,p_person_type_id  => p_person_type_id
        );
  end if;
   --
   -- End PTU Changes
--

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 80);
  END IF;


  if p_address_set then
-- **************************
-- Create the ADDRESS record
-- **************************
    l_dummy_number := NULL ;
    hr_utility.set_location('PER_APPLICANT_PKG.INSERT_ROW' , 2 ) ;
	per_addresses_pkg.insert_row(
	     p_row_id                  => l_dummy_varchar2
	    ,p_address_id              => l_dummy_number
	    ,p_business_group_id       => p_business_group_id
	    ,p_person_id               => p_person_id
	    ,p_date_from               => p_date_received
	    ,p_primary_flag            => 'Y'
	    ,p_style                   => p_style
	    ,p_address_line1           => p_address_line1
	    ,p_address_line2           => p_address_line2
	    ,p_address_line3           =>  p_address_line3
	    ,p_address_type            => p_address_type
	    ,p_comments                => NULL
	    ,p_country                 => p_country
	    ,p_date_to                 => NULL
	    ,p_postal_code             => p_postal_code
	    ,p_region_1                => p_region_1
	    ,p_region_2                => p_region_2
	    ,p_region_3                => p_region_3
	    ,p_telephone_number_1      => p_telephone_number_1
	    ,p_telephone_number_2      => p_telephone_number_2
	    ,p_telephone_number_3      => p_telephone_number_3
	    ,p_town_or_city            => p_town_or_city
	    ,p_request_id              => p_request_id
	    ,p_program_application_id  => p_program_application_id
	    ,p_program_id              => p_program_id
	    ,p_program_update_date     => p_program_update_date
	    ,p_addr_attribute_category => p_addr_attribute_category
	    ,p_addr_attribute1         => p_addr_attribute1
	    ,p_addr_attribute2         => p_addr_attribute2
	    ,p_addr_attribute3         => p_addr_attribute3
	    ,p_addr_attribute4         => p_addr_attribute4
	    ,p_addr_attribute5         => p_addr_attribute5
	    ,p_addr_attribute6         => p_addr_attribute6
	    ,p_addr_attribute7         => p_addr_attribute7
	    ,p_addr_attribute8         => p_addr_attribute8
	    ,p_addr_attribute9         => p_addr_attribute9
	    ,p_addr_attribute10        => p_addr_attribute10
	    ,p_addr_attribute11        => p_addr_attribute11
	    ,p_addr_attribute12        => p_addr_attribute12
	    ,p_addr_attribute13        => p_addr_attribute13
	    ,p_addr_attribute14        => p_addr_attribute14
	    ,p_addr_attribute15        => p_addr_attribute15
	    ,p_addr_attribute16        => p_addr_attribute16
	    ,p_addr_attribute17        => p_addr_attribute17
	    ,p_addr_attribute18        => p_addr_attribute18
	    ,p_addr_attribute19        => p_addr_attribute19
	    ,p_addr_attribute20        => p_addr_attribute20
        -- ***** Start commented code for bug 2711964 ********
        -- ,p_add_information17       => null
        -- ,p_add_information18       => null
        -- ,p_add_information19       => null
        -- ,p_add_information20       => null
        -- ***** End commented code for bug 2711964 **********
        -- ***** Start new code for bug 2711964 **************
        ,p_add_information13       => p_add_information13
        ,p_add_information14       => p_add_information14
        ,p_add_information15       => p_add_information15
        ,p_add_information16       => p_add_information16
        ,p_add_information17       => p_add_information17
        ,p_add_information18       => p_add_information18
        ,p_add_information19       => p_add_information19
        ,p_add_information20       => p_add_information20
        -- ***** End new code for bug 2711964 ***************
       ,p_end_of_time	       => hr_general.end_of_time
	);
  end if ;
--

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 90);
  END IF;

--
-- Create the APPLICATION record
    -- If terminating application then set end date
    if p_per_system_status = 'TERM_APL' then
        l_apl_date_end := p_date_received ;
    else
        l_apl_date_end := NULL ;
    end if ;
    --
    l_application_id := NULL ;
    l_dummy_varchar2 := NULL ;
    hr_utility.set_location('PER_APPLICANT_PKG.INSERT_ROW' , 3 ) ;
    per_applications_pkg.Insert_Row(p_Rowid    => l_dummy_varchar2,
                     p_Application_Id          => l_application_id,
                     p_Business_Group_Id       => p_business_group_id,
                     p_Person_Id               => p_person_id,
                     p_Date_Received           => p_date_received,
                     p_Comments                => NULL,
                     p_Current_Employer        => p_current_employer,
                     p_Date_End                => l_apl_date_end,
                     p_Projected_Hire_Date     => NULL,
                     p_Successful_Flag         => NULL,
                     p_Termination_Reason      => NULL,
                     p_Appl_Attribute_Category => p_appl_attribute_category,
                     p_Appl_Attribute1         => p_appl_attribute1,
                     p_Appl_Attribute2         => p_appl_attribute2,
                     p_Appl_Attribute3         => p_appl_attribute3,
                     p_Appl_Attribute4         => p_appl_attribute4,
                     p_Appl_Attribute5         => p_appl_attribute5,
                     p_Appl_Attribute6         => p_appl_attribute6,
                     p_Appl_Attribute7         => p_appl_attribute7,
                     p_Appl_Attribute8         => p_appl_attribute8,
                     p_Appl_Attribute9         => p_appl_attribute9,
                     p_Appl_Attribute10        => p_appl_attribute10,
                     p_Appl_Attribute11        => p_appl_attribute11,
                     p_Appl_Attribute12        => p_appl_attribute12,
                     p_Appl_Attribute13        => p_appl_attribute13,
                     p_Appl_Attribute14        => p_appl_attribute14,
                     p_Appl_Attribute15        => p_appl_attribute15,
                     p_Appl_Attribute16        => p_appl_attribute16,
                     p_Appl_Attribute17        => p_appl_attribute17,
                     p_Appl_Attribute18        => p_appl_attribute18,
                     p_Appl_Attribute19        => p_appl_attribute19,
                     p_Appl_Attribute20        => p_appl_attribute20,
                     p_Last_Update_Date        => null,
                     p_Last_Updated_By         => null,
                     p_Last_Update_Login       => null,
                     p_Created_By              => null,
                     p_Creation_Date           => null ) ;
--
--
-- Create the ASSIGNMENT record
--
--

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 100);
  END IF;

    hr_utility.set_location('PER_APPLICANT_PKG.INSERT_ROW' , 4 ) ;
    l_dummy_number   := NULL ;
    l_dummy_varchar2 := NULL ;
    --
    -- Set the end date of the assignment if the status is TERM_APL
    --
    if ( p_per_system_status = 'TERM_APL' ) then
	l_asg_end_date := p_date_received ;
    else
	l_asg_end_date := hr_general.end_of_time ;
    end if ;
    --
    --
    -- Get the working conditions.
    --
    get_working_conditions ( p_business_group_id => p_business_group_id,
			     p_organization_id   => p_organization_id,
			     p_position_id	 => p_position_id,
			     p_freq		 => l_freq,
			     p_hours		 => l_hours,
			     p_start		 => l_start,
			     p_finish		 => l_finish,
			     p_probation_period  => l_probation_period,
			     p_probation_unit    => l_probation_unit  ) ;
    --
    -- Start of fix for bug# 2314084
    --

  IF g_debug THEN
     hr_utility.set_location(g_package || l_proc, 110);
  END IF;

    if ((l_probation_period is not null) and (l_probation_unit is not null) ) then
        hr_assignment.gen_probation_end
           (p_assignment_id      => l_assignment_id
           ,p_probation_period   => l_probation_period
           ,p_probation_unit     => l_probation_unit
           ,p_start_date         => p_date_received
           ,p_date_probation_end => l_date_probation_end
        );
    end if;
    --
    -- End of fix for bug# 2314084
    --

  IF g_debug THEN
     hr_utility.set_location(g_package || l_proc, 120);
  END IF;

    per_assignments_f_pkg.insert_row(
	p_row_id			   => l_dummy_varchar2,
	p_assignment_id                    => l_assignment_id,
	p_effective_start_date             => p_date_received,
	p_effective_end_date               => l_asg_end_date,
	p_business_group_id                => p_business_group_id,
	p_recruiter_id                     => p_recruiter_id,
	p_grade_id                         => p_grade_id,
	p_position_id                      => p_position_id,
	p_job_id                           => p_job_id,
	p_assignment_status_type_id        => p_assignment_status_type_id,
	p_payroll_id                       => NULL,
	p_location_id                      => p_location_id,
	p_person_referred_by_id            => p_person_referred_by_id,
	p_supervisor_id                    => NULL,
	p_special_ceiling_step_id          => NULL,
	p_person_id                        => p_person_id,
	p_recruitment_activity_id          => p_recruitment_activity_id,
	p_source_organization_id           => p_source_organization_id,
	p_organization_id                  => nvl(p_organization_id,p_business_group_id
),

	p_people_group_id                  => p_people_group_id,
	p_soft_coding_keyflex_id           => NULL,
	p_vacancy_id                       => p_vacancy_id,
	p_assignment_sequence              => 1,
	p_assignment_type                  => 'A',
	p_primary_flag                     => 'N',
	p_application_id                   => l_application_id,
	p_assignment_number                => NULL,
	p_change_reason                    => NULL,
	p_comment_id                       => NULL,
	p_date_probation_end               => l_date_probation_end,
	p_default_code_comb_id             => NULL,
	p_frequency                        => l_freq,
	p_internal_address_line            => NULL,
	p_manager_flag                     => 'N',
	p_normal_hours                     => l_hours,
	p_period_of_service_id             => NULL,
	p_probation_period                 => l_probation_period,
	p_probation_unit                   => l_probation_unit,
	p_set_of_books_id                  => NULL,
	p_source_type                      => p_source_type,
	p_time_normal_finish               => l_finish,
	p_time_normal_start                => l_start,
	p_request_id                       => NULL,
	p_program_application_id           => NULL,
	p_program_id                       => NULL,
	p_program_update_date              => NULL,
	p_ass_attribute_category           => p_ass_attribute_category,
	p_ass_attribute1                   => p_ass_attribute1,
	p_ass_attribute2                   => p_ass_attribute2,
	p_ass_attribute3                   => p_ass_attribute3,
	p_ass_attribute4                   => p_ass_attribute4,
	p_ass_attribute5                   => p_ass_attribute5,
	p_ass_attribute6                   => p_ass_attribute6,
	p_ass_attribute7                   => p_ass_attribute7,
	p_ass_attribute8                   => p_ass_attribute8,
	p_ass_attribute9                   => p_ass_attribute9,
	p_ass_attribute10                  => p_ass_attribute10,
	p_ass_attribute11                  => p_ass_attribute11,
	p_ass_attribute12                  => p_ass_attribute12,
	p_ass_attribute13                  => p_ass_attribute13,
	p_ass_attribute14                  => p_ass_attribute14,
	p_ass_attribute15                  => p_ass_attribute15,
	p_ass_attribute16                  => p_ass_attribute16,
	p_ass_attribute17                  => p_ass_attribute17,
	p_ass_attribute18                  => p_ass_attribute18,
	p_ass_attribute19                  => p_ass_attribute19,
	p_ass_attribute20                  => p_ass_attribute20,
	p_ass_attribute21                  => p_ass_attribute21,
	p_ass_attribute22                  => p_ass_attribute22,
	p_ass_attribute23                  => p_ass_attribute23,
	p_ass_attribute24                  => p_ass_attribute24,
	p_ass_attribute25                  => p_ass_attribute25,
	p_ass_attribute26                  => p_ass_attribute26,
	p_ass_attribute27                  => p_ass_attribute27,
	p_ass_attribute28                  => p_ass_attribute28,
	p_ass_attribute29                  => p_ass_attribute29,
	p_ass_attribute30                  => p_ass_attribute30,
	p_sal_review_period                => NULL,
	p_sal_review_period_frequency      => NULL,
	p_perf_review_period               => NULL,
	p_perf_review_period_frequency     => NULL,
	p_pay_basis_id                     => NULL,
	p_employment_category		   => NULL,
        p_bargaining_unit_code             => NULL,
        p_labour_union_member_flag         => NULL,
	p_hourly_salaried_code             => NULL
) ;
--
/* Removing the call as this creates an additional record
    -- Insert a row into irc_assignment_statuses for irecruitment

 IRC_ASG_STATUS_API.create_irc_asg_status
            ( p_validate                   => FALSE
            , p_assignment_id              => l_assignment_id
            , p_assignment_status_type_id  => p_assignment_status_type_id
            , p_status_change_date         => p_date_received --2754362 l_asg_end_date
            , p_assignment_status_id       => l_assignment_status_id
            , p_object_version_number      => l_object_version_number
             );
*/

  IF g_debug THEN
     hr_utility.set_location(g_package || l_proc, 130);
  END IF;


    -- Create default budget values for the assignment
    create_default_budget_values ( p_business_group_id,
			           l_assignment_id,
				   p_effective_start_date => p_date_received,
				   p_effective_end_date   => l_asg_end_date) ;
--

  IF g_debug THEN
     hr_utility.set_location(g_package || l_proc, 140);
  END IF;

    update_group ( p_people_group_id,
		   p_people_group_name ) ;
--
-- Create letter request

  IF g_debug THEN
     hr_utility.set_location(g_package || l_proc, 150);
  END IF;


    check_for_letter_requests ( p_business_group_id    => p_business_group_id,
			        p_per_system_status    => p_per_system_status,
			        p_assignment_status_type_id => p_assignment_status_type_id,
				p_person_id		    => p_person_id,
				p_assignment_id		    => l_assignment_id,
				p_effective_start_date => p_effective_start_date,
				p_validation_start_date=> p_effective_start_date,
				p_vacancy_id 		=> p_vacancy_id
) ;
--
  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 160);
  END IF;

end insert_row ;
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
   ,p_vendor_id NUMBER
   ,p_work_telephone VARCHAR2
   ,p_attribute_category VARCHAR2
   ,p_attribute1 VARCHAR2
   ,p_attribute2 VARCHAR2
   ,p_attribute3 VARCHAR2
   ,p_attribute4 VARCHAR2
   ,p_attribute5 VARCHAR2
   ,p_attribute6 VARCHAR2
   ,p_attribute7 VARCHAR2
   ,p_attribute8 VARCHAR2
   ,p_attribute9 VARCHAR2
   ,p_attribute10 VARCHAR2
   ,p_attribute11 VARCHAR2
   ,p_attribute12 VARCHAR2
   ,p_attribute13 VARCHAR2
   ,p_attribute14 VARCHAR2
   ,p_attribute15 VARCHAR2
   ,p_attribute16 VARCHAR2
   ,p_attribute17 VARCHAR2
   ,p_attribute18 VARCHAR2
   ,p_attribute19 VARCHAR2
   ,p_attribute20 VARCHAR2
   ,p_attribute21 VARCHAR2
   ,p_attribute22 VARCHAR2
   ,p_attribute23 VARCHAR2
   ,p_attribute24 VARCHAR2
   ,p_attribute25 VARCHAR2
   ,p_attribute26 VARCHAR2
   ,p_attribute27 VARCHAR2
   ,p_attribute28 VARCHAR2
   ,p_attribute29 VARCHAR2
   ,p_attribute30 VARCHAR2
   ,p_per_information_category VARCHAR2
   ,p_per_information1 VARCHAR2
   ,p_per_information2 VARCHAR2
   ,p_per_information3 VARCHAR2
   ,p_per_information4 VARCHAR2
   ,p_per_information5 VARCHAR2
   ,p_per_information6 VARCHAR2
   ,p_per_information7 VARCHAR2
   ,p_per_information8 VARCHAR2
   ,p_per_information9 VARCHAR2
   ,p_per_information10 VARCHAR2
   ,p_per_information11 VARCHAR2
   ,p_per_information12 VARCHAR2
   ,p_per_information13 VARCHAR2
   ,p_per_information14 VARCHAR2
   ,p_per_information15 VARCHAR2
   ,p_per_information16 VARCHAR2
   ,p_per_information17 VARCHAR2
   ,p_per_information18 VARCHAR2
   ,p_per_information19 VARCHAR2
   ,p_per_information20 VARCHAR2
   ,p_per_information21 VARCHAR2
   ,p_per_information22 VARCHAR2
   ,p_per_information23 VARCHAR2
   ,p_per_information24 VARCHAR2
   ,p_per_information25 VARCHAR2
   ,p_per_information26 VARCHAR2
   ,p_per_information27 VARCHAR2
   ,p_per_information28 VARCHAR2
   ,p_per_information29 VARCHAR2
   ,p_per_information30 VARCHAR2) is

l_proc  varchar2(8)  := 'lock_row';

begin
--
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;

    -- Call people lock row
    per_people_pkg.lock_row(
		   p_rowid                        => p_rowid,
		   p_person_id                    => p_person_id ,
		   p_effective_start_date         => p_effective_start_date,
		   p_effective_end_date           => p_effective_end_date,
		   p_business_group_id            => p_business_group_id  ,
		   p_person_type_id               => p_person_type_id ,
		   p_last_name                    => p_last_name,
		   p_start_date                   => p_start_date,
		   p_applicant_number             => p_applicant_number ,
		   p_comment_id                   => p_comment_id,
		   p_current_applicant_flag       => p_current_applicant_flag,
		   p_current_emp_or_apl_flag      => p_current_emp_or_apl_flag,
		   p_current_employee_flag        => p_current_employee_flag,
		   p_date_employee_data_verified  => p_date_employee_data_verified,
		   p_date_of_birth                => p_date_of_birth,
		   p_email_address  		  => p_email_address,
		   p_employee_number              => p_employee_number,
		   p_expense_check_send_to_addr   => p_expense_check_send_to_addr,
		   p_first_name  		  => p_first_name,
		   p_full_name                    => p_full_name,
		   p_known_as  			  => p_known_as,
		   p_marital_status               => p_marital_status,
		   p_middle_names  		  => p_middle_names,
		   p_nationality  		  => p_nationality,
		   p_national_identifier 	  => p_national_identifier,
		   p_previous_last_name           => p_previous_last_name,
		   p_registered_disabled_flag     => p_registered_disabled_flag,
		   p_sex  			  => p_sex ,
		   p_title 			  => p_title ,
		   p_suffix			  => NULL,
		   p_vendor_id 			  => p_vendor_id,
		   p_work_telephone 		  => p_work_telephone  ,
		   p_a_cat 	  => p_attribute_category ,
		   p_a1  		  => p_attribute1,
		   p_a2 		  => p_attribute2,
		   p_a3 		  => p_attribute3,
		   p_a4  	          => p_attribute4,
		   p_a5                   => p_attribute5,
		   p_a6  		  => p_attribute6,
		   p_a7  	          => p_attribute7,
		   p_a8  	          => p_attribute8,
		   p_a9  		  => p_attribute9,
		   p_a10  		  => p_attribute10,
		   p_a11  		  => p_attribute11,
		   p_a12  		  => p_attribute12,
		   p_a13  		  => p_attribute13,
		   p_a14  		  => p_attribute14,
		   p_a15  		  => p_attribute15,
		   p_a16  		  => p_attribute16,
		   p_a17  		  => p_attribute17,
		   p_a18  	          => p_attribute18,
		   p_a19  		  => p_attribute19,
		   p_a20  		  => p_attribute20,
		   p_a21  		  => p_attribute21,
		   p_a22  		  => p_attribute22,
		   p_a23  		  => p_attribute23,
		   p_a24  		  => p_attribute24,
		   p_a25  		  => p_attribute25,
		   p_a26  		  => p_attribute26,
		   p_a27  		  => p_attribute27,
		   p_a28  	          => p_attribute28,
		   p_a29  		  => p_attribute29,
		   p_a30  		  => p_attribute30,
		   p_i_cat         => p_per_information_category ,
		   p_i1  		  => p_per_information1 ,
		   p_i2  		  => p_per_information2,
		   p_i3  		  => p_per_information3,
		   p_i4  		  => p_per_information4,
		   p_i5  		  => p_per_information5,
		   p_i6  		  => p_per_information6,
		   p_i7  		  => p_per_information7,
		   p_i8  		  => p_per_information8,
		   p_i9  		  => p_per_information9,
		   p_i10 		  => p_per_information10,
		   p_i11 		  => p_per_information11,
		   p_i12 		  => p_per_information12,
		   p_i13 		  => p_per_information13,
		   p_i14 		  => p_per_information14,
		   p_i15 		  => p_per_information15,
		   p_i16 		  => p_per_information16,
		   p_i17 		  => p_per_information17,
		   p_i18 		  => p_per_information18,
		   p_i19 		  => p_per_information19,
		   p_i20 		  => p_per_information20,
		   p_i21 		  => p_per_information21,
		   p_i22 		  => p_per_information22,
		   p_i23 		  => p_per_information23,
		   p_i24 		  => p_per_information24,
		   p_i25 		  => p_per_information25,
		   p_i26 		  => p_per_information26,
		   p_i27 		  => p_per_information27,
		   p_i28 		  => p_per_information28,
		   p_i29 		  => p_per_information29,
		   p_i30 		  => p_per_information30
		  ) ;
--
  IF g_debug THEN
    hr_utility.set_location('leaving: '|| g_package || l_proc, 10);
  END IF;

end lock_row ;
--
-- Fix for 3908271 starts here. Comment out the delete
-- proc as a new API procedure hr_person_api.delete_person
-- is avilable for deleting a person.
--
/*
procedure delete_row ( p_person_id    in number,
		       p_session_date in date  ) is
begin
--
   check_delete_allowed ( p_person_id    => p_person_id,
			  p_session_date => p_session_date ) ;
   --
   hr_person.applicant_default_deletes( p_person_id => p_person_id,
					p_form_call => TRUE);
--
end delete_row ;
*/
--
-- Fix for 3908271 ends here.
--
-- Retrieve the location code for the given location id
function get_location_code ( p_location_id in number ) return varchar2 is
-- length increased to 60 from 20 for UTF8 compatibility
l_return_value varchar2(60) := NULL ;
--
cursor c1 is
  select location_code
  from   hr_locations
  where  location_id = p_location_id ;
--
begin
  --
  open c1 ;
  fetch c1 into l_return_value ;
  close c1 ;
  --
  return( l_return_value ) ;
end get_location_code ;
--
-- overload provided for get_db_default_values
--
procedure get_db_default_values (p_business_group_id      in number ,
				             p_legislation_code       in varchar2,
				             p_bg_name		        in out nocopy varchar2,
				             p_bg_location_id	        in out nocopy number,
				             p_bg_working_hours	   in out nocopy number,
				             p_bg_frequency	        in out nocopy varchar2,
				             p_bg_default_start_time  in out nocopy varchar2,
				             p_bg_default_end_time    in out nocopy varchar2,
				             p_system_person_type     in out nocopy varchar2,
				             p_person_type_id	        in out nocopy number,
				             p_ass_status_type_id     in out nocopy number,
				             p_ass_status_type_desc   in out nocopy varchar2,
				             p_ass_per_system_status  in out nocopy varchar2,
				             p_country_meaning        in out nocopy varchar2,
				             p_default_yes_desc       in out nocopy varchar2,
				             p_default_no_desc        in out nocopy varchar2,
				             p_people_group_structure in out nocopy varchar2,
				             p_method_of_apl_gen      in out nocopy varchar2) is
--
l_style fnd_descr_flex_contexts_vl.descriptive_flex_context_code%TYPE;
--
begin

   get_db_default_values (p_business_group_id       => p_business_group_id
	                     ,p_legislation_code       => p_legislation_code
			           ,p_bg_name                => p_bg_name
			           ,p_bg_location_id         => p_bg_location_id
	                     ,p_bg_working_hours	  => p_bg_working_hours
			           ,p_bg_frequency	       => p_bg_frequency
			           ,p_bg_default_start_time  => p_bg_default_start_time
			           ,p_bg_default_end_time    => p_bg_default_end_time
			           ,p_system_person_type     => p_system_person_type
			           ,p_person_type_id	       => p_person_type_id
		                ,p_ass_status_type_id     => p_ass_status_type_id
			           ,p_ass_status_type_desc   => p_ass_status_type_desc
			           ,p_ass_per_system_status  => p_ass_per_system_status
			           ,p_country_meaning        => p_country_meaning
		                ,p_default_yes_desc       => p_default_yes_desc
			           ,p_default_no_desc        => p_default_no_desc
			           ,p_people_group_structure => p_people_group_structure
			           ,p_method_of_apl_gen      => p_method_of_apl_gen
			           ,p_style                  => l_style);
end;
--
procedure get_db_default_values (p_business_group_id      in number ,
				   p_legislation_code       in varchar2,
				   p_bg_name		        in out nocopy varchar2,
				   p_bg_location_id	        in out nocopy number,
				   p_bg_working_hours	   in out nocopy number,
				   p_bg_frequency	        in out nocopy varchar2,
				   p_bg_default_start_time  in out nocopy varchar2,
				   p_bg_default_end_time    in out nocopy varchar2,
				   p_system_person_type	   in out nocopy varchar2,
				   p_person_type_id	        in out nocopy number,
				   p_ass_status_type_id     in out nocopy number,
				   p_ass_status_type_desc   in out nocopy varchar2,
				   p_ass_per_system_status  in out nocopy varchar2,
				   p_country_meaning        in out nocopy varchar2,
				   p_default_yes_desc       in out nocopy varchar2,
				   p_default_no_desc        in out nocopy varchar2,
				   p_people_group_structure in out nocopy varchar2,
				   p_method_of_apl_gen      in out nocopy varchar2,
				   p_style                  in out nocopy varchar2) is
--
l_proc               varchar2(22)   := 'get_db_default_values';
l_geocodes_installed varchar2(1);
l_default varchar2(80);
l_default_code varchar2(30);
--
	-- Bug fix 3648715
	-- cursor c1  modified - '+0' removed to improve performance.

cursor c1 is
select person_type_id,
       system_person_type
from   per_person_types
where  business_group_id  = p_business_group_id
and    system_person_type = 'APL'
and    active_flag        = 'Y'
and    default_flag       = 'Y' ;
--
cursor c2 is
select a.assignment_status_type_id
,      nvl(btl.user_status,atl.user_status)
,      a.per_system_status
from   per_assignment_status_types_tl atl
,      per_assignment_status_types a
,      per_ass_status_type_amends_tl btl
,      per_ass_status_type_amends b
where  b.assignment_status_type_id(+)  = a.assignment_status_type_id
and    b.business_group_id(+) + 0   = p_business_group_id
and    nvl(a.business_group_id,p_business_group_id) = p_business_group_id
and    nvl(a.legislation_code,p_legislation_code)   = p_legislation_code
and    nvl(b.active_flag,a.active_flag)             = 'Y'
and    nvl(b.default_flag,a.default_flag)    	    = 'Y'
and    nvl(b.per_system_status,a.per_system_status) = 'ACTIVE_APL'
and    b.ass_status_type_amend_id      = btl.ass_status_type_amend_id (+)
and    decode(btl.ass_status_type_amend_id, null, '1', userenv('LANG')) =
              decode(btl.ass_status_type_amend_id, null, '1', btl.LANGUAGE)
and    a.assignment_status_type_id = atl.assignment_status_type_id
and    atl.LANGUAGE = userenv('LANG');
--
	-- Bug fix 3648715
	-- cursor c3  modified - "application_id = 800" added to improve performance.

cursor c3 is
  select descriptive_flex_context_name, descriptive_flex_context_code
  from fnd_descr_flex_contexts_vl
  where (descriptive_flex_context_code = p_legislation_code
    or (p_legislation_code = descriptive_flex_context_code
    and p_legislation_code in ('CA','US')
    and hr_general.chk_geocodes_installed = 'Y'))
    and descriptive_flexfield_name = 'Address Structure'
    and application_id = 800 	-- Bug fix 3648715
    and enabled_flag = 'Y';
--
	-- Bug fix 3648715
	-- cursor c6  modified - "application_id = 800" added to improve performance.

cursor c6 is
select descriptive_flex_context_name,descriptive_flex_context_code
from fnd_descr_flex_contexts_vl
where substr(descriptive_flex_context_code,1,2)= p_legislation_code
and descriptive_flexfield_name = 'Address Structure'
and application_id = 800	-- Bug Fix 3648715
and enabled_flag = 'Y';
--
cursor c4 is
  select  l1.meaning,
          l2.meaning
  from    hr_lookups l1,
	  hr_lookups l2
  where   l1.lookup_type = 'YES_NO'
  and     l2.lookup_type = 'YES_NO'
  and     l1.lookup_code = 'Y'
  and     l2.lookup_code = 'N' ;
--
cursor c5 is
  select pbg.name,
	 pbg.location_id,
	fnd_number.canonical_to_number(pbg.working_hours),
	 pbg.frequency,
	 pbg.default_start_time,
	 pbg.default_end_time,
	 pbg.people_group_structure,
	 pbg.method_of_generation_apl_num
  from   per_business_groups pbg
  where  business_group_id = p_business_group_id ;
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;

--
   hr_utility.set_location('PER_APPLICANT_PKG.GET_DB_DEFAULT_VALUES' , 1 ) ;
   -- Retrieve the person type for a system person type of APL
   open c1 ;
   fetch c1 into p_person_type_id,
		 p_system_person_type ;
   close c1 ;
   -- Retrieve the Assignment Status Type defaults

  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 10);
  END IF;

   open c2 ;
   fetch c2 into p_ass_status_type_id,
		 p_ass_status_type_desc,
		 p_ass_per_system_status ;
   close c2 ;
   --
   -- Retrieve the default country to use for addresses

  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 20);
  END IF;

   open c3;
   fetch c3 into l_default,l_default_code;
   if c3%notfound then
	open c6;
	fetch  c6 into l_default,l_default_code;
	close c6;
   end if;
   close c3;
  --
  p_country_meaning := l_default;
  p_style           := l_default_code;
   --
   --
   -- Retrieve the default yes and no descriptions

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 30);
  END IF;

   open c4 ;
   fetch c4 into p_default_yes_desc,p_default_no_desc ;
   close c4 ;
   --
   -- Retrieve business group defaults

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 40);
  END IF;

   open c5 ;
   fetch c5 into p_bg_name,
		 p_bg_location_id,
		 p_bg_working_hours,
		 p_bg_frequency,
		 p_bg_default_start_time,
		 p_bg_default_end_time,
		 p_people_group_structure ,
		 p_method_of_apl_gen ;
   close c5 ;
   --

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 50);
  END IF;

end get_db_default_values ;
--
--
--
function vacancy_in_activity ( p_recruitment_activity_id in number,
			       p_vacancy_id              in number )
			       return boolean  is
l_return_value boolean := FALSE ;
l_dummy        number ;
l_proc         varchar2(19)   := 'vacancy_in_activity';

cursor c1 is
  select 1
  from   per_recruitment_activity_for
  where  recruitment_activity_id = p_recruitment_activity_id
  and    vacancy_id		 = p_vacancy_id ;
begin
--

  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;

  open c1 ;
  fetch c1 into l_dummy ;
  l_return_value := c1%found ;
  close c1 ;

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
  END IF;

  return ( l_return_value ) ;
--
end vacancy_in_activity ;
--
--
--
function uniq_vac_for_rec_act ( p_recruitment_activity_id in number,
				p_date_received           in date )
			      return number  is
cursor c1 is
 select min(r.vacancy_id)
 from   per_recruitment_activity_for r,
	per_all_vacancies x
 where  r.recruitment_activity_id = p_recruitment_activity_id
 and    r.vacancy_id              = x.vacancy_id
 and    p_date_received between x.date_from
	and nvl(x.date_to,p_date_received)
 group by r.recruitment_activity_id
 having count(r.vacancy_id) = 1 ;
--
l_vacancy_id number := null ;
l_proc       varchar2(20)   := 'uniq_vac_for_rec_act';
--
begin

  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;

   open c1 ;
   fetch c1 into l_vacancy_id ;
   if c1%notfound then
     l_vacancy_id := null ;
   end if ;
   close c1 ;
   --

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
  END IF;

   return ( l_vacancy_id ) ;
--
end uniq_vac_for_rec_act ;
--
--
--
procedure get_vacancy_details ( p_vacancy_id      in number,
				p_vacancy_name    in out nocopy varchar2,
				p_recruiter_id    in out nocopy number,
				p_recruiter_name  in out nocopy varchar2,
				p_org_id 	  in out nocopy number,
				p_org_name	  in out nocopy varchar2,
				p_people_group_id in out nocopy number,
				p_job_id	  in out nocopy number,
				p_job_name	  in out nocopy varchar2,
				p_pos_id	  in out nocopy number,
				p_pos_name	  in out nocopy varchar2,
				p_grade_id	  in out nocopy number,
				p_grade_name	  in out nocopy varchar2,
				p_location_id     in out nocopy number,
				p_location_code   in out nocopy varchar2,
                                p_recruiter_number in out nocopy varchar2 ) is

l_proc           varchar2(20)   := 'get_vacancy_details';
l_manager_id     per_vacancies.manager_id%TYPE;
l_manager_name   per_all_people_f.full_name%TYPE;
l_manager_number per_all_people_f.employee_number%TYPE;

begin
  --
  hr_utility.set_location('Entering: '|| g_package || l_proc, 10);

  get_vacancy_details ( p_vacancy_id        =>  p_vacancy_id
			,p_vacancy_name     =>  p_vacancy_name
			,p_recruiter_id     =>  p_recruiter_id
			,p_recruiter_name   =>  p_recruiter_name
			,p_org_id           =>  p_org_id
			,p_org_name	    =>  p_org_name
			,p_people_group_id  =>  p_people_group_id
			,p_job_id           =>  p_job_id
			,p_job_name         =>  p_job_name
			,p_pos_id           =>  p_pos_id
			,p_pos_name         =>  p_pos_name
			,p_grade_id         =>  p_grade_id
			,p_grade_name	    =>  p_grade_name
			,p_location_id      =>  p_location_id
			,p_location_code    =>  p_location_code
                        ,p_recruiter_number =>  p_recruiter_number
                        ,p_manager_id       =>  l_manager_id
                        ,p_manager_name     =>  l_manager_name
                        ,p_manager_number   =>  l_manager_number);

  hr_utility.set_location('Leaving: '|| g_package || l_proc, 100);
  --
end;

--
procedure get_vacancy_details ( p_vacancy_id      in number,
				p_vacancy_name    in out nocopy varchar2,
				p_recruiter_id    in out nocopy number,
				p_recruiter_name  in out nocopy varchar2,
				p_org_id 	  in out nocopy number,
				p_org_name	  in out nocopy varchar2,
				p_people_group_id in out nocopy number,
				p_job_id	  in out nocopy number,
				p_job_name	  in out nocopy varchar2,
				p_pos_id	  in out nocopy number,
				p_pos_name	  in out nocopy varchar2,
				p_grade_id	  in out nocopy number,
				p_grade_name	  in out nocopy varchar2,
				p_location_id     in out nocopy number,
				p_location_code   in out nocopy varchar2,
                                p_recruiter_number in out nocopy varchar2,
                                -- Start changes for bug 8678206
                                p_manager_id       in out nocopy number,
                                p_manager_name     in out nocopy varchar2,
                                p_manager_number   in out nocopy varchar2) is
                                -- End changes for bug 8678206
cursor get_vacancy is
  select x.name,
	 x.organization_id,
	 x.people_group_id,
	 x.job_id,
	 x.position_id,
	 x.grade_id,
	 x.location_id,
	 x.recruiter_id,
         x.manager_id -- added for bug 8678206
  from   per_all_vacancies x
  where  x.vacancy_id = p_vacancy_id ;
--
cursor get_organization is
  select xtl.name
  from   hr_all_organization_units_tl xtl,
         hr_all_organization_units x
  where  xtl.organization_id = p_org_id
  and    x.organization_id = xtl.organization_id
  and    xtl.LANGUAGE = userenv('LANG');
--
cursor get_recruiter is
  select per.full_name
        ,per.employee_number
  from   per_all_people per
  where  per.person_id = p_recruiter_id;
--
cursor get_job is
  select x.name
  from   per_jobs_vl x
  where  x.job_id = p_job_id ;
--
-- Changed 01-Oct-99 SCNair (per_all_positions to hr_all_positions) date track requirement
--
cursor get_position is
  select x.name
  from   hr_all_positions x
  where  x.position_id = p_pos_id ;
--
cursor get_grade is
  select x.name
  from   per_grades_vl x
  where  x.grade_id = p_grade_id ;
--
cursor get_location is
  select l.location_code
  from   hr_locations l
  where  l.location_id = p_location_id ;
--
-- Start changes for bug 8678206
cursor get_manager is
  select per.full_name
        ,per.employee_number
  from   per_all_people per
  where  per.person_id = p_manager_id;
-- End changes for bug 8678206
--
l_proc       varchar2(20)   := 'get_vacancy_details';
--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;


    if p_vacancy_name is null then
     open get_vacancy ;
     fetch get_vacancy into p_vacancy_name,
		            p_org_id,
		            p_people_group_id,
		  	    p_job_id,
		   	    p_pos_id,
		    	    p_grade_id,
		   	    p_location_id,
			    p_recruiter_id,
                            p_manager_id; -- added for bug 8678206
     close get_vacancy ;
    end if ;
--
--   Retrieve descriptions
--
    -- Recruiter
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 10);
  END IF;
    if p_recruiter_id is not null then
       open get_recruiter ;
       fetch get_recruiter into p_recruiter_name
                               ,p_recruiter_number ;
       close get_recruiter ;
    else
       p_recruiter_name := null ;
       p_recruiter_number := null;
    end if ;
--
    -- Organization
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 20);
  END IF;

    if p_org_id is not null then
       open get_organization ;
       fetch get_organization into p_org_name ;
       close get_organization ;
    else
       p_org_name := null ;
    end if ;
--
    -- Job
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 30);
  END IF;

    if p_job_id is not null then
       open get_job ;
       fetch get_job into p_job_name ;
       close get_job ;
    else
       p_job_name := null ;
    end if ;
--
    -- Position
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 40);
  END IF;

    if p_pos_id is not null then
       open get_position ;
       fetch get_position into p_pos_name ;
       close get_position ;
    else
       p_pos_name := null ;
    end if ;
--
    -- Grade
   IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 50);
  END IF;

   if p_grade_id is not null then
       open get_grade ;
       fetch get_grade into p_grade_name ;
       close get_grade ;
    else
       p_grade_name := null ;
    end if ;
--
    -- Location
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 60);
  END IF;

    if p_location_id is not null then
       open get_location ;
       fetch get_location into p_location_code ;
       close get_location ;
    else
       p_location_code := null ;
    end if ;
--

-- Start changes for bug 8678206
  -- Manager
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 65);
  END IF;

    if p_manager_id is not null then
       open get_manager ;
       fetch get_manager into p_manager_name, p_manager_number ;
       close get_manager ;
    else
       p_manager_name := null ;
       p_manager_number := null ;
    end if ;
--
-- End changes for bug 8678206

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 70);
  END IF;
end get_vacancy_details ;
--
-- Provide overload for get_vacancy_details
--
procedure get_vacancy_details ( p_vacancy_id      in number,
				p_vacancy_name    in out nocopy varchar2,
				p_recruiter_id    in out nocopy number,
				p_recruiter_name  in out nocopy varchar2,
				p_org_id 	  in out nocopy number,
				p_org_name	  in out nocopy varchar2,
				p_people_group_id in out nocopy number,
				p_job_id	  in out nocopy number,
				p_job_name	  in out nocopy varchar2,
				p_pos_id	  in out nocopy number,
				p_pos_name	  in out nocopy varchar2,
				p_grade_id	  in out nocopy number,
				p_grade_name	  in out nocopy varchar2,
				p_location_id     in out nocopy number,
				p_location_code   in out nocopy varchar2) is

l_recruiter_number PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE;

begin
  get_vacancy_details (p_vacancy_id       => p_vacancy_id,
                       p_vacancy_name     => p_vacancy_name,
                       p_recruiter_id     => p_recruiter_id,
                       p_recruiter_name   => p_recruiter_name,
                       p_org_id           => p_org_id,
                       p_org_name         => p_org_name,
                       p_people_group_id  => p_people_group_id,
                       p_job_id           => p_job_id,
                       p_job_name         => p_job_name,
                       p_pos_id           => p_pos_id,
                       p_pos_name         => p_pos_name,
                       p_grade_id         => p_grade_id,
                       p_grade_name       => p_grade_name,
                       p_location_id      => p_location_id,
                       p_location_code    => p_location_code,
                       p_recruiter_number => l_recruiter_number);
end get_vacancy_details;
--
-- Start changes for bug 8678206
--
procedure set_vac_from_rec_act ( p_recruitment_activity_id in number,
                                 p_date_received           in date,
                                 p_vacancy_id      	   in out nocopy number,
			 	 p_vacancy_name            in out nocopy varchar2,
				 p_recruiter_id    	   in out nocopy number,
				 p_recruiter_name  	   in out nocopy varchar2,
				 p_org_id	  	   in out nocopy number,
				 p_org_name	  	   in out nocopy varchar2,
				 p_people_group_id 	   in out nocopy number,
				 p_job_id	  	   in out nocopy number,
				 p_job_name	  	   in out nocopy varchar2,
				 p_pos_id	  	   in out nocopy number,
				 p_pos_name	  	   in out nocopy varchar2,
				 p_grade_id	  	   in out nocopy number,
				 p_grade_name	  	   in out nocopy varchar2,
				 p_location_id     	   in out nocopy number,
				 p_location_code   	   in out nocopy varchar2) is

  --
  l_proc           varchar2(20):= 'set_vac_from_rec_act';
  l_manager_id     per_vacancies.manager_id%TYPE;
  l_manager_name   per_all_people_f.full_name%TYPE;
  l_manager_number per_all_people_f.employee_number%TYPE;
  --

begin
--
  hr_utility.set_location('Entering: '|| g_package || l_proc, 10);
  --
  set_vac_from_rec_act  (p_recruitment_activity_id =>  p_recruitment_activity_id
                        ,p_date_received           =>  p_date_received
                        ,p_vacancy_id              =>  p_vacancy_id
			,p_vacancy_name            =>  p_vacancy_name
			,p_recruiter_id            =>  p_recruiter_id
			,p_recruiter_name          =>  p_recruiter_name
			,p_org_id                  =>  p_org_id
			,p_org_name                =>  p_org_name
			,p_people_group_id         =>  p_people_group_id
			,p_job_id                  =>  p_job_id
			,p_job_name                =>  p_job_name
			,p_pos_id                  =>  p_pos_id
			,p_pos_name                =>  p_pos_name
			,p_grade_id                =>  p_grade_id
			,p_grade_name              =>  p_grade_name
			,p_location_id             =>  p_location_id
			,p_location_code           =>  p_location_code
                        ,p_manager_id              =>  l_manager_id
                        ,p_manager_name            =>  l_manager_name
                        ,p_manager_number          =>  l_manager_number);
  --
  hr_utility.set_location('Leaving: '|| g_package || l_proc, 100);
--
end;

--
procedure set_vac_from_rec_act ( p_recruitment_activity_id in number,
                                 p_date_received           in date,
                                 p_vacancy_id      	   in out nocopy number,
			 	 p_vacancy_name            in out nocopy varchar2,
				 p_recruiter_id    	   in out nocopy number,
				 p_recruiter_name  	   in out nocopy varchar2,
				 p_org_id	  	   in out nocopy number,
				 p_org_name	  	   in out nocopy varchar2,
				 p_people_group_id 	   in out nocopy number,
				 p_job_id	  	   in out nocopy number,
				 p_job_name	  	   in out nocopy varchar2,
				 p_pos_id	  	   in out nocopy number,
				 p_pos_name	  	   in out nocopy varchar2,
				 p_grade_id	  	   in out nocopy number,
				 p_grade_name	  	   in out nocopy varchar2,
				 p_location_id     	   in out nocopy number,
				 p_location_code   	   in out nocopy varchar2,
                                 -- Start changes for bug 8678206
                                 p_manager_id             in out nocopy number,
                                 p_manager_name           in out nocopy varchar2,
                                 p_manager_number         in out nocopy varchar2) is
                                 -- End changes for bug 8678206

l_recruiter_number PER_ALL_PEOPLE.EMPLOYEE_NUMBER%TYPE;

l_proc             varchar2(20)  := 'set_vac_from_rec_act';

begin
--
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;

   -- Check that the vacancy is unique
   p_vacancy_id := uniq_vac_for_rec_act ( p_recruitment_activity_id,
					  p_date_received ) ;
   --
   -- Get the details if there is a unique vacancy
   --
   if ( p_vacancy_id is not null ) then
	  get_vacancy_details ( p_vacancy_id      => p_vacancy_id,
				p_vacancy_name    => p_vacancy_name,
				p_recruiter_id    => p_recruiter_id,
				p_recruiter_name  => p_recruiter_name,
				p_org_id 	  => p_org_id,
				p_org_name	  => p_org_name,
				p_people_group_id => p_people_group_id,
				p_job_id	  => p_job_id,
				p_job_name	  => p_job_name,
				p_pos_id	  => p_pos_id,
				p_pos_name	  => p_pos_name,
				p_grade_id	  => p_grade_id,
				p_grade_name	  => p_grade_name,
				p_location_id     => p_location_id,
				p_location_code   => p_location_code,
                                p_recruiter_number=> l_recruiter_number,
                                -- Start changes for bug 8678206
                                p_manager_id      => p_manager_id,
                                p_manager_name    => p_manager_name,
                                p_manager_number  => p_manager_number);
                                -- End changes for bug 8678206
   end if ;
   --
  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
  END IF;

end set_vac_from_rec_act ;
--
--
--
function chk_job_org_pos_comb ( p_job_id        in number,
				p_org_id        in number,
				p_pos_id        in number,
				p_date_received in date    ) return boolean is
l_return_value boolean := FALSE ;
l_dummy	       number ;
l_proc         varchar2(20)   :='chk_job_org_pos_comb';
--
-- Changed 01-Oct-99 SCNair (per_all_positions to hr_all_positions) date track requirement.
cursor c1 is
SELECT 1
FROM   HR_ALL_POSITIONS P
WHERE  P.JOB_ID          = p_job_id
AND    P.ORGANIZATION_ID = p_org_id
AND    P.POSITION_ID     = p_pos_id
AND    P.DATE_EFFECTIVE <= p_date_received
AND    ((P.DATE_END IS NULL)
OR      (P.DATE_END >= p_date_received )) ;
begin
--
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;

   open c1 ;
   fetch c1 into l_dummy ;
   l_return_value := c1%found ;
   close c1 ;
--

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
  END IF;

   return ( l_return_value ) ;
--
end chk_job_org_pos_comb ;
--
procedure update_group( p_pg_id         number,
			p_group_name    varchar2) is

begin
   if p_pg_id <> -1 then
   --
   -- This is an existing desc flex record, update group_name held on
   -- combinations table.
      update pay_people_groups
      set     group_name      = P_GROUP_NAME
      where   people_group_id = P_PG_ID
      and P_GROUP_NAME is not null; -- 4103321
   --
      if sql%rowcount = 0 then
        fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL' );
        fnd_message.set_token('PROCEDURE','PER_APPLICANT_PKG.UPDATE_GROUP');
        fnd_message.set_token('STEP','1' ) ;
        fnd_message.raise_error ;
     end if ;
   end if;
end update_group ;
--
procedure exists_val_grd_for_pos_and_job ( p_business_group_id  in number,
					   p_date_received      in date,
					   p_job_id	        in number,
					   p_exists_grd_for_job out nocopy boolean,
					   p_pos_id             in number,
					   p_exists_grd_for_pos out nocopy boolean ) is
--
l_dummy_number number ;		-- Used to discard output from cursor
l_proc         varchar2(31)   := 'exists_val_grd_for_pos_and_job';
--
cursor c1 is
SELECT 1
FROM   SYS.DUAL
WHERE  EXISTS
      (SELECT NULL
       FROM   PER_VALID_GRADES
       WHERE  business_group_id + 0 = p_business_group_id
       AND    DATE_FROM        <= p_date_received
       AND  ((DATE_TO IS NULL)
              OR    (DATE_TO   >= p_date_received))
       AND    JOB_ID            = p_job_id ) ;
--
cursor c2 is
SELECT 1
FROM   SYS.DUAL
WHERE  EXISTS
      (SELECT NULL
       FROM   PER_VALID_GRADES
       WHERE  business_group_id + 0 = p_business_group_id
       AND    DATE_FROM        <= p_date_received
       AND  ((DATE_TO IS NULL)
              OR    (DATE_TO   >= p_date_received))
       AND    POSITION_ID       = p_pos_id) ;
--
--
begin
  --

  open c1 ;
  fetch c1 into l_dummy_number ;
  p_exists_grd_for_job := c1%found ;
  close c1 ;
  --
  if p_pos_id is null then
    p_exists_grd_for_pos := FALSE ;
  else
    open c2 ;
    fetch c2 into l_dummy_number ;
    p_exists_grd_for_pos := c2%found ;
    close c2 ;
  end if ;
  --
  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 1);
  END IF;

end exists_val_grd_for_pos_and_job ;
--
--  ***TEMP Probably obsolete
procedure check_apl_num_unique( p_business_group_id in number,
			        p_applicant_number  in number ) is
l_dummy_number number ;
cursor c1 is
  SELECT 1
  FROM   PER_ALL_PEOPLE_F
  WHERE  APPLICANT_NUMBER  = p_applicant_number
  AND    business_group_id + 0 = p_business_group_id ;
begin
--
  open c1 ;
  fetch c1 into l_dummy_number ;
  if c1%found then
    close c1 ;
    hr_utility.set_message('PAY','HR_6413_APPL_NO_EXISTS');
    hr_utility.raise_error ;
  end if ;
  close c1 ;
--
end check_apl_num_unique ;
--
procedure check_delete_allowed ( p_person_id    in number,
				 p_session_date in date ) is
--
l_dummy_number number := NULL ;
cursor c1 is
  select 1
  from   per_all_people_f
  where  person_id = p_person_id
  group  by person_id having count(*) > 1 ;
--
cursor c2 is
  select 1
  from   per_addresses
  where  person_id = p_person_id
  group by person_id having count(*) > 1 ;
begin
--
  open c1 ;
  fetch c1 into l_dummy_number ;
  if c1%found then
     close c1 ;
     hr_utility.set_message(801,'HR_6414_APPL_DATE_EFFECTIVE' );
     hr_utility.raise_error ;
  end if;
  close c1 ;
  --
  open c2 ;
  fetch c2 into l_dummy_number ;
  if c2%found then
     close c2 ;
     hr_utility.set_message(801,'HR_6415_APPL_ADDRESS' );
     hr_utility.raise_error ;
  end if;
  close c2 ;
  --
  -- Fix for 3908271 starts here.
  -- The Applicant Quick entry form is using this validation proc.
  -- Now the form is using API proc hr_person_api.delete_person which
  -- includes the strong predel validations. So comment out here.
  --
  /*
  -- Standard strong delete check
  hr_person.strong_predel_validation ( p_person_id    => p_person_id,
				       p_session_date => p_session_date ) ;
  */
  --
  -- Fix for 3908271 ends here.
  --
--
end check_delete_allowed ;
--
procedure create_default_budget_values ( p_business_group_id in number,
					 p_assignment_id     in number,
                                         p_effective_start_date in date,
					 p_effective_end_date   in date) is

l_proc   varchar2(28) := 'create_default_budget_values';
begin
--
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;

    insert into per_assignment_budget_values_f
	    (assignment_budget_value_id,
             effective_start_date,
             effective_end_date,
	     business_group_id,
	     assignment_id,
	     unit,
	     value)
    select per_assignment_budget_values_s.nextval,
           p_effective_start_date,
           p_effective_end_date,
	   p_business_group_id,
	   p_assignment_id,
	   d.unit,
	   d.value
    from   per_default_budget_values d
    where  d.business_group_id + 0 = p_business_group_id ;
--

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
  END IF;
end create_default_budget_values ;
--
procedure check_for_letter_requests ( p_business_group_id in number,
				      p_per_system_status in varchar2,
				      p_assignment_status_type_id in number,
				      p_person_id	       in number,
				      p_assignment_id          in number,
				      p_effective_start_date   in date,
				      p_validation_start_date  in date,
				      p_vacancy_id		in number) is
l_dummy_number number ;
l_proc         varchar2(25)  := 'check_for_letter_requests';

cursor check_statuses is
  select 1
  from   per_letter_gen_statuses s
  where  s.business_group_id + 0         = p_business_group_id
  and    s.assignment_status_type_id = p_assignment_status_type_id
  and    s.enabled_flag              = 'Y' ;
--
-- Fix for bug 3680947 starts here.
--
CURSOR csr_check_manual_or_auto IS
SELECT 1
FROM  PER_LETTER_REQUESTS PLR,
      PER_LETTER_GEN_STATUSES PLGS
WHERE PLGS.business_group_id + 0 = p_business_group_id
AND   PLR.business_group_id +0 = p_business_group_id
AND   PLGS.assignment_status_type_id = p_assignment_status_type_id
AND   PLR.letter_type_id = PLGS.letter_type_id
AND   PLR.auto_or_manual = 'MANUAL';
--
-- Fix for bug 3680947 ends here.
--
begin
--
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 1);
  END IF;

  open check_statuses ;
  fetch check_statuses into l_dummy_number ;
  if check_statuses%notfound then
      close check_statuses ;
      return ;
  end if ;
  close check_statuses ;
--
-- Fix for bug 3680947 starts here.
--
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 10);
  END IF;

  open csr_check_manual_or_auto;
  fetch csr_check_manual_or_auto into l_dummy_number;
  if csr_check_manual_or_auto%found then
     close csr_check_manual_or_auto;
     return;
  end if;
  close csr_check_manual_or_auto;
--
-- Fix for bug 3680947 ends here.
--
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 20);
  END IF;


   if (nvl(fnd_profile.value('HR_LETTER_BY_VACANCY'),'N')='Y') then

  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 30);
    hr_utility.set_location('HR_LETTER_BY_VACANCY = Y',10);
  END IF;


  insert into per_letter_requests
  (   letter_request_id,
      business_group_id,
      letter_type_id,
      request_status,
      auto_or_manual,
      date_from,
      vacancy_id)
  select  per_letter_requests_s.nextval,
          p_business_group_id,
          s.letter_type_id,
          'PENDING',
          'AUTO',
          p_effective_start_date,
          p_vacancy_id
  from    PER_LETTER_GEN_STATUSES s
  where   s.business_group_id + 0     = p_business_group_id
  and     s.assignment_status_type_id = p_assignment_status_type_id
  and     s.enabled_flag              = 'Y'
  and not exists ( select null
		   from   per_letter_requests r
		   where  r.letter_type_id        = s.letter_type_id
		   and    r.business_group_id + 0 = p_business_group_id
		   and    r.business_group_id + 0 = s.business_group_id + 0
                   and    nvl(r.vacancy_id,-1) 	  = nvl(p_vacancy_id,-1)
		   and    r.request_status        = 'PENDING'
		   and    r.auto_or_manual        = 'AUTO' ) ;
   --
   -- Create a letter request line
   --
   -- Bug fix 3648715
   -- Insert statment modified - 'r.business_group_id +0' changed to
   -- r.business_group_id to improve performance.
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 40);
  END IF;

   insert into per_letter_request_lines
      (letter_request_line_id,
       business_group_id,
       letter_request_id,
       person_id,
       assignment_id,
       assignment_status_type_id,
       date_from )
   select  per_letter_request_lines_s.nextval,
           p_business_group_id,
           r.letter_request_id,
           p_person_id,
           p_assignment_id,
           p_assignment_status_type_id,
           p_validation_start_date
   from    per_letter_requests r
   where   exists
           (select null
            from    per_letter_gen_statuses s
            where   s.letter_type_id            = r.letter_type_id
            and     s.business_group_id + 0     = r.business_group_id + 0
            and     s.assignment_status_type_id= p_assignment_status_type_id
            and     s.enabled_flag = 'Y')
   and   not exists
            (select l.assignment_id
            from    per_letter_request_lines l
            where   l.letter_request_id = r.letter_request_id
            and     l.assignment_id     = p_assignment_id
            and     l.business_group_id + 0 = r.business_group_id + 0
            and     l.date_from         = p_validation_start_date)
   and    r.request_status        = 'PENDING'
   and    r.business_group_id  = p_business_group_id   -- bug fix 3648715
   and    nvl(r.vacancy_id,-1)    = nvl(p_vacancy_id,-1);

   else

   -- Profile HR: Letter by Vacancy has not been set to Yes
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 50);
  END IF;

   insert into per_letter_requests
     (letter_request_id,
      business_group_id,
      letter_type_id,
      request_status,
      auto_or_manual,
      date_from)
   select
      per_letter_requests_s.nextval,
      p_business_group_id,
      s.letter_type_id,
      'PENDING',
      'AUTO',
      p_effective_start_date
   from    PER_LETTER_GEN_STATUSES s
   where   s.business_group_id + 0     = p_business_group_id
   and     s.assignment_status_type_id = p_assignment_status_type_id
   and     s.enabled_flag              = 'Y'
   and not exists ( select null
                   from   per_letter_requests r
                   where  r.letter_type_id = s.letter_type_id
                   and    r.business_group_id + 0 = p_business_group_id
                   and    r.business_group_id + 0 = s.business_group_id + 0
                   and    r.request_status        = 'PENDING'
                   and    r.auto_or_manual        = 'AUTO' ) ;

   --
   -- Create a letter request line
   --
   -- bug fix 3648715
   -- Insert statment modified - 'r.business_group_id +0' changed to
   -- r.business_group_id to improve performance.
  IF g_debug THEN
    hr_utility.set_location(g_package || l_proc, 60);
  END IF;

    insert into per_letter_request_lines
      (letter_request_line_id,
       business_group_id,
       letter_request_id,
       person_id,
       assignment_id,
       assignment_status_type_id,
       date_from )
   select
       per_letter_request_lines_s.nextval,
       p_business_group_id,
       r.letter_request_id,
       p_person_id,
       p_assignment_id,
       p_assignment_status_type_id,
       p_validation_start_date
   from    per_letter_requests r
   where   exists
           (select null
            from    per_letter_gen_statuses s
            where   s.letter_type_id            = r.letter_type_id
            and     s.business_group_id + 0     = r.business_group_id + 0
            and     s.assignment_status_type_id = p_assignment_status_type_id
            and     s.enabled_flag              = 'Y')
   and not exists
           (select l.assignment_id
            from    per_letter_request_lines l
            where   l.letter_request_id = r.letter_request_id
            and     l.assignment_id     = p_assignment_id
            and     l.business_group_id + 0 = r.business_group_id + 0
            and     l.date_from         = p_validation_start_date)
   and r.request_status        = 'PENDING'
   and r.business_group_id  = p_business_group_id ;  -- bug fix 3648715

   end if;
--
--
  IF g_debug THEN
    hr_utility.set_location('Leaving: ' ||g_package || l_proc, 30);
  END IF;

end check_for_letter_requests ;
--
procedure pre_update ( p_rowid              in varchar2,
		       p_person_id	    in number,
		       p_business_group_id  in number,
		       p_date_received      in date,
		       p_old_date_received  in out nocopy date ) is
l_system_person_type varchar2(30) ;
cursor c1 is
  select date_received
  from   per_applications
  where  rowid = p_rowid  ;
--
cursor c2 is
  select ppt.system_person_type
  from   per_people_f     per,
	 per_person_types ppt
  where  per.person_id      = p_person_id
  and    per.person_type_id = ppt.person_type_id ;
begin
--
  open c1 ;
  fetch c1 into p_old_date_received ;
  close c1 ;
  --
  open c2 ;
  fetch c2 into l_system_person_type ;
  close c2 ;
  --
  if ( p_old_date_received <> p_date_received ) then
     hr_date_chk.check_apl_ref_int ( p_person_id,
				     p_business_group_id,
				     l_system_person_type,
				     p_old_date_received,
				     p_date_received ) ;
  end if;
  --
end pre_update ;

function get_territory_short_name ( p_territory_code in varchar2 )
    return varchar2 is
l_return_value fnd_territories_vl.territory_short_name%type := null ;
--
cursor get_territory_short_name is
  select territory_short_name
  from fnd_territories_vl
  where territory_code = p_territory_code ;
begin

  if ( p_territory_code is not null ) then
        open get_territory_short_name ;
        fetch get_territory_short_name into l_return_value ;
        close get_territory_short_name ;
  end if;

  return(l_return_value);

end get_territory_short_name ;
--
function get_style_name (p_style in varchar2)
  return varchar2 is
 l_return_value fnd_descr_flex_contexts_vl.descriptive_flex_context_name%type := null;
--
cursor get_style_name is
  select descriptive_flex_context_name
  from fnd_descr_flex_contexts_vl
  where descriptive_flex_context_code = p_style;
--
begin
  if (p_style is not null) then
	open get_style_name;
	fetch get_style_name into l_return_value;
	close get_style_name;
  end if;
--
  return(l_return_value);
--
end get_style_name;
--
end PER_APPLICANT_PKG ;

/
