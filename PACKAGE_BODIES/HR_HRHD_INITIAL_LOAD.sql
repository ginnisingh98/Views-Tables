--------------------------------------------------------
--  DDL for Package Body HR_HRHD_INITIAL_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HRHD_INITIAL_LOAD" as
/* $Header: perhdfsyn.pkb 120.3.12010000.12 2009/05/13 08:54:34 sathkris noship $ */

p_effective_date DATE default sysdate;

/*Procedure to extract Location Initial Load Extraction Begins*/
    PROCEDURE  HR_LOCATION_INITIAL_LOAD(errbuf  OUT NOCOPY VARCHAR2
                        ,retcode OUT NOCOPY VARCHAR2)
    is

     p_bg_id              hr_locations_all.business_group_id%type;
     p_loc_id             hr_locations_all.LOCATION_ID%type;
     p_active_date        varchar2(10);
     p_effecive_status    varchar2(10);
     p_lang_code          varchar2(10);
     p_loc_desc           hr_locations_all.DESCRIPTION%type;
     p_loc_style          hr_locations_all.STYLE%type;
     p_add_line_1         hr_locations_all.ADDRESS_LINE_1%type;
     p_add_line_2         hr_locations_all.ADDRESS_LINE_2%type;
     p_add_line_3         hr_locations_all.ADDRESS_LINE_3%type;
     p_town_or_city       hr_locations_all.TOWN_OR_CITY%type;
     p_country            hr_locations_all.COUNTRY%type;
     p_postal_code        hr_locations_all.POSTAL_CODE%type;
     p_region_1           hr_locations_all.REGION_1%type;
     p_region_2           hr_locations_all.REGION_2%type;
     p_region_3           hr_locations_all.REGION_3%type;
     p_tel_no_1           hr_locations_all.TELEPHONE_NUMBER_1%type;
     p_tel_no_2           hr_locations_all.TELEPHONE_NUMBER_2%type;
     p_tel_no_3           hr_locations_all.TELEPHONE_NUMBER_3%type;
     p_loc_info_13        hr_locations_all.LOC_INFORMATION13%type;
     p_loc_info_14        hr_locations_all.LOC_INFORMATION14%type;
     p_loc_info_15        hr_locations_all.LOC_INFORMATION15%type;
     p_loc_info_16        hr_locations_all.LOC_INFORMATION16%type;
     p_loc_info_17        hr_locations_all.LOC_INFORMATION17%type;
     p_loc_info_18        hr_locations_all.LOC_INFORMATION18%type;
     p_loc_info_19        hr_locations_all.LOC_INFORMATION19%type;
     p_loc_info_20        hr_locations_all.LOC_INFORMATION20%type;


    /*CURSOR TO FETCH THE LOCATION DETAILS*/
     cursor CSR_LOC_INITIAL_LOAD is
         select  hloc.BUSINESS_GROUP_ID,
         to_char(hloc.CREATION_DATE,'YYYY-MM-DD'),
             'A' ,
            hloc.LOCATION_ID,
            tl.language,
            tl.DESCRIPTION,
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
            hr_locations_all hloc,hr_locations_all_tl tl
            where tl.location_id = hloc.location_id
            and nvl(inactive_date,to_date('31/12/4712','DD/MM/YYYY')) > sysdate
         union
            select  hloc.BUSINESS_GROUP_ID,
            to_char(inactive_date,'YYYY-MM-DD'),
             'I',
            hloc.LOCATION_ID,
            tl.language,
            tl.DESCRIPTION,
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
            hr_locations_all hloc,hr_locations_all_tl tl
            where tl.location_id = hloc.location_id
            and inactive_date is not null
            order by  business_group_id,location_id ;

    begin


            FND_FILE.NEW_LINE(FND_FILE.log, 1);
              FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
            FND_FILE.put_line(fnd_file.log,'Location Initial Load Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

                 /*Generate the initial load extraction for location and the column delimiter used is to_char(400)*/
              open CSR_LOC_INITIAL_LOAD;
              loop
                fetch CSR_LOC_INITIAL_LOAD into p_bg_id,p_active_date,p_effecive_status,p_loc_id,p_lang_code,
                    p_loc_desc, p_loc_style , p_country, p_add_line_1, p_add_line_2, p_add_line_3,
                    p_town_or_city,p_region_1,p_region_2,p_region_3,p_postal_code,p_tel_no_1,p_tel_no_2 ,
                    p_tel_no_3,p_loc_info_13,    p_loc_info_14,p_loc_info_15,p_loc_info_16,p_loc_info_17,p_loc_info_18,
                    p_loc_info_19,p_loc_info_20;

                exit when CSR_LOC_INITIAL_LOAD%NOTFOUND;


                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_bg_id||
                fnd_global.local_chr(400)||p_active_date||
                fnd_global.local_chr(400)||p_effecive_status||
                fnd_global.local_chr(400)||p_loc_id||
                fnd_global.local_chr(400)||p_lang_code||
		fnd_global.local_chr(400)||p_loc_desc||
                fnd_global.local_chr(400)||p_loc_style ||
                fnd_global.local_chr(400)|| p_add_line_1||
                fnd_global.local_chr(400)||p_add_line_2||
                fnd_global.local_chr(400)|| p_add_line_3||
                fnd_global.local_chr(400)||p_town_or_city||
                fnd_global.local_chr(400)||p_country||
                fnd_global.local_chr(400)||p_postal_code||
                fnd_global.local_chr(400)||p_region_1||
                fnd_global.local_chr(400)||p_region_2||
                fnd_global.local_chr(400)||p_region_3||
                fnd_global.local_chr(400)||p_tel_no_1||
                fnd_global.local_chr(400)||p_tel_no_2 ||
                fnd_global.local_chr(400)||p_tel_no_3||
                fnd_global.local_chr(400)||p_loc_info_13||
                fnd_global.local_chr(400)||p_loc_info_14||
                fnd_global.local_chr(400)||p_loc_info_15||
                fnd_global.local_chr(400)||p_loc_info_16||
                fnd_global.local_chr(400)||p_loc_info_17||
                fnd_global.local_chr(400)||p_loc_info_18||
                fnd_global.local_chr(400)||p_loc_info_19||
                fnd_global.local_chr(400)||p_loc_info_20||
                fnd_global.local_chr(10)||fnd_global.local_chr(13));



                end loop;
                close CSR_LOC_INITIAL_LOAD;


           FND_FILE.NEW_LINE(FND_FILE.log, 1);
         FND_FILE.put_line(fnd_file.log,'Location Initial Load Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));


      exception
           when OTHERS then
            errbuf := errbuf||SQLERRM;
            retcode := '1';
            FND_FILE.put_line(fnd_file.log, 'Error in Location Initial Load Extraction: '||SQLCODE);
            FND_FILE.NEW_LINE(FND_FILE.log, 1);
            FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

     END HR_LOCATION_INITIAL_LOAD;
/*Procedure to extract Location Initial Load Extraction Ends*/

/*Procedure to extract Job Initial Load Extraction Begins*/

        PROCEDURE HR_JOBCODE_INITIAL_LOAD(errbuf  OUT NOCOPY VARCHAR2
                          ,retcode OUT NOCOPY VARCHAR2)
        IS


        p_job_id            per_jobs.job_id%type;
        p_business_grp_id   per_jobs.business_group_id%type;
        p_eff_date          varchar2(10);
        p_lang_code         varchar2(10);
        p_eff_status        varchar2(10);
        p_job_descr         per_jobs_tl.name%type;

        /*Cursor to fetch the job details*/

        cursor csr_job_initial_load is
        select pj.job_id,
        business_group_id,
        tl.language,
        tl.name,
        to_char(DATE_FROM,'YYYY-MM-DD') ,
        'A'
        from per_jobs pj,per_jobs_tl tl
        where pj.job_id = tl.job_id
        and nvl(date_to,to_date('31/12/4712','DD/MM/YYYY')) > sysdate
     union
       select pj.job_id,
        business_group_id,
        tl.language,
        tl.name,
        to_char(DATE_TO,'YYYY-MM-DD') ,
        'I'
        from per_jobs pj,per_jobs_tl tl
        where pj.job_id = tl.job_id
        and date_to is not null
        order by business_group_id,job_id;



         begin


        FND_FILE.NEW_LINE(FND_FILE.log, 1);
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        FND_FILE.put_line(fnd_file.log,'Job Code Initial Load Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        /*Generate the initial load extraction for job and the column delimiter used is to_char(400)*/
        OPEN csr_job_initial_load;

        LOOP

                FETCH csr_job_initial_load
                INTO p_job_id,p_business_grp_id,p_lang_code,p_job_descr,p_eff_date,p_eff_status;
                EXIT WHEN csr_job_initial_load%NOTFOUND;


                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                         p_business_grp_id||fnd_global.local_chr(400)||
                         p_job_id||fnd_global.local_chr(400)||
                         p_eff_date||fnd_global.local_chr(400)||
                         p_eff_status||fnd_global.local_chr(400)||
                         p_lang_code||fnd_global.local_chr(400)||
                         p_job_descr||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));

        END Loop;
                CLOSE csr_job_initial_load;

           FND_FILE.NEW_LINE(FND_FILE.log, 1);
           FND_FILE.put_line(fnd_file.log,'Job Code Initial Load Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        EXCEPTION WHEN OTHERS THEN
                errbuf := errbuf||SQLERRM;
                retcode := '1';
                FND_FILE.put_line(fnd_file.log, 'Error in Job Initial Load Extraction: '||SQLCODE);
                FND_FILE.NEW_LINE(FND_FILE.log, 1);
                FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

        END HR_JOBCODE_INITIAL_LOAD;

/*Procedure to extract Job Initial Load Ends*/



/*Procedure to extract Organization Initial Load Extraction Begins*/

        PROCEDURE HR_ORGANIZATION_INITIAL_LOAD(errbuf  OUT NOCOPY VARCHAR2
                          ,retcode OUT NOCOPY VARCHAR2)
        IS


        p_bg_id         hr_all_organization_units.business_group_id%type;
        p_org_id        hr_all_organization_units.organization_id%type;
        p_lang_code     varchar2(10);
        p_bg_name       hr_all_organization_units_tl.name%type;
        p_eff_status    varchar2(10);
        p_loc_id        hr_all_organization_units.location_id%type;
        p_eff_date      varchar2(10);
        p_person_id     per_org_manager_v.person_id%type;



        /*Cursor to fetch the organization details
        If date_to is in future then
         two records has to be fetched in the format
         Date_From 'A'
         Date_To   'I'

         If date_to is in past then
         one record has to be fetched as
         Date_To 'I'*/

        cursor csr_org_initial_load is
        select ORG.BUSINESS_GROUP_ID,
               ORG.ORGANIZATION_ID,
               to_char(DATE_FROM,'YYYY-MM-DD') ,
               'A' ,
               TL.LANGUAGE,
               TL.NAME,
               ORG.LOCATION_ID,
	       /*Fix for 7576511 - to fetch employee number*/
               (select employee_number from per_all_people_f ppf,hr_organization_information hrorg1
			where ppf.person_id = hrorg1.ORG_INFORMATION2
			and   ppf.business_group_id  = org.business_group_id
			and hrorg1.org_information_context = 'Organization Name Alias'
			and   hrorg1.organization_id =   org.organization_id
			and   nvl(org.date_to,to_date('31/12/4712','DD/MM/YYYY')) between fnd_date.canonical_to_date(hrorg1.org_information3)
			and nvl(fnd_date.canonical_to_date(hrorg1.org_information4),to_date('31/12/4712','DD/MM/YYYY'))
			and fnd_date.canonical_to_date(hrorg1.org_information3) between ppf.effective_start_date and ppf.effective_end_date) MANAGER_ID

	     from hr_all_organization_units org,hr_all_organization_units_tl TL
             ,hr_organization_information hrorg
             where  tl.organization_id  = org.organization_id
             and hrorg.organization_id = org.organization_id
             and hrorg.org_information1 = 'HR_ORG'
             and nvl(date_to,to_date('31/12/4712','DD/MM/YYYY')) > sysdate
    union
        select ORG.BUSINESS_GROUP_ID,
               ORG.ORGANIZATION_ID,
               to_char(DATE_TO,'YYYY-MM-DD') ,
               'I' ,
               TL.LANGUAGE,
               TL.NAME,
               ORG.LOCATION_ID,
               /*Fix for 7576511 - to fetch employee number*/
               (select employee_number from per_all_people_f ppf,hr_organization_information hrorg1
			where ppf.person_id = hrorg1.ORG_INFORMATION2
			and   ppf.business_group_id  = org.business_group_id
			and hrorg1.org_information_context = 'Organization Name Alias'
			and   hrorg1.organization_id =   org.organization_id
			and   nvl(org.date_to,to_date('31/12/4712','DD/MM/YYYY')) between fnd_date.canonical_to_date(hrorg1.org_information3)
			and nvl(fnd_date.canonical_to_date(hrorg1.org_information4),to_date('31/12/4712','DD/MM/YYYY'))
			and fnd_date.canonical_to_date(hrorg1.org_information3) between ppf.effective_start_date and ppf.effective_end_date) MANAGER_ID

             from hr_all_organization_units org,hr_all_organization_units_tl TL
             ,hr_organization_information hrorg
             where  tl.organization_id  = org.organization_id
             and hrorg.organization_id = org.organization_id
             and hrorg.org_information1 = 'HR_ORG'
             and date_to is not null
             order by business_group_id,organization_id;


         begin


        FND_FILE.NEW_LINE(FND_FILE.log, 1);
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        FND_FILE.put_line(fnd_file.log,'Organization Initial Load Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        /*Generate the initial load extraction for organization and the column delimiter used is to_char(400)*/
        OPEN csr_org_initial_load;

        LOOP

                FETCH csr_org_initial_load
                INTO p_bg_id,p_org_id,p_eff_date,p_eff_status,p_lang_code,p_bg_name,p_loc_id,p_person_id;
                EXIT WHEN csr_org_initial_load%NOTFOUND;


                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                         p_bg_id||fnd_global.local_chr(400)||
                         p_org_id||fnd_global.local_chr(400)||
                         p_eff_date||fnd_global.local_chr(400)||
                         p_eff_status||fnd_global.local_chr(400)||
                         p_lang_code||fnd_global.local_chr(400)||
                         p_bg_name||fnd_global.local_chr(400)||
                         p_loc_id||fnd_global.local_chr(400)||
                         p_person_id||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));

        END Loop;
                CLOSE csr_org_initial_load;

           FND_FILE.NEW_LINE(FND_FILE.log, 1);
           FND_FILE.put_line(fnd_file.log,'Organization Initial Load Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        EXCEPTION WHEN OTHERS THEN
                errbuf := errbuf||SQLERRM;
                retcode := '1';
                FND_FILE.put_line(fnd_file.log, 'Error in Organization Initial Load Extraction: '||SQLCODE);
                FND_FILE.NEW_LINE(FND_FILE.log, 1);
                FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

        END HR_ORGANIZATION_INITIAL_LOAD;

/*Procedure to extract Organization Initial Load Ends*/


/*Procedure to extract Workforce Initial Load Extraction Begins*/

        PROCEDURE HR_WORKFORCE_INITIAL_LOAD(errbuf  OUT NOCOPY VARCHAR2
                          ,retcode OUT NOCOPY VARCHAR2)
        IS


        p_person_id                     per_all_people_f.person_id%type;
        p_assignment_id                 per_all_assignments_f.assignment_id%type;
        p_assignment_number             per_all_assignments_f.assignment_number%type;
        p_effective_start_date          varchar2(10);
        p_effective_end_date            varchar2(10);
        p_probation_period              per_all_assignments_f.probation_period%type;
        p_probation_units               per_all_assignments_f.probation_unit%type;
        p_organization_id               per_all_assignments_f.organization_id%type;
        p_job_id                        per_all_assignments_f.job_id%type;
        p_position_id                   per_all_assignments_f.position_id%type;
        p_assignment_status_type_id     per_all_assignments_f.assignment_status_type_id%type;
        p_location_id                   per_all_assignments_f.location_id%type;
        p_employment_category           per_all_assignments_f.employment_category%type;
        p_business_group_id             per_all_assignments_f.business_group_id%type;
        p_normal_hours                  per_all_assignments_f.normal_hours%type;
        p_frequency                     per_all_assignments_f.frequency%type;
        p_grade_id                      per_all_assignments_f.grade_id%type;
        p_supervisor_id                 per_all_assignments_f.supervisor_id%type;
        p_act_termn_date                varchar2(10);
        p_final_prcs_date               varchar2(10);
	p_primary_flag                  per_all_assignments_f.primary_flag%type;



        /*Cursor to fetch the workforce details*/

        cursor csr_wkfrc_initial_load is
        SELECT
            pas.person_id,
            pas.assignment_id,
            pas.assignment_number,
            to_char(pas.effective_start_date,'YYYY-MM-DD'),
            to_char(pas.effective_end_date,'YYYY-MM-DD'),
            pas.probation_period,
            pas.probation_unit,
            pas.organization_id,
            pas.job_id,
            pas.position_id,
            pas.assignment_status_type_id,
            pas.location_id,
            pas.employment_category,
            pas.business_group_id,
            pas.normal_hours,
            pas.frequency,
            pas.grade_id,
            pas.supervisor_id,

            case when (pas.person_id = pos.person_id and pas.effective_end_date = pos.actual_termination_date) then
             to_char(pos.final_process_date,'YYYY-MM-DD')
             when (pas.person_id = pop.person_id and pas.effective_end_date = pop.actual_termination_date) then to_char(pop.final_process_date,'YYYY-MM-DD') end  ,

            case when (pas.person_id = pos.person_id and pas.effective_end_date = pos.actual_termination_date)
            then to_char(pos.ACTUAL_TERMINATION_DATE,'YYYY-MM-DD')
            when (pas.person_id = pop.person_id and pas.effective_end_date = pop.actual_termination_date) then to_char(pop.ACTUAL_TERMINATION_DATE,'YYYY-MM-DD') end ,

	    primary_flag

            FROM
            per_all_assignments_f pas,
            per_periods_of_service pos,
            per_periods_of_placement pop
            WHERE pas.person_id = pop.person_id (+)
            AND pas.person_id = pos.person_id (+)
            order by pas.business_group_id,pas.assignment_id,pas.effective_start_date;


         begin


        FND_FILE.NEW_LINE(FND_FILE.log, 1);
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
        FND_FILE.put_line(fnd_file.log,'Workforce Initial Load Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        /*Generate the initial load extraction for workforce and the column delimiter used is to_char(400)*/
        OPEN csr_wkfrc_initial_load;

        LOOP

                FETCH csr_wkfrc_initial_load
                INTO p_person_id,p_assignment_id,p_assignment_number,p_effective_start_date,p_effective_end_date,
                p_probation_period,p_probation_units,p_organization_id,p_job_id,p_position_id,p_assignment_status_type_id,
                p_location_id,p_employment_category,p_business_group_id,p_normal_hours,p_frequency,p_grade_id,
                p_supervisor_id ,p_act_termn_date, p_final_prcs_date,p_primary_flag;
                EXIT WHEN csr_wkfrc_initial_load%NOTFOUND;


                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                         p_business_group_id||fnd_global.local_chr(400)||
                         p_person_id||fnd_global.local_chr(400)||
                         p_assignment_id||fnd_global.local_chr(400)||
                         p_assignment_number||fnd_global.local_chr(400)||
                         p_effective_start_date||fnd_global.local_chr(400)||
                         p_effective_end_date||fnd_global.local_chr(400)||
                         p_organization_id||fnd_global.local_chr(400)||
                         p_probation_period||fnd_global.local_chr(400)||
                         p_probation_units||fnd_global.local_chr(400)||
                         p_job_id||fnd_global.local_chr(400)||
                         p_assignment_status_type_id||fnd_global.local_chr(400)||
                         p_location_id||fnd_global.local_chr(400)||
                         p_employment_category||fnd_global.local_chr(400)||
                         p_normal_hours||fnd_global.local_chr(400)||
                         p_frequency||fnd_global.local_chr(400)||
                         p_grade_id||fnd_global.local_chr(400)||
                         p_position_id||fnd_global.local_chr(400)||
                         p_supervisor_id||fnd_global.local_chr(400)||
                         p_act_termn_date||fnd_global.local_chr(400)||
                         p_final_prcs_date||fnd_global.local_chr(400)||
			 p_primary_flag||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));

        END Loop;
                CLOSE csr_wkfrc_initial_load;

           FND_FILE.NEW_LINE(FND_FILE.log, 1);
           FND_FILE.put_line(fnd_file.log,'Workforce Initial Load Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        EXCEPTION WHEN OTHERS THEN
                errbuf := errbuf||SQLERRM;
                retcode := '1';
                FND_FILE.put_line(fnd_file.log, 'Error in Workforce Initial Load Extraction: '||SQLCODE);
                FND_FILE.NEW_LINE(FND_FILE.log, 1);
                FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

        END HR_WORKFORCE_INITIAL_LOAD;

/*Procedure to extract Workforce Initial Load Ends*/


/*Procedure to extract Person Initial Load Extraction Begins*/

        PROCEDURE HR_PERSON_INITIAL_LOAD(errbuf  OUT NOCOPY VARCHAR2
                                        ,retcode OUT NOCOPY VARCHAR2)
        IS

        p_person_id                     per_all_people_f.person_id%type;
        p_business_group_id             per_all_people_f.business_group_id%type;
        p_legislation_code              hr_organization_information.org_information9%type;
        p_employee_number               per_all_people_f.employee_number%type;
        p_applicant_number              per_all_people_f.applicant_number%type;
        p_npw_number                    per_all_people_f.npw_number%type;
        p_person_type_id                per_all_people_f.person_type_id%type;
        p_date_of_birth                 varchar2(10);
        p_town_of_birth                 per_all_people_f.town_of_birth%type;
        p_cntry_of_birth                per_all_people_f.country_of_birth%type;
        p_date_of_death                 varchar2(10);
        p_orig_dt_of_hire               varchar2(10);
        p_eff_start_date                varchar2(10);
        p_eff_end_date                  varchar2(10);
        p_sex                           per_all_people_f.sex%type;
        p_full_name                     per_all_people_f.full_name%type;
        p_suffix                        per_all_people_f.suffix%type;
        p_title                         per_all_people_f.title%type;
        p_last_name                     per_all_people_f.last_name%type;
        p_first_name                    per_all_people_f.first_name%type;
        p_middle_names                  per_all_people_f.middle_names%type;
        p_nationality                   per_all_people_f.nationality%type;
        p_national_identifier           per_all_people_f.national_identifier%type;
        p_email_address                 per_all_people_f.email_address%type;
	p_national_id_label             varchar2(200);


        TYPE ADDRESS IS RECORD
        (

        p_address_type                  per_addresses.address_type%type,
         p_address_style                  per_addresses.style%type,
        p_adr_date_from                 varchar2(10),
        p_adr_date_to                   varchar2(10),
        p_country                       per_addresses.country%type,
        p_addr_line1                    per_addresses.address_line1%type,
        p_addr_line2                    per_addresses.address_line2%type,
        p_addr_line3                    per_addresses.address_line3%type,
        p_twn_or_city                   per_addresses.town_or_city%type,
        p_tel_number1                   per_addresses.telephone_number_1%type,
        p_region1                       per_addresses.region_1%type,
        p_region2                       per_addresses.region_2%type,
        p_postal_code                   per_addresses.postal_code%type,
	p_primary_flag			per_addresses.primary_flag%type);

        TYPE address_record is table of ADDRESS index by binary_integer;

        TYPE PHONE IS RECORD
        (

        p_phn_date_from                 varchar2(10),
        p_phn_date_to                   varchar2(10),
        p_phone_type                    per_phones.phone_type%type,
        p_phone_no                      per_phones.phone_number%type);

        TYPE phone_record is table of PHONE index by binary_integer;

        p_addr_type address_record;
        p_phn_type phone_record;


        /*Cursor to fetch the person details*/

        cursor csr_person_data is
         SELECT ppf.person_id,
                ppf.business_group_id,
                (select org_information9 from
                    hr_organization_information where organization_id = ppf.business_group_id
                    and org_information_context = 'Business Group Information') LEGISLATION_CODE,
                EMPLOYEE_NUMBER,
                APPLICANT_NUMBER,
                NPW_NUMBER,
                PERSON_TYPE_ID ,
                to_char(DATE_OF_BIRTH,'YYYY-MM-DD'),
                TOWN_OF_BIRTH,
                COUNTRY_OF_BIRTH,
                to_char(DATE_OF_DEATH,'YYYY-MM-DD'),
                to_char(ORIGINAL_DATE_OF_HIRE,'YYYY-MM-DD'),
                to_char(EFFECTIVE_START_DATE,'YYYY-MM-DD'),
                to_char(EFFECTIVE_END_DATE,'YYYY-MM-DD'),
                SEX,
                FULL_NAME,
                SUFFIX,
                TITLE,
                LAST_NAME,
                FIRST_NAME,
                MIDDLE_NAMES,
                NATIONALITY,
                NATIONAL_IDENTIFIER,
                EMAIL_ADDRESS,
		(select message_text from fnd_new_messages where message_name = 'HR_NATIONAL_ID_NUMBER_'|| (select to_char(org_information9) from
                hr_organization_information where organization_id = ppf.business_group_id
                 and org_information_context = 'Business Group Information')
                and language_code = USERENV('LANG') )NATIONAL_IDENTIFIER_LABEL

        FROM    PER_ALL_PEOPLE_F ppf
        order by ppf.person_id,ppf.effective_start_date;

      Cursor Csr_Address_Data(P_Person_Id Number,P_Eff_St_Dt Date,P_Eff_End_Dt Date) Is
      Select

             Address_Type,
             style,
             To_Char(Date_From,'YYYY-MM-DD'),
             To_Char(Date_To,'YYYY-MM-DD'),
             Country,
             Address_Line1,
             Address_Line2,
             Address_Line3,
             Town_Or_City,
             Telephone_Number_1,
             Region_1,
             Region_2,
             Postal_Code,
	     Primary_Flag
        FROM per_addresses
        where person_id = p_person_id
        and   date_from between  P_Eff_St_Dt and P_Eff_End_Dt;

        Cursor csr_phone_data(P_Person_Id Number,P_Eff_St_Dt Date,P_Eff_End_Dt Date) Is
        Select

                to_char(ppn.date_from,'YYYY-MM-DD'),
                to_char(ppn.date_to,'YYYY-MM-DD'),
                PHONE_TYPE,
                PHONE_NUMBER
           FROM per_phones ppn
           where  ppn.PARENT_ID (+) = P_PERSON_ID
            AND PPN.PARENT_TABLE  (+)          = 'PER_ALL_PEOPLE_F'
            AND DATE_FROM between  P_Eff_St_Dt and P_Eff_End_Dt;


         begin

                FND_FILE.NEW_LINE(FND_FILE.log, 1);
                FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
                FND_FILE.put_line(fnd_file.log,'Person Initial Load Extraction Begins:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

                 /*Generate the initial load extraction for location and the column delimiter used is to_char(400)*/

        /*Generate the initial load extraction for person and the column delimiter used is to_char(400)*/
        OPEN csr_person_data;
        loop
            fetch csr_person_data into p_person_id,p_business_group_id,p_legislation_code,p_employee_number,p_applicant_number,p_npw_number,p_person_type_id,
                                       p_date_of_birth,p_town_of_birth,p_cntry_of_birth,p_date_of_death,p_orig_dt_of_hire,p_eff_start_date,
                                       p_eff_end_date,p_sex,p_full_name,p_suffix,p_title,p_last_name,p_first_name,p_middle_names,
                                       p_nationality,p_national_identifier,p_email_address,p_national_id_label;
            exit when csr_person_data%notfound;

            open csr_address_data(p_person_id,to_date(p_eff_start_date,'YYYY-MM-DD'),to_date(p_eff_end_date,'YYYY-MM-DD'));
            fetch csr_address_data bulk collect into p_addr_type;
            close csr_address_data;

            open csr_phone_data(p_person_id,to_date(p_eff_start_date,'YYYY-MM-DD'),to_date(p_eff_end_date,'YYYY-MM-DD'));
            fetch csr_phone_data bulk collect into p_phn_type;
            close csr_phone_data;

               if p_addr_type.count > 0 and p_phn_type.count > 0 and p_addr_type.count >= p_phn_type.count
                then

                for k in p_addr_type.first .. p_addr_type.last
                loop
                         if k <= p_phn_type.count
                        then

                        FND_FILE.put_line(FND_FILE.OUTPUT,
                         p_business_group_id||fnd_global.local_chr(400)||
                         p_person_id||fnd_global.local_chr(400)||
                         p_legislation_code||fnd_global.local_chr(400)||
                         p_employee_number||fnd_global.local_chr(400)||
                         p_applicant_number||fnd_global.local_chr(400)||
                         p_npw_number||fnd_global.local_chr(400)||
                         p_person_type_id||fnd_global.local_chr(400)||
                         p_date_of_birth||fnd_global.local_chr(400)||
                         p_town_of_birth||fnd_global.local_chr(400)||
                         p_cntry_of_birth||fnd_global.local_chr(400)||
                         p_date_of_death||fnd_global.local_chr(400)||
                         p_orig_dt_of_hire||fnd_global.local_chr(400)||
                         p_eff_start_date||fnd_global.local_chr(400)||
                         p_eff_end_date||fnd_global.local_chr(400)||
                         p_sex||fnd_global.local_chr(400)||
                         p_full_name||fnd_global.local_chr(400)||
                         p_suffix||fnd_global.local_chr(400)||
                         p_title||fnd_global.local_chr(400)||
                         p_last_name||fnd_global.local_chr(400)||
                         p_first_name||fnd_global.local_chr(400)||
                         p_middle_names||fnd_global.local_chr(400)||
                         p_nationality||fnd_global.local_chr(400)||
                         p_national_identifier||fnd_global.local_chr(400)||
                         p_email_address||fnd_global.local_chr(400)||
                         p_addr_type(k).p_address_type||fnd_global.local_chr(400)||
                         p_addr_type(k).p_adr_date_from||fnd_global.local_chr(400)||
                         p_addr_type(k).p_adr_date_to||fnd_global.local_chr(400)||
                         p_addr_type(k).p_address_style||fnd_global.local_chr(400)||
                         p_addr_type(k).p_country||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line2||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line3||fnd_global.local_chr(400)||
                         p_addr_type(k).p_twn_or_city||fnd_global.local_chr(400)||
                         p_addr_type(k).p_tel_number1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_region1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_region2||fnd_global.local_chr(400)||
                         p_addr_type(k).p_postal_code ||fnd_global.local_chr(400)||
			 p_addr_type(k).p_primary_flag ||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phn_date_from||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phn_date_to||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phone_type ||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phone_no||fnd_global.local_chr(400)||
			 p_national_id_label||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_person_id)||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_business_group_id)||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));


                        else

                         FND_FILE.put_line(FND_FILE.OUTPUT,
                         p_business_group_id||fnd_global.local_chr(400)||
                         p_person_id||fnd_global.local_chr(400)||
                         p_legislation_code||fnd_global.local_chr(400)||
                         p_employee_number||fnd_global.local_chr(400)||
                         p_applicant_number||fnd_global.local_chr(400)||
                         p_npw_number||fnd_global.local_chr(400)||
                         p_person_type_id||fnd_global.local_chr(400)||
                         p_date_of_birth||fnd_global.local_chr(400)||
                         p_town_of_birth||fnd_global.local_chr(400)||
                         p_cntry_of_birth||fnd_global.local_chr(400)||
                         p_date_of_death||fnd_global.local_chr(400)||
                         p_orig_dt_of_hire||fnd_global.local_chr(400)||
                         p_eff_start_date||fnd_global.local_chr(400)||
                         p_eff_end_date||fnd_global.local_chr(400)||
                         p_sex||fnd_global.local_chr(400)||
                         p_full_name||fnd_global.local_chr(400)||
                         p_suffix||fnd_global.local_chr(400)||
                         p_title||fnd_global.local_chr(400)||
                         p_last_name||fnd_global.local_chr(400)||
                         p_first_name||fnd_global.local_chr(400)||
                         p_middle_names||fnd_global.local_chr(400)||
                         p_nationality||fnd_global.local_chr(400)||
                         p_national_identifier||fnd_global.local_chr(400)||
                         p_email_address||fnd_global.local_chr(400)||
                         p_addr_type(k).p_address_type||fnd_global.local_chr(400)||
                         p_addr_type(k).p_adr_date_from||fnd_global.local_chr(400)||
                         p_addr_type(k).p_adr_date_to||fnd_global.local_chr(400)||
                         p_addr_type(k).p_address_style||fnd_global.local_chr(400)||
                         p_addr_type(k).p_country||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line2||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line3||fnd_global.local_chr(400)||
                         p_addr_type(k).p_twn_or_city||fnd_global.local_chr(400)||
                         p_addr_type(k).p_tel_number1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_region1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_region2||fnd_global.local_chr(400)||
                         p_addr_type(k).p_postal_code ||fnd_global.local_chr(400)||
			 p_addr_type(k).p_primary_flag ||fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
			 p_national_id_label||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_person_id)||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_business_group_id)||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));


                         end if;
                 end loop;
                end if;

                if p_addr_type.count > 0 and p_phn_type.count > 0 and p_addr_type.count < p_phn_type.count
                then

                for k in p_phn_type.first .. p_phn_type.last
                loop
                        if k <= p_addr_type.count
                        then

                        FND_FILE.put_line(FND_FILE.OUTPUT,
                         p_business_group_id||fnd_global.local_chr(400)||
                         p_person_id||fnd_global.local_chr(400)||
                         p_legislation_code||fnd_global.local_chr(400)||
                         p_employee_number||fnd_global.local_chr(400)||
                         p_applicant_number||fnd_global.local_chr(400)||
                         p_npw_number||fnd_global.local_chr(400)||
                         p_person_type_id||fnd_global.local_chr(400)||
                         p_date_of_birth||fnd_global.local_chr(400)||
                         p_town_of_birth||fnd_global.local_chr(400)||
                         p_cntry_of_birth||fnd_global.local_chr(400)||
                         p_date_of_death||fnd_global.local_chr(400)||
                         p_orig_dt_of_hire||fnd_global.local_chr(400)||
                         p_eff_start_date||fnd_global.local_chr(400)||
                         p_eff_end_date||fnd_global.local_chr(400)||
                         p_sex||fnd_global.local_chr(400)||
                         p_full_name||fnd_global.local_chr(400)||
                         p_suffix||fnd_global.local_chr(400)||
                         p_title||fnd_global.local_chr(400)||
                         p_last_name||fnd_global.local_chr(400)||
                         p_first_name||fnd_global.local_chr(400)||
                         p_middle_names||fnd_global.local_chr(400)||
                         p_nationality||fnd_global.local_chr(400)||
                         p_national_identifier||fnd_global.local_chr(400)||
                         p_email_address||fnd_global.local_chr(400)||
                         p_addr_type(k).p_address_type||fnd_global.local_chr(400)||
                         p_addr_type(k).p_adr_date_from||fnd_global.local_chr(400)||
                         p_addr_type(k).p_adr_date_to||fnd_global.local_chr(400)||
                         p_addr_type(k).p_address_style||fnd_global.local_chr(400)||
                         p_addr_type(k).p_country||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line2||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line3||fnd_global.local_chr(400)||
                         p_addr_type(k).p_twn_or_city||fnd_global.local_chr(400)||
                         p_addr_type(k).p_tel_number1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_region1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_region2||fnd_global.local_chr(400)||
                         p_addr_type(k).p_postal_code ||fnd_global.local_chr(400)||
			 p_addr_type(k).p_primary_flag ||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phn_date_from||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phn_date_to||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phone_type ||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phone_no||fnd_global.local_chr(400)||
			 p_national_id_label||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_person_id)||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_business_group_id)||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));

                        else

                         FND_FILE.put_line(FND_FILE.OUTPUT,
                         p_business_group_id||fnd_global.local_chr(400)||
                         p_person_id||fnd_global.local_chr(400)||
                         p_legislation_code||fnd_global.local_chr(400)||
                         p_employee_number||fnd_global.local_chr(400)||
                         p_applicant_number||fnd_global.local_chr(400)||
                         p_npw_number||fnd_global.local_chr(400)||
                         p_person_type_id||fnd_global.local_chr(400)||
                         p_date_of_birth||fnd_global.local_chr(400)||
                         p_town_of_birth||fnd_global.local_chr(400)||
                         p_cntry_of_birth||fnd_global.local_chr(400)||
                         p_date_of_death||fnd_global.local_chr(400)||
                         p_orig_dt_of_hire||fnd_global.local_chr(400)||
                         p_eff_start_date||fnd_global.local_chr(400)||
                         p_eff_end_date||fnd_global.local_chr(400)||
                         p_sex||fnd_global.local_chr(400)||
                         p_full_name||fnd_global.local_chr(400)||
                         p_suffix||fnd_global.local_chr(400)||
                         p_title||fnd_global.local_chr(400)||
                         p_last_name||fnd_global.local_chr(400)||
                         p_first_name||fnd_global.local_chr(400)||
                         p_middle_names||fnd_global.local_chr(400)||
                         p_nationality||fnd_global.local_chr(400)||
                         p_national_identifier||fnd_global.local_chr(400)||
                         p_email_address||fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
			 fnd_global.local_chr(400)||
                         p_phn_type(k).p_phn_date_from||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phn_date_to||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phone_type ||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phone_no||fnd_global.local_chr(400)||
			 p_national_id_label||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_person_id)||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_business_group_id)||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));
                         end if;
                 end loop;
                 end if;

                if  p_phn_type.count > 0 and p_addr_type.count = 0
                then
                 for k in p_phn_type.first .. p_phn_type.last
                loop

                  FND_FILE.put_line(FND_FILE.OUTPUT,
                         p_business_group_id||fnd_global.local_chr(400)||
                         p_person_id||fnd_global.local_chr(400)||
                         p_legislation_code||fnd_global.local_chr(400)||
                         p_employee_number||fnd_global.local_chr(400)||
                         p_applicant_number||fnd_global.local_chr(400)||
                         p_npw_number||fnd_global.local_chr(400)||
                         p_person_type_id||fnd_global.local_chr(400)||
                         p_date_of_birth||fnd_global.local_chr(400)||
                         p_town_of_birth||fnd_global.local_chr(400)||
                         p_cntry_of_birth||fnd_global.local_chr(400)||
                         p_date_of_death||fnd_global.local_chr(400)||
                         p_orig_dt_of_hire||fnd_global.local_chr(400)||
                         p_eff_start_date||fnd_global.local_chr(400)||
                         p_eff_end_date||fnd_global.local_chr(400)||
                         p_sex||fnd_global.local_chr(400)||
                         p_full_name||fnd_global.local_chr(400)||
                         p_suffix||fnd_global.local_chr(400)||
                         p_title||fnd_global.local_chr(400)||
                         p_last_name||fnd_global.local_chr(400)||
                         p_first_name||fnd_global.local_chr(400)||
                         p_middle_names||fnd_global.local_chr(400)||
                         p_nationality||fnd_global.local_chr(400)||
                         p_national_identifier||fnd_global.local_chr(400)||
                         p_email_address||fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
			 fnd_global.local_chr(400)||
                         p_phn_type(k).p_phn_date_from||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phn_date_to||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phone_type ||fnd_global.local_chr(400)||
                         p_phn_type(k).p_phone_no||fnd_global.local_chr(400)||
			 p_national_id_label||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_person_id)||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_business_group_id)||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));

                 end loop;
                 end if;

                if  p_addr_type.count > 0 and p_phn_type.count = 0
                then
                 for k in p_addr_type.first .. p_addr_type.last
                loop

                         FND_FILE.put_line(FND_FILE.OUTPUT,
                         p_business_group_id||fnd_global.local_chr(400)||
			 p_person_id||fnd_global.local_chr(400)||
                         p_legislation_code||fnd_global.local_chr(400)||
                         p_employee_number||fnd_global.local_chr(400)||
                         p_applicant_number||fnd_global.local_chr(400)||
                         p_npw_number||fnd_global.local_chr(400)||
                         p_person_type_id||fnd_global.local_chr(400)||
                         p_date_of_birth||fnd_global.local_chr(400)||
                         p_town_of_birth||fnd_global.local_chr(400)||
                         p_cntry_of_birth||fnd_global.local_chr(400)||
                         p_date_of_death||fnd_global.local_chr(400)||
                         p_orig_dt_of_hire||fnd_global.local_chr(400)||
                         p_eff_start_date||fnd_global.local_chr(400)||
                         p_eff_end_date||fnd_global.local_chr(400)||
                         p_sex||fnd_global.local_chr(400)||
                         p_full_name||fnd_global.local_chr(400)||
                         p_suffix||fnd_global.local_chr(400)||
                         p_title||fnd_global.local_chr(400)||
                         p_last_name||fnd_global.local_chr(400)||
                         p_first_name||fnd_global.local_chr(400)||
                         p_middle_names||fnd_global.local_chr(400)||
                         p_nationality||fnd_global.local_chr(400)||
                         p_national_identifier||fnd_global.local_chr(400)||
                         p_email_address||fnd_global.local_chr(400)||
                         p_addr_type(k).p_address_type||fnd_global.local_chr(400)||
                         p_addr_type(k).p_adr_date_from||fnd_global.local_chr(400)||
                         p_addr_type(k).p_adr_date_to||fnd_global.local_chr(400)||
                         p_addr_type(k).p_address_style||fnd_global.local_chr(400)||
                         p_addr_type(k).p_country||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line2||fnd_global.local_chr(400)||
                         p_addr_type(k).p_addr_line3||fnd_global.local_chr(400)||
                         p_addr_type(k).p_twn_or_city||fnd_global.local_chr(400)||
                         p_addr_type(k).p_tel_number1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_region1||fnd_global.local_chr(400)||
                         p_addr_type(k).p_region2||fnd_global.local_chr(400)||
                         p_addr_type(k).p_postal_code ||fnd_global.local_chr(400)||
			 p_addr_type(k).p_primary_flag ||fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
			 p_national_id_label||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_person_id)||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_business_group_id)||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));

                 end loop;
                 end if;

		/*Fix for bug 7650158 starts here*/
		   if  p_addr_type.count = 0 and p_phn_type.count = 0
		    then


                         FND_FILE.put_line(FND_FILE.OUTPUT,
                         p_business_group_id||fnd_global.local_chr(400)||
			 p_person_id||fnd_global.local_chr(400)||
                         p_legislation_code||fnd_global.local_chr(400)||
                         p_employee_number||fnd_global.local_chr(400)||
                         p_applicant_number||fnd_global.local_chr(400)||
                         p_npw_number||fnd_global.local_chr(400)||
                         p_person_type_id||fnd_global.local_chr(400)||
                         p_date_of_birth||fnd_global.local_chr(400)||
                         p_town_of_birth||fnd_global.local_chr(400)||
                         p_cntry_of_birth||fnd_global.local_chr(400)||
                         p_date_of_death||fnd_global.local_chr(400)||
                         p_orig_dt_of_hire||fnd_global.local_chr(400)||
                         p_eff_start_date||fnd_global.local_chr(400)||
                         p_eff_end_date||fnd_global.local_chr(400)||
                         p_sex||fnd_global.local_chr(400)||
                         p_full_name||fnd_global.local_chr(400)||
                         p_suffix||fnd_global.local_chr(400)||
                         p_title||fnd_global.local_chr(400)||
                         p_last_name||fnd_global.local_chr(400)||
                         p_first_name||fnd_global.local_chr(400)||
                         p_middle_names||fnd_global.local_chr(400)||
                         p_nationality||fnd_global.local_chr(400)||
                         p_national_identifier||fnd_global.local_chr(400)||
                         p_email_address||fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
                         fnd_global.local_chr(400)||
			 fnd_global.local_chr(400)||
			 p_national_id_label||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_person_id)||fnd_global.local_chr(400)||
                         hr_hrhd_initial_load.hr_hrhd_encrypt(p_business_group_id)||
                         fnd_global.local_chr(10)||fnd_global.local_chr(13));


                 end if;
		/*Fix for bug 7650158 ends here*/

        END Loop;
               close csr_person_data;


           FND_FILE.NEW_LINE(FND_FILE.log, 1);
           FND_FILE.put_line(fnd_file.log,'Person Initial Load Extraction Ends:'||to_char(p_effective_date, 'DD/MM/RRRR HH:MI:SS'));

        EXCEPTION WHEN OTHERS THEN
                errbuf := errbuf||SQLERRM;
                retcode := '1';
                FND_FILE.put_line(fnd_file.log, 'Error in Person Initial Load Extraction: '||SQLCODE);
                FND_FILE.NEW_LINE(FND_FILE.log, 1);
                FND_FILE.put_line(fnd_file.log, 'Error Msg: '||substr(SQLERRM,1,700));

        END HR_PERSON_INITIAL_LOAD;

/*Procedure to extract Person Initial Load Ends*/


 /*Common Procedure called from concurrent program begins*/
        procedure HR_INITIAL_LOAD (ERRBUF           OUT NOCOPY varchar2,
                                RETCODE          OUT NOCOPY number,
                                p_process_name in varchar2)
        is
        begin

             if p_process_name = 'LOCATION_FULL_SYNCH' then
                HR_HRHD_INITIAL_LOAD.HR_LOCATION_INITIAL_LOAD(ERRBUF,RETCODE);

                elsif p_process_name = 'JOBCODE_FULL_SYNCH' then
                HR_HRHD_INITIAL_LOAD.HR_JOBCODE_INITIAL_LOAD(ERRBUF,RETCODE);

                elsif p_process_name = 'ORGANIZATION_FULL_SYNCH' then
                HR_HRHD_INITIAL_LOAD.HR_ORGANIZATION_INITIAL_LOAD(ERRBUF,RETCODE);

                elsif p_process_name = 'WORKFORCE_FULL_SYNCH' then
                HR_HRHD_INITIAL_LOAD.HR_WORKFORCE_INITIAL_LOAD(ERRBUF,RETCODE);

                elsif p_process_name = 'PERSON_FULL_SYNCH' then
                HR_HRHD_INITIAL_LOAD.HR_PERSON_INITIAL_LOAD(ERRBUF,RETCODE);
              end if;
        end HR_INITIAL_LOAD;
/*Common Procedure called from concurrent program ends*/

/* Function for encrypting */

    function hr_hrhd_encrypt(p_data VARCHAR2 ) RETURN RAW is
    key_bytes_raw      RAW (128);               -- stores 256-bit encryption key
    encryption_type    PLS_INTEGER := FND_CRYPTO.DES3_CBC_PKCS5;
    --DBMS_CRYPTO.HASH_MD5+ DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;      -- total encryption type
    BEGIN

    key_bytes_raw := UTL_I18N.STRING_TO_RAW(fnd_vault.get('HRHD','CRYPT_KEY'));

    RETURN(FND_CRYPTO.ENCRYPT(plaintext => utl_raw.cast_to_raw (p_data),
                            crypto_type => encryption_type, key => key_bytes_raw ));

    END;

/* Function for decrypting */

    function hr_hrhd_decrypt(p_data RAW ) RETURN VARCHAR2 is
    key_bytes_raw      RAW (128);               -- stores 256-bit encryption key
    encryption_type    PLS_INTEGER := FND_CRYPTO.DES3_CBC_PKCS5  ;    -- total encryption type
    --DBMS_CRYPTO.HASH_MD5+ DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
    BEGIN

     key_bytes_raw := UTL_I18N.STRING_TO_RAW(fnd_vault.get('HRHD','CRYPT_KEY'));

    RETURN(UTL_RAW.CAST_TO_VARCHAR2(FND_CRYPTO.DECRYPT(cryptext => p_data,
                            crypto_type => encryption_type, key => key_bytes_raw )));

    END;


end HR_HRHD_INITIAL_LOAD;

/
