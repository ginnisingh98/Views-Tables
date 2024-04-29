--------------------------------------------------------
--  DDL for Package Body GHR_WGI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_WGI_PKG" AS
/* $Header: ghwgipro.pkb 120.17.12010000.2 2010/01/12 10:40:56 managarw ship $ */
   PROCEDURE ghr_wgi_process (
      errbuf                  OUT NOCOPY      VARCHAR2,
      retcode                 OUT NOCOPY      NUMBER,
      p_personnel_office_id   IN              ghr_pa_requests.personnel_office_id%TYPE
            DEFAULT NULL,
      p_pay_plan              IN              ghr_pay_plans.pay_plan%TYPE
            DEFAULT NULL
   )
   IS
      l_errbuf    VARCHAR2 (2000);
      l_retcode   NUMBER          := 0;
   BEGIN
      --
      -- call the main procedure
      --
      ghr_wgi_emp (p_errbuf                   => l_errbuf,
                   p_retcode                  => l_retcode,
                   p_personnel_office_id      => p_personnel_office_id,
                   p_pay_plan                 => p_pay_plan
                  );
      errbuf := l_errbuf;
      retcode := l_retcode;
   EXCEPTION
      WHEN OTHERS
      THEN
         errbuf := NULL;
         retcode := NULL;
         RAISE;
   END ghr_wgi_process;

--
--
--
   PROCEDURE ghr_wgi_emp (
      p_effective_date        IN              DATE DEFAULT TRUNC (SYSDATE),
      p_frequency             IN              NUMBER DEFAULT 90,
      p_log_flag              IN              CHAR DEFAULT 'N',
      p_errbuf                OUT NOCOPY      VARCHAR2,
      p_retcode               OUT NOCOPY      NUMBER,
      p_personnel_office_id   IN              ghr_pa_requests.personnel_office_id%TYPE
            DEFAULT NULL,
      p_pay_plan              IN              ghr_pay_plans.pay_plan%TYPE
            DEFAULT NULL
   )
   IS
--
-- Local variables



-- Bug 4377361 included EMP_APL for person type condition
      CURSOR per_assign_cursor (l_effective_date IN DATE)
      IS
         SELECT ppf.person_id, ppf.national_identifier, ppf.date_of_birth,
                ppf.last_name, ppf.first_name, ppf.middle_names,
                ppf.full_name, paf.position_id, paf.assignment_id,
                paf.grade_id, paf.job_id, paf.location_id,
                paf.organization_id
           FROM per_assignments_f paf, per_people_f ppf,
                per_person_types ppt
          WHERE ppf.person_id = paf.person_id
            AND paf.primary_flag = 'Y'
            AND paf.assignment_type <> 'B'
            AND l_effective_date BETWEEN paf.effective_start_date
                                     AND paf.effective_end_date
            AND ppf.person_type_id = ppt.person_type_id
            AND ppt.system_person_type IN ('EMP','EMP_APL')
            AND l_effective_date BETWEEN ppf.effective_start_date
                                     AND ppf.effective_end_date
	    AND ret_wgi_pay_date(paf.assignment_id,l_effective_date, p_frequency) IS NOT NULL
	    AND PAF.BUSINESS_GROUP_ID >=0;  --Bug #5212248
	    -- TAR 4124874.999 Above condition added to filter out the
	    -- employees not having Pay date.



--
-- remove person id, set default frequency to 90, uncomment element api
--
      l_exists                         BOOLEAN;
      l_person_id                      per_people_f.person_id%TYPE;
      l_assignment_id                  per_assignments.assignment_id%TYPE;
      l_national_identifier            per_people_f.national_identifier%TYPE;
      l_date_of_birth                  per_people_f.date_of_birth%TYPE;
      l_last_name                      per_people_f.last_name%TYPE;
      l_first_name                     per_people_f.first_name%TYPE;
      l_middle_names                   per_people_f.middle_names%TYPE;
      l_full_name                      per_people_f.full_name%TYPE;
      l_position_id                    per_assignments.position_id%TYPE;
      l_grade_id                       ghr_pa_requests.to_grade_id%TYPE;
      l_job_id                         per_assignments.job_id%TYPE;
      l_location_id                    per_assignments.location_id%TYPE;
      l_organization_id                per_assignments.organization_id%TYPE;
      l_proc                           VARCHAR2 (30)               := 'AWGI :';
      l_pay_basis                      per_pay_bases.pay_basis%TYPE;
      l_organization_name              hr_organization_units.NAME%TYPE;
      l_org_address_line1              hr_locations.address_line_1%TYPE;
      l_org_address_line2              hr_locations.address_line_2%TYPE;
      l_org_address_line3              hr_locations.address_line_3%TYPE;
      l_org_city                       hr_locations.town_or_city%TYPE;
      l_org_state                      hr_locations.region_2%TYPE;
      l_org_country                    hr_locations.country%TYPE;
      l_duty_station_id                ghr_duty_stations_f.duty_station_id%TYPE;
      l_pay_table_plan_id              ghr_pay_plans.pay_plan%TYPE;
      l_wgi_pay_date                   DATE;
	  l_wgi_due_date				   DATE; -- Bug 3747024
      l_value                          VARCHAR2 (30);
      l_multiple_error_flag            BOOLEAN;
      l_pa_request_id                  ghr_pa_requests.pa_request_id%TYPE;
      l_par_object_version_number      ghr_pa_requests.object_version_number%TYPE;
      l_1_pa_routing_history_id        ghr_pa_routing_history.routing_seq_number%TYPE;
      l_1_prh_object_version_number    ghr_pa_requests.object_version_number%TYPE;
      l_2_pa_routing_history_id        ghr_pa_routing_history.routing_seq_number%TYPE;
      l_2_prh_object_version_number    ghr_pa_requests.object_version_number%TYPE;
      l_routing_group_id               ghr_pa_requests.routing_group_id%TYPE;
      l_validate                       BOOLEAN;
      l_u_attachment_modified_flag     VARCHAR2 (30);
      l_u_approved_flag                VARCHAR2 (30);
      l_u_user_name_acted_on           ghr_pa_routing_history.user_name%TYPE;
      l_u_action_taken                 ghr_pa_routing_history.action_taken%TYPE
                                                               := 'NOT_ROUTED';
      l_i_user_name_routed_to          ghr_pa_routing_history.user_name%TYPE;
      l_i_groupbox_id                  ghr_pa_routing_history.groupbox_id%TYPE;
      l_i_routing_list_id              NUMBER;
      l_i_routing_seq_number           NUMBER;
      l_u_prh_object_version_number    NUMBER;
      l_i_pa_routing_history_id        NUMBER;
      l_i_prh_object_version_number    NUMBER;
      l_effective_date                 ghr_pa_requests.effective_date%TYPE;
      -- For Create SF52 procedure
      l_noa_family_code                ghr_pa_requests.noa_family_code%TYPE; --'SALARY_CHG';
      l_first_noa_code                 ghr_pa_requests.first_noa_code%TYPE;
      l_first_noa_desc                 ghr_pa_requests.first_noa_desc%TYPE;
      l_first_action_la_code1          ghr_pa_requests.first_action_la_code1%TYPE;
      l_first_action_la_desc1          ghr_pa_requests.first_action_la_desc1%TYPE;
      l_first_action_la_code2          ghr_pa_requests.first_action_la_code2%TYPE;
      l_first_action_la_desc2          ghr_pa_requests.first_action_la_desc2%TYPE;
      l_proposed_effective_asap_flag   ghr_pa_requests.proposed_effective_asap_flag%TYPE
                                                                        := 'N';
      -- For Update SF52 procedure (ghr_pa_requests_pkg.get_SF52_person_ddf_details)
      l_citizenship                    ghr_pa_requests.citizenship%TYPE;
      l_veterans_preference            ghr_pa_requests.veterans_preference%TYPE;
      l_veterans_pref_for_rif          ghr_pa_requests.veterans_pref_for_rif%TYPE;
      l_veterans_status                ghr_pa_requests.veterans_status%TYPE;
      l_scd_leave                      VARCHAR2 (150);
      -- For Update SF52 procedure From side data elements(ghr_pa_requests_pkg.SF52_from_data_elements)
      l_from_adj_basic_pay             ghr_pa_requests.from_adj_basic_pay%TYPE;
      l_from_agency_code               ghr_pa_requests.from_agency_code%TYPE;
      l_from_agency_desc               ghr_pa_requests.from_agency_desc%TYPE;
      l_from_basic_pay                 ghr_pa_requests.from_basic_pay%TYPE;
      l_from_grade_or_level            ghr_pa_requests.from_grade_or_level%TYPE;
      l_from_locality_adj              ghr_pa_requests.from_locality_adj%TYPE;
      l_from_occ_code                  ghr_pa_requests.from_occ_code%TYPE;
      l_from_office_symbol             ghr_pa_requests.from_office_symbol%TYPE;
      l_from_other_pay_amount          ghr_pa_requests.from_other_pay_amount%TYPE;
      l_from_pay_basis                 ghr_pa_requests.from_pay_basis%TYPE;
      l_from_pay_plan                  ghr_pa_requests.from_pay_plan%TYPE;
      l_from_position_id               ghr_pa_requests.from_position_id%TYPE;
      l_from_position_org_line1        ghr_pa_requests.from_position_org_line1%TYPE;
      l_from_position_org_line2        ghr_pa_requests.from_position_org_line2%TYPE;
      l_from_position_org_line3        ghr_pa_requests.from_position_org_line3%TYPE;
      l_from_position_org_line4        ghr_pa_requests.from_position_org_line4%TYPE;
      l_from_position_org_line5        ghr_pa_requests.from_position_org_line5%TYPE;
      l_from_position_org_line6        ghr_pa_requests.from_position_org_line6%TYPE;
      l_from_position_number           ghr_pa_requests.from_position_number%TYPE;
      l_from_position_seq_no           ghr_pa_requests.from_position_seq_no%TYPE;
      l_from_position_title            ghr_pa_requests.from_position_title%TYPE;
      l_from_step_or_rate              ghr_pa_requests.from_step_or_rate%TYPE;
      l_from_total_salary              ghr_pa_requests.from_total_salary%TYPE;
      l_to_au_overtime                 ghr_pa_requests.to_au_overtime%TYPE;
      l_to_auo_premium_pay_indicator   ghr_pa_requests.to_auo_premium_pay_indicator%TYPE;
      l_to_availability_pay            ghr_pa_requests.to_availability_pay%TYPE;
      l_to_ap_premium_pay_indicator    ghr_pa_requests.to_ap_premium_pay_indicator%TYPE;
      l_to_retention_allowance         ghr_pa_requests.to_retention_allowance%TYPE;
      l_to_supervisory_differential    ghr_pa_requests.to_supervisory_differential%TYPE;
      l_to_staffing_differential       ghr_pa_requests.to_staffing_differential%TYPE;
      l_to_organization_id             ghr_pa_requests.to_organization_id%TYPE;
      l_to_step_or_rate                ghr_pa_requests.to_step_or_rate%TYPE;
      l_pay_rate_determinant           ghr_pa_requests.pay_rate_determinant%TYPE;
      l_duty_station_location_id       ghr_pa_requests.duty_station_location_id%TYPE;
      l_education_level                ghr_pa_requests.education_level%TYPE;
      l_academic_discipline            ghr_pa_requests.academic_discipline%TYPE;
      l_year_degree_attained           ghr_pa_requests.year_degree_attained%TYPE;
      --
      l_retention_allow_percentage     ghr_pa_requests.to_retention_allow_percentage%TYPE;
      l_supervisory_diff_percentage    ghr_pa_requests.to_supervisory_diff_percentage%TYPE;
      l_staffing_diff_percentage       ghr_pa_requests.to_staffing_diff_percentage%TYPE;
      l_award_percentage               ghr_pa_requests.award_percentage%TYPE;
      --
      -- for get_SF52_asg_ddf_details
      l_tenure                         ghr_pa_requests.tenure%TYPE;
      l_annuitant_indicator            ghr_pa_requests.annuitant_indicator%TYPE;
      l_annuitant_indicator_desc       ghr_pa_requests.annuitant_indicator_desc%TYPE;
      l_flsa_category                  ghr_pa_requests.flsa_category%TYPE;
      l_bargaining_unit_status         ghr_pa_requests.bargaining_unit_status%TYPE;
      l_work_schedule                  ghr_pa_requests.work_schedule%TYPE;
      l_work_schedule_desc             ghr_pa_requests.work_schedule_desc%TYPE;
      l_functional_class               ghr_pa_requests.functional_class%TYPE;
      l_supervisory_status             ghr_pa_requests.supervisory_status%TYPE;
      l_position_occupied              ghr_pa_requests.position_occupied%TYPE;
      l_appropriation_code1            ghr_pa_requests.appropriation_code1%TYPE;
      l_appropriation_code2            ghr_pa_requests.appropriation_code2%TYPE;
      l_part_time_hours                ghr_pa_requests.part_time_hours%TYPE;
      -- for get_duty_station_detail
      l_duty_station_code              ghr_pa_requests.duty_station_code%TYPE;
      l_duty_station_desc              ghr_pa_requests.duty_station_desc%TYPE;
      l_custom_pay_calc_flag           ghr_pa_requests.custom_pay_calc_flag%TYPE;
      l_fegli                          ghr_pa_requests.fegli%TYPE;
      l_fegli_desc                     ghr_pa_requests.fegli_desc%TYPE;
      l_retirement_plan                ghr_pa_requests.retirement_plan%TYPE;
      l_retirement_plan_desc           ghr_pa_requests.retirement_plan_desc%TYPE;
      l_service_comp_date              ghr_pa_requests.service_comp_date%TYPE;
      -- for check_assignment_id
      -- for person_in_pa_requests
      l_days                           NUMBER                           := 350;
      l_frequency                      NUMBER;
      l_message_set                    BOOLEAN;
      l_calculated                     BOOLEAN;
      l_nature_of_action_id            ghr_nature_of_actions.nature_of_action_id%TYPE;
      l_retained_grade                 ghr_pay_calc.retained_grade_rec_type;
      -- used for starting the wgi workflow
      l_start_wgi_wf_flag              CHAR (1)                         := 'N';
      l_errbuf                         VARCHAR2 (2000);
      l_retcode                        NUMBER                             := 0;
      -- to side pay calc added for bug fix
      l_to_basic_pay                   ghr_pa_requests.to_basic_pay%TYPE;
      l_to_locality_adj                ghr_pa_requests.to_locality_adj%TYPE;
      l_to_adj_basic_pay               ghr_pa_requests.to_adj_basic_pay%TYPE;
      l_to_total_salary                ghr_pa_requests.to_total_salary%TYPE;
      l_to_other_pay_amount            ghr_pa_requests.to_other_pay_amount%TYPE;
      -- Added for WGI Custome user hook
      l_wgi_in_rec_type                ghr_wgi_pkg.wgi_in_rec_type; -- This is the IN record structure for the WGI hook
      l_wgi_out_rec_type               ghr_wgi_pkg.wgi_out_rec_type; -- This is the IN/OUT record structure for the WGI hook
                                                                     --
      l_open_pay_fields                BOOLEAN;
      l_personnel_office_id            ghr_pa_requests.personnel_office_id%TYPE;
      -- Added for the output parameters these values are not used anywhere
      l_tmp_work_schedule              ghr_pa_requests.work_schedule%TYPE;
      l_tmp_part_time_hours            ghr_pa_requests.part_time_hours%TYPE;
      l_tmp_from_pay_plan              ghr_pa_requests.from_pay_plan%TYPE;
      l_tmp_from_grade_or_level        ghr_pa_requests.from_grade_or_level%TYPE;
      l_tmp_from_step_or_rate          ghr_pa_requests.from_step_or_rate%TYPE;
      l_tmp_from_temp_step             ghr_pa_requests.from_step_or_rate%TYPE;
      -- Added pay calc record type in/out
      l_pay_calc_in_rec_type           ghr_pay_calc.pay_calc_in_rec_type;
      l_pay_calc_out_rec_type          ghr_pay_calc.pay_calc_out_rec_type;
      l_req                            VARCHAR2 (15);
      l_in_pay_plan                    ghr_pa_requests.from_pay_plan%TYPE;
      l_in_personnel_office_id         ghr_pa_requests.personnel_office_id%TYPE;
      -- Remarks
      l_pa_remark_id                   ghr_pa_remarks.pa_remark_id%TYPE;
      l_pre_object_version_number      ghr_pa_remarks.object_version_number%TYPE;
      l_remark_id1                     ghr_pa_remarks.remark_id%TYPE   := NULL;
      l_remark_desc1                   ghr_pa_remarks.description%TYPE := NULL;
      l_remark1_info1                  ghr_pa_remarks.remark_code_information1%TYPE
                                                                       := NULL;
      l_remark1_info2                  ghr_pa_remarks.remark_code_information2%TYPE
                                                                       := NULL;
      l_remark1_info3                  ghr_pa_remarks.remark_code_information3%TYPE
                                                                       := NULL;
      l_remark_id2                     ghr_pa_remarks.remark_id%TYPE   := NULL;
      l_remark_desc2                   ghr_pa_remarks.description%TYPE := NULL;
      l_remark2_info1                  ghr_pa_remarks.remark_code_information1%TYPE
                                                                       := NULL;
      l_remark2_info2                  ghr_pa_remarks.remark_code_information2%TYPE
                                                                       := NULL;
      l_remark2_info3                  ghr_pa_remarks.remark_code_information3%TYPE
                                                                       := NULL;
      l_commit                         NUMBER;
	------------ Bug 3680601
	  l_grp_box_id ghr_pois.groupbox_id%type;
	  l_no_groupbox_exception EXCEPTION;
	  l_from_asg_exception EXCEPTION;
	  l_retained_grade_exception EXCEPTION;
	  l_max_step_exception EXCEPTION;

	  CURSOR c_check_group_box(c_po_id ghr_pois.personnel_office_id%type) IS
	  SELECT groupbox_id
		FROM ghr_pois
			WHERE personnel_office_id = c_po_id;
--
      --  Bug#5482191 Added effective date condition.
      CURSOR get_sal_chg_fam
      IS
         SELECT noa_family_code
           FROM ghr_families
          WHERE noa_family_code IN (
                   SELECT noa_family_code
                     FROM ghr_noa_families
                    WHERE nature_of_action_id =
                                              (SELECT nature_of_action_id
                                                 FROM ghr_nature_of_actions
                                                WHERE code = l_first_noa_code
                                                AND l_effective_date BETWEEN NVL(Date_from,l_effective_date)
                                                                         AND NVL(date_to,l_effective_date)
                                               )
                                               )
            AND proc_method_flag = 'Y';

      CURSOR c_fnd_sessions
      IS
         SELECT 1
           FROM fnd_sessions
          WHERE session_id = USERENV ('sessionid');

      CURSOR cur_wgi_no_payplan (p_grd_id per_grades.grade_id%TYPE)
      IS
         SELECT gdf.segment1 pay_plan
           FROM per_grades grd, per_grade_definitions gdf
          WHERE grd.grade_id = p_grd_id
            AND grd.grade_definition_id = gdf.grade_definition_id;

      l_ret_calc_perc                  NUMBER (15,3);
      l_new_retention_allowance        NUMBER;
      l_per_pay_plan                   per_grade_definitions.segment1%TYPE;
      l_from_pay_table_identifier      ghr_pa_requests.from_pay_table_identifier%TYPE;
      -- Sun 4490539
      l_check_pay_plan ghr_pa_requests.from_pay_plan%TYPE;
      l_check_step_or_rate ghr_pa_requests.to_step_or_rate%type;
      -- End Sun 4490539
      -- vmididho 6145659
         cursor val_pa_remarks(p_pa_request_id in number,
	                       p_remark_id     in number)
             is
	     select 1
	     from   ghr_pa_remarks
	     where  pa_request_id = p_pa_request_id
	     and    pa_remark_id  = p_remark_id;

         m_val_pa_remarks   val_pa_remarks%rowtype;
      -- end 6145659
   BEGIN
      -- Set the Frequency - This is used for triggering the WGI process 90 days in advance of the Pay Date
      l_frequency := p_frequency;
      -- Set Concurrent Program name and Request ID
      l_req := fnd_profile.VALUE ('CONC_REQUEST_ID');
      l_proc := 'AWGI :' || l_req;
      l_in_pay_plan := p_pay_plan;
      l_in_personnel_office_id := p_personnel_office_id;
      l_exists := FALSE;

--      hr_utility.trace_on(null,'sundar');
      -- Replacing the insert dml  with a call to the dt_fndate.change_ses_date  procedure .

      dt_fndate.change_ses_date (p_ses_date      => TRUNC (SYSDATE),
                                 p_commit        => l_commit
                                );
-- The previous code did not perform a commit after writing to fnd_sessions
-- Hence not issuing  a Commit based on the value of the l_commit out variable

   hr_utility.set_location('Before Check if Personnel Office ID is having group box',1234);
   -- Bug 3649933. Check if Personnel Office ID is having group box
      IF l_in_personnel_office_id IS NOT NULL THEN
		FOR l_check_group_box IN c_check_group_box(l_in_personnel_office_id) LOOP
			l_grp_box_id := l_check_group_box.groupbox_id;
		END LOOP;

		IF l_grp_box_id IS NULL THEN
			-- If No group box is assigned, then throw an error
			l_errbuf := 'Group Box does not exist for this Personnel office id ' || l_in_personnel_office_id;
			RAISE l_no_groupbox_exception;
		END IF;
      END IF; -- If PO ID is not null
	   -- End 3649933


      OPEN per_assign_cursor (p_effective_date);
      LOOP
        BEGIN
            FETCH per_assign_cursor INTO l_person_id,
             l_national_identifier,
             l_date_of_birth,
             l_last_name,
             l_first_name,
             l_middle_names,
             l_full_name,
             l_position_id,
             l_assignment_id,
             l_grade_id,
             l_job_id,
             l_location_id,
             l_organization_id;
            --
            EXIT WHEN per_assign_cursor%NOTFOUND;
            -- Initialize the PA Request ID
            l_pa_request_id := NULL;
	   hr_utility.set_location('After fetch Person ID: ' || l_person_id,1234);
            --
           -- Bug 3941877
	      l_in_pay_plan := p_pay_plan;
	      l_in_personnel_office_id := p_personnel_office_id;
	   -- End Bug 3941877

	    IF (checkpoiparm (p_in_personnel_office_id      => l_in_personnel_office_id,
                          p_position_id                 => l_position_id,
                          p_effective_date              => p_effective_date
                          )
                        )
            THEN

	   hr_utility.set_location('Checking POI',1234);

	   FOR wgi_no_payplan_rec IN cur_wgi_no_payplan (l_grade_id)
	    LOOP
	       l_per_pay_plan := wgi_no_payplan_rec.pay_plan;
	    END LOOP;

	    IF check_pay_plan (l_per_pay_plan)  THEN
               -- If the assignment ID is not present then do not process this employee
               --
	        hr_utility.set_location('Checking Pay plan',1234);
		   IF p_log_flag = 'Y'
		   THEN
			  create_ghr_errorlog (p_program_name      => l_proc,
								   p_log_text          =>    'Fetched Full Name : '
														  || l_full_name
														  || ' Person ID : '
														  || TO_CHAR (l_person_id
																	 )
														  || ' Assignment ID : '
														  || TO_CHAR (l_assignment_id
																	 )
														  || ' Pay Plan Parameter : '
														  || l_in_pay_plan
														  || ' POI Parameter : '
														  || l_in_personnel_office_id,
								   p_message_name      => NULL,
								   p_log_date          => SYSDATE
								  );
		   END IF;

		   IF l_assignment_id IS NOT NULL
		   THEN                                  -- 1st IF of Assignment ID
                    --
				-- Get the WGI Status
				-- If Deny, Delay, Postpone, dont process WGI Bug 4475295

				 ghr_api.retrieve_element_entry_value (p_element_name  => 'Within Grade Increase',
			      p_input_value_name         => 'Status',
			      p_assignment_id            => l_assignment_id,
			      p_effective_date           => p_effective_date,
			      p_value                    => l_value,
			      p_multiple_error_flag      => l_multiple_error_flag
			     );

				IF l_value IN ('1','2','3') THEN
					NULL; -- Dont proceed from here.
                    -- Get SF52 From side data elements and Get the Pay Plan for the WGI
                    -- End Bug 4475295
				ELSE
				  BEGIN
					ghr_api.sf52_from_data_elements (p_person_id  => l_person_id,
				   p_assignment_id                    => l_assignment_id,
				   p_position_title                   => l_from_position_title,
				   p_position_number                  => l_from_position_number,
				   p_position_seq_no                  => l_from_position_seq_no,
				   p_pay_plan                         => l_from_pay_plan,
				   p_job_id                           => l_job_id,
				   p_occ_code                         => l_from_occ_code,
				   p_grade_id                         => l_grade_id,
				   p_grade_or_level                   => l_from_grade_or_level,
				   p_step_or_rate                     => l_from_step_or_rate,
				   p_total_salary                     => l_from_total_salary,
				   p_pay_basis                        => l_from_pay_basis,
                   -- FWFA Changes Bug#4444609
                   p_pay_table_identifier             => l_from_pay_table_identifier,
                   -- FWFA Changes
				   p_basic_pay                        => l_from_basic_pay,
				   p_locality_adj                     => l_from_locality_adj,
				   p_adj_basic_pay                    => l_from_adj_basic_pay,
				   p_other_pay                        => l_from_other_pay_amount,
				   p_au_overtime                      => l_to_au_overtime,
				   p_auo_premium_pay_indicator        => l_to_auo_premium_pay_indicator,
				   p_availability_pay                 => l_to_availability_pay,
				   p_ap_premium_pay_indicator         => l_to_ap_premium_pay_indicator,
				   p_retention_allowance              => l_to_retention_allowance,
				   p_supervisory_differential         => l_to_supervisory_differential,
				   p_staffing_differential            => l_to_staffing_differential,
				   p_organization_id                  => l_to_organization_id,
				   p_position_org_line1               => l_from_position_org_line1,
				   p_position_org_line2               => l_from_position_org_line2,
				   p_position_org_line3               => l_from_position_org_line3,
				   p_position_org_line4               => l_from_position_org_line4,
				   p_position_org_line5               => l_from_position_org_line5,
				   p_position_org_line6               => l_from_position_org_line6,
				   p_position_id                      => l_from_position_id,
				   p_duty_station_location_id         => l_duty_station_location_id,
				   p_pay_rate_determinant             => l_pay_rate_determinant,
				   p_work_schedule                    => l_tmp_work_schedule,
				   p_retention_allow_percentage       => l_retention_allow_percentage,
				   p_supervisory_diff_percentage      => l_supervisory_diff_percentage,
				   p_staffing_diff_percentage         => l_staffing_diff_percentage,
				   p_altered_pa_request_id            => NULL,
				   p_noa_id_corrected                 => NULL,
				   p_pa_history_id                    => NULL
				  );
					EXCEPTION
						WHEN OTHERS THEN
							raise l_from_asg_exception;
					END;
					-- For non-retained employees
				/*Start Bug: 9255822: rest of the code should not run for PRD Y*/
				IF l_pay_rate_determinant <> 'Y' THEN

				hr_utility.set_location('After fetching from assignments',1234);

					l_check_pay_plan := l_from_pay_plan;
					l_check_step_or_rate := l_from_step_or_rate;
                 --- Sundar 3386203
					-- In case of PRD's A,B,E,F,U,V get pay plan from Retained grade.
					BEGIN
						 IF l_pay_rate_determinant IN ('A','B','E','F','U','V') THEN
							l_retained_grade :=
									 ghr_pc_basic_pay.get_retained_grade_details
										(p_person_id      => l_person_id
										,p_effective_date => p_effective_date);
--									 l_from_pay_plan := l_retained_grade.pay_plan;

									-- Start 3431965
									IF l_retained_grade.temp_step IS NOT NULL THEN
									  l_check_step_or_rate := l_retained_grade.temp_step;
									ELSE
									  l_check_step_or_rate := l_retained_grade.step_or_rate;
    								  l_check_pay_plan := l_retained_grade.pay_plan;
									END IF;
									-- End 3431965
						 END IF;
					EXCEPTION
						WHEN OTHERS THEN
							raise l_retained_grade_exception;
					END;
					-- End Sundar 3386203

					  IF p_log_flag = 'Y'
					  THEN
					     create_ghr_errorlog (p_program_name      => l_proc,
								  p_log_text          =>    'Checking  CheckPayPlanParm '
											 || 'for Full Name : '
											 || l_full_name
											 || ' Person ID : '
											 || TO_CHAR (l_person_id
												    )
											 || ' Assignment ID : '
											 || TO_CHAR (l_assignment_id
												    )
											 || ' p_in_pay_plan : '
											 || l_in_pay_plan
											 || ' p_from_pay_plan : '
											 || l_from_pay_plan,
								  p_message_name      => NULL,
								  p_log_date          => SYSDATE
								 );
					  END IF;

                  -- Check to see if WGI is to be run for One Pay Plan only (2.1 CheckPayPlanParm)
                  IF (checkpayplanparm (p_in_pay_plan        => l_in_pay_plan,
                                        p_from_pay_plan      => l_check_pay_plan
                                       )
                     )
                  THEN
		  hr_utility.set_location('After checkpayplanparm',1234);
                  hr_utility.set_location ('Pay Plan criteria satisfied ',
                                              1000
                                             );

                     IF p_log_flag = 'Y'
                     THEN
                        create_ghr_errorlog (p_program_name      => l_proc,
                                             p_log_text          =>    'Checking  CheckPOIParm '
                                                                    || 'for Full Name : '
                                                                    || l_full_name
                                                                    || ' Person ID : '
                                                                    || TO_CHAR (l_person_id
                                                                               )
                                                                    || ' Assignment ID : '
                                                                    || TO_CHAR (l_assignment_id
                                                                               )
                                                                    || ' p_in_personnel_office_id : '
                                                                    || l_in_personnel_office_id
                                                                    || ' p_position_id : '
                                                                    || TO_CHAR (l_from_position_id
                                                                               )
                                                                    || ' p_effective_date : '
                                                                    || fnd_date.date_to_displaydate (p_effective_date
                                                                                                    ),
                                             p_message_name      => NULL,
                                             p_log_date          => SYSDATE
                                            );
                     END IF;

                     -- Check to see if WGI is to be run for One POI  only (2.2 CheckPOIParm)
                     /*IF (checkpoiparm (p_in_personnel_office_id      => l_in_personnel_office_id,
                                       p_position_id                 => l_from_position_id,
                                       p_effective_date              => p_effective_date
                                      )
                        )
                     THEN*/
                        --  Set the tmp pay plan for checking purposes
                        hr_utility.set_location ('POI criteria satisfied ' || l_in_personnel_office_id,
                                                 1000
                                                );
					 -- Bug 3649933. Check if Personnel Office ID is having group box
					    IF l_in_personnel_office_id IS NOT NULL THEN
							FOR l_check_group_box IN c_check_group_box(l_in_personnel_office_id) LOOP
								l_grp_box_id := l_check_group_box.groupbox_id;
							END LOOP;
							hr_utility.set_location ('l_grp_box_id ' || l_grp_box_id,
							1000);
							IF l_grp_box_id IS NULL THEN
								-- If No group box is assigned, then throw an error
								l_errbuf := 'Group Box does not exist for this Personnel office id ' || l_in_personnel_office_id;
								hr_utility.set_location ('Error buff set',1000);
								RAISE l_no_groupbox_exception;
							END IF;
					    END IF; -- If PO ID is not null
						-- End Bug 3649933.

                        IF p_log_flag = 'Y'
                        THEN
                           create_ghr_errorlog (p_program_name      => l_proc,
                                                p_log_text          =>    'Checking  CheckIfMaxPayPlan '
                                                                       || 'for Full Name : '
                                                                       || l_full_name
                                                                       || ' Person ID : '
                                                                       || TO_CHAR (l_person_id
                                                                                  )
                                                                       || ' Assignment ID : '
                                                                       || TO_CHAR (l_assignment_id
                                                                                  )
                                                                       || ' p_from_pay_plan : '
                                                                       || l_from_pay_plan
                                                                       || ' p_from_step_or_rate : '
                                                                       || l_from_step_or_rate,
                                                p_message_name      => NULL,
                                                p_log_date          => SYSDATE
                                               );
                        END IF;

                        --------------- Check  WGI Pay Date if its falls in range
						-- Bug 3747024 - Getting Due date
						 ghr_api.retrieve_element_entry_value (p_element_name             => 'Within Grade Increase',
                                                              p_input_value_name         => 'Date Due',
                                                              p_assignment_id            => l_assignment_id,
                                                              p_effective_date           => p_effective_date,
                                                              p_value                    => l_value,
                                                              p_multiple_error_flag      => l_multiple_error_flag
                                                             );
						IF l_value IS NOT NULL THEN
							l_wgi_due_date := fnd_date.canonical_to_date (l_value);
                        ELSE
                            l_wgi_due_date := NULL;
                        END IF;
						-- End Bug 3747024

                        ghr_api.retrieve_element_entry_value (p_element_name             => 'Within Grade Increase',
                                                              p_input_value_name         => 'Pay Date',
                                                              p_assignment_id            => l_assignment_id,
                                                              p_effective_date           => p_effective_date,
                                                              p_value                    => l_value,
                                                              p_multiple_error_flag      => l_multiple_error_flag
                                                             );

                        --
                        IF l_value IS NOT NULL
                        THEN
                           l_wgi_pay_date :=  fnd_date.canonical_to_date (l_value);
                        ELSE
                           l_wgi_pay_date := NULL;
                        END IF;

                        ---
                        IF p_log_flag = 'Y'
                        THEN
                           create_ghr_errorlog (p_program_name      => l_proc,
                                                p_log_text          =>    'retrieved WGI Pay Date for Full Name : '
                                                                       || l_full_name
                                                                       || ' Person ID : '
                                                                       || TO_CHAR (l_person_id
                                                                                  )
                                                                       || ' Assignment ID : '
                                                                       || TO_CHAR (l_assignment_id
                                                                                  )
                                                                       || ' WGI Pay Date : '
                                                                       || fnd_date.date_to_displaydate (l_wgi_pay_date
                                                                                                       )
                                                                       || ' WGI Due Date : '
                                                                       || fnd_date.date_to_displaydate (l_wgi_due_date
                                                                                                       ),
                                                p_message_name      => NULL,
                                                p_log_date          => SYSDATE
                                               );
                        END IF;

                        IF l_wgi_pay_date IS NOT NULL THEN --  2nd IF of WGI Pay Date
                           IF (p_effective_date >=
                                               (l_wgi_pay_date - l_frequency
                                               )
                              )
                           THEN                                                                  --  3rd IF of l_frequency
                                -- Initialize the effective date and then do not change it for this record
                              l_effective_date := l_wgi_pay_date;

                              IF p_log_flag = 'Y'
                              THEN
                                 create_ghr_errorlog (p_program_name      => l_proc,
                                                      p_log_text          =>    'Retrieving from data elements (sf52_from_data_elements) '
                                                                             || 'for Full Name : '
                                                                             || l_full_name
                                                                             || ' Person ID : '
                                                                             || TO_CHAR (l_person_id
                                                                                        )
                                                                             || ' Assignment ID : '
                                                                             || TO_CHAR (l_assignment_id
                                                                                        ),
                                                      p_message_name      => NULL,
                                                      p_log_date          => SYSDATE
                                                     );
                              END IF;

                              --------------End Checking Pay Date
                              -- Check to see if the employee has reached the max step (2.3 CheckIfMaxPayPlan)

                              IF (checkifmaxpayplan (p_from_pay_plan          => l_check_pay_plan,
                                                     p_from_step_or_rate      => l_check_step_or_rate
                                                    )
                                 )
                              THEN
                                 l_tmp_from_pay_plan := l_check_pay_plan;

                                 IF p_log_flag = 'Y'
                                 THEN
                                    create_ghr_errorlog (p_program_name      => l_proc,
                                                         p_log_text          =>    'Checking  check_assignment_prd  '
                                                                                || 'for Full Name : '
                                                                                || l_full_name
                                                                                || ' Person ID : '
                                                                                || TO_CHAR (l_person_id
                                                                                           )
                                                                                || ' Assignment ID : '
                                                                                || TO_CHAR (l_assignment_id
                                                                                           )
                                                                                || ' p_pay_rate_determinant : '
                                                                                || l_pay_rate_determinant,
                                                         p_message_name      => NULL,
                                                         p_log_date          => SYSDATE
                                                        );
                                 END IF;

                                 --
                                 -- Check if in PA Request table if there is  a record in NOA 893 from sysdate
                                 IF (check_assignment_prd (p_pay_rate_determinant      => l_pay_rate_determinant
                                                          )
                                    )
                                 THEN                                                                                    --  4th IF of PRD
                                      --
                                    IF p_log_flag = 'Y'
                                    THEN
                                       create_ghr_errorlog (p_program_name      => l_proc,
                                                            p_log_text          =>    'Checking  CheckIfFWPayPlan '
                                                                                   || 'for Full Name : '
                                                                                   || l_full_name
                                                                                   || ' Person ID : '
                                                                                   || TO_CHAR (l_person_id
                                                                                              )
                                                                                   || ' Assignment ID : '
                                                                                   || TO_CHAR (l_assignment_id
                                                                                              )
                                                                                   || ' p_from_pay_plan : '
                                                                                   || l_from_pay_plan,
                                                            p_message_name      => NULL,
                                                            p_log_date          => SYSDATE
                                                           );
                                    END IF;

                                    -- Derive l_days Wage Grade employees minimum time is 165 days and other is 350
                                    IF (checkiffwpayplan (p_from_pay_plan      => l_check_pay_plan
                                                         )
                                       )
                                    THEN
                                       l_days := 165;
                                    ELSE
                                       l_days := 350;
                                    END IF;

                                                -- Then Get reatined pay plan in l_from_pay_plan
                                             /* RP 10/4    l_retained_grade :=
                                                   ghr_pc_basic_pay.get_retained_grade_details
                                                   (p_person_id      => l_person_id
                                                   ,p_effective_date => l_effective_date);
                                          l_tmp_from_pay_plan       := l_retained_grade.pay_plan;
                                          l_tmp_from_grade_or_level := l_retained_grade.grade_or_level;
                                          l_tmp_from_step_or_rate   := l_retained_grade.step_or_rate;
                                 */
                                    --RP 04/10
                                          -- Derive NOA code
                                    IF l_tmp_from_pay_plan IN ('GM','GR') THEN --Bug# 6603968
                                        -- Bug#5482191 Process 893 for GM Employees after 07-JAN-2007
                                        IF l_effective_date < to_date('07/01/2007','DD/MM/YYYY') THEN
                                           l_first_noa_code := '891';
                                        ELSE
                                            l_first_noa_code := '893';
                                        END IF;
                                    ELSE
                                       l_first_noa_code := '893';
                                    END IF;
                                 ELSE
                                    IF l_check_pay_plan IN ('GM','GR') THEN --Bug# 6603968
                                        -- Bug#5482191 Process 893 for GM Employees after 07-JAN-2007
                                        IF l_effective_date < to_date('07/01/2007','DD/MM/YYYY') THEN
                                           l_first_noa_code := '891';
                                           hr_utility.set_location ('WGI noa code 891 ', 1  );
                                        ELSE
                                            l_first_noa_code := '893';
                                        END IF;
                                     --  bug# 5725910 code commented as this is not necessary..891 should not be assigned to first noa code irrespective of the effective date.
				     --  l_first_noa_code := '891';

                                    ELSE
                                       l_first_noa_code := '893';
                                    END IF;
                                 END IF; -- IF (check_assignment_prd

                                 IF p_log_flag = 'Y'
                                 THEN
                                    create_ghr_errorlog (p_program_name      => l_proc,
                                                         p_log_text          =>    'Checking  person_in_pa_requests '
                                                                                || 'for Full Name : '
                                                                                || l_full_name
                                                                                || ' Person ID : '
                                                                                || TO_CHAR (l_person_id
                                                                                           )
                                                                                || ' Assignment ID : '
                                                                                || TO_CHAR (l_assignment_id
                                                                                           )
                                                                                || ' p_first_noa_code : '
                                                                                || l_first_noa_code,
                                                         p_message_name      => NULL,
                                                         p_log_date          => SYSDATE
                                                        );
                                 END IF;

                                 --
                                 -- Check in PA Reqest table if there is a NOA of this person is existing already
                                 hr_utility.set_location ('Check in PA Reqest table if there is a NOA of this person ',
                                                          1000
                                                         );

                                 IF (person_in_pa_requests (p_person_id           => l_person_id,
                                                            p_effective_date      => l_effective_date,
                                                            p_first_noa_code      => l_first_noa_code,
                                                            p_days                => l_days
                                                           )
                                    )
                                 THEN                                                   -- 5th IF of PA Request
                                      --
                                    IF p_log_flag = 'Y'
                                    THEN
                                       create_ghr_errorlog (p_program_name      => l_proc,
                                                            p_log_text          =>    'No records found in person_in_pa_requests '
                                                                                   || 'for Full Name : '
                                                                                   || l_full_name
                                                                                   || ' Person ID : '
                                                                                   || TO_CHAR (l_person_id
                                                                                              )
                                                                                   || ' p_effective_date : '
                                                                                   || fnd_date.date_to_displaydate (l_effective_date
                                                                                                                   )
                                                                                   || ' p_first_noa_code : '
                                                                                   || l_first_noa_code,
                                                            p_message_name      => NULL,
                                                            p_log_date          => SYSDATE
                                                           );
                                    END IF;

                                    IF l_pay_rate_determinant IN
                                                         ('A', 'B', 'E', 'F')
                                    THEN
                                       IF p_log_flag = 'Y'
                                       THEN
                                          create_ghr_errorlog (p_program_name      => l_proc,
                                                               p_log_text          =>    'Getting Retained Pay Plan as PRD in A/B/E/F '
                                                                                      || 'for Full Name : '
                                                                                      || l_full_name
                                                                                      || ' Person ID : '
                                                                                      || TO_CHAR (l_person_id
                                                                                                 )
                                                                                      || ' p_effective_date : '
                                                                                      || fnd_date.date_to_displaydate (l_effective_date
                                                                                                                      )
                                                                                      || ' p_first_noa_code : '
                                                                                      || l_first_noa_code,
                                                               p_message_name      => NULL,
                                                               p_log_date          => SYSDATE
                                                              );
                                       END IF;

                                       --
                                       -- Then Get reatined pay plan in l_from_pay_plan
                                       l_retained_grade :=
                                          ghr_pc_basic_pay.get_retained_grade_details (p_person_id           => l_person_id,
                                                                                       p_effective_date      => l_effective_date
                                                                                      );
                                       l_tmp_from_pay_plan :=
                                                     l_retained_grade.pay_plan;
                                       --bug#5171417
                                       l_tmp_from_grade_or_level := l_retained_grade.grade_or_level;
                                       l_tmp_from_step_or_rate   := l_retained_grade.step_or_rate;
                                       l_tmp_from_temp_step      := l_retained_grade.temp_step;

                                    END IF;

                                    IF p_log_flag = 'Y'
                                    THEN
                                       create_ghr_errorlog (p_program_name      => l_proc,
                                                            p_log_text          =>    'Checking Pay Plan check_pay_plan : '
                                                                                   || 'for Full Name : '
                                                                                   || l_full_name
                                                                                   || ' Person ID : '
                                                                                   || TO_CHAR (l_person_id
                                                                                              )
                                                                                   || ' p_pay_plan : '
                                                                                   || l_tmp_from_pay_plan,
                                                            p_message_name      => NULL,
                                                            p_log_date          => SYSDATE
                                                           );
                                    END IF;

                                    -- Check if the Pay Plan is a valid pay plan for WGI
                                    IF (check_pay_plan (p_pay_plan      => l_tmp_from_pay_plan
                                                       )
                                       )
                                    THEN -- 6th If for Check Pay  Plan
                                       hr_utility.set_location (   'Pay Plan valid l_person_id'
                                                                || l_person_id,
                                                                1000
                                                               );

                                       --
                                       -- Get first_noa_desc description
                                       --
                                       IF p_log_flag = 'Y'
                                       THEN
                                          create_ghr_errorlog (p_program_name      => l_proc,
                                                               p_log_text          =>    'Pay Plan is valid for WGI : '
                                                                                      || 'for Full Name : '
                                                                                      || l_full_name
                                                                                      || ' Person ID : '
                                                                                      || TO_CHAR (l_person_id
                                                                                                 )
                                                                                      || ' p_pay_plan : '
                                                                                      || l_tmp_from_pay_plan,
                                                               p_message_name      => NULL,
                                                               p_log_date          => SYSDATE
                                                              );
                                       END IF;

                                       get_noa_code_desc (p_code                     => l_first_noa_code,
                                                          p_effective_date           => l_effective_date,
                                                          p_nature_of_action_id      => l_nature_of_action_id,
                                                          p_description              => l_first_noa_desc
                                                         );

                                       IF p_log_flag = 'Y'
                                       THEN
                                          create_ghr_errorlog (p_program_name      => l_proc,
                                                               p_log_text          =>    'NOA code desc get_noa_code_desc for WGI : '
                                                                                      || ' for Full Name : '
                                                                                      || l_full_name
                                                                                      || ' Person ID : '
                                                                                      || TO_CHAR (l_person_id
                                                                                                 )
                                                                                      || ' p_description : '
                                                                                      || l_first_noa_desc,
                                                               p_message_name      => NULL,
                                                               p_log_date          => SYSDATE
                                                              );
                                       END IF;

                                       --
                                       -- Get Legal Authority Codes and Description (GHR_US_LEGAL_AUTHORITY)
                                       -- Bug#5058116 Commented this code and added it just before update_sf52.
                                       /* derive_legal_auth_cd_remarks (
                                                     p_first_noa_code               => l_first_noa_code,
                                                     p_pay_rate_determinant         => l_pay_rate_determinant,
                                                     p_from_pay_plan                => l_check_pay_plan,
                                                     p_grade_or_level               => l_from_grade_or_level,
                                                     p_step_or_rate                 => l_from_step_or_rate,
                                                     p_retained_pay_plan            => l_tmp_from_pay_plan,
                                                     p_retained_grade_or_level      => l_tmp_from_grade_or_level,
                                                     p_retained_step_or_rate        => l_tmp_from_step_or_rate,
                                                     p_temp_step                    => l_tmp_from_temp_step,
                                                     p_effective_date               => l_effective_date,
                                                     p_first_action_la_code1        => l_first_action_la_code1,
                                                     p_first_action_la_desc1        => l_first_action_la_desc1,
                                                     p_first_action_la_code2        => l_first_action_la_code2,
                                                     p_first_action_la_desc2        => l_first_action_la_desc2,
                                                     p_remark_id1                   => l_remark_id1,
                                                     p_remark_desc1                 => l_remark_desc1,
                                                     p_remark1_info1                => l_remark1_info1,
                                                     p_remark1_info2                => l_remark1_info2,
                                                     p_remark1_info3                => l_remark1_info3,
                                                     p_remark_id2                   => l_remark_id2,
                                                     p_remark_desc2                 => l_remark_desc2,
                                                     p_remark2_info1                => l_remark2_info1,
                                                     p_remark2_info2                => l_remark2_info2,
                                                     p_remark2_info3                => l_remark2_info3
                                                    );

                                           --
                                           --  Calling create_sf52 with miminum parameters.
                                       --
                                       IF p_log_flag = 'Y'
                                       THEN
                                          create_ghr_errorlog (p_program_name      => l_proc,
                                                               p_log_text          =>    'NOA code desc derive_legal_auth_cd for WGI : '
                                                                  || ' for Full Name : '
                                                                  || l_full_name
                                                                  || ' Person ID : '
                                                                  || TO_CHAR (l_person_id
                                                                             )
                                                                  || ' p_first_action_la_code1 : '
                                                                  || l_first_action_la_code1
                                                                  || ' p_first_action_la_code2 : '
                                                                  || l_first_action_la_code2,
                                                               p_message_name      => NULL,
                                                               p_log_date          => SYSDATE
                                                              );
                                       END IF;*/

                                       -- Set values for the WGI Custom Hook for additional validations for
                                             -- person being selected for auto WGI
                                       l_wgi_in_rec_type.person_id :=
                                                                   l_person_id;
                                       l_wgi_in_rec_type.assignment_id :=
                                                               l_assignment_id;
                                       l_wgi_in_rec_type.position_id :=
                                                            l_from_position_id;
                                       l_wgi_in_rec_type.effective_date :=
                                                              l_effective_date;
                                       --
                                       -- Out record type initialzed to TRUE which means the
                                             -- person will be processed for WGI
                                             -- Call to the Custom WGI hook can override it to
                                             -- be FALSE.
                                       l_wgi_out_rec_type.process_person :=
                                                                          TRUE;
                                       -- Call WGI Custom Hook for additional validations for
                                             -- person being selected for auto WGI
                                       --
                                       ghr_custom_wgi_validation.custom_wgi_criteria (l_wgi_in_rec_type,
                                                                                      l_wgi_out_rec_type
                                                                                     );

                                       IF l_wgi_out_rec_type.process_person
                                       THEN
                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                                  p_log_text          =>    'Custom WGI Hook (custom_wgi_criteria) '
                                                                         || ' return value is TRUE for : '
                                                                         || ' for Full Name : '
                                                                         || l_full_name
                                                                         || ' Person ID : '
                                                                         || TO_CHAR (l_person_id
                                                                                    ),
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;
                                       ELSE
                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                                  p_log_text          =>    'Custom WGI Hook (custom_wgi_criteria) '
                                                                         || ' return value is FALSE for : '
                                                                         || ' for Full Name : '
                                                                         || l_full_name
                                                                         || ' Person ID : '
                                                                         || TO_CHAR (l_person_id
                                                                                    ),
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;
                                       END IF;

                                       -- If Custom hook returns true process the WGI
                                       IF l_wgi_out_rec_type.process_person
                                       THEN                                  -- 7th If for Custom Hook
                                            --  Set PA Request ID to null so that the shadow record is not created
                                          l_pa_request_id := NULL;

                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                      p_log_text          =>    'Creating AWGI PA request for :  '
                                                                             || l_full_name
                                                                             || ' Person ID : '
                                                                             || TO_CHAR (l_person_id
                                                                                        ),
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;

                                          OPEN get_sal_chg_fam;
                                          FETCH get_sal_chg_fam INTO l_noa_family_code;
                                          CLOSE get_sal_chg_fam;
                                          --
                                              -- Create the WGI SF52
                                          --
                                          ghr_sf52_api.create_sf52 (
                                            p_noa_family_code                   => l_noa_family_code,
                                            p_person_id                         => l_person_id,
                                            p_effective_date                    => l_effective_date,
                                            p_first_noa_code                    => l_first_noa_code,
                                            p_first_noa_desc                    => l_first_noa_desc,
                                            p_first_action_la_code1             => l_first_action_la_code1,
                                            p_first_action_la_desc1             => l_first_action_la_desc1,
                                            p_first_action_la_code2             => l_first_action_la_code2,
                                            p_first_action_la_desc2             => l_first_action_la_desc2,
                                            p_proposed_effective_asap_flag      => l_proposed_effective_asap_flag,
                                            p_from_adj_basic_pay                => l_from_adj_basic_pay,
                                            p_from_basic_pay                    => l_from_basic_pay,
                                            p_from_grade_or_level               => l_from_grade_or_level,
                                            p_from_locality_adj                 => l_from_locality_adj,
                                            p_from_occ_code                     => l_from_occ_code,
                                            p_from_other_pay_amount             => l_from_other_pay_amount,
                                            p_from_pay_basis                    => l_from_pay_basis,
                                            p_from_pay_plan                     => l_from_pay_plan,
                                            p_employee_assignment_id            => l_assignment_id,
                                            p_employee_date_of_birth            => l_date_of_birth,
                                            p_employee_first_name               => l_first_name,
                                            p_employee_last_name                => l_last_name,
                                            p_employee_middle_names             => l_middle_names,
                                            p_employee_national_identifier      => l_national_identifier,
                                            p_from_position_id                  => l_from_position_id,
                                            p_from_position_org_line1           => l_from_position_org_line1,
                                            p_from_position_org_line2           => l_from_position_org_line2,
                                            p_from_position_org_line3           => l_from_position_org_line3,
                                            p_from_position_org_line4           => l_from_position_org_line4,
                                            p_from_position_org_line5           => l_from_position_org_line5,
                                            p_from_position_org_line6           => l_from_position_org_line6,
                                            p_from_position_number              => l_from_position_number,
                                            p_from_position_seq_no              => l_from_position_seq_no,
                                            p_from_position_title               => l_from_position_title,
                                            p_from_step_or_rate                 => l_from_step_or_rate,
                                            p_from_total_salary                 => l_from_total_salary,
                                            p_pay_rate_determinant              => l_pay_rate_determinant,
                                            p_first_noa_id                      => l_nature_of_action_id,
                                            p_1_user_name_acted_on              => NULL,
                                            p_pa_request_id                     => l_pa_request_id,
                                            p_par_object_version_number         => l_par_object_version_number,
                                            p_1_pa_routing_history_id           => l_1_pa_routing_history_id,
                                            p_1_prh_object_version_number       => l_1_prh_object_version_number,
                                            p_1_action_taken                    => l_u_action_taken,
                                            p_2_pa_routing_history_id           => l_2_pa_routing_history_id,
                                            p_2_prh_object_version_number       => l_2_prh_object_version_number,
                                            -- FWFA Changes Bug#4444609
                                            p_from_pay_table_identifier         => l_from_pay_table_identifier
                                            -- FWFA Changes
                                           );
                                          COMMIT;
                                          --
                                          -- set the start wgi flag
                                          --
                                          hr_utility.set_location (   'Create SF52 l_person_id'
                                                                   || l_person_id,
                                                                   1000
                                                                  );
                                          l_start_wgi_wf_flag := 'Y';

                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                  p_log_text          =>    'Created AWGI SF52 / PA Request ID : '
                                                                         || TO_CHAR (l_pa_request_id
                                                                                    )
                                                                         || ' for : '
                                                                         || l_full_name
                                                                         || ' Person ID : '
                                                                         || TO_CHAR (l_person_id
                                                                                    ),
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;

                                             --
                                          -- Get SF52 Person DDF details
                                           --
                                          ghr_pa_requests_pkg.get_sf52_person_ddf_details (
                                                   p_person_id                  => l_person_id,
                                                   p_date_effective             => l_effective_date,
                                                   p_citizenship                => l_citizenship,
                                                   p_veterans_preference        => l_veterans_preference,
                                                   p_veterans_pref_for_rif      => l_veterans_pref_for_rif,
                                                   p_veterans_status            => l_veterans_status,
                                                   p_scd_leave                  => l_scd_leave
                                                  );
                                          --
                                          -- populate service comp date
                                          --
                                          l_service_comp_date :=
                                             fnd_date.canonical_to_date (l_scd_leave
                                                                        );

                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                              p_log_text          =>    'After get_SF52_person_ddf_details for : '
                                                         || l_full_name
                                                         || ' Person ID : '
                                                         || TO_CHAR (l_person_id
                                                                    )
                                                         || ' service_comp_date : '
                                                         || fnd_date.date_to_displaydate (l_service_comp_date
                                                                                         ),
                                              p_message_name      => NULL,
                                              p_log_date          => SYSDATE
                                             );
                                          END IF;

                                           --
                                             -- Get education details
                                          --
                                          ghr_api.return_education_details (
                                                        p_person_id                 => l_person_id,
                                                        p_effective_date            => l_effective_date,
                                                        p_education_level           => l_education_level,
                                                        p_academic_discipline       => l_academic_discipline,
                                                        p_year_degree_attained      => l_year_degree_attained
                                                       );

                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                              p_log_text          =>    'After return_education_details for : '
                                                                     || l_full_name
                                                                     || ' Person ID : '
                                                                     || TO_CHAR (l_person_id
                                                                                ),
                                              p_message_name      => NULL,
                                              p_log_date          => SYSDATE
                                             );
                                          END IF;

                                          --
                                          -- Get assignment details
                                          --
                                          ghr_pa_requests_pkg.get_sf52_asg_ddf_details (
                                                            p_assignment_id             => l_assignment_id,
                                                            p_date_effective            => l_effective_date,
                                                            p_tenure                    => l_tenure,
                                                            p_annuitant_indicator       => l_annuitant_indicator,
                                                            p_pay_rate_determinant      => l_pay_rate_determinant,
                                                            p_work_schedule             => l_work_schedule,
                                                            p_part_time_hours           => l_part_time_hours
                                                           );
                                          --
                                          -- get fegli desc
                                          --
                                          l_annuitant_indicator_desc :=
                                             ghr_pa_requests_pkg.get_lookup_meaning (800,
                                                                                     'GHR_US_ANNUITANT INDICATOR',
                                                                                     l_annuitant_indicator
                                                                                    );
                                           --
                                          -- populate work schedule desc
                                          --
                                          l_work_schedule_desc :=
                                             ghr_pa_requests_pkg.get_lookup_meaning (800,
                                                                                     'GHR_US_WORK_SCHEDULE',
                                                                                     l_work_schedule
                                                                                    );
                                             --
                                           -- Get position details
                                          --
                                          ghr_pa_requests_pkg.get_sf52_pos_ddf_details (
                                                        p_position_id                 => l_from_position_id,
                                                        p_date_effective              => l_effective_date,
                                                        p_flsa_category               => l_flsa_category,
                                                        p_bargaining_unit_status      => l_bargaining_unit_status,
                                                        p_work_schedule               => l_work_schedule,
                                                        p_functional_class            => l_functional_class,
                                                        p_supervisory_status          => l_supervisory_status,
                                                        p_position_occupied           => l_position_occupied,
                                                        p_appropriation_code1         => l_appropriation_code1,
                                                        p_appropriation_code2         => l_appropriation_code2,
                                                        p_personnel_office_id         => l_personnel_office_id,
                                                        p_office_symbol               => l_from_office_symbol,
                                                        p_part_time_hours             => l_tmp_part_time_hours
                                                       );

                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                                  p_log_text          =>    'After get_SF52_pos_ddf_details for : '
                                                                                         || l_full_name
                                                                                         || ' Person ID : '
                                                                                         || TO_CHAR (l_person_id
                                                                                                    ),
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;

                                             --
                                          -- Get location details
                                          --
                                          ghr_pa_requests_pkg.get_sf52_loc_ddf_details (
                                                                p_location_id          => l_location_id,
                                                                p_duty_station_id      => l_duty_station_id
                                                               );

                                          --
                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                                  p_log_text          =>    'After get_SF52_loc_ddf_details for : '
                                                                                         || l_full_name
                                                                                         || ' Person ID : '
                                                                                         || TO_CHAR (l_person_id
                                                                                                    ),
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;

                                             --
                                          -- Get duty station details
                                          --
                                          ghr_pa_requests_pkg.get_duty_station_details (
                                                                p_duty_station_id        => l_duty_station_id,
                                                                p_effective_date         => l_effective_date,
                                                                p_duty_station_code      => l_duty_station_code,
                                                                p_duty_station_desc      => l_duty_station_desc
                                                               );

                                          -- fetch FEGLI code and description
                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                                  p_log_text          =>    'After get_duty_station_details for : '
                                                                                         || l_full_name
                                                                                         || ' Person ID : '
                                                                                         || TO_CHAR (l_person_id
                                                                                                    ),
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;

                                          ghr_api.retrieve_element_entry_value (
                                                        p_element_name             => 'FEGLI',
                                                        p_input_value_name         => 'FEGLI',
                                                        p_assignment_id            => l_assignment_id,
                                                        p_effective_date           => l_effective_date,
                                                        p_value                    => l_fegli,
                                                        p_multiple_error_flag      => l_multiple_error_flag
                                                       );
                                          l_fegli_desc :=
                                             ghr_pa_requests_pkg.get_lookup_meaning (800,
                                                                                     'GHR_US_FEGLI',
                                                                                     l_fegli
                                                                                    );

                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                                  p_log_text          =>    'After retrieve_element_entry_value for : '
                                                                                         || l_full_name
                                                                                         || ' Person ID : '
                                                                                         || TO_CHAR (l_person_id
                                                                                                    ),
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;

                                          -- Set the IN record structure values
                                          l_pay_calc_in_rec_type.person_id :=
                                                                   l_person_id;
                                          l_pay_calc_in_rec_type.position_id :=
                                                            l_from_position_id;
                                          l_pay_calc_in_rec_type.noa_family_code :=
                                                             l_noa_family_code;
                                          l_pay_calc_in_rec_type.noa_code :=
                                                              l_first_noa_code;
                                          l_pay_calc_in_rec_type.second_noa_code :=
                                                                          NULL;
                                          l_pay_calc_in_rec_type.effective_date :=
                                                              l_effective_date;
                                          l_pay_calc_in_rec_type.pay_rate_determinant :=
                                                        l_pay_rate_determinant;
                                          l_pay_calc_in_rec_type.pay_plan :=
                                                               l_from_pay_plan;
                                          l_pay_calc_in_rec_type.grade_or_level :=
                                                         l_from_grade_or_level;
                                          l_pay_calc_in_rec_type.step_or_rate :=
                                                           l_from_step_or_rate;
                                          l_pay_calc_in_rec_type.pay_basis :=
                                                              l_from_pay_basis;
                                          l_pay_calc_in_rec_type.user_table_id :=
                                                                          NULL;
                                          l_pay_calc_in_rec_type.duty_station_id :=
                                                             l_duty_station_id;
                                          l_pay_calc_in_rec_type.auo_premium_pay_indicator :=
                                                l_to_auo_premium_pay_indicator;
                                          l_pay_calc_in_rec_type.ap_premium_pay_indicator :=
                                                 l_to_ap_premium_pay_indicator;
                                          l_pay_calc_in_rec_type.retention_allowance :=
                                                      l_to_retention_allowance;
                                          l_pay_calc_in_rec_type.to_ret_allow_percentage :=
                                                  l_retention_allow_percentage;
                                          l_pay_calc_in_rec_type.supervisory_differential :=
                                                                          NULL;
                                          l_pay_calc_in_rec_type.staffing_differential :=
                                                    l_to_staffing_differential;
                                          l_pay_calc_in_rec_type.current_basic_pay :=
                                                              l_from_basic_pay;
                                          l_pay_calc_in_rec_type.current_adj_basic_pay :=
                                                          l_from_adj_basic_pay;
                                          l_pay_calc_in_rec_type.current_step_or_rate :=
                                                           l_from_step_or_rate;
                                          l_pay_calc_in_rec_type.pa_request_id :=
                                                                          NULL;
                                          --Bug# 6340691
                                          l_pay_calc_in_rec_type.open_out_locality_adj := l_from_locality_adj;
                                          -- Call the pay calc
                                          ghr_pay_calc.sql_main_pay_calc (p_pay_calc_data          => l_pay_calc_in_rec_type,
                                                                          p_pay_calc_out_data      => l_pay_calc_out_rec_type,
                                                                          p_message_set            => l_message_set,
                                                                          p_calculated             => l_calculated
                                                                         );
                                          -- Set the out records
                                          l_to_basic_pay :=
                                             l_pay_calc_out_rec_type.basic_pay;
                                          l_to_locality_adj :=
                                             l_pay_calc_out_rec_type.locality_adj;
                                          l_to_adj_basic_pay :=
                                             l_pay_calc_out_rec_type.adj_basic_pay;
                                          l_to_total_salary :=
                                             l_pay_calc_out_rec_type.total_salary;
                                          l_to_other_pay_amount :=
                                             l_pay_calc_out_rec_type.other_pay_amount;
                                          l_to_au_overtime :=
                                             l_pay_calc_out_rec_type.au_overtime;
                                          l_to_availability_pay :=
                                             l_pay_calc_out_rec_type.availability_pay;
                                          l_to_step_or_rate :=
                                             l_pay_calc_out_rec_type.out_step_or_rate;
                                          l_to_retention_allowance :=
                                             l_pay_calc_out_rec_type.retention_allowance;
                                          hr_utility.set_location (   'retention_allowance = '
                                                                   || TO_CHAR (l_to_retention_allowance
                                                                              ),
                                                                   10
                                                                  );
                                          hr_utility.set_location (   'Supervisory Diff Amount = '
                                                                   || TO_CHAR (l_to_supervisory_differential
                                                                              ),
                                                                   10
                                                                  );

                                          /****************
                                          ------Other Pay new requirement
                                          l_new_retention_allowance      := NULL;
                                          l_ret_calc_perc                := 0;

                                          hr_utility.set_location('retention_allowance = ' || to_char(l_to_retention_allowance),10);
                                          hr_utility.set_location('Supervisory Diff Amount = ' || to_char(l_to_supervisory_differential),10);

                                          if l_to_retention_allowance is not null then
                                             if l_from_basic_pay <> l_to_basic_pay then
                                               if l_retention_allow_percentage is null then
                                                 l_ret_calc_perc := (l_to_retention_allowance / l_from_basic_pay) * 100;
                                                 l_new_retention_allowance :=
                                                      ROUND(ghr_pay_calc.convert_amount(l_to_basic_pay,l_from_pay_basis,'PA')
                                                                                * l_ret_calc_perc / 100 ,0);
                                               else
                                                 l_new_retention_allowance :=
                                                      ROUND(ghr_pay_calc.convert_amount(l_to_basic_pay,l_from_pay_basis,'PA')
                                                                                * l_retention_allow_percentage / 100 ,0);
                                               end if;
                                             else
                                               l_new_retention_allowance := l_to_retention_allowance;
                                             end if;
                                          end if;

                                          l_to_retention_allowance := l_new_retention_allowance;

                                          hr_utility.set_location('retention_allowance = ' || to_char(l_to_retention_allowance),12);
                                          hr_utility.set_location('Supervisory Diff Amount = ' || to_char(l_to_supervisory_differential),12);

                                          l_to_other_pay_amount    := nvl(l_to_au_overtime,0)
                                                              + nvl(l_to_availability_pay,0)
                                                              + nvl(l_to_retention_allowance,0)
                                                              + nvl(l_to_supervisory_differential,0)
                                                              + nvl(l_to_staffing_differential,0);
                                          if l_to_other_pay_amount = 0 then
                                             l_to_other_pay_amount := null;
                                          end if;
                                          l_pay_calc_out_rec_type.other_pay_amount := l_to_other_pay_amount;

                                          l_to_total_salary := NVL(l_to_adj_basic_pay,0)
                                                         + ghr_pay_calc.convert_amount(NVL(l_to_other_pay_amount,0),
                                                                                'PA',
                                                                                l_from_pay_basis);

                                          l_pay_calc_out_rec_type.total_salary := l_to_total_salary;

                                          ------Other Pay new requirement end
                                          ***********/
                                          IF l_calculated
                                          THEN
                                             l_custom_pay_calc_flag := 'N';
                                          ELSE
                                             l_custom_pay_calc_flag := 'Y';
                                          END IF;

                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                                  p_log_text          =>    'After sql_main_pay_calc  for : '
                                                                                         || l_full_name
                                                                                         || ' Person ID : '
                                                                                         || TO_CHAR (l_person_id
                                                                                                    ),
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;

                                          -- Populate all the parameters for update_sf52
                                          l_validate := FALSE;
                                            --
                                            --
                                          -- fetch retirement plan and desc
                                          --
                                          ghr_api.retrieve_element_entry_value (
                                                            p_element_name             => 'Retirement Plan',
                                                            p_input_value_name         => 'Plan',
                                                            p_assignment_id            => l_assignment_id,
                                                            p_effective_date           => l_effective_date,
                                                            p_value                    => l_retirement_plan,
                                                            p_multiple_error_flag      => l_multiple_error_flag
                                                           );

                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                                  p_log_text          =>    'After retrieve_element_entry_value  for : '
                                                                                         || l_full_name
                                                                                         || ' Person ID : '
                                                                                         || TO_CHAR (l_person_id
                                                                                                    )
                                                                                         || ' l_retirement_plan : '
                                                                                         || l_retirement_plan,
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;

                                          IF l_retirement_plan IS NOT NULL
                                          THEN
                                             l_retirement_plan_desc :=
                                                ghr_pa_requests_pkg.get_lookup_meaning (800,
                                                                                        'GHR_US_RETIREMENT_PLAN',
                                                                                        l_retirement_plan
                                                                                       );
                                          END IF;

                                          --
                                          OPEN get_sal_chg_fam;
                                          FETCH get_sal_chg_fam INTO l_noa_family_code;
                                          CLOSE get_sal_chg_fam;

                                          -- Bug#5058116 Added derive_legal_auth_cd_remarks call before update_sf52 call.
                                          -- Get Legal Authority Codes and Description (GHR_US_LEGAL_AUTHORITY)
                                          --
                                          derive_legal_auth_cd_remarks (
                                                p_first_noa_code            => l_first_noa_code,
                                                 p_pay_rate_determinant         => NVL(l_pay_calc_out_rec_type.out_pay_rate_determinant,
                                                                                       l_pay_rate_determinant),
                                                 p_from_pay_plan                => l_check_pay_plan,
                                                 p_grade_or_level               => l_from_grade_or_level,
                                                 p_step_or_rate                 => l_from_step_or_rate,
                                                 p_retained_pay_plan            => l_tmp_from_pay_plan,
                                                 p_retained_grade_or_level      => l_tmp_from_grade_or_level,
                                                 p_retained_step_or_rate        => l_tmp_from_step_or_rate,
                                                 p_temp_step                    => l_tmp_from_temp_step,
                                                 p_effective_date               => l_effective_date,
                                                 p_first_action_la_code1        => l_first_action_la_code1,
                                                 p_first_action_la_desc1        => l_first_action_la_desc1,
                                                 p_first_action_la_code2        => l_first_action_la_code2,
                                                 p_first_action_la_desc2        => l_first_action_la_desc2,
                                                 p_remark_id1                   => l_remark_id1,
                                                 p_remark_desc1                 => l_remark_desc1,
                                                 p_remark1_info1                => l_remark1_info1,
                                                 p_remark1_info2                => l_remark1_info2,
                                                 p_remark1_info3                => l_remark1_info3,
                                                 p_remark_id2                   => l_remark_id2,
                                                 p_remark_desc2                 => l_remark_desc2,
                                                 p_remark2_info1                => l_remark2_info1,
                                                 p_remark2_info2                => l_remark2_info2,
                                                 p_remark2_info3                => l_remark2_info3
                                                );

                                           --
                                           --  Calling create_sf52 with miminum parameters.
                                           --
                                           IF p_log_flag = 'Y' THEN
                                              create_ghr_errorlog (p_program_name      => l_proc,
                                                                   p_log_text          =>    'NOA code desc derive_legal_auth_cd for WGI : '
                                                                      || ' for Full Name : '
                                                                      || l_full_name
                                                                      || ' Person ID : '
                                                                      || TO_CHAR (l_person_id
                                                                                 )
                                                                      || ' p_first_action_la_code1 : '
                                                                      || l_first_action_la_code1
                                                                      || ' p_first_action_la_code2 : '
                                                                      || l_first_action_la_code2,
                                                                   p_message_name      => NULL,
                                                                   p_log_date          => SYSDATE
                                                                  );
                                           END IF;

                                          ghr_sf52_api.update_sf52 (
                                                p_validate                          => l_validate,
                                                p_pa_request_id                     => l_pa_request_id,
                                                p_noa_family_code                   => l_noa_family_code,
                                                p_routing_group_id                  => l_routing_group_id,
                                                p_par_object_version_number         => l_par_object_version_number,
                                                p_proposed_effective_asap_flag      => l_proposed_effective_asap_flag,
                                                p_academic_discipline               => l_academic_discipline,
                                                p_additional_info_person_id         => NULL,
                                                p_additional_info_tel_number        => NULL,
                                                p_altered_pa_request_id             => NULL,
                                                p_annuitant_indicator               => l_annuitant_indicator,
                                                p_annuitant_indicator_desc          => NULL,
                                                p_appropriation_code1               => l_appropriation_code1,
                                                p_appropriation_code2               => l_appropriation_code2,
                                                p_authorized_by_person_id           => NULL,
                                                p_authorized_by_title               => NULL,
                                                p_award_amount                      => NULL,
                                                p_award_uom                         => NULL,
                                                p_bargaining_unit_status            => l_bargaining_unit_status,
                                                p_citizenship                       => l_citizenship,
                                                p_concurrence_date                  => NULL,
                                                p_custom_pay_calc_flag              => l_custom_pay_calc_flag,
                                                p_duty_station_code                 => l_duty_station_code,
                                                p_duty_station_desc                 => l_duty_station_desc,
                                                p_duty_station_id                   => l_duty_station_id,
                                                p_duty_station_location_id          => l_duty_station_location_id,
                                                p_education_level                   => l_education_level,
                                                p_effective_date                    => l_effective_date,
                                                p_employee_assignment_id            => l_assignment_id,
                                                p_employee_date_of_birth            => l_date_of_birth,
                                                p_employee_first_name               => l_first_name,
                                                p_employee_last_name                => l_last_name,
                                                p_employee_middle_names             => l_middle_names,
                                                p_employee_national_identifier      => l_national_identifier,
                                                p_fegli                             => l_fegli,
                                                p_fegli_desc                        => l_fegli_desc,
                                                p_first_action_la_code1             => l_first_action_la_code1,
                                                p_first_action_la_code2             => l_first_action_la_code2,
                                                p_first_action_la_desc1             => l_first_action_la_desc1,
                                                p_first_action_la_desc2             => l_first_action_la_desc2,
                                                p_first_noa_cancel_or_correct       => NULL,
                                                p_first_noa_code                    => l_first_noa_code,
                                                p_first_noa_desc                    => l_first_noa_desc,
                                                p_first_noa_id                      => l_nature_of_action_id,
                                                p_first_noa_pa_request_id           => NULL,
                                                p_flsa_category                     => l_flsa_category,
                                                p_forwarding_address_line1          => NULL,
                                                p_forwarding_address_line2          => NULL,
                                                p_forwarding_address_line3          => NULL,
                                                p_forwarding_country                => NULL,
                                                p_forwarding_postal_code            => NULL,
                                                p_forwarding_region_2               => NULL,
                                                p_forwarding_town_or_city           => NULL,
                                                p_from_adj_basic_pay                => l_from_adj_basic_pay,
                                                p_from_basic_pay                    => l_from_basic_pay,
                                                p_from_grade_or_level               => l_from_grade_or_level,
                                                p_from_locality_adj                 => l_from_locality_adj,
                                                p_from_occ_code                     => l_from_occ_code,
                                                p_from_other_pay_amount             => l_from_other_pay_amount,
                                                p_from_pay_basis                    => l_from_pay_basis,
                                                p_from_pay_plan                     => l_from_pay_plan,
                                                p_from_position_id                  => l_from_position_id,
                                                p_from_position_org_line1           => l_from_position_org_line1,
                                                p_from_position_org_line2           => l_from_position_org_line2,
                                                p_from_position_org_line3           => l_from_position_org_line3,
                                                p_from_position_org_line4           => l_from_position_org_line4,
                                                p_from_position_org_line5           => l_from_position_org_line5,
                                                p_from_position_org_line6           => l_from_position_org_line6,
                                                p_from_position_number              => l_from_position_number,
                                                p_from_position_seq_no              => l_from_position_seq_no,
                                                p_from_position_title               => l_from_position_title,
                                                p_from_step_or_rate                 => l_from_step_or_rate,
                                                p_from_total_salary                 => l_from_total_salary,
                                                p_functional_class                  => l_functional_class,
                                                p_notepad                           => NULL,
                                                p_part_time_hours                   => l_part_time_hours,
                                                -- FWFA Changes Bug#4444609 Added NVL Condition
                                                p_pay_rate_determinant              => NVL(l_pay_calc_out_rec_type.out_pay_rate_determinant,
                                                                              l_pay_rate_determinant),
                                                -- FWFA Changes
                                                p_person_id                         => l_person_id,
                                                p_position_occupied                 => l_position_occupied,
                                                p_proposed_effective_date           => NULL,
                                                p_requested_by_person_id            => NULL,
                                                p_requested_by_title                => NULL,
                                                p_requested_date                    => NULL,
                                                p_requesting_office_remarks_de      => NULL,
                                                p_requesting_office_remarks_fl      => NULL,
                                                p_request_number                    =>    'WGI:'
                                                                                       || l_pa_request_id,
                                                p_resign_and_retire_reason_des      => NULL,
                                                p_retirement_plan                   => l_retirement_plan,
                                                p_retirement_plan_desc              => l_retirement_plan_desc,
                                                p_second_action_la_code1            => NULL,
                                                p_second_action_la_code2            => NULL,
                                                p_second_action_la_desc1            => NULL,
                                                p_second_action_la_desc2            => NULL,
                                                p_second_noa_cancel_or_correct      => NULL,
                                                p_second_noa_code                   => NULL,
                                                p_second_noa_desc                   => NULL,
                                                p_second_noa_id                     => NULL,
                                                p_second_noa_pa_request_id          => NULL,
                                                p_service_comp_date                 => l_service_comp_date,
                                                p_supervisory_status                => l_supervisory_status,
                                                p_tenure                            => l_tenure,
                                                p_to_adj_basic_pay                  => l_to_adj_basic_pay,
                                                p_to_basic_pay                      => l_to_basic_pay,
                                                p_to_grade_id                       => l_grade_id,
                                                p_to_grade_or_level                 => l_from_grade_or_level,
                                                p_to_job_id                         => l_job_id,
                                                p_to_locality_adj                   => l_to_locality_adj,
                                                p_to_occ_code                       => l_from_occ_code,
                                                p_to_organization_id                => l_to_organization_id,
                                                p_to_other_pay_amount               => l_to_other_pay_amount,
                                                p_to_au_overtime                    => l_to_au_overtime,
                                                p_to_auo_premium_pay_indicator      => l_to_auo_premium_pay_indicator,
                                                p_to_availability_pay               => l_to_availability_pay,
                                                p_to_ap_premium_pay_indicator       => l_to_ap_premium_pay_indicator,
                                                p_to_retention_allowance            => l_to_retention_allowance,
                                                p_to_supervisory_differential       => l_to_supervisory_differential,
                                                p_to_staffing_differential          => l_to_staffing_differential,
                                                p_to_pay_basis                      => l_from_pay_basis,
                                                p_to_pay_plan                       => l_from_pay_plan,
                                                p_to_position_id                    => l_from_position_id,
                                                p_to_position_org_line1             => l_from_position_org_line1,
                                                p_to_position_org_line2             => l_from_position_org_line2,
                                                p_to_position_org_line3             => l_from_position_org_line3,
                                                p_to_position_org_line4             => l_from_position_org_line4,
                                                p_to_position_org_line5             => l_from_position_org_line5,
                                                p_to_position_org_line6             => l_from_position_org_line6,
                                                p_to_position_number                => l_from_position_number,
                                                p_to_position_seq_no                => l_from_position_seq_no,
                                                p_to_position_title                 => l_from_position_title,
                                                p_to_step_or_rate                   => l_to_step_or_rate,
                                                p_to_total_salary                   => l_to_total_salary,
                                                p_veterans_preference               => l_veterans_preference,
                                                p_veterans_pref_for_rif             => l_veterans_pref_for_rif,
                                                p_veterans_status                   => l_veterans_status,
                                                p_work_schedule                     => l_work_schedule,
                                                p_work_schedule_desc                => l_work_schedule_desc,
                                                p_year_degree_attained              => l_year_degree_attained,
                                                p_first_noa_information1            => NULL,
                                                p_first_noa_information2            => NULL,
                                                p_first_noa_information3            => NULL,
                                                p_first_noa_information4            => NULL,
                                                p_first_noa_information5            => NULL,
                                                p_second_lac1_information1          => NULL,
                                                p_second_lac1_information2          => NULL,
                                                p_second_lac1_information3          => NULL,
                                                p_second_lac1_information4          => NULL,
                                                p_second_lac1_information5          => NULL,
                                                p_second_lac2_information1          => NULL,
                                                p_second_lac2_information2          => NULL,
                                                p_second_lac2_information3          => NULL,
                                                p_second_lac2_information4          => NULL,
                                                p_second_lac2_information5          => NULL,
                                                p_second_noa_information1           => NULL,
                                                p_second_noa_information2           => NULL,
                                                p_second_noa_information3           => NULL,
                                                p_second_noa_information4           => NULL,
                                                p_second_noa_information5           => NULL,
                                                p_first_lac1_information1           => NULL,
                                                p_first_lac1_information2           => NULL,
                                                p_first_lac1_information3           => NULL,
                                                p_first_lac1_information4           => NULL,
                                                p_first_lac1_information5           => NULL,
                                                p_first_lac2_information1           => NULL,
                                                p_first_lac2_information2           => NULL,
                                                p_first_lac2_information3           => NULL,
                                                p_first_lac2_information4           => NULL,
                                                p_first_lac2_information5           => NULL,
                                                p_u_attachment_modified_flag        => l_u_attachment_modified_flag,
                                                p_u_approved_flag                   => l_u_approved_flag,
                                                p_u_user_name_acted_on              => l_u_user_name_acted_on,
                                                p_u_action_taken                    => l_u_action_taken,
                                                p_i_user_name_routed_to             => l_i_user_name_routed_to,
                                                p_i_groupbox_id                     => l_i_groupbox_id,
                                                p_i_routing_list_id                 => l_i_routing_list_id,
                                                p_i_routing_seq_number              => l_i_routing_seq_number,
                                                p_u_prh_object_version_number       => l_u_prh_object_version_number,
                                                p_i_pa_routing_history_id           => l_i_pa_routing_history_id,
                                                p_i_prh_object_version_number       => l_i_prh_object_version_number,
                                                p_to_retention_allow_percentag      => l_retention_allow_percentage,
                                                p_to_supervisory_diff_percenta      => l_supervisory_diff_percentage,
                                                p_to_staffing_diff_percentage       => l_staffing_diff_percentage,
                                                p_award_percentage                  => l_award_percentage,
                                                -- FWFA Changes
                                                p_input_pay_rate_determinant        => l_pay_rate_determinant,
                                                p_from_pay_table_identifier         => l_pay_calc_out_rec_type.pay_table_id,
                                                p_to_pay_table_identifier           => l_pay_calc_out_rec_type.calculation_pay_table_id
                                                -- FWFA Changes
                                               );

                                          -- Create Remarks
                                          IF l_remark_id1 IS NOT NULL
                                          THEN
					    IF val_pa_remarks%isopen then
					       close val_pa_remarks;
					    END IF;

					    OPEN val_pa_remarks(p_pa_request_id => l_pa_request_id,
					                        p_remark_id     => l_remark_id1);
                                            FETCH val_pa_remarks into m_val_pa_remarks;
					    IF val_pa_remarks%NOTFOUND THEN
                                              ghr_pa_remarks_api.create_pa_remarks (
                                                    p_pa_request_id                 => l_pa_request_id,
                                                    p_remark_id                     => l_remark_id1,
                                                    p_description                   => l_remark_desc1,
                                                    p_remark_code_information1      => l_remark1_info1,
                                                    p_remark_code_information2      => l_remark1_info2,
                                                    p_remark_code_information3      => l_remark1_info3,
                                                    p_pa_remark_id                  => l_pa_remark_id,
                                                    p_object_version_number         => l_pre_object_version_number
                                                   );
					    END IF;
					    CLOSE val_pa_remarks;
                                          END IF;

                                          IF l_remark_id2 IS NOT NULL
                                          THEN
  					    IF val_pa_remarks%isopen then
					       close val_pa_remarks;
					    END IF;

					    OPEN val_pa_remarks(p_pa_request_id => l_pa_request_id,
					                        p_remark_id     => l_remark_id2);
                                            FETCH val_pa_remarks into m_val_pa_remarks;
					    IF val_pa_remarks%NOTFOUND THEN
                                             ghr_pa_remarks_api.create_pa_remarks (
                                                   p_pa_request_id                 => l_pa_request_id,
                                                   p_remark_id                     => l_remark_id2,
                                                   p_description                   => l_remark_desc2,
                                                   p_remark_code_information1      => l_remark2_info1,
                                                   p_remark_code_information2      => l_remark2_info2,
                                                   p_remark_code_information3      => l_remark2_info3,
                                                   p_pa_remark_id                  => l_pa_remark_id,
                                                   p_object_version_number         => l_pre_object_version_number
                                                  );
                                             END IF;
					     CLOSE val_pa_remarks;
                                          END IF;

                                          --
                                          COMMIT;

                                          --
                                          IF p_log_flag = 'Y'
                                          THEN
                                             create_ghr_errorlog (p_program_name      => l_proc,
                                                                  p_log_text          =>    'After update_sf52 for : '
                                                                                         || l_full_name
                                                                                         || ' Person ID : '
                                                                                         || TO_CHAR (l_person_id
                                                                                                    )
                                                                                         || ' l_retirement_plan : '
                                                                                         || l_retirement_plan,
                                                                  p_message_name      => NULL,
                                                                  p_log_date          => SYSDATE
                                                                 );
                                          END IF;

                                          --
                                          -- start the wgi workflow.
                                          --
                                          ghr_wf_wgi_pkg.startwgiprocess (p_pa_request_id      => l_pa_request_id,
                                                                          p_full_name          => l_full_name
                                                                         );
                                          create_ghr_errorlog (p_program_name      => l_proc,
                                                               p_log_text          =>    'Started Auto WGI Workflow process for : '
                                                                                      || l_full_name
                                                                                      || ' Person ID : '
                                                                                      || TO_CHAR (l_person_id
                                                                                                 )
                                                                                      || ' Assignment ID : '
                                                                                      || TO_CHAR (l_assignment_id
                                                                                                 )
                                                                                      || ' PA Request ID : '
                                                                                      || TO_CHAR (l_pa_request_id
                                                                                                 ),
                                                               p_message_name      => NULL,
                                                               p_log_date          => SYSDATE
                                                              );
                                          COMMIT;
                                          --
                                          -- reset the flag
                                          l_start_wgi_wf_flag := 'N';
                                       --
                                       END IF; -- if l_wgi_out_rec_type.process_person
                                    END IF; --if (check_pay_plan(p_pay_plan  =>  l_tmp_from_pay_plan))
                                 END IF;                -- IF person_in_pa_requests
                                         --END IF; --  IF check_assignment_prd
							  ELSE
									RAISE l_max_step_exception;
                              END IF; -- (IF checkIfMaxPayPlan)
                           END IF; -- IF (  p_effective_date  >= (l_wgi_pay_dat
					   ELSE -- Add for Bug 3035967 fix.
						  hr_utility.set_location('error in pay date',2500)	;
						  IF l_wgi_due_date IS NOT NULL THEN
							  -- Check if max step is reached. If it has, then ignore this employee
							  IF (checkifmaxpayplan (p_from_pay_plan          => l_from_pay_plan,
                                                     p_from_step_or_rate      => l_from_step_or_rate
                                                    )
                                 )
                              THEN
								  create_ghr_errorlog (p_program_name      => l_proc,
													   p_log_text          =>    'ERROR encountered in processing Auto WGI for : '
                                                      || l_full_name
                                                      || ' Error Message :'
                                                      || ' The employee does not have a WGI Pay Date.'
                                                      || ' Cause:  The employee does not have a WGI Pay Date in their Within Grade '
                                                      || ' Increase element entry.  The employee cannot be selected for a WGI without a '
                                                      || ' Pay Date. '
                                                      || ' Action:  You must enter a Pay Date in the employee''s Within Grade Increase '
                                                      || ' element entry. Person ID : '
                                                      || TO_CHAR (l_person_id
                                                                 )
                                                      || ' Assignment ID : '
                                                      || TO_CHAR (l_assignment_id
                                                                 )
                                                      || ' PA Request ID : '
                                                      || TO_CHAR (l_pa_request_id
                                                                 ),
													   p_message_name      => 'Pay Date not entered',
													   p_log_date          => SYSDATE
													  );
									l_retcode := 1;
									COMMIT;
								END IF; --  IF (checkifmaxpayplan if wgiduedate is not null
							END IF; -- IF l_wgi_due_date IS NULL
                        END IF; -- IF l_wgi_pay_date IS NOT NULL THEN
                  END IF; --  IF   ( CheckPayPlanParm
		 END IF; -- l_pay_rate_determinant <> 'Y'
/*End Bug:9255822*/
				 END IF; -- IF l_value IN ('1','2','3')
               END IF; -- IF l_assignment_id IS NOT NULL THEN
            END IF;      --- IF check_pay_plan(l_per_pay_plan)
                    --
                    -- log message and continue processing next record
                    --
		END IF; -- IF ( CheckPOIParm - Moved outside
         EXCEPTION
		 -- Bug 3649933 To raise error when group box does not exist.

		    WHEN l_no_groupbox_exception THEN
    			  hr_utility.set_location('error in group box',2500)	;
				create_ghr_errorlog (p_program_name      => l_proc,
                                    p_log_text          =>    'ERROR encountered in processing Auto WGI for : '
                                                           || l_full_name
                                                           || ' ** Error Message ** : '
                                                           || ' Group Box doesnt exist for Personnel Office ID for '
                                                           || ' Person ID : '
                                                           || TO_CHAR (l_person_id
                                                                      )
                                                           ,
                                    p_message_name      => 'No Group Box',
                                    p_log_date          => SYSDATE
                                   );
				l_retcode := 1;
			WHEN l_from_asg_exception THEN
   		    	  hr_utility.set_location('error in fetch from asg',2500)	;
				create_ghr_errorlog (p_program_name      => l_proc,
                                    p_log_text          =>    'ERROR encountered in processing Auto WGI for : '
                                                           || l_full_name
                                                           || ' ** Error Message ** : '
                                                           || ' Error in fetching values from Assignment for '
                                                           || ' Person ID : '
                                                           || TO_CHAR (l_person_id
                                                                      )
                                                           || ' Assignment ID : '
                                                           || TO_CHAR (l_assignment_id
                                                                      )
                                                           || ' PA Request ID : '
                                                           || TO_CHAR (l_pa_request_id
                                                                      ),
                                    p_message_name      => 'Fetch values from Assignment',
                                    p_log_date          => SYSDATE
                                   );

				l_retcode := 1;
			WHEN l_retained_grade_exception THEN
				hr_utility.set_location('error in l_retained_grade_exception',2500)	;
				create_ghr_errorlog (p_program_name      => l_proc,
                                    p_log_text          =>    'ERROR encountered in processing Auto WGI for : '
                                                           || l_full_name
                                                           || ' ** Error Message ** : '
                                                           || ' Error in getting Retained Grade details for '
                                                           || ' Person ID : '
                                                           || TO_CHAR (l_person_id
                                                                      )
                                                           || ' Assignment ID : '
                                                           || TO_CHAR (l_assignment_id
                                                                      )
                                                           || ' PA Request ID : '
                                                           || TO_CHAR (l_pa_request_id
                                                                      ),
                                    p_message_name      => 'Get Retained Grade details',
                                    p_log_date          => SYSDATE
                                   );

				l_retcode := 1;
			WHEN l_max_step_exception THEN
				hr_utility.set_location('error in l_retained_grade_exception',2500)	;
				create_ghr_errorlog (p_program_name      => l_proc,
				   p_log_text          =>    'ERROR encountered in processing Auto WGI for : '
										  || l_full_name
										  || ' Error Message :'
										  || ' The employee has reached Maximum Step assigned for the Pay plan'
										  || ' Person ID : '
										  || TO_CHAR (l_person_id
													 )
										  || ' Assignment ID : '
										  || TO_CHAR (l_assignment_id
													 )
										  || ' PA Request ID : '
										  || TO_CHAR (l_pa_request_id
													 ),
				   p_message_name      => 'Maximum Step Reached',
				   p_log_date          => SYSDATE
				  );
				l_retcode := 1;
            WHEN OTHERS
            THEN
	    --bug# 5685874 reassigning l_errbuf to null so that buffer overflow does not occur.
	       l_errbuf := NULL;

		hr_utility.set_location('error in OTHERS' || SQLCODE ,2500)	;
		 create_ghr_errorlog (p_program_name      => l_proc,
		    p_log_text          =>    'ERROR encountered in processing Auto WGI for : '
					   || l_full_name
					   || ' ** Error Message ** : '
					   || SUBSTR (SQLERRM,
						      1,
						      1000
						     )
					   || ' Person ID : '
					   || TO_CHAR (l_person_id
						      )
					   || ' Assignment ID : '
					   || TO_CHAR (l_assignment_id
						      )
					   || ' PA Request ID : '
					   || TO_CHAR (l_pa_request_id
						      ),
		    p_message_name      => to_char(SQLCODE),
		    p_log_date          => SYSDATE
		   );

               IF l_start_wgi_wf_flag = 'Y'
               THEN
                  ghr_wf_wgi_pkg.startwgiprocess (p_pa_request_id      => l_pa_request_id,
                                                  p_full_name          => l_full_name
                                                 );
                  create_ghr_errorlog (p_program_name      => l_proc,
                                       p_log_text          =>    'Started Auto WGI Workflow process for : '
                                                              || l_full_name
                                                              || ' Person ID : '
                                                              || TO_CHAR (l_person_id
                                                                         )
                                                              || ' Assignment ID : '
                                                              || TO_CHAR (l_assignment_id
                                                                         )
                                                              || ' PA Request ID : '
                                                              || TO_CHAR (l_pa_request_id
                                                                         ),
                                       p_message_name      => NULL,
                                       p_log_date          => SYSDATE
                                      );
                  COMMIT;
                  --
                  -- reset the flag
                  l_start_wgi_wf_flag := 'N';
               --
               ELSE
                  l_retcode := 1;



                  IF l_errbuf IS NULL
                  THEN
                     l_errbuf :=
                            'The following PA Request could not be processed : '
                         || l_full_name
                         || ' PA Request id : '
                         || TO_CHAR (l_pa_request_id);
                  ELSE
                     l_errbuf :=
                            l_errbuf
                         || ',  '
                         || TO_CHAR (l_person_id)
                         || ':'
                         || TO_CHAR (l_pa_request_id);
                  END IF;


               END IF;
         END;
      END LOOP;
      p_retcode := l_retcode;
      p_errbuf := l_errbuf;
--      hr_utility.trace_off;
      CLOSE per_assign_cursor;
   EXCEPTION
	  -- Bug 3649933 To raise error when group box does not exist.
      WHEN l_no_groupbox_exception THEN
		p_retcode := 2;
		p_errbuf := 'Group Box does not exist for this Personnel office id :' || l_in_personnel_office_id;
		--RAISE;
      WHEN OTHERS
      THEN
         p_errbuf := NULL;
         p_retcode := NULL;
         RAISE;
   END ghr_wgi_emp;

--
--
   PROCEDURE create_ghr_errorlog (
      p_program_name   IN   ghr_process_log.program_name%TYPE,
      p_log_text       IN   ghr_process_log.log_text%TYPE,
      p_message_name   IN   ghr_process_log.message_name%TYPE,
      p_log_date       IN   ghr_process_log.log_date%TYPE
   )
   IS
--
      l_message_name   ghr_process_log.message_name%TYPE;
   BEGIN
--
      l_message_name := NVL (p_message_name, 'Please see log text');

      INSERT INTO ghr_process_log
                  (process_log_id, program_name, log_text,
                   message_name, log_date
                  )
           VALUES (ghr_process_log_s.NEXTVAL, p_program_name, p_log_text,
                   l_message_name, p_log_date
                  );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END create_ghr_errorlog;

--
--
   PROCEDURE get_noa_code_desc (
      p_code                  IN              ghr_nature_of_actions.code%TYPE,
      p_effective_date        IN              DATE DEFAULT SYSDATE,
      p_nature_of_action_id   OUT NOCOPY      ghr_nature_of_actions.nature_of_action_id%TYPE,
      p_description           OUT NOCOPY      ghr_nature_of_actions.description%TYPE
   )
   IS
--
-- local variables
--
      l_effective_date        DATE;
      l_code                  ghr_nature_of_actions.code%TYPE;
      l_description           ghr_nature_of_actions.description%TYPE;
      l_nature_of_action_id   ghr_nature_of_actions.nature_of_action_id%TYPE;

--
      CURSOR csr_noa
      IS
         SELECT noa.nature_of_action_id, noa.description
           FROM ghr_nature_of_actions noa
          WHERE noa.code = l_code
            AND noa.enabled_flag = 'Y'
            AND NVL (l_effective_date, TRUNC (SYSDATE)) BETWEEN noa.date_from
                                                            AND NVL (noa.date_to,
                                                                     NVL (l_effective_date,
                                                                          TRUNC (SYSDATE
                                                                                )
                                                                         )
                                                                    );
--
   BEGIN
--
      l_code := p_code;

      IF (p_effective_date IS NOT NULL)
      THEN
         l_effective_date := p_effective_date;
      END IF;

      OPEN csr_noa;
      FETCH csr_noa INTO l_nature_of_action_id, l_description;

      IF csr_noa%NOTFOUND
      THEN
         -- if the cursor does not return a row then we must set the out
         -- parameter to null
         p_description := NULL;
         p_nature_of_action_id := NULL;
      ELSE
         p_description := l_description;
         p_nature_of_action_id := l_nature_of_action_id;
      END IF;

      -- close the cursor
      CLOSE csr_noa;
--
--
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
      WHEN OTHERS
      THEN
         p_nature_of_action_id := NULL;
         p_description := NULL;
         RAISE;
   END get_noa_code_desc;

--
--
   FUNCTION get_fnd_lookup_meaning (
      p_lookup_type      IN   hr_lookups.lookup_type%TYPE,
      p_lookup_code      IN   hr_lookups.lookup_code%TYPE,
      p_effective_date   IN   DATE DEFAULT SYSDATE
   )
      RETURN hr_lookups.meaning%TYPE
   IS
--
-- Local variables
-- This function returns description and not meaning as is used to fetch only type GHR_US_LEGAL_AUTHORITY
--
      l_effective_date   ghr_pa_requests.effective_date%TYPE;
      l_lookup_type      hr_lookups.lookup_type%TYPE;
      l_lookup_code      hr_lookups.lookup_code%TYPE;
      l_meaning          hr_lookups.meaning%TYPE;

--
--
      CURSOR csr_lkp_code
      IS
         SELECT fcl.description
           FROM hr_lookups fcl
          WHERE fcl.lookup_type = l_lookup_type
            AND fcl.lookup_code = l_lookup_code
            AND fcl.enabled_flag = 'Y'
            AND NVL (l_effective_date, TRUNC (SYSDATE))
                   BETWEEN NVL (fcl.start_date_active,
                                NVL (l_effective_date, TRUNC (SYSDATE))
                               )
                       AND NVL (fcl.end_date_active,
                                NVL (l_effective_date, TRUNC (SYSDATE))
                               );
--
   BEGIN
--
      l_lookup_type := p_lookup_type;
      l_lookup_code := p_lookup_code;

      IF p_effective_date IS NOT NULL
      THEN
         l_effective_date := p_effective_date;
      ELSE
         l_effective_date := SYSDATE;
      END IF;

      -- Open Lookup cursor
      OPEN csr_lkp_code;
      FETCH csr_lkp_code INTO l_meaning;

      IF csr_lkp_code%NOTFOUND
      THEN
         l_meaning := NULL;
      ELSE
         l_meaning := l_meaning;
      END IF;

      CLOSE csr_lkp_code;
      RETURN l_meaning;
--
   END get_fnd_lookup_meaning;

--
-- Check assignment id
--
   FUNCTION check_assignment_prd (
      p_pay_rate_determinant   IN   ghr_pa_requests.pay_rate_determinant%TYPE
   )
      RETURN BOOLEAN
   IS
--
   BEGIN
      IF p_pay_rate_determinant IN
                               ('0', '5', '6', '7', 'M', 'A', 'B', 'E', 'F')
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END check_assignment_prd;

--
-- Verify person in PA requests
--
   FUNCTION person_in_pa_requests (
      p_person_id        IN   ghr_pa_requests.person_id%TYPE,
      p_effective_date   IN   ghr_pa_requests.effective_date%TYPE,
      p_first_noa_code   IN   ghr_pa_requests.first_noa_code%TYPE,
      p_days             IN   NUMBER
   )
      RETURN BOOLEAN
   IS
--
      CURSOR csr_action_taken
      IS
         SELECT   pr.pa_request_id,
                  MAX (pa_routing_history_id) pa_routing_history_id
             FROM ghr_pa_requests pr, ghr_pa_routing_history prh
            WHERE pr.pa_request_id = prh.pa_request_id
              AND person_id = p_person_id
              AND (first_noa_code = p_first_noa_code OR first_noa_code = '888'
                  )
              AND effective_date >= (p_effective_date - p_days)
              AND NVL (pr.first_noa_cancel_or_correct, 'X') <>
                                                      ghr_history_api.g_cancel
-- vtakru Apr 17, 98 vtakru
-- and nvl(pr.first_noa_cancel_or_correct,'X') <> 'CANCELED'
         GROUP BY pr.pa_request_id;

      l_action_taken   ghr_pa_routing_history.action_taken%TYPE;
   BEGIN
      FOR v_action_taken IN csr_action_taken
      LOOP
         SELECT NVL (action_taken, ' ')
           INTO l_action_taken
           FROM ghr_pa_routing_history
          WHERE pa_routing_history_id = v_action_taken.pa_routing_history_id;

         IF l_action_taken <> 'CANCELED'
         THEN
            RETURN FALSE;
         END IF;
      END LOOP;

      RETURN TRUE;
   END person_in_pa_requests;

--
--
   FUNCTION check_pay_plan (p_pay_plan IN VARCHAR2)
      RETURN BOOLEAN
   IS
--
      l_exists     VARCHAR2 (1);
      l_pay_plan   VARCHAR2(200);

      CURSOR csr_pay_plan (p_pay_plan ghr_pay_plans.pay_plan%TYPE)
      IS
         SELECT 'X'
           FROM ghr_pay_plans
          WHERE pay_plan = l_pay_plan AND wgi_enabled_flag = 'Y';
--
   BEGIN
      l_pay_plan := p_pay_plan;
      OPEN csr_pay_plan (l_pay_plan);
      FETCH csr_pay_plan INTO l_exists;

      IF csr_pay_plan%NOTFOUND
      THEN
         CLOSE csr_pay_plan;
         RETURN FALSE;
      ELSE
         CLOSE csr_pay_plan;
         RETURN TRUE;
      END IF;
   END check_pay_plan;

--
--
--
--
-- Derive Legal Authority code and Remarks
--
   PROCEDURE derive_legal_auth_cd_remarks (
      p_first_noa_code            IN              ghr_pa_requests.first_noa_code%TYPE,
      p_pay_rate_determinant      IN              ghr_pa_requests.pay_rate_determinant%TYPE,
      p_from_pay_plan             IN              ghr_pa_requests.from_pay_plan%TYPE,
      p_grade_or_level            IN              ghr_pa_requests.from_grade_or_level%TYPE,
      p_step_or_rate              IN              ghr_pa_requests.from_step_or_rate%TYPE,
      p_retained_pay_plan         IN              ghr_pa_requests.from_pay_plan%TYPE
            DEFAULT NULL,
      p_retained_grade_or_level   IN              ghr_pa_requests.from_grade_or_level%TYPE
            DEFAULT NULL,
      p_retained_step_or_rate     IN              ghr_pa_requests.from_step_or_rate%TYPE
            DEFAULT NULL,
      -- Bug#5204589
      p_temp_step                 IN       ghr_pa_requests.from_step_or_rate%TYPE    default null,
      p_effective_date            IN              ghr_pa_requests.effective_date%TYPE,
      p_first_action_la_code1     IN OUT NOCOPY   ghr_pa_requests.first_action_la_code1%TYPE,
      p_first_action_la_desc1     IN OUT NOCOPY   ghr_pa_requests.first_action_la_desc1%TYPE,
      p_first_action_la_code2     IN OUT NOCOPY   ghr_pa_requests.first_action_la_code2%TYPE,
      p_first_action_la_desc2     IN OUT NOCOPY   ghr_pa_requests.first_action_la_desc2%TYPE,
      p_remark_id1                OUT NOCOPY      ghr_pa_remarks.remark_id%TYPE,
      p_remark_desc1              OUT NOCOPY      ghr_pa_remarks.description%TYPE,
      p_remark1_info1             OUT NOCOPY      ghr_pa_remarks.remark_code_information1%TYPE,
      p_remark1_info2             OUT NOCOPY      ghr_pa_remarks.remark_code_information2%TYPE,
      p_remark1_info3             OUT NOCOPY      ghr_pa_remarks.remark_code_information3%TYPE,
      p_remark_id2                OUT NOCOPY      ghr_pa_remarks.remark_id%TYPE,
      p_remark_desc2              OUT NOCOPY      ghr_pa_remarks.description%TYPE,
      p_remark2_info1             OUT NOCOPY      ghr_pa_remarks.remark_code_information1%TYPE,
      p_remark2_info2             OUT NOCOPY      ghr_pa_remarks.remark_code_information2%TYPE,
      p_remark2_info3             OUT NOCOPY      ghr_pa_remarks.remark_code_information3%TYPE
   )
   IS
      l_eq_pay_plan             ghr_pa_requests.from_pay_plan%TYPE;
      l_from_pay_plan           ghr_pa_requests.from_pay_plan%TYPE;
      l_remark_id1              ghr_remarks.remark_id%TYPE;
      l_remark_code1            ghr_remarks.code%TYPE                 := NULL;
      l_remark_desc1            ghr_pa_remarks.description%TYPE       := NULL;
      l_remark_desc1_out        ghr_pa_remarks.description%TYPE;
      l_remark_code2            ghr_remarks.code%TYPE                 := NULL;
      l_remark_desc2            ghr_pa_remarks.description%TYPE       := NULL;
      l_remark_desc2_out        ghr_pa_remarks.description%TYPE;
      l_remark1_ins1            VARCHAR2 (150)                        := NULL;
      l_remark1_ins2            VARCHAR2 (150)                        := NULL;
      l_remark1_ins3            VARCHAR2 (150)                        := NULL;
      l_remark2_ins1            VARCHAR2 (150)                        := NULL;
      l_remark2_ins2            VARCHAR2 (150)                        := NULL;
      l_remark2_ins3            VARCHAR2 (150)                        := NULL;
      l_first_action_la_code1   ghr_pa_requests.first_action_la_code1%TYPE;
      l_first_action_la_desc1   ghr_pa_requests.first_action_la_desc1%TYPE;
      l_first_action_la_code2   ghr_pa_requests.first_action_la_code2%TYPE;
      l_first_action_la_desc2   ghr_pa_requests.first_action_la_desc2%TYPE;

      CURSOR c_eq_pay_plan
      IS
         SELECT gpp.equivalent_pay_plan
           FROM ghr_pay_plans gpp
          WHERE gpp.pay_plan = l_from_pay_plan;
--
--
   BEGIN
      l_first_action_la_code1 := p_first_action_la_code1;
      l_first_action_la_desc1 := p_first_action_la_desc1;
      l_first_action_la_code2 := p_first_action_la_code2;
      l_first_action_la_desc2 := p_first_action_la_desc2;
      p_first_action_la_code1 := NULL;
      p_first_action_la_desc1 := NULL;
      p_first_action_la_code2 := NULL;
      p_first_action_la_desc2 := NULL;
      p_remark_id1 := NULL;
      p_remark_id2 := NULL;
      p_remark_desc1 := NULL;
      p_remark_desc2 := NULL;

      IF p_first_noa_code = '893'
      THEN
         IF p_pay_rate_determinant IN ('A', 'B', 'E', 'F') AND p_temp_step is NULL
         THEN
            -- GEt the equivalent pay plan for the  retained pay plan
            l_from_pay_plan := p_retained_pay_plan;

            FOR eq_pay_plan_rec IN c_eq_pay_plan
            LOOP
               l_eq_pay_plan := eq_pay_plan_rec.equivalent_pay_plan;
            END LOOP;

            IF l_eq_pay_plan = 'FW'
            THEN
               p_first_action_la_code1 := 'VUL';
               p_first_action_la_code2 := 'VLJ';
			   l_remark_code1 := 'P14'; -- Bug
               l_remark_code2 := 'X46';
               -- Bug# 5204589 Modified the variable from l_remark1_ins1 to l_remark2_ins1.
               l_remark2_ins1 := TO_CHAR (TO_NUMBER (p_retained_step_or_rate) + 1);
               l_remark2_ins1 := LPAD(l_remark2_ins1,2,0);
               l_remark2_ins2 :=
                       p_retained_pay_plan || '-'
                       || p_retained_grade_or_level;
            ELSIF l_eq_pay_plan = 'GS' AND l_from_pay_plan <> 'GG'
            THEN
               p_first_action_la_code1 := 'Q7M';
               p_first_action_la_code2 := 'VLJ';
               l_remark_code1 := 'P14';
               l_remark_code2 := 'X46';
               l_remark2_ins1 := TO_CHAR (TO_NUMBER (p_retained_step_or_rate) + 1);
               l_remark2_ins1 := LPAD(l_remark2_ins1,2,0);
               l_remark2_ins2 :=
                       p_retained_pay_plan || '-'
                       || p_retained_grade_or_level;
            ELSIF l_eq_pay_plan = 'GS' AND l_from_pay_plan = 'GG'
            THEN
               p_first_action_la_code1 := 'UAM';
               p_first_action_la_code2 := NULL;
               l_remark_code1 := 'X44';
               l_remark_code2 := NULL;
               l_remark1_ins1 :=
                             TO_CHAR (TO_NUMBER (p_retained_step_or_rate) + 1);
               l_remark1_ins1 := LPAD(l_remark1_ins1,2,0);
               l_remark1_ins2 :=
                       p_retained_pay_plan || '-'
                       || p_retained_grade_or_level;
            END IF;
         ELSE --IF p_pay_rate_determinant NOT IN ('A', 'B', 'E', 'F')   THEN
            l_from_pay_plan := p_from_pay_plan;

            -- GEt the equivalent pay plan for the from_pay_plan
            FOR eq_pay_plan_rec IN c_eq_pay_plan
            LOOP
               l_eq_pay_plan := eq_pay_plan_rec.equivalent_pay_plan;
            END LOOP;

            IF l_eq_pay_plan = 'FW'
            THEN
               p_first_action_la_code1 := 'VUL';
			        l_remark_code1 := 'P14'; -- Bug 5090440
------Added Z2P for GM pay plan as a part of GPPA Requirement
            ELSIF l_eq_pay_plan = 'GS' AND l_from_pay_plan = 'GM'
            THEN
               p_first_action_la_code1 := 'Z2P';
               l_remark_code1 := 'P14';
-----GPPA End
            ELSIF l_eq_pay_plan = 'GS'
            THEN
               p_first_action_la_code1 := 'Q7M';
               l_remark_code1 := 'P14';
            END IF;

            IF l_from_pay_plan = 'GG'
            THEN
               p_first_action_la_code1 := 'UAM';

               IF p_pay_rate_determinant IN
                                         ('J', 'K', 'R', 'S', 'U', 'V', '3')
               THEN
                  l_remark_code1 := 'X40';
               END IF;
            END IF;
         END IF; -- PRD

         IF p_pay_rate_determinant IN ('6', 'E', 'F')
         THEN
            IF l_remark_code1 IS NULL
            THEN
               l_remark_code1 := 'P05';
            ELSE
               l_remark_code2 := 'P05';
            END IF;
         END IF;
      END IF; -- 893;

-- If NOA code is 891
  -- not including the check for pay plan = 'GM' because the very fact that this is
  -- a 891 NOA implies that.

        IF  p_first_noa_code = '891' THEN
            IF p_pay_rate_determinant IN ('A', 'B', 'E', 'F') AND p_temp_step IS NULL THEN
                p_first_action_la_code1 := 'Z2P';
                p_first_action_la_code2 := 'VLJ';
                l_remark_code1 := 'P14';
                l_remark_code2 := 'X62';
                l_remark2_ins1 :=
                       p_retained_pay_plan || '-'
                   || p_retained_grade_or_level;
            ELSE
                 p_first_action_la_code1 := 'Z2P';
                 p_first_action_la_code2 := NULL;
                l_remark_code1 := 'P14';
            END IF;
        END IF;

        -- If NOA code is 888
        IF  p_first_noa_code = '888' THEN

            IF p_pay_rate_determinant IN ('A', 'B', 'E', 'F') AND p_temp_step IS NULL THEN

                IF p_from_pay_plan = 'GM' THEN
                    p_first_action_la_code1 := 'Z2P';
                 p_first_action_la_code2 := 'VLJ';
                 l_remark_code1 := 'P91';
                 l_remark_code2 := 'X63';
                 l_remark2_ins1 :=
                               p_retained_pay_plan || '-'
                               || p_retained_grade_or_level;
                ELSE
                   p_first_action_la_code1 := 'Q5M';
                   p_first_action_la_code2 := 'VLJ';
                   l_remark_code1 := 'P15';
                   l_remark1_ins1 := TO_CHAR (TO_NUMBER (p_retained_step_or_rate) + 1);
                   l_remark1_ins1 := LPAD(l_remark1_ins1,2,0);
                   l_remark1_ins2 := p_grade_or_level;
                   l_remark1_ins3 := p_step_or_rate; -- ?? Retained Step
                   l_remark_code2 := 'X47';
                   l_remark2_ins1 := TO_CHAR (TO_NUMBER (p_retained_step_or_rate) + 1);
                   l_remark2_ins1 := LPAD(l_remark2_ins1,2,0);
                END IF;

            ELSE

                IF p_from_pay_plan = 'GM' THEN
                    p_first_action_la_code1 := 'Z2P';
                    p_first_action_la_code2 := NULL;
                    l_remark_code1 := 'P91';
                ELSE
                    p_first_action_la_code1 := 'Q5M';
                    p_first_action_la_code2 := NULL;
                    l_remark_code1 := 'P15';
                    l_remark1_ins1 := TO_CHAR (TO_NUMBER (p_step_or_rate) + 1);
                    l_remark1_ins1 := LPAD(l_remark1_ins1,2,0);
                    l_remark1_ins2 := p_grade_or_level;
                    l_remark1_ins3 := p_step_or_rate;

                END IF;

            END IF;
        END IF;

      IF p_first_action_la_code1 IS NOT NULL
      THEN
         p_first_action_la_desc1 :=
            get_fnd_lookup_meaning (p_lookup_type         => 'GHR_US_LEGAL_AUTHORITY',
                                    p_lookup_code         => p_first_action_la_code1,
                                    p_effective_date      => p_effective_date
                                   );
      END IF;

      IF p_first_action_la_code2 IS NOT NULL
      THEN
         p_first_action_la_desc2 :=
            get_fnd_lookup_meaning (p_lookup_type         => 'GHR_US_LEGAL_AUTHORITY',
                                    p_lookup_code         => p_first_action_la_code2,
                                    p_effective_date      => p_effective_date
                                   );
      END IF;

      IF l_remark_code1 IS NOT NULL
      THEN
         ghr_mass_actions_pkg.get_remark_id_desc (p_remark_code         => l_remark_code1,
                                                  p_effective_date      => p_effective_date,
                                                  p_remark_id           => l_remark_id1,
                                                  p_remark_desc         => l_remark_desc1
                                                 );

         -- Insertion values.      ghr_mass_actions_pkg.replace_insertion_values
         IF    l_remark1_ins1 IS NOT NULL
            OR l_remark1_ins2 IS NOT NULL
            OR l_remark1_ins3 IS NOT NULL
         THEN
	    -- Bug#4256022 Passed the variable l_remark_desc1_out and assigned
	    -- the value back to l_remark_desc1 to avoid NOCOPY related problems.
            ghr_mass_actions_pkg.replace_insertion_values (p_desc              => l_remark_desc1,
                                                           p_information1      => l_remark1_ins1,
                                                           p_information2      => l_remark1_ins2,
                                                           p_information3      => l_remark1_ins3,
                                                           p_desc_out          => l_remark_desc1_out
                                                          );
            l_remark_desc1 := l_remark_desc1_out;
         END IF;
      END IF;

      IF l_remark_code2 IS NOT NULL
      THEN
         ghr_mass_actions_pkg.get_remark_id_desc (p_remark_code         => l_remark_code2,
                                                  p_effective_date      => p_effective_date,
                                                  p_remark_id           => p_remark_id2,
                                                  p_remark_desc         => l_remark_desc2
                                                 );

         -- Insertion values.      ghr_mass_actions_pkg.replace_insertion_values
         IF    l_remark2_ins1 IS NOT NULL
            OR l_remark2_ins2 IS NOT NULL
            OR l_remark2_ins3 IS NOT NULL
         THEN
	    -- Bug#4256022 Passed the variable l_remark_desc2_out and assigned
	    -- the value back to l_remark_desc2 to avoid NOCOPY related problems.
            ghr_mass_actions_pkg.replace_insertion_values (p_desc              => l_remark_desc2,
                                                           p_information1      => l_remark2_ins1,
                                                           p_information2      => l_remark2_ins2,
                                                           p_information3      => l_remark2_ins3,
                                                           p_desc_out          => l_remark_desc2_out
                                                          );
            l_remark_desc2 := l_remark_desc2_out;
         END IF;
      END IF;

      p_remark_id1 := l_remark_id1;
      p_remark_desc1 := l_remark_desc1;
      p_remark1_info1 := l_remark1_ins1;
      p_remark1_info2 := l_remark1_ins2;
      p_remark1_info3 := l_remark1_ins3;
      p_remark2_info1 := l_remark2_ins1;
      p_remark_desc2 := l_remark_desc2;
      p_remark2_info2 := l_remark2_ins2;
      p_remark2_info3 := l_remark2_ins3;
--
--
   EXCEPTION
      WHEN OTHERS
      THEN
         p_first_action_la_code1 := l_first_action_la_code1;
         p_first_action_la_desc1 := l_first_action_la_desc1;
         p_first_action_la_code2 := l_first_action_la_code2;
         p_first_action_la_desc2 := l_first_action_la_desc2;
         p_remark_id1 := NULL;
         p_remark_desc1 := NULL;
         p_remark1_info1 := NULL;
         p_remark1_info2 := NULL;
         p_remark1_info3 := NULL;
         p_remark_id2 := NULL;
         p_remark_desc2 := NULL;
         p_remark2_info1 := NULL;
         p_remark2_info2 := NULL;
         p_remark2_info3 := NULL;
         RAISE;
   END derive_legal_auth_cd_remarks;

--
--
--
   FUNCTION checkiffwpayplan (
      p_from_pay_plan   IN   ghr_pa_requests.from_pay_plan%TYPE
   )
      RETURN BOOLEAN
   IS
--
-- Local variables
      l_from_pay_plan   ghr_pa_requests.from_pay_plan%TYPE;

-- This function checks if the Pay plan is FW equivalent. If its the it returns TRUE otherwise FALSE
--
--
      CURSOR csr_chk_fw_pp
      IS
         SELECT pay_plan
           FROM ghr_pay_plans
          WHERE pay_plan = p_from_pay_plan AND equivalent_pay_plan = 'FW';
--
   BEGIN
--
      OPEN csr_chk_fw_pp;
      FETCH csr_chk_fw_pp INTO l_from_pay_plan;

      IF csr_chk_fw_pp%NOTFOUND
      THEN
         CLOSE csr_chk_fw_pp;
         RETURN FALSE;
      ELSE
         CLOSE csr_chk_fw_pp;
         RETURN TRUE;
      END IF;
--
--
   END checkiffwpayplan;

--
--
   FUNCTION checkpayplanparm (
      p_in_pay_plan     IN   ghr_pa_requests.from_pay_plan%TYPE,
      p_from_pay_plan   IN   ghr_pa_requests.from_pay_plan%TYPE
   )
      RETURN BOOLEAN
   IS
--
--
   BEGIN
--
      IF p_in_pay_plan IS NOT NULL
      THEN
         IF p_in_pay_plan = p_from_pay_plan
         THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      ELSE
         RETURN TRUE;
      END IF;
--
--
   END checkpayplanparm;

--
--
   FUNCTION checkpoiparm (
      p_in_personnel_office_id   IN  OUT NOCOPY ghr_pa_requests.personnel_office_id%TYPE,
      p_position_id              IN   per_assignments.position_id%TYPE,
      p_effective_date           IN   ghr_pa_requests.effective_date%TYPE
   )
      RETURN BOOLEAN
   IS
--
      l_flsa_category            ghr_pa_requests.flsa_category%TYPE;
      l_bargaining_unit_status   ghr_pa_requests.bargaining_unit_status%TYPE;
      l_work_schedule            ghr_pa_requests.work_schedule%TYPE;
      l_work_schedule_desc       ghr_pa_requests.work_schedule_desc%TYPE;
      l_functional_class         ghr_pa_requests.functional_class%TYPE;
      l_supervisory_status       ghr_pa_requests.supervisory_status%TYPE;
      l_position_occupied        ghr_pa_requests.position_occupied%TYPE;
      l_appropriation_code1      ghr_pa_requests.appropriation_code1%TYPE;
      l_appropriation_code2      ghr_pa_requests.appropriation_code2%TYPE;
      l_personnel_office_id      ghr_pa_requests.personnel_office_id%TYPE;
      l_from_office_symbol       ghr_pa_requests.from_office_symbol%TYPE;
      l_part_time_hours          ghr_pa_requests.part_time_hours%TYPE;
	  l_po_id ghr_pa_requests.personnel_office_id%TYPE;
--
--
   BEGIN
--
	  l_po_id := 	p_in_personnel_office_id;
      IF p_in_personnel_office_id IS NOT NULL
      THEN
         ghr_pa_requests_pkg.get_sf52_pos_ddf_details (p_position_id                 => p_position_id,
                                                       p_date_effective              => p_effective_date,
                                                       p_flsa_category               => l_flsa_category,
                                                       p_bargaining_unit_status      => l_bargaining_unit_status,
                                                       p_work_schedule               => l_work_schedule,
                                                       p_functional_class            => l_functional_class,
                                                       p_supervisory_status          => l_supervisory_status,
                                                       p_position_occupied           => l_position_occupied,
                                                       p_appropriation_code1         => l_appropriation_code1,
                                                       p_appropriation_code2         => l_appropriation_code2,
                                                       p_personnel_office_id         => l_personnel_office_id,
                                                       p_office_symbol               => l_from_office_symbol,
                                                       p_part_time_hours             => l_part_time_hours
                                                      );

         IF l_personnel_office_id = p_in_personnel_office_id
         THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      ELSE
		 ----------------Return PO ID also
		 ghr_pa_requests_pkg.get_sf52_pos_ddf_details (p_position_id                 => p_position_id,
                                                       p_date_effective              => p_effective_date,
                                                       p_flsa_category               => l_flsa_category,
                                                       p_bargaining_unit_status      => l_bargaining_unit_status,
                                                       p_work_schedule               => l_work_schedule,
                                                       p_functional_class            => l_functional_class,
                                                       p_supervisory_status          => l_supervisory_status,
                                                       p_position_occupied           => l_position_occupied,
                                                       p_appropriation_code1         => l_appropriation_code1,
                                                       p_appropriation_code2         => l_appropriation_code2,
                                                       p_personnel_office_id         => l_personnel_office_id,
                                                       p_office_symbol               => l_from_office_symbol,
                                                       p_part_time_hours             => l_part_time_hours
                                                      );
			p_in_personnel_office_id := l_personnel_office_id;
		 ----------------
         RETURN TRUE;
      END IF;
--
--
   EXCEPTION
		WHEN OTHERS THEN
			p_in_personnel_office_id := l_po_id;
   END checkpoiparm;

--
--
   FUNCTION checkifmaxpayplan (
      p_from_pay_plan       IN   ghr_pa_requests.from_pay_plan%TYPE,
      p_from_step_or_rate   IN   ghr_pa_requests.from_step_or_rate%TYPE
   )
      RETURN BOOLEAN
   IS
--
-- Local variables
      l_from_pay_plan   ghr_pa_requests.from_pay_plan%TYPE;
      l_maximum_step    ghr_pay_plans.maximum_step%TYPE;

--
-- This function checks if the Pay plan is FW equivalent. If its the it returns TRUE otherwise FALSE
--
--
      CURSOR csr_chk_max_pp
      IS
         SELECT maximum_step
           FROM ghr_pay_plans
          WHERE pay_plan = l_from_pay_plan;
--
   BEGIN
--
      IF p_from_pay_plan IN ('GM','GR') --Bug# 6603968
      THEN
         l_from_pay_plan := 'GS';
      ELSE
         l_from_pay_plan := p_from_pay_plan;
      END IF;

      OPEN csr_chk_max_pp;
      FETCH csr_chk_max_pp INTO l_maximum_step;

      IF csr_chk_max_pp%NOTFOUND
      THEN
         CLOSE csr_chk_max_pp;
         RETURN FALSE;
      ELSE
         IF (TO_NUMBER (p_from_step_or_rate) <= (l_maximum_step - 1))
         THEN
            CLOSE csr_chk_max_pp;
            RETURN TRUE;
         END IF;
      END IF;

      RETURN FALSE;
--
--
   END checkifmaxpayplan;
--
--
FUNCTION ret_wgi_pay_date (
	   p_assignment_id   IN   per_all_assignments_f.assignment_id%type,
	   p_effective_date    IN   per_all_assignments_f.effective_start_date%type,
	   p_frequency             IN              NUMBER
	)
RETURN VARCHAR2
IS
   l_value                 VARCHAR2(30);
   l_multiple_error_flag   BOOLEAN;
   l_wgi_pay_date          DATE;
   p_ret_value             VARCHAR2(30);
BEGIN
--
   l_value := NULL;
   p_ret_value := NULL;

	   BEGIN
		ghr_api.retrieve_element_entry_value
				     (p_element_name          => 'Within Grade Increase',
				      p_input_value_name         => 'Pay Date',
				      p_assignment_id            => p_assignment_id,
				      p_effective_date           => p_effective_date,
				      p_value                    => l_value,
				      p_multiple_error_flag      => l_multiple_error_flag
				     );
	   EXCEPTION
		WHEN OTHERS THEN
		        l_value := NULL;
			p_ret_value := NULL;
	   END;

	   IF l_value IS NOT NULL THEN
		 l_wgi_pay_date := fnd_date.canonical_to_date (l_value);
		 IF (p_effective_date >= (l_wgi_pay_date - p_frequency)) THEN
			 p_ret_value := l_value;
		 END IF;
	   END IF;

    RETURN p_ret_value;

  END ret_wgi_pay_date;

END ghr_wgi_pkg;

/
