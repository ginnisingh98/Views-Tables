--------------------------------------------------------
--  DDL for Package Body PAY_SE_ALECTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_ALECTA" AS
/* $Header: pysealer.pkb 120.0.12010000.5 2009/04/20 14:11:44 rsengupt ship $ */
   g_debug                   BOOLEAN        := hr_utility.debug_enabled;

   TYPE lock_rec IS RECORD (
      archive_assact_id   NUMBER
   );

   TYPE lock_table IS TABLE OF lock_rec
      INDEX BY BINARY_INTEGER;

   g_lock_table              lock_table;
   g_index                   NUMBER         := -1;
   g_index_assact            NUMBER         := -1;
   g_index_bal               NUMBER         := -1;
   g_package                 VARCHAR2 (100) := 'PAY_SE_ALECTA.';
   g_payroll_action_id       NUMBER;
   g_arc_payroll_action_id   NUMBER;
-- Globals to pick up all the parameter
   g_business_group_id       NUMBER;
   g_effective_date          DATE;
   g_pension_provider_id     NUMBER;
   g_legal_employer_id       NUMBER;
   g_local_unit_id           NUMBER;
   g_request_for             VARCHAR2 (20);
   g_year                    NUMBER;
   g_month                   VARCHAR2 (4);
   g_sent_from               VARCHAR2 (240);
   g_sent_to                 VARCHAR2 (240);
   g_production              VARCHAR2 (240);
--End of Globals to pick up all the parameter
   g_format_mask             VARCHAR2 (50);
   g_err_num                 NUMBER;
   g_errm                    VARCHAR2 (150);

   /* GET PARAMETER */
   FUNCTION get_parameter (
      p_parameter_string         IN       VARCHAR2
     ,p_token                    IN       VARCHAR2
     ,p_segment_number           IN       NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      l_parameter   pay_payroll_actions.legislative_parameters%TYPE   := NULL;
      l_start_pos   NUMBER;
      l_delimiter   VARCHAR2 (1)                                      := ' ';
      l_proc        VARCHAR2 (40)           := g_package || ' get parameter ';
   BEGIN
      --
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Function GET_PARAMETER', 10);
      END IF;

      l_start_pos :=
              INSTR (' ' || p_parameter_string, l_delimiter || p_token || '=');

      --
      IF l_start_pos = 0
      THEN
         l_delimiter := '|';
         l_start_pos :=
             INSTR (' ' || p_parameter_string, l_delimiter || p_token || '=');
      END IF;

--      DBMS_OUTPUT.put_line (' ' || p_parameter_string);
--      DBMS_OUTPUT.put_line (l_delimiter || p_token || '=');
--      DBMS_OUTPUT.put_line (l_start_pos);

      IF l_start_pos <> 0
      THEN
         l_start_pos := l_start_pos + LENGTH (p_token || '=');
--         DBMS_OUTPUT.put_line (l_start_pos);
         l_parameter :=
            SUBSTR (p_parameter_string
                   ,l_start_pos
                   ,   INSTR (p_parameter_string || ' ', ',', l_start_pos)
                     - (l_start_pos)
                   );
--         DBMS_OUTPUT.put_line (l_parameter);

         IF p_segment_number IS NOT NULL
         THEN
            l_parameter := ':' || l_parameter || ':';
            l_parameter :=
               SUBSTR (l_parameter
                      , INSTR (l_parameter, ':', 1, p_segment_number) + 1
                      ,   INSTR (l_parameter, ':', 1, p_segment_number + 1)
                        - 1
                        - INSTR (l_parameter, ':', 1, p_segment_number)
                      );
         END IF;
      END IF;

      --
      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Function GET_PARAMETER', 20);
      END IF;

      RETURN l_parameter;
   END;

   /* GET ALL PARAMETERS */
   PROCEDURE get_all_parameters (
      p_payroll_action_id        IN       NUMBER               -- In parameter
     ,p_business_group_id        OUT NOCOPY NUMBER           -- Core parameter
     ,p_effective_date           OUT NOCOPY DATE             -- Core parameter
     ,p_legal_employer_id        OUT NOCOPY NUMBER           -- User parameter
     ,p_request_for_all_or_not   OUT NOCOPY VARCHAR2         -- User parameter
     ,p_year                     OUT NOCOPY NUMBER           -- User parameter
     ,p_month                    OUT NOCOPY VARCHAR2         -- User parameter
     ,p_sent_from                OUT NOCOPY VARCHAR2
     ,p_sent_to                  OUT NOCOPY VARCHAR2
     ,p_production               OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR csr_parameter_info (p_payroll_action_id NUMBER)
      IS
         SELECT TO_NUMBER
                         (pay_se_alecta.get_parameter (legislative_parameters
                                                      ,'LEGAL_EMPLOYER'
                                                      )
                         ) legal
               , (pay_se_alecta.get_parameter (legislative_parameters
                                              ,'REQUEST_FOR'
                                              )
                 ) request_for
               , (pay_se_alecta.get_parameter (legislative_parameters, 'YEAR')
                 ) report_year
               , (pay_se_alecta.get_parameter (legislative_parameters
                                              ,'MONTH')
                 ) report_month
               , (pay_se_alecta.get_parameter (legislative_parameters
                                              ,'SENT_FROM'
                                              )
                 ) sent_from
               , (pay_se_alecta.get_parameter (legislative_parameters
                                              ,'SENT_TO'
                                              )
                 ) sent_to
               , (pay_se_alecta.get_parameter (legislative_parameters
                                              ,'PRODUCTION'
                                              )
                 ) production
               ,effective_date effective_date
               ,business_group_id bg_id
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_payroll_action_id;

      lr_parameter_info   csr_parameter_info%ROWTYPE;
      l_proc              VARCHAR2 (240)
                                        := g_package || ' GET_ALL_PARAMETERS ';
   BEGIN
/*      fnd_file.put_line (fnd_file.LOG,
                         'Entering Procedure GET_ALL_PARAMETER '
                        );
      fnd_file.put_line (fnd_file.LOG,
                         'Payroill Action iD   ' || p_payroll_action_id
                        );
*/
      OPEN csr_parameter_info (p_payroll_action_id);

      --FETCH csr_parameter_info into lr_parameter_info;
      FETCH csr_parameter_info
       INTO lr_parameter_info;

      CLOSE csr_parameter_info;

      p_legal_employer_id := lr_parameter_info.legal;
      p_request_for_all_or_not := lr_parameter_info.request_for;
      p_year := TO_NUMBER (lr_parameter_info.report_year);
      p_month := (lr_parameter_info.report_month);
      p_sent_from := (lr_parameter_info.sent_from);
      p_sent_to := (lr_parameter_info.sent_to);
      p_production := (lr_parameter_info.production);
      p_effective_date := lr_parameter_info.effective_date;
      p_business_group_id := lr_parameter_info.bg_id;
/*
      fnd_file.put_line (fnd_file.LOG,
                            'lr_parameter_info.Legal   '
                         || lr_parameter_info.legal
                        );
      fnd_file.put_line (fnd_file.LOG,
                            'lr_parameter_info.REQUEST_FOR   '
                         || lr_parameter_info.request_for
                        );
      fnd_file.put_line (fnd_file.LOG,
                         'lr_parameter_info.YEAR   ' || lr_parameter_info.REPORT_YEAR
                        );

      fnd_file.put_line (fnd_file.LOG,
                            'lr_parameter_info.MONTH   '
                         || lr_parameter_info.REPORT_MONTH
                        );

      fnd_file.put_line (fnd_file.LOG,
                            'lr_parameter_info.Effective_date   '
                         || lr_parameter_info.effective_date
                        );

      fnd_file.put_line (fnd_file.LOG, 'After  csr_parameter_info in  ');
      fnd_file.put_line (fnd_file.LOG,
                            'After  p_legal_employer_id  in  '
                         || p_legal_employer_id
                        );
*/
   END get_all_parameters;

 -- Changes 2008/2009
-- Adding the function to get the defined balace id of a given balance
  function defined_balance_id (p_balance_type     in varchar2,
                             p_dimension_suffix in varchar2) return number is
--
  l_legislation_code  varchar2(30) := 'SE';
--
  l_found       BOOLEAN := FALSE;

  l_balance_name        VARCHAR2(80);
  l_balance_suffix      VARCHAR2(30);

  CURSOR c_defined_balance IS
        SELECT
                defined_balance_id
        FROM
                pay_defined_balances PDB,
                pay_balance_dimensions PBD,
                pay_balance_types PBT
        WHERE   PBT.balance_name = p_balance_type
        AND     PBT.legislation_code = l_legislation_code
        AND     PDB.balance_type_id = PBT.balance_type_id
        AND     PBD.balance_dimension_id = PDB.balance_dimension_id
        AND     PDB.legislation_code = l_legislation_code
        AND     PBD.database_item_suffix = p_dimension_suffix;


--
  l_result number;
--
begin

        open c_defined_balance;
        fetch c_defined_balance into l_result;
        close c_defined_balance;

  return l_result;
End;
-- end changes 2008/2009

   /* RANGE CODE */
   PROCEDURE range_code (
      p_payroll_action_id        IN       NUMBER
     ,p_sql                      OUT NOCOPY VARCHAR2
   )
   IS
      l_action_info_id           NUMBER;
      l_ovn                      NUMBER;
      l_business_group_id        NUMBER;
      l_start_date               VARCHAR2 (30);
      l_end_date                 VARCHAR2 (30);
      l_effective_date           DATE;
      l_consolidation_set        NUMBER;
      l_defined_balance_id       NUMBER                               := 0;
      l_count                    NUMBER                               := 0;
      l_prev_prepay              NUMBER                               := 0;
      l_canonical_start_date     DATE;
      l_canonical_end_date       DATE;
      l_payroll_id               NUMBER;
      l_prepay_action_id         NUMBER;
      l_actid                    NUMBER;
      l_assignment_id            NUMBER;
      l_action_sequence          NUMBER;
      l_assact_id                NUMBER;
      l_pact_id                  NUMBER;
      l_flag                     NUMBER                               := 0;
      l_element_context          VARCHAR2 (5);

-- Archiving the data , as this will fire once
      CURSOR csr_legal_employer_details (
         csr_v_legal_employer_id             hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT o1.NAME legal_employer_name
               ,hoi2.org_information2 org_number
               ,hoi1.organization_id legal_id
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id =
                           NVL (csr_v_legal_employer_id, hoi1.organization_id)
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS';

      l_legal_employer_details   csr_legal_employer_details%ROWTYPE;

      CURSOR csr_check_empty_le (
         csr_v_legal_employer_id             NUMBER
        ,csr_v_canonical_start_date          DATE
        ,csr_v_canonical_end_date            DATE
      )
      IS
         SELECT   '1'
             FROM pay_payroll_actions appa
                 ,pay_assignment_actions act
                 ,per_all_assignments_f as1
                 ,pay_payroll_actions ppa
            WHERE ppa.payroll_action_id = p_payroll_action_id
              AND appa.effective_date BETWEEN csr_v_canonical_start_date
                                          AND csr_v_canonical_end_date
              AND appa.action_type IN ('R', 'Q')
              -- Payroll Run or Quickpay Run
              AND act.payroll_action_id = appa.payroll_action_id
              AND act.source_action_id IS NULL                -- Master Action
              AND as1.assignment_id = act.assignment_id
              AND as1.business_group_id = g_business_group_id
              AND act.action_status = 'C'                         -- Completed
              AND act.tax_unit_id = csr_v_legal_employer_id
              AND appa.effective_date BETWEEN as1.effective_start_date
                                          AND as1.effective_end_date
              AND ppa.effective_date BETWEEN as1.effective_start_date
                                         AND as1.effective_end_date
         ORDER BY as1.person_id
                 ,act.assignment_id;

      l_le_has_employee          VARCHAR2 (2);
-- Archiving the data , as this will fire once
   BEGIN

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
      g_pension_provider_id := NULL;
      g_legal_employer_id := NULL;
      g_local_unit_id := NULL;
      pay_se_alecta.get_all_parameters (p_payroll_action_id
                                       ,g_business_group_id
                                       ,g_effective_date
                                       ,g_legal_employer_id
                                       ,g_request_for
                                       ,g_year
                                       ,g_month
                                       ,g_sent_from
                                       ,g_sent_to
                                       ,g_production
                                       );


-- *****************************************************************************
 -- TO pick up the required details for Pension Providers
      OPEN csr_legal_employer_details (g_legal_employer_id);

      FETCH csr_legal_employer_details
       INTO l_legal_employer_details;

      CLOSE csr_legal_employer_details;

-- *****************************************************************************

-- *****************************************************************************
      -- Insert the report Parameters
      pay_action_information_api.create_action_information
         (p_action_information_id            => l_action_info_id
         ,p_action_context_id                => p_payroll_action_id
         ,p_action_context_type              => 'PA'
         ,p_object_version_number            => l_ovn
         ,p_effective_date                   => g_effective_date
         ,p_source_id                        => NULL
         ,p_source_text                      => NULL
         ,p_action_information_category      => 'EMEA REPORT DETAILS'
         ,p_action_information1              => 'PYSEALEA'
         ,p_action_information2              => l_legal_employer_details.legal_employer_name
         ,p_action_information3              => g_legal_employer_id
         ,p_action_information4              => g_request_for
         ,p_action_information5              => (g_year)
         ,p_action_information6              => (g_month)
         ,p_action_information7              => g_sent_from
         ,p_action_information8              => g_sent_to
         ,p_action_information9              => g_production
         ,p_action_information10             => l_legal_employer_details.org_number -- changes 2009/2010
         );
-- *****************************************************************************

      --fnd_file.put_line(fnd_file.log,'PENSION provider name ==> '||lr_pension_provider_details.NAME );
      --fnd_file.put_line(fnd_file.log,'PENSION provider ID   ==> '||g_pension_provider_id);

      --fnd_file.put_line(fnd_file.log,'Local Unit ID         ==> '||g_local_unit_id);
      --fnd_file.put_line(fnd_file.log,'acti_info_id          ==> '||l_action_info_id );


-- *****************************************************************************
/*      IF g_request_for = 'REQUESTING_ORG'
      THEN
         -- Information regarding the Legal Employer
         OPEN csr_legal_employer_details (g_legal_employer_id);

         FETCH csr_legal_employer_details
          INTO l_legal_employer_details;

         CLOSE csr_legal_employer_details;

         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id,
             p_action_context_id                => p_payroll_action_id,
             p_action_context_type              => 'PA',
             p_object_version_number            => l_ovn,
             p_effective_date                   => g_effective_date,
             p_source_id                        => NULL,
             p_source_text                      => NULL,
             p_action_information_category      => 'EMEA REPORT INFORMATION',
             p_action_information1              => 'PYSEALEA',
             p_action_information2              => 'LE',
             p_action_information3              => g_legal_employer_id,
             p_action_information4              => l_legal_employer_details.legal_employer_name,
             p_action_information5              => l_legal_employer_details.org_number,
             p_action_information6              => NULL,
             p_action_information7              => NULL,
             p_action_information8              => NULL,
             p_action_information9              => NULL,
             p_action_information10             => NULL
            );
-- *****************************************************************************
      ELSE
-- *****************************************************************************
         FOR rec_legal_employer_details IN csr_legal_employer_details (NULL)
         LOOP
            OPEN csr_check_empty_le (rec_legal_employer_details.legal_id,
                                     g_start_date,
                                     g_end_date
                                    );

            FETCH csr_check_empty_le
             INTO l_le_has_employee;

            CLOSE csr_check_empty_le;

            IF l_le_has_employee = '1'
            THEN
               pay_action_information_api.create_action_information
                  (p_action_information_id            => l_action_info_id,
                   p_action_context_id                => p_payroll_action_id,
                   p_action_context_type              => 'PA',
                   p_object_version_number            => l_ovn,
                   p_effective_date                   => g_effective_date,
                   p_source_id                        => NULL,
                   p_source_text                      => NULL,
                   p_action_information_category      => 'EMEA REPORT INFORMATION',
                   p_action_information1              => 'PYSEALEA',
                   p_action_information2              => 'LE',
                   p_action_information3              => rec_legal_employer_details.legal_id,
                   p_action_information4              => rec_legal_employer_details.legal_employer_name,
                   p_action_information5              => rec_legal_employer_details.org_number,
                   p_action_information6              => NULL,
                   p_action_information7              => NULL,
                   p_action_information8              => NULL,
                   p_action_information9              => NULL,
                   p_action_information10             => NULL
                  );
            END IF;
         END LOOP;
      END IF;                                          -- FOR G_LEGAL_EMPLOYER
*/
      --END IF; -- G_Archive End
      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure RANGE_CODE', 50);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Return cursor that selects no rows
         p_sql :=
               'select 1 from dual where to_char(:payroll_action_id) = dummy';
   END range_code;

   /* ASSIGNMENT ACTION CODE */
   PROCEDURE assignment_action_code (
      p_payroll_action_id        IN       NUMBER
     ,p_start_person             IN       NUMBER
     ,p_end_person               IN       NUMBER
     ,p_chunk                    IN       NUMBER
   )
   IS
      CURSOR csr_prepaid_assignments_le (
         p_payroll_action_id                 NUMBER
        ,p_start_person                      NUMBER
        ,p_end_person                        NUMBER
        ,p_legal_employer_id                 NUMBER
        ,l_canonical_start_date              DATE
        ,l_canonical_end_date                DATE
      )
      IS
         SELECT   as1.person_id person_id
                 ,act.assignment_id assignment_id
                 ,act.assignment_action_id run_action_id
             FROM pay_payroll_actions appa
                 ,pay_assignment_actions act
                 ,per_all_assignments_f as1
                 ,pay_payroll_actions ppa
            WHERE ppa.payroll_action_id = p_payroll_action_id
              AND appa.effective_date BETWEEN l_canonical_start_date
                                          AND l_canonical_end_date
              AND as1.person_id BETWEEN p_start_person AND p_end_person
              AND appa.action_type IN ('R', 'Q')
              -- Payroll Run or Quickpay Run
              AND act.payroll_action_id = appa.payroll_action_id
              AND act.source_action_id IS NULL                -- Master Action
              AND as1.assignment_id = act.assignment_id
              AND as1.business_group_id = g_business_group_id
              AND act.action_status = 'C'                         -- Completed
              AND act.tax_unit_id = NVL (p_legal_employer_id, act.tax_unit_id)
              AND appa.effective_date BETWEEN as1.effective_start_date
                                          AND as1.effective_end_date
--              AND ppa.effective_date BETWEEN as1.effective_start_date AND as1.effective_end_date
         ORDER BY as1.person_id
                 ,act.assignment_id;

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name                  ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue
               ,ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'SE'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';

      lr_get_defined_balance_id   csr_get_defined_balance_id%ROWTYPE;
      l_count                     NUMBER                                  := 0;
      l_prev_prepay               NUMBER                                  := 0;
      l_canonical_start_date      DATE;
      l_canonical_end_date        DATE;
      l_pension_type              hr_organization_information.org_information1%TYPE;
      l_prepay_action_id          NUMBER;
      l_actid                     NUMBER;
      l_assignment_id             NUMBER;
      l_action_sequence           NUMBER;
      l_assact_id                 NUMBER;
      l_pact_id                   NUMBER;
      l_flag                      NUMBER                                  := 0;
      l_defined_balance_id        NUMBER                                  := 0;
      l_action_info_id            NUMBER;
      l_ovn                       NUMBER;
-- User pARAMETERS needed
      l_business_group_id         NUMBER;
      l_effective_date            DATE;
      l_pension_provider_id       NUMBER;
      l_legal_employer_id         NUMBER;
      l_local_unit_id             NUMBER;
      l_archive                   VARCHAR2 (10);
-- End of User pARAMETERS needed
   BEGIN
--      fnd_file.put_line (fnd_file.LOG, ' ASSIGNMENT_ACTION_CODE ');
      pay_se_alecta.get_all_parameters (p_payroll_action_id
                                       ,g_business_group_id
                                       ,g_effective_date
                                       ,g_legal_employer_id
                                       ,g_request_for
                                       ,g_year
                                       ,g_month
                                       ,g_sent_from
                                       ,g_sent_to
                                       ,g_production
                                       );
--fnd_file.put_line(fnd_file.log,' g_year '|| g_year);
--fnd_file.put_line(fnd_file.log,' g_month '|| g_month);
      l_canonical_start_date :=
         fnd_date.string_to_date (('01-' || TRUNC (g_month) || '-' || g_year)
                                 ,'DD-MM-YYYY'
                                 );
      l_canonical_end_date := LAST_DAY (l_canonical_start_date);
      l_prepay_action_id := 0;
      --fnd_file.put_line(fnd_file.log,' g_local_unit_id '|| g_local_unit_id);

      --fnd_file.put_line(fnd_file.log,' INSIDE IF LOCAL UNIT NOT NULL ');
/*
      fnd_file.put_line (fnd_file.LOG,
                         ' p_payroll_action_id ==> ' || p_payroll_action_id
                        );
      fnd_file.put_line (fnd_file.LOG,
                         ' g_legal_employer_id ==> ' || g_legal_employer_id
                        );
      fnd_file.put_line (fnd_file.LOG,
                         ' g_effective_date ==> ' || g_effective_date
                        );
      fnd_file.put_line (fnd_file.LOG,
                            ' l_canonical_start_date ==> '
                         || l_canonical_start_date
                        );
      fnd_file.put_line (fnd_file.LOG,
                         ' l_canonical_end_date ==> ' || l_canonical_end_date
                        );
*/
      --fnd_file.put_line(fnd_file.log,' INSIDE ELS LOCAL UNIT NULL ');
      l_assignment_id := 0;

      FOR rec_prepaid_assignments IN
         csr_prepaid_assignments_le (p_payroll_action_id
                                    ,p_start_person
                                    ,p_end_person
                                    ,g_legal_employer_id
                                    ,l_canonical_start_date
                                    ,l_canonical_end_date
                                    )
      LOOP
         IF l_assignment_id <> rec_prepaid_assignments.assignment_id
         THEN
            SELECT pay_assignment_actions_s.NEXTVAL
              INTO l_actid
              FROM DUAL;

            -- Create the archive assignment action
            hr_nonrun_asact.insact (l_actid
                                   ,rec_prepaid_assignments.assignment_id
                                   ,p_payroll_action_id
                                   ,p_chunk
                                   ,NULL
                                   );
         -- Create archive to prepayment assignment action interlock
         --
         --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
         END IF;

         -- create archive to master assignment action interlock
         --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
         l_assignment_id := rec_prepaid_assignments.assignment_id;
      END LOOP;
/*
      fnd_file.put_line
                     (fnd_file.LOG,
                      ' After Ending Assignment Act Code  the Locking Cursor '
                     );
*/
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('error raised assignment_action_code '
                                    ,5
                                    );
         END IF;

         RAISE;
   END assignment_action_code;

/*fffffffffffffffffffffffffff*/

   /* INITIALIZATION CODE */
   PROCEDURE initialization_code (p_payroll_action_id IN NUMBER)
   IS
      l_action_info_id       NUMBER;
      l_ovn                  NUMBER;
      l_count                NUMBER                          := 0;
      l_business_group_id    NUMBER;
      l_start_date           VARCHAR2 (20);
      l_end_date             VARCHAR2 (20);
      l_effective_date       DATE;
      l_payroll_id           NUMBER;
      l_consolidation_set    NUMBER;
      l_prev_prepay          NUMBER                          := 0;

      CURSOR csr_get_all_legal_employer_id
      IS
         SELECT o.organization_id
           FROM hr_all_organization_units o
               ,hr_organization_information hoi1
          WHERE o.business_group_id = g_business_group_id
            AND hoi1.organization_id = o.organization_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
/*            AND o.organization_id =
                   DECODE (g_request_for
                          ,'ALL_ORG', o.organization_id
                          ,g_legal_employer_id
                          ) */
      ;

      CURSOR csr_get_all_fields
      IS
         SELECT   h.lookup_code
             FROM hr_lookups h
            WHERE h.lookup_type = 'HR_SE_ALECTA_FIELDS'
              AND h.enabled_flag = 'Y'
         ORDER BY h.meaning;

      CURSOR csr_get_all_events (csr_v_fields VARCHAR2)
      IS
         SELECT   h.lookup_code
             FROM hr_lookups h
            WHERE h.lookup_type = 'HR_SE_EVENT'
              AND h.enabled_flag = 'Y'
              AND (   (    SUBSTR (csr_v_fields, 1, 2) = 'ET'
                       AND (lookup_code <> 'FK')
                      )
                   OR (    SUBSTR (csr_v_fields, 1, 2) = 'MS'
                       AND lookup_code IN ('IN', 'FK', 'LO')
                      )
                   OR (    SUBSTR (csr_v_fields, 1, 2) = 'TR'
                       AND lookup_code IN ('AV2', 'AV3', 'AV4')
                      )
                   OR (    SUBSTR (csr_v_fields, 1, 2) = 'PL'
                       AND (lookup_code = 'AV2')
                      )
                  )
         ORDER BY h.meaning;

      CURSOR csr_get_le_event_info (
         csr_v_le                            NUMBER
        ,csr_v_name                          VARCHAR2
        ,csr_v_event                         VARCHAR2
      )
      IS
         SELECT o.organization_id
               ,hoi3.org_information1
               ,hoi3.org_information2
               ,hoi3.org_information3
               ,hoi3.org_information4
               ,hoi3.org_information5
               ,hoi3.org_information6
               ,hoi3.org_information7
               ,hoi3.org_information8
           FROM hr_all_organization_units o
               ,hr_organization_information hoi1
               ,hr_organization_information hoi3
          WHERE o.business_group_id = g_business_group_id
            AND hoi1.organization_id = o.organization_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o.organization_id = csr_v_le
            AND o.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'SE_ALECTA_MAPPING'
            AND hoi3.org_information1 = csr_v_name
            AND hoi3.org_information2 = csr_v_event;

      lr_get_le_event_info   csr_get_le_event_info%ROWTYPE;
      l_temp_counter         VARCHAR2 (200);
      l_temp_field           VARCHAR2 (200);
      l_temp_event           VARCHAR2 (200);
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure INITIALIZATION_CODE'
                                 ,80
                                 );
      END IF;


      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_legal_employer_id := NULL;
      pay_se_alecta.get_all_parameters (p_payroll_action_id
                                       ,g_business_group_id
                                       ,g_effective_date
                                       ,g_legal_employer_id
                                       ,g_request_for
                                       ,g_year
                                       ,g_month
                                       ,g_sent_from
                                       ,g_sent_to
                                       ,g_production
                                       );

      g_start_date :=
         fnd_date.string_to_date (('01-' || TRUNC (g_month) || '-' || g_year)
                                 ,'DD-MM-YYYY'
                                 );
      g_end_date := LAST_DAY (g_start_date);

      l_count := 1;

      FOR row_legal_emp_id IN csr_get_all_legal_employer_id
      LOOP

         record_legal_employer (row_legal_emp_id.organization_id).organization_id :=
                                             row_legal_emp_id.organization_id;

         FOR row_get_all_fields IN csr_get_all_fields
         LOOP
            record_legal_employer (row_legal_emp_id.organization_id).field_code
                                              (row_get_all_fields.lookup_code).disp_name :=
                                               row_get_all_fields.lookup_code;
            lr_get_le_event_info := NULL;

            FOR row_get_all_events IN
               csr_get_all_events (row_get_all_fields.lookup_code)
            LOOP
               record_legal_employer (row_legal_emp_id.organization_id).field_code
                                              (row_get_all_fields.lookup_code).events_row
                                              (row_get_all_events.lookup_code).event_code :=
                                               row_get_all_events.lookup_code;

               OPEN csr_get_le_event_info (row_legal_emp_id.organization_id
                                          ,row_get_all_fields.lookup_code
                                          ,row_get_all_events.lookup_code
                                          );

               FETCH csr_get_le_event_info
                INTO lr_get_le_event_info;

               CLOSE csr_get_le_event_info;

               record_legal_employer (row_legal_emp_id.organization_id).field_code
                                               (row_get_all_fields.lookup_code).events_row
                                               (row_get_all_events.lookup_code).bal_ele :=
                                         lr_get_le_event_info.org_information3;
               record_legal_employer (row_legal_emp_id.organization_id).field_code
                                               (row_get_all_fields.lookup_code).events_row
                                               (row_get_all_events.lookup_code).balance_type_id :=
                                         lr_get_le_event_info.org_information8;
               record_legal_employer (row_legal_emp_id.organization_id).field_code
                                               (row_get_all_fields.lookup_code).events_row
                                               (row_get_all_events.lookup_code).element_type_id :=
                                         lr_get_le_event_info.org_information5;
               record_legal_employer (row_legal_emp_id.organization_id).field_code
                                               (row_get_all_fields.lookup_code).events_row
                                               (row_get_all_events.lookup_code).input_value_id :=
                                         lr_get_le_event_info.org_information6;
		lr_get_le_event_info:=NULL;
            END LOOP;
         END LOOP;
      END LOOP;
/*
      l_temp_counter := RECORD_LEGAL_EMPLOYER.FIRST;

      WHILE l_temp_counter IS NOT NULL
      LOOP
logger ('EACH LE' ,RECORD_LEGAL_EMPLOYER (l_temp_counter).organization_id );
l_temp_field := RECORD_LEGAL_EMPLOYER(l_temp_counter).FIELD_CODE.FIRST;
        while l_temp_field IS NOT NULL
        Loop
logger ('FIELD ' ,RECORD_LEGAL_EMPLOYER(l_temp_counter).
FIELD_CODE(l_temp_field).DISP_NAME );

l_temp_event :=RECORD_LEGAL_EMPLOYER(l_temp_counter).
FIELD_CODE(l_temp_field).
EVENTS_ROW.FIRST;
        while l_temp_event IS NOT NULL
        LOOP
logger ('         EVENT' ,RECORD_LEGAL_EMPLOYER(l_temp_counter).
FIELD_CODE(l_temp_field).
EVENTS_ROW(l_temp_event).EVENT_CODE  );
l_temp_event :=RECORD_LEGAL_EMPLOYER(l_temp_counter).FIELD_CODE(l_temp_field).
EVENTS_ROW.NEXT(l_temp_event);
        END LOOP;
l_temp_field :=RECORD_LEGAL_EMPLOYER(l_temp_counter).FIELD_CODE.NEXT(l_temp_field);
        END LOOP;
         l_temp_counter := RECORD_LEGAL_EMPLOYER.NEXT (l_temp_counter);
      END LOOP;
*/
   EXCEPTION
      WHEN OTHERS
      THEN
         g_err_num := SQLCODE;

         IF g_debug
         THEN
            hr_utility.set_location (   'ORA_ERR: '
                                     || g_err_num
                                     || 'In INITIALIZATION_CODE'
                                    ,180
                                    );
         END IF;
   END initialization_code;

   /* GET DEFINED BALANCE ID */
   FUNCTION get_defined_balance_id (p_user_name IN VARCHAR2)
      RETURN NUMBER
   IS
      /* Cursor to retrieve Defined Balance Id */
      CURSOR csr_def_bal_id (p_user_name VARCHAR2)
      IS
         SELECT u.creator_id
           FROM ff_user_entities u
               ,ff_database_items d
          WHERE d.user_name = p_user_name
            AND u.user_entity_id = d.user_entity_id
            AND (u.legislation_code = 'SE')
            AND (u.business_group_id IS NULL)
            AND u.creator_type = 'B';

      l_defined_balance_id   ff_user_entities.user_entity_id%TYPE;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location
                                (' Entering Function GET_DEFINED_BALANCE_ID'
                                ,240
                                );
      END IF;

      OPEN csr_def_bal_id (p_user_name);

      FETCH csr_def_bal_id
       INTO l_defined_balance_id;

      CLOSE csr_def_bal_id;

      RETURN l_defined_balance_id;

      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Function GET_DEFINED_BALANCE_ID'
                                 ,250
                                 );
      END IF;
   END get_defined_balance_id;

   FUNCTION get_defined_balance_value (
      p_balance_type_id          IN       NUMBER
     ,p_dimension                IN       VARCHAR2
     ,p_in_assignment_id         IN       NUMBER
     ,p_in_virtual_date          IN       DATE
   )
      RETURN NUMBER
   IS
      CURSOR csr_defined_balance_id
      IS
         SELECT db.defined_balance_id
           FROM pay_defined_balances db
               ,pay_balance_dimensions bd
          WHERE db.balance_type_id = p_balance_type_id
            AND db.balance_dimension_id = bd.balance_dimension_id
            AND bd.database_item_suffix = p_dimension
            AND bd.legislation_code = 'SE';

      l_defined_balance_id     ff_user_entities.user_entity_id%TYPE;
      l_return_balance_value   NUMBER;
   BEGIN
      IF p_balance_type_id IS NOT NULL
      THEN
--      pay_balance_pkg.set_context ('TAX_UNIT_ID', p_tax_unit_id);
--      pay_balance_pkg.set_context ('LOCAL_UNIT_ID', p_local_unit_id);
         OPEN csr_defined_balance_id;

         FETCH csr_defined_balance_id
          INTO l_defined_balance_id;

         CLOSE csr_defined_balance_id;

         l_return_balance_value :=
            TO_CHAR
               (pay_balance_pkg.get_value
                                (p_defined_balance_id      => l_defined_balance_id
                                ,p_assignment_id           => p_in_assignment_id
                                ,p_virtual_date            => p_in_virtual_date
                                )
               ,'999999999D99'
               );
      ELSE
         l_return_balance_value := 0;
      END IF;

      RETURN l_return_balance_value;
   END get_defined_balance_value;

   /* ARCHIVE CODE */
   PROCEDURE archive_code (
      p_assignment_action_id     IN       NUMBER
     ,p_effective_date           IN       DATE
   )
   IS
      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name                  ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue
               ,ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'SE'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';

      lr_get_defined_balance_id     csr_get_defined_balance_id%ROWTYPE;
      l_actid                       NUMBER;
      l_end_date                    per_time_periods.end_date%TYPE;
      l_date_earned                 pay_payroll_actions.date_earned%TYPE;
      l_effective_date              pay_payroll_actions.effective_date%TYPE;
      l_start_date                  per_time_periods.start_date%TYPE;
      l_action_info_id              pay_action_information.action_information_id%TYPE;
      l_ovn                         pay_action_information.object_version_number%TYPE;
      l_flag                        NUMBER                                := 0;
      -- The place for Variables which fetches the values to be archived
      l_employee_number             VARCHAR2 (240);
      l_employee_code               VARCHAR2 (240);
      l_new_entry                   VARCHAR2 (240);
      l_moving_company              VARCHAR2 (240);
      l_new_salary                  VARCHAR2 (240);
      l_withdrawal                  VARCHAR2 (240);
      l_organization_number         VARCHAR2 (240);
      l_cost_centre                 VARCHAR2 (240);
      l_agreement_plan_id           VARCHAR2 (240);
      l_employee_pin                VARCHAR2 (240);
      l_alecta_itp_detail           VARCHAR2 (20);  -- Changes 2008/2009
      l_time_for_event_in           DATE;
      l_time_for_event_fk           DATE;
      l_time_for_event_lo           DATE;
      l_time_for_event_av           DATE;
      l_last_name                   VARCHAR2 (240);
      l_first_name                  VARCHAR2 (240);
      l_before_after                VARCHAR2 (240);
      l_monthly_salary_in           NUMBER                                := 0;
      l_monthly_salary_fk           NUMBER                                := 0;
      l_monthly_salary_lo           NUMBER                                := 0;
      l_fully_capable_of_work       VARCHAR2 (20);
      l_inability_to_work           VARCHAR2 (20);
      l_prev_organization_number    VARCHAR2 (100);
      l_curr_organization_number    VARCHAR2 (100);
      l_prev_cost_center            VARCHAR2 (240);
      l_curr_cost_center            VARCHAR2 (240);
      l_reason_for_termination      VARCHAR2 (240);
      l_yearly_salary_in            NUMBER                                := 0;
      l_yearly_salary_fk            NUMBER                                := 0;
      l_yearly_salary_lo            NUMBER                                := 0;
      l_salary_cut                  VARCHAR2 (240);
      l_start_parental_leave        DATE;
      l_action_id                   VARCHAR2 (2);
      l_local_unit_id_fetched       NUMBER;
      l_eit_local_unit              NUMBER;
      l_legal_employer_id_fetched   NUMBER;
      l_sw_dim_ytd                  NUMBER                                :=0;   -- Changes 2008/2009
      l_sal_withdrawal              NUMBER                                :=0;   -- Changes 2008/2009
      l_annual_salary_in            NUMBER                                :=0;  -- Changes 2008/2009
      l_annual_salary_lo            NUMBER                                :=0;  -- Changes 2008/2009
      l_annual_salary_fk            NUMBER                                :=0;  -- Changes 2008/2009

      -- Temp needed Variables
      l_person_id                   per_all_people_f.person_id%TYPE;
      l_assignment_id               per_all_assignments_f.assignment_id%TYPE;

      -- Temp needed Variables

      -- End of place for Variables which fetches the values to be archived

      -- The place for Cursor  which fetches the values to be archived

      --
            -- Cursor to pick up

      /* Cursor to retrieve Person Details */
      CURSOR csr_get_assignment_id (p_asg_act_id NUMBER)
      IS
         SELECT pac.assignment_id
           FROM pay_assignment_actions pac
          WHERE pac.assignment_action_id = p_asg_act_id;

      CURSOR csr_get_person_details (p_asg_act_id NUMBER)
      IS
         SELECT pap.last_name
               ,pap.pre_name_adjunct
               ,pap.first_name
               ,pap.national_identifier
               ,pap.person_id
               ,pac.assignment_id
               ,paa.assignment_number
               ,paa.employee_category
               ,paa.effective_start_date
           FROM pay_assignment_actions pac
               ,per_all_assignments_f paa
               ,per_all_people_f pap
          WHERE pac.assignment_action_id = p_asg_act_id
            AND paa.assignment_id = pac.assignment_id
            AND paa.person_id = pap.person_id
            AND pap.per_information_category = 'SE'
            AND p_effective_date BETWEEN pap.effective_start_date
                                     AND pap.effective_end_date
            AND p_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date;

      lr_get_person_details         csr_get_person_details%ROWTYPE;

      -- Cursor to pick up segment2
      CURSOR csr_get_segment2
      IS
         SELECT scl.segment2
               ,scl.segment8
           FROM per_all_assignments_f paa
               ,hr_soft_coding_keyflex scl
               ,pay_assignment_actions pasa
          WHERE pasa.assignment_action_id = p_assignment_action_id
            AND pasa.assignment_id = paa.assignment_id
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
--            AND paa.primary_flag = 'Y'
            AND p_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date;

      lr_get_segment2               csr_get_segment2%ROWTYPE;

      -- Cursor to pick up LEGAL EMPLOYER
      CURSOR csr_find_legal_employer (
         csr_v_organization_id               hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hoi3.organization_id legal_id
           FROM hr_all_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_organization_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER';

      lr_find_legal_employer        csr_find_legal_employer%ROWTYPE;

-- Cursor to pick up Local Unit Details
      CURSOR csr_local_unit_details (
         csr_v_local_unit_id                 hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT o1.NAME
               ,hoi2.org_information1
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_local_unit_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_LOCAL_UNIT_DETAILS';

      lr_local_unit_details         csr_local_unit_details%ROWTYPE;

      CURSOR csr_new_joinee (csr_v_assignment_id NUMBER)
      IS
         SELECT COUNT ('1') "RECORD_FOUND"
           FROM per_all_assignments_f
          WHERE assignment_id = csr_v_assignment_id
            AND business_group_id = g_business_group_id
            AND effective_start_date < g_start_date;

      lr_new_joinee                 csr_new_joinee%ROWTYPE;

      CURSOR csr_agreement_plan (csr_v_assignment_id NUMBER)
      IS
         SELECT hr_general.decode_lookup ('SE_AGREEMENT_PLAN'
                                         ,aei_information1
                                         ) "AGREEMENT"
           FROM per_assignment_extra_info
          WHERE assignment_id = csr_v_assignment_id
            AND information_type = 'SE_ALECTA_DETAILS';

 -- Start Changes 2008/2009

  CURSOR csr_alecta_itp_details (csr_v_assignment_id NUMBER)
      IS
         SELECT hr_general.decode_lookup ('SE_ALECTA_ITP_DETAILS'
                                         ,aei_information2
                                         )
           FROM per_assignment_extra_info
          WHERE assignment_id = csr_v_assignment_id
            AND information_type = 'SE_ALECTA_DETAILS';
 -- End Changes 2008/2009

      CURSOR csr_get_joining_date (csr_v_assignment_id NUMBER)
      IS
         SELECT   effective_start_date
                 ,effective_end_date
             FROM per_all_assignments_f
            WHERE assignment_id = csr_v_assignment_id
              AND business_group_id = g_business_group_id
              AND effective_start_date >= g_start_date
              AND effective_start_date <= g_end_date
--AND rownum =1
         ORDER BY effective_start_date ASC;

      lr_get_joining_date           csr_get_joining_date%ROWTYPE;

      CURSOR csr_get_person_id (csr_v_assignment_id NUMBER)
      IS
         SELECT paaf.person_id
           FROM per_all_assignments_f paaf
          WHERE paaf.assignment_id = csr_v_assignment_id
            AND paaf.effective_start_date <= g_end_date;

      lr_get_person_id              csr_get_person_id%ROWTYPE;

      CURSOR csr_get_assignments (csr_v_assignment_id NUMBER)
      IS
         SELECT   GREATEST (effective_start_date, g_start_date)
                                                         effective_start_date
                 ,LEAST (effective_end_date, g_end_date) effective_end_date
             FROM per_all_assignments_f
            WHERE assignment_id = csr_v_assignment_id
              AND business_group_id = g_business_group_id
              AND effective_start_date BETWEEN g_start_date AND g_end_date
         ORDER BY effective_end_date DESC;

      lr_get_assignments            csr_get_assignments%ROWTYPE;
      -- End of Cursors
      l_current_local_unit          NUMBER;
      l_previous_local_unit         NUMBER;
      l_current_location_id         NUMBER;
      l_previous_location_id        NUMBER;
      l_current_legal_employer      NUMBER;
      l_previous_legal_employer     NUMBER;
      l_joining_date                DATE;
      l_period_start_date           DATE;
      l_period_end_date             DATE;
-- Cursor to pick up the Absence details
--#########################################

   -- End of place for Cursor  which fetches the values to be archived
   BEGIN



-- *****************************************************************************
   -- TO pick up Assignmnet ID
      OPEN csr_get_assignment_id (p_assignment_action_id);

      FETCH csr_get_assignment_id
       INTO l_assignment_id;

      CLOSE csr_get_assignment_id;



      OPEN csr_get_person_id (l_assignment_id);

      FETCH csr_get_person_id
       INTO lr_get_person_id;

      CLOSE csr_get_person_id;


      l_person_id := lr_get_person_id.person_id;

      OPEN csr_agreement_plan (l_assignment_id);

      FETCH csr_agreement_plan
       INTO l_agreement_plan_id;

      CLOSE csr_agreement_plan;

-- Start Changes 2008/2009

     OPEN csr_alecta_itp_details(l_assignment_id);

      FETCH csr_alecta_itp_details
       INTO l_alecta_itp_detail;

     CLOSE csr_alecta_itp_details;


   l_sw_dim_ytd := defined_balance_id('Gross Salary Withdrawal','_ASG_YTD');
   l_sal_withdrawal := nvl(pay_balance_pkg.get_value(l_sw_dim_ytd, l_assignment_id,p_effective_date),0);

-- End Changes 2008/2009

-- New Entry

      OPEN csr_new_joinee (l_assignment_id);

      FETCH csr_new_joinee
       INTO lr_new_joinee;

      CLOSE csr_new_joinee;


      IF lr_new_joinee.record_found <= 0
      THEN
         l_new_entry := 'IN';
      ELSE
         l_new_entry := NULL;
      END IF;



      IF l_new_entry = 'IN'
      THEN


         OPEN csr_get_joining_date (l_assignment_id);

         FETCH csr_get_joining_date
          INTO lr_get_joining_date;

         CLOSE csr_get_joining_date;

         l_joining_date := lr_get_joining_date.effective_start_date;
         get_assignment_lvl_info (l_assignment_id
                                 ,l_joining_date
                                 ,l_organization_number
                                 ,l_cost_centre
                                 );
         get_person_lvl_info (l_assignment_id
                             ,l_joining_date
                             ,l_employee_pin
                             ,l_first_name
                             ,l_last_name
                             ,l_before_after
                             );

         get_in_time_of_event (l_assignment_id
                              ,l_joining_date
                              ,l_time_for_event_in
                              );

         get_salary (l_assignment_id
                    ,l_joining_date
                    ,l_before_after
                    ,l_new_entry
                    ,l_monthly_salary_in
                    ,l_yearly_salary_in
		    ,l_annual_salary_in  -- Changes 2008/2009
                    );

         get_absence_lvl_info (l_assignment_id
                              ,l_joining_date
                              ,l_fully_capable_of_work
                              ,l_inability_to_work
                              );



      END IF;

/* **********************************************************************************/
      IF l_new_entry IS NOT NULL
      THEN
         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_assignment_action_id
            ,p_action_context_type              => 'AAP'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => l_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEALEA'
            ,p_action_information2              => 'PER'
            ,p_action_information3              => g_payroll_action_id
            ,p_action_information4              => l_new_entry
            ,p_action_information5              => l_organization_number
            ,p_action_information6              => l_cost_centre
            ,p_action_information7              => l_agreement_plan_id
            ,p_action_information8              => l_employee_pin
            ,p_action_information9              => fnd_date.date_to_canonical
                                                          (l_time_for_event_in)
            ,p_action_information10             => l_last_name
            ,p_action_information11             => l_first_name
            ,p_action_information12             => l_before_after
            ,p_action_information13             => fnd_number.number_to_canonical
                                                           (l_yearly_salary_in)
            ,p_action_information14             => fnd_number.number_to_canonical
                                                          (l_monthly_salary_in)
            ,p_action_information15             => l_fully_capable_of_work
            ,p_action_information16             => /*NVL */(l_inability_to_work)
                                                       /*,'0'
                                                       ) */
            ,p_action_information17             => l_alecta_itp_detail  -- changes 2008/2009
            ,p_action_information18             => fnd_number.number_to_canonical
						     (l_sal_withdrawal)    -- changes 2008/2009
            ,p_action_information19             => fnd_number.number_to_canonical
						    (l_annual_salary_in)        --Changes 2008/2009
            ,p_action_information20             => NULL
            ,p_action_information21             => NULL
            ,p_action_information22             => NULL
            ,p_action_information23             => NULL
            ,p_action_information24             => NULL
            ,p_action_information25             => NULL
            ,p_action_information26             => NULL
            ,p_action_information27             => NULL
            ,p_action_information28             => NULL
            ,p_action_information29             => NULL
            ,p_action_information30             => l_person_id
            ,p_assignment_id                    => l_assignment_id
            );

      END IF;

/* *****************************************************************************/
     -- Change in Company
      FOR row_get_assignments IN csr_get_assignments (l_assignment_id)
      LOOP

         l_current_local_unit := NULL;
         l_current_legal_employer := NULL;
         l_current_location_id := NULL;
         l_previous_local_unit := NULL;
         l_previous_legal_employer := NULL;
         l_previous_location_id := NULL;
         get_org_lvl_info (l_assignment_id
                          ,row_get_assignments.effective_start_date
                          ,l_current_local_unit
                          ,l_current_legal_employer
                          ,l_current_location_id
                          );
         get_org_lvl_info (l_assignment_id
                          , (row_get_assignments.effective_start_date) - 1
                          ,l_previous_local_unit
                          ,l_previous_legal_employer
                          ,l_previous_location_id
                          );

         l_moving_company := NULL;

         IF l_current_legal_employer <> l_previous_legal_employer
         THEN
            l_moving_company := 'FK';
            l_time_for_event_fk := row_get_assignments.effective_start_date;
            get_assignment_lvl_info (l_assignment_id
                                    ,row_get_assignments.effective_start_date
                                    ,l_curr_organization_number
                                    ,l_curr_cost_center
                                    );
            get_assignment_lvl_info
                                  (l_assignment_id
                                  ,   (row_get_assignments.effective_start_date
                                      )
                                    - 1
                                  ,l_prev_organization_number
                                  ,l_prev_cost_center
                                  );
            get_person_lvl_info (l_assignment_id
                                ,row_get_assignments.effective_start_date
                                ,l_employee_pin
                                ,l_first_name
                                ,l_last_name
                                ,l_before_after
                                );
            get_salary (l_assignment_id
                       ,g_end_date
                       ,l_before_after
                       ,l_moving_company
                       ,l_monthly_salary_fk
                       ,l_yearly_salary_fk
		       ,l_annual_salary_fk -- Changes 2008/2009
                       );
            get_absence_lvl_info (l_assignment_id
                                 ,g_end_date
                                 ,l_fully_capable_of_work
                                 ,l_inability_to_work
                                 );
/* **********************************************************************************/
            pay_action_information_api.create_action_information
               (p_action_information_id            => l_action_info_id
               ,p_action_context_id                => p_assignment_action_id
               ,p_action_context_type              => 'AAP'
               ,p_object_version_number            => l_ovn
               ,p_effective_date                   => l_effective_date
               ,p_source_id                        => NULL
               ,p_source_text                      => NULL
               ,p_action_information_category      => 'EMEA REPORT INFORMATION'
               ,p_action_information1              => 'PYSEALEA'
               ,p_action_information2              => 'PER'
               ,p_action_information3              => g_payroll_action_id
               ,p_action_information4              => l_moving_company
               ,p_action_information5              => l_curr_organization_number
               ,p_action_information6              => l_curr_cost_center
               ,p_action_information7              => l_agreement_plan_id
               ,p_action_information8              => l_employee_pin
               ,p_action_information9              => fnd_date.date_to_canonical
                                                          (l_time_for_event_fk)
               ,p_action_information10             => l_before_after
               ,p_action_information11             => fnd_number.number_to_canonical
                                                           (l_yearly_salary_fk)
               ,p_action_information12             => fnd_number.number_to_canonical
                                                          (l_monthly_salary_fk)
               ,p_action_information13             => l_fully_capable_of_work
               ,p_action_information14             =>/* NVL*/
                                                         (l_inability_to_work)
                                                         /*,'0'
                                                         ) */
               ,p_action_information15             => l_prev_organization_number
               ,p_action_information16             => l_prev_cost_center
               ,p_action_information17             => NULL
               ,p_action_information18             => NULL
               ,p_action_information19             => NULL
               ,p_action_information20             => NULL
               ,p_action_information21             => NULL
               ,p_action_information22             => NULL
               ,p_action_information23             => NULL
               ,p_action_information24             => NULL
               ,p_action_information25             => NULL
               ,p_action_information26             => NULL
               ,p_action_information27             => NULL
               ,p_action_information28             => NULL
               ,p_action_information29             => NULL
               ,p_action_information30             => l_person_id
               ,p_assignment_id                    => l_assignment_id
               );



-- Changes 2008/2009
-- The Monthly and Annual Salary is removed from 'moving within a group of companies'
-- If salary should be reported when moving , report salary seperately using event 'Salary change'
   get_salary_change_or_not (l_assignment_id
                               ,l_new_salary
                               ,l_time_for_event_lo
                               );

      IF     l_new_salary IS NOT NULL
         AND l_new_salary = 'LO'
         AND l_new_entry IS NULL
      THEN

         get_assignment_lvl_info (l_assignment_id
                                 ,g_end_date
                                 ,l_organization_number
                                 ,l_cost_centre
                                 );

         get_person_lvl_info (l_assignment_id
                             ,g_end_date
                             ,l_employee_pin
                             ,l_first_name
                             ,l_last_name
                             ,l_before_after
                             );

         get_salary (l_assignment_id
                    ,g_end_date
                    ,l_before_after
                    ,l_new_salary
                    ,l_monthly_salary_lo
                    ,l_yearly_salary_lo
		    ,l_annual_salary_lo   -- changes 2008/2009
                    );

         IF l_before_after = 'BEFORE'
         THEN
            get_salary_cut (l_assignment_id, g_end_date, l_salary_cut);
         ELSE
            l_salary_cut := NULL;
         END IF;


         get_absence_lvl_info (l_assignment_id
                              ,g_end_date
                              ,l_fully_capable_of_work
                              ,l_inability_to_work
                              );


      END IF;


      IF l_new_salary IS NOT NULL
      THEN
         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_assignment_action_id
            ,p_action_context_type              => 'AAP'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => l_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEALEA'
            ,p_action_information2              => 'PER'
            ,p_action_information3              => g_payroll_action_id
            ,p_action_information4              => l_new_salary
            ,p_action_information5              => l_organization_number
            ,p_action_information6              => l_cost_centre
            ,p_action_information7              => l_employee_pin
            ,p_action_information8              => fnd_date.date_to_canonical
                                                          (l_time_for_event_lo)
            ,p_action_information9              => l_before_after
            ,p_action_information10             => fnd_number.number_to_canonical
                                                           (l_yearly_salary_lo)
            ,p_action_information11             => fnd_number.number_to_canonical
                                                          (l_monthly_salary_lo)
            ,p_action_information12             => l_salary_cut
            ,p_action_information13             => /*NVL*/ (l_inability_to_work)
                                                       /*,'0'
                                                       ) */
            ,p_action_information14             => fnd_number.number_to_canonical
						    (l_sal_withdrawal)   -- Changes 2008/2009
            ,p_action_information15             => fnd_number.number_to_canonical
						    (l_annual_salary_lo)     -- Changes 2008/2009
            ,p_action_information16             => NULL
            ,p_action_information17             => NULL
            ,p_action_information18             => NULL
            ,p_action_information19             => NULL
            ,p_action_information20             => NULL
            ,p_action_information21             => NULL
            ,p_action_information22             => NULL
            ,p_action_information23             => NULL
            ,p_action_information24             => NULL
            ,p_action_information25             => NULL
            ,p_action_information26             => NULL
            ,p_action_information27             => NULL
            ,p_action_information28             => NULL
            ,p_action_information29             => NULL
            ,p_action_information30             => l_person_id
            ,p_assignment_id                    => l_assignment_id
            );

      END IF;   -- End of change of salary when moving company
-- End Changes - 2008/2009
/* *****************************************************************************/
         END IF;
      END LOOP;  -- End of Moving Company

/********************************************************************************/
-- Changes 2008/2009
-- Adding the Logic - If there is a event 'Moving company' and 'Change of Salary'
-- It will be archived along with 'Moving Company'
--  Here we archive 'Change of Salary' when there is no event 'Moving Company'



-- If the event 'change of Company' doesnt occur - archive the 'Change of Salary' event
 IF l_moving_company IS NULL
    THEN
-- End changes 2008/2009
      get_salary_change_or_not (l_assignment_id
                               ,l_new_salary
                               ,l_time_for_event_lo
                               );

      IF     l_new_salary IS NOT NULL
         AND l_new_salary = 'LO'
         AND l_new_entry IS NULL
      THEN

         get_assignment_lvl_info (l_assignment_id
                                 ,g_end_date
                                 ,l_organization_number
                                 ,l_cost_centre
                                 );

         get_person_lvl_info (l_assignment_id
                             ,g_end_date
                             ,l_employee_pin
                             ,l_first_name
                             ,l_last_name
                             ,l_before_after
                             );

         get_salary (l_assignment_id
                    ,g_end_date
                    ,l_before_after
                    ,l_new_salary
                    ,l_monthly_salary_lo
                    ,l_yearly_salary_lo
		    ,l_annual_salary_lo   -- Changes 2008/2009
                    );

         IF l_before_after = 'BEFORE'
         THEN
            get_salary_cut (l_assignment_id, g_end_date, l_salary_cut);
         ELSE
            l_salary_cut := NULL;
         END IF;


         get_absence_lvl_info (l_assignment_id
                              ,g_end_date
                              ,l_fully_capable_of_work
                              ,l_inability_to_work
                              );


      END IF;

/* **********************************************************************************/
      IF l_new_salary IS NOT NULL
      THEN
         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_assignment_action_id
            ,p_action_context_type              => 'AAP'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => l_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEALEA'
            ,p_action_information2              => 'PER'
            ,p_action_information3              => g_payroll_action_id
            ,p_action_information4              => l_new_salary
            ,p_action_information5              => l_organization_number
            ,p_action_information6              => l_cost_centre
            ,p_action_information7              => l_employee_pin
            ,p_action_information8              => fnd_date.date_to_canonical
                                                          (l_time_for_event_lo)
            ,p_action_information9              => l_before_after
            ,p_action_information10             => fnd_number.number_to_canonical
                                                           (l_yearly_salary_lo)
            ,p_action_information11             => fnd_number.number_to_canonical
                                                          (l_monthly_salary_lo)
            ,p_action_information12             => l_salary_cut
            ,p_action_information13             => /*NVL*/ (l_inability_to_work)
                                                       /*,'0'
                                                       ) */
            ,p_action_information14             => fnd_number.number_to_canonical
						   (l_sal_withdrawal)   -- Changes 2008/2009
            ,p_action_information15             => fnd_number.number_to_canonical
  						   (l_annual_salary_lo)  --Changes 2008/2009
            ,p_action_information16             => NULL
            ,p_action_information17             => NULL
            ,p_action_information18             => NULL
            ,p_action_information19             => NULL
            ,p_action_information20             => NULL
            ,p_action_information21             => NULL
            ,p_action_information22             => NULL
            ,p_action_information23             => NULL
            ,p_action_information24             => NULL
            ,p_action_information25             => NULL
            ,p_action_information26             => NULL
            ,p_action_information27             => NULL
            ,p_action_information28             => NULL
            ,p_action_information29             => NULL
            ,p_action_information30             => l_person_id
            ,p_assignment_id                    => l_assignment_id
            );

      END IF;

     END IF;  -- Closure of IF  for the check of change of company
     -- End Changes 2008/2009

/* *****************************************************************************/

      l_time_for_event_av := NULL;
      get_end_employment_or_not (l_assignment_id
                                ,l_withdrawal
                                ,l_time_for_event_av
                                ,l_reason_for_termination
                                ,l_effective_date
                                );
      l_start_parental_leave := NULL;


      IF l_time_for_event_av IS NULL AND l_reason_for_termination IS NULL
      THEN
         get_termination_or_not (l_assignment_id
                                ,'AV2'
                                ,l_withdrawal
                                ,l_time_for_event_av
                                ,l_reason_for_termination
                                ,l_effective_date
                                ,l_start_parental_leave
                                );
      END IF;


      IF l_time_for_event_av IS NULL AND l_reason_for_termination IS NULL
      THEN
         get_termination_or_not (l_assignment_id
                                ,'AV3'
                                ,l_withdrawal
                                ,l_time_for_event_av
                                ,l_reason_for_termination
                                ,l_effective_date
                                ,l_start_parental_leave
                                );
      END IF;

-- Start Changes 2008/2009
-- Reason for Withdrawl - Early Retirement Pension is Removed
/*
      IF l_time_for_event_av IS NULL AND l_reason_for_termination IS NULL
      THEN
         get_termination_or_not (l_assignment_id
                                ,'AV4'
                                ,l_withdrawal
                                ,l_time_for_event_av
                                ,l_reason_for_termination
                                ,l_effective_date
                                ,l_start_parental_leave
                                );
      END IF;

*/
-- End Changes 2008/2009

      IF    l_time_for_event_av IS NOT NULL
         OR l_reason_for_termination IS NOT NULL
      THEN
         get_assignment_lvl_info (l_assignment_id
                                 ,l_effective_date
                                 ,l_organization_number
                                 ,l_cost_centre
                                 );
         get_person_lvl_info (l_assignment_id
                             ,l_effective_date
                             ,l_employee_pin
                             ,l_first_name
                             ,l_last_name
                             ,l_before_after
                             );
         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_assignment_action_id
            ,p_action_context_type              => 'AAP'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => l_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEALEA'
            ,p_action_information2              => 'PER'
            ,p_action_information3              => g_payroll_action_id
            ,p_action_information4              => l_withdrawal
            ,p_action_information5              => l_organization_number
            ,p_action_information6              => l_cost_centre
            ,p_action_information7              => l_employee_pin
            ,p_action_information8              => fnd_date.date_to_canonical
                                                          (l_time_for_event_av)
            ,p_action_information9              => l_reason_for_termination
            ,p_action_information10             => fnd_date.date_to_canonical
                                                       (l_start_parental_leave)
            ,p_action_information11             => l_before_after -- changes 2009-2010
            ,p_action_information12             => NULL
            ,p_action_information13             => NULL
            ,p_action_information14             => NULL
            ,p_action_information15             => NULL
            ,p_action_information16             => NULL
            ,p_action_information17             => NULL
            ,p_action_information18             => NULL
            ,p_action_information19             => NULL
            ,p_action_information20             => NULL
            ,p_action_information21             => NULL
            ,p_action_information22             => NULL
            ,p_action_information23             => NULL
            ,p_action_information24             => NULL
            ,p_action_information25             => NULL
            ,p_action_information26             => NULL
            ,p_action_information27             => NULL
            ,p_action_information28             => NULL
            ,p_action_information29             => NULL
            ,p_action_information30             => l_person_id
            ,p_assignment_id                    => l_assignment_id
            );
      END IF;

      -- End of Pickingup the Data
   END archive_code;

   --- Report XML generating code
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB)
   IS
      l_xfdf_string    CLOB;
      l_str1           VARCHAR2 (4000);
      l_str_1          VARCHAR2 (4000);
      l_str_2          VARCHAR2 (4000);
      l_str_3          VARCHAR2 (4000);
      l_str2           VARCHAR2 (200);
      l_str3           VARCHAR2 (200);
      l_str4           VARCHAR2 (200);
      l_str5           VARCHAR2 (200);
      l_str6           VARCHAR2 (500);
      l_str7           VARCHAR2 (1000);
      l_str8           VARCHAR2 (240);
      l_str9           VARCHAR2 (240);
      l_str10          VARCHAR2 (200);
      l_str11          VARCHAR2 (200);
      current_index    PLS_INTEGER;
      l_iana_charset   VARCHAR2 (150);
   BEGIN

      l_iana_charset := hr_se_utility.get_iana_charset;
--    logger('CLOB l_iana_charset +== > ',l_iana_charset);
      l_str1 :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?>'
-- changes 2008/2009 Start
-- Changing the Header of the XML
--       || '<granssnitt:GrunduppgifterITP ';
         || '<GrunduppgifterITP';
--     l_str_1 :='version="2.0.0.0" xmlns:granssnitt="http://collectum.se/granssnitt/grunduppgifterITP/2.0" xmlns:arkitekturella="http://collectum.se/arkitekturella/2.0" ';
--     l_str_2 :='xmlns:avanmalan="http://collectum.se/paket/pa/avanmalan/2.0" xmlns:flyttAnstalldaInomKoncern="http://collectum.se/paket/pa/flyttAnstalldaInomKoncern/2.0" ';
--     l_str_3 :=' xmlns:loneandring="http://collectum.se/paket/pa/loneandring/2.0" xmlns:nyanmalan="http://collectum.se/paket/pa/nyanmalan/2.0" xmlns:typer="http://collectum.se/typer/2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >';
      l_str_1 := ' xmlns:granssnitt="http://collectum.se/granssnitt/grunduppgifterITP/3.0" xmlns:arkitekturella="http://collectum.se/arkitekturella/2.0" ';
      l_str_2 := 'xmlns:avanmalan="http://collectum.se/paket/pa/avanmalan/2.0" xmlns:flyttAnstalldaInomKoncern="http://collectum.se/paket/pa/flyttAnstalldaInomKoncern/3.0" xmlns:loneandring="http://collectum.se/paket/pa/loneandring/3.0" ';
      l_str_3 := 'xmlns:nyanmalan="http://collectum.se/paket/pa/nyanmalan/2.0" xmlns:typer="http://collectum.se/typer/2.0" version="3.0.0.0"> ';
-- changes 2008/2009 End
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
--  Changes 2008/2009 Start
--  Changing the Main Tag of XML
--    l_str6 := '</granssnitt:GrunduppgifterITP>';
      l_str6 := '</GrunduppgifterITP>';
--  Changes 2008/2009 End
      l_str7 :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT></ROOT>';
      l_str10 := NULL;
      l_str11 := '</>';
      DBMS_LOB.createtemporary (l_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (l_xfdf_string, DBMS_LOB.lob_readwrite);
      current_index := 0;

--logger('CLOB CLOB  +== > ','In CLOB');
--logger('str1111   +== > ',l_str1);
--logger('str1111   +== > ',l_str_1);
      IF ghpd_data.COUNT > 0
      THEN
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str_1), l_str_1);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str_2), l_str_2);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str_3), l_str_3);
         FOR table_counter IN ghpd_data.FIRST .. ghpd_data.LAST
         LOOP
            l_str8 := ghpd_data (table_counter).tagname;
            l_str9 := ghpd_data (table_counter).tagvalue;
            l_str10 := ghpd_data (table_counter).eventnumber;

            IF l_str9 IN
                  ('Header'                -- The keyword grassnitt is removed 2008/2009
                  ,'Header_END'		    -- The keyword grassnitt is removed 2008/2009
                  ,'AvanmalanHandelse'       -- The keyword grassnitt is removed 2008/2009
                  ,'AvanmalanHandelse_END'    -- The keyword grassnitt is removed 2008/2009
                  ,'arkitekturella:Timestamp'
                  ,'arkitekturella:Timestamp_END'
                  ,'Avanmalan'			 -- The keyword grassnitt is removed 2008/2009
                  ,'Avanmalan_END'		 -- The keyword grassnitt is removed 2008/2009
                  ,'avanmalan:Tidsstampel'
                  ,'avanmalan:Tidsstampel_END'
                  ,'FlyttAnstalldaInomKoncernHandelse'   -- The keyword grassnitt is removed 2008/2009
                  ,'FlyttAnstalldaInomKoncernHandelse_END'  -- The keyword grassnitt is removed 2008/2009
                  ,'FlyttAnstalldaInomKoncern'               -- The keyword grassnitt is removed 2008/2009
                  ,'FlyttAnstalldaInomKoncern_END'             -- The keyword grassnitt is removed 2008/2009
                  ,'flyttAnstalldaInomKoncern:Tidsstampel'
                  ,'flyttAnstalldaInomKoncern:Tidsstampel_END'
                  ,'LoneandringHandelse'		 -- The keyword grassnitt is removed 2008/2009
                  ,'LoneandringHandelse_END'		 -- The keyword grassnitt is removed 2008/2009
                  ,'Loneandring'			 -- The keyword grassnitt is removed 2008/2009
                  ,'Loneandring_END'			 -- The keyword grassnitt is removed 2008/2009
                  ,'loneandring:Tidsstampel'
                  ,'loneandring:Tidsstampel_END'
                  ,'NyanmalanHandelse'			 -- The keyword grassnitt is removed 2008/2009
                  ,'NyanmalanHandelse_END'		 -- The keyword grassnitt is removed 2008/2009
                  ,'Nyanmalan'				 -- The keyword grassnitt is removed 2008/2009
                  ,'Nyanmalan_END'			 -- The keyword grassnitt is removed 2008/2009
                  ,'nyanmalan:Tidsstampel'
                  ,'nyanmalan:Tidsstampel_END'
                  )
            THEN
               IF l_str9 IN
                     ('Header'				 -- The keyword grassnitt is removed 2008/2009
                     ,'AvanmalanHandelse'		 -- The keyword grassnitt is removed 2008/2009
                     ,'arkitekturella:Timestamp'
                     ,'Avanmalan'			 -- The keyword grassnitt is removed 2008/2009
                     ,'avanmalan:Tidsstampel'
                     ,'FlyttAnstalldaInomKoncernHandelse'   -- The keyword grassnitt is removed 2008/2009
                     ,'FlyttAnstalldaInomKoncern'	     -- The keyword grassnitt is removed 2008/2009
                     ,'flyttAnstalldaInomKoncern:Tidsstampel'
                     ,'LoneandringHandelse'		     -- The keyword grassnitt is removed 2008/2009
                     ,'Loneandring'			 -- The keyword grassnitt is removed 2008/2009
                     ,'loneandring:Tidsstampel'
                     ,'NyanmalanHandelse'		 -- The keyword grassnitt is removed 2008/2009
                     ,'Nyanmalan'			 -- The keyword grassnitt is removed 2008/2009
                     ,'nyanmalan:Tidsstampel'
                     )
               THEN
                  IF l_str9 IN
                        ('AvanmalanHandelse'		 -- The keyword grassnitt is removed 2008/2009
                        ,'FlyttAnstalldaInomKoncernHandelse'   -- The keyword grassnitt is removed 2008/2009
                        ,'LoneandringHandelse'			 -- The keyword grassnitt is removed 2008/2009
                        ,'NyanmalanHandelse'		 -- The keyword grassnitt is removed 2008/2009
                        )
                  THEN
                     DBMS_LOB.writeappend (l_xfdf_string
                                          ,LENGTH (l_str2)
                                          ,l_str2
                                          );
                     DBMS_LOB.writeappend (l_xfdf_string
                                          ,LENGTH (l_str8)
                                          ,l_str8
                                          );
--logger('Adding  +== > ','Attribute');
--logger('Adding l_str10  +== > ', l_str10);
                      -- Add attribute column
                     DBMS_LOB.writeappend (l_xfdf_string
                                          ,LENGTH (' Handelsenummer="')
                                          ,' Handelsenummer="'
                                          );
                     DBMS_LOB.writeappend (l_xfdf_string
                                          ,LENGTH (l_str10)
                                          ,l_str10
                                          );
                     DBMS_LOB.writeappend (l_xfdf_string, LENGTH ('"'), '"');
                     -- END of attribute addition
                     DBMS_LOB.writeappend (l_xfdf_string
                                          ,LENGTH (l_str3)
                                          ,l_str3
                                          );
                  ELSE
                     DBMS_LOB.writeappend (l_xfdf_string
                                          ,LENGTH (l_str2)
                                          ,l_str2
                                          );
                     DBMS_LOB.writeappend (l_xfdf_string
                                          ,LENGTH (l_str8)
                                          ,l_str8
                                          );
                     DBMS_LOB.writeappend (l_xfdf_string
                                          ,LENGTH (l_str3)
                                          ,l_str3
                                          );
                  END IF;
               ELSE
                  DBMS_LOB.writeappend (l_xfdf_string
                                       ,LENGTH (l_str4)
                                       ,l_str4
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                       ,l_str5);
               END IF;
            ELSE
               IF l_str9 IS NOT NULL
               THEN
                  DBMS_LOB.writeappend (l_xfdf_string
                                       ,LENGTH (l_str2)
                                       ,l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                       ,l_str3);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9)
                                       ,l_str9);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4)
                                       ,l_str4);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                       ,l_str5);
               ELSE
                  DBMS_LOB.writeappend (l_xfdf_string
                                       ,LENGTH (l_str2)
                                       ,l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                       ,l_str3);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4)
                                       ,l_str4);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                       ,l_str5);
               END IF;
            END IF;
         END LOOP;

         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str6), l_str6);
      ELSE
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str7), l_str7);
      END IF;

      p_xfdf_clob := l_xfdf_string;
      hr_utility.set_location ('Leaving WritetoCLOB ', 40);
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.TRACE ('sqlerrm ' || SQLERRM);
         hr_utility.raise_error;
   END writetoclob;

   PROCEDURE get_xml_for_report (
      p_business_group_id        IN       NUMBER
     ,p_payroll_action_id        IN       VARCHAR2
     ,p_template_name            IN       VARCHAR2
     ,p_xml                      OUT NOCOPY CLOB
   )
   IS
--Variables needed for the report
      l_counter                     NUMBER                               := 0;
      l_payroll_action_id           pay_action_information.action_information1%TYPE;

--Cursors needed for report
      CURSOR csr_report_details (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT *
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT DETAILS'
            AND action_information1 = 'PYSEALEA';

      lr_report_details             csr_report_details%ROWTYPE;

      CURSOR csr_all_employees_for_event (
         csr_v_pa_id                         pay_action_information.action_information3%TYPE
        ,csr_v_event                         pay_action_information.action_information4%TYPE
      )
      IS
         SELECT   *
             FROM pay_action_information
            WHERE action_context_type = 'AAP'
              AND action_information_category = 'EMEA REPORT INFORMATION'
              AND action_information1 = 'PYSEALEA'
              AND action_information3 = csr_v_pa_id
              AND action_information2 = 'PER'
              AND action_information4 = csr_v_event
         ORDER BY action_information30;

      CURSOR csr_count_employees_for_event (
         csr_v_pa_id                         pay_action_information.action_information3%TYPE
        ,csr_v_event                         pay_action_information.action_information4%TYPE
      )
      IS
         SELECT COUNT ('1')
           FROM pay_action_information
          WHERE action_context_type = 'AAP'
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEALEA'
            AND action_information3 = csr_v_pa_id
            AND action_information2 = 'PER'
            AND action_information4 = csr_v_event;

      l_count_employees_for_event   NUMBER;

      CURSOR csr_all_employees_under_le (
         csr_v_pa_id                         pay_action_information.action_information3%TYPE
        ,csr_v_le_id                         pay_action_information.action_information15%TYPE
      )
      IS
         SELECT   *
             FROM pay_action_information
            WHERE action_context_type = 'AAP'
              AND action_information_category = 'EMEA REPORT INFORMATION'
              AND action_information1 = 'PYSEALEA'
              AND action_information3 = csr_v_pa_id
              AND action_information2 = 'PER'
              AND action_information15 = csr_v_le_id
         ORDER BY action_information30;

/* End of declaration*/
/* Proc to Add the tag value and Name */
      PROCEDURE add_tag_value (
         p_tag_name                 IN       VARCHAR2
        ,p_tag_value                IN       VARCHAR2
        ,p_eventnumber              IN       NUMBER DEFAULT NULL
      )
      IS
      BEGIN
         ghpd_data (l_counter).tagname := p_tag_name;
         ghpd_data (l_counter).tagvalue := p_tag_value;
         ghpd_data (l_counter).eventnumber := p_eventnumber;
         l_counter := l_counter + 1;
      END add_tag_value;
/* End of Proc to Add the tag value and Name */
/* Start of GET_HPD_XML */
   BEGIN
      IF p_payroll_action_id IS NULL
      THEN
         BEGIN
            SELECT payroll_action_id
              INTO l_payroll_action_id
              FROM pay_payroll_actions ppa
                  ,fnd_conc_req_summary_v fcrs
                  ,fnd_conc_req_summary_v fcrs1
             WHERE fcrs.request_id = fnd_global.conc_request_id
               AND fcrs.priority_request_id = fcrs1.priority_request_id
               AND ppa.request_id BETWEEN fcrs1.request_id AND fcrs.request_id
               AND ppa.request_id = fcrs1.request_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      ELSE
         l_payroll_action_id := p_payroll_action_id;


--logger('p_payroll_action_id  +== > ',p_payroll_action_id);
         OPEN csr_report_details (l_payroll_action_id);

         FETCH csr_report_details
          INTO lr_report_details;

         CLOSE csr_report_details;


-- Header ---
-- changes 2008/2009 Start
-- add_tag_value ('granssnitt:Header', 'granssnitt:Header');
         add_tag_value ('Header version="2.0.0.2"','Header');
-- Changes 2008/2009 End
         add_tag_value ('arkitekturella:SkickatFran'
                       ,lr_report_details.action_information7
                       );
         add_tag_value ('arkitekturella:SkickatTill'
                       ,lr_report_details.action_information8
                       );
         add_tag_value ('arkitekturella:Timestamp'
                       ,'arkitekturella:Timestamp');
         add_tag_value ('typer:Datetime'
                       ,REPLACE (TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:MM:SS')
                                ,' '
                                ,'T'
                                )
                       );
         add_tag_value ('typer:Fractions', '000000');
         add_tag_value ('arkitekturella:Timestamp'
                       ,'arkitekturella:Timestamp_END'
                       );
         add_tag_value ('arkitekturella:Sekvensnummer', '1');

         IF lr_report_details.action_information9 = 'Y'
         THEN
            add_tag_value ('arkitekturella:Produktion', 'true' /*'Yes'*/);
         ELSE
            add_tag_value ('arkitekturella:Produktion', 'false' /*'No'*/);
         END IF;
-- changes 2008/2009 Start
-- add_tag_value ('granssnitt:Header', 'granssnitt:Header_END');
	add_tag_value ('Header','Header_END');
	add_tag_value ('Organisationsnummer'
                          ,'16'||lr_report_details.action_information10
                          );


-- Changes 2008/2009 End


/**************************************************************************************************/
/* The order of display has been changed
The order of XML earlier was
    1) Withdrawal - AvanmalanHandelse
    2) Change of company - FlyttAnstalldaInomKoncernHandelse
    3) Salary Change - LoneandringHandelse
    4) New Entry or New Joinee - NyanmalanHandelse

The New Order is
    1) New Entry or New Joinee - NyanmalanHandelse
    2) Salary Change - LoneandringHandelse
    3)  Change of company - FlyttAnstalldaInomKoncernHandelse
    4) Withdrawal/Termination - AvanmalanHandelse
/*************************************************************************************************/

    -- New Entry or New Joinee
    l_count_employees_for_event := 1;
/*
l_count_employees_for_event := NULL;
         OPEN csr_count_employees_for_event (l_payroll_action_id,'IN');
         FETCH csr_count_employees_for_event INTO l_count_employees_for_event;
         CLOSE csr_count_employees_for_event;
IF l_count_employees_for_event > 0
THEN
*/
         FOR row_all_employees_for_event IN
            csr_all_employees_for_event (l_payroll_action_id, 'IN')
         LOOP
-- add_tag_value ('granssnitt:User', ' ');
--  add_tag_value ('granssnitt:Organisationsnummer','16'||row_all_employees_for_event.action_information5);
--- Moved the position of display of Organization number -- Changes 2009/2010
--	add_tag_value ('Organisationsnummer','16'||row_all_employees_for_event.action_information5);  -- The keyword grassnitt is removed 2008/2009
-- add_tag_value ('granssnitt:Filnamn', ' ');

--            add_tag_value ('granssnitt:NyanmalanHandelse'
--                          ,'granssnitt:NyanmalanHandelse'
--                          ,l_count_employees_for_event
--                          );
		add_tag_value ('NyanmalanHandelse'    -- The keyword grassnitt is removed 2008/2009
                          ,'NyanmalanHandelse'
                          ,l_count_employees_for_event
                          );
            l_count_employees_for_event := l_count_employees_for_event + 1;
-- add_tag_value ('granssnitt:Nyanmalan', 'granssnitt:Nyanmalan');

	   add_tag_value ('Nyanmalan version="2.0.0.0"', 'Nyanmalan');  -- The keyword grassnitt is removed 2008/2009
            add_tag_value ('nyanmalan:Organisationsnummer'
                          ,'16'||row_all_employees_for_event.action_information5
                          );
            add_tag_value ('nyanmalan:KostnadsstalleId'
                          ,row_all_employees_for_event.action_information6
                          );
            add_tag_value ('nyanmalan:Avtalsplanid'
                          ,row_all_employees_for_event.action_information7
                          );
            add_tag_value ('nyanmalan:Personnummer'
                          ,row_all_employees_for_event.action_information8
                          );
            add_tag_value
               ('nyanmalan:Handelsetidpunkt'
               ,TO_CHAR
                   (fnd_date.canonical_to_date
                              (row_all_employees_for_event.action_information9)
                   ,'YYYY-MM-DD'
                   )
               );
            add_tag_value ('nyanmalan:Efternamn'
                          ,row_all_employees_for_event.action_information10
                          );
            add_tag_value ('nyanmalan:Fornamn'
                          ,row_all_employees_for_event.action_information11
                          );

-- add conditional tags

           IF row_all_employees_for_event.action_information12 = 'AFTER'
            THEN
               add_tag_value
                            ('nyanmalan:Manadslon'
                            ,row_all_employees_for_event.action_information14
                            );
            ELSE
               add_tag_value
                            ('nyanmalan:Arslon'
                            ,row_all_employees_for_event.action_information13
                            );
          END IF;

-- Start Changes 2008/2009
  IF row_all_employees_for_event.action_information18 > 0 AND row_all_employees_for_event.action_information12 = 'BEFORE'
  THEN
               add_tag_value
                            ('nyanmalan:ArslonForeLoneavstaende'
                            ,(row_all_employees_for_event.action_information18 + row_all_employees_for_event.action_information19)
                            );  -- Annual Salary Before withdrawal = Annual Salary + Withdrawal Salary

	        add_tag_value
                            ('nyanmalan:ArslonEfterLoneavstaende'
                            ,(row_all_employees_for_event.action_information19)
                            );  -- Annual Salary After withdrawal = Annual Salary

 ELSIF row_all_employees_for_event.action_information18 = 0 AND row_all_employees_for_event.action_information12 = 'BEFORE'
 THEN

                add_tag_value
                            ('nyanmalan:ArslonForeLoneavstaende'
                            ,(row_all_employees_for_event.action_information19)
                            );  -- Annual Salary Before withdrawal = Annual Salary (If withdrawal is zero)

	        add_tag_value
                            ('nyanmalan:ArslonEfterLoneavstaende'
                            ,(row_all_employees_for_event.action_information18)
                            );  -- Annual Salary After withdrawal = 0 SEK (if withdrawal is zero)
 END IF;

-- End Changes 2008/2009


            add_tag_value ('nyanmalan:FulltArbetsfor'
                          ,row_all_employees_for_event.action_information15
                          );

-- Added the condition, Show Inability to work percentage only if fully capable to work is false
	  If row_all_employees_for_event.action_information15 = 'false'
	  THEN

            add_tag_value ('nyanmalan:GradAvArbetsoformaga'
                          ,row_all_employees_for_event.action_information16
                          );
          END IF;
-- Start Changes 2008/2009

 IF row_all_employees_for_event.action_information17 = 'Alecta - Part 2' AND row_all_employees_for_event.action_information12 = 'BEFORE'
        THEN
	add_tag_value ('nyanmalan:VanligITP2'
                          ,'Ja'
                          );
  END IF;
-- End changes 2008/2009


            add_tag_value ('nyanmalan:Tidsstampel', 'nyanmalan:Tidsstampel');
            add_tag_value ('typer:Datetime'
                          ,REPLACE (TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:MM:SS')
                                   ,' '
                                   ,'T'
                                   )
                          );
            add_tag_value ('typer:Fractions', '000000');
            add_tag_value ('nyanmalan:Tidsstampel'
                          ,'nyanmalan:Tidsstampel_END'
                          );
-- add_tag_value ('granssnitt:Nyanmalan', 'granssnitt:Nyanmalan_END');
		add_tag_value ('Nyanmalan', 'Nyanmalan_END');  -- The keyword grassnitt is removed 2008/2009
-- add_tag_value ('granssnitt:NyanmalanHandelse'
--                          ,'granssnitt:NyanmalanHandelse_END'
--                          );
		add_tag_value ('NyanmalanHandelse' -- The keyword grassnitt is removed 2008/2009
                          ,'NyanmalanHandelse_END'
                          );
         END LOOP;
--END IF;
-------------------------------------------------------------------------------------------------------------------
-- Salary Change


/*
l_count_employees_for_event := NULL;
         OPEN csr_count_employees_for_event (l_payroll_action_id,'LO');
         FETCH csr_count_employees_for_event INTO l_count_employees_for_event;
         CLOSE csr_count_employees_for_event;
IF l_count_employees_for_event > 0
THEN
*/
         FOR row_all_employees_for_event IN
            csr_all_employees_for_event (l_payroll_action_id, 'LO')
         LOOP
 -- add_tag_value ('granssnitt:User', ' ');
--  add_tag_value ('granssnitt:Organisationsnummer','16'||row_all_employees_for_event.action_information5);
--- Moved the position of display of Organization number -- Changes 2009/2010
--	  add_tag_value ('Organisationsnummer','16'||row_all_employees_for_event.action_information5);  -- The keyword grassnitt is removed 2008/2009

-- add_tag_value ('granssnitt:Filnamn', ' ');

-- add_tag_value ('granssnitt:LoneandringHandelse'
--                          ,'granssnitt:LoneandringHandelse'
--                          ,l_count_employees_for_event
--                          );
	   add_tag_value ('LoneandringHandelse'    -- The keyword grassnitt is removed 2008/2009
                          ,'LoneandringHandelse'
                          ,l_count_employees_for_event
                          );

            l_count_employees_for_event := l_count_employees_for_event + 1;

-- add_tag_value ('Loneandring', 'Loneandring');

	     add_tag_value ('Loneandring version="2.0.0.0"', 'Loneandring'); -- The keyword grassnitt is removed 2008/2009

            add_tag_value ('loneandring:Organisationsnummer'
                          ,'16'||row_all_employees_for_event.action_information5
                          );
            add_tag_value ('loneandring:KostnadsstalleId'
                          ,row_all_employees_for_event.action_information6
                          );
            add_tag_value ('loneandring:Personnummer'
                          ,row_all_employees_for_event.action_information7
                          );
            add_tag_value
               ('loneandring:Handelsetidpunkt'
               ,TO_CHAR
                   (fnd_date.canonical_to_date
                              (row_all_employees_for_event.action_information8)
                   ,'YYYY-MM-DD'
                   )
               );

-- add conditional tags
IF row_all_employees_for_event.action_information9 = 'AFTER'
THEN
		add_tag_value
                            ('loneandring:Manadslon'
                            ,row_all_employees_for_event.action_information11
                            );
ELSE

	       add_tag_value
                            ('loneandring:Arslon'
                            ,row_all_employees_for_event.action_information10
                            );
END IF;

-- Start Changes 2008/2009
  IF row_all_employees_for_event.action_information14  > 0 AND row_all_employees_for_event.action_information9 = 'BEFORE'
  THEN
               add_tag_value
                            ('loneandring:ArslonForeLoneavstaende'
                            ,(row_all_employees_for_event.action_information14 + row_all_employees_for_event.action_information15)
                            );  -- Annual Salary Before withdrawal = Annual  Salary + Withdrawal Salary

	        add_tag_value
                            ('loneandring:ArslonEfterLoneavstaende'
                            ,(row_all_employees_for_event.action_information15)
                            );  -- Annual Salary After withdrawal = Annual Salary

 ELSIF row_all_employees_for_event.action_information14 = 0 AND row_all_employees_for_event.action_information9 = 'BEFORE'
 THEN

                add_tag_value
                            ('loneandring:ArslonForeLoneavstaende'
                            ,(row_all_employees_for_event.action_information15)
                            );  -- Annual Salary Before withdrawal = Annual Salary (If withdrawal is zero)

	        add_tag_value
                            ('loneandring:ArslonEfterLoneavstaende'
                            ,(row_all_employees_for_event.action_information14)
                            );  -- Annual Salary After withdrawal = 0 SEK (if withdrawal is zero)
 END IF;

-- End Changes 2008/2009

-- Changes 2009/2010
If row_all_employees_for_event.action_information13 > 0
THEN


	       add_tag_value ('loneandring:GradAvArbetsoformaga'
                             ,row_all_employees_for_event.action_information13
                             );

END IF;
-- Start changes 2008/2009
-- H10 Salary Cut is removed
/*

--            IF row_all_employees_for_event.action_information9 = 'AFTER'
--            THEN
--             /*  add_tag_value
--                            ('loneandring:Manadslon'
--                            ,row_all_employees_for_event.action_information11
--                            );*/
--               /*add_tag_value ('loneandring:GradAvArbetsoformaga'
--                             ,row_all_employees_for_event.action_information13
--                             );*/
--			     null;
--           ELSE
--               /*add_tag_value
--                            ('loneandring:Arslon'
--                            ,row_all_employees_for_event.action_information10
--                            );*/
--               add_tag_value ('loneandring:Lonesankning'
--                             ,row_all_employees_for_event.action_information12
--                             );
--            END IF;

-- End Changes 2008/2009

            add_tag_value ('loneandring:Tidsstampel'
                          ,'loneandring:Tidsstampel'
                          );
            add_tag_value ('typer:Datetime'
                          ,REPLACE (TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:MM:SS')
                                   ,' '
                                   ,'T'
                                   )
                          );
            add_tag_value ('typer:Fractions', '000000');
            add_tag_value ('loneandring:Tidsstampel'
                          ,'loneandring:Tidsstampel_END'
                          );

 -- add_tag_value ('granssnitt:Loneandring'
 --                        ,'granssnitt:Loneandring_END'
 --                         );
	add_tag_value ('Loneandring'		-- The keyword grassnitt is removed 2008/2009
                        ,'Loneandring_END'
                         );

 -- add_tag_value ('granssnitt:LoneandringHandelse'
 --                         ,'granssnitt:LoneandringHandelse_END'
 --                         );

	add_tag_value ('LoneandringHandelse'       -- The keyword grassnitt is removed 2008/2009
                      ,'LoneandringHandelse_END'
                       );
         END LOOP;

--END IF;
----------------------------------------------------------------------------------------------------------------



--Change of company
/*
l_count_employees_for_event := NULL;
         OPEN csr_count_employees_for_event (l_payroll_action_id,'FK');
         FETCH csr_count_employees_for_event INTO l_count_employees_for_event;
         CLOSE csr_count_employees_for_event;
IF l_count_employees_for_event > 0
THEN
*/
         FOR row_all_employees_for_event IN
            csr_all_employees_for_event (l_payroll_action_id, 'FK')
         LOOP
--  add_tag_value ('granssnitt:User', ' ');
--  add_tag_value ('granssnitt:Organisationsnummer','16'||row_all_employees_for_event.action_information5);
--  Moved the position of display of Organization number -- Changes 2009/2010
--           add_tag_value ('Organisationsnummer','16'||row_all_employees_for_event.action_information5); -- The keyword grassnitt is removed 2008/2009
--  add_tag_value ('granssnitt:Filnamn', ' ');

-- add_tag_value ('granssnitt:FlyttAnstalldaInomKoncernHandelse'
--                          ,'granssnitt:FlyttAnstalldaInomKoncernHandelse'
--                          ,l_count_employees_for_event
--                         );
	   add_tag_value ('FlyttAnstalldaInomKoncernHandelse'   -- The keyword grassnitt is removed 2008/2009
                          ,'FlyttAnstalldaInomKoncernHandelse'
                          ,l_count_employees_for_event
                         );
            l_count_employees_for_event := l_count_employees_for_event + 1;

-- add_tag_value ('granssnitt:FlyttAnstalldaInomKoncern'
--                          ,'granssnitt:FlyttAnstalldaInomKoncern'
--                          );

         add_tag_value ('FlyttAnstalldaInomKoncern version="2.0.0.0" '    -- The keyword grassnitt is removed 2008/2009
                          ,'FlyttAnstalldaInomKoncern'
                          );
            add_tag_value ('flyttAnstalldaInomKoncern:Organisationsnummer'
                          ,'16'||row_all_employees_for_event.action_information5
                          );
            add_tag_value ('flyttAnstalldaInomKoncern:KostnadsstalleId'
                          ,row_all_employees_for_event.action_information6
                          );
            add_tag_value ('flyttAnstalldaInomKoncern:Avtalsplanid'
                          ,row_all_employees_for_event.action_information7
                          );
            add_tag_value ('flyttAnstalldaInomKoncern:Personnummer'
                          ,row_all_employees_for_event.action_information8
                          );
            add_tag_value
               ('flyttAnstalldaInomKoncern:Handelsetidpunkt'
               ,TO_CHAR
                   (fnd_date.canonical_to_date
                              (row_all_employees_for_event.action_information9)
                   ,'YYYY-MM-DD'
                   )
               );

-- Add conditional for yearly or monthly salary.
            /*IF row_all_employees_for_event.action_information10 = 'AFTER'
            THEN*/
-- Start Changes 2008/2009
-- H25  - Monthly Salary Removed from moving Within a group of companies
	    /*
               add_tag_value
                  ('flyttAnstalldaInomKoncern:Manadslon'
                  ,fnd_number.canonical_to_number
                             (row_all_employees_for_event.action_information12)
                  );
		  */
-- End changes 2008/2009
/* END IF;*/
IF row_all_employees_for_event.action_information10 = 'BEFORE'
THEN
               add_tag_value
                  ('flyttAnstalldaInomKoncern:Arslon'
                  ,fnd_number.canonical_to_number
                             (row_all_employees_for_event.action_information11)
                  );
END IF;
--Start Changes 2008/2009
-- H17 - Fully Capable of Work Removed
/*
            add_tag_value ('flyttAnstalldaInomKoncern:FulltArbetsfor'
                          ,row_all_employees_for_event.action_information13
                          );
*/
-- End Changes 2008/2009
           /* add_tag_value ('flyttAnstalldaInomKoncern:GradAvArbetsoformaga'
                          ,row_all_employees_for_event.action_information14
                          );*/
            add_tag_value
                         ('flyttAnstalldaInomKoncern:OrganisationsnummerFran'
                         ,'16'||row_all_employees_for_event.action_information15
                         );
            add_tag_value ('flyttAnstalldaInomKoncern:KostnadsstalleIdFran'
                          ,row_all_employees_for_event.action_information16
                          );
            add_tag_value ('flyttAnstalldaInomKoncern:Tidsstampel'
                          ,'flyttAnstalldaInomKoncern:Tidsstampel'
                          );
            add_tag_value ('typer:Datetime'
                          ,REPLACE (TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:MM:SS')
                                   ,' '
                                   ,'T'
                                   )
                          );
            add_tag_value ('typer:Fractions', '000000');
            add_tag_value ('flyttAnstalldaInomKoncern:Tidsstampel'
                          ,'flyttAnstalldaInomKoncern:Tidsstampel_END'
                          );
--  add_tag_value ('granssnitt:FlyttAnstalldaInomKoncern'
--			   ,'granssnitt:FlyttAnstalldaInomKoncern_END'
--                          );
	add_tag_value ('FlyttAnstalldaInomKoncern'    -- The keyword grassnitt is removed 2008/2009
			   ,'FlyttAnstalldaInomKoncern_END'
                          );

-- add_tag_value ('granssnitt:FlyttAnstalldaInomKoncernHandelse'
--                          ,'granssnitt:FlyttAnstalldaInomKoncernHandelse_END'
--                          );
	 add_tag_value ('FlyttAnstalldaInomKoncernHandelse'   -- The keyword grassnitt is removed 2008/2009
                          ,'FlyttAnstalldaInomKoncernHandelse_END'
                          );
         END LOOP;

--END IF;

--------------------------------------------------------------------------------------------------------------------
-- Withdrawal ---
         /*add_tag_value ('granssnitt:User', ' ');
         add_tag_value ('granssnitt:Filnamn', ' ');*/


/*l_count_employees_for_event := NULL;
         OPEN csr_count_employees_for_event (l_payroll_action_id,'AV');
         FETCH csr_count_employees_for_event INTO l_count_employees_for_event;
         CLOSE csr_count_employees_for_event;
IF l_count_employees_for_event > 0
THEN
*/
         FOR row_all_employees_for_event IN
            csr_all_employees_for_event (l_payroll_action_id, 'AV')
         LOOP
-- changes 2008/2009 Start
-- add_tag_value ('granssnitt:User', ' ');
-- add_tag_value ('granssnitt:Organisationsnummer','16'||row_all_employees_for_event.action_information5);
-- Moved the position of display of Organization number -- Changes 2009/2010
-- add_tag_value ('Organisationsnummer','16'||row_all_employees_for_event.action_information5);

-- add_tag_value ('granssnitt:Filnamn', ' ');  -- Not used in new report 2008/2009

-- add_tag_value ('granssnitt:AvanmalanHandelse'   -- The keyword grassnitt is removed 2008/2009
--                          ,'granssnitt:AvanmalanHandelse'
--                          ,l_count_employees_for_event
--                          );
            add_tag_value ('AvanmalanHandelse'
                          ,'AvanmalanHandelse'
                          ,l_count_employees_for_event
                          );
            l_count_employees_for_event := l_count_employees_for_event + 1;

--  add_tag_value ('granssnitt:Avanmalan','granssnitt:Avanmalan');
            add_tag_value ('Avanmalan version="2.0.0.0"','Avanmalan');  -- The keyword grassnitt is removed 2008/2009


            add_tag_value ('avanmalan:Organisationsnummer'
                          ,'16'||row_all_employees_for_event.action_information5
                          );
            add_tag_value ('avanmalan:KostnadsstalleId'
                          ,row_all_employees_for_event.action_information6
                          );
            add_tag_value ('avanmalan:Personnummer'
                          ,row_all_employees_for_event.action_information7
                          );
--logger('Before Change of Company  +== > ',row_all_employees_for_event.action_information8);
            add_tag_value
               ('avanmalan:Handelsetidpunkt'
               ,TO_CHAR
                   (fnd_date.canonical_to_date
                              (row_all_employees_for_event.action_information8)
                   ,'YYYY-MM-DD'
                   )
               );
--logger('Before Change of Company  +== > ',row_all_employees_for_event.action_information8);
            add_tag_value ('avanmalan:Avgangsorsak'
                          ,row_all_employees_for_event.action_information9
                          );

            IF row_all_employees_for_event.action_information10 IS NOT NULL AND row_all_employees_for_event.action_information11 = 'BEFORE'
            THEN
               add_tag_value
                  ('avanmalan:DatumForForalderledighet'
                  ,TO_CHAR
                      (fnd_date.canonical_to_date
                             (row_all_employees_for_event.action_information10)
                      ,'YYYY-MM-DD'
                      )
                  );
            END IF;

            add_tag_value ('avanmalan:Tidsstampel', 'avanmalan:Tidsstampel');
            add_tag_value ('typer:Datetime'
                          ,REPLACE (TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:MM:SS')
                                   ,' '
                                   ,'T'
                                   )
                          );
            add_tag_value ('typer:Fractions', '000000');
            add_tag_value ('avanmalan:Tidsstampel'
                          ,'avanmalan:Tidsstampel_END'
                          );

 -- add_tag_value ('granssnitt:Avanmalan', 'granssnitt:Avanmalan_END');
           add_tag_value ('Avanmalan', 'Avanmalan_END');   -- The keyword grassnitt is removed 2008/2009

 -- add_tag_value ('granssnitt:AvanmalanHandelse'
 --                         ,'granssnitt:AvanmalanHandelse_END'
 --                         );

	  add_tag_value ('AvanmalanHandelse'   -- The keyword grassnitt is removed 2008/2009
                         ,'AvanmalanHandelse_END'
                          );
         END LOOP;

--END IF;
-------------------------------------------------------------------------------------------------------------

/*         add_tag_value ('PERIOD_FROM', lr_report_details.period_from);
         add_tag_value ('PERIOD_TO', lr_report_details.period_to);
         fnd_file.put_line (fnd_file.LOG, 'After csr_REPORT_DETAILS  ');
         fnd_file.put_line (fnd_file.LOG,
                            'PERIOD_FROM  ' || lr_report_details.period_from
                           );
         fnd_file.put_line (fnd_file.LOG,
                            'PERIOD_TO  ' || lr_report_details.period_to
                           );
         fnd_file.put_line (fnd_file.LOG, 'Before Csr for Legal');

         FOR rec_all_le IN csr_all_legal_employer (l_payroll_action_id)
         LOOP
            add_tag_value ('LEGAL_EMPLOYER', 'LEGAL_EMPLOYER');
            add_tag_value ('LE_DETAILS', 'LE_DETAILS');
            add_tag_value ('LE_NAME', rec_all_le.action_information4);
            add_tag_value ('LE_ORG_NUM', rec_all_le.action_information5);
            add_tag_value ('LE_DETAILS', 'LE_DETAILS_END');
            add_tag_value ('EMPLOYEES', 'EMPLOYEES');
            fnd_file.put_line (fnd_file.LOG, '^^^^^^^^^^^^^^^^^^^^^');
            fnd_file.put_line (fnd_file.LOG, 'Legal Employer');
            fnd_file.put_line (fnd_file.LOG,
                               'LE ID  ' || rec_all_le.action_information3
                              );
            fnd_file.put_line (fnd_file.LOG,
                               'LE_NAME  ' || rec_all_le.action_information4
                              );
            fnd_file.put_line (fnd_file.LOG, '^^^^^^^^^^^^^^^^^^^^^');
            fnd_file.put_line (fnd_file.LOG, '^^^^^^^^^^^^^^^^^^^^^');
            fnd_file.put_line (fnd_file.LOG, ' Inside Person Query');

            FOR rec_all_emp_under_le IN
               csr_all_employees_under_le (l_payroll_action_id,
                                           rec_all_le.action_information3
                                          )
            LOOP
               fnd_file.put_line (fnd_file.LOG,
                                     'PERSON ID ==>  '
                                  || rec_all_emp_under_le.action_information30
                                 );
               add_tag_value ('PERSON', 'PERSON');
               add_tag_value ('EMPLOYEE_CODE',
                              rec_all_emp_under_le.action_information4
                             );
               add_tag_value ('EMPLOYEE_NUMBER',
                              rec_all_emp_under_le.action_information5
                             );
               add_tag_value ('EMPLOYEE_NAME',
                              rec_all_emp_under_le.action_information6
                             );
               add_tag_value
                  ('HOLIDAY_PAY_PER_DAY',
                   TO_CHAR
                      (fnd_number.canonical_to_number
                                     (rec_all_emp_under_le.action_information7),
                       '999999990D99'
                      )
                  );
               add_tag_value ('TOTAL_PAID_DAYS',
                              rec_all_emp_under_le.action_information8
                             );
               add_tag_value
                  ('TOTAL_PAID_DAYS_AMOUNT',
                   TO_CHAR
                      (fnd_number.canonical_to_number
                                     (rec_all_emp_under_le.action_information9),
                       '999999990D99'
                      )
                  );
               add_tag_value ('TOTAL_SAVED_DAYS',
                              rec_all_emp_under_le.action_information10
                             );
               add_tag_value
                  ('TOTAL_SAVED_DAYS_AMOUNT',
                   TO_CHAR
                      (fnd_number.canonical_to_number
                                    (rec_all_emp_under_le.action_information11),
                       '999999990D99'
                      )
                  );
               add_tag_value ('TOTAL_EARNED_DAYS',
                              rec_all_emp_under_le.action_information12
                             );
               add_tag_value
                  ('TOTAL_EARNED_DAYS_AMOUNT',
                   TO_CHAR
                      (fnd_number.canonical_to_number
                                    (rec_all_emp_under_le.action_information13),
                       '999999990D99'
                      )
                  );
               add_tag_value ('PERSON', 'PERSON_END');
            END LOOP;                                  -- For all EMPLOYEES

            fnd_file.put_line (fnd_file.LOG, '^^^^^^^^^^^^^^^^^^^^^');
            add_tag_value ('EMPLOYEES', 'EMPLOYEES_END');
            add_tag_value ('LEGAL_EMPLOYER', 'LEGAL_EMPLOYER_END');
         END LOOP;                                 -- For all LEGAL_EMPLYER
         */
      END IF;                               -- for p_payroll_action_id IS NULL

      writetoclob (p_xml);

--      INSERT INTO clob_table           VALUES (p_xml                  );

  --    COMMIT;
   END get_xml_for_report;

      -- *****************************************************************************
/* Proc to Add the tag value and Name */
   PROCEDURE logger (p_display IN VARCHAR2, p_value IN VARCHAR2)
   IS
   BEGIN
      fnd_file.put_line (fnd_file.LOG
                        , p_display || '          ==> ' || p_value
                        );
   END logger;

   PROCEDURE get_assignment_lvl_info (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_organization_number      OUT NOCOPY VARCHAR2
     ,p_cost_centre              OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR csr_get_details
      IS
         SELECT scl.segment2
               ,paa.location_id
           FROM per_all_assignments_f paa
               ,hr_soft_coding_keyflex scl
          WHERE paa.assignment_id = p_assignment_id
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
--            AND paa.primary_flag = 'Y'
            AND p_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date;

      lr_get_details              csr_get_details%ROWTYPE;

      -- Cursor to pick up LEGAL EMPLOYER
      CURSOR csr_find_legal_employer (
         csr_v_organization_id               hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hoi3.organization_id legal_id
           FROM hr_all_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_organization_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER';

      lr_find_legal_employer      csr_find_legal_employer%ROWTYPE;

      CURSOR csr_legal_employer_details (
         csr_v_legal_employer_id             hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT o1.NAME legal_employer_name
               ,hoi2.org_information2 org_number
               ,hoi1.organization_id legal_id
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_legal_employer_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS';

      lr_legal_employer_details   csr_legal_employer_details%ROWTYPE;

      CURSOR csr_cost_center_details (csr_v_location_id NUMBER)
      IS
         SELECT hr_general.decode_lookup ('SE_ALECTA_COST_CENTER'
                                         ,lei_information1
                                         ) "COST_CENTER"
           FROM hr_location_extra_info
          WHERE location_id = csr_v_location_id
            AND information_type = 'SE_ALECTA_DETAILS';
   BEGIN
      OPEN csr_get_details;

      FETCH csr_get_details
       INTO lr_get_details;

      CLOSE csr_get_details;

--logger('LOCAL UNIT   ==> ',lr_get_details.segment2);
      OPEN csr_find_legal_employer (lr_get_details.segment2);

      FETCH csr_find_legal_employer
       INTO lr_find_legal_employer;

      CLOSE csr_find_legal_employer;

--logger('LEGAL EMPLOYER   ==> ',lr_find_legal_employer.legal_id);
      OPEN csr_legal_employer_details (lr_find_legal_employer.legal_id);

      FETCH csr_legal_employer_details
       INTO lr_legal_employer_details;

      CLOSE csr_legal_employer_details;

      p_organization_number := lr_legal_employer_details.org_number;

--logger('p_organization_number   ==> ',p_organization_number);
      OPEN csr_cost_center_details (lr_get_details.location_id);

      FETCH csr_cost_center_details
       INTO p_cost_centre;
      CLOSE csr_cost_center_details;
       p_cost_centre:=nvl(p_cost_centre,'000');
--logger('p_cost_centre   ==> ',p_cost_centre);
   END get_assignment_lvl_info;

   PROCEDURE get_person_lvl_info (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_pin                      OUT NOCOPY VARCHAR2
     ,p_first_name               OUT NOCOPY VARCHAR2
     ,p_last_name                OUT NOCOPY VARCHAR2
     ,p_born_1979                OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR csr_get_details
      IS
         SELECT pap.last_name
               ,pap.first_name
               ,pap.national_identifier
               ,pap.person_id
               ,paa.assignment_id
               ,paa.assignment_number
               ,paa.effective_start_date
               ,pap.date_of_birth
           FROM per_all_assignments_f paa
               ,per_all_people_f pap
          WHERE paa.assignment_id = p_assignment_id
            AND paa.person_id = pap.person_id
            AND pap.per_information_category = 'SE'
            AND p_effective_date BETWEEN pap.effective_start_date
                                     AND pap.effective_end_date
            AND p_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date;

      lr_get_details   csr_get_details%ROWTYPE;
   BEGIN
      OPEN csr_get_details;

      FETCH csr_get_details
       INTO lr_get_details;

      CLOSE csr_get_details;

      p_pin := substr(TO_CHAR(lr_get_details.date_of_birth,'yyyy'),1,2)||replace(lr_get_details.national_identifier,'-','');
      p_first_name := lr_get_details.first_name;
      p_last_name := lr_get_details.last_name;

      IF TO_CHAR (lr_get_details.date_of_birth, 'YYYY') >= 1979
      THEN
         p_born_1979 := 'AFTER';
      ELSE
         p_born_1979 := 'BEFORE';
      END IF;
--logger('p_PIN   ==> ',p_PIN);
--logger('p_FIRST_NAME   ==> ',p_FIRST_NAME);
--logger('p_LAST_NAME   ==> ',p_LAST_NAME);
--logger('p_born_1979   ==> ',p_born_1979);
   END get_person_lvl_info;

   PROCEDURE get_in_time_of_event (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_event_date               OUT NOCOPY DATE
   )
   IS
      CURSOR csr_get_details
      IS
         SELECT MONTHS_BETWEEN (g_start_date, pap.date_of_birth) / 12 "YEAR"
               ,pap.date_of_birth
           FROM per_all_assignments_f paa
               ,per_all_people_f pap
          WHERE paa.assignment_id = p_assignment_id
            AND paa.person_id = pap.person_id
            AND pap.per_information_category = 'SE'
            AND p_effective_date BETWEEN pap.effective_start_date
                                     AND pap.effective_end_date
            AND p_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date;

      lr_get_details   csr_get_details%ROWTYPE;
   BEGIN
      OPEN csr_get_details;

      FETCH csr_get_details
       INTO lr_get_details;

      CLOSE csr_get_details;

      IF lr_get_details.YEAR >= 18
      THEN
         p_event_date := p_effective_date;
      ELSE
         p_event_date := ADD_MONTHS (lr_get_details.date_of_birth, 18 * 12);
      END IF;
   END get_in_time_of_event;

   PROCEDURE get_absence_lvl_info (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_fully_capable            OUT NOCOPY VARCHAR2
     ,p_inability_to_work        OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR csr_get_details
      IS
         SELECT paa.person_id
           FROM per_all_assignments_f paa
          WHERE paa.assignment_id = p_assignment_id
            AND p_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date;

      lr_get_details       csr_get_details%ROWTYPE;

      CURSOR csr_get_abs_details (csr_v_person_id NUMBER)
      IS
         SELECT paat.absence_category
               ,paa.date_start
               ,paa.date_end
               ,paa.abs_information3
           FROM per_absence_attendances paa
               ,per_absence_attendance_types paat
          WHERE paa.person_id = csr_v_person_id
            AND paa.absence_attendance_type_id =
                                               paat.absence_attendance_type_id
            AND paat.absence_category = 'S'
            AND paa.date_start >= g_start_date
            AND paa.date_start <= g_end_date
	    ORDER BY paa.date_start desc;

      lr_get_abs_details   csr_get_abs_details%ROWTYPE;
   BEGIN
      OPEN csr_get_details;

      FETCH csr_get_details
       INTO lr_get_details;

      CLOSE csr_get_details;

      OPEN csr_get_abs_details (lr_get_details.person_id);

      FETCH csr_get_abs_details
       INTO lr_get_abs_details;

      CLOSE csr_get_abs_details;

      IF     lr_get_abs_details.abs_information3 IS NOT NULL
         AND lr_get_abs_details.abs_information3 <> 100
      THEN
         p_fully_capable := /*'No';*/ 'false';
         p_inability_to_work :=
                             NVL (lr_get_abs_details.abs_information3, '0');
      ELSE
         p_fully_capable := /*'Yes';*/ 'true';
      /*   p_inability_to_work := '0';*/
      END IF;

   END;

   PROCEDURE get_org_lvl_info (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_local_unit_id            OUT NOCOPY NUMBER
     ,p_legal_employer_id        OUT NOCOPY NUMBER
     ,p_location_id              OUT NOCOPY NUMBER
   )
   IS
      CURSOR csr_get_details
      IS
         SELECT scl.segment2
               ,paa.location_id
           FROM per_all_assignments_f paa
               ,hr_soft_coding_keyflex scl
          WHERE paa.assignment_id = p_assignment_id
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
            AND p_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date;

      lr_get_details           csr_get_details%ROWTYPE;

      -- Cursor to pick up LEGAL EMPLOYER
      CURSOR csr_find_legal_employer (
         csr_v_organization_id               hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hoi3.organization_id legal_id
           FROM hr_all_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_organization_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER';

      lr_find_legal_employer   csr_find_legal_employer%ROWTYPE;
   BEGIN
      OPEN csr_get_details;

      FETCH csr_get_details
       INTO lr_get_details;

      CLOSE csr_get_details;

      p_local_unit_id := lr_get_details.segment2;
      p_location_id := lr_get_details.location_id;


      OPEN csr_find_legal_employer (lr_get_details.segment2);

      FETCH csr_find_legal_employer
       INTO lr_find_legal_employer;

      CLOSE csr_find_legal_employer;

      p_legal_employer_id := lr_find_legal_employer.legal_id;

   END;

   PROCEDURE get_salary (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_before_after             IN       VARCHAR2
     ,p_event                    IN       VARCHAR2
     ,p_monthly_salary           OUT NOCOPY NUMBER
     ,p_yearly_salary            OUT NOCOPY NUMBER
     ,p_annual_salary            OUT NOCOPY NUMBER   -- Changes 2008/2009 Get the annual salary if there is withdrawal
     )
   IS
      l_local_unit_id        NUMBER;
      l_legal_employer_id    NUMBER;
      l_location_id          NUMBER;
      l_balance_type_id      NUMBER;
      l_defined_balance_id   NUMBER;

      CURSOR csr_defined_balance_id (
         csr_v_balance_type_id               NUMBER
        ,csr_v_dimesion                      VARCHAR2
      )
      IS
         SELECT db.defined_balance_id
           FROM pay_defined_balances db
               ,pay_balance_dimensions bd
          WHERE db.balance_type_id = csr_v_balance_type_id
            AND db.balance_dimension_id = bd.balance_dimension_id
            AND bd.database_item_suffix = csr_v_dimesion
            AND bd.legislation_code = 'SE';
   BEGIN
      l_legal_employer_id := NULL;
      l_local_unit_id := NULL;
      l_location_id := NULL;
      get_org_lvl_info (p_assignment_id
                       ,p_effective_date
                       ,l_local_unit_id
                       ,l_legal_employer_id
                       ,l_location_id
                       );


      IF p_before_after = 'AFTER'
      THEN
         l_balance_type_id :=
            record_legal_employer (l_legal_employer_id).field_code ('MS1').events_row
                                                                     (p_event).balance_type_id;

         /* OPEN csr_defined_balance_id(l_balance_type_id,'_ASG_MONTH');
           FETCH csr_defined_balance_id  INTO l_defined_balance_id;
          CLOSE csr_defined_balance_id;*/
         p_monthly_salary :=ceil(
            get_defined_balance_value (l_balance_type_id
                                      ,'_ASG_MONTH'
                                      ,p_assignment_id
                                      ,g_end_date
                                      ));

         p_yearly_salary := 0;
	 p_annual_salary := p_monthly_salary*(12.2);
      ELSE
         l_balance_type_id :=
            record_legal_employer (l_legal_employer_id).field_code ('MS2').events_row
                                                                     (p_event).balance_type_id;


/*
   OPEN csr_defined_balance_id(l_balance_type_id,'_ASG_YTD');
   FETCH csr_defined_balance_id  INTO l_defined_balance_id;
  CLOSE csr_defined_balance_id;
  */

  -- Start Changes  2008/2009
  -- Annual Salary is Fixed Monthly Salary multiplied by 12.2(according to Swedish Industry Association/PTK agreement)
  -- The increase in 12.2 corresponds to the average additional holiday pay.
  /*
         p_yearly_salary :=ceil(
            get_defined_balance_value (l_balance_type_id
                                      ,'_ASG_YTD'
                                      ,p_assignment_id
                                      ,ADD_MONTHS (  TRUNC (g_end_date
                                                           ,'YYYY')
                                                   - 1
                                                  ,12
                                                  )
                                      ));

	 */
	  p_monthly_salary :=ceil(
            get_defined_balance_value (l_balance_type_id
                                      ,'_ASG_MONTH'
                                      ,p_assignment_id
                                      ,g_end_date
                                      ));

          p_yearly_salary := p_monthly_salary*(12.2) ;
	  p_annual_salary := p_yearly_salary ;
 -- End Changes 2008/2009
         p_monthly_salary := 0;
      END IF;

        IF p_monthly_salary IS NULL THEN
	p_monthly_salary := 0;
      END IF;

   END get_salary;

   PROCEDURE get_salary_change_or_not (
      p_assignment_id            IN       NUMBER
     ,p_new_salary               OUT NOCOPY VARCHAR2
     ,p_event_time               OUT NOCOPY DATE
   )
   IS
      l_local_unit_id       NUMBER;
      l_legal_employer_id   NUMBER;
      l_location_id         NUMBER;
      l_element_type_id     NUMBER;

      CURSOR csr_get_element (csr_v_element_type_id NUMBER)
      IS
         SELECT effective_start_date
           FROM pay_element_entries_f
          WHERE assignment_id = p_assignment_id
            AND element_type_id = csr_v_element_type_id
            AND effective_start_date BETWEEN g_start_date AND g_end_date;

      lr_get_element        csr_get_element%ROWTYPE;
   BEGIN
      l_legal_employer_id := NULL;
      l_local_unit_id := NULL;
      l_location_id := NULL;
      get_org_lvl_info (p_assignment_id
                       ,g_end_date
                       ,l_local_unit_id
                       ,l_legal_employer_id
                       ,l_location_id
                       );
      l_element_type_id :=
         record_legal_employer (l_legal_employer_id).field_code ('ET').events_row
                                                                         ('LO').element_type_id;

      lr_get_element := NULL;

      OPEN csr_get_element (l_element_type_id);

      FETCH csr_get_element
       INTO lr_get_element;

      CLOSE csr_get_element;

      IF lr_get_element.effective_start_date IS NULL
      THEN
         p_new_salary := NULL;
         p_event_time := NULL;
      ELSE
         p_new_salary := 'LO';
         p_event_time := lr_get_element.effective_start_date;
      END IF;


   END get_salary_change_or_not;

   PROCEDURE get_salary_cut (
      p_assignment_id            IN       NUMBER
     ,p_effective_date           IN       DATE
     ,p_salary_cut               OUT NOCOPY VARCHAR2
   )
   IS
      l_balance_type_id          NUMBER;
      l_current_yearly_salary    NUMBER;
      l_previous_yearly_salary   NUMBER;
      l_local_unit_id            NUMBER;
      l_legal_employer_id        NUMBER;
      l_location_id              NUMBER;
      l_min_assg_start_date      DATE;
      CURSOR csr_min_assignment (csr_v_assignment_id NUMBER )
	IS
	SELECT min(effective_start_date)
	FROM per_all_assignments_f
	WHERE assignment_id=csr_v_assignment_id;
   BEGIN

      get_org_lvl_info (p_assignment_id
                       ,g_end_date
                       ,l_local_unit_id
                       ,l_legal_employer_id
                       ,l_location_id
                       );
	OPEN csr_min_assignment(p_assignment_id);
		FETCH csr_min_assignment INTO l_min_assg_start_date;
	CLOSE csr_min_assignment;

      l_balance_type_id :=
         record_legal_employer (l_legal_employer_id).field_code ('MS2').events_row
                                                                         ('LO').balance_type_id;

      l_current_yearly_salary :=ceil(
         get_defined_balance_value (l_balance_type_id
                                   ,'_ASG_YTD'
                                   ,p_assignment_id
                                   ,ADD_MONTHS (TRUNC (g_end_date, 'YYYY') - 1
                                               ,12
                                               )
                                   ));

      IF l_min_assg_start_date > ( TRUNC (g_end_date, 'YYYY') - 1) THEN
	l_previous_yearly_salary:=0;
      ELSE
      l_previous_yearly_salary :=ceil(
         get_defined_balance_value (l_balance_type_id
                                   ,'_ASG_YTD'
                                   ,p_assignment_id
                                   , TRUNC (g_end_date, 'YYYY') - 1
                                   ));
      END IF;


      IF l_previous_yearly_salary > l_current_yearly_salary
      THEN
         p_salary_cut := 'Ja';
      ELSE
         p_salary_cut := NULL;
      END IF;
   END;

   PROCEDURE get_end_employment_or_not (
      p_assignment_id            IN       NUMBER
     ,p_withdrawl                OUT NOCOPY VARCHAR2
     ,p_event_time               OUT NOCOPY DATE
     ,p_reason                   OUT NOCOPY VARCHAR2
     ,p_effective_date           OUT NOCOPY DATE
   )
   IS
      l_local_unit_id       NUMBER;
      l_legal_employer_id   NUMBER;
      l_location_id         NUMBER;
      l_element_type_id     NUMBER;

      CURSOR csr_get_assignments (csr_v_assignment_id NUMBER)
      IS
         SELECT   scl.segment2
                 ,scl.segment5
                 ,scl.segment6
                 ,scl.segment7
                 ,GREATEST (effective_start_date, g_start_date)
                                                             "EFF_START_DATE"
                 ,LEAST (effective_end_date, g_end_date) "EFF_END_DATE"
             FROM per_all_assignments_f paa
                 ,hr_soft_coding_keyflex scl
            WHERE paa.assignment_id = p_assignment_id
              AND paa.business_group_id = g_business_group_id
              AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
              AND paa.effective_start_date BETWEEN g_start_date AND g_end_date
         ORDER BY paa.effective_end_date DESC;

      lr_get_assignments    csr_get_assignments%ROWTYPE;
   BEGIN
      OPEN csr_get_assignments (p_assignment_id);

      FETCH csr_get_assignments
       INTO lr_get_assignments;

      CLOSE csr_get_assignments;

      p_effective_date := lr_get_assignments.eff_start_date;


      IF     lr_get_assignments.segment5 IS NOT NULL
         AND lr_get_assignments.segment6 IS NOT NULL
      THEN
         p_withdrawl := 'AV';
         p_event_time :=
                     fnd_date.canonical_to_date (lr_get_assignments.segment6);
         p_reason := '1';
      ELSE
         p_withdrawl := NULL;
         p_event_time := NULL;
         p_reason := NULL;
      END IF;


   END;

   PROCEDURE get_termination_or_not (
      p_assignment_id            IN       NUMBER
     ,p_field_code               IN       VARCHAR2
     ,p_withdrawl                OUT NOCOPY VARCHAR2
     ,p_event_time               OUT NOCOPY DATE
     ,p_reason                   OUT NOCOPY VARCHAR2
     ,p_effective_date           OUT NOCOPY DATE
     ,p_parental_start_date      OUT NOCOPY DATE
   )
   IS
      l_local_unit_id       NUMBER;
      l_legal_employer_id   NUMBER;
      l_location_id         NUMBER;
      l_element_type_id     NUMBER;
      l_input_value_id      NUMBER;

      CURSOR csr_get_element (
         csr_v_element_type_id               NUMBER
        ,csr_v_input_value_id                NUMBER
      )
      IS
         SELECT peef.effective_start_date
               ,peevf.screen_entry_value
           FROM pay_element_entries_f peef
               ,pay_element_entry_values_f peevf
          WHERE peef.assignment_id = p_assignment_id
            AND peef.element_type_id = csr_v_element_type_id
            AND peef.effective_start_date BETWEEN g_start_date AND g_end_date
	    AND peevf.effective_start_date BETWEEN g_start_date AND g_end_date
	    AND peef.element_entry_id=peevf.element_entry_id
            AND peevf.input_value_id = csr_v_input_value_id;

      lr_get_element        csr_get_element%ROWTYPE;
   BEGIN
      l_legal_employer_id := NULL;
      l_local_unit_id := NULL;
      l_location_id := NULL;
      get_org_lvl_info (p_assignment_id
                       ,g_end_date
                       ,l_local_unit_id
                       ,l_legal_employer_id
                       ,l_location_id
                       );

      l_element_type_id := NULL;
      l_input_value_id := NULL;
      l_element_type_id :=
         record_legal_employer (l_legal_employer_id).field_code ('TR').events_row
                                                                 (p_field_code).element_type_id;

      l_input_value_id :=
         record_legal_employer (l_legal_employer_id).field_code ('TR').events_row
                                                                 (p_field_code).input_value_id;

      lr_get_element := NULL;

      OPEN csr_get_element (l_element_type_id, l_input_value_id);

      FETCH csr_get_element
       INTO lr_get_element;
      p_effective_date := lr_get_element.effective_start_date;
      CLOSE csr_get_element;


      p_effective_date := lr_get_element.effective_start_date;


      IF lr_get_element.screen_entry_value IS NULL
      THEN
         p_withdrawl := NULL;
         p_event_time := NULL;
         p_reason := NULL;
      ELSE
         p_withdrawl := 'AV';
         p_reason := lr_get_element.screen_entry_value;
         l_element_type_id := NULL;
         l_input_value_id := NULL;
         l_element_type_id :=
            record_legal_employer (l_legal_employer_id).field_code ('ET').events_row
                                                                (p_field_code).element_type_id;

         l_input_value_id :=
            record_legal_employer (l_legal_employer_id).field_code ('ET').events_row
                                                                (p_field_code).input_value_id;

         lr_get_element := NULL;

         OPEN csr_get_element (l_element_type_id, l_input_value_id);

         FETCH csr_get_element
          INTO lr_get_element;

         CLOSE csr_get_element;


         p_event_time :=
                fnd_date.canonical_to_date (lr_get_element.screen_entry_value);
      END IF;

      IF p_field_code = 'AV2'
      THEN
         l_element_type_id := NULL;
         l_input_value_id := NULL;
         p_parental_start_date := NULL;
         l_element_type_id :=
            record_legal_employer (l_legal_employer_id).field_code ('PL').events_row
                                                                (p_field_code).element_type_id;

         l_input_value_id :=
            record_legal_employer (l_legal_employer_id).field_code ('PL').events_row
                                                                (p_field_code).input_value_id;

         lr_get_element := NULL;

         OPEN csr_get_element (l_element_type_id, l_input_value_id);

         FETCH csr_get_element
          INTO lr_get_element;

         CLOSE csr_get_element;


         p_parental_start_date :=
                fnd_date.canonical_to_date (lr_get_element.screen_entry_value);
      ELSE
         p_parental_start_date := NULL;
      END IF;


   END;
--
--
END pay_se_alecta;

/
