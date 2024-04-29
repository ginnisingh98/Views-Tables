--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_EHRIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_EHRIS" AS
/* $Header: ghrehris.pkb 120.34.12010000.6 2009/08/04 06:42:20 vmididho ship $ */

  g_duty_station_id            ghr_duty_stations_f.duty_station_id%TYPE;
  g_pay_table_name             varchar2(30);
  g_to_pay_plan                varchar2(30);
  g_retained_pay_table_name    varchar2(30);

  PROCEDURE initialize_record
  IS
    l_proc                        varchar2(30) := 'initialize_record';
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
    g_ghr_cpdf_temp.academic_discipline          := NULL;
    g_ghr_cpdf_temp.agency_code                  := NULL;
    g_ghr_cpdf_temp.annuitant_indicator          := NULL;
    g_ghr_cpdf_temp.award_amount                 := NULL;
    g_ghr_cpdf_temp.bargaining_unit_status       := NULL;
    g_ghr_cpdf_temp.benefit_amount               := NULL;
    g_ghr_cpdf_temp.citizenship                  := NULL;
    g_ghr_cpdf_temp.creditable_military_service  := NULL;
    g_ghr_cpdf_temp.current_appointment_auth1    := NULL;
    g_ghr_cpdf_temp.current_appointment_auth2    := NULL;
    g_ghr_cpdf_temp.to_duty_station_code         := NULL;
    g_ghr_cpdf_temp.education_level              := NULL;
    g_ghr_cpdf_temp.effective_date               := NULL;
    g_ghr_cpdf_temp.employee_date_of_birth       := NULL;
    g_ghr_cpdf_temp.employee_first_name          := NULL;
    g_ghr_cpdf_temp.employee_last_name           := NULL;
    g_ghr_cpdf_temp.employee_middle_names        := NULL;
    g_ghr_cpdf_temp.from_national_identifier     := NULL;
    g_ghr_cpdf_temp.fegli                        := NULL;
    g_ghr_cpdf_temp.fers_coverage                := NULL;
    g_ghr_cpdf_temp.first_action_la_code1        := NULL;
    g_ghr_cpdf_temp.first_action_la_code2        := NULL;
    g_ghr_cpdf_temp.first_noa_code               := NULL;
    g_ghr_cpdf_temp.flsa_category                := NULL;
    g_ghr_cpdf_temp.from_basic_pay               := NULL;
    g_ghr_cpdf_temp.from_duty_station_code       := NULL;
    g_ghr_cpdf_temp.from_grade_or_level          := NULL;
    g_ghr_cpdf_temp.from_locality_adj            := NULL;
    g_ghr_cpdf_temp.from_occ_code                := NULL;
    g_ghr_cpdf_temp.from_pay_table_id            := NULL;
    g_ghr_cpdf_temp.from_pay_basis               := NULL;
    g_ghr_cpdf_temp.from_pay_plan                := NULL;
    g_ghr_cpdf_temp.from_pay_rate_determinant    := NULL;
    g_ghr_cpdf_temp.from_retirement_coverage     := NULL;
    g_ghr_cpdf_temp.from_step_or_rate            := NULL;
    g_ghr_cpdf_temp.from_total_salary            := NULL;
    g_ghr_cpdf_temp.from_work_schedule           := NULL;
    g_ghr_cpdf_temp.frozen_service               := NULL;
    g_ghr_cpdf_temp.functional_class             := NULL;
    g_ghr_cpdf_temp.handicap_code                := NULL;
    g_ghr_cpdf_temp.health_plan                  := NULL;
    g_ghr_cpdf_temp.individual_group_award       := NULL;
    g_ghr_cpdf_temp.organizational_component     := NULL;
    g_ghr_cpdf_temp.pay_status                   := NULL;
    g_ghr_cpdf_temp.personnel_office_id          := NULL;
    g_ghr_cpdf_temp.position_occupied            := NULL;
    g_ghr_cpdf_temp.race_national_origin         := NULL;
    g_ghr_cpdf_temp.rating_of_record             := NULL;
    g_ghr_cpdf_temp.rating_of_record_level       := NULL;
    g_ghr_cpdf_temp.rating_of_record_pattern     := NULL;
    g_ghr_cpdf_temp.rating_of_record_period_starts := NULL;
    g_ghr_cpdf_temp.rating_of_record_period_ends := NULL;
    g_ghr_cpdf_temp.retained_grade_or_level      := NULL;
    g_ghr_cpdf_temp.retained_pay_plan            := NULL;
    g_ghr_cpdf_temp.retained_step_or_rate        := NULL;
    g_ghr_cpdf_temp.retirement_plan              := NULL;
    g_ghr_cpdf_temp.second_noa_code              := NULL;
    g_ghr_cpdf_temp.service_comp_date            := NULL;
    g_ghr_cpdf_temp.sex                          := NULL;
    g_ghr_cpdf_temp.supervisory_status           := NULL;
    g_ghr_cpdf_temp.tenure                       := NULL;
    g_ghr_cpdf_temp.to_basic_pay                 := NULL;
    g_ghr_cpdf_temp.to_grade_or_level            := NULL;
    g_ghr_cpdf_temp.to_locality_adj              := NULL;
    g_ghr_cpdf_temp.to_national_identifier       := NULL;
    g_ghr_cpdf_temp.to_occ_code                  := NULL;
    g_ghr_cpdf_temp.to_pay_basis                 := NULL;
    g_ghr_cpdf_temp.to_pay_plan                  := NULL;
    g_ghr_cpdf_temp.to_pay_rate_determinant      := NULL;
    g_ghr_cpdf_temp.to_pay_table_id              := NULL;
    g_ghr_cpdf_temp.to_retention_allowance       := NULL;
    g_ghr_cpdf_temp.to_staffing_differential     := NULL;
    g_ghr_cpdf_temp.to_step_or_rate              := NULL;
    g_ghr_cpdf_temp.to_supervisory_differential  := NULL;
    g_ghr_cpdf_temp.to_total_salary              := NULL;
    g_ghr_cpdf_temp.to_work_schedule             := NULL;
    g_ghr_cpdf_temp.veterans_preference          := NULL;
    g_ghr_cpdf_temp.veterans_status              := NULL;
    g_ghr_cpdf_temp.year_degree_attained         := NULL;
    g_duty_station_id                            := NULL;
    g_ghr_cpdf_temp.SCD_retirement               := NULL;
    g_ghr_cpdf_temp.SCD_rif                      := NULL;
    g_ghr_cpdf_temp.position_title		       := NULL;
    g_ghr_cpdf_temp.name_title			 := NULL;

    g_ghr_cpdf_temp.ehri_employee_id	       := NULL;
    g_ghr_cpdf_temp.agency_employee_id	       := NULL;
    g_ghr_cpdf_temp.world_citizenship	       := NULL;
    g_ghr_cpdf_temp.slct_serv_regi_indicator	 := NULL;
    g_ghr_cpdf_temp.svc_oblig_type_code1	       := NULL;
    g_ghr_cpdf_temp.svc_oblig_type_end_date1	 := NULL;
    g_ghr_cpdf_temp.svc_oblig_type_code2	       := NULL;
    g_ghr_cpdf_temp.svc_oblig_type_end_date2	 := NULL;
    g_ghr_cpdf_temp.svc_oblig_type_code3	       := NULL;
    g_ghr_cpdf_temp.svc_oblig_type_end_date3	 := NULL;
    g_ghr_cpdf_temp.svc_oblig_type_code4	       := NULL;
    g_ghr_cpdf_temp.svc_oblig_type_end_date4	 := NULL;
    g_ghr_cpdf_temp.appoint_type_code	       := NULL;
    g_ghr_cpdf_temp.part_time_hours	             := NULL;
    g_ghr_cpdf_temp.to_adj_basic_pay	       := NULL;
    g_ghr_cpdf_temp.spcl_pay_tbl_type	       := NULL;
    g_ghr_cpdf_temp.act_svc_indicator	       := NULL;
    g_ghr_cpdf_temp.appropriation_code	       := NULL;
    g_ghr_cpdf_temp.comp_pos_indicator	       := NULL;
    g_ghr_cpdf_temp.mil_char_svc_code	       := NULL;
    g_ghr_cpdf_temp.mil_svc_sno	             := NULL;
    g_ghr_cpdf_temp.mil_svc_start_date	       := NULL;
    g_ghr_cpdf_temp.mil_svc_end_date	       := NULL;
    g_ghr_cpdf_temp.mil_branch_code	             := NULL;
    g_ghr_cpdf_temp.mil_discharge_code	       := NULL;
    g_ghr_cpdf_temp.career_tenure_code	       := NULL;
    g_ghr_cpdf_temp.fegli_life_change_code	 := NULL;
    g_ghr_cpdf_temp.fegli_life_event_date	       := NULL;
    g_ghr_cpdf_temp.fegli_elect_date             := NULL;
    g_ghr_cpdf_temp.fehb_event_code	             := NULL;
    g_ghr_cpdf_temp.tsp_eligibility_date	       := NULL;
    g_ghr_cpdf_temp.tsp_effective_date	       := NULL;
    g_ghr_cpdf_temp.tsp_elect_contrib_pct	       := NULL;
    g_ghr_cpdf_temp.tsp_emp_amount	             := NULL;
    g_ghr_cpdf_temp.fers_elect_date	             := NULL;
    g_ghr_cpdf_temp.fers_elect_indicator	       := NULL;
    g_ghr_cpdf_temp.alb_indicator	             := NULL;
    g_ghr_cpdf_temp.alb_elect_date	             := NULL;
    g_ghr_cpdf_temp.alb_notify_date	             := NULL;
    g_ghr_cpdf_temp.fegli_indicator	             := NULL;
    g_ghr_cpdf_temp.fegli_elect_date	       := NULL;
    g_ghr_cpdf_temp.fegli_notify_date	       := NULL;
    g_ghr_cpdf_temp.fehb_indicator	             := NULL;
    --g_ghr_cpdf_temp.fehb_elect_date	             := NULL;
    g_ghr_cpdf_temp.fehb_notify_date	       := NULL;

     --bug#6158983
    g_ghr_cpdf_temp.fehb_elect_eff_date              := NULL;
    g_ghr_cpdf_temp.appointment_nte_date            := NULL;
     --end of 6158983
    g_ghr_cpdf_temp.retire_indicator	       := NULL;
    g_ghr_cpdf_temp.retire_elect_date	       := NULL;
    g_ghr_cpdf_temp.retire_notify_date	       := NULL;
    g_ghr_cpdf_temp.cont_elect_date	             := NULL;
    g_ghr_cpdf_temp.cont_notify_date	       := NULL;
    g_ghr_cpdf_temp.cont_term_elect_date	       := NULL;
    g_ghr_cpdf_temp.cont_ins_pay_notify_date	 := NULL;
    g_ghr_cpdf_temp.cont_pay_type_code	       := NULL;
    g_ghr_cpdf_temp.scd_ses	                   := NULL;
    g_ghr_cpdf_temp.scd_spcl_retire              := NULL;
    g_ghr_cpdf_temp.leave_scd	                   := NULL;
    g_ghr_cpdf_temp.tsp_scd	                   := NULL;
    g_ghr_cpdf_temp.disability_retire_notify	 := NULL;
    g_ghr_cpdf_temp.work_address_line1           := NULL;
    g_ghr_cpdf_temp.work_address_line2	       := NULL;
    g_ghr_cpdf_temp.work_address_line3           := NULL;
    g_ghr_cpdf_temp.work_address_line4           := NULL;
    g_ghr_cpdf_temp.work_city	                   := NULL;
    g_ghr_cpdf_temp.work_region	                 := NULL; --Bug# 4725292
    g_ghr_cpdf_temp.work_state_code	             := NULL;
    g_ghr_cpdf_temp.work_postal_code	       := NULL;
    g_ghr_cpdf_temp.work_country_code	       := NULL;
    g_ghr_cpdf_temp.work_employee_email	       := NULL;
    g_ghr_cpdf_temp.work_phone_number	       := NULL;
    g_ghr_cpdf_temp.home_phone_number	       := NULL;
    g_ghr_cpdf_temp.cell_phone_number	       := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_family_name1	 := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_given_name1	 := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_middle_name1	 := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_suffix1	       := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_infrm_upd_dt1	 := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_phone1	       := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_family_name2	 := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_given_name2	 := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_middle_name2	 := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_suffix2	       := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_infrm_upd_dt2	 := NULL;
    g_ghr_cpdf_temp.emrgncy_cntct_phone2	       := NULL;
    g_ghr_cpdf_temp.language_code1	             := NULL;
    g_ghr_cpdf_temp.lang_prof_type1	             := NULL;
    g_ghr_cpdf_temp.lang_prof_level1	       := NULL;
    g_ghr_cpdf_temp.language_code2	             := NULL;
    g_ghr_cpdf_temp.lang_prof_type2	             := NULL;
    g_ghr_cpdf_temp.lang_prof_level2	       := NULL;
    g_ghr_cpdf_temp.language_code3	             := NULL;
    g_ghr_cpdf_temp.lang_prof_type3	             := NULL;
    g_ghr_cpdf_temp.lang_prof_level3	       := NULL;
    g_ghr_cpdf_temp.language_code4	             := NULL;
    g_ghr_cpdf_temp.lang_prof_type4	             := NULL;
    g_ghr_cpdf_temp.lang_prof_level4	       := NULL;
    g_ghr_cpdf_temp.language_code5	             := NULL;
    g_ghr_cpdf_temp.lang_prof_type5	             := NULL;
    g_ghr_cpdf_temp.lang_prof_level5	       := NULL;
    g_ghr_cpdf_temp.language_code6	             := NULL;
    g_ghr_cpdf_temp.lang_prof_type6	             := NULL;
    g_ghr_cpdf_temp.lang_prof_level6	       := NULL;
    g_ghr_cpdf_temp.language_code7	             := NULL;
    g_ghr_cpdf_temp.lang_prof_type7	             := NULL;
    g_ghr_cpdf_temp.lang_prof_level7	       := NULL;
    g_ghr_cpdf_temp.language_code8	             := NULL;
    g_ghr_cpdf_temp.lang_prof_type8	             := NULL;
    g_ghr_cpdf_temp.lang_prof_level8	       := NULL;
    g_ghr_cpdf_temp.spcl_salary_rate             := NULL;
	g_ghr_cpdf_temp.race_ethnic_info			:= NULL;
	g_ghr_cpdf_temp.to_spl_rate_supplement		:= NULL;


  END initialize_record;

  PROCEDURE cleanup_table
  IS
    l_proc                        varchar2(30) := 'cleanup_table';
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
    DELETE FROM ghr_cpdf_temp
      WHERE report_type = 'STATUS'
      AND session_id  = userenv('SESSIONID');
  END cleanup_table;

  PROCEDURE get_appointment_date (p_person_id        IN  NUMBER
                                 ,p_report_date      IN  DATE
                                 ,p_appointment_date OUT NOCOPY DATE) IS

-- Cursor modified for Performance changes
/*  CURSOR cur_per IS
    SELECT per.hire_date
    FROM   per_people_v per
    WHERE  per.person_id = p_person_id;  */
	-- Bug 3742271, 3757124 - Added p_person_id in the following condition.
	CURSOR cur_per IS
	   SELECT
			DECODE(PER.CURRENT_EMPLOYEE_FLAG, 'Y', PPS.DATE_START,  DECODE(PER.CURRENT_NPW_FLAG, 'Y', PPP.DATE_START,  NULL)) hire_date
		FROM
			per_all_people PER ,
			PER_PERIODS_OF_SERVICE PPS ,
			PER_PERIODS_OF_PLACEMENT PPP
		WHERE
		PPS.PERSON_ID (+) = PER.PERSON_ID AND
		PPP.PERSON_ID (+) = PER.PERSON_ID AND
		PER.PERSON_ID = p_person_id AND
		(
		(PER.EMPLOYEE_NUMBER IS NULL) OR
		(PER.EMPLOYEE_NUMBER IS NOT NULL AND
		  PPS.DATE_START = (SELECT MAX(PPS1.DATE_START) FROM PER_PERIODS_OF_SERVICE PPS1 WHERE PPS1.PERSON_ID = PER.PERSON_ID AND
		  PPS1.DATE_START <= PER.EFFECTIVE_END_DATE))) AND
		((PER.NPW_NUMBER IS NULL) OR (PER.NPW_NUMBER IS NOT NULL AND
		  PPP.DATE_START = (SELECT MAX(PPP1.DATE_START) FROM PER_PERIODS_OF_PLACEMENT PPP1 WHERE PPP1.PERSON_ID = PER.PERSON_ID AND
		  PPP1.DATE_START <= PER.EFFECTIVE_END_DATE)));

   --
  BEGIN

    FOR cur_per_rec IN cur_per LOOP
      p_appointment_date := cur_per_rec.hire_date;
    END LOOP;

  END get_appointment_date;
  --
  PROCEDURE get_from_history_asgnei
            (
            p_sr_assignment_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS
    l_proc                        varchar2(30) := 'get_from_history_asgnei';
    l_ASGNEI_DATA                 PER_ASSIGNMENT_EXTRA_INFO%ROWTYPE;
    l_ASGNEI_DATA_INIT            PER_ASSIGNMENT_EXTRA_INFO%ROWTYPE;
    l_session                     ghr_history_api.g_session_var_type;
    l_extra_info_id               per_assignment_extra_info.assignment_extra_info_id%type;
    l_result                      varchar2(20);

  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    l_ASGNEI_DATA := l_ASGNEI_DATA_INIT;
	-- Begin Bug# 4753092
	g_message_name := 'Assignment EIT: Assigment RPA';
	-- End Bug# 4753092
    GHR_HISTORY_FETCH.fetch_asgei(
                       p_assignment_id    => p_sr_assignment_id,
                       p_information_type => 'GHR_US_ASG_SF52',
                       p_date_effective   => p_sr_report_date,
                       p_asg_ei_data      => l_ASGNEI_DATA
                                  );
    p_sr_ghr_cpdf_temp.annuitant_indicator       := l_ASGNEI_DATA.AEI_INFORMATION5;
    p_sr_ghr_cpdf_temp.to_step_or_rate           := l_ASGNEI_DATA.AEI_INFORMATION3;
    p_sr_ghr_cpdf_temp.to_pay_rate_determinant   := l_ASGNEI_DATA.AEI_INFORMATION6;
    p_sr_ghr_cpdf_temp.tenure                    := l_ASGNEI_DATA.AEI_INFORMATION4;
    p_sr_ghr_cpdf_temp.to_work_schedule          := l_ASGNEI_DATA.AEI_INFORMATION7;
    p_sr_ghr_cpdf_temp.part_time_hours       := l_ASGNEI_DATA.AEI_INFORMATION8;

    -- FWFA Changes Retrieved pay table id
    p_sr_ghr_cpdf_temp.to_pay_table_id := l_ASGNEI_DATA.AEI_INFORMATION9;
    --FWFA Changes



  END get_from_history_asgnei;

  PROCEDURE get_from_history_people
            (
            p_sr_person_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS

    -- JH EHRI Added Employee Number, Email Adress
    CURSOR PEOPLE_CUR IS
    SELECT SEX,
           DATE_OF_BIRTH,
           NATIONAL_IDENTIFIER,
           EMPLOYEE_NUMBER,
           EMAIL_ADDRESS

     FROM per_all_people
     WHERE (TRUNC(p_sr_report_date) between effective_start_date
                                    and effective_end_date)
     AND PERSON_ID = g_person_id;

     -- JH New EHRI Phones
     CURSOR cur_phones IS
     SELECT pho.phone_number, pho.phone_type
     FROM per_phones pho
     WHERE pho.parent_table = 'PER_ALL_PEOPLE_F'
     AND pho.parent_id = g_person_id
     AND pho.phone_type IN ('W1','H1','M');

     -- JH EHRI Get Emergeny Contacts
     CURSOR cur_contacts IS
     SELECT contact.last_name, contact.first_name, contact.middle_names, contact.suffix
     ,pho.phone_number, rel.date_start
     FROM per_contact_relationships_v2 rel
         ,per_all_people contact
         ,per_phones pho
     WHERE  rel.person_id = g_person_id
     AND    contact_type in ('EMRG','EC')
     AND    rel.contact_person_id = contact.person_id
     AND    p_sr_report_date between contact.effective_start_date AND contact.effective_end_date
     AND    p_sr_report_date BETWEEN NVL(rel.date_start,p_sr_report_date) AND NVL(rel.date_end,p_sr_report_date)
     AND    pho.parent_id(+) = contact.person_id
     AND    p_sr_report_date BETWEEN NVL(pho.date_from,p_sr_report_date) AND NVL(pho.date_to,p_sr_report_date)
     AND   ((pho.phone_type = 'M'
     AND NOT EXISTS (SELECT 1
                     FROM   per_phones pho2
                     WHERE  pho2.parent_id = pho.parent_id
                     AND    pho2.phone_type IN ('H1','W1')
                     )
             )
     OR    (pho.phone_type = 'W1'
     AND NOT EXISTS (SELECT 1
                     FROM   per_phones pho2
                     WHERE  pho2.parent_id = pho.parent_id
                     AND    pho2.phone_type = 'H1'
                     )
            )
     OR    (pho.phone_type = 'H1')
     OR    (pho.phone_type IS NULL)
          )
     ORDER BY DECODE(rel.primary_contact_flag,'P',0,rel.sequence_number);

     l_proc varchar2(30) := 'get_from_history_people';
     l_PEOPLE_REC        PEOPLE_CUR%ROWTYPE;
     l_contact_cnt       INTEGER;
     l_cnt               NUMBER := 0;
     l_suffix            GHR_CPDF_TEMP.emrgncy_cntct_suffix1%TYPE;
     l_last_name         per_all_people.last_name%type;


  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
	--Begin Bug# 4753092
	g_message_name := 'Fetch Person Details';
	--End Bug# 4753092

    OPEN PEOPLE_CUR;

    FETCH PEOPLE_CUR INTO l_PEOPLE_REC;

    IF PEOPLE_CUR%FOUND
    THEN
      p_sr_ghr_cpdf_temp.sex                     := l_PEOPLE_REC.SEX;
      p_sr_ghr_cpdf_temp.employee_date_of_birth  := l_PEOPLE_REC.DATE_OF_BIRTH;
      p_sr_ghr_cpdf_temp.to_national_identifier  :=
               SUBSTR(l_PEOPLE_REC.NATIONAL_IDENTIFIER,1,3) ||
               SUBSTR(l_PEOPLE_REC.NATIONAL_IDENTIFIER,5,2) ||
               SUBSTR(l_PEOPLE_REC.NATIONAL_IDENTIFIER,8,4);
      p_sr_ghr_cpdf_temp.agency_employee_id            := l_PEOPLE_REC.EMPLOYEE_NUMBER;
      p_sr_ghr_cpdf_temp.work_employee_email           := l_PEOPLE_REC.EMAIL_ADDRESS;

    END IF;

    CLOSE PEOPLE_CUR;

    -- JH EHRI get phones.
	--Begin Bug# 4753092
	g_message_name := 'Fetch Person:Contact Details';
	--End Bug# 4753092
    FOR cur_phones_rec IN cur_phones LOOP
     IF cur_phones_rec.phone_type = 'W1' THEN
       p_sr_ghr_cpdf_temp.work_phone_number   := cur_phones_rec.phone_number;
     ELSIF cur_phones_rec.phone_type = 'H1' THEN
       p_sr_ghr_cpdf_temp.home_phone_number   := cur_phones_rec.phone_number;
     ELSIF cur_phones_rec.phone_type = 'M' THEN
       p_sr_ghr_cpdf_temp.cell_phone_number := cur_phones_rec.phone_number;
     END IF;
    END LOOP;

    -- JH EHRI Emergency Contacts.
    l_contact_cnt := 0;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Person:Emrg Contact Dtls';
	--End Bug# 4753092
    FOR cur_contacts_rec IN cur_contacts LOOP
      l_contact_cnt := l_contact_cnt +1;

      IF l_contact_cnt = 1 THEN
        -- Bug# 4648811 extracting the suffix from the lastname and also removing suffix from lastname
        get_suffix_lname(p_last_name   => cur_contacts_rec.last_name,
                         p_report_date => p_sr_report_date,
                         p_suffix      => l_suffix,
                         p_lname       => l_last_name);
        p_sr_ghr_cpdf_temp.emrgncy_cntct_family_name1   := l_last_name;
        p_sr_ghr_cpdf_temp.emrgncy_cntct_given_name1    := cur_contacts_rec.first_name;
        p_sr_ghr_cpdf_temp.emrgncy_cntct_middle_name1   := cur_contacts_rec.middle_names;
        p_sr_ghr_cpdf_temp.emrgncy_cntct_suffix1        := l_suffix;
        --End Bug# 4648811
        p_sr_ghr_cpdf_temp.emrgncy_cntct_phone1         := cur_contacts_rec.phone_number;
        --p_sr_ghr_cpdf_temp.emrgncy_cntct_infrm_upd_dt1  := fnd_date.canonical_to_date(cur_contacts_rec.date_start);
        p_sr_ghr_cpdf_temp.emrgncy_cntct_infrm_upd_dt1  := cur_contacts_rec.date_start;
      ELSIF l_contact_cnt = 2 THEN
       -- Bug# 4648811  extracting the suffix from the lastname and also removing suffix from lastname
        get_suffix_lname(p_last_name   => cur_contacts_rec.last_name,
                         p_report_date => p_sr_report_date,
                         p_suffix      => l_suffix,
                         p_lname       => l_last_name);
        p_sr_ghr_cpdf_temp.emrgncy_cntct_family_name2   := l_last_name;
        p_sr_ghr_cpdf_temp.emrgncy_cntct_given_name2    := cur_contacts_rec.first_name;
        p_sr_ghr_cpdf_temp.emrgncy_cntct_middle_name2   := cur_contacts_rec.middle_names;
        p_sr_ghr_cpdf_temp.emrgncy_cntct_suffix2        := l_suffix;
        --End Bug# 4648811
        p_sr_ghr_cpdf_temp.emrgncy_cntct_phone2         := cur_contacts_rec.phone_number;
        --p_sr_ghr_cpdf_temp.emrgncy_cntct_infrm_upd_dt2  := fnd_date.canonical_to_date(cur_contacts_rec.date_start);
        p_sr_ghr_cpdf_temp.emrgncy_cntct_infrm_upd_dt2  := cur_contacts_rec.date_start;
      END IF;
    END LOOP;

  END get_from_history_people;

  PROCEDURE get_from_history_ancrit
            (
            p_sr_person_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS
    l_proc                        varchar2(30) := 'get_from_history_ancrit';
    l_ANCRIT_REC ghr_api.special_information_type;
    l_emp_number     per_all_people.employee_number%TYPE;

    l_id_flex_num    fnd_id_flex_structures.id_flex_num%type;
    l_max_segment    per_analysis_criteria.segment1%type;
    l_lang_cnt       number;
    l_flex_struct_name  varchar2(30);
    l_special_pay_plan  varchar2(30);
    l_special_pay_grade varchar2(30);
    l_message_name      varchar2(50);
    l_log_text          varchar2(2000);

    CURSOR c_per IS
      SELECT per.employee_number
        FROM per_all_people per
       WHERE per.person_id = p_sr_person_id
         AND NVL(p_sr_report_date, TRUNC(sysdate)) BETWEEN per.effective_start_date
                                                       AND per.effective_end_date;

    Cursor c_flex_num is
      select    flx.id_flex_num
      from      fnd_id_flex_structures_tl flx
      where     flx.id_flex_code           = 'PEA'  --
      and       flx.application_id         =  800   --
      and       flx.id_flex_structure_name =  l_flex_struct_name
      and	    flx.language	       = 'US';

    Cursor   c_sit_oldest      is
      select pea.analysis_criteria_id,
             pan.date_from, -- added for bug fix : 609285
             pan.person_analysis_id,
             pan.object_version_number,
             pea.start_date_active,
             pea.segment1,
             pea.segment2,
             pea.segment3,
             pea.segment4,
             pea.segment5,
             pea.segment6,
             pea.segment7
      from    per_analysis_criteria pea,
              per_person_analyses   pan
      where   pan.person_id            =  g_person_id
      and     pan.id_flex_num          =  l_id_flex_num
      and     pea.analysis_criteria_id =  pan.analysis_criteria_id
      and     p_sr_report_date
      between nvl(pan.date_from,p_sr_report_date)
      and     nvl(pan.date_to,p_sr_report_date)
      and     p_sr_report_date
      between nvl(pea.start_date_active,p_sr_report_date)
      and     nvl(pea.end_date_active,p_sr_report_date)
      order   by 1 asc;


    Cursor   c_sit_latest      is
      select pan.date_from,
             pan.analysis_criteria_id,
             pac.segment3,
             pac.segment4,
             pac.segment5,
             pac.segment6,
	     pac.segment17
      from   per_person_analyses   pan,
             per_analysis_Criteria pac
      where   pan.person_id            =  g_person_id
      and     pan.id_flex_num          =  l_id_flex_num
      and     pan.analysis_criteria_id =  pac.analysis_criteria_id
      and     p_sr_report_date
      between nvl(pan.date_from,p_sr_report_date)
      and     nvl(pan.date_to,p_sr_report_date)
      and     p_sr_report_date
      between nvl(pac.start_date_active,p_sr_report_date)
      and     nvl(pac.end_date_active,p_sr_report_date)
      order   by pan.date_from desc, pan.analysis_criteria_id desc; -- Latest From Date, Most Recent Record.

  BEGIN

    -- bug 749386 use ghr_api.return_education_details and ghr_api.return_special_information
    hr_utility.set_location('Entering:'||l_proc,5);
	--Begin Bug# 4753092
	g_message_name := 'Special Info: Education Dtls';
	--End Bug# 4753092
    ghr_api.return_education_details(p_person_id            => p_sr_person_id,
                                     p_effective_date       => p_sr_report_date,
                                     p_education_level      => p_sr_ghr_cpdf_temp.education_level,
                                     p_academic_discipline  => p_sr_ghr_cpdf_temp.academic_discipline,
                                     p_year_degree_attained => p_sr_ghr_cpdf_temp.year_degree_attained);

    -- get language
	--Begin Bug# 4753092
	g_message_name := 'Special Info: Language';
	--End Bug# 4753092
    l_flex_struct_name := 'US Fed Language';
    for flex_num in c_flex_num loop
      l_id_flex_num  :=  flex_num.id_flex_num;
    End loop;

    If l_id_flex_num is null then
      hr_utility.set_message(8301,'GHR_38275_INV_SP_INFO_TYPE');
      hr_utility.raise_error;
    End if;

    l_lang_cnt := 1;
    FOR special_info IN c_sit_oldest LOOP
		-- Begin Bug# 5034669
		IF special_info.segment6 IS NOT NULL THEN
		-- End Bug# 5034669
		  IF special_info.segment3 IS NOT NULL THEN
			-- Reading Code 03
			IF l_lang_cnt = 1 THEN
			  p_sr_ghr_cpdf_temp.language_code1    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level1  := special_info.segment3;
			  p_sr_ghr_cpdf_temp.lang_prof_type1   := '03';
			ELSIF l_lang_cnt = 2 THEN
			  p_sr_ghr_cpdf_temp.language_code2    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level2  := special_info.segment3;
			  p_sr_ghr_cpdf_temp.lang_prof_type2   := '03';
			ELSIF l_lang_cnt = 3 THEN
			  p_sr_ghr_cpdf_temp.language_code3    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level3  := special_info.segment3;
			  p_sr_ghr_cpdf_temp.lang_prof_type3   := '03';
			ELSIF l_lang_cnt = 4 THEN
			  p_sr_ghr_cpdf_temp.language_code4    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level4  := special_info.segment3;
			  p_sr_ghr_cpdf_temp.lang_prof_type4   := '03';
			ELSIF l_lang_cnt = 5 THEN
			  p_sr_ghr_cpdf_temp.language_code5    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level5  := special_info.segment3;
			  p_sr_ghr_cpdf_temp.lang_prof_type5   := '03';
			ELSIF l_lang_cnt = 6 THEN
			  p_sr_ghr_cpdf_temp.language_code6    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level6  := special_info.segment3;
			  p_sr_ghr_cpdf_temp.lang_prof_type6   := '03';
			ELSIF l_lang_cnt = 7 THEN
			  p_sr_ghr_cpdf_temp.language_code7    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level7  := special_info.segment3;
			  p_sr_ghr_cpdf_temp.lang_prof_type7   := '03';
			ELSIF l_lang_cnt = 8 THEN
			  p_sr_ghr_cpdf_temp.language_code8    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level8  := special_info.segment3;
			  p_sr_ghr_cpdf_temp.lang_prof_type8   := '03';
			END IF; --l_lang_cnt
			l_lang_cnt := l_lang_cnt +1;
		  END IF; -- Reading
		  IF special_info.segment4 IS NOT NULL THEN
			-- Speaking Code 01
			IF l_lang_cnt = 1 THEN
			  p_sr_ghr_cpdf_temp.language_code1    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level1  := special_info.segment4;
			  p_sr_ghr_cpdf_temp.lang_prof_type1   := '01';
			ELSIF l_lang_cnt = 2 THEN
			  p_sr_ghr_cpdf_temp.language_code2    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level2  := special_info.segment4;
			  p_sr_ghr_cpdf_temp.lang_prof_type2   := '01';
			ELSIF l_lang_cnt = 3 THEN
			  p_sr_ghr_cpdf_temp.language_code3    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level3  := special_info.segment4;
			  p_sr_ghr_cpdf_temp.lang_prof_type3   := '01';
			ELSIF l_lang_cnt = 4 THEN
			  p_sr_ghr_cpdf_temp.language_code4    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level4  := special_info.segment4;
			  p_sr_ghr_cpdf_temp.lang_prof_type4   := '01';
			ELSIF l_lang_cnt = 5 THEN
			  p_sr_ghr_cpdf_temp.language_code5    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level5  := special_info.segment4;
			  p_sr_ghr_cpdf_temp.lang_prof_type5   := '01';
			ELSIF l_lang_cnt = 6 THEN
			  p_sr_ghr_cpdf_temp.language_code6    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level6  := special_info.segment4;
			  p_sr_ghr_cpdf_temp.lang_prof_type6   := '01';
			ELSIF l_lang_cnt = 7 THEN
			  p_sr_ghr_cpdf_temp.language_code7    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level7  := special_info.segment4;
			  p_sr_ghr_cpdf_temp.lang_prof_type7   := '01';
			ELSIF l_lang_cnt = 8 THEN
			  p_sr_ghr_cpdf_temp.language_code8    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level8  := special_info.segment4;
			  p_sr_ghr_cpdf_temp.lang_prof_type8   := '01';
			END IF; --l_lang_cnt
			l_lang_cnt := l_lang_cnt +1;
		  END IF; -- Speaking
		  IF special_info.segment5 IS NOT NULL THEN
			-- Listening Code 02
			IF l_lang_cnt = 1 THEN
			  p_sr_ghr_cpdf_temp.language_code1    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level1  := special_info.segment5;
			  p_sr_ghr_cpdf_temp.lang_prof_type1   := '02';
			ELSIF l_lang_cnt = 2 THEN
			  p_sr_ghr_cpdf_temp.language_code2    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level2  := special_info.segment5;
			  p_sr_ghr_cpdf_temp.lang_prof_type2   := '02';
			ELSIF l_lang_cnt = 3 THEN
			  p_sr_ghr_cpdf_temp.language_code3    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level3  := special_info.segment5;
			  p_sr_ghr_cpdf_temp.lang_prof_type3   := '02';
			ELSIF l_lang_cnt = 4 THEN
			  p_sr_ghr_cpdf_temp.language_code4    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level4  := special_info.segment5;
			  p_sr_ghr_cpdf_temp.lang_prof_type4   := '02';
			ELSIF l_lang_cnt = 5 THEN
			  p_sr_ghr_cpdf_temp.language_code5    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level5  := special_info.segment5;
			  p_sr_ghr_cpdf_temp.lang_prof_type5   := '02';
			ELSIF l_lang_cnt = 6 THEN
			  p_sr_ghr_cpdf_temp.language_code6    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level6  := special_info.segment5;
			  p_sr_ghr_cpdf_temp.lang_prof_type6   := '02';
			ELSIF l_lang_cnt = 7 THEN
			  p_sr_ghr_cpdf_temp.language_code7    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level7  := special_info.segment5;
			  p_sr_ghr_cpdf_temp.lang_prof_type7   := '02';
			ELSIF l_lang_cnt = 8 THEN
			  p_sr_ghr_cpdf_temp.language_code8    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level8  := special_info.segment5;
			  p_sr_ghr_cpdf_temp.lang_prof_type8   := '02';
			END IF; --l_lang_cnt
			l_lang_cnt := l_lang_cnt +1;
		  END IF; -- Listening
		  IF special_info.segment7 IS NOT NULL THEN
			-- Writing Code 04
			IF l_lang_cnt = 1 THEN
			  p_sr_ghr_cpdf_temp.language_code1    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level1  := special_info.segment7;
			  p_sr_ghr_cpdf_temp.lang_prof_type1   := '04';
			ELSIF l_lang_cnt = 2 THEN
			  p_sr_ghr_cpdf_temp.language_code2    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level2  := special_info.segment7;
			  p_sr_ghr_cpdf_temp.lang_prof_type2   := '04';
			ELSIF l_lang_cnt = 3 THEN
			  p_sr_ghr_cpdf_temp.language_code3    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level3  := special_info.segment7;
			  p_sr_ghr_cpdf_temp.lang_prof_type3   := '04';
			ELSIF l_lang_cnt = 4 THEN
			  p_sr_ghr_cpdf_temp.language_code4    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level4  := special_info.segment7;
			  p_sr_ghr_cpdf_temp.lang_prof_type4   := '04';
			ELSIF l_lang_cnt = 5 THEN
			  p_sr_ghr_cpdf_temp.language_code5    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level5  := special_info.segment7;
			  p_sr_ghr_cpdf_temp.lang_prof_type5   := '04';
			ELSIF l_lang_cnt = 6 THEN
			  p_sr_ghr_cpdf_temp.language_code6    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level6  := special_info.segment7;
			  p_sr_ghr_cpdf_temp.lang_prof_type6   := '04';
			ELSIF l_lang_cnt = 7 THEN
			  p_sr_ghr_cpdf_temp.language_code7    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level7  := special_info.segment7;
			  p_sr_ghr_cpdf_temp.lang_prof_type7   := '04';
			ELSIF l_lang_cnt = 8 THEN
			  p_sr_ghr_cpdf_temp.language_code8    := special_info.segment1;
			  p_sr_ghr_cpdf_temp.lang_prof_level8  := special_info.segment7;
			  p_sr_ghr_cpdf_temp.lang_prof_type8   := '04';
			END IF; --l_lang_cnt
			l_lang_cnt := l_lang_cnt +1;
		  END IF; -- Writing
		-- Begin Bug# 5034669
		END IF; -- Segment6
		-- End Bug# 5034669
      IF l_lang_cnt >= 9 THEN
        EXIT;
      END IF;
    END LOOP; -- Language

    -- get Performance Appraisal Details
    l_flex_struct_name := 'US Fed Perf Appraisal';
	--Begin Bug# 4753092
	g_message_name := 'Special Info: Perf Appraisal';
	--End Bug# 4753092
    for flex_num in c_flex_num loop
      l_id_flex_num  :=  flex_num.id_flex_num;
    End loop;

    If l_id_flex_num is null then
      hr_utility.set_message(8301,'GHR_38275_INV_SP_INFO_TYPE');
      hr_utility.raise_error;
    End if;

    l_lang_cnt := 0;
    FOR special_info IN c_sit_latest LOOP
      p_sr_ghr_cpdf_temp.rating_of_record_pattern       := special_info.segment4;
      p_sr_ghr_cpdf_temp.rating_of_record_level         := special_info.segment5;
      p_sr_ghr_cpdf_temp.rating_of_record_period_ends   := fnd_date.canonical_to_date(special_info.segment6);
      --Bug# 4753117 05-MAR-07	Veeramani  adding Appraisal start date
      p_sr_ghr_cpdf_temp.rating_of_record_period_starts := fnd_date.canonical_to_date(special_info.segment17);
      l_lang_cnt := l_lang_cnt + 1;
      exit;
    END LOOP;

  END get_from_history_ancrit;

  PROCEDURE get_from_history_peopei
            (
            p_sr_person_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS

   -- JH EHRI may need date factored in and order by (test)
   Cursor  c_extra_info_id is
     select      pei.person_extra_info_id
     from        per_people_extra_info pei
     where       pei.person_id          =  p_sr_person_id
     and         pei.information_type   =  'GHR_US_PER_SERVICE_OBLIGATION'
     order by pei.person_extra_info_id;

   Cursor c_retained_pay_table_name (p_user_table_id number) is
	select substr(user_table_name,1,4) user_table_name
      from pay_user_tables
   	where user_table_id = p_user_table_id;


    l_proc                    varchar2(30) := 'get_from_history_peopei';
    l_PEOPEI_DATA             PER_PEOPLE_EXTRA_INFO%ROWTYPE;
    l_PEOPEI_DATA_INIT        PER_PEOPLE_EXTRA_INFO%ROWTYPE;
    l_type_of_employment      per_people_extra_info.pei_information4%TYPE;
    l_retained_grade_rec      ghr_pay_calc.retained_grade_rec_type;
    l_session                 ghr_history_api.g_session_var_type;
    l_extra_info_id           per_people_extra_info.person_extra_info_id%type;
    l_result                  varchar2(20);
    l_cnt                     number;
    l_user_table_id           number;
    l_message_name            varchar2(50);
    l_log_text                varchar2(2000);

  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4753092
	g_message_name := 'Person EIT: Uniformed Serivces';
	-- End Bug# 4753092
    GHR_HISTORY_FETCH.fetch_peopleei(
                       p_person_id        => p_sr_person_id,
                       p_information_type => 'GHR_US_PER_UNIFORMED_SERVICES',
                       p_date_effective   => p_sr_report_date,
                       p_per_ei_data      => l_PEOPEI_DATA
                                     );
    p_sr_ghr_cpdf_temp.creditable_military_service := l_PEOPEI_DATA.PEI_INFORMATION5;
	--Begin Bug# 4672725
	IF l_PEOPEI_DATA.PEI_INFORMATION20 IS NOT NULL THEN
		p_sr_ghr_cpdf_temp.mil_svc_end_date := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION20);
	ELSE
		p_sr_ghr_cpdf_temp.mil_svc_end_date := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION6);
	END IF;
	--end Bug# 4672725
    p_sr_ghr_cpdf_temp.act_svc_indicator           := l_PEOPEI_DATA.PEI_INFORMATION12;
    p_sr_ghr_cpdf_temp.mil_char_svc_code           := l_PEOPEI_DATA.PEI_INFORMATION13;
    p_sr_ghr_cpdf_temp.mil_svc_sno                 := l_PEOPEI_DATA.PEI_INFORMATION14;
    p_sr_ghr_cpdf_temp.mil_svc_start_date          := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION15);
    p_sr_ghr_cpdf_temp.mil_branch_code             := l_PEOPEI_DATA.PEI_INFORMATION16;
    p_sr_ghr_cpdf_temp.mil_discharge_code          := l_PEOPEI_DATA.PEI_INFORMATION17;


    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4753092
	g_message_name := 'Person EIT: Separation, Retire';
	-- End Bug# 4753092
    GHR_HISTORY_FETCH.fetch_peopleei(
                       p_person_id        => p_sr_person_id,
                       p_information_type => 'GHR_US_PER_SEPARATE_RETIRE',
                       p_date_effective   => p_sr_report_date,
                       p_per_ei_data      => l_PEOPEI_DATA
                                     );
    p_sr_ghr_cpdf_temp.frozen_service           := l_PEOPEI_DATA.PEI_INFORMATION5;
    p_sr_ghr_cpdf_temp.fers_coverage            := l_PEOPEI_DATA.PEI_INFORMATION3;
    p_sr_ghr_cpdf_temp.fers_elect_date          := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION18);
    p_sr_ghr_cpdf_temp.fers_elect_indicator     := l_PEOPEI_DATA.PEI_INFORMATION19;
    p_sr_ghr_cpdf_temp.disability_retire_notify := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION20);

    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4753092
	g_message_name := 'Person EIT: Person RPA';
	-- End Bug# 4753092
    GHR_HISTORY_FETCH.fetch_peopleei(
                       p_person_id        => p_sr_person_id,
                       p_information_type => 'GHR_US_PER_SF52',
                       p_date_effective   => p_sr_report_date,
                       p_per_ei_data      => l_PEOPEI_DATA
                                     );

    p_sr_ghr_cpdf_temp.veterans_preference := l_PEOPEI_DATA.PEI_INFORMATION4;
    p_sr_ghr_cpdf_temp.veterans_status     := l_PEOPEI_DATA.PEI_INFORMATION6;
    -- Bug#5063292 Show the citizenship as 'Y' for value '1'
    -- 'N' for '8' and 'NA' for NULL
    IF l_peopei_data.pei_information3 is NOT NULL THEN
        IF l_peopei_data.pei_information3 = '1' THEN
            p_sr_ghr_cpdf_temp.citizenship  := 'Y';
        ELSIF l_peopei_data.pei_information3 = '8' THEN
            p_sr_ghr_cpdf_temp.citizenship  := 'N';
        ELSE
            p_sr_ghr_cpdf_temp.citizenship  := l_peopei_data.pei_information3;
        END IF;
    ELSE
        p_sr_ghr_cpdf_temp.citizenship         := 'NA';
    END IF;

    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4753092
	g_message_name := 'Person EIT: Person Group1';
	-- End Bug# 4753092
    GHR_HISTORY_FETCH.fetch_peopleei(
                       p_person_id        => p_sr_person_id,
                       p_information_type => 'GHR_US_PER_GROUP1',
                       p_date_effective   => p_sr_report_date,
                       p_per_ei_data      => l_PEOPEI_DATA
                                     );
    p_sr_ghr_cpdf_temp.current_appointment_auth1 := l_PEOPEI_DATA.PEI_INFORMATION8;
    p_sr_ghr_cpdf_temp.current_appointment_auth2 := l_PEOPEI_DATA.PEI_INFORMATION9;
    p_sr_ghr_cpdf_temp.race_national_origin      := l_PEOPEI_DATA.PEI_INFORMATION5;
    p_sr_ghr_cpdf_temp.handicap_code             := l_PEOPEI_DATA.PEI_INFORMATION11;
    l_type_of_employment                         := l_PEOPEI_DATA.PEI_INFORMATION4;
    p_sr_ghr_cpdf_temp.world_citizenship         := l_PEOPEI_DATA.PEI_INFORMATION10;
    -- Bug#5184166 Appointment type code should not be reported.
    -- p_sr_ghr_cpdf_temp.appoint_type_code         := l_PEOPEI_DATA.PEI_INFORMATION3;
    p_sr_ghr_cpdf_temp.ehri_employee_id          := to_number(l_PEOPEI_DATA.PEI_INFORMATION18);
    p_sr_ghr_cpdf_temp.slct_serv_regi_indicator  := l_PEOPEI_DATA.PEI_INFORMATION19;
    p_sr_ghr_cpdf_temp.career_tenure_code        := l_PEOPEI_DATA.PEI_INFORMATION20;

    -- bug 749190 Use FUNCTION ghr_pc_basic_pay.get_retained_grade_details instead of
    -- GHR_HISTORY_FETCH.fetch_peopleei
    -- do not worry if it didn't return anything!
	-- Begin Bug# 4753092
	g_message_name := 'Person EIT: RG Details';
	-- End Bug# 4753092
	-- Bug# 4753092 Added If Condition
	IF p_sr_ghr_cpdf_temp.to_pay_rate_determinant IN ('A','B','E','F','U','V')  THEN
		BEGIN
		  l_retained_grade_rec := ghr_pc_basic_pay.get_retained_grade_details (
													   p_person_id        => p_sr_person_id,
													   p_effective_date   => p_sr_report_date
																			 );
		  --- added for bug 3834462 Madhuri, store Retained Pay Basis value
		  --- Start of fix
		  p_sr_ghr_cpdf_temp.to_pay_basis		   := l_retained_grade_rec.pay_basis;
		  -- End of Bug fix
		  p_sr_ghr_cpdf_temp.retained_pay_plan         := l_retained_grade_rec.pay_plan;
		  p_sr_ghr_cpdf_temp.retained_grade_or_level   := l_retained_grade_rec.grade_or_level;
		  p_sr_ghr_cpdf_temp.retained_step_or_rate     := l_retained_grade_rec.step_or_rate;

		  -- JH Added for EHRI to get retained pay table name.
		  l_user_table_id                              := l_retained_grade_rec.user_table_id;
		  g_retained_pay_table_name := NULL;
		  For retained_pay in c_retained_pay_table_name(l_user_table_id) loop
			g_retained_pay_table_name := retained_pay.user_table_name;
		  End Loop;

		EXCEPTION
		  WHEN ghr_pay_calc.pay_calc_message THEN
			NULL;
		END;
	END IF;
    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4753092
	g_message_name := 'Person EIT: Person SCD Info';
	-- End Bug# 4753092
    GHR_HISTORY_FETCH.fetch_peopleei(
                       p_person_id        => p_sr_person_id,
                       p_information_type => 'GHR_US_PER_SCD_INFORMATION',
                       p_date_effective   => p_sr_report_date,
                       p_per_ei_data      => l_PEOPEI_DATA
                                     );
    -- SVC may be changed w/ resolution of type/length conversion
    p_sr_ghr_cpdf_temp.service_comp_date         :=
                   fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION3);

    -- SCD RIF and Retirement dates
    p_sr_ghr_cpdf_temp.SCD_rif         :=
                   fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION5);
    p_sr_ghr_cpdf_temp.SCD_retirement  :=
                   fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION7);

    p_sr_ghr_cpdf_temp.leave_scd         := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION3);
    p_sr_ghr_cpdf_temp.tsp_scd           := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION6);
    p_sr_ghr_cpdf_temp.scd_ses           := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION8);
    p_sr_ghr_cpdf_temp.scd_spcl_retire   := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION9);

    -- JH EHRI Multiple Entries!!! GHR_US_PER_SERVICE_OBLIGATION
    l_cnt := 0;
	-- Begin Bug# 4753092
	g_message_name := 'Person EIT: Service Obligation';
	-- End Bug# 4753092
    For  extra_info in c_extra_info_id loop
      l_cnt := l_cnt + 1;
      l_extra_info_id   :=   extra_info.person_extra_info_id;
      If l_extra_info_id is not null then
        hr_utility.set_location(l_proc,10);
        ghr_history_api.get_g_session_var(l_session);
     	  ghr_history_fetch.fetch_peopleei ( p_person_extra_info_id  => l_extra_info_id,
		                               p_date_effective        => p_sr_report_date,
                                           p_altered_pa_request_id => l_session.altered_pa_request_id,
                                           p_noa_id_corrected      => l_session.noa_id_correct,
	                                     p_pa_history_id         => l_session.pa_history_id,
	                                     p_peopleei_data         => l_PEOPEI_DATA,
                                           p_get_ovn_flag          => 'Y',
                                           p_result_code           => l_result
                                         );

        IF l_cnt = 1 THEN
          p_sr_ghr_cpdf_temp.svc_oblig_type_code1      := l_PEOPEI_DATA.PEI_INFORMATION3;
          p_sr_ghr_cpdf_temp.svc_oblig_type_end_date1  := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION4);
        ELSIF l_cnt = 2 THEN
          p_sr_ghr_cpdf_temp.svc_oblig_type_code2      := l_PEOPEI_DATA.PEI_INFORMATION3;
          p_sr_ghr_cpdf_temp.svc_oblig_type_end_date2  := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION4);
        ELSIF l_cnt = 3 THEN
          p_sr_ghr_cpdf_temp.svc_oblig_type_code3      := l_PEOPEI_DATA.PEI_INFORMATION3;
          p_sr_ghr_cpdf_temp.svc_oblig_type_end_date3  := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION4);
        ELSIF l_cnt = 4 THEN
          p_sr_ghr_cpdf_temp.svc_oblig_type_code4      := l_PEOPEI_DATA.PEI_INFORMATION3;
          p_sr_ghr_cpdf_temp.svc_oblig_type_end_date4  := fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION4);
        END IF;
      End if;
    End loop;

    -- CPDF EDITS FOR CREDITABLE MILITARY SERVICE
    -- October date specified per requirements
    -- Bug# 4060669 starts
     IF NVL(p_sr_ghr_cpdf_temp.annuitant_indicator,'9') <> '9' OR
        g_appointment_date < to_date('1986/10/01','YYYY/MM/DD')
     THEN
       p_sr_ghr_cpdf_temp.creditable_military_service := NULL;
     ELSIF NVL(p_sr_ghr_cpdf_temp.annuitant_indicator,'9') = '9' AND
       g_appointment_date > to_date('1986/10/01','YYYY/MM/DD') THEN
       IF p_sr_ghr_cpdf_temp.creditable_military_service IS NULL THEN
          p_sr_ghr_cpdf_temp.creditable_military_service := '000000';
       END IF;
     END IF;

/*
     -- Bug# 4060669 ends
     IF (SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,1,1) < '0' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,2,1) < '0' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,3,1) < '0' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,4,1) < '0' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,5,1) < '0' OR -- need to be added for ehri
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,6,1) < '0' OR -- need to be added for ehri
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,1,1) > '9' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,2,1) > '9' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,3,1) > '9' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,4,1) > '9' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,5,1) > '9' OR -- need to be added for ehri
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,6,1) > '9' ) -- need to be added for ehri
     AND
       p_sr_ghr_cpdf_temp.creditable_military_service IS NOT NULL AND
       p_sr_ghr_cpdf_temp.creditable_military_service <> ' '
     THEN
       p_sr_ghr_cpdf_temp.creditable_military_service := '000000'; -- from 0000 to '000000'
     END IF;
*/


    -- CPDF EDITS FOR FROZEN SERVICE
    -- October date specified per requirements
    -- use retirement plan, not fers coverage per raj/john
     IF p_sr_ghr_cpdf_temp.retirement_plan NOT IN('K','L','M','N','C','E') OR
        g_appointment_date < to_date('1986/10/01','YYYY/MM/DD')
     THEN
       p_sr_ghr_cpdf_temp.frozen_service := ' ';
     END IF;


    -- CPDF EDITS FOR FERS COVERAGE
    -- use retirement plan, not fers coverage per raj/john
     IF p_sr_ghr_cpdf_temp.retirement_plan NOT IN('K','L','M','N')
     THEN
       p_sr_ghr_cpdf_temp.fers_coverage := ' ';
     END IF;

    -- CPDF EDITS FOR RETAINED ...
     IF p_sr_ghr_cpdf_temp.to_pay_rate_determinant
               NOT IN ('A','B','E','F','U','V')
     THEN
       p_sr_ghr_cpdf_temp.retained_pay_plan         := NULL;
       p_sr_ghr_cpdf_temp.retained_grade_or_level   := NULL;
       p_sr_ghr_cpdf_temp.retained_step_or_rate     := NULL;
-- Bug 3834462 fix Madhuri
-- NULL this out incase the PRD is not in above list,
-- pay basis can be picked now from valid grade info instead of the retained grade details.
       p_sr_ghr_cpdf_temp.to_pay_basis		    := NULL;
     END IF;

/*
    -- Populating based on Assignment Status for EHRI
    -- CPDF EDITS FOR PAY_STATUS
    --  pay status is derived from type of employment per logic provided
    --    by john z.

     IF l_type_of_employment
               IN ('1','2','3','4','5','6','7','C','D','E','G','H','J','W')
     THEN
       p_sr_ghr_cpdf_temp.pay_status                := 'P';
     ELSIF l_type_of_employment = 'F'
     THEN
       p_sr_ghr_cpdf_temp.pay_status                := 'N';
     ELSE
       p_sr_ghr_cpdf_temp.pay_status                := l_type_of_employment;
     END IF;
*/


		-- Fetching Race and ethnicity category
		l_PEOPEI_DATA :=NULL;
		-- Begin Bug# 4753092
		g_message_name := 'Person EIT: Ethnicity, Race';

		-- End Bug# 4753092
	    ghr_history_fetch.fetch_peopleei
		  (p_person_id           =>  p_sr_person_id,
		    p_information_type   =>  'GHR_US_PER_ETHNICITY_RACE',
		    p_date_effective     =>  p_sr_report_date,
	            p_per_ei_data    =>  l_PEOPEI_DATA
		  );

		  p_sr_ghr_cpdf_temp.race_ethnic_info := NULL;
		  -- Populate Race only if atleast one data segment is entered.
		  IF l_PEOPEI_DATA.pei_information3 IS NOT NULL OR
		  	 l_PEOPEI_DATA.pei_information4 IS NOT NULL OR
		  	 l_PEOPEI_DATA.pei_information5 IS NOT NULL OR
		  	 l_PEOPEI_DATA.pei_information6 IS NOT NULL OR
		  	 l_PEOPEI_DATA.pei_information7 IS NOT NULL OR
		  	 l_PEOPEI_DATA.pei_information8 IS NOT NULL THEN
		  	 p_sr_ghr_cpdf_temp.race_ethnic_info := NVL(l_PEOPEI_DATA.pei_information3,'0') || NVL(l_PEOPEI_DATA.pei_information4,'0') || NVL(l_PEOPEI_DATA.pei_information5,'0') ||
		  											NVL(l_PEOPEI_DATA.pei_information6,'0') || NVL(l_PEOPEI_DATA.pei_information7,'0') || NVL(l_PEOPEI_DATA.pei_information8,'0');
		  END IF;
		  -- End Bug 4714292 EHRI Reports Changes for EOY 05

       --Begin Bug# 6158983


         l_PEOPEI_DATA  := l_PEOPEI_DATA_INIT;
         g_message_name   := 'Person EIT : US Benefit Cont';

         GHR_HISTORY_FETCH.fetch_peopleei(p_person_id        => p_sr_person_id,
                                          p_information_type => 'GHR_US_PER_BENEFITS_CONT',
                                          p_date_effective   => p_sr_report_date,
                                          p_per_ei_data      => l_PEOPEI_DATA
                                          );


         p_sr_ghr_cpdf_temp.fegli_indicator := l_peopei_data.pei_information1;
         p_sr_ghr_cpdf_temp.fegli_elect_date := fnd_date.canonical_to_date(l_peopei_data.pei_information2);
         p_sr_ghr_cpdf_temp.fegli_notify_date := fnd_date.canonical_to_date(l_peopei_data.pei_information3);
         p_sr_ghr_cpdf_temp.fehb_indicator := l_peopei_data.pei_information4;
         p_sr_ghr_cpdf_temp.fehb_elect_date := fnd_date.canonical_to_date(l_peopei_data.pei_information5);
         p_sr_ghr_cpdf_temp.fehb_notify_date := fnd_date.canonical_to_date(l_peopei_data.pei_information6);
         p_sr_ghr_cpdf_temp.retire_indicator := l_peopei_data.pei_information7;
         p_sr_ghr_cpdf_temp.retire_elect_date := fnd_date.canonical_to_date(l_peopei_data.pei_information12);
         p_sr_ghr_cpdf_temp.retire_notify_date := fnd_date.canonical_to_date(l_peopei_data.pei_information8);
         p_sr_ghr_cpdf_temp.cont_term_elect_date := fnd_date.canonical_to_date(l_peopei_data.pei_information9);
         p_sr_ghr_cpdf_temp.cont_ins_pay_notify_date:= fnd_date.canonical_to_date(l_peopei_data.pei_information10);
         p_sr_ghr_cpdf_temp.cont_pay_type_code:= l_peopei_data.pei_information11;

  -- End Bug#6158983

  END get_from_history_peopei;

  PROCEDURE get_from_history_posiei
            (
            p_sr_position_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS
    l_proc                        varchar2(30) := 'get_from_history_posiei';
    l_POSIEI_DATA                   PER_POSITION_EXTRA_INFO%ROWTYPE;
    l_POSIEI_DATA_INIT              PER_POSITION_EXTRA_INFO%ROWTYPE;
    l_to_pay_table_id               ghr_cpdf_temp.to_pay_table_id%type;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    l_POSIEI_DATA := l_POSIEI_DATA_INIT;
	-- Begin Bug# 4753092
	g_message_name := 'Position EIT: Position Group1';
	-- End Bug# 4753092
    GHR_HISTORY_FETCH.fetch_positionei(
                       p_position_id      => p_sr_position_id,
                       p_information_type => 'GHR_US_POS_GRP1',
                       p_date_effective   => p_sr_report_date,
                       p_pos_ei_data      => l_POSIEI_DATA
                                       );
	-- Bug# 4753092. As EHRI Status report is having lentgh 18 for Organizational component
	-- to avoid the errors we use the substr.
    p_sr_ghr_cpdf_temp.organizational_component := substr(l_POSIEI_DATA.POEI_INFORMATION5,1,30);
    p_sr_ghr_cpdf_temp.personnel_office_id      := l_POSIEI_DATA.POEI_INFORMATION3;
    p_sr_ghr_cpdf_temp.functional_class         := l_POSIEI_DATA.POEI_INFORMATION11;
    p_sr_ghr_cpdf_temp.supervisory_status       := l_POSIEI_DATA.POEI_INFORMATION16;
    p_sr_ghr_cpdf_temp.flsa_category            := l_POSIEI_DATA.POEI_INFORMATION7;
    p_sr_ghr_cpdf_temp.bargaining_unit_status   := SUBSTR(l_POSIEI_DATA.POEI_INFORMATION8,length(l_POSIEI_DATA.POEI_INFORMATION8)-3);


    l_POSIEI_DATA := l_POSIEI_DATA_INIT;
	-- Begin Bug# 4753092
	g_message_name := 'Position EIT: Valid Grade';
	-- End Bug# 4753092
    GHR_HISTORY_FETCH.fetch_positionei(
                       p_position_id      => p_sr_position_id,
                       p_information_type => 'GHR_US_POS_VALID_GRADE',
                       p_date_effective   => p_sr_report_date,
                       p_pos_ei_data      => l_POSIEI_DATA
                                       );
    -- Added this condition for Bug 3834462 Fix (Madhuri)
    IF p_sr_ghr_cpdf_temp.to_pay_basis is NULL THEN
        p_sr_ghr_cpdf_temp.to_pay_basis     := l_POSIEI_DATA.POEI_INFORMATION6;
    END IF;
    -- Added this condition for Bug 3834462 Fix (Madhuri)
    g_pay_table_name := null;
    if (l_POSIEI_DATA.POEI_INFORMATION5 is not null) then
	 select substr(user_table_name,1,4)
  	 into l_to_pay_table_id
       from pay_user_tables
   	 where user_table_id = l_POSIEI_DATA.POEI_INFORMATION5;
       g_pay_table_name := l_to_pay_table_id;
    end if;

    -- JH EHRI Special Salary Rate
    IF g_ghr_cpdf_temp.to_pay_rate_determinant in ('E','F','U','V')
     AND g_ghr_cpdf_temp.retained_pay_plan in ('GS','GG','GM','GH')
     AND nvl(g_retained_pay_table_name,'0000') <> '0000' THEN
       g_ghr_cpdf_temp.spcl_salary_rate := g_ghr_cpdf_temp.to_basic_pay;
    ELSIF g_ghr_cpdf_temp.to_pay_rate_determinant in ('6','7')
     AND nvl(g_pay_table_name,'0000') <> '0000' THEN
       g_ghr_cpdf_temp.spcl_salary_rate := g_ghr_cpdf_temp.to_basic_pay;
    ELSE
       g_ghr_cpdf_temp.spcl_salary_rate := NULL;
    END IF;


    -- JH Special Pay Table ID, if PRD = 6 and Pay Plan equal GS or GG then populate with Pay Table ID
    -- or PRD is E or F and Retained Pay Plan = GS or GG then populate with Retained Grade Pay Table ID.

    l_POSIEI_DATA := l_POSIEI_DATA_INIT;
	-- Begin Bug# 4753092
	g_message_name := 'Position EIT: Position Group2';
	-- End Bug# 4753092
    GHR_HISTORY_FETCH.fetch_positionei(
                       p_position_id      =>  p_sr_position_id,
                       p_information_type =>  'GHR_US_POS_GRP2',
                       p_date_effective   =>  p_sr_report_date,
                       p_pos_ei_data      =>  l_POSIEI_DATA
                                       );
    p_sr_ghr_cpdf_temp.position_occupied  := l_POSIEI_DATA.POEI_INFORMATION3;
    p_sr_ghr_cpdf_temp.appropriation_code := l_POSIEI_DATA.POEI_INFORMATION13;
    p_sr_ghr_cpdf_temp.comp_pos_indicator := l_POSIEI_DATA.POEI_INFORMATION18;

    -- CPDF EDITS FOR PAY TABLE ID
    IF p_sr_ghr_cpdf_temp.to_pay_rate_determinant NOT IN ('5','6','E','F','M')
    THEN
       p_sr_ghr_cpdf_temp.to_pay_table_id := ' ';
    END IF;

  END get_from_history_posiei;

  PROCEDURE get_from_history_gradef
            (
            p_sr_grade_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS
    --  start_date_active and end_date_active on the PER_GRADE_DEFINITIONS
    --    table WAS NOT considered as a query criteria because all rows on
    --    GHRDEV16 had null values for both columns.
    l_proc                        varchar2(30) := 'get_from_history_gradef';
    CURSOR GRADEFCUR IS
    SELECT SEGMENT1,
           SEGMENT2
      FROM PER_GRADE_DEFINITIONS
      WHERE GRADE_DEFINITION_ID =
        (SELECT MAX(GRADE_DEFINITION_ID)
           FROM PER_GRADES
           WHERE GRADE_ID = g_grade_id);

    l_GRADEFREC GRADEFCUR%ROWTYPE;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    OPEN GRADEFCUR;

    FETCH GRADEFCUR INTO l_GRADEFREC;

    -- Pay Plan to be changed w/ resolution of type/length conversion

    IF GRADEFCUR%FOUND
    THEN
      p_sr_ghr_cpdf_temp.to_pay_plan             := substr(l_GRADEFREC.SEGMENT1,1,2);
      g_to_pay_plan                              := p_sr_ghr_cpdf_temp.to_pay_plan;
      p_sr_ghr_cpdf_temp.to_grade_or_level       := l_GRADEFREC.SEGMENT2;
    END IF;

    CLOSE GRADEFCUR;
  END get_from_history_gradef;

  PROCEDURE get_from_history_jobdef
            (
            p_sr_job_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS
    l_proc                        varchar2(30) := 'get_from_history_jobdef';
    CURSOR JOBDEF_CUR IS
    SELECT SEGMENT1
      FROM PER_JOB_DEFINITIONS
      WHERE JOB_DEFINITION_ID =
        (SELECT JOB_DEFINITION_ID
           FROM PER_JOBS
           WHERE JOB_ID = g_job_id);

    -- Declared record despite a "one column query" for future maintenance
    l_JOBDEF_REC JOBDEF_CUR%ROWTYPE;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    OPEN JOBDEF_CUR;

    FETCH JOBDEF_CUR INTO l_JOBDEF_REC;

    IF JOBDEF_CUR%FOUND
    THEN
      p_sr_ghr_cpdf_temp.to_occ_code             := l_JOBDEF_REC.SEGMENT1;
    END IF;

    CLOSE JOBDEF_CUR;

  END get_from_history_jobdef;

  PROCEDURE get_from_history_dutsta
            (
            p_sr_location_id   IN NUMBER
           ,p_sr_report_date   IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS
    l_proc                     varchar2(30) := 'get_from_history_dutsta';
    l_log_text                 ghr_process_log.log_text%type;
    l_message_name           	 ghr_process_log.message_name%type;
    l_log_date                 ghr_process_log.log_date%type;

    CURSOR DUTSTACUR IS
    SELECT DUTY_STATION_CODE, DUTY_STATION_ID
      FROM GHR_DUTY_STATIONS_F
     WHERE trunc(p_sr_report_date) between effective_start_date and
                                       nvl(effective_end_date, p_sr_report_date)
       AND DUTY_STATION_ID =
           (SELECT LEI_INFORMATION3
            FROM   HR_LOCATION_EXTRA_INFO
            WHERE  INFORMATION_TYPE = 'GHR_US_LOC_INFORMATION'
              AND  LOCATION_ID      = g_location_id);

    -- Declared record despite a "one column query" for future maintenance
    l_DUTSTAREC DUTSTACUR%ROWTYPE;

    -- JH EHRI Loc Address
    -- Bug#5508003 Added substr to all the address lines
    CURSOR cur_loc_address IS
    SELECT substr(address_line_1,1,35) address_line_1,
           substr(address_line_2,1,35) address_line_2,
	       substr(address_line_3,1,35) address_line_3,
           substr(postal_code,1,35) postal_code,
	       substr(town_or_city,1,35) town_or_city,
	       substr(country,1,4) country,
	       substr(region_2,1,2) region_2
--    FROM   hr_locations_v Bug 4863608 Performance
	 FROM  hr_locations_all
    WHERE  location_id = g_location_id;

  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
	-- Begin Bug# 4753092
	g_message_name := 'Duty Station Details';
	-- End Bug# 4753092
    OPEN DUTSTACUR;

    FETCH DUTSTACUR INTO l_DUTSTAREC;

    IF DUTSTACUR%FOUND
    THEN
      p_sr_ghr_cpdf_temp.to_duty_station_code     := l_DUTSTAREC.DUTY_STATION_CODE;
      g_duty_station_id                           := l_DUTSTAREC.DUTY_STATION_ID;
    END IF;

    CLOSE DUTSTACUR;
	-- Begin Bug# 4753092
	g_message_name := 'Duty Station Location Address';
	-- End Bug# 4753092
    -- JH EHRI Loc Address
    --Bug# 4725292
    -- Commented this since the address will be fetched from Person Work address
    /*FOR cur_loc_addr_rec IN cur_loc_address LOOP
      p_sr_ghr_cpdf_temp.work_address_line1       := cur_loc_addr_rec.address_line_1;
      p_sr_ghr_cpdf_temp.work_address_line2       := cur_loc_addr_rec.address_line_2;
      p_sr_ghr_cpdf_temp.work_address_line3       := cur_loc_addr_rec.address_line_3;
      p_sr_ghr_cpdf_temp.work_address_line4       := NULL;
      p_sr_ghr_cpdf_temp.work_city                := cur_loc_addr_rec.town_or_city;
      p_sr_ghr_cpdf_temp.work_postal_code         := cur_loc_addr_rec.postal_code;
      p_sr_ghr_cpdf_temp.work_state_code          := cur_loc_addr_rec.region_2;
      p_sr_ghr_cpdf_temp.work_country_code        := cur_loc_addr_rec.country;
    END LOOP;*/
    --Bug# 4725292
   /* -- Commented this exception to return the cursor to calling program bug# 4753092
    EXCEPTION
	WHEN OTHERS THEN
        l_message_name := 'Unhandled Error';
        l_log_text     := 'Unhandled Error under procedure get_from_history_dutsta'||
        ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
        ghr_mto_int.log_message(p_procedure => l_message_name,
        p_message   => l_log_text);
        COMMIT;
	*/
  END get_from_history_dutsta;
    --Begin Bug# 4725292
  PROCEDURE get_from_per_wrkadd(
            p_sr_person_id   IN NUMBER
           ,p_sr_report_date   IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )  IS
    l_proc                     varchar2(30) := 'get_from_per_wrkadd';

    CURSOR workaddcur IS
    select address_line1,address_line2, address_line3, region_3 address_line4,
    COUNTRY, REGION_2, TOWN_OR_CITY CITY,POSTAL_CODE, REGION_1 County
    FROM PER_ADDRESSES
    Where Address_type= 'FED_WA'
     AND Person_id = p_sr_person_id
    And  trunc(p_sr_report_date) between date_from and
                        nvl(date_to, p_sr_report_date);

  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
    g_message_name := 'Person Work Address Details';

    FOR cur_wrk_addr_rec IN workaddcur LOOP
        p_sr_ghr_cpdf_temp.work_address_line1       := cur_wrk_addr_rec.address_line1;
        p_sr_ghr_cpdf_temp.work_address_line2       := cur_wrk_addr_rec.address_line2;
        p_sr_ghr_cpdf_temp.work_address_line3       := cur_wrk_addr_rec.address_line3;
        p_sr_ghr_cpdf_temp.work_address_line4       := cur_wrk_addr_rec.address_line4;
        p_sr_ghr_cpdf_temp.work_city                := cur_wrk_addr_rec.city;
        p_sr_ghr_cpdf_temp.work_postal_code         := cur_wrk_addr_rec.postal_code;

        IF cur_wrk_addr_rec.country <> 'US' THEN
            p_sr_ghr_cpdf_temp.work_region          := cur_wrk_addr_rec.County;
            --Begin Bug# 6973541
            p_sr_ghr_cpdf_temp.work_country_code    := cur_wrk_addr_rec.country;
            p_sr_ghr_cpdf_temp.work_state_code      := NULL;
            --End Bug# 6973541
        ELSE
            p_sr_ghr_cpdf_temp.work_region          := NULL;
            --Begin Bug# 6973541
            p_sr_ghr_cpdf_temp.work_country_code    := NULL;
            p_sr_ghr_cpdf_temp.work_state_code      := cur_wrk_addr_rec.region_2;
            --End Bug# 6973541
        END IF;
    END LOOP;

  END get_from_per_wrkadd;
    --End Bug# 4725292
  PROCEDURE get_from_history_payele
            (p_sr_assignment_id  IN NUMBER
            ,p_sr_report_date    IN DATE
            ,p_sr_ghr_cpdf_temp  IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE)
  IS
    l_proc                 varchar2(30) := 'get_from_history_payele';
    l_scrn_ent_val_init    PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE%TYPE;
    l_scrn_ent_val         PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE%TYPE;
    l_value                VARCHAR2(250);
    l_effective_start_date DATE:= NULL;

  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    l_value                := null;
    l_effective_start_date := null;
	-- Begin Bug# 4753092
	g_message_name := 'Fetch Element: Retirement Plan';
	-- End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'Retirement Plan'
                                 ,p_input_value_name     =>  'Plan'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.retirement_plan                   :=  l_value;

    l_value                := null;
    l_effective_start_date := null;
	-- Begin Bug# 4753092
	g_message_name := 'Fetch Element: FEGLI';
	-- End Bug# 4753092
    ghr_per_sum.get_element_details(p_element_name       => 'FEGLI'
                                 ,p_input_value_name     => 'FEGLI'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.fegli                             :=  l_value;
    p_sr_ghr_cpdf_temp.fegli_elect_date                  :=  l_effective_start_date;


    l_value                := null;
    l_effective_start_date := null;
	-- Begin Bug# 4753092
	g_message_name := 'Fetch Element: TSP Amount';
	-- End Bug# 4753092
    ghr_per_sum.get_element_details(p_element_name       => 'TSP'
                                 ,p_input_value_name     => 'Amount'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    IF l_value IS NOT NULL THEN
      p_sr_ghr_cpdf_temp.tsp_emp_amount                    :=  to_number(l_value);
      p_sr_ghr_cpdf_temp.tsp_effective_date                :=  l_effective_start_date;
    END IF;

    l_value                := null;
    l_effective_start_date := null;
	-- Begin Bug# 4753092
	g_message_name := 'Fetch Element: TSP Rate';
	-- End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'TSP'
                                 ,p_input_value_name     =>  'Rate'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    IF l_value IS NOT NULL THEN
      p_sr_ghr_cpdf_temp.tsp_elect_contrib_pct             :=  to_number(l_value);
      p_sr_ghr_cpdf_temp.tsp_effective_date                :=  l_effective_start_date;
    END IF;

    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element: TSP Elig Date';
	--End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'TSP'
                                 ,p_input_value_name     =>  'Agncy Contrib Elig Date'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.tsp_eligibility_date              :=  fnd_date.canonical_to_date(l_value);


    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element: HB Pre Tax plan';
	--End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'Health Benefits Pre tax'
                                 ,p_input_value_name     =>  'Health Plan'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.health_plan                       :=  l_value;
    -- BUG#6158983
    p_sr_ghr_cpdf_temp.fehb_elect_eff_date := l_effective_start_date;
    -- End  BUG#6158983


    -- Report Plan + Enrollment as Health Plan.
    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element: HB Pre tax Enrl';
	--End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'Health Benefits Pre tax'
                                 ,p_input_value_name     =>  'Enrollment'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

       IF l_value is NOT NULL THEN
         p_sr_ghr_cpdf_temp.health_plan                       :=  NVL(p_sr_ghr_cpdf_temp.health_plan, '  ') || l_value;
       END IF;

    IF p_sr_ghr_cpdf_temp.health_plan is NULL THEN
      l_value                := null;
      l_effective_start_date := null;
	  --Begin Bug# 4753092
	  g_message_name := ' Fetch Element: HB plan';
	  --End Bug# 4753092
      ghr_per_sum.get_element_details (p_element_name      =>  'Health Benefits'
                                   ,p_input_value_name     =>  'Health Plan'
                                   ,p_assignment_id        =>  p_sr_assignment_id
                                   ,p_effective_date       =>  p_sr_report_date
                                   ,p_value                =>  l_value
                                   ,p_effective_start_date =>  l_effective_start_date
                                   ,p_business_group_id    =>  g_business_group_id);

      p_sr_ghr_cpdf_temp.health_plan                       :=  l_value;
      -- BUG#6158983
      p_sr_ghr_cpdf_temp.fehb_elect_eff_date := l_effective_start_date;
      --End of BUG# 6158983

      -- Report Plan + Enrollment as Health Plan.
      l_value                := null;
      l_effective_start_date := null;
	  --Begin Bug# 4753092
	  g_message_name := ' Fetch Element: HB Enrollment';
	  --End Bug# 4753092
      ghr_per_sum.get_element_details (p_element_name      =>  'Health Benefits'
                                   ,p_input_value_name     =>  'Enrollment'
                                   ,p_assignment_id        =>  p_sr_assignment_id
                                   ,p_effective_date       =>  p_sr_report_date
                                   ,p_value                =>  l_value
                                   ,p_effective_start_date =>  l_effective_start_date
                                   ,p_business_group_id    =>  g_business_group_id);

      p_sr_ghr_cpdf_temp.health_plan                       :=  NVL(p_sr_ghr_cpdf_temp.health_plan, '  ') || l_value;
    END IF;

    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element: Total Pay';
	--End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'Total Pay'
                                 ,p_input_value_name     =>  'Amount'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.to_total_salary                   :=  to_number(l_value);

    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element: Basic Salary';
	--End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'Basic Salary Rate'
                                 ,p_input_value_name     =>  'Rate'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.to_basic_pay                      :=  to_number(l_value);

    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element: Adj Basic Pay';
	--End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'Adjusted Basic Pay'
                                 ,p_input_value_name     =>  'Amount'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.to_adj_basic_pay                  :=  to_number(l_value);

    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element: Locality Pay';
	--End Bug# 4753092
    -- FWFA Changes Bug#4444609
    ghr_per_sum.get_element_details (p_element_name      =>  'Locality Pay or SR Supplement'
    -- FWFA Changes Modify 'Locality Pay' to 'Locality Pay or SR Supplement'
                                 ,p_input_value_name     =>  'Rate'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    IF to_number(l_value) = 0 THEN
      p_sr_ghr_cpdf_temp.to_locality_adj                   :=  NULL;
    ELSE
      p_sr_ghr_cpdf_temp.to_locality_adj                   :=  to_number(l_value);
    END IF;


    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element: Staffing Diff';
	--End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'Staffing Differential'
                                 ,p_input_value_name     =>  'Amount'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.to_staffing_differential          :=  to_number(l_value);

    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element:Supervisory Diff';
	--End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'Supervisory Differential'
                                 ,p_input_value_name     =>  'Amount'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.to_supervisory_differential       :=  to_number(l_value);
    l_value                := null;
    l_effective_start_date := null;
	--Begin Bug# 4753092
	g_message_name := 'Fetch Element:Retention Allow';
	--End Bug# 4753092
    ghr_per_sum.get_element_details (p_element_name      =>  'Retention Allowance'
                                 ,p_input_value_name     =>  'Amount'
                                 ,p_assignment_id        =>  p_sr_assignment_id
                                 ,p_effective_date       =>  p_sr_report_date
                                 ,p_value                =>  l_value
                                 ,p_effective_start_date =>  l_effective_start_date
                                 ,p_business_group_id    =>  g_business_group_id);

    p_sr_ghr_cpdf_temp.to_retention_allowance            :=  to_number(l_value);

    -- JH EHRI Placeholder for Benefits stuff setting to null for now per Rohini.
/*
    -- Bug 4469808
    p_sr_ghr_cpdf_temp.alb_indicator            := null;
    p_sr_ghr_cpdf_temp.alb_elect_date           := null;
    p_sr_ghr_cpdf_temp.alb_notify_date          := null;
    p_sr_ghr_cpdf_temp.cont_elect_date          := null;
    p_sr_ghr_cpdf_temp.cont_notify_date         := null;

*/

--Bug 6158983
/*    p_sr_ghr_cpdf_temp.fegli_indicator          := null;
   p_sr_ghr_cpdf_temp.fegli_elect_date         := null;  --Used this name for elect effective date.
    p_sr_ghr_cpdf_temp.fegli_notify_date        := null;
    p_sr_ghr_cpdf_temp.fehb_indicator           := null;
    p_sr_ghr_cpdf_temp.fehb_elect_date          := null;
    p_sr_ghr_cpdf_temp.fehb_notify_date         := null;
    p_sr_ghr_cpdf_temp.retire_indicator         := null;
    p_sr_ghr_cpdf_temp.retire_elect_date        := null;
    p_sr_ghr_cpdf_temp.retire_notify_date       := null;
    p_sr_ghr_cpdf_temp.cont_term_elect_date     := null;
    p_sr_ghr_cpdf_temp.cont_ins_pay_notify_date := null;
    p_sr_ghr_cpdf_temp.cont_pay_type_code       := null;
    p_sr_ghr_cpdf_temp.fegli_life_change_code   := null;
    p_sr_ghr_cpdf_temp.fegli_life_event_date    := null;
    p_sr_ghr_cpdf_temp.fehb_event_code          := null;*/

  END get_from_history_payele;

  PROCEDURE calc_is_foreign_duty_station
           ( p_report_date    in date
           )
  IS
    l_proc                    varchar2(30) := 'calc_is_foreign_duty_station';
    l_log_text                ghr_process_log.log_text%type;
    l_message_name           	ghr_process_log.message_name%type;
    l_log_date               	ghr_process_log.log_date%type;

    CURSOR CALCDUTSTA_CUR IS
    SELECT STATE_OR_COUNTRY_CODE
      FROM GHR_DUTY_STATIONS_F
     WHERE trunc(p_report_date) between effective_start_date and
                                    nvl(effective_end_date, p_report_date)
       AND DUTY_STATION_ID =
           (SELECT LEI_INFORMATION3
            FROM HR_LOCATION_EXTRA_INFO
            WHERE INFORMATION_TYPE = 'GHR_US_LOC_INFORMATION'
              AND LOCATION_ID      = g_location_id);

    l_STATE_CNTRY_CODE         GHR_DUTY_STATIONS_F.STATE_OR_COUNTRY_CODE%TYPE;

  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    OPEN CALCDUTSTA_CUR;

    FETCH CALCDUTSTA_CUR INTO l_STATE_CNTRY_CODE;

    CLOSE CALCDUTSTA_CUR;

    --  a determination of whether a duty station is foreign or domestic
    --    has been hard-coded.  at the time this proc was written, there
    --    was talk that a future release of GHR would represent this value
    --    as a flexfield (i.e., no need to calculate).  furthermore,
    --    the ghr_cpdf_temp.from_duty_station_code will be used as
    --    a temporary storage for this value


    IF (l_STATE_CNTRY_CODE >= '01' AND
        l_STATE_CNTRY_CODE <= '99' )  OR
        l_STATE_CNTRY_CODE IN ('GQ','RQ','AQ','FM','JQ',
                             'CQ','MQ','RM','HQ','PS',
                             'BQ','WQ','VQ')
    THEN
      g_ghr_cpdf_temp.from_duty_station_code := 'N';
    ELSE
      g_ghr_cpdf_temp.from_duty_station_code := 'Y';
    END IF;

  END calc_is_foreign_duty_station;

  PROCEDURE insert_row
  IS
    l_proc                 varchar2(30) := 'insert_row';
    l_log_text             ghr_process_log.log_text%type;
    l_message_name         ghr_process_log.message_name%type;

  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    -- Bug#3231946 Added reference to parameters as the function definition is changed
    IF NOT (ghr_cpdf_dynrpt.get_loc_pay_area_code(p_duty_station_id => g_duty_station_id,
			                          p_effective_date  => g_ghr_cpdf_temp.effective_date) <> '99')
    THEN
      g_ghr_cpdf_temp.from_locality_adj := NULL;
      g_ghr_cpdf_temp.to_locality_adj   := NULL;
    ELSIF ghr_cpdf_dynrpt.get_equivalent_pay_plan(
     NVL(g_ghr_cpdf_temp.retained_pay_plan, g_ghr_cpdf_temp.to_pay_plan)) = 'FW'
    THEN
      g_ghr_cpdf_temp.from_locality_adj := NULL;
      g_ghr_cpdf_temp.to_locality_adj   := NULL;
    END IF;

	hr_utility.set_location('Inside insert row Locality adj' ||  g_ghr_cpdf_temp.to_locality_adj,111 );


    INSERT INTO ghr_cpdf_temp (
                   report_type
                  ,session_id
                  ,academic_discipline
                  ,agency_code
                  ,annuitant_indicator
                  ,award_amount
                  ,bargaining_unit_status
                  ,benefit_amount
                  ,citizenship
                  ,creditable_military_service
                  ,current_appointment_auth1
                  ,current_appointment_auth2
                  ,to_duty_station_code
                  ,education_level
                  ,effective_date
                  ,employee_date_of_birth
                  ,employee_first_name
                  ,employee_last_name
                  ,employee_middle_names
                  ,from_national_identifier
                  ,fegli
                  ,fers_coverage
                  ,first_action_la_code1
                  ,first_action_la_code2
                  ,first_noa_code
                  ,flsa_category
                  ,from_basic_pay
                  ,from_duty_station_code
                  ,from_grade_or_level
                  ,from_locality_adj
                  ,from_occ_code
                  ,from_pay_table_id
                  ,from_pay_basis
                  ,from_pay_plan
                  ,from_pay_rate_determinant
                  ,from_retirement_coverage
                  ,from_step_or_rate
                  ,from_total_salary
                  ,from_work_schedule
                  ,frozen_service
                  ,functional_class
                  ,handicap_code
                  ,health_plan
                  ,individual_group_award
                  ,organizational_component
                  ,pay_status
                  ,personnel_office_id
                  ,position_occupied
                  ,race_national_origin
                  ,rating_of_record
                  ,rating_of_record_level
                  ,rating_of_record_pattern
                  ,rating_of_record_period_starts
                  ,rating_of_record_period_ends
                  ,retained_grade_or_level
                  ,retained_pay_plan
                  ,retained_step_or_rate
                  ,retirement_plan
                  ,second_noa_code
                  ,service_comp_date
                  ,sex
                  ,supervisory_status
                  ,tenure
                  ,to_basic_pay
                  ,to_grade_or_level
                  ,to_locality_adj
                  ,to_national_identifier
                  ,to_occ_code
                  ,to_pay_basis
                  ,to_pay_plan
                  ,to_pay_rate_determinant
                  ,to_pay_table_id
                  ,to_retention_allowance
                  ,to_staffing_differential
                  ,to_step_or_rate
                  ,to_supervisory_differential
                  ,to_total_salary
                  ,to_work_schedule
                  ,veterans_preference
                  ,veterans_status
                  ,year_degree_attained,
				name_title,
				position_title,
				award_dollars,
				award_hours,
				award_percentage,
				SCD_retirement,
				SCD_rif,
-- New EHRI Starts Here ---
                  ehri_employee_id,
                  agency_employee_id,
                  world_citizenship,
                  slct_serv_regi_indicator,
                  svc_oblig_type_code1,
                  svc_oblig_type_end_date1,
                  svc_oblig_type_code2,
                  svc_oblig_type_end_date2,
                  svc_oblig_type_code3,
                  svc_oblig_type_end_date3,
                  svc_oblig_type_code4,
                  svc_oblig_type_end_date4,
                  appoint_type_code,
                  part_time_hours,
                  to_adj_basic_pay,
                  spcl_pay_tbl_type,
                  act_svc_indicator,
                  appropriation_code,
                  comp_pos_indicator,
                  mil_char_svc_code,
                  mil_svc_sno,
                  mil_svc_start_date,
                  mil_svc_end_date,
                  mil_branch_code,
                  mil_discharge_code,
                  career_tenure_code,
                  fegli_life_change_code,
                  fegli_life_event_date,
                  fegli_elect_date,
                  fehb_event_code,
                  tsp_eligibility_date,
                  tsp_effective_date,
                  tsp_elect_contrib_pct,
                  tsp_emp_amount,
                  fers_elect_date,
                  fers_elect_indicator,
                  alb_indicator,
                  alb_elect_date,
                  alb_notify_date,
                  fegli_indicator,
                  --fegli_elect_date,
                  fegli_notify_date,
                  fehb_indicator,
                  fehb_elect_date,
		  --bug# 6158983
		  fehb_elect_eff_date,
		  appointment_nte_date,
		  --6158983
                  fehb_notify_date,
                  retire_indicator,
                  retire_elect_date,
                  retire_notify_date,
                  cont_elect_date,
                  cont_notify_date,
                  cont_term_elect_date,
                  cont_ins_pay_notify_date,
                  cont_pay_type_code,
                  scd_ses,
                  scd_spcl_retire,
                  leave_scd,
                  tsp_scd,
                  disability_retire_notify,
                  work_address_line1,
                  work_address_line2,
                  work_address_line3,
                  work_address_line4,
                  work_city,
                  work_region, --Bug# 4725292
                  work_state_code,
                  work_postal_code,
                  work_country_code,
                  work_employee_email,
                  work_phone_number,
                  home_phone_number,
                  cell_phone_number,
                  emrgncy_cntct_family_name1,
                  emrgncy_cntct_given_name1,
                  emrgncy_cntct_middle_name1,
                  emrgncy_cntct_suffix1,
                  emrgncy_cntct_infrm_upd_dt1,
                  emrgncy_cntct_phone1,
                  emrgncy_cntct_family_name2,
                  emrgncy_cntct_given_name2,
                  emrgncy_cntct_middle_name2,
                  emrgncy_cntct_suffix2,
                  emrgncy_cntct_infrm_upd_dt2,
                  emrgncy_cntct_phone2,
                  language_code1,
                  lang_prof_type1,
                  lang_prof_level1,
                  language_code2,
                  lang_prof_type2,
                  lang_prof_level2,
                  language_code3,
                  lang_prof_type3,
                  lang_prof_level3,
                  language_code4,
                  lang_prof_type4,
                  lang_prof_level4,
                  language_code5,
                  lang_prof_type5,
                  lang_prof_level5,
                  language_code6,
                  lang_prof_type6,
                  lang_prof_level6,
                  language_code7,
                  lang_prof_type7,
                  lang_prof_level7,
                  language_code8,
                  lang_prof_type8,
                  lang_prof_level8,
                  spcl_salary_rate,
                  race_ethnic_info,
				  to_spl_rate_supplement
--			created_by,
--			creation_Date,
--			last_updated_by,
--			last_update_date,
--			last_update_login
			)
      values (
                   'STATUS'
                  ,userenv('SESSIONID')
                  ,g_ghr_cpdf_temp.academic_discipline
                  ,g_ghr_cpdf_temp.agency_code
                  ,g_ghr_cpdf_temp.annuitant_indicator
                  ,g_ghr_cpdf_temp.award_amount
                  ,g_ghr_cpdf_temp.bargaining_unit_status
                  ,g_ghr_cpdf_temp.benefit_amount
                  ,g_ghr_cpdf_temp.citizenship
                  ,g_ghr_cpdf_temp.creditable_military_service
                  ,g_ghr_cpdf_temp.current_appointment_auth1
                  ,g_ghr_cpdf_temp.current_appointment_auth2
                  ,g_ghr_cpdf_temp.to_duty_station_code
                  ,g_ghr_cpdf_temp.education_level
                  ,g_ghr_cpdf_temp.effective_date
                  ,g_ghr_cpdf_temp.employee_date_of_birth
                  ,g_ghr_cpdf_temp.employee_first_name
                  ,g_ghr_cpdf_temp.employee_last_name
                  ,g_ghr_cpdf_temp.employee_middle_names
                  ,g_ghr_cpdf_temp.from_national_identifier
                  ,g_ghr_cpdf_temp.fegli
                  ,g_ghr_cpdf_temp.fers_coverage
                  ,g_ghr_cpdf_temp.first_action_la_code1
                  ,g_ghr_cpdf_temp.first_action_la_code2
                  ,g_ghr_cpdf_temp.first_noa_code
                  ,g_ghr_cpdf_temp.flsa_category
                  ,g_ghr_cpdf_temp.from_basic_pay
                  ,g_ghr_cpdf_temp.from_duty_station_code
                  ,g_ghr_cpdf_temp.from_grade_or_level
                  ,g_ghr_cpdf_temp.from_locality_adj
                  ,g_ghr_cpdf_temp.from_occ_code
                  ,g_ghr_cpdf_temp.from_pay_table_id
                  ,g_ghr_cpdf_temp.from_pay_basis
                  ,g_ghr_cpdf_temp.from_pay_plan
                  ,g_ghr_cpdf_temp.from_pay_rate_determinant
                  ,g_ghr_cpdf_temp.from_retirement_coverage
                  ,g_ghr_cpdf_temp.from_step_or_rate
                  ,g_ghr_cpdf_temp.from_total_salary
                  ,g_ghr_cpdf_temp.from_work_schedule
                  ,g_ghr_cpdf_temp.frozen_service
                  ,g_ghr_cpdf_temp.functional_class
                  ,g_ghr_cpdf_temp.handicap_code
                  ,g_ghr_cpdf_temp.health_plan
                  ,g_ghr_cpdf_temp.individual_group_award
                  ,g_ghr_cpdf_temp.organizational_component
                  ,g_ghr_cpdf_temp.pay_status
                  ,g_ghr_cpdf_temp.personnel_office_id
                  ,g_ghr_cpdf_temp.position_occupied
                  ,g_ghr_cpdf_temp.race_national_origin
                  ,g_ghr_cpdf_temp.rating_of_record
                  ,g_ghr_cpdf_temp.rating_of_record_level
                  ,g_ghr_cpdf_temp.rating_of_record_pattern
                  ,g_ghr_cpdf_temp.rating_of_record_period_starts
                  ,g_ghr_cpdf_temp.rating_of_record_period_ends
                  ,g_ghr_cpdf_temp.retained_grade_or_level
                  ,g_ghr_cpdf_temp.retained_pay_plan
                  ,g_ghr_cpdf_temp.retained_step_or_rate
                  ,g_ghr_cpdf_temp.retirement_plan
                  ,g_ghr_cpdf_temp.second_noa_code
                  ,g_ghr_cpdf_temp.service_comp_date
                  ,g_ghr_cpdf_temp.sex
                  ,g_ghr_cpdf_temp.supervisory_status
                  ,g_ghr_cpdf_temp.tenure
                  ,g_ghr_cpdf_temp.to_basic_pay
                  ,g_ghr_cpdf_temp.to_grade_or_level
                  ,g_ghr_cpdf_temp.to_locality_adj
                  ,g_ghr_cpdf_temp.to_national_identifier
                  ,g_ghr_cpdf_temp.to_occ_code
                  ,g_ghr_cpdf_temp.to_pay_basis
                  ,g_ghr_cpdf_temp.to_pay_plan
                  ,g_ghr_cpdf_temp.to_pay_rate_determinant
                  ,g_ghr_cpdf_temp.to_pay_table_id
                  ,g_ghr_cpdf_temp.to_retention_allowance
                  ,g_ghr_cpdf_temp.to_staffing_differential
                  ,g_ghr_cpdf_temp.to_step_or_rate
                  ,g_ghr_cpdf_temp.to_supervisory_differential
                  ,g_ghr_cpdf_temp.to_total_salary
                  ,g_ghr_cpdf_temp.to_work_schedule
                  ,g_ghr_cpdf_temp.veterans_preference
                  ,g_ghr_cpdf_temp.veterans_status
                  ,g_ghr_cpdf_temp.year_degree_attained,
--			p_ghr_cpdf_temp_rec.employee_first_name,
--			p_ghr_cpdf_temp_rec.employee_middle_names,
			g_ghr_cpdf_temp.name_title,
			g_ghr_cpdf_temp.position_title,
			g_ghr_cpdf_temp.award_dollars,
			g_ghr_cpdf_temp.award_hours,
			g_ghr_cpdf_temp.award_percentage,
			g_ghr_cpdf_temp.SCD_retirement,
			g_ghr_cpdf_temp.SCD_rif,
                  -- JH NEW EHRI
                  g_ghr_cpdf_temp.ehri_employee_id,
                  g_ghr_cpdf_temp.agency_employee_id,
                  g_ghr_cpdf_temp.world_citizenship,
                  g_ghr_cpdf_temp.slct_serv_regi_indicator,
                  g_ghr_cpdf_temp.svc_oblig_type_code1,
                  g_ghr_cpdf_temp.svc_oblig_type_end_date1,
                  g_ghr_cpdf_temp.svc_oblig_type_code2,
                  g_ghr_cpdf_temp.svc_oblig_type_end_date2,
                  g_ghr_cpdf_temp.svc_oblig_type_code3,
                  g_ghr_cpdf_temp.svc_oblig_type_end_date3,
                  g_ghr_cpdf_temp.svc_oblig_type_code4,
                  g_ghr_cpdf_temp.svc_oblig_type_end_date4,
                  g_ghr_cpdf_temp.appoint_type_code,
                  g_ghr_cpdf_temp.part_time_hours,
                  g_ghr_cpdf_temp.to_adj_basic_pay,
                  g_ghr_cpdf_temp.spcl_pay_tbl_type,
                  g_ghr_cpdf_temp.act_svc_indicator,
                  g_ghr_cpdf_temp.appropriation_code,
                  g_ghr_cpdf_temp.comp_pos_indicator,
                  g_ghr_cpdf_temp.mil_char_svc_code,
                  g_ghr_cpdf_temp.mil_svc_sno,
                  g_ghr_cpdf_temp.mil_svc_start_date,
                  g_ghr_cpdf_temp.mil_svc_end_date,
                  g_ghr_cpdf_temp.mil_branch_code,
                  g_ghr_cpdf_temp.mil_discharge_code,
                  g_ghr_cpdf_temp.career_tenure_code,
                  g_ghr_cpdf_temp.fegli_life_change_code,
                  g_ghr_cpdf_temp.fegli_life_event_date,
                  g_ghr_cpdf_temp.fegli_elect_date,
                  g_ghr_cpdf_temp.fehb_event_code,
                  g_ghr_cpdf_temp.tsp_eligibility_date,
                  g_ghr_cpdf_temp.tsp_effective_date,
                  g_ghr_cpdf_temp.tsp_elect_contrib_pct,
                  g_ghr_cpdf_temp.tsp_emp_amount,
                  g_ghr_cpdf_temp.fers_elect_date,
                  g_ghr_cpdf_temp.fers_elect_indicator,
                  g_ghr_cpdf_temp.alb_indicator,
                  g_ghr_cpdf_temp.alb_elect_date,
                  g_ghr_cpdf_temp.alb_notify_date,
                  g_ghr_cpdf_temp.fegli_indicator,
                  --g_ghr_cpdf_temp.fegli_elect_date,
                  g_ghr_cpdf_temp.fegli_notify_date,
                  g_ghr_cpdf_temp.fehb_indicator,
                  g_ghr_cpdf_temp.fehb_elect_date,
		  --Bug# 6158983
                  g_ghr_cpdf_temp.fehb_elect_eff_date,
                  g_ghr_cpdf_temp.appointment_nte_date,
		  --Bug# 6158983
                  g_ghr_cpdf_temp.fehb_notify_date,
                  g_ghr_cpdf_temp.retire_indicator,
                  g_ghr_cpdf_temp.retire_elect_date,
                  g_ghr_cpdf_temp.retire_notify_date,
                  g_ghr_cpdf_temp.cont_elect_date,
                  g_ghr_cpdf_temp.cont_notify_date,
                  g_ghr_cpdf_temp.cont_term_elect_date,
                  g_ghr_cpdf_temp.cont_ins_pay_notify_date,
                  g_ghr_cpdf_temp.cont_pay_type_code,
                  g_ghr_cpdf_temp.scd_ses,
                  g_ghr_cpdf_temp.scd_spcl_retire,
                  g_ghr_cpdf_temp.leave_scd,
                  g_ghr_cpdf_temp.tsp_scd,
                  g_ghr_cpdf_temp.disability_retire_notify,
                  g_ghr_cpdf_temp.work_address_line1,
                  g_ghr_cpdf_temp.work_address_line2,
                  g_ghr_cpdf_temp.work_address_line3,
                  g_ghr_cpdf_temp.work_address_line4,
                  g_ghr_cpdf_temp.work_city,
                  g_ghr_cpdf_temp.work_region, --Bug# 4725292
                  g_ghr_cpdf_temp.work_state_code,
                  g_ghr_cpdf_temp.work_postal_code,
                  g_ghr_cpdf_temp.work_country_code,
                  g_ghr_cpdf_temp.work_employee_email,
                  g_ghr_cpdf_temp.work_phone_number,
                  g_ghr_cpdf_temp.home_phone_number,
                  g_ghr_cpdf_temp.cell_phone_number,
                  g_ghr_cpdf_temp.emrgncy_cntct_family_name1,
                  g_ghr_cpdf_temp.emrgncy_cntct_given_name1,
                  g_ghr_cpdf_temp.emrgncy_cntct_middle_name1,
                  g_ghr_cpdf_temp.emrgncy_cntct_suffix1,
                  g_ghr_cpdf_temp.emrgncy_cntct_infrm_upd_dt1,
                  g_ghr_cpdf_temp.emrgncy_cntct_phone1,
                  g_ghr_cpdf_temp.emrgncy_cntct_family_name2,
                  g_ghr_cpdf_temp.emrgncy_cntct_given_name2,
                  g_ghr_cpdf_temp.emrgncy_cntct_middle_name2,
                  g_ghr_cpdf_temp.emrgncy_cntct_suffix2,
                  g_ghr_cpdf_temp.emrgncy_cntct_infrm_upd_dt2,
                  g_ghr_cpdf_temp.emrgncy_cntct_phone2,
                  g_ghr_cpdf_temp.language_code1,
                  g_ghr_cpdf_temp.lang_prof_type1,
                  g_ghr_cpdf_temp.lang_prof_level1,
                  g_ghr_cpdf_temp.language_code2,
                  g_ghr_cpdf_temp.lang_prof_type2,
                  g_ghr_cpdf_temp.lang_prof_level2,
                  g_ghr_cpdf_temp.language_code3,
                  g_ghr_cpdf_temp.lang_prof_type3,
                  g_ghr_cpdf_temp.lang_prof_level3,
                  g_ghr_cpdf_temp.language_code4,
                  g_ghr_cpdf_temp.lang_prof_type4,
                  g_ghr_cpdf_temp.lang_prof_level4,
                  g_ghr_cpdf_temp.language_code5,
                  g_ghr_cpdf_temp.lang_prof_type5,
                  g_ghr_cpdf_temp.lang_prof_level5,
                  g_ghr_cpdf_temp.language_code6,
                  g_ghr_cpdf_temp.lang_prof_type6,
                  g_ghr_cpdf_temp.lang_prof_level6,
                  g_ghr_cpdf_temp.language_code7,
                  g_ghr_cpdf_temp.lang_prof_type7,
                  g_ghr_cpdf_temp.lang_prof_level7,
                  g_ghr_cpdf_temp.language_code8,
                  g_ghr_cpdf_temp.lang_prof_type8,
                  g_ghr_cpdf_temp.lang_prof_level8,
                  g_ghr_cpdf_temp.spcl_salary_rate,
                  g_ghr_cpdf_temp.race_ethnic_info,
				  g_ghr_cpdf_temp.to_spl_rate_supplement
      );

    EXCEPTION
	WHEN OTHERS THEN
        l_message_name := 'Unhandled Error';
        l_log_text     := 'Unhandled Error under procedure insert_row'||
        ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
        ghr_mto_int.log_message(p_procedure => l_message_name,
        p_message   => l_log_text);
        --dbms_output.put_line(l_log_text);
        COMMIT;

  END insert_row;

  PROCEDURE purge_suppression
  IS
    l_proc                        varchar2(30) := 'purge_suppression';
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    -- bug 743502 moved the checking of agency code matching the parameter passed in to
    -- to as soon as possible, not here at the end!
    -- Bug#5225838 Modified citizenship <> '1' to citizenship <>'Y'
    DELETE FROM ghr_cpdf_temp
      WHERE (report_type='STATUS')
        AND (
      -- *** SUPPRESS NON APPROPRIATED EMPLOYEES / COMMISSIONED OFFICERS
                ( to_pay_plan IN ('NA','NL','NS','CC') )
      -- *** EXCLUDE NON US CITIZENS WORKING IN FOREIGN DUTY STATIONS
             OR ( from_duty_station_code = 'Y'
                  AND decode(citizenship, NULL, ' ', citizenship) <> 'Y' )
      -- *** EXCLUDE CERTAIN AGENCIES
             OR ( agency_code IN ('CI00','DD05','DD28','FR00',
                                  'PO00','PJ00','TV00','WH01') )
      -- *** EXCLUDE CERTAIN SUBELEMENTS
             OR ( substr(agency_code,1,2) IN ('LL','LB','LA','LD','LG','LC') )
      -- *** EXCLUDE NON SELECTED AGENCY CODE
      --       OR ( decode(agency_code, NULL, ' ', agency_code)
      --              not like DECODE(g_agency,NULL,'%',rtrim(g_agency)||'%'))
            )
       ;

  END purge_suppression;

  PROCEDURE get_suffix_lname(p_last_name   in  varchar2,
                             p_report_date in  date,
                             p_suffix      out nocopy varchar2,
                             p_lname       out nocopy varchar2)
  IS
    l_suffix_pos number;
    l_total_len  number;
    l_proc       varchar2(30) := 'get_suffix_lname';


    CURSOR GET_SUFFIX IS
    SELECT INSTR(TRANSLATE(UPPER(p_last_name),',.','  '),' '||UPPER(LOOKUP_CODE),-1),
           LENGTH(p_last_name)
    FROM   HR_LOOKUPS
    WHERE  LOOKUP_TYPE = 'GHR_US_NAME_SUFFIX'
    AND    TRUNC(p_report_date) BETWEEN NVL(START_DATE_ACTIVE,p_report_date)
                                AND     NVL(END_DATE_ACTIVE,p_report_date)
    AND    RTRIM(SUBSTR(TRANSLATE(UPPER(p_last_name),',.','  '),
           INSTR(TRANSLATE(UPPER(p_last_name),',.','  '),' '||UPPER(LOOKUP_CODE),-1),
           LENGTH(p_last_name)),' ') = ' '||UPPER(LOOKUP_CODE)
    AND    ROWNUM = 1;
BEGIN

  hr_utility.set_location('Entering:'||l_proc,5);

  IF GET_SUFFIX%ISOPEN THEN
     CLOSE GET_SUFFIX;
  END IF;

  OPEN GET_SUFFIX;
  --getting the position of a suffix appended in the lastname by comparing the lastname
  --  with the suffixes available in lookup*/
  FETCH GET_SUFFIX INTO l_suffix_pos, l_total_len;
  IF GET_SUFFIX%NOTFOUND OR l_suffix_pos is NULL THEN
     p_lname  := RTRIM(p_last_name,' ,.');
     p_suffix := NULL;
  ELSE
     p_lname  := RTRIM(SUBSTR(p_last_name, 0, l_suffix_pos-1),' ,.');
     p_suffix := SUBSTR(p_last_name,l_suffix_pos+1,l_total_len);
  END IF;
  CLOSE GET_SUFFIX;
END get_suffix_lname;



---------------------------------------------------------------------------
--- THIS IS PROC TO GENERATE THE ASCII and XML file
---------------------------------------------------------------------------
--
PROCEDURE WritetoFile (p_input_file_name VARCHAR2
						,p_gen_xml_file IN VARCHAR2
						,p_gen_txt_file IN VARCHAR2)
 IS
  p_xml_fp UTL_FILE.FILE_TYPE;
  p_ascii_fp  UTL_FILE.FILE_TYPE;
  l_audit_log_dir varchar2(500);
  l_xml_file_name varchar2(500);
  l_ascii_file_name varchar2(500);
  l_output_xml_fname varchar2(500);
  l_output_ascii_fname varchar2(500);
  v_tags t_tags;
  l_count NUMBER;
  l_session_id NUMBER;
  l_request_id NUMBER;
  l_temp VARCHAR2(500);

  CURSOR c_cpdf_status(c_session_id NUMBER) IS
   SELECT *
   FROM GHR_CPDF_TEMP
   WHERE SESSION_ID  = c_session_id
   AND   report_type = 'STATUS';

  --
/*
  CURSOR c_out_dir(c_request_id fnd_concurrent_requests.request_id%type) IS
   SELECT outfile_name
   FROM FND_CONCURRENT_REQUESTS
   WHERE request_id = c_request_id;
*/
  --
  BEGIN
    -- Assigning the File name.
    l_xml_file_name :=  p_input_file_name || '.xml';
    l_ascii_file_name := p_input_file_name || '.txt';
    l_count := 1;
    l_session_id := USERENV('SESSIONID');

    /*
       l_request_id := fnd_profile.VALUE('CONC_REQUEST_ID');
       FOR l_out_dir IN c_out_dir(l_request_id) LOOP
        l_temp := l_out_dir.outfile_name;
       END LOOP;
       l_audit_log_dir := SUBSTR(l_temp,1,INSTR(l_temp,'o'||l_request_id)-1);
    */
    --
    select value
    into  l_audit_log_dir
    from  v$parameter
    where name = 'utl_file_dir';
    -- Check whether more than one util file directory is found
    IF INSTR(l_audit_log_dir,',') > 0 THEN
      l_audit_log_dir := substr(l_audit_log_dir,1,instr(l_audit_log_dir,',')-1);
    END IF;

    -- JH Display Output File Directory
    --dbms_output.put_line('Output File Directory '||l_audit_log_dir);

    -- Find out whether the OS is MS or Unix/Linux based
    -- If it's greater than 0, it's Unix/Linux based environment
    IF INSTR(l_audit_log_dir,'/') > 0 THEN
      l_output_xml_fname := l_audit_log_dir || '/' || l_xml_file_name;
      l_output_ascii_fname := l_audit_log_dir || '/' || l_ascii_file_name;
    ELSE
      l_output_xml_fname := l_audit_log_dir || '\' || l_xml_file_name;
	  l_output_ascii_fname := l_audit_log_dir || '\' || l_ascii_file_name;
    END IF;


--    fnd_file.put_line(fnd_file.log,'-----'||l_audit_log_dir);
	-- Bug 5013892
--    p_xml_fp := utl_file.fopen(l_audit_log_dir,l_xml_file_name,'w');
--    p_ascii_fp := utl_file.fopen(l_audit_log_dir,l_ascii_file_name,'w');
	 p_ascii_fp := utl_file.fopen(l_audit_log_dir,l_ascii_file_name,'w',32767);

	IF p_gen_xml_file = 'Y' THEN
		 p_xml_fp := utl_file.fopen(l_audit_log_dir,l_xml_file_name,'w',32767);
		 -- End Bug 5013892
	    utl_file.put_line(p_xml_fp,'<?xml version="1.0" encoding="UTF-8"?>');
		-- Writing from and to dates
	    utl_file.put_line(p_xml_fp,'<Records>');
		-- Loop through cursor and write the values into the XML and ASCII File.
		FOR ctr_table IN c_cpdf_status(l_session_id) LOOP
			WriteTagValues(ctr_table,v_tags);
			utl_file.put_line(p_xml_fp,'<Record' || l_count || '>');
			WriteXMLvalues(p_xml_fp,v_tags);
			utl_file.put_line(p_xml_fp,'</Record' || l_count || '>');
			WriteAsciivalues(p_ascii_fp,v_tags,p_gen_txt_file);
			l_count := l_count + 1;
		END LOOP;
		utl_file.put_line(p_xml_fp,'</Records>');
		utl_file.fclose(p_xml_fp);
	ELSE
		FOR ctr_table IN c_cpdf_status(l_session_id) LOOP
			WriteTagValues(ctr_table,v_tags);
			WriteAsciivalues(p_ascii_fp,v_tags,p_gen_txt_file);
			l_count := l_count + 1;
		END LOOP;
	END IF;

	l_count := l_count - 1;
	fnd_file.put_line(fnd_file.log,'------------------------------------------------');
	fnd_file.put_line(fnd_file.log,'Total Records : ' || l_count );
	fnd_file.put_line(fnd_file.log,'------------------------------------------------');
	-- Write the end tag and close the XML File.

	IF p_gen_xml_file = 'Y' OR p_gen_txt_file = 'Y' THEN
			fnd_file.put_line(fnd_file.log,'------------Path of output file----------------');
			IF p_gen_xml_file = 'Y' THEN
				fnd_file.put_line(fnd_file.log,'XML  file : ' || l_output_xml_fname);
			END IF;
			IF p_gen_txt_file = 'Y' THEN
				fnd_file.put_line(fnd_file.log,'Text file : ' || l_output_ascii_fname);
			END IF;
			fnd_file.put_line(fnd_file.log,'-------------------------------------------');
	END IF;
  END WritetoFile;

---------------------------------------------------------------------------------------------
-- This Procedure writes one record from the temporary table GHR_CPDF_TEMP
-- to a PL/SQL table p_tags at a time. This PL/SQL table p_tags is used to write to file.
---------------------------------------------------------------------------------------------

  PROCEDURE WriteTagValues(p_cpdf_status GHR_CPDF_TEMP%rowtype,p_tags OUT NOCOPY t_tags)
  IS
  l_count NUMBER;
  BEGIN
    l_count := 1;
    -- Writing to Tags
    p_tags(l_count).tagname := 'Social_Security_Number';
    p_tags(l_count).tagvalue := SUBSTR(p_cpdf_status.to_national_identifier,1,3) || '-' ||SUBSTR(p_cpdf_status.to_national_identifier,4,2) || '-' ||SUBSTR(p_cpdf_status.to_national_identifier,6) ;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Birth_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.employee_date_of_birth,'YYYY-MM-DD');
    l_count := l_count+1;

    -- Check this
    p_tags(l_count).tagname := 'EHRI_Employee_ID';
    p_tags(l_count).tagvalue := p_cpdf_status.ehri_employee_id;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Agency_Subelement_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.agency_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Name_Family';
    p_tags(l_count).tagvalue := p_cpdf_status.employee_last_name;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Name_Given';
    p_tags(l_count).tagvalue := p_cpdf_status.employee_first_name;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Name_Middle';
    p_tags(l_count).tagvalue := p_cpdf_status.employee_middle_names;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Name_Suffix';
    p_tags(l_count).tagvalue := p_cpdf_status.name_title;  -- Not included since Fed doesn't allow entry.
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Agency_Employee_id';
    p_tags(l_count).tagvalue := p_cpdf_status.agency_employee_id;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Veterans_Status_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.veterans_status;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Annuitant_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.annuitant_indicator;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'US_Citizenship_Indicator';
    p_tags(l_count).tagvalue := NVL(p_cpdf_status.citizenship,'NA');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Citizen_Country_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.world_citizenship;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Gender_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.sex;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Race_National_Origin_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.race_national_origin;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Disability_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.handicap_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Selective_Service_Registration_Indicator';
    p_tags(l_count).tagvalue := NVL(p_cpdf_status.slct_serv_regi_indicator,'NA');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Duty_Station_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.to_duty_station_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Veterans_Preference_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.veterans_preference;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Service_Obligation_Type_Code_1';
    p_tags(l_count).tagvalue := p_cpdf_status.svc_oblig_type_code1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Service_Obligation_End_Date_1';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.svc_oblig_type_end_date1,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Service_Obligation_Type_Code_2';
    p_tags(l_count).tagvalue := p_cpdf_status.svc_oblig_type_code2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Service_Obligation_End_Date_2';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.svc_oblig_type_end_date2,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Service_Obligation_Type_Code_3';
    p_tags(l_count).tagvalue := p_cpdf_status.svc_oblig_type_code3;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Service_Obligation_End_Date_3';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.svc_oblig_type_end_date3,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Service_Obligation_Type_Code_4';
    p_tags(l_count).tagvalue := p_cpdf_status.svc_oblig_type_code4;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Service_Obligation_End_Date_4';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.svc_oblig_type_end_date4,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Instructional_Program_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.academic_discipline;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Education_Level_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.education_level;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Degree_Year';
    p_tags(l_count).tagvalue := p_cpdf_status.year_degree_attained;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Grade_Level_Class_Rank_or_Pay_Band';
    p_tags(l_count).tagvalue := p_cpdf_status.to_grade_or_level;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Step_or_Rate_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.to_step_or_rate;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Organizational_Component_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.organizational_component;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Appointment_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.appoint_type_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Functional_Classification_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.functional_class;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Occupational_Series_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.to_occ_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Supervisory_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.supervisory_status;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Personnel_Office_identifier_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.personnel_office_id;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Schedule_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.to_work_schedule;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Part_Time_Hours';
    p_tags(l_count).tagvalue := p_cpdf_status.part_time_hours;
    l_count := l_count+1;

	p_tags(l_count).tagname := 'Special_Rate_Supplement';
	p_tags(l_count).tagvalue := p_cpdf_status.to_spl_rate_supplement;
	l_count := l_count+1;

/*    p_tags(l_count).tagname := 'Special_Salary_Rate';
    p_tags(l_count).tagvalue := p_cpdf_status.spcl_salary_rate;
    l_count := l_count+1; */

   -- Begin Bug# 5011025
	IF p_cpdf_status.to_pay_basis <> 'PA' THEN
		p_tags(l_count).tagname := 'Total_Pay_Rate';
		p_tags(l_count).tagvalue := ltrim(to_char(p_cpdf_status.to_total_salary,'99999999.99'));
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Basic_Pay_Amount';
		p_tags(l_count).tagvalue := ltrim(to_char(p_cpdf_status.to_basic_pay,'99999999.99'));
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Adjusted_Basic_Pay_Amount';
		p_tags(l_count).tagvalue := ltrim(to_char(p_cpdf_status.to_adj_basic_pay,'99999999.99'));
		l_count := l_count+1;
	ELSE
		p_tags(l_count).tagname := 'Total_Pay_Rate';
		p_tags(l_count).tagvalue := p_cpdf_status.to_total_salary;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Basic_Pay_Amount';
		p_tags(l_count).tagvalue := p_cpdf_status.to_basic_pay;
		l_count := l_count+1;

		p_tags(l_count).tagname := 'Adjusted_Basic_Pay_Amount';
		p_tags(l_count).tagvalue := p_cpdf_status.to_adj_basic_pay;
		l_count := l_count+1;
	END IF;
	-- End Bug# 5011025

    p_tags(l_count).tagname := 'Locality_Pay_Amount';
    p_tags(l_count).tagvalue := p_cpdf_status.to_locality_adj;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Supervisor_Differential_Amount';
    p_tags(l_count).tagvalue := p_cpdf_status.to_supervisory_differential;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Retention_Allowance_Amount';
    p_tags(l_count).tagvalue := p_cpdf_status.to_retention_allowance;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Pay_Status_Type';
    p_tags(l_count).tagvalue := p_cpdf_status.pay_status;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Position_Title';
    p_tags(l_count).tagvalue := p_cpdf_status.position_title;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Position_Occupied_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.position_occupied;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Pay_Basis_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.to_pay_basis;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Pay_Plan_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.to_pay_plan;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Pay_Rate_Determinant_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.to_pay_rate_determinant;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Special_Pay_Table_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.spcl_pay_tbl_type;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Active_Uniformed_Service_Indicator';
    p_tags(l_count).tagvalue := p_cpdf_status.act_svc_indicator;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'FLSA_Category_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.FLSA_Category;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Bargaining_Unit_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.bargaining_unit_status;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Appropriation_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.appropriation_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Computer_Position_Indicator';
    p_tags(l_count).tagvalue := NVL(p_cpdf_status.comp_pos_indicator,'NA');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Military_Character_of_Service_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.mil_char_svc_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Military_Service_Serial_Number';
    p_tags(l_count).tagvalue := p_cpdf_status.mil_svc_sno;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Military_Service_Start_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.mil_svc_start_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Military_Service_End_Date';
	p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.mil_svc_end_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Military_Branch_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.mil_branch_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Military_Discharge_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.mil_discharge_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Creditable_Military_Service_Years';
    p_tags(l_count).tagvalue := SUBSTR(p_cpdf_status.creditable_military_service,1,2);
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Creditable_Military_Service_Months';
    p_tags(l_count).tagvalue := SUBSTR(p_cpdf_status.creditable_military_service,3,2);
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Creditable_Military_Service_Days';
    p_tags(l_count).tagvalue := SUBSTR(p_cpdf_status.creditable_military_service,5,2);
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Rating_of_Record_Level_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.rating_of_record_level;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Rating_of_Record_Pattern_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.rating_of_record_pattern;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Rating_Record_Period_Start_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.rating_of_record_period_starts,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Rating_Record_Period_End_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.rating_of_record_period_ends,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Tenure_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.tenure;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Career_Tenure_Authority_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.career_tenure_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Federal_Employees_Group_Life_Insurance_FEGLI_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.fegli;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Federal_Employees_Group_Life_Insurance_FEGLI_Life_Change_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.fegli_life_change_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Federal_Employees_Group_Life_Insurance_FEGLI_Life_Event_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.fegli_life_event_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Federal_Employees_Group_Life_Insurance_FEGLI_Election_Effective_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.fegli_elect_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Federal_Employees_Health_Benefits_FEHB_Plan_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.health_plan;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'FEHB_Event_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.fehb_event_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Thrift_Savings_Plan_TSP_Eligibility_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.tsp_eligibility_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Thrift_Savings_Plan_TSP_Effective_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.tsp_effective_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Thrift_Savings_Plan_TSP_Election_Contribution_Percent';
    p_tags(l_count).tagvalue := p_cpdf_status.tsp_elect_contrib_pct;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Thrift_Savings_Plan_TSP_Election_Contribution_Amount';
    p_tags(l_count).tagvalue := p_cpdf_status.tsp_emp_amount;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Federal_Employees_Retirement_System_FERS_Coverage_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.fers_coverage;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Federal_Employees_Retirement_System_FERS_Elect_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.fers_elect_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Federal_Employees_Retirement_System_FERS_Election_Indicator';
    p_tags(l_count).tagvalue := p_cpdf_status.fers_elect_indicator;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Retained_Grade_Level_Class_Rank_or_Pay_Brand_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.retained_grade_or_level;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Retained_Pay_Plan_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.retained_pay_plan;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Retained_Step_or_Rate_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.retained_step_or_rate;
    l_count := l_count+1;

/*
    -- Bug 4469808
    p_tags(l_count).tagname := 'Benefits_Continuation_Annual_Leave_Balance_Indicator';
    p_tags(l_count).tagvalue := p_cpdf_status.alb_indicator;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Annual_Leave_Balance_Election_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.alb_elect_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Annual_Leave_Balance_Election_Notification_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.alb_notify_date,'YYYY-MM-DD');
    l_count := l_count+1;
*/

    p_tags(l_count).tagname := 'Benefits_Continuation_Federal_Employees_Group_Life_Insurance_FEGLI_Indicator';
    p_tags(l_count).tagvalue := NVL(p_cpdf_status.fegli_indicator,'NA');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Employees_Group_Life_Insurance_FEGLI_Election_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.fegli_elect_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Employees_Group_Life_Insurance_FEGLI_Election_Notification_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.fegli_notify_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Federal_Employee_Health_Benefits_FEHB_Indicator';
    p_tags(l_count).tagvalue := NVL(p_cpdf_status.fehb_indicator,'NA');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Federal_Employee_Health_Benefits_FEHB_Election_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.fehb_elect_date,'YYYY-MM-DD');
    l_count := l_count+1;


    p_tags(l_count).tagname := 'Benefits_Continuation_Federal_Employee_Health_Benefits_FEHB_Election_Notification_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.fehb_notify_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Retirement_Indicator';
    p_tags(l_count).tagvalue := NVL(p_cpdf_status.retire_indicator,'NA');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Retirement_Election_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.retire_elect_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Retirement_Election_Notification_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.retire_notify_date,'YYYY-MM-DD');
    l_count := l_count+1;

/*
    -- Bug 4469808
    p_tags(l_count).tagname := 'Benefits_Continuation_Election_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.cont_elect_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Election_Notification_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.cont_notify_date,'YYYY-MM-DD');
    l_count := l_count+1;
*/

    p_tags(l_count).tagname := 'Benefits_Continuation_Termination_Insufficient_Pay_Election_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.cont_term_elect_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Termination_Insufficient_Pay_Notification_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.cont_ins_pay_notify_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Benefits_Continuation_Termination_Insufficient_Pay_Payment_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.cont_pay_type_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Retirement_Service_Computation_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.scd_retirement,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'RIF_Service_Computation_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.SCD_RIF,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'SES_Service_Computation_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.scd_ses,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Special_Retirement_Service_Computation_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.scd_spcl_retire,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Leave_Service_Computation_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.leave_scd,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Thrift_Savings_Plan_Service_Computation_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.tsp_scd,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Intergovernmental_Personnel_Act_IPA_Entitlements_Benefits_Notification_Text';
    p_tags(l_count).tagvalue := null;  -- Add to Temp too!
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Retirement_System_Type_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.retirement_plan;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Disability_Retirement_Notification_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.disability_retire_notify,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Frozen_Service_Years';
    p_tags(l_count).tagvalue := SUBSTR(p_cpdf_status.frozen_service,1,2);
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Frozen_Service_Months';
    p_tags(l_count).tagvalue := SUBSTR(p_cpdf_status.frozen_service,3,2);
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Frozen_Service_Days';
    p_tags(l_count).tagvalue := SUBSTR(p_cpdf_status.frozen_service,5,2);
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Current_Appointment_Authority_Code_1';
    p_tags(l_count).tagvalue := p_cpdf_status.current_appointment_auth1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Current_Appointment_Authority_Code_2';
    p_tags(l_count).tagvalue := p_cpdf_status.current_appointment_auth2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Address_Line_1';
    p_tags(l_count).tagvalue := p_cpdf_status.work_address_line1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Address_Line_2';
    p_tags(l_count).tagvalue := p_cpdf_status.work_address_line2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Address_Line_3';
    p_tags(l_count).tagvalue := p_cpdf_status.work_address_line3;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Address_Line_4';
    p_tags(l_count).tagvalue := p_cpdf_status.work_address_line4;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_City';
    p_tags(l_count).tagvalue := p_cpdf_status.work_city;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Geographic_Locator_Code';
    IF p_cpdf_status.work_address_line1 IS NOT NULL THEN --Bug# 6973541
        p_tags(l_count).tagvalue := p_cpdf_status.to_duty_station_code;
    END IF; --Bug# 6973541
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_State_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.work_state_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Postal_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.work_postal_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Region';
    p_tags(l_count).tagvalue := p_cpdf_status.work_region;  --Bug# 4725292
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Country_Code';
    p_tags(l_count).tagvalue := p_cpdf_status.work_country_code;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Employee_Work_Email';
    p_tags(l_count).tagvalue := p_cpdf_status.work_employee_email;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Work_Phone_Number';
    p_tags(l_count).tagvalue := p_cpdf_status.work_phone_number;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Home_Phone_Number';
    p_tags(l_count).tagvalue := p_cpdf_status.home_phone_number;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Cell_Phone_Number';
    p_tags(l_count).tagvalue := p_cpdf_status.cell_phone_number;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Family_Name_1';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_family_name1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Given_Name_1';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_given_name1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Middle_Name_1';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_middle_name1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Name_Suffix_1';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_suffix1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Information_Update_Date_1';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.emrgncy_cntct_infrm_upd_dt1,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Phone_Number_1';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_phone1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Family_Name_2';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_family_name2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Given_Name_2';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_given_name2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Middle_Name_2';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_middle_name2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Name_Suffix_2';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_suffix2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Information_Update_Date_2';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.emrgncy_cntct_infrm_upd_dt2,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Emergency_Contact_Phone_Number_2';
    p_tags(l_count).tagvalue := p_cpdf_status.emrgncy_cntct_phone2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Code_1';
    p_tags(l_count).tagvalue := p_cpdf_status.language_code1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Type_Code_1';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_type1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Level_Code_1';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_level1;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Code_2';
    p_tags(l_count).tagvalue := p_cpdf_status.language_code2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Type_Code_2';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_type2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Level_Code_2';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_level2;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Code_3';
    p_tags(l_count).tagvalue := p_cpdf_status.language_code3;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Type_Code_3';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_type3;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Level_Code_3';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_level3;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Code_4';
    p_tags(l_count).tagvalue := p_cpdf_status.language_code4;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Type_Code_4';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_type4;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Level_Code_4';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_level4;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Code_5';
    p_tags(l_count).tagvalue := p_cpdf_status.language_code5;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Type_Code_5';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_type5;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Level_Code_5';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_level5;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Code_6';
    p_tags(l_count).tagvalue := p_cpdf_status.language_code6;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Type_Code_6';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_type6;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Level_Code_6';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_level6;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Code_7';
    p_tags(l_count).tagvalue := p_cpdf_status.language_code7;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Type_Code_7';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_type7;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Level_Code_7';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_level7;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Code_8';
    p_tags(l_count).tagvalue := p_cpdf_status.language_code8;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Type_Code_8';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_type8;
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Language_Proficiency_Level_Code_8';
    p_tags(l_count).tagvalue := p_cpdf_status.lang_prof_level8;
    l_count := l_count+1;

    -- Bug 4714292 EHRI Reports Changes for EOY 05
	p_tags(l_count).tagname := 'Ethnicity_Code';
	p_tags(l_count).tagvalue := p_cpdf_status.race_ethnic_info;
	l_count := l_count+1;
	-- End Bug 4714292 EHRI Reports Changes for EOY 05
--Bug 6158983 EHRI Report Changes
    p_tags(l_count).tagname := 'Benefits_Continuation_Federal_Employees_Health_Benefits_FEHB_Election_Effective_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.fehb_elect_eff_date,'YYYY-MM-DD');
    l_count := l_count+1;

    p_tags(l_count).tagname := 'Appointment_Not_to_Exceed_NTE_Date';
    p_tags(l_count).tagvalue := TO_CHAR(p_cpdf_status.appointment_nte_date,'YYYY-MM-DD');
    l_count := l_count+1;

--End Bug 6158983 EHRI Report Changes



  END WriteTagValues;

-----------------------------------------------------------------------------
-- Writing the records from PL/SQL table p_tags into XML File
-----------------------------------------------------------------------------
PROCEDURE WriteXMLvalues(p_l_fp utl_file.file_type, p_tags t_tags )
IS
  BEGIN
    FOR l_tags IN p_tags.FIRST .. p_tags.LAST LOOP
     utl_file.put_line(p_l_fp,'<' || p_tags(l_tags).tagname || '>' || p_tags(l_tags).tagvalue || '</' || p_tags(l_tags).tagname || '>');
    END LOOP;
  END;

-----------------------------------------------------------------------------
-- Writing the records from PL/SQL table p_tags into Text and FND Output File
-----------------------------------------------------------------------------
    PROCEDURE WriteAsciivalues(p_l_fp utl_file.file_type, p_tags t_tags,p_gen_txt_file IN VARCHAR2 )
	IS
	l_temp VARCHAR2(4000);
	l_tot NUMBER;
	BEGIN
	   l_tot := p_tags.COUNT;
	   IF l_tot > 0 THEN
	       FOR l_tags IN p_tags.FIRST .. p_tags.LAST LOOP
	           IF l_tags = l_tot THEN
  	               l_temp := p_tags(l_tags).tagvalue;
				   IF p_gen_txt_file = 'Y' THEN
		               utl_file.put_line(p_l_fp,l_temp);
					END IF;
			       fnd_file.put_line(fnd_file.output,l_temp);
	            ELSE
		 	       l_temp := p_tags(l_tags).tagvalue || '|';
				   IF p_gen_txt_file = 'Y' THEN
		               utl_file.put(p_l_fp,l_temp);
				   END IF;
			       fnd_file.put(fnd_file.output,l_temp);
				END IF;
  	       END LOOP;
  	    END IF;

	END WriteAsciivalues;

--Bug# 8486208 added the following procedure
PROCEDURE get_agencies_from_group(p_agency_group IN VARCHAR2,
                                  p_agencies_with_se OUT NOCOPY VARCHAR2,
				  p_agencies_without_se OUT NOCOPY VARCHAR2)
 IS
l_agencies_with_se varchar2(240);
l_agencies_without_se varchar2(240);
l_prev NUMBER;
l_next NUMBER;
l_no_of_char NUMBER;

BEGIN
  l_agencies_with_se := NULL;
  l_agencies_without_se := NULL;
  l_prev :=1;

  loop
  l_next := instr(p_agency_group,',',l_prev);
    if l_next = 0 then
       l_next := length(p_agency_group)+1;
    end if;
  l_no_of_char := l_next -l_prev;

  if l_no_of_char > 2 then
     if l_agencies_with_se is NULL then
        l_agencies_with_se := substr(p_agency_group,l_prev,l_no_of_char);
     else
        l_agencies_with_se := l_agencies_with_se||','||substr(p_agency_group,l_prev,l_no_of_char);
     end if;
  else
     if l_agencies_without_se is NULL then
        l_agencies_without_se := substr(p_agency_group,l_prev,l_no_of_char);
     else
        l_agencies_without_se := l_agencies_without_se||','||substr(p_agency_group,l_prev,l_no_of_char);
     end if;
  end if;
  if l_next > length(p_agency_group) then
     exit;
  end if;
  l_prev := l_next+1;
  end loop;

  p_agencies_with_se := l_agencies_with_se;
  p_agencies_without_se := l_agencies_without_se;

END;

---------------------------------------------------------------------------------------------
-- This is the procedure to populate values into the temporary table GHR_CPDF_TEMP
---------------------------------------------------------------------------------------------
-- Bug 8486208 modified for new dynamic parameter
 PROCEDURE populate_ghr_cpdf_temp (p_agency       IN VARCHAR2,
                                   p_agency_group IN VARCHAR2,
                                   p_report_date  IN DATE,
                                   p_count_only   IN BOOLEAN)

  IS
    l_proc varchar2(30) := 'populate_ghr_cpdf_temp';

    CURSOR all_assignments_cur(p_agencies_with_se in varchar2,
                               p_agencies_without_se in varchar2)
       is
       SELECT asg.assignment_id,
              asg.person_id,
              asg.position_id,
              asg.grade_id,
              asg.job_id,
              asg.location_id,
              asg.effective_start_date,
	        asg.business_group_id,
              ast.per_system_status assignment_status_type,
              ghr_api.get_position_agency_code_pos(asg.position_id,asg.business_group_id) agency_code
         FROM PER_ALL_ASSIGNMENTS asg, per_assignment_status_types ast -- Changing from per_assignments_f
         WHERE ast.assignment_status_type_id = asg.assignment_status_type_id
            -- only consider "Active" assignments as defined by below, also only look at
		-- assignments that are assigned to a valid person as of the report date.
         AND   g_report_date between asg.effective_start_date and asg.effective_end_date
         AND   ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
         AND   asg.assignment_type <> 'B'
         AND   asg.position_id IS NOT NULL
	 --Bug 8486208 modified for new dynamic parameter
         AND   ((p_agency is not null and
	        ghr_api.get_position_agency_code_pos(asg.position_id,asg.business_group_id) like p_agency)
		OR
	        (p_agencies_with_se is not null and INSTR(p_agencies_with_se,ghr_api.get_position_agency_code_pos(asg.position_id,asg.business_group_id),1) > 0)
	        OR
		(p_agencies_without_se is not null and INSTR(p_agencies_without_se,substr(ghr_api.get_position_agency_code_pos(asg.position_id,asg.business_group_id),1,2),1) > 0)
		)
         AND decode(hr_general.get_xbg_profile,'Y',asg.business_group_id , hr_general.get_business_group_id) = asg.business_group_id
         ORDER BY assignment_id;
         -- Bug 3704123 - Adding order by clause for the above statement so that results will be in temp segment

    l_all_assignments_rec all_assignments_cur%ROWTYPE;
--- 3671043 Bug fix
    l_log_text                ghr_process_log.log_text%type;
    l_message_name           	ghr_process_log.message_name%type;
    l_log_date               	ghr_process_log.log_date%type;

CURSOR cur_per_details(p_person_id  per_all_people.person_id%type)
  IS
SELECT pap.full_name name ,pap.national_identifier ssn,pap.last_name,pap.first_name
      ,pap.middle_names, pap.title
FROM   per_all_people pap
WHERE  p_person_id = pap.person_id
AND    p_report_date between pap.effective_start_date AND pap.effective_end_date
AND    g_business_group_id = pap.business_group_id;

--Bug# 6158983
    --Bug# 6477035
  /*Cursor nte_date
      is
      SELECT  first_noa_information1
      FROM    ghr_pa_requests
      WHERE   employee_assignment_id = g_assignment_id
      AND     pa_notification_id  is not null
      AND     person_id              = g_person_id
      AND     to_position_id         = g_position_id
      AND     noa_family_code        = 'APP'
      AND     first_noa_information1 like '____%__%__ __:__:__'
      AND     fnd_date.canonical_to_date(first_noa_information1) >= g_report_date;*/

    Cursor nte_date
        is
        SELECT aei_information4
        FROM   ghr_assignment_extra_info_h_v
        WHERE  pa_history_id = (SELECT max(pa_history_id)
                                FROM   ghr_assignment_extra_info_h_v ASG,
                                       ghr_nature_of_actions NAT
                                WHERE information_type = 'GHR_US_ASG_NTE_DATES'
                                AND   asg.nature_of_action_id = nat.nature_of_action_id
                                AND   (code LIKE '1%' OR code LIKE '5%' OR code IN ('750','760','761','762','765'))
                                AND   aei_information4 IS NOT NULL
                                AND   assignment_id = g_assignment_id
                                AND   person_id     = g_person_id)
        AND   fnd_date.canonical_to_date(aei_information4) >= g_report_date;
 --Bug# 6477035

--Bug# 6158983



l_full_name		      per_all_people.full_name%type;
l_ssn			      per_all_people.national_identifier%type;
l_records_found		BOOLEAN;
l_mesgbuff1             VARCHAR2(4000);
l_assignment_status_type VARCHAR2(200);
l_suffix     VARCHAR2(30) := NULL;
l_last_name  VARCHAR2(150) := NULL;

-- FWFA Changes Declare variable l_calc_pay_table_id

Cursor c_pay_table_name (p_user_table_id number) is
 SELECT SUBSTR(user_table_name,1,4) user_table_name
   FROM pay_user_tables
  WHERE user_table_id = p_user_table_id;

  l_calc_pay_table_id     VARCHAR2(4);

  --8486208
  l_agencies_with_se VARCHAR2(240);
  l_agencies_without_se VARCHAR2(240);


-- This function returns true if the Pay Plan passed in is an 'GS' equivalent
    FUNCTION pp_gs_equivalent (p_pay_plan IN VARCHAR2)
      RETURN BOOLEAN IS
    CURSOR cur_ppl IS
      SELECT 1
      FROM   ghr_pay_plans ppl
      WHERE  ppl.pay_plan = p_pay_plan
      AND    ppl.equivalent_pay_plan = 'GS';
    --
    BEGIN
      FOR cur_ppl_rec IN cur_ppl LOOP
        RETURN(TRUE);
      END LOOP;
      --
      RETURN(FALSE);
    END pp_gs_equivalent;


  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
    ghr_mto_int.set_log_program_name('GHR_CPDF_EHRI_STATRPT');
    g_report_date := p_report_date;
    g_agency      := p_agency;
    l_records_found:=FALSE;
    cleanup_table;
    initialize_record;

    --8486208 added the following to get agencies with sub elements and with out sub elements
    if p_agency_group is not null then
      get_agencies_from_group(UPPER(p_agency_group),l_agencies_with_se, l_agencies_without_se);
    end if;
    FOR l_all_assignments_rec IN all_assignments_cur(l_agencies_with_se,l_agencies_without_se)
     LOOP

      BEGIN
       -- initialize every iteration
       initialize_record;
       -- assign globals
       g_assignment_id        := l_all_assignments_rec.assignment_id;

       --dbms_output.put_line('Assignment_id = '||g_assignment_id);
       g_person_id            := l_all_assignments_rec.person_id;
       g_position_id          := l_all_assignments_rec.position_id;
       g_grade_id             := l_all_assignments_rec.grade_id;
       g_job_id               := l_all_assignments_rec.job_id;
       g_location_id          := l_all_assignments_rec.location_id;
       g_ghr_cpdf_temp.agency_code := l_all_assignments_rec.agency_code;
       g_business_group_id    := l_all_assignments_rec.business_group_id;
       l_assignment_status_type := l_all_assignments_rec.assignment_status_type;
       -- Bug 714944 -- No not report on NAF positions:
       IF ghr_cpdf_dynrpt.exclude_position (p_position_id       => g_position_id
                                           ,p_effective_date    => g_report_date) THEN
         GOTO end_asg_loop;  -- loop for the next one!

       END IF;

       l_message_name := NULL;
	   g_message_name := NULL; --Bug# 4753092
       l_records_found:=TRUE;
       --
       --
    BEGIN

      FOR per_det in cur_per_details(g_person_id)
      LOOP
     -- Bug# 4648811 extracting suffix from the lastname and also removing suffix from lastname
      get_suffix_lname(per_det.last_name,
                       p_report_date,
                       l_suffix,
                       l_last_name);
     --End Bug# 4648811

	  g_ghr_cpdf_temp.employee_last_name    := l_last_name;
	  g_ghr_cpdf_temp.employee_first_name   := per_det.first_name;
	  g_ghr_cpdf_temp.employee_middle_names := per_det.middle_names;
	  g_ghr_cpdf_temp.name_title            := l_suffix;
      END LOOP;

      IF l_assignment_status_type = 'ACTIVE_ASSIGN' THEN
        g_ghr_cpdf_temp.pay_status := 'P';
      ELSIF l_assignment_status_type = 'SUSP_ASSIGN' THEN
        g_ghr_cpdf_temp.pay_status := 'N';
      END IF;

	  -- Begin Bug# 4753092
      g_message_name := 'Fetch Position title';
	  -- End Bug# 4753092
      g_ghr_cpdf_temp.position_title :=  ghr_api.get_position_title_pos(
                 p_position_id       => g_position_id,
                 p_business_group_id => g_business_group_id,
                 p_effective_date    => g_report_date);

       --
       -- Bug 3671043 Handling Exceptions (madhuri)
	   -- Bug# 4753092
       g_message_name := 'Fetch Appointment date';
       --dbms_output.put_line(l_message_name);
       get_appointment_date(p_person_id        => g_person_id
                           ,p_report_date      => g_report_date
                           ,p_appointment_date => g_appointment_date);
       --
       -- call fetch routines to populate record
       -- Bug# 4753092 commented below statment
       --l_message_name := 'get_from_history_asgnei';
       --dbms_output.put_line(l_message_name);
       get_from_history_asgnei
           (p_sr_assignment_id    => g_assignment_id
           ,p_sr_report_date      => g_report_date
           ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           );
       -- FWFA Change Get pay table id
       -- Bug#5063289 Fetch the First 4 characters of Pay table name.
       FOR pay_table_rec IN c_pay_table_name(g_ghr_cpdf_temp.to_pay_table_id)
       LOOP
           l_calc_pay_table_id := pay_table_rec.user_table_name;
       END LOOP;
      --Begin Bug# 4753092
	  --l_message_name := 'get_from_history_payele';
	  --End Bug# 4753092
      --dbms_output.put_line(l_message_name);
      get_from_history_payele
           (p_sr_assignment_id    => g_assignment_id
           ,p_sr_report_date      => g_report_date
           ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp);

	  --Begin Bug# 4753092
	  g_message_name := 'Fetch Person Details';
	  --l_message_name := 'get_from_history_people';
	  --End Bug# 4753092
      --dbms_output.put_line(l_message_name);
      get_from_history_people
           (p_sr_person_id        => g_person_id
           ,p_sr_report_date      => g_report_date
           ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           ); -- g_ghr_cpdf_temp.to_national_identifier

		--Begin Bug# 4753092
		--l_message_name := 'get_from_history_ancrit';
		--End Bug# 4753092
      --dbms_output.put_line(l_message_name);
      get_from_history_ancrit
           (p_sr_person_id        => g_person_id
           ,p_sr_report_date      => g_report_date
           ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           );
	--Begin Bug# 4753092
	--l_message_name := 'get_from_history_peopei';
	--End Bug# 4753092
      --dbms_output.put_line(l_message_name);
      get_from_history_peopei
           (p_sr_person_id        => g_person_id
           ,p_sr_report_date      => g_report_date
           ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           );
            --Begin Bug# 4725292
           get_from_per_wrkadd
           (p_sr_person_id        => g_person_id
           ,p_sr_report_date      => g_report_date
           ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           );
            --End Bug# 4725292
      IF g_position_id IS NOT NULL
      THEN
	-- Begin Bug# 4753092
	-- l_message_name := 'get_from_history_posiei';
	-- End Bug# 4753092
      --dbms_output.put_line(l_message_name);
      get_from_history_posiei
             (p_sr_position_id      => g_position_id
             ,p_sr_report_date      => g_report_date
             ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
             );
      END IF;

      IF g_grade_id IS NOT NULL
      THEN
		-- Begin Bug# 4753092
		g_message_name := 'Fetch Grade Details';
		--l_message_name := 'get_from_history_gradef';
		-- End Bug# 4753092
		--dbms_output.put_line(l_message_name);
		get_from_history_gradef
			 (p_sr_grade_id         => g_grade_id
			 ,p_sr_report_date      => g_report_date
			 ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
			 );
      END IF;

      IF g_job_id IS NOT NULL
      THEN
		-- Begin Bug# 4753092
		g_message_name := 'Fetch Job Details';
		--l_message_name := 'get_from_history_jobdef';
		-- End Bug# 4753092
		--dbms_output.put_line(l_message_name);
		get_from_history_jobdef
			 (p_sr_job_id           => g_job_id
			 ,p_sr_report_date      => g_report_date
			 ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
			 );
      END IF;

      IF g_location_id IS NOT NULL
      THEN
		-- Begin Bug# 4753092
		--l_message_name := 'get_from_history_dutsta';
		-- End Bug# 4753092
		--dbms_output.put_line(l_message_name);
		get_from_history_dutsta
			 (p_sr_location_id      => g_location_id
			 ,p_sr_report_date      => g_report_date
			 ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
			 );
      END IF;


	-- Bug 4714292 EHRI Reports Changes for EOY 05
	IF g_ghr_cpdf_temp.to_pay_rate_determinant IN ('5','6','E','F') THEN
			hr_utility.set_location('Inside PRD ' ||  g_ghr_cpdf_temp.to_locality_adj,111 );
			g_ghr_cpdf_temp.to_spl_rate_supplement := g_ghr_cpdf_temp.to_locality_adj;
			g_ghr_cpdf_temp.to_locality_adj := NULL;
	ELSE
			g_ghr_cpdf_temp.to_spl_rate_supplement := NULL;
	END IF;
	-- End Bug 	4714292 EHRI Reports Changes for EOY 05

	-- If Ethnicity is reported, RNO should be null
  	IF g_ghr_cpdf_temp.race_ethnic_info IS NOT NULL THEN
  		g_ghr_cpdf_temp.race_national_origin := NULL;
 	END IF;

      -- FWFA Change Override pay table id with that retrieved from Assignment
      -- Bug#5036001
      IF l_calc_pay_table_id IS NOT NULL THEN
         IF pp_gs_equivalent(g_to_pay_plan) AND
         g_ghr_cpdf_temp.to_pay_rate_determinant IN ('5','6','E','F') THEN
             g_ghr_cpdf_temp.spcl_pay_tbl_type := l_calc_pay_table_id;
         END IF;
      ELSE
        IF g_ghr_cpdf_temp.to_pay_rate_determinant IN ('5','6') AND
           pp_gs_equivalent(g_to_pay_plan) THEN
            g_ghr_cpdf_temp.spcl_pay_tbl_type := g_pay_table_name;
        ELSIF g_ghr_cpdf_temp.to_pay_rate_determinant in ('E','F') AND
           pp_gs_equivalent(g_ghr_cpdf_temp.retained_pay_plan) THEN
            g_ghr_cpdf_temp.spcl_pay_tbl_type := nvl(g_retained_pay_table_name,'0000');
        END IF;
      END IF;
      -- FWFA Change


      --Bug# 6158983
        FOR nte_date_rec in nte_date
	LOOP
          g_ghr_cpdf_temp.appointment_nte_date := fnd_date.canonical_to_date(nte_date_rec.aei_information4);
        END LOOP;
      -- Bug# 6158983

	 --Start of BUG# 6631879
         IF g_ghr_cpdf_temp.to_work_schedule in ('I','J') then
   	    g_ghr_cpdf_temp.part_time_hours := NULL;
         ELSIF g_ghr_cpdf_temp.to_work_schedule in ('F','G','B') then
            IF g_ghr_cpdf_temp.retirement_plan in ('E','M','T') then
	       g_ghr_cpdf_temp.part_time_hours := 144;
	    ELSE
	       g_ghr_cpdf_temp.part_time_hours := 80;
	    END IF;
	 END IF;
          --End of BUG# 6631879

    EXCEPTION
	WHEN OTHERS THEN
	FOR per_details in cur_per_details(g_person_id)
	LOOP
	l_full_name := per_details.name;
	l_ssn       := per_details.ssn;
	l_log_text  := 'Error in fetching data for Employee : ' ||l_full_name||
                     ' SSN : '||l_ssn||
                     ';  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
	END LOOP;
	Raise CPDF_STATRPT_ERROR;

    END;
    --
    -- END of handling exceptions for Bug 3671043
    --
      calc_is_foreign_duty_station(p_report_date  => g_report_date);
      insert_row;

      <<end_asg_loop>>
      NULL;

     EXCEPTION
        WHEN CPDF_STATRPT_ERROR THEN
             hr_utility.set_location('Inside EHRI_STATRPT_ERROR exception ',30);
             ghr_mto_int.log_message(p_procedure => g_message_name, --Bug# 4753092
             p_message   => l_log_text);
             --dbms_output.put_line('Name '||l_full_name);
             --dbms_output.put_line('Name '||l_log_text);
             COMMIT;
     END;
    END LOOP;

   IF NOT l_records_found THEN
	l_message_name:='RECORDS_NOT_FOUND';
	l_log_text:= 'No Records found for the given Report Date '||g_report_date;
        ghr_mto_int.log_message(p_procedure => l_message_name,
                                p_message   => l_log_text
                               );

       l_mesgbuff1:='No Records found for the given Report Date '||g_report_date;
       fnd_file.put(fnd_file.log,l_mesgbuff1);
       fnd_file.new_line(fnd_file.log);
    END IF;

    -- purge per design doc
    purge_suppression;

  END populate_ghr_cpdf_temp;

  PROCEDURE ehri_status_main
  (errbuf               OUT NOCOPY VARCHAR2
  ,retcode              OUT NOCOPY NUMBER
  ,p_report_name	IN VARCHAR2
  ,p_agency_code	IN VARCHAR2
  ,p_agency_subelement	IN VARCHAR2
   -- 8486208 Added new parameter
  ,p_agency_group      IN VARCHAR2
  ,p_report_date	      IN VARCHAR2
  ,p_gen_xml_file IN VARCHAR2 DEFAULT 'N'
  ,p_gen_txt_file IN VARCHAR2 DEFAULT 'Y'
   )
  IS
  l_ascii_fname		varchar2(80);
  l_xml_fname		varchar2(80);
  l_count_only		BOOLEAN;
  l_file_name VARCHAR2(500);
  l_report_date DATE;
  l_ret_code NUMBER;
  l_invalid_filename EXCEPTION;
  l_report_name VARCHAR2(500);
  l_log_text             ghr_process_log.log_text%type;
  l_message_name         ghr_process_log.message_name%type;
  l_agency_subelement  VARCHAR2(30);
  --l_sue_date varchar2(50);

  --
  BEGIN

  ghr_mto_int.set_log_program_name('GHR_CPDF_EHRI_STATRPT');
  l_report_date := fnd_date.canonical_to_date(p_report_date);
  --l_report_date := sysdate;
  --dbms_output.enable(100000000);
  --dbms_output.put_line(p_agency_code||' '||p_agency_subelement||' '||l_report_date);
  --8486208 added the following condition
  IF p_agency_code is NOT NULL OR p_agency_group is NULL THEN
    IF p_agency_subelement IS NULL THEN
       l_agency_subelement := '%';
    ELSE
       l_agency_subelement := p_agency_subelement;
    END IF;
  END IF;

  l_report_name := p_report_name;
  l_ret_code    := 0;

  INSERT INTO fnd_sessions
    (session_id
    ,effective_date)
  VALUES
    (userenv('sessionid')
    ,l_report_date);

 --8486208 added the the new parameter
  --
  populate_ghr_cpdf_temp(p_agency_code||l_agency_subelement,p_agency_group,l_report_date,l_count_only);

  -- Generate ASCII and XML files


  WritetoFile(l_report_name,p_gen_xml_file,p_gen_txt_file);

  -- Purge the table contents after reporting
  cleanup_table;
  DELETE FROM fnd_sessions
  WHERE  session_id = userenv('sessionid');


EXCEPTION
  WHEN OTHERS THEN
   l_message_name := 'Unhandled Error';
   l_log_text     := 'Unhandled Error under procedure ehri_status_main Date '||p_report_date||
   '  ** Error Message ** : ' ||substr(sqlerrm,1,1000);
   ghr_mto_int.log_message(p_procedure => l_message_name,
   p_message   => l_log_text);
   --dbms_output.put_line(l_log_text);
   COMMIT;

END ehri_status_main;

END ghr_cpdf_ehris;

/
