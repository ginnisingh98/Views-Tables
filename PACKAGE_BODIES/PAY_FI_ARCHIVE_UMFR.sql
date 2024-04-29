--------------------------------------------------------
--  DDL for Package Body PAY_FI_ARCHIVE_UMFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_ARCHIVE_UMFR" AS
/* $Header: pyfiumfa.pkb 120.1 2006/04/04 01:53:38 dragarwa noship $ */
g_debug                   BOOLEAN        := hr_utility.debug_enabled;

   TYPE lock_rec IS RECORD (
      archive_assact_id             NUMBER);

   TYPE lock_table IS TABLE OF lock_rec
      INDEX BY BINARY_INTEGER;

   g_lock_table              lock_table;
   g_index                   NUMBER         := -1;
   g_index_assact            NUMBER         := -1;
   g_index_bal               NUMBER         := -1;
   g_package                 VARCHAR2 (33)  := ' PAY_FI_ARCHIVE_UMFR.';
   g_payroll_action_id       NUMBER;
   g_arc_payroll_action_id   NUMBER;

-- Globals to pick up all the parameter
   g_business_group_id       NUMBER;
   g_effective_date          DATE;
   g_trade_union_id          NUMBER;
   g_legal_employer_id       NUMBER;
   g_local_unit_id           NUMBER;
   g_reporting_date          DATE;
   g_period                  VARCHAR2 (240);
   g_period_start_date       DATE;
   g_period_end_date         DATE;

--End of Globals to pick up all the parameter
   g_format_mask             VARCHAR2 (50);
   g_err_num                 NUMBER;
   g_errm                    VARCHAR2 (150);
   g_archive                 VARCHAR2 (1);

   /* GET PARAMETER */
   FUNCTION get_parameter (
      p_parameter_string   IN   VARCHAR2,
      p_token              IN   VARCHAR2,
      p_segment_number     IN   NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      l_parameter   pay_payroll_actions.legislative_parameters%TYPE   := NULL;
      l_start_pos   NUMBER;
      l_delimiter   VARCHAR2 (1)                                      := ' ';
      l_proc        VARCHAR2 (40)                :=    g_package
                                                    || ' get parameter ';
   BEGIN
      --
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Function GET_PARAMETER', 10);
      END IF;

      l_start_pos :=
           INSTR (   ' '
                  || p_parameter_string,    l_delimiter
                                         || p_token
                                         || '=');

      --
      IF l_start_pos = 0
      THEN
         l_delimiter := '|';
         l_start_pos := INSTR (
                              ' '
                           || p_parameter_string,
                              l_delimiter
                           || p_token
                           || '='
                        );
      END IF;

      IF l_start_pos <> 0
      THEN
         l_start_pos :=   l_start_pos
                        + LENGTH (   p_token
                                  || '=');
         l_parameter := SUBSTR (
                           p_parameter_string,
                           l_start_pos,
                             INSTR (
                                   p_parameter_string
                                || ' ',
                                l_delimiter,
                                l_start_pos
                             )
                           - l_start_pos
                        );

         IF p_segment_number IS NOT NULL
         THEN
            l_parameter :=    ':'
                           || l_parameter
                           || ':';
            l_parameter := SUBSTR (
                              l_parameter,
                                INSTR (l_parameter, ':', 1, p_segment_number)
                              + 1,
                                INSTR (
                                   l_parameter,
                                   ':',
                                   1,
                                     p_segment_number
                                   + 1
                                )
                              - 1
                              - INSTR (l_parameter, ':', 1, p_segment_number)
                           );
         END IF;
      END IF;

      --
      RETURN l_parameter;

      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Function GET_PARAMETER', 20);
      END IF;
   END;

   /* GET ALL PARAMETERS */
   PROCEDURE get_all_parameters (
      p_payroll_action_id   IN              NUMBER -- In parameter
                                                  ,
      p_business_group_id   OUT NOCOPY      NUMBER -- Core parameter
                                                  ,
      p_effective_date      OUT NOCOPY      DATE -- Core parameter
                                                ,
      p_trade_union_id      OUT NOCOPY      NUMBER -- User parameter
                                                  ,
      p_legal_employer_id   OUT NOCOPY      NUMBER -- User parameter
                                                  ,
      p_local_unit_id       OUT NOCOPY      NUMBER -- User parameter
                                                  ,


      p_period              OUT NOCOPY      VARCHAR2, -- User parameter,

      p_period_end_date     OUT NOCOPY      DATE,
      p_archive             OUT NOCOPY      VARCHAR2
   )
   IS
      --
      CURSOR csr_parameter_info (p_payroll_action_id NUMBER)
      IS
         SELECT pay_fi_archive_umfr.get_parameter (
                   legislative_parameters,
                   'ARCHIVE'
                ),
                TO_NUMBER (
                   pay_fi_archive_umfr.get_parameter (
                      legislative_parameters,
                      'TRADE_UNION_ID'
                   )
                )
                      trade,
                TO_NUMBER (
                   pay_fi_archive_umfr.get_parameter (
                      legislative_parameters,
                      'LEGAL_EMPLOYER_ID'
                   )
                )
                      legal,
                TO_NUMBER (
                   pay_fi_archive_umfr.get_parameter (
                      legislative_parameters,
                      'LOCAL_UNIT_ID'
                   )
                )
                      LOCAL,
                pay_fi_archive_umfr.get_parameter (
                   legislative_parameters,
                   'PERIOD'
                )
                      period,
                fnd_date.canonical_to_date (
                   pay_fi_archive_umfr.get_parameter (
                      legislative_parameters,
                      'PERIOD_END_DATE'
                   )
                )
                      period_end_date,
                effective_date effective_date, business_group_id bg_id
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_payroll_action_id;

      lr_parameter_info   csr_parameter_info%ROWTYPE;
      l_proc              VARCHAR2 (240)
                                      :=    g_package
                                         || ' GET_ALL_PARAMETERS ';
   --
   BEGIN
      OPEN csr_parameter_info (p_payroll_action_id);
      --FETCH csr_parameter_info into lr_parameter_info;
      FETCH csr_parameter_info INTO p_archive,
                                    p_trade_union_id,
                                    p_legal_employer_id,
                                    p_local_unit_id,
                                    p_period,
                                    p_period_end_date,
                                    p_effective_date,
                                    p_business_group_id;
      CLOSE csr_parameter_info;


      IF g_debug
      THEN
         hr_utility.set_location (
            ' Leaving Procedure GET_ALL_PARAMETERS',
            30
         );
      END IF;
   END get_all_parameters;

   /* RANGE CODE */
   PROCEDURE range_code (
      p_payroll_action_id   IN              NUMBER,
      p_sql                 OUT NOCOPY      VARCHAR2
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
      l_trade_union_number        NUMBER;
      l_y_number                  VARCHAR2 (30);
      l_local_unit_id_fetched     NUMBER;
      l_accounting_id             NUMBER;
      l_action_sequence           NUMBER;
      l_assact_id                 NUMBER;
      l_pact_id                   NUMBER;
      l_flag                      NUMBER                               := 0;
      l_element_context           VARCHAR2 (5);

      CURSOR csr_trade_union_details (
         csr_v_trade_union_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hou.NAME, hoi.org_information1, hoi.org_information5
           FROM hr_organization_information hoi, hr_organization_units hou
          WHERE org_information_context = 'FI_TRADE_UNION_DETAILS'
            AND hou.organization_id = csr_v_trade_union_id
            AND hoi.organization_id = hou.organization_id;

      lr_trade_union_details      csr_trade_union_details%ROWTYPE;

      CURSOR csr_legal_employer_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hou.NAME, hoi.org_information1, hoi.org_information8
           FROM hr_organization_information hoi, hr_organization_units hou
          WHERE org_information_context = 'FI_LEGAL_EMPLOYER_DETAILS'
            AND hoi.organization_id = hou.organization_id
            AND hou.organization_id = csr_v_legal_employer_id;

      lr_legal_employer_details   csr_legal_employer_details%ROWTYPE;

      CURSOR csr_all_local_unit_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hoi_le.org_information1 local_unit_id,
                hou_lu.NAME local_unit_name,
                hoi_lu.org_information1 y_spare_number,
                hoi_lu.org_information2 local_unit_number
           FROM hr_organization_units hou_le,
                hr_organization_information hoi_le,
                hr_organization_units hou_lu,
                hr_organization_information hoi_lu
          WHERE hoi_le.organization_id = hou_le.organization_id
            AND hou_le.organization_id = csr_v_legal_employer_id
            AND hoi_le.org_information_context = 'FI_LOCAL_UNITS'
            AND hou_lu.organization_id = hoi_le.org_information1
            AND hou_lu.organization_id = hoi_lu.organization_id
            AND hoi_lu.org_information_context = 'FI_LOCAL_UNIT_DETAILS';

      lr_all_local_unit_details   csr_all_local_unit_details%ROWTYPE;

      CURSOR csr_local_unit_details (
         csr_v_local_unit_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hou.NAME, hoi.org_information1 y_spare_number,
                hoi.org_information2 local_unit_number
           FROM hr_organization_information hoi, hr_organization_units hou
          WHERE org_information_context = 'FI_LOCAL_UNIT_DETAILS'
            AND hoi.organization_id = hou.organization_id
            AND hou.organization_id = csr_v_local_unit_id;

      lr_local_unit_details       csr_local_unit_details%ROWTYPE;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure RANGE_CODE', 40);
      END IF;

      fnd_file.put_line (fnd_file.LOG, 'Entering Procedure RANGE_CODE 7');
      p_sql :=
            'SELECT DISTINCT person_id
   FROM  per_people_f ppf
        ,pay_payroll_actions ppa
   WHERE ppa.payroll_action_id = :payroll_action_id
   AND   ppa.business_group_id = ppf.business_group_id
   ORDER BY ppf.person_id';
      pay_fi_archive_umfr.get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_effective_date,
         g_trade_union_id,
         g_legal_employer_id,
         g_local_unit_id,
         g_period,
         g_period_end_date,
         g_archive
      );

      IF g_archive = 'Y'
      THEN
         OPEN csr_trade_union_details (g_trade_union_id);
         FETCH csr_trade_union_details INTO lr_trade_union_details;
         CLOSE csr_trade_union_details;
         l_trade_union_number := lr_trade_union_details.org_information1;
         l_accounting_id := lr_trade_union_details.org_information5;
         -- Pick up the details belonging to Legal Employer Details

         OPEN csr_legal_employer_details (g_legal_employer_id);
         fnd_file.put_line (fnd_file.LOG, '1');
         FETCH csr_legal_employer_details INTO lr_legal_employer_details;
         fnd_file.put_line (fnd_file.LOG, '2');
         CLOSE csr_legal_employer_details;
         fnd_file.put_line (fnd_file.LOG, '3');
         l_y_number := lr_legal_employer_details.org_information1;

         IF g_local_unit_id IS NOT NULL
         THEN
            OPEN csr_local_unit_details (g_local_unit_id);
            FETCH csr_local_unit_details INTO lr_local_unit_details;
            CLOSE csr_local_unit_details;
            pay_action_information_api.create_action_information (
               p_action_information_id=> l_action_info_id,
               p_action_context_id=> p_payroll_action_id,
               p_action_context_type=> 'PA',
               p_object_version_number=> l_ovn,
               p_effective_date=> g_effective_date,
               p_source_id=> NULL,
               p_source_text=> NULL,
               p_action_information_category=> 'EMEA REPORT INFORMATION',
               p_action_information1=> 'PYFIUMFR',
               p_action_information2=> 'LU',
               p_action_information3=> g_local_unit_id,
               p_action_information4=> lr_local_unit_details.NAME,
               p_action_information5=> lr_local_unit_details.y_spare_number,
               p_action_information6=> lr_local_unit_details.local_unit_number,
               p_action_information7=> NULL,
               p_action_information8=> NULL,
               p_action_information9=> NULL,
               p_action_information10=> NULL,
               p_action_information11=> NULL,
               p_action_information12=> NULL,
               p_action_information13=> NULL,
               p_action_information14=> NULL,
               p_action_information15=> NULL,
               p_action_information16=> NULL,
               p_action_information17=> NULL,
               p_action_information18=> NULL,
               p_action_information19=> NULL,
               p_action_information20=> NULL,
               p_action_information21=> NULL,
               p_action_information22=> NULL,
               p_action_information23=> NULL,
               p_action_information24=> NULL,
               p_action_information25=> NULL,
               p_action_information26=> NULL,
               p_action_information27=> NULL --date from srs req
                                            ,
               p_action_information28=> NULL,
               p_action_information29=> NULL,
               p_action_information30=> NULL
            );
         ELSE
            FOR lr_all_local_unit_details IN
                csr_all_local_unit_details (g_legal_employer_id)
            LOOP
               pay_action_information_api.create_action_information (
                  p_action_information_id=> l_action_info_id,
                  p_action_context_id=> p_payroll_action_id,
                  p_action_context_type=> 'PA',
                  p_object_version_number=> l_ovn,
                  p_effective_date=> g_effective_date,
                  p_source_id=> NULL,
                  p_source_text=> NULL,
                  p_action_information_category=> 'EMEA REPORT INFORMATION',
                  p_action_information1=> 'PYFIUMFR',
                  p_action_information2=> 'LU',
                  p_action_information3=> lr_all_local_unit_details.local_unit_id,
                  p_action_information4=> lr_all_local_unit_details.local_unit_name,
                  p_action_information5=> lr_all_local_unit_details.y_spare_number,
                  p_action_information6=> lr_all_local_unit_details.local_unit_number,
                  p_action_information7=> NULL,
                  p_action_information8=> NULL,
                  p_action_information9=> NULL,
                  p_action_information10=> NULL,
                  p_action_information11=> NULL,
                  p_action_information12=> NULL,
                  p_action_information13=> NULL,
                  p_action_information14=> NULL,
                  p_action_information15=> NULL,
                  p_action_information16=> NULL,
                  p_action_information17=> NULL,
                  p_action_information18=> NULL,
                  p_action_information19=> NULL,
                  p_action_information20=> NULL,
                  p_action_information21=> NULL,
                  p_action_information22=> NULL,
                  p_action_information23=> NULL,
                  p_action_information24=> NULL,
                  p_action_information25=> NULL,
                  p_action_information26=> NULL,
                  p_action_information27=> NULL --date from srs req
                                               ,
                  p_action_information28=> NULL,
                  p_action_information29=> NULL,
                  p_action_information30=> NULL
               );
            END LOOP;
         END IF;

         pay_action_information_api.create_action_information (
            p_action_information_id=> l_action_info_id,
            p_action_context_id=> p_payroll_action_id,
            p_action_context_type=> 'PA',
            p_object_version_number=> l_ovn,
            p_effective_date=> g_effective_date,
            p_source_id=> NULL,
            p_source_text=> NULL,
            p_action_information_category=> 'EMEA REPORT DETAILS',
            p_action_information1=> 'PYFIUMFR',
            p_action_information2=> lr_trade_union_details.NAME,
            p_action_information3=> g_trade_union_id,
            p_action_information4=> lr_legal_employer_details.NAME,
            p_action_information5=> g_legal_employer_id,
            p_action_information6=> lr_local_unit_details.NAME,
            p_action_information7=> g_local_unit_id,
            p_action_information8=> g_period,
            p_action_information9=> fnd_date.date_to_canonical (
                        g_period_end_date
                     ),
            p_action_information10=> NULL,
            p_action_information11=> NULL,
            p_action_information12=> NULL,
            p_action_information13=> NULL,
            p_action_information14=> NULL,
            p_action_information15=> NULL,
            p_action_information16=> NULL,
            p_action_information17=> NULL,
            p_action_information18=> NULL,
            p_action_information19=> NULL,
            p_action_information20=> NULL,
            p_action_information21=> NULL,
            p_action_information22=> NULL,
            p_action_information23=> NULL,
            p_action_information24=> NULL,
            p_action_information25=> NULL,
            p_action_information26=> NULL,
            p_action_information27=> NULL,
            p_action_information28=> NULL,
            p_action_information29=> NULL,
            p_action_information30=> NULL
         );
         pay_action_information_api.create_action_information (
            p_action_information_id=> l_action_info_id,
            p_action_context_id=> p_payroll_action_id,
            p_action_context_type=> 'PA',
            p_object_version_number=> l_ovn,
            p_effective_date=> g_effective_date,
            p_source_id=> NULL,
            p_source_text=> NULL,
            p_action_information_category=> 'EMEA REPORT INFORMATION',
            p_action_information1=> 'PYFIUMFR',
            p_action_information2=> 'LE',
            p_action_information3=> g_legal_employer_id,
            p_action_information4=> lr_legal_employer_details.NAME,
            p_action_information5=> l_y_number,
            p_action_information6=> NULL,
            p_action_information7=> NULL,
            p_action_information8=> NULL,
            p_action_information9=> NULL,
            p_action_information10=> NULL,
            p_action_information11=> NULL,
            p_action_information12=> NULL,
            p_action_information13=> NULL,
            p_action_information14=> NULL,
            p_action_information15=> NULL,
            p_action_information16=> NULL,
            p_action_information17=> NULL,
            p_action_information18=> NULL,
            p_action_information19=> NULL,
            p_action_information20=> NULL,
            p_action_information21=> NULL,
            p_action_information22=> NULL,
            p_action_information23=> NULL,
            p_action_information24=> NULL,
            p_action_information25=> NULL,
            p_action_information26=> NULL,
            p_action_information27=> NULL,
            p_action_information28=> NULL,
            p_action_information29=> NULL,
            p_action_information30=> NULL
         );
         pay_action_information_api.create_action_information (
            p_action_information_id=> l_action_info_id,
            p_action_context_id=> p_payroll_action_id,
            p_action_context_type=> 'PA',
            p_object_version_number=> l_ovn,
            p_effective_date=> g_effective_date,
            p_source_id=> NULL,
            p_source_text=> NULL,
            p_action_information_category=> 'EMEA REPORT INFORMATION',
            p_action_information1=> 'PYFIUMFR',
            p_action_information2=> 'TU',
            p_action_information3=> g_trade_union_id,
            p_action_information4=> lr_trade_union_details.NAME,
            p_action_information5=> l_trade_union_number,
            p_action_information6=> l_accounting_id,
            p_action_information7=> NULL,
            p_action_information8=> NULL,
            p_action_information9=> NULL,
            p_action_information10=> NULL,
            p_action_information11=> NULL,
            p_action_information12=> NULL,
            p_action_information13=> NULL,
            p_action_information14=> NULL,
            p_action_information15=> NULL,
            p_action_information16=> NULL,
            p_action_information17=> NULL,
            p_action_information18=> NULL,
            p_action_information19=> NULL,
            p_action_information20=> NULL,
            p_action_information21=> NULL,
            p_action_information22=> NULL,
            p_action_information23=> NULL,
            p_action_information24=> NULL,
            p_action_information25=> NULL,
            p_action_information26=> NULL,
            p_action_information27=> NULL,
            p_action_information28=> NULL,
            p_action_information29=> NULL,
            p_action_information30=> NULL
         );
      END IF; --archiving=yes

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
      p_payroll_action_id   IN   NUMBER,
      p_start_person        IN   NUMBER,
      p_end_person          IN   NUMBER,
      p_chunk               IN   NUMBER
   )
   IS
      CURSOR csr_prepaid_assignments (
         p_payroll_action_id    NUMBER,
         p_start_person         NUMBER,
         p_end_person           NUMBER,
         p_legal_employer_id    NUMBER,
         p_local_unit_id        NUMBER,
         p_trade_union_id       NUMBER,
         l_period_start_date    DATE,
         l_period_end_date      DATE,
         l_bussiness_group_id   NUMBER,
         p_chunk                NUMBER
      )
      IS

		 SELECT act.assignment_id            assignment_id,
			act.assignment_action_id     run_action_id,
			act1.assignment_action_id    prepaid_action_id
		 FROM   pay_payroll_actions          ppa
			,pay_payroll_actions          appa
			,pay_payroll_actions          appa2
			,pay_assignment_actions       act
			,pay_assignment_actions       act1
			,pay_action_interlocks        pai
			,per_all_assignments_f        as1
			,hr_soft_coding_keyflex         hsck
			 ,pay_run_result_values    TARGET
			,pay_run_results          RR
			,pay_element_entries_f  PEEF
			,pay_element_types_f     PETF
			, pay_input_values_f     PIV
			, per_all_people_f         pap
		 WHERE  ppa.payroll_action_id        = p_payroll_action_id
		 AND    appa.effective_date          BETWEEN l_period_start_date
			    AND     l_period_end_date
		 AND    as1.person_id                BETWEEN p_start_person
			    AND     p_end_person
		 AND    appa.action_type             IN ('R','Q')
			-- Payroll Run or Quickpay Run
		 AND    act.payroll_action_id        = appa.payroll_action_id
		 AND    act.source_action_id         IS NULL -- Master Action
		 AND    as1.assignment_id            = act.assignment_id
                AND     as1.person_id = pap.person_id
		   AND pap.per_information9 =
                                                   TO_CHAR (p_trade_union_id)
		 AND    ppa.effective_date           BETWEEN as1.effective_start_date
			    AND     as1.effective_end_date
		 AND    act.action_status            = 'C'  -- Completed
		 AND    act.assignment_action_id     = pai.locked_action_id
		 AND    act1.assignment_action_id    = pai.locking_action_id
		 AND    act1.action_status           = 'C' -- Completed
		 AND    act1.payroll_action_id     = appa2.payroll_action_id
		 AND    appa2.action_type            IN ('P','U')
		 AND    appa2.effective_date          BETWEEN l_period_start_date
				 AND l_period_end_date
			-- Prepayments or Quickpay Prepayments
            AND (   p_local_unit_id IS NULL
                 OR (    p_local_unit_id IS NOT NULL
                     AND hsck.segment2 = TO_CHAR (p_local_unit_id)
                    )
                )
		 AND  hsck.SOFT_CODING_KEYFLEX_ID=as1.SOFT_CODING_KEYFLEX_ID
--		AND   hsck.segment2 = p_local_unit_id
		AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
		AND   act.TAX_UNIT_ID    =  p_legal_employer_id
		and    TARGET.run_result_id    = RR.run_result_id
		AND   (( RR.assignment_action_id
		in ( Select act2.assignment_action_id
		from pay_assignment_actions act2
		Where    act2.source_action_id=act.assignment_action_id
		AND    act2.action_status            = 'C'  -- Completed
		AND    act2.payroll_action_id        = act.payroll_action_id))
		or
		(RR.assignment_action_id=act.assignment_action_id))
		and    RR.status in ('P','PA')
		and  PEEF.element_entry_id  = RR.element_entry_id
		and  PEEF.element_type_id   = RR.element_type_id
		and  PEEF.element_type_id   = PETF.element_type_id
		and  PETF.legislation_code  ='FI'
		and  PETF.element_name  = 'Trade Union Membership Fees'
		and  PIV.element_type_id   = PETF.element_type_id
		and  PIV.input_value_id    = TARGET.input_value_id
		and  PIV.name='Third Party Payee'
		and TARGET.result_value   = to_char(p_trade_union_id)
		and  act.assignment_id  IN
		(SELECT  MIN(act.assignment_id)
		 FROM   pay_payroll_actions          ppa
			,pay_payroll_actions          appa
			,pay_payroll_actions          appa2
			,pay_assignment_actions       act
			,pay_assignment_actions       act1
			,pay_action_interlocks        pai
			,per_all_assignments_f        as1
			,hr_soft_coding_keyflex         hsck
			 ,pay_run_result_values    TARGET
			,pay_run_results          RR
			,pay_element_entries_f  PEEF
			,pay_element_types_f     PETF
			, pay_input_values_f     PIV
			, per_all_people_f         pap
		 WHERE  ppa.payroll_action_id        = p_payroll_action_id
		 AND    appa.effective_date          BETWEEN l_period_start_date
			    AND     l_period_end_date
		 AND    as1.person_id                BETWEEN p_start_person
			    AND     p_end_person
		 AND    appa.action_type             IN ('R','Q')
			-- Payroll Run or Quickpay Run
		 AND    act.payroll_action_id        = appa.payroll_action_id
		 AND    act.source_action_id         IS NULL -- Master Action
		 AND    as1.assignment_id            = act.assignment_id
                 AND     as1.person_id = pap.person_id
		   AND pap.per_information9 =
                                                   TO_CHAR (p_trade_union_id)
		 AND    ppa.effective_date           BETWEEN as1.effective_start_date
			    AND     as1.effective_end_date
		 AND    act.action_status            = 'C'  -- Completed
		 AND    act.assignment_action_id     = pai.locked_action_id
		 AND    act1.assignment_action_id    = pai.locking_action_id
		 AND    act1.action_status           = 'C' -- Completed
		 AND    act1.payroll_action_id       = appa2.payroll_action_id
		 AND    appa2.action_type            IN ('P','U')
		 AND    appa2.effective_date          BETWEEN l_period_start_date
				 AND l_period_end_date
			-- Prepayments or Quickpay Prepayments
		 AND  hsck.SOFT_CODING_KEYFLEX_ID=as1.SOFT_CODING_KEYFLEX_ID
            AND (   p_local_unit_id IS NULL
                 OR (    p_local_unit_id IS NOT NULL
                     AND hsck.segment2 = TO_CHAR (p_local_unit_id)
                    )
                )
--		AND   hsck.segment2 = p_local_unit_id
		AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
		AND   act.TAX_UNIT_ID    =  p_legal_employer_id
		and    TARGET.run_result_id    = RR.run_result_id
		AND   (( RR.assignment_action_id
		in ( Select act2.assignment_action_id
		from pay_assignment_actions act2
		Where    act2.source_action_id=act.assignment_action_id
		AND    act2.action_status            = 'C'  -- Completed
		AND    act2.payroll_action_id        = act.payroll_action_id))
		or
		(RR.assignment_action_id=act.assignment_action_id))
		and    RR.status in ('P','PA')
		and  PEEF.element_entry_id  = RR.element_entry_id
		and  PEEF.element_type_id   = RR.element_type_id
		and  PEEF.element_type_id   = PETF.element_type_id
		and  PETF.legislation_code  ='FI'
		and  PETF.element_name  = 'Trade Union Membership Fees'
		and  PIV.element_type_id   = PETF.element_type_id
		and  PIV.input_value_id    = TARGET.input_value_id
		and  PIV.name='Third Party Payee'
		and TARGET.result_value   = to_char(p_trade_union_id)
		GROUP BY  as1.person_id
		)
	      	and  (act.assignment_id ,act.assignment_action_id )  IN
		(SELECT  act.assignment_id , max(act.assignment_action_id )
		 FROM   pay_payroll_actions          ppa
			,pay_payroll_actions          appa
			,pay_payroll_actions          appa2
			,pay_assignment_actions       act
			,pay_assignment_actions       act1
			,pay_action_interlocks        pai
			,per_all_assignments_f        as1
			,hr_soft_coding_keyflex         hsck
			 ,pay_run_result_values    TARGET
			,pay_run_results          RR
			,pay_element_entries_f  PEEF
			,pay_element_types_f     PETF
			, pay_input_values_f     PIV
			, per_all_people_f         pap
		 WHERE  ppa.payroll_action_id        = p_payroll_action_id
		 AND    appa.effective_date          BETWEEN l_period_start_date
			    AND     l_period_end_date
		 AND    as1.person_id                BETWEEN p_start_person
			    AND     p_end_person
		 AND    appa.action_type             IN ('R','Q')
			-- Payroll Run or Quickpay Run
		 AND    act.payroll_action_id        = appa.payroll_action_id
		 AND    act.source_action_id         IS NULL -- Master Action
		 AND    as1.assignment_id            = act.assignment_id
                 AND     as1.person_id = pap.person_id
		   AND pap.per_information9 =
                                                   TO_CHAR (p_trade_union_id)
		 AND    ppa.effective_date           BETWEEN as1.effective_start_date
			    AND     as1.effective_end_date
		 AND    act.action_status            = 'C'  -- Completed
		 AND    act.assignment_action_id     = pai.locked_action_id
		 AND    act1.assignment_action_id    = pai.locking_action_id
		 AND    act1.action_status           = 'C' -- Completed
		 AND    act1.payroll_action_id       = appa2.payroll_action_id
		 AND    appa2.action_type            IN ('P','U')
		 AND    appa2.effective_date          BETWEEN l_period_start_date
				 AND l_period_end_date
		 AND  hsck.SOFT_CODING_KEYFLEX_ID=as1.SOFT_CODING_KEYFLEX_ID
            AND (   p_local_unit_id IS NULL
                 OR (    p_local_unit_id IS NOT NULL
                     AND hsck.segment2 = TO_CHAR (p_local_unit_id)
                    )
                )
		AND   act.TAX_UNIT_ID    =  act1.TAX_UNIT_ID
		AND   act.TAX_UNIT_ID    =  p_legal_employer_id
		and    TARGET.run_result_id    = RR.run_result_id
		AND   (( RR.assignment_action_id
		in ( Select act2.assignment_action_id
		from pay_assignment_actions act2
		Where    act2.source_action_id=act.assignment_action_id
		AND    act2.action_status            = 'C'  -- Completed
		AND    act2.payroll_action_id        = act.payroll_action_id))
		or
		(RR.assignment_action_id=act.assignment_action_id))
		and    RR.status in ('P','PA')
		and  PEEF.element_entry_id  = RR.element_entry_id
		and  PEEF.element_type_id   = RR.element_type_id
		and  PEEF.element_type_id   = PETF.element_type_id
		and  PETF.legislation_code  ='FI'
		and  PETF.element_name  = 'Trade Union Membership Fees'
		and  PIV.element_type_id   = PETF.element_type_id
		and  PIV.input_value_id    = TARGET.input_value_id
		and  PIV.name='Third Party Payee'
		and TARGET.result_value   = to_char(p_trade_union_id)
		GROUP BY  act.assignment_id
		)
		 ORDER BY act.assignment_id;






      l_count                  NUMBER         := 0;
      l_prev_prepay            NUMBER         := 0;
      l_start_date             VARCHAR2 (20);
      l_end_date               VARCHAR2 (20);
      l_canonical_start_date   DATE;
      l_canonical_end_date     DATE;
      l_payroll_id             NUMBER;
      l_consolidation_set      NUMBER;
      l_prepay_action_id       NUMBER;
      l_actid                  NUMBER;
      l_assignment_id          NUMBER;
      l_action_sequence        NUMBER;
      l_assact_id              NUMBER;
      l_pact_id                NUMBER;
      l_flag                   NUMBER         := 0;
      l_defined_balance_id     NUMBER         := 0;
      l_action_info_id         NUMBER;
      l_ovn                    NUMBER;
      -- User pARAMETERS needed
      l_business_group_id      NUMBER;
      l_effective_date         DATE;
      l_trade_union_id         NUMBER;
      l_legal_employer_id      NUMBER;
      l_local_unit_id          NUMBER;
      l_reporting_date         DATE;
      l_period                 VARCHAR2 (240);
      l_period_start_date      DATE;
      l_period_end_date        DATE;
   -- End of User pARAMETERS needed
     l_assignment number;   --
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (
            ' Entering Procedure ASSIGNMENT_ACTION_CODE',
            60
         );
      END IF;

      pay_fi_archive_umfr.get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_effective_date,
         g_trade_union_id,
         g_legal_employer_id,
         g_local_unit_id,
         g_period,
         g_period_end_date,
         g_archive
      );

    fnd_file.put_line ( fnd_file.LOG, g_legal_employer_id ||'g_legal_employer_id');
       fnd_file.put_line ( fnd_file.LOG, p_start_person ||'p_start_person');
      fnd_file.put_line ( fnd_file.LOG, p_end_person ||'p_end_person');
       fnd_file.put_line ( fnd_file.LOG, g_local_unit_id ||'g_local_unit_id');
      fnd_file.put_line ( fnd_file.LOG, g_trade_union_id ||'g_trade_union_id');
      fnd_file.put_line ( fnd_file.LOG, g_period_start_date ||'g_period_start_date');
      fnd_file.put_line ( fnd_file.LOG, g_period_start_date ||'g_period_start_date');
      fnd_file.put_line ( fnd_file.LOG, g_period_start_date ||'g_period_start_date');

      IF g_archive = 'Y'
      THEN
         l_prepay_action_id := 0;
         l_assignment:=0;
         fnd_file.put_line (fnd_file.LOG, ' Before the Locking Cursor ');

         SELECT DECODE (
                   g_period,
                   'MONTH', TRUNC (g_period_end_date, 'MM'),
                   'BIMONTH', TRUNC (
                                 ADD_MONTHS (
                                    g_period_end_date,
                                      MOD (
                                         TO_NUMBER (
                                            TO_CHAR (g_period_end_date, 'MM')
                                         ),
                                         2
                                      )
                                    - 1
                                 ),
                                 'MM'
                              ),
                   'BIWEEK',  g_period_end_date - 14,
                   'QUARTER', TRUNC (g_period_end_date, 'Q')
                )
           INTO g_period_start_date
           FROM DUAL;

         fnd_file.put_line (
            fnd_file.LOG,
               'G_PERIOD_start_DATE '
            || g_period_start_date
         );

         -- this is for all the person's assignment actionid under the selected legal employer
         FOR rec_prepaid_assignments IN
             csr_prepaid_assignments (
                p_payroll_action_id,
                p_start_person,
                p_end_person,
                g_legal_employer_id,
                g_local_unit_id,
                g_trade_union_id,
                g_period_start_date,
                g_period_end_date,
                g_business_group_id,
                p_chunk
             )
         LOOP

--            IF l_prepay_action_id <>
  --                                  rec_prepaid_assignments.prepaid_action_id --pp
  if l_assignment <> rec_prepaid_assignments.assignment_id then
--            THEN
               SELECT pay_assignment_actions_s.NEXTVAL
                 INTO l_actid
                 FROM DUAL;

               --
               g_index_assact :=   g_index_assact
                                 + 1;
               g_lock_table (g_index_assact).archive_assact_id := l_actid;

               -- Create the archive assignment action
               fnd_file.put_line (
                  fnd_file.LOG,
                     'l_actid'
                  || l_actid
                  || ' rec_prepaid_assignments.assignment_id'
                  || rec_prepaid_assignments.assignment_id
                  || ' p_chunk'
                  || p_chunk
               );
               hr_nonrun_asact.insact (
                  l_actid,
                  rec_prepaid_assignments.assignment_id,
                  p_payroll_action_id,
                  p_chunk,
                  NULL
               );
            -- Create archive to prepayment assignment action interlock
            --
                                 --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
            END IF;

            -- create archive to master assignment action interlock
             --hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
--            l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id; ---pp
               l_assignment:=               rec_prepaid_assignments.assignment_id;
         END LOOP;
      END IF; --ARCHIVE

      fnd_file.put_line (
         fnd_file.LOG,
         ' After Ending Assignment Act Code  the Locking Cursor '
      );

      IF g_debug
      THEN
         hr_utility.set_location (
            ' Leaving Procedure ASSIGNMENT_ACTION_CODE',
            70
         );
      END IF;
   END assignment_action_code;


   PROCEDURE initialization_code (p_payroll_action_id IN NUMBER)
   IS
      CURSOR csr_prepay_id
      IS
         SELECT DISTINCT prepay_payact.payroll_action_id prepay_payact_id,
                         run_payact.date_earned date_earned
                    FROM pay_action_interlocks archive_intlck,
                         pay_assignment_actions prepay_assact,
                         pay_payroll_actions prepay_payact,
                         pay_action_interlocks prepay_intlck,
                         pay_assignment_actions run_assact,
                         pay_payroll_actions run_payact,
                         pay_assignment_actions archive_assact
                   WHERE archive_intlck.locking_action_id =
                                          archive_assact.assignment_action_id
                     AND archive_assact.payroll_action_id =
                                                          p_payroll_action_id
                     AND prepay_assact.assignment_action_id =
                                              archive_intlck.locked_action_id
                     AND prepay_payact.payroll_action_id =
                                              prepay_assact.payroll_action_id
                     AND prepay_payact.action_type IN ('U', 'P')
                     AND prepay_intlck.locking_action_id =
                                           prepay_assact.assignment_action_id
                     AND run_assact.assignment_action_id =
                                               prepay_intlck.locked_action_id
                     AND run_payact.payroll_action_id =
                                                 run_assact.payroll_action_id
                     AND run_payact.action_type IN ('Q', 'R')
                ORDER BY prepay_payact.payroll_action_id;


      CURSOR csr_runact_id
      IS
         SELECT DISTINCT prepay_payact.payroll_action_id prepay_payact_id,
                         run_payact.date_earned date_earned,
                         run_payact.payroll_action_id run_payact_id
                    FROM pay_action_interlocks archive_intlck,
                         pay_assignment_actions prepay_assact,
                         pay_payroll_actions prepay_payact,
                         pay_action_interlocks prepay_intlck,
                         pay_assignment_actions run_assact,
                         pay_payroll_actions run_payact,
                         pay_assignment_actions archive_assact
                   WHERE archive_intlck.locking_action_id =
                                          archive_assact.assignment_action_id
                     AND archive_assact.payroll_action_id =
                                                          p_payroll_action_id
                     AND prepay_assact.assignment_action_id =
                                              archive_intlck.locked_action_id
                     AND prepay_payact.payroll_action_id =
                                              prepay_assact.payroll_action_id
                     AND prepay_payact.action_type IN ('U', 'P')
                     AND prepay_intlck.locking_action_id =
                                           prepay_assact.assignment_action_id
                     AND run_assact.assignment_action_id =
                                               prepay_intlck.locked_action_id
                     AND run_payact.payroll_action_id =
                                                 run_assact.payroll_action_id
                     AND run_payact.action_type IN ('Q', 'R')
                ORDER BY prepay_payact.payroll_action_id;

      rec_prepay_id         csr_prepay_id%ROWTYPE;
      rec_runact_id         csr_runact_id%ROWTYPE;
      l_action_info_id      NUMBER;
      l_ovn                 NUMBER;
      l_count               NUMBER                  := 0;
      l_business_group_id   NUMBER;
      l_start_date          VARCHAR2 (20);
      l_end_date            VARCHAR2 (20);
      l_effective_date      DATE;
      l_payroll_id          NUMBER;
      l_consolidation_set   NUMBER;
      l_prev_prepay         NUMBER                  := 0;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (
            ' Entering Procedure INITIALIZATION_CODE',
            80
         );
      END IF;

      fnd_file.put_line (fnd_file.LOG, 'In INIT_CODE 0');


      IF g_debug
      THEN
         hr_utility.set_location (
            ' Leaving Procedure INITIALIZATION_CODE',
            90
         );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_err_num := SQLCODE;

         IF g_debug
         THEN
            hr_utility.set_location (
                  'ORA_ERR: '
               || g_err_num
               || 'In INITIALIZATION_CODE',
               180
            );
         END IF;
   END initialization_code;

   /* GET COUNTRY NAME FROM CODE */
   FUNCTION get_country_name (p_territory_code VARCHAR2)
      RETURN VARCHAR2
   IS
      CURSOR csr_get_territory_name (p_territory_code VARCHAR2)
      IS
         SELECT territory_short_name
           FROM fnd_territories_vl
          WHERE territory_code = p_territory_code;

      l_country   fnd_territories_vl.territory_short_name%TYPE;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Function GET_COUNTRY_NAME', 140);
      END IF;

      OPEN csr_get_territory_name (p_territory_code);
      FETCH csr_get_territory_name INTO l_country;
      CLOSE csr_get_territory_name;
      RETURN l_country;

      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Function GET_COUNTRY_NAME', 150);
      END IF;
   END get_country_name;

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
            AND (u.legislation_code = 'FI')
            AND (u.business_group_id IS NULL)
            AND u.creator_type = 'B';

      l_defined_balance_id   ff_user_entities.user_entity_id%TYPE;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (
            ' Entering Function GET_DEFINED_BALANCE_ID',
            240
         );
      END IF;

      OPEN csr_def_bal_id (p_user_name);
      FETCH csr_def_bal_id INTO l_defined_balance_id;
      CLOSE csr_def_bal_id;
      RETURN l_defined_balance_id;

      IF g_debug
      THEN
         hr_utility.set_location (
            ' Leaving Function GET_DEFINED_BALANCE_ID',
            250
         );
      END IF;
   END get_defined_balance_id;

   /* ARCHIVE CODE */
   PROCEDURE archive_code (
      p_assignment_action_id   IN   NUMBER,
      p_effective_date         IN   DATE
   )
   IS
      /* Cursor to retrieve Payroll and Prepayment related Ids for Archival */
      CURSOR csr_archive_ids (p_locking_action_id NUMBER)
      IS
         SELECT   prepay_assact.assignment_action_id prepay_assact_id,
                  prepay_assact.assignment_id prepay_assgt_id,
                  prepay_payact.payroll_action_id prepay_payact_id,
                  prepay_payact.effective_date prepay_effective_date,
                  run_assact.assignment_id run_assgt_id,
                  run_assact.assignment_action_id run_assact_id,
                  run_payact.payroll_action_id run_payact_id,
                  run_payact.payroll_id payroll_id
             FROM pay_action_interlocks archive_intlck,
                  pay_assignment_actions prepay_assact,
                  pay_payroll_actions prepay_payact,
                  pay_action_interlocks prepay_intlck,
                  pay_assignment_actions run_assact,
                  pay_payroll_actions run_payact
            WHERE archive_intlck.locking_action_id = p_locking_action_id
              AND prepay_assact.assignment_action_id =
                                              archive_intlck.locked_action_id
              AND prepay_payact.payroll_action_id =
                                              prepay_assact.payroll_action_id
              AND prepay_payact.action_type IN ('U', 'P')
              AND prepay_intlck.locking_action_id =
                                           prepay_assact.assignment_action_id
              AND run_assact.assignment_action_id =
                                               prepay_intlck.locked_action_id
              AND run_payact.payroll_action_id = run_assact.payroll_action_id
              AND run_payact.action_type IN ('Q', 'R')
         ORDER BY prepay_intlck.locking_action_id,
                  prepay_intlck.locked_action_id DESC;

      /* Cursor to retrieve time period information */
      CURSOR csr_period_end_date (p_assact_id NUMBER, p_pay_act_id NUMBER)
      IS
         SELECT ptp.end_date end_date,
                ptp.regular_payment_date regular_payment_date,
                ptp.time_period_id time_period_id,
                ppa.date_earned date_earned,
                ppa.effective_date effective_date, ptp.start_date start_date
           FROM per_time_periods ptp,
                pay_payroll_actions ppa,
                pay_assignment_actions paa
          WHERE ptp.payroll_id = ppa.payroll_id
            AND ppa.payroll_action_id = paa.payroll_action_id
            AND paa.assignment_action_id = p_assact_id
            AND ppa.payroll_action_id = p_pay_act_id
            AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date;

      /* Cursor to retrieve Archive Payroll Action Id */
      CURSOR csr_archive_payact (p_assignment_action_id NUMBER)
      IS
         SELECT payroll_action_id
           FROM pay_assignment_actions
          WHERE assignment_action_id = p_assignment_action_id;

      l_archive_payact_id         NUMBER;
      l_record_count              NUMBER;
      l_actid                     NUMBER;
      l_end_date                  per_time_periods.end_date%TYPE;
      l_pre_end_date              per_time_periods.end_date%TYPE;
      l_reg_payment_date          per_time_periods.regular_payment_date%TYPE;
      l_pre_reg_payment_date      per_time_periods.regular_payment_date%TYPE;
      l_date_earned               pay_payroll_actions.date_earned%TYPE;
      l_pre_date_earned           pay_payroll_actions.date_earned%TYPE;
      l_effective_date            pay_payroll_actions.effective_date%TYPE;
      l_pre_effective_date        pay_payroll_actions.effective_date%TYPE;
      l_run_payact_id             NUMBER;
      l_action_context_id         NUMBER;
      g_archive_pact              NUMBER;
      p_assactid                  NUMBER;
      l_time_period_id            per_time_periods.time_period_id%TYPE;
      l_pre_time_period_id        per_time_periods.time_period_id%TYPE;
      l_start_date                per_time_periods.start_date%TYPE;
      l_pre_start_date            per_time_periods.start_date%TYPE;
      l_fnd_session               NUMBER                                       := 0;
      l_prev_prepay               NUMBER                                       := 0;
      l_action_info_id            pay_action_information.action_information_id%TYPE;
      l_ovn                       pay_action_information.object_version_number%TYPE;
      l_flag                      NUMBER                                       := 0;
      -- The place for Variables which fetches the values to be archived
      l_y_number                  VARCHAR2 (240);
      l_y_number_spare            NUMBER;
      l_accounting_id             NUMBER;
      l_accounting_id_spare       VARCHAR2 (240);
      l_trade_union_number        NUMBER;
      l_local_unit_number         NUMBER;
      l_employee_pin              VARCHAR2 (240);
      l_employee_name             VARCHAR2 (240);
      l_membership_start_date     DATE;
      l_membership_end_date       DATE;

      l_amount_of_payment         NUMBER;
      l_reason_of_payment         VARCHAR2 (240)                             := '00'; -- 00 => Normal Membership fee
      l_tax_year                  NUMBER; -- YYYY format
      l_union_dues                NUMBER;
      l_local_unit_id_fetched     NUMBER;


 -- End of place for Variables which fetches the values to be archived
-- The place for Cursor  which fetches the values to be archived

      --             This cursor fetches Trade Union Details


      CURSOR csr_person_details (
         csr_v_business_group_id   per_all_people_f.business_group_id%TYPE,
         csr_v_local_unit_id       hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT pap.LAST_NAME || ' ' || pap.FIRST_NAME NAME, pap.national_identifier,
                paa.assignment_id assignment_id,
                pap.per_information18 membership_start_date,
                pap.per_information19 membership_end_date
           FROM per_all_people_f pap,
                per_all_assignments_f paa,
                hr_soft_coding_keyflex scl,
                pay_assignment_actions pasa
          WHERE paa.person_id = pap.person_id
            AND pasa.assignment_id = paa.assignment_id
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id
            AND pap.effective_start_date <= g_period_end_date
            AND pap.effective_end_date >= g_period_start_date
            AND paa.effective_start_date <= g_period_end_date
            AND paa.effective_end_date >= g_period_start_date
            AND pap.business_group_id = csr_v_business_group_id
            AND scl.segment2 = csr_v_local_unit_id
            AND pasa.assignment_action_id = p_assignment_action_id;


--                     AND paa.primary_flag = 'Y'
--


      --GROUP BY pap.person_id   ;

      lr_person_details           csr_person_details%ROWTYPE;

      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name   ff_database_items.user_name%TYPE
      )
      IS
         SELECT ue.creator_id
           FROM ff_user_entities ue, ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'FI'
            AND ue.business_group_id IS NULL
            AND ue.creator_type = 'B';

      lr_get_defined_balance_id   csr_get_defined_balance_id%ROWTYPE;

      -- Cursor to pick up segment2
      CURSOR csr_get_segment2
      IS
         SELECT scl.segment2
           FROM per_all_assignments_f paa,
                hr_soft_coding_keyflex scl,
                pay_assignment_actions pasa
          WHERE pasa.assignment_action_id = p_assignment_action_id
            AND pasa.assignment_id = paa.assignment_id
            AND scl.soft_coding_keyflex_id = paa.soft_coding_keyflex_id;


--            AND paa.primary_flag = 'Y';

      lr_get_segment2             csr_get_segment2%ROWTYPE;

      l_union_per_le        VARCHAR2 (100);
      l_union_per_lu        VARCHAR2 (100);
      l_negative_per_lu         VARCHAR2 (100);
      l_negative_per_le         VARCHAR2 (100);
      l_Sign_of_payment  VARCHAR2(1);
   -- End of Cursors

   -- End of place for Cursor  which fetches the values to be archived

   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (' Entering Procedure ARCHIVE_CODE', 380);
      END IF;

      IF g_archive = 'Y'
      THEN

--
--
--
         fnd_file.put_line (fnd_file.LOG, 'Entering  ARCHIVE_CODE  ');

--Insert your logic to select the data for report over here.

         --Pick up the details belonging to Trade Union


      -- If the g_local_unit_id is null then
      -- from assignment action id find the assignmnet id then segment2 where the local unit is is stored
      -- from there pick up the local unit details from the organization table
         OPEN csr_get_segment2 ();
         FETCH csr_get_segment2 INTO lr_get_segment2;
         CLOSE csr_get_segment2;
         l_local_unit_id_fetched := lr_get_segment2.segment2;
         fnd_file.put_line (
            fnd_file.LOG,
               ' After the Legal  g_local_unit_id  '
            || g_local_unit_id
         );
         fnd_file.put_line (
            fnd_file.LOG,
               '   l_Y_number_spare   '
            || l_y_number_spare
         );
         fnd_file.put_line (
            fnd_file.LOG,
               '   l_Local_unit_number   '
            || l_local_unit_number
         );
         hr_utility.TRACE ('After Local Unit');
         hr_utility.TRACE ('Before Person Record');
         fnd_file.put_line (
            fnd_file.LOG,
               '   g_business_group_id   '
            || g_business_group_id
         );
         fnd_file.put_line (
            fnd_file.LOG,
               '   l_local_unit_id_fetched   '
            || l_local_unit_id_fetched
         );
         fnd_file.put_line (
            fnd_file.LOG,
               '   p_assignment_action_id   '
            || p_assignment_action_id
         );
         fnd_file.put_line (
            fnd_file.LOG,
               '   p_effective_date   '
            || p_effective_date
         );
         OPEN csr_person_details (
            g_business_group_id,
            l_local_unit_id_fetched
         );
         FETCH csr_person_details INTO lr_person_details;
         CLOSE csr_person_details;
         l_employee_name := lr_person_details.NAME;
         l_employee_pin := lr_person_details.national_identifier;
							pay_balance_pkg.set_context('TAX_UNIT_ID',g_legal_employer_id);
							pay_balance_pkg.set_context('LOCAL_UNIT_ID',l_local_unit_id_fetched);
							pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(g_period_end_date));
							pay_balance_pkg.set_context('JURISDICTION_CODE',NULL);
							pay_balance_pkg.set_context('SOURCE_ID',NULL);
							pay_balance_pkg.set_context('TAX_GROUP',NULL);
							pay_balance_pkg.set_context('ORGANIZATION_ID',g_trade_union_id);
					pay_balance_pkg.set_context('ASSIGNMENT_ID',lr_person_details.assignment_id);

if g_period='MONTH' THEN


          OPEN  csr_Get_Defined_Balance_Id( 'CUMULATIVE_TRADE_UNION_MEMBERSHIP_FEES_PER_UNION_LU_MONTH');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

            l_union_per_lu :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>lr_person_details.assignment_id , P_VIRTUAL_DATE =>  g_period_end_date );
          OPEN  csr_Get_Defined_Balance_Id( 'UNION_DUES_NEGATIVE_PAYMENT_PER_UNION_LU_MONTH');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

            l_negative_per_lu :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>lr_person_details.assignment_id , P_VIRTUAL_DATE =>  g_period_end_date );

elsif g_period='BIMONTH' THEN
          OPEN  csr_Get_Defined_Balance_Id( 'CUMULATIVE_TRADE_UNION_MEMBERSHIP_FEES_PER_UNION_LU_BIMONTH');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

            l_union_per_lu :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>lr_person_details.assignment_id , P_VIRTUAL_DATE =>  g_period_end_date );
          OPEN  csr_Get_Defined_Balance_Id( 'UNION_DUES_NEGATIVE_PAYMENT_PER_UNION_LU_BIMONTH');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

            l_negative_per_lu :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>lr_person_details.assignment_id , P_VIRTUAL_DATE =>  g_period_end_date );


elsif g_period='BIWEEK' THEN
          OPEN  csr_Get_Defined_Balance_Id( 'CUMULATIVE_TRADE_UNION_MEMBERSHIP_FEES_PER_UNION_LU_BIWEEK');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

            l_union_per_lu :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>lr_person_details.assignment_id , P_VIRTUAL_DATE =>  g_period_end_date );
          OPEN  csr_Get_Defined_Balance_Id( 'UNION_DUES_NEGATIVE_PAYMENT_PER_UNION_LU_BIWEEK');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

            l_negative_per_lu :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>lr_person_details.assignment_id , P_VIRTUAL_DATE =>  g_period_end_date );


elsif g_period='QUARTER' THEN
          OPEN  csr_Get_Defined_Balance_Id( 'CUMULATIVE_TRADE_UNION_MEMBERSHIP_FEES_PER_UNION_LU_QUARTER');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

            l_union_per_lu :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>lr_person_details.assignment_id , P_VIRTUAL_DATE =>  g_period_end_date );
          OPEN  csr_Get_Defined_Balance_Id( 'UNION_DUES_NEGATIVE_PAYMENT_PER_UNION_LU_QUARTER');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

            l_negative_per_lu :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>lr_person_details.assignment_id , P_VIRTUAL_DATE =>  g_period_end_date );


      END IF;


            -- Pick up the defined balance id belonging to CUMULATIVE_TRADE_UNION_MEMBERSHIP_FEES_PER_PTD
-- End of Pickingup the Data
--   l_Union_Dues := pay_balance_pkg.get_value(lr_Get_Defined_Balance_Id.creator_id, lr_Person_Details.assignment_id,p_effective_date);

                     IF l_negative_per_lu > 0
                     THEN
                        l_Sign_of_payment := '-';
                     ELSE
                        l_Sign_of_payment :='+';
                     END IF;


         BEGIN
            SELECT 1
              INTO l_flag
              FROM pay_action_information
             WHERE action_information_category = 'EMEA REPORT INFORMATION'
               AND action_information1 = 'PYFIUMFR'
               AND action_information2 = 'PER'
               AND action_context_id = p_assignment_action_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               pay_action_information_api.create_action_information (
                  p_action_information_id=> l_action_info_id,
                  p_action_context_id=> p_assignment_action_id,
                  p_action_context_type=> 'AAP',
                  p_object_version_number=> l_ovn,
                  p_effective_date=> l_effective_date,
                  p_source_id=> NULL,
                  p_source_text=> NULL,
                  p_action_information_category=> 'EMEA REPORT INFORMATION',
                  p_action_information1=> 'PYFIUMFR',
                  p_action_information2=> 'PER',
                  p_action_information3=> l_local_unit_id_fetched,
                  p_action_information4=> lr_person_details.national_identifier,
                  p_action_information5=> lr_person_details.NAME,
                  p_action_information6=> (lr_person_details.membership_start_date),
                  p_action_information7=> (lr_person_details.membership_end_date),
                  p_action_information8=> fnd_number.number_to_canonical(l_union_per_lu),
                  p_action_information9=> l_Sign_of_payment,
                  p_action_information10=> NULL,
                  p_action_information11=> NULL,
                  p_action_information12=> NULL,
                  p_action_information13=> NULL,
                  p_action_information14=> NULL,
                  p_action_information15=> NULL,
                  p_action_information16=> NULL,
                  p_action_information17=> NULL,
                  p_action_information18=> NULL,
                  p_action_information19=> NULL,
                  p_action_information20=> NULL,
                  p_action_information21=> NULL,
                  p_action_information22=> NULL,
                  p_action_information23=> NULL,
                  p_action_information24=> NULL,
                  p_action_information25=> NULL,
                  p_action_information26=> NULL,
                  p_action_information27=> NULL --date from srs req
                                               ,
                  p_action_information28=> NULL,
                  p_action_information29=> NULL,
                  p_action_information30=> NULL
               );
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF; ---ARCHIVE=YES


--
--
--
 --END LOOP;
      IF g_debug
      THEN
         hr_utility.set_location (' Leaving Procedure ARCHIVE_CODE', 390);
      END IF;
   END archive_code;
END pay_fi_archive_umfr;

/
