--------------------------------------------------------
--  DDL for Package Body PAY_SE_SLSA_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_SLSA_ARCHIVE" AS
   /* $Header: pyseslsa.pkb 120.1.12010000.2 2009/04/14 06:04:00 rrajaman ship $ */
   g_debug               BOOLEAN       := hr_utility.debug_enabled;
   g_package             VARCHAR2 (33) := 'PAY_SE_SLSA_ARCHIVE.';
   g_payroll_action_id   NUMBER;
   -- Globals to pick up all the parameter
   g_business_group_id   NUMBER;
   g_effective_date      DATE;
   g_legal_employer_id   NUMBER;
   g_local_unit_id       NUMBER;
   g_request_for         VARCHAR2 (20);
   g_start_date          DATE;
   g_end_date            DATE;
   g_lower_age_group     NUMBER        := 29;
   -- g_middle_start_age_group   NUMBER        := 30;
   -- g_middle_end_age_group     NUMBER        := 49;
   g_upper_age_group     NUMBER        := 50;
   g_no_of_long_leave    NUMBER        := 60;
   /*
1. Lower Age Group  -  29 and below
2. Middle Age Group -  Between 30 and 49
3. Upper Age Group  -  50 and Above */

   --End of Globals to pick up all the parameter

   /* GET PARAMETER */
   FUNCTION get_parameter (
      p_parameter_string   IN   VARCHAR2,
      p_token              IN   VARCHAR2,
      p_segment_number     IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2 IS
      l_parameter   pay_payroll_actions.legislative_parameters%TYPE   := NULL;
      l_start_pos   NUMBER;
      l_delimiter   VARCHAR2 (1)                                      := ' ';
      l_proc        VARCHAR2 (40)                                     := g_package || ' get parameter ';
   BEGIN
      --
      IF g_debug THEN
         hr_utility.set_location (' Entering Function GET_PARAMETER', 10);
      END IF;

      l_start_pos := instr (' ' || p_parameter_string, l_delimiter || p_token || '=');

      --
      IF l_start_pos = 0 THEN
         l_delimiter := '|';
         l_start_pos := instr (' ' || p_parameter_string, l_delimiter || p_token || '=');
      END IF;

      IF l_start_pos <> 0 THEN
         l_start_pos := l_start_pos + LENGTH (p_token || '=');
         l_parameter := substr (
                           p_parameter_string,
                           l_start_pos,
                           instr (p_parameter_string || ' ', l_delimiter, l_start_pos) - (l_start_pos)
                        );

         IF p_segment_number IS NOT NULL THEN
            l_parameter := ':' || l_parameter || ':';
            l_parameter := substr (
                              l_parameter,
                              instr (l_parameter, ':', 1, p_segment_number) + 1,
                              instr (l_parameter, ':', 1, p_segment_number + 1) - 1
                              - instr (l_parameter, ':', 1, p_segment_number)
                           );
         END IF;
      END IF;

      --
      IF g_debug THEN
         hr_utility.set_location (' Leaving Function GET_PARAMETER', 20);
      END IF;

      RETURN l_parameter;
   END;
   /* GET ALL PARAMETERS */
   PROCEDURE get_all_parameters (
      p_payroll_action_id        IN              NUMBER -- In parameter
                                                       ,
      p_business_group_id        OUT NOCOPY      NUMBER -- Core parameter
                                                       ,
      p_effective_date           OUT NOCOPY      DATE -- Core parameter
                                                     ,
      p_legal_employer_id        OUT NOCOPY      NUMBER -- User parameter
                                                       ,
      p_request_for_all_or_not   OUT NOCOPY      VARCHAR2 -- User parameter
                                                         ,
      p_start_date               OUT NOCOPY      DATE -- User parameter
                                                     ,
      p_end_date                 OUT NOCOPY      DATE -- User parameter
   ) IS
      CURSOR csr_parameter_info (
         p_payroll_action_id   NUMBER
      ) IS
         SELECT to_number (
                   substr (
                      pay_se_slsa_archive.get_parameter (legislative_parameters, 'LEGAL_EMPLOYER'),
                      1,
                      LENGTH (pay_se_slsa_archive.get_parameter (legislative_parameters, 'LEGAL_EMPLOYER')) - 1
                   )
                ) legal,
                substr (
                   pay_se_slsa_archive.get_parameter (legislative_parameters, 'REQUEST_FOR'),
                   1,
                   LENGTH (pay_se_slsa_archive.get_parameter (legislative_parameters, 'REQUEST_FOR')) - 1
                ) request_for,
                (pay_se_slsa_archive.get_parameter (legislative_parameters, 'EFFECTIVE_START_DATE')) eff_start_date,
                (pay_se_slsa_archive.get_parameter (legislative_parameters, 'EFFECTIVE_END_DATE'))
                      eff_end_date,
                effective_date effective_date, business_group_id bg_id
         FROM   pay_payroll_actions
         WHERE payroll_action_id = p_payroll_action_id;

      lr_parameter_info   csr_parameter_info%ROWTYPE;
      l_proc              VARCHAR2 (240)               := g_package || ' GET_ALL_PARAMETERS ';
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'Entering Procedure GET_ALL_PARAMETER ');
      OPEN csr_parameter_info (p_payroll_action_id);
      --FETCH csr_parameter_info into lr_parameter_info;
      FETCH csr_parameter_info INTO lr_parameter_info;
      CLOSE csr_parameter_info;
      p_legal_employer_id := lr_parameter_info.legal;
      p_request_for_all_or_not := lr_parameter_info.request_for;
      p_start_date := fnd_date.canonical_to_date (lr_parameter_info.eff_start_date);
      p_end_date := fnd_date.canonical_to_date (lr_parameter_info.eff_end_date);
      p_effective_date := lr_parameter_info.effective_date;
      p_business_group_id := lr_parameter_info.bg_id;

      IF g_debug THEN
         hr_utility.set_location (' Leaving Procedure GET_ALL_PARAMETERS', 30);
      END IF;
   END get_all_parameters;
   /* procedure to get the working hours and day for the business group */
   PROCEDURE get_schedule_duration (
      p_start_date      IN              DATE,
      p_end_date        IN              DATE,
      p_days_or_hours   IN              VARCHAR2,
      p_duration        IN OUT NOCOPY   NUMBER
   ) IS
      --  l_schedule_source VARCHAR2(10);
      l_schedule          cac_avlblty_time_varray;
      l_msg_count         NUMBER;
      l_return            NUMBER;
      l_idx               NUMBER;
      l_ref_date          DATE;
      l_first_band        BOOLEAN;
      l_day_start_time    VARCHAR2 (5);
      l_day_end_time      VARCHAR2 (5);
      l_start_time        VARCHAR2 (5);
      l_end_time          VARCHAR2 (5);
      --
      l_start_date        DATE;
      l_end_date          DATE;
      --l_schedule        cac_avlblty_time_varray;
      l_schedule_source   VARCHAR2 (10);
      l_return_status     VARCHAR2 (1);
      l_return_message    VARCHAR2 (2000);
      --
      l_time_start        VARCHAR2 (10);
      l_time_end          VARCHAR2 (10);
      --
      e_bad_time_format   EXCEPTION;
   BEGIN
      cac_avlblty_pub.get_schedule (
         p_api_version            => 1.0,
         p_init_msg_list          => 'F',
         p_object_type            => 'BUSINESS_GROUP',
         p_object_id              => g_business_group_id,
         p_start_date_time        => p_start_date,
         p_end_date_time          => p_end_date,
         p_schedule_category      => NULL,
         p_include_exception      => 'Y',
         p_busy_tentative         => 'FREE',
         x_schedule               => l_schedule,
         x_return_status          => l_return_status,
         x_msg_count              => l_msg_count,
         x_msg_data               => l_return_message
      );

      IF l_return_status = 'S' THEN
         l_idx := l_schedule.FIRST;

         IF p_days_or_hours = 'D' THEN
            --
            l_first_band := TRUE ;
            l_ref_date := NULL;

            WHILE l_idx IS NOT NULL
            LOOP
               -- l_schedule(l_idx).FREE_BUSY_TYPE := 'FREE' ;
               IF l_schedule (l_idx).free_busy_type IS NOT NULL THEN
                  IF l_schedule (l_idx).free_busy_type = 'FREE' THEN
                     --   dbms_output.put_line('Inside FREE_BUSY_TYPE' ||l_schedule(l_idx).FREE_BUSY_TYPE  ) ;
                     IF l_first_band THEN
                        l_first_band := FALSE ;
                        l_ref_date := trunc (l_schedule (l_idx).start_date_time);
                        hr_utility.set_location ('start date time ' || l_schedule (l_idx).start_date_time, 20);
                        hr_utility.set_location ('end date time ' || l_schedule (l_idx).end_date_time, 20);

                        IF (trunc (l_schedule (l_idx).end_date_time) = trunc (l_schedule (l_idx).start_date_time)) THEN
                           p_duration := p_duration
                                         + (trunc (l_schedule (l_idx).end_date_time)
                                            - trunc (l_schedule (l_idx).start_date_time) + 1
                                           );
                        ELSE
                           p_duration := p_duration
                                         + (trunc (l_schedule (l_idx).end_date_time)
                                            - trunc (l_schedule (l_idx).start_date_time)
                                           );
                        END IF;
                     ELSE -- not first time
                        IF trunc (l_schedule (l_idx).start_date_time) = l_ref_date THEN
                           p_duration := p_duration
                                         + (trunc (l_schedule (l_idx).end_date_time)
                                            - trunc (l_schedule (l_idx).start_date_time)
                                           );
                        ELSE
                           l_ref_date := trunc (l_schedule (l_idx).end_date_time);

                           IF (trunc (l_schedule (l_idx).end_date_time) = trunc (l_schedule (l_idx).start_date_time)) THEN
                              p_duration := p_duration
                                            + (trunc (l_schedule (l_idx).end_date_time)
                                               - trunc (l_schedule (l_idx).start_date_time) + 1
                                              );
                           ELSE
                              p_duration := p_duration
                                            + (trunc (l_schedule (l_idx).end_date_time)
                                               - trunc (l_schedule (l_idx).start_date_time)
                                              );
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               l_idx := l_schedule (l_idx).next_object_index;
            END LOOP;
         --
         ELSE -- p_days_or_hours is 'H'
            --
            l_day_start_time := '00:00';
            l_day_end_time := '23:59';

            WHILE l_idx IS NOT NULL
            LOOP
               IF l_schedule (l_idx).free_busy_type IS NOT NULL THEN
                  IF l_schedule (l_idx).free_busy_type = 'FREE' THEN
                     IF l_schedule (l_idx).end_date_time < l_schedule (l_idx).start_date_time THEN
                        -- Skip this invalid slot which ends before it starts
                        NULL;
                     ELSE
                        IF trunc (l_schedule (l_idx).end_date_time) > trunc (l_schedule (l_idx).start_date_time) THEN
                           -- Start and End on different days
                           --
                           -- Get first day hours
                           l_start_time := to_char (l_schedule (l_idx).start_date_time, 'HH24:MI');

                           SELECT p_duration
                                  + (((substr (l_day_end_time, 1, 2) * 60 + substr (l_day_end_time, 4, 2))
                                      - (substr (l_start_time, 1, 2) * 60 + substr (l_start_time, 4, 2))
                                     )
                                     / 60
                                    )
                           INTO  p_duration
                           FROM   dual;

                           --
                           -- Get last day hours
                           l_end_time := to_char (l_schedule (l_idx).end_date_time, 'HH24:MI');

                           SELECT p_duration
                                  + (((substr (l_end_time, 1, 2) * 60 + substr (l_end_time, 4, 2))
                                      - (substr (l_day_start_time, 1, 2) * 60 + substr (l_day_start_time, 4, 2)) + 1
                                     )
                                     / 60
                                    )
                           INTO  p_duration
                           FROM   dual;

                           --
                           -- Get between full day hours
                           SELECT p_duration
                                  + ((trunc (l_schedule (l_idx).end_date_time) - trunc (l_schedule (l_idx).start_date_time) - 1)
                                     * 24
                                    )
                           INTO  p_duration
                           FROM   dual;
                        ELSE
                           -- Start and End on same day
                           l_start_time := to_char (l_schedule (l_idx).start_date_time, 'HH24:MI');
                           l_end_time := to_char (l_schedule (l_idx).end_date_time, 'HH24:MI');

                           SELECT p_duration
                                  + (((substr (l_end_time, 1, 2) * 60 + substr (l_end_time, 4, 2))
                                      - (substr (l_start_time, 1, 2) * 60 + substr (l_start_time, 4, 2))
                                     )
                                     / 60
                                    )
                           INTO  p_duration
                           FROM   dual;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               l_idx := l_schedule (l_idx).next_object_index;
            END LOOP;

            p_duration := round (p_duration, 2);
         --
         END IF;
      END IF;
   END;
   /* RANGE CODE */
   PROCEDURE range_code (
      p_payroll_action_id   IN              NUMBER,
      p_sql                 OUT NOCOPY      VARCHAR2
   ) IS
      l_action_info_id           NUMBER;
      l_ovn                      NUMBER;
      l_business_group_id        NUMBER;
      l_effective_date           DATE;
      l_current_start_date       DATE;
      l_current_end_date         DATE;
      l_previous_start_date      DATE;
      l_previous_end_date        DATE;

      -- Archiving the data , as this will fire once
      CURSOR csr_legal_employer_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE
      ) IS
         SELECT o1.NAME legal_employer_name, hoi2.org_information2 org_number, hoi1.organization_id legal_id
         FROM   hr_organization_units o1, hr_organization_information hoi1, hr_organization_information hoi2
         WHERE o1.business_group_id = g_business_group_id
         AND   hoi1.organization_id = o1.organization_id
         AND   hoi1.organization_id = nvl (csr_v_legal_employer_id, hoi1.organization_id)
         AND   hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
         AND   hoi1.org_information_context = 'CLASS'
         AND   o1.organization_id = hoi2.organization_id
         AND   hoi2.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS';

      l_legal_employer_details   csr_legal_employer_details%ROWTYPE;
      /* Procedure to get the employee data */
      PROCEDURE get_employee_data (
         p_legal_employer_id      hr_organization_information.organization_id%TYPE,
         p_effective_start_date   DATE,
         p_effective_end_date     DATE,
         p_curr_prev_flag         VARCHAR2 -- 'C' for current year and 'P' for Previous Year
      ) IS
         CURSOR csr_get_employee_detail (
            p_legal_employer_id      hr_organization_information.organization_id%TYPE,
            p_effective_start_date   DATE,
            p_effective_end_date     DATE
         ) IS
            SELECT papf.person_id, paaf.assignment_id, papf.date_of_birth, papf.sex, nvl (hsc.segment9, 100) work_percentage
            FROM   per_all_people_f papf,
                   per_all_assignments_f paaf,
                   hr_soft_coding_keyflex hsc,
                   per_assignment_status_types past,
                   hr_organization_information hoi,
                   per_person_types ppt,
                   per_all_people_f papfs,
                   per_all_assignments_f paafs
            WHERE paaf.person_id = papf.person_id
            AND   paaf.business_group_id = papf.business_group_id
            AND   hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
            AND   hsc.segment2 = hoi.org_information1
            AND   hoi.organization_id = p_legal_employer_id
            AND   ppt.system_person_type LIKE 'EMP%'
            AND   ppt.person_type_id = papf.person_type_id
            AND   paaf.assignment_status_type_id = past.assignment_status_type_id
            AND   past.per_system_status = 'ACTIVE_ASSIGN'
            AND   paaf.primary_flag = 'Y'
            AND   paaf.assignment_id = paafs.assignment_id
            AND   papf.person_id = papfs.person_id
            AND   p_effective_end_date BETWEEN papfs.effective_start_date AND papfs.effective_end_date
            AND   p_effective_end_date BETWEEN papf.effective_start_date AND papf.effective_end_date
	    AND   p_effective_end_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
            AND   p_effective_end_date BETWEEN paafs.effective_start_date AND paafs.effective_end_date;

         CURSOR csr_legal_employer_details (
            csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE
         ) IS
            SELECT o1.NAME legal_employer_name, hoi2.org_information2 org_number, hoi1.organization_id legal_id
            FROM   hr_organization_units o1, hr_organization_information hoi1, hr_organization_information hoi2
            WHERE o1.business_group_id = g_business_group_id
            AND   hoi1.organization_id = o1.organization_id
            AND   hoi1.organization_id = nvl (csr_v_legal_employer_id, hoi1.organization_id)
            AND   hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND   hoi1.org_information_context = 'CLASS'
            AND   o1.organization_id = hoi2.organization_id
            AND   hoi2.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS';

         /* Cursor to get the standard work details from the 'Standard Work Details' EIT */
         CURSOR csr_get_std_work_details (
            p_legal_employer_id   hr_organization_information.organization_id%TYPE,
            p_year                hr_organization_information.org_information1%TYPE
         ) IS
            SELECT org_information2 weekly_working_hours, org_information3 daily_working_hours,
                   org_information4
                         days_per_year, org_information5 hours_per_year
            FROM   hr_organization_information
            WHERE organization_id = p_legal_employer_id
            AND   org_information_context = 'SE_STD_WORK_DETAILS'
            AND   org_information1 = p_year;

         /* Cursor to get the defined balance id */
         CURSOR csr_get_defined_balance_id (
            csr_v_balance_name   ff_database_items.user_name%TYPE
         ) IS
            SELECT defined_balance_id
            FROM   pay_balance_types pbt, pay_balance_dimensions pbd, pay_defined_balances pdb
            WHERE pbt.balance_name = csr_v_balance_name
            AND   nvl (pbt.business_group_id, g_business_group_id) = g_business_group_id
            AND   pbt.balance_type_id = pdb.balance_type_id
            AND   pbd.database_item_suffix = '_ASG_YTD'
            AND   pbd.legislation_code = 'SE'
            AND   pbd.balance_dimension_id = pdb.balance_dimension_id;

         CURSOR csr_element_type (
            p_element_name      VARCHAR2,
            p_report_end_date   DATE
         ) IS
            SELECT element_type_id
            FROM   pay_element_types_f
            WHERE element_name = p_element_name
            AND   legislation_code = 'SE'
            AND   business_group_id IS NULL
            AND   p_report_end_date BETWEEN effective_start_date AND effective_end_date;

         CURSOR csr_input_values (
            p_element_type_id   NUMBER,
            p_report_end_date   DATE,
            p_input_value       VARCHAR2
         ) IS
            SELECT input_value_id
            FROM   pay_input_values_f
            WHERE element_type_id = p_element_type_id
            AND   p_report_end_date BETWEEN effective_start_date AND effective_end_date
            AND   NAME = p_input_value
            AND   legislation_code = 'SE'
            AND   business_group_id IS NULL;

         /* This cursor is used to take start date for each of the sickness group */
         CURSOR csr_group_start_date (
            p_element_type_id     NUMBER,
            p_assignment_id       NUMBER,
            p_report_start_date   DATE,
            p_report_end_date     DATE,
            p_input_value_id      NUMBER
         ) IS
            SELECT   prrv.result_value start_date
            FROM     pay_assignment_actions paa, pay_payroll_actions ppa, pay_run_results prr, pay_run_result_values prrv
            WHERE ppa.effective_date BETWEEN p_report_start_date AND p_report_end_date
            AND   ppa.payroll_action_id = paa.payroll_action_id
            AND   paa.assignment_id = p_assignment_id
            AND   paa.assignment_action_id = prr.assignment_action_id
            AND   prr.element_type_id = p_element_type_id
            AND   prr.run_result_id = prrv.run_result_id
            AND   prrv.input_value_id = p_input_value_id
            GROUP BY result_value;

        CURSOR csr_get_input_value (
            p_group_start_date   VARCHAR2,
            p_input_value_id     NUMBER,
	    p_assignment_id      NUMBER,
	    p_report_start_date   DATE,
            p_report_end_date     DATE

         ) IS
            SELECT sum (fnd_number.canonical_to_number (result_value))
            FROM   pay_run_result_values prrv
            WHERE input_value_id = p_input_value_id
	    AND run_result_id IN    (SELECT prr.run_result_id
                                    FROM  pay_assignment_actions paa, pay_payroll_actions ppa,pay_run_result_values prrv1,
					  pay_run_results prr
                                    WHERE ppa.effective_date BETWEEN p_report_start_date AND p_report_end_date
				    AND   ppa.payroll_action_id = paa.payroll_action_id
				    AND  paa.assignment_id = p_assignment_id
                                    and paa.assignment_action_id = prr.assignment_action_id
                                    and prr.run_result_id = prrv1.run_result_id
                                    and prrv1.result_value = p_group_start_date
                                      ) ;


         l_def_bal_id_hours             NUMBER;
         l_def_bal_id_days              NUMBER;
         l_get_def_bal_id_till_14       NUMBER;
         l_get_def_bal_id_after_14      NUMBER;
         l_current_year                 VARCHAR2 (4);
         l_legal_employer_details       csr_legal_employer_details%ROWTYPE;
         l_le_has_employee              VARCHAR2 (2);
         l_curr_prev_data               VARCHAR2 (30); -- 'LE_CURR_YR_DATA' for current year and 'LE_PREV_YR_DATA' for previous year
         l_curr_prev_stat               VARCHAR2 (30); -- 'LE_CURR_YR_STAT' for current year and 'LE_PREV_YR_STAT' for previous year
         l_curr_prev_std_hour           VARCHAR2 (30); -- 'LE_CURR_YR_STD_HOUR' for current year and 'LE_PREV_YR_STD_HOUR' for previous year
         l_long_sick_leave_flag         CHAR (1); -- 'L' - for long leave and 'N' for Normal leave
         l_men_lower_age_count          NUMBER                                     := 0; -- No of men employees for lower age group
         l_men_middle_age_count         NUMBER                                     := 0; -- No of men employees for middle age group
         l_men_upper_age_count          NUMBER                                     := 0; -- No of men employees for upper age group
         l_women_lower_age_count        NUMBER                                     := 0; -- No of women employees for lower age group
         l_women_middle_age_count       NUMBER                                     := 0; -- No of women employees for middle age group
         l_women_upper_age_count        NUMBER                                     := 0; -- No of women employees for upper age group
         l_men_lower_age_work_hour      NUMBER                                     := 0; -- No of men employees hours for lower age group
         l_men_middle_age_work_hour     NUMBER                                     := 0; -- No of men employees hours for middle age group
         l_men_upper_age_work_hour      NUMBER                                     := 0; -- No of men employees hours for upper age group
         l_women_lower_age_work_hour    NUMBER                                     := 0; -- No of women employees hours for lower age group
         l_women_middle_age_work_hour   NUMBER                                     := 0; -- No of women employees hours for middle age group
         l_women_upper_age_work_hour    NUMBER                                     := 0; -- No of women employees hours for upper age group
         l_men_l_age_sick_leaves        NUMBER                                     := 0; -- No Sick leaves for men employees for lower age group
         l_men_m_age_sick_leaves        NUMBER                                     := 0; -- No Sick leaves for men employees for middle age group
         l_men_u_age_sick_leaves        NUMBER                                     := 0; -- No Sick leaves for men employees for upper age group
         l_women_l_age_sick_leaves      NUMBER                                     := 0; -- No Sick leaves for women employees for lower age group
         l_women_m_age_sick_leaves      NUMBER                                     := 0; -- No Sick leaves for women employees for middle age group
         l_women_u_age_sick_leaves      NUMBER                                     := 0; -- No Sick leaves for women employees for upper age group
         l_men_l_age_l_sick_leaves      NUMBER                                     := 0; -- No Long Sick leaves for men employees for lower age group
         l_men_m_age_l_sick_leaves      NUMBER                                     := 0; -- No Long Sick leaves for men employees for middle age group
         l_men_u_age_l_sick_leaves      NUMBER                                     := 0; -- No Long Sick leaves for men employees for upper age group
         l_women_l_age_l_sick_leaves    NUMBER                                     := 0; -- No Long Sick leaves for women employees for lower age group
         l_women_m_age_l_sick_leaves    NUMBER                                     := 0; -- No Long Sick leaves for women employees for middle age group
         l_women_u_age_l_sick_leaves    NUMBER                                     := 0; -- No Long Sick leaves for women employees for upper age group
         l_curr_week_hours              NUMBER; -- No of weekly working hours for the current year
         l_curr_daily_hours             NUMBER; -- NO of daily working hours  for the current year
         l_curr_days_per_year           NUMBER; -- No of day per year for the current year
         l_curr_hours_per_year          NUMBER; -- No of working hours for the current year
         l_current_age                  NUMBER;
         l_emp_gender                   VARCHAR2 (2);
         /* l_emp_gender :-
   1. ML - Male Small Age Group
   2. MM - Male Middle Age Group
   3. MU - Male Upper  Age Group
   4. WL - Female Small Age Group
   5. WM - Female Middle Age Group
   6. WU - Female Upper Age Group */
         l_emp_work_hours               NUMBER;
         l_emp_sick_hours               NUMBER;
         l_total_sick_days              NUMBER;
         l_org_tot_men_work_hours       NUMBER                                     := 0;
         l_org_tot_women_work_hours     NUMBER                                     := 0;
         l_org_total_work_hours         NUMBER                                     := 0;
         l_org_tot_men_sick_hours       NUMBER                                     := 0;
         l_org_tot_women_sick_hours     NUMBER                                     := 0;
         l_org_total_sick_hours         NUMBER                                     := 0;
         l_org_total_l_sick_hours       NUMBER                                     := 0;
         l_org_tot_l_age_work_hours     NUMBER                                     := 0;
         l_org_tot_m_age_work_hours     NUMBER                                     := 0;
         l_org_tot_u_age_work_hours     NUMBER                                     := 0;
         l_org_tot_l_age_sick_hours     NUMBER                                     := 0;
         l_org_tot_m_age_sick_hours     NUMBER                                     := 0;
         l_org_tot_u_age_sick_hours     NUMBER                                     := 0;
         l_leave_to_work_hours          NUMBER                                     := 0;
         l_long_leave_part              NUMBER                                     := 0;
         l_women_leave_to_work_hour     NUMBER                                     := 0;
         l_men_leave_to_work_hour       NUMBER                                     := 0;
         l_leave_to_work_hour_lower     NUMBER                                     := 0;
         l_leave_to_work_hour_middle    NUMBER                                     := 0;
         l_leave_to_work_hour_upper     NUMBER                                     := 0;
         l_duration                     NUMBER                                     := 0;
         l_element_type_id              pay_element_types_f.element_type_id%TYPE;
         l_input_value_start_date       pay_input_values_f.input_value_id%TYPE;
         l_input_value_end_date         pay_input_values_f.input_value_id%TYPE;
         l_input_value_cal_days         pay_input_values_f.input_value_id%TYPE;
         l_input_value_work_days        pay_input_values_f.input_value_id%TYPE;
         l_input_value_work_hours       pay_input_values_f.input_value_id%TYPE;
         l_group_date                   DATE;
         l_working_days                 NUMBER;
         l_working_hours                NUMBER;
         l_calendar_days                NUMBER;
         l_long_sick_leave              NUMBER;
      BEGIN
         l_current_year := to_char (p_effective_start_date, 'YYYY');

         IF p_curr_prev_flag = 'C' THEN
            l_curr_prev_data := 'LE_CURR_YR_DATA';
            l_curr_prev_stat := 'LE_CURR_YR_STAT';
            l_curr_prev_std_hour := 'LE_CURR_YR_STD_HOUR';
         ELSIF p_curr_prev_flag = 'P' THEN
            l_curr_prev_data := 'LE_PREV_YR_DATA';
            l_curr_prev_stat := 'LE_PREV_YR_STAT';
            l_curr_prev_std_hour := 'LE_PREV_YR_STD_HOUR';
         END IF;


         OPEN csr_legal_employer_details (p_legal_employer_id);
         FETCH csr_legal_employer_details INTO l_legal_employer_details;
         CLOSE csr_legal_employer_details;
         l_current_age := 0;
         l_men_lower_age_count := 0;
         l_men_middle_age_count := 0;
         l_men_upper_age_count := 0;
         l_women_lower_age_count := 0;
         l_women_middle_age_count := 0;
         l_women_upper_age_count := 0;
         l_emp_work_hours := 0;
         l_emp_sick_hours := 0;
         /* Get the Standard working hours */
         OPEN csr_get_std_work_details (p_legal_employer_id, to_char (p_effective_end_date, 'YYYY'));
         FETCH csr_get_std_work_details INTO l_curr_week_hours, l_curr_daily_hours, l_curr_days_per_year, l_curr_hours_per_year;
         CLOSE csr_get_std_work_details;

         IF l_curr_days_per_year IS NULL THEN
            l_curr_days_per_year := 0;
            l_curr_hours_per_year := 0;
            get_schedule_duration (
               p_start_date         => p_effective_start_date,
               p_end_date           => p_effective_end_date,
               p_days_or_hours      => 'D',
               p_duration           => l_curr_days_per_year
            );
            get_schedule_duration (
               p_start_date         => p_effective_start_date,
               p_end_date           => p_effective_end_date,
               p_days_or_hours      => 'H',
               p_duration           => l_curr_hours_per_year
            );
         END IF;

         pay_action_information_api.create_action_information (
            p_action_information_id            => l_action_info_id,
            p_action_context_id                => p_payroll_action_id,
            p_action_context_type              => 'PA',
            p_object_version_number            => l_ovn,
            p_effective_date                   => g_effective_date,
            p_source_id                        => NULL,
            p_source_text                      => NULL,
            p_action_information_category      => 'EMEA REPORT INFORMATION',
            p_action_information1              => 'PYSESLSA',
            p_action_information2              => l_curr_prev_std_hour,
            p_action_information3              => p_legal_employer_id,
            p_action_information4              => l_legal_employer_details.legal_employer_name,
            p_action_information5              => l_legal_employer_details.org_number,
            p_action_information6              => fnd_number.number_to_canonical (l_curr_week_hours),
            p_action_information7              => fnd_number.number_to_canonical (l_curr_daily_hours),
            p_action_information8              => fnd_number.number_to_canonical (l_curr_days_per_year),
            p_action_information9              => fnd_number.number_to_canonical (l_curr_hours_per_year),
            p_action_information10             => fnd_date.date_to_canonical (p_effective_start_date),
            p_action_information11             => fnd_date.date_to_canonical (p_effective_end_date)
         );
         /* Get the Element Type Id for the given element Name */
         OPEN csr_element_type ('Sickness Group Details', p_effective_end_date);
         FETCH csr_element_type INTO l_element_type_id;
         CLOSE csr_element_type;
         /* Get the Input Value id for the given Input Value Name */
         OPEN csr_input_values (l_element_type_id, p_effective_end_date, 'Start Date');
         FETCH csr_input_values INTO l_input_value_start_date;
         CLOSE csr_input_values;
         --
         OPEN csr_input_values (l_element_type_id, p_effective_end_date, 'End Date');
         FETCH csr_input_values INTO l_input_value_end_date;
         CLOSE csr_input_values;
         --
         OPEN csr_input_values (l_element_type_id, p_effective_end_date, 'Calendar Days');
         FETCH csr_input_values INTO l_input_value_cal_days;
         CLOSE csr_input_values;
         --
         OPEN csr_input_values (l_element_type_id, p_effective_end_date, 'Working Days');
         FETCH csr_input_values INTO l_input_value_work_days;
         CLOSE csr_input_values;
         --
         OPEN csr_input_values (l_element_type_id, p_effective_end_date, 'Working Hours');
         FETCH csr_input_values INTO l_input_value_work_hours;
         CLOSE csr_input_values;
	         --
         FOR i IN csr_get_employee_detail (
                     p_legal_employer_id         => p_legal_employer_id,
                     p_effective_start_date      => p_effective_start_date,
                     p_effective_end_date        => p_effective_end_date
                  )
         LOOP
            l_emp_sick_hours := 0;
            l_total_sick_days := 0;
            l_current_age := floor (months_between (g_end_date, i.date_of_birth) / 12);
            /* to_number (l_current_year) - to_number (to_char (i.date_of_birth, 'YYYY'));*/
            l_emp_work_hours := (l_curr_hours_per_year * i.work_percentage) / 100;
            l_long_sick_leave := 0;
	    l_emp_sick_hours  := 0;

            FOR rec_group_start_date IN csr_group_start_date (
                                           p_element_type_id        => l_element_type_id,
                                           p_assignment_id          => i.assignment_id,
                                           p_report_start_date      => p_effective_start_date,
                                           p_report_end_date        => p_effective_end_date,
                                           p_input_value_id         => l_input_value_start_date
                                        )
            LOOP

               l_calendar_days := 0;
               l_working_hours := 0;
               /* Get the no of Calendar days for the group */
               OPEN csr_get_input_value (
                  p_group_start_date      => rec_group_start_date.start_date,
                  p_input_value_id        => l_input_value_cal_days,
		  p_assignment_id         => i.assignment_id,
                  p_report_start_date     => p_effective_start_date,
                  p_report_end_date       => p_effective_end_date
               );
               FETCH csr_get_input_value INTO l_calendar_days;
               CLOSE csr_get_input_value;
               --


                    /* Get the no of Working Hours for the group */
               OPEN csr_get_input_value (
                  p_group_start_date      => rec_group_start_date.start_date,
                  p_input_value_id        => l_input_value_work_hours ,
		  p_assignment_id         => i.assignment_id,
                  p_report_start_date     => p_effective_start_date,
                  p_report_end_date       => p_effective_end_date
               );
               FETCH csr_get_input_value INTO l_working_hours;
               CLOSE csr_get_input_value;

               l_emp_sick_hours := l_emp_sick_hours + l_working_hours;

               IF l_calendar_days >= g_no_of_long_leave THEN
                  l_long_sick_leave := l_long_sick_leave + l_working_hours;
               END IF;

            END LOOP;

            IF i.sex = 'M' AND l_current_age > g_lower_age_group AND l_current_age < g_upper_age_group THEN
               l_emp_gender := 'MM';
               l_men_middle_age_count := l_men_middle_age_count + 1;
               l_men_middle_age_work_hour := l_men_middle_age_work_hour + l_emp_work_hours;
               l_men_m_age_sick_leaves := l_men_m_age_sick_leaves + l_emp_sick_hours;
               l_men_m_age_l_sick_leaves := l_men_m_age_l_sick_leaves + l_long_sick_leave;
            -- Get The Woen count for the middle age group
            ELSIF i.sex = 'F' AND l_current_age > g_lower_age_group AND l_current_age < g_upper_age_group THEN
               l_emp_gender := 'WM';
               l_women_middle_age_count := l_women_middle_age_count + 1;
               l_women_middle_age_work_hour := l_women_middle_age_work_hour + l_emp_work_hours;
               l_women_m_age_sick_leaves := l_women_m_age_sick_leaves + l_emp_sick_hours;
               l_women_m_age_l_sick_leaves := l_women_m_age_l_sick_leaves + l_long_sick_leave;
            -- Get The Men count for lower age group
            ELSIF i.sex = 'M' AND l_current_age <= g_lower_age_group THEN
               l_emp_gender := 'ML';
               l_men_lower_age_count := l_men_lower_age_count + 1;
               l_men_lower_age_work_hour := l_men_lower_age_work_hour + l_emp_work_hours;
               l_men_l_age_sick_leaves := l_men_l_age_sick_leaves + l_emp_sick_hours;
               l_men_l_age_l_sick_leaves := l_men_l_age_l_sick_leaves + l_long_sick_leave;
            --  Get The Women count for lower age group
            ELSIF i.sex = 'F' AND l_current_age <= g_lower_age_group THEN
               l_emp_gender := 'WL';
               l_women_lower_age_count := l_women_lower_age_count + 1;
               l_women_lower_age_work_hour := l_women_lower_age_work_hour + l_emp_work_hours;
               l_women_l_age_sick_leaves := l_women_l_age_sick_leaves + l_emp_sick_hours;
               l_women_l_age_l_sick_leaves := l_women_l_age_l_sick_leaves + l_long_sick_leave;
            -- Get The Men count for upper age group
            ELSIF i.sex = 'M' AND l_current_age >= g_upper_age_group THEN
               l_emp_gender := 'MU';
               l_men_upper_age_count := l_men_upper_age_count + 1;
               l_men_upper_age_work_hour := l_men_upper_age_work_hour + l_emp_work_hours;
               l_men_u_age_sick_leaves := l_men_u_age_sick_leaves + l_emp_sick_hours;
               l_men_u_age_l_sick_leaves := l_men_u_age_l_sick_leaves + l_long_sick_leave;
            -- Get The Women count for upper age group
            ELSIF i.sex = 'F' AND l_current_age >= g_upper_age_group THEN
               l_emp_gender := 'WU';
               l_women_upper_age_count := l_women_upper_age_count + 1;
               l_women_upper_age_work_hour := l_women_upper_age_work_hour + l_emp_work_hours;
               l_women_u_age_sick_leaves := l_women_u_age_sick_leaves + l_emp_sick_hours;
               l_women_u_age_l_sick_leaves := l_women_u_age_l_sick_leaves + l_long_sick_leave;
            END IF;
         END LOOP; -- End loop for csr_get_employee_detail
         /* Total Men Working Hours */
         l_org_tot_men_work_hours := l_men_lower_age_work_hour + l_men_middle_age_work_hour + l_men_upper_age_work_hour;
         --
              /* Total Women Working Hours */
         l_org_tot_women_work_hours := l_women_lower_age_work_hour + l_women_middle_age_work_hour + l_women_upper_age_work_hour;
         --
              /* Total Working Hours */
         l_org_total_work_hours := l_org_tot_men_work_hours + l_org_tot_women_work_hours;
         l_org_tot_l_age_work_hours := l_men_lower_age_work_hour + l_women_lower_age_work_hour;
         l_org_tot_m_age_work_hours := l_men_middle_age_work_hour + l_women_middle_age_work_hour;
         l_org_tot_u_age_work_hours := l_men_upper_age_work_hour + l_women_upper_age_work_hour;
         --
              /* Total Men Sick Hours  */
         l_org_tot_men_sick_hours := l_men_l_age_sick_leaves + l_men_m_age_sick_leaves + l_men_u_age_sick_leaves;
         --
              /* Total Women Sick Hours */
         l_org_tot_women_sick_hours := l_women_l_age_sick_leaves + l_women_m_age_sick_leaves + l_women_u_age_sick_leaves;
         --
              /* Total Sick leaves */
         l_org_total_sick_hours := l_org_tot_men_sick_hours + l_org_tot_women_sick_hours;
         l_org_tot_l_age_sick_hours := l_men_l_age_sick_leaves + l_women_l_age_sick_leaves;
         l_org_tot_m_age_sick_hours := l_men_m_age_sick_leaves + l_women_m_age_sick_leaves;
         l_org_tot_u_age_sick_hours := l_men_u_age_sick_leaves + l_women_u_age_sick_leaves;
         --
              /* Total Long Sick leaves */
         l_org_total_l_sick_hours := l_men_l_age_l_sick_leaves + l_women_l_age_l_sick_leaves + l_men_m_age_l_sick_leaves
                                     + l_women_m_age_l_sick_leaves + l_men_m_age_l_sick_leaves + l_women_u_age_l_sick_leaves;

         --
                    /* Find the Statistics */
               /* Find the  Total sick leave related to total standard working hours */
         IF l_org_total_work_hours > 0 THEN
            l_leave_to_work_hours := round ((l_org_total_sick_hours / l_org_total_work_hours * 100), 1);
         ELSE
            l_leave_to_work_hours := 0;
         END IF;

         --
          /* Find the  Part of total sick leave, which is 60 days or longer */
         IF l_org_total_sick_hours > 0 THEN
            l_long_leave_part := round ((l_org_total_l_sick_hours / l_org_total_sick_hours * 100), 1);
         ELSE
            l_long_leave_part := 0;
         END IF;

              --
         /* Find the  Sick leave for women related to total standard working hours for women */
         IF l_org_tot_women_work_hours > 0 THEN
            l_women_leave_to_work_hour := round ((l_org_tot_women_sick_hours / l_org_tot_women_work_hours * 100), 1);
         ELSE
            l_women_leave_to_work_hour := 0;
         END IF;

         /* Find the  Sick leave for men related to total standard working hours for men */
         IF l_org_tot_men_work_hours > 0 THEN
            l_men_leave_to_work_hour := round ((l_org_tot_men_sick_hours / l_org_tot_men_work_hours * 100), 1);
         ELSE
            l_men_leave_to_work_hour := 0;
         END IF;

         /* Find the Sick leave for the lower age group, related to the total standard working hours for this group  */
         IF l_org_tot_l_age_work_hours > 0 THEN
            l_leave_to_work_hour_lower := round ((l_org_tot_l_age_sick_hours / l_org_tot_l_age_work_hours * 100), 1);
         ELSE
            l_leave_to_work_hour_lower := 0;
         END IF;

         /* Find the Sick leave for the middle age group, related to the total standard working hours for this group  */
         IF l_org_tot_m_age_work_hours > 0 THEN
            l_leave_to_work_hour_middle := round ((l_org_tot_m_age_sick_hours / l_org_tot_m_age_work_hours * 100), 1);
         ELSE
            l_leave_to_work_hour_middle := 0;
         END IF;

         /* Find the Sick leave for the upper age group, related to the total standard working hours for this group  */
         IF l_org_tot_u_age_work_hours > 0 THEN
            l_leave_to_work_hour_upper := round ((l_org_tot_u_age_sick_hours / l_org_tot_u_age_work_hours * 100), 1);
         ELSE
            l_leave_to_work_hour_upper := 0;
         END IF;

         /* Archive the data for the Report Details */
         pay_action_information_api.create_action_information (
            p_action_information_id            => l_action_info_id,
            p_action_context_id                => p_payroll_action_id,
            p_action_context_type              => 'PA',
            p_object_version_number            => l_ovn,
            p_effective_date                   => g_effective_date,
            p_source_id                        => NULL,
            p_source_text                      => NULL,
            p_action_information_category      => 'EMEA REPORT INFORMATION',
            p_action_information1              => 'PYSESLSA',
            p_action_information2              => l_curr_prev_data,
            p_action_information3              => p_legal_employer_id,
            p_action_information4              => l_legal_employer_details.legal_employer_name,
            p_action_information5              => l_legal_employer_details.org_number,
            /* Archive the no of employees agewise in each gender group */
            p_action_information6              => fnd_number.number_to_canonical (l_men_lower_age_count),
            p_action_information7              => fnd_number.number_to_canonical (l_men_middle_age_count),
            p_action_information8              => fnd_number.number_to_canonical (l_men_upper_age_count),
            p_action_information9              => fnd_number.number_to_canonical (l_women_lower_age_count),
            p_action_information10             => fnd_number.number_to_canonical (l_women_middle_age_count),
            p_action_information11             => fnd_number.number_to_canonical (l_women_upper_age_count),
            /* Archive the no of working hours agewise in each gender group */
            p_action_information12             => fnd_number.number_to_canonical (l_men_lower_age_work_hour),
            p_action_information13             => fnd_number.number_to_canonical (l_men_middle_age_work_hour),
            p_action_information14             => fnd_number.number_to_canonical (l_men_upper_age_work_hour),
            p_action_information15             => fnd_number.number_to_canonical (l_women_lower_age_work_hour),
            p_action_information16             => fnd_number.number_to_canonical (l_women_middle_age_work_hour),
            p_action_information17             => fnd_number.number_to_canonical (l_women_upper_age_work_hour),
            /* Archive the no of sick leaves agewise in each gender group */
            p_action_information18             => fnd_number.number_to_canonical (l_men_l_age_sick_leaves),
            p_action_information19             => fnd_number.number_to_canonical (l_men_m_age_sick_leaves),
            p_action_information20             => fnd_number.number_to_canonical (l_men_u_age_sick_leaves),
            p_action_information21             => fnd_number.number_to_canonical (l_women_l_age_sick_leaves),
            p_action_information22             => fnd_number.number_to_canonical (l_women_m_age_sick_leaves),
            p_action_information23             => fnd_number.number_to_canonical (l_women_u_age_sick_leaves),
            /* Archive the no of long  sick leaves agewise in each gender group */
            p_action_information24             => fnd_number.number_to_canonical (l_men_l_age_l_sick_leaves),
            p_action_information25             => fnd_number.number_to_canonical (l_men_m_age_l_sick_leaves),
            p_action_information26             => fnd_number.number_to_canonical (l_men_u_age_l_sick_leaves),
            p_action_information27             => fnd_number.number_to_canonical (l_women_l_age_l_sick_leaves),
            p_action_information28             => fnd_number.number_to_canonical (l_women_m_age_l_sick_leaves),
            p_action_information29             => fnd_number.number_to_canonical (l_women_u_age_l_sick_leaves)
         );
         pay_action_information_api.create_action_information (
            p_action_information_id            => l_action_info_id,
            p_action_context_id                => p_payroll_action_id,
            p_action_context_type              => 'PA',
            p_object_version_number            => l_ovn,
            p_effective_date                   => g_effective_date,
            p_source_id                        => NULL,
            p_source_text                      => NULL,
            p_action_information_category      => 'EMEA REPORT INFORMATION',
            p_action_information1              => 'PYSESLSA',
            p_action_information2              => l_curr_prev_stat,
            p_action_information3              => p_legal_employer_id,
            p_action_information4              => l_legal_employer_details.legal_employer_name,
            p_action_information5              => l_legal_employer_details.org_number,
            /* Archive the no of employees agewise in each gender group */
            p_action_information6              => fnd_number.number_to_canonical (l_leave_to_work_hours),
            p_action_information7              => fnd_number.number_to_canonical (l_long_leave_part),
            p_action_information8              => fnd_number.number_to_canonical (l_men_leave_to_work_hour),
            p_action_information9              => fnd_number.number_to_canonical (l_women_leave_to_work_hour),
            p_action_information10             => fnd_number.number_to_canonical (l_leave_to_work_hour_lower),
            p_action_information11             => fnd_number.number_to_canonical (l_leave_to_work_hour_middle),
            p_action_information12             => fnd_number.number_to_canonical (l_leave_to_work_hour_upper)
         );
      END;
   -- Archiving the data , as this will fire once
   BEGIN
      g_debug := TRUE ;

      IF g_debug THEN
         hr_utility.set_location (' Entering Procedure RANGE_CODE', 40);
      END IF;

      p_sql :=
         'SELECT DISTINCT person_id
            FROM  per_people_f ppf
                 ,pay_payroll_actions ppa
            WHERE ppa.payroll_action_id = :payroll_action_id
            AND   ppa.business_group_id = ppf.business_group_id
            ORDER BY ppf.person_id';
      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_legal_employer_id := NULL;
      g_local_unit_id := NULL;
      pay_se_slsa_archive.get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_effective_date,
         g_legal_employer_id,
         g_request_for,
         g_start_date,
         g_end_date
      );
      l_current_start_date := g_start_date;

      IF g_effective_date < g_end_date THEN
         l_current_end_date := g_effective_date;
      ELSE
         l_current_end_date := g_end_date;
      END IF;

      l_previous_start_date := add_months (g_start_date, -12);
      l_previous_end_date := add_months (g_end_date, -12);

      IF g_request_for = 'REQUESTING_ORG' THEN
         OPEN csr_legal_employer_details (g_legal_employer_id);
         FETCH csr_legal_employer_details INTO l_legal_employer_details;
         CLOSE csr_legal_employer_details;
      END IF;

      -- Insert the report Parameters
      pay_action_information_api.create_action_information (
         p_action_information_id            => l_action_info_id,
         p_action_context_id                => p_payroll_action_id,
         p_action_context_type              => 'PA',
         p_object_version_number            => l_ovn,
         p_effective_date                   => g_effective_date,
         p_source_id                        => NULL,
         p_source_text                      => NULL,
         p_action_information_category      => 'EMEA REPORT DETAILS',
         p_action_information1              => 'PYSESLSA',
         p_action_information2              => hr_general.decode_lookup ('SE_TAX_CARD_REQUEST_LEVEL', g_request_for),
         p_action_information3              => g_legal_employer_id,
         p_action_information4              => l_legal_employer_details.legal_employer_name,
         p_action_information5              => fnd_date.date_to_canonical (g_start_date),
         p_action_information6              => fnd_date.date_to_canonical (g_end_date),
         p_action_information7              => NULL,
         p_action_information8              => NULL,
         p_action_information9              => NULL,
         p_action_information10             => NULL
      );

      IF g_request_for = 'REQUESTING_ORG' THEN
         /* For Current Year */
         get_employee_data (
            p_legal_employer_id         => g_legal_employer_id,
            p_effective_start_date      => g_start_date,
            p_effective_end_date        => g_end_date,
            p_curr_prev_flag            => 'C'
         );
         /* For Previous Year */
         get_employee_data (
            p_legal_employer_id         => g_legal_employer_id,
            p_effective_start_date      => add_months (g_start_date, -12),
            p_effective_end_date        => add_months (g_end_date, -12),
            p_curr_prev_flag            => 'P'
         );



      ELSE

-- *****************************************************************************
         FOR rec_legal_employer_details IN csr_legal_employer_details (NULL)
         LOOP
            /* For Current Year */
            get_employee_data (
               p_legal_employer_id         => rec_legal_employer_details.legal_id,
               p_effective_start_date      => g_start_date,
               p_effective_end_date        => g_end_date,
               p_curr_prev_flag            => 'C'
            );
            /* For Previous Year */
            get_employee_data (
               p_legal_employer_id         => rec_legal_employer_details.legal_id,
               p_effective_start_date      => add_months (g_start_date, -12),
               p_effective_end_date        => add_months (g_end_date, -12),
               p_curr_prev_flag            => 'P'
            );
         END LOOP;
      END IF; -- FOR G_LEGAL_EMPLOYER
      --END IF; -- G_Archive End
      IF g_debug THEN
         hr_utility.set_location (' Leaving Procedure RANGE_CODE', 50);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- Return cursor that selects no rows
         p_sql := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
   END range_code;
   /* ASSIGNMENT ACTION CODE */
   PROCEDURE assignment_action_code (
      p_payroll_action_id   IN   NUMBER,
      p_start_person        IN   NUMBER,
      p_end_person          IN   NUMBER,
      p_chunk               IN   NUMBER
   ) IS
   BEGIN
      IF g_debug THEN
         hr_utility.set_location (' Entering Procedure ASSIGNMENT_ACTION_CODE', 60);
      END IF;
   END assignment_action_code;
   /* INITIALIZATION CODE */
   PROCEDURE initialization_code (
      p_payroll_action_id   IN   NUMBER
   ) IS
   BEGIN
      IF g_debug THEN
         hr_utility.set_location (' Entering Procedure INITIALIZATION_CODE', 80);
      END IF;
   END initialization_code;
   /* ARCHIVE CODE */
   PROCEDURE archive_code (
      p_assignment_action_id   IN   NUMBER,
      p_effective_date         IN   DATE
   ) IS
   BEGIN
      IF g_debug THEN
         hr_utility.set_location (' Entering Procedure ARCHIVE_CODE', 380);
      END IF;
   END archive_code;
END pay_se_slsa_archive;

/
