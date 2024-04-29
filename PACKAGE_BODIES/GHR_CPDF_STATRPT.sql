--------------------------------------------------------
--  DDL for Package Body GHR_CPDF_STATRPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CPDF_STATRPT" AS
/* $Header: ghrcpdfs.pkb 120.7.12000000.3 2007/03/02 05:48:03 vmididho noship $ */

  g_duty_station_id            ghr_duty_stations_f.duty_station_id%TYPE;
  g_retained_pay_table_id      pay_user_tables.user_table_id%TYPE;

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
    g_ghr_cpdf_temp.SCD_retirement        := NULL;
    g_ghr_cpdf_temp.SCD_rif        := NULL;
    g_ghr_cpdf_temp.position_title		 := NULL;
    g_ghr_cpdf_temp.name_title			 := NULL;

  END initialize_record;

  PROCEDURE cleanup_table
  IS
    l_proc                        varchar2(30) := 'cleanup_table';
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
    DELETE FROM ghr_cpdf_temp
      WHERE report_type = 'STATUS'
        AND session_id  = userenv('SESSIONID')
     ;
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
			PER_PEOPLE_F PER ,
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

  BEGIN
    INSERT INTO fnd_sessions
      (session_id
      ,effective_date)
    VALUES
      (userenv('sessionid')
      ,p_report_date);

    --
    FOR cur_per_rec IN cur_per LOOP
      p_appointment_date := cur_per_rec.hire_date;
    END LOOP;

    DELETE FROM fnd_sessions
    WHERE  session_id = userenv('sessionid');

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
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    l_ASGNEI_DATA := l_ASGNEI_DATA_INIT;
	-- Begin Bug# 4168162
	g_message_name := 'Assignment EIT: Assigment RPA';
	-- End Bug# 4168162
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
    -- FWFA Changes Get pay table id also
    p_sr_ghr_cpdf_temp.to_pay_table_id := l_ASGNEI_DATA.AEI_INFORMATION9;
    -- FWFA Changes

  END get_from_history_asgnei;


  PROCEDURE get_from_history_people
            (
            p_sr_person_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS
    l_proc                        varchar2(30) := 'get_from_history_people';
    CURSOR PEOPLE_CUR IS
    SELECT SEX,
           DATE_OF_BIRTH,
           NATIONAL_IDENTIFIER
      FROM PER_PEOPLE_F
      WHERE (TRUNC(p_sr_report_date) between effective_start_date and
                                          effective_end_date) AND
            PERSON_ID = g_person_id;

     l_PEOPLE_REC PEOPLE_CUR%ROWTYPE;

  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
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
    END IF;

    CLOSE PEOPLE_CUR;

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
    l_emp_number     per_people_f.employee_number%TYPE;
    CURSOR c_per IS
      SELECT per.employee_number
        FROM per_people_f per
       WHERE per.person_id = p_sr_person_id
         AND NVL(p_sr_report_date, TRUNC(sysdate)) BETWEEN per.effective_start_date
                                                       AND per.effective_end_date;
  BEGIN

    -- bug 749386 use ghr_api.return_education_details and ghr_api.return_special_information
    hr_utility.set_location('Entering:'||l_proc,5);
	-- Begin Bug# 4168162
	g_message_name := 'Special Info: Education Dtls';
	-- End Bug# 4168162
    ghr_api.return_education_details(p_person_id            => p_sr_person_id,
                                     p_effective_date       => p_sr_report_date,
                                     p_education_level      => p_sr_ghr_cpdf_temp.education_level,
                                     p_academic_discipline  => p_sr_ghr_cpdf_temp.academic_discipline,
                                     p_year_degree_attained => p_sr_ghr_cpdf_temp.year_degree_attained);

    -- Begin Bug# 4168162
	g_message_name := 'Special Info: Perf Appraisal';
	-- End Bug# 4168162
	ghr_cpdf_dynrpt.get_per_sit_perf_appraisal(p_sr_person_id
							  ,p_sr_report_date
							  ,p_sr_ghr_cpdf_temp.rating_of_record_level
							  ,p_sr_ghr_cpdf_temp.rating_of_record_pattern
							  ,p_sr_ghr_cpdf_temp.rating_of_record_period_ends);

/***** Commented 2003405
    ghr_api.return_special_information(p_person_id      => p_sr_person_id,
                                       p_structure_name => 'US Fed Perf Appraisal',
                                       p_effective_date => p_sr_report_date,
                                       p_special_info   => l_ancrit_rec);

    IF l_ancrit_rec.object_version_number IS NOT NULL THEN
      p_sr_ghr_cpdf_temp.rating_of_record_level       := l_ANCRIT_REC.SEGMENT5;
      p_sr_ghr_cpdf_temp.rating_of_record_pattern     := l_ANCRIT_REC.SEGMENT4;
    p_sr_ghr_cpdf_temp.rating_of_record_period_ends := fnd_date.canonical_to_date(l_ANCRIT_REC.SEGMENT6);
    ELSE -- Generate entry in PROCESS_LOG
      OPEN c_per;
      FETCH c_per INTO l_emp_number;
      CLOSE c_per;
      ghr_mto_int.log_message(p_procedure => 'No US Fed Perf Appraisal Info',
                              p_message   => 'Employee number ' || l_emp_number ||
                                             ' does not have US Fed Perf Appraisal ' ||
                                             'on ' || TO_CHAR(p_sr_report_date, 'DD-MON-YYYY'));
    END IF;
********* Bug 2003405******/

  END get_from_history_ancrit;

  PROCEDURE get_from_history_peopei
            (
            p_sr_person_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS
    l_proc                          varchar2(30) := 'get_from_history_peopei';
    l_PEOPEI_DATA                   PER_PEOPLE_EXTRA_INFO%ROWTYPE;
    l_PEOPEI_DATA_INIT              PER_PEOPLE_EXTRA_INFO%ROWTYPE;
    l_type_of_employment            per_people_extra_info.pei_information4%TYPE;
    l_retained_grade_rec            ghr_pay_calc.retained_grade_rec_type;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);


    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4168162
	g_message_name := 'Person EIT: Uniformed Serivces';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_peopleei(
                       p_person_id        => p_sr_person_id,
                       p_information_type => 'GHR_US_PER_UNIFORMED_SERVICES',
                       p_date_effective   => p_sr_report_date,
                       p_per_ei_data      => l_PEOPEI_DATA
                                     );
    p_sr_ghr_cpdf_temp.creditable_military_service := SUBSTR(l_PEOPEI_DATA.PEI_INFORMATION5,1,4);

    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4168162
	g_message_name := 'Person EIT: Separation, Retire';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_peopleei(
                       p_person_id        => p_sr_person_id,
                       p_information_type => 'GHR_US_PER_SEPARATE_RETIRE',
                       p_date_effective   => p_sr_report_date,
                       p_per_ei_data      => l_PEOPEI_DATA
                                     );
    p_sr_ghr_cpdf_temp.frozen_service := SUBSTR(l_PEOPEI_DATA.PEI_INFORMATION5,1,4);
    p_sr_ghr_cpdf_temp.fers_coverage  := l_PEOPEI_DATA.PEI_INFORMATION3;


    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4168162
	g_message_name := 'Person EIT: Person RPA';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_peopleei(
                       p_person_id        => p_sr_person_id,
                       p_information_type => 'GHR_US_PER_SF52',
                       p_date_effective   => p_sr_report_date,
                       p_per_ei_data      => l_PEOPEI_DATA
                                     );

    p_sr_ghr_cpdf_temp.veterans_preference := l_PEOPEI_DATA.PEI_INFORMATION4;
    p_sr_ghr_cpdf_temp.veterans_status     := l_PEOPEI_DATA.PEI_INFORMATION6;
    p_sr_ghr_cpdf_temp.citizenship         := l_PEOPEI_DATA.PEI_INFORMATION3;


    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4168162
	g_message_name := 'Person EIT: Person Group1';
	-- End Bug# 4168162
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

    -- bug 749190 Use FUNCTION ghr_pc_basic_pay.get_retained_grade_details instead of
    -- GHR_HISTORY_FETCH.fetch_peopleei
    -- do not woory if it didn't return anything!
    IF p_sr_ghr_cpdf_temp.to_pay_rate_determinant IN ('A','B','E','F','U','V')  THEN
        BEGIN
		-- Begin Bug# 4168162
		g_message_name := 'Person EIT: RG Details';
		-- End Bug# 4168162
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
          g_retained_pay_table_id                      := l_retained_grade_rec.user_table_id;
        EXCEPTION
          WHEN ghr_pay_calc.pay_calc_message THEN
               --l_message_name := 'Person EIT - Retained Grade';
               RAISE;
        END;
    END IF;

    l_PEOPEI_DATA := l_PEOPEI_DATA_INIT;
	-- Begin Bug# 4168162
	g_message_name := 'Person EIT: Person SCD Info';
	-- End Bug# 4168162
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
    p_sr_ghr_cpdf_temp.SCD_retirement         :=
                   fnd_date.canonical_to_date(l_PEOPEI_DATA.PEI_INFORMATION7);
-- EHRI changes

    -- CPDF EDITS FOR CREDITABLE MILITARY SERVICE
    -- October date specified per requirements
    -- Suggested Fix for 4060669
     IF NVL(p_sr_ghr_cpdf_temp.annuitant_indicator,'9') <> '9' OR
        g_appointment_date < to_date('1986/10/01','YYYY/MM/DD')
     THEN
       p_sr_ghr_cpdf_temp.creditable_military_service := ' ';
     END IF;

     IF (SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,1,1) < '0' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,2,1) < '0' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,3,1) < '0' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,4,1) < '0' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,1,1) > '9' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,2,1) > '9' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,3,1) > '9' OR
         SUBSTR(p_sr_ghr_cpdf_temp.creditable_military_service,4,1) > '9' ) AND
        p_sr_ghr_cpdf_temp.creditable_military_service IS NOT NULL AND
        p_sr_ghr_cpdf_temp.creditable_military_service <> ' '
     THEN
       p_sr_ghr_cpdf_temp.creditable_military_service := '0000';
     END IF;

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

     -- Fetching Race and ethnicity category
		l_PEOPEI_DATA :=NULL;
		-- Begin Bug# 4168162
		g_message_name := 'Person EIT: Ethnicity, Race';
		-- End Bug# 4168162
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
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    l_POSIEI_DATA := l_POSIEI_DATA_INIT;
	-- Begin Bug# 4168162
	g_message_name := 'Position EIT: Position Group1';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_positionei(
                       p_position_id      => p_sr_position_id,
                       p_information_type => 'GHR_US_POS_GRP1',
                       p_date_effective   => p_sr_report_date,
                       p_pos_ei_data      => l_POSIEI_DATA
                                       );
    p_sr_ghr_cpdf_temp.organizational_component := l_POSIEI_DATA.POEI_INFORMATION5;
    p_sr_ghr_cpdf_temp.personnel_office_id      := l_POSIEI_DATA.POEI_INFORMATION3;
    p_sr_ghr_cpdf_temp.functional_class         := l_POSIEI_DATA.POEI_INFORMATION11;
    p_sr_ghr_cpdf_temp.supervisory_status       := l_POSIEI_DATA.POEI_INFORMATION16;
    p_sr_ghr_cpdf_temp.flsa_category            := l_POSIEI_DATA.POEI_INFORMATION7;
    p_sr_ghr_cpdf_temp.bargaining_unit_status   := l_POSIEI_DATA.POEI_INFORMATION8;


    l_POSIEI_DATA := l_POSIEI_DATA_INIT;
	-- Begin Bug# 4168162
	g_message_name := 'Position EIT: Valid Grade';
	-- End Bug# 4168162
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
    if (l_POSIEI_DATA.POEI_INFORMATION5 is not null) then
	  p_sr_ghr_cpdf_temp.to_pay_table_id := l_POSIEI_DATA.POEI_INFORMATION5;
    end if;

    l_POSIEI_DATA := l_POSIEI_DATA_INIT;
	-- Begin Bug# 4168162
	g_message_name := 'Position EIT: Position Group2';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_positionei(
                       p_position_id      =>  p_sr_position_id,
                       p_information_type =>  'GHR_US_POS_GRP2',
                       p_date_effective   =>  p_sr_report_date,
                       p_pos_ei_data      =>  l_POSIEI_DATA
                                       );
    p_sr_ghr_cpdf_temp.position_occupied  := l_POSIEI_DATA.POEI_INFORMATION3;

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
    l_proc                        varchar2(30) := 'get_from_history_dutsta';

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
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
	-- Begin Bug# 4168162
	g_message_name := 'Duty Station Details';
	-- End Bug# 4168162
    OPEN DUTSTACUR;

    FETCH DUTSTACUR INTO l_DUTSTAREC;

    IF DUTSTACUR%FOUND
    THEN
      p_sr_ghr_cpdf_temp.to_duty_station_code     := l_DUTSTAREC.DUTY_STATION_CODE;
      g_duty_station_id                           := l_DUTSTAREC.DUTY_STATION_ID;
    END IF;

    CLOSE DUTSTACUR;
  END get_from_history_dutsta;

  PROCEDURE get_from_history_payele
            (
            p_sr_assignment_id IN NUMBER
           ,p_sr_report_date IN DATE
           ,p_sr_ghr_cpdf_temp IN OUT NOCOPY ghr_cpdf_temp%ROWTYPE
            )
  IS
    l_proc                        varchar2(30) := 'get_from_history_payele';
    l_scrn_ent_val_init PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE%TYPE;
    l_scrn_ent_val      PAY_ELEMENT_ENTRY_VALUES_F.SCREEN_ENTRY_VALUE%TYPE;
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);


    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := 'Fetch Element: Retirement Plan';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'Retirement Plan',
                       p_input_value_name   =>  'Plan',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val
                                               );
    p_sr_ghr_cpdf_temp.retirement_plan       := l_scrn_ent_val;

    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := 'Fetch Element: FEGLI';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'FEGLI',
                       p_input_value_name   =>  'FEGLI',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val
                                               );
    p_sr_ghr_cpdf_temp.fegli                  := l_scrn_ent_val;


    -- Start Bug 1635449
    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := 'Fetch Element: HB Pre Tax plan';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'Health Benefits Pre tax',
                       p_input_value_name   =>  'Health Plan',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val);
    p_sr_ghr_cpdf_temp.health_plan             := SUBSTR(LTRIM(l_scrn_ent_val), 1 ,2);
    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := 'Fetch Element: HB Pre tax Enrl';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'Health Benefits Pre tax',
                       p_input_value_name   =>  'Enrollment',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val
                                               );
    IF l_scrn_ent_val is NULL and p_sr_ghr_cpdf_temp.health_plan is NULL THEN
    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := ' Fetch Element: HB plan';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'Health Benefits',
                       p_input_value_name   =>  'Health Plan',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val);
    p_sr_ghr_cpdf_temp.health_plan             := SUBSTR(LTRIM(l_scrn_ent_val), 1 ,2);
    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := ' Fetch Element: HB Enrollment';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'Health Benefits',
                       p_input_value_name   =>  'Enrollment',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val
                                               );
    END IF;
    p_sr_ghr_cpdf_temp.health_plan             := NVL(p_sr_ghr_cpdf_temp.health_plan, '  ') ||
                                                  SUBSTR(LTRIM(l_scrn_ent_val), 1, 1);
-- End Bug 1635449
-- Changes for Payroll Integration
-- Name       Bug          Date      Comments
-- ----      -----        ------    -----------
-- Madhuri  Payroll Intg 04-Jul-03   Changing the Basic Salary Rate
--                                   Input Value name from 'Salary' to 'Rate'
--
    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := 'Fetch Element: Basic Salary';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'Basic Salary Rate',
                       p_input_value_name   =>  'Rate',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val
                                               );
    p_sr_ghr_cpdf_temp.to_basic_pay         := to_number(l_scrn_ent_val);

    l_scrn_ent_val := l_scrn_ent_val_init;

-- Changes for Payroll Integration
-- Name       Bug          Date      Comments
-- ----      -----        ------    -----------
-- Madhuri  Payroll Intg 18-AUG-03   Changing the Locality Pay
--                                   Input Value name from 'Amount' to 'Rate'
--
	-- Begin Bug# 4168162
	g_message_name := 'Fetch Element: Locality Pay';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
    -- FWFA Changes Bug#4444609
                       p_element_name       =>  'Locality Pay or SR Supplement',
    -- FWFA Changes Modify 'Locality Pay' to 'Locality Pay or SR Supplement'
                       p_input_value_name   =>  'Rate',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val
                                               );
    p_sr_ghr_cpdf_temp.to_locality_adj      := to_number(l_scrn_ent_val);

    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := 'Fetch Element: Staffing Diff';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'Staffing Differential',
                       p_input_value_name   =>  'Amount',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val
                                               );
    p_sr_ghr_cpdf_temp.to_staffing_differential   := to_number(l_scrn_ent_val);

    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := 'Fetch Element:Supervisory Diff';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'Supervisory Differential',
                       p_input_value_name   =>  'Amount',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val
                                               );
    p_sr_ghr_cpdf_temp.to_supervisory_differential   := to_number(l_scrn_ent_val);

    l_scrn_ent_val := l_scrn_ent_val_init;
	-- Begin Bug# 4168162
	g_message_name := 'Fetch Element:Retention Allow';
	-- End Bug# 4168162
    GHR_HISTORY_FETCH.fetch_element_entry_value(
                       p_element_name       =>  'Retention Allowance',
                       p_input_value_name   =>  'Amount',
                       p_assignment_id      =>  p_sr_assignment_id,
                       p_date_effective     =>  p_sr_report_date,
                       p_screen_entry_value =>  l_scrn_ent_val
                                               );
    p_sr_ghr_cpdf_temp.to_retention_allowance  := to_number(l_scrn_ent_val);

  END get_from_history_payele;

  PROCEDURE calc_is_foreign_duty_station
           ( p_report_date    in date
           )
  IS
    l_proc                      varchar2(30) := 'calc_is_foreign_duty_station';
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
    l_proc                        varchar2(30) := 'insert_row';
	-- Bug 4542476
	l_locality_pay_area   ghr_locality_pay_areas_f.locality_pay_area_code%type;
	l_equivalent_pay_plan ghr_pay_plans.equivalent_pay_plan%type;
	-- End Bug 4542476
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
    -- Bug#3231946 Added reference to parameters as the function definition is changed

	l_locality_pay_area := ghr_cpdf_dynrpt.get_loc_pay_area_code(p_duty_station_id => g_duty_station_id,
			                          p_effective_date  => g_ghr_cpdf_temp.effective_date);
	l_equivalent_pay_plan :=  ghr_cpdf_dynrpt.get_equivalent_pay_plan(
							     NVL(g_ghr_cpdf_temp.retained_pay_plan, g_ghr_cpdf_temp.to_pay_plan));

	IF (l_locality_pay_area = '99')
    THEN
      g_ghr_cpdf_temp.from_locality_adj := NULL;
      g_ghr_cpdf_temp.to_locality_adj   := NULL;
    ELSIF l_equivalent_pay_plan = 'FW'
    THEN
      g_ghr_cpdf_temp.from_locality_adj := NULL;
      g_ghr_cpdf_temp.to_locality_adj   := NULL;
    END IF;

	-- Bug 4542476
	IF g_ghr_cpdf_temp.to_locality_adj = 0 THEN
		IF l_equivalent_pay_plan = 'GS' AND l_locality_pay_area = 'ZZ' THEN
			g_ghr_cpdf_temp.to_locality_adj := NULL;
		ELSIF l_equivalent_pay_plan = 'GS' AND NVL(l_locality_pay_area,'-1') <> 'ZZ' THEN
			g_ghr_cpdf_temp.to_locality_adj := 0;
		ELSE
			g_ghr_cpdf_temp.to_locality_adj := NULL;
		END IF;
	END IF;
	-- End Bug 4542476

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
--		  	employee_first_name,
--			employee_middle_names,
			name_title,
			position_title,
			award_dollars,
			award_hours,
			award_percentage,
			SCD_retirement,
			SCD_rif,
			race_ethnic_info
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
			g_ghr_cpdf_temp.race_ethnic_info
--			1,sysdate,1,sysdate,1
      );
  END insert_row;

  PROCEDURE purge_suppression
  IS
    l_proc                        varchar2(30) := 'purge_suppression';
  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);

    -- bug 743502 moved the checking of agency code matching the parameter passed in to
    -- to as soon as possible, not here at the end!
    DELETE FROM ghr_cpdf_temp
      WHERE (report_type='STATUS')
        AND (
      -- *** SUPPRESS NON APPROPRIATED EMPLOYEES / COMMISSIONED OFFICERS
                ( to_pay_plan IN ('NA','NL','NS','CC') )
      -- *** EXCLUDE NON US CITIZENS WORKING IN FOREIGN DUTY STATIONS
             OR ( from_duty_station_code = 'Y'
                  AND decode(citizenship, NULL, ' ', citizenship) <> '1' )
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
  -- if suffix not found then returning lastname otherwise returning lastname without suffix
  -- and suffix
  IF GET_SUFFIX%NOTFOUND THEN
     p_lname  := RTRIM(p_last_name,' ,.');
     p_suffix := NULL;
  ELSE
     p_lname  := RTRIM(SUBSTR(p_last_name, 0, l_suffix_pos-1),' ,.');
     p_suffix := SUBSTR(p_last_name,l_suffix_pos+1,l_total_len);
  END IF;
  CLOSE GET_SUFFIX;
 END get_suffix_lname;

  PROCEDURE populate_ghr_cpdf_temp (p_agency      IN VARCHAR2,
                                    p_report_date IN DATE)
  IS
    l_proc                        varchar2(30) := 'populate_ghr_cpdf_temp';
    CURSOR assignments_f_cur is
       SELECT asg.assignment_id,
              asg.person_id,
              asg.position_id,
              asg.grade_id,
              asg.job_id,
              asg.location_id,
              asg.effective_start_date,
	      asg.business_group_id,
              ghr_api.get_position_agency_code_pos(asg.position_id,asg.business_group_id) agency_code
         FROM PER_ASSIGNMENTS_F asg
         WHERE
            -- only consider "Active" assignments as defined by below, also only look at
		-- assignments that are assigned to a valid person as of the report date.
               p_report_date between asg.effective_start_date and asg.effective_end_date
         AND   asg.assignment_status_type_id in
              (select ast.assignment_status_type_id
               from   PER_ASSIGNMENT_STATUS_TYPES ast
               where  ast.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN'))
         AND   asg.assignment_type <> 'B'
         AND   asg.position_id IS NOT NULL
         AND   ghr_api.get_position_agency_code_pos(asg.position_id,asg.business_group_id) like p_agency
		 ORDER BY assignment_id;
		 -- Bug 3704123 - Adding order by clause for the above statement so that results will be in temp segment

    l_assignments_f_rec assignments_f_cur%ROWTYPE;
--- 3671043 Bug fix
    l_log_text                  ghr_process_log.log_text%type;
    l_message_name           	ghr_process_log.message_name%type;
    l_log_date               	ghr_process_log.log_date%type;
    l_suffix                    per_all_people_f.title%type;
    l_last_name                 per_all_people_f.last_name%type;


CURSOR cur_per_details(p_person_id    per_people_f.person_id%type)
  IS
SELECT full_name name ,national_identifier ssn,last_name,first_name,middle_names, title
FROM   per_all_people_f
WHERE  person_id=p_person_id;


l_business_group_id     per_assignments_f.business_group_id%type;
l_full_name		per_people_f.full_name%type;
l_ssn			per_people_f.national_identifier%type;
l_records_found		BOOLEAN;
l_mesgbuff1            VARCHAR2(4000);
ll_per_ei_data		per_people_extra_info%rowtype;
-- FWFA Changes Declare variable l_calc_pay_table_id
Cursor c_pay_table_name (p_user_table_id number) is
 SELECT SUBSTR(user_table_name,1,4) user_table_name
   FROM pay_user_tables
  WHERE user_table_id = p_user_table_id;
l_calc_pay_table_id     VARCHAR2(4);
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
    ghr_mto_int.set_log_program_name('GHR_CPDF_STATRPT');
    g_report_date := p_report_date;
    g_agency      := p_agency;
    l_records_found:=FALSE;
    -- cleanup_table;
    initialize_record;

    FOR l_assignments_f_rec IN assignments_f_cur
     LOOP
      BEGIN
       -- initialize every iteration
       initialize_record;
       -- assign globals
       g_assignment_id        := l_assignments_f_rec.assignment_id;
       g_person_id            := l_assignments_f_rec.person_id;
       g_position_id          := l_assignments_f_rec.position_id;
       g_grade_id             := l_assignments_f_rec.grade_id;
       g_job_id               := l_assignments_f_rec.job_id;
       g_location_id          := l_assignments_f_rec.location_id;
       g_ghr_cpdf_temp.agency_code := l_assignments_f_rec.agency_code;
       -- added for EHRI reports
       l_business_group_id    := l_assignments_f_rec.business_group_id;
       -- added for EHRI reports

       -- Bug 714944 -- No not report on NAF positions:
       IF ghr_cpdf_dynrpt.exclude_position (p_position_id       => g_position_id
                                           ,p_effective_date    => p_report_date) THEN
         GOTO end_asg_loop;  -- loop for the next one!
       END IF;
       --
       --
    BEGIN

      FOR per_det in cur_per_details(g_person_id)
      LOOP
      -- Bug# 4648811 extracting suffix from the lastname
      get_suffix_lname(per_det.last_name,
                       p_report_date,
                       l_suffix,
                       l_last_name);
	g_ghr_cpdf_temp.employee_last_name    := l_last_name;
	g_ghr_cpdf_temp.employee_first_name   := per_det.first_name;
	g_ghr_cpdf_temp.employee_middle_names := per_det.middle_names;
	g_ghr_cpdf_temp.name_title            := l_suffix;
     --End Bug# 4648811
      END LOOP;

		-- Begin Bug# 4168162
		g_message_name := 'Fetch Position title';
		--l_message_name :='get_position_title_pos';
		-- End Bug# 4168162

        g_ghr_cpdf_temp.position_title :=  ghr_api.get_position_title_pos(
			p_position_id		=> g_position_id,
		        p_business_group_id	=> l_business_group_id,
			p_effective_date	=> g_report_date);


/*      ghr_history_fetch.fetch_peopleei
	  (p_person_id          =>  g_person_id,
	    p_information_type   =>  'GHR_US_PER_SCD_INFORMATION',
	    p_date_effective     =>  nvl(g_report_date,trunc(sysdate)),
	    p_per_ei_data        =>  ll_per_ei_data
	  );

	g_ghr_cpdf_temp.SCD_rif:= fnd_date.canonical_to_date(ll_per_ei_data.pei_information5);
	g_ghr_cpdf_temp.SCD_retirement:= fnd_date.canonical_to_date(ll_per_ei_data.pei_information7);
*/
       --
       -- Bug 3671043 Handling Exceptions (madhuri)
	   -- Begin Bug# 4168162
		g_message_name := 'Fetch Appointment date';
       --l_message_name := 'get_appointment_date';
	   -- End Bug# 4168162
       get_appointment_date(p_person_id        => g_person_id
                           ,p_report_date      => p_report_date
                           ,p_appointment_date => g_appointment_date);
       --
       -- call fetch routines to populate record
       -- Begin Bug# 4168162
       --l_message_name := 'get_from_history_asgnei';
	   -- End Bug# 4168162
       get_from_history_asgnei
           (
           p_sr_assignment_id    => g_assignment_id
          ,p_sr_report_date      => g_report_date
          ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           );
       -- FWFA Change Get pay table id
       -- Bug#5063289 Fetch the First 4 characters of Pay table name.
       FOR pay_table_rec IN c_pay_table_name(g_ghr_cpdf_temp.to_pay_table_id)
       LOOP
           l_calc_pay_table_id := pay_table_rec.user_table_name;
       END LOOP;

		-- Begin Bug# 4168162
		--l_message_name := 'get_from_history_payele';
		-- End Bug# 4168162
       get_from_history_payele
           (
           p_sr_assignment_id    => g_assignment_id
          ,p_sr_report_date      => g_report_date
          ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           );

		-- Begin Bug# 4168162
		g_message_name := 'Fetch Person Details';
		--l_message_name := 'get_from_history_people';
		-- End Bug# 4168162
       get_from_history_people
           (
           p_sr_person_id        => g_person_id
          ,p_sr_report_date      => g_report_date
          ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           ); -- g_ghr_cpdf_temp.to_national_identifier

		-- Begin Bug# 4168162
		--l_message_name := 'get_from_history_ancrit';
		-- End Bug# 4168162
       get_from_history_ancrit
           (
           p_sr_person_id        => g_person_id
          ,p_sr_report_date      => g_report_date
          ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           );

		-- Begin Bug# 4168162
		--l_message_name := 'get_from_history_peopei';
		-- End Bug# 4168162
      get_from_history_peopei
           (
           p_sr_person_id        => g_person_id
          ,p_sr_report_date      => g_report_date
          ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
           );

      IF g_position_id IS NOT NULL
      THEN
		-- Begin Bug# 4168162
		--l_message_name := 'get_from_history_posiei';
		-- End Bug# 4168162
        get_from_history_posiei
             (
             p_sr_position_id      => g_position_id
            ,p_sr_report_date      => g_report_date
            ,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
             );
      END IF;


      IF g_grade_id IS NOT NULL
      THEN
		-- Begin Bug# 4168162
		g_message_name := 'Fetch Grade Details';
		--l_message_name := 'get_from_history_gradef';
		-- End Bug# 4168162
		get_from_history_gradef
				 (
				 p_sr_grade_id         => g_grade_id
				,p_sr_report_date      => g_report_date
				,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
				 );
      END IF;

      IF g_job_id IS NOT NULL
      THEN
		-- Begin Bug# 4168162
		g_message_name := 'Fetch Job Details';
		--l_message_name := 'get_from_history_jobdef';
		-- End Bug# 4168162
		get_from_history_jobdef
				 (
				 p_sr_job_id           => g_job_id
				,p_sr_report_date      => g_report_date
				,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
				 );
      END IF;

      IF g_location_id IS NOT NULL
      THEN
		-- Begin Bug# 4168162
		-- l_message_name := 'get_from_history_dutsta';
		-- End Bug# 4168162
		get_from_history_dutsta
				 (
				 p_sr_location_id      => g_location_id
				,p_sr_report_date      => g_report_date
				,p_sr_ghr_cpdf_temp    => g_ghr_cpdf_temp
				 );
      END IF;


      -- If Ethnicity is reported, RNO should be null
      IF g_ghr_cpdf_temp.race_ethnic_info IS NOT NULL THEN
      	g_ghr_cpdf_temp.race_national_origin := NULL;
      END IF;

      -- FWFA Change Override pay table id with that retrieved from Assignment

     IF l_calc_pay_table_id IS NOT NULL THEN
         IF pp_gs_equivalent(g_ghr_cpdf_temp.to_pay_plan) AND
         g_ghr_cpdf_temp.to_pay_rate_determinant IN ('5','6','E','F') THEN
             g_ghr_cpdf_temp.to_pay_table_id := l_calc_pay_table_id;
         ELSE
             g_ghr_cpdf_temp.to_pay_table_id := NULL;
         END IF;
      ELSE
        IF g_ghr_cpdf_temp.to_pay_rate_determinant IN ('5','6') AND
            pp_gs_equivalent(g_ghr_cpdf_temp.to_pay_plan) THEN
             FOR pay_table_rec IN c_pay_table_name(g_ghr_cpdf_temp.to_pay_table_id)
               LOOP
                   g_ghr_cpdf_temp.to_pay_table_id := pay_table_rec.user_table_name;
               END LOOP;
        ELSIF g_ghr_cpdf_temp.to_pay_rate_determinant in ('E','F') AND
           pp_gs_equivalent(g_ghr_cpdf_temp.retained_pay_plan) THEN
           FOR pay_table_rec IN c_pay_table_name(g_retained_pay_table_id)
           LOOP
               g_ghr_cpdf_temp.to_pay_table_id := pay_table_rec.user_table_name;
           END LOOP;
        ELSE
               g_ghr_cpdf_temp.to_pay_table_id := NULL;
        END IF;
      END IF;

	g_message_name := NULL;

    l_records_found:=TRUE;

    EXCEPTION
    WHEN ghr_pay_calc.pay_calc_message THEN
        FOR per_details in cur_per_details(g_person_id)
	    LOOP
            g_message_name := 'Person EIT - Retained_grade'; --Bug# 4168162
	        l_full_name := per_details.name;
	        l_ssn       := per_details.ssn;
	        l_log_text     := 'Error in fetching data for Employee : ' ||l_full_name||
							 ' SSN : '||l_ssn||
	 					         ';  ** Error Message ** : Retained Grade details not available as on the report date' ;
	    END LOOP;
	    Raise CPDF_STATRPT_ERROR;

    WHEN OTHERS THEN
	FOR per_details in cur_per_details(g_person_id)
	LOOP
	l_full_name := per_details.name;
	l_ssn       := per_details.ssn;
	l_log_text     := 'Error in fetching data for Employee : ' ||l_full_name||
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
                    hr_utility.set_location('Inside CPDF_STATRPT_ERROR exception ',30);
                    ghr_mto_int.log_message(p_procedure => g_message_name, --Bug# 4168162
                                            p_message   => l_log_text
                                            );
                    COMMIT;
     END;
    END LOOP;

   IF NOT l_records_found THEN
	g_message_name:='RECORDS_NOT_FOUND'; --Bug# 4168162
	l_log_text:= 'No Records found for the given Report Date '||g_report_date;
        ghr_mto_int.log_message(p_procedure => g_message_name, --Bug# 4168162
                                p_message   => l_log_text
                               );

       l_mesgbuff1:='No Records found for the given Report Date '||g_report_date;
       fnd_file.put(fnd_file.log,l_mesgbuff1);
       fnd_file.new_line(fnd_file.log);
    END IF;


    -- purge per design doc
    purge_suppression;

  END populate_ghr_cpdf_temp;

END ghr_cpdf_statrpt;

/
