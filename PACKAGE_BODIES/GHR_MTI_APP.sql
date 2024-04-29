--------------------------------------------------------
--  DDL for Package Body GHR_MTI_APP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MTI_APP" AS
/* $Header: ghmtiapp.pkb 120.1.12010000.2 2009/08/07 09:36:23 utokachi ship $ */

g_package  varchar2(32) := '  GHR_MTI_APP';
l_log_text varchar2(2000) := null;
l_mass_errbuf   varchar2(2000) := null;

procedure populate_and_create_52(p_errbuf out nocopy varchar2,
                                 p_retcode out nocopy number,
                                 p_business_group_id in number,
                                 p_mtin_name in varchar2,
                                 p_mtin_id in number,
                                 p_effective_date in date) is

cursor cur_people (l_effective_date date,l_person_id number) is
select ppf.first_name   FIRST_NAME,
       ppf.last_name    LAST_NAME,
       ppf.middle_names MIDDLE_NAMES,
       ppf.full_name    FULL_NAME,
       ppf.date_of_birth DATE_OF_BIRTH,
       ppf.national_identifier NATIONAL_IDENTIFIER
  from per_people_f        ppf
 where ppf.person_id    = l_person_id
   and l_effective_date between ppf.effective_start_date
             and nvl(ppf.effective_end_date,l_effective_date+1);

CURSOR ghr_mt_int (p_national_identifier varchar2,p_mt_name varchar2) is
SELECT RETIREMENT_PLAN,
       RETENTION_ALLOWANCE,
       TENURE,
       ANNUITANT_INDICATOR,
       FEGLI,
       TO_POSITION_ID,
       FROM_POSITION_TITLE,
       FROM_POSITION_SEQ_NUM,
       pay_rate_determinant,
       from_step_or_rate,
       APPOINTMENT_TYPE,
       date_arrived_personnel_office,
       wgi_date_due,
       frozen_service,
       -- Bug#2412656 Added FERS_Coverage
       fers_coverage,
       non_disclosure_agmt_status,
       part_time_indicator,
       position_working_title,
       previous_retirement_coverage,
       MT_STATUS,

       FLSA_CATEGORY,
       BARGAINING_UNIT_STATUS,
       functional_class,
       supervisory_status,
       position_occupied,
       appropriation_code1,
       appropriation_code2,

       TYPE_OF_EMPLOYMENT,
       RACE_OR_NATIONAL_ORIGIN,
       AGENCY_CODE_TRANSFER_FROM,
       ORIG_APPOINTMENT_AUTH_CODE_1,
       ORIG_APPT_AUTH_CODE_1_DESC,--Bug# 8724192
       ORIG_APPOINTMENT_AUTH_CODE_2,
       ORIG_APPT_AUTH_CODE_2_DESC,--Bug# 8724192
       HANDICAP_CODE,

       CITIZENSHIP,
       VETERANS_PREFERENCE,
       VETERANS_PREFERENCE_FOR_RIF,
       VETERANS_STATUS,

       WORK_SCHEDULE,
       CREDITABLE_MILITARY_SERVICE,
       -- # BUG # 711533
       SERVICE_COMP_DATE,
       EDUCATIONAL_LEVEL,
       ACADEMIC_DISCIPLINE,
       YEAR_DEGREE_ATTAINED,
       -- Bug # 712305
       PART_TIME_HOURS,
       -- Bug 4093771
       to_basic_salary_rate,
       TO_ADJUSTED_BASIC_PAY,
       TO_TOTAL_SALARY,
       ASSIGNMENT_NTE_START_DATE,--Bug# 8724192
       ASSIGNMENT_NTE--Bug# 8724192
  FROM ghr_mt_interface_v
 WHERE national_identifier = p_national_identifier
   AND mt_name = p_mt_name;

CURSOR ghr_mt_int_count (p_mt_name varchar2) is
select count(*) COUNT
 from ghr_mt_interface_v
where mt_name = p_mt_name
  and mt_status = 'E';

CURSOR PER_EXTRA_CUR (p_mt_id number) is
SELECT PERSON_ID
     , PERSON_EXTRA_INFO_ID
     , OBJECT_VERSION_NUMBER
  FROM PER_PEOPLE_EXTRA_INFO
 WHERE PEI_INFORMATION6  = 'Y'
   AND PEI_INFORMATION8  = to_char(p_mt_id)
   AND INFORMATION_TYPE  = 'GHR_US_PER_MASS_ACTIONS';

CURSOR PA_REQ_EXT_INFO_CUR (p_pa_request_id number) is
SELECT PA_REQUEST_EXTRA_INFO_ID,
       OBJECT_VERSION_NUMBER
  FROM GHR_PA_REQUEST_EXTRA_INFO
 WHERE INFORMATION_TYPE  = 'GHR_US_PAR_APPT_TRANSFER'
   and pa_request_id = p_pa_request_id;

--Begin Bug# 8724192
CURSOR PA_REQ_NTE_EI_CUR (p_pa_request_id number) is
SELECT PA_REQUEST_EXTRA_INFO_ID,
       OBJECT_VERSION_NUMBER
  FROM GHR_PA_REQUEST_EXTRA_INFO
 WHERE INFORMATION_TYPE  = 'GHR_US_MASS_TRNSFR_NTE_DATES'
   and pa_request_id = p_pa_request_id;

CURSOR PA_REQ_APP_AUTH_EI_CUR (p_pa_request_id number) is
SELECT PA_REQUEST_EXTRA_INFO_ID,
       OBJECT_VERSION_NUMBER
  FROM GHR_PA_REQUEST_EXTRA_INFO
 WHERE INFORMATION_TYPE  = 'GHR_US_TRANS_CURN_APP_AUTH'
   and pa_request_id = p_pa_request_id;

--End Bug# 8724192

CURSOR GHR_MTI_CUR (p_mt_id number) is
SELECT PA_REQUEST_ID
  FROM GHR_MASS_TRANSFERS
 WHERE MASS_TRANSFER_ID = p_mt_id
   and TRANSFER_TYPE    = 'IN';

CURSOR c_asg_by_per_id_not_prim (p_per_id number, p_eff_date date) IS
    SELECT asg.assignment_id
    FROM   per_assignments_f asg
    WHERE  asg.person_id = p_per_id
    AND    asg.assignment_type <> 'B'
    AND    trunc(p_eff_date) BETWEEN asg.effective_start_date AND asg.effective_end_date
    ORDER BY asg.assignment_id;

l_pa_request_id             number;
l_lac_sf52_rec              ghr_pa_requests%rowtype;

l_person_id number;
l_employee_assignment_id number;
l_position_id number;
l_RETIREMENT_PLAN      VARCHAR2(30);
l_RETENTION_ALLOWANCE  NUMBER;
l_TENURE 	       VARCHAR2(30);
l_ANNUITANT_INDICATOR  VARCHAR2(30);
l_FEGLI                VARCHAR2(30);

l_flsa_category      varchar2(100);
l_bargaining_unit_status varchar2(100);
l_functional_class       varchar2(100);
l_supervisory_status     varchar2(100);
l_position_occupied      varchar2(100);
l_appropriation_code1    varchar2(100);
l_appropriation_code2    varchar2(100);

l_last_name            per_people_f.last_name%type;
l_first_name           per_people_f.first_name%type;
l_full_name            per_people_f.full_name%type;
l_middle_names         per_people_f.middle_names%type;
l_date_of_birth        varchar2(20);
l_national_identifier  per_people_f.NATIONAL_IDENTIFIER%type;

l_grade_id             number;
l_job_id               number;
l_organization_id      number;

l_position_title       varchar2(300);
l_position_number      varchar2(20);
l_position_seq_no      number(15);

l_pay_rate_determinant varchar2(35);
l_work_schedule        varchar2(35);

l_part_time_hours      varchar2(35);
l_pay_table_id         number;
l_pay_plan             varchar2(30);
l_occ_code             varchar2(30);
l_grade_or_level       varchar2(30);
l_step_or_rate         varchar2(30);
l_pay_basis            varchar2(30);
l_location_id          number;
l_duty_station_id      number;
l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
l_duty_station_code    ghr_pa_requests.duty_station_code%type;
l_mt_status            varchar2(2);

l_org1                 varchar2(40);
l_org2                 varchar2(40);
l_org3                 varchar2(40);
l_org4                 varchar2(40);
l_org5                 varchar2(40);
l_org6                 varchar2(40);
l_dummy                varchar2(35);

l_personnel_office_id  varchar2(300);
l_org_structure_id     varchar2(300);

l_citizenship             varchar2(32);
l_veterans_preference     varchar2(32);
l_veterans_preference_for_RIF varchar2(32);
l_veterans_status             varchar2(32);
l_serv_comp_date              varchar2(32);


l_agency_code_transfer_from    varchar2(32);
l_handicap_code               varchar2(32);
l_orig_appointment_auth_code1 varchar2(32);
l_orig_appointment_auth_code2 varchar2(32);
l_race_or_national_origin     varchar2(32);
l_type_of_employment          varchar2(32);

l_creditable_military_service varchar2(32);

l_appointment_type            varchar2(32);
l_previous_retirement_coverage varchar2(32);
-- Bug#2412656 Added l_fers_coverage
l_fers_coverage                varchar2(32);
l_frozen_service               varchar2(32);
l_date_arr_pers_office         varchar2(20);
l_date_wgi_due               varchar2(20);
l_non_disc_agmt_status varchar2(150);
l_position_working_title varchar2(150);
l_part_time_indicator varchar2(150);

l_sf52_rec                  ghr_pa_requests%rowtype;
l_errbuf                    varchar2(2000);

l_retcode                   number;

l_pos_ei_data               per_position_extra_info%rowtype;
l_pos_grp1_rec              per_position_extra_info%rowtype;
l_pos_grp2_rec              per_position_extra_info%rowtype;
l_per_ei1_data               per_people_extra_info%rowtype;
l_per_ei2_data               per_people_extra_info%rowtype;
l_per_ei3_data               per_people_extra_info%rowtype;
l_per_ei4_data               per_people_extra_info%rowtype;
l_per_ei5_data               per_people_extra_info%rowtype;

l_education_level           ghr_pa_requests.education_level%type;
l_year_degree_attained      ghr_pa_requests.year_degree_attained%type;
l_academic_discipline      ghr_pa_requests.academic_discipline%type;
l_service_comp_date         date;

-- Changes 4093771
l_to_basic_pay ghr_pa_requests.to_basic_pay%type;
l_to_adj_basic_pay ghr_pa_requests.to_adj_basic_pay%type;
l_to_total_salary ghr_pa_requests.to_total_salary%type;
-- End Changes 4093771
--Bug# 8724192
l_orig_appt_auth_code_1_desc  varchar2(80);
l_orig_appt_auth_code_2_desc  varchar2(80);
l_assignment_nte_start_date   varchar2(255);
l_assignment_nte	      varchar2(255);
--Bug# 8724192

l_proc varchar2(72) :=  g_package || '.get_all_52_elements';

l_ms_cnt              number := 0;
l_recs_failed         number := 0;
l_mt_status_err_cnt   number := 0;
l_capped_other_pay number := hr_api.g_number;
BEGIN
  hr_utility.set_location('Entering    ' || l_proc,5);
  hr_utility.set_location('Inside populate and create 52' || l_proc, 15);
  hr_utility.set_location('Mt in id '||to_char(p_mtin_id) ||' Mt in Name '||p_mtin_name ||
         'p_business_grp id '||to_char(p_business_group_id)  || l_proc, 25);
  hr_utility.set_location('Eff date ' || to_char(p_effective_date) || l_proc, 35);

  p_retcode := 0;

  for ghr_mti_rec in ghr_mti_cur (p_mtin_id)
  LOOP
     l_pa_request_id  := ghr_mti_rec.pa_request_id;
     exit;
  END LOOP;

  if l_pa_request_id is null then
       hr_utility.set_message(8301, 'GHR_99999_SELECT_LAC_REMARKS');
       hr_utility.raise_error;
  END IF;

  ghr_msl_pkg.get_lac_dtls(l_pa_request_id,
                           l_lac_sf52_rec);

  hr_utility.set_location('After get_lac_dtls ' || l_proc, 44);
  for per_ext_rec in PER_EXTRA_CUR (p_mtin_id)
  LOOP
   BEGIN
      savepoint EXECUTE_MRE_IN_SP;
      l_ms_cnt := l_ms_cnt + 1;
      l_person_id := per_ext_rec.person_id;

      FOR per IN cur_people (p_effective_date,l_person_id) LOOP
        l_last_name           := per.last_name;
  ----  l_date_of_birth       := to_char(per.DATE_OF_BIRTH, 'DD-MON-YYYY');
        l_date_of_birth       := fnd_date.date_to_canonical(per.DATE_OF_BIRTH);
        l_national_identifier := per.NATIONAL_IDENTIFIER;
        l_first_name          := per.first_name;
        l_middle_names        := per.middle_names;
        l_full_name           := per.full_name;

        exit;
      END LOOP;

      hr_utility.set_location('After fetch people ' || l_proc , 45);
      hr_utility.set_location('Last Name      ' || substr(l_last_name,1,40) , 45);
      hr_utility.set_location('Date of Birth  ' || l_date_of_birth , 45);
      hr_utility.set_location('Bef fetch from intface ' || to_char(l_person_id) || p_mtin_name , 55);

      for per_mt_int in ghr_mt_int (l_national_identifier,p_mtin_name) loop
        l_RETIREMENT_PLAN     := per_mt_int.RETIREMENT_PLAN;
        l_RETENTION_ALLOWANCE := per_mt_int.RETENTION_ALLOWANCE;
        l_TENURE 	            := per_mt_int.TENURE;
        l_ANNUITANT_INDICATOR := per_mt_int.ANNUITANT_INDICATOR;
        l_FEGLI               := per_mt_int.FEGLI;
        l_appointment_type    := per_mt_int.appointment_type;
        l_position_id         := per_mt_int.to_position_id;
        l_pay_rate_determinant := per_mt_int.pay_rate_determinant;
        l_step_or_rate        := per_mt_int.from_step_or_rate;
    --    l_date_arr_pers_office :=
    --            to_char(per_mt_int.date_arrived_personnel_office, 'DD-MON-YYYY');
        l_date_arr_pers_office :=
                fnd_date.date_to_canonical(per_mt_int.date_arrived_personnel_office);
        -- # Bug 711536
    --  l_date_wgi_due := to_char( per_mt_int.wgi_date_due, 'DD-MON-YYYY');
        l_date_wgi_due := fnd_date.date_to_canonical( per_mt_int.wgi_date_due);
        l_non_disc_agmt_status := per_mt_int.non_disclosure_agmt_status;
        l_previous_retirement_coverage := per_mt_int.previous_retirement_coverage;
        l_position_working_title := per_mt_int.position_working_title;
        l_part_time_indicator := per_mt_int.part_time_indicator;
        l_mt_status := per_mt_int.mt_status;

        l_flsa_category       := per_mt_int.flsa_category;
        l_bargaining_unit_status  := per_mt_int.bargaining_unit_status;
        l_functional_class        := per_mt_int.functional_class;
        l_supervisory_status      := per_mt_int.supervisory_status;
        l_position_occupied       := per_mt_int.position_occupied;
        l_appropriation_code1     := per_mt_int.appropriation_code1;
        l_appropriation_code2     := per_mt_int.appropriation_code2;
        -- # Bug # 711533
        l_frozen_service          := per_mt_int.frozen_service;
        -- Bug # 712305
        -- Bug#2412656 Added Fers Coverage
	l_fers_coverage           := per_mt_int.fers_coverage;

        l_part_time_hours         := per_mt_int.part_time_hours;

        l_type_of_employment          := per_mt_int.TYPE_OF_EMPLOYMENT;
        l_race_or_national_origin     := per_mt_int.RACE_OR_NATIONAL_ORIGIN;
        l_orig_appointment_auth_code1 := per_mt_int.ORIG_APPOINTMENT_AUTH_CODE_1;
        l_orig_appointment_auth_code2 := per_mt_int.ORIG_APPOINTMENT_AUTH_CODE_2;
        l_handicap_code               := per_mt_int.HANDICAP_CODE;
        l_agency_code_transfer_from   := per_mt_int.AGENCY_CODE_TRANSFER_FROM;

        l_citizenship                 := per_mt_int.CITIZENSHIP;
        l_veterans_preference         := per_mt_int.VETERANS_PREFERENCE;
        l_veterans_preference_for_RIF := per_mt_int.VETERANS_PREFERENCE_FOR_RIF;
        l_veterans_status             := per_mt_int.VETERANS_STATUS;

        l_work_schedule       := per_mt_int.work_schedule;

        l_creditable_military_service   := per_mt_int.creditable_military_service;
        l_academic_discipline           := per_mt_int.academic_discipline;
        l_education_level               := per_mt_int.educational_level;
        l_year_degree_attained          := per_mt_int.year_degree_attained;
        l_service_comp_date             := per_mt_int.service_comp_date;
	-- Changes 4093771
	l_to_basic_pay			:= per_mt_int.to_basic_salary_rate;
	l_to_adj_basic_pay		:= per_mt_int.to_adjusted_basic_pay;
	l_to_total_salary		:= per_mt_int.to_total_salary;
	-- End Changes 4093771
	--Begin Bug# 8724192
	l_orig_appt_auth_code_1_desc  := per_mt_int.orig_appt_auth_code_1_desc;
	l_orig_appt_auth_code_2_desc  := per_mt_int.orig_appt_auth_code_2_desc;
	l_assignment_nte_start_date   := fnd_date.date_to_canonical(per_mt_int.assignment_nte_start_date);
	l_assignment_nte	      := fnd_date.date_to_canonical(per_mt_int.assignment_nte);
	--End Bug# 8724192
        exit;
     end loop;

     hr_utility.set_location('After fetch from int' || l_proc, 65);
     hr_utility.set_location('Retirement plan     ' || l_retirement_plan, 65);
     hr_utility.set_location('Appointment Type    ' || l_appointment_type, 65);
     hr_utility.set_location('Position Id         ' || to_char(l_position_id) ,65);

     if nvl(l_mt_status,'U') = 'P' THEN

     if check_eligibility(l_person_id,p_effective_date) then
      ghr_pa_requests_pkg.get_SF52_to_data_elements
                         (p_position_id    => l_position_id
                         ,p_effective_date => p_effective_date
                         ,p_prd            => l_pay_rate_determinant
                         ,p_grade_id       => l_grade_id
                         ,p_job_id         => l_job_id
                         ,p_organization_id => l_organization_id
                         ,p_location_id     => l_location_id
                         ,p_pay_plan        => l_pay_plan
                         ,p_occ_code        => l_occ_code
                         ,p_grade_or_level  => l_grade_or_level
                         ,p_pay_basis       => l_pay_basis
                         ,p_position_org_line1 => l_org1
                         ,p_position_org_line2 => l_org2
                         ,p_position_org_line3 => l_org3
                         ,p_position_org_line4 => l_org4
                         ,p_position_org_line5 => l_org5
                         ,p_position_org_line6 => l_org6
                         ,p_duty_station_id    => l_duty_station_id);

     hr_utility.set_location('after sf52 to data grade ' || l_proc, 75);
     hr_utility.set_location('Grade ID       ' || l_grade_id, 75);
     hr_utility.set_location('Pay Plan       ' || l_pay_plan, 75);
     hr_utility.set_location('Occ            ' || l_occ_code, 85);
     hr_utility.set_location('Grade Or Level ' || l_grade_or_level, 85);
     hr_utility.set_location('Pay Basis      ' || l_pay_basis, 85);

        begin
           ghr_pa_requests_pkg.get_duty_station_details
                  (p_duty_station_id        => l_duty_station_id
                  ,p_effective_date        => p_effective_date
                  ,p_duty_station_code        => l_duty_station_code
                  ,p_duty_station_desc        => l_duty_station_desc);
        exception
             when others then
                 hr_utility.set_location('Err get duty station_det '||
                              ' Sql Err is '|| sqlerrm(sqlcode), 95);
		 -- Bug#3718167 Added full Name, SSN in l_mass_errbuf
                 l_mass_errbuf := 'Error in ghr_pa_req.get duty station_det for '||l_full_name||' SSN: '||l_national_identifier||
                              ' Sql Err is '|| sqlerrm(sqlcode);
                 raise mass_error;
        end;

     hr_utility.set_location('After duty stat    ' || l_proc, 115);
     hr_utility.set_location('Duty Station Code  ' || l_duty_station_code, 115);
     hr_utility.set_location('Duty Station Desc  ' || l_duty_station_desc, 115);

        begin
         ghr_history_fetch.fetch_positionei
                  (p_position_id           => l_position_id
                  ,p_information_type      => 'GHR_US_POS_GRP1'
                  ,p_date_effective        => p_effective_date
                  ,p_pos_ei_data           => l_pos_grp1_rec);
        exception
             when others then
                 hr_utility.set_location('Err fetch_posnei-POS_GRP1'||
                              ' Sql Err is '|| sqlerrm(sqlcode) , 125);
                 -- Bug#3718167 Added full Name, SSN in l_mass_errbuf
                 l_mass_errbuf := 'Error in fetch_positionei -POS_GRP1 for '||l_full_name||' SSN: '||l_national_identifier||
                              ' Sql Err is '|| sqlerrm(sqlcode);
                 raise mass_error;
        end;

--- those commented here will be fetched from interface table

         l_personnel_office_id := l_pos_grp1_rec.poei_information3;
         l_org_structure_id    := l_pos_grp1_rec.poei_information5;
    --     l_FLSA_category       := l_pos_grp1_rec.poei_information7;
    --     l_bargaining_unit_status := l_pos_grp1_rec.poei_information8;
    --     l_work_schedule       := l_pos_grp1_rec.poei_information10;
    --     l_functional_class     := l_pos_grp1_rec.poei_information11;
    --     l_supervisory_status   := l_pos_grp1_rec.poei_information16;

          hr_utility.set_location('After pos grp1  poi  ' || l_proc, 135);
          hr_utility.set_location('Personnel Office id  ' || l_personnel_office_id, 135);
          hr_utility.set_location('work sch             ' || l_work_schedule, 135);
          hr_utility.set_location('bargain              ' || l_bargaining_unit_status, 135);

         l_position_title := ghr_api.get_position_title_pos
	    (p_position_id            => l_position_id
	    ,p_business_group_id      => p_business_group_id ) ;

         l_position_number := ghr_api.get_position_desc_no_pos
	    (p_position_id         => l_position_id
	    ,p_business_group_id   => p_business_group_id);

         l_position_seq_no := ghr_api.get_position_sequence_no_pos
                               (p_position_id   => l_position_id,
                                p_business_group_id => p_business_group_id);


        begin
         ghr_history_fetch.fetch_peopleei
                  (p_person_id             => l_person_id
                  ,p_information_type      => 'GHR_US_PER_SCD_INFORMATON'
                  ,p_date_effective        => p_effective_date
                  ,p_per_ei_data           => l_per_ei2_data);
        exception
             when others then
                 hr_utility.set_location('Err fetch peopleei-SCDINFO'||
                              ' Sql Err is '|| sqlerrm(sqlcode) , 145);
                 -- Bug#3718167 Added full Name, SSN in l_mass_errbuf
                 l_mass_errbuf := 'Error in fetch peopleei - SCD INFO for '||l_full_name||' SSN: '||l_national_identifier||
                              ' Sql Err is '|| sqlerrm(sqlcode);
                 raise mass_error;
        end;

         l_serv_comp_date              := l_per_ei2_data.pei_INFORMATION3;

         hr_utility.set_location('Serv comp date   ' || l_proc, 155);
         hr_utility.set_location('Serv comp date   ' || l_serv_comp_date, 155);
         hr_utility.set_location('Pos Occ          ' || l_position_occupied, 155);
         hr_utility.set_location('appr 1           ' || l_appropriation_code1, 155);
         hr_utility.set_location('appr 2           ' || l_appropriation_code2, 155);

         hr_utility.set_location('us per separate retire ' || l_proc,175);
         hr_utility.set_location('prev ret cov     ' || l_previous_retirement_coverage, 175);
         hr_utility.set_location('Frozen Service   ' || l_frozen_service, 175);
         hr_utility.set_location('FERS Coverage   ' || l_fers_coverage, 175);

        FOR c_asg_by_per_id_not_prim_rec in c_asg_by_per_id_not_prim
                                            (l_person_id,p_effective_date)
        LOOP

            l_employee_assignment_id := c_asg_by_per_id_not_prim_rec.assignment_id;

        END LOOP;

         begin
            assign_to_sf52_rec(
                       l_person_id,
                       l_position_id,
                       l_job_id,
                       l_employee_assignment_id,
                       l_last_name,
                       l_first_name,
                       l_middle_names,
                       l_national_identifier,
                       l_date_of_birth,
                       p_effective_date,
                       l_position_title,
                       l_position_number,
 		       l_position_seq_no,
                       l_pay_plan,
                       l_occ_code,
                       l_organization_id,
                       l_grade_id,
                       l_grade_or_level,
                       l_pay_basis,
                       l_step_or_rate,
                       l_veterans_preference,
                       l_veterans_preference_for_RIF,
                       l_FEGLI,
                       l_tenure,
                       l_annuitant_indicator,
                       l_pay_rate_determinant,
                       l_retirement_plan,
                       l_serv_comp_date,
                       l_work_schedule,
                       l_position_occupied,
                       l_flsa_category,
                       l_appropriation_code1,
                       l_appropriation_code2,
                       l_bargaining_unit_status,
                       l_location_id,
                       l_duty_station_id,
                       l_duty_station_code,
                       l_duty_station_desc,
                       l_functional_class,
                       l_citizenship,
                       l_veterans_status,
                       l_supervisory_status,
                       l_type_of_employment,
                       l_race_or_national_origin,
                       l_orig_appointment_auth_code1,
                       l_handicap_code,
                       l_creditable_military_service,
                       l_previous_retirement_coverage,
                       l_frozen_service,
                       l_agency_code_transfer_from,
                       l_org1,
                       l_org2,
                       l_org3,
                       l_org4,
	               l_org5,
                       l_org6,
		       l_to_basic_pay,
		       l_to_adj_basic_pay,
		       l_to_total_salary,
                       l_lac_sf52_rec,
                       l_sf52_rec);

          -- Bug # 711533 [Following values were not being populated from Mass Transfer in Form
          l_sf52_rec.academic_discipline := l_academic_discipline;
          l_sf52_rec.year_degree_attained := l_year_degree_attained;
          l_sf52_rec.education_level := l_education_level;
          l_sf52_rec.service_comp_date  := l_service_comp_date;
          -- Bug # 712305
          l_sf52_rec.part_time_hours := l_part_time_hours;

          exception
             when others then
                 hr_utility.set_location('Others err in assign_sf52'||
                              ' Sql Err is '|| sqlerrm(sqlcode) , 185);
                 -- Bug#3718167 Added full Name, SSN in l_mass_errbuf
                 l_mass_errbuf := 'Others error in assign_sf52 for '||l_full_name||' SSN: '||l_national_identifier||
                              ' Sql Err is '|| sqlerrm(sqlcode);
                 raise mass_error;
          end;

         hr_utility.set_location('After assign to sf52 rec' || l_proc, 195);

          begin
             hr_utility.set_location('Calling Redo Pay Calc ' || l_proc, 196);
             ghr_process_Sf52.redo_pay_calc(l_sf52_rec,l_capped_other_pay);
             hr_utility.set_location('Calling create_sf52 ' || l_proc, 197);

             -- Adding the following code to keep track of the RPA type and Mass action id
 	     --
 	     l_sf52_rec.rpa_type            := 'MTI';
 	     l_sf52_rec.mass_action_id      := p_mtin_id;
 	     --
             ghr_mass_changes.create_sf52_for_mass_changes
                  (p_mass_action_type => 'MASS_TRANSFER_IN',
                   p_pa_request_rec  => l_sf52_rec,
                   p_errbuf           => l_errbuf,
                   p_retcode          => l_retcode);
          exception
             when others then
                 hr_utility.set_location('Others error in ghr_mass_changes.create_sf52' ||
                              ' Sql Err is '|| sqlerrm(sqlcode) , 205);
	         -- Bug#3718167 Added full Name, SSN in l_mass_errbuf
                 l_mass_errbuf := 'Error in ghr_mass_changes.create_sf52 for '||l_full_name||' SSN: '||l_national_identifier||
                              ' PA Request ID ' || to_char(l_sf52_rec.pa_request_id) ||
                              ' Sql Err is '|| sqlerrm(sqlcode);
                 raise mass_error;
          end;

          if l_errbuf is not null then
                 hr_utility.set_location('Error in ghr_mass_changes.create_sf52 ' ||
                              l_errbuf , 215);
		 -- Bug#3718167 Added full Name, SSN in l_mass_errbuf
                 l_mass_errbuf := 'Error in ghr_mass_changes.create_sf52 for '||l_full_name||' SSN: '||l_national_identifier||
                              ' PA Request ID ' || to_char(l_sf52_rec.pa_request_id) ||
                              l_errbuf;

                 raise mass_error;
          else

-- We do not Update the flag to NULL like in other Mass Actions
-- because we cannot create multiple previews for Mass transfer IN
-- as it is dependent on the interface dump.

                   ghr_mto_int.log_message(
                       p_procedure => 'Successful Completion',
                       p_message   => 'Name: '||l_full_name ||
                       ' SSN: '|| l_national_identifier ||
                       ' Mass Transfer IN : '||
                      p_mtin_name ||' SF52 Successfully completed');

                   ghr_msl_pkg.create_lac_remarks(l_pa_request_id,
                                              l_sf52_rec.pa_request_id);

                   commit;
          end if;

          declare
              l_PA_REQUEST_EXTRA_INFO_ID number;
              l_pa_OBJECT_VERSION_NUMBER number;
	      --Bug# 8724192
	      l_APP_AUTH_PA_REQUEST_EI_ID number;
              l_APP_AUTH_PA_OBJECT_VER_NUM number;
	      l_NTE_PA_REQUEST_EI_ID number;
              l_NTE_PA_OBJECT_VER_NUM number;
	      --Bug# 8724192
          begin
            for pa_rec in PA_REQ_EXT_INFO_CUR (l_sf52_rec.pa_request_id)
            loop
                l_PA_REQUEST_EXTRA_INFO_ID := pa_rec.PA_REQUEST_EXTRA_INFO_ID;
                l_pa_OBJECT_VERSION_NUMBER := pa_rec.OBJECT_VERSION_NUMBER;
                exit;
            end loop;
            if l_pa_request_extra_info_id is null then
		  ghr_par_extra_info_api.create_pa_request_extra_info
		       (p_validate                    => false,
			p_pa_request_id               => l_sf52_rec.pa_request_id,
			p_information_type            => 'GHR_US_PAR_APPT_TRANSFER',
			p_rei_information_category    => 'GHR_US_PAR_APPT_TRANSFER',
			p_rei_information3           => l_agency_code_transfer_from,
			p_rei_information4           => l_appointment_type,
			p_rei_information6           => l_creditable_military_service,
			p_rei_information7           => l_date_arr_pers_office,
			p_rei_information8           => l_date_wgi_due,
			p_rei_information9           => l_frozen_service,
			p_rei_information10           => l_handicap_code,
			p_rei_information11          => l_non_disc_agmt_status,
			------ p_rei_information12          => l_orig_appointment_auth_code1,
			------ p_rei_information13          => l_orig_appointment_auth_code2,
			p_rei_information14          => l_part_time_indicator,
			p_rei_information15          => l_position_working_title,
			p_rei_information16          => l_previous_retirement_coverage,
			p_rei_information18          => l_race_or_national_origin,
			p_rei_information19          => l_type_of_employment,
			-- Bug#2412656 Added fers_coverage
			p_rei_information21          => l_fers_coverage,
			p_pa_request_extra_info_id    => l_dummy,
			p_object_version_number       => l_dummy);

            else
		  ghr_par_extra_info_api.update_pa_request_extra_info
		       (p_validate                   => false,
			p_rei_information3           => l_agency_code_transfer_from,
			p_rei_information4           => l_appointment_type,
			p_rei_information6           => l_creditable_military_service,
			p_rei_information7           => l_date_arr_pers_office,
			p_rei_information8           => l_date_wgi_due,
			p_rei_information9           => l_frozen_service,
			p_rei_information10           => l_handicap_code,
			p_rei_information11          => l_non_disc_agmt_status,
			------	p_rei_information12          => l_orig_appointment_auth_code1,
			------	p_rei_information13          => l_orig_appointment_auth_code2,
			p_rei_information14          => l_part_time_indicator,
			p_rei_information15          => l_position_working_title,
			p_rei_information16          => l_previous_retirement_coverage,
			p_rei_information18          => l_race_or_national_origin,
			p_rei_information19          => l_type_of_employment,
			-- Bug#2412656 Added fers_coverage
			p_rei_information21          => l_fers_coverage,
			p_pa_request_extra_info_id   => l_PA_REQUEST_EXTRA_INFO_ID,
			p_object_version_number      => l_pa_OBJECT_VERSION_NUMBER);
            end if;

	    --Begin Bug# 8724192
		for pa_rec_auth in PA_REQ_APP_AUTH_EI_CUR (l_sf52_rec.pa_request_id)
		loop
			l_APP_AUTH_PA_REQUEST_EI_ID := pa_rec_auth.PA_REQUEST_EXTRA_INFO_ID;
			l_APP_AUTH_PA_OBJECT_VER_NUM := pa_rec_auth.OBJECT_VERSION_NUMBER;
		exit;
		end loop;

		if l_APP_AUTH_PA_REQUEST_EI_ID is null then
			ghr_par_extra_info_api.create_pa_request_extra_info
				(p_validate                    => false,
				p_pa_request_id               => l_sf52_rec.pa_request_id,
				p_information_type            => 'GHR_US_TRANS_CURN_APP_AUTH',
				p_rei_information_category    => 'GHR_US_TRANS_CURN_APP_AUTH',
				p_rei_information1           => l_orig_appointment_auth_code1,
				p_rei_information2           => l_orig_appt_auth_code_1_desc,
				p_rei_information3           => l_orig_appointment_auth_code2,
				p_rei_information4           => l_orig_appt_auth_code_2_desc,
				p_pa_request_extra_info_id    => l_dummy,
				p_object_version_number       => l_dummy);

		else
			ghr_par_extra_info_api.update_pa_request_extra_info
			       (p_validate                   => false,
				p_rei_information1           => l_orig_appointment_auth_code1,
				p_rei_information2           => l_orig_appt_auth_code_1_desc,
				p_rei_information3           => l_orig_appointment_auth_code2,
				p_rei_information4           => l_orig_appt_auth_code_2_desc,
				p_pa_request_extra_info_id   => l_APP_AUTH_PA_REQUEST_EI_ID,
				p_object_version_number      => l_APP_AUTH_PA_OBJECT_VER_NUM);

		End if;

		for pa_rec_nte in PA_REQ_NTE_EI_CUR (l_sf52_rec.pa_request_id)
		loop
			l_NTE_PA_REQUEST_EI_ID := pa_rec_nte.PA_REQUEST_EXTRA_INFO_ID;
			l_NTE_PA_OBJECT_VER_NUM := pa_rec_nte.OBJECT_VERSION_NUMBER;
		exit;
		end loop;

		if l_NTE_PA_REQUEST_EI_ID is null then
			ghr_par_extra_info_api.create_pa_request_extra_info
			       (p_validate                    => false,
				p_pa_request_id               => l_sf52_rec.pa_request_id,
				p_information_type            => 'GHR_US_MASS_TRNSFR_NTE_DATES',
				p_rei_information_category    => 'GHR_US_MASS_TRNSFR_NTE_DATES',
				p_rei_information10           => l_assignment_nte_start_date,
				p_rei_information11           => l_assignment_nte,
				p_pa_request_extra_info_id    => l_dummy,
				p_object_version_number       => l_dummy);

		else
			ghr_par_extra_info_api.update_pa_request_extra_info
			       (p_validate                   => false,
				p_rei_information10           => l_assignment_nte_start_date,
				p_rei_information11           => l_assignment_nte,
				p_pa_request_extra_info_id   => l_NTE_PA_REQUEST_EI_ID,
				p_object_version_number      => l_NTE_PA_OBJECT_VER_NUM);
		end if;
		--end Bug# 8724192
        exception
             when others then
                 hr_utility.set_location('Error in ghr_par_extra info.create pa req'||
                              ' Sql Err is '|| sqlerrm(sqlcode) , 225);
		 -- Bug#3718167 Added full Name, SSN in l_mass_errbuf
                 l_mass_errbuf := 'Error in ghr_par_extra info.create pa req for '||l_full_name||' SSN: '||l_national_identifier||
                              ' Sql Err is '|| sqlerrm(sqlcode);
                 raise mass_error;
        end;
            hr_utility.set_location('After create pa_req_extra_info' || l_proc, 235);
   else


-- We do not Update the flag to NULL like in other Mass Actions
-- because we cannot create multiple previews for Mass transfer IN
-- as it is dependent on the interface dump.

        commit;
   end if; ---- for check_eligibility...
  else

    l_mt_status_err_cnt := l_mt_status_err_cnt + 1;
  end if; ---- for mt_status != 'P'

  EXCEPTION
    when mass_error then
       hr_utility.set_location('Mass error raised ' || l_mass_errbuf , 245);
       begin
         ROLLBACK TO EXECUTE_MRE_IN_SP;
       exception
         when others then null;
       end;

        update ghr_mass_transfers
           set status = 'E'
         where mass_transfer_id = p_mtin_id;
         commit;
         l_recs_failed := l_recs_failed + 1;
        p_errbuf   := 'Error in '||l_proc || 'Details in GHR_PROCESS_LOG';
        p_retcode  := 1;
       begin

          ghr_mto_int.log_message(p_procedure => 'GHMTIAPP',
                                  p_message   => l_mass_errbuf);
          commit;
       exception
           when others then
               hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
               hr_utility.raise_error;
       end;

    WHEN OTHERS THEN
       hr_utility.set_location('Err (Oth) Sql error '||sqlerrm(sqlcode),30);
       l_mass_errbuf := 'Error in '||l_proc|| ' Sql Err is '||sqlerrm(sqlcode);
       begin
         ROLLBACK TO EXECUTE_MRE_IN_SP;
       exception
         when others then null;
       end;

        update ghr_mass_transfers
           set status = 'E'
         where mass_transfer_id = p_mtin_id;
         commit;

       l_recs_failed := l_recs_failed + 1;
        p_errbuf   := 'Error in '||l_proc || 'Details in GHR_PROCESS_LOG';
        p_retcode  := 1;
       begin
          ghr_mto_int.log_message(p_procedure => 'GHMTIAPP',
                                  p_message   => l_mass_errbuf);
          commit;
       exception
           when others then
               hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
               hr_utility.raise_error;
       end;
    END;
  END LOOP;

  for mt_int_rec in ghr_mt_int_count(p_mtin_name)
  loop
     l_mt_status_err_cnt := mt_int_rec.count;
     exit;
  end loop;

  if (l_recs_failed = 0) then
     begin
        update ghr_mass_transfers
           set status = decode(l_mt_status_err_cnt,0,'P','E')
         where mass_transfer_id = p_mtin_id;
        commit;
     EXCEPTION
       when others then
          hr_utility.set_location('Err in Update mass_transfers Sql err '||sqlerrm(sqlcode),30);
          hr_utility.set_message(8301, 'GHR_38476_UPD_GHR_MSL_FAILURE');
          hr_utility.raise_error;
     END;
  else
        update ghr_mass_transfers
           set status = 'E'
         where mass_transfer_id = p_mtin_id;
         commit;

        p_errbuf   := 'Error in '||l_proc || 'Details in GHR_PROCESS_LOG';
        p_retcode  := 1;
  end if;

EXCEPTION
  when mass_error then
     hr_utility.set_location('Mass error raised' || l_mass_errbuf , 245);
     ROLLBACK TO EXECUTE_MRE_IN_SP;

      update ghr_mass_transfers
         set status = 'E'
       where mass_transfer_id = p_mtin_id;
       commit;
       l_recs_failed := l_recs_failed + 1;
      p_errbuf   := 'Error in '||l_proc || 'Details in GHR_PROCESS_LOG';
      p_retcode  := 1;
     begin
        ghr_mto_int.log_message(p_procedure => 'GHMTIAPP',
                                p_message   => l_mass_errbuf);
        commit;
     exception
         when others then
             hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
             hr_utility.raise_error;
     end;
  WHEN OTHERS THEN
     hr_utility.set_location('Err (Others) occurred in Sql error '|| sqlerrm(sqlcode),30);
     hr_utility.set_location('Error others '||' Err is '||sqlerrm(sqlcode),20);
     l_mass_errbuf := 'Error in '||l_proc||
                     ' Sql Err is '||sqlerrm(sqlcode);
     begin
       ROLLBACK TO EXECUTE_MRE_IN_SP;
     exception
       when others then null;
     end;

      update ghr_mass_transfers
         set status = 'E'
       where mass_transfer_id = p_mtin_id;
       commit;

     l_recs_failed := l_recs_failed + 1;
     p_errbuf   := 'Error in '||l_proc || 'Details in GHR_PROCESS_LOG';
     p_retcode  := 1;
     BEGIN
        ghr_mto_int.log_message(p_procedure => 'GHMTIAPP',
                                p_message   => l_mass_errbuf);
        COMMIT;
     EXCEPTION
         WHEN OTHERS THEN
	      p_errbuf          := NULL;
              p_retcode         := NULL;
             hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
             hr_utility.raise_error;
     END;
END populate_and_create_52;

--
--
--

function check_eligibility(p_person_id in number,
                           p_effective_date in date) return boolean is

l_proc            varchar2(72) :=  g_package || '.check_eligibility';
begin
    if GHR_MRE_PKG.person_in_pa_req_1noa
          (p_person_id      => p_person_id,
           p_effective_date => p_effective_date,
           p_first_noa_code => '132'
           ) then
       return false;
    end if;
/********************
    if GHR_MRE_PKG.person_in_pa_req_2noa
          (p_person_id      => p_person_id,
           p_effective_date => p_effective_date,
           p_second_noa_code => '132'
           ) then
       return false;
    end if;
****************/

    return true;
end;

procedure assign_to_sf52_rec(
    p_person_id                      in number
   ,p_position_id                    in number
   ,p_job_id                         in number
   ,p_employee_assignment_id         in number
   ,p_last_name                      in varchar2
   ,p_first_name                     in varchar2
   ,p_middle_names                   in varchar2
   ,p_national_identifier            in varchar2
   ,p_date_of_birth                  in varchar2
   ,p_effective_date                 in varchar2
   ,p_position_title                 in varchar2
   ,p_position_number                in varchar2
   ,p_position_seq_no                in number
   ,p_pay_plan                       in varchar2
   ,p_occ_code                       in varchar2
   ,p_organization_id                in number
   ,p_grade_id                       in number
   ,p_grade_or_level                 in varchar2
   ,p_pay_basis                      in varchar2
   ,p_step_or_rate                   in varchar2
   ,p_veterans_preference            in varchar2
   ,p_vet_preference_for_RIF         in varchar2
   ,p_FEGLI                          in varchar2
   ,p_tenure                         in varchar2
   ,p_annuitant_indicator            in varchar2
   ,p_pay_rate_determinant           in varchar2
   ,p_retirement_plan                in varchar2
   ,p_service_comp_date              in varchar2
   ,p_work_schedule                  in varchar2
   ,p_position_occupied              in varchar2
   ,p_flsa_category                  in varchar2
   ,p_appropriation_code1            in varchar2
   ,p_appropriation_code2            in varchar2
   ,p_bargaining_unit_status         in varchar2
   ,p_duty_station_location_id       in number
   ,p_duty_station_id                in number
   ,p_duty_station_code              in varchar2
   ,p_duty_station_desc              in varchar2
   ,p_functional_class               in varchar2
   ,p_citizenship                    in varchar2
   ,p_veterans_status                in varchar2
   ,p_supervisory_status             in varchar2
   ,p_type_of_employment             in varchar2
   ,p_race_or_national_origin        in varchar2
   ,p_orig_appointment_auth_code1    in varchar2
   ,p_handicap_code                  in varchar2
   ,p_creditable_military_service    in varchar2
   ,p_previous_retirement_coverage   in varchar2
   ,p_frozen_service                 in varchar2
   ,p_agency_code_transfer_from      in varchar2
   ,p_to_position_org_line1          IN  varchar2
   ,p_to_position_org_line2          IN  varchar2
   ,p_to_position_org_line3          IN  varchar2
   ,p_to_position_org_line4          IN  varchar2
   ,p_to_position_org_line5          IN  varchar2
   ,p_to_position_org_line6          IN  varchar2
   -- Changes 4093771
   , p_to_basic_pay		     IN number
   , p_to_adj_basic_pay              IN number
   , p_to_total_salary               IN number
   -- End Changes 4093771
   ,p_lac_sf52_rec                   in  ghr_pa_requests%rowtype
   ,p_sf52_rec                   out   nocopy  ghr_pa_requests%rowtype)
IS

l_proc                      varchar2(72)
          :=  g_package || '.assign_to_sf52_rec';
begin

    hr_utility.set_location('Entering    ' || l_proc,5);

    p_sf52_rec.pa_request_id                    := null;
    p_sf52_rec.pa_notification_id               := null;
    p_sf52_rec.noa_family_code                  := 'APP';
    p_sf52_rec.routing_group_id                 := null;
    p_sf52_rec.academic_discipline              := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.additional_info_person_id        := null;
    p_sf52_rec.additional_info_tel_number       := null;
    p_sf52_rec.agency_code                      := null;
    p_sf52_rec.altered_pa_request_id            := null;
    p_sf52_rec.annuitant_indicator              := p_annuitant_indicator;
    p_sf52_rec.annuitant_indicator_desc         := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.appropriation_code1              := p_appropriation_code1;
    p_sf52_rec.appropriation_code2              := p_appropriation_code2;
    p_sf52_rec.approval_date                    := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.approving_official_full_name     := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.approving_official_work_title    := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.authorized_by_person_id          := null;
    p_sf52_rec.authorized_by_title              := null;
    p_sf52_rec.award_amount                     := null;
    p_sf52_rec.award_uom                        := null;
    p_sf52_rec.bargaining_unit_status           := p_bargaining_unit_status;
    p_sf52_rec.citizenship                      := p_citizenship;
    p_sf52_rec.concurrence_date                 := null;
    p_sf52_rec.custom_pay_calc_flag             := null;
    p_sf52_rec.duty_station_code                := p_duty_station_code;
    p_sf52_rec.duty_station_desc                := p_duty_station_desc;
    p_sf52_rec.duty_station_id                  := p_duty_station_id;
    p_sf52_rec.duty_station_location_id         := p_duty_station_location_id;
    p_sf52_rec.education_level                  := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.effective_date                   := p_effective_date;
    p_sf52_rec.employee_assignment_id           := p_employee_assignment_id;
 ---p_sf52_rec.employee_date_of_birth           := to_date(p_date_of_birth, 'DD-MON-YYYY');
    p_sf52_rec.employee_date_of_birth           := fnd_date.canonical_to_date(p_date_of_birth);
    p_sf52_rec.employee_dept_or_agency          := null;
    p_sf52_rec.employee_first_name              := p_first_name;
    p_sf52_rec.employee_last_name               := p_last_name;
    p_sf52_rec.employee_middle_names            := p_middle_names;
    p_sf52_rec.employee_national_identifier     := p_national_identifier;
    p_sf52_rec.fegli                            := p_fegli;
    p_sf52_rec.fegli_desc                       := null;
    p_sf52_rec.first_action_la_code1            := p_lac_sf52_rec.first_action_la_code1;
    p_sf52_rec.first_action_la_code2            := p_lac_sf52_rec.first_action_la_code2;
    p_sf52_rec.first_action_la_desc1            := p_lac_sf52_rec.first_action_la_desc1;
    p_sf52_rec.first_action_la_desc2            := p_lac_sf52_rec.first_action_la_desc2;
    p_sf52_rec.first_noa_cancel_or_correct      := null;
    p_sf52_rec.first_noa_code                   := '132';
    p_sf52_rec.first_noa_desc                   := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.first_noa_id                     := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.first_noa_pa_request_id          := null;
    p_sf52_rec.flsa_category                    := p_flsa_category;
    p_sf52_rec.forwarding_address_line1         := null;
    p_sf52_rec.forwarding_address_line2         := null;
    p_sf52_rec.forwarding_address_line3         := null;
    p_sf52_rec.forwarding_country               := null;
    p_sf52_rec.forwarding_country_short_name    := null;
    p_sf52_rec.forwarding_postal_code           := null;
    p_sf52_rec.forwarding_region_2              := null;
    p_sf52_rec.forwarding_town_or_city          := null;
    p_sf52_rec.from_adj_basic_pay               := null;
    p_sf52_rec.from_agency_code                 := null;
    p_sf52_rec.from_agency_desc                 := null;
    p_sf52_rec.from_basic_pay                   := null;
    p_sf52_rec.from_grade_or_level              := null;
    p_sf52_rec.from_locality_adj                := null;
    p_sf52_rec.from_occ_code                    := null;
    p_sf52_rec.from_office_symbol               := null;
    p_sf52_rec.from_other_pay_amount            := null;
    p_sf52_rec.from_pay_basis                   := null;
    p_sf52_rec.from_pay_plan                    := null;
    p_sf52_rec.from_position_id                 := null;
    p_sf52_rec.from_position_org_line1          := p_agency_code_transfer_from;  --AVR
    p_sf52_rec.from_position_org_line2          := null;
    p_sf52_rec.from_position_org_line3          := null;
    p_sf52_rec.from_position_org_line4          := null;
    p_sf52_rec.from_position_org_line5          := null;
    p_sf52_rec.from_position_org_line6          := null;
    p_sf52_rec.from_position_number             := null;
    p_sf52_rec.from_position_seq_no             := null;
    p_sf52_rec.from_position_title              := null;
    p_sf52_rec.from_step_or_rate                := null;
    p_sf52_rec.from_total_salary                := null;
    p_sf52_rec.functional_class                 := p_functional_class;
    p_sf52_rec.no_of_notification_printed       := null;
    p_sf52_rec.notepad                          := null;
    p_sf52_rec.notification_printed_by          := null;
    p_sf52_rec.part_time_hours                  := null;
    p_sf52_rec.pay_rate_determinant             := p_pay_rate_determinant;
    p_sf52_rec.personnel_office_id              := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.person_id                        := p_person_id;
    p_sf52_rec.position_occupied                := p_position_occupied;
    p_sf52_rec.proposed_effective_asap_flag     := null;
    p_sf52_rec.proposed_effective_date          := null;
    p_sf52_rec.requested_by_person_id           := null;
    p_sf52_rec.requested_by_title               := null;
    p_sf52_rec.requested_date                   := null;
    p_sf52_rec.requesting_office_remarks_desc   := null;
    p_sf52_rec.requesting_office_remarks_flag   := null;
    p_sf52_rec.request_number                   := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.resign_and_retire_reason_desc    := null;
    p_sf52_rec.retirement_plan                  := p_retirement_plan;
    p_sf52_rec.retirement_plan_desc             := null;
    p_sf52_rec.second_action_la_code1           := null;
    p_sf52_rec.second_action_la_code2           := null;
    p_sf52_rec.second_action_la_desc1           := null;
    p_sf52_rec.second_action_la_desc2           := null;
    p_sf52_rec.second_noa_cancel_or_correct     := null;
    p_sf52_rec.second_noa_code                  := null;
    p_sf52_rec.second_noa_desc                  := null;
    p_sf52_rec.second_noa_id                    := null;
    p_sf52_rec.second_noa_pa_request_id         := null;
    p_sf52_rec.service_comp_date                := p_service_comp_date;
    p_sf52_rec.sf50_approval_date               := null;
    p_sf52_rec.sf50_approving_ofcl_full_name    := null;
    p_sf52_rec.sf50_approving_ofcl_work_title   := null;
    p_sf52_rec.status                           := null;
    p_sf52_rec.supervisory_status               := p_supervisory_status;
    p_sf52_rec.tenure                           := p_tenure;
    p_sf52_rec.to_adj_basic_pay                 := null;
    p_sf52_rec.to_ap_premium_pay_indicator      := null;
    p_sf52_rec.to_auo_premium_pay_indicator     := null;
    p_sf52_rec.to_au_overtime                   := null;
    p_sf52_rec.to_availability_pay              := null;
    p_sf52_rec.to_basic_pay                     := null;
    p_sf52_rec.to_grade_id                      := p_grade_id;
    p_sf52_rec.to_grade_or_level                := p_grade_or_level;
    p_sf52_rec.to_job_id                        := p_job_id;
    p_sf52_rec.to_locality_adj                  := null;
    p_sf52_rec.to_occ_code                      := p_occ_code;
    p_sf52_rec.to_office_symbol                 := null;
    p_sf52_rec.to_organization_id               := p_organization_id;
    p_sf52_rec.to_other_pay_amount              := null;
    p_sf52_rec.to_pay_basis                     := p_pay_basis;
    p_sf52_rec.to_pay_plan                      := p_pay_plan;
    p_sf52_rec.to_position_id                   := p_position_id;
    p_sf52_rec.to_position_org_line1            := p_to_position_org_line1;
    p_sf52_rec.to_position_org_line2            := p_to_position_org_line2;
    p_sf52_rec.to_position_org_line3            := p_to_position_org_line3;
    p_sf52_rec.to_position_org_line4            := p_to_position_org_line4;
    p_sf52_rec.to_position_org_line5            := p_to_position_org_line5;
    p_sf52_rec.to_position_org_line6            := p_to_position_org_line6;
    p_sf52_rec.to_position_number               := p_position_number;
    p_sf52_rec.to_position_seq_no               := p_position_seq_no;
    p_sf52_rec.to_position_title                := p_position_title;
    p_sf52_rec.to_retention_allowance           := null;
    p_sf52_rec.to_staffing_differential         := null;
    p_sf52_rec.to_step_or_rate                  := p_step_or_rate;
    p_sf52_rec.to_supervisory_differential      := null;
    p_sf52_rec.to_total_salary                  := null;
    p_sf52_rec.veterans_preference              := p_veterans_preference;    -- Re-populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES?
    p_sf52_rec.veterans_pref_for_rif            := p_vet_preference_for_rif; -- Re-populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES?
    p_sf52_rec.veterans_status                  := p_veterans_status;        -- Re-populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES?
    p_sf52_rec.work_schedule                    := p_work_schedule;
    p_sf52_rec.work_schedule_desc               := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.year_degree_attained             := null; -- Populated in GHR_MASS_CHANGES.CREATE_SF52_FOR_MASS_CHANGES
    p_sf52_rec.first_noa_information1           := null;
    p_sf52_rec.first_noa_information2           := null;
    p_sf52_rec.first_noa_information3           := null;
    p_sf52_rec.first_noa_information4           := null;
    p_sf52_rec.first_noa_information5           := null;
    p_sf52_rec.second_lac1_information1         := p_lac_sf52_rec.second_lac1_information1;
    p_sf52_rec.second_lac1_information2         := p_lac_sf52_rec.second_lac1_information2;
    p_sf52_rec.second_lac1_information3         := p_lac_sf52_rec.second_lac1_information3;
    p_sf52_rec.second_lac1_information4         := p_lac_sf52_rec.second_lac1_information4;
    p_sf52_rec.second_lac1_information5         := p_lac_sf52_rec.second_lac1_information5;
    p_sf52_rec.second_lac2_information1         := null;
    p_sf52_rec.second_lac2_information2         := null;
    p_sf52_rec.second_lac2_information3         := null;
    p_sf52_rec.second_lac2_information4         := null;
    p_sf52_rec.second_lac2_information5         := null;
    p_sf52_rec.second_noa_information1          := null;
    p_sf52_rec.second_noa_information2          := null;
    p_sf52_rec.second_noa_information3          := null;
    p_sf52_rec.second_noa_information4          := null;
    p_sf52_rec.second_noa_information5          := null;
    p_sf52_rec.first_lac1_information1          := p_lac_sf52_rec.first_lac1_information1;
    p_sf52_rec.first_lac1_information2          := p_lac_sf52_rec.first_lac1_information2;
    p_sf52_rec.first_lac1_information3          := p_lac_sf52_rec.first_lac1_information3;
    p_sf52_rec.first_lac1_information4          := p_lac_sf52_rec.first_lac1_information4;
    p_sf52_rec.first_lac1_information5          := p_lac_sf52_rec.first_lac1_information5;
    p_sf52_rec.first_lac2_information1          := null;
    p_sf52_rec.first_lac2_information2          := null;
    p_sf52_rec.first_lac2_information3          := null;
    p_sf52_rec.first_lac2_information4          := null;
    p_sf52_rec.first_lac2_information5          := null;
    p_sf52_rec.attribute_category               := null;
    p_sf52_rec.attribute1                       := null;
    p_sf52_rec.attribute2                       := null;
    p_sf52_rec.attribute3                       := null;
    p_sf52_rec.attribute4                       := null;
    p_sf52_rec.attribute5                       := null;
    p_sf52_rec.attribute6                       := null;
    p_sf52_rec.attribute7                       := null;
    p_sf52_rec.attribute8                       := null;
    p_sf52_rec.attribute9                       := null;
    p_sf52_rec.attribute10                      := null;
    p_sf52_rec.attribute11                      := null;
    p_sf52_rec.attribute12                      := null;
    p_sf52_rec.attribute13                      := null;
    p_sf52_rec.attribute14                      := null;
    p_sf52_rec.attribute15                      := null;
    p_sf52_rec.attribute16                      := null;
    p_sf52_rec.attribute17                      := null;
    p_sf52_rec.attribute18                      := null;
    p_sf52_rec.attribute19                      := null;
    p_sf52_rec.attribute20                      := null;
    p_sf52_rec.created_by                       := null;
    p_sf52_rec.creation_date                    := null;
    p_sf52_rec.last_updated_by                  := null;
    p_sf52_rec.last_update_date                 := null;
    p_sf52_rec.last_update_login                := null;
    p_sf52_rec.object_version_number            := null;

    -- Changes 4093771
    IF ghr_pay_calc.get_open_pay_range(p_position_id=>p_position_id,
					   p_person_id=>p_person_id,
					   p_prd=>p_pay_rate_determinant,
					   p_pa_request_id => NULL,
					   p_effective_date => NVL(p_effective_date,sysdate)) = TRUE THEN
	    p_sf52_rec.to_basic_pay        := p_to_basic_pay;
	    p_sf52_rec.to_adj_basic_pay    := p_to_adj_basic_pay;
	    p_sf52_rec.to_total_salary     := p_to_total_salary;
    END IF;
    -- End Changes 4093771

    hr_utility.set_location('Exiting    ' || l_proc,10);

EXCEPTION
  WHEN others THEN
     -- Reset IN OUT parameters and set OUT parameters

     p_sf52_rec          := NULL;

   hr_utility.set_location('Leaving  ' || l_proc,60);
   RAISE;

end assign_to_sf52_rec;

--
--
--

procedure pr (msg varchar2,par1 in varchar2 default null,
            par2 in varchar2 default null) is
begin
  null;
  ---DBMS_OUTPUT.PUT_LINE(msg||'-'||par1||' -'||par2||'-');
end;

END GHR_MTI_APP;

/
