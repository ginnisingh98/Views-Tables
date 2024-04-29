--------------------------------------------------------
--  DDL for Package Body GHR_HISTORY_CONV_RG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_HISTORY_CONV_RG" as
/* $Header: ghconvrg.pkb 115.7 2003/09/02 02:43:46 ajose ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Ghr_History_API> >--------------------------|
-- ----------------------------------------------------------------------------
--



Procedure copy_field_value(
	p_source_field  	in varchar2,
	p_target_field   	in out nocopy varchar2 ) is

	l_proc		   varchar2(30) := 'copy_field_value 1';
	l_target_field     varchar(4000);
begin

        l_target_field := p_target_field; /* NOCOPY CHANGES */

	hr_utility.set_location('Entering:'|| l_proc, 5);
	if ( p_source_field is not null  ) then
		p_target_field := p_source_field;
 	end if;
	hr_utility.set_location(' Leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_target_field := l_target_field;
     raise;

end copy_field_value;


Procedure copy_field_value(
	p_source_field  	in date,
	p_target_field   	in out nocopy date ) is

	l_proc		varchar2(30) := 'copy_field_value 2';
        l_target_field  date;
begin

        l_target_field := p_target_field; /* NOCOPY CHANGES */

	hr_utility.set_location('Entering:'|| l_proc, 15);
	if ( p_source_field is not null  ) then
		p_target_field := p_source_field;
	end if;
	hr_utility.set_location(' Leaving:'||l_proc, 20);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_target_field := l_target_field;
     raise;

end copy_field_value;


Procedure copy_field_value(
	p_source_field  	in number,
	p_target_field   	in out nocopy number ) is

	l_proc		varchar2(30):='copy_field_value 3';
        l_target_field  number;
begin

        l_target_field := p_target_field; /* NOCOPY CHANGES */

	hr_utility.set_location('Entering:'|| l_proc, 25);
	if ( p_source_field is not null ) then
		p_target_field := p_source_field;
	end if;
	hr_utility.set_location(' Leaving:'||l_proc, 30);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_target_field := l_target_field;
     raise;
end copy_field_value;

-- Procedure conv_to_people_rg copies the indivisual fields supplied as parameters
-- to the per_peole_f type record.
Procedure conv_to_people_rg(
	p_person_id                    in per_people_f.person_id%type                     default null,
	p_effective_start_date         in per_people_f.effective_start_date%type          default null,
	p_effective_end_date           in per_people_f.effective_end_date%type            default null,
	p_business_group_id            in per_people_f.business_group_id%type             default null,
	p_person_type_id               in per_people_f.person_type_id%type                default null,
	p_last_name                    in per_people_f.last_name%type                     default null,
	p_start_date                   in per_people_f.start_date%type                    default null,
	p_applicant_number             in per_people_f.applicant_number%type              default null,
	p_background_check_status      in per_people_f.background_check_status%type       default null,
	p_background_date_check        in per_people_f.background_date_check%type         default null,
	p_blood_type                   in per_people_f.blood_type%type                    default null,
	p_comment_id                   in per_people_f.comment_id%type                    default null,
	p_correspondence_language      in per_people_f.correspondence_language%type       default null,
	p_current_applicant_flag       in per_people_f.current_applicant_flag%type        default null,
	p_current_emp_or_apl_flag      in per_people_f.current_emp_or_apl_flag%type       default null,
	p_current_employee_flag        in per_people_f.current_employee_flag%type         default null,
	p_date_employee_data_verified  in per_people_f.date_employee_data_verified%type   default null,
	p_date_of_birth                in per_people_f.date_of_birth%type                 default null,
	p_email_address                in per_people_f.email_address%type                 default null,
	p_employee_number              in per_people_f.employee_number%type               default null,
	p_expense_check_send_to_add    in per_people_f.expense_check_send_to_address%type default null,
	p_fast_path_employee           in per_people_f.fast_path_employee%type            default null,
	p_first_name                   in per_people_f.first_name%type                    default null,
	p_fte_capacity                 in per_people_f.fte_capacity%type                  default null,
	p_full_name                    in per_people_f.full_name%type                     default null,
	p_hold_applicant_date_until    in per_people_f.hold_applicant_date_until%type     default null,
	p_honors                       in per_people_f.honors%type                        default null,
	p_internal_location            in per_people_f.internal_location%type             default null,
	p_known_as                     in per_people_f.known_as%type                      default null,
	p_last_medical_test_by         in per_people_f.last_medical_test_by%type          default null,
	p_last_medical_test_date       in per_people_f.last_medical_test_date%type        default null,
	p_mailstop                     in per_people_f.mailstop%type                      default null,
	p_marital_status               in per_people_f.marital_status%type                default null,
	p_middle_names                 in per_people_f.middle_names%type                  default null,
	p_nationality                  in per_people_f.nationality%type                   default null,
	p_national_identifier          in per_people_f.national_identifier%type           default null,
	p_office_number                in per_people_f.office_number%type                 default null,
	p_on_military_service          in per_people_f.on_military_service%type           default null,
	p_order_name                   in per_people_f.order_name%type                    default null,
	p_pre_name_adjunct             in per_people_f.pre_name_adjunct%type              default null,
	p_previous_last_name           in per_people_f.previous_last_name%type            default null,
	p_projected_start_date         in per_people_f.projected_start_date%type          default null,
	p_rehire_authorizor            in per_people_f.rehire_authorizor%type             default null,
	p_rehire_recommendation        in per_people_f.rehire_recommendation%type         default null,
	p_resume_exists                in per_people_f.resume_exists%type                 default null,
	p_resume_last_updated          in per_people_f.resume_last_updated%type           default null,
	p_registered_disabled_flag     in per_people_f.registered_disabled_flag%type      default null,
	p_second_passport_exists       in per_people_f.second_passport_exists%type        default null,
	p_sex                          in per_people_f.sex%type                           default null,
	p_student_status               in per_people_f.student_status%type                default null,
	p_suffix                       in per_people_f.suffix%type                        default null,
	p_title                        in per_people_f.title%type                         default null,
	p_vendor_id                    in per_people_f.vendor_id%type                     default null,
	p_work_schedule                in per_people_f.work_schedule%type                 default null,
	p_work_telephone               in per_people_f.work_telephone%type                default null,
	p_request_id                   in per_people_f.request_id%type                    default null,
	p_program_application_id       in per_people_f.program_application_id%type        default null,
	p_program_id                   in per_people_f.program_id%type                    default null,
	p_program_update_date          in per_people_f.program_update_date%type           default null,
	p_attribute_category           in per_people_f.attribute_category%type            default null,
	p_attribute1                   in per_people_f.attribute1%type                    default null,
	p_attribute2                   in per_people_f.attribute2%type                    default null,
	p_attribute3                   in per_people_f.attribute3%type                    default null,
	p_attribute4                   in per_people_f.attribute4%type                    default null,
	p_attribute5                   in per_people_f.attribute5%type                    default null,
	p_attribute6                   in per_people_f.attribute6%type                    default null,
	p_attribute7                   in per_people_f.attribute7%type                    default null,
	p_attribute8                   in per_people_f.attribute8%type                    default null,
	p_attribute9                   in per_people_f.attribute9%type                    default null,
	p_attribute10                  in per_people_f.attribute10%type                   default null,
	p_attribute11                  in per_people_f.attribute11%type                   default null,
	p_attribute12                  in per_people_f.attribute12%type                   default null,
	p_attribute13                  in per_people_f.attribute13%type                   default null,
	p_attribute14                  in per_people_f.attribute14%type                   default null,
	p_attribute15                  in per_people_f.attribute15%type                   default null,
	p_attribute16                  in per_people_f.attribute16%type                   default null,
	p_attribute17                  in per_people_f.attribute17%type                   default null,
	p_attribute18                  in per_people_f.attribute18%type                   default null,
	p_attribute19                  in per_people_f.attribute19%type                   default null,
	p_attribute20                  in per_people_f.attribute20%type                   default null,
	p_attribute21                  in per_people_f.attribute21%type                   default null,
	p_attribute22                  in per_people_f.attribute22%type                   default null,
	p_attribute23                  in per_people_f.attribute23%type                   default null,
	p_attribute24                  in per_people_f.attribute24%type                   default null,
	p_attribute25                  in per_people_f.attribute25%type                   default null,
	p_attribute26                  in per_people_f.attribute26%type                   default null,
	p_attribute27                  in per_people_f.attribute27%type                   default null,
	p_attribute28                  in per_people_f.attribute28%type                   default null,
	p_attribute29                  in per_people_f.attribute29%type                   default null,
	p_attribute30                  in per_people_f.attribute30%type                   default null,
	p_per_information_category     in per_people_f.per_information_category%type      default null,
	p_per_information1             in per_people_f.per_information1%type              default null,
	p_per_information2             in per_people_f.per_information2%type              default null,
	p_per_information3             in per_people_f.per_information3%type              default null,
	p_per_information4             in per_people_f.per_information4%type              default null,
	p_per_information5             in per_people_f.per_information5%type              default null,
	p_per_information6             in per_people_f.per_information6%type              default null,
	p_per_information7             in per_people_f.per_information7%type              default null,
	p_per_information8             in per_people_f.per_information8%type              default null,
	p_per_information9             in per_people_f.per_information9%type              default null,
	p_per_information10            in per_people_f.per_information10%type             default null,
	p_per_information11            in per_people_f.per_information11%type             default null,
	p_per_information12            in per_people_f.per_information12%type             default null,
	p_per_information13            in per_people_f.per_information13%type             default null,
	p_per_information14            in per_people_f.per_information14%type             default null,
	p_per_information15            in per_people_f.per_information15%type             default null,
	p_per_information16            in per_people_f.per_information16%type             default null,
	p_per_information17            in per_people_f.per_information17%type             default null,
	p_per_information18            in per_people_f.per_information18%type             default null,
	p_per_information19            in per_people_f.per_information19%type             default null,
	p_per_information20            in per_people_f.per_information20%type             default null,
	p_per_information21            in per_people_f.per_information21%type             default null,
	p_per_information22            in per_people_f.per_information22%type             default null,
	p_per_information23            in per_people_f.per_information23%type             default null,
	p_per_information24            in per_people_f.per_information24%type             default null,
	p_per_information25            in per_people_f.per_information25%type             default null,
	p_per_information26            in per_people_f.per_information26%type             default null,
	p_per_information27            in per_people_f.per_information27%type             default null,
	p_per_information28            in per_people_f.per_information28%type             default null,
	p_per_information29            in per_people_f.per_information29%type             default null,
	p_per_information30            in per_people_f.per_information30%type             default null,
--	p_object_version_number        in per_people_f.object_version_number%type         default null,
	p_date_of_death                in per_people_f.date_of_death%type                 default null,
	p_rehire_reason                in per_people_f.rehire_reason%type                 default null,
	p_people_data	  	   in out nocopy per_all_people_f%rowtype  )  is

	l_proc	varchar2(30):='conv_to_people_rg';
	l_people_data	per_all_people_f%rowtype;

begin

	l_people_data :=p_people_data; --NOCOPY Changes

	hr_utility.set_location('Entering:'|| l_proc, 5);

	copy_field_value(	p_source_field =>  p_person_id,
			   	p_target_field =>  p_people_data.person_id);
	copy_field_value( p_source_field =>  p_effective_start_date,
			   	p_target_field =>  p_people_data.effective_start_date);
	copy_field_value( p_source_field =>  p_effective_end_date,
			   	p_target_field =>  p_people_data.effective_end_date);
	copy_field_value( p_source_field =>  p_business_group_id,
			   	p_target_field =>  p_people_data.business_group_id);
	copy_field_value( p_source_field =>  p_person_type_id,
			   	p_target_field =>  p_people_data.person_type_id);
	copy_field_value( p_source_field =>  p_last_name,
			   	p_target_field =>  p_people_data.last_name);
	copy_field_value( p_source_field =>  p_start_date,
			   	p_target_field =>  p_people_data.start_date);
	copy_field_value( p_source_field =>  p_applicant_number,
			   	p_target_field =>  p_people_data.applicant_number);
	copy_field_value( p_source_field =>  p_background_check_status,
			   	p_target_field =>  p_people_data.background_check_status);
	copy_field_value( p_source_field =>  p_background_date_check,
			   	p_target_field =>  p_people_data.background_date_check);
	copy_field_value( p_source_field =>  p_blood_type,
			   	p_target_field =>  p_people_data.blood_type);
	copy_field_value( p_source_field =>  p_comment_id,
			   	p_target_field =>  p_people_data.comment_id);
	copy_field_value( p_source_field =>  p_correspondence_language,
			   	p_target_field =>  p_people_data.correspondence_language);
	copy_field_value( p_source_field =>  p_current_applicant_flag,
			   	p_target_field =>  p_people_data.current_applicant_flag);
	copy_field_value( p_source_field =>  p_current_emp_or_apl_flag,
			   	p_target_field =>  p_people_data.current_emp_or_apl_flag);
	copy_field_value( p_source_field =>  p_current_employee_flag,
			   	p_target_field =>  p_people_data.current_employee_flag);
	copy_field_value( p_source_field =>  p_date_employee_data_verified,
			   	p_target_field =>  p_people_data.date_employee_data_verified);
	copy_field_value( p_source_field =>  p_date_of_birth,
			   	p_target_field =>  p_people_data.date_of_birth);
	copy_field_value( p_source_field =>  p_email_address,
			   	p_target_field =>  p_people_data.email_address);
	copy_field_value( p_source_field =>  p_employee_number,
			   	p_target_field =>  p_people_data.employee_number);
	copy_field_value( p_source_field =>  p_expense_check_send_to_add,
			   	p_target_field =>  p_people_data.expense_check_send_to_address);
	copy_field_value( p_source_field =>  p_fast_path_employee,
			   	p_target_field =>  p_people_data.fast_path_employee);
	copy_field_value( p_source_field =>  p_first_name,
			   	p_target_field =>  p_people_data.first_name);
	copy_field_value( p_source_field =>  p_fte_capacity,
			   	p_target_field =>  p_people_data.fte_capacity);
	copy_field_value( p_source_field =>  p_full_name,
			   	p_target_field =>  p_people_data.full_name);
	copy_field_value( p_source_field =>  p_hold_applicant_date_until,
			   	p_target_field =>  p_people_data.hold_applicant_date_until);
	copy_field_value( p_source_field =>  p_honors,
			   	p_target_field =>  p_people_data.honors);
	copy_field_value( p_source_field =>  p_internal_location,
			   	p_target_field =>  p_people_data.internal_location);
	copy_field_value( p_source_field =>  p_known_as,
			   	p_target_field =>  p_people_data.known_as);
	copy_field_value( p_source_field =>  p_last_medical_test_by,
			   	p_target_field =>  p_people_data.last_medical_test_by);
	copy_field_value( p_source_field =>  p_last_medical_test_date,
			   	p_target_field =>  p_people_data.last_medical_test_date);
	copy_field_value( p_source_field =>  p_mailstop,
			   	p_target_field =>  p_people_data.mailstop);
	copy_field_value( p_source_field =>  p_marital_status,
			   	p_target_field =>  p_people_data.marital_status);
	copy_field_value( p_source_field =>  p_middle_names,
			   	p_target_field =>  p_people_data.middle_names);
	copy_field_value( p_source_field =>  p_nationality,
			   	p_target_field =>  p_people_data.nationality);
	copy_field_value( p_source_field =>  p_national_identifier,
			   	p_target_field =>  p_people_data.national_identifier);
	copy_field_value( p_source_field =>  p_office_number,
			   	p_target_field =>  p_people_data.office_number);
	copy_field_value( p_source_field =>  p_on_military_service,
			   	p_target_field =>  p_people_data.on_military_service);
	copy_field_value( p_source_field =>  p_order_name,
			   	p_target_field =>  p_people_data.order_name);
	copy_field_value( p_source_field =>  p_pre_name_adjunct,
			   	p_target_field =>  p_people_data.pre_name_adjunct);
	copy_field_value( p_source_field =>  p_previous_last_name,
			   	p_target_field =>  p_people_data.previous_last_name);
	copy_field_value( p_source_field =>  p_projected_start_date,
			   	p_target_field =>  p_people_data.projected_start_date);
	copy_field_value( p_source_field =>  p_rehire_authorizor,
			   	p_target_field =>  p_people_data.rehire_authorizor);
	copy_field_value( p_source_field =>  p_rehire_recommendation,
			   	p_target_field =>  p_people_data.rehire_recommendation);
	copy_field_value( p_source_field =>  p_resume_exists,
			   	p_target_field =>  p_people_data.resume_exists);
	copy_field_value( p_source_field =>  p_resume_last_updated,
			   	p_target_field =>  p_people_data.resume_last_updated);
	copy_field_value( p_source_field =>  p_registered_disabled_flag,
			   	p_target_field =>  p_people_data.registered_disabled_flag);
	copy_field_value( p_source_field =>  p_second_passport_exists,
			   	p_target_field =>  p_people_data.second_passport_exists);
	copy_field_value( p_source_field =>  p_sex,
			   	p_target_field =>  p_people_data.sex);
	copy_field_value( p_source_field =>  p_student_status,
			   	p_target_field =>  p_people_data.student_status);
	copy_field_value( p_source_field =>  p_suffix,
			   	p_target_field =>  p_people_data.suffix);
	copy_field_value( p_source_field =>  p_title,
			   	p_target_field =>  p_people_data.title);
	copy_field_value( p_source_field =>  p_vendor_id,
			   	p_target_field =>  p_people_data.vendor_id);
	copy_field_value( p_source_field =>  p_work_schedule,
			   	p_target_field =>  p_people_data.work_schedule);
	copy_field_value( p_source_field =>  p_work_telephone,
			   	p_target_field =>  p_people_data.work_telephone);
	copy_field_value( p_source_field =>  p_request_id,
			   	p_target_field =>  p_people_data.request_id);
	copy_field_value( p_source_field =>  p_program_application_id,
			   	p_target_field =>  p_people_data.program_application_id);
	copy_field_value( p_source_field =>  p_program_id,
			   	p_target_field =>  p_people_data.program_id);
	copy_field_value( p_source_field =>  p_program_update_date,
			   	p_target_field =>  p_people_data.program_update_date);
	copy_field_value( p_source_field =>  p_attribute_category,
			   	p_target_field =>  p_people_data.attribute_category);
	copy_field_value( p_source_field =>  p_attribute1,
			   	p_target_field =>  p_people_data.attribute1);
	copy_field_value( p_source_field =>  p_attribute2,
			   	p_target_field =>  p_people_data.attribute2);
	copy_field_value( p_source_field =>  p_attribute3,
			   	p_target_field =>  p_people_data.attribute3);
	copy_field_value( p_source_field =>  p_attribute4,
			   	p_target_field =>  p_people_data.attribute4);
	copy_field_value( p_source_field =>  p_attribute5,
			   	p_target_field =>  p_people_data.attribute5);
	copy_field_value( p_source_field =>  p_attribute6,
			   	p_target_field =>  p_people_data.attribute6);
	copy_field_value( p_source_field =>  p_attribute7,
			   	p_target_field =>  p_people_data.attribute7);
	copy_field_value( p_source_field =>  p_attribute8,
			   	p_target_field =>  p_people_data.attribute8);
	copy_field_value( p_source_field =>  p_attribute9,
			   	p_target_field =>  p_people_data.attribute9);
	copy_field_value( p_source_field =>  p_attribute10,
			   	p_target_field =>  p_people_data.attribute10);
	copy_field_value( p_source_field =>  p_attribute11,
			   	p_target_field =>  p_people_data.attribute11);
	copy_field_value( p_source_field =>  p_attribute12,
			   	p_target_field =>  p_people_data.attribute12);
	copy_field_value( p_source_field =>  p_attribute13,
			   	p_target_field =>  p_people_data.attribute13);
	copy_field_value( p_source_field =>  p_attribute14,
			   	p_target_field =>  p_people_data.attribute14);
	copy_field_value( p_source_field =>  p_attribute15,
			   	p_target_field =>  p_people_data.attribute15);
	copy_field_value( p_source_field =>  p_attribute16,
			   	p_target_field =>  p_people_data.attribute16);
	copy_field_value( p_source_field =>  p_attribute17,
			   	p_target_field =>  p_people_data.attribute17);
	copy_field_value( p_source_field =>  p_attribute18,
			   	p_target_field =>  p_people_data.attribute18);
	copy_field_value( p_source_field =>  p_attribute19,
			   	p_target_field =>  p_people_data.attribute19);
	copy_field_value( p_source_field =>  p_attribute20,
			   	p_target_field =>  p_people_data.attribute20);
	copy_field_value( p_source_field =>  p_attribute21,
			   	p_target_field =>  p_people_data.attribute21);
	copy_field_value( p_source_field =>  p_attribute22,
			   	p_target_field =>  p_people_data.attribute22);
	copy_field_value( p_source_field =>  p_attribute23,
			   	p_target_field =>  p_people_data.attribute23);
	copy_field_value( p_source_field =>  p_attribute24,
			   	p_target_field =>  p_people_data.attribute24);
	copy_field_value( p_source_field =>  p_attribute25,
			   	p_target_field =>  p_people_data.attribute25);
	copy_field_value( p_source_field =>  p_attribute26,
			   	p_target_field =>  p_people_data.attribute26);
	copy_field_value( p_source_field =>  p_attribute27,
			   	p_target_field =>  p_people_data.attribute27);
	copy_field_value( p_source_field =>  p_attribute28,
			   	p_target_field =>  p_people_data.attribute28);
	copy_field_value( p_source_field =>  p_attribute29,
			   	p_target_field =>  p_people_data.attribute29);
	copy_field_value( p_source_field =>  p_attribute30,
			   	p_target_field =>  p_people_data.attribute30);
	copy_field_value( p_source_field =>  p_per_information_category,
			   	p_target_field =>  p_people_data.per_information_category);
	copy_field_value( p_source_field =>  p_per_information1,
			   	p_target_field =>  p_people_data.per_information1);
	copy_field_value( p_source_field =>  p_per_information2,
			   	p_target_field =>  p_people_data.per_information2);
	copy_field_value( p_source_field =>  p_per_information3,
			   	p_target_field =>  p_people_data.per_information3);
	copy_field_value( p_source_field =>  p_per_information4,
			   	p_target_field =>  p_people_data.per_information4);
	copy_field_value( p_source_field =>  p_per_information5,
			   	p_target_field =>  p_people_data.per_information5);
	copy_field_value( p_source_field =>  p_per_information6,
			   	p_target_field =>  p_people_data.per_information6);
	copy_field_value( p_source_field =>  p_per_information7,
			   	p_target_field =>  p_people_data.per_information7);
	copy_field_value( p_source_field =>  p_per_information8,
			   	p_target_field =>  p_people_data.per_information8);
	copy_field_value( p_source_field =>  p_per_information9,
			   	p_target_field =>  p_people_data.per_information9);
	copy_field_value( p_source_field =>  p_per_information10,
			   	p_target_field =>  p_people_data.per_information10);
	copy_field_value( p_source_field =>  p_per_information11,
			   	p_target_field =>  p_people_data.per_information11);
	copy_field_value( p_source_field =>  p_per_information12,
			   	p_target_field =>  p_people_data.per_information12);
	copy_field_value( p_source_field =>  p_per_information13,
			   	p_target_field =>  p_people_data.per_information13);
	copy_field_value( p_source_field =>  p_per_information14,
			   	p_target_field =>  p_people_data.per_information14);
	copy_field_value( p_source_field =>  p_per_information15,
			   	p_target_field =>  p_people_data.per_information15);
	copy_field_value( p_source_field =>  p_per_information16,
			   	p_target_field =>  p_people_data.per_information16);
	copy_field_value( p_source_field =>  p_per_information17,
			   	p_target_field =>  p_people_data.per_information17);
	copy_field_value( p_source_field =>  p_per_information18,
			   	p_target_field =>  p_people_data.per_information18);
	copy_field_value( p_source_field =>  p_per_information19,
			   	p_target_field =>  p_people_data.per_information19);
	copy_field_value( p_source_field =>  p_per_information20,
			   	p_target_field =>  p_people_data.per_information20);
	copy_field_value( p_source_field =>  p_per_information21,
			   	p_target_field =>  p_people_data.per_information21);
	copy_field_value( p_source_field =>  p_per_information22,
			   	p_target_field =>  p_people_data.per_information22);
	copy_field_value( p_source_field =>  p_per_information23,
			   	p_target_field =>  p_people_data.per_information23);
	copy_field_value( p_source_field =>  p_per_information24,
			   	p_target_field =>  p_people_data.per_information24);
	copy_field_value( p_source_field =>  p_per_information25,
			   	p_target_field =>  p_people_data.per_information25);
	copy_field_value( p_source_field =>  p_per_information26,
			   	p_target_field =>  p_people_data.per_information26);
	copy_field_value( p_source_field =>  p_per_information27,
			   	p_target_field =>  p_people_data.per_information27);
	copy_field_value( p_source_field =>  p_per_information28,
			   	p_target_field =>  p_people_data.per_information28);
	copy_field_value( p_source_field =>  p_per_information29,
			   	p_target_field =>  p_people_data.per_information29);
	copy_field_value( p_source_field =>  p_per_information30,
			   	p_target_field =>  p_people_data.per_information30);
--	copy_field_value( p_source_field =>  p_object_version_number,
--			   	p_target_field =>  p_people_data.object_version_number);
	copy_field_value( p_source_field =>  p_date_of_death,
			   	p_target_field =>  p_people_data.date_of_death);
	copy_field_value( p_source_field =>  p_rehire_reason,
			   	p_target_field =>  p_people_data.rehire_reason);

 	hr_utility.set_location('Entering:'|| l_proc, 10);

 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_people_data := l_people_data;
     raise;
end conv_to_people_rg;


Procedure conv_to_people_rg (p_people_h_v  in  ghr_people_h_v%rowtype,
                             p_people_data out nocopy per_all_people_f%rowtype) is

	l_proc		varchar2(30):='Conv_to_people_rg';
	l_people_data	per_all_people_f%rowtype;

Begin
	hr_utility.set_location('Entering : ' || l_proc, 100);

	Conv_to_people_rg(
                       p_person_id                       => p_people_h_v.person_id                          ,
                       p_effective_start_date            => p_people_h_v.effective_start_date               ,
                       p_effective_end_date              => p_people_h_v.effective_end_date                 ,
                       p_business_group_id               => p_people_h_v.business_group_id                  ,
                       p_person_type_id                  => p_people_h_v.person_type_id                     ,
                       p_last_name                       => p_people_h_v.last_name                          ,
                       p_start_date                      => p_people_h_v.start_date                         ,
                       p_applicant_number                => p_people_h_v.applicant_number                   ,
                       p_background_check_status         => p_people_h_v.background_check_status            ,
                       p_background_date_check           => p_people_h_v.background_date_check              ,
                       p_blood_type                      => p_people_h_v.blood_type                         ,
                       p_comment_id                      => p_people_h_v.comment_id                         ,
                       p_correspondence_language         => p_people_h_v.correspondence_language            ,
                       p_current_applicant_flag          => p_people_h_v.current_applicant_flag             ,
                       p_current_emp_or_apl_flag         => p_people_h_v.current_emp_or_apl_flag            ,
                       p_current_employee_flag           => p_people_h_v.current_employee_flag              ,
                       p_date_employee_data_verified     => p_people_h_v.date_employee_data_verified        ,
                       p_date_of_birth                   => p_people_h_v.date_of_birth                      ,
                       p_email_address                   => p_people_h_v.email_address                      ,
                       p_employee_number                 => p_people_h_v.employee_number                    ,
                       p_expense_check_send_to_add       => p_people_h_v.expense_check_send_to_address      ,
                       p_fast_path_employee              => p_people_h_v.fast_path_employee                 ,
                       p_first_name                      => p_people_h_v.first_name                         ,
                       p_fte_capacity                    => p_people_h_v.fte_capacity                       ,
                       p_full_name                       => p_people_h_v.full_name                          ,
                       p_hold_applicant_date_until       => p_people_h_v.hold_applicant_date_until          ,
                       p_honors                          => p_people_h_v.honors                             ,
                       p_internal_location               => p_people_h_v.internal_location                  ,
                       p_known_as                        => p_people_h_v.known_as                           ,
                       p_last_medical_test_by            => p_people_h_v.last_medical_test_by               ,
                       p_last_medical_test_date          => p_people_h_v.last_medical_test_date             ,
                       p_mailstop                        => p_people_h_v.mailstop                           ,
                       p_marital_status                  => p_people_h_v.marital_status                     ,
                       p_middle_names                    => p_people_h_v.middle_names                       ,
                       p_nationality                     => p_people_h_v.nationality                        ,
                       p_national_identifier             => p_people_h_v.national_identifier                ,
                       p_office_number                   => p_people_h_v.office_number                      ,
                       p_on_military_service             => p_people_h_v.on_military_service                ,
                       p_order_name                      => p_people_h_v.order_name                         ,
                       p_pre_name_adjunct                => p_people_h_v.pre_name_adjunct                   ,
                       p_previous_last_name              => p_people_h_v.previous_last_name                 ,
                       p_projected_start_date            => p_people_h_v.projected_start_date               ,
                       p_rehire_authorizor               => p_people_h_v.rehire_authorizor                  ,
                       p_rehire_recommendation           => p_people_h_v.rehire_recommendation              ,
                       p_resume_exists                   => p_people_h_v.resume_exists                      ,
                       p_resume_last_updated             => p_people_h_v.resume_last_updated                ,
                       p_registered_disabled_flag        => p_people_h_v.registered_disabled_flag           ,
                       p_second_passport_exists          => p_people_h_v.second_passport_exists             ,
                       p_sex                             => p_people_h_v.sex                                ,
                       p_student_status                  => p_people_h_v.student_status                     ,
                       p_suffix                          => p_people_h_v.suffix                             ,
                       p_title                           => p_people_h_v.title                              ,
                       p_vendor_id                       => p_people_h_v.vendor_id                          ,
                       p_work_schedule                   => p_people_h_v.work_schedule                      ,
                       p_work_telephone                  => p_people_h_v.work_telephone                     ,
                       p_request_id                      => p_people_h_v.request_id                         ,
                       p_program_application_id          => p_people_h_v.program_application_id             ,
                       p_program_id                      => p_people_h_v.program_id                         ,
                       p_program_update_date             => p_people_h_v.program_update_date                ,
                       p_attribute_category              => p_people_h_v.attribute_category                 ,
                       p_attribute1                      => p_people_h_v.attribute1                         ,
                       p_attribute2                      => p_people_h_v.attribute2                         ,
                       p_attribute3                      => p_people_h_v.attribute3                         ,
                       p_attribute4                      => p_people_h_v.attribute4                         ,
                       p_attribute5                      => p_people_h_v.attribute5                         ,
                       p_attribute6                      => p_people_h_v.attribute6                         ,
                       p_attribute7                      => p_people_h_v.attribute7                         ,
                       p_attribute8                      => p_people_h_v.attribute8                         ,
                       p_attribute9                      => p_people_h_v.attribute9                         ,
                       p_attribute10                     => p_people_h_v.attribute10                        ,
                       p_attribute11                     => p_people_h_v.attribute11                        ,
                       p_attribute12                     => p_people_h_v.attribute12                        ,
                       p_attribute13                     => p_people_h_v.attribute13                        ,
                       p_attribute14                     => p_people_h_v.attribute14                        ,
                       p_attribute15                     => p_people_h_v.attribute15                        ,
                       p_attribute16                     => p_people_h_v.attribute16                        ,
                       p_attribute17                     => p_people_h_v.attribute17                        ,
                       p_attribute18                     => p_people_h_v.attribute18                        ,
                       p_attribute19                     => p_people_h_v.attribute19                        ,
                       p_attribute20                     => p_people_h_v.attribute20                        ,
                       p_attribute21                     => p_people_h_v.attribute21                        ,
                       p_attribute22                     => p_people_h_v.attribute22                        ,
                       p_attribute23                     => p_people_h_v.attribute23                        ,
                       p_attribute24                     => p_people_h_v.attribute24                        ,
                       p_attribute25                     => p_people_h_v.attribute25                        ,
                       p_attribute26                     => p_people_h_v.attribute26                        ,
                       p_attribute27                     => p_people_h_v.attribute27                        ,
                       p_attribute28                     => p_people_h_v.attribute28                        ,
                       p_attribute29                     => p_people_h_v.attribute29                        ,
                       p_attribute30                     => p_people_h_v.attribute30                        ,
                       p_per_information_category        => p_people_h_v.per_information_category           ,
                       p_per_information1                => p_people_h_v.per_information1                   ,
                       p_per_information2                => p_people_h_v.per_information2                   ,
                       p_per_information3                => p_people_h_v.per_information3                   ,
                       p_per_information4                => p_people_h_v.per_information4                   ,
                       p_per_information5                => p_people_h_v.per_information5                   ,
                       p_per_information6                => p_people_h_v.per_information6                   ,
                       p_per_information7                => p_people_h_v.per_information7                   ,
                       p_per_information8                => p_people_h_v.per_information8                   ,
                       p_per_information9                => p_people_h_v.per_information9                   ,
                       p_per_information10               => p_people_h_v.per_information10                  ,
                       p_per_information11               => p_people_h_v.per_information11                  ,
                       p_per_information12               => p_people_h_v.per_information12                  ,
                       p_per_information13               => p_people_h_v.per_information13                  ,
                       p_per_information14               => p_people_h_v.per_information14                  ,
                       p_per_information15               => p_people_h_v.per_information15                  ,
                       p_per_information16               => p_people_h_v.per_information16                  ,
                       p_per_information17               => p_people_h_v.per_information17                  ,
                       p_per_information18               => p_people_h_v.per_information18                  ,
                       p_per_information19               => p_people_h_v.per_information19                  ,
                       p_per_information20               => p_people_h_v.per_information20                  ,
                       p_per_information21               => p_people_h_v.per_information21                  ,
                       p_per_information22               => p_people_h_v.per_information22                  ,
                       p_per_information23               => p_people_h_v.per_information23                  ,
                       p_per_information24               => p_people_h_v.per_information24                  ,
                       p_per_information25               => p_people_h_v.per_information25                  ,
                       p_per_information26               => p_people_h_v.per_information26                  ,
                       p_per_information27               => p_people_h_v.per_information27                  ,
                       p_per_information28               => p_people_h_v.per_information28                  ,
                       p_per_information29               => p_people_h_v.per_information29                  ,
                       p_per_information30               => p_people_h_v.per_information30                  ,
--                       p_object_version_number           => p_people_h_v.object_version_number              ,
                       p_date_of_death                   => p_people_h_v.date_of_death                      ,
                       p_rehire_reason                   => p_people_h_v.rehire_reason                      ,
                       p_people_data                     => l_people_data);

	p_people_data := l_people_data;
	hr_utility.set_location('Leaving : ' || l_proc, 200);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_people_data := NULL;
     raise;

End Conv_to_people_rg;


-- procedure conv_people_rg_to_hist_rg converts the  per_people_f record type to
-- ghr_pa_history record type

Procedure conv_people_rg_to_hist_rg(
	p_people_data        in  per_all_people_f%rowtype,
	p_history_data   in out nocopy  ghr_pa_history%rowtype) as

	l_proc	 varchar2(30) := 'conv_people_rg_to_hist_rg';
	l_history_data  ghr_pa_history%rowtype;

begin
        l_history_data := p_history_data; --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);
	p_history_data.person_id        := p_people_data.person_id;
	p_history_data.information1	  := p_people_data.person_id	;
	p_history_data.information2	  := to_char(p_people_data.effective_start_date, g_hist_date_format)	;
	p_history_data.information3	  := to_char(p_people_data.effective_end_date, g_hist_date_format)	;
	p_history_data.information4	  := to_char(p_people_data.date_of_death,g_hist_date_format)	;
	p_history_data.information5	  := p_people_data.person_type_id	;
	p_history_data.information6	  := p_people_data.last_name	;
	p_history_data.information7	  := to_char(p_people_data.start_date, g_hist_date_format)	;
	p_history_data.information8	  := p_people_data.applicant_number	;
	p_history_data.information9	  := p_people_data.background_check_status	;
	p_history_data.information10	  := to_char(p_people_data.background_date_check, g_hist_date_format)	;
	p_history_data.information11	  := p_people_data.blood_type	;
	p_history_data.information12	  := p_people_data.comment_id	;
	p_history_data.information13	  := p_people_data.correspondence_language	;
	p_history_data.information14	  := p_people_data.current_applicant_flag	;
	p_history_data.information15	  := p_people_data.current_emp_or_apl_flag	;
	p_history_data.information16	  := p_people_data.current_employee_flag	;
	p_history_data.information17	  := to_char(p_people_data.date_employee_data_verified, g_hist_date_format)	;
	p_history_data.information18	  := to_char(p_people_data.date_of_birth, g_hist_date_format)	;
	p_history_data.information19	  := p_people_data.email_address	;
	p_history_data.information20	  := p_people_data.employee_number	;
	p_history_data.information21	  := p_people_data.expense_check_send_to_address	;
	p_history_data.information22	  := p_people_data.fast_path_employee	;
	p_history_data.information23	  := p_people_data.first_name	;
	p_history_data.information24	  := p_people_data.fte_capacity	;
	p_history_data.information25	  := p_people_data.full_name	;
	p_history_data.information26	  := to_char(p_people_data.hold_applicant_date_until, g_hist_date_format)	;
	p_history_data.information27	  := p_people_data.honors	;
	p_history_data.information28	  := p_people_data.internal_location	;
	p_history_data.information29	  := p_people_data.known_as	;
	p_history_data.information30	  := p_people_data.last_medical_test_by	;
	p_history_data.information31	  := to_char(p_people_data.last_medical_test_date, g_hist_date_format)	;
	p_history_data.information32	  := p_people_data.mailstop	;
	p_history_data.information33	  := p_people_data.marital_status	;
	p_history_data.information34	  := p_people_data.middle_names	;
	p_history_data.information35	  := p_people_data.nationality	;
	p_history_data.information36	  := p_people_data.national_identifier	;
	p_history_data.information37	  := p_people_data.office_number	;
	p_history_data.information38	  := p_people_data.on_military_service	;
	p_history_data.information39	  := p_people_data.order_name	;
	p_history_data.information40	  := p_people_data.pre_name_adjunct	;
	p_history_data.information41	  := p_people_data.previous_last_name	;
	p_history_data.information42	  := to_char(p_people_data.projected_start_date, g_hist_date_format)	;
	p_history_data.information43	  := p_people_data.rehire_authorizor	;
	p_history_data.information44	  := p_people_data.rehire_recommendation	;
	p_history_data.information45	  := p_people_data.resume_exists	;
	p_history_data.information46	  := to_char(p_people_data.resume_last_updated, g_hist_date_format)	;
	p_history_data.information47	  := p_people_data.registered_disabled_flag	;
	p_history_data.information48	  := p_people_data.second_passport_exists	;
	p_history_data.information49	  := p_people_data.sex	;
	p_history_data.information50	  := p_people_data.student_status	;
	p_history_data.information51	  := p_people_data.suffix	;
	p_history_data.information52	  := p_people_data.title	;
	p_history_data.information53	  := p_people_data.vendor_id	;
	p_history_data.information54	  := p_people_data.work_schedule	;
	p_history_data.information55	  := p_people_data.work_telephone	;
	p_history_data.information56	  := p_people_data.per_information_category	;
	p_history_data.information57	  := p_people_data.per_information1	;
	p_history_data.information58	  := p_people_data.per_information2	;
	p_history_data.information59	  := p_people_data.per_information3	;
	p_history_data.information60	  := p_people_data.per_information4	;
	p_history_data.information61	  := p_people_data.per_information5	;
	p_history_data.information62	  := p_people_data.per_information6	;
	p_history_data.information63	  := p_people_data.per_information7	;
	p_history_data.information64	  := p_people_data.per_information8	;
	p_history_data.information65	  := p_people_data.per_information9	;
	p_history_data.information66	  := p_people_data.per_information10	;
	p_history_data.information67	  := p_people_data.per_information11	;
	p_history_data.information68	  := p_people_data.per_information12	;
	p_history_data.information69	  := p_people_data.per_information13	;
	p_history_data.information70	  := p_people_data.per_information14	;
	p_history_data.information71	  := p_people_data.per_information15	;
	p_history_data.information72	  := p_people_data.per_information16	;
	p_history_data.information73	  := p_people_data.per_information17	;
	p_history_data.information74	  := p_people_data.per_information18	;
	p_history_data.information75	  := p_people_data.per_information19	;
	p_history_data.information76	  := p_people_data.per_information20	;
	p_history_data.information77	  := p_people_data.per_information21	;
	p_history_data.information78	  := p_people_data.per_information22	;
	p_history_data.information79	  := p_people_data.per_information23	;
	p_history_data.information80	  := p_people_data.per_information24	;
	p_history_data.information81	  := p_people_data.per_information25	;
	p_history_data.information82	  := p_people_data.per_information26	;
	p_history_data.information83	  := p_people_data.per_information27	;
	p_history_data.information84	  := p_people_data.per_information28	;
	p_history_data.information85	  := p_people_data.per_information29	;
	p_history_data.information86	  := p_people_data.per_information30	;
	p_history_data.information87	  := p_people_data.rehire_reason	;
	p_history_data.information121	  := p_people_data.request_id	;
	p_history_data.information122	  := p_people_data.program_application_id	;
	p_history_data.information123	  := p_people_data.program_id	;
	p_history_data.information124	  := to_char(p_people_data.program_update_date, g_hist_date_format)	;
	p_history_data.information125	  := p_people_data.attribute_category	;
	p_history_data.information126	  := p_people_data.attribute1	;
	p_history_data.information127	  := p_people_data.attribute2	;
	p_history_data.information128	  := p_people_data.attribute3	;
	p_history_data.information129	  := p_people_data.attribute4	;
	p_history_data.information130	  := p_people_data.attribute5	;
	p_history_data.information131	  := p_people_data.attribute6	;
	p_history_data.information132	  := p_people_data.attribute7	;
	p_history_data.information133	  := p_people_data.attribute8	;
	p_history_data.information134	  := p_people_data.attribute9	;
	p_history_data.information135	  := p_people_data.attribute10	;
	p_history_data.information136	  := p_people_data.attribute11	;
	p_history_data.information137	  := p_people_data.attribute12	;
	p_history_data.information138	  := p_people_data.attribute13	;
	p_history_data.information139	  := p_people_data.attribute14	;
	p_history_data.information140	  := p_people_data.attribute15	;
	p_history_data.information141	  := p_people_data.attribute16	;
	p_history_data.information142	  := p_people_data.attribute17	;
	p_history_data.information143	  := p_people_data.attribute18	;
	p_history_data.information144	  := p_people_data.attribute19	;
	p_history_data.information145	  := p_people_data.attribute20	;
	p_history_data.information146	  := p_people_data.attribute21	;
	p_history_data.information147	  := p_people_data.attribute22	;
	p_history_data.information148	  := p_people_data.attribute23	;
	p_history_data.information149	  := p_people_data.attribute24	;
	p_history_data.information150	  := p_people_data.attribute25	;
	p_history_data.information151	  := p_people_data.attribute26	;
	p_history_data.information152	  := p_people_data.attribute27	;
	p_history_data.information153	  := p_people_data.attribute28	;
	p_history_data.information154	  := p_people_data.attribute29	;
	p_history_data.information155	  := p_people_data.attribute30	;
--	p_history_data.information161	  := p_people_data.object_version_number	;
	p_history_data.information162	  := p_people_data.business_group_id	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_history_data := l_history_data;
     raise;

end conv_people_rg_to_hist_rg;


-- procedure conv_hist_rg_to_people_rg converts the  ghr_pa_history record type
-- to per_people_rg

Procedure conv_to_people_rg(
	p_history_data   	   in  ghr_pa_history%rowtype,
	p_people_data    in out	nocopy per_all_people_f%rowtype)  as

	l_proc	 varchar2(30) := 'conv_hist_rg_to_people_rg';
	l_people_data    per_all_people_f%rowtype;

begin

        l_people_data  :=p_people_data; --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);
	p_people_data.person_id			 	:= p_history_data.person_id;
	p_people_data.person_id			 	:= p_history_data.information1	;
	p_people_data.effective_start_date	 	:= to_date(p_history_data.information2, g_hist_date_format)	;
	p_people_data.effective_end_date	 	:= to_date(p_history_data.information3, g_hist_date_format)	;
	p_people_data.date_of_death	 	 	:= to_date(p_history_data.information4, g_hist_date_format)	;
	p_people_data.person_type_id 		 	:= p_history_data.information5	;
	p_people_data.last_name	  			:= p_history_data.information6	;
	p_people_data.start_date	  		:= to_date(p_history_data.information7, g_hist_date_format)	;
	p_people_data.applicant_number	  	:= p_history_data.information8;
	p_people_data.background_check_status	:= p_history_data.information9;
	p_people_data.background_date_check	  	:= to_date(p_history_data.information10, g_hist_date_format)	;
	p_people_data.blood_type	  		:= p_history_data.information11;
	p_people_data.comment_id	  		:= p_history_data.information12;
	p_people_data.correspondence_language	:= p_history_data.information13;
	p_people_data.current_applicant_flag	:= p_history_data.information14;
	p_people_data.current_emp_or_apl_flag	:= p_history_data.information15;
	p_people_data.current_employee_flag	  	:= p_history_data.information16	;
	p_people_data.date_employee_data_verified	:= to_date(p_history_data.information17, g_hist_date_format)	;
	p_people_data.date_of_birth	  		:= to_date(p_history_data.information18, g_hist_date_format)	;
	p_people_data.email_address	  		:= p_history_data.information19	;
	p_people_data.employee_number	  		:= p_history_data.information20	;
	p_people_data.expense_check_send_to_address	  := p_history_data.information21;
	p_people_data.fast_path_employee	  	:= p_history_data.information22;
	p_people_data.first_name	  		:= p_history_data.information23;
	p_people_data.fte_capacity	  		:= p_history_data.information24;
	p_people_data.full_name	  			:= p_history_data.information25	;
	p_people_data.hold_applicant_date_until  := to_date(p_history_data.information26, g_hist_date_format)	;
	p_people_data.honors				:= p_history_data.information27	;
	p_people_data.internal_location	  	:= p_history_data.information28	;
	p_people_data.known_as	  			:= p_history_data.information29	;
	p_people_data.last_medical_test_by	  	:= p_history_data.information30	;
	p_people_data.last_medical_test_date	:= to_date(p_history_data.information31, g_hist_date_format)	;
	p_people_data.mailstop	  			:= p_history_data.information32	;
	p_people_data.marital_status	  		:= p_history_data.information33	;
	p_people_data.middle_names	  		:= p_history_data.information34	;
	p_people_data.nationality	  		:= p_history_data.information35	;
	p_people_data.national_identifier		:= p_history_data.information36	;
	p_people_data.office_number			:= p_history_data.information37	;
	p_people_data.on_military_service		:= p_history_data.information38	;
	p_people_data.order_name			:= p_history_data.information39	;
	p_people_data.pre_name_adjunct		:= p_history_data.information40	;
	p_people_data.previous_last_name		:= p_history_data.information41	;
	p_people_data.projected_start_date	  	:= to_date(p_history_data.information42, g_hist_date_format)	;
	p_people_data.rehire_authorizor		:= p_history_data.information43	;
	p_people_data.rehire_recommendation		:= p_history_data.information44	;
	p_people_data.resume_exists			:= p_history_data.information45	;
	p_people_data.resume_last_updated		:= to_date(p_history_data.information46, g_hist_date_format)	;
	p_people_data.registered_disabled_flag	:= p_history_data.information47;
	p_people_data.second_passport_exists	:= p_history_data.information48;
	p_people_data.sex					:= p_history_data.information49;
	p_people_data.student_status			:= p_history_data.information50;
	p_people_data.suffix	  			:= p_history_data.information51	;
	p_people_data.title	  			:= p_history_data.information52	;
	p_people_data.vendor_id	  			:= p_history_data.information53	;
	p_people_data.work_schedule	  		:= p_history_data.information54	;
	p_people_data.work_telephone	  		:= p_history_data.information55	;
	p_people_data.per_information_category	:= p_history_data.information56	;
	p_people_data.per_information1		:= p_history_data.information57	;
	p_people_data.per_information2	 	:= p_history_data.information58	;
	p_people_data.per_information3	  	:= p_history_data.information59	;
	p_people_data.per_information4	  	:= p_history_data.information60	;
	p_people_data.per_information5	  	:= p_history_data.information61	;
	p_people_data.per_information6	  	:= p_history_data.information62	;
	p_people_data.per_information7	  	:= p_history_data.information63	;
	p_people_data.per_information8	  	:= p_history_data.information64	;
	p_people_data.per_information9	  	:= p_history_data.information65	;
	p_people_data.per_information10	  	:= p_history_data.information66	;
	p_people_data.per_information11	  	:= p_history_data.information67	;
	p_people_data.per_information12	  	:= p_history_data.information68	;
	p_people_data.per_information13	  	:= p_history_data.information69	;
	p_people_data.per_information14	  	:= p_history_data.information70	;
	p_people_data.per_information15	  	:= p_history_data.information71	;
	p_people_data.per_information16	  	:= p_history_data.information72	;
	p_people_data.per_information17	  	:= p_history_data.information73	;
	p_people_data.per_information18	  	:= p_history_data.information74	;
	p_people_data.per_information19	  	:= p_history_data.information75	;
	p_people_data.per_information20	  	:= p_history_data.information76	;
	p_people_data.per_information21	  	:= p_history_data.information77	;
	p_people_data.per_information22	  	:= p_history_data.information78	;
	p_people_data.per_information23	  	:= p_history_data.information79	;
	p_people_data.per_information24	  	:= p_history_data.information80	;
	p_people_data.per_information25	  	:= p_history_data.information81	;
	p_people_data.per_information26	  	:= p_history_data.information82	;
	p_people_data.per_information27	  	:= p_history_data.information83	;
	p_people_data.per_information28	  	:= p_history_data.information84	;
	p_people_data.per_information29	  	:= p_history_data.information85	;
	p_people_data.per_information30	  	:= p_history_data.information86	;
	p_people_data.rehire_reason	  	  	:= p_history_data.information87	;
	p_people_data.request_id	  	  	:= p_history_data.information121	;
	p_people_data.program_application_id  	:= p_history_data.information122	;
	p_people_data.program_id	  	  	:= p_history_data.information123	;
	p_people_data.program_update_date	  	:= to_date(p_history_data.information124, g_hist_date_format)	;
	p_people_data.attribute_category	  	:= p_history_data.information125	;
	p_people_data.attribute1	  		:= p_history_data.information126	;
	p_people_data.attribute2	  		:= p_history_data.information127	;
	p_people_data.attribute3	  		:= p_history_data.information128	;
	p_people_data.attribute4	  		:= p_history_data.information129	;
	p_people_data.attribute5	  		:= p_history_data.information130	;
	p_people_data.attribute6	  		:= p_history_data.information131	;
	p_people_data.attribute7	  		:= p_history_data.information132	;
	p_people_data.attribute8	  		:= p_history_data.information133	;
	p_people_data.attribute9	  		:= p_history_data.information134	;
	p_people_data.attribute10	  		:= p_history_data.information135	;
	p_people_data.attribute11	  		:= p_history_data.information136	;
	p_people_data.attribute12	  		:= p_history_data.information137	;
	p_people_data.attribute13	  		:= p_history_data.information138	;
	p_people_data.attribute14	  		:= p_history_data.information139	;
	p_people_data.attribute15	  		:= p_history_data.information140	;
	p_people_data.attribute16	  		:= p_history_data.information141	;
	p_people_data.attribute17	  		:= p_history_data.information142	;
	p_people_data.attribute18	  		:= p_history_data.information143	;
	p_people_data.attribute19	  		:= p_history_data.information144	;
	p_people_data.attribute20	  		:= p_history_data.information145	;
	p_people_data.attribute21	  		:= p_history_data.information146	;
	p_people_data.attribute22	  		:= p_history_data.information147	;
	p_people_data.attribute23	  		:= p_history_data.information148	;
	p_people_data.attribute24	  		:= p_history_data.information149	;
	p_people_data.attribute25	  		:= p_history_data.information150	;
	p_people_data.attribute26	  		:= p_history_data.information151	;
	p_people_data.attribute27	  		:= p_history_data.information152	;
	p_people_data.attribute28	  		:= p_history_data.information153	;
	p_people_data.attribute29	  		:= p_history_data.information154	;
	p_people_data.attribute30	  		:= p_history_data.information155	;
--	p_people_data.object_version_number		:= p_history_data.information161	;
	p_people_data.business_group_id 		:= p_history_data.information162	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_people_data := l_people_data;
     raise;

end conv_to_people_rg;




Procedure conv_to_asgnei_rg( p_asgnei_h_v	    in   ghr_assignment_extra_info_h_v%rowtype,
                             p_asgnei_data   out nocopy  per_assignment_extra_info%rowtype) is

	l_proc		varchar(30):='conv_to_asgnei_rg';
	l_asgnei_data	per_assignment_extra_info%rowtype;

Begin
	hr_utility.set_location('Entering : ' || l_proc, 100);

	Conv_to_asgnei_rg(
                       p_assignment_extra_info_id        => p_asgnei_h_v.assignment_extra_info_id          ,
                       p_assignment_id                   => p_asgnei_h_v.assignment_id                     ,
                       p_information_type                => p_asgnei_h_v.information_type                  ,
                       p_request_id                      => p_asgnei_h_v.request_id                        ,
                       p_program_application_id          => p_asgnei_h_v.program_application_id            ,
                       p_program_id                      => p_asgnei_h_v.program_id                        ,
                       p_program_update_date             => p_asgnei_h_v.program_update_date               ,
                       p_aei_attribute_category          => p_asgnei_h_v.aei_attribute_category            ,
                       p_aei_attribute1                  => p_asgnei_h_v.aei_attribute1                    ,
                       p_aei_attribute2                  => p_asgnei_h_v.aei_attribute2                    ,
                       p_aei_attribute3                  => p_asgnei_h_v.aei_attribute3                    ,
                       p_aei_attribute4                  => p_asgnei_h_v.aei_attribute4                    ,
                       p_aei_attribute5                  => p_asgnei_h_v.aei_attribute5                    ,
                       p_aei_attribute6                  => p_asgnei_h_v.aei_attribute6                    ,
                       p_aei_attribute7                  => p_asgnei_h_v.aei_attribute7                    ,
                       p_aei_attribute8                  => p_asgnei_h_v.aei_attribute8                    ,
                       p_aei_attribute9                  => p_asgnei_h_v.aei_attribute9                    ,
                       p_aei_attribute10                 => p_asgnei_h_v.aei_attribute10                   ,
                       p_aei_attribute11                 => p_asgnei_h_v.aei_attribute11                   ,
                       p_aei_attribute12                 => p_asgnei_h_v.aei_attribute12                   ,
                       p_aei_attribute13                 => p_asgnei_h_v.aei_attribute13                   ,
                       p_aei_attribute14                 => p_asgnei_h_v.aei_attribute14                   ,
                       p_aei_attribute15                 => p_asgnei_h_v.aei_attribute15                   ,
                       p_aei_attribute16                 => p_asgnei_h_v.aei_attribute16                   ,
                       p_aei_attribute17                 => p_asgnei_h_v.aei_attribute17                   ,
                       p_aei_attribute18                 => p_asgnei_h_v.aei_attribute18                   ,
                       p_aei_attribute19                 => p_asgnei_h_v.aei_attribute19                   ,
                       p_aei_attribute20                 => p_asgnei_h_v.aei_attribute20                   ,
                       p_aei_information_category        => p_asgnei_h_v.aei_information_category          ,
                       p_aei_information1                => p_asgnei_h_v.aei_information1                  ,
                       p_aei_information2                => p_asgnei_h_v.aei_information2                  ,
                       p_aei_information3                => p_asgnei_h_v.aei_information3                  ,
                       p_aei_information4                => p_asgnei_h_v.aei_information4                  ,
                       p_aei_information5                => p_asgnei_h_v.aei_information5                  ,
                       p_aei_information6                => p_asgnei_h_v.aei_information6                  ,
                       p_aei_information7                => p_asgnei_h_v.aei_information7                  ,
                       p_aei_information8                => p_asgnei_h_v.aei_information8                  ,
                       p_aei_information9                => p_asgnei_h_v.aei_information9                  ,
                       p_aei_information10               => p_asgnei_h_v.aei_information10                 ,
                       p_aei_information11               => p_asgnei_h_v.aei_information11                 ,
                       p_aei_information12               => p_asgnei_h_v.aei_information12                 ,
                       p_aei_information13               => p_asgnei_h_v.aei_information13                 ,
                       p_aei_information14               => p_asgnei_h_v.aei_information14                 ,
                       p_aei_information15               => p_asgnei_h_v.aei_information15                 ,
                       p_aei_information16               => p_asgnei_h_v.aei_information16                 ,
                       p_aei_information17               => p_asgnei_h_v.aei_information17                 ,
                       p_aei_information18               => p_asgnei_h_v.aei_information18                 ,
                       p_aei_information19               => p_asgnei_h_v.aei_information19                 ,
                       p_aei_information20               => p_asgnei_h_v.aei_information20                 ,
                       p_aei_information21               => p_asgnei_h_v.aei_information21                 ,
                       p_aei_information22               => p_asgnei_h_v.aei_information22                 ,
                       p_aei_information23               => p_asgnei_h_v.aei_information23                 ,
                       p_aei_information24               => p_asgnei_h_v.aei_information24                 ,
                       p_aei_information25               => p_asgnei_h_v.aei_information25                 ,
                       p_aei_information26               => p_asgnei_h_v.aei_information26                 ,
                       p_aei_information27               => p_asgnei_h_v.aei_information27                 ,
                       p_aei_information28               => p_asgnei_h_v.aei_information28                 ,
                       p_aei_information29               => p_asgnei_h_v.aei_information29                 ,
                       p_aei_information30               => p_asgnei_h_v.aei_information30                 ,
--                       p_object_version_number           => p_asgnei_h_v.object_version_number             ,
                       p_asgnei_data                     => l_asgnei_data);
	p_asgnei_data := l_asgnei_data;

	hr_utility.set_location('Leaving : ' || l_proc, 200);

 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_asgnei_data :=NULL;
     raise;

End conv_to_asgnei_rg;




-- Procedute conv_to_assign_ei_rg copies the indivisual fields supplied as parameters
-- to the per_assgn_ei type record.

Procedure conv_to_asgnei_rg(
	p_assignment_extra_info_id	in 	per_assignment_extra_info.assignment_extra_info_id%type	default NULL,
	p_assignment_id			in	per_assignment_extra_info.assignment_id%type 			default NULL,
	p_information_type		in	per_assignment_extra_info.information_type%type 		default NULL,
	p_aei_information_category	in	per_assignment_extra_info.aei_information_category%type 	default NULL,
	p_aei_information1		in	per_assignment_extra_info.aei_information1%type 		default NULL,
	p_aei_information2		in	per_assignment_extra_info.aei_information2%type 		default NULL,
	p_aei_information3		in	per_assignment_extra_info.aei_information3%type 		default NULL,
	p_aei_information4		in	per_assignment_extra_info.aei_information4%type 		default NULL,
	p_aei_information5		in	per_assignment_extra_info.aei_information5%type 		default NULL,
	p_aei_information6		in	per_assignment_extra_info.aei_information6%type 		default NULL,
	p_aei_information7		in	per_assignment_extra_info.aei_information7%type 		default NULL,
	p_aei_information8		in	per_assignment_extra_info.aei_information8%type 		default NULL,
	p_aei_information9		in	per_assignment_extra_info.aei_information9%type 		default NULL,
	p_aei_information10		in	per_assignment_extra_info.aei_information10%type 		default NULL,
	p_aei_information11		in	per_assignment_extra_info.aei_information11%type 		default NULL,
	p_aei_information12		in	per_assignment_extra_info.aei_information12%type 		default NULL,
	p_aei_information13		in	per_assignment_extra_info.aei_information13%type 		default NULL,
	p_aei_information14		in	per_assignment_extra_info.aei_information14%type 		default NULL,
	p_aei_information15		in	per_assignment_extra_info.aei_information15%type 		default NULL,
	p_aei_information16		in	per_assignment_extra_info.aei_information16%type 		default NULL,
	p_aei_information17		in	per_assignment_extra_info.aei_information17%type 		default NULL,
	p_aei_information18		in	per_assignment_extra_info.aei_information18%type 		default NULL,
	p_aei_information19		in	per_assignment_extra_info.aei_information19%type 		default NULL,
	p_aei_information20		in	per_assignment_extra_info.aei_information20%type 		default NULL,
	p_aei_information21		in	per_assignment_extra_info.aei_information21%type 		default NULL,
	p_aei_information22		in	per_assignment_extra_info.aei_information22%type 		default NULL,
	p_aei_information23		in	per_assignment_extra_info.aei_information23%type 		default NULL,
	p_aei_information24		in	per_assignment_extra_info.aei_information24%type 		default NULL,
	p_aei_information25		in	per_assignment_extra_info.aei_information25%type 		default NULL,
	p_aei_information26		in	per_assignment_extra_info.aei_information26%type 		default NULL,
	p_aei_information27		in	per_assignment_extra_info.aei_information27%type 		default NULL,
	p_aei_information28		in	per_assignment_extra_info.aei_information28%type 		default NULL,
	p_aei_information29		in	per_assignment_extra_info.aei_information29%type 		default NULL,
	p_aei_information30		in	per_assignment_extra_info.aei_information30%type 		default NULL,
	p_request_id			in	per_assignment_extra_info.request_id%type 			default NULL,
	p_program_application_id	in	per_assignment_extra_info.program_application_id%type 	default NULL,
	p_program_id			in	per_assignment_extra_info.program_id%type 			default NULL,
	p_program_update_date		in	per_assignment_extra_info.program_update_date%type 		default NULL,
	p_aei_attribute_category	in	per_assignment_extra_info.aei_attribute_category%type 	default NULL,
	p_aei_attribute1			in	per_assignment_extra_info.aei_attribute1%type 			default NULL,
	p_aei_attribute2			in	per_assignment_extra_info.aei_attribute2%type 			default NULL,
	p_aei_attribute3			in	per_assignment_extra_info.aei_attribute3%type 			default NULL,
	p_aei_attribute4			in	per_assignment_extra_info.aei_attribute4%type 			default NULL,
	p_aei_attribute5			in	per_assignment_extra_info.aei_attribute5%type 			default NULL,
	p_aei_attribute6			in	per_assignment_extra_info.aei_attribute6%type 			default NULL,
	p_aei_attribute7			in	per_assignment_extra_info.aei_attribute7%type 			default NULL,
	p_aei_attribute8			in	per_assignment_extra_info.aei_attribute8%type 			default NULL,
	p_aei_attribute9			in	per_assignment_extra_info.aei_attribute9%type 			default NULL,
	p_aei_attribute10			in	per_assignment_extra_info.aei_attribute10%type 			default NULL,
	p_aei_attribute11			in	per_assignment_extra_info.aei_attribute11%type 			default NULL,
	p_aei_attribute12			in	per_assignment_extra_info.aei_attribute12%type 			default NULL,
	p_aei_attribute13			in	per_assignment_extra_info.aei_attribute13%type 			default NULL,
	p_aei_attribute14			in	per_assignment_extra_info.aei_attribute14%type 			default NULL,
	p_aei_attribute15			in	per_assignment_extra_info.aei_attribute15%type 			default NULL,
	p_aei_attribute16			in	per_assignment_extra_info.aei_attribute16%type 			default NULL,
	p_aei_attribute17			in	per_assignment_extra_info.aei_attribute17%type 			default NULL,
	p_aei_attribute18			in	per_assignment_extra_info.aei_attribute18%type 			default NULL,
	p_aei_attribute19			in	per_assignment_extra_info.aei_attribute19%type 			default NULL,
	p_aei_attribute20			in	per_assignment_extra_info.aei_attribute20	%type 		default NULL,
--	p_object_version_number		in	per_assignment_extra_info.object_version_number%type 		default NULL,
	p_asgnei_data	  	  in out nocopy	per_assignment_extra_info%rowtype 								 )  is

	l_proc	varchar2(30):='conv_to_asgnei_rg';
        l_asgnei_data	  per_assignment_extra_info%rowtype;
begin
        l_asgnei_data := p_asgnei_data;--NOCOPY CHANGES

 	hr_utility.set_location('entering:'|| l_proc, 5);

	copy_field_value( p_source_field => p_assignment_extra_info_id,
			   	p_target_field => p_asgnei_data.assignment_extra_info_id );
	copy_field_value( p_source_field => p_assignment_id		 ,
	 		   	p_target_field => p_asgnei_data.assignment_id);
	copy_field_value( p_source_field => p_information_type		 ,
			   	p_target_field => p_asgnei_data.information_type );
	copy_field_value( p_source_field => p_aei_information_category	 ,
			   	p_target_field => p_asgnei_data.aei_information_category );
	copy_field_value( p_source_field => p_aei_information1		 ,
			   	p_target_field => p_asgnei_data.aei_information1 );
	copy_field_value( p_source_field => p_aei_information2		 ,
			   	p_target_field => p_asgnei_data.aei_information2 );
	copy_field_value( p_source_field => p_aei_information3		 ,
				p_target_field => p_asgnei_data.aei_information3 );
	copy_field_value( p_source_field => p_aei_information4		 ,
			   	p_target_field => p_asgnei_data.aei_information4 );
	copy_field_value( p_source_field => p_aei_information5		 ,
			   	p_target_field => p_asgnei_data.aei_information5 );
	copy_field_value( p_source_field => p_aei_information6		 ,
			   	p_target_field => p_asgnei_data.aei_information6 );
	copy_field_value( p_source_field => p_aei_information7		 ,
			   	p_target_field => p_asgnei_data.aei_information7 );
	copy_field_value( p_source_field => p_aei_information8		 ,
			   	p_target_field => p_asgnei_data.aei_information8 );
	copy_field_value( p_source_field => p_aei_information9		 ,
			   	p_target_field => p_asgnei_data.aei_information9 );
	copy_field_value( p_source_field => p_aei_information10		 ,
			   	p_target_field => p_asgnei_data.aei_information10 );
	copy_field_value( p_source_field => p_aei_information11		 ,
			   	p_target_field => p_asgnei_data.aei_information11 );
	copy_field_value( p_source_field => p_aei_information12		 ,
			   	p_target_field => p_asgnei_data.aei_information12 );
	copy_field_value( p_source_field => p_aei_information13		 ,
			   	p_target_field => p_asgnei_data.aei_information13 );
	copy_field_value( p_source_field => p_aei_information14		 ,
			   	p_target_field => p_asgnei_data.aei_information14 );
	copy_field_value( p_source_field => p_aei_information15		 ,
			   	p_target_field => p_asgnei_data.aei_information15 );
	copy_field_value( p_source_field => p_aei_information16		 ,
			   	p_target_field => p_asgnei_data.aei_information16 );
	copy_field_value( p_source_field => p_aei_information17		 ,
			   	p_target_field => p_asgnei_data.aei_information17 );
	copy_field_value( p_source_field => p_aei_information18		 ,
			   	p_target_field => p_asgnei_data.aei_information18 );
	copy_field_value( p_source_field => p_aei_information19		 ,
			   	p_target_field => p_asgnei_data.aei_information19 );
	copy_field_value( p_source_field => p_aei_information20		 ,
			   	p_target_field => p_asgnei_data.aei_information20 );
	copy_field_value( p_source_field => p_aei_information21		 ,
			   	p_target_field => p_asgnei_data.aei_information21 );
	copy_field_value( p_source_field => p_aei_information22		 ,
			   	p_target_field => p_asgnei_data.aei_information22 );
	copy_field_value( p_source_field => p_aei_information23		 ,
			   	p_target_field => p_asgnei_data.aei_information23 );
	copy_field_value( p_source_field => p_aei_information24		 ,
			   	p_target_field => p_asgnei_data.aei_information24 );
	copy_field_value( p_source_field => p_aei_information25		 ,
			   	p_target_field => p_asgnei_data.aei_information25 );
	copy_field_value( p_source_field => p_aei_information26		 ,
			   	p_target_field => p_asgnei_data.aei_information26 );
	copy_field_value( p_source_field => p_aei_information27		 ,
			   	p_target_field => p_asgnei_data.aei_information27 );
	copy_field_value( p_source_field => p_aei_information28		 ,
			   	p_target_field => p_asgnei_data.aei_information28 );
	copy_field_value( p_source_field => p_aei_information29		 ,
			   	p_target_field => p_asgnei_data.aei_information29 );
	copy_field_value( p_source_field => p_aei_information30		 ,
			   	p_target_field => p_asgnei_data.aei_information30 );
	copy_field_value( p_source_field => p_request_id,
	 		 	p_target_field => p_asgnei_data.request_id );
	copy_field_value( p_source_field => p_program_application_id	 ,
			   	p_target_field => p_asgnei_data.program_application_id );
	copy_field_value( p_source_field => p_program_id,
				p_target_field => p_asgnei_data.program_id );
	copy_field_value( p_source_field => p_program_update_date		 ,
			   	p_target_field => p_asgnei_data.program_update_date );
	copy_field_value( p_source_field => p_aei_attribute_category,
			   	p_target_field => p_asgnei_data.aei_attribute_category );
	copy_field_value( p_source_field => p_aei_attribute1		 ,
			   	p_target_field => p_asgnei_data.aei_attribute1 );
	copy_field_value( p_source_field => p_aei_attribute2		 ,
			   	p_target_field => p_asgnei_data.aei_attribute2 );
	copy_field_value( p_source_field => p_aei_attribute3		 ,
			   	p_target_field => p_asgnei_data.aei_attribute3 );
	copy_field_value( p_source_field => p_aei_attribute4		 ,
			   	p_target_field => p_asgnei_data.aei_attribute4 );
	copy_field_value( p_source_field => p_aei_attribute5		 ,
			   	p_target_field => p_asgnei_data.aei_attribute5 );
	copy_field_value( p_source_field => p_aei_attribute6		 ,
			   	p_target_field => p_asgnei_data.aei_attribute6 );
	copy_field_value( p_source_field => p_aei_attribute7		 ,
			   	p_target_field => p_asgnei_data.aei_attribute7 );
	copy_field_value( p_source_field => p_aei_attribute8		 ,
			   	p_target_field => p_asgnei_data.aei_attribute8 );
	copy_field_value( p_source_field => p_aei_attribute9		 ,
			   	p_target_field => p_asgnei_data.aei_attribute9 );
	copy_field_value( p_source_field => p_aei_attribute10		 ,
			   	p_target_field => p_asgnei_data.aei_attribute10 );
	copy_field_value( p_source_field => p_aei_attribute11		 ,
			   	p_target_field => p_asgnei_data.aei_attribute11 );
	copy_field_value( p_source_field => p_aei_attribute12		 ,
			   	p_target_field => p_asgnei_data.aei_attribute12 );
	copy_field_value( p_source_field => p_aei_attribute13		 ,
			   	p_target_field => p_asgnei_data.aei_attribute13 );
	copy_field_value( p_source_field => p_aei_attribute14		 ,
			   	p_target_field => p_asgnei_data.aei_attribute14 );
	copy_field_value( p_source_field => p_aei_attribute15		 ,
			   	p_target_field => p_asgnei_data.aei_attribute15 );
	copy_field_value( p_source_field => p_aei_attribute16		 ,
			   	p_target_field => p_asgnei_data.aei_attribute16 );
	copy_field_value( p_source_field => p_aei_attribute17		 ,
			   	p_target_field => p_asgnei_data.aei_attribute17 );
	copy_field_value( p_source_field => p_aei_attribute18		 ,
			   	p_target_field => p_asgnei_data.aei_attribute18 );
	copy_field_value( p_source_field => p_aei_attribute19		 ,
			   	p_target_field => p_asgnei_data.aei_attribute19 );
	copy_field_value( p_source_field => p_aei_attribute20		 ,
			   	p_target_field => p_asgnei_data.aei_attribute20 );
--	copy_field_value( p_source_field => p_object_version_number	 ,
--			   	p_target_field => p_asgnei_data.object_version_number );
	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_asgnei_data := l_asgnei_data;
     raise;

end conv_to_asgnei_rg;


-- Procedure conv_to_assigei_rg_hist_rg converts the  per_assignment_extra_info record
-- type to ghr_pa_history record type
Procedure conv_asgnei_rg_to_hist_rg(
	p_asgnei_data        in   per_assignment_extra_info%rowtype,
	p_history_data   	in out nocopy  ghr_pa_history%rowtype) is

	l_proc	 varchar2(30) := 'conv_asgnei_rg_to_hist_rg';
	l_history_data   ghr_pa_history%rowtype;

begin

        l_history_data := p_history_data; --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);
	p_history_data.assignment_id	:= p_asgnei_data.assignment_id	;
	p_history_data.information1	:= p_asgnei_data.assignment_extra_info_id	;
	p_history_data.information4	:= p_asgnei_data.assignment_id	;
	p_history_data.information5	:= p_asgnei_data.information_type	;
	p_history_data.information6	:= p_asgnei_data.aei_information_category	;
	p_history_data.information7	:= p_asgnei_data.aei_information1	;
	p_history_data.information8	:= p_asgnei_data.aei_information2	;
	p_history_data.information9	:= p_asgnei_data.aei_information3	;
	p_history_data.information10	:= p_asgnei_data.aei_information4	;
	p_history_data.information11	:= p_asgnei_data.aei_information5	;
	p_history_data.information12	:= p_asgnei_data.aei_information6	;
	p_history_data.information13	:= p_asgnei_data.aei_information7	;
	p_history_data.information14	:= p_asgnei_data.aei_information8	;
	p_history_data.information15	:= p_asgnei_data.aei_information9	;
	p_history_data.information16	:= p_asgnei_data.aei_information10	;
	p_history_data.information17	:= p_asgnei_data.aei_information11	;
	p_history_data.information18	:= p_asgnei_data.aei_information12	;
	p_history_data.information19	:= p_asgnei_data.aei_information13	;
	p_history_data.information20	:= p_asgnei_data.aei_information14	;
	p_history_data.information21	:= p_asgnei_data.aei_information15	;
	p_history_data.information22	:= p_asgnei_data.aei_information16	;
	p_history_data.information23	:= p_asgnei_data.aei_information17	;
	p_history_data.information24	:= p_asgnei_data.aei_information18	;
	p_history_data.information25	:= p_asgnei_data.aei_information19	;
	p_history_data.information26	:= p_asgnei_data.aei_information20	;
	p_history_data.information27	:= p_asgnei_data.aei_information21	;
	p_history_data.information28	:= p_asgnei_data.aei_information22	;
	p_history_data.information29	:= p_asgnei_data.aei_information23	;
	p_history_data.information30	:= p_asgnei_data.aei_information24	;
	p_history_data.information31	:= p_asgnei_data.aei_information25	;
	p_history_data.information32	:= p_asgnei_data.aei_information26	;
	p_history_data.information33	:= p_asgnei_data.aei_information27	;
	p_history_data.information34	:= p_asgnei_data.aei_information28	;
	p_history_data.information35	:= p_asgnei_data.aei_information29	;
	p_history_data.information36	:= p_asgnei_data.aei_information30	;
	p_history_data.information121	:= p_asgnei_data.request_id	;
	p_history_data.information122	:= p_asgnei_data.program_application_id	;
	p_history_data.information123	:= p_asgnei_data.program_id	;
	p_history_data.information124	:= to_char(p_asgnei_data.program_update_date, g_hist_date_format);
	p_history_data.information125	:= p_asgnei_data.aei_attribute_category	;
	p_history_data.information126	:= p_asgnei_data.aei_attribute1	;
	p_history_data.information127	:= p_asgnei_data.aei_attribute2	;
	p_history_data.information128	:= p_asgnei_data.aei_attribute3	;
	p_history_data.information129	:= p_asgnei_data.aei_attribute4	;
	p_history_data.information130	:= p_asgnei_data.aei_attribute5	;
	p_history_data.information131	:= p_asgnei_data.aei_attribute6	;
	p_history_data.information132	:= p_asgnei_data.aei_attribute7	;
	p_history_data.information133	:= p_asgnei_data.aei_attribute8	;
	p_history_data.information134	:= p_asgnei_data.aei_attribute9	;
	p_history_data.information135	:= p_asgnei_data.aei_attribute10	;
	p_history_data.information136	:= p_asgnei_data.aei_attribute11	;
	p_history_data.information137	:= p_asgnei_data.aei_attribute12	;
	p_history_data.information138	:= p_asgnei_data.aei_attribute13	;
	p_history_data.information139	:= p_asgnei_data.aei_attribute14	;
	p_history_data.information140	:= p_asgnei_data.aei_attribute15	;
	p_history_data.information141	:= p_asgnei_data.aei_attribute16	;
	p_history_data.information142	:= p_asgnei_data.aei_attribute17	;
	p_history_data.information143	:= p_asgnei_data.aei_attribute18	;
	p_history_data.information144	:= p_asgnei_data.aei_attribute19	;
	p_history_data.information145	:= p_asgnei_data.aei_attribute20	;
--	p_history_data.information151	:= p_asgnei_data.object_version_number;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_history_data := l_history_data;
     raise;

end 	conv_asgnei_rg_to_hist_rg;



-- Procedure conv_hist_rg_to_asgei_rg converts the ghr_pa_history record type
-- to per_assignment_extra_info record
Procedure conv_to_asgnei_rg(
	p_history_data	    in  ghr_pa_history%rowtype,
	p_asgnei_data	in out nocopy  per_assignment_extra_info%rowtype) is

	l_proc	 varchar2(30) := 'conv_hist_rg_to_asgnei_rg';
	l_asgnei_data      per_assignment_extra_info%rowtype;

begin

        l_asgnei_data := p_asgnei_data; --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);
	p_asgnei_data.assignment_id	:= p_history_data.assignment_id	;
	p_asgnei_data.assignment_extra_info_id	:= p_history_data.information1	;
	p_asgnei_data.assignment_id			:= p_history_data.information4	;
	p_asgnei_data.information_type		:= p_history_data.information5	;
	p_asgnei_data.aei_information_category	:= p_history_data.information6	;
	p_asgnei_data.aei_information1		:= p_history_data.information7	;
	p_asgnei_data.aei_information2		:= p_history_data.information8	;
	p_asgnei_data.aei_information3		:= p_history_data.information9	;
	p_asgnei_data.aei_information4		:= p_history_data.information10	;
	p_asgnei_data.aei_information5		:= p_history_data.information11	;
	p_asgnei_data.aei_information6		:= p_history_data.information12	;
	p_asgnei_data.aei_information7		:= p_history_data.information13	;
	p_asgnei_data.aei_information8		:= p_history_data.information14	;
	p_asgnei_data.aei_information9		:= p_history_data.information15	;
	p_asgnei_data.aei_information10		:= p_history_data.information16	;
	p_asgnei_data.aei_information11		:= p_history_data.information17	;
	p_asgnei_data.aei_information12		:= p_history_data.information18	;
	p_asgnei_data.aei_information13		:= p_history_data.information19	;
	p_asgnei_data.aei_information14		:= p_history_data.information20	;
	p_asgnei_data.aei_information15		:= p_history_data.information21	;
	p_asgnei_data.aei_information16		:= p_history_data.information22	;
	p_asgnei_data.aei_information17		:= p_history_data.information23	;
	p_asgnei_data.aei_information18		:= p_history_data.information24	;
	p_asgnei_data.aei_information19		:= p_history_data.information25	;
	p_asgnei_data.aei_information20		:= p_history_data.information26	;
	p_asgnei_data.aei_information21		:= p_history_data.information27	;
	p_asgnei_data.aei_information22		:= p_history_data.information28	;
	p_asgnei_data.aei_information23		:= p_history_data.information29	;
	p_asgnei_data.aei_information24		:= p_history_data.information30	;
	p_asgnei_data.aei_information25		:= p_history_data.information31	;
	p_asgnei_data.aei_information26		:= p_history_data.information32	;
	p_asgnei_data.aei_information27		:= p_history_data.information33	;
	p_asgnei_data.aei_information28		:= p_history_data.information34	;
	p_asgnei_data.aei_information29		:= p_history_data.information35	;
	p_asgnei_data.aei_information30		:= p_history_data.information36	;
	p_asgnei_data.request_id			:= p_history_data.information121	;
	p_asgnei_data.program_application_id	:= p_history_data.information122	;
	p_asgnei_data.program_id			:= p_history_data.information123	;
	p_asgnei_data.program_update_date		:= to_date(p_history_data.information124, g_hist_date_format);
	p_asgnei_data.aei_attribute_category	:= p_history_data.information125	;
	p_asgnei_data.aei_attribute1			:= p_history_data.information126	;
	p_asgnei_data.aei_attribute2			:= p_history_data.information127	;
	p_asgnei_data.aei_attribute3			:= p_history_data.information128	;
	p_asgnei_data.aei_attribute4			:= p_history_data.information129	;
	p_asgnei_data.aei_attribute5			:= p_history_data.information130	;
	p_asgnei_data.aei_attribute6			:= p_history_data.information131	;
	p_asgnei_data.aei_attribute7			:= p_history_data.information132	;
	p_asgnei_data.aei_attribute8			:= p_history_data.information133	;
	p_asgnei_data.aei_attribute9			:= p_history_data.information134	;
	p_asgnei_data.aei_attribute10			:= p_history_data.information135	;
	p_asgnei_data.aei_attribute11			:= p_history_data.information136	;
	p_asgnei_data.aei_attribute12			:= p_history_data.information137	;
	p_asgnei_data.aei_attribute13			:= p_history_data.information138	;
	p_asgnei_data.aei_attribute14			:= p_history_data.information139	;
	p_asgnei_data.aei_attribute15			:= p_history_data.information140	;
	p_asgnei_data.aei_attribute16			:= p_history_data.information141	;
	p_asgnei_data.aei_attribute17			:= p_history_data.information142	;
	p_asgnei_data.aei_attribute18			:= p_history_data.information143	;
	p_asgnei_data.aei_attribute19			:= p_history_data.information144	;
	p_asgnei_data.aei_attribute20			:= p_history_data.information145	;
--	p_asgnei_data.object_version_number		:= p_history_data.information151;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_asgnei_data := l_asgnei_data;
     raise;


end 	conv_to_asgnei_rg;



-- Procedure conv_to_asgn_rg copies the indivisual fields supplied as parameters
-- to the per_assignments_f type record.

Procedure conv_to_asgn_rg(
	p_assignment_id                   in per_assignments_f.assignment_id%type                 default null,
	p_effective_start_date            in per_assignments_f.effective_start_date%type          default null,
	p_effective_end_date              in per_assignments_f.effective_end_date%type            default null,
	p_business_group_id               in per_assignments_f.business_group_id%type             default null,
	p_recruiter_id                    in per_assignments_f.recruiter_id%type                  default null,
	p_grade_id                        in per_assignments_f.grade_id%type                      default null,
	p_position_id                     in per_assignments_f.position_id%type                   default null,
	p_job_id                          in per_assignments_f.job_id%type                        default null,
	p_assignment_status_type_id       in per_assignments_f.assignment_status_type_id%type     default null,
	p_payroll_id                      in per_assignments_f.payroll_id%type                    default null,
	p_location_id                     in per_assignments_f.location_id%type                   default null,
	p_person_referred_by_id           in per_assignments_f.person_referred_by_id%type         default null,
	p_supervisor_id                   in per_assignments_f.supervisor_id%type                 default null,
	p_special_ceiling_step_id         in per_assignments_f.special_ceiling_step_id%type       default null,
	p_person_id                       in per_assignments_f.person_id%type                     default null,
	p_recruitment_activity_id         in per_assignments_f.recruitment_activity_id%type       default null,
	p_source_organization_id          in per_assignments_f.source_organization_id%type        default null,
	p_organization_id                 in per_assignments_f.organization_id%type               default null,
	p_people_group_id                 in per_assignments_f.people_group_id%type               default null,
	p_soft_coding_keyflex_id          in per_assignments_f.soft_coding_keyflex_id%type        default null,
	p_vacancy_id                      in per_assignments_f.vacancy_id%type                    default null,
	p_pay_basis_id                    in per_assignments_f.pay_basis_id%type                  default null,
	p_assignment_sequence             in per_assignments_f.assignment_sequence%type           default null,
	p_assignment_type                 in per_assignments_f.assignment_type%type               default null,
	p_primary_flag                    in per_assignments_f.primary_flag%type                  default null,
	p_application_id                  in per_assignments_f.application_id%type                default null,
	p_assignment_number               in per_assignments_f.assignment_number%type             default null,
	p_change_reason                   in per_assignments_f.change_reason%type                 default null,
	p_comment_id                      in per_assignments_f.comment_id%type                    default null,
	p_date_probation_end              in per_assignments_f.date_probation_end%type            default null,
	p_default_code_comb_id            in per_assignments_f.default_code_comb_id%type          default null,
	p_employment_category             in per_assignments_f.employment_category%type           default null,
	p_frequency                       in per_assignments_f.frequency%type                     default null,
	p_internal_address_line           in per_assignments_f.internal_address_line%type         default null,
	p_manager_flag                    in per_assignments_f.manager_flag%type                  default null,
	p_normal_hours                    in per_assignments_f.normal_hours%type                  default null,
	p_perf_review_period              in per_assignments_f.perf_review_period%type            default null,
	p_perf_review_period_frequency    in per_assignments_f.perf_review_period_frequency%type  default null,
	p_period_of_service_id            in per_assignments_f.period_of_service_id%type          default null,
	p_probation_period                in per_assignments_f.probation_period%type              default null,
	p_probation_unit                  in per_assignments_f.probation_unit%type                default null,
	p_sal_review_period               in per_assignments_f.sal_review_period%type             default null,
	p_sal_review_period_frequency     in per_assignments_f.sal_review_period_frequency%type   default null,
	p_set_of_books_id                 in per_assignments_f.set_of_books_id%type               default null,
	p_source_type                     in per_assignments_f.source_type%type                   default null,
	p_time_normal_finish              in per_assignments_f.time_normal_finish%type            default null,
	p_time_normal_start               in per_assignments_f.time_normal_start%type             default null,
	p_request_id                      in per_assignments_f.request_id%type                    default null,
	p_program_application_id          in per_assignments_f.program_application_id%type        default null,
	p_program_id                      in per_assignments_f.program_id%type                    default null,
	p_program_update_date             in per_assignments_f.program_update_date%type           default null,
	p_ass_attribute_category          in per_assignments_f.ass_attribute_category%type        default null,
	p_ass_attribute1                  in per_assignments_f.ass_attribute1%type                default null,
	p_ass_attribute2                  in per_assignments_f.ass_attribute2%type                default null,
	p_ass_attribute3                  in per_assignments_f.ass_attribute3%type                default null,
	p_ass_attribute4                  in per_assignments_f.ass_attribute4%type                default null,
	p_ass_attribute5                  in per_assignments_f.ass_attribute5%type                default null,
	p_ass_attribute6                  in per_assignments_f.ass_attribute6%type                default null,
	p_ass_attribute7                  in per_assignments_f.ass_attribute7%type                default null,
	p_ass_attribute8                  in per_assignments_f.ass_attribute8%type                default null,
	p_ass_attribute9                  in per_assignments_f.ass_attribute9%type                default null,
	p_ass_attribute10                 in per_assignments_f.ass_attribute10%type               default null,
	p_ass_attribute11                 in per_assignments_f.ass_attribute11%type               default null,
	p_ass_attribute12                 in per_assignments_f.ass_attribute12%type               default null,
	p_ass_attribute13                 in per_assignments_f.ass_attribute13%type               default null,
	p_ass_attribute14                 in per_assignments_f.ass_attribute14%type               default null,
	p_ass_attribute15                 in per_assignments_f.ass_attribute15%type               default null,
	p_ass_attribute16                 in per_assignments_f.ass_attribute16%type               default null,
	p_ass_attribute17                 in per_assignments_f.ass_attribute17%type               default null,
	p_ass_attribute18                 in per_assignments_f.ass_attribute18%type               default null,
	p_ass_attribute19                 in per_assignments_f.ass_attribute19%type               default null,
	p_ass_attribute20                 in per_assignments_f.ass_attribute20%type               default null,
	p_ass_attribute21                 in per_assignments_f.ass_attribute21%type               default null,
	p_ass_attribute22                 in per_assignments_f.ass_attribute22%type               default null,
	p_ass_attribute23                 in per_assignments_f.ass_attribute23%type               default null,
	p_ass_attribute24                 in per_assignments_f.ass_attribute24%type               default null,
	p_ass_attribute25                 in per_assignments_f.ass_attribute25%type               default null,
	p_ass_attribute26                 in per_assignments_f.ass_attribute26%type               default null,
	p_ass_attribute27                 in per_assignments_f.ass_attribute27%type               default null,
	p_ass_attribute28                 in per_assignments_f.ass_attribute28%type               default null,
	p_ass_attribute29                 in per_assignments_f.ass_attribute29%type               default null,
	p_ass_attribute30                 in per_assignments_f.ass_attribute30%type               default null,
	p_title                           in per_assignments_f.title%type                         default null,
--	p_object_version_number           in per_assignments_f.object_version_number%type         default null,
	p_asgn_data	  	 		in out nocopy per_all_assignments_f%rowtype  )  as

	l_proc	varchar2(30):='conv_to_asgn_rg';
	l_asgn_data    per_all_assignments_f%rowtype;

begin

        l_asgn_data :=p_asgn_data; --NOCOPY CHANGES

 	hr_utility.set_location('Entering:'|| l_proc, 5);

	copy_field_value( p_source_field =>  p_assignment_id,
				p_target_field =>  p_asgn_data.assignment_id);
	copy_field_value( p_source_field =>  p_effective_start_date,
				p_target_field =>  p_asgn_data.effective_start_date);
	copy_field_value( p_source_field =>  p_effective_end_date,
				p_target_field =>  p_asgn_data.effective_end_date);
	copy_field_value( p_source_field =>  p_business_group_id,
				p_target_field =>  p_asgn_data.business_group_id);
	copy_field_value( p_source_field =>  p_recruiter_id,
				p_target_field =>  p_asgn_data.recruiter_id);
	copy_field_value( p_source_field =>  p_grade_id,
				p_target_field =>  p_asgn_data.grade_id);
	copy_field_value( p_source_field =>  p_position_id,
				p_target_field =>  p_asgn_data.position_id);
	copy_field_value( p_source_field =>  p_job_id,
				p_target_field =>  p_asgn_data.job_id);
	copy_field_value( p_source_field =>  p_assignment_status_type_id,
				p_target_field =>  p_asgn_data.assignment_status_type_id);
	copy_field_value( p_source_field =>  p_payroll_id,
				p_target_field =>  p_asgn_data.payroll_id);
	copy_field_value( p_source_field =>  p_location_id,
				p_target_field =>  p_asgn_data.location_id);
	copy_field_value( p_source_field =>  p_person_referred_by_id,
				p_target_field =>  p_asgn_data.person_referred_by_id);
	copy_field_value( p_source_field =>  p_supervisor_id,
				p_target_field =>  p_asgn_data.supervisor_id);
	copy_field_value( p_source_field =>  p_special_ceiling_step_id,
				p_target_field =>  p_asgn_data.special_ceiling_step_id);
	copy_field_value( p_source_field =>  p_person_id,
				p_target_field =>  p_asgn_data.person_id);
	copy_field_value( p_source_field =>  p_recruitment_activity_id,
				p_target_field =>  p_asgn_data.recruitment_activity_id);
	copy_field_value( p_source_field =>  p_source_organization_id,
				p_target_field =>  p_asgn_data.source_organization_id);
	copy_field_value( p_source_field =>  p_organization_id,
				p_target_field =>  p_asgn_data.organization_id);
	copy_field_value( p_source_field =>  p_people_group_id,
				p_target_field =>  p_asgn_data.people_group_id);
	copy_field_value( p_source_field =>  p_soft_coding_keyflex_id,
				p_target_field =>  p_asgn_data.soft_coding_keyflex_id);
	copy_field_value( p_source_field =>  p_vacancy_id,
				p_target_field =>  p_asgn_data.vacancy_id);
	copy_field_value( p_source_field =>  p_pay_basis_id,
				p_target_field =>  p_asgn_data.pay_basis_id);
	copy_field_value( p_source_field =>  p_assignment_sequence,
				p_target_field =>  p_asgn_data.assignment_sequence);
	copy_field_value( p_source_field =>  p_assignment_type,
				p_target_field =>  p_asgn_data.assignment_type);
	copy_field_value( p_source_field =>  p_primary_flag,
				p_target_field =>  p_asgn_data.primary_flag);
	copy_field_value( p_source_field =>  p_application_id,
				p_target_field =>  p_asgn_data.application_id);
	copy_field_value( p_source_field =>  p_assignment_number,
				p_target_field =>  p_asgn_data.assignment_number);
	copy_field_value( p_source_field =>  p_change_reason,
				p_target_field =>  p_asgn_data.change_reason);
	copy_field_value( p_source_field =>  p_comment_id,
				p_target_field =>  p_asgn_data.comment_id);
	copy_field_value( p_source_field =>  p_date_probation_end,
				p_target_field =>  p_asgn_data.date_probation_end);
	copy_field_value( p_source_field =>  p_default_code_comb_id,
				p_target_field =>  p_asgn_data.default_code_comb_id);
	copy_field_value( p_source_field =>  p_employment_category,
				p_target_field =>  p_asgn_data.employment_category);
	copy_field_value( p_source_field =>  p_frequency,
				p_target_field =>  p_asgn_data.frequency);
	copy_field_value( p_source_field =>  p_internal_address_line,
				p_target_field =>  p_asgn_data.internal_address_line);
	copy_field_value( p_source_field =>  p_manager_flag,
				p_target_field =>  p_asgn_data.manager_flag);
	copy_field_value( p_source_field =>  p_normal_hours,
				p_target_field =>  p_asgn_data.normal_hours);
	copy_field_value( p_source_field =>  p_perf_review_period,
				p_target_field =>  p_asgn_data.perf_review_period);
	copy_field_value( p_source_field =>  p_perf_review_period_frequency,
				p_target_field =>  p_asgn_data.perf_review_period_frequency);
	copy_field_value( p_source_field =>  p_period_of_service_id,
				p_target_field =>  p_asgn_data.period_of_service_id);
	copy_field_value( p_source_field =>  p_probation_period,
				p_target_field =>  p_asgn_data.probation_period);
	copy_field_value( p_source_field =>  p_probation_unit,
				p_target_field =>  p_asgn_data.probation_unit);
	copy_field_value( p_source_field =>  p_sal_review_period,
				p_target_field =>  p_asgn_data.sal_review_period);
	copy_field_value( p_source_field =>  p_sal_review_period_frequency,
				p_target_field =>  p_asgn_data.sal_review_period_frequency);
	copy_field_value( p_source_field =>  p_set_of_books_id,
				p_target_field =>  p_asgn_data.set_of_books_id);
	copy_field_value( p_source_field =>  p_source_type,
				p_target_field =>  p_asgn_data.source_type);
	copy_field_value( p_source_field =>  p_time_normal_finish,
				p_target_field =>  p_asgn_data.time_normal_finish);
	copy_field_value( p_source_field =>  p_time_normal_start,
				p_target_field =>  p_asgn_data.time_normal_start);
	copy_field_value( p_source_field =>  p_request_id,
				p_target_field =>  p_asgn_data.request_id);
	copy_field_value( p_source_field =>  p_program_application_id,
				p_target_field =>  p_asgn_data.program_application_id);
	copy_field_value( p_source_field =>  p_program_id,
				p_target_field =>  p_asgn_data.program_id);
	copy_field_value( p_source_field =>  p_program_update_date,
				p_target_field =>  p_asgn_data.program_update_date);
	copy_field_value( p_source_field =>  p_ass_attribute_category,
				p_target_field =>  p_asgn_data.ass_attribute_category);
	copy_field_value( p_source_field =>  p_ass_attribute1,
				p_target_field =>  p_asgn_data.ass_attribute1);
	copy_field_value( p_source_field =>  p_ass_attribute2,
				p_target_field =>  p_asgn_data.ass_attribute2);
	copy_field_value( p_source_field =>  p_ass_attribute3,
				p_target_field =>  p_asgn_data.ass_attribute3);
	copy_field_value( p_source_field =>  p_ass_attribute4,
				p_target_field =>  p_asgn_data.ass_attribute4);
	copy_field_value( p_source_field =>  p_ass_attribute5,
				p_target_field =>  p_asgn_data.ass_attribute5);
	copy_field_value( p_source_field =>  p_ass_attribute6,
				p_target_field =>  p_asgn_data.ass_attribute6);
	copy_field_value( p_source_field =>  p_ass_attribute7,
				p_target_field =>  p_asgn_data.ass_attribute7);
	copy_field_value( p_source_field =>  p_ass_attribute8,
				p_target_field =>  p_asgn_data.ass_attribute8);
	copy_field_value( p_source_field =>  p_ass_attribute9,
				p_target_field =>  p_asgn_data.ass_attribute9);
	copy_field_value( p_source_field =>  p_ass_attribute10,
				p_target_field =>  p_asgn_data.ass_attribute10);
	copy_field_value( p_source_field =>  p_ass_attribute11,
				p_target_field =>  p_asgn_data.ass_attribute11);
	copy_field_value( p_source_field =>  p_ass_attribute12,
				p_target_field =>  p_asgn_data.ass_attribute12);
	copy_field_value( p_source_field =>  p_ass_attribute13,
				p_target_field =>  p_asgn_data.ass_attribute13);
	copy_field_value( p_source_field =>  p_ass_attribute14,
				p_target_field =>  p_asgn_data.ass_attribute14);
	copy_field_value( p_source_field =>  p_ass_attribute15,
				p_target_field =>  p_asgn_data.ass_attribute15);
	copy_field_value( p_source_field =>  p_ass_attribute16,
				p_target_field =>  p_asgn_data.ass_attribute16);
	copy_field_value( p_source_field =>  p_ass_attribute17,
				p_target_field =>  p_asgn_data.ass_attribute17);
	copy_field_value( p_source_field =>  p_ass_attribute18,
				p_target_field =>  p_asgn_data.ass_attribute18);
	copy_field_value( p_source_field =>  p_ass_attribute19,
				p_target_field =>  p_asgn_data.ass_attribute19);
	copy_field_value( p_source_field =>  p_ass_attribute20,
				p_target_field =>  p_asgn_data.ass_attribute20);
	copy_field_value( p_source_field =>  p_ass_attribute21,
				p_target_field =>  p_asgn_data.ass_attribute21);
	copy_field_value( p_source_field =>  p_ass_attribute22,
				p_target_field =>  p_asgn_data.ass_attribute22);
	copy_field_value( p_source_field =>  p_ass_attribute23,
				p_target_field =>  p_asgn_data.ass_attribute23);
	copy_field_value( p_source_field =>  p_ass_attribute24,
				p_target_field =>  p_asgn_data.ass_attribute24);
	copy_field_value( p_source_field =>  p_ass_attribute25,
				p_target_field =>  p_asgn_data.ass_attribute25);
	copy_field_value( p_source_field =>  p_ass_attribute26,
				p_target_field =>  p_asgn_data.ass_attribute26);
	copy_field_value( p_source_field =>  p_ass_attribute27,
				p_target_field =>  p_asgn_data.ass_attribute27);
	copy_field_value( p_source_field =>  p_ass_attribute28,
				p_target_field =>  p_asgn_data.ass_attribute28);
	copy_field_value( p_source_field =>  p_ass_attribute29,
				p_target_field =>  p_asgn_data.ass_attribute29);
	copy_field_value( p_source_field =>  p_ass_attribute30,
				p_target_field =>  p_asgn_data.ass_attribute30);
	copy_field_value( p_source_field =>  p_title,
				p_target_field =>  p_asgn_data.title);
--	copy_field_value( p_source_field =>  p_object_version_number,
--				p_target_field =>  p_asgn_data.object_version_number);
 	hr_utility.set_location('Leaving:'|| l_proc, 5);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_asgn_data := l_asgn_data;
     raise;

End  conv_to_asgn_rg;

Procedure conv_to_asgn_rg ( p_asgn_h_v		in	ghr_assignments_h_v%rowtype,
                            p_asgn_data        out nocopy	per_all_assignments_f%rowtype) is

	l_asgn_data  per_all_assignments_f%rowtype;

	l_proc 	varchar2(30):='conv_to_asgn_rg';
Begin


	hr_utility.set_location('Entering : ' || l_proc, 100);
	conv_to_asgn_rg(
                       p_assignment_id                   => p_asgn_h_v.assignment_id                        ,
                       p_effective_start_date            => p_asgn_h_v.effective_start_date                 ,
                       p_effective_end_date              => p_asgn_h_v.effective_end_date                   ,
                       p_business_group_id               => p_asgn_h_v.business_group_id                    ,
                       p_recruiter_id                    => p_asgn_h_v.recruiter_id                         ,
                       p_grade_id                        => p_asgn_h_v.grade_id                             ,
                       p_position_id                     => p_asgn_h_v.position_id                          ,
                       p_job_id                          => p_asgn_h_v.job_id                               ,
                       p_assignment_status_type_id       => p_asgn_h_v.assignment_status_type_id            ,
                       p_payroll_id                      => p_asgn_h_v.payroll_id                           ,
                       p_location_id                     => p_asgn_h_v.location_id                          ,
                       p_person_referred_by_id           => p_asgn_h_v.person_referred_by_id                ,
                       p_supervisor_id                   => p_asgn_h_v.supervisor_id                        ,
                       p_special_ceiling_step_id         => p_asgn_h_v.special_ceiling_step_id              ,
                       p_person_id                       => p_asgn_h_v.person_id                            ,
                       p_recruitment_activity_id         => p_asgn_h_v.recruitment_activity_id              ,
                       p_source_organization_id          => p_asgn_h_v.source_organization_id               ,
                       p_organization_id                 => p_asgn_h_v.organization_id                      ,
                       p_people_group_id                 => p_asgn_h_v.people_group_id                      ,
                       p_soft_coding_keyflex_id          => p_asgn_h_v.soft_coding_keyflex_id               ,
                       p_vacancy_id                      => p_asgn_h_v.vacancy_id                           ,
                       p_pay_basis_id                    => p_asgn_h_v.pay_basis_id                         ,
                       p_assignment_sequence             => p_asgn_h_v.assignment_sequence                  ,
                       p_assignment_type                 => p_asgn_h_v.assignment_type                      ,
                       p_primary_flag                    => p_asgn_h_v.primary_flag                         ,
                       p_application_id                  => p_asgn_h_v.application_id                       ,
                       p_assignment_number               => p_asgn_h_v.assignment_number                    ,
                       p_change_reason                   => p_asgn_h_v.change_reason                        ,
                       p_comment_id                      => p_asgn_h_v.comment_id                           ,
                       p_date_probation_end              => p_asgn_h_v.date_probation_end                   ,
                       p_default_code_comb_id            => p_asgn_h_v.default_code_comb_id                 ,
                       p_employment_category             => p_asgn_h_v.employment_category                  ,
                       p_frequency                       => p_asgn_h_v.frequency                            ,
                       p_internal_address_line           => p_asgn_h_v.internal_address_line                ,
                       p_manager_flag                    => p_asgn_h_v.manager_flag                         ,
                       p_normal_hours                    => p_asgn_h_v.normal_hours                         ,
                       p_perf_review_period              => p_asgn_h_v.perf_review_period                   ,
                       p_perf_review_period_frequency    => p_asgn_h_v.perf_review_period_frequency         ,
                       p_period_of_service_id            => p_asgn_h_v.period_of_service_id                 ,
                       p_probation_period                => p_asgn_h_v.probation_period                     ,
                       p_probation_unit                  => p_asgn_h_v.probation_unit                       ,
                       p_sal_review_period               => p_asgn_h_v.sal_review_period                    ,
                       p_sal_review_period_frequency     => p_asgn_h_v.sal_review_period_frequency          ,
                       p_set_of_books_id                 => p_asgn_h_v.set_of_books_id                      ,
                       p_source_type                     => p_asgn_h_v.source_type                          ,
                       p_time_normal_finish              => p_asgn_h_v.time_normal_finish                   ,
                       p_time_normal_start               => p_asgn_h_v.time_normal_start                    ,
                       p_request_id                      => p_asgn_h_v.request_id                           ,
                       p_program_application_id          => p_asgn_h_v.program_application_id               ,
                       p_program_id                      => p_asgn_h_v.program_id                           ,
                       p_program_update_date             => p_asgn_h_v.program_update_date                  ,
                       p_ass_attribute_category          => p_asgn_h_v.ass_attribute_category               ,
                       p_ass_attribute1                  => p_asgn_h_v.ass_attribute1                       ,
                       p_ass_attribute2                  => p_asgn_h_v.ass_attribute2                       ,
                       p_ass_attribute3                  => p_asgn_h_v.ass_attribute3                       ,
                       p_ass_attribute4                  => p_asgn_h_v.ass_attribute4                       ,
                       p_ass_attribute5                  => p_asgn_h_v.ass_attribute5                       ,
                       p_ass_attribute6                  => p_asgn_h_v.ass_attribute6                       ,
                       p_ass_attribute7                  => p_asgn_h_v.ass_attribute7                       ,
                       p_ass_attribute8                  => p_asgn_h_v.ass_attribute8                       ,
                       p_ass_attribute9                  => p_asgn_h_v.ass_attribute9                       ,
                       p_ass_attribute10                 => p_asgn_h_v.ass_attribute10                      ,
                       p_ass_attribute11                 => p_asgn_h_v.ass_attribute11                      ,
                       p_ass_attribute12                 => p_asgn_h_v.ass_attribute12                      ,
                       p_ass_attribute13                 => p_asgn_h_v.ass_attribute13                      ,
                       p_ass_attribute14                 => p_asgn_h_v.ass_attribute14                      ,
                       p_ass_attribute15                 => p_asgn_h_v.ass_attribute15                      ,
                       p_ass_attribute16                 => p_asgn_h_v.ass_attribute16                      ,
                       p_ass_attribute17                 => p_asgn_h_v.ass_attribute17                      ,
                       p_ass_attribute18                 => p_asgn_h_v.ass_attribute18                      ,
                       p_ass_attribute19                 => p_asgn_h_v.ass_attribute19                      ,
                       p_ass_attribute20                 => p_asgn_h_v.ass_attribute20                      ,
                       p_ass_attribute21                 => p_asgn_h_v.ass_attribute21                      ,
                       p_ass_attribute22                 => p_asgn_h_v.ass_attribute22                      ,
                       p_ass_attribute23                 => p_asgn_h_v.ass_attribute23                      ,
                       p_ass_attribute24                 => p_asgn_h_v.ass_attribute24                      ,
                       p_ass_attribute25                 => p_asgn_h_v.ass_attribute25                      ,
                       p_ass_attribute26                 => p_asgn_h_v.ass_attribute26                      ,
                       p_ass_attribute27                 => p_asgn_h_v.ass_attribute27                      ,
                       p_ass_attribute28                 => p_asgn_h_v.ass_attribute28                      ,
                       p_ass_attribute29                 => p_asgn_h_v.ass_attribute29                      ,
                       p_ass_attribute30                 => p_asgn_h_v.ass_attribute30                      ,
                       p_title                           => p_asgn_h_v.title                                ,
--                       p_object_version_number           => p_asgn_h_v.object_version_number                ,
                       p_asgn_data                       => l_asgn_data);

	p_asgn_data := l_asgn_data;
	hr_utility.set_location('Leaving : ' || l_proc, 200);

 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_asgn_data := NULL;
     raise;

End conv_to_asgn_rg;

-- procedure convert_assignment_rg_hist_rg converts the  per_assignments record type to
-- ghr_pa_history record type
procedure conv_asgn_rg_to_hist_rg(
	p_assignment_data        in  per_all_assignments_f%rowtype,
	p_history_data   	   in out nocopy ghr_pa_history%rowtype) as

	l_proc	 varchar2(30) := 'convert_assignment_rg_hist_rg';
        l_history_data   ghr_pa_history%rowtype;
begin

        l_history_data := p_history_data; --NOCOPY CHANGES
	hr_utility.set_location('entering:'|| l_proc, 5);

	p_history_data.information1	  :=   	p_assignment_data.assignment_id	;
	p_history_data.information2	  :=   	to_char(p_assignment_data.effective_start_date, g_hist_date_format)	;
	p_history_data.information3	  :=   	to_char(p_assignment_data.effective_end_date, g_hist_date_format)	;
	p_history_data.information4	  :=   	p_assignment_data.recruiter_id	;
	p_history_data.information5	  :=   	p_assignment_data.assignment_status_type_id	;
	p_history_data.information6	  :=   	p_assignment_data.payroll_id	;
	p_history_data.information7	  :=   	p_assignment_data.person_referred_by_id	;
	p_history_data.information8	  :=   	p_assignment_data.supervisor_id	;
	p_history_data.information9	  :=   	p_assignment_data.special_ceiling_step_id	;
	p_history_data.information10	  :=   	p_assignment_data.person_id	;
	p_history_data.information11	  :=   	p_assignment_data.recruitment_activity_id	;
	p_history_data.information12	  :=   	p_assignment_data.source_organization_id	;
	p_history_data.information13	  :=   	p_assignment_data.people_group_id	;
	p_history_data.information14	  :=   	p_assignment_data.soft_coding_keyflex_id	;
	p_history_data.information15	  :=   	p_assignment_data.vacancy_id	;
	p_history_data.information16	  :=   	p_assignment_data.pay_basis_id	;
	p_history_data.information17	  :=   	p_assignment_data.assignment_sequence	;
	p_history_data.information18	  :=   	p_assignment_data.assignment_type	;
	p_history_data.information19	  :=   	p_assignment_data.primary_flag	;
	p_history_data.information20	  :=   	p_assignment_data.application_id	;
	p_history_data.information21	  :=   	p_assignment_data.assignment_number	;
	p_history_data.information22	  :=   	p_assignment_data.change_reason	;
	p_history_data.information23	  :=   	p_assignment_data.comment_id	;
	p_history_data.information24	  :=   	to_char(p_assignment_data.date_probation_end,g_hist_date_format)	;
	p_history_data.information25	  :=   	p_assignment_data.default_code_comb_id	;
	p_history_data.information26	  :=   	p_assignment_data.employment_category	;
	p_history_data.information27	  :=   	p_assignment_data.frequency	;
	p_history_data.information28	  :=   	p_assignment_data.internal_address_line	;
	p_history_data.information29	  :=   	p_assignment_data.manager_flag	;
	p_history_data.information30	  :=   	p_assignment_data.normal_hours	;
	p_history_data.information31	  :=   	p_assignment_data.perf_review_period	;
	p_history_data.information32	  :=   	p_assignment_data.perf_review_period_frequency	;
	p_history_data.information33	  :=   	p_assignment_data.period_of_service_id	;
	p_history_data.information34	  :=   	p_assignment_data.probation_period	;
	p_history_data.information35	  :=   	p_assignment_data.probation_unit	;
	p_history_data.information36	  :=   	p_assignment_data.sal_review_period	;
	p_history_data.information37	  :=   	p_assignment_data.sal_review_period_frequency	;
	p_history_data.information38	  :=   	p_assignment_data.set_of_books_id	;
	p_history_data.information39	  :=   	p_assignment_data.source_type	;
	p_history_data.information40	  :=   	p_assignment_data.time_normal_finish	;
	p_history_data.information41	  :=   	p_assignment_data.time_normal_start	;
	p_history_data.information42	  :=   	p_assignment_data.title	;
	p_history_data.information43	  :=   	p_assignment_data.organization_id	;
	p_history_data.information44	  :=   	p_assignment_data.job_id	;
	p_history_data.information101	  :=   	p_assignment_data.position_id	;
	p_history_data.information45	  :=   	p_assignment_data.grade_id	;
	p_history_data.information103	  :=   	p_assignment_data.location_id	;
	p_history_data.information121	  :=   	p_assignment_data.business_group_id	;
	p_history_data.information122	  :=   	p_assignment_data.request_id	;
	p_history_data.information123	  :=   	p_assignment_data.program_application_id	;
	p_history_data.information124	  :=   	p_assignment_data.program_id	;
	p_history_data.information125	  :=   	p_assignment_data.program_update_date	;
	p_history_data.information126	  :=   	p_assignment_data.ass_attribute_category	;
	p_history_data.information127	  :=   	p_assignment_data.ass_attribute1	;
	p_history_data.information128	  :=   	p_assignment_data.ass_attribute2	;
	p_history_data.information129	  :=   	p_assignment_data.ass_attribute3	;
	p_history_data.information130	  :=   	p_assignment_data.ass_attribute4	;
	p_history_data.information131	  :=   	p_assignment_data.ass_attribute5	;
	p_history_data.information132	  :=   	p_assignment_data.ass_attribute6	;
	p_history_data.information133	  :=   	p_assignment_data.ass_attribute7	;
	p_history_data.information134	  :=   	p_assignment_data.ass_attribute8	;
	p_history_data.information135	  :=   	p_assignment_data.ass_attribute9	;
	p_history_data.information136	  :=   	p_assignment_data.ass_attribute10	;
	p_history_data.information137	  :=   	p_assignment_data.ass_attribute11	;
	p_history_data.information138	  :=   	p_assignment_data.ass_attribute12	;
	p_history_data.information139	  :=   	p_assignment_data.ass_attribute13	;
	p_history_data.information140	  :=   	p_assignment_data.ass_attribute14	;
	p_history_data.information141	  :=   	p_assignment_data.ass_attribute15	;
	p_history_data.information142	  :=   	p_assignment_data.ass_attribute16	;
	p_history_data.information143	  :=   	p_assignment_data.ass_attribute17	;
	p_history_data.information144	  :=   	p_assignment_data.ass_attribute18	;
	p_history_data.information145	  :=   	p_assignment_data.ass_attribute19	;
	p_history_data.information146	  :=   	p_assignment_data.ass_attribute20	;
	p_history_data.information147	  :=   	p_assignment_data.ass_attribute21	;
	p_history_data.information148	  :=   	p_assignment_data.ass_attribute22	;
	p_history_data.information149	  :=   	p_assignment_data.ass_attribute23	;
	p_history_data.information150	  :=   	p_assignment_data.ass_attribute24	;
	p_history_data.information151	  :=   	p_assignment_data.ass_attribute25	;
	p_history_data.information152	  :=   	p_assignment_data.ass_attribute26	;
	p_history_data.information153	  :=   	p_assignment_data.ass_attribute27	;
	p_history_data.information154	  :=   	p_assignment_data.ass_attribute28	;
	p_history_data.information155	  :=   	p_assignment_data.ass_attribute29	;
	p_history_data.information156	  :=   	p_assignment_data.ass_attribute30	;
--	p_history_data.information162	  :=   	p_assignment_data.object_version_number	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_history_data := l_history_data;
     raise;

end conv_asgn_rg_to_hist_rg;

-- procedure conv_hist_rg_to_asgn_rg converts the  pa_history record to
-- per_assignments record type
procedure conv_to_asgn_rg(
	p_history_data   	  	 in ghr_pa_history%rowtype,
	p_assignment_data    in out nocopy per_all_assignments_f%rowtype) as

	l_proc	 varchar2(30) := 'conv_hist_rg_to_asgn_rg';
	l_assignment_data   per_all_assignments_f%rowtype;

begin

	l_assignment_data :=p_assignment_data; --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);

	p_assignment_data.assignment_id	  	:=   	p_history_data.information1;
	p_assignment_data.effective_start_date	:=   	to_date(p_history_data.information2, g_hist_date_format)	;
	p_assignment_data.effective_end_date	:=   	to_date(p_history_data.information3, g_hist_date_format)	;
	p_assignment_data.recruiter_id	  	:=   	p_history_data.information4	;
	p_assignment_data.assignment_status_type_id	:=   	p_history_data.information5	;
	p_assignment_data.payroll_id	  		:=   	p_history_data.information6	;
	p_assignment_data.person_referred_by_id	:=   	p_history_data.information7	;
	p_assignment_data.supervisor_id	  	:=   	p_history_data.information8	;
	p_assignment_data.special_ceiling_step_id :=   	p_history_data.information9	;
	p_assignment_data.person_id			:=   	p_history_data.information10	;
	p_assignment_data.recruitment_activity_id	:=   	p_history_data.information11	;
	p_assignment_data.source_organization_id	:=   	p_history_data.information12	;
	p_assignment_data.people_group_id		:=   	p_history_data.information13	;
	p_assignment_data.soft_coding_keyflex_id	:=   	p_history_data.information14	;
	p_assignment_data.vacancy_id			:=   	p_history_data.information15	;
	p_assignment_data.pay_basis_id		:=   	p_history_data.information16	;
	p_assignment_data.assignment_sequence	:=   	p_history_data.information17	;
	p_assignment_data.assignment_type		:=   	p_history_data.information18	;
	p_assignment_data.primary_flag		:=   	p_history_data.information19	;
	p_assignment_data.application_id	  	:=   	p_history_data.information20	;
	p_assignment_data.assignment_number	  	:=   	p_history_data.information21	;
	p_assignment_data.change_reason	  	:=   	p_history_data.information22	;
	p_assignment_data.comment_id	  		:=   	p_history_data.information23	;
	p_assignment_data.date_probation_end	:=   	to_date(p_history_data.information24, g_hist_date_format)	;
	p_assignment_data.default_code_comb_id	:=   	p_history_data.information25	;
	p_assignment_data.employment_category	:=   	p_history_data.information26	;
	p_assignment_data.frequency	  		:=   	p_history_data.information27	;
	p_assignment_data.internal_address_line	:=   	p_history_data.information28	;
	p_assignment_data.manager_flag	  	:=   	p_history_data.information29	;
	p_assignment_data.normal_hours	  	:=   	p_history_data.information30	;
	p_assignment_data.perf_review_period	:=   	p_history_data.information31	;
	p_assignment_data.perf_review_period_frequency	  :=  p_history_data.information32	;
	p_assignment_data.period_of_service_id	:=   	p_history_data.information33	;
	p_assignment_data.probation_period	  	:=   	p_history_data.information34	;
	p_assignment_data.probation_unit	  	:=   	p_history_data.information35	;
	p_assignment_data.sal_review_period	  	:=   	p_history_data.information36	;
	p_assignment_data.sal_review_period_frequency	  :=  p_history_data.information37	;
	p_assignment_data.set_of_books_id	  	:=   	p_history_data.information38	;
	p_assignment_data.source_type	  		:=   	p_history_data.information39	;
	p_assignment_data.time_normal_finish	:=   	p_history_data.information40	;
	p_assignment_data.time_normal_start	  	:=   	p_history_data.information41	;
	p_assignment_data.title	  			:=   	p_history_data.information42	;
	p_assignment_data.organization_id  		:=   	p_history_data.information43	;
	p_assignment_data.job_id	  		:=   	p_history_data.information44	;
	p_assignment_data.position_id	  		:=   	p_history_data.information101	;
	p_assignment_data.grade_id	  		:=   	p_history_data.information45	;
	p_assignment_data.location_id	  		:=   	p_history_data.information103	;
	p_assignment_data.business_group_id	  	:=   	p_history_data.information121	;
	p_assignment_data.request_id	  		:=   	p_history_data.information122	;
	p_assignment_data.program_application_id	:=   	p_history_data.information123	;
	p_assignment_data.program_id	  		:=   	p_history_data.information124	;
	p_assignment_data.program_update_date	:=   	p_history_data.information125	;
	p_assignment_data.ass_attribute_category	:=   	p_history_data.information126	;
	p_assignment_data.ass_attribute1		:=   	p_history_data.information127	;
	p_assignment_data.ass_attribute2		:=   	p_history_data.information128	;
	p_assignment_data.ass_attribute3		:=   	p_history_data.information129	;
	p_assignment_data.ass_attribute4		:=   	p_history_data.information130	;
	p_assignment_data.ass_attribute5	  	:=   	p_history_data.information131	;
	p_assignment_data.ass_attribute6	  	:=   	p_history_data.information132	;
	p_assignment_data.ass_attribute7	  	:=   	p_history_data.information133	;
	p_assignment_data.ass_attribute8	  	:=   	p_history_data.information134	;
	p_assignment_data.ass_attribute9	  	:=   	p_history_data.information135	;
	p_assignment_data.ass_attribute10	  	:=   	p_history_data.information136	;
	p_assignment_data.ass_attribute11	  	:=   	p_history_data.information137	;
	p_assignment_data.ass_attribute12	  	:=   	p_history_data.information138	;
	p_assignment_data.ass_attribute13	  	:=   	p_history_data.information139	;
	p_assignment_data.ass_attribute14	  	:=   	p_history_data.information140	;
	p_assignment_data.ass_attribute15	  	:=   	p_history_data.information141	;
	p_assignment_data.ass_attribute16	  	:=   	p_history_data.information142	;
	p_assignment_data.ass_attribute17	  	:=   	p_history_data.information143	;
	p_assignment_data.ass_attribute18	  	:=   	p_history_data.information144	;
	p_assignment_data.ass_attribute19	  	:=   	p_history_data.information145	;
	p_assignment_data.ass_attribute20	  	:=   	p_history_data.information146	;
	p_assignment_data.ass_attribute21	  	:=   	p_history_data.information147	;
	p_assignment_data.ass_attribute22	  	:=   	p_history_data.information148	;
	p_assignment_data.ass_attribute23	  	:=   	p_history_data.information149	;
	p_assignment_data.ass_attribute24	  	:=   	p_history_data.information150	;
	p_assignment_data.ass_attribute25	  	:=   	p_history_data.information151	;
	p_assignment_data.ass_attribute26	  	:=   	p_history_data.information152	;
	p_assignment_data.ass_attribute27	  	:=   	p_history_data.information153	;
	p_assignment_data.ass_attribute28	  	:=   	p_history_data.information154	;
	p_assignment_data.ass_attribute29	  	:=   	p_history_data.information155	;
	p_assignment_data.ass_attribute30	  	:=   	p_history_data.information156;
--	p_assignment_data.object_version_number	:=   	p_history_data.information162	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_assignment_data := l_assignment_data;
     raise;

end conv_to_asgn_rg;



Procedure conv_to_peopleei_rg ( p_peopleei_h_v   in	ghr_people_extra_info_h_v%rowtype,
                                p_peopleei_data  out nocopy	per_people_extra_info%rowtype) is

	l_peopleei_data	per_people_extra_info%rowtype;
	l_proc		varchar2(30):='conv_to_peopleei_rg';
Begin

	hr_utility.set_location('Entering : '|| l_proc, 100);
	conv_to_peopleei_rg(
                       p_person_extra_info_id            => p_peopleei_h_v.person_extra_info_id            ,
                       p_person_id                       => p_peopleei_h_v.person_id                       ,
                       p_information_type                => p_peopleei_h_v.information_type                ,
                       p_request_id                      => p_peopleei_h_v.request_id                      ,
                       p_program_application_id          => p_peopleei_h_v.program_application_id          ,
                       p_program_id                      => p_peopleei_h_v.program_id                      ,
                       p_program_update_date             => p_peopleei_h_v.program_update_date             ,
                       p_pei_attribute_category          => p_peopleei_h_v.pei_attribute_category          ,
                       p_pei_attribute1                  => p_peopleei_h_v.pei_attribute1                  ,
                       p_pei_attribute2                  => p_peopleei_h_v.pei_attribute2                  ,
                       p_pei_attribute3                  => p_peopleei_h_v.pei_attribute3                  ,
                       p_pei_attribute4                  => p_peopleei_h_v.pei_attribute4                  ,
                       p_pei_attribute5                  => p_peopleei_h_v.pei_attribute5                  ,
                       p_pei_attribute6                  => p_peopleei_h_v.pei_attribute6                  ,
                       p_pei_attribute7                  => p_peopleei_h_v.pei_attribute7                  ,
                       p_pei_attribute8                  => p_peopleei_h_v.pei_attribute8                  ,
                       p_pei_attribute9                  => p_peopleei_h_v.pei_attribute9                  ,
                       p_pei_attribute10                 => p_peopleei_h_v.pei_attribute10                 ,
                       p_pei_attribute11                 => p_peopleei_h_v.pei_attribute11                 ,
                       p_pei_attribute12                 => p_peopleei_h_v.pei_attribute12                 ,
                       p_pei_attribute13                 => p_peopleei_h_v.pei_attribute13                 ,
                       p_pei_attribute14                 => p_peopleei_h_v.pei_attribute14                 ,
                       p_pei_attribute15                 => p_peopleei_h_v.pei_attribute15                 ,
                       p_pei_attribute16                 => p_peopleei_h_v.pei_attribute16                 ,
                       p_pei_attribute17                 => p_peopleei_h_v.pei_attribute17                 ,
                       p_pei_attribute18                 => p_peopleei_h_v.pei_attribute18                 ,
                       p_pei_attribute19                 => p_peopleei_h_v.pei_attribute19                 ,
                       p_pei_attribute20                 => p_peopleei_h_v.pei_attribute20                 ,
                       p_pei_information_category        => p_peopleei_h_v.pei_information_category        ,
                       p_pei_information1                => p_peopleei_h_v.pei_information1                ,
                       p_pei_information2                => p_peopleei_h_v.pei_information2                ,
                       p_pei_information3                => p_peopleei_h_v.pei_information3                ,
                       p_pei_information4                => p_peopleei_h_v.pei_information4                ,
                       p_pei_information5                => p_peopleei_h_v.pei_information5                ,
                       p_pei_information6                => p_peopleei_h_v.pei_information6                ,
                       p_pei_information7                => p_peopleei_h_v.pei_information7                ,
                       p_pei_information8                => p_peopleei_h_v.pei_information8                ,
                       p_pei_information9                => p_peopleei_h_v.pei_information9                ,
                       p_pei_information10               => p_peopleei_h_v.pei_information10               ,
                       p_pei_information11               => p_peopleei_h_v.pei_information11               ,
                       p_pei_information12               => p_peopleei_h_v.pei_information12               ,
                       p_pei_information13               => p_peopleei_h_v.pei_information13               ,
                       p_pei_information14               => p_peopleei_h_v.pei_information14               ,
                       p_pei_information15               => p_peopleei_h_v.pei_information15               ,
                       p_pei_information16               => p_peopleei_h_v.pei_information16               ,
                       p_pei_information17               => p_peopleei_h_v.pei_information17               ,
                       p_pei_information18               => p_peopleei_h_v.pei_information18               ,
                       p_pei_information19               => p_peopleei_h_v.pei_information19               ,
                       p_pei_information20               => p_peopleei_h_v.pei_information20               ,
                       p_pei_information21               => p_peopleei_h_v.pei_information21               ,
                       p_pei_information22               => p_peopleei_h_v.pei_information22               ,
                       p_pei_information23               => p_peopleei_h_v.pei_information23               ,
                       p_pei_information24               => p_peopleei_h_v.pei_information24               ,
                       p_pei_information25               => p_peopleei_h_v.pei_information25               ,
                       p_pei_information26               => p_peopleei_h_v.pei_information26               ,
                       p_pei_information27               => p_peopleei_h_v.pei_information27               ,
                       p_pei_information28               => p_peopleei_h_v.pei_information28               ,
                       p_pei_information29               => p_peopleei_h_v.pei_information29               ,
                       p_pei_information30               => p_peopleei_h_v.pei_information30               ,
--                       p_object_version_number           => p_peopleei_h_v.object_version_number           ,
			     p_peopleei_data			   => l_peopleei_data);
	p_peopleei_data	:= l_peopleei_data;

	hr_utility.set_location('Leaving : '|| l_proc, 200);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_peopleei_data := NULL;
     raise;

End conv_to_peopleei_rg;



-- Procedure conv_to_peopleei_rg copies the individuual fields supplied as parameters
-- to the per_peopleei type record.
procedure conv_to_peopleei_rg  (
	p_person_extra_info_id      in per_people_extra_info.person_extra_info_id%type       default null,
	p_person_id                 in per_people_extra_info.person_id%type                  default null,
	p_information_type          in per_people_extra_info.information_type%type           default null,
	p_request_id                in per_people_extra_info.request_id%type                 default null,
	p_program_application_id    in per_people_extra_info.program_application_id%type     default null,
	p_program_id                in per_people_extra_info.program_id%type                 default null,
	p_program_update_date       in per_people_extra_info.program_update_date%type        default null,
	p_pei_attribute_category    in per_people_extra_info.pei_attribute_category%type     default null,
	p_pei_attribute1            in per_people_extra_info.pei_attribute1%type             default null,
	p_pei_attribute2            in per_people_extra_info.pei_attribute2%type             default null,
	p_pei_attribute3            in per_people_extra_info.pei_attribute3%type             default null,
	p_pei_attribute4            in per_people_extra_info.pei_attribute4%type             default null,
	p_pei_attribute5            in per_people_extra_info.pei_attribute5%type             default null,
	p_pei_attribute6            in per_people_extra_info.pei_attribute6%type             default null,
	p_pei_attribute7            in per_people_extra_info.pei_attribute7%type             default null,
	p_pei_attribute8            in per_people_extra_info.pei_attribute8%type             default null,
	p_pei_attribute9            in per_people_extra_info.pei_attribute9%type             default null,
	p_pei_attribute10           in per_people_extra_info.pei_attribute10%type            default null,
	p_pei_attribute11           in per_people_extra_info.pei_attribute11%type            default null,
	p_pei_attribute12           in per_people_extra_info.pei_attribute12%type            default null,
	p_pei_attribute13           in per_people_extra_info.pei_attribute13%type            default null,
	p_pei_attribute14           in per_people_extra_info.pei_attribute14%type            default null,
	p_pei_attribute15           in per_people_extra_info.pei_attribute15%type            default null,
	p_pei_attribute16           in per_people_extra_info.pei_attribute16%type            default null,
	p_pei_attribute17           in per_people_extra_info.pei_attribute17%type            default null,
	p_pei_attribute18           in per_people_extra_info.pei_attribute18%type            default null,
	p_pei_attribute19           in per_people_extra_info.pei_attribute19%type            default null,
	p_pei_attribute20           in per_people_extra_info.pei_attribute20%type            default null,
	p_pei_information_category  in per_people_extra_info.pei_information_category%type   default null,
	p_pei_information1          in per_people_extra_info.pei_information1%type           default null,
	p_pei_information2          in per_people_extra_info.pei_information2%type           default null,
	p_pei_information3          in per_people_extra_info.pei_information3%type           default null,
	p_pei_information4          in per_people_extra_info.pei_information4%type           default null,
	p_pei_information5          in per_people_extra_info.pei_information5%type           default null,
	p_pei_information6          in per_people_extra_info.pei_information6%type           default null,
	p_pei_information7          in per_people_extra_info.pei_information7%type           default null,
	p_pei_information8          in per_people_extra_info.pei_information8%type           default null,
	p_pei_information9          in per_people_extra_info.pei_information9%type           default null,
	p_pei_information10         in per_people_extra_info.pei_information10%type          default null,
	p_pei_information11         in per_people_extra_info.pei_information11%type          default null,
	p_pei_information12         in per_people_extra_info.pei_information12%type          default null,
	p_pei_information13         in per_people_extra_info.pei_information13%type          default null,
	p_pei_information14         in per_people_extra_info.pei_information14%type          default null,
	p_pei_information15         in per_people_extra_info.pei_information15%type          default null,
	p_pei_information16         in per_people_extra_info.pei_information16%type          default null,
	p_pei_information17         in per_people_extra_info.pei_information17%type          default null,
	p_pei_information18         in per_people_extra_info.pei_information18%type          default null,
	p_pei_information19         in per_people_extra_info.pei_information19%type          default null,
	p_pei_information20         in per_people_extra_info.pei_information20%type          default null,
	p_pei_information21         in per_people_extra_info.pei_information21%type          default null,
	p_pei_information22         in per_people_extra_info.pei_information22%type          default null,
	p_pei_information23         in per_people_extra_info.pei_information23%type          default null,
	p_pei_information24         in per_people_extra_info.pei_information24%type          default null,
	p_pei_information25         in per_people_extra_info.pei_information25%type          default null,
	p_pei_information26         in per_people_extra_info.pei_information26%type          default null,
	p_pei_information27         in per_people_extra_info.pei_information27%type          default null,
	p_pei_information28         in per_people_extra_info.pei_information28%type          default null,
	p_pei_information29         in per_people_extra_info.pei_information29%type          default null,
	p_pei_information30         in per_people_extra_info.pei_information30%type          default null,
--	p_object_version_number     in per_people_extra_info.object_version_number%type      default null,
	p_peopleei_data	    	in out nocopy per_people_extra_info%rowtype  )  as

	l_proc	varchar2(30):= 'conv_to_peopleei_rg ';
        l_peopleei_data   per_people_extra_info%rowtype;

begin

        l_peopleei_data :=p_peopleei_data; --NOCOPY CHANGES

	hr_utility.set_location('Entering:'|| l_proc, 5);
	copy_field_value( p_source_field =>  p_person_extra_info_id,
				p_target_field =>  p_peopleei_data.person_extra_info_id);
	copy_field_value( p_source_field =>  p_person_id,
				p_target_field =>  p_peopleei_data.person_id);
	copy_field_value( p_source_field =>  p_information_type,
				p_target_field =>  p_peopleei_data.information_type);
	copy_field_value( p_source_field =>  p_request_id,
				p_target_field =>  p_peopleei_data.request_id);
	copy_field_value( p_source_field =>  p_program_application_id,
				p_target_field =>  p_peopleei_data.program_application_id);
	copy_field_value( p_source_field =>  p_program_id,
				p_target_field =>  p_peopleei_data.program_id);
	copy_field_value( p_source_field =>  p_program_update_date,
				p_target_field =>  p_peopleei_data.program_update_date);
	copy_field_value( p_source_field =>  p_pei_attribute_category,
				p_target_field =>  p_peopleei_data.pei_attribute_category);
	copy_field_value( p_source_field =>  p_pei_attribute1,
				p_target_field =>  p_peopleei_data.pei_attribute1);
	copy_field_value( p_source_field =>  p_pei_attribute2,
				p_target_field =>  p_peopleei_data.pei_attribute2);
	copy_field_value( p_source_field =>  p_pei_attribute3,
				p_target_field =>  p_peopleei_data.pei_attribute3);
	copy_field_value( p_source_field =>  p_pei_attribute4,
				p_target_field =>  p_peopleei_data.pei_attribute4);
	copy_field_value( p_source_field =>  p_pei_attribute5,
				p_target_field =>  p_peopleei_data.pei_attribute5);
	copy_field_value( p_source_field =>  p_pei_attribute6,
				p_target_field =>  p_peopleei_data.pei_attribute6);
	copy_field_value( p_source_field =>  p_pei_attribute7,
				p_target_field =>  p_peopleei_data.pei_attribute7);
	copy_field_value( p_source_field =>  p_pei_attribute8,
				p_target_field =>  p_peopleei_data.pei_attribute8);
	copy_field_value( p_source_field =>  p_pei_attribute9,
				p_target_field =>  p_peopleei_data.pei_attribute9);
	copy_field_value( p_source_field =>  p_pei_attribute10,
				p_target_field =>  p_peopleei_data.pei_attribute10);
	copy_field_value( p_source_field =>  p_pei_attribute11,
				p_target_field =>  p_peopleei_data.pei_attribute11);
	copy_field_value( p_source_field =>  p_pei_attribute12,
				p_target_field =>  p_peopleei_data.pei_attribute12);
	copy_field_value( p_source_field =>  p_pei_attribute13,
				p_target_field =>  p_peopleei_data.pei_attribute13);
	copy_field_value( p_source_field =>  p_pei_attribute14,
				p_target_field =>  p_peopleei_data.pei_attribute14);
	copy_field_value( p_source_field =>  p_pei_attribute15,
				p_target_field =>  p_peopleei_data.pei_attribute15);
	copy_field_value( p_source_field =>  p_pei_attribute16,
				p_target_field =>  p_peopleei_data.pei_attribute16);
	copy_field_value( p_source_field =>  p_pei_attribute17,
				p_target_field =>  p_peopleei_data.pei_attribute17);
	copy_field_value( p_source_field =>  p_pei_attribute18,
				p_target_field =>  p_peopleei_data.pei_attribute18);
	copy_field_value( p_source_field =>  p_pei_attribute19,
				p_target_field =>  p_peopleei_data.pei_attribute19);
	copy_field_value( p_source_field =>  p_pei_attribute20,
				p_target_field =>  p_peopleei_data.pei_attribute20);
	copy_field_value( p_source_field =>  p_pei_information_category,
				p_target_field =>  p_peopleei_data.pei_information_category);
	copy_field_value( p_source_field =>  p_pei_information1,
				p_target_field =>  p_peopleei_data.pei_information1);
	copy_field_value( p_source_field =>  p_pei_information2,
				p_target_field =>  p_peopleei_data.pei_information2);
	copy_field_value( p_source_field =>  p_pei_information3,
				p_target_field =>  p_peopleei_data.pei_information3);
	copy_field_value( p_source_field =>  p_pei_information4,
				p_target_field =>  p_peopleei_data.pei_information4);
	copy_field_value( p_source_field =>  p_pei_information5,
				p_target_field =>  p_peopleei_data.pei_information5);
	copy_field_value( p_source_field =>  p_pei_information6,
				p_target_field =>  p_peopleei_data.pei_information6);
	copy_field_value( p_source_field =>  p_pei_information7,
				p_target_field =>  p_peopleei_data.pei_information7);
	copy_field_value( p_source_field =>  p_pei_information8,
				p_target_field =>  p_peopleei_data.pei_information8);
	copy_field_value( p_source_field =>  p_pei_information9,
				p_target_field =>  p_peopleei_data.pei_information9);
	copy_field_value( p_source_field =>  p_pei_information10,
				p_target_field =>  p_peopleei_data.pei_information10);
	copy_field_value( p_source_field =>  p_pei_information11,
				p_target_field =>  p_peopleei_data.pei_information11);
	copy_field_value( p_source_field =>  p_pei_information12,
				p_target_field =>  p_peopleei_data.pei_information12);
	copy_field_value( p_source_field =>  p_pei_information13,
				p_target_field =>  p_peopleei_data.pei_information13);
	copy_field_value( p_source_field =>  p_pei_information14,
				p_target_field =>  p_peopleei_data.pei_information14);
	copy_field_value( p_source_field =>  p_pei_information15,
				p_target_field =>  p_peopleei_data.pei_information15);
	copy_field_value( p_source_field =>  p_pei_information16,
				p_target_field =>  p_peopleei_data.pei_information16);
	copy_field_value( p_source_field =>  p_pei_information17,
				p_target_field =>  p_peopleei_data.pei_information17);
	copy_field_value( p_source_field =>  p_pei_information18,
				p_target_field =>  p_peopleei_data.pei_information18);
	copy_field_value( p_source_field =>  p_pei_information19,
				p_target_field =>  p_peopleei_data.pei_information19);
	copy_field_value( p_source_field =>  p_pei_information20,
				p_target_field =>  p_peopleei_data.pei_information20);
	copy_field_value( p_source_field =>  p_pei_information21,
				p_target_field =>  p_peopleei_data.pei_information21);
	copy_field_value( p_source_field =>  p_pei_information22,
				p_target_field =>  p_peopleei_data.pei_information22);
	copy_field_value( p_source_field =>  p_pei_information23,
				p_target_field =>  p_peopleei_data.pei_information23);
	copy_field_value( p_source_field =>  p_pei_information24,
				p_target_field =>  p_peopleei_data.pei_information24);
	copy_field_value( p_source_field =>  p_pei_information25,
				p_target_field =>  p_peopleei_data.pei_information25);
	copy_field_value( p_source_field =>  p_pei_information26,
				p_target_field =>  p_peopleei_data.pei_information26);
	copy_field_value( p_source_field =>  p_pei_information27,
				p_target_field =>  p_peopleei_data.pei_information27);
	copy_field_value( p_source_field =>  p_pei_information28,
				p_target_field =>  p_peopleei_data.pei_information28);
	copy_field_value( p_source_field =>  p_pei_information29,
				p_target_field =>  p_peopleei_data.pei_information29);
	copy_field_value( p_source_field =>  p_pei_information30,
				p_target_field =>  p_peopleei_data.pei_information30);
--	copy_field_value( p_source_field =>  p_object_version_number,
--				p_target_field =>  p_peopleei_data.object_version_number);

	hr_utility.set_location('Leaving:'|| l_proc, 5);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_peopleei_data := l_peopleei_data;
     raise;

End conv_to_peopleei_rg;



-- procedure conv_peopleei_rg_to_hist_rg converts the  per_people_extra_info record type
-- to ghr_pa_history record type
Procedure conv_peopleei_rg_to_hist_rg(
	p_people_ei_data		    in  per_people_extra_info%rowtype,
	p_history_data		in out nocopy  ghr_pa_history%rowtype) as

	l_proc	 varchar2(30) := 'conv_peopleei_rg_to_hist_rg';
        l_history_data   ghr_pa_history%rowtype;
begin

        l_history_data := p_history_data;  --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);
	p_history_data.person_id        := p_people_ei_data.person_id	;
	p_history_data.information1	  := p_people_ei_data.person_extra_info_id	;
	p_history_data.information4	  := p_people_ei_data.person_id	;
	p_history_data.information5	  := p_people_ei_data.information_type	;
	p_history_data.information6	  := p_people_ei_data.pei_information_category	;
	p_history_data.information7	  := p_people_ei_data.pei_information1	;
	p_history_data.information8	  := p_people_ei_data.pei_information2	;
	p_history_data.information9	  := p_people_ei_data.pei_information3	;
	p_history_data.information10	  := p_people_ei_data.pei_information4	;
	p_history_data.information11	  := p_people_ei_data.pei_information5	;
	p_history_data.information12	  := p_people_ei_data.pei_information6	;
	p_history_data.information13	  := p_people_ei_data.pei_information7	;
	p_history_data.information14	  := p_people_ei_data.pei_information8	;
	p_history_data.information15	  := p_people_ei_data.pei_information9	;
	p_history_data.information16	  := p_people_ei_data.pei_information10	;
	p_history_data.information17	  := p_people_ei_data.pei_information11	;
	p_history_data.information18	  := p_people_ei_data.pei_information12	;
	p_history_data.information19	  := p_people_ei_data.pei_information13	;
	p_history_data.information20	  := p_people_ei_data.pei_information14	;
	p_history_data.information21	  := p_people_ei_data.pei_information15	;
	p_history_data.information22	  := p_people_ei_data.pei_information16	;
	p_history_data.information23	  := p_people_ei_data.pei_information17	;
	p_history_data.information24	  := p_people_ei_data.pei_information18	;
	p_history_data.information25	  := p_people_ei_data.pei_information19	;
	p_history_data.information26	  := p_people_ei_data.pei_information20	;
	p_history_data.information27	  := p_people_ei_data.pei_information21	;
	p_history_data.information28	  := p_people_ei_data.pei_information22	;
	p_history_data.information29	  := p_people_ei_data.pei_information23	;
	p_history_data.information30	  := p_people_ei_data.pei_information24	;
	p_history_data.information31	  := p_people_ei_data.pei_information25	;
	p_history_data.information32	  := p_people_ei_data.pei_information26	;
	p_history_data.information33	  := p_people_ei_data.pei_information27	;
	p_history_data.information34	  := p_people_ei_data.pei_information28	;
	p_history_data.information35	  := p_people_ei_data.pei_information29	;
	p_history_data.information36	  := p_people_ei_data.pei_information30	;
	p_history_data.information121	  := p_people_ei_data.request_id	;
	p_history_data.information122	  := p_people_ei_data.program_application_id	;
	p_history_data.information123	  := p_people_ei_data.program_id	;
	p_history_data.information124	  := to_char(p_people_ei_data.program_update_date, g_hist_date_format)	;
	p_history_data.information125	  := p_people_ei_data.pei_attribute_category	;
	p_history_data.information126	  := p_people_ei_data.pei_attribute1	;
	p_history_data.information127	  := p_people_ei_data.pei_attribute2	;
	p_history_data.information128	  := p_people_ei_data.pei_attribute3	;
	p_history_data.information129	  := p_people_ei_data.pei_attribute4	;
	p_history_data.information130	  := p_people_ei_data.pei_attribute5	;
	p_history_data.information131	  := p_people_ei_data.pei_attribute6	;
	p_history_data.information132	  := p_people_ei_data.pei_attribute7	;
	p_history_data.information133	  := p_people_ei_data.pei_attribute8	;
	p_history_data.information134	  := p_people_ei_data.pei_attribute9	;
	p_history_data.information135	  := p_people_ei_data.pei_attribute10	;
	p_history_data.information136	  := p_people_ei_data.pei_attribute11	;
	p_history_data.information137	  := p_people_ei_data.pei_attribute12	;
	p_history_data.information138	  := p_people_ei_data.pei_attribute13	;
	p_history_data.information139	  := p_people_ei_data.pei_attribute14	;
	p_history_data.information140	  := p_people_ei_data.pei_attribute15	;
	p_history_data.information141	  := p_people_ei_data.pei_attribute16	;
	p_history_data.information142	  := p_people_ei_data.pei_attribute17	;
	p_history_data.information143	  := p_people_ei_data.pei_attribute18	;
	p_history_data.information144	  := p_people_ei_data.pei_attribute19	;
	p_history_data.information145	  := p_people_ei_data.pei_attribute20	;
--	p_history_data.information146	  := p_people_ei_data.object_version_number	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_history_data := l_history_data;
     raise;


	-- rest of the fields are not yet mapped

end conv_peopleei_rg_to_hist_rg;

-- procedure conv_to_peopleei_rg converts the ghr_pa_history record type to
-- per_people_extra_info type
--
Procedure conv_to_peopleei_rg(
	p_history_data		    in ghr_pa_history%rowtype,
	p_people_ei_data		in out nocopy per_people_extra_info%rowtype ) as

	l_proc	 varchar2(30) := 'conv_to_peopleei_rg';
	l_people_ei_data    per_people_extra_info%rowtype;

begin

        l_people_ei_data :=p_people_ei_data; --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);
	p_people_ei_data.person_id	  	  	:=	p_history_data.person_id	;
	p_people_ei_data.person_extra_info_id 	:=	p_history_data.information1	;
	p_people_ei_data.person_id	  	  	:=	p_history_data.information4	;
	p_people_ei_data.information_type	  	:= 	p_history_data.information5	;
	p_people_ei_data.pei_information_category	:= 	p_history_data.information6	;
	p_people_ei_data.pei_information1	  	:= 	p_history_data.information7	;
	p_people_ei_data.pei_information2	  	:= 	p_history_data.information8	;
	p_people_ei_data.pei_information3	  	:= 	p_history_data.information9	;
	p_people_ei_data.pei_information4	  	:= 	p_history_data.information10	;
	p_people_ei_data.pei_information5	  	:= 	p_history_data.information11	;
	p_people_ei_data.pei_information6	  	:= 	p_history_data.information12	;
	p_people_ei_data.pei_information7	  	:= 	p_history_data.information13	;
	p_people_ei_data.pei_information8	  	:= 	p_history_data.information14	;
	p_people_ei_data.pei_information9	  	:= 	p_history_data.information15	;
	p_people_ei_data.pei_information10	  	:= 	p_history_data.information16	;
	p_people_ei_data.pei_information11	  	:= 	p_history_data.information17	;
	p_people_ei_data.pei_information12	  	:=	p_history_data.information18	;
	p_people_ei_data.pei_information13	  	:= 	p_history_data.information19	;
	p_people_ei_data.pei_information14	  	:= 	p_history_data.information20	;
	p_people_ei_data.pei_information15	  	:= 	p_history_data.information21	;
	p_people_ei_data.pei_information16	  	:= 	p_history_data.information22	;
	p_people_ei_data.pei_information17	  	:=	p_history_data.information23	;
	p_people_ei_data.pei_information18	  	:=	p_history_data.information24	;
	p_people_ei_data.pei_information19	  	:=	p_history_data.information25	;
	p_people_ei_data.pei_information20	  	:=	p_history_data.information26	;
	p_people_ei_data.pei_information21	  	:= 	p_history_data.information27	;
	p_people_ei_data.pei_information22	  	:= 	p_history_data.information28	;
	p_people_ei_data.pei_information23	  	:= 	p_history_data.information29	;
	p_people_ei_data.pei_information24	  	:= 	p_history_data.information30	;
	p_people_ei_data.pei_information25	  	:= 	p_history_data.information31	;
	p_people_ei_data.pei_information26	  	:= 	p_history_data.information32	;
	p_people_ei_data.pei_information27	  	:= 	p_history_data.information33	;
	p_people_ei_data.pei_information28	  	:= 	p_history_data.information34	;
	p_people_ei_data.pei_information29	  	:= 	p_history_data.information35	;
	p_people_ei_data.pei_information30	  	:= 	p_history_data.information36	;
	p_people_ei_data.request_id	  		:= 	p_history_data.information121	;
	p_people_ei_data.program_application_id	:= 	p_history_data.information122	;
	p_people_ei_data.program_id	  		:= 	p_history_data.information123	;
	p_people_ei_data.program_update_date  	:= 	to_date(p_history_data.information124, g_hist_date_format);
	p_people_ei_data.pei_attribute_category	:=	p_history_data.information125	;
	p_people_ei_data.pei_attribute1	  	:= 	p_history_data.information126	;
	p_people_ei_data.pei_attribute2	  	:= 	p_history_data.information127	;
	p_people_ei_data.pei_attribute3	  	:= 	p_history_data.information128	;
	p_people_ei_data.pei_attribute4	  	:= 	p_history_data.information129	;
	p_people_ei_data.pei_attribute5	  	:= 	p_history_data.information130	;
	p_people_ei_data.pei_attribute6	  	:=	p_history_data.information131	;
	p_people_ei_data.pei_attribute7	  	:= 	p_history_data.information132	;
	p_people_ei_data.pei_attribute8	  	:= 	p_history_data.information133	;
	p_people_ei_data.pei_attribute9	  	:= 	p_history_data.information134	;
	p_people_ei_data.pei_attribute10	  	:= 	p_history_data.information135	;
	p_people_ei_data.pei_attribute11	  	:= 	p_history_data.information136	;
	p_people_ei_data.pei_attribute12	  	:= 	p_history_data.information137	;
	p_people_ei_data.pei_attribute13	  	:= 	p_history_data.information138	;
	p_people_ei_data.pei_attribute14	  	:= 	p_history_data.information139	;
	p_people_ei_data.pei_attribute15	  	:= 	p_history_data.information140	;
	p_people_ei_data.pei_attribute16	  	:= 	p_history_data.information141	;
	p_people_ei_data.pei_attribute17	  	:= 	p_history_data.information142	;
	p_people_ei_data.pei_attribute18	  	:= 	p_history_data.information143	;
	p_people_ei_data.pei_attribute19	  	:= 	p_history_data.information144	;
	p_people_ei_data.pei_attribute20	  	:= 	p_history_data.information145	;
--	p_people_ei_data.object_version_number	:= 	p_history_data.information146	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
     p_people_ei_data := l_people_ei_data;
     raise;


	-- rest of the fields are not yet mapped

end conv_to_peopleei_rg;



-- Procedure conv_to_positionei_rg copies the individual fields supplied as parameters
-- to the per_position_extra_info type record.

Procedure conv_to_positionei_rg(
	p_position_extra_info_id         in per_position_extra_info.position_extra_info_id%type       default null,
	p_position_id                    in per_position_extra_info.position_id%type                  default null,
	p_information_type               in per_position_extra_info.information_type%type             default null,
	p_request_id                     in per_position_extra_info.request_id%type                   default null,
	p_program_application_id         in per_position_extra_info.program_application_id%type       default null,
	p_program_id                     in per_position_extra_info.program_id%type                   default null,
	p_program_update_date            in per_position_extra_info.program_update_date%type          default null,
	p_poei_attribute_category        in per_position_extra_info.poei_attribute_category%type      default null,
	p_poei_attribute1                in per_position_extra_info.poei_attribute1%type              default null,
	p_poei_attribute2                in per_position_extra_info.poei_attribute2%type              default null,
	p_poei_attribute3                in per_position_extra_info.poei_attribute3%type              default null,
	p_poei_attribute4                in per_position_extra_info.poei_attribute4%type              default null,
	p_poei_attribute5                in per_position_extra_info.poei_attribute5%type              default null,
	p_poei_attribute6                in per_position_extra_info.poei_attribute6%type              default null,
	p_poei_attribute7                in per_position_extra_info.poei_attribute7%type              default null,
	p_poei_attribute8                in per_position_extra_info.poei_attribute8%type              default null,
	p_poei_attribute9                in per_position_extra_info.poei_attribute9%type              default null,
	p_poei_attribute10               in per_position_extra_info.poei_attribute10%type             default null,
	p_poei_attribute11               in per_position_extra_info.poei_attribute11%type             default null,
	p_poei_attribute12               in per_position_extra_info.poei_attribute12%type             default null,
	p_poei_attribute13               in per_position_extra_info.poei_attribute13%type             default null,
	p_poei_attribute14               in per_position_extra_info.poei_attribute14%type             default null,
	p_poei_attribute15               in per_position_extra_info.poei_attribute15%type             default null,
	p_poei_attribute16               in per_position_extra_info.poei_attribute16%type             default null,
	p_poei_attribute17               in per_position_extra_info.poei_attribute17%type             default null,
	p_poei_attribute18               in per_position_extra_info.poei_attribute18%type             default null,
	p_poei_attribute19               in per_position_extra_info.poei_attribute19%type             default null,
	p_poei_attribute20               in per_position_extra_info.poei_attribute20%type             default null,
	p_poei_information_category      in per_position_extra_info.poei_information_category%type    default null,
	p_poei_information1              in per_position_extra_info.poei_information1%type            default null,
	p_poei_information2              in per_position_extra_info.poei_information2%type            default null,
	p_poei_information3              in per_position_extra_info.poei_information3%type            default null,
	p_poei_information4              in per_position_extra_info.poei_information4%type            default null,
	p_poei_information5              in per_position_extra_info.poei_information5%type            default null,
	p_poei_information6              in per_position_extra_info.poei_information6%type            default null,
	p_poei_information7              in per_position_extra_info.poei_information7%type            default null,
	p_poei_information8              in per_position_extra_info.poei_information8%type            default null,
	p_poei_information9              in per_position_extra_info.poei_information9%type            default null,
	p_poei_information10             in per_position_extra_info.poei_information10%type           default null,
	p_poei_information11             in per_position_extra_info.poei_information11%type           default null,
	p_poei_information12             in per_position_extra_info.poei_information12%type           default null,
	p_poei_information13             in per_position_extra_info.poei_information13%type           default null,
	p_poei_information14             in per_position_extra_info.poei_information14%type           default null,
	p_poei_information15             in per_position_extra_info.poei_information15%type           default null,
	p_poei_information16             in per_position_extra_info.poei_information16%type           default null,
	p_poei_information17             in per_position_extra_info.poei_information17%type           default null,
	p_poei_information18             in per_position_extra_info.poei_information18%type           default null,
	p_poei_information19             in per_position_extra_info.poei_information19%type           default null,
	p_poei_information20             in per_position_extra_info.poei_information20%type           default null,
	p_poei_information21             in per_position_extra_info.poei_information21%type           default null,
	p_poei_information22             in per_position_extra_info.poei_information22%type           default null,
	p_poei_information23             in per_position_extra_info.poei_information23%type           default null,
	p_poei_information24             in per_position_extra_info.poei_information24%type           default null,
	p_poei_information25             in per_position_extra_info.poei_information25%type           default null,
	p_poei_information26             in per_position_extra_info.poei_information26%type           default null,
	p_poei_information27             in per_position_extra_info.poei_information27%type           default null,
	p_poei_information28             in per_position_extra_info.poei_information28%type           default null,
	p_poei_information29             in per_position_extra_info.poei_information29%type           default null,
	p_poei_information30             in per_position_extra_info.poei_information30%type           default null,
--	p_object_version_number          in per_position_extra_info.object_version_number%type        default null,
	p_position_extra_info_data   in out nocopy per_position_extra_info%rowtype  )  as

	l_proc	varchar2(30):='conv_to_positionei_rg';
	l_position_extra_info_data  per_position_extra_info%rowtype;

begin

        l_position_extra_info_data :=p_position_extra_info_data; --NOCOPY CHANGES

 	hr_utility.set_location('Entering:'|| l_proc, 5);
	copy_field_value( p_source_field =>  p_position_extra_info_id,
				p_target_field =>  p_position_extra_info_data.position_extra_info_id);
	copy_field_value( p_source_field =>  p_position_id,
				p_target_field =>  p_position_extra_info_data.position_id);
	copy_field_value( p_source_field =>  p_information_type,
				p_target_field =>  p_position_extra_info_data.information_type);
	copy_field_value( p_source_field =>  p_request_id,
				p_target_field =>  p_position_extra_info_data.request_id);
	copy_field_value( p_source_field =>  p_program_application_id,
				p_target_field =>  p_position_extra_info_data.program_application_id);
	copy_field_value( p_source_field =>  p_program_id,
				p_target_field =>  p_position_extra_info_data.program_id);
	copy_field_value( p_source_field =>  p_program_update_date,
				p_target_field =>  p_position_extra_info_data.program_update_date);
	copy_field_value( p_source_field =>  p_poei_attribute_category,
				p_target_field =>  p_position_extra_info_data.poei_attribute_category);
	copy_field_value( p_source_field =>  p_poei_attribute1,
				p_target_field =>  p_position_extra_info_data.poei_attribute1);
	copy_field_value( p_source_field =>  p_poei_attribute2,
				p_target_field =>  p_position_extra_info_data.poei_attribute2);
	copy_field_value( p_source_field =>  p_poei_attribute3,
				p_target_field =>  p_position_extra_info_data.poei_attribute3);
	copy_field_value( p_source_field =>  p_poei_attribute4,
				p_target_field =>  p_position_extra_info_data.poei_attribute4);
	copy_field_value( p_source_field =>  p_poei_attribute5,
				p_target_field =>  p_position_extra_info_data.poei_attribute5);
	copy_field_value( p_source_field =>  p_poei_attribute6,
				p_target_field =>  p_position_extra_info_data.poei_attribute6);
	copy_field_value( p_source_field =>  p_poei_attribute7,
				p_target_field =>  p_position_extra_info_data.poei_attribute7);
	copy_field_value( p_source_field =>  p_poei_attribute8,
				p_target_field =>  p_position_extra_info_data.poei_attribute8);
	copy_field_value( p_source_field =>  p_poei_attribute9,
				p_target_field =>  p_position_extra_info_data.poei_attribute9);
	copy_field_value( p_source_field =>  p_poei_attribute10,
				p_target_field =>  p_position_extra_info_data.poei_attribute10);
	copy_field_value( p_source_field =>  p_poei_attribute11,
				p_target_field =>  p_position_extra_info_data.poei_attribute11);
	copy_field_value( p_source_field =>  p_poei_attribute12,
				p_target_field =>  p_position_extra_info_data.poei_attribute12);
	copy_field_value( p_source_field =>  p_poei_attribute13,
				p_target_field =>  p_position_extra_info_data.poei_attribute13);
	copy_field_value( p_source_field =>  p_poei_attribute14,
				p_target_field =>  p_position_extra_info_data.poei_attribute14);
	copy_field_value( p_source_field =>  p_poei_attribute15,
				p_target_field =>  p_position_extra_info_data.poei_attribute15);
	copy_field_value( p_source_field =>  p_poei_attribute16,
				p_target_field =>  p_position_extra_info_data.poei_attribute16);
	copy_field_value( p_source_field =>  p_poei_attribute17,
				p_target_field =>  p_position_extra_info_data.poei_attribute17);
	copy_field_value( p_source_field =>  p_poei_attribute18,
				p_target_field =>  p_position_extra_info_data.poei_attribute18);
	copy_field_value( p_source_field =>  p_poei_attribute19,
				p_target_field =>  p_position_extra_info_data.poei_attribute19);
	copy_field_value( p_source_field =>  p_poei_attribute20,
				p_target_field =>  p_position_extra_info_data.poei_attribute20);
	copy_field_value( p_source_field =>  p_poei_information_category,
				p_target_field =>  p_position_extra_info_data.poei_information_category);
	copy_field_value( p_source_field =>  p_poei_information1,
				p_target_field =>  p_position_extra_info_data.poei_information1);
	copy_field_value( p_source_field =>  p_poei_information2,
				p_target_field =>  p_position_extra_info_data.poei_information2);
	copy_field_value( p_source_field =>  p_poei_information3,
				p_target_field =>  p_position_extra_info_data.poei_information3);
	copy_field_value( p_source_field =>  p_poei_information4,
				p_target_field =>  p_position_extra_info_data.poei_information4);
	copy_field_value( p_source_field =>  p_poei_information5,
				p_target_field =>  p_position_extra_info_data.poei_information5);
	copy_field_value( p_source_field =>  p_poei_information6,
				p_target_field =>  p_position_extra_info_data.poei_information6);
	copy_field_value( p_source_field =>  p_poei_information7,
				p_target_field =>  p_position_extra_info_data.poei_information7);
	copy_field_value( p_source_field =>  p_poei_information8,
				p_target_field =>  p_position_extra_info_data.poei_information8);
	copy_field_value( p_source_field =>  p_poei_information9,
				p_target_field =>  p_position_extra_info_data.poei_information9);
	copy_field_value( p_source_field =>  p_poei_information10,
				p_target_field =>  p_position_extra_info_data.poei_information10);
	copy_field_value( p_source_field =>  p_poei_information11,
				p_target_field =>  p_position_extra_info_data.poei_information11);
	copy_field_value( p_source_field =>  p_poei_information12,
				p_target_field =>  p_position_extra_info_data.poei_information12);
	copy_field_value( p_source_field =>  p_poei_information13,
				p_target_field =>  p_position_extra_info_data.poei_information13);
	copy_field_value( p_source_field =>  p_poei_information14,
				p_target_field =>  p_position_extra_info_data.poei_information14);
	copy_field_value( p_source_field =>  p_poei_information15,
				p_target_field =>  p_position_extra_info_data.poei_information15);
	copy_field_value( p_source_field =>  p_poei_information16,
				p_target_field =>  p_position_extra_info_data.poei_information16);
	copy_field_value( p_source_field =>  p_poei_information17,
				p_target_field =>  p_position_extra_info_data.poei_information17);
	copy_field_value( p_source_field =>  p_poei_information18,
				p_target_field =>  p_position_extra_info_data.poei_information18);
	copy_field_value( p_source_field =>  p_poei_information19,
				p_target_field =>  p_position_extra_info_data.poei_information19);
	copy_field_value( p_source_field =>  p_poei_information20,
				p_target_field =>  p_position_extra_info_data.poei_information20);
	copy_field_value( p_source_field =>  p_poei_information21,
				p_target_field =>  p_position_extra_info_data.poei_information21);
	copy_field_value( p_source_field =>  p_poei_information22,
				p_target_field =>  p_position_extra_info_data.poei_information22);
	copy_field_value( p_source_field =>  p_poei_information23,
				p_target_field =>  p_position_extra_info_data.poei_information23);
	copy_field_value( p_source_field =>  p_poei_information24,
				p_target_field =>  p_position_extra_info_data.poei_information24);
	copy_field_value( p_source_field =>  p_poei_information25,
				p_target_field =>  p_position_extra_info_data.poei_information25);
	copy_field_value( p_source_field =>  p_poei_information26,
				p_target_field =>  p_position_extra_info_data.poei_information26);
	copy_field_value( p_source_field =>  p_poei_information27,
				p_target_field =>  p_position_extra_info_data.poei_information27);
	copy_field_value( p_source_field =>  p_poei_information28,
				p_target_field =>  p_position_extra_info_data.poei_information28);
	copy_field_value( p_source_field =>  p_poei_information29,
				p_target_field =>  p_position_extra_info_data.poei_information29);
	copy_field_value( p_source_field =>  p_poei_information30,
				p_target_field =>  p_position_extra_info_data.poei_information30);
--	copy_field_value( p_source_field =>  p_object_version_number,
--				p_target_field =>  p_position_extra_info_data.object_version_number);
 	hr_utility.set_location('Leaving:'|| l_proc, 5);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_position_extra_info_data :=l_position_extra_info_data;
     raise;



end conv_to_positionei_rg;


-- Procedure conv_to_positionei_rg converts the
-- to the per_position_extra_info type record.
Procedure conv_to_positionei_rg
				( p_positionei_h_v    in	ghr_position_extra_info_h_v%rowtype,
                          p_positionei_data   out  nocopy	per_position_extra_info%rowtype) is

	l_positionei_data		per_position_extra_info%rowtype;
	l_proc			varchar2(30):='conv_to_positionei_rg';

Begin
	conv_to_positionei_rg(
			p_position_extra_info_id         =>  p_positionei_h_v.position_extra_info_id       ,
			p_position_id                    =>  p_positionei_h_v.position_id                  ,
			p_information_type               =>  p_positionei_h_v.information_type             ,
			p_request_id                     =>  p_positionei_h_v.request_id                   ,
			p_program_application_id         =>  p_positionei_h_v.program_application_id       ,
			p_program_id                     =>  p_positionei_h_v.program_id                   ,
			p_program_update_date            =>  p_positionei_h_v.program_update_date          ,
			p_poei_attribute_category        =>  p_positionei_h_v.poei_attribute_category      ,
			p_poei_attribute1                =>  p_positionei_h_v.poei_attribute1              ,
			p_poei_attribute2                =>  p_positionei_h_v.poei_attribute2              ,
			p_poei_attribute3                =>  p_positionei_h_v.poei_attribute3              ,
			p_poei_attribute4                =>  p_positionei_h_v.poei_attribute4              ,
			p_poei_attribute5                =>  p_positionei_h_v.poei_attribute5              ,
			p_poei_attribute6                =>  p_positionei_h_v.poei_attribute6              ,
			p_poei_attribute7                =>  p_positionei_h_v.poei_attribute7              ,
			p_poei_attribute8                =>  p_positionei_h_v.poei_attribute8              ,
			p_poei_attribute9                =>  p_positionei_h_v.poei_attribute9              ,
			p_poei_attribute10               =>  p_positionei_h_v.poei_attribute10             ,
			p_poei_attribute11               =>  p_positionei_h_v.poei_attribute11             ,
			p_poei_attribute12               =>  p_positionei_h_v.poei_attribute12             ,
			p_poei_attribute13               =>  p_positionei_h_v.poei_attribute13             ,
			p_poei_attribute14               =>  p_positionei_h_v.poei_attribute14             ,
			p_poei_attribute15               =>  p_positionei_h_v.poei_attribute15             ,
			p_poei_attribute16               =>  p_positionei_h_v.poei_attribute16             ,
			p_poei_attribute17               =>  p_positionei_h_v.poei_attribute17             ,
			p_poei_attribute18               =>  p_positionei_h_v.poei_attribute18             ,
			p_poei_attribute19               =>  p_positionei_h_v.poei_attribute19             ,
			p_poei_attribute20               =>  p_positionei_h_v.poei_attribute20             ,
			p_poei_information_category      =>  p_positionei_h_v.poei_information_category    ,
			p_poei_information1              =>  p_positionei_h_v.poei_information1            ,
			p_poei_information2              =>  p_positionei_h_v.poei_information2            ,
			p_poei_information3              =>  p_positionei_h_v.poei_information3            ,
			p_poei_information4              =>  p_positionei_h_v.poei_information4            ,
			p_poei_information5              =>  p_positionei_h_v.poei_information5            ,
			p_poei_information6              =>  p_positionei_h_v.poei_information6            ,
			p_poei_information7              =>  p_positionei_h_v.poei_information7            ,
			p_poei_information8              =>  p_positionei_h_v.poei_information8            ,
			p_poei_information9              =>  p_positionei_h_v.poei_information9            ,
			p_poei_information10             =>  p_positionei_h_v.poei_information10           ,
			p_poei_information11             =>  p_positionei_h_v.poei_information11           ,
			p_poei_information12             =>  p_positionei_h_v.poei_information12           ,
			p_poei_information13             =>  p_positionei_h_v.poei_information13           ,
			p_poei_information14             =>  p_positionei_h_v.poei_information14           ,
			p_poei_information15             =>  p_positionei_h_v.poei_information15           ,
			p_poei_information16             =>  p_positionei_h_v.poei_information16           ,
			p_poei_information17             =>  p_positionei_h_v.poei_information17           ,
			p_poei_information18             =>  p_positionei_h_v.poei_information18           ,
			p_poei_information19             =>  p_positionei_h_v.poei_information19           ,
			p_poei_information20             =>  p_positionei_h_v.poei_information20           ,
			p_poei_information21             =>  p_positionei_h_v.poei_information21           ,
			p_poei_information22             =>  p_positionei_h_v.poei_information22           ,
			p_poei_information23             =>  p_positionei_h_v.poei_information23           ,
			p_poei_information24             =>  p_positionei_h_v.poei_information24           ,
			p_poei_information25             =>  p_positionei_h_v.poei_information25           ,
			p_poei_information26             =>  p_positionei_h_v.poei_information26           ,
			p_poei_information27             =>  p_positionei_h_v.poei_information27           ,
			p_poei_information28             =>  p_positionei_h_v.poei_information28           ,
			p_poei_information29             =>  p_positionei_h_v.poei_information29           ,
			p_poei_information30             =>  p_positionei_h_v.poei_information30           ,
--			p_object_version_number          =>  p_positionei_h_v.object_version_number        ,
			p_position_extra_info_data	   =>  l_positionei_data  );
	p_positionei_data	:=	l_positionei_data;


  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
       p_positionei_data	:=NULL;
     raise;

End conv_to_positionei_rg;

-- procedure convt_positionei_rg_to_hist_rg converts the  per_element_entries record type to
-- ghr_pa_history record type
Procedure conv_positionei_rg_to_hist_rg(
	p_position_ei_data        in  per_position_extra_info%rowtype,
	p_history_data   	    in out nocopy ghr_pa_history%rowtype) as

	l_proc	 varchar2(30) := 'convert_position_ei_rg_hist_rg';
	l_history_data  ghr_pa_history%rowtype;

Begin

	l_history_data :=p_history_data; --NOCOPY CHANGES
	hr_utility.set_location('entering:'|| l_proc, 5);

	p_history_data.information1	  :=  	p_position_ei_data.position_extra_info_id	;
	p_history_data.information4	  :=  	p_position_ei_data.position_id	;
	p_history_data.information5	  :=  	p_position_ei_data.information_type	;
	p_history_data.information6	  :=  	p_position_ei_data.poei_information_category	;
	p_history_data.information7	  :=  	p_position_ei_data.poei_information1	;
	p_history_data.information8	  :=  	p_position_ei_data.poei_information2	;
	p_history_data.information9	  :=  	p_position_ei_data.poei_information3	;
	p_history_data.information10	  :=  	p_position_ei_data.poei_information4	;
	p_history_data.information11	  :=  	p_position_ei_data.poei_information5	;
	p_history_data.information12	  :=  	p_position_ei_data.poei_information6	;
	p_history_data.information13	  :=  	p_position_ei_data.poei_information7	;
	p_history_data.information14	  :=  	p_position_ei_data.poei_information8	;
	p_history_data.information15	  :=  	p_position_ei_data.poei_information9	;
	p_history_data.information16	  :=  	p_position_ei_data.poei_information10	;
	p_history_data.information17	  :=  	p_position_ei_data.poei_information11	;
	p_history_data.information18	  :=  	p_position_ei_data.poei_information12	;
	p_history_data.information19	  :=  	p_position_ei_data.poei_information13	;
	p_history_data.information20	  :=  	p_position_ei_data.poei_information14	;
	p_history_data.information21	  :=  	p_position_ei_data.poei_information15	;
	p_history_data.information22	  :=  	p_position_ei_data.poei_information16	;
	p_history_data.information23	  :=  	p_position_ei_data.poei_information17	;
	p_history_data.information24	  :=  	p_position_ei_data.poei_information18	;
	p_history_data.information25	  :=  	p_position_ei_data.poei_information19	;
	p_history_data.information26	  :=  	p_position_ei_data.poei_information20	;
	p_history_data.information27	  :=  	p_position_ei_data.poei_information21	;
	p_history_data.information28	  :=  	p_position_ei_data.poei_information22	;
	p_history_data.information29	  :=  	p_position_ei_data.poei_information23	;
	p_history_data.information30	  :=  	p_position_ei_data.poei_information24	;
	p_history_data.information31	  :=  	p_position_ei_data.poei_information25	;
	p_history_data.information32	  :=  	p_position_ei_data.poei_information26	;
	p_history_data.information33	  :=  	p_position_ei_data.poei_information27	;
	p_history_data.information34	  :=  	p_position_ei_data.poei_information28	;
	p_history_data.information35	  :=  	p_position_ei_data.poei_information29	;
	p_history_data.information36	  :=  	p_position_ei_data.poei_information30	;
	p_history_data.information121	  :=  	p_position_ei_data.request_id	;
	p_history_data.information122	  :=  	p_position_ei_data.program_application_id	;
	p_history_data.information123	  :=  	p_position_ei_data.program_id	;
	p_history_data.information124	  :=  	to_char(p_position_ei_data.program_update_date, g_hist_date_format)	;
	p_history_data.information125	  :=  	p_position_ei_data.poei_attribute_category	;
	p_history_data.information126	  :=  	p_position_ei_data.poei_attribute1	;
	p_history_data.information127	  :=  	p_position_ei_data.poei_attribute2	;
	p_history_data.information128	  :=  	p_position_ei_data.poei_attribute3	;
	p_history_data.information129	  :=  	p_position_ei_data.poei_attribute4	;
	p_history_data.information130	  :=  	p_position_ei_data.poei_attribute5	;
	p_history_data.information131	  :=  	p_position_ei_data.poei_attribute6	;
	p_history_data.information132	  :=  	p_position_ei_data.poei_attribute7	;
	p_history_data.information133	  :=  	p_position_ei_data.poei_attribute8	;
	p_history_data.information134	  :=  	p_position_ei_data.poei_attribute9	;
	p_history_data.information135	  :=  	p_position_ei_data.poei_attribute10	;
	p_history_data.information136	  :=  	p_position_ei_data.poei_attribute11	;
	p_history_data.information137	  :=  	p_position_ei_data.poei_attribute12	;
	p_history_data.information138	  :=  	p_position_ei_data.poei_attribute13	;
	p_history_data.information139	  :=  	p_position_ei_data.poei_attribute14	;
	p_history_data.information140	  :=  	p_position_ei_data.poei_attribute15	;
	p_history_data.information141	  :=  	p_position_ei_data.poei_attribute16	;
	p_history_data.information142	  :=  	p_position_ei_data.poei_attribute17	;
	p_history_data.information143	  :=  	p_position_ei_data.poei_attribute18	;
	p_history_data.information144	  :=  	p_position_ei_data.poei_attribute19	;
	p_history_data.information145	  :=  	p_position_ei_data.poei_attribute20	;
--	p_history_data.information146	  :=  	p_position_ei_data.object_version_number	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_history_data :=l_history_data ;
     raise;
End conv_positionei_rg_to_hist_rg;


-- procedure conv_to_positionei_rg converts the ghr_pa_history record type into
-- per_element_entries record type
Procedure conv_to_positionei_rg(
	p_history_data		in   ghr_pa_history%rowtype,
	p_position_ei_data      in  out nocopy per_position_extra_info%rowtype) as

	l_proc	 varchar2(30) := 'convert_position_ei_rg_hist_rg';
	l_position_ei_data	per_position_extra_info%rowtype;

Begin

        l_position_ei_data := p_position_ei_data; --NOCOPY CHANGES
	hr_utility.set_location('entering:'|| l_proc, 5);

	p_position_ei_data.position_extra_info_id	  := 	p_history_data.information1	;
	p_position_ei_data.position_id		  := 	p_history_data.information4	;
	p_position_ei_data.information_type		  := 	p_history_data.information5	;
	p_position_ei_data.poei_information_category:= 	p_history_data.information6	;
	p_position_ei_data.poei_information1	  :=  p_history_data.information7	;
	p_position_ei_data.poei_information2	  :=  p_history_data.information8	;
	p_position_ei_data.poei_information3	  :=  p_history_data.information9	;
	p_position_ei_data.poei_information4	  :=  p_history_data.information10	;
	p_position_ei_data.poei_information5	  :=  p_history_data.information11	;
	p_position_ei_data.poei_information6	  :=  p_history_data.information12	;
	p_position_ei_data.poei_information7	  :=  p_history_data.information13	;
	p_position_ei_data.poei_information8	  :=  p_history_data.information14	;
	p_position_ei_data.poei_information9	  :=  p_history_data.information15	;
	p_position_ei_data.poei_information10	  :=  p_history_data.information16	;
	p_position_ei_data.poei_information11	  :=  p_history_data.information17	;
	p_position_ei_data.poei_information12	  :=  p_history_data.information18	;
	p_position_ei_data.poei_information13	  :=  p_history_data.information19	;
	p_position_ei_data.poei_information14	  :=  p_history_data.information20	;
	p_position_ei_data.poei_information15	  :=  p_history_data.information21	;
	p_position_ei_data.poei_information16	  :=  p_history_data.information22	;
	p_position_ei_data.poei_information17	  :=  p_history_data.information23	;
	p_position_ei_data.poei_information18	  :=  p_history_data.information24	;
	p_position_ei_data.poei_information19	  :=  p_history_data.information25	;
	p_position_ei_data.poei_information20	  :=  p_history_data.information26	;
	p_position_ei_data.poei_information21	  :=  p_history_data.information27	;
	p_position_ei_data.poei_information22	  :=  p_history_data.information28	;
	p_position_ei_data.poei_information23	  :=  p_history_data.information29	;
	p_position_ei_data.poei_information24	  :=  p_history_data.information30	;
	p_position_ei_data.poei_information25	  :=  p_history_data.information31	;
	p_position_ei_data.poei_information26	  :=  p_history_data.information32	;
	p_position_ei_data.poei_information27	  :=  p_history_data.information33	;
	p_position_ei_data.poei_information28	  :=  p_history_data.information34	;
	p_position_ei_data.poei_information29	  :=  p_history_data.information35	;
	p_position_ei_data.poei_information30	  :=  p_history_data.information36	;
	p_position_ei_data.request_id	  		  :=  p_history_data.information121	;
	p_position_ei_data.program_application_id	  :=  p_history_data.information122	;
	p_position_ei_data.program_id			  :=  p_history_data.information123	;
	p_position_ei_data.program_update_date	  :=  to_date(p_history_data.information124, g_hist_date_format)	;
	p_position_ei_data.poei_attribute_category  := 	p_history_data.information125	;
	p_position_ei_data.poei_attribute1	  	  :=  p_history_data.information126	;
	p_position_ei_data.poei_attribute2		  :=  p_history_data.information127	;
	p_position_ei_data.poei_attribute3		  :=  p_history_data.information128	;
	p_position_ei_data.poei_attribute4		  :=  p_history_data.information129	;
	p_position_ei_data.poei_attribute5		  :=  p_history_data.information130	;
	p_position_ei_data.poei_attribute6		  :=  p_history_data.information131	;
	p_position_ei_data.poei_attribute7		  :=  p_history_data.information132	;
	p_position_ei_data.poei_attribute8		  :=  p_history_data.information133	;
	p_position_ei_data.poei_attribute9		  :=  p_history_data.information134	;
	p_position_ei_data.poei_attribute10		  :=  p_history_data.information135	;
	p_position_ei_data.poei_attribute11		  :=  p_history_data.information136	;
	p_position_ei_data.poei_attribute12		  :=  p_history_data.information137	;
	p_position_ei_data.poei_attribute13		  :=  p_history_data.information138	;
	p_position_ei_data.poei_attribute14		  :=  p_history_data.information139	;
	p_position_ei_data.poei_attribute15		  :=  p_history_data.information140	;
	p_position_ei_data.poei_attribute16		  :=  p_history_data.information141	;
	p_position_ei_data.poei_attribute17		  :=  p_history_data.information142	;
	p_position_ei_data.poei_attribute18		  :=  p_history_data.information143	;
	p_position_ei_data.poei_attribute19		  :=  p_history_data.information144	;
	p_position_ei_data.poei_attribute20		  :=  p_history_data.information145	;
--	p_position_ei_data.object_version_number	  :=  p_history_data.information146	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_position_ei_data :=l_position_ei_data ;
     raise;

End conv_to_positionei_rg;


-- Procedure conv_to_element_entry_rg copies the individual fields supplied as parameters
-- to the per_assignment_f type record.
--
Procedure conv_to_element_entry_rg(
	p_element_entry_id              in pay_element_entries_f.element_entry_id%type             default null,
	p_effective_start_date          in pay_element_entries_f.effective_start_date%type         default null,
	p_effective_end_date            in pay_element_entries_f.effective_end_date%type           default null,
	p_cost_allocation_keyflex_id    in pay_element_entries_f.cost_allocation_keyflex_id%type   default null,
	p_assignment_id                 in pay_element_entries_f.assignment_id%type                default null,
	p_updating_action_id            in pay_element_entries_f.updating_action_id%type           default null,
	p_element_link_id               in pay_element_entries_f.element_link_id%type              default null,
	p_original_entry_id             in pay_element_entries_f.original_entry_id%type            default null,
	p_creator_type                  in pay_element_entries_f.creator_type%type                 default null,
	p_entry_type                    in pay_element_entries_f.entry_type%type                   default null,
	p_comment_id                    in pay_element_entries_f.comment_id%type                   default null,
	p_creator_id                    in pay_element_entries_f.creator_id%type                   default null,
	p_reason                        in pay_element_entries_f.reason%type                       default null,
	p_target_entry_id               in pay_element_entries_f.target_entry_id%type              default null,
	p_attribute_category            in pay_element_entries_f.attribute_category%type           default null,
	p_attribute1                    in pay_element_entries_f.attribute1%type                   default null,
	p_attribute2                    in pay_element_entries_f.attribute2%type                   default null,
	p_attribute3                    in pay_element_entries_f.attribute3%type                   default null,
	p_attribute4                    in pay_element_entries_f.attribute4%type                   default null,
	p_attribute5                    in pay_element_entries_f.attribute5%type                   default null,
	p_attribute6                    in pay_element_entries_f.attribute6%type                   default null,
	p_attribute7                    in pay_element_entries_f.attribute7%type                   default null,
	p_attribute8                    in pay_element_entries_f.attribute8%type                   default null,
	p_attribute9                    in pay_element_entries_f.attribute9%type                   default null,
	p_attribute10                   in pay_element_entries_f.attribute10%type                  default null,
	p_attribute11                   in pay_element_entries_f.attribute11%type                  default null,
	p_attribute12                   in pay_element_entries_f.attribute12%type                  default null,
	p_attribute13                   in pay_element_entries_f.attribute13%type                  default null,
	p_attribute14                   in pay_element_entries_f.attribute14%type                  default null,
	p_attribute15                   in pay_element_entries_f.attribute15%type                  default null,
	p_attribute16                   in pay_element_entries_f.attribute16%type                  default null,
	p_attribute17                   in pay_element_entries_f.attribute17%type                  default null,
	p_attribute18                   in pay_element_entries_f.attribute18%type                  default null,
	p_attribute19                   in pay_element_entries_f.attribute19%type                  default null,
	p_attribute20                   in pay_element_entries_f.attribute20%type                  default null,
	p_subpriority                   in pay_element_entries_f.subpriority%type                  default null,
	p_personal_payment_method_id    in pay_element_entries_f.personal_payment_method_id%type   default null,
	p_date_earned                   in pay_element_entries_f.date_earned%type                  default null,
	p_element_entry_data	    in out nocopy pay_element_entries_f%rowtype  )  as


	l_proc	varchar2(30):=' conv_to_element_entry_rg ';
	l_element_entry_data	pay_element_entries_f%rowtype;

begin

        l_element_entry_data :=p_element_entry_data; --NOCOPY CHANGES
	hr_utility.set_location('Entering:'|| l_proc, 5);
	copy_field_value( p_source_field =>  p_element_entry_id,
				p_target_field =>  p_element_entry_data.element_entry_id);
	copy_field_value( p_source_field =>  p_effective_start_date,
				p_target_field =>  p_element_entry_data.effective_start_date);
	copy_field_value( p_source_field =>  p_effective_end_date,
				p_target_field =>  p_element_entry_data.effective_end_date);
	copy_field_value( p_source_field =>  p_cost_allocation_keyflex_id,
				p_target_field =>  p_element_entry_data.cost_allocation_keyflex_id);
	copy_field_value( p_source_field =>  p_assignment_id,
				p_target_field =>  p_element_entry_data.assignment_id);
	copy_field_value( p_source_field =>  p_updating_action_id,
				p_target_field =>  p_element_entry_data.updating_action_id);
	copy_field_value( p_source_field =>  p_element_link_id,
				p_target_field =>  p_element_entry_data.element_link_id);
	copy_field_value( p_source_field =>  p_original_entry_id,
				p_target_field =>  p_element_entry_data.original_entry_id);
	copy_field_value( p_source_field =>  p_creator_type,
				p_target_field =>  p_element_entry_data.creator_type);
	copy_field_value( p_source_field =>  p_entry_type,
				p_target_field =>  p_element_entry_data.entry_type);
	copy_field_value( p_source_field =>  p_comment_id,
				p_target_field =>  p_element_entry_data.comment_id);
	copy_field_value( p_source_field =>  p_creator_id,
				p_target_field =>  p_element_entry_data.creator_id);
	copy_field_value( p_source_field =>  p_reason,
				p_target_field =>  p_element_entry_data.reason);
	copy_field_value( p_source_field =>  p_target_entry_id,
				p_target_field =>  p_element_entry_data.target_entry_id);
	copy_field_value( p_source_field =>  p_attribute_category,
				p_target_field =>  p_element_entry_data.attribute_category);
	copy_field_value( p_source_field =>  p_attribute1,
				p_target_field =>  p_element_entry_data.attribute1);
	copy_field_value( p_source_field =>  p_attribute2,
				p_target_field =>  p_element_entry_data.attribute2);
	copy_field_value( p_source_field =>  p_attribute3,
				p_target_field =>  p_element_entry_data.attribute3);
	copy_field_value( p_source_field =>  p_attribute4,
				p_target_field =>  p_element_entry_data.attribute4);
	copy_field_value( p_source_field =>  p_attribute5,
				p_target_field =>  p_element_entry_data.attribute5);
	copy_field_value( p_source_field =>  p_attribute6,
				p_target_field =>  p_element_entry_data.attribute6);
	copy_field_value( p_source_field =>  p_attribute7,
				p_target_field =>  p_element_entry_data.attribute7);
	copy_field_value( p_source_field =>  p_attribute8,
				p_target_field =>  p_element_entry_data.attribute8);
	copy_field_value( p_source_field =>  p_attribute9,
				p_target_field =>  p_element_entry_data.attribute9);
	copy_field_value( p_source_field =>  p_attribute10,
				p_target_field =>  p_element_entry_data.attribute10);
	copy_field_value( p_source_field =>  p_attribute11,
				p_target_field =>  p_element_entry_data.attribute11);
	copy_field_value( p_source_field =>  p_attribute12,
				p_target_field =>  p_element_entry_data.attribute12);
	copy_field_value( p_source_field =>  p_attribute13,
				p_target_field =>  p_element_entry_data.attribute13);
	copy_field_value( p_source_field =>  p_attribute14,
				p_target_field =>  p_element_entry_data.attribute14);
	copy_field_value( p_source_field =>  p_attribute15,
				p_target_field =>  p_element_entry_data.attribute15);
	copy_field_value( p_source_field =>  p_attribute16,
				p_target_field =>  p_element_entry_data.attribute16);
	copy_field_value( p_source_field =>  p_attribute17,
				p_target_field =>  p_element_entry_data.attribute17);
	copy_field_value( p_source_field =>  p_attribute18,
				p_target_field =>  p_element_entry_data.attribute18);
	copy_field_value( p_source_field =>  p_attribute19,
				p_target_field =>  p_element_entry_data.attribute19);
	copy_field_value( p_source_field =>  p_attribute20,
				p_target_field =>  p_element_entry_data.attribute20);
	copy_field_value( p_source_field =>  p_subpriority,
				p_target_field =>  p_element_entry_data.subpriority);
	copy_field_value( p_source_field =>  p_personal_payment_method_id,
				p_target_field =>  p_element_entry_data.personal_payment_method_id);
	copy_field_value( p_source_field =>  p_date_earned,
				p_target_field =>  p_element_entry_data.date_earned);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_element_entry_data :=l_element_entry_data;
     raise;

End conv_to_element_entry_rg;


-- Procedure conv_to_element_entry_rg converts the
-- to the element_entries_h_v type to pay_element_entriestype record.
--
Procedure conv_to_element_entry_rg(	p_element_entry_h_v	in  ghr_element_entries_h_v%rowtype,
						p_element_entry_data	out nocopy pay_element_entries_f%rowtype) as

	l_proc			varchar2(30):='Conv_to_element_rg';
	l_element_entry_data	pay_element_entries_f%rowtype;

Begin

	conv_to_element_entry_rg(
		p_element_entry_id              => p_element_entry_h_v.element_entry_id              ,
		p_effective_start_date          => p_element_entry_h_v.effective_start_date          ,
		p_effective_end_date            => p_element_entry_h_v.effective_end_date            ,
		p_cost_allocation_keyflex_id    => p_element_entry_h_v.cost_allocation_keyflex_id    ,
		p_assignment_id                 => p_element_entry_h_v.assignment_id                 ,
		p_updating_action_id            => p_element_entry_h_v.updating_action_id            ,
		p_element_link_id               => p_element_entry_h_v.element_link_id               ,
		p_original_entry_id             => p_element_entry_h_v.original_entry_id             ,
		p_creator_type                  => p_element_entry_h_v.creator_type                  ,
		p_entry_type                    => p_element_entry_h_v.entry_type                    ,
		p_comment_id                    => p_element_entry_h_v.comment_id                    ,
		p_creator_id                    => p_element_entry_h_v.creator_id                    ,
		p_reason                        => p_element_entry_h_v.reason                        ,
		p_target_entry_id               => p_element_entry_h_v.target_entry_id               ,
		p_attribute_category            => p_element_entry_h_v.attribute_category            ,
		p_attribute1                    => p_element_entry_h_v.attribute1                    ,
		p_attribute2                    => p_element_entry_h_v.attribute2                    ,
		p_attribute3                    => p_element_entry_h_v.attribute3                    ,
		p_attribute4                    => p_element_entry_h_v.attribute4                    ,
		p_attribute5                    => p_element_entry_h_v.attribute5                    ,
		p_attribute6                    => p_element_entry_h_v.attribute6                    ,
		p_attribute7                    => p_element_entry_h_v.attribute7                    ,
		p_attribute8                    => p_element_entry_h_v.attribute8                    ,
		p_attribute9                    => p_element_entry_h_v.attribute9                    ,
		p_attribute10                   => p_element_entry_h_v.attribute10                   ,
		p_attribute11                   => p_element_entry_h_v.attribute11                   ,
		p_attribute12                   => p_element_entry_h_v.attribute12                   ,
		p_attribute13                   => p_element_entry_h_v.attribute13                   ,
		p_attribute14                   => p_element_entry_h_v.attribute14                   ,
		p_attribute15                   => p_element_entry_h_v.attribute15                   ,
		p_attribute16                   => p_element_entry_h_v.attribute16                   ,
		p_attribute17                   => p_element_entry_h_v.attribute17                   ,
		p_attribute18                   => p_element_entry_h_v.attribute18                   ,
		p_attribute19                   => p_element_entry_h_v.attribute19                   ,
		p_attribute20                   => p_element_entry_h_v.attribute20                   ,
		p_subpriority                   => p_element_entry_h_v.subpriority                   ,
		p_personal_payment_method_id    => p_element_entry_h_v.personal_payment_method_id    ,
		p_date_earned                   => p_element_entry_h_v.date_earned                   ,
		p_element_entry_data	    	  => l_element_entry_data);
	p_element_entry_data	:= l_element_entry_data;

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_element_entry_data :=NULL;
     raise;



End conv_to_element_entry_rg;


-- procedure convt_element_entry_rg_to_hist converts the  per_ element_entries record type to
-- ghr_pa_history record type
procedure conv_element_entry_rg_to_hist(
	p_element_entries_data        in  pay_element_entries_f%rowtype,
	p_history_data   	   	   in out nocopy  ghr_pa_history%rowtype) as

	l_proc	 varchar2(30) := 'convert_element_ent_rg_hist_rg';
	l_history_data		ghr_pa_history%rowtype;

begin

        l_history_data := p_history_data ; --NOCOPY CHANGES
	hr_utility.set_location('entering:'|| l_proc, 5);

	p_history_data.INFORMATION1     :=   p_element_entries_data.ELEMENT_ENTRY_ID	;
	p_history_data.INFORMATION2     :=   TO_CHAR(p_element_entries_data.EFFECTIVE_START_DATE, g_hist_date_format)	;
	p_history_data.INFORMATION3	  :=   TO_CHAR(p_element_entries_data.EFFECTIVE_END_DATE, g_hist_date_format)	;
	p_history_data.INFORMATION4	  :=   p_element_entries_data.COST_ALLOCATION_KEYFLEX_ID	;
	p_history_data.INFORMATION5	  :=   p_element_entries_data.ASSIGNMENT_ID	;
	p_history_data.INFORMATION6	  :=   p_element_entries_data.UPDATING_ACTION_ID	;
	p_history_data.INFORMATION7	  :=   p_element_entries_data.ELEMENT_LINK_ID	;
	p_history_data.INFORMATION8	  :=   p_element_entries_data.ORIGINAL_ENTRY_ID	;
	p_history_data.INFORMATION9	  :=   p_element_entries_data.CREATOR_TYPE	;
	p_history_data.INFORMATION10	  :=   p_element_entries_data.ENTRY_TYPE	;
	p_history_data.INFORMATION11	  :=   p_element_entries_data.COMMENT_ID	;
	p_history_data.INFORMATION12	  :=   p_element_entries_data.CREATOR_ID	;
	p_history_data.INFORMATION13	  :=   p_element_entries_data.REASON	;
	p_history_data.INFORMATION14	  :=   p_element_entries_data.TARGET_ENTRY_ID	;
	p_history_data.INFORMATION15	  :=   p_element_entries_data.SUBPRIORITY	;
	p_history_data.INFORMATION16	  :=   p_element_entries_data.PERSONAL_PAYMENT_METHOD_ID	;
	p_history_data.INFORMATION17	  :=   TO_CHAR(p_element_entries_data.DATE_EARNED, g_hist_date_format)	;
	p_history_data.INFORMATION121	  :=   p_element_entries_data.ATTRIBUTE_CATEGORY	;
	p_history_data.INFORMATION122	  :=   p_element_entries_data.ATTRIBUTE1	;
	p_history_data.INFORMATION123	  :=   p_element_entries_data.ATTRIBUTE2	;
	p_history_data.INFORMATION124	  :=   p_element_entries_data.ATTRIBUTE3	;
	p_history_data.INFORMATION125	  :=   p_element_entries_data.ATTRIBUTE4	;
	p_history_data.INFORMATION126	  :=   p_element_entries_data.ATTRIBUTE5	;
	p_history_data.INFORMATION127	  :=   p_element_entries_data.ATTRIBUTE6	;
	p_history_data.INFORMATION128	  :=   p_element_entries_data.ATTRIBUTE7	;
	p_history_data.INFORMATION129	  :=   p_element_entries_data.ATTRIBUTE8	;
	p_history_data.INFORMATION130	  :=   p_element_entries_data.ATTRIBUTE9	;
	p_history_data.INFORMATION131	  :=   p_element_entries_data.ATTRIBUTE10	;
	p_history_data.INFORMATION132	  :=   p_element_entries_data.ATTRIBUTE11	;
	p_history_data.INFORMATION133	  :=   p_element_entries_data.ATTRIBUTE12	;
	p_history_data.INFORMATION134	  :=   p_element_entries_data.ATTRIBUTE13	;
	p_history_data.INFORMATION135	  :=   p_element_entries_data.ATTRIBUTE14	;
	p_history_data.INFORMATION136	  :=   p_element_entries_data.ATTRIBUTE15	;
	p_history_data.INFORMATION137	  :=   p_element_entries_data.ATTRIBUTE16	;
	p_history_data.INFORMATION138	  :=   p_element_entries_data.ATTRIBUTE17	;
	p_history_data.INFORMATION139	  :=   p_element_entries_data.ATTRIBUTE18	;
	p_history_data.INFORMATION140	  :=   p_element_entries_data.ATTRIBUTE19	;
	p_history_data.INFORMATION141	  :=   p_element_entries_data.ATTRIBUTE20	;
	hr_utility.set_location(' leaving:'||l_proc, 10);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_history_data := l_history_data ;
     raise;



end conv_element_entry_rg_to_hist;


--procedure conv_to_element_entry_rg converts the ghr_pa_history record type to
--per_element_entries_f record type
procedure conv_to_element_entry_rg(
	p_history_data   	   	      	in  ghr_pa_history%rowtype,
	p_element_entries_data         in  out nocopy pay_element_entries_f%rowtype) as

	l_proc	 varchar2(30) := 'conv_to_element_entry_rg';
	l_element_entries_data   pay_element_entries_f%rowtype;

begin

        l_element_entries_data  := p_element_entries_data ; --NOCOPY CHANGES
	hr_utility.set_location('entering:'|| l_proc, 5);

	p_element_entries_data.ELEMENT_ENTRY_ID		:=	p_history_data.INFORMATION1	;
	p_element_entries_data.EFFECTIVE_START_DATE	:=	to_date(p_history_data.INFORMATION2, g_hist_date_format)	;
	p_element_entries_data.EFFECTIVE_END_DATE		:=	to_date(p_history_data.INFORMATION3, g_hist_date_format)	;
	p_element_entries_data.COST_ALLOCATION_KEYFLEX_ID :=	p_history_data.INFORMATION4	;
	p_element_entries_data.ASSIGNMENT_ID		:=	p_history_data.INFORMATION5	;
	p_element_entries_data.UPDATING_ACTION_ID		:=	p_history_data.INFORMATION6	;
	p_element_entries_data.ELEMENT_LINK_ID		:=	p_history_data.INFORMATION7	;
	p_element_entries_data.ORIGINAL_ENTRY_ID		:=	p_history_data.INFORMATION8	;
	p_element_entries_data.CREATOR_TYPE			:=	p_history_data.INFORMATION9	;
	p_element_entries_data.ENTRY_TYPE			:=	p_history_data.INFORMATION10	;
	p_element_entries_data.COMMENT_ID			:=	p_history_data.INFORMATION11	;
	p_element_entries_data.CREATOR_ID			:=	p_history_data.INFORMATION12	;
	p_element_entries_data.REASON				:=	p_history_data.INFORMATION13	;
	p_element_entries_data.TARGET_ENTRY_ID		:=	p_history_data.INFORMATION14	;
	p_element_entries_data.SUBPRIORITY			:=	p_history_data.INFORMATION15	;
	p_element_entries_data.PERSONAL_PAYMENT_METHOD_ID :=	p_history_data.INFORMATION16	;
	p_element_entries_data.DATE_EARNED			:=	to_date(p_history_data.INFORMATION17, g_hist_date_format)	;
	p_element_entries_data.ATTRIBUTE_CATEGORY		:=	p_history_data.INFORMATION121	;
	p_element_entries_data.ATTRIBUTE1			:=	p_history_data.INFORMATION122	;
	p_element_entries_data.ATTRIBUTE2			:=	p_history_data.INFORMATION123	;
	p_element_entries_data.ATTRIBUTE3			:=	p_history_data.INFORMATION124	;
	p_element_entries_data.ATTRIBUTE4			:=	p_history_data.INFORMATION125	;
	p_element_entries_data.ATTRIBUTE5			:=	p_history_data.INFORMATION126	;
	p_element_entries_data.ATTRIBUTE6			:=	p_history_data.INFORMATION127	;
	p_element_entries_data.ATTRIBUTE7			:=	p_history_data.INFORMATION128	;
	p_element_entries_data.ATTRIBUTE8			:=	p_history_data.INFORMATION129	;
	p_element_entries_data.ATTRIBUTE9			:=	p_history_data.INFORMATION130	;
	p_element_entries_data.ATTRIBUTE10			:=	p_history_data.INFORMATION131	;
	p_element_entries_data.ATTRIBUTE11			:=	p_history_data.INFORMATION132	;
	p_element_entries_data.ATTRIBUTE12			:=	p_history_data.INFORMATION133	;
	p_element_entries_data.ATTRIBUTE13			:=	p_history_data.INFORMATION134	;
	p_element_entries_data.ATTRIBUTE14			:=	p_history_data.INFORMATION135	;
	p_element_entries_data.ATTRIBUTE15			:=	p_history_data.INFORMATION136	;
	p_element_entries_data.ATTRIBUTE16			:=	p_history_data.INFORMATION137	;
	p_element_entries_data.ATTRIBUTE17			:=	p_history_data.INFORMATION138	;
	p_element_entries_data.ATTRIBUTE18			:=	p_history_data.INFORMATION139	;
	p_element_entries_data.ATTRIBUTE19			:=	p_history_data.INFORMATION140	;
	p_element_entries_data.ATTRIBUTE20			:=	p_history_data.INFORMATION141	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_element_entries_data :=l_element_entries_data;
     raise;


end conv_to_element_entry_rg;


-- Procedure conv_to_addresses_rg copies the individual fields supplied as parameters
-- to the per_addresses type record.
Procedure conv_to_addresses_rg(
	p_address_id              in per_addresses.address_id%type                 default null,
	p_business_group_id       in per_addresses.business_group_id%type          default null,
	p_person_id               in per_addresses.person_id%type                  default null,
	p_date_from               in per_addresses.date_from%type                  default null,
	p_primary_flag            in per_addresses.primary_flag%type               default null,
	p_style                   in per_addresses.style%type                      default null,
	p_address_line1           in per_addresses.address_line1%type              default null,
	p_address_line2           in per_addresses.address_line2%type              default null,
	p_address_line3           in per_addresses.address_line3%type              default null,
	p_address_type            in per_addresses.address_type%type               default null,
--	p_comments                in per_addresses.comments%type                   default null,
	p_country                 in per_addresses.country%type                    default null,
	p_date_to                 in per_addresses.date_to%type                    default null,
	p_postal_code             in per_addresses.postal_code%type                default null,
	p_region_1                in per_addresses.region_1%type                   default null,
	p_region_2                in per_addresses.region_2%type                   default null,
	p_region_3                in per_addresses.region_3%type                   default null,
	p_telephone_number_1      in per_addresses.telephone_number_1%type         default null,
	p_telephone_number_2      in per_addresses.telephone_number_2%type         default null,
	p_telephone_number_3      in per_addresses.telephone_number_3%type         default null,
	p_town_or_city            in per_addresses.town_or_city%type               default null,
	p_request_id              in per_addresses.request_id%type                 default null,
	p_program_application_id  in per_addresses.program_application_id%type     default null,
	p_program_id              in per_addresses.program_id%type                 default null,
	p_program_update_date     in per_addresses.program_update_date%type        default null,
	p_addr_attribute_category in per_addresses.addr_attribute_category%type    default null,
	p_addr_attribute1         in per_addresses.addr_attribute1%type            default null,
	p_addr_attribute2         in per_addresses.addr_attribute2%type            default null,
	p_addr_attribute3         in per_addresses.addr_attribute3%type            default null,
	p_addr_attribute4         in per_addresses.addr_attribute4%type            default null,
	p_addr_attribute5         in per_addresses.addr_attribute5%type            default null,
	p_addr_attribute6         in per_addresses.addr_attribute6%type            default null,
	p_addr_attribute7         in per_addresses.addr_attribute7%type            default null,
	p_addr_attribute8         in per_addresses.addr_attribute8%type            default null,
	p_addr_attribute9         in per_addresses.addr_attribute9%type            default null,
	p_addr_attribute10        in per_addresses.addr_attribute10%type           default null,
	p_addr_attribute11        in per_addresses.addr_attribute11%type           default null,
	p_addr_attribute12        in per_addresses.addr_attribute12%type           default null,
	p_addr_attribute13        in per_addresses.addr_attribute13%type           default null,
	p_addr_attribute14        in per_addresses.addr_attribute14%type           default null,
	p_addr_attribute15        in per_addresses.addr_attribute15%type           default null,
	p_addr_attribute16        in per_addresses.addr_attribute16%type           default null,
	p_addr_attribute17        in per_addresses.addr_attribute17%type           default null,
	p_addr_attribute18        in per_addresses.addr_attribute18%type           default null,
	p_addr_attribute19        in per_addresses.addr_attribute19%type           default null,
	p_addr_attribute20        in per_addresses.addr_attribute20%type           default null,
--	p_object_version_number   in per_addresses.object_version_number%type      default null,
	p_addresses_data	    in out nocopy per_addresses%rowtype  )  as

	l_proc	varchar2(30):='conv_to_addresses_rg';
	l_addresses_data         per_addresses%rowtype;

begin

	l_addresses_data := p_addresses_data ; --NOCOPY CHANGES

	hr_utility.set_location('Entering:'|| l_proc, 5);
	copy_field_value( p_source_field =>  p_address_id,
				p_target_field =>  p_addresses_data.address_id);
	copy_field_value( p_source_field =>  p_business_group_id,
				p_target_field =>  p_addresses_data.business_group_id);
	copy_field_value( p_source_field =>  p_person_id,
				p_target_field =>  p_addresses_data.person_id);
	copy_field_value( p_source_field =>  p_date_from,
				p_target_field =>  p_addresses_data.date_from);
	copy_field_value( p_source_field =>  p_primary_flag,
				p_target_field =>  p_addresses_data.primary_flag);
	copy_field_value( p_source_field =>  p_style,
				p_target_field =>  p_addresses_data.style);
	copy_field_value( p_source_field =>  p_address_line1,
				p_target_field =>  p_addresses_data.address_line1);
	copy_field_value( p_source_field =>  p_address_line2,
				p_target_field =>  p_addresses_data.address_line2);
	copy_field_value( p_source_field =>  p_address_line3,
				p_target_field =>  p_addresses_data.address_line3);
	copy_field_value( p_source_field =>  p_address_type,
				p_target_field =>  p_addresses_data.address_type);
--	copy_field_value( p_source_field =>  p_comments,
--				p_target_field =>  p_addresses_data.comments);
	copy_field_value( p_source_field =>  p_country,
				p_target_field =>  p_addresses_data.country);
	copy_field_value( p_source_field =>  p_date_to,
				p_target_field =>  p_addresses_data.date_to);
	copy_field_value( p_source_field =>  p_postal_code,
				p_target_field =>  p_addresses_data.postal_code);
	copy_field_value( p_source_field =>  p_region_1,
				p_target_field =>  p_addresses_data.region_1);
	copy_field_value( p_source_field =>  p_region_2,
				p_target_field =>  p_addresses_data.region_2);
	copy_field_value( p_source_field =>  p_region_3,
				p_target_field =>  p_addresses_data.region_3);
	copy_field_value( p_source_field =>  p_telephone_number_1,
				p_target_field =>  p_addresses_data.telephone_number_1);
	copy_field_value( p_source_field =>  p_telephone_number_2,
				p_target_field =>  p_addresses_data.telephone_number_2);
	copy_field_value( p_source_field =>  p_telephone_number_3,
				p_target_field =>  p_addresses_data.telephone_number_3);
	copy_field_value( p_source_field =>  p_town_or_city,
				p_target_field =>  p_addresses_data.town_or_city);
	copy_field_value( p_source_field =>  p_request_id,
				p_target_field =>  p_addresses_data.request_id);
	copy_field_value( p_source_field =>  p_program_application_id,
				p_target_field =>  p_addresses_data.program_application_id);
	copy_field_value( p_source_field =>  p_program_id,
				p_target_field =>  p_addresses_data.program_id);
	copy_field_value( p_source_field =>  p_program_update_date,
				p_target_field =>  p_addresses_data.program_update_date);
	copy_field_value( p_source_field =>  p_addr_attribute_category,
				p_target_field =>  p_addresses_data.addr_attribute_category);
	copy_field_value( p_source_field =>  p_addr_attribute1,
				p_target_field =>  p_addresses_data.addr_attribute1);
	copy_field_value( p_source_field =>  p_addr_attribute2,
				p_target_field =>  p_addresses_data.addr_attribute2);
	copy_field_value( p_source_field =>  p_addr_attribute3,
				p_target_field =>  p_addresses_data.addr_attribute3);
	copy_field_value( p_source_field =>  p_addr_attribute4,
				p_target_field =>  p_addresses_data.addr_attribute4);
	copy_field_value( p_source_field =>  p_addr_attribute5,
				p_target_field =>  p_addresses_data.addr_attribute5);
	copy_field_value( p_source_field =>  p_addr_attribute6,
				p_target_field =>  p_addresses_data.addr_attribute6);
	copy_field_value( p_source_field =>  p_addr_attribute7,
				p_target_field =>  p_addresses_data.addr_attribute7);
	copy_field_value( p_source_field =>  p_addr_attribute8,
				p_target_field =>  p_addresses_data.addr_attribute8);
	copy_field_value( p_source_field =>  p_addr_attribute9,
				p_target_field =>  p_addresses_data.addr_attribute9);
	copy_field_value( p_source_field =>  p_addr_attribute10,
				p_target_field =>  p_addresses_data.addr_attribute10);
	copy_field_value( p_source_field =>  p_addr_attribute11,
				p_target_field =>  p_addresses_data.addr_attribute11);
	copy_field_value( p_source_field =>  p_addr_attribute12,
				p_target_field =>  p_addresses_data.addr_attribute12);
	copy_field_value( p_source_field =>  p_addr_attribute13,
				p_target_field =>  p_addresses_data.addr_attribute13);
	copy_field_value( p_source_field =>  p_addr_attribute14,
				p_target_field =>  p_addresses_data.addr_attribute14);
	copy_field_value( p_source_field =>  p_addr_attribute15,
				p_target_field =>  p_addresses_data.addr_attribute15);
	copy_field_value( p_source_field =>  p_addr_attribute16,
				p_target_field =>  p_addresses_data.addr_attribute16);
	copy_field_value( p_source_field =>  p_addr_attribute17,
				p_target_field =>  p_addresses_data.addr_attribute17);
	copy_field_value( p_source_field =>  p_addr_attribute18,
				p_target_field =>  p_addresses_data.addr_attribute18);
	copy_field_value( p_source_field =>  p_addr_attribute19,
				p_target_field =>  p_addresses_data.addr_attribute19);
	copy_field_value( p_source_field =>  p_addr_attribute20,
				p_target_field =>  p_addresses_data.addr_attribute20);
--	copy_field_value( p_source_field =>  p_object_version_number,
--				p_target_field =>  p_addresses_data.object_version_number);
 	hr_utility.set_location('Leaving:'|| l_proc, 5);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_addresses_data :=l_addresses_data;
     raise;



end conv_to_addresses_rg;


-- Procedure conv_to_addresses_rg converts the ghr_addresses record to
-- to the per_addresses record
Procedure conv_to_addresses_rg(p_addresses_h_v    in ghr_addresses_h_v%rowtype,
                             	 p_addresses_data  out nocopy per_addresses%rowtype) is

	l_proc		varchar2(30):='Conv_to_addresses_rg';
	l_addresses_data	per_addresses%rowtype;

Begin
	hr_utility.set_location('Entering : ' || l_proc, 100);
	conv_to_addresses_rg(
		p_address_id              => p_addresses_h_v.address_id                  ,
		p_business_group_id       => p_addresses_h_v.business_group_id           ,
		p_person_id               => p_addresses_h_v.person_id                   ,
		p_date_from               => p_addresses_h_v.date_from                   ,
		p_primary_flag            => p_addresses_h_v.primary_flag                ,
		p_style                   => p_addresses_h_v.style                       ,
		p_address_line1           => p_addresses_h_v.address_line1               ,
		p_address_line2           => p_addresses_h_v.address_line2               ,
		p_address_line3           => p_addresses_h_v.address_line3               ,
		p_address_type            => p_addresses_h_v.address_type                ,
	--	p_comments                => p_addresses_h_v.comments                    ,
		p_country                 => p_addresses_h_v.country                     ,
		p_date_to                 => p_addresses_h_v.date_to                     ,
		p_postal_code             => p_addresses_h_v.postal_code                 ,
		p_region_1                => p_addresses_h_v.region_1                    ,
		p_region_2                => p_addresses_h_v.region_2                    ,
		p_region_3                => p_addresses_h_v.region_3                    ,
		p_telephone_number_1      => p_addresses_h_v.telephone_number_1          ,
		p_telephone_number_2      => p_addresses_h_v.telephone_number_2          ,
		p_telephone_number_3      => p_addresses_h_v.telephone_number_3          ,
		p_town_or_city            => p_addresses_h_v.town_or_city                ,
		p_request_id              => p_addresses_h_v.request_id                  ,
		p_program_application_id  => p_addresses_h_v.program_application_id      ,
		p_program_id              => p_addresses_h_v.program_id                  ,
		p_program_update_date     => p_addresses_h_v.program_update_date         ,
		p_addr_attribute_category => p_addresses_h_v.addr_attribute_category     ,
		p_addr_attribute1         => p_addresses_h_v.addr_attribute1             ,
		p_addr_attribute2         => p_addresses_h_v.addr_attribute2             ,
		p_addr_attribute3         => p_addresses_h_v.addr_attribute3             ,
		p_addr_attribute4         => p_addresses_h_v.addr_attribute4             ,
		p_addr_attribute5         => p_addresses_h_v.addr_attribute5             ,
		p_addr_attribute6         => p_addresses_h_v.addr_attribute6             ,
		p_addr_attribute7         => p_addresses_h_v.addr_attribute7             ,
		p_addr_attribute8         => p_addresses_h_v.addr_attribute8             ,
		p_addr_attribute9         => p_addresses_h_v.addr_attribute9             ,
		p_addr_attribute10        => p_addresses_h_v.addr_attribute10            ,
		p_addr_attribute11        => p_addresses_h_v.addr_attribute11            ,
		p_addr_attribute12        => p_addresses_h_v.addr_attribute12            ,
		p_addr_attribute13        => p_addresses_h_v.addr_attribute13            ,
		p_addr_attribute14        => p_addresses_h_v.addr_attribute14            ,
		p_addr_attribute15        => p_addresses_h_v.addr_attribute15            ,
		p_addr_attribute16        => p_addresses_h_v.addr_attribute16            ,
		p_addr_attribute17        => p_addresses_h_v.addr_attribute17            ,
		p_addr_attribute18        => p_addresses_h_v.addr_attribute18            ,
		p_addr_attribute19        => p_addresses_h_v.addr_attribute19            ,
		p_addr_attribute20        => p_addresses_h_v.addr_attribute20            ,
--		p_object_version_number   => p_addresses_h_v.object_version_number       ,
		p_addresses_data		  => l_addresses_data);
	p_addresses_data	:=	l_addresses_data;

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_addresses_data :=NULL;
     raise;


end conv_to_addresses_rg;


-- procedure conv_addresses_rg_to_hist_rg converts the  addresses_rg record type to
-- ghr_addresses_history record type
Procedure conv_addresses_rg_to_hist_rg(
	p_addresses_data        in  	per_addresses%rowtype,
	p_history_data   	  in out  nocopy ghr_pa_history%rowtype) as

	l_proc	 varchar2(30) := 'conv_addresses_rg_to_hist_rg';
	l_history_data    ghr_pa_history%rowtype;

begin

	l_history_data := p_history_data ; --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);

	p_history_data.information1	  :=   p_addresses_data.address_id	;
	p_history_data.information5	  :=   p_addresses_data.person_id	;
	p_history_data.information6	  :=   to_char(p_addresses_data.date_from,g_hist_date_format)	;
	p_history_data.information7	  :=   p_addresses_data.primary_flag	;
	p_history_data.information8	  :=   p_addresses_data.style	;
	p_history_data.information9	  :=   p_addresses_data.address_line1	;
	p_history_data.information10	  :=   p_addresses_data.address_line2	;
	p_history_data.information11	  :=   p_addresses_data.address_line3	;
	p_history_data.information12	  :=   p_addresses_data.address_type	;
	p_history_data.information13	  :=   p_addresses_data.town_or_city	;
	p_history_data.information14	  :=   p_addresses_data.country	;
	p_history_data.information15	  :=   to_char(p_addresses_data.date_to,g_hist_date_format)	;
	p_history_data.information16	  :=   p_addresses_data.postal_code	;
	p_history_data.information17	  :=   p_addresses_data.region_1	;
	p_history_data.information18	  :=   p_addresses_data.region_2	;
	p_history_data.information19	  :=   p_addresses_data.region_3	;
	p_history_data.information20	  :=   p_addresses_data.telephone_number_1	;
	p_history_data.information21	  :=   p_addresses_data.telephone_number_2	;
	p_history_data.information22	  :=   p_addresses_data.telephone_number_3	;
--	p_history_data.information23	  :=   p_addresses_data.town_or_city	;
	p_history_data.information121	  :=   p_addresses_data.request_id	;
	p_history_data.information122	  :=   p_addresses_data.program_application_id	;
	p_history_data.information123	  :=   p_addresses_data.program_id	;
	p_history_data.information124	  :=   to_char(p_addresses_data.program_update_date,g_hist_date_format)	;
	p_history_data.information125	  :=   p_addresses_data.addr_attribute_category	;
	p_history_data.information126	  :=   p_addresses_data.addr_attribute1	;
	p_history_data.information127	  :=   p_addresses_data.addr_attribute2	;
	p_history_data.information128	  :=   p_addresses_data.addr_attribute3	;
	p_history_data.information129	  :=   p_addresses_data.addr_attribute4	;
	p_history_data.information130	  :=   p_addresses_data.addr_attribute5	;
	p_history_data.information131	  :=   p_addresses_data.addr_attribute6	;
	p_history_data.information132	  :=   p_addresses_data.addr_attribute7	;
	p_history_data.information133	  :=   p_addresses_data.addr_attribute8	;
	p_history_data.information134	  :=   p_addresses_data.addr_attribute9	;
	p_history_data.information135	  :=   p_addresses_data.addr_attribute10	;
	p_history_data.information136	  :=   p_addresses_data.addr_attribute11	;
	p_history_data.information137	  :=   p_addresses_data.addr_attribute12	;
	p_history_data.information138	  :=   p_addresses_data.addr_attribute13	;
	p_history_data.information139	  :=   p_addresses_data.addr_attribute14	;
	p_history_data.information140	  :=   p_addresses_data.addr_attribute15	;
	p_history_data.information141	  :=   p_addresses_data.addr_attribute16	;
	p_history_data.information142	  :=   p_addresses_data.addr_attribute17	;
	p_history_data.information143	  :=   p_addresses_data.addr_attribute18	;
	p_history_data.information144	  :=   p_addresses_data.addr_attribute19	;
	p_history_data.information145	  :=   p_addresses_data.addr_attribute20	;
--	p_history_data.information151	  :=   p_addresses_data.object_version_number	;
	p_history_data.information152	  :=   p_addresses_data.business_group_id	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_history_data :=l_history_data;
     raise;




end conv_addresses_rg_to_hist_rg;

--procedure conv_to_addresses_rg converts the  ghr_addresses_history
--record type to addresses_rg
Procedure conv_to_addresses_rg(
	p_history_data 	    in   	ghr_pa_history%rowtype,
	p_addresses_data  in out nocopy	per_addresses%rowtype) as

	l_proc	 varchar2(30) := 'conv_addresses_rg_to_hist_rg';
	l_addresses_data  per_addresses%rowtype;
begin

	l_addresses_data :=p_addresses_data; --NOCOPY Changes
	hr_utility.set_location('entering:'|| l_proc, 5);

	p_addresses_data.address_id	  	  	:=	p_history_data.information1	;
	p_addresses_data.person_id	  	  	:=	p_history_data.information5	;
	p_addresses_data.date_from	  	  	:=	to_date(p_history_data.information6,g_hist_date_format)	;
	p_addresses_data.primary_flag	  	  	:=	p_history_data.information7	;
	p_addresses_data.style	  		  	:=	p_history_data.information8	;
	p_addresses_data.address_line1	  	:=	p_history_data.information9	;
	p_addresses_data.address_line2	  	:=	p_history_data.information10	;
	p_addresses_data.address_line3	  	:=	p_history_data.information11	;
	p_addresses_data.address_type	  	  	:=	p_history_data.information12	;
	--p_addresses_data.comments	  	  	:=	p_history_data.information13	;
	p_addresses_data.country	  	  	:=	p_history_data.information14	;
	p_addresses_data.date_to	  	  	:=	to_date(p_history_data.information15,g_hist_date_format)	;
	p_addresses_data.postal_code	  	  	:=	p_history_data.information16	;
	p_addresses_data.region_1	  	  	:= 	p_history_data.information17	;
	p_addresses_data.region_2	  	  	:= 	p_history_data.information18	;
	p_addresses_data.region_3	  	  	:=	p_history_data.information19	;
	p_addresses_data.telephone_number_1	  	:=	p_history_data.information20	;
	p_addresses_data.telephone_number_2	  	:=	p_history_data.information21	;
	p_addresses_data.telephone_number_3	  	:=	p_history_data.information22	;
	p_addresses_data.town_or_city	  	  	:= 	p_history_data.information13	;
	p_addresses_data.request_id	    	  	:=	p_history_data.information121	;
	p_addresses_data.program_application_id  	:=  	p_history_data.information122	;
	p_addresses_data.program_id	  	  	:=	p_history_data.information123	;
	p_addresses_data.program_update_date  	:=	to_date(p_history_data.information124,g_hist_date_format)	;
	p_addresses_data.addr_attribute_category 	:= 	p_history_data.information125	;
	p_addresses_data.addr_attribute1	  	:=	p_history_data.information126	;
	p_addresses_data.addr_attribute2	  	:=	p_history_data.information127	;
	p_addresses_data.addr_attribute3	  	:=  	p_history_data.information128	;
	p_addresses_data.addr_attribute4	  	:=  	p_history_data.information129	;
	p_addresses_data.addr_attribute5	  	:=  	p_history_data.information130	;
	p_addresses_data.addr_attribute6	  	:=  	p_history_data.information131	;
	p_addresses_data.addr_attribute7	  	:=  	p_history_data.information132	;
	p_addresses_data.addr_attribute8	  	:=  	p_history_data.information133	;
	p_addresses_data.addr_attribute9	  	:=  	p_history_data.information134	;
	p_addresses_data.addr_attribute10	  	:=  	p_history_data.information135	;
	p_addresses_data.addr_attribute11	  	:=  	p_history_data.information136	;
	p_addresses_data.addr_attribute12	  	:=  	p_history_data.information137	;
	p_addresses_data.addr_attribute13	  	:=  	p_history_data.information138	;
	p_addresses_data.addr_attribute14	  	:=  	p_history_data.information139	;
	p_addresses_data.addr_attribute15	  	:=  	p_history_data.information140	;
	p_addresses_data.addr_attribute16	  	:=  	p_history_data.information141	;
	p_addresses_data.addr_attribute17	  	:=  	p_history_data.information142	;
	p_addresses_data.addr_attribute18	  	:=  	p_history_data.information143	;
	p_addresses_data.addr_attribute19	  	:=  	p_history_data.information144	;
	p_addresses_data.addr_attribute20	  	:=  	p_history_data.information145	;
--	p_addresses_data.object_version_number	:= 	p_history_data.information151	;
	p_addresses_data.business_group_id	  	:=  	p_history_data.information152	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_addresses_data :=l_addresses_data;
     raise;



end conv_to_addresses_rg;

Procedure conv_to_element_entval_rg(
	p_element_entry_value_id	in pay_element_entry_values_f.element_entry_value_id%type,
	p_effective_start_date		in pay_element_entry_values_f.effective_start_date%type,
	p_effective_end_date     	in pay_element_entry_values_f.effective_end_date%type,
	p_input_value_id			in pay_element_entry_values_f.input_value_id%type,
	p_element_entry_id       	in pay_element_entry_values_f.element_entry_id%type,
	p_screen_entry_value		in pay_element_entry_values_f.screen_entry_value%type,
	p_elmeval_data		  in out nocopy pay_element_entry_values_f%rowtype) is

	l_proc	varchar2(30):='conv_to_element_entval_rg';
	l_elmeval_data	pay_element_entry_values_f%rowtype;
Begin

	l_elmeval_data := p_elmeval_data; --NOCOPY CHANGES

	hr_utility.set_location(' entering:'|| l_proc, 5);

	copy_field_value( p_source_field =>  p_element_entry_value_id,
				p_target_field =>  p_elmeval_data.element_entry_value_id);
	copy_field_value( p_source_field =>  p_effective_start_Date,
				p_target_field =>  p_elmeval_data.effective_start_Date);
	copy_field_value( p_source_field =>  p_effective_end_Date,
				p_target_field =>  p_elmeval_data.effective_end_Date);
	copy_field_value( p_source_field =>  p_input_value_id,
				p_target_field =>  p_elmeval_data.input_value_id);
	copy_field_value( p_source_field =>  p_element_entry_id,
				p_target_field =>  p_elmeval_data.element_entry_id);
	copy_field_value( p_source_field =>  p_screen_entry_value,
				p_target_field =>  p_elmeval_data.screen_entry_value);
	hr_utility.set_location(' leaving:'||l_proc, 10);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_elmeval_data := l_elmeval_data;
     raise;

end conv_to_element_entval_rg;

Procedure conv_to_element_entval_rg(
	p_element_entval_h_v		in  ghr_element_entry_values_h_v%rowtype,
	p_element_entval_data		out nocopy pay_element_entry_values_f%rowtype) is

	l_proc	varchar2(30):='conv_to_element_entval_rg';


Begin

	hr_utility.set_location(' entering:' || l_proc, 5);
	p_element_entval_data.element_entry_value_id 	:= p_element_entval_h_v.element_entry_value_id  ;
	p_element_entval_data.effective_start_Date 	:= p_element_entval_h_v.effective_start_Date ;
	p_element_entval_data.effective_end_Date 		:= p_element_entval_h_v.effective_end_Date ;
	p_element_entval_data.input_value_id 		:= p_element_entval_h_v.input_value_id ;
	p_element_entval_data.element_entry_id 		:= p_element_entval_h_v.element_entry_id ;
	p_element_entval_data.screen_entry_value 		:= p_element_entval_h_v.screen_entry_value;

	hr_utility.set_location(' leaving:'||l_proc, 10);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_element_entval_data := NULL;
     raise;

End conv_to_element_entval_rg;


procedure conv_element_entval_rg_to_hist(
	p_element_entval_data        in  pay_element_entry_values_f%rowtype,
	p_history_data   	   	  in out nocopy  ghr_pa_history%rowtype) is

	l_proc	varchar2(30):='conv_to_element_entval_rg';
	l_history_data   ghr_pa_history%rowtype;

Begin

        l_history_data :=p_history_data; --NOCOPY CHANGES
	hr_utility.set_location(' entering:' || l_proc, 5);
	p_history_data.information1 := to_char(p_element_entval_data.element_entry_value_id) ;
	p_history_data.information2 := to_char(p_element_entval_data.effective_start_date, ghr_history_api.g_hist_date_format);
	p_history_data.information3 := to_char(p_element_entval_data.effective_end_date, ghr_history_api.g_hist_date_format) ;
	p_history_data.information4 := to_char(p_element_entval_data.input_value_id) ;
	p_history_data.information5 := to_char(p_element_entval_data.element_entry_id) ;
	p_history_data.information6 := substr(p_element_entval_data.screen_entry_value,1 ,60) ;

	hr_utility.set_location(' leaving:'||l_proc, 10);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_history_data :=l_history_data;
     raise;


End conv_element_entval_rg_to_hist;

procedure conv_to_element_entval_rg(
	p_history_data   	   	     	 in  ghr_pa_history%rowtype,
	p_element_entval_data    in  out  nocopy pay_element_entry_values_f%rowtype)  is

	l_proc	varchar2(30):='conv_to_element_entval_rg';
	l_element_entval_data    pay_element_entry_values_f%rowtype;
Begin

	l_element_entval_data :=p_element_entval_data; --NOCOPY CHANGES

	hr_utility.set_location(' entering:' || l_proc, 5);
	p_element_entval_data.element_entry_value_id 	:= to_number(p_history_data.information1) ;
	p_element_entval_data.effective_start_date 	:= to_date(p_history_data.information2, ghr_history_api.g_hist_date_format);
	p_element_entval_data.effective_end_date 		:= to_date(p_history_data.information3, ghr_history_api.g_hist_date_format) ;
	p_element_entval_data.input_value_id 		:= to_number(p_history_data.information4 ) ;
	p_element_entval_data.element_entry_id 		:= to_number(p_history_data.information5) ;
	p_element_entval_data.screen_entry_value 		:= substr(p_history_data.information6,1 ,60) ;

	hr_utility.set_location(' leaving:'||l_proc, 10);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_element_entval_data := l_element_entval_data;
     raise;

End conv_to_element_entval_rg;

-- SIT tables

-- procedure conv_peranalyses_rg_to_hist_rg converts the person_analyses_rg
-- record type to ghr_person_analyses_history record type
Procedure conv_peranalyses_rg_to_hist_rg(
	p_peranalyses_data      in  	per_person_analyses%rowtype,
	p_history_data   	  in out  nocopy ghr_pa_history%rowtype) as

	l_proc	 varchar2(30) := 'conv_peranalyses_rg_to_hist_rg';
	l_history_data  ghr_pa_history%rowtype;

begin

        l_history_data :=p_history_data; --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);

	p_history_data.information1  		:=	p_peranalyses_data.PERSON_ANALYSIS_ID						;
	p_history_data.information5  		:=	p_peranalyses_data.BUSINESS_GROUP_ID						;
	p_history_data.information6  		:=	p_peranalyses_data.ANALYSIS_CRITERIA_ID						;
	p_history_data.information7  		:=	p_peranalyses_data.PERSON_ID								;
	p_history_data.information8  		:=	p_peranalyses_data.COMMENTS								;
	p_history_data.information9  		:=	to_char(p_peranalyses_data.DATE_FROM,g_hist_date_format)		;
	p_history_data.information10  	:=	to_char(p_peranalyses_data.DATE_TO,g_hist_date_format)			;
	p_history_data.information11  	:=	p_peranalyses_data.ID_FLEX_NUM							;
	p_history_data.information121 	:=	p_peranalyses_data.REQUEST_ID								;
	p_history_data.information122  	:=	p_peranalyses_data.PROGRAM_APPLICATION_ID						;
	p_history_data.information123  	:=	p_peranalyses_data.PROGRAM_ID								;
	p_history_data.information124  	:=	to_char(p_peranalyses_data.PROGRAM_UPDATE_DATE,g_hist_date_format)	;
	p_history_data.information125  	:=	p_peranalyses_data.ATTRIBUTE_CATEGORY						;
	p_history_data.information126  	:=	p_peranalyses_data.ATTRIBUTE1 	;
	p_history_data.information127  	:=	p_peranalyses_data.ATTRIBUTE2 	;
	p_history_data.information128  	:=	p_peranalyses_data.ATTRIBUTE3 	;
	p_history_data.information129  	:=	p_peranalyses_data.ATTRIBUTE4 	;
	p_history_data.information130		:=	p_peranalyses_data.ATTRIBUTE5 	;
	p_history_data.information131  	:=	p_peranalyses_data.ATTRIBUTE6 	;
	p_history_data.information132  	:=	p_peranalyses_data.ATTRIBUTE7 	;
	p_history_data.information133		:=	p_peranalyses_data.ATTRIBUTE8 	;
	p_history_data.information134  	:=	p_peranalyses_data.ATTRIBUTE9		;
	p_history_data.information135  	:=	p_peranalyses_data.ATTRIBUTE10	;
	p_history_data.information136		:=	p_peranalyses_data.ATTRIBUTE11	;
	p_history_data.information137  	:=	p_peranalyses_data.ATTRIBUTE12	;
	p_history_data.information138  	:=	p_peranalyses_data.ATTRIBUTE13	;
	p_history_data.information139		:=	p_peranalyses_data.ATTRIBUTE14	;
	p_history_data.information140  	:=	p_peranalyses_data.ATTRIBUTE15	;
	p_history_data.information141  	:=	p_peranalyses_data.ATTRIBUTE16	;
	p_history_data.information142		:=	p_peranalyses_data.ATTRIBUTE17	;
	p_history_data.information143  	:=	p_peranalyses_data.ATTRIBUTE18	;
	p_history_data.information144  	:=	p_peranalyses_data.ATTRIBUTE19	;
	p_history_data.information145		:=	p_peranalyses_data.ATTRIBUTE20	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_history_data :=l_history_data;
     raise;

end conv_peranalyses_rg_to_hist_rg;

--procedure conv_to_peranalyses_rg converts the  ghr_person_analyses_history
--record type to person analysis_rg
Procedure conv_to_peranalyses_rg(
	p_history_data 	      in   	ghr_pa_history%rowtype,
	p_peranalyses_data  in out nocopy per_person_analyses%rowtype) as

	l_proc	 varchar2(30) := 'conv_to_peranalyses_rg';
        l_peranalyses_data   per_person_analyses%rowtype;
begin

	l_peranalyses_data  :=p_peranalyses_data; --NOCOPY Changes
	hr_utility.set_location('entering:'|| l_proc, 5);

	p_peranalyses_data.PERSON_ANALYSIS_ID   	:=	p_history_data.information1  						;
	p_peranalyses_data.BUSINESS_GROUP_ID	:=	p_history_data.information5  						;
	p_peranalyses_data.ANALYSIS_CRITERIA_ID	:=	p_history_data.information6  						;
	p_peranalyses_data.PERSON_ID			:=	p_history_data.information7  						;
	p_peranalyses_data.COMMENTS              	:=	p_history_data.information8  						;
	p_peranalyses_data.DATE_FROM	       	:=	to_date(p_history_data.information9,g_hist_date_format)	;
	p_peranalyses_data.DATE_TO                :=	to_date(p_history_data.information10,g_hist_date_format);
	p_peranalyses_data.ID_FLEX_NUM            :=	p_history_data.information11  					;
	p_peranalyses_data.REQUEST_ID             :=	p_history_data.information121 					;
	p_peranalyses_data.PROGRAM_APPLICATION_ID :=	p_history_data.information122  					;
	p_peranalyses_data.PROGRAM_ID             :=	p_history_data.information123  					;
	p_peranalyses_data.PROGRAM_UPDATE_DATE    :=	to_date(p_history_data.information124,g_hist_date_format);
	p_peranalyses_data.ATTRIBUTE_CATEGORY     :=	p_history_data.information125  	;
	p_peranalyses_data.ATTRIBUTE1             :=	p_history_data.information126  	;
	p_peranalyses_data.ATTRIBUTE2             :=	p_history_data.information127  	;
	p_peranalyses_data.ATTRIBUTE3             :=	p_history_data.information128  	;
	p_peranalyses_data.ATTRIBUTE4             :=	p_history_data.information129  	;
	p_peranalyses_data.ATTRIBUTE5             :=	p_history_data.information130		;
	p_peranalyses_data.ATTRIBUTE6             :=	p_history_data.information131  	;
	p_peranalyses_data.ATTRIBUTE7             :=	p_history_data.information132  	;
	p_peranalyses_data.ATTRIBUTE8             :=	p_history_data.information133		;
	p_peranalyses_data.ATTRIBUTE9             :=	p_history_data.information134  	;
	p_peranalyses_data.ATTRIBUTE10            :=	p_history_data.information135  	;
	p_peranalyses_data.ATTRIBUTE11            :=	p_history_data.information136		;
	p_peranalyses_data.ATTRIBUTE12            :=	p_history_data.information137  	;
	p_peranalyses_data.ATTRIBUTE13            :=	p_history_data.information138  	;
	p_peranalyses_data.ATTRIBUTE14            :=	p_history_data.information139		;
	p_peranalyses_data.ATTRIBUTE15            :=	p_history_data.information140  	;
	p_peranalyses_data.ATTRIBUTE16            :=	p_history_data.information141  	;
	p_peranalyses_data.ATTRIBUTE17            :=	p_history_data.information142		;
	p_peranalyses_data.ATTRIBUTE18            :=	p_history_data.information143  	;
	p_peranalyses_data.ATTRIBUTE19            :=	p_history_data.information144  	;
	p_peranalyses_data.ATTRIBUTE20            :=	p_history_data.information145		;

	hr_utility.set_location(' leaving:'||l_proc, 10);

  EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_peranalyses_data  :=l_peranalyses_data;
     raise;

end conv_to_peranalyses_rg;



-- Procedure conv_to_peranalyses_rg converts the ghr_person_analysis record to
-- to the per_person_analysis record
Procedure conv_to_peranalyses_rg(p_peranalyses_h_v    in ghr_person_analyses_h_v%rowtype,
                             	   p_peranalyses_data  out nocopy per_person_analyses%rowtype) is

	l_proc			varchar2(30) := 'Conv_to_peranalyses_rg';
	l_peranalyses_data	per_person_analyses%rowtype;

Begin

	hr_utility.set_location('Entering : ' || l_proc, 100);
	conv_to_peranalyses_rg(
		p_PERSON_ANALYSIS_ID              	=>	 p_peranalyses_h_v.PERSON_ANALYSIS_ID        ,
		p_BUSINESS_GROUP_ID               	=>	 p_peranalyses_h_v.BUSINESS_GROUP_ID         ,
		p_ANALYSIS_CRITERIA_ID            	=>	 p_peranalyses_h_v.ANALYSIS_CRITERIA_ID      ,
 		p_PERSON_ID                       	=>	 p_peranalyses_h_v.PERSON_ID                 ,
 		p_COMMENTS                          =>	 p_peranalyses_h_v.COMMENTS                  ,
		p_DATE_FROM                         =>	 p_peranalyses_h_v.DATE_FROM                 ,
		p_DATE_TO                           =>	 p_peranalyses_h_v.DATE_TO                   ,
		p_ID_FLEX_NUM                       =>	 p_peranalyses_h_v.ID_FLEX_NUM               ,
		p_REQUEST_ID                        =>	 p_peranalyses_h_v.REQUEST_ID                ,
		p_PROGRAM_APPLICATION_ID            =>	 p_peranalyses_h_v.PROGRAM_APPLICATION_ID    ,
		p_PROGRAM_ID                        =>	 p_peranalyses_h_v.PROGRAM_ID                ,
		p_PROGRAM_UPDATE_DATE               =>	 p_peranalyses_h_v.PROGRAM_UPDATE_DATE       ,
		p_ATTRIBUTE_CATEGORY              	=>	 p_peranalyses_h_v.ATTRIBUTE_CATEGORY        ,
		p_ATTRIBUTE1                        =>	 p_peranalyses_h_v.ATTRIBUTE1                ,
		p_ATTRIBUTE2                        =>	 p_peranalyses_h_v.ATTRIBUTE2                ,
		p_ATTRIBUTE3                        =>	 P_peranalyses_H_V.ATTRIBUTE3                ,
		p_ATTRIBUTE4                        =>	 P_peranalyses_H_V.ATTRIBUTE4                ,
		p_ATTRIBUTE5                        =>	 P_peranalyses_H_V.ATTRIBUTE5                ,
		p_ATTRIBUTE6                        =>	 P_peranalyses_H_V.ATTRIBUTE6                ,
		p_ATTRIBUTE7                        =>	 P_peranalyses_H_V.ATTRIBUTE7                ,
		p_ATTRIBUTE8                        =>	 P_peranalyses_H_V.ATTRIBUTE8                ,
		p_ATTRIBUTE9                        =>	 P_peranalyses_H_V.ATTRIBUTE9                ,
		p_ATTRIBUTE10                       =>	 P_peranalyses_H_V.ATTRIBUTE10               ,
		p_ATTRIBUTE11                       =>	 P_peranalyses_H_V.ATTRIBUTE11               ,
		p_ATTRIBUTE12                       =>	 P_peranalyses_H_V.ATTRIBUTE12               ,
		p_ATTRIBUTE13                       =>	 P_peranalyses_H_V.ATTRIBUTE13               ,
		p_ATTRIBUTE14                       =>	 P_peranalyses_H_V.ATTRIBUTE14               ,
		p_ATTRIBUTE15                       =>	 P_peranalyses_H_V.ATTRIBUTE15               ,
		p_ATTRIBUTE16                       =>	 P_peranalyses_H_V.ATTRIBUTE16               ,
		p_ATTRIBUTE17                       =>	 P_peranalyses_H_V.ATTRIBUTE17               ,
		p_ATTRIBUTE18                       =>	 P_peranalyses_H_V.ATTRIBUTE18               ,
		p_ATTRIBUTE19                       =>	 P_peranalyses_H_V.ATTRIBUTE19               ,
		p_ATTRIBUTE20                       =>	 P_peranalyses_H_V.ATTRIBUTE20               ,
		p_peranalyses_data		  	=>     l_peranalyses_data);

	p_peranalyses_data	:=	l_peranalyses_data;

 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_peranalyses_data  :=NULL;
     raise;


end conv_to_peranalyses_rg;


-- Procedure conv_to_peranalyses_rg copies the individual fields supplied as parameters
-- to the per_person_analysis type record.
Procedure conv_to_peranalyses_rg(

	 p_person_analysis_id           in	 per_person_analyses.person_analysis_id%type		default null,
	 p_business_group_id            in	 per_person_analyses.business_group_id%type		default null,
	 p_analysis_criteria_id         in	 per_person_analyses.analysis_criteria_id%type		default null,
	 p_person_id                    in	 per_person_analyses.person_id%type				default null,
	 p_comments                     in	 per_person_analyses.comments%type				default null,
	 p_date_from                    in	 per_person_analyses.date_from%type				default null,
	 p_date_to                      in	 per_person_analyses.date_to%type				default null,
	 p_id_flex_num                  in	 per_person_analyses.id_flex_num%type			default null,
	 p_request_id                   in	 per_person_analyses.request_id%type			default null,
	 p_program_application_id       in	 per_person_analyses.program_application_id%type	default null,
	 p_program_id                   in	 per_person_analyses.program_id%type		default null,
	 p_program_update_date          in	 per_person_analyses.program_update_date%type	default null,
	 p_attribute_category           in	 per_person_analyses.attribute_category%type	default null,
	 p_attribute1                   in	 per_person_analyses.attribute1%type		default null,
	 p_attribute2                   in	 per_person_analyses.attribute2%type		default null,
	 p_attribute3                   in	 per_person_analyses.attribute3%type		default null,
	 p_attribute4                   in	 per_person_analyses.attribute4%type		default null,
	 p_attribute5                   in	 per_person_analyses.attribute5%type		default null,
	 p_attribute6                   in	 per_person_analyses.attribute6%type		default null,
	 p_attribute7                   in	 per_person_analyses.attribute7%type		default null,
	 p_attribute8                   in	 per_person_analyses.attribute8%type		default null,
	 p_attribute9                   in	 per_person_analyses.attribute9%type		default null,
	 p_attribute10                  in	 per_person_analyses.attribute10%type		default null,
	 p_attribute11                  in	 per_person_analyses.attribute11%type		default null,
	 p_attribute12                  in	 per_person_analyses.attribute12%type		default null,
	 p_attribute13                  in	 per_person_analyses.attribute13%type		default null,
	 p_attribute14                  in	 per_person_analyses.attribute14%type		default null,
	 p_attribute15                  in	 per_person_analyses.attribute15%type		default null,
	 p_attribute16                  in	 per_person_analyses.attribute16%type		default null,
	 p_attribute17                  in	 per_person_analyses.attribute17%type		default null,
	 p_attribute18                  in	 per_person_analyses.attribute18%type		default null,
	 p_attribute19                  in	 per_person_analyses.attribute19%type		default null,
	 p_attribute20                  in	 per_person_analyses.attribute20%type		default null,
 	 p_peranalyses_data	    in out nocopy	 per_person_analyses%rowtype  )  as

	l_proc	varchar2(30):='conv_to_peranalyses_rg';
	l_peranalyses_data  per_person_analyses%rowtype;

begin


  	l_peranalyses_data :=p_peranalyses_data; --NOCOPY Changes

	hr_utility.set_location('Entering:'|| l_proc, 5);

	 copy_field_value( p_source_field =>  p_person_analysis_id,
				 p_target_field =>  p_peranalyses_data.person_analysis_id);
	 copy_field_value( p_source_field =>  p_business_group_id,
				 p_target_field =>  p_peranalyses_data.business_group_id);
	 copy_field_value( p_source_field =>  p_analysis_criteria_id,
				 p_target_field =>  p_peranalyses_data.analysis_criteria_id);
	 copy_field_value( p_source_field =>  p_person_id,
				 p_target_field =>  p_peranalyses_data.person_id);
	 copy_field_value( p_source_field =>  p_comments,
				 p_target_field =>  p_peranalyses_data.comments);
	 copy_field_value( p_source_field =>  p_date_from,
				 p_target_field =>  p_peranalyses_data.date_from);
	 copy_field_value( p_source_field =>  p_date_to,
				 p_target_field =>  p_peranalyses_data.date_to);
	 copy_field_value( p_source_field =>  p_id_flex_num,
				 p_target_field =>  p_peranalyses_data.id_flex_num);
	 copy_field_value( p_source_field =>  p_request_id,
				 p_target_field =>  p_peranalyses_data.request_id);
	 copy_field_value( p_source_field =>  p_program_application_id,
				 p_target_field =>  p_peranalyses_data.program_application_id);
	 copy_field_value( p_source_field =>  p_program_id,
				 p_target_field =>  p_peranalyses_data.program_id);
	 copy_field_value( p_source_field =>  p_program_update_date,
				 p_target_field =>  p_peranalyses_data.program_update_date);
	 copy_field_value( p_source_field =>  p_attribute_category,
				 p_target_field =>  p_peranalyses_data.attribute_category);
	 copy_field_value( p_source_field =>  p_attribute1,
				 p_target_field =>  p_peranalyses_data.attribute1);
	 copy_field_value( p_source_field =>  p_attribute2,
				 p_target_field =>  p_peranalyses_data.attribute2);
	 copy_field_value( p_source_field =>  p_attribute3,
				 p_target_field =>  p_peranalyses_data.attribute3);
	 copy_field_value( p_source_field =>  p_attribute4,
				 p_target_field =>  p_peranalyses_data.attribute4);
	 copy_field_value( p_source_field =>  p_attribute5,
				 p_target_field =>  p_peranalyses_data.attribute5);
	 copy_field_value( p_source_field =>  p_attribute6,
				 p_target_field =>  p_peranalyses_data.attribute6);
	 copy_field_value( p_source_field =>  p_attribute7,
				 p_target_field =>  p_peranalyses_data.attribute7);
	 copy_field_value( p_source_field =>  p_attribute8,
				 p_target_field =>  p_peranalyses_data.attribute8);
	 copy_field_value( p_source_field =>  p_attribute9,
				 p_target_field =>  p_peranalyses_data.attribute9);
	 copy_field_value( p_source_field =>  p_attribute10,
				 p_target_field =>  p_peranalyses_data.attribute10);
	 copy_field_value( p_source_field =>  p_attribute11,
				 p_target_field =>  p_peranalyses_data.attribute11);
	 copy_field_value( p_source_field =>  p_attribute12,
				 p_target_field =>  p_peranalyses_data.attribute12);
	 copy_field_value( p_source_field =>  p_attribute13,
				 p_target_field =>  p_peranalyses_data.attribute13);
	 copy_field_value( p_source_field =>  p_attribute14,
				 p_target_field =>  p_peranalyses_data.attribute14);
	 copy_field_value( p_source_field =>  p_attribute15,
				 p_target_field =>  p_peranalyses_data.attribute15);
	 copy_field_value( p_source_field =>  p_attribute16,
				 p_target_field =>  p_peranalyses_data.attribute16);
	 copy_field_value( p_source_field =>  p_attribute17,
				 p_target_field =>  p_peranalyses_data.attribute17);
	 copy_field_value( p_source_field =>  p_attribute18,
				 p_target_field =>  p_peranalyses_data.attribute18);
	 copy_field_value( p_source_field =>  p_attribute19,
				 p_target_field =>  p_peranalyses_data.attribute19);
	 copy_field_value( p_source_field =>  p_attribute20,
                         p_target_field =>  p_peranalyses_data.attribute20);

 	hr_utility.set_location('Leaving:'|| l_proc, 5);

 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_peranalyses_data  :=l_peranalyses_data;
     raise;



end conv_to_peranalyses_rg;

Procedure convert_shadow_to_sf52 (
	p_shadow	 in   ghr_pa_request_shadow%rowtype,
	p_sf52	out nocopy	ghr_pa_requests%rowtype) is

Begin

    p_sf52.pa_request_id                     := p_shadow.pa_request_id                ;
    p_sf52.academic_discipline               := p_shadow.academic_discipline          ;
    p_sf52.annuitant_indicator               := p_shadow.annuitant_indicator          ;
    p_sf52.appropriation_code1               := p_shadow.appropriation_code1          ;
    p_sf52.appropriation_code2               := p_shadow.appropriation_code2          ;
    p_sf52.bargaining_unit_status            := p_shadow.bargaining_unit_status       ;
    p_sf52.citizenship                       := p_shadow.citizenship                  ;
    p_sf52.duty_station_id                   := p_shadow.duty_station_id              ;
    p_sf52.duty_station_location_id          := p_shadow.duty_station_location_id     ;
    p_sf52.education_level                   := p_shadow.education_level              ;
    p_sf52.fegli                             := p_shadow.fegli                        ;
    p_sf52.flsa_category                     := p_shadow.flsa_category                ;
    p_sf52.forwarding_address_line1          := p_shadow.forwarding_address_line1 ;
    p_sf52.forwarding_address_line2          := p_shadow.forwarding_address_line2 ;
    p_sf52.forwarding_address_line3          := p_shadow.forwarding_address_line3  ;
    p_sf52.forwarding_country_short_name     := p_shadow.forwarding_country_short_name;
    p_sf52.forwarding_postal_code            := p_shadow.forwarding_postal_code       ;
    p_sf52.forwarding_region_2               := p_shadow.forwarding_region_2          ;
    p_sf52.forwarding_town_or_city           := p_shadow.forwarding_town_or_city      ;
    p_sf52.functional_class                  := p_shadow.functional_class             ;
    p_sf52.part_time_hours                   := p_shadow.part_time_hours              ;
    p_sf52.pay_rate_determinant              := p_shadow.pay_rate_determinant         ;
    p_sf52.position_occupied                 := p_shadow.position_occupied            ;
    p_sf52.retirement_plan                   := p_shadow.retirement_plan              ;
    p_sf52.service_comp_date                 := p_shadow.service_comp_date            ;
    p_sf52.supervisory_status                := p_shadow.supervisory_status           ;
    p_sf52.tenure                            := p_shadow.tenure                       ;
    p_sf52.to_ap_premium_pay_indicator       := p_shadow.to_ap_premium_pay_indicator  ;
    p_sf52.to_auo_premium_pay_indicator      := p_shadow.to_auo_premium_pay_indicator ;
    p_sf52.to_occ_code                       := p_shadow.to_occ_code                  ;
    p_sf52.to_position_id                    := p_shadow.to_position_id               ;
    p_sf52.to_retention_allowance            := p_shadow.to_retention_allowance       ;
    p_sf52.to_retention_allow_percentage     := p_shadow.to_retention_allow_percentage;
    p_sf52.to_staffing_differential          := p_shadow.to_staffing_differential     ;
    p_sf52.to_staffing_diff_percentage       := p_shadow.to_staffing_diff_percentage     ;
    p_sf52.to_step_or_rate                   := p_shadow.to_step_or_rate              ;
    p_sf52.to_supervisory_differential       := p_shadow.to_supervisory_differential  ;
    p_sf52.to_supervisory_diff_percentage    := p_shadow.to_supervisory_diff_percentage;
    p_sf52.veterans_preference               := p_shadow.veterans_preference          ;
    p_sf52.veterans_pref_for_rif             := p_shadow.veterans_pref_for_rif        ;
    p_sf52.veterans_status                   := p_shadow.veterans_status              ;
    p_sf52.work_schedule                     := p_shadow.work_schedule                ;
    p_sf52.year_degree_attained              := p_shadow.year_degree_attained         ;

 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_sf52  :=NULL;
     raise;

End;

Procedure convert_sf52_to_shadow (
	p_sf52	 in	ghr_pa_requests%rowtype,
	p_shadow	out nocopy   ghr_pa_request_shadow%rowtype
) is

Begin

    p_shadow.pa_request_id                     := p_sf52.pa_request_id                ;
    p_shadow.academic_discipline               := p_sf52.academic_discipline          ;
    p_shadow.annuitant_indicator               := p_sf52.annuitant_indicator          ;
    p_shadow.appropriation_code1               := p_sf52.appropriation_code1          ;
    p_shadow.appropriation_code2               := p_sf52.appropriation_code2          ;
    p_shadow.bargaining_unit_status            := p_sf52.bargaining_unit_status       ;
    p_shadow.citizenship                       := p_sf52.citizenship                  ;
    p_shadow.duty_station_id                   := p_sf52.duty_station_id              ;
    p_shadow.duty_station_location_id          := p_sf52.duty_station_location_id     ;
    p_shadow.education_level                   := p_sf52.education_level              ;
    p_shadow.fegli                             := p_sf52.fegli                        ;
    p_shadow.flsa_category                     := p_sf52.flsa_category                ;
    p_shadow.forwarding_address_line1          := p_sf52.forwarding_address_line1 ;
    p_shadow.forwarding_address_line2          := p_sf52.forwarding_address_line2 ;
    p_shadow.forwarding_address_line3          := p_sf52.forwarding_address_line3  ;
    p_shadow.forwarding_country_short_name     := p_sf52.forwarding_country_short_name;
    p_shadow.forwarding_postal_code            := p_sf52.forwarding_postal_code       ;
    p_shadow.forwarding_region_2               := p_sf52.forwarding_region_2          ;
    p_shadow.forwarding_town_or_city           := p_sf52.forwarding_town_or_city      ;
    p_shadow.functional_class                  := p_sf52.functional_class             ;
    p_shadow.part_time_hours                   := p_sf52.part_time_hours              ;
    p_shadow.pay_rate_determinant              := p_sf52.pay_rate_determinant         ;
    p_shadow.position_occupied                 := p_sf52.position_occupied            ;
    p_shadow.retirement_plan                   := p_sf52.retirement_plan              ;
    p_shadow.service_comp_date                 := p_sf52.service_comp_date            ;
    p_shadow.supervisory_status                := p_sf52.supervisory_status           ;
    p_shadow.tenure                            := p_sf52.tenure                       ;
    p_shadow.to_ap_premium_pay_indicator       := p_sf52.to_ap_premium_pay_indicator  ;
    p_shadow.to_auo_premium_pay_indicator      := p_sf52.to_auo_premium_pay_indicator ;
    p_shadow.to_occ_code                       := p_sf52.to_occ_code                  ;
    p_shadow.to_position_id                    := p_sf52.to_position_id               ;
    p_shadow.to_retention_allowance            := p_sf52.to_retention_allowance       ;
    p_shadow.to_retention_allow_percentage     := p_sf52.to_retention_allow_percentage;
    p_shadow.to_staffing_differential          := p_sf52.to_staffing_differential     ;
    p_shadow.to_staffing_diff_percentage       := p_sf52.to_staffing_diff_percentage  ;
    p_shadow.to_step_or_rate                   := p_sf52.to_step_or_rate              ;
    p_shadow.to_supervisory_differential       := p_sf52.to_supervisory_differential  ;
    p_shadow.to_supervisory_diff_percentage    := p_sf52.to_supervisory_diff_percentage;
    p_shadow.veterans_preference               := p_sf52.veterans_preference          ;
    p_shadow.veterans_pref_for_rif             := p_sf52.veterans_pref_for_rif        ;
    p_shadow.veterans_status                   := p_sf52.veterans_status              ;
    p_shadow.work_schedule                     := p_sf52.work_schedule                ;
    p_shadow.year_degree_attained              := p_sf52.year_degree_attained         ;


 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_shadow  :=NULL;
     raise;


End;



/* Deleted for New Position table functions (date tracked)

-- Procedure conv_to_position_rg. Copies the individual fields supplied as parameters
-- to the per_position type record.
Procedure conv_to_position_rg(
	p_position_id			in per_positions.position_id%type			default	null,
	p_business_group_id		in per_positions.business_group_id%type		default	null,
	p_job_id				in per_positions.job_id%type				default	null,
	p_organization_id			in per_positions.organization_id%type		default	null,
	p_successor_position_id		in per_positions.successor_position_id%type	default	null,
	p_relief_position_id		in per_positions.relief_position_id%type		default	null,
	p_location_id			in per_positions.location_id%type			default	null,
	p_position_definition_id	in per_positions.position_definition_id%type	default	null,
	p_date_effective			in per_positions.date_effective%type		default	null,
	p_date_end				in per_positions.date_end%type			default	null,
	p_frequency				in per_positions.frequency%type			default	null,
	p_name				in per_positions.name%type				default	null,
	p_probation_period		in per_positions.probation_period%type		default	null,
	p_probation_period_units	in per_positions.probation_period_units%type	default	null,
	p_replacement_required_flag	in per_positions.replacement_required_flag%type	default	null,
	p_time_normal_finish		in per_positions.time_normal_finish%type		default	null,
	p_time_normal_start		in per_positions.time_normal_start%type		default	null,
	p_working_hours			in per_positions.working_hours%type			default	null,
	p_request_id			in per_positions.request_id%type			default	null,
	p_program_application_id	in per_positions.program_application_id%type	default	null,
	p_program_id			in per_positions.program_id%type			default	null,
	p_program_update_date		in per_positions.program_update_date%type		default	null,
	p_attribute_category		in per_positions.attribute_category%type		default	null,
	p_attribute1			in per_positions.attribute1%type			default	null,
	p_attribute2			in per_positions.attribute2%type			default	null,
	p_attribute3			in per_positions.attribute3%type			default	null,
	p_attribute4			in per_positions.attribute4%type			default	null,
	p_attribute5			in per_positions.attribute5%type			default	null,
	p_attribute6			in per_positions.attribute6%type			default	null,
	p_attribute7			in per_positions.attribute7%type			default	null,
	p_attribute8			in per_positions.attribute8%type			default	null,
	p_attribute9			in per_positions.attribute9%type			default	null,
	p_attribute10			in per_positions.attribute10%type			default	null,
	p_attribute11			in per_positions.attribute11%type			default	null,
	p_attribute12			in per_positions.attribute12%type			default	null,
	p_attribute13			in per_positions.attribute13%type			default	null,
	p_attribute14			in per_positions.attribute14%type			default	null,
	p_attribute15			in per_positions.attribute15%type			default	null,
	p_attribute16			in per_positions.attribute16%type			default	null,
	p_attribute17			in per_positions.attribute17%type			default	null,
	p_attribute18			in per_positions.attribute18%type			default	null,
	p_attribute19			in per_positions.attribute19%type			default	null,
	p_attribute20			in per_positions.attribute20%type			default	null,
	p_status				in per_positions.status%type				default	null,
	p_position_data		in	out per_positions%rowtype  )  is

	l_proc	varchar2(30):='conv_to_position_rg';

begin
 	hr_utility.set_location('Entering:'|| l_proc, 5);
	copy_field_value(	p_source_field => p_position_id,
				p_target_field => p_position_data.position_id);
	copy_field_value(	p_source_field => p_business_group_id,
				p_target_field => p_position_data.business_group_id);
	copy_field_value(	p_source_field => p_job_id,
				p_target_field => p_position_data.job_id);
	copy_field_value(	p_source_field => p_organization_id,
				p_target_field => p_position_data.organization_id);
	copy_field_value(	p_source_field => p_successor_position_id,
				p_target_field => p_position_data.successor_position_id);
	copy_field_value(	p_source_field => p_relief_position_id,
				p_target_field => p_position_data.relief_position_id);
	copy_field_value(	p_source_field => p_location_id,
				p_target_field => p_position_data.location_id);
	copy_field_value(	p_source_field => p_position_definition_id,
				p_target_field => p_position_data.position_definition_id);
	copy_field_value(	p_source_field => p_date_effective,
				p_target_field => p_position_data.date_effective);
	copy_field_value(	p_source_field => p_date_end,
				p_target_field => p_position_data.date_end);
	copy_field_value(	p_source_field => p_frequency,
				p_target_field => p_position_data.frequency);
	copy_field_value(	p_source_field => p_name,
				p_target_field => p_position_data.name);
	copy_field_value(	p_source_field => p_probation_period,
				p_target_field => p_position_data.probation_period);
	copy_field_value(	p_source_field => p_probation_period_units,
				p_target_field => p_position_data.probation_period_units);
	copy_field_value(	p_source_field => p_replacement_required_flag,
				p_target_field => p_position_data.replacement_required_flag);
	copy_field_value(	p_source_field => p_time_normal_finish,
				p_target_field => p_position_data.time_normal_finish);
	copy_field_value(	p_source_field => p_time_normal_start,
				p_target_field => p_position_data.time_normal_start);
	copy_field_value(	p_source_field => p_working_hours,
				p_target_field => p_position_data.working_hours);
	copy_field_value(	p_source_field => p_request_id,
				p_target_field => p_position_data.request_id);
	copy_field_value(	p_source_field => p_program_application_id,
				p_target_field => p_position_data.program_application_id);
	copy_field_value(	p_source_field => p_program_id,
				p_target_field => p_position_data.program_id);
	copy_field_value(	p_source_field => p_program_update_date,
				p_target_field => p_position_data.program_update_date);
	copy_field_value(	p_source_field => p_attribute_category,
				p_target_field => p_position_data.attribute_category);
	copy_field_value(	p_source_field => p_attribute1,
				p_target_field => p_position_data.attribute1);
	copy_field_value(	p_source_field => p_attribute2,
				p_target_field => p_position_data.attribute2);
	copy_field_value(	p_source_field => p_attribute3,
				p_target_field => p_position_data.attribute3);
	copy_field_value(	p_source_field => p_attribute4,
				p_target_field => p_position_data.attribute4);
	copy_field_value(	p_source_field => p_attribute5,
				p_target_field => p_position_data.attribute5);
	copy_field_value(	p_source_field => p_attribute6,
				p_target_field => p_position_data.attribute6);
	copy_field_value(	p_source_field => p_attribute7,
				p_target_field => p_position_data.attribute7);
	copy_field_value(	p_source_field => p_attribute8,
				p_target_field => p_position_data.attribute8);
	copy_field_value(	p_source_field => p_attribute9,
				p_target_field => p_position_data.attribute9);
	copy_field_value(	p_source_field => p_attribute10,
				p_target_field => p_position_data.attribute10);
	copy_field_value(	p_source_field => p_attribute11,
				p_target_field => p_position_data.attribute11);
	copy_field_value(	p_source_field => p_attribute12,
				p_target_field => p_position_data.attribute12);
	copy_field_value(	p_source_field => p_attribute13,
				p_target_field => p_position_data.attribute13);
	copy_field_value(	p_source_field => p_attribute14,
				p_target_field => p_position_data.attribute14);
	copy_field_value(	p_source_field => p_attribute15,
				p_target_field => p_position_data.attribute15);
	copy_field_value(	p_source_field => p_attribute16,
				p_target_field => p_position_data.attribute16);
	copy_field_value(	p_source_field => p_attribute17,
				p_target_field => p_position_data.attribute17);
	copy_field_value(	p_source_field => p_attribute18,
				p_target_field => p_position_data.attribute18);
	copy_field_value(	p_source_field => p_attribute19,
				p_target_field => p_position_data.attribute19);
	copy_field_value(	p_source_field => p_attribute20,
				p_target_field => p_position_data.attribute20);
	copy_field_value(	p_source_field => p_status,
				p_target_field => p_position_data.status);
 	hr_utility.set_location('Entering:'|| l_proc, 10);

end conv_to_position_rg;
--
-- Procedure to convert the position history view rg to the position rg.
--
Procedure conv_to_position_rg (
       p_position_h_v  in  ghr_positions_h_v%rowtype,
       p_position_data out per_positions%rowtype) is

       l_proc		varchar2(30):='Conv_to_position_rg';
       l_position_data	per_positions%rowtype;
Begin
	hr_utility.set_location('Entering : ' || l_proc, 100);
	Conv_to_position_rg(
			p_position_id			=>	p_position_h_v.position_id			,
			p_business_group_id		=>	p_position_h_v.business_group_id		,
			p_job_id				=>	p_position_h_v.job_id				,
			p_organization_id			=>	p_position_h_v.organization_id		,
			p_successor_position_id		=>	p_position_h_v.successor_position_id	,
			p_relief_position_id		=>	p_position_h_v.relief_position_id		,
			p_location_id			=>	p_position_h_v.location_id			,
			p_position_definition_id	=>	p_position_h_v.position_definition_id	,
			p_date_effective			=>	p_position_h_v.date_effective			,
			p_date_end				=>	p_position_h_v.date_end				,
			p_frequency				=>	p_position_h_v.frequency			,
			p_name				=>	p_position_h_v.name				,
			p_probation_period		=>	p_position_h_v.probation_period		,
			p_probation_period_units	=>	p_position_h_v.probation_period_units	,
			p_replacement_required_flag	=>	p_position_h_v.replacement_required_flag	,
			p_time_normal_finish		=>	p_position_h_v.time_normal_finish		,
			p_time_normal_start		=>	p_position_h_v.time_normal_start		,
			p_working_hours			=>	p_position_h_v.working_hours			,
			p_request_id			=>	p_position_h_v.request_id			,
			p_program_application_id	=>	p_position_h_v.program_application_id	,
			p_program_id			=>	p_position_h_v.program_id			,
			p_program_update_date		=>	p_position_h_v.program_update_date		,
			p_attribute_category		=>	p_position_h_v.attribute_category		,
			p_attribute1			=>	p_position_h_v.attribute1			,
			p_attribute2			=>	p_position_h_v.attribute2			,
			p_attribute3			=>	p_position_h_v.attribute3			,
			p_attribute4			=>	p_position_h_v.attribute4			,
			p_attribute5			=>	p_position_h_v.attribute5			,
			p_attribute6			=>	p_position_h_v.attribute6			,
			p_attribute7			=>	p_position_h_v.attribute7			,
			p_attribute8			=>	p_position_h_v.attribute8			,
			p_attribute9			=>	p_position_h_v.attribute9			,
			p_attribute10			=>	p_position_h_v.attribute10			,
			p_attribute11			=>	p_position_h_v.attribute11			,
			p_attribute12			=>	p_position_h_v.attribute12			,
			p_attribute13			=>	p_position_h_v.attribute13			,
			p_attribute14			=>	p_position_h_v.attribute14			,
			p_attribute15			=>	p_position_h_v.attribute15			,
			p_attribute16			=>	p_position_h_v.attribute16			,
			p_attribute17			=>	p_position_h_v.attribute17			,
			p_attribute18			=>	p_position_h_v.attribute18			,
			p_attribute19			=>	p_position_h_v.attribute19			,
			p_attribute20			=>	p_position_h_v.attribute20			,
			p_status				=>	p_position_h_v.status                     ,
                  p_position_data               =>    l_position_data
                 );

	p_position_data := l_position_data;
	hr_utility.set_location('Leaving : ' || l_proc, 200);

End Conv_to_position_rg;
--
-- procedure to convert Position RG to Position History RG
-- ghr_pa_history record type
--
Procedure conv_position_rg_to_hist_rg(
	p_position_data        in  per_positions%rowtype,
	p_history_data     in out  ghr_pa_history%rowtype) as

	l_proc	 varchar2(30) := 'conv_position_rg_to_hist_rg';

begin
	hr_utility.set_location('entering:'|| l_proc, 5);
	p_history_data.information1	:=	p_position_data.position_id;
	p_history_data.information4	:=	to_char(p_position_data.date_effective, g_hist_date_format);
	p_history_data.information5	:=	to_char(p_position_data.date_end, g_hist_date_format);
	p_history_data.information6	:=	p_position_data.name;
	p_history_data.information7	:=	p_position_data.relief_position_id;
	p_history_data.information8	:=	p_position_data.location_id;
	p_history_data.information9	:=	p_position_data.position_definition_id;
	p_history_data.information10	:=	p_position_data.job_id;
	p_history_data.information12	:=	p_position_data.organization_id;
	p_history_data.information13	:=	p_position_data.frequency;
	p_history_data.information14	:=	p_position_data.successor_position_id;
	p_history_data.information15	:=	p_position_data.probation_period;
	p_history_data.information16	:=	p_position_data.probation_period_units;
	p_history_data.information17	:=	p_position_data.replacement_required_flag;
	p_history_data.information18	:=	p_position_data.time_normal_finish;
	p_history_data.information19	:=	p_position_data.time_normal_start;
	p_history_data.information20	:=	p_position_data.working_hours;
	p_history_data.information121	:=	p_position_data.status;
	p_history_data.information122	:=	p_position_data.business_group_id;
	p_history_data.information123	:=	p_position_data.request_id;
	p_history_data.information124	:=	p_position_data.program_application_id;
	p_history_data.information125	:=	p_position_data.program_id;
	p_history_data.information126	:=	to_char(p_position_data.program_update_date, g_hist_date_format);
	p_history_data.information127	:=	p_position_data.attribute_category;
	p_history_data.information128	:=	p_position_data.attribute1;
	p_history_data.information129	:=	p_position_data.attribute2;
	p_history_data.information130	:=	p_position_data.attribute3;
	p_history_data.information131	:=	p_position_data.attribute4;
	p_history_data.information132	:=	p_position_data.attribute5;
	p_history_data.information133	:=	p_position_data.attribute6;
	p_history_data.information134	:=	p_position_data.attribute7;
	p_history_data.information135	:=	p_position_data.attribute8;
	p_history_data.information136	:=	p_position_data.attribute9;
	p_history_data.information137	:=	p_position_data.attribute10;
	p_history_data.information138	:=	p_position_data.attribute11;
	p_history_data.information139	:=	p_position_data.attribute12;
	p_history_data.information140	:=	p_position_data.attribute13;
	p_history_data.information141	:=	p_position_data.attribute14;
	p_history_data.information142	:=	p_position_data.attribute15;
	p_history_data.information143	:=	p_position_data.attribute16;
	p_history_data.information144	:=	p_position_data.attribute17;
	p_history_data.information145	:=	p_position_data.attribute18;
	p_history_data.information146	:=	p_position_data.attribute19;
	p_history_data.information147	:=	p_position_data.attribute20;

	hr_utility.set_location(' leaving:'||l_proc, 10);

end conv_position_rg_to_hist_rg;
--
-- Procedure to convert history RG to Position RG
--
Procedure conv_to_position_rg(
	p_history_data   	    in   ghr_pa_history%rowtype,
	p_position_data    in out  per_positions%rowtype)  as

	l_proc	 varchar2(30) := 'conv_to_position_rg';

begin
	hr_utility.set_location('entering:'|| l_proc, 5);

	p_position_data.position_id			:=	p_history_data.information1	;
	p_position_data.date_effective		:=	to_date(p_history_data.information4, g_hist_date_format);
	p_position_data.date_end			:=	to_date(p_history_data.information5, g_hist_date_format);
	p_position_data.name				:=	p_history_data.information6	;
	p_position_data.relief_position_id		:=	p_history_data.information7	;
	p_position_data.location_id			:=	p_history_data.information8	;
	p_position_data.position_definition_id	:=	p_history_data.information9	;
	p_position_data.job_id				:=	p_history_data.information10	;
	p_position_data.organization_id		:=	p_history_data.information12	;
	p_position_data.frequency			:=	p_history_data.information13	;
	p_position_data.successor_position_id	:=	p_history_data.information14	;
	p_position_data.probation_period		:=	p_history_data.information15	;
	p_position_data.probation_period_units	:=	p_history_data.information16	;
	p_position_data.replacement_required_flag	:=	p_history_data.information17	;
	p_position_data.time_normal_finish		:=	p_history_data.information18	;
	p_position_data.time_normal_start		:=	p_history_data.information19	;
	p_position_data.working_hours			:=	p_history_data.information20	;
	p_position_data.status				:=	p_history_data.information121	;
	p_position_data.business_group_id		:=	p_history_data.information122	;
	p_position_data.request_id			:=	p_history_data.information123	;
	p_position_data.program_application_id	:=	p_history_data.information124	;
	p_position_data.program_id			:=	p_history_data.information125	;
	p_position_data.program_update_date		:=	to_date(p_history_data.information126, g_hist_date_format);
	p_position_data.attribute_category		:=	p_history_data.information127	;
	p_position_data.attribute1			:=	p_history_data.information128	;
	p_position_data.attribute2			:=	p_history_data.information129	;
	p_position_data.attribute3			:=	p_history_data.information130	;
	p_position_data.attribute4			:=	p_history_data.information131	;
	p_position_data.attribute5			:=	p_history_data.information132	;
	p_position_data.attribute6			:=	p_history_data.information133	;
	p_position_data.attribute7			:=	p_history_data.information134	;
	p_position_data.attribute8			:=	p_history_data.information135	;
	p_position_data.attribute9			:=	p_history_data.information136	;
	p_position_data.attribute10			:=	p_history_data.information137	;
	p_position_data.attribute11			:=	p_history_data.information138	;
	p_position_data.attribute12			:=	p_history_data.information139	;
	p_position_data.attribute13			:=	p_history_data.information140	;
	p_position_data.attribute14			:=	p_history_data.information141	;
	p_position_data.attribute15			:=	p_history_data.information142	;
	p_position_data.attribute16			:=	p_history_data.information143	;
	p_position_data.attribute17			:=	p_history_data.information144	;
	p_position_data.attribute18			:=	p_history_data.information145	;
	p_position_data.attribute19			:=	p_history_data.information146	;
	p_position_data.attribute20			:=	p_history_data.information147	;

	hr_utility.set_location(' leaving:'||l_proc, 10);

end conv_to_position_rg;

*/

-- Procedure conv_to_position_rg. Copies the individual fields supplied as parameters
-- to the hr_all_positions_f type record.
Procedure conv_to_position_rg(
        p_position_id           in      hr_all_positions_f.position_id%TYPE default NULL,
        p_effective_start_date  in      hr_all_positions_f.effective_start_date%TYPE default NULL,
        p_effective_end_date    in      hr_all_positions_f.effective_end_date%TYPE default NULL,
        p_availability_status_id in     hr_all_positions_f.availability_status_id%TYPE default NULL,
        p_business_group_id     in      hr_all_positions_f.business_group_id%TYPE default NULL,
        p_entry_step_id         in      hr_all_positions_f.entry_step_id%TYPE default NULL,
        p_job_id                in      hr_all_positions_f.job_id%TYPE default NULL,
        p_location_id           in      hr_all_positions_f.location_id%TYPE default NULL,
        p_organization_id       in      hr_all_positions_f.organization_id%TYPE default NULL,
        p_pay_freq_payroll_id   in      hr_all_positions_f.pay_freq_payroll_id%TYPE default NULL,
        p_position_definition_id in     hr_all_positions_f.position_definition_id%TYPE default NULL,
        p_position_transaction_id in    hr_all_positions_f.position_transaction_id%TYPE default NULL,
        p_prior_position_id       in    hr_all_positions_f.prior_position_id%TYPE default NULL,
        p_relief_position_id    in      hr_all_positions_f.relief_position_id%TYPE default NULL,
        p_successor_position_id in      hr_all_positions_f.successor_position_id%TYPE default NULL,
        p_supervisor_position_id in     hr_all_positions_f.supervisor_position_id%TYPE default NULL,
        p_amendment_date        in      hr_all_positions_f.amendment_date%TYPE default NULL,
        p_amendment_recommendation in   hr_all_positions_f.amendment_recommendation%TYPE default NULL,
        p_amendment_ref_number  in      hr_all_positions_f.amendment_ref_number%TYPE default NULL,
        p_bargaining_unit_cd    in      hr_all_positions_f.bargaining_unit_cd%TYPE default NULL,
        p_current_job_prop_end_date in  hr_all_positions_f.current_job_prop_end_date%TYPE default NULL,
        p_current_org_prop_end_date in  hr_all_positions_f.current_org_prop_end_date%TYPE default NULL,
        p_avail_status_prop_end_date in hr_all_positions_f.avail_status_prop_end_date%TYPE default NULL,
        p_date_effective        in      hr_all_positions_f.date_effective%TYPE default NULL,
        p_date_end              in      hr_all_positions_f.date_end%TYPE default NULL,
        p_earliest_hire_date    in      hr_all_positions_f.earliest_hire_date%TYPE default NULL,
        p_fill_by_date          in      hr_all_positions_f.fill_by_date%TYPE default NULL,
        p_frequency             in      hr_all_positions_f.frequency%TYPE default NULL,
        p_fte                   in      hr_all_positions_f.fte%TYPE default NULL,
        p_max_persons           in      hr_all_positions_f.max_persons%TYPE default NULL,
        p_name                  in      hr_all_positions_f.name%TYPE default NULL,
        p_overlap_period        in      hr_all_positions_f.overlap_period%TYPE default NULL,
        p_overlap_unit_cd       in      hr_all_positions_f.overlap_unit_cd%TYPE default NULL,
        p_pay_term_end_day_cd   in      hr_all_positions_f.pay_term_end_day_cd%TYPE default NULL,
        p_pay_term_end_month_cd in      hr_all_positions_f.pay_term_end_month_cd%TYPE default NULL,
        p_permanent_temporary_flag in   hr_all_positions_f.permanent_temporary_flag%TYPE default NULL,
        p_permit_recruitment_flag in    hr_all_positions_f.permit_recruitment_flag%TYPE default NULL,
        p_position_type         in      hr_all_positions_f.position_type%TYPE default NULL,
        p_posting_description   in      hr_all_positions_f.posting_description%TYPE default NULL,
        p_probation_period      in      hr_all_positions_f.probation_period%TYPE default NULL,
        p_probation_period_unit_cd in   hr_all_positions_f.probation_period_unit_cd%TYPE default NULL,
        p_replacement_required_flag in  hr_all_positions_f.replacement_required_flag%TYPE default NULL,
        p_review_flag           in      hr_all_positions_f.review_flag%TYPE default NULL,
        p_seasonal_flag         in      hr_all_positions_f.seasonal_flag%TYPE default NULL,
        p_security_requirements in      hr_all_positions_f.security_requirements%TYPE default NULL,
        p_status                in      hr_all_positions_f.status%TYPE default NULL,
        p_term_start_day_cd     in      hr_all_positions_f.term_start_day_cd%TYPE default NULL,
        p_term_start_month_cd   in      hr_all_positions_f.term_start_month_cd%TYPE default NULL,
        p_time_normal_finish    in      hr_all_positions_f.time_normal_finish%TYPE default NULL,
        p_time_normal_start     in      hr_all_positions_f.time_normal_start%TYPE default NULL,
        p_update_source_cd      in      hr_all_positions_f.update_source_cd%TYPE default NULL,
        p_working_hours         in      hr_all_positions_f.working_hours%TYPE default NULL,
        p_works_council_approval_flag in hr_all_positions_f.works_council_approval_flag%TYPE default NULL,
        p_work_period_type_cd   in      hr_all_positions_f.work_period_type_cd%TYPE default NULL,
        p_work_term_end_day_cd  in      hr_all_positions_f.work_term_end_day_cd%TYPE default NULL,
        p_work_term_end_month_cd in     hr_all_positions_f.work_term_end_month_cd%TYPE default NULL,
        p_information_category  in      hr_all_positions_f.information_category%TYPE default NULL,
        p_information1          in      hr_all_positions_f.information1%TYPE default NULL,
        p_information2          in      hr_all_positions_f.information2%TYPE default NULL,
        p_information3          in      hr_all_positions_f.information3%TYPE default NULL,
        p_information4          in      hr_all_positions_f.information4%TYPE default NULL,
        p_information5          in      hr_all_positions_f.information5%TYPE default NULL,
        p_information6          in      hr_all_positions_f.information6%TYPE default NULL,
        p_information7          in      hr_all_positions_f.information7%TYPE default NULL,
        p_information8          in      hr_all_positions_f.information8%TYPE default NULL,
        p_information9          in      hr_all_positions_f.information9%TYPE default NULL,
        p_information10         in      hr_all_positions_f.information10%TYPE default NULL,
        p_information11         in      hr_all_positions_f.information11%TYPE default NULL,
        p_information12         in      hr_all_positions_f.information12%TYPE default NULL,
        p_information13         in      hr_all_positions_f.information13%TYPE default NULL,
        p_information14         in      hr_all_positions_f.information14%TYPE default NULL,
        p_information15         in      hr_all_positions_f.information15%TYPE default NULL,
        p_information16         in      hr_all_positions_f.information16%TYPE default NULL,
        p_information17         in      hr_all_positions_f.information17%TYPE default NULL,
        p_information18         in      hr_all_positions_f.information18%TYPE default NULL,
        p_information19         in      hr_all_positions_f.information19%TYPE default NULL,
        p_information20         in      hr_all_positions_f.information20%TYPE default NULL,
        p_information21         in      hr_all_positions_f.information21%TYPE default NULL,
        p_information22         in      hr_all_positions_f.information22%TYPE default NULL,
        p_information23         in      hr_all_positions_f.information23%TYPE default NULL,
        p_information24         in      hr_all_positions_f.information24%TYPE default NULL,
        p_information25         in      hr_all_positions_f.information25%TYPE default NULL,
        p_information26         in      hr_all_positions_f.information26%TYPE default NULL,
        p_information27         in      hr_all_positions_f.information27%TYPE default NULL,
        p_information28         in      hr_all_positions_f.information28%TYPE default NULL,
        p_information29         in      hr_all_positions_f.information29%TYPE default NULL,
        p_information30         in      hr_all_positions_f.information30%TYPE default NULL,
        p_attribute_category    in      hr_all_positions_f.attribute_category%TYPE default NULL,
        p_attribute1            in      hr_all_positions_f.attribute1%TYPE default NULL,
        p_attribute2            in      hr_all_positions_f.attribute2%TYPE default NULL,
        p_attribute3            in      hr_all_positions_f.attribute3%TYPE default NULL,
        p_attribute4            in      hr_all_positions_f.attribute4%TYPE default NULL,
        p_attribute5            in      hr_all_positions_f.attribute5%TYPE default NULL,
        p_attribute6            in      hr_all_positions_f.attribute6%TYPE default NULL,
        p_attribute7            in      hr_all_positions_f.attribute7%TYPE default NULL,
        p_attribute8            in      hr_all_positions_f.attribute8%TYPE default NULL,
        p_attribute9            in      hr_all_positions_f.attribute9%TYPE default NULL,
        p_attribute10           in      hr_all_positions_f.attribute10%TYPE default NULL,
        p_attribute11           in      hr_all_positions_f.attribute11%TYPE default NULL,
        p_attribute12           in      hr_all_positions_f.attribute12%TYPE default NULL,
        p_attribute13           in      hr_all_positions_f.attribute13%TYPE default NULL,
        p_attribute14           in      hr_all_positions_f.attribute14%TYPE default NULL,
        p_attribute15           in      hr_all_positions_f.attribute15%TYPE default NULL,
        p_attribute16           in      hr_all_positions_f.attribute16%TYPE default NULL,
        p_attribute17           in      hr_all_positions_f.attribute17%TYPE default NULL,
        p_attribute18           in      hr_all_positions_f.attribute18%TYPE default NULL,
        p_attribute19           in      hr_all_positions_f.attribute19%TYPE default NULL,
        p_attribute20           in      hr_all_positions_f.attribute20%TYPE default NULL,
        p_attribute21           in      hr_all_positions_f.attribute21%TYPE default NULL,
        p_attribute22           in      hr_all_positions_f.attribute22%TYPE default NULL,
        p_attribute23           in      hr_all_positions_f.attribute23%TYPE default NULL,
        p_attribute24           in      hr_all_positions_f.attribute24%TYPE default NULL,
        p_attribute25           in      hr_all_positions_f.attribute25%TYPE default NULL,
        p_attribute26           in      hr_all_positions_f.attribute26%TYPE default NULL,
        p_attribute27           in      hr_all_positions_f.attribute27%TYPE default NULL,
        p_attribute28           in      hr_all_positions_f.attribute28%TYPE default NULL,
        p_attribute29           in      hr_all_positions_f.attribute29%TYPE default NULL,
        p_attribute30           in      hr_all_positions_f.attribute30%TYPE default NULL,
        p_request_id            in      hr_all_positions_f.request_id%TYPE default NULL,
        p_program_application_id in     hr_all_positions_f.program_application_id%TYPE default NULL,
        p_program_id            in      hr_all_positions_f.program_id%TYPE default NULL,
        p_program_update_date   in      hr_all_positions_f.program_update_date%TYPE default NULL,
        p_entry_grade_id        in      hr_all_positions_f.entry_grade_id%TYPE default NULL,
        p_entry_grade_rule_id   in      hr_all_positions_f.entry_grade_rule_id%TYPE default NULL,
        p_proposed_fte_for_layoff in    hr_all_positions_f.proposed_fte_for_layoff%TYPE default NULL,
        p_proposed_date_for_layoff in   hr_all_positions_f.proposed_date_for_layoff%TYPE default NULL,
        p_pay_basis_id          in      hr_all_positions_f.pay_basis_id%TYPE default NULL,
        p_supervisor_id         in      hr_all_positions_f.supervisor_id%TYPE default NULL,
        p_copied_to_old_table_flag in   hr_all_positions_f.copied_to_old_table_flag%TYPE default NULL,
	p_position_data		in	out  nocopy hr_all_positions_f%rowtype  )  is

	l_proc	varchar2(30):='conv_to_position_rg';
	l_position_data  hr_all_positions_f%rowtype;

begin

	l_position_data :=p_position_data; --NOCOPY Changes

	hr_utility.set_location('Entering:'|| l_proc, 5);
	copy_field_value(	p_source_field => p_position_id,
				p_target_field => p_position_data.position_id);
	copy_field_value(	p_source_field => p_effective_start_date,
				p_target_field => p_position_data.effective_start_date);
	copy_field_value(	p_source_field => p_effective_end_date,
				p_target_field => p_position_data.effective_end_date);
	copy_field_value(	p_source_field => p_availability_status_id,
				p_target_field => p_position_data.availability_status_id);
	copy_field_value(	p_source_field => p_business_group_id,
				p_target_field => p_position_data.business_group_id);
	copy_field_value(	p_source_field => p_entry_step_id,
				p_target_field => p_position_data.entry_step_id);
	copy_field_value(	p_source_field => p_job_id,
				p_target_field => p_position_data.job_id);
	copy_field_value(	p_source_field => p_location_id,
				p_target_field => p_position_data.location_id);
	copy_field_value(	p_source_field => p_organization_id,
				p_target_field => p_position_data.organization_id);
	copy_field_value(	p_source_field => p_pay_freq_payroll_id,
				p_target_field => p_position_data.pay_freq_payroll_id);
	copy_field_value(	p_source_field => p_position_definition_id,
				p_target_field => p_position_data.position_definition_id);
	copy_field_value(	p_source_field => p_position_transaction_id,
				p_target_field => p_position_data.position_transaction_id);
	copy_field_value(	p_source_field => p_prior_position_id,
				p_target_field => p_position_data.prior_position_id);
	copy_field_value(	p_source_field => p_relief_position_id,
				p_target_field => p_position_data.relief_position_id);
	copy_field_value(	p_source_field => p_successor_position_id,
				p_target_field => p_position_data.successor_position_id);
	copy_field_value(	p_source_field => p_supervisor_position_id,
				p_target_field => p_position_data.supervisor_position_id);
	copy_field_value(	p_source_field => p_amendment_date,
				p_target_field => p_position_data.amendment_date);
	copy_field_value(	p_source_field => p_amendment_recommendation,
				p_target_field => p_position_data.amendment_recommendation);
	copy_field_value(	p_source_field => p_amendment_ref_number,
				p_target_field => p_position_data.amendment_ref_number);
	copy_field_value(	p_source_field => p_bargaining_unit_cd,
				p_target_field => p_position_data.bargaining_unit_cd);
	copy_field_value(	p_source_field => p_current_job_prop_end_date,
				p_target_field => p_position_data.current_job_prop_end_date);
	copy_field_value(	p_source_field => p_current_org_prop_end_date,
				p_target_field => p_position_data.current_org_prop_end_date);
	copy_field_value(	p_source_field => p_avail_status_prop_end_date,
				p_target_field => p_position_data.avail_status_prop_end_date);
	copy_field_value(	p_source_field => p_date_effective,
				p_target_field => p_position_data.date_effective);
	copy_field_value(	p_source_field => p_date_end,
				p_target_field => p_position_data.date_end);
	copy_field_value(	p_source_field => p_earliest_hire_date,
				p_target_field => p_position_data.earliest_hire_date);
	copy_field_value(	p_source_field => p_fill_by_date,
				p_target_field => p_position_data.fill_by_date);
	copy_field_value(	p_source_field => p_frequency,
				p_target_field => p_position_data.frequency);
	copy_field_value(	p_source_field => p_fte,
				p_target_field => p_position_data.fte);
	copy_field_value(	p_source_field => p_max_persons,
				p_target_field => p_position_data.max_persons);
	copy_field_value(	p_source_field => p_name,
				p_target_field => p_position_data.name);
	copy_field_value(	p_source_field => p_overlap_period,
				p_target_field => p_position_data.overlap_period);
	copy_field_value(	p_source_field => p_overlap_unit_cd,
				p_target_field => p_position_data.overlap_unit_cd);
	copy_field_value(	p_source_field => p_pay_term_end_day_cd,
				p_target_field => p_position_data.pay_term_end_day_cd);
	copy_field_value(	p_source_field => p_pay_term_end_month_cd,
				p_target_field => p_position_data.pay_term_end_month_cd);
	copy_field_value(	p_source_field => p_permanent_temporary_flag,
				p_target_field => p_position_data.permanent_temporary_flag);
	copy_field_value(	p_source_field => p_permit_recruitment_flag,
				p_target_field => p_position_data.permit_recruitment_flag);
	copy_field_value(	p_source_field => p_position_type,
				p_target_field => p_position_data.position_type);
	copy_field_value(	p_source_field => p_posting_description,
				p_target_field => p_position_data.posting_description);
	copy_field_value(	p_source_field => p_probation_period,
				p_target_field => p_position_data.probation_period);
	copy_field_value(	p_source_field => p_probation_period_unit_cd,
				p_target_field => p_position_data.probation_period_unit_cd);
	copy_field_value(	p_source_field => p_replacement_required_flag,
				p_target_field => p_position_data.replacement_required_flag);
	copy_field_value(	p_source_field => p_review_flag,
				p_target_field => p_position_data.review_flag);
	copy_field_value(	p_source_field => p_seasonal_flag,
				p_target_field => p_position_data.seasonal_flag);
	copy_field_value(	p_source_field => p_security_requirements,
				p_target_field => p_position_data.security_requirements);
	copy_field_value(	p_source_field => p_status,
				p_target_field => p_position_data.status);
	copy_field_value(	p_source_field => p_term_start_day_cd,
				p_target_field => p_position_data.term_start_day_cd);
	copy_field_value(	p_source_field => p_term_start_month_cd,
				p_target_field => p_position_data.term_start_month_cd);
	copy_field_value(	p_source_field => p_time_normal_finish,
				p_target_field => p_position_data.time_normal_finish);
	copy_field_value(	p_source_field => p_time_normal_start,
				p_target_field => p_position_data.time_normal_start);
	copy_field_value(	p_source_field => p_update_source_cd,
				p_target_field => p_position_data.update_source_cd);
	copy_field_value(	p_source_field => p_working_hours,
				p_target_field => p_position_data.working_hours);
	copy_field_value(	p_source_field => p_works_council_approval_flag,
				p_target_field => p_position_data.works_council_approval_flag);
	copy_field_value(	p_source_field => p_work_period_type_cd,
				p_target_field => p_position_data.work_period_type_cd);
	copy_field_value(	p_source_field => p_work_term_end_day_cd,
				p_target_field => p_position_data.work_term_end_day_cd);
	copy_field_value(	p_source_field => p_work_term_end_month_cd,
				p_target_field => p_position_data.work_term_end_month_cd);
	copy_field_value(	p_source_field => p_information_category,
				p_target_field => p_position_data.information_category);
	copy_field_value(	p_source_field => p_information1,
				p_target_field => p_position_data.information1);
	copy_field_value(	p_source_field => p_information2,
				p_target_field => p_position_data.information2);
	copy_field_value(	p_source_field => p_information3,
				p_target_field => p_position_data.information3);
	copy_field_value(	p_source_field => p_information4,
				p_target_field => p_position_data.information4);
	copy_field_value(	p_source_field => p_information5,
				p_target_field => p_position_data.information5);
	copy_field_value(	p_source_field => p_information6,
				p_target_field => p_position_data.information6);
	copy_field_value(	p_source_field => p_information7,
				p_target_field => p_position_data.information7);
	copy_field_value(	p_source_field => p_information8,
				p_target_field => p_position_data.information8);
	copy_field_value(	p_source_field => p_information9,
				p_target_field => p_position_data.information9);
	copy_field_value(	p_source_field => p_information10,
				p_target_field => p_position_data.information10);
	copy_field_value(	p_source_field => p_information11,
				p_target_field => p_position_data.information11);
	copy_field_value(	p_source_field => p_information12,
				p_target_field => p_position_data.information12);
	copy_field_value(	p_source_field => p_information13,
				p_target_field => p_position_data.information13);
	copy_field_value(	p_source_field => p_information14,
				p_target_field => p_position_data.information14);
	copy_field_value(	p_source_field => p_information15,
				p_target_field => p_position_data.information15);
	copy_field_value(	p_source_field => p_information16,
				p_target_field => p_position_data.information16);
	copy_field_value(	p_source_field => p_information17,
				p_target_field => p_position_data.information17);
	copy_field_value(	p_source_field => p_information18,
				p_target_field => p_position_data.information18);
	copy_field_value(	p_source_field => p_information19,
				p_target_field => p_position_data.information19);
	copy_field_value(	p_source_field => p_information20,
				p_target_field => p_position_data.information20);
	copy_field_value(	p_source_field => p_information21,
				p_target_field => p_position_data.information21);
	copy_field_value(	p_source_field => p_information22,
				p_target_field => p_position_data.information22);
	copy_field_value(	p_source_field => p_information23,
				p_target_field => p_position_data.information23);
	copy_field_value(	p_source_field => p_information24,
				p_target_field => p_position_data.information24);
	copy_field_value(	p_source_field => p_information25,
				p_target_field => p_position_data.information25);
	copy_field_value(	p_source_field => p_information26,
				p_target_field => p_position_data.information26);
	copy_field_value(	p_source_field => p_information27,
				p_target_field => p_position_data.information27);
	copy_field_value(	p_source_field => p_information28,
				p_target_field => p_position_data.information28);
	copy_field_value(	p_source_field => p_information29,
				p_target_field => p_position_data.information29);
	copy_field_value(	p_source_field => p_information30,
				p_target_field => p_position_data.information30);
	copy_field_value(	p_source_field => p_attribute_category,
				p_target_field => p_position_data.attribute_category);
	copy_field_value(	p_source_field => p_attribute1,
				p_target_field => p_position_data.attribute1);
	copy_field_value(	p_source_field => p_attribute2,
				p_target_field => p_position_data.attribute2);
	copy_field_value(	p_source_field => p_attribute3,
				p_target_field => p_position_data.attribute3);
	copy_field_value(	p_source_field => p_attribute4,
				p_target_field => p_position_data.attribute4);
	copy_field_value(	p_source_field => p_attribute5,
				p_target_field => p_position_data.attribute5);
	copy_field_value(	p_source_field => p_attribute6,
				p_target_field => p_position_data.attribute6);
	copy_field_value(	p_source_field => p_attribute7,
				p_target_field => p_position_data.attribute7);
	copy_field_value(	p_source_field => p_attribute8,
				p_target_field => p_position_data.attribute8);
	copy_field_value(	p_source_field => p_attribute9,
				p_target_field => p_position_data.attribute9);
	copy_field_value(	p_source_field => p_attribute10,
				p_target_field => p_position_data.attribute10);
	copy_field_value(	p_source_field => p_attribute11,
				p_target_field => p_position_data.attribute11);
	copy_field_value(	p_source_field => p_attribute12,
				p_target_field => p_position_data.attribute12);
	copy_field_value(	p_source_field => p_attribute13,
				p_target_field => p_position_data.attribute13);
	copy_field_value(	p_source_field => p_attribute14,
				p_target_field => p_position_data.attribute14);
	copy_field_value(	p_source_field => p_attribute15,
				p_target_field => p_position_data.attribute15);
	copy_field_value(	p_source_field => p_attribute16,
				p_target_field => p_position_data.attribute16);
	copy_field_value(	p_source_field => p_attribute17,
				p_target_field => p_position_data.attribute17);
	copy_field_value(	p_source_field => p_attribute18,
				p_target_field => p_position_data.attribute18);
	copy_field_value(	p_source_field => p_attribute19,
				p_target_field => p_position_data.attribute19);
	copy_field_value(	p_source_field => p_attribute20,
				p_target_field => p_position_data.attribute20);
	copy_field_value(	p_source_field => p_attribute21,
				p_target_field => p_position_data.attribute21);
	copy_field_value(	p_source_field => p_attribute22,
				p_target_field => p_position_data.attribute22);
	copy_field_value(	p_source_field => p_attribute23,
				p_target_field => p_position_data.attribute23);
	copy_field_value(	p_source_field => p_attribute24,
				p_target_field => p_position_data.attribute24);
	copy_field_value(	p_source_field => p_attribute25,
				p_target_field => p_position_data.attribute25);
	copy_field_value(	p_source_field => p_attribute26,
				p_target_field => p_position_data.attribute26);
	copy_field_value(	p_source_field => p_attribute27,
				p_target_field => p_position_data.attribute27);
	copy_field_value(	p_source_field => p_attribute28,
				p_target_field => p_position_data.attribute28);
	copy_field_value(	p_source_field => p_attribute29,
				p_target_field => p_position_data.attribute29);
	copy_field_value(	p_source_field => p_attribute30,
				p_target_field => p_position_data.attribute30);
	copy_field_value(	p_source_field => p_request_id,
				p_target_field => p_position_data.request_id);
	copy_field_value(	p_source_field => p_program_application_id,
				p_target_field => p_position_data.program_application_id);
	copy_field_value(	p_source_field => p_program_id,
				p_target_field => p_position_data.program_id);
	copy_field_value(	p_source_field => p_program_update_date,
				p_target_field => p_position_data.program_update_date);
	copy_field_value(	p_source_field => p_entry_grade_id,
				p_target_field => p_position_data.entry_grade_id);
	copy_field_value(	p_source_field => p_entry_grade_rule_id,
				p_target_field => p_position_data.entry_grade_rule_id);
	copy_field_value(	p_source_field => p_proposed_fte_for_layoff,
				p_target_field => p_position_data.proposed_fte_for_layoff);
	copy_field_value(	p_source_field => p_proposed_date_for_layoff,
				p_target_field => p_position_data.proposed_date_for_layoff);
	copy_field_value(	p_source_field => p_pay_basis_id,
				p_target_field => p_position_data.pay_basis_id);
	copy_field_value(	p_source_field => p_supervisor_id,
				p_target_field => p_position_data.supervisor_id);
	copy_field_value(	p_source_field => p_copied_to_old_table_flag,
				p_target_field => p_position_data.copied_to_old_table_flag);
 	hr_utility.set_location('Entering:'|| l_proc, 10);

 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_position_data :=l_position_data;
     raise;

end conv_to_position_rg;
--
-- Procedure to convert the position history view rg to the position rg.
--
Procedure conv_to_position_rg (
       p_position_h_v  in  ghr_positions_h_v%rowtype,
       p_position_data out nocopy hr_all_positions_f%rowtype) is

       l_proc		varchar2(30):='Conv_to_position_rg';
       l_position_data  hr_all_positions_f%rowtype;
Begin
	hr_utility.set_location('Entering : ' || l_proc, 100);
	conv_to_position_rg(
           p_position_id           => p_position_h_v.position_id,
           p_effective_start_date  => p_position_h_v.effective_start_date,
           p_effective_end_date    => p_position_h_v.effective_end_date,
           p_date_effective        => p_position_h_v.date_effective,
           p_date_end              => p_position_h_v.date_end,
           p_name                  => p_position_h_v.name,
           p_relief_position_id    => p_position_h_v.relief_position_id,
           p_location_id           => p_position_h_v.location_id,
           p_position_definition_id=> p_position_h_v.position_definition_id,
           p_job_id                => p_position_h_v.job_id,
           p_organization_id       => p_position_h_v.organization_id,
           p_frequency             => p_position_h_v.frequency,
           p_successor_position_id => p_position_h_v.successor_position_id,
           p_probation_period      => p_position_h_v.probation_period,
           p_probation_period_unit_cd => p_position_h_v.probation_period_unit_cd,
           p_replacement_required_flag => p_position_h_v.replacement_required_flag,
           p_time_normal_finish        => p_position_h_v.time_normal_finish,
           p_time_normal_start         => p_position_h_v.time_normal_start,
           p_working_hours             => p_position_h_v.working_hours,
           p_amendment_date            => p_position_h_v.amendment_date,
           p_amendment_recommendation  => p_position_h_v.amendment_recommendation,
           p_amendment_ref_number      => p_position_h_v.amendment_ref_number,
           p_availability_status_id    => p_position_h_v.availability_status_id,
           p_avail_status_prop_end_date => p_position_h_v.avail_status_prop_end_date,
           p_bargaining_unit_cd         => p_position_h_v.bargaining_unit_cd,
           p_copied_to_old_table_flag   => p_position_h_v.copied_to_old_table_flag,
           p_earliest_hire_date         => p_position_h_v.earliest_hire_date,
           p_entry_grade_id             => p_position_h_v.entry_grade_id,
           p_entry_grade_rule_id        => p_position_h_v.entry_grade_rule_id,
           p_entry_step_id              => p_position_h_v.entry_step_id,
           p_fill_by_date               => p_position_h_v.fill_by_date,
           p_fte                        => p_position_h_v.fte,
           p_max_persons                => p_position_h_v.max_persons,
           p_overlap_period             => p_position_h_v.overlap_period,
           p_overlap_unit_cd            => p_position_h_v.overlap_unit_cd,
           p_pay_basis_id               => p_position_h_v.pay_basis_id,
           p_pay_freq_payroll_id        => p_position_h_v.pay_freq_payroll_id,
           p_pay_term_end_day_cd        => p_position_h_v.pay_term_end_day_cd,
           p_pay_term_end_month_cd      => p_position_h_v.pay_term_end_month_cd,
           p_permanent_temporary_flag   => p_position_h_v.permanent_temporary_flag,
           p_permit_recruitment_flag    => p_position_h_v.permit_recruitment_flag,
           p_position_transaction_id    => p_position_h_v.position_transaction_id,
           p_position_type              => p_position_h_v.position_type,
           p_posting_description        => p_position_h_v.posting_description,
           p_prior_position_id          => p_position_h_v.prior_position_id,
           p_review_flag                => p_position_h_v.review_flag,
           p_seasonal_flag              => p_position_h_v.seasonal_flag,
           p_security_requirements      => p_position_h_v.security_requirements,
           p_supervisor_id              => p_position_h_v.supervisor_id,
           p_supervisor_position_id     => p_position_h_v.supervisor_position_id,
           p_term_start_day_cd          => p_position_h_v.term_start_day_cd,
           p_term_start_month_cd        => p_position_h_v.term_start_month_cd,
           p_update_source_cd           => p_position_h_v.update_source_cd,
           p_works_council_approval_flag => p_position_h_v.works_council_approval_flag,
           p_work_period_type_cd         => p_position_h_v.work_period_type_cd,
           p_work_term_end_day_cd        => p_position_h_v.work_term_end_day_cd,
           p_work_term_end_month_cd      => p_position_h_v.work_term_end_month_cd,
           p_current_job_prop_end_date   => p_position_h_v.current_job_prop_end_date,
           p_current_org_prop_end_date   => p_position_h_v.current_org_prop_end_date,
           p_proposed_date_for_layoff    => p_position_h_v.proposed_date_for_layoff,
           p_proposed_fte_for_layoff     => p_position_h_v.proposed_fte_for_layoff,
           p_status                      => p_position_h_v.status,
           p_business_group_id           => p_position_h_v.business_group_id,
           p_request_id                  => p_position_h_v.request_id,
           p_program_application_id      => p_position_h_v.program_application_id,
           p_program_id                  => p_position_h_v.program_id,
           p_program_update_date         => p_position_h_v.program_update_date,
           p_attribute_category          => p_position_h_v.attribute_category,
           p_attribute1                  => p_position_h_v.attribute1,
           p_attribute2                  => p_position_h_v.attribute2,
           p_attribute3                  => p_position_h_v.attribute3,
           p_attribute4                  => p_position_h_v.attribute4,
           p_attribute5                  => p_position_h_v.attribute5,
           p_attribute6                  => p_position_h_v.attribute6,
           p_attribute7                  => p_position_h_v.attribute7,
           p_attribute8                  => p_position_h_v.attribute8,
           p_attribute9                  => p_position_h_v.attribute9,
           p_attribute10                 => p_position_h_v.attribute10,
           p_attribute11                 => p_position_h_v.attribute11,
           p_attribute12                 => p_position_h_v.attribute12,
           p_attribute13                 => p_position_h_v.attribute13,
           p_attribute14                 => p_position_h_v.attribute14,
           p_attribute15                 => p_position_h_v.attribute15,
           p_attribute16                 => p_position_h_v.attribute16,
           p_attribute17                 => p_position_h_v.attribute17,
           p_attribute18                 => p_position_h_v.attribute18,
           p_attribute19                 => p_position_h_v.attribute19,
           p_attribute20                 => p_position_h_v.attribute20,
           p_attribute21                 => p_position_h_v.attribute21,
           p_attribute22                 => p_position_h_v.attribute22,
           p_attribute23                 => p_position_h_v.attribute23,
           p_attribute24                 => p_position_h_v.attribute24,
           p_attribute25                 => p_position_h_v.attribute25,
           p_attribute26                 => p_position_h_v.attribute26,
           p_attribute27                 => p_position_h_v.attribute27,
           p_attribute28                 => p_position_h_v.attribute28,
           p_attribute29                 => p_position_h_v.attribute29,
           p_attribute30                 => p_position_h_v.attribute30,
           p_information_category        => p_position_h_v.information_category,
           p_information1                => p_position_h_v.information1,
           p_information2                => p_position_h_v.information2,
           p_information3                => p_position_h_v.information3,
           p_information4                => p_position_h_v.information4,
           p_information5                => p_position_h_v.information5,
           p_information6                => p_position_h_v.information6,
           p_information7                => p_position_h_v.information7,
           p_information8                => p_position_h_v.information8,
           p_information9                => p_position_h_v.information9,
           p_information10               => p_position_h_v.information10,
           p_information11               => p_position_h_v.information11,
           p_information12               => p_position_h_v.information12,
           p_information13               => p_position_h_v.information13,
           p_information14               => p_position_h_v.information14,
           p_information15               => p_position_h_v.information15,
           p_information16               => p_position_h_v.information16,
           p_information17               => p_position_h_v.information17,
           p_information18               => p_position_h_v.information18,
           p_information19               => p_position_h_v.information19,
           p_information20               => p_position_h_v.information20,
           p_information21               => p_position_h_v.information21,
           p_information22               => p_position_h_v.information22,
           p_information23               => p_position_h_v.information23,
           p_information24               => p_position_h_v.information24,
           p_information25               => p_position_h_v.information25,
           p_information26               => p_position_h_v.information26,
           p_information27               => p_position_h_v.information27,
           p_information28               => p_position_h_v.information28,
           p_information29               => p_position_h_v.information29,
           p_information30               => p_position_h_v.information30,
           p_position_data         => l_position_data
           );

	p_position_data := l_position_data;
	hr_utility.set_location('Leaving : ' || l_proc, 200);

 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_position_data :=NULL;
     raise;


End Conv_to_position_rg;
--
-- procedure to convert Position RG to Position History RG
-- ghr_pa_history record type
--
Procedure conv_position_rg_to_hist_rg(
        p_position_data        in  hr_all_positions_f%rowtype,
	p_history_data     in out nocopy ghr_pa_history%rowtype) as

	l_proc	 varchar2(30) := 'conv_position_rg_to_hist_rg';
	l_history_data   ghr_pa_history%rowtype ;

begin

        l_history_data :=p_history_data; --NOCOPY CHANGES

	hr_utility.set_location('entering:'|| l_proc, 5);
        p_history_data.information1   :=      p_position_data.position_id;
        p_history_data.information2   :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.effective_start_date);
        p_history_data.information3   :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.effective_end_date);
        p_history_data.information4   :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.date_effective);
        p_history_data.information5   :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.date_end);
        p_history_data.information6   :=      p_position_data.name;
        p_history_data.information7   :=      p_position_data.relief_position_id;
        p_history_data.information8   :=      p_position_data.location_id;
        p_history_data.information9   :=      p_position_data.position_definition_id;
        p_history_data.information10  :=      p_position_data.job_id;
        p_history_data.information12  :=      p_position_data.organization_id;
        p_history_data.information13  :=      p_position_data.frequency;
        p_history_data.information14  :=      p_position_data.successor_position_id;
        p_history_data.information15  :=      p_position_data.probation_period;
        p_history_data.information16  :=      p_position_data.probation_period_unit_cd;
        p_history_data.information17  :=      p_position_data.replacement_required_flag;
        p_history_data.information18  :=      p_position_data.time_normal_finish;
        p_history_data.information19  :=      p_position_data.time_normal_start;
        p_history_data.information20  :=      p_position_data.working_hours;
        p_history_data.information21  :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.amendment_date);
        p_history_data.information22  :=      p_position_data.amendment_recommendation;
        p_history_data.information23  :=      p_position_data.amendment_ref_number;
        p_history_data.information24  :=      p_position_data.availability_status_id;
        p_history_data.information25  :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.avail_status_prop_end_date);
        p_history_data.information26  :=      p_position_data.bargaining_unit_cd;
        p_history_data.information27  :=      p_position_data.copied_to_old_table_flag;
        p_history_data.information28  :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.earliest_hire_date);
        p_history_data.information29  :=      p_position_data.entry_grade_id;
        p_history_data.information30  :=      p_position_data.entry_grade_rule_id;
        p_history_data.information31  :=      p_position_data.entry_step_id;
        p_history_data.information32  :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.fill_by_date);
        p_history_data.information33  :=      p_position_data.fte;
        p_history_data.information34  :=      p_position_data.max_persons;
        p_history_data.information35  :=      p_position_data.overlap_period;
        p_history_data.information36  :=      p_position_data.overlap_unit_cd;
        p_history_data.information37  :=      p_position_data.pay_basis_id;
        p_history_data.information38  :=      p_position_data.pay_freq_payroll_id;
        p_history_data.information39  :=      p_position_data.pay_term_end_day_cd;
        p_history_data.information40  :=      p_position_data.pay_term_end_month_cd;
        p_history_data.information41  :=      p_position_data.permanent_temporary_flag;
        p_history_data.information42  :=      p_position_data.permit_recruitment_flag;
        p_history_data.information43  :=      p_position_data.position_transaction_id;
        p_history_data.information44  :=      p_position_data.position_type;
        p_history_data.information45  :=      p_position_data.posting_description;
        p_history_data.information46  :=      p_position_data.prior_position_id;
        p_history_data.information47  :=      p_position_data.review_flag;
        p_history_data.information48  :=      p_position_data.seasonal_flag;
        p_history_data.information49  :=      p_position_data.security_requirements;
        p_history_data.information50  :=      p_position_data.supervisor_id;
        p_history_data.information51  :=      p_position_data.supervisor_position_id;
        p_history_data.information52  :=      p_position_data.term_start_day_cd;
        p_history_data.information53  :=      p_position_data.term_start_month_cd;
        p_history_data.information54  :=      p_position_data.update_source_cd;
        p_history_data.information55  :=      p_position_data.works_council_approval_flag;
        p_history_data.information56  :=      p_position_data.work_period_type_cd;
        p_history_data.information57  :=      p_position_data.work_term_end_day_cd;
        p_history_data.information58  :=      p_position_data.work_term_end_month_cd;
        p_history_data.information59  :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.current_job_prop_end_date);
        p_history_data.information60  :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.current_org_prop_end_date);
        p_history_data.information61  :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.proposed_date_for_layoff);
        p_history_data.information62  :=      p_position_data.proposed_fte_for_layoff;
        p_history_data.information121 :=      p_position_data.status;
        p_history_data.information122 :=      p_position_data.business_group_id;
        p_history_data.information123 :=      p_position_data.request_id;
        p_history_data.information124 :=      p_position_data.program_application_id;
        p_history_data.information125 :=      p_position_data.program_id;
        p_history_data.information126 :=      FND_DATE.DATE_TO_CANONICAL(p_position_data.program_update_date);
        p_history_data.information127 :=      p_position_data.attribute_category;
        p_history_data.information128 :=      p_position_data.attribute1;
        p_history_data.information129 :=      p_position_data.attribute2;
        p_history_data.information130 :=      p_position_data.attribute3;
        p_history_data.information131 :=      p_position_data.attribute4;
        p_history_data.information132 :=      p_position_data.attribute5;
        p_history_data.information133 :=      p_position_data.attribute6;
        p_history_data.information134 :=      p_position_data.attribute7;
        p_history_data.information135 :=      p_position_data.attribute8;
        p_history_data.information136 :=      p_position_data.attribute9;
        p_history_data.information137 :=      p_position_data.attribute10;
        p_history_data.information138 :=      p_position_data.attribute11;
        p_history_data.information139 :=      p_position_data.attribute12;
        p_history_data.information140 :=      p_position_data.attribute13;
        p_history_data.information141 :=      p_position_data.attribute14;
        p_history_data.information142 :=      p_position_data.attribute15;
        p_history_data.information143 :=      p_position_data.attribute16;
        p_history_data.information144 :=      p_position_data.attribute17;
        p_history_data.information145 :=      p_position_data.attribute18;
        p_history_data.information146 :=      p_position_data.attribute19;
        p_history_data.information147 :=      p_position_data.attribute20;
        p_history_data.information148 :=      p_position_data.attribute21;
        p_history_data.information149 :=      p_position_data.attribute22;
        p_history_data.information150 :=      p_position_data.attribute23;
        p_history_data.information151 :=      p_position_data.attribute24;
        p_history_data.information152 :=      p_position_data.attribute25;
        p_history_data.information153 :=      p_position_data.attribute26;
        p_history_data.information154 :=      p_position_data.attribute27;
        p_history_data.information155 :=      p_position_data.attribute28;
        p_history_data.information156 :=      p_position_data.attribute29;
        p_history_data.information157 :=      p_position_data.attribute30;
        p_history_data.information158 :=      p_position_data.information_category;
        p_history_data.information159 :=      p_position_data.information1;
        p_history_data.information160 :=      p_position_data.information2;
        p_history_data.information161 :=      p_position_data.information3;
        p_history_data.information162 :=      p_position_data.information4;
        p_history_data.information163 :=      p_position_data.information5;
        p_history_data.information164 :=      p_position_data.information6;
        p_history_data.information165 :=      p_position_data.information7;
        p_history_data.information166 :=      p_position_data.information8;
        p_history_data.information167 :=      p_position_data.information9;
        p_history_data.information168 :=      p_position_data.information10;
        p_history_data.information169 :=      p_position_data.information11;
        p_history_data.information170 :=      p_position_data.information12;
        p_history_data.information171 :=      p_position_data.information13;
        p_history_data.information172 :=      p_position_data.information14;
        p_history_data.information173 :=      p_position_data.information15;
        p_history_data.information174 :=      p_position_data.information16;
        p_history_data.information175 :=      p_position_data.information17;
        p_history_data.information176 :=      p_position_data.information18;
        p_history_data.information177 :=      p_position_data.information19;
        p_history_data.information178 :=      p_position_data.information20;
        p_history_data.information179 :=      p_position_data.information21;
        p_history_data.information180 :=      p_position_data.information22;
        p_history_data.information181 :=      p_position_data.information23;
        p_history_data.information182 :=      p_position_data.information24;
        p_history_data.information183 :=      p_position_data.information25;
        p_history_data.information184 :=      p_position_data.information26;
        p_history_data.information185 :=      p_position_data.information27;
        p_history_data.information186 :=      p_position_data.information28;
        p_history_data.information187 :=      p_position_data.information29;
        p_history_data.information188 :=      p_position_data.information30;

	hr_utility.set_location(' leaving:'||l_proc, 10);

EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
        p_history_data :=l_history_data;
     raise;


end conv_position_rg_to_hist_rg;
--
-- Procedure to convert history RG to Position RG
--
Procedure conv_to_position_rg(
	p_history_data   	    in   ghr_pa_history%rowtype,
        p_position_data    in out  nocopy hr_all_positions_f%rowtype)  as

	l_proc	 varchar2(30) := 'conv_to_position_rg';
	l_position_data    hr_all_positions_f%rowtype ;

begin

	l_position_data :=p_position_data; --NOCOPY Changes
	hr_utility.set_location('entering:'|| l_proc, 5);

        p_position_data.position_id             := p_history_data.information1     ;
        p_position_data.effective_start_date    := FND_DATE.CANONICAL_TO_DATE(p_history_data.information2);
        p_position_data.effective_end_date      := FND_DATE.CANONICAL_TO_DATE(p_history_data.information3);
        p_position_data.date_effective          := FND_DATE.CANONICAL_TO_DATE(p_history_data.information4);
        p_position_data.date_end                := FND_DATE.CANONICAL_TO_DATE(p_history_data.information5);
        p_position_data.name                    := p_history_data.information6     ;
        p_position_data.relief_position_id      := p_history_data.information7     ;
        p_position_data.location_id             := p_history_data.information8     ;
        p_position_data.position_definition_id  := p_history_data.information9     ;
	p_position_data.job_id		        := p_history_data.information10	;
	p_position_data.organization_id		:= p_history_data.information12	;
	p_position_data.frequency		:= p_history_data.information13	;
	p_position_data.successor_position_id	:= p_history_data.information14	;
	p_position_data.probation_period	:= p_history_data.information15	;
        p_position_data.probation_period_unit_cd  := p_history_data.information16    ;
	p_position_data.replacement_required_flag := p_history_data.information17	;
	p_position_data.time_normal_finish	  := p_history_data.information18	;
	p_position_data.time_normal_start	  := p_history_data.information19	;
	p_position_data.working_hours		  := p_history_data.information20	;
        p_position_data.amendment_date            := FND_DATE.CANONICAL_TO_DATE(p_history_data.information21);
        p_position_data.amendment_recommendation  := p_history_data.information22;
        p_position_data.amendment_ref_number    := p_history_data.information23;
        p_position_data.availability_status_id  := p_history_data.information24;
        p_position_data.avail_status_prop_end_date := FND_DATE.CANONICAL_TO_DATE(p_history_data.information25);
        p_position_data.bargaining_unit_cd      := p_history_data.information26;
        p_position_data.copied_to_old_table_flag := p_history_data.information27;
        p_position_data.earliest_hire_date       := FND_DATE.CANONICAL_TO_DATE(p_history_data.information28);
        p_position_data.entry_grade_id           := p_history_data.information29;
        p_position_data.entry_grade_rule_id      := p_history_data.information30;
        p_position_data.entry_step_id            := p_history_data.information31;
        p_position_data.fill_by_date             := FND_DATE.CANONICAL_TO_DATE(p_history_data.information32);
        p_position_data.fte                      := p_history_data.information33;
        p_position_data.max_persons              := p_history_data.information34;
        p_position_data.overlap_period           := p_history_data.information35;
        p_position_data.overlap_unit_cd          := p_history_data.information36;
        p_position_data.pay_basis_id             := p_history_data.information37;
        p_position_data.pay_freq_payroll_id      := p_history_data.information38;
        p_position_data.pay_term_end_day_cd      := p_history_data.information39;
        p_position_data.pay_term_end_month_cd    := p_history_data.information40;
        p_position_data.permanent_temporary_flag := p_history_data.information41;
        p_position_data.permit_recruitment_flag  := p_history_data.information42;
        p_position_data.position_transaction_id  := p_history_data.information43;
        p_position_data.position_type            := p_history_data.information44;
        p_position_data.posting_description      := p_history_data.information45;
        p_position_data.prior_position_id        := p_history_data.information46;
        p_position_data.review_flag              := p_history_data.information47;
        p_position_data.seasonal_flag            := p_history_data.information48;
        p_position_data.security_requirements    := p_history_data.information49;
        p_position_data.supervisor_id            := p_history_data.information50;
        p_position_data.supervisor_position_id   := p_history_data.information51;
        p_position_data.term_start_day_cd        := p_history_data.information52;
        p_position_data.term_start_month_cd      := p_history_data.information53;
        p_position_data.update_source_cd         := p_history_data.information54;
        p_position_data.works_council_approval_flag := p_history_data.information55;
        p_position_data.work_period_type_cd      := p_history_data.information56;
        p_position_data.work_term_end_day_cd     := p_history_data.information57;
        p_position_data.work_term_end_month_cd   := p_history_data.information58;
        p_position_data.current_job_prop_end_date := FND_DATE.CANONICAL_TO_DATE(p_history_data.information59);
        p_position_data.current_org_prop_end_date := FND_DATE.CANONICAL_TO_DATE(p_history_data.information60);
        p_position_data.proposed_date_for_layoff := FND_DATE.CANONICAL_TO_DATE(p_history_data.information61);
        p_position_data.proposed_fte_for_layoff  := p_history_data.information62;
	p_position_data.status		         := p_history_data.information121	;
	p_position_data.business_group_id	 := p_history_data.information122	;
	p_position_data.request_id		 := p_history_data.information123	;
	p_position_data.program_application_id	 := p_history_data.information124	;
	p_position_data.program_id	 	 := p_history_data.information125	;
        p_position_data.program_update_date      := FND_DATE.CANONICAL_TO_DATE(p_history_data.information126);
	p_position_data.attribute_category	 := p_history_data.information127	;
	p_position_data.attribute1		:= p_history_data.information128	;
	p_position_data.attribute2		:= p_history_data.information129	;
	p_position_data.attribute3		:= p_history_data.information130	;
	p_position_data.attribute4		:= p_history_data.information131	;
	p_position_data.attribute5		:= p_history_data.information132	;
	p_position_data.attribute6		:= p_history_data.information133	;
	p_position_data.attribute7		:= p_history_data.information134	;
	p_position_data.attribute8		:= p_history_data.information135	;
	p_position_data.attribute9		:= p_history_data.information136	;
	p_position_data.attribute10		:= p_history_data.information137	;
	p_position_data.attribute11		:= p_history_data.information138	;
	p_position_data.attribute12		:= p_history_data.information139	;
	p_position_data.attribute13		:= p_history_data.information140	;
	p_position_data.attribute14		:= p_history_data.information141	;
	p_position_data.attribute15		:= p_history_data.information142	;
	p_position_data.attribute16		:= p_history_data.information143	;
	p_position_data.attribute17		:= p_history_data.information144	;
	p_position_data.attribute18		:= p_history_data.information145	;
	p_position_data.attribute19		:= p_history_data.information146	;
	p_position_data.attribute20		:= p_history_data.information147	;
        p_position_data.attribute21             := p_history_data.information148   ;
        p_position_data.attribute22             := p_history_data.information149   ;
        p_position_data.attribute23             := p_history_data.information150   ;
        p_position_data.attribute24             := p_history_data.information151   ;
        p_position_data.attribute25             := p_history_data.information152   ;
        p_position_data.attribute26             := p_history_data.information153   ;
        p_position_data.attribute27             := p_history_data.information154   ;
        p_position_data.attribute28             := p_history_data.information155   ;
        p_position_data.attribute29             := p_history_data.information156   ;
        p_position_data.attribute30             := p_history_data.information157   ;
        p_position_data.information_category    := p_history_data.information158;
        p_position_data.information1            := p_history_data.information159;
        p_position_data.information2            := p_history_data.information160;
        p_position_data.information3            := p_history_data.information161;
        p_position_data.information4            := p_history_data.information162;
        p_position_data.information5            := p_history_data.information163;
        p_position_data.information6            := p_history_data.information164;
        p_position_data.information7            := p_history_data.information165;
        p_position_data.information8            := p_history_data.information166;
        p_position_data.information9            := p_history_data.information167;
        p_position_data.information10           := p_history_data.information168;
        p_position_data.information11           := p_history_data.information169;
        p_position_data.information12           := p_history_data.information170;
        p_position_data.information13           := p_history_data.information171;
        p_position_data.information14           := p_history_data.information172;
        p_position_data.information15           := p_history_data.information173;
        p_position_data.information16           := p_history_data.information174;
        p_position_data.information17           := p_history_data.information175;
        p_position_data.information18           := p_history_data.information176;
        p_position_data.information19           := p_history_data.information177;
        p_position_data.information20           := p_history_data.information178;
        p_position_data.information21           := p_history_data.information179;
        p_position_data.information22           := p_history_data.information180;
        p_position_data.information23           := p_history_data.information181;
        p_position_data.information24           := p_history_data.information182;
        p_position_data.information25           := p_history_data.information183;
        p_position_data.information26           := p_history_data.information184;
        p_position_data.information27           := p_history_data.information185;
        p_position_data.information28           := p_history_data.information186;
        p_position_data.information29           := p_history_data.information187;
        p_position_data.information30           := p_history_data.information188;

	hr_utility.set_location(' leaving:'||l_proc, 10);


 EXCEPTION
  WHEN others THEN
   --Reset IN OUT parameters and set OUT parameters
	p_position_data :=l_position_data;
     raise;
end conv_to_position_rg;

End GHR_HISTORY_CONV_RG;

/
