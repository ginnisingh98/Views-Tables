--------------------------------------------------------
--  DDL for Package PQP_GB_CPX_EXTRACT_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_CPX_EXTRACT_FUNCTIONS" 
--  /* $Header: pqpgbcpx.pkh 120.4.12010000.3 2008/08/05 14:02:04 ubhat ship $ */
AUTHID CURRENT_USER AS

--
-- Debug Variables.
--
   g_proc_name                  VARCHAR2 (61)
                                            := 'pqp_gb_cpx_extract_functions.';
   g_nested_level               NUMBER                                     := 0;
   g_trace                      VARCHAR2 (1)                             := NULL;
   g_next_effective_date        DATE;

--
-- Global Variables
--
   g_business_group_id          NUMBER                                   := NULL;
   g_legislation_code           VARCHAR2 (10)                             := 'GB';
   g_effective_date             DATE;
   g_extract_type               pqp_extract_attributes.ext_dfn_type%TYPE;
   g_extract_udt_name           pay_user_tables.user_table_name%TYPE;
   g_effective_start_date       DATE;
   g_effective_end_date         DATE;
   g_header_system_element      ben_ext_rslt_dtl.val_01%TYPE;
   g_initial_ext_date           DATE;
   g_pension_bal_name           pay_balance_types.balance_name%TYPE;
   g_pension_ele_name           pay_element_types_f.element_name%TYPE;
   g_emp_cont_iv_name           pay_input_values_f.NAME%TYPE;
   g_superann_refno_iv_name     pay_input_values_f.NAME%TYPE;
   g_superann_sal_bal_name      pay_balance_types.balance_name%TYPE;
   g_additional_cont_bal_name   pay_balance_types.balance_name%TYPE;
   g_buyback_cont_bal_name      pay_balance_types.balance_name%TYPE;

   -- Bug Fix 4721921
   g_ni_ele_type_id             NUMBER;
   g_ni_cat_iv_id               NUMBER;
   g_ni_pen_iv_id               NUMBER;
   g_index                      NUMBER;

   TYPE t_number IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE t_varchar2 IS TABLE OF VARCHAR2 (200)
      INDEX BY BINARY_INTEGER;

   TYPE r_ele_entry_details IS RECORD (
      element_type_id               NUMBER,
      element_entry_id              NUMBER,
      effective_start_date          DATE,
      effective_end_date            DATE,
      assignment_id                 NUMBER);

   TYPE t_ele_entry_details IS TABLE OF r_ele_entry_details
      INDEX BY BINARY_INTEGER;

   -- Holds the element entry details for an assignment

   g_ele_entry_details          t_ele_entry_details;
   g_pen_ele_details            t_ele_entry_details;

   TYPE r_ni_ele_details IS RECORD (
      category                      pay_ni_element_entries_v.category%TYPE,
      user_table_id                 NUMBER,
      user_row_id                   NUMBER);

   TYPE t_ni_ele_details IS TABLE OF r_ni_ele_details
      INDEX BY BINARY_INTEGER;

   -- Holds the NI element details
   g_ni_ele_details             t_ni_ele_details;
   -- Holds the eligible secondary assignment id's

   g_secondary_asg_ids          t_number;


--
-- Cursor Definitions
--

   -- Cursor to get extract details from PQP_EXTRACT_ATTRIBUTES table

   CURSOR csr_pqp_extract_attributes
   IS
      SELECT eat.ext_dfn_type, udt.user_table_name
        FROM pqp_extract_attributes eat, pay_user_tables udt
       WHERE eat.ext_dfn_id = ben_ext_thread.g_ext_dfn_id
         AND udt.user_table_id(+) = eat.ext_user_table_id;

   -- Cursor to get balance type id for a balance

   CURSOR csr_get_pay_bal_id (c_balance_name VARCHAR2)
   IS
      SELECT balance_type_id
        FROM pay_balance_types
       WHERE balance_name = c_balance_name
         AND (   (business_group_id IS NULL AND legislation_code IS NULL)
              OR (    business_group_id IS NULL
                  AND legislation_code = g_legislation_code
                 )
              OR (business_group_id = g_business_group_id)
             );

   g_additional_cont_bal_id     pay_balance_types.balance_type_id%TYPE;
   g_pension_bal_id             pay_balance_types.balance_type_id%TYPE;
   g_superann_sal_bal_id        pay_balance_types.balance_type_id%TYPE;
   g_buyback_cont_bal_id        pay_balance_types.balance_type_id%TYPE;

   -- Cursor to get element type id from an element name

   CURSOR csr_get_pay_ele_id (c_element_name VARCHAR2, c_effective_date DATE)
   IS
      SELECT element_type_id
        FROM pay_element_types_f
       WHERE element_name = c_element_name
         AND (   (business_group_id IS NULL AND legislation_code IS NULL)
              OR (    business_group_id IS NULL
                  AND legislation_code = g_legislation_code
                 )
              OR (business_group_id = g_business_group_id)
             )
         AND (   c_effective_date BETWEEN effective_start_date
                                      AND effective_end_date
              OR effective_start_date < c_effective_date
             );

   -- Cursor to get input value ids from balance

   CURSOR csr_get_pay_iv_ids_from_bal (
      c_balance_type_id        NUMBER,
      c_effective_start_date   DATE,
      c_effective_end_date     DATE
   )
   IS
      SELECT input_value_id
        FROM pay_balance_feeds_f pbf
       WHERE pbf.balance_type_id = c_balance_type_id
         AND (   pbf.effective_start_date BETWEEN c_effective_start_date
                                              AND c_effective_end_date
              OR pbf.effective_end_date BETWEEN c_effective_start_date
                                            AND c_effective_end_date
              OR c_effective_start_date BETWEEN pbf.effective_start_date
                                            AND pbf.effective_end_date
              OR c_effective_end_date BETWEEN pbf.effective_start_date
                                          AND pbf.effective_end_date
             );

   -- Cursor to get element type ids from Balance/Input values

   CURSOR csr_get_pay_ele_ids_from_bal (c_input_value_id NUMBER)
   IS
      SELECT pet.element_type_id element_type_id
        FROM pay_element_types_f pet, pay_input_values_f piv
       WHERE pet.element_type_id = piv.element_type_id
         AND (   (    pet.business_group_id IS NULL
                  AND pet.legislation_code IS NULL
                 )
              OR (    pet.business_group_id IS NULL
                  AND pet.legislation_code = g_legislation_code
                 )
              OR (pet.business_group_id = g_business_group_id)
             )
         AND piv.input_value_id = c_input_value_id;

   TYPE t_ele_ids_from_bal IS TABLE OF csr_get_pay_ele_ids_from_bal%ROWTYPE
      INDEX BY BINARY_INTEGER;

   -- Holds the pension element ID's

   g_pension_ele_ids            t_ele_ids_from_bal;

   -- Cursor to get input value ids for a given element type id
   -- and input value name

   CURSOR csr_get_pay_iv_id (
      c_element_type_id    NUMBER,
      c_input_value_name   VARCHAR2,
      c_effective_date     DATE
   )
   IS
      SELECT input_value_id
        FROM pay_input_values_f
       WHERE element_type_id = c_element_type_id
         AND NAME = c_input_value_name
         AND (   (business_group_id IS NULL AND legislation_code IS NULL)
              OR (    business_group_id IS NULL
                  AND legislation_code = g_legislation_code
                 )
              OR (business_group_id = g_business_group_id)
             )
         AND (   c_effective_date BETWEEN effective_start_date
                                      AND effective_end_date
              OR effective_start_date < c_effective_date
             );

   -- Cursor to get element entries information for Starters

   CURSOR csr_get_starters_eet_info (
      c_assignment_id          NUMBER,
      c_effective_start_date   DATE,
      c_effective_end_date     DATE
   )
   IS
      SELECT   pet.element_type_id, pee.element_entry_id,
               pee.effective_start_date, pee.effective_end_date
          FROM pay_element_entries_f pee,
               pay_element_links_f pel,
               pay_element_classifications pec,
               pay_element_types_f pet
         WHERE pee.assignment_id = c_assignment_id
           AND pee.entry_type    = 'E'
           AND pee.creation_date BETWEEN c_effective_start_date
                                     AND c_effective_end_date
           AND pel.element_link_id = pee.element_link_id
           AND pel.element_type_id = pet.element_type_id
           AND (   (    pet.business_group_id IS NULL
                    AND pet.legislation_code IS NULL
                   )
                OR (    pet.business_group_id IS NULL
                    AND pet.legislation_code = g_legislation_code
                   )
                OR (pet.business_group_id = g_business_group_id)
               )
           AND pee.effective_start_date BETWEEN pet.effective_start_date
                                            AND pet.effective_end_date
           AND pee.effective_start_date BETWEEN pel.effective_start_date
                                            AND pel.effective_end_date
           AND pet.classification_id = pec.classification_id
           -- Added to improve performance
           AND pec.classification_name = 'Pre Tax Deductions'
           AND pec.legislation_code = g_legislation_code
      ORDER BY pee.effective_start_date DESC;

   -- Cursor to get element entries information

   CURSOR csr_get_eet_info (
      c_assignment_id          NUMBER,
      c_effective_start_date   DATE,
      c_effective_end_date     DATE
   )
   IS
      SELECT   pet.element_type_id, pee.element_entry_id,
               pee.effective_start_date, pee.effective_end_date
          FROM pay_element_entries_f pee,
               pay_element_links_f pel,
               pay_element_classifications pec,
               pay_element_types_f pet
         WHERE pee.assignment_id = c_assignment_id
           AND pee.entry_type    = 'E'
           AND (   pee.effective_start_date BETWEEN c_effective_start_date
                                                AND c_effective_end_date
                OR pee.effective_end_date BETWEEN c_effective_start_date
                                              AND c_effective_end_date
                OR c_effective_start_date BETWEEN pee.effective_start_date
                                              AND pee.effective_end_date
                OR c_effective_end_date BETWEEN pee.effective_start_date
                                            AND pee.effective_end_date
               )
           AND pee.effective_start_date BETWEEN pet.effective_start_date
                                            AND pet.effective_end_date
           AND pee.effective_start_date BETWEEN pel.effective_start_date
                                            AND pel.effective_end_date
           AND pel.element_link_id = pee.element_link_id
           AND pel.element_type_id = pet.element_type_id
           AND (   (    pet.business_group_id IS NULL
                    AND pet.legislation_code IS NULL
                   )
                OR (    pet.business_group_id IS NULL
                    AND pet.legislation_code = g_legislation_code
                   )
                OR (pet.business_group_id = g_business_group_id)
               )
           AND pet.classification_id = pec.classification_id
           -- Added to improve performance
           AND pec.classification_name = 'Pre Tax Deductions'
           AND pec.legislation_code = g_legislation_code
      ORDER BY pee.effective_start_date DESC;

   -- Cursor to get multiple assignment info for a primary
   -- assignment

   CURSOR csr_get_multiple_assignments (c_assignment_id NUMBER)
   IS
      SELECT DISTINCT (pef2.assignment_id) assignment_id
                 FROM per_assignments_f pef, per_assignments_f pef2
                WHERE pef.assignment_id = c_assignment_id
                  AND pef2.person_id = pef.person_id
                  AND pef2.assignment_id <> pef.assignment_id;

   -- Cursor to get element entry value information

   CURSOR csr_get_ele_entry_value (
      c_element_entry_id       NUMBER,
      c_input_value_id         NUMBER,
      c_effective_start_date   DATE,
      c_effective_end_date     DATE
   )
   IS
      SELECT screen_entry_value
        FROM pay_element_entry_values_f
       WHERE element_entry_id = c_element_entry_id
         AND input_value_id = c_input_value_id
         AND effective_start_date = c_effective_start_date
         AND effective_end_date = c_effective_end_date;

  -- Bug Fix 5101756
   -- Cursor to retrieve end_dates from per_time_periods
   CURSOR csr_get_end_date (
      c_assignment_id          NUMBER,
      c_effective_start_date   DATE,
      c_effective_end_date     DATE
   )
   IS
      SELECT DISTINCT (ptp.end_date) end_date
                 FROM per_time_periods ptp,
                      pay_payroll_actions ppa,
                      pay_assignment_actions paa
                WHERE ptp.time_period_id = ppa.time_period_id
                  AND ppa.effective_date BETWEEN ptp.start_date
                                             AND ptp.end_date
                  AND ppa.payroll_action_id = paa.payroll_action_id
--                  AND ppa.effective_date BETWEEN c_effective_start_date
--                                             AND c_effective_end_date
                  AND (ptp.start_date BETWEEN c_effective_start_date
                                          AND c_effective_end_date OR
                       ptp.end_date BETWEEN c_effective_start_date
                                        AND c_effective_end_date OR
                       c_effective_start_date BETWEEN ptp.start_date
                                                  AND ptp.end_date OR
                       c_effective_end_date BETWEEN ptp.start_date
                                                AND ptp.end_date)
                  AND ppa.action_type IN ('R', 'Q', 'I', 'V', 'B')
                  AND NVL (ppa.business_group_id, g_business_group_id) =
                                                          g_business_group_id
                  AND paa.assignment_id = c_assignment_id
             ORDER BY ptp.end_date;

   -- Cursor to retrieve the min effective start date
   -- from NI element entry for a given assignment id and
   -- category

   CURSOR csr_get_ele_ent_min_start_dt (
      c_assignment_id     NUMBER,
      c_category          VARCHAR2
   )
   IS
      SELECT MIN (effective_start_date)
        FROM pay_ni_element_entries_v
       WHERE assignment_id = c_assignment_id
         AND category      = c_category;

   -- Cursor to get user_table_id
   CURSOR csr_get_udt_id (c_user_table_name VARCHAR2)
   IS
      SELECT user_table_id
        FROM pay_user_tables
       WHERE user_table_name = c_user_table_name
         AND (   (    business_group_id IS NULL
                  AND legislation_code = g_legislation_code
                 )
              OR (    business_group_id IS NOT NULL
                  AND business_group_id = g_business_group_id
                 )
             );

   -- Cursor to get user_column_id
   CURSOR csr_get_user_column_id (
      c_user_table_id   NUMBER,
      c_user_col_name   VARCHAR2
   )
   IS
      SELECT user_column_id
        FROM pay_user_columns
       WHERE user_table_id = c_user_table_id
         AND user_column_name = c_user_col_name
         AND (   (business_group_id IS NULL AND legislation_code IS NULL)
              OR (    business_group_id IS NULL
                  AND legislation_code = g_legislation_code
                 )
              OR (business_group_id = g_business_group_id)
             );

   -- Cursor to get user_row_id
   CURSOR csr_get_user_row_id (
      c_user_table_id  NUMBER,
      c_user_row_name  VARCHAR2,
      c_effective_date DATE
   )
   IS
      SELECT user_row_id
        FROM pay_user_rows_f
       WHERE user_table_id = c_user_table_id
         AND row_low_range_or_name = c_user_row_name
         AND c_effective_date BETWEEN effective_start_date
                                  AND effective_end_date
         AND (   (business_group_id IS NULL AND legislation_code IS NULL)
              OR (    business_group_id IS NULL
                  AND legislation_code = g_legislation_code
                 )
              OR (business_group_id = g_business_group_id)
             );

   -- Cursor to retrieve element type id's for NI
   -- elements from UDT

--  CURSOR csr_get_NI_ele_ids
--     (c_user_table_id NUMBER)
--   IS
--   SELECT pet.element_type_id
--         ,pet.element_name
--     FROM pay_user_rows_f       pur
--         ,pay_element_types_f   pet
--   WHERE  pet.element_name    = pur.row_low_range_or_name
--     AND  NVL(pet.business_group_id, g_business_group_id)
--                              = g_business_group_id
--     AND  pur.user_table_id   = c_user_table_id
--     AND  NVL(pur.business_group_id, g_business_group_id)
--                              = g_business_group_id;

   -- Cursor to retrieve the NI element id's from
   -- the UDT

   CURSOR csr_get_ni_ele_ids_from_udt (
      c_user_table_id    NUMBER,
      c_user_column_id   NUMBER,
      c_effective_date   DATE
   )
   IS
      SELECT pur.user_row_id
            ,SUBSTR(pur.row_low_range_or_name, 4, 1) category
        FROM pay_user_column_instances_f puci,
             pay_user_rows_f pur
       WHERE pur.user_table_id = c_user_table_id
         AND pur.user_row_id = puci.user_row_id
         AND puci.user_column_id = c_user_column_id
         AND puci.business_group_id = g_business_group_id
         AND (c_effective_date BETWEEN puci.effective_start_date
                                   AND puci.effective_end_date
             );

   TYPE t_ni_ele_ids IS TABLE OF csr_get_ni_ele_ids_from_udt%ROWTYPE
      INDEX BY BINARY_INTEGER;

   -- Holds the NI Contracted out element details

   g_ni_cont_out_ele_ids        t_ni_ele_ids;

   -- Cursor to retrieve the latest NI element
   -- assigned to the employee from the NI list
   -- available from the UDT

--   CURSOR csr_get_NI_ele_entry_info
--     (c_assignment_id    NUMBER
--     ,c_element_type_id  NUMBER
--     )
--   IS
--   SELECT pee.element_entry_id
--         ,pee.effective_start_date
--         ,pee.effective_end_date
--     FROM pay_element_entries_f pee
--         ,pay_element_links_f   pel
--   WHERE  pee.assignment_id   = c_assignment_id
--     AND  pee.element_link_id = pel.element_link_id
--     AND  pel.element_type_id = c_element_type_id
--     AND  pee.effective_start_date =
--           (SELECT MAX(effective_start_date)
--              FROM pay_element_entries
--             WHERE element_link_id = pee.element_link_id
--               AND assignment_id   = c_assignment_id
--           );


   -- Cursor to get NI element names from the UDT

   CURSOR csr_get_ni_ele_name (c_user_table_id NUMBER)
   IS
      SELECT pur.user_row_id, pur.row_low_range_or_name
        FROM pay_user_rows_f pur
       WHERE pur.user_table_id = c_user_table_id
         AND (   (    pur.business_group_id IS NULL
                  AND pur.legislation_code IS NULL
                 )
              OR (    pur.business_group_id IS NULL
                  AND pur.legislation_code = g_legislation_code
                 )
              OR (pur.business_group_id = g_business_group_id)
             );

   -- Cursor to get the active or most recent NI
   -- element assigned to employee
   -- Bug Fix 4721921 Modify cursor

--    CURSOR csr_get_asg_ni_ele_info (
--       c_assignment_id     NUMBER,
--       c_effective_date    DATE
--    )
--    IS
--       SELECT category
--         FROM pay_ni_element_entries_v
--        WHERE assignment_id = c_assignment_id
--          AND (   c_effective_date BETWEEN effective_start_date
--                                       AND effective_end_date
--               OR c_effective_date > effective_start_date
--              )
--        ORDER BY effective_start_date DESC;


--           AND pet.element_name = pur.row_low_range_or_name
--           AND NVL (pet.business_group_id, g_business_group_id) =
--                                                          g_business_group_id
--           AND pur.user_table_id = c_user_table_id
--           AND NVL (pur.business_group_id, g_business_group_id) =
--                                                          g_business_group_id

   CURSOR csr_get_asg_ni_ele_info (
     c_assignment_id   NUMBER,
     c_element_type_id NUMBER,
     c_effective_date  DATE
   )
   IS
         SELECT   pee.element_entry_id, pee.effective_start_date
                 ,pee.effective_end_date
             FROM pay_element_entries_f pee, pay_element_links_f pel
            WHERE pee.assignment_id = c_assignment_id
              AND pee.entry_type = 'E'
              AND pee.element_link_id = pel.element_link_id
              AND c_effective_date BETWEEN pee.effective_start_date
                                       AND pee.effective_end_date
              AND pel.element_type_id = c_element_type_id
              AND c_effective_date BETWEEN pel.effective_start_date
                                       AND pel.effective_end_date
         ORDER BY pee.effective_start_date DESC;


   -- Cursor to get employment category from assignment table

   CURSOR csr_get_asg_employment_cat (
      c_assignment_id    NUMBER,
      c_effective_date   DATE
   )
   IS
      SELECT   employment_category
          FROM per_all_assignments_f
         WHERE assignment_id = c_assignment_id
           AND c_effective_date BETWEEN effective_start_date
                                    AND effective_end_date
      ORDER BY effective_start_date DESC;

   -- CURSOR to get person_id and assignment_number
   CURSOR csr_get_asg_details (c_assignment_id NUMBER, c_effective_date DATE)
   IS
      SELECT   person_id, assignment_number, employee_category
          FROM per_all_assignments_f
         WHERE assignment_id = c_assignment_id
           AND c_effective_date BETWEEN effective_start_date
                                    AND effective_end_date
      ORDER BY effective_start_date DESC;

   TYPE t_asg_details IS TABLE OF csr_get_asg_details%ROWTYPE
      INDEX BY BINARY_INTEGER;

   -- Holds the assignment details

   g_asg_details                t_asg_details;

   -- CURSOR to get marital status from person table

   CURSOR csr_get_marital_status (c_person_id NUMBER, c_effective_date DATE)
   IS
      SELECT   marital_status
          FROM per_people_f pep
         WHERE pep.person_id = c_person_id
           AND c_effective_date BETWEEN pep.effective_start_date
                                    AND pep.effective_end_date
      ORDER BY pep.effective_start_date DESC;

   -- CURSOR to get spouses details

   CURSOR csr_get_spouses_details (c_person_id NUMBER, c_effective_date DATE)
   IS
      SELECT   pep.date_of_birth, pep.first_name, pep.middle_names
          FROM per_people_f pep, per_contact_relationships pcr
         WHERE pcr.person_id = c_person_id
           AND pcr.contact_type = 'S'
           AND c_effective_date BETWEEN NVL (
                                           pcr.date_start,
                                           c_effective_date
                                        )
                                    AND NVL (pcr.date_end, c_effective_date)
           AND pep.person_id = pcr.contact_person_id
           AND c_effective_date BETWEEN pep.effective_start_date
                                    AND pep.effective_end_date
      ORDER BY pep.effective_start_date DESC;

   -- Cursor to get udt col name information

   CURSOR csr_get_user_col_name (
      c_user_table_id    NUMBER,
      c_user_row_id      NUMBER,
      c_effective_date   DATE
   )
   IS
      SELECT puc.user_column_name
        FROM pay_user_columns puc, pay_user_column_instances_f puci
       WHERE puci.user_row_id = c_user_row_id
         AND puci.user_column_id = puc.user_column_id
         AND puc.user_table_id = c_user_table_id
         AND puci.business_group_id = g_business_group_id
         AND c_effective_date BETWEEN puci.effective_start_date
                                  AND puci.effective_end_date;

   -- Cursor to get the run result value sum for an element
   CURSOR csr_get_rresult_value (
      c_assignment_action_id   NUMBER,
      c_element_type_id        NUMBER,
      c_input_value_id         NUMBER
   )
   IS
      SELECT NVL (SUM (result_value), 0) result_value
        FROM pay_run_result_values target,
             pay_run_results rr,
             pay_payroll_actions pact,
             pay_assignment_actions assact,
             pay_payroll_actions bact,
             pay_assignment_actions bal_assact
       WHERE bal_assact.assignment_action_id = c_assignment_action_id
         AND bal_assact.payroll_action_id = bact.payroll_action_id
         AND NVL (target.result_value, '0') <> '0'
         AND target.run_result_id = rr.run_result_id
         AND target.input_value_id = c_input_value_id
         AND rr.assignment_action_id = assact.assignment_action_id
         AND rr.element_type_id = c_element_type_id
         AND assact.payroll_action_id = pact.payroll_action_id
         AND rr.status IN ('P', 'PA')
         AND pact.time_period_id = bact.time_period_id
         AND assact.action_sequence <= bal_assact.action_sequence
         AND assact.assignment_id = bal_assact.assignment_id;

   -- Cursor to get the translated code from the translation UDT
   CURSOR csr_get_udt_translated_code (
      c_user_table_id     NUMBER,
      c_effective_date    DATE,
      c_asg_user_col_id   NUMBER,
      c_ext_user_col_id   NUMBER,
      c_value             VARCHAR2
   )
   IS
      SELECT extv.VALUE ext_value
        FROM pay_user_rows_f urws,
             pay_user_column_instances_f asgv,
             pay_user_column_instances_f extv
       WHERE urws.user_table_id = c_user_table_id
         AND c_effective_date BETWEEN urws.effective_start_date
                                  AND urws.effective_end_date
         AND asgv.user_column_id = c_asg_user_col_id
         AND c_effective_date BETWEEN asgv.effective_start_date
                                  AND asgv.effective_end_date
         AND extv.user_column_id = c_ext_user_col_id
         AND c_effective_date BETWEEN extv.effective_start_date
                                  AND extv.effective_end_date
         AND asgv.user_row_id = urws.user_row_id
         AND extv.user_row_id = asgv.user_row_id
         AND asgv.VALUE = c_value;

   --
   -- Added for Hour Change report
   --

   -- Cursor to get FTE value
   CURSOR csr_get_fte_value (c_assignment_id NUMBER, c_effective_date DATE)
   IS
      SELECT   VALUE fte
          FROM per_assignment_budget_values_f
         WHERE assignment_id = c_assignment_id
           AND unit = 'FTE'
           AND c_effective_date BETWEEN effective_start_date
                                    AND effective_end_date
      ORDER BY effective_start_date DESC;

   --
-- Cursor to fetch the record if of the details record, but not the hidden one
-- WARNING : This works only if there is one displayed detail record.
-- Do we need to raise an error if there are 2 diplayed detail records??
-- If yes, then Fetch ... , check .. and raise error
-- Alternatively, modify the cursor to return the required id by querying on name.
  CURSOR csr_ext_rcd_id(p_hide_flag       IN VARCHAR2
                       ,p_rcd_type_cd     IN VARCHAR2
                       ) IS
  SELECT rcd.ext_rcd_id
  FROM ben_ext_rcd rcd
      ,ben_ext_rcd_in_file RinF
      ,ben_ext_dfn dfn
  WHERE dfn.ext_dfn_id = ben_ext_thread.g_ext_dfn_id
    AND RinF.ext_file_id = dfn.ext_file_id
    AND RinF.hide_flag = p_hide_flag
    AND RinF.ext_rcd_id = rcd.ext_rcd_id
    AND rcd.rcd_type_cd = p_rcd_type_cd;

--
-- Procedures and Functions
--

-- FUNCTIONS (Private)

-- Function set_periodic_run_dates
   FUNCTION set_periodic_run_dates (
      p_error_number   OUT NOCOPY   NUMBER,
      p_error_text     OUT NOCOPY   VARCHAR2
   )
      RETURN NUMBER;


-- Function Get Input Value Id
   FUNCTION get_input_value_id (
      p_element_type_id    IN   NUMBER,
      p_input_value_name   IN   VARCHAR2,
      p_effective_date     IN   DATE
   )
      RETURN NUMBER;


-- Function Get Pay Balance ID From Name

   FUNCTION get_pay_bal_id (p_balance_name IN VARCHAR2)
      RETURN NUMBER;


-- Function Fetch_CPX_UDT_details
   FUNCTION fetch_cpx_udt_details (
      p_error_number   OUT NOCOPY   NUMBER,
      p_error_text     OUT NOCOPY   VARCHAR2
   )
      RETURN NUMBER;


-- Function set_extract_globals
   FUNCTION set_extract_globals (
      p_assignment_id       IN              NUMBER,
      p_business_group_id   IN              NUMBER,
      p_effective_date      IN              DATE,
      p_error_number        OUT NOCOPY      NUMBER,
      p_error_text          OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;


-- Function chk_is_employee_a_starter
   FUNCTION chk_is_employee_a_starter (
      p_assignment_id          IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN VARCHAR2;


-- Function get_ele_entry_value
   FUNCTION get_ele_entry_value (
      p_element_entry_id       IN   NUMBER,
      p_input_value_id         IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN VARCHAR2;


-- Function Get Pay Element Ids From Balance
   FUNCTION get_pay_ele_ids_from_bal (
      p_balance_type_id        IN              NUMBER,
      p_effective_start_date   IN              DATE,
      p_effective_end_date     IN              DATE,
      p_tab_ele_ids            OUT NOCOPY      t_ele_ids_from_bal,
      p_error_number           OUT NOCOPY      NUMBER,
      p_error_text             OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;


-- Function get_udt_id
   FUNCTION get_udt_id (p_udt_name IN VARCHAR2)
      RETURN NUMBER;


-- Function get_user_column_name
   FUNCTION get_user_column_name (
      p_user_table_id    IN   NUMBER,
      p_user_row_id      IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN t_varchar2;


-- Function get_user_column_id
   FUNCTION get_user_column_id (
      p_user_table_id   IN   NUMBER,
      p_user_col_name   IN   VARCHAR2
   )
      RETURN NUMBER;


-- Function get_NI_cont_out_ele_details
   FUNCTION get_ni_cont_out_ele_details (
      p_error_number   OUT NOCOPY   NUMBER,
      p_error_text     OUT NOCOPY   VARCHAR2
   )
      RETURN NUMBER;


-- Function get_asg_employment_cat
   FUNCTION get_asg_employment_cat (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2;


-- Function get_part_time_indicator
   FUNCTION get_part_time_indicator (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2;


-- Function get_marital_status
   FUNCTION get_marital_status (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2;


-- Function get_NI_indicator
   FUNCTION get_ni_indicator (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2;


-- Function get_asg_bal_value
   FUNCTION get_asg_bal_value (
      p_assignment_id          IN   NUMBER,
      p_balance_type_id        IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER;


-- Function get_person_bal_value
   FUNCTION get_person_bal_value (
      p_assignment_id          IN   NUMBER,
      p_balance_type_id        IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER;


-- Function get_remuneration_from_bal
   FUNCTION get_remuneration_from_bal (
      p_assignment_id          IN   NUMBER,
      p_balance_type_id        IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN VARCHAR2;


-- Function get_balance_value
   FUNCTION get_balance_value (
      p_assignment_id          IN   NUMBER,
      p_balance_type_id        IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER;


-- Added for Annual
--
-- Function chk_is_employee_a_member
   FUNCTION chk_is_employee_a_member (
      p_assignment_id          IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN VARCHAR2;


-- Function get_latest_action_id
   FUNCTION get_latest_action_id (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN NUMBER;


-- Function get_asg_ele_rresult_value
   FUNCTION get_asg_ele_rresult_value (
      p_assignment_id          IN   NUMBER,
      p_element_type_id        IN   NUMBER,
      p_input_value_id         IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER;


-- Function get_person_ele_rresult_value
   FUNCTION get_person_ele_rresult_value (
      p_assignment_id          IN   NUMBER,
      p_element_type_id        IN   NUMBER,
      p_input_value_id         IN   NUMBER,
      p_effective_start_date   IN   DATE,
      p_effective_end_date     IN   DATE
   )
      RETURN NUMBER;


-- Function get_udt_translated_code
   FUNCTION get_udt_translated_code (
      p_user_table_name     IN   VARCHAR2,
      p_effective_date      IN   DATE,
      p_asg_user_col_name   IN   VARCHAR2,
      p_ext_user_col_name   IN   VARCHAR2,
      p_value               IN   VARCHAR2
   )
      RETURN VARCHAR2;


--
-- Added for Hour Change
--

-- Function get_fte_value
   FUNCTION get_fte_value (p_assignment_id IN NUMBER, p_effective_date IN DATE)
      RETURN NUMBER;


-- To be included as Formula functions (public)

-- Function chk_employee_qual_for_starters
   FUNCTION chk_employee_qual_for_starters (
      p_business_group_id   IN              NUMBER -- Context
                                                  ,
      p_effective_date      IN              DATE -- Context
                                                ,
      p_assignment_id       IN              NUMBER -- Context
                                                  ,
      p_error_number        OUT NOCOPY      NUMBER,
      p_error_text          OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2;


-- Function get_superannuation_ref_no
   FUNCTION get_superannuation_ref_no (p_assignment_id IN NUMBER -- Context
                                                                )
      RETURN VARCHAR2;


-- Functio get_emp_cont_rate
   FUNCTION get_emp_cont_rate (p_assignment_id IN NUMBER -- Context
                                                        )
      RETURN VARCHAR2;


-- Function get_scheme_number
   FUNCTION get_scheme_number (
      p_assignment_id   IN              NUMBER -- Context
                                              ,
      p_scheme_number   OUT NOCOPY      VARCHAR2,
      p_error_number    OUT NOCOPY      NUMBER,
      p_error_text      OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;


-- Function get_employer_reference_number
   FUNCTION get_employer_reference_number (
      p_assignment_id     IN              NUMBER -- Context
                                                ,
      p_employer_ref_no   OUT NOCOPY      VARCHAR2,
      p_error_number      OUT NOCOPY      NUMBER,
      p_error_text        OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;


-- Function get_date_joined_pens_fund
   FUNCTION get_date_joined_pens_fund (
      p_assignment_id    IN              NUMBER -- Context
                                               ,
      p_dt_joined_pens   OUT NOCOPY      DATE,
      p_error_number     OUT NOCOPY      NUMBER,
      p_error_text       OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;


-- Function get_date_contracted_out
   FUNCTION get_date_contracted_out (
      p_assignment_id   IN              NUMBER -- Context
                                              ,
      p_dt_cont_out     OUT NOCOPY      DATE,
      p_error_number    OUT NOCOPY      NUMBER,
      p_error_text      OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER;


-- Function get_employment_number
   FUNCTION get_employment_number (p_assignment_id IN NUMBER)
      RETURN VARCHAR2;


-- Function get_employee_category
   FUNCTION get_employee_category (p_assignment_id IN NUMBER)
      RETURN VARCHAR2;


-- Function get_system_data_element
   FUNCTION get_system_data_element
      RETURN VARCHAR2;


-- Function get_STARTERS_part_time_ind
   FUNCTION get_starters_part_time_ind (p_assignment_id IN NUMBER -- Context
                                                                 )
      RETURN VARCHAR2;


-- Function get_CPX_part_time_ind
   FUNCTION get_cpx_part_time_ind (p_assignment_id IN NUMBER -- Context
                                                            )
      RETURN VARCHAR2;


-- Function get_STARTERS_marital_status
   FUNCTION get_starters_marital_status (p_assignment_id IN NUMBER -- Context
                                                                  )
      RETURN VARCHAR2;


-- Function get_CPX_marital_status
   FUNCTION get_cpx_marital_status (p_assignment_id IN NUMBER -- Context
                                                             )
      RETURN VARCHAR2;


-- Function get_spouses_date_of_birth
   FUNCTION get_spouses_date_of_birth (p_assignment_id IN NUMBER -- Context
                                                                )
      RETURN DATE;


-- Function get_spouses_initials
   FUNCTION get_spouses_initials (p_assignment_id IN NUMBER -- Context
                                                           )
      RETURN VARCHAR2;


-- Function get_STARTERS_NI_indicator
   FUNCTION get_starters_ni_indicator (p_assignment_id IN NUMBER -- Context
                                                                )
      RETURN VARCHAR2;


-- Function get_CPX_NI_indicator
   FUNCTION get_cpx_ni_indicator (p_assignment_id IN NUMBER -- Context
                                                           )
      RETURN VARCHAR2;


-- Function get_actual_remuneration
   FUNCTION get_actual_remuneration (p_assignment_id IN NUMBER -- Context
                                                              )
      RETURN VARCHAR2;


-- Function get_pensionable_remuneration
   FUNCTION get_pensionable_remuneration (p_assignment_id IN NUMBER -- Context
                                                                   )
      RETURN VARCHAR2;


-- Function get_total_number_data_records
   FUNCTION get_total_number_data_records (p_type IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;


-- Function get_data_element_total_value
   FUNCTION get_data_element_total_value (p_val_seq IN NUMBER)
      RETURN VARCHAR2;


--
-- Added for Annual
--

-- Function chk_employee_qual_for_annual
   FUNCTION chk_employee_qual_for_annual (
      p_business_group_id   IN              NUMBER -- context
                                                  ,
      p_effective_date      IN              DATE -- context
                                                ,
      p_assignment_id       IN              NUMBER -- context
                                                  ,
      p_error_number        OUT NOCOPY      NUMBER,
      p_error_text          OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2;


-- Function get_member_contributions
   FUNCTION get_member_contributions (p_assignment_id IN NUMBER)
      RETURN VARCHAR2;


-- Function get_NI_earnings
   FUNCTION get_ni_earnings (p_assignment_id IN NUMBER)
      RETURN VARCHAR2;


-- Function get_additional_contributions
   FUNCTION get_additional_contributions (p_assignment_id IN NUMBER)
      RETURN VARCHAR2;


-- Function get_buyback_contributions
   FUNCTION get_buyback_contributions (p_assignment_id IN NUMBER)
      RETURN VARCHAR2;


--
-- Added for Hour Change
--

-- Function chk_employee_qual_for_pthrch
   FUNCTION chk_employee_qual_for_pthrch (
      p_business_group_id   IN              NUMBER -- context
                                                  ,
      p_effective_date      IN              DATE -- context
                                                ,
      p_assignment_id       IN              NUMBER -- context
                                                  ,
      p_error_number        OUT NOCOPY      NUMBER,
      p_error_text          OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2;


-- Function get_part_time_percent
   FUNCTION get_part_time_percent (p_assignment_id IN NUMBER)
      RETURN VARCHAR2;


-- PROCEDURES (Private)

-- Procedure debug
   PROCEDURE DEBUG (
      p_trace_message    IN   VARCHAR2,
      p_trace_location   IN   NUMBER DEFAULT NULL
   );


-- Procedure debug_enter
   PROCEDURE debug_enter (
      p_proc_name   IN   VARCHAR2 DEFAULT NULL,
      p_trace_on    IN   VARCHAR2 DEFAULT NULL
   );


-- Procedure debug_exit
   PROCEDURE debug_exit (
      p_proc_name   IN   VARCHAR2 DEFAULT NULL,
      p_trace_off   IN   VARCHAR2 DEFAULT NULL
   );


-- Procedure set_annual_run_dates
   PROCEDURE set_annual_run_dates;


-- Procedure get_all_sec_assignments
   PROCEDURE get_all_sec_assignments (
      p_assignment_id       IN              NUMBER,
      p_secondary_asg_ids   OUT NOCOPY      t_number
   );


-- Procedure get_eligible_sec_assignments
   PROCEDURE get_eligible_sec_assignments (
      p_assignment_id       IN              NUMBER,
      p_secondary_asg_ids   OUT NOCOPY      t_number
   );


-- Procedure set_assignment_details
   PROCEDURE set_assignment_details (
      p_assignment_id    IN   NUMBER,
      p_effective_date   IN   DATE
   );


-- Procedure get_NI_element_details
   PROCEDURE get_ni_element_details;
END pqp_gb_cpx_extract_functions;

/
