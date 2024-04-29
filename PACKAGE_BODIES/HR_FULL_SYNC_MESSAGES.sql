--------------------------------------------------------
--  DDL for Package Body HR_FULL_SYNC_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FULL_SYNC_MESSAGES" as
/* $Header: perhrhdfull.pkb 120.9 2008/03/19 09:52:12 sathkris noship $ */

TYPE EMPLIDTYPE IS TABLE OF per_all_people_f.employee_number%type INDEX BY BINARY_INTEGER;
TYPE EMPL_RCDTYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE PROBATION_DTTYPE IS TABLE OF per_all_assignments_f.probation_period%type INDEX BY BINARY_INTEGER;
TYPE ORIG_HIRE_DTTYPE IS TABLE OF per_all_people_f.original_date_of_hire%type INDEX BY BINARY_INTEGER;
TYPE WEFFDTTYPE IS TABLE OF per_all_assignments_f.effective_start_date%type INDEX BY BINARY_INTEGER;
TYPE BUSINESS_UNITTYPE IS TABLE OF per_all_assignments_f.organization_id%type INDEX BY BINARY_INTEGER;
TYPE WJOBCODETYPE IS TABLE OF per_all_assignments_f.job_id%type INDEX BY BINARY_INTEGER;
TYPE EMPL_STATUSTYPE IS TABLE OF per_all_assignments_f.assignment_status_type_id%type INDEX BY BINARY_INTEGER;
TYPE LOCATIONTYPE IS TABLE OF per_all_assignments_f.location_id%type INDEX BY BINARY_INTEGER;
TYPE FULL_PART_TIMETYPE IS TABLE OF per_all_assignments_f.employment_category%type INDEX BY BINARY_INTEGER;
TYPE COMPANYTYPE IS TABLE OF per_all_assignments_f.business_group_id%type INDEX BY BINARY_INTEGER;
TYPE STD_HOURSTYPE IS TABLE OF per_all_assignments_f.normal_hours%type INDEX BY BINARY_INTEGER;
TYPE STD_HRS_FREQUENCYTYPE IS TABLE OF per_all_assignments_f.frequency%type INDEX BY BINARY_INTEGER;
TYPE GRADETYPE IS TABLE OF per_all_assignments_f.grade_id%type INDEX BY BINARY_INTEGER;
TYPE SUPERVISOR_IDTYPE IS TABLE OF per_all_assignments_f.supervisor_id%type INDEX BY BINARY_INTEGER;
TYPE ASGN_START_DTTYPE IS TABLE OF per_all_assignments_f.EFFECTIVE_START_DATE%type INDEX BY BINARY_INTEGER;
TYPE ASGN_END_DTTYPE IS TABLE OF per_all_assignments_f.EFFECTIVE_END_DATE%type INDEX BY BINARY_INTEGER;
TYPE TERMINATION_DTTYPE IS TABLE OF per_periods_of_service.final_process_date%type INDEX BY BINARY_INTEGER;
TYPE LAST_DATE_WORKEDTYPE IS TABLE OF per_periods_of_service.ACCEPTED_TERMINATION_DATE%type INDEX BY BINARY_INTEGER;
TYPE STEPTYPE IS TABLE OF PER_SPINAL_POINT_PLACEMENTS_F.STEP_ID%type INDEX BY BINARY_INTEGER;
TYPE workforce IS REF CURSOR;

TYPE WorkForceTblType IS RECORD
(
    EMPLID EMPLIDTYPE
    ,EMPL_RCD EMPL_RCDTYPE
    ,PROBATION_DT PROBATION_DTTYPE
    ,ORIG_HIRE_DT ORIG_HIRE_DTTYPE
    ,EFFDT WEFFDTTYPE
    ,BUSINESS_UNIT BUSINESS_UNITTYPE
    ,JOBCODE WJOBCODETYPE
    ,EMPL_STATUS EMPL_STATUSTYPE
    ,LOCATION LOCATIONTYPE
    ,FULL_PART_TIME FULL_PART_TIMETYPE
    ,COMPANY COMPANYTYPE
    ,STD_HOURS STD_HOURSTYPE
    ,STD_HRS_FREQUENCY STD_HRS_FREQUENCYTYPE
    ,GRADE GRADETYPE
    ,SUPERVISOR_ID SUPERVISOR_IDTYPE
    ,ASGN_START_DT ASGN_START_DTTYPE
    ,ASGN_END_DT ASGN_END_DTTYPE
    ,TERMINATION_DT TERMINATION_DTTYPE
    ,LAST_DATE_WORKED LAST_DATE_WORKEDTYPE
    ,STEP STEPTYPE
);

WorkForceFullType WorkForceTblType;
WorkForcedeltaType WorkForceTblType;



		TYPE setidType IS TABLE OF per_jobs.business_group_id%type INDEX BY BINARY_INTEGER;
		TYPE jobcodeType IS TABLE OF per_jobs.job_id%type INDEX BY BINARY_INTEGER;
		TYPE effdtType IS TABLE OF per_jobs.date_from%type INDEX BY BINARY_INTEGER;
		TYPE effstatusType IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
		TYPE descrType IS TABLE OF per_jobs.name%type INDEX BY BINARY_INTEGER;
		TYPE jobcode IS REF CURSOR;

		TYPE JobCodeTblType IS RECORD
		(
		SETID setidType,
		JOBCODE jobcodeType,
		EFFDT effdtType,
		EFF_STATUS effstatusType,
		DESCR descrType);

		Jobcodefulltype JobCodeTblType;
		Jobcodedeltatype JobCodeTblType;

/*Common procedure to update the hr_psft_sync_run table begins here*/
		PROCEDURE update_psft_sync_run
		(p_status number
		 ,p_process_name varchar2
		 ,p_run_date date
		 ,errbuf  OUT NOCOPY VARCHAR2
		 ,retcode OUT NOCOPY VARCHAR2)
		IS
		l_status varchar2(10);

		BEGIN

		if p_status = 1 then
		    l_status := 'COMPLETED';
		elsif p_status = 2 then
		    l_status := 'STARTED';
		elsif p_status = 3 then
		    l_status := 'ERROR';
		end if;

		update hr_psft_sync_run
		set status = l_status
		where process = p_process_name
		and run_date = p_run_date;
		commit;

		FND_FILE.NEW_LINE(FND_FILE.log, 1);

		EXCEPTION WHEN OTHERS THEN
		        errbuf := errbuf||SQLERRM;
		        retcode := '1';
		        FND_FILE.put_line(fnd_file.log,'Error in update_psft_sync_run: '||SQLCODE);
		        FND_FILE.NEW_LINE(FND_FILE.log, 1);
		        FND_FILE.put_line(fnd_file.log,'Error Msg: '||substr(SQLERRM,1,700));

		END update_psft_sync_run;
/*Common procedure to update the hr_psft_sync_run table ends here*/

/*Common procedure to insert into hr_psft_sync_run table begins here*/

		 PROCEDURE insert_psft_sync_run
		 (p_status number
		 ,p_process_name varchar2
		 ,errbuf  OUT NOCOPY VARCHAR2
		 ,retcode OUT NOCOPY VARCHAR2)
		IS
		l_status varchar2(10);
		BEGIN

		FND_FILE.NEW_LINE(FND_FILE.log, 1);

		if p_status = 1 then
		    l_status := 'COMPLETED';
		elsif p_status = 2 then
		    l_status := 'STARTED';
		elsif p_status = 3 then
		    l_status := 'ERROR';
		end if;

		INSERT INTO hr_psft_sync_run(run_date,status,process)
		Values(sysdate,l_status,p_process_name);
		commit;

		FND_FILE.NEW_LINE(FND_FILE.log, 1);

		EXCEPTION WHEN OTHERS THEN
		        errbuf := errbuf||SQLERRM;
		        retcode := '1';
		        FND_FILE.put_line(fnd_file.log,'Error in insert_psft_sync_run: '||SQLCODE);
		        FND_FILE.NEW_LINE(FND_FILE.log, 1);
		        FND_FILE.put_line(fnd_file.log,'Error Msg: '||substr(SQLERRM,1,700));

		END insert_psft_sync_run;
/*Common procedure to insert into psft_sync_run table ends here*/

/*Procedure to extract state data for Full Synch messages begins*/
    PROCEDURE  HR_STATE_FULL_SYNC(errbuf  OUT NOCOPY VARCHAR2
 							 ,retcode OUT NOCOPY VARCHAR2)
    is

     		 p_cntry_code fnd_territories_vl.territory_code%type;
		 p_state_code fnd_common_lookups.lookup_code%type;
		 p_state_desc fnd_common_lookups.meaning%type;
		 p_enabled_flag fnd_common_lookups.enabled_flag%type;
		 p_effective_date date default sysdate;



     cursor fet_state_sync is
     select ft.territory_code,fcl.lookup_code,fcl.meaning,fcl.enabled_flag
     from fnd_common_lookups fcl,fnd_territories_vl ft
     where fcl.lookup_type = (ft.territory_code ||'_STATE')
     order by ft.territory_code;

     cursor fet_psft_sync is
     select count('x')
     from   hr_psft_sync_run
     where  process = 'STATE_FULL_SYNC'
     and    run_date < p_effective_date
     and    status = 'STARTED';

     l_dummy number;

     begin

    	open fet_psft_sync;
     	fetch fet_psft_sync into l_dummy;
     	close fet_psft_sync;
     	if l_dummy = 0
     		then
     			  	FND_FILE.NEW_LINE(FND_FILE.log, 1);
          			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
     			 	FND_FILE.put_line(fnd_file.log,'State Full synch Data Extraction Begins:'||to_char(p_effective_date,
                      'DD/MM/RRRR HH:MI:SS'));
     			 	hr_full_sync_messages.insert_psft_sync_run(2,'STATE_FULL_SYNC',errbuf,retcode);

      		open fet_state_sync;
      		loop
        		fetch fet_state_sync into p_cntry_code,p_state_code,p_state_desc,p_enabled_flag;
        		exit when fet_state_sync%notfound;

          		FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_cntry_code||fnd_global.local_chr(400)||p_state_code
			||fnd_global.local_chr(400)||p_state_desc||fnd_global.local_chr(400)||p_enabled_flag);
          		FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        	end loop;
        	close fet_state_sync;

     	  hr_full_sync_messages.update_psft_sync_run(1,'STATE_FULL_SYNC',p_effective_date,errbuf,retcode);
     	  FND_FILE.NEW_LINE(FND_FILE.log, 1);
    	  FND_FILE.put_line(fnd_file.log,'State Full Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
       end if;


      exception
           when OTHERS then
            hr_full_sync_messages.update_psft_sync_run(3,'STATE_FULL_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in State Data Full Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

     end HR_STATE_FULL_SYNC;
/*Procedure to extract state data for Full Synch messages ends*/

/*Procedure to extract country data for Full Synch messages begins*/

	PROCEDURE HR_COUNTRY_FULL_SYNC(errbuf  OUT NOCOPY VARCHAR2
 							 ,retcode OUT NOCOPY VARCHAR2)
	 is

 	     p_cntry_code fnd_territories_vl.territory_code%type;
	     p_cntry_desc fnd_territories_vl.territory_short_name%type;
	     p_obsolete_flag fnd_territories_vl.obsolete_flag%type;
	     p_effective_date date default sysdate;

	 cursor fet_cntry_fsync is
	 select ft.territory_code,
	 ft.territory_short_name ,
	 ft.territory_code,ft.obsolete_flag
	 from fnd_territories_vl ft
	 order by ft.territory_code;

	 cursor fet_psft_sync is
	 select count('x')
	 from   hr_psft_sync_run
	 where  process = 'COUNTRY_FULL_SYNC'
	 and    run_date < p_effective_date
	 and    status = 'STARTED';

	 l_dummy number;

	 begin

	 	open fet_psft_sync;
	 	fetch fet_psft_sync into l_dummy;
	   	close fet_psft_sync;
	 	if l_dummy = 0
	 	then
			FND_FILE.NEW_LINE(FND_FILE.log, 1);
  			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
		 	FND_FILE.put_line(fnd_file.log,'Country Full Synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
		 	hr_full_sync_messages.insert_psft_sync_run(2,'COUNTRY_FULL_SYNC',errbuf,retcode);
		open fet_cntry_fsync;
	  	loop
	    	fetch fet_cntry_fsync into p_cntry_code,p_cntry_desc,p_cntry_code,p_obsolete_flag;
	    	exit when fet_cntry_fsync%notfound;
	    	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_cntry_code||fnd_global.local_chr(400)||p_cntry_desc||fnd_global.local_chr(400)
		||p_cntry_code||fnd_global.local_chr(400)||p_obsolete_flag);
		FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
		end loop;
	    	close fet_cntry_fsync;


	 	 hr_full_sync_messages.update_psft_sync_run(1,'COUNTRY_FULL_SYNC',p_effective_date,errbuf,retcode);
	 	 FND_FILE.NEW_LINE(FND_FILE.log, 1);
		 FND_FILE.put_line(fnd_file.log,'Country Full Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

	 end if;

	  exception
	       when OTHERS then
	        hr_full_sync_messages.update_psft_sync_run(3,'COUNTRY_FULL_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Country Data Full Synch Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

	 end HR_COUNTRY_FULL_SYNC;

/*Procedure to extract country data for Full Synch messages ends*/

/*Procedure to extract Location data for Full Synch messages Begins*/
	PROCEDURE  HR_LOCATION_FULL_SYNC(errbuf  OUT NOCOPY VARCHAR2
 							 ,retcode OUT NOCOPY VARCHAR2)
	is

	 p_bg_id  		hr_locations_all.business_group_id%type;
	 p_loc_id 		hr_locations_all.LOCATION_ID%type;
	 p_active_date 		date;
	 p_effecive_status	varchar2(10);
	 p_loc_code 		hr_locations_all.LOCATION_CODE%type;
	 p_loc_desc		hr_locations_all.DESCRIPTION%type;
	 p_loc_style 		hr_locations_all.STYLE%type;
	 p_add_line_1		hr_locations_all.ADDRESS_LINE_1%type;
	 p_add_line_2		hr_locations_all.ADDRESS_LINE_2%type;
	 p_add_line_3		hr_locations_all.ADDRESS_LINE_3%type;
	 p_town_or_city		hr_locations_all.TOWN_OR_CITY%type;
	 p_country		hr_locations_all.COUNTRY%type;
	 p_postal_code		hr_locations_all.POSTAL_CODE%type;
	 p_region_1		hr_locations_all.REGION_1%type;
	 p_region_2		hr_locations_all.REGION_2%type;
	 p_region_3		hr_locations_all.REGION_3%type;
	 p_tel_no_1		hr_locations_all.TELEPHONE_NUMBER_1%type;
	 p_tel_no_2		hr_locations_all.TELEPHONE_NUMBER_2%type;
	 p_tel_no_3		hr_locations_all.TELEPHONE_NUMBER_3%type;
	 p_loc_info_13		hr_locations_all.LOC_INFORMATION13%type;
	 p_loc_info_14		hr_locations_all.LOC_INFORMATION14%type;
	 p_loc_info_15		hr_locations_all.LOC_INFORMATION15%type;
	 p_loc_info_16		hr_locations_all.LOC_INFORMATION16%type;
	 p_loc_info_17		hr_locations_all.LOC_INFORMATION17%type;
	 p_loc_info_18		hr_locations_all.LOC_INFORMATION18%type;
	 p_loc_info_19		hr_locations_all.LOC_INFORMATION19%type;
	 p_loc_info_20		hr_locations_all.LOC_INFORMATION20%type;
	 p_effective_date	date default sysdate;

	 cursor fet_loc_sync is
	 select  BUSINESS_GROUP_ID,
	        LOCATION_ID,
	        case when inactive_date is not null then inactive_date
	        else CREATION_DATE end,
	        case when inactive_date is not null then 'INACTIVE'
	        else 'ACTIVE' end,
	        LOCATION_CODE ,
	        DESCRIPTION,
	        STYLE,
	        COUNTRY,
	        ADDRESS_LINE_1,
	        ADDRESS_LINE_2,
	        ADDRESS_LINE_3,
	        TOWN_OR_CITY,
	        REGION_1,
	        REGION_2,
	        REGION_3,
	        POSTAL_CODE,
	        TELEPHONE_NUMBER_1,
	        TELEPHONE_NUMBER_2,
	        TELEPHONE_NUMBER_3,
	        LOC_INFORMATION13,
	        LOC_INFORMATION14,
		LOC_INFORMATION15,
		LOC_INFORMATION16,
		LOC_INFORMATION17,
		LOC_INFORMATION18,
		LOC_INFORMATION19,
		LOC_INFORMATION20
		from
		hr_locations_all;


			cursor fet_psft_sync is
	 		select count('x')
	 		from   hr_psft_sync_run
	 		where  process = 'LOC_FULL_SYNC'
	 		and    run_date < p_effective_date
	 		and    status = 'STARTED';



	 		 l_dummy number;

	begin

	 	open fet_psft_sync;
	 	fetch fet_psft_sync into l_dummy;
	   	close fet_psft_sync;
	 	if l_dummy = 0
	 		then
			FND_FILE.NEW_LINE(FND_FILE.log, 1);
	  		FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
			FND_FILE.put_line(fnd_file.log,'Location Full Synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
			hr_full_sync_messages.insert_psft_sync_run(2,'LOC_FULL_SYNC',errbuf,retcode);

	  		open fet_loc_sync;
	  		loop
	    		fetch fet_loc_sync into p_bg_id,p_loc_id,p_active_date,p_effecive_status,
		 		p_loc_code, p_loc_desc, p_loc_style , p_country, p_add_line_1, p_add_line_2, p_add_line_3,
		  		p_town_or_city,p_region_1,p_region_2,p_region_3,p_postal_code,p_tel_no_1,p_tel_no_2 ,
		  		p_tel_no_3,p_loc_info_13,	p_loc_info_14,p_loc_info_15,p_loc_info_16,p_loc_info_17,p_loc_info_18,
		  		p_loc_info_19,p_loc_info_20;
	    		exit when fet_loc_sync%notfound;
	    		FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_bg_id||fnd_global.local_chr(400)||p_loc_id||
			fnd_global.local_chr(400)||p_active_date||
			fnd_global.local_chr(400)||p_effecive_status||fnd_global.local_chr(400)||
		 	p_loc_code||fnd_global.local_chr(400)|| p_loc_desc||fnd_global.local_chr(400)||'ADDRESS_START'||
			fnd_global.local_chr(400)||p_loc_style ||fnd_global.local_chr(400)|| p_add_line_1||
			fnd_global.local_chr(400)|| p_add_line_2||fnd_global.local_chr(400)|| p_add_line_3||
			fnd_global.local_chr(400)||p_town_or_city||fnd_global.local_chr(400)||p_country||
			fnd_global.local_chr(400)||p_postal_code||fnd_global.local_chr(400)||p_region_1||
			fnd_global.local_chr(400)||p_region_2||fnd_global.local_chr(400)||p_region_3||
			fnd_global.local_chr(400)||p_tel_no_1||fnd_global.local_chr(400)||p_tel_no_2 ||
			fnd_global.local_chr(400)||p_tel_no_3||fnd_global.local_chr(400)||p_loc_info_13||
			fnd_global.local_chr(400)||	p_loc_info_14||fnd_global.local_chr(400)||p_loc_info_15||
			fnd_global.local_chr(400)||p_loc_info_16||fnd_global.local_chr(400)||p_loc_info_17||
			fnd_global.local_chr(400)||p_loc_info_18||fnd_global.local_chr(400)||
		  		p_loc_info_19||fnd_global.local_chr(400)||p_loc_info_20||fnd_global.local_chr(400)||'ADDRESS_END'||
                  fnd_global.local_chr(400));
		  	FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
	    	end loop;
	    	close fet_loc_sync;

	  	 hr_full_sync_messages.update_psft_sync_run(1,'LOC_FULL_SYNC',p_effective_date,errbuf,retcode);
	  	 FND_FILE.NEW_LINE(FND_FILE.log, 1);
		 FND_FILE.put_line(fnd_file.log,'Location Full Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

	 end if;

	  exception
	       when OTHERS then
	        hr_full_sync_messages.update_psft_sync_run(3,'LOC_FULL_SYNC',p_effective_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Location Full Synch Data Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

	 end HR_LOCATION_FULL_SYNC;
/*Procedure to extract Location data for Full Synch messages Ends*/

/*Procedure to extract Person data for Full Synch messages Begins*/

	procedure hr_person_full_sync(errbuf  OUT NOCOPY VARCHAR2
 					,retcode OUT NOCOPY VARCHAR2)
	is

	L_EMPLOYEE_NUMBER  PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%type;
	L_USER_PERSON_TYPE VARCHAR2(60);
	L_DATE_OF_BIRTH DATE;
	L_TOWN_OF_BIRTH PER_ALL_PEOPLE_F.TOWN_OF_BIRTH%type;
	L_COUNTRY_OF_BIRTH PER_ALL_PEOPLE_F.COUNTRY_OF_BIRTH%type;
	L_DATE_OF_DEATH DATE;
	L_ORIGINAL_DATE_OF_HIRE DATE;

	L_EFFECTIVE_START_DATE DATE;

	L_SEX VARCHAR2(30);
	L_MARITAL_STATUS VARCHAR2(30);
	L_FULL_NAME PER_ALL_PEOPLE_F.FULL_NAME%type;
	L_PRE_NAME_ADJUNCT PER_ALL_PEOPLE_F.PRE_NAME_ADJUNCT%type;
	L_SUFFIX VARCHAR2(30);
	L_TITLE VARCHAR2(30);
	L_LAST_NAME PER_ALL_PEOPLE_F.LAST_NAME%type;
	L_FIRST_NAME PER_ALL_PEOPLE_F.FIRST_NAME%type;
	L_MIDDLE_NAMES PER_ALL_PEOPLE_F.MIDDLE_NAMES%type;



	L_ADDRESS_TYPE PER_ADDRESSES.ADDRESS_TYPE%type;
	L_DATE_FROM DATE;
	L_COUNTRY PER_ADDRESSES.COUNTRY%type;
	L_ADDRESS_LINE1 PER_ADDRESSES.ADDRESS_LINE1%type;
	L_ADDRESS_LINE2 PER_ADDRESSES.ADDRESS_LINE2%type;
	L_ADDRESS_LINE3 PER_ADDRESSES.ADDRESS_LINE3%type;
	L_TOWN_OR_CITY PER_ADDRESSES.TOWN_OR_CITY%type;
	L_TELEPHONE_NUMBER_1 PER_ADDRESSES.TELEPHONE_NUMBER_1%type;
	L_REGION_1 PER_ADDRESSES.REGION_1%type;
	L_REGION_2 PER_ADDRESSES.REGION_1%type;
	L_POSTAL_CODE PER_ADDRESSES.POSTAL_CODE%type;

	L_EMAIL_ADDRESS PER_ALL_PEOPLE_F.EMAIL_ADDRESS%type;

	L_PHONE_TYPE PER_PHONES.PHONE_TYPE%type;
	L_PHONE_NUMBER PER_PHONES.PHONE_NUMBER%type;

	L_NATIONALITY VARCHAR2(30);
	L_NATIONAL_IDENTIFIER PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER%type;

	--
	/*Select state ment modified for the employee number
	 not getting displayed for Ex-Employee*/
	cursor csr_person_data is
	SELECT  DECODE ( ppf.CURRENT_NPW_FLAG , 'Y', NPW_NUMBER,EMPLOYEE_NUMBER ) EMPLOYEE_NUMBER,
	        HR_PERSON_TYPE_USAGE_INFO.GET_USER_PERSON_TYPE(SYSDATE , PPF.PERSON_ID) ,
	        DATE_OF_BIRTH,
	        TOWN_OF_BIRTH,
	        COUNTRY_OF_BIRTH,
	        DATE_OF_DEATH,
	        ORIGINAL_DATE_OF_HIRE,
	        EFFECTIVE_START_DATE,
	        HL1.MEANING SEX,
	        HL4.MEANING MARITAL_STATUS,
	        FULL_NAME,
	        PRE_NAME_ADJUNCT,
	        SUFFIX,
	        HL3.MEANING TITLE,
	        LAST_NAME,
	        FIRST_NAME,
	        MIDDLE_NAMES,
	        ADDRESS_TYPE,
	        padr.DATE_FROM,
	        COUNTRY,
	        ADDRESS_LINE1,
	        ADDRESS_LINE2,
	        ADDRESS_LINE3,
	        TOWN_OR_CITY,
	        TELEPHONE_NUMBER_1,
	        REGION_1,
	        REGION_2,
	        POSTAL_CODE,
	        EMAIL_ADDRESS,
	        PHONE_TYPE,
	        PHONE_NUMBER,
	        HL2.MEANING NATIONALITY,
	        NATIONAL_IDENTIFIER

	FROM    PER_ALL_PEOPLE_F ppf,
	        PER_ADDRESSES padr ,
	        PER_PHONES ppn ,
	        hr_lookups HL1 ,
	        HR_LOOKUPS HL2 ,
	        HR_LOOKUPS HL3 ,
	        HR_LOOKUPS HL4
	WHERE   ppf.person_id = padr.person_id (+)
	    AND ( padr.person_id is null
	     OR ( padr.person_id is not null
	    AND padr.primary_flag ='Y'
	    AND ppf.person_id     = padr.person_id
	    and sysdate  between padr.date_from and nvl (padr.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))
	   ))
	    AND ppn.PARENT_ID (+) = PPF.PERSON_ID
	    -- Modified for the bug 6895752 starts here
	    /*AND ( ppn.parent_id is null
	     OR ( ppn.parent_id is not null
	    AND PPN.PARENT_TABLE            = 'PER_ALL_PEOPLE_F'
	    AND PPN.PHONE_TYPE              = 'W1' ))*/



	    AND PPN.PARENT_TABLE  (+)          = 'PER_ALL_PEOPLE_F'
	    AND PPN.PHONE_TYPE (+)             = 'W1'
	    -- Modified for the bug 6895752 ends here
	    AND ((ppf.CURRENT_EMPLOYEE_FLAG = 'Y'
	     OR ppf.person_id               in   -- modified for bug6873563
	        (SELECT nvl(pps.person_id , -100)
	        FROM    per_periods_of_service pps
	        WHERE   pps.person_id         = ppf.person_id
	            AND pps.business_group_id = ppf.business_group_id
	            and  ACTUAL_TERMINATION_DATE is not null
	        ))
	     OR ( ppf.CURRENT_NPW_FLAG = 'Y'
	     OR ppf.person_id          in   -- modified for bug6873563
	        (SELECT nvl(ppp.person_id , -100)
	        FROM    per_periods_of_placement ppp
	        WHERE   ppp.person_id         = ppf.person_id
	            AND ppp.business_group_id = ppf.business_group_id
	            and  ACTUAL_TERMINATION_DATE is not null
	        )))
	    AND HL1.LOOKUP_TYPE (+)     = 'SEX'
	    AND HL1.LOOKUP_CODE (+)     = ppf.SEX
	    AND HL2.LOOKUP_TYPE (+)     = 'NATIONALITY'
	    AND HL2.LOOKUP_CODE (+)     = Ppf.NATIONALITY
	    AND HL3.LOOKUP_TYPE (+)     = 'TITLE'
	    AND HL3.LOOKUP_CODE (+)     = PPF.TITLE
	    AND HL4.LOOKUP_TYPE (+)     = 'MAR_STATUS'
	    AND HL4.LOOKUP_CODE (+)     = PPF.MARITAL_STATUS
	    AND sysdate BETWEEN effective_start_date AND effective_end_date ;



	 cursor csr_psft_sync is
	 select COUNT ('1')
	 from   hr_psft_sync_run
	 where  process = 'PERSON_FULL_SYNC'
	 and    run_date > sysdate
	 and    status = 'STARTED';

	 l_dummy number;
	 l_current_date date;

	begin
	   open csr_psft_sync;
	   fetch csr_psft_sync into l_dummy;
	   close csr_psft_sync;

	  if l_dummy = 0  then
	   l_current_date :=sysdate;

	   FND_FILE.NEW_LINE(FND_FILE.log, 1);
	   FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
	   FND_FILE.put_line(fnd_file.log,'Person Full Synch Data Extraction Begins:'||to_char(l_current_date, 'DD/MM/RRRR HH:MI:SS'));
	   hr_full_sync_messages.insert_psft_sync_run(2,'PERSON_FULL_SYNC',errbuf,retcode);

	  open csr_person_data;
	  loop
	   fetch csr_person_data into L_EMPLOYEE_NUMBER,L_USER_PERSON_TYPE,L_DATE_OF_BIRTH,L_TOWN_OF_BIRTH,L_COUNTRY_OF_BIRTH
	,L_DATE_OF_DEATH ,L_ORIGINAL_DATE_OF_HIRE,L_EFFECTIVE_START_DATE
	, L_SEX,L_MARITAL_STATUS,L_FULL_NAME,L_PRE_NAME_ADJUNCT ,L_SUFFIX
	,L_TITLE,L_LAST_NAME,L_FIRST_NAME ,L_MIDDLE_NAMES, L_ADDRESS_TYPE ,L_DATE_FROM ,L_COUNTRY, L_ADDRESS_LINE1,
	L_ADDRESS_LINE2,L_ADDRESS_LINE3,L_TOWN_OR_CITY ,L_TELEPHONE_NUMBER_1,L_REGION_1 ,L_REGION_2,
	L_POSTAL_CODE, L_EMAIL_ADDRESS, L_PHONE_TYPE
	,L_PHONE_NUMBER,L_NATIONALITY ,L_NATIONAL_IDENTIFIER ;

	    exit when csr_person_data%notfound;
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,L_EMPLOYEE_NUMBER||fnd_global.local_chr(400)||L_USER_PERSON_TYPE||fnd_global.local_chr(400)||L_DATE_OF_BIRTH
	    ||fnd_global.local_chr(400)||L_TOWN_OF_BIRTH||fnd_global.local_chr(400)||L_COUNTRY_OF_BIRTH||fnd_global.local_chr(400)||L_DATE_OF_DEATH
	    ||fnd_global.local_chr(400)||L_ORIGINAL_DATE_OF_HIRE||fnd_global.local_chr(400)||L_EFFECTIVE_START_DATE||fnd_global.local_chr(400)||L_SEX
	    ||fnd_global.local_chr(400)||L_MARITAL_STATUS||fnd_global.local_chr(400)||L_FULL_NAME||fnd_global.local_chr(400)||L_PRE_NAME_ADJUNCT
	    ||fnd_global.local_chr(400)||L_SUFFIX||fnd_global.local_chr(400)||L_TITLE||fnd_global.local_chr(400)||L_LAST_NAME
	    ||fnd_global.local_chr(400)||L_FIRST_NAME||fnd_global.local_chr(400)||L_MIDDLE_NAMES||fnd_global.local_chr(400)||L_ADDRESS_TYPE
	    ||fnd_global.local_chr(400)||L_DATE_FROM||fnd_global.local_chr(400)||L_COUNTRY||fnd_global.local_chr(400)||L_ADDRESS_LINE1
	    ||fnd_global.local_chr(400)||L_ADDRESS_LINE2||fnd_global.local_chr(400)||L_ADDRESS_LINE3||fnd_global.local_chr(400)||L_TOWN_OR_CITY
	    ||fnd_global.local_chr(400)||L_TELEPHONE_NUMBER_1||fnd_global.local_chr(400)||L_REGION_1||fnd_global.local_chr(400)||L_REGION_2
	    ||fnd_global.local_chr(400)||L_PHONE_NUMBER||fnd_global.local_chr(400)||L_NATIONALITY||fnd_global.local_chr(400)||L_NATIONAL_IDENTIFIER
	    );
	    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
	    end loop;
	    close csr_person_data;

		hr_full_sync_messages.update_psft_sync_run(1,'PERSON_FULL_SYNC',l_current_date,errbuf,retcode);
	  	 FND_FILE.NEW_LINE(FND_FILE.log, 1);
		 FND_FILE.put_line(fnd_file.log,'Person Full Synch Data Extraction Ends:'||to_char(l_current_date, 'DD/MM/RRRR HH:MI:SS'));

	    END if;

	  exception
	       when OTHERS then
	        hr_full_sync_messages.update_psft_sync_run(3,'PERSON_FULL_SYNC',l_current_date,errbuf,retcode);
        	errbuf := errbuf||SQLERRM;
        	retcode := '1';
        	FND_FILE.put_line(fnd_file.log, 'Error in Person Full Synch Data Extraction: '||SQLCODE);
        	FND_FILE.NEW_LINE(FND_FILE.log, 1);
        	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

	end hr_person_full_sync;
/*Procedure to extract Country data for Full Synch messages Ends*/

/*Procedure to extract Job data for Full Synch messages Begins*/

		PROCEDURE hr_jobcode_full_sync(errbuf  OUT NOCOPY VARCHAR2
		 							 ,retcode OUT NOCOPY VARCHAR2)
		IS

		jobcode_full jobcode;
		p_cnt number := 0 ;
		p_eff_date DATE default sysdate;
		l_current_date date default sysdate;

		cursor fet_psft_sync is
		select count('x')
		from   hr_psft_sync_run
		where  process = 'JOBCODE_FULL_SYNC'
		and    run_date < p_eff_date
		and    status = 'STARTED';

		l_dummy number;

		 begin

		 open fet_psft_sync;
		 fetch fet_psft_sync into l_dummy;
		 close fet_psft_sync;

		if l_dummy = 0
		then

		FND_FILE.NEW_LINE(FND_FILE.log, 1);
		FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
		FND_FILE.put_line(fnd_file.log,'Job Code Full Synch Data Extraction Begins:'||to_char(l_current_date, 'DD/MM/RRRR HH:MI:SS'));
		hr_full_sync_messages.insert_psft_sync_run(2,'JOBCODE_FULL_SYNC',errbuf,retcode);

		OPEN jobcode_full FOR
		SELECT BUSINESS_GROUP_ID SETID,
		JOB_ID JOBCODE,
		DATE_FROM EFFDT,
		DECODE(DATE_TO,NULL,'ACTIVE','INACTIVE') EFF_STATUS,
		NAME DESCR
		FROM PER_JOBS
		WHERE last_update_date <= p_eff_date;

		LOOP
		BEGIN
		FETCH jobcode_full BULK COLLECT
		INTO Jobcodefulltype.SETID
		,Jobcodefulltype.JOBCODE
		,Jobcodefulltype.EFFDT
		,Jobcodefulltype.EFF_STATUS
		,Jobcodefulltype.DESCR;


		END;

		if Jobcodefulltype.jobcode.count <=0 then
		    CLOSE jobcode_full;
		    EXIT;
		end if;

		p_cnt := p_cnt + Jobcodefulltype.jobcode.count;

		if  jobcode_full%NOTFOUND then
		    CLOSE jobcode_full;
		    EXIT;
		end if;

		END LOOP;

		FOR I IN 1 .. p_cnt Loop

		FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
		             Jobcodefulltype.SETID(I)||fnd_global.local_chr(400)||
		             Jobcodefulltype.JOBCODE(I)||fnd_global.local_chr(400)||
		             Jobcodefulltype.EFFDT(I)||fnd_global.local_chr(400)||
		             Jobcodefulltype.EFF_STATUS(I)||fnd_global.local_chr(400)||
		             Jobcodefulltype.DESCR(I)
		);
		FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
		END Loop;
		end if;
		   hr_full_sync_messages.update_psft_sync_run(1,'JOBCODE_FULL_SYNC',l_current_date,errbuf,retcode);
		   FND_FILE.NEW_LINE(FND_FILE.log, 1);
		   FND_FILE.put_line(fnd_file.log,'Job Code Full Synch Data Extraction Ends:'||to_char(l_current_date, 'DD/MM/RRRR HH:MI:SS'));

		EXCEPTION WHEN OTHERS THEN
		        update_psft_sync_run(3,'JOBCODE_FULL_SYNC',l_current_date,errbuf,retcode);
		        errbuf := errbuf||SQLERRM;
		        retcode := '1';
		        FND_FILE.put_line(fnd_file.log, 'Error in jobcode_fullsync: '||SQLCODE);
		        FND_FILE.NEW_LINE(FND_FILE.log, 1);
		        FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

		END hr_jobcode_full_sync;

/*Procedure to extract Job data for Full Synch messages Ends*/

/*Procedure to extract Workforce data for Full Synch messages Begins*/

			procedure hr_workforce_full_sync(errbuf  OUT NOCOPY VARCHAR2
			 							     ,retcode OUT NOCOPY VARCHAR2)
			is
			p_eff_date  DATE default sysdate;
			workforce_full workforce;
			p_cnt number default 0 ;
			l_current_date date default sysdate;

			cursor fet_psft_sync is
			select count('x')
			from   hr_psft_sync_run
			where  process = 'WORKFORCE_FULL_SYNC'
			and    run_date < p_eff_date
			and    status = 'STARTED';
			l_dummy number;

			begin

			 open fet_psft_sync;
			 fetch fet_psft_sync into l_dummy;
			 close fet_psft_sync;

			if l_dummy = 0
			then

				FND_FILE.NEW_LINE(FND_FILE.log, 1);
				FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
				FND_FILE.put_line(fnd_file.log,'Workforce Full Synch Data Extraction Begins:'||to_char(l_current_date, 'DD/MM/RRRR HH:MI:SS'));
				hr_full_sync_messages.insert_psft_sync_run(2,'WORKFORCE_FULL_SYNC',errbuf,retcode);

			OPEN workforce_full FOR
            SELECT ppf.employee_number,1 AS empl_rcd ,ppf.original_date_of_hire,
            pas.probation_period,pas.effective_start_date effdt,pas.organization_id,
            pas.job_id,pas.assignment_status_type_id,pas.location_id,
            pas.employment_category,pas.business_group_id,pas.normal_hours,
            pas.frequency,pas.grade_id,pas.supervisor_id,pas.EFFECTIVE_START_DATE,
            nvl(pas.EFFECTIVE_END_DATE,sysdate) EFFECTIVE_END_DATE,
            nvl(psf.step_id,0) Step_id
            ,pos.final_process_date,pos.ACCEPTED_TERMINATION_DATE
            FROM per_all_people_f ppf,per_all_assignments_f pas,
            per_periods_of_service pos,PER_SPINAL_POINT_PLACEMENTS_F psf
            WHERE pas.primary_flag='Y'
            AND pos.person_id=pas.person_id
            AND ppf.person_id = pos.person_id
            AND pas.business_group_id = psf.business_group_id(+)
            AND pas.assignment_id = psf.assignment_id(+)
            AND ppf.BUSINESS_GROUP_ID = pas.BUSINESS_GROUP_ID
            AND pas.effective_start_date BETWEEN ppf.effective_start_date(+) AND
            ppf.effective_end_date(+)
            AND pas.last_update_date < = sysdate;

LOOP
BEGIN
FETCH workforce_full BULK COLLECT
INTO WorkForceFullType.EMPLID
,WorkForceFullType.EMPL_RCD
,WorkForceFullType.ORIG_HIRE_DT
,WorkForceFullType.PROBATION_DT
,WorkForceFullType.EFFDT
,WorkForceFullType.BUSINESS_UNIT
,WorkForceFullType.JOBCODE
,WorkForceFullType.EMPL_STATUS
,WorkForceFullType.LOCATION
,WorkForceFullType.FULL_PART_TIME
,WorkForceFullType.COMPANY
,WorkForceFullType.STD_HOURS
,WorkForceFullType.STD_HRS_FREQUENCY
,WorkForceFullType.GRADE
,WorkForceFullType.SUPERVISOR_ID
,WorkForceFullType.ASGN_START_DT
,WorkForceFullType.ASGN_END_DT
,WorkForceFullType.STEP
,WorkForceFullType.TERMINATION_DT
,WorkForceFullType.LAST_DATE_WORKED;


END;



if WorkForceFullType.EMPLID.count <=0 then
    CLOSE workforce_full;
    EXIT;
end if;

p_cnt := p_cnt + WorkForceFullType.EMPLID.count;

if  workforce_full%NOTFOUND then
    CLOSE workforce_full;
    EXIT;
end if;

END LOOP;


			FOR I IN 1 .. p_cnt Loop

			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
			            WorkForceFullType.EMPLID(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.EMPL_RCD(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.ORIG_HIRE_DT(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.PROBATION_DT(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.EFFDT(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.BUSINESS_UNIT(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.JOBCODE(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.EMPL_STATUS(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.LOCATION(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.FULL_PART_TIME(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.COMPANY(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.STD_HOURS(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.STD_HRS_FREQUENCY(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.GRADE(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.SUPERVISOR_ID(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.ASGN_START_DT(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.ASGN_END_DT(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.STEP(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.TERMINATION_DT(I)||fnd_global.local_chr(400)||
                        WorkForceFullType.LAST_DATE_WORKED(I)
			         );

			FND_FILE.NEW_LINE(FND_FILE.output, 1);
			END Loop;

			   hr_full_sync_messages.update_psft_sync_run(1,'WORKFORCE_FULL_SYNC',l_current_date,errbuf,retcode);
			   FND_FILE.NEW_LINE(FND_FILE.log, 1);
			   FND_FILE.put_line(fnd_file.log,'Work Force Full Synch Data Extraction Ends:'||to_char(l_current_date, 'DD/MM/RRRR HH:MI:SS'));

			End if;

			EXCEPTION
			WHEN OTHERS THEN
			        hr_full_sync_messages.update_psft_sync_run(3,'WORKFORCE_FULL_SYNC',l_current_date,errbuf,retcode);
			        errbuf := errbuf||SQLERRM;
			        retcode := '1';
			        FND_FILE.put_line(fnd_file.log, 'Error in workforce_fullsync: '||SQLCODE);
			        FND_FILE.NEW_LINE(FND_FILE.log, 1);
			        FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

			end hr_workforce_full_sync;

/*Procedure to extract the workforce data for full synch process ends*/

/*Procedure to extract the organization data for full synch process begins*/
		procedure hr_organizaton_full_sync(errbuf  OUT NOCOPY VARCHAR2
		 								   ,retcode OUT NOCOPY VARCHAR2)
		is
		p_bg_id hr_all_organization_units.business_group_id%type;
		p_dept_id hr_all_organization_units.organization_id%type;
		p_eff_date date;
		p_loc_id hr_all_organization_units.location_id%type;
		p_person_id per_org_manager_v.person_id%type;
		p_full_name per_org_manager_v.full_name%type;
		p_bg_name hr_all_organization_units.name%type;
		p_eff_status varchar2(10);
		p_effective_date date default sysdate;

	          cursor fet_org_fsync is
        	  select org.business_group_id,
                    org.organization_id,
                    case when org.date_to is null then org.date_from
                    else org.date_to end,
                    case when org.date_to is null then 'ACTIVE'
                    else 'INACTIVE' end,
                    org.name,
                    org.location_id,
                    mgr.person_id,
                    mgr.full_name
             from hr_all_organization_units org
             ,per_org_manager_v mgr,hr_organization_information hrorg
              where org.business_group_id = mgr.business_group_id(+)
             and  org.organization_id = mgr.organization_id(+)
              and hrorg.organization_id = org.organization_id
             and hrorg.org_information1 = 'HR_ORG'
             and p_effective_date between org.date_from
             and nvl(org.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))
             and  p_effective_date between mgr.start_date(+) and mgr.end_date(+);



        	 cursor fet_psft_sync is
        	 select count('x')
        	 from   hr_psft_sync_run
        	 where  process = 'ORG_FULL_SYNC'
        	 and    run_date < p_effective_date
        	 and    status = 'STARTED';

        	 l_dummy number;

        	 begin

        	 	open fet_psft_sync;
        	 	fetch fet_psft_sync into l_dummy;
        	   	close fet_psft_sync;
        	 	if l_dummy = 0
        	 	then
        			FND_FILE.NEW_LINE(FND_FILE.log, 1);
          			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        		 	FND_FILE.put_line(fnd_file.log,'Organization Full Synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
        		 	hr_full_sync_messages.insert_psft_sync_run(2,'ORG_FULL_SYNC',errbuf,retcode);
        		open fet_org_fsync;
        	  	loop
        	    	fetch fet_org_fsync into p_bg_id,p_dept_id,p_eff_date,p_eff_status,p_bg_name,p_loc_id,p_person_id,p_full_name;
        	    	exit when fet_org_fsync%notfound;

        	    	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_bg_id||fnd_global.local_chr(400)||p_dept_id||fnd_global.local_chr(400)||p_eff_date||
                        fnd_global.local_chr(400)||
                        p_eff_status||fnd_global.local_chr(400)||p_bg_name||fnd_global.local_chr(400)||
                        p_loc_id||fnd_global.local_chr(400)||p_person_id||fnd_global.local_chr(400)||p_full_name);
                    	 FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        		end loop;
        	    	close fet_org_fsync;


        	 	 hr_full_sync_messages.update_psft_sync_run(1,'ORG_FULL_SYNC',p_effective_date,errbuf,retcode);
        	 	 FND_FILE.NEW_LINE(FND_FILE.log, 1);
        		 FND_FILE.put_line(fnd_file.log,'Organization Full Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        	 end if;

        	  exception
        	       when OTHERS then
        	        hr_full_sync_messages.update_psft_sync_run(3,'ORG_FULL_SYNC',p_effective_date,errbuf,retcode);
                	errbuf := errbuf||SQLERRM;
                	retcode := '1';
                	FND_FILE.put_line(fnd_file.log, 'Error in Organization Data Full Synch Extraction: '||SQLCODE);
                	FND_FILE.NEW_LINE(FND_FILE.log, 1);
                	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));
		end hr_organizaton_full_sync;
/*Procedure to extract the organization data for full synch process ends*/

/*Procedure to extract the business group data for full synch process begins*/
		procedure hr_businessgrp_full_sync(errbuf  OUT NOCOPY VARCHAR2
		 								   ,retcode OUT NOCOPY VARCHAR2)
		is

		p_bg_id PER_BUSINESS_GROUPS.business_group_id%type;
		p_bg_name PER_BUSINESS_GROUPS.name%type;
		p_eff_status varchar2(10);
		p_eff_date date;
		p_effective_date date default sysdate;

        	 cursor fet_bg_fsync is
        	 select business_group_id,
                    name,
                    case when date_to is null then date_from
                    else date_to end,
                    case when date_to is null then 'ACTIVE'
                    else 'INACTIVE' end
             from PER_BUSINESS_GROUPS
             where p_effective_date between date_from and
             nvl (date_to, to_date('31-12-4712', 'DD-MM-YYYY'));


        	 cursor fet_psft_sync is
        	 select count('x')
        	 from   hr_psft_sync_run
        	 where  process = 'BG_FULL_SYNC'
        	 and    run_date < p_effective_date
        	 and    status = 'STARTED';

        	 l_dummy number;

        	 begin

        	 	open fet_psft_sync;
        	 	fetch fet_psft_sync into l_dummy;
        	   	close fet_psft_sync;
        	 	if l_dummy = 0
        	 	then
        			FND_FILE.NEW_LINE(FND_FILE.log, 1);
          			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        		 	FND_FILE.put_line(fnd_file.log,'Business Group Full Synch Data Extraction Begins:'
				||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
        		 	hr_full_sync_messages.insert_psft_sync_run(2,'BG_FULL_SYNC',errbuf,retcode);
        		open fet_bg_fsync;
        	  	loop
        	    	fetch fet_bg_fsync into p_bg_id,p_bg_name,p_eff_date,p_eff_status;
        	    	exit when fet_bg_fsync%notfound;
        	    	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_bg_id||fnd_global.local_chr(400)||p_bg_name||fnd_global.local_chr(400)||
			p_eff_date||fnd_global.local_chr(400)||p_eff_status);
			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        		end loop;
        	    	close fet_bg_fsync;


        	 	 hr_full_sync_messages.update_psft_sync_run(1,'BG_FULL_SYNC',p_effective_date,errbuf,retcode);
        	 	 FND_FILE.NEW_LINE(FND_FILE.log, 1);
        		 FND_FILE.put_line(fnd_file.log,'Business Group Full Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        	 end if;

        	  exception
        	       when OTHERS then
        	        hr_full_sync_messages.update_psft_sync_run(3,'BG_FULL_SYNC',p_effective_date,errbuf,retcode);
                	errbuf := errbuf||SQLERRM;
                	retcode := '1';
                	FND_FILE.put_line(fnd_file.log, 'Error in Business Group Data Full Synch Extraction: '||SQLCODE);
                	FND_FILE.NEW_LINE(FND_FILE.log, 1);
                	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));
		end hr_businessgrp_full_sync;
/*Procedure to extract the business group data for full synch process ends*/

/*Procedure to extract the payroll group data for full synch process begins*/
		procedure hr_payroll_full_sync(errbuf  OUT NOCOPY VARCHAR2
		                               ,retcode OUT NOCOPY VARCHAR2)
		is
        		p_pyrl_id pay_all_payrolls_f.payroll_id%type;
        		p_pyrl_name pay_all_payrolls_f.payroll_name%type;
        		p_bg_id pay_all_payrolls_f.business_group_id%type;
        		p_eff_date date;
        		p_eff_status varchar2(10);
        		p_effective_date date default sysdate;

        	 cursor fet_pyrl_fsync is
        	 select  payroll_id,
        	        payroll_name,
        	        business_group_id,
        	        case when p_effective_date > add_months(first_period_end_date,NUMBER_OF_YEARS*12)
        	        then add_months(first_period_end_date,NUMBER_OF_YEARS*12) else (select min(effective_start_date) from
                                                                                     pay_all_payrolls_f pay1
                                                                                     where pay1.payroll_id = pay.payroll_id
                                                                                     and pay1.business_group_id = pay.business_group_id) end,
        	        case when p_effective_date > add_months(first_period_end_date,NUMBER_OF_YEARS*12)
        	        then 'INACTIVE' else 'ACTIVE' end
        	 from pay_all_payrolls_f pay
             where p_effective_date between effective_start_date and effective_end_date;


        	 cursor fet_psft_sync is
        	 select count('x')
        	 from   hr_psft_sync_run
        	 where  process = 'PYRL_FULL_SYNC'
        	 and    run_date < p_effective_date
        	 and    status = 'STARTED';

        	 l_dummy number;

        	 begin

        	 	open fet_psft_sync;
        	 	fetch fet_psft_sync into l_dummy;
        	   	close fet_psft_sync;
        	 	if l_dummy = 0
        	 	then
        			FND_FILE.NEW_LINE(FND_FILE.log, 1);
          			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        		 	FND_FILE.put_line(fnd_file.log,'Payroll Full Synch Data Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));
        		 	hr_full_sync_messages.insert_psft_sync_run(2,'PYRL_FULL_SYNC',errbuf,retcode);
        		open fet_pyrl_fsync;
        	  	loop

          	    	fetch fet_pyrl_fsync into p_pyrl_id,p_pyrl_name,p_bg_id,p_eff_date,p_eff_status;
        	    	exit when fet_pyrl_fsync%notfound;
        	    	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_pyrl_id||fnd_global.local_chr(400)||
			p_pyrl_name||fnd_global.local_chr(400)||p_bg_id||fnd_global.local_chr(400)||p_eff_date||fnd_global.local_chr(400)||p_eff_status);
			FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        		end loop;
        	    	close fet_pyrl_fsync;


        	 	 hr_full_sync_messages.update_psft_sync_run(1,'PYRL_FULL_SYNC',p_effective_date,errbuf,retcode);
        	 	 FND_FILE.NEW_LINE(FND_FILE.log, 1);
        		 FND_FILE.put_line(fnd_file.log,'Payroll Full Synch Data Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        	 end if;

        	  exception
        	       when OTHERS then
        	        hr_full_sync_messages.update_psft_sync_run(3,'PYRL_FULL_SYNC',p_effective_date,errbuf,retcode);
                	errbuf := errbuf||SQLERRM;
                	retcode := '1';
                	FND_FILE.put_line(fnd_file.log, 'Error in Payroll Data Full Synch Extraction: '||SQLCODE);
                	FND_FILE.NEW_LINE(FND_FILE.log, 1);
                	FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));
		end hr_payroll_full_sync;
/*Procedure to extract the payroll group data for full synch process ends*/

 /*Common Procedure called from concurrent program begins*/
		procedure hr_full_sync (ERRBUF           OUT NOCOPY varchar2,
		                        RETCODE          OUT NOCOPY number,
		                        p_process_name in varchar2)
		is
		begin

		 if p_process_name = 'STATE_FULL_SYNCH'
		  then
		  hr_full_sync_messages.hr_state_full_sync(ERRBUF,RETCODE);
		  elsif p_process_name = 'COUNTRY_FULL_SYNCH'
		  then
		  hr_full_sync_messages.hr_country_full_sync(ERRBUF,RETCODE);
		  elsif p_process_name = 'LOCATION_FULL_SYNCH'
		  then
		  hr_full_sync_messages.hr_location_full_sync(ERRBUF,RETCODE);
		  elsif p_process_name = 'PERSON_FULL_SYNCH'
		  then
		  hr_full_sync_messages.hr_person_full_sync(ERRBUF,RETCODE);
		  elsif p_process_name = 'WORKFORCE_FULL_SYNCH'
		  then
		  hr_full_sync_messages.hr_workforce_full_sync(ERRBUF,RETCODE);
		  elsif p_process_name = 'JOBCODE_FULL_SYNCH' then
		  hr_full_sync_messages.hr_jobcode_full_sync(ERRBUF,RETCODE);
		  elsif p_process_name = 'ORGANIZATION_FULL_SYNCH' then
		  hr_full_sync_messages.hr_organizaton_full_sync(ERRBUF,RETCODE);
		  elsif p_process_name = 'BUSINESSGROUP_FULL_SYNCH' then
		  hr_full_sync_messages.hr_businessgrp_full_sync(ERRBUF,RETCODE);
		  elsif p_process_name = 'PAYROLL_FULL_SYNCH' then
		  hr_full_sync_messages.hr_payroll_full_sync(ERRBUF,RETCODE);
		  end if;
		end hr_full_sync;
/*Common Procedure called from concurrent program ends*/

end hr_full_sync_messages;

/
