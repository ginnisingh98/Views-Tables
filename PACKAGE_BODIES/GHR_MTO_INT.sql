--------------------------------------------------------
--  DDL for Package Body GHR_MTO_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MTO_INT" AS
/* $Header: ghmtoint.pkb 120.3 2005/09/28 08:01:29 vnarasim noship $ */

	g_datefmt	constant varchar2(12) := 'DD-MON-YYYY';
	g_name		constant varchar2(12) := 'GHR_MTO_INT';
	g_log_name      varchar2(30);
	g_message	varchar2(128); -- 128 max for hr_utility.set_location

        -- Created g_new_line to use instead of CHR(10)
        g_new_line      varchar2(1)    := substr('
',1,1);

	--
	-- Directs logging messages to hr_utility.set_location unless the global
	-- variable, g_dbms_output, is TRUE, then output goes to dbms_output
	--
	-- g_dbms_output is FALSE by default
	--
	procedure put_line(p_message varchar2 default null) is

	begin
		if g_dbms_output = TRUE then
                       null;
			--dbms_output.put_line(g_message||p_message);
		else
			hr_utility.set_location(substr(g_message||p_message,128),33);
		end if;

		g_message := null;

	exception
		when others then
			null;
	end;

	procedure put(p_message varchar2) is
	begin
		g_message := substr(g_message||p_message,128);

	exception
		when others then
			null;
	end;

	function row_exists (p_transfer_name varchar2,
			     p_person_id number,
			p_table_name varchar2,
			p_info_type varchar2 default null,
			p_contact_name varchar2 default null)
	return boolean is

		l_count			number;

		-- if p_contact_name is null then it should not influence the
		-- query result, otherwise it should identify a contact address
		-- row regardless of the contact name.  We want to have only one
		-- contact address.
		cursor cur_ck_unique is
			select count(*)
			from ghr_interface
			where information4 = p_table_name			-- mt_table_name
			and information1 = p_transfer_name			-- mt_name
			and information3 = to_char(p_person_id)	-- mt_person_id
			and nvl(information5,'null') = nvl(p_info_type,'null')
			and decode(information7,null,'null','notnull') =
				decode(nvl(p_contact_name,information7),null,'null','notnull');

	begin

		open cur_ck_unique;
		fetch cur_ck_unique into l_count;
		close cur_ck_unique;

		if l_count = 0 then
			return FALSE;
		else
			return TRUE;
		end if;

	end;

	--
	-- set program name used by log_message
	--
	-- The concurrent program request id is appended to the
	-- name passed and if the result is > 29 the name is truncated
	--
	-- If the procedure is not called by the concurrent manager then
	-- the value ghr_process_log_s.nextval is used in place of the
	-- request id
	--
	procedure set_log_program_name(p_log_program_name varchar2) is
		l_prog_name			varchar2(30);
		l_id_len				number;
		l_name_len			number;
		l_proc			varchar2(72) := g_package||'set_log_program_name';

		cursor cur_get_seq is
			select to_char(ghr_process_log_s.nextval)
			from sys.dual;

	begin
		hr_utility.set_location('Entering:'||l_proc, 10);

		l_prog_name := Fnd_profile.value('CONC_REQUEST_ID');

      hr_utility.set_location('l_prog_name conc_request_id :' || l_prog_name ,11);
      if l_prog_name = '-1' then
         l_prog_name := NULL;
      end if;

		if l_prog_name is null then -- we're not called by concurrent mgr
			open cur_get_seq;
			fetch cur_get_seq into l_prog_name;
			close cur_get_seq;
      hr_utility.set_location('l_prog_name in if condn :' || l_prog_name ,12);
		end if;


		l_id_len := length(l_prog_name);
		l_name_len := length(p_log_program_name);

		if l_id_len + l_name_len + 1 > 30 then
			l_prog_name := substr(p_log_program_name,1,30 - l_id_len - 1)||'_'||
								l_prog_name;
		else
			l_prog_name := p_log_program_name||'_'||l_prog_name;
		end if;

		put_line('Log Program Name: '|| l_prog_name);

      hr_utility.set_location('l_prog_name Final :' || l_prog_name ,13);

		g_log_name := l_prog_name;

		hr_utility.set_location('Leaving:'||l_proc, 20);

	end;

	procedure log_message(p_procedure varchar2, p_message varchar2)
	is

		l_proc			varchar2(72) := g_package||'log_message';

	begin
		hr_utility.set_location('Entering:'||l_proc, 10);

		if g_log_enabled = FALSE then
			return;
		end if;

		-- call set_log_program_name to set g_log_name before first call
		if g_log_name is null then
			hr_utility.set_message(8301, 'GHR_38546_LOG_NAME_NOT_SET');
			hr_utility.raise_error;
		end  if;

		-- p_procedure must contain 30 or fewer characters
		if length(p_procedure) > 30 then
			hr_utility.set_message(8301, 'GHR_38547_NAME_TOO_LONG');
			hr_utility.raise_error;
		end if;
		hr_utility.set_location('g_log_name     :'||g_log_name, 11);
		hr_utility.set_location('p_procedure     :'||p_procedure, 11);

		ghr_wgi_pkg.create_ghr_errorlog(
						p_program_name  =>  g_log_name,
						p_message_name  =>  p_procedure,
						p_log_text      =>  p_message,
						p_log_date      =>  sysdate
		);

		hr_utility.set_location('Leaving:'||l_proc, 10);
	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;
	end;

	procedure who_called_me(p_name  out nocopy varchar2)
	as
		 call_stack  varchar2(4096) default dbms_utility.format_call_stack;
		 n           number;
		 found_stack BOOLEAN default FALSE;
		 line        varchar2(255);
		 cnt         number := 0;

		 l_owner		varchar2(30);
		 l_lineno	number;
		 l_caller_t	varchar2(30);

	begin

		 loop
			  n := instr( call_stack, g_new_line );
			  exit when ( cnt = 3 or n is NULL or n = 0 );

			  line := substr( call_stack, 1, n-1 );
			  call_stack := substr( call_stack, n+1 );

			  if ( NOT found_stack ) then
					if ( line like '%handle%number%name%' ) then
						 found_stack := TRUE;
					end if;
			  else
					cnt := cnt + 1;
					-- cnt = 1 is this procedure, ME
					-- cnt = 2 is MY Caller
					-- cnt = 3 is Their Caller
					if ( cnt = 3 ) then
					        -- Bug#4086677 Commented the following line.
						-- l_lineno := to_number(substr( line, 13, 6 ));
						 line   := substr( line, 21 );
						 if ( line like 'pr%' ) then
							  n := length( 'procedure ' );
						 elsif ( line like 'fun%' ) then
							  n := length( 'function ' );
						 elsif ( line like 'package body%' ) then
							  n := length( 'package body ' );
						 elsif ( line like 'pack%' ) then
							  n := length( 'package ' );
						 else
							  n := length( 'anonymous block ' );
						 end if;
						 l_caller_t := ltrim(rtrim(upper(substr( line, 1, n-1 ))));
						 line := substr( line, n );
						 n := instr( line, '.' );
						 l_owner := ltrim(rtrim(substr( line, 1, n-1 )));
						 p_name  := ltrim(rtrim(substr( line, n+1 )));
					end if;
			  end if;
		 end loop;

	end;

	procedure get_transfer_parameters(p_mass_transfer_id in number,
					p_transfer_name		out nocopy varchar2,
					p_effective_date 		out nocopy date,
					p_inter_bg_transfer	out nocopy varchar2) is

		cursor cur_eff_date is
			select effective_date, name, within_bg_transfer
			from ghr_mass_transfers
			where mass_transfer_id = p_mass_transfer_id;

		l_effdate	date;
		l_name		ghr_mass_transfers.name%type;
		l_bg_tran	ghr_mass_transfers.within_bg_transfer%type;
		l_proc			varchar2(72) := g_package||'get_transfer_parameters';

	begin

		open cur_eff_date;
		fetch cur_eff_date into l_effdate, l_name, l_bg_tran;
		close cur_eff_date;

		p_effective_date := l_effdate;
		p_transfer_name := l_name;
		p_inter_bg_transfer := l_bg_tran;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

	end get_transfer_parameters;

	procedure update_agency_transfer_from(p_person_id	number,
												  		 p_effective_date date,
														 p_value			varchar2) is

		cursor cur_pei_id is
			select  person_extra_info_id, object_version_number
			from per_people_extra_info
			where person_id = p_person_id
			and information_type = 'GHR_US_PER_GROUP1';

		l_person_extra_info_id	per_people_extra_info.person_extra_info_id%type;
		l_object_version_number per_people_extra_info.object_version_number%type;

		l_proc			varchar2(72) := g_package||'update_agency_transfer_from';

	begin

		hr_utility.set_location('Entering:'||l_proc, 10);

		open cur_pei_id;
		fetch cur_pei_id into l_person_extra_info_id, l_object_version_number;

		if cur_pei_id%notfound then	-- create info type

			ghr_person_extra_info_api.create_person_extra_info (
				 p_person_id						=> p_person_id
        ,p_effective_date                              => p_effective_date
	 ,p_information_type				=> 'GHR_US_PER_GROUP1'
				 ,p_pei_information_category	=> 'GHR_US_PER_GROUP1'
				 ,p_pei_information7				=> p_value
				 ,p_person_extra_info_id		=> l_person_extra_info_id
				 ,p_object_version_number		=> l_object_version_number
			);

		else

			ghr_person_extra_info_api.update_person_extra_info
				(p_person_extra_info_id		=> l_person_extra_info_id
				,p_object_version_number	=> l_object_version_number
				,p_effective_date				=> p_effective_date
				,p_pei_information7			=> p_value);

		end if;

		-- update_person_extra_info() invalidates the person, so we need
		-- to re-validate
--- Commented the following two lines to remove Validation functionality on Person.
--		ghr_validate_perwsepi.validate_perwsepi(p_person_id);
--		ghr_validate_perwsepi.update_person_user_type(p_person_id);

		close cur_pei_id;
		hr_utility.set_location('Leaving:'||l_proc, 10);

		exception
			when others then
				put_line(l_proc||' - raised exception');
				raise;

	end;

--
-- all insert_% procedures defined in this package are public and
-- will enforce uniqueness of transfer_name and ppf.person_id
-- by raising an error when the row already exists.
--
-- When called by mass_transfer_out the uniqueness condition does not
-- need to be checked since mass_transfer_out deletes all rows in
-- the interface table for a person_id and transfer_name which already
-- exists
--
procedure	insert_people_f(p_transfer_name		varchar2,
									 p_inter_bg_transfer	varchar2,
									 p_effective_date		date,
									 ppf 						per_all_people_f%rowtype)
is

	l_proc			varchar2(72) := g_package||'insert_people_f';
	l_table_name	constant varchar2(30) := 'PER_PEOPLE_F';

	l_owner		varchar2(30);
	l_name		varchar2(30);
	l_lineno		number;
	l_caller		varchar2(30);

begin

	put('insert people_f');

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line(' - called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> ppf.person_id
				,p_table_name			=> l_table_name) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line(' - called locally');
	end if;

	insert into ghr_mt_people_f_v (
			ghr_interface_id,
			MT_PROCESS_DATE, MT_SOURCE, MT_EFFECTIVE_DATE,
			MT_NAME, MT_STATUS, MT_PERSON_ID,
			MT_TABLE_NAME, MT_INFORMATION_TYPE,
			MT_INTER_BG_TRANSFER, PERSON_ID,
			EFFECTIVE_START_DATE, EFFECTIVE_END_DATE, BUSINESS_GROUP_ID,
			PERSON_TYPE_ID, LAST_NAME, START_DATE,
			APPLICANT_NUMBER, BACKGROUND_CHECK_STATUS, BACKGROUND_DATE_CHECK,
			BLOOD_TYPE, COMMENT_ID, CORRESPONDENCE_LANGUAGE,
			CURRENT_APPLICANT_FLAG, CURRENT_EMP_OR_APL_FLAG,
			CURRENT_EMPLOYEE_FLAG, DATE_EMPLOYEE_DATA_VERIFIED,
			DATE_OF_BIRTH, EMAIL_ADDRESS, EMPLOYEE_NUMBER,
			EXPENSE_CHECK_SEND_TO_ADDRESS, FAST_PATH_EMPLOYEE,
			FIRST_NAME, FTE_CAPACITY, FULL_NAME,
			HOLD_APPLICANT_DATE_UNTIL, HONORS, INTERNAL_LOCATION,
			KNOWN_AS, LAST_MEDICAL_TEST_BY, LAST_MEDICAL_TEST_DATE,
			MAILSTOP, MARITAL_STATUS, MIDDLE_NAMES, NATIONALITY,
			NATIONAL_IDENTIFIER, OFFICE_NUMBER, ON_MILITARY_SERVICE,
			ORDER_NAME, PRE_NAME_ADJUNCT, PREVIOUS_LAST_NAME,
			PROJECTED_START_DATE, REHIRE_AUTHORIZOR, REHIRE_RECOMMENDATION,
			RESUME_EXISTS, RESUME_LAST_UPDATED, REGISTERED_DISABLED_FLAG,
			SECOND_PASSPORT_EXISTS, SEX, STUDENT_STATUS, SUFFIX,
			TITLE, VENDOR_ID, WORK_SCHEDULE, WORK_TELEPHONE, REQUEST_ID,
			PROGRAM_APPLICATION_ID, PROGRAM_ID, PROGRAM_UPDATE_DATE,
			ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
			ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
			ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
			ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18,
			ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21, ATTRIBUTE22,
			ATTRIBUTE23, ATTRIBUTE24, ATTRIBUTE25, ATTRIBUTE26,
			ATTRIBUTE27, ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30,
			LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, CREATED_BY,
			CREATION_DATE, PER_INFORMATION_CATEGORY, PER_INFORMATION1,
			PER_INFORMATION2, PER_INFORMATION3, PER_INFORMATION4,
			PER_INFORMATION5, PER_INFORMATION6, PER_INFORMATION7,
			PER_INFORMATION8, PER_INFORMATION9, PER_INFORMATION10,
			PER_INFORMATION11, PER_INFORMATION12, PER_INFORMATION13,
			PER_INFORMATION14, PER_INFORMATION15, PER_INFORMATION16,
			PER_INFORMATION17, PER_INFORMATION18, PER_INFORMATION19,
			PER_INFORMATION20, PER_INFORMATION21, PER_INFORMATION22,
			PER_INFORMATION23, PER_INFORMATION24, PER_INFORMATION25,
			PER_INFORMATION26, PER_INFORMATION27, PER_INFORMATION28,
			PER_INFORMATION29, PER_INFORMATION30, OBJECT_VERSION_NUMBER,
			DATE_OF_DEATH, REHIRE_REASON
		)
		values (
			ghr_interface_s.nextval,
			sysdate,
			l_name,
			p_effective_date,
			p_transfer_name,
			null,								-- MT_STATUS,
			ppf.person_id,					-- MT_PERSON_ID,
			l_table_name,					-- MT_TABLE_NAME,
			null,								-- MT_INFORMATION_TYPE,
			p_inter_bg_transfer,			-- MT_INTER_BG_TRANSFER,
			ppf.PERSON_ID,
			to_char(ppf.EFFECTIVE_START_DATE,g_datefmt),
			to_char(ppf.EFFECTIVE_END_DATE,g_datefmt),
			ppf.BUSINESS_GROUP_ID,
			ppf.PERSON_TYPE_ID,
			ppf.LAST_NAME,
			to_char(ppf.START_DATE,g_datefmt),
			ppf.APPLICANT_NUMBER,
			ppf.BACKGROUND_CHECK_STATUS,
			to_char(ppf.BACKGROUND_DATE_CHECK,g_datefmt),
			ppf.BLOOD_TYPE,
			ppf.COMMENT_ID,
			ppf.CORRESPONDENCE_LANGUAGE,
			ppf.CURRENT_APPLICANT_FLAG,
			ppf.CURRENT_EMP_OR_APL_FLAG,
			ppf.CURRENT_EMPLOYEE_FLAG,
			to_char(ppf.DATE_EMPLOYEE_DATA_VERIFIED,g_datefmt),
			to_char(ppf.DATE_OF_BIRTH,g_datefmt),
			ppf.EMAIL_ADDRESS,
			ppf.EMPLOYEE_NUMBER,
			ppf.EXPENSE_CHECK_SEND_TO_ADDRESS,
			ppf.FAST_PATH_EMPLOYEE,
			ppf.FIRST_NAME,
			ppf.FTE_CAPACITY,
			ppf.FULL_NAME,
			to_char(ppf.HOLD_APPLICANT_DATE_UNTIL,g_datefmt),
			ppf.HONORS,
			ppf.INTERNAL_LOCATION,
			ppf.KNOWN_AS,
			ppf.LAST_MEDICAL_TEST_BY,
			to_char(ppf.LAST_MEDICAL_TEST_DATE,g_datefmt),
			ppf.MAILSTOP,
			ppf.MARITAL_STATUS,
			ppf.MIDDLE_NAMES,
			ppf.NATIONALITY,
			ppf.NATIONAL_IDENTIFIER,
			ppf.OFFICE_NUMBER,
			ppf.ON_MILITARY_SERVICE,
			ppf.ORDER_NAME,
			ppf.PRE_NAME_ADJUNCT,
			ppf.PREVIOUS_LAST_NAME,
			to_char(ppf.PROJECTED_START_DATE,g_datefmt),
			ppf.REHIRE_AUTHORIZOR,
			ppf.REHIRE_RECOMMENDATION,
			ppf.RESUME_EXISTS,
			to_char(ppf.RESUME_LAST_UPDATED,g_datefmt),
			ppf.REGISTERED_DISABLED_FLAG,
			ppf.SECOND_PASSPORT_EXISTS,
			ppf.SEX,
			ppf.STUDENT_STATUS,
			ppf.SUFFIX,
			ppf.TITLE,
			ppf.VENDOR_ID,
			ppf.WORK_SCHEDULE,
			ppf.WORK_TELEPHONE,
			ppf.REQUEST_ID,
			ppf.PROGRAM_APPLICATION_ID,
			ppf.PROGRAM_ID,
			to_char(ppf.PROGRAM_UPDATE_DATE,g_datefmt),
			ppf.ATTRIBUTE_CATEGORY,
			ppf.ATTRIBUTE1,
			ppf.ATTRIBUTE2,
			ppf.ATTRIBUTE3,
			ppf.ATTRIBUTE4,
			ppf.ATTRIBUTE5,
			ppf.ATTRIBUTE6,
			ppf.ATTRIBUTE7,
			ppf.ATTRIBUTE8,
			ppf.ATTRIBUTE9,
			ppf.ATTRIBUTE10,
			ppf.ATTRIBUTE11,
			ppf.ATTRIBUTE12,
			ppf.ATTRIBUTE13,
			ppf.ATTRIBUTE14,
			ppf.ATTRIBUTE15,
			ppf.ATTRIBUTE16,
			ppf.ATTRIBUTE17,
			ppf.ATTRIBUTE18,
			ppf.ATTRIBUTE19,
			ppf.ATTRIBUTE20,
			ppf.ATTRIBUTE21,
			ppf.ATTRIBUTE22,
			ppf.ATTRIBUTE23,
			ppf.ATTRIBUTE24,
			ppf.ATTRIBUTE25,
			ppf.ATTRIBUTE26,
			ppf.ATTRIBUTE27,
			ppf.ATTRIBUTE28,
			ppf.ATTRIBUTE29,
			ppf.ATTRIBUTE30,
			to_char(ppf.LAST_UPDATE_DATE,g_datefmt),
			ppf.LAST_UPDATED_BY,
			ppf.LAST_UPDATE_LOGIN,
			ppf.CREATED_BY,
			to_char(ppf.CREATION_DATE,g_datefmt),
			ppf.PER_INFORMATION_CATEGORY,
			ppf.PER_INFORMATION1,
			ppf.PER_INFORMATION2,
			ppf.PER_INFORMATION3,
			ppf.PER_INFORMATION4,
			ppf.PER_INFORMATION5,
			ppf.PER_INFORMATION6,
			ppf.PER_INFORMATION7,
			ppf.PER_INFORMATION8,
			ppf.PER_INFORMATION9,
			ppf.PER_INFORMATION10,
			ppf.PER_INFORMATION11,
			ppf.PER_INFORMATION12,
			ppf.PER_INFORMATION13,
			ppf.PER_INFORMATION14,
			ppf.PER_INFORMATION15,
			ppf.PER_INFORMATION16,
			ppf.PER_INFORMATION17,
			ppf.PER_INFORMATION18,
			ppf.PER_INFORMATION19,
			ppf.PER_INFORMATION20,
			ppf.PER_INFORMATION21,
			ppf.PER_INFORMATION22,
			ppf.PER_INFORMATION23,
			ppf.PER_INFORMATION24,
			ppf.PER_INFORMATION25,
			ppf.PER_INFORMATION26,
			ppf.PER_INFORMATION27,
			ppf.PER_INFORMATION28,
			ppf.PER_INFORMATION29,
			ppf.PER_INFORMATION30,
			ppf.OBJECT_VERSION_NUMBER,
			to_char(ppf.DATE_OF_DEATH,g_datefmt),
			ppf.REHIRE_REASON
		);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure update_people_f(p_transfer_name			varchar2,
								  p_inter_bg_transfer	varchar2,
								  p_effective_date		date,
								  ppf 						per_all_people_f%rowtype)
is

	l_proc			varchar2(72) := g_package||'update_people_f';
	l_table_name	constant varchar2(30) := 'PER_PEOPLE_F';
	l_name			varchar2(30);
	l_x				varchar2(1);

	cursor cur_get_person is
		select 'x'
		from ghr_mt_people_f_v
		where mt_name = p_transfer_name
		and mt_person_id = to_char(ppf.person_id)
		for update;

begin

	put_line('update people_f');

	open cur_get_person;
  	fetch cur_get_person into l_x;

	if cur_get_person%notfound then
		close cur_get_person;
		hr_utility.set_message(8301, 'GHR_38549_UPDATE_NOT_FOUND');
		hr_utility.raise_error;
	end if;

	update ghr_mt_people_f_v
		set
			MT_EFFECTIVE_DATE = p_effective_date,
			MT_INTER_BG_TRANSFER = p_inter_bg_transfer,
			BUSINESS_GROUP_ID = nvl(ppf.BUSINESS_GROUP_ID,BUSINESS_GROUP_ID),
			PERSON_TYPE_ID = nvl(ppf.PERSON_TYPE_ID,PERSON_TYPE_ID),
			LAST_NAME = nvl(ppf.LAST_NAME, LAST_NAME),
			START_DATE = nvl(to_char(ppf.START_DATE,g_datefmt),START_DATE),
			APPLICANT_NUMBER = nvl(ppf.APPLICANT_NUMBER, APPLICANT_NUMBER),
			BACKGROUND_CHECK_STATUS =
					nvl(ppf.BACKGROUND_CHECK_STATUS, BACKGROUND_CHECK_STATUS),
			BACKGROUND_DATE_CHECK =
					nvl(to_char(ppf.BACKGROUND_DATE_CHECK,g_datefmt),
					BACKGROUND_DATE_CHECK),
			BLOOD_TYPE = nvl(ppf.BLOOD_TYPE, BLOOD_TYPE),
			COMMENT_ID = nvl(ppf.COMMENT_ID, COMMENT_ID),
			CORRESPONDENCE_LANGUAGE =
					nvl(ppf.CORRESPONDENCE_LANGUAGE,CORRESPONDENCE_LANGUAGE),
			CURRENT_APPLICANT_FLAG =
					nvl(ppf.CURRENT_APPLICANT_FLAG, CURRENT_APPLICANT_FLAG),
			CURRENT_EMP_OR_APL_FLAG =
					nvl(ppf.CURRENT_EMP_OR_APL_FLAG,CURRENT_EMP_OR_APL_FLAG),
			CURRENT_EMPLOYEE_FLAG =
					nvl(ppf.CURRENT_EMPLOYEE_FLAG, CURRENT_EMPLOYEE_FLAG),
			DATE_EMPLOYEE_DATA_VERIFIED =
					nvl(to_char(ppf.DATE_EMPLOYEE_DATA_VERIFIED,g_datefmt),
					DATE_EMPLOYEE_DATA_VERIFIED),
			DATE_OF_BIRTH =
					nvl(to_char(ppf.DATE_OF_BIRTH,g_datefmt), DATE_OF_BIRTH),
			EMAIL_ADDRESS = nvl(ppf.EMAIL_ADDRESS, EMAIL_ADDRESS),
			EMPLOYEE_NUMBER = nvl(ppf.EMPLOYEE_NUMBER,EMPLOYEE_NUMBER),
			EXPENSE_CHECK_SEND_TO_ADDRESS =
					nvl(ppf.EXPENSE_CHECK_SEND_TO_ADDRESS,
						EXPENSE_CHECK_SEND_TO_ADDRESS),
			FAST_PATH_EMPLOYEE = nvl(ppf.FAST_PATH_EMPLOYEE,FAST_PATH_EMPLOYEE),
			FIRST_NAME = nvl(ppf.FIRST_NAME, FIRST_NAME),
			FTE_CAPACITY = nvl(ppf.FTE_CAPACITY, FTE_CAPACITY),
			FULL_NAME = nvl(ppf.FULL_NAME,FULL_NAME),
			HOLD_APPLICANT_DATE_UNTIL =
					nvl(to_char(ppf.HOLD_APPLICANT_DATE_UNTIL,g_datefmt),
					HOLD_APPLICANT_DATE_UNTIL),
			HONORS = nvl(ppf.HONORS, HONORS),
			INTERNAL_LOCATION = nvl(ppf.INTERNAL_LOCATION,INTERNAL_LOCATION),
			KNOWN_AS = nvl(ppf.KNOWN_AS, KNOWN_AS),
			LAST_MEDICAL_TEST_BY =
					nvl(ppf.LAST_MEDICAL_TEST_BY, LAST_MEDICAL_TEST_BY),
			LAST_MEDICAL_TEST_DATE =
					nvl(to_char(ppf.LAST_MEDICAL_TEST_DATE,g_datefmt),
					LAST_MEDICAL_TEST_DATE),
			MAILSTOP = nvl(ppf.MAILSTOP, MAILSTOP),
			MARITAL_STATUS = nvl(ppf.MARITAL_STATUS, MARITAL_STATUS),
			MIDDLE_NAMES = nvl(ppf.MIDDLE_NAMES, MIDDLE_NAMES),
			NATIONALITY = nvl(ppf.NATIONALITY,NATIONALITY),
			NATIONAL_IDENTIFIER =
					nvl(ppf.NATIONAL_IDENTIFIER, NATIONAL_IDENTIFIER),
			OFFICE_NUMBER = nvl(ppf.OFFICE_NUMBER, OFFICE_NUMBER),
			ON_MILITARY_SERVICE = nvl(ppf.ON_MILITARY_SERVICE,ON_MILITARY_SERVICE),
			ORDER_NAME = nvl(ppf.ORDER_NAME, ORDER_NAME),
			PRE_NAME_ADJUNCT = nvl(ppf.PRE_NAME_ADJUNCT, PRE_NAME_ADJUNCT),
			PREVIOUS_LAST_NAME = nvl(ppf.PREVIOUS_LAST_NAME,PREVIOUS_LAST_NAME),
			PROJECTED_START_DATE =
					nvl(to_char(ppf.PROJECTED_START_DATE,g_datefmt),
					PROJECTED_START_DATE),
			REHIRE_AUTHORIZOR = nvl(ppf.REHIRE_AUTHORIZOR, REHIRE_AUTHORIZOR),
			REHIRE_RECOMMENDATION =
					nvl(ppf.REHIRE_RECOMMENDATION,REHIRE_RECOMMENDATION),
			RESUME_EXISTS = nvl(ppf.RESUME_EXISTS, RESUME_EXISTS),
			RESUME_LAST_UPDATED =
					nvl(to_char(ppf.RESUME_LAST_UPDATED,g_datefmt),
					RESUME_LAST_UPDATED),
			REGISTERED_DISABLED_FLAG =
					nvl(ppf.REGISTERED_DISABLED_FLAG,REGISTERED_DISABLED_FLAG),
			SECOND_PASSPORT_EXISTS =
					nvl(ppf.SECOND_PASSPORT_EXISTS, SECOND_PASSPORT_EXISTS),
			SEX = nvl(ppf.SEX, SEX),
			STUDENT_STATUS = nvl(ppf.STUDENT_STATUS, STUDENT_STATUS),
			SUFFIX = nvl(ppf.SUFFIX,SUFFIX),
			TITLE = nvl(ppf.TITLE, TITLE),
			VENDOR_ID = nvl(ppf.VENDOR_ID, VENDOR_ID),
			WORK_SCHEDULE = nvl(ppf.WORK_SCHEDULE, WORK_SCHEDULE),
			WORK_TELEPHONE = nvl(ppf.WORK_TELEPHONE,WORK_TELEPHONE),
			REQUEST_ID = nvl(ppf.REQUEST_ID,REQUEST_ID),
			PROGRAM_APPLICATION_ID =
					nvl(ppf.PROGRAM_APPLICATION_ID,PROGRAM_APPLICATION_ID),
			PROGRAM_ID = nvl(ppf.PROGRAM_ID,PROGRAM_ID),
			ATTRIBUTE_CATEGORY = nvl(ppf.ATTRIBUTE_CATEGORY,ATTRIBUTE_CATEGORY),
			ATTRIBUTE1 = nvl(ppf.ATTRIBUTE1,ATTRIBUTE1),
			ATTRIBUTE2 = nvl(ppf.ATTRIBUTE2,ATTRIBUTE2),
			ATTRIBUTE3 = nvl(ppf.ATTRIBUTE3,ATTRIBUTE3),
			ATTRIBUTE4 = nvl(ppf.ATTRIBUTE4,ATTRIBUTE4),
			ATTRIBUTE5 = nvl(ppf.ATTRIBUTE5,ATTRIBUTE5),
			ATTRIBUTE6 = nvl(ppf.ATTRIBUTE6,ATTRIBUTE6),
			ATTRIBUTE7 = nvl(ppf.ATTRIBUTE7,ATTRIBUTE7),
			ATTRIBUTE8 = nvl(ppf.ATTRIBUTE8,ATTRIBUTE8),
			ATTRIBUTE9 = nvl(ppf.ATTRIBUTE9,ATTRIBUTE9),
			ATTRIBUTE10 = nvl(ppf.ATTRIBUTE10,ATTRIBUTE10),
			ATTRIBUTE11 = nvl(ppf.ATTRIBUTE11,ATTRIBUTE11),
			ATTRIBUTE12 = nvl(ppf.ATTRIBUTE12,ATTRIBUTE12),
			ATTRIBUTE13 = nvl(ppf.ATTRIBUTE13,ATTRIBUTE13),
			ATTRIBUTE14 = nvl(ppf.ATTRIBUTE14,ATTRIBUTE14),
			ATTRIBUTE15 = nvl(ppf.ATTRIBUTE15,ATTRIBUTE15),
			ATTRIBUTE16 = nvl(ppf.ATTRIBUTE16,ATTRIBUTE16),
			ATTRIBUTE17 = nvl(ppf.ATTRIBUTE17,ATTRIBUTE17),
			ATTRIBUTE18 = nvl(ppf.ATTRIBUTE18,ATTRIBUTE18),
			ATTRIBUTE19 = nvl(ppf.ATTRIBUTE19,ATTRIBUTE19),
			ATTRIBUTE20 = nvl(ppf.ATTRIBUTE20,ATTRIBUTE20),
			ATTRIBUTE21 = nvl(ppf.ATTRIBUTE21,ATTRIBUTE21),
			ATTRIBUTE22 = nvl(ppf.ATTRIBUTE22,ATTRIBUTE22),
			ATTRIBUTE23 = nvl(ppf.ATTRIBUTE23,ATTRIBUTE23),
			ATTRIBUTE24 = nvl(ppf.ATTRIBUTE24,ATTRIBUTE24),
			ATTRIBUTE25 = nvl(ppf.ATTRIBUTE25,ATTRIBUTE25),
			ATTRIBUTE26 = nvl(ppf.ATTRIBUTE26,ATTRIBUTE26),
			ATTRIBUTE27 = nvl(ppf.ATTRIBUTE27,ATTRIBUTE27),
			ATTRIBUTE28 = nvl(ppf.ATTRIBUTE28,ATTRIBUTE28),
			ATTRIBUTE29 = nvl(ppf.ATTRIBUTE29,ATTRIBUTE29),
			ATTRIBUTE30 = nvl(ppf.ATTRIBUTE30,ATTRIBUTE30),
			PER_INFORMATION_CATEGORY =
					nvl(ppf.PER_INFORMATION_CATEGORY,PER_INFORMATION_CATEGORY),
			PER_INFORMATION1 = nvl(ppf.PER_INFORMATION1,PER_INFORMATION1),
			PER_INFORMATION2 = nvl(ppf.PER_INFORMATION2,PER_INFORMATION2),
			PER_INFORMATION3 = nvl(ppf.PER_INFORMATION3,PER_INFORMATION3),
			PER_INFORMATION4 = nvl(ppf.PER_INFORMATION4,PER_INFORMATION4),
			PER_INFORMATION5 = nvl(ppf.PER_INFORMATION5,PER_INFORMATION5),
			PER_INFORMATION6 = nvl(ppf.PER_INFORMATION6,PER_INFORMATION6),
			PER_INFORMATION7 = nvl(ppf.PER_INFORMATION7,PER_INFORMATION7),
			PER_INFORMATION8 = nvl(ppf.PER_INFORMATION8,PER_INFORMATION8),
			PER_INFORMATION9 = nvl(ppf.PER_INFORMATION9,PER_INFORMATION9),
			PER_INFORMATION10 = nvl(ppf.PER_INFORMATION10,PER_INFORMATION10),
			PER_INFORMATION11 = nvl(ppf.PER_INFORMATION11,PER_INFORMATION11),
			PER_INFORMATION12 = nvl(ppf.PER_INFORMATION12,PER_INFORMATION12),
			PER_INFORMATION13 = nvl(ppf.PER_INFORMATION13,PER_INFORMATION13),
			PER_INFORMATION14 = nvl(ppf.PER_INFORMATION14,PER_INFORMATION14),
			PER_INFORMATION15 = nvl(ppf.PER_INFORMATION15,PER_INFORMATION15),
			PER_INFORMATION16 = nvl(ppf.PER_INFORMATION16,PER_INFORMATION16),
			PER_INFORMATION17 = nvl(ppf.PER_INFORMATION17,PER_INFORMATION17),
			PER_INFORMATION18 = nvl(ppf.PER_INFORMATION18,PER_INFORMATION18),
			PER_INFORMATION19 = nvl(ppf.PER_INFORMATION19,PER_INFORMATION19),
			PER_INFORMATION20 = nvl(ppf.PER_INFORMATION20,PER_INFORMATION20),
			PER_INFORMATION21 = nvl(ppf.PER_INFORMATION21,PER_INFORMATION21),
			PER_INFORMATION22 = nvl(ppf.PER_INFORMATION22,PER_INFORMATION22),
			PER_INFORMATION23 = nvl(ppf.PER_INFORMATION23,PER_INFORMATION23),
			PER_INFORMATION24 = nvl(ppf.PER_INFORMATION24,PER_INFORMATION24),
			PER_INFORMATION25 = nvl(ppf.PER_INFORMATION25,PER_INFORMATION25),
			PER_INFORMATION26 = nvl(ppf.PER_INFORMATION26,PER_INFORMATION26),
			PER_INFORMATION27 = nvl(ppf.PER_INFORMATION27,PER_INFORMATION27),
			PER_INFORMATION28 = nvl(ppf.PER_INFORMATION28,PER_INFORMATION28),
			PER_INFORMATION29 = nvl(ppf.PER_INFORMATION29,PER_INFORMATION29),
			PER_INFORMATION30 = nvl(ppf.PER_INFORMATION30,PER_INFORMATION30),
			DATE_OF_DEATH = nvl(to_char(ppf.DATE_OF_DEATH,g_datefmt),
					DATE_OF_DEATH),
			REHIRE_REASON = nvl(ppf.REHIRE_REASON,REHIRE_REASON)
		where current of cur_get_person;

	close cur_get_person;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

function get_code_meaning(p_lookup_type		varchar2,
								  p_lookup_code		varchar2)
return varchar2 is

	l_proc			varchar2(72) := g_package||'get_code_meaning';
	l_description	hr_lookups.description%type := null;

begin

	if p_lookup_code is null then
		return null;
	end if;

	if p_lookup_type = 'GHR_US_LEGAL_AUTHORITY' then
		l_description := ghr_pa_requests_pkg.get_lookup_description (
				p_application_id		=> 800,
				p_lookup_type			=> p_lookup_type,
				p_lookup_code			=> p_lookup_code);
	else
		l_description := ghr_pa_requests_pkg.get_lookup_meaning (
				p_application_id		=> 800,
				p_lookup_type			=> p_lookup_type,
				p_lookup_code			=> p_lookup_code);
	end if;

	return l_description;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure insert_people_ei(p_transfer_name varchar2,
									  p_effective_date date,
									  pp_ei per_people_extra_info%rowtype)
is

	l_info3_meaning	varchar2(80) := null;
	l_info4_meaning	varchar2(80) := null;
	l_info5_meaning	varchar2(80) := null;
	l_info6_meaning	varchar2(80) := null;
	l_info7_meaning	varchar2(80) := null;
	l_info8_meaning	varchar2(80) := null;
	l_info9_meaning	varchar2(80) := null;
	l_info10_meaning	varchar2(80) := null;
	l_info11_meaning	varchar2(80) := null;

	l_proc			varchar2(72) := g_package||'insert_people_ei';
	l_table_name	constant varchar2(30) := 'PER_PEOPLE_EXTRA_INFO';
	l_name			varchar2(30);

begin

	put('insert people_ei');

	-- check if pp_ei contains data, if not return
	if pp_ei.information_type is null then
		put_line(' - no data');
		return;
	end if;
	put_line(' - ok, info_type: '||pp_ei.information_type);

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line('Called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> pp_ei.person_id
				,p_table_name			=> l_table_name
				,p_info_type			=> pp_ei.information_type) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line('Called locally');
	end if;

	if pp_ei.information_type = 'GHR_US_PER_SF52' then
		l_info3_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_CITIZENSHIP',
									p_lookup_code	=>	pp_ei.pei_information3);

		l_info4_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_VETERANS_PREF',
									p_lookup_code	=>	pp_ei.pei_information4);

		l_info5_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_VETERANS_PREF_FOR_RIF',
									p_lookup_code	=>	pp_ei.pei_information5);

		l_info6_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_VET_STATUS',
									p_lookup_code	=>	pp_ei.pei_information6);

	elsif pp_ei.information_type = 'GHR_US_PER_GROUP1' then
		l_info3_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_APPOINTMENT_TYPE',
									p_lookup_code	=>	pp_ei.pei_information3);

		l_info4_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_TYPE_EMPLOYMENT',
									p_lookup_code	=>	pp_ei.pei_information4);

		l_info5_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_RACE_NATIONAL_ORIGIN',
									p_lookup_code	=>	pp_ei.pei_information5);

		l_info7_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_AGENCY_CODE',
									p_lookup_code	=>	pp_ei.pei_information7);

		l_info8_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_LEGAL_AUTHORITY',
									p_lookup_code	=>	pp_ei.pei_information8);

		l_info9_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_LEGAL_AUTHORITY',
									p_lookup_code	=>	pp_ei.pei_information9);

		l_info11_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_HANDICAP_CODE',
									p_lookup_code	=>	pp_ei.pei_information11);

	elsif pp_ei.information_type = 'GHR_US_PER_SEPARATE_RETIRE' then
		l_info3_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_FERS_COVERAGE',
									p_lookup_code	=>	pp_ei.pei_information3);

		l_info4_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_PREV_RETIRE_COVER',
									p_lookup_code	=>	pp_ei.pei_information4);

	elsif pp_ei.information_type = 'GHR_US_PER_UNIFORMED_SERVICES' then
		l_info5_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_CREDIT_MIL_SVC',
									p_lookup_code	=>	pp_ei.pei_information5);

	end if;

	insert into ghr_mt_people_ei_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		PERSON_EXTRA_INFO_ID,
		PERSON_ID,
		INFORMATION_TYPE,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		PEI_ATTRIBUTE_CATEGORY,
		PEI_ATTRIBUTE1,
		PEI_ATTRIBUTE2,
		PEI_ATTRIBUTE3,
		PEI_ATTRIBUTE4,
		PEI_ATTRIBUTE5,
		PEI_ATTRIBUTE6,
		PEI_ATTRIBUTE7,
		PEI_ATTRIBUTE8,
		PEI_ATTRIBUTE9,
		PEI_ATTRIBUTE10,
		PEI_ATTRIBUTE11,
		PEI_ATTRIBUTE12,
		PEI_ATTRIBUTE13,
		PEI_ATTRIBUTE14,
		PEI_ATTRIBUTE15,
		PEI_ATTRIBUTE16,
		PEI_ATTRIBUTE17,
		PEI_ATTRIBUTE18,
		PEI_ATTRIBUTE19,
		PEI_ATTRIBUTE20,
		PEI_INFORMATION_CATEGORY,
		PEI_INFORMATION1,
		PEI_INFORMATION2,
		PEI_INFORMATION3,
		PEI_INFORMATION4,
		PEI_INFORMATION5,
		PEI_INFORMATION6,
		PEI_INFORMATION7,
		PEI_INFORMATION8,
		PEI_INFORMATION9,
		PEI_INFORMATION10,
		PEI_INFORMATION11,
		PEI_INFORMATION12,
		PEI_INFORMATION13,
		PEI_INFORMATION14,
		PEI_INFORMATION15,
		PEI_INFORMATION16,
		PEI_INFORMATION17,
		PEI_INFORMATION18,
		PEI_INFORMATION19,
		PEI_INFORMATION20,
		PEI_INFORMATION21,
		PEI_INFORMATION22,
		PEI_INFORMATION23,
		PEI_INFORMATION24,
		PEI_INFORMATION25,
		PEI_INFORMATION26,
		PEI_INFORMATION27,
		PEI_INFORMATION28,
		PEI_INFORMATION29,
		PEI_INFORMATION30,
		OBJECT_VERSION_NUMBER,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATION_DATE,
		info3_meaning,
		info4_meaning,
		info5_meaning,
		info6_meaning,
		info7_meaning,
		info8_meaning,
		info9_meaning,
		info10_meaning,
		info11_meaning
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,								-- MT_STATUS,
		pp_ei.person_id,				-- MT_PERSON_ID,
		l_table_name,					-- MT_TABLE_NAME,
		pp_ei.information_type,		-- MT_INFORMATION_TYPE,
		null,
		pp_ei.PERSON_EXTRA_INFO_ID,
		pp_ei.PERSON_ID,
		pp_ei.INFORMATION_TYPE,
		pp_ei.REQUEST_ID,
		pp_ei.PROGRAM_APPLICATION_ID,
		pp_ei.PROGRAM_ID,
		to_char(pp_ei.PROGRAM_UPDATE_DATE,g_datefmt),
		pp_ei.PEI_ATTRIBUTE_CATEGORY,
		pp_ei.PEI_ATTRIBUTE1,
		pp_ei.PEI_ATTRIBUTE2,
		pp_ei.PEI_ATTRIBUTE3,
		pp_ei.PEI_ATTRIBUTE4,
		pp_ei.PEI_ATTRIBUTE5,
		pp_ei.PEI_ATTRIBUTE6,
		pp_ei.PEI_ATTRIBUTE7,
		pp_ei.PEI_ATTRIBUTE8,
		pp_ei.PEI_ATTRIBUTE9,
		pp_ei.PEI_ATTRIBUTE10,
		pp_ei.PEI_ATTRIBUTE11,
		pp_ei.PEI_ATTRIBUTE12,
		pp_ei.PEI_ATTRIBUTE13,
		pp_ei.PEI_ATTRIBUTE14,
		pp_ei.PEI_ATTRIBUTE15,
		pp_ei.PEI_ATTRIBUTE16,
		pp_ei.PEI_ATTRIBUTE17,
		pp_ei.PEI_ATTRIBUTE18,
		pp_ei.PEI_ATTRIBUTE19,
		pp_ei.PEI_ATTRIBUTE20,
		pp_ei.PEI_INFORMATION_CATEGORY,
		pp_ei.PEI_INFORMATION1,
		pp_ei.PEI_INFORMATION2,
		pp_ei.PEI_INFORMATION3,
		pp_ei.PEI_INFORMATION4,
		pp_ei.PEI_INFORMATION5,
		pp_ei.PEI_INFORMATION6,
		pp_ei.PEI_INFORMATION7,
		pp_ei.PEI_INFORMATION8,
		pp_ei.PEI_INFORMATION9,
		pp_ei.PEI_INFORMATION10,
		pp_ei.PEI_INFORMATION11,
		pp_ei.PEI_INFORMATION12,
		pp_ei.PEI_INFORMATION13,
		pp_ei.PEI_INFORMATION14,
		pp_ei.PEI_INFORMATION15,
		pp_ei.PEI_INFORMATION16,
		pp_ei.PEI_INFORMATION17,
		pp_ei.PEI_INFORMATION18,
		pp_ei.PEI_INFORMATION19,
		pp_ei.PEI_INFORMATION20,
		pp_ei.PEI_INFORMATION21,
		pp_ei.PEI_INFORMATION22,
		pp_ei.PEI_INFORMATION23,
		pp_ei.PEI_INFORMATION24,
		pp_ei.PEI_INFORMATION25,
		pp_ei.PEI_INFORMATION26,
		pp_ei.PEI_INFORMATION27,
		pp_ei.PEI_INFORMATION28,
		pp_ei.PEI_INFORMATION29,
		pp_ei.PEI_INFORMATION30,
		pp_ei.OBJECT_VERSION_NUMBER,
		to_char(pp_ei.LAST_UPDATE_DATE,g_datefmt),
		pp_ei.LAST_UPDATED_BY,
		pp_ei.LAST_UPDATE_LOGIN,
		pp_ei.CREATED_BY,
		to_char(pp_ei.CREATION_DATE,g_datefmt),
		l_info3_meaning,
		l_info4_meaning,
		l_info5_meaning,
		l_info6_meaning,
		l_info7_meaning,
		l_info8_meaning,
		l_info9_meaning,
		l_info10_meaning,
		l_info11_meaning
	);

exception
	when others then
		put_line(l_proc||' - raised exception');
		raise;
end;

procedure update_people_ei(p_transfer_name varchar2,
									  p_effective_date date,
									  pp_ei per_people_extra_info%rowtype)
is

	l_info3_meaning	varchar2(80) := null;
	l_info4_meaning	varchar2(80) := null;
	l_info5_meaning	varchar2(80) := null;
	l_info6_meaning	varchar2(80) := null;
	l_info7_meaning	varchar2(80) := null;
	l_info8_meaning	varchar2(80) := null;
	l_info9_meaning	varchar2(80) := null;
	l_info10_meaning	varchar2(80) := null;
	l_info11_meaning	varchar2(80) := null;

	l_proc			varchar2(72) := g_package||'update_people_ei';
	l_x				varchar2(1);

	cursor cur_get_person_ei is
		select 'x'	-- mt_person_id
		from ghr_mt_people_ei_v
		where mt_name = p_transfer_name
		and mt_person_id = to_char(pp_ei.person_id)
		and mt_information_type = pp_ei.information_type
		for update;

begin

	put_line('update_people_ei');

	open cur_get_person_ei;
	fetch cur_get_person_ei into l_x;

	-- if select fails to return a row then call insert
	if cur_get_person_ei%notfound then

		put_line('update row not found - calling insert');
		close cur_get_person_ei;

		insert_people_ei(
				  p_transfer_name 		=> p_transfer_name,
				  p_effective_date 		=> p_effective_date,
				  pp_ei 						=> pp_ei
		);

		return;

	end if;

	if pp_ei.information_type = 'GHR_US_PER_SF52' then
		l_info3_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_CITIZENSHIP',
									p_lookup_code	=>	pp_ei.pei_information3);

		l_info4_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_VETERANS_PREF',
									p_lookup_code	=>	pp_ei.pei_information4);

		l_info5_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_VETERANS_PREF_FOR_RIF',
									p_lookup_code	=>	pp_ei.pei_information5);

		l_info6_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_VET_STATUS',
									p_lookup_code	=>	pp_ei.pei_information6);

	elsif pp_ei.information_type = 'GHR_US_PER_GROUP1' then
		l_info3_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_APPOINTMENT_TYPE',
									p_lookup_code	=>	pp_ei.pei_information3);

		l_info4_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_TYPE_EMPLOYMENT',
									p_lookup_code	=>	pp_ei.pei_information4);

		l_info5_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_RACE_NATIONAL_ORIGIN',
									p_lookup_code	=>	pp_ei.pei_information5);

		l_info7_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_AGENCY_CODE',
									p_lookup_code	=>	pp_ei.pei_information7);

		l_info8_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_LEGAL_AUTHORITY',
									p_lookup_code	=>	pp_ei.pei_information8);

		l_info9_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_LEGAL_AUTHORITY',
									p_lookup_code	=>	pp_ei.pei_information9);

		l_info11_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_HANDICAP_CODE',
									p_lookup_code	=>	pp_ei.pei_information11);

	elsif pp_ei.information_type = 'GHR_US_PER_SEPARATE_RETIRE' then
		l_info3_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_FERS_COVERAGE',
									p_lookup_code	=>	pp_ei.pei_information3);

		l_info4_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_PREV_RETIRE_COVER',
									p_lookup_code	=>	pp_ei.pei_information4);

	elsif pp_ei.information_type = 'GHR_US_PER_UNIFORMED_SERVICES' then
		l_info5_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_CREDIT_MIL_SVC',
									p_lookup_code	=>	pp_ei.pei_information5);

	end if;

	update ghr_mt_people_ei_v
	set
		MT_EFFECTIVE_DATE = nvl(p_EFFECTIVE_DATE,MT_EFFECTIVE_DATE),
		PERSON_EXTRA_INFO_ID =
				nvl(pp_ei.PERSON_EXTRA_INFO_ID,PERSON_EXTRA_INFO_ID),
		INFORMATION_TYPE = nvl(pp_ei.INFORMATION_TYPE,INFORMATION_TYPE),
		REQUEST_ID = nvl(pp_ei.REQUEST_ID,REQUEST_ID),
		PROGRAM_APPLICATION_ID =
				nvl(pp_ei.PROGRAM_APPLICATION_ID,PROGRAM_APPLICATION_ID),
		PROGRAM_ID = nvl(pp_ei.PROGRAM_ID,PROGRAM_ID),
		PROGRAM_UPDATE_DATE =
				nvl(to_char(pp_ei.PROGRAM_UPDATE_DATE,g_datefmt),
				PROGRAM_UPDATE_DATE),
		PEI_ATTRIBUTE_CATEGORY =
				nvl(pp_ei.PEI_ATTRIBUTE_CATEGORY,PEI_ATTRIBUTE_CATEGORY),
		PEI_ATTRIBUTE1 = nvl(pp_ei.PEI_ATTRIBUTE1,PEI_ATTRIBUTE1),
		PEI_ATTRIBUTE2 = nvl(pp_ei.PEI_ATTRIBUTE2,PEI_ATTRIBUTE2),
		PEI_ATTRIBUTE3 = nvl(pp_ei.PEI_ATTRIBUTE3,PEI_ATTRIBUTE3),
		PEI_ATTRIBUTE4 = nvl(pp_ei.PEI_ATTRIBUTE4,PEI_ATTRIBUTE4),
		PEI_ATTRIBUTE5 = nvl(pp_ei.PEI_ATTRIBUTE5,PEI_ATTRIBUTE5),
		PEI_ATTRIBUTE6 = nvl(pp_ei.PEI_ATTRIBUTE6,PEI_ATTRIBUTE6),
		PEI_ATTRIBUTE7 = nvl(pp_ei.PEI_ATTRIBUTE7,PEI_ATTRIBUTE7),
		PEI_ATTRIBUTE8 = nvl(pp_ei.PEI_ATTRIBUTE8,PEI_ATTRIBUTE8),
		PEI_ATTRIBUTE9 = nvl(pp_ei.PEI_ATTRIBUTE9,PEI_ATTRIBUTE9),
		PEI_ATTRIBUTE10 = nvl(pp_ei.PEI_ATTRIBUTE10,PEI_ATTRIBUTE10),
		PEI_ATTRIBUTE11 = nvl(pp_ei.PEI_ATTRIBUTE11,PEI_ATTRIBUTE11),
		PEI_ATTRIBUTE12 = nvl(pp_ei.PEI_ATTRIBUTE12,PEI_ATTRIBUTE12),
		PEI_ATTRIBUTE13 = nvl(pp_ei.PEI_ATTRIBUTE13,PEI_ATTRIBUTE13),
		PEI_ATTRIBUTE14 = nvl(pp_ei.PEI_ATTRIBUTE14,PEI_ATTRIBUTE14),
		PEI_ATTRIBUTE15 = nvl(pp_ei.PEI_ATTRIBUTE15,PEI_ATTRIBUTE15),
		PEI_ATTRIBUTE16 = nvl(pp_ei.PEI_ATTRIBUTE16,PEI_ATTRIBUTE16),
		PEI_ATTRIBUTE17 = nvl(pp_ei.PEI_ATTRIBUTE17,PEI_ATTRIBUTE17),
		PEI_ATTRIBUTE18 = nvl(pp_ei.PEI_ATTRIBUTE18,PEI_ATTRIBUTE18),
		PEI_ATTRIBUTE19 = nvl(pp_ei.PEI_ATTRIBUTE19,PEI_ATTRIBUTE19),
		PEI_ATTRIBUTE20 = nvl(pp_ei.PEI_ATTRIBUTE20,PEI_ATTRIBUTE20),
		PEI_INFORMATION_CATEGORY =
				nvl(pp_ei.PEI_INFORMATION_CATEGORY,PEI_INFORMATION_CATEGORY),
		PEI_INFORMATION1 = nvl(pp_ei.PEI_INFORMATION1,PEI_INFORMATION1),
		PEI_INFORMATION2 = nvl(pp_ei.PEI_INFORMATION2,PEI_INFORMATION2),
		--PEI_INFORMATION3 = nvl(pp_ei.PEI_INFORMATION3,PEI_INFORMATION3),
	---Bug 2412656 FERS Coverage
		PEI_INFORMATION3 = decode(pp_ei.information_type,'GHR_US_PER_SEPARATE_RETIRE',
                              pp_ei.PEI_INFORMATION3, nvl(pp_ei.PEI_INFORMATION3,PEI_INFORMATION3)),
		PEI_INFORMATION4 = nvl(pp_ei.PEI_INFORMATION4,PEI_INFORMATION4),
		--PEI_INFORMATION5 = nvl(pp_ei.PEI_INFORMATION5,PEI_INFORMATION5),
         ---Bug 2412656 Frozen Service
		PEI_INFORMATION5 = decode(pp_ei.information_type,'GHR_US_PER_SEPARATE_RETIRE',
                              pp_ei.PEI_INFORMATION5, nvl(pp_ei.PEI_INFORMATION5,PEI_INFORMATION5)),
		PEI_INFORMATION6 = nvl(pp_ei.PEI_INFORMATION6,PEI_INFORMATION6),
		PEI_INFORMATION7 = nvl(pp_ei.PEI_INFORMATION7,PEI_INFORMATION7),
		PEI_INFORMATION8 = nvl(pp_ei.PEI_INFORMATION8,PEI_INFORMATION8),
		PEI_INFORMATION9 = nvl(pp_ei.PEI_INFORMATION9,PEI_INFORMATION9),
		PEI_INFORMATION10 = nvl(pp_ei.PEI_INFORMATION10,PEI_INFORMATION10),
		PEI_INFORMATION11 = nvl(pp_ei.PEI_INFORMATION11,PEI_INFORMATION11),
		PEI_INFORMATION12 = nvl(pp_ei.PEI_INFORMATION12,PEI_INFORMATION12),
		PEI_INFORMATION13 = nvl(pp_ei.PEI_INFORMATION13,PEI_INFORMATION13),
		PEI_INFORMATION14 = nvl(pp_ei.PEI_INFORMATION14,PEI_INFORMATION14),
		PEI_INFORMATION15 = nvl(pp_ei.PEI_INFORMATION15,PEI_INFORMATION15),
		PEI_INFORMATION16 = nvl(pp_ei.PEI_INFORMATION16,PEI_INFORMATION16),
		PEI_INFORMATION17 = nvl(pp_ei.PEI_INFORMATION17,PEI_INFORMATION17),
		PEI_INFORMATION18 = nvl(pp_ei.PEI_INFORMATION18,PEI_INFORMATION18),
		PEI_INFORMATION19 = nvl(pp_ei.PEI_INFORMATION19,PEI_INFORMATION19),
		PEI_INFORMATION20 = nvl(pp_ei.PEI_INFORMATION20,PEI_INFORMATION20),
		PEI_INFORMATION21 = nvl(pp_ei.PEI_INFORMATION21,PEI_INFORMATION21),
		PEI_INFORMATION22 = nvl(pp_ei.PEI_INFORMATION22,PEI_INFORMATION22),
		PEI_INFORMATION23 = nvl(pp_ei.PEI_INFORMATION23,PEI_INFORMATION23),
		PEI_INFORMATION24 = nvl(pp_ei.PEI_INFORMATION24,PEI_INFORMATION24),
		PEI_INFORMATION25 = nvl(pp_ei.PEI_INFORMATION25,PEI_INFORMATION25),
		PEI_INFORMATION26 = nvl(pp_ei.PEI_INFORMATION26,PEI_INFORMATION26),
		PEI_INFORMATION27 = nvl(pp_ei.PEI_INFORMATION27,PEI_INFORMATION27),
		PEI_INFORMATION28 = nvl(pp_ei.PEI_INFORMATION28,PEI_INFORMATION28),
		PEI_INFORMATION29 = nvl(pp_ei.PEI_INFORMATION29,PEI_INFORMATION29),
		PEI_INFORMATION30 = nvl(pp_ei.PEI_INFORMATION30,PEI_INFORMATION30),
		--info3_meaning = nvl(l_info3_meaning,info3_meaning),
		-----Bug 2412656 FERS Coverage
		info3_meaning = decode(pp_ei.information_type,'GHR_US_PER_SEPARATE_RETIRE',
                           l_info3_meaning, nvl(l_info3_meaning,info3_meaning)),
		info4_meaning = nvl(l_info4_meaning,info4_meaning),
		info5_meaning = nvl(l_info5_meaning,info5_meaning),
		info6_meaning = nvl(l_info6_meaning,info6_meaning),
		info7_meaning = nvl(l_info7_meaning,info7_meaning),
		info8_meaning = nvl(l_info8_meaning,info8_meaning),
		info9_meaning = nvl(l_info9_meaning,info9_meaning),
		info10_meaning = nvl(l_info10_meaning,info10_meaning),
		info11_meaning = nvl(l_info11_meaning,info11_meaning)
	where current of cur_get_person_ei;

	close cur_get_person_ei;

exception
	when others then
		put_line(l_proc||' - raised exception');
		raise;
end;


--
-- insert data only if there is at least one value in p_si which is
-- not null
--
procedure insert_special_info(
					p_transfer_name	varchar2,
					p_effective_date	date,
					p_person_id			number,
					p_flex_name			varchar2,
					p_si					ghr_api.special_information_type)
is

	l_concat					varchar2(2000);
	l_segment1_meaning	varchar2(80);
	l_segment2_meaning	varchar2(80);
	l_proc			varchar2(72) := g_package||'insert_special_info';
	l_table_name	constant varchar2(30) := 'PER_ANALYSIS_CRITERIA';
	l_name			varchar2(30);

begin

	put('insert special info');

	l_concat := p_si.segment1	||
					p_si.segment2	||
					p_si.SEGMENT3	||
					p_si.SEGMENT4	||
					p_si.SEGMENT5	||
					p_si.SEGMENT6	||
					p_si.SEGMENT7	||
					p_si.SEGMENT8	||
					p_si.SEGMENT9	||
					p_si.SEGMENT10 ||
					p_si.SEGMENT11 ||
					p_si.SEGMENT12 ||
					p_si.SEGMENT13 ||
					p_si.SEGMENT14 ||
					p_si.SEGMENT15 ||
					p_si.SEGMENT16 ||
					p_si.SEGMENT17 ||
					p_si.SEGMENT18 ||
					p_si.SEGMENT19 ||
					p_si.SEGMENT20;

	if l_concat is null then
		put_line(' - no data');
		return;
	end if;
	put_line(' - ok, flex_name: '||p_flex_name);

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line('Called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> p_person_id
				,p_table_name			=> l_table_name
				,p_info_type			=> p_flex_name) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line('Called locally');
	end if;

	if p_flex_name = 'US Fed Education' then
		l_segment1_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_EDUCATIONAL_LEVEL',
									p_lookup_code	=>	p_si.segment1);

		l_segment2_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_ACADEMIC_DISCIPLINE',
									p_lookup_code	=>	p_si.segment2);

	end if;


	insert into ghr_mt_analysis_criteria_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		SEGMENT1,
		SEGMENT2,
		SEGMENT3,
		SEGMENT4,
		SEGMENT5,
		SEGMENT6,
		SEGMENT7,
		SEGMENT8,
		SEGMENT9,
		SEGMENT10,
		SEGMENT11,
		SEGMENT12,
		SEGMENT13,
		SEGMENT14,
		SEGMENT15,
		SEGMENT16,
		SEGMENT17,
		SEGMENT18,
		SEGMENT19,
		SEGMENT20,
		segment1_meaning,
		segment2_meaning
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,								-- MT_STATUS,
		p_person_id,					-- MT_PERSON_ID,
		l_table_name,					-- MT_TABLE_NAME,
		p_flex_name,					-- MT_INFORMATION_TYPE,
		null,
		p_si.SEGMENT1,
		p_si.SEGMENT2,
		p_si.SEGMENT3,
		p_si.SEGMENT4,
		p_si.SEGMENT5,
		p_si.SEGMENT6,
		p_si.SEGMENT7,
		p_si.SEGMENT8,
		p_si.SEGMENT9,
		p_si.SEGMENT10,
		p_si.SEGMENT11,
		p_si.SEGMENT12,
		p_si.SEGMENT13,
		p_si.SEGMENT14,
		p_si.SEGMENT15,
		p_si.SEGMENT16,
		p_si.SEGMENT17,
		p_si.SEGMENT18,
		p_si.SEGMENT19,
		p_si.SEGMENT20,
		l_segment1_meaning,
		l_segment2_meaning
	);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure update_special_info(
					p_transfer_name	varchar2,
					p_effective_date	date,
					p_person_id			number,
					p_flex_name			varchar2,
					p_si					ghr_api.special_information_type)
is

	l_segment1_meaning	varchar2(80);
	l_segment2_meaning	varchar2(80);
	l_proc			varchar2(72) := g_package||'update_special_info';
	l_x				varchar2(1);

	cursor cur_get_special_info is
		select 'x'
		from ghr_mt_analysis_criteria_v
		where mt_name = p_transfer_name
		and mt_person_id = to_char(p_person_id)
		and mt_information_type = p_flex_name
		for update;

begin

	put_line('update special info');

	open cur_get_special_info;
	fetch cur_get_special_info into l_x;

	if cur_get_special_info%notfound then
		put_line('update row not found - calling insert');
		close cur_get_special_info;

		insert_special_info(
					p_transfer_name	=> p_transfer_name,
					p_effective_date	=> p_effective_date,
					p_person_id			=> p_person_id,
					p_flex_name			=> p_flex_name,
					p_si					=> p_si
		);

		return;
	end if;

	if p_flex_name = 'US Fed Education' then
		l_segment1_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_EDUCATIONAL_LEVEL',
									p_lookup_code	=>	p_si.segment1);

		l_segment2_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_ACADEMIC_DISCIPLINE',
									p_lookup_code	=>	p_si.segment2);

	end if;

	update ghr_mt_analysis_criteria_v
	set
		MT_EFFECTIVE_DATE = p_effective_date,
		SEGMENT1 = nvl(p_si.SEGMENT1,SEGMENT1),
		--SEGMENT2 = nvl(p_si.SEGMENT2,SEGMENT2),
		--SEGMENT3 = nvl(p_si.SEGMENT3,SEGMENT3),
		SEGMENT2 = p_si.SEGMENT2,
		SEGMENT3 = p_si.SEGMENT3,
		SEGMENT4 = nvl(p_si.SEGMENT4,SEGMENT4),
		SEGMENT5 = nvl(p_si.SEGMENT5,SEGMENT5),
		SEGMENT6 = nvl(p_si.SEGMENT6,SEGMENT6),
		SEGMENT7 = nvl(p_si.SEGMENT7,SEGMENT7),
		SEGMENT8 = nvl(p_si.SEGMENT8,SEGMENT8),
		SEGMENT9 = nvl(p_si.SEGMENT9,SEGMENT9),
		SEGMENT10 = nvl(p_si.SEGMENT10,SEGMENT10),
		SEGMENT11 = nvl(p_si.SEGMENT11,SEGMENT11),
		SEGMENT12 = nvl(p_si.SEGMENT12,SEGMENT12),
		SEGMENT13 = nvl(p_si.SEGMENT13,SEGMENT13),
		SEGMENT14 = nvl(p_si.SEGMENT14,SEGMENT14),
		SEGMENT15 = nvl(p_si.SEGMENT15,SEGMENT15),
		SEGMENT16 = nvl(p_si.SEGMENT16,SEGMENT16),
		SEGMENT17 = nvl(p_si.SEGMENT17,SEGMENT17),
		SEGMENT18 = nvl(p_si.SEGMENT18,SEGMENT18),
		SEGMENT19 = nvl(p_si.SEGMENT19,SEGMENT19),
		SEGMENT20 = nvl(p_si.SEGMENT20,SEGMENT20),
		segment1_meaning = nvl(l_segment1_meaning,segment1_meaning),
		--segment2_meaning = nvl(l_segment2_meaning,segment2_meaning)
		---bug 2412656 SIT
		segment2_meaning = l_segment2_meaning
	where current of cur_get_special_info;

	close cur_get_special_info;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;


/*
 * The parameters, p_contact_name, and p_contact_type should contain values
 * when the address inserted is that of the contact.
 */
procedure insert_address(p_transfer_name		in varchar2,
									p_effective_date		in date,
									p_a						in per_addresses%rowtype,
									p_contact_name			in varchar2	default null,
									p_contact_type			in varchar2	default null)
is

	l_proc			varchar2(72) := g_package||'insert_address';
	l_name			varchar2(30);
	l_table_name	constant varchar2(30) := 'PER_ADDRESSES';

begin

	if p_contact_name is null then
		put('insert address');
	else
		put('insert contact address');
	end if;

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line(' - called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> p_a.person_id
				,p_table_name			=> l_table_name
				,p_contact_name		=> p_contact_name) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line(' - called locally');
	end if;

	insert into ghr_mt_addresses_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		MT_CONTACT_NAME,
		MT_CONTACT_TYPE,
		ADDRESS_ID,
		BUSINESS_GROUP_ID,
		PERSON_ID,
		DATE_FROM,
		PRIMARY_FLAG,
		STYLE,
		ADDRESS_LINE1,
		ADDRESS_LINE2,
		ADDRESS_LINE3,
		ADDRESS_TYPE,
		COMMENTS,
		COUNTRY,
		DATE_TO,
		POSTAL_CODE,
		REGION_1,
		REGION_2,
		REGION_3,
		TELEPHONE_NUMBER_1,
		TELEPHONE_NUMBER_2,
		TELEPHONE_NUMBER_3,
		TOWN_OR_CITY,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		ADDR_ATTRIBUTE_CATEGORY,
		ADDR_ATTRIBUTE1,
		ADDR_ATTRIBUTE2,
		ADDR_ATTRIBUTE3,
		ADDR_ATTRIBUTE4,
		ADDR_ATTRIBUTE5,
		ADDR_ATTRIBUTE6,
		ADDR_ATTRIBUTE7,
		ADDR_ATTRIBUTE8,
		ADDR_ATTRIBUTE9,
		ADDR_ATTRIBUTE10,
		ADDR_ATTRIBUTE11,
		ADDR_ATTRIBUTE12,
		ADDR_ATTRIBUTE13,
		ADDR_ATTRIBUTE14,
		ADDR_ATTRIBUTE15,
		ADDR_ATTRIBUTE16,
		ADDR_ATTRIBUTE17,
		ADDR_ATTRIBUTE18,
		ADDR_ATTRIBUTE19,
		ADDR_ATTRIBUTE20
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,								-- MT_STATUS,
		p_a.person_id,					-- MT_PERSON_ID,
		l_table_name,					-- MT_TABLE_NAME,
		null,								-- MT_INFORMATION_TYPE,
		null,
		p_contact_name,				-- MT_CONTACT_NAME
		p_contact_type,				-- MT_CONTACT_TYPE
		p_a.ADDRESS_ID,
		p_a.BUSINESS_GROUP_ID,
		p_a.PERSON_ID,
		to_char(p_a.DATE_FROM,g_datefmt),
		p_a.PRIMARY_FLAG,
		p_a.STYLE,
		p_a.ADDRESS_LINE1,
		p_a.ADDRESS_LINE2,
		p_a.ADDRESS_LINE3,
		p_a.ADDRESS_TYPE,
		p_a.COMMENTS,
		p_a.COUNTRY,
		to_char(p_a.DATE_TO,g_datefmt),
		p_a.POSTAL_CODE,
		p_a.REGION_1,
		p_a.REGION_2,
		p_a.REGION_3,
		p_a.TELEPHONE_NUMBER_1,
		p_a.TELEPHONE_NUMBER_2,
		p_a.TELEPHONE_NUMBER_3,
		p_a.TOWN_OR_CITY,
		p_a.REQUEST_ID,
		p_a.PROGRAM_APPLICATION_ID,
		p_a.PROGRAM_ID,
		p_a.PROGRAM_UPDATE_DATE,
		p_a.ADDR_ATTRIBUTE_CATEGORY,
		p_a.ADDR_ATTRIBUTE1,
		p_a.ADDR_ATTRIBUTE2,
		p_a.ADDR_ATTRIBUTE3,
		p_a.ADDR_ATTRIBUTE4,
		p_a.ADDR_ATTRIBUTE5,
		p_a.ADDR_ATTRIBUTE6,
		p_a.ADDR_ATTRIBUTE7,
		p_a.ADDR_ATTRIBUTE8,
		p_a.ADDR_ATTRIBUTE9,
		p_a.ADDR_ATTRIBUTE10,
		p_a.ADDR_ATTRIBUTE11,
		p_a.ADDR_ATTRIBUTE12,
		p_a.ADDR_ATTRIBUTE13,
		p_a.ADDR_ATTRIBUTE14,
		p_a.ADDR_ATTRIBUTE15,
		p_a.ADDR_ATTRIBUTE16,
		p_a.ADDR_ATTRIBUTE17,
		p_a.ADDR_ATTRIBUTE18,
		p_a.ADDR_ATTRIBUTE19,
		p_a.ADDR_ATTRIBUTE20
	);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure update_address(p_transfer_name		in varchar2,
									p_effective_date		in date,
									p_a						in per_addresses%rowtype,
									p_contact_name			in varchar2	default null,
									p_contact_type			in varchar2	default null)
is

	l_proc			varchar2(72) := g_package||'update_address';
	l_x				varchar2(1);

	cursor cur_address is
	select 'x'
	from ghr_mt_addresses_v
	where mt_name = p_transfer_name
	and mt_person_id = to_char(p_a.person_id)
	and nvl(mt_contact_name,'null') = nvl(p_contact_name,'null')
	for update;

begin

	if p_contact_name is null then
		put_line('update address');
	else
		put_line('update contact address');
	end if;

	open cur_address;
	fetch cur_address into l_x;

	if cur_address%notfound then
		close cur_address;
		hr_utility.set_message(8301, 'GHR_38549_UPDATE_NOT_FOUND');
		hr_utility.raise_error;
	end if;

	update ghr_mt_addresses_v
	set
		MT_EFFECTIVE_DATE = p_effective_date,
		ADDRESS_ID = nvl(p_a.ADDRESS_ID,ADDRESS_ID),
		BUSINESS_GROUP_ID = nvl(p_a.BUSINESS_GROUP_ID,BUSINESS_GROUP_ID),
		PERSON_ID = nvl(p_a.PERSON_ID,PERSON_ID),
		DATE_FROM = nvl(to_char(p_a.DATE_FROM,g_datefmt),DATE_FROM),
		PRIMARY_FLAG = nvl(p_a.PRIMARY_FLAG,PRIMARY_FLAG),
		STYLE = nvl(p_a.STYLE,STYLE),
		ADDRESS_LINE1 = nvl(p_a.ADDRESS_LINE1,ADDRESS_LINE1),
		ADDRESS_LINE2 = nvl(p_a.ADDRESS_LINE2,ADDRESS_LINE2),
		ADDRESS_LINE3 = nvl(p_a.ADDRESS_LINE3,ADDRESS_LINE3),
		ADDRESS_TYPE = nvl(p_a.ADDRESS_TYPE,ADDRESS_TYPE),
		COMMENTS = nvl(p_a.COMMENTS,COMMENTS),
		COUNTRY = nvl(p_a.COUNTRY,COUNTRY),
		DATE_TO = nvl(to_char(p_a.DATE_TO,g_datefmt),DATE_TO),
		POSTAL_CODE = nvl(p_a.POSTAL_CODE,POSTAL_CODE),
		REGION_1 = nvl(p_a.REGION_1,REGION_1),
		REGION_2 = nvl(p_a.REGION_2,REGION_2),
		REGION_3 = nvl(p_a.REGION_3,REGION_3),
		TELEPHONE_NUMBER_1 = nvl(p_a.TELEPHONE_NUMBER_1,TELEPHONE_NUMBER_1),
		TELEPHONE_NUMBER_2 = nvl(p_a.TELEPHONE_NUMBER_2,TELEPHONE_NUMBER_2),
		TELEPHONE_NUMBER_3 = nvl(p_a.TELEPHONE_NUMBER_3,TELEPHONE_NUMBER_3),
		TOWN_OR_CITY = nvl(p_a.TOWN_OR_CITY,TOWN_OR_CITY),
		REQUEST_ID = nvl(p_a.REQUEST_ID,REQUEST_ID),
		PROGRAM_APPLICATION_ID =
				nvl(p_a.PROGRAM_APPLICATION_ID,PROGRAM_APPLICATION_ID),
		PROGRAM_ID = nvl(p_a.PROGRAM_ID,PROGRAM_ID),
		ADDR_ATTRIBUTE_CATEGORY =
				nvl(p_a.ADDR_ATTRIBUTE_CATEGORY,ADDR_ATTRIBUTE_CATEGORY),
		ADDR_ATTRIBUTE1 = nvl(p_a.ADDR_ATTRIBUTE1,ADDR_ATTRIBUTE1),
		ADDR_ATTRIBUTE2 = nvl(p_a.ADDR_ATTRIBUTE2,ADDR_ATTRIBUTE2),
		ADDR_ATTRIBUTE3 = nvl(p_a.ADDR_ATTRIBUTE3,ADDR_ATTRIBUTE3),
		ADDR_ATTRIBUTE4 = nvl(p_a.ADDR_ATTRIBUTE4,ADDR_ATTRIBUTE4),
		ADDR_ATTRIBUTE5 = nvl(p_a.ADDR_ATTRIBUTE5,ADDR_ATTRIBUTE5),
		ADDR_ATTRIBUTE6 = nvl(p_a.ADDR_ATTRIBUTE6,ADDR_ATTRIBUTE6),
		ADDR_ATTRIBUTE7 = nvl(p_a.ADDR_ATTRIBUTE7,ADDR_ATTRIBUTE7),
		ADDR_ATTRIBUTE8 = nvl(p_a.ADDR_ATTRIBUTE8,ADDR_ATTRIBUTE8),
		ADDR_ATTRIBUTE9 = nvl(p_a.ADDR_ATTRIBUTE9,ADDR_ATTRIBUTE9),
		ADDR_ATTRIBUTE10 = nvl(p_a.ADDR_ATTRIBUTE10,ADDR_ATTRIBUTE10),
		ADDR_ATTRIBUTE11 = nvl(p_a.ADDR_ATTRIBUTE11,ADDR_ATTRIBUTE11),
		ADDR_ATTRIBUTE12 = nvl(p_a.ADDR_ATTRIBUTE12,ADDR_ATTRIBUTE12),
		ADDR_ATTRIBUTE13 = nvl(p_a.ADDR_ATTRIBUTE13,ADDR_ATTRIBUTE13),
		ADDR_ATTRIBUTE14 = nvl(p_a.ADDR_ATTRIBUTE14,ADDR_ATTRIBUTE14),
		ADDR_ATTRIBUTE15 = nvl(p_a.ADDR_ATTRIBUTE15,ADDR_ATTRIBUTE15),
		ADDR_ATTRIBUTE16 = nvl(p_a.ADDR_ATTRIBUTE16,ADDR_ATTRIBUTE16),
		ADDR_ATTRIBUTE17 = nvl(p_a.ADDR_ATTRIBUTE17,ADDR_ATTRIBUTE17),
		ADDR_ATTRIBUTE18 = nvl(p_a.ADDR_ATTRIBUTE18,ADDR_ATTRIBUTE18),
		ADDR_ATTRIBUTE19 = nvl(p_a.ADDR_ATTRIBUTE19,ADDR_ATTRIBUTE19),
		ADDR_ATTRIBUTE20 = nvl(p_a.ADDR_ATTRIBUTE20,ADDR_ATTRIBUTE20)
	where current of cur_address;

	close cur_address;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure insert_assignment_f(p_transfer_name 		varchar2,
									p_effective_date		date,
									p_a						per_all_assignments_f%rowtype)
is

	l_proc			varchar2(72) := g_package||'insert_assignment';
	l_table_name	constant varchar2(30) := 'PER_ASSIGNMENTS_F';
	l_name			varchar2(30);

begin

	put('insert assignment');

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line(' - called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> p_a.person_id
				,p_table_name			=> l_table_name) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line(' - called locally');
	end if;


	insert into ghr_mt_assignments_f_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		ASSIGNMENT_ID,
		EFFECTIVE_START_DATE,
		EFFECTIVE_END_DATE,
		BUSINESS_GROUP_ID,
		RECRUITER_ID,
		GRADE_ID,
		POSITION_ID,
		JOB_ID,
		ASSIGNMENT_STATUS_TYPE_ID,
		PAYROLL_ID,
		LOCATION_ID,
		PERSON_REFERRED_BY_ID,
		SUPERVISOR_ID,
		SPECIAL_CEILING_STEP_ID,
		PERSON_ID,
		RECRUITMENT_ACTIVITY_ID,
		SOURCE_ORGANIZATION_ID,
		ORGANIZATION_ID,
		PEOPLE_GROUP_ID,
		SOFT_CODING_KEYFLEX_ID,
		VACANCY_ID,
		PAY_BASIS_ID,
		ASSIGNMENT_SEQUENCE,
		ASSIGNMENT_TYPE,
		PRIMARY_FLAG,
		APPLICATION_ID,
		ASSIGNMENT_NUMBER,
		CHANGE_REASON,
		COMMENT_ID,
		DATE_PROBATION_END,
		DEFAULT_CODE_COMB_ID,
		EMPLOYMENT_CATEGORY,
		FREQUENCY,
		INTERNAL_ADDRESS_LINE,
		MANAGER_FLAG,
		NORMAL_HOURS,
		PERF_REVIEW_PERIOD,
		PERF_REVIEW_PERIOD_FREQUENCY,
		PERIOD_OF_SERVICE_ID,
		PROBATION_PERIOD,
		PROBATION_UNIT,
		SAL_REVIEW_PERIOD,
		SAL_REVIEW_PERIOD_FREQUENCY,
		SET_OF_BOOKS_ID,
		SOURCE_TYPE,
		TIME_NORMAL_FINISH,
		TIME_NORMAL_START,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		ASS_ATTRIBUTE_CATEGORY,
		ASS_ATTRIBUTE1,
		ASS_ATTRIBUTE2,
		ASS_ATTRIBUTE3,
		ASS_ATTRIBUTE4,
		ASS_ATTRIBUTE5,
		ASS_ATTRIBUTE6,
		ASS_ATTRIBUTE7,
		ASS_ATTRIBUTE8,
		ASS_ATTRIBUTE9,
		ASS_ATTRIBUTE10,
		ASS_ATTRIBUTE11,
		ASS_ATTRIBUTE12,
		ASS_ATTRIBUTE13,
		ASS_ATTRIBUTE14,
		ASS_ATTRIBUTE15,
		ASS_ATTRIBUTE16,
		ASS_ATTRIBUTE17,
		ASS_ATTRIBUTE18,
		ASS_ATTRIBUTE19,
		ASS_ATTRIBUTE20,
		ASS_ATTRIBUTE21,
		ASS_ATTRIBUTE22,
		ASS_ATTRIBUTE23,
		ASS_ATTRIBUTE24,
		ASS_ATTRIBUTE25,
		ASS_ATTRIBUTE26,
		ASS_ATTRIBUTE27,
		ASS_ATTRIBUTE28,
		ASS_ATTRIBUTE29,
		ASS_ATTRIBUTE30,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATION_DATE,
		TITLE,
		OBJECT_VERSION_NUMBER
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,								-- MT_STATUS,
		p_a.person_id,					-- MT_PERSON_ID,
		l_table_name,					-- MT_TABLE_NAME,
		null,								-- MT_INFORMATION_TYPE,
		null,
		p_a.ASSIGNMENT_ID,
		to_char(p_a.EFFECTIVE_START_DATE,g_datefmt),
		to_char(p_a.EFFECTIVE_END_DATE,g_datefmt),
		p_a.BUSINESS_GROUP_ID,
		p_a.RECRUITER_ID,
		p_a.GRADE_ID,
		p_a.POSITION_ID,
		p_a.JOB_ID,
		p_a.ASSIGNMENT_STATUS_TYPE_ID,
		p_a.PAYROLL_ID,
		p_a.LOCATION_ID,
		p_a.PERSON_REFERRED_BY_ID,
		p_a.SUPERVISOR_ID,
		p_a.SPECIAL_CEILING_STEP_ID,
		p_a.PERSON_ID,
		p_a.RECRUITMENT_ACTIVITY_ID,
		p_a.SOURCE_ORGANIZATION_ID,
		p_a.ORGANIZATION_ID,
		p_a.PEOPLE_GROUP_ID,
		p_a.SOFT_CODING_KEYFLEX_ID,
		p_a.VACANCY_ID,
		p_a.PAY_BASIS_ID,
		p_a.ASSIGNMENT_SEQUENCE,
		p_a.ASSIGNMENT_TYPE,
		p_a.PRIMARY_FLAG,
		p_a.APPLICATION_ID,
		p_a.ASSIGNMENT_NUMBER,
		p_a.CHANGE_REASON,
		p_a.COMMENT_ID,
		to_char(p_a.DATE_PROBATION_END,g_datefmt),
		p_a.DEFAULT_CODE_COMB_ID,
		p_a.EMPLOYMENT_CATEGORY,
		p_a.FREQUENCY,
		p_a.INTERNAL_ADDRESS_LINE,
		p_a.MANAGER_FLAG,
		p_a.NORMAL_HOURS,
		p_a.PERF_REVIEW_PERIOD,
		p_a.PERF_REVIEW_PERIOD_FREQUENCY,
		p_a.PERIOD_OF_SERVICE_ID,
		p_a.PROBATION_PERIOD,
		p_a.PROBATION_UNIT,
		p_a.SAL_REVIEW_PERIOD,
		p_a.SAL_REVIEW_PERIOD_FREQUENCY,
		p_a.SET_OF_BOOKS_ID,
		p_a.SOURCE_TYPE,
		p_a.TIME_NORMAL_FINISH,
		p_a.TIME_NORMAL_START,
		p_a.REQUEST_ID,
		p_a.PROGRAM_APPLICATION_ID,
		p_a.PROGRAM_ID,
		to_char(p_a.PROGRAM_UPDATE_DATE,g_datefmt),
		p_a.ASS_ATTRIBUTE_CATEGORY,
		p_a.ASS_ATTRIBUTE1,
		p_a.ASS_ATTRIBUTE2,
		p_a.ASS_ATTRIBUTE3,
		p_a.ASS_ATTRIBUTE4,
		p_a.ASS_ATTRIBUTE5,
		p_a.ASS_ATTRIBUTE6,
		p_a.ASS_ATTRIBUTE7,
		p_a.ASS_ATTRIBUTE8,
		p_a.ASS_ATTRIBUTE9,
		p_a.ASS_ATTRIBUTE10,
		p_a.ASS_ATTRIBUTE11,
		p_a.ASS_ATTRIBUTE12,
		p_a.ASS_ATTRIBUTE13,
		p_a.ASS_ATTRIBUTE14,
		p_a.ASS_ATTRIBUTE15,
		p_a.ASS_ATTRIBUTE16,
		p_a.ASS_ATTRIBUTE17,
		p_a.ASS_ATTRIBUTE18,
		p_a.ASS_ATTRIBUTE19,
		p_a.ASS_ATTRIBUTE20,
		p_a.ASS_ATTRIBUTE21,
		p_a.ASS_ATTRIBUTE22,
		p_a.ASS_ATTRIBUTE23,
		p_a.ASS_ATTRIBUTE24,
		p_a.ASS_ATTRIBUTE25,
		p_a.ASS_ATTRIBUTE26,
		p_a.ASS_ATTRIBUTE27,
		p_a.ASS_ATTRIBUTE28,
		p_a.ASS_ATTRIBUTE29,
		p_a.ASS_ATTRIBUTE30,
		to_char(p_a.LAST_UPDATE_DATE,g_datefmt),
		p_a.LAST_UPDATED_BY,
		p_a.LAST_UPDATE_LOGIN,
		p_a.CREATED_BY,
		to_char(p_a.CREATION_DATE,g_datefmt),
		p_a.TITLE,
		p_a.OBJECT_VERSION_NUMBER
	);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure update_assignment_f(p_transfer_name 		varchar2,
										p_effective_date		date,
										p_a						per_all_assignments_f%rowtype)
is

	l_proc			varchar2(72) := g_package||'insert_assignment';
	l_x				varchar2(1);

	cursor cur_assignment is
	select 'x'
	from ghr_mt_assignments_f_v
	where mt_name = p_transfer_name
	and mt_person_id = to_char(p_a.person_id)
	for update;

begin

	put_line('update assignment');

	open cur_assignment;
	fetch cur_assignment into l_x;

	if cur_assignment%notfound then
		close cur_assignment;
		hr_utility.set_message(8301, 'GHR_38549_UPDATE_NOT_FOUND');
		hr_utility.raise_error;
	end if;

	update ghr_mt_assignments_f_v
	set
		MT_EFFECTIVE_DATE = p_effective_date,
		ASSIGNMENT_ID = nvl(p_a.ASSIGNMENT_ID,ASSIGNMENT_ID),
		EFFECTIVE_START_DATE =
				nvl(to_char(p_a.EFFECTIVE_START_DATE,g_datefmt),
				EFFECTIVE_START_DATE),
		EFFECTIVE_END_DATE = nvl(to_char(p_a.EFFECTIVE_END_DATE,g_datefmt),
				EFFECTIVE_END_DATE),
		BUSINESS_GROUP_ID = nvl(p_a.BUSINESS_GROUP_ID,BUSINESS_GROUP_ID),
		RECRUITER_ID = nvl(p_a.RECRUITER_ID,RECRUITER_ID),
		GRADE_ID = nvl(p_a.GRADE_ID,GRADE_ID),
		POSITION_ID = nvl(p_a.POSITION_ID,POSITION_ID),
		JOB_ID = nvl(p_a.JOB_ID,JOB_ID),
		ASSIGNMENT_STATUS_TYPE_ID =
				nvl(p_a.ASSIGNMENT_STATUS_TYPE_ID,ASSIGNMENT_STATUS_TYPE_ID),
		PAYROLL_ID = nvl(p_a.PAYROLL_ID,PAYROLL_ID),
		LOCATION_ID = nvl(p_a.LOCATION_ID,LOCATION_ID),
		PERSON_REFERRED_BY_ID =
				nvl(p_a.PERSON_REFERRED_BY_ID,PERSON_REFERRED_BY_ID),
		SUPERVISOR_ID = nvl(p_a.SUPERVISOR_ID,SUPERVISOR_ID),
		SPECIAL_CEILING_STEP_ID =
				nvl(p_a.SPECIAL_CEILING_STEP_ID,SPECIAL_CEILING_STEP_ID),
		PERSON_ID = nvl(p_a.PERSON_ID,PERSON_ID),
		RECRUITMENT_ACTIVITY_ID =
				nvl(p_a.RECRUITMENT_ACTIVITY_ID,RECRUITMENT_ACTIVITY_ID),
		SOURCE_ORGANIZATION_ID =
				nvl(p_a.SOURCE_ORGANIZATION_ID,SOURCE_ORGANIZATION_ID),
		ORGANIZATION_ID = nvl(p_a.ORGANIZATION_ID,ORGANIZATION_ID),
		PEOPLE_GROUP_ID = nvl(p_a.PEOPLE_GROUP_ID,PEOPLE_GROUP_ID),
		SOFT_CODING_KEYFLEX_ID =
				nvl(p_a.SOFT_CODING_KEYFLEX_ID,SOFT_CODING_KEYFLEX_ID),
		VACANCY_ID = nvl(p_a.VACANCY_ID,VACANCY_ID),
		PAY_BASIS_ID = nvl(p_a.PAY_BASIS_ID,PAY_BASIS_ID),
		ASSIGNMENT_SEQUENCE = nvl(p_a.ASSIGNMENT_SEQUENCE,ASSIGNMENT_SEQUENCE),
		ASSIGNMENT_TYPE = nvl(p_a.ASSIGNMENT_TYPE,ASSIGNMENT_TYPE),
		PRIMARY_FLAG = nvl(p_a.PRIMARY_FLAG,PRIMARY_FLAG),
		APPLICATION_ID = nvl(p_a.APPLICATION_ID,APPLICATION_ID),
		ASSIGNMENT_NUMBER = nvl(p_a.ASSIGNMENT_NUMBER,ASSIGNMENT_NUMBER),
		CHANGE_REASON = nvl(p_a.CHANGE_REASON,CHANGE_REASON),
		COMMENT_ID = nvl(p_a.COMMENT_ID,COMMENT_ID),
		DATE_PROBATION_END =
				nvl(to_char(p_a.DATE_PROBATION_END,g_datefmt),DATE_PROBATION_END),
		DEFAULT_CODE_COMB_ID = nvl(p_a.DEFAULT_CODE_COMB_ID,DEFAULT_CODE_COMB_ID),
		EMPLOYMENT_CATEGORY = nvl(p_a.EMPLOYMENT_CATEGORY,EMPLOYMENT_CATEGORY),
		FREQUENCY = nvl(p_a.FREQUENCY,FREQUENCY),
		INTERNAL_ADDRESS_LINE =
				nvl(p_a.INTERNAL_ADDRESS_LINE,INTERNAL_ADDRESS_LINE),
		MANAGER_FLAG = nvl(p_a.MANAGER_FLAG,MANAGER_FLAG),
		NORMAL_HOURS = nvl(p_a.NORMAL_HOURS,NORMAL_HOURS),
		PERF_REVIEW_PERIOD = nvl(p_a.PERF_REVIEW_PERIOD,PERF_REVIEW_PERIOD),
		PERF_REVIEW_PERIOD_FREQUENCY =
				nvl(p_a.PERF_REVIEW_PERIOD_FREQUENCY,PERF_REVIEW_PERIOD_FREQUENCY),
		PERIOD_OF_SERVICE_ID = nvl(p_a.PERIOD_OF_SERVICE_ID,PERIOD_OF_SERVICE_ID),
		PROBATION_PERIOD = nvl(p_a.PROBATION_PERIOD,PROBATION_PERIOD),
		PROBATION_UNIT = nvl(p_a.PROBATION_UNIT,PROBATION_UNIT),
		SAL_REVIEW_PERIOD = nvl(p_a.SAL_REVIEW_PERIOD,SAL_REVIEW_PERIOD),
		SAL_REVIEW_PERIOD_FREQUENCY =
				nvl(p_a.SAL_REVIEW_PERIOD_FREQUENCY,SAL_REVIEW_PERIOD_FREQUENCY),
		SET_OF_BOOKS_ID = nvl(p_a.SET_OF_BOOKS_ID,SET_OF_BOOKS_ID),
		SOURCE_TYPE = nvl(p_a.SOURCE_TYPE,SOURCE_TYPE),
		TIME_NORMAL_FINISH = nvl(p_a.TIME_NORMAL_FINISH,TIME_NORMAL_FINISH),
		TIME_NORMAL_START = nvl(p_a.TIME_NORMAL_START,TIME_NORMAL_START),
		REQUEST_ID = nvl(p_a.REQUEST_ID,REQUEST_ID),
		PROGRAM_APPLICATION_ID =
				nvl(p_a.PROGRAM_APPLICATION_ID,PROGRAM_APPLICATION_ID),
		PROGRAM_ID = nvl(p_a.PROGRAM_ID,PROGRAM_ID),
		PROGRAM_UPDATE_DATE = nvl(p_a.PROGRAM_UPDATE_DATE,PROGRAM_UPDATE_DATE),
		ASS_ATTRIBUTE_CATEGORY =
				nvl(p_a.ASS_ATTRIBUTE_CATEGORY,ASS_ATTRIBUTE_CATEGORY),
		ASS_ATTRIBUTE1 = nvl(p_a.ASS_ATTRIBUTE1,ASS_ATTRIBUTE1),
		ASS_ATTRIBUTE2 = nvl(p_a.ASS_ATTRIBUTE2,ASS_ATTRIBUTE2),
		ASS_ATTRIBUTE3 = nvl(p_a.ASS_ATTRIBUTE3,ASS_ATTRIBUTE3),
		ASS_ATTRIBUTE4 = nvl(p_a.ASS_ATTRIBUTE4,ASS_ATTRIBUTE4),
		ASS_ATTRIBUTE5 = nvl(p_a.ASS_ATTRIBUTE5,ASS_ATTRIBUTE5),
		ASS_ATTRIBUTE6 = nvl(p_a.ASS_ATTRIBUTE6,ASS_ATTRIBUTE6),
		ASS_ATTRIBUTE7 = nvl(p_a.ASS_ATTRIBUTE7,ASS_ATTRIBUTE7),
		ASS_ATTRIBUTE8 = nvl(p_a.ASS_ATTRIBUTE8,ASS_ATTRIBUTE8),
		ASS_ATTRIBUTE9 = nvl(p_a.ASS_ATTRIBUTE9,ASS_ATTRIBUTE9),
		ASS_ATTRIBUTE10 = nvl(p_a.ASS_ATTRIBUTE10,ASS_ATTRIBUTE10),
		ASS_ATTRIBUTE11 = nvl(p_a.ASS_ATTRIBUTE11,ASS_ATTRIBUTE11),
		ASS_ATTRIBUTE12 = nvl(p_a.ASS_ATTRIBUTE12,ASS_ATTRIBUTE12),
		ASS_ATTRIBUTE13 = nvl(p_a.ASS_ATTRIBUTE13,ASS_ATTRIBUTE13),
		ASS_ATTRIBUTE14 = nvl(p_a.ASS_ATTRIBUTE14,ASS_ATTRIBUTE14),
		ASS_ATTRIBUTE15 = nvl(p_a.ASS_ATTRIBUTE15,ASS_ATTRIBUTE15),
		ASS_ATTRIBUTE16 = nvl(p_a.ASS_ATTRIBUTE16,ASS_ATTRIBUTE16),
		ASS_ATTRIBUTE17 = nvl(p_a.ASS_ATTRIBUTE17,ASS_ATTRIBUTE17),
		ASS_ATTRIBUTE18 = nvl(p_a.ASS_ATTRIBUTE18,ASS_ATTRIBUTE18),
		ASS_ATTRIBUTE19 = nvl(p_a.ASS_ATTRIBUTE19,ASS_ATTRIBUTE19),
		ASS_ATTRIBUTE20 = nvl(p_a.ASS_ATTRIBUTE20,ASS_ATTRIBUTE20),
		ASS_ATTRIBUTE21 = nvl(p_a.ASS_ATTRIBUTE21,ASS_ATTRIBUTE21),
		ASS_ATTRIBUTE22 = nvl(p_a.ASS_ATTRIBUTE22,ASS_ATTRIBUTE22),
		ASS_ATTRIBUTE23 = nvl(p_a.ASS_ATTRIBUTE23,ASS_ATTRIBUTE23),
		ASS_ATTRIBUTE24 = nvl(p_a.ASS_ATTRIBUTE24,ASS_ATTRIBUTE24),
		ASS_ATTRIBUTE25 = nvl(p_a.ASS_ATTRIBUTE25,ASS_ATTRIBUTE25),
		ASS_ATTRIBUTE26 = nvl(p_a.ASS_ATTRIBUTE26,ASS_ATTRIBUTE26),
		ASS_ATTRIBUTE27 = nvl(p_a.ASS_ATTRIBUTE27,ASS_ATTRIBUTE27),
		ASS_ATTRIBUTE28 = nvl(p_a.ASS_ATTRIBUTE28,ASS_ATTRIBUTE28),
		ASS_ATTRIBUTE29 = nvl(p_a.ASS_ATTRIBUTE29,ASS_ATTRIBUTE29),
		ASS_ATTRIBUTE30 = nvl(p_a.ASS_ATTRIBUTE30,ASS_ATTRIBUTE30),
		TITLE = nvl(p_a.TITLE,TITLE)
	where current of cur_assignment;

	close cur_assignment;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure insert_assignment_ei(p_transfer_name 			varchar2,
									   p_person_id					number,
									   p_effective_date			date,
									   p_a_ei	per_assignment_extra_info%rowtype)
is

	l_proc			varchar2(72) := g_package||'insert_assignment_ei';
	l_table_name	constant varchar2(30) := 'PER_ASSIGNMENT_EXTRA_INFO';
	l_name			varchar2(30);

	l_info4_meaning	varchar2(80) := null;
	l_info5_meaning	varchar2(80) := null;
	l_info6_meaning	varchar2(80) := null;
	l_info7_meaning	varchar2(80) := null;
	l_info8_meaning	varchar2(80) := null;

begin

	put('insert assignment_ei');

	-- check if p_a_ei contains data, if not return
	if p_a_ei.information_type is null then
		put_line(' - no data');
		return;
	end if;
	put_line(' - ok, info_type: '||p_a_ei.information_type);

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line('Called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> p_person_id
				,p_table_name			=> l_table_name
				,p_info_type			=> p_a_ei.information_type) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line('Called locally');
	end if;

	if p_a_ei.information_type = 'GHR_US_ASG_SF52' then
		l_info4_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_TENURE',
									p_lookup_code	=>	p_a_ei.aei_information4);

		l_info5_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_ANNUITANT_INDICATOR',
									p_lookup_code	=>	p_a_ei.aei_information5);

		l_info6_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_PAY_RATE_DETERMINANT',
									p_lookup_code	=>	p_a_ei.aei_information6);

		l_info7_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_WORK_SCHEDULE',
									p_lookup_code	=>	p_a_ei.aei_information7);

	elsif p_a_ei.information_type = 'GHR_US_ASG_NON_SF52' then
		l_info6_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_NON_DISCLOSURE_AGREE',
									p_lookup_code	=>	p_a_ei.aei_information6);

		l_info8_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_PART_TIME_INDICATOR',
									p_lookup_code	=>	p_a_ei.aei_information8);

	end if;


	insert into ghr_mt_assignment_ei_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		ASSIGNMENT_EXTRA_INFO_ID,
		ASSIGNMENT_ID,
		INFORMATION_TYPE,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		AEI_ATTRIBUTE_CATEGORY,
		AEI_ATTRIBUTE1,
		AEI_ATTRIBUTE2,
		AEI_ATTRIBUTE3,
		AEI_ATTRIBUTE4,
		AEI_ATTRIBUTE5,
		AEI_ATTRIBUTE6,
		AEI_ATTRIBUTE7,
		AEI_ATTRIBUTE8,
		AEI_ATTRIBUTE9,
		AEI_ATTRIBUTE10,
		AEI_ATTRIBUTE11,
		AEI_ATTRIBUTE12,
		AEI_ATTRIBUTE13,
		AEI_ATTRIBUTE14,
		AEI_ATTRIBUTE15,
		AEI_ATTRIBUTE16,
		AEI_ATTRIBUTE17,
		AEI_ATTRIBUTE18,
		AEI_ATTRIBUTE19,
		AEI_ATTRIBUTE20,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATION_DATE,
		AEI_INFORMATION_CATEGORY,
		AEI_INFORMATION1,
		AEI_INFORMATION2,
		AEI_INFORMATION3,
		AEI_INFORMATION4,
		AEI_INFORMATION5,
		AEI_INFORMATION6,
		AEI_INFORMATION7,
		AEI_INFORMATION8,
		AEI_INFORMATION9,
		AEI_INFORMATION10,
		AEI_INFORMATION11,
		AEI_INFORMATION12,
		AEI_INFORMATION13,
		AEI_INFORMATION14,
		AEI_INFORMATION15,
		AEI_INFORMATION16,
		AEI_INFORMATION17,
		AEI_INFORMATION18,
		AEI_INFORMATION19,
		AEI_INFORMATION20,
		AEI_INFORMATION21,
		AEI_INFORMATION22,
		AEI_INFORMATION23,
		AEI_INFORMATION24,
		AEI_INFORMATION25,
		AEI_INFORMATION26,
		AEI_INFORMATION27,
		AEI_INFORMATION28,
		AEI_INFORMATION29,
		AEI_INFORMATION30,
		OBJECT_VERSION_NUMBER,
		info4_meaning,
		info5_meaning,
		info6_meaning,
		info7_meaning,
		info8_meaning
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,									-- MT_STATUS,
		p_person_id,						-- MT_PERSON_ID,
		l_table_name,						-- MT_TABLE_NAME,
		p_a_ei.information_type,		-- MT_INFORMATION_TYPE,
		null,									-- MT_INTER_BG_TRANSFER
		p_a_ei.ASSIGNMENT_EXTRA_INFO_ID,
		p_a_ei.ASSIGNMENT_ID,
		p_a_ei.INFORMATION_TYPE,
		p_a_ei.REQUEST_ID,
		p_a_ei.PROGRAM_APPLICATION_ID,
		p_a_ei.PROGRAM_ID,
		to_char(p_a_ei.PROGRAM_UPDATE_DATE,g_datefmt),
		p_a_ei.AEI_ATTRIBUTE_CATEGORY,
		p_a_ei.AEI_ATTRIBUTE1,
		p_a_ei.AEI_ATTRIBUTE2,
		p_a_ei.AEI_ATTRIBUTE3,
		p_a_ei.AEI_ATTRIBUTE4,
		p_a_ei.AEI_ATTRIBUTE5,
		p_a_ei.AEI_ATTRIBUTE6,
		p_a_ei.AEI_ATTRIBUTE7,
		p_a_ei.AEI_ATTRIBUTE8,
		p_a_ei.AEI_ATTRIBUTE9,
		p_a_ei.AEI_ATTRIBUTE10,
		p_a_ei.AEI_ATTRIBUTE11,
		p_a_ei.AEI_ATTRIBUTE12,
		p_a_ei.AEI_ATTRIBUTE13,
		p_a_ei.AEI_ATTRIBUTE14,
		p_a_ei.AEI_ATTRIBUTE15,
		p_a_ei.AEI_ATTRIBUTE16,
		p_a_ei.AEI_ATTRIBUTE17,
		p_a_ei.AEI_ATTRIBUTE18,
		p_a_ei.AEI_ATTRIBUTE19,
		p_a_ei.AEI_ATTRIBUTE20,
		to_char(p_a_ei.LAST_UPDATE_DATE,g_datefmt),
		p_a_ei.LAST_UPDATED_BY,
		p_a_ei.LAST_UPDATE_LOGIN,
		p_a_ei.CREATED_BY,
		to_char(p_a_ei.CREATION_DATE,g_datefmt),
		p_a_ei.AEI_INFORMATION_CATEGORY,
		p_a_ei.AEI_INFORMATION1,
		p_a_ei.AEI_INFORMATION2,
		p_a_ei.AEI_INFORMATION3,
		p_a_ei.AEI_INFORMATION4,
		p_a_ei.AEI_INFORMATION5,
		p_a_ei.AEI_INFORMATION6,
		p_a_ei.AEI_INFORMATION7,
		p_a_ei.AEI_INFORMATION8,
		p_a_ei.AEI_INFORMATION9,
		p_a_ei.AEI_INFORMATION10,
		p_a_ei.AEI_INFORMATION11,
		p_a_ei.AEI_INFORMATION12,
		p_a_ei.AEI_INFORMATION13,
		p_a_ei.AEI_INFORMATION14,
		p_a_ei.AEI_INFORMATION15,
		p_a_ei.AEI_INFORMATION16,
		p_a_ei.AEI_INFORMATION17,
		p_a_ei.AEI_INFORMATION18,
		p_a_ei.AEI_INFORMATION19,
		p_a_ei.AEI_INFORMATION20,
		p_a_ei.AEI_INFORMATION21,
		p_a_ei.AEI_INFORMATION22,
		p_a_ei.AEI_INFORMATION23,
		p_a_ei.AEI_INFORMATION24,
		p_a_ei.AEI_INFORMATION25,
		p_a_ei.AEI_INFORMATION26,
		p_a_ei.AEI_INFORMATION27,
		p_a_ei.AEI_INFORMATION28,
		p_a_ei.AEI_INFORMATION29,
		p_a_ei.AEI_INFORMATION30,
		p_a_ei.OBJECT_VERSION_NUMBER,
		l_info4_meaning,
		l_info5_meaning,
		l_info6_meaning,
		l_info7_meaning,
		l_info8_meaning
	);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure update_assignment_ei(p_transfer_name 			varchar2,
									   p_person_id					number,
									   p_effective_date			date,
									   p_a_ei	per_assignment_extra_info%rowtype)
is

	l_proc			varchar2(72) := g_package||'update_assignment_ei';
	l_x				varchar2(1);

	l_info4_meaning	varchar2(80) := null;
	l_info5_meaning	varchar2(80) := null;
	l_info6_meaning	varchar2(80) := null;
	l_info7_meaning	varchar2(80) := null;
	l_info8_meaning	varchar2(80) := null;

	cursor cur_assignment_ei is
	select 'x'
	from ghr_mt_assignment_ei_v
	where mt_name = p_transfer_name
	and mt_person_id = to_char(p_person_id)
	and mt_information_type = p_a_ei.information_type
	for update;

begin

	put_line('update assignment_ei');

	open cur_assignment_ei;
	fetch cur_assignment_ei into l_x;

	if cur_assignment_ei%notfound then
		put_line('update row not found - calling insert');
		close cur_assignment_ei;

		insert_assignment_ei(
			p_transfer_name 			=> p_transfer_name,
			p_person_id					=> p_person_id,
			p_effective_date			=> p_effective_date,
			p_a_ei						=> p_a_ei
		);

		return;
	end if;

	if p_a_ei.information_type = 'GHR_US_ASG_SF52' then
		l_info4_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_TENURE',
									p_lookup_code	=>	p_a_ei.aei_information4);

		l_info5_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_ANNUITANT_INDICATOR',
									p_lookup_code	=>	p_a_ei.aei_information5);

		l_info6_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_PAY_RATE_DETERMINANT',
									p_lookup_code	=>	p_a_ei.aei_information6);

		l_info7_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_WORK_SCHEDULE',
									p_lookup_code	=>	p_a_ei.aei_information7);

	elsif p_a_ei.information_type = 'GHR_US_ASG_NON_SF52' then
		l_info6_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_NON_DISCLOSURE_AGREE',
									p_lookup_code	=>	p_a_ei.aei_information6);

		l_info8_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_PART_TIME_INDICATOR',
									p_lookup_code	=>	p_a_ei.aei_information8);

	end if;

	update ghr_mt_assignment_ei_v
	set
		MT_EFFECTIVE_DATE = p_effective_date,
		ASSIGNMENT_EXTRA_INFO_ID =
				nvl(p_a_ei.ASSIGNMENT_EXTRA_INFO_ID,ASSIGNMENT_EXTRA_INFO_ID),
		ASSIGNMENT_ID = nvl(p_a_ei.ASSIGNMENT_ID,ASSIGNMENT_ID),
		INFORMATION_TYPE = nvl(p_a_ei.INFORMATION_TYPE,INFORMATION_TYPE),
		REQUEST_ID = nvl(p_a_ei.REQUEST_ID,REQUEST_ID),
		PROGRAM_APPLICATION_ID =
				nvl(p_a_ei.PROGRAM_APPLICATION_ID,PROGRAM_APPLICATION_ID),
		PROGRAM_ID = nvl(p_a_ei.PROGRAM_ID,PROGRAM_ID),
		PROGRAM_UPDATE_DATE =
				nvl(to_char(p_a_ei.PROGRAM_UPDATE_DATE,g_datefmt),
				PROGRAM_UPDATE_DATE),
		AEI_ATTRIBUTE_CATEGORY =
				nvl(p_a_ei.AEI_ATTRIBUTE_CATEGORY,AEI_ATTRIBUTE_CATEGORY),
		AEI_ATTRIBUTE1 = nvl(p_a_ei.AEI_ATTRIBUTE1,AEI_ATTRIBUTE1),
		AEI_ATTRIBUTE2 = nvl(p_a_ei.AEI_ATTRIBUTE2,AEI_ATTRIBUTE2),
		AEI_ATTRIBUTE3 = nvl(p_a_ei.AEI_ATTRIBUTE3,AEI_ATTRIBUTE3),
		AEI_ATTRIBUTE4 = nvl(p_a_ei.AEI_ATTRIBUTE4,AEI_ATTRIBUTE4),
		AEI_ATTRIBUTE5 = nvl(p_a_ei.AEI_ATTRIBUTE5,AEI_ATTRIBUTE5),
		AEI_ATTRIBUTE6 = nvl(p_a_ei.AEI_ATTRIBUTE6,AEI_ATTRIBUTE6),
		AEI_ATTRIBUTE7 = nvl(p_a_ei.AEI_ATTRIBUTE7,AEI_ATTRIBUTE7),
		AEI_ATTRIBUTE8 = nvl(p_a_ei.AEI_ATTRIBUTE8,AEI_ATTRIBUTE8),
		AEI_ATTRIBUTE9 = nvl(p_a_ei.AEI_ATTRIBUTE9,AEI_ATTRIBUTE9),
		AEI_ATTRIBUTE10 = nvl(p_a_ei.AEI_ATTRIBUTE10,AEI_ATTRIBUTE10),
		AEI_ATTRIBUTE11 = nvl(p_a_ei.AEI_ATTRIBUTE11,AEI_ATTRIBUTE11),
		AEI_ATTRIBUTE12 = nvl(p_a_ei.AEI_ATTRIBUTE12,AEI_ATTRIBUTE12),
		AEI_ATTRIBUTE13 = nvl(p_a_ei.AEI_ATTRIBUTE13,AEI_ATTRIBUTE13),
		AEI_ATTRIBUTE14 = nvl(p_a_ei.AEI_ATTRIBUTE14,AEI_ATTRIBUTE14),
		AEI_ATTRIBUTE15 = nvl(p_a_ei.AEI_ATTRIBUTE15,AEI_ATTRIBUTE15),
		AEI_ATTRIBUTE16 = nvl(p_a_ei.AEI_ATTRIBUTE16,AEI_ATTRIBUTE16),
		AEI_ATTRIBUTE17 = nvl(p_a_ei.AEI_ATTRIBUTE17,AEI_ATTRIBUTE17),
		AEI_ATTRIBUTE18 = nvl(p_a_ei.AEI_ATTRIBUTE18,AEI_ATTRIBUTE18),
		AEI_ATTRIBUTE19 = nvl(p_a_ei.AEI_ATTRIBUTE19,AEI_ATTRIBUTE19),
		AEI_ATTRIBUTE20 = nvl(p_a_ei.AEI_ATTRIBUTE20,AEI_ATTRIBUTE20),
		AEI_INFORMATION_CATEGORY =
				nvl(p_a_ei.AEI_INFORMATION_CATEGORY,AEI_INFORMATION_CATEGORY),
		AEI_INFORMATION1 = nvl(p_a_ei.AEI_INFORMATION1,AEI_INFORMATION1),
		AEI_INFORMATION2 = nvl(p_a_ei.AEI_INFORMATION2,AEI_INFORMATION2),
	      --AEI_INFORMATION3 = nvl(p_a_ei.AEI_INFORMATION3,AEI_INFORMATION3),
		-----bug 2412656  Date Arrived Per
		AEI_INFORMATION3 = decode(p_a_ei.information_type,'GHR_US_ASG_NON_SF52',
                              p_a_ei.AEI_INFORMATION3, nvl(p_a_ei.AEI_INFORMATION3,AEI_INFORMATION3)),
		AEI_INFORMATION4 = nvl(p_a_ei.AEI_INFORMATION4,AEI_INFORMATION4),
		AEI_INFORMATION5 = nvl(p_a_ei.AEI_INFORMATION5,AEI_INFORMATION5),
	      --AEI_INFORMATION6 = nvl(p_a_ei.AEI_INFORMATION6,AEI_INFORMATION6),
		-----bug 2412656  Non Disclosure Agr.
                AEI_INFORMATION6 = decode(p_a_ei.information_type,'GHR_US_ASG_NON_SF52',
                              p_a_ei.AEI_INFORMATION6, nvl(p_a_ei.AEI_INFORMATION6,AEI_INFORMATION6)),
		AEI_INFORMATION7 = nvl(p_a_ei.AEI_INFORMATION7,AEI_INFORMATION7),
  	        --AEI_INFORMATION8 = nvl(p_a_ei.AEI_INFORMATION8,AEI_INFORMATION8),
		-----bug 2412656  Part time Indicator and Part Time Hrs
		AEI_INFORMATION8 = decode(p_a_ei.information_type,'GHR_US_ASG_NON_SF52',
                              p_a_ei.AEI_INFORMATION8,'GHR_US_ASG_SF52',
                              p_a_ei.AEI_INFORMATION8, nvl(p_a_ei.AEI_INFORMATION8,AEI_INFORMATION8)),
		AEI_INFORMATION9 = nvl(p_a_ei.AEI_INFORMATION9,AEI_INFORMATION9),
		AEI_INFORMATION10 = nvl(p_a_ei.AEI_INFORMATION10,AEI_INFORMATION10),
		AEI_INFORMATION11 = nvl(p_a_ei.AEI_INFORMATION11,AEI_INFORMATION11),
		AEI_INFORMATION12 = nvl(p_a_ei.AEI_INFORMATION12,AEI_INFORMATION12),
		AEI_INFORMATION13 = nvl(p_a_ei.AEI_INFORMATION13,AEI_INFORMATION13),
		AEI_INFORMATION14 = nvl(p_a_ei.AEI_INFORMATION14,AEI_INFORMATION14),
		AEI_INFORMATION15 = nvl(p_a_ei.AEI_INFORMATION15,AEI_INFORMATION15),
		AEI_INFORMATION16 = nvl(p_a_ei.AEI_INFORMATION16,AEI_INFORMATION16),
		AEI_INFORMATION17 = nvl(p_a_ei.AEI_INFORMATION17,AEI_INFORMATION17),
		AEI_INFORMATION18 = nvl(p_a_ei.AEI_INFORMATION18,AEI_INFORMATION18),
		AEI_INFORMATION19 = nvl(p_a_ei.AEI_INFORMATION19,AEI_INFORMATION19),
		AEI_INFORMATION20 = nvl(p_a_ei.AEI_INFORMATION20,AEI_INFORMATION20),
		AEI_INFORMATION21 = nvl(p_a_ei.AEI_INFORMATION21,AEI_INFORMATION21),
		AEI_INFORMATION22 = nvl(p_a_ei.AEI_INFORMATION22,AEI_INFORMATION22),
		AEI_INFORMATION23 = nvl(p_a_ei.AEI_INFORMATION23,AEI_INFORMATION23),
		AEI_INFORMATION24 = nvl(p_a_ei.AEI_INFORMATION24,AEI_INFORMATION24),
		AEI_INFORMATION25 = nvl(p_a_ei.AEI_INFORMATION25,AEI_INFORMATION25),
		AEI_INFORMATION26 = nvl(p_a_ei.AEI_INFORMATION26,AEI_INFORMATION26),
		AEI_INFORMATION27 = nvl(p_a_ei.AEI_INFORMATION27,AEI_INFORMATION27),
		AEI_INFORMATION28 = nvl(p_a_ei.AEI_INFORMATION28,AEI_INFORMATION28),
		AEI_INFORMATION29 = nvl(p_a_ei.AEI_INFORMATION29,AEI_INFORMATION29),
		AEI_INFORMATION30 = nvl(p_a_ei.AEI_INFORMATION30,AEI_INFORMATION30),
		info4_meaning = nvl(l_info4_meaning,info4_meaning),
		info5_meaning = nvl(l_info5_meaning,info5_meaning),
		--info6_meaning = nvl(l_info6_meaning,info6_meaning),
		-----bug 2412656  Non Disclosure Agr.
		info6_meaning = decode(p_a_ei.information_type,'GHR_US_ASG_NON_SF52',
                           l_info6_meaning, nvl(l_info6_meaning,info6_meaning)),
		info7_meaning = nvl(l_info7_meaning,info7_meaning),
		--info8_meaning = nvl(l_info8_meaning,info8_meaning)
		-----bug 2412656  Part time Indicator
		info8_meaning = decode(p_a_ei.information_type,'GHR_US_ASG_NON_SF52',
                           l_info8_meaning, nvl(l_info8_meaning,info8_meaning))
	where current of cur_assignment_ei;

	close cur_assignment_ei;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure  insert_position(p_transfer_name  varchar2,
								   p_person_id		  number,
									p_effective_date date,
									p_pos				  hr_all_positions_f%rowtype)
is

	l_proc			varchar2(72) := g_package||'insert_position';
	l_table_name	constant varchar2(30) := 'PER_POSITIONS';
	l_name			varchar2(30);

begin

	put('insert position');

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line(' - called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> p_person_id
				,p_table_name			=> l_table_name) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line(' - called locally');
	end if;

	insert into ghr_mt_positions_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		POSITION_ID,
		BUSINESS_GROUP_ID,
		JOB_ID,
		ORGANIZATION_ID,
		SUCCESSOR_POSITION_ID,
		RELIEF_POSITION_ID,
		LOCATION_ID,
		POSITION_DEFINITION_ID,
		DATE_EFFECTIVE,
		COMMENTS,
		DATE_END,
		FREQUENCY,
		NAME,
		PROBATION_PERIOD,
		PROBATION_PERIOD_UNITS,
		REPLACEMENT_REQUIRED_FLAG,
		TIME_NORMAL_FINISH,
		TIME_NORMAL_START,
		WORKING_HOURS,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		ATTRIBUTE16,
		ATTRIBUTE17,
		ATTRIBUTE18,
		ATTRIBUTE19,
		ATTRIBUTE20,
		OBJECT_VERSION_NUMBER,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATION_DATE,
		STATUS
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,									-- MT_STATUS,
		p_person_id,						-- MT_PERSON_ID,
		l_table_name,						-- MT_TABLE_NAME,
		null,									-- MT_INFORMATION_TYPE,
		null,									-- MT_INTER_BG_TRANSFER
		p_pos.POSITION_ID,
		p_pos.BUSINESS_GROUP_ID,
		p_pos.JOB_ID,
		p_pos.ORGANIZATION_ID,
		p_pos.SUCCESSOR_POSITION_ID,
		p_pos.RELIEF_POSITION_ID,
		p_pos.LOCATION_ID,
		p_pos.POSITION_DEFINITION_ID,
		to_char(p_pos.DATE_EFFECTIVE,g_datefmt),
		p_pos.COMMENTS,
		to_char(p_pos.DATE_END,g_datefmt),
		p_pos.FREQUENCY,
		p_pos.NAME,
		p_pos.PROBATION_PERIOD,
		p_pos.PROBATION_PERIOD_UNIT_CD,
		p_pos.REPLACEMENT_REQUIRED_FLAG,
		p_pos.TIME_NORMAL_FINISH,
		p_pos.TIME_NORMAL_START,
		p_pos.WORKING_HOURS,
		p_pos.REQUEST_ID,
		p_pos.PROGRAM_APPLICATION_ID,
		p_pos.PROGRAM_ID,
		to_char(p_pos.PROGRAM_UPDATE_DATE,g_datefmt),
		p_pos.ATTRIBUTE_CATEGORY,
		p_pos.ATTRIBUTE1,
		p_pos.ATTRIBUTE2,
		p_pos.ATTRIBUTE3,
		p_pos.ATTRIBUTE4,
		p_pos.ATTRIBUTE5,
		p_pos.ATTRIBUTE6,
		p_pos.ATTRIBUTE7,
		p_pos.ATTRIBUTE8,
		p_pos.ATTRIBUTE9,
		p_pos.ATTRIBUTE10,
		p_pos.ATTRIBUTE11,
		p_pos.ATTRIBUTE12,
		p_pos.ATTRIBUTE13,
		p_pos.ATTRIBUTE14,
		p_pos.ATTRIBUTE15,
		p_pos.ATTRIBUTE16,
		p_pos.ATTRIBUTE17,
		p_pos.ATTRIBUTE18,
		p_pos.ATTRIBUTE19,
		p_pos.ATTRIBUTE20,
		p_pos.OBJECT_VERSION_NUMBER,
		to_char(p_pos.LAST_UPDATE_DATE,g_datefmt),
		p_pos.LAST_UPDATED_BY,
		p_pos.LAST_UPDATE_LOGIN,
		p_pos.CREATED_BY,
		to_char(p_pos.CREATION_DATE,g_datefmt),
		p_pos.STATUS
	);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure  update_position(p_transfer_name  varchar2,
								   p_person_id		  number,
									p_effective_date date,
									p_pos				  hr_all_positions_f%rowtype)
is

	l_proc			varchar2(72) := g_package||'update_position';
	l_x				varchar2(1);

	cursor cur_position is
		select 'x'
		from ghr_mt_positions_v
		where mt_name = p_transfer_name
		and mt_person_id = to_char(p_person_id)
		for update;

begin

	put_line('update position');

	open cur_position;
	fetch cur_position into l_x;

	if cur_position%notfound then
		close cur_position;
		hr_utility.set_message(8301, 'GHR_38549_UPDATE_NOT_FOUND');
		hr_utility.raise_error;
	end if;

	update ghr_mt_positions_v
	set
		MT_EFFECTIVE_DATE = p_effective_date,
		POSITION_ID = nvl(p_pos.POSITION_ID,POSITION_ID),
		BUSINESS_GROUP_ID = nvl(p_pos.BUSINESS_GROUP_ID,BUSINESS_GROUP_ID),
		JOB_ID = nvl(p_pos.JOB_ID,JOB_ID),
		ORGANIZATION_ID = nvl(p_pos.ORGANIZATION_ID,ORGANIZATION_ID),
		SUCCESSOR_POSITION_ID =
				nvl(p_pos.SUCCESSOR_POSITION_ID,SUCCESSOR_POSITION_ID),
		RELIEF_POSITION_ID = nvl(p_pos.RELIEF_POSITION_ID,RELIEF_POSITION_ID),
		LOCATION_ID = nvl(p_pos.LOCATION_ID,LOCATION_ID),
		POSITION_DEFINITION_ID =
				nvl(p_pos.POSITION_DEFINITION_ID,POSITION_DEFINITION_ID),
		DATE_EFFECTIVE = nvl(to_char(p_pos.DATE_EFFECTIVE,g_datefmt),
				DATE_EFFECTIVE),
		COMMENTS = nvl(p_pos.COMMENTS,COMMENTS),
		DATE_END = nvl(to_char(p_pos.DATE_END,g_datefmt),DATE_END),
		FREQUENCY = nvl(p_pos.FREQUENCY,FREQUENCY),
		NAME = nvl(p_pos.NAME,NAME),
		PROBATION_PERIOD = nvl(p_pos.PROBATION_PERIOD,PROBATION_PERIOD),
		PROBATION_PERIOD_UNITS =
				nvl(p_pos.PROBATION_PERIOD_UNIT_CD,PROBATION_PERIOD_UNITS),
		REPLACEMENT_REQUIRED_FLAG =
				nvl(p_pos.REPLACEMENT_REQUIRED_FLAG,REPLACEMENT_REQUIRED_FLAG),
		TIME_NORMAL_FINISH = nvl(p_pos.TIME_NORMAL_FINISH,TIME_NORMAL_FINISH),
		TIME_NORMAL_START = nvl(p_pos.TIME_NORMAL_START,TIME_NORMAL_START),
		WORKING_HOURS = nvl(p_pos.WORKING_HOURS,WORKING_HOURS),
		REQUEST_ID = nvl(p_pos.REQUEST_ID,REQUEST_ID),
		PROGRAM_APPLICATION_ID =
				nvl(p_pos.PROGRAM_APPLICATION_ID,PROGRAM_APPLICATION_ID),
		PROGRAM_ID = nvl(p_pos.PROGRAM_ID,PROGRAM_ID),
		PROGRAM_UPDATE_DATE =
				nvl(to_char(p_pos.PROGRAM_UPDATE_DATE,g_datefmt),
				PROGRAM_UPDATE_DATE),
		ATTRIBUTE_CATEGORY = nvl(p_pos.ATTRIBUTE_CATEGORY,ATTRIBUTE_CATEGORY),
		ATTRIBUTE1 = nvl(p_pos.ATTRIBUTE1,ATTRIBUTE1),
		ATTRIBUTE2 = nvl(p_pos.ATTRIBUTE2,ATTRIBUTE2),
		ATTRIBUTE3 = nvl(p_pos.ATTRIBUTE3,ATTRIBUTE3),
		ATTRIBUTE4 = nvl(p_pos.ATTRIBUTE4,ATTRIBUTE4),
		ATTRIBUTE5 = nvl(p_pos.ATTRIBUTE5,ATTRIBUTE5),
		ATTRIBUTE6 = nvl(p_pos.ATTRIBUTE6,ATTRIBUTE6),
		ATTRIBUTE7 = nvl(p_pos.ATTRIBUTE7,ATTRIBUTE7),
		ATTRIBUTE8 = nvl(p_pos.ATTRIBUTE8,ATTRIBUTE8),
		ATTRIBUTE9 = nvl(p_pos.ATTRIBUTE9,ATTRIBUTE9),
		ATTRIBUTE10 = nvl(p_pos.ATTRIBUTE10,ATTRIBUTE10),
		ATTRIBUTE11 = nvl(p_pos.ATTRIBUTE11,ATTRIBUTE11),
		ATTRIBUTE12 = nvl(p_pos.ATTRIBUTE12,ATTRIBUTE12),
		ATTRIBUTE13 = nvl(p_pos.ATTRIBUTE13,ATTRIBUTE13),
		ATTRIBUTE14 = nvl(p_pos.ATTRIBUTE14,ATTRIBUTE14),
		ATTRIBUTE15 = nvl(p_pos.ATTRIBUTE15,ATTRIBUTE15),
		ATTRIBUTE16 = nvl(p_pos.ATTRIBUTE16,ATTRIBUTE16),
		ATTRIBUTE17 = nvl(p_pos.ATTRIBUTE17,ATTRIBUTE17),
		ATTRIBUTE18 = nvl(p_pos.ATTRIBUTE18,ATTRIBUTE18),
		ATTRIBUTE19 = nvl(p_pos.ATTRIBUTE19,ATTRIBUTE19),
		ATTRIBUTE20 = nvl(p_pos.ATTRIBUTE20,ATTRIBUTE20),
		STATUS = nvl(p_pos.STATUS,STATUS)
	where current of cur_position;

	close cur_position;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure insert_position_ei(p_transfer_name		varchar2,
								    p_person_id			number,
							       p_effective_date		date,
								    p_pos_ei		per_position_extra_info%rowtype)
is

	l_proc			varchar2(72) := g_package||'insert_position_ei';

	l_info3_meaning	varchar2(80) := null;
	l_info7_meaning	varchar2(80) := null;
	l_info8_meaning	varchar2(80) := null;
	l_info11_meaning	varchar2(80) := null;
	l_info12_meaning	varchar2(80) := null;
	l_info13_meaning	varchar2(80) := null;
	l_info14_meaning	varchar2(80) := null;
	l_info16_meaning	varchar2(80) := null;

	l_table_name	constant varchar2(30) := 'PER_POSITION_EXTRA_INFO';
	l_name			varchar2(30);

begin

	put('insert position_ei');

	--
	-- check if p_pos_ei contains data, if not return
	--
	if p_pos_ei.information_type is null then
		put_line(' - no data');
		return;
	end if;
	put_line(' - ok, info_type: '||p_pos_ei.information_type);

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line('Called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> p_person_id
				,p_table_name			=> l_table_name
				,p_info_type			=> p_pos_ei.information_type) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line('Called locally');
	end if;


	if p_pos_ei.information_type = 'GHR_US_POS_GRP1' then
		l_info7_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_FLSA_CATEGORY',
									p_lookup_code	=>	p_pos_ei.poei_information7);

		l_info8_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_BARG_UNIT_STATUS',
									p_lookup_code	=>	p_pos_ei.poei_information8);

		l_info11_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_FUNCTIONAL_CLASS',
									p_lookup_code	=>	p_pos_ei.poei_information11);

		l_info12_meaning := 	p_pos_ei.poei_information12;

		l_info16_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_SUPERVISORY_STATUS',
									p_lookup_code	=>	p_pos_ei.poei_information16);

	elsif p_pos_ei.information_type = 'GHR_US_POS_GRP2' then
		l_info3_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_POSITION_OCCUPIED',
									p_lookup_code	=>	p_pos_ei.poei_information3);

		l_info13_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_APPROPRIATION_CODE1',
									p_lookup_code	=>	p_pos_ei.poei_information13);

		l_info14_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_APPROPRIATION_CODE2',
									p_lookup_code	=>	p_pos_ei.poei_information14);


	end if;


	insert into ghr_mt_position_ei_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		POSITION_EXTRA_INFO_ID,
		POSITION_ID,
		INFORMATION_TYPE,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		POEI_ATTRIBUTE_CATEGORY,
		POEI_ATTRIBUTE1,
		POEI_ATTRIBUTE2,
		POEI_ATTRIBUTE3,
		POEI_ATTRIBUTE4,
		POEI_ATTRIBUTE5,
		POEI_ATTRIBUTE6,
		POEI_ATTRIBUTE7,
		POEI_ATTRIBUTE8,
		POEI_ATTRIBUTE9,
		POEI_ATTRIBUTE10,
		POEI_ATTRIBUTE11,
		POEI_ATTRIBUTE12,
		POEI_ATTRIBUTE13,
		POEI_ATTRIBUTE14,
		POEI_ATTRIBUTE15,
		POEI_ATTRIBUTE16,
		POEI_ATTRIBUTE17,
		POEI_ATTRIBUTE18,
		POEI_ATTRIBUTE19,
		POEI_ATTRIBUTE20,
		POEI_INFORMATION_CATEGORY,
		POEI_INFORMATION1,
		POEI_INFORMATION2,
		POEI_INFORMATION3,
		POEI_INFORMATION4,
		POEI_INFORMATION5,
		POEI_INFORMATION6,
		POEI_INFORMATION7,
		POEI_INFORMATION8,
		POEI_INFORMATION9,
		POEI_INFORMATION10,
		POEI_INFORMATION11,
		POEI_INFORMATION12,
		POEI_INFORMATION13,
		POEI_INFORMATION14,
		POEI_INFORMATION15,
		POEI_INFORMATION16,
		POEI_INFORMATION17,
		POEI_INFORMATION18,
		POEI_INFORMATION19,
		POEI_INFORMATION20,
		POEI_INFORMATION21,
		POEI_INFORMATION22,
		POEI_INFORMATION23,
		POEI_INFORMATION24,
		POEI_INFORMATION25,
		POEI_INFORMATION26,
		POEI_INFORMATION27,
		POEI_INFORMATION28,
		POEI_INFORMATION29,
		POEI_INFORMATION30,
		OBJECT_VERSION_NUMBER,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATION_DATE,
		info3_meaning,
		info7_meaning,
		info8_meaning,
		info11_meaning,
		info12_meaning,
		info13_meaning,
		info14_meaning,
		info16_meaning
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,									-- MT_STATUS,
		p_person_id,						-- MT_PERSON_ID,
		l_table_name,						-- MT_TABLE_NAME,
		p_pos_ei.information_type,		-- MT_INFORMATION_TYPE,
		null,									-- MT_INTER_BG_TRANSFER
		p_pos_ei.POSITION_EXTRA_INFO_ID,
		p_pos_ei.POSITION_ID,
		p_pos_ei.INFORMATION_TYPE,
		p_pos_ei.REQUEST_ID,
		p_pos_ei.PROGRAM_APPLICATION_ID,
		p_pos_ei.PROGRAM_ID,
		to_char(p_pos_ei.PROGRAM_UPDATE_DATE,g_datefmt),
		p_pos_ei.POEI_ATTRIBUTE_CATEGORY,
		p_pos_ei.POEI_ATTRIBUTE1,
		p_pos_ei.POEI_ATTRIBUTE2,
		p_pos_ei.POEI_ATTRIBUTE3,
		p_pos_ei.POEI_ATTRIBUTE4,
		p_pos_ei.POEI_ATTRIBUTE5,
		p_pos_ei.POEI_ATTRIBUTE6,
		p_pos_ei.POEI_ATTRIBUTE7,
		p_pos_ei.POEI_ATTRIBUTE8,
		p_pos_ei.POEI_ATTRIBUTE9,
		p_pos_ei.POEI_ATTRIBUTE10,
		p_pos_ei.POEI_ATTRIBUTE11,
		p_pos_ei.POEI_ATTRIBUTE12,
		p_pos_ei.POEI_ATTRIBUTE13,
		p_pos_ei.POEI_ATTRIBUTE14,
		p_pos_ei.POEI_ATTRIBUTE15,
		p_pos_ei.POEI_ATTRIBUTE16,
		p_pos_ei.POEI_ATTRIBUTE17,
		p_pos_ei.POEI_ATTRIBUTE18,
		p_pos_ei.POEI_ATTRIBUTE19,
		p_pos_ei.POEI_ATTRIBUTE20,
		p_pos_ei.POEI_INFORMATION_CATEGORY,
		p_pos_ei.POEI_INFORMATION1,
		p_pos_ei.POEI_INFORMATION2,
		p_pos_ei.POEI_INFORMATION3,
		p_pos_ei.POEI_INFORMATION4,
		p_pos_ei.POEI_INFORMATION5,
		p_pos_ei.POEI_INFORMATION6,
		p_pos_ei.POEI_INFORMATION7,
		p_pos_ei.POEI_INFORMATION8,
		p_pos_ei.POEI_INFORMATION9,
		p_pos_ei.POEI_INFORMATION10,
		p_pos_ei.POEI_INFORMATION11,
		p_pos_ei.POEI_INFORMATION12,
		p_pos_ei.POEI_INFORMATION13,
		p_pos_ei.POEI_INFORMATION14,
		p_pos_ei.POEI_INFORMATION15,
		p_pos_ei.POEI_INFORMATION16,
		p_pos_ei.POEI_INFORMATION17,
		p_pos_ei.POEI_INFORMATION18,
		p_pos_ei.POEI_INFORMATION19,
		p_pos_ei.POEI_INFORMATION20,
		p_pos_ei.POEI_INFORMATION21,
		p_pos_ei.POEI_INFORMATION22,
		p_pos_ei.POEI_INFORMATION23,
		p_pos_ei.POEI_INFORMATION24,
		p_pos_ei.POEI_INFORMATION25,
		p_pos_ei.POEI_INFORMATION26,
		p_pos_ei.POEI_INFORMATION27,
		p_pos_ei.POEI_INFORMATION28,
		p_pos_ei.POEI_INFORMATION29,
		p_pos_ei.POEI_INFORMATION30,
		p_pos_ei.OBJECT_VERSION_NUMBER,
		to_char(p_pos_ei.LAST_UPDATE_DATE,g_datefmt),
		p_pos_ei.LAST_UPDATED_BY,
		p_pos_ei.LAST_UPDATE_LOGIN,
		p_pos_ei.CREATED_BY,
		to_char(p_pos_ei.CREATION_DATE,g_datefmt),
		l_info3_meaning,
		l_info7_meaning,
		l_info8_meaning,
		l_info11_meaning,
		l_info12_meaning,
		l_info13_meaning,
		l_info14_meaning,
		l_info16_meaning
	);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure update_position_ei(p_transfer_name		varchar2,
								    p_person_id			number,
							       p_effective_date		date,
								    p_pos_ei		per_position_extra_info%rowtype)
is

	l_proc			varchar2(72) := g_package||'update_position_ei';
	l_x				varchar2(1);

	l_info3_meaning	varchar2(80) := null;
	l_info7_meaning	varchar2(80) := null;
	l_info8_meaning	varchar2(80) := null;
	l_info11_meaning	varchar2(80) := null;
	l_info12_meaning	varchar2(80) := null;
	l_info13_meaning	varchar2(80) := null;
	l_info14_meaning	varchar2(80) := null;
	l_info16_meaning	varchar2(80) := null;

	cursor cur_position_ei is
		select 'x'
		from ghr_mt_position_ei_v
		where mt_name = p_transfer_name
		and mt_person_id = to_char(p_person_id)
		and mt_information_type = p_pos_ei.information_type
		for update;

begin

	put_line('update position_ei');

	open cur_position_ei;
	fetch cur_position_ei into l_x;

	if cur_position_ei%notfound then
		put_line('update row not found - calling insert');
		close cur_position_ei;

		insert_position_ei(
			p_transfer_name		=> p_transfer_name,
		   p_person_id				=> p_person_id,
		   p_effective_date		=> p_effective_date,
		   p_pos_ei					=> p_pos_ei
		);

		return;
	end if;

	if p_pos_ei.information_type = 'GHR_US_POS_GRP1' then
		l_info7_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_FLSA_CATEGORY',
									p_lookup_code	=>	p_pos_ei.poei_information7);

		l_info8_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_BARG_UNIT_STATUS',
									p_lookup_code	=>	p_pos_ei.poei_information8);

		l_info11_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_FUNCTIONAL_CLASS',
									p_lookup_code	=>	p_pos_ei.poei_information11);

		l_info12_meaning := 	p_pos_ei.poei_information12;

		l_info16_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_SUPERVISORY_STATUS',
									p_lookup_code	=>	p_pos_ei.poei_information16);

	elsif p_pos_ei.information_type = 'GHR_US_POS_GRP2' then
		l_info3_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_POSITION_OCCUPIED',
									p_lookup_code	=>	p_pos_ei.poei_information3);

		l_info13_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_APPROPRIATION_CODE1',
									p_lookup_code	=>	p_pos_ei.poei_information13);

		l_info14_meaning := get_code_meaning (
									p_lookup_type	=> 'GHR_US_APPROPRIATION_CODE2',
									p_lookup_code	=>	p_pos_ei.poei_information14);


	end if;

	update ghr_mt_position_ei_v
	set
		MT_EFFECTIVE_DATE = p_effective_date,
		POSITION_EXTRA_INFO_ID =
				nvl(p_pos_ei.POSITION_EXTRA_INFO_ID,POSITION_EXTRA_INFO_ID),
		POSITION_ID = nvl(p_pos_ei.POSITION_ID,POSITION_ID),
		INFORMATION_TYPE = nvl(p_pos_ei.INFORMATION_TYPE,INFORMATION_TYPE),
		REQUEST_ID = nvl(p_pos_ei.REQUEST_ID,REQUEST_ID),
		PROGRAM_APPLICATION_ID =
				nvl(p_pos_ei.PROGRAM_APPLICATION_ID,PROGRAM_APPLICATION_ID),
		PROGRAM_ID = nvl(p_pos_ei.PROGRAM_ID,PROGRAM_ID),
		PROGRAM_UPDATE_DATE =
				nvl(to_char(p_pos_ei.PROGRAM_UPDATE_DATE,g_datefmt),
				PROGRAM_UPDATE_DATE),
		POEI_ATTRIBUTE_CATEGORY =
				nvl(p_pos_ei.POEI_ATTRIBUTE_CATEGORY,POEI_ATTRIBUTE_CATEGORY),
		POEI_ATTRIBUTE1 = nvl(p_pos_ei.POEI_ATTRIBUTE1,POEI_ATTRIBUTE1),
		POEI_ATTRIBUTE2 = nvl(p_pos_ei.POEI_ATTRIBUTE2,POEI_ATTRIBUTE2),
		POEI_ATTRIBUTE3 = nvl(p_pos_ei.POEI_ATTRIBUTE3,POEI_ATTRIBUTE3),
		POEI_ATTRIBUTE4 = nvl(p_pos_ei.POEI_ATTRIBUTE4,POEI_ATTRIBUTE4),
		POEI_ATTRIBUTE5 = nvl(p_pos_ei.POEI_ATTRIBUTE5,POEI_ATTRIBUTE5),
		POEI_ATTRIBUTE6 = nvl(p_pos_ei.POEI_ATTRIBUTE6,POEI_ATTRIBUTE6),
		POEI_ATTRIBUTE7 = nvl(p_pos_ei.POEI_ATTRIBUTE7,POEI_ATTRIBUTE7),
		POEI_ATTRIBUTE8 = nvl(p_pos_ei.POEI_ATTRIBUTE8,POEI_ATTRIBUTE8),
		POEI_ATTRIBUTE9 = nvl(p_pos_ei.POEI_ATTRIBUTE9,POEI_ATTRIBUTE9),
		POEI_ATTRIBUTE10 = nvl(p_pos_ei.POEI_ATTRIBUTE10,POEI_ATTRIBUTE10),
		POEI_ATTRIBUTE11 = nvl(p_pos_ei.POEI_ATTRIBUTE11,POEI_ATTRIBUTE11),
		POEI_ATTRIBUTE12 = nvl(p_pos_ei.POEI_ATTRIBUTE12,POEI_ATTRIBUTE12),
		POEI_ATTRIBUTE13 = nvl(p_pos_ei.POEI_ATTRIBUTE13,POEI_ATTRIBUTE13),
		POEI_ATTRIBUTE14 = nvl(p_pos_ei.POEI_ATTRIBUTE14,POEI_ATTRIBUTE14),
		POEI_ATTRIBUTE15 = nvl(p_pos_ei.POEI_ATTRIBUTE15,POEI_ATTRIBUTE15),
		POEI_ATTRIBUTE16 = nvl(p_pos_ei.POEI_ATTRIBUTE16,POEI_ATTRIBUTE16),
		POEI_ATTRIBUTE17 = nvl(p_pos_ei.POEI_ATTRIBUTE17,POEI_ATTRIBUTE17),
		POEI_ATTRIBUTE18 = nvl(p_pos_ei.POEI_ATTRIBUTE18,POEI_ATTRIBUTE18),
		POEI_ATTRIBUTE19 = nvl(p_pos_ei.POEI_ATTRIBUTE19,POEI_ATTRIBUTE19),
		POEI_ATTRIBUTE20 = nvl(p_pos_ei.POEI_ATTRIBUTE20,POEI_ATTRIBUTE20),
		POEI_INFORMATION_CATEGORY =
				nvl(p_pos_ei.POEI_INFORMATION_CATEGORY,POEI_INFORMATION_CATEGORY),
		POEI_INFORMATION1 = nvl(p_pos_ei.POEI_INFORMATION1,POEI_INFORMATION1),
		POEI_INFORMATION2 = nvl(p_pos_ei.POEI_INFORMATION2,POEI_INFORMATION2),
		POEI_INFORMATION3 = nvl(p_pos_ei.POEI_INFORMATION3,POEI_INFORMATION3),
		POEI_INFORMATION4 = nvl(p_pos_ei.POEI_INFORMATION4,POEI_INFORMATION4),
		POEI_INFORMATION5 = nvl(p_pos_ei.POEI_INFORMATION5,POEI_INFORMATION5),
		POEI_INFORMATION6 = nvl(p_pos_ei.POEI_INFORMATION6,POEI_INFORMATION6),
		POEI_INFORMATION7 = nvl(p_pos_ei.POEI_INFORMATION7,POEI_INFORMATION7),
		POEI_INFORMATION8 = nvl(p_pos_ei.POEI_INFORMATION8,POEI_INFORMATION8),
		POEI_INFORMATION9 = nvl(p_pos_ei.POEI_INFORMATION9,POEI_INFORMATION9),
		POEI_INFORMATION10 = nvl(p_pos_ei.POEI_INFORMATION10,POEI_INFORMATION10),
		POEI_INFORMATION11 = nvl(p_pos_ei.POEI_INFORMATION11,POEI_INFORMATION11),
		--POEI_INFORMATION12 = nvl(p_pos_ei.POEI_INFORMATION12,POEI_INFORMATION12),
		-----bug 2412656  Position Title
		POEI_INFORMATION12 = decode(p_pos_ei.information_type,'GHR_US_POS_GRP1',
                              p_pos_ei.POEI_INFORMATION12, nvl(p_pos_ei.POEI_INFORMATION12,POEI_INFORMATION12)),
		POEI_INFORMATION13 = nvl(p_pos_ei.POEI_INFORMATION13,POEI_INFORMATION13),
		POEI_INFORMATION14 = nvl(p_pos_ei.POEI_INFORMATION14,POEI_INFORMATION14),
		POEI_INFORMATION15 = nvl(p_pos_ei.POEI_INFORMATION15,POEI_INFORMATION15),
		POEI_INFORMATION16 = nvl(p_pos_ei.POEI_INFORMATION16,POEI_INFORMATION16),
		POEI_INFORMATION17 = nvl(p_pos_ei.POEI_INFORMATION17,POEI_INFORMATION17),
		POEI_INFORMATION18 = nvl(p_pos_ei.POEI_INFORMATION18,POEI_INFORMATION18),
		POEI_INFORMATION19 = nvl(p_pos_ei.POEI_INFORMATION19,POEI_INFORMATION19),
		POEI_INFORMATION20 = nvl(p_pos_ei.POEI_INFORMATION20,POEI_INFORMATION20),
		POEI_INFORMATION21 = nvl(p_pos_ei.POEI_INFORMATION21,POEI_INFORMATION21),
		POEI_INFORMATION22 = nvl(p_pos_ei.POEI_INFORMATION22,POEI_INFORMATION22),
		--POEI_INFORMATION23 = nvl(p_pos_ei.POEI_INFORMATION23,POEI_INFORMATION23),
		 --Part Time Hours
		POEI_INFORMATION23 = decode(p_pos_ei.information_type,'GHR_US_POS_GRP1',
                              p_pos_ei.POEI_INFORMATION23, nvl(p_pos_ei.POEI_INFORMATION23,POEI_INFORMATION23)),
		POEI_INFORMATION24 = nvl(p_pos_ei.POEI_INFORMATION24,POEI_INFORMATION24),
		POEI_INFORMATION25 = nvl(p_pos_ei.POEI_INFORMATION25,POEI_INFORMATION25),
		POEI_INFORMATION26 = nvl(p_pos_ei.POEI_INFORMATION26,POEI_INFORMATION26),
		POEI_INFORMATION27 = nvl(p_pos_ei.POEI_INFORMATION27,POEI_INFORMATION27),
		POEI_INFORMATION28 = nvl(p_pos_ei.POEI_INFORMATION28,POEI_INFORMATION28),
		POEI_INFORMATION29 = nvl(p_pos_ei.POEI_INFORMATION29,POEI_INFORMATION29),
		POEI_INFORMATION30 = nvl(p_pos_ei.POEI_INFORMATION30,POEI_INFORMATION30),
		info3_meaning = nvl(l_info3_meaning,info3_meaning),
		info7_meaning = nvl(l_info7_meaning,info7_meaning),
		info8_meaning = nvl(l_info8_meaning,info8_meaning),
		info11_meaning = nvl(l_info11_meaning,info11_meaning),
		--info12_meaning = nvl(l_info12_meaning,info12_meaning),
		-----bug 2412656  Position Title
                info12_meaning = decode(p_pos_ei.information_type,'GHR_US_POS_GRP1',
                           l_info12_meaning, nvl(l_info12_meaning,info12_meaning)),
		info13_meaning = nvl(l_info13_meaning,info13_meaning),
		info14_meaning = nvl(l_info14_meaning,info14_meaning),
		info16_meaning = nvl(l_info16_meaning,info16_meaning)
	where current of cur_position_ei;

	close cur_position_ei;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;


procedure insert_position_defs(p_transfer_name		varchar2,
										 p_effective_date		date,
								  		 p_person_id			number,
										 p_flex_name			varchar2,
								  		 p_pos_defs per_position_definitions%rowtype)
is

	l_proc			varchar2(72) := g_package||'insert_position_defs';
	l_table_name	constant varchar2(30) := 'PER_POSITION_DEFINITIONS';
	l_name			varchar2(30);

begin

	put_line('insert position_defs -'||p_flex_name);

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line('Called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> p_person_id
				,p_table_name			=> l_table_name
				,p_info_type			=> p_flex_name) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line('Called locally');
	end if;

	insert into ghr_mt_position_definitions_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		POSITION_DEFINITION_ID,
		ID_FLEX_NUM,
		SUMMARY_FLAG,
		ENABLED_FLAG,
		START_DATE_ACTIVE,
		END_DATE_ACTIVE,
		SEGMENT1,
		SEGMENT2,
		SEGMENT3,
		SEGMENT4,
		SEGMENT5,
		SEGMENT6,
		SEGMENT7,
		SEGMENT8,
		SEGMENT9,
		SEGMENT10,
		SEGMENT11,
		SEGMENT12,
		SEGMENT13,
		SEGMENT14,
		SEGMENT15,
		SEGMENT16,
		SEGMENT17,
		SEGMENT18,
		SEGMENT19,
		SEGMENT20,
		SEGMENT21,
		SEGMENT22,
		SEGMENT23,
		SEGMENT24,
		SEGMENT25,
		SEGMENT26,
		SEGMENT27,
		SEGMENT28,
		SEGMENT29,
		SEGMENT30,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATION_DATE
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,									-- MT_STATUS,
		p_person_id,						-- MT_PERSON_ID,
		l_table_name,						-- MT_TABLE_NAME,
		p_flex_name,						-- MT_INFORMATION_TYPE,
		null,									-- MT_INTER_BG_TRANSFER
		p_pos_defs.POSITION_DEFINITION_ID,
		p_pos_defs.ID_FLEX_NUM,
		p_pos_defs.SUMMARY_FLAG,
		p_pos_defs.ENABLED_FLAG,
		to_char(p_pos_defs.START_DATE_ACTIVE,g_datefmt),
		to_char(p_pos_defs.END_DATE_ACTIVE,g_datefmt),
		p_pos_defs.SEGMENT1,
		p_pos_defs.SEGMENT2,
		p_pos_defs.SEGMENT3,
		p_pos_defs.SEGMENT4,
		p_pos_defs.SEGMENT5,
		p_pos_defs.SEGMENT6,
		p_pos_defs.SEGMENT7,
		p_pos_defs.SEGMENT8,
		p_pos_defs.SEGMENT9,
		p_pos_defs.SEGMENT10,
		p_pos_defs.SEGMENT11,
		p_pos_defs.SEGMENT12,
		p_pos_defs.SEGMENT13,
		p_pos_defs.SEGMENT14,
		p_pos_defs.SEGMENT15,
		p_pos_defs.SEGMENT16,
		p_pos_defs.SEGMENT17,
		p_pos_defs.SEGMENT18,
		p_pos_defs.SEGMENT19,
		p_pos_defs.SEGMENT20,
		p_pos_defs.SEGMENT21,
		p_pos_defs.SEGMENT22,
		p_pos_defs.SEGMENT23,
		p_pos_defs.SEGMENT24,
		p_pos_defs.SEGMENT25,
		p_pos_defs.SEGMENT26,
		p_pos_defs.SEGMENT27,
		p_pos_defs.SEGMENT28,
		p_pos_defs.SEGMENT29,
		p_pos_defs.SEGMENT30,
		to_char(p_pos_defs.LAST_UPDATE_DATE,g_datefmt),
		p_pos_defs.LAST_UPDATED_BY,
		p_pos_defs.LAST_UPDATE_LOGIN,
		p_pos_defs.CREATED_BY,
		to_char(p_pos_defs.CREATION_DATE,g_datefmt)
	);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure update_position_defs(p_transfer_name		varchar2,
										 p_effective_date		date,
								  		 p_person_id			number,
										 p_flex_name			varchar2,
								  		 p_pos_defs per_position_definitions%rowtype)
is

	l_proc			varchar2(72) := g_package||'update_position_defs';
	l_x				varchar2(1);

	cursor cur_pos_defs is
	select 'x'
	from ghr_mt_position_definitions_v
	where mt_name = p_transfer_name
	and mt_person_id = to_char(p_person_id)
	and mt_information_type = p_flex_name
	for update;

begin

	put_line('update position_defs -'||p_flex_name);

	open cur_pos_defs;
	fetch cur_pos_defs into l_x;

	if cur_pos_defs%notfound then
		put_line('update row not found - calling insert');
		close cur_pos_defs;

		insert_position_defs(
					p_transfer_name		=> p_transfer_name,
				   p_effective_date		=> p_effective_date,
					p_person_id				=> p_person_id,
					p_flex_name				=> p_flex_name,
					p_pos_defs 				=> p_pos_defs
		);

		return;
	end if;

	update ghr_mt_position_definitions_v
	set
		MT_EFFECTIVE_DATE = p_effective_date,
		POSITION_DEFINITION_ID =
				nvl(p_pos_defs.POSITION_DEFINITION_ID,POSITION_DEFINITION_ID),
		ID_FLEX_NUM = nvl(p_pos_defs.ID_FLEX_NUM,ID_FLEX_NUM),
		SUMMARY_FLAG = nvl(p_pos_defs.SUMMARY_FLAG,SUMMARY_FLAG),
		ENABLED_FLAG = nvl(p_pos_defs.ENABLED_FLAG,ENABLED_FLAG),
		START_DATE_ACTIVE =
				nvl(to_char(p_pos_defs.START_DATE_ACTIVE,g_datefmt),
				START_DATE_ACTIVE),
		END_DATE_ACTIVE =
				nvl(to_char(p_pos_defs.END_DATE_ACTIVE,g_datefmt),END_DATE_ACTIVE),
		SEGMENT1 = nvl(p_pos_defs.SEGMENT1,SEGMENT1),
		SEGMENT2 = nvl(p_pos_defs.SEGMENT2,SEGMENT2),
		SEGMENT3 = nvl(p_pos_defs.SEGMENT3,SEGMENT3),
		SEGMENT4 = nvl(p_pos_defs.SEGMENT4,SEGMENT4),
		SEGMENT5 = nvl(p_pos_defs.SEGMENT5,SEGMENT5),
		SEGMENT6 = nvl(p_pos_defs.SEGMENT6,SEGMENT6),
		SEGMENT7 = nvl(p_pos_defs.SEGMENT7,SEGMENT7),
		SEGMENT8 = nvl(p_pos_defs.SEGMENT8,SEGMENT8),
		SEGMENT9 = nvl(p_pos_defs.SEGMENT9,SEGMENT9),
		SEGMENT10 = nvl(p_pos_defs.SEGMENT10,SEGMENT10),
		SEGMENT11 = nvl(p_pos_defs.SEGMENT11,SEGMENT11),
		SEGMENT12 = nvl(p_pos_defs.SEGMENT12,SEGMENT12),
		SEGMENT13 = nvl(p_pos_defs.SEGMENT13,SEGMENT13),
		SEGMENT14 = nvl(p_pos_defs.SEGMENT14,SEGMENT14),
		SEGMENT15 = nvl(p_pos_defs.SEGMENT15,SEGMENT15),
		SEGMENT16 = nvl(p_pos_defs.SEGMENT16,SEGMENT16),
		SEGMENT17 = nvl(p_pos_defs.SEGMENT17,SEGMENT17),
		SEGMENT18 = nvl(p_pos_defs.SEGMENT18,SEGMENT18),
		SEGMENT19 = nvl(p_pos_defs.SEGMENT19,SEGMENT19),
		SEGMENT20 = nvl(p_pos_defs.SEGMENT20,SEGMENT20),
		SEGMENT21 = nvl(p_pos_defs.SEGMENT21,SEGMENT21),
		SEGMENT22 = nvl(p_pos_defs.SEGMENT22,SEGMENT22),
		SEGMENT23 = nvl(p_pos_defs.SEGMENT23,SEGMENT23),
		SEGMENT24 = nvl(p_pos_defs.SEGMENT24,SEGMENT24),
		SEGMENT25 = nvl(p_pos_defs.SEGMENT25,SEGMENT25),
		SEGMENT26 = nvl(p_pos_defs.SEGMENT26,SEGMENT26),
		SEGMENT27 = nvl(p_pos_defs.SEGMENT27,SEGMENT27),
		SEGMENT28 = nvl(p_pos_defs.SEGMENT28,SEGMENT28),
		SEGMENT29 = nvl(p_pos_defs.SEGMENT29,SEGMENT29),
		SEGMENT30 = nvl(p_pos_defs.SEGMENT30,SEGMENT30)
	where current of cur_pos_defs;

	close cur_pos_defs;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure insert_element_entries(
					 p_transfer_name		varchar2,
					 p_person_id			number,
					 p_effective_date		date,
					 p_element				in out nocopy ghr_mt_element_entries_v%rowtype)
is

	l_proc			varchar2(72) := g_package||'insert_element_entries';
	l_fegli_meaning				hr_lookups.meaning%type;
	l_retirement_plan_meaning	hr_lookups.meaning%type;
	l_table_name	constant varchar2(30) := 'PER_ELEMENT_ENTRIES';
	l_name			varchar2(30);

begin

	put('insert element entries');

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line(' - called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> p_person_id
				,p_table_name			=> l_table_name) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line(' - called locally');
	end if;

	l_fegli_meaning := get_code_meaning (
								p_lookup_type	=> 'GHR_US_FEGLI',
								p_lookup_code	=>	p_element.fegli);

	l_retirement_plan_meaning := get_code_meaning (
								p_lookup_type	=> 'GHR_US_RETIREMENT_PLAN',
								p_lookup_code	=>	p_element.retirement_plan);

	insert into ghr_mt_element_entries_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		TOTAL_SALARY,
		SALARY,
		LOCALITY_ADJUSTMENT,
		ADJUSTED_PAY,
		OTHER_PAY,
		FEGLI,
		ELIGIBILITY_EXPIRATION,
		RETIREMENT_PLAN,
		RETENTION_ALLOWANCE,
      TO_RETENTION_ALLOW_PERCENTAGE,
		STAFFING_DIFFERENTIAL,
      TO_STAFFING_DIFF_PERCENTAGE,
		SUPERVISORY_DIFFERENTIAL,
      TO_SUPERVISORY_DIFF_PERCENTAGE,
      AUO_AMOUNT,
      AUO_PREMIUM_PAY_IND,
      AP_AMOUNT,
      AP_PREMIUM_PAY_IND,
		ENROLLMENT,
		HEALTH_PLAN,
		TEMPS_TOTAL_COST,
		TSP_AMOUNT,
		TSP_RATE,
		TSP_G_FUND,
		TSP_F_FUND,
		TSP_C_FUND,
		TSP_STATUS,
		TSP_STATUS_DATE,
		TSP_ELIGIBILITY_DATE,
		WGI_STATUS,
		WGI_DATE_DUE,
		WGI_LAST_INCREASE_DATE,
		WGI_POSTPONMT_EFFECTIVE,
		WGI_POSTPONMT_DETERM_DUE,
		fegli_meaning,
		retirement_plan_meaning,
		to_basic_salary_rate,
		TO_ADJUSTED_BASIC_PAY,
		TO_TOTAL_SALARY
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,									-- MT_STATUS,
		p_person_id,						-- MT_PERSON_ID,
		l_table_name,						-- MT_TABLE_NAME,
		null,									-- MT_INFORMATION_TYPE,
		null,									-- MT_INTER_BG_TRANSFER
		p_element.TOTAL_SALARY,
		p_element.SALARY,
		p_element.LOCALITY_ADJUSTMENT,
		p_element.ADJUSTED_PAY,
		p_element.OTHER_PAY,
		p_element.FEGLI,
		p_element.ELIGIBILITY_EXPIRATION,
		p_element.RETIREMENT_PLAN,
		p_element.RETENTION_ALLOWANCE,
		p_element.TO_RETENTION_ALLOW_PERCENTAGE,
		p_element.STAFFING_DIFFERENTIAL,
		p_element.TO_STAFFING_DIFF_PERCENTAGE,
		p_element.SUPERVISORY_DIFFERENTIAL,
	        p_element.TO_SUPERVISORY_DIFF_PERCENTAGE,
	        p_element.AUO_AMOUNT,
	        p_element.AUO_PREMIUM_PAY_IND,
  		p_element.AP_AMOUNT,
	        p_element.AP_PREMIUM_PAY_IND,
		p_element.ENROLLMENT,
		p_element.HEALTH_PLAN,
		p_element.TEMPS_TOTAL_COST,
		p_element.TSP_AMOUNT,
		p_element.TSP_RATE,
		p_element.TSP_G_FUND,
		p_element.TSP_F_FUND,
		p_element.TSP_C_FUND,
		p_element.TSP_STATUS,
		p_element.TSP_STATUS_DATE,
		p_element.TSP_ELIGIBILITY_DATE,
		p_element.WGI_STATUS,
		p_element.WGI_DATE_DUE,
		p_element.WGI_LAST_INCREASE_DATE,
		p_element.WGI_POSTPONMT_EFFECTIVE,
		p_element.WGI_POSTPONMT_DETERM_DUE,
		l_fegli_meaning,
		l_retirement_plan_meaning,
		-- Changes 4093771
		p_element.TO_BASIC_SALARY_RATE,
		p_element.TO_ADJUSTED_BASIC_PAY,
		p_element.TO_TOTAL_SALARY
		-- End changes 4093771
	);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure update_element_entries(
					 p_transfer_name		varchar2,
					 p_person_id			number,
					 p_effective_date		date,
					 p_element in out nocopy ghr_mt_element_entries_v%rowtype)
is

	l_proc			varchar2(72) := g_package||'update_element_entries';
	l_fegli_meaning				hr_lookups.meaning%type;
	l_retirement_plan_meaning	hr_lookups.meaning%type;
	l_x								varchar2(1);

	cursor cur_elements is
	select 'x'
	from ghr_mt_element_entries_v
	where mt_name = p_transfer_name
	and mt_person_id = to_char(p_person_id)
	for update;

begin

	put_line('update element entries');

	put_line('update element entries - basic' || p_element.TO_BASIC_SALARY_RATE);
	put_line('update element entries - TO_TOTAL_SALARY' || p_element.TO_TOTAL_SALARY);
	put_line('update element entries - TO_ADJUSTED_BASIC_PAY' || p_element.TO_ADJUSTED_BASIC_PAY);

	open cur_elements;
	fetch cur_elements into l_x;

	if cur_elements%notfound then
		put_line('update row not found - calling insert');
		close cur_elements;

		insert_element_entries(
			   p_transfer_name		=> p_transfer_name,
				p_person_id				=> p_person_id,
				p_effective_date		=> p_effective_date,
				p_element				=> p_element
		);

		return;
	end if;

	l_fegli_meaning := get_code_meaning (
								p_lookup_type	=> 'GHR_US_FEGLI',
								p_lookup_code	=>	p_element.fegli);

	l_retirement_plan_meaning := get_code_meaning (
								p_lookup_type	=> 'GHR_US_RETIREMENT_PLAN',
								p_lookup_code	=>	p_element.retirement_plan);

	update ghr_mt_element_entries_v
	set
		MT_EFFECTIVE_DATE = p_effective_date,
		TOTAL_SALARY = nvl(p_element.TOTAL_SALARY,TOTAL_SALARY),
		SALARY = nvl(p_element.SALARY,SALARY),
		LOCALITY_ADJUSTMENT =
				nvl(p_element.LOCALITY_ADJUSTMENT,LOCALITY_ADJUSTMENT),
		ADJUSTED_PAY = nvl(p_element.ADJUSTED_PAY,ADJUSTED_PAY),
		OTHER_PAY = nvl(p_element.OTHER_PAY,OTHER_PAY),
		FEGLI = nvl(p_element.FEGLI,FEGLI),
		ELIGIBILITY_EXPIRATION =
				nvl(p_element.ELIGIBILITY_EXPIRATION,ELIGIBILITY_EXPIRATION),
		RETIREMENT_PLAN = nvl(p_element.RETIREMENT_PLAN,RETIREMENT_PLAN),
		RETENTION_ALLOWANCE =
				nvl(p_element.RETENTION_ALLOWANCE,RETENTION_ALLOWANCE),
		TO_RETENTION_ALLOW_PERCENTAGE =
            nvl(p_element.TO_RETENTION_ALLOW_PERCENTAGE,TO_RETENTION_ALLOW_PERCENTAGE),
		STAFFING_DIFFERENTIAL =
				nvl(p_element.STAFFING_DIFFERENTIAL,STAFFING_DIFFERENTIAL),
	      TO_STAFFING_DIFF_PERCENTAGE =
            nvl(p_element.TO_STAFFING_DIFF_PERCENTAGE,TO_STAFFING_DIFF_PERCENTAGE),
		SUPERVISORY_DIFFERENTIAL =
				nvl(p_element.SUPERVISORY_DIFFERENTIAL,SUPERVISORY_DIFFERENTIAL),
	      TO_SUPERVISORY_DIFF_PERCENTAGE =
            nvl(p_element.TO_SUPERVISORY_DIFF_PERCENTAGE,TO_SUPERVISORY_DIFF_PERCENTAGE),
	      AUO_AMOUNT =   nvl(p_element.AUO_AMOUNT,AUO_AMOUNT),
	      AUO_PREMIUM_PAY_IND =  nvl(p_element.AUO_PREMIUM_PAY_IND,AUO_PREMIUM_PAY_IND),
	      AP_AMOUNT =  nvl(p_element.AP_AMOUNT,AP_AMOUNT),
	      AP_PREMIUM_PAY_IND = nvl(p_element.AP_PREMIUM_PAY_IND,AP_PREMIUM_PAY_IND),
		ENROLLMENT = nvl(p_element.ENROLLMENT,ENROLLMENT),
		HEALTH_PLAN = nvl(p_element.HEALTH_PLAN,HEALTH_PLAN),
		TEMPS_TOTAL_COST = nvl(p_element.TEMPS_TOTAL_COST,TEMPS_TOTAL_COST),
		TSP_AMOUNT = nvl(p_element.TSP_AMOUNT,TSP_AMOUNT),
		TSP_RATE = nvl(p_element.TSP_RATE,TSP_RATE),
		TSP_G_FUND = nvl(p_element.TSP_G_FUND,TSP_G_FUND),
		TSP_F_FUND = nvl(p_element.TSP_F_FUND,TSP_F_FUND),
		TSP_C_FUND = nvl(p_element.TSP_C_FUND,TSP_C_FUND),
		TSP_STATUS = nvl(p_element.TSP_STATUS,TSP_STATUS),
		TSP_STATUS_DATE =
				nvl(p_element.TSP_STATUS_DATE,TSP_STATUS_DATE),
		TSP_ELIGIBILITY_DATE =
				nvl(p_element.TSP_ELIGIBILITY_DATE,TSP_ELIGIBILITY_DATE),
		WGI_STATUS = nvl(p_element.WGI_STATUS,WGI_STATUS),
		/*WGI_DATE_DUE =
				nvl(p_element.WGI_DATE_DUE,WGI_DATE_DUE),*/
                ---Bug 2412656 WGI element
		WGI_DATE_DUE = p_element.WGI_DATE_DUE,
		WGI_LAST_INCREASE_DATE =
				nvl(p_element.WGI_LAST_INCREASE_DATE, WGI_LAST_INCREASE_DATE),
		WGI_POSTPONMT_EFFECTIVE =
				nvl(p_element.WGI_POSTPONMT_EFFECTIVE,WGI_POSTPONMT_EFFECTIVE),
		WGI_POSTPONMT_DETERM_DUE =
				nvl(p_element.WGI_POSTPONMT_DETERM_DUE,WGI_POSTPONMT_DETERM_DUE),
		fegli_meaning = nvl(l_fegli_meaning,fegli_meaning),
		retirement_plan_meaning =
				nvl(l_retirement_plan_meaning,retirement_plan_meaning),
		TO_BASIC_SALARY_RATE = p_element.TO_BASIC_SALARY_RATE,
		TO_ADJUSTED_BASIC_PAY = p_element.TO_ADJUSTED_BASIC_PAY,
		TO_TOTAL_SALARY = p_element.TO_TOTAL_SALARY
	where current of cur_elements;

	close cur_elements;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure  insert_misc(p_transfer_name		varchar2,
							p_person_id				number,
							p_effective_date		date,
							p_misc					ghr_mt_misc_v%rowtype)
is

	l_proc			varchar2(72) := g_package||'insert_misc';
	l_table_name	constant varchar2(30) := 'MISCELANEOUS';
	l_name			varchar2(30);

	l_from_agency_code_desc varchar2(80);

begin

	put('insert misc');

	who_called_me(p_name	=> l_name);

	-- if this package body did NOT call this procedure then ckeck if
	-- the row to be inserted already exists, if so raise an error
	if nvl(l_name,'unknown') <> g_name then
		put_line(' - called by '|| l_name);
		if row_exists(
				p_transfer_name		=> p_transfer_name
				,p_person_id			=> p_person_id
				,p_table_name			=> l_table_name) then

			hr_utility.set_message(8301, 'GHR_38548_UNIQUE_CONSTRAINT');
			hr_utility.raise_error;
		end if;
	else
		put_line(' - called locally');
	end if;

	l_from_agency_code_desc := get_code_meaning (
								p_lookup_type	=> 'GHR_US_AGENCY_CODE',
								p_lookup_code	=>	p_misc.from_agency_code);

	insert into ghr_mt_misc_v (
		GHR_INTERFACE_ID,
		MT_PROCESS_DATE,
		MT_SOURCE,
		MT_EFFECTIVE_DATE,
		MT_NAME,
		MT_STATUS,
		MT_PERSON_ID,
		MT_TABLE_NAME,
		MT_INFORMATION_TYPE,
		MT_INTER_BG_TRANSFER,
		FROM_GRADE_OR_LEVEL,
		FROM_PAY_PLAN,
		FROM_POSITION_TITLE,
		FROM_POSITION_SEQ_NUM,
		FROM_POSITION_DESC_NUM,
		FROM_POSITION_ID,
		FROM_AGENCY_CODE,
		OCC_SERIES,
		TO_POSITION_ID,
		DUTY_STATION_DESC,
		DUTY_STATION_CODE,
		FROM_AGENCY_CODE_DESC
	)
	values (
		ghr_interface_s.nextval,
		sysdate,
		l_name,
		p_effective_date,
		p_transfer_name,
		null,									-- MT_STATUS,
		p_person_id,						-- MT_PERSON_ID,
		l_table_name,						-- MT_TABLE_NAME,
		null,									-- MT_INFORMATION_TYPE,
		null,									-- MT_INTER_BG_TRANSFER
		p_misc.FROM_GRADE_OR_LEVEL,
		p_misc.FROM_PAY_PLAN,
		p_misc.FROM_POSITION_TITLE,
		p_misc.FROM_POSITION_SEQ_NUM,
		p_misc.FROM_POSITION_DESC_NUM,
		p_misc.FROM_POSITION_ID,
		p_misc.FROM_AGENCY_CODE,
		p_misc.OCC_SERIES,
		p_misc.TO_POSITION_ID,
		p_misc.DUTY_STATION_DESC,
		p_misc.DUTY_STATION_CODE,
		l_from_agency_code_desc
	);

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;

procedure  update_misc(p_transfer_name		varchar2,
							p_person_id				number,
							p_effective_date		date,
							p_misc					ghr_mt_misc_v%rowtype)
is

	l_proc			varchar2(72) := g_package||'update_misc';
	l_x				varchar2(1);
	l_from_agency_code_desc	varchar2(80);

	cursor cur_misc  is
	select 'x'
	from ghr_mt_misc_v
	where mt_name = p_transfer_name
	and mt_person_id = to_char(p_person_id)
	for update;

begin

	put_line('update misc');

	open cur_misc;
	fetch cur_misc into l_x;

	if cur_misc%notfound then
		close cur_misc;
		hr_utility.set_message(8301, 'GHR_38549_UPDATE_NOT_FOUND');
		hr_utility.raise_error;
	end if;

	l_from_agency_code_desc := get_code_meaning (
								p_lookup_type	=> 'GHR_US_AGENCY_CODE',
								p_lookup_code	=>	p_misc.from_agency_code);

	update ghr_mt_misc_v
	set
		MT_EFFECTIVE_DATE = p_effective_date,
		FROM_GRADE_OR_LEVEL = nvl(p_misc.FROM_GRADE_OR_LEVEL,FROM_GRADE_OR_LEVEL),
		FROM_PAY_PLAN = nvl(p_misc.FROM_PAY_PLAN,FROM_PAY_PLAN),
		FROM_POSITION_TITLE = nvl(p_misc.FROM_POSITION_TITLE,FROM_POSITION_TITLE),
		FROM_POSITION_SEQ_NUM =
				nvl(p_misc.FROM_POSITION_SEQ_NUM,FROM_POSITION_SEQ_NUM),
		FROM_POSITION_DESC_NUM =
				nvl(p_misc.FROM_POSITION_DESC_NUM,FROM_POSITION_DESC_NUM),
		FROM_POSITION_ID = nvl(p_misc.FROM_POSITION_ID,FROM_POSITION_ID),
		FROM_AGENCY_CODE = nvl(p_misc.FROM_AGENCY_CODE,FROM_AGENCY_CODE),
		OCC_SERIES = nvl(p_misc.OCC_SERIES,OCC_SERIES),
		TO_POSITION_ID = nvl(p_misc.TO_POSITION_ID,TO_POSITION_ID),
		DUTY_STATION_DESC = nvl(p_misc.DUTY_STATION_DESC,DUTY_STATION_DESC),
		DUTY_STATION_CODE = nvl(p_misc.DUTY_STATION_CODE,DUTY_STATION_CODE),
		from_agency_code_desc =
				nvl(l_from_agency_code_desc,from_agency_code_desc)
	where current of cur_misc;

	close cur_misc;

	exception
		when others then
			put_line(l_proc||' - raised exception');
			raise;

end;


--
-- Copy information for the person identified by p_person_id to
-- ghr_mass_interface_v.  The parameter p_transfer_id is used to get the
-- transfer effective date and transfer name used for the transfer of
-- the person.
--
-- If a person already exists in the interface table
-- for the transfer name, the data is deleted before continuing with
-- the transfer out.
--
-- This procedure does not commit
--
-- Note: this procedure or procedures that it calls, calls log_message
--       to write messages to ghr_process_log.  The log_message procedure
--       will raise an exception if it is called before set_log_program_name()
--       is called.  The procedure below expects that its caller has called
--       set_log_program_name() first.
--
procedure mass_transfer_out(p_errbuf 		 out nocopy varchar2,
                       		 p_retcode 		 out nocopy number,
									 p_transfer_id  in number,
									 p_person_id    in per_all_people_f.person_id%type)
is
	l_proc_name  varchar2(30) := 'mass_transfer_out';
	l_proc       varchar2(72) := g_package||l_proc_name;

	l_effdate						date;
	l_transfer_name				ghr_mass_transfers.name%type;
	l_retained_grade_rec        ghr_pay_calc.retained_grade_rec_type;

	l_position_id					per_assignments_f.position_id%type;
	l_location_id					per_assignments_f.location_id%type;
	l_assignment_id				per_assignments_f.assignment_id%type;
	l_grade_id						per_assignments_f.grade_id%type;
	l_business_group_id			per_assignments_f.business_group_id%type;

	l_pos_ei_data					per_position_extra_info%rowtype;
	l_per_ei_data					per_people_extra_info%rowtype;
	l_asg_ei_data					per_assignment_extra_info%rowtype;
	l_special_info					ghr_api.special_information_type;

	l_adj_basic_pay				number;
	l_multi_error_flag			boolean;

	l_position_status				hr_all_positions_f.status%type;
	l_rc								varchar2(30);
	l_inter_bg_transfer			varchar2(1);

	---------------
	l_people_row			per_all_people_f%rowtype;
	l_position_row			hr_all_positions_f%rowtype;
	l_people_ei_row		per_people_extra_info%rowtype;
	l_element				ghr_mt_element_entries_v%rowtype;
	l_misc					ghr_mt_misc_v%rowtype;

	l_pos_defs		per_position_definitions%rowtype;
        l_position_rec          hr_all_positions_f%rowtype;
        l_result_code           varchar2(10);
/*
	cursor cur_pos_definitions(p_position_id number) is
		select pd.*
		from per_position_definitions pd,
			  hr_all_positions_f p
		where p.position_id = p_position_id
		and p.position_definition_id = pd.position_definition_id
		and trunc(l_effdate) between p.effective_start_date and
		nvl(effective_end_date,l_effdate+1);
*/
	cursor cur_pos_definitions(p_position_definition_id number) is
		select pd.*
		from per_position_definitions pd
		where pd.position_definition_id = p_position_definition_id;
--
	l_address_row		per_addresses%rowtype;
	cursor cur_addr(p_person_id number) is
		select *
		from per_addresses
		where person_id = p_person_id
		and primary_flag = 'Y'
		and     l_effdate
		between nvl(date_from,l_effdate)
		and     nvl(date_to,l_effdate);

	l_assignments_row		per_all_assignments_f%rowtype;
	l_assignment_ei_row		per_assignment_extra_info%rowtype;
	cursor cur_assignments_f(p_person_id number) is
		select assignment_id, position_id, business_group_id, grade_id, location_id
		from per_all_assignments_f
		where primary_flag = 'Y'
      and   assignment_type <> 'B'
		and   person_id = p_person_id
		and   trunc(l_effdate) between effective_start_date
		and   effective_end_date;

	l_positions_row		hr_all_positions_f%rowtype;
	l_position_ei_row		per_position_extra_info%rowtype;

	l_contact_type		varchar2(30);
	l_contact_name		varchar2(240);
	l_contact_person_id		per_people_f.person_id%type;
	cursor cur_contact_info(p_person_id number) is
		select cr.contact_type, p.full_name, cr.contact_person_id
		from per_contact_relationships cr, per_all_people_f p
		where cr.person_id = p_person_id
		and cr.primary_contact_flag = 'Y'
		and cr.contact_person_id = p.person_id
		and trunc(l_effdate) between p.effective_start_date
		and p.effective_end_date;

	cursor cur_lei(p_location_id number) is
	  select ds.duty_station_desc, ds.duty_station_code
	  FROM  hr_location_extra_info lei, ghr_duty_stations_v ds
	  WHERE lei.location_id = p_location_id
	  AND   lei.information_type = 'GHR_US_LOC_INFORMATION'
	  and to_number(lei.lei_information3) = ds.duty_station_id
	  and trunc(l_effdate) between ds.effective_start_date
	  and ds.effective_end_date;

	-- from ghapiapi.pkb (can't find api)
	cursor cur_grd(p_grade_id number) is
	  SELECT gdf.segment1 pay_plan
			  ,gdf.segment2 grade_or_level
	  FROM  per_grade_definitions gdf
			 ,per_grades            grd
	  WHERE grd.grade_id = p_grade_id
	  AND   grd.grade_definition_id = gdf.grade_definition_id;

begin

		hr_utility.set_location('Entering:'||l_proc, 10);
		put_line(l_proc||' transfer_id: '||p_transfer_id ||
				', person_id: '||p_person_id);

		get_transfer_parameters(p_transfer_id,
				p_effective_date	=> l_effdate,
				p_transfer_name   => l_transfer_name,
				p_inter_bg_transfer	=> l_inter_bg_transfer);

		if l_effdate is null then

			log_message(
				p_procedure	=> l_proc_name,
				p_message	=> 'Failed to get Transfer Out information from'||
									'GHR_MASS_TRANSFERS for mass_transfer_id:'||
									p_transfer_id);
			commit;
			hr_utility.set_message(8301, 'GHR_38534_MT_ID_ERR');
			hr_utility.raise_error;

		end if;

		ghr_history_fetch.fetch_people (
			p_person_id			=> p_person_id,
			p_date_effective	=> l_effdate,
			p_people_data		=> l_people_row,
			p_result_code		=> l_rc
		);

		if l_rc = 'not_found' then

			log_message(
				p_procedure	=> l_proc_name,
				p_message	=>
					'Could not query data from PER_PEOPLE_F for person_id:'||
					p_person_id);

			commit;
			hr_utility.set_message(8301, 'GHR_38536_MTO_NO_PERSON');
			hr_utility.raise_error;
		end if;

		-- if person and p_transfer_name exits in the interface table
		-- refresh the information by deleting the current data before
		-- inserting new data
		if row_exists(
				p_transfer_name		=> l_transfer_name
				,p_person_id			=> p_person_id
				,p_table_name			=> 'PER_PEOPLE_F') then

			put_line('------------------------------------------');
			put_line('Person '||p_person_id||', found in table');
			put_line('------------------------------------------');

			delete ghr_interface
			where information1 = l_transfer_name
			and information3 = to_char(p_person_id);
		end if;

		savepoint mto;

		insert_people_f(p_transfer_name		=> l_transfer_name,
							 p_inter_bg_transfer	=> l_inter_bg_transfer,
							 p_effective_date		=> l_effdate,
							 ppf						=> l_people_row);

		hr_utility.set_location('Gathering Data:'||l_proc, 20);

		-- procedure insert_people_ei tests if informaton_type is null and
		-- if it is the row in not inserted into the interface table

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_UNIFORMED_SERVICES'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_SF52'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_GROUP1'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_GROUP2'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);


		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_SCD_INFORMATION'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_PROBATIONS'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_RETAINED_GRADE'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_SEPARATE_RETIRE'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_SECURITY'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_CONVERSIONS'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_USER_INFO'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		l_people_ei_row.information_type := null;
		ghr_history_fetch.fetch_peopleei
						(p_person_id			=> p_person_id
						,p_information_type	=> 'GHR_US_PER_WF_ROUTING_GROUPS'
                  ,p_date_effective		=> l_effdate
                  ,p_per_ei_data			=> l_people_ei_row
  	   );

		insert_people_ei(l_transfer_name, l_effdate, l_people_ei_row);

		-- get person special information
		ghr_api.return_special_information
								(p_person_id       => p_person_id
								,p_structure_name  => 'US Fed Education'
								,p_effective_date  => l_effdate
								,p_special_info    => l_special_info
								);

		insert_special_info(l_transfer_name, l_effdate, p_person_id,
								  'US Fed Education', l_special_info);

		ghr_api.return_special_information
								(p_person_id       => p_person_id
								,p_structure_name  => 'US Fed Cndtn of Emplmt'
								,p_effective_date  => l_effdate
								,p_special_info    => l_special_info
								);

		insert_special_info(l_transfer_name, l_effdate, p_person_id,
								  'US Fed Cndtn of Emplmt', l_special_info);

		ghr_api.return_special_information
								(p_person_id       => p_person_id
								,p_structure_name  => 'US Fed Conduct Perf'
								,p_effective_date  => l_effdate
								,p_special_info    => l_special_info
								);

		insert_special_info(l_transfer_name, l_effdate, p_person_id,
								  'US Fed Conduct Perf', l_special_info);

		ghr_api.return_special_information
								(p_person_id       => p_person_id
								,p_structure_name  => 'US Fed Language'
								,p_effective_date  => l_effdate
								,p_special_info    => l_special_info
								);

		insert_special_info(l_transfer_name, l_effdate, p_person_id,
								  'US Fed Language', l_special_info);

		ghr_api.return_special_information
								(p_person_id       => p_person_id
								,p_structure_name  => 'US Fed Spcl Consdrtn'
								,p_effective_date  => l_effdate
								,p_special_info    => l_special_info
								);

		insert_special_info(l_transfer_name, l_effdate, p_person_id,
								  'US Fed Spcl Consdrtn', l_special_info);

		ghr_api.return_special_information
								(p_person_id       => p_person_id
								,p_structure_name  => 'US Fed Perf Appraisal'
								,p_effective_date  => l_effdate
								,p_special_info    => l_special_info
								);

		insert_special_info(l_transfer_name, l_effdate, p_person_id,
								  'US Fed Perf Appraisal', l_special_info);

		-- get address info
		open cur_addr(p_person_id);
		fetch cur_addr into l_address_row;

		if cur_addr%notfound then
			put_line('No primary address info found');
		else
			insert_address(p_transfer_name	=> l_transfer_name,
								p_effective_date	=> l_effdate,
								p_a					=> l_address_row);
		end if;
		close cur_addr;

		-- get person contact info
		open cur_contact_info(p_person_id);
		fetch cur_contact_info into l_contact_type, l_contact_name,
											 l_contact_person_id;

		if cur_contact_info%notfound then
			put_line('No primary contact found');
		else

			open cur_addr(l_contact_person_id);
			fetch cur_addr into l_address_row;

			if cur_addr%notfound then
				put_line('Primary contact address into not found');
			else
				-- Replace the person_id on the contact address record with
				-- the person_id of the employee being transfered out
				-- If this is not done, the mt_person_id column in the interface
				-- table will be that of the contact not the employee
				l_address_row.person_id := p_person_id;
				insert_address(
						p_transfer_name 		=> l_transfer_name,
						p_effective_date		=> l_effdate,
						p_a						=> l_address_row,
						p_contact_name			=> l_contact_name,
						p_contact_type			=> l_contact_type);
			end if;
			close cur_addr;
		end if;
		close cur_contact_info;

		-- get persons primary assignment
		open cur_assignments_f(p_person_id);
		fetch cur_assignments_f into l_assignment_id, l_position_id, l_business_group_id, l_grade_id, l_location_id;

		if cur_assignments_f%notfound then
			put_line('No assignment found');
			close cur_assignments_f;
            -- Bug 3718167 Added Person,SSN in the message
			log_message(
				p_procedure	=> l_proc_name,
				p_message	=>
					'Could not get assignment data '||
                    'for Employee: '|| l_people_row.full_name ||
                    ' SSN: '|| l_people_row.national_identifier ||
                    'person_id:'|| p_person_id);

			hr_utility.set_message(8301, 'GHR_38537_MTO_NO_ASG');
			hr_utility.raise_error;
		end if;
		close cur_assignments_f;

		ghr_history_fetch.fetch_assignment (
			p_assignment_id 			=> l_assignment_id,
			p_date_effective 			=> l_effdate,
			p_assignment_data			=> l_assignments_row,
			p_result_code           => l_rc);

		if l_rc = 'not_found' then
			--Bug#3718167 Added Name, SSN in the message.
			log_message(
				p_procedure	=> l_proc_name,
				p_message	=>
					'Could not get assignment data '||
                    'for Employee: '|| l_people_row.full_name ||
                    ' SSN: '|| l_people_row.national_identifier ||
                    'person_id:'|| p_person_id);
			hr_utility.set_message(8301, 'GHR_38537_MTO_NO_ASG');
			hr_utility.raise_error;
		end if;

		insert_assignment_f(p_transfer_name 		=> l_transfer_name,
								  p_effective_date		=> l_effdate,
								  p_a							=> l_assignments_row);

		-- get assignment extra info
		l_assignment_ei_row.information_type := null;
		ghr_history_fetch.fetch_asgei(
			p_assignment_id		=> l_assignment_id,
			p_information_type	=> 'GHR_US_ASG_SF52',
			p_date_effective		=> l_effdate,
			p_asg_ei_data			=> l_assignment_ei_row
		);

		insert_assignment_ei(p_transfer_name	=> l_transfer_name,
								p_person_id				=> p_person_id,
								p_effective_date		=> l_effdate,
								p_a_ei					=> l_assignment_ei_row
		);

		l_assignment_ei_row.information_type := null;
		ghr_history_fetch.fetch_asgei(
			p_assignment_id		=> l_assignment_id,
			p_information_type	=> 'GHR_US_ASG_NON_SF52',
			p_date_effective		=> l_effdate,
			p_asg_ei_data			=> l_assignment_ei_row
		);

		insert_assignment_ei(p_transfer_name	=> l_transfer_name,
								p_person_id				=> p_person_id,
								p_effective_date		=> l_effdate,
								p_a_ei					=> l_assignment_ei_row
		);

		l_assignment_ei_row.information_type := null;
		ghr_history_fetch.fetch_asgei(
			p_assignment_id		=> l_assignment_id,
			p_information_type	=> 'GHR_US_ASG_NTE_DATES',
			p_date_effective		=> l_effdate,
			p_asg_ei_data			=> l_assignment_ei_row
		);

		insert_assignment_ei(p_transfer_name	=> l_transfer_name,
								p_person_id				=> p_person_id,
								p_effective_date		=> l_effdate,
								p_a_ei					=> l_assignment_ei_row
		);

		-- get position info
		ghr_history_fetch.fetch_position(
			p_position_id		=> l_position_id,
			p_date_effective	=> l_effdate,
			p_position_data	=> l_position_row,
			p_result_code		=> l_rc
		);

		insert_position(p_transfer_name 		=> l_transfer_name,
							 p_person_id			=> p_person_id,
							 p_effective_date		=> l_effdate,
							 p_pos					=> l_position_row);

		-- get position extra info
		l_position_ei_row.information_type := null;
		ghr_history_fetch.fetch_positionei
                  (p_position_id      => l_position_id
                  ,p_information_type => 'GHR_US_POS_GRP1'
                  ,p_date_effective   => l_effdate
                  ,p_pos_ei_data      => l_position_ei_row
      );

		insert_position_ei(p_transfer_name 		=> l_transfer_name,
								 p_person_id			=> p_person_id,
								 p_effective_date		=> l_effdate,
								 p_pos_ei				=> l_position_ei_row);

		l_position_ei_row.information_type := null;
		ghr_history_fetch.fetch_positionei
                  (p_position_id      => l_position_id
                  ,p_information_type => 'GHR_US_POS_GRP2'
                  ,p_date_effective   => l_effdate
                  ,p_pos_ei_data      => l_position_ei_row
      );

		insert_position_ei(p_transfer_name 		=> l_transfer_name,
								 p_person_id			=> p_person_id,
								 p_effective_date		=> l_effdate,
								 p_pos_ei				=> l_position_ei_row);

		l_position_ei_row.information_type := null;
		ghr_history_fetch.fetch_positionei
                  (p_position_id      => l_position_id
                  ,p_information_type => 'GHR_US_POSITION_DESCRIPTION'
                  ,p_date_effective   => l_effdate
                  ,p_pos_ei_data      => l_position_ei_row
      );

		insert_position_ei(p_transfer_name 		=> l_transfer_name,
								 p_person_id			=> p_person_id,
								 p_effective_date		=> l_effdate,
								 p_pos_ei				=> l_position_ei_row);

		l_position_ei_row.information_type := null;
		ghr_history_fetch.fetch_positionei
                  (p_position_id      => l_position_id
                  ,p_information_type => 'GHR_US_POS_OBLIG'
                  ,p_date_effective   => l_effdate
                  ,p_pos_ei_data      => l_position_ei_row
      );

		insert_position_ei(p_transfer_name 		=> l_transfer_name,
								 p_person_id			=> p_person_id,
								 p_effective_date		=> l_effdate,
								 p_pos_ei				=> l_position_ei_row);

		l_position_ei_row.information_type := null;
		ghr_history_fetch.fetch_positionei
                        (p_position_id      => l_position_id
                        ,p_information_type => 'GHR_US_POS_VALID_GRADE'
                        ,p_date_effective   => l_effdate
                        ,p_pos_ei_data      => l_position_ei_row
      );

		insert_position_ei(p_transfer_name 	=> l_transfer_name,
				 p_person_id		=> p_person_id,
				 p_effective_date	=> l_effdate,
				 p_pos_ei		=> l_position_ei_row);
                GHR_HISTORY_FETCH.fetch_position (
                    p_position_id                   => l_position_id,
                    p_date_effective                => l_effdate,
                    p_position_data                 => l_position_rec,
                    p_result_code                   => l_result_code );

		open cur_pos_definitions(l_position_rec.position_definition_id);
		fetch cur_pos_definitions into l_pos_defs;

		if cur_pos_definitions%found then
			put_line('Position Definition data found');
			insert_position_defs(
					p_transfer_name	        => l_transfer_name,
					p_effective_date	=> l_effdate,
					p_person_id		=> p_person_id,
					p_flex_name		=> 'US Federal Position',
					p_pos_defs		=> l_pos_defs
			);
		end if;
		close cur_pos_definitions;

-- Processing Total Pay and Adjusted Basic Pay
-- NAME    DATE       BUG           COMMENTS
-- Ashley  17-JUL-03  Payroll Intg  Modified the Input Value name
--                                  Changes from Total Salary -> Amount
--                                               Adjusted Pay -> Amount


		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Total Pay'
			      ,p_input_value_name      => 'Amount'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.total_salary
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name     => 'Basic Salary Rate'
			      ,p_input_value_name      => 'Rate'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.salary
			      ,p_multiple_error_flag   => l_multi_error_flag);

 		ghr_api.retrieve_element_entry_value (
-- FWFA Changes Bug#4444609
					p_element_name    => 'Locality Pay or SR Supplement'
-- FWFA Changes Modify 'Locality Pay' to 'Locality Pay or SR Supplement'
			      ,p_input_value_name      => 'Rate'
-- Changed 'Amount' input value to 'Rate' by Ashu Gupta.
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.locality_adjustment
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name	=> 'Adjusted Basic Pay'
			       ,p_input_value_name	=> 'Amount'
			       ,p_assignment_id		=> l_assignment_id
			       ,p_effective_date	=> l_effdate
			       ,p_value                  => l_element.adjusted_pay
			       ,p_multiple_error_flag    => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Other Pay'
			      ,p_input_value_name      => 'Amount'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.other_pay
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Health Benefits'
			      ,p_input_value_name      => 'Enrollment'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.enrollment
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Health Benefits'
			      ,p_input_value_name      => 'Health Plan'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.health_plan
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Health Benefits'
			      ,p_input_value_name      => 'Temps Total Cost'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.temps_total_cost
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'TSP'
			      ,p_input_value_name      => 'Amount'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.tsp_amount
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'TSP'
			      ,p_input_value_name      => 'Rate'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.tsp_rate
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'TSP'
			      ,p_input_value_name      => 'G Fund'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.tsp_g_fund
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'TSP'
			      ,p_input_value_name      => 'F Fund'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.tsp_f_fund
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'TSP'
			      ,p_input_value_name      => 'C Fund'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.tsp_c_fund
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'TSP'
			      ,p_input_value_name      => 'Status'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.tsp_status
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'TSP'
			      ,p_input_value_name      => 'Status Date'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.tsp_status_date
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'TSP'
			      ,p_input_value_name      => 'Eligibility Date'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.tsp_eligibility_date
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Within Grade Increase'
			      ,p_input_value_name      => 'Status'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.wgi_status
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Within Grade Increase'
			      ,p_input_value_name      => 'Date Due'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.wgi_date_due
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Within Grade Increase'
			      ,p_input_value_name      => 'Pay Date'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.wgi_pay_date
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Within Grade Increase'
			      ,p_input_value_name      => 'Last Increase Date'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.wgi_last_increase_date
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Within Grade Increase'
			      ,p_input_value_name      => 'Postponmt Effective'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.wgi_postponmt_effective
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Within Grade Increase'
			      ,p_input_value_name      => 'Postponmt Determ Due'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.wgi_postponmt_determ_due
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name					=> 'FEGLI'
			       ,p_input_value_name			=> 'FEGLI'
			       ,p_assignment_id				=> l_assignment_id
			       ,p_effective_date			=> l_effdate
			       ,p_value                  => l_element.fegli
			       ,p_multiple_error_flag    => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name					=> 'FEGLI'
			       ,p_input_value_name			=> 'Eligibility Expiration'
			       ,p_assignment_id				=> l_assignment_id
			       ,p_effective_date			=> l_effdate
			       ,p_value                  => l_element.eligibility_expiration
			       ,p_multiple_error_flag    => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name					=> 'Retirement Plan'
			       ,p_input_value_name			=> 'Plan'
			       ,p_assignment_id				=> l_assignment_id
			       ,p_effective_date			=> l_effdate
			       ,p_value                  => l_element.retirement_plan
			       ,p_multiple_error_flag    => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Retention Allowance'
			      ,p_input_value_name      => 'Amount'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.retention_allowance
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Retention Allowance'
			      ,p_input_value_name      => 'Percentage'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.to_retention_allow_percentage
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Staffing Differential'
			      ,p_input_value_name      => 'Amount'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.staffing_differential
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Staffing Differential'
			      ,p_input_value_name      => 'Percent'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.to_staffing_diff_percentage
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Supervisory Differential'
			      ,p_input_value_name      => 'Amount'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.supervisory_differential
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Supervisory Differential'
			      ,p_input_value_name      => 'Percentage'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.to_supervisory_diff_percentage
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'AUO'
			      ,p_input_value_name      => 'Amount'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.auo_amount
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'AUO'
			      ,p_input_value_name      => 'Premium Pay Ind'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.auo_premium_pay_ind
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Availability Pay'
			      ,p_input_value_name      => 'Amount'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.ap_amount
			      ,p_multiple_error_flag   => l_multi_error_flag);

		ghr_api.retrieve_element_entry_value (
					p_element_name    => 'Availability Pay'
			      ,p_input_value_name      => 'Premium Pay Ind'
			      ,p_assignment_id         => l_assignment_id
			      ,p_effective_date        => l_effdate
			      ,p_value                 => l_element.ap_premium_pay_ind
			      ,p_multiple_error_flag   => l_multi_error_flag);

		insert_element_entries(p_transfer_name		=> l_transfer_name,
									 p_person_id			=> p_person_id,
									 p_effective_date		=> l_effdate,
									 p_element				=> l_element);

		ghr_msl_pkg.get_sub_element_code_pos_title(
					l_position_id,
					p_person_id,
					l_business_group_id,
					l_assignment_id,
					l_effdate,
					l_misc.from_agency_code,
					l_misc.from_position_title,
					l_misc.from_position_desc_num,
					l_misc.from_position_seq_num);

		open cur_grd(l_grade_id);
		fetch cur_grd into l_misc.from_pay_plan, l_misc.from_grade_or_level;
		close cur_grd;

		l_misc.occ_series := ghr_api.get_job_occupational_series(
						p_person_id			=> p_person_id
						,p_assignment_id	=> l_assignment_id
						,p_effective_date	=> l_effdate);

		-- per jmacgoy 3/5/98,
		-- assignment_location is duty_station_code
		open cur_lei(l_location_id);
		fetch cur_lei into l_misc.duty_station_desc, l_misc.duty_station_code;
		close cur_lei;

		insert_misc(p_transfer_name		=> l_transfer_name,
						p_person_id				=> p_person_id,
						p_effective_date		=> l_effdate,
						p_misc					=> l_misc);

		/*
		-- copy from_agency_code to segment Agency Code Transfer From (pei_info7)
		update_agency_transfer_from(
						p_person_id				=> p_person_id,
						p_effective_date		=> l_effdate,
						p_value					=> l_misc.from_agency_code);
		*/

		hr_utility.set_location('Leaving:'||l_proc, 60);
        -- Bug#4183516 Modified the Message Text.
		log_message(
			p_procedure	=> l_proc_name,
			p_message	=> 'Interface table updated Successfully for ' || l_people_row.full_name ||
								' SSN: '|| l_people_row.national_identifier );
								--||' successful');

		p_retcode := 0;
		p_errbuf := null;

	exception
		when others then

			rollback to mto;

			log_message(
				p_procedure	=> l_proc_name,
				p_message	=> 'Mass Transfer Out for ' || l_people_row.full_name ||
									' SSN: '|| l_people_row.national_identifier ||
									' failed with error message: '||sqlerrm(sqlcode));

			commit;
			put_line(l_proc||' - raised exception');

			p_errbuf := 'MTO: '|| sqlerrm(sqlcode);
			p_retcode := 2;

	end mass_transfer_out;

begin
	g_dbms_output  := false;
	g_message		:= null;
	g_log_name		:= null;
end ghr_mto_int;

/
