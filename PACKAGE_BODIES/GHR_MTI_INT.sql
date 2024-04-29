--------------------------------------------------------
--  DDL for Package Body GHR_MTI_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MTI_INT" AS
/* $Header: ghmtiint.pkb 120.0.12010000.2 2008/08/05 15:07:34 ubhat ship $ */

	g_datefmt	constant varchar2(30) := 'DD-MON-YYYY';

	function report_state(p_bool	boolean, p_message varchar2)
	return varchar2 is

		l_proc			varchar2(72) := g_package||'report_state';
		l_message		varchar2(100);

	begin

		hr_utility.set_location('Entering:'||l_proc, 10);

		if p_bool = TRUE then
			l_message := p_message|| 'TRUE';
		else
			l_message := p_message|| 'FALSE';
		end if;

		hr_utility.set_location('Leaving:'||l_proc, 10);
		return l_message;

	end report_state;

	function ck_parameter_list(p_person_row in ghr_mt_people_f_v%rowtype)
	return boolean is
		l_proc			varchar2(72) := g_package||'ck_parameter_list';

    begin

		hr_utility.set_location('Entering:'||l_proc, 10);

		if p_person_row.last_name is null then
			-- a persons last name is required to create an applicant
			return FALSE;
		elsif p_person_row.mt_person_id is null then
			-- person_id required to differentiate between like named people
			-- for update of transfer status, and to find all data in the
			-- interface table for ther person
			return FALSE;
		end if;

		hr_utility.set_location('Leaving:'||l_proc, 10);
		return TRUE;

	end ck_parameter_list;

	procedure set_transfer_status(p_status_code		varchar2,
								  p_transfer_name	varchar2,
								  p_last_name		varchar2,
								  p_person_id		varchar2) is

		l_proc			varchar2(72) := g_package||'set_transfer_status';
	begin

		hr_utility.set_location('Entering:'||l_proc, 10);

		-- update interface table to indicate result of transfer
		update ghr_mt_people_f_v
		set mt_status = p_status_code
		where mt_name = p_transfer_name
		and last_name = p_last_name
		and mt_person_id = p_person_id;

		hr_utility.set_location('Leaving:'||l_proc, 10);

		exception
			when others then
				ghr_mto_int.put_line(l_proc||' - raised exception');
				hr_utility.raise_error;

	end set_transfer_status;

	procedure update_mass_transfer_in_flag(p_person_id	number,
														p_transfer_id varchar2,
														p_effective_date date) is

		cursor cur_pei_id is
			select  person_extra_info_id, object_version_number
			from per_people_extra_info
			where person_id = p_person_id
			and information_type = 'GHR_US_PER_MASS_ACTIONS';

		l_person_extra_info_id	per_people_extra_info.person_extra_info_id%type;
		l_object_version_number per_people_extra_info.object_version_number%type;

		l_proc			varchar2(72) := g_package||'update_mass_transfer_in_flag';

	begin

		hr_utility.set_location('Entering:'||l_proc, 10);

		open cur_pei_id;
		fetch cur_pei_id into l_person_extra_info_id, l_object_version_number;

		if cur_pei_id%notfound then	-- create info type

			ghr_person_extra_info_api.create_person_extra_info (
				  p_person_id						=> p_person_id
             ,p_effective_date            => p_effective_date
				 ,p_information_type				=> 'GHR_US_PER_MASS_ACTIONS'
				 ,p_pei_information_category	=> 'GHR_US_PER_MASS_ACTIONS'
				 ,p_pei_information6				=> 'Y'
				 ,p_pei_information8				=> p_transfer_id
				 ,p_person_extra_info_id		=> l_person_extra_info_id
				 ,p_object_version_number		=> l_object_version_number
			);

		else

			ghr_person_extra_info_api.update_person_extra_info (
				p_person_extra_info_id		=> l_person_extra_info_id
				,p_object_version_number	=> l_object_version_number
				,p_effective_date				=> p_effective_date
				,p_pei_information6			=> 'Y'
				,p_pei_information8			=> p_transfer_id
			);

		end if;

		close cur_pei_id;
		hr_utility.set_location('Leaving:'||l_proc, 10);

		exception
			when others then
				ghr_mto_int.put_line(l_proc||' - raised exception');
				hr_utility.raise_error;

	end;

--
-- If all information parameters are null then this procedure does nothing
-- otherwise it calls hr_person_extra_info_api.create_person_extra_info.
--
	procedure create_person_extra_info_maybe (
				 p_person_id				number
				 ,p_effective_date		date
				 ,p_information_type		varchar2
				 ,p_pei_information3		varchar2 default null
				 ,p_pei_information4		varchar2 default null
				 ,p_pei_information5		varchar2 default null
				 ,p_pei_information6		varchar2 default null
				 ,p_pei_information7		varchar2 default null
				 ,p_pei_information8		varchar2 default null
				 ,p_pei_information9		varchar2 default null
				 ,p_pei_information10	varchar2 default null
				 ,p_pei_information11	varchar2 default null
				 ,p_pei_information12	varchar2 default null
				 ,p_pei_information13	varchar2 default null
				 ,p_pei_information14	varchar2 default null
				 ,p_pei_information15	varchar2 default null
				 ,p_pei_information16	varchar2 default null
				 ,p_pei_information17	varchar2 default null) is

		l_proc    varchar2(72) := g_package||'create_person_extra_info_maybe';
		l_concat	 varchar2(2000);
		l_info3	 varchar2(150) := p_pei_information3;

		l_person_extra_info_id				number(15);
		l_object_version_number				number(15);

	begin

		hr_utility.set_location('Entering:'||l_proc, 10);

		ghr_mto_int.put('Person Extra Info: '|| p_information_type);

		-- don't add info3 if DDF segment is GHR_US_PER_GROUP1
		if p_information_type = 'GHR_US_PER_GROUP1' then
			l_info3 := null;
		end if;

		-- if l_concat is null then there is no extra information, just
		-- exit procedure doing nothing

		l_concat := l_info3				  ||
						p_pei_information4  ||
						p_pei_information5  ||
						p_pei_information6  ||
						p_pei_information7  ||
						p_pei_information8  ||
						p_pei_information9  ||
						p_pei_information10 ||
						p_pei_information11 ||
						p_pei_information12 ||
						p_pei_information13 ||
						p_pei_information14 ||
						p_pei_information15 ||
						p_pei_information16 ||
						p_pei_information17;

		if l_concat is null then
			ghr_mto_int.put_line(' > not created.');
			return;
		end if;

		ghr_person_extra_info_api.create_person_extra_info (
			  p_validate						=> g_validate
			 ,p_person_id						=> p_person_id
			 ,p_effective_date				=> p_effective_date
			 ,p_information_type				=> p_information_type
			 ,p_pei_information_category	=> p_information_type
			 ,p_pei_information3				=> l_info3
			 ,p_pei_information4				=> p_pei_information4
			 ,p_pei_information5				=> p_pei_information5
			 ,p_pei_information6				=> p_pei_information6
			 ,p_pei_information7				=> p_pei_information7
			 ,p_pei_information8				=> p_pei_information8
			 ,p_pei_information9				=> p_pei_information9
			 ,p_pei_information10			=> p_pei_information10
			 ,p_pei_information11			=> p_pei_information11
			 ,p_pei_information12			=> p_pei_information12
			 ,p_pei_information13			=> p_pei_information13
			 ,p_pei_information14			=> p_pei_information14
			 ,p_pei_information15			=> p_pei_information15
			 ,p_pei_information16			=> p_pei_information16
			 ,p_pei_information17			=> p_pei_information17
			 ,p_person_extra_info_id		=> l_person_extra_info_id
			 ,p_object_version_number		=> l_object_version_number
		);

		ghr_mto_int.put_line(' > ok, pei_id: '|| l_person_extra_info_id);
		hr_utility.set_location('Leaving:'||l_proc, 30);

		exception
			when others then
				ghr_mto_int.put_line(l_proc||' - raised exception');
				hr_utility.raise_error;

	end;

procedure create_sit_maybe (
			p_person_id							in number
			,p_business_group_id				in number
			,p_id_flex_name					in varchar2
			,p_effective_date					in date
		   ,p_segment1         				in varchar2 default null
		   ,p_segment2         				in varchar2 default null
		   ,p_segment3         				in varchar2 default null
		   ,p_segment4         				in varchar2 default null
		   ,p_segment5         				in varchar2 default null
		   ,p_segment6         				in varchar2 default null
		   ,p_segment7         				in varchar2 default null
		   ,p_segment8         				in varchar2 default null
		   ,p_segment9         				in varchar2 default null
		   ,p_segment10        				in varchar2 default null
		   ,p_segment11        				in varchar2 default null
		   ,p_segment12        				in varchar2 default null
		   ,p_segment13        				in varchar2 default null
		   ,p_segment14        				in varchar2 default null) is

	l_analysis_criteria_id			number;
	l_person_analysis_id				number;
	l_pea_object_version_number	number;

	l_id_flex_num						number(15);

   l_proc    varchar2(72) := g_package||'create_sit_maybe';
	l_concat	 varchar2(2000);

	cursor cur_flex_num is
		select id_flex_num
		from fnd_id_flex_structures_tl
		where id_flex_structure_name = p_id_flex_name
		and language = 'US';

begin

	hr_utility.set_location('Entering:'||l_proc, 10);

	ghr_mto_int.put('Person Spcl Info: '|| p_id_flex_name);

	l_concat := p_segment1	||
					p_segment2	||
					p_segment3	||
					p_segment4	||
					p_segment5	||
					p_segment6	||
					p_segment7	||
					p_segment8	||
					p_segment9	||
					p_segment10	||
					p_segment11	||
					p_segment12	||
					p_segment13	||
					p_segment14;

	if l_concat is null then
		ghr_mto_int.put_line(' > not created.');
		return;
	end if;

	open cur_flex_num;
	fetch cur_flex_num into l_id_flex_num;

	if cur_flex_num%notfound then
		close cur_flex_num;
		hr_utility.set_message(8301, 'GHR_38532_MT_SIT_STRUCT');
		hr_utility.raise_error;
	end  if;
	close cur_flex_num;

	ghr_sit_api.create_sit (
		 p_validate					=> g_validate
		,p_person_id				=> p_person_id
		,p_business_group_id		=> p_business_group_id
		,p_id_flex_num				=> l_id_flex_num
		,p_effective_date			=> p_effective_date
		,p_date_from				=> p_effective_date
		,p_segment1					=> p_segment1
		,p_segment2					=> p_segment2
		,p_segment3					=> p_segment3
		,p_segment4					=> p_segment4
		,p_segment5					=> p_segment5
		,p_segment6					=> p_segment6
		,p_segment7					=> p_segment7
		,p_segment8					=> p_segment8
		,p_segment9					=> p_segment9
		,p_segment10				=> p_segment10
		,p_segment11				=> p_segment11
		,p_segment12				=> p_segment12
		,p_segment13				=> p_segment13
		,p_segment14				=> p_segment14
		,p_analysis_criteria_id			=> l_analysis_criteria_id
		,p_person_analysis_id			=> l_person_analysis_id
		,p_pea_object_version_number	=> l_pea_object_version_number
	);

	ghr_mto_int.put_line(' > ok, criteria_id: '||
				l_analysis_criteria_id||', analysis_id: '||
				l_person_analysis_id);
	hr_utility.set_location('Leaving:'||l_proc, 30);

	exception
		when others then
			ghr_mto_int.put_line(l_proc||' - raised exception');
			hr_utility.raise_error;

end;

	procedure transfer_person_in(
					p_transfer_name			varchar2,
					p_business_group_id		number,
					p_person_type_id			number,
					p_effective_date			date,
					p_tran						ghr_mt_people_f_v%rowtype,
					p_person_id					out NOCOPY per_people_f.person_id%type,
					p_result					out NOCOPY varchar2) is

			l_proc_name				varchar2(30) := 'transfer_person_in';
			l_proc					varchar2(72) := g_package||l_proc_name;
			l_applicant_date		date;
			l_accept_date			date;
			l_message				varchar2(1000);

			-- out parameters for create_us_applicant
			l_applicant_number 				per_people_f.applicant_number%type;
			l_person_id 					per_people_f.person_id%type;
            -- Bug#3718167 Added variable l_exists_full_name
            l_exists_full_name              per_people_f.full_name%type;
            l_exists_person_id              per_people_f.person_id%type;
			l_assignment_id 				number;
            l_assignment_status_type_id     number;   ---AVR
			l_address_id	 				number;
			l_application_id	 			number;
			l_per_object_version_number 	number;
			l_asg_object_version_number 	number;
			l_apl_object_version_number 	number;
			l_per_effective_start_date 		date;
			l_per_effective_end_date 		date;
			l_full_name						per_people_f.full_name%type;
			l_per_comment_id 				number;
			l_assignment_sequence 			number;
			l_name_combination_warning		boolean;
            l_orig_hire_warning             boolean;

			l_pei			ghr_mt_people_ei_v%rowtype;
			l_sit			ghr_mt_analysis_criteria_v%rowtype;
            l_hr_user_type  varchar2(20);
			l_address		ghr_mt_addresses_v%rowtype;

			--
			-- select all people extra info rows by transfer name and
			-- person_id, The person_id must uniquely identify all information
			-- in the interface table for a person by transfer_name.
			--
			cursor cur_people_ei is
				select *
				from ghr_mt_people_ei_v
				where mt_name = p_transfer_name
				and mt_person_id = p_tran.mt_person_id;

			cursor cur_sit is
				select *
				from ghr_mt_analysis_criteria_v
				where mt_name = p_transfer_name
				and mt_person_id = p_tran.mt_person_id;

			cursor cur_address is
				select *
				from ghr_mt_addresses_v
				where mt_name = p_transfer_name
				and mt_person_id = p_tran.mt_person_id
				and mt_contact_name is null;

			/*
			cursor cur_contact_address is
				select *
				from ghr_mt_addresses_v
				where mt_name = p_transfer_name
				and mt_person_id = p_tran.mt_person_id
				and mt_contact_name is not null;
			*/

----Added for Assignment_status_type_id  --AVR

         cursor cur_asg_type is
            select ASSIGNMENT_STATUS_TYPE_ID
            from PER_ASSIGNMENT_STATUS_TYPES
            where ASSIGNMENT_STATUS_TYPE_ID < 10
            and user_status like '%Accepted%'
            and business_group_id is null;

         -- Bug#3718167 Added full_name in the selection
         cursor cur_person_exists is
            select person_id, full_name
            from per_people_f
            where national_identifier = p_tran.national_identifier
            and business_group_id     = p_business_group_id
            and p_effective_date
                between effective_start_date and effective_end_date;
		begin

			hr_utility.set_location('Entering:'||l_proc, 10);
			p_result := 'P';

			ghr_mto_int.put_line('Transfering: '||p_tran.last_name);

			if ck_parameter_list(p_tran) = FALSE then
				ghr_mto_int.put_line('Missing required data for transfer in');
				ghr_mto_int.log_message(
								p_procedure		=> l_proc_name,
								p_message		=> 'Missing last_name and/or '||
								'mt_person_id from ghr_mt_people_f_v');

				-- so message gets into the log, since the caller rollsback on error
				commit;

				hr_utility.set_message(8301, 'GHR_38533_MTI_MISS_REQ');
				hr_utility.raise_error;
			end if;


--------------------------  changed the applicant from p_effective_date-2 to p_effective_date-1 for bug# 2488778

			l_applicant_date := trunc(p_effective_date) - 1;
			l_accept_date    := trunc(p_effective_date) - 1;

			ghr_mto_int.put_line(report_state(g_validate, 'Validate Flag:'));
			hr_utility.set_location('Create Applicant:'||l_proc, 20);

         for cur_person_exists_rec in cur_person_exists
         loop
            l_exists_person_id := cur_person_exists_rec.person_id;
            l_exists_full_name := cur_person_exists_rec.full_name;
         exit;
         end loop;
			--
			-- on transfer in:
			-- p_tran.comment_id contains comments
    IF l_exists_person_id is NULL then
			ghr_applicant_api.create_applicant (
				 p_validate							=> g_validate
				,p_date_received					=> l_applicant_date
				,p_business_group_id				=> p_business_group_id
				,p_last_name						=> p_tran.last_name
				,p_sex								=> p_tran.sex
				,p_person_type_id					=> p_person_type_id
				,p_applicant_number				=> l_applicant_number
				,P_per_COMMENTS					=> p_tran.comment_id
				,p_date_of_birth					=>
						to_date(p_tran.date_of_birth,g_datefmt)
				,P_EMAIL_ADDRESS					=> p_tran.email_address
				,P_EXPENSE_CHECK_SEND_TO_ADDRES	=>
								p_tran.expense_check_send_to_address
				,p_first_name						=> p_tran.first_name
				,P_KNOWN_AS							=> p_tran.known_as
				,P_MARITAL_STATUS					=> p_tran.MARITAL_STATUS
				,P_MIDDLE_NAMES					=> p_tran.MIDDLE_NAMES
				,P_NATIONALITY						=> p_tran.NATIONALITY
				,p_national_identifier			=> p_tran.national_identifier
				,P_PREVIOUS_LAST_NAME			=> p_tran.PREVIOUS_LAST_NAME
				,P_REGISTERED_DISABLED_FLAG	=> p_tran.REGISTERED_DISABLED_FLAG
				,P_TITLE								=> p_tran.TITLE
				,P_WORK_TELEPHONE 				=> p_tran.WORK_TELEPHONE
------------,P_ATTRIBUTE_CATEGORY			=> p_tran.ATTRIBUTE_CATEGORY
				,P_ATTRIBUTE1						=> p_tran.attribute1
				,P_ATTRIBUTE2						=> p_tran.ATTRIBUTE2
				,P_ATTRIBUTE3						=> p_tran.ATTRIBUTE3
				,P_ATTRIBUTE4						=> p_tran.ATTRIBUTE4
			   ,P_ATTRIBUTE5						=> p_tran.ATTRIBUTE5
				,P_ATTRIBUTE6						=> p_tran.ATTRIBUTE6
				,P_ATTRIBUTE7						=> p_tran.ATTRIBUTE7
				,P_ATTRIBUTE8						=> p_tran.ATTRIBUTE8
				,P_ATTRIBUTE9						=> p_tran.ATTRIBUTE9
				,P_ATTRIBUTE10						=> p_tran.ATTRIBUTE10
				,P_ATTRIBUTE11						=> p_tran.ATTRIBUTE11
				,P_ATTRIBUTE12						=> p_tran.ATTRIBUTE12
				,P_ATTRIBUTE13						=> p_tran.ATTRIBUTE13
				,P_ATTRIBUTE14						=> p_tran.ATTRIBUTE14
				,P_ATTRIBUTE15						=> p_tran.ATTRIBUTE15
				,P_ATTRIBUTE16						=> p_tran.ATTRIBUTE16
				,P_ATTRIBUTE17						=> p_tran.ATTRIBUTE17
				,P_ATTRIBUTE18						=> p_tran.ATTRIBUTE18
				,P_ATTRIBUTE19						=> p_tran.ATTRIBUTE19
				,P_ATTRIBUTE20						=> p_tran.ATTRIBUTE20
				,P_ATTRIBUTE21						=> p_tran.ATTRIBUTE21
				,P_ATTRIBUTE22						=> p_tran.ATTRIBUTE22
				,P_ATTRIBUTE23						=> p_tran.ATTRIBUTE23
				,P_ATTRIBUTE24						=> p_tran.ATTRIBUTE24
				,P_ATTRIBUTE25						=> p_tran.ATTRIBUTE25
				,P_ATTRIBUTE26						=> p_tran.ATTRIBUTE26
				,P_ATTRIBUTE27						=> p_tran.ATTRIBUTE27
				,P_ATTRIBUTE28						=> p_tran.ATTRIBUTE28
				,P_ATTRIBUTE29						=> p_tran.ATTRIBUTE29
				,P_ATTRIBUTE30						=> p_tran.ATTRIBUTE30
				,P_SUFFIX                 		=> p_tran.SUFFIX
				,P_PER_INFORMATION_CATEGORY	=> p_tran.PER_INFORMATION_CATEGORY
				,P_PER_INFORMATION1				=> p_tran.PER_INFORMATION1
				,P_PER_INFORMATION2				=> p_tran.PER_INFORMATION2
				,P_PER_INFORMATION3				=> p_tran.PER_INFORMATION3
				,P_PER_INFORMATION4				=> p_tran.PER_INFORMATION4
				,P_PER_INFORMATION5				=> p_tran.PER_INFORMATION5
				,P_PER_INFORMATION6				=> p_tran.PER_INFORMATION6
				,P_PER_INFORMATION7				=> p_tran.PER_INFORMATION7
				,P_PER_INFORMATION8				=> p_tran.PER_INFORMATION8
				,P_PER_INFORMATION9				=> p_tran.PER_INFORMATION9
				,P_PER_INFORMATION10				=> p_tran.PER_INFORMATION10
				,P_PER_INFORMATION11				=> p_tran.PER_INFORMATION11
				,P_PER_INFORMATION12				=> p_tran.PER_INFORMATION12
				,P_PER_INFORMATION13				=> p_tran.PER_INFORMATION13
				,P_PER_INFORMATION14				=> p_tran.PER_INFORMATION14
				,P_PER_INFORMATION15				=> p_tran.PER_INFORMATION15
				,P_PER_INFORMATION16				=> p_tran.PER_INFORMATION16
				,P_PER_INFORMATION17				=> p_tran.PER_INFORMATION17
				,P_PER_INFORMATION18				=> p_tran.PER_INFORMATION18
				,P_PER_INFORMATION19				=> p_tran.PER_INFORMATION19
				,P_PER_INFORMATION20				=> p_tran.PER_INFORMATION20
				,P_PER_INFORMATION21				=> p_tran.PER_INFORMATION21
				,P_PER_INFORMATION22				=> p_tran.PER_INFORMATION22
				,P_PER_INFORMATION23				=> p_tran.PER_INFORMATION23
				,P_PER_INFORMATION24				=> p_tran.PER_INFORMATION24
				,P_PER_INFORMATION25				=> p_tran.PER_INFORMATION25
				,P_PER_INFORMATION26				=> p_tran.PER_INFORMATION26
				,P_PER_INFORMATION27				=> p_tran.PER_INFORMATION27
				,P_PER_INFORMATION28				=> p_tran.PER_INFORMATION28
				,P_PER_INFORMATION29				=> p_tran.PER_INFORMATION29
				,P_PER_INFORMATION30				=> p_tran.PER_INFORMATION30
				,P_BACKGROUND_CHECK_STATUS		=> p_tran.BACKGROUND_CHECK_STATUS
				,P_BACKGROUND_DATE_CHECK		=>
						to_date(p_tran.BACKGROUND_DATE_CHECK,g_datefmt)
				,P_CORRESPONDENCE_LANGUAGE		=> p_tran.CORRESPONDENCE_LANGUAGE
				,P_FTE_CAPACITY					=> p_tran.FTE_CAPACITY
				,P_HOLD_APPLICANT_DATE_UNTIL	=>
						to_date(p_tran.HOLD_APPLICANT_DATE_UNTIL,g_datefmt)
				,P_HONORS							=> p_tran.HONORS
				,P_MAILSTOP							=> p_tran.MAILSTOP
				,P_OFFICE_NUMBER					=> p_tran.OFFICE_NUMBER
				,P_PRE_NAME_ADJUNCT				=> p_tran.PRE_NAME_ADJUNCT
				,P_PROJECTED_START_DATE			=>
						to_date(p_tran.PROJECTED_START_DATE,g_datefmt)
				,P_RESUME_EXISTS					=> p_tran.RESUME_EXISTS
				,P_RESUME_LAST_UPDATED			=>
						to_date(p_tran.RESUME_LAST_UPDATED,g_datefmt)
				,P_WORK_SCHEDULE					=> p_tran.WORK_SCHEDULE
				,p_person_id						=> l_person_id
				,p_assignment_id					=> l_assignment_id
				,p_application_id					=> l_application_id
				,p_per_object_version_number	=> l_per_object_version_number
				,p_asg_object_version_number	=> l_asg_object_version_number
				,p_apl_object_version_number  => l_apl_object_version_number
				,p_per_effective_start_date	=> l_per_effective_start_date
				,p_per_effective_end_date		=> l_per_effective_end_date
				,p_full_name						=> l_full_name
				,p_per_comment_id					=> l_per_comment_id
				,p_assignment_sequence			=> l_assignment_sequence
				,p_name_combination_warning	=> l_name_combination_warning
                                ,p_orig_hire_warning            => l_orig_hire_warning
			);

			-- assign out parameter p_person_id
			p_person_id := l_person_id;

			if g_validate = FALSE then
				ghr_mto_int.put_line('===== Create Applicant =============');
				ghr_mto_int.put_line('Person ID:'||l_person_id);
				ghr_mto_int.put_line('Assignment ID:'||l_assignment_id);
				ghr_mto_int.put_line('Application ID:'||l_application_id);
				ghr_mto_int.put_line(
					report_state(l_name_combination_warning,'Name Warning:'));
			end if;

-------AVR  bug 2467099
         for cur_asg_type_rec in cur_asg_type
         loop
            l_assignment_status_type_id := cur_asg_type_rec.assignment_status_type_id;
         end loop;


			hr_utility.set_location('l_assignment_id  : '||to_char(l_assignment_id), 29);
			hr_utility.set_location('l_person_id      : '||to_char(l_person_id)    , 29);
   		hr_utility.set_location('l_asg_sts_tpe_id :' ||to_char(l_assignment_status_type_id), 29);

			hr_utility.set_location('Accept Applicant:'||l_proc, 30);

			if g_validate = FALSE then

---------------------changed the p_datetrack_update_mode to CORRECTION for Bug#2488778

				hr_assignment_internal.update_status_type_apl_asg (
					 p_effective_date 				=> l_accept_date
   					,p_datetrack_update_mode		=> 'CORRECTION'
					,p_assignment_id					=> l_assignment_id
--					,p_object_version_number		=> l_per_object_version_number
-- Sundar Commented the above line and added the below one. Asg OVN shd be passed instead of per ovn. Bug 2944589
					,p_object_version_number		=> l_asg_object_version_number
					,p_expected_system_status		=> 'ACCEPTED'
               ,p_assignment_status_type_id  => l_assignment_status_type_id
					,p_effective_start_date			=> l_per_effective_start_date
					,p_effective_end_date			=> l_per_effective_end_date
				);

					ghr_mto_int.put_line('------- Accept Applicant -------------');
					ghr_mto_int.put_line('Start Date: '||
						to_char(l_per_effective_start_date,g_datefmt));
					ghr_mto_int.put_line('End Date: '||
						to_char(l_per_effective_end_date,g_datefmt));
					ghr_mto_int.put_line('------------------------------------');
			end if;

			hr_utility.set_location('Person Extra Info:'||l_proc, 40);

			for c_people_ei in cur_people_ei loop

				l_pei := c_people_ei;

				create_person_extra_info_maybe (
					 p_person_id				=> l_person_id
					 ,p_effective_date		=> l_accept_date
					 ,p_information_type		=> l_pei.information_type
					 ,p_pei_information3		=> l_pei.pei_information3
					 ,p_pei_information4		=> l_pei.pei_information4
					 ,p_pei_information5		=> l_pei.pei_information5
					 ,p_pei_information6		=> l_pei.pei_information6
					 ,p_pei_information7		=> l_pei.pei_information7
					 ,p_pei_information8		=> l_pei.pei_information8
					 ,p_pei_information9		=> l_pei.pei_information9
					 ,p_pei_information10	=> l_pei.pei_information10
					 ,p_pei_information11	=> l_pei.pei_information11
					 ,p_pei_information12	=> l_pei.pei_information12
					 ,p_pei_information13	=> l_pei.pei_information13
					 ,p_pei_information14	=> l_pei.pei_information14
					 ,p_pei_information15	=> l_pei.pei_information15
					 ,p_pei_information16	=> l_pei.pei_information16
					 ,p_pei_information17	=> l_pei.pei_information17
				);

			end loop;

			hr_utility.set_location('Person Spcl Info:'||l_proc, 50);

			for c_sit in cur_sit loop

				l_sit := c_sit;

				create_sit_maybe (
					p_person_id				=> l_person_id
					,p_business_group_id	=> p_business_group_id
					,p_id_flex_name		=> l_sit.mt_information_type
					,p_effective_date		=> l_accept_date
					,p_segment1				=> l_sit.segment1
					,p_segment2				=> l_sit.segment2
					,p_segment3				=> l_sit.segment3
					,p_segment4				=> l_sit.segment4
					,p_segment5				=> l_sit.segment5
					,p_segment6				=> l_sit.segment6
					,p_segment7				=> l_sit.segment7
					,p_segment8				=> l_sit.segment8
					,p_segment9				=> l_sit.segment9
					,p_segment10			=> l_sit.segment10
					,p_segment11			=> l_sit.segment11
					,p_segment12			=> l_sit.segment12
					,p_segment13			=> l_sit.segment13
					,p_segment14			=> l_sit.segment14
				);

			end loop;
    commit;
			-- get persons address info
			open cur_address;
			fetch cur_address into l_address;

		IF cur_address%found then

				-- Note: ghr_mt_address_v.region_1=county,
				--       ghr_mt_address_v.region_2=state
				--
				-- This creates US style address and assumes region_1
				-- is the county and region_2 is the state
		    hr_utility.set_location(' Address :'||l_proc, 55);
				--
/***** Old code for address Bug 2467099
          begin
				hr_person_address_api.create_us_person_address (
					P_EFFECTIVE_DATE				=> l_accept_date,
					P_PERSON_ID						=> l_person_id,
					P_PRIMARY_FLAG					=> l_address.primary_flag,
					P_DATE_FROM						=>
						to_date(l_address.date_from,g_datefmt),
					P_DATE_TO						=>
						to_date(l_address.date_to,g_datefmt),
					P_COMMENTS						=> l_address.comments,
					P_ADDRESS_TYPE					=> l_address.address_type,
					P_ADDRESS_LINE1    			=> l_address.address_line1,
					P_ADDRESS_LINE2  				=> l_address.address_line2,
					P_ADDRESS_LINE3				=> l_address.address_line3,
					P_CITY       					=> l_address.town_or_CITY,
					P_STATE							=> l_address.region_2,
					P_ZIP_CODE						=> l_address.postal_code,
					P_COUNTY							=> l_address.region_1,
					P_COUNTRY           			=> l_address.COUNTRY,
					P_TELEPHONE_NUMBER_1			=> l_address.TELEPHONE_NUMBER_1,
					P_TELEPHONE_NUMBER_2			=> l_address.TELEPHONE_NUMBER_2,
---------------P_ADDR_ATTRIBUTE_CATEGORY 	=> l_address.ADDR_ATTRIBUTE_CATEGORY,
					P_ADDR_ATTRIBUTE1         	=> l_address.ADDR_ATTRIBUTE1,
					P_ADDR_ATTRIBUTE2        	=> l_address.ADDR_ATTRIBUTE2,
					P_ADDR_ATTRIBUTE3       	=> l_address.ADDR_ATTRIBUTE3,
					P_ADDR_ATTRIBUTE4      		=> l_address.ADDR_ATTRIBUTE4,
					P_ADDR_ATTRIBUTE5     		=> l_address.ADDR_ATTRIBUTE5,
					P_ADDR_ATTRIBUTE6    		=> l_address.ADDR_ATTRIBUTE6,
					P_ADDR_ATTRIBUTE7   			=> l_address.ADDR_ATTRIBUTE7,
					P_ADDR_ATTRIBUTE8  			=> l_address.ADDR_ATTRIBUTE8,
					P_ADDR_ATTRIBUTE9         	=> l_address.ADDR_ATTRIBUTE9,
					P_ADDR_ATTRIBUTE10        	=> l_address.ADDR_ATTRIBUTE10,
					P_ADDR_ATTRIBUTE11        	=> l_address.ADDR_ATTRIBUTE11,
					P_ADDR_ATTRIBUTE12        	=> l_address.ADDR_ATTRIBUTE12,
					P_ADDR_ATTRIBUTE13        	=> l_address.ADDR_ATTRIBUTE13,
					P_ADDR_ATTRIBUTE14        	=> l_address.ADDR_ATTRIBUTE14,
					P_ADDR_ATTRIBUTE15       	=> l_address.ADDR_ATTRIBUTE15,
					P_ADDR_ATTRIBUTE16      	=> l_address.ADDR_ATTRIBUTE16,
					P_ADDR_ATTRIBUTE17     		=> l_address.ADDR_ATTRIBUTE17,
					P_ADDR_ATTRIBUTE18    		=> l_address.ADDR_ATTRIBUTE18,
					P_ADDR_ATTRIBUTE19   		=> l_address.ADDR_ATTRIBUTE19,
					P_ADDR_ATTRIBUTE20  			=> l_address.ADDR_ATTRIBUTE20,
					P_ADDRESS_ID       			=> l_ADDRESS_ID,
					P_OBJECT_VERSION_NUMBER   	=> l_per_object_VERSION_NUMBER
				);
           exception when others then
			     hr_utility.set_location(' Error Address :'||l_proc, 56);
              l_message := 'Error in Address creation ' ||  sqlerrm(sqlcode);
              end;
************/

        l_hr_user_type := fnd_profile.value('HR_USER_TYPE');

        IF l_hr_user_type = 'INT' THEN

            begin

             hr_person_address_api.create_us_person_address
             (p_effective_date              => l_accept_date
             ,p_person_id                   => l_person_id
             ,p_primary_flag                => l_address.primary_flag
             ,p_date_from                   => l_accept_date
             ,p_address_line1               => l_address.address_line1
             ,p_address_line2               => l_address.address_line2
             ,p_address_line3               => l_address.address_line3
             ,p_city                        => l_address.town_or_CITY
             ,p_state                       => l_address.region_2
             ,p_county                      => l_address.region_1
             ,p_zip_code                    => l_address.postal_code
             ,p_country                     => l_address.COUNTRY
             ,p_address_id                  => l_ADDRESS_ID
             ,p_object_version_number       => l_per_object_VERSION_NUMBER
             );
				 ghr_mto_int.log_message(
				        		p_procedure	=> l_proc_name,
						      p_message	=> 'Address created Successfully');

            exception
                when others then
                      hr_utility.set_location(' User type INT Error Address :'||l_proc, 56);
                      -- Bug#3718167 Added Person Name and SSN in the log text
                      l_message := 'Error in INT Address creation for ' || l_full_name||
                                   ' SSN: '||p_tran.national_identifier|| 'Error is:'||sqlerrm(sqlcode);
			        	  ghr_mto_int.log_message(
				        		p_procedure	=> l_proc_name,
			        			p_message	=> l_message);
            end;


        ELSIF l_hr_user_type = 'PER' THEN

             begin

             hr_person_address_api.create_person_address
             (p_effective_date              => l_accept_date
             ,p_person_id                   => l_person_id
             ,p_primary_flag                => l_address.primary_flag
             ,p_style                       => 'US_GLB_FED' --Bug# 4725292
             ,p_date_from                   => l_accept_date
             ,p_address_line1               => l_address.address_line1
             ,p_address_line2               => l_address.address_line2
             ,p_address_line3               => l_address.address_line3
             ,p_town_or_city                => l_address.town_or_CITY
             ,p_region_1                    => l_address.region_1
             ,p_region_2                    => l_address.region_2
             ,p_postal_code                 => l_address.postal_code
             ,p_country                     => l_address.COUNTRY
             ,p_address_id                  => l_ADDRESS_ID
             ,p_object_version_number       => l_per_object_VERSION_NUMBER
             );

				 ghr_mto_int.log_message(
				        		p_procedure	=> l_proc_name,
						      p_message	=> 'PER Address created Successfully');
            exception when others then
                      hr_utility.set_location(' User type PER Error Address :'||l_proc, 56);
                      -- Bug#3718167 Added Person Name and SSN in the log text
                      l_message := 'Error in PER Address creation for ' || l_full_name||
                                   ' SSN: '||p_tran.national_identifier|| 'Error is:'||sqlerrm(sqlcode);
				          ghr_mto_int.log_message(
				        		p_procedure	=> l_proc_name,
						      p_message	=> l_message);
            end;
        END IF;

	END IF;

			close cur_address;

			ghr_mto_int.put_line('* Successful');
			hr_utility.set_location('Leaving:'||l_proc, 50);

 ELSE
       -- Employee exists with same SSN....
       -- Bug#3718167  Added Person Full Name in the Log Message
          ghr_mto_int.log_message(
           p_procedure => l_proc_name,
           p_message   => 'Person exists with the same SSN : ' || p_tran.national_identifier ||
                          ' in the given business group with person Full Name as '||l_exists_full_name ||
                          ' and the person id is ' ||to_char(l_exists_person_id) );
 END IF;

			exception
				when others then

					rollback;
					-- NOCOPY Changes Sundar 03Dec2003
					p_person_id	:= NULL;
					p_result := NULL;
					-- End NOCOPY changes
					ghr_mto_int.put_line(l_proc||' - raised exception');
					ghr_mto_int.put_line(sqlerrm);

					ghr_mto_int.log_message(
						p_procedure	=> l_proc_name,
						p_message	=> l_message);

					hr_utility.raise_error;

		end transfer_person_in;

		--
		-- For all rows in ghr_mt_people_f_v where mt_status = 'Y' and
		-- name = ghr_mass_transfers.name do the following:
		--		1. create an applicant
		--		2. accept the applicant
		--		3. copy information from the row into person and person analysis
		--			ddf's
		--
		-- Last name and person_id must exist in ghr_mt_people_f_v for each person
		-- transfered in.  Last name is required by create_us_applicant()
		-- and person_id is necessary to differentiate between like named people
		-- when setting the mt_status column to the transfer result (P or E)
		--
		-- All rows in the interface table pertaining to a person in a transfer
		-- group (l_transfer_name) must contain the same mt_person_id.  This
		-- is used to query data from the interface table.
		--
		-- Ghr_mt_people_f_v.mt_status is set to 'P' for each successful
		-- transfer and set to 'E' if an error was encountered.  The
		-- transfer name, last_name, and national_identifier (ssn) is
		-- expected to be unique.
		--
		-- Parameters:
		--		p_transfer_id:		id of row in ghr_mass_transfers containing
		--								transfer information
		--		p_business_group_id:	identifies the business group
		--
		procedure mass_transfer_in(p_errbuf 		 		out NOCOPY varchar2,
                       		 		p_retcode 		 		out NOCOPY number,
											p_transfer_id			in number,
										   p_business_group_id	in number) is

			l_proc_name  varchar2(30) := 'mass_transfer_in';
			l_proc       varchar2(72) := g_package||l_proc_name;

			l_person_type_id			per_person_types.person_type_id%type;
			l_person_type_mti		   per_person_types.user_person_type%type;
			l_person_type_mti_id		per_person_types.person_type_id%type;
			l_transfer_name			ghr_mass_transfers.name%type;
			l_effective_date			ghr_mass_transfers.effective_date%type;
			l_person_row				ghr_mt_people_f_v%rowtype;
			l_result						varchar2(1);
			l_person_id					per_people_f.person_id%type;
			l_inter_bg_transfer		varchar2(1);

			l_error_count				number := 0;
			l_transfer_count			number := 0;
			l_message					varchar2(250);
			l_errbuf						varchar2(2000);
			l_retcode					number;

			e_transfer_in_warning	exception;

			cursor cur_person_type is
				select person_type_id
				from per_person_types
				where business_group_id = p_business_group_id
				and user_person_type = 'Applicant';

         cursor cur_person_type_mti is
            select b.USER_PERSON_TYPE   usertype,
                   b.person_type_id     person_type_id
            from   per_all_people_f a,
                   per_person_types b
            where a.BUSINESS_GROUP_ID = b.BUSINESS_GROUP_ID
            and   a.business_group_id = p_business_group_id
            and   a.PERSON_TYPE_ID    = b.PERSON_TYPE_ID
            and   a.person_id         = l_person_row.mt_person_id
            and   l_effective_date
                  between a.effective_start_date and a.effective_end_date;


			-- Rows in ghr_mt_people_f_v with mt_status of 'Y' have been
			-- selected for transfer in
			cursor cur_people is
				select *
				from ghr_mt_people_f_v
				where mt_name = l_transfer_name
				and mt_status = 'Y';

		begin

			hr_utility.set_location('Entering:'||l_proc, 10);
			ghr_mto_int.set_log_program_name('Mass Transfer In');

			ghr_mto_int.get_transfer_parameters(
					p_mass_transfer_id	=> p_transfer_id,
					p_transfer_name   	=> l_transfer_name,
					p_effective_date		=> l_effective_date,
					p_inter_bg_transfer	=> l_inter_bg_transfer);

			if l_effective_date is null then
				ghr_mto_int.log_message(
					p_procedure	=> l_proc_name,
					p_message	=> 'Failed to get Transfer In information from'||
										'GHR_MASS_TRANSFERS for mass_transfer_id:'||
										p_transfer_id);

				hr_utility.set_message(8301, 'GHR_38534_MT_ID_ERR');
				hr_utility.raise_error;
			end if;

			ghr_mto_int.put_line('Starting Transfer In for:'||l_transfer_name);

			-- find the person type id for applicant in the business group
			open cur_person_type;
			fetch cur_person_type into l_person_type_id;
			close cur_person_type;

			if l_person_type_id is null then
				ghr_mto_int.log_message(
					p_procedure	=> l_proc_name,
					p_message	=>
						'Failed to get the person_type_id for APPLICANT '||
						'in the business group');
				hr_utility.set_message(8301, 'GHR_38535_NO_MTI_PERSON_TYPE');
				hr_utility.raise_error;
			end if;

			-- for all people selected for transfer in
			for c_person in cur_people loop

				l_person_row := c_person;
				l_result := 'P';		-- if we don't call transfer_person_in()

            for cur_person_type_mti_rec in cur_person_type_mti
            loop
                 l_person_type_mti      := cur_person_type_mti_rec.usertype;
			        l_person_type_mti_id   := cur_person_type_mti_rec.person_type_id;
            exit;
            end loop;

			   if l_person_type_mti = 'Employee' then
                   -- Bug#3718167 Added Person Name, SSN
				   ghr_mto_int.log_message(
				        p_procedure	=> l_proc_name,
					     p_message	   =>
                'Error: Selected person: '||c_person.full_name||'(SSN: '||c_person.national_identifier||
                ') contains an invalid Person Type as of the Effective ' ||
                'Date of the Transfer In action.  Person Type may not be Employee.  Please  ' ||
                'make sure this person is not an Employee as of the Effective Date of the   ' ||
                'Transfer In, and then resubmit the Transfer In action.');
				     hr_utility.raise_error;
			   end if;

				-- A person is transfered in only if this is not an
				-- inter business group transfer
				if nvl(l_person_row.mt_inter_bg_transfer,'N') <> 'Y' then
					begin
						transfer_person_in(
								p_transfer_name		=> l_transfer_name,
								p_business_group_id	=> p_business_group_id,
								p_person_type_id		=> l_person_type_id,
								p_effective_date		=> l_effective_date,
								p_tran					=> l_person_row,
								p_person_id				=> l_person_id,
								p_result					=> l_result);
					exception
						when others then
							l_result := 'E';
							l_error_count := l_error_count + 1;
							-- Bug#3718167 Added Full Name, SSN in the log message
							ghr_mto_int.log_message(
								p_procedure	=> l_proc_name,
								p_message	=>
									'Mass Transfer In for person: '|| c_person.full_name||' SSN: '||c_person.national_identifier||
									' Person ID: '||l_person_id||
                                    ' failed with error message: '|| sqlerrm(sqlcode));

					end;
				else
					l_person_id := to_number(l_person_row.mt_person_id);
				end if;

				set_transfer_status(
						p_status_code		=> l_result,
						p_transfer_name	=> l_transfer_name,
						p_last_name			=> l_person_row.last_name,
						p_person_id			=> l_person_row.mt_person_id);

				if l_result = 'P' then
					update_mass_transfer_in_flag(
							p_person_id			=> l_person_id,
							p_transfer_id		=> p_transfer_id,
							p_effective_date	=> l_effective_date);
				end if;

				commit;
				ghr_mto_int.put_line('Committed');

				l_transfer_count := l_transfer_count + 1;

			end loop;

			-- always call sri's package to create sf52's
			begin

				ghr_mti_app.populate_and_create_52(
					p_errbuf					=> l_errbuf,
					p_retcode				=> l_retcode,
					p_mtin_name				=> l_transfer_name,
					p_mtin_id				=> p_transfer_id,
					p_effective_date		=> l_effective_date,
					p_business_group_id	=> p_business_group_id);

			exception
				when others then

					ghr_mto_int.put_line('ghr_mti_app.populate_and_create_52'||
												' - raised exception');

					rollback;		-- rollback changes made by the procedure

					-- return errbuf and retcode returned from sri's procedure
					p_errbuf := l_errbuf;
					p_retcode := l_retcode;

					ghr_mto_int.log_message(
						p_procedure	=> l_proc_name,
						p_message	=>
							'Mass Transfer In for '||
							l_transfer_name ||
                        'Sql err '||sqlerrm(sqlcode)||
							l_errbuf || ' from populate_and_create_52()');
                --- ' recieved error message: "'||

					commit;
					hr_utility.raise_error;
			end;

			-- notify user that at data from the interface table was not
			-- successfully transfered in by transfer_person_in()
			if l_error_count <> 0 then
				raise e_transfer_in_warning;
			end if;

			p_errbuf := null;
			p_retcode := 0;

			ghr_mto_int.log_message(
					p_procedure	=> l_proc_name,
					p_message	=>
						'Mass Transfer In for '||
						l_transfer_name || ' transfered '||l_transfer_count ||
						' employees.');

			commit;
			hr_utility.set_location('Leaving:'||l_proc, 10);

		exception
			when e_transfer_in_warning then
				l_message := 'Warning: Mass Transfer In for transfer: '||
								l_transfer_name ||' was unable to transfer '||
								l_error_count || ' people out of '|| l_transfer_count;

				ghr_mto_int.log_message(
					p_procedure	=> l_proc_name,
					p_message	=> l_message);

				p_errbuf := l_message;
				p_retcode := 1;   -- signal warning condition to concurrent mgr

				commit;

			when others then
				ghr_mto_int.put_line(l_proc||' - raised exception');

				  if l_person_type_mti <> 'Employee' then
						ghr_mto_int.log_message(
							p_procedure	=> l_proc_name,
							p_message	=>
								'Mass Transfer In for mass_transfer_id: '||
								p_transfer_id || ' failed with error message: '||
								sqlerrm(sqlcode));
				  end if;

				p_errbuf := sqlerrm(sqlcode);
				p_retcode := 2;	-- signal error condition to concurrent mgr

				commit;

		end mass_transfer_in;

end ghr_mti_int;

/
