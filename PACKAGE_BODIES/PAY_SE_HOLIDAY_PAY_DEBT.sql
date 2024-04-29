--------------------------------------------------------
--  DDL for Package Body PAY_SE_HOLIDAY_PAY_DEBT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_HOLIDAY_PAY_DEBT" AS
/* $Header: pysehpdr.pkb 120.0.12000000.1 2007/04/20 06:28:12 abhgangu noship $ */
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
   g_package                 VARCHAR2 (33)  := 'PAY_SE_HOLIDAY_PAY_DEBT.';
   g_payroll_action_id       NUMBER;
   g_arc_payroll_action_id   NUMBER;
-- Globals to pick up all the parameter
   g_business_group_id       NUMBER;
   g_effective_date          DATE;
   g_pension_provider_id     NUMBER;
   g_legal_employer_id       NUMBER;
   g_local_unit_id           NUMBER;
   g_request_for             VARCHAR2 (20);
   g_start_date              DATE;
   g_end_date                DATE;
--End of Globals to pick up all the parameter
   g_format_mask             VARCHAR2 (50);
   g_err_num                 NUMBER;
   g_errm                    VARCHAR2 (150);

    /* GET PARAMETER */
    /*FUNCTION GET_PARAMETER(
       p_parameter_string IN VARCHAR2
      ,p_token            IN VARCHAR2
      ,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2
    IS
      l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
      l_start_pos  NUMBER;
      l_delimiter  VARCHAR2(1):=' ';
      l_proc VARCHAR2(40):= g_package||' get parameter ';

    BEGIN
    --
    IF g_debug THEN
        hr_utility.set_location(' Entering Function GET_PARAMETER',10);
    END IF;
    l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
    --
      IF l_start_pos = 0 THEN
        l_delimiter := '|';
        l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
      END IF;
      IF l_start_pos <> 0 THEN
        l_start_pos := l_start_pos + length(p_token||'=');
        l_parameter := substr(p_parameter_string,
       l_start_pos,
       instr(p_parameter_string||' ',
       l_delimiter,l_start_pos)
       - l_start_pos);
        IF p_segment_number IS NOT NULL THEN
          l_parameter := ':'||l_parameter||':';
          l_parameter := substr(l_parameter,
         instr(l_parameter,':',1,p_segment_number)+1,
         instr(l_parameter,':',1,p_segment_number+1) -1
         - instr(l_parameter,':',1,p_segment_number));
        END IF;
      END IF;
      --
      RETURN l_parameter;
    IF g_debug THEN
         hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
    END IF;
    END;
   */
    /* GET PARAMETER */
   FUNCTION get_parameter (
      p_parameter_string   IN   VARCHAR2
    , p_token              IN   VARCHAR2
    , p_segment_number     IN   NUMBER DEFAULT NULL
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

      IF l_start_pos <> 0
      THEN
         l_start_pos := l_start_pos + LENGTH (p_token || '=');
         l_parameter :=
            SUBSTR (p_parameter_string
                  , l_start_pos
                  ,   INSTR (p_parameter_string || ' '
                           , l_delimiter
                           , l_start_pos
                            )
                    - (l_start_pos)
                   );

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
      p_payroll_action_id        IN              NUMBER        -- In parameter
    , p_business_group_id        OUT NOCOPY      NUMBER      -- Core parameter
    , p_effective_date           OUT NOCOPY      DATE        -- Core parameter
    , p_legal_employer_id        OUT NOCOPY      NUMBER      -- User parameter
    , p_request_for_all_or_not   OUT NOCOPY      VARCHAR2    -- User parameter
    , p_start_date               OUT NOCOPY      DATE        -- User parameter
    , p_end_date                 OUT NOCOPY      DATE        -- User parameter
   )
   IS
      CURSOR csr_parameter_info (p_payroll_action_id NUMBER)
      IS
         SELECT TO_NUMBER
                   (SUBSTR
                       (pay_se_holiday_pay_debt.get_parameter
                                                      (legislative_parameters
                                                     , 'LEGAL_EMPLOYER'
                                                      )
                      , 1
                      ,   LENGTH
                             (pay_se_holiday_pay_debt.get_parameter
                                                      (legislative_parameters
                                                     , 'LEGAL_EMPLOYER'
                                                      )
                             )
                        - 1
                       )
                   ) legal
              , SUBSTR
                   (pay_se_holiday_pay_debt.get_parameter
                                                      (legislative_parameters
                                                     , 'REQUEST_FOR'
                                                      )
                  , 1
                  ,   LENGTH
                         (pay_se_holiday_pay_debt.get_parameter
                                                      (legislative_parameters
                                                     , 'REQUEST_FOR'
                                                      )
                         )
                    - 1
                   ) request_for
              , (pay_se_holiday_pay_debt.get_parameter
                                                      (legislative_parameters
                                                     , 'EFFECTIVE_START_DATE'
                                                      )
                ) eff_start_date
              , (pay_se_holiday_pay_debt.get_parameter
                                                      (legislative_parameters
                                                     , 'EFFECTIVE_END_DATE'
                                                      )
                ) eff_end_date
              , effective_date effective_date, business_group_id bg_id
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_payroll_action_id;

      lr_parameter_info   csr_parameter_info%ROWTYPE;
      l_proc              VARCHAR2 (240)
                                       := g_package || ' GET_ALL_PARAMETERS ';
   BEGIN
      fnd_file.put_line (fnd_file.LOG
                       , 'Entering Procedure GET_ALL_PARAMETER '
                        );
      fnd_file.put_line (fnd_file.LOG
                       , 'Payroill Action iD   ' || p_payroll_action_id
                        );

      OPEN csr_parameter_info (p_payroll_action_id);

      --FETCH csr_parameter_info into lr_parameter_info;
      FETCH csr_parameter_info
       INTO lr_parameter_info;

      CLOSE csr_parameter_info;

      p_legal_employer_id := lr_parameter_info.legal;
      fnd_file.put_line (fnd_file.LOG
                       ,    'lr_parameter_info.Legal   '
                         || lr_parameter_info.legal
                        );
      p_request_for_all_or_not := lr_parameter_info.request_for;
      fnd_file.put_line (fnd_file.LOG
                       ,    'lr_parameter_info.REQUEST_FOR   '
                         || lr_parameter_info.request_for
                        );
      fnd_file.put_line (fnd_file.LOG
                       ,    'lr_parameter_info.EFF_START_DATE   '
                         || lr_parameter_info.eff_start_date
                        );
      p_start_date :=
                 fnd_date.canonical_to_date (lr_parameter_info.eff_start_date);
      fnd_file.put_line (fnd_file.LOG
                       ,    'lr_parameter_info.EFF_END_DATE   '
                         || lr_parameter_info.eff_end_date
                        );
      p_end_date  :=
                   fnd_date.canonical_to_date (lr_parameter_info.eff_end_date);
      fnd_file.put_line (fnd_file.LOG
                       ,    'lr_parameter_info.Effective_date   '
                         || lr_parameter_info.effective_date
                        );
      p_effective_date := lr_parameter_info.effective_date;
      p_business_group_id := lr_parameter_info.bg_id;
      fnd_file.put_line (fnd_file.LOG, 'After  csr_parameter_info in  ');
      --fnd_file.put_line(fnd_file.log,'After  p_pension_provider_id  '  || p_pension_provider_id);
      fnd_file.put_line (fnd_file.LOG
                       ,    'After  p_legal_employer_id  in  '
                         || p_legal_employer_id
                        );

      --fnd_file.put_line(fnd_file.log,'After  p_local_unit_id in  ' || p_local_unit_id  );
      --fnd_file.put_line(fnd_file.log,'After  p_archive' || p_archive  );
      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure GET_ALL_PARAMETERS'
                                , 30);
      END IF;
   END get_all_parameters;

   /* RANGE CODE */
   PROCEDURE range_code (
      p_payroll_action_id   IN              NUMBER
    , p_sql                 OUT NOCOPY      VARCHAR2
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
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT o1.NAME legal_employer_name
              , hoi2.org_information2 org_number
              , hoi1.organization_id legal_id
           FROM hr_organization_units o1
              , hr_organization_information hoi1
              , hr_organization_information hoi2
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
         csr_v_legal_employer_id      NUMBER
       , csr_v_canonical_start_date   DATE
       , csr_v_canonical_end_date     DATE
      )
      IS
         SELECT   '1'
             FROM pay_payroll_actions appa
                , pay_assignment_actions act
                , per_all_assignments_f as1
                , pay_payroll_actions ppa
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
         ORDER BY as1.person_id, act.assignment_id;

      l_le_has_employee          VARCHAR2 (2);
-- Archiving the data , as this will fire once
   BEGIN
      fnd_file.put_line (fnd_file.LOG, 'In  RANGE_CODE 0');

      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure RANGE_CODE', 40);
      END IF;

      p_sql       :=
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
      pay_se_holiday_pay_debt.get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_request_for
                                                , g_start_date
                                                , g_end_date
                                                 );
      fnd_file.put_line (fnd_file.LOG
                       ,    'Range Legal Emp ID          ==> '
                         || g_legal_employer_id
                        );

-- *****************************************************************************
 -- TO pick up the required details for Pension Providers
      OPEN csr_legal_employer_details (g_legal_employer_id);

      FETCH csr_legal_employer_details
       INTO l_legal_employer_details;

      CLOSE csr_legal_employer_details;

-- *****************************************************************************
      fnd_file.put_line (fnd_file.LOG
                       ,    'After CURSOR Legal Emp DETAILS         ==> '
                         || g_legal_employer_id
                        );
-- *****************************************************************************
      -- Insert the report Parameters
      pay_action_information_api.create_action_information
         (p_action_information_id            => l_action_info_id
        , p_action_context_id                => p_payroll_action_id
        , p_action_context_type              => 'PA'
        , p_object_version_number            => l_ovn
        , p_effective_date                   => g_effective_date
        , p_source_id                        => NULL
        , p_source_text                      => NULL
        , p_action_information_category      => 'EMEA REPORT DETAILS'
        , p_action_information1              => 'PYSEHPDA'
        , p_action_information2              => l_legal_employer_details.legal_employer_name
        , p_action_information3              => g_legal_employer_id
        , p_action_information4              => g_request_for
        , p_action_information5              => fnd_date.date_to_canonical
                                                                 (g_start_date)
        , p_action_information6              => fnd_date.date_to_canonical
                                                                   (g_end_date)
        , p_action_information7              => NULL
        , p_action_information8              => NULL
        , p_action_information9              => NULL
        , p_action_information10             => NULL
         );
-- *****************************************************************************
      fnd_file.put_line (fnd_file.LOG
                       , ' ================ ALL ================ '
                        );
      --fnd_file.put_line(fnd_file.log,'PENSION provider name ==> '||lr_pension_provider_details.NAME );
      --fnd_file.put_line(fnd_file.log,'PENSION provider ID   ==> '||g_pension_provider_id);
      fnd_file.put_line (fnd_file.LOG
                       ,    'Legal Emp Name        ==> '
                         || l_legal_employer_details.legal_employer_name
                        );
      fnd_file.put_line (fnd_file.LOG
                       , 'Legal Emp ID          ==> ' || g_legal_employer_id
                        );
      fnd_file.put_line (fnd_file.LOG
                       , 'g_request_for      ==> ' || g_request_for
                        );
      --fnd_file.put_line(fnd_file.log,'Local Unit ID         ==> '||g_local_unit_id);
      --fnd_file.put_line(fnd_file.log,'acti_info_id          ==> '||l_action_info_id );
      fnd_file.put_line (fnd_file.LOG, ' ================================ ');

-- *****************************************************************************
      IF g_request_for = 'REQUESTING_ORG'
      THEN
         -- Information regarding the Legal Employer
         OPEN csr_legal_employer_details (g_legal_employer_id);

         FETCH csr_legal_employer_details
          INTO l_legal_employer_details;

         CLOSE csr_legal_employer_details;

         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
           , p_action_context_id                => p_payroll_action_id
           , p_action_context_type              => 'PA'
           , p_object_version_number            => l_ovn
           , p_effective_date                   => g_effective_date
           , p_source_id                        => NULL
           , p_source_text                      => NULL
           , p_action_information_category      => 'EMEA REPORT INFORMATION'
           , p_action_information1              => 'PYSEHPDA'
           , p_action_information2              => 'LE'
           , p_action_information3              => g_legal_employer_id
           , p_action_information4              => l_legal_employer_details.legal_employer_name
           , p_action_information5              => l_legal_employer_details.org_number
           , p_action_information6              => NULL
           , p_action_information7              => NULL
           , p_action_information8              => NULL
           , p_action_information9              => NULL
           , p_action_information10             => NULL
            );
-- *****************************************************************************
      ELSE
-- *****************************************************************************
         FOR rec_legal_employer_details IN csr_legal_employer_details (NULL)
         LOOP
            OPEN csr_check_empty_le (rec_legal_employer_details.legal_id
                                   , g_start_date
                                   , g_end_date
                                    );

            FETCH csr_check_empty_le
             INTO l_le_has_employee;

            CLOSE csr_check_empty_le;

            IF l_le_has_employee = '1'
            THEN
               pay_action_information_api.create_action_information
                  (p_action_information_id            => l_action_info_id
                 , p_action_context_id                => p_payroll_action_id
                 , p_action_context_type              => 'PA'
                 , p_object_version_number            => l_ovn
                 , p_effective_date                   => g_effective_date
                 , p_source_id                        => NULL
                 , p_source_text                      => NULL
                 , p_action_information_category      => 'EMEA REPORT INFORMATION'
                 , p_action_information1              => 'PYSEHPDA'
                 , p_action_information2              => 'LE'
                 , p_action_information3              => rec_legal_employer_details.legal_id
                 , p_action_information4              => rec_legal_employer_details.legal_employer_name
                 , p_action_information5              => rec_legal_employer_details.org_number
                 , p_action_information6              => NULL
                 , p_action_information7              => NULL
                 , p_action_information8              => NULL
                 , p_action_information9              => NULL
                 , p_action_information10             => NULL
                  );
            END IF;
         END LOOP;
      END IF;                                          -- FOR G_LEGAL_EMPLOYER

      --END IF; -- G_Archive End
      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure RANGE_CODE', 50);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Return cursor that selects no rows
         p_sql       :=
               'select 1 from dual where to_char(:payroll_action_id) = dummy';
   END range_code;

   /* ASSIGNMENT ACTION CODE */
   PROCEDURE assignment_action_code (
      p_payroll_action_id   IN   NUMBER
    , p_start_person        IN   NUMBER
    , p_end_person          IN   NUMBER
    , p_chunk               IN   NUMBER
   )
   IS
      CURSOR csr_prepaid_assignments_le (
         p_payroll_action_id      NUMBER
       , p_start_person           NUMBER
       , p_end_person             NUMBER
       , p_legal_employer_id      NUMBER
       , l_canonical_start_date   DATE
       , l_canonical_end_date     DATE
      )
      IS
         /* SELECT   as1.person_id person_id, act.assignment_id assignment_id
                 , act.assignment_action_id run_action_id
                 , act1.assignment_action_id prepaid_action_id
              FROM pay_payroll_actions ppa
                 , pay_payroll_actions appa
                 , pay_payroll_actions appa2
                 , pay_assignment_actions act
                 , pay_assignment_actions act1
                 , pay_action_interlocks pai
                 , per_all_assignments_f as1
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
               AND ppa.effective_date BETWEEN as1.effective_start_date
                                          AND as1.effective_end_date
               AND act.action_status = 'C'                         -- Completed
               AND act.assignment_action_id = pai.locked_action_id
               AND act1.assignment_action_id = pai.locking_action_id
               AND act1.action_status = 'C'                        -- Completed
               AND act1.payroll_action_id = appa2.payroll_action_id
               AND appa2.action_type IN ('P', 'U')
               AND appa2.effective_date BETWEEN l_canonical_start_date
                                            AND l_canonical_end_date
               -- Prepayments or Quickpay Prepayments
               AND act.tax_unit_id = act1.tax_unit_id
               AND act.tax_unit_id = NVL (p_legal_employer_id, act.tax_unit_id)
          ORDER BY as1.person_id, act.assignment_id;
          */
         SELECT   as1.person_id person_id, act.assignment_id assignment_id
                , act.assignment_action_id run_action_id
             FROM pay_payroll_actions appa
                , pay_assignment_actions act
                , per_all_assignments_f as1
                , pay_payroll_actions ppa
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
              AND ppa.effective_date BETWEEN as1.effective_start_date
                                         AND as1.effective_end_date
         ORDER BY as1.person_id, act.assignment_id;

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name   ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue, ff_database_items di
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
      IF g_debug
      THEN
         hr_utility.set_location
                               (' Entering Procedure ASSIGNMENT_ACTION_CODE'
                              , 60
                               );
      END IF;

      fnd_file.put_line (fnd_file.LOG, ' ASSIGNMENT_ACTION_CODE ');
      pay_se_holiday_pay_debt.get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_request_for
                                                , g_start_date
                                                , g_end_date
                                                 );
      l_canonical_start_date := g_start_date;
      l_canonical_end_date := g_end_date;
      l_prepay_action_id := 0;
      --fnd_file.put_line(fnd_file.log,' g_local_unit_id '|| g_local_unit_id);

      --fnd_file.put_line(fnd_file.log,' INSIDE IF LOCAL UNIT NOT NULL ');
      fnd_file.put_line (fnd_file.LOG
                       , ' p_payroll_action_id ==> ' || p_payroll_action_id
                        );
      fnd_file.put_line (fnd_file.LOG
                       , ' g_legal_employer_id ==> ' || g_legal_employer_id
                        );
      --fnd_file.put_line(fnd_file.log,' g_local_unit_id ==> ' || g_local_unit_id);
      --fnd_file.put_line(fnd_file.log,' g_pension_provider_id ==> ' || g_pension_provider_id);
      fnd_file.put_line (fnd_file.LOG
                       , ' g_effective_date ==> ' || g_effective_date
                        );
      fnd_file.put_line (fnd_file.LOG
                       ,    ' l_canonical_start_date ==> '
                         || l_canonical_start_date
                        );
      fnd_file.put_line (fnd_file.LOG
                       , ' l_canonical_end_date ==> ' || l_canonical_end_date
                        );

      --fnd_file.put_line(fnd_file.log,' INSIDE ELS LOCAL UNIT NULL ');
	l_assignment_id := 0;
      FOR rec_prepaid_assignments IN
         csr_prepaid_assignments_le (p_payroll_action_id
                                   , p_start_person
                                   , p_end_person
                                   , g_legal_employer_id
                                   , l_canonical_start_date
                                   , l_canonical_end_date
                                    )
      LOOP
         --fnd_file.put_line(fnd_file.log,' LE Inside the Csr Prepaid Cursor ');
         IF l_assignment_id <> rec_prepaid_assignments.assignment_id
         THEN
         SELECT pay_assignment_actions_s.NEXTVAL
           INTO l_actid
           FROM DUAL;

         -- Create the archive assignment action
         hr_nonrun_asact.insact (l_actid
                               , rec_prepaid_assignments.assignment_id
                               , p_payroll_action_id
                               , p_chunk
                               , NULL
                                );
      -- Create archive to prepayment assignment action interlock
      --
      --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
      END IF;

      -- create archive to master assignment action interlock
      --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
      l_assignment_id := rec_prepaid_assignments.assignment_id;
      END LOOP;

      fnd_file.put_line
                     (fnd_file.LOG
                    , ' After Ending Assignment Act Code  the Locking Cursor '
                     );

      IF g_debug
      THEN
         hr_utility.set_location
                                (' Leaving Procedure ASSIGNMENT_ACTION_CODE'
                               , 70
                                );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF g_debug
         THEN
            hr_utility.set_location ('error raised assignment_action_code '
                                   , 5
                                    );
         END IF;

         RAISE;
   END assignment_action_code;

/*fffffffffffffffffffffffffff*/

   /* INITIALIZATION CODE */
   PROCEDURE initialization_code (p_payroll_action_id IN NUMBER)
   IS
      l_action_info_id      NUMBER;
      l_ovn                 NUMBER;
      l_count               NUMBER        := 0;
      l_business_group_id   NUMBER;
      l_start_date          VARCHAR2 (20);
      l_end_date            VARCHAR2 (20);
      l_effective_date      DATE;
      l_payroll_id          NUMBER;
      l_consolidation_set   NUMBER;
      l_prev_prepay         NUMBER        := 0;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure INITIALIZATION_CODE'
                                , 80
                                 );
      END IF;

      fnd_file.put_line (fnd_file.LOG, 'In INIT_CODE 0');
      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_legal_employer_id := NULL;
      pay_se_holiday_pay_debt.get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_legal_employer_id
                                                , g_request_for
                                                , g_start_date
                                                , g_end_date
                                                 );
      fnd_file.put_line
         (fnd_file.LOG
        , 'In the  INITIALIZATION_CODE After Initiliazing the global parameter '
         );

      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure INITIALIZATION_CODE'
                                , 90
                                 );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_err_num   := SQLCODE;

         IF g_debug
         THEN
            hr_utility.set_location (   'ORA_ERR: '
                                     || g_err_num
                                     || 'In INITIALIZATION_CODE'
                                   , 180
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
           FROM ff_user_entities u, ff_database_items d
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
                               , 240
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
                                , 250
                                 );
      END IF;
   END get_defined_balance_id;

   FUNCTION get_defined_balance_value (
      p_user_name          IN   VARCHAR2
    , p_in_assignment_id   IN   NUMBER
    , p_in_virtual_date    IN   DATE
    , p_tax_unit_id        IN   NUMBER
    , p_local_unit_id      IN   NUMBER
   )
      RETURN NUMBER
   IS
      /* Cursor to retrieve Defined Balance Id */
      CURSOR csr_def_bal_id (p_user_name VARCHAR2)
      IS
         SELECT u.creator_id
           FROM ff_user_entities u, ff_database_items d
          WHERE d.user_name = p_user_name
            AND u.user_entity_id = d.user_entity_id
            AND (u.legislation_code = 'SE')
            AND (u.business_group_id IS NULL)
            AND u.creator_type = 'B';

      l_defined_balance_id     ff_user_entities.user_entity_id%TYPE;
      l_return_balance_value   NUMBER;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location
                             (' Entering Function GET_DEFINED_BALANCE_VALUE'
                            , 240
                             );
      END IF;

      OPEN csr_def_bal_id (p_user_name);

      FETCH csr_def_bal_id
       INTO l_defined_balance_id;

      CLOSE csr_def_bal_id;

      pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id);
      pay_balance_pkg.set_context('LOCAL_UNIT_ID',p_local_unit_id);

      l_return_balance_value :=
         TO_CHAR
            (pay_balance_pkg.get_value
                                (p_defined_balance_id      => l_defined_balance_id
                               , p_assignment_id           => p_in_assignment_id
                               , p_virtual_date            => p_in_virtual_date
                                )
           , '999999999D99'
            );
      RETURN l_return_balance_value;

      IF g_debug
      THEN
         hr_utility.set_location
                              (' Leaving Function GET_DEFINED_BALANCE_VALUE'
                             , 250
                              );
      END IF;
   END get_defined_balance_value;

   /* ARCHIVE CODE */
   PROCEDURE archive_code (
      p_assignment_action_id   IN   NUMBER
    , p_effective_date         IN   DATE
   )
   IS
      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name   ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue, ff_database_items di
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
      l_employee_name               VARCHAR2 (240);
      l_employee_number             VARCHAR2 (240);
      l_employee_code               VARCHAR2 (240);
      l_employee_pin                VARCHAR2 (240);
      l_holiday_pay_per_day         NUMBER                                := 0;
      l_total_paid_days             NUMBER                                := 0;
      l_total_paid_days_amount      NUMBER                                := 0;
      l_total_saved_days            NUMBER                                := 0;
      l_total_saved_days_amount     NUMBER                                := 0;
      l_total_earned_days           NUMBER                                := 0;
      l_total_earned_days_amount    NUMBER                                := 0;
      l_original_total_paid_days    NUMBER                                := 0;
      l_action_id                   VARCHAR2 (2);
      l_local_unit_id_fetched       NUMBER;
      l_eit_local_unit              NUMBER;
      l_legal_employer_id_fetched   NUMBER;
      -- Temp needed Variables
      l_person_id                   per_all_people_f.person_id%TYPE;
      l_assignment_id               per_all_assignments_f.assignment_id%TYPE;

      -- Temp needed Variables

      -- End of place for Variables which fetches the values to be archived

      -- The place for Cursor  which fetches the values to be archived

      --
            -- Cursor to pick up

      /* Cursor to retrieve Person Details */
      CURSOR csr_get_person_details (p_asg_act_id NUMBER)
      IS
         SELECT pap.last_name, pap.pre_name_adjunct, pap.first_name
              , pap.national_identifier, pap.person_id, pac.assignment_id
              , paa.assignment_number, paa.employee_category
           FROM pay_assignment_actions pac
              , per_all_assignments_f paa
              , per_all_people_f pap
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
         SELECT scl.segment2, scl.segment8
           FROM per_all_assignments_f paa
              , hr_soft_coding_keyflex scl
              , pay_assignment_actions pasa
          WHERE pasa.assignment_action_id = p_assignment_action_id
            AND pasa.assignment_id = paa.assignment_id
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
            AND paa.primary_flag = 'Y'
            AND p_effective_date BETWEEN paa.effective_start_date
                                     AND paa.effective_end_date;

      lr_get_segment2               csr_get_segment2%ROWTYPE;

      -- Cursor to pick up LEGAL EMPLOYER
      CURSOR csr_find_legal_employer (
         csr_v_organization_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hoi3.organization_id legal_id
           FROM hr_all_organization_units o1
              , hr_organization_information hoi1
              , hr_organization_information hoi2
              , hr_organization_information hoi3
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
         csr_v_local_unit_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT o1.NAME, hoi2.org_information1
           FROM hr_organization_units o1
              , hr_organization_information hoi1
              , hr_organization_information hoi2
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id = csr_v_local_unit_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_LOCAL_UNIT_DETAILS';

      lr_local_unit_details         csr_local_unit_details%ROWTYPE;
      -- End of Cursors
      l_period_start_date           DATE;
      l_period_end_date             DATE;
-- Cursor to pick up the Absence details
--#########################################

   -- End of place for Cursor  which fetches the values to be archived
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure ARCHIVE_CODE', 380);
      END IF;

      fnd_file.put_line (fnd_file.LOG, 'Entering  ARCHIVE_CODE  ');

-- *****************************************************************************
   -- TO pick up the PIN
      OPEN csr_get_person_details (p_assignment_action_id);

      FETCH csr_get_person_details
       INTO lr_get_person_details;

      CLOSE csr_get_person_details;

      l_employee_pin := lr_get_person_details.national_identifier;

      IF lr_get_person_details.pre_name_adjunct IS NULL
      THEN
         l_employee_name :=
               lr_get_person_details.last_name
            || ' '
            || lr_get_person_details.first_name;
      ELSE
         l_employee_name :=
               lr_get_person_details.last_name
            || ' '
            || lr_get_person_details.pre_name_adjunct
            || ' '
            || lr_get_person_details.first_name;
      END IF;

      l_employee_number := lr_get_person_details.assignment_number;
      l_employee_code := lr_get_person_details.employee_category;
      fnd_file.put_line (fnd_file.LOG
                       , ' ==============PERSON================== '
                        );
      fnd_file.put_line (fnd_file.LOG
                       , 'l_Employee_Pin     ==> ' || l_employee_pin
                        );
      fnd_file.put_line (fnd_file.LOG
                       , 'l_Employee_name    ==> ' || l_employee_name
                        );
      fnd_file.put_line (fnd_file.LOG, ' ================================ ');

-- *****************************************************************************
-- TO pick up the Local Unit  Sub-disbursement Number
      OPEN csr_get_segment2 ();

      FETCH csr_get_segment2
       INTO lr_get_segment2;

      CLOSE csr_get_segment2;

      l_local_unit_id_fetched := lr_get_segment2.segment2;

      OPEN csr_find_legal_employer (l_local_unit_id_fetched);

      FETCH csr_find_legal_employer
       INTO lr_find_legal_employer;

      CLOSE csr_find_legal_employer;

      l_legal_employer_id_fetched := lr_find_legal_employer.legal_id;
-- *****************************************************************************
    -- Pick up Person ID
      l_person_id := lr_get_person_details.person_id;
      fnd_file.put_line (fnd_file.LOG
                       , 'l_person_id        ==> ' || l_person_id
                        );
-- *****************************************************************************

      -- *****************************************************************************
-- Pick up the Balance value
      l_assignment_id := lr_get_person_details.assignment_id;
      fnd_file.put_line (fnd_file.LOG
                       , 'l_assignment_id    ==> ' || l_assignment_id
                        );

-- *****************************************************************************
-- Setting the context
      BEGIN
         fnd_file.put_line (fnd_file.LOG
                          , 'l_assignment_id    ==> ' || l_assignment_id
                           );
         pay_balance_pkg.set_context ('ASSIGNMENT_ID', l_assignment_id);
         fnd_file.put_line (fnd_file.LOG
                          ,    'L_LEGAL_EMPLOYER_ID_FETCHED    ==> '
                            || l_legal_employer_id_fetched
                           );
         pay_balance_pkg.set_context ('TAX_UNIT_ID'
                                    , l_legal_employer_id_fetched
                                     );
         fnd_file.put_line (fnd_file.LOG
                          ,    'l_local_unit_id_fetched    ==> '
                            || l_local_unit_id_fetched
                           );
         pay_balance_pkg.set_context ('LOCAL_UNIT_ID'
                                    , l_local_unit_id_fetched);
         fnd_file.put_line (fnd_file.LOG, 'G_END_DATE    ==> ' || g_end_date);
         pay_balance_pkg.set_context ('DATE_EARNED', g_end_date);
         fnd_file.put_line (fnd_file.LOG
                          , 'l_assignment_id    ==> ' || l_assignment_id
                           );
         pay_balance_pkg.set_context ('JURISDICTION_CODE', NULL);
         pay_balance_pkg.set_context ('SOURCE_ID', NULL);
         pay_balance_pkg.set_context ('TAX_GROUP', NULL);
      END;

-- *****************************************************************************
-- getting Balance Values
      l_holiday_pay_per_day :=
         TO_CHAR
            (get_defined_balance_value ('HOLIDAY_PAY_PER_DAY_ASG_LE_HY_YEAR'
                                      , l_assignment_id
                                      , g_end_date
                                      ,l_legal_employer_id_fetched
                                      ,l_local_unit_id_fetched
                                       )
           , '999999999D99'
            );
/*             OPEN  csr_Get_Defined_Balance_Id( 'HOLIDAY_PAY_PER_DAY_ASG_LE_HY_YEAR');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                --fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

            L_HOLIDAY_PAY_PER_DAY :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_end_date ),'999999999D99') ;
*/
/*             OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_PAID_HOLIDAY_DAYS_TAKEN_ASG_LE_HY_YEAR');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

                fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                --fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

            L_TOTAL_PAID_DAYS :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_end_date ),'999999999D99') ;
*/
      l_total_paid_days :=
         TO_CHAR
            (get_defined_balance_value
                              ('TOTAL_PAID_HOLIDAY_DAYS_TAKEN_ASG_LE_HY_YEAR'
                             , l_assignment_id
                             , g_end_date
                             ,l_legal_employer_id_fetched
                             ,l_local_unit_id_fetched
                              )
           , '999999999D99'
            );
/*
            OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_HOLIDAY_PAY_ASG_LE_HY_YEAR');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

                --fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                --fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

            L_TOTAL_PAID_DAYS_AMOUNT :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_end_date ),'999999999D99') ;
*/
      l_total_paid_days_amount :=
         TO_CHAR
              (get_defined_balance_value ('TOTAL_HOLIDAY_PAY_ASG_LE_HY_YEAR'
                                        , l_assignment_id
                                        , g_end_date
                                        ,l_legal_employer_id_fetched
                                        ,l_local_unit_id_fetched
                                         )
             , '999999999D99'
              );
/*
   OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SAVED_HOLIDAY_DAYS_TAKEN_ASG_LE_HY_YEAR');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

                --fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                --fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

            L_TOTAL_SAVED_DAYS :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_end_date ),'999999999D99') ;
*/
      l_total_saved_days :=
         TO_CHAR
            (get_defined_balance_value
                             ('TOTAL_SAVED_HOLIDAY_DAYS_TAKEN_ASG_LE_HY_YEAR'
                            , l_assignment_id
                            , g_end_date
                            ,l_legal_employer_id_fetched
                            ,l_local_unit_id_fetched
                             )
           , '999999999D99'
            );
/*
            OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_SAVED_HOLIDAY_PAY_ASG_LE_HY_YEAR');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

                --fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                --fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

            L_TOTAL_SAVED_DAYS_AMOUNT  :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_end_date ),'999999999D99') ;
*/
      l_total_saved_days_amount :=
         TO_CHAR
            (get_defined_balance_value
                                    ('TOTAL_SAVED_HOLIDAY_PAY_ASG_LE_HY_YEAR'
                                   , l_assignment_id
                                   , g_end_date
                                   ,l_legal_employer_id_fetched
                                   ,l_local_unit_id_fetched
                                    )
           , '999999999D99'
            );
      l_original_total_paid_days :=
         TO_CHAR
            (get_defined_balance_value
                                    ('TOTAL_PAID_HOLIDAY_DAYS_ASG_LE_HY_YEAR'
                                   , l_assignment_id
                                   , g_end_date
                                   ,l_legal_employer_id_fetched
                                   ,l_local_unit_id_fetched
                                    )
           , '999999999D99'
            );
      l_total_earned_days := l_original_total_paid_days - l_total_paid_days;

      IF l_total_earned_days <= 0
      THEN
         l_total_earned_days := 0;
      END IF;

      l_total_earned_days_amount :=
                                   l_total_earned_days * l_holiday_pay_per_day;

/*
         OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_PAID_HOLIDAY_DAYS_TAKEN_ASG_LE_HY_YEAR');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

                --fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                --fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

            L_TOTAL_EARNED_DAYS  :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_end_date ),'999999999D99') ;
*/
/*       OPEN  csr_Get_Defined_Balance_Id( 'TOTAL_PAID_HOLIDAY_DAYS_ASG_LE_HY_YEAR');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

                --fnd_file.put_line(fnd_file.log,'DEFINED_BALANCE_ID ==> ' ||lr_Get_Defined_Balance_Id.creator_id );
                --fnd_file.put_line(fnd_file.log,'g_effective_date   ==> ' ||g_effective_date );

            L_TOTAL_EARNED_DAYS_AMOUNT  :=to_char(pay_balance_pkg.get_value
                                        (P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id,
                                         P_ASSIGNMENT_ID =>l_assignment_id ,
                                         P_VIRTUAL_DATE =>  g_end_date ),'999999999D99') ;

*/
        -- End of Pickingup the Data
      BEGIN
         SELECT 1
           INTO l_flag
           FROM pay_action_information
          WHERE action_information_category = 'EMEA REPORT DETAILS'
            AND action_information1 = 'PYSEHPDA'
            AND action_context_id = p_assignment_action_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            --fnd_file.put_line(fnd_file.log,'Not found  In Archive record ' );
            fnd_file.put_line (fnd_file.LOG
                             , 'g_payroll_action_id ' || g_payroll_action_id
                              );
            pay_action_information_api.create_action_information
               (p_action_information_id            => l_action_info_id
              , p_action_context_id                => p_assignment_action_id
              , p_action_context_type              => 'AAP'
              , p_object_version_number            => l_ovn
              , p_effective_date                   => l_effective_date
              , p_source_id                        => NULL
              , p_source_text                      => NULL
              , p_action_information_category      => 'EMEA REPORT INFORMATION'
              , p_action_information1              => 'PYSEHPDA'
              , p_action_information2              => 'PER'
              , p_action_information3              => g_payroll_action_id
              , p_action_information4              => l_employee_code
              , p_action_information5              => l_employee_number
              , p_action_information6              => l_employee_name
              , p_action_information7              => fnd_number.number_to_canonical
                                                         (l_holiday_pay_per_day
                                                         )
              , p_action_information8              => fnd_number.number_to_canonical
                                                            (l_total_paid_days)
              , p_action_information9              => fnd_number.number_to_canonical
                                                         (l_total_paid_days_amount
                                                         )
              , p_action_information10             => fnd_number.number_to_canonical
                                                           (l_total_saved_days)
              , p_action_information11             => fnd_number.number_to_canonical
                                                         (l_total_saved_days_amount
                                                         )
              , p_action_information12             => fnd_number.number_to_canonical
                                                          (l_total_earned_days)
              , p_action_information13             => fnd_number.number_to_canonical
                                                         (l_total_earned_days_amount
                                                         )
              , p_action_information14             => l_local_unit_id_fetched
              , p_action_information15             => l_legal_employer_id_fetched
              , p_action_information16             => NULL
              , p_action_information17             => NULL
              , p_action_information18             => NULL
              , p_action_information19             => NULL
              , p_action_information20             => NULL
              , p_action_information21             => NULL
              , p_action_information22             => NULL
              , p_action_information23             => NULL
              , p_action_information24             => NULL
              , p_action_information25             => NULL
              , p_action_information26             => NULL
              , p_action_information27             => NULL
              , p_action_information28             => NULL
              , p_action_information29             => NULL
              , p_action_information30             => l_person_id
              , p_assignment_id                    => l_assignment_id
               );
            fnd_file.put_line (fnd_file.LOG
                             , 'l_action_info_id ==> ' || l_action_info_id
                              );
            fnd_file.put_line (fnd_file.LOG
                             , 'l_action_info_id ==> ' || l_person_id
                              );
         WHEN OTHERS
         THEN
            NULL;
      END;

--END IF;
      fnd_file.put_line (fnd_file.LOG, 'Leaving Procedure ARCHIVE_CODE');

      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure ARCHIVE_CODE', 390);
      END IF;
   END archive_code;

   --- Report XML generating code
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB)
   IS
      l_xfdf_string    CLOB;
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
      current_index    PLS_INTEGER;
      l_iana_charset   VARCHAR2 (50);
   BEGIN
      l_iana_charset := hr_se_utility.get_iana_charset;
      hr_utility.set_location ('Entering WritetoCLOB ', 70);
      l_str1      :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT><HPDR>';
      l_str2      := '<';
      l_str3      := '>';
      l_str4      := '</';
      l_str5      := '>';
      l_str6      := '</HPDR></ROOT>';
      l_str7      :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT></ROOT>';
      l_str10     := '<HPDR>';
      l_str11     := '</HPDR>';
      DBMS_LOB.createtemporary (l_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (l_xfdf_string, DBMS_LOB.lob_readwrite);
      current_index := 0;

      IF ghpd_data.COUNT > 0
      THEN
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);

         FOR table_counter IN ghpd_data.FIRST .. ghpd_data.LAST
         LOOP
            l_str8      := ghpd_data (table_counter).tagname;
            l_str9      := ghpd_data (table_counter).tagvalue;

            IF l_str9 IN
                  ('LEGAL_EMPLOYER'
                 , 'LE_DETAILS'
                 , 'EMPLOYEES'
                 , 'PERSON'
                 , 'LE_DETAILS_END'
                 , 'PERSON_END'
                 , 'EMPLOYEES_END'
                 , 'LEGAL_EMPLOYER_END'
                  )
            THEN
               IF l_str9 IN
                     ('LEGAL_EMPLOYER', 'LE_DETAILS', 'EMPLOYEES', 'PERSON')
               THEN
                  DBMS_LOB.writeappend (l_xfdf_string
                                      , LENGTH (l_str2)
                                      , l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                      , l_str3);
               ELSE
                  DBMS_LOB.writeappend (l_xfdf_string
                                      , LENGTH (l_str4)
                                      , l_str4
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                      , l_str5);
               END IF;
            ELSE
               IF l_str9 IS NOT NULL
               THEN
                  DBMS_LOB.writeappend (l_xfdf_string
                                      , LENGTH (l_str2)
                                      , l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                      , l_str3);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9)
                                      , l_str9);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4)
                                      , l_str4);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                      , l_str5);
               ELSE
                  DBMS_LOB.writeappend (l_xfdf_string
                                      , LENGTH (l_str2)
                                      , l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                      , l_str3);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4)
                                      , l_str4);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                      , l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5)
                                      , l_str5);
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
      p_business_group_id   IN              NUMBER
    , p_payroll_action_id   IN              VARCHAR2
    , p_template_name       IN              VARCHAR2
    , p_xml                 OUT NOCOPY      CLOB
   )
   IS
--Variables needed for the report
      l_counter             NUMBER                                       := 0;
      l_payroll_action_id   pay_action_information.action_information1%TYPE;

--Cursors needed for report
      CURSOR csr_all_legal_employer (
         csr_v_pa_id   pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT action_information3, action_information4
              , action_information5
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEHPDA'
            AND action_information2 = 'LE';

      CURSOR csr_report_details (
         csr_v_pa_id   pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT TO_CHAR
                   (fnd_date.canonical_to_date (action_information5)
                  , 'YYYYMMDD'
                   ) period_from
              , TO_CHAR
                   (fnd_date.canonical_to_date (action_information6)
                  , 'YYYYMMDD'
                   ) period_to
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT DETAILS'
            AND action_information1 = 'PYSEHPDA';

      lr_report_details     csr_report_details%ROWTYPE;

      CURSOR csr_all_employees_under_le (
         csr_v_pa_id   pay_action_information.action_information3%TYPE
       , csr_v_le_id   pay_action_information.action_information15%TYPE
      )
      IS
         SELECT   *
             FROM pay_action_information
            WHERE action_context_type = 'AAP'
              AND action_information_category = 'EMEA REPORT INFORMATION'
              AND action_information1 = 'PYSEHPDA'
              AND action_information3 = csr_v_pa_id
              AND action_information2 = 'PER'
              AND action_information15 = csr_v_le_id
         ORDER BY action_information30;

/* End of declaration*/
/* Proc to Add the tag value and Name */
      PROCEDURE add_tag_value (p_tag_name IN VARCHAR2, p_tag_value IN VARCHAR2)
      IS
      BEGIN
         ghpd_data (l_counter).tagname := p_tag_name;
         ghpd_data (l_counter).tagvalue := p_tag_value;
         l_counter   := l_counter + 1;
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
                 , fnd_conc_req_summary_v fcrs
                 , fnd_conc_req_summary_v fcrs1
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
         fnd_file.put_line (fnd_file.LOG, 'Entered Reporting');
         fnd_file.put_line (fnd_file.LOG
                          , 'p_payroll_action_id  ' || p_payroll_action_id
                           );

/* Structure of Xml should look like this
<LE>
    <DETAILS>
    </DETAILS>
    <EMPLOYEES>
        <PERSON>
        </PERSON>
    </EMPLOYEES>
</LE>
*/
         OPEN csr_report_details (l_payroll_action_id);

         FETCH csr_report_details
          INTO lr_report_details;

         CLOSE csr_report_details;

         add_tag_value ('PERIOD_FROM', lr_report_details.period_from);
         add_tag_value ('PERIOD_TO', lr_report_details.period_to);
         fnd_file.put_line (fnd_file.LOG, 'After csr_REPORT_DETAILS  ');
         fnd_file.put_line (fnd_file.LOG
                          , 'PERIOD_FROM  ' || lr_report_details.period_from
                           );
         fnd_file.put_line (fnd_file.LOG
                          , 'PERIOD_TO  ' || lr_report_details.period_to
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
            fnd_file.put_line (fnd_file.LOG
                             , 'LE ID  ' || rec_all_le.action_information3
                              );
            fnd_file.put_line (fnd_file.LOG
                             , 'LE_NAME  ' || rec_all_le.action_information4
                              );
            fnd_file.put_line (fnd_file.LOG, '^^^^^^^^^^^^^^^^^^^^^');
            fnd_file.put_line (fnd_file.LOG, '^^^^^^^^^^^^^^^^^^^^^');
            fnd_file.put_line (fnd_file.LOG, ' Inside Person Query');

            FOR rec_all_emp_under_le IN
               csr_all_employees_under_le (l_payroll_action_id
                                         , rec_all_le.action_information3
                                          )
            LOOP
               fnd_file.put_line (fnd_file.LOG
                                ,    'PERSON ID ==>  '
                                  || rec_all_emp_under_le.action_information30
                                 );
               add_tag_value ('PERSON', 'PERSON');
               add_tag_value ('EMPLOYEE_CODE'
                            , rec_all_emp_under_le.action_information4
                             );
               add_tag_value ('EMPLOYEE_NUMBER'
                            , rec_all_emp_under_le.action_information5
                             );
               add_tag_value ('EMPLOYEE_NAME'
                            , rec_all_emp_under_le.action_information6
                             );
               add_tag_value
                  ('HOLIDAY_PAY_PER_DAY'
                 , TO_CHAR
                      (fnd_number.canonical_to_number
                                     (rec_all_emp_under_le.action_information7)
                     , '999999990D99'
                      )
                  );
               add_tag_value ('TOTAL_PAID_DAYS'
                            , rec_all_emp_under_le.action_information8
                             );
               add_tag_value
                  ('TOTAL_PAID_DAYS_AMOUNT'
                 , TO_CHAR
                      (fnd_number.canonical_to_number
                                     (rec_all_emp_under_le.action_information9)
                     , '999999990D99'
                      )
                  );
               add_tag_value ('TOTAL_SAVED_DAYS'
                            , rec_all_emp_under_le.action_information10
                             );
               add_tag_value
                  ('TOTAL_SAVED_DAYS_AMOUNT'
                 , TO_CHAR
                      (fnd_number.canonical_to_number
                                    (rec_all_emp_under_le.action_information11)
                     , '999999990D99'
                      )
                  );
               add_tag_value ('TOTAL_EARNED_DAYS'
                            , rec_all_emp_under_le.action_information12
                             );
               add_tag_value
                  ('TOTAL_EARNED_DAYS_AMOUNT'
                 , TO_CHAR
                      (fnd_number.canonical_to_number
                                    (rec_all_emp_under_le.action_information13)
                     , '999999990D99'
                      )
                  );
               add_tag_value ('PERSON', 'PERSON_END');
            END LOOP;                                  /* For all EMPLOYEES */

            fnd_file.put_line (fnd_file.LOG, '^^^^^^^^^^^^^^^^^^^^^');
            add_tag_value ('EMPLOYEES', 'EMPLOYEES_END');
            add_tag_value ('LEGAL_EMPLOYER', 'LEGAL_EMPLOYER_END');
         END LOOP;                                 /* For all LEGAL_EMPLYER */
      END IF;                            /* for p_payroll_action_id IS NULL */

      writetoclob (p_xml);
   END get_xml_for_report;
END pay_se_holiday_pay_debt;

/
