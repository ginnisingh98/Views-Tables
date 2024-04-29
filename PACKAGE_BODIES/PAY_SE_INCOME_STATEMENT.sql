--------------------------------------------------------
--  DDL for Package Body PAY_SE_INCOME_STATEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_INCOME_STATEMENT" AS
/* $Header: pyseinsr.pkb 120.2.12010000.6 2010/03/12 13:27:55 vijranga ship $ */
   g_debug                          BOOLEAN       := hr_utility.debug_enabled;

   TYPE lock_rec IS RECORD (
      archive_assact_id   NUMBER
   );

   TYPE lock_table IS TABLE OF lock_rec
      INDEX BY BINARY_INTEGER;

   g_lock_table                     lock_table;
   g_index                          NUMBER         := -1;
   g_index_assact                   NUMBER         := -1;
   g_index_bal                      NUMBER         := -1;
   g_package                        VARCHAR2 (100)
                                                 := 'PAY_SE_INCOME_STATEMENT.';
   g_payroll_action_id              NUMBER;
   g_arc_payroll_action_id          NUMBER;
-- Globals to pick up all the parameter
   g_business_group_id              NUMBER;
   g_effective_date                 DATE;
   g_income_statement_provider_id   NUMBER;
   g_legal_employer_id              NUMBER;
   g_local_unit_id                  NUMBER;
   g_request_for                    VARCHAR2 (20);
   g_person_for                     VARCHAR2 (20);
   g_person_number                  NUMBER;
   g_income_year                    NUMBER;
   g_test_or_production             VARCHAR2 (20);
   g_income_start_date              DATE;
   g_income_end_date                DATE;
   g_sort_order                     VARCHAR2 (20);
--End of Globals to pick up all the parameter
   g_format_mask                    VARCHAR2 (50);
   g_err_num                        NUMBER;
   g_errm                           VARCHAR2 (150);

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

      IF l_start_pos <> 0
      THEN
         l_start_pos := l_start_pos + LENGTH (p_token || '=');
         l_parameter :=
            SUBSTR (p_parameter_string
                   ,l_start_pos
                   ,   INSTR (p_parameter_string || ' '
                             ,l_delimiter
                             ,l_start_pos
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
      p_payroll_action_id        IN       NUMBER               -- In parameter
     ,p_business_group_id        OUT NOCOPY NUMBER           -- Core parameter
     ,p_effective_date           OUT NOCOPY DATE             -- Core parameter
     ,p_income_statement_provider_id OUT NOCOPY NUMBER       -- User parameter
     ,p_request_for_all_or_not   OUT NOCOPY VARCHAR2         -- User parameter
     ,p_legal_employer_id        OUT NOCOPY NUMBER           -- User parameter
     ,p_income_year              OUT NOCOPY VARCHAR2         -- User parameter
     ,p_person_for               OUT NOCOPY VARCHAR2         -- User parameter
     ,p_person_number            OUT NOCOPY NUMBER           -- User parameter
     ,p_sort_order              OUT NOCOPY VARCHAR2           -- User parameter
     ,p_test_or_production       OUT NOCOPY VARCHAR2         -- User parameter
   )
   IS
      CURSOR csr_parameter_info (p_payroll_action_id NUMBER)
      IS
         SELECT (pay_se_income_statement.get_parameter
                                                  (legislative_parameters
                                                  ,'INCOME_STATEMENT_PROVIDER'
                                                  )
                ) income_statement_provider
               , (pay_se_income_statement.get_parameter
                                                      (legislative_parameters
                                                      ,'REQUEST_FOR'
                                                      )
                 ) request_for
               , (pay_se_income_statement.get_parameter
                                                      (legislative_parameters
                                                      ,'LEGAL_EMPLOYER'
                                                      )
                 ) legal_employer
               , (pay_se_income_statement.get_parameter
                                                      (legislative_parameters
                                                      ,'INCOME_YEAR'
                                                      )
                 ) income_year
               , (pay_se_income_statement.get_parameter
                                                      (legislative_parameters
                                                      ,'PERSON_REQUEST'
                                                      )
                 ) person_for
               , (pay_se_income_statement.get_parameter
                                                      (legislative_parameters
                                                      ,'REQUESTING_PERSON'
                                                      )
                 ) person_number
               , (pay_se_income_statement.get_parameter
                                                      (legislative_parameters
                                                      ,'TEST_PRODUCTION'
                                                      )
                 ) test_production
               , (pay_se_income_statement.get_parameter
                                                      (legislative_parameters
                                                      ,'SORT_ORDER'
                                                      )
                 ) sort_order
               ,effective_date
               ,business_group_id bg_id
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_payroll_action_id;

      lr_parameter_info   csr_parameter_info%ROWTYPE;
      l_proc              VARCHAR2 (240)
                                        := g_package || ' GET_ALL_PARAMETERS ';
   BEGIN
     -- logger ('Entering Procedure ', 'GET_ALL_PARAMETER');
     -- logger ('p_payroll_action_id', p_payroll_action_id);

      OPEN csr_parameter_info (p_payroll_action_id);

      FETCH csr_parameter_info
       INTO lr_parameter_info;

      CLOSE csr_parameter_info;

      p_income_statement_provider_id :=
                                   lr_parameter_info.income_statement_provider;
      p_legal_employer_id := lr_parameter_info.legal_employer;
      p_request_for_all_or_not := lr_parameter_info.request_for;
      p_person_for := lr_parameter_info.person_for;
      p_person_number := lr_parameter_info.person_number;
      p_effective_date := lr_parameter_info.effective_date;
      p_business_group_id := lr_parameter_info.bg_id;
      p_income_year := lr_parameter_info.income_year;
      p_test_or_production := lr_parameter_info.test_production;
      p_sort_order :=lr_parameter_info.sort_order;
--      logger ('p_income_statement_provider_id'
--             ,p_income_statement_provider_id);
--      logger ('p_legal_employer_id', p_legal_employer_id);
--      logger ('p_request_for_all_or_not', p_request_for_all_or_not);
--      logger ('p_person_for', p_person_for);
--      logger ('p_person_number', p_person_number);
--      logger ('p_income_year', p_income_year);
--      logger ('p_effective_date', p_effective_date);
--      logger ('p_business_group_id', p_business_group_id);
--      logger ('p_test_or_production', p_test_or_production);

      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure GET_ALL_PARAMETERS'
                                 ,30);
      END IF;
   END get_all_parameters;

   /* RANGE CODE */
   PROCEDURE range_code (
      p_payroll_action_id        IN       NUMBER
     ,p_sql                      OUT NOCOPY VARCHAR2
   )
   IS
      l_action_info_id            NUMBER;
      l_ovn                       NUMBER;
      l_business_group_id         NUMBER;
      l_start_date                VARCHAR2 (30);
      l_end_date                  VARCHAR2 (30);
      l_effective_date            DATE;
      l_consolidation_set         NUMBER;
      l_defined_balance_id        NUMBER                               := 0;
      l_count                     NUMBER                               := 0;
      l_prev_prepay               NUMBER                               := 0;
      l_canonical_start_date      DATE;
      l_canonical_end_date        DATE;
      l_payroll_id                NUMBER;
      l_prepay_action_id          NUMBER;
      l_actid                     NUMBER;
      l_assignment_id             NUMBER;
      l_action_sequence           NUMBER;
      l_assact_id                 NUMBER;
      l_pact_id                   NUMBER;
      l_flag                      NUMBER                               := 0;
      l_element_context           VARCHAR2 (5);

-- Archiving the data , as this will fire once
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

      l_le_has_employee           VARCHAR2 (2);
-- Archiving the data , as this will fire once
-- *****************************************************************************
-- Variables and cursors for for File INFO.KU (Media Provider Details)
-- *****************************************************************************
      l_product                   VARCHAR2 (10);
      l_period                    VARCHAR2 (10);
      l_test_or_production        VARCHAR2 (10);
      l_mp_org_number             VARCHAR2 (100);
      l_mp_name                   VARCHAR2 (240);
      l_mp_department             VARCHAR2 (240);
      l_mp_contact_person         VARCHAR2 (240);
      l_mp_address                VARCHAR2 (240);
      l_mp_postcode               VARCHAR2 (15);
      l_mp_postal_address         VARCHAR2 (50);
      l_mp_phonenumber            VARCHAR2 (15);
      l_mp_faxnumber              VARCHAR2 (15);
      l_mp_email                  VARCHAR2 (50);
      l_location_id               VARCHAR2 (100);
      l_phone_number              VARCHAR2 (100);
      l_location_code             VARCHAR2 (100);
      l_address_line_1            VARCHAR2 (100);
      l_address_line_2            VARCHAR2 (100);
      l_address_line_3            VARCHAR2 (100);
      l_postal_code               VARCHAR2 (100);
      l_town_or_city              VARCHAR2 (100);
      l_region_1                  VARCHAR2 (100);
      l_region_2                  VARCHAR2 (100);
      l_territory_short_name      VARCHAR2 (100);
      l_sender VARCHAR2 (100);
      l_receiver VARCHAR2 (100);
      l_information_type VARCHAR2 (100);
l_medium_identity varchar2(30);
l_medium_program varchar2(30);

      CURSOR csr_media_provider_details (
         csr_v_media_provider_id             hr_all_organization_units.organization_id%TYPE
      )
      IS
         SELECT o.NAME "MP_NAME",o.location_id
               ,hoi1.org_information1 "MP_ORG_NUMBER"
               ,hoi1.org_information2 "MP_DEPARTMENT"
,hoi1.org_information3 "MEDIUM_IDENTITY"
,hoi1.org_information4 "PROGRAM"
           FROM hr_all_organization_units o
               ,hr_organization_information hoi
               ,hr_organization_information hoi1
          WHERE o.business_group_id = g_business_group_id
            AND o.organization_id = hoi.organization_id
            AND hoi.org_information_context = 'CLASS'
            AND hoi.org_information1 = 'SE_INC_STMT_PROVIDER'
            AND o.organization_id = hoi1.organization_id
            AND hoi1.org_information_context = 'SE_INC_STMT_PROVIDER_DETAILS'
            AND o.organization_id = csr_v_media_provider_id;

      lr_media_provider_details   csr_media_provider_details%ROWTYPE;

      CURSOR csr_org_contacts (
         csr_v_media_provider_id             hr_organization_information.organization_id%TYPE
        ,csr_v_type                          hr_organization_information.org_information1%TYPE
      )
      IS
         SELECT   hoi22.org_information1
                 ,hoi22.org_information2
                 ,hoi22.org_information3
                 ,hoi22.org_information_id
             FROM hr_organization_information hoi11
                 ,hr_organization_information hoi22
            WHERE hoi11.organization_id = csr_v_media_provider_id
              AND hoi11.org_information_context = 'CLASS'
              AND hoi11.org_information1 = 'SE_INC_STMT_PROVIDER'
              AND hoi22.organization_id = hoi11.organization_id
              AND hoi22.org_information_context = 'SE_ORG_CONTACT_DETAILS'
              AND hoi22.org_information1 = csr_v_type
              AND ROWNUM < 2
         ORDER BY hoi22.org_information_id ASC;

      lr_org_contacts             csr_org_contacts%ROWTYPE;

      CURSOR csr_legal_employer_details (
         csr_v_legal_employer_id             hr_organization_information.organization_id%TYPE
        ,csr_v_media_provider_id             hr_organization_information.organization_id%TYPE
      )
      IS
         /* select o1.NAME legal_employer_name
                  , hoi2.org_information2 org_number
                  , hoi1.organization_id legal_id
             FROM hr_organization_units o1
                  , hr_organization_information hoi1
                  , hr_organization_information hoi2
                  , hr_organization_units o2
                  , hr_organization_information hoi3
              WHERE o1.business_group_id = g_business_group_id
                AND hoi1.organization_id = o1.organization_id
                AND hoi1.organization_id = NVL(csr_v_legal_employer_id,hoi1.organization_id)
                AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
                AND hoi1.org_information_context = 'CLASS'
                AND o1.organization_id = hoi2.organization_id
                AND hoi2.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS'
                AND o2.organization_id = csr_v_media_provider_id
                AND hoi3.org_information_context = 'SE_LEGAL_EMPLOYERS'
                and hoi3.org_information1 = o1.organization_id;*/
         SELECT o1.NAME legal_employer_name
               ,o1.location_id
               ,hoi2.org_information2 org_number
               ,hoi1.organization_id legal_id
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.organization_id =
                           NVL (csr_v_legal_employer_id, hoi1.organization_id)
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o1.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_LEGAL_EMPLOYER_DETAILS'
            AND o1.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'SE_INC_STMT_PROVIDERS'
            AND hoi3.org_information1 = csr_v_media_provider_id;

      l_legal_employer_details    csr_legal_employer_details%ROWTYPE;

      CURSOR csr_address_details (
         csr_v_location_id                   hr_locations.location_id%TYPE
      )
      IS
         SELECT hl.location_code
               ,hl.description
               ,hl.address_line_1
               ,hl.address_line_2
               ,hl.address_line_3
               ,hl.postal_code
               ,hl.town_or_city
               ,hl.region_1
               ,hl.region_2
               ,ft.territory_short_name
           FROM hr_organization_units hou
               ,hr_locations hl
               ,fnd_territories_vl ft
          WHERE hl.location_id = csr_v_location_id
            AND hl.country = ft.territory_code;

      lr_address_details          csr_address_details%ROWTYPE;

      CURSOR csr_post_header
      IS
       SELECT ORG_INFORMATION1,ORG_INFORMATION2,ORG_INFORMATION3
 FROM   hr_organization_information
 WHERE  organization_id = g_business_group_id
 AND    org_information_context = 'SE_POST_HEADER_INFO';

       lr_post_header          csr_post_header%ROWTYPE;
-- *****************************************************************************
   BEGIN
      --logger ('Range Code ', '=====> Started');

      IF g_debug
      THEN
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
      g_income_statement_provider_id := NULL;
      g_legal_employer_id := NULL;
      g_local_unit_id := NULL;
      g_income_year := NULL;
      g_person_for := NULL;
      g_person_number := NULL;
      pay_se_income_statement.get_all_parameters
                                              (p_payroll_action_id
                                              ,g_business_group_id
                                              ,g_effective_date
                                              ,g_income_statement_provider_id
                                              ,g_request_for
                                              ,g_legal_employer_id
                                              ,g_income_year
                                              ,g_person_for
                                              ,g_person_number
                                              ,g_sort_order
                                              ,g_test_or_production
                                              );
      --logger ('Parameters are ', '=====');
      --logger ('p_payroll_action_id ', p_payroll_action_id);
      --logger ('g_business_group_id ', g_business_group_id);
      --logger ('g_effective_date ', g_effective_date);
      --logger ('g_income_statement_provider_id '             ,g_income_statement_provider_id             );
      --logger ('g_request_for ', g_request_for);
      --logger ('g_legal_employer_id ', g_legal_employer_id);
      --logger ('g_income_year ', g_income_year);
      --logger ('g_person_from ', g_person_for);
      --logger ('g_person_to ', g_person_number);
      --logger ('g_test_or_production ', g_test_or_production);
      g_income_start_date := TO_DATE ('01-01-' || g_income_year, 'DD-MM-YYYY');
      g_income_end_date := TO_DATE ('31-12-' || g_income_year, 'DD-MM-YYYY');
      --logger ('g_income_start_date ', g_income_start_date);
      --logger ('g_income_end_date ', g_income_end_date);
-- *****************************************************************************
-- To pick up the details for File INFO.KU (Media Provider Details)
-- *****************************************************************************
      l_product := TO_CHAR (g_effective_date, 'YYYY');
      l_period := g_income_year;
      l_test_or_production := g_test_or_production;

      OPEN csr_media_provider_details (g_income_statement_provider_id);

      FETCH csr_media_provider_details
       INTO lr_media_provider_details;

      CLOSE csr_media_provider_details;

      l_mp_name := lr_media_provider_details.mp_name;
      l_mp_org_number := lr_media_provider_details.mp_org_number;
      l_mp_department := lr_media_provider_details.mp_department;
   l_medium_identity := lr_MEDIA_PROVIDER_DETAILS.MEDIUM_IDENTITY;
   l_medium_program := lr_MEDIA_PROVIDER_DETAILS.PROGRAM;

       OPEN csr_address_details (lr_MEDIA_PROVIDER_DETAILS.location_id);

         FETCH csr_address_details
          INTO lr_address_details;

         CLOSE csr_address_details;


IF lr_address_details.location_code IS NOT NULL
THEN
l_mp_address := lr_address_details.location_code ;
END IF;

IF lr_address_details.address_line_1 IS NOT NULL
THEN
l_mp_address :=  l_mp_address||' '||lr_address_details.address_line_1;
END IF;

IF lr_address_details.address_line_2 IS NOT NULL
THEN
l_mp_address :=  l_mp_address||' '||lr_address_details.address_line_2;
END IF;

IF lr_address_details.address_line_3 IS NOT NULL
THEN
l_mp_address :=  l_mp_address||' '||lr_address_details.address_line_3;
END IF;

l_mp_postcode := lr_address_details.postal_code ;
-- Bug#8849455 fix Added space between 3 and 4 digits in postal code
l_mp_postcode := substr(l_mp_postcode,1,3)||' '||substr(l_mp_postcode,4,2);

IF lr_address_details.town_or_city IS NOT NULL
THEN
l_mp_postal_address :=  l_mp_postal_address||' '||lr_address_details.town_or_city;
END IF;

IF lr_address_details.region_1 IS NOT NULL
THEN
l_mp_postal_address :=  l_mp_postal_address||' '||lr_address_details.region_1;
END IF;

IF lr_address_details.region_2 IS NOT NULL
THEN
l_mp_postal_address :=  l_mp_postal_address||' '||lr_address_details.region_2;
END IF;

IF lr_address_details.territory_short_name IS NOT NULL
THEN
l_mp_postal_address :=  l_mp_postal_address||' '||lr_address_details.territory_short_name;
END IF;

lr_address_details := null;

      --logger ('l_mp_name ', l_mp_name);
      --logger ('l_mp_org_number ', l_mp_org_number);
      --logger ('l_mp_department ', l_mp_department);
--logger ('l_medium_identity ', l_medium_identity );
--logger ('l_medium_program ', l_medium_program );

--logger ('l_mp_address ', l_mp_address );
--logger ('l_mp_postcode ', l_mp_postcode );
--logger ('l_mp_postal_address ', l_mp_postal_address );

      lr_org_contacts := NULL;

      OPEN csr_org_contacts (g_income_statement_provider_id, 'PERSON');

      FETCH csr_org_contacts
       INTO lr_org_contacts;

      CLOSE csr_org_contacts;

      l_mp_contact_person := lr_org_contacts.org_information3;
      lr_org_contacts := NULL;

      OPEN csr_org_contacts (g_income_statement_provider_id, 'PHONE');

      FETCH csr_org_contacts
       INTO lr_org_contacts;

      CLOSE csr_org_contacts;

      l_mp_phonenumber := lr_org_contacts.org_information3;
      lr_org_contacts := NULL;

      OPEN csr_org_contacts (g_income_statement_provider_id, 'EMAIL');

      FETCH csr_org_contacts
       INTO lr_org_contacts;

      CLOSE csr_org_contacts;

      l_mp_email := lr_org_contacts.org_information3;
      lr_org_contacts := NULL;

      OPEN csr_org_contacts (g_income_statement_provider_id, 'FAX');

      FETCH csr_org_contacts
       INTO lr_org_contacts;

      CLOSE csr_org_contacts;

      l_mp_faxnumber := lr_org_contacts.org_information3;
      lr_org_contacts := NULL;
      --logger ('l_mp_contact_person ', l_mp_contact_person);
      --logger ('l_mp_phonenumber ', l_mp_phonenumber);
      --logger ('l_mp_email ', l_mp_email);
      --logger ('l_mp_faxnumber ', l_mp_faxnumber);
-- *****************************************************************************
      OPEN csr_post_header ;
      FETCH csr_post_header       INTO lr_post_header;
      CLOSE csr_post_header;
l_sender := lr_post_header.org_information1;
l_receiver := lr_post_header.org_information2;
l_information_type := lr_post_header.org_information3;

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
                     ,p_action_information1              => 'PYSEINSA'
                     ,p_action_information2              => g_income_statement_provider_id
                     ,p_action_information3              => g_request_for
                     ,p_action_information4              => g_legal_employer_id
                     ,p_action_information5              => g_person_for
                     ,p_action_information6              => g_person_number
                     ,p_action_information7              => g_income_year
                     ,p_action_information8              => g_business_group_id
                     ,p_action_information9              => g_test_or_production
                     ,p_action_information10             => g_sort_order
                                   ,p_action_information11             => l_sender
               ,p_action_information12             => l_receiver
               ,p_action_information13             => l_information_type
                     );
-- *****************************************************************************
-- Insert for Media Provider Details
-- *****************************************************************************
-- *****************************************************************************
      pay_action_information_api.create_action_information
                  (p_action_information_id            => l_action_info_id
                  ,p_action_context_id                => p_payroll_action_id
                  ,p_action_context_type              => 'PA'
                  ,p_object_version_number            => l_ovn
                  ,p_effective_date                   => g_effective_date
                  ,p_source_id                        => NULL
                  ,p_source_text                      => NULL
                  ,p_action_information_category      => 'EMEA REPORT INFORMATION'
                  ,p_action_information1              => 'PYSEINSA'
                  ,p_action_information2              => 'MP'
                  ,p_action_information3              => l_product
                  ,p_action_information4              => l_period
                  ,p_action_information5              => l_test_or_production
                  ,p_action_information6              => l_mp_org_number
                  ,p_action_information7              => l_mp_name
                  ,p_action_information8              => l_mp_department
                  ,p_action_information9              => l_mp_contact_person
                  ,p_action_information10             => l_mp_address
                  ,p_action_information11             => l_mp_postcode
                  ,p_action_information12             => l_mp_postal_address
                  ,p_action_information13             => l_mp_phonenumber
                  ,p_action_information14             => l_mp_faxnumber
                  ,p_action_information15             => l_mp_email
           , p_action_information16             => l_medium_identity
           , p_action_information17             => l_medium_program

                  );

-- *****************************************************************************
-- *****************************************************************************
--Insert for LE or ALL LE
-- *****************************************************************************
-- *****************************************************************************
      IF g_request_for = 'REQUESTING_ORG'
      THEN
         -- Information regarding the Legal Employer
         OPEN csr_legal_employer_details (g_legal_employer_id
                                         ,g_income_statement_provider_id
                                         );

         FETCH csr_legal_employer_details
          INTO l_legal_employer_details;

         CLOSE csr_legal_employer_details;

         l_location_id := l_legal_employer_details.location_id;
         lr_address_details := NULL;
         --logger ('l_location_id', l_location_id);

         OPEN csr_address_details (l_location_id);

         FETCH csr_address_details
          INTO lr_address_details;

         CLOSE csr_address_details;

         l_location_code := lr_address_details.location_code;
         l_address_line_1 := lr_address_details.address_line_1;
         l_address_line_2 := lr_address_details.address_line_2;
         l_address_line_3 := lr_address_details.address_line_3;
         l_postal_code := lr_address_details.postal_code;
	 -- Bug#8849455 fix Added space between 3 and 4 digits in postal code
         l_postal_code := substr(l_postal_code,1,3)||' '||substr(l_postal_code,4,2);
         l_town_or_city := lr_address_details.town_or_city;
         l_region_1 := lr_address_details.region_1;
         l_region_2 := lr_address_details.region_2;
         l_territory_short_name := lr_address_details.territory_short_name;
         --logger ('l_location_code', l_location_code);
         --logger ('l_address_line_1', l_address_line_1);
         --logger ('l_address_line_2', l_address_line_2);
         --logger ('l_address_line_3', l_address_line_3);
         --logger ('l_postal_code', l_postal_code);
         --logger ('l_TOWN_OR_CITY', l_town_or_city);
         --logger ('l_REGION_1', l_region_1);
         --logger ('l_REGION_2', l_region_2);
         --logger ('l_TERRITORY_SHORT_NAME', l_territory_short_name);
         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_payroll_action_id
            ,p_action_context_type              => 'PA'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => g_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEINSA'
            ,p_action_information2              => 'LE'
            ,p_action_information3              => g_legal_employer_id
            ,p_action_information4              => l_legal_employer_details.legal_employer_name
            ,p_action_information5              => l_legal_employer_details.org_number
            ,p_action_information6              => l_location_code
            ,p_action_information7              => l_address_line_1
            ,p_action_information8              => l_address_line_2
            ,p_action_information9              => l_address_line_3
            ,p_action_information10             => l_postal_code
            ,p_action_information11             => l_town_or_city
            ,p_action_information12             => l_region_1
            ,p_action_information13             => l_region_2
            ,p_action_information14             => l_territory_short_name
            ,p_action_information15             => NULL
            );
-- *****************************************************************************
      ELSE
-- *****************************************************************************
         FOR rec_legal_employer_details IN
            csr_legal_employer_details (NULL, g_income_statement_provider_id)
         LOOP
            l_location_id := rec_legal_employer_details.location_id;
            --logger ('l_location_id', l_location_id);
            lr_address_details := NULL;

            OPEN csr_address_details (l_location_id);

            FETCH csr_address_details
             INTO lr_address_details;

            CLOSE csr_address_details;

            l_location_code := lr_address_details.location_code;
            l_address_line_1 := lr_address_details.address_line_1;
            l_address_line_2 := lr_address_details.address_line_2;
            l_address_line_3 := lr_address_details.address_line_3;
            l_postal_code := lr_address_details.postal_code;
	    -- Bug#8849455 fix Added space between 3 and 4 digits in postal code
            l_postal_code := substr(l_postal_code,1,3)||' '||substr(l_postal_code,4,2);
            l_town_or_city := lr_address_details.town_or_city;
            l_region_1 := lr_address_details.region_1;
            l_region_2 := lr_address_details.region_2;
            l_territory_short_name := lr_address_details.territory_short_name;
            --logger ('l_location_code', l_location_code);
            --logger ('l_address_line_1', l_address_line_1);
            --logger ('l_address_line_2', l_address_line_2);
            --logger ('l_address_line_3', l_address_line_3);
            --logger ('l_postal_code', l_postal_code);
            --logger ('l_TOWN_OR_CITY', l_town_or_city);
            --logger ('l_REGION_1', l_region_1);
            --logger ('l_REGION_2', l_region_2);
            --logger ('l_TERRITORY_SHORT_NAME', l_territory_short_name);
            pay_action_information_api.create_action_information
               (p_action_information_id            => l_action_info_id
               ,p_action_context_id                => p_payroll_action_id
               ,p_action_context_type              => 'PA'
               ,p_object_version_number            => l_ovn
               ,p_effective_date                   => g_effective_date
               ,p_source_id                        => NULL
               ,p_source_text                      => NULL
               ,p_action_information_category      => 'EMEA REPORT INFORMATION'
               ,p_action_information1              => 'PYSEINSA'
               ,p_action_information2              => 'LE'
               ,p_action_information3              => rec_legal_employer_details.legal_id
               ,p_action_information4              => rec_legal_employer_details.legal_employer_name
               ,p_action_information5              => rec_legal_employer_details.org_number
               ,p_action_information6              => l_location_code
               ,p_action_information7              => l_address_line_1
               ,p_action_information8              => l_address_line_2
               ,p_action_information9              => l_address_line_3
               ,p_action_information10             => l_postal_code
               ,p_action_information11             => l_town_or_city
               ,p_action_information12             => l_region_1
               ,p_action_information13             => l_region_2
               ,p_action_information14             => l_territory_short_name
               );
         END LOOP;
      END IF;                                       -- FOR G_LEGAL_EMPLOYER_ID

-- *****************************************************************************
--END OF Insert for LE or ALL LE
-- *****************************************************************************
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
                 ,act.tax_unit_id legal_employer_id
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
              AND appa.effective_date BETWEEN as1.effective_start_date
                                          AND as1.effective_end_date
--              AND ppa.effective_date BETWEEN as1.effective_start_date
--                                         AND as1.effective_end_date
              AND act.tax_unit_id IN (
                     SELECT o.organization_id
                       FROM hr_all_organization_units o
                           ,hr_organization_information hoi1
                           ,hr_organization_information hoi2
                      WHERE o.business_group_id = g_business_group_id
                        AND hoi1.organization_id = o.organization_id
                        AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
                        AND hoi1.org_information_context = 'CLASS'
                        AND o.organization_id = hoi2.organization_id
                        AND hoi2.org_information_context =
                                                       'SE_INC_STMT_PROVIDERS'
                        AND hoi2.org_information1 =
                                                g_income_statement_provider_id)
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
      l_person_id                 NUMBER;
      l_archive                   VARCHAR2 (10);

      l_a_tax_card_or_not         NUMBER;
-- End of User pARAMETERS needed

 /* GET THE PERSON NUMBE VALIDATED */
   FUNCTION validate_person_number (
   val_person_id IN number,
   val_person_number IN number
   )
      RETURN varchar2
   IS
      /* Cursor to retrieve Defined Balance Id */
      CURSOR csr_check_person_number
            IS
            SELECT count('1') "VALID" from per_all_people_f pap
            where pap.person_id=val_person_id
            AND pap.EMPLOYEE_NUMBER=val_person_number
            AND pap.EFFECTIVE_START_DATE  <= g_income_end_date
            AND pap.EFFECTIVE_END_DATE > = g_income_start_date
            ;
lr_check_person_number csr_check_person_number%rowtype;

   BEGIN

      OPEN csr_check_person_number;
      FETCH csr_check_person_number       INTO lr_check_person_number;
      CLOSE csr_check_person_number;
IF lr_check_person_number.valid > 0
THEN
      RETURN 'VALID';
ELSE
      RETURN NULL;
END IF;
END validate_person_number;



/* Proc to check A tax card */
      PROCEDURE check_a_taxcard (
         p_l_person_id              IN       NUMBER
        ,p_return_count_value       OUT NOCOPY NUMBER
      )
      IS
         CURSOR csr_get_prim_assignments (csr_v_person_id NUMBER)
         IS
            SELECT paa.assignment_id
                  ,paa.effective_start_date
                  ,paa.effective_end_date
                  ,scl.segment2
              FROM per_all_assignments_f paa
                  ,hr_soft_coding_keyflex scl
             WHERE person_id = csr_v_person_id
               AND paa.effective_start_date <= g_income_end_date
               AND paa.effective_end_date > = g_income_start_date
               AND paa.primary_flag = 'Y'
               AND paa.assignment_status_type_id IN (
                      SELECT assignment_status_type_id
                        FROM per_assignment_status_types
                       WHERE per_system_status = 'ACTIVE_ASSIGN'
                         AND active_flag = 'Y'
                         AND (   (    legislation_code IS NULL
                                  AND business_group_id IS NULL
                                 )
                              OR (business_group_id = g_business_group_id)
                             ))
               AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id;

         lr_get_prim_assignments   csr_get_prim_assignments%ROWTYPE;

         CURSOR csr_get_element_ids
         IS
            SELECT pet.element_type_id
                  ,piv.input_value_id
                  ,pel.element_link_id
              FROM pay_element_types_f pet
                  ,pay_input_values_f piv
                  ,pay_element_links_f pel
             WHERE pet.element_name = 'Tax Card'
               AND pet.legislation_code = 'SE'
               AND piv.element_type_id = pet.element_type_id
               AND piv.NAME = 'Tax Card Type'
               AND pel.element_type_id = pet.element_type_id
               AND pel.business_group_id = g_business_group_id
               AND pet.effective_start_date <= g_income_end_date
               AND pet.effective_end_date > = g_income_start_date
               AND piv.effective_start_date <= g_income_end_date
               AND piv.effective_end_date > = g_income_start_date
               AND pel.effective_start_date <= g_income_end_date
               AND pel.effective_end_date > = g_income_start_date;

         lr_get_element_ids        csr_get_element_ids%ROWTYPE;

         CURSOR csr_chk_a_taxcard (
            csr_v_input_value_id                pay_element_entry_values_f.input_value_id%TYPE
           ,csr_v_link_id                       pay_element_entries_f.element_link_id%TYPE
           ,csr_v_type_id                       pay_element_entries_f.element_type_id%TYPE
           ,csr_v_prim_assignment_id            NUMBER
         )
         IS
            SELECT COUNT ('Y') valid
              FROM pay_element_entries_f pee
                  ,pay_element_entry_values_f peev
             WHERE peev.screen_entry_value = 'A'
               AND peev.element_entry_id = pee.element_entry_id
               AND peev.effective_start_date = pee.effective_start_date
               AND peev.effective_end_date = pee.effective_end_date
               AND peev.input_value_id = csr_v_input_value_id
               --AND pee.element_link_id = csr_v_link_id
               AND pee.element_type_id = csr_v_type_id
               AND pee.assignment_id = csr_v_prim_assignment_id
               AND pee.effective_start_date <= g_income_end_date
               AND pee.effective_end_date > = g_income_start_date;

         lr_chk_a_taxcard          csr_chk_a_taxcard%ROWTYPE;

-- *****************************************************************************
-- Income Statement Specification Details
         CURSOR csr_person_inc_stmt_spec (
            csr_v_person_id                     NUMBER
           ,csr_v_information_type              per_people_extra_info.information_type%TYPE
         )
         IS
            SELECT pei_information1
                  ,pei_information2
                  ,pei_information3
                  ,pei_information4
                  ,pei_information5
                  ,pei_information6
                  ,pei_information7
                  ,pei_information8
                  ,pei_information9
              FROM per_people_extra_info
             WHERE person_id = csr_v_person_id
               AND information_type = csr_v_information_type;

         lr_person_inc_stmt_spec   csr_person_inc_stmt_spec%ROWTYPE;
-- *****************************************************************************
      BEGIN
-- *****************************************************************************
         lr_person_inc_stmt_spec := NULL;

         OPEN csr_person_inc_stmt_spec (p_l_person_id
                                       ,'SE_INC_STMT_DATA_CORRECTION'
                                       );

         FETCH csr_person_inc_stmt_spec
          INTO lr_person_inc_stmt_spec;

         CLOSE csr_person_inc_stmt_spec;

         --logger ('lr_Person_inc_stmt_spec.PEI_INFORMATION1'                ,lr_person_inc_stmt_spec.pei_information1                );

         IF lr_person_inc_stmt_spec.pei_information1 = 'NA'
         THEN
            p_return_count_value := 0;
            --logger ('NA. not VALID', p_return_count_value);
         ELSIF lr_person_inc_stmt_spec.pei_information1 IS NULL
         THEN
            OPEN csr_get_prim_assignments (p_l_person_id);

            FETCH csr_get_prim_assignments
             INTO lr_get_prim_assignments;

            CLOSE csr_get_prim_assignments;

            OPEN csr_get_element_ids;

            FETCH csr_get_element_ids
             INTO lr_get_element_ids;

            CLOSE csr_get_element_ids;

            lr_chk_a_taxcard := NULL;

            OPEN csr_chk_a_taxcard (lr_get_element_ids.input_value_id
                                   ,lr_get_element_ids.element_link_id
                                   ,lr_get_element_ids.element_type_id
                                   ,lr_get_prim_assignments.assignment_id
                                   );

            FETCH csr_chk_a_taxcard
             INTO lr_chk_a_taxcard;

            CLOSE csr_chk_a_taxcard;

            --logger ('lr_chk_A_taxcard.VALID', lr_chk_a_taxcard.valid);
            p_return_count_value := lr_chk_a_taxcard.valid;
         ELSE            -- if the value has been entereed as KU10, KU13, KU14
-- then dont check this tax card
            p_return_count_value := 1;
            --logger ('Else .VALID', p_return_count_value);
         END IF;
      END check_a_taxcard;
/* End of Proc to Add the tag value and Name */
   BEGIN


      --logger ('ASSIGNMENT_ACTION_CODE ', '--------------------------------- Started');

      pay_se_income_statement.get_all_parameters (p_payroll_action_id
                                                , g_business_group_id
                                                , g_effective_date
                                                , g_income_statement_provider_id
                                                , g_request_for
                                                , g_legal_employer_id
                                                , g_income_year
                                                , g_person_for
                                                , g_person_number
                                                , g_sort_order
                                                , g_test_or_production
                                                 );

      l_canonical_start_date := NULL;
      l_canonical_end_date := NULL;
      l_prepay_action_id := 0;
/*
      logger ('p_payroll_action_id ', p_payroll_action_id );
      logger ('g_business_group_id ', g_business_group_id );
      logger ('g_effective_date ', g_effective_date );
      logger ('g_income_statement_provider_id ', g_income_statement_provider_id );
      logger ('g_request_for ', g_request_for );
      logger ('g_legal_employer_id ', g_legal_employer_id );
      logger ('g_income_year ', g_income_year );
      logger ('g_person_from ', g_person_for );
      logger ('g_person_to ', g_person_number );
      logger ('g_test_or_production ', g_test_or_production );
*/
      g_income_start_date := TO_DATE ('01-01-' || g_income_year, 'DD-MM-YYYY');
      g_income_end_date := TO_DATE ('31-12-' || g_income_year, 'DD-MM-YYYY');

      l_canonical_start_date := g_income_start_date;
      l_canonical_end_date := g_income_end_date;
      --logger ('l_canonical_start_date ', l_canonical_start_date );
      --logger ('l_canonical_end_date ', l_canonical_end_date );
      l_assignment_id := 0;
      l_legal_employer_id := 0;
      l_person_id := 0;

      IF g_person_for = 'PER_ALL'
      THEN
      IF g_request_for <>'REQUESTING_ORG'
      THEN
         FOR rec_prepaid_assignments IN
            csr_prepaid_assignments_le (p_payroll_action_id
                                       ,p_start_person
                                       ,p_end_person
                                       ,g_legal_employer_id
                                       ,l_canonical_start_date
                                       ,l_canonical_end_date
                                       )
         LOOP
        --logger ('FOR ALL EMP  ', 'FOR ALL LE');
            --logger ('rec_prepaid_assignments.person_id  '                   ,rec_prepaid_assignments.person_id                   );
            --logger ('rec_prepaid_assignments.LEGAL_EMPLOYER_ID '                   ,rec_prepaid_assignments.legal_employer_id                   );
            --logger ('Person ID  ', l_person_id);
            --logger ('Legal Employer id ', l_legal_employer_id);

            IF (    l_person_id <> rec_prepaid_assignments.person_id
                or l_legal_employer_id <>
                                     rec_prepaid_assignments.legal_employer_id
               )
            THEN
               --logger ('Passed  ', '+-+-+-+-');
               l_a_tax_card_or_not := NULL;
               check_a_taxcard (rec_prepaid_assignments.person_id
                               ,l_a_tax_card_or_not
                               );

               IF l_a_tax_card_or_not > 0
               THEN
                  SELECT pay_assignment_actions_s.NEXTVAL
                    INTO l_actid
                    FROM DUAL;

                  -- Create the archive assignment action
                  hr_nonrun_asact.insact
                                       (l_actid
                                       ,rec_prepaid_assignments.assignment_id
                                       ,p_payroll_action_id
                                       ,p_chunk
                                       ,NULL
                                       );
               -- Create archive to prepayment assignment action interlock
               --
               --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
               END IF;
            l_assignment_id := rec_prepaid_assignments.assignment_id;
            l_legal_employer_id := rec_prepaid_assignments.legal_employer_id;
            l_person_id := rec_prepaid_assignments.person_id;

            END IF;

            -- create archive to master assignment action interlock
            --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
         END LOOP;
    ELSE
        --logger ('FOR ALL EMP  ', 'UNDER GIVEN LE');
         FOR rec_prepaid_assignments IN
            csr_prepaid_assignments_le (p_payroll_action_id
                                       ,p_start_person
                                       ,p_end_person
                                       ,g_legal_employer_id
                                       ,l_canonical_start_date
                                       ,l_canonical_end_date
                                       )
         LOOP

            --logger ('rec_prepaid_assignments.person_id  '                   ,rec_prepaid_assignments.person_id                   );
            --logger ('rec_prepaid_assignments.LEGAL_EMPLOYER_ID '                   ,rec_prepaid_assignments.legal_employer_id                   );
            --logger ('Person ID  ', l_person_id);
            --logger ('Legal Employer id ', l_legal_employer_id);

            IF (    l_person_id <> rec_prepaid_assignments.person_id
                AND rec_prepaid_assignments.legal_employer_id = g_legal_employer_id
               )
            THEN
               --logger ('Passed  ', '+-+-+-+-');
               l_a_tax_card_or_not := NULL;
               check_a_taxcard (rec_prepaid_assignments.person_id
                               ,l_a_tax_card_or_not
                               );

               IF l_a_tax_card_or_not > 0
               THEN
                  SELECT pay_assignment_actions_s.NEXTVAL
                    INTO l_actid
                    FROM DUAL;

                  -- Create the archive assignment action
                  hr_nonrun_asact.insact
                                       (l_actid
                                       ,rec_prepaid_assignments.assignment_id
                                       ,p_payroll_action_id
                                       ,p_chunk
                                       ,NULL
                                       );
               -- Create archive to prepayment assignment action interlock
               --
               --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
               END IF;
            l_assignment_id := rec_prepaid_assignments.assignment_id;
            l_legal_employer_id := rec_prepaid_assignments.legal_employer_id;
            l_person_id := rec_prepaid_assignments.person_id;

            END IF;

            -- create archive to master assignment action interlock
            --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
         END LOOP;
    END IF;
      ELSE
      --logger ('FOR GIVEN EMP  ', '8****8*****8****8****8');
      IF g_request_for <>'REQUESTING_ORG'
      THEN
      --logger ('FOR GIVEN EMP  ', 'UNDER ALL LE');
         FOR rec_prepaid_assignments IN
            csr_prepaid_assignments_le (p_payroll_action_id
                                       ,p_start_person
                                       ,p_end_person
                                       ,g_legal_employer_id
                                       ,l_canonical_start_date
                                       ,l_canonical_end_date
                                       )
         LOOP
		--logger ('============================Person Number to be checked   ', rec_prepaid_assignments.person_id);
		--logger ('===========LE   ', rec_prepaid_assignments.legal_employer_id);

            IF (    l_person_id <> rec_prepaid_assignments.person_id
      or l_legal_employer_id <>  rec_prepaid_assignments.legal_employer_id
               )
            THEN
               --logger ('Person ID  ', l_person_id);
               --logger ('Legal Employer id ', l_legal_employer_id);
    IF validate_person_number(rec_prepaid_assignments.person_id,g_person_number) IS NOT NULL
    THEN
		--logger ('Person validated  ', rec_prepaid_assignments.person_id);
               check_a_taxcard (rec_prepaid_assignments.person_id
                               ,l_a_tax_card_or_not
                               );

               IF l_a_tax_card_or_not > 0
               THEN
                  SELECT pay_assignment_actions_s.NEXTVAL
                    INTO l_actid
                    FROM DUAL;

                  -- Create the archive assignment action
                  hr_nonrun_asact.insact
                                       (l_actid
                                       ,rec_prepaid_assignments.assignment_id
                                       ,p_payroll_action_id
                                       ,p_chunk
                                       ,NULL
                                       );
               -- Create archive to prepayment assignment action interlock
               --
               --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
               END IF;
END IF;-- person number
            l_assignment_id := rec_prepaid_assignments.assignment_id;
            l_legal_employer_id := rec_prepaid_assignments.legal_employer_id;
            l_person_id := rec_prepaid_assignments.person_id;
            END IF;


            -- create archive to master assignment action interlock
            --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
         END LOOP;
ELSE
--logger ('FOR GIVEN EMP  ', 'UNDER GIVEN LE');
         FOR rec_prepaid_assignments IN
            csr_prepaid_assignments_le (p_payroll_action_id
                                       ,p_start_person
                                       ,p_end_person
                                       ,g_legal_employer_id
                                       ,l_canonical_start_date
                                       ,l_canonical_end_date
                                       )
         LOOP
		--logger ('============================Person Number to be checked   ', rec_prepaid_assignments.person_id);
		--logger ('===========LE   ', rec_prepaid_assignments.legal_employer_id);

            IF (    l_person_id <> rec_prepaid_assignments.person_id
      AND rec_prepaid_assignments.legal_employer_id = g_legal_employer_id
               )
            THEN
               --logger ('Person ID  ', l_person_id);
               --logger ('Legal Employer id ', l_legal_employer_id);
    IF validate_person_number(rec_prepaid_assignments.person_id,g_person_number) IS NOT NULL
    THEN
		--logger ('Person validated  ', rec_prepaid_assignments.person_id);
               check_a_taxcard (rec_prepaid_assignments.person_id
                               ,l_a_tax_card_or_not
                               );

               IF l_a_tax_card_or_not > 0
               THEN
                  SELECT pay_assignment_actions_s.NEXTVAL
                    INTO l_actid
                    FROM DUAL;

                  -- Create the archive assignment action
                  hr_nonrun_asact.insact
                                       (l_actid
                                       ,rec_prepaid_assignments.assignment_id
                                       ,p_payroll_action_id
                                       ,p_chunk
                                       ,NULL
                                       );
               -- Create archive to prepayment assignment action interlock
               --
               --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
               END IF;
END IF;-- person number
            l_assignment_id := rec_prepaid_assignments.assignment_id;
            l_legal_employer_id := rec_prepaid_assignments.legal_employer_id;
            l_person_id := rec_prepaid_assignments.person_id;
            END IF;


            -- create archive to master assignment action interlock
            --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
         END LOOP;
      END IF;

      END IF;                                                   -- for PER_ALL

      --logger ('ASSIGNMENT_ACTION_CODE ', '--------------------------------- Ended');

      IF g_debug
      THEN
         hr_utility.set_location
                                (' Leaving Procedure ASSIGNMENT_ACTION_CODE'
                                ,70
                                );
      END IF;
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
      l_action_info_id      NUMBER;
      l_ovn                 NUMBER;
      l_count               NUMBER                     := 0;
      l_business_group_id   NUMBER;
      l_start_date          VARCHAR2 (20);
      l_end_date            VARCHAR2 (20);
      l_effective_date      DATE;
      l_payroll_id          NUMBER;
      l_consolidation_set   NUMBER;
      l_le                  NUMBER                     := 0;

      CURSOR csr_get_all_legal_employer_id
      IS
         SELECT o.organization_id
           FROM hr_all_organization_units o
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
          WHERE o.business_group_id = g_business_group_id
            AND hoi1.organization_id = o.organization_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_INC_STMT_PROVIDERS'
            AND hoi2.org_information1 = g_income_statement_provider_id
            AND o.organization_id =
                   DECODE (g_request_for
                          ,'ALL_ORG', o.organization_id
                          ,g_legal_employer_id
                          );

 /*     CURSOR csr_get_all_Legal_employer_id
      IS
      select o.organization_id,hoi3.ORG_INFORMATION1,hoi3.ORG_INFORMATION2
         FROM hr_all_organization_units o
              , hr_organization_information hoi1
              , hr_organization_information hoi2
              , hr_organization_information hoi3
          WHERE o.business_group_id = g_business_group_id
            AND hoi1.organization_id = o.organization_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o.organization_id = hoi2.organization_id
            AND hoi2.org_information_context = 'SE_INC_STMT_PROVIDERS'
            and hoi2.org_information1 = g_income_statement_provider_id
            and o.organization_id = decode(g_request_for,'ALL_ORG',o.organization_id,g_legal_employer_id)
            AND o.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'SE_INC_STMT_KU10_INFORMATION';
*/
/*
      CURSOR csr_get_all_info(csr_v_LE_id NUMBER)
      IS
      select o.organization_id,hoi3.ORG_INFORMATION1,hoi3.ORG_INFORMATION2
         FROM hr_all_organization_units o
              , hr_organization_information hoi1
              , hr_organization_information hoi3
          WHERE o.business_group_id = g_business_group_id
            AND hoi1.organization_id = o.organization_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            and o.organization_id = csr_v_LE_id
            AND o.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'SE_INC_STMT_KU10_INFORMATION';

*/
      CURSOR csr_get_all_info (csr_v_le_id NUMBER, csr_v_code VARCHAR2)
      IS
         SELECT o.organization_id
               ,hoi3.org_information1
               ,hoi3.org_information2
           FROM hr_all_organization_units o
               ,hr_organization_information hoi1
               ,hr_organization_information hoi3
          WHERE o.business_group_id = g_business_group_id
            AND hoi1.organization_id = o.organization_id
            AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi1.org_information_context = 'CLASS'
            AND o.organization_id = csr_v_le_id
            AND o.organization_id = hoi3.organization_id
--            AND hoi3.org_information_context = 'SE_INC_STMT_KU10_INFORMATION'
            AND hoi3.org_information_context IN
                   ('SE_INC_STMT_KU10_INFORMATION'
                   ,'SE_INC_STMT_KU13_INFORMATION'
                   ,'SE_INC_STMT_KU14_INFORMATION'
                   )
            AND hoi3.org_information1 = csr_v_code;

      lr_get_all_info       csr_get_all_info%ROWTYPE;

      CURSOR csr_get_all_codes
      IS
         SELECT   h.lookup_code
             FROM hr_lookups h
            WHERE h.lookup_type = 'SE_INCOME_STATEMENT_FIELDS'
              AND h.lookup_code LIKE 'KU%'
              AND h.enabled_flag = 'Y'
         ORDER BY h.meaning;

      l_temp_counter        VARCHAR2 (200);
   BEGIN
      --logger ('Initialization Code ', '=====> Started');
      g_payroll_action_id := p_payroll_action_id;
      g_business_group_id := NULL;
      g_effective_date := NULL;
      g_legal_employer_id := NULL;
      pay_se_income_statement.get_all_parameters
                                             (p_payroll_action_id
                                             ,g_business_group_id
                                             ,g_effective_date
                                             ,g_income_statement_provider_id
                                             ,g_request_for
                                             ,g_legal_employer_id
                                             ,g_income_year
                                             ,g_person_for
                                             ,g_person_number
                                             ,g_sort_order
                                             ,g_test_or_production
                                             );
      g_income_start_date := TO_DATE ('01-01-' || g_income_year, 'DD-MM-YYYY');
      g_income_end_date := TO_DATE ('31-12-' || g_income_year, 'DD-MM-YYYY');
      --logger ('Initialization Code ', '=====> ; In');
      l_count := 1;

      FOR row_get_all_legal_employer_id IN csr_get_all_legal_employer_id
      LOOP
         --logger ('organization_id  '                ,row_get_all_legal_employer_id.organization_id                );
         each_field_value (row_get_all_legal_employer_id.organization_id).legal_employer_id :=
                                 row_get_all_legal_employer_id.organization_id;

-- each_field_value(row_get_all_Legal_employer_id.organization_id).FIELD_CODE(row_get_all_Legal_employer_id.ORG_INFORMATION1) := row_get_all_Legal_employer_id.ORG_INFORMATION2;
         FOR row_get_all_codes IN csr_get_all_codes
         LOOP
            --logger ('CODE', row_get_all_codes.lookup_code);
            lr_get_all_info := NULL;

            OPEN csr_get_all_info
                              (row_get_all_legal_employer_id.organization_id
                              ,row_get_all_codes.lookup_code
                              );

            FETCH csr_get_all_info
             INTO lr_get_all_info;

            CLOSE csr_get_all_info;

            --logger ('ORG_INFORMATION1  ', lr_get_all_info.org_information1);
            each_field_value (row_get_all_legal_employer_id.organization_id).field_code
                                                (row_get_all_codes.lookup_code) :=
                                              lr_get_all_info.org_information2;
            --logger ('ORG_INFORMATION2  ', lr_get_all_info.org_information2);
         END LOOP;
/*
        FOR row_get_all_info IN csr_get_all_info(row_get_all_Legal_employer_id.organization_id)
        LOOP

              logger ('ORG_INFORMATION1  ',row_get_all_info.ORG_INFORMATION1 );
 each_field_value(row_get_all_Legal_employer_id.organization_id).FIELD_CODE(row_get_all_info.ORG_INFORMATION1) := row_get_all_info.ORG_INFORMATION2;
              logger ('ORG_INFORMATION2  ',row_get_all_info.ORG_INFORMATION2 );
--              l_count := l_count + 1 ;
        END LOOP;
*/
      END LOOP;

      l_temp_counter := each_field_value.FIRST;

      WHILE l_temp_counter IS NOT NULL
      LOOP
         --logger ('each__value'                ,each_field_value (l_temp_counter).legal_employer_id                );
         l_temp_counter := each_field_value.NEXT (l_temp_counter);
      END LOOP;

-- *****************************************************************************
   /*   FOR i IN each_field_value.FIRST .. each_field_value.LAST
      LOOP


        l_LE :=each_field_value (i).LEGAL_EMPLOYER_ID;
         logger ('each_field_value    ', l_LE);
         l_temp_counter := each_field_value (l_LE).FIELD_CODE.FIRST;

        FOR row_get_all_codes IN csr_get_all_codes
        LOOP

            IF each_field_value(l_LE).FIELD_CODE.EXISTS(row_get_all_codes.LOOKUP_CODE) = FALSE
            THEN
             logger ('      Is not There',row_get_all_codes.LOOKUP_CODE );
               each_field_value(l_LE).FIELD_CODE(row_get_all_codes.LOOKUP_CODE) := NULL;
            END IF;

          logger ('LooK   ',row_get_all_codes.LOOKUP_CODE );
          logger ('Value ',each_field_value(l_LE).FIELD_CODE(row_get_all_codes.LOOKUP_CODE) );
         END LOOP;
/*
         WHILE l_temp_counter IS NOT NULL
         LOOP
      logger (   'Vslue',each_field_value (l_LE).FIELD_CODE(l_temp_counter) );
      l_temp_counter :=each_field_value (l_LE).FIELD_CODE.NEXT(l_temp_counter);
         END LOOP;
      END LOOP;*/

      -- *****************************************************************************
      --logger ('Initialization Code ', '=====> ; after ');
--      logger ('each_field_value (3134).FIELD_CODE(KU10_RENT) ',each_field_value ('3134').--field_code ('KU10_RENT')             );
--      logger ('each_field_value (3134).FIELD_CODE(KU10_RENT) ',each_field_value ('3267').--field_code ('KU10_RENT')            );
/*
      FOR i IN each_field_value.FIRST .. each_field_value.LAST
      LOOP
      logger ('Legal Employer    ', each_field_value (i).LEGAL_EMPLOYER_ID);
      END LOOP;
  */
      --logger ('Initialization Code ', '********> Ended');
   EXCEPTION
      WHEN OTHERS
      THEN
         g_err_num := SQLCODE;
         --logger ('Initialization Code ', '********> Errorrr');
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
      p_user_name                IN       VARCHAR2
     ,p_in_assignment_id         IN       NUMBER
     ,p_in_virtual_date          IN       DATE
     ,p_tax_unit_id              IN       NUMBER
     ,p_local_unit_id            IN       NUMBER
   )
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

      l_defined_balance_id     ff_user_entities.user_entity_id%TYPE;
      l_return_balance_value   NUMBER;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location
                             (' Entering Function GET_DEFINED_BALANCE_VALUE'
                             ,240
                             );
      END IF;

      OPEN csr_def_bal_id (p_user_name);

      FETCH csr_def_bal_id
       INTO l_defined_balance_id;

      CLOSE csr_def_bal_id;

      pay_balance_pkg.set_context ('TAX_UNIT_ID', p_tax_unit_id);
      pay_balance_pkg.set_context ('LOCAL_UNIT_ID', p_local_unit_id);
      l_return_balance_value :=
--         TO_CHAR            (
	pay_balance_pkg.get_value
                                (p_defined_balance_id      => l_defined_balance_id
                                ,p_assignment_id           => p_in_assignment_id
                                ,p_virtual_date            => p_in_virtual_date
                                )
--            ,'999999999D99'            )
;
      RETURN l_return_balance_value;

      IF g_debug
      THEN
         hr_utility.set_location
                              (' Leaving Function GET_DEFINED_BALANCE_VALUE'
                              ,250
                              );
      END IF;
   END get_defined_balance_value;

   FUNCTION get_balance_value (
      p_balance_type_id          IN       NUMBER
     ,p_in_assignment_id         IN       NUMBER
     ,p_in_virtual_date          IN       DATE
     ,p_tax_unit_id              IN       NUMBER
     ,p_local_unit_id            IN       NUMBER
   )
      RETURN NUMBER
   IS
      /* Cursor to retrieve Defined Balance Id */
      CURSOR csr_def_bal_id (csr_v_balance_type_id NUMBER)
      IS
         SELECT pd.defined_balance_id
           FROM pay_defined_balances pd
               ,pay_balance_dimensions pbd
          WHERE pd.balance_type_id = csr_v_balance_type_id
            AND pbd.balance_dimension_id = pd.balance_dimension_id
            AND pbd.legislation_code = 'SE'
            AND pbd.database_item_suffix = '_PER_LE_YTD';

      l_defined_balance_id     ff_user_entities.user_entity_id%TYPE;
      l_return_balance_value   NUMBER;
   BEGIN
      IF p_balance_type_id IS NOT NULL
      THEN
         OPEN csr_def_bal_id (p_balance_type_id);

         FETCH csr_def_bal_id
          INTO l_defined_balance_id;

         CLOSE csr_def_bal_id;

         IF l_defined_balance_id IS NOT NULL
         THEN
            pay_balance_pkg.set_context ('TAX_UNIT_ID', p_tax_unit_id);
            pay_balance_pkg.set_context ('LOCAL_UNIT_ID', p_local_unit_id);
            l_return_balance_value :=
--               TO_CHAR                  (
pay_balance_pkg.get_value
                                (p_defined_balance_id      => l_defined_balance_id
                                ,p_assignment_id           => p_in_assignment_id
                                ,p_virtual_date            => p_in_virtual_date
                                )
--                  ,'999999999D99'        )
;
         END IF;
      ELSE
         l_return_balance_value := 0;
      END IF;

      RETURN l_return_balance_value;
   END get_balance_value;

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
      l_employee_last_name               VARCHAR2 (240);
      l_employee_name               VARCHAR2 (240);
      l_employee_pin                VARCHAR2 (240);
      l_employees_address           VARCHAR2 (240);
      l_employees_postalcode        VARCHAR2 (240);
      l_employee_postal_address     VARCHAR2 (240);
      l_date_of_birth               DATE;      -- Changes EOY 2008/2009
      l_month_from                  VARCHAR2 (10);
      l_month_to                    VARCHAR2 (10);
      l_date_of_correction          VARCHAR2 (50);
      l_a_tax_withheld              NUMBER;
      l_a_tax_withheld_flag         VARCHAR2 (10);
      l_gross_salary                NUMBER;
      l_tb_exclusive_car_fuel       NUMBER;
      l_tb_exclusive_fuel           NUMBER;
      l_rsv_code                    VARCHAR2 (240);
      l_number_of_months_car        NUMBER;
      l_number_of_kilometers        NUMBER;
      l_emp_payment_car             NUMBER;
      l_free_fuel_car               NUMBER;
      l_compensation_for_expenses   NUMBER;
      l_occupational_pension        NUMBER;
      l_other_tax_rem               NUMBER;
      l_tax_rem_without_sjd         NUMBER;    --EOY 2008
      l_tax_rem_paid                NUMBER;
      l_not_tax_rem                 NUMBER;
      l_certain_deductions          NUMBER;
      l_rent                        NUMBER;
      l_tax_red_house_ku10          NUMBER;   -- EOY 2008/2009
      l_tax_red_rot_ku10            NUMBER;   -- EOY 2009/2010
      l_work_site_number            VARCHAR2 (100);
      l_free_housing                VARCHAR2 (100);
      l_free_meals                  VARCHAR2 (100);
      l_free_housing_other41        VARCHAR2 (100);
      l_interest                    VARCHAR2 (100);
      l_other_benefits              VARCHAR2 (100);
      l_benefit_adjusted            VARCHAR2 (100);
      l_mileage_allowance           VARCHAR2 (100);
      l_per_diem_sweden             VARCHAR2 (100);
      l_per_diem_other              VARCHAR2 (100);
      l_within_sweden               VARCHAR2 (100);
      l_other_countries             VARCHAR2 (100);
      l_business_travel_expenses    VARCHAR2 (100);
      l_acc_business_travels        VARCHAR2 (100);
      l_other_benefits_up65         VARCHAR2 (100);
      l_compe_for_expenses_up66     VARCHAR2 (100);
      l_tax_rem_paid_up67           VARCHAR2 (100);
      l_other_tax_rem_up68          VARCHAR2 (100);
      l_tax_rem_without_sjd_up69    VARCHAR2 (100);   ---EOY 2008
      l_benefit_as_pension          VARCHAR2 (100);   --EOY 2008
      l_benefit_as_pension_flag     VARCHAR2 (100);    --EOY 2008
      l_certain_deductions_up70     VARCHAR2 (100);
      l_car_ben_ytd                 NUMBER;
      l_fuel_ben_ytd                NUMBER;
      l_ben_ytd                     NUMBER;
      l_primary_local_unit_id       NUMBER;
      l_primary_assignment_id       NUMBER;
      l_temp                        NUMBER;
      l_temp_balance_value          NUMBER;
      l_free_housing_other41_flag   VARCHAR2 (240);
      l_interest_flag               VARCHAR2 (240);
      l_other_benefits_flag         VARCHAR2 (240);
      l_busi_travel_expenses_flag   VARCHAR2 (240);
      l_acc_business_travels_flag   VARCHAR2 (240);
      l_car_elem_end_date           DATE;
      l_car_elem_start_date         DATE;
      l_car_elem_entry_id           NUMBER;
      l_statement_type              VARCHAR2 (240);
      l_correction_date             VARCHAR2 (240);
      l_tax_country_meaning         VARCHAR2 (240);
      l_tax_country_code            VARCHAR2 (240);
      l_ftin                        VARCHAR2 (240);
      l_work_country_meaning        VARCHAR2 (240);
      l_work_country_code           VARCHAR2 (240);
      l_work_period                 VARCHAR2 (240);
      l_emp_regulation_category     VARCHAR2 (240);
      l_emp_regulation_category_code     VARCHAR2 (240);
      l_article_details             VARCHAR2 (240);
      l_occupational_pension_ku13   NUMBER;
      l_compen_for_benefit_ku13     NUMBER;
      l_tax_rem_ssc_ku13            NUMBER;
      l_not_tax_rem_ku14            NUMBER;
      l_occupational_pension_ku14   NUMBER;
      l_tax_rem_ssc_ku14            NUMBER;
      l_other_tax_rem_ku14          NUMBER;
      l_other_tax_rem_ku13          NUMBER;  -- EOY 2008/2009
      l_compe_for_expenses_ku14     NUMBER;
      l_tax_red_house_ku14          NUMBER;  -- EOY 2008/2009
      l_benefit_pen_ku14            NUMBER;  -- EOY 2008/2009
      l_benefit_pen_flag_KU14       VARCHAR2 (10); --EOY 2008/2009
      l_tax_red_rot_ku14            NUMBER;  -- EOY 2009/2010
      l_in_plain_writing_code       VARCHAR2 (240);
      l_in_plain_writing_meaning    VARCHAR2 (240);
      l_employee_number             VARCHAR2 (240);
      l_employee_code               VARCHAR2 (240);
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
      CURSOR csr_get_person_id (p_asg_act_id NUMBER)
      IS
         SELECT *
           FROM (SELECT   paa.effective_start_date,paa.effective_end_date
                         ,paa.person_id
                         ,paa.assignment_id
                     FROM per_all_assignments_f paa
                         ,pay_assignment_actions pac
                    WHERE pac.assignment_action_id = p_asg_act_id
                      AND paa.assignment_id = pac.assignment_id
                      AND paa.effective_start_date <= g_income_end_date
                      AND paa.effective_end_date > = g_income_start_date
                      AND assignment_status_type_id IN (
                             SELECT assignment_status_type_id
                               FROM per_assignment_status_types
                              WHERE per_system_status = 'ACTIVE_ASSIGN'
                                AND active_flag = 'Y'
                                AND (   (    legislation_code IS NULL
                                         AND business_group_id IS NULL
                                        )
                                     OR (business_group_id =
                                                           g_business_group_id
                                        )
                                    ))
                 ORDER BY paa.effective_start_date DESC)
          WHERE ROWNUM < 2;

      lr_get_person_id              csr_get_person_id%ROWTYPE;

      /* Cursor to retrieve Person Details */
      CURSOR csr_get_person_details (
         csr_v_person_id                     NUMBER
        ,csr_v_effective_date                DATE
      )
      IS
         SELECT pap.last_name
               ,pap.pre_name_adjunct
               ,pap.first_name
               ,pap.national_identifier
               ,pap.person_id
               ,pap.per_information1
               ,ft.territory_short_name
               ,ft.territory_code
               ,pap.effective_end_date
               ,pap.EMPLOYEE_NUMBER
	       ,pap.date_of_birth  -- EOY 2008/2009
           FROM per_all_people_f pap
               ,fnd_territories_vl ft
          WHERE pap.person_id = csr_v_person_id
            AND pap.per_information_category = 'SE'
            AND ft.obsolete_flag = 'N'
            AND ft.territory_code = pap.per_information1
            AND csr_v_effective_date BETWEEN pap.effective_start_date
                                         AND pap.effective_end_date;

/*         SELECT pap.last_name, pap.pre_name_adjunct, pap.first_name
              , pap.national_identifier, pap.person_id
           FROM
              per_all_people_f pap
          WHERE pap.person_id = csr_v_person_id
            AND pap.per_information_category = 'SE'
            AND csr_v_effective_date BETWEEN pap.effective_start_date
                                     AND pap.effective_end_date;
*/
     lr_get_person_details         csr_get_person_details%ROWTYPE;

      CURSOR csr_get_employee_address (
         csr_v_person_id                     NUMBER
        ,csr_v_effective_date                DATE
      )
      IS
         SELECT address_line1
               ,address_line2
               ,address_line3
               ,postal_code
               ,country
               ,ft.territory_short_name
           FROM per_addresses
               ,fnd_territories_vl ft
          WHERE business_group_id = g_business_group_id
            AND person_id = csr_v_person_id
            AND country = ft.territory_code
            AND csr_v_effective_date BETWEEN date_from
                                         AND NVL (date_to
                                                 ,TO_DATE ('31-12-4712'
                                                          ,'DD-MM-YYYY'
                                                          )
                                                 );

      lr_get_employee_address       csr_get_employee_address%ROWTYPE;

      CURSOR csr_get_month_to_from (
         csr_v_person_id                     NUMBER
        ,csr_v_legal_employer                NUMBER
      )
      IS
         SELECT MIN (paa.effective_start_date) effective_start_date
               ,MAX (paa.effective_end_date) effective_end_date
           FROM per_all_assignments_f paa
               ,hr_soft_coding_keyflex scl
          WHERE person_id = csr_v_person_id
            AND paa.effective_start_date <= g_income_end_date
            AND paa.effective_end_date > = g_income_start_date
            AND assignment_status_type_id IN (
                   SELECT assignment_status_type_id
                     FROM per_assignment_status_types
                    WHERE per_system_status = 'ACTIVE_ASSIGN'
                      AND active_flag = 'Y'
                      AND (   (    legislation_code IS NULL
                               AND business_group_id IS NULL
                              )
                           OR (business_group_id = g_business_group_id)
                          ))
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
            AND scl.segment2 IN (
                   SELECT o1.organization_id
                     FROM hr_organization_units o1
                         ,hr_organization_information hoi1
                         ,hr_organization_information hoi2
                         ,hr_organization_information hoi3
                    WHERE o1.business_group_id = g_business_group_id
                      AND hoi1.organization_id = o1.organization_id
                      AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
                      AND hoi1.org_information_context = 'CLASS'
                      AND NVL (hoi1.org_information2, 'N') = 'Y'
                      AND o1.organization_id = hoi2.org_information1
                      AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
                      AND hoi2.organization_id = hoi3.organization_id
                      AND hoi3.org_information_context = 'CLASS'
                      AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
                      AND hoi3.organization_id = csr_v_legal_employer
                      AND NVL (hoi3.org_information2, 'N') = 'Y');

      lr_get_month_to_from          csr_get_month_to_from%ROWTYPE;

      CURSOR csr_person_correction_date (csr_v_person_id NUMBER)
      IS
         SELECT pei_information1
           FROM per_people_extra_info
          WHERE person_id = csr_v_person_id
            AND information_type = 'SE_INC_STMT_DATA_CORRECTION';

      lr_person_correction_date     csr_person_correction_date%ROWTYPE;

      -- Cursor to pick up segment2
      CURSOR csr_get_segment2 (csr_v_effective_date DATE)
      IS
         SELECT scl.segment2
               ,scl.segment8
           FROM per_all_assignments_f paa
               ,hr_soft_coding_keyflex scl
               ,pay_assignment_actions pasa
          WHERE pasa.assignment_action_id = p_assignment_action_id
            AND pasa.assignment_id = paa.assignment_id
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
            AND csr_v_effective_date BETWEEN paa.effective_start_date
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
               ,hoi2.org_information2
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

      CURSOR csr_get_assignments (csr_v_person_id NUMBER)
      IS
         SELECT paa.assignment_id
               ,paa.effective_start_date
               ,paa.effective_end_date
               ,scl.segment2
           FROM per_all_assignments_f paa
               ,hr_soft_coding_keyflex scl
          WHERE paa.person_id = csr_v_person_id
            AND paa.effective_start_date <= g_income_end_date
            AND paa.effective_end_date > = g_income_start_date
            AND paa.assignment_status_type_id IN (
                   SELECT assignment_status_type_id
                     FROM per_assignment_status_types
                    WHERE per_system_status = 'ACTIVE_ASSIGN'
                      AND active_flag = 'Y'
                      AND (   (    legislation_code IS NULL
                               AND business_group_id IS NULL
                              )
                           OR (business_group_id = g_business_group_id)
                          ))
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id;

      lr_get_assignments            csr_get_assignments%ROWTYPE;

      CURSOR csr_get_prim_assignments (csr_v_person_id NUMBER)
      IS
         SELECT paa.assignment_id
               ,paa.effective_start_date
               ,paa.effective_end_date
               ,scl.segment2
           FROM per_all_assignments_f paa
               ,hr_soft_coding_keyflex scl
          WHERE person_id = csr_v_person_id
            AND paa.effective_start_date <= g_income_end_date
            AND paa.effective_end_date > = g_income_start_date
            AND paa.primary_flag = 'Y'
            AND paa.assignment_status_type_id IN (
                   SELECT assignment_status_type_id
                     FROM per_assignment_status_types
                    WHERE per_system_status = 'ACTIVE_ASSIGN'
                      AND active_flag = 'Y'
                      AND (   (    legislation_code IS NULL
                               AND business_group_id IS NULL
                              )
                           OR (business_group_id = g_business_group_id)
                          ))
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id;

      lr_get_prim_assignments       csr_get_prim_assignments%ROWTYPE;

      CURSOR csr_chk_valid_le_lu (
         csr_v_local_unit_id                 hr_organization_information.organization_id%TYPE
        ,csr_v_legal_employer_id             hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT 'Y' "VALID"
           FROM hr_organization_units o1
               ,hr_organization_information hoi1
               ,hr_organization_information hoi2
               ,hr_organization_information hoi3
          WHERE o1.business_group_id = g_business_group_id
            AND hoi1.organization_id = o1.organization_id
            AND hoi1.org_information1 = 'SE_LOCAL_UNIT'
            AND hoi1.org_information_context = 'CLASS'
            AND NVL (hoi1.org_information2, 'N') = 'Y'
            AND o1.organization_id = hoi2.org_information1
            AND hoi2.org_information_context = 'SE_LOCAL_UNITS'
            AND hoi2.organization_id = hoi3.organization_id
            AND hoi3.org_information_context = 'CLASS'
            AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
            AND hoi3.organization_id = csr_v_legal_employer_id
            AND NVL (hoi3.org_information2, 'N') = 'Y'
            AND o1.organization_id = csr_v_local_unit_id;

      lr_chk_valid_le_lu            csr_chk_valid_le_lu%ROWTYPE;

      CURSOR csr_get_element_ids
      IS
         SELECT pet.element_type_id
               ,piv.input_value_id
               ,pel.element_link_id
           FROM pay_element_types_f pet
               ,pay_input_values_f piv
               ,pay_element_links_f pel
          WHERE pet.element_name = 'Tax Card'
            AND pet.legislation_code = 'SE'
            AND piv.element_type_id = pet.element_type_id
            AND piv.NAME = 'Tax Card Type'
            AND pel.element_type_id = pet.element_type_id
            AND pel.business_group_id = g_business_group_id
            AND pet.effective_start_date <= g_income_end_date
            AND pet.effective_end_date > = g_income_start_date
            AND piv.effective_start_date <= g_income_end_date
            AND piv.effective_end_date > = g_income_start_date
            AND pel.effective_start_date <= g_income_end_date
            AND pel.effective_end_date > = g_income_start_date;

      lr_get_element_ids            csr_get_element_ids%ROWTYPE;

      CURSOR csr_get_element_type_id (csr_v_element_name VARCHAR2)
      IS
         SELECT pet.element_type_id
               ,pel.element_link_id
           FROM pay_element_types_f pet
               ,pay_element_links_f pel
          WHERE pet.element_name = csr_v_element_name
            AND pet.legislation_code = 'SE'
            AND pel.element_type_id = pet.element_type_id
            AND pel.business_group_id = g_business_group_id
            AND pet.effective_start_date <= g_income_end_date
            AND pet.effective_end_date > = g_income_start_date
            AND pel.effective_start_date <= g_income_end_date
            AND pel.effective_end_date > = g_income_start_date;

      lr_get_element_type_id        csr_get_element_type_id%ROWTYPE;

/*
      CURSOR csr_chk_A_taxcard (
         csr_v_input_value_id   pay_element_entry_values_f.input_value_id%TYPE
         ,csr_v_link_id   pay_element_entries_f.ELEMENT_LINK_ID%TYPE
         ,csr_v_type_id   pay_element_entries_f.ELEMENT_TYPE_ID%TYPE
         ,csr_v_person_id  NUMBER
      ) is
SELECT count('Y') VALID
   from pay_element_entries_f pee
   , per_all_assignments_f paa
    , pay_element_entry_values_f peev
   where peev.screen_entry_value ='A'
     AND peev.element_entry_id = pee.element_entry_id
    AND  peev.input_value_id   = csr_v_input_value_id
AND peev.EFFECTIVE_START_DATE = pee.EFFECTIVE_START_DATE
AND peev.EFFECTIVE_END_DATE =  pee.EFFECTIVE_END_DATE
   and pee.ELEMENT_LINK_ID = csr_v_link_id
   and paa.ASSIGNMENT_ID = pee.ASSIGNMENT_ID
   and pee.ELEMENT_TYPE_ID = csr_v_type_id
   and pee.ASSIGNMENT_ID = paa.assignment_id
   AND PAA.PERSON_ID = csr_v_person_id
   AND PAA.BUSINESS_GROUP_ID      = g_business_group_id
   AND PAA.PRIMARY_FLAG = 'Y'
    AND pee.EFFECTIVE_START_DATE  <= g_income_end_date    AND pee.EFFECTIVE_END_DATE > = g_income_start_date
    AND paa.EFFECTIVE_START_DATE  <= g_income_end_date    AND paa.EFFECTIVE_END_DATE > = g_income_start_date
    AND paa.assignment_status_type_id IN
                            (select assignment_status_type_id
                                    from per_assignment_status_types
                                    where per_system_status = 'ACTIVE_ASSIGN'
                                    and active_flag = 'Y'
                                    and (
                                          (     legislation_code is null
                                            and business_group_id is null
                                          )
                                        OR
                                        (   BUSINESS_GROUP_ID = g_business_group_id )
                                        )
                                );
*/
      CURSOR csr_chk_a_taxcard (
         csr_v_input_value_id                pay_element_entry_values_f.input_value_id%TYPE
        ,csr_v_link_id                       pay_element_entries_f.element_link_id%TYPE
        ,csr_v_type_id                       pay_element_entries_f.element_type_id%TYPE
        ,csr_v_prim_assignment_id            NUMBER
      )
      IS
         SELECT COUNT ('Y') valid
           FROM pay_element_entries_f pee
               ,pay_element_entry_values_f peev
          WHERE peev.screen_entry_value = 'A'
            AND peev.element_entry_id = pee.element_entry_id
            AND peev.effective_start_date = pee.effective_start_date
            AND peev.effective_end_date = pee.effective_end_date
            AND peev.input_value_id = csr_v_input_value_id
            AND pee.element_link_id = csr_v_link_id
            AND pee.element_type_id = csr_v_type_id
            AND pee.assignment_id = csr_v_prim_assignment_id
            AND pee.effective_start_date <= g_income_end_date
            AND pee.effective_end_date > = g_income_start_date;

      lr_chk_a_taxcard              csr_chk_a_taxcard%ROWTYPE;

-- *****************************************************************************
-- Income Statement Specification Details
      CURSOR csr_person_inc_stmt_spec (
         csr_v_person_id                     NUMBER
        ,csr_v_information_type              per_people_extra_info.information_type%TYPE
      )
      IS
         SELECT pei_information1
               ,pei_information2
               ,pei_information3
               ,pei_information4
               ,pei_information5
               ,pei_information6
               ,pei_information7
               ,pei_information8
               ,pei_information9
           FROM per_people_extra_info
          WHERE person_id = csr_v_person_id
            AND information_type = csr_v_information_type;

      lr_person_inc_stmt_spec       csr_person_inc_stmt_spec%ROWTYPE;

-- *****************************************************************************
      CURSOR csr_get_ben_elem_type_id (
         csr_v_assignment_id                 NUMBER
        ,csr_v_elem_code                     VARCHAR2
        ,csr_v_category                      VARCHAR2
      )
      IS
         SELECT pet.element_type_id
               ,pel.element_link_id
               ,pee.element_entry_id
           FROM pay_element_types_f pet
               ,pay_element_links_f pel
               ,pay_element_entries_f pee
          WHERE pel.element_type_id = pet.element_type_id
            AND (pet.legislation_code = 'SE' OR pet.legislation_code IS NULL
                )
            AND pel.business_group_id = g_business_group_id
            AND pet.effective_start_date <= g_income_end_date
            AND pet.effective_end_date > = g_income_start_date
            AND pel.effective_start_date <= g_income_end_date
            AND pel.effective_end_date > = g_income_start_date
            AND pee.effective_start_date <= g_income_end_date
            AND pee.effective_end_date > = g_income_start_date
            AND pet.element_information1 = csr_v_elem_code
            AND pet.element_information_category = csr_v_category
            AND pee.element_link_id = pel.element_link_id
            AND pee.assignment_id = csr_v_assignment_id;

      CURSOR csr_get_elem_processed (csr_v_element_entry_id NUMBER)
      IS
         SELECT 'Y' "PROCESSED"
           FROM pay_run_results prr
               ,pay_element_entries_f pee
          WHERE pee.element_entry_id =
                                  csr_v_element_entry_id
                                                        --p_p_element_entry_id
            /*and     p_effective_date*  between pee.effective_start_date
                                         and pee.effective_end_date*/
            AND pee.effective_start_date BETWEEN g_income_start_date
                                             AND g_income_end_date
            AND pee.effective_end_date BETWEEN g_income_start_date
                                           AND g_income_end_date
            AND prr.source_id = pee.element_entry_id
            AND prr.entry_type = pee.entry_type
            AND prr.source_type = 'E'
            AND prr.status <> 'U'
            AND NOT EXISTS (
                   SELECT 1
                     FROM pay_run_results sub_rr
                    WHERE sub_rr.source_id = prr.run_result_id
                      AND sub_rr.source_type IN ('R', 'V'));

      CURSOR csr_get_car_elem (csr_v_assignment_id NUMBER)
      IS
         SELECT   pee.element_entry_id
                 ,pet.element_name
                 ,pee.effective_start_date
                 ,pee.effective_end_date
             FROM pay_element_entries_f pee
                 ,pay_element_types_f pet
            WHERE pet.element_name = 'Car Benefit'
              AND pet.legislation_code = 'SE'
              AND pee.assignment_id = csr_v_assignment_id
              AND pee.element_type_id = pet.element_type_id
              AND pee.effective_start_date <= g_income_end_date
              AND pee.effective_end_date >= g_income_start_date
              AND pet.effective_start_date <= g_income_end_date
              AND pet.effective_end_date >= g_income_start_date
         ORDER BY pee.effective_end_date DESC;

      lr_get_car_elem               csr_get_car_elem%ROWTYPE;

      CURSOR csr_get_car_elem_details (
                                       --csr_v_assignment_id  NUMBER      , Not Needed now
                                       csr_v_ee_id NUMBER)
      IS
         SELECT pee.element_entry_id
               ,pee.effective_start_date
               ,pee.effective_end_date
               ,peev.screen_entry_value
           FROM pay_element_entries_f pee
               ,pay_input_values_f piv
               ,pay_element_entry_values_f peev
          WHERE pee.element_entry_id = csr_v_ee_id
            AND piv.element_type_id = piv.element_type_id
            AND piv.NAME = 'RSV Code'
            AND peev.element_entry_id = pee.element_entry_id
            AND peev.input_value_id = piv.input_value_id
-- AND pee.ASSIGNMENT_ID = csr_v_assignment_id Not Needed now.
            AND pee.effective_start_date <= g_income_end_date
            AND pee.effective_end_date > = g_income_start_date
            AND piv.effective_start_date <= g_income_end_date
            AND piv.effective_end_date > = g_income_start_date;

      lr_get_car_elem_details       csr_get_car_elem_details%ROWTYPE;
      -- End of Cursors
      l_period_start_date           DATE;
      l_period_end_date             DATE;
      l_effective_end_date DATE;
-- Cursor to pick up the Absence details
--#########################################

   -- End of place for Cursor  which fetches the values to be archived
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure ARCHIVE_CODE', 380);
      END IF;

      --logger ('ARCHIVE_CODE ', '--------------------------------Started');
      --logger ('p_assignment_action_id ', p_assignment_action_id);
      --logger ('p_effective_date ', p_effective_date);

      OPEN csr_get_person_id (p_assignment_action_id);

      FETCH csr_get_person_id
       INTO lr_get_person_id;

      CLOSE csr_get_person_id;

      l_person_id := lr_get_person_id.person_id;
      l_effective_date :=
         GREATEST (lr_get_person_id.effective_start_date, g_income_start_date);
      l_assignment_id := lr_get_person_id.assignment_id;
      --logger ('l_person_id ', l_person_id);
      --logger ('l_effective_date ', l_effective_date);
      --logger ('l_assignment_id ', l_assignment_id);

      OPEN csr_get_prim_assignments (l_person_id);

      FETCH csr_get_prim_assignments
       INTO lr_get_prim_assignments;

      CLOSE csr_get_prim_assignments;

      l_primary_local_unit_id := lr_get_prim_assignments.segment2;
      l_primary_assignment_id := lr_get_prim_assignments.assignment_id;

-- *****************************************************************************
-- TO pick up the Local Unit
      OPEN csr_get_segment2 (l_effective_date);

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
      --logger ('==============PERSON================== ', '=');

-- *****************************************************************************
   -- TO pick up the PIN
      OPEN csr_get_person_details (l_person_id, l_effective_date);

      FETCH csr_get_person_details
       INTO lr_get_person_details;

      CLOSE csr_get_person_details;
    l_effective_end_date :=lr_get_person_details.effective_end_date;
      l_employee_pin := lr_get_person_details.national_identifier;
      --logger ('l_employee_pin ', l_employee_pin);
      l_employee_last_name := lr_get_person_details.last_name;
      --logger ('l_employee_last_name ', l_employee_last_name);
      l_employee_number := lr_get_person_details.employee_number;
      --logger ('l_employee_number ', l_employee_number);

--********************************************************************************--
      -- Changes EOY 2008/2009
      --Date of Birth is tracked for changes in field 31 and 32
      -- where Special job Deduction is not longer in use for persons
      -- born 1937 or earlier.
      -- Salary for persons born 1937 or earlier should be reported in field 31
      l_date_of_birth := lr_get_person_details.date_of_birth;

--*********************************************************************************--

      l_employee_name :=
            lr_get_person_details.last_name
         || ' '
         || lr_get_person_details.first_name;
      --logger ('l_employee_name ', l_employee_name);
      l_in_plain_writing_meaning := lr_get_person_details.territory_short_name;
      --logger ('l_In_plain_Writing_meaning ', l_in_plain_writing_meaning);
      l_in_plain_writing_code := lr_get_person_details.territory_code;
      --logger ('l_In_plain_Writing_code ', l_in_plain_writing_code);

-- *****************************************************************************
      OPEN csr_get_employee_address (l_person_id, l_effective_date);

      FETCH csr_get_employee_address
       INTO lr_get_employee_address;

      CLOSE csr_get_employee_address;

      l_employees_address :=
            lr_get_employee_address.address_line1
         || ' '
         || lr_get_employee_address.address_line2
         || ' '
         || lr_get_employee_address.address_line3;
      l_employees_postalcode := lr_get_employee_address.postal_code;
      -- Bug#8849455 fix Added space between 3 and 4 digits in postal code
      l_employees_postalcode := substr(l_employees_postalcode,1,3)||' '||substr(l_employees_postalcode,4,2);
      l_employee_postal_address :=
                                  lr_get_employee_address.territory_short_name;

-- *****************************************************************************
      OPEN csr_get_month_to_from (l_person_id, l_legal_employer_id_fetched);

      FETCH csr_get_month_to_from
       INTO lr_get_month_to_from;

      CLOSE csr_get_month_to_from;

      l_month_from :=
         TO_CHAR (GREATEST (g_income_start_date
                           ,lr_get_month_to_from.effective_start_date
                           )
                 ,'MM'
                 );
      l_month_to :=
         TO_CHAR (LEAST (g_income_end_date
                        ,lr_get_month_to_from.effective_end_date
                        )
                 ,'MM'
                 );
      --logger ('l_month_from ', l_month_from);
      --logger ('l_month_to ', l_month_to);
-- *****************************************************************************
/*      OPEN csr_Person_correction_date (l_person_id);
      FETCH csr_Person_correction_date    INTO lr_Person_correction_date;
      CLOSE csr_Person_correction_date;

l_date_of_correction := lr_Person_correction_date.PEI_INFORMATION1;
      logger ('l_date_of_correction ', l_date_of_correction);
*/
-- *****************************************************************************
      l_free_housing_other41_flag := 'N';
      l_interest_flag := 'N';
      l_other_benefits_flag := 'N';
      l_busi_travel_expenses_flag := 'N';
      l_acc_business_travels_flag := 'N';
      l_car_elem_end_date := NULL;
      l_car_elem_start_date := NULL;
      l_car_elem_entry_id := NULL;
-- Amount of A-tax withheld
-- With this Person id and Legal employer id.
-- find all the assignment for this person for this legal employer
-- for these assignments find the tax card element .
-- if any of these elements is having value A-Tax Card
-- populate this from " Employee Taxable Base PER_LE_YTD "
      l_a_tax_withheld_flag := 'N';

      FOR row_get_assignments IN csr_get_assignments (l_person_id)
      LOOP
-- *****************************************************************************
-- A Tax card field
-- *****************************************************************************
         OPEN csr_chk_valid_le_lu (row_get_assignments.segment2
                                  ,l_legal_employer_id_fetched
                                  );

         FETCH csr_chk_valid_le_lu
          INTO lr_chk_valid_le_lu;

         CLOSE csr_chk_valid_le_lu;

-- *****************************************************************************
         IF lr_chk_valid_le_lu.valid = 'Y'
         THEN
 /*
-- *****************************************************************************
-- l_A_TAX_WITHHELD_FLAG
-- *****************************************************************************
        IF l_A_TAX_WITHHELD_FLAG <> 'Y'
            THEN

      OPEN csr_get_element_ids ;
      FETCH csr_get_element_ids    INTO lr_get_element_ids;
      CLOSE csr_get_element_ids;

      OPEN csr_chk_A_taxcard(
        lr_get_element_ids.input_value_id
      , lr_get_element_ids.ELEMENT_LINK_ID
      , lr_get_element_ids.ELEMENT_TYPE_ID
      , l_primary_assignment_id
      ) ;
      FETCH csr_chk_A_taxcard    INTO lr_chk_A_taxcard;
      CLOSE csr_chk_A_taxcard;

        IF lr_chk_A_taxcard.VALID > 0
        THEN
            l_A_TAX_WITHHELD := --TO_CHAR
            round(get_defined_balance_value
                              ('EMPLOYEE_TAX_PER_LE_YTD'
                             , l_assignment_id
                             , g_income_end_date
                             , l_legal_employer_id_fetched
                             , NULL
                              )
--           , '999999999D99'
            );
            l_A_TAX_WITHHELD_FLAG := 'Y';
        END IF;

END IF;
*/
-- *****************************************************************************
-- *****************************************************************************
-- *****************************************************************************
-- END OF A Tax card field
-- *****************************************************************************
            --logger ('row_get_assignments.assignment_id '                   ,row_get_assignments.assignment_id                   );

-- *****************************************************************************
-- free_housing_other41
-- *****************************************************************************
            IF l_free_housing_other41_flag <> 'Y'
            THEN
               FOR row_ben_elem_type_id IN
                  csr_get_ben_elem_type_id
                                          (row_get_assignments.assignment_id
                                          ,'43'
                                          ,'SE_BENEFITS IN KIND'
                                          )
               LOOP
                  --logger ('row_ben_elem_type_id ELEMENT_ENTRY_ID '                         ,row_ben_elem_type_id.element_entry_id                         );

                  -- row_ben_elem_type_id.ELEMENT_TYPE_ID
                  -- row_ben_elem_type_id.ELEMENT_ENTRY_ID
                  IF l_free_housing_other41_flag <> 'Y'
                  THEN
                     FOR row_get_elem_processed IN
                        csr_get_elem_processed
                                       (row_ben_elem_type_id.element_entry_id)
                     LOOP
                        IF row_get_elem_processed.processed = 'Y'
                        THEN
                           l_free_housing_other41_flag := 'Y';
                           --logger ('free_housing_other41_flag '                                  ,l_free_housing_other41_flag                                  );
                        END IF;

                        EXIT WHEN l_free_housing_other41_flag = 'Y';
                     END LOOP;
                  END IF;

                  EXIT WHEN l_free_housing_other41_flag = 'Y';
               END LOOP;
            END IF;

-- *****************************************************************************
-- END OF free_housing_other41
-- *****************************************************************************
-- *****************************************************************************
-- l_interest
-- *****************************************************************************
            IF l_interest_flag <> 'Y'
            THEN
               FOR row_ben_elem_type_id IN
                  csr_get_ben_elem_type_id
                                          (row_get_assignments.assignment_id
                                          ,'44'
                                          ,'SE_BENEFITS IN KIND'
                                          )
               LOOP
                  --logger ('row_ben_elem_type_id ELEMENT_ENTRY_ID '                         ,row_ben_elem_type_id.element_entry_id                         );

                  -- row_ben_elem_type_id.ELEMENT_TYPE_ID
                  -- row_ben_elem_type_id.ELEMENT_ENTRY_ID
                  IF l_interest_flag <> 'Y'
                  THEN
                     FOR row_get_elem_processed IN
                        csr_get_elem_processed
                                       (row_ben_elem_type_id.element_entry_id)
                     LOOP
                        IF row_get_elem_processed.processed = 'Y'
                        THEN
                           l_interest_flag := 'Y';
                           --logger ('l_interest_flag ', l_interest_flag);
                        END IF;

                        EXIT WHEN l_interest_flag = 'Y';
                     END LOOP;
                  END IF;

                  EXIT WHEN l_interest_flag = 'Y';
               END LOOP;
            END IF;

-- *****************************************************************************
-- END OF l_interest
-- *****************************************************************************

            -- *****************************************************************************
-- l_Other_benefits_flag
-- *****************************************************************************
            IF l_other_benefits_flag <> 'Y'
            THEN
               FOR row_ben_elem_type_id IN
                  csr_get_ben_elem_type_id
                                          (row_get_assignments.assignment_id
                                          ,'47'
                                          ,'SE_BENEFITS IN KIND'
                                          )
               LOOP
                  --logger ('row_ben_elem_type_id ELEMENT_ENTRY_ID '                         ,row_ben_elem_type_id.element_entry_id                         );

                  -- row_ben_elem_type_id.ELEMENT_TYPE_ID
                  -- row_ben_elem_type_id.ELEMENT_ENTRY_ID
                  IF l_other_benefits_flag <> 'Y'
                  THEN
                     FOR row_get_elem_processed IN
                        csr_get_elem_processed
                                       (row_ben_elem_type_id.element_entry_id)
                     LOOP
                        IF row_get_elem_processed.processed = 'Y'
                        THEN
                           l_other_benefits_flag := 'Y';
                           --logger ('l_Other_benefits_flag '                                  ,l_other_benefits_flag                                  );
                        END IF;

                        EXIT WHEN l_other_benefits_flag = 'Y';
                     END LOOP;
                  END IF;

                  EXIT WHEN l_other_benefits_flag = 'Y';
               END LOOP;
            END IF;

-- *****************************************************************************
-- END OF l_Other_benefits_flag
-- *****************************************************************************

            -- *****************************************************************************
-- l_Busi_travel_expenses_flag
-- *****************************************************************************
            IF l_busi_travel_expenses_flag <> 'Y'
            THEN
               FOR row_ben_elem_type_id IN
                  csr_get_ben_elem_type_id
                                          (row_get_assignments.assignment_id
                                          ,'55'
                                          ,'SE_TAXABLE EXPENSES'
                                          )
               LOOP
                  --logger ('row_ben_elem_type_id ELEMENT_ENTRY_ID '                         ,row_ben_elem_type_id.element_entry_id                         );

                  -- row_ben_elem_type_id.ELEMENT_TYPE_ID
                  -- row_ben_elem_type_id.ELEMENT_ENTRY_ID
                  IF l_busi_travel_expenses_flag <> 'Y'
                  THEN
                     FOR row_get_elem_processed IN
                        csr_get_elem_processed
                                       (row_ben_elem_type_id.element_entry_id)
                     LOOP
                        IF row_get_elem_processed.processed = 'Y'
                        THEN
                           l_busi_travel_expenses_flag := 'Y';
                           --logger ('l_Busi_travel_expenses_flag '                                  ,l_busi_travel_expenses_flag                                  );
                        END IF;

                        EXIT WHEN l_busi_travel_expenses_flag = 'Y';
                     END LOOP;
                  END IF;

                  EXIT WHEN l_busi_travel_expenses_flag = 'Y';
               END LOOP;
            END IF;

-- *****************************************************************************
-- END OF l_Busi_travel_expenses_flag
-- *****************************************************************************

            -- *****************************************************************************
-- l_Acc_business_travels_flag
-- *****************************************************************************
            IF l_acc_business_travels_flag <> 'Y'
            THEN
               FOR row_ben_elem_type_id IN
                  csr_get_ben_elem_type_id
                                          (row_get_assignments.assignment_id
                                          ,'56'
                                          ,'SE_TAXABLE EXPENSES'
                                          )
               LOOP
                  --logger ('row_ben_elem_type_id ELEMENT_ENTRY_ID '                         ,row_ben_elem_type_id.element_entry_id                         );

                  -- row_ben_elem_type_id.ELEMENT_TYPE_ID
                  -- row_ben_elem_type_id.ELEMENT_ENTRY_ID
                  IF l_acc_business_travels_flag <> 'Y'
                  THEN
                     FOR row_get_elem_processed IN
                        csr_get_elem_processed
                                       (row_ben_elem_type_id.element_entry_id)
                     LOOP
                        IF row_get_elem_processed.processed = 'Y'
                        THEN
                           l_acc_business_travels_flag := 'Y';
                           --logger ('l_Acc_business_travels_flag '                                  ,l_acc_business_travels_flag                                  );
                        END IF;

                        EXIT WHEN l_acc_business_travels_flag = 'Y';
                     END LOOP;
                  END IF;

                  EXIT WHEN l_acc_business_travels_flag = 'Y';
               END LOOP;
            END IF;

-- *****************************************************************************
-- END OF l_Busi_travel_expenses_flag
-- *****************************************************************************

            -- *****************************************************************************
-- CAR ELEMENT
-- *****************************************************************************
            --logger ('FOR EACH.assignment_id '                   ,row_get_assignments.assignment_id                   );
            lr_get_car_elem := NULL;

            OPEN csr_get_car_elem (row_get_assignments.assignment_id);

            FETCH csr_get_car_elem
             INTO lr_get_car_elem;

            CLOSE csr_get_car_elem;

            --logger ('lr_get_Car_elem.EFFECTIVE_END_DATE  '                   ,lr_get_car_elem.effective_end_date                   );
            --logger ('lr_get_Car_elem.EFFECTIVE_START_DATE  '                   ,lr_get_car_elem.effective_start_date                   );
            --logger ('lr_get_Car_elem.ELEMENT_ENTRY_ID  '                   ,lr_get_car_elem.element_entry_id                   );

            /* For the firsttime the value has to be put in variables ;)*/
            IF l_car_elem_end_date IS NULL
            THEN
               l_car_elem_end_date := lr_get_car_elem.effective_end_date;
               l_car_elem_start_date := lr_get_car_elem.effective_start_date;
               l_car_elem_entry_id := lr_get_car_elem.element_entry_id;
            /* From the next-time the value has to be put in variables after comparing ;)*/
            ELSIF     lr_get_car_elem.effective_end_date IS NOT NULL
                  AND lr_get_car_elem.effective_end_date > l_car_elem_end_date
            THEN
               l_car_elem_end_date := lr_get_car_elem.effective_end_date;
               l_car_elem_start_date := lr_get_car_elem.effective_start_date;
               l_car_elem_entry_id := lr_get_car_elem.element_entry_id;
            END IF;
-- *****************************************************************************
-- END OF CAR ELEMENT
-- *****************************************************************************
         END IF;                                        -- for valid LE nad LE
      END LOOP;

      --logger ('l_free_housing_flag ', l_free_housing_other41_flag);
      --logger ('l_interest_flag ', l_interest_flag);
      --logger ('l_Other_benefits_flag ', l_other_benefits_flag);
      --logger ('l_Busi_travel_expenses_flag ', l_busi_travel_expenses_flag);
      --logger ('l_Acc_business_travels_flag ', l_acc_business_travels_flag);
      --logger ('l_car_elem_end_date ', l_car_elem_end_date);
      --logger ('l_car_elem_start_date ', l_car_elem_start_date);
      --logger ('l_car_elem_entry_id ', l_car_elem_entry_id);
      --logger ('Balance ', 'Values');
      --logger ('l_assignment_id ', l_assignment_id);
      --logger ('g_income_end_date ', g_income_end_date);
      --logger ('l_legal_employer_id_fetched ', l_legal_employer_id_fetched);
-- *****************************************************************************
-- Employer Taxable Base PER_LE_YTD
g_income_end_date := least(l_effective_end_date,g_income_end_date);
      --logger ('After Least g_income_end_date ', g_income_end_date);
      l_a_tax_withheld :=
--         TO_CHAR
              round(get_defined_balance_value ('EMPLOYEE_TAX_PER_LE_YTD'
                                         ,l_assignment_id
                                         ,g_income_end_date
                                         ,l_legal_employer_id_fetched
                                         ,NULL
                                         )
--              ,'999999999D99'
              );
      --logger ('l_A_TAX_WITHHELD ', l_a_tax_withheld);
-- *****************************************************************************
-- Gross salary get from Taxable Base PER_LE_YTD
      l_gross_salary :=
--         TO_CHAR
 round(get_defined_balance_value ('GROSS_SALARY_PER_LE_YTD'
                                            ,l_assignment_id
                                            ,g_income_end_date
                                            ,l_legal_employer_id_fetched
                                            ,NULL
                                            )
--                 ,'999999999D99'
                 );
      --logger ('l_gross_salary ', l_gross_salary);
-- *****************************************************************************
--Taxable benefits exclusive of employer-provided car and fuel
-- get from Using Balance:
-- Benefits in Kind PER_LE_YTD -
-- ( Car Benefit in Kind PER_LE_YTD + Fuel Benefit in Kind PER_LE_YTD )
      l_ben_ytd :=
--         TO_CHAR
round(get_defined_balance_value ('BENEFITS_IN_KIND_PER_LE_YTD'
                                            ,l_assignment_id
                                            ,g_income_end_date
                                            ,l_legal_employer_id_fetched
                                            ,NULL
                                            )
--                 ,'999999999D99'
                 );
      --logger ('l_ben_ytd ', l_ben_ytd);
      l_car_ben_ytd :=
--         TO_CHAR
                round(get_defined_balance_value ('CAR_BENEFIT_IN_KIND_PER_LE_YTD'
                                           ,l_assignment_id
                                           ,g_income_end_date
                                           ,l_legal_employer_id_fetched
                                           ,NULL
                                           )
  --              ,'999999999D99'
                );
      --logger ('l_car_ben_YTD ', l_car_ben_ytd);
      l_fuel_ben_ytd :=
--         TO_CHAR
               round(get_defined_balance_value ('FUEL_BENEFIT_IN_KIND_PER_LE_YTD'
                                          ,l_assignment_id
                                          ,g_income_end_date
                                          ,l_legal_employer_id_fetched
                                          ,NULL
                                          )
--               ,'999999999D99'
               );
      --logger ('l_fuel_ben_YTD ', l_fuel_ben_ytd);
      l_tb_exclusive_car_fuel := l_ben_ytd - (l_car_ben_ytd + l_fuel_ben_ytd);
      --logger ('l_tb_exclusive_car_fuel ', l_tb_exclusive_car_fuel);
-- *****************************************************************************
-- Taxable benefit of employer-provided car exclusive of fuel
-- Using Balance: Car Benefit in Kind PER_LE_YTD
      l_tb_exclusive_fuel := l_car_ben_ytd;
      --logger ('l_tb_exclusive_fuel ', l_tb_exclusive_fuel);

-- *****************************************************************************
-- RSV-code of employer-provided car
-- the "Car Benefit" Element input value RSV Code.
-- For the given person id and Legal employer and income year
-- all assignments under the above condition
-- find last element entry in these assignments
-- get the input value
      IF l_car_elem_entry_id IS NOT NULL
      THEN
         lr_get_car_elem_details := NULL;

         OPEN csr_get_car_elem_details (l_car_elem_entry_id);

         FETCH csr_get_car_elem_details
          INTO lr_get_car_elem_details;

         CLOSE csr_get_car_elem_details;

         l_rsv_code := lr_get_car_elem_details.screen_entry_value;
         l_car_elem_end_date := LEAST (l_car_elem_end_date, g_income_end_date);
         l_car_elem_start_date :=
                         GREATEST (l_car_elem_start_date, g_income_start_date);
      ELSE
         l_rsv_code := NULL;
      END IF;

      --logger ('l_rsv_code ', l_rsv_code);
-- *****************************************************************************
-- Number of months with employer-provided car
-- Using Element: Car Benefit
-- Using the Start -  End Dates - Report Number of Months
-- (Only, if less than 12 Months)
-- Note: Part of month should be calculated as whole month.
      --logger ('l_car_elem_end_date ', l_car_elem_end_date);
      --logger ('l_car_elem_start_date ', l_car_elem_start_date);
      --logger ('last_day(l_car_elem_end_date) '             ,LAST_DAY (l_car_elem_end_date));
      --logger ('trunc(l_car_elem_start_date,) '             ,TRUNC (l_car_elem_start_date, 'MM')             );
      l_number_of_months_car :=
         CEIL (MONTHS_BETWEEN (LAST_DAY (l_car_elem_end_date)
                              ,TRUNC (l_car_elem_start_date, 'MM')
                              )
              );
      --logger ('l_number_of_months_car ', l_number_of_months_car);
-- *****************************************************************************
-- Number of kilometers with mileage allowance for employer-provided car
-- Using Balance : Cumulative Distance
--
      l_number_of_kilometers :=
--         TO_CHAR
                round(get_defined_balance_value ('CUMULATIVE_DISTANCE_PER_LE_YTD'
                                           ,l_assignment_id
                                           ,g_income_end_date
                                           ,l_legal_employer_id_fetched
                                           ,NULL
                                           )
--                ,'999999999D99'
                );
      --logger ('l_number_of_kilometers ', l_number_of_kilometers);
-- *****************************************************************************
-- Employee's payment for employer-provided car.
-- Using Balance : Car Benefit in Kind
      l_emp_payment_car := l_car_ben_ytd;
-- *****************************************************************************
-- Free fuel in connection with employer-provided car
-- Using Balance: Fuel Benefit in Kind PER_LE_YTD
      l_free_fuel_car := l_fuel_ben_ytd;
-- *****************************************************************************
-- Compensation for expenses not ticked in boxes at codes 50-56
-- Pick up from the EIT

      --l_compensation_for_expenses := 0 ;
      --logger ('l_legal_employer_id_fetched ', l_legal_employer_id_fetched);
      --logger         ('each_field_value ().FIELD_CODE(KU10_CFE) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU10_CFE')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU10_CFE');
      l_compensation_for_expenses :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_compensation_for_expenses ', l_compensation_for_expenses);
-- *****************************************************************************
-- Occupational pension
-- Pick up from the EIT

      --l_Occupational_pension := 0 ;
      --logger         ('each_field_value ().FIELD_CODE(KU10_OCP) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU10_OCP')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU10_OCP');
      l_occupational_pension :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_Occupational_pension ', l_occupational_pension);
-- *****************************************************************************
--Other Taxable Remunerations
--Taxable remunerations for which social security contributions are not paid.
-- Pick up from the EIT
      l_other_tax_rem := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU10_OTR) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU10_OTR')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU10_OTR');
      l_other_tax_rem :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );

-- Changes EOY 2008/2009
-- Persons born 1937 or earlier do not pay Special Income tax or Social security contribution,
-- and should therefore be included in field 31.
-- Salary for persons born 1937 or earlier should be reported in field 31
	IF l_date_of_birth < to_date('01-01-1938','DD-MM-YYYY')
        THEN
	l_other_tax_rem := l_other_tax_rem + l_gross_salary;

        END IF ;
-- End changes 2008/2009
      --logger ('l_other_tax_rem ', l_other_tax_rem);
-- *****************************************************************************
--Other Taxable Remunerations
--Taxable remunerations for which social security contributions are not paid
-- and which are not entitled to Special Job Deduction
-- Pick up from the EIT
      l_tax_rem_without_sjd := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU10_OTRSJD) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU10_OTRSJD')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU10_OTRSJD');
      l_tax_rem_without_sjd :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );

-- Changes EOY 2008/2009
-- Special job deductions is no longer in use for persons born 1937 or earliser
	IF l_date_of_birth < to_date('01-01-1938','DD-MM-YYYY')
        THEN
        l_tax_rem_without_sjd := 0 ;
        END IF ;
      --logger ('l_tax_rem_without_sjd ', l_tax_rem_without_sjd);
-- *****************************************************************************
-- *****************************************************************************
--Benefits As Pension
--If Benefit is Given As Pension the box will be ticked
-- Pick up from the EIT
-- Check Box
      l_benefit_as_pension := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU10_BENPEN) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU10_BENPEN')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU10_BENPEN');
      l_benefit_as_pension :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
	IF l_benefit_as_pension > 0
      THEN
         l_benefit_as_pension_flag := 'Y';
      ELSE
         l_benefit_as_pension_flag := 'N';
      END IF;

      --logger ('l_benefit_as_pension ', l_benefit_as_pension);
      --logger ('l_benefit_as_pension_flag', l_benefit_as_pension_flag);
      -- *****************************************************************************
--Taxable remunerations for which the employee pays social security contributions.
-- Pick up from the EIT
      l_tax_rem_paid := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU10_TRSSC) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                 ('KU10_TRSSC')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code
                                                                 ('KU10_TRSSC');
      l_tax_rem_paid :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
--                 ,'999999999D99'
                 );
      --logger ('l_tax_rem_paid ', l_tax_rem_paid);
-- *****************************************************************************

      --Not taxable remunerations to foreign key persons working in Sweden
-- Pick up from the EIT
      l_not_tax_rem := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU10_NTR) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU10_NTR')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU10_NTR');
      l_not_tax_rem :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_not_tax_rem ', l_not_tax_rem);
-- *****************************************************************************
-- Certain deductions
-- Pick up from the EIT
      l_certain_deductions := 0;
      --logger          ('each_field_value ().FIELD_CODE(KU10_CD) '          ,each_field_value (l_legal_employer_id_fetched).field_code                                                                    ('KU10_CD')          );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU10_CD');
      l_certain_deductions :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_Certain_deductions ', l_certain_deductions);
-- *****************************************************************************
-- Rent
-- Pick up from the EIT
      l_rent := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU10_RENT) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                  ('KU10_RENT')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code
                                                                  ('KU10_RENT');
      l_rent :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_rent ', l_rent);

-- *****************************************************************************
--
-- *****************************************************************************
--
-- EOY Changes 2008/2009
--
-- Basis for Tax Reduction for Household Services
-- Pick up from the EIT
      l_tax_red_house_ku10 := 0;
      --logger ('each_field_value ().FIELD_CODE(KU10_TRHS) ',each_field_value (l_legal_employer_id_fetched).field_code('KU10_TRHS'));
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code('KU10_TRHS');
      l_tax_red_house_ku10 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_tax_red_house_ku10 ', l_tax_red_house_ku10);
-- *****************************************************************************
-- EOY Changes 2009/2010
-- Basis for Tax Reduction for ROT Work
-- Pick up from the EIT
      l_tax_red_rot_ku10 := 0;
      --logger ('each_field_value ().FIELD_CODE(KU10_TRHS) ',each_field_value (l_legal_employer_id_fetched).field_code('KU10_TRHS'));
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code('KU10_TRROT');
      l_tax_red_rot_ku10 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
 logger ('l_tax_red_rot_ku10 ', l_tax_red_rot_ku10);

-- *****************************************************************************
-- Work site number allocated by the Central Bureau of Statistics (SCB)
-- Swedish Local Unit Details EIT  CFAR Number
-- If a person is terminated during the year or have changed Local Unit,
-- enter the last Local Unit number used for that employee.

      -- Note: Local Unit of the Primary Assignment
      OPEN csr_local_unit_details (l_primary_local_unit_id);

      FETCH csr_local_unit_details
       INTO lr_local_unit_details;

      CLOSE csr_local_unit_details;

      l_work_site_number := lr_local_unit_details.org_information2;
      --logger ('l_work_site_number ', l_work_site_number);
-- *****************************************************************************
-- Free housing 1- or 2-family house
-- Check Box,
-- if Element "Accommodation Benefit" contains value during the reporting Year.
      l_temp :=
--         TO_CHAR
              round(get_defined_balance_value ('ACCOMMODATION_BENEFIT_PER_LE_YTD'
                                         ,l_assignment_id
                                         ,g_income_end_date
                                         ,l_legal_employer_id_fetched
                                         ,NULL
                                         )
  --            ,'999999999D99'
              );
	--logger ('ACCOMMODATION_BENEFIT_PER_LE_YTD ', l_temp);

      IF l_temp > 0
      THEN
         l_free_housing := 'Y';
      ELSE
         l_free_housing := 'N';
      END IF;

      --logger ('l_free_housing ', l_free_housing);
-- *****************************************************************************
-- Free meals
-- Check Box,
-- if Element "Food Benefit" contains value during the reporting Year.
      l_temp :=
--         TO_CHAR
round(get_defined_balance_value ('FOOD_BENEFIT_PER_LE_YTD'
                                            ,l_assignment_id
                                            ,g_income_end_date
                                            ,l_legal_employer_id_fetched
                                            ,NULL
                                            )
  --               ,'999999999D99'
                 );
      --logger ('FOOD_BENEFIT_PER_LE_YTD ', l_temp);

      IF l_temp > 0
      THEN
         l_free_meals := 'Y';
      ELSE
         l_free_meals := 'N';
      END IF;

      --logger ('l_free_meals ', l_free_meals);
-- *****************************************************************************
-- Free housing, other than code 41
-- Check Box,
-- if "User Defined" Element (To be identified using the Element:
-- Further Information Details, Benefit Type value matches "Free Housing")
-- contains value during the reporting Year.
      l_free_housing_other41 := l_free_housing_other41_flag;
      --logger ('l_free_housing_other41 ', l_free_housing_other41);
-- *****************************************************************************
-- Interest
-- Check Box,
-- "User Defined" Element  (To be identified using the Element:
-- Further Information Details, Benefit Type value matches "Interest")
-- contains value during the reporting Year.
      l_interest := l_interest_flag;
      --logger ('l_interest ', l_interest);
-- *****************************************************************************
-- Other benefits
-- Check Box,
-- "User Defined" Element  (To be identified using the Element:
-- Further Information Details, Benefit Type value matches "Other Benefits")
-- contains value during the reporting Year.
      l_other_benefits := l_other_benefits_flag;
      --logger ('l_Other_benefits ', l_other_benefits);
-- *****************************************************************************
--Benefit has been adjusted
-- Check Box,
-- if "Reducement Value"
-- exists in Elements Car OR Food OR Accommodation Benefit Elements.
      l_temp :=
--         TO_CHAR
            round(get_defined_balance_value ('BENEFIT_IN_KIND_ADJUSTED_PER_LE_YTD'
                                       ,l_assignment_id
                                       ,g_income_end_date
                                       ,l_legal_employer_id_fetched
                                       ,NULL
                                       )
  --          ,'999999999D99'
            );
      --logger ('BENEFIT_IN_KIND_ADJUSTED_PER_LE_YTD ', l_temp);

      IF l_temp > 0
      THEN
         l_benefit_adjusted := 'Y';
      ELSE
         l_benefit_adjusted := 'N';
      END IF;

      --logger ('l_benefit_adjusted ', l_benefit_adjusted);


-- *****************************************************************************
--Mileage allowance
-- Check Box,
-- if Element "Mileage" contains "Cumulative Distance" value
-- AND
--  if "Mileage Employee" is NOT created for that period.
      l_temp :=
--         TO_CHAR
round(get_defined_balance_value ('MILEAGE_EMPLOYEE_PER_LE_YTD'
                                            ,l_assignment_id
                                            ,g_income_end_date
                                            ,l_legal_employer_id_fetched
                                            ,NULL
                                            )
  --               ,'999999999D99'
                 );
      --logger ('MILEAGE_EMPLOYEE_PER_LE_YTD ', l_temp);

      IF l_number_of_kilometers > 0 AND l_temp = 0
      THEN
         l_mileage_allowance := 'Y';
      ELSE
         l_mileage_allowance := 'N';
      END IF;

      --logger ('l_Mileage_allowance ', l_mileage_allowance);
-- *****************************************************************************

      -- Per diem, Sweden
-- Check Box,
-- if Element "Per Diem Sweden" contains  "Number of Days upto 3 Months" value
-- AND
-- if "Per Diem Sweden Employee" is NOT created for that period.
      l_temp_balance_value :=
--         TO_CHAR
            round(get_defined_balance_value
                             ('PER_DIEM_SWEDEN_DAYS_UPTO_3_MONTHS_PER_LE_YTD'
                             ,l_assignment_id
                             ,g_income_end_date
                             ,l_legal_employer_id_fetched
                             ,NULL
                             )
  --          ,'999999999D99'
            );
      --logger ('PER_DIEM_SWEDEN_DAYS_UPTO_3_MONTHS_PER_LE_YTD '             ,l_temp_balance_value             );
      l_temp :=
--         TO_CHAR
           round(get_defined_balance_value ('PER_DIEM_SWEDEN_EMPLOYEE_PER_LE_YTD'
                                       ,l_assignment_id
                                       ,g_income_end_date
                                       ,l_legal_employer_id_fetched
                                       ,NULL
                                       )
--            ,'999999999D99'
            );
      --logger ('PER_DIEM_SWEDEN_EMPLOYEE_PER_LE_YTD ', l_temp);

      IF l_temp_balance_value > 0 AND l_temp = 0
      THEN
         l_per_diem_sweden := 'Y';
      ELSE
         l_per_diem_sweden := 'N';
      END IF;

      --logger ('l_Per_diem_Sweden ', l_per_diem_sweden);
-- *****************************************************************************
-- Per diem, other countries
-- Check Box,
-- if Element "Per Diem Other Countries" contains "Number of Days upto 3 Months" value
-- AND
-- if "Per Diem Other Countries Employee" is NOT created for that period
      l_temp_balance_value :=
--         TO_CHAR
            round(get_defined_balance_value
                    ('PER_DIEM_OTHER_COUNTRIES_DAYS_UPTO_3_MONTHS_PER_LE_YTD'
                    ,l_assignment_id
                    ,g_income_end_date
                    ,l_legal_employer_id_fetched
                    ,NULL
                    )
  --          ,'999999999D99'
            );
      --logger ('PER_DIEM_OTHER_COUNTRIES_DAYS_UPTO_3_MONTHS_PER_LE_YTD '             ,l_temp_balance_value             );
      l_temp :=
--         TO_CHAR
            round(get_defined_balance_value
                              ('PER_DIEM_OTHER_COUNTRIES_EMPLOYEE_PER_LE_YTD'
                              ,l_assignment_id
                              ,g_income_end_date
                              ,l_legal_employer_id_fetched
                              ,NULL
                              )
  --          ,'999999999D99'
            );
      --logger ('PER_DIEM_OTHER_COUNTRIES_EMPLOYEE_PER_LE_YTD ', l_temp);

      IF l_temp_balance_value > 0 AND l_temp = 0
      THEN
         l_per_diem_other := 'Y';
      ELSE
         l_per_diem_other := 'N';
      END IF;

      --logger ('l_Per_diem_other ', l_per_diem_other);
-- *****************************************************************************
--  Within Sweden
-- Check Box,
-- if Element "Per Diem Sweden" contains  "Number of Days above 3 Months" value.
      l_temp :=
--         TO_CHAR
            round(get_defined_balance_value
                            ('PER_DIEM_SWEDEN_DAYS_ABOVE_3_MONTHS_PER_LE_YTD'
                            ,l_assignment_id
                            ,g_income_end_date
                            ,l_legal_employer_id_fetched
                            ,NULL
                            )
  --          ,'999999999D99'
            );
      --logger ('PER_DIEM_SWEDEN_DAYS_ABOVE_3_MONTHS_PER_LE_YTD ', l_temp);

      IF l_temp > 0
      THEN
         l_within_sweden := 'Y';
      ELSE
         l_within_sweden := 'N';
      END IF;

      --logger ('l_Within_Sweden ', l_within_sweden);
-- *****************************************************************************
--Other countries
-- Check Box,
-- if Element "Per Diem Other Countries" contains "Number of Days above 3 Months" value.
      l_temp :=
--         TO_CHAR
            round(get_defined_balance_value
                   ('PER_DIEM_OTHER_COUNTRIES_DAYS_ABOVE_3_MONTHS_PER_LE_YTD'
                   ,l_assignment_id
                   ,g_income_end_date
                   ,l_legal_employer_id_fetched
                   ,NULL
                   )
--            ,'999999999D99'
            );
      --logger ('PER_DIEM_OTHER_COUNTRIES_DAYS_ABOVE_3_MONTHS_PER_LE_YTD '             ,l_temp             );

      IF l_temp > 0
      THEN
         l_other_countries := 'Y';
      ELSE
         l_other_countries := 'N';
      END IF;

      --logger ('l_Other_countries ', l_other_countries);
-- *****************************************************************************
-- Business travel expenses
-- Check Box,
-- if "User Defined" Element  (To be identified using the Element:
-- Further Information Details, Expense Type value matches "Business Travel Expense")
-- contains value during the reporting Year.
      l_business_travel_expenses := l_busi_travel_expenses_flag;
      --logger ('l_Business_travel_expenses ', l_business_travel_expenses);
-- *****************************************************************************

      -- Accomodation, business travels
-- Check Box,
-- if "User Defined" Element  (To be identified using the Element:
-- Further Information Details, Expense Type value matches "Accomodation Business Travel")
-- contains value during the reporting Year.
      l_acc_business_travels := l_acc_business_travels_flag;
      --logger ('l_Acc_business_travels ', l_acc_business_travels);
-- *****************************************************************************
      lr_person_inc_stmt_spec := NULL;

      OPEN csr_person_inc_stmt_spec (l_person_id, 'SE_INC_STMT_SPEC_DETAILS');

      FETCH csr_person_inc_stmt_spec
       INTO lr_person_inc_stmt_spec;

      CLOSE csr_person_inc_stmt_spec;

-- *****************************************************************************
-- Other benefits
-- Person Form: Extra Information (Income Statement Specification Details)
      l_other_benefits_up65 := lr_person_inc_stmt_spec.pei_information1;
      --logger ('l_Other_benefits_UP65 ', l_other_benefits_up65);
-- *****************************************************************************
--Compensation for expenses
-- Person Form: Extra Information (Income Statement Specification Details)
      l_compe_for_expenses_up66 := lr_person_inc_stmt_spec.pei_information2;
      --logger ('l_Compe_for_expenses_UP66 ', l_compe_for_expenses_up66);
-- *****************************************************************************
-- Taxable remunerations for which the employee pays social security contributions
-- Person Form: Extra Information (Income Statement Specification Details)
      l_tax_rem_paid_up67 := lr_person_inc_stmt_spec.pei_information3;
      --logger ('l_tax_rem_paid_UP67 ', l_tax_rem_paid_up67);
-- *****************************************************************************
-- Taxable remunerations for which social security contributions are not paid.
-- Person Form: Extra Information (Income Statement Specification Details)
      l_other_tax_rem_up68 := lr_person_inc_stmt_spec.pei_information4;
-- Changes 2008/2009
-- Persons born 1937 or earlier do not pay Special Income tax or Social
-- security contribution, and should therefore be included in field 31.
-- Date of Birth of the person is to be reported in the Filed 68, for person
-- born 1937 or earlier.
     If l_date_of_birth < to_date('01-01-1938','DD-MM-YYYY') AND l_other_tax_rem_up68 IS NULL
     THEN
     l_other_tax_rem_up68 := l_date_of_birth;

     END IF;
      --logger ('l_other_tax_rem_UP68 ', l_other_tax_rem_up68);
-- *****************************************************************************
-- Taxable remunerations for which social security contributions are not paid
-- and which are not entitled to Special Job Deduction
-- Person Form: Extra Information (Income Statement Specification Details)
      l_tax_rem_without_sjd_up69 := lr_person_inc_stmt_spec.pei_information6;
      --logger ('l_tax_rem_without_sjd_UP69 ', l_tax_rem_without_sjd_up69);
-- *****************************************************************************
-- Certain deductions
-- Person Form: Extra Information (Income Statement Specification Details)
      l_certain_deductions_up70 := lr_person_inc_stmt_spec.pei_information5;
      --logger ('l_Certain_deductions_UP70 ', l_certain_deductions_up70);
-- *****************************************************************************
-- *****************************************************************************
-- *****************************************************************************
      lr_person_inc_stmt_spec := NULL;

      OPEN csr_person_inc_stmt_spec (l_person_id
                                    ,'SE_INC_STMT_DATA_CORRECTION'
                                    );

      FETCH csr_person_inc_stmt_spec
       INTO lr_person_inc_stmt_spec;

      CLOSE csr_person_inc_stmt_spec;

      l_statement_type :=
         hr_general.decode_lookup ('SE_INCOME_STATEMENT_TYPE'
                                  ,lr_person_inc_stmt_spec.pei_information1
                                  );
      l_correction_date := lr_person_inc_stmt_spec.pei_information2;
      l_tax_country_code := lr_person_inc_stmt_spec.pei_information4;
      l_tax_country_meaning := get_country(lr_person_inc_stmt_spec.pei_information4);
      l_ftin := lr_person_inc_stmt_spec.pei_information5;
      l_work_country_meaning := get_country(lr_person_inc_stmt_spec.pei_information7);
      l_work_country_code := lr_person_inc_stmt_spec.pei_information7;
      l_work_period := lr_person_inc_stmt_spec.pei_information8;
--      l_WOrk_period_meaning := hr_general.decode_lookup ('SE_INCOME_WORK_PERIOD',lr_Person_inc_stmt_spec.PEI_INFORMATION6);
      --logger ('l_statement_type ', l_statement_type);
      --logger ('l_correction_date ', l_correction_date);
      --logger ('l_tax_country_code ', l_tax_country_code);
      --logger ('l_tax_country_meaning ', l_tax_country_meaning);
      --logger ('l_FTIN ', l_ftin);
      --logger ('l_work_country_meaning ', l_work_country_meaning);
      --logger ('l_work_country_code ', l_work_country_code);
--      logger ('l_WOrk_period meaning', l_WOrk_period_meaning);
      --logger ('l_WOrk_period_code', l_work_period);
      lr_person_inc_stmt_spec := NULL;

      OPEN csr_person_inc_stmt_spec (l_person_id, 'SE_INC_STMT_KU14_SPECIAL');

      FETCH csr_person_inc_stmt_spec
       INTO lr_person_inc_stmt_spec;

      CLOSE csr_person_inc_stmt_spec;

l_emp_regulation_category_code := lr_person_inc_stmt_spec.pei_information1;
      l_emp_regulation_category :=
         hr_general.decode_lookup ('SE_EMPLOYER_REGULATION'
                                  ,lr_person_inc_stmt_spec.pei_information1
                                  );
      l_article_details := lr_person_inc_stmt_spec.pei_information2;
      --logger ('l_emp_regulation_category ', l_emp_regulation_category);
      --logger ('l_article_details ', l_article_details);
-- *****************************************************************************
-- Occupational pension ku 13
-- Pick up from the EIT
      --logger         ('each_field_value ().FIELD_CODE(KU13_OCP) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU13_OCP')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU13_OCP');
      l_occupational_pension_ku13 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_Occupational_pension_ku13 ', l_occupational_pension_ku13);
-- *****************************************************************************
-- *****************************************************************************
-- Compensation for benefit ku 13
-- Pick up from the EIT
      --logger         ('each_field_value ().FIELD_CODE(KU13_CFBHT) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                 ('KU13_CFBHT')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code
                                                                 ('KU13_CFBHT');
      l_compen_for_benefit_ku13 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_compen_for_benefit_ku13 ', l_compen_for_benefit_ku13);
-- *****************************************************************************

      -- *****************************************************************************
-- Taxable remunerations for social security contributions (KU13)
-- Pick up from the EIT
      --logger         ('each_field_value ().FIELD_CODE(KU13_TRSSC) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                 ('KU13_TRSSC')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code
                                                                 ('KU13_TRSSC');
      l_tax_rem_ssc_ku13 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );

      --logger ('l_tax_rem_ssc_ku13 ', l_tax_rem_ssc_ku13);
-- *****************************************************************************

      -- *****************************************************************************
-- Taxable remunerations for social security contributions (KU13) are paid
-- Pick up from the EIT
      --logger         ('each_field_value ().FIELD_CODE(KU14_TRSSC) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                 ('KU14_TRSSC')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code
                                                                 ('KU14_TRSSC');
      l_tax_rem_ssc_ku14 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
--                 ,'999999999D99'
                 );
      --logger ('l_tax_rem_ssc_ku14 ', l_tax_rem_ssc_ku14);
-- *****************************************************************************
-- Changes EOY 2008/2009
-- *****************************************************************************
--Other Taxable Remunerations KU 13
-- Taxable remunerations for which social security contributions are not paid

      -- Pick up from the EIT
      l_other_tax_rem_ku13 := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU13_OTR) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU14_OTR')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU13_OTR');
      l_other_tax_rem_ku13 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );

 -- Changes EOY 2008/2009
-- Persons born 1937 or earlier do not pay Special Income tax or Social security contribution,
-- and should therefore be included in field 31.
-- Salary for persons born 1937 or earlier should be reported in field 31
	IF l_date_of_birth < to_date('01-01-1938','DD-MM-YYYY')
        THEN
	l_other_tax_rem_ku13 := l_other_tax_rem_ku13 + l_gross_salary;

        END IF ;
-- End changes 2008/2009
      --logger ('l_other_tax_rem_ku13 ', l_other_tax_rem_ku13);

      -- *****************************************************************************
-- Occupational pension ku 14
-- Pick up from the EIT
      --logger         ('each_field_value ().FIELD_CODE(KU14_OCP) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU14_OCP')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU14_OCP');
      l_occupational_pension_ku14 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
--                 ,'999999999D99'
                 );
      --logger ('l_Occupational_pension_ku14 ', l_occupational_pension_ku14);
-- *****************************************************************************
-- *****************************************************************************

      --Not taxable remunerations ku 14
-- Pick up from the EIT
      l_not_tax_rem_ku14 := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU14_NTR) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU14_NTR')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU14_NTR');
      l_not_tax_rem_ku14 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_not_tax_rem_ku14 ', l_not_tax_rem_ku14);
-- *****************************************************************************
-- *****************************************************************************
--Other Taxable Remunerations KU 14

      -- Pick up from the EIT
      l_other_tax_rem_ku14 := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU14_OTR) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU14_OTR')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU14_OTR');
      l_other_tax_rem_ku14 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );

 -- Changes EOY 2008/2009
-- Persons born 1937 or earlier do not pay Special Income tax or Social security contribution,
-- and should therefore be included in field 31.
-- Salary for persons born 1937 or earlier should be reported in field 31
	IF l_date_of_birth < to_date('01-01-1938','DD-MM-YYYY')
        THEN
	l_other_tax_rem_ku14 := l_other_tax_rem_ku14 + l_gross_salary;

        END IF ;
-- End changes 2008/2009
      --logger ('l_other_tax_rem_ku14 ', l_other_tax_rem_ku14);
-- *****************************************************************************
-- Compensation for expenses not ticked in boxes at codes 50-56
-- Pick up from the EIT KU 14

      --l_compensation_for_expenses := 0 ;
      --logger ('l_legal_employer_id_fetched ', l_legal_employer_id_fetched);
      --logger         ('each_field_value ().FIELD_CODE(KU14_CFE) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU14_CFE')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU14_CFE');
      l_compe_for_expenses_ku14 :=
--         TO_CHAR
round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_compe_for_expenses_ku14 ', l_compe_for_expenses_ku14);
-- *****************************************************************************
-- *****************************************************************************
--
-- EOY Changes 2008/2009
--
-- Basis for Tax Reduction for Household services
-- Pick up from the EIT KU 14

      l_tax_red_house_ku14 := 0 ;
      --logger ('l_legal_employer_id_fetched ', l_legal_employer_id_fetched);
      --logger         ('each_field_value ().FIELD_CODE(KU14_TRHS) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU14_TRHS')         );
      l_temp := each_field_value (l_legal_employer_id_fetched).field_code ('KU14_TRHS');
      l_tax_red_house_ku14 :=round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
      --logger ('l_tax_red_house_ku14 ', l_tax_red_house_ku14);
-- *****************************************************************************
-- EOY Changes 2009/2010
-- Basis for Tax Reduction for ROT Work
-- Pick up from the EIT KU 14

      l_tax_red_rot_ku14 := 0 ;
      l_temp := each_field_value (l_legal_employer_id_fetched).field_code ('KU14_TRROT');
      l_tax_red_rot_ku14 :=round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
  --               ,'999999999D99'
                 );
  logger ('l_tax_red_rot_ku14 ', l_tax_red_rot_ku14);
-- *****************************************************************************
-- Changes EOY 2008/2009
-- Benefits As Pension
-- Pick Up from EIT KU14
 l_benefit_pen_ku14 := 0;
      --logger         ('each_field_value ().FIELD_CODE(KU10_BENPEN) '         ,each_field_value (l_legal_employer_id_fetched).field_code                                                                   ('KU10_BENPEN')         );
      l_temp :=
         each_field_value (l_legal_employer_id_fetched).field_code ('KU14_BENPEN');
      l_benefit_pen_ku14 := round(get_balance_value (l_temp
                                    ,l_assignment_id
                                    ,g_income_end_date
                                    ,l_legal_employer_id_fetched
                                    ,NULL
                                    )
--              ,'999999999D99'
                                );
--logger ('l_benefit_pen_ku14  ', l_benefit_pen_ku14);
    IF l_benefit_pen_ku14 > 0
      THEN
         l_benefit_pen_flag_KU14 := 'Y';
      ELSE
         l_benefit_pen_flag_KU14 := 'N';
      END IF;

-- End Changes 2008/2009

-- **********************************************************************************

      -- *****************************************************************************
      --logger ('###############PERSON ENDED##############======== ', '=');

      -- End of Pickingup the Data
      BEGIN
/*
         SELECT 1
           INTO l_flag
           FROM pay_action_information
          WHERE action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEINSA'
            AND action_context_id = p_assignment_action_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
*/
         --logger ('g_payroll_action_id', g_payroll_action_id);
         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_assignment_action_id
            ,p_action_context_type              => 'AAP'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => l_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEINSA'
            ,p_action_information2              => 'PERSON'
            ,p_action_information3              => g_payroll_action_id
            ,p_action_information4              => l_statement_type
            ,p_action_information5              => l_employee_number
            ,p_action_information6              => l_employee_pin
            ,p_action_information7              => l_employee_last_name
            ,p_action_information8              => NULL
            ,p_action_information9              => NULL
            ,p_action_information10             => NULL
            ,p_action_information11             => NULL
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
            ,p_action_information29             => l_legal_employer_id_fetched
            ,p_action_information30             => l_person_id
            ,p_assignment_id                    => l_assignment_id
            );
         --logger ('l_action_info_id', l_action_info_id);

         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_assignment_action_id
            ,p_action_context_type              => 'AAP'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => l_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEINSA'
            ,p_action_information2              => 'PERSON1'
            ,p_action_information3              => g_payroll_action_id
            ,p_action_information4              => NVL (l_statement_type
                                                       ,'KU10'
                                                       )
            ,p_action_information5              => l_month_from
            ,p_action_information6              => l_month_to
            ,p_action_information7              => l_employee_pin
            ,p_action_information8              => l_employee_name
            ,p_action_information9              => l_correction_date
            ,p_action_information10             => l_work_site_number
            ,p_action_information11             => fnd_number.number_to_canonical
                                                             (l_a_tax_withheld)
            ,p_action_information12             => fnd_number.number_to_canonical
                                                               (l_gross_salary)
            ,p_action_information13             => fnd_number.number_to_canonical
                                                      (l_tb_exclusive_car_fuel)
            ,p_action_information14             => l_free_housing
            ,p_action_information15             => l_free_meals
            ,p_action_information16             => l_free_housing_other41
            ,p_action_information17             => l_interest
            ,p_action_information18             => l_other_benefits
            ,p_action_information19             => l_benefit_adjusted
            ,p_action_information20             => l_tb_exclusive_fuel
            ,p_action_information21             => l_rsv_code
            ,p_action_information22             => l_number_of_months_car
            ,p_action_information23             => l_number_of_kilometers
            ,p_action_information24             => l_emp_payment_car
            ,p_action_information25             => l_free_fuel_car
            ,p_action_information26             => l_employees_address
            ,p_action_information27             => l_employees_postalcode
            ,p_action_information28             => l_employee_postal_address
            ,p_action_information29             => l_legal_employer_id_fetched
            ,p_action_information30             => l_person_id
            ,p_assignment_id                    => l_assignment_id
            );
         --logger ('l_action_info_id', l_action_info_id);
         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_assignment_action_id
            ,p_action_context_type              => 'AAP'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => l_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEINSA'
            ,p_action_information2              => 'PERSON2'
            ,p_action_information3              => g_payroll_action_id
            ,p_action_information4              => fnd_number.number_to_canonical
                                                      (l_compensation_for_expenses
                                                      )
            ,p_action_information5              => l_mileage_allowance
            ,p_action_information6              => l_per_diem_sweden
            ,p_action_information7              => l_per_diem_other
            ,p_action_information8              => l_busi_travel_expenses_flag
            ,p_action_information9              => l_acc_business_travels_flag
            ,p_action_information10             => l_within_sweden
            ,p_action_information11             => l_other_countries
            ,p_action_information12             => fnd_number.number_to_canonical
                                                       (l_occupational_pension)
            ,p_action_information13             => fnd_number.number_to_canonical
                                                              (l_other_tax_rem)
            ,p_action_information14             => fnd_number.number_to_canonical
                                                               (l_tax_rem_paid)
            ,p_action_information15             => fnd_number.number_to_canonical
                                                         (l_certain_deductions)
            ,p_action_information16             => l_other_benefits_up65
            ,p_action_information17             => l_compe_for_expenses_up66
            ,p_action_information18             => l_tax_rem_paid_up67
            ,p_action_information19             => l_other_tax_rem_up68
            ,p_action_information20             => l_certain_deductions_up70
            ,p_action_information21             => fnd_number.number_to_canonical
                                                                (l_not_tax_rem)
            ,p_action_information22             => fnd_number.number_to_canonical
                                                                       (l_rent)
            ,p_action_information23             => fnd_number.number_to_canonical
                                                              (l_tax_rem_without_sjd) -- EOY 2008
            ,p_action_information24             =>l_tax_rem_without_sjd_up69           --EOY 2008
            ,p_action_information25             => l_benefit_as_pension_flag          --EOY 2008
            ,p_action_information26             => fnd_number.number_to_canonical
                                                                       (l_tax_red_house_ku10) -- EOY 2008/2009
            ,p_action_information27             => fnd_number.number_to_canonical
                                                                    (l_tax_red_rot_ku10) -- EOY 2009/2010
            ,p_action_information28             => NULL
            ,p_action_information29             => NULL
            ,p_action_information30             => l_person_id
            ,p_assignment_id                    => l_assignment_id
            );
         --logger ('l_action_info_id', l_action_info_id);
         pay_action_information_api.create_action_information
            (p_action_information_id            => l_action_info_id
            ,p_action_context_id                => p_assignment_action_id
            ,p_action_context_type              => 'AAP'
            ,p_object_version_number            => l_ovn
            ,p_effective_date                   => l_effective_date
            ,p_source_id                        => NULL
            ,p_source_text                      => NULL
            ,p_action_information_category      => 'EMEA REPORT INFORMATION'
            ,p_action_information1              => 'PYSEINSA'
            ,p_action_information2              => 'PERSON3'
            ,p_action_information3              => g_payroll_action_id
            ,p_action_information4              => l_ftin
            ,p_action_information5              => l_tax_country_code
            ,p_action_information6              => fnd_number.number_to_canonical
                                                      (l_occupational_pension_ku13
                                                      )
            ,p_action_information7              => fnd_number.number_to_canonical
                                                           (l_tax_rem_ssc_ku13)
            ,p_action_information8              => fnd_number.number_to_canonical
                                                      (l_compen_for_benefit_ku13
                                                      )
            ,p_action_information9              => l_work_country_code
            ,p_action_information10             => l_in_plain_writing_code
            ,p_action_information11             => fnd_number.number_to_canonical
                                                      (l_occupational_pension_ku14
                                                      )
            ,p_action_information12             => fnd_number.number_to_canonical
                                                         (l_other_tax_rem_ku14)
            ,p_action_information13             => fnd_number.number_to_canonical
                                                           (l_tax_rem_ssc_ku14)
            ,p_action_information14             => fnd_number.number_to_canonical
                                                           (l_not_tax_rem_ku14)
            ,p_action_information15             => l_work_period
            ,p_action_information16             => l_emp_regulation_category
            ,p_action_information17             => l_article_details
            ,p_action_information18             => l_work_country_meaning
            ,p_action_information19             => l_in_plain_writing_meaning
            ,p_action_information20             => l_tax_country_meaning
            ,p_action_information21             => fnd_number.number_to_canonical
                                                      (l_compe_for_expenses_ku14
                                                      )
            ,p_action_information22             => l_emp_regulation_category_code
            ,p_action_information23             => fnd_number.number_to_canonical
                                                      (l_tax_red_house_ku14)    -- EOY 2008/2009
            ,p_action_information24             => l_benefit_pen_flag_KU14 --EOY 2008/2009
            ,p_action_information25             => fnd_number.number_to_canonical(l_other_tax_rem_ku13)   -- EOY 2008/2009
            ,p_action_information26             => fnd_number.number_to_canonical
                                                      (l_tax_red_rot_ku14) --EOY 2009/2010
            ,p_action_information27             => NULL
            ,p_action_information28             => NULL
            ,p_action_information29             => NULL
            ,p_action_information30             => l_person_id
            ,p_assignment_id                    => l_assignment_id
            );
         --logger ('l_action_info_id', l_action_info_id);
--logger('l_action_info_id',l_action_info_id);

      /*         WHEN OTHERS
         THEN
            NULL;
*/
      END;

      --logger ('ARCHIVE_CODE '             ,'::::::::::::::::::::::::::::::::::::::::Ended');
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
      l_str1 :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT><INSR>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</INSR></ROOT>';
      l_str7 :=
            '<?xml version="1.0" encoding="'
         || l_iana_charset
         || '"?> <ROOT></ROOT>';
      l_str10 := '<INSR>';
      l_str11 := '</INSR>';
      DBMS_LOB.createtemporary (l_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (l_xfdf_string, DBMS_LOB.lob_readwrite);
      current_index := 0;

      IF gins_data.COUNT > 0
      THEN
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);

         FOR table_counter IN gins_data.FIRST .. gins_data.LAST
         LOOP
            l_str8 := gins_data (table_counter).tagname;
            l_str9 := gins_data (table_counter).tagvalue;

            IF l_str9 IN
                  ('LEGAL_EMPLOYER'
                  ,'LE_DETAILS'
                  ,'EMPLOYEES'
                  ,'PERSON'
                  ,'LE_DETAILS_END'
                  ,'PERSON_END'
                  ,'EMPLOYEES_END'
                  ,'LEGAL_EMPLOYER_END'
                  ,'INCOME_STATEMENT_END'
                  ,'INCOME_STATEMENT'
                  ,'INFO_KU_END'
                  ,'INFO_KU'
                  ,'KU10_PERSON_END'
                  ,'KU13_PERSON_END'
                  ,'KU14_PERSON_END'
                  ,'KU10_PERSON'
                  ,'KU13_PERSON'
                  ,'KU14_PERSON'
                  ,'LE_ADDRESS_END'
                  ,'LE_ADDRESS'
                  )
            THEN
               IF l_str9 IN
                     ('LEGAL_EMPLOYER'
                     ,'LE_DETAILS'
                     ,'EMPLOYEES'
                     ,'PERSON'
                     ,'INCOME_STATEMENT'
                     ,'INFO_KU'
                     ,'KU10_PERSON'
                     ,'KU13_PERSON'
                     ,'KU14_PERSON'
                     ,'LE_ADDRESS'
                     )
               THEN
                  DBMS_LOB.writeappend (l_xfdf_string
                                       ,LENGTH (l_str2)
                                       ,l_str2
                                       );
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8)
                                       ,l_str8);
                  DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3)
                                       ,l_str3);
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
      l_counter             NUMBER                                       := 0;
      l_payroll_action_id   pay_action_information.action_information1%TYPE;

--Cursors needed for report
      CURSOR csr_all_legal_employer (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT *
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEINSA'
            AND action_information2 = 'LE';

      CURSOR csr_media_provider (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT *
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT INFORMATION'
            AND action_information1 = 'PYSEINSA'
            AND action_information2 = 'MP';

      lr_media_provider     csr_media_provider%ROWTYPE;

      CURSOR csr_report_details (
         csr_v_pa_id                         pay_action_information.action_context_id%TYPE
      )
      IS
         SELECT *
           FROM pay_action_information
          WHERE action_context_type = 'PA'
            AND action_context_id = csr_v_pa_id
            AND action_information_category = 'EMEA REPORT DETAILS'
            AND action_information1 = 'PYSEINSA';

      lr_report_details     csr_report_details%ROWTYPE;

      CURSOR csr_all_employees_under_le (
         csr_v_pa_id                         pay_action_information.action_information3%TYPE
        ,csr_v_le_id                         pay_action_information.action_information15%TYPE
        ,csr_v_stmt_type                     pay_action_information.action_information4%TYPE
        ,csr_v_sort_order                    pay_action_information.action_information4%TYPE
      )
      IS
         SELECT   *
             FROM pay_action_information
            WHERE action_context_type = 'AAP'
              AND action_information_category = 'EMEA REPORT INFORMATION'
              AND action_information1 = 'PYSEINSA'
              AND action_information2 = 'PERSON'
              AND action_information3 = csr_v_pa_id
              AND action_information4 = csr_v_stmt_type
              AND action_information29 = csr_v_le_id
         ORDER BY decode(csr_v_sort_order
         ,'EMPNUM',action_information5
         ,'EMPPIN',action_information6
         ,'EMPLAN',action_information7
         );

      CURSOR csr_get_person (
         csr_v_record                        pay_action_information.action_information3%TYPE
        ,csr_v_pa_id                         pay_action_information.action_information3%TYPE
        ,csr_v_person_id                     pay_action_information.action_information30%TYPE
      )
      IS
         SELECT   *
             FROM pay_action_information
            WHERE action_context_type = 'AAP'
              AND action_information_category = 'EMEA REPORT INFORMATION'
              AND action_information1 = 'PYSEINSA'
              AND action_information2 = csr_v_record
              AND action_information3 = csr_v_pa_id
              AND action_information30 = csr_v_person_id
         ORDER BY action_information30;

      lr_get_person         csr_get_person%ROWTYPE;

/* End of declaration*/
/* Proc to Add the tag value and Name */
      PROCEDURE add_tag_value (p_tag_name IN VARCHAR2, p_tag_value IN VARCHAR2)
      IS
      BEGIN
         gins_data (l_counter).tagname := p_tag_name;
         gins_data (l_counter).tagvalue := p_tag_value;
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
         --logger ('Entered Reporting', ' XML Creation ');
         --logger ('p_payroll_action_id', p_payroll_action_id);

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
         --logger ('SORT by  ', lr_report_details.action_information10);

         --logger ('Before ', ' Csr for Legal ');

         OPEN csr_media_provider (l_payroll_action_id);

         FETCH csr_media_provider
          INTO lr_media_provider;

         CLOSE csr_media_provider;

         --logger ('PRODUCT', lr_media_provider.action_information3);
         --logger ('PERIOD', lr_media_provider.action_information4);
         --logger ('TEST_OR_PRODUCTION', lr_media_provider.action_information5);
         --logger ('ORG_NUMBER', lr_media_provider.action_information6);
         --logger ('MEDIA_PROVIDER_NAME', lr_media_provider.action_information7);
         --logger ('DIVISION', lr_media_provider.action_information8);
         --logger ('CONTACT_PERSON', lr_media_provider.action_information9);
         --logger ('ADDRESS', lr_media_provider.action_information10);
         --logger ('POSTAL_CODE', lr_media_provider.action_information11);
         --logger ('POSTAL_ADDRESS', lr_media_provider.action_information12);
         --logger ('PHONE_NUMBER', lr_media_provider.action_information13);
         --logger ('FAX_NUMBER', lr_media_provider.action_information14);
         --logger ('EMAIL', lr_media_provider.action_information15);
         add_tag_value ('INCOME_STATEMENT', 'INCOME_STATEMENT');
-- Add header for file
         add_tag_value ('SENDER', lr_report_details.action_information11);
         add_tag_value ('RECEIVER', lr_report_details.action_information12);
         add_tag_value ('INFORMATION_TYPE', lr_report_details.action_information13);
-- Add header for file
         add_tag_value ('INFO_KU', 'INFO_KU');
         add_tag_value ('PRODUCT', lr_media_provider.action_information3);
         add_tag_value ('PERIOD', lr_media_provider.action_information4);
         add_tag_value ('TEST_OR_PRODUCTION'
                       ,lr_media_provider.action_information5
                       );
         add_tag_value ('ORG_NUMBER', lr_media_provider.action_information6);
         add_tag_value ('MEDIA_PROVIDER_NAME'
                       ,lr_media_provider.action_information7
                       );
         add_tag_value ('DIVISION', lr_media_provider.action_information8);
         add_tag_value ('CONTACT_PERSON'
                       ,lr_media_provider.action_information9
                       );
         add_tag_value ('ADDRESS', lr_media_provider.action_information10);
         add_tag_value ('POSTAL_CODE', lr_media_provider.action_information11);
         add_tag_value ('POSTAL_ADDRESS'
                       ,lr_media_provider.action_information12
                       );
         add_tag_value ('PHONE_NUMBER'
                       ,lr_media_provider.action_information13);
         add_tag_value ('FAX_NUMBER', lr_media_provider.action_information14);
         add_tag_value ('EMAIL', lr_media_provider.action_information15);
add_tag_value('IDENTITY',lr_Media_provider.action_information16);
add_tag_value('PROGRAM',lr_Media_provider.action_information17);

         add_tag_value ('INFO_KU', 'INFO_KU_END');

         FOR rec_all_le IN csr_all_legal_employer (l_payroll_action_id)
         LOOP
            --logger ('LE_NAME', rec_all_le.action_information4);
            --logger ('LE_ORG_NUM', rec_all_le.action_information5);
            add_tag_value ('LEGAL_EMPLOYER', 'LEGAL_EMPLOYER');
            add_tag_value ('LE_DETAILS', 'LE_DETAILS');
            add_tag_value ('LE_NAME', rec_all_le.action_information4);
            add_tag_value ('LE_ORG_NUM', rec_all_le.action_information5);
            add_tag_value ('LE_ADDRESS', 'LE_ADDRESS');
            add_tag_value ('LOCATION_CODE', rec_all_le.action_information6);
            add_tag_value ('ADDRESS_LINE_1', rec_all_le.action_information7);
            add_tag_value ('ADDRESS_LINE_2', rec_all_le.action_information8);
            add_tag_value ('ADDRESS_LINE_3', rec_all_le.action_information9);
            add_tag_value ('POSTAL_CODE', rec_all_le.action_information10);
            add_tag_value ('TOWN_OR_CITY', rec_all_le.action_information11);
            add_tag_value ('REGION_1', rec_all_le.action_information12);
            add_tag_value ('REGION_2', rec_all_le.action_information13);
            add_tag_value ('TERRITORY_SHORT_NAME'
                          ,rec_all_le.action_information14
                          );
            add_tag_value ('LE_ADDRESS', 'LE_ADDRESS_END');
            add_tag_value ('LE_DETAILS', 'LE_DETAILS_END');
            add_tag_value ('EMPLOYEES', 'EMPLOYEES');
            --logger ('LE_ORG_NUM', rec_all_le.action_information5);
            --logger ('LE ID', rec_all_le.action_information3);
            --logger ('Before Person Query', '^^^^^^^^^^^^^^^^^^^^^');
-- *****************************************************************************
-- FOR KU10
            add_tag_value ('KU10_PERSON', 'KU10_PERSON');

-- *****************************************************************************
            FOR rec_all_emp_under_le IN
               csr_all_employees_under_le (l_payroll_action_id
                                          ,rec_all_le.action_information3
                                          ,'KU10'
                                          ,lr_report_details.action_information10
                                          )
            LOOP
               add_tag_value ('PERSON', 'PERSON');
               add_tag_value ('TYPE', 'KU10');

 lr_get_person := NULL;
               OPEN csr_get_person ('PERSON1'
                                   ,l_payroll_action_id
                                   ,rec_all_emp_under_le.action_information30
                                   );
               FETCH csr_get_person
                INTO lr_get_person;

               CLOSE csr_get_person;
	       add_tag_value ('FROM'
                             ,lr_get_person.action_information5
                             );
               add_tag_value ('TO', lr_get_person.action_information6);
               add_tag_value ('PIN', lr_get_person.action_information7);
               add_tag_value ('NAME'
                             ,lr_get_person.action_information8);
               add_tag_value ('ADDRESS'
                             ,lr_get_person.action_information26
                             );
               add_tag_value ('POSTAL_CODE'
                             ,lr_get_person.action_information27
                             );
               add_tag_value ('POSTAL_TOWN'
                             ,lr_get_person.action_information28
                             );
               add_tag_value
                  ('CORRECTION_DATE'
                  ,TO_CHAR
                      (fnd_date.canonical_to_date
                                     (lr_get_person.action_information9)
                      ,'YYYY-MM-DD'
                      )
                  );
               add_tag_value ('WORK_SITE_NUMBER'
                             ,lr_get_person.action_information10
                             );
               add_tag_value ('AMOUNT_TAX_WITHHELD'
                             ,lr_get_person.action_information11
                             );
               add_tag_value ('GROSS_SALARY'
                             ,lr_get_person.action_information12
                             );
               add_tag_value ('TB_EXCLUSIVE_CAR_FUEL'
                             ,lr_get_person.action_information13
                             );
               add_tag_value ('FREE_HOUSING'
                             ,lr_get_person.action_information14
                             );

		IF lr_get_person.action_information14='Y' THEN

			add_tag_value ('F_H'
                             ,'X');

		END IF;

               add_tag_value ('FREE_MEALS'
                             ,lr_get_person.action_information15
                             );

		IF lr_get_person.action_information15='Y' THEN

			add_tag_value ('F_M'
                             ,'X');

		END IF;

               add_tag_value ('FREE_HOUSING_OTHER41'
                             ,lr_get_person.action_information16
                             );

		IF lr_get_person.action_information16='Y' THEN

			add_tag_value ('F_H41'
                             ,'X');

		END IF;

               add_tag_value ('INTEREST'
                             ,lr_get_person.action_information17
                             );

		IF lr_get_person.action_information17='Y' THEN

			add_tag_value ('INT'
                             ,'X');

		END IF;

               add_tag_value ('OTHER_BENEFITS'
                             ,lr_get_person.action_information18
                             );

		IF lr_get_person.action_information18='Y' THEN

			add_tag_value ('OTH_BEN'
                             ,'X');

		END IF;

               add_tag_value ('BENEFIT_ADJUSTED'
                             ,lr_get_person.action_information19
                             );

		IF lr_get_person.action_information19='Y' THEN

			add_tag_value ('BEN_ADJ'
                             ,'X');

		END IF;


               add_tag_value ('TB_EXCLUSIVE_FUEL'
                             ,lr_get_person.action_information20
                             );
               add_tag_value ('RSV_CODE'
                             ,lr_get_person.action_information21
                             );
               add_tag_value ('NUMBER_OF_MONTHS_CAR'
                             ,lr_get_person.action_information22
                             );
               add_tag_value ('NUMBER_OF_KILOMETERS'
                             ,lr_get_person.action_information23
                             );
               add_tag_value ('EMPLOYEE_PAYMENT_CAR'
                             ,lr_get_person.action_information24
                             );
               add_tag_value ('FREE_FUEL_CAR'
                             ,lr_get_person.action_information25
                             );
               lr_get_person := NULL;

               OPEN csr_get_person ('PERSON2'
                                   ,l_payroll_action_id
                                   ,rec_all_emp_under_le.action_information30
                                   );

               FETCH csr_get_person
                INTO lr_get_person;

               CLOSE csr_get_person;


               add_tag_value ('COMPENSATION_FOR_EXPENSES'
                             ,lr_get_person.action_information4
                             );
               add_tag_value ('MILEAGE_ALLOWANCE'
                             ,lr_get_person.action_information5
                             );
		IF lr_get_person.action_information5='Y' THEN

			add_tag_value ('MIL_ALLOW'
                             ,'X');

		END IF;

               add_tag_value ('PER_DIEM_SWEDEN'
                             ,lr_get_person.action_information6
                             );
		IF lr_get_person.action_information6='Y' THEN

			add_tag_value ('PD_SW'
                             ,'X');

		END IF;
               add_tag_value ('PER_DIEM_OTHER'
                             ,lr_get_person.action_information7
                             );
		IF lr_get_person.action_information7='Y' THEN

			add_tag_value ('PD_OTH'
                             ,'X');

		END IF;
               add_tag_value ('BUSI_TRAVEL_EXPENSES_FLAG'
                             ,lr_get_person.action_information8
                             );
		IF lr_get_person.action_information8='Y' THEN

			add_tag_value ('BTE'
                             ,'X');

		END IF;
               add_tag_value ('ACC_BUSINESS_TRAVELS_FLAG'
                             ,lr_get_person.action_information9
                             );
		IF lr_get_person.action_information9='Y' THEN

			add_tag_value ('ABTF'
                             ,'X');

		END IF;
               add_tag_value ('WITHIN_SWEDEN'
                             ,lr_get_person.action_information10
                             );
		IF lr_get_person.action_information10='Y' THEN

			add_tag_value ('WS'
                             ,'X');

		END IF;
               add_tag_value ('OTHER_COUNTRIES'
                             ,lr_get_person.action_information11
                             );
		IF lr_get_person.action_information11='Y' THEN

			add_tag_value ('OTH_C'
                             ,'X');

		END IF;
               add_tag_value ('OCCUPATIONAL_PENSION'
                             ,lr_get_person.action_information12
                             );
               add_tag_value ('OTHER_TAX_REM'
                             ,lr_get_person.action_information13
                             );
	       add_tag_value ('TAX_REM_WITHOUT_SJD'                         --EOY 2008
                             ,lr_get_person.action_information23
                             );
--------------------------------------------------------------------------------------------------
--Taxable remunerations forwhich social security contributionsare not paid and which are notentitled to special job deduction
-------------------------------------------------------------------------------------------------------
               add_tag_value ('TAX_REM_PAID'
                             ,lr_get_person.action_information14
                             );
               add_tag_value ('CERTAIN_DEDUCTIONS'
                             ,lr_get_person.action_information15
                             );
               add_tag_value ('OTHER_BENEFITS_UP65'
                             ,lr_get_person.action_information16
                             );
               add_tag_value ('COMPE_FOR_EXPENSES_UP66'
                             ,lr_get_person.action_information17
                             );
               add_tag_value ('TAX_REM_PAID_UP67'
                             ,lr_get_person.action_information18
                             );
               add_tag_value ('OTHER_TAX_REM_UP68'
                             ,lr_get_person.action_information19
                             );
	        add_tag_value ('TAX_REM_WITHOUT_SJD_UP69'                       ---EOY 2008
                             ,lr_get_person.action_information24
                             );
--------------------------------------------------------------------------------------------------------------------------
--Taxable remunerations for which social security contributionsare not paid and which are not entitled to special job deduction
----------------------------------------------------------------------------------------------------------
               add_tag_value ('CERTAIN_DEDUCTIONS_UP70'
                             ,lr_get_person.action_information20
                             );
               add_tag_value ('NOT_TAX_REM'
                             ,lr_get_person.action_information21
                             );
               add_tag_value ('RENT', lr_get_person.action_information22);

		add_tag_value ('BENEFIT_AS_PENSION'                           --EOY 2008
                             ,lr_get_person.action_information25
                             );

		IF lr_get_person.action_information25='Y' THEN

			add_tag_value ('BEN_PEN'
                             ,'X');

		END IF;

--------------------------------------------------------------------------------------------------------------------------
-----------------------------------------New Benefit as pension-----------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
-- EOY 2008 - 2009  - Start
-- Basis for Tax Reduction for Household Services - Field 21
	      add_tag_value ('TAX_RED_HOUSE_SER'
                             ,lr_get_person.action_information26
                             );
-- EOY 2008-2009 end
-- EOY 2009 - 2010  - Start
-- Basis for Tax Reduction for ROT work - Field 22
	      add_tag_value ('TAX_RED_ROT_WORK'
                             ,lr_get_person.action_information27
                             );
-- EOY 2009-2010 end
               add_tag_value ('PERSON', 'PERSON_END');
            END LOOP;

-- *****************************************************************************
            add_tag_value ('KU10_PERSON', 'KU10_PERSON_END');
-- FOR KU13
            add_tag_value ('KU13_PERSON', 'KU13_PERSON');

-- *****************************************************************************
            FOR rec_all_emp_under_le IN
               csr_all_employees_under_le (l_payroll_action_id
                                          ,rec_all_le.action_information3
                                          ,'KU13'
                                          ,lr_report_details.action_information10
                                          )
            LOOP
               add_tag_value ('PERSON', 'PERSON');
               add_tag_value ('TYPE', 'KU13');
 lr_get_person := NULL;
               OPEN csr_get_person ('PERSON1'
                                   ,l_payroll_action_id
                                   ,rec_all_emp_under_le.action_information30
                                   );
               FETCH csr_get_person
                INTO lr_get_person;

               CLOSE csr_get_person;
               add_tag_value ('FROM'
                             ,lr_get_person.action_information5
                             );
               add_tag_value ('TO', lr_get_person.action_information6);
               add_tag_value ('PIN', lr_get_person.action_information7);
               add_tag_value ('NAME'
                             ,lr_get_person.action_information8);
               add_tag_value ('ADDRESS'
                             ,lr_get_person.action_information26
                             );
               add_tag_value ('POSTAL_CODE'
                             ,lr_get_person.action_information27
                             );
               add_tag_value ('POSTAL_TOWN'
                             ,lr_get_person.action_information28
                             );
               add_tag_value
                  ('CORRECTION_DATE'
                  ,TO_CHAR
                      (fnd_date.canonical_to_date
                                     (lr_get_person.action_information9)
                      ,'YYYY-MM-DD'
                      )
                  );
               add_tag_value ('WORK_SITE_NUMBER'
                             ,lr_get_person.action_information10
                             );
               add_tag_value ('AMOUNT_TAX_WITHHELD'
                             ,lr_get_person.action_information11
                             );
               add_tag_value ('GROSS_SALARY'
                             ,lr_get_person.action_information12
                             );
               add_tag_value ('TB_EXCLUSIVE_CAR_FUEL'
                             ,lr_get_person.action_information13
                             );
               add_tag_value ('FREE_HOUSING'
                             ,lr_get_person.action_information14
                             );
		IF lr_get_person.action_information14='Y' THEN

			add_tag_value ('F_H'
                             ,'X');

		END IF;

               add_tag_value ('FREE_MEALS'
                             ,lr_get_person.action_information15
                             );

		IF lr_get_person.action_information15='Y' THEN

			add_tag_value ('F_M'
                             ,'X');

		END IF;

               add_tag_value ('FREE_HOUSING_OTHER41'
                             ,lr_get_person.action_information16
                             );

		IF lr_get_person.action_information16='Y' THEN

			add_tag_value ('F_H41'
                             ,'X');

		END IF;

               add_tag_value ('INTEREST'
                             ,lr_get_person.action_information17
                             );

		IF lr_get_person.action_information17='Y' THEN

			add_tag_value ('INT'
                             ,'X');

		END IF;

               add_tag_value ('OTHER_BENEFITS'
                             ,lr_get_person.action_information18
                             );

		IF lr_get_person.action_information18='Y' THEN

			add_tag_value ('OTH_BEN'
                             ,'X');

		END IF;

               add_tag_value ('BENEFIT_ADJUSTED'
                             ,lr_get_person.action_information19
                             );


		IF lr_get_person.action_information19='Y' THEN

			add_tag_value ('BEN_ADJ'
                             ,'X');

		END IF;

               add_tag_value ('TB_EXCLUSIVE_FUEL'
                             ,lr_get_person.action_information20
                             );
               add_tag_value ('RSV_CODE'
                             ,lr_get_person.action_information21
                             );
               add_tag_value ('NUMBER_OF_MONTHS_CAR'
                             ,lr_get_person.action_information22
                             );
               add_tag_value ('NUMBER_OF_KILOMETERS'
                             ,lr_get_person.action_information23
                             );
               add_tag_value ('EMPLOYEE_PAYMENT_CAR'
                             ,lr_get_person.action_information24
                             );
               add_tag_value ('FREE_FUEL_CAR'
                             ,lr_get_person.action_information25
                             );
               lr_get_person := NULL;

               OPEN csr_get_person ('PERSON3'
                                   ,l_payroll_action_id
                                   ,rec_all_emp_under_le.action_information30
                                   );

               FETCH csr_get_person
                INTO lr_get_person;

               CLOSE csr_get_person;

               add_tag_value ('FTIN', lr_get_person.action_information4);
               add_tag_value ('TAX_COUNTRY_CODE'
                             ,lr_get_person.action_information5
                             );
               add_tag_value ('OCCUPATIONAL_PENSION'
                             ,lr_get_person.action_information6
                             );

-- Changes 2008/2009 Start
-- Updated the XML Code for which Taxable Remunerations for
-- which social securrity contributions are not paid
/*************************************************************************************
               add_tag_value ('OTHER_TAX_REM'
                             ,lr_get_person.action_information7
                             );
****************************************************************************************/
                add_tag_value ('OTHER_TAX_REM'
                             ,lr_get_person.action_information25
                             );
-- Changes 2008/2009 End

               add_tag_value ('COMPEN_FOR_BENEFIT'
                             ,lr_get_person.action_information8
                             );
               add_tag_value ('IN_PLAIN_WRITING_CODE'
                             ,lr_get_person.action_information10
                             );
               add_tag_value ('IN_PLAIN_WRITING_MEANING'
                             ,lr_get_person.action_information19
                             );
               add_tag_value ('PERSON', 'PERSON_END');
            END LOOP;

-- *****************************************************************************
            add_tag_value ('KU13_PERSON', 'KU13_PERSON_END');
-- FOR KU14
            add_tag_value ('KU14_PERSON', 'KU14_PERSON');

-- *****************************************************************************
            FOR rec_all_emp_under_le IN
               csr_all_employees_under_le (l_payroll_action_id
                                          ,rec_all_le.action_information3
                                          ,'KU14'
                                          ,lr_report_details.action_information10
                                          )
            LOOP
               add_tag_value ('PERSON', 'PERSON');
               add_tag_value ('TYPE', 'KU14');

 lr_get_person := NULL;
               OPEN csr_get_person ('PERSON1'
                                   ,l_payroll_action_id
                                   ,rec_all_emp_under_le.action_information30
                                   );
               FETCH csr_get_person
                INTO lr_get_person;

               CLOSE csr_get_person;
               add_tag_value ('FROM'
                             ,lr_get_person.action_information5
                             );
               add_tag_value ('TO', lr_get_person.action_information6);
               add_tag_value ('PIN', lr_get_person.action_information7);
               add_tag_value ('NAME'
                             ,lr_get_person.action_information8);
               add_tag_value ('ADDRESS'
                             ,lr_get_person.action_information26
                             );
               add_tag_value ('POSTAL_CODE'
                             ,lr_get_person.action_information27
                             );
               add_tag_value ('POSTAL_TOWN'
                             ,lr_get_person.action_information28
                             );
               add_tag_value
                  ('CORRECTION_DATE'
                  ,TO_CHAR
                      (fnd_date.canonical_to_date
                                     (lr_get_person.action_information9)
                      ,'YYYY-MM-DD'
                      )
                  );
               add_tag_value ('WORK_SITE_NUMBER'
                             ,lr_get_person.action_information10
                             );
               add_tag_value ('AMOUNT_TAX_WITHHELD'
                             ,lr_get_person.action_information11
                             );
               add_tag_value ('GROSS_SALARY'
                             ,lr_get_person.action_information12
                             );
               add_tag_value ('TB_EXCLUSIVE_CAR_FUEL'
                             ,lr_get_person.action_information13
                             );
               add_tag_value ('FREE_HOUSING'
                             ,lr_get_person.action_information14
                             );

		IF lr_get_person.action_information14='Y' THEN

			add_tag_value ('F_H'
                             ,'X');

		END IF;

               add_tag_value ('FREE_MEALS'
                             ,lr_get_person.action_information15
                             );

		IF lr_get_person.action_information15='Y' THEN

			add_tag_value ('F_M'
                             ,'X');

		END IF;

               add_tag_value ('FREE_HOUSING_OTHER41'
                             ,lr_get_person.action_information16
                             );

		IF lr_get_person.action_information16='Y' THEN

			add_tag_value ('F_H41'
                             ,'X');

		END IF;

               add_tag_value ('INTEREST'
                             ,lr_get_person.action_information17
                             );

		IF lr_get_person.action_information17='Y' THEN

			add_tag_value ('INT'
                             ,'X');

		END IF;


               add_tag_value ('OTHER_BENEFITS'
                             ,lr_get_person.action_information18
                             );
		IF lr_get_person.action_information18='Y' THEN

			add_tag_value ('OTH_BEN'
                             ,'X');

		END IF;

               add_tag_value ('BENEFIT_ADJUSTED'
                             ,lr_get_person.action_information19
                             );

		IF lr_get_person.action_information19='Y' THEN

			add_tag_value ('BEN_ADJ'
                             ,'X');

		END IF;

               add_tag_value ('TB_EXCLUSIVE_FUEL'
                             ,lr_get_person.action_information20
                             );
               add_tag_value ('RSV_CODE'
                             ,lr_get_person.action_information21
                             );
               add_tag_value ('NUMBER_OF_MONTHS_CAR'
                             ,lr_get_person.action_information22
                             );
               add_tag_value ('NUMBER_OF_KILOMETERS'
                             ,lr_get_person.action_information23
                             );
               add_tag_value ('EMPLOYEE_PAYMENT_CAR'
                             ,lr_get_person.action_information24
                             );
               add_tag_value ('FREE_FUEL_CAR'
                             ,lr_get_person.action_information25
                             );
               lr_get_person := NULL;

               OPEN csr_get_person ('PERSON2'
                                   ,l_payroll_action_id
                                   ,rec_all_emp_under_le.action_information30
                                   );

               FETCH csr_get_person
                INTO lr_get_person;

               CLOSE csr_get_person;

               add_tag_value ('MILEAGE_ALLOWANCE'
                             ,lr_get_person.action_information5
                             );
		IF lr_get_person.action_information5='Y' THEN

			add_tag_value ('MIL_ALLOW'
                             ,'X');

		END IF;
               add_tag_value ('PER_DIEM_SWEDEN'
                             ,lr_get_person.action_information6
                             );
		IF lr_get_person.action_information6='Y' THEN

			add_tag_value ('PD_SW'
                             ,'X');

		END IF;
               add_tag_value ('PER_DIEM_OTHER'
                             ,lr_get_person.action_information7
                             );
		IF lr_get_person.action_information7='Y' THEN

			add_tag_value ('PD_OTH'
                             ,'X');

		END IF;
               add_tag_value ('BUSI_TRAVEL_EXPENSES_FLAG'
                             ,lr_get_person.action_information8
                             );
		IF lr_get_person.action_information8='Y' THEN

			add_tag_value ('BTE'
                             ,'X');

		END IF;
               add_tag_value ('ACC_BUSINESS_TRAVELS_FLAG'
                             ,lr_get_person.action_information9
                             );
		IF lr_get_person.action_information9='Y' THEN

			add_tag_value ('ABTF'
                             ,'X');

		END IF;
               add_tag_value ('WITHIN_SWEDEN'
                             ,lr_get_person.action_information10
                             );
		IF lr_get_person.action_information10='Y' THEN

			add_tag_value ('WS'
                             ,'X');

		END IF;
               add_tag_value ('OTHER_COUNTRIES'
                             ,lr_get_person.action_information11
                             );
		IF lr_get_person.action_information11='Y' THEN

			add_tag_value ('OTH_C'
                             ,'X');

		END IF;
               lr_get_person := NULL;

               OPEN csr_get_person ('PERSON3'
                                   ,l_payroll_action_id
                                   ,rec_all_emp_under_le.action_information30
                                   );

               FETCH csr_get_person
                INTO lr_get_person;

               CLOSE csr_get_person;

               add_tag_value ('FTIN', lr_get_person.action_information4);
               add_tag_value ('TAX_COUNTRY_CODE'
                             ,lr_get_person.action_information5
                             );
               add_tag_value ('OCCUPATIONAL_PENSION'
                             ,lr_get_person.action_information11
                             );
               add_tag_value ('OTHER_TAX_REM'
                             ,lr_get_person.action_information12
                             );
               add_tag_value ('TAX_REM_PAID'
                             ,lr_get_person.action_information13
                             );
               add_tag_value ('NOT_TAX_REM'
                             ,lr_get_person.action_information14
                             );
               add_tag_value ('WORK_COUNTRY_CODE'
                             ,lr_get_person.action_information9
                             );
               add_tag_value ('WORK_COUNTRY_MEANING'
                             ,lr_get_person.action_information18
                             );
               add_tag_value ('IN_PLAIN_WRITING_CODE'
                             ,lr_get_person.action_information10
                             );
               add_tag_value ('IN_PLAIN_WRITING_MEANING'
                             ,lr_get_person.action_information19
                             );
               add_tag_value ('WORK_PERIOD'
                             ,lr_get_person.action_information15
                             );
		IF lr_get_person.action_information15='SIX_MONTHS_LESS' THEN

			add_tag_value ('WP_6'
                             ,'X');
		ELSIF lr_get_person.action_information15='SIX_TO_ONE_YEAR' THEN

			add_tag_value ('WP_L_12'
                             ,'X');

		ELSIF lr_get_person.action_information15='ONE_YEAR_OR_MORE' THEN

			add_tag_value ('WP_G_12'
                             ,'X');

		END IF;

               add_tag_value ('EMP_REGULATION_CATEGORY'
                             ,lr_get_person.action_information16
                             );
		IF lr_get_person.action_information16='92A' THEN

			add_tag_value ('CC_92A'
                             ,'X');
		ELSIF lr_get_person.action_information16='92B' THEN

			add_tag_value ('CC_92B'
                             ,'X');

		ELSIF lr_get_person.action_information16='92C' THEN

			add_tag_value ('CC_92C'
                             ,'X');

		ELSIF lr_get_person.action_information16='92D' THEN

			add_tag_value ('CC_92D'
                             ,'X');
		ELSIF lr_get_person.action_information16='92E' THEN

			add_tag_value ('CC_92E'
                             ,'X');

		ELSIF lr_get_person.action_information16='92F' THEN

			add_tag_value ('CC_92F'
                             ,'X');

		END IF;

                add_tag_value ('EMP_REGULATION_CATEGORY_CODE'
                             ,lr_get_person.action_information22
                             );

--EOY 2008/2009 Start
--Basis for Tax Reduction for household services

	        add_tag_value ('TAX_RED_HOUSE_SER'
                             ,lr_get_person.action_information23);
-- Benefit As Pension
                add_tag_value ('BENEFIT_AS_PENSION'
                             ,lr_get_person.action_information24
                             );
		IF lr_get_person.action_information24='Y' THEN

			add_tag_value ('BEN_PEN'
                             ,'X');
	END IF;
-- End
--EOY 2009/2010 Start
--Basis for Tax Reduction for rot work

	        add_tag_value ('TAX_RED_ROT_WORK'
                             ,lr_get_person.action_information26);
--EOY 2009/2010 End
               add_tag_value ('ARTICLE_DETAILS'
	                ,lr_get_person.action_information17
                             );
add_tag_value ('COMPENSATION_FOR_EXPENSES', lr_get_PERSON.action_information21);
               add_tag_value ('PERSON', 'PERSON_END');
            END LOOP;

-- *****************************************************************************
            add_tag_value ('KU14_PERSON', 'KU14_PERSON_END');
-- *****************************************************************************
            fnd_file.put_line (fnd_file.LOG, '^^^^^^^^^^^^^^^^^^^^^');
            add_tag_value ('EMPLOYEES', 'EMPLOYEES_END');
            add_tag_value ('LEGAL_EMPLOYER', 'LEGAL_EMPLOYER_END');
         END LOOP;                                 /* For all LEGAL_EMPLYER */

         add_tag_value ('INCOME_STATEMENT', 'INCOME_STATEMENT_END');
      END IF;                            /* for p_payroll_action_id IS NULL */

      writetoclob (p_xml);

--      INSERT INTO clob_table           VALUES (p_xml                  );
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
/* End of Proc to Add the tag value and Name */
 -- *****************************************************************************
       -- *****************************************************************************
/* Proc to Add the tag value and Name */
   FUNCTION get_country (p_code IN VARCHAR2 )
   return Varchar2
   IS
         CURSOR csr_get_country_details
      IS
         SELECT ft.territory_short_name
           FROM fnd_territories_vl ft
          WHERE ft.territory_code = p_code;

      lr_get_country_details          csr_get_country_details%ROWTYPE;

   l_country_name varchar2(240);

   BEGIN
   l_country_name := NULL;
   lr_get_country_details := NULL;

            OPEN csr_get_country_details ;
         FETCH csr_get_country_details          INTO lr_get_country_details;
         CLOSE csr_get_country_details;
   l_country_name := lr_get_country_details.territory_short_name;
   return l_country_name;
   END get_country;
/* End of Proc to Add the tag value and Name */
 -- *****************************************************************************
END pay_se_income_statement;

/
