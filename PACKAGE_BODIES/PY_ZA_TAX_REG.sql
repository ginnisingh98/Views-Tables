--------------------------------------------------------
--  DDL for Package Body PY_ZA_TAX_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_TAX_REG" AS
/* $Header: pyzatreg.pkb 120.1.12010000.7 2010/04/02 07:49:29 rbabla ship $ */
/* Copyright (c) 2001 Oracle Corporation Redwood Shores, California, USA */
/*                       All rights reserved.
/*
Change List:
------------

Name           Date          Version   Bug       Text
-------------- -----------   -------   -------   -----------------------
R Babla        02/04/2010    115.28    9539950   Added nvl to l_pdt_bal, mtd and ytd when code exist
                                                 in t_code_val
R Babla        30/03/2010    115.27    9402834   Populating codes 4141,4142, 4149 and removing 4103
P Arusia       25/02/2010    115.26    9369937   Resetting the user table t_code_val
                                                 for each assignment
P Arusia       02/12/2009    115.25    9117260   Changes for Tax Year 2010
R Babla        23/02/2009    115.24    8274764   Modified cursor csr_irp5_balances
                                                 to add a join on the pay_assignment_actions.action_sequence
                                                 and cursor csr_processed_assignments to select
                                                 the action_sequence
R Babla        30/01/2009    115.23    8213478   Modifed the cursor csr_irp5_balances
                                                 to include the code 4005 with
                                                 balance_sequence 2
A. Mahanty     13/06/2006    115.22    5330452   Modified the cursor
                                                 csr_processed_assignments. The query was
                                                 modified to pick up the correct action_sequence.
                                                 (choosing max payroll_action_id may give incorrect
                                                 balance values in some cases)
                                                 Secure views were used for Performance enhancement.
A. Mahanty     14/04/2005    115.21    3491357   BRA Enh. Balance Value retrieval
                                                 modified.
J.N. Louw      23/06/2004    115.20    3694450   Modified assignment_nature
                                                 to reference fnd_lookup_values
                                                 instead of hr_lookups
R. Pahune      09/02/2004    115.19    3400581   Modified the cursor
                                                 csr_processed_assignments.
N. Venugopal   09/01/2004    115.18    3221746   removed set serverout on for gscc compliance.
N. Venugopal   07/01/2004    115.17    3221746   Code changes for performace improvement.
N. Venugopal   11/08/2003    115.16    3069004   Modified cursor csr_irp5_balances.
L. Kloppers    23/12/2002    115.15    2720082   Modified the cursors:
                                                 csr_processed_assignments to
                                                 select assignments only if they are on the
                                                 chosen payroll in the specified payroll period
                                                 for which the Tax Register is being run, and
                                                 csr_irp5_balances to
                                                 select lump sum balances for an assignment, even
                                                 where they were paid in earlier payrolls that
                                                 the assignment was on.
A.Sengar       10/12/2002    115.14    2665394   Modified the cursor
                                                 csr_processed_assignments to
                                                 improve the performance of the
                                                 select statement.
L. Kloppers    23/09/2002    115.11    2224332   Added Procedure assignment_nature
                                                 Modified Procedure pre_process to call
                                                 py_za_tax_certificates.get_sars_code
                                                 for correct saving of balance codes for
                                                 Foreign- and Directors Income
                                                 Removed DEFAULT NULL for two parameters in
                                                 public procedure pre_process as per gscc
J.N. Louw      29/05/2002    115.9     1858619   Fixing QA raised issues
                                       2377480   Legal Entity fetch per
                                                 assignment and not per
                                                 organization
J.N. Louw      28/02/2002    115.8               Added
                                                 hr_utility calls
                                                 Removed
                                                 record creation for
                                                 assignment with no
                                                 balance values
J.N. Louw      04/02/2002    115.7               Added
                                                 include_assignment
J.N. Louw      25/01/2002    115.5     1756600   Register was updated to
                                       1756617   accommodate bug changes
                                       1858619   and merge of both
                                       2117507   current and terminated
                                       2132644   assignments reports
L. Kloppers    01-Mar-2001   115.4               Changed
                                                 per_assignment_status_types_tl
                                                 back to
                                                 per_assignment_status_types
                                                 and use PER_SYSTEM_STATUS
                                                 i.s.o.  USER_STATUS
L. Kloppers    23-Feb-2001   115.3               Changed
                                                   per_assignment_status_types
                                                 to
                                                   per_assignment_status_types_tl
L. Kloppers    06-Feb-2001   115.2               Changed "end_date"
                                                         to "ptp.end_date"
L. Kloppers    31-Jan-2001   115.1               Changed attribute1
                                                         to prd_information1
A vd Berg      22-Jan-2001   110.11              Amended Version Number
G. Fraser      10-Nov-2000   110.8               Changed Termination
                                                 Assignment Cursor
G. Fraser      24-May-2000   110.3-7             Speed improvements
L.J.Kloppers   23-Feb-2000   110.2               Added p_tax_register_id
                                                 IN OUT NOCOPY parameter
L.J.Kloppers   13-Feb-2000   110.1               Added p_total_employees
                                                 and p_total_assignments
                                                 IN OUT NOCOPY parameters
L.J.Kloppers   12-Feb-2000   110.0               Initial Version
*/

-------------------------------------------------------------------------------
--                               PACKAGE BODY                                --
-------------------------------------------------------------------------------

------------------
-- Package Globals
------------------
   type code_desc is record (
       bal_name        varchar2(100)
   );

   type code_value_rec is record (
       bal_name       varchar2(400),
       included_in    number,
       ptd_val        number,
       mtd_val        number,
       ytd_val        number,
       ptd_group_val  number,
       mtd_group_val  number,
       ytd_group_val  number
   );
   type code_value_table is table of code_value_rec index by binary_integer;
   type code_desc_table  is table of code_desc      index by binary_integer;

   g_code                code_desc_table;
   g_tax_register_id     pay_za_tax_registers.tax_register_id%TYPE;
   g_payroll_id          pay_all_payrolls_f.payroll_id%TYPE;
   g_start_period_id     per_time_periods.time_period_id%TYPE;
   g_end_period_id       per_time_periods.time_period_id%TYPE;
   g_period_num          per_time_periods.period_num%TYPE;
   g_period_start_date   per_time_periods.start_date%TYPE;
   g_period_end_date     per_time_periods.end_date%TYPE;
   g_payroll_name        pay_all_payrolls_f.payroll_name%TYPE;
   g_include_asg         VARCHAR2(1);
   g_retrieve_ptd        BOOLEAN;
   g_retrieve_mtd        BOOLEAN;
   g_retrieve_ytd        BOOLEAN;

--
-------------------------------------------------------------------------------
-- zeroval
-------------------------------------------------------------------------------
PROCEDURE zvl (
   p_val IN OUT NOCOPY NUMBER
   )
AS
-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.zvl',1);

   IF p_val IS NOT NULL THEN
      IF p_val = 0 THEN
         p_val := NULL;
      END IF;
   END IF;

   hr_utility.set_location('py_za_tax_reg.zvl',2);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.zvl',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END zvl;

-------------------------------------------------------------------------------
-- valid_record
-------------------------------------------------------------------------------
FUNCTION valid_record (
   p_ptd_bal          IN    NUMBER DEFAULT NULL
 , p_mtd_bal          IN    NUMBER DEFAULT NULL
 , p_ytd_bal          IN    NUMBER DEFAULT NULL
 )
RETURN BOOLEAN
AS
   ------------
   -- Variables
   ------------
   l_check_val VARCHAR2(1) := 'X';
   l_ret_val   BOOLEAN     DEFAULT FALSE;
   ------------
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.valid_record',1);

   IF nvl(
           to_char(
                   nvl(
                        nvl( p_ptd_bal
                           , p_mtd_bal
                           )
                      , p_ytd_bal
                      )
                  )
         , l_check_val
         ) <> l_check_val
   THEN
      hr_utility.set_location('py_za_tax_reg.valid_record',2);
      l_ret_val := TRUE;
   END IF;

   hr_utility.set_location('py_za_tax_reg.valid_record',3);
   RETURN l_ret_val;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.valid_record',4);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END valid_record;

-------------------------------------------------------------------------------
-- balance_id
-------------------------------------------------------------------------------
FUNCTION balance_id (
   p_balance_name IN pay_balance_types.balance_name%TYPE
   )
RETURN pay_balance_types.balance_type_id%TYPE
AS
   ---------
   -- Cursor
   ---------
   CURSOR csr_balance_id (
      p_balance_name IN pay_balance_types.balance_name%TYPE
      )
   IS
      SELECT
             pbt.balance_type_id
        FROM
             pay_balance_types pbt
       WHERE
             pbt.balance_name       = p_balance_name
         AND pbt.business_group_id IS NULL
         AND pbt.legislation_code   = 'ZA';

   ------------
   -- Variables
   ------------
   l_retval pay_balance_types.balance_type_id%TYPE;

-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.balance_id',1);

   OPEN csr_balance_id(p_balance_name);
   FETCH csr_balance_id INTO l_retval;
   CLOSE csr_balance_id;

   hr_utility.set_location('py_za_tax_reg.balance_id',2);
   RETURN l_retval;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.balance_id',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END balance_id;

-------------------------------------------------------------------------------
-- ptd_value
-------------------------------------------------------------------------------
FUNCTION ptd_value (
   p_asg_action_id    IN pay_assignment_actions.assignment_action_id%TYPE
 , p_action_period_id IN per_time_periods.time_period_id%TYPE
 , p_balance_type_id  IN pay_balance_types.balance_type_id%TYPE
 , p_balance_name     IN pay_za_irp5_bal_codes.full_balance_name%TYPE
 , p_effective_date   IN pay_payroll_actions.effective_date%TYPE
 )
RETURN NUMBER AS
   ------------
   -- Variables
   ------------
   l_ptd_value NUMBER;
   --
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.ptd_value',1);
   -- Check if the PTD value must be retrieved
   --
   IF g_retrieve_ptd THEN
      hr_utility.set_location('py_za_tax_reg.ptd_value',2);
      -- PTD value of Site and Paye Amount not necessary
      --
      IF UPPER(p_balance_name) NOT IN ('SITE','PAYE') THEN
         hr_utility.set_location('py_za_tax_reg.ptd_value',3);
         -- Is the assignment's action in the current period
         --
         IF g_end_period_id = p_action_period_id THEN
            hr_utility.set_location('py_za_tax_reg.ptd_value',4);
            -- Retrieve the value
            --3491357
            /*l_ptd_value := py_za_bal.calc_asg_tax_ptd_action (
                              p_asg_action_id
                            , p_balance_type_id
                            , p_effective_date
                            );*/
            l_ptd_value := py_za_bal.get_balance_value_action (
                               p_asg_action_id
                             , p_balance_type_id
                             , '_ASG_TAX_PTD'
                             );
         END IF;
      END IF;
   END IF;
   hr_utility.set_location('py_za_tax_reg.ptd_value',5);
   zvl(l_ptd_value);
   hr_utility.set_location('py_za_tax_reg.ptd_value',6);
   -- Return
   RETURN l_ptd_value;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.ptd_value',7);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END ptd_value;

-------------------------------------------------------------------------------
-- mtd_value
-------------------------------------------------------------------------------
FUNCTION mtd_value (
   p_asg_action_id   IN pay_assignment_actions.assignment_action_id%TYPE
 , p_balance_type_id IN pay_balance_types.balance_type_id%TYPE
 , p_balance_name    IN pay_za_irp5_bal_codes.full_balance_name%TYPE
 , p_effective_date  IN pay_payroll_actions.effective_date%TYPE
 )
RETURN NUMBER AS
   ------------
   -- Variables
   ------------
   l_mtd_value NUMBER;
   --
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.mtd_value',1);
   -- Check if the MTD value must be retrieved
   --
   IF g_retrieve_mtd THEN
      hr_utility.set_location('py_za_tax_reg.mtd_value',2);
      -- PTD value of Site and Paye Amount not necessary
      --
      IF UPPER(p_balance_name) NOT IN ('SITE','PAYE') THEN
         hr_utility.set_location('py_za_tax_reg.mtd_value',3);
         -- Is the effective date of the action in the current period
         --
         IF p_effective_date between g_period_start_date
                                 and g_period_end_date
         THEN
            hr_utility.set_location('py_za_tax_reg.mtd_value',4);
            -- Retrieve the value
            --3491357
            /*l_mtd_value := py_za_bal.calc_asg_tax_mtd_action (
                              p_asg_action_id
                            , p_balance_type_id
                            , p_effective_date
                            );*/
              l_mtd_value := py_za_bal.get_balance_value_action (
                               p_asg_action_id
                             , p_balance_type_id
                             , '_ASG_TAX_MTD'
                             );
         END IF;
      END IF;
   END IF;
   hr_utility.set_location('py_za_tax_reg.mtd_value',5);
   zvl(l_mtd_value);
   hr_utility.set_location('py_za_tax_reg.mtd_value',6);
   -- Return
   RETURN l_mtd_value;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.mtd_value',7);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END mtd_value;

-------------------------------------------------------------------------------
-- ytd_value
-------------------------------------------------------------------------------
FUNCTION ytd_value (
   p_asg_action_id   IN pay_assignment_actions.assignment_action_id%TYPE
 , p_balance_type_id IN pay_balance_types.balance_type_id%TYPE
 , p_effective_date  IN pay_payroll_actions.effective_date%TYPE
 )
RETURN NUMBER AS
   ------------
   -- Variables
   ------------
   l_ytd_value NUMBER;
   --
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.ytd_value',1);
   -- Check if the YTD value must be retrieved
   --
   IF g_retrieve_ytd THEN
      hr_utility.set_location('py_za_tax_reg.ytd_value',2);
      -- Retrieve the value
      --3491357
      /*l_ytd_value := py_za_bal.calc_asg_tax_ytd_action (
                        p_asg_action_id
                      , p_balance_type_id
                      , p_effective_date
                      );*/
        l_ytd_value := py_za_bal.get_balance_value_action (
                               p_asg_action_id
                             , p_balance_type_id
                             , '_ASG_TAX_YTD'
                             );
   END IF;
   hr_utility.set_location('py_za_tax_reg.ytd_value',3);
   zvl(l_ytd_value);
   hr_utility.set_location('py_za_tax_reg.ytd_value',4);
   -- Return
   RETURN l_ytd_value;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.ytd_value',5);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END ytd_value;

-------------------------------------------------------------------------------
-- run_result_value
-------------------------------------------------------------------------------
FUNCTION run_result_value (
   p_element_name  IN     pay_element_types_f.element_name%TYPE
 , p_value_name    IN     pay_input_values_f.name%TYPE
 , p_assignment_id IN     per_all_assignments_f.assignment_id%TYPE
 , p_run_result_id IN OUT NOCOPY pay_run_results.run_result_id%TYPE
 )
RETURN pay_run_result_values.result_value%TYPE
AS
   ---------
   -- Cursor
   ---------
   CURSOR csr_result_value
   IS
      SELECT
             prrv.result_value
           , prrv.run_result_id
        FROM
             pay_element_types_f      pet
           , pay_input_values_f       piv
           , pay_run_results          prr
           , pay_run_result_values    prrv
       WHERE
             pet.element_name         = p_element_name
         AND pet.legislation_code     = 'ZA'
         AND pet.element_type_id      = piv.element_type_id
         AND piv.name                 = p_value_name
         AND piv.input_value_id       = prrv.input_value_id
         AND prr.element_type_id      = pet.element_type_id
         AND prr.run_result_id        = prrv.run_result_id
         AND prr.assignment_action_id =
           (
             SELECT
                    MAX(paa2.assignment_action_id)
               FROM
                    pay_run_results           prr2
                  , pay_assignment_actions    paa2
                  , pay_payroll_actions       ppa2
              WHERE
                    prr2.element_type_id      = pet.element_type_id
                AND prr2.run_result_id        = nvl(p_run_result_id, prr2.run_result_id)
                AND prr2.assignment_action_id = paa2.assignment_action_id
                AND paa2.assignment_id        = p_assignment_id
                AND paa2.payroll_action_id    = ppa2.payroll_action_id
                AND ppa2.action_type         IN ('R', 'Q', 'I', 'B', 'V')
                AND ppa2.time_period_id BETWEEN g_start_period_id
                                            AND g_end_period_id
           );

   ------------
   -- Variables
   ------------
   l_result_value csr_result_value%ROWTYPE;
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.run_result_value',1);
   OPEN csr_result_value;
   FETCH csr_result_value INTO l_result_value;
   CLOSE csr_result_value;
   --
   hr_utility.set_location('py_za_tax_reg.run_result_value',2);
   p_run_result_id := l_result_value.run_result_id;
   RETURN l_result_value.result_value;
   --
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.run_result_value',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END run_result_value;

-------------------------------------------------------------------------------
-- run_result_value
-- Overloaded version of the function where the run_result_id us known
-------------------------------------------------------------------------------
FUNCTION run_result_value (
   p_value_name    IN pay_input_values_f.name%TYPE
 , p_run_result_id IN pay_run_results.run_result_id%TYPE
 )
RETURN pay_run_result_values.result_value%TYPE
AS
   ---------
   -- Cursor
   ---------
   CURSOR csr_result_value
   IS
      SELECT
             prrv.result_value
        FROM
             pay_run_results       prr
           , pay_input_values_f    piv
           , pay_run_result_values prrv
       WHERE
             prr.run_result_id     = p_run_result_id
         AND prr.element_type_id   = piv.element_type_id
         AND piv.name              = p_value_name
         AND piv.input_value_id    = prrv.input_value_id
         AND prr.run_result_id     = prrv.run_result_id;

   ------------
   -- Variables
   ------------
   l_result_value csr_result_value%ROWTYPE;
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.run_result_value',4);
   OPEN csr_result_value;
   FETCH csr_result_value INTO l_result_value;
   CLOSE csr_result_value;
   --
   hr_utility.set_location('py_za_tax_reg.run_result_value',5);
   RETURN l_result_value.result_value;
   --
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.run_result_value',6);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END run_result_value;

-------------------------------------------------------------------------------
-- decode_lookup_code
-------------------------------------------------------------------------------
FUNCTION decode_lookup_code (
   p_lookup_type    IN hr_lookups.lookup_type%TYPE
 , p_lookup_code    IN hr_lookups.lookup_code%TYPE
 , p_application_id IN hr_lookups.application_id%TYPE
 )
RETURN hr_lookups.meaning%TYPE AS
   ---------
   -- Cursor
   ---------
   CURSOR csr_lookup_meaning
   IS
      SELECT hl.meaning
        FROM hr_lookups hl
       WHERE hl.lookup_type    = p_lookup_type
         AND hl.lookup_code    = p_lookup_code
         AND hl.application_id = p_application_id;
   --
   ------------
   -- Variables
   ------------
   l_meaning hr_lookups.meaning%TYPE;
   --
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.decode_lookup_code',1);
   OPEN csr_lookup_meaning;
   FETCH csr_lookup_meaning INTO l_meaning;
   CLOSE csr_lookup_meaning;

   hr_utility.set_location('py_za_tax_reg.decode_lookup_code',2);
   RETURN l_meaning;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.decode_lookup_code',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END decode_lookup_code;

-------------------------------------------------------------------------------
-- assignment_tax_status_directive
-------------------------------------------------------------------------------
PROCEDURE assignment_tax_sta_dir (
   p_assignment_id       IN     per_all_assignments_f.assignment_id%TYPE
 , p_asg_tax_status      OUT NOCOPY hr_lookups.meaning%TYPE
 , p_asg_dir_value       OUT NOCOPY pay_run_result_values.result_value%TYPE
 , p_asg_tax_status_code OUT NOCOPY hr_lookups.lookup_code%TYPE
 )
AS
   ------------
   -- Variables
   ------------
   l_tax_status          hr_lookups.meaning%TYPE;
   l_dir_value           pay_run_result_values.result_value%TYPE;
   l_run_result_id       pay_run_results.run_result_id%TYPE;
   l_asg_tax_status_code hr_lookups.lookup_code%TYPE;

-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.assignment_tax_sta_dir',1);
   --
   l_tax_status := run_result_value (
                      p_element_name  => 'ZA_Tax'
                    , p_value_name    => 'Tax Status'
                    , p_assignment_id => p_assignment_id
                    , p_run_result_id => l_run_result_id
                    );
   --
   l_asg_tax_status_code := l_tax_status;
   --
   hr_utility.set_location('py_za_tax_reg.assignment_tax_sta_dir',2);
   --
   l_tax_status := decode_lookup_code (
                      p_lookup_type    => 'ZA_TAX_STATUS'
                    , p_lookup_code    => l_tax_status
                    , p_application_id => 800
                    );
   --
   hr_utility.set_location('py_za_tax_reg.assignment_tax_sta_dir',3);
   --
   IF l_run_result_id IS NOT NULL THEN
      hr_utility.set_location('py_za_tax_reg.assignment_tax_sta_dir',4);
      -- Find the directive value for the same result id
      l_dir_value := run_result_value (
                        p_value_name    => 'Tax Directive Value'
                      , p_run_result_id => l_run_result_id
                      );
   END IF;
   --
   hr_utility.set_location('py_za_tax_reg.assignment_tax_sta_dir',5);
   --
   p_asg_tax_status      := l_tax_status;
   p_asg_dir_value       := l_dir_value;
   p_asg_tax_status_code := l_asg_tax_status_code;


EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.assignment_tax_sta_dir',6);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END assignment_tax_sta_dir;

-------------------------------------------------------------------------------
-- assignment_nature
-------------------------------------------------------------------------------
PROCEDURE assignment_nature (
   p_assignment_id  IN  per_all_assignments_f.assignment_id%TYPE
 , p_effective_date IN  DATE
 , p_asg_nature     OUT NOCOPY hr_lookups.meaning%TYPE
 )
AS
   ------------
   -- Variables
   ------------

   -----------------------------------------------------------------
   -- Cursor csr_asg_nature
   -----------------------------------------------------------------
   CURSOR csr_asg_nature (
       c_assignment_id   IN per_all_assignments_f.assignment_id%TYPE
     , c_effective_date  IN DATE
     )
   IS
   SELECT
          nvl(fcl.meaning, 'A') nature
     FROM
          per_all_assignments_f      ass
        , per_assignment_extra_info  aei
        , fnd_lookup_values          fcl
    WHERE ass.assignment_id        = c_assignment_id
      AND ass.effective_start_date =
      (
       SELECT max(paf2.effective_start_date)
         FROM per_all_assignments_f paf2
        WHERE paf2.assignment_id = ass.assignment_id
          AND paf2.effective_start_date <= c_effective_date
      )
      AND ass.assignment_id            = aei.assignment_id(+)
      AND aei.aei_information_category = 'ZA_SPECIFIC_INFO'
      AND fcl.lookup_type(+)           = 'ZA_PER_NATURES'
      AND fcl.lookup_code(+)           = aei.aei_information4
      AND fcl.language(+)              = 'US';


   l_nature        hr_lookups.meaning%TYPE;

-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.assignment_nature',1);
   --
   FOR v_asg_nature IN csr_asg_nature
      ( c_assignment_id  => p_assignment_id
      , c_effective_date => p_effective_date
      )
   LOOP

      l_nature := v_asg_nature.nature;

   END LOOP csr_asg_nature;

   IF l_nature IS NULL THEN

      l_nature := 'A';

   END IF;
   --
   hr_utility.set_location('py_za_tax_reg.assignment_nature',2);
   --
   p_asg_nature := l_nature;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.assignment_nature',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END assignment_nature;

-------------------------------------------------------------------------------
-- assignment_dys_worked
-------------------------------------------------------------------------------
FUNCTION assignment_dys_worked (
   p_asg_tax_status IN hr_lookups.meaning%TYPE
 , p_asg_action_id  IN pay_assignment_actions.assignment_action_id%TYPE
 , p_effective_date IN pay_payroll_actions.effective_date%TYPE
 )
RETURN NUMBER
AS
   ------------
   -- Variables
   ------------
   l_bal_type_id   pay_balance_types.balance_type_id%TYPE;
   l_balance_value NUMBER;
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.assignment_dys_worked',1);
   IF p_asg_tax_status = 'Seasonal Worker' THEN
      hr_utility.set_location('py_za_tax_reg.assignment_dys_worked',2);
      --
      l_bal_type_id :=
         balance_id (
            p_balance_name => 'Total Seasonal Workers Days Worked'
            );
      hr_utility.set_location('py_za_tax_reg.assignment_dys_worked',3);
      l_balance_value :=
         ytd_value (
            p_asg_action_id   => p_asg_action_id
          , p_balance_type_id => l_bal_type_id
          , p_effective_date  => p_effective_date
          );
   END IF;

   hr_utility.set_location('py_za_tax_reg.assignment_dys_worked',4);
   zvl(l_balance_value);
   hr_utility.set_location('py_za_tax_reg.assignment_dys_worked',5);
   -- Return
   RETURN l_balance_value;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.assignment_dys_worked',6);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END assignment_dys_worked;

-------------------------------------------------------------------------------
-- assignment_start_date
-------------------------------------------------------------------------------
FUNCTION assignment_start_date (
   p_assignment_id IN per_all_assignments_f.assignment_id%TYPE
   )
RETURN DATE AS
   ---------
   -- Cursor
   ---------
   CURSOR csr_assignment_start_date
   IS
      SELECT MIN(per.effective_start_date)
        FROM per_all_assignments_f       per
           , per_assignment_status_types past
       WHERE per.assignment_id              = p_assignment_id
         AND per.assignment_status_type_id  = past.assignment_status_type_id
         AND past.per_system_status        IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

   ------------
   -- Variables
   ------------
 /*<variabel_name> <datatype> DEFAULT <default_value>;*/
   l_date per_all_assignments_f.effective_start_date%TYPE;
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.assignment_start_date',1);
   OPEN csr_assignment_start_date;
   FETCH csr_assignment_start_date INTO l_date;
   CLOSE csr_assignment_start_date;

   hr_utility.set_location('py_za_tax_reg.assignment_start_date',2);
   RETURN l_date;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.assignment_start_date',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END assignment_start_date;

-------------------------------------------------------------------------------
-- assignment_end_date
-------------------------------------------------------------------------------
FUNCTION assignment_end_date (
   p_assignment_id IN per_all_assignments_f.assignment_id%TYPE
 )
RETURN DATE AS
   ---------
   -- Cursor
   ---------
   CURSOR csr_assignment_end_date
   IS
      SELECT MAX(per.effective_end_date)
        FROM per_all_assignments_f       per
           , per_assignment_status_types past
       WHERE per.assignment_id              = p_assignment_id
         AND per.assignment_status_type_id  = past.assignment_status_type_id
         AND past.per_system_status        IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

   ------------
   -- Variables
   ------------
 /*<variabel_name> <datatype> DEFAULT <default_value>;*/
   l_date per_all_assignments_f.effective_start_date%TYPE;
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.assignment_end_date',1);

   OPEN csr_assignment_end_date;
   FETCH csr_assignment_end_date INTO l_date;
   CLOSE csr_assignment_end_date;

   hr_utility.set_location('py_za_tax_reg.assignment_end_date',2);
   RETURN l_date;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.assignment_end_date',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END assignment_end_date;

-------------------------------------------------------------------------------
-- include_assignment
-------------------------------------------------------------------------------
FUNCTION include_assignment (
   p_asg_id         IN  per_all_assignments_f.assignment_id%TYPE
 , p_asg_start_date OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
 , p_asg_end_date   OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
 )
RETURN BOOLEAN AS
   ------------
   -- Variables
   ------------
   l_asg_end_date per_all_assignments_f.effective_end_date%TYPE;
   l_include      BOOLEAN;
   --
-------------------------------------------------------------------------------
BEGIN --                              MAIN                                   --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.include_assignment',1);
   --
   p_asg_end_date := assignment_end_date (p_assignment_id => p_asg_id);
   -- Include ALL Assignments
   --
   IF    g_include_asg = 'A' THEN
      hr_utility.set_location('py_za_tax_reg.include_assignment',2);
      --
      l_include := TRUE;
   -- Include Terminated Assignments ONLY
   --
   ELSIF g_include_asg = 'T' THEN
      hr_utility.set_location('py_za_tax_reg.include_assignment',3);
      --
      IF p_asg_end_date < g_period_end_date THEN
         hr_utility.set_location('py_za_tax_reg.include_assignment',4);
         l_include := TRUE;
      ELSE
         hr_utility.set_location('py_za_tax_reg.include_assignment',5);
         l_include := FALSE;
      END IF;
   -- Include Current Assignments ONLY
   --
   ELSIF g_include_asg = 'C' THEN
      hr_utility.set_location('py_za_tax_reg.include_assignment',6);
      --
      IF p_asg_end_date >= g_period_end_date THEN
         hr_utility.set_location('py_za_tax_reg.include_assignment',7);
         l_include := TRUE;
      ELSE
         hr_utility.set_location('py_za_tax_reg.include_assignment',8);
         l_include := FALSE;
      END IF;
   END IF;


   -- Set the end date of the assignment to null if
   -- it's on or after the period end date
   -- this will indicate a non terminated assignment
   --
   IF p_asg_end_date >= g_period_end_date THEN
      hr_utility.set_location('py_za_tax_reg.include_assignment',9);
      p_asg_end_date := NULL;
   END IF;

   IF l_include THEN
      hr_utility.set_location('py_za_tax_reg.include_assignment',10);
      p_asg_start_date := assignment_start_date (p_assignment_id => p_asg_id);
   END IF;

   hr_utility.set_location('py_za_tax_reg.include_assignment',11);
   RETURN l_include;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.include_assignment',12);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END include_assignment;

-------------------------------------------------------------------------------
-- include_assignment
-- This function is the overloaded version of include_assignment
-- It is called from the value set PY_SRS_ZA_TX_RGSTR_ASG
-------------------------------------------------------------------------------
FUNCTION include_assignment (
   p_asg_id          IN  per_all_assignments_f.assignment_id%TYPE
 , p_period_end_date IN per_time_periods.end_date%TYPE
 , p_include_flag    IN VARCHAR2
 )
RETURN VARCHAR2 AS
   ------------
   -- Variables
   ------------
   l_asg_end_date per_all_assignments_f.effective_end_date%TYPE;
   l_include      VARCHAR2(1);
   --
-------------------------------------------------------------------------------
BEGIN --                              MAIN                                   --
-------------------------------------------------------------------------------
   l_asg_end_date := assignment_end_date (p_assignment_id => p_asg_id);
   -- Include ALL Assignments
   --
   IF p_include_flag = 'A' THEN
      l_include := 'Y';
   -- Include Terminated Assignments ONLY
   --
   ELSIF p_include_flag = 'T' THEN
      IF l_asg_end_date < p_period_end_date THEN
         l_include := 'Y';
      ELSE
         l_include := 'N';
      END IF;
   -- Include Current Assignments ONLY
   --
   ELSIF p_include_flag = 'C' THEN
      IF l_asg_end_date >= p_period_end_date THEN
         l_include := 'Y';
      ELSE
         l_include := 'N';
      END IF;
   END IF;

   hr_utility.set_location('py_za_tax_reg.include_assignment',1);
   RETURN l_include;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.include_assignment',2);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END include_assignment;

-------------------------------------------------------------------------------
-- total_employees
-------------------------------------------------------------------------------
FUNCTION total_employees RETURN NUMBER AS
   ---------
   -- Cursor
   ---------
   CURSOR csr_total_employees
   IS
      SELECT
             count(max(tr.person_id))
        FROM
             pay_za_tax_registers tr
       GROUP BY
             tr.person_id;

   ------------
   -- Variables
   ------------
   l_tot_employees NUMBER;

-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.total_employees',1);

   OPEN csr_total_employees;
   FETCH csr_total_employees INTO l_tot_employees;
   CLOSE csr_total_employees;

   hr_utility.set_location('py_za_tax_reg.total_employees',2);
   RETURN l_tot_employees;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.total_employees',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END total_employees;

-------------------------------------------------------------------------------
-- total_assignments
-------------------------------------------------------------------------------
FUNCTION total_assignments RETURN NUMBER AS
   ---------
   -- Cursor
   ---------
   CURSOR csr_total_assignments
   IS
      SELECT
             count(max(tr.assignment_id))
        FROM
             pay_za_tax_registers tr
       GROUP BY
             tr.assignment_id;

   ------------
   -- Variables
   ------------
   l_tot_assignments NUMBER;

-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.total_assignments',1);

   OPEN csr_total_assignments;
   FETCH csr_total_assignments INTO l_tot_assignments;
   CLOSE csr_total_assignments;

   hr_utility.set_location('py_za_tax_reg.total_assignments',2);
   RETURN l_tot_assignments;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.total_assignments',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END total_assignments;


-------------------------------------------------------------------------------
-- set_period_details
-------------------------------------------------------------------------------
PROCEDURE set_period_details AS
   ---------
   -- Cursor
   ---------
   CURSOR csr_min_time_period
   IS
      SELECT
             MIN(ptp.time_period_id) min_time_period
        FROM
             per_time_periods ptp
       WHERE
             ptp.payroll_id = g_payroll_id
         AND ptp.prd_information1 =
           (
             SELECT ptp2.prd_information1
               FROM per_time_periods ptp2
              WHERE ptp2.payroll_id     = g_payroll_id
                AND ptp2.time_period_id = g_end_period_id
           );
   ---------
   -- Cursor
   ---------
   CURSOR csr_period_details
   IS
      SELECT ptp.period_num
           , ptp.start_date
           , ptp.end_date
        FROM per_time_periods ptp
       WHERE ptp.time_period_id = g_end_period_id;
   ------------
   -- Variables
   ------------
   l_min_period_id per_time_periods.time_period_id%TYPE;
   l_period_info   csr_period_details%ROWTYPE;
   --
-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.set_period_details',1);
   IF g_start_period_id IS NULL THEN
      hr_utility.set_location('py_za_tax_reg.set_period_details',2);

      OPEN csr_min_time_period;
      FETCH csr_min_time_period INTO l_min_period_id;
      CLOSE csr_min_time_period;

      g_start_period_id := l_min_period_id;
   END IF;
   --
   hr_utility.set_location('py_za_tax_reg.set_period_details',3);
   --
   OPEN csr_period_details;
   FETCH csr_period_details INTO l_period_info;
   CLOSE csr_period_details;
   --
   hr_utility.set_location('py_za_tax_reg.set_period_details',4);
   --
   g_period_num        := l_period_info.period_num;
   g_period_start_date := l_period_info.start_date;
   g_period_end_date   := l_period_info.end_date;
   --
   hr_utility.set_location('py_za_tax_reg.set_period_details',5);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.set_period_details',6);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END set_period_details;


-------------------------------------------------------------------------------
-- set_payroll_details
-------------------------------------------------------------------------------
PROCEDURE set_payroll_details AS
   ---------
   -- Cursor
   ---------
-- 3221746 removed fnd_sessions table
   CURSOR csr_payroll_name
   IS
      SELECT
             pap.payroll_name
        FROM
             pay_all_payrolls_f pap
       WHERE
             pap.payroll_id = g_payroll_id
         AND g_period_end_date BETWEEN pap.effective_start_date
                                   AND pap.effective_end_date;

   ------------
   -- Variables
   ------------
   --
-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.set_payroll_details',1);

   OPEN csr_payroll_name;
   FETCH csr_payroll_name INTO g_payroll_name;
   CLOSE csr_payroll_name;

   hr_utility.set_location('py_za_tax_reg.set_payroll_details',2);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.set_payroll_details',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END set_payroll_details;

-------------------------------------------------------------------------------
-- set_globals
-------------------------------------------------------------------------------
PROCEDURE set_globals (
   p_payroll_id      IN pay_all_payrolls_f.payroll_id%TYPE
 , p_start_period_id IN per_time_periods.time_period_id%TYPE
 , p_end_period_id   IN per_time_periods.time_period_id%TYPE
 , p_include         IN VARCHAR2
 , p_retrieve_ptd    IN VARCHAR2
 , p_retrieve_mtd    IN VARCHAR2
 , p_retrieve_ytd    IN VARCHAR2
 )
AS
   ------------
   -- Variables
   ------------
   --
-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.set_globals',1);
   --
   SELECT
          pay_za_tax_registers_s.nextval
     INTO
          g_tax_register_id
     FROM
          dual;
   --
   hr_utility.set_location('py_za_tax_reg.set_globals',2);
   --
   g_payroll_id      := p_payroll_id;
   g_start_period_id := p_start_period_id;
   g_end_period_id   := p_end_period_id;
   g_include_asg     := p_include;
   --
   hr_utility.set_location('py_za_tax_reg.set_globals',3);
   --
   IF p_retrieve_ptd = 'Y' THEN
      hr_utility.set_location('py_za_tax_reg.set_globals',4);
      g_retrieve_ptd := TRUE;
   END IF;
   IF p_retrieve_mtd = 'Y' THEN
      hr_utility.set_location('py_za_tax_reg.set_globals',5);
      g_retrieve_mtd := TRUE;
   END IF;
   IF p_retrieve_ytd = 'Y' THEN
      hr_utility.set_location('py_za_tax_reg.set_globals',6);
      g_retrieve_ytd := TRUE;
   END IF;
   --
   hr_utility.set_location('py_za_tax_reg.set_globals',7);
   --
   set_period_details;
   set_payroll_details;
   --set_company_details;
   --
   hr_utility.set_location('py_za_tax_reg.set_globals',8);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.set_globals',9);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END set_globals;

-------------------------------------------------------------------------------
-- ins_register
-------------------------------------------------------------------------------
PROCEDURE ins_register (
-- <parameter_name> <IN OUT> <datatype> <default>
   p_full_name             IN pay_za_tax_registers.full_name%TYPE
 , p_employee_number       IN pay_za_tax_registers.employee_number%TYPE
 , p_person_id             IN pay_za_tax_registers.person_id%TYPE
 , p_date_of_birth         IN pay_za_tax_registers.date_of_birth%TYPE
 , p_age                   IN pay_za_tax_registers.age%TYPE
 , p_tax_reference_no      IN pay_za_tax_registers.tax_reference_no%TYPE
 , p_cmpy_tax_reference_no IN pay_za_tax_registers.cmpy_tax_reference_no%TYPE
 , p_tax_status            IN pay_za_tax_registers.tax_status%TYPE
 , p_tax_directive_value   IN pay_za_tax_registers.tax_directive_value%TYPE
 , p_days_worked           IN pay_za_tax_registers.days_worked%TYPE
 , p_assignment_id         IN pay_za_tax_registers.assignment_id%TYPE
 , p_assignment_action_id  IN pay_za_tax_registers.assignment_action_id%TYPE
 , p_assignment_number     IN pay_za_tax_registers.assignment_number%TYPE
 , p_assignment_start_date IN pay_za_tax_registers.assignment_start_date%TYPE
 , p_assignment_end_date   IN pay_za_tax_registers.assignment_end_date%TYPE
 , p_bal_name              IN pay_za_tax_registers.bal_name%TYPE DEFAULT NULL
 , p_bal_code              IN pay_za_tax_registers.bal_code%TYPE DEFAULT NULL
 , p_tot_ptd               IN pay_za_tax_registers.tot_ptd%TYPE  DEFAULT NULL
 , p_tot_mtd               IN pay_za_tax_registers.tot_mtd%TYPE  DEFAULT NULL
 , p_tot_ytd               IN pay_za_tax_registers.tot_ytd%TYPE  DEFAULT NULL
 )
AS
   ------------
   -- Variables
   ------------
   --
-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.ins_register',1);
   --
   INSERT INTO pay_za_tax_registers (
      tax_register_id
    , full_name
    , employee_number
    , person_id
    , date_of_birth
    , age
    , tax_reference_no
    , cmpy_tax_reference_no
    , tax_status
    , tax_directive_value
    , days_worked
    , assignment_id
    , assignment_action_id
    , assignment_number
    , assignment_start_date
    , assignment_end_date
    , bal_name
    , bal_code
    , tot_ptd
    , tot_mtd
    , tot_ytd
    )
   VALUES (
      g_tax_register_id
    , p_full_name
    , p_employee_number
    , p_person_id
    , p_date_of_birth
    , p_age
    , p_tax_reference_no
    , p_cmpy_tax_reference_no
    , p_tax_status
    , p_tax_directive_value
    , p_days_worked
    , p_assignment_id
    , p_assignment_action_id
    , p_assignment_number
    , p_assignment_start_date
    , p_assignment_end_date
    , p_bal_name
    , p_bal_code
    , p_tot_ptd
    , p_tot_mtd
    , p_tot_ytd
    );
   --
   hr_utility.set_location('py_za_tax_reg.ins_register',2);
   --
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.ins_register',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END ins_register;


-------------------------------------------------------------------------------
-- clear_register
-------------------------------------------------------------------------------
PROCEDURE clear_register (
   p_id IN pay_za_tax_registers.tax_register_id%TYPE
 )
AS
-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.clear_register',1);
   --
   DELETE
     FROM
          pay_za_tax_registers ztr
    WHERE
          ztr.tax_register_id = p_id;

   hr_utility.set_location('py_za_tax_reg.clear_register',2);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.clear_register',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END clear_register;

-------------------------------------------------------------------------------
-- Procedure pre_process
--
-- The Pre Process procedure called by the ZA Tax Register Report
-- It populates the pay_za_tax_registers table with
-- processed assignment balance value information
-------------------------------------------------------------------------------
PROCEDURE pre_process (
   p_payroll_id        IN     pay_all_payrolls_f.payroll_id%TYPE
 , p_start_period_id   IN     per_time_periods.time_period_id%TYPE
 , p_end_period_id     IN     per_time_periods.time_period_id%TYPE
 , p_include           IN     VARCHAR2
 , p_assignment_id     IN     per_all_assignments_f.assignment_id%TYPE
 , p_retrieve_ptd      IN     VARCHAR2
 , p_retrieve_mtd      IN     VARCHAR2
 , p_retrieve_ytd      IN     VARCHAR2
 , p_tax_register_id      OUT NOCOPY pay_za_tax_registers.tax_register_id%TYPE
 , p_payroll_name         OUT NOCOPY pay_all_payrolls_f.payroll_name%TYPE
 , p_period_num           OUT NOCOPY per_time_periods.period_num%TYPE
 , p_period_start_date    OUT NOCOPY per_time_periods.start_date%TYPE
 , p_period_end_date      OUT NOCOPY per_time_periods.end_date%TYPE
 , p_tot_employees        OUT NOCOPY NUMBER
 , p_tot_assignments      OUT NOCOPY NUMBER
 )
AS
   -----------------------------------------------------------------
   -- Cursor csr_processed_assignments
   --
   -- Selects processed assignments and corresponding person details
   -- for a specific payroll within two time periods
   -- returning the maximum assignment action
   -----------------------------------------------------------------
   -- Bug 5330452
   CURSOR csr_processed_assignments (
       p_payroll_id      IN pay_all_payrolls_f.payroll_id%TYPE
     , p_start_period_id IN per_time_periods.time_period_id%TYPE
     , p_end_period_id   IN per_time_periods.time_period_id%TYPE
     , p_asg_id          IN per_all_assignments_f.assignment_id%TYPE DEFAULT NULL
     )
   IS
      SELECT
             paa.assignment_action_id
           , paa.assignment_id
           , paa.action_sequence
           , ppa.time_period_id
           , ppa.effective_date
           , asg.assignment_number
           , pap.person_id
           , pap.full_name
           , pap.date_of_birth
           , pap.employee_number
           , pap.per_information1 tax_reference_number
           , trunc(months_between(g_period_end_date, pap.date_of_birth)/12) age
           , oit.org_information3 cmpy_tax_reference_number
        FROM
             pay_assignment_actions           paa
           , pay_payroll_actions              ppa
           , hr_organization_information      oit
           , per_assignment_extra_info        aei
           , per_assignments_f                asg
           , per_people_f                     pap
      , (select end_date from per_time_periods ptp where ptp.time_period_id = p_end_period_id) ptp
       WHERE
             ppa.payroll_id         = p_payroll_id
         AND ppa.time_period_id    >= p_start_period_id
         AND ppa.time_period_id    <= p_end_period_id
         AND ppa.payroll_action_id  = paa.payroll_action_id
         AND paa.assignment_id      = nvl(p_asg_id, paa.assignment_id)
         AND paa.rowid =
         (select rowid from pay_assignment_actions paa2 where
                 paa2.assignment_id=paa.assignment_id
             and paa2.action_sequence=
             (select MAX(paa3.action_sequence) from pay_assignment_actions paa3,
                                                    pay_payroll_actions ppa2
             where paa3.assignment_id = paa.assignment_id
             and paa3.payroll_action_id = ppa2.payroll_action_id
             and ppa2.action_type       IN ('R', 'Q', 'I', 'B', 'V')
                    and ppa2.time_period_id    <= p_end_period_id
                    and ppa2.payroll_id = p_payroll_id
              )
          )
         AND paa.assignment_id               = asg.assignment_id
         AND (
              (
                   asg.effective_start_date <= ptp.end_date
               AND asg.effective_end_date   >= ptp.end_date
              )
              OR
              (
                   asg.effective_end_date   <= ptp.end_date
               AND asg.effective_end_date   =  (select max(asg2.effective_end_date)
                                                  from per_assignments_f asg2
                                                 where asg2.assignment_id = asg.assignment_id)
              )
             )
         AND asg.payroll_id              = p_payroll_id
         AND asg.assignment_id               = aei.assignment_id(+)
         AND aei.aei_information_category(+) = 'ZA_SPECIFIC_INFO'
         AND aei.aei_information7            = oit.organization_id(+)
         AND oit.org_information_context(+)  = 'ZA_LEGAL_ENTITY'
         AND asg.person_id                   = pap.person_id
         -- important, must be app eff date to get correct data
         AND asg.payroll_id                  = ppa.payroll_id
         AND g_period_end_date  BETWEEN pap.effective_start_date
                                    AND pap.effective_end_date;
   -----------------------------------------------------------
   -- Cursor csr_irp5_balances
   --
   -- select those balances that have been fed by any
   -- assignment action of the assignment within the specified
   -- time periods, the tax year
   -----------------------------------------------------------
   CURSOR csr_irp5_balances (
     -- p_asg_action_id   IN pay_assignment_actions.assignment_action_id%TYPE
      p_action_seq      IN pay_assignment_actions.action_sequence%TYPE
    , p_asg_id          IN pay_assignment_actions.assignment_id%TYPE
    , p_start_period_id IN per_time_periods.time_period_id%TYPE
    , p_end_period_id   IN per_time_periods.time_period_id%TYPE
    )
   IS
      SELECT DISTINCT
             pbc.full_balance_name       bal_name
           , pbc.code                    bal_code
           , pbc.balance_type_id         bal_id
        FROM pay_za_irp5_bal_codes       pbc
           , pay_run_result_values       prrv
           , pay_run_results             prr
           , pay_balance_feeds_f         feed
           , pay_payroll_actions         ppa
           , pay_assignment_actions      paa
       WHERE prrv.input_value_id       = feed.input_value_id
         AND prr.run_result_id         = prrv.run_result_id
        -- AND paa.assignment_action_id <= p_asg_action_id
         AND paa.action_sequence < = p_action_seq
         AND prr.assignment_action_id  = paa.assignment_action_id
         AND paa.assignment_id         = p_asg_id
         AND ppa.payroll_action_id     = paa.payroll_action_id
         AND ppa.action_type          IN ('R', 'I', 'B', 'Q', 'V')
         AND ppa.effective_date >= (select start_date from per_time_periods ptp where ptp.time_period_id = p_start_period_id)
         AND ppa.effective_date <= (select end_date from per_time_periods ptp where ptp.time_period_id = p_end_period_id)
         AND pbc.balance_type_id       = feed.balance_type_id
         AND (pbc.balance_sequence = 1
              or (pbc.code=4005 and pbc.balance_sequence=2)
              ) ;
   ------------
   -- Variables
   ------------
   l_asg_start_date      per_all_assignments_f.effective_start_date%TYPE;
   l_asg_end_date        per_all_assignments_f.effective_end_date%TYPE;
   l_asg_tax_status      pay_run_result_values.result_value%TYPE;
   l_asg_dir_value       pay_run_result_values.result_value%TYPE;
   l_asg_dys_worked      NUMBER;
   l_ptd_bal             NUMBER;
   l_mtd_bal             NUMBER;
   l_ytd_bal             NUMBER;
   l_asg_tax_status_code hr_lookups.lookup_code%TYPE;
   l_nature              hr_lookups.meaning%TYPE;
   l_bal_code            pay_za_irp5_bal_codes.code%TYPE;

-------------------------------------------------------------------------------
BEGIN --                      Pre Process  - MAIN                            --
-------------------------------------------------------------------------------
  -- hr_utility.trace_on(null,'ZATAXREG');
   hr_utility.set_location('py_za_tax_reg.pre_process',1);
   --
   set_globals (
      p_payroll_id      => p_payroll_id
    , p_start_period_id => p_start_period_id
    , p_end_period_id   => p_end_period_id
    , p_include         => p_include
    , p_retrieve_ptd    => p_retrieve_ptd
    , p_retrieve_mtd    => p_retrieve_mtd
    , p_retrieve_ytd    => p_retrieve_ytd
    );
   --
   hr_utility.set_location('py_za_tax_reg.pre_process',2);
   ------------------------
   <<Processed_Assignments>>
   ------------------------
   FOR v_assignments IN csr_processed_assignments
      ( p_payroll_id      => g_payroll_id
      , p_start_period_id => g_start_period_id
      , p_end_period_id   => g_end_period_id
      , p_asg_id          => p_assignment_id
      )
   LOOP
      hr_utility.set_location('py_za_tax_reg.pre_process',3);
      --
      IF include_assignment (
            p_asg_id         => v_assignments.assignment_id
          , p_asg_start_date => l_asg_start_date
          , p_asg_end_date   => l_asg_end_date
          )
      THEN
         hr_utility.set_location('py_za_tax_reg.pre_process',4);
         -- get assignment's tax status and directive value
         assignment_tax_sta_dir (
            p_assignment_id       => v_assignments.assignment_id
          , p_asg_tax_status      => l_asg_tax_status
          , p_asg_dir_value       => l_asg_dir_value
        , p_asg_tax_status_code => l_asg_tax_status_code
          );
         --
         -- get assignment's nature of person
         assignment_nature (
            p_assignment_id  => v_assignments.assignment_id
          , p_effective_date => v_assignments.effective_date
          , p_asg_nature     => l_nature
          );
         --
         hr_utility.set_location('py_za_tax_reg.pre_process',6);
         -- get assignment's seasonal days worked
         l_asg_dys_worked :=
            assignment_dys_worked (
               p_asg_tax_status => l_asg_tax_status
             , p_asg_action_id  => v_assignments.assignment_action_id
             , p_effective_date => v_assignments.effective_date
             );
         --
         hr_utility.set_location('py_za_tax_reg.pre_process',7);
         -----------------
         <<Balance_Values>>
         -----------------
         FOR v_bal IN csr_irp5_balances (
          --  p_asg_action_id   => v_assignments.assignment_action_id
            p_action_seq      => v_assignments.action_sequence
          , p_asg_id          => v_assignments.assignment_id
          , p_start_period_id => g_start_period_id
          , p_end_period_id   => g_end_period_id
          )
         LOOP
            hr_utility.set_location('py_za_tax_reg.pre_process',8);
            --
            --get the correct SARS Code for directors and foreign income
            l_bal_code := py_za_tax_certificates.get_sars_code(
                             p_sars_code  => v_bal.bal_code
                           , p_tax_status => l_asg_tax_status_code
                           , p_nature     => l_nature
                     );
            --
            l_ptd_bal :=
               ptd_value (
                  p_asg_action_id    => v_assignments.assignment_action_id
                , p_action_period_id => v_assignments.time_period_id
                , p_balance_type_id  => v_bal.bal_id
                , p_balance_name     => v_bal.bal_name
                , p_effective_date   => v_assignments.effective_date
                );
            --
            hr_utility.set_location('py_za_tax_reg.pre_process',9);
            --
            l_mtd_bal :=
               mtd_value (
                  p_asg_action_id   => v_assignments.assignment_action_id
                , p_balance_type_id => v_bal.bal_id
                , p_balance_name    => v_bal.bal_name
                , p_effective_date  => v_assignments.effective_date
                );
            --
            hr_utility.set_location('py_za_tax_reg.pre_process',10);
            --
            l_ytd_bal :=
               ytd_value (
                  p_asg_action_id   => v_assignments.assignment_action_id
                , p_balance_type_id => v_bal.bal_id
                , p_effective_date  => v_assignments.effective_date
                );
            --
            hr_utility.set_location('py_za_tax_reg.pre_process',11);
            --
            IF valid_record (
               p_ptd_bal          => l_ptd_bal
             , p_mtd_bal          => l_mtd_bal
             , p_ytd_bal          => l_ytd_bal
             )
            THEN
               hr_utility.set_location('py_za_tax_reg.pre_process',12);
               -- Create the register record
               --
               ins_register (
                  p_full_name             => v_assignments.full_name
                , p_employee_number       => v_assignments.employee_number
                , p_person_id             => v_assignments.person_id
                , p_date_of_birth         => v_assignments.date_of_birth
                , p_age                   => v_assignments.age
                , p_tax_reference_no      => v_assignments.tax_reference_number
                , p_cmpy_tax_reference_no => v_assignments.cmpy_tax_reference_number
                , p_tax_status            => l_asg_tax_status
                , p_tax_directive_value   => l_asg_dir_value
                , p_days_worked           => l_asg_dys_worked
                , p_assignment_id         => v_assignments.assignment_id
                , p_assignment_action_id  => v_assignments.assignment_action_id
                , p_assignment_number     => v_assignments.assignment_number
                , p_assignment_start_date => l_asg_start_date
                , p_assignment_end_date   => l_asg_end_date
                , p_bal_name              => v_bal.bal_name
                , p_bal_code              => l_bal_code
                , p_tot_ptd               => l_ptd_bal
                , p_tot_mtd               => l_mtd_bal
                , p_tot_ytd               => l_ytd_bal
                );
            END IF; -- Valid Record
         END LOOP Balance_Values;
      END IF; -- Include Assignment
   END LOOP Processed_Assignments;
   --
   hr_utility.set_location('py_za_tax_reg.pre_process',13);
   ---------------------
   -- Set out Parameters
   ---------------------
   p_tax_register_id   := g_tax_register_id;
   p_payroll_name      := g_payroll_name;
   p_period_num        := g_period_num;
   p_period_start_date := g_period_start_date;
   p_period_end_date   := g_period_end_date;
   p_tot_employees     := total_employees;
   p_tot_assignments   := total_assignments;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.pre_process',14);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END pre_process;--                     END                                   --
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- valid_record used from tax year 2010 onwards
-------------------------------------------------------------------------------
FUNCTION valid_record_01032009 (
   p_ptd_bal          IN    NUMBER DEFAULT NULL
 , p_mtd_bal          IN    NUMBER DEFAULT NULL
 , p_ytd_bal          IN    NUMBER DEFAULT NULL
 , p_code             IN    NUMBER
 , p_desc             OUT NOCOPY VARCHAR2
 )
RETURN BOOLEAN
AS
   ------------
   -- Variables
   ------------
   l_check_val VARCHAR2(1) := 'X';
   l_ret_val   BOOLEAN     DEFAULT FALSE;
   l_code      varchar2(4);
   ------------
-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   l_code  := p_code;
   hr_utility.set_location('py_za_tax_reg.valid_record_01032009 code:'||p_code,1);

   IF nvl(
           to_char(
                   nvl(
                        nvl( p_ptd_bal
                           , p_mtd_bal
                           )
                      , p_ytd_bal
                      )
                  )
         , l_check_val
         ) <> l_check_val
   THEN
      hr_utility.set_location('py_za_tax_reg.valid_record_01032009',2);
      l_ret_val := TRUE;

      if    l_code = 3665 then l_code := 3651;
      elsif l_code = 3615 then l_code := 3601;
      end if;

      -- g_code contains list of all codes which are valid and their descriptions
      if g_code.exists(l_code) then
         p_desc := g_code(l_code).bal_name;
         hr_utility.set_location('py_za_tax_reg.valid_record_01032009',2.1);
      elsif g_code.exists(l_code-50) then
         p_desc := g_code(l_code-50).bal_name;
         hr_utility.set_location('py_za_tax_reg.valid_record_01032009',2.2);
      else
         l_ret_val := FALSE;
         hr_utility.set_location('py_za_tax_reg.valid_record_01032009',2.3);
      end if;
   END IF;

   hr_utility.set_location('py_za_tax_reg.valid_record_01032009',3);
   RETURN l_ret_val;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.valid_record_01032009',4);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END valid_record_01032009;


-------------------------------------------------------------------------------
-- assignment_nature to be used from tax year 2010 onwards
-------------------------------------------------------------------------------
PROCEDURE assignment_nature_01032009 (
   p_assignment_id  IN  per_all_assignments_f.assignment_id%TYPE
 , p_effective_date IN  DATE
 , p_asg_nature     OUT NOCOPY hr_lookups.meaning%TYPE
 , p_foreign_income OUT NOCOPY varchar2
 )
AS
   ------------
   -- Variables
   ------------

   -----------------------------------------------------------------
   -- Cursor csr_asg_nature
   -----------------------------------------------------------------
   CURSOR csr_asg_nature (
       c_assignment_id   IN per_all_assignments_f.assignment_id%TYPE
     , c_effective_date  IN DATE
     )
   IS
   SELECT
          nvl(fcl.meaning, 'A') nature,
          aei.aei_information15 foreign_income
     FROM
          per_all_assignments_f      ass
        , per_assignment_extra_info  aei
        , fnd_lookup_values          fcl
    WHERE ass.assignment_id        = c_assignment_id
      AND ass.effective_start_date =
      (
       SELECT max(paf2.effective_start_date)
         FROM per_all_assignments_f paf2
        WHERE paf2.assignment_id = ass.assignment_id
          AND paf2.effective_start_date <= c_effective_date
      )
      AND ass.assignment_id            = aei.assignment_id(+)
      AND aei.aei_information_category = 'ZA_SPECIFIC_INFO'
      AND fcl.lookup_type(+)           = 'ZA_PER_NATURES'
      AND fcl.lookup_code(+)           = aei.aei_information4
      AND fcl.language(+)              = 'US';


   l_nature        hr_lookups.meaning%TYPE;

-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_tax_reg.assignment_nature_01032009',1);
   --
   FOR v_asg_nature IN csr_asg_nature
      ( c_assignment_id  => p_assignment_id
      , c_effective_date => p_effective_date
      )
   LOOP

      l_nature := v_asg_nature.nature;
      p_foreign_income := v_asg_nature.foreign_income;

   END LOOP csr_asg_nature;

   IF l_nature IS NULL THEN

      l_nature := 'A';

   END IF;
   --
   hr_utility.set_location('py_za_tax_reg.assignment_nature_01032009',2);
   --
   p_asg_nature := l_nature;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.assignment_nature_01032009',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END assignment_nature_01032009;


-------------------------------------------------------------------------------
-- get_sars_code
-------------------------------------------------------------------------------
function get_sars_code
(
   p_sars_code        in     varchar2,
   p_foreign_income   in     varchar2,
   p_nature           in     varchar2
)  return varchar2 is

l_sars_code       varchar2(256);

-------------------------------------------------------------------------------
BEGIN --                      Pre Process  - MAIN                            --
-------------------------------------------------------------------------------
   -- Local variable initialization - GSCC standards
   l_sars_code := 0;

   if (p_nature = 'C' and p_sars_code = '3601')
   then
      l_sars_code := '3615';
   else
      l_sars_code := p_sars_code;
   end if;

   if (p_foreign_income = 'Y' and to_number(l_sars_code) >= 3601 and to_number(l_sars_code) <= 3907
                              and to_number(l_sars_code) not in (3614,3908,3909,3915,3920,3921
                                                                 ,3696, 3697, 3698))
   then
      l_sars_code := to_char(to_number(l_sars_code) + 50);
   end if;

   return l_sars_code;
-------------------------------------------------------------------------------
END get_sars_code;





-------------------------------------------------------------------------------
-- fetch_code_desc
-------------------------------------------------------------------------------
PROCEDURE fetch_code_desc as
  cursor csr_code_desc is
    select lookup_code code,
           description  code_desc
    from hr_lookups
    where application_id = 800
     and lookup_type = 'ZA_SARS_CODE_DESCRIPTIONS';
-------------------------------------------------------------------------------
BEGIN --
-------------------------------------------------------------------------------
   for rec in csr_code_desc loop
       g_code(rec.code).bal_name := rec.code_desc;
   end loop;
   g_code(4103).bal_name := 'Tax';
-------------------------------------------------------------------------------
END fetch_code_desc;



-------------------------------------------------------------------------------
-- merge
-------------------------------------------------------------------------------
PROCEDURE merge (
    t_code_val IN OUT NOCOPY code_value_table
  , from_code  IN            number
  , to_code    IN            number
 ) as
    function get_bal_name (l_code number) return varchar2 is
       cursor csr_bal_name(l_code number) is
         select balance_name
         from pay_za_irp5_bal_codes
         where code = l_code;
       l_bal_name varchar2(100);
    begin
       if l_code = '4003' then
          l_bal_name := 'Current and Arrear Provident Fund';
       end if;
       open csr_bal_name(l_code);
       fetch csr_bal_name into l_bal_name;
       close csr_bal_name;

       return l_bal_name;
    end get_bal_name;
-------------------------------------------------------------------------------
BEGIN --                      Pre Process  - MAIN                            --
-------------------------------------------------------------------------------
hr_utility.set_location('Entering merge',1);
hr_utility.set_location('from_code:'||from_code,1);
hr_utility.set_location('to_code:'||to_code,1);
if t_code_val.exists(from_code) then
   hr_utility.set_location('From Code exists',2);
   t_code_val(from_code).included_in := to_code;
   if not t_code_val.exists(to_code) then
       hr_utility.set_location('To Code doesnt exists',2);
       t_code_val(to_code).bal_name := get_bal_name(to_code);
       IF g_retrieve_ptd THEN
          t_code_val(to_code).ptd_val := 0;
          t_code_val(to_code).ptd_group_val := 0;
       END IF;
       IF g_retrieve_mtd THEN
          t_code_val(to_code).mtd_val := 0;
          t_code_val(to_code).mtd_group_val := 0;
       END IF;
       IF g_retrieve_ytd THEN
          t_code_val(to_code).ytd_val := 0;
          t_code_val(to_code).ytd_group_val := 0;
       END IF;
   end if;

   IF g_retrieve_ptd THEN
      t_code_val(to_code).ptd_group_val := nvl(t_code_val(  to_code).ptd_group_val,0) +
                                           nvl(t_code_val(from_code).ptd_group_val,0) ;
   END IF;
   IF g_retrieve_mtd THEN
      t_code_val(to_code).mtd_group_val := nvl(t_code_val(  to_code).mtd_group_val,0) +
                                           nvl(t_code_val(from_code).mtd_group_val,0) ;
   END IF;
   IF g_retrieve_ytd then
      t_code_val(to_code).ytd_group_val := nvl(t_code_val(  to_code).ytd_group_val,0) +
                                           nvl(t_code_val(from_code).ytd_group_val,0) ;
   END IF;
   hr_utility.set_location('After merging',5);
   hr_utility.set_location('t_code_val(to_code).ptd_group_val:'||t_code_val(to_code).ptd_group_val,10);
   hr_utility.set_location('t_code_val(to_code).mtd_group_val:'||t_code_val(to_code).mtd_group_val,10);
   hr_utility.set_location('t_code_val(to_code).ytd_group_val:'||t_code_val(to_code).ytd_group_val,10);
end if;
hr_utility.set_location('Exiting merge',50);
-------------------------------------------------------------------------------
END merge;


--------------------------------------------------------------------------------
--populate_4149
--------------------------------------------------------------------------------
PROCEDURE populate_4149( t_code_val IN OUT NOCOPY code_value_table
                        ,p_4149_PTD IN NUMBER
                        ,p_4149_MTD IN NUMBER
                        ,p_4149_YTD IN NUMBER)
IS
BEGIN
   if not t_code_val.exists(4149) then
       IF g_retrieve_ptd THEN
          t_code_val(4149).ptd_val := 0;
          t_code_val(4149).ptd_group_val := 0;
       END IF;
       IF g_retrieve_mtd THEN
          t_code_val(4149).mtd_val := 0;
          t_code_val(4149).mtd_group_val := 0;
       END IF;
       IF g_retrieve_ytd THEN
          t_code_val(4149).ytd_val := 0;
          t_code_val(4149).ytd_group_val := 0;
       END IF;
   end if;

   --Populate 4103 value in 4149
   merge(t_code_val,4103,4149);
   IF g_retrieve_ptd THEN
      t_code_val(4149).ptd_group_val :=    t_code_val(4149).ptd_group_val +
                                           p_4149_PTD;
   END IF;
   IF g_retrieve_mtd THEN
      t_code_val(4149).mtd_group_val :=    t_code_val(4149).mtd_group_val +
                                           p_4149_MTD;
   END IF;
   IF g_retrieve_ytd then
      t_code_val(4149).ytd_group_val :=    t_code_val(4149).ytd_group_val +
                                           p_4149_YTD;
   END IF;


END;
-----------------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Procedure pre_process to be used from tax year 2010 onwards
--
-- The Pre Process procedure called by the ZA Tax Register Report
-- It populates the pay_za_tax_registers table with
-- processed assignment balance value information
-------------------------------------------------------------------------------
PROCEDURE pre_process_01032009 (
   p_payroll_id        IN     pay_all_payrolls_f.payroll_id%TYPE
 , p_start_period_id   IN     per_time_periods.time_period_id%TYPE
 , p_end_period_id     IN     per_time_periods.time_period_id%TYPE
 , p_include           IN     VARCHAR2
 , p_assignment_id     IN     per_all_assignments_f.assignment_id%TYPE
 , p_retrieve_ptd      IN     VARCHAR2
 , p_retrieve_mtd      IN     VARCHAR2
 , p_retrieve_ytd      IN     VARCHAR2
 , p_tax_register_id      OUT NOCOPY pay_za_tax_registers.tax_register_id%TYPE
 , p_payroll_name         OUT NOCOPY pay_all_payrolls_f.payroll_name%TYPE
 , p_period_num           OUT NOCOPY per_time_periods.period_num%TYPE
 , p_period_start_date    OUT NOCOPY per_time_periods.start_date%TYPE
 , p_period_end_date      OUT NOCOPY per_time_periods.end_date%TYPE
 , p_tot_employees        OUT NOCOPY NUMBER
 , p_tot_assignments      OUT NOCOPY NUMBER
 )
AS
   -----------------------------------------------------------------
   -- Cursor csr_processed_assignments
   --
   -- Selects processed assignments and corresponding person details
   -- for a specific payroll within two time periods
   -- returning the maximum assignment action
   -----------------------------------------------------------------
   -- Bug 5330452
   CURSOR csr_processed_assignments (
       p_payroll_id      IN pay_all_payrolls_f.payroll_id%TYPE
     , p_start_period_id IN per_time_periods.time_period_id%TYPE
     , p_end_period_id   IN per_time_periods.time_period_id%TYPE
     , p_asg_id          IN per_all_assignments_f.assignment_id%TYPE DEFAULT NULL
     )
   IS
      SELECT
             paa.assignment_action_id
           , paa.assignment_id
           , paa.action_sequence
           , ppa.time_period_id
           , ppa.effective_date
           , asg.assignment_number
           , pap.person_id
           , pap.full_name
           , pap.date_of_birth
           , pap.employee_number
           , pap.per_information1 tax_reference_number
           , trunc(months_between(g_period_end_date, pap.date_of_birth)/12) age
           , oit.org_information3 cmpy_tax_reference_number
        FROM
             pay_assignment_actions           paa
           , pay_payroll_actions              ppa
           , hr_organization_information      oit
           , per_assignment_extra_info        aei
           , per_assignments_f                asg
           , per_people_f                     pap
      , (select end_date from per_time_periods ptp where ptp.time_period_id = p_end_period_id) ptp
       WHERE
             ppa.payroll_id         = p_payroll_id
         AND ppa.time_period_id    >= p_start_period_id
         AND ppa.time_period_id    <= p_end_period_id
         AND ppa.payroll_action_id  = paa.payroll_action_id
         AND paa.assignment_id      = nvl(p_asg_id, paa.assignment_id)
         AND paa.rowid =
         (select rowid from pay_assignment_actions paa2 where
                 paa2.assignment_id=paa.assignment_id
             and paa2.action_sequence=
             (select MAX(paa3.action_sequence) from pay_assignment_actions paa3,
                                                    pay_payroll_actions ppa2
             where paa3.assignment_id = paa.assignment_id
             and paa3.payroll_action_id = ppa2.payroll_action_id
             and ppa2.action_type       IN ('R', 'Q', 'I', 'B', 'V')
                    and ppa2.time_period_id    <= p_end_period_id
                    and ppa2.payroll_id = p_payroll_id
              )
          )
         AND paa.assignment_id               = asg.assignment_id
         AND (
              (
                   asg.effective_start_date <= ptp.end_date
               AND asg.effective_end_date   >= ptp.end_date
              )
              OR
              (
                   asg.effective_end_date   <= ptp.end_date
               AND asg.effective_end_date   =  (select max(asg2.effective_end_date)
                                                  from per_assignments_f asg2
                                                 where asg2.assignment_id = asg.assignment_id)
              )
             )
         AND asg.payroll_id              = p_payroll_id
         AND asg.assignment_id               = aei.assignment_id(+)
         AND aei.aei_information_category(+) = 'ZA_SPECIFIC_INFO'
         AND aei.aei_information7            = oit.organization_id(+)
         AND oit.org_information_context(+)  = 'ZA_LEGAL_ENTITY'
         AND asg.person_id                   = pap.person_id
         -- important, must be app eff date to get correct data
         AND asg.payroll_id                  = ppa.payroll_id
         AND g_period_end_date  BETWEEN pap.effective_start_date
                                    AND pap.effective_end_date;
   -----------------------------------------------------------
   -- Cursor csr_irp5_balances
   --
   -- select those balances that have been fed by any
   -- assignment action of the assignment within the specified
   -- time periods, the tax year
   -----------------------------------------------------------
   CURSOR csr_irp5_balances (
     -- p_asg_action_id   IN pay_assignment_actions.assignment_action_id%TYPE
      p_action_seq      IN pay_assignment_actions.action_sequence%TYPE
    , p_asg_id          IN pay_assignment_actions.assignment_id%TYPE
    , p_start_period_id IN per_time_periods.time_period_id%TYPE
    , p_end_period_id   IN per_time_periods.time_period_id%TYPE
    )
   IS
      SELECT DISTINCT
             pbc.balance_name            bal_name
           , pbc.code                    bal_code
           , pbc.balance_type_id         bal_id
        FROM pay_za_irp5_bal_codes       pbc
           , pay_run_result_values       prrv
           , pay_run_results             prr
           , pay_balance_feeds_f         feed
           , pay_payroll_actions         ppa
           , pay_assignment_actions      paa
       WHERE prrv.input_value_id       = feed.input_value_id
         AND prr.run_result_id         = prrv.run_result_id
        -- AND paa.assignment_action_id <= p_asg_action_id
         AND paa.action_sequence < = p_action_seq
         AND prr.assignment_action_id  = paa.assignment_action_id
         AND paa.assignment_id         = p_asg_id
         AND ppa.payroll_action_id     = paa.payroll_action_id
         AND ppa.action_type          IN ('R', 'I', 'B', 'Q', 'V')
         AND ppa.effective_date >= (select start_date from per_time_periods ptp where ptp.time_period_id = p_start_period_id)
         AND ppa.effective_date <= (select end_date from per_time_periods ptp where ptp.time_period_id = p_end_period_id)
         AND pbc.balance_type_id       = feed.balance_type_id
         AND (pbc.balance_sequence = 1
              or (pbc.code=4005 and pbc.balance_sequence=2)
              )
      UNION
      SELECT DISTINCT
             pbt.balance_name            bal_name
           , decode(pbt.balance_name,'Skills Levy',4142,4141) bal_code
           , pbt.balance_type_id         bal_id
        FROM pay_balance_types           pbt
           , pay_run_result_values       prrv
           , pay_run_results             prr
           , pay_balance_feeds_f         feed
           , pay_payroll_actions         ppa
           , pay_assignment_actions      paa
       WHERE prrv.input_value_id       = feed.input_value_id
         AND prr.run_result_id         = prrv.run_result_id
         AND paa.action_sequence < = p_action_seq
         AND prr.assignment_action_id  = paa.assignment_action_id
         AND paa.assignment_id         = p_asg_id
         AND ppa.payroll_action_id     = paa.payroll_action_id
         AND ppa.action_type          IN ('R', 'I', 'B', 'Q', 'V')
         AND ppa.effective_date >= (select start_date from per_time_periods ptp where ptp.time_period_id = p_start_period_id)
         AND ppa.effective_date <= (select end_date from per_time_periods ptp where ptp.time_period_id = p_end_period_id)
         AND pbt.balance_type_id       = feed.balance_type_id
         AND pbt.balance_name in ('Skills Levy','UIF Employee Contribution','UIF Employer Contribution')
         AND pbt.legislation_code='ZA';
/*
      SELECT DISTINCT
             pbt.balance_name            bal_name
           , decode(pbt.balance_name,'Skills Levy',4142,4141) bal_code
           , pbt.balance_type_id         bal_id
        FROM pay_balance_types           pbt
       WHERE pbt.balance_name in ('Skills Levy','UIF Employee Contribution','UIF Employer Contribution')
         AND pbt.legislation_code='ZA'; */

   ------------
   -- Variables
   ------------
   l_asg_start_date      per_all_assignments_f.effective_start_date%TYPE;
   l_asg_end_date        per_all_assignments_f.effective_end_date%TYPE;
   l_asg_tax_status      pay_run_result_values.result_value%TYPE;
   l_asg_dir_value       pay_run_result_values.result_value%TYPE;
   l_asg_dys_worked      NUMBER;
   l_ptd_bal             NUMBER;
   l_mtd_bal             NUMBER;
   l_ytd_bal             NUMBER;
   l_asg_tax_status_code hr_lookups.lookup_code%TYPE;
   l_nature              hr_lookups.meaning%TYPE;
   l_bal_code            pay_za_irp5_bal_codes.code%TYPE;
   t_code_val            code_value_table;
   l_code                pay_za_irp5_bal_codes.code%TYPE;
   l_asg_foreign_income  varchar2(1);
   l_4149_ptd            NUMBER;
   l_4149_mtd            NUMBER;
   l_4149_ytd            NUMBER;

-------------------------------------------------------------------------------
BEGIN --                      Pre Process  - MAIN                            --
-------------------------------------------------------------------------------
--   hr_utility.trace_on(null,'ZATAXREG');
   hr_utility.set_location('py_za_tax_reg.pre_process_01032009',1);
   --
   set_globals (
      p_payroll_id      => p_payroll_id
    , p_start_period_id => p_start_period_id
    , p_end_period_id   => p_end_period_id
    , p_include         => p_include
    , p_retrieve_ptd    => p_retrieve_ptd
    , p_retrieve_mtd    => p_retrieve_mtd
    , p_retrieve_ytd    => p_retrieve_ytd
    );
   --
   -- fetch code descriptions
   fetch_code_desc;
   --
   hr_utility.set_location('py_za_tax_reg.pre_process_01032009',2);
   ------------------------
   <<Processed_Assignments>>
   ------------------------
   FOR v_assignments IN csr_processed_assignments
      ( p_payroll_id      => g_payroll_id
      , p_start_period_id => g_start_period_id
      , p_end_period_id   => g_end_period_id
      , p_asg_id          => p_assignment_id
      )
   LOOP
      hr_utility.set_location('py_za_tax_reg.pre_process_01032009',3);
      hr_utility.set_location('Assignment ID:'||v_assignments.assignment_id,3);
      hr_utility.set_location('Employee Num :'||v_assignments.employee_number,3);
      --
      IF include_assignment (
            p_asg_id         => v_assignments.assignment_id
          , p_asg_start_date => l_asg_start_date
          , p_asg_end_date   => l_asg_end_date
          )
      THEN
         hr_utility.set_location('py_za_tax_reg.pre_process_01032009',4);
         -- get assignment's tax status and directive value
         assignment_tax_sta_dir (
            p_assignment_id       => v_assignments.assignment_id
          , p_asg_tax_status      => l_asg_tax_status
          , p_asg_dir_value       => l_asg_dir_value
          , p_asg_tax_status_code => l_asg_tax_status_code
          );
         --
         -- get assignment's nature of person
         assignment_nature_01032009 (
            p_assignment_id  => v_assignments.assignment_id
          , p_effective_date => v_assignments.effective_date
          , p_asg_nature     => l_nature
          , p_foreign_income => l_asg_foreign_income
          );
         --
         hr_utility.set_location('py_za_tax_reg.pre_process_01032009',6);
         -- get assignment's seasonal days worked
         l_asg_dys_worked :=
            assignment_dys_worked (
               p_asg_tax_status => l_asg_tax_status
             , p_asg_action_id  => v_assignments.assignment_action_id
             , p_effective_date => v_assignments.effective_date
             );
         --
         hr_utility.set_location('py_za_tax_reg.pre_process_01032009',7);
         -----------------
         <<Balance_Values>>
         -----------------
         t_code_val.delete;
         l_4149_ptd :=0;
         l_4149_mtd :=0;
         l_4149_ytd :=0;
         FOR v_bal IN csr_irp5_balances (
          --  p_asg_action_id   => v_assignments.assignment_action_id
            p_action_seq      => v_assignments.action_sequence
          , p_asg_id          => v_assignments.assignment_id
          , p_start_period_id => g_start_period_id
          , p_end_period_id   => g_end_period_id
          )
         LOOP
            hr_utility.set_location('py_za_tax_reg.pre_process_01032009',8);
            --
            hr_utility.set_location('Balance Type ID:'||v_bal.bal_id,8);
            hr_utility.set_location('Balance Name   :'||v_bal.bal_name,8);

            l_ptd_bal :=
               ptd_value (
                  p_asg_action_id    => v_assignments.assignment_action_id
                , p_action_period_id => v_assignments.time_period_id
                , p_balance_type_id  => v_bal.bal_id
                , p_balance_name     => v_bal.bal_name
                , p_effective_date   => v_assignments.effective_date
                );
            --
            hr_utility.set_location('py_za_tax_reg.pre_process_01032009',9);
            --
            l_mtd_bal :=
               mtd_value (
                  p_asg_action_id   => v_assignments.assignment_action_id
                , p_balance_type_id => v_bal.bal_id
                , p_balance_name    => v_bal.bal_name
                , p_effective_date  => v_assignments.effective_date
                );
            --
            hr_utility.set_location('py_za_tax_reg.pre_process_01032009',10);
            --
            l_ytd_bal :=
               ytd_value (
                  p_asg_action_id   => v_assignments.assignment_action_id
                , p_balance_type_id => v_bal.bal_id
                , p_effective_date  => v_assignments.effective_date
                );
            --
            hr_utility.set_location('py_za_tax_reg.pre_process_01032009',11);
            --
            hr_utility.set_location('py_za_tax_reg.pre_process_01032009',12);
            hr_utility.set_location('code :'||v_bal.bal_code,12);
            hr_utility.set_location('PTD:'||l_ptd_bal||'   MTD:'||l_mtd_bal||'    YTD:'||l_ytd_bal,12);
            t_code_val(v_bal.bal_code).bal_name := v_bal.bal_name;

            --Retrieve the value to be populated in code 4149
            --Value of Tax i.e. 4103 will be merged in code 4149 through populate_4149
            if v_bal.bal_name in ('Tax on Lump Sums','Voluntary Tax')
               OR v_bal.bal_code in (4115,4141,4142) then
                  l_4149_ptd:=l_4149_ptd + nvl(l_ptd_bal,0);
                  l_4149_mtd:=l_4149_mtd + nvl(l_mtd_bal,0);
                  l_4149_ytd:=l_4149_ytd + nvl(l_ytd_bal,0);
                  hr_utility.set_location('l_4149_ptd:'||l_4149_ptd,12);
                  hr_utility.set_location('l_4149_mtd:'||l_4149_mtd,12);
                  hr_utility.set_location('l_4149_ytd:'||l_4149_ytd,12);
            end if;

            if t_code_val.exists(v_bal.bal_code) then
               hr_utility.set_location('Code'||v_bal.bal_code||' exists',12);
               t_code_val(v_bal.bal_code).ptd_val  := nvl(t_code_val(v_bal.bal_code).ptd_val,0) + nvl(l_ptd_bal,0);
               t_code_val(v_bal.bal_code).mtd_val  := nvl(t_code_val(v_bal.bal_code).mtd_val,0) + nvl(l_mtd_bal,0);
               t_code_val(v_bal.bal_code).ytd_val  := nvl(t_code_val(v_bal.bal_code).ytd_val,0) + nvl(l_ytd_bal,0);
            else
               hr_utility.set_location('Code' ||v_bal.bal_code||' does not exists',12);
               t_code_val(v_bal.bal_code).ptd_val  := l_ptd_bal;
               t_code_val(v_bal.bal_code).mtd_val  := l_mtd_bal;
               t_code_val(v_bal.bal_code).ytd_val  := l_ytd_bal;
            end if;
            t_code_val(v_bal.bal_code).ptd_group_val := t_code_val(v_bal.bal_code).ptd_val;
            t_code_val(v_bal.bal_code).mtd_group_val := t_code_val(v_bal.bal_code).mtd_val;
            t_code_val(v_bal.bal_code).ytd_group_val := t_code_val(v_bal.bal_code).ytd_val;
            hr_utility.set_location('t_code_val(v_bal.bal_code).ptd_val:'||t_code_val(v_bal.bal_code).ptd_val,12);
            hr_utility.set_location('t_code_val(v_bal.bal_code).mtd_val:'||t_code_val(v_bal.bal_code).mtd_val,12);
            hr_utility.set_location('t_code_val(v_bal.bal_code).ytd_val:'||t_code_val(v_bal.bal_code).ytd_val,12);
            hr_utility.set_location('t_code_val(v_bal.bal_code).ptd_group_val:'||t_code_val(v_bal.bal_code).ptd_group_val,12);
            hr_utility.set_location('t_code_val(v_bal.bal_code).mtd_group_val:'||t_code_val(v_bal.bal_code).mtd_group_val,12);
            hr_utility.set_location('t_code_val(v_bal.bal_code).ytd_group_val:'||t_code_val(v_bal.bal_code).ytd_group_val,12);

          END LOOP Balance_Values;

         -- Merge codes
         --
         merge(t_code_val,3603,3601);
         merge(t_code_val,3607,3601);
         merge(t_code_val,3610,3601);
         merge(t_code_val,3604,3602);
         merge(t_code_val,3609,3602);
         merge(t_code_val,3612,3602);
         merge(t_code_val,3706,3713);
         merge(t_code_val,3710,3713);
         merge(t_code_val,3711,3713);
         merge(t_code_val,3712,3713);
         merge(t_code_val,3705,3714);
         merge(t_code_val,3709,3714);
         merge(t_code_val,3716,3714);
         merge(t_code_val,3803,3801);
         merge(t_code_val,3804,3801);
         merge(t_code_val,3805,3801);
         merge(t_code_val,3806,3801);
         merge(t_code_val,3807,3801);
         merge(t_code_val,3808,3801);
         merge(t_code_val,3809,3801);
         merge(t_code_val,4004,4003);

         --Populate Code 4149 (i.e. Total Tax + SDL + UIF)
         populate_4149(t_code_val,l_4149_ptd,l_4149_mtd,l_4149_ytd);


         --Create the register records
         --
         hr_utility.set_location('After Merging codes',12.1);
         l_code := t_code_val.first;
         while l_code is not null
         loop
               zvl(t_code_val(l_code).ptd_group_val);
               zvl(t_code_val(l_code).mtd_group_val);
               zvl(t_code_val(l_code).ytd_group_val);
               hr_utility.set_location('py_za_tax_reg.pre_process_01032009',12.2);
               hr_utility.set_location('Code :'||l_code||'  PTD:'||t_code_val(l_code).ptd_group_val||'  MTD:'||t_code_val(l_code).mtd_group_val||'  YTD:'||t_code_val(l_code).ytd_group_val,12.2);
               IF valid_record_01032009 (
                     p_ptd_bal          => t_code_val(l_code).ptd_group_val
                   , p_mtd_bal          => t_code_val(l_code).mtd_group_val
                   , p_ytd_bal          => t_code_val(l_code).ytd_group_val
                   , p_code             => l_code
                   , p_desc             => t_code_val(l_code).bal_name
                )
              THEN
                --
                --get the correct SARS Code for directors and foreign income
                hr_utility.set_location('py_za_tax_reg.pre_process_01032009',12.3);
                l_bal_code := get_sars_code(
                             p_sars_code      => l_code
                           , p_foreign_income => l_asg_foreign_income
                           , p_nature         => l_nature
                           );
                if t_code_val(l_code).included_in is null then
                   hr_utility.set_location('py_za_tax_reg.pre_process_01032009',12.4);
                   ins_register (
                      p_full_name              => v_assignments.full_name
                     , p_employee_number       => v_assignments.employee_number
                     , p_person_id             => v_assignments.person_id
                     , p_date_of_birth         => v_assignments.date_of_birth
                     , p_age                   => v_assignments.age
                     , p_tax_reference_no      => v_assignments.tax_reference_number
                     , p_cmpy_tax_reference_no => v_assignments.cmpy_tax_reference_number
                     , p_tax_status            => l_asg_tax_status
                     , p_tax_directive_value   => l_asg_dir_value
                     , p_days_worked           => l_asg_dys_worked
                     , p_assignment_id         => v_assignments.assignment_id
                     , p_assignment_action_id  => v_assignments.assignment_action_id
                     , p_assignment_number     => v_assignments.assignment_number
                     , p_assignment_start_date => l_asg_start_date
                     , p_assignment_end_date   => l_asg_end_date
                     , p_bal_name              => t_code_val(l_code).bal_name
                     , p_bal_code              => l_bal_code
                     , p_tot_ptd               => t_code_val(l_code).ptd_group_val
                     , p_tot_mtd               => t_code_val(l_code).mtd_group_val
                     , p_tot_ytd               => t_code_val(l_code).ytd_group_val
                    );
                end if;
              END IF; -- valid record
              l_code := t_code_val.next(l_code);
         end loop;
      END IF; -- Include Assignment
   END LOOP Processed_Assignments;
   --
   hr_utility.set_location('py_za_tax_reg.pre_process_01032009',13);
   ---------------------
   -- Set out Parameters
   ---------------------
   p_tax_register_id   := g_tax_register_id;
   p_payroll_name      := g_payroll_name;
   p_period_num        := g_period_num;
   p_period_start_date := g_period_start_date;
   p_period_end_date   := g_period_end_date;
   p_tot_employees     := total_employees;
   p_tot_assignments   := total_assignments;
EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_tax_reg.pre_process_01032009',14);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END pre_process_01032009;--                     END                                   --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
END py_za_tax_reg;--              END OF PACKAGE                             --

/
