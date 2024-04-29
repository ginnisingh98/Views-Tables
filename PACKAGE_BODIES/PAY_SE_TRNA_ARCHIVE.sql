--------------------------------------------------------
--  DDL for Package Body PAY_SE_TRNA_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_TRNA_ARCHIVE" AS
   /* $Header: pysetrna.pkb 120.2.12010000.2 2009/03/13 07:05:36 rsengupt ship $ */
   TYPE lock_rec IS RECORD (
      archive_assact_id   NUMBER
   );

   TYPE lock_table IS TABLE OF lock_rec
      INDEX BY BINARY_INTEGER;

   g_debug                   BOOLEAN       := hr_utility.debug_enabled;
   g_package                 VARCHAR2 (33) := 'pay_se_trna_archive.';
   g_payroll_action_id       NUMBER;
   -- Globals to pick up all the parameter
   g_business_group_id       NUMBER;
   g_effective_date          DATE;
   g_legal_employer_id       NUMBER;
   g_local_unit_id           NUMBER;
   g_request_for             VARCHAR2 (20);
   g_start_date              DATE;
   g_end_date                DATE;
   g_div_code                VARCHAR2 (30);
   g_request_for_div         VARCHAR2 (30);
   g_agreement_area          VARCHAR2 (30);
   g_emp_catg                VARCHAR2 (30);
   g_asg_catg                VARCHAR2 (30);
   g_precedence_end_date     DATE;
   g_start_date_of_birth     DATE;
   g_end_date_of_birth       DATE;
   g_request_for_agreement   VARCHAR2 (30);
   g_emp_sec                 VARCHAR2 (30);
   g_lock_table              lock_table;
   g_index                   NUMBER        := -1;
   g_index_assact            NUMBER        := -1;
   g_index_bal               NUMBER        := -1;
   g_report_date             DATE;
   g_sort_order              VARCHAR2 (30);
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

      g_debug := FALSE ;
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
      p_request_for_all_or_not   OUT NOCOPY      VARCHAR2, -- User parameter
      p_div_code                 OUT NOCOPY      VARCHAR2 -- User parameter
                                                         ,
      p_request_for_div          OUT NOCOPY      VARCHAR2 -- User parameter
                                                         ,
      p_agreement_area           OUT NOCOPY      VARCHAR2 -- User parameter
                                                         ,
      p_request_for_agreement    OUT NOCOPY      VARCHAR2, -- User parameter
      p_report_date              OUT NOCOPY      VARCHAR2,
      p_precedence_end_date      OUT NOCOPY      DATE,
      p_start_date_of_birth      OUT NOCOPY      DATE,
      p_end_date_of_birth        OUT NOCOPY      DATE,
      p_emp_catg                 OUT NOCOPY      VARCHAR2 -- User parameter
                                                         ,
      p_asg_catg                 OUT NOCOPY      VARCHAR2 -- User parameter
                                                         ,
      p_emp_sec                  OUT NOCOPY      VARCHAR2,
      p_sort_order               OUT NOCOPY      VARCHAR2,
      p_start_date               OUT NOCOPY      DATE -- User parameter
                                                     ,
      p_end_date                 OUT NOCOPY      DATE
   ) IS
      CURSOR csr_parameter_info (
         p_payroll_action_id   NUMBER
      ) IS
         SELECT to_number (
                   substr (
                      pay_se_trna_archive.get_parameter (legislative_parameters, 'LEGAL_EMPLOYER'),
                      1,
                      LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'LEGAL_EMPLOYER')) - 1
                   )
                ) legal,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'REQUEST_FOR'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'REQUEST_FOR')) - 1
                ) request_for,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'DIVISION'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'DIVISION')) - 1
                ) division,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'REQUEST_FOR_DIV'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'REQUEST_FOR_DIV')) - 1
                ) request_for_div,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'AGREEMENT_AREA'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'AGREEMENT_AREA')) - 1
                ) agreement_area,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'REQUEST_FOR_AGREEMENT'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'REQUEST_FOR_AGREEMENT')) - 1
                )
                      request_for_agreement,
                (pay_se_trna_archive.get_parameter (legislative_parameters, 'REPORT_DATE')) report_date,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'PRECEDENCE_END_DATE'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'PRECEDENCE_END_DATE')) - 1
                )
                      precedence_end_date1,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'EMP_CATG'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'EMP_CATG')) - 1
                ) emp_catg,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'ASG_CATG'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'ASG_CATG')) - 1
                ) asg_catg,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'EMP_SEC'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'EMP_SEC')) - 1
                ) requesting_emp_sec,
                substr (
                   pay_se_trna_archive.get_parameter (legislative_parameters, 'SORT_ORDER'),
                   1,
                   LENGTH (pay_se_trna_archive.get_parameter (legislative_parameters, 'SORT_ORDER')) - 1
                ) sort_order,
                (pay_se_trna_archive.get_parameter (legislative_parameters, 'EFFECTIVE_START_DATE')) eff_start_date,
                (pay_se_trna_archive.get_parameter (legislative_parameters, 'EFFECTIVE_END_DATE'))
                      eff_end_date,
                (pay_se_trna_archive.get_parameter (legislative_parameters, 'PRECEDENCE_END_DATE')) precedence_end_date,
                (pay_se_trna_archive.get_parameter (legislative_parameters, 'START_DATE_OF_BIRTH'))
                      start_date_of_birth,
                (pay_se_trna_archive.get_parameter (legislative_parameters, 'END_DATE_OF_BIRTH')) end_date_of_birth,
                effective_date
                      effective_date, business_group_id bg_id
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
      p_div_code := lr_parameter_info.division;
      p_request_for_div := lr_parameter_info.request_for_div;
      p_agreement_area := lr_parameter_info.agreement_area;
      p_request_for_agreement := lr_parameter_info.request_for_agreement;
      p_report_date := fnd_date.canonical_to_date (lr_parameter_info.report_date);
      p_precedence_end_date := fnd_date.canonical_to_date (lr_parameter_info.precedence_end_date);
      p_emp_catg := lr_parameter_info.emp_catg;
      p_asg_catg := lr_parameter_info.asg_catg;
      p_start_date_of_birth := fnd_date.canonical_to_date (lr_parameter_info.start_date_of_birth);
      p_end_date_of_birth := fnd_date.canonical_to_date (lr_parameter_info.end_date_of_birth);
      p_emp_sec := lr_parameter_info.requesting_emp_sec;
      p_start_date := fnd_date.canonical_to_date (lr_parameter_info.eff_start_date);
      p_end_date := fnd_date.canonical_to_date (lr_parameter_info.eff_end_date);
      p_effective_date := lr_parameter_info.effective_date;
      p_business_group_id := lr_parameter_info.bg_id;
      p_sort_order := lr_parameter_info.sort_order;

      SELECT decode (lr_parameter_info.emp_catg, 'B', 'BC', 'W', 'WC', NULL)
      INTO  p_emp_catg
      FROM   dual;

      IF g_debug THEN
         hr_utility.set_location (' Leaving Procedure GET_ALL_PARAMETERS', 30);
      END IF;
   END get_all_parameters;
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
      l_le_has_employee          VARCHAR2 (2);
      l_curr_avg_men_count       NUMBER;
      l_curr_avg_women_count     NUMBER;
      l_prev_avg_men_count       NUMBER;
      l_prev_avg_women_count     NUMBER;
   -- Archiving the data , as this will fire once
   BEGIN
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
      pay_se_trna_archive.get_all_parameters (
         g_payroll_action_id,
         g_business_group_id,
         g_effective_date,
         g_legal_employer_id,
         g_request_for,
         g_div_code,
         g_request_for_div,
         g_agreement_area,
         g_request_for_agreement,
         g_report_date,
         g_precedence_end_date,
         g_start_date_of_birth,
         g_end_date_of_birth,
         g_emp_catg,
         g_asg_catg,
         g_emp_sec,
         g_sort_order,
         g_start_date,
         g_end_date
      );

      IF g_request_for = 'REQUESTING_ORG' THEN
         OPEN csr_legal_employer_details (g_legal_employer_id);
         FETCH csr_legal_employer_details INTO l_legal_employer_details;
         CLOSE csr_legal_employer_details;
      END IF;

      pay_action_information_api.create_action_information (
         p_action_information_id            => l_action_info_id,
         p_action_context_id                => g_payroll_action_id,
         p_action_context_type              => 'PA',
         p_object_version_number            => l_ovn,
         p_effective_date                   => g_effective_date,
         p_source_id                        => NULL,
         p_source_text                      => NULL,
         p_action_information_category      => 'EMEA REPORT DETAILS',
         p_action_information1              => 'PYSETRNA',
         p_action_information2              => hr_general.decode_lookup ('SE_TAX_CARD_REQUEST_LEVEL', g_request_for),
         p_action_information3              => g_legal_employer_id,
         p_action_information4              => l_legal_employer_details.legal_employer_name,
         p_action_information5              => fnd_date.date_to_canonical (g_start_date),
         p_action_information6              => fnd_date.date_to_canonical (g_end_date),
         p_action_information7              => hr_general.decode_lookup ('SE_REQUEST_LEVEL', g_request_for_div),
         p_action_information8              => g_div_code,
         p_action_information9              => hr_general.decode_lookup ('SE_DIVISION_CODE', g_div_code),
         p_action_information10             => hr_general.decode_lookup ('SE_REQUEST_LEVEL', g_request_for_agreement),
         p_action_information11             => g_agreement_area,
         p_action_information12             => hr_general.decode_lookup ('SE_AGREEMENT_CODE', g_agreement_area),
         p_action_information13             => hr_general.decode_lookup ('EMPLOYEE_CATG', g_emp_catg),
         p_action_information14             => hr_general.decode_lookup ('EMP_CAT', g_asg_catg),
         p_action_information15             => hr_general.decode_lookup ('HR_SE_EMP_SECTION', g_emp_sec),
         p_action_information16             => fnd_date.date_to_canonical (g_start_date_of_birth),
         p_action_information17             => fnd_date.date_to_canonical (g_end_date_of_birth),
         p_action_information18             => fnd_date.date_to_canonical (g_precedence_end_date),
         p_action_information19             => fnd_date.date_to_canonical (g_report_date),
         p_action_information20             => g_sort_order
      );

      FOR rec_legal_employer_details IN csr_legal_employer_details (g_legal_employer_id)
      LOOP
         pay_action_information_api.create_action_information (
            p_action_information_id            => l_action_info_id,
            p_action_context_id                => p_payroll_action_id,
            p_action_context_type              => 'PA',
            p_object_version_number            => l_ovn,
            p_effective_date                   => g_effective_date,
            p_source_id                        => NULL,
            p_source_text                      => NULL,
            p_action_information_category      => 'EMEA REPORT INFORMATION',
            p_action_information1              => 'PYSETRNA',
            p_action_information2              => 'LE',
            p_action_information3              => rec_legal_employer_details.legal_id,
            p_action_information4              => rec_legal_employer_details.legal_employer_name,
            p_action_information5              => rec_legal_employer_details.org_number
         );
      END LOOP;

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

      CURSOR csr_person_assignments (
         p_legal_employer_id   hr_organization_information.organization_id%TYPE
      ) IS
         SELECT papf.person_id, paaf.assignment_id, papf.full_name, papf.national_identifier, paaf.assignment_number,
                paaf.employment_category, hsck.segment15 div_code, hsck.segment14 area_code
         FROM   per_all_assignments_f paaf,
                hr_soft_coding_keyflex hsck,
                hr_organization_units hou,
                hr_organization_information hoi,
                per_all_people_f papf
         WHERE papf.person_id BETWEEN p_start_person AND p_end_person
         AND   g_report_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
         AND   paaf.effective_start_date BETWEEN papf.effective_start_date AND papf.effective_end_date
         AND   papf.person_id = paaf.person_id
         AND   hou.business_group_id = g_business_group_id
         AND   papf.date_of_birth BETWEEN nvl (g_start_date_of_birth, TO_DATE ('01/01/0001', 'dd/mm/yyyy'))
                                      AND nvl (g_end_date_of_birth, TO_DATE ('31/12/4712', 'dd/mm/yyyy'))
         AND   paaf.employee_category IN ('WC', 'BC')
         AND   paaf.employee_category = nvl (g_emp_catg, paaf.employee_category)
         AND   nvl (paaf.employment_category, '-1') = nvl (g_asg_catg, nvl (paaf.employment_category, '-1'))
         AND   hsck.segment15 IS NOT NULL
         AND   hsck.segment15 = nvl (g_div_code, hsck.segment15)
         AND   hsck.segment14 IS NOT NULL
         AND   hsck.segment14 = nvl (g_agreement_area, hsck.segment14)
         AND   primary_flag = 'Y'
         AND   hou.organization_id = hoi.organization_id
         AND   hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
         AND   hoi.organization_id = nvl (p_legal_employer_id, hoi.organization_id)
         AND   hoi.org_information_context = 'SE_LOCAL_UNITS'
         AND   hoi.org_information1 = hsck.segment2
	 AND   (SELECT nvl(fnd_date.canonical_to_date (hs.segment16),TO_DATE ('01/01/0001', 'dd/mm/yyyy'))
                                         FROM hr_soft_coding_keyflex hs
	               WHERE hs.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id) <= nvl (
                                                                 g_precedence_end_date,
                                                                 TO_DATE ('31/12/4712', 'dd/mm/yyyy')
                                                              ); -- Inner Query for 7162312
       /*AND   fnd_date.canonical_to_date (nvl('2001/01/01 00:00:00','2001/01/01 00:00:00')) <=
                                                                 nvl(g_precedence_end_date,
                                                                 fnd_date.canonical_to_date ('4712/12/31 00:00:00')
                                                               ); */

      /* Cursor to get the Start Date of the Assignment */
      CURSOR csr_start_date (
         p_assignment_id   per_all_assignments_f.assignment_id%TYPE
      ) IS
         SELECT min (effective_start_date)
         FROM   per_all_assignments_f paaf, per_assignment_status_types past
         WHERE assignment_id = p_assignment_id
         AND   paaf.assignment_status_type_id = past.assignment_status_type_id
         AND   past.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
         AND   effective_start_date BETWEEN nvl(g_start_date,effective_start_date) AND nvl(g_end_date, effective_end_date); -- nvl for 7162312

      /* Cursor to get the Termination and Prcedence Date */
      CURSOR csr_emp_details (
         p_assignment_id    per_all_assignments_f.assignment_id%TYPE,
         p_effective_date   DATE
      ) IS
         SELECT fnd_date.canonical_to_date (hsck.segment6) termination_date,
                fnd_date.canonical_to_date (hsck.segment16)
                      precedence_date
         FROM   per_all_assignments_f paaf, hr_soft_coding_keyflex hsck
         WHERE paaf.assignment_id = p_assignment_id
         AND   hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
         AND   p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date;

      /* Cursor to retrieve Person Previous Employment Time  Details */
      CURSOR csr_person_prev_teta (
         csr_v_person_id           NUMBER,
         csr_v_business_group_id   NUMBER,
         csr_v_effective_date      DATE
      ) IS
         SELECT   start_date, end_date, end_date - start_date prev_emp_days
         FROM     per_previous_employers_v ppev
         WHERE ppev.person_id = csr_v_person_id
         AND   ppev.business_group_id = csr_v_business_group_id
         AND   ppev.start_date <= csr_v_effective_date
         ORDER BY ppev.start_date ASC;

      l_prepay_action_id       NUMBER;
      l_actid                  NUMBER;
      l_assignment_id          NUMBER;
      l_action_sequence        NUMBER;
      l_assact_id              NUMBER;
      l_pact_id                NUMBER;
      l_flag                   NUMBER        := 0;
      l_action_info_id         NUMBER;
      l_ovn                    NUMBER;
      l_emp_start_date         DATE;
      l_current_emp_time       NUMBER;
      l_prev_total_emp_time    NUMBER;
      l_total_emp_time         NUMBER;
      l_hire_date              DATE;
      l_termination_date       DATE;
      l_precedence_date        DATE;
      l_emp_termination_date   DATE;
      l_emp_precedence_date    DATE;
      l_emp_type               VARCHAR2 (10);
   BEGIN
      IF g_debug THEN
         hr_utility.set_location ('Entering Procedure ASSIGNMENT_ACTION_CODE', 60);
      END IF;

      pay_se_trna_archive.get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_effective_date,
         g_legal_employer_id,
         g_request_for,
         g_div_code,
         g_request_for_div,
         g_agreement_area,
         g_request_for_agreement,
         g_report_date,
         g_precedence_end_date,
         g_start_date_of_birth,
         g_end_date_of_birth,
         g_emp_catg,
         g_asg_catg,
         g_emp_sec,
         g_sort_order,
         g_start_date,
         g_end_date
      );

      FOR rec_legal_employer_details IN csr_legal_employer_details (g_legal_employer_id)
      LOOP
         FOR person_assignments_rec IN csr_person_assignments (rec_legal_employer_details.legal_id)
         LOOP
            l_hire_date := NULL;
            l_emp_start_date := NULL;
            l_prev_total_emp_time := 0;
            l_termination_date := NULL;
            l_precedence_date := NULL;
            l_emp_type := NULL;
            l_emp_termination_date := NULL;
            l_emp_precedence_date := NULL;
            -- Get the Start Date For Current Employment
            OPEN csr_start_date (person_assignments_rec.assignment_id);
            FETCH csr_start_date INTO l_emp_start_date;
            CLOSE csr_start_date;

            IF l_emp_start_date IS NOT NULL THEN
               l_current_emp_time := g_effective_date - l_emp_start_date;

               FOR person_prev_teta_rec IN csr_person_prev_teta (
                                              person_assignments_rec.person_id,
                                              g_business_group_id,
                                              g_effective_date
                                           )
               LOOP
                  IF l_hire_date IS NULL THEN
                     l_hire_date := person_prev_teta_rec.start_date;
                  END IF;

                  l_prev_total_emp_time := l_prev_total_emp_time + person_prev_teta_rec.prev_emp_days;
               END LOOP;

               IF l_hire_date IS NULL THEN
                  l_hire_date := l_emp_start_date;
               END IF;

               l_total_emp_time := l_current_emp_time + l_prev_total_emp_time;
               OPEN csr_emp_details (person_assignments_rec.assignment_id, g_effective_date);
               FETCH csr_emp_details INTO l_emp_termination_date, l_emp_precedence_date;
               CLOSE csr_emp_details;

               --If the termination date is in future and and the assignment category is termporay employment

               IF     l_emp_termination_date IS NOT NULL
                  AND l_emp_termination_date > g_effective_date
                  AND person_assignments_rec.employment_category = 'SE_TE' THEN
                  l_termination_date := l_emp_termination_date;
               END IF;

               IF l_emp_precedence_date IS NOT NULL AND l_emp_termination_date > g_effective_date THEN
                  l_termination_date := NULL;
                  l_precedence_date := l_emp_precedence_date;
               END IF;

               SELECT pay_assignment_actions_s.NEXTVAL
               INTO  l_actid
               FROM   dual;

               --
               g_index_assact := g_index_assact + 1;
               g_lock_table (g_index_assact).archive_assact_id := l_actid;
               -- Create the archive assignment action
               hr_nonrun_asact.insact (l_actid, person_assignments_rec.assignment_id, p_payroll_action_id, p_chunk, NULL);

               IF l_precedence_date IS NOT NULL THEN
                  l_emp_type := 'PRE';
               ELSIF l_termination_date IS NOT NULL THEN
                  l_emp_type := 'TLE';
               ELSE
                  l_emp_type := 'REG';
               END IF;

               IF g_emp_sec IS NULL THEN
                  pay_action_information_api.create_action_information (
                     p_action_information_id            => l_action_info_id,
                     p_action_context_id                => l_actid,
                     p_action_context_type              => 'AAP',
                     p_object_version_number            => l_ovn,
                     p_effective_date                   => g_effective_date,
                     p_source_id                        => NULL,
                     p_source_text                      => NULL,
                     p_action_information_category      => 'EMEA REPORT INFORMATION',
                     p_action_information1              => 'PYSETRNA',
                     p_action_information2              => g_payroll_action_id,
                     p_action_information3              => person_assignments_rec.person_id,
                     p_action_information4              => person_assignments_rec.national_identifier,
                     p_action_information5              => person_assignments_rec.assignment_number,
                     p_action_information6              => person_assignments_rec.full_name,
                     p_action_information7              => fnd_date.date_to_canonical (l_hire_date),
                     p_action_information8              => fnd_number.number_to_canonical (l_total_emp_time),
                     p_action_information9              => fnd_date.date_to_canonical (l_precedence_date),
                     p_action_information10             => fnd_date.date_to_canonical (l_termination_date),
                     p_action_information11             => l_emp_type,
                     p_action_information12             => g_emp_sec,
                     p_action_information13             => rec_legal_employer_details.legal_id,
                     p_action_information14             => person_assignments_rec.div_code,
                     p_action_information15             => person_assignments_rec.area_code,
                     p_action_information16             => hr_general.decode_lookup (
                                                              'SE_DIVISION_CODE',
                                                              person_assignments_rec.div_code
                                                           ),
                     p_action_information17             => hr_general.decode_lookup (
                                                              'SE_AGREEMENT_CODE',
                                                              person_assignments_rec.area_code
                                                           )
                  );
               ELSIF g_emp_sec = 'REGULAR' AND l_precedence_date IS NULL AND l_termination_date IS NULL THEN
                  pay_action_information_api.create_action_information (
                     p_action_information_id            => l_action_info_id,
                     p_action_context_id                => l_actid,
                     p_action_context_type              => 'AAP',
                     p_object_version_number            => l_ovn,
                     p_effective_date                   => g_effective_date,
                     p_source_id                        => NULL,
                     p_source_text                      => NULL,
                     p_action_information_category      => 'EMEA REPORT INFORMATION',
                     p_action_information1              => 'PYSETRNA',
                     p_action_information2              => g_payroll_action_id,
                     p_action_information3              => person_assignments_rec.person_id,
                     p_action_information4              => person_assignments_rec.national_identifier,
                     p_action_information5              => person_assignments_rec.assignment_number,
                     p_action_information6              => person_assignments_rec.full_name,
                     p_action_information7              => fnd_date.date_to_canonical (l_hire_date),
                     p_action_information8              => l_total_emp_time,
                     p_action_information9              => NULL,
                     p_action_information10             => NULL,
                     p_action_information11             => l_emp_type,
                     p_action_information12             => g_emp_sec,
                     p_action_information13             => rec_legal_employer_details.legal_id,
                     p_action_information14             => person_assignments_rec.div_code,
                     p_action_information15             => person_assignments_rec.area_code,
                     p_action_information16             => hr_general.decode_lookup (
                                                              'SE_DIVISION_CODE',
                                                              person_assignments_rec.div_code
                                                           ),
                     p_action_information17             => hr_general.decode_lookup (
                                                              'SE_AGREEMENT_CODE',
                                                              person_assignments_rec.area_code
                                                           )
                  );
               ELSIF g_emp_sec = 'PREVIOUS' AND l_precedence_date IS NOT NULL THEN
                  pay_action_information_api.create_action_information (
                     p_action_information_id            => l_action_info_id,
                     p_action_context_id                => l_actid,
                     p_action_context_type              => 'AAP',
                     p_object_version_number            => l_ovn,
                     p_effective_date                   => g_effective_date,
                     p_source_id                        => NULL,
                     p_source_text                      => NULL,
                     p_action_information_category      => 'EMEA REPORT INFORMATION',
                     p_action_information1              => 'PYSETRNA',
                     p_action_information2              => g_payroll_action_id,
                     p_action_information3              => person_assignments_rec.person_id,
                     p_action_information4              => person_assignments_rec.national_identifier,
                     p_action_information5              => person_assignments_rec.assignment_number,
                     p_action_information6              => person_assignments_rec.full_name,
                     p_action_information7              => fnd_date.date_to_canonical (l_hire_date),
                     p_action_information8              => l_total_emp_time,
                      p_action_information9              => fnd_date.date_to_canonical (l_precedence_date),
                     p_action_information10             => NULL,
                     p_action_information11             => l_emp_type,
                     p_action_information12             => g_emp_sec,
                     p_action_information13             => rec_legal_employer_details.legal_id,
                     p_action_information14             => person_assignments_rec.div_code,
                     p_action_information15             => person_assignments_rec.area_code,
                     p_action_information16             => hr_general.decode_lookup (
                                                              'SE_DIVISION_CODE',
                                                              person_assignments_rec.div_code
                                                           ),
                     p_action_information17             => hr_general.decode_lookup (
                                                              'SE_AGREEMENT_CODE',
                                                              person_assignments_rec.area_code
                                                           )
                  );
               ELSIF g_emp_sec = 'TIME_LIMITED' AND l_precedence_date IS NULL AND l_termination_date IS NOT NULL THEN
                  pay_action_information_api.create_action_information (
                     p_action_information_id            => l_action_info_id,
                     p_action_context_id                => l_actid,
                     p_action_context_type              => 'AAP',
                     p_object_version_number            => l_ovn,
                     p_effective_date                   => g_effective_date,
                     p_source_id                        => NULL,
                     p_source_text                      => NULL,
                     p_action_information_category      => 'EMEA REPORT INFORMATION',
                     p_action_information1              => 'PYSETRNA',
                     p_action_information2              => g_payroll_action_id,
                     p_action_information3              => person_assignments_rec.person_id,
                     p_action_information4              => person_assignments_rec.national_identifier,
                     p_action_information5              => person_assignments_rec.assignment_number,
                     p_action_information6              => person_assignments_rec.full_name,
                     p_action_information7              => fnd_date.date_to_canonical (l_hire_date),
                     p_action_information8              => l_total_emp_time,
                     p_action_information9              => NULL,
                     p_action_information10             => fnd_date.date_to_canonical (l_termination_date),
                     p_action_information11             => l_emp_type,
                     p_action_information12             => g_emp_sec,
                     p_action_information13             => rec_legal_employer_details.legal_id,
                     p_action_information14             => person_assignments_rec.div_code,
                     p_action_information15             => person_assignments_rec.area_code,
                     p_action_information16             => hr_general.decode_lookup (
                                                              'SE_DIVISION_CODE',
                                                              person_assignments_rec.div_code
                                                           ),
                     p_action_information17             => hr_general.decode_lookup (
                                                              'SE_AGREEMENT_CODE',
                                                              person_assignments_rec.area_code
                                                           )
                  );
               END IF;
            END IF;
         -- Create archive to prepayment assignment action interlock
         --
         --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);

         END LOOP;
      END LOOP;
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
END pay_se_trna_archive;

/
