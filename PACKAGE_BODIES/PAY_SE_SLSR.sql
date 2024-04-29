--------------------------------------------------------
--  DDL for Package Body PAY_SE_SLSR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_SLSR" AS
   /* $Header: pyseslsr.pkb 120.0.12000000.1 2007/07/18 11:18:03 psingla noship $ */
   PROCEDURE get_data (
      p_business_group_id   IN              NUMBER,
      p_payroll_action_id   IN              VARCHAR2,
      p_template_name       IN              VARCHAR2,
      p_xml                 OUT NOCOPY      CLOB
   ) IS
      --Cursors needed for report
      CURSOR csr_all_legal_employer (
         csr_v_pa_id            pay_action_information.action_context_id%TYPE,
         p_curr_prev_std_hour   VARCHAR2,
         p_leagal_employer_id   VARCHAR2
      ) IS
         SELECT action_information3 legal_employer_id, action_information4 legal_employer_name,
                action_information5
                      org_number, fnd_number.canonical_to_number (action_information6) week_hours,
                fnd_number.canonical_to_number (action_information7)
                      daily_hours,
                fnd_number.canonical_to_number (action_information8) days_per_year,
                fnd_number.canonical_to_number (action_information9)
                      hours_per_year,
                fnd_date.canonical_to_date (action_information10) start_date,
                fnd_date.canonical_to_date (action_information11)
                      end_date
         FROM   pay_action_information
         WHERE action_context_type = 'PA'
         AND   action_context_id = csr_v_pa_id
         AND   action_information_category = 'EMEA REPORT INFORMATION'
         AND   action_information1 = 'PYSESLSA'
         AND   action_information3 = nvl (p_leagal_employer_id, action_information3)
         AND   action_information2 = p_curr_prev_std_hour;

      CURSOR csr_all_legal_employer_l (
         csr_v_pa_id            pay_action_information.action_context_id%TYPE,
         p_curr_prev_std_hour   VARCHAR2,
         p_leagal_employer_id   VARCHAR2
      ) IS
         SELECT action_information3 legal_employer_id, action_information4 legal_employer_name,
                action_information5
                      org_number, fnd_number.canonical_to_number (action_information6) week_hours,
                fnd_number.canonical_to_number (action_information7)
                      daily_hours,
                fnd_number.canonical_to_number (action_information8) days_per_year,
                fnd_number.canonical_to_number (action_information9)
                      hours_per_year,
                fnd_date.canonical_to_date (action_information10) start_date,
                fnd_date.canonical_to_date (action_information11)
                      end_date
         FROM   pay_action_information
         WHERE action_context_type = 'PA'
         AND   action_context_id = csr_v_pa_id
         AND   action_information_category = 'EMEA REPORT INFORMATION'
         AND   action_information1 = 'PYSESLSA'
         AND   action_information3 = nvl (p_leagal_employer_id, action_information3)
         AND   action_information2 = p_curr_prev_std_hour;

      l_all_legal_employer         csr_all_legal_employer_l%ROWTYPE;

      CURSOR csr_get_report_data (
         csr_v_pa_id            pay_action_information.action_context_id%TYPE,
         p_curr_prev_data       VARCHAR2,
         p_leagal_employer_id   VARCHAR2
      ) IS
         SELECT fnd_number.canonical_to_number (action_information6) men_lower_age_count,
                fnd_number.canonical_to_number (action_information7)
                      men_middle_age_count,
                fnd_number.canonical_to_number (action_information8) men_upper_age_count,
                fnd_number.canonical_to_number (action_information9)
                      women_lower_age_count,
                fnd_number.canonical_to_number (action_information10) women_middle_age_count,
                fnd_number.canonical_to_number (action_information11)
                      women_upper_age_count,
                fnd_number.canonical_to_number (action_information12) men_lower_age_work_hour,
                fnd_number.canonical_to_number (action_information13)
                      men_middle_age_work_hour,
                fnd_number.canonical_to_number (action_information14) men_upper_age_work_hour,
                fnd_number.canonical_to_number (action_information15)
                      women_lower_age_work_hour,
                fnd_number.canonical_to_number (action_information16)
                      women_middle_age_work_hour,
                fnd_number.canonical_to_number (action_information17)
                      women_upper_age_work_hour,
                fnd_number.canonical_to_number (action_information18) men_l_age_sick_leaves,
                fnd_number.canonical_to_number (action_information19)
                      men_m_age_sick_leaves,
                fnd_number.canonical_to_number (action_information20) men_u_age_sick_leaves,
                fnd_number.canonical_to_number (action_information21)
                      women_l_age_sick_leaves,
                fnd_number.canonical_to_number (action_information22) women_m_age_sick_leaves,
                fnd_number.canonical_to_number (action_information23)
                      women_u_age_sick_leaves,
                fnd_number.canonical_to_number (action_information24) men_l_age_l_sick_leaves,
                fnd_number.canonical_to_number (action_information25)
                      men_m_age_l_sick_leaves,
                fnd_number.canonical_to_number (action_information26) men_u_age_l_sick_leaves,
                fnd_number.canonical_to_number (action_information27)
                      women_l_age_l_sick_leaves,
                fnd_number.canonical_to_number (action_information28)
                      women_m_age_l_sick_leaves,
                fnd_number.canonical_to_number (action_information29)
                      women_u_age_l_sick_leaves
         FROM   pay_action_information
         WHERE action_context_type = 'PA'
         AND   action_context_id = csr_v_pa_id
         AND   action_information_category = 'EMEA REPORT INFORMATION'
         AND   action_information1 = 'PYSESLSA'
         AND   action_information3 = p_leagal_employer_id
         AND   action_information2 = p_curr_prev_data;

      l_csr_get_curr_report_data   csr_get_report_data%ROWTYPE;
      l_csr_get_prev_report_data   csr_get_report_data%ROWTYPE;

      /*
           CURSOR csr_get_report_stat (
              csr_v_pa_id            pay_action_information.action_context_id%TYPE,
              p_curr_prev_stat       VARCHAR2,
              p_leagal_employer_id   VARCHAR2
           ) IS
              SELECT fnd_number.canonical_to_number (action_information6) leave_to_work_hours,
                     fnd_number.canonical_to_number (action_information7)
                           long_leave_part,
                     fnd_number.canonical_to_number (action_information8) men_leave_to_work_hour,
                     fnd_number.canonical_to_number (action_information9)
                           women_leave_to_work_hour,
                     fnd_number.canonical_to_number (action_information10) leave_to_work_hour_lower,
                     fnd_number.canonical_to_number (action_information11)
                           leave_to_work_hour_middle,
                     fnd_number.canonical_to_number (action_information12) leave_to_work_hour_upper
              FROM   pay_action_information
              WHERE action_context_type = 'PA'
              AND   action_context_id = csr_v_pa_id
              AND   action_information_category = 'EMEA REPORT INFORMATION'
              AND   action_information1 = 'PYSESLSA'
              AND   action_information3 = p_leagal_employer_id
              AND   action_information2 = p_curr_prev_stat;*/
      CURSOR csr_get_report_stat (
         csr_v_pa_id            pay_action_information.action_context_id%TYPE,
         p_curr_prev_stat       VARCHAR2,
         p_leagal_employer_id   VARCHAR2
      ) IS
         SELECT fnd_number.canonical_to_number (action_information6) leave_to_work_hours,
                fnd_number.canonical_to_number (action_information7)
                      long_leave_part,
                fnd_number.canonical_to_number (action_information8) men_leave_to_work_hour,
                fnd_number.canonical_to_number (action_information9)
                      women_leave_to_work_hour,
                fnd_number.canonical_to_number (action_information10) leave_to_work_hour_lower,
                fnd_number.canonical_to_number (action_information11)
                      leave_to_work_hour_middle,
                fnd_number.canonical_to_number (action_information12) leave_to_work_hour_upper
         FROM   pay_action_information
         WHERE action_context_type = 'PA'
         AND   action_context_id = csr_v_pa_id
         AND   action_information_category = 'EMEA REPORT INFORMATION'
         AND   action_information1 = 'PYSESLSA'
         AND   action_information3 = p_leagal_employer_id
         AND   action_information2 = p_curr_prev_stat;

      l_csr_get_curr_report_stat   csr_get_report_stat%ROWTYPE;
      l_csr_get_prev_report_stat   csr_get_report_stat%ROWTYPE;
      l_payroll_action_id          pay_action_information.action_information1%TYPE;
      l_counter                    NUMBER                                            := 0;
   BEGIN
      IF p_payroll_action_id IS NULL THEN
         BEGIN
            SELECT payroll_action_id
            INTO  l_payroll_action_id
            FROM   pay_payroll_actions ppa, fnd_conc_req_summary_v fcrs, fnd_conc_req_summary_v fcrs1
            WHERE fcrs.request_id = fnd_global.conc_request_id
            AND   fcrs.priority_request_id = fcrs1.priority_request_id
            AND   ppa.request_id BETWEEN fcrs1.request_id AND fcrs.request_id
            AND   ppa.request_id = fcrs1.request_id;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      ELSE
         l_payroll_action_id := p_payroll_action_id;
      END IF;

      FOR i IN csr_all_legal_employer (
                  csr_v_pa_id               => l_payroll_action_id,
                  p_curr_prev_std_hour      => 'LE_CURR_YR_STD_HOUR',
                  p_leagal_employer_id      => NULL
               )
      LOOP
         xml_tab (l_counter).tagname := 'ORG_NAME';
         xml_tab (l_counter).tagvalue := i.legal_employer_name;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'ORG_NUM';
         xml_tab (l_counter).tagvalue := i.org_number;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'CURR_WEEK_HOURS';
         xml_tab (l_counter).tagvalue := i.week_hours;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'CURR_DAILY_HOURS';
         xml_tab (l_counter).tagvalue := i.daily_hours;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'CURR_DAYS_PER_YEAR';
         xml_tab (l_counter).tagvalue := i.days_per_year;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'CURR_HOURS_PER_YEAR';
         xml_tab (l_counter).tagvalue := i.hours_per_year;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'CURR_START_DATE';
         xml_tab (l_counter).tagvalue := to_char (i.start_date, 'YYYYMMDD');
         l_counter := l_counter + 1;
         xml_tab (l_counter).tagname := 'CURR_END_DATE';
         xml_tab (l_counter).tagvalue := to_char (i.end_date, 'YYYYMMDD');
         l_counter := l_counter + 1;
         OPEN csr_all_legal_employer_l (l_payroll_action_id, 'LE_PREV_YR_STD_HOUR', i.legal_employer_id);
         FETCH csr_all_legal_employer_l INTO l_all_legal_employer;
         CLOSE csr_all_legal_employer_l;
         --
         --
         xml_tab (l_counter).tagname := 'PREV_WEEK_HOURS';
         xml_tab (l_counter).tagvalue := l_all_legal_employer.week_hours;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'PREV_DAILY_HOURS';
         xml_tab (l_counter).tagvalue := l_all_legal_employer.daily_hours;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'PREV_DAYS_PER_YEAR';
         xml_tab (l_counter).tagvalue := l_all_legal_employer.days_per_year;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'PREV_HOURS_PER_YEAR';
         xml_tab (l_counter).tagvalue := l_all_legal_employer.hours_per_year;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'PREV_START_DATE';
         xml_tab (l_counter).tagvalue := to_char (l_all_legal_employer.start_date, 'YYYYMMDD');
         l_counter := l_counter + 1;
         xml_tab (l_counter).tagname := 'PREV_END_DATE';
         xml_tab (l_counter).tagvalue := to_char (l_all_legal_employer.end_date, 'YYYYMMDD');
         l_counter := l_counter + 1;
         /* Get The Report data for the current year */
         OPEN csr_get_report_data (
            csr_v_pa_id               => l_payroll_action_id,
            p_curr_prev_data          => 'LE_CURR_YR_DATA',
            p_leagal_employer_id      => i.legal_employer_id
         );
         FETCH csr_get_report_data INTO l_csr_get_curr_report_data;
         CLOSE csr_get_report_data;
         xml_tab (l_counter).tagname := 'MEN_LOWER_AGE_COUNT_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_lower_age_count;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'MEN_MIDDLE_AGE_COUNT_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_middle_age_count;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_UPPER_AGE_COUNT_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_upper_age_count;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_LOWER_AGE_COUNT_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_lower_age_count;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_MIDDLE_AGE_COUNT_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_middle_age_count;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_UPPER_AGE_COUNT_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_upper_age_count;
         l_counter := l_counter + 1;
         xml_tab (l_counter).tagname := 'TOT_EMP_COUNT_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_lower_age_count
                                         + l_csr_get_curr_report_data.men_middle_age_count
                                         + l_csr_get_curr_report_data.men_upper_age_count
                                         + l_csr_get_curr_report_data.women_lower_age_count
                                         + l_csr_get_curr_report_data.women_middle_age_count
                                         + l_csr_get_curr_report_data.women_upper_age_count;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_LOWER_AGE_HOUR_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_lower_age_work_hour;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_MIDDLE_AGE_HOUR_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_middle_age_work_hour;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_UPPER_AGE_HOUR_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_upper_age_work_hour;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'WOMEN_LOWER_AGE_HOUR_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_lower_age_work_hour;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'WOMEN_MIDDLE_AGE_HOUR_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_middle_age_work_hour;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'WOMEN_UPPER_AGE_HOUR_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_upper_age_work_hour;
         l_counter := l_counter + 1;
              --
         --
         xml_tab (l_counter).tagname := 'TOT_WORK_HOUR_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_lower_age_work_hour
                                         + l_csr_get_curr_report_data.men_middle_age_work_hour
                                         + l_csr_get_curr_report_data.men_upper_age_work_hour
                                         + l_csr_get_curr_report_data.women_lower_age_work_hour
                                         + l_csr_get_curr_report_data.women_middle_age_work_hour
                                         + l_csr_get_curr_report_data.women_upper_age_work_hour;
         l_counter := l_counter + 1;
         xml_tab (l_counter).tagname := 'MEN_L_AGE_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_l_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_M_AGE_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_m_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_U_AGE_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_u_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_L_AGE_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_l_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_M_AGE_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_m_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_U_AGE_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_u_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'TOT_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_l_age_sick_leaves
                                         + l_csr_get_curr_report_data.men_m_age_sick_leaves
                                         + l_csr_get_curr_report_data.men_u_age_sick_leaves
                                         + l_csr_get_curr_report_data.women_l_age_sick_leaves
                                         + l_csr_get_curr_report_data.women_m_age_sick_leaves
                                         + l_csr_get_curr_report_data.women_u_age_sick_leaves;
         l_counter := l_counter + 1;
         xml_tab (l_counter).tagname := 'MEN_L_AGE_L_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_l_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_M_AGE_L_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_m_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_U_AGE_L_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_u_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_L_AGE_L_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_l_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_M_AGE_L_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_m_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_U_AGE_L_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.women_u_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'TOT_L_SICK_LEAVES_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_data.men_l_age_l_sick_leaves
                                         + l_csr_get_curr_report_data.men_m_age_l_sick_leaves
                                         + l_csr_get_curr_report_data.men_u_age_l_sick_leaves
                                         + l_csr_get_curr_report_data.women_l_age_l_sick_leaves
                                         + l_csr_get_curr_report_data.women_m_age_l_sick_leaves
                                         + l_csr_get_curr_report_data.women_u_age_l_sick_leaves;
         l_counter := l_counter + 1;
         /* Get The Report data for the current year */
         OPEN csr_get_report_data (
            csr_v_pa_id               => l_payroll_action_id,
            p_curr_prev_data          => 'LE_PREV_YR_DATA',
            p_leagal_employer_id      => i.legal_employer_id
         );
         FETCH csr_get_report_data INTO l_csr_get_prev_report_data;
         CLOSE csr_get_report_data;
         xml_tab (l_counter).tagname := 'MEN_LOWER_AGE_COUNT_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_lower_age_count;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'MEN_MIDDLE_AGE_COUNT_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_middle_age_count;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_UPPER_AGE_COUNT_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_upper_age_count;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_LOWER_AGE_COUNT_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_lower_age_count;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_MIDDLE_AGE_COUNT_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_middle_age_count;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_UPPER_AGE_COUNT_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_upper_age_count;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'TOT_EMP_COUNT_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_lower_age_count
                                         + l_csr_get_prev_report_data.men_middle_age_count
                                         + l_csr_get_prev_report_data.men_upper_age_count
                                         + l_csr_get_prev_report_data.women_lower_age_count
                                         + l_csr_get_prev_report_data.women_middle_age_count
                                         + l_csr_get_prev_report_data.women_upper_age_count;
         l_counter := l_counter + 1;
         xml_tab (l_counter).tagname := 'MEN_LOWER_AGE_HOUR_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_lower_age_work_hour;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'MEN_MIDDLE_AGE_HOUR_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_middle_age_work_hour;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_UPPER_AGE_HOUR_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_upper_age_work_hour;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'WOMEN_LOWER_AGE_HOUR_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_lower_age_work_hour;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'WOMEN_MIDDLE_AGE_HOUR_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_middle_age_work_hour;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'WOMEN_UPPER_AGE_HOUR_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_upper_age_work_hour;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'TOT_WORK_HOUR_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_lower_age_work_hour
                                         + l_csr_get_prev_report_data.men_middle_age_work_hour
                                         + l_csr_get_prev_report_data.men_upper_age_work_hour
                                         + l_csr_get_prev_report_data.women_lower_age_work_hour
                                         + l_csr_get_prev_report_data.women_middle_age_work_hour
                                         + l_csr_get_prev_report_data.women_upper_age_work_hour;
         l_counter := l_counter + 1;
         xml_tab (l_counter).tagname := 'MEN_L_AGE_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_l_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_M_AGE_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_m_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_U_AGE_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_u_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_L_AGE_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_l_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_M_AGE_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_m_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_U_AGE_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_u_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --

         --
         xml_tab (l_counter).tagname := 'TOT_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_l_age_sick_leaves
                                         + l_csr_get_prev_report_data.men_m_age_sick_leaves
                                         + l_csr_get_prev_report_data.men_u_age_sick_leaves
                                         + l_csr_get_prev_report_data.women_l_age_sick_leaves
                                         + l_csr_get_prev_report_data.women_m_age_sick_leaves
                                         + l_csr_get_prev_report_data.women_u_age_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_L_AGE_L_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_l_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_M_AGE_L_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_m_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_U_AGE_L_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_u_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_L_AGE_L_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_l_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_M_AGE_L_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_m_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_U_AGE_L_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.women_u_age_l_sick_leaves;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'TOT_L_SICK_LEAVES_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_data.men_l_age_l_sick_leaves
                                         + l_csr_get_prev_report_data.men_m_age_l_sick_leaves
                                         + l_csr_get_prev_report_data.men_u_age_l_sick_leaves
                                         + l_csr_get_prev_report_data.women_l_age_l_sick_leaves
                                         + l_csr_get_prev_report_data.women_m_age_l_sick_leaves
                                         + l_csr_get_prev_report_data.women_u_age_l_sick_leaves;
         l_counter := l_counter + 1;
         /* Get The Report statistics for the current year */
         OPEN csr_get_report_stat (
            csr_v_pa_id               => l_payroll_action_id,
            p_curr_prev_stat          => 'LE_CURR_YR_STAT', --'LE_CURR_YR_STAT',
            p_leagal_employer_id      => i.legal_employer_id
         );
         FETCH csr_get_report_stat INTO l_csr_get_curr_report_stat;
         CLOSE csr_get_report_stat;
         xml_tab (l_counter).tagname := 'LEAVE_TO_WORK_HOURS_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_stat.leave_to_work_hours;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'LONG_LEAVE_PART_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_stat.long_leave_part;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_LEAVE_TO_WORK_HOUR_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_stat.men_leave_to_work_hour;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_LEAVE_TO_WORK_HOUR_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_stat.women_leave_to_work_hour;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'LEAVE_TO_WORK_HOUR_LOWER_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_stat.leave_to_work_hour_lower;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'LEAVE_TO_WORK_HOUR_MIDDLE_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_stat.leave_to_work_hour_middle;
         l_counter := l_counter + 1;
         --


         xml_tab (l_counter).tagname := 'LEAVE_TO_WORK_HOUR_UPPER_C';
         xml_tab (l_counter).tagvalue := l_csr_get_curr_report_stat.leave_to_work_hour_upper;
         l_counter := l_counter + 1;
         --
         /* Get The Report data for the current year */
         OPEN csr_get_report_stat (
            csr_v_pa_id               => l_payroll_action_id,
            p_curr_prev_stat          => 'LE_PREV_YR_STAT',
            p_leagal_employer_id      => i.legal_employer_id
         );
         FETCH csr_get_report_stat INTO l_csr_get_prev_report_stat;
         CLOSE csr_get_report_stat;
         xml_tab (l_counter).tagname := 'LEAVE_TO_WORK_HOURS_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_stat.leave_to_work_hours;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'LONG_LEAVE_PART_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_stat.long_leave_part;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'MEN_LEAVE_TO_WORK_HOUR_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_stat.men_leave_to_work_hour;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'WOMEN_LEAVE_TO_WORK_HOUR_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_stat.women_leave_to_work_hour;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'LEAVE_TO_WORK_HOUR_LOWER_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_stat.leave_to_work_hour_lower;
         l_counter := l_counter + 1;
         --
         --
         xml_tab (l_counter).tagname := 'LEAVE_TO_WORK_HOUR_MIDDLE_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_stat.leave_to_work_hour_middle;
         l_counter := l_counter + 1;
         --

         xml_tab (l_counter).tagname := 'LEAVE_TO_WORK_HOUR_UPPER_P';
         xml_tab (l_counter).tagvalue := l_csr_get_prev_report_stat.leave_to_work_hour_upper;
         l_counter := l_counter + 1;
      --

      END LOOP;

      writetoclob (p_xml);
   --
   END get_data;

-----------------------------------------------------------------------------------------------------------------
   PROCEDURE writetoclob (
      p_xfdf_clob   OUT NOCOPY   CLOB
   ) IS
      l_xfdf_string    CLOB;
      l_iana_charset   VARCHAR2 (30);
      current_index    PLS_INTEGER;
      l_str1           VARCHAR2 (1000);
      l_str2           VARCHAR2 (20);
      l_str3           VARCHAR2 (20);
      l_str4           VARCHAR2 (20);
      l_str5           VARCHAR2 (20);
      l_str6           VARCHAR2 (30);
      l_str7           VARCHAR2 (1000);
      l_str8           VARCHAR2 (240);
      l_str9           VARCHAR2 (240);
      l_str10          VARCHAR2 (20);
      l_str11          VARCHAR2 (20);
      l_str12          VARCHAR2 (30);
      l_str13          VARCHAR2 (30);
      l_str14          VARCHAR2 (30);
      l_str15          VARCHAR2 (30);
   BEGIN
      l_iana_charset := hr_se_utility.get_iana_charset;
      l_str1 := '<?xml version="1.0" encoding="' || l_iana_charset || '"?> <ROOT><PAACR>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</PAACR></ROOT>';
      l_str7 := '<?xml version="1.0" encoding="' || l_iana_charset || '"?> <ROOT></ROOT>';
      l_str10 := '<PAACR>';
      l_str11 := '</PAACR>';
      l_str12 := '<FILE_HEADER_START>';
      l_str13 := '</FILE_HEADER_START>';
      l_str14 := '<LE_RECORD>';
      l_str15 := '</LE_RECORD>';
      dbms_lob.createtemporary (l_xfdf_string, FALSE , dbms_lob.CALL);
      dbms_lob.OPEN (l_xfdf_string, dbms_lob.lob_readwrite);
      current_index := 0;

      IF xml_tab.count > 0 THEN
         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);
         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str12), l_str12);

         FOR table_counter IN xml_tab.FIRST .. xml_tab.LAST
         LOOP
            l_str8 := xml_tab (table_counter).tagname;
            l_str9 := xml_tab (table_counter).tagvalue;

            IF l_str8 = 'ORG_NAME' THEN
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str14), l_str14);
            END IF;

            IF l_str9 IS NOT NULL THEN
               l_str9 := '<![CDATA[' || l_str9 || ']]>';
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str9), l_str9);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
            ELSE
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
            END IF;

            IF xml_tab.LAST = table_counter THEN
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str15), l_str15);
            ELSIF xml_tab (table_counter + 1).tagname = 'ORG_NAME' AND l_str8 <> 'REPORT_DATE' THEN
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str15), l_str15);
            END IF;
         END LOOP;

         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str13), l_str13);
         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str6), l_str6);
      ELSE
         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str7), l_str7);
      END IF;

      p_xfdf_clob := l_xfdf_string;
      hr_utility.set_location ('Leaving WritetoCLOB ', 20);
   END writetoclob;
-------------------------------------------------------------------------------------------------------------------------

END pay_se_slsr;

/
