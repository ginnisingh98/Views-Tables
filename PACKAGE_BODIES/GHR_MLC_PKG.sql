--------------------------------------------------------
--  DDL for Package Body GHR_MLC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MLC_PKG" AS
/* $Header: ghmlcexe.pkb 120.10.12000000.3 2007/02/24 10:58:24 asubrahm noship $ */

g_no number := 0;
g_package  varchar2(32) := 'GHR_MLC_PKG';
g_proc     varchar2(72) := null;
g_effective_date  date;

l_log_text varchar2(2000) := null;
l_mlcerrbuf   varchar2(2000) := null;

procedure execute_mlc (p_errbuf out nocopy varchar2,
                       p_retcode out nocopy number,
                       p_mass_salary_id in number,
                       p_action in varchar2) is

p_mass_salary varchar2(32);
l_p_locality_area_code     ghr_mass_salaries.locality_pay_area_code%type;

--
-- Main Cursor which fetches from per_assignments_f and per_people_f
--
-- Bug 4377361 included EMP_APL for person type condition

cursor cur_people (effective_date date, p_org_id number) is
select ppf.person_id    PERSON_ID,
       ppf.first_name   FIRST_NAME,
       ppf.last_name    LAST_NAME,
       ppf.middle_names MIDDLE_NAMES,
       ppf.full_name    FULL_NAME,
       ppf.date_of_birth DATE_OF_BIRTH,
       ppf.national_identifier NATIONAL_IDENTIFIER,
       paf.position_id  POSITION_ID,
       paf.assignment_id ASSIGNMENT_ID,
       paf.grade_id     GRADE_ID,
       paf.job_id       JOB_ID,
       paf.location_id  LOCATION_ID,
       paf.organization_id ORGANIZATION_ID,
       paf.business_group_id BUSINESS_GROUP_ID
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt,
       per_assignment_status_types pas_t,
       hr_location_extra_info hlei,
       ghr_duty_stations_f    gdsf,
       ghr_locality_pay_areas_f glpa
 where ppf.person_id    = paf.person_id
   and paf.primary_flag = 'Y'
   and paf.assignment_type <> 'B'
   and paf.assignment_status_type_id = pas_t.assignment_status_type_id
   and upper(pas_t.user_status) not in (
         'TERMINATE ASSIGNMENT', 'ACTIVE APPLICATION', 'OFFER', 'ACCEPTED',
         'TERMINATE APPLICATION',   'END', 'TERMINATE APPOINTMENT', 'SEPARATED')
   and effective_date between paf.effective_start_date and paf.effective_end_date
   and ppf.person_type_id = ppt.person_type_id
   and ppt.system_person_type IN ('EMP','EMP_APL')
   and effective_date between ppf.effective_start_date and ppf.effective_end_date
   and paf.organization_id + 0 = nvl(p_org_id, paf.organization_id)
   and paf.position_id is not null
   and paf.location_id = hlei.location_id
   and hlei.information_type = 'GHR_US_LOC_INFORMATION'
   and hlei.lei_information3 = gdsf.duty_station_id
   and gdsf.locality_pay_area_id = glpa.locality_pay_area_id
   and effective_date between gdsf.effective_start_date and gdsf.effective_end_date
   and effective_date between glpa.effective_start_date and glpa.effective_end_date
   and glpa.locality_pay_area_code = l_p_locality_area_code
   order by ppf.person_id;

CURSOR ghr_msl (p_msl_id number) is
SELECT name, effective_date, mass_salary_id, user_table_id, submit_flag,
       executive_order_number, executive_order_date, ROWID, PA_REQUEST_ID,
       ORGANIZATION_ID, DUTY_STATION_ID, PERSONNEL_OFFICE_ID,
       AGENCY_CODE_SUBELEMENT, OPM_ISSUANCE_NUMBER, OPM_ISSUANCE_DATE,
       locality_pay_area_code
FROM ghr_mass_salaries
WHERE MASS_SALARY_ID = p_msl_id
---and   process_type   = <>
for update of user_table_id nowait;

CURSOR get_sal_chg_fam is
SELECT NOA_FAMILY_CODE
FROM ghr_families
WHERE NOA_FAMILY_CODE in
    (SELECT NOA_FAMILY_CODE FROM ghr_noa_families
     WHERE  nature_of_action_id in
            (SELECT nature_of_action_id
             FROM ghr_nature_of_actions
             WHERE code = nvl(ghr_msl_pkg.g_first_noa_code,'895') )
    ) and proc_method_flag = 'Y';

l_assignment_id        per_assignments_f.assignment_id%type;
l_position_id          per_assignments_f.position_id%type;
l_grade_id             per_assignments_f.grade_id%type;
l_business_group_id    per_assignments_f.business_group_id%type;

l_position_title       varchar2(300);
l_position_number      varchar2(20);
l_position_seq_no      varchar2(20);

l_msl_cnt              number := 0;
l_recs_failed          number := 0;

l_tenure               varchar2(35);
l_annuitant_indicator  varchar2(35);
l_pay_rate_determinant varchar2(35);
l_work_schedule        varchar2(35);
l_part_time_hour       varchar2(35);
l_pay_table_id         number;
l_pay_plan             varchar2(30);
l_grade_or_level       varchar2(30);
l_step_or_rate         varchar2(30);
l_pay_basis            varchar2(30);
	l_location_id          number;
	l_duty_station_id      number;
	l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
	l_duty_station_code    ghr_pa_requests.duty_station_code%type;
	l_effective_date       date;
	l_personnel_office_id  varchar2(300);
	l_org_structure_id     varchar2(300);
	l_sub_element_code     varchar2(300);

	l_old_basic_pay        number;
	l_old_avail_pay        number;
	l_old_loc_diff         number;
	l_tot_old_sal          number;
	l_old_auo_pay          number;
	l_old_ADJ_basic_pay    number;
	l_other_pay            number;


	l_auo_premium_pay_indicator     varchar2(30);
	l_ap_premium_pay_indicator      varchar2(30);
	l_retention_allowance           number;
	l_retention_allow_perc          number;
	l_new_retention_allowance       number;
	l_supervisory_differential      number;
	l_supervisory_diff_perc         number;
	l_new_supervisory_differential  number;
	l_staffing_differential         number;

	l_new_avail_pay             number;
	l_new_loc_diff              number;
	l_tot_new_sal               number;
	l_new_auo_pay               number;

	l_new_basic_pay             number;
	l_new_locality_adj          number;
	l_new_adj_basic_pay         number;
	l_new_total_salary          number;
	l_new_other_pay_amount      number;
	l_new_au_overtime           number;
	l_new_availability_pay      number;
	l_out_step_or_rate          varchar2(30);
	l_out_pay_rate_determinant  varchar2(30);
	l_PT_eff_start_date         date;
	l_open_pay_fields           boolean;
	l_message_set               boolean;
	l_calculated                boolean;

	l_mass_salary_id            number;
	l_user_table_id             number;
	l_submit_flag               varchar2(2);
	l_executive_order_number    ghr_mass_salaries.executive_order_number%TYPE;
	l_executive_order_date      ghr_mass_salaries.executive_order_date%TYPE;
	l_opm_issuance_number       ghr_mass_salaries.opm_issuance_number%TYPE;
	l_opm_issuance_date         ghr_mass_salaries.opm_issuance_date%TYPE;
	l_pa_request_id             number;
	l_rowid                     varchar2(30);

	l_p_ORGANIZATION_ID           number;
	l_p_DUTY_STATION_ID           number;
	l_p_PERSONNEL_OFFICE_ID       varchar2(5);

	L_row_cnt                   number := 0;

	l_sf52_rec                  ghr_pa_requests%rowtype;
	l_lac_sf52_rec              ghr_pa_requests%rowtype;
	l_errbuf                    varchar2(2000);

	l_retcode                   number;

	l_pos_ei_data               per_position_extra_info%rowtype;
	l_pos_grp1_rec              per_position_extra_info%rowtype;

	l_pay_calc_in_data          ghr_pay_calc.pay_calc_in_rec_type;
	l_pay_calc_out_data         ghr_pay_calc.pay_calc_out_rec_type;
	l_sel_flg                   varchar2(2);

	l_first_action_la_code1     varchar2(30);
	l_first_action_la_code2     varchar2(30);

	l_remark_code1              varchar2(30);
	l_remark_code2              varchar2(30);
	l_p_AGENCY_CODE_SUBELEMENT       varchar2(30);

	----Pay cap variables
	l_entitled_other_pay        NUMBER;
	l_capped_other_pay          NUMBER;
	l_adj_basic_message         BOOLEAN  := FALSE;
	l_pay_cap_message           BOOLEAN  := FALSE;
	l_temp_retention_allowance  NUMBER;
	l_open_pay_fields_caps      BOOLEAN;
	l_message_set_caps          BOOLEAN;
	l_total_pay_check           VARCHAR2(1);
	l_comment                   VARCHAR2(150);
	l_comment_sal               VARCHAR2(150);
	-- Bug#3968005 Commented l_pay_sel as it is not required.
        -- l_pay_sel                   VARCHAR2(1) := NULL;
	l_old_capped_other_pay     NUMBER;
	----
	REC_BUSY                    exception;
	pragma exception_init(REC_BUSY,-54);

	l_proc  varchar2(72) :=  g_package || '.execute_mlc';

	l_essl_table  BOOLEAN := FALSE;
	l_org_name	hr_organization_units.name%type;
        l_table_type	VARCHAR2(2);

	CURSOR c_pay_tab_type(p_user_table_id    pay_user_tables.user_table_id%type)
	is
	SELECT range_or_match
	FROM   pay_user_tables
	WHERE  user_table_id = p_user_table_id;

	BEGIN
	  g_proc  := 'execute_mlc';
	  hr_utility.set_location('Entering    ' || l_proc,5);

          ghr_msl_pkg.g_first_noa_code     := null;

	  p_retcode  := 0;
	  BEGIN
	    FOR msl IN ghr_msl (p_mass_salary_id)
	    LOOP
		p_mass_salary              := msl.name;
		l_effective_date           := msl.effective_date;
		l_mass_salary_id           := msl.mass_salary_id;
		l_user_table_id            := msl.user_table_id;
		l_submit_flag              := msl.submit_flag;
		l_executive_order_number   := msl.executive_order_number;
		l_executive_order_date     :=  msl.executive_order_date;
		l_opm_issuance_number      :=  msl.opm_issuance_number;
		l_opm_issuance_date        :=  msl.opm_issuance_date;
		l_pa_request_id            := msl.pa_request_id;
		l_rowid                    := msl.rowid;
		l_p_ORGANIZATION_ID        := msl.ORGANIZATION_ID;
		l_p_DUTY_STATION_ID        := msl.DUTY_STATION_ID;
		l_p_PERSONNEL_OFFICE_ID    := msl.PERSONNEL_OFFICE_ID;
		l_p_AGENCY_CODE_SUBELEMENT := msl.AGENCY_CODE_SUBELEMENT;
		l_p_locality_area_code     := msl.locality_pay_area_code;

			pr('Pa request id is '||to_char(l_pa_request_id));
	       exit;
	    END LOOP;
	  EXCEPTION
	    when REC_BUSY then
		hr_utility.set_location('Mass Salary is in use',1);
		l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
		hr_utility.set_message(8301, 'GHR_38477_LOCK_ON_MSL');
		hr_utility.raise_error;
	    when others then
		hr_utility.set_location('Error in '||l_proc||' Sql err is '||sqlerrm(sqlcode),1);
		l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
		raise mlc_error;
	  END;

	  g_effective_date := l_effective_date;

	  IF upper(p_action) = 'CREATE' then
	     ghr_mto_int.set_log_program_name('GHR_MLC_PKG');
	  ELSE
	     ghr_mto_int.set_log_program_name('MLC_'||p_mass_salary);
	  END IF;

	  get_lac_dtls(l_pa_request_id,
		       l_lac_sf52_rec);

--------GPPA Update 46 start

          if l_effective_date >= to_date('2007/01/07','YYYY/MM/DD') AND
             l_lac_sf52_rec.first_action_la_code1 = 'VGR' THEN

             ghr_msl_pkg.g_first_noa_code := '894';

          end if;

--------GPPA Update 46 end
	  hr_utility.set_location('After fetch msl '||to_char(l_effective_date)
	    ||' '||to_char(l_user_table_id),20);

	    FOR per IN cur_people (l_effective_date,l_p_ORGANIZATION_ID)
	    LOOP
	     BEGIN
	      savepoint execute_mlc_sp;
		 l_msl_cnt := l_msl_cnt +1;
		 --Bug#3968005 Initialised l_sel_flg
		 l_sel_flg := NULL;
		 l_pay_calc_in_data  := NULL;
		 l_pay_calc_out_data := NULL;

	       l_assignment_id     := per.assignment_id;
	       l_position_id       := per.position_id;
	       l_grade_id          := per.grade_id;
	       l_business_group_id := per.business_group_iD;
	       l_location_id       := per.location_id;

	hr_utility.set_location('The location id is:'||l_location_id,12345);
       begin
          ghr_pa_requests_pkg.get_SF52_loc_ddf_details
              (p_location_id      => l_location_id
              ,p_duty_station_id  => l_duty_station_id);
       exception
          when others then
             hr_utility.set_location(
             'Error in Ghr_pa_requests_pkg.get_sf52_loc_ddf_details'||
                   'Err is '||sqlerrm(sqlcode),20);
             l_mlcerrbuf := 'Error in get_sf52_loc_ddf_details '||
                   'Sql Err is '|| sqlerrm(sqlcode);
             raise mlc_error;
       end;

       l_org_name :=GHR_MRE_PKG.GET_ORGANIZATION_NAME(per.ORGANIZATION_ID);

       get_pos_grp1_ddf(l_position_id,
                        l_effective_date,
                        l_pos_grp1_rec);

       l_personnel_office_id :=  l_pos_grp1_rec.poei_information3;
       l_org_structure_id    :=  l_pos_grp1_rec.poei_information5;

       get_sub_element_code_pos_title(l_position_id,
                                     null,
                                     l_business_group_id,
                                     l_assignment_id,
                                     l_effective_date,
                                     l_sub_element_code,
                                     l_position_title,
                                     l_position_number,
                                     l_position_seq_no);

	hr_utility.set_location('The duty station id is:'||l_duty_station_id,12345);

       if check_init_eligibility(l_p_duty_station_id,
                              l_p_PERSONNEL_OFFICE_ID,
                              l_p_AGENCY_CODE_SUBELEMENT,
                              l_duty_station_id,
                              l_personnel_office_id,
                              l_sub_element_code) then

          hr_utility.set_location('check_init_eligibility    ' || l_proc,6);

	  begin
	       ghr_pa_requests_pkg.get_sf52_asg_ddf_details
	           (l_assignment_id,
		    l_effective_date,
		    l_tenure,
		    l_annuitant_indicator,
		    l_pay_rate_determinant,
		    l_work_schedule,
		    l_part_time_hour);
          exception
	       when others then
	            hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details'||
	                                                             'Err is '||sqlerrm(sqlcode),20);
                    l_mlcerrbuf := 'Error in get_sf52_asgddf_details Sql Err is '|| sqlerrm(sqlcode);
	            raise mlc_error;
	  end;

	BEGIN
		-- Get Pay table ID and other details
		   ghr_msl_pkg.get_pay_plan_and_table_id(l_pay_rate_determinant,per.person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_assignment_id,'SHOW',l_pay_plan,
                           l_pay_table_id,l_grade_or_level, l_step_or_rate,
                           l_pay_basis);
	EXCEPTION
		when ghr_msl_pkg.msl_error then
		  l_mlcerrbuf := hr_utility.get_message;
		  raise mlc_error;
	END;

			IF check_eligibility(
                               l_pay_plan,
                               per.person_id,
                               l_effective_date,
                               p_action) THEN

                               hr_utility.set_location('check_eligibility    ' || l_proc,8);

			 IF upper(p_action) = 'REPORT' AND l_submit_flag = 'P' THEN
		 	 -- BUG 3377958 Madhuri
 			    pop_dtls_from_pa_req(per.person_id,l_effective_date,l_mass_salary_id,l_org_name);
 		    	 -- BUG 3377958 Madhuri
			 ELSE
			   IF check_select_flg(per.person_id,
                                               upper(p_action),
					       l_effective_date,
                                               p_mass_salary_id,
                                               l_sel_flg) then

	        hr_utility.set_location('check_select_flg    ' || l_proc,7);
                  BEGIN
		hr_utility.set_location('The duty station name is:'||l_duty_station_code,12345);
		hr_utility.set_location('The duty station desc is:'||l_duty_station_desc,12345);
		     ghr_pa_requests_pkg.get_duty_station_details
                       (p_duty_station_id        => l_duty_station_id
                       ,p_effective_date        => l_effective_date
                       ,p_duty_station_code        => l_duty_station_code
                       ,p_duty_station_desc        => l_duty_station_desc);
                  EXCEPTION
                     when others then
                        hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_duty_station_details'||
                               'Err is '||sqlerrm(sqlcode),20);
                    l_mlcerrbuf := 'Error in get_duty_station_details Sql Err is '|| sqlerrm(sqlcode);
                    raise mlc_error;

                  END;

                  get_other_dtls_for_rep(l_pay_rate_determinant,
                                     l_executive_order_number,
                                     to_char(l_executive_order_date),
                                     l_first_action_la_code1,
                                     l_first_action_la_code2,
                                     l_remark_code1,
                                     l_remark_code2);

                  get_from_sf52_data_elements
                            (l_assignment_id,
                             l_effective_date,
                             l_old_basic_pay,
                             l_old_avail_pay,
                             l_old_loc_diff,
                             l_tot_old_sal,
                             l_old_auo_pay,
                             l_old_adj_basic_pay,
                             l_other_pay,
                             l_auo_premium_pay_indicator,
                             l_ap_premium_pay_indicator,
                             l_retention_allowance,
                             l_retention_allow_perc,
                             l_supervisory_differential,
                             l_supervisory_diff_perc,
                             l_staffing_differential);

  open get_sal_chg_fam;
  fetch get_sal_chg_fam into l_pay_calc_in_data.noa_family_code;
  close get_sal_chg_fam;

  l_pay_calc_in_data.person_id                 := per.person_id;
  l_pay_calc_in_data.position_id               := l_position_id;
  l_pay_calc_in_data.noa_code                  := nvl(ghr_msl_pkg.g_first_noa_code,'895');
  l_pay_calc_in_data.second_noa_code           := null;
  l_pay_calc_in_data.first_action_la_code1     := l_lac_sf52_rec.first_action_la_code1;
  l_pay_calc_in_data.effective_date            := l_effective_date;
  l_pay_calc_in_data.pay_rate_determinant      := l_pay_rate_determinant;
  l_pay_calc_in_data.pay_plan                  := l_pay_plan;
  l_pay_calc_in_data.grade_or_level            := l_grade_or_level;
  l_pay_calc_in_data.step_or_rate              := l_step_or_rate;
  l_pay_calc_in_data.pay_basis                 := l_pay_basis;
  l_pay_calc_in_data.user_table_id             := l_pay_table_id;
  l_pay_calc_in_data.duty_station_id           := l_duty_station_id;
  l_pay_calc_in_data.auo_premium_pay_indicator := l_auo_premium_pay_indicator;
  l_pay_calc_in_data.ap_premium_pay_indicator  := l_ap_premium_pay_indicator;
  l_pay_calc_in_data.retention_allowance       := l_retention_allowance;
  l_pay_calc_in_data.to_ret_allow_percentage   := l_retention_allow_perc;
  l_pay_calc_in_data.supervisory_differential  := l_supervisory_differential;
  l_pay_calc_in_data.staffing_differential     := l_staffing_differential;
  l_pay_calc_in_data.current_basic_pay         := l_old_basic_pay;
  l_pay_calc_in_data.current_adj_basic_pay     := l_old_adj_basic_pay;
  l_pay_calc_in_data.current_step_or_rate      := l_step_or_rate;
  l_pay_calc_in_data.pa_request_id             := null;

  -- Mass Salary Percetnage Changes
  -- IF the table is of type R then populate the basic into open_pay_basic
  FOR pay_tab_type IN c_pay_tab_type(l_pay_table_id)
  LOOP
	l_table_type   := pay_tab_type.range_or_match;
  END LOOP;

  IF ( l_table_type = 'R') THEN
	l_pay_calc_in_data.open_range_out_basic_pay := l_old_basic_pay;
  -- Bug#3968005 Added Else Condition. Setting open_range_out_basic_pay to NULL
  -- because pay calculation will calculate values depending on this value.
  -- See pay calculation for further details.
  ELSE
     l_pay_calc_in_data.open_range_out_basic_pay := NULL;
  END IF;

              BEGIN
                  ghr_pay_calc.sql_main_pay_calc (l_pay_calc_in_data
                       ,l_pay_calc_out_data
                       ,l_message_set
                       ,l_calculated);

                  IF l_message_set THEN
                    hr_utility.set_location( l_proc, 40);
                    l_calculated     := FALSE;
                    l_mlcerrbuf  := hr_utility.get_message;
                  END IF;
              EXCEPTION
                  when mlc_error then
                       g_proc := 'ghr_pay_calc';
                       raise;
                  when others then
                       IF ghr_pay_calc.gm_unadjusted_pay_flg = 'Y' then
                          l_comment := 'MLC:Error: Unadjusted Basic Pay must be entered in Employee record.';
                       ELSE
                          l_comment := 'MLC:Error: See process log for details.';
                       END IF;

                       IF upper(p_action) IN ('SHOW') THEN
                          -- Bug#2383392
                          create_mass_act_prev (
                             p_effective_date          => l_effective_date,
                             p_date_of_birth           => per.date_of_birth,
                             p_full_name               => per.full_name,
                             p_national_identifier     => per.national_identifier,
                             p_duty_station_code       => l_duty_station_code,
                             p_duty_station_desc       => l_duty_station_desc,
                             p_personnel_office_id     => l_personnel_office_id,
                             p_basic_pay               => l_old_basic_pay,
                             p_new_basic_pay           => null,
                             --Bug#2383992 Added old_adj_basic_pay
                             p_adj_basic_pay           => l_old_adj_basic_pay,
                             p_new_adj_basic_pay       => null,
                             p_old_avail_pay           => l_old_avail_pay,
                             p_new_avail_pay           => null,
                             p_old_loc_diff            => l_old_loc_diff,
                             p_new_loc_diff            => null,
                             p_tot_old_sal             => l_tot_old_sal,
                             p_tot_new_sal             => null,
                             p_old_auo_pay             => l_old_auo_pay,
                             p_new_auo_pay             => null,
                             p_position_id             => l_position_id,
                             p_position_title          => l_position_title,
                             -- FWFA Changes Bug#4444609
                             p_position_number         => l_position_number,
                             p_position_seq_no         => l_position_seq_no,
                             -- FWFA Changes
                             p_org_structure_id        => l_org_structure_id,
                             p_agency_sub_element_code => l_sub_element_code,
                             p_person_id               => per.person_id,
                             p_mass_salary_id          => l_mass_salary_id,
                             p_sel_flg                 => l_sel_flg,
                             p_first_action_la_code1   => l_first_action_la_code1,
                             p_first_action_la_code2   => l_first_action_la_code2,
                             p_remark_code1            => l_remark_code1,
                             p_remark_code2            => l_remark_code2,
                             p_grade_or_level          => l_grade_or_level,
                             p_step_or_rate            => l_step_or_rate,
                             p_pay_plan                => l_pay_plan,
                             p_pay_rate_determinant    => null,
                             p_tenure                  => l_tenure,
                             p_action                  => p_action,
                             p_assignment_id           => l_assignment_id,
                             p_old_other_pay           => l_other_pay,
                             p_new_other_pay           => null,
                             -- Bug#2383992
                             p_old_capped_other_pay    => NULL,
                             p_new_capped_other_pay    => NULL,
                             p_old_retention_allowance => l_retention_allowance,
                             p_new_retention_allowance => NULL,
                             p_old_supervisory_differential => l_supervisory_differential,
                             p_new_supervisory_differential => NULL,
                             -- BUG 3377958 Madhuri
                             p_organization_name            => l_org_name,
                             -- BUG 3377958 Madhuri
                             -- Bug#2383992
                             -- FWFA Changes Bug#4444609
                             p_input_pay_rate_determinant  => l_pay_rate_determinant,
                             p_from_pay_table_id         => l_user_table_id,
                             p_to_pay_table_id           =>  null
                             -- FWFA Changes
                              );
                       END IF;
		               -- Bug#3968005 Replaced parameter l_pay_sel with l_sel_flg
                       ins_upd_per_extra_info
                         (per.person_id,l_effective_date, l_sel_flg, l_comment,p_mass_salary_id);
                       l_comment := NULL;
                       ------  BUG 3287299 End
                       hr_utility.set_location('Error in Ghr_pay_calc.sql_main_pay_calc '||
                                 'Err is '||sqlerrm(sqlcode),20);
                       l_mlcerrbuf := 'Error in ghr_pay_calc  Sql Err is '|| sqlerrm(sqlcode);
                       g_proc := 'ghr_pay_calc';
                       raise mlc_error;
                    END;

                       l_new_basic_pay                := l_pay_calc_out_data.basic_pay;
                       l_new_locality_adj             := l_pay_calc_out_data.locality_adj;
                       l_new_adj_basic_pay            := l_pay_calc_out_data.adj_basic_pay;
                       l_new_au_overtime              := l_pay_calc_out_data.au_overtime;
                       l_new_availability_pay         := l_pay_calc_out_data.availability_pay;

                       l_out_pay_rate_determinant     := l_pay_calc_out_data.out_pay_rate_determinant;
                       l_out_step_or_rate             := l_pay_calc_out_data.out_step_or_rate;
                       l_new_retention_allowance      :=  l_pay_calc_out_data.retention_allowance;
                       l_new_supervisory_differential := l_supervisory_differential;
                       l_new_other_pay_amount         := l_pay_calc_out_data.other_pay_amount;
                       l_entitled_other_pay           := l_new_other_pay_amount;
                       if l_new_other_pay_amount = 0 then
                          l_new_other_pay_amount := null;
                       end if;
                       l_new_total_salary             := l_pay_calc_out_data.total_salary;

     hr_utility.set_location('retention_allowance = ' || to_char(l_retention_allowance),10);
     hr_utility.set_location('Supervisory Diff Amount = ' || to_char(l_supervisory_differential),10);

-------------Call Pay cap Procedure
     begin
      l_capped_other_pay := ghr_pa_requests_pkg2.get_cop( p_assignment_id  => l_assignment_id
                                                         ,p_effective_date => l_effective_date);
      l_old_capped_other_pay :=  l_capped_other_pay;
	-- Sundar Added the following if statement to improve performance
	if hr_utility.debug_enabled = true then
	  hr_utility.set_location('Before Pay Cap    ' || l_proc,21);
	  hr_utility.set_location('l_effective_date  ' || l_effective_date,21);
	  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,21);
	  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,21);
	  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),21);
	  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,21);
	  hr_utility.set_location('person_id  ' || to_char(per.person_id),21);
	  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),21);
	  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),21);
	  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),21);
	  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),21);
	  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),21);
	  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),21);
	  hr_utility.set_location('l_new_retention_allowance ' || to_char(l_new_retention_allowance),21);
  hr_utility.set_location('l_new_supervisory_differential ' || to_char(l_new_supervisory_differential),21);
	  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),21);
	  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),21);
	  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),21);
	end if;

      ghr_pay_caps.do_pay_caps_main
                   (p_pa_request_id        =>    null
                   ,p_effective_date       =>    l_effective_date
                   ,p_pay_rate_determinant =>    nvl(l_out_pay_rate_determinant,l_pay_rate_determinant)
                   ,p_pay_plan             =>    l_pay_plan
                   ,p_to_position_id       =>    l_position_id
                   ,p_pay_basis            =>    l_pay_basis
                   ,p_person_id            =>    per.person_id
                   ,p_noa_code             =>    nvl(ghr_msl_pkg.g_first_noa_code,'895')
                   ,p_basic_pay            =>    l_new_basic_pay
                   ,p_locality_adj         =>    l_new_locality_adj
                   ,p_adj_basic_pay        =>    l_new_adj_basic_pay
                   ,p_total_salary         =>    l_new_total_salary
                   ,p_other_pay_amount     =>    l_entitled_other_pay
                   ,p_capped_other_pay     =>    l_capped_other_pay
                   ,p_retention_allowance  =>    l_new_retention_allowance
                   ,p_retention_allow_percentage => l_retention_allow_perc
                   ,p_supervisory_allowance =>   l_new_supervisory_differential
                   ,p_staffing_differential =>   l_staffing_differential
                   ,p_au_overtime          =>    l_new_au_overtime
                   ,p_availability_pay     =>    l_new_availability_pay
                   ,p_adj_basic_message    =>    l_adj_basic_message
                   ,p_pay_cap_message      =>    l_pay_cap_message
                   ,p_pay_cap_adj          =>    l_temp_retention_allowance
                   ,p_open_pay_fields      =>    l_open_pay_fields_caps
                   ,p_message_set          =>    l_message_set_caps
                   ,p_total_pay_check      =>    l_total_pay_check);


             l_new_other_pay_amount := nvl(l_capped_other_pay,l_entitled_other_pay);

	-- Sundar Added the following statement to improve performance
	if hr_utility.debug_enabled = true then
	  hr_utility.set_location('After Pay Cap    ' || l_proc,22);
	  hr_utility.set_location('l_effective_date  ' || l_effective_date,22);
	  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,22);
	  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,22);
	  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),22);
	  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,22);
	  hr_utility.set_location('person_id  ' || to_char(per.person_id),22);
	  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),22);
	  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),22);
	  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),22);
	  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),22);
	  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),22);
	  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),22);
	  hr_utility.set_location('l_new_retention_allowance  ' || to_char(l_new_retention_allowance),22);
  hr_utility.set_location('l_new_supervisory_differential  ' || to_char(l_new_supervisory_differential),22);
	  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),22);
	  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),22);
	  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),22);
	end if;

       IF l_pay_cap_message THEN
	IF nvl(l_temp_retention_allowance,0) > 0 THEN
	  l_comment := 'MLC: Exceeded Total Cap - reduce Retention Allow to '
			|| to_char(l_temp_retention_allowance);
	  -- Bug#3968005 Replaced l_pay_sel with l_sel_flg
	  l_sel_flg := 'N';
	ELSE
	  l_comment := 'MLC: Exceeded Total cap - pls review.';
	END IF;
       ELSIF l_adj_basic_message THEN
          l_comment := 'MLC: Exceeded Adjusted Pay Cap - Locality reduced.';
       END IF;

       -- Bug 2639698 Sundar
       IF (l_old_basic_pay > l_new_basic_pay) THEN
           l_comment_sal := 'MLC: From Basic Pay exceeds To Basic Pay.';
       END IF;
	   -- End Bug 2639698

       IF l_pay_cap_message or l_adj_basic_message THEN
    	  -- Bug 2639698
	  IF (l_comment_sal IS NOT NULL) THEN
	     l_comment := l_comment_sal || ' ' || l_comment;
	  END IF;
	  -- End Bug 2639698
	  -- Bug#3968005 Replaced parameter l_pay_sel with l_sel_flg
          ins_upd_per_extra_info
               (per.person_id,l_effective_date, l_sel_flg, l_comment,p_mass_salary_id);
          l_comment := NULL;
       --------------------Bug 2639698 Sundar To add comments
	   -- Should create comments only if comments need to be inserted
       ELSIF l_comment_sal IS NOT NULL THEN
             -- Bug#3968005 Replaced parameter l_pay_sel with l_sel_flg
       	     ins_upd_per_extra_info
               (per.person_id,l_effective_date, l_sel_flg, l_comment_sal,p_mass_salary_id);
       END IF;

       l_comment_sal := NULL; -- bug 2639698
     exception
          when mlc_error then
               raise;
          when others then
               hr_utility.set_location('Error in ghr_pay_caps.do_pay_caps_main ' ||
                                'Err is '||sqlerrm(sqlcode),23);
                    l_mlcerrbuf := 'Error in do_pay_caps_main  Sql Err is '|| sqlerrm(sqlcode);
                    raise mlc_error;
     end;


                IF upper(p_action) IN ('SHOW','REPORT') THEN
                          -- Bug#2383392
                    create_mass_act_prev (
                        p_effective_date          => l_effective_date,
                        p_date_of_birth           => per.date_of_birth,
                        p_full_name               => per.full_name,
                        p_national_identifier     => per.national_identifier,
                        p_duty_station_code       => l_duty_station_code,
                        p_duty_station_desc       => l_duty_station_desc,
                        p_personnel_office_id     => l_personnel_office_id,
                        p_basic_pay               => l_old_basic_pay,
                        p_new_basic_pay           => l_new_basic_pay,
                        --Bug#2383992 Added old_adj_basic_pay
                        p_adj_basic_pay           => l_old_adj_basic_pay,
                        p_new_adj_basic_pay       => l_new_adj_basic_pay,
                        p_old_avail_pay           => l_old_avail_pay,
                        p_new_avail_pay           =>  l_new_availability_pay,
                        p_old_loc_diff            => l_old_loc_diff,
                        p_new_loc_diff            => l_new_locality_adj,
                        p_tot_old_sal             => l_tot_old_sal,
                        p_tot_new_sal             =>   l_new_total_salary,
                        p_old_auo_pay             => l_old_auo_pay,
                        p_new_auo_pay             =>   l_new_au_overtime,
                        p_position_id             => l_position_id,
                        p_position_title          => l_position_title,
                         -- FWFA Changes Bug#4444609
                         p_position_number         => l_position_number,
                         p_position_seq_no         => l_position_seq_no,
                         -- FWFA Changes
                        p_org_structure_id        => l_org_structure_id,
                        p_agency_sub_element_code => l_sub_element_code,
                        p_person_id               => per.person_id,
                        p_mass_salary_id          => l_mass_salary_id,
                        p_sel_flg                 => l_sel_flg,
                        p_first_action_la_code1   => l_first_action_la_code1,
                        p_first_action_la_code2   => l_first_action_la_code2,
                        p_remark_code1            => l_remark_code1,
                        p_remark_code2            => l_remark_code2,
                        p_grade_or_level          => l_grade_or_level,
                        p_step_or_rate            => l_step_or_rate,
                        p_pay_plan                => l_pay_plan,
                        -- FWFA Changes Bug#4444609 Passed l_out_pay_rate_determinant
                        p_pay_rate_determinant    => NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                        -- FWFA Changes
                        p_tenure                  => l_tenure,
                        p_action                  => p_action,
                        p_assignment_id           => l_assignment_id,
                        p_old_other_pay           => l_other_pay,
                        p_new_other_pay           => l_new_other_pay_amount,
                        -- Bug#2383992
                        p_old_capped_other_pay    => l_old_capped_other_pay,--NULL,
                        p_new_capped_other_pay    => l_capped_other_pay,
                        p_old_retention_allowance => l_retention_allowance,
                        p_new_retention_allowance => l_new_retention_allowance,
                        p_old_supervisory_differential => l_supervisory_differential,
                        p_new_supervisory_differential => l_new_supervisory_differential,
                        -- BUG 3377958 Madhuri
                        p_organization_name            => l_org_name,
                        -- Bug#2383992
                        -- FWFA Changes Bug#4444609
                        p_input_pay_rate_determinant   => l_pay_rate_determinant,
                        p_from_pay_table_id            => l_pay_calc_out_data.pay_table_id,
                        p_to_pay_table_id              => l_pay_calc_out_data.calculation_pay_table_id
                        -- FWFA Changes
                         );


                ELSIF upper(p_action) = 'CREATE' then

                     BEGIN
                        ghr_msl_pkg.get_pay_plan_and_table_id
                              (l_pay_rate_determinant,per.person_id,
                               l_position_id,l_effective_date,
                               l_grade_id, l_assignment_id,'CREATE',
                               l_pay_plan,l_pay_table_id,
                               l_grade_or_level, l_step_or_rate,
                               l_pay_basis);
                    EXCEPTION
                    when ghr_msl_pkg.msl_error then
                      l_mlcerrbuf := hr_utility.get_message;
                      raise mlc_error;
                    END;

                     assign_to_sf52_rec(
                       per.person_id,
                       per.first_name,
                       per.last_name,
                       per.middle_names,
                       per.national_identifier,
                       per.date_of_birth,
                       l_effective_date,
                       l_assignment_id,
                       l_tenure,
                       l_step_or_rate,
                       l_annuitant_indicator,
                       -- FWFA Changes Bug#4444609
                       NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                       -- FWFA Changes
                       l_work_schedule,
                       l_part_time_hour,
                       l_pos_ei_data.poei_information7, --FLSA Category
                       l_pos_ei_data.poei_information8, --Bargaining Unit Status
                       l_pos_ei_data.poei_information11,--Functional Class
                       l_pos_ei_data.poei_information16,--Supervisory Status,
                       l_new_basic_pay,
                       l_new_locality_adj,
                       l_new_adj_basic_pay,
                       l_new_total_salary,
                       l_other_pay,
                       l_new_other_pay_amount,
                       l_new_au_overtime,
                       l_new_availability_pay,
                       l_new_retention_allowance,
                       l_retention_allow_perc,
                       l_new_supervisory_differential,
                       l_supervisory_diff_perc,
                       l_staffing_differential,
                       l_duty_station_id,
                       l_duty_station_code,
                       l_duty_station_desc,
                       -- FWFA Changes Bug#4444609
                       l_pay_rate_determinant,
                       l_pay_calc_out_data.pay_table_id,
                       l_pay_calc_out_data.calculation_pay_table_id,
                       -- FWFA Changes
                       l_lac_sf52_rec,
                       l_sf52_rec);

		  BEGIN
		       ghr_mass_actions_pkg.pay_calc_rec_to_sf52_rec
					   (l_pay_calc_out_data,
		       			    l_sf52_rec);
		  EXCEPTION
		       when others then
		       hr_utility.set_location('Error in Ghr_mass_actions_pkg.pay_calc_rec_to_sf52_rec '||
					       'Err is '||sqlerrm(sqlcode),20);
		       l_mlcerrbuf := 'Error in ghr_mass_act_pkg.pay_calc_to_sf52  Sql Err is ' ||
                                               sqlerrm(sqlcode);
		       raise mlc_error;
		  END;

                  BEGIN

                      l_sf52_rec.mass_action_id := p_mass_salary_id;
                      l_sf52_rec.rpa_type       := 'MLC';

                      ghr_mass_changes.create_sf52_for_mass_changes
                           (p_mass_action_type => 'MASS_LOCALITY_CHG',
                            p_pa_request_rec  => l_sf52_rec,
                            p_errbuf           => l_errbuf,
                            p_retcode          => l_retcode);

		      ------ Added by Dinkar for List reports problem

		      DECLARE
			 l_pa_request_number ghr_pa_requests.request_number%TYPE;
		      BEGIN

			 l_pa_request_number   := l_sf52_rec.request_number||'-'||p_mass_salary_id;

			 ghr_par_upd.upd
			  (p_pa_request_id             => l_sf52_rec.pa_request_id,
			   p_object_version_number     => l_sf52_rec.object_version_number,
			   p_request_number            => l_pa_request_number
			  );
		      END;

	   	      ---------------------------------------
                      IF l_errbuf is null then
                           pr('No error in create sf52 ');
                           hr_utility.set_location('Before commiting',2);

                           ghr_mto_int.log_message(
                              p_procedure => 'Successful Completion',
                              p_message   => 'Name: '||per.full_name ||
                                             ' SSN: '|| per.national_identifier|| '  Mass Salary : '||
                                             p_mass_salary ||' SF52 Successfully completed');

                           create_lac_remarks(l_pa_request_id, l_sf52_rec.pa_request_id);

                           -- Added by Enunez 11-SEP-1999
                           IF l_lac_sf52_rec.first_action_la_code1 IS NULL THEN
                             -- Added by Edward Nunez for 895 rules
                             g_proc := 'Apply_895_Rules';
                              --Bug 2012782 fix
                             if l_out_pay_rate_determinant is null then
                                l_out_pay_rate_determinant := l_pay_rate_determinant;
                             end if;
                              --Bug 2012782 fix end
                             ghr_lacs_remarks.Apply_894_Rules(
                               l_sf52_rec.pa_request_id,
                               l_out_pay_rate_determinant,
                               l_pay_rate_determinant,
                               l_out_step_or_rate,
                               l_executive_order_number,
                               l_executive_order_date,
                               l_opm_issuance_number,
                               l_opm_issuance_date,
                               l_errbuf,
                               l_retcode
                               );
                             if l_errbuf is not null then
                                l_mlcerrbuf := l_mlcerrbuf || ' ' || l_errbuf || ' Sql Err is '
                                                                  || sqlerrm(sqlcode);
                               raise mlc_error;
                             end if;
                           END IF; -- IF l_lac_sf52_rec.first_action_la_code1
                           g_proc := 'update_SEL_FLG';

                           update_SEL_FLG(PER.PERSON_ID,l_effective_date);

                           commit;
                        else
                           pr('Error in create sf52',l_errbuf);
                           hr_utility.set_location('Error in '||to_char(per.position_id),20);
                           --l_recs_failed := l_recs_failed + 1;
                           raise mlc_error;
                        end if; -- if l_errbuf is null then
                   exception
                      when mlc_error then raise;
                      when others then  null;
                    l_mlcerrbuf := 'Error in ghr_mass_chg.create_sf52 '||
                              ' Sql Err is '|| sqlerrm(sqlcode);
                    raise mlc_error;
                   end;
                END IF; --  IF upper(p_action) IN ('SHOW','REPORT') THEN
              END IF; -- end if for check_select_flg
           END IF; -- end if for p_action = 'REPORT'
         END IF; --- end if for check_eligbility
       --- END IF; -- CHECK FOR PAY PLAN
       --- END IF; -- check for PRD
       --- END LOOP; -- Record Type Loop ends here
      END IF; --- end if for check_init_eligibility

         L_row_cnt := L_row_cnt + 1;
         if upper(p_action) <> 'CREATE' THEN
           if L_row_cnt > 50 then
              commit;
              L_row_cnt := 0;
           end if;
         end if;
      EXCEPTION
         WHEN mlc_ERROR THEN
               HR_UTILITY.SET_LOCATION('Error occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),10);
               begin
                ------  BUG 3287299 -- Not to rollback for preview.
       	        if upper(p_action) <> 'SHOW' then
                  ROLLBACK TO EXECUTE_MLC_SP;
                end if;
               EXCEPTION
                  WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error in '||l_proc||' '||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| per.full_name || ' SSN: ' || per.national_identifier ||' '||
                              l_mlcerrbuf;
               hr_utility.set_location('before creating entry in log file',10);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);

            exception
                when others then
                    hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
                    hr_utility.raise_error;
            end;
         when others then
               HR_UTILITY.SET_LOCATION('Error (Others) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),20);
               BEGIN
                 ROLLBACK TO EXECUTE_MLC_SP;
               EXCEPTION
                 WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error (others) in '||l_proc||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| per.full_name || ' SSN: ' || per.national_identifier ||
                              ' Sql Err is '||sqlerrm(sqlcode);
               hr_utility.set_location('before creating entry in log file',20);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);
            exception
                when others then
                    hr_utility.set_message(8301, 'Create Error Log failed');
                    hr_utility.raise_error;
            end;
      END;
    END LOOP;

    pr('After processing is over ',to_char(l_recs_failed));

    IF (l_recs_failed  = 0) then
     IF upper(p_action) = 'CREATE' THEN
       begin
          update ghr_mass_salaries
             set submit_flag = 'P'
           where rowid = l_rowid;
       EXCEPTION
         when others then
           HR_UTILITY.SET_LOCATION('Error in Update ghr_msl  Sql error '||sqlerrm(sqlcode),30);
           hr_utility.set_message(8301, 'GHR_38476_UPD_GHR_MSL_FAILURE');
           hr_utility.raise_error;
       END;
-----Bug 2849262. Updating extra info to null is already done by Update_sel_flg in the main loop.
-----             So it is not required to do in global if you see the procedure upd_ext_info_to_null
-----             Commenting the following line. Dated 14-OCT-2003.
-----
-----  upd_ext_info_to_null(l_effective_date);
     end if;
  ELSE
--if (l_recs_failed  <> 0) then
      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_salaries
            set submit_flag = 'E'
          where rowid = l_rowid;
      END IF;
  end if;
pr('Before commiting.....');
COMMIT;
pr('After commiting.....',to_char(l_recs_failed));

EXCEPTION
    when others then
--    raise_application_error(-20121,'Error in EXECUTE_MLC Err is '||sqlerrm(sqlcode));
      HR_UTILITY.SET_LOCATION('Error (Others2) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),30);
      BEGIN
        ROLLBACK TO EXECUTE_MLC_SP;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
      l_log_text  := 'Error in '||l_proc||
                     ' For Mass Salary Name : '||p_mass_salary||
                     ' Sql Err is '||sqlerrm(sqlcode);
      l_recs_failed := l_recs_failed + 1;
      hr_utility.set_location('before creating entry in log file',30);

      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_salaries
            set submit_flag = 'E'
          where rowid = l_rowid;
          commit;
      END IF;

      begin
         ghr_mto_int.log_message(
                        p_procedure => g_proc,
                        p_message   => l_log_text);
      exception
          when others then
              hr_utility.set_message(8301, 'Create Error Log failed');
              hr_utility.raise_error;
      end;
END EXECUTE_MLC;

--
--
--

PROCEDURE execute_msl_pay (p_errbuf         OUT NOCOPY varchar2,
                           p_retcode        OUT NOCOPY number,
                           p_mass_salary_id IN number,
                           p_action         IN varchar2) is

p_mass_salary varchar2(32);
--
-- Main Cursor which fetches from per_assignments_f and per_people_f
--
-- 1. Cursor with organization.
--
cursor cur_people_org (effective_date date, p_org_id number) is
select ppf.person_id                 PERSON_ID,
       ppf.first_name                FIRST_NAME,
       ppf.last_name                 LAST_NAME,
       ppf.middle_names              MIDDLE_NAMES,
       ppf.full_name                 FULL_NAME,
       ppf.date_of_birth             DATE_OF_BIRTH,
       ppf.national_identifier       NATIONAL_IDENTIFIER,
       paf.position_id               POSITION_ID,
       paf.assignment_id             ASSIGNMENT_ID,
       paf.grade_id                  GRADE_ID,
       paf.job_id                    JOB_ID,
       paf.location_id               LOCATION_ID,
       paf.organization_id           ORGANIZATION_ID,
       paf.business_group_id         BUSINESS_GROUP_ID,
       paf.assignment_status_type_id ASSIGNMENT_STATUS_TYPE_ID
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt
 where ppf.person_id           = paf.person_id
   and effective_date between ppf.effective_start_date and ppf.effective_end_date
   and effective_date between paf.effective_start_date and paf.effective_end_date
   and paf.primary_flag        = 'Y'
   and paf.assignment_type     <> 'B'
   and ppf.person_type_id      = ppt.person_type_id
   and ppt.system_person_type  IN ('EMP','EMP_APL')
   and paf.organization_id     = p_org_id
   and paf.position_id is not null
   order by ppf.person_id;

---
--- Bug  3539816 Order by added to prevent snapshot old error
--- 2. Cursor with no organization.
---
cursor cur_people (effective_date date, p_org_id number) is
select ppf.person_id                 PERSON_ID,
       ppf.first_name                FIRST_NAME,
       ppf.last_name                 LAST_NAME,
       ppf.middle_names              MIDDLE_NAMES,
       ppf.full_name                 FULL_NAME,
       ppf.date_of_birth             DATE_OF_BIRTH,
       ppf.national_identifier       NATIONAL_IDENTIFIER,
       paf.position_id               POSITION_ID,
       paf.assignment_id             ASSIGNMENT_ID,
       paf.grade_id                  GRADE_ID,
       paf.job_id                    JOB_ID,
       paf.location_id               LOCATION_ID,
       paf.organization_id           ORGANIZATION_ID,
       paf.business_group_id         BUSINESS_GROUP_ID,
       paf.assignment_status_type_id ASSIGNMENT_STATUS_TYPE_ID
  from per_assignments_f   paf,
       per_people_f        ppf,
       per_person_types    ppt
 where ppf.person_id           = paf.person_id
   and effective_date between ppf.effective_start_date and ppf.effective_end_date
   and effective_date between paf.effective_start_date and paf.effective_end_date
   and paf.primary_flag        = 'Y'
   and paf.assignment_type     <> 'B'
   and ppf.person_type_id      = ppt.person_type_id
   and ppt.system_person_type  IN ('EMP','EMP_APL')
   and paf.position_id is not null
   order by ppf.person_id;
--
-- Check assignment_status_type
--

cursor cur_ast (asg_status_type_id number) is
select user_status from per_assignment_status_types
where assignment_status_type_id = asg_status_type_id
  and upper(user_status) not in (
                         'TERMINATE ASSIGNMENT',           /* 3 */
                         'ACTIVE APPLICATION',             /* 4 */
                         'OFFER',                          /* 5 */
                         'ACCEPTED',                       /* 6 */
                         'TERMINATE APPLICATION',          /* 7 */
                         'END',                            /* 8 */
                         'TERMINATE APPOINTMENT',          /* 126 */
                         'SEPARATED');                     /* 132 */

--
-- Cursor to select from GHR_MASS_SALARIES - Where criteria is stored
-- Before executing this package
-- from ghr_mass_salary_criteria

cursor ghr_msl (p_msl_id number) is
select name, effective_date, mass_salary_id, user_table_id, submit_flag,
       executive_order_number, executive_order_date, ROWID, PA_REQUEST_ID,
       ORGANIZATION_ID, DUTY_STATION_ID, PERSONNEL_OFFICE_ID,
       AGENCY_CODE_SUBELEMENT, OPM_ISSUANCE_NUMBER, OPM_ISSUANCE_DATE, PROCESS_TYPE,
       locality_pay_area_code
  from ghr_mass_salaries
 where MASS_SALARY_ID = p_msl_id
   for update of user_table_id nowait;

---Fetch Noa_family_code ---800 (CHG_DATA_ELEMENT) , 894 (GHR_SAL_PAY_ADJ)

cursor get_sal_chg_fam (cnoacode varchar2) is
select NOA_FAMILY_CODE
from ghr_families
where NOA_FAMILY_CODE in
    (select NOA_FAMILY_CODE from ghr_noa_families
         where  nature_of_action_id in
            (select nature_of_action_id
             from ghr_nature_of_actions
             where code = cnoacode)
    ) and proc_method_flag = 'Y';


cursor unassigned_pos (p_org_pos_id       NUMBER,
                       effective_DATE DATE) is
       SELECT   null PERSON_ID,
               'VACANT' FIRST_NAME,
               'VACANT' LAST_NAME,
               'VACANT' FULL_NAME,
               null     MIDDLE_NAMES,
               null     DATE_OF_BIRTH,
               null     NATIONAL_IDENTIFIER,
               position_id POSITION_ID,
               null     ASSIGNMENT_ID,
               to_NUMBER(null)     GRADE_ID,
               JOB_ID,
               pop.LOCATION_ID,
               pop.ORGANIZATION_ID,
               pop.BUSINESS_GROUP_ID,
               punits.name        ORGANIZATION_NAME,
               pop.availability_status_id
        from   hr_positions_f     pop,
               per_organization_units punits
      WHERE  trunc(effective_DATE) between pop.effective_start_DATE and pop.effective_END_DATE
        and  pop.organization_id = punits.organization_id
        and  pop.organization_id = nvl(p_org_pos_id,pop.organization_id)
        and   not exists
        (
         SELECT 'X'
         FROM   per_people_f p, per_assignments_f a
         WHERE  trunc(effective_DATE) between a.effective_start_DATE and a.effective_END_DATE
           AND    a.primary_flag          = 'Y'
           AND    a.assignment_type      <> 'B'
           AND    p.current_employee_flag = 'Y'
           AND    a.business_group_id = pop.business_group_id
           AND    a.person_id         = p.person_id
           AND    a.position_id           = pop.position_id
           AND    trunc(effective_DATE) between p.effective_start_DATE and p.effective_end_DATE
        );

----Bug 4699955
cursor c_pos_name (p_position_id       NUMBER)
is
select name from hr_positions_f
where position_id = p_position_id;

l_pos_name  hr_positions_f.name%type;
----Bug 4699955

l_assignment_id        per_assignments_f.assignment_id%type;
l_position_id          per_assignments_f.position_id%type;
l_grade_id             per_assignments_f.grade_id%type;
l_business_group_id    per_assignments_f.business_group_id%type;

l_position_title       varchar2(300);
l_position_number      varchar2(20);
l_position_seq_no      varchar2(20);

l_msl_cnt              number := 0;
l_recs_failed          number := 0;

l_tenure               varchar2(35);
l_annuitant_indicator  varchar2(35);
l_pay_rate_determinant varchar2(35);
l_work_schedule        varchar2(35);
l_part_time_hour       varchar2(35);
l_pay_table_id         number;
l_pay_plan             varchar2(30);
l_grade_or_level       varchar2(30);
l_step_or_rate         varchar2(30);
l_pay_basis            varchar2(30);
l_location_id          number;
l_duty_station_id      number;
l_duty_station_desc    ghr_pa_requests.duty_station_desc%type;
l_duty_station_code    ghr_pa_requests.duty_station_code%type;
l_effective_date       date;
l_personnel_office_id  varchar2(300);
l_org_structure_id     varchar2(300);
l_sub_element_code     varchar2(300);

l_old_basic_pay        number;
l_old_avail_pay        number;
l_old_loc_diff         number;
l_tot_old_sal          number;
l_old_auo_pay          number;
l_old_ADJ_basic_pay    number;
l_other_pay            number;


l_auo_premium_pay_indicator     varchar2(30);
l_ap_premium_pay_indicator      varchar2(30);
l_retention_allowance           number;
l_retention_allow_perc          number;
l_new_retention_allowance       number;
l_supervisory_differential      number;
l_supervisory_diff_perc         number;
l_new_supervisory_differential  number;
l_staffing_differential         number;

l_new_avail_pay             number;
l_new_loc_diff              number;
l_tot_new_sal               number;
l_new_auo_pay               number;

l_new_basic_pay             number;
l_new_locality_adj          number;
l_new_adj_basic_pay         number;
l_new_total_salary          number;
l_new_other_pay_amount      number;
l_new_au_overtime           number;
l_new_availability_pay      number;
l_out_step_or_rate          varchar2(30);
l_out_pay_rate_determinant  varchar2(30);
l_open_pay_fields           boolean;
l_message_set               boolean;
l_calculated                boolean;

l_mass_salary_id            number;
l_user_table_id             number;
l_submit_flag               varchar2(2);
l_executive_order_number    ghr_mass_salaries.executive_order_number%TYPE;
l_executive_order_date      ghr_mass_salaries.executive_order_date%TYPE;
l_opm_issuance_number       ghr_mass_salaries.opm_issuance_number%TYPE;
l_opm_issuance_date         ghr_mass_salaries.opm_issuance_date%TYPE;
l_pa_request_id             number;
l_rowid                     varchar2(30);

l_p_ORGANIZATION_ID           number;
l_p_DUTY_STATION_ID           number;
l_p_PERSONNEL_OFFICE_ID       varchar2(5);

L_row_cnt                   number := 0;

l_sf52_rec                  ghr_pa_requests%rowtype;
l_lac_sf52_rec              ghr_pa_requests%rowtype;
l_errbuf                    varchar2(2000);

l_retcode                   number;

l_pos_ei_data               per_position_extra_info%rowtype;
l_pos_grp1_rec              per_position_extra_info%rowtype;

l_pay_calc_in_data          ghr_pay_calc.pay_calc_in_rec_type;
l_pay_calc_out_data         ghr_pay_calc.pay_calc_out_rec_type;
l_sel_flg                   varchar2(2);

l_first_action_la_code1     varchar2(30);
l_first_action_la_code2     varchar2(30);

l_remark_code1              varchar2(30);
l_remark_code2              varchar2(30);
l_p_AGENCY_CODE_SUBELEMENT       varchar2(30);
l_p_locality_area_code     ghr_mass_salaries.locality_pay_area_code%type;

----Pay cap variables
l_entitled_other_pay        NUMBER;
l_capped_other_pay          NUMBER;
l_adj_basic_message         BOOLEAN  := FALSE;
l_pay_cap_message           BOOLEAN  := FALSE;
l_temp_retention_allowance  NUMBER;
l_open_pay_fields_caps      BOOLEAN;
l_message_set_caps          BOOLEAN;
l_total_pay_check           VARCHAR2(1);
l_comment                   VARCHAR2(150);
l_comment_sal               VARCHAR2(150);
l_pay_sel                   VARCHAR2(1) := NULL;
l_old_capped_other_pay      NUMBER;
----
l_row_low NUMBER;
l_row_high NUMBER;
l_comment_range VARCHAR2(150);
l_comments      VARCHAR2(150);

REC_BUSY                    exception;
pragma exception_init(REC_BUSY,-54);

l_proc  varchar2(72) :=  g_package || '.execute_msl_pay';

l_org_name	hr_organization_units.name%type;
----FWFA Changes
l_0000_id                  number;
l_0491_id                  number;
l_to_pay_table_id          number;
l_pos_valid_grade_ei_data  per_position_extra_info%rowtype;
l_mtcerrbuf                varchar2(2000);
l_avail_status_id          number;
l_occ_series               varchar2(30);
l_pt_value                 number;
l_pp_grd_exists            boolean;
l_dummy                    varchar2(1);
l_pt_eff_start_date        date;
l_pt_eff_end_date          date;
l_position_data_rec        ghr_sf52_pos_UPDATE.position_data_rec_type;

--
-- Bug 3315432 Madhuri
--
CURSOR cur_pp_prd_per_gr(p_msl_id ghr_mass_salary_criteria.mass_salary_id%type)
IS
SELECT criteria.pay_plan pay_plan,
       criteria.pay_rate_determinant prd,
       ext.grade grade
FROM   ghr_mass_salary_criteria criteria, ghr_mass_salary_criteria_ext ext
WHERE  criteria.mass_salary_id=p_msl_id
AND    criteria.mass_salary_criteria_id=ext.mass_salary_criteria_id(+);

TYPE pay_plan_prd_per_gr IS RECORD
(
pay_plan	ghr_mass_salary_criteria.pay_plan%type,
prd		ghr_mass_salary_criteria.pay_rate_determinant%type,
grade		ghr_mass_salary_criteria_ext.grade%type
);

TYPE pp_prd_per_gr IS TABLE OF pay_plan_prd_per_gr INDEX BY BINARY_INTEGER;
rec_pp_prd_per_gr pp_prd_per_gr;

l_index         NUMBER:=1;
l_cnt           NUMBER;
l_count         NUMBER;
--
--

cursor c_locality (effective_date date,l_loc_id number,l_loc_code varchar2) is
select 1
from   hr_location_extra_info hlei,
       ghr_duty_stations_f    gdsf,
       ghr_locality_pay_areas_f glpa
where  hlei.location_id = l_loc_id
  and  hlei.information_type = 'GHR_US_LOC_INFORMATION'
  and  hlei.lei_information3 = gdsf.duty_station_id
  and  gdsf.locality_pay_area_id = glpa.locality_pay_area_id
  and  effective_date between gdsf.effective_start_date and gdsf.effective_end_date
  and  effective_date between glpa.effective_start_date and glpa.effective_end_date
  and  glpa.locality_pay_area_code = l_loc_code;

l_locality_check BOOLEAN;

cursor c_grade_kff (grd_id NUMBER) is
        SELECT gdf.segment1
              ,gdf.segment2
        from per_grades grd, per_grade_definitions gdf
        WHERE grd.grade_id = grd_id
        and grd.grade_definition_id = gdf.grade_definition_id;

cursor c_pay_table_id (pay_table varchar2) is
  select user_table_id from pay_user_tables
  where substr(user_table_name,1,4) = pay_table;



PROCEDURE msl_pay_process(p_assignment_id  per_assignments_f.assignment_id%TYPE
			 ,p_person_id per_assignments_f.person_id%TYPE
			 ,p_position_id  per_assignments_f.position_id%TYPE
			 ,p_grade_id per_assignments_f.grade_id%TYPE
			 ,p_business_group_id per_assignments_f.business_group_iD%TYPE
			 ,p_location_id per_assignments_f.location_id%TYPE
			 ,p_organization_id per_assignments_f.organization_id%TYPE
			 ,p_date_of_birth date
			 ,p_first_name per_people_f.first_name%TYPE
			 ,p_last_name per_people_f.last_name%TYPE
          ,p_full_name per_people_f.full_name%TYPE
          ,p_middle_names per_people_f.middle_names%TYPE
			 ,p_national_identifier per_people_f.national_identifier%TYPE
               ) IS

BEGIN
      savepoint execute_msl_pay_sp;
         l_msl_cnt := l_msl_cnt +1;
         l_count   := 0;
         --Bug#3968005 Initialised l_sel_flg
         l_sel_flg := NULL;
         l_pay_calc_in_data  := NULL;
         l_pay_calc_out_data := NULL;


         l_assignment_id     := p_assignment_id;
         l_position_id       := p_position_id;
         l_grade_id          := p_grade_id;
         l_business_group_id := p_business_group_iD;
         l_location_id       := p_location_id;

	 hr_utility.set_location('The location id is:'||l_location_id,12345);
         begin
            ghr_pa_requests_pkg.get_SF52_loc_ddf_details
              (p_location_id      => l_location_id
              ,p_duty_station_id  => l_duty_station_id);
         exception
         when others then
             hr_utility.set_location(
             'Error in Ghr_pa_requests_pkg.get_sf52_loc_ddf_details'||
                   'Err is '||sqlerrm(sqlcode),20);
             l_mtcerrbuf := 'Error in get_sf52_loc_ddf_details '||
                   'Sql Err is '|| sqlerrm(sqlcode);
             raise mtc_error;
         end;

	      l_org_name :=GHR_MRE_PKG.GET_ORGANIZATION_NAME(p_ORGANIZATION_ID);

         get_pos_grp1_ddf(l_position_id,
                        l_effective_date,
                        l_pos_grp1_rec);

         l_personnel_office_id :=  l_pos_grp1_rec.poei_information3;
         l_org_structure_id    :=  l_pos_grp1_rec.poei_information5;

         get_sub_element_code_pos_title(l_position_id,
                                     null,
                                     l_business_group_id,
                                     l_assignment_id,
                                     l_effective_date,
                                     l_sub_element_code,
                                     l_position_title,
                                     l_position_number,
                                     l_position_seq_no);

	hr_utility.set_location('The duty station id is:'||l_duty_station_id,12345);
   -- Check Locality Area Code

         l_locality_check := FALSE;

         IF l_p_locality_area_code is null then
              l_locality_check := TRUE;
         ELSE
            FOR c_locality_rec IN c_locality (l_effective_date,l_location_id,l_p_locality_area_code)
            LOOP
                l_locality_check := TRUE;
                exit;
            END LOOP;
         END IF;

   --1 Check Duty station code,POI,agnecy and subelement.

         IF l_locality_check and check_init_eligibility(l_p_duty_station_id,
                              l_p_PERSONNEL_OFFICE_ID,
                              l_p_AGENCY_CODE_SUBELEMENT,
                              l_duty_station_id,
                              l_personnel_office_id,
                              l_sub_element_code) then

   hr_utility.set_location('check_init_eligibility    ' || l_proc,6);
   -- Get PRD, work schedule etc form ASG EI

			begin
				ghr_pa_requests_pkg.get_sf52_asg_ddf_details
						  (l_assignment_id,
						   l_effective_date,
						   l_tenure,
						   l_annuitant_indicator,
						   l_pay_rate_determinant,
						   l_work_schedule,
						   l_part_time_hour);
			exception
				when others then
					hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details'||
							  'Err is '||sqlerrm(sqlcode),20);
					l_mtcerrbuf := 'Error in get_sf52_asgddf_details Sql Err is '|| sqlerrm(sqlcode);
					raise mtc_error;
			end;

   -- Check PRD,pay plan,table id   Loop start
      FOR l_cnt in 1..rec_pp_prd_per_gr.COUNT LOOP

   --2 PRD Check
		IF nvl(rec_pp_prd_per_gr(l_cnt).prd,'ALL') = 'ALL' OR
		   nvl(rec_pp_prd_per_gr(l_cnt).prd,l_pay_rate_determinant) = l_pay_rate_determinant THEN
		-- Get Pay table ID and other details
           BEGIN
		       ghr_msl_pkg.get_pay_plan_and_table_id(l_pay_rate_determinant,p_person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_assignment_id,'SHOW',l_pay_plan,
                           l_pay_table_id,l_grade_or_level, l_step_or_rate,
                           l_pay_basis);
           EXCEPTION
               when mtc_error then
                 l_mtcerrbuf := hr_utility.get_message;
                 raise;
           END;

    --3 Pay plan and tableid check
		     IF ( nvl(rec_pp_prd_per_gr(l_cnt).pay_plan,l_pay_plan) = l_pay_plan
                        AND l_user_table_id = nvl(l_pay_table_id,hr_api.g_number)
                        AND nvl(rec_pp_prd_per_gr(l_cnt).grade,l_grade_or_level)=l_grade_or_level) THEN

			IF check_eligibility_mtc(
                               l_pay_plan,
                               p_person_id,
                               l_effective_date,
                               p_action) THEN

   hr_utility.set_location('check_eligibility    ' || l_proc,8);

			  IF upper(p_action) = 'REPORT' AND l_submit_flag = 'P' THEN
 			    pop_dtls_from_pa_req(p_person_id,l_effective_date,l_mass_salary_id,l_org_name);
			  ELSE
			   if check_select_flg(p_person_id
                               ,upper(p_action)
						             ,l_effective_date
                               ,p_mass_salary_id
                               ,l_sel_flg
						             ) then

    hr_utility.set_location('check_select_flg    ' || l_proc,7);
    hr_utility.set_location('The duty station name is:'||l_duty_station_code,12345);
	 hr_utility.set_location('The duty station desc is:'||l_duty_station_desc,12345);

           begin
			     ghr_pa_requests_pkg.get_duty_station_details
                       (p_duty_station_id        => l_duty_station_id
                       ,p_effective_date        => l_effective_date
                       ,p_duty_station_code        => l_duty_station_code
                       ,p_duty_station_desc        => l_duty_station_desc);
           exception
                     when others then
                        hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_duty_station_details'||
                               'Err is '||sqlerrm(sqlcode),20);
                    l_mtcerrbuf := 'Error in get_duty_station_details Sql Err is '|| sqlerrm(sqlcode);
                    raise mtc_error;
           end;

---Replace the following procedure with LACs and remarks since it is straight forward.

                     get_other_dtls_for_rep(l_pay_rate_determinant,
                                     l_executive_order_number,
                                     to_char(l_executive_order_date),
                                     l_first_action_la_code1,
                                     l_first_action_la_code2,
                                     l_remark_code1,
                                     l_remark_code2);

                     get_from_sf52_data_elements
                            (l_assignment_id,  l_effective_date,
                             l_old_basic_pay, l_old_avail_pay,
                             l_old_loc_diff, l_tot_old_sal,
                             l_old_auo_pay, l_old_adj_basic_pay,
                             l_other_pay, l_auo_premium_pay_indicator,
                             l_ap_premium_pay_indicator,
                             l_retention_allowance,
                             l_retention_allow_perc,
                             l_supervisory_differential,
                             l_supervisory_diff_perc,
                             l_staffing_differential);

  for get_sal_chg_fam_rec IN get_sal_chg_fam('894')
  loop
     l_pay_calc_in_data.noa_family_code := get_sal_chg_fam_rec.noa_family_code;
     exit;
  end loop;

------  open get_sal_chg_fam;
------  fetch get_sal_chg_fam into l_pay_calc_in_data.noa_family_code;
------  close get_sal_chg_fam;

  l_pay_calc_in_data.person_id                := p_person_id;
  l_pay_calc_in_data.position_id              := l_position_id;
  l_pay_calc_in_data.noa_code                 := '894';
  l_pay_calc_in_data.second_noa_code          := null;
  l_pay_calc_in_data.first_action_la_code1    := l_lac_sf52_rec.first_action_la_code1;
  l_pay_calc_in_data.effective_date           := l_effective_date;
  l_pay_calc_in_data.pay_rate_determinant     := l_pay_rate_determinant;
  l_pay_calc_in_data.pay_plan                 := l_pay_plan;
  l_pay_calc_in_data.grade_or_level           := l_grade_or_level;
  l_pay_calc_in_data.step_or_rate             := l_step_or_rate;
  l_pay_calc_in_data.pay_basis                := l_pay_basis;
  l_pay_calc_in_data.user_table_id            := l_pay_table_id;
  l_pay_calc_in_data.duty_station_id          := l_duty_station_id;
  l_pay_calc_in_data.auo_premium_pay_indicator := l_auo_premium_pay_indicator;
  l_pay_calc_in_data.ap_premium_pay_indicator  := l_ap_premium_pay_indicator;
  l_pay_calc_in_data.retention_allowance       := l_retention_allowance;
  l_pay_calc_in_data.to_ret_allow_percentage   := l_retention_allow_perc;
  l_pay_calc_in_data.supervisory_differential  := l_supervisory_differential;
  l_pay_calc_in_data.staffing_differential    := l_staffing_differential;
  l_pay_calc_in_data.current_basic_pay        := l_old_basic_pay;
  l_pay_calc_in_data.current_adj_basic_pay    := l_old_adj_basic_pay;
  l_pay_calc_in_data.current_step_or_rate     := l_step_or_rate;
  l_pay_calc_in_data.pa_request_id            := null;

     get_extra_info_comments(p_person_id,l_effective_date,l_pay_sel,
                             l_comments,p_mass_salary_id);
     l_comments := NULL;

              begin
                  ghr_pay_calc.sql_main_pay_calc (l_pay_calc_in_data
                       ,l_pay_calc_out_data
                       ,l_message_set
                       ,l_calculated);

					IF l_message_set THEN
						hr_utility.set_location( l_proc, 40);
						l_calculated     := FALSE;
						l_mtcerrbuf  := hr_utility.get_message;
			--			raise mtc_error;
					END IF;
              exception
                  when mtc_error then
                       g_proc := 'ghr_pay_calc';
                      raise;
                  when others then
                ----BUG 3287299 Start
                IF ghr_pay_calc.gm_unadjusted_pay_flg = 'Y' then
                  l_comment := 'MSL:Error: Unadjusted Basic Pay must be entered in Employee record.';
                ELSE
                  l_comment := 'MSL:Error: See process log for details.';
                END IF;

                IF upper(p_action) IN ('SHOW') THEN
                      -- Bug#2383392
                   create_mass_act_prev_mtc (
			              p_effective_date          => l_effective_date,
			              p_date_of_birth           => p_date_of_birth,
			              p_full_name               => p_full_name,
			              p_national_identifier     => p_national_identifier,
			              p_duty_station_code       => l_duty_station_code,
			              p_duty_station_desc       => l_duty_station_desc,
			              p_personnel_office_id     => l_personnel_office_id,
			              p_basic_pay               => l_old_basic_pay,
			              p_new_basic_pay           => null,
			              p_adj_basic_pay           => l_old_adj_basic_pay,
			              p_new_adj_basic_pay       => null,
			              p_old_avail_pay           => l_old_avail_pay,
			              p_new_avail_pay           => null,
			              p_old_loc_diff            => l_old_loc_diff,
			              p_new_loc_diff            => null,
			              p_tot_old_sal             => l_tot_old_sal,
			              p_tot_new_sal             => null,
			              p_old_auo_pay             => l_old_auo_pay,
			              p_new_auo_pay             => null,
			              p_position_id             => l_position_id,
			              p_position_title          => l_position_title,
                             -- FWFA Changes Bug#4444609
                             p_position_number         => l_position_number,
                             p_position_seq_no         => l_position_seq_no,
                             -- FWFA Changes
			              p_org_structure_id        => l_org_structure_id,
	              		  p_agency_sub_element_code => l_sub_element_code,
			              p_person_id               => p_person_id,
			              p_mass_salary_id          => l_mass_salary_id,
			              p_sel_flg                 => l_sel_flg,
			              p_first_action_la_code1   => l_first_action_la_code1,
			              p_first_action_la_code2   => l_first_action_la_code2,
			              p_remark_code1            => l_remark_code1,
			              p_remark_code2            => l_remark_code2,
			              p_grade_or_level          => l_grade_or_level,
			              p_step_or_rate            => l_step_or_rate,
			              p_pay_plan                => l_pay_plan,
			              p_pay_rate_determinant    => null,
			              p_tenure                  => l_tenure,
			              p_action                  => p_action,
			              p_assignment_id           => l_assignment_id,
			              p_old_other_pay           => l_other_pay,
			              p_new_other_pay           => null,
			              p_old_capped_other_pay    => NULL,
			              p_new_capped_other_pay    => NULL,
			              p_old_retention_allowance => l_retention_allowance,
			              p_new_retention_allowance => NULL,
			              p_old_supervisory_differential => l_supervisory_differential,
			              p_new_supervisory_differential => NULL,
			              p_organization_name            => l_org_name,
                          -- FWFA Changes Bug#4444609
                          p_input_pay_rate_determinant  =>  l_pay_rate_determinant,
                          p_from_pay_table_id         => l_user_table_id,
                          p_to_pay_table_id           =>  null
  		                );
                      END IF;
                      l_comments := substr(l_comments || ' ' || l_comment , 1,150);
                      ins_upd_per_extra_info
                         (p_person_id,l_effective_date, l_sel_flg, l_comments,p_mass_salary_id);
                      l_comment := NULL;
                      ------  BUG 3287299 End
                      hr_utility.set_location('Error in Ghr_pay_calc.sql_main_pay_calc '||
                                'Err is '||sqlerrm(sqlcode),20);
                    l_mtcerrbuf := 'Error in ghr_pay_calc  Sql Err is '|| sqlerrm(sqlcode);
                    g_proc := 'ghr_pay_calc';
                    raise mtc_error;
              end;

        l_new_basic_pay                 := l_pay_calc_out_data.basic_pay;
        l_new_locality_adj              := l_pay_calc_out_data.locality_adj;
        l_new_adj_basic_pay             := l_pay_calc_out_data.adj_basic_pay;
        l_new_au_overtime               := l_pay_calc_out_data.au_overtime;
        l_new_availability_pay          := l_pay_calc_out_data.availability_pay;
        l_out_pay_rate_determinant      := l_pay_calc_out_data.out_pay_rate_determinant;
        l_out_step_or_rate              := l_pay_calc_out_data.out_step_or_rate;
        l_new_retention_allowance       := l_pay_calc_out_data.retention_allowance;
        l_new_supervisory_differential  := l_supervisory_differential;
        l_new_other_pay_amount          := l_pay_calc_out_data.other_pay_amount;
        l_entitled_other_pay            := l_new_other_pay_amount;

        if l_new_other_pay_amount = 0 then
           l_new_other_pay_amount := null;
        end if;
        l_new_total_salary        := l_pay_calc_out_data.total_salary;

     hr_utility.set_location('retention_allowance = ' || to_char(l_retention_allowance),10);
     hr_utility.set_location('Supervisory Diff Amount = ' || to_char(l_supervisory_differential),10);


-------------Call Pay cap Procedure
     begin
      l_capped_other_pay := ghr_pa_requests_pkg2.get_cop( p_assignment_id  => l_assignment_id
                                                         ,p_effective_date => l_effective_date);
      l_old_capped_other_pay :=  l_capped_other_pay;
		-- Sundar Added the following if statement to improve performance
			if hr_utility.debug_enabled = true then
				  hr_utility.set_location('Before Pay Cap    ' || l_proc,21);
				  hr_utility.set_location('l_effective_date  ' || l_effective_date,21);
				  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,21);
				  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,21);
				  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),21);
				  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,21);
				  hr_utility.set_location('person_id  ' || to_char(p_person_id),21);
				  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),21);
				  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),21);
				  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),21);
				  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),21);
				  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),21);
				  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),21);
				  hr_utility.set_location('l_new_retention_allowance  ' || to_char(l_new_retention_allowance),21);
				  hr_utility.set_location('l_new_supervisory_diff ' || to_char(l_new_supervisory_differential),21);
				  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),21);
				  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),21);
				  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),21);
			end if;


      ghr_pay_caps.do_pay_caps_main
                   (p_pa_request_id        =>    null
                   ,p_effective_date       =>    l_effective_date
                   ,p_pay_rate_determinant =>    nvl(l_out_pay_rate_determinant,l_pay_rate_determinant)
                   ,p_pay_plan             =>    l_pay_plan
                   ,p_to_position_id       =>    l_position_id
                   ,p_pay_basis            =>    l_pay_basis
                   ,p_person_id            =>    p_person_id
                   ,p_noa_code             =>    '894'
                   ,p_basic_pay            =>    l_new_basic_pay
                   ,p_locality_adj         =>    l_new_locality_adj
                   ,p_adj_basic_pay        =>    l_new_adj_basic_pay
                   ,p_total_salary         =>    l_new_total_salary
                   ,p_other_pay_amount     =>    l_entitled_other_pay
                   ,p_capped_other_pay     =>    l_capped_other_pay
                   ,p_retention_allowance  =>    l_new_retention_allowance
                   ,p_retention_allow_percentage => l_retention_allow_perc
                   ,p_supervisory_allowance =>   l_new_supervisory_differential
                   ,p_staffing_differential =>   l_staffing_differential
                   ,p_au_overtime          =>    l_new_au_overtime
                   ,p_availability_pay     =>    l_new_availability_pay
                   ,p_adj_basic_message    =>    l_adj_basic_message
                   ,p_pay_cap_message      =>    l_pay_cap_message
                   ,p_pay_cap_adj          =>    l_temp_retention_allowance
                   ,p_open_pay_fields      =>    l_open_pay_fields_caps
                   ,p_message_set          =>    l_message_set_caps
                   ,p_total_pay_check      =>    l_total_pay_check);


             l_new_other_pay_amount := nvl(l_capped_other_pay,l_entitled_other_pay);

			-- Sundar Added the following statement to improve performance
			if hr_utility.debug_enabled = true then
				  hr_utility.set_location('After Pay Cap    ' || l_proc,22);
				  hr_utility.set_location('l_effective_date  ' || l_effective_date,22);
				  hr_utility.set_location('l_out_pay_rate_determinant  ' || l_out_pay_rate_determinant,22);
				  hr_utility.set_location('l_pay_plan  ' || l_pay_plan,22);
				  hr_utility.set_location('l_position_id  ' || to_char(l_position_id),22);
				  hr_utility.set_location('l_pay_basis  ' || l_pay_basis,22);
				  hr_utility.set_location('person_id  ' || to_char(p_person_id),22);
				  hr_utility.set_location('l_new_basic_pay  ' || to_char(l_new_basic_pay),22);
				  hr_utility.set_location('l_new_locality_adj  ' || to_char(l_new_locality_adj),22);
				  hr_utility.set_location('l_new_adj_basic_pay  ' || to_char(l_new_adj_basic_pay),22);
				  hr_utility.set_location('l_new_total_salary  ' || to_char(l_new_total_salary),22);
				  hr_utility.set_location('l_entitled_other_pay  ' || to_char(l_entitled_other_pay),22);
				  hr_utility.set_location('l_capped_other_pay  ' || to_char(l_capped_other_pay),22);
				  hr_utility.set_location('l_new_retention_allowance  ' || to_char(l_new_retention_allowance),22);
				  hr_utility.set_location('l_new_supervisory_diff ' || to_char(l_new_supervisory_differential),22);
				  hr_utility.set_location('l_staffing_differential  ' || to_char(l_staffing_differential),22);
				  hr_utility.set_location('l_new_au_overtime  ' || to_char(l_new_au_overtime),22);
				  hr_utility.set_location('l_new_availability_pay  ' || to_char(l_new_availability_pay),22);
			end if;

       IF l_pay_cap_message THEN
			IF nvl(l_temp_retention_allowance,0) > 0 THEN
			  l_comment := 'MSL: Exceeded Total Cap - reduce Retention Allow to '
										|| to_char(l_temp_retention_allowance);
			  l_sel_flg := 'N';
			ELSE
			  l_comment := 'MSL: Exceeded Total cap - pls review.';
			END IF;
       ELSIF l_adj_basic_message THEN
          l_comment := 'MSL: Exceeded Adjusted Pay Cap - Locality reduced.';
       END IF;

       IF l_pay_cap_message or l_adj_basic_message THEN
			-- Bug 2639698
		  IF (l_comment_sal IS NOT NULL) THEN
		     l_comment := l_comment_sal || ' ' || l_comment;
		  END IF;
		  -- End Bug 2639698
          l_comments := substr(l_comments || ' ' || l_comment, 1,150);
          ins_upd_per_extra_info
               (p_person_id,l_effective_date, l_sel_flg, l_comments,p_mass_salary_id);
          l_comment := NULL;
       --------------------Bug 2639698 Sundar To add comments
	   -- Should create comments only if comments need to be inserted
	    ELSIF l_comment_sal IS NOT NULL THEN
          l_comments := substr(l_comments || ' ' || l_comment_sal, 1,150);
		  ins_upd_per_extra_info
               (p_person_id,l_effective_date, l_sel_flg, l_comments,p_mass_salary_id);
	   END IF;

       l_comment_sal := NULL; -- bug 2639698
     exception
          when mtc_error then
               raise;
          when others then
               hr_utility.set_location('Error in ghr_pay_caps.do_pay_caps_main ' ||
                                'Err is '||sqlerrm(sqlcode),23);
                    l_mtcerrbuf := 'Error in do_pay_caps_main  Sql Err is '|| sqlerrm(sqlcode);
                    raise mtc_error;
     end;


                IF upper(p_action) IN ('SHOW','REPORT') THEN
                    create_mass_act_prev_mtc (
                        p_effective_date               => l_effective_date,
                        p_date_of_birth                => p_date_of_birth,
                        p_full_name                    => p_full_name,
                        p_national_identifier          => p_national_identifier,
                        p_duty_station_code            => l_duty_station_code,
                        p_duty_station_desc            => l_duty_station_desc,
                        p_personnel_office_id          => l_personnel_office_id,
                        p_basic_pay                    => l_old_basic_pay,
                        p_new_basic_pay                => l_new_basic_pay,
                        p_adj_basic_pay                => l_old_adj_basic_pay,
                        p_new_adj_basic_pay            => l_new_adj_basic_pay,
                        p_old_avail_pay                => l_old_avail_pay,
                        p_new_avail_pay                => l_new_availability_pay,
                        p_old_loc_diff                 => l_old_loc_diff,
                        p_new_loc_diff                 => l_new_locality_adj,
                        p_tot_old_sal                  => l_tot_old_sal,
                        p_tot_new_sal                  => l_new_total_salary,
                        p_old_auo_pay                  => l_old_auo_pay,
                        p_new_auo_pay                  => l_new_au_overtime,
                        p_position_id                  => l_position_id,
                        p_position_title               => l_position_title,
                         -- FWFA Changes Bug#4444609
                         p_position_number         => l_position_number,
                         p_position_seq_no         => l_position_seq_no,
                         -- FWFA Changes
                        p_org_structure_id             => l_org_structure_id,
                        p_agency_sub_element_code      => l_sub_element_code,
                        p_person_id                    => p_person_id,
                        p_mass_salary_id               => l_mass_salary_id,
                        p_sel_flg                      => l_sel_flg,
                        p_first_action_la_code1        => l_first_action_la_code1,
                        p_first_action_la_code2        => l_first_action_la_code2,
                        p_remark_code1                 => l_remark_code1,
                        p_remark_code2                 => l_remark_code2,
                        p_grade_or_level               => l_grade_or_level,
                        p_step_or_rate                 => l_step_or_rate,
                        p_pay_plan                     => l_pay_plan,
                        -- FWFA Changes Bug#4444609 Added NVL condition
                        p_pay_rate_determinant         => NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                        -- FWFA Changes
                        p_tenure                       => l_tenure,
                        p_action                       => p_action,
                        p_assignment_id                => l_assignment_id,
                        p_old_other_pay                => l_other_pay,
                        p_new_other_pay                => l_new_other_pay_amount,
                        p_old_capped_other_pay         => l_old_capped_other_pay,
                        p_new_capped_other_pay         => l_capped_other_pay,
                        p_old_retention_allowance      => l_retention_allowance,
                        p_new_retention_allowance      => l_new_retention_allowance,
                        p_old_supervisory_differential => l_supervisory_differential,
                        p_new_supervisory_differential => l_new_supervisory_differential,
                        p_organization_name            => l_org_name,
                        -- FWFA Changes Bug#4444609
                        p_input_pay_rate_determinant   => l_pay_rate_determinant,
                        p_from_pay_table_id            => l_pay_calc_out_data.pay_table_id,
                        p_to_pay_table_id              => l_pay_calc_out_data.calculation_pay_table_id
                        -- FWFA Changes
                         );


                ELSIF upper(p_action) = 'CREATE' then
                    BEGIN
                       ghr_msl_pkg.get_pay_plan_and_table_id
                          (l_pay_rate_determinant,p_person_id,
                           l_position_id,l_effective_date,
                           l_grade_id, l_assignment_id,'CREATE',
                           l_pay_plan,l_pay_table_id,
                           l_grade_or_level, l_step_or_rate,
                           l_pay_basis);
                    EXCEPTION
                    when mtc_error then
                      l_mtcerrbuf := hr_utility.get_message;
                      raise;
                    END;
                    assign_to_sf52_rec(
                       p_person_id,
                       p_first_name,
                       p_last_name,
                       p_middle_names,
                       p_national_identifier,
                       p_date_of_birth,
                       l_effective_date,
                       l_assignment_id,
                       l_tenure,
                       l_step_or_rate,
                       l_annuitant_indicator,
                       -- FWFA Changes Bug#4444609
                       NVL(l_out_pay_rate_determinant,l_pay_rate_determinant),
                       -- FWFA Changes
                       l_work_schedule,
                       l_part_time_hour,
                       l_pos_ei_data.poei_information7, --FLSA Category
                       l_pos_ei_data.poei_information8, --Bargaining Unit Status
                       l_pos_ei_data.poei_information11,--Functional Class
                       l_pos_ei_data.poei_information16,--Supervisory Status,
                       l_new_basic_pay,
                       l_new_locality_adj,
                       l_new_adj_basic_pay,
                       l_new_total_salary,
                       l_other_pay,
                       l_new_other_pay_amount,
                       l_new_au_overtime,
                       l_new_availability_pay,
                       l_new_retention_allowance,
                       l_retention_allow_perc,
                       l_new_supervisory_differential,
                       l_supervisory_diff_perc,
                       l_staffing_differential,
                       l_duty_station_id,
                       l_duty_station_code,
                       l_duty_station_desc,
                       -- FWFA Changes  Bug#4444609
                       l_pay_rate_determinant,
                       l_pay_calc_out_data.pay_table_id,
                       l_pay_calc_out_data.calculation_pay_table_id,
                       -- FWFA Changes
                       l_lac_sf52_rec,
                       l_sf52_rec);

                   begin

		              l_sf52_rec.mass_action_id := p_mass_salary_id;
                      l_sf52_rec.rpa_type := 'MTC';

                      ghr_mass_changes.create_sf52_for_mass_changes
                           (p_mass_action_type => 'MASS_TABLE_CHG',
                            p_pa_request_rec   => l_sf52_rec,
                            p_errbuf           => l_errbuf,
                            p_retcode          => l_retcode);

				------ Added by Dinkar for List reports problem

					 declare
					 l_pa_request_number ghr_pa_requests.request_number%TYPE;
						 begin

						 l_pa_request_number   :=
								 l_sf52_rec.request_number||'-'||p_mass_salary_id;

						 ghr_par_upd.upd
						  (p_pa_request_id             => l_sf52_rec.pa_request_id,
						   p_object_version_number     => l_sf52_rec.object_version_number,
						   p_request_number            => l_pa_request_number
						  );
						 end;

				---------------------------------------
                        if l_errbuf is null then
                           pr('No error in create sf52 ');
                           hr_utility.set_location('Before commiting',2);

                           ghr_mto_int.log_message(
                              p_procedure => 'Successful Completion',
                              p_message   => 'Name: '||p_full_name ||
                                   ' SSN: '|| p_national_identifier|| '  Mass Salary : '||
                                   p_mass_salary ||' SF52 Successfully completed');


			   create_lac_remarks(l_pa_request_id,
                                           l_sf52_rec.pa_request_id);

                           -- Added by Enunez 11-SEP-1999
                           IF l_lac_sf52_rec.first_action_la_code1 IS NULL THEN
                             -- Added by Edward Nunez for 894 rules
                             g_proc := 'Apply_FWFA_Rules';
			     -- FWFA Changes Bug#4444609
                             ghr_lacs_remarks.Apply_fwfa_Rules(
                                               l_sf52_rec.pa_request_id,
                                               l_sf52_rec.first_noa_code,
                                               l_sf52_rec.to_pay_plan,
                                               l_errbuf,
                                               l_retcode
                                               );
       			     -- FWFA Changes
                             if l_errbuf is not null then
                                l_mtcerrbuf := l_mtcerrbuf || ' ' || l_errbuf || ' Sql Err is '
                                                                  || sqlerrm(sqlcode);
                                raise mtc_error;
                             end if;
                           END IF; -- IF l_lac_sf52_rec.first_action_la_code1

                           g_proc := 'update_SEL_FLG';

                           update_SEL_FLG(p_PERSON_ID,l_effective_date);

                           commit;
                        else
                           pr('Error in create sf52',l_errbuf);
                           hr_utility.set_location('Error in '||to_char(p_position_id),20);
                           --l_recs_failed := l_recs_failed + 1;
                           raise mtc_error;
                        end if; -- if l_errbuf is null then
                   exception
                      when mtc_error then raise;
                      when others then  null;
                    l_mtcerrbuf := 'Error in ghr_mass_chg.create_sf52 '||
                                   ' Sql Err is '|| sqlerrm(sqlcode);
                    raise mtc_error;
                   end;
                END IF; --  IF upper(p_action) IN ('SHOW','REPORT') THEN
              END IF; -- end if for check_select_flg
           END IF; -- end if for p_action = 'REPORT'
       END IF; -- CHECK FOR PAY PLAN
       END IF; -- check for PRD
       END IF; -- check eligibility_mtc
       END LOOP; -- Record Type Loop ends here
       --END IF; -- Check Grade and percent.
      END IF; --- end if for check_init_eligibility

         L_row_cnt := L_row_cnt + 1;
         if upper(p_action) <> 'CREATE' THEN
           if L_row_cnt > 50 then
              commit;
              L_row_cnt := 0;
           end if;
         end if;
      EXCEPTION
         WHEN MTC_ERROR THEN
               HR_UTILITY.SET_LOCATION('Error occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),10);
               begin
                ------  BUG 3287299 -- Not to rollback for preview.
       	        if upper(p_action) <> 'SHOW' then
                  ROLLBACK TO execute_msl_pay_SP;
                end if;
               EXCEPTION
                  WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error in '||l_proc||' '||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| p_full_name || ' SSN: ' || p_national_identifier ||' '||
                              l_mtcerrbuf;
               hr_utility.set_location('before creating entry in log file',10);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);

            exception
                when others then
                    hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
                    hr_utility.raise_error;
            end;
         when others then
               HR_UTILITY.SET_LOCATION('Error (Others) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),20);
               BEGIN
                 ROLLBACK TO execute_msl_pay_SP;
               EXCEPTION
                 WHEN OTHERS THEN NULL;
               END;
               l_log_text  := 'Error (others) in '||l_proc||
                              ' For Mass Salary Name : '||p_mass_salary||
                              'Name: '|| p_full_name || ' SSN: ' || p_national_identifier ||
                              ' Sql Err is '||sqlerrm(sqlcode);
               hr_utility.set_location('before creating entry in log file',20);
               l_recs_failed := l_recs_failed + 1;
            begin
               ghr_mto_int.log_message(
                              p_procedure => g_proc,
                              p_message   => l_log_text);

            exception
                when others then
                    hr_utility.set_message(8301, 'Create Error Log failed');
                    hr_utility.raise_error;
            end;


  END msl_pay_process;

BEGIN

  g_proc  := 'execute_msl_pay';
  hr_utility.set_location('Entering    ' || l_proc,5);
  p_retcode  := 0;
  l_count    := 0;

  ghr_msl_pkg.g_first_noa_code     := null;


  BEGIN
    FOR msl IN ghr_msl (p_mass_salary_id)
    LOOP
        p_mass_salary              := msl.name;
        l_effective_date           := msl.effective_date;
        l_mass_salary_id           := msl.mass_salary_id;
        l_user_table_id            := msl.user_table_id;
        l_submit_flag              := msl.submit_flag;
        l_executive_order_number   := msl.executive_order_number;
        l_executive_order_date     :=  msl.executive_order_date;
        l_opm_issuance_number      :=  msl.opm_issuance_number;
        l_opm_issuance_date        :=  msl.opm_issuance_date;
        l_pa_request_id            := msl.pa_request_id;
        l_rowid                    := msl.rowid;
        l_p_ORGANIZATION_ID        := msl.ORGANIZATION_ID;
        l_p_DUTY_STATION_ID        := msl.DUTY_STATION_ID;
        l_p_PERSONNEL_OFFICE_ID    := msl.PERSONNEL_OFFICE_ID;
        l_p_AGENCY_CODE_SUBELEMENT := msl.AGENCY_CODE_SUBELEMENT;
        l_p_locality_area_code     := msl.locality_pay_area_code;

    		pr('Pa request id is '||to_char(l_pa_request_id));
       exit;
    END LOOP;
  EXCEPTION
    when REC_BUSY then
        hr_utility.set_location('Mass Salary is in use',1);
        l_mtcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
        hr_utility.set_message(8301, 'GHR_38477_LOCK_ON_MSL');
        hr_utility.raise_error;
--
    when others then
        hr_utility.set_location('Error in '||l_proc||' Sql err is '||sqlerrm(sqlcode),1);
        l_mtcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
        raise mtc_error;
  END;

  g_effective_date := l_effective_date;

-- Bug 3315432 Madhuri
--
  FOR pp_prd_per_gr IN cur_pp_prd_per_gr(p_mass_salary_id)
  LOOP
	rec_pp_prd_per_gr(l_index).pay_plan := pp_prd_per_gr.pay_plan;
	rec_pp_prd_per_gr(l_index).prd      := pp_prd_per_gr.prd;
	rec_pp_prd_per_gr(l_index).grade    := pp_prd_per_gr.grade;
	l_index := l_index +1;
        l_count := l_count + 1;
  END LOOP;

  if l_count = 0 then
     rec_pp_prd_per_gr(1).pay_plan := null;
     rec_pp_prd_per_gr(1).prd      := 'ALL';
     rec_pp_prd_per_gr(1).grade    := null;
  end if;

  IF upper(p_action) = 'CREATE' then
     ghr_mto_int.set_log_program_name('GHR_MSL_PKG');
  ELSE
     ghr_mto_int.set_log_program_name('MSL_'||p_mass_salary);
  END IF;

  get_lac_dtls(l_pa_request_id,
               l_lac_sf52_rec);

  hr_utility.set_location('After fetch msl '||to_char(l_effective_date)
    ||' '||to_char(l_user_table_id),20);

    IF l_p_ORGANIZATION_ID is not null then
    FOR per IN cur_people_org (l_effective_date,l_p_ORGANIZATION_ID)
    LOOP
        FOR ast IN cur_ast (per.assignment_status_type_id) LOOP
            msl_pay_process( p_assignment_id  => per.assignment_id
                      ,p_person_id => per.person_id
                      ,p_position_id  => per.position_id
                      ,p_grade_id => per.grade_id
                      ,p_business_group_id => per.business_group_id
                      ,p_location_id => per.location_id
                      ,p_organization_id => per.organization_id
                      ,p_date_of_birth => per.date_of_birth
                      ,p_first_name => per.first_name
		                ,p_last_name => per.last_name
                      ,p_full_name => per.full_name
                      ,p_middle_names => per.middle_names
		                ,p_national_identifier => per.national_identifier

                      );
        END LOOP;
    END LOOP;
  ELSE
    FOR per IN cur_people (l_effective_date,l_p_ORGANIZATION_ID)
    LOOP
        FOR ast IN cur_ast (per.assignment_status_type_id) LOOP
                        msl_pay_process( p_assignment_id  => per.assignment_id
                      ,p_person_id => per.person_id
                      ,p_position_id  => per.position_id
                      ,p_grade_id => per.grade_id
                      ,p_business_group_id => per.business_group_id
                      ,p_location_id => per.location_id
                      ,p_organization_id => per.organization_id
                      ,p_date_of_birth => per.date_of_birth
		                ,p_first_name => per.first_name
		                ,p_last_name => per.last_name
                      ,p_full_name => per.full_name
                      ,p_middle_names => per.middle_names
                      ,p_national_identifier => per.national_identifier
                      );

        END LOOP;
    END LOOP;
  END IF;

  pr('After processing is over ',to_char(l_recs_failed));

 -- Vacant Positions Logic

  hr_utility.set_location('Entering  Unassigned positions  ' || l_proc,30);

                FOR c_pay_table_rec IN c_pay_table_id('0000') LOOP
                    l_0000_id   := c_pay_table_rec.user_table_id;
                    exit;
                END LOOP;

  hr_utility.set_location('0000 tableid is ' || to_char(l_0000_id) || l_proc,35);

                FOR c_pay_table_rec IN c_pay_table_id('0491') LOOP
                    l_0491_id   := c_pay_table_rec.user_table_id;
                    exit;
                END LOOP;

  hr_utility.set_location('0491 tableid is ' || to_char(l_0491_id) || l_proc,36);

                FOR un_per IN unassigned_pos (l_p_organization_id,  l_effective_date)
                LOOP

                    l_avail_status_id := un_per.availability_status_id;

            -- 1 Available status check
                    IF ( HR_GENERAL.DECODE_AVAILABILITY_STATUS(l_avail_status_id)
                        = 'Active' )  THEN
 ---------          not in ('Eliminated','Frozen','Deleted') ) THEN

  hr_utility.set_location('Available status ' || HR_GENERAL.DECODE_AVAILABILITY_STATUS(l_avail_status_id) || l_proc,37);
                        l_position_id       := un_per.position_id;
  hr_utility.set_location('position id is ' || to_char(l_position_id) || l_proc,40);

                        ghr_history_fetch.fetch_positionei
                        (p_position_id      => l_position_id
                        ,p_information_type => 'GHR_US_POS_VALID_GRADE'
                        ,p_DATE_effective   => l_effective_DATE
                        ,p_pos_ei_data      => l_pos_valid_grade_ei_data
                        );

                        l_grade_id          := l_pos_valid_grade_ei_data.poei_information3;
                        l_pay_table_id      := l_pos_valid_grade_ei_data.poei_information5;
                        l_business_group_id := un_per.business_group_iD;
                        l_location_id       := un_per.location_id;

  hr_utility.set_location('position valid grade table id is ' || to_char(l_pay_table_id) || l_proc,45);
                        BEGIN
                            ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                            (p_location_id      => l_location_id
                            ,p_duty_station_id  => l_duty_station_id);
                        END;

                        get_pos_grp1_ddf(l_position_id,
                                         l_effective_date,
                                         l_pos_grp1_rec);

                        l_personnel_office_id := l_pos_grp1_rec.poei_information3;
                        l_org_structure_id    := l_pos_grp1_rec.poei_information5;

                        l_position_title := ghr_api.get_position_title_pos
                                              (p_position_id            => l_position_id
                                              ,p_business_group_id      => l_business_group_id ) ;

                        l_sub_element_code := ghr_api.get_position_agency_code_pos
                                              (l_position_id,l_business_group_id);

                        l_occ_series := ghr_api.get_job_occ_series_job
                                              (p_job_id              => un_per.job_id
                                              ,p_business_group_id   => un_per.business_group_id);

                        l_position_NUMBER := ghr_api.get_position_desc_no_pos
                                              (p_position_id         => l_position_id
                                              ,p_business_group_id   => un_per.business_group_id);

                        l_position_seq_no := ghr_api.get_position_sequence_no_pos
                                              (p_position_id         => l_position_id
                                              ,p_business_group_id   => un_per.business_group_id);

   -- Check Locality Area Code

         l_locality_check := FALSE;

         IF l_p_locality_area_code is null then
              l_locality_check := TRUE;
         ELSE
            FOR c_locality_rec IN c_locality (l_effective_date,l_location_id,l_p_locality_area_code)
            LOOP
                l_locality_check := TRUE;
                exit;
            END LOOP;
         END IF;

         if l_locality_check then
  hr_utility.set_location('locality check is TRUE' || l_proc,50);
         else
  hr_utility.set_location('locality check is FALSE' || l_proc,50);
         end if;


   --2 Check Duty station code,POI,agnecy and subelement.

         IF l_locality_check
            AND l_user_table_id = nvl(l_pay_table_id,hr_api.g_number)
            AND check_init_eligibility(l_p_duty_station_id,
                              l_p_PERSONNEL_OFFICE_ID,
                              l_p_AGENCY_CODE_SUBELEMENT,
                              l_duty_station_id,
                              l_personnel_office_id,
                              l_sub_element_code) then

   hr_utility.set_location('check_init_eligibility    ' || l_proc,55);

                        FOR c_grade_kff_rec IN c_grade_kff (l_grade_id)
                        LOOP
                            l_pay_plan          := c_grade_kff_rec.segment1;
                            l_grade_or_level    := c_grade_kff_rec.segment2;
                            exit;
                        END loop;

   hr_utility.set_location('l_pay_plan          ' || l_pay_plan || l_proc,56);
   hr_utility.set_location('l_grade_or_level    ' || l_grade_or_level || l_proc,56);

   --3 (Internal Loop) Check pay plan,table id
      FOR l_cnt in 1..rec_pp_prd_per_gr.COUNT LOOP

   hr_utility.set_location('For internal loop l_cnt    ' || to_char(l_cnt) || l_proc,58);
   --4 Pay plan , table, grade check
          IF ( nvl(rec_pp_prd_per_gr(l_cnt).pay_plan,l_pay_plan) = l_pay_plan
             AND l_user_table_id = nvl(l_pay_table_id,hr_api.g_number)
             AND  nvl(rec_pp_prd_per_gr(l_cnt).grade,l_grade_or_level)=l_grade_or_level ) THEN

   hr_utility.set_location('check l_pay_plan          ' || l_pay_plan || l_proc,58);
   hr_utility.set_location('check l_grade_or_level    ' || l_grade_or_level || l_proc,58);
             BEGIN
                 ghr_pa_requests_pkg.get_duty_station_details
                     (p_duty_station_id   => l_duty_station_id
                     ,p_effective_DATE    => l_effective_DATE
                     ,p_duty_station_code => l_duty_station_code
                     ,p_duty_station_desc => l_duty_station_desc);
             END;
             check_select_flg_pos(un_per.position_id
                                 ,UPPER(p_action)
                                 ,l_effective_DATE
                                 ,p_mass_salary_id
                                 ,l_sel_flg);

  hr_utility.set_location('Entering  Before get_special_table_pay_table_value ' || l_proc,60);
                 ghr_pay_calc.get_special_pay_table_value
                                 (p_pay_plan         => l_pay_plan
                                 ,p_grade_or_level   => l_grade_or_level
                                 ,p_step_or_rate     => null
                                 ,p_user_table_id    => l_user_table_id
                                 ,p_effective_date   => l_effective_date
                                 ,p_pt_value          => l_pt_value
                                 ,p_PT_eff_start_date => l_pt_eff_start_date
                                 ,p_PT_eff_end_date   => l_pt_eff_end_date
                                 ,p_pp_grd_exists     => l_pp_grd_exists);
        --

        --5 pp_grd check
              IF NOT l_pp_grd_exists THEN
                IF ghr_pay_calc.LEO_position (l_dummy
                                ,l_position_id
                                ,l_dummy
                                ,l_dummy
                                ,l_effective_date) AND l_grade_or_level between 03 and 10 THEN
                   l_to_pay_table_id := l_0491_id;
                ELSE
                   l_to_pay_table_id := l_0000_id;
                END IF;

                IF UPPER(p_action) = 'SHOW' or (UPPER(p_action) = 'REPORT') THEN
                    create_mass_act_prev_mtc (
                        p_effective_date          => l_effective_date,
                        p_date_of_birth           => null,
                        p_full_name               => un_per.full_name,
                        p_national_identifier     => un_per.national_identifier,
                        p_duty_station_code       => l_duty_station_code,
                        p_duty_station_desc       => l_duty_station_desc,
                        p_personnel_office_id     => l_personnel_office_id,
                        p_basic_pay               => null,
                        p_new_basic_pay           => null,
                        p_adj_basic_pay           => null,
                        p_new_adj_basic_pay       => null,
                        p_old_avail_pay           => null,
                        p_new_avail_pay           => null,
                        p_old_loc_diff            => null,
                        p_new_loc_diff            => null,
                        p_tot_old_sal             => null,
                        p_tot_new_sal             => null,
                        p_old_auo_pay             => null,
                        p_new_auo_pay             => null,
                        p_position_id             => l_position_id,
                        p_position_title          => l_position_title,
                         -- FWFA Changes Bug#4444609
                         p_position_number         => l_position_number,
                         p_position_seq_no         => l_position_seq_no,
                         -- FWFA Changes
                        p_org_structure_id        => l_org_structure_id,
                        p_agency_sub_element_code => l_sub_element_code,
                        p_person_id               => null,
                        p_mass_salary_id          => l_mass_salary_id,
                        p_sel_flg                 => l_sel_flg,
                        p_first_action_la_code1   => null,
                        p_first_action_la_code2   => null,
                        p_remark_code1            => null,
                        p_remark_code2            => null,
                        p_grade_or_level          => l_grade_or_level,
                        p_step_or_rate            => null,
                        p_pay_plan                => l_pay_plan,
                        p_pay_rate_determinant    => null,
                        p_tenure                  => null,
                        p_action                  => p_action,
                        p_assignment_id           => null,
                        p_old_other_pay           => null,
                        p_new_other_pay           => null,
                        p_old_capped_other_pay    => null,
                        p_new_capped_other_pay    => null,
                        p_old_retention_allowance => null,
                        p_new_retention_allowance => null,
                        p_old_supervisory_differential => null,
                        p_new_supervisory_differential => null,
			            p_organization_name            => l_org_name,
                        -- FWFA Changes Bug#4444609
                        p_input_pay_rate_determinant     =>  null,
                        p_from_pay_table_id            => l_user_table_id,
                        p_to_pay_table_id              => l_to_pay_table_id
                        -- FWFA Changes
                         );
                     exit;
                   ELSIF upper(p_action) = 'CREATE' THEN
                      --Bug 4699955
                      FOR c_pos_name_rec IN c_pos_name(l_position_id) LOOP
                          l_pos_name := c_pos_name_rec.name;
                          exit;
                      END LOOP;
                      --Bug 4699955
                      if l_sel_flg = 'Y' then
                         begin
                           ghr_api.g_api_dml       := TRUE;
                           ghr_position_extra_info_api.update_position_extra_info
                           ( p_position_extra_info_id   =>    l_pos_valid_grade_ei_data.position_extra_info_id
                           , p_effective_date           =>    l_effective_date
                           , p_object_version_number    =>    l_pos_valid_grade_ei_data.object_version_number
                           , p_poei_information5        =>    l_to_pay_table_id);
                           ghr_api.g_api_dml       := FALSE;

                           ghr_validate_perwsdpo.validate_perwsdpo(l_position_id,l_effective_date);
                           ghr_validate_perwsdpo.update_posn_status(l_position_id,l_effective_date);

                           ghr_mto_int.log_message(
                               p_procedure => 'Successful Completion',
                               p_message   => 'Vacant Position : '||l_pos_name ||
                                        ' Mass Table Change : '||
                                          p_mass_salary ||' Vacant pos Successfully completed');

                           position_history_update (p_position_id    => l_position_id,
                                                    p_effective_date => l_effective_date,
                                                    p_table_id       => l_user_table_id,
                                                    p_upd_tableid    => l_to_pay_table_id);

                           upd_ext_info_to_null(l_position_id,l_effective_DATE);
                           exit;
------
/******
                           g_proc := 'ghr_sf52.UPDATE_position_info';
                           l_position_data_rec.position_id       := l_position_id;
                           l_position_data_rec.effective_DATE    := l_effective_DATE;
                           l_position_data_rec.organization_id   := un_per.organization_id;
                           ----ghr_mre_pkg.UPDATE_position_info (l_position_data_rec);
**************************/
                         exception when  others then
                                l_mtcerrbuf := 'Error in ghr_sf52_pos_UPDATE.UPDATE_position_info' ||
                                               ' Sql Err is '|| sqlerrm(sqlcode);
                           ghr_mto_int.log_message(
                               p_procedure => 'Failed',
                               p_message   => 'Vacant Position : '||l_pos_name ||
                                        ' Mass Table Change : '||
                                          p_mass_salary || l_mtcerrbuf);

                         end;
                      end if;
                 END IF;   ------Preview or Final
                END IF;    ------pp_grd_check
               END IF;      ------pay plan,table, grade check
              END LOOP;     ------Internal Loop.
             END IF;        ------Locality Check and Eligibility check
            END IF;         ------Check of avaiability status

          END LOOP;

   if (l_recs_failed  = 0) then
     IF upper(p_action) = 'CREATE' THEN
       begin
          update ghr_mass_salaries
             set submit_flag = 'P'
           where rowid = l_rowid;
       EXCEPTION
         when others then
           HR_UTILITY.SET_LOCATION('Error in Update ghr_msl  Sql error '||sqlerrm(sqlcode),30);
           hr_utility.set_message(8301, 'GHR_38476_UPD_GHR_MSL_FAILURE');
           hr_utility.raise_error;
       END;
     end if;
  ELSE
      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_salaries
            set submit_flag = 'E'
          where rowid = l_rowid;
      END IF;
  end if;
COMMIT;

EXCEPTION
    when others then
      HR_UTILITY.SET_LOCATION('Error (Others2) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),30);
      BEGIN
        ROLLBACK TO execute_msl_pay_SP;
      EXCEPTION
        WHEN OTHERS THEN NULL;
      END;
      l_log_text  := 'Error in '||l_proc||
                     ' For Mass Salary Name : '||p_mass_salary||
                     ' Sql Err is '||sqlerrm(sqlcode);
      l_recs_failed := l_recs_failed + 1;
      hr_utility.set_location('before creating entry in log file',30);

      p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
      p_retcode  := 2;
      IF upper(p_action) = 'CREATE' THEN
         update ghr_mass_salaries
            set submit_flag = 'E'
          where rowid = l_rowid;
          commit;
      END IF;

      begin
         ghr_mto_int.log_message(
                        p_procedure => g_proc,
                        p_message   => l_log_text);

      exception
          when others then
              hr_utility.set_message(8301, 'Create Error Log failed');
              hr_utility.raise_error;
      end;

END execute_msl_pay;

--
--
--

-- Function returns the request id.
-- This is coded as a wrapper for fnd_request.submit_request
-- if all the params are passed as null, the submit request is passing all the
-- params as null and so, we get wrong no of params passed error.
--

function SUBMIT_CONC_REQ (P_APPLICATION IN VARCHAR2,
                              P_PROGRAM IN VARCHAR2,
                              P_DESCRIPTION IN VARCHAR2,
                              P_START_TIME IN VARCHAR2,
                              P_SUB_REQUEST IN BOOLEAN,
                              P_ARGUMENT1 IN VARCHAR2,
                              P_ARGUMENT2 IN VARCHAR2)
   RETURN NUMBER IS
BEGIN
  return (fnd_request.submit_request(
   APPLICATION    => p_application
  ,PROGRAM        => p_program
  ,DESCRIPTION    => p_description
  ,START_TIME     => p_start_time
  ,SUB_REQUEST    => p_sub_request
  ,ARGUMENT1      => p_argument1
  ,ARGUMENT2      => p_argument2
 ));

end submit_conc_req;

--
--
--
-- Procedure Deletes all records processed by the report
--

procedure purge_processed_recs(p_session_id in number,
                               p_err_buf out nocopy varchar2) is
begin
   p_err_buf := null;
   delete from ghr_mass_actions_preview
         where mass_action_type = 'SALARY'
           and session_id  = p_session_id;
   commit;

exception
   when others then
     p_err_buf := 'Sql err '|| sqlerrm(sqlcode);
end;

--
-- Added p_org_name to this proc for MLC form changes
--
procedure pop_dtls_from_pa_req(p_person_id in number,p_effective_date in date,
         p_mass_salary_id in number, p_org_name in varchar2) is

cursor ghr_pa_req_cur is
select EMPLOYEE_DATE_OF_BIRTH,
       substr(EMPLOYEE_LAST_NAME||', '||EMPLOYEE_FIRST_NAME||' '||
              EMPLOYEE_MIDDLE_NAMES,1,240)  FULL_NAME,
       EMPLOYEE_NATIONAL_IDENTIFIER,
       DUTY_STATION_CODE,
       DUTY_STATION_DESC,
       PERSONNEL_OFFICE_ID,
       FROM_BASIC_PAY,
       TO_BASIC_PAY,
       --Bug#2383992
       FROM_ADJ_BASIC_PAY,
       TO_ADJ_BASIC_PAY,
       --Bug#2383992
       NULL FROM_AVAILABILITY_PAY,
       TO_AVAILABILITY_PAY,
       FROM_LOCALITY_ADJ,
       TO_LOCALITY_ADJ,
       FROM_TOTAL_SALARY,
       TO_TOTAL_SALARY,
       NULL FROM_AU_OVERTIME,
       TO_AU_OVERTIME,
       TO_POSITION_ID POSITION_ID,
       TO_POSITION_TITLE POSITION_TITLE,
       -- FWFA Changes Bug#4444609
       TO_POSITION_NUMBER POSITION_NUMBER,
       TO_POSITION_SEQ_NO POSITION_SEQ_NO,
       -- FWFA Changes
       null org_structure_id,
       FROM_AGENCY_CODE,
       PERSON_ID,
--       p_mass_salary_id
       'Y'  Sel_flag,
       first_action_la_code1,
       first_action_la_code2,
       NULL REMARK_CODE1,
       NULL REMARK_CODE2,
       from_grade_or_level,
       from_step_or_rate,
       from_pay_plan,
       PAY_RATE_DETERMINANT,
       TENURE,
       EMPLOYEE_ASSIGNMENT_ID,
       FROM_OTHER_PAY_AMOUNT,
       TO_OTHER_PAY_AMOUNT,
       --Bug#2383992
       NULL FROM_RETENTION_ALLOWANCE,
       TO_RETENTION_ALLOWANCE,
       NULL FROM_SUPERVISORY_DIFFERENTIAL,
       TO_SUPERVISORY_DIFFERENTIAL,
       NULL FROM_CAPPED_OTHER_PAY,
       NULL TO_CAPPED_OTHER_PAY,
       -- FWFA Changes Bug#4444609
       input_pay_rate_determinant,
       from_pay_table_identifier,
       to_pay_table_identifier
       -- FWFA Changes
  from ghr_pa_requests
 where person_id = p_person_id
   and effective_date = p_effective_date
   and substr(request_number,(instr(request_number,'-')+1)) = to_char(p_mass_salary_id)
   and first_noa_code = nvl(ghr_msl_pkg.g_first_noa_code,'895');

l_proc    varchar2(72) :=  g_package || '.pop_dtls_from_pa_req';
begin
    g_proc  := 'pop_dtls_from_pa_req';

    hr_utility.set_location('Entering    ' || l_proc,5);
    for pa_req_rec in ghr_pa_req_cur
    loop
     create_mass_act_prev (
			p_effective_date          => p_effective_date,
			p_date_of_birth           =>  pa_req_rec.employee_date_of_birth,
			p_full_name               => pa_req_rec.full_name,
			p_national_identifier     =>   pa_req_rec.employee_national_identifier,
			p_duty_station_code       => pa_req_rec.duty_station_code,
			p_duty_station_desc       => pa_req_rec.duty_station_desc,
			p_personnel_office_id     => pa_req_rec.personnel_office_id,
			p_basic_pay               =>pa_req_rec.from_basic_pay,
			p_new_basic_pay           => pa_req_rec.to_basic_pay,
			--Bug#2383992 Added old_adj_basic_pay
			p_adj_basic_pay           => pa_req_rec.from_adj_basic_pay,
			p_new_adj_basic_pay       => pa_req_rec.to_adj_basic_pay,
			p_old_avail_pay           =>  pa_req_rec.from_availability_pay,
			p_new_avail_pay           =>   pa_req_rec.to_availability_pay,
			p_old_loc_diff            =>  pa_req_rec.from_locality_adj,
			p_new_loc_diff            => pa_req_rec.to_locality_adj,
			p_tot_old_sal             =>   pa_req_rec.from_total_salary,
			p_tot_new_sal             =>   pa_req_rec.to_total_salary,
			p_old_auo_pay             =>  pa_req_rec.from_au_overtime,
			p_new_auo_pay             =>  pa_req_rec.to_au_overtime,
			p_position_id             => pa_req_rec.position_id,
			p_position_title          => pa_req_rec.position_title,
             -- FWFA Changes Bug#4444609
             p_position_number         => pa_req_rec.position_number,
             p_position_seq_no         => pa_req_rec.position_seq_no,
             -- FWFA Changes
			p_org_structure_id        => pa_req_rec.org_structure_id,
			p_agency_sub_element_code =>  pa_req_rec.from_agency_code,
			p_person_id               => pa_req_rec.person_id,
			p_mass_salary_id          =>  p_mass_salary_id,
			p_sel_flg                 => 'Y', --- Sel flag
			p_first_action_la_code1   => pa_req_rec.first_action_la_code1,
			p_first_action_la_code2   =>  pa_req_rec.first_action_la_code2,
			p_remark_code1            => pa_req_rec.remark_code1,   --- will be null
			p_remark_code2            => pa_req_rec.remark_code2,    --- will be null
			p_grade_or_level          => pa_req_rec.from_grade_or_level,
			p_step_or_rate            =>  pa_req_rec.from_step_or_rate,
			p_pay_plan                => pa_req_rec.from_pay_plan,
			p_pay_rate_determinant    =>  pa_req_rec.pay_rate_determinant,
			p_tenure                  => pa_req_rec.tenure,
			p_action                  => 'REPORT',
			p_assignment_id           => pa_req_rec.employee_assignment_id,
			p_old_other_pay           => pa_req_rec.from_other_pay_amount,
			p_new_other_pay           => pa_req_rec.to_other_pay_amount,
			-- Bug#2383992
			p_old_capped_other_pay    => pa_req_rec.from_capped_other_pay,
			p_new_capped_other_pay    => pa_req_rec.to_capped_other_pay,
			p_old_retention_allowance => pa_req_rec.from_retention_allowance,
			p_new_retention_allowance => pa_req_rec.to_retention_allowance,
			p_old_supervisory_differential => pa_req_rec.from_supervisory_differential,
			p_new_supervisory_differential => pa_req_rec.to_supervisory_differential,
			-- BUG 3377958 Madhuri
			p_organization_name            =>  p_org_name,
			-- Bug#2383992
            -- FWFA Changes Bug#4444609
            p_input_pay_rate_determinant     =>  pa_req_rec.input_pay_rate_determinant,
            p_from_pay_table_id            =>  pa_req_rec.from_pay_table_identifier,
            p_to_pay_table_id              =>  pa_req_rec.to_pay_table_identifier
            -- FWFA Changes
  		      );
       exit;
     END LOOP;
     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end pop_dtls_from_pa_req;
--
-- Added the following procedure for MTC changes
--
procedure pop_dtls_from_pa_req_mtc(p_person_id in number,p_effective_date in date,
         p_mass_salary_id in number, p_org_name in varchar2) is

cursor ghr_pa_req_cur is
select EMPLOYEE_DATE_OF_BIRTH,
       substr(EMPLOYEE_LAST_NAME||', '||EMPLOYEE_FIRST_NAME||' '||
              EMPLOYEE_MIDDLE_NAMES,1,240)  FULL_NAME,
       EMPLOYEE_NATIONAL_IDENTIFIER,
       DUTY_STATION_CODE,
       DUTY_STATION_DESC,
       PERSONNEL_OFFICE_ID,
       FROM_BASIC_PAY,
       TO_BASIC_PAY,
       --Bug#2383992
       FROM_ADJ_BASIC_PAY,
       TO_ADJ_BASIC_PAY,
       --Bug#2383992
       NULL FROM_AVAILABILITY_PAY,
       TO_AVAILABILITY_PAY,
       FROM_LOCALITY_ADJ,
       TO_LOCALITY_ADJ,
       FROM_TOTAL_SALARY,
       TO_TOTAL_SALARY,
       NULL FROM_AU_OVERTIME,
       TO_AU_OVERTIME,
       TO_POSITION_ID POSITION_ID,
       TO_POSITION_TITLE POSITION_TITLE,
       -- FWFA Changes Bug#4444609
       TO_POSITION_NUMBER POSITION_NUMBER,
       TO_POSITION_SEQ_NO POSITION_SEQ_NO,
       -- FWFA Changes
       null org_structure_id,
       FROM_AGENCY_CODE,
       PERSON_ID,
--       p_mass_salary_id
       'Y'  Sel_flag,
       first_action_la_code1,
       first_action_la_code2,
       NULL REMARK_CODE1,
       NULL REMARK_CODE2,
       from_grade_or_level,
       from_step_or_rate,
       from_pay_plan,
       PAY_RATE_DETERMINANT,
       TENURE,
       EMPLOYEE_ASSIGNMENT_ID,
       FROM_OTHER_PAY_AMOUNT,
       TO_OTHER_PAY_AMOUNT,
       --Bug#2383992
       NULL FROM_RETENTION_ALLOWANCE,
       TO_RETENTION_ALLOWANCE,
       NULL FROM_SUPERVISORY_DIFFERENTIAL,
       TO_SUPERVISORY_DIFFERENTIAL,
       NULL FROM_CAPPED_OTHER_PAY,
       NULL TO_CAPPED_OTHER_PAY,
       -- FWFA Changes Bug#4444609
       input_pay_rate_determinant,
       from_pay_table_identifier,
       to_pay_table_identifier
       -- FWFA Changes
  from ghr_pa_requests
 where person_id = p_person_id
   and effective_date = p_effective_date
   and substr(request_number,(instr(request_number,'-')+1)) = to_char(p_mass_salary_id)
   and first_noa_code in ('894','800');

l_proc    varchar2(72) :=  g_package || '.pop_dtls_from_pa_req_mtc';
begin
    g_proc  := 'pop_dtls_from_pa_req_mtc';

    hr_utility.set_location('Entering    ' || l_proc,5);
    for pa_req_rec in ghr_pa_req_cur
    loop
     create_mass_act_prev_mtc (
			p_effective_date          => p_effective_date,
			p_date_of_birth           =>  pa_req_rec.employee_date_of_birth,
			p_full_name               => pa_req_rec.full_name,
			p_national_identifier     =>   pa_req_rec.employee_national_identifier,
			p_duty_station_code       => pa_req_rec.duty_station_code,
			p_duty_station_desc       => pa_req_rec.duty_station_desc,
			p_personnel_office_id     => pa_req_rec.personnel_office_id,
			p_basic_pay               =>pa_req_rec.from_basic_pay,
			p_new_basic_pay           => pa_req_rec.to_basic_pay,
			p_adj_basic_pay           => pa_req_rec.from_adj_basic_pay,
			p_new_adj_basic_pay       => pa_req_rec.to_adj_basic_pay,
			p_old_avail_pay           =>  pa_req_rec.from_availability_pay,
			p_new_avail_pay           =>   pa_req_rec.to_availability_pay,
			p_old_loc_diff            =>  pa_req_rec.from_locality_adj,
			p_new_loc_diff            => pa_req_rec.to_locality_adj,
			p_tot_old_sal             =>   pa_req_rec.from_total_salary,
			p_tot_new_sal             =>   pa_req_rec.to_total_salary,
			p_old_auo_pay             =>  pa_req_rec.from_au_overtime,
			p_new_auo_pay             =>  pa_req_rec.to_au_overtime,
			p_position_id             => pa_req_rec.position_id,
			p_position_title          => pa_req_rec.position_title,
             -- FWFA Changes Bug#4444609
             p_position_number         => pa_req_rec.position_number,
             p_position_seq_no         => pa_req_rec.position_seq_no,
             -- FWFA Changes
			p_org_structure_id        => pa_req_rec.org_structure_id,
			p_agency_sub_element_code =>  pa_req_rec.from_agency_code,
			p_person_id               => pa_req_rec.person_id,
			p_mass_salary_id          =>  p_mass_salary_id,
			p_sel_flg                 => 'Y', --- Sel flag
			p_first_action_la_code1   => pa_req_rec.first_action_la_code1,
			p_first_action_la_code2   =>  pa_req_rec.first_action_la_code2,
			p_remark_code1            => pa_req_rec.remark_code1,   --- will be null
			p_remark_code2            => pa_req_rec.remark_code2,    --- will be null
			p_grade_or_level          => pa_req_rec.from_grade_or_level,
			p_step_or_rate            =>  pa_req_rec.from_step_or_rate,
			p_pay_plan                => pa_req_rec.from_pay_plan,
			p_pay_rate_determinant    =>  pa_req_rec.pay_rate_determinant,
			p_tenure                  => pa_req_rec.tenure,
			p_action                  => 'REPORT',
			p_assignment_id           => pa_req_rec.employee_assignment_id,
			p_old_other_pay           => pa_req_rec.from_other_pay_amount,
			p_new_other_pay           => pa_req_rec.to_other_pay_amount,
			p_old_capped_other_pay    => pa_req_rec.from_capped_other_pay,
			p_new_capped_other_pay    => pa_req_rec.to_capped_other_pay,
			p_old_retention_allowance => pa_req_rec.from_retention_allowance,
			p_new_retention_allowance => pa_req_rec.to_retention_allowance,
			p_old_supervisory_differential => pa_req_rec.from_supervisory_differential,
			p_new_supervisory_differential => pa_req_rec.to_supervisory_differential,
			p_organization_name            => p_org_name,
            -- FWFA Changes Bug#4444609
            p_input_pay_rate_determinant     =>  pa_req_rec.input_pay_rate_determinant,
            p_from_pay_table_id            =>  pa_req_rec.from_pay_table_identifier,
            p_to_pay_table_id              =>  pa_req_rec.to_pay_table_identifier
            -- FWFA Changes
  		     );
       exit;
     END LOOP;
     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end pop_dtls_from_pa_req_mtc;


--
--
--

FUNCTION check_select_flg(p_person_id in number,
                          p_action in varchar2,
                          p_effective_date in date,
                          p_mass_salary_id in number,
                          p_sel_flg in out nocopy varchar2)
RETURN boolean IS

l_per_ei_data        per_people_extra_info%rowtype;
l_comments           varchar2(250);
l_sel_flag           varchar2(3);
l_line               number := 0;

l_proc               varchar2(72) :=  g_package || '.check_select_flg';

BEGIN

     g_proc  := 'check_select_flg';
     hr_utility.set_location('Entering    ' || l_proc,5);

     get_extra_info_comments(p_person_id,p_effective_date,l_sel_flag,l_comments,p_mass_salary_id);

     --------- Initialize the comments
     -- Now all the messages have MLC as a prefix.
     --
     IF l_comments is not null THEN
       IF substr(nvl(l_comments,'@#%'),1,3) = 'MLC' THEN
          ins_upd_per_extra_info
               (p_person_id,p_effective_date, l_sel_flag, null,p_mass_salary_id);
       END IF;
     END IF;
     ---------

     IF l_sel_flag IS null THEN
          p_sel_flg := 'Y';
     ELSE
          p_sel_flg := l_sel_flag;
     END IF;

     IF p_action IN ('SHOW','REPORT') THEN
         RETURN TRUE;
     ELSIF p_action = 'CREATE' THEN
         IF p_sel_flg = 'Y' THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
     END IF;
EXCEPTION
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||' @'||to_char(l_line)||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
END;

--
--
--

procedure purge_old_data (p_mass_salary_id in number) is
l_proc   varchar2(72) :=  g_package || '.purge_old_data';
BEGIN
   g_proc  := 'purge_old_data';

   hr_utility.set_location('Entering    ' || l_proc,5);
   delete from ghr_mass_actions_preview
    where mass_action_type = 'SALARY'
      and session_id  = p_mass_salary_id;
   commit;
   hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
END;

--
--
--

--Removed the procedure get_pay_plan_and_table_id

--
--
--

procedure update_sel_flg (p_person_id in number,p_effective_date date) is

   l_person_extra_info_id number;
   l_object_version_number number;
   l_per_ei_data         per_people_extra_info%rowtype;
   l_proc  varchar2(72) :=  g_package || '.update_sel_flg';
l_ind number := 1;
begin
  g_proc  := 'update_sel_flg';
   hr_utility.set_location('Entering    ' || l_proc,5);
pr('Inside '||l_proc,to_char(p_person_id));
l_ind := 10;
   ghr_history_fetch.fetch_peopleei
                  (p_person_id             => p_person_id
                  ,p_information_type      => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective        => p_effective_date
                  ,p_per_ei_data           => l_per_ei_data);

l_ind := 20;
   l_person_extra_info_id  := l_per_ei_data.person_extra_info_id;
   l_object_version_number := l_per_ei_data.object_version_number;

   if l_person_extra_info_id is not null then
      ghr_person_extra_info_api.update_person_extra_info
                   (P_PERSON_EXTRA_INFO_ID   => l_person_extra_info_id
                   ,P_EFFECTIVE_DATE         => sysdate
                   ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
                   ,p_pei_INFORMATION3       => NULL
                   ,p_pei_INFORMATION4       => NULL
                   ,p_pei_INFORMATION5       => NULL
                   ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_MASS_ACTIONS');

l_ind := 30;
     hr_utility.set_location('Exiting    ' || l_proc,10);
-- There is a trigger on PER_PEOPLE_EXTRA_INFO to make the employee INVALID
-- when there is a update done on the table.
---Commented the following three lines to remove Validation functionality on Person.
---   ghr_validate_perwsepi.validate_perwsepi(p_person_id);
---   l_ind := 40;
---   ghr_validate_perwsepi.update_person_user_type(p_person_id);
   end if;

l_ind := 50;
  pr('Exiting '||l_proc,to_char(p_person_id));
exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||
                           ' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||' at '||to_char(l_ind)||
                          '  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end update_sel_flg;

--
--
--

FUNCTION GET_PAY_PLAN_NAME (PP IN VARCHAR2) RETURN VARCHAR2 IS

 CURSOR CUR_PP IS
 select pay_plan,description
   from ghr_pay_plans
  WHERE PAY_PLAN = PP;
  l_pp_desc varchar2(150);
BEGIN
  FOR PP_REC IN CUR_PP
  LOOP
     l_pp_desc := pp_rec.description;
     exit;
  END LOOP;
  return (l_pp_desc);
END;

FUNCTION GET_USER_TABLE_name (P_USER_TABLE_id IN NUMBER) RETURN VARCHAR2 IS
   CURSOR MSL_CUR IS
   select user_table_id,substr(user_table_name,0,4) user_table_name
     from pay_user_tables
         where substr(user_table_name,6,14) in
                     ('Oracle Federal','Federal Agency')
           and user_table_id = p_user_table_id;
  l_user_table_name varchar2(80);
BEGIN
    for msl in msl_cur
    LOOP
       l_user_table_name := msl.user_table_name;
       exit;
    end loop;
    return (l_user_table_name);
END;

--
--
--


PROCEDURE get_extra_info_comments
                (p_person_id in number,
                 p_effective_date in date,
                 p_sel_flag    in out nocopy varchar2,
                 p_comments    in out nocopy varchar2,
		 p_mass_salary_id in number) is

  l_per_ei_data        per_people_extra_info%rowtype;
  l_proc  varchar2(72) := g_package || '.get_extra_info_comments';
  l_eff_date date;

  CURSOR chk_history (p_person_id in NUMBER ,
                      eff_date    in Date) IS
   select information9  info9
         ,information10 info10
	 ,information11 info11
   from ghr_pa_history
   where person_id = p_person_id
   and pa_history_id IN ( select max(pa_history_id)
                          from ghr_pa_history
                          where person_id  = p_person_id
                          and information5 = 'GHR_US_PER_MASS_ACTIONS'
                          and table_name   = 'PER_PEOPLE_EXTRA_INFO'
                          and effective_date = eff_date
                          group by  information11);

begin
  g_proc  := 'get_extra_info_comments';
    hr_utility.set_location('Entering    ' || l_proc,5);
/*
  if p_effective_date > sysdate then
       l_eff_date := sysdate;
  else
       l_eff_date := p_effective_date;
  end if;
*/
    l_eff_date := p_effective_date;

     ghr_history_fetch.fetch_peopleei
                  (p_person_id             => p_person_id
                  ,p_information_type      => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective        => l_eff_date
                  ,p_per_ei_data           => l_per_ei_data);

   if l_per_ei_data.pei_information5 <> p_mass_salary_id then
      p_sel_flag := 'Y';
      p_comments := null;
   else
    p_sel_flag := l_per_ei_data.pei_information3;
    p_comments := l_per_ei_data.pei_information4;
   end if;

    IF p_sel_flag IS NOT NULL and (l_per_ei_data.pei_information5 <> p_mass_salary_id) THEN
     FOR chk_history_rec in chk_history(p_person_id => p_person_id,
					eff_date => l_eff_date) loop
       If chk_history_rec.info11 = p_mass_salary_id then
         p_sel_flag := chk_history_rec.info9;
	 p_comments := chk_history_rec.info10;--Added by Ashley
       END IF;
     END LOOP;
   END IF;


exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end;

--
--
--

procedure ins_upd_per_extra_info
               (p_person_id in number,p_effective_date in date,
                p_sel_flag in varchar2, p_comment in varchar2,p_msl_id in number) is

   l_person_extra_info_id number;
   l_object_version_number number;
   l_per_ei_data         per_people_extra_info%rowtype;

   CURSOR people_ext_cur (person number) is
   SELECT person_extra_info_id, object_version_number
     FROM PER_people_EXTRA_INFO
    WHERE person_ID = person
      and information_type = 'GHR_US_PER_MASS_ACTIONS';

l_proc    varchar2(72) :=  g_package || '.ins_upd_per_extra_info';
    l_eff_date date;

begin
  g_proc  := 'ins_upd_per_extra_info';
  hr_utility.set_location('Entering    ' || l_proc,5);
  if p_effective_date > sysdate then
       l_eff_date := sysdate;
  else
       l_eff_date := p_effective_date;
  end if;

   ghr_history_fetch.fetch_peopleei
                  (p_person_id           => p_person_id
                  ,p_information_type      => 'GHR_US_PER_MASS_ACTIONS'
                  ,p_date_effective        => l_eff_date
                  ,p_per_ei_data           => l_per_ei_data);

   l_person_extra_info_id  := l_per_ei_data.person_extra_info_id;
   l_object_version_number := l_per_ei_data.object_version_number;

   if l_person_extra_info_id is null then
      for per_ext_rec in people_ext_cur(p_person_id)
      loop
         l_person_extra_info_id  := per_ext_rec.person_extra_info_id;
         l_object_version_number := per_ext_rec.object_version_number;
      end loop;
   end if;

   if l_person_extra_info_id is not null then
        ghr_person_extra_info_api.update_person_extra_info
                       (P_PERSON_EXTRA_INFO_ID   => l_person_extra_info_id
                       ,P_EFFECTIVE_DATE           => trunc(l_eff_date)
                       ,P_OBJECT_VERSION_NUMBER    => l_object_version_number
                       ,p_pei_INFORMATION3        => p_sel_flag
                       ,p_pei_INFORMATION4        => p_comment
                       ,p_pei_INFORMATION5        => to_char(p_msl_id)
                       ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_MASS_ACTIONS');
   else
        ghr_person_extra_info_api.create_person_extra_info
                       (P_pERSON_ID             => p_PERSON_id
                       ,P_INFORMATION_TYPE        => 'GHR_US_PER_MASS_ACTIONS'
                       ,P_EFFECTIVE_DATE          => trunc(l_eff_date)
                       ,p_pei_INFORMATION3       => p_sel_flag
                       ,p_pei_INFORMATION4       => p_comment
                       ,p_pei_INFORMATION5       => to_char(p_msl_id)
                       ,P_PEI_INFORMATION_CATEGORY  => 'GHR_US_PER_MASS_ACTIONS'
                       ,P_pERSON_EXTRA_INFO_ID  => l_pERSON_extra_info_id
                       ,P_OBJECT_VERSION_NUMBER   => l_object_version_number);
   end if;

---Commented the following two lines to remove Validation functionality on Person.
-- ghr_validate_perwsepi.validate_perwsepi(p_person_id);
-- ghr_validate_perwsepi.update_person_user_type(p_person_id);

   hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mlc_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end ins_upd_per_extra_info;

--
--
--

FUNCTION check_init_eligibility(p_duty_station_id in number,
                            p_PERSONNEL_OFFICE_ID in varchar2,
                            p_AGENCY_CODE_SUBELEMENT   in varchar2,
                            p_l_duty_station_id   in number,
                            p_l_personnel_office_id in varchar2,
                            p_l_sub_element_code in varchar2)
return boolean is

CURSOR cur_valid_DS(p_ds_id NUMBER)
IS
SELECT effective_end_date  end_date
FROM   ghr_duty_stations_f
WHERE  duty_station_id=p_ds_id
AND    g_effective_date between effective_start_date and effective_end_date;

l_ds_end_date	ghr_duty_stations_f.effective_end_date%type;

l_proc   varchar2(72) :=  g_package || '.check_init_eligibility';
BEGIN

  g_proc  := 'check_init_eligibility';
  hr_utility.set_location('Entering    ' || l_proc,5);

  if p_personnel_office_id is not null then
     if p_personnel_office_id <> nvl(p_l_personnel_office_id,'NULL!~') then
        return false;
     end if;
  end if;

  if p_agency_code_subelement is not null then
     if substr(p_agency_code_subelement, 1, 2) <> nvl(substr(p_l_sub_element_code, 1, 2), 'NULL!~') then
        return false;
     end if;
  end if;

  if substr(p_agency_code_subelement, 3, 2) is not null then
     if substr(p_agency_code_subelement, 3, 2) <> nvl(substr(p_l_sub_element_code, 3, 2), 'NULL!~') then
        return false;
     end if;
  end if;

  if p_duty_station_id is not null then
     if p_duty_station_id <> nvl(p_l_duty_station_id,0) then
        return false;
     end if;
  end if;

  FOR rec_ds in cur_valid_ds(p_l_duty_station_id)
  LOOP
      l_ds_end_date	:= rec_ds.end_Date;
  END LOOP;

  If l_ds_end_date IS NULL THEN
     hr_utility.set_location('Under DS null check'||p_l_duty_station_id,12345);
     raise mlc_error;
     return false;
  end if;

  pr('Eligible');
  return true;
exception
  when mlc_error then --raise;
   hr_utility.set_location('Error NO DUTY STATION '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf :=
     'Error - No valid Location found, salary cannot be correctly calculated without the employee''s duty location ';
     return false;
     raise mlc_error;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     return false;
     raise mlc_error;
END check_init_eligibility;


FUNCTION check_eligibility(p_pay_plan        in  varchar2,
                           p_person_id       in number,
                           p_effective_date  in date,
                           p_action          in varchar2)
return boolean is

l_proc         varchar2(72) :=  g_package || '.check_eligibility';

CURSOR cur_equiv_ES_pay_plan(p_pay_plan	ghr_pay_plans.pay_plan%TYPE)
IS
SELECT 1
FROM   ghr_pay_plans
WHERE  equivalent_pay_plan ='ES'
AND    pay_plan=p_pay_plan;

BEGIN
  g_proc  := 'check_eligibility';
  hr_utility.set_location('Entering    ' || l_proc,5);

--- MSL percentage changes Madhuri
---

FOR es_rec  IN cur_equiv_ES_pay_plan(p_pay_plan)
LOOP
 RETURN FALSE;
END LOOP;

IF p_pay_plan NOT IN ('AD','AL','GG','GH','GM','GS','IP',
                      'FB','FG','FJ','FM','FX','CA','AA','SL','ST','EE') THEN
 RETURN FALSE;
END IF;

 ---Filtering the pay plans which need not
 ---be picked for Locality Adjustment.

   IF p_action = 'CREATE' THEN
      IF person_in_pa_req_1noa
          (p_person_id      => p_person_id,
           p_effective_date => p_effective_date,
           p_first_noa_code => nvl(ghr_msl_pkg.g_first_noa_code,'895'),
           p_pay_plan       => p_pay_plan
           ) then
           ghr_mre_pkg.pr('1noa failed',to_char(p_person_id));
           RETURN FALSE;
      ELSE
           ghr_mre_pkg.pr('Eligible');
           RETURN TRUE;
      END IF;
  END IF;

  RETURN TRUE;
exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
END check_eligibility;

--
--
--

function person_in_pa_req_1noa
          (p_person_id      in number,
           p_effective_date in date,
           p_first_noa_code in varchar2,
           p_pay_plan       in varchar2,
           p_days           in number default 350
           )
  return boolean is
--
  l_name            per_people_f.full_name%type;
  l_pa_request_id   ghr_pa_requests.pa_request_id%TYPE;

  cursor csr_action_taken is
      select pr.pa_request_id, max(pa_routing_history_id) pa_routing_history_id
        from ghr_pa_requests pr, ghr_pa_routing_history prh
      where pr.pa_request_id = prh.pa_request_id
      and   person_id = p_person_id
      and   first_noa_code = p_first_noa_code
      and   effective_date = p_effective_date
      and nvl(pr.first_noa_cancel_or_correct,'X') <> ghr_history_api.g_cancel
---- Bug # 657439
      --and nvl(pr.first_noa_cancel_or_correct,'X') <> 'CANCELED'
      group by pr.pa_request_id;

    cursor csr_name is
    select substr(pr.employee_last_name || ', ' || pr.employee_first_name,1,240) fname
    from ghr_pa_requests pr
    where pr.pa_request_id = l_pa_request_id;

  cursor csr_action_taken_fw is
      select pr.pa_request_id, max(pa_routing_history_id) pa_routing_history_id
        from ghr_pa_requests pr, ghr_pa_routing_history prh
      where pr.pa_request_id = prh.pa_request_id
      and   person_id        = p_person_id
      and   first_noa_code   = p_first_noa_code
      and   effective_date   = p_effective_date
      and nvl(pr.first_noa_cancel_or_correct,'X') <> ghr_history_api.g_cancel
      group by pr.pa_request_id;

  cursor csr_eq_pay_plan is
      SELECT equivalent_pay_plan
      FROM ghr_pay_plans
     WHERE pay_plan = p_pay_plan;

    cursor pa_hist_cur (p_r_hist_id number) is
      select nvl(action_taken,' ') action_taken
        from ghr_pa_routing_history
      where pa_routing_history_id = p_r_hist_id;

  l_action_taken    ghr_pa_routing_history.action_taken%TYPE;
  l_proc     varchar2(72) :=  g_package || '.person_in_pa_req_1noa';
  l_eq_pay_plan     ghr_pay_plans.equivalent_pay_plan%type;

begin
  g_proc  := 'person_in_pa_req_1noa';
  hr_utility.set_location('Entering    ' || l_proc,5);
-- Bug 1631952 start

   for csr_eq_pay_plan_rec in csr_eq_pay_plan loop
      l_eq_pay_plan := csr_eq_pay_plan_rec.equivalent_pay_plan;
   end loop;

 if l_eq_pay_plan = 'FW' then
   for v_action_taken_fw in csr_action_taken_fw loop
       l_pa_request_id := v_action_taken_fw.pa_request_id;
       for v_name in csr_name
       loop
           l_name := v_name.fname;
       exit;
       end loop;
       for pa_hist_rec in pa_hist_cur (v_action_taken_fw.pa_routing_history_id)
       loop
           l_action_taken := pa_hist_rec.action_taken;
           exit;
       end loop;
      if l_action_taken <> 'CANCELED' then
          ghr_mto_int.log_message(
          p_procedure => 'RPA Exists Already',
          p_message   => 'Name: '|| l_name || ' - Salary Change ' ||
                         ' RPA Exists for the given FWS pay_lan and effective date' );
         return true;
      end if;
   end loop;
 else
--- Bug 1631952 end.  The same bug was extended to GS equvalent pay plans.
   for v_action_taken in csr_action_taken loop
       l_pa_request_id := v_action_taken.pa_request_id;
       for v_name in csr_name
       loop
           l_name := v_name.fname;
       exit;
       end loop;
       for pa_hist_rec in pa_hist_cur (v_action_taken.pa_routing_history_id)
       loop
           l_action_taken := pa_hist_rec.action_taken;
           exit;
       end loop;
      if l_action_taken <> 'CANCELED' then
          ghr_mto_int.log_message(
          p_procedure => 'RPA Exists Already',
          p_message   => 'Name: '|| l_name || ' - Salary Change ' ||
                         ' RPA Exists for the given effective date ' );
         return true;
      end if;

   end loop;
 end if; ------Bug 1631952
   return false;
end person_in_pa_req_1noa;

--


FUNCTION check_eligibility_mtc(p_pay_plan        in  varchar2,
                           p_person_id       in number,
                           p_effective_date  in date,
                           p_action          in varchar2)
return boolean is

l_proc         varchar2(72) :=  g_package || '.check_eligibility';

CURSOR cur_equiv_ES_pay_plan(p_pay_plan	ghr_pay_plans.pay_plan%TYPE)
IS
SELECT 1
FROM   ghr_pay_plans
WHERE  equivalent_pay_plan ='ES'
AND    pay_plan=p_pay_plan;

BEGIN
  g_proc  := 'check_eligibility';
  hr_utility.set_location('Entering    ' || l_proc,5);

--- MSL percentage changes Madhuri
---

FOR es_rec  IN cur_equiv_ES_pay_plan(p_pay_plan)
LOOP
 RETURN FALSE;
END LOOP;

IF p_pay_plan NOT IN ('AD','AL','GG','GH','GM','GS','IP',
                      'FB','FG','FJ','FM','FX','CA','AA','SL','ST','EE') THEN
 RETURN FALSE;
END IF;

 ---Filtering the pay plans which need not
 ---be picked for Locality Adjustment.

   IF p_action = 'CREATE' THEN
      IF person_in_pa_req_1noa_mtc
          (p_person_id      => p_person_id,
           p_effective_date => p_effective_date,
           p_first_noa_code => '894',
           p_pay_plan       => p_pay_plan
           ) then
           ghr_mre_pkg.pr('1noa failed',to_char(p_person_id));
           RETURN FALSE;
      ELSE
           ghr_mre_pkg.pr('Eligible');
           RETURN TRUE;
      END IF;
  END IF;

  RETURN TRUE;
exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
END check_eligibility_mtc;

--
--
--

function person_in_pa_req_1noa_mtc
          (p_person_id      in number,
           p_effective_date in date,
           p_first_noa_code in varchar2,
           p_pay_plan       in varchar2,
           p_days           in number default 350
           )
  return boolean is
--
  l_name            per_people_f.full_name%type;
  l_pa_request_id   ghr_pa_requests.pa_request_id%TYPE;

  cursor csr_action_taken is
      select pr.pa_request_id, max(pa_routing_history_id) pa_routing_history_id
        from ghr_pa_requests pr, ghr_pa_routing_history prh
      where pr.pa_request_id = prh.pa_request_id
      and   person_id = p_person_id
      and   (first_noa_code = p_first_noa_code or first_noa_code = '800')
      and   effective_date = p_effective_date
      and nvl(pr.first_noa_cancel_or_correct,'X') <> ghr_history_api.g_cancel
      group by pr.pa_request_id;

    cursor csr_name is
    select substr(pr.employee_last_name || ', ' || pr.employee_first_name,1,240) fname
    from ghr_pa_requests pr
    where pr.pa_request_id = l_pa_request_id;

  cursor csr_action_taken_fw is
      select pr.pa_request_id, max(pa_routing_history_id) pa_routing_history_id
        from ghr_pa_requests pr, ghr_pa_routing_history prh
      where pr.pa_request_id = prh.pa_request_id
      and   person_id        = p_person_id
      and   (first_noa_code = p_first_noa_code or first_noa_code = '800')
      and   effective_date   = p_effective_date
      and nvl(pr.first_noa_cancel_or_correct,'X') <> ghr_history_api.g_cancel
      group by pr.pa_request_id;

  cursor csr_eq_pay_plan is
      SELECT equivalent_pay_plan
      FROM ghr_pay_plans
     WHERE pay_plan = p_pay_plan;

    cursor pa_hist_cur (p_r_hist_id number) is
      select nvl(action_taken,' ') action_taken
        from ghr_pa_routing_history
      where pa_routing_history_id = p_r_hist_id;

  l_action_taken    ghr_pa_routing_history.action_taken%TYPE;
  l_proc     varchar2(72) :=  g_package || '.person_in_pa_req_1noa';
  l_eq_pay_plan     ghr_pay_plans.equivalent_pay_plan%type;

begin
  g_proc  := 'person_in_pa_req_1noa';
  hr_utility.set_location('Entering    ' || l_proc,5);
-- Bug 1631952 start

   for csr_eq_pay_plan_rec in csr_eq_pay_plan loop
      l_eq_pay_plan := csr_eq_pay_plan_rec.equivalent_pay_plan;
   end loop;

 if l_eq_pay_plan = 'FW' then
   for v_action_taken_fw in csr_action_taken_fw loop
       l_pa_request_id := v_action_taken_fw.pa_request_id;
       for v_name in csr_name
       loop
           l_name := v_name.fname;
       exit;
       end loop;
       for pa_hist_rec in pa_hist_cur (v_action_taken_fw.pa_routing_history_id)
       loop
           l_action_taken := pa_hist_rec.action_taken;
           exit;
       end loop;
      if l_action_taken <> 'CANCELED' then
          ghr_mto_int.log_message(
          p_procedure => 'RPA Exists Already',
          p_message   => 'Name: '|| l_name || ' - Mass Table Change ' ||
                         ' RPA Exists for the given FWS pay_lan and effective date' );
         return true;
      end if;
   end loop;
 else
--- Bug 1631952 end.  The same bug was extended to GS equvalent pay plans.
   for v_action_taken in csr_action_taken loop
       l_pa_request_id := v_action_taken.pa_request_id;
       for v_name in csr_name
       loop
           l_name := v_name.fname;
       exit;
       end loop;
       for pa_hist_rec in pa_hist_cur (v_action_taken.pa_routing_history_id)
       loop
           l_action_taken := pa_hist_rec.action_taken;
           exit;
       end loop;
      if l_action_taken <> 'CANCELED' then
          ghr_mto_int.log_message(
          p_procedure => 'RPA Exists Already',
          p_message   => 'Name: '|| l_name || ' - Mass Table Change ' ||
                         ' RPA Exists for the given effective date ' );
         return true;
      end if;

   end loop;
 end if;
   return false;
end person_in_pa_req_1noa_mtc;

--
--

FUNCTION check_grade_retention(p_prd in varchar2
                              ,p_person_id in number
                              ,p_effective_date in date) return varchar2 is

l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
l_per_ei_data         per_people_extra_info%rowtype;

l_proc  varchar2(72) :=  g_package || '.check_grade_retention';

begin
  g_proc  := 'check_grade_retention';
  hr_utility.set_location('Entering    ' || l_proc,5);
  if p_prd in ('A','B','E','F','U','V') then
     if p_prd in ('A','B','E','F') then
        BEGIN
           l_retained_grade_rec :=
                   ghr_pc_basic_pay.get_retained_grade_details
                                      ( p_person_id,
                                        p_effective_date);
	           if l_retained_grade_rec.temp_step is not null then
		      return 'REGULAR';
	           end if;
		-- Bug 3315432 Need to write into process log if retained grade record is expired
        EXCEPTION
            WHEN GHR_PAY_CALC.PAY_CALC_MESSAGE THEN
				 raise mlc_error;
			WHEN OTHERS THEN
                raise;
        END;
     end if;
     return 'RETAIN';
  ELSE
       return 'REGULAR';
  END IF;
exception
  when mlc_error then
      RETURN 'MLC_ERROR';
  when others then
     RETURN 'OTHER_ERROR';
END CHECK_GRADE_RETENTION;

--
--
--

procedure get_pos_grp1_ddf (p_position_id in per_assignments_f.position_id%type,
                            p_effective_date in date,
                            p_pos_ei_data     out nocopy per_position_extra_info%rowtype)
IS

l_proc  varchar2(72) :=  g_package || '.get_pos_grp1_ddf';
--l_pos_ei_data         per_position_extra_info%type;

begin
  g_proc  := 'get_pos_grp1_ddf';
  hr_utility.set_location('Entering    ' || l_proc,5);
     ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_GRP1'
                  ,p_date_effective        => p_effective_date
                  ,p_pos_ei_data           => p_pos_ei_data
                                        );
     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
END get_pos_grp1_ddf;

--
--
--

procedure get_from_sf52_data_elements (p_assignment_id in number,
                                       p_effective_date in date,
                                       p_old_basic_pay out nocopy number,
                                       p_old_avail_pay out nocopy number,
                                       p_old_loc_diff out nocopy number,
                                       p_tot_old_sal out nocopy number,
                                       p_old_auo_pay out nocopy number,
                                       p_old_adj_basic_pay out nocopy number,
                                       p_other_pay out nocopy number,
                                       p_auo_premium_pay_indicator out nocopy varchar2,
                                       p_ap_premium_pay_indicator out nocopy varchar2,
                                       p_retention_allowance out nocopy number,
                                       p_retention_allow_perc out nocopy number,
                                       p_supervisory_differential out nocopy number,
                                       p_supervisory_diff_perc out nocopy number,
                                       p_staffing_differential out nocopy number) is

  l_multi_error_flag    boolean;
  l_total_salary        number;
  l_basic_pay           number;
  l_locality_adj        number;
  l_adj_basic_pay       number;
  l_other_pay           number;
  l_au_overtime               NUMBER;
  l_auo_premium_pay_indicator VARCHAR2(30);
  l_availability_pay          NUMBER;
  l_ap_premium_pay_indicator  VARCHAR2(30);
  l_retention_allowance       NUMBER;
  l_retention_allow_perc      NUMBER;
  l_supervisory_differential  NUMBER;
  l_supervisory_diff_perc     NUMBER;
  l_staffing_differential     NUMBER;
l_proc   varchar2(72) :=  g_package || '.get_from_sf52_data_elements';

BEGIN

  g_proc  := 'get_from_sf52_data_elements';
  hr_utility.set_location('Entering    ' || l_proc,5);

-- Processing Total Pay and Adjusted Basic Pay
-- NAME    DATE       BUG           COMMENTS
-- Ashley  17-JUL-03  Payroll Intg  Modified the Input Value name
--                                  Changes from Total Salary -> Amount
--                                               Adjusted Pay -> Amount

  ghr_api.retrieve_element_entry_value
                       (p_element_name    => 'Total Pay'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_total_salary
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Total Pay = ' || to_char(l_total_salary), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Basic Salary Rate'
                       ,p_input_value_name      => 'Rate'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_basic_pay
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Basic Salary Rate = ' || to_char(l_basic_pay), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

 ghr_api.retrieve_element_entry_value
                       (p_element_name   => 'Locality Pay or SR Supplement'
                       ,p_input_value_name      => 'Rate'
-- Changed by Ashu. 'Amount' to 'Rate'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_locality_adj
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Locality Pay = ' || to_char(l_locality_adj), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Adjusted Basic Pay'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_adj_basic_pay
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Adjusted Basic Pay = ' || to_char(l_adj_basic_pay), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Other Pay'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_other_pay
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Other Pay = ' || to_char(l_other_pay), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'AUO'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_au_overtime
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('AUO Amount = ' || to_char(l_au_overtime), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'AUO'
                       ,p_input_value_name      => 'Premium Pay Ind'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_auo_premium_pay_indicator
                       ,p_multiple_error_flag   => l_multi_error_flag);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Availability Pay'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_availability_pay
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Availability Pay Amount = ' || to_char(l_availability_pay), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Availability Pay'
                       ,p_input_value_name      => 'Premium Pay Ind'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_ap_premium_pay_indicator
                       ,p_multiple_error_flag   => l_multi_error_flag);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --
  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Retention Allowance'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_retention_allowance
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Retention Allowance Amount = ' || to_char(l_retention_allowance), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Retention Allowance'
                       ,p_input_value_name      => 'Percentage'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_retention_allow_perc
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Retention Allowance Percent = ' || to_char(l_retention_allow_perc), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name    => 'Supervisory Differential'
                       ,p_input_value_name      => 'Amount'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_supervisory_differential
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Supervisory Diff Amount = ' || to_char(l_supervisory_differential), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  ghr_api.retrieve_element_entry_value
                       (p_element_name    => 'Supervisory Differential'
                       ,p_input_value_name      => 'Percentage'
                       ,p_assignment_id         => p_assignment_id
                       ,p_effective_date        => p_effective_date
                       ,p_value                 => l_supervisory_diff_perc
                       ,p_multiple_error_flag   => l_multi_error_flag);

  hr_utility.set_location('Supervisory Diff Percent = ' || to_char(l_supervisory_diff_perc), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

 --
 --
  ghr_api.retrieve_element_entry_value
                       (p_element_name  => 'Staffing Differential'
                       ,p_input_value_name    => 'Amount'
                       ,p_assignment_id       => p_assignment_id
                       ,p_effective_date      => p_effective_date
                       ,p_value               => l_staffing_differential
                       ,p_multiple_error_flag => l_multi_error_flag);

  hr_utility.set_location('Staffing Diff Amount = ' || to_char(l_staffing_differential), 6);

  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;

  p_tot_old_sal               := round(l_total_salary,2);
  p_OLD_BASIC_PAY             := round(l_basic_pay,2);
  p_OLD_LOC_DIFF              := round(l_locality_adj,0);
  p_old_adj_basic_pay         := round(l_adj_basic_pay,2);
  p_other_pay                 := l_other_pay;
  p_OLD_AUO_PAY               := l_au_overtime;
  p_auo_premium_pay_indicator := l_auo_premium_pay_indicator;
  p_OLD_AVAIL_PAY             := l_availability_pay;
  p_ap_premium_pay_indicator  := l_ap_premium_pay_indicator;
  p_retention_allowance       := l_retention_allowance;
  p_retention_allow_perc      := l_retention_allow_perc;
  p_supervisory_differential  := l_supervisory_differential;
  p_supervisory_diff_perc     := l_supervisory_diff_perc;
  p_staffing_differential     := l_staffing_differential;

  hr_utility.set_location('Exiting    ' || l_proc,10);

exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
END GET_FROM_SF52_DATA_ELEMENTS;

--
--
--

procedure get_sub_element_code_pos_title
               (p_position_id in per_assignments_f.position_id%type,
                p_person_id in number,
                p_business_group_id in per_assignments_f.business_group_id%type,
                p_assignment_id in per_assignments_f.assignment_id%type,
                p_effective_date in date,
                p_sub_element_code out nocopy varchar2,
                p_position_title   out nocopy varchar2,
                p_position_number   out nocopy varchar2,
                p_position_seq_no   out nocopy varchar2) is
l_proc     varchar2(72) :=  g_package || '.get_sub_element_code_pos_title';
begin
  g_proc  := 'get_sub_element_code_pos_title';
  hr_utility.set_location('Entering    ' || l_proc,5);
   p_sub_element_code := ghr_api.get_position_agency_code_pos
                   (p_position_id,p_business_group_id,p_effective_date);

   p_position_title := ghr_api.get_position_title_pos
	(p_position_id            => p_position_id
	,p_business_group_id      => p_business_group_id
        ,p_effective_date         => p_effective_date ) ;

--   if p_person_id is not null then
    p_position_number := ghr_api.get_position_description_no
	(p_person_id            => p_person_id
	,p_assignment_id        => p_assignment_id
	,p_effective_date       => p_effective_date
	);

   p_position_seq_no := ghr_api.get_position_sequence_no
	(p_person_id            => p_person_id
	,p_assignment_id        => p_assignment_id
	,p_effective_date       => p_effective_date
	);
 --  end if;

  hr_utility.set_location('Exiting    ' || l_proc,10);
end get_sub_element_code_pos_title;

--
-- Get all details for the reporting...
--

procedure get_other_dtls_for_rep(p_prd in varchar2,
                 p_first_lac2_information1 in varchar2,
                 p_first_lac2_information2 in varchar2,
                 p_first_action_la_code1 out nocopy varchar2,
                 p_first_action_la_code2 out nocopy varchar2,
                 p_remark_code1 out nocopy varchar2,
                 p_remark_code2 out nocopy varchar2
                 ) is
l_proc   varchar2(72) :=  g_package || '.get_other_dtls_for_rep';
BEGIN
  g_proc  := 'get_other_dtls_for_rep';
  hr_utility.set_location('Entering    ' || l_proc,5);
  p_first_action_la_code1  :=  'QWM';
  p_first_action_la_code2  :=  'ZLM';

/**
       If  p_prd in ('A','B','E','F') then -- retained grade
         p_first_action_la_code1  :=  'QWM';
         p_first_action_la_code2  :=  'ZLM';
         p_remark_code1           :=  'X44';
       Elsif p_prd in ('3','J','K') then   -- retained  pay
         p_first_action_la_code1  :=  'QWM';
         p_first_action_la_code2  :=  'ZLM';
         p_remark_code1           :=  'X40';
       Elsif p_prd in ('U','V') then    -- pay and grade
         p_first_action_la_code1  :=  'QWM';
         p_first_action_la_code2  :=  'ZLM';
         p_remark_code1         :=  'X40';
         p_remark_code2         :=  'X44';
       Else
         p_first_action_la_code1  :=  'QWM';
         p_first_action_la_code2  :=  'ZLM';
       End if;
*/

   hr_utility.set_location('Exiting    ' || l_proc,10);

exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
END get_other_dtls_for_rep;

--
--
--

procedure create_mass_act_prev (
 p_effective_date in date,
 p_date_of_birth in date,
 p_full_name in varchar2,
 p_national_identifier in varchar2,
 p_duty_station_code in varchar2,
 p_duty_station_desc in varchar2,
 p_personnel_office_id in varchar2,
 p_basic_pay       in number,
 p_new_basic_pay   in number,
  -- Bug#2383992
 p_adj_basic_pay       in number,
 p_new_adj_basic_pay   in number,
  -- Bug#2383992
 p_old_avail_pay   in number,
 p_new_avail_pay   in number,
 p_old_loc_diff    in number,
 p_new_loc_diff    in number,
 p_tot_old_sal     in number,
 p_tot_new_sal     in number,
 p_old_auo_pay     in number,
 p_new_auo_pay     in number,
 p_position_id in per_assignments_f.position_id%type,
 p_position_title in varchar2,
 -- FWFA Changes Bug#4444609
 p_position_number in varchar2,
 p_position_seq_no in varchar2,
-- FWFA Changes
 p_org_structure_id in varchar2,
 p_agency_sub_element_code in varchar2,
 p_person_id       in number,
 p_mass_salary_id  in number,
 p_sel_flg         in varchar2,
 p_first_action_la_code1 in varchar2,
 p_first_action_la_code2 in varchar2,
 p_remark_code1 in varchar2,
 p_remark_code2 in varchar2,
 p_grade_or_level in varchar2,
 p_step_or_rate in varchar2,
 p_pay_plan     in varchar2,
 p_pay_rate_determinant in varchar2,
 p_tenure in varchar2,
 p_action in varchar2,
 p_assignment_id in number,
 p_old_other_pay in number,
 p_new_other_pay in number,
 -- Bug#2383992
 p_old_capped_other_pay in number,
 p_new_capped_other_pay in number,
 p_old_retention_allowance in number,
 p_new_retention_allowance in number,
 p_old_supervisory_differential in number,
 p_new_supervisory_differential in number,
 p_organization_name   in varchar2,
 -- Bug#2383992
 -- FWFA ChangesBug#4444609
 p_input_pay_rate_determinant in varchar2,
 p_from_pay_table_id in number,
 p_to_pay_table_id   in number
 -- FWFA Changes
 )
is

 l_comb_rem varchar2(30);
 l_proc     varchar2(72) :=  g_package || '.create_mass_act_prev';

 l_cust_rec     ghr_mass_act_custom.ghr_mass_custom_out_rec_type;
 l_cust_in_rec  ghr_mass_act_custom.ghr_mass_custom_in_rec_type;
 l_poi_desc                   varchar2(80);
----Temp Promo Changes.
 l_step_or_rate  varchar2(30);
 l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
 l_check_grade_retention varchar2(30);
begin
  g_proc  := 'create_mass_act_prev';
  hr_utility.set_location('Entering    ' || l_proc,5);
  if p_remark_code2 is not null then
     l_comb_rem := p_remark_code1||', '||p_remark_code2;
  else
     l_comb_rem := p_remark_code1;
  end if;

  l_poi_desc := GHR_MRE_PKG.GET_POI_NAME (p_personnel_office_id);

  BEGIN
     l_cust_in_rec.person_id := p_person_id;
     l_cust_in_rec.position_id := p_position_id;
     l_cust_in_rec.assignment_id := p_assignment_id;
     l_cust_in_rec.national_identifier := p_national_identifier;
     l_cust_in_rec.mass_action_type := 'SALARY';
     l_cust_in_rec.mass_action_id := p_mass_salary_id;
     l_cust_in_rec.effective_date := p_effective_date;

     GHR_MASS_ACT_CUSTOM.pre_insert (
                       p_cust_in_rec => l_cust_in_rec,
                       p_cust_rec => l_cust_rec);

  exception
     when others then
     hr_utility.set_location('Error in Mass Act Custom '||
              'Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in Mass Act Custom '||
              'Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
  END;

  l_check_grade_retention := check_grade_retention(p_pay_rate_determinant,p_person_id,p_effective_date);

  l_step_or_rate := p_step_or_rate;

  IF p_pay_rate_determinant in ('A','B','E','F')  THEN
    IF l_check_grade_retention = 'REGULAR' THEN
     begin
          l_retained_grade_rec :=
            ghr_pc_basic_pay.get_retained_grade_details
                                      ( p_person_id,
                                        p_effective_date);
            if l_retained_grade_rec.temp_step is not null then
               l_step_or_rate := l_retained_grade_rec.temp_step;
            end if;
     exception
        when ghr_pay_calc.pay_calc_message THEN
             l_mlcerrbuf := ' Retained Grade record is invalid for this Employee ';
             raise mlc_error;
        when others then
             l_mlcerrbuf := 'Preview -  Others error in Get retained grade '||
                            'SQL Error is '|| sqlerrm(sqlcode);
             raise mlc_error;
     end;

  ELSIF l_check_grade_retention ='MLC_ERROR' THEN
       hr_utility.set_message(8301,'GHR_38927_MISSING_MA_RET_DET');
       raise mlc_error;
   ELSIF l_check_grade_retention = 'OTHER_ERROR' THEN
     l_mlcerrbuf := 'Others error in check_grade_retention function while fetching retained grade record. Please
                     verify the retained grade record';
      raise mlc_error;
   END IF;
  END IF;

insert into GHR_MASS_ACTIONS_PREVIEW
(
 mass_action_type,
 --report_type,
 ui_type,
 session_id,
 effective_date,
 employee_date_of_birth,
 full_name,
 national_identifier,
 duty_station_code,
 duty_station_desc,
 personnel_office_id,
 from_basic_pay,
 to_basic_pay,
   -- Bug#2383992
 from_adj_basic_pay       ,
 to_adj_basic_pay   ,
    -- Bug#2383992
 from_availability_pay,
 to_availability_pay,
 from_locality_adj,
 to_locality_adj,
 from_total_salary,
 to_total_salary,
 from_auo_pay,
 to_auo_pay,
 from_other_pay,
 to_other_pay,
  -- Bug#2383992
  from_capped_other_pay,
 to_capped_other_pay,
 from_retention_allowance,
 to_retention_allowance,
 from_supervisory_differential ,
 to_supervisory_differential ,
 -- Bug#2383992
 position_id,
 position_title,
 -- FWFA Changes Bug#4444609
 position_number,
 position_seq_no,
 -- FWFA Changes
 org_structure_id,
 agency_code,
 person_id,
 select_flag,
 first_noa_code,
 first_action_la_code1,
 first_action_la_code2,
 grade_or_level,
 step_or_rate,
 pay_plan,
 pay_rate_determinant,
 tenure,
 POI_DESC,
 organization_name,
 -- FWFA Changes Bug#4444609
 input_pay_rate_determinant,
 from_pay_table_identifier,
 to_pay_table_identifier,
 -- FWFA Changes
 USER_ATTRIBUTE1,
 USER_ATTRIBUTE2,
 USER_ATTRIBUTE3,
 USER_ATTRIBUTE4,
 USER_ATTRIBUTE5,
 USER_ATTRIBUTE6,
 USER_ATTRIBUTE7,
 USER_ATTRIBUTE8,
 USER_ATTRIBUTE9,
 USER_ATTRIBUTE10,
 USER_ATTRIBUTE11,
 USER_ATTRIBUTE12,
 USER_ATTRIBUTE13,
 USER_ATTRIBUTE14,
 USER_ATTRIBUTE15,
 USER_ATTRIBUTE16,
 USER_ATTRIBUTE17,
 USER_ATTRIBUTE18,
 USER_ATTRIBUTE19,
 USER_ATTRIBUTE20
)
values
(
 'SALARY',
 /*--decode(p_action,'REPORT',userenv('SESSIONID'),p_mass_realignment_id),*/
 decode(p_action,'SHOW','FORM','REPORT'),
 userenv('SESSIONID'),
 p_effective_date,
 p_date_of_birth,
 p_full_name,
 p_national_identifier,
 p_duty_station_code,
 p_duty_station_desc,
 p_personnel_office_id,
 p_basic_pay,
 p_new_basic_pay,
 -- Bug#2383992
 p_adj_basic_pay       ,
 p_new_adj_basic_pay   ,
 -- Bug#2383992
 p_old_avail_pay,
 p_new_avail_pay,
 p_old_loc_diff,
 p_new_loc_diff,
 p_tot_old_sal,
 p_tot_new_sal,
 p_old_auo_pay,
 p_new_auo_pay,
 p_old_other_pay,                 ----------- nvl(p_old_auo_pay,0)+ nvl(p_old_avail_pay,0),
 p_new_other_pay,                 ----------- nvl(p_new_auo_pay,0)+ nvl(p_new_avail_pay,0),
  -- Bug#2383992
 p_old_capped_other_pay,
 p_new_capped_other_pay,
 p_old_retention_allowance,
 p_new_retention_allowance,
 p_old_supervisory_differential ,
 p_new_supervisory_differential ,
 -- Bug#2383992
 p_position_id,
 p_position_title,
 -- FWFA Changes Bug#4444609
 p_position_number,
 p_position_seq_no,
 -- FWFA Changes
 p_org_structure_id,
 p_agency_sub_element_code,
 p_person_id,
 p_sel_flg,
 nvl(ghr_msl_pkg.g_first_noa_code,'895'),
 p_first_action_la_code1,
 p_first_action_la_code2,
 p_grade_or_level,
 l_step_or_rate,
 p_pay_plan,
 p_pay_rate_determinant,
 p_tenure,
 l_poi_desc,
 p_organization_name,
 -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant,
 p_from_pay_table_id,
 p_to_pay_table_id,
 -- FWFA Changes
 l_cust_rec.user_attribute1,
 l_cust_rec.user_attribute2,
 l_cust_rec.user_attribute3,
 l_cust_rec.user_attribute4,
 l_cust_rec.user_attribute5,
 l_cust_rec.user_attribute6,
 l_cust_rec.user_attribute7,
 l_cust_rec.user_attribute8,
 l_cust_rec.user_attribute9,
 l_cust_rec.user_attribute10,
 l_cust_rec.user_attribute11,
 l_cust_rec.user_attribute12,
 l_cust_rec.user_attribute13,
 l_cust_rec.user_attribute14,
 l_cust_rec.user_attribute15,
 l_cust_rec.user_attribute16,
 l_cust_rec.user_attribute17,
 l_cust_rec.user_attribute18,
 l_cust_rec.user_attribute19,
 l_cust_rec.user_attribute20
);

     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
   when mlc_error then raise;
   when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end create_mass_act_prev;

--


procedure create_mass_act_prev_mtc (
 p_effective_date in date,
 p_date_of_birth in date,
 p_full_name in varchar2,
 p_national_identifier in varchar2,
 p_duty_station_code in varchar2,
 p_duty_station_desc in varchar2,
 p_personnel_office_id in varchar2,
 p_basic_pay       in number,
 p_new_basic_pay   in number,
 p_adj_basic_pay       in number,
 p_new_adj_basic_pay   in number,
 p_old_avail_pay   in number,
 p_new_avail_pay   in number,
 p_old_loc_diff    in number,
 p_new_loc_diff    in number,
 p_tot_old_sal     in number,
 p_tot_new_sal     in number,
 p_old_auo_pay     in number,
 p_new_auo_pay     in number,
 p_position_id in per_assignments_f.position_id%type,
 p_position_title in varchar2,
 -- FWFA Changes Bug#4444609
 p_position_number in varchar2,
 p_position_seq_no in varchar2,
-- FWFA Changes
 p_org_structure_id in varchar2,
 p_agency_sub_element_code in varchar2,
 p_person_id       in number,
 p_mass_salary_id  in number,
 p_sel_flg         in varchar2,
 p_first_action_la_code1 in varchar2,
 p_first_action_la_code2 in varchar2,
 p_remark_code1 in varchar2,
 p_remark_code2 in varchar2,
 p_grade_or_level in varchar2,
 p_step_or_rate in varchar2,
 p_pay_plan     in varchar2,
 p_pay_rate_determinant in varchar2,
 p_tenure in varchar2,
 p_action in varchar2,
 p_assignment_id in number,
 p_old_other_pay in number,
 p_new_other_pay in number,
 p_old_capped_other_pay in number,
 p_new_capped_other_pay in number,
 p_old_retention_allowance in number,
 p_new_retention_allowance in number,
 p_old_supervisory_differential in number,
 p_new_supervisory_differential in number,
 p_organization_name   in varchar2,
 -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant in varchar2,
 p_from_pay_table_id in number,
 p_to_pay_table_id   in number
 -- FWFA Changes
 )
is

 l_comb_rem varchar2(30);
 l_proc     varchar2(72) :=  g_package || '.create_mass_act_prev';

 l_cust_rec     ghr_mass_act_custom.ghr_mass_custom_out_rec_type;
 l_cust_in_rec  ghr_mass_act_custom.ghr_mass_custom_in_rec_type;
 l_poi_desc                   varchar2(80);
----Temp Promo Changes.
 l_step_or_rate  varchar2(30);
 l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;
 l_check_grade_retention varchar2(30);
begin
  g_proc  := 'create_mass_act_prev';
  hr_utility.set_location('Entering    ' || l_proc,5);
  IF p_person_id is not null then
  if p_remark_code2 is not null then
     l_comb_rem := p_remark_code1||', '||p_remark_code2;
  else
     l_comb_rem := p_remark_code1;
  end if;

  l_poi_desc := GHR_MRE_PKG.GET_POI_NAME (p_personnel_office_id);

  BEGIN
     l_cust_in_rec.person_id := p_person_id;
     l_cust_in_rec.position_id := p_position_id;
     l_cust_in_rec.assignment_id := p_assignment_id;
     l_cust_in_rec.national_identifier := p_national_identifier;
     l_cust_in_rec.mass_action_type := 'SALARY';
     l_cust_in_rec.mass_action_id := p_mass_salary_id;
     l_cust_in_rec.effective_date := p_effective_date;

     GHR_MASS_ACT_CUSTOM.pre_insert (
                       p_cust_in_rec => l_cust_in_rec,
                       p_cust_rec => l_cust_rec);

  exception
     when others then
     hr_utility.set_location('Error in Mass Act Custom '||
              'Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in Mass Act Custom '||
              'Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
  END;

  l_check_grade_retention := check_grade_retention(p_pay_rate_determinant,p_person_id,p_effective_date);

  l_step_or_rate := p_step_or_rate;

  IF p_pay_rate_determinant in ('A','B','E','F')  THEN
    IF l_check_grade_retention = 'REGULAR' THEN
     begin
          l_retained_grade_rec :=
            ghr_pc_basic_pay.get_retained_grade_details
                                      ( p_person_id,
                                        p_effective_date);
            if l_retained_grade_rec.temp_step is not null then
               l_step_or_rate := l_retained_grade_rec.temp_step;
            end if;
     exception
        when ghr_pay_calc.pay_calc_message THEN
             l_mlcerrbuf := ' Retained Grade record is invalid for this Employee ';
             raise mlc_error;
        when others then
             l_mlcerrbuf := 'Preview -  Others error in Get retained grade '||
                            'SQL Error is '|| sqlerrm(sqlcode);
             raise mlc_error;
     end;

  ELSIF l_check_grade_retention ='MLC_ERROR' THEN
       hr_utility.set_message(8301,'GHR_38927_MISSING_MA_RET_DET');
       raise mlc_error;
   ELSIF l_check_grade_retention = 'OTHER_ERROR' THEN
     l_mlcerrbuf := 'Others error in check_grade_retention function while fetching retained grade record. Please
                     verify the retained grade record';
      raise mlc_error;
   END IF;
  END IF;
 END IF;
insert into GHR_MASS_ACTIONS_PREVIEW
(
 mass_action_type,
 --report_type,
 ui_type,
 session_id,
 effective_date,
 employee_date_of_birth,
 full_name,
 national_identifier,
 duty_station_code,
 duty_station_desc,
 personnel_office_id,
 from_basic_pay,
 to_basic_pay,
   -- Bug#2383992
 from_adj_basic_pay       ,
 to_adj_basic_pay   ,
    -- Bug#2383992
 from_availability_pay,
 to_availability_pay,
 from_locality_adj,
 to_locality_adj,
 from_total_salary,
 to_total_salary,
 from_auo_pay,
 to_auo_pay,
 from_other_pay,
 to_other_pay,
  -- Bug#2383992
  from_capped_other_pay,
 to_capped_other_pay,
 from_retention_allowance,
 to_retention_allowance,
 from_supervisory_differential ,
 to_supervisory_differential ,
 -- Bug#2383992
 position_id,
 position_title,
 -- FWFA Changes Bug#4444609
 position_number,
 position_seq_no,
 -- FWFA Changes
 org_structure_id,
 agency_code,
 person_id,
 select_flag,
 first_noa_code,
 first_action_la_code1,
 first_action_la_code2,
 grade_or_level,
 step_or_rate,
 pay_plan,
 pay_rate_determinant,
 tenure,
 POI_DESC,
 organization_name,
 -- FWFA Changes Bug#4444609
 input_pay_rate_determinant,
 from_pay_table_identifier,
 to_pay_table_identifier,
  -- FWFA Changes
 USER_ATTRIBUTE1,
 USER_ATTRIBUTE2,
 USER_ATTRIBUTE3,
 USER_ATTRIBUTE4,
 USER_ATTRIBUTE5,
 USER_ATTRIBUTE6,
 USER_ATTRIBUTE7,
 USER_ATTRIBUTE8,
 USER_ATTRIBUTE9,
 USER_ATTRIBUTE10,
 USER_ATTRIBUTE11,
 USER_ATTRIBUTE12,
 USER_ATTRIBUTE13,
 USER_ATTRIBUTE14,
 USER_ATTRIBUTE15,
 USER_ATTRIBUTE16,
 USER_ATTRIBUTE17,
 USER_ATTRIBUTE18,
 USER_ATTRIBUTE19,
 USER_ATTRIBUTE20
)
values
(
 'SALARY',
 /*--decode(p_action,'REPORT',userenv('SESSIONID'),p_mass_realignment_id),*/
 decode(p_action,'SHOW','FORM','REPORT'),
 userenv('SESSIONID'),
 p_effective_date,
 p_date_of_birth,
 p_full_name,
 p_national_identifier,
 p_duty_station_code,
 p_duty_station_desc,
 p_personnel_office_id,
 p_basic_pay,
 p_new_basic_pay,
 p_adj_basic_pay       ,
 p_new_adj_basic_pay   ,
 p_old_avail_pay,
 p_new_avail_pay,
 p_old_loc_diff,
 p_new_loc_diff,
 p_tot_old_sal,
 p_tot_new_sal,
 p_old_auo_pay,
 p_new_auo_pay,
 p_old_other_pay,
 p_new_other_pay,
 p_old_capped_other_pay,
 p_new_capped_other_pay,
 p_old_retention_allowance,
 p_new_retention_allowance,
 p_old_supervisory_differential ,
 p_new_supervisory_differential ,
 p_position_id,
 p_position_title,
 -- FWFA Changes Bug#4444609
 p_position_number,
 p_position_seq_no,
 -- FWFA Changes
 p_org_structure_id,
 p_agency_sub_element_code,
 p_person_id,
 p_sel_flg,
 decode(p_basic_pay,p_new_basic_pay,'800','894'),
 p_first_action_la_code1,
 p_first_action_la_code2,
 p_grade_or_level,
 l_step_or_rate,
 p_pay_plan,
 p_pay_rate_determinant,
 p_tenure,
 l_poi_desc,
 p_organization_name,
  -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant,
 p_from_pay_table_id,
 p_to_pay_table_id,
  -- FWFA Changes
 l_cust_rec.user_attribute1,
 l_cust_rec.user_attribute2,
 l_cust_rec.user_attribute3,
 l_cust_rec.user_attribute4,
 l_cust_rec.user_attribute5,
 l_cust_rec.user_attribute6,
 l_cust_rec.user_attribute7,
 l_cust_rec.user_attribute8,
 l_cust_rec.user_attribute9,
 l_cust_rec.user_attribute10,
 l_cust_rec.user_attribute11,
 l_cust_rec.user_attribute12,
 l_cust_rec.user_attribute13,
 l_cust_rec.user_attribute14,
 l_cust_rec.user_attribute15,
 l_cust_rec.user_attribute16,
 l_cust_rec.user_attribute17,
 l_cust_rec.user_attribute18,
 l_cust_rec.user_attribute19,
 l_cust_rec.user_attribute20
);

     hr_utility.set_location('Exiting    ' || l_proc,10);
exception
   when mlc_error then raise;
   when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end create_mass_act_prev_mtc;

--
--

procedure get_lac_dtls
            (p_pa_request_id  in number,
             p_sf52_rec       out nocopy ghr_pa_requests%rowtype) IS

l_proc varchar2(72) :=  g_package || '.get_lac_dtls';

cursor cur_pa_req_cur is
select * from ghr_pa_requests
 where pa_request_id = p_pa_request_id;

begin
  g_proc  := 'get_lac_dtls';
  hr_utility.set_location('Entering    ' || l_proc,5);

pr('Entering '||l_proc||' Pa req id ',to_char(p_pa_request_id));
if p_pa_request_id is null then
    pr('PA request id is null.................');
else

  for cur_pa_rec in cur_pa_req_cur
  loop
     p_sf52_rec := cur_pa_rec;
     exit;
  end loop;
end if;

  hr_utility.set_location('Exiting    ' || l_proc,10);
exception
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end get_lac_dtls;

--
--
--

procedure create_lac_remarks
            (p_pa_request_id  in number,
             p_new_pa_request_id  in number) is

l_proc varchar2(72) :=  g_package || '.create_lac_remarks';

cursor cur_pa_rem_cur is
select * from ghr_pa_remarks
 where pa_request_id = p_pa_request_id;

l_remarks_rec     ghr_pa_remarks%rowtype;

begin
  g_proc  := 'create_lac_remarks';
  hr_utility.set_location('Entering    ' || l_proc,5);

  pr('Inside '||l_proc,to_char(p_pa_request_id),to_char(p_new_pa_request_id));

    FOR CUR_PA_REM_rec in cur_pa_rem_cur
    loop

      l_remarks_rec := cur_pa_rem_rec;

pr('Rem id '||to_char(l_remarks_rec.remark_id));
    ghr_pa_remarks_api.create_pa_remarks
    (p_validate                 => false
    ,p_pa_request_id            => p_new_pa_request_id
    ,p_remark_id                => l_remarks_rec.remark_id
    ,p_description              => l_remarks_rec.description
    ,p_remark_code_information1 => l_remarks_rec.remark_code_information1
    ,p_remark_code_information2 => l_remarks_rec.remark_code_information2
    ,p_remark_code_information3 => l_remarks_rec.remark_code_information3
    ,p_remark_code_information4 => l_remarks_rec.remark_code_information4
    ,p_remark_code_information5 => l_remarks_rec.remark_code_information5
    ,p_pa_remark_id             => l_remarks_rec.pa_remark_id
    ,p_object_version_number    => l_remarks_rec.object_version_number
    );

  end loop;

  hr_utility.set_location('Exiting    ' || l_proc,10);

exception
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end create_lac_remarks;

--
--

procedure upd_ext_info_to_null(p_position_id in NUMBER, p_effective_DATE in DATE) is

   CURSOR POSITION_EXT_CUR (p_position NUMBER) IS
   SELECT position_extra_info_id, object_version_NUMBER
     from per_position_extra_info
    WHERE position_id = (p_position)
      and INFORMATION_TYPE = 'GHR_US_POS_MASS_ACTIONS';

   l_Position_EXTRA_INFO_ID         NUMBER;
   l_OBJECT_VERSION_NUMBER        NUMBER;
   l_eff_DATE                     DATE;

   l_pos_ei_data         per_position_extra_info%rowtype;
   l_proc    VARCHAR2(72) :=  g_package || '.upd_ext_info_api';
BEGIN

  g_proc := 'upd_ext_info_to_null';

  if p_effective_DATE > sysDATE then
       l_eff_DATE := sysDATE;
  ELSE
       l_eff_DATE := p_effective_DATE;
  END IF;

   ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_DATE_effective        => l_eff_DATE
		  ,p_pos_ei_data           => l_pos_ei_data);

   l_position_extra_info_id  := l_pos_ei_data.position_extra_info_id;
   l_object_version_NUMBER := l_pos_ei_data.object_version_NUMBER;

   if l_position_extra_info_id is not null then

----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;

       BEGIN

          ghr_position_extra_info_api.UPDATE_position_extra_info
                      (P_POSITION_EXTRA_INFO_ID   => l_position_extra_info_id
                      ,P_OBJECT_VERSION_NUMBER  => l_object_version_NUMBER
                      ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS'
                      ,P_EFFECTIVE_DATE             => l_eff_DATE
                      ,P_POEI_INFORMATION19       => null
                      ,P_POEI_INFORMATION20       => null
                      ,P_POEI_INFORMATION21       => null);

      EXCEPTION when others then
                hr_utility.set_location('UPDATE posei error 3' || l_proc,10);
                hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
      END;

----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;

   END IF;
END;
--
--
--
PROCEDURE assign_to_sf52_rec(
 p_person_id              in number,
 p_first_name             in varchar2,
 p_last_name              in varchar2,
 p_middle_names           in varchar2,
 p_national_identifier    in varchar2,
 p_date_of_birth          in date,
 p_effective_date         in date,
 p_assignment_id          in number,
 p_tenure                 in varchar2,
 p_step_or_rate           in varchar2,
 p_annuitant_indicator    in varchar2,
 p_pay_rate_determinant   in varchar2,
 p_work_schedule          in varchar2,
 p_part_time_hour         in varchar2,
 p_flsa_category          in varchar2,
 p_bargaining_unit_status in varchar2,
 p_functional_class       in varchar2,
 p_supervisory_status     in varchar2,
 p_basic_pay              in number,
 p_to_locality_adj        in number,
 p_to_adj_basic_pay       in number,
 p_to_total_salary        in number,
 p_from_other_pay_amount  in number,
 p_to_other_pay_amount    in number,
 p_to_au_overtime         in number,
 p_to_availability_pay    in number,
 p_to_retention_allowance in number,
 p_to_retention_allow_perce in number,
 p_to_supervisory_differential in number,
 p_to_supervisory_diff_perce in number,
 p_to_staffing_differential in number,
 p_duty_station_id        in number,
 p_duty_station_code      in ghr_pa_requests.duty_station_code%type,
 p_duty_station_desc      in ghr_pa_requests.duty_station_desc%type,
  -- FWFA Changes Bug#4444609
 p_input_pay_rate_determinant in ghr_pa_requests.input_pay_rate_determinant%type,
 p_from_pay_table_id       in ghr_pa_requests.from_pay_table_identifier%type,
 p_to_pay_table_id         in ghr_pa_requests.to_pay_table_identifier%type,
  -- FWFA Changes
 p_lac_sf52_rec           in ghr_pa_requests%rowtype,
 p_sf52_rec               out nocopy ghr_pa_requests%rowtype) IS

l_proc   varchar2(72) :=  g_package || '.assign_to_sf52_rec';
begin

  g_proc  := 'assign_to_sf52_rec';

  hr_utility.set_location('Entering    ' || l_proc,5);
 p_sf52_rec.person_id := p_person_id;
 p_sf52_rec.employee_first_name := p_first_name;
 p_sf52_rec.employee_last_name := p_last_name;
 p_sf52_rec.employee_middle_names := p_middle_names;
 p_sf52_rec.employee_national_identifier := p_national_identifier;
 p_sf52_rec.employee_date_of_birth := p_date_of_birth;
 p_sf52_rec.effective_date := p_effective_date;
 p_sf52_rec.employee_assignment_id := p_assignment_id;
 p_sf52_rec.tenure := p_tenure;
 p_sf52_rec.to_step_or_rate := p_step_or_rate;
 p_sf52_rec.annuitant_indicator  := p_annuitant_indicator;
 p_sf52_rec.pay_rate_determinant  := p_pay_rate_determinant;
 p_sf52_rec.work_schedule := p_work_schedule;
 p_sf52_rec.part_time_hours := p_part_time_hour;
 p_sf52_rec.flsa_category := p_flsa_category;
 p_sf52_rec.bargaining_unit_status := p_bargaining_unit_status;
 p_sf52_rec.functional_class := p_functional_class;
 p_sf52_rec.supervisory_status := p_supervisory_status;
 p_sf52_rec.to_basic_pay := p_basic_pay;
 p_sf52_rec.to_locality_adj := p_to_locality_adj;
 p_sf52_rec.to_adj_basic_pay := p_to_adj_basic_pay;
 p_sf52_rec.to_total_salary := p_to_total_salary;
 p_sf52_rec.from_other_pay_amount := p_from_other_pay_amount;
 p_sf52_rec.to_other_pay_amount := p_to_other_pay_amount;
 p_sf52_rec.to_au_overtime := p_to_au_overtime;
 p_sf52_rec.to_availability_pay := p_to_availability_pay;
 if p_to_retention_allowance = 0 or p_to_retention_allowance is null then
    p_sf52_rec.to_retention_allowance := null;
 else
    p_sf52_rec.to_retention_allowance := p_to_retention_allowance;
 end if;
 p_sf52_rec.to_retention_allow_percentage := p_to_retention_allow_perce;
 if p_to_supervisory_differential = 0 or p_to_supervisory_differential is null then
    p_sf52_rec.to_supervisory_differential := null;
 else
    p_sf52_rec.to_supervisory_differential := p_to_supervisory_differential;
 end if;
 p_sf52_rec.to_supervisory_diff_percentage := p_to_supervisory_diff_perce;
 p_sf52_rec.to_staffing_differential := p_to_staffing_differential;
 p_sf52_rec.duty_station_id := p_duty_station_id;
 p_sf52_rec.duty_station_code := p_duty_station_code;
 p_sf52_rec.duty_station_desc := p_duty_station_desc;
 -- FWFA Changes Bug#4444609
 p_sf52_rec.input_pay_rate_determinant := p_input_pay_rate_determinant;
 p_sf52_rec.from_pay_table_identifier  := p_from_pay_table_id;
 p_sf52_rec.to_pay_table_identifier    := p_to_pay_table_id;
 -- FWFA Changes
 p_sf52_rec.FIRST_LAC1_INFORMATION1 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION1;
 p_sf52_rec.FIRST_LAC1_INFORMATION2 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION2;
 p_sf52_rec.FIRST_LAC1_INFORMATION3 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION3;
 p_sf52_rec.FIRST_LAC1_INFORMATION4 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION4;
 p_sf52_rec.FIRST_LAC1_INFORMATION5 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION5;
 p_sf52_rec.SECOND_LAC1_INFORMATION1 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION1;
 p_sf52_rec.SECOND_LAC1_INFORMATION2 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION2;
 p_sf52_rec.SECOND_LAC1_INFORMATION3 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION3;
 p_sf52_rec.SECOND_LAC1_INFORMATION4 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION4;
 p_sf52_rec.SECOND_LAC1_INFORMATION5 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION5;
 p_sf52_rec.FIRST_ACTION_LA_CODE1 := p_lac_sf52_rec.FIRST_ACTION_LA_CODE1;
 p_sf52_rec.FIRST_ACTION_LA_CODE2 := p_lac_sf52_rec.FIRST_ACTION_LA_CODE2;
 p_sf52_rec.FIRST_ACTION_LA_DESC1 := p_lac_sf52_rec.FIRST_ACTION_LA_DESC1;
 p_sf52_rec.FIRST_ACTION_LA_DESC2 := p_lac_sf52_rec.FIRST_ACTION_LA_DESC2;

     hr_utility.set_location('Exiting    ' || l_proc,10);

exception
  when mlc_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end assign_to_sf52_rec;

--
--
--

procedure ins_upd_pos_extra_info
               (p_position_id    in NUMBER,
	        p_effective_DATE in DATE,
                p_sel_flag       in VARCHAR2,
		p_comment        in VARCHAR2,
                p_msl_id         in NUMBER) is

   l_position_extra_info_id NUMBER;
   l_object_version_NUMBER NUMBER;
   l_pos_ei_data         per_position_extra_info%rowtype;

   CURSOR position_ext_cur (position NUMBER) is
   SELECT position_extra_info_id, object_version_NUMBER
     FROM PER_POSITION_EXTRA_INFO
    WHERE POSITION_ID = position
      and information_type = 'GHR_US_POS_MASS_ACTIONS';

l_proc    VARCHAR2(72) :=  g_package || '.ins_upd_pos_extra_info';
    l_eff_DATE DATE;

BEGIN
  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'ins_upd_pos_extra_info';

  if p_effective_DATE > sysDATE then
       l_eff_DATE := sysDATE;
  ELSE
       l_eff_DATE := p_effective_DATE;
  END IF;

   ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_DATE_effective        => l_eff_DATE
                  ,p_pos_ei_data           => l_pos_ei_data);

   l_position_extra_info_id  := l_pos_ei_data.position_extra_info_id;
   l_object_version_NUMBER := l_pos_ei_data.object_version_NUMBER;

   IF l_position_extra_info_id is null then
      for pos_ext_rec in position_ext_cur(p_position_id)
      loop
         l_position_extra_info_id  := pos_ext_rec.position_extra_info_id;
         l_object_version_NUMBER := pos_ext_rec.object_version_NUMBER;
      END loop;
   END IF;

   if l_position_extra_info_id is not null then

----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;

      BEGIN
        ghr_position_extra_info_api.UPDATE_position_extra_info
                       (P_POSITION_EXTRA_INFO_ID   => l_position_extra_info_id
                       ,P_EFFECTIVE_DATE           => trunc(l_eff_DATE)
                       ,P_OBJECT_VERSION_NUMBER    => l_object_version_NUMBER
                       ,p_poei_INFORMATION19        => p_sel_flag
                       ,p_poei_INFORMATION20        => p_comment
                       ,p_poei_INFORMATION21       => to_char(p_msl_id)
                       ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS');
      EXCEPTION when others then
                hr_utility.set_location('UPDATE posei error 1' || l_proc,10);
                hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
      END;
----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;

   ELSE
        ghr_position_extra_info_api.create_position_extra_info
                       (P_POSITION_ID             => p_position_id
                       ,P_INFORMATION_TYPE        => 'GHR_US_POS_MASS_ACTIONS'
                       ,P_EFFECTIVE_DATE          => trunc(l_eff_DATE)
                       ,p_poei_INFORMATION19      => p_sel_flag
                       ,p_poei_INFORMATION20      => p_comment
                       ,p_poei_INFORMATION21       => to_char(p_msl_id)
                       ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS'
                       ,P_POSITION_EXTRA_INFO_ID  => l_position_extra_info_id
                       ,P_OBJECT_VERSION_NUMBER   => l_object_version_NUMBER);
   END IF;
     hr_utility.set_location('Exiting    ' || l_proc,30);

EXCEPTION
  when mtc_error  then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mtc_error ;
END ins_upd_pos_extra_info;


PROCEDURE get_extra_info_comments_pos
                (p_position_id     in NUMBER,
                 p_effective_DATE  in DATE,
                 p_sel_flag        in out NOCOPY VARCHAR2,
                 p_comments        in out NOCOPY VARCHAR2,
                 p_msl_id          in out NOCOPY NUMBER) IS

  l_sel_flag           VARCHAR2(30);
  l_comments           VARCHAR2(4000);
  l_msl_id             NUMBER;
  l_pos_ei_data        per_position_extra_info%rowtype;
  l_proc  VARCHAR2(72) := g_package || '.get_extra_info_comments';
  l_eff_DATE DATE;
  l_char_msl_id VARCHAR2(30);

BEGIN
  g_proc := 'get_extra_info_comments';
    hr_utility.set_location('Entering    ' || l_proc,5);
    pr('In '||l_proc);

    -- Initialization for NOCOPY Changes
    l_sel_flag     := p_sel_flag;
    l_comments     := p_comments;
    l_msl_id       := p_msl_id;
    --
    l_eff_DATE := p_effective_DATE;

   pr(l_proc||'---> before fetch pos ei');

     ghr_history_fetch.fetch_positionei
                  (p_position_id             => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_DATE_effective        => l_eff_DATE
                  ,p_pos_ei_data           => l_pos_ei_data);

   pr(l_proc||'---> after fetch pos ei');

    l_sel_flag := l_pos_ei_data.poei_information19;

   pr(l_proc||'---> after sel_flg assignment');
    l_comments := l_pos_ei_data.poei_information20;
   pr(l_proc||'---> after comments  assignment');
    l_char_msl_id := l_pos_ei_data.poei_information21;
   pr(l_proc||'---> after l_msl_id  assignment');
    l_msl_id := to_NUMBER(l_char_msl_id);
   pr(l_proc||'---> after p_msl_id  assignment');

    p_sel_flag     := l_sel_flag;
    p_comments     := l_comments;
    p_msl_id       := l_msl_id;

    pr('position ext id',to_char(l_pos_ei_data.position_extra_info_id),
                  to_char(l_pos_ei_data.object_version_NUMBER));
EXCEPTION
  when mtc_error then raise;
  when others then
  -- NOCOPY Changes
  -- Reset INOUT Params and set OUT params
  --
    p_sel_flag     := l_sel_flag;
    p_comments     := l_comments;
    p_msl_id       := l_msl_id;
  --
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||' Sql Err is '|| sqlerrm(sqlcode);
     raise mtc_error;
END get_extra_info_comments_pos;


procedure check_select_flg_pos(p_position_id    in NUMBER,
                              p_action         in VARCHAR2,
                              p_effective_DATE in DATE,
                              p_msl_id         in NUMBER,
                              p_sel_flg        in OUT NOCOPY VARCHAR2)
IS

l_comments   VARCHAR2(150);
l_msl_id     NUMBER;
l_sel_flg    VARCHAR2(10);
l_line       NUMBER := 0;

l_proc  VARCHAR2(72) :=  g_package || '.check_select_flg';

BEGIN
  g_proc := 'check_SELECT_flg';

  --Initilization for NOCOPY Changes
  --
  l_sel_flg := p_sel_flg;
  --
   hr_utility.set_location('Entering    ' || l_proc,5);
   pr('in '||l_proc);
  --
l_line := 5;
   get_extra_info_comments_pos(p_position_id,p_effective_DATE,l_sel_flg,l_comments,l_msl_id);

   pr('After get ext ');
   pr('Sel flg ',l_sel_flg,'msl id '||to_char(l_msl_id));
   pr('After pr sel fl');
   p_sel_flg := l_sel_flg;

l_line := 10;
   if l_sel_flg is null then
      p_sel_flg := 'Y';
   ELSIF l_sel_flg = 'Y' then
         if nvl(l_msl_id,0) <> nvl(p_msl_id,0) then
            p_sel_flg := 'N';
         END IF;
   ELSIF l_sel_flg = 'N' then
         if nvl(l_msl_id,0) <> nvl(p_msl_id,0) then
            p_sel_flg := 'Y';
         END IF;
   END IF;

EXCEPTION
  when mtc_error then raise;
  when others then
     -- NOCOPY Changes
     -- Reset IN OUT params and Set OUT params to null
     p_sel_flg := l_sel_flg;
     --
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in '||l_proc||' @'||to_char(l_line)||' Sql Err is '|| sqlerrm(sqlcode);

     raise mtc_error;
END check_select_flg_pos;


procedure position_history_update (p_position_id    IN hr_positions_f.position_id%type,
                                   p_effective_date IN date,
                                   p_table_id       IN pay_user_tables.user_table_id%type,
                                   p_upd_tableid    IN pay_user_tables.user_table_id%type)
is

CURSOR cur_hist_rows(l_tab_id NUMBER,l_eff_date date, l_pos_id NUMBER)
IS

SELECT pah.pa_history_id,
       pah.information4 , -- position_id
       to_number(pah.information11) user_tab_id,
       pah.effective_date
FROM   ghr_pa_history pah
WHERE  pah.table_name    = 'PER_POSITION_EXTRA_INFO'
AND    pah.information5  = 'GHR_US_POS_VALID_GRADE'
AND    to_number(pah.information4)  = l_pos_id
AND    to_number(pah.information11) = l_tab_id
AND    pah.effective_date >= to_date('2005/05/01','YYYY/MM/DD')
AND    pah.effective_date > l_eff_date
AND    to_number(pah.information4) in
       (SELECT position_id
        from   hr_positions_f pos
        WHERE  pos.position_id = to_number(pah.information4)
        AND    pah.effective_date
               between pos.effective_start_date and pos.effective_end_date
        AND    HR_GENERAL.DECODE_AVAILABILITY_STATUS(pos.availability_status_id) = 'Active');

l_hist_id                    ghr_pa_history.pa_history_id%type;
l_position_id                per_assignments_f.position_id%type;
l_his_eff_date               ghr_pa_requests.effective_date%type;
l_user_tab_id                pay_user_tables.user_table_id%type;


begin
        FOR hist_rec IN cur_hist_rows(p_table_id,p_effective_date,p_position_id)
        LOOP

            l_hist_id       := hist_rec.pa_history_id;
            l_position_id   := hist_rec.information4;
            l_his_eff_date  := hist_rec.effective_date;
            l_user_tab_id   := hist_rec.user_tab_id;


            UPDATE GHR_PA_HISTORY  upah
            SET    information11 = to_char(p_upd_tableid)
            WHERE  pa_history_id = l_hist_id;

       END LOOP;
end position_history_update;

procedure pr (msg varchar2,par1 in varchar2 default null,
            par2 in varchar2 default null) is
begin
--  g_no := g_no +1;
--  insert into l_tmp values (g_no,substr(msg||'-'||par1||' -'||par2||'-',1,199));
 -- DBMS_OUTPUT.PUT_LINE(msg||'-'||par1||' -'||par2||'-');

    ghr_mto_int.put_line(msg||'-'||par1||' -'||par2||'-');
exception
  when others then
     hr_utility.set_location('Error in pr '||' Err is '||sqlerrm(sqlcode),20);
     l_mlcerrbuf := 'Error in pr  Sql Err is '|| sqlerrm(sqlcode);
     raise mlc_error;
end;

END GHR_MLC_PKG;

/
