--------------------------------------------------------
--  DDL for Package Body PAY_FI_PAYLIST_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_PAYLIST_ARCHIVE" AS
   /* $Header: pyfipayla.pkb 120.2 2006/04/06 00:58:17 dragarwa noship $ */
   g_debug                   BOOLEAN        := hr_utility.debug_enabled;

   TYPE lock_rec IS RECORD (
      archive_assact_id             NUMBER);

   TYPE lock_table IS TABLE OF lock_rec
      INDEX BY BINARY_INTEGER;

   g_lock_table              lock_table;
   g_index                   NUMBER         := -1;
   g_index_assact            NUMBER         := -1;
   g_index_bal               NUMBER         := -1;
   g_package                 VARCHAR2 (33)  := ' PAY_FI_PAYLIST_ARCHIVE.';
   g_run_payroll_action_id       NUMBER;
   g_arc_payroll_action_id   NUMBER;

-- Globals to pick up all the parameter
   g_business_group_id       NUMBER;
   g_effective_date          DATE;
   g_trade_union_id          NUMBER;
   g_legal_employer_id       NUMBER;
   g_start_date              DATE;
   g_payroll_id              NUMBER;
   g_pay_period_id           NUMBER;
   g_pay_period              VARCHAR2 (240);
   g_payroll                 VARCHAR2 (240);
   g_pay_period_end_date     DATE;
   g_legal_employer_name     VARCHAR2 (240);

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
      p_business_group_id   OUT NOCOPY      NUMBER,
      p_start_date          OUT NOCOPY      DATE,
      p_effective_date      OUT NOCOPY      DATE,
      --p_legal_employer_id   OUT NOCOPY      NUMBER,
      p_payroll_id          OUT NOCOPY      NUMBER,
      p_run_payroll_action_id       OUT NOCOPY      NUMBER,
      p_archive             OUT NOCOPY      VARCHAR2
   )
   IS
      --
      CURSOR csr_parameter_info (p_payroll_action_id NUMBER)
      IS
         SELECT pay_fi_archive_umfr.get_parameter (
                   legislative_parameters,
                   'ARCHIVE'
                )
                      ARCHIVE,
                TO_NUMBER (
                   pay_fi_archive_umfr.get_parameter (
                      legislative_parameters,
                      'PAYROLL_ID'
                   )
                )
                      payroll_id,
                TO_NUMBER (
                   pay_fi_archive_umfr.get_parameter (
                      legislative_parameters,
                      'PAYROLL_ACTION_ID'
                   )
                )
                      RUN_payroll_action_id,
                start_date, effective_date effective_date,
                business_group_id bg_id
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_payroll_action_id;

      lr_parameter_info   csr_parameter_info%ROWTYPE;
      l_proc              VARCHAR2 (240)
                                      :=    g_package
                                         || ' GET_ALL_PARAMETERS ';
   --
   BEGIN
      fnd_file.put_line (
         fnd_file.LOG,
         'Entering Procedure GET_ALL_PARAMETER '
      );
      fnd_file.put_line (
         fnd_file.LOG,
            'Payroill Action iD   '
         || p_RUN_payroll_action_id
      );
      OPEN csr_parameter_info (p_payroll_action_id);
      --FETCH csr_parameter_info into lr_parameter_info;
      FETCH csr_parameter_info INTO p_archive,
                                    p_payroll_id,
                                    p_run_payroll_action_id,
                                    p_start_date,
                                    p_effective_date,
                                    p_business_group_id;
      CLOSE csr_parameter_info;
      fnd_file.put_line (fnd_file.LOG, 'After  csr_parameter_info in  ');
      fnd_file.put_line (fnd_file.LOG,    'archive='
                                       || p_archive);

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

/*      CURSOR csr_legal_employer_details (
         csr_v_legal_employer_id   hr_organization_information.organization_id%TYPE
      )
      IS
         SELECT hou.NAME, hoi.org_information1, hoi.org_information8
           FROM hr_organization_information hoi, hr_organization_units hou
          WHERE org_information_context = 'FI_LEGAL_EMPLOYER_DETAILS'
            AND hoi.organization_id = hou.organization_id
            AND hou.organization_id = csr_v_legal_employer_id;

      lr_legal_employer_details   csr_legal_employer_details%ROWTYPE;
*/

      CURSOR csr_time_period_details (
         csr_v_payroll_action_id   pay_payroll_actions.payroll_action_id%TYPE
      )
      IS
      		  select papf.payroll_name,ptp.end_date , ptp.period_name ,
              ptp.regular_payment_date from pay_payroll_actions ppa,per_time_periods ptp,pay_all_payrolls_f papf
		  where ptp.time_period_id=ppa.time_period_id
		  and ppa.PAYROLL_ID=papf.PAYROLL_ID
		  and ppa.payroll_action_id=csr_v_payroll_action_id;


      lr_time_period_details      csr_time_period_details%ROWTYPE;
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
      get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_start_date,
         g_effective_date,
         g_payroll_id,
         g_run_payroll_action_id,
         g_archive
      );

      IF g_archive = 'Y'
      THEN
         -- Pick up the details belonging to Legal Employer Details
/*         OPEN csr_legal_employer_details (g_legal_employer_id);
         FETCH csr_legal_employer_details INTO lr_legal_employer_details;
         CLOSE csr_legal_employer_details;*/
         OPEN csr_time_period_details (g_run_payroll_action_id);
         FETCH csr_time_period_details INTO lr_time_period_details;
         CLOSE csr_time_period_details;
         g_pay_period_end_date := lr_time_period_details.end_date;
         pay_action_information_api.create_action_information (
            p_action_information_id=> l_action_info_id,
            p_action_context_id=> p_payroll_action_id,
            p_action_context_type=> 'PA',
            p_object_version_number=> l_ovn,
            p_effective_date=> g_effective_date,
            p_source_id=> NULL,
            p_source_text=> NULL,
            p_action_information_category=> 'EMEA REPORT DETAILS',
            p_action_information1=> 'PYFIPAYL',
            p_action_information2=> g_payroll_id ,
            p_action_information3=> g_run_payroll_action_id,
            p_action_information4=> lr_time_period_details.Payroll_name,
            p_action_information5=> lr_time_period_details.period_name,
            p_action_information6=> fnd_date.date_to_canonical (
                        lr_time_period_details.regular_payment_date
                     ),
            p_action_information7=> fnd_date.date_to_canonical (
                        lr_time_period_details.end_date
                     ),
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
         p_payroll_action_id     NUMBER,
         p_start_person          NUMBER,
         p_end_person            NUMBER,
         p_run_payroll_action_id NUMBER,
         l_bussiness_group_id    NUMBER


--         p_chunk                NUMBER
      )
      IS
      SELECT   act.assignment_id assignment_id,
               act.assignment_action_id run_action_id,
               act1.assignment_action_id prepaid_action_id
             FROM pay_payroll_actions appa,
                  pay_payroll_actions appa2,
                  pay_assignment_actions act,
                  pay_assignment_actions act1,
                  pay_action_interlocks pai,
                  per_all_assignments_f paaf
            WHERE  appa.payroll_action_id=p_run_payroll_action_id
			 AND appa.action_type IN ('R', 'Q')
			   AND act.payroll_action_id = appa.payroll_action_id
              AND act.source_action_id IS NULL -- Master Action
              AND act.action_status = 'C' -- Completed
              AND act.assignment_action_id = pai.locked_action_id
              AND act1.assignment_action_id = pai.locking_action_id
              AND act1.action_status = 'C' -- Completed
              AND act1.payroll_action_id = appa2.payroll_action_id
              AND appa2.action_type IN ('P', 'U')
              and paaf.assignment_id=act.assignment_id
              and paaf.person_id  BETWEEN p_start_person
			    AND     p_end_person    ;


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
      l_assignment             NUMBER;
   BEGIN
      IF g_debug
      THEN
         hr_utility.set_location (
            ' Entering Procedure ASSIGNMENT_ACTION_CODE',
            60
         );
      END IF;
      get_all_parameters (
         p_payroll_action_id,
         g_business_group_id,
         g_start_date,
         g_effective_date,
         g_payroll_id,
         g_run_payroll_action_id,
         g_archive
      );

      fnd_file.put_line (fnd_file.LOG, ' ');
      fnd_file.put_line (
         fnd_file.LOG,
            'Parameter P_Start_person    '
         || p_start_person
      );
      fnd_file.put_line (
         fnd_file.LOG,
            'Paramter  P_end_personn  '
         || p_end_person
      );
      fnd_file.put_line (
         fnd_file.LOG,
            'Paramter  P_end_personn  '
         || p_end_person
      );
      fnd_file.put_line (
         fnd_file.LOG,
            'Paramter  P_end_personn  '
         || p_end_person
      );
      fnd_file.put_line (
         fnd_file.LOG,
            'g_run_payroll_action_id'
         || g_run_payroll_action_id
      );

      IF g_archive = 'Y'
      THEN
         l_prepay_action_id := 0;

         l_assignment := 0;
         fnd_file.put_line (fnd_file.LOG, ' Before the Locking Cursor ');

         -- this is for all the person's assignment actionid under the selected legal employer
         FOR rec_prepaid_assignments IN
             csr_prepaid_assignments (
                p_payroll_action_id,
                p_start_person,
                p_end_person,
                g_run_payroll_action_id,
                g_business_group_id
             )
         LOOP
            fnd_file.put_line (
               fnd_file.LOG,
               ' Inside the Csr Prepaid Cursor '
            );


            IF l_assignment <> rec_prepaid_assignments.assignment_id

--            IF l_prepay_action_id <>
  --                                  rec_prepaid_assignments.prepaid_action_id
            THEN
               SELECT pay_assignment_actions_s.NEXTVAL
                 INTO l_actid
                 FROM DUAL;

               --
               g_index_assact :=   g_index_assact
                                 + 1;
               g_lock_table (g_index_assact).archive_assact_id := l_actid;
                                                       /* For Element archival */
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
--            l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;

            l_assignment := rec_prepaid_assignments.assignment_id;
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

   /* INITIALIZATION CODE */
   PROCEDURE initialization_code (p_payroll_action_id IN NUMBER)
   IS
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

   /* ARCHIVE CODE */
   PROCEDURE archive_code (
      p_assignment_action_id   IN   NUMBER,
      p_effective_date         IN   DATE
   )
   IS
      /* Cursor to retrieve Payroll and Prepayment related Ids for Archival */

      /* Cursor to retrieve Archive Payroll Action Id */

      l_archive_payact_id       NUMBER;
      l_record_count            NUMBER;
      l_actid                   NUMBER;
      l_end_date                per_time_periods.end_date%TYPE;
      l_pre_end_date            per_time_periods.end_date%TYPE;
      l_reg_payment_date        per_time_periods.regular_payment_date%TYPE;
      l_pre_reg_payment_date    per_time_periods.regular_payment_date%TYPE;
      l_date_earned             pay_payroll_actions.date_earned%TYPE;
      l_pre_date_earned         pay_payroll_actions.date_earned%TYPE;
      l_effective_date          pay_payroll_actions.effective_date%TYPE;
      l_pre_effective_date      pay_payroll_actions.effective_date%TYPE;
      l_run_payact_id           NUMBER;
      l_action_context_id       NUMBER;
      g_archive_pact            NUMBER;
      p_assactid                NUMBER;
      l_time_period_id          per_time_periods.time_period_id%TYPE;
      l_pre_time_period_id      per_time_periods.time_period_id%TYPE;
      l_start_date              per_time_periods.start_date%TYPE;
      l_pre_start_date          per_time_periods.start_date%TYPE;
      l_fnd_session             NUMBER                                         := 0;
      l_prev_prepay             NUMBER                                         := 0;
      l_action_info_id          pay_action_information.action_information_id%TYPE;
      l_ovn                     pay_action_information.object_version_number%TYPE;
      l_flag                    NUMBER                                         := 0;
      -- The place for Variables which fetches the values to be archived
      l_y_number                VARCHAR2 (240);
      l_y_number_spare          NUMBER;
      l_accounting_id           NUMBER;
      l_accounting_id_spare     VARCHAR2 (240);
      l_trade_union_number      NUMBER;
      l_local_unit_number       NUMBER;
      l_employee_pin            VARCHAR2 (240);
      l_employee_name           VARCHAR2 (240);
      l_membership_start_date   DATE;
      l_membership_end_date     DATE;
      l_amount_of_payment       NUMBER;
      l_reason_of_payment       VARCHAR2 (240)                               := '00'; -- 00 => Normal Membership fee
      l_tax_year                NUMBER; -- YYYY format
      l_union_dues              NUMBER;
      l_local_unit_id_fetched   NUMBER;

      CURSOR csr_person_details (
         csr_v_business_group_id   per_all_people_f.business_group_id%TYPE
      )
      IS
         SELECT Distinct(pap.full_name) NAME,
          PAA.ASSIGNMENT_NUMBER ASSIGNMENT_NUMBER,
              --  pap.national_identifier national_identifier,
                paa.assignment_id assignment_id
           FROM per_all_people_f pap,
                per_all_assignments_f paa,
                pay_assignment_actions pasa
          WHERE paa.person_id = pap.person_id
            AND pasa.assignment_id = paa.assignment_id
            AND pap.business_group_id = csr_v_business_group_id
--            AND g_pay_period_end_date BETWEEN pap.effective_start_date
  --                                        AND pap.effective_end_date
    --        AND g_pay_period_end_date BETWEEN paa.effective_start_date
      --                                    AND paa.effective_end_date
            AND pasa.assignment_action_id = p_assignment_action_id;

      lr_person_details         csr_person_details%ROWTYPE;
      -- Cursor to pick up segment2

--            AND paa.primary_flag = 'Y';


      l_union_per_le            VARCHAR2 (100);

--      l_benefits              VARCHAR2 (100);
      l_negative_per_lu         VARCHAR2 (100);
      l_negative_per_le         VARCHAR2 (100);
      l_sign_of_payment         VARCHAR2 (1);
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
         OPEN csr_person_details (g_business_group_id);
         FETCH csr_person_details INTO lr_person_details;
         CLOSE csr_person_details;
--         l_employee_pin := lr_person_details.national_identifier;
         pay_balance_pkg.set_context ('TAX_UNIT_ID', g_legal_employer_id);
         pay_balance_pkg.set_context (
            'DATE_EARNED',
            fnd_date.date_to_canonical (g_pay_period_end_date)
         );
         pay_balance_pkg.set_context ('JURISDICTION_CODE', NULL);
         pay_balance_pkg.set_context (
            'ASSIGNMENT_ID',
            lr_person_details.assignment_id
         );
         pay_balance_pkg.set_context ('SOURCE_ID', NULL);
         pay_balance_pkg.set_context ('TAX_GROUP', NULL);
         /*   OPEN  csr_Get_Defined_Balance_Id( 'BENEFITS_IN_KIND_PER_LE_PTD');
            FETCH csr_Get_Defined_Balance_Id INTO lr_Get_Defined_Balance_Id;
            CLOSE csr_Get_Defined_Balance_Id;

            l_benefits :=pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID =>lr_Get_Defined_Balance_Id.creator_id, P_ASSIGNMENT_ID =>lr_person_details.assignment_id , P_VIRTUAL_DATE =>  g_pay_period_end_date );
          fnd_file.put_line (
         fnd_file.LOG,
            '  l_benefits'||l_benefits

      );

*/

/*         BEGIN
            SELECT 1
              INTO l_flag
              FROM pay_action_information
             WHERE action_information_category = 'EMEA REPORT INFORMATION'
               AND action_information1 = 'PYFIUMFR'
               AND action_information2 = 'PER'
               AND action_context_id = p_assignment_action_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN*/

         pay_action_information_api.create_action_information (
            p_action_information_id=> l_action_info_id,
            p_action_context_id=> p_assignment_action_id,
            p_action_context_type=> 'AAP',
            p_object_version_number=> l_ovn,
            p_effective_date=> p_effective_date,
            p_source_id=> NULL,
            p_source_text=> NULL,
            p_action_information_category=> 'EMEA REPORT INFORMATION',
            p_action_information1=> 'PYFIPAYL',
            p_action_information2=> 'ASG',
            p_action_information3=> lr_person_details.NAME,
            p_action_information4=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'Salary Income',
                        p_assignment_action_id
                     )),
            p_action_information5=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'Benefits in Kind',
                        p_assignment_action_id
                     )),
            p_action_information6=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'Insurance Salary Base',
                        p_assignment_action_id
                     )),
            p_action_information7=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'Deductions Before Tax',
                        p_assignment_action_id
                     )),
            p_action_information8=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'Withholding Tax Base',
                        p_assignment_action_id
                     )+get_balance_value (
                        'Tax at Source Base',
                        p_assignment_action_id
                     ))
                     ,
            p_action_information9=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'Withholding Tax',
                        p_assignment_action_id
                     ) +get_balance_value (
                        'Tax at Source',
                        p_assignment_action_id
                     )),
            p_action_information10=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'External Expenses',
                        p_assignment_action_id
                     )),
            p_action_information11=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'Withholding Tax Base',
                        p_assignment_action_id
                     )+      get_balance_value ('Tax at Source Base', p_assignment_action_id  )+
get_balance_value ('Deductions Before Tax', p_assignment_action_id  )-
(get_balance_value ('Withholding Tax', p_assignment_action_id  )+
get_balance_value ('Tax at Source', p_assignment_action_id  ))-
get_balance_value ('Net Pay', p_assignment_action_id  )),

            p_action_information12=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'Net Pay',
                        p_assignment_action_id
                     ) ),
            p_action_information13=> FND_NUMBER.NUMBER_TO_CANONICAL(get_balance_value (
                        'Capital Income Base',
                        p_assignment_action_id
                     )),
            p_action_information14=> lr_person_details.assignment_number,
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

   FUNCTION get_balance_value (
      p_balance_name           IN   VARCHAR2,
      p_assignment_action_id   IN   NUMBER
   )
      RETURN NUMBER
   IS
      CURSOR csr_get_defined_balance_id (
         csr_v_balance_name   ff_database_items.user_name%TYPE
      )
      IS
      SELECT defined_balance_id
  FROM pay_balance_types pbt,
       pay_balance_dimensions pbd,
       pay_defined_balances pdb
 WHERE pbt.balance_name =  csr_v_balance_name
   AND pbt.legislation_code = 'FI'
   AND pbt.balance_type_id = pdb.balance_type_id
   AND pbd.database_item_suffix = '_ASG_PTD'
   AND pbd.legislation_code = 'FI'
   AND pbd.balance_dimension_id = pdb.balance_dimension_id
  and pdb.legislation_code = 'FI';

      CURSOR csr_get_run_ass_action_id (
         csr_v_ass_action_id  pay_assignment_actions.assignment_action_id%TYPE
      )
      IS
SELECT paa_run.assignment_action_id
  FROM pay_assignment_actions paa_archive, pay_assignment_actions paa_run
 WHERE  paa_run.assignment_id = paa_archive.assignment_id
   AND paa_run.payroll_action_id = g_run_payroll_action_id
   AND paa_archive.assignment_action_id = p_assignment_action_id;
/*         SELECT ue.creator_id
           FROM ff_user_entities ue, ff_database_items di
          WHERE di.user_name = csr_v_balance_name
            AND ue.user_entity_id = di.user_entity_id
            AND ue.legislation_code = 'FI';
--            AND ue.business_group_id IS NULL temporary commented
--            AND ue.creator_type = 'B';
*/
      lr_get_defined_balance_id   NUMBER;
      lr_get_run_ass_action_id  NUMBER;
   BEGIN
      OPEN csr_get_defined_balance_id (p_balance_name);
      FETCH csr_get_defined_balance_id INTO lr_get_defined_balance_id;
      CLOSE csr_get_defined_balance_id;

      OPEN csr_get_run_ass_action_id  (p_assignment_action_id);
      FETCH csr_get_run_ass_action_id  INTO lr_get_run_ass_action_id ;
      CLOSE csr_get_run_ass_action_id ;

 fnd_file.put_line (      fnd_file.LOG,
               'p_balance_name'
            || p_balance_name
         );
 fnd_file.put_line (       fnd_file.LOG,
               'lr_get_defined_balance_id '
            || lr_get_defined_balance_id
         );
 fnd_file.put_line ( fnd_file.LOG,
               'p_assignment_action_id '
            || p_assignment_action_id
         );
 fnd_file.put_line ( fnd_file.LOG,
               'lr_get_run_ass_action_id'
            || lr_get_run_ass_action_id
         );


      RETURN (pay_balance_pkg.get_value (
                 p_defined_balance_id=> lr_get_defined_balance_id,
                 p_assignment_action_id=> lr_get_run_ass_action_id
              )
             );
 /*  EXCEPTION
   WHEN OTHERS THEN

       null;*/
   END get_balance_value;
END pay_fi_paylist_archive;

/
