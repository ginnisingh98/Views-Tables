--------------------------------------------------------
--  DDL for Package Body PAY_SE_HCIA_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_HCIA_ARCHIVE" AS
   /* $Header: pysehcia.pkb 120.0.12000000.1 2007/07/18 10:57:48 psingla noship $ */
   g_debug               BOOLEAN       := hr_utility.debug_enabled;
   g_package             VARCHAR2 (33) := 'PAY_SE_HCIA_ARCHIVE.';
   g_payroll_action_id   NUMBER;
   -- Globals to pick up all the parameter
   g_business_group_id   NUMBER;
   g_effective_date      DATE;
   g_legal_employer_id   NUMBER;
   g_local_unit_id       NUMBER;
   g_request_for         VARCHAR2 (20);
   g_start_date          DATE;
   g_end_date            DATE;
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
                      pay_se_hcia_archive.get_parameter (legislative_parameters, 'LEGAL_EMPLOYER'),
                      1,
                      LENGTH (pay_se_hcia_archive.get_parameter (legislative_parameters, 'LEGAL_EMPLOYER')) - 1
                   )
                ) legal,
                substr (
                   pay_se_hcia_archive.get_parameter (legislative_parameters, 'REQUEST_FOR'),
                   1,
                   LENGTH (pay_se_hcia_archive.get_parameter (legislative_parameters, 'REQUEST_FOR')) - 1
                ) request_for,
                (pay_se_hcia_archive.get_parameter (legislative_parameters, 'EFFECTIVE_START_DATE')) eff_start_date,
                (pay_se_hcia_archive.get_parameter (legislative_parameters, 'EFFECTIVE_END_DATE'))
                      eff_end_date,
                effective_date effective_date, business_group_id bg_id
         FROM   pay_payroll_actions
         WHERE payroll_action_id = p_payroll_action_id;

      lr_parameter_info   csr_parameter_info%ROWTYPE;
      l_proc              VARCHAR2 (240)               := g_package || ' GET_ALL_PARAMETERS ';
   BEGIN

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

      FUNCTION get_emp_count (
         p_legal_employer_id   hr_organization_information.organization_id%TYPE,
         p_gender_type         per_all_people_f.sex%TYPE,
         p_start_date          DATE,
         p_end_date            DATE
      )
         RETURN NUMBER IS
         l_start_count     NUMBER := 0;
         l_end_count       NUMBER := 0;
         l_average_count   NUMBER := 0;

         CURSOR csr_get_employee_count (
            p_legal_employer_id   hr_organization_information.organization_id%TYPE,
            p_gender_type         per_all_people_f.sex%TYPE,
            p_effective_date      DATE
         ) IS
            SELECT count (*)
            FROM   per_all_people_f papf,
                   per_all_assignments_f paaf,
                   hr_soft_coding_keyflex hsc,
                   per_assignment_status_types past,
                   hr_organization_information hoi,
                   per_person_types ppt
            WHERE paaf.person_id = papf.person_id
            AND   paaf.business_group_id = papf.business_group_id
            AND   hsc.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
            AND   hsc.segment2 = hoi.org_information1
            AND   hoi.organization_id = p_legal_employer_id
            AND   ppt.system_person_type LIKE 'EMP%'
            AND   ppt.person_type_id = papf.person_type_id
            AND   papf.sex = p_gender_type
            AND   paaf.assignment_status_type_id = past.assignment_status_type_id
            AND   past.per_system_status = 'ACTIVE_ASSIGN'
            AND   paaf.primary_flag = 'Y'
            AND   p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
            AND   p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date;
      BEGIN
         -- Get The count in the start
         OPEN csr_get_employee_count (
            p_legal_employer_id      => p_legal_employer_id,
            p_gender_type            => p_gender_type,
            p_effective_date         => p_start_date
         );
         FETCH csr_get_employee_count INTO l_start_count;
         CLOSE csr_get_employee_count;
         -- Get the Count in the end

         OPEN csr_get_employee_count (
            p_legal_employer_id      => p_legal_employer_id,
            p_gender_type            => p_gender_type,
            p_effective_date         => p_end_date
         );
         FETCH csr_get_employee_count INTO l_end_count;
         CLOSE csr_get_employee_count;

         -- Find the Average
         IF (l_start_count + l_end_count) > 0 THEN
            l_average_count := (l_start_count + l_end_count) / 2;
         END IF;

         RETURN l_average_count;
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
      pay_se_hcia_archive.get_all_parameters (
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
         p_action_information1              => 'PYSEHCIA',
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
         -- Information regarding the Legal Employer
         OPEN csr_legal_employer_details (g_legal_employer_id);
         FETCH csr_legal_employer_details INTO l_legal_employer_details;
         CLOSE csr_legal_employer_details;
         -- Get the current average for men

         l_curr_avg_men_count := get_emp_count (g_legal_employer_id, 'M', l_current_start_date, l_current_end_date);
         -- Get the current average for women

         l_curr_avg_women_count := get_emp_count (g_legal_employer_id, 'F', l_current_start_date, l_current_end_date);
         -- Get the previous average for men
         l_prev_avg_men_count := get_emp_count (g_legal_employer_id, 'M', l_previous_start_date, l_previous_end_date);
         -- Get the previous average for women
         l_prev_avg_women_count := get_emp_count (g_legal_employer_id, 'F', l_previous_start_date, l_previous_end_date);

         IF    (l_curr_avg_men_count > 0)
            OR (l_curr_avg_women_count > 0)
            OR (l_prev_avg_men_count > 0)
            OR (l_prev_avg_women_count > 0) THEN
            pay_action_information_api.create_action_information (
               p_action_information_id            => l_action_info_id,
               p_action_context_id                => p_payroll_action_id,
               p_action_context_type              => 'PA',
               p_object_version_number            => l_ovn,
               p_effective_date                   => g_effective_date,
               p_source_id                        => NULL,
               p_source_text                      => NULL,
               p_action_information_category      => 'EMEA REPORT INFORMATION',
               p_action_information1              => 'PYSEHCIA',
               p_action_information2              => 'LE',
               p_action_information3              => g_legal_employer_id,
               p_action_information4              => l_legal_employer_details.legal_employer_name,
               p_action_information5              => l_legal_employer_details.org_number,
               p_action_information6              => fnd_date.date_to_canonical (l_current_start_date),
               p_action_information7              => fnd_date.date_to_canonical (l_current_end_date),
               p_action_information8              => fnd_date.date_to_canonical (l_previous_start_date),
               p_action_information9              => fnd_date.date_to_canonical (l_previous_end_date),
               p_action_information10             => fnd_number.number_to_canonical (l_curr_avg_men_count),
               p_action_information11             => fnd_number.number_to_canonical (l_curr_avg_women_count),
               p_action_information12             => fnd_number.number_to_canonical (l_prev_avg_men_count),
               p_action_information13             => fnd_number.number_to_canonical (l_prev_avg_women_count)
            );
         END IF;
-- *****************************************************************************
      ELSE

-- *****************************************************************************
         FOR rec_legal_employer_details IN csr_legal_employer_details (NULL)
         LOOP
            -- Get the current average for men
            l_curr_avg_men_count := get_emp_count (
                                       rec_legal_employer_details.legal_id,
                                       'M',
                                       g_start_date,
                                       l_current_end_date
                                    );
            -- Get the current average for women

            l_curr_avg_women_count := get_emp_count (
                                         rec_legal_employer_details.legal_id,
                                         'F',
                                         g_start_date,
                                         l_current_end_date
                                      );
            -- Get the previous average for men
            l_prev_avg_men_count := get_emp_count (
                                       rec_legal_employer_details.legal_id,
                                       'M',
                                       l_previous_start_date,
                                       l_previous_end_date
                                    );
            -- Get the previous average for women
            l_prev_avg_women_count := get_emp_count (
                                         rec_legal_employer_details.legal_id,
                                         'F',
                                         l_previous_start_date,
                                         l_previous_end_date
                                      );

            IF    (l_curr_avg_men_count > 0)
               OR (l_curr_avg_women_count > 0)
               OR (l_prev_avg_men_count > 0)
               OR (l_prev_avg_women_count > 0) THEN
               pay_action_information_api.create_action_information (
                  p_action_information_id            => l_action_info_id,
                  p_action_context_id                => p_payroll_action_id,
                  p_action_context_type              => 'PA',
                  p_object_version_number            => l_ovn,
                  p_effective_date                   => g_effective_date,
                  p_source_id                        => NULL,
                  p_source_text                      => NULL,
                  p_action_information_category      => 'EMEA REPORT INFORMATION',
                  p_action_information1              => 'PYSEHCIA',
                  p_action_information2              => 'LE',
                  p_action_information3              => rec_legal_employer_details.legal_id,
                  p_action_information4              => rec_legal_employer_details.legal_employer_name,
                  p_action_information5              => rec_legal_employer_details.org_number,
                  p_action_information6              => fnd_date.date_to_canonical (l_current_start_date),
                  p_action_information7              => fnd_date.date_to_canonical (l_current_end_date),
                  p_action_information8              => fnd_date.date_to_canonical (l_previous_start_date),
                  p_action_information9              => fnd_date.date_to_canonical (l_previous_end_date),
                  p_action_information10             => fnd_number.number_to_canonical (l_curr_avg_men_count),
                  p_action_information11             => fnd_number.number_to_canonical (l_curr_avg_women_count),
                  p_action_information12             => fnd_number.number_to_canonical (l_prev_avg_men_count),
                  p_action_information13             => fnd_number.number_to_canonical (l_prev_avg_women_count)
               );
            END IF;
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
END pay_se_hcia_archive;

/
